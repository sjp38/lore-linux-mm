Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CCD776B0089
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:35 -0500 (EST)
Message-Id: <20111111200733.112660970@linux.com>
Date: Fri, 11 Nov 2011 14:07:23 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 12/18] slub: Remove kmem_cache_cpu dependency from acquire slab
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=remove_kmem_cache_cpu_dependency_from_acquire_slab
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

The page can be determined later from the object pointer
via virt_to_head_page().

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-10 13:46:55.809479604 -0600
+++ linux-2.6/mm/slub.c	2011-11-10 14:33:56.815359070 -0600
@@ -1531,7 +1531,7 @@ static int put_cpu_partial(struct kmem_c
  * Try to allocate a partial slab from a specific node.
  */
 static void *get_partial_node(struct kmem_cache *s,
-		struct kmem_cache_node *n, struct kmem_cache_cpu *c)
+		struct kmem_cache_node *n)
 {
 	struct page *page, *page2;
 	void *object = NULL;
@@ -1555,7 +1555,6 @@ static void *get_partial_node(struct kme
 			break;
 
 		if (!object) {
-			c->page = page;
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
 			available =  page->objects - page->inuse;
@@ -1574,8 +1573,7 @@ static void *get_partial_node(struct kme
 /*
  * Get a page from somewhere. Search in increasing NUMA distances.
  */
-static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
-		struct kmem_cache_cpu *c)
+static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
@@ -1615,7 +1613,7 @@ static struct page *get_any_partial(stru
 
 		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > s->min_partial) {
-			object = get_partial_node(s, n, c);
+			object = get_partial_node(s, n);
 			if (object) {
 				put_mems_allowed();
 				return object;
@@ -1630,17 +1628,16 @@ static struct page *get_any_partial(stru
 /*
  * Get a partial page, lock it and return it.
  */
-static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
-		struct kmem_cache_cpu *c)
+static void *get_partial(struct kmem_cache *s, gfp_t flags, int node)
 {
 	void *object;
 	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
 
-	object = get_partial_node(s, get_node(s, searchnode), c);
+	object = get_partial_node(s, get_node(s, searchnode));
 	if (object || node != NUMA_NO_NODE)
 		return object;
 
-	return get_any_partial(s, flags, c);
+	return get_any_partial(s, flags);
 }
 
 #ifdef CONFIG_PREEMPT
@@ -2088,7 +2085,7 @@ slab_out_of_memory(struct kmem_cache *s,
 }
 
 static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
-			int node, struct kmem_cache_cpu **pc)
+			int node)
 {
 	void *freelist;
 	struct kmem_cache_cpu *c;
@@ -2107,8 +2104,6 @@ static inline void *new_slab_objects(str
 		page->freelist = NULL;
 
 		stat(s, ALLOC_SLAB);
-		c->page = page;
-		*pc = c;
 	} else
 		freelist = NULL;
 
@@ -2225,10 +2220,10 @@ new_slab:
 		goto redo;
 	}
 
-	freelist = get_partial(s, gfpflags, node, c);
+	freelist = get_partial(s, gfpflags, node);
 
 	if (!freelist)
-		freelist = new_slab_objects(s, gfpflags, node, &c);
+		freelist = new_slab_objects(s, gfpflags, node);
 
 
 	if (unlikely(!freelist)) {
@@ -2239,7 +2234,8 @@ new_slab:
 		return NULL;
 	}
 
-	page = c->page;
+	page = c->page = virt_to_head_page(freelist);
+
 	if (likely(!kmem_cache_debug(s)))
 		goto load_freelist;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
