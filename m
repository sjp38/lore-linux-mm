Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 3C14D6B005D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 16:22:54 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2964108pad.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 13:22:53 -0700 (PDT)
Date: Fri, 2 Nov 2012 13:22:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: CK5 [02/18] slab: Simplify bootstrap
In-Reply-To: <0000013abdf0becf-a3e4ca1c-e164-4445-b1ff-d253af740700-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1211021314590.5902@chino.kir.corp.google.com>
References: <20121101214538.971500204@linux.com> <0000013abdf0becf-a3e4ca1c-e164-4445-b1ff-d253af740700-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, elezegarcia@gmail.com

On Thu, 1 Nov 2012, Christoph Lameter wrote:

> The nodelists field in kmem_cache is pointing to the first unused
> object in the array field when bootstrap is complete.
> 
> A problem with the current approach is that the statically sized
> kmem_cache structure use on boot can only contain NR_CPUS entries.
> If the number of nodes plus the number of cpus is greater then we
> would overwrite memory following the kmem_cache_boot definition.
> 
> Increase the size of the array field to ensure that also the node
> pointers fit into the array field.
> 
> Once we do that we no longer need the kmem_cache_nodelists
> array and we can then also use that structure elsewhere.
> 
> V1->V2:
> 	- No need to zap kmem_cache->nodelists since it is allocated
> 		with kmem_cache_zalloc() [glommer]
> 
> Acked-by: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>
> ---
>  include/linux/slab_def.h |    2 +-
>  mm/slab.c                |   18 +++++++++++++-----
>  2 files changed, 14 insertions(+), 6 deletions(-)
> 
> Index: linux/include/linux/slab_def.h
> ===================================================================
> --- linux.orig/include/linux/slab_def.h	2012-11-01 10:09:47.073417947 -0500
> +++ linux/include/linux/slab_def.h	2012-11-01 10:09:55.357555494 -0500
> @@ -91,7 +91,7 @@ struct kmem_cache {
>  	 * is statically defined, so we reserve the max number of cpus.
>  	 */
>  	struct kmem_list3 **nodelists;
> -	struct array_cache *array[NR_CPUS];
> +	struct array_cache *array[NR_CPUS + MAX_NUMNODES];

Needs to update the comment which specifies this is only sized to NR_CPUS.

>  	/*
>  	 * Do not add fields after array[]
>  	 */
> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c	2012-11-01 10:09:47.073417947 -0500
> +++ linux/mm/slab.c	2012-11-01 10:09:55.361555562 -0500
> @@ -553,9 +553,7 @@ static struct arraycache_init initarray_
>      { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
>  
>  /* internal cache of cache description objs */
> -static struct kmem_list3 *kmem_cache_nodelists[MAX_NUMNODES];
>  static struct kmem_cache kmem_cache_boot = {
> -	.nodelists = kmem_cache_nodelists,
>  	.batchcount = 1,
>  	.limit = BOOT_CPUCACHE_ENTRIES,
>  	.shared = 1,
> @@ -1560,6 +1558,15 @@ static void __init set_up_list3s(struct
>  }
>  
>  /*
> + * The memory after the last cpu cache pointer is used for the
> + * the nodelists pointer.
> + */
> +static void setup_nodelists_pointer(struct kmem_cache *s)

cachep

> +{
> +	s->nodelists = (struct kmem_list3 **)&s->array[nr_cpu_ids];
> +}
> +
> +/*
>   * Initialisation.  Called after the page allocator have been initialised and
>   * before smp_init().
>   */
> @@ -1573,15 +1580,14 @@ void __init kmem_cache_init(void)
>  	int node;
>  
>  	kmem_cache = &kmem_cache_boot;
> +	setup_nodelists_pointer(kmem_cache);
>  
>  	if (num_possible_nodes() == 1)
>  		use_alien_caches = 0;
>  
> -	for (i = 0; i < NUM_INIT_LISTS; i++) {
> +	for (i = 0; i < NUM_INIT_LISTS; i++)
>  		kmem_list3_init(&initkmem_list3[i]);
> -		if (i < MAX_NUMNODES)
> -			kmem_cache->nodelists[i] = NULL;
> -	}
> +
>  	set_up_list3s(kmem_cache, CACHE_CACHE);
>  
>  	/*
> @@ -1619,7 +1625,6 @@ void __init kmem_cache_init(void)
>  	list_add(&kmem_cache->list, &slab_caches);
>  	kmem_cache->colour_off = cache_line_size();
>  	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
> -	kmem_cache->nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
>  
>  	/*
>  	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
> @@ -2425,7 +2430,7 @@ __kmem_cache_create (struct kmem_cache *
>  	else
>  		gfp = GFP_NOWAIT;
>  
> -	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
> +	setup_nodelists_pointer(cachep);
>  #if DEBUG
>  
>  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
