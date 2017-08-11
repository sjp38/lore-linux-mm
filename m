Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 098796B02FA
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 01:17:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s14so27578913pgs.4
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 22:17:52 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p3si29541pgf.103.2017.08.10.22.17.50
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 22:17:50 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 6/7] zram: remove zram_rw_page
Date: Fri, 11 Aug 2017 14:17:26 +0900
Message-Id: <1502428647-28928-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1502428647-28928-1-git-send-email-minchan@kernel.org>
References: <1502428647-28928-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

With on-stack-bio, rw_page interface doesn't provide a clear performance
benefit for zram and surely has a maintenance burden, so remove the
last user to remove rw_page completely.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 52 -------------------------------------------
 1 file changed, 52 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index a60441bd6f0c..b30f70d593d0 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -1268,57 +1268,6 @@ static void zram_slot_free_notify(struct block_device *bdev,
 	atomic64_inc(&zram->stats.notify_free);
 }
 
-static int zram_rw_page(struct block_device *bdev, sector_t sector,
-		       struct page *page, bool is_write)
-{
-	int offset, ret;
-	u32 index;
-	struct zram *zram;
-	struct bio_vec bv;
-
-	if (PageTransHuge(page))
-		return -ENOTSUPP;
-	zram = bdev->bd_disk->private_data;
-
-	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
-		atomic64_inc(&zram->stats.invalid_io);
-		ret = -EINVAL;
-		goto out;
-	}
-
-	index = sector >> SECTORS_PER_PAGE_SHIFT;
-	offset = (sector & (SECTORS_PER_PAGE - 1)) << SECTOR_SHIFT;
-
-	bv.bv_page = page;
-	bv.bv_len = PAGE_SIZE;
-	bv.bv_offset = 0;
-
-	ret = zram_bvec_rw(zram, &bv, index, offset, is_write, NULL);
-out:
-	/*
-	 * If I/O fails, just return error(ie, non-zero) without
-	 * calling page_endio.
-	 * It causes resubmit the I/O with bio request by upper functions
-	 * of rw_page(e.g., swap_readpage, __swap_writepage) and
-	 * bio->bi_end_io does things to handle the error
-	 * (e.g., SetPageError, set_page_dirty and extra works).
-	 */
-	if (unlikely(ret < 0))
-		return ret;
-
-	switch (ret) {
-	case 0:
-		page_endio(page, is_write, 0);
-		break;
-	case 1:
-		ret = 0;
-		break;
-	default:
-		WARN_ON(1);
-	}
-	return ret;
-}
-
 static void zram_reset_device(struct zram *zram)
 {
 	struct zcomp *comp;
@@ -1460,7 +1409,6 @@ static int zram_open(struct block_device *bdev, fmode_t mode)
 static const struct block_device_operations zram_devops = {
 	.open = zram_open,
 	.swap_slot_free_notify = zram_slot_free_notify,
-	.rw_page = zram_rw_page,
 	.owner = THIS_MODULE
 };
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
