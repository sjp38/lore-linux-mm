Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id A38826B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 09:59:54 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id f206so26099013wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 06:59:54 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id wk7si152728626wjb.244.2016.01.05.06.59.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 06:59:53 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id u188so26352552wmu.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 06:59:53 -0800 (PST)
Date: Tue, 5 Jan 2016 15:59:51 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Intel-gfx] [PATCH v2 1/3] drm/i915: Enable lockless lookup of
 request tracking via RCU
Message-ID: <20160105145951.GN8076@phenom.ffwll.local>
References: <1450869563-23892-1-git-send-email-chris@chris-wilson.co.uk>
 <1450877756-2902-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450877756-2902-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Dec 23, 2015 at 01:35:54PM +0000, Chris Wilson wrote:
> If we enable RCU for the requests (providing a grace period where we can
> inspect a "dead" request before it is freed), we can allow callers to
> carefully perform lockless lookup of an active request.
> 
> However, by enabling deferred freeing of requests, we can potentially
> hog a lot of memory when dealing with tens of thousands of requests per
> second - with a quick insertion of the a synchronize_rcu() inside our
> shrinker callback, that issue disappears.
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> ---
>  drivers/gpu/drm/i915/i915_gem.c          |  3 ++-
>  drivers/gpu/drm/i915/i915_gem_request.c  |  2 +-
>  drivers/gpu/drm/i915/i915_gem_request.h  | 24 +++++++++++++++++++++++-
>  drivers/gpu/drm/i915/i915_gem_shrinker.c |  1 +
>  4 files changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index c169574758d5..696ada3891ed 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -4222,7 +4222,8 @@ i915_gem_load(struct drm_device *dev)
>  	dev_priv->requests =
>  		kmem_cache_create("i915_gem_request",
>  				  sizeof(struct drm_i915_gem_request), 0,
> -				  SLAB_HWCACHE_ALIGN,
> +				  SLAB_HWCACHE_ALIGN |
> +				  SLAB_DESTROY_BY_RCU,
>  				  NULL);
>  
>  	INIT_LIST_HEAD(&dev_priv->context_list);

[snip i915 private changes, leave just slab/shrinker changes]

> diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> index c561ed2b8287..03a8bbb3e31e 100644
> --- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
> +++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
> @@ -142,6 +142,7 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
>  	}
>  
>  	i915_gem_retire_requests(dev_priv->dev);
> +	synchronize_rcu(); /* expedite the grace period to free the requests */

Shouldn't the slab subsystem do this for us if we request it delays the
actual kfree? Seems like a core bug to me ... Adding more folks.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
