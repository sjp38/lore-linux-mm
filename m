Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D1DF16B01EE
	for <linux-mm@kvack.org>; Fri, 14 May 2010 19:59:00 -0400 (EDT)
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id o4ENwqXV013694
	for <linux-mm@kvack.org>; Fri, 14 May 2010 16:58:53 -0700
From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH] slub: move kmem_cache_node into it's own cacheline
Date: Fri, 14 May 2010 16:58:52 -0700
Message-ID: <20100514235852.13665.54331.stgit@gitlad.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is meant to improve the performance of SLUB by moving the local
kmem_cache_node lock into it's own cacheline separate from kmem_cache.
This is accomplished by simply removing the local_node when NUMA is enabled.

On my system with 2 nodes I saw around a 5% performance increase w/
hackbench times dropping from 6.2 seconds to 5.9 seconds on average.  I
suspect the performance gain would increase as the number of nodes
increases, but I do not have the data to currently back that up.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/slub_def.h |   11 ++++-------
 mm/slub.c                |   33 +++++++++++----------------------
 2 files changed, 15 insertions(+), 29 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 0249d41..e6217bb 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -52,7 +52,7 @@ struct kmem_cache_node {
 	atomic_long_t total_objects;
 	struct list_head full;
 #endif
-};
+} ____cacheline_internodealigned_in_smp;
 
 /*
  * Word size structure that can be atomically updated or read and that
@@ -75,12 +75,6 @@ struct kmem_cache {
 	int offset;		/* Free pointer offset. */
 	struct kmem_cache_order_objects oo;
 
-	/*
-	 * Avoid an extra cache line for UP, SMP and for the node local to
-	 * struct kmem_cache.
-	 */
-	struct kmem_cache_node local_node;
-
 	/* Allocation and freeing of slabs */
 	struct kmem_cache_order_objects max;
 	struct kmem_cache_order_objects min;
@@ -102,6 +96,9 @@ struct kmem_cache {
 	 */
 	int remote_node_defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
+#else
+	/* Avoid an extra cache line for UP */
+	struct kmem_cache_node local_node;
 #endif
 };
 
diff --git a/mm/slub.c b/mm/slub.c
index d2a54fe..6cf6be7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2141,7 +2141,7 @@ static void free_kmem_cache_nodes(struct kmem_cache *s)
 
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = s->node[node];
-		if (n && n != &s->local_node)
+		if (n)
 			kmem_cache_free(kmalloc_caches, n);
 		s->node[node] = NULL;
 	}
@@ -2150,33 +2150,22 @@ static void free_kmem_cache_nodes(struct kmem_cache *s)
 static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
 {
 	int node;
-	int local_node;
-
-	if (slab_state >= UP && (s < kmalloc_caches ||
-			s >= kmalloc_caches + KMALLOC_CACHES))
-		local_node = page_to_nid(virt_to_page(s));
-	else
-		local_node = 0;
 
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n;
 
-		if (local_node == node)
-			n = &s->local_node;
-		else {
-			if (slab_state == DOWN) {
-				early_kmem_cache_node_alloc(gfpflags, node);
-				continue;
-			}
-			n = kmem_cache_alloc_node(kmalloc_caches,
-							gfpflags, node);
-
-			if (!n) {
-				free_kmem_cache_nodes(s);
-				return 0;
-			}
+		if (slab_state == DOWN) {
+			early_kmem_cache_node_alloc(gfpflags, node);
+			continue;
+		}
+		n = kmem_cache_alloc_node(kmalloc_caches,
+						gfpflags, node);
 
+		if (!n) {
+			free_kmem_cache_nodes(s);
+			return 0;
 		}
+
 		s->node[node] = n;
 		init_kmem_cache_node(n, s);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
