Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7E8B46B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:15:39 -0400 (EDT)
Message-Id: <20120802201537.792112551@linux.com>
Date: Thu, 02 Aug 2012 15:15:19 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [13/19] slub: Use a statically allocated kmem_cache boot structure for bootstrap
References: <20120802201506.266817615@linux.com>
Content-Disposition: inline; filename=slub_static_init
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Simplify bootstrap by statically allocated two kmem_cache structures. These are
freed after bootup is complete. Allows us to no longer worry about calculations
of sizes of kmem_cache structures during bootstrap.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   32 +++++++++-----------------------
 1 file changed, 9 insertions(+), 23 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-01 14:52:12.944165176 -0500
+++ linux-2.6/mm/slub.c	2012-08-01 14:57:05.201430270 -0500
@@ -3686,13 +3686,13 @@
 	}
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
+	int caches = 2;
 	unsigned long kmalloc_size;
 
 	if (debug_guardpage_minorder())
@@ -3701,19 +3701,10 @@
 	kmem_size = offsetof(struct kmem_cache, node) +
 			nr_node_ids * sizeof(struct kmem_cache_node *);
 
-	/* Allocate two kmem_caches from the page allocator */
 	kmalloc_size = ALIGN(kmem_size, cache_line_size());
-	order = get_order(2 * kmalloc_size);
-	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
-
-	/*
-	 * Must first have the slab cache available for the allocations of the
-	 * struct kmem_cache_node's. There is special bootstrap code in
-	 * kmem_cache_open for slab_state == DOWN.
-	 */
-	kmem_cache_node = (void *)kmem_cache + kmalloc_size;
+	kmem_cache_node = &boot_kmem_cache_node;
 
-	kmem_cache_open(kmem_cache_node, "kmem_cache_node",
+	kmem_cache_open(&boot_kmem_cache_node, "kmem_cache_node",
 		sizeof(struct kmem_cache_node),
 		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
 
@@ -3722,29 +3713,21 @@
 	/* Able to allocate the per node structures */
 	slab_state = PARTIAL;
 
-	temp_kmem_cache = kmem_cache;
-	kmem_cache_open(kmem_cache, "kmem_cache", kmem_size,
+	kmem_cache_open(&boot_kmem_cache, "kmem_cache", kmem_size,
 		0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
-	kmem_cache = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
-	memcpy(kmem_cache, temp_kmem_cache, kmem_size);
+	kmem_cache = kmem_cache_alloc(&boot_kmem_cache, GFP_NOWAIT);
+	memcpy(kmem_cache, &boot_kmem_cache, kmem_size);
 
 	/*
 	 * Allocate kmem_cache_node properly from the kmem_cache slab.
 	 * kmem_cache_node is separately allocated so no need to
 	 * update any list pointers.
 	 */
-	temp_kmem_cache_node = kmem_cache_node;
-
 	kmem_cache_node = kmem_cache_alloc(kmem_cache, GFP_NOWAIT);
-	memcpy(kmem_cache_node, temp_kmem_cache_node, kmem_size);
+	memcpy(kmem_cache_node, &boot_kmem_cache_node, kmem_size);
 
 	kmem_cache_bootstrap_fixup(kmem_cache_node);
-
-	caches++;
 	kmem_cache_bootstrap_fixup(kmem_cache);
-	caches++;
-	/* Free temporary boot structure */
-	free_pages((unsigned long)temp_kmem_cache, order);
 
 	/* Now we can use the kmem_cache to allocate kmalloc slabs */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
