From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:43:55 -0400
Message-Id: <20070727194355.18614.71582.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 06/14] Memoryless Node: Slab support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 06/14] Memoryless Node: Slab support

Slab should not allocate control structures for nodes without memory.
This may seem to work right now but its unreliable since not all
allocations can fall back due to the use of GFP_THISNODE.

Switching a few for_each_online_node's to for_each_memory_node will
allow us to only allocate for nodes that actually have memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 mm/slab.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: Linux/mm/slab.c
===================================================================
--- Linux.orig/mm/slab.c	2007-07-25 09:29:50.000000000 -0400
+++ Linux/mm/slab.c	2007-07-25 11:36:37.000000000 -0400
@@ -1565,7 +1565,7 @@ void __init kmem_cache_init(void)
 		/* Replace the static kmem_list3 structures for the boot cpu */
 		init_list(&cache_cache, &initkmem_list3[CACHE_CACHE], node);
 
-		for_each_online_node(nid) {
+		for_each_node_state(nid, N_MEMORY) {
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
@@ -1943,7 +1943,7 @@ static void __init set_up_list3s(struct 
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		cachep->nodelists[node] = &initkmem_list3[index + node];
 		cachep->nodelists[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
@@ -2074,7 +2074,7 @@ static int __init_refok setup_cpu_cache(
 			g_cpucache_up = PARTIAL_L3;
 		} else {
 			int node;
-			for_each_online_node(node) {
+			for_each_node_state(node, N_MEMORY) {
 				cachep->nodelists[node] =
 				    kmalloc_node(sizeof(struct kmem_list3),
 						GFP_KERNEL, node);
@@ -3784,7 +3784,7 @@ static int alloc_kmemlist(struct kmem_ca
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 
                 if (use_alien_caches) {
                         new_alien = alloc_alien_cache(node, cachep->limit);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
