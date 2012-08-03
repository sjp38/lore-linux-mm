Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 6E0C56B0087
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 15:21:59 -0400 (EDT)
Message-Id: <20120803192157.697774094@linux.com>
Date: Fri, 03 Aug 2012 14:21:09 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common10 [17/20] slab: Simplify bootstrap
References: <20120803192052.448575403@linux.com>
Content-Disposition: inline; filename=setup_nodelists
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

The nodelists field in kmem_cache is pointing to the first unused
object in the array field when bootstrap is complete.

On boot we use a statically allocated array for that purpose.

A problem with the current approach is that the statically sized
kmem_cache structure can only contain NR_CPUS entries. If the number
of nodes plus the number of cpus is greater then we would overwrite
memory following the kmem_cache_boot definition.

Increase the size of the array field to ensure that also the node
pointers fit into the array field.

Once we do that we no longer need the kmem_cache_nodelists
array and we can then also simplify bootstrap.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/include/linux/slab_def.h
===================================================================
--- linux-2.6.orig/include/linux/slab_def.h	2012-08-03 13:17:27.000000000 -0500
+++ linux-2.6/include/linux/slab_def.h	2012-08-03 13:48:01.257871286 -0500
@@ -92,7 +92,7 @@ struct kmem_cache {
 	 * is statically defined, so we reserve the max number of cpus.
 	 */
 	struct kmem_list3 **nodelists;
-	struct array_cache *array[NR_CPUS];
+	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
 	/*
 	 * Do not add fields after array[]
 	 */
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-03 13:46:46.000000000 -0500
+++ linux-2.6/mm/slab.c	2012-08-03 13:48:25.122303959 -0500
@@ -585,9 +585,7 @@ static struct arraycache_init initarray_
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
 /* internal cache of cache description objs */
-static struct kmem_list3 *kmem_cache_nodelists[MAX_NUMNODES];
 static struct kmem_cache kmem_cache_boot = {
-	.nodelists = kmem_cache_nodelists,
 	.batchcount = 1,
 	.limit = BOOT_CPUCACHE_ENTRIES,
 	.shared = 1,
@@ -1579,6 +1577,15 @@ static void __init set_up_list3s(struct
 }
 
 /*
+ * The memory after the last cpu cache pointer is used for the
+ * the nodelists pointer.
+ */
+static void setup_nodelists_pointer(struct kmem_cache *s)
+{
+	s->nodelists = (struct kmem_list3 **)&s->array[nr_cpu_ids];
+}
+
+/*
  * Initialisation.  Called after the page allocator have been initialised and
  * before smp_init().
  */
@@ -1592,13 +1599,15 @@ void __init kmem_cache_init(void)
 	int node;
 
 	kmem_cache = &kmem_cache_boot;
+	setup_nodelists_pointer(kmem_cache);
 
 	if (num_possible_nodes() == 1)
 		use_alien_caches = 0;
 
+
 	for (i = 0; i < NUM_INIT_LISTS; i++) {
 		kmem_list3_init(&initkmem_list3[i]);
-		if (i < MAX_NUMNODES)
+		if (i < nr_node_ids)
 			kmem_cache->nodelists[i] = NULL;
 	}
 	set_up_list3s(kmem_cache, CACHE_CACHE);
@@ -1638,7 +1647,6 @@ void __init kmem_cache_init(void)
 	list_add(&kmem_cache->list, &slab_caches);
 	kmem_cache->colour_off = cache_line_size();
 	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
-	kmem_cache->nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
 
 	/*
 	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
@@ -2451,7 +2459,7 @@ __kmem_cache_create (struct kmem_cache *
 	else
 		gfp = GFP_NOWAIT;
 
-	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
+	setup_nodelists_pointer(cachep);
 #if DEBUG
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
