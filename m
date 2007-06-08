Date: Thu, 7 Jun 2007 20:49:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
In-Reply-To: <20070608032505.GA13227@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706072027300.27295@schroedinger.engr.sgi.com>
References: <20070607011701.GA14211@linux-sh.org>
 <20070607180108.0eeca877.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com>
 <20070608032505.GA13227@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, Paul Mundt wrote:

> obviously possible to try to work that in to SLOB or something similar,
> if making SLUB or SLAB lighterweight and more tunable for these cases
> ends up being a real barrier.

Its obviously possible and as far as I can tell the architecture you have 
there requires it to operate. But the question is how much special casing 
we will have to add to the core VM.

We would likely have to add a 

slub_nodes=

parameter that allows the specification of a nodelist that is allowed for 
the slab allocator. Then modify slub to use its own nodemap instead of 
the node online map. Modify get_partial_node to not try a node not in the 
nodemap and go to get_any_partial immediately. In addition to checking 
cpuset_zone_allowed we would need to check the slab node list.

Hmm.... That would also help to create isolated nodes that have no memory 
on them.

See what evil things you drive me to...

Could you try this patch (untested)? Set the allowed nodes on boot
with

slub_nodes=0

if you have only node 0 for SLUB.

---
 mm/slub.c |   69 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 63 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-06-07 20:32:30.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-06-07 20:48:19.000000000 -0700
@@ -270,6 +270,20 @@ static inline struct kmem_cache_node *ge
 #endif
 }
 
+#ifdef CONFIG_NUMA
+static nodemask_t slub_nodes = NODE_MASK_ALL;
+
+static inline int forbidden_node(int node)
+{
+	return !node_isset(node, slub_nodes);
+}
+#else
+static inline int forbidden_node(int node)
+{
+	return 0;
+}
+#endif
+
 static inline int check_valid_pointer(struct kmem_cache *s,
 				struct page *page, const void *object)
 {
@@ -1242,8 +1256,12 @@ static struct page *get_any_partial(stru
 					->node_zonelists[gfp_zone(flags)];
 	for (z = zonelist->zones; *z; z++) {
 		struct kmem_cache_node *n;
+		int node = zone_to_nid(*z);
 
-		n = get_node(s, zone_to_nid(*z));
+		if (forbidden_node(node))
+			continue;
+
+		n = get_node(s, node);
 
 		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
 				n->nr_partial > MIN_PARTIAL) {
@@ -1261,10 +1279,12 @@ static struct page *get_any_partial(stru
  */
 static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
 {
-	struct page *page;
+	struct page *page = NULL;
 	int searchnode = (node == -1) ? numa_node_id() : node;
 
-	page = get_partial_node(get_node(s, searchnode));
+	if (!forbidden_node(node))
+		page = get_partial_node(get_node(s, searchnode));
+
 	if (page || (flags & __GFP_THISNODE))
 		return page;
 
@@ -1819,7 +1839,11 @@ static void free_kmem_cache_nodes(struct
 	int node;
 
 	for_each_online_node(node) {
-		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_node *n;
+
+		if (forbidden_node(node))
+			continue;
+		n= s->node[node];
 		if (n && n != &s->local_node)
 			kmem_cache_free(kmalloc_caches, n);
 		s->node[node] = NULL;
@@ -1839,6 +1863,9 @@ static int init_kmem_cache_nodes(struct 
 	for_each_online_node(node) {
 		struct kmem_cache_node *n;
 
+		if (forbidden_node(node))
+			continue;
+
 		if (local_node == node)
 			n = &s->local_node;
 		else {
@@ -2092,7 +2119,12 @@ static int kmem_cache_close(struct kmem_
 
 	/* Attempt to free all objects */
 	for_each_online_node(node) {
-		struct kmem_cache_node *n = get_node(s, node);
+		struct kmem_cache_node *n;
+
+		if (forbidden_node(node))
+			continue;
+
+		n = get_node(s, node);
 
 		n->nr_partial -= free_list(s, n, &n->partial);
 		if (atomic_long_read(&n->nr_slabs))
@@ -2167,6 +2199,17 @@ static int __init setup_slub_nomerge(cha
 
 __setup("slub_nomerge", setup_slub_nomerge);
 
+#ifdef CONFIG_NUMA
+static int __init setup_slub_nodes(char *str)
+{
+	if (*str == '=')
+		nodelist_parse(str + 1, slub_nodes);
+	return 1;
+}
+
+__setup("slub_nodes", setup_slub_nodes);
+#endif
+
 static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
 		const char *name, int size, gfp_t gfp_flags)
 {
@@ -2329,6 +2372,9 @@ int kmem_cache_shrink(struct kmem_cache 
 
 	flush_all(s);
 	for_each_online_node(node) {
+		if (forbidden_node(node))
+			continue;
+
 		n = get_node(s, node);
 
 		if (!n->nr_partial)
@@ -2755,7 +2801,12 @@ static unsigned long validate_slab_cache
 
 	flush_all(s);
 	for_each_online_node(node) {
-		struct kmem_cache_node *n = get_node(s, node);
+		struct kmem_cache_node *n;
+
+		if (forbidden_node(node))
+			continue;
+
+		n = get_node(s, node);
 
 		count += validate_slab_node(s, n);
 	}
@@ -2981,6 +3032,9 @@ static int list_locations(struct kmem_ca
 		unsigned long flags;
 		struct page *page;
 
+		if (forbidden_node(node))
+			continue;
+
 		if (!atomic_read(&n->nr_slabs))
 			continue;
 
@@ -3104,6 +3158,9 @@ static unsigned long slab_objects(struct
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
+		if (forbidden_node(node))
+			continue;
+
 		if (flags & SO_PARTIAL) {
 			if (flags & SO_OBJECTS)
 				x = count_partial(n);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
