From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 1/5] Fix object counting
Date: Tue, 10 Apr 2007 12:19:10 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Object counting did not take into account that the number of full slabs
is the total number of slabs - number of partial - number of cpu slabs. As a
results the counts were off a bit. This issue surfaced when slab validation
was implemented.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   61 ++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 34 insertions(+), 27 deletions(-)

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 22:29:21.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 22:30:06.000000000 -0700
@@ -2318,23 +2318,34 @@ static unsigned long slab_objects(struct
 	int node;
 	int x;
 	unsigned long *nodes;
+	unsigned long *per_cpu;
 
-	nodes = kmalloc(sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
+	nodes = kzalloc(2 * sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
+	per_cpu = nodes + nr_node_ids;
+
+	for_each_possible_cpu(cpu) {
+		struct page *page = s->cpu_slab[cpu];
+		int node;
+
+		if (page) {
+			node = page_to_nid(page);
+			if (flags & SO_CPU) {
+				int x = 0;
+
+				if (flags & SO_OBJECTS)
+					x = page->inuse;
+				else
+					x = 1;
+				total += x;
+				nodes[node] += x;
+			}
+			per_cpu[node]++;
+		}
+	}
 
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		nodes[node] = 0;
-
-		if (flags & SO_FULL) {
-			if (flags & SO_OBJECTS)
-				x = atomic_read(&n->nr_slabs)
-						* s->objects;
-			else
-				x = atomic_read(&n->nr_slabs);
-			total += x;
-			nodes[node] += x;
-		}
 		if (flags & SO_PARTIAL) {
 			if (flags & SO_OBJECTS)
 				x = count_partial(n);
@@ -2343,24 +2354,20 @@ static unsigned long slab_objects(struct
 			total += x;
 			nodes[node] += x;
 		}
-	}
-
-	if (flags & SO_CPU)
-		for_each_possible_cpu(cpu) {
-			struct page *page = s->cpu_slab[cpu];
 
-			if (page) {
-				int x = 0;
-				int node = page_to_nid(page);
+		if (flags & SO_FULL) {
+			int full_slabs = atomic_read(&n->nr_slabs)
+					- per_cpu[node]
+					- n->nr_partial;
 
-				if (flags & SO_OBJECTS)
-					x = page->inuse;
-				else
-					x = 1;
-				total += x;
-				nodes[node] += x;
-			}
+			if (flags & SO_OBJECTS)
+				x = full_slabs * s->objects;
+			else
+				x = full_slabs;
+			total += x;
+			nodes[node] += x;
 		}
+	}
 
 	x = sprintf(buf, "%lu", total);
 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
