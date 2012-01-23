Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D7DE66B006E
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 15:17:10 -0500 (EST)
Message-Id: <20120123201708.869898930@linux.com>
Date: Mon, 23 Jan 2012 14:16:52 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup 6/9] slub: Get rid of the node field
References: <20120123201646.924319545@linux.com>
Content-Disposition: inline; filename=get_rid_of_cnode
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The node field is always page_to_nid(c->page). So its rather easy to
replace. Note that there maybe slightly more overhead in various hot paths
due to the need to shift the bits from page->flags. However, that is mostly
compensated for by a smaller footprint of the kmem_cache_cpu structure (this
patch reduces that to 3 words per cache) which allows better caching.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    1 -
 mm/slub.c                |   35 ++++++++++++++++-------------------
 2 files changed, 16 insertions(+), 20 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-01-20 07:30:03.810312824 -0600
+++ linux-2.6/mm/slub.c	2012-01-20 08:15:54.066255837 -0600
@@ -1555,7 +1555,6 @@ static void *get_partial_node(struct kme
 
 		if (!object) {
 			c->page = page;
-			c->node = page_to_nid(page);
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
 			available =  page->objects - page->inuse;
@@ -2032,7 +2031,7 @@ static void flush_all(struct kmem_cache
 static inline int node_match(struct kmem_cache_cpu *c, int node)
 {
 #ifdef CONFIG_NUMA
-	if (node != NUMA_NO_NODE && c->node != node)
+	if (node != NUMA_NO_NODE && page_to_nid(c->page) != node)
 		return 0;
 #endif
 	return 1;
@@ -2127,7 +2126,6 @@ static inline void *new_slab_objects(str
 		page->freelist = NULL;
 
 		stat(s, ALLOC_SLAB);
-		c->node = page_to_nid(page);
 		c->page = page;
 		*pc = c;
 	} else
@@ -2244,7 +2242,6 @@ new_slab:
 	if (c->partial) {
 		c->page = c->partial;
 		c->partial = c->page->next;
-		c->node = page_to_nid(c->page);
 		stat(s, CPU_PARTIAL_ALLOC);
 		c->freelist = NULL;
 		goto redo;
@@ -2269,7 +2266,6 @@ new_slab:
 
 	c->freelist = get_freepointer(s, freelist);
 	deactivate_slab(s, c);
-	c->node = NUMA_NO_NODE;
 	local_irq_restore(flags);
 	return freelist;
 }
@@ -4474,30 +4470,31 @@ static ssize_t show_slab_objects(struct
 
 		for_each_possible_cpu(cpu) {
 			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
-			int node = ACCESS_ONCE(c->node);
+			int node;
 			struct page *page;
 
-			if (node < 0)
-				continue;
 			page = ACCESS_ONCE(c->page);
-			if (page) {
-				if (flags & SO_TOTAL)
-					x = page->objects;
-				else if (flags & SO_OBJECTS)
-					x = page->inuse;
-				else
-					x = 1;
+			if (!page)
+				continue;
 
-				total += x;
-				nodes[node] += x;
-			}
-			page = c->partial;
+			node = page_to_nid(page);
+			if (flags & SO_TOTAL)
+				x = page->objects;
+			else if (flags & SO_OBJECTS)
+				x = page->inuse;
+			else
+				x = 1;
 
+			total += x;
+			nodes[node] += x;
+
+			page = ACCESS_ONCE(c->partial);
 			if (page) {
 				x = page->pobjects;
 				total += x;
 				nodes[node] += x;
 			}
+
 			per_cpu[node]++;
 		}
 	}
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2012-01-20 05:06:45.478490987 -0600
+++ linux-2.6/include/linux/slub_def.h	2012-01-20 08:15:54.066255837 -0600
@@ -45,7 +45,6 @@ struct kmem_cache_cpu {
 	unsigned long tid;	/* Globally unique transaction id */
 	struct page *page;	/* The slab from which we are allocating */
 	struct page *partial;	/* Partially allocated frozen slabs */
-	int node;		/* The node of the page (or -1 for debug) */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
