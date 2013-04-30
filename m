Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B82196B0147
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 17:54:03 -0400 (EDT)
Date: Tue, 30 Apr 2013 22:53:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 17/31] drivers: convert shrinkers to new count/scan API
Message-ID: <20130430215355.GN6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-18-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-18-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Kent Overstreet <koverstreet@google.com>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On Sat, Apr 27, 2013 at 03:19:13AM +0400, Glauber Costa wrote:
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
> 
> Special mention goes to the zcache/zcache2 drivers. They can't
> co-exist in the build at the same time, they are under different
> menu options in menuconfig, they only show up when you've got the
> right set of mm subsystem options configured and so even compile
> testing is an exercise in pulling teeth.  And that doesn't even take
> into account the horrible, broken code...
> 
> [ glommer: fixes for i915, android lowmem, zcache, bcache ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>

Mostly glancing through. For this patch, double check where I asked
about -1's because I think some of the scanners are returning 0 when it
should be -1. Other comments on the shrinkers are drive-by comments.
Affected maintainers are now on the cc which should probably be aware of
this patch.

> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index 6be940e..2e44733 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -1729,15 +1731,20 @@ i915_gem_purge(struct drm_i915_private *dev_priv, long target)
>  	return __i915_gem_shrink(dev_priv, target, true);
>  }
>  
> -static void
> +static long
>  i915_gem_shrink_all(struct drm_i915_private *dev_priv)
>  {
>  	struct drm_i915_gem_object *obj, *next;
> +	long freed = 0;
>  
> -	i915_gem_evict_everything(dev_priv->dev);
> +	freed += i915_gem_evict_everything(dev_priv->dev);
>  
> -	list_for_each_entry_safe(obj, next, &dev_priv->mm.unbound_list, gtt_list)
> +	list_for_each_entry_safe(obj, next, &dev_priv->mm.unbound_list, gtt_list) {
> +		if (obj->pages_pin_count == 0)
> +			freed += obj->base.size >> PAGE_SHIFT;
>  		i915_gem_object_put_pages(obj);
> +	}
> +	return freed;
>  }
>  

i915_gem_shrink_all is a sledge hammer! That i915_gem_evict_everything
looks like it switches to every GPU context, waits for everything to
complete and then retire it all. I don't know the details of what it's
doing but it's sounds very heavy handed and is called from shrinker
context if it fails to shrink 128 objects. Those shrinker callsback can
be very frequently called even from kswapd. 

>  static int
> @@ -4205,7 +4212,8 @@ i915_gem_load(struct drm_device *dev)
>  
>  	dev_priv->mm.interruptible = true;
>  
> -	dev_priv->mm.inactive_shrinker.shrink = i915_gem_inactive_shrink;
> +	dev_priv->mm.inactive_shrinker.scan_objects = i915_gem_inactive_scan;
> +	dev_priv->mm.inactive_shrinker.count_objects = i915_gem_inactive_count;
>  	dev_priv->mm.inactive_shrinker.seeks = DEFAULT_SEEKS;
>  	register_shrinker(&dev_priv->mm.inactive_shrinker);
>  }
> @@ -4428,8 +4436,8 @@ static bool mutex_is_locked_by(struct mutex *mutex, struct task_struct *task)
>  #endif
>  }
>  
> -static int
> -i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
> +static long
> +i915_gem_inactive_count(struct shrinker *shrinker, struct shrink_control *sc)
>  {
>  	struct drm_i915_private *dev_priv =
>  		container_of(shrinker,
> @@ -4437,9 +4445,8 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>  			     mm.inactive_shrinker);
>  	struct drm_device *dev = dev_priv->dev;
>  	struct drm_i915_gem_object *obj;
> -	int nr_to_scan = sc->nr_to_scan;
>  	bool unlock = true;
> -	int cnt;
> +	long cnt;
>  
>  	if (!mutex_trylock(&dev->struct_mutex)) {
>  		if (!mutex_is_locked_by(&dev->struct_mutex, current))
> @@ -4451,15 +4458,6 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>  		unlock = false;
>  	}
>  
> -	if (nr_to_scan) {
> -		nr_to_scan -= i915_gem_purge(dev_priv, nr_to_scan);
> -		if (nr_to_scan > 0)
> -			nr_to_scan -= __i915_gem_shrink(dev_priv, nr_to_scan,
> -							false);
> -		if (nr_to_scan > 0)
> -			i915_gem_shrink_all(dev_priv);
> -	}
> -
>  	cnt = 0;
>  	list_for_each_entry(obj, &dev_priv->mm.unbound_list, gtt_list)
>  		if (obj->pages_pin_count == 0)
> @@ -4472,3 +4470,36 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>  		mutex_unlock(&dev->struct_mutex);
>  	return cnt;
>  }
> +static long
> +i915_gem_inactive_scan(struct shrinker *shrinker, struct shrink_control *sc)
> +{
> +	struct drm_i915_private *dev_priv =
> +		container_of(shrinker,
> +			     struct drm_i915_private,
> +			     mm.inactive_shrinker);
> +	struct drm_device *dev = dev_priv->dev;
> +	int nr_to_scan = sc->nr_to_scan;
> +	long freed;
> +	bool unlock = true;
> +
> +	if (!mutex_trylock(&dev->struct_mutex)) {
> +		if (!mutex_is_locked_by(&dev->struct_mutex, current))
> +			return 0;
> +

return -1 if it's about preventing potential deadlocks?

> +		if (dev_priv->mm.shrinker_no_lock_stealing)
> +			return 0;
> +

same?

> +		unlock = false;
> +	}
> +
> +	freed = i915_gem_purge(dev_priv, nr_to_scan);
> +	if (freed < nr_to_scan)
> +		freed += __i915_gem_shrink(dev_priv, nr_to_scan,
> +							false);
> +	if (freed < nr_to_scan)
> +		freed += i915_gem_shrink_all(dev_priv);
> +

Do we *really* want to call i915_gem_shrink_all from the slab shrinker?
Are there any bug reports where i915 rendering jitters in low memory
situations while shrinkers might be active? Maybe it's really fast.

> +	if (unlock)
> +		mutex_unlock(&dev->struct_mutex);
> +	return freed;
> +}
> diff --git a/drivers/gpu/drm/i915/i915_gem_evict.c b/drivers/gpu/drm/i915/i915_gem_evict.c
> index c86d5d9..e379340 100644
> --- a/drivers/gpu/drm/i915/i915_gem_evict.c
> +++ b/drivers/gpu/drm/i915/i915_gem_evict.c
> @@ -150,13 +150,13 @@ found:
>  	return ret;
>  }
>  
> -int
> +long
>  i915_gem_evict_everything(struct drm_device *dev)
>  {
>  	drm_i915_private_t *dev_priv = dev->dev_private;
>  	struct drm_i915_gem_object *obj, *next;
>  	bool lists_empty;
> -	int ret;
> +	long ret = 0;
>  
>  	lists_empty = (list_empty(&dev_priv->mm.inactive_list) &&
>  		       list_empty(&dev_priv->mm.active_list));
> @@ -178,8 +178,10 @@ i915_gem_evict_everything(struct drm_device *dev)
>  	/* Having flushed everything, unbind() should never raise an error */
>  	list_for_each_entry_safe(obj, next,
>  				 &dev_priv->mm.inactive_list, mm_list)
> -		if (obj->pin_count == 0)
> +		if (obj->pin_count == 0) {
> +			ret += obj->base.size >> PAGE_SHIFT;
>  			WARN_ON(i915_gem_object_unbind(obj));
> +		}
>  
> -	return 0;
> +	return ret;
>  }
> diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
> index 117ce38..da0017a 100644
> --- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
> +++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
> @@ -566,7 +566,7 @@ err:		/* Decrement pin count for bound objects */
>  			return ret;
>  
>  		ret = i915_gem_evict_everything(ring->dev);
> -		if (ret)
> +		if (ret < 0)
>  			return ret;
>  	} while (1);
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

Yep, direct reclaimers potentially hit this. Options include using
kmalloc atomic and falling back to a very small on-stack array or a lump
hammer like declaring a per-cpu buffer similar to what pagevecs do.

> -static int ttm_pool_mm_shrink(struct shrinker *shrink,
> -			      struct shrink_control *sc)
> +static long
> +ttm_pool_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
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
> + * bad.
> + *
> + * I'm getting sadder as I hear more pathetical whimpers about needing per-pool
> + * shrinkers
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
> diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
> index 03e44c1..8b9c1a6 100644
> --- a/drivers/md/bcache/btree.c
> +++ b/drivers/md/bcache/btree.c
> @@ -599,11 +599,12 @@ static int mca_reap(struct btree *b, struct closure *cl, unsigned min_order)
>  	return 0;
>  }
>  
> -static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
> +static long bch_mca_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
>  	struct btree *b, *t;
>  	unsigned long i, nr = sc->nr_to_scan;
> +	long freed = 0;
>  
>  	if (c->shrinker_disabled)
>  		return 0;

-1 if shrinker disabled?

Otherwise if the shrinker is disabled we ultimately hit this loop in
shrink_slab_one()

do {
	ret = shrinker->scan_objects(shrinker, sc);
	if (ret == -1)
		break
	....
        count_vm_events(SLABS_SCANNED, batch_size);
        total_scan -= batch_size;

        cond_resched();
} while (total_scan >= batch_size);

which won't break as such but we busy loop until total_scan drops and
account for SLABS_SCANNED incorrectly.

More using of mutex_lock in here which means that multiple direct reclaimers
will contend on each other. bch_mca_shrink() checks for __GFP_WAIT but an
atomic caller does not direct reclaim so it'll always try and contend.

> @@ -611,12 +612,6 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  	if (c->try_harder)
>  		return 0;
>  
> -	/*
> -	 * If nr == 0, we're supposed to return the number of items we have
> -	 * cached. Not allowed to return -1.
> -	 */
> -	if (!nr)
> -		return mca_can_free(c) * c->btree_pages;
>  
>  	/* Return -1 if we can't do anything right now */
>  	if (sc->gfp_mask & __GFP_WAIT)
> @@ -629,14 +624,14 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  
>  	i = 0;
>  	list_for_each_entry_safe(b, t, &c->btree_cache_freeable, list) {
> -		if (!nr)
> +		if (freed >= nr)
>  			break;
>  
>  		if (++i > 3 &&
>  		    !mca_reap(b, NULL, 0)) {
>  			mca_data_free(b);
>  			rw_unlock(true, b);
> -			--nr;
> +			freed++;
>  		}
>  	}
>  
> @@ -647,7 +642,7 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  	if (list_empty(&c->btree_cache))
>  		goto out;
>  
> -	for (i = 0; nr && i < c->bucket_cache_used; i++) {
> +	for (i = 0; i < c->bucket_cache_used; i++) {
>  		b = list_first_entry(&c->btree_cache, struct btree, list);
>  		list_rotate_left(&c->btree_cache);
>  
> @@ -656,14 +651,20 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  			mca_bucket_free(b);
>  			mca_data_free(b);
>  			rw_unlock(true, b);
> -			--nr;
> +			freed++;
>  		} else
>  			b->accessed = 0;
>  	}
>  out:
> -	nr = mca_can_free(c) * c->btree_pages;
>  	mutex_unlock(&c->bucket_lock);
> -	return nr;
> +	return freed;
> +}
> +
> +static long bch_mca_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
> +
> +	return mca_can_free(c) * c->btree_pages;
>  }
>  
>  void bch_btree_cache_free(struct cache_set *c)
> @@ -732,7 +733,8 @@ int bch_btree_cache_alloc(struct cache_set *c)
>  		c->verify_data = NULL;
>  #endif
>  
> -	c->shrink.shrink = bch_mca_shrink;
> +	c->shrink.count_objects = bch_mca_count;
> +	c->shrink.scan_objects = bch_mca_scan;
>  	c->shrink.seeks = 4;
>  	c->shrink.batch = c->btree_pages * 2;
>  	register_shrinker(&c->shrink);
> diff --git a/drivers/md/bcache/sysfs.c b/drivers/md/bcache/sysfs.c
> index 4d9cca4..fa8d048 100644
> --- a/drivers/md/bcache/sysfs.c
> +++ b/drivers/md/bcache/sysfs.c
> @@ -535,7 +535,7 @@ STORE(__bch_cache_set)
>  		struct shrink_control sc;
>  		sc.gfp_mask = GFP_KERNEL;
>  		sc.nr_to_scan = strtoul_or_return(buf);
> -		c->shrink.shrink(&c->shrink, &sc);
> +		c->shrink.scan_objects(&c->shrink, &sc);
>  	}
>  
>  	sysfs_strtoul(congested_read_threshold_us,
> diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
> index 6f1b57a..59b6082 100644
> --- a/drivers/md/dm-bufio.c
> +++ b/drivers/md/dm-bufio.c
> @@ -1361,62 +1361,80 @@ static int __cleanup_old_buffer(struct dm_buffer *b, gfp_t gfp,
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
> @@ -1518,7 +1536,8 @@ struct dm_bufio_client *dm_bufio_client_create(struct block_device *bdev, unsign
>  	__cache_size_refresh();
>  	mutex_unlock(&dm_bufio_clients_lock);
>  
> -	c->shrinker.shrink = shrink;
> +	c->shrinker.count_objects = dm_bufio_shrink_count;
> +	c->shrinker.scan_objects = dm_bufio_shrink_scan;
>  	c->shrinker.seeks = 1;
>  	c->shrinker.batch = 0;
>  	register_shrinker(&c->shrinker);
> @@ -1605,7 +1624,7 @@ static void cleanup_old_buffers(void)
>  			struct dm_buffer *b;
>  			b = list_entry(c->lru[LIST_CLEAN].prev,
>  				       struct dm_buffer, lru_list);
> -			if (__cleanup_old_buffer(b, 0, max_age * HZ))
> +			if (!__cleanup_old_buffer(b, 0, max_age * HZ))
>  				break;
>  			dm_bufio_cond_resched();
>  		}
> diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
> index 3240d34..951d944 100644
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
> @@ -690,14 +708,11 @@ static long ashmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  		if (capable(CAP_SYS_ADMIN)) {
>  			struct shrink_control sc = {
>  				.gfp_mask = GFP_KERNEL,
> -				.nr_to_scan = 0,
> +				.nr_to_scan = LONG_MAX,
>  			};
>  
>  			nodes_setall(sc.nodes_to_scan);
> -
> -			ret = ashmem_shrink(&ashmem_shrinker, &sc);
> -			sc.nr_to_scan = ret;
> -			ashmem_shrink(&ashmem_shrinker, &sc);
> +			ashmem_shrink_scan(&ashmem_shrinker, &sc);
>  		}
>  		break;
>  	}
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> index fe74494..d23bfea 100644
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -66,7 +66,15 @@ static unsigned long lowmem_deathpending_timeout;
>  			pr_info(x);			\
>  	} while (0)
>  
> -static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
> +static long lowmem_count(struct shrinker *s, struct shrink_control *sc)
> +{
> +	return global_page_state(NR_ACTIVE_ANON) +
> +		global_page_state(NR_ACTIVE_FILE) +
> +		global_page_state(NR_INACTIVE_ANON) +
> +		global_page_state(NR_INACTIVE_FILE);
> +}
> +
> +static long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
>  {
>  	struct task_struct *tsk;
>  	struct task_struct *selected = NULL;
> @@ -92,19 +100,17 @@ static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  			break;
>  		}
>  	}
> -	if (sc->nr_to_scan > 0)
> -		lowmem_print(3, "lowmem_shrink %lu, %x, ofree %d %d, ma %hd\n",
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
> +
> +	lowmem_print(3, "lowmem_scan %lu, %x, ofree %d %d, ma %hd\n",
> +			sc->nr_to_scan, sc->gfp_mask, other_free,
> +			other_file, min_score_adj);
> +
> +	if (min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
> +		lowmem_print(5, "lowmem_scan %lu, %x, return 0\n",
> +			     sc->nr_to_scan, sc->gfp_mask);
> +		return 0;
>  	}
> +

-1 again?

Otherwise given the really high number that lowmem_count returns (which
is then basically ignored anyway), this thing will just loop for a while
being called by the slab shrinker. It's just a CPU sink if there is
nothing for the shrinker to do.

>  	selected_oom_score_adj = min_score_adj;
>  
>  	rcu_read_lock();
> @@ -154,16 +160,18 @@ static int lowmem_shrink(struct shrinker *s, struct shrink_control *sc)
>  		lowmem_deathpending_timeout = jiffies + HZ;
>  		send_sig(SIGKILL, selected, 0);
>  		set_tsk_thread_flag(selected, TIF_MEMDIE);
> -		rem -= selected_tasksize;
> +		rem += selected_tasksize;
>  	}
> -	lowmem_print(4, "lowmem_shrink %lu, %x, return %d\n",
> +
> +	lowmem_print(4, "lowmem_scan %lu, %x, return %d\n",
>  		     sc->nr_to_scan, sc->gfp_mask, rem);
>  	rcu_read_unlock();
>  	return rem;
>  }
>  
>  static struct shrinker lowmem_shrinker = {
> -	.shrink = lowmem_shrink,
> +	.scan_objects = lowmem_scan,
> +	.count_objects = lowmem_count,
>  	.seeks = DEFAULT_SEEKS * 16
>  };
>  
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 522cb8e..bbfcd4f 100644
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

-1?

Not clear why in_progress is not a static mutex and a trylock because
currently it's a race.

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

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
