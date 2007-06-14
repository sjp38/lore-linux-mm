Message-Id: <20070614075335.467539848@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:32 -0700
From: clameter@sgi.com
Subject: [RFC 06/13] Memoryless nodes: SLUB support
Content-Disposition: inline; filename=nodeless_slub
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Simply switch all for_each_online_node to for_each_memory_node. That way
SLUB only operates on nodes with memory. Any allocation attempt on a
memoryless node will fall whereupon SLUB will fetch memory from a nearby
node (depending on how memory policies and cpuset describe fallback).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-13 23:23:35.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-13 23:23:59.000000000 -0700
@@ -1887,7 +1887,7 @@ static void free_kmem_cache_nodes(struct
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = s->node[node];
 		if (n && n != &s->local_node)
 			kmem_cache_free(kmalloc_caches, n);
@@ -1905,7 +1905,7 @@ static int init_kmem_cache_nodes(struct 
 	else
 		local_node = 0;
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n;
 
 		if (local_node == node)
@@ -2159,7 +2159,7 @@ static int kmem_cache_close(struct kmem_
 	flush_all(s);
 
 	/* Attempt to free all objects */
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		n->nr_partial -= free_list(s, n, &n->partial);
@@ -2406,7 +2406,7 @@ int kmem_cache_shrink(struct kmem_cache 
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		n = get_node(s, node);
 
 		if (!n->nr_partial)
@@ -2842,7 +2842,7 @@ static unsigned long validate_slab_cache
 	unsigned long count = 0;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		count += validate_slab_node(s, n);
@@ -3064,7 +3064,7 @@ static int list_locations(struct kmem_ca
 	/* Push back cpu slabs */
 	flush_all(s);
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 		unsigned long flags;
 		struct page *page;
@@ -3189,7 +3189,7 @@ static unsigned long slab_objects(struct
 		}
 	}
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		if (flags & SO_PARTIAL) {
@@ -3217,7 +3217,7 @@ static unsigned long slab_objects(struct
 
 	x = sprintf(buf, "%lu", total);
 #ifdef CONFIG_NUMA
-	for_each_online_node(node)
+	for_each_memory_node(node)
 		if (nodes[node])
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
