Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B7CEA6B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:10:45 -0400 (EDT)
Date: Fri, 7 Jun 2013 10:10:27 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH v11 20/25] drivers: convert shrinkers to new count/scan
 API
Message-ID: <20130607141027.GH25649@phenom.dumpdata.com>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
 <1370550898-26711-21-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370550898-26711-21-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Kent Overstreet <koverstreet@google.com>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, John Stultz <john.stultz@linaro.org>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>

On Fri, Jun 07, 2013 at 12:34:53AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert the driver shrinkers to the new API. Most changes are
> compile tested only because I either don't have the hardware or it's
> staging stuff.
> 
> FWIW, the md and android code is pretty good, but the rest of it
> makes me want to claw my eyes out.  The amount of broken code I just
> encountered is mind boggling.  I've added comments explaining what
> is broken, but I fear that some of the code would be best dealt with
> by being dragged behind the bike shed, burying in mud up to it's
> neck and then run over repeatedly with a blunt lawn mower.

The rest being i915, ttm, bcache- etc ?

> 
> Special mention goes to the zcache/zcache2 drivers. They can't
> co-exist in the build at the same time, they are under different
> menu options in menuconfig, they only show up when you've got the
> right set of mm subsystem options configured and so even compile
> testing is an exercise in pulling teeth.  And that doesn't even take
> into account the horrible, broken code...

Now that you have rebased it, did you still see issues here.

> diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
> index bd2a3b4..1746f30 100644
> --- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
> +++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
> @@ -377,28 +377,26 @@ out:
>  	return nr_free;
>  }
>  
> -/* Get good estimation how many pages are free in pools */
> -static int ttm_pool_get_num_unused_pages(void)
> -{
> -	unsigned i;
> -	int total = 0;
> -	for (i = 0; i < NUM_POOLS; ++i)
> -		total += _manager->pools[i].npages;
> -
> -	return total;
> -}
> -

I am unclear as of why you move this.
>  /**
>   * Callback for mm to request pool to reduce number of page held.
> + *
> + * XXX: (dchinner) Deadlock warning!
> + *
> + * ttm_page_pool_free() does memory allocation using GFP_KERNEL.  that means

That
> + * this can deadlock when called a sc->gfp_mask that is not equal to
> + * GFP_KERNEL.
> + *
> + * This code is crying out for a shrinker per pool....

It iterates over different pools.


The ttm_page_pool_free() could use GFP_ATOMIC to guard against the dead-lock
I think?

>   */
> -static int ttm_pool_mm_shrink(struct shrinker *shrink,
> -			      struct shrink_control *sc)
> +static long
> +ttm_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	static atomic_t start_pool = ATOMIC_INIT(0);
>  	unsigned i;
>  	unsigned pool_offset = atomic_add_return(1, &start_pool);
>  	struct ttm_page_pool *pool;
>  	int shrink_pages = sc->nr_to_scan;
> +	long freed = 0;
>  
>  	pool_offset = pool_offset % NUM_POOLS;
>  	/* select start pool in round robin fashion */
> @@ -408,14 +406,28 @@ static int ttm_pool_mm_shrink(struct shrinker *shrink,
>  			break;
>  		pool = &_manager->pools[(i + pool_offset)%NUM_POOLS];
>  		shrink_pages = ttm_page_pool_free(pool, nr_free);
> +		freed += nr_free - shrink_pages;
>  	}
> -	/* return estimated number of unused pages in pool */
> -	return ttm_pool_get_num_unused_pages();
> +	return freed;
> +}
> +
> +
> +static long
> +ttm_pool_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	unsigned i;
> +	long count = 0;
> +
> +	for (i = 0; i < NUM_POOLS; ++i)
> +		count += _manager->pools[i].npages;
> +
> +	return count;
>  }
>  
>  static void ttm_pool_mm_shrink_init(struct ttm_pool_manager *manager)
>  {
> -	manager->mm_shrink.shrink = &ttm_pool_mm_shrink;
> +	manager->mm_shrink.count_objects = &ttm_pool_shrink_count;
> +	manager->mm_shrink.scan_objects = &ttm_pool_shrink_scan;
>  	manager->mm_shrink.seeks = 1;
>  	register_shrinker(&manager->mm_shrink);
>  }
> diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> index b8b3943..dc009f1 100644
> --- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> +++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> @@ -918,19 +918,6 @@ int ttm_dma_populate(struct ttm_dma_tt *ttm_dma, struct device *dev)
>  }
>  EXPORT_SYMBOL_GPL(ttm_dma_populate);
>  
> -/* Get good estimation how many pages are free in pools */
> -static int ttm_dma_pool_get_num_unused_pages(void)
> -{
> -	struct device_pools *p;
> -	unsigned total = 0;
> -
> -	mutex_lock(&_manager->lock);
> -	list_for_each_entry(p, &_manager->pools, pools)
> -		total += p->pool->npages_free;
> -	mutex_unlock(&_manager->lock);
> -	return total;
> -}
> -
>  /* Put all pages in pages list to correct pool to wait for reuse */
>  void ttm_dma_unpopulate(struct ttm_dma_tt *ttm_dma, struct device *dev)
>  {
> @@ -1002,18 +989,29 @@ EXPORT_SYMBOL_GPL(ttm_dma_unpopulate);
>  
>  /**
>   * Callback for mm to request pool to reduce number of page held.
> + *
> + * XXX: (dchinner) Deadlock warning!
> + *
> + * ttm_dma_page_pool_free() does GFP_KERNEL memory allocation, and so attention
> + * needs to be paid to sc->gfp_mask to determine if this can be done or not.
> + * GFP_KERNEL memory allocation in a GFP_ATOMIC reclaim context woul dbe really
> + * bad.

would be.
> + *
> + * I'm getting sadder as I hear more pathetical whimpers about needing per-pool
> + * shrinkers

Were are these whimpers coming from?

>   */
> -static int ttm_dma_pool_mm_shrink(struct shrinker *shrink,
> -				  struct shrink_control *sc)
> +static long
> +ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	static atomic_t start_pool = ATOMIC_INIT(0);
>  	unsigned idx = 0;
>  	unsigned pool_offset = atomic_add_return(1, &start_pool);
>  	unsigned shrink_pages = sc->nr_to_scan;
>  	struct device_pools *p;
> +	long freed = 0;
>  
>  	if (list_empty(&_manager->pools))
> -		return 0;
> +		return SHRINK_STOP;
>  
>  	mutex_lock(&_manager->lock);
>  	pool_offset = pool_offset % _manager->npools;
> @@ -1029,18 +1027,33 @@ static int ttm_dma_pool_mm_shrink(struct shrinker *shrink,
>  			continue;
>  		nr_free = shrink_pages;
>  		shrink_pages = ttm_dma_page_pool_free(p->pool, nr_free);
> +		freed += nr_free - shrink_pages;
> +
>  		pr_debug("%s: (%s:%d) Asked to shrink %d, have %d more to go\n",
>  			 p->pool->dev_name, p->pool->name, current->pid,
>  			 nr_free, shrink_pages);
>  	}
>  	mutex_unlock(&_manager->lock);
> -	/* return estimated number of unused pages in pool */
> -	return ttm_dma_pool_get_num_unused_pages();
> +	return freed;
> +}

That code looks good.
> +
> +static long
> +ttm_dma_pool_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	struct device_pools *p;
> +	long count = 0;
> +
> +	mutex_lock(&_manager->lock);
> +	list_for_each_entry(p, &_manager->pools, pools)
> +		count += p->pool->npages_free;
> +	mutex_unlock(&_manager->lock);
> +	return count;
>  }

But this needn't to be moved? Or is it b/c you would like the code to
be in "one section" ?

If so, please use the same style for functions as the rest of the file
has.

>  
>  static void ttm_dma_pool_mm_shrink_init(struct ttm_pool_manager *manager)
>  {
> -	manager->mm_shrink.shrink = &ttm_dma_pool_mm_shrink;
> +	manager->mm_shrink.count_objects = &ttm_dma_pool_shrink_count;
> +	manager->mm_shrink.scan_objects = &ttm_dma_pool_shrink_scan;
>  	manager->mm_shrink.seeks = 1;
>  	register_shrinker(&manager->mm_shrink);
>  }

.. snip..
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index dcceed2..4ade8e3 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1140,23 +1140,19 @@ static bool zcache_freeze;
>   * pageframes in use.  FIXME POLICY: Probably the writeback should only occur
>   * if the eviction doesn't free enough pages.
>   */
> -static int shrink_zcache_memory(struct shrinker *shrink,
> -				struct shrink_control *sc)
> +static long scan_zcache_memory(struct shrinker *shrink,
> +			       struct shrink_control *sc)
>  {
>  	static bool in_progress;
> -	int ret = -1;
> -	int nr = sc->nr_to_scan;
>  	int nr_evict = 0;
>  	int nr_writeback = 0;
>  	struct page *page;
>  	int  file_pageframes_inuse, anon_pageframes_inuse;
> -
> -	if (nr <= 0)
> -		goto skip_evict;
> +	long freed = 0;
>  
>  	/* don't allow more than one eviction thread at a time */
>  	if (in_progress)
> -		goto skip_evict;
> +		return 0;
>  
>  	in_progress = true;
>  
> @@ -1176,6 +1172,7 @@ static int shrink_zcache_memory(struct shrinker *shrink,
>  		if (page == NULL)
>  			break;
>  		zcache_free_page(page);
> +		freed++;
>  	}
>  
>  	zcache_last_active_anon_pageframes =
> @@ -1192,13 +1189,22 @@ static int shrink_zcache_memory(struct shrinker *shrink,
>  #ifdef CONFIG_ZCACHE_WRITEBACK
>  		int writeback_ret;
>  		writeback_ret = zcache_frontswap_writeback();
> -		if (writeback_ret == -ENOMEM)
> +		if (writeback_ret != -ENOMEM)
> +			freed++;
> +		else
>  #endif
>  			break;
>  	}
>  	in_progress = false;
>  
> -skip_evict:
> +	return freed;
> +}
> +
> +static long count_zcache_memory(struct shrinker *shrink,
> +				struct shrink_control *sc)
> +{
> +	int ret = -1;
> +
>  	/* resample: has changed, but maybe not all the way yet */
>  	zcache_last_active_file_pageframes =
>  		global_page_state(NR_LRU_BASE + LRU_ACTIVE_FILE);
> @@ -1212,7 +1218,8 @@ skip_evict:
>  }
>  
>  static struct shrinker zcache_shrinker = {
> -	.shrink = shrink_zcache_memory,
> +	.scan_objects = scan_zcache_memory,
> +	.count_objects = count_zcache_memory,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  

That looks OK, but I think it needs an Ack from Greg KH as well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
