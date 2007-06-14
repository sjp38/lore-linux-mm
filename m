Message-Id: <20070614075336.405903951@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:36 -0700
From: clameter@sgi.com
Subject: [RFC 10/13] Memoryless nodes: Fix GFP_THISNODE behavior
Content-Disposition: inline; filename=memless_thisnode_fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

GFP_THISNODE checks that the zone selected is within the pgdat (node) of the
first zone of a nodelist. That only works if the node has memory. A
memoryless node will have its first node on another pgdat (node).

GFP_THISNODE currently will return simply memory on the first pgdat.
Thus it is returning memory on other nodes. GFP_THISNODE should fail
if there is no local memory on a node.


Add a new set of zonelists for each node that only contain the nodes
that belong to the zones itself so that no fallback is possible.

Then modify gfp_type to pickup the right zone based on the presence
of __GFP_THISNODE.

Then we can drop the existing GFP_THISNODE code from the hot path.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/include/linux/gfp.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/gfp.h	2007-06-14 00:22:42.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/gfp.h	2007-06-14 00:24:17.000000000 -0700
@@ -116,22 +116,28 @@ static inline int allocflags_to_migratet
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
+	int offset = 0;
+
+#ifdef CONFIG_NUMA
+	if (flags & __GFP_THISNODE)
+		offset = MAX_NR_ZONES;
+#endif
 #ifdef CONFIG_ZONE_DMA
 	if (flags & __GFP_DMA)
-		return ZONE_DMA;
+		return offset + ZONE_DMA;
 #endif
 #ifdef CONFIG_ZONE_DMA32
 	if (flags & __GFP_DMA32)
-		return ZONE_DMA32;
+		return offset + ZONE_DMA32;
 #endif
 	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
 			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return ZONE_MOVABLE;
+		return offset + ZONE_MOVABLE;
 #ifdef CONFIG_HIGHMEM
 	if (flags & __GFP_HIGHMEM)
-		return ZONE_HIGHMEM;
+		return offset + ZONE_HIGHMEM;
 #endif
-	return ZONE_NORMAL;
+	return offset + ZONE_NORMAL;
 }
 
 static inline gfp_t set_migrateflags(gfp_t gfp, gfp_t migrate_flags)
Index: linux-2.6.22-rc4-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/page_alloc.c	2007-06-14 00:25:29.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/page_alloc.c	2007-06-14 00:36:44.000000000 -0700
@@ -1433,9 +1433,6 @@ zonelist_scan:
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 		zone = *z;
-		if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
-			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
-				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				goto try_next_zone;
@@ -1556,7 +1553,10 @@ restart:
 	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
 
 	if (unlikely(*z == NULL)) {
-		/* Should this ever happen?? */
+		/*
+		 * Happens if we have an empty zonelist as a result of
+		 * GFP_THISNODE being used on a memoryless node
+		 */
 		return NULL;
 	}
 
@@ -2154,6 +2154,22 @@ static void build_zonelists_in_node_orde
 }
 
 /*
+ * Build gfp_thisnode zonelists
+ */
+static void build_thisnode_zonelists(pg_data_t *pgdat)
+{
+	enum zone_type i;
+	int j;
+	struct zonelist *zonelist;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		zonelist = pgdat->node_zonelists + MAX_NR_ZONES + i;
+ 		j = build_zonelists_node(pgdat, zonelist, 0, i);
+		zonelist->zones[j] = NULL;
+	}
+}
+
+/*
  * Build zonelists ordered by zone and nodes within zones.
  * This results in conserving DMA zone[s] until all Normal memory is
  * exhausted, but results in overflowing to remote node while memory
@@ -2257,7 +2273,7 @@ static void build_zonelists(pg_data_t *p
 	int order = current_zonelist_order;
 
 	/* initialize zonelists */
-	for (i = 0; i < MAX_NR_ZONES; i++) {
+	for (i = 0; i < 2 * MAX_NR_ZONES; i++) {
 		zonelist = pgdat->node_zonelists + i;
 		zonelist->zones[0] = NULL;
 	}
@@ -2303,6 +2319,8 @@ static void build_zonelists(pg_data_t *p
 		build_zonelists_in_zone_order(pgdat, j);
 	}
 
+	build_thisnode_zonelists(pgdat);
+
 	if (pgdat->node_present_pages)
 		node_set_has_memory(local_node);
 }
Index: linux-2.6.22-rc4-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/mmzone.h	2007-06-14 00:24:28.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/mmzone.h	2007-06-14 00:25:25.000000000 -0700
@@ -469,7 +469,11 @@ extern struct page *mem_map;
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
+#ifdef CONFIG_NUMA
+	struct zonelist node_zonelists[2 * MAX_NR_ZONES];
+#else
 	struct zonelist node_zonelists[MAX_NR_ZONES];
+#endif
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
