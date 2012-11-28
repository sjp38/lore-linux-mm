Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id BDD046B0074
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:23:02 -0500 (EST)
Message-Id: <0000013b47d41854-7d7d63f2-13f4-4212-86ed-94d6156033bf-000000@email.amazonses.com>
Date: Wed, 28 Nov 2012 16:23:01 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK5 [2/6] slab: Simplify bootstrap
References: <20121128162238.111670741@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

The nodelists field in kmem_cache is pointing to the first unused
object in the array field when bootstrap is complete.

A problem with the current approach is that the statically sized
kmem_cache structure use on boot can only contain NR_CPUS entries.
If the number of nodes plus the number of cpus is greater then we
would overwrite memory following the kmem_cache_boot definition.

Increase the size of the array field to ensure that also the node
pointers fit into the array field.

Once we do that we no longer need the kmem_cache_nodelists
array and we can then also use that structure elsewhere.

V1->V2:
	- No need to zap kmem_cache->nodelists since it is allocated
		with kmem_cache_zalloc() [glommer]

Acked-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 include/linux/slab_def.h |    2 +-
 mm/slab.c                |   18 +++++++++++++-----
 2 files changed, 14 insertions(+), 6 deletions(-)

Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2012-11-15 15:26:24.940949492 -0600
+++ linux/include/linux/slab_def.h	2012-11-28 09:18:26.219105161 -0600
@@ -89,9 +89,13 @@ struct kmem_cache {
 	 * (see kmem_cache_init())
 	 * We still use [NR_CPUS] and not [1] or [0] because cache_cache
 	 * is statically defined, so we reserve the max number of cpus.
+	 *
+	 * We also need to guarantee that the list is able to accomodate a
+	 * pointer for each node since "nodelists" uses the remainder of
+	 * available pointers.
 	 */
 	struct kmem_list3 **nodelists;
-	struct array_cache *array[NR_CPUS];
+	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
 	/*
 	 * Do not add fields after array[]
 	 */
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-11-28 09:17:22.110761578 -0600
+++ linux/mm/slab.c	2012-11-28 09:18:26.219105161 -0600
@@ -553,9 +553,7 @@ static struct arraycache_init initarray_
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
 /* internal cache of cache description objs */
-static struct kmem_list3 *kmem_cache_nodelists[MAX_NUMNODES];
 static struct kmem_cache kmem_cache_boot = {
-	.nodelists = kmem_cache_nodelists,
 	.batchcount = 1,
 	.limit = BOOT_CPUCACHE_ENTRIES,
 	.shared = 1,
@@ -1560,6 +1558,15 @@ static void __init set_up_list3s(struct
 }
 
 /*
+ * The memory after the last cpu cache pointer is used for the
+ * the nodelists pointer.
+ */
+static void setup_nodelists_pointer(struct kmem_cache *cachep)
+{
+	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
+}
+
+/*
  * Initialisation.  Called after the page allocator have been initialised and
  * before smp_init().
  */
@@ -1573,15 +1580,14 @@ void __init kmem_cache_init(void)
 	int node;
 
 	kmem_cache = &kmem_cache_boot;
+	setup_nodelists_pointer(kmem_cache);
 
 	if (num_possible_nodes() == 1)
 		use_alien_caches = 0;
 
-	for (i = 0; i < NUM_INIT_LISTS; i++) {
+	for (i = 0; i < NUM_INIT_LISTS; i++)
 		kmem_list3_init(&initkmem_list3[i]);
-		if (i < MAX_NUMNODES)
-			kmem_cache->nodelists[i] = NULL;
-	}
+
 	set_up_list3s(kmem_cache, CACHE_CACHE);
 
 	/*
@@ -1619,7 +1625,6 @@ void __init kmem_cache_init(void)
 	list_add(&kmem_cache->list, &slab_caches);
 	kmem_cache->colour_off = cache_line_size();
 	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
-	kmem_cache->nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
 
 	/*
 	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
@@ -2422,7 +2427,7 @@ __kmem_cache_create (struct kmem_cache *
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
