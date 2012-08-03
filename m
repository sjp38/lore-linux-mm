Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 8DB016B0089
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 15:22:00 -0400 (EDT)
Message-Id: <20120803192158.861046713@linux.com>
Date: Fri, 03 Aug 2012 14:21:11 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common10 [19/20] slab: Use the new create_boot_cache function to simplify bootstrap
References: <20120803192052.448575403@linux.com>
Content-Disposition: inline; filename=slab_use_boot_cache
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Simplify setup and reduce code in kmem_cache_init().

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-03 13:53:12.000000000 -0500
+++ linux-2.6/mm/slab.c	2012-08-03 13:58:36.725354998 -0500
@@ -1591,11 +1591,9 @@ static void setup_nodelists_pointer(stru
  */
 void __init kmem_cache_init(void)
 {
-	size_t left_over;
 	struct cache_sizes *sizes;
 	struct cache_names *names;
 	int i;
-	int order;
 	int node;
 
 	kmem_cache = &kmem_cache_boot;
@@ -1643,33 +1641,18 @@ void __init kmem_cache_init(void)
 	node = numa_mem_id();
 
 	/* 1) create the kmem_cache */
-	INIT_LIST_HEAD(&slab_caches);
-	list_add(&kmem_cache->list, &slab_caches);
 	kmem_cache->colour_off = cache_line_size();
 	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
 
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
@@ -2270,7 +2253,7 @@ static int __init_refok setup_cpu_cache(
 	if (slab_state >= FULL)
 		return enable_cpucache(cachep, gfp);
 
-	if (slab_state == DOWN) {
+	if (slab_state == PARTIAL) {
 		/*
 		 * Note: the first kmem_cache_create must create the cache
 		 * that's used by kmalloc(24), otherwise the creation of
@@ -2542,10 +2525,13 @@ __kmem_cache_create (struct kmem_cache *
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
 
-	err = setup_cpu_cache(cachep, gfp);
-	if (err) {
-		__kmem_cache_shutdown(cachep);
-		return err;
+	/* During early boot the cpu cache are setup by the caller */
+	if (slab_state != DOWN) {
+		err = setup_cpu_cache(cachep, gfp);
+		if (err) {
+			__kmem_cache_shutdown(cachep);
+			return err;
+		}
 	}
 
 	if (flags & SLAB_DEBUG_OBJECTS) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
