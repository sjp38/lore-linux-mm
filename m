Message-Id: <20070618192545.764710140@sgi.com>
References: <20070618191956.411091458@sgi.com>
Date: Mon, 18 Jun 2007 12:20:03 -0700
From: clameter@sgi.com
Subject: [patch 07/10] Memoryless nodes: SLUB support
Content-Disposition: inline; filename=memless_slub
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Simply switch all for_each_online_node to for_each_memory_node. That way
SLUB only operates on nodes with memory. Any allocation attempt on a
memoryless node will fall whereupon SLUB will fetch memory from a nearby
node (depending on how memory policies and cpuset describe fallback).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-18 11:16:15.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-18 11:28:50.000000000 -0700
@@ -2086,7 +2086,7 @@ static void free_kmem_cache_nodes(struct
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = s->node[node];
 		if (n && n != &s->local_node)
 			kmem_cache_free(kmalloc_caches, n);
@@ -2104,7 +2104,7 @@ static int init_kmem_cache_nodes(struct 
 	else
 		local_node = 0;
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n;
 
 		if (local_node == node)
@@ -2366,7 +2366,7 @@ static inline int kmem_cache_close(struc
 	/* Attempt to free all objects */
 	free_kmem_cache_cpus(s);
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		n->nr_partial -= free_list(s, n, &n->partial);
@@ -2937,7 +2937,7 @@ int kmem_cache_shrink(struct kmem_cache 
 	if (!scratch)
 		return -ENOMEM;
 
-	for_each_online_node(node)
+	for_each_memory_node(node)
 		__kmem_cache_shrink(s, get_node(s, node), scratch);
 
 	kfree(scratch);
@@ -3008,7 +3008,7 @@ int kmem_cache_defrag(int percent, int n
 		scratch = kmalloc(sizeof(struct list_head) * s->objects,
 								GFP_KERNEL);
 		if (node == -1) {
-			for_each_online_node(node)
+			for_each_memory_node(node)
 				pages += __kmem_cache_defrag(s, percent,
 							node, scratch);
 		} else
@@ -3392,7 +3392,7 @@ static unsigned long validate_slab_cache
 	unsigned long count = 0;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		count += validate_slab_node(s, n);
@@ -3611,7 +3611,7 @@ static int list_locations(struct kmem_ca
 	/* Push back cpu slabs */
 	flush_all(s);
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 		unsigned long flags;
 		struct page *page;
@@ -3723,7 +3723,7 @@ static unsigned long slab_objects(struct
 		}
 	}
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		if (flags & SO_PARTIAL) {
@@ -3751,7 +3751,7 @@ static unsigned long slab_objects(struct
 
 	x = sprintf(buf, "%lu", total);
 #ifdef CONFIG_NUMA
-	for_each_online_node(node)
+	for_each_memory_node(node)
 		if (nodes[node])
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);
@@ -3772,7 +3772,7 @@ static int any_slab_objects(struct kmem_
 			return 1;
 	}
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		if (n && (n->nr_partial || atomic_read(&n->nr_slabs)))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
