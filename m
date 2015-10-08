Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 35A716B0253
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 11:13:21 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so29934396wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 08:13:20 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id pc9si53756422wjb.170.2015.10.08.08.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 08:13:20 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so33256139wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 08:13:19 -0700 (PDT)
Date: Thu, 8 Oct 2015 17:13:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify and inline __mem_cgroup_from_kmem
Message-ID: <20151008151318.GG426@dhcp22.suse.cz>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
 <517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 05-10-15 01:21:43, Vladimir Davydov wrote:
> Before the previous patch, __mem_cgroup_from_kmem had to handle two
> types of kmem - slab pages and pages allocated with alloc_kmem_pages -
> differently, because slab pages did not store information about owner
> memcg in the page struct. Now we can unify it. Since after it, this
> function becomes tiny we can fold it into mem_cgroup_from_kmem.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h |  7 ++++---
>  mm/memcontrol.c            | 18 ------------------
>  2 files changed, 4 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 8a9b7a798f14..0e2e039609d1 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -769,8 +769,6 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
>  struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
>  void __memcg_kmem_put_cache(struct kmem_cache *cachep);
>  
> -struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr);
> -
>  static inline bool __memcg_kmem_bypass(gfp_t gfp)
>  {
>  	if (!memcg_kmem_enabled())
> @@ -832,9 +830,12 @@ static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
>  
>  static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
>  {
> +	struct page *page;
> +
>  	if (!memcg_kmem_enabled())
>  		return NULL;
> -	return __mem_cgroup_from_kmem(ptr);
> +	page = virt_to_head_page(ptr);
> +	return page->mem_cgroup;
>  }
>  #else
>  #define for_each_memcg_cache_index(_idx)	\
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1d6413e0dd29..6329e6182d89 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2430,24 +2430,6 @@ void __memcg_kmem_uncharge(struct page *page, int order)
>  	page->mem_cgroup = NULL;
>  	css_put_many(&memcg->css, nr_pages);
>  }
> -
> -struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr)
> -{
> -	struct mem_cgroup *memcg = NULL;
> -	struct kmem_cache *cachep;
> -	struct page *page;
> -
> -	page = virt_to_head_page(ptr);
> -	if (PageSlab(page)) {
> -		cachep = page->slab_cache;
> -		if (!is_root_cache(cachep))
> -			memcg = cachep->memcg_params.memcg;
> -	} else
> -		/* page allocated by alloc_kmem_pages */
> -		memcg = page->mem_cgroup;
> -
> -	return memcg;
> -}
>  #endif /* CONFIG_MEMCG_KMEM */
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
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
