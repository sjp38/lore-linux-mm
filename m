Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id A9FA36B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 12:41:07 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so3645358eek.37
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 09:41:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si968064eeh.164.2013.12.18.09.41.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 09:41:06 -0800 (PST)
Date: Wed, 18 Dec 2013 18:41:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] memcg, slab: check and init memcg_cahes under
 slab_mutex
Message-ID: <20131218174105.GE31080@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
 <afc6d5e85d805c7313e928497b4ebcf1815703dd.1387372122.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <afc6d5e85d805c7313e928497b4ebcf1815703dd.1387372122.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 18-12-13 17:16:55, Vladimir Davydov wrote:
> The memcg_params::memcg_caches array can be updated concurrently from
> memcg_update_cache_size() and memcg_create_kmem_cache(). Although both
> of these functions take the slab_mutex during their operation, the
> latter checks if memcg's cache has already been allocated w/o taking the
> mutex. This can result in a race as described below.
> 
> Asume two threads schedule kmem_cache creation works for the same
> kmem_cache of the same memcg from __memcg_kmem_get_cache(). One of the
> works successfully creates it. Another work should fail then, but if it
> interleaves with memcg_update_cache_size() as follows, it does not:

I am not sure I understand the race. memcg_update_cache_size is called
when we start accounting a new memcg or a child is created and it
inherits accounting from the parent. memcg_create_kmem_cache is called
when a new cache is first allocated from, right?

Why cannot we simply take slab_mutex inside memcg_create_kmem_cache?
it is running from the workqueue context so it should clash with other
locks.

> 
>   memcg_create_kmem_cache()                     memcg_update_cache_size()
>   (called w/o mutexes held)                     (called with slab_mutex held)
>   -------------------------                     -------------------------
>   mutex_lock(&memcg_cache_mutex)
>                                                 s->memcg_params=kzalloc(...)
>   new_cachep=cache_from_memcg_idx(cachep,idx)
>   // new_cachep==NULL => proceed to creation
>                                                 s->memcg_params->memcg_caches[i]
>                                                     =cur_params->memcg_caches[i]
>   // kmem_cache_dup takes slab_mutex so we will
>   // hang around here until memcg_update_cache_size()
>   // finishes, but ...
>   new_cachep = kmem_cache_dup(memcg, cachep)
>   // nothing will prevent kmem_cache_dup from
>   // succeeding so ...
>   cachep->memcg_params->memcg_caches[idx]=new_cachep
>   // we've overwritten an existing cache ptr!
> 
> Let's fix this by moving both the check and the update of
> memcg_params::memcg_caches from memcg_create_kmem_cache() to
> kmem_cache_create_memcg() to be called under the slab_mutex.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Glauber Costa <glommer@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memcontrol.h |    9 ++--
>  mm/memcontrol.c            |   98 +++++++++++++++-----------------------------
>  mm/slab_common.c           |    8 +++-
>  3 files changed, 44 insertions(+), 71 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b357ae3..fdd3f30 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -500,8 +500,8 @@ int memcg_cache_id(struct mem_cgroup *memcg);
>  int memcg_init_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
>  			    struct kmem_cache *root_cache);
>  void memcg_free_cache_params(struct kmem_cache *s);
> -void memcg_release_cache(struct kmem_cache *cachep);
> -void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep);
> +void memcg_register_cache(struct kmem_cache *s);
> +void memcg_release_cache(struct kmem_cache *s);
>  
>  int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
>  void memcg_update_array_size(int num_groups);
> @@ -652,12 +652,11 @@ static inline void memcg_free_cache_params(struct kmem_cache *s);
>  {
>  }
>  
> -static inline void memcg_release_cache(struct kmem_cache *cachep)
> +static inline void memcg_register_cache(struct kmem_cache *s)
>  {
>  }
>  
> -static inline void memcg_cache_list_add(struct mem_cgroup *memcg,
> -					struct kmem_cache *s)
> +static inline void memcg_release_cache(struct kmem_cache *s)
>  {
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e37fdb5..62b9991 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3059,16 +3059,6 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
>  		css_put(&memcg->css);
>  }
>  
> -void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
> -{
> -	if (!memcg)
> -		return;
> -
> -	mutex_lock(&memcg->slab_caches_mutex);
> -	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
> -	mutex_unlock(&memcg->slab_caches_mutex);
> -}
> -
>  /*
>   * helper for acessing a memcg's index. It will be used as an index in the
>   * child cache array in kmem_cache, and also to derive its name. This function
> @@ -3229,6 +3219,35 @@ void memcg_free_cache_params(struct kmem_cache *s)
>  	kfree(s->memcg_params);
>  }
>  
> +void memcg_register_cache(struct kmem_cache *s)
> +{
> +	struct kmem_cache *root;
> +	struct mem_cgroup *memcg;
> +	int id;
> +
> +	if (is_root_cache(s))
> +		return;
> +
> +	memcg = s->memcg_params->memcg;
> +	id = memcg_cache_id(memcg);
> +	root = s->memcg_params->root_cache;
> +
> +	css_get(&memcg->css);
> +
> +	/*
> +	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
> +	 * barrier here to ensure nobody will see the kmem_cache partially
> +	 * initialized.
> +	 */
> +	smp_wmb();
> +
> +	root->memcg_params->memcg_caches[id] = s;
> +
> +	mutex_lock(&memcg->slab_caches_mutex);
> +	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
> +	mutex_unlock(&memcg->slab_caches_mutex);
> +}
> +
>  void memcg_release_cache(struct kmem_cache *s)
>  {
>  	struct kmem_cache *root;
> @@ -3356,26 +3375,13 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>  	schedule_work(&cachep->memcg_params->destroy);
>  }
>  
> -/*
> - * This lock protects updaters, not readers. We want readers to be as fast as
> - * they can, and they will either see NULL or a valid cache value. Our model
> - * allow them to see NULL, in which case the root memcg will be selected.
> - *
> - * We need this lock because multiple allocations to the same cache from a non
> - * will span more than one worker. Only one of them can create the cache.
> - */
> -static DEFINE_MUTEX(memcg_cache_mutex);
> -
> -/*
> - * Called with memcg_cache_mutex held
> - */
> -static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
> -					 struct kmem_cache *s)
> +static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> +						  struct kmem_cache *s)
>  {
>  	struct kmem_cache *new;
>  	static char *tmp_name = NULL;
>  
> -	lockdep_assert_held(&memcg_cache_mutex);
> +	BUG_ON(!memcg_can_account_kmem(memcg));
>  
>  	/*
>  	 * kmem_cache_create_memcg duplicates the given name and
> @@ -3403,45 +3409,6 @@ static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
>  	return new;
>  }
>  
> -static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> -						  struct kmem_cache *cachep)
> -{
> -	struct kmem_cache *new_cachep;
> -	int idx;
> -
> -	BUG_ON(!memcg_can_account_kmem(memcg));
> -
> -	idx = memcg_cache_id(memcg);
> -
> -	mutex_lock(&memcg_cache_mutex);
> -	new_cachep = cache_from_memcg_idx(cachep, idx);
> -	if (new_cachep) {
> -		css_put(&memcg->css);
> -		goto out;
> -	}
> -
> -	new_cachep = kmem_cache_dup(memcg, cachep);
> -	if (new_cachep == NULL) {
> -		new_cachep = cachep;
> -		css_put(&memcg->css);
> -		goto out;
> -	}
> -
> -	atomic_set(&new_cachep->memcg_params->nr_pages , 0);
> -
> -	/*
> -	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
> -	 * barrier here to ensure nobody will see the kmem_cache partially
> -	 * initialized.
> -	 */
> -	smp_wmb();
> -
> -	cachep->memcg_params->memcg_caches[idx] = new_cachep;
> -out:
> -	mutex_unlock(&memcg_cache_mutex);
> -	return new_cachep;
> -}
> -
>  void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
>  {
>  	struct kmem_cache *c;
> @@ -3516,6 +3483,7 @@ static void memcg_create_cache_work_func(struct work_struct *w)
>  
>  	cw = container_of(w, struct create_work, work);
>  	memcg_create_kmem_cache(cw->memcg, cw->cachep);
> +	css_put(&cw->memcg->css);
>  	kfree(cw);
>  }
>  
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 62712fe..51dc106 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -176,6 +176,12 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>  	get_online_cpus();
>  	mutex_lock(&slab_mutex);
>  
> +	if (memcg) {
> +		s = cache_from_memcg_idx(parent_cache, memcg_cache_id(memcg));
> +		if (s)
> +			goto out_unlock;
> +	}
> +
>  	err = kmem_cache_sanity_check(memcg, name, size);
>  	if (err)
>  		goto out_unlock;
> @@ -218,7 +224,7 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>  
>  	s->refcount = 1;
>  	list_add(&s->list, &slab_caches);
> -	memcg_cache_list_add(memcg, s);
> +	memcg_register_cache(s);
>  
>  out_unlock:
>  	mutex_unlock(&slab_mutex);
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
