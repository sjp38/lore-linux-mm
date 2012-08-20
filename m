Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id CF9AA6B0092
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 17:01:57 -0400 (EDT)
Message-Id: <0000013945d78378-c0d5b879-5e97-4af5-b988-e534d98289aa-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 21:01:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [18/19] slab: Use the new create_boot_cache function to simplify bootstrap
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Simplify setup and reduce code in kmem_cache_init(). This allows us to
get rid of initarray_cache as well as the manual setup code for
the kmem_cache and kmem_cache_node arrays during bootstrap.

We introduce a new bootstrap state "PARTIAL" for slab that signals the
creation of a kmem_cache boot cache.

V1->V2: Get rid of initarray_cache as well.

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c |   51 ++++++++++++++++++---------------------------------
 1 file changed, 18 insertions(+), 33 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4d88b39..0612c54 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -572,8 +572,6 @@ static struct cache_names __initdata cache_names[] = {
 #undef CACHE
 };
 
-static struct arraycache_init initarray_cache __initdata =
-    { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
@@ -1584,12 +1582,9 @@ static void setup_nodelists_pointer(struct kmem_cache *s)
  */
 void __init kmem_cache_init(void)
 {
-	size_t left_over;
 	struct cache_sizes *sizes;
 	struct cache_names *names;
 	int i;
-	int order;
-	int node;
 
 	kmem_cache = &kmem_cache_boot;
 	setup_nodelists_pointer(kmem_cache);
@@ -1633,36 +1628,17 @@ void __init kmem_cache_init(void)
 	 * 6) Resize the head arrays of the kmalloc caches to their final sizes.
 	 */
 
-	node = numa_mem_id();
-
 	/* 1) create the kmem_cache */
-	INIT_LIST_HEAD(&slab_caches);
-	list_add(&kmem_cache->list, &slab_caches);
-	kmem_cache->colour_off = cache_line_size();
-	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
 
 	/*
 	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
 	 */
-	kmem_cache->size = offsetof(struct kmem_cache, array[nr_cpu_ids]) +
-				  nr_node_ids * sizeof(struct kmem_list3 *);
-	kmem_cache->object_size = kmem_cache->size;
-	kmem_cache->size = ALIGN(kmem_cache->object_size,
-					cache_line_size());
-	kmem_cache->reciprocal_buffer_size =
-		reciprocal_value(kmem_cache->size);
-
-	for (order = 0; order < MAX_ORDER; order++) {
-		cache_estimate(order, kmem_cache->size,
-			cache_line_size(), 0, &left_over, &kmem_cache->num);
-		if (kmem_cache->num)
-			break;
-	}
-	BUG_ON(!kmem_cache->num);
-	kmem_cache->gfporder = order;
-	kmem_cache->colour = left_over / kmem_cache->colour_off;
-	kmem_cache->slab_size = ALIGN(kmem_cache->num * sizeof(kmem_bufctl_t) +
-				      sizeof(struct slab), cache_line_size());
+	create_boot_cache(kmem_cache, "kmem_cache",
+		offsetof(struct kmem_cache, array[nr_cpu_ids]) +
+				  nr_node_ids * sizeof(struct kmem_list3 *),
+				  SLAB_HWCACHE_ALIGN);
+
+	slab_state = PARTIAL;
 
 	/* 2+3) create the kmalloc caches */
 	sizes = malloc_sizes;
@@ -1710,7 +1686,6 @@ void __init kmem_cache_init(void)
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
-		BUG_ON(cpu_cache_get(kmem_cache) != &initarray_cache.cache);
 		memcpy(ptr, cpu_cache_get(kmem_cache),
 		       sizeof(struct arraycache_init));
 		/*
@@ -2265,7 +2240,16 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 
 	if (slab_state == DOWN) {
 		/*
-		 * Note: the first kmem_cache_create must create the cache
+		 * Note: Creation of first cache (kmem_cache).
+		 * The setup_list3s is taken care
+		 * of by the caller of __kmem_cache_create
+		 */
+		cachep->array[smp_processor_id()] = &initarray_generic.cache;
+		slab_state = PARTIAL;
+	} else
+	if (slab_state == PARTIAL) {
+		/*
+		 * Note: the second kmem_cache_create must create the cache
 		 * that's used by kmalloc(24), otherwise the creation of
 		 * further caches will BUG().
 		 */
@@ -2273,7 +2257,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 
 		/*
 		 * If the cache that's used by kmalloc(sizeof(kmem_list3)) is
-		 * the first cache, then we need to set up all its list3s,
+		 * the second cache, then we need to set up all its list3s,
 		 * otherwise the creation of further caches will BUG().
 		 */
 		set_up_list3s(cachep, SIZE_AC);
@@ -2282,6 +2266,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 		else
 			slab_state = PARTIAL_ARRAYCACHE;
 	} else {
+		/* Remaining boot caches */
 		cachep->array[smp_processor_id()] =
 			kmalloc(sizeof(struct arraycache_init), gfp);
 
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
