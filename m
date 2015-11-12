Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 033D66B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 11:17:45 -0500 (EST)
Received: by wmww144 with SMTP id w144so95530528wmw.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 08:17:44 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id t18si20340767wme.69.2015.11.12.08.17.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 08:17:42 -0800 (PST)
Received: by wmww144 with SMTP id w144so207424086wmw.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 08:17:42 -0800 (PST)
Date: Thu, 12 Nov 2015 17:17:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 4/6] slab: add SLAB_ACCOUNT flag
Message-ID: <20151112161741.GN1174@dhcp22.suse.cz>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
 <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ce23e932ea53f47a3376de90b21a9db8293bd6c.1447172835.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 10-11-15 21:34:05, Vladimir Davydov wrote:
> Currently, if we want to account all objects of a particular kmem cache,
> we have to pass __GFP_ACCOUNT to each kmem_cache_alloc call, which is
> inconvenient. This patch introduces SLAB_ACCOUNT flag which if passed to
> kmem_cache_create will force accounting for every allocation from this
> cache even if __GFP_ACCOUNT is not passed.

Yes this is much better and less error prone for dedicated caches.

> This patch does not make any of the existing caches use this flag - it
> will be done later in the series.
> 
> Note, a cache with SLAB_ACCOUNT cannot be merged with a cache w/o
> SLAB_ACCOUNT, i.e. using this flag will probably reduce the number of
> merged slabs even if kmem accounting is not used (only compiled in).

I would expect some reasoning why this is the case. Why cannot caches of
the same memcg be merged? I remember you have mentioned something in the
previous discussion with Tejun but it should be in the changelog as well
IMO.

> Suggested-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

I am not sufficiently qualified to judge the slab implementation
specifics but for the overal approach

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 15 +++++++--------
>  include/linux/slab.h       |  5 +++++
>  mm/memcontrol.c            |  8 +++++++-
>  mm/slab.h                  |  5 +++--
>  mm/slab_common.c           |  3 ++-
>  mm/slub.c                  |  2 ++
>  6 files changed, 26 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index c9d9a8e7b45f..5c97265c1c6e 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -766,15 +766,13 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
>  	return memcg ? memcg->kmemcg_id : -1;
>  }
>  
> -struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
> +struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
>  void __memcg_kmem_put_cache(struct kmem_cache *cachep);
>  
> -static inline bool __memcg_kmem_bypass(gfp_t gfp)
> +static inline bool __memcg_kmem_bypass(void)
>  {
>  	if (!memcg_kmem_enabled())
>  		return true;
> -	if (!(gfp & __GFP_ACCOUNT))
> -		return true;
>  	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
>  		return true;
>  	return false;
> @@ -791,7 +789,9 @@ static inline bool __memcg_kmem_bypass(gfp_t gfp)
>  static __always_inline int memcg_kmem_charge(struct page *page,
>  					     gfp_t gfp, int order)
>  {
> -	if (__memcg_kmem_bypass(gfp))
> +	if (__memcg_kmem_bypass())
> +		return 0;
> +	if (!(gfp & __GFP_ACCOUNT))
>  		return 0;
>  	return __memcg_kmem_charge(page, gfp, order);
>  }
> @@ -810,16 +810,15 @@ static __always_inline void memcg_kmem_uncharge(struct page *page, int order)
>  /**
>   * memcg_kmem_get_cache: selects the correct per-memcg cache for allocation
>   * @cachep: the original global kmem cache
> - * @gfp: allocation flags.
>   *
>   * All memory allocated from a per-memcg cache is charged to the owner memcg.
>   */
>  static __always_inline struct kmem_cache *
>  memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
>  {
> -	if (__memcg_kmem_bypass(gfp))
> +	if (__memcg_kmem_bypass())
>  		return cachep;
> -	return __memcg_kmem_get_cache(cachep);
> +	return __memcg_kmem_get_cache(cachep, gfp);
>  }
>  
>  static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 7c82e3b307a3..20168c6ffe89 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -86,6 +86,11 @@
>  #else
>  # define SLAB_FAILSLAB		0x00000000UL
>  #endif
> +#ifdef CONFIG_MEMCG_KMEM
> +# define SLAB_ACCOUNT		0x04000000UL	/* Account to memcg */
> +#else
> +# define SLAB_ACCOUNT		0x00000000UL
> +#endif
>  
>  /* The following flags affect the page allocator grouping pages by mobility */
>  #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bc502e590366..06e4f538e38e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2332,7 +2332,7 @@ static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
>   * Can't be called in interrupt context or from kernel threads.
>   * This function needs to be called with rcu_read_lock() held.
>   */
> -struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
> +struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
>  {
>  	struct mem_cgroup *memcg;
>  	struct kmem_cache *memcg_cachep;
> @@ -2340,6 +2340,12 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
>  
>  	VM_BUG_ON(!is_root_cache(cachep));
>  
> +	if (cachep->flags & SLAB_ACCOUNT)
> +		gfp |= __GFP_ACCOUNT;
> +
> +	if (!(gfp & __GFP_ACCOUNT))
> +		return cachep;
> +
>  	if (current->memcg_kmem_skip_account)
>  		return cachep;
>  
> diff --git a/mm/slab.h b/mm/slab.h
> index 27492eb678f7..2778de8673bd 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -128,10 +128,11 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>  
>  #if defined(CONFIG_SLAB)
>  #define SLAB_CACHE_FLAGS (SLAB_MEM_SPREAD | SLAB_NOLEAKTRACE | \
> -			  SLAB_RECLAIM_ACCOUNT | SLAB_TEMPORARY | SLAB_NOTRACK)
> +			  SLAB_RECLAIM_ACCOUNT | SLAB_TEMPORARY | \
> +			  SLAB_NOTRACK | SLAB_ACCOUNT)
>  #elif defined(CONFIG_SLUB)
>  #define SLAB_CACHE_FLAGS (SLAB_NOLEAKTRACE | SLAB_RECLAIM_ACCOUNT | \
> -			  SLAB_TEMPORARY | SLAB_NOTRACK)
> +			  SLAB_TEMPORARY | SLAB_NOTRACK | SLAB_ACCOUNT)
>  #else
>  #define SLAB_CACHE_FLAGS (0)
>  #endif
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index d88e97c10a2e..698b2c97b22b 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -37,7 +37,8 @@ struct kmem_cache *kmem_cache;
>  		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
>  		SLAB_FAILSLAB)
>  
> -#define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | SLAB_NOTRACK)
> +#define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
> +			 SLAB_NOTRACK | SLAB_ACCOUNT)
>  
>  /*
>   * Merge control. If this is set then no merging of slab caches will occur.
> diff --git a/mm/slub.c b/mm/slub.c
> index 75a5fa92ac2a..b037cea9cfeb 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5247,6 +5247,8 @@ static char *create_unique_id(struct kmem_cache *s)
>  		*p++ = 'F';
>  	if (!(s->flags & SLAB_NOTRACK))
>  		*p++ = 't';
> +	if (s->flags & SLAB_ACCOUNT)
> +		*p++ = 'A';
>  	if (p != name + 1)
>  		*p++ = '-';
>  	p += sprintf(p, "%07d", s->size);
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
