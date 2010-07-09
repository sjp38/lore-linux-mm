Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 50E7F600924
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:12:24 -0400 (EDT)
Message-Id: <20100709190856.718793052@quilx.com>
Date: Fri, 09 Jul 2010 14:07:18 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q2 12/19] slub: Dynamically size kmalloc cache allocations
References: <20100709190706.938177313@quilx.com>
Content-Disposition: inline; filename=slub_dynamic_kmem_alloc
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

kmalloc caches are statically defined and may take up a lot of space just
because the sizes of the node array has to be dimensioned for the largest
node count supported.

This patch makes the size of the kmem_cache structure dynamic throughout by
creating a kmem_cache slab cache for the kmem_cache objects. The bootstrap
occurs by allocating the initial one or two kmem_cache objects from the
page allocator.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    7 -
 mm/slub.c                |  181 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 139 insertions(+), 49 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-07-06 15:25:56.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-07-07 08:45:14.000000000 -0500
@@ -136,19 +136,16 @@ struct kmem_cache {
 
 #ifdef CONFIG_ZONE_DMA
 #define SLUB_DMA __GFP_DMA
-/* Reserve extra caches for potential DMA use */
-#define KMALLOC_CACHES (2 * SLUB_PAGE_SHIFT)
 #else
 /* Disable DMA functionality */
 #define SLUB_DMA (__force gfp_t)0
-#define KMALLOC_CACHES SLUB_PAGE_SHIFT
 #endif
 
 /*
  * We keep the general caches in an array of slab caches that are used for
  * 2^x bytes of allocations.
  */
-extern struct kmem_cache kmalloc_caches[KMALLOC_CACHES];
+extern struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
 
 /*
  * Sorry that the following has to be that ugly but some versions of GCC
@@ -213,7 +210,7 @@ static __always_inline struct kmem_cache
 	if (index == 0)
 		return NULL;
 
-	return &kmalloc_caches[index];
+	return kmalloc_caches[index];
 }
 
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-06 15:26:31.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-07 08:45:14.000000000 -0500
@@ -179,7 +179,7 @@ static struct notifier_block slab_notifi
 
 static enum {
 	DOWN,		/* No slab functionality available */
-	PARTIAL,	/* kmem_cache_open() works but kmalloc does not */
+	PARTIAL,	/* Kmem_cache_node works */
 	UP,		/* Everything works but does not show up in sysfs */
 	SYSFS		/* Sysfs up */
 } slab_state = DOWN;
@@ -2079,6 +2079,8 @@ static inline int alloc_kmem_cache_cpus(
 }
 
 #ifdef CONFIG_NUMA
+static struct kmem_cache *kmem_cache_node;
+
 /*
  * No kmalloc_node yet so do it by hand. We know that this is the first
  * slab on the node for this slabcache. There are no concurrent accesses
@@ -2094,9 +2096,9 @@ static void early_kmem_cache_node_alloc(
 	struct kmem_cache_node *n;
 	unsigned long flags;
 
-	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
+	BUG_ON(kmem_cache_node->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, GFP_KERNEL, node);
+	page = new_slab(kmem_cache_node, GFP_KERNEL, node);
 
 	BUG_ON(!page);
 	if (page_to_nid(page) != node) {
@@ -2108,15 +2110,15 @@ static void early_kmem_cache_node_alloc(
 
 	n = page->freelist;
 	BUG_ON(!n);
-	page->freelist = get_freepointer(kmalloc_caches, n);
+	page->freelist = get_freepointer(kmem_cache_node, n);
 	page->inuse++;
-	kmalloc_caches->node[node] = n;
+	kmem_cache_node->node[node] = n;
 #ifdef CONFIG_SLUB_DEBUG
-	init_object(kmalloc_caches, n, 1);
-	init_tracking(kmalloc_caches, n);
+	init_object(kmem_cache_node, n, 1);
+	init_tracking(kmem_cache_node, n);
 #endif
-	init_kmem_cache_node(n, kmalloc_caches);
-	inc_slabs_node(kmalloc_caches, node, page->objects);
+	init_kmem_cache_node(n, kmem_cache_node);
+	inc_slabs_node(kmem_cache_node, node, page->objects);
 
 	/*
 	 * lockdep requires consistent irq usage for each lock
@@ -2134,8 +2136,10 @@ static void free_kmem_cache_nodes(struct
 
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = s->node[node];
+
 		if (n)
-			kmem_cache_free(kmalloc_caches, n);
+			kmem_cache_free(kmem_cache_node, n);
+
 		s->node[node] = NULL;
 	}
 }
@@ -2151,7 +2155,7 @@ static int init_kmem_cache_nodes(struct 
 			early_kmem_cache_node_alloc(node);
 			continue;
 		}
-		n = kmem_cache_alloc_node(kmalloc_caches,
+		n = kmem_cache_alloc_node(kmem_cache_node,
 						GFP_KERNEL, node);
 
 		if (!n) {
@@ -2505,11 +2509,13 @@ EXPORT_SYMBOL(kmem_cache_destroy);
  *		Kmalloc subsystem
  *******************************************************************/
 
-struct kmem_cache kmalloc_caches[KMALLOC_CACHES] __cacheline_aligned;
+struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
 EXPORT_SYMBOL(kmalloc_caches);
 
+static struct kmem_cache *kmem_cache;
+
 #ifdef CONFIG_ZONE_DMA
-static struct kmem_cache kmalloc_dma_caches[SLUB_PAGE_SHIFT];
+static struct kmem_cache *kmalloc_dma_caches[SLUB_PAGE_SHIFT];
 #endif
 
 static int __init setup_slub_min_order(char *str)
@@ -2548,9 +2554,13 @@ static int __init setup_slub_nomerge(cha
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
-static void create_kmalloc_cache(struct kmem_cache *s,
+static void __init create_kmalloc_cache(struct kmem_cache **sp,
 		const char *name, int size, unsigned int flags)
 {
+	struct kmem_cache *s;
+
+	s = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
+
 	/*
 	 * This function is called with IRQs disabled during early-boot on
 	 * single CPU so there's no need to take slub_lock here.
@@ -2559,6 +2569,8 @@ static void create_kmalloc_cache(struct 
 								flags, NULL))
 		goto panic;
 
+	*sp = s;
+
 	list_add(&s->list, &slab_caches);
 
 	if (!sysfs_slab_add(s))
@@ -2620,10 +2632,10 @@ static struct kmem_cache *get_slab(size_
 
 #ifdef CONFIG_ZONE_DMA
 	if (unlikely((flags & SLUB_DMA)))
-		return &kmalloc_dma_caches[index];
+		return kmalloc_dma_caches[index];
 
 #endif
-	return &kmalloc_caches[index];
+	return kmalloc_caches[index];
 }
 
 void *__kmalloc(size_t size, gfp_t flags)
@@ -2946,46 +2958,114 @@ static int slab_memory_callback(struct n
  *			Basic setup of slabs
  *******************************************************************/
 
+/*
+ * Used for early kmem_cache structures that were allocated using
+ * the page allocator
+ */
+
+static void __init kmem_cache_bootstrap_fixup(struct kmem_cache *s)
+{
+	int node;
+
+	list_add(&s->list, &slab_caches);
+	sysfs_slab_add(s);
+	s->refcount = -1;
+
+	for_each_node(node) {
+		struct kmem_cache_node *n = get_node(s, node);
+		struct page *p;
+
+		if (n) {
+			list_for_each_entry(p, &n->partial, lru)
+				p->slab = s;
+
+#ifdef CONFIG_SLAB_DEBUG
+			list_for_each_entry(p, &n->full, lru)
+				p->slab = s;
+#endif
+		}
+	}
+}
+
 void __init kmem_cache_init(void)
 {
 	int i;
 	int caches = 0;
+	struct kmem_cache *temp_kmem_cache;
+	int order;
 
 #ifdef CONFIG_NUMA
+	struct kmem_cache *temp_kmem_cache_node;
+	unsigned long kmalloc_size;
+
+	kmem_size = offsetof(struct kmem_cache, node) +
+				nr_node_ids * sizeof(struct kmem_cache_node *);
+
+	/* Allocate two kmem_caches from the page allocator */
+	kmalloc_size = ALIGN(kmem_size, cache_line_size());
+	order = get_order(2 * kmalloc_size);
+	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
+
 	/*
 	 * Must first have the slab cache available for the allocations of the
 	 * struct kmem_cache_node's. There is special bootstrap code in
 	 * kmem_cache_open for slab_state == DOWN.
 	 */
-	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
-		sizeof(struct kmem_cache_node), 0);
-	kmalloc_caches[0].refcount = -1;
-	caches++;
+	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
+
+	kmem_cache_open(kmem_cache_node, "kmem_cache_node",
+		sizeof(struct kmem_cache_node),
+		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
+#else
+	/* Allocate a single kmem_cache from the page allocator */
+	kmem_size = sizeof(struct kmem_cache);
+	order = get_order(kmem_size);
+	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
 #endif
 
 	/* Able to allocate the per node structures */
 	slab_state = PARTIAL;
 
-	/* Caches that are not of the two-to-the-power-of size */
-	if (KMALLOC_MIN_SIZE <= 32) {
-		create_kmalloc_cache(&kmalloc_caches[1],
-				"kmalloc-96", 96, 0);
-		caches++;
-	}
-	if (KMALLOC_MIN_SIZE <= 64) {
-		create_kmalloc_cache(&kmalloc_caches[2],
-				"kmalloc-192", 192, 0);
-		caches++;
-	}
+	temp_kmem_cache = kmem_cache;
+	kmem_cache_open(kmem_cache, "kmem_cache", kmem_size,
+		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
+	memcpy(kmem_cache, temp_kmem_cache, kmem_size);
 
-	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
-		create_kmalloc_cache(&kmalloc_caches[i],
-			"kmalloc", 1 << i, 0);
-		caches++;
-	}
+#ifdef CONFIG_NUMA
+	/*
+	 * Allocate kmem_cache_node properly from the kmem_cache slab.
+	 * kmem_cache_node is separately allocated so no need to
+	 * update any list pointers.
+	 */
+	temp_kmem_cache_node = kmem_cache_node;
 
+	kmem_cache_node = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
+	memcpy(kmem_cache_node, temp_kmem_cache_node, kmem_size);
+
+	kmem_cache_bootstrap_fixup(kmem_cache_node);
+
+	caches++;
+#else
+	/*
+	 * kmem_cache has kmem_cache_node embedded and we moved it!
+	 * Update the list heads
+	 */
+	INIT_LIST_HEAD(&kmem_cache->local_node.partial);
+	list_splice(&temp_kmem_cache->local_node.partial, &kmem_cache->local_node.partial);
+#ifdef CONFIG_SLUB_DEBUG
+	INIT_LIST_HEAD(&kmem_cache->local_node.full);
+	list_splice(&temp_kmem_cache->local_node.full, &kmem_cache->local_node.full);
+#endif
+#endif
+	kmem_cache_bootstrap_fixup(kmem_cache);
+	caches++;
+	/* Free temporary boot structure */
+	free_pages((unsigned long)temp_kmem_cache, order);
+
+	/* Now we can use the kmem_cache to allocate kmalloc slabs */
 
 	/*
 	 * Patch up the size_index table if we have strange large alignment
@@ -3025,6 +3105,25 @@ void __init kmem_cache_init(void)
 			size_index[size_index_elem(i)] = 8;
 	}
 
+	/* Caches that are not of the two-to-the-power-of size */
+	if (KMALLOC_MIN_SIZE <= 32) {
+		create_kmalloc_cache(&kmalloc_caches[1],
+				"kmalloc-96", 96, 0);
+		caches++;
+	}
+
+	if (KMALLOC_MIN_SIZE <= 64) {
+		create_kmalloc_cache(&kmalloc_caches[2],
+				"kmalloc-192", 192, 0);
+		caches++;
+	}
+
+	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
+		create_kmalloc_cache(&kmalloc_caches[i],
+			"kmalloc", 1 << i, 0);
+		caches++;
+	}
+
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */
@@ -3032,18 +3131,12 @@ void __init kmem_cache_init(void)
 		char *s = kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
 
 		BUG_ON(!s);
-		kmalloc_caches[i].name = s;
+		kmalloc_caches[i]->name = s;
 	}
 
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
 #endif
-#ifdef CONFIG_NUMA
-	kmem_size = offsetof(struct kmem_cache, node) +
-				nr_node_ids * sizeof(struct kmem_cache_node *);
-#else
-	kmem_size = sizeof(struct kmem_cache);
-#endif
 
 	printk(KERN_INFO
 		"SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
@@ -3059,7 +3152,7 @@ void __init kmem_cache_init_late(void)
 	int i;
 
 	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
-		struct kmem_cache *s = &kmalloc_caches[i];
+		struct kmem_cache *s = kmalloc_caches[i];
 
 		if (s && s->size) {
 			char *name = kasprintf(GFP_KERNEL,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
