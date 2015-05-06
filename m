Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 80C866B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 10:58:17 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so14634412wgi.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 07:58:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mm8si34423738wjc.36.2015.05.06.07.58.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 07:58:16 -0700 (PDT)
Date: Wed, 6 May 2015 16:58:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506145814.GP14550@dhcp22.suse.cz>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 05-05-15 12:45:42, Vladimir Davydov wrote:
[...]
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 97a9373e61e8..37c422df2a0f 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -30,6 +30,7 @@ struct vm_area_struct;
>  #define ___GFP_HARDWALL		0x20000u
>  #define ___GFP_THISNODE		0x40000u
>  #define ___GFP_RECLAIMABLE	0x80000u
> +#define ___GFP_NOACCOUNT	0x100000u
>  #define ___GFP_NOTRACK		0x200000u
>  #define ___GFP_NO_KSWAPD	0x400000u
>  #define ___GFP_OTHER_NODE	0x800000u
> @@ -87,6 +88,7 @@ struct vm_area_struct;
>  #define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
>  #define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
>  #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
> +#define __GFP_NOACCOUNT	((__force gfp_t)___GFP_NOACCOUNT) /* Don't account to memcg */

The wording suggests that _any_ memcg charge might be skipped by this flag
but only kmem part is handled.

So either handle the flag in try_charge or, IMO preferably, update the
comment here and add WARN_ON{_ONCE}(gfp & __GFP_NOACCOUNT). I do not
think we should allow to skip the charge for user pages ATM and warning
could tell us about the abuse of the flag.

>  #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
>  
>  #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 72dff5fb0d0c..6c8918114804 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -463,6 +463,8 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
>  	if (!memcg_kmem_enabled())
>  		return true;
>  
> +	if (gfp & __GFP_NOACCOUNT)
> +		return true;
>  	/*
>  	 * __GFP_NOFAIL allocations will move on even if charging is not
>  	 * possible. Therefore we don't even try, and have this allocation
> @@ -522,6 +524,8 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
>  {
>  	if (!memcg_kmem_enabled())
>  		return cachep;
> +	if (gfp & __GFP_NOACCOUNT)
> +		return cachep;
>  	if (gfp & __GFP_NOFAIL)
>  		return cachep;
>  	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 5405aff5a590..f0fe4f2c1fa7 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -115,7 +115,8 @@
>  #define BYTES_PER_POINTER	sizeof(void *)
>  
>  /* GFP bitmask for kmemleak internal allocations */
> -#define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
> +#define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC | \
> +					   __GFP_NOACCOUNT)) | \
>  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
>  				 __GFP_NOWARN)
>  
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
