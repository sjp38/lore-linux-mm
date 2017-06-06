Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7D4E6B03B0
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:48:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 139so26131130wmf.5
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:48:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si32767364edh.321.2017.06.06.04.48.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 04:48:11 -0700 (PDT)
Date: Tue, 6 Jun 2017 13:48:05 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC] drm/i915: Start writeback from the shrinker
Message-ID: <20170606114805.GK1189@dhcp22.suse.cz>
References: <20170606095634.17989-1-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170606095634.17989-1-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@intel.com>, Matthew Auld <matthew.auld@intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

[CC linux-mm and some mm guys]

On Tue 06-06-17 10:56:34, Chris Wilson wrote:
> When we are called to relieve mempressue via the shrinker, the only way
> we can make progress is either by discarding unwanted pages (those
> objects that userspace has marked MADV_DONTNEED) or by reclaiming the
> dirty objects via swap. As we know that is the only way to make further
> progress, we can initiate the writeback as we invalidate the objects.
> This means the objects we put onto the inactive anon lru list are
> already marked for reclaim+writeback and so will trigger a wait upon the
> writeback inside direct reclaim, greatly improving the success rate of
> direct reclaim on i915 objects.
> 
> The corollary is that we may start a slow swap on opportunistic
> mempressure from the likes of the compaction + migration kthreads. This
> is limited by those threads only being allowed to shrink idle pages, but
> also that if we reactivate the page before it is swapped out by gpu
> activity, we only page the cost of repinning the page. The cost is most
> felt when an object is reused after mempressure, which hopefully
> excludes the latency sensitive tasks (as we are just extending the
> impact of swap thrashing to them).
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
> Cc: Matthew Auld <matthew.auld@intel.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/gpu/drm/i915/i915_drv.h          |  2 +-
>  drivers/gpu/drm/i915/i915_gem.c          | 27 ++--------------
>  drivers/gpu/drm/i915/i915_gem_shrinker.c | 55 +++++++++++++++++++++++++++++++-
>  3 files changed, 57 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
> index c31c0cfe5c20..33ffec1e6c90 100644
> --- a/drivers/gpu/drm/i915/i915_drv.h
> +++ b/drivers/gpu/drm/i915/i915_drv.h
> @@ -3321,7 +3321,7 @@ enum i915_mm_subclass { /* lockdep subclass for obj->mm.lock */
>  
>  void __i915_gem_object_put_pages(struct drm_i915_gem_object *obj,
>  				 enum i915_mm_subclass subclass);
> -void __i915_gem_object_invalidate(struct drm_i915_gem_object *obj);
> +void __i915_gem_object_truncate(struct drm_i915_gem_object *obj);
>  
>  enum i915_map_type {
>  	I915_MAP_WB = 0,
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index 845df6067e90..8cb811519db1 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -2176,8 +2176,7 @@ i915_gem_mmap_gtt_ioctl(struct drm_device *dev, void *data,
>  }
>  
>  /* Immediately discard the backing storage */
> -static void
> -i915_gem_object_truncate(struct drm_i915_gem_object *obj)
> +void __i915_gem_object_truncate(struct drm_i915_gem_object *obj)
>  {
>  	i915_gem_object_free_mmap_offset(obj);
>  
> @@ -2194,28 +2193,6 @@ i915_gem_object_truncate(struct drm_i915_gem_object *obj)
>  	obj->mm.pages = ERR_PTR(-EFAULT);
>  }
>  
> -/* Try to discard unwanted pages */
> -void __i915_gem_object_invalidate(struct drm_i915_gem_object *obj)
> -{
> -	struct address_space *mapping;
> -
> -	lockdep_assert_held(&obj->mm.lock);
> -	GEM_BUG_ON(obj->mm.pages);
> -
> -	switch (obj->mm.madv) {
> -	case I915_MADV_DONTNEED:
> -		i915_gem_object_truncate(obj);
> -	case __I915_MADV_PURGED:
> -		return;
> -	}
> -
> -	if (obj->base.filp == NULL)
> -		return;
> -
> -	mapping = obj->base.filp->f_mapping,
> -	invalidate_mapping_pages(mapping, 0, (loff_t)-1);
> -}
> -
>  static void
>  i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
>  			      struct sg_table *pages)
> @@ -4215,7 +4192,7 @@ i915_gem_madvise_ioctl(struct drm_device *dev, void *data,
>  
>  	/* if the object is no longer attached, discard its backing storage */
>  	if (obj->mm.madv == I915_MADV_DONTNEED && !obj->mm.pages)
> -		i915_gem_object_truncate(obj);
> +		__i915_gem_object_truncate(obj);
>  
>  	args->retained = obj->mm.madv != __I915_MADV_PURGED;
>  	mutex_unlock(&obj->mm.lock);
> diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> index 58f27369183c..026500ad6d35 100644
> --- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
> +++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> @@ -122,6 +122,59 @@ static bool unsafe_drop_pages(struct drm_i915_gem_object *obj)
>  	return !READ_ONCE(obj->mm.pages);
>  }
>  
> +static void __start_writeback(struct drm_i915_gem_object *obj)
> +{
> +	struct address_space *mapping;
> +	struct writeback_control wbc = {
> +		.sync_mode = WB_SYNC_NONE,
> +		.nr_to_write = SWAP_CLUSTER_MAX,
> +		.range_start = 0,
> +		.range_end = LLONG_MAX,
> +		.for_reclaim = 1,
> +	};
> +	unsigned long i;
> +
> +	lockdep_assert_held(&obj->mm.lock);
> +	GEM_BUG_ON(obj->mm.pages);
> +
> +	switch (obj->mm.madv) {
> +	case I915_MADV_DONTNEED:
> +		__i915_gem_object_truncate(obj);
> +	case __I915_MADV_PURGED:
> +		return;
> +	}
> +
> +	if (!obj->base.filp)
> +		return;
> +
> +	/* Force any other users of this object to refault */
> +	mapping = obj->base.filp->f_mapping;
> +	unmap_mapping_range(mapping, 0, (loff_t)-1, 0);
> +
> +	/* Begin writeback on each dirty page */
> +	for (i = 0; i < obj->base.size >> PAGE_SHIFT; i++) {
> +		struct page *page;
> +
> +		page = find_lock_entry(mapping, i);
> +		if (radix_tree_exceptional_entry(page))
> +			continue;
> +
> +		if (!page_mapped(page) && clear_page_dirty_for_io(page)) {
> +			int ret;
> +
> +			SetPageReclaim(page);
> +			ret = mapping->a_ops->writepage(page, &wbc);
> +			if (!PageWriteback(page))
> +				ClearPageReclaim(page);
> +			if (!ret)
> +				goto put;
> +		}
> +		unlock_page(page);
> +put:
> +		put_page(page);
> +	}
> +}
> +
>  /**
>   * i915_gem_shrink - Shrink buffer object caches
>   * @dev_priv: i915 device
> @@ -234,7 +287,7 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
>  				mutex_lock_nested(&obj->mm.lock,
>  						  I915_MM_SHRINKER);
>  				if (!obj->mm.pages) {
> -					__i915_gem_object_invalidate(obj);
> +					__start_writeback(obj);
>  					list_del_init(&obj->global_link);
>  					count += obj->base.size >> PAGE_SHIFT;
>  				}
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
