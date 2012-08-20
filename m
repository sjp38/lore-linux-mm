Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id B965A6B0089
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 17:01:56 -0400 (EDT)
Message-Id: <0000013945d782fa-c110727e-08c5-460d-9e84-fcf5a142993d-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 21:01:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [15/19] slab: Simplify bootstrap
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

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
---
 include/linux/slab_def.h |    2 +-
 mm/slab.c                |   18 +++++++++++++-----
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 36d7031..a2b9206 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -91,7 +91,7 @@ struct kmem_cache {
 	 * is statically defined, so we reserve the max number of cpus.
 	 */
 	struct kmem_list3 **nodelists;
-	struct array_cache *array[NR_CPUS];
+	struct array_cache *array[NR_CPUS + MAX_NUMNODES];
 	/*
 	 * Do not add fields after array[]
 	 */
diff --git a/mm/slab.c b/mm/slab.c
index 32ba049..33449a6 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -578,9 +578,7 @@ static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
 /* internal cache of cache description objs */
-static struct kmem_list3 *kmem_cache_nodelists[MAX_NUMNODES];
 static struct kmem_cache kmem_cache_boot = {
-	.nodelists = kmem_cache_nodelists,
 	.batchcount = 1,
 	.limit = BOOT_CPUCACHE_ENTRIES,
 	.shared = 1,
@@ -1572,6 +1570,15 @@ static void __init set_up_list3s(struct kmem_cache *cachep, int index)
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
@@ -1585,13 +1592,15 @@ void __init kmem_cache_init(void)
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
@@ -1631,7 +1640,6 @@ void __init kmem_cache_init(void)
 	list_add(&kmem_cache->list, &slab_caches);
 	kmem_cache->colour_off = cache_line_size();
 	kmem_cache->array[smp_processor_id()] = &initarray_cache.cache;
-	kmem_cache->nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
 
 	/*
 	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
@@ -2441,7 +2449,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	else
 		gfp = GFP_NOWAIT;
 
-	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
+	setup_nodelists_pointer(cachep);
 #if DEBUG
 
 	/*
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
