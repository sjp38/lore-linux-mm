Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BD5E06B0071
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 23:01:52 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so105087033pad.7
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 20:01:52 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id jx10si625648pbc.99.2015.02.03.20.01.50
        for <linux-mm@kvack.org>;
        Tue, 03 Feb 2015 20:01:51 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2] zram: remove init_lock in zram_make_request
Date: Wed,  4 Feb 2015 13:01:46 +0900
Message-Id: <1423022506-29979-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>

Admin could reset zram during I/O operation going on so we have
used zram->init_lock as read-side lock in I/O path to prevent
sudden zram meta freeing.

However, the init_lock is really troublesome.
We can't do call zram_meta_alloc under init_lock due to lockdep splat
because zram_rw_page is one of the function under reclaim path and
hold it as read_lock while other places in process context hold it
as write_lock. So, we have used allocation out of the lock to avoid
lockdep warn but it's not good for readability and fainally, I met
another lockdep splat between init_lock and cpu_hotplug from
kmem_cache_destroy during working zsmalloc compaction. :(

Yes, the ideal is to remove horrible init_lock of zram in rw path.
This patch removes it in rw path and instead, add atomic refcount
for meta lifetime management and completion to free meta in process
context. It's important to free meta in process context because
some of resource destruction needs mutex lock, which could be held
if we releases the resource in reclaim context so it's deadlock,
again.

As a bonus, we could remove init_done check in rw path because
zram_meta_get will do a role for it, instead.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 76 ++++++++++++++++++++++++++++++-------------
 drivers/block/zram/zram_drv.h | 20 +++++++-----
 2 files changed, 64 insertions(+), 32 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index f8376d685666..a4002ee1dabd 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -53,9 +53,9 @@ static ssize_t name##_show(struct device *d,		\
 }									\
 static DEVICE_ATTR_RO(name);
 
-static inline int init_done(struct zram *zram)
+static inline bool init_done(struct zram *zram)
 {
-	return zram->meta != NULL;
+	return zram->disksize;
 }
 
 static inline struct zram *dev_to_zram(struct device *dev)
@@ -358,6 +358,18 @@ out_error:
 	return NULL;
 }
 
+static inline bool zram_meta_get(struct zram *zram)
+{
+	if (atomic_inc_not_zero(&zram->refcount))
+		return true;
+	return false;
+}
+
+static inline void zram_meta_put(struct zram *zram)
+{
+	atomic_dec(&zram->refcount);
+}
+
 static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
 {
 	if (*offset + bvec->bv_len >= PAGE_SIZE)
@@ -719,6 +731,10 @@ static void zram_bio_discard(struct zram *zram, u32 index,
 
 static void zram_reset_device(struct zram *zram)
 {
+	struct zram_meta *meta;
+	struct zcomp *comp;
+	u64 disksize;
+
 	down_write(&zram->init_lock);
 
 	zram->limit_pages = 0;
@@ -728,16 +744,31 @@ static void zram_reset_device(struct zram *zram)
 		return;
 	}
 
-	zcomp_destroy(zram->comp);
-	zram->max_comp_streams = 1;
-	zram_meta_free(zram->meta, zram->disksize);
-	zram->meta = NULL;
+	meta = zram->meta;
+	comp = zram->comp;
+	disksize = zram->disksize;
+	/*
+	 * Refcount will go down to 0 eventually and r/w handler
+	 * cannot handle further I/O so it will bail out by
+	 * check zram_meta_get.
+	 */
+	zram_meta_put(zram);
+	/*
+	 * We want to free zram_meta in process context to avoid
+	 * deadlock between reclaim path and any other locks.
+	 */
+	wait_event(zram->io_done, atomic_read(&zram->refcount) == 0);
+
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
 	zram->disksize = 0;
+	zram->max_comp_streams = 1;
 	set_capacity(zram->disk, 0);
 
 	up_write(&zram->init_lock);
+	/* I/O operation under all of CPU are done so let's free */
+	zram_meta_free(meta, disksize);
+	zcomp_destroy(comp);
 }
 
 static ssize_t disksize_store(struct device *dev,
@@ -773,6 +804,8 @@ static ssize_t disksize_store(struct device *dev,
 		goto out_destroy_comp;
 	}
 
+	init_waitqueue_head(&zram->io_done);
+	atomic_set(&zram->refcount, 1);
 	zram->meta = meta;
 	zram->comp = comp;
 	zram->disksize = disksize;
@@ -903,23 +936,21 @@ static void zram_make_request(struct request_queue *queue, struct bio *bio)
 {
 	struct zram *zram = queue->queuedata;
 
-	down_read(&zram->init_lock);
-	if (unlikely(!init_done(zram)))
+	if (unlikely(!zram_meta_get(zram)))
 		goto error;
 
 	if (!valid_io_request(zram, bio->bi_iter.bi_sector,
 					bio->bi_iter.bi_size)) {
 		atomic64_inc(&zram->stats.invalid_io);
-		goto error;
+		goto put_zram;
 	}
 
 	__zram_make_request(zram, bio);
-	up_read(&zram->init_lock);
-
+	zram_meta_put(zram);
 	return;
-
+put_zram:
+	zram_meta_put(zram);
 error:
-	up_read(&zram->init_lock);
 	bio_io_error(bio);
 }
 
@@ -941,21 +972,19 @@ static void zram_slot_free_notify(struct block_device *bdev,
 static int zram_rw_page(struct block_device *bdev, sector_t sector,
 		       struct page *page, int rw)
 {
-	int offset, err;
+	int offset, err = -EIO;
 	u32 index;
 	struct zram *zram;
 	struct bio_vec bv;
 
 	zram = bdev->bd_disk->private_data;
+	if (unlikely(!zram_meta_get(zram)))
+		goto out;
+
 	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
 		atomic64_inc(&zram->stats.invalid_io);
-		return -EINVAL;
-	}
-
-	down_read(&zram->init_lock);
-	if (unlikely(!init_done(zram))) {
-		err = -EIO;
-		goto out_unlock;
+		err = -EINVAL;
+		goto put_zram;
 	}
 
 	index = sector >> SECTORS_PER_PAGE_SHIFT;
@@ -966,8 +995,9 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
 	bv.bv_offset = 0;
 
 	err = zram_bvec_rw(zram, &bv, index, offset, rw);
-out_unlock:
-	up_read(&zram->init_lock);
+put_zram:
+	zram_meta_put(zram);
+out:
 	/*
 	 * If I/O fails, just return error(ie, non-zero) without
 	 * calling page_endio.
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index b05a816b09ac..5249f51ccdb3 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -100,24 +100,26 @@ struct zram_meta {
 
 struct zram {
 	struct zram_meta *meta;
+	struct zcomp *comp;
 	struct request_queue *queue;
 	struct gendisk *disk;
-	struct zcomp *comp;
-
-	/* Prevent concurrent execution of device init, reset and R/W request */
+	/* Prevent concurrent execution of device init */
 	struct rw_semaphore init_lock;
 	/*
-	 * This is the limit on amount of *uncompressed* worth of data
-	 * we can store in a disk.
+	 * the number of pages zram can consume for storing compressed data
 	 */
-	u64 disksize;	/* bytes */
+	unsigned long limit_pages;
 	int max_comp_streams;
+
 	struct zram_stats stats;
+	atomic_t refcount; /* refcount for zram_meta */
+	/* wait all IO under all of cpu are done */
+	wait_queue_head_t io_done;
 	/*
-	 * the number of pages zram can consume for storing compressed data
+	 * This is the limit on amount of *uncompressed* worth of data
+	 * we can store in a disk.
 	 */
-	unsigned long limit_pages;
-
+	u64 disksize;	/* bytes */
 	char compressor[10];
 };
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
