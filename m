Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DBA0A6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 09:10:58 -0400 (EDT)
Message-Id: <20100928131056.509118201@linux.com>
Date: Tue, 28 Sep 2010 08:10:26 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup5 1/3] slub: reduce differences between SMP and NUMA
References: <20100928131025.319846721@linux.com>
Content-Disposition: inline; filename=drop_smp
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Reduce the #ifdefs and simplify bootstrap by making SMP and NUMA as much alike
as possible. This means that there will be an additional indirection to get to
the kmem_cache_node field under SMP.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    5 +----
 mm/slub.c                |   39 +--------------------------------------
 2 files changed, 2 insertions(+), 42 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-09-28 07:54:31.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-09-28 07:56:37.000000000 -0500
@@ -96,11 +96,8 @@ struct kmem_cache {
 	 * Defragmentation by allocating from a remote node.
 	 */
 	int remote_node_defrag_ratio;
-	struct kmem_cache_node *node[MAX_NUMNODES];
-#else
-	/* Avoid an extra cache line for UP */
-	struct kmem_cache_node local_node;
 #endif
+	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
 /*
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-09-28 07:54:33.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-09-28 07:56:37.000000000 -0500
@@ -233,11 +233,7 @@ int slab_is_available(void)
 
 static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 {
-#ifdef CONFIG_NUMA
 	return s->node[node];
-#else
-	return &s->local_node;
-#endif
 }
 
 /* Verify that a pointer has an address that is valid within a slab page */
@@ -871,7 +867,7 @@ static inline void inc_slabs_node(struct
 	 * dilemma by deferring the increment of the count during
 	 * bootstrap (see early_kmem_cache_node_alloc).
 	 */
-	if (!NUMA_BUILD || n) {
+	if (n) {
 		atomic_long_inc(&n->nr_slabs);
 		atomic_long_add(objects, &n->total_objects);
 	}
@@ -2112,7 +2108,6 @@ static inline int alloc_kmem_cache_cpus(
 	return s->cpu_slab != NULL;
 }
 
-#ifdef CONFIG_NUMA
 static struct kmem_cache *kmem_cache_node;
 
 /*
@@ -2202,17 +2197,6 @@ static int init_kmem_cache_nodes(struct 
 	}
 	return 1;
 }
-#else
-static void free_kmem_cache_nodes(struct kmem_cache *s)
-{
-}
-
-static int init_kmem_cache_nodes(struct kmem_cache *s)
-{
-	init_kmem_cache_node(&s->local_node, s);
-	return 1;
-}
-#endif
 
 static void set_min_partial(struct kmem_cache *s, unsigned long min)
 {
@@ -3023,8 +3007,6 @@ void __init kmem_cache_init(void)
 	int caches = 0;
 	struct kmem_cache *temp_kmem_cache;
 	int order;
-
-#ifdef CONFIG_NUMA
 	struct kmem_cache *temp_kmem_cache_node;
 	unsigned long kmalloc_size;
 
@@ -3048,12 +3030,6 @@ void __init kmem_cache_init(void)
 		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
-#else
-	/* Allocate a single kmem_cache from the page allocator */
-	kmem_size = sizeof(struct kmem_cache);
-	order = get_order(kmem_size);
-	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
-#endif
 
 	/* Able to allocate the per node structures */
 	slab_state = PARTIAL;
@@ -3064,7 +3040,6 @@ void __init kmem_cache_init(void)
 	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
 	memcpy(kmem_cache, temp_kmem_cache, kmem_size);
 
-#ifdef CONFIG_NUMA
 	/*
 	 * Allocate kmem_cache_node properly from the kmem_cache slab.
 	 * kmem_cache_node is separately allocated so no need to
@@ -3078,18 +3053,6 @@ void __init kmem_cache_init(void)
 	kmem_cache_bootstrap_fixup(kmem_cache_node);
 
 	caches++;
-#else
-	/*
-	 * kmem_cache has kmem_cache_node embedded and we moved it!
-	 * Update the list heads
-	 */
-	INIT_LIST_HEAD(&kmem_cache->local_node.partial);
-	list_splice(&temp_kmem_cache->local_node.partial, &kmem_cache->local_node.partial);
-#ifdef CONFIG_SLUB_DEBUG
-	INIT_LIST_HEAD(&kmem_cache->local_node.full);
-	list_splice(&temp_kmem_cache->local_node.full, &kmem_cache->local_node.full);
-#endif
-#endif
 	kmem_cache_bootstrap_fixup(kmem_cache);
 	caches++;
 	/* Free temporary boot structure */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
