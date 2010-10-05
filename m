Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0C2476B008A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:22 -0400 (EDT)
Message-Id: <20101005185819.929054093@linux.com>
Date: Tue, 05 Oct 2010 13:57:39 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 14/16] slub: Reduce size of not performance critical slabs
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_reduce
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

There are some slab caches around that are rarely used and which are not
performance critical. Add a new SLAB_LOWMEM option to reduce the memory
requirements of such slabs. SLAB_LOWMEM caches will keep no empty slabs
around, have no shared or alien caches and will have a small per cpu
queue of 5 objects.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h |    2 ++
 mm/slub.c            |   25 ++++++++++++++++---------
 2 files changed, 18 insertions(+), 9 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2010-10-05 13:40:04.000000000 -0500
+++ linux-2.6/include/linux/slab.h	2010-10-05 13:40:08.000000000 -0500
@@ -17,12 +17,14 @@
  * The ones marked DEBUG are only valid if CONFIG_SLAB_DEBUG is set.
  */
 #define SLAB_DEBUG_FREE		0x00000100UL	/* DEBUG: Perform (expensive) checks on free */
+#define SLAB_LOWMEM		0x00000200UL	/* Reduce memory usage of this slab */
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
+
 /*
  * SLAB_DESTROY_BY_RCU - **WARNING** READ THIS!
  *
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-05 13:40:04.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-05 13:40:08.000000000 -0500
@@ -2829,12 +2829,20 @@ static int kmem_cache_open(struct kmem_c
 	 * The larger the object size is, the more pages we want on the partial
 	 * list to avoid pounding the page allocator excessively.
 	 */
-	set_min_partial(s, ilog2(s->size));
+	if (flags & SLAB_LOWMEM)
+		set_min_partial(s, 0);
+	else
+		set_min_partial(s, ilog2(s->size));
+
 	s->refcount = 1;
 	if (!init_kmem_cache_nodes(s))
 		goto error;
 
-	s->queue = initial_queue_size(s->size);
+	if (flags & SLAB_LOWMEM)
+		s->queue = 5;
+	else
+		s->queue = initial_queue_size(s->size);
+
 	s->batch = (s->queue + 1) / 2;
 
 #ifdef CONFIG_NUMA
@@ -2879,7 +2887,9 @@ static int kmem_cache_open(struct kmem_c
 
 	if (alloc_kmem_cache_cpus(s)) {
 		s->shared_queue_sysfs = 0;
-		if (nr_cpu_ids > 1 && s->size < PAGE_SIZE) {
+		if (!(flags & SLAB_LOWMEM) &&
+				nr_cpu_ids > 1 &&
+				s->size < PAGE_SIZE) {
 			s->shared_queue_sysfs = 10 * s->batch;
 			alloc_shared_caches(s);
 		}
@@ -3788,7 +3798,7 @@ void __init kmem_cache_init(void)
 
 	kmem_cache_open(kmem_cache_node, "kmem_cache_node",
 		sizeof(struct kmem_cache_node),
-		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_LOWMEM, NULL);
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 
@@ -3797,7 +3807,7 @@ void __init kmem_cache_init(void)
 
 	temp_kmem_cache = kmem_cache;
 	kmem_cache_open(kmem_cache, "kmem_cache", kmem_size,
-		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_LOWMEM, NULL);
 	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
 	memcpy(kmem_cache, temp_kmem_cache, kmem_size);
 
@@ -3906,12 +3916,9 @@ void __init kmem_cache_init(void)
 		if (s && s->size) {
 			char *name = kasprintf(GFP_NOWAIT,
 				 "dma-kmalloc-%d", s->objsize);
-
 			BUG_ON(!name);
 			kmalloc_dma_caches[i] = create_kmalloc_cache(name,
-				s->objsize, SLAB_CACHE_DMA);
-			 /* DMA caches are rarely used. Reduce memory consumption */
-			kmalloc_dma_caches[i]->shared_queue_sysfs = 0;
+				s->objsize, SLAB_CACHE_DMA | SLAB_LOWMEM);
 		}
 	}
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
