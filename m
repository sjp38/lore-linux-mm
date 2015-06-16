Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E4F326B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 10:47:38 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so15914457pdj.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 07:47:38 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id tz6si1661277pab.216.2015.06.16.07.47.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 07:47:37 -0700 (PDT)
Received: by pdbnf5 with SMTP id nf5so16030231pdb.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 07:47:37 -0700 (PDT)
Date: Tue, 16 Jun 2015 23:47:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv2 8/8] zsmalloc: register a shrinker to trigger
 auto-compaction
Message-ID: <20150616144730.GD31387@blaptop>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri, Jun 05, 2015 at 09:03:58PM +0900, Sergey Senozhatsky wrote:
> Perform automatic pool compaction by a shrinker when system
> is getting tight on memory.
> 
> Demonstration (this output is merely to show auto-compaction
> effectiveness and is not part of the code):
> [..]
> [ 4283.803766] zram0 zs_shrinker_scan freed 364
> [ 4285.398937] zram0 zs_shrinker_scan freed 471
> [ 4286.044095] zram0 zs_shrinker_scan freed 273
> [ 4286.951824] zram0 zs_shrinker_scan freed 312
> [ 4287.583563] zram0 zs_shrinker_scan freed 222
> [ 4289.360971] zram0 zs_shrinker_scan freed 343
> [ 4289.884653] zram0 zs_shrinker_scan freed 210
> [ 4291.204705] zram0 zs_shrinker_scan freed 175
> [ 4292.043656] zram0 zs_shrinker_scan freed 425
> [ 4292.273397] zram0 zs_shrinker_scan freed 109
> [ 4292.513351] zram0 zs_shrinker_scan freed 191
> [..]
> 
> cat /sys/block/zram0/mm_stat
>  2908798976 2061913167 2091438080        0 2128449536      868     6074
> 
> Compaction now has a relatively quick pool scan so we are able to
> estimate the number of pages that will be freed easily, which makes it
> possible to call this function from a shrinker->count_objects() callback.
> We also abort compaction as soon as we detect that we can't free any
> pages any more, preventing wasteful objects migrations. In the example
> above, "6074 objects were migrated" implies that we actually released
> zspages back to system.
> 
> The initial patch was triggering compaction from zs_free() for
> every ZS_ALMOST_EMPTY page. Minchan Kim proposed to use a slab
> shrinker.

First of all, thanks for mentioning me as proposer.
However, it's not a helpful comment for other reviewers and
anonymous people who will review this in future.

At least, write why I suggested it so others can understand
the pros/cons.

> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Reported-by: Minchan Kim <minchan@kernel.org>

I didn't report anything. ;-).


> ---
>  mm/zsmalloc.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 71 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index a81e75b..f262d8d 100644
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
> @@ -1728,12 +1730,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
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
>  
>  			putback_zspage(pool, class, dst_page);
>  		}
> @@ -1744,11 +1743,10 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
>  
>  		putback_zspage(pool, class, dst_page);
>  		putback_zspage(pool, class, src_page);
> -		spin_unlock(&class->lock);
> -		cond_resched();
> -		spin_lock(&class->lock);

So should we hold class lock until finishing the compaction of the class?
It would make horrible latency for other allocation from the class
in parallel.

I will review remain parts tomorrow(I hope) but what I want to say
before going sleep is:

I like the idea but still have a concern to lack of fragmented zspages
during memory pressure because auto-compaction will prevent fragment
most of time. Surely, using fragment space as buffer in heavy memory
pressure is not intened design so it could be fragile but I'm afraid
this feature might accelrate it and it ends up having a problem and
change current behavior in zram as swap.

I hope you test this feature with considering my concern.
Of course, I will test it with enough time.

Thanks.


>  	}
> -
> +out:
> +	if (dst_page)
> +		putback_zspage(pool, class, dst_page);
>  	if (src_page)
>  		putback_zspage(pool, class, src_page);
>  
> @@ -1772,6 +1770,65 @@ unsigned long zs_compact(struct zs_pool *pool)
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
> @@ -1857,6 +1914,9 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
>  	if (zs_pool_stat_create(name, pool))
>  		goto err;
>  
> +	/* Not critical, we still can use the pool */
> +	if (zs_register_shrinker(pool) == 0)
> +		pool->shrinker_enabled = true;
>  	return pool;
>  
>  err:
> @@ -1869,6 +1929,7 @@ void zs_destroy_pool(struct zs_pool *pool)
>  {
>  	int i;
>  
> +	zs_unregister_shrinker(pool);
>  	zs_pool_stat_destroy(pool);
>  
>  	for (i = 0; i < zs_size_classes; i++) {
> -- 
> 2.4.2.387.gf86f31a
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
