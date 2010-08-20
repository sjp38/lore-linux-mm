Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9B4856B0331
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:33:01 -0400 (EDT)
Date: Fri, 20 Aug 2010 12:32:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [S+Q Cleanup3 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <alpine.DEB.2.00.1008201206390.32757@router.home>
Message-ID: <alpine.DEB.2.00.1008201231520.32757@router.home>
References: <20100819203324.549566024@linux.com> <20100819203438.745611155@linux.com> <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com> <alpine.DEB.2.00.1008191627100.5611@router.home> <alpine.DEB.2.00.1008191600240.25634@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1008191819420.7903@router.home> <alpine.DEB.2.00.1008191638390.29676@chino.kir.corp.google.com> <alpine.DEB.2.00.1008201206390.32757@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > It would really be nice to get rid of all the #ifdefs in kmem_cache_init()
> > for CONFIG_NUMA by extracting them to helper functions if you're
> > interested.

Draft patch to drop SMP particularities.

---
 include/linux/slub_def.h |    5 +----
 mm/slub.c                |   39 +--------------------------------------
 2 files changed, 2 insertions(+), 42 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-08-20 12:08:48.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-08-20 12:09:17.000000000 -0500
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
--- linux-2.6.orig/mm/slub.c	2010-08-20 12:09:19.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-20 12:31:11.000000000 -0500
@@ -232,11 +232,7 @@ int slab_is_available(void)

 static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 {
-#ifdef CONFIG_NUMA
 	return s->node[node];
-#else
-	return &s->local_node;
-#endif
 }

 /* Verify that a pointer has an address that is valid within a slab page */
@@ -837,7 +833,7 @@ static inline void inc_slabs_node(struct
 	 * dilemma by deferring the increment of the count during
 	 * bootstrap (see early_kmem_cache_node_alloc).
 	 */
-	if (!NUMA_BUILD || n) {
+	if (n) {
 		atomic_long_inc(&n->nr_slabs);
 		atomic_long_add(objects, &n->total_objects);
 	}
@@ -2071,7 +2067,6 @@ static inline int alloc_kmem_cache_cpus(
 	return s->cpu_slab != NULL;
 }

-#ifdef CONFIG_NUMA
 static struct kmem_cache *kmem_cache_node;

 /*
@@ -2161,17 +2156,6 @@ static int init_kmem_cache_nodes(struct
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
@@ -2982,8 +2966,6 @@ void __init kmem_cache_init(void)
 	int caches = 0;
 	struct kmem_cache *temp_kmem_cache;
 	int order;
-
-#ifdef CONFIG_NUMA
 	struct kmem_cache *temp_kmem_cache_node;
 	unsigned long kmalloc_size;

@@ -3007,12 +2989,6 @@ void __init kmem_cache_init(void)
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
@@ -3023,7 +2999,6 @@ void __init kmem_cache_init(void)
 	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
 	memcpy(kmem_cache, temp_kmem_cache, kmem_size);

-#ifdef CONFIG_NUMA
 	/*
 	 * Allocate kmem_cache_node properly from the kmem_cache slab.
 	 * kmem_cache_node is separately allocated so no need to
@@ -3037,18 +3012,6 @@ void __init kmem_cache_init(void)
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
