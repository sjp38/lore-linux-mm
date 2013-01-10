Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 9620E6B006C
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:14:27 -0500 (EST)
Message-Id: <0000013c25e2606c-c8d370da-8a29-41c6-afc5-18d822174de7-000000@email.amazonses.com>
Date: Thu, 10 Jan 2013 19:14:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: REN2 [12/13] slab: Rename list3/l3 to node
References: <20130110190027.780479755@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

The list3 or l3 pointers are pointing to per node structures. Reflect
that in the names of variables used.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2013-01-10 09:55:55.000000000 -0600
+++ linux/mm/slab.c	2013-01-10 09:56:33.338426534 -0600
@@ -306,13 +306,13 @@ struct kmem_cache_node {
  * Need this for bootstrapping a per node allocator.
  */
 #define NUM_INIT_LISTS (3 * MAX_NUMNODES)
-static struct kmem_cache_node __initdata initkmem_list3[NUM_INIT_LISTS];
+static struct kmem_cache_node __initdata init_kmem_cache_node[NUM_INIT_LISTS];
 #define	CACHE_CACHE 0
 #define	SIZE_AC MAX_NUMNODES
-#define	SIZE_L3 (2 * MAX_NUMNODES)
+#define	SIZE_NODE (2 * MAX_NUMNODES)
 
 static int drain_freelist(struct kmem_cache *cache,
-			struct kmem_cache_node *l3, int tofree);
+			struct kmem_cache_node *n, int tofree);
 static void free_block(struct kmem_cache *cachep, void **objpp, int len,
 			int node);
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
@@ -321,9 +321,9 @@ static void cache_reap(struct work_struc
 static int slab_early_init = 1;
 
 #define INDEX_AC kmalloc_index(sizeof(struct arraycache_init))
-#define INDEX_L3 kmalloc_index(sizeof(struct kmem_cache_node))
+#define INDEX_NODE kmalloc_index(sizeof(struct kmem_cache_node))
 
-static void kmem_list3_init(struct kmem_cache_node *parent)
+static void kmem_cache_node_init(struct kmem_cache_node *parent)
 {
 	INIT_LIST_HEAD(&parent->slabs_full);
 	INIT_LIST_HEAD(&parent->slabs_partial);
@@ -538,15 +538,15 @@ static void slab_set_lock_classes(struct
 		int q)
 {
 	struct array_cache **alc;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	int r;
 
-	l3 = cachep->node[q];
-	if (!l3)
+	n = cachep->node[q];
+	if (!n)
 		return;
 
-	lockdep_set_class(&l3->list_lock, l3_key);
-	alc = l3->alien;
+	lockdep_set_class(&n->list_lock, l3_key);
+	alc = n->alien;
 	/*
 	 * FIXME: This check for BAD_ALIEN_MAGIC
 	 * should go away when common slab code is taught to
@@ -583,14 +583,14 @@ static void init_node_lock_keys(int q)
 		return;
 
 	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
-		struct kmem_cache_node *l3;
+		struct kmem_cache_node *n;
 		struct kmem_cache *cache = kmalloc_caches[i];
 
 		if (!cache)
 			continue;
 
-		l3 = cache->node[q];
-		if (!l3 || OFF_SLAB(cache))
+		n = cache->node[q];
+		if (!n || OFF_SLAB(cache))
 			continue;
 
 		slab_set_lock_classes(cache, &on_slab_l3_key,
@@ -857,29 +857,29 @@ static inline bool is_slab_pfmemalloc(st
 static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
 						struct array_cache *ac)
 {
-	struct kmem_cache_node *l3 = cachep->node[numa_mem_id()];
+	struct kmem_cache_node *n = cachep->node[numa_mem_id()];
 	struct slab *slabp;
 	unsigned long flags;
 
 	if (!pfmemalloc_active)
 		return;
 
-	spin_lock_irqsave(&l3->list_lock, flags);
-	list_for_each_entry(slabp, &l3->slabs_full, list)
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry(slabp, &n->slabs_full, list)
 		if (is_slab_pfmemalloc(slabp))
 			goto out;
 
-	list_for_each_entry(slabp, &l3->slabs_partial, list)
+	list_for_each_entry(slabp, &n->slabs_partial, list)
 		if (is_slab_pfmemalloc(slabp))
 			goto out;
 
-	list_for_each_entry(slabp, &l3->slabs_free, list)
+	list_for_each_entry(slabp, &n->slabs_free, list)
 		if (is_slab_pfmemalloc(slabp))
 			goto out;
 
 	pfmemalloc_active = false;
 out:
-	spin_unlock_irqrestore(&l3->list_lock, flags);
+	spin_unlock_irqrestore(&n->list_lock, flags);
 }
 
 static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
@@ -890,7 +890,7 @@ static void *__ac_get_obj(struct kmem_ca
 
 	/* Ensure the caller is allowed to use objects from PFMEMALLOC slab */
 	if (unlikely(is_obj_pfmemalloc(objp))) {
-		struct kmem_cache_node *l3;
+		struct kmem_cache_node *n;
 
 		if (gfp_pfmemalloc_allowed(flags)) {
 			clear_obj_pfmemalloc(&objp);
@@ -912,8 +912,8 @@ static void *__ac_get_obj(struct kmem_ca
 		 * If there are empty slabs on the slabs_free list and we are
 		 * being forced to refill the cache, mark this one !pfmemalloc.
 		 */
-		l3 = cachep->node[numa_mem_id()];
-		if (!list_empty(&l3->slabs_free) && force_refill) {
+		n = cachep->node[numa_mem_id()];
+		if (!list_empty(&n->slabs_free) && force_refill) {
 			struct slab *slabp = virt_to_slab(objp);
 			ClearPageSlabPfmemalloc(virt_to_head_page(slabp->s_mem));
 			clear_obj_pfmemalloc(&objp);
@@ -990,7 +990,7 @@ static int transfer_objects(struct array
 #ifndef CONFIG_NUMA
 
 #define drain_alien_cache(cachep, alien) do { } while (0)
-#define reap_alien(cachep, l3) do { } while (0)
+#define reap_alien(cachep, n) do { } while (0)
 
 static inline struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
 {
@@ -1062,33 +1062,33 @@ static void free_alien_cache(struct arra
 static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
-	struct kmem_cache_node *rl3 = cachep->node[node];
+	struct kmem_cache_node *n = cachep->node[node];
 
 	if (ac->avail) {
-		spin_lock(&rl3->list_lock);
+		spin_lock(&n->list_lock);
 		/*
 		 * Stuff objects into the remote nodes shared array first.
 		 * That way we could avoid the overhead of putting the objects
 		 * into the free lists and getting them back later.
 		 */
-		if (rl3->shared)
-			transfer_objects(rl3->shared, ac, ac->limit);
+		if (n->shared)
+			transfer_objects(n->shared, ac, ac->limit);
 
 		free_block(cachep, ac->entry, ac->avail, node);
 		ac->avail = 0;
-		spin_unlock(&rl3->list_lock);
+		spin_unlock(&n->list_lock);
 	}
 }
 
 /*
  * Called from cache_reap() to regularly drain alien caches round robin.
  */
-static void reap_alien(struct kmem_cache *cachep, struct kmem_cache_node *l3)
+static void reap_alien(struct kmem_cache *cachep, struct kmem_cache_node *n)
 {
 	int node = __this_cpu_read(slab_reap_node);
 
-	if (l3->alien) {
-		struct array_cache *ac = l3->alien[node];
+	if (n->alien) {
+		struct array_cache *ac = n->alien[node];
 
 		if (ac && ac->avail && spin_trylock_irq(&ac->lock)) {
 			__drain_alien_cache(cachep, ac, node);
@@ -1118,7 +1118,7 @@ static inline int cache_free_alien(struc
 {
 	struct slab *slabp = virt_to_slab(objp);
 	int nodeid = slabp->nodeid;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	struct array_cache *alien = NULL;
 	int node;
 
@@ -1131,10 +1131,10 @@ static inline int cache_free_alien(struc
 	if (likely(slabp->nodeid == node))
 		return 0;
 
-	l3 = cachep->node[node];
+	n = cachep->node[node];
 	STATS_INC_NODEFREES(cachep);
-	if (l3->alien && l3->alien[nodeid]) {
-		alien = l3->alien[nodeid];
+	if (n->alien && n->alien[nodeid]) {
+		alien = n->alien[nodeid];
 		spin_lock(&alien->lock);
 		if (unlikely(alien->avail == alien->limit)) {
 			STATS_INC_ACOVERFLOW(cachep);
@@ -1153,7 +1153,7 @@ static inline int cache_free_alien(struc
 
 /*
  * Allocates and initializes node for a node on each slab cache, used for
- * either memory or cpu hotplug.  If memory is being hot-added, the kmem_list3
+ * either memory or cpu hotplug.  If memory is being hot-added, the kmem_cache_node
  * will be allocated off-node since memory is not yet online for the new node.
  * When hotplugging memory or a cpu, existing node are not replaced if
  * already in use.
@@ -1163,7 +1163,7 @@ static inline int cache_free_alien(struc
 static int init_cache_node_node(int node)
 {
 	struct kmem_cache *cachep;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	const int memsize = sizeof(struct kmem_cache_node);
 
 	list_for_each_entry(cachep, &slab_caches, list) {
@@ -1173,11 +1173,11 @@ static int init_cache_node_node(int node
 		 * node has not already allocated this
 		 */
 		if (!cachep->node[node]) {
-			l3 = kmalloc_node(memsize, GFP_KERNEL, node);
-			if (!l3)
+			n = kmalloc_node(memsize, GFP_KERNEL, node);
+			if (!n)
 				return -ENOMEM;
-			kmem_list3_init(l3);
-			l3->next_reap = jiffies + REAPTIMEOUT_LIST3 +
+			kmem_cache_node_init(n);
+			n->next_reap = jiffies + REAPTIMEOUT_LIST3 +
 			    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 
 			/*
@@ -1185,7 +1185,7 @@ static int init_cache_node_node(int node
 			 * go.  slab_mutex is sufficient
 			 * protection here.
 			 */
-			cachep->node[node] = l3;
+			cachep->node[node] = n;
 		}
 
 		spin_lock_irq(&cachep->node[node]->list_lock);
@@ -1200,7 +1200,7 @@ static int init_cache_node_node(int node
 static void __cpuinit cpuup_canceled(long cpu)
 {
 	struct kmem_cache *cachep;
-	struct kmem_cache_node *l3 = NULL;
+	struct kmem_cache_node *n = NULL;
 	int node = cpu_to_mem(cpu);
 	const struct cpumask *mask = cpumask_of_node(node);
 
@@ -1212,34 +1212,34 @@ static void __cpuinit cpuup_canceled(lon
 		/* cpu is dead; no one can alloc from it. */
 		nc = cachep->array[cpu];
 		cachep->array[cpu] = NULL;
-		l3 = cachep->node[node];
+		n = cachep->node[node];
 
-		if (!l3)
+		if (!n)
 			goto free_array_cache;
 
-		spin_lock_irq(&l3->list_lock);
+		spin_lock_irq(&n->list_lock);
 
-		/* Free limit for this kmem_list3 */
-		l3->free_limit -= cachep->batchcount;
+		/* Free limit for this kmem_cache_node */
+		n->free_limit -= cachep->batchcount;
 		if (nc)
 			free_block(cachep, nc->entry, nc->avail, node);
 
 		if (!cpumask_empty(mask)) {
-			spin_unlock_irq(&l3->list_lock);
+			spin_unlock_irq(&n->list_lock);
 			goto free_array_cache;
 		}
 
-		shared = l3->shared;
+		shared = n->shared;
 		if (shared) {
 			free_block(cachep, shared->entry,
 				   shared->avail, node);
-			l3->shared = NULL;
+			n->shared = NULL;
 		}
 
-		alien = l3->alien;
-		l3->alien = NULL;
+		alien = n->alien;
+		n->alien = NULL;
 
-		spin_unlock_irq(&l3->list_lock);
+		spin_unlock_irq(&n->list_lock);
 
 		kfree(shared);
 		if (alien) {
@@ -1255,17 +1255,17 @@ free_array_cache:
 	 * shrink each nodelist to its limit.
 	 */
 	list_for_each_entry(cachep, &slab_caches, list) {
-		l3 = cachep->node[node];
-		if (!l3)
+		n = cachep->node[node];
+		if (!n)
 			continue;
-		drain_freelist(cachep, l3, l3->free_objects);
+		drain_freelist(cachep, n, n->free_objects);
 	}
 }
 
 static int __cpuinit cpuup_prepare(long cpu)
 {
 	struct kmem_cache *cachep;
-	struct kmem_cache_node *l3 = NULL;
+	struct kmem_cache_node *n = NULL;
 	int node = cpu_to_mem(cpu);
 	int err;
 
@@ -1273,7 +1273,7 @@ static int __cpuinit cpuup_prepare(long
 	 * We need to do this right in the beginning since
 	 * alloc_arraycache's are going to use this list.
 	 * kmalloc_node allows us to add the slab to the right
-	 * kmem_list3 and not this cpu's kmem_list3
+	 * kmem_cache_node and not this cpu's kmem_cache_node
 	 */
 	err = init_cache_node_node(node);
 	if (err < 0)
@@ -1310,25 +1310,25 @@ static int __cpuinit cpuup_prepare(long
 			}
 		}
 		cachep->array[cpu] = nc;
-		l3 = cachep->node[node];
-		BUG_ON(!l3);
+		n = cachep->node[node];
+		BUG_ON(!n);
 
-		spin_lock_irq(&l3->list_lock);
-		if (!l3->shared) {
+		spin_lock_irq(&n->list_lock);
+		if (!n->shared) {
 			/*
 			 * We are serialised from CPU_DEAD or
 			 * CPU_UP_CANCELLED by the cpucontrol lock
 			 */
-			l3->shared = shared;
+			n->shared = shared;
 			shared = NULL;
 		}
 #ifdef CONFIG_NUMA
-		if (!l3->alien) {
-			l3->alien = alien;
+		if (!n->alien) {
+			n->alien = alien;
 			alien = NULL;
 		}
 #endif
-		spin_unlock_irq(&l3->list_lock);
+		spin_unlock_irq(&n->list_lock);
 		kfree(shared);
 		free_alien_cache(alien);
 		if (cachep->flags & SLAB_DEBUG_OBJECTS)
@@ -1383,9 +1383,9 @@ static int __cpuinit cpuup_callback(stru
 	case CPU_DEAD_FROZEN:
 		/*
 		 * Even if all the cpus of a node are down, we don't free the
-		 * kmem_list3 of any cache. This to avoid a race between
+		 * kmem_cache_node of any cache. This to avoid a race between
 		 * cpu_down, and a kmalloc allocation from another cpu for
-		 * memory from the node of the cpu going down.  The list3
+		 * memory from the node of the cpu going down.  The node
 		 * structure is usually allocated from kmem_cache_create() and
 		 * gets destroyed at kmem_cache_destroy().
 		 */
@@ -1419,16 +1419,16 @@ static int __meminit drain_cache_node_no
 	int ret = 0;
 
 	list_for_each_entry(cachep, &slab_caches, list) {
-		struct kmem_cache_node *l3;
+		struct kmem_cache_node *n;
 
-		l3 = cachep->node[node];
-		if (!l3)
+		n = cachep->node[node];
+		if (!n)
 			continue;
 
-		drain_freelist(cachep, l3, l3->free_objects);
+		drain_freelist(cachep, n, n->free_objects);
 
-		if (!list_empty(&l3->slabs_full) ||
-		    !list_empty(&l3->slabs_partial)) {
+		if (!list_empty(&n->slabs_full) ||
+		    !list_empty(&n->slabs_partial)) {
 			ret = -EBUSY;
 			break;
 		}
@@ -1470,7 +1470,7 @@ out:
 #endif /* CONFIG_NUMA && CONFIG_MEMORY_HOTPLUG */
 
 /*
- * swap the static kmem_list3 with kmalloced memory
+ * swap the static kmem_cache_node with kmalloced memory
  */
 static void __init init_list(struct kmem_cache *cachep, struct kmem_cache_node *list,
 				int nodeid)
@@ -1491,15 +1491,15 @@ static void __init init_list(struct kmem
 }
 
 /*
- * For setting up all the kmem_list3s for cache whose buffer_size is same as
- * size of kmem_list3.
+ * For setting up all the kmem_cache_node for cache whose buffer_size is same as
+ * size of kmem_cache_node.
  */
-static void __init set_up_list3s(struct kmem_cache *cachep, int index)
+static void __init set_up_node(struct kmem_cache *cachep, int index)
 {
 	int node;
 
 	for_each_online_node(node) {
-		cachep->node[node] = &initkmem_list3[index + node];
+		cachep->node[node] = &init_kmem_cache_node[index + node];
 		cachep->node[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
 		    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
@@ -1530,9 +1530,9 @@ void __init kmem_cache_init(void)
 		use_alien_caches = 0;
 
 	for (i = 0; i < NUM_INIT_LISTS; i++)
-		kmem_list3_init(&initkmem_list3[i]);
+		kmem_cache_node_init(&init_kmem_cache_node[i]);
 
-	set_up_list3s(kmem_cache, CACHE_CACHE);
+	set_up_node(kmem_cache, CACHE_CACHE);
 
 	/*
 	 * Fragmentation resistance on low memory - only use bigger
@@ -1548,7 +1548,7 @@ void __init kmem_cache_init(void)
 	 *    kmem_cache structures of all caches, except kmem_cache itself:
 	 *    kmem_cache is statically allocated.
 	 *    Initially an __init data area is used for the head array and the
-	 *    kmem_list3 structures, it's replaced with a kmalloc allocated
+	 *    kmem_cache_node structures, it's replaced with a kmalloc allocated
 	 *    array at the end of the bootstrap.
 	 * 2) Create the first kmalloc cache.
 	 *    The struct kmem_cache for the new cache is allocated normally.
@@ -1557,7 +1557,7 @@ void __init kmem_cache_init(void)
 	 *    head arrays.
 	 * 4) Replace the __init data head arrays for kmem_cache and the first
 	 *    kmalloc cache with kmalloc allocated arrays.
-	 * 5) Replace the __init data for kmem_list3 for kmem_cache and
+	 * 5) Replace the __init data for kmem_cache_node for kmem_cache and
 	 *    the other cache's with kmalloc allocated memory.
 	 * 6) Resize the head arrays of the kmalloc caches to their final sizes.
 	 */
@@ -1577,17 +1577,17 @@ void __init kmem_cache_init(void)
 
 	/*
 	 * Initialize the caches that provide memory for the array cache and the
-	 * kmem_list3 structures first.  Without this, further allocations will
+	 * kmem_cache_node structures first.  Without this, further allocations will
 	 * bug.
 	 */
 
 	kmalloc_caches[INDEX_AC] = create_kmalloc_cache("kmalloc-ac",
 					kmalloc_size(INDEX_AC), ARCH_KMALLOC_FLAGS);
 
-	if (INDEX_AC != INDEX_L3)
-		kmalloc_caches[INDEX_L3] =
-			create_kmalloc_cache("kmalloc-l3",
-				kmalloc_size(INDEX_L3), ARCH_KMALLOC_FLAGS);
+	if (INDEX_AC != INDEX_NODE)
+		kmalloc_caches[INDEX_NODE] =
+			create_kmalloc_cache("kmalloc-node",
+				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
 
 	slab_early_init = 0;
 
@@ -1619,19 +1619,19 @@ void __init kmem_cache_init(void)
 
 		kmalloc_caches[INDEX_AC]->array[smp_processor_id()] = ptr;
 	}
-	/* 5) Replace the bootstrap kmem_list3's */
+	/* 5) Replace the bootstrap kmem_cache_node */
 	{
 		int nid;
 
 		for_each_online_node(nid) {
-			init_list(kmem_cache, &initkmem_list3[CACHE_CACHE + nid], nid);
+			init_list(kmem_cache, &init_kmem_cache_node[CACHE_CACHE + nid], nid);
 
 			init_list(kmalloc_caches[INDEX_AC],
-				  &initkmem_list3[SIZE_AC + nid], nid);
+				  &init_kmem_cache_node[SIZE_AC + nid], nid);
 
-			if (INDEX_AC != INDEX_L3) {
-				init_list(kmalloc_caches[INDEX_L3],
-					  &initkmem_list3[SIZE_L3 + nid], nid);
+			if (INDEX_AC != INDEX_NODE) {
+				init_list(kmalloc_caches[INDEX_NODE],
+					  &init_kmem_cache_node[SIZE_NODE + nid], nid);
 			}
 		}
 	}
@@ -1697,7 +1697,7 @@ __initcall(cpucache_init);
 static noinline void
 slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 {
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	struct slab *slabp;
 	unsigned long flags;
 	int node;
@@ -1712,24 +1712,24 @@ slab_out_of_memory(struct kmem_cache *ca
 		unsigned long active_objs = 0, num_objs = 0, free_objects = 0;
 		unsigned long active_slabs = 0, num_slabs = 0;
 
-		l3 = cachep->node[node];
-		if (!l3)
+		n = cachep->node[node];
+		if (!n)
 			continue;
 
-		spin_lock_irqsave(&l3->list_lock, flags);
-		list_for_each_entry(slabp, &l3->slabs_full, list) {
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry(slabp, &n->slabs_full, list) {
 			active_objs += cachep->num;
 			active_slabs++;
 		}
-		list_for_each_entry(slabp, &l3->slabs_partial, list) {
+		list_for_each_entry(slabp, &n->slabs_partial, list) {
 			active_objs += slabp->inuse;
 			active_slabs++;
 		}
-		list_for_each_entry(slabp, &l3->slabs_free, list)
+		list_for_each_entry(slabp, &n->slabs_free, list)
 			num_slabs++;
 
-		free_objects += l3->free_objects;
-		spin_unlock_irqrestore(&l3->list_lock, flags);
+		free_objects += n->free_objects;
+		spin_unlock_irqrestore(&n->list_lock, flags);
 
 		num_slabs += active_slabs;
 		num_objs = num_slabs * cachep->num;
@@ -2154,7 +2154,7 @@ static int __init_refok setup_cpu_cache(
 	if (slab_state == DOWN) {
 		/*
 		 * Note: Creation of first cache (kmem_cache).
-		 * The setup_list3s is taken care
+		 * The setup_node is taken care
 		 * of by the caller of __kmem_cache_create
 		 */
 		cachep->array[smp_processor_id()] = &initarray_generic.cache;
@@ -2168,13 +2168,13 @@ static int __init_refok setup_cpu_cache(
 		cachep->array[smp_processor_id()] = &initarray_generic.cache;
 
 		/*
-		 * If the cache that's used by kmalloc(sizeof(kmem_list3)) is
-		 * the second cache, then we need to set up all its list3s,
+		 * If the cache that's used by kmalloc(sizeof(kmem_cache_node)) is
+		 * the second cache, then we need to set up all its node/,
 		 * otherwise the creation of further caches will BUG().
 		 */
-		set_up_list3s(cachep, SIZE_AC);
-		if (INDEX_AC == INDEX_L3)
-			slab_state = PARTIAL_L3;
+		set_up_node(cachep, SIZE_AC);
+		if (INDEX_AC == INDEX_NODE)
+			slab_state = PARTIAL_NODE;
 		else
 			slab_state = PARTIAL_ARRAYCACHE;
 	} else {
@@ -2183,8 +2183,8 @@ static int __init_refok setup_cpu_cache(
 			kmalloc(sizeof(struct arraycache_init), gfp);
 
 		if (slab_state == PARTIAL_ARRAYCACHE) {
-			set_up_list3s(cachep, SIZE_L3);
-			slab_state = PARTIAL_L3;
+			set_up_node(cachep, SIZE_NODE);
+			slab_state = PARTIAL_NODE;
 		} else {
 			int node;
 			for_each_online_node(node) {
@@ -2192,7 +2192,7 @@ static int __init_refok setup_cpu_cache(
 				    kmalloc_node(sizeof(struct kmem_cache_node),
 						gfp, node);
 				BUG_ON(!cachep->node[node]);
-				kmem_list3_init(cachep->node[node]);
+				kmem_cache_node_init(cachep->node[node]);
 			}
 		}
 	}
@@ -2322,7 +2322,7 @@ __kmem_cache_create (struct kmem_cache *
 			size += BYTES_PER_WORD;
 	}
 #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
-	if (size >= kmalloc_size(INDEX_L3 + 1)
+	if (size >= kmalloc_size(INDEX_NODE + 1)
 	    && cachep->object_size > cache_line_size() && ALIGN(size, align) < PAGE_SIZE) {
 		cachep->obj_offset += PAGE_SIZE - ALIGN(size, align);
 		size = PAGE_SIZE;
@@ -2457,7 +2457,7 @@ static void check_spinlock_acquired_node
 #define check_spinlock_acquired_node(x, y) do { } while(0)
 #endif
 
-static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *l3,
+static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 			struct array_cache *ac,
 			int force, int node);
 
@@ -2477,21 +2477,21 @@ static void do_drain(void *arg)
 
 static void drain_cpu_caches(struct kmem_cache *cachep)
 {
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	int node;
 
 	on_each_cpu(do_drain, cachep, 1);
 	check_irq_on();
 	for_each_online_node(node) {
-		l3 = cachep->node[node];
-		if (l3 && l3->alien)
-			drain_alien_cache(cachep, l3->alien);
+		n = cachep->node[node];
+		if (n && n->alien)
+			drain_alien_cache(cachep, n->alien);
 	}
 
 	for_each_online_node(node) {
-		l3 = cachep->node[node];
-		if (l3)
-			drain_array(cachep, l3, l3->shared, 1, node);
+		n = cachep->node[node];
+		if (n)
+			drain_array(cachep, n, n->shared, 1, node);
 	}
 }
 
@@ -2502,19 +2502,19 @@ static void drain_cpu_caches(struct kmem
  * Returns the actual number of slabs released.
  */
 static int drain_freelist(struct kmem_cache *cache,
-			struct kmem_cache_node *l3, int tofree)
+			struct kmem_cache_node *n, int tofree)
 {
 	struct list_head *p;
 	int nr_freed;
 	struct slab *slabp;
 
 	nr_freed = 0;
-	while (nr_freed < tofree && !list_empty(&l3->slabs_free)) {
+	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
 
-		spin_lock_irq(&l3->list_lock);
-		p = l3->slabs_free.prev;
-		if (p == &l3->slabs_free) {
-			spin_unlock_irq(&l3->list_lock);
+		spin_lock_irq(&n->list_lock);
+		p = n->slabs_free.prev;
+		if (p == &n->slabs_free) {
+			spin_unlock_irq(&n->list_lock);
 			goto out;
 		}
 
@@ -2527,8 +2527,8 @@ static int drain_freelist(struct kmem_ca
 		 * Safe to drop the lock. The slab is no longer linked
 		 * to the cache.
 		 */
-		l3->free_objects -= cache->num;
-		spin_unlock_irq(&l3->list_lock);
+		n->free_objects -= cache->num;
+		spin_unlock_irq(&n->list_lock);
 		slab_destroy(cache, slabp);
 		nr_freed++;
 	}
@@ -2540,20 +2540,20 @@ out:
 static int __cache_shrink(struct kmem_cache *cachep)
 {
 	int ret = 0, i = 0;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 
 	drain_cpu_caches(cachep);
 
 	check_irq_on();
 	for_each_online_node(i) {
-		l3 = cachep->node[i];
-		if (!l3)
+		n = cachep->node[i];
+		if (!n)
 			continue;
 
-		drain_freelist(cachep, l3, l3->free_objects);
+		drain_freelist(cachep, n, n->free_objects);
 
-		ret += !list_empty(&l3->slabs_full) ||
-			!list_empty(&l3->slabs_partial);
+		ret += !list_empty(&n->slabs_full) ||
+			!list_empty(&n->slabs_partial);
 	}
 	return (ret ? 1 : 0);
 }
@@ -2582,7 +2582,7 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 int __kmem_cache_shutdown(struct kmem_cache *cachep)
 {
 	int i;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	int rc = __cache_shrink(cachep);
 
 	if (rc)
@@ -2591,13 +2591,13 @@ int __kmem_cache_shutdown(struct kmem_ca
 	for_each_online_cpu(i)
 	    kfree(cachep->array[i]);
 
-	/* NUMA: free the list3 structures */
+	/* NUMA: free the node structures */
 	for_each_online_node(i) {
-		l3 = cachep->node[i];
-		if (l3) {
-			kfree(l3->shared);
-			free_alien_cache(l3->alien);
-			kfree(l3);
+		n = cachep->node[i];
+		if (n) {
+			kfree(n->shared);
+			free_alien_cache(n->alien);
+			kfree(n);
 		}
 	}
 	return 0;
@@ -2779,7 +2779,7 @@ static int cache_grow(struct kmem_cache
 	struct slab *slabp;
 	size_t offset;
 	gfp_t local_flags;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -2788,17 +2788,17 @@ static int cache_grow(struct kmem_cache
 	BUG_ON(flags & GFP_SLAB_BUG_MASK);
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
-	/* Take the l3 list lock to change the colour_next on this node */
+	/* Take the node list lock to change the colour_next on this node */
 	check_irq_off();
-	l3 = cachep->node[nodeid];
-	spin_lock(&l3->list_lock);
+	n = cachep->node[nodeid];
+	spin_lock(&n->list_lock);
 
 	/* Get colour for the slab, and cal the next value. */
-	offset = l3->colour_next;
-	l3->colour_next++;
-	if (l3->colour_next >= cachep->colour)
-		l3->colour_next = 0;
-	spin_unlock(&l3->list_lock);
+	offset = n->colour_next;
+	n->colour_next++;
+	if (n->colour_next >= cachep->colour)
+		n->colour_next = 0;
+	spin_unlock(&n->list_lock);
 
 	offset *= cachep->colour_off;
 
@@ -2835,13 +2835,13 @@ static int cache_grow(struct kmem_cache
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
 	check_irq_off();
-	spin_lock(&l3->list_lock);
+	spin_lock(&n->list_lock);
 
 	/* Make slab active. */
-	list_add_tail(&slabp->list, &(l3->slabs_free));
+	list_add_tail(&slabp->list, &(n->slabs_free));
 	STATS_INC_GROWN(cachep);
-	l3->free_objects += cachep->num;
-	spin_unlock(&l3->list_lock);
+	n->free_objects += cachep->num;
+	spin_unlock(&n->list_lock);
 	return 1;
 opps1:
 	kmem_freepages(cachep, objp);
@@ -2969,7 +2969,7 @@ static void *cache_alloc_refill(struct k
 							bool force_refill)
 {
 	int batchcount;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	struct array_cache *ac;
 	int node;
 
@@ -2988,14 +2988,14 @@ retry:
 		 */
 		batchcount = BATCHREFILL_LIMIT;
 	}
-	l3 = cachep->node[node];
+	n = cachep->node[node];
 
-	BUG_ON(ac->avail > 0 || !l3);
-	spin_lock(&l3->list_lock);
+	BUG_ON(ac->avail > 0 || !n);
+	spin_lock(&n->list_lock);
 
 	/* See if we can refill from the shared array */
-	if (l3->shared && transfer_objects(ac, l3->shared, batchcount)) {
-		l3->shared->touched = 1;
+	if (n->shared && transfer_objects(ac, n->shared, batchcount)) {
+		n->shared->touched = 1;
 		goto alloc_done;
 	}
 
@@ -3003,11 +3003,11 @@ retry:
 		struct list_head *entry;
 		struct slab *slabp;
 		/* Get slab alloc is to come from. */
-		entry = l3->slabs_partial.next;
-		if (entry == &l3->slabs_partial) {
-			l3->free_touched = 1;
-			entry = l3->slabs_free.next;
-			if (entry == &l3->slabs_free)
+		entry = n->slabs_partial.next;
+		if (entry == &n->slabs_partial) {
+			n->free_touched = 1;
+			entry = n->slabs_free.next;
+			if (entry == &n->slabs_free)
 				goto must_grow;
 		}
 
@@ -3035,15 +3035,15 @@ retry:
 		/* move slabp to correct slabp list: */
 		list_del(&slabp->list);
 		if (slabp->free == BUFCTL_END)
-			list_add(&slabp->list, &l3->slabs_full);
+			list_add(&slabp->list, &n->slabs_full);
 		else
-			list_add(&slabp->list, &l3->slabs_partial);
+			list_add(&slabp->list, &n->slabs_partial);
 	}
 
 must_grow:
-	l3->free_objects -= ac->avail;
+	n->free_objects -= ac->avail;
 alloc_done:
-	spin_unlock(&l3->list_lock);
+	spin_unlock(&n->list_lock);
 
 	if (unlikely(!ac->avail)) {
 		int x;
@@ -3301,21 +3301,21 @@ static void *____cache_alloc_node(struct
 {
 	struct list_head *entry;
 	struct slab *slabp;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	void *obj;
 	int x;
 
-	l3 = cachep->node[nodeid];
-	BUG_ON(!l3);
+	n = cachep->node[nodeid];
+	BUG_ON(!n);
 
 retry:
 	check_irq_off();
-	spin_lock(&l3->list_lock);
-	entry = l3->slabs_partial.next;
-	if (entry == &l3->slabs_partial) {
-		l3->free_touched = 1;
-		entry = l3->slabs_free.next;
-		if (entry == &l3->slabs_free)
+	spin_lock(&n->list_lock);
+	entry = n->slabs_partial.next;
+	if (entry == &n->slabs_partial) {
+		n->free_touched = 1;
+		entry = n->slabs_free.next;
+		if (entry == &n->slabs_free)
 			goto must_grow;
 	}
 
@@ -3331,20 +3331,20 @@ retry:
 
 	obj = slab_get_obj(cachep, slabp, nodeid);
 	check_slabp(cachep, slabp);
-	l3->free_objects--;
+	n->free_objects--;
 	/* move slabp to correct slabp list: */
 	list_del(&slabp->list);
 
 	if (slabp->free == BUFCTL_END)
-		list_add(&slabp->list, &l3->slabs_full);
+		list_add(&slabp->list, &n->slabs_full);
 	else
-		list_add(&slabp->list, &l3->slabs_partial);
+		list_add(&slabp->list, &n->slabs_partial);
 
-	spin_unlock(&l3->list_lock);
+	spin_unlock(&n->list_lock);
 	goto done;
 
 must_grow:
-	spin_unlock(&l3->list_lock);
+	spin_unlock(&n->list_lock);
 	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL);
 	if (x)
 		goto retry;
@@ -3496,7 +3496,7 @@ static void free_block(struct kmem_cache
 		       int node)
 {
 	int i;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
@@ -3506,19 +3506,19 @@ static void free_block(struct kmem_cache
 		objp = objpp[i];
 
 		slabp = virt_to_slab(objp);
-		l3 = cachep->node[node];
+		n = cachep->node[node];
 		list_del(&slabp->list);
 		check_spinlock_acquired_node(cachep, node);
 		check_slabp(cachep, slabp);
 		slab_put_obj(cachep, slabp, objp, node);
 		STATS_DEC_ACTIVE(cachep);
-		l3->free_objects++;
+		n->free_objects++;
 		check_slabp(cachep, slabp);
 
 		/* fixup slab chains */
 		if (slabp->inuse == 0) {
-			if (l3->free_objects > l3->free_limit) {
-				l3->free_objects -= cachep->num;
+			if (n->free_objects > n->free_limit) {
+				n->free_objects -= cachep->num;
 				/* No need to drop any previously held
 				 * lock here, even if we have a off-slab slab
 				 * descriptor it is guaranteed to come from
@@ -3527,14 +3527,14 @@ static void free_block(struct kmem_cache
 				 */
 				slab_destroy(cachep, slabp);
 			} else {
-				list_add(&slabp->list, &l3->slabs_free);
+				list_add(&slabp->list, &n->slabs_free);
 			}
 		} else {
 			/* Unconditionally move a slab to the end of the
 			 * partial list on free - maximum time for the
 			 * other objects to be freed, too.
 			 */
-			list_add_tail(&slabp->list, &l3->slabs_partial);
+			list_add_tail(&slabp->list, &n->slabs_partial);
 		}
 	}
 }
@@ -3542,7 +3542,7 @@ static void free_block(struct kmem_cache
 static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 {
 	int batchcount;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	int node = numa_mem_id();
 
 	batchcount = ac->batchcount;
@@ -3550,10 +3550,10 @@ static void cache_flusharray(struct kmem
 	BUG_ON(!batchcount || batchcount > ac->avail);
 #endif
 	check_irq_off();
-	l3 = cachep->node[node];
-	spin_lock(&l3->list_lock);
-	if (l3->shared) {
-		struct array_cache *shared_array = l3->shared;
+	n = cachep->node[node];
+	spin_lock(&n->list_lock);
+	if (n->shared) {
+		struct array_cache *shared_array = n->shared;
 		int max = shared_array->limit - shared_array->avail;
 		if (max) {
 			if (batchcount > max)
@@ -3572,8 +3572,8 @@ free_done:
 		int i = 0;
 		struct list_head *p;
 
-		p = l3->slabs_free.next;
-		while (p != &(l3->slabs_free)) {
+		p = n->slabs_free.next;
+		while (p != &(n->slabs_free)) {
 			struct slab *slabp;
 
 			slabp = list_entry(p, struct slab, list);
@@ -3585,7 +3585,7 @@ free_done:
 		STATS_SET_FREEABLE(cachep, i);
 	}
 #endif
-	spin_unlock(&l3->list_lock);
+	spin_unlock(&n->list_lock);
 	ac->avail -= batchcount;
 	memmove(ac->entry, &(ac->entry[batchcount]), sizeof(void *)*ac->avail);
 }
@@ -3829,12 +3829,12 @@ void kfree(const void *objp)
 EXPORT_SYMBOL(kfree);
 
 /*
- * This initializes kmem_list3 or resizes various caches for all nodes.
+ * This initializes kmem_cache_node or resizes various caches for all nodes.
  */
 static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int node;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
@@ -3857,43 +3857,43 @@ static int alloc_kmemlist(struct kmem_ca
 			}
 		}
 
-		l3 = cachep->node[node];
-		if (l3) {
-			struct array_cache *shared = l3->shared;
+		n = cachep->node[node];
+		if (n) {
+			struct array_cache *shared = n->shared;
 
-			spin_lock_irq(&l3->list_lock);
+			spin_lock_irq(&n->list_lock);
 
 			if (shared)
 				free_block(cachep, shared->entry,
 						shared->avail, node);
 
-			l3->shared = new_shared;
-			if (!l3->alien) {
-				l3->alien = new_alien;
+			n->shared = new_shared;
+			if (!n->alien) {
+				n->alien = new_alien;
 				new_alien = NULL;
 			}
-			l3->free_limit = (1 + nr_cpus_node(node)) *
+			n->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
-			spin_unlock_irq(&l3->list_lock);
+			spin_unlock_irq(&n->list_lock);
 			kfree(shared);
 			free_alien_cache(new_alien);
 			continue;
 		}
-		l3 = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
-		if (!l3) {
+		n = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
+		if (!n) {
 			free_alien_cache(new_alien);
 			kfree(new_shared);
 			goto fail;
 		}
 
-		kmem_list3_init(l3);
-		l3->next_reap = jiffies + REAPTIMEOUT_LIST3 +
+		kmem_cache_node_init(n);
+		n->next_reap = jiffies + REAPTIMEOUT_LIST3 +
 				((unsigned long)cachep) % REAPTIMEOUT_LIST3;
-		l3->shared = new_shared;
-		l3->alien = new_alien;
-		l3->free_limit = (1 + nr_cpus_node(node)) *
+		n->shared = new_shared;
+		n->alien = new_alien;
+		n->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
-		cachep->node[node] = l3;
+		cachep->node[node] = n;
 	}
 	return 0;
 
@@ -3903,11 +3903,11 @@ fail:
 		node--;
 		while (node >= 0) {
 			if (cachep->node[node]) {
-				l3 = cachep->node[node];
+				n = cachep->node[node];
 
-				kfree(l3->shared);
-				free_alien_cache(l3->alien);
-				kfree(l3);
+				kfree(n->shared);
+				free_alien_cache(n->alien);
+				kfree(n);
 				cachep->node[node] = NULL;
 			}
 			node--;
@@ -4071,11 +4071,11 @@ skip_setup:
 }
 
 /*
- * Drain an array if it contains any elements taking the l3 lock only if
- * necessary. Note that the l3 listlock also protects the array_cache
+ * Drain an array if it contains any elements taking the node lock only if
+ * necessary. Note that the node listlock also protects the array_cache
  * if drain_array() is used on the shared array.
  */
-static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *l3,
+static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 			 struct array_cache *ac, int force, int node)
 {
 	int tofree;
@@ -4085,7 +4085,7 @@ static void drain_array(struct kmem_cach
 	if (ac->touched && !force) {
 		ac->touched = 0;
 	} else {
-		spin_lock_irq(&l3->list_lock);
+		spin_lock_irq(&n->list_lock);
 		if (ac->avail) {
 			tofree = force ? ac->avail : (ac->limit + 4) / 5;
 			if (tofree > ac->avail)
@@ -4095,7 +4095,7 @@ static void drain_array(struct kmem_cach
 			memmove(ac->entry, &(ac->entry[tofree]),
 				sizeof(void *) * ac->avail);
 		}
-		spin_unlock_irq(&l3->list_lock);
+		spin_unlock_irq(&n->list_lock);
 	}
 }
 
@@ -4114,7 +4114,7 @@ static void drain_array(struct kmem_cach
 static void cache_reap(struct work_struct *w)
 {
 	struct kmem_cache *searchp;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	int node = numa_mem_id();
 	struct delayed_work *work = to_delayed_work(w);
 
@@ -4126,33 +4126,33 @@ static void cache_reap(struct work_struc
 		check_irq_on();
 
 		/*
-		 * We only take the l3 lock if absolutely necessary and we
+		 * We only take the node lock if absolutely necessary and we
 		 * have established with reasonable certainty that
 		 * we can do some work if the lock was obtained.
 		 */
-		l3 = searchp->node[node];
+		n = searchp->node[node];
 
-		reap_alien(searchp, l3);
+		reap_alien(searchp, n);
 
-		drain_array(searchp, l3, cpu_cache_get(searchp), 0, node);
+		drain_array(searchp, n, cpu_cache_get(searchp), 0, node);
 
 		/*
 		 * These are racy checks but it does not matter
 		 * if we skip one check or scan twice.
 		 */
-		if (time_after(l3->next_reap, jiffies))
+		if (time_after(n->next_reap, jiffies))
 			goto next;
 
-		l3->next_reap = jiffies + REAPTIMEOUT_LIST3;
+		n->next_reap = jiffies + REAPTIMEOUT_LIST3;
 
-		drain_array(searchp, l3, l3->shared, 0, node);
+		drain_array(searchp, n, n->shared, 0, node);
 
-		if (l3->free_touched)
-			l3->free_touched = 0;
+		if (n->free_touched)
+			n->free_touched = 0;
 		else {
 			int freed;
 
-			freed = drain_freelist(searchp, l3, (l3->free_limit +
+			freed = drain_freelist(searchp, n, (n->free_limit +
 				5 * searchp->num - 1) / (5 * searchp->num));
 			STATS_ADD_REAPED(searchp, freed);
 		}
@@ -4178,25 +4178,25 @@ void get_slabinfo(struct kmem_cache *cac
 	const char *name;
 	char *error = NULL;
 	int node;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 
 	active_objs = 0;
 	num_slabs = 0;
 	for_each_online_node(node) {
-		l3 = cachep->node[node];
-		if (!l3)
+		n = cachep->node[node];
+		if (!n)
 			continue;
 
 		check_irq_on();
-		spin_lock_irq(&l3->list_lock);
+		spin_lock_irq(&n->list_lock);
 
-		list_for_each_entry(slabp, &l3->slabs_full, list) {
+		list_for_each_entry(slabp, &n->slabs_full, list) {
 			if (slabp->inuse != cachep->num && !error)
 				error = "slabs_full accounting error";
 			active_objs += cachep->num;
 			active_slabs++;
 		}
-		list_for_each_entry(slabp, &l3->slabs_partial, list) {
+		list_for_each_entry(slabp, &n->slabs_partial, list) {
 			if (slabp->inuse == cachep->num && !error)
 				error = "slabs_partial inuse accounting error";
 			if (!slabp->inuse && !error)
@@ -4204,16 +4204,16 @@ void get_slabinfo(struct kmem_cache *cac
 			active_objs += slabp->inuse;
 			active_slabs++;
 		}
-		list_for_each_entry(slabp, &l3->slabs_free, list) {
+		list_for_each_entry(slabp, &n->slabs_free, list) {
 			if (slabp->inuse && !error)
 				error = "slabs_free/inuse accounting error";
 			num_slabs++;
 		}
-		free_objects += l3->free_objects;
-		if (l3->shared)
-			shared_avail += l3->shared->avail;
+		free_objects += n->free_objects;
+		if (n->shared)
+			shared_avail += n->shared->avail;
 
-		spin_unlock_irq(&l3->list_lock);
+		spin_unlock_irq(&n->list_lock);
 	}
 	num_slabs += active_slabs;
 	num_objs = num_slabs * cachep->num;
@@ -4239,7 +4239,7 @@ void get_slabinfo(struct kmem_cache *cac
 void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
 {
 #if STATS
-	{			/* list3 stats */
+	{			/* node stats */
 		unsigned long high = cachep->high_mark;
 		unsigned long allocs = cachep->num_allocations;
 		unsigned long grown = cachep->grown;
@@ -4392,7 +4392,7 @@ static int leaks_show(struct seq_file *m
 {
 	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
 	struct slab *slabp;
-	struct kmem_cache_node *l3;
+	struct kmem_cache_node *n;
 	const char *name;
 	unsigned long *n = m->private;
 	int node;
@@ -4408,18 +4408,18 @@ static int leaks_show(struct seq_file *m
 	n[1] = 0;
 
 	for_each_online_node(node) {
-		l3 = cachep->node[node];
-		if (!l3)
+		n = cachep->node[node];
+		if (!n)
 			continue;
 
 		check_irq_on();
-		spin_lock_irq(&l3->list_lock);
+		spin_lock_irq(&n->list_lock);
 
-		list_for_each_entry(slabp, &l3->slabs_full, list)
+		list_for_each_entry(slabp, &n->slabs_full, list)
 			handle_slab(n, cachep, slabp);
-		list_for_each_entry(slabp, &l3->slabs_partial, list)
+		list_for_each_entry(slabp, &n->slabs_partial, list)
 			handle_slab(n, cachep, slabp);
-		spin_unlock_irq(&l3->list_lock);
+		spin_unlock_irq(&n->list_lock);
 	}
 	name = cachep->name;
 	if (n[0] == n[1]) {
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2013-01-10 09:55:55.000000000 -0600
+++ linux/mm/slab.h	2013-01-10 09:56:02.905946348 -0600
@@ -16,7 +16,7 @@ enum slab_state {
 	DOWN,			/* No slab functionality yet */
 	PARTIAL,		/* SLUB: kmem_cache_node available */
 	PARTIAL_ARRAYCACHE,	/* SLAB: kmalloc size for arraycache available */
-	PARTIAL_L3,		/* SLAB: kmalloc size for l3 struct available */
+	PARTIAL_NODE,		/* SLAB: kmalloc size for node struct available */
 	UP,			/* Slab caches usable but not all extras yet */
 	FULL			/* Everything is working */
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
