Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC276B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:27:31 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id v186so31373572lfa.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 05:27:31 -0800 (PST)
Received: from smtp5.mail.ru (smtp5.mail.ru. [94.100.179.24])
        by mx.google.com with ESMTPS id h29si8813650lfj.361.2017.01.14.05.27.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 05:27:30 -0800 (PST)
Date: Sat, 14 Jan 2017 16:27:22 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 3/9] slab: simplify shutdown_memcg_caches()
Message-ID: <20170114132722.GB2668@esperanza>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-4-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114055449.11044-4-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 12:54:43AM -0500, Tejun Heo wrote:
> shutdown_memcg_caches() shuts down all memcg caches associated with a
> root cache.  It first walks the index table clearing and shutting down
> each entry and then shuts down the ones on
> root_cache->memcg_params.list.  As active caches are on both the table
> and the list, they're stashed away from the list to avoid shutting
> down twice and then get spliced back later.
> 
> This is unnecessarily complication.  All memcg caches are on
> root_cache->memcg_params.list.  The function can simply clear the
> index table and shut down all caches on the list.  There's no need to
> muck with temporary stashing.
> 
> Simplify the code.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/slab_common.c | 32 +++++---------------------------
>  1 file changed, 5 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 851c75e..45aa67c 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -634,48 +634,26 @@ static int shutdown_memcg_caches(struct kmem_cache *s)
>  {
>  	struct memcg_cache_array *arr;
>  	struct kmem_cache *c, *c2;
> -	LIST_HEAD(busy);
>  	int i;
>  
>  	BUG_ON(!is_root_cache(s));
>  
>  	/*
> -	 * First, shutdown active caches, i.e. caches that belong to online
> -	 * memory cgroups.
> +	 * First, clear the pointers to all memcg caches so that they will
> +	 * never be accessed even if the root cache stays alive.
>  	 */
>  	arr = rcu_dereference_protected(s->memcg_params.memcg_caches,
>  					lockdep_is_held(&slab_mutex));
> -	for_each_memcg_cache_index(i) {
> -		c = arr->entries[i];
> -		if (!c)
> -			continue;
> -		if (shutdown_cache(c))
> -			/*
> -			 * The cache still has objects. Move it to a temporary
> -			 * list so as not to try to destroy it for a second
> -			 * time while iterating over inactive caches below.
> -			 */
> -			list_move(&c->memcg_params.list, &busy);
> -		else
> -			/*
> -			 * The cache is empty and will be destroyed soon. Clear
> -			 * the pointer to it in the memcg_caches array so that
> -			 * it will never be accessed even if the root cache
> -			 * stays alive.
> -			 */
> -			arr->entries[i] = NULL;
> -	}
> +	for_each_memcg_cache_index(i)
> +		arr->entries[i] = NULL;
>  
>  	/*
> -	 * Second, shutdown all caches left from memory cgroups that are now
> -	 * offline.
> +	 * Shutdown all caches.
>  	 */
>  	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
>  				 memcg_params.list)
>  		shutdown_cache(c);

The point of this complexity was to leave caches that happen to have
objects when kmem_cache_destroy() is called on the list, so that they
could be reused later. This behavior was inherited from the global
caches - if kmem_cache_destroy() is called on a cache that still has
object, we print a warning message and don't destroy the cache. This
patch changes this behavior.

>  
> -	list_splice(&busy, &s->memcg_params.list);
> -
>  	/*
>  	 * A cache being destroyed must be empty. In particular, this means
>  	 * that all per memcg caches attached to it must be empty too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
