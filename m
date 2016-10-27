Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42D226B0275
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:25:21 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n3so6644277lfn.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 00:25:21 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id eo16si6850603wjb.48.2016.10.27.00.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 00:25:19 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id m83so1214277wmc.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 00:25:19 -0700 (PDT)
Date: Thu, 27 Oct 2016 09:25:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] memcg: Prevent caches to be both OFF_SLAB &
 OBJFREELIST_SLAB
Message-ID: <20161027072518.GC6454@dhcp22.suse.cz>
References: <1477503688-69191-1-git-send-email-thgarnie@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1477503688-69191-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, Vladimir Davydov <vdavydov.dev@gmail.com>

The patch is marked for memcg but I do not see any direct relation.
I am not familiar with this code enough probably but if this really is
memcg kmem related, please do not forget to CC Vladimir

On Wed 26-10-16 10:41:28, Thomas Garnier wrote:
> While testing OBJFREELIST_SLAB integration with pagealloc, we found a
> bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
> CFLGS_OBJFREELIST_SLAB.
> 
> The original kmem_cache is created early making OFF_SLAB not possible.
> When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
> is enabled it will try to enable it first under certain conditions.
> Given kmem_cache(sys) reuses the original flag, you can have both flags
> at the same time resulting in allocation failures and odd behaviors.
> 
> The proposed fix removes these flags by default at the entrance of
> __kmem_cache_create. This way the function will define which way the
> freelist should be handled at this stage for the new cache.
> 
> Fixes: b03a017bebc4 ("mm/slab: introduce new slab management type, OBJFREELIST_SLAB")
> Signed-off-by: Thomas Garnier <thgarnie@google.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
> Based on next-20161025
> ---
>  mm/slab.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 3c83c29..efe280a 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2027,6 +2027,14 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>  	int err;
>  	size_t size = cachep->size;
>  
> +	/*
> +	 * memcg re-creates caches with the flags of the originals. Remove
> +	 * the freelist related flags to ensure they are re-defined at this
> +	 * stage. Prevent having both flags on edge cases like with pagealloc
> +	 * if the original cache was created too early to be OFF_SLAB.
> +	 */
> +	flags &= ~(CFLGS_OBJFREELIST_SLAB|CFLGS_OFF_SLAB);
> +
>  #if DEBUG
>  #if FORCED_DEBUG
>  	/*
> -- 
> 2.8.0.rc3.226.g39d4020
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
