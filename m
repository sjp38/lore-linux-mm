Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 05F766B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 00:10:28 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so77513875pab.11
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 21:10:27 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ra16si22248039pac.161.2015.02.01.21.10.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 21:10:27 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id et14so77620472pad.4
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 21:10:26 -0800 (PST)
Date: Mon, 2 Feb 2015 14:10:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202051017.GH6402@blaptop>
References: <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
 <20150201145036.GA1290@swordfish>
 <20150202013028.GB6402@blaptop>
 <20150202014800.GA6977@swordfish>
 <20150202024405.GD6402@blaptop>
 <20150202040124.GE6977@swordfish>
 <20150202042847.GG6402@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202042847.GG6402@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Mon, Feb 02, 2015 at 01:28:47PM +0900, Minchan Kim wrote:
> On Mon, Feb 02, 2015 at 01:01:24PM +0900, Sergey Senozhatsky wrote:
> > On (02/02/15 11:44), Minchan Kim wrote:
> > > > sure, I did think about this. and I actually didn't find any reason not
> > > > to use ->refcount there. if user wants to reset the device, he first
> > > > should umount it to make bdev->bd_holders check happy. and that's where
> > > > IOs will be failed. so it makes sense to switch to ->refcount there, IMHO.
> > > 
> > > If we use zram as block device itself(not a fs or swap) and open the
> > > block device as !FMODE_EXCL, bd_holders will be void.
> > > 
> > 
> > hm.
> > I don't mind to use ->disksize there, but personally I'd maybe prefer
> > to use ->refcount, which just looks less hacky. zram's most common use
> > cases are coming from ram swap device or ram device with fs. so it looks
> > a bit like we care about some corner case here.
> 
> Maybe, but I always test zram with dd so it's not a corner case for me. :)
> 
> > 
> > just my opinion, no objections against ->disksize != 0.
> 
> Thanks. It's a draft for v2. Please review.
> 
> BTW, you pointed out race between bdev_open/close and reset and
> it's cleary bug although it's rare in real practice.
> So, I want to fix it earlier than this patch and mark it as -stable
> if we can fix it easily like Ganesh's work.
> If it gets landing, we could make this patch rebased on it.
> 
> From 699502b4e0c84b3d7b33f8754cf1c0109b16c012 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 2 Feb 2015 10:36:28 +0900
> Subject: [PATCH v2] zram: remove init_lock in zram_make_request
> 
> Admin could reset zram during I/O operation going on so we have
> used zram->init_lock as read-side lock in I/O path to prevent
> sudden zram meta freeing.
> 
> However, the init_lock is really troublesome.
> We can't do call zram_meta_alloc under init_lock due to lockdep splat
> because zram_rw_page is one of the function under reclaim path and
> hold it as read_lock while other places in process context hold it
> as write_lock. So, we have used allocation out of the lock to avoid
> lockdep warn but it's not good for readability and fainally, I met
> another lockdep splat between init_lock and cpu_hotplug from
> kmem_cache_destroy during working zsmalloc compaction. :(
> 
> Yes, the ideal is to remove horrible init_lock of zram in rw path.
> This patch removes it in rw path and instead, add atomic refcount
> for meta lifetime management and completion to free meta in process
> context. It's important to free meta in process context because
> some of resource destruction needs mutex lock, which could be held
> if we releases the resource in reclaim context so it's deadlock,
> again.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/block/zram/zram_drv.c | 85 ++++++++++++++++++++++++++++++-------------
>  drivers/block/zram/zram_drv.h | 20 +++++-----
>  2 files changed, 71 insertions(+), 34 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index aa5a4c5..c6d505c 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -55,7 +55,7 @@ static DEVICE_ATTR_RO(name);
>  
>  static inline int init_done(struct zram *zram)
>  {
> -	return zram->meta != NULL;
> +	return zram->disksize != 0;
>  }
>  
>  static inline struct zram *dev_to_zram(struct device *dev)
> @@ -358,6 +358,18 @@ out_error:
>  	return NULL;
>  }
>  
> +static inline bool zram_meta_get(struct zram *zram)
> +{
> +	if (atomic_inc_not_zero(&zram->refcount))
> +		return true;
> +	return false;
> +}
> +
> +static inline void zram_meta_put(struct zram *zram)
> +{
> +	atomic_dec(&zram->refcount);
> +}
> +
>  static void update_position(u32 *index, int *offset, struct bio_vec *bvec)
>  {
>  	if (*offset + bvec->bv_len >= PAGE_SIZE)
> @@ -719,6 +731,10 @@ static void zram_bio_discard(struct zram *zram, u32 index,
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
> @@ -728,19 +744,32 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
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
> +	zram->disksize = 0;
> +	/*
> +	 * ->refcount will go down to 0 eventually and rw handler cannot
> +	 * handle further I/O by init_done checking.
> +	 */
> +	zram_meta_put(zram);
> +	/*
> +	 * We want to free zram_meta in process context to avoid
> +	 * deadlock between reclaim path and any other locks
> +	 */
> +	wait_event(zram->io_done, atomic_read(&zram->refcount) == 0);
> +
>  	/* Reset stats */
>  	memset(&zram->stats, 0, sizeof(zram->stats));
> +	zram->max_comp_streams = 1;
>  
> -	zram->disksize = 0;
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
> @@ -783,6 +812,8 @@ static ssize_t disksize_store(struct device *dev,
>  		goto out_destroy_comp;
>  	}
>  
> +	init_waitqueue_head(&zram->io_done);
> +	zram_meta_get(zram);
        
Argh, It should be

        atomic_set(&zram->refcount, 1);

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
