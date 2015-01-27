Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0BBEB6B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 02:58:54 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so16970410pad.7
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 23:58:53 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id nm14si716077pdb.12.2015.01.26.23.58.52
        for <linux-mm@kvack.org>;
        Mon, 26 Jan 2015 23:58:53 -0800 (PST)
Date: Tue, 27 Jan 2015 17:00:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH -mm 3/3] slub: make dead caches discard free slabs
 immediately
Message-ID: <20150127080009.GB11358@js1304-P5Q-DELUXE>
References: <cover.1422275084.git.vdavydov@parallels.com>
 <42d95683e3c7f4bb00be4d777e2b334e8981d552.1422275084.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42d95683e3c7f4bb00be4d777e2b334e8981d552.1422275084.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 03:55:29PM +0300, Vladimir Davydov wrote:
> To speed up further allocations SLUB may store empty slabs in per
> cpu/node partial lists instead of freeing them immediately. This
> prevents per memcg caches destruction, because kmem caches created for a
> memory cgroup are only destroyed after the last page charged to the
> cgroup is freed.
> 
> To fix this issue, this patch resurrects approach first proposed in [1].
> It forbids SLUB to cache empty slabs after the memory cgroup that the
> cache belongs to was destroyed. It is achieved by setting kmem_cache's
> cpu_partial and min_partial constants to 0 and tuning put_cpu_partial()
> so that it would drop frozen empty slabs immediately if cpu_partial = 0.
> 
> The runtime overhead is minimal. From all the hot functions, we only
> touch relatively cold put_cpu_partial(): we make it call
> unfreeze_partials() after freezing a slab that belongs to an offline
> memory cgroup. Since slab freezing exists to avoid moving slabs from/to
> a partial list on free/alloc, and there can't be allocations from dead
> caches, it shouldn't cause any overhead. We do have to disable
> preemption for put_cpu_partial() to achieve that though.
> 
> The original patch was accepted well and even merged to the mm tree.
> However, I decided to withdraw it due to changes happening to the memcg
> core at that time. I had an idea of introducing per-memcg shrinkers for
> kmem caches, but now, as memcg has finally settled down, I do not see it
> as an option, because SLUB shrinker would be too costly to call since
> SLUB does not keep free slabs on a separate list. Besides, we currently
> do not even call per-memcg shrinkers for offline memcgs. Overall, it
> would introduce much more complexity to both SLUB and memcg than this
> small patch.
> 
> Regarding to SLAB, there's no problem with it, because it shrinks
> per-cpu/node caches periodically. Thanks to list_lru reparenting, we no
> longer keep entries for offline cgroups in per-memcg arrays (such as
> memcg_cache_params->memcg_caches), so we do not have to bother if a
> per-memcg cache will be shrunk a bit later than it could be.
> 
> [1] http://thread.gmane.org/gmane.linux.kernel.mm/118649/focus=118650
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  mm/slab.c        |    2 +-
>  mm/slab.h        |    2 +-
>  mm/slab_common.c |   15 +++++++++++++--
>  mm/slob.c        |    2 +-
>  mm/slub.c        |   25 ++++++++++++++++++++-----
>  5 files changed, 36 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 279c44d6d8e1..f0514df07b85 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2400,7 +2400,7 @@ static int __cache_shrink(struct kmem_cache *cachep)
>  	return (ret ? 1 : 0);
>  }
>  
> -void __kmem_cache_shrink(struct kmem_cache *cachep)
> +void __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
>  {
>  	__cache_shrink(cachep);
>  }
> diff --git a/mm/slab.h b/mm/slab.h
> index c036e520d2cf..041260197984 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -138,7 +138,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>  #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
>  
>  int __kmem_cache_shutdown(struct kmem_cache *);
> -void __kmem_cache_shrink(struct kmem_cache *);
> +void __kmem_cache_shrink(struct kmem_cache *, bool);
>  void slab_kmem_cache_release(struct kmem_cache *);
>  
>  struct seq_file;
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 6803639fdff0..472ab7fcffd4 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -549,10 +549,13 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
>  {
>  	int idx;
>  	struct memcg_cache_array *arr;
> -	struct kmem_cache *s;
> +	struct kmem_cache *s, *c;
>  
>  	idx = memcg_cache_id(memcg);
>  
> +	get_online_cpus();
> +	get_online_mems();
> +
>  	mutex_lock(&slab_mutex);
>  	list_for_each_entry(s, &slab_caches, list) {
>  		if (!is_root_cache(s))
> @@ -560,9 +563,17 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
>  
>  		arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
>  						lockdep_is_held(&slab_mutex));
> +		c = arr->entries[idx];
> +		if (!c)
> +			continue;
> +
> +		__kmem_cache_shrink(c, true);
>  		arr->entries[idx] = NULL;
>  	}
>  	mutex_unlock(&slab_mutex);
> +
> +	put_online_mems();
> +	put_online_cpus();
>  }
>  
>  void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
> @@ -646,7 +657,7 @@ void kmem_cache_shrink(struct kmem_cache *cachep)
>  {
>  	get_online_cpus();
>  	get_online_mems();
> -	__kmem_cache_shrink(cachep);
> +	__kmem_cache_shrink(cachep, false);
>  	put_online_mems();
>  	put_online_cpus();
>  }
> diff --git a/mm/slob.c b/mm/slob.c
> index 043a14b6ccbe..e63ff9d926dc 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -618,7 +618,7 @@ int __kmem_cache_shutdown(struct kmem_cache *c)
>  	return 0;
>  }
>  
> -void __kmem_cache_shrink(struct kmem_cache *c)
> +void __kmem_cache_shrink(struct kmem_cache *c, bool deactivate)
>  {
>  }
>  
> diff --git a/mm/slub.c b/mm/slub.c
> index c09d93dde40e..6f57824af019 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2007,6 +2007,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>  	int pages;
>  	int pobjects;
>  
> +	preempt_disable();
>  	do {
>  		pages = 0;
>  		pobjects = 0;
> @@ -2040,6 +2041,14 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>  
>  	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
>  								!= oldpage);
> +	if (unlikely(!s->cpu_partial)) {
> +		unsigned long flags;
> +
> +		local_irq_save(flags);
> +		unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
> +		local_irq_restore(flags);
> +	}
> +	preempt_enable();
>  #endif
>  }
>  
> @@ -3368,7 +3377,7 @@ EXPORT_SYMBOL(kfree);
>   * being allocated from last increasing the chance that the last objects
>   * are freed in them.
>   */
> -void __kmem_cache_shrink(struct kmem_cache *s)
> +void __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
>  {
>  	int node;
>  	int i;
> @@ -3381,6 +3390,15 @@ void __kmem_cache_shrink(struct kmem_cache *s)
>  		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
>  	unsigned long flags;
>  
> +	if (deactivate) {
> +		/*
> +		 * Disable empty slabs caching. Used to avoid pinning offline
> +		 * memory cgroups by freeable kmem pages.
> +		 */
> +		s->cpu_partial = 0;
> +		s->min_partial = 0;
> +	}
> +

Hello,

Maybe, kick_all_cpus_sync() is needed here since object would
be freed asynchronously so they can't see this updated value.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
