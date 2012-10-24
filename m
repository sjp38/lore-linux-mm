Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 318A26B0074
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 11:06:13 -0400 (EDT)
Message-Id: <0000013a934f2b3e-d3b1d3f9-7b5c-4e4b-bedc-b8dc864a7c65-000000@email.amazonses.com>
Date: Wed, 24 Oct 2012 15:06:11 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK4 [03/15] slub: Use a statically allocated kmem_cache boot structure for bootstrap
References: <20121024150518.156629201@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Simplify bootstrap by statically allocated two kmem_cache structures. These are
freed after bootup is complete. Allows us to no longer worry about calculations
of sizes of kmem_cache structures during bootstrap.

V1->V2:
	- Use kmem_cache_zalloc to properly zero structures.
	- Simplify setup by introducing a new boottime
		function "bootstrap()".

Reviewed-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   41 +++++++++++------------------------------
 1 file changed, 11 insertions(+), 30 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-10-24 09:33:17.773804951 -0500
+++ linux/mm/slub.c	2012-10-24 09:49:55.791858212 -0500
@@ -3644,15 +3644,16 @@ static int slab_memory_callback(struct n
 
 /*
  * Used for early kmem_cache structures that were allocated using
- * the page allocator
+ * the page allocator. Allocate them properly then fix up the pointers
+ * that may be pointing to the wrong kmem_cache structure.
  */
 
-static void __init kmem_cache_bootstrap_fixup(struct kmem_cache *s)
+static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 {
 	int node;
+	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 
-	list_add(&s->list, &slab_caches);
-	s->refcount = -1;
+	memcpy(s, static_cache, kmem_size);
 
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
@@ -3668,70 +3669,44 @@ static void __init kmem_cache_bootstrap_
 #endif
 		}
 	}
+	return s;
 }
 
+static __initdata struct kmem_cache boot_kmem_cache,
+			boot_kmem_cache_node;
+
 void __init kmem_cache_init(void)
 {
 	int i;
-	int caches = 0;
-	struct kmem_cache *temp_kmem_cache;
-	int order;
-	struct kmem_cache *temp_kmem_cache_node;
-	unsigned long kmalloc_size;
+	int caches = 2;
 
 	if (debug_guardpage_minorder())
 		slub_max_order = 0;
 
+	kmem_cache_node = &boot_kmem_cache_node;
+	kmem_cache = &boot_kmem_cache;
 	kmem_size = offsetof(struct kmem_cache, node) +
 			nr_node_ids * sizeof(struct kmem_cache_node *);
 
-	/* Allocate two kmem_caches from the page allocator */
-	kmalloc_size = ALIGN(kmem_size, cache_line_size());
-	order = get_order(2 * kmalloc_size);
-	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT | __GFP_ZERO, order);
-
-	/*
-	 * Must first have the slab cache available for the allocations of the
-	 * struct kmem_cache_node's. There is special bootstrap code in
-	 * kmem_cache_open for slab_state == DOWN.
-	 */
-	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
-
-	kmem_cache_node->name = "kmem_cache_node";
-	kmem_cache_node->size = kmem_cache_node->object_size =
-		sizeof(struct kmem_cache_node);
-	kmem_cache_open(kmem_cache_node, SLAB_HWCACHE_ALIGN | SLAB_PANIC);
+	create_boot_cache(kmem_cache_node, "kmem_cache_node",
+		sizeof(struct kmem_cache_node), SLAB_HWCACHE_ALIGN);
 
 	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 
 	/* Able to allocate the per node structures */
 	slab_state = PARTIAL;
 
-	temp_kmem_cache = kmem_cache;
-	kmem_cache->name = "kmem_cache";
-	kmem_cache->size = kmem_cache->object_size = kmem_size;
-	kmem_cache_open(kmem_cache, SLAB_HWCACHE_ALIGN | SLAB_PANIC);
+	create_boot_cache(kmem_cache, "kmem_cache", kmem_size,
+		       SLAB_HWCACHE_ALIGN);
 
-	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
-	memcpy(kmem_cache, temp_kmem_cache, kmem_size);
+	kmem_cache = bootstrap(&boot_kmem_cache);
 
 	/*
 	 * Allocate kmem_cache_node properly from the kmem_cache slab.
 	 * kmem_cache_node is separately allocated so no need to
 	 * update any list pointers.
 	 */
-	temp_kmem_cache_node = kmem_cache_node;
-
-	kmem_cache_node = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
-	memcpy(kmem_cache_node, temp_kmem_cache_node, kmem_size);
-
-	kmem_cache_bootstrap_fixup(kmem_cache_node);
-
-	caches++;
-	kmem_cache_bootstrap_fixup(kmem_cache);
-	caches++;
-	/* Free temporary boot structure */
-	free_pages((unsigned long)temp_kmem_cache, order);
+	kmem_cache_node = bootstrap(&boot_kmem_cache_node);
 
 	/* Now we can use the kmem_cache to allocate kmalloc slabs */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
