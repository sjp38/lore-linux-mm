Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1708E6B0253
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 14:40:21 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id p65so775130wmp.1
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 11:40:21 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id u7si11074461wme.10.2016.03.24.11.40.19
        for <linux-mm@kvack.org>;
        Thu, 24 Mar 2016 11:40:20 -0700 (PDT)
Date: Thu, 24 Mar 2016 18:40:00 +0000
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH v2 2/2] drm/i915: Make pages of GFX allocations movable
Message-ID: <20160324184000.GW27742@nuc-i3427.alporthouse.com>
References: <20160324081308.GA26929@nuc-i3427.alporthouse.com>
 <1458843779-27904-1-git-send-email-akash.goel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458843779-27904-1-git-send-email-akash.goel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akash.goel@intel.com
Cc: intel-gfx@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Sourab Gupta <sourab.gupta@intel.com>

On Thu, Mar 24, 2016 at 11:52:59PM +0530, akash.goel@intel.com wrote:
> +static int
> +unsafe_drop_pages(struct drm_i915_gem_object *obj)
> +{
> +	struct i915_vma *vma, *next;
> +	int ret;
> +
> +	drm_gem_object_reference(&obj->base);
> +	list_for_each_entry_safe(vma, next, &obj->vma_list, obj_link)
> +		if (i915_vma_unbind(vma))
> +			break;
> +
> +	ret = i915_gem_object_put_pages(obj);
> +	drm_gem_object_unreference(&obj->base);
> +
> +	return ret;
> +}
> +
> +static int
> +do_migrate_page(struct drm_i915_gem_object *obj)
> +{
> +	struct drm_i915_private *dev_priv = obj->base.dev->dev_private;
> +	int ret = 0;
> +
> +	if (!can_migrate_page(obj))
> +		return -EBUSY;
> +
> +	/* HW access would be required for a bound object for which
> +	 * device has to be kept runtime active. But a deadlock scenario
> +	 * can arise if the attempt is made to resume the device, when
> +	 * either a suspend or a resume operation is already happening
> +	 * concurrently from some other path and that only actually
> +	 * triggered the compaction. So only unbind if the device is
> +	 * currently runtime active.
> +	 */
> +	if (!intel_runtime_pm_get_if_in_use(dev_priv))
> +		return -EBUSY;
> +
> +	if (!unsafe_drop_pages(obj))
> +		ret = -EBUSY;

Reversed!

> +
> +	intel_runtime_pm_put(dev_priv);
> +	return ret;
> +}
> +
>  /**
>   * i915_gem_shrink - Shrink buffer object caches
>   * @dev_priv: i915 device
> @@ -156,7 +222,6 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
>  		INIT_LIST_HEAD(&still_in_list);
>  		while (count < target && !list_empty(phase->list)) {
>  			struct drm_i915_gem_object *obj;
> -			struct i915_vma *vma, *v;
>  
>  			obj = list_first_entry(phase->list,
>  					       typeof(*obj), global_list);
> @@ -172,18 +237,8 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
>  			if (!can_release_pages(obj))
>  				continue;
>  
> -			drm_gem_object_reference(&obj->base);
> -
> -			/* For the unbound phase, this should be a no-op! */
> -			list_for_each_entry_safe(vma, v,
> -						 &obj->vma_list, obj_link)
> -				if (i915_vma_unbind(vma))
> -					break;
> -
> -			if (i915_gem_object_put_pages(obj) == 0)
> +			if (unsafe_drop_pages(obj) == 0)
>  				count += obj->base.size >> PAGE_SHIFT;

But correct here :)
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
