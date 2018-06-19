Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC96F6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 12:22:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n8-v6so491731wmh.0
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 09:22:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l7-v6si174920edn.256.2018.06.19.09.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 09:22:14 -0700 (PDT)
Date: Tue, 19 Jun 2018 12:24:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm: memcg: remote memcg charging for kmem allocations
Message-ID: <20180619162429.GB27423@cmpxchg.org>
References: <20180619051327.149716-1-shakeelb@google.com>
 <20180619051327.149716-2-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180619051327.149716-2-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>

On Mon, Jun 18, 2018 at 10:13:25PM -0700, Shakeel Butt wrote:
> @@ -248,6 +248,30 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
>  	current->flags = (current->flags & ~PF_MEMALLOC) | flags;
>  }
>  
> +#ifdef CONFIG_MEMCG
> +static inline struct mem_cgroup *memalloc_memcg_save(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *old_memcg = current->target_memcg;
> +
> +	current->target_memcg = memcg;
> +	return old_memcg;
> +}
> +
> +static inline void memalloc_memcg_restore(struct mem_cgroup *memcg)
> +{
> +	current->target_memcg = memcg;
> +}

The use_mm() and friends naming scheme would be better here:
memalloc_use_memcg(), memalloc_unuse_memcg(), current->active_memcg

> @@ -375,6 +376,27 @@ static __always_inline void kfree_bulk(size_t size, void **p)
>  	kmem_cache_free_bulk(NULL, size, p);
>  }
>  
> +/*
> + * Calling kmem_cache_alloc_memcg implicitly assumes that the caller wants
> + * a __GFP_ACCOUNT allocation. However if memcg is NULL then
> + * kmem_cache_alloc_memcg is same as kmem_cache_alloc.
> + */
> +static __always_inline void *kmem_cache_alloc_memcg(struct kmem_cache *cachep,
> +						    gfp_t flags,
> +						    struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *old_memcg;
> +	void *ptr;
> +
> +	if (!memcg)
> +		return kmem_cache_alloc(cachep, flags);
> +
> +	old_memcg = memalloc_memcg_save(memcg);
> +	ptr = kmem_cache_alloc(cachep, flags | __GFP_ACCOUNT);
> +	memalloc_memcg_restore(old_memcg);
> +	return ptr;

I'm not a big fan of these functions as an interface because it
implies that kmem_cache_alloc() et al wouldn't charge a memcg - but
they do, just using current's memcg.

It's also a lot of churn to duplicate all the various slab functions.

Can you please inline the save/restore (or use/unuse) functions into
the callsites? If you make them handle NULL as parameters, it merely
adds two bracketing lines around the allocation call in the callsites,
which I think would be better to understand - in particular with a
comment on why we are charging *that* group instead of current's.

> +static __always_inline struct mem_cgroup *get_mem_cgroup(
> +				struct mem_cgroup *memcg, struct mm_struct *mm)
> +{
> +	if (unlikely(memcg)) {
> +		rcu_read_lock();
> +		if (css_tryget_online(&memcg->css)) {
> +			rcu_read_unlock();
> +			return memcg;
> +		}
> +		rcu_read_unlock();
> +	}
> +	return get_mem_cgroup_from_mm(mm);
> +}
> +
>  /**
>   * mem_cgroup_iter - iterate over memory cgroup hierarchy
>   * @root: hierarchy root
> @@ -2260,7 +2274,7 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
>  	if (current->memcg_kmem_skip_account)
>  		return cachep;
>  
> -	memcg = get_mem_cgroup_from_mm(current->mm);
> +	memcg = get_mem_cgroup(current->target_memcg, current->mm);

get_mem_cgroup_from_current(), which uses current->active_memcg if set
and current->mm->memcg otherwise, would be a nicer abstraction IMO.
