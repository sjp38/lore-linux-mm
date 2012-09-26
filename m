Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id C0D296B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:07:10 -0400 (EDT)
Message-Id: <0000013a0430a882-06cc02cd-4623-41f6-b4c9-702e0c37acb2-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:07:08 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [09/13] slab: rename nodelists to node
References: <20120926200005.911809821@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Have a common naming between both slab caches for future changes.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2012-09-19 09:21:35.811415438 -0500
+++ linux/include/linux/slab_def.h	2012-09-19 09:21:37.499450510 -0500
@@ -88,16 +88,13 @@ struct kmem_cache {
 	 * We still use [NR_CPUS] and not [1] or [0] because cache_cache
 	 * is statically defined, so we reserve the max number of cpus.
 	 */
-	struct kmem_cache_node **nodelists;
+	struct kmem_cache_node **node;
 	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
 	/*
 	 * Do not add fields after array[]
 	 */
 };
 
-extern struct kmem_cache *cs_cachep[PAGE_SHIFT + MAX_ORDER];
-extern struct kmem_cache *cs_dmacachep[PAGE_SHIFT + MAX_ORDER];
-
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
@@ -132,10 +129,10 @@ static __always_inline void *kmalloc(siz
 
 #ifdef CONFIG_ZONE_DMA
 		if (flags & GFP_DMA)
-			cachep = cs_dmacachep[i];
+			cachep = kmalloc_dma_caches[i];
 		else
 #endif
-			cachep = cs_cachep[i];
+			cachep = kmalloc_caches[i];
 
 		ret = kmem_cache_alloc_trace(size, cachep, flags);
 
@@ -178,10 +175,10 @@ static __always_inline void *kmalloc_nod
 
 #ifdef CONFIG_ZONE_DMA
 		if (flags & GFP_DMA)
-			cachep = cs_dmacachep[i];
+			cachep = kmalloc_dma_caches[i];
 		else
 #endif
-			cachep = cs_cachep[i];
+			cachep = kmalloc_caches[i];
 
 		return kmem_cache_alloc_node_trace(size, cachep, flags, node);
 	}
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-19 09:21:35.815415526 -0500
+++ linux/mm/slab.c	2012-09-19 09:21:37.503450612 -0500
@@ -291,11 +291,6 @@ static inline void clear_obj_pfmemalloc(
 	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
 }
 
-struct kmem_cache *cs_cachep[PAGE_SHIFT + MAX_ORDER];
-EXPORT_SYMBOL(cs_cachep);
-struct kmem_cache *cs_dmacachep[PAGE_SHIFT + MAX_ORDER];
-EXPORT_SYMBOL(cs_dmacachep);
-
 /*
  * bootstrap: The caches do not work without cpuarrays anymore, but the
  * cpuarrays are allocated from the generic caches...
@@ -360,7 +355,7 @@ static void kmem_list3_init(struct kmem_
 #define MAKE_LIST(cachep, listp, slab, nodeid)				\
 	do {								\
 		INIT_LIST_HEAD(listp);					\
-		list_splice(&(cachep->nodelists[nodeid]->slab), listp);	\
+		list_splice(&(cachep->node[nodeid]->slab), listp);	\
 	} while (0)
 
 #define	MAKE_ALL_LISTS(cachep, ptr, nodeid)				\
@@ -570,7 +565,7 @@ static void slab_set_lock_classes(struct
 	struct kmem_cache_node *l3;
 	int r;
 
-	l3 = cachep->nodelists[q];
+	l3 = cachep->node[q];
 	if (!l3)
 		return;
 
@@ -613,12 +608,12 @@ static void init_node_lock_keys(int q)
 
 	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
 		struct kmem_cache_node *l3;
-		struct kmem_cache *cache = cs_cachep[i];
+		struct kmem_cache *cache = kmalloc_caches[i];
 
 		if (!cache)
 			continue;
 
-		l3 = cache->nodelists[q];
+		l3 = cache->node[q];
 		if (!l3 || OFF_SLAB(cache))
 			continue;
 
@@ -669,7 +664,7 @@ static inline struct kmem_cache *__find_
 	 * kmem_cache_create(), or __kmalloc(), before
 	 * the generic caches are initialized.
 	 */
-	BUG_ON(cs_cachep[INDEX_AC] == NULL);
+	BUG_ON(kmalloc_caches[INDEX_AC] == NULL);
 #endif
 	if (!size)
 		return ZERO_SIZE_PTR;
@@ -683,9 +678,9 @@ static inline struct kmem_cache *__find_
 	 */
 #ifdef CONFIG_ZONE_DMA
 	if (unlikely(gfpflags & GFP_DMA))
-		return cs_dmacachep[i];
+		return kmalloc_dma_caches[i];
 #endif
-	return cs_cachep[i];
+	return kmalloc_caches[i];
 }
 
 static struct kmem_cache *kmem_find_general_cachep(size_t size, gfp_t gfpflags)
@@ -893,7 +888,7 @@ static inline bool is_slab_pfmemalloc(st
 static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
 						struct array_cache *ac)
 {
-	struct kmem_cache_node *l3 = cachep->nodelists[numa_mem_id()];
+	struct kmem_cache_node *l3 = cachep->node[numa_mem_id()];
 	struct slab *slabp;
 	unsigned long flags;
 
@@ -948,7 +943,7 @@ static void *__ac_get_obj(struct kmem_ca
 		 * If there are empty slabs on the slabs_free list and we are
 		 * being forced to refill the cache, mark this one !pfmemalloc.
 		 */
-		l3 = cachep->nodelists[numa_mem_id()];
+		l3 = cachep->node[numa_mem_id()];
 		if (!list_empty(&l3->slabs_free) && force_refill) {
 			struct slab *slabp = virt_to_slab(objp);
 			ClearPageSlabPfmemalloc(virt_to_head_page(slabp->s_mem));
@@ -1098,7 +1093,7 @@ static void free_alien_cache(struct arra
 static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
-	struct kmem_cache_node *rl3 = cachep->nodelists[node];
+	struct kmem_cache_node *rl3 = cachep->node[node];
 
 	if (ac->avail) {
 		spin_lock(&rl3->list_lock);
@@ -1167,7 +1162,7 @@ static inline int cache_free_alien(struc
 	if (likely(slabp->nodeid == node))
 		return 0;
 
-	l3 = cachep->nodelists[node];
+	l3 = cachep->node[node];
 	STATS_INC_NODEFREES(cachep);
 	if (l3->alien && l3->alien[nodeid]) {
 		alien = l3->alien[nodeid];
@@ -1179,24 +1174,24 @@ static inline int cache_free_alien(struc
 		ac_put_obj(cachep, alien, objp);
 		spin_unlock(&alien->lock);
 	} else {
-		spin_lock(&(cachep->nodelists[nodeid])->list_lock);
+		spin_lock(&(cachep->node[nodeid])->list_lock);
 		free_block(cachep, &objp, 1, nodeid);
-		spin_unlock(&(cachep->nodelists[nodeid])->list_lock);
+		spin_unlock(&(cachep->node[nodeid])->list_lock);
 	}
 	return 1;
 }
 #endif
 
 /*
- * Allocates and initializes nodelists for a node on each slab cache, used for
+ * Allocates and initializes node for a node on each slab cache, used for
  * either memory or cpu hotplug.  If memory is being hot-added, the kmem_list3
  * will be allocated off-node since memory is not yet online for the new node.
- * When hotplugging memory or a cpu, existing nodelists are not replaced if
+ * When hotplugging memory or a cpu, existing node are not replaced if
  * already in use.
  *
  * Must hold slab_mutex.
  */
-static int init_cache_nodelists_node(int node)
+static int init_cache_node_node(int node)
 {
 	struct kmem_cache *cachep;
 	struct kmem_cache_node *l3;
@@ -1208,7 +1203,7 @@ static int init_cache_nodelists_node(int
 		 * begin anything. Make sure some other cpu on this
 		 * node has not already allocated this
 		 */
-		if (!cachep->nodelists[node]) {
+		if (!cachep->node[node]) {
 			l3 = kmalloc_node(memsize, GFP_KERNEL, node);
 			if (!l3)
 				return -ENOMEM;
@@ -1221,14 +1216,14 @@ static int init_cache_nodelists_node(int
 			 * go.  slab_mutex is sufficient
 			 * protection here.
 			 */
-			cachep->nodelists[node] = l3;
+			cachep->node[node] = l3;
 		}
 
-		spin_lock_irq(&cachep->nodelists[node]->list_lock);
-		cachep->nodelists[node]->free_limit =
+		spin_lock_irq(&cachep->node[node]->list_lock);
+		cachep->node[node]->free_limit =
 			(1 + nr_cpus_node(node)) *
 			cachep->batchcount + cachep->num;
-		spin_unlock_irq(&cachep->nodelists[node]->list_lock);
+		spin_unlock_irq(&cachep->node[node]->list_lock);
 	}
 	return 0;
 }
@@ -1248,7 +1243,7 @@ static void __cpuinit cpuup_canceled(lon
 		/* cpu is dead; no one can alloc from it. */
 		nc = cachep->array[cpu];
 		cachep->array[cpu] = NULL;
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 
 		if (!l3)
 			goto free_array_cache;
@@ -1291,7 +1286,7 @@ free_array_cache:
 	 * shrink each nodelist to its limit.
 	 */
 	list_for_each_entry(cachep, &slab_caches, list) {
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 		drain_freelist(cachep, l3, l3->free_objects);
@@ -1311,7 +1306,7 @@ static int __cpuinit cpuup_prepare(long
 	 * kmalloc_node allows us to add the slab to the right
 	 * kmem_list3 and not this cpu's kmem_list3
 	 */
-	err = init_cache_nodelists_node(node);
+	err = init_cache_node_node(node);
 	if (err < 0)
 		goto bad;
 
@@ -1346,7 +1341,7 @@ static int __cpuinit cpuup_prepare(long
 			}
 		}
 		cachep->array[cpu] = nc;
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		BUG_ON(!l3);
 
 		spin_lock_irq(&l3->list_lock);
@@ -1446,7 +1441,7 @@ static struct notifier_block __cpuinitda
  *
  * Must hold slab_mutex.
  */
-static int __meminit drain_cache_nodelists_node(int node)
+static int __meminit drain_cache_node_node(int node)
 {
 	struct kmem_cache *cachep;
 	int ret = 0;
@@ -1454,7 +1449,7 @@ static int __meminit drain_cache_nodelis
 	list_for_each_entry(cachep, &slab_caches, list) {
 		struct kmem_cache_node *l3;
 
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 
@@ -1483,12 +1478,12 @@ static int __meminit slab_memory_callbac
 	switch (action) {
 	case MEM_GOING_ONLINE:
 		mutex_lock(&slab_mutex);
-		ret = init_cache_nodelists_node(nid);
+		ret = init_cache_node_node(nid);
 		mutex_unlock(&slab_mutex);
 		break;
 	case MEM_GOING_OFFLINE:
 		mutex_lock(&slab_mutex);
-		ret = drain_cache_nodelists_node(nid);
+		ret = drain_cache_node_node(nid);
 		mutex_unlock(&slab_mutex);
 		break;
 	case MEM_ONLINE:
@@ -1520,7 +1515,7 @@ static void __init init_list(struct kmem
 	spin_lock_init(&ptr->list_lock);
 
 	MAKE_ALL_LISTS(cachep, ptr, nodeid);
-	cachep->nodelists[nodeid] = ptr;
+	cachep->node[nodeid] = ptr;
 }
 
 /*
@@ -1532,8 +1527,8 @@ static void __init set_up_list3s(struct
 	int node;
 
 	for_each_online_node(node) {
-		cachep->nodelists[node] = &initkmem_list3[index + node];
-		cachep->nodelists[node]->next_reap = jiffies +
+		cachep->node[node] = &initkmem_list3[index + node];
+		cachep->node[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
 		    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 	}
@@ -1541,11 +1536,11 @@ static void __init set_up_list3s(struct
 
 /*
  * The memory after the last cpu cache pointer is used for the
- * the nodelists pointer.
+ * the node pointer.
  */
-static void setup_nodelists_pointer(struct kmem_cache *s)
+static void setup_node_pointer(struct kmem_cache *s)
 {
-	s->nodelists = (struct kmem_cache_node **)&s->array[nr_cpu_ids];
+	s->node = (struct kmem_cache_node **)&s->array[nr_cpu_ids];
 }
 
 /*
@@ -1557,7 +1552,7 @@ void __init kmem_cache_init(void)
 	int i;
 
 	kmem_cache = &kmem_cache_boot;
-	setup_nodelists_pointer(kmem_cache);
+	setup_node_pointer(kmem_cache);
 
 	if (num_possible_nodes() == 1)
 		use_alien_caches = 0;
@@ -1566,7 +1561,7 @@ void __init kmem_cache_init(void)
 	for (i = 0; i < NUM_INIT_LISTS; i++) {
 		kmem_list3_init(&initkmem_list3[i]);
 		if (i < nr_node_ids)
-			kmem_cache->nodelists[i] = NULL;
+			kmem_cache->node[i] = NULL;
 	}
 	set_up_list3s(kmem_cache, CACHE_CACHE);
 
@@ -1618,11 +1613,11 @@ void __init kmem_cache_init(void)
 	 * bug.
 	 */
 
-	cs_cachep[INDEX_AC] = create_kmalloc_cache("kmalloc-ac",
+	kmalloc_caches[INDEX_AC] = create_kmalloc_cache("kmalloc-ac",
 					kmalloc_size(INDEX_AC), ARCH_KMALLOC_FLAGS);
 
 	if (INDEX_AC != INDEX_L3)
-		cs_cachep[INDEX_L3] =
+		kmalloc_caches[INDEX_L3] =
 			create_kmalloc_cache("kmalloc-l3",
 				kmalloc_size(INDEX_L3), ARCH_KMALLOC_FLAGS);
 
@@ -1634,7 +1629,7 @@ void __init kmem_cache_init(void)
 		if (cs_size < KMALLOC_MIN_SIZE)
 			continue;
 
-		if (!cs_cachep[i]) {
+		if (!kmalloc_caches[i]) {
 			/*
 			 * For performance, all the general caches are L1 aligned.
 			 * This should be particularly beneficial on SMP boxes, as it
@@ -1642,12 +1637,12 @@ void __init kmem_cache_init(void)
 			 * Note for systems short on memory removing the alignment will
 			 * allow tighter packing of the smaller caches.
 			 */
-			cs_cachep[i] = create_kmalloc_cache("kmalloc",
+			kmalloc_caches[i] = create_kmalloc_cache("kmalloc",
 					cs_size, ARCH_KMALLOC_FLAGS);
 		}
 
 #ifdef CONFIG_ZONE_DMA
-		cs_dmacachep[i] = create_kmalloc_cache(
+		kmalloc_dma_caches[i] = create_kmalloc_cache(
 			"kmalloc-dma", cs_size,
 			SLAB_CACHE_DMA|ARCH_KMALLOC_FLAGS);
 #endif
@@ -1669,16 +1664,16 @@ void __init kmem_cache_init(void)
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
-		BUG_ON(cpu_cache_get(cs_cachep[INDEX_AC])
+		BUG_ON(cpu_cache_get(kmalloc_caches[INDEX_AC])
 		       != &initarray_generic.cache);
-		memcpy(ptr, cpu_cache_get(cs_cachep[INDEX_AC]),
+		memcpy(ptr, cpu_cache_get(kmalloc_caches[INDEX_AC]),
 		       sizeof(struct arraycache_init));
 		/*
 		 * Do not assume that spinlocks can be initialized via memcpy:
 		 */
 		spin_lock_init(&ptr->lock);
 
-		cs_cachep[INDEX_AC]->array[smp_processor_id()] = ptr;
+		kmalloc_caches[INDEX_AC]->array[smp_processor_id()] = ptr;
 	}
 	/* 5) Replace the bootstrap kmem_list3's */
 	{
@@ -1687,11 +1682,11 @@ void __init kmem_cache_init(void)
 		for_each_online_node(nid) {
 			init_list(kmem_cache, &initkmem_list3[CACHE_CACHE + nid], nid);
 
-			init_list(cs_cachep[INDEX_AC],
+			init_list(kmalloc_caches[INDEX_AC],
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
 			if (INDEX_AC != INDEX_L3) {
-				init_list(cs_cachep[INDEX_L3],
+				init_list(kmalloc_caches[INDEX_L3],
 					  &initkmem_list3[SIZE_L3 + nid], nid);
 			}
 		}
@@ -1702,7 +1697,7 @@ void __init kmem_cache_init(void)
 	/* Create the proper names */
 	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
 		char *s;
-		struct kmem_cache *c = cs_cachep[i];
+		struct kmem_cache *c = kmalloc_caches[i];
 
 		if (!c)
 			continue;
@@ -1713,7 +1708,7 @@ void __init kmem_cache_init(void)
 		c->name = s;
 		
 #ifdef CONFIG_ZONE_DMA
-		c = cs_dmacachep[i];
+		c = kmalloc_dma_caches[i];
 		BUG_ON(!c);
 		s = kasprintf(GFP_NOWAIT, "dma-kmalloc-%d", kmalloc_size(i));
 		BUG_ON(!s);
@@ -1750,7 +1745,7 @@ void __init kmem_cache_init_late(void)
 #ifdef CONFIG_NUMA
 	/*
 	 * Register a memory hotplug callback that initializes and frees
-	 * nodelists.
+	 * node.
 	 */
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 #endif
@@ -1795,7 +1790,7 @@ slab_out_of_memory(struct kmem_cache *ca
 		unsigned long active_objs = 0, num_objs = 0, free_objects = 0;
 		unsigned long active_slabs = 0, num_slabs = 0;
 
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 
@@ -2269,15 +2264,15 @@ static int __init_refok setup_cpu_cache(
 		} else {
 			int node;
 			for_each_online_node(node) {
-				cachep->nodelists[node] =
+				cachep->node[node] =
 				    kmalloc_node(sizeof(struct kmem_cache_node),
 						gfp, node);
-				BUG_ON(!cachep->nodelists[node]);
-				kmem_list3_init(cachep->nodelists[node]);
+				BUG_ON(!cachep->node[node]);
+				kmem_list3_init(cachep->node[node]);
 			}
 		}
 	}
-	cachep->nodelists[numa_mem_id()]->next_reap =
+	cachep->node[numa_mem_id()]->next_reap =
 			jiffies + REAPTIMEOUT_LIST3 +
 			((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 
@@ -2388,7 +2383,7 @@ __kmem_cache_create (struct kmem_cache *
 	else
 		gfp = GFP_NOWAIT;
 
-	setup_nodelists_pointer(cachep);
+	setup_node_pointer(cachep);
 #if DEBUG
 
 	/*
@@ -2526,7 +2521,7 @@ static void check_spinlock_acquired(stru
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->nodelists[numa_mem_id()]->list_lock);
+	assert_spin_locked(&cachep->node[numa_mem_id()]->list_lock);
 #endif
 }
 
@@ -2534,7 +2529,7 @@ static void check_spinlock_acquired_node
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->nodelists[node]->list_lock);
+	assert_spin_locked(&cachep->node[node]->list_lock);
 #endif
 }
 
@@ -2557,9 +2552,9 @@ static void do_drain(void *arg)
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
-	spin_lock(&cachep->nodelists[node]->list_lock);
+	spin_lock(&cachep->node[node]->list_lock);
 	free_block(cachep, ac->entry, ac->avail, node);
-	spin_unlock(&cachep->nodelists[node]->list_lock);
+	spin_unlock(&cachep->node[node]->list_lock);
 	ac->avail = 0;
 }
 
@@ -2571,13 +2566,13 @@ static void drain_cpu_caches(struct kmem
 	on_each_cpu(do_drain, cachep, 1);
 	check_irq_on();
 	for_each_online_node(node) {
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (l3 && l3->alien)
 			drain_alien_cache(cachep, l3->alien);
 	}
 
 	for_each_online_node(node) {
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (l3)
 			drain_array(cachep, l3, l3->shared, 1, node);
 	}
@@ -2634,7 +2629,7 @@ static int __cache_shrink(struct kmem_ca
 
 	check_irq_on();
 	for_each_online_node(i) {
-		l3 = cachep->nodelists[i];
+		l3 = cachep->node[i];
 		if (!l3)
 			continue;
 
@@ -2681,7 +2676,7 @@ int __kmem_cache_shutdown(struct kmem_ca
 
 	/* NUMA: free the list3 structures */
 	for_each_online_node(i) {
-		l3 = cachep->nodelists[i];
+		l3 = cachep->node[i];
 		if (l3) {
 			kfree(l3->shared);
 			free_alien_cache(l3->alien);
@@ -2878,7 +2873,7 @@ static int cache_grow(struct kmem_cache
 
 	/* Take the l3 list lock to change the colour_next on this node */
 	check_irq_off();
-	l3 = cachep->nodelists[nodeid];
+	l3 = cachep->node[nodeid];
 	spin_lock(&l3->list_lock);
 
 	/* Get colour for the slab, and cal the next value. */
@@ -3076,7 +3071,7 @@ retry:
 		 */
 		batchcount = BATCHREFILL_LIMIT;
 	}
-	l3 = cachep->nodelists[node];
+	l3 = cachep->node[node];
 
 	BUG_ON(ac->avail > 0 || !l3);
 	spin_lock(&l3->list_lock);
@@ -3298,7 +3293,7 @@ static void *alternate_node_alloc(struct
 /*
  * Fallback function if there was no memory available and no objects on a
  * certain node and fall back is permitted. First we scan all the
- * available nodelists for available objects. If that fails then we
+ * available node for available objects. If that fails then we
  * perform an allocation without specifying a node. This allows the page
  * allocator to do its reclaim / fallback magic. We then insert the
  * slab into the proper nodelist and then allocate from it.
@@ -3332,8 +3327,8 @@ retry:
 		nid = zone_to_nid(zone);
 
 		if (cpuset_zone_allowed_hardwall(zone, flags) &&
-			cache->nodelists[nid] &&
-			cache->nodelists[nid]->free_objects) {
+			cache->node[nid] &&
+			cache->node[nid]->free_objects) {
 				obj = ____cache_alloc_node(cache,
 					flags | GFP_THISNODE, nid);
 				if (obj)
@@ -3393,7 +3388,7 @@ static void *____cache_alloc_node(struct
 	void *obj;
 	int x;
 
-	l3 = cachep->nodelists[nodeid];
+	l3 = cachep->node[nodeid];
 	BUG_ON(!l3);
 
 retry:
@@ -3476,7 +3471,7 @@ __cache_alloc_node(struct kmem_cache *ca
 	if (nodeid == NUMA_NO_NODE)
 		nodeid = slab_node;
 
-	if (unlikely(!cachep->nodelists[nodeid])) {
+	if (unlikely(!cachep->node[nodeid])) {
 		/* Node not bootstrapped yet */
 		ptr = fallback_alloc(cachep, flags);
 		goto out;
@@ -3590,7 +3585,7 @@ static void free_block(struct kmem_cache
 		objp = objpp[i];
 
 		slabp = virt_to_slab(objp);
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		list_del(&slabp->list);
 		check_spinlock_acquired_node(cachep, node);
 		check_slabp(cachep, slabp);
@@ -3634,7 +3629,7 @@ static void cache_flusharray(struct kmem
 	BUG_ON(!batchcount || batchcount > ac->avail);
 #endif
 	check_irq_off();
-	l3 = cachep->nodelists[node];
+	l3 = cachep->node[node];
 	spin_lock(&l3->list_lock);
 	if (l3->shared) {
 		struct array_cache *shared_array = l3->shared;
@@ -3946,7 +3941,7 @@ static int alloc_kmemlist(struct kmem_ca
 			}
 		}
 
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (l3) {
 			struct array_cache *shared = l3->shared;
 
@@ -3982,7 +3977,7 @@ static int alloc_kmemlist(struct kmem_ca
 		l3->alien = new_alien;
 		l3->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
-		cachep->nodelists[node] = l3;
+		cachep->node[node] = l3;
 	}
 	return 0;
 
@@ -3991,13 +3986,13 @@ fail:
 		/* Cache is not active yet. Roll back what we did */
 		node--;
 		while (node >= 0) {
-			if (cachep->nodelists[node]) {
-				l3 = cachep->nodelists[node];
+			if (cachep->node[node]) {
+				l3 = cachep->node[node];
 
 				kfree(l3->shared);
 				free_alien_cache(l3->alien);
 				kfree(l3);
-				cachep->nodelists[node] = NULL;
+				cachep->node[node] = NULL;
 			}
 			node--;
 		}
@@ -4057,9 +4052,9 @@ static int do_tune_cpucache(struct kmem_
 		struct array_cache *ccold = new->new[i];
 		if (!ccold)
 			continue;
-		spin_lock_irq(&cachep->nodelists[cpu_to_mem(i)]->list_lock);
+		spin_lock_irq(&cachep->node[cpu_to_mem(i)]->list_lock);
 		free_block(cachep, ccold->entry, ccold->avail, cpu_to_mem(i));
-		spin_unlock_irq(&cachep->nodelists[cpu_to_mem(i)]->list_lock);
+		spin_unlock_irq(&cachep->node[cpu_to_mem(i)]->list_lock);
 		kfree(ccold);
 	}
 	kfree(new);
@@ -4180,7 +4175,7 @@ static void cache_reap(struct work_struc
 		 * have established with reasonable certainty that
 		 * we can do some work if the lock was obtained.
 		 */
-		l3 = searchp->nodelists[node];
+		l3 = searchp->node[node];
 
 		reap_alien(searchp, l3);
 
@@ -4279,7 +4274,7 @@ static int s_show(struct seq_file *m, vo
 	active_objs = 0;
 	num_slabs = 0;
 	for_each_online_node(node) {
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 
@@ -4533,7 +4528,7 @@ static int leaks_show(struct seq_file *m
 	n[1] = 0;
 
 	for_each_online_node(node) {
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
