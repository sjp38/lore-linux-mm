Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 39FF36B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:17:51 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so1670288eei.33
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:17:50 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id q2si40487044eep.72.2014.04.18.07.17.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:17:50 -0700 (PDT)
Date: Fri, 18 Apr 2014 10:17:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC -mm v2 3/3] memcg, slab: simplify synchronization
 scheme
Message-ID: <20140418141734.GD26283@cmpxchg.org>
References: <cover.1397804745.git.vdavydov@parallels.com>
 <c3c36df83d582f8fac94bb716b82406e24229cad.1397804745.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c3c36df83d582f8fac94bb716b82406e24229cad.1397804745.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

I like this patch, but the API names are confusing.  Could we fix up
that whole thing by any chance?  Some suggestions below, but they
might only be marginally better...

On Fri, Apr 18, 2014 at 12:04:49PM +0400, Vladimir Davydov wrote:
> @@ -3156,24 +3157,34 @@ void memcg_free_cache_params(struct kmem_cache *s)
>  	kfree(s->memcg_params);
>  }
>  
> -void memcg_register_cache(struct kmem_cache *s)
> +static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
> +				    struct kmem_cache *root_cache)

memcg_copy_kmem_cache()?

> @@ -3182,49 +3193,30 @@ void memcg_register_cache(struct kmem_cache *s)
>  	 */
>  	smp_wmb();
>  
> -	/*
> -	 * Initialize the pointer to this cache in its parent's memcg_params
> -	 * before adding it to the memcg_slab_caches list, otherwise we can
> -	 * fail to convert memcg_params_to_cache() while traversing the list.
> -	 */
> -	VM_BUG_ON(root->memcg_params->memcg_caches[id]);
> -	root->memcg_params->memcg_caches[id] = s;
> -
> -	mutex_lock(&memcg->slab_caches_mutex);
> -	list_add(&s->memcg_params->list, &memcg->memcg_slab_caches);
> -	mutex_unlock(&memcg->slab_caches_mutex);
> +	BUG_ON(root_cache->memcg_params->memcg_caches[id]);
> +	root_cache->memcg_params->memcg_caches[id] = cachep;
>  }
>  
> -void memcg_unregister_cache(struct kmem_cache *s)
> +static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)

memcg_destroy_kmem_cache()?

> @@ -3258,70 +3250,42 @@ static inline void memcg_resume_kmem_account(void)
>  	current->memcg_kmem_skip_account--;
>  }
>  
> -static void kmem_cache_destroy_work_func(struct work_struct *w)
> -{
> -	struct kmem_cache *cachep;
> -	struct memcg_cache_params *p;
> -
> -	p = container_of(w, struct memcg_cache_params, destroy);
> -
> -	cachep = memcg_params_to_cache(p);
> -
> -	kmem_cache_shrink(cachep);
> -	if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
> -		kmem_cache_destroy(cachep);
> -}
> -
>  int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)

kmem_cache_destroy_memcg_copies()?

>  static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)

memcg_destroy_kmem_cache_copies()?

> @@ -266,22 +265,15 @@ EXPORT_SYMBOL(kmem_cache_create);
>   * requests going from @memcg to @root_cache. The new cache inherits properties
>   * from its parent.
>   */
> -void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_cache)
> +struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
> +					   struct kmem_cache *root_cache)

kmem_cache_request_memcg_copy()?

>  {
> -	struct kmem_cache *s;
> +	struct kmem_cache *s = NULL;
>  	char *cache_name;
>  
>  	get_online_cpus();
>  	mutex_lock(&slab_mutex);
>  
> -	/*
> -	 * Since per-memcg caches are created asynchronously on first
> -	 * allocation (see memcg_kmem_get_cache()), several threads can try to
> -	 * create the same cache, but only one of them may succeed.
> -	 */
> -	if (cache_from_memcg_idx(root_cache, memcg_cache_id(memcg)))
> -		goto out_unlock;
> -
>  	cache_name = memcg_create_cache_name(memcg, root_cache);

memcg_name_kmem_cache()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
