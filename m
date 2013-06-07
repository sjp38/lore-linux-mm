Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 36F6C6B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 09:37:33 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id cm16so1042709qab.7
        for <linux-mm@kvack.org>; Fri, 07 Jun 2013 06:37:32 -0700 (PDT)
Date: Fri, 7 Jun 2013 09:37:28 -0400
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: Re: [PATCH 17/19] drivers: convert shrinkers to new count/scan API
Message-ID: <20130607133721.GA31384@phenom.dumpdata.com>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-18-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354058086-27937-18-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Wed, Nov 28, 2012 at 10:14:44AM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert the driver shrinkers to the new API. Most changes are
> compile tested only because I either don't have the hardware or it's
> staging stuff.

I presume that the the i915, ttm_page_alloc and ttm_page_alloc_dma
were tested by you? They cover the most common graphic drivers.

> 
> FWIW, the md and android code is pretty good, but the rest of it
> makes me want to claw my eyes out.  The amount of broken code I just
> encountered is mind boggling.  I've added comments explaining what
> is broken, but I fear that some of the code would be best dealt with
> by being dragged behind the bike shed, burying in mud up to it's
> neck and then run over repeatedly with a blunt lawn mower.
> 
> Special mention goes to the zcache/zcache2 drivers. They can't
> co-exist in the build at the same time, they are under different
> menu options in menuconfig, they only show up when you've got the
> right set of mm subsystem options configured and so even compile
> testing is an exercise in pulling teeth.  And that doesn't even take
> into account the horrible, broken code...

Hm, I was under the impression that there is only one zcache code?
Are you referring to ramster perhaps?

> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  drivers/gpu/drm/i915/i915_dma.c           |    4 +-
>  drivers/gpu/drm/i915/i915_gem.c           |   64 +++++++++++++++++++++-------
>  drivers/gpu/drm/ttm/ttm_page_alloc.c      |   48 ++++++++++++++-------
>  drivers/gpu/drm/ttm/ttm_page_alloc_dma.c  |   55 +++++++++++++++---------
>  drivers/md/dm-bufio.c                     |   65 +++++++++++++++++++----------
>  drivers/staging/android/ashmem.c          |   44 ++++++++++++-------
>  drivers/staging/android/lowmemorykiller.c |   60 +++++++++++++++++---------
>  drivers/staging/ramster/zcache-main.c     |   58 ++++++++++++++++++-------
>  drivers/staging/zcache/zcache-main.c      |   40 ++++++++++--------
>  9 files changed, 297 insertions(+), 141 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/i915_dma.c b/drivers/gpu/drm/i915/i915_dma.c
> index 61ae104..0ddec32 100644
> --- a/drivers/gpu/drm/i915/i915_dma.c
> +++ b/drivers/gpu/drm/i915/i915_dma.c
> @@ -1658,7 +1658,7 @@ int i915_driver_load(struct drm_device *dev, unsigned long flags)
>  	return 0;
>  
>  out_gem_unload:
> -	if (dev_priv->mm.inactive_shrinker.shrink)
> +	if (dev_priv->mm.inactive_shrinker.scan_objects)
>  		unregister_shrinker(&dev_priv->mm.inactive_shrinker);
>  
>  	if (dev->pdev->msi_enabled)
> @@ -1695,7 +1695,7 @@ int i915_driver_unload(struct drm_device *dev)
>  
>  	i915_teardown_sysfs(dev);
>  
> -	if (dev_priv->mm.inactive_shrinker.shrink)
> +	if (dev_priv->mm.inactive_shrinker.scan_objects)
>  		unregister_shrinker(&dev_priv->mm.inactive_shrinker);
>  
>  	mutex_lock(&dev->struct_mutex);
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index 107f09b..ceab752 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -53,8 +53,10 @@ static void i915_gem_object_update_fence(struct drm_i915_gem_object *obj,
>  					 struct drm_i915_fence_reg *fence,
>  					 bool enable);
>  
> -static int i915_gem_inactive_shrink(struct shrinker *shrinker,
> +static long i915_gem_inactive_count(struct shrinker *shrinker,
>  				    struct shrink_control *sc);
> +static long i915_gem_inactive_scan(struct shrinker *shrinker,
> +				   struct shrink_control *sc);
>  static long i915_gem_purge(struct drm_i915_private *dev_priv, long target);
>  static void i915_gem_shrink_all(struct drm_i915_private *dev_priv);
>  static void i915_gem_object_truncate(struct drm_i915_gem_object *obj);
> @@ -4197,7 +4199,8 @@ i915_gem_load(struct drm_device *dev)
>  
>  	dev_priv->mm.interruptible = true;
>  
> -	dev_priv->mm.inactive_shrinker.shrink = i915_gem_inactive_shrink;
> +	dev_priv->mm.inactive_shrinker.count_objects = i915_gem_inactive_count;
> +	dev_priv->mm.inactive_shrinker.scan_objects = i915_gem_inactive_scan;
>  	dev_priv->mm.inactive_shrinker.seeks = DEFAULT_SEEKS;
>  	register_shrinker(&dev_priv->mm.inactive_shrinker);
>  }
> @@ -4407,35 +4410,64 @@ void i915_gem_release(struct drm_device *dev, struct drm_file *file)
>  	spin_unlock(&file_priv->mm.lock);
>  }
>  
> -static int
> -i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
> +/*
> + * XXX: (dchinner) This is one of the worst cases of shrinker abuse I've seen.
> + *
> + * i915_gem_purge() expects a byte count to be passed, and the minimum object
> + * size is PAGE_SIZE. The shrinker doesn't work on bytes - it works on
> + * *objects*. So it passes a nr_to_scan of 128 objects, which is interpreted
> + * here to mean "free 128 bytes". That means a single object will be freed, as
> + * the minimum object size is a page.
> + *
> + * But the craziest part comes when i915_gem_purge() has walked all the objects
> + * and can't free any memory. That results in i915_gem_shrink_all() being
> + * called, which idles the GPU and frees everything the driver has in it's
> + * active and inactive lists. It's basically hitting the driver with a great big
> + * hammer because it was busy doing stuff when something else generated memory
> + * pressure. This doesn't seem particularly wise...
> + */
> +static long
> +i915_gem_inactive_scan(struct shrinker *shrinker, struct shrink_control *sc)
>  {
>  	struct drm_i915_private *dev_priv =
>  		container_of(shrinker,
>  			     struct drm_i915_private,
>  			     mm.inactive_shrinker);
>  	struct drm_device *dev = dev_priv->dev;
> -	struct drm_i915_gem_object *obj;
> -	int nr_to_scan = sc->nr_to_scan;
> -	int cnt;
> +	long freed = 0;
>  
>  	if (!mutex_trylock(&dev->struct_mutex))
>  		return 0;
>  
> -	if (nr_to_scan) {
> -		nr_to_scan -= i915_gem_purge(dev_priv, nr_to_scan);
> -		if (nr_to_scan > 0)
> -			i915_gem_shrink_all(dev_priv);
> -	}
> +	freed = i915_gem_purge(dev_priv, sc->nr_to_scan);
> +	if (freed < sc->nr_to_scan)
> +		i915_gem_shrink_all(dev_priv);
> +
> +	mutex_unlock(&dev->struct_mutex);
> +	return freed;
> +}
> +
> +static long
> +i915_gem_inactive_count(struct shrinker *shrinker, struct shrink_control *sc)
> +{
> +	struct drm_i915_private *dev_priv =
> +		container_of(shrinker,
> +			     struct drm_i915_private,
> +			     mm.inactive_shrinker);
> +	struct drm_device *dev = dev_priv->dev;
> +	struct drm_i915_gem_object *obj;
> +	long count = 0;
> +
> +	if (!mutex_trylock(&dev->struct_mutex))
> +		return 0;
>  
> -	cnt = 0;
>  	list_for_each_entry(obj, &dev_priv->mm.unbound_list, gtt_list)
>  		if (obj->pages_pin_count == 0)
> -			cnt += obj->base.size >> PAGE_SHIFT;
> +			count += obj->base.size >> PAGE_SHIFT;
>  	list_for_each_entry(obj, &dev_priv->mm.bound_list, gtt_list)
>  		if (obj->pin_count == 0 && obj->pages_pin_count == 0)
> -			cnt += obj->base.size >> PAGE_SHIFT;
> +			count += obj->base.size >> PAGE_SHIFT;
>  
>  	mutex_unlock(&dev->struct_mutex);
> -	return cnt;
> +	return count;
>  }
> diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
> index bd2a3b4..83058a2 100644
> --- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
> +++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
> @@ -377,28 +377,28 @@ out:
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
>  /**
>   * Callback for mm to request pool to reduce number of page held.
> + *
> + * XXX: (dchinner) Deadlock warning!
> + *
> + * ttm_page_pool_free() does memory allocation using GFP_KERNEL.  that means
> + * this can deadlock when called a sc->gfp_mask that is not equal to
> + * GFP_KERNEL.
> + *
> + * This code is crying out for a shrinker per pool....
>   */
> -static int ttm_pool_mm_shrink(struct shrinker *shrink,
> -			      struct shrink_control *sc)
> +static long
> +ttm_pool_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)

Please don't change the style.
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
> @@ -408,14 +408,30 @@ static int ttm_pool_mm_shrink(struct shrinker *shrink,
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
> +ttm_pool_shrink_count(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)

Please don't change the style. Why did you move it down?

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
> index b8b3943..b3b4f99 100644
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
> @@ -1002,18 +989,31 @@ EXPORT_SYMBOL_GPL(ttm_dma_unpopulate);
>  
>  /**
>   * Callback for mm to request pool to reduce number of page held.
> + *
> + * XXX: (dchinner) Deadlock warning!
> + *
> + * ttm_dma_page_pool_free() does GFP_KERNEL memory allocation, and so attention
> + * needs to be paid to sc->gfp_mask to determine if this can be done or not.
> + * GFP_KERNEL memory allocation in a GFP_ATOMIC reclaim context woul dbe really

would be
> + * bad.

It could use (ttm_dma_page_pool_free) use GFP_ATOMIC as the allocation is
just for an array of pages (so that we can iterate over all of the them
in the list and find the candidates). At the end of the
ttm_dma_page_pool_free it ends up freeing it.

The same treatment can be applied to the  ttm_page_pool_free.
> + *
> + * I'm getting sadder as I hear more pathetical whimpers about needing per-pool
> + * shrinkers

I am not entirely clear how this comment is useful in the code?
>   */
> -static int ttm_dma_pool_mm_shrink(struct shrinker *shrink,
> -				  struct shrink_control *sc)
> +static long
> +ttm_dma_pool_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
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
> +		return -1;

Could there be a set of #defines for these values?
>  
>  	mutex_lock(&_manager->lock);
>  	pool_offset = pool_offset % _manager->npools;
> @@ -1029,18 +1029,35 @@ static int ttm_dma_pool_mm_shrink(struct shrinker *shrink,
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
> +
> +static long
> +ttm_dma_pool_shrink_count(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)

Again, please don't change the styleguide and also why move the code?

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
>  
>  static void ttm_dma_pool_mm_shrink_init(struct ttm_pool_manager *manager)
>  {
> -	manager->mm_shrink.shrink = &ttm_dma_pool_mm_shrink;
> +	manager->mm_shrink.count_objects = &ttm_dma_pool_shrink_count;
> +	manager->mm_shrink.scan_objects = &ttm_dma_pool_shrink_scan;
>  	manager->mm_shrink.seeks = 1;
>  	register_shrinker(&manager->mm_shrink);
>  }
> diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
> index 651ca79..0898bf5 100644
> --- a/drivers/md/dm-bufio.c
> +++ b/drivers/md/dm-bufio.c
> @@ -1359,62 +1359,80 @@ static int __cleanup_old_buffer(struct dm_buffer *b, gfp_t gfp,
>  				unsigned long max_jiffies)
>  {
>  	if (jiffies - b->last_accessed < max_jiffies)
> -		return 1;
> +		return 0;
>  
>  	if (!(gfp & __GFP_IO)) {
>  		if (test_bit(B_READING, &b->state) ||
>  		    test_bit(B_WRITING, &b->state) ||
>  		    test_bit(B_DIRTY, &b->state))
> -			return 1;
> +			return 0;
>  	}
>  
>  	if (b->hold_count)
> -		return 1;
> +		return 0;
>  
>  	__make_buffer_clean(b);
>  	__unlink_buffer(b);
>  	__free_buffer_wake(b);
>  
> -	return 0;
> +	return 1;
>  }
>  
> -static void __scan(struct dm_bufio_client *c, unsigned long nr_to_scan,
> -		   struct shrink_control *sc)
> +static long __scan(struct dm_bufio_client *c, unsigned long nr_to_scan,
> +		   gfp_t gfp_mask)
>  {
>  	int l;
>  	struct dm_buffer *b, *tmp;
> +	long freed = 0;
>  
>  	for (l = 0; l < LIST_SIZE; l++) {
> -		list_for_each_entry_safe_reverse(b, tmp, &c->lru[l], lru_list)
> -			if (!__cleanup_old_buffer(b, sc->gfp_mask, 0) &&
> -			    !--nr_to_scan)
> -				return;
> +		list_for_each_entry_safe_reverse(b, tmp, &c->lru[l], lru_list) {
> +			freed += __cleanup_old_buffer(b, gfp_mask, 0);
> +			if (!--nr_to_scan)
> +				break;
> +		}
>  		dm_bufio_cond_resched();
>  	}
> +	return freed;
>  }
>  
> -static int shrink(struct shrinker *shrinker, struct shrink_control *sc)
> +static long
> +dm_bufio_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
>  {
>  	struct dm_bufio_client *c =
> -	    container_of(shrinker, struct dm_bufio_client, shrinker);
> -	unsigned long r;
> -	unsigned long nr_to_scan = sc->nr_to_scan;
> +	    container_of(shrink, struct dm_bufio_client, shrinker);
> +	long freed;
>  
>  	if (sc->gfp_mask & __GFP_IO)
>  		dm_bufio_lock(c);
>  	else if (!dm_bufio_trylock(c))
> -		return !nr_to_scan ? 0 : -1;
> +		return -1;
>  
> -	if (nr_to_scan)
> -		__scan(c, nr_to_scan, sc);
> +	freed  = __scan(c, sc->nr_to_scan, sc->gfp_mask);
> +	dm_bufio_unlock(c);
> +	return freed;
> +}
>  
> -	r = c->n_buffers[LIST_CLEAN] + c->n_buffers[LIST_DIRTY];
> -	if (r > INT_MAX)
> -		r = INT_MAX;
> +static long
> +dm_bufio_shrink_count(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
> +{
> +	struct dm_bufio_client *c =
> +	    container_of(shrink, struct dm_bufio_client, shrinker);
> +	long count;
> +
> +	if (sc->gfp_mask & __GFP_IO)
> +		dm_bufio_lock(c);
> +	else if (!dm_bufio_trylock(c))
> +		return 0;
>  
> +	count = c->n_buffers[LIST_CLEAN] + c->n_buffers[LIST_DIRTY];
>  	dm_bufio_unlock(c);
> +	return count;
>  
> -	return r;
>  }
>  
>  /*
> @@ -1516,7 +1534,8 @@ struct dm_bufio_client *dm_bufio_client_create(struct block_device *bdev, unsign
>  	__cache_size_refresh();
>  	mutex_unlock(&dm_bufio_clients_lock);
>  
> -	c->shrinker.shrink = shrink;
> +	c->shrinker.count_objects = dm_bufio_shrink_count;
> +	c->shrinker.scan_objects = dm_bufio_shrink_scan;
>  	c->shrinker.seeks = 1;
>  	c->shrinker.batch = 0;
>  	register_shrinker(&c->shrinker);
> @@ -1603,7 +1622,7 @@ static void cleanup_old_buffers(void)
>  			struct dm_buffer *b;
>  			b = list_entry(c->lru[LIST_CLEAN].prev,
>  				       struct dm_buffer, lru_list);
> -			if (__cleanup_old_buffer(b, 0, max_age * HZ))
> +			if (!__cleanup_old_buffer(b, 0, max_age * HZ))
>  				break;
>  			dm_bufio_cond_resched();
>  		}
> diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
> index 634b9ae..30f9f8e 100644
> --- a/drivers/staging/android/ashmem.c
> +++ b/drivers/staging/android/ashmem.c
> @@ -341,27 +341,28 @@ out:
>  /*
>   * ashmem_shrink - our cache shrinker, called from mm/vmscan.c :: shrink_slab
>   *
> - * 'nr_to_scan' is the number of objects (pages) to prune, or 0 to query how
> - * many objects (pages) we have in total.
> + * 'nr_to_scan' is the number of objects to scan for freeing.
>   *
>   * 'gfp_mask' is the mask of the allocation that got us into this mess.
>   *
> - * Return value is the number of objects (pages) remaining, or -1 if we cannot
> + * Return value is the number of objects freed or -1 if we cannot
>   * proceed without risk of deadlock (due to gfp_mask).
>   *
>   * We approximate LRU via least-recently-unpinned, jettisoning unpinned partial
>   * chunks of ashmem regions LRU-wise one-at-a-time until we hit 'nr_to_scan'
>   * pages freed.
>   */
> -static int ashmem_shrink(struct shrinker *s, struct shrink_control *sc)
> +static long
> +ashmem_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
>  {
>  	struct ashmem_range *range, *next;
> +	long freed = 0;
>  
>  	/* We might recurse into filesystem code, so bail out if necessary */
> -	if (sc->nr_to_scan && !(sc->gfp_mask & __GFP_FS))
> +	if (!(sc->gfp_mask & __GFP_FS))
>  		return -1;
> -	if (!sc->nr_to_scan)
> -		return lru_count;
>  
>  	mutex_lock(&ashmem_mutex);
>  	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
> @@ -374,17 +375,34 @@ static int ashmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  		range->purged = ASHMEM_WAS_PURGED;
>  		lru_del(range);
>  
> -		sc->nr_to_scan -= range_size(range);
> -		if (sc->nr_to_scan <= 0)
> +		freed += range_size(range);
> +		if (--sc->nr_to_scan <= 0)
>  			break;
>  	}
>  	mutex_unlock(&ashmem_mutex);
> +	return freed;
> +}
>  
> +static long
> +ashmem_shrink_count(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
> +{
> +	/*
> +	 * note that lru_count is count of pages on the lru, not a count of
> +	 * objects on the list. This means the scan function needs to return the
> +	 * number of pages freed, not the number of objects scanned.
> +	 */
>  	return lru_count;
>  }
>  
>  static struct shrinker ashmem_shrinker = {
> -	.shrink = ashmem_shrink,
> +	.count_objects = ashmem_shrink_count,
> +	.scan_objects = ashmem_shrink_scan,
> +	/*
> +	 * XXX (dchinner): I wish people would comment on why they need on
> +	 * significant changes to the default value here
> +	 */
>  	.seeks = DEFAULT_SEEKS * 4,
>  };
>  
> @@ -671,11 +689,9 @@ static long ashmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  		if (capable(CAP_SYS_ADMIN)) {
>  			struct shrink_control sc = {
>  				.gfp_mask = GFP_KERNEL,
> -				.nr_to_scan = 0,
> +				.nr_to_scan = LONG_MAX,
>  			};
> -			ret = ashmem_shrink(&ashmem_shrinker, &sc);
> -			sc.nr_to_scan = ret;
> -			ashmem_shrink(&ashmem_shrinker, &sc);
> +			ashmem_shrink_scan(&ashmem_shrinker, &sc);
>  		}
>  		break;
>  	}
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> index b91e4bc..2bf2c2f 100644
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -63,11 +63,19 @@ static unsigned long lowmem_deathpending_timeout;
>  			printk(x);			\
>  	} while (0)
>  
> -static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
> +/*
> + * XXX (dchinner): this should all be using longs, not ints, as
> + * functions like global_page_state, get_mm_rss, etc all return longs or
> + * unsigned longs. Even the shrinker now uses longs....
> + */
> +static long
> +lowmem_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
>  {
>  	struct task_struct *tsk;
>  	struct task_struct *selected = NULL;
> -	int rem = 0;
> +	long freed = 0;
>  	int tasksize;
>  	int i;
>  	int min_score_adj = OOM_SCORE_ADJ_MAX + 1;
> @@ -89,19 +97,17 @@ static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  			break;
>  		}
>  	}
> -	if (sc->nr_to_scan > 0)
> -		lowmem_print(3, "lowmem_shrink %lu, %x, ofree %d %d, ma %d\n",
> -				sc->nr_to_scan, sc->gfp_mask, other_free,
> -				other_file, min_score_adj);
> -	rem = global_page_state(NR_ACTIVE_ANON) +
> -		global_page_state(NR_ACTIVE_FILE) +
> -		global_page_state(NR_INACTIVE_ANON) +
> -		global_page_state(NR_INACTIVE_FILE);
> -	if (sc->nr_to_scan <= 0 || min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
> -		lowmem_print(5, "lowmem_shrink %lu, %x, return %d\n",
> -			     sc->nr_to_scan, sc->gfp_mask, rem);
> -		return rem;
> +	lowmem_print(3, "lowmem_shrink %lu, %x, ofree %d %d, ma %d\n",
> +			sc->nr_to_scan, sc->gfp_mask, other_free,
> +			other_file, min_score_adj);
> +
> +	if (min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
> +		/* nothing to do, no point in calling again */
> +		lowmem_print(5, "lowmem_shrink %lu, %x, return -1\n",
> +			     sc->nr_to_scan, sc->gfp_mask);
> +		return -1;
>  	}
> +
>  	selected_oom_score_adj = min_score_adj;
>  
>  	rcu_read_lock();
> @@ -151,16 +157,32 @@ static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  		lowmem_deathpending_timeout = jiffies + HZ;
>  		send_sig(SIGKILL, selected, 0);
>  		set_tsk_thread_flag(selected, TIF_MEMDIE);
> -		rem -= selected_tasksize;
> +		freed += selected_tasksize;
>  	}
> -	lowmem_print(4, "lowmem_shrink %lu, %x, return %d\n",
> -		     sc->nr_to_scan, sc->gfp_mask, rem);
> +	lowmem_print(4, "lowmem_shrink %lu, %x, return %ld\n",
> +		     sc->nr_to_scan, sc->gfp_mask, freed);
>  	rcu_read_unlock();
> -	return rem;
> +	return freed;
> +}
> +
> +static long
> +lowmem_shrink_count(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
> +{
> +	long count;
> +
> +	count = global_page_state(NR_ACTIVE_ANON) +
> +		global_page_state(NR_ACTIVE_FILE) +
> +		global_page_state(NR_INACTIVE_ANON) +
> +		global_page_state(NR_INACTIVE_FILE);
> +	return count;
>  }
>  
>  static struct shrinker lowmem_shrinker = {
> -	.shrink = lowmem_shrink,
> +	.count_objects = lowmem_shrink_count,
> +	.scan_objects = lowmem_shrink_scan,
> +	/* why can't we document magic numbers? */
>  	.seeks = DEFAULT_SEEKS * 16
>  };
>  
> diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
> index a09dd5c..7d50688 100644
> --- a/drivers/staging/ramster/zcache-main.c
> +++ b/drivers/staging/ramster/zcache-main.c
> @@ -1054,12 +1054,13 @@ static bool zcache_freeze;
>   * used by zcache to approximately the same as the total number of LRU_FILE
>   * pageframes in use.
>   */
> -static int shrink_zcache_memory(struct shrinker *shrink,
> -				struct shrink_control *sc)
> +static long
> +zcache_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)

Why the Style changes? If the code has a certain style there is no need
to alter just one function in it to be at odd with the rest.
>  {
>  	static bool in_progress;
> -	int ret = -1;
> -	int nr = sc->nr_to_scan;
> +	long freed = 0;
>  	int nr_evict = 0;
>  	int nr_unuse = 0;
>  	struct page *page;
> @@ -1067,15 +1068,23 @@ static int shrink_zcache_memory(struct shrinker *shrink,
>  	int unuse_ret;
>  #endif
>  
> -	if (nr <= 0)
> -		goto skip_evict;
> +	/*
> +	 * XXX (dchinner): My kingdom for a mutex! There's no way this should
> +	 * ever be allowed to move out of staging until it supports concurrent
> +	 * shrinkers correctly.
> +	 *
> +	 * This whole shrinker is making me want to claw my eyes out. It has no
> +	 * redeeming values whatsoever and I can't undo the damage it has
> +	 * already done to my brain.

I am sad to hear that your brain has been damaged, but I fear that part
of working for open source is that there is no warranty and it can be
hazardous to your health.

How would you add redeeming values here? Perhaps that should
be added in the TODO file in the root directory of the driver. That is
the usual policy that Greg wants.

Is it that you would like to insert a mutex here? The underlaying code
(zcache_evict_eph_pageframe) ends up taking a spinlock.

> +	 */
>  
>  	/* don't allow more than one eviction thread at a time */
>  	if (in_progress)
> -		goto skip_evict;
> +		return -1;
>  
>  	in_progress = true;
>  
> +

Hm..
>  	/* we are going to ignore nr, and target a different value */
>  	zcache_last_active_file_pageframes =
>  		global_page_state(NR_LRU_BASE + LRU_ACTIVE_FILE);
> @@ -1083,11 +1092,13 @@ static int shrink_zcache_memory(struct shrinker *shrink,
>  		global_page_state(NR_LRU_BASE + LRU_INACTIVE_FILE);
>  	nr_evict = zcache_eph_pageframes - zcache_last_active_file_pageframes +
>  		zcache_last_inactive_file_pageframes;
> +

Hmmm?
>  	while (nr_evict-- > 0) {
>  		page = zcache_evict_eph_pageframe();
>  		if (page == NULL)
>  			break;
>  		zcache_free_page(page);
> +		freed++;
>  	}
>  
>  	zcache_last_active_anon_pageframes =
> @@ -1104,25 +1115,42 @@ static int shrink_zcache_memory(struct shrinker *shrink,
>  		unuse_ret = zcache_frontswap_unuse();
>  		if (unuse_ret == -ENOMEM)
>  			break;
> +		freed++;
>  	}
>  #endif
>  	in_progress = false;
> +	return freed;
> +}
> +
> +
> +/*
> + * XXX (dchinner): the shrinker updates global variables? You've got to be
> + * kidding me! And the object count can (apparently) go negative - that's
> + * *always* a bug so be bloody noisy about it.

The reason for this is that the ramster code shares code with zcache.
The mechanism to find out whether a page has been freed or not is
currently via these counters - which are actually ssize_t so are silly.

Perhaps you could expand the comment to mention a better mechanism for
keeping that value non-global and atomic?

> + */
> +static long
> +zcache_shrink_count(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)

Please, not style guide changes.

> +{
> +	long count;
>  
> -skip_evict:
> -	/* resample: has changed, but maybe not all the way yet */
>  	zcache_last_active_file_pageframes =
>  		global_page_state(NR_LRU_BASE + LRU_ACTIVE_FILE);
>  	zcache_last_inactive_file_pageframes =
>  		global_page_state(NR_LRU_BASE + LRU_INACTIVE_FILE);
> -	ret = zcache_eph_pageframes - zcache_last_active_file_pageframes +
> -		zcache_last_inactive_file_pageframes;
> -	if (ret < 0)
> -		ret = 0;
> -	return ret;
> +
> +	count = zcache_last_active_file_pageframes +
> +		zcache_last_inactive_file_pageframes +
> +		zcache_eph_pageframes;

Why not just use the 'free' value?
> +
> +	WARN_ON_ONCE(count < 0);
> +	return count < 0 ? 0 : count;
>  }
>  
>  static struct shrinker zcache_shrinker = {
> -	.shrink = shrink_zcache_memory,
> +	.count_objects = zcache_shrink_count,
> +	.scan_objects = zcache_shrink_scan,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 52b43b7..d17ab5d 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c

What Linux version is this based on? I am not seeing this in v3.10-rc4 ?

> @@ -536,10 +536,11 @@ static void zbud_evict_zbpg(struct zbud_page *zbpg)
>   * page in use by another cpu, but also to avoid potential deadlock due to
>   * lock inversion.
>   */
> -static void zbud_evict_pages(int nr)
> +static long zbud_evict_pages(int nr)
>  {
>  	struct zbud_page *zbpg;
>  	int i;
> +	long freed = 0;
>  
>  	/* first try freeing any pages on unused list */
>  retry_unused_list:
> @@ -554,6 +555,7 @@ retry_unused_list:
>  		spin_unlock_bh(&zbpg_unused_list_spinlock);
>  		zcache_free_page(zbpg);
>  		zcache_evicted_raw_pages++;
> +		freed++;
>  		if (--nr <= 0)
>  			goto out;
>  		goto retry_unused_list;
> @@ -578,6 +580,7 @@ retry_unbud_list_i:
>  			/* want budlists unlocked when doing zbpg eviction */
>  			zbud_evict_zbpg(zbpg);
>  			local_bh_enable();
> +			freed++;
>  			if (--nr <= 0)
>  				goto out;
>  			goto retry_unbud_list_i;
> @@ -602,13 +605,14 @@ retry_bud_list:
>  		/* want budlists unlocked when doing zbpg eviction */
>  		zbud_evict_zbpg(zbpg);
>  		local_bh_enable();
> +		freed++;
>  		if (--nr <= 0)
>  			goto out;
>  		goto retry_bud_list;
>  	}
>  	spin_unlock_bh(&zbud_budlists_spinlock);
>  out:
> -	return;
> +	return freed;
>  }
>  
>  static void __init zbud_init(void)
> @@ -1527,26 +1531,28 @@ static bool zcache_freeze;
>  /*
>   * zcache shrinker interface (only useful for ephemeral pages, so zbud only)
>   */
> -static int shrink_zcache_memory(struct shrinker *shrink,
> -				struct shrink_control *sc)
> +static long
> +zcache_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)

Please, no style guide changes.
>  {
> -	int ret = -1;
> -	int nr = sc->nr_to_scan;
> -	gfp_t gfp_mask = sc->gfp_mask;
> +	if (!(sc->gfp_mask & __GFP_FS))
> +		return -1;
>  
> -	if (nr >= 0) {
> -		if (!(gfp_mask & __GFP_FS))
> -			/* does this case really need to be skipped? */
> -			goto out;
> -		zbud_evict_pages(nr);
> -	}
> -	ret = (int)atomic_read(&zcache_zbud_curr_raw_pages);
> -out:
> -	return ret;
> +	return zbud_evict_pages(sc->nr_to_scan);
> +}
> +
> +static long
> +zcache_shrink_count(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
> +{
> +	return (long)atomic_read(&zcache_zbud_curr_raw_pages);
>  }
>  
>  static struct shrinker zcache_shrinker = {
> -	.shrink = shrink_zcache_memory,
> +	.count_objects = zcache_shrink_count,
> +	.scan_objects = zcache_shrink_scan,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> -- 
> 1.7.10
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
