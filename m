Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 00E456B0068
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:18:14 -0400 (EDT)
Message-Id: <0000013a043aca11-926da326-bd96-42b0-8d69-92ce9833912b-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:18:12 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [04/13] slab: Use the new create_boot_cache function to simplify bootstrap
References: <20120926200005.911809821@linux.com>
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

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-19 09:21:14.422971030 -0500
+++ linux/mm/slab.c	2012-09-19 09:21:21.399115971 -0500
@@ -572,8 +572,6 @@ static struct cache_names __initdata cac
 #undef CACHE
 };
 
-static struct arraycache_init initarray_cache __initdata =
-    { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
@@ -1596,12 +1594,9 @@ static void setup_nodelists_pointer(stru
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
@@ -1645,36 +1640,17 @@ void __init kmem_cache_init(void)
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
@@ -1722,7 +1698,6 @@ void __init kmem_cache_init(void)
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
 
-		BUG_ON(cpu_cache_get(kmem_cache) != &initarray_cache.cache);
 		memcpy(ptr, cpu_cache_get(kmem_cache),
 		       sizeof(struct arraycache_init));
 		/*
@@ -2277,7 +2252,16 @@ static int __init_refok setup_cpu_cache(
 
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
@@ -2285,7 +2269,7 @@ static int __init_refok setup_cpu_cache(
 
 		/*
 		 * If the cache that's used by kmalloc(sizeof(kmem_list3)) is
-		 * the first cache, then we need to set up all its list3s,
+		 * the second cache, then we need to set up all its list3s,
 		 * otherwise the creation of further caches will BUG().
 		 */
 		set_up_list3s(cachep, SIZE_AC);
@@ -2294,6 +2278,7 @@ static int __init_refok setup_cpu_cache(
 		else
 			slab_state = PARTIAL_ARRAYCACHE;
 	} else {
+		/* Remaining boot caches */
 		cachep->array[smp_processor_id()] =
 			kmalloc(sizeof(struct arraycache_init), gfp);
 
@@ -2389,22 +2374,6 @@ __kmem_cache_create (struct kmem_cache *
 		size &= ~(BYTES_PER_WORD - 1);
 	}
 
-	/* calculate the final buffer alignment: */
-
-	/* 1) arch recommendation: can be overridden for debug */
-	if (flags & SLAB_HWCACHE_ALIGN) {
-		/*
-		 * Default alignment: as specified by the arch code.  Except if
-		 * an object is really small, then squeeze multiple objects into
-		 * one cacheline.
-		 */
-		ralign = cache_line_size();
-		while (size <= ralign / 2)
-			ralign /= 2;
-	} else {
-		ralign = BYTES_PER_WORD;
-	}
-
 	/*
 	 * Redzoning and user store require word alignment or possibly larger.
 	 * Note this will be overridden by architecture or caller mandated
@@ -2421,10 +2390,6 @@ __kmem_cache_create (struct kmem_cache *
 		size &= ~(REDZONE_ALIGN - 1);
 	}
 
-	/* 2) arch mandated alignment */
-	if (ralign < ARCH_SLAB_MINALIGN) {
-		ralign = ARCH_SLAB_MINALIGN;
-	}
 	/* 3) caller mandated alignment */
 	if (ralign < cachep->align) {
 		ralign = cachep->align;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
