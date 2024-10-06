USE mysql_server;

CREATE TABLE products (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
quantity INT NOT NULL
);

INSERT INTO products (name, quantity) VALUES
('Sản phẩm A', 10),
('Sản phẩm B', 20),
('Sản phẩm C', 0);

DELIMITER $$

CREATE PROCEDURE place_order(IN product_id INT)
BEGIN
	DECLARE current_quantity INT;
    
  -- Bắt đầu giao dịch
    START TRANSACTION;

    -- Khóa bản ghi sản phẩm để không cho phép các giao dịch khác cập nhật
    SELECT quantity INTO current_quantity
    FROM products
    WHERE id = product_id
    FOR UPDATE;

    -- Kiểm tra số lượng sản phẩm
    IF current_quantity IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sản phẩm không tồn tại.';
    ELSEIF current_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không đủ sản phẩm để đặt hàng.';
    ELSE
        -- Giảm số lượng sản phẩm đi 1
        UPDATE products
        SET quantity = quantity - 1
        WHERE id = product_id;

        -- Lưu thay đổi
        COMMIT;
        
        SELECT CONCAT('Đặt hàng thành công cho sản phẩm ID: ', product_id) AS message;
    END IF;

    -- Nếu có lỗi, rollback
    ROLLBACK;
END $$

CALL place_order(1);
CALL place_order(2);
CALL place_order(3);
