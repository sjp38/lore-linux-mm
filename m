Message-Id: <20070618192545.536071353@sgi.com>
References: <20070618191956.411091458@sgi.com>
Date: Mon, 18 Jun 2007 12:20:02 -0700
From: clameter@sgi.com
Subject: [patch 06/10] Memoryless Node: Slab support
Content-Disposition: inline; filename=memless_slab
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Slab should not allocate control structures for nodes without memory. This may seem
to work right now but its unreliable since not all allocations can fall back due
to the use of GFP_THISNODE.

Switching a few for_each_online_node's to for_each_memory_node will allow us to
only allocate for nodes that actually have memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Index: linux-2.6.22-rc4-mm2/mm/slab.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slab.c	2007-06-18 11:46:25.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slab.c	2007-06-18 11:49:53.000000000 -0700
@@ -1564,7 +1564,7 @@ void __init kmem_cache_init(void)
 		/* Replace the static kmem_list3 structures for the boot cpu */
 		init_list(&cache_cache, &initkmem_list3[CACHE_CACHE], node);
 
-		for_each_online_node(nid) {
+		for_each_memory_node(nid) {
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
@@ -1942,7 +1942,7 @@ static void __init set_up_list3s(struct 
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 		cachep->nodelists[node] = &initkmem_list3[index + node];
 		cachep->nodelists[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
@@ -2073,7 +2073,7 @@ static int __init_refok setup_cpu_cache(
 			g_cpucache_up = PARTIAL_L3;
 		} else {
 			int node;
-			for_each_online_node(node) {
+			for_each_memory_node(node) {
 				cachep->nodelists[node] =
 				    kmalloc_node(sizeof(struct kmem_list3),
 						GFP_KERNEL, node);
@@ -3787,7 +3787,7 @@ static int alloc_kmemlist(struct kmem_ca
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
-	for_each_online_node(node) {
+	for_each_memory_node(node) {
 
                 if (use_alien_caches) {
                         new_alien = alloc_alien_cache(node, cachep->limit);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
