Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id CB5F16B00A2
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:47:15 -0400 (EDT)
Message-Id: <0000013abdf137c2-6ad5be2b-280c-4c89-9b7c-b7f3359b03c2-000000@email.amazonses.com>
Date: Thu, 1 Nov 2012 21:47:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK5 [05/18] slab: Use the new create_boot_cache function to simplify bootstrap
References: <20121101214538.971500204@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Simplify setup and reduce code in kmem_cache_init(). This allows us to
get rid of initarray_cache as well as the manual setup code for
the kmem_cache and kmem_cache_node arrays during bootstrap.

We introduce a new bootstrap state "PARTIAL" for slab that signals the
creation of a kmem_cache boot cache.

V1->V2: Get rid of initarray_cache as well.
V2->V3: Drop the setting of slab_state to PARTIAL [glommer]

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c |   51 ++++++++++++++++++---------------------------------
 1 file changed, 18 insertions(+), 33 deletions(-)

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-11-01 16:33:23.943008612 -0500
+++ linux/mm/slab.c	2012-11-01 16:39:57.844520127 -0500
@@ -547,8 +547,6 @@ static struct cache_names __initdata cac
 #undef CACHE
 };
 
-static struct arraycache_init initarray_cache __initdata =
-    { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
@@ -1572,12 +1570,9 @@ static void setup_nodelists_pointer(stru
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
@@ -1618,36 +1613,16 @@ void __init kmem_cache_init(void)
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
+	list_add(&kmem_cache->list, &slab_caches);
 
 	/* 2+3) create the kmalloc caches */
 	sizes = malloc_sizes;
@@ -1695,7 +1670,6 @@ void __init kmem_cache_init(void)
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
-		BUG_ON(cpu_cache_get(kmem_cache) != &initarray_cache.cache);
 		memcpy(ptr, cpu_cache_get(kmem_cache),
 		       sizeof(struct arraycache_init));
 		/*
@@ -2250,7 +2224,15 @@ static int __init_refok setup_cpu_cache(
 
 	if (slab_state == DOWN) {
 		/*
-		 * Note: the first kmem_cache_create must create the cache
+		 * Note: Creation of first cache (kmem_cache).
+		 * The setup_list3s is taken care
+		 * of by the caller of __kmem_cache_create
+		 */
+		cachep->array[smp_processor_id()] = &initarray_generic.cache;
+		slab_state = PARTIAL;
+	} else if (slab_state == PARTIAL) {
+		/*
+		 * Note: the second kmem_cache_create must create the cache
 		 * that's used by kmalloc(24), otherwise the creation of
 		 * further caches will BUG().
 		 */
@@ -2258,7 +2240,7 @@ static int __init_refok setup_cpu_cache(
 
 		/*
 		 * If the cache that's used by kmalloc(sizeof(kmem_list3)) is
-		 * the first cache, then we need to set up all its list3s,
+		 * the second cache, then we need to set up all its list3s,
 		 * otherwise the creation of further caches will BUG().
 		 */
 		set_up_list3s(cachep, SIZE_AC);
@@ -2267,6 +2249,7 @@ static int __init_refok setup_cpu_cache(
 		else
 			slab_state = PARTIAL_ARRAYCACHE;
 	} else {
+		/* Remaining boot caches */
 		cachep->array[smp_processor_id()] =
 			kmalloc(sizeof(struct arraycache_init), gfp);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
