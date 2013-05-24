Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 376216B0032
	for <linux-mm@kvack.org>; Fri, 24 May 2013 17:57:14 -0400 (EDT)
Received: by mail-ea0-f180.google.com with SMTP id g10so2616471eak.25
        for <linux-mm@kvack.org>; Fri, 24 May 2013 14:57:12 -0700 (PDT)
Date: Fri, 24 May 2013 23:57:08 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH v8 20/34] i915: bail out earlier when shrinker cannot
 acquire mutex
Message-ID: <20130524215708.GK15743@phenom.ffwll.local>
References: <1369391368-31562-1-git-send-email-glommer@openvz.org>
 <1369391368-31562-21-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369391368-31562-21-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Dave Chinner <dchinner@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Kent Overstreet <koverstreet@google.com>

On Fri, May 24, 2013 at 03:59:14PM +0530, Glauber Costa wrote:
> The main shrinker driver will keep trying for a while to free objects if
> the returned value from the shrink scan procedure is 0.  That means "no
> objects now", but a retry could very well succeed.
> 
> A negative value has a different meaning. It means it is impossible to
> shrink, and we would better bail out soon. We find this behavior more
> appropriate for the case where the lock cannot be taken. Specially given
> the hammer behavior of the i915: if another thread is already shrinking,
> we are likely not to be able to shrink anything anyway when we finally
> acquire the mutex.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> CC: Dave Chinner <dchinner@redhat.com>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Daniel Vetter <daniel.vetter@ffwll.ch>
> CC: Kent Overstreet <koverstreet@google.com>

Acked-by: Daniel Vetter <daniel.vetter@ffwll.ch>

> ---
>  drivers/gpu/drm/i915/i915_gem.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index 6b17122..52b3ac1 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -4448,10 +4448,10 @@ i915_gem_inactive_count(struct shrinker *shrinker, struct shrink_control *sc)
>  
>  	if (!mutex_trylock(&dev->struct_mutex)) {
>  		if (!mutex_is_locked_by(&dev->struct_mutex, current))
> -			return 0;
> +			return -1;
>  
>  		if (dev_priv->mm.shrinker_no_lock_stealing)
> -			return 0;
> +			return -1;
>  
>  		unlock = false;
>  	}
> -- 
> 1.8.1.4
> 

-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
