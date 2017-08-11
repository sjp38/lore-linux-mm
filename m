Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE676B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 01:17:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z3so27607096pfk.4
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 22:17:48 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k6si15491pln.803.2017.08.10.22.17.46
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 22:17:47 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/7] zram: set BDI_CAP_STABLE_WRITES once
Date: Fri, 11 Aug 2017 14:17:21 +0900
Message-Id: <1502428647-28928-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1502428647-28928-1-git-send-email-minchan@kernel.org>
References: <1502428647-28928-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Senozhatsky <sergey.senozhatsky@gmail.com>, Ilya Dryomov <idryomov@gmail.com>

[1] fixed weird thing(i.e., reset BDI_CAP_STABLE_WRITES flag
unconditionally whenever revalidat_disk is called) so zram doesn't
need to reset the flag any more whenever revalidating the bdev.
Instead, set the flag just once when the zram device is created.

It shouldn't change any behavior.

[1] 19b7ccf8651d, block: get rid of blk_integrity_revalidate()
Cc: Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Ilya Dryomov <idryomov@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index e27daca996ed..bbbc2f230b8e 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -122,14 +122,6 @@ static inline bool is_partial_io(struct bio_vec *bvec)
 }
 #endif
 
-static void zram_revalidate_disk(struct zram *zram)
-{
-	revalidate_disk(zram->disk);
-	/* revalidate_disk reset the BDI_CAP_STABLE_WRITES so set again */
-	zram->disk->queue->backing_dev_info->capabilities |=
-		BDI_CAP_STABLE_WRITES;
-}
-
 /*
  * Check if request is within bounds and aligned on zram logical blocks.
  */
@@ -1392,7 +1384,8 @@ static ssize_t disksize_store(struct device *dev,
 	zram->comp = comp;
 	zram->disksize = disksize;
 	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-	zram_revalidate_disk(zram);
+
+	revalidate_disk(zram->disk);
 	up_write(&zram->init_lock);
 
 	return len;
@@ -1439,7 +1432,7 @@ static ssize_t reset_store(struct device *dev,
 	/* Make sure all the pending I/O are finished */
 	fsync_bdev(bdev);
 	zram_reset_device(zram);
-	zram_revalidate_disk(zram);
+	revalidate_disk(zram->disk);
 	bdput(bdev);
 
 	mutex_lock(&bdev->bd_mutex);
@@ -1558,6 +1551,7 @@ static int zram_add(void)
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 	queue_flag_clear_unlocked(QUEUE_FLAG_ADD_RANDOM, zram->disk->queue);
+
 	/*
 	 * To ensure that we always get PAGE_SIZE aligned
 	 * and n*PAGE_SIZED sized I/O requests.
@@ -1582,6 +1576,8 @@ static int zram_add(void)
 	if (ZRAM_LOGICAL_BLOCK_SIZE == PAGE_SIZE)
 		blk_queue_max_write_zeroes_sectors(zram->disk->queue, UINT_MAX);
 
+	zram->disk->queue->backing_dev_info->capabilities |=
+					BDI_CAP_STABLE_WRITES;
 	add_disk(zram->disk);
 
 	ret = sysfs_create_group(&disk_to_dev(zram->disk)->kobj,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
