Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EB61C900147
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:43 -0400 (EDT)
Message-Id: <20110902204740.866685343@linux.com>
Date: Fri, 02 Sep 2011 15:47:00 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 03/12] slub: Get rid of the node field
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=get_rid_of_cnode
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

The node field is always page_to_nid(c->page). So its rather easy to
replace. Note that there will be additional overhead in various hot paths.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    1 -
 mm/slub.c                |   12 +++++-------
 2 files changed, 5 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-09-01 07:27:22.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-09-02 08:20:19.021219504 -0500
@@ -1588,7 +1588,6 @@ static inline int acquire_slab(struct km
 		/* Populate the per cpu freelist */
 		this_cpu_write(s->cpu_slab->freelist, freelist);
 		this_cpu_write(s->cpu_slab->page, page);
-		this_cpu_write(s->cpu_slab->node, page_to_nid(page));
 		return 1;
 	} else {
 		/*
@@ -1958,7 +1957,7 @@ static void flush_all(struct kmem_cache
 static inline int node_match(struct kmem_cache_cpu *c, int node)
 {
 #ifdef CONFIG_NUMA
-	if (node != NUMA_NO_NODE && c->node != node)
+	if (node != NUMA_NO_NODE && page_to_nid(c->page) != node)
 		return 0;
 #endif
 	return 1;
@@ -2142,7 +2141,6 @@ new_slab:
 		page->inuse = page->objects;
 
 		stat(s, ALLOC_SLAB);
-		c->node = page_to_nid(page);
 		c->page = page;
 
 		if (kmem_cache_debug(s))
@@ -2160,7 +2158,6 @@ debug:
 
 	c->freelist = get_freepointer(s, object);
 	deactivate_slab(s, c);
-	c->node = NUMA_NO_NODE;
 	local_irq_restore(flags);
 	return object;
 }
@@ -4316,9 +4313,10 @@ static ssize_t show_slab_objects(struct
 		for_each_possible_cpu(cpu) {
 			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-			if (!c || c->node < 0)
+			if (!c || !c->freelist)
 				continue;
 
+			node = page_to_nid(c->page);
 			if (c->page) {
 					if (flags & SO_TOTAL)
 						x = c->page->objects;
@@ -4328,9 +4326,9 @@ static ssize_t show_slab_objects(struct
 					x = 1;
 
 				total += x;
-				nodes[c->node] += x;
+				nodes[node] += x;
 			}
-			per_cpu[c->node]++;
+			per_cpu[node]++;
 		}
 	}
 
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-09-01 07:26:53.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2011-09-02 08:18:46.071220101 -0500
@@ -42,7 +42,6 @@ struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to next available object */
 	unsigned long tid;	/* Globally unique transaction id */
 	struct page *page;	/* The slab from which we are allocating */
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
