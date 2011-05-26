Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3AF5B900110
	for <linux-mm@kvack.org>; Thu, 26 May 2011 15:03:18 -0400 (EDT)
Message-Id: <20110526190315.583692908@linux.com>
Date: Thu, 26 May 2011 14:03:02 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub p1 2/4] slub: pass kmem_cache_cpu pointer to get_partial()
References: <20110526190300.120896512@linux.com>
Content-Disposition: inline; filename=push_c_into_get_partial
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

Pass the kmem_cache_cpu pointer to get_partial(). That way
we can avoid the this_cpu_write() statements.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |   30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-24 09:41:20.854874883 -0500
+++ linux-2.6/mm/slub.c	2011-05-24 09:41:23.624874864 -0500
@@ -1437,7 +1437,8 @@ static inline void remove_partial(struct
  * Must hold list_lock.
  */
 static inline int acquire_slab(struct kmem_cache *s,
-		struct kmem_cache_node *n, struct page *page)
+		struct kmem_cache_node *n, struct page *page,
+		struct kmem_cache_cpu *c)
 {
 	void *freelist;
 	unsigned long counters;
@@ -1466,9 +1467,9 @@ static inline int acquire_slab(struct km
 
 	if (freelist) {
 		/* Populate the per cpu freelist */
-		this_cpu_write(s->cpu_slab->freelist, freelist);
-		this_cpu_write(s->cpu_slab->page, page);
-		this_cpu_write(s->cpu_slab->node, page_to_nid(page));
+		c->freelist = freelist;
+		c->page = page;
+		c->node = page_to_nid(page);
 		return 1;
 	} else {
 		/*
@@ -1486,7 +1487,7 @@ static inline int acquire_slab(struct km
  * Try to allocate a partial slab from a specific node.
  */
 static struct page *get_partial_node(struct kmem_cache *s,
-					struct kmem_cache_node *n)
+		struct kmem_cache_node *n, struct kmem_cache_cpu *c)
 {
 	struct page *page;
 
@@ -1501,7 +1502,7 @@ static struct page *get_partial_node(str
 
 	spin_lock(&n->list_lock);
 	list_for_each_entry(page, &n->partial, lru)
-		if (acquire_slab(s, n, page))
+		if (acquire_slab(s, n, page, c))
 			goto out;
 	page = NULL;
 out:
@@ -1512,7 +1513,8 @@ out:
 /*
  * Get a page from somewhere. Search in increasing NUMA distances.
  */
-static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
+static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
+		struct kmem_cache_cpu *c)
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
@@ -1552,7 +1554,7 @@ static struct page *get_any_partial(stru
 
 		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > s->min_partial) {
-			page = get_partial_node(s, n);
+			page = get_partial_node(s, n, c);
 			if (page) {
 				put_mems_allowed();
 				return page;
@@ -1567,16 +1569,17 @@ static struct page *get_any_partial(stru
 /*
  * Get a partial page, lock it and return it.
  */
-static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node,
+		struct kmem_cache_cpu *c)
 {
 	struct page *page;
 	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
 
-	page = get_partial_node(s, get_node(s, searchnode));
+	page = get_partial_node(s, get_node(s, searchnode), c);
 	if (page || node != NUMA_NO_NODE)
 		return page;
 
-	return get_any_partial(s, flags);
+	return get_any_partial(s, flags, c);
 }
 
 #ifdef CONFIG_PREEMPT
@@ -1645,9 +1648,6 @@ void init_kmem_cache_cpus(struct kmem_ca
 	for_each_possible_cpu(cpu)
 		per_cpu_ptr(s->cpu_slab, cpu)->tid = init_tid(cpu);
 }
-/*
- * Remove the cpu slab
- */
 
 /*
  * Remove the cpu slab
@@ -1999,7 +1999,7 @@ load_freelist:
 	return object;
 
 new_slab:
-	page = get_partial(s, gfpflags, node);
+	page = get_partial(s, gfpflags, node, c);
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
 		object = c->freelist;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
