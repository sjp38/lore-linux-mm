Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 89D836B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 15:07:28 -0500 (EST)
Message-Id: <20111111200725.634567005@linux.com>
Date: Fri, 11 Nov 2011 14:07:12 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [rfc 01/18] slub: Get rid of the node field
References: <20111111200711.156817886@linux.com>
Content-Disposition: inline; filename=get_rid_of_cnode
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

The node field is always page_to_nid(c->page). So its rather easy to
replace. Note that there will be additional overhead in various hot paths
due to the need to mask a set of bits in page->flags and shift the
result.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    1 -
 mm/slub.c                |   15 ++++++---------
 2 files changed, 6 insertions(+), 10 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-08 09:53:04.043865616 -0600
+++ linux-2.6/mm/slub.c	2011-11-09 11:10:46.111334466 -0600
@@ -1551,7 +1551,6 @@ static void *get_partial_node(struct kme
 
 		if (!object) {
 			c->page = page;
-			c->node = page_to_nid(page);
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
 			available =  page->objects - page->inuse;
@@ -2016,7 +2015,7 @@ static void flush_all(struct kmem_cache
 static inline int node_match(struct kmem_cache_cpu *c, int node)
 {
 #ifdef CONFIG_NUMA
-	if (node != NUMA_NO_NODE && c->node != node)
+	if (node != NUMA_NO_NODE && page_to_nid(c->page) != node)
 		return 0;
 #endif
 	return 1;
@@ -2105,7 +2104,6 @@ static inline void *new_slab_objects(str
 		page->freelist = NULL;
 
 		stat(s, ALLOC_SLAB);
-		c->node = page_to_nid(page);
 		c->page = page;
 		*pc = c;
 	} else
@@ -2202,7 +2200,6 @@ new_slab:
 	if (c->partial) {
 		c->page = c->partial;
 		c->partial = c->page->next;
-		c->node = page_to_nid(c->page);
 		stat(s, CPU_PARTIAL_ALLOC);
 		c->freelist = NULL;
 		goto redo;
@@ -2233,7 +2230,6 @@ new_slab:
 
 	c->freelist = get_freepointer(s, object);
 	deactivate_slab(s, c);
-	c->node = NUMA_NO_NODE;
 	local_irq_restore(flags);
 	return object;
 }
@@ -4437,9 +4433,10 @@ static ssize_t show_slab_objects(struct
 			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 			struct page *page;
 
-			if (!c || c->node < 0)
+			if (!c || !c->page)
 				continue;
 
+			node = page_to_nid(c->page);
 			if (c->page) {
 					if (flags & SO_TOTAL)
 						x = c->page->objects;
@@ -4449,16 +4446,16 @@ static ssize_t show_slab_objects(struct
 					x = 1;
 
 				total += x;
-				nodes[c->node] += x;
+				nodes[node] += x;
 			}
 			page = c->partial;
 
 			if (page) {
 				x = page->pobjects;
                                 total += x;
-                                nodes[c->node] += x;
+                                nodes[node] += x;
 			}
-			per_cpu[c->node]++;
+			per_cpu[node]++;
 		}
 	}
 
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-11-08 09:53:03.979865196 -0600
+++ linux-2.6/include/linux/slub_def.h	2011-11-09 11:10:46.121334523 -0600
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
