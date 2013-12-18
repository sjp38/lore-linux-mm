Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 191EB6B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 12:06:53 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so3684997eae.19
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 09:06:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si841956eew.160.2013.12.18.09.06.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 09:06:52 -0800 (PST)
Date: Wed, 18 Dec 2013 18:06:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/6] memcg, slab: kmem_cache_create_memcg(): free memcg
 params on error
Message-ID: <20131218170649.GC31080@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
 <9420ad797a2cfa14c23ad1ba6db615a2a51ffee0.1387372122.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9420ad797a2cfa14c23ad1ba6db615a2a51ffee0.1387372122.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 18-12-13 17:16:53, Vladimir Davydov wrote:
> Plus, rename memcg_register_cache() to memcg_init_cache_params(),
> because it actually does not register the cache anywhere, but simply
> initialize kmem_cache::memcg_params.

I've almost missed this is a memory leak fix.
I do not mind renaming and the name but wouldn't
memcg_alloc_cache_params suit better?

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Glauber Costa <glommer@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memcontrol.h |   13 +++++++++----
>  mm/memcontrol.c            |    9 +++++++--
>  mm/slab_common.c           |    3 ++-
>  3 files changed, 18 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b3e7a66..b357ae3 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -497,8 +497,9 @@ void __memcg_kmem_commit_charge(struct page *page,
>  void __memcg_kmem_uncharge_pages(struct page *page, int order);
>  
>  int memcg_cache_id(struct mem_cgroup *memcg);
> -int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
> -			 struct kmem_cache *root_cache);
> +int memcg_init_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
> +			    struct kmem_cache *root_cache);
> +void memcg_free_cache_params(struct kmem_cache *s);
>  void memcg_release_cache(struct kmem_cache *cachep);
>  void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep);
>  
> @@ -641,12 +642,16 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
>  }
>  
>  static inline int
> -memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
> -		     struct kmem_cache *root_cache)
> +memcg_init_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
> +			struct kmem_cache *root_cache)
>  {
>  	return 0;
>  }
>  
> +static inline void memcg_free_cache_params(struct kmem_cache *s);
> +{
> +}
> +
>  static inline void memcg_release_cache(struct kmem_cache *cachep)
>  {
>  }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bf5e894..e6ad6ff 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3195,8 +3195,8 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
>  	return 0;
>  }
>  
> -int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
> -			 struct kmem_cache *root_cache)
> +int memcg_init_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
> +			    struct kmem_cache *root_cache)
>  {
>  	size_t size;
>  
> @@ -3224,6 +3224,11 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
>  	return 0;
>  }
>  
> +void memcg_free_cache_params(struct kmem_cache *s)
> +{
> +	kfree(s->memcg_params);
> +}
> +
>  void memcg_release_cache(struct kmem_cache *s)
>  {
>  	struct kmem_cache *root;
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 5d6f743..62712fe 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -208,7 +208,7 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>  		goto out_free_cache;
>  	}
>  
> -	err = memcg_register_cache(memcg, s, parent_cache);
> +	err = memcg_init_cache_params(memcg, s, parent_cache);
>  	if (err)
>  		goto out_free_cache;
>  
> @@ -238,6 +238,7 @@ out_unlock:
>  	return s;
>  
>  out_free_cache:
> +	memcg_free_cache_params(s);
>  	kfree(s->name);
>  	kmem_cache_free(kmem_cache, s);
>  	goto out_unlock;
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
