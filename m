Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 994086B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 20:43:25 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so75656111pab.5
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 17:43:25 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id g8si21791464pdk.182.2015.02.01.17.43.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 17:43:24 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so75702434pac.2
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 17:43:24 -0800 (PST)
Date: Mon, 2 Feb 2015 10:43:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202014315.GC6402@blaptop>
References: <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
 <20150201145036.GA1290@swordfish>
 <20150201150416.GB1290@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150201150416.GB1290@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Mon, Feb 02, 2015 at 12:04:16AM +0900, Sergey Senozhatsky wrote:
> Sorry, guys! my bad. the patch I sent to you is incomplete. pelase review
> this one.
> 
> On (02/01/15 23:50), Sergey Senozhatsky wrote:
> > +	zram_meta_free(meta, disksize);
> > 
> that was my in-mail last second stupid modification and I didn't compile
> tested it. I hit send button and then realized that your patch didn't move
> ->meta and ->comp free out of ->init_lock.
> 
> So this patch does it.
> 
> thanks.
> 
> ---
> 
>  drivers/block/zram/zram_drv.c | 84 +++++++++++++++++++++++++++++--------------
>  drivers/block/zram/zram_drv.h | 17 ++++-----
>  2 files changed, 67 insertions(+), 34 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index aa5a4c5..c0b612d 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -44,7 +44,7 @@ static const char *default_compressor = "lzo";
>  static unsigned int num_devices = 1;
>  
>  #define ZRAM_ATTR_RO(name)						\
> -static ssize_t name##_show(struct device *d,		\
> +static ssize_t name##_show(struct device *d,				\
>  				struct device_attribute *attr, char *b)	\
>  {									\
>  	struct zram *zram = dev_to_zram(d);				\
> @@ -55,7 +55,7 @@ static DEVICE_ATTR_RO(name);
>  
>  static inline int init_done(struct zram *zram)
>  {
> -	return zram->meta != NULL;
> +	return atomic_read(&zram->refcount);

As I said previous mail, it could make livelock so I want to use disksize
in here to prevent further I/O handling.

>  }
>  
>  static inline struct zram *dev_to_zram(struct device *dev)
> @@ -358,6 +358,23 @@ out_error:
>  	return NULL;
>  }
>  
> +static inline bool zram_get(struct zram *zram)
> +{
> +	if (atomic_inc_not_zero(&zram->refcount))
> +		return true;
> +	return false;
> +}
> +
> +/*
> + * We want to free zram_meta in process context to avoid
> + * deadlock between reclaim path and any other locks
> + */
> +static inline void zram_put(struct zram *zram)
> +{
> +	if (atomic_dec_and_test(&zram->refcount))
> +		complete(&zram->io_done);
> +}

Although I suggested this complete, it might be rather overkill(pz,
understand me it was work in midnight. :))
Instead, we could use just atomic_dec in here and
use wait_event(event, atomic_read(&zram->refcount) == 0) in reset.

Otherwise, looks good to me. I will cook up based on this version
and test/send if you don't have any strong objection until that.

Thanks for the review, Sergey!

> +
>  static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
>  {
>  	if (*offset + bvec->bv_len >= PAGE_SIZE)
> @@ -719,6 +736,10 @@ static void zram_bio_discard(struct zram *zram, u32 index,
>  
>  static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  {
> +	struct zram_meta *meta;
> +	struct zcomp *comp;
> +	u64 disksize;
> +
>  	down_write(&zram->init_lock);
>  
>  	zram->limit_pages = 0;
> @@ -728,19 +749,25 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  		return;
>  	}
>  
> -	zcomp_destroy(zram->comp);
> -	zram->max_comp_streams = 1;
> -	zram_meta_free(zram->meta, zram->disksize);
> -	zram->meta = NULL;
> +	meta = zram->meta;
> +	comp = zram->comp;
> +	disksize = zram->disksize;
> +	/* ->refcount will go down to 0 eventually */
> +	zram_put(zram);
> +	wait_for_completion(&zram->io_done);
> +
>  	/* Reset stats */
>  	memset(&zram->stats, 0, sizeof(zram->stats));
> -
>  	zram->disksize = 0;
> +	zram->max_comp_streams = 1;
> +
>  	if (reset_capacity)
>  		set_capacity(zram->disk, 0);
>  
>  	up_write(&zram->init_lock);
> -
> +	/* I/O operation under all of CPU are done so let's free */
> +	zram_meta_free(meta, disksize);
> +	zcomp_destroy(comp);
>  	/*
>  	 * Revalidate disk out of the init_lock to avoid lockdep splat.
>  	 * It's okay because disk's capacity is protected by init_lock
> @@ -783,6 +810,8 @@ static ssize_t disksize_store(struct device *dev,
>  		goto out_destroy_comp;
>  	}
>  
> +	init_completion(&zram->io_done);
> +	atomic_set(&zram->refcount, 1);
>  	zram->meta = meta;
>  	zram->comp = comp;
>  	zram->disksize = disksize;
> @@ -795,7 +824,6 @@ static ssize_t disksize_store(struct device *dev,
>  	 * so that revalidate_disk always sees up-to-date capacity.
>  	 */
>  	revalidate_disk(zram->disk);
> -
>  	return len;
>  
>  out_destroy_comp:
> @@ -908,23 +936,24 @@ static void zram_make_request(struct request_queue *queue, struct bio *bio)
>  {
>  	struct zram *zram = queue->queuedata;
>  
> -	down_read(&zram->init_lock);
> -	if (unlikely(!init_done(zram)))
> +	if (unlikely(!zram_get(zram)))
>  		goto error;
>  
> +	if (unlikely(!init_done(zram)))
> +		goto put_zram;
> +
>  	if (!valid_io_request(zram, bio->bi_iter.bi_sector,
>  					bio->bi_iter.bi_size)) {
>  		atomic64_inc(&zram->stats.invalid_io);
> -		goto error;
> +		goto put_zram;
>  	}
>  
>  	__zram_make_request(zram, bio);
> -	up_read(&zram->init_lock);
> -
> +	zram_put(zram);
>  	return;
> -
> +put_zram:
> +	zram_put(zram);
>  error:
> -	up_read(&zram->init_lock);
>  	bio_io_error(bio);
>  }
>  
> @@ -946,21 +975,22 @@ static void zram_slot_free_notify(struct block_device *bdev,
>  static int zram_rw_page(struct block_device *bdev, sector_t sector,
>  		       struct page *page, int rw)
>  {
> -	int offset, err;
> +	int offset, err = -EIO;
>  	u32 index;
>  	struct zram *zram;
>  	struct bio_vec bv;
>  
>  	zram = bdev->bd_disk->private_data;
> +	if (unlikely(!zram_get(zram)))
> +		goto out;
> +
> +	if (unlikely(!init_done(zram)))
> +		goto put_zram;
> +
>  	if (!valid_io_request(zram, sector, PAGE_SIZE)) {
>  		atomic64_inc(&zram->stats.invalid_io);
> -		return -EINVAL;
> -	}
> -
> -	down_read(&zram->init_lock);
> -	if (unlikely(!init_done(zram))) {
> -		err = -EIO;
> -		goto out_unlock;
> +		err = -EINVAL;
> +		goto put_zram;
>  	}
>  
>  	index = sector >> SECTORS_PER_PAGE_SHIFT;
> @@ -971,8 +1001,9 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
>  	bv.bv_offset = 0;
>  
>  	err = zram_bvec_rw(zram, &bv, index, offset, rw);
> -out_unlock:
> -	up_read(&zram->init_lock);
> +put_zram:
> +	zram_put(zram);
> +out:
>  	/*
>  	 * If I/O fails, just return error(ie, non-zero) without
>  	 * calling page_endio.
> @@ -1041,6 +1072,7 @@ static int create_device(struct zram *zram, int device_id)
>  	int ret = -ENOMEM;
>  
>  	init_rwsem(&zram->init_lock);
> +	atomic_set(&zram->refcount, 0);
>  
>  	zram->queue = blk_alloc_queue(GFP_KERNEL);
>  	if (!zram->queue) {
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index b05a816..7138c82 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -100,24 +100,25 @@ struct zram_meta {
>  
>  struct zram {
>  	struct zram_meta *meta;
> +	struct zcomp *comp;
>  	struct request_queue *queue;
>  	struct gendisk *disk;
> -	struct zcomp *comp;
> -
>  	/* Prevent concurrent execution of device init, reset and R/W request */
>  	struct rw_semaphore init_lock;
>  	/*
> -	 * This is the limit on amount of *uncompressed* worth of data
> -	 * we can store in a disk.
> +	 * the number of pages zram can consume for storing compressed data
>  	 */
> -	u64 disksize;	/* bytes */
> +	unsigned long limit_pages;
> +	atomic_t refcount;
>  	int max_comp_streams;
> +
>  	struct zram_stats stats;
> +	struct completion io_done; /* notify IO under all of cpu are done */
>  	/*
> -	 * the number of pages zram can consume for storing compressed data
> +	 * This is the limit on amount of *uncompressed* worth of data
> +	 * we can store in a disk.
>  	 */
> -	unsigned long limit_pages;
> -
> +	u64 disksize;	/* bytes */
>  	char compressor[10];
>  };
>  #endif
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
