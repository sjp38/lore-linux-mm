Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B01006B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 05:03:27 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id 20so12334289wmh.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 02:03:27 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id b81si18085223wma.79.2016.04.05.02.03.26
        for <linux-mm@kvack.org>;
        Tue, 05 Apr 2016 02:03:26 -0700 (PDT)
Date: Tue, 5 Apr 2016 10:03:08 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH v2 3/3] drm/i915/shrinker: Hook up vmap allocation
 failure notifier
Message-ID: <20160405090308.GE24026@nuc-i3427.alporthouse.com>
References: <1459777603-23618-1-git-send-email-chris@chris-wilson.co.uk>
 <1459777603-23618-4-git-send-email-chris@chris-wilson.co.uk>
 <1459844378.5564.12.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1459844378.5564.12.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Pen <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tvrtko Ursulin <tvrtko.ursulin@intel.com>, Mika Kahola <mika.kahola@intel.com>

On Tue, Apr 05, 2016 at 11:19:38AM +0300, Joonas Lahtinen wrote:
> On ma, 2016-04-04 at 14:46 +0100, Chris Wilson wrote:
> > If the core runs out of vmap address space, it will call a notifier in
> > case any driver can reap some of its vmaps. As i915.ko is possibily
> > holding onto vmap address space that could be recovered, hook into the
> > notifier chain and try and reap objects holding onto vmaps.
> > 
> > Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Roman Pen <r.peniaev@gmail.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: linux-mm@kvack.org
> > Cc: linux-kernel@vger.kernel.org
> > Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> 
> A comment below. But regardless;
> 
> Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> 
> > Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
> > Cc: Mika Kahola <mika.kahola@intel.com>
> > ---
> >  drivers/gpu/drm/i915/i915_drv.h          |  1 +
> >  drivers/gpu/drm/i915/i915_gem_shrinker.c | 39 ++++++++++++++++++++++++++++++++
> >  2 files changed, 40 insertions(+)
> > 
> > diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
> > index dd187727c813..6443745d4182 100644
> > --- a/drivers/gpu/drm/i915/i915_drv.h
> > +++ b/drivers/gpu/drm/i915/i915_drv.h
> > @@ -1257,6 +1257,7 @@ struct i915_gem_mm {
> >  	struct i915_hw_ppgtt *aliasing_ppgtt;
> >  
> >  	struct notifier_block oom_notifier;
> > +	struct notifier_block vmap_notifier;
> >  	struct shrinker shrinker;
> >  	bool shrinker_no_lock_stealing;
> >  
> > diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> > index e391ee3ec486..be7501afb59e 100644
> > --- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
> > +++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> > @@ -28,6 +28,7 @@
> >  #include 
> >  #include 
> >  #include 
> > +#include 
> >  #include 
> >  #include 
> >  
> > @@ -356,6 +357,40 @@ i915_gem_shrinker_oom(struct notifier_block *nb, unsigned long event, void *ptr)
> >  	return NOTIFY_DONE;
> >  }
> >  
> > +static int
> > +i915_gem_shrinker_vmap(struct notifier_block *nb, unsigned long event, void *ptr)
> > +{
> > +	struct drm_i915_private *dev_priv =
> > +		container_of(nb, struct drm_i915_private, mm.vmap_notifier);
> > +	struct drm_device *dev = dev_priv->dev;
> > +	unsigned long timeout = msecs_to_jiffies(5000) + 1;
> > +	unsigned long freed_pages;
> > +	bool was_interruptible;
> > +	bool unlock;
> > +
> > +	while (!i915_gem_shrinker_lock(dev, &unlock) && --timeout) {
> > +		schedule_timeout_killable(1);
> > +		if (fatal_signal_pending(current))
> > +			return NOTIFY_DONE;
> > +	}
> > +	if (timeout == 0) {
> > +		pr_err("Unable to purge GPU vmaps due to lock contention.\n");
> > +		return NOTIFY_DONE;
> > +	}
> > +
> > +	was_interruptible = dev_priv->mm.interruptible;
> > +	dev_priv->mm.interruptible = false;
> > +
> > +	freed_pages = i915_gem_shrink_all(dev_priv);
> > +
> > +	dev_priv->mm.interruptible = was_interruptible;
> 
> Up until here this is same function as the oom shrinker, so I would
> combine these two and here do "if (vmap) goto out;" sort of thing.
> 
> Would just need a way to distinct between two calling sites. I did not
> come up with a quick solution as both are passing 0 as event.

Less thrilled about merging the two notifier callbacks, but we could
wrap i915_gem_shrinker_lock_killable().
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
