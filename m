Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D97F6B0261
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 18:42:18 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 101so90634700iom.7
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 15:42:18 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y26si69278pfk.69.2017.01.09.15.42.16
        for <linux-mm@kvack.org>;
        Mon, 09 Jan 2017 15:42:17 -0800 (PST)
Date: Tue, 10 Jan 2017 08:41:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170109234110.GA10298@bbox>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
In-Reply-To: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

Hello,

On Fri, Jan 06, 2017 at 04:42:25PM +0800, zhouxianrong@huawei.com wrote:
> From: zhouxianrong <zhouxianrong@huawei.com>
> 
> the idea is that without doing more calculations we extend zero pages
> to same element pages for zram. zero page is special case of
> same element page with zero element.
> 
> 1. the test is done under android 7.0
> 2. startup too many applications circularly
> 3. sample the zero pages, same pages (none-zero element) 
>    and total pages in function page_zero_filled
> 
> the result is listed as below:
> 
> ZERO	SAME	TOTAL
> 36214	17842	598196
> 
> 		ZERO/TOTAL	 SAME/TOTAL	  (ZERO+SAME)/TOTAL ZERO/SAME
> AVERAGE	0.060631909	 0.024990816  0.085622726		2.663825038
> STDEV	0.00674612	 0.005887625  0.009707034		2.115881328
> MAX		0.069698422	 0.030046087  0.094975336		7.56043956
> MIN		0.03959586	 0.007332205  0.056055193		1.928985507
> 
> from above data, the benefit is about 2.5% and up to 3% of total 
> swapout pages.

It looks great if we considers the amount of diff.
Thanks!

> 
> the defect of the patch is that when we recovery a page from 
> non-zero element the operations are low efficient for partial
> read.

Nice description. I love to see pros/cons. :)
If it hurts partial-read little bit, it would be not critical problem.

> 
> Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
> ---
>  drivers/block/zram/zram_drv.c |  102 +++++++++++++++++++++++++++++++----------
>  drivers/block/zram/zram_drv.h |   11 +++--
>  2 files changed, 84 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 15f58ab..3250a8b 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -94,6 +94,17 @@ static void zram_clear_flag(struct zram_meta *meta, u32 index,
>  	meta->table[index].value &= ~BIT(flag);
>  }
>  
> +static inline void zram_set_element(struct zram_meta *meta, u32 index,
> +			unsigned long element)
> +{
> +	meta->table[index].element = element;
> +}
> +
> +static inline void zram_clear_element(struct zram_meta *meta, u32 index)
> +{
> +	meta->table[index].element = 0;
> +}
> +
>  static size_t zram_get_obj_size(struct zram_meta *meta, u32 index)
>  {
>  	return meta->table[index].value & (BIT(ZRAM_FLAG_SHIFT) - 1);
> @@ -158,31 +169,68 @@ static inline void update_used_max(struct zram *zram,
>  	} while (old_max != cur_max);
>  }
>  
> -static bool page_zero_filled(void *ptr)
> +static inline void zram_set_page(char *ptr, unsigned long value)

Nit:
I prefer fill to set in this case.
How about zram_fill_page?
It is a just nit so if you want to set, I'm not against.

> +{
> +	int i;
> +	unsigned long *page = (unsigned long *)ptr;
> +
> +	for (i = PAGE_SIZE / sizeof(unsigned long) - 1; i >= 0; i--)
> +		page[i] = value;
> +}
> +
> +static inline void zram_set_page_partial(char *ptr, unsigned int size,
> +		unsigned long value)
> +{
> +	int i;
> +
> +	i = ((unsigned long)ptr) % sizeof(unsigned long);
> +	if (i) {

Hmm, Is this case really happens? I guess block layer works with IO size unit
which would be aligned (unsigned long) at least, maybe SECTOR or PAGE size.

Then, I think we can merge both zram_set_page and zram_set_page_partial
like this.

static inline void zram_fill_page(char *ptr, unsigned int size, unsigned long elelment)
{
        int i;
        unsigned long *page = (unsigned long *)ptr;

        WARN_ON_ONCE((unsigned long)ptr % sizeof(unsigned long));
        for (i = size / sizeof(unsigned long) - 1; i >= 0; i--)
                page[i] = element
}

> +		while (i < sizeof(unsigned long)) {
> +			*ptr++ = (value >> (i * 8)) & 0xff;
> +			--size;
> +			++i;
> +		}
> +	}
> +
> +	for (i = size / sizeof(unsigned long); i > 0; --i) {
> +		*(unsigned long *)ptr = value;
> +		ptr += sizeof(unsigned long);
> +		size -= sizeof(unsigned long);
> +	}
> +
> +	for (i = 0; i < size; ++i)
> +		*ptr++ = (value >> (i * 8)) & 0xff;
> +}
> +
> +static bool page_same_filled(void *ptr, unsigned long *element)
>  {
>  	unsigned int pos;
>  	unsigned long *page;
>  
>  	page = (unsigned long *)ptr;
>  
> -	for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
> -		if (page[pos])
> +	for (pos = PAGE_SIZE / sizeof(unsigned long) - 1; pos > 0; pos--) {
> +		if (page[pos] != page[pos - 1])
>  			return false;
>  	}
>  
> +	if (element)

Maybe, we don't need this condition check?

> +		element[0] = page[pos];
> +
>  	return true;
>  }
>  
> -static void handle_zero_page(struct bio_vec *bvec)
> +static void handle_same_page(struct bio_vec *bvec, unsigned long element)
>  {
>  	struct page *page = bvec->bv_page;
>  	void *user_mem;
>  
>  	user_mem = kmap_atomic(page);
>  	if (is_partial_io(bvec))
> -		memset(user_mem + bvec->bv_offset, 0, bvec->bv_len);
> +		zram_set_page_partial(user_mem + bvec->bv_offset, bvec->bv_len,
> +			element);
>  	else
> -		clear_page(user_mem);
> +		zram_set_page(user_mem, element);
>  	kunmap_atomic(user_mem);
>  
>  	flush_dcache_page(page);
> @@ -431,7 +479,7 @@ static ssize_t mm_stat_show(struct device *dev,
>  			mem_used << PAGE_SHIFT,
>  			zram->limit_pages << PAGE_SHIFT,
>  			max_used << PAGE_SHIFT,
> -			(u64)atomic64_read(&zram->stats.zero_pages),
> +			(u64)atomic64_read(&zram->stats.same_pages),

Unfortunately, we cannot replace zero pages stat with same pages's one right
now due to compatibility problem. Please add same_pages to tail of the stat
and we should warn deprecated zero_pages stat so we finally will remove it
two year later. Please reference Documentation/ABI/obsolete/sysfs-block-zram
And add zero-pages to the document.

For example,

... mm_stat_show()
{
        pr_warn_once("zero pages was deprecated so it will be removed at 2019 Jan");
}

Sergey, what's your opinion?

>  			pool_stats.pages_compacted);
>  	up_read(&zram->init_lock);
>  
> @@ -464,7 +512,7 @@ static ssize_t debug_stat_show(struct device *dev,
>  ZRAM_ATTR_RO(failed_writes);
>  ZRAM_ATTR_RO(invalid_io);
>  ZRAM_ATTR_RO(notify_free);
> -ZRAM_ATTR_RO(zero_pages);
> +ZRAM_ATTR_RO(same_pages);
>  ZRAM_ATTR_RO(compr_data_size);
>  
>  static inline bool zram_meta_get(struct zram *zram)
> @@ -538,18 +586,20 @@ static void zram_free_page(struct zram *zram, size_t index)
>  	struct zram_meta *meta = zram->meta;
>  	unsigned long handle = meta->table[index].handle;
>  
> -	if (unlikely(!handle)) {
> -		/*
> -		 * No memory is allocated for zero filled pages.
> -		 * Simply clear zero page flag.
> -		 */
> -		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
> -			zram_clear_flag(meta, index, ZRAM_ZERO);
> -			atomic64_dec(&zram->stats.zero_pages);
> -		}
> +	/*
> +	 * No memory is allocated for same element filled pages.
> +	 * Simply clear same page flag.
> +	 */
> +	if (zram_test_flag(meta, index, ZRAM_SAME)) {
> +		zram_clear_flag(meta, index, ZRAM_SAME);
> +		zram_clear_element(meta, index);
> +		atomic64_dec(&zram->stats.same_pages);
>  		return;
>  	}
>  
> +	if (!handle)
> +		return;
> +
>  	zs_free(meta->mem_pool, handle);
>  
>  	atomic64_sub(zram_get_obj_size(meta, index),
> @@ -572,9 +622,9 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
>  	handle = meta->table[index].handle;
>  	size = zram_get_obj_size(meta, index);
>  
> -	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
> +	if (!handle || zram_test_flag(meta, index, ZRAM_SAME)) {
>  		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> -		clear_page(mem);
> +		zram_set_page(mem, meta->table[index].element);

>  		return 0;
>  	}
>  
> @@ -610,9 +660,9 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
>  
>  	bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  	if (unlikely(!meta->table[index].handle) ||
> -			zram_test_flag(meta, index, ZRAM_ZERO)) {
> +			zram_test_flag(meta, index, ZRAM_SAME)) {
>  		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> -		handle_zero_page(bvec);
> +		handle_same_page(bvec, meta->table[index].element);
>  		return 0;
>  	}
>  	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> @@ -660,6 +710,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	struct zram_meta *meta = zram->meta;
>  	struct zcomp_strm *zstrm = NULL;
>  	unsigned long alloced_pages;
> +	unsigned long element;
>  
>  	page = bvec->bv_page;
>  	if (is_partial_io(bvec)) {
> @@ -688,16 +739,17 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  		uncmem = user_mem;
>  	}
>  
> -	if (page_zero_filled(uncmem)) {
> +	if (page_same_filled(uncmem, &element)) {
>  		if (user_mem)
>  			kunmap_atomic(user_mem);
>  		/* Free memory associated with this sector now. */
>  		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  		zram_free_page(zram, index);
> -		zram_set_flag(meta, index, ZRAM_ZERO);
> +		zram_set_flag(meta, index, ZRAM_SAME);
> +		zram_set_element(meta, index, element);
>  		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
>  
> -		atomic64_inc(&zram->stats.zero_pages);
> +		atomic64_inc(&zram->stats.same_pages);
>  		ret = 0;
>  		goto out;
>  	}
> @@ -1203,7 +1255,7 @@ static int zram_open(struct block_device *bdev, fmode_t mode)
>  	&dev_attr_compact.attr,
>  	&dev_attr_invalid_io.attr,
>  	&dev_attr_notify_free.attr,
> -	&dev_attr_zero_pages.attr,
> +	&dev_attr_same_pages.attr,
>  	&dev_attr_orig_data_size.attr,
>  	&dev_attr_compr_data_size.attr,
>  	&dev_attr_mem_used_total.attr,
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index 74fcf10..4bb92e1 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -60,8 +60,8 @@
>  
>  /* Flags for zram pages (table[page_no].value) */
>  enum zram_pageflags {
> -	/* Page consists entirely of zeros */
> -	ZRAM_ZERO = ZRAM_FLAG_SHIFT,
> +	/* Page consists entirely of same elements */
> +	ZRAM_SAME = ZRAM_FLAG_SHIFT,
>  	ZRAM_ACCESS,	/* page is now accessed */
>  
>  	__NR_ZRAM_PAGEFLAGS,
> @@ -71,7 +71,10 @@ enum zram_pageflags {
>  
>  /* Allocated for each disk page */
>  struct zram_table_entry {
> -	unsigned long handle;
> +	union {
> +		unsigned long handle;
> +		unsigned long element;
> +	};
>  	unsigned long value;
>  };
>  
> @@ -83,7 +86,7 @@ struct zram_stats {
>  	atomic64_t failed_writes;	/* can happen when memory is too low */
>  	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
>  	atomic64_t notify_free;	/* no. of swap slot free notifications */
> -	atomic64_t zero_pages;		/* no. of zero filled pages */
> +	atomic64_t same_pages;		/* no. of same element filled pages */
>  	atomic64_t pages_stored;	/* no. of pages currently stored */
>  	atomic_long_t max_used_pages;	/* no. of maximum pages stored */
>  	atomic64_t writestall;		/* no. of write slow paths */
> -- 
> 1.7.9.5
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
