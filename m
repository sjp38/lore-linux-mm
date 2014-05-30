Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4590E6B0038
	for <linux-mm@kvack.org>; Fri, 30 May 2014 14:28:10 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id hq11so546315vcb.11
        for <linux-mm@kvack.org>; Fri, 30 May 2014 11:28:10 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id g7si3686145vek.12.2014.05.30.11.28.09
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 11:28:09 -0700 (PDT)
Message-Id: <20140530182801.551316493@linux.com>
Date: Fri, 30 May 2014 13:27:56 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 3/4] slab: Use get_node function
References: <20140530182753.191965442@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=common_slab_node
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2014-05-30 13:07:17.313211059 -0500
+++ linux/mm/slab.c	2014-05-30 13:07:17.313211059 -0500
@@ -267,7 +267,7 @@ static void kmem_cache_node_init(struct
 #define MAKE_LIST(cachep, listp, slab, nodeid)				\
 	do {								\
 		INIT_LIST_HEAD(listp);					\
-		list_splice(&(cachep->node[nodeid]->slab), listp);	\
+		list_splice(&get_node(cachep, nodeid)->slab, listp);	\
 	} while (0)
 
 #define	MAKE_ALL_LISTS(cachep, ptr, nodeid)				\
@@ -461,7 +461,7 @@ static void slab_set_lock_classes(struct
 	struct kmem_cache_node *n;
 	int r;
 
-	n = cachep->node[q];
+	n = get_node(cachep, q);
 	if (!n)
 		return;
 
@@ -509,7 +509,7 @@ static void init_node_lock_keys(int q)
 		if (!cache)
 			continue;
 
-		n = cache->node[q];
+		n = get_node(cache, q);
 		if (!n || OFF_SLAB(cache))
 			continue;
 
@@ -520,7 +520,7 @@ static void init_node_lock_keys(int q)
 
 static void on_slab_lock_classes_node(struct kmem_cache *cachep, int q)
 {
-	if (!cachep->node[q])
+	if (!get_node(cachep, q))
 		return;
 
 	slab_set_lock_classes(cachep, &on_slab_l3_key,
@@ -774,7 +774,7 @@ static inline bool is_slab_pfmemalloc(st
 static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
 						struct array_cache *ac)
 {
-	struct kmem_cache_node *n = cachep->node[numa_mem_id()];
+	struct kmem_cache_node *n = get_node(cachep,numa_mem_id());
 	struct page *page;
 	unsigned long flags;
 
@@ -829,7 +829,7 @@ static void *__ac_get_obj(struct kmem_ca
 		 * If there are empty slabs on the slabs_free list and we are
 		 * being forced to refill the cache, mark this one !pfmemalloc.
 		 */
-		n = cachep->node[numa_mem_id()];
+		n = get_node(cachep, numa_mem_id());
 		if (!list_empty(&n->slabs_free) && force_refill) {
 			struct page *page = virt_to_head_page(objp);
 			ClearPageSlabPfmemalloc(page);
@@ -979,7 +979,7 @@ static void free_alien_cache(struct arra
 static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
-	struct kmem_cache_node *n = cachep->node[node];
+	struct kmem_cache_node *n = get_node(cachep, node);
 
 	if (ac->avail) {
 		spin_lock(&n->list_lock);
@@ -1047,7 +1047,7 @@ static inline int cache_free_alien(struc
 	if (likely(nodeid == node))
 		return 0;
 
-	n = cachep->node[node];
+	n = get_node(cachep, node);
 	STATS_INC_NODEFREES(cachep);
 	if (n->alien && n->alien[nodeid]) {
 		alien = n->alien[nodeid];
@@ -1059,9 +1059,9 @@ static inline int cache_free_alien(struc
 		ac_put_obj(cachep, alien, objp);
 		spin_unlock(&alien->lock);
 	} else {
-		spin_lock(&(cachep->node[nodeid])->list_lock);
+		spin_lock(&get_node(cachep, nodeid)->list_lock);
 		free_block(cachep, &objp, 1, nodeid);
-		spin_unlock(&(cachep->node[nodeid])->list_lock);
+		spin_unlock(&get_node(cachep, nodeid)->list_lock);
 	}
 	return 1;
 }
@@ -1088,7 +1088,7 @@ static int init_cache_node_node(int node
 		 * begin anything. Make sure some other cpu on this
 		 * node has not already allocated this
 		 */
-		if (!cachep->node[node]) {
+		if (!get_node(cachep, node)) {
 			n = kmalloc_node(memsize, GFP_KERNEL, node);
 			if (!n)
 				return -ENOMEM;
@@ -1104,11 +1104,11 @@ static int init_cache_node_node(int node
 			cachep->node[node] = n;
 		}
 
-		spin_lock_irq(&cachep->node[node]->list_lock);
-		cachep->node[node]->free_limit =
+		spin_lock_irq(&get_node(cachep, node)->list_lock);
+		get_node(cachep, node)->free_limit =
 			(1 + nr_cpus_node(node)) *
 			cachep->batchcount + cachep->num;
-		spin_unlock_irq(&cachep->node[node]->list_lock);
+		spin_unlock_irq(&get_node(cachep, node)->list_lock);
 	}
 	return 0;
 }
@@ -1134,7 +1134,7 @@ static void cpuup_canceled(long cpu)
 		/* cpu is dead; no one can alloc from it. */
 		nc = cachep->array[cpu];
 		cachep->array[cpu] = NULL;
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 
 		if (!n)
 			goto free_array_cache;
@@ -1177,7 +1177,7 @@ free_array_cache:
 	 * shrink each nodelist to its limit.
 	 */
 	list_for_each_entry(cachep, &slab_caches, list) {
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		if (!n)
 			continue;
 		drain_freelist(cachep, n, slabs_tofree(cachep, n));
@@ -1232,7 +1232,7 @@ static int cpuup_prepare(long cpu)
 			}
 		}
 		cachep->array[cpu] = nc;
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		BUG_ON(!n);
 
 		spin_lock_irq(&n->list_lock);
@@ -1343,7 +1343,7 @@ static int __meminit drain_cache_node_no
 	list_for_each_entry(cachep, &slab_caches, list) {
 		struct kmem_cache_node *n;
 
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		if (!n)
 			continue;
 
@@ -2371,7 +2371,7 @@ static void check_spinlock_acquired(stru
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->node[numa_mem_id()]->list_lock);
+	assert_spin_locked(&get_node(cachep, numa_mem_id())->list_lock);
 #endif
 }
 
@@ -2379,7 +2379,7 @@ static void check_spinlock_acquired_node
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->node[node]->list_lock);
+	assert_spin_locked(&get_node(cachep, node)->list_lock);
 #endif
 }
 
@@ -2402,9 +2402,9 @@ static void do_drain(void *arg)
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
-	spin_lock(&cachep->node[node]->list_lock);
+	spin_lock(&get_node(cachep, node)->list_lock);
 	free_block(cachep, ac->entry, ac->avail, node);
-	spin_unlock(&cachep->node[node]->list_lock);
+	spin_unlock(&get_node(cachep, node)->list_lock);
 	ac->avail = 0;
 }
 
@@ -2416,13 +2416,13 @@ static void drain_cpu_caches(struct kmem
 	on_each_cpu(do_drain, cachep, 1);
 	check_irq_on();
 	for_each_online_node(node) {
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		if (n && n->alien)
 			drain_alien_cache(cachep, n->alien);
 	}
 
 	for_each_online_node(node) {
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		if (n)
 			drain_array(cachep, n, n->shared, 1, node);
 	}
@@ -2479,7 +2479,7 @@ static int __cache_shrink(struct kmem_ca
 
 	check_irq_on();
 	for_each_online_node(i) {
-		n = cachep->node[i];
+		n = get_node(cachep, i);
 		if (!n)
 			continue;
 
@@ -2526,7 +2526,7 @@ int __kmem_cache_shutdown(struct kmem_ca
 
 	/* NUMA: free the node structures */
 	for_each_online_node(i) {
-		n = cachep->node[i];
+		n = get_node(cachep, i);
 		if (n) {
 			kfree(n->shared);
 			free_alien_cache(n->alien);
@@ -2709,7 +2709,7 @@ static int cache_grow(struct kmem_cache
 
 	/* Take the node list lock to change the colour_next on this node */
 	check_irq_off();
-	n = cachep->node[nodeid];
+	n = get_node(cachep, nodeid);
 	spin_lock(&n->list_lock);
 
 	/* Get colour for the slab, and cal the next value. */
@@ -2877,7 +2877,7 @@ retry:
 		 */
 		batchcount = BATCHREFILL_LIMIT;
 	}
-	n = cachep->node[node];
+	n = get_node(cachep, node);
 
 	BUG_ON(ac->avail > 0 || !n);
 	spin_lock(&n->list_lock);
@@ -3121,8 +3121,8 @@ retry:
 		nid = zone_to_nid(zone);
 
 		if (cpuset_zone_allowed_hardwall(zone, flags) &&
-			cache->node[nid] &&
-			cache->node[nid]->free_objects) {
+			get_node(cache, nid) &&
+			get_node(cache, nid)->free_objects) {
 				obj = ____cache_alloc_node(cache,
 					flags | GFP_THISNODE, nid);
 				if (obj)
@@ -3185,7 +3185,7 @@ static void *____cache_alloc_node(struct
 	int x;
 
 	VM_BUG_ON(nodeid > num_online_nodes());
-	n = cachep->node[nodeid];
+	n = get_node(cachep, nodeid);
 	BUG_ON(!n);
 
 retry:
@@ -3256,7 +3256,7 @@ slab_alloc_node(struct kmem_cache *cache
 	if (nodeid == NUMA_NO_NODE)
 		nodeid = slab_node;
 
-	if (unlikely(!cachep->node[nodeid])) {
+	if (unlikely(!get_node(cachep, nodeid))) {
 		/* Node not bootstrapped yet */
 		ptr = fallback_alloc(cachep, flags);
 		goto out;
@@ -3372,7 +3372,7 @@ static void free_block(struct kmem_cache
 		objp = objpp[i];
 
 		page = virt_to_head_page(objp);
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		list_del(&page->lru);
 		check_spinlock_acquired_node(cachep, node);
 		slab_put_obj(cachep, page, objp, node);
@@ -3414,7 +3414,7 @@ static void cache_flusharray(struct kmem
 	BUG_ON(!batchcount || batchcount > ac->avail);
 #endif
 	check_irq_off();
-	n = cachep->node[node];
+	n = get_node(cachep, node);
 	spin_lock(&n->list_lock);
 	if (n->shared) {
 		struct array_cache *shared_array = n->shared;
@@ -3727,7 +3727,7 @@ static int alloc_kmem_cache_node(struct
 			}
 		}
 
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		if (n) {
 			struct array_cache *shared = n->shared;
 
@@ -3772,8 +3772,8 @@ fail:
 		/* Cache is not active yet. Roll back what we did */
 		node--;
 		while (node >= 0) {
-			if (cachep->node[node]) {
-				n = cachep->node[node];
+			if (get_node(cachep, node)) {
+				n = get_node(cachep, node);
 
 				kfree(n->shared);
 				free_alien_cache(n->alien);
@@ -3838,9 +3838,9 @@ static int __do_tune_cpucache(struct kme
 		struct array_cache *ccold = new->new[i];
 		if (!ccold)
 			continue;
-		spin_lock_irq(&cachep->node[cpu_to_mem(i)]->list_lock);
+		spin_lock_irq(&get_node(cachep, cpu_to_mem(i))->list_lock);
 		free_block(cachep, ccold->entry, ccold->avail, cpu_to_mem(i));
-		spin_unlock_irq(&cachep->node[cpu_to_mem(i)]->list_lock);
+		spin_unlock_irq(&get_node(cachep, cpu_to_mem(i))->list_lock);
 		kfree(ccold);
 	}
 	kfree(new);
@@ -4000,7 +4000,7 @@ static void cache_reap(struct work_struc
 		 * have established with reasonable certainty that
 		 * we can do some work if the lock was obtained.
 		 */
-		n = searchp->node[node];
+		n = get_node(searchp, node);
 
 		reap_alien(searchp, n);
 
@@ -4053,7 +4053,7 @@ void get_slabinfo(struct kmem_cache *cac
 	active_objs = 0;
 	num_slabs = 0;
 	for_each_online_node(node) {
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		if (!n)
 			continue;
 
@@ -4290,7 +4290,7 @@ static int leaks_show(struct seq_file *m
 	x[1] = 0;
 
 	for_each_online_node(node) {
-		n = cachep->node[node];
+		n = get_node(cachep, node);
 		if (!n)
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
