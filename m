Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3C23B82F82
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:34:06 -0500 (EST)
Received: by wmww144 with SMTP id w144so16265438wmw.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 01:34:05 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id x9si17621284wjf.139.2015.12.10.01.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 01:34:05 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id v187so23483175wmv.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 01:34:04 -0800 (PST)
Date: Thu, 10 Dec 2015 10:34:02 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH v2 2/2] drm/i915: Disable shrinker for non-swapped backed
 objects
Message-ID: <20151210093402.GI20822@phenom.ffwll.local>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <1449244734-25733-2-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449244734-25733-2-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Akash Goel <akash.goel@intel.com>, sourab.gupta@intel.com

On Fri, Dec 04, 2015 at 03:58:54PM +0000, Chris Wilson wrote:
> If the system has no available swap pages, we cannot make forward
> progress in the shrinker by releasing active pages, only by releasing
> purgeable pages which are immediately reaped. Take total_swap_pages into
> account when counting up available objects to be shrunk and subsequently
> shrinking them. By doing so, we avoid unbinding objects that cannot be
> shrunk and so wasting CPU cycles flushing those objects from the GPU to
> the system and then immediately back again (as they will more than
> likely be reused shortly after).
> 
> Based on a patch by Akash Goel.
> 
> v2: frontswap registers extra swap pages available for the system, so it
> is already include in the count of available swap pages.
> 
> v3: Use get_nr_swap_pages() to query the currently available amount of
> swap space. This should also stop us from shrinking the GPU buffers if
> we ever run out of swap space. Though at that point, we would expect the
> oom-notifier to be running and failing miserably...
> 
> Reported-by: Akash Goel <akash.goel@intel.com>
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: linux-mm@kvack.org
> Cc: Akash Goel <akash.goel@intel.com>
> Cc: sourab.gupta@intel.com

Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>

I did wonder whether we shouldn't check this at the top, but this looks
nicer. And if you've run out of memory wasting a bit of cpu won't be a
concern really.
-Daniel

> ---
>  drivers/gpu/drm/i915/i915_gem_shrinker.c | 60 +++++++++++++++++++++++---------
>  1 file changed, 44 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> index f7df54a8ee2b..16da9c1422cc 100644
> --- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
> +++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> @@ -47,6 +47,46 @@ static bool mutex_is_locked_by(struct mutex *mutex, struct task_struct *task)
>  #endif
>  }
>  
> +static int num_vma_bound(struct drm_i915_gem_object *obj)
> +{
> +	struct i915_vma *vma;
> +	int count = 0;
> +
> +	list_for_each_entry(vma, &obj->vma_list, vma_link) {
> +		if (drm_mm_node_allocated(&vma->node))
> +			count++;
> +		if (vma->pin_count)
> +			count++;
> +	}
> +
> +	return count;
> +}
> +
> +static bool swap_available(void)
> +{
> +	return get_nr_swap_pages() > 0;
> +}
> +
> +static bool can_release_pages(struct drm_i915_gem_object *obj)
> +{
> +	/* Only report true if by unbinding the object and putting its pages
> +	 * we can actually make forward progress towards freeing physical
> +	 * pages.
> +	 *
> +	 * If the pages are pinned for any other reason than being bound
> +	 * to the GPU, simply unbinding from the GPU is not going to succeed
> +	 * in releasing our pin count on the pages themselves.
> +	 */
> +	if (obj->pages_pin_count != num_vma_bound(obj))
> +		return false;
> +
> +	/* We can only return physical pages to the system if we can either
> +	 * discard the contents (because the user has marked them as being
> +	 * purgeable) or if we can move their contents out to swap.
> +	 */
> +	return swap_available() || obj->madv == I915_MADV_DONTNEED;
> +}
> +
>  /**
>   * i915_gem_shrink - Shrink buffer object caches
>   * @dev_priv: i915 device
> @@ -129,6 +169,9 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
>  			if ((flags & I915_SHRINK_ACTIVE) == 0 && obj->active)
>  				continue;
>  
> +			if (!can_release_pages(obj))
> +				continue;
> +
>  			drm_gem_object_reference(&obj->base);
>  
>  			/* For the unbound phase, this should be a no-op! */
> @@ -188,21 +231,6 @@ static bool i915_gem_shrinker_lock(struct drm_device *dev, bool *unlock)
>  	return true;
>  }
>  
> -static int num_vma_bound(struct drm_i915_gem_object *obj)
> -{
> -	struct i915_vma *vma;
> -	int count = 0;
> -
> -	list_for_each_entry(vma, &obj->vma_list, vma_link) {
> -		if (drm_mm_node_allocated(&vma->node))
> -			count++;
> -		if (vma->pin_count)
> -			count++;
> -	}
> -
> -	return count;
> -}
> -
>  static unsigned long
>  i915_gem_shrinker_count(struct shrinker *shrinker, struct shrink_control *sc)
>  {
> @@ -222,7 +250,7 @@ i915_gem_shrinker_count(struct shrinker *shrinker, struct shrink_control *sc)
>  			count += obj->base.size >> PAGE_SHIFT;
>  
>  	list_for_each_entry(obj, &dev_priv->mm.bound_list, global_list) {
> -		if (!obj->active && obj->pages_pin_count == num_vma_bound(obj))
> +		if (!obj->active && can_release_pages(obj))
>  			count += obj->base.size >> PAGE_SHIFT;
>  	}
>  
> -- 
> 2.6.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
