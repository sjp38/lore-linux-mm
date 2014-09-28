Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B7CA86B0035
	for <linux-mm@kvack.org>; Sun, 28 Sep 2014 02:24:54 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so3604240pab.26
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 23:24:54 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id rx10si17124994pab.77.2014.09.27.23.24.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 27 Sep 2014 23:24:53 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so758734pdi.38
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 23:24:53 -0700 (PDT)
Date: Sat, 27 Sep 2014 23:24:49 -0700
From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: [REGRESSION] [PATCH 1/3] mm/slab: use percpu allocator for cpu
 cache
Message-ID: <20140928062449.GA1277@hudson.localdomain>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 21, 2014 at 05:11:13PM +0900, Joonsoo Kim wrote:
> Because of chicken and egg problem, initializaion of SLAB is really
> complicated. We need to allocate cpu cache through SLAB to make
> the kmem_cache works, but, before initialization of kmem_cache,
> allocation through SLAB is impossible.
> 
> On the other hand, SLUB does initialization with more simple way. It
> uses percpu allocator to allocate cpu cache so there is no chicken and
> egg problem.
> 
> So, this patch try to use percpu allocator in SLAB. This simplify
> initialization step in SLAB so that we could maintain SLAB code more
> easily.
> 
> From my testing, there is no performance difference.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/slab_def.h |   20 +---
>  mm/slab.c                |  237 +++++++++++++++-------------------------------
>  mm/slab.h                |    1 -
>  3 files changed, 81 insertions(+), 177 deletions(-)
> 
> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index 8235dfb..b869d16 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -8,6 +8,8 @@
>   */
>  
>  struct kmem_cache {
> +	struct array_cache __percpu *cpu_cache;
> +
>  /* 1) Cache tunables. Protected by slab_mutex */
>  	unsigned int batchcount;
>  	unsigned int limit;
> @@ -71,23 +73,7 @@ struct kmem_cache {
>  	struct memcg_cache_params *memcg_params;
>  #endif
>  
> -/* 6) per-cpu/per-node data, touched during every alloc/free */
> -	/*
> -	 * We put array[] at the end of kmem_cache, because we want to size
> -	 * this array to nr_cpu_ids slots instead of NR_CPUS
> -	 * (see kmem_cache_init())
> -	 * We still use [NR_CPUS] and not [1] or [0] because cache_cache
> -	 * is statically defined, so we reserve the max number of cpus.
> -	 *
> -	 * We also need to guarantee that the list is able to accomodate a
> -	 * pointer for each node since "nodelists" uses the remainder of
> -	 * available pointers.
> -	 */
> -	struct kmem_cache_node **node;
> -	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
> -	/*
> -	 * Do not add fields after array[]
> -	 */
> +	struct kmem_cache_node *node[MAX_NUMNODES];
>  };
>  
>  #endif	/* _LINUX_SLAB_DEF_H */
> diff --git a/mm/slab.c b/mm/slab.c
> index 5927a17..09b060e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -237,11 +237,10 @@ struct arraycache_init {
>  /*
>   * Need this for bootstrapping a per node allocator.
>   */
> -#define NUM_INIT_LISTS (3 * MAX_NUMNODES)
> +#define NUM_INIT_LISTS (2 * MAX_NUMNODES)
>  static struct kmem_cache_node __initdata init_kmem_cache_node[NUM_INIT_LISTS];
>  #define	CACHE_CACHE 0
> -#define	SIZE_AC MAX_NUMNODES
> -#define	SIZE_NODE (2 * MAX_NUMNODES)
> +#define	SIZE_NODE (MAX_NUMNODES)
>  
>  static int drain_freelist(struct kmem_cache *cache,
>  			struct kmem_cache_node *n, int tofree);
> @@ -253,7 +252,6 @@ static void cache_reap(struct work_struct *unused);
>  
>  static int slab_early_init = 1;
>  
> -#define INDEX_AC kmalloc_index(sizeof(struct arraycache_init))
>  #define INDEX_NODE kmalloc_index(sizeof(struct kmem_cache_node))
>  
>  static void kmem_cache_node_init(struct kmem_cache_node *parent)
> @@ -458,9 +456,6 @@ static inline unsigned int obj_to_index(const struct kmem_cache *cache,
>  	return reciprocal_divide(offset, cache->reciprocal_buffer_size);
>  }
>  
> -static struct arraycache_init initarray_generic =
> -    { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
> -
>  /* internal cache of cache description objs */
>  static struct kmem_cache kmem_cache_boot = {
>  	.batchcount = 1,
> @@ -476,7 +471,7 @@ static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
>  
>  static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
>  {
> -	return cachep->array[smp_processor_id()];
> +	return this_cpu_ptr(cachep->cpu_cache);
>  }
>  
>  static size_t calculate_freelist_size(int nr_objs, size_t align)
> @@ -1096,9 +1091,6 @@ static void cpuup_canceled(long cpu)
>  		struct alien_cache **alien;
>  		LIST_HEAD(list);
>  
> -		/* cpu is dead; no one can alloc from it. */
> -		nc = cachep->array[cpu];
> -		cachep->array[cpu] = NULL;
>  		n = get_node(cachep, node);
>  
>  		if (!n)
> @@ -1108,6 +1100,9 @@ static void cpuup_canceled(long cpu)
>  
>  		/* Free limit for this kmem_cache_node */
>  		n->free_limit -= cachep->batchcount;
> +
> +		/* cpu is dead; no one can alloc from it. */
> +		nc = per_cpu_ptr(cachep->cpu_cache, cpu);
>  		if (nc)
>  			free_block(cachep, nc->entry, nc->avail, node, &list);
>  
> @@ -1135,7 +1130,6 @@ static void cpuup_canceled(long cpu)
>  		}
>  free_array_cache:
>  		slabs_destroy(cachep, &list);
> -		kfree(nc);
>  	}
>  	/*
>  	 * In the previous loop, all the objects were freed to
> @@ -1172,32 +1166,23 @@ static int cpuup_prepare(long cpu)
>  	 * array caches
>  	 */
>  	list_for_each_entry(cachep, &slab_caches, list) {
> -		struct array_cache *nc;
>  		struct array_cache *shared = NULL;
>  		struct alien_cache **alien = NULL;
>  
> -		nc = alloc_arraycache(node, cachep->limit,
> -					cachep->batchcount, GFP_KERNEL);
> -		if (!nc)
> -			goto bad;
>  		if (cachep->shared) {
>  			shared = alloc_arraycache(node,
>  				cachep->shared * cachep->batchcount,
>  				0xbaadf00d, GFP_KERNEL);
> -			if (!shared) {
> -				kfree(nc);
> +			if (!shared)
>  				goto bad;
> -			}
>  		}
>  		if (use_alien_caches) {
>  			alien = alloc_alien_cache(node, cachep->limit, GFP_KERNEL);
>  			if (!alien) {
>  				kfree(shared);
> -				kfree(nc);
>  				goto bad;
>  			}
>  		}
> -		cachep->array[cpu] = nc;
>  		n = get_node(cachep, node);
>  		BUG_ON(!n);
>  
> @@ -1389,15 +1374,6 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
>  }
>  
>  /*
> - * The memory after the last cpu cache pointer is used for the
> - * the node pointer.
> - */
> -static void setup_node_pointer(struct kmem_cache *cachep)
> -{
> -	cachep->node = (struct kmem_cache_node **)&cachep->array[nr_cpu_ids];
> -}
> -
> -/*
>   * Initialisation.  Called after the page allocator have been initialised and
>   * before smp_init().
>   */
> @@ -1408,7 +1384,6 @@ void __init kmem_cache_init(void)
>  	BUILD_BUG_ON(sizeof(((struct page *)NULL)->lru) <
>  					sizeof(struct rcu_head));
>  	kmem_cache = &kmem_cache_boot;
> -	setup_node_pointer(kmem_cache);
>  
>  	if (num_possible_nodes() == 1)
>  		use_alien_caches = 0;
> @@ -1416,8 +1391,6 @@ void __init kmem_cache_init(void)
>  	for (i = 0; i < NUM_INIT_LISTS; i++)
>  		kmem_cache_node_init(&init_kmem_cache_node[i]);
>  
> -	set_up_node(kmem_cache, CACHE_CACHE);
> -
>  	/*
>  	 * Fragmentation resistance on low memory - only use bigger
>  	 * page orders on machines with more than 32MB of memory if
> @@ -1452,49 +1425,22 @@ void __init kmem_cache_init(void)
>  	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
>  	 */
>  	create_boot_cache(kmem_cache, "kmem_cache",
> -		offsetof(struct kmem_cache, array[nr_cpu_ids]) +
> +		offsetof(struct kmem_cache, node) +
>  				  nr_node_ids * sizeof(struct kmem_cache_node *),
>  				  SLAB_HWCACHE_ALIGN);
>  	list_add(&kmem_cache->list, &slab_caches);
> -
> -	/* 2+3) create the kmalloc caches */
> +	slab_state = PARTIAL;
>  
>  	/*
> -	 * Initialize the caches that provide memory for the array cache and the
> -	 * kmem_cache_node structures first.  Without this, further allocations will
> -	 * bug.
> +	 * Initialize the caches that provide memory for the  kmem_cache_node
> +	 * structures first.  Without this, further allocations will bug.
>  	 */
> -
> -	kmalloc_caches[INDEX_AC] = create_kmalloc_cache("kmalloc-ac",
> -					kmalloc_size(INDEX_AC), ARCH_KMALLOC_FLAGS);
> -
> -	if (INDEX_AC != INDEX_NODE)
> -		kmalloc_caches[INDEX_NODE] =
> -			create_kmalloc_cache("kmalloc-node",
> +	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache("kmalloc-node",
>  				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
> +	slab_state = PARTIAL_NODE;
>  
>  	slab_early_init = 0;
>  
> -	/* 4) Replace the bootstrap head arrays */
> -	{
> -		struct array_cache *ptr;
> -
> -		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
> -
> -		memcpy(ptr, cpu_cache_get(kmem_cache),
> -		       sizeof(struct arraycache_init));
> -
> -		kmem_cache->array[smp_processor_id()] = ptr;
> -
> -		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
> -
> -		BUG_ON(cpu_cache_get(kmalloc_caches[INDEX_AC])
> -		       != &initarray_generic.cache);
> -		memcpy(ptr, cpu_cache_get(kmalloc_caches[INDEX_AC]),
> -		       sizeof(struct arraycache_init));
> -
> -		kmalloc_caches[INDEX_AC]->array[smp_processor_id()] = ptr;
> -	}
>  	/* 5) Replace the bootstrap kmem_cache_node */
>  	{
>  		int nid;
> @@ -1502,13 +1448,8 @@ void __init kmem_cache_init(void)
>  		for_each_online_node(nid) {
>  			init_list(kmem_cache, &init_kmem_cache_node[CACHE_CACHE + nid], nid);
>  
> -			init_list(kmalloc_caches[INDEX_AC],
> -				  &init_kmem_cache_node[SIZE_AC + nid], nid);
> -
> -			if (INDEX_AC != INDEX_NODE) {
> -				init_list(kmalloc_caches[INDEX_NODE],
> +			init_list(kmalloc_caches[INDEX_NODE],
>  					  &init_kmem_cache_node[SIZE_NODE + nid], nid);
> -			}
>  		}
>  	}
>  
> @@ -2041,56 +1982,63 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
>  	return left_over;
>  }
>  
> +static struct array_cache __percpu *__alloc_kmem_cache_cpus(
> +		struct kmem_cache *cachep, int entries, int batchcount)
> +{
> +	int cpu;
> +	size_t size;
> +	struct array_cache __percpu *cpu_cache;
> +
> +	size = sizeof(void *) * entries + sizeof(struct array_cache);
> +	cpu_cache = __alloc_percpu(size, 0);
> +
> +	if (!cpu_cache)
> +		return NULL;
> +
> +	for_each_possible_cpu(cpu) {
> +		init_arraycache(per_cpu_ptr(cpu_cache, cpu),
> +				entries, batchcount);
> +	}
> +
> +	return cpu_cache;
> +}
> +
> +static int alloc_kmem_cache_cpus(struct kmem_cache *cachep, int entries,
> +				int batchcount)
> +{
> +	cachep->cpu_cache = __alloc_kmem_cache_cpus(cachep, entries,
> +							batchcount);
> +	if (!cachep->cpu_cache)
> +		return 1;
> +
> +	return 0;
> +}
> +
>  static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
>  {
>  	if (slab_state >= FULL)
>  		return enable_cpucache(cachep, gfp);
>  
> +	if (alloc_kmem_cache_cpus(cachep, 1, 1))
> +		return 1;
> +
>  	if (slab_state == DOWN) {
> -		/*
> -		 * Note: Creation of first cache (kmem_cache).
> -		 * The setup_node is taken care
> -		 * of by the caller of __kmem_cache_create
> -		 */
> -		cachep->array[smp_processor_id()] = &initarray_generic.cache;
> -		slab_state = PARTIAL;
> +		/* Creation of first cache (kmem_cache). */
> +		set_up_node(kmem_cache, CACHE_CACHE);
>  	} else if (slab_state == PARTIAL) {
> -		/*
> -		 * Note: the second kmem_cache_create must create the cache
> -		 * that's used by kmalloc(24), otherwise the creation of
> -		 * further caches will BUG().
> -		 */
> -		cachep->array[smp_processor_id()] = &initarray_generic.cache;
> -
> -		/*
> -		 * If the cache that's used by kmalloc(sizeof(kmem_cache_node)) is
> -		 * the second cache, then we need to set up all its node/,
> -		 * otherwise the creation of further caches will BUG().
> -		 */
> -		set_up_node(cachep, SIZE_AC);
> -		if (INDEX_AC == INDEX_NODE)
> -			slab_state = PARTIAL_NODE;
> -		else
> -			slab_state = PARTIAL_ARRAYCACHE;
> +		/* For kmem_cache_node */
> +		set_up_node(cachep, SIZE_NODE);
>  	} else {
> -		/* Remaining boot caches */
> -		cachep->array[smp_processor_id()] =
> -			kmalloc(sizeof(struct arraycache_init), gfp);
> +		int node;
>  
> -		if (slab_state == PARTIAL_ARRAYCACHE) {
> -			set_up_node(cachep, SIZE_NODE);
> -			slab_state = PARTIAL_NODE;
> -		} else {
> -			int node;
> -			for_each_online_node(node) {
> -				cachep->node[node] =
> -				    kmalloc_node(sizeof(struct kmem_cache_node),
> -						gfp, node);
> -				BUG_ON(!cachep->node[node]);
> -				kmem_cache_node_init(cachep->node[node]);
> -			}
> +		for_each_online_node(node) {
> +			cachep->node[node] = kmalloc_node(
> +				sizeof(struct kmem_cache_node), gfp, node);
> +			BUG_ON(!cachep->node[node]);
> +			kmem_cache_node_init(cachep->node[node]);
>  		}
>  	}
> +
>  	cachep->node[numa_mem_id()]->next_reap =
>  			jiffies + REAPTIMEOUT_NODE +
>  			((unsigned long)cachep) % REAPTIMEOUT_NODE;
> @@ -2194,7 +2142,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>  	else
>  		gfp = GFP_NOWAIT;
>  
> -	setup_node_pointer(cachep);
>  #if DEBUG
>  
>  	/*
> @@ -2451,8 +2398,7 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
>  	if (rc)
>  		return rc;
>  
> -	for_each_online_cpu(i)
> -	    kfree(cachep->array[i]);
> +	free_percpu(cachep->cpu_cache);
>  
>  	/* NUMA: free the node structures */
>  	for_each_kmem_cache_node(cachep, i, n) {
> @@ -3700,72 +3646,45 @@ fail:
>  	return -ENOMEM;
>  }
>  
> -struct ccupdate_struct {
> -	struct kmem_cache *cachep;
> -	struct array_cache *new[0];
> -};
> -
> -static void do_ccupdate_local(void *info)
> -{
> -	struct ccupdate_struct *new = info;
> -	struct array_cache *old;
> -
> -	check_irq_off();
> -	old = cpu_cache_get(new->cachep);
> -
> -	new->cachep->array[smp_processor_id()] = new->new[smp_processor_id()];
> -	new->new[smp_processor_id()] = old;
> -}
> -
>  /* Always called with the slab_mutex held */
>  static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
>  				int batchcount, int shared, gfp_t gfp)
>  {
> -	struct ccupdate_struct *new;
> -	int i;
> +	struct array_cache __percpu *cpu_cache, *prev;
> +	int cpu;
>  
> -	new = kzalloc(sizeof(*new) + nr_cpu_ids * sizeof(struct array_cache *),
> -		      gfp);
> -	if (!new)
> +	cpu_cache = __alloc_kmem_cache_cpus(cachep, limit, batchcount);
> +	if (!cpu_cache)
>  		return -ENOMEM;
>  
> -	for_each_online_cpu(i) {
> -		new->new[i] = alloc_arraycache(cpu_to_mem(i), limit,
> -						batchcount, gfp);
> -		if (!new->new[i]) {
> -			for (i--; i >= 0; i--)
> -				kfree(new->new[i]);
> -			kfree(new);
> -			return -ENOMEM;
> -		}
> -	}
> -	new->cachep = cachep;
> -
> -	on_each_cpu(do_ccupdate_local, (void *)new, 1);
> +	prev = cachep->cpu_cache;
> +	cachep->cpu_cache = cpu_cache;
> +	kick_all_cpus_sync();
>  
>  	check_irq_on();
>  	cachep->batchcount = batchcount;
>  	cachep->limit = limit;
>  	cachep->shared = shared;
>  
> -	for_each_online_cpu(i) {
> +	if (!prev)
> +		goto alloc_node;
> +
> +	for_each_online_cpu(cpu) {
>  		LIST_HEAD(list);
> -		struct array_cache *ccold = new->new[i];
>  		int node;
>  		struct kmem_cache_node *n;
> +		struct array_cache *ac = per_cpu_ptr(prev, cpu);
>  
> -		if (!ccold)
> -			continue;
> -
> -		node = cpu_to_mem(i);
> +		node = cpu_to_mem(cpu);
>  		n = get_node(cachep, node);
>  		spin_lock_irq(&n->list_lock);
> -		free_block(cachep, ccold->entry, ccold->avail, node, &list);
> +		free_block(cachep, ac->entry, ac->avail, node, &list);
>  		spin_unlock_irq(&n->list_lock);
>  		slabs_destroy(cachep, &list);
> -		kfree(ccold);
>  	}
> -	kfree(new);
> +	free_percpu(prev);
> +
> +alloc_node:
>  	return alloc_kmem_cache_node(cachep, gfp);
>  }
>  
> diff --git a/mm/slab.h b/mm/slab.h
> index bd1c54a..5cb4649 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -48,7 +48,6 @@ struct kmem_cache {
>  enum slab_state {
>  	DOWN,			/* No slab functionality yet */
>  	PARTIAL,		/* SLUB: kmem_cache_node available */
> -	PARTIAL_ARRAYCACHE,	/* SLAB: kmalloc size for arraycache available */
>  	PARTIAL_NODE,		/* SLAB: kmalloc size for node struct available */
>  	UP,			/* Slab caches usable but not all extras yet */
>  	FULL			/* Everything is working */
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

I just encountered a problem on a Lenovo Carbon X1 where it will
suspend but won't resume.  A bisect indicated that this patch
is causing the problem.

997888488ef92da365b870247de773255227ce1f

I imagine the patch author, Joonsoo Kim, might have a better idea
why this is happening than I do.  But if I can provide any information
or run any tests that might be of help just let me know.

-- 
Jeremiah Mahler
jmmahler@gmail.com
http://github.com/jmahler

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
