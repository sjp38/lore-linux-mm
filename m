Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 000656B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 09:50:05 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so71762202pab.6
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 06:50:05 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id qk3si20307220pbc.251.2015.02.01.06.50.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 06:50:04 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so71906120pad.1
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 06:50:04 -0800 (PST)
Date: Sun, 1 Feb 2015 23:50:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150201145036.GA1290@swordfish>
References: <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130144145.GA2840@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

Hello Minchan,

the idea looks good and this is something I was trying to do, except
that I used kref.

some review nitpicks are below. I also posted modified version of your
patch so that will save some time.


>  static inline int init_done(struct zram *zram)
>  {
> -	return zram->meta != NULL;
> +	return zram->disksize != 0;

we don't set ->disksize to 0 when create device. and I think
it's better to use refcount here, but set it to 0 during device creation.
(see the patch below)

> +static inline bool zram_meta_get(struct zram_meta *meta)
> +{
> +	if (!atomic_inc_not_zero(&meta->refcount))
> +		return false;
> +	return true;
> +}

I've changed it to likely case first: `if recount return true'

>  static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  {
> +	struct zram_meta *meta;
> +	u64 disksize;

not needed. (see the patch below).

> +
>  	down_write(&zram->init_lock);
>  
>  	zram->limit_pages = 0;
> @@ -728,14 +750,20 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  		return;
>  	}
>  
> +	meta = zram->meta;
> +
>  	zcomp_destroy(zram->comp);

we can't destoy zcomp before we see IO completion.

>  	zram->max_comp_streams = 1;

we better keep original comp_streams number before we see IO completion.
we don't know how many RW ops we have, so completion can happen earlier.

> -	zram_meta_free(zram->meta, zram->disksize);
> -	zram->meta = NULL;
> +	disksize = zram->disksize;
> +	zram_meta_put(meta);
> +	/* Read/write handler will not handle further I/O operation. */
> +	zram->disksize = 0;

I keep it on its current position. (see below)

> +	wait_for_completion(&meta->complete);
> +	/* I/O operation under all of CPU are done so let's free */
> +	zram_meta_free(zram->meta, disksize);
>  	/* Reset stats */
>  	memset(&zram->stats, 0, sizeof(zram->stats));
>  
> -	zram->disksize = 0;
>  	if (reset_capacity)
>  		set_capacity(zram->disk, 0);
>  
> @@ -908,23 +936,25 @@ static void zram_make_request(struct request_queue *queue, struct bio *bio)
>  {
>  	struct zram *zram = queue->queuedata;
>  
> -	down_read(&zram->init_lock);
> -	if (unlikely(!init_done(zram)))
> +	if (unlikely(!zram_meta_get(zram->meta)))
>  		goto error;
>  
> +	if (unlikely(!init_done(zram)))
> +		goto put_meta;
> +

here and later:
we can't take zram_meta_get() first and then check for init_done(zram),
because ->meta can be NULL, so it fill be ->NULL->refcount.

let's keep ->completion and ->refcount in zram and rename zram_meta_[get|put]
to zram_[get|put].




please review a bit modified version of your patch.

/* the patch also reogranizes a bit order of struct zram members, to move
member that we use more often together and to avoid paddings. nothing
critical here. */


next action items are:
-- we actually can now switch from init_lock in some _show() fucntion to
zram_get()/zram_put()
-- address that theoretical and very unlikely in real live race condition
of umount-reset vs. mount-rw.


no concerns about performance of this version -- we probably will not get
any faster than that.


thanks a lot for your effort!

---

 drivers/block/zram/zram_drv.c | 82 ++++++++++++++++++++++++++++++-------------
 drivers/block/zram/zram_drv.h | 17 ++++-----
 2 files changed, 66 insertions(+), 33 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index aa5a4c5..6916790 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -44,7 +44,7 @@ static const char *default_compressor = "lzo";
 static unsigned int num_devices = 1;
 
 #define ZRAM_ATTR_RO(name)						\
-static ssize_t name##_show(struct device *d,		\
+static ssize_t name##_show(struct device *d,				\
 				struct device_attribute *attr, char *b)	\
 {									\
 	struct zram *zram = dev_to_zram(d);				\
@@ -55,7 +55,7 @@ static DEVICE_ATTR_RO(name);
 
 static inline int init_done(struct zram *zram)
 {
-	return zram->meta != NULL;
+	return atomic_read(&zram->refcount);
 }
 
 static inline struct zram *dev_to_zram(struct device *dev)
@@ -358,6 +358,23 @@ out_error:
 	return NULL;
 }
 
+static inline bool zram_get(struct zram *zram)
+{
+	if (atomic_inc_not_zero(&zram->refcount))
+		return true;
+	return false;
+}
+
+/*
+ * We want to free zram_meta in process context to avoid
+ * deadlock between reclaim path and any other locks
+ */
+static inline void zram_put(struct zram *zram)
+{
+	if (atomic_dec_and_test(&zram->refcount))
+		complete(&zram->io_done);
+}
+
 static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
 {
 	if (*offset + bvec->bv_len >= PAGE_SIZE)
@@ -719,6 +736,9 @@ static void zram_bio_discard(struct zram *zram, u32 index,
 
 static void zram_reset_device(struct zram *zram, bool reset_capacity)
 {
+	struct zram_meta *meta;
+	struct zcomp *comp;
+
 	down_write(&zram->init_lock);
 
 	zram->limit_pages = 0;
@@ -728,14 +748,21 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 		return;
 	}
 
-	zcomp_destroy(zram->comp);
-	zram->max_comp_streams = 1;
-	zram_meta_free(zram->meta, zram->disksize);
-	zram->meta = NULL;
+	meta = zram->meta;
+	comp = zram->comp;
+	/* ->refcount will go down to 0 eventually */
+	zram_put(zram);
+
+	wait_for_completion(&zram->io_done);
+	/* I/O operation under all of CPU are done so let's free */
+	zram_meta_free(meta, disksize);
+	zcomp_destroy(comp);
+
 	/* Reset stats */
 	memset(&zram->stats, 0, sizeof(zram->stats));
-
 	zram->disksize = 0;
+	zram->max_comp_streams = 1;
+
 	if (reset_capacity)
 		set_capacity(zram->disk, 0);
 
@@ -783,6 +810,8 @@ static ssize_t disksize_store(struct device *dev,
 		goto out_destroy_comp;
 	}
 
+	init_completion(&zram->io_done);
+	atomic_set(&zram->refcount, 1);
 	zram->meta = meta;
 	zram->comp = comp;
 	zram->disksize = disksize;
@@ -795,7 +824,6 @@ static ssize_t disksize_store(struct device *dev,
 	 * so that revalidate_disk always sees up-to-date capacity.
 	 */
 	revalidate_disk(zram->disk);
-
 	return len;
 
 out_destroy_comp:
@@ -908,23 +936,24 @@ static void zram_make_request(struct request_queue *queue, struct bio *bio)
 {
 	struct zram *zram = queue->queuedata;
 
-	down_read(&zram->init_lock);
-	if (unlikely(!init_done(zram)))
+	if (unlikely(!zram_get(zram)))
 		goto error;
 
+	if (unlikely(!init_done(zram)))
+		goto put_zram;
+
 	if (!valid_io_request(zram, bio->bi_iter.bi_sector,
 					bio->bi_iter.bi_size)) {
 		atomic64_inc(&zram->stats.invalid_io);
-		goto error;
+		goto put_zram;
 	}
 
 	__zram_make_request(zram, bio);
-	up_read(&zram->init_lock);
-
+	zram_put(zram);
 	return;
-
+put_zram:
+	zram_put(zram);
 error:
-	up_read(&zram->init_lock);
 	bio_io_error(bio);
 }
 
@@ -946,21 +975,22 @@ static void zram_slot_free_notify(struct block_device *bdev,
 static int zram_rw_page(struct block_device *bdev, sector_t sector,
 		       struct page *page, int rw)
 {
-	int offset, err;
+	int offset, err = -EIO;
 	u32 index;
 	struct zram *zram;
 	struct bio_vec bv;
 
 	zram = bdev->bd_disk->private_data;
+	if (unlikely(!zram_get(zram)))
+		goto out;
+
+	if (unlikely(!init_done(zram)))
+		goto put_zram;
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
@@ -971,8 +1001,9 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
 	bv.bv_offset = 0;
 
 	err = zram_bvec_rw(zram, &bv, index, offset, rw);
-out_unlock:
-	up_read(&zram->init_lock);
+put_zram:
+	zram_put(zram);
+out:
 	/*
 	 * If I/O fails, just return error(ie, non-zero) without
 	 * calling page_endio.
@@ -1041,6 +1072,7 @@ static int create_device(struct zram *zram, int device_id)
 	int ret = -ENOMEM;
 
 	init_rwsem(&zram->init_lock);
+	atomic_set(&zram->refcount, 0);
 
 	zram->queue = blk_alloc_queue(GFP_KERNEL);
 	if (!zram->queue) {
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index b05a816..7138c82 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -100,24 +100,25 @@ struct zram_meta {
 
 struct zram {
 	struct zram_meta *meta;
+	struct zcomp *comp;
 	struct request_queue *queue;
 	struct gendisk *disk;
-	struct zcomp *comp;
-
 	/* Prevent concurrent execution of device init, reset and R/W request */
 	struct rw_semaphore init_lock;
 	/*
-	 * This is the limit on amount of *uncompressed* worth of data
-	 * we can store in a disk.
+	 * the number of pages zram can consume for storing compressed data
 	 */
-	u64 disksize;	/* bytes */
+	unsigned long limit_pages;
+	atomic_t refcount;
 	int max_comp_streams;
+
 	struct zram_stats stats;
+	struct completion io_done; /* notify IO under all of cpu are done */
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
