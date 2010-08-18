Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CB52E6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:11:17 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o7ILBCgS021285
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:11:13 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz17.hot.corp.google.com with ESMTP id o7ILB8Vj015112
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:11:11 -0700
Received: by pzk33 with SMTP id 33so665445pzk.0
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:11:08 -0700 (PDT)
Date: Wed, 18 Aug 2010 14:11:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup2 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <20100818162638.201568486@linux.com>
Message-ID: <alpine.DEB.2.00.1008181350340.28077@chino.kir.corp.google.com>
References: <20100818162539.281413425@linux.com> <20100818162638.201568486@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, Christoph Lameter wrote:

> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2010-08-17 11:38:48.000000000 -0500
> +++ linux-2.6/include/linux/slub_def.h	2010-08-17 14:45:54.000000000 -0500
> @@ -139,19 +139,16 @@ struct kmem_cache {
>  
>  #ifdef CONFIG_ZONE_DMA
>  #define SLUB_DMA __GFP_DMA
> -/* Reserve extra caches for potential DMA use */
> -#define KMALLOC_CACHES (2 * SLUB_PAGE_SHIFT)
>  #else
>  /* Disable DMA functionality */
>  #define SLUB_DMA (__force gfp_t)0
> -#define KMALLOC_CACHES SLUB_PAGE_SHIFT
>  #endif
>  
>  /*
>   * We keep the general caches in an array of slab caches that are used for
>   * 2^x bytes of allocations.
>   */
> -extern struct kmem_cache kmalloc_caches[KMALLOC_CACHES];
> +extern struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
>  
>  /*
>   * Sorry that the following has to be that ugly but some versions of GCC
> @@ -216,7 +213,7 @@ static __always_inline struct kmem_cache
>  	if (index == 0)
>  		return NULL;
>  
> -	return &kmalloc_caches[index];
> +	return kmalloc_caches[index];
>  }
>  
>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-08-17 12:30:11.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-08-17 14:46:09.000000000 -0500
> @@ -178,7 +178,7 @@ static struct notifier_block slab_notifi
>  
>  static enum {
>  	DOWN,		/* No slab functionality available */
> -	PARTIAL,	/* kmem_cache_open() works but kmalloc does not */
> +	PARTIAL,	/* Kmem_cache_node works */

This isn't going to be needed anymore, even with the rest of your SLUB+Q 
patches, so it should probably be removed unless you can think of a future 
use.

>  	UP,		/* Everything works but does not show up in sysfs */
>  	SYSFS		/* Sysfs up */
>  } slab_state = DOWN;
> @@ -2073,6 +2073,8 @@ static inline int alloc_kmem_cache_cpus(
>  }
>  
>  #ifdef CONFIG_NUMA
> +static struct kmem_cache *kmem_cache_node;
> +
>  /*
>   * No kmalloc_node yet so do it by hand. We know that this is the first
>   * slab on the node for this slabcache. There are no concurrent accesses
> @@ -2088,9 +2090,9 @@ static void early_kmem_cache_node_alloc(
>  	struct kmem_cache_node *n;
>  	unsigned long flags;
>  
> -	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
> +	BUG_ON(kmem_cache_node->size < sizeof(struct kmem_cache_node));
>  
> -	page = new_slab(kmalloc_caches, GFP_NOWAIT, node);
> +	page = new_slab(kmem_cache_node, GFP_NOWAIT, node);
>  
>  	BUG_ON(!page);
>  	if (page_to_nid(page) != node) {
> @@ -2102,15 +2104,15 @@ static void early_kmem_cache_node_alloc(
>  
>  	n = page->freelist;
>  	BUG_ON(!n);
> -	page->freelist = get_freepointer(kmalloc_caches, n);
> +	page->freelist = get_freepointer(kmem_cache_node, n);
>  	page->inuse++;
> -	kmalloc_caches->node[node] = n;
> +	kmem_cache_node->node[node] = n;
>  #ifdef CONFIG_SLUB_DEBUG
> -	init_object(kmalloc_caches, n, 1);
> -	init_tracking(kmalloc_caches, n);
> +	init_object(kmem_cache_node, n, 1);
> +	init_tracking(kmem_cache_node, n);
>  #endif
> -	init_kmem_cache_node(n, kmalloc_caches);
> -	inc_slabs_node(kmalloc_caches, node, page->objects);
> +	init_kmem_cache_node(n, kmem_cache_node);
> +	inc_slabs_node(kmem_cache_node, node, page->objects);
>  
>  	/*
>  	 * lockdep requires consistent irq usage for each lock
> @@ -2128,8 +2130,10 @@ static void free_kmem_cache_nodes(struct
>  
>  	for_each_node_state(node, N_NORMAL_MEMORY) {
>  		struct kmem_cache_node *n = s->node[node];
> +
>  		if (n)
> -			kmem_cache_free(kmalloc_caches, n);
> +			kmem_cache_free(kmem_cache_node, n);
> +
>  		s->node[node] = NULL;
>  	}
>  }
> @@ -2145,7 +2149,7 @@ static int init_kmem_cache_nodes(struct 
>  			early_kmem_cache_node_alloc(node);
>  			continue;
>  		}
> -		n = kmem_cache_alloc_node(kmalloc_caches,
> +		n = kmem_cache_alloc_node(kmem_cache_node,
>  						GFP_KERNEL, node);
>  
>  		if (!n) {
> @@ -2498,11 +2502,13 @@ EXPORT_SYMBOL(kmem_cache_destroy);
>   *		Kmalloc subsystem
>   *******************************************************************/
>  
> -struct kmem_cache kmalloc_caches[KMALLOC_CACHES] __cacheline_aligned;
> +struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
>  EXPORT_SYMBOL(kmalloc_caches);
>  
> +static struct kmem_cache *kmem_cache;
> +
>  #ifdef CONFIG_ZONE_DMA
> -static struct kmem_cache kmalloc_dma_caches[SLUB_PAGE_SHIFT];
> +static struct kmem_cache *kmalloc_dma_caches[SLUB_PAGE_SHIFT];
>  #endif
>  
>  static int __init setup_slub_min_order(char *str)
> @@ -2541,9 +2547,13 @@ static int __init setup_slub_nomerge(cha
>  
>  __setup("slub_nomerge", setup_slub_nomerge);
>  
> -static void create_kmalloc_cache(struct kmem_cache *s,
> +static void __init create_kmalloc_cache(struct kmem_cache **sp,
>  		const char *name, int size, unsigned int flags)
>  {
> +	struct kmem_cache *s;
> +
> +	s = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);

Needs BUG_ON(!s)?

> +
>  	/*
>  	 * This function is called with IRQs disabled during early-boot on
>  	 * single CPU so there's no need to take slub_lock here.
> @@ -2552,6 +2562,8 @@ static void create_kmalloc_cache(struct 
>  								flags, NULL))
>  		goto panic;
>  
> +	*sp = s;

Is there an advantage to doing this and not simply having the function 
return s (or NULL, on error) back to kmem_cache_init()?

> +
>  	list_add(&s->list, &slab_caches);
>  
>  	if (!sysfs_slab_add(s))
> @@ -2613,10 +2625,10 @@ static struct kmem_cache *get_slab(size_
>  
>  #ifdef CONFIG_ZONE_DMA
>  	if (unlikely((flags & SLUB_DMA)))
> -		return &kmalloc_dma_caches[index];
> +		return kmalloc_dma_caches[index];
>  
>  #endif
> -	return &kmalloc_caches[index];
> +	return kmalloc_caches[index];
>  }
>  
>  void *__kmalloc(size_t size, gfp_t flags)
> @@ -2940,46 +2952,114 @@ static int slab_memory_callback(struct n
>   *			Basic setup of slabs
>   *******************************************************************/
>  
> +/*
> + * Used for early kmem_cache structures that were allocated using
> + * the page allocator
> + */
> +
> +static void __init kmem_cache_bootstrap_fixup(struct kmem_cache *s)
> +{
> +	int node;
> +
> +	list_add(&s->list, &slab_caches);
> +	sysfs_slab_add(s);

We'll need some error handling here to at least emit a warning message 
that we're missing caches in sysfs.

> +	s->refcount = -1;
> +
> +	for_each_node(node) {

Only needs to iterate over N_NORMAL_MEMORY.

> +		struct kmem_cache_node *n = get_node(s, node);
> +		struct page *p;
> +
> +		if (n) {
> +			list_for_each_entry(p, &n->partial, lru)
> +				p->slab = s;
> +
> +#ifdef CONFIG_SLAB_DEBUG
> +			list_for_each_entry(p, &n->full, lru)
> +				p->slab = s;
> +#endif
> +		}
> +	}
> +}
> +
>  void __init kmem_cache_init(void)
>  {
>  	int i;
>  	int caches = 0;
> +	struct kmem_cache *temp_kmem_cache;
> +	int order;
>  
>  #ifdef CONFIG_NUMA
> +	struct kmem_cache *temp_kmem_cache_node;
> +	unsigned long kmalloc_size;
> +
> +	kmem_size = offsetof(struct kmem_cache, node) +
> +				nr_node_ids * sizeof(struct kmem_cache_node *);
> +
> +	/* Allocate two kmem_caches from the page allocator */
> +	kmalloc_size = ALIGN(kmem_size, cache_line_size());
> +	order = get_order(2 * kmalloc_size);
> +	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
> +
>  	/*
>  	 * Must first have the slab cache available for the allocations of the
>  	 * struct kmem_cache_node's. There is special bootstrap code in
>  	 * kmem_cache_open for slab_state == DOWN.
>  	 */
> -	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
> -		sizeof(struct kmem_cache_node), 0);
> -	kmalloc_caches[0].refcount = -1;
> -	caches++;
> +	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
> +
> +	kmem_cache_open(kmem_cache_node, "kmem_cache_node",
> +		sizeof(struct kmem_cache_node),
> +		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
>  
>  	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
> +#else
> +	/* Allocate a single kmem_cache from the page allocator */
> +	kmem_size = sizeof(struct kmem_cache);
> +	order = get_order(kmem_size);

Should this be cacheline aligned?

> +	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
>  #endif
>  
>  	/* Able to allocate the per node structures */
>  	slab_state = PARTIAL;
>  
> -	/* Caches that are not of the two-to-the-power-of size */
> -	if (KMALLOC_MIN_SIZE <= 32) {
> -		create_kmalloc_cache(&kmalloc_caches[1],
> -				"kmalloc-96", 96, 0);
> -		caches++;
> -	}
> -	if (KMALLOC_MIN_SIZE <= 64) {
> -		create_kmalloc_cache(&kmalloc_caches[2],
> -				"kmalloc-192", 192, 0);
> -		caches++;
> -	}
> +	temp_kmem_cache = kmem_cache;
> +	kmem_cache_open(kmem_cache, "kmem_cache", kmem_size,
> +		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> +	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);

BUG_ON(!kmem_cache);

> +	memcpy(kmem_cache, temp_kmem_cache, kmem_size);

kmem_cache_bootstrap_fixup(kmem_cache) should be here and not later, 
right?

>  
> -	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
> -		create_kmalloc_cache(&kmalloc_caches[i],
> -			"kmalloc", 1 << i, 0);
> -		caches++;
> -	}
> +#ifdef CONFIG_NUMA
> +	/*
> +	 * Allocate kmem_cache_node properly from the kmem_cache slab.
> +	 * kmem_cache_node is separately allocated so no need to
> +	 * update any list pointers.
> +	 */
> +	temp_kmem_cache_node = kmem_cache_node;
>  
> +	kmem_cache_node = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);

BUG_ON(!kmem_cache_node);

> +	memcpy(kmem_cache_node, temp_kmem_cache_node, kmem_size);
> +
> +	kmem_cache_bootstrap_fixup(kmem_cache_node);
> +
> +	caches++;
> +#else
> +	/*
> +	 * kmem_cache has kmem_cache_node embedded and we moved it!
> +	 * Update the list heads
> +	 */
> +	INIT_LIST_HEAD(&kmem_cache->local_node.partial);
> +	list_splice(&temp_kmem_cache->local_node.partial, &kmem_cache->local_node.partial);
> +#ifdef CONFIG_SLUB_DEBUG
> +	INIT_LIST_HEAD(&kmem_cache->local_node.full);
> +	list_splice(&temp_kmem_cache->local_node.full, &kmem_cache->local_node.full);
> +#endif
> +#endif
> +	kmem_cache_bootstrap_fixup(kmem_cache);
> +	caches++;
> +	/* Free temporary boot structure */
> +	free_pages((unsigned long)temp_kmem_cache, order);
> +
> +	/* Now we can use the kmem_cache to allocate kmalloc slabs */
>  
>  	/*
>  	 * Patch up the size_index table if we have strange large alignment
> @@ -3019,6 +3099,25 @@ void __init kmem_cache_init(void)
>  			size_index[size_index_elem(i)] = 8;
>  	}
>  
> +	/* Caches that are not of the two-to-the-power-of size */
> +	if (KMALLOC_MIN_SIZE <= 32) {
> +		create_kmalloc_cache(&kmalloc_caches[1],
> +				"kmalloc-96", 96, 0);
> +		caches++;
> +	}
> +
> +	if (KMALLOC_MIN_SIZE <= 64) {
> +		create_kmalloc_cache(&kmalloc_caches[2],
> +				"kmalloc-192", 192, 0);
> +		caches++;
> +	}
> +
> +	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
> +		create_kmalloc_cache(&kmalloc_caches[i],
> +			"kmalloc", 1 << i, 0);
> +		caches++;
> +	}
> +
>  	slab_state = UP;
>  
>  	/* Provide the correct kmalloc names now that the caches are up */
> @@ -3026,24 +3125,18 @@ void __init kmem_cache_init(void)
>  		char *s = kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
>  
>  		BUG_ON(!s);
> -		kmalloc_caches[i].name = s;
> +		kmalloc_caches[i]->name = s;
>  	}
>  
>  #ifdef CONFIG_SMP
>  	register_cpu_notifier(&slab_notifier);
>  #endif
> -#ifdef CONFIG_NUMA
> -	kmem_size = offsetof(struct kmem_cache, node) +
> -				nr_node_ids * sizeof(struct kmem_cache_node *);
> -#else
> -	kmem_size = sizeof(struct kmem_cache);
> -#endif
>  
>  #ifdef CONFIG_ZONE_DMA
> -	for (i = 1; i < SLUB_PAGE_SHIFT; i++) {
> -		struct kmem_cache *s = &kmalloc_caches[i];
> +	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
> +		struct kmem_cache *s = kmalloc_caches[i];
>  
> -		if (s->size) {
> +		if (s && s->size) {
>  			char *name = kasprintf(GFP_NOWAIT,
>  				 "dma-kmalloc-%d", s->objsize);
>  
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
