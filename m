Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38A956B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 01:29:57 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y200so20448632itc.7
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 22:29:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h67sor10163099ioh.126.2017.12.26.22.29.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Dec 2017 22:29:55 -0800 (PST)
Date: Wed, 27 Dec 2017 15:29:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zram: better utilization of zram swap space
Message-ID: <20171227062946.GA11295@bgram>
References: <CGME20171222103443epcas5p41f45e1a99146aac89edd63f76a3eb62a@epcas5p4.samsung.com>
 <1513938606-17735-1-git-send-email-gopi.st@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513938606-17735-1-git-send-email-gopi.st@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gopi Sai Teja <gopi.st@samsung.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, v.narang@samsung.com, pankaj.m@samsung.com, a.sahrawat@samsung.com, prakash.a@samsung.com, himanshu.sh@samsung.com, lalit.mohan@samsung.com

Hello,

On Fri, Dec 22, 2017 at 04:00:06PM +0530, Gopi Sai Teja wrote:
> 75% of the PAGE_SIZE is not a correct threshold to store uncompressed

Please describe it in detail that why current threshold is bad in that
memory efficiency point of view.

> pages in zs_page as this must be changed if the maximum pages stored
> in zspage changes. Instead using zs classes, we can set the correct

Also, let's include the pharase Sergey pointed out in this description.

It's not a good idea that zram need to know allocator's implementation
with harded value like 75%.

> threshold irrespective of the maximum pages stored in zspage.
> 
> Tested on ARM:
> 
> Before Patch:
> class  size  obj_allocated   obj_used pages_used
> ....
>   190  3072           6744       6724       5058
>   202  3264             90         87         72
>   254  4096          11886      11886      11886
> 
> Total               123251     120511      55076
> 
> After Patch:
> class  size  obj_allocated   obj_used pages_used
> ...
>   190  3072           6368       6326       4776
>   202  3264           2205       2197       1764
>   254  4096          12624      12624      12624
> 
> Total               125655     122045      56541
> 
> Signed-off-by: Gopi Sai Teja <gopi.st@samsung.com>
> ---
> v1 -> v2: Earlier, threshold to store uncompressed page is set
> to 80% of PAGE_SIZE and now zsmalloc classes is used to set the
> threshold.
> 
>  drivers/block/zram/zram_drv.c |  2 +-
>  include/linux/zsmalloc.h      |  1 +
>  mm/zsmalloc.c                 | 13 +++++++++++++
>  3 files changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index d70eba3..dda0ef8 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -965,7 +965,7 @@ static int __zram_bvec_write(struct zram *zram, struct bio_vec *bvec,
>  		return ret;
>  	}
>  
> -	if (unlikely(comp_len > max_zpage_size)) {
> +	if (unlikely(comp_len > zs_max_zpage_size(zram->mem_pool))) {
>  		if (zram_wb_enabled(zram) && allow_wb) {
>  			zcomp_stream_put(zram->comp);
>  			ret = write_to_bdev(zram, bvec, index, bio, &element);
> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> index 57a8e98..0b09aa5 100644
> --- a/include/linux/zsmalloc.h
> +++ b/include/linux/zsmalloc.h
> @@ -54,5 +54,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>  unsigned long zs_get_total_pages(struct zs_pool *pool);
>  unsigned long zs_compact(struct zs_pool *pool);
>  
> +unsigned int zs_max_zpage_size(struct zs_pool *pool);
>  void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
>  #endif
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 685049a..5b434ab 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -261,6 +261,7 @@ struct zs_pool {
>  	 * and unregister_shrinker() will not Oops.
>  	 */
>  	bool shrinker_enabled;
> +	unsigned short max_zpage_size;
>  #ifdef CONFIG_ZSMALLOC_STAT
>  	struct dentry *stat_dentry;
>  #endif
> @@ -318,6 +319,11 @@ static void init_deferred_free(struct zs_pool *pool) {}
>  static void SetZsPageMovable(struct zs_pool *pool, struct zspage *zspage) {}
>  #endif
>  

It seems zs_max_zpage_size is rather confusing although I suggested it.
I couldn't think better name at that time and it's true, still.
Why it's bad is that user can consider it as max size zsmalloc could
store although real meaning is it's the max size allocator can store
for saving memory.

If we cannot think of better name, we should add description in the
head of the function.

/*
 * It returns the max size allocator can store for saving memory.
 * In fact, zsmalloc can store up to ZS_MAX_ALLOC_SIZE but
 * [zs_max_zpage_size, ZA_MAX_ALLOC_SIZE] are pointless for
 * memory saving point of view due to implementation detail.
 */

> +unsigned int zs_max_zpage_size(struct zs_pool *pool)
> +{
> +	return pool->max_zpage_size;

In zsmalloc, we can return hard-coded value instead of variable of pool.
Every instance of zs_pool has same max_zpage_size at this moment so
I don't think we need to introduce new variable of zs_pool.

Thanks.

> +}
> +
>  static int create_cache(struct zs_pool *pool)
>  {
>  	pool->handle_cachep = kmem_cache_create("zs_handle", ZS_HANDLE_SIZE,
> @@ -2368,6 +2374,8 @@ struct zs_pool *zs_create_pool(const char *name)
>  	if (create_cache(pool))
>  		goto err;
>  
> +	pool->max_zpage_size = 0;
> +
>  	/*
>  	 * Iterate reversely, because, size of size_class that we want to use
>  	 * for merging should be larger or equal to current size.
> @@ -2411,6 +2419,11 @@ struct zs_pool *zs_create_pool(const char *name)
>  		class->objs_per_zspage = objs_per_zspage;
>  		spin_lock_init(&class->lock);
>  		pool->size_class[i] = class;
> +
> +		if (!pool->max_zpage_size &&
> +				pages_per_zspage < objs_per_zspage)
> +			pool->max_zpage_size = class->size - ZS_HANDLE_SIZE;
> +
>  		for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
>  							fullness++)
>  			INIT_LIST_HEAD(&class->fullness_list[fullness]);
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
