Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 203176B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 11:04:14 -0500 (EST)
Received: by wmvv187 with SMTP id v187so40397461wmv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 08:04:13 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id m134si20274100wmd.84.2015.11.12.08.04.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 08:04:13 -0800 (PST)
Received: by wmww144 with SMTP id w144so94937861wmw.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 08:04:12 -0800 (PST)
Date: Thu, 12 Nov 2015 17:04:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/6] memcg: only account kmem allocations marked as
 __GFP_ACCOUNT
Message-ID: <20151112160409.GM1174@dhcp22.suse.cz>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <14d7a7f5e696d71793ddd835604de309af1963fd.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14d7a7f5e696d71793ddd835604de309af1963fd.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 10-11-15 21:34:04, Vladimir Davydov wrote:
> Black-list kmem accounting policy (aka __GFP_NOACCOUNT) turned out to be
> fragile and difficult to maintain, because there seem to be many more
> allocations that should not be accounted than those that should be.
> Besides, false accounting an allocation might result in much worse
> consequences than not accounting at all, namely increased memory
> consumption due to pinned dead kmem caches.
> 
> So this patch switches kmem accounting to the white-policy: now only
> those kmem allocations that are marked as __GFP_ACCOUNT are accounted to
> memcg. Currently, no kmem allocations are marked like this. The
> following patches will mark several kmem allocations that are known to
> be easily triggered from userspace and therefore should be accounted to
> memcg.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

As mentioned previously I would simply squash 1-3 into a single patch.
Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/gfp.h        | 4 ++++
>  include/linux/memcontrol.h | 2 ++
>  mm/page_alloc.c            | 3 ++-
>  3 files changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 2b917ce34efc..61305a492356 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -30,6 +30,7 @@ struct vm_area_struct;
>  #define ___GFP_HARDWALL		0x20000u
>  #define ___GFP_THISNODE		0x40000u
>  #define ___GFP_RECLAIMABLE	0x80000u
> +#define ___GFP_ACCOUNT		0x100000u
>  #define ___GFP_NOTRACK		0x200000u
>  #define ___GFP_NO_KSWAPD	0x400000u
>  #define ___GFP_OTHER_NODE	0x800000u
> @@ -90,6 +91,8 @@ struct vm_area_struct;
>  #define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
>  #define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
>  #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
> +#define __GFP_ACCOUNT	((__force gfp_t)___GFP_ACCOUNT)	/* Account to memcg (only relevant
> +							 * to kmem allocations) */
>  #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
>  
>  #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
> @@ -112,6 +115,7 @@ struct vm_area_struct;
>  #define GFP_NOIO	(__GFP_WAIT)
>  #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
>  #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
> +#define GFP_KERNEL_ACCOUNT	(GFP_KERNEL | __GFP_ACCOUNT)
>  #define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
>  			 __GFP_RECLAIMABLE)
>  #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 2103f36b3bd3..c9d9a8e7b45f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -773,6 +773,8 @@ static inline bool __memcg_kmem_bypass(gfp_t gfp)
>  {
>  	if (!memcg_kmem_enabled())
>  		return true;
> +	if (!(gfp & __GFP_ACCOUNT))
> +		return true;
>  	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
>  		return true;
>  	return false;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 446bb36ee59d..8e22f5b27de0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3420,7 +3420,8 @@ EXPORT_SYMBOL(__free_page_frag);
>  
>  /*
>   * alloc_kmem_pages charges newly allocated pages to the kmem resource counter
> - * of the current memory cgroup.
> + * of the current memory cgroup if __GFP_ACCOUNT is set, other than that it is
> + * equivalent to alloc_pages.
>   *
>   * It should be used when the caller would like to use kmalloc, but since the
>   * allocation is large, it has to fall back to the page allocator.
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
