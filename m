Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id EA6D06B01AE
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:31:35 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id g10so627645pdj.8
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 23:31:35 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id gc6si14034pac.152.2014.06.11.23.31.32
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 23:31:34 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:35:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] slab: Use get_node() and kmem_cache_node() functions
Message-ID: <20140612063530.GB19918@js1304-P5Q-DELUXE>
References: <20140611191510.082006044@linux.com>
 <20140611191519.182409067@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140611191519.182409067@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jun 11, 2014 at 02:15:13PM -0500, Christoph Lameter wrote:
> Use the two functions to simplify the code avoiding numerous explicit
> checks coded checking for a certain node to be online.
> 
> Get rid of various repeated calculations of kmem_cache_node structures.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c	2014-06-10 13:51:07.751070658 -0500
> +++ linux/mm/slab.c	2014-06-10 14:14:47.821503296 -0500
> @@ -267,7 +267,7 @@ static void kmem_cache_node_init(struct
>  #define MAKE_LIST(cachep, listp, slab, nodeid)				\
>  	do {								\
>  		INIT_LIST_HEAD(listp);					\
> -		list_splice(&(cachep->node[nodeid]->slab), listp);	\
> +		list_splice(&get_node(cachep, nodeid)->slab, listp);	\
>  	} while (0)
>  
>  #define	MAKE_ALL_LISTS(cachep, ptr, nodeid)				\
> @@ -455,16 +455,11 @@ static struct lock_class_key debugobj_al
>  
>  static void slab_set_lock_classes(struct kmem_cache *cachep,
>  		struct lock_class_key *l3_key, struct lock_class_key *alc_key,
> -		int q)
> +		struct kmem_cache_node *n)
>  {
>  	struct array_cache **alc;
> -	struct kmem_cache_node *n;
>  	int r;
>  
> -	n = cachep->node[q];
> -	if (!n)
> -		return;
> -
>  	lockdep_set_class(&n->list_lock, l3_key);
>  	alc = n->alien;
>  	/*
> @@ -482,17 +477,19 @@ static void slab_set_lock_classes(struct
>  	}
>  }
>  
> -static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep, int node)
> +static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep,
> +	struct kmem_cache_node *n)
>  {
> -	slab_set_lock_classes(cachep, &debugobj_l3_key, &debugobj_alc_key, node);
> +	slab_set_lock_classes(cachep, &debugobj_l3_key, &debugobj_alc_key, n);
>  }
>  
>  static void slab_set_debugobj_lock_classes(struct kmem_cache *cachep)
>  {
>  	int node;
> +	struct kmem_cache_node *n;
>  
> -	for_each_online_node(node)
> -		slab_set_debugobj_lock_classes_node(cachep, node);
> +	for_each_kmem_cache_node(cachep, node, h)
> +		slab_set_debugobj_lock_classes_node(cachep, n);
>  }
>  
>  static void init_node_lock_keys(int q)
> @@ -509,31 +506,30 @@ static void init_node_lock_keys(int q)
>  		if (!cache)
>  			continue;
>  
> -		n = cache->node[q];
> +		n = get_node(cache, q);
>  		if (!n || OFF_SLAB(cache))
>  			continue;
>  
>  		slab_set_lock_classes(cache, &on_slab_l3_key,
> -				&on_slab_alc_key, q);
> +				&on_slab_alc_key, n);
>  	}
>  }
>  
> -static void on_slab_lock_classes_node(struct kmem_cache *cachep, int q)
> +static void on_slab_lock_classes_node(struct kmem_cache *cachep,
> +	struct kmem_cache_node *n)
>  {
> -	if (!cachep->node[q])
> -		return;
> -
>  	slab_set_lock_classes(cachep, &on_slab_l3_key,
> -			&on_slab_alc_key, q);
> +			&on_slab_alc_key, n);
>  }

Hello,

on_slab_lock_classes_node() definition differs with the !LOCKDEP case.
So if you turn on lockdep, compile error occurs.

>  
>  static inline void on_slab_lock_classes(struct kmem_cache *cachep)
>  {
>  	int node;
> +	struct kmem_cache_node *n;
>  
>  	VM_BUG_ON(OFF_SLAB(cachep));
> -	for_each_node(node)
> -		on_slab_lock_classes_node(cachep, node);
> +	for_each_kmem_cache_node(cachep, node, h)
> +		on_slab_lock_classes_node(cachep, h);
>  }

%s/h/n

>  
>  static inline void init_lock_keys(void)
> @@ -556,7 +552,8 @@ static inline void on_slab_lock_classes(
>  {
>  }
>  
> -static inline void on_slab_lock_classes_node(struct kmem_cache *cachep, int node)
> +static inline void on_slab_lock_classes_node(struct kmem_cache *cachep,
> +	int node, struct kmem_cache_node *n)
>  {
>  }

Here is different definition,

>  
> @@ -774,7 +771,7 @@ static inline bool is_slab_pfmemalloc(st
>  static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
>  						struct array_cache *ac)
>  {
> -	struct kmem_cache_node *n = cachep->node[numa_mem_id()];
> +	struct kmem_cache_node *n = get_node(cachep,numa_mem_id());

after comma, one blank will be needed

>  	struct page *page;
>  	unsigned long flags;
>  
> @@ -829,7 +826,7 @@ static void *__ac_get_obj(struct kmem_ca
>  		 * If there are empty slabs on the slabs_free list and we are
>  		 * being forced to refill the cache, mark this one !pfmemalloc.
>  		 */
> -		n = cachep->node[numa_mem_id()];
> +		n = get_node(cachep, numa_mem_id());
>  		if (!list_empty(&n->slabs_free) && force_refill) {
>  			struct page *page = virt_to_head_page(objp);
>  			ClearPageSlabPfmemalloc(page);
> @@ -979,7 +976,7 @@ static void free_alien_cache(struct arra
>  static void __drain_alien_cache(struct kmem_cache *cachep,
>  				struct array_cache *ac, int node)
>  {
> -	struct kmem_cache_node *n = cachep->node[node];
> +	struct kmem_cache_node *n = get_node(cachep, node);
>  
>  	if (ac->avail) {
>  		spin_lock(&n->list_lock);
> @@ -1047,7 +1044,7 @@ static inline int cache_free_alien(struc
>  	if (likely(nodeid == node))
>  		return 0;
>  
> -	n = cachep->node[node];
> +	n = get_node(cachep, node);
>  	STATS_INC_NODEFREES(cachep);
>  	if (n->alien && n->alien[nodeid]) {
>  		alien = n->alien[nodeid];
> @@ -1059,9 +1056,10 @@ static inline int cache_free_alien(struc
>  		ac_put_obj(cachep, alien, objp);
>  		spin_unlock(&alien->lock);
>  	} else {
> -		spin_lock(&(cachep->node[nodeid])->list_lock);
> +		n = get_node(cachep, nodeid);
> +		spin_lock(&n->list_lock);
>  		free_block(cachep, &objp, 1, nodeid);
> -		spin_unlock(&(cachep->node[nodeid])->list_lock);
> +		spin_unlock(&n->list_lock);
>  	}
>  	return 1;
>  }
> @@ -1088,7 +1086,8 @@ static int init_cache_node_node(int node
>  		 * begin anything. Make sure some other cpu on this
>  		 * node has not already allocated this
>  		 */
> -		if (!cachep->node[node]) {
> +		n = get_node(cachep, node);
> +		if (!n) {
>  			n = kmalloc_node(memsize, GFP_KERNEL, node);
>  			if (!n)
>  				return -ENOMEM;
> @@ -1104,11 +1103,11 @@ static int init_cache_node_node(int node
>  			cachep->node[node] = n;
>  		}
>  
> -		spin_lock_irq(&cachep->node[node]->list_lock);
> -		cachep->node[node]->free_limit =
> +		spin_lock_irq(&n->list_lock);
> +		n->free_limit =
>  			(1 + nr_cpus_node(node)) *
>  			cachep->batchcount + cachep->num;
> -		spin_unlock_irq(&cachep->node[node]->list_lock);
> +		spin_unlock_irq(&n->list_lock);
>  	}
>  	return 0;
>  }
> @@ -1134,7 +1133,7 @@ static void cpuup_canceled(long cpu)
>  		/* cpu is dead; no one can alloc from it. */
>  		nc = cachep->array[cpu];
>  		cachep->array[cpu] = NULL;
> -		n = cachep->node[node];
> +		n = get_node(cachep, node);
>  
>  		if (!n)
>  			goto free_array_cache;
> @@ -1177,7 +1176,7 @@ free_array_cache:
>  	 * shrink each nodelist to its limit.
>  	 */
>  	list_for_each_entry(cachep, &slab_caches, list) {
> -		n = cachep->node[node];
> +		n = get_node(cachep, node);
>  		if (!n)
>  			continue;
>  		drain_freelist(cachep, n, slabs_tofree(cachep, n));
> @@ -1232,7 +1231,7 @@ static int cpuup_prepare(long cpu)
>  			}
>  		}
>  		cachep->array[cpu] = nc;
> -		n = cachep->node[node];
> +		n = get_node(cachep, node);
>  		BUG_ON(!n);
>  
>  		spin_lock_irq(&n->list_lock);
> @@ -1257,7 +1256,7 @@ static int cpuup_prepare(long cpu)
>  			slab_set_debugobj_lock_classes_node(cachep, node);
>  		else if (!OFF_SLAB(cachep) &&
>  			 !(cachep->flags & SLAB_DESTROY_BY_RCU))
> -			on_slab_lock_classes_node(cachep, node);
> +			on_slab_lock_classes_node(cachep, node, n);
>  	}
>  	init_node_lock_keys(node);
>  
> @@ -1343,7 +1342,7 @@ static int __meminit drain_cache_node_no
>  	list_for_each_entry(cachep, &slab_caches, list) {
>  		struct kmem_cache_node *n;
>  
> -		n = cachep->node[node];
> +		n = get_node(cachep, node);
>  		if (!n)
>  			continue;
>  
> @@ -1638,14 +1637,10 @@ slab_out_of_memory(struct kmem_cache *ca
>  	printk(KERN_WARNING "  cache: %s, object size: %d, order: %d\n",
>  		cachep->name, cachep->size, cachep->gfporder);
>  
> -	for_each_online_node(node) {
> +	for_each_kmem_cache_node(cachep, node, n) {
>  		unsigned long active_objs = 0, num_objs = 0, free_objects = 0;
>  		unsigned long active_slabs = 0, num_slabs = 0;
>  
> -		n = cachep->node[node];
> -		if (!n)
> -			continue;
> -
>  		spin_lock_irqsave(&n->list_lock, flags);
>  		list_for_each_entry(page, &n->slabs_full, lru) {
>  			active_objs += cachep->num;
> @@ -2380,7 +2375,7 @@ static void check_spinlock_acquired(stru
>  {
>  #ifdef CONFIG_SMP
>  	check_irq_off();
> -	assert_spin_locked(&cachep->node[numa_mem_id()]->list_lock);
> +	assert_spin_locked(&get_node(cachep, numa_mem_id())->list_lock);
>  #endif
>  }
>  
> @@ -2388,7 +2383,7 @@ static void check_spinlock_acquired_node
>  {
>  #ifdef CONFIG_SMP
>  	check_irq_off();
> -	assert_spin_locked(&cachep->node[node]->list_lock);
> +	assert_spin_locked(&get_node(cachep, node)->list_lock);
>  #endif
>  }
>  
> @@ -2408,12 +2403,14 @@ static void do_drain(void *arg)
>  	struct kmem_cache *cachep = arg;
>  	struct array_cache *ac;
>  	int node = numa_mem_id();
> +	struct kmem_cache_node *n;
>  
>  	check_irq_off();
>  	ac = cpu_cache_get(cachep);
> -	spin_lock(&cachep->node[node]->list_lock);
> +	n = get_node(cachep, node);
> +	spin_lock(&n->list_lock);
>  	free_block(cachep, ac->entry, ac->avail, node);
> -	spin_unlock(&cachep->node[node]->list_lock);
> +	spin_unlock(&n->list_lock);
>  	ac->avail = 0;
>  }
>  
> @@ -2424,17 +2421,12 @@ static void drain_cpu_caches(struct kmem
>  
>  	on_each_cpu(do_drain, cachep, 1);
>  	check_irq_on();
> -	for_each_online_node(node) {
> -		n = cachep->node[node];
> -		if (n && n->alien)
> +	for_each_kmem_cache_node(cachep, node, n)
> +		if (n->alien)
>  			drain_alien_cache(cachep, n->alien);
> -	}
>  
> -	for_each_online_node(node) {
> -		n = cachep->node[node];
> -		if (n)
> -			drain_array(cachep, n, n->shared, 1, node);
> -	}
> +	for_each_kmem_cache_node(cachep, node, n)
> +		drain_array(cachep, n, n->shared, 1, node);
>  }
>  
>  /*
> @@ -2480,17 +2472,14 @@ out:
>  
>  int __kmem_cache_shrink(struct kmem_cache *cachep)
>  {
> -	int ret = 0, i = 0;
> +	int ret = 0;
> +	int node;
>  	struct kmem_cache_node *n;
>  
>  	drain_cpu_caches(cachep);
>  
>  	check_irq_on();
> -	for_each_online_node(i) {
> -		n = cachep->node[i];
> -		if (!n)
> -			continue;
> -
> +	for_each_kmem_cache_node(cachep, node, n) {
>  		drain_freelist(cachep, n, slabs_tofree(cachep, n));
>  
>  		ret += !list_empty(&n->slabs_full) ||
> @@ -2512,13 +2501,11 @@ int __kmem_cache_shutdown(struct kmem_ca
>  	    kfree(cachep->array[i]);
>  
>  	/* NUMA: free the node structures */
> -	for_each_online_node(i) {
> -		n = cachep->node[i];
> -		if (n) {
> -			kfree(n->shared);
> -			free_alien_cache(n->alien);
> -			kfree(n);
> -		}
> +	for_each_kmem_cache_node(cachep, i, n) {
> +		kfree(n->shared);
> +		free_alien_cache(n->alien);
> +		kfree(n);
> +		cachep->node[i] = NULL;
>  	}
>  	return 0;
>  }
> @@ -2696,7 +2683,7 @@ static int cache_grow(struct kmem_cache
>  
>  	/* Take the node list lock to change the colour_next on this node */
>  	check_irq_off();
> -	n = cachep->node[nodeid];
> +	n = get_node(cachep, nodeid);
>  	spin_lock(&n->list_lock);
>  
>  	/* Get colour for the slab, and cal the next value. */
> @@ -2864,7 +2851,7 @@ retry:
>  		 */
>  		batchcount = BATCHREFILL_LIMIT;
>  	}
> -	n = cachep->node[node];
> +	n = get_node(cachep, node);
>  
>  	BUG_ON(ac->avail > 0 || !n);
>  	spin_lock(&n->list_lock);
> @@ -3108,8 +3095,8 @@ retry:
>  		nid = zone_to_nid(zone);
>  
>  		if (cpuset_zone_allowed_hardwall(zone, flags) &&
> -			cache->node[nid] &&
> -			cache->node[nid]->free_objects) {
> +			get_node(cache, nid) &&
> +			get_node(cache, nid)->free_objects) {
>  				obj = ____cache_alloc_node(cache,
>  					flags | GFP_THISNODE, nid);
>  				if (obj)
> @@ -3172,7 +3159,7 @@ static void *____cache_alloc_node(struct
>  	int x;
>  
>  	VM_BUG_ON(nodeid > num_online_nodes());
> -	n = cachep->node[nodeid];
> +	n = get_node(cachep, nodeid);
>  	BUG_ON(!n);
>  
>  retry:
> @@ -3243,7 +3230,7 @@ slab_alloc_node(struct kmem_cache *cache
>  	if (nodeid == NUMA_NO_NODE)
>  		nodeid = slab_node;
>  
> -	if (unlikely(!cachep->node[nodeid])) {
> +	if (unlikely(!get_node(cachep, nodeid))) {
>  		/* Node not bootstrapped yet */
>  		ptr = fallback_alloc(cachep, flags);
>  		goto out;
> @@ -3359,7 +3346,7 @@ static void free_block(struct kmem_cache
>  		objp = objpp[i];
>  
>  		page = virt_to_head_page(objp);
> -		n = cachep->node[node];
> +		n = get_node(cachep, node);
>  		list_del(&page->lru);
>  		check_spinlock_acquired_node(cachep, node);
>  		slab_put_obj(cachep, page, objp, node);
> @@ -3401,7 +3388,7 @@ static void cache_flusharray(struct kmem
>  	BUG_ON(!batchcount || batchcount > ac->avail);
>  #endif
>  	check_irq_off();
> -	n = cachep->node[node];
> +	n = get_node(cachep, node);
>  	spin_lock(&n->list_lock);
>  	if (n->shared) {
>  		struct array_cache *shared_array = n->shared;
> @@ -3714,7 +3701,7 @@ static int alloc_kmem_cache_node(struct
>  			}
>  		}
>  
> -		n = cachep->node[node];
> +		n = get_node(cachep, node);
>  		if (n) {
>  			struct array_cache *shared = n->shared;
>  
> @@ -3759,8 +3746,8 @@ fail:
>  		/* Cache is not active yet. Roll back what we did */
>  		node--;
>  		while (node >= 0) {
> -			if (cachep->node[node]) {
> -				n = cachep->node[node];
> +			if (get_node(cachep, node)) {
> +				n = get_node(cachep, node);

Could you do this as following?

n = get_node(cachep, node);
if (n) {
        ...
}

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
