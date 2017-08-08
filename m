Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 322736B02FD
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 02:50:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p20so24888213pfj.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 23:50:35 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n16si466300pll.676.2017.08.07.23.50.33
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 23:50:33 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 6/6] fs: remove rw_page
Date: Tue,  8 Aug 2017 15:50:24 +0900
Message-Id: <1502175024-28338-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1502175024-28338-1-git-send-email-minchan@kernel.org>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

Currently, there is no user of rw_page so remove it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/block_dev.c         | 76 --------------------------------------------------
 fs/mpage.c             | 12 ++------
 include/linux/blkdev.h |  4 ---
 mm/page_io.c           | 17 -----------
 4 files changed, 2 insertions(+), 107 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 9941dc8342df..6fb408041e7d 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -649,82 +649,6 @@ int blkdev_fsync(struct file *filp, loff_t start, loff_t end, int datasync)
 }
 EXPORT_SYMBOL(blkdev_fsync);
 
-/**
- * bdev_read_page() - Start reading a page from a block device
- * @bdev: The device to read the page from
- * @sector: The offset on the device to read the page to (need not be aligned)
- * @page: The page to read
- *
- * On entry, the page should be locked.  It will be unlocked when the page
- * has been read.  If the block driver implements rw_page synchronously,
- * that will be true on exit from this function, but it need not be.
- *
- * Errors returned by this function are usually "soft", eg out of memory, or
- * queue full; callers should try a different route to read this page rather
- * than propagate an error back up the stack.
- *
- * Return: negative errno if an error occurs, 0 if submission was successful.
- */
-int bdev_read_page(struct block_device *bdev, sector_t sector,
-			struct page *page)
-{
-	const struct block_device_operations *ops = bdev->bd_disk->fops;
-	int result = -EOPNOTSUPP;
-
-	if (!ops->rw_page || bdev_get_integrity(bdev))
-		return result;
-
-	result = blk_queue_enter(bdev->bd_queue, false);
-	if (result)
-		return result;
-	result = ops->rw_page(bdev, sector + get_start_sect(bdev), page, false);
-	blk_queue_exit(bdev->bd_queue);
-	return result;
-}
-EXPORT_SYMBOL_GPL(bdev_read_page);
-
-/**
- * bdev_write_page() - Start writing a page to a block device
- * @bdev: The device to write the page to
- * @sector: The offset on the device to write the page to (need not be aligned)
- * @page: The page to write
- * @wbc: The writeback_control for the write
- *
- * On entry, the page should be locked and not currently under writeback.
- * On exit, if the write started successfully, the page will be unlocked and
- * under writeback.  If the write failed already (eg the driver failed to
- * queue the page to the device), the page will still be locked.  If the
- * caller is a ->writepage implementation, it will need to unlock the page.
- *
- * Errors returned by this function are usually "soft", eg out of memory, or
- * queue full; callers should try a different route to write this page rather
- * than propagate an error back up the stack.
- *
- * Return: negative errno if an error occurs, 0 if submission was successful.
- */
-int bdev_write_page(struct block_device *bdev, sector_t sector,
-			struct page *page, struct writeback_control *wbc)
-{
-	int result;
-	const struct block_device_operations *ops = bdev->bd_disk->fops;
-
-	if (!ops->rw_page || bdev_get_integrity(bdev))
-		return -EOPNOTSUPP;
-	result = blk_queue_enter(bdev->bd_queue, false);
-	if (result)
-		return result;
-
-	set_page_writeback(page);
-	result = ops->rw_page(bdev, sector + get_start_sect(bdev), page, true);
-	if (result)
-		end_page_writeback(page);
-	else
-		unlock_page(page);
-	blk_queue_exit(bdev->bd_queue);
-	return result;
-}
-EXPORT_SYMBOL_GPL(bdev_write_page);
-
 /*
  * pseudo-fs
  */
diff --git a/fs/mpage.c b/fs/mpage.c
index eaeaef27d693..707d77fe7289 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -301,11 +301,8 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 				submit_bio(&sbio);
 				goto out;
 			}
-
-			if (!bdev_read_page(bdev, blocks[0] << (blkbits - 9),
-								page))
-				goto out;
 		}
+
 		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 				min_t(int, nr_pages, BIO_MAX_PAGES), gfp);
 		if (bio == NULL)
@@ -646,13 +643,8 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 				submit_bio(&sbio);
 				clean_buffers(page, first_unmapped);
 			}
-
-			if (!bdev_write_page(bdev, blocks[0] << (blkbits - 9),
-								page, wbc)) {
-				clean_buffers(page, first_unmapped);
-				goto out;
-			}
 		}
+
 		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 				BIO_MAX_PAGES, GFP_NOFS|__GFP_HIGH);
 		if (bio == NULL)
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 25f6a0cb27d3..21fffa849033 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1936,7 +1936,6 @@ static inline bool integrity_req_gap_front_merge(struct request *req,
 struct block_device_operations {
 	int (*open) (struct block_device *, fmode_t);
 	void (*release) (struct gendisk *, fmode_t);
-	int (*rw_page)(struct block_device *, sector_t, struct page *, bool);
 	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	unsigned int (*check_events) (struct gendisk *disk,
@@ -1954,9 +1953,6 @@ struct block_device_operations {
 
 extern int __blkdev_driver_ioctl(struct block_device *, fmode_t, unsigned int,
 				 unsigned long);
-extern int bdev_read_page(struct block_device *, sector_t, struct page *);
-extern int bdev_write_page(struct block_device *, sector_t, struct page *,
-						struct writeback_control *);
 #else /* CONFIG_BLOCK */
 
 struct block_device;
diff --git a/mm/page_io.c b/mm/page_io.c
index d794fd810773..1cbbac7b852a 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -331,12 +331,6 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc)
 		return ret;
 	}
 
-	ret = bdev_write_page(sis->bdev, swap_page_sector(page), page, wbc);
-	if (!ret) {
-		count_swpout_vm_event(page);
-		return 0;
-	}
-
 	ret = 0;
 	if (!(sis->flags & SWP_SYNC_IO)) {
 		struct bio *bio;
@@ -399,17 +393,6 @@ int swap_readpage(struct page *page, bool do_poll)
 		return ret;
 	}
 
-	ret = bdev_read_page(sis->bdev, swap_page_sector(page), page);
-	if (!ret) {
-		if (trylock_page(page)) {
-			swap_slot_free_notify(page);
-			unlock_page(page);
-		}
-
-		count_vm_event(PSWPIN);
-		return 0;
-	}
-
 	ret = 0;
 	count_vm_event(PSWPIN);
 	if (!(sis->flags & SWP_SYNC_IO)) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
