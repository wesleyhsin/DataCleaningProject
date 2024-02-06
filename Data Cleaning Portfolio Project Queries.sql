/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- Formatted the sale date to YYYY-MM-DD
SELECT saledate, convert(date,saledate)
FROM nashvillehousing

Update nashvillehousing
SET Saledate = convert(date,saledate)

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date; 

Update nashvillehousing
SET SaleDateConverted = convert(date,saledate);

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- There are NULL values in the dataset

-- ParcelID matches with an address

--SELECT *
--FROM nashvillehousing
--where propertyaddress IS NULL
-- join table with itself

SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b ON a.parcelID = b.parcelID
	AND a.[uniqueID] <> b.[uniqueID]
WHERE a.propertyaddress is NULL

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b ON a.parcelID = b.parcelID
	AND a.[uniqueID] <> b.[uniqueID]
WHERE a.propertyaddress is NULL

SELECT *
FROM nashvillehousing
where propertyaddress IS NULL
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- Using substring, character index

SELECT
SUBSTRING(propertyaddress, 1, Charindex(',', propertyaddress)-1) as Address
, SUBSTRING(propertyaddress, Charindex(',', propertyaddress)+1, LEN(propertyaddress)) as Address
FROM nashvillehousing


ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(250); 

Update nashvillehousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, Charindex(',', propertyaddress)-1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity VARCHAR(250); 

Update nashvillehousing
SET PropertySplitCity = SUBSTRING(propertyaddress, Charindex(',', propertyaddress)+1, LEN(propertyaddress));



-- Breaking out OwnerAddress into Individual Columns (Address, City, State) Using PARSENAME
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM nashvillehousing


ALTER TABLE nashvillehousing
ADD OwnerSplitAddress NVARCHAR(250)

Update nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashvillehousing
ADD OwnerSplitCity NVARCHAR(250)

Update nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE nashvillehousing
ADD OwnerSplitState NVARCHAR(250)

Update nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



SELECT *
FROM nashvillehousing;
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(Soldasvacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
order by 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	Else SoldAsVacant
	END
FROM nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	Else SoldAsVacant
	END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- CTE

WITH RowNumCTE AS(
SELECT*,
	ROW_number() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID
		) row_num
FROM nashvillehousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- Deleting original owner address and property adddress after spliting them
SELECT*
FROM nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



ALTER TABLE nashvillehousing
DROP COLUMN SaleDate


