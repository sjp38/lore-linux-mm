Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 8909D6B007B
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 16:50:40 -0400 (EDT)
Message-Id: <0000013945cd2c57-290b81c0-45b1-4893-9176-1347b33af921-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 20:50:37 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [06/19] Always use the name "kmem_cache" for the slab cache
 with the kmem_cache structure.
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Make all allocators use the "kmem_cache" slabname for the "kmem_cache" structure.

Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |   72 ++++++++++++++++++++++++++++--------------------------
 mm/slab.h        |    6 +++++
 mm/slab_common.c |    1 +
 mm/slob.c        |    8 ++++++
 mm/slub.c        |    2 --
 5 files changed, 52 insertions(+), 37 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 6826d93..6365632 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -578,9 +578,9 @@ static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
 /* internal cache of cache description objs */
-static struct kmem_list3 *cache_cache_nodelists[MAX_NUMNODES];
-static struct kmem_cache cache_cache = {
-	.nodelists = cache_cache_nodelists,
+static struct kmem_list3 *kmem_cache_nodelists[MAX_NUMNODES];
+static struct kmem_cache kmem_cache_boot = {
+	.nodelists = kmem_cache_nodelists,
 	.batchcount = 1,
 	.limit = BOOT_CPUCACHE_ENTRIES,
 	.shared = 1,
@@ -1584,15 +1584,17 @@ void __init kmem_cache_init(void)
 	int order;
 	int node;
 
+	kmem_cache = &kmem_cache_boot;
+
 	if (num_possible_nodes() == 1)
 		use_alien_caches = 0;
 
 	for (i = 0; i < NUM_INIT_LISTS; i++) {
 		kmem_list3_init(&initkmem_list3[i]);
 		if (i < MAX_NUMNODES)
-			cache_cache.nodelists[i] = NULL;
+			kmem_cache->nodelists[i] = NULL;
 	}
-	set_up_list3s(&cache_cache, CACHE_CACHE);
+	set_up_list3s(kmem_cache, CACHE_CACHE);
 
 	/*
 	 * Fragmentation resistance on low memory - only use bigger
@@ -1604,9 +1606,9 @@ void __init kmem_cache_init(void)
 
 	/* Bootstrap is tricky, because several objects are allocated
 	 * from caches that do not exist yet:
-	 * 1) initialize the cache_cache cache: it contains the struct
-	 *    kmem_cache structures of all caches, except cache_cache itself:
-	 *    cache_cache is statically allocated.
+	 * 1) initialize the kmem_cache cache: it contains the struct
+	 *    kmem_cache structures of all caches, except kmem_cache itself:
+	 *    kmem_cache is statically allocated.
 	 *    Initially an __init data area is used for the head array and the
 	 *    kmem_list3 structures, it's replaced with a kmalloc allocated
 	 *    array at the end of the bootstrap.
@@ -1615,43 +1617,43 @@ void __init kmem_cache_init(void)
 	 *    An __init data area is used for the head array.
 	 * 3) Create the remaining kmalloc caches, with minimally sized
 	 *    head arrays.
-	 * 4) Replace the __init data head arrays for cache_cache and the first
+	 * 4) Replace the __init data head arrays for kmem_cache and the first
 	 *    kmalloc cache with kmalloc allocated arrays.
-	 * 5) Replace the __init data for kmem_list3 for cache_cache and
+	 * 5) Replace the __init data for kmem_list3 for kmem_cache and
 	 *    the other cache's with kmalloc allocated memory.
 	 * 6) Resize the head arrays of the kmalloc caches to their final sizes.
 	 */
 
 	node = numa_mem_id();
 
-	/* 1) create the cache_cache */
+	/* 1) create the kmem_cache */
 	INIT_LIST_HEAD(&slab_caches);
-	list_add(&cache_cache.list, &slab_caches);
-	cache_cache.colour_off = cache_line_size();
-	cache_cache.array[smp_processor_id()] = &initarray_cache.cache;
-	cache_cache.nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
+	list_add(&kmem_cache->list, &slab_caches);
+	kmem_cache->colour_off = cache_line_size();
+	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
+	kmem_cache->nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
 
 	/*
 	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
 	 */
-	cache_cache.size = offsetof(struct kmem_cache, array[nr_cpu_ids]) +
+	kmem_cache->size = offsetof(struct kmem_cache, array[nr_cpu_ids]) +
 				  nr_node_ids * sizeof(struct kmem_list3 *);
-	cache_cache.object_size = cache_cache.size;
-	cache_cache.size = ALIGN(cache_cache.size,
+	kmem_cache->object_size = kmem_cache->size;
+	kmem_cache->size = ALIGN(kmem_cache->object_size,
 					cache_line_size());
-	cache_cache.reciprocal_buffer_size =
-		reciprocal_value(cache_cache.size);
+	kmem_cache->reciprocal_buffer_size =
+		reciprocal_value(kmem_cache->size);
 
 	for (order = 0; order < MAX_ORDER; order++) {
-		cache_estimate(order, cache_cache.size,
-			cache_line_size(), 0, &left_over, &cache_cache.num);
-		if (cache_cache.num)
+		cache_estimate(order, kmem_cache->size,
+			cache_line_size(), 0, &left_over, &kmem_cache->num);
+		if (kmem_cache->num)
 			break;
 	}
-	BUG_ON(!cache_cache.num);
-	cache_cache.gfporder = order;
-	cache_cache.colour = left_over / cache_cache.colour_off;
-	cache_cache.slab_size = ALIGN(cache_cache.num * sizeof(kmem_bufctl_t) +
+	BUG_ON(!kmem_cache->num);
+	kmem_cache->gfporder = order;
+	kmem_cache->colour = left_over / kmem_cache->colour_off;
+	kmem_cache->slab_size = ALIGN(kmem_cache->num * sizeof(kmem_bufctl_t) +
 				      sizeof(struct slab), cache_line_size());
 
 	/* 2+3) create the kmalloc caches */
@@ -1718,15 +1720,15 @@ void __init kmem_cache_init(void)
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
-		BUG_ON(cpu_cache_get(&cache_cache) != &initarray_cache.cache);
-		memcpy(ptr, cpu_cache_get(&cache_cache),
+		BUG_ON(cpu_cache_get(kmem_cache) != &initarray_cache.cache);
+		memcpy(ptr, cpu_cache_get(kmem_cache),
 		       sizeof(struct arraycache_init));
 		/*
 		 * Do not assume that spinlocks can be initialized via memcpy:
 		 */
 		spin_lock_init(&ptr->lock);
 
-		cache_cache.array[smp_processor_id()] = ptr;
+		kmem_cache->array[smp_processor_id()] = ptr;
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
@@ -1747,7 +1749,7 @@ void __init kmem_cache_init(void)
 		int nid;
 
 		for_each_online_node(nid) {
-			init_list(&cache_cache, &initkmem_list3[CACHE_CACHE + nid], nid);
+			init_list(kmem_cache, &initkmem_list3[CACHE_CACHE + nid], nid);
 
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
 				  &initkmem_list3[SIZE_AC + nid], nid);
@@ -2213,7 +2215,7 @@ void __kmem_cache_destroy(struct kmem_cache *cachep)
 			kfree(l3);
 		}
 	}
-	kmem_cache_free(&cache_cache, cachep);
+	kmem_cache_free(kmem_cache, cachep);
 }
 
 
@@ -2463,7 +2465,7 @@ __kmem_cache_create (const char *name, size_t size, size_t align,
 		gfp = GFP_NOWAIT;
 
 	/* Get cache's description obj. */
-	cachep = kmem_cache_zalloc(&cache_cache, gfp);
+	cachep = kmem_cache_zalloc(kmem_cache, gfp);
 	if (!cachep)
 		return NULL;
 
@@ -2521,7 +2523,7 @@ __kmem_cache_create (const char *name, size_t size, size_t align,
 	if (!cachep->num) {
 		printk(KERN_ERR
 		       "kmem_cache_create: couldn't create cache %s.\n", name);
-		kmem_cache_free(&cache_cache, cachep);
+		kmem_cache_free(kmem_cache, cachep);
 		return NULL;
 	}
 	slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
@@ -3289,7 +3291,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 
 static bool slab_should_failslab(struct kmem_cache *cachep, gfp_t flags)
 {
-	if (cachep == &cache_cache)
+	if (cachep == kmem_cache)
 		return false;
 
 	return should_failslab(cachep->object_size, flags, cachep->flags);
diff --git a/mm/slab.h b/mm/slab.h
index 07a537e..6724aa6 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -25,8 +25,14 @@ extern enum slab_state slab_state;
 
 /* The slab cache mutex protects the management structures during changes */
 extern struct mutex slab_mutex;
+
+/* The list of all slab caches on the system */
 extern struct list_head slab_caches;
 
+/* The slab cache that manages slab cache information */
+extern struct kmem_cache *kmem_cache;
+
+/* Functions provided by the slab allocators */
 struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags, void (*ctor)(void *));
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 5cc1371..850c497 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -22,6 +22,7 @@
 enum slab_state slab_state;
 LIST_HEAD(slab_caches);
 DEFINE_MUTEX(slab_mutex);
+struct kmem_cache *kmem_cache;
 
 #ifdef CONFIG_DEBUG_VM
 static int kmem_cache_sanity_check(const char *name, size_t size)
diff --git a/mm/slob.c b/mm/slob.c
index 289be4f..7d272c3 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -622,8 +622,16 @@ int kmem_cache_shrink(struct kmem_cache *d)
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+struct kmem_cache kmem_cache_boot = {
+	.name = "kmem_cache",
+	.size = sizeof(struct kmem_cache),
+	.flags = SLAB_PANIC,
+	.align = ARCH_KMALLOC_MINALIGN,
+};
+
 void __init kmem_cache_init(void)
 {
+	kmem_cache = &kmem_cache_boot;
 	slab_state = UP;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index c99c0af..607fee5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3221,8 +3221,6 @@ void __kmem_cache_destroy(struct kmem_cache *s)
 struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
 EXPORT_SYMBOL(kmalloc_caches);
 
-static struct kmem_cache *kmem_cache;
-
 #ifdef CONFIG_ZONE_DMA
 static struct kmem_cache *kmalloc_dma_caches[SLUB_PAGE_SHIFT];
 #endif
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
