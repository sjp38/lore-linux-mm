Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 149766B00AC
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:51:52 -0400 (EDT)
Message-Id: <0000013a79823d1c-0d9c7db2-2a3b-418e-ba50-293dacd5796a-000000@email.amazonses.com>
Date: Fri, 19 Oct 2012 14:51:49 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [10/15] slab: rename nodelists to node
References: <20121019142254.724806786@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Have a common naming between both slab caches for future changes.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2012-10-15 16:12:15.640382714 -0500
+++ linux/include/linux/slab_def.h	2012-10-15 16:12:18.568438789 -0500
@@ -88,7 +88,7 @@ struct kmem_cache {
 	 * We still use [NR_CPUS] and not [1] or [0] because cache_cache
 	 * is statically defined, so we reserve the max number of cpus.
 	 */
-	struct kmem_cache_node **nodelists;
+	struct kmem_cache_node **node;
 	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
 	/*
 	 * Do not add fields after array[]
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-10-15 16:12:15.640382714 -0500
+++ linux/mm/slab.c	2012-10-15 16:12:18.568438789 -0500
@@ -363,7 +363,7 @@ static void kmem_list3_init(struct kmem_
 #define MAKE_LIST(cachep, listp, slab, nodeid)				\
 	do {								\
 		INIT_LIST_HEAD(listp);					\
-		list_splice(&(cachep->nodelists[nodeid]->slab), listp);	\
+		list_splice(&(cachep->node[nodeid]->slab), listp);	\
 	} while (0)
 
 #define	MAKE_ALL_LISTS(cachep, ptr, nodeid)				\
@@ -565,7 +565,7 @@ static void slab_set_lock_classes(struct
 	struct kmem_cache_node *l3;
 	int r;
 
-	l3 = cachep->nodelists[q];
+	l3 = cachep->node[q];
 	if (!l3)
 		return;
 
@@ -613,7 +613,7 @@ static void init_node_lock_keys(int q)
 		if (!cache)
 			continue;
 
-		l3 = cache->nodelists[q];
+		l3 = cache->node[q];
 		if (!l3 || OFF_SLAB(cache))
 			continue;
 
@@ -889,7 +889,7 @@ static inline bool is_slab_pfmemalloc(st
 static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
 						struct array_cache *ac)
 {
-	struct kmem_cache_node *l3 = cachep->nodelists[numa_mem_id()];
+	struct kmem_cache_node *l3 = cachep->node[numa_mem_id()];
 	struct slab *slabp;
 	unsigned long flags;
 
@@ -944,7 +944,7 @@ static void *__ac_get_obj(struct kmem_ca
 		 * If there are empty slabs on the slabs_free list and we are
 		 * being forced to refill the cache, mark this one !pfmemalloc.
 		 */
-		l3 = cachep->nodelists[numa_mem_id()];
+		l3 = cachep->node[numa_mem_id()];
 		if (!list_empty(&l3->slabs_free) && force_refill) {
 			struct slab *slabp = virt_to_slab(objp);
 			ClearPageSlabPfmemalloc(virt_to_head_page(slabp->s_mem));
@@ -1094,7 +1094,7 @@ static void free_alien_cache(struct arra
 static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
-	struct kmem_cache_node *rl3 = cachep->nodelists[node];
+	struct kmem_cache_node *rl3 = cachep->node[node];
 
 	if (ac->avail) {
 		spin_lock(&rl3->list_lock);
@@ -1163,7 +1163,7 @@ static inline int cache_free_alien(struc
 	if (likely(slabp->nodeid == node))
 		return 0;
 
-	l3 = cachep->nodelists[node];
+	l3 = cachep->node[node];
 	STATS_INC_NODEFREES(cachep);
 	if (l3->alien && l3->alien[nodeid]) {
 		alien = l3->alien[nodeid];
@@ -1175,24 +1175,24 @@ static inline int cache_free_alien(struc
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
@@ -1204,7 +1204,7 @@ static int init_cache_nodelists_node(int
 		 * begin anything. Make sure some other cpu on this
 		 * node has not already allocated this
 		 */
-		if (!cachep->nodelists[node]) {
+		if (!cachep->node[node]) {
 			l3 = kmalloc_node(memsize, GFP_KERNEL, node);
 			if (!l3)
 				return -ENOMEM;
@@ -1217,14 +1217,14 @@ static int init_cache_nodelists_node(int
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
@@ -1244,7 +1244,7 @@ static void __cpuinit cpuup_canceled(lon
 		/* cpu is dead; no one can alloc from it. */
 		nc = cachep->array[cpu];
 		cachep->array[cpu] = NULL;
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 
 		if (!l3)
 			goto free_array_cache;
@@ -1287,7 +1287,7 @@ free_array_cache:
 	 * shrink each nodelist to its limit.
 	 */
 	list_for_each_entry(cachep, &slab_caches, list) {
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 		drain_freelist(cachep, l3, l3->free_objects);
@@ -1307,7 +1307,7 @@ static int __cpuinit cpuup_prepare(long
 	 * kmalloc_node allows us to add the slab to the right
 	 * kmem_list3 and not this cpu's kmem_list3
 	 */
-	err = init_cache_nodelists_node(node);
+	err = init_cache_node_node(node);
 	if (err < 0)
 		goto bad;
 
@@ -1342,7 +1342,7 @@ static int __cpuinit cpuup_prepare(long
 			}
 		}
 		cachep->array[cpu] = nc;
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		BUG_ON(!l3);
 
 		spin_lock_irq(&l3->list_lock);
@@ -1442,7 +1442,7 @@ static struct notifier_block __cpuinitda
  *
  * Must hold slab_mutex.
  */
-static int __meminit drain_cache_nodelists_node(int node)
+static int __meminit drain_cache_node_node(int node)
 {
 	struct kmem_cache *cachep;
 	int ret = 0;
@@ -1450,7 +1450,7 @@ static int __meminit drain_cache_nodelis
 	list_for_each_entry(cachep, &slab_caches, list) {
 		struct kmem_cache_node *l3;
 
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 
@@ -1479,12 +1479,12 @@ static int __meminit slab_memory_callbac
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
@@ -1516,7 +1516,7 @@ static void __init init_list(struct kmem
 	spin_lock_init(&ptr->list_lock);
 
 	MAKE_ALL_LISTS(cachep, ptr, nodeid);
-	cachep->nodelists[nodeid] = ptr;
+	cachep->node[nodeid] = ptr;
 }
 
 /*
@@ -1528,8 +1528,8 @@ static void __init set_up_list3s(struct
 	int node;
 
 	for_each_online_node(node) {
-		cachep->nodelists[node] = &initkmem_list3[index + node];
-		cachep->nodelists[node]->next_reap = jiffies +
+		cachep->node[node] = &initkmem_list3[index + node];
+		cachep->node[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
 		    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 	}
@@ -1537,11 +1537,11 @@ static void __init set_up_list3s(struct
 
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
@@ -1553,7 +1553,7 @@ void __init kmem_cache_init(void)
 	int i;
 
 	kmem_cache = &kmem_cache_boot;
-	setup_nodelists_pointer(kmem_cache);
+	setup_node_pointer(kmem_cache);
 
 	if (num_possible_nodes() == 1)
 		use_alien_caches = 0;
@@ -1562,7 +1562,7 @@ void __init kmem_cache_init(void)
 	for (i = 0; i < NUM_INIT_LISTS; i++) {
 		kmem_list3_init(&initkmem_list3[i]);
 		if (i < nr_node_ids)
-			kmem_cache->nodelists[i] = NULL;
+			kmem_cache->node[i] = NULL;
 	}
 	set_up_list3s(kmem_cache, CACHE_CACHE);
 
@@ -1746,7 +1746,7 @@ void __init kmem_cache_init_late(void)
 #ifdef CONFIG_NUMA
 	/*
 	 * Register a memory hotplug callback that initializes and frees
-	 * nodelists.
+	 * node.
 	 */
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 #endif
@@ -1791,7 +1791,7 @@ slab_out_of_memory(struct kmem_cache *ca
 		unsigned long active_objs = 0, num_objs = 0, free_objects = 0;
 		unsigned long active_slabs = 0, num_slabs = 0;
 
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 
@@ -2265,15 +2265,15 @@ static int __init_refok setup_cpu_cache(
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
 
@@ -2384,7 +2384,7 @@ __kmem_cache_create (struct kmem_cache *
 	else
 		gfp = GFP_NOWAIT;
 
-	setup_nodelists_pointer(cachep);
+	setup_node_pointer(cachep);
 #if DEBUG
 
 	/*
@@ -2522,7 +2522,7 @@ static void check_spinlock_acquired(stru
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->nodelists[numa_mem_id()]->list_lock);
+	assert_spin_locked(&cachep->node[numa_mem_id()]->list_lock);
 #endif
 }
 
@@ -2530,7 +2530,7 @@ static void check_spinlock_acquired_node
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->nodelists[node]->list_lock);
+	assert_spin_locked(&cachep->node[node]->list_lock);
 #endif
 }
 
@@ -2553,9 +2553,9 @@ static void do_drain(void *arg)
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
-	spin_lock(&cachep->nodelists[node]->list_lock);
+	spin_lock(&cachep->node[node]->list_lock);
 	free_block(cachep, ac->entry, ac->avail, node);
-	spin_unlock(&cachep->nodelists[node]->list_lock);
+	spin_unlock(&cachep->node[node]->list_lock);
 	ac->avail = 0;
 }
 
@@ -2567,13 +2567,13 @@ static void drain_cpu_caches(struct kmem
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
@@ -2630,7 +2630,7 @@ static int __cache_shrink(struct kmem_ca
 
 	check_irq_on();
 	for_each_online_node(i) {
-		l3 = cachep->nodelists[i];
+		l3 = cachep->node[i];
 		if (!l3)
 			continue;
 
@@ -2677,7 +2677,7 @@ int __kmem_cache_shutdown(struct kmem_ca
 
 	/* NUMA: free the list3 structures */
 	for_each_online_node(i) {
-		l3 = cachep->nodelists[i];
+		l3 = cachep->node[i];
 		if (l3) {
 			kfree(l3->shared);
 			free_alien_cache(l3->alien);
@@ -2874,7 +2874,7 @@ static int cache_grow(struct kmem_cache
 
 	/* Take the l3 list lock to change the colour_next on this node */
 	check_irq_off();
-	l3 = cachep->nodelists[nodeid];
+	l3 = cachep->node[nodeid];
 	spin_lock(&l3->list_lock);
 
 	/* Get colour for the slab, and cal the next value. */
@@ -3072,7 +3072,7 @@ retry:
 		 */
 		batchcount = BATCHREFILL_LIMIT;
 	}
-	l3 = cachep->nodelists[node];
+	l3 = cachep->node[node];
 
 	BUG_ON(ac->avail > 0 || !l3);
 	spin_lock(&l3->list_lock);
@@ -3294,7 +3294,7 @@ static void *alternate_node_alloc(struct
 /*
  * Fallback function if there was no memory available and no objects on a
  * certain node and fall back is permitted. First we scan all the
- * available nodelists for available objects. If that fails then we
+ * available node for available objects. If that fails then we
  * perform an allocation without specifying a node. This allows the page
  * allocator to do its reclaim / fallback magic. We then insert the
  * slab into the proper nodelist and then allocate from it.
@@ -3328,8 +3328,8 @@ retry:
 		nid = zone_to_nid(zone);
 
 		if (cpuset_zone_allowed_hardwall(zone, flags) &&
-			cache->nodelists[nid] &&
-			cache->nodelists[nid]->free_objects) {
+			cache->node[nid] &&
+			cache->node[nid]->free_objects) {
 				obj = ____cache_alloc_node(cache,
 					flags | GFP_THISNODE, nid);
 				if (obj)
@@ -3389,7 +3389,7 @@ static void *____cache_alloc_node(struct
 	void *obj;
 	int x;
 
-	l3 = cachep->nodelists[nodeid];
+	l3 = cachep->node[nodeid];
 	BUG_ON(!l3);
 
 retry:
@@ -3472,7 +3472,7 @@ slab_alloc_node(struct kmem_cache *cache
 	if (nodeid == NUMA_NO_NODE)
 		nodeid = slab_node;
 
-	if (unlikely(!cachep->nodelists[nodeid])) {
+	if (unlikely(!cachep->node[nodeid])) {
 		/* Node not bootstrapped yet */
 		ptr = fallback_alloc(cachep, flags);
 		goto out;
@@ -3586,7 +3586,7 @@ static void free_block(struct kmem_cache
 		objp = objpp[i];
 
 		slabp = virt_to_slab(objp);
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		list_del(&slabp->list);
 		check_spinlock_acquired_node(cachep, node);
 		check_slabp(cachep, slabp);
@@ -3630,7 +3630,7 @@ static void cache_flusharray(struct kmem
 	BUG_ON(!batchcount || batchcount > ac->avail);
 #endif
 	check_irq_off();
-	l3 = cachep->nodelists[node];
+	l3 = cachep->node[node];
 	spin_lock(&l3->list_lock);
 	if (l3->shared) {
 		struct array_cache *shared_array = l3->shared;
@@ -3940,7 +3940,7 @@ static int alloc_kmemlist(struct kmem_ca
 			}
 		}
 
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (l3) {
 			struct array_cache *shared = l3->shared;
 
@@ -3976,7 +3976,7 @@ static int alloc_kmemlist(struct kmem_ca
 		l3->alien = new_alien;
 		l3->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
-		cachep->nodelists[node] = l3;
+		cachep->node[node] = l3;
 	}
 	return 0;
 
@@ -3985,13 +3985,13 @@ fail:
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
@@ -4051,9 +4051,9 @@ static int do_tune_cpucache(struct kmem_
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
@@ -4174,7 +4174,7 @@ static void cache_reap(struct work_struc
 		 * have established with reasonable certainty that
 		 * we can do some work if the lock was obtained.
 		 */
-		l3 = searchp->nodelists[node];
+		l3 = searchp->node[node];
 
 		reap_alien(searchp, l3);
 
@@ -4273,7 +4273,7 @@ static int s_show(struct seq_file *m, vo
 	active_objs = 0;
 	num_slabs = 0;
 	for_each_online_node(node) {
-		l3 = cachep->nodelists[node];
+		l3 = cachep->node[node];
 		if (!l3)
 			continue;
 
@@ -4527,7 +4527,7 @@ static int leaks_show(struct seq_file *m
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
