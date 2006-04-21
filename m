Date: Fri, 21 Apr 2006 13:11:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] split zonelist and use nodemask for page allocation [1/4]
Message-Id: <20060421131147.81477c93.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: clameter@sgi.com
List-ID: <linux-mm.kvack.org>

These patches modifies zonelist and add nodes_list[].
They also modify alloc_pages to use nodemask instead of zonelist.

By this, 
(1)very long zonelist will be removed.
(2)MPOL_BIND can work in sane way.
(3)node-hot-plug doesn't need to care  mempolicies.IOW, mempolicy doesn't have
   to manage zonelist.

My current concern is
(a) the performance degradation of alloc_pages() by this
(b) whether this will break assumptions of mempolicy or not.


-Kame

==
Now zonelist covers all nodes' zones, this patch modifies it to cover
only one node's. This patch also modifes front-end of alloc_pages to use
nodemask instead of zonelist.

zonelist is splited into zonelist and node_lists.
node_lists preserves all node's id in order of distance.

to be done:
- To duplicate nodes_list for each gfp type as zone_list will be better.
- This patch will make it slow the fastest path of alloc_pages(), so some more
  optimization will be needed.
- more clean up

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.17-rc1-mm2/include/linux/gfp.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/gfp.h	2006-04-21 10:54:40.000000000 +0900
+++ linux-2.6.17-rc1-mm2/include/linux/gfp.h	2006-04-21 10:55:15.000000000 +0900
@@ -104,7 +104,7 @@
 #endif
 
 extern struct page *
-FASTCALL(__alloc_pages(gfp_t, unsigned int, struct zonelist *));
+FASTCALL(__alloc_pages_nodemask(gfp_t, unsigned int, int, nodemask_t *));
 
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
@@ -116,8 +116,7 @@
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order,
-		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
+	return __alloc_pages_nodemask(gfp_mask, order, nid, NULL);
 }
 
 #ifdef CONFIG_NUMA
Index: linux-2.6.17-rc1-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-rc1-mm2.orig/include/linux/mmzone.h	2006-04-21 10:54:40.000000000 +0900
+++ linux-2.6.17-rc1-mm2/include/linux/mmzone.h	2006-04-21 12:07:40.000000000 +0900
@@ -268,7 +268,7 @@
  * footprint of this construct is very small.
  */
 struct zonelist {
-	struct zone *zones[MAX_NUMNODES * MAX_NR_ZONES + 1]; // NULL delimited
+	struct zone *zones[MAX_NR_ZONES + 1]; // NULL delimited
 };
 
 
@@ -287,6 +287,7 @@
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
 	struct zonelist node_zonelists[GFP_ZONETYPES];
+	int nodes_list[MAX_NUMNODES + 1]; /* sorted by distance */
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;
Index: linux-2.6.17-rc1-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/page_alloc.c	2006-04-21 10:54:40.000000000 +0900
+++ linux-2.6.17-rc1-mm2/mm/page_alloc.c	2006-04-21 12:08:22.000000000 +0900
@@ -980,7 +980,7 @@
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
-struct page * fastcall
+static struct page * fastcall
 __alloc_pages(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist)
 {
@@ -999,7 +999,7 @@
 	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
 
 	if (unlikely(*z == NULL)) {
-		/* Should this ever happen?? */
+		/* goto next node */
 		return NULL;
 	}
 
@@ -1137,7 +1137,29 @@
 	return page;
 }
 
-EXPORT_SYMBOL(__alloc_pages);
+struct page * fastcall
+__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
+		       int nid, nodemask_t *nodemask)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+	struct page *page = NULL;
+	struct zonelist *zl;
+	int target_nid;
+	int i = 0;
+
+	do {
+		target_nid = pgdat->nodes_list[i++];
+		if (likely(node_online(target_nid)))
+			if (!nodemask  || node_isset(target_nid, *nodemask)) {
+				zl = NODE_DATA(target_nid)->node_zonelists +
+					gfp_zone(gfp_mask);
+				page = __alloc_pages(gfp_mask, order, zl);
+			}
+	} while(!page && pgdat->nodes_list[i] != -1);
+
+	return page;
+}
+EXPORT_SYMBOL(__alloc_pages_nodemask);
 
 /*
  * Common helper functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
