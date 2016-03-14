Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 10E496B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 02:31:23 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id mh10so7082773igb.0
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 23:31:23 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id qc5si15773523igb.48.2016.03.13.23.31.21
        for <linux-mm@kvack.org>;
        Sun, 13 Mar 2016 23:31:22 -0700 (PDT)
Date: Mon, 14 Mar 2016 15:32:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v3 2/5] mm/zsmalloc: remove shrinker compaction
 callbacks
Message-ID: <20160314063207.GD10675@bbox>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-3-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1457016363-11339-3-git-send-email-sergey.senozhatsky@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, Mar 03, 2016 at 11:46:00PM +0900, Sergey Senozhatsky wrote:
> Do not register shrinker compaction callbacks anymore, since
> now we shedule class compaction work each time its fragmentation
> value goes above the watermark.

I suggested to remove shrinker compaction but while I review your
first patch in this thread, I thought we need upper-bound to
compact zspage so background work can bail out for latency easily.
IOW, the work could give up the job. In such case, we might need
fall-back scheme to continue the job. And I think that could be
a shrinker.

What do you think?

> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/zsmalloc.c | 72 -----------------------------------------------------------
>  1 file changed, 72 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index a4ef7e7..0bb060f 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -256,13 +256,6 @@ struct zs_pool {
>  
>  	struct zs_pool_stats stats;
>  
> -	/* Compact classes */
> -	struct shrinker shrinker;
> -	/*
> -	 * To signify that register_shrinker() was successful
> -	 * and unregister_shrinker() will not Oops.
> -	 */
> -	bool shrinker_enabled;
>  #ifdef CONFIG_ZSMALLOC_STAT
>  	struct dentry *stat_dentry;
>  #endif
> @@ -1848,64 +1841,6 @@ void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats)
>  }
>  EXPORT_SYMBOL_GPL(zs_pool_stats);
>  
> -static unsigned long zs_shrinker_scan(struct shrinker *shrinker,
> -		struct shrink_control *sc)
> -{
> -	unsigned long pages_freed;
> -	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
> -			shrinker);
> -
> -	pages_freed = pool->stats.pages_compacted;
> -	/*
> -	 * Compact classes and calculate compaction delta.
> -	 * Can run concurrently with a manually triggered
> -	 * (by user) compaction.
> -	 */
> -	pages_freed = zs_compact(pool) - pages_freed;
> -
> -	return pages_freed ? pages_freed : SHRINK_STOP;
> -}
> -
> -static unsigned long zs_shrinker_count(struct shrinker *shrinker,
> -		struct shrink_control *sc)
> -{
> -	int i;
> -	struct size_class *class;
> -	unsigned long pages_to_free = 0;
> -	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
> -			shrinker);
> -
> -	for (i = zs_size_classes - 1; i >= 0; i--) {
> -		class = pool->size_class[i];
> -		if (!class)
> -			continue;
> -		if (class->index != i)
> -			continue;
> -
> -		pages_to_free += zs_can_compact(class);
> -	}
> -
> -	return pages_to_free;
> -}
> -
> -static void zs_unregister_shrinker(struct zs_pool *pool)
> -{
> -	if (pool->shrinker_enabled) {
> -		unregister_shrinker(&pool->shrinker);
> -		pool->shrinker_enabled = false;
> -	}
> -}
> -
> -static int zs_register_shrinker(struct zs_pool *pool)
> -{
> -	pool->shrinker.scan_objects = zs_shrinker_scan;
> -	pool->shrinker.count_objects = zs_shrinker_count;
> -	pool->shrinker.batch = 0;
> -	pool->shrinker.seeks = DEFAULT_SEEKS;
> -
> -	return register_shrinker(&pool->shrinker);
> -}
> -
>  /**
>   * zs_create_pool - Creates an allocation pool to work from.
>   * @flags: allocation flags used to allocate pool metadata
> @@ -1994,12 +1929,6 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>  	if (zs_pool_stat_create(name, pool))
>  		goto err;
>  
> -	/*
> -	 * Not critical, we still can use the pool
> -	 * and user can trigger compaction manually.
> -	 */
> -	if (zs_register_shrinker(pool) == 0)
> -		pool->shrinker_enabled = true;
>  	return pool;
>  
>  err:
> @@ -2012,7 +1941,6 @@ void zs_destroy_pool(struct zs_pool *pool)
>  {
>  	int i;
>  
> -	zs_unregister_shrinker(pool);
>  	zs_pool_stat_destroy(pool);
>  
>  	for (i = 0; i < zs_size_classes; i++) {
> -- 
> 2.8.0.rc0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
