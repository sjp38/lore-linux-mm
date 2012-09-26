Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id B28EC6B006E
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:20:30 -0400 (EDT)
Message-Id: <0000013a043cda28-b1405dff-7a18-49fc-93bf-4d418fbdd918-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:20:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [03/13] slub: Use a statically allocated kmem_cache boot structure for bootstrap
References: <20120926200005.911809821@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Simplify bootstrap by statically allocated two kmem_cache structures. These are
freed after bootup is complete. Allows us to no longer worry about calculations
of sizes of kmem_cache structures during bootstrap.

V1->V2: Do not unlock mutexes that are not taken during early boot.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   41 +++++++++++------------------------------
 1 file changed, 11 insertions(+), 30 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-19 09:21:14.422971030 -0500
+++ linux/mm/slub.c	2012-09-19 09:21:18.403053765 -0500
@@ -3649,9 +3649,6 @@ static void __init kmem_cache_bootstrap_
 {
 	int node;
 
-	list_add(&s->list, &slab_caches);
-	s->refcount = -1;
-
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 		struct page *p;
@@ -3668,14 +3665,13 @@ static void __init kmem_cache_bootstrap_
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
-	unsigned long kmalloc_size;
+	int caches = 2;
 
 	if (debug_guardpage_minorder())
 		slub_max_order = 0;
@@ -3683,53 +3679,32 @@ void __init kmem_cache_init(void)
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
+	kmem_cache_node = &boot_kmem_cache_node;
 
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
+	create_boot_cache(&boot_kmem_cache, "kmem_cache", kmem_size,
+		       SLAB_HWCACHE_ALIGN);
 
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
 
@@ -3930,6 +3905,10 @@ int __kmem_cache_create(struct kmem_cach
 	if (err)
 		return err;
 
+	/* Mutex is not taken during early boot */
+	if (slab_state <= UP)
+		return 0;
+
 	mutex_unlock(&slab_mutex);
 	err = sysfs_slab_add(s);
 	mutex_lock(&slab_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
