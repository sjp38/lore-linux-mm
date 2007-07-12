Date: Wed, 11 Jul 2007 18:42:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 07/12] Memoryless nodes: SLUB support
In-Reply-To: <20070711170736.f6c304d3.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707111835130.3806@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com> <20070711182251.433134748@sgi.com>
 <20070711170736.f6c304d3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kxr@sgi.com, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007, Andrew Morton wrote:

> This is as far as I got when a reject storm hit.
> 
> > -	for_each_online_node(node)
> > +	for_each_node_state(node, N_MEMORY)
> >  		__kmem_cache_shrink(s, get_node(s, node), scratch);
> 
> I can find no sign of any __kmem_cache_shrink's anywhere.

Yup I expected slab defrag to be merged first before you get to this.
 
> Let's park all this until post-merge-window please.  Generally, now is not
> a good time for me to be merging 2.6.24 stuff.

For SGI this is not important at all since we have no memoryless nodes. 

However, these fixes are important for other NUMA users. I think this 
needs to go into 2.6.23 for correctnesses sake. We may have some fun with 
it since the fixed up behavior of GFP_THISNODE may expose additional 
problems in how subsystems handle memoryless nodes (and I do not have 
such a system). There are also patches against hugetlb that use this 
functionality here.

Necessary for asymmetric NUMA configs to work right.


Here is the patch rediffed before slab defrag.


Memoryless nodes: SLUB support

Simply switch all for_each_online_node to for_each_memory_node. That way
SLUB only operates on nodes with memory. Any allocation attempt on a
memoryless node will fall whereupon SLUB will fetch memory from a nearby
node (depending on how memory policies and cpuset describe fallback).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-11 18:31:55.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-11 18:33:27.000000000 -0700
@@ -1914,7 +1914,7 @@ static void free_kmem_cache_nodes(struct
 {
 	int node;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = s->node[node];
 		if (n && n != &s->local_node)
 			kmem_cache_free(kmalloc_caches, n);
@@ -1932,7 +1932,7 @@ static int init_kmem_cache_nodes(struct 
 	else
 		local_node = 0;
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n;
 
 		if (local_node == node)
@@ -2185,7 +2185,7 @@ static inline int kmem_cache_close(struc
 	flush_all(s);
 
 	/* Attempt to free all objects */
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		n->nr_partial -= free_list(s, n, &n->partial);
@@ -2480,7 +2480,7 @@ int kmem_cache_shrink(struct kmem_cache 
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		n = get_node(s, node);
 
 		if (!n->nr_partial)
@@ -2886,7 +2886,7 @@ static long validate_slab_cache(struct k
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		count += validate_slab_node(s, n, map);
@@ -3106,7 +3106,7 @@ static int list_locations(struct kmem_ca
 	/* Push back cpu slabs */
 	flush_all(s);
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 		unsigned long flags;
 		struct page *page;
@@ -3233,7 +3233,7 @@ static unsigned long slab_objects(struct
 		}
 	}
 
-	for_each_online_node(node) {
+	for_each_node_state(node, N_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
 		if (flags & SO_PARTIAL) {
@@ -3261,7 +3261,7 @@ static unsigned long slab_objects(struct
 
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
