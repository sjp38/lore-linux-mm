Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id CAB9C6B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 04:18:50 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id 184so6260468pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 01:18:50 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id yi4si1461583pac.177.2016.04.05.01.18.49
        for <linux-mm@kvack.org>;
        Tue, 05 Apr 2016 01:18:50 -0700 (PDT)
Message-ID: <1459844378.5564.12.camel@linux.intel.com>
Subject: Re: [PATCH v2 3/3] drm/i915/shrinker: Hook up vmap allocation
 failure notifier
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Tue, 05 Apr 2016 11:19:38 +0300
In-Reply-To: <1459777603-23618-4-git-send-email-chris@chris-wilson.co.uk>
References: <1459777603-23618-1-git-send-email-chris@chris-wilson.co.uk>
	 <1459777603-23618-4-git-send-email-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Pen <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tvrtko Ursulin <tvrtko.ursulin@intel.com>, Mika Kahola <mika.kahola@intel.com>

On ma, 2016-04-04 at 14:46 +0100, Chris Wilson wrote:
> If the core runs out of vmap address space, it will call a notifier in
> case any driver can reap some of its vmaps. As i915.ko is possibily
> holding onto vmap address space that could be recovered, hook into the
> notifier chain and try and reap objects holding onto vmaps.
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Roman Pen <r.peniaev@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

A comment below. But regardless;

Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

> Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
> Cc: Mika Kahola <mika.kahola@intel.com>
> ---
> A drivers/gpu/drm/i915/i915_drv.hA A A A A A A A A A |A A 1 +
> A drivers/gpu/drm/i915/i915_gem_shrinker.c | 39 ++++++++++++++++++++++++++++++++
> A 2 files changed, 40 insertions(+)
> 
> diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
> index dd187727c813..6443745d4182 100644
> --- a/drivers/gpu/drm/i915/i915_drv.h
> +++ b/drivers/gpu/drm/i915/i915_drv.h
> @@ -1257,6 +1257,7 @@ struct i915_gem_mm {
> A 	struct i915_hw_ppgtt *aliasing_ppgtt;
> A 
> A 	struct notifier_block oom_notifier;
> +	struct notifier_block vmap_notifier;
> A 	struct shrinker shrinker;
> A 	bool shrinker_no_lock_stealing;
> A 
> diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> index e391ee3ec486..be7501afb59e 100644
> --- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
> +++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> @@ -28,6 +28,7 @@
> A #include 
> A #include 
> A #include 
> +#include 
> A #include 
> A #include 
> A 
> @@ -356,6 +357,40 @@ i915_gem_shrinker_oom(struct notifier_block *nb, unsigned long event, void *ptr)
> A 	return NOTIFY_DONE;
> A }
> A 
> +static int
> +i915_gem_shrinker_vmap(struct notifier_block *nb, unsigned long event, void *ptr)
> +{
> +	struct drm_i915_private *dev_priv =
> +		container_of(nb, struct drm_i915_private, mm.vmap_notifier);
> +	struct drm_device *dev = dev_priv->dev;
> +	unsigned long timeout = msecs_to_jiffies(5000) + 1;
> +	unsigned long freed_pages;
> +	bool was_interruptible;
> +	bool unlock;
> +
> +	while (!i915_gem_shrinker_lock(dev, &unlock) && --timeout) {
> +		schedule_timeout_killable(1);
> +		if (fatal_signal_pending(current))
> +			return NOTIFY_DONE;
> +	}
> +	if (timeout == 0) {
> +		pr_err("Unable to purge GPU vmaps due to lock contention.\n");
> +		return NOTIFY_DONE;
> +	}
> +
> +	was_interruptible = dev_priv->mm.interruptible;
> +	dev_priv->mm.interruptible = false;
> +
> +	freed_pages = i915_gem_shrink_all(dev_priv);
> +
> +	dev_priv->mm.interruptible = was_interruptible;

Up until here this is same function as the oom shrinker, so I would
combine these two and here do "if (vmap) goto out;" sort of thing.

Would just need a way to distinct between two calling sites. I did not
come up with a quick solution as both are passing 0 as event.

Regards, Joonas

> +	if (unlock)
> +		mutex_unlock(&dev->struct_mutex);
> +
> +	*(unsigned long *)ptr += freed_pages;
> +	return NOTIFY_DONE;
> +}
> +
> A /**
> A  * i915_gem_shrinker_init - Initialize i915 shrinker
> A  * @dev_priv: i915 device
> @@ -371,6 +406,9 @@ void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
> A 
> A 	dev_priv->mm.oom_notifier.notifier_call = i915_gem_shrinker_oom;
> A 	WARN_ON(register_oom_notifier(&dev_priv->mm.oom_notifier));
> +
> +	dev_priv->mm.vmap_notifier.notifier_call = i915_gem_shrinker_vmap;
> +	WARN_ON(register_vmap_purge_notifier(&dev_priv->mm.vmap_notifier));
> A }
> A 
> A /**
> @@ -381,6 +419,7 @@ void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
> A  */
> A void i915_gem_shrinker_cleanup(struct drm_i915_private *dev_priv)
> A {
> +	WARN_ON(unregister_vmap_purge_notifier(&dev_priv->mm.vmap_notifier));
> A 	WARN_ON(unregister_oom_notifier(&dev_priv->mm.oom_notifier));
> A 	unregister_shrinker(&dev_priv->mm.shrinker);
> A }
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
