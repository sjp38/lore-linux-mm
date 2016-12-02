Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF9256B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 03:44:25 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y16so1760478wmd.6
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 00:44:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tz15si4255939wjb.56.2016.12.02.00.44.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 00:44:24 -0800 (PST)
Subject: Re: [PATCH] mm: use vmalloc fallback path for certain memcg
 allocations
References: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <03a17767-1322-3466-a1f1-dba2c6862be4@suse.cz>
Date: Fri, 2 Dec 2016 09:44:23 +0100
MIME-Version: 1.0
In-Reply-To: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anatoly Stepanov <astepanov@cloudlinux.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, vdavydov.dev@gmail.com, umka@cloudlinux.com, panda@cloudlinux.com, vmeshkov@cloudlinux.com, Michal Hocko <mhocko@suse.cz>

On 12/01/2016 02:16 AM, Anatoly Stepanov wrote:
> As memcg array size can be up to:
> sizeof(struct memcg_cache_array) + kmemcg_id * sizeof(void *);
>
> where kmemcg_id can be up to MEMCG_CACHES_MAX_SIZE.
>
> When a memcg instance count is large enough it can lead
> to high order allocations up to order 7.
>
> The same story with memcg_lrus allocations.
> So let's work this around by utilizing vmalloc fallback path.
>
> Signed-off-by: Anatoly Stepanov <astepanov@cloudlinux.com>
> ---
>  include/linux/memcontrol.h | 16 ++++++++++++++++
>  mm/list_lru.c              | 14 +++++++-------
>  mm/slab_common.c           | 21 ++++++++++++++-------
>  3 files changed, 37 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 61d20c1..a281622 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -29,6 +29,9 @@
>  #include <linux/mmzone.h>
>  #include <linux/writeback.h>
>  #include <linux/page-flags.h>
> +#include <linux/vmalloc.h>
> +#include <linux/slab.h>
> +#include <linux/mm.h>
>
>  struct mem_cgroup;
>  struct page;
> @@ -878,4 +881,17 @@ static inline void memcg_kmem_update_page_stat(struct page *page,
>  }
>  #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
>
> +static inline void memcg_free(const void *ptr)
> +{
> +	is_vmalloc_addr(ptr) ? vfree(ptr) : kfree(ptr);
> +}
> +
> +static inline void *memcg_alloc(size_t size)
> +{
> +	if (likely(size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)))
> +		return kzalloc(size, GFP_KERNEL|__GFP_NORETRY);
> +
> +	return vzalloc(size);

That's not how I imagine a "fallback" to work. You should be trying 
kzalloc() and if that fails, call vzalloc(), not distinguish it by 
costly order check. Also IIRC __GFP_NORETRY can easily fail even for 
non-costly orders.

> +}
> +
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 234676e..8f49339 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -327,12 +327,12 @@ static int memcg_init_list_lru_node(struct list_lru_node *nlru)
>  {
>  	int size = memcg_nr_cache_ids;
>
> -	nlru->memcg_lrus = kmalloc(size * sizeof(void *), GFP_KERNEL);
> -	if (!nlru->memcg_lrus)
> +	nlru->memcg_lrus = memcg_alloc(size * sizeof(void *));
> +	if (nlru->memcg_lrus == NULL)
>  		return -ENOMEM;
>
>  	if (__memcg_init_list_lru_node(nlru->memcg_lrus, 0, size)) {
> -		kfree(nlru->memcg_lrus);
> +		memcg_free(nlru->memcg_lrus);
>  		return -ENOMEM;
>  	}
>
> @@ -342,7 +342,7 @@ static int memcg_init_list_lru_node(struct list_lru_node *nlru)
>  static void memcg_destroy_list_lru_node(struct list_lru_node *nlru)
>  {
>  	__memcg_destroy_list_lru_node(nlru->memcg_lrus, 0, memcg_nr_cache_ids);
> -	kfree(nlru->memcg_lrus);
> +	memcg_free(nlru->memcg_lrus);
>  }
>
>  static int memcg_update_list_lru_node(struct list_lru_node *nlru,
> @@ -353,12 +353,12 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
>  	BUG_ON(old_size > new_size);
>
>  	old = nlru->memcg_lrus;
> -	new = kmalloc(new_size * sizeof(void *), GFP_KERNEL);
> +	new = memcg_alloc(new_size * sizeof(void *));
>  	if (!new)
>  		return -ENOMEM;
>
>  	if (__memcg_init_list_lru_node(new, old_size, new_size)) {
> -		kfree(new);
> +		memcg_free(new);
>  		return -ENOMEM;
>  	}
>
> @@ -375,7 +375,7 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
>  	nlru->memcg_lrus = new;
>  	spin_unlock_irq(&nlru->lock);
>
> -	kfree(old);
> +	memcg_free(old);
>  	return 0;
>  }
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 329b038..19f8cb5 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -157,9 +157,8 @@ static int init_memcg_params(struct kmem_cache *s,
>  	if (!memcg_nr_cache_ids)
>  		return 0;
>
> -	arr = kzalloc(sizeof(struct memcg_cache_array) +
> -		      memcg_nr_cache_ids * sizeof(void *),
> -		      GFP_KERNEL);
> +	arr = memcg_alloc(sizeof(struct memcg_cache_array) +
> +			memcg_nr_cache_ids * sizeof(void *));
>  	if (!arr)
>  		return -ENOMEM;
>
> @@ -170,7 +169,15 @@ static int init_memcg_params(struct kmem_cache *s,
>  static void destroy_memcg_params(struct kmem_cache *s)
>  {
>  	if (is_root_cache(s))
> -		kfree(rcu_access_pointer(s->memcg_params.memcg_caches));
> +		memcg_free(rcu_access_pointer(s->memcg_params.memcg_caches));
> +}
> +
> +static void memcg_rcu_free(struct rcu_head *rcu)
> +{
> +	struct memcg_cache_array *arr;
> +
> +	arr = container_of(rcu, struct memcg_cache_array, rcu);
> +	memcg_free(arr);
>  }
>
>  static int update_memcg_params(struct kmem_cache *s, int new_array_size)
> @@ -180,8 +187,8 @@ static int update_memcg_params(struct kmem_cache *s, int new_array_size)
>  	if (!is_root_cache(s))
>  		return 0;
>
> -	new = kzalloc(sizeof(struct memcg_cache_array) +
> -		      new_array_size * sizeof(void *), GFP_KERNEL);
> +	new = memcg_alloc(sizeof(struct memcg_cache_array) +
> +				new_array_size * sizeof(void *));
>  	if (!new)
>  		return -ENOMEM;
>
> @@ -193,7 +200,7 @@ static int update_memcg_params(struct kmem_cache *s, int new_array_size)
>
>  	rcu_assign_pointer(s->memcg_params.memcg_caches, new);
>  	if (old)
> -		kfree_rcu(old, rcu);
> +		call_rcu(&old->rcu, memcg_rcu_free);
>  	return 0;
>  }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
