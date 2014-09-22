Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 546EB6B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 10:07:38 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id ge10so6632493lab.41
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 07:07:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bk7si2419870lbc.71.2014.09.22.07.07.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 07:07:36 -0700 (PDT)
Date: Mon, 22 Sep 2014 16:07:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: move memcg_update_cache_size to slab_common.c
Message-ID: <20140922140734.GF336@dhcp22.suse.cz>
References: <e768785511927d65bd3e6d9f65ab2a9851a3d73d.1411054735.git.vdavydov@parallels.com>
 <0689062e28e13375241dcc64df2a398c9d606c64.1411054735.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0689062e28e13375241dcc64df2a398c9d606c64.1411054735.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>

On Thu 18-09-14 19:50:20, Vladimir Davydov wrote:
> The only reason why this function lives in memcontrol.c is that it
> depends on memcg_caches_array_size. However, we can pass the new array
> size immediately to it instead of new_id+1 so that it will be free of
> any memcontrol.c dependencies.
> 
> So let's move this function to slab_common.c and make it static.

Why?

besides that the patch does more code reshuffling which should be
documented. I have got lost a bit to be honest.

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Christoph Lameter <cl@linux.com>
> ---
>  include/linux/memcontrol.h |    1 -
>  mm/memcontrol.c            |  114 ++++++++++++++------------------------------
>  mm/slab_common.c           |   30 +++++++++++-
>  3 files changed, 65 insertions(+), 80 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 4d17242eeff7..19df5d857411 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -440,7 +440,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order);
>  
>  int memcg_cache_id(struct mem_cgroup *memcg);
>  
> -int memcg_update_cache_size(struct kmem_cache *s, int num_groups);
>  void memcg_update_array_size(int num_groups);
>  
>  struct kmem_cache *
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b6bbb1e3e2ab..9431024e490c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -646,11 +646,13 @@ int memcg_limited_groups_array_size;
>  struct static_key memcg_kmem_enabled_key;
>  EXPORT_SYMBOL(memcg_kmem_enabled_key);
>  
> +static void memcg_free_cache_id(int id);
> +
>  static void disarm_kmem_keys(struct mem_cgroup *memcg)
>  {
>  	if (memcg_kmem_is_active(memcg)) {
>  		static_key_slow_dec(&memcg_kmem_enabled_key);
> -		ida_simple_remove(&kmem_limited_groups, memcg->kmemcg_id);
> +		memcg_free_cache_id(memcg->kmemcg_id);
>  	}
>  	/*
>  	 * This check can't live in kmem destruction function,
> @@ -2892,19 +2894,45 @@ int memcg_cache_id(struct mem_cgroup *memcg)
>  	return memcg ? memcg->kmemcg_id : -1;
>  }
>  
> -static size_t memcg_caches_array_size(int num_groups)
> +static int memcg_alloc_cache_id(void)
>  {
> -	ssize_t size;
> -	if (num_groups <= 0)
> -		return 0;
> +	int id, size;
> +	int err;
> +
> +	id = ida_simple_get(&kmem_limited_groups,
> +			    0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
> +	if (id < 0)
> +		return id;
>  
> -	size = 2 * num_groups;
> +	if (id < memcg_limited_groups_array_size)
> +		return id;
> +
> +	/*
> +	 * There's no space for the new id in memcg_caches arrays,
> +	 * so we have to grow them.
> +	 */
> +
> +	size = 2 * (id + 1);
>  	if (size < MEMCG_CACHES_MIN_SIZE)
>  		size = MEMCG_CACHES_MIN_SIZE;
>  	else if (size > MEMCG_CACHES_MAX_SIZE)
>  		size = MEMCG_CACHES_MAX_SIZE;
>  
> -	return size;
> +	mutex_lock(&memcg_slab_mutex);
> +	err = memcg_update_all_caches(size);
> +	mutex_unlock(&memcg_slab_mutex);
> +
> +	if (err) {
> +		ida_simple_remove(&kmem_limited_groups, id);
> +		return err;
> +	}
> +	return id;
> +
> +}
> +
> +static void memcg_free_cache_id(int id)
> +{
> +	ida_simple_remove(&kmem_limited_groups, id);
>  }
>  
>  /*
> @@ -2914,60 +2942,7 @@ static size_t memcg_caches_array_size(int num_groups)
>   */
>  void memcg_update_array_size(int num)
>  {
> -	if (num > memcg_limited_groups_array_size)
> -		memcg_limited_groups_array_size = memcg_caches_array_size(num);
> -}
> -
> -int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
> -{
> -	struct memcg_cache_params *cur_params = s->memcg_params;
> -
> -	VM_BUG_ON(!is_root_cache(s));
> -
> -	if (num_groups > memcg_limited_groups_array_size) {
> -		int i;
> -		struct memcg_cache_params *new_params;
> -		ssize_t size = memcg_caches_array_size(num_groups);
> -
> -		size *= sizeof(void *);
> -		size += offsetof(struct memcg_cache_params, memcg_caches);
> -
> -		new_params = kzalloc(size, GFP_KERNEL);
> -		if (!new_params)
> -			return -ENOMEM;
> -
> -		new_params->is_root_cache = true;
> -
> -		/*
> -		 * There is the chance it will be bigger than
> -		 * memcg_limited_groups_array_size, if we failed an allocation
> -		 * in a cache, in which case all caches updated before it, will
> -		 * have a bigger array.
> -		 *
> -		 * But if that is the case, the data after
> -		 * memcg_limited_groups_array_size is certainly unused
> -		 */
> -		for (i = 0; i < memcg_limited_groups_array_size; i++) {
> -			if (!cur_params->memcg_caches[i])
> -				continue;
> -			new_params->memcg_caches[i] =
> -						cur_params->memcg_caches[i];
> -		}
> -
> -		/*
> -		 * Ideally, we would wait until all caches succeed, and only
> -		 * then free the old one. But this is not worth the extra
> -		 * pointer per-cache we'd have to have for this.
> -		 *
> -		 * It is not a big deal if some caches are left with a size
> -		 * bigger than the others. And all updates will reset this
> -		 * anyway.
> -		 */
> -		rcu_assign_pointer(s->memcg_params, new_params);
> -		if (cur_params)
> -			kfree_rcu(cur_params, rcu_head);
> -	}
> -	return 0;
> +	memcg_limited_groups_array_size = num;
>  }
>  
>  static void memcg_register_cache(struct mem_cgroup *memcg,
> @@ -4167,23 +4142,12 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
>  	if (err)
>  		goto out;
>  
> -	memcg_id = ida_simple_get(&kmem_limited_groups,
> -				  0, MEMCG_CACHES_MAX_SIZE, GFP_KERNEL);
> +	memcg_id = memcg_alloc_cache_id();
>  	if (memcg_id < 0) {
>  		err = memcg_id;
>  		goto out;
>  	}
>  
> -	/*
> -	 * Make sure we have enough space for this cgroup in each root cache's
> -	 * memcg_params.
> -	 */
> -	mutex_lock(&memcg_slab_mutex);
> -	err = memcg_update_all_caches(memcg_id + 1);
> -	mutex_unlock(&memcg_slab_mutex);
> -	if (err)
> -		goto out_rmid;
> -
>  	memcg->kmemcg_id = memcg_id;
>  	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
>  
> @@ -4204,10 +4168,6 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
>  out:
>  	memcg_resume_kmem_account();
>  	return err;
> -
> -out_rmid:
> -	ida_simple_remove(&kmem_limited_groups, memcg_id);
> -	goto out;
>  }
>  
>  static int memcg_activate_kmem(struct mem_cgroup *memcg,
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 9c29ba792368..800314e2a075 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -120,6 +120,33 @@ static void memcg_free_cache_params(struct kmem_cache *s)
>  	kfree(s->memcg_params);
>  }
>  
> +static int memcg_update_cache_params(struct kmem_cache *s, int num_memcgs)
> +{
> +	int size;
> +	struct memcg_cache_params *new_params, *cur_params;
> +
> +	BUG_ON(!is_root_cache(s));
> +
> +	size = offsetof(struct memcg_cache_params, memcg_caches);
> +	size += num_memcgs * sizeof(void *);
> +
> +	new_params = kzalloc(size, GFP_KERNEL);
> +	if (!new_params)
> +		return -ENOMEM;
> +
> +	cur_params = s->memcg_params;
> +	memcpy(new_params->memcg_caches, cur_params->memcg_caches,
> +	       memcg_limited_groups_array_size * sizeof(void *));
> +
> +	new_params->is_root_cache = true;
> +
> +	rcu_assign_pointer(s->memcg_params, new_params);
> +	if (cur_params)
> +		kfree_rcu(cur_params, rcu_head);
> +
> +	return 0;
> +}
> +
>  int memcg_update_all_caches(int num_memcgs)
>  {
>  	struct kmem_cache *s;
> @@ -130,9 +157,8 @@ int memcg_update_all_caches(int num_memcgs)
>  		if (!is_root_cache(s))
>  			continue;
>  
> -		ret = memcg_update_cache_size(s, num_memcgs);
> +		ret = memcg_update_cache_params(s, num_memcgs);
>  		/*
> -		 * See comment in memcontrol.c, memcg_update_cache_size:
>  		 * Instead of freeing the memory, we'll just leave the caches
>  		 * up to this point in an updated state.
>  		 */
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
