Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id EC5046B00B7
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 19:00:02 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so7547317pad.15
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 16:00:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id si6si7753220pab.285.2014.04.13.16.00.01
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 16:00:02 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v3 4/7] Add bdev_read_page() and bdev_write_page()
Date: Sun, 13 Apr 2014 18:59:53 -0400
Message-Id: <0d8d65c0afe9c4bf93c9bdda154e81081e4f7e7a.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1397429628.git.matthew.r.wilcox@intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

A block device driver may choose to provide a rw_page operation.
These will be called when the filesystem is attempting to do page sized
I/O to page cache pages (ie not for direct I/O).  This does preclude
I/Os that are larger than page size, so this may only be a performance
gain for some devices.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Tested-by: Dheeraj Reddy <dheeraj.reddy@intel.com>
---
 fs/block_dev.c         | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/mpage.c             | 12 ++++++++++
 include/linux/blkdev.h |  4 ++++
 3 files changed, 79 insertions(+)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 552a8d1..83fba15 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -363,6 +363,69 @@ int blkdev_fsync(struct file *filp, loff_t start, loff_t end, int datasync)
 }
 EXPORT_SYMBOL(blkdev_fsync);
 
+/**
+ * bdev_read_page() - Start reading a page from a block device
+ * @bdev: The device to read the page from
+ * @sector: The offset on the device to read the page to (need not be aligned)
+ * @page: The page to read
+ *
+ * On entry, the page should be locked.  It will be unlocked when the page
+ * has been read.  If the block driver implements rw_page synchronously,
+ * that will be true on exit from this function, but it need not be.
+ *
+ * Errors returned by this function are usually "soft", eg out of memory, or
+ * queue full; callers should try a different route to read this page rather
+ * than propagate an error back up the stack.
+ *
+ * Return: negative errno if an error occurs, 0 if submission was successful.
+ */
+int bdev_read_page(struct block_device *bdev, sector_t sector,
+			struct page *page)
+{
+	const struct block_device_operations *ops = bdev->bd_disk->fops;
+	if (!ops->rw_page)
+		return -EOPNOTSUPP;
+	return ops->rw_page(bdev, sector + get_start_sect(bdev), page, READ);
+}
+EXPORT_SYMBOL_GPL(bdev_read_page);
+
+/**
+ * bdev_write_page() - Start writing a page to a block device
+ * @bdev: The device to write the page to
+ * @sector: The offset on the device to write the page to (need not be aligned)
+ * @page: The page to write
+ * @wbc: The writeback_control for the write
+ *
+ * On entry, the page should be locked and not currently under writeback.
+ * On exit, if the write started successfully, the page will be unlocked and
+ * under writeback.  If the write failed already (eg the driver failed to
+ * queue the page to the device), the page will still be locked.  If the
+ * caller is a ->writepage implementation, it will need to unlock the page.
+ *
+ * Errors returned by this function are usually "soft", eg out of memory, or
+ * queue full; callers should try a different route to write this page rather
+ * than propagate an error back up the stack.
+ *
+ * Return: negative errno if an error occurs, 0 if submission was successful.
+ */
+int bdev_write_page(struct block_device *bdev, sector_t sector,
+			struct page *page, struct writeback_control *wbc)
+{
+	int result;
+	int rw = (wbc->sync_mode == WB_SYNC_ALL) ? WRITE_SYNC : WRITE;
+	const struct block_device_operations *ops = bdev->bd_disk->fops;
+	if (!ops->rw_page)
+		return -EOPNOTSUPP;
+	set_page_writeback(page);
+	result = ops->rw_page(bdev, sector + get_start_sect(bdev), page, rw);
+	if (result)
+		end_page_writeback(page);
+	else
+		unlock_page(page);
+	return result;
+}
+EXPORT_SYMBOL_GPL(bdev_write_page);
+
 /*
  * pseudo-fs
  */
diff --git a/fs/mpage.c b/fs/mpage.c
index 10da0da..5f9ed62 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -269,6 +269,11 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 
 alloc_new:
 	if (bio == NULL) {
+		if (first_hole == blocks_per_page) {
+			if (!bdev_read_page(bdev, blocks[0] << (blkbits - 9),
+								page))
+				goto out;
+		}
 		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 			  	min_t(int, nr_pages, bio_get_nr_vecs(bdev)),
 				GFP_KERNEL);
@@ -587,6 +592,13 @@ page_is_mapped:
 
 alloc_new:
 	if (bio == NULL) {
+		if (first_unmapped == blocks_per_page) {
+			if (!bdev_write_page(bdev, blocks[0] << (blkbits - 9),
+								page, wbc)) {
+				clean_buffers(page, first_unmapped);
+				goto out;
+			}
+		}
 		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 				bio_get_nr_vecs(bdev), GFP_NOFS|__GFP_HIGH);
 		if (bio == NULL)
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 0d84981..6d2de38 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1570,6 +1570,7 @@ static inline bool blk_integrity_is_initialized(struct gendisk *g)
 struct block_device_operations {
 	int (*open) (struct block_device *, fmode_t);
 	void (*release) (struct gendisk *, fmode_t);
+	int (*rw_page)(struct block_device *, sector_t, struct page *, int rw);
 	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*direct_access) (struct block_device *, sector_t,
@@ -1588,6 +1589,9 @@ struct block_device_operations {
 
 extern int __blkdev_driver_ioctl(struct block_device *, fmode_t, unsigned int,
 				 unsigned long);
+extern int bdev_read_page(struct block_device *, sector_t, struct page *);
+extern int bdev_write_page(struct block_device *, sector_t, struct page *,
+						struct writeback_control *);
 #else /* CONFIG_BLOCK */
 /*
  * stubs for when the block layer is configured out
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
