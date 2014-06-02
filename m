Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8375E6B0031
	for <linux-mm@kvack.org>; Sun,  1 Jun 2014 20:42:57 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lj1so3617122pab.31
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 17:42:57 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xm4si13998589pbc.45.2014.06.01.17.42.53
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 17:42:56 -0700 (PDT)
Date: Mon, 2 Jun 2014 09:43:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] zram: remove global tb_lock with fine grain lock
Message-ID: <20140602004338.GA26372@bbox>
References: <000001cf7be2$385f9fd0$a91edf70$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cf7be2$385f9fd0$a91edf70$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Heesub Shin' <heesub.shin@samsung.com>, 'Davidlohr Bueso' <davidlohr@hp.com>, 'Joonsoo Kim' <js1304@gmail.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

Hello Weijie,

Thanks for resending.
Below are mostly nitpicks.

On Fri, May 30, 2014 at 04:34:44PM +0800, Weijie Yang wrote:
> Currently, we use a rwlock tb_lock to protect concurrent access to
> the whole zram meta table. However, according to the actual access model,
> there is only a small chance for upper user to access the same table[index],
> so the current lock granularity is too big.
> 
> The idea of optimization is to change the lock granularity from whole
> meta table to per table entry (table -> table[index]), so that we can
> protect concurrent access to the same table[index], meanwhile allow
> the maximum concurrency.
> With this in mind, several kinds of locks which could be used as a
> per-entry lock were tested and compared:
> 
> Test environment:
> x86-64 Intel Core2 Q8400, system memory 4GB, Ubuntu 12.04,
> kernel v3.15.0-rc3 as base, zram with 4 max_comp_streams LZO.
> 
> iozone test:
> iozone -t 4 -R -r 16K -s 200M -I +Z
> (1GB zram with ext4 filesystem, take the average of 10 tests, KB/s)
> 
>       Test       base      CAS    spinlock    rwlock   bit_spinlock
> -------------------------------------------------------------------
>  Initial write  1381094   1425435   1422860   1423075   1421521
>        Rewrite  1529479   1641199   1668762   1672855   1654910
>           Read  8468009  11324979  11305569  11117273  10997202
>        Re-read  8467476  11260914  11248059  11145336  10906486
>   Reverse Read  6821393   8106334   8282174   8279195   8109186
>    Stride read  7191093   8994306   9153982   8961224   9004434
>    Random read  7156353   8957932   9167098   8980465   8940476
> Mixed workload  4172747   5680814   5927825   5489578   5972253
>   Random write  1483044   1605588   1594329   1600453   1596010
>         Pwrite  1276644   1303108   1311612   1314228   1300960
>          Pread  4324337   4632869   4618386   4457870   4500166
> 
> To enhance the possibility of access the same table[index] concurrently,
> set zram a small disksize(10MB) and let threads run with large loop count.
> 
> fio test:
> fio --bs=32k --randrepeat=1 --randseed=100 --refill_buffers
> --scramble_buffers=1 --direct=1 --loops=3000 --numjobs=4
> --filename=/dev/zram0 --name=seq-write --rw=write --stonewall
> --name=seq-read --rw=read --stonewall --name=seq-readwrite
> --rw=rw --stonewall --name=rand-readwrite --rw=randrw --stonewall
> (10MB zram raw block device, take the average of 10 tests, KB/s)
> 
>     Test     base     CAS    spinlock    rwlock  bit_spinlock
> -------------------------------------------------------------
> seq-write   933789   999357   1003298    995961   1001958
>  seq-read  5634130  6577930   6380861   6243912   6230006
>    seq-rw  1405687  1638117   1640256   1633903   1634459
>   rand-rw  1386119  1614664   1617211   1609267   1612471
> 
> All the optimization methods show a higher performance than the base,
> however, it is hard to say which method is the most appropriate.
> 
> On the other hand, zram is mostly used on small embedded system, so we
> don't want to increase any memory footprint.
> 
> This patch pick the bit_spinlock method, pack object size and page_flag
> into an unsigned long table.value, so as to not increase any memory
> overhead on both 32-bit and 64-bit system.
> 
> On the third hand, even though different kinds of locks have different
> performances, we can ignore this difference, because:
> if zram is used as zram swapfile, the swap subsystem can prevent concurrent
> access to the same swapslot;
> if zram is used as zram-blk for set up filesystem on it, the upper filesystem
> and the page cache also prevent concurrent access of the same block mostly.
> So we can ignore the different performances among locks.

Nice description. :)

> 
> Changes since v1: https://lkml.org/lkml/2014/5/5/1
>   - replace CAS method with bit_spinlock method
>   - rename zram_test_flag() to zram_test_zero()
>   - add some comments
> 
> Changes since v2: https://lkml.org/lkml/2014/5/15/113
>   - change size type from int to size_t in zram_set_obj_size()
>   - refactor zram_set_obj_size() to make it readable
>   - add comments
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>  drivers/block/zram/zram_drv.c |   89 ++++++++++++++++++++++++-----------------
>  drivers/block/zram/zram_drv.h |   22 +++++++---
>  2 files changed, 68 insertions(+), 43 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 9849b52..166e882 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -179,23 +179,32 @@ static ssize_t comp_algorithm_store(struct device *dev,
>  	return len;
>  }
>  
> -/* flag operations needs meta->tb_lock */
> -static int zram_test_flag(struct zram_meta *meta, u32 index,
> -			enum zram_pageflags flag)
> +static int zram_test_zero(struct zram_meta *meta, u32 index)

Why do you want to create specific function for zero?
It would be one of usecase for various potential flags.
Do you want to create new functions whenever we define new flag?
Or something do you have a mind?


>  {
> -	return meta->table[index].flags & BIT(flag);
> +	return meta->table[index].value & BIT(ZRAM_ZERO);
>  }
>  
> -static void zram_set_flag(struct zram_meta *meta, u32 index,
> -			enum zram_pageflags flag)
> +static void zram_set_zero(struct zram_meta *meta, u32 index)
>  {
> -	meta->table[index].flags |= BIT(flag);
> +	meta->table[index].value |= BIT(ZRAM_ZERO);
>  }
>  
> -static void zram_clear_flag(struct zram_meta *meta, u32 index,
> -			enum zram_pageflags flag)
> +static void zram_clear_zero(struct zram_meta *meta, u32 index)
>  {
> -	meta->table[index].flags &= ~BIT(flag);
> +	meta->table[index].value &= ~BIT(ZRAM_ZERO);
> +}
> +
> +static size_t zram_get_obj_size(struct zram_meta *meta, u32 index)
> +{
> +	return meta->table[index].value & (BIT(ZRAM_FLAG_SHIFT) - 1);
> +}
> +
> +static void zram_set_obj_size(struct zram_meta *meta,
> +					u32 index, size_t size)
> +{
> +	unsigned long flags = meta->table[index].value >> ZRAM_FLAG_SHIFT;
> +
> +	meta->table[index].value = (flags << ZRAM_FLAG_SHIFT) | size;
>  }
>  
>  static inline int is_partial_io(struct bio_vec *bvec)
> @@ -255,7 +264,6 @@ static struct zram_meta *zram_meta_alloc(u64 disksize)
>  		goto free_table;
>  	}
>  
> -	rwlock_init(&meta->tb_lock);
>  	return meta;
>  
>  free_table:
> @@ -304,19 +312,24 @@ static void handle_zero_page(struct bio_vec *bvec)
>  	flush_dcache_page(page);
>  }
>  
> -/* NOTE: caller should hold meta->tb_lock with write-side */
> +/*
> + * To protect concurrent access to the same index entry,
> + * caller should hold this table index entry's bit_spinlock to
> + * indicate this index entry is accessing.
> + */
>  static void zram_free_page(struct zram *zram, size_t index)
>  {
>  	struct zram_meta *meta = zram->meta;
>  	unsigned long handle = meta->table[index].handle;
> +	size_t size;
>  
>  	if (unlikely(!handle)) {
>  		/*
>  		 * No memory is allocated for zero filled pages.
>  		 * Simply clear zero page flag.
>  		 */
> -		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
> -			zram_clear_flag(meta, index, ZRAM_ZERO);
> +		if (zram_test_zero(meta, index)) {
> +			zram_clear_zero(meta, index);
>  			atomic64_dec(&zram->stats.zero_pages);
>  		}
>  		return;
> @@ -324,27 +337,28 @@ static void zram_free_page(struct zram *zram, size_t index)
>  
>  	zs_free(meta->mem_pool, handle);
>  
> -	atomic64_sub(meta->table[index].size, &zram->stats.compr_data_size);
> +	size = zram_get_obj_size(meta, index);
> +	atomic64_sub(size, &zram->stats.compr_data_size);
>  	atomic64_dec(&zram->stats.pages_stored);
>  
>  	meta->table[index].handle = 0;
> -	meta->table[index].size = 0;
> +	zram_set_obj_size(meta, index, 0);
>  }
>  
>  static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
>  {
> -	int ret = 0;

Unnecessary change.

>  	unsigned char *cmem;
>  	struct zram_meta *meta = zram->meta;
>  	unsigned long handle;
> -	u16 size;

I'm not sure it's good idea to use size_t instead of u16 because we apparently
have a limitation to express range of size due to packing it into unsigned long
so u16 is more clear to show the limiation and someone might find a problem
more easily in future if we break something subtle.

> +	size_t size;
> +	int ret = 0;
>  
> -	read_lock(&meta->tb_lock);
> +	bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  	handle = meta->table[index].handle;
> -	size = meta->table[index].size;
> +	size = zram_get_obj_size(meta, index);
>  
> -	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
> -		read_unlock(&meta->tb_lock);
> +	if (!handle || zram_test_zero(meta, index)) {
> +		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  		clear_page(mem);
>  		return 0;
>  	}
> @@ -355,7 +369,7 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
>  	else
>  		ret = zcomp_decompress(zram->comp, cmem, size, mem);
>  	zs_unmap_object(meta->mem_pool, handle);
> -	read_unlock(&meta->tb_lock);
> +	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  
>  	/* Should NEVER happen. Return bio error if it does. */
>  	if (unlikely(ret)) {
> @@ -376,14 +390,14 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
>  	struct zram_meta *meta = zram->meta;
>  	page = bvec->bv_page;
>  
> -	read_lock(&meta->tb_lock);
> +	bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  	if (unlikely(!meta->table[index].handle) ||
> -			zram_test_flag(meta, index, ZRAM_ZERO)) {
> -		read_unlock(&meta->tb_lock);
> +			zram_test_zero(meta, index)) {
> +		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  		handle_zero_page(bvec);
>  		return 0;
>  	}
> -	read_unlock(&meta->tb_lock);
> +	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  
>  	if (is_partial_io(bvec))
>  		/* Use  a temporary buffer to decompress the page */
> @@ -461,10 +475,10 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	if (page_zero_filled(uncmem)) {
>  		kunmap_atomic(user_mem);
>  		/* Free memory associated with this sector now. */
> -		write_lock(&zram->meta->tb_lock);
> +		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  		zram_free_page(zram, index);
> -		zram_set_flag(meta, index, ZRAM_ZERO);
> -		write_unlock(&zram->meta->tb_lock);
> +		zram_set_zero(meta, index);
> +		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  
>  		atomic64_inc(&zram->stats.zero_pages);
>  		ret = 0;
> @@ -514,12 +528,12 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	 * Free memory associated with this sector
>  	 * before overwriting unused sectors.
>  	 */
> -	write_lock(&zram->meta->tb_lock);
> +	bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  	zram_free_page(zram, index);
>  
>  	meta->table[index].handle = handle;
> -	meta->table[index].size = clen;
> -	write_unlock(&zram->meta->tb_lock);
> +	zram_set_obj_size(meta, index, clen);
> +	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  
>  	/* Update stats */
>  	atomic64_add(clen, &zram->stats.compr_data_size);
> @@ -560,6 +574,7 @@ static void zram_bio_discard(struct zram *zram, u32 index,
>  			     int offset, struct bio *bio)
>  {
>  	size_t n = bio->bi_iter.bi_size;
> +	struct zram_meta *meta = zram->meta;
>  
>  	/*
>  	 * zram manages data in physical block size units. Because logical block
> @@ -584,9 +599,9 @@ static void zram_bio_discard(struct zram *zram, u32 index,
>  		 * Discard request can be large so the lock hold times could be
>  		 * lengthy.  So take the lock once per page.
>  		 */
> -		write_lock(&zram->meta->tb_lock);
> +		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  		zram_free_page(zram, index);
> -		write_unlock(&zram->meta->tb_lock);
> +		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  		index++;
>  		n -= PAGE_SIZE;
>  	}
> @@ -804,9 +819,9 @@ static void zram_slot_free_notify(struct block_device *bdev,
>  	zram = bdev->bd_disk->private_data;
>  	meta = zram->meta;
>  
> -	write_lock(&meta->tb_lock);
> +	bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  	zram_free_page(zram, index);
> -	write_unlock(&meta->tb_lock);
> +	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  	atomic64_inc(&zram->stats.notify_free);
>  }
>  
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index 7f21c14..71bc4ad 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -51,10 +51,22 @@ static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
>  #define ZRAM_SECTOR_PER_LOGICAL_BLOCK	\
>  	(1 << (ZRAM_LOGICAL_BLOCK_SHIFT - SECTOR_SHIFT))
>  
> -/* Flags for zram pages (table[page_no].flags) */
> +/*
> + * The lower ZRAM_FLAG_SHIFT bits of table.value is for
> + * object size (excluding header), the higher bits is for
> + * zram_pageflags. By this means, it won't increase any
> + * memory overhead on both 32-bit and 64-bit system.

Comment on "By this means, ~ 64 bit system" is unncessary because
someone read this line but don't know history couldn't understand
what's the old structure.


> + * zram is mostly used on small embedded system, so we
> + * don't want to increase memory footprint. That is why
> + * we pack size and flag into table.value.
> + */

IMHO, it would be more clear but not sure if native speakers look at. ;-)

* zram is mainly used for memory efficiency so we want to keep memory
* footprint small so we can squeeze size and flags into a field.
* The lower ZRAM_FLAG_SHIFT bits is for object size (excluding header),
* the higher bits is for zram_pageflags.


> +#define ZRAM_FLAG_SHIFT 24

Why is it 24? We have used for 16-bit for size.
Do you think it's too small for size?

> +
> +/* Flags for zram pages (table[page_no].value) */
>  enum zram_pageflags {
>  	/* Page consists entirely of zeros */
> -	ZRAM_ZERO,
> +	ZRAM_ZERO = ZRAM_FLAG_SHIFT + 1,
> +	ZRAM_ACCESS,  /* page in now accessed */
>  
>  	__NR_ZRAM_PAGEFLAGS,
>  };
> @@ -64,9 +76,8 @@ enum zram_pageflags {
>  /* Allocated for each disk page */
>  struct table {
>  	unsigned long handle;
> -	u16 size;	/* object size (excluding header) */
> -	u8 flags;
> -} __aligned(4);
> +	unsigned long value;
> +};
>  
>  struct zram_stats {
>  	atomic64_t compr_data_size;	/* compressed size of pages stored */
> @@ -81,7 +92,6 @@ struct zram_stats {
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
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
