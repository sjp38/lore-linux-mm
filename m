From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:44:01 -0400
Message-Id: <20070727194401.18614.15154.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 07/14] Memoryless nodes: SLUB support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 07/14] Memoryless nodes: SLUB support

Memoryless nodes: SLUB support

Simply switch all for_each_online_node to for_each_memory_node. That way
SLUB only operates on nodes with memory. Any allocation attempt on a
memoryless node will fall whereupon SLUB will fetch memory from a nearby
node (depending on how memory policies and cpuset describe fallback).

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 mm/slub.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

Index: Linux/mm/slub.c
===================================================================
--- Linux.orig/mm/slub.c	2007-07-25 09:29:50.000000000 -0400
+++ Linux/mm/slub.c	2007-07-25 11:37:28.000000000 -0400
@@ -1918,7 +1918,7 @@ static void free_kmem_cache_nodes(struct
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = s->node[node];
 		if (n && n != &s->local_node)
 			kmem_cache_free(kmalloc_caches, n);
@@ -1936,7 +1936,7 @@ static int init_kmem_cache_nodes(struct 
 	else
 		local_node = 0;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n;
 
 		if (local_node == node)
@@ -2189,7 +2189,7 @@ static inline int kmem_cache_close(struc
 	flush_all(s);
 
 	/* Attempt to free all objects */
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		n->nr_partial -= free_list(s, n, &n->partial);
@@ -2484,7 +2484,7 @@ int kmem_cache_shrink(struct kmem_cache 
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		n = get_node(s, node);
 
 		if (!n->nr_partial)
@@ -2884,7 +2884,7 @@ static long validate_slab_cache(struct k
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		count += validate_slab_node(s, n, map);
@@ -3104,7 +3104,7 @@ static int list_locations(struct kmem_ca
 	/* Push back cpu slabs */
 	flush_all(s);
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 		unsigned long flags;
 		struct page *page;
@@ -3231,7 +3231,7 @@ static unsigned long slab_objects(struct
 		}
 	}
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		if (flags & SO_PARTIAL) {
@@ -3259,7 +3259,7 @@ static unsigned long slab_objects(struct
 
 	x = sprintf(buf, "%lu", total);
 #ifdef CONFIG_NUMA
-	for_each_online_node(node)
+	for_each_node_state(node, N_MEMORY)
 		if (nodes[node])
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
