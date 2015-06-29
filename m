Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7306B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 03:07:03 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so111566338pdb.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 00:07:02 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ct3si62845770pbc.99.2015.06.29.00.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 00:07:02 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so100905125pab.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 00:07:01 -0700 (PDT)
Date: Mon, 29 Jun 2015 16:07:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv3 7/7] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150629070711.GD13179@bbox>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-8-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434628004-11144-8-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, Jun 18, 2015 at 08:46:44PM +0900, Sergey Senozhatsky wrote:
> Perform automatic pool compaction by a shrinker when system
> is getting tight on memory.
> 
> User-space has a very little knowledge regarding zsmalloc fragmentation
> and basically has no mechanism to tell whether compaction will result
> in any memory gain. Another issue is that user space is not always
> aware of the fact that system is getting tight on memory. Which leads
> to very uncomfortable scenarios when user space may start issuing
> compaction 'randomly' or from crontab (for example). Fragmentation
> is not always necessarily bad, allocated and unused objects, after all,
> may be filled with the data later, w/o the need of allocating a new
> zspage. On the other hand, we obviously don't want to waste memory
> when systems needs it.
> 
> Compaction now has a relatively quick pool scan so we are able to
> estimate the number of pages that will be freed easily, which makes it
> possible to call this function from a shrinker->count_objects() callback.
> We also abort compaction as soon as we detect that we can't free any
> pages any more, preventing wasteful objects migrations.
> 
> Minchan Kim proposed to use the shrinker (the original patch was too
> aggressive and was attempting to perform compaction for every
> ALMOST_EMPTY zspage).
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/zsmalloc.c | 78 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 71 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index c9aea0a..692b7dc 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -247,7 +247,9 @@ struct zs_pool {
>  	atomic_long_t		pages_allocated;
>  	/* How many objects were migrated */
>  	unsigned long		num_migrated;
> -
> +	/* Compact classes */
> +	struct shrinker		shrinker;
> +	bool			shrinker_enabled;
>  #ifdef CONFIG_ZSMALLOC_STAT
>  	struct dentry		*stat_dentry;
>  #endif
> @@ -1730,12 +1732,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  
>  		while ((dst_page = isolate_target_page(class))) {
>  			cc.d_page = dst_page;
> -			/*
> -			 * If there is no more space in dst_page, resched
> -			 * and see if anyone had allocated another zspage.
> -			 */
> +
>  			if (!migrate_zspage(pool, class, &cc))
> -				break;
> +				goto out;

It should retry with another target_page instead of going out.

>  
>  			putback_zspage(pool, class, dst_page);
>  		}
> @@ -1750,7 +1749,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  		cond_resched();
>  		spin_lock(&class->lock);
>  	}
> -
> +out:
> +	if (dst_page)
> +		putback_zspage(pool, class, dst_page);
>  	if (src_page)
>  		putback_zspage(pool, class, src_page);
>  
> @@ -1774,6 +1775,65 @@ unsigned long zs_compact(struct zs_pool *pool)
>  }
>  EXPORT_SYMBOL_GPL(zs_compact);
>  
> +static unsigned long zs_shrinker_scan(struct shrinker *shrinker,
> +		struct shrink_control *sc)
> +{
> +	unsigned long freed;
> +	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
> +			shrinker);
> +
> +	freed = pool->num_migrated;
> +	/* Compact classes and calculate compaction delta */
> +	freed = zs_compact(pool) - freed;

Returns migrated object count.

> +
> +	return freed ? freed : SHRINK_STOP;
> +}
> +
> +static unsigned long zs_shrinker_count(struct shrinker *shrinker,
> +		struct shrink_control *sc)
> +{
> +	int i;
> +	struct size_class *class;
> +	unsigned long to_free = 0;
> +	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
> +			shrinker);
> +
> +	if (!pool->shrinker_enabled)
> +		return 0;
> +
> +	for (i = zs_size_classes - 1; i >= 0; i--) {
> +		class = pool->size_class[i];
> +		if (!class)
> +			continue;
> +		if (class->index != i)
> +			continue;
> +
> +		spin_lock(&class->lock);
> +		to_free += zs_can_compact(class);

But it returns wasted_obj / max_obj_per_zspage?

> +		spin_unlock(&class->lock);
> +	}
> +
> +	return to_free;
> +}
> +
> +static void zs_unregister_shrinker(struct zs_pool *pool)
> +{
> +	if (pool->shrinker_enabled) {
> +		unregister_shrinker(&pool->shrinker);
> +		pool->shrinker_enabled = false;
> +	}
> +}
> +
> +static int zs_register_shrinker(struct zs_pool *pool)
> +{
> +	pool->shrinker.scan_objects = zs_shrinker_scan;
> +	pool->shrinker.count_objects = zs_shrinker_count;
> +	pool->shrinker.batch = 0;
> +	pool->shrinker.seeks = DEFAULT_SEEKS;
> +
> +	return register_shrinker(&pool->shrinker);
> +}
> +
>  /**
>   * zs_create_pool - Creates an allocation pool to work from.
>   * @flags: allocation flags used to allocate pool metadata
> @@ -1859,6 +1919,9 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
>  	if (zs_pool_stat_create(name, pool))
>  		goto err;
>  
> +	/* Not critical, we still can use the pool */
> +	if (zs_register_shrinker(pool) == 0)
> +		pool->shrinker_enabled = true;
>  	return pool;
>  
>  err:
> @@ -1871,6 +1934,7 @@ void zs_destroy_pool(struct zs_pool *pool)
>  {
>  	int i;
>  
> +	zs_unregister_shrinker(pool);
>  	zs_pool_stat_destroy(pool);
>  
>  	for (i = 0; i < zs_size_classes; i++) {
> -- 
> 2.4.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
