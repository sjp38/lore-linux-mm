Date: Thu, 7 Jun 2007 21:27:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
In-Reply-To: <20070608041303.GA13603@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706072123560.27441@schroedinger.engr.sgi.com>
References: <20070607011701.GA14211@linux-sh.org>
 <20070607180108.0eeca877.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com>
 <20070608032505.GA13227@linux-sh.org> <Pine.LNX.4.64.0706072027300.27295@schroedinger.engr.sgi.com>
 <20070608041303.GA13603@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, Paul Mundt wrote:

> Node 1 SUnreclaim:          8 kB

> So at least that gets back the couple of slab pages!

Hmmmm.. is that worth it? The patch is not right btw. There is still the 
case that new_slab can acquire a page on the wrong node and since we are 
not setup to allow that node in SLUB we will crash.

This now gets a bit ugly. In order to avoid that situation we check
first if the node is allowed. If not then we simply ask for an alloc on
the first node.

But that may still make the page allocator fall back. If that happens then
we redo the allocation with GFP_THISNODE to force an allocation on the 
first node or fail.

I think we could do better by constructing a custom zonelist but that will 
be even more special casing.


---
 mm/slub.c |   63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 58 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-06-07 21:01:32.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-06-07 21:23:04.000000000 -0700
@@ -215,6 +215,10 @@ static inline void ClearSlabDebug(struct
 
 static int kmem_size = sizeof(struct kmem_cache);
 
+#ifdef CONFIG_NUMA
+static nodemask_t slub_nodes = NODE_MASK_ALL;
+#endif
+
 #ifdef CONFIG_SMP
 static struct notifier_block slab_notifier;
 #endif
@@ -1023,6 +1027,11 @@ static struct page *new_slab(struct kmem
 	if (flags & __GFP_WAIT)
 		local_irq_enable();
 
+	/* Hack: Just get the first node if the node is not allowed */
+	if (slab_state >= UP && !get_node(s, node))
+		node = first_node(slub_nodes);
+
+redo:
 	page = allocate_slab(s, flags & GFP_LEVEL_MASK, node);
 	if (!page)
 		goto out;
@@ -1030,6 +1039,27 @@ static struct page *new_slab(struct kmem
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
+#ifdef CONFIG_NUMA
+	else {
+		if (slab_state >= UP) {
+			/*
+			 * The baaad page allocator gave us a page on a
+			 * node that we should not use. Force a page on
+			 * a legit node or fail.
+			 */
+			__free_pages(page, s->order);
+			flags |= GFP_THISNODE;
+
+			mod_zone_page_state(page_zone(page),
+				(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+			NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
+				- (1 << s->order));
+
+			goto redo;
+		}
+	}
+#endif
+
 	page->offset = s->offset / sizeof(void *);
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
@@ -1261,10 +1291,13 @@ static struct page *get_any_partial(stru
  */
 static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
 {
-	struct page *page;
+	struct page *page = NULL;
 	int searchnode = (node == -1) ? numa_node_id() : node;
+	struct kmem_cache_node *n = get_node(s, searchnode);
+
+	if (n)
+		page = get_partial_node(n);
 
-	page = get_partial_node(get_node(s, searchnode));
 	if (page || (flags & __GFP_THISNODE))
 		return page;
 
@@ -1820,12 +1853,22 @@ static void free_kmem_cache_nodes(struct
 
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = s->node[node];
+
 		if (n && n != &s->local_node)
 			kmem_cache_free(kmalloc_caches, n);
 		s->node[node] = NULL;
 	}
 }
 
+static int __init setup_slub_nodes(char *str)
+{
+	if (*str == '=')
+		nodelist_parse(str + 1, slub_nodes);
+	return 1;
+}
+
+__setup("slub_nodes", setup_slub_nodes);
+
 static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
 {
 	int node;
@@ -1839,6 +1882,9 @@ static int init_kmem_cache_nodes(struct 
 	for_each_online_node(node) {
 		struct kmem_cache_node *n;
 
+		if (!node_isset(node, slub_nodes))
+			continue;
+
 		if (local_node == node)
 			n = &s->local_node;
 		else {
@@ -2094,6 +2140,9 @@ static int kmem_cache_close(struct kmem_
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
+		if (!n)
+			continue;
+
 		n->nr_partial -= free_list(s, n, &n->partial);
 		if (atomic_long_read(&n->nr_slabs))
 			return 1;
@@ -2331,7 +2380,7 @@ int kmem_cache_shrink(struct kmem_cache 
 	for_each_online_node(node) {
 		n = get_node(s, node);
 
-		if (!n->nr_partial)
+		if (!n || !n->nr_partial)
 			continue;
 
 		for (i = 0; i < s->objects; i++)
@@ -2757,7 +2806,8 @@ static unsigned long validate_slab_cache
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		count += validate_slab_node(s, n);
+		if (n)
+			count += validate_slab_node(s, n);
 	}
 	return count;
 }
@@ -2981,7 +3031,7 @@ static int list_locations(struct kmem_ca
 		unsigned long flags;
 		struct page *page;
 
-		if (!atomic_read(&n->nr_slabs))
+		if (!n || !atomic_read(&n->nr_slabs))
 			continue;
 
 		spin_lock_irqsave(&n->list_lock, flags);
@@ -3104,6 +3154,9 @@ static unsigned long slab_objects(struct
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
+		if (!n)
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
