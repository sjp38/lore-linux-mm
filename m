Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 038746B009B
	for <linux-mm@kvack.org>; Mon,  5 May 2014 11:20:18 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id i4so7876919oah.19
        for <linux-mm@kvack.org>; Mon, 05 May 2014 08:20:18 -0700 (PDT)
Received: from mail-oa0-x236.google.com (mail-oa0-x236.google.com [2607:f8b0:4003:c02::236])
        by mx.google.com with ESMTPS id q5si334160oew.166.2014.05.05.08.20.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 08:20:18 -0700 (PDT)
Received: by mail-oa0-f54.google.com with SMTP id j17so4182458oag.41
        for <linux-mm@kvack.org>; Mon, 05 May 2014 08:20:17 -0700 (PDT)
Date: Mon, 5 May 2014 10:20:14 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
Message-ID: <20140505152014.GA8551@cerebellum.variantweb.net>
References: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, weijie.yang.kh@gmail.com, heesub.shin@samsung.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Mon, May 05, 2014 at 12:01:21PM +0800, Weijie Yang wrote:
> Currently, we use a rwlock tb_lock to protect concurrent access to
> whole zram meta table. However, according to the actual access model,
> there is only a small chance for upper user access the same table[index],
> so the current lock granularity is too big.
> 
> This patch add a atomic state for every table[index] to record its access,
> by using CAS operation, protect concurrent access to the same table[index],
> meanwhile allow the maximum concurrency.
> 
> On 64-bit system, it will not increase the meta table memory overhead, and
> on 32-bit system with 4K page_size, it will increase about 1MB memory overhead
> for 1GB zram. So, it is cost-efficient.
> 
> Test result:
> (x86-64 Intel Core2 Q8400, system memory 4GB, Ubuntu 12.04,
> kernel v3.15.0-rc3, zram 1GB with 4 max_comp_streams LZO,
> take the average of 5 tests)
> 
> iozone -t 4 -R -r 16K -s 200M -I +Z
> 
>       Test          base	   lock-free	ratio
> ------------------------------------------------------
>  Initial write   1348017.60    1424141.62   +5.6%
>        Rewrite   1520189.16    1652504.81   +8.7%
>           Read   8294445.45   11404668.35   +37.5%
>        Re-read   8134448.83   11555483.75   +42.1%
>   Reverse Read   6748717.97    8394478.17   +24.4%
>    Stride read   7220276.66    9372229.95   +29.8%
>    Random read   7133010.06    9187221.90   +28.8%
> Mixed workload   4056980.71    5843370.85   +44.0%
>   Random write   1470106.17    1608947.04   +9.4%
>         Pwrite   1259493.72    1311055.32   +4.1%
>          Pread   4247583.17    4652056.11   +9.5%
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
> 
> This patch is based on linux-next tree, commit b5c8d48bf8f42 
> 
>  drivers/block/zram/zram_drv.c |   41 ++++++++++++++++++++++++++---------------
>  drivers/block/zram/zram_drv.h |    5 ++++-
>  2 files changed, 30 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 48eccb3..8b70945
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -255,7 +255,6 @@ static struct zram_meta *zram_meta_alloc(u64 disksize)
>  		goto free_table;
>  	}
>  
> -	rwlock_init(&meta->tb_lock);
>  	return meta;
>  
>  free_table:
> @@ -339,12 +338,14 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
>  	unsigned long handle;
>  	u16 size;
>  
> -	read_lock(&meta->tb_lock);
> +	while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> +		cpu_relax();
> +

So... this might be dumb question, but this looks like a spinlock
implementation.

What advantage does this have over a standard spinlock?

Seth

>  	handle = meta->table[index].handle;
>  	size = meta->table[index].size;
>  
>  	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
> -		read_unlock(&meta->tb_lock);
> +		atomic_set(&meta->table[index].state, IDLE);
>  		clear_page(mem);
>  		return 0;
>  	}
> @@ -355,7 +356,7 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
>  	else
>  		ret = zcomp_decompress(zram->comp, cmem, size, mem);
>  	zs_unmap_object(meta->mem_pool, handle);
> -	read_unlock(&meta->tb_lock);
> +	atomic_set(&meta->table[index].state, IDLE);
>  
>  	/* Should NEVER happen. Return bio error if it does. */
>  	if (unlikely(ret)) {
> @@ -376,14 +377,16 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
>  	struct zram_meta *meta = zram->meta;
>  	page = bvec->bv_page;
>  
> -	read_lock(&meta->tb_lock);
> +	while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> +		cpu_relax();
> +
>  	if (unlikely(!meta->table[index].handle) ||
>  			zram_test_flag(meta, index, ZRAM_ZERO)) {
> -		read_unlock(&meta->tb_lock);
> +		atomic_set(&meta->table[index].state, IDLE);
>  		handle_zero_page(bvec);
>  		return 0;
>  	}
> -	read_unlock(&meta->tb_lock);
> +	atomic_set(&meta->table[index].state, IDLE);
>  
>  	if (is_partial_io(bvec))
>  		/* Use  a temporary buffer to decompress the page */
> @@ -461,10 +464,13 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	if (page_zero_filled(uncmem)) {
>  		kunmap_atomic(user_mem);
>  		/* Free memory associated with this sector now. */
> -		write_lock(&zram->meta->tb_lock);
> +		while(atomic_cmpxchg(&meta->table[index].state,
> +				IDLE, ACCESS) != IDLE)
> +			cpu_relax();
> +
>  		zram_free_page(zram, index);
>  		zram_set_flag(meta, index, ZRAM_ZERO);
> -		write_unlock(&zram->meta->tb_lock);
> +		atomic_set(&meta->table[index].state, IDLE);
>  
>  		atomic64_inc(&zram->stats.zero_pages);
>  		ret = 0;
> @@ -514,12 +520,13 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	 * Free memory associated with this sector
>  	 * before overwriting unused sectors.
>  	 */
> -	write_lock(&zram->meta->tb_lock);
> +	while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> +		cpu_relax();
>  	zram_free_page(zram, index);
>  
>  	meta->table[index].handle = handle;
>  	meta->table[index].size = clen;
> -	write_unlock(&zram->meta->tb_lock);
> +	atomic_set(&meta->table[index].state, IDLE);
>  
>  	/* Update stats */
>  	atomic64_add(clen, &zram->stats.compr_data_size);
> @@ -560,6 +567,7 @@ static void zram_bio_discard(struct zram *zram, u32 index,
>  			     int offset, struct bio *bio)
>  {
>  	size_t n = bio->bi_iter.bi_size;
> +	struct zram_meta *meta = zram->meta;
>  
>  	/*
>  	 * zram manages data in physical block size units. Because logical block
> @@ -584,9 +592,11 @@ static void zram_bio_discard(struct zram *zram, u32 index,
>  		 * Discard request can be large so the lock hold times could be
>  		 * lengthy.  So take the lock once per page.
>  		 */
> -		write_lock(&zram->meta->tb_lock);
> +		while(atomic_cmpxchg(&meta->table[index].state,
> +				IDLE, ACCESS) != IDLE)
> +			cpu_relax();
>  		zram_free_page(zram, index);
> -		write_unlock(&zram->meta->tb_lock);
> +		atomic_set(&meta->table[index].state, IDLE);
>  		index++;
>  		n -= PAGE_SIZE;
>  	}
> @@ -804,9 +814,10 @@ static void zram_slot_free_notify(struct block_device *bdev,
>  	zram = bdev->bd_disk->private_data;
>  	meta = zram->meta;
>  
> -	write_lock(&meta->tb_lock);
> +	while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> +		cpu_relax();
>  	zram_free_page(zram, index);
> -	write_unlock(&meta->tb_lock);
> +	atomic_set(&meta->table[index].state, IDLE);
>  	atomic64_inc(&zram->stats.notify_free);
>  }
>  
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index 7f21c14..76b2bb5
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -61,9 +61,13 @@ enum zram_pageflags {
>  
>  /*-- Data structures */
>  
> +#define IDLE   0
> +#define ACCESS 1
> +
>  /* Allocated for each disk page */
>  struct table {
>  	unsigned long handle;
> +	atomic_t state;
>  	u16 size;	/* object size (excluding header) */
>  	u8 flags;
>  } __aligned(4);
> @@ -81,7 +85,6 @@ struct zram_stats {
>  };
>  
>  struct zram_meta {
> -	rwlock_t tb_lock;	/* protect table */
>  	struct table *table;
>  	struct zs_pool *mem_pool;
>  };
> -- 
> 1.7.10.4
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
