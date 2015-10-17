Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id D8D5882F64
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 11:05:36 -0400 (EDT)
Received: by iow1 with SMTP id 1so151961192iow.1
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 08:05:36 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id f188si20194559iof.15.2015.10.17.08.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Oct 2015 08:05:36 -0700 (PDT)
Date: Sat, 17 Oct 2015 18:05:26 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/3] memcg: unify slab and other kmem pages charging
Message-ID: <20151017150526.GM11309@esperanza>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
 <41bbfbf1268f7cce22ac9e1656ddc196ae56a409.1443996201.git.vdavydov@virtuozzo.com>
 <20151017001932.GA6403@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151017001932.GA6403@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 16, 2015 at 05:19:32PM -0700, Johannes Weiner wrote:
...
> I think it'd be better to have an outer function than a magic
> parameter for the memcg lookup. Could we fold this in there?

Yeah, that looks neater. Thanks!

Andrew, could you please fold this one too?

> 
> ---
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |  7 ++++---
>  mm/memcontrol.c            | 36 ++++++++++++++++++------------------
>  mm/slab.h                  |  4 ++--
>  3 files changed, 24 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 47677ac..730a65d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -756,8 +756,9 @@ static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>   * conditions, but because they are pretty simple, they are expected to be
>   * fast.
>   */
> -int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order,
> -			struct mem_cgroup *memcg);
> +int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
> +			      struct mem_cgroup *memcg);
> +int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
>  void __memcg_kmem_uncharge(struct page *page, int order);
>  
>  /*
> @@ -797,7 +798,7 @@ static __always_inline int memcg_kmem_charge(struct page *page,
>  {
>  	if (__memcg_kmem_bypass(gfp))
>  		return 0;
> -	return __memcg_kmem_charge(page, gfp, order, NULL);
> +	return __memcg_kmem_charge(page, gfp, order);
>  }
>  
>  /**
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 15db655..6fc9959 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2378,39 +2378,39 @@ void __memcg_kmem_put_cache(struct kmem_cache *cachep)
>  		css_put(&cachep->memcg_params.memcg->css);
>  }
>  
> -/*
> - * If @memcg != NULL, charge to @memcg, otherwise charge to the memcg the
> - * current task belongs to.
> - */
> -int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order,
> -			struct mem_cgroup *memcg)
> +int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
> +			      struct mem_cgroup *memcg)
>  {
> -	struct page_counter *counter;
>  	unsigned int nr_pages = 1 << order;
> -	bool put = false;
> +	struct page_counter *counter;
>  	int ret = 0;
>  
> -	if (!memcg) {
> -		memcg = get_mem_cgroup_from_mm(current->mm);
> -		put = true;
> -	}
>  	if (!memcg_kmem_is_active(memcg))
> -		goto out;
> +		return 0;
>  
>  	ret = page_counter_try_charge(&memcg->kmem, nr_pages, &counter);
>  	if (ret)
> -		goto out;
> +		return ret;
>  
>  	ret = try_charge(memcg, gfp, nr_pages);
>  	if (ret) {
>  		page_counter_uncharge(&memcg->kmem, nr_pages);
> -		goto out;
> +		return ret;
>  	}
>  
>  	page->mem_cgroup = memcg;
> -out:
> -	if (put)
> -		css_put(&memcg->css);
> +
> +	return 0;
> +}
> +
> +int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
> +{
> +	struct mem_cgroup *memcg;
> +	int ret;
> +
> +	memcg = get_mem_cgroup_from_mm(current->mm);
> +	ret = __memcg_kmem_charge_memcg(page, gfp, order, memcg);
> +	css_put(&memcg->css);
>  	return ret;
>  }
>  
> diff --git a/mm/slab.h b/mm/slab.h
> index 3d667a4..27492eb 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -244,8 +244,8 @@ static __always_inline int memcg_charge_slab(struct page *page,
>  		return 0;
>  	if (is_root_cache(s))
>  		return 0;
> -	return __memcg_kmem_charge(page, gfp, order,
> -				   s->memcg_params.memcg);
> +	return __memcg_kmem_charge_memcg(page, gfp, order,
> +					 s->memcg_params.memcg);
>  }
>  
>  extern void slab_init_memcg_params(struct kmem_cache *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
