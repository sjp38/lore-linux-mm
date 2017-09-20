Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E11D6B025E
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 01:43:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so3529862pga.6
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 22:43:35 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x66si605148pfa.50.2017.09.19.22.43.33
        for <linux-mm@kvack.org>;
        Tue, 19 Sep 2017 22:43:33 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/4] zram: set BDI_CAP_STABLE_WRITES once
Date: Wed, 20 Sep 2017 14:43:22 +0900
Message-Id: <1505886205-9671-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1505886205-9671-1-git-send-email-minchan@kernel.org>
References: <1505886205-9671-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Minchan Kim <minchan@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

[1] fixed weird thing(i.e., reset BDI_CAP_STABLE_WRITES flag
unconditionally whenever revalidat_disk is called) so zram doesn't
need to reset the flag any more whenever revalidating the bdev.
Instead, set the flag just once when the zram device is created.

It shouldn't change any behavior.

[1] 19b7ccf8651d, block: get rid of blk_integrity_revalidate()
Cc: Ilya Dryomov <idryomov@gmail.com>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index cc78f61e22d1..98ef1a8389b0 100644
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
@@ -1371,7 +1363,8 @@ static ssize_t disksize_store(struct device *dev,
 	zram->comp = comp;
 	zram->disksize = disksize;
 	set_capacity(zram->disk, zram->disksize >> SECTOR_SHIFT);
-	zram_revalidate_disk(zram);
+
+	revalidate_disk(zram->disk);
 	up_write(&zram->init_lock);
 
 	return len;
@@ -1418,7 +1411,7 @@ static ssize_t reset_store(struct device *dev,
 	/* Make sure all the pending I/O are finished */
 	fsync_bdev(bdev);
 	zram_reset_device(zram);
-	zram_revalidate_disk(zram);
+	revalidate_disk(zram->disk);
 	bdput(bdev);
 
 	mutex_lock(&bdev->bd_mutex);
@@ -1537,6 +1530,7 @@ static int zram_add(void)
 	/* zram devices sort of resembles non-rotational disks */
 	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, zram->disk->queue);
 	queue_flag_clear_unlocked(QUEUE_FLAG_ADD_RANDOM, zram->disk->queue);
+
 	/*
 	 * To ensure that we always get PAGE_SIZE aligned
 	 * and n*PAGE_SIZED sized I/O requests.
@@ -1561,6 +1555,8 @@ static int zram_add(void)
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
