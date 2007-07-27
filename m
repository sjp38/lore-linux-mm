From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:44:33 -0400
Message-Id: <20070727194433.18614.31421.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 12/14] Memoryless nodes: Fix GFP_THISNODE behavior
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 12/14] Memoryless nodes: Fix GFP_THISNODE behavior

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

Drop the existing GFP_THISNODE checks from the page_allocators hot path.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 include/linux/gfp.h    |   16 +++++++++++-----
 include/linux/mmzone.h |   14 +++++++++++++-
 mm/page_alloc.c        |   28 +++++++++++++++++++++++-----
 3 files changed, 47 insertions(+), 11 deletions(-)

Index: Linux/include/linux/gfp.h
===================================================================
--- Linux.orig/include/linux/gfp.h	2007-07-25 09:29:50.000000000 -0400
+++ Linux/include/linux/gfp.h	2007-07-25 11:37:52.000000000 -0400
@@ -116,22 +116,28 @@ static inline int allocflags_to_migratet
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
+	int base = 0;
+
+#ifdef CONFIG_NUMA
+	if (flags & __GFP_THISNODE)
+		base = MAX_NR_ZONES;
+#endif
 #ifdef CONFIG_ZONE_DMA
 	if (flags & __GFP_DMA)
-		return ZONE_DMA;
+		return base + ZONE_DMA;
 #endif
 #ifdef CONFIG_ZONE_DMA32
 	if (flags & __GFP_DMA32)
-		return ZONE_DMA32;
+		return base + ZONE_DMA32;
 #endif
 	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
 			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return ZONE_MOVABLE;
+		return base + ZONE_MOVABLE;
 #ifdef CONFIG_HIGHMEM
 	if (flags & __GFP_HIGHMEM)
-		return ZONE_HIGHMEM;
+		return base + ZONE_HIGHMEM;
 #endif
-	return ZONE_NORMAL;
+	return base + ZONE_NORMAL;
 }
 
 static inline gfp_t set_migrateflags(gfp_t gfp, gfp_t migrate_flags)
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-07-25 11:37:48.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-07-25 11:37:52.000000000 -0400
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
@@ -1560,7 +1557,10 @@ restart:
 	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
 
 	if (unlikely(*z == NULL)) {
-		WARN_ON_ONCE(1);
+		/*
+		 * Happens if we have an empty zonelist as a result of
+		 * GFP_THISNODE being used on a memoryless node
+		 */
 		return NULL;
 	}
 
@@ -2159,6 +2159,22 @@ static void build_zonelists_in_node_orde
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
@@ -2262,7 +2278,7 @@ static void build_zonelists(pg_data_t *p
 	int order = current_zonelist_order;
 
 	/* initialize zonelists */
-	for (i = 0; i < MAX_NR_ZONES; i++) {
+	for (i = 0; i < MAX_ZONELISTS; i++) {
 		zonelist = pgdat->node_zonelists + i;
 		zonelist->zones[0] = NULL;
 	}
@@ -2307,6 +2323,8 @@ static void build_zonelists(pg_data_t *p
 		/* calculate node order -- i.e., DMA last! */
 		build_zonelists_in_zone_order(pgdat, j);
 	}
+
+	build_thisnode_zonelists(pgdat);
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */
Index: Linux/include/linux/mmzone.h
===================================================================
--- Linux.orig/include/linux/mmzone.h	2007-07-25 09:29:50.000000000 -0400
+++ Linux/include/linux/mmzone.h	2007-07-25 11:37:52.000000000 -0400
@@ -357,6 +357,17 @@ struct zone {
 #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
 
 #ifdef CONFIG_NUMA
+
+/*
+ * The NUMA zonelists are doubled becausse we need zonelists that restrict the
+ * allocations to a single node for GFP_THISNODE.
+ *
+ * [0 .. MAX_NR_ZONES -1] 		: Zonelists with fallback
+ * [MAZ_NR_ZONES ... MAZ_ZONELISTS -1]  : No fallback (GFP_THISNODE)
+ */
+#define MAX_ZONELISTS (2 * MAX_NR_ZONES)
+
+
 /*
  * We cache key information from each zonelist for smaller cache
  * footprint when scanning for free pages in get_page_from_freelist().
@@ -422,6 +433,7 @@ struct zonelist_cache {
 	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
 };
 #else
+#define MAX_ZONELISTS MAX_NR_ZONES
 struct zonelist_cache;
 #endif
 
@@ -470,7 +482,7 @@ extern struct page *mem_map;
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
-	struct zonelist node_zonelists[MAX_NR_ZONES];
+	struct zonelist node_zonelists[MAX_ZONELISTS];
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
