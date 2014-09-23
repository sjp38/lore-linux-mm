Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4926B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:09:24 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id q5so5719974wiv.10
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 11:09:24 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id ee7si3581802wib.81.2014.09.23.11.09.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 11:09:23 -0700 (PDT)
Received: by mail-wi0-f176.google.com with SMTP id fb4so5455074wid.3
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 11:09:23 -0700 (PDT)
Date: Tue, 23 Sep 2014 20:09:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/3] memcg: move memcg_update_cache_size to
 slab_common.c
Message-ID: <20140923180920.GC29528@dhcp22.suse.cz>
References: <cover.1411401021.git.vdavydov@parallels.com>
 <dd66241915c99132e41f10d0cd0d346be3a4f39c.1411401021.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dd66241915c99132e41f10d0cd0d346be3a4f39c.1411401021.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 22-09-14 20:00:46, Vladimir Davydov wrote:
> While growing per memcg caches arrays, we jump between memcontrol.c and
> slab_common.c in a weird way:
> 
>   memcg_alloc_cache_id - memcontrol.c
>     memcg_update_all_caches - slab_common.c
>       memcg_update_cache_size - memcontrol.c
> 
> There's absolutely no reason why memcg_update_cache_size can't live on
> the slab's side though. So let's move it there and settle it comfortably
> amid per-memcg cache allocation functions.
> 
> Besides, this patch cleans this function up a bit, removing all the
> useless comments from it, and renames it to memcg_update_cache_params to
> conform to memcg_alloc/free_cache_params, which we already have in
> slab_common.c.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

I found new_params->memcg_caches[i] = ... style of initialization easier
to read and understand than memcpy. This is not something to block
this cleanup but I would be happier to have the array style back ;)

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memcontrol.h |    1 -
>  mm/memcontrol.c            |   49 --------------------------------------------
>  mm/slab_common.c           |   30 +++++++++++++++++++++++++--
>  3 files changed, 28 insertions(+), 52 deletions(-)
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
> index 55d131645b45..1ec22bf380d0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2944,55 +2944,6 @@ void memcg_update_array_size(int num)
>  	memcg_limited_groups_array_size = num;
>  }
>  
> -int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
> -{
> -	struct memcg_cache_params *cur_params = s->memcg_params;
> -	struct memcg_cache_params *new_params;
> -	size_t size;
> -	int i;
> -
> -	VM_BUG_ON(!is_root_cache(s));
> -
> -	size = num_groups * sizeof(void *);
> -	size += offsetof(struct memcg_cache_params, memcg_caches);
> -
> -	new_params = kzalloc(size, GFP_KERNEL);
> -	if (!new_params)
> -		return -ENOMEM;
> -
> -	new_params->is_root_cache = true;
> -
> -	/*
> -	 * There is the chance it will be bigger than
> -	 * memcg_limited_groups_array_size, if we failed an allocation
> -	 * in a cache, in which case all caches updated before it, will
> -	 * have a bigger array.
> -	 *
> -	 * But if that is the case, the data after
> -	 * memcg_limited_groups_array_size is certainly unused
> -	 */
> -	for (i = 0; i < memcg_limited_groups_array_size; i++) {
> -		if (!cur_params->memcg_caches[i])
> -			continue;
> -		new_params->memcg_caches[i] =
> -			cur_params->memcg_caches[i];
> -	}
> -
> -	/*
> -	 * Ideally, we would wait until all caches succeed, and only
> -	 * then free the old one. But this is not worth the extra
> -	 * pointer per-cache we'd have to have for this.
> -	 *
> -	 * It is not a big deal if some caches are left with a size
> -	 * bigger than the others. And all updates will reset this
> -	 * anyway.
> -	 */
> -	rcu_assign_pointer(s->memcg_params, new_params);
> -	if (cur_params)
> -		kfree_rcu(cur_params, rcu_head);
> -	return 0;
> -}
> -
>  static void memcg_register_cache(struct mem_cgroup *memcg,
>  				 struct kmem_cache *root_cache)
>  {
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
