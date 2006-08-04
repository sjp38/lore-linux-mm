Date: Fri, 4 Aug 2006 16:57:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: linearly index zone->node_zonelists[]
In-Reply-To: <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0608041656150.5573@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

I wonder why we need this bitmask indexing into zone->node_zonelists[]?

We always start with the highest zone and then include all lower zones
if we build zonelists.

Are there really cases where we need allocation from ZONE_DMA or
ZONE_HIGHMEM but not ZONE_NORMAL? It seems that the current implementation
of highest_zone() makes that already impossible.

If we go linear on the index then gfp_zone() == highest_zone() and a lot
of definitions fall by the wayside.

We can now revert back to the use of gfp_zone() in mempolicy.c ;-)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc2-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.18-rc2-mm1.orig/include/linux/gfp.h	2006-08-04 15:25:00.000000000 -0700
+++ linux-2.6.18-rc2-mm1/include/linux/gfp.h	2006-08-04 16:07:39.000000000 -0700
@@ -12,9 +12,6 @@
  *
  * Zone modifiers (see linux/mmzone.h - low three bits)
  *
- * These may be masked by GFP_ZONEMASK to make allocations with this bit
- * set fall back to ZONE_NORMAL.
- *
  * Do not put any conditional on these. If necessary modify the definitions
  * without the underscores and use the consistently. The definitions here may
  * be used in bit comparisons.
@@ -78,14 +75,7 @@
 #define GFP_DMA32	__GFP_DMA32
 
 
-static inline int gfp_zone(gfp_t gfp)
-{
-	int zone = GFP_ZONEMASK & (__force int) gfp;
-	BUG_ON(zone >= GFP_ZONETYPES);
-	return zone;
-}
-
-static inline enum zone_type highest_zone(gfp_t flags)
+static inline enum zone_type gfp_zone(gfp_t flags)
 {
 	if (flags & __GFP_DMA)
 		return ZONE_DMA;
Index: linux-2.6.18-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc2-mm1.orig/mm/page_alloc.c	2006-08-04 16:07:12.000000000 -0700
+++ linux-2.6.18-rc2-mm1/mm/page_alloc.c	2006-08-04 16:07:39.000000000 -0700
@@ -1534,14 +1534,14 @@
 
 static void __meminit build_zonelists(pg_data_t *pgdat)
 {
-	int i, j, node, local_node;
+	int j, node, local_node;
+	enum zone_type i;
 	int prev_node, load;
 	struct zonelist *zonelist;
 	nodemask_t used_mask;
-	enum zone_type k;
 
 	/* initialize zonelists */
-	for (i = 0; i < GFP_ZONETYPES; i++) {
+	for (i = 0; i < MAX_NR_ZONES; i++) {
 		zonelist = pgdat->node_zonelists + i;
 		zonelist->zones[0] = NULL;
 	}
@@ -1571,13 +1571,11 @@
 			node_load[node] += load;
 		prev_node = node;
 		load--;
-		for (i = 0; i < GFP_ZONETYPES; i++) {
+		for (i = 0; i < MAX_NR_ZONES; i++) {
 			zonelist = pgdat->node_zonelists + i;
 			for (j = 0; zonelist->zones[j] != NULL; j++);
 
-			k = highest_zone(i);
-
-	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
 			zonelist->zones[j] = NULL;
 		}
 	}
@@ -1587,19 +1585,16 @@
 
 static void __meminit build_zonelists(pg_data_t *pgdat)
 {
-	int i, node, local_node;
-	enum zone_type k;
-	enum zone_type j;
+	int node, local_node;
+	enum zone_type i,j;
 
 	local_node = pgdat->node_id;
-	for (i = 0; i < GFP_ZONETYPES; i++) {
+	for (i = 0; i < MAX_NR_ZONES; i++) {
 		struct zonelist *zonelist;
 
 		zonelist = pgdat->node_zonelists + i;
 
-		j = 0;
-		k = highest_zone(i);
- 		j = build_zonelists_node(pgdat, zonelist, j, k);
+ 		j = build_zonelists_node(pgdat, zonelist, 0, i);
  		/*
  		 * Now we build the zonelist so that it contains the zones
  		 * of all the other nodes.
@@ -1611,12 +1606,12 @@
 		for (node = local_node + 1; node < MAX_NUMNODES; node++) {
 			if (!node_online(node))
 				continue;
-			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+			j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
 		}
 		for (node = 0; node < local_node; node++) {
 			if (!node_online(node))
 				continue;
-			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+			j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
 		}
 
 		zonelist->zones[j] = NULL;
Index: linux-2.6.18-rc2-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.18-rc2-mm1.orig/include/linux/mmzone.h	2006-08-04 15:08:57.000000000 -0700
+++ linux-2.6.18-rc2-mm1/include/linux/mmzone.h	2006-08-04 16:07:39.000000000 -0700
@@ -136,60 +136,18 @@
 	MAX_NR_ZONES
 };
 
-
 /*
  * When a memory allocation must conform to specific limitations (such
  * as being suitable for DMA) the caller will pass in hints to the
  * allocator in the gfp_mask, in the zone modifier bits.  These bits
  * are used to select a priority ordered list of memory zones which
- * match the requested limits.  GFP_ZONEMASK defines which bits within
- * the gfp_mask should be considered as zone modifiers.  Each valid
- * combination of the zone modifier bits has a corresponding list
- * of zones (in node_zonelists).  Thus for two zone modifiers there
- * will be a maximum of 4 (2 ** 2) zonelists, for 3 modifiers there will
- * be 8 (2 ** 3) zonelists.  GFP_ZONETYPES defines the number of possible
- * combinations of zone modifiers in "zone modifier space".
- *
- * As an optimisation any zone modifier bits which are only valid when
- * no other zone modifier bits are set (loners) should be placed in
- * the highest order bits of this field.  This allows us to reduce the
- * extent of the zonelists thus saving space.  For example in the case
- * of three zone modifier bits, we could require up to eight zonelists.
- * If the left most zone modifier is a "loner" then the highest valid
- * zonelist would be four allowing us to allocate only five zonelists.
- * Use the first form for GFP_ZONETYPES when the left most bit is not
- * a "loner", otherwise use the second.
- *
- * NOTE! Make sure this matches the zones in <linux/gfp.h>
+ * match the requested limits. See gfp_zone() in include/linux/gfp.h
  */
 
-#ifdef CONFIG_ZONE_DMA32
-
-#ifdef CONFIG_HIGHMEM
-#define GFP_ZONETYPES		((GFP_ZONEMASK + 1) / 2 + 1)    /* Loner */
-#define GFP_ZONEMASK		0x07
-#define ZONES_SHIFT		2	/* ceil(log2(MAX_NR_ZONES)) */
-#else
-#define GFP_ZONETYPES		((0x07 + 1) / 2 + 1)    /* Loner */
-/* Mask __GFP_HIGHMEM */
-#define GFP_ZONEMASK		0x05
-#define ZONES_SHIFT		2
-#endif
-
+#if !defined(CONFIG_ZONE_DMA32) && !defined(CONFIG_HIGHMEM)
+#define ZONES_SHIFT 1
 #else
-#ifdef CONFIG_HIGHMEM
-
-#define GFP_ZONEMASK		0x03
-#define ZONES_SHIFT		2
-#define GFP_ZONETYPES		3
-
-#else
-
-#define GFP_ZONEMASK		0x01
-#define ZONES_SHIFT		1
-#define GFP_ZONETYPES		2
-
-#endif
+#define ZONES_SHIFT 2
 #endif
 
 struct zone {
@@ -364,7 +322,7 @@
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
-	struct zonelist node_zonelists[GFP_ZONETYPES];
+	struct zonelist node_zonelists[MAX_NR_ZONES];
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;
Index: linux-2.6.18-rc2-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.18-rc2-mm1.orig/mm/mempolicy.c	2006-08-04 16:07:12.000000000 -0700
+++ linux-2.6.18-rc2-mm1/mm/mempolicy.c	2006-08-04 16:07:39.000000000 -0700
@@ -1097,7 +1097,7 @@
 	case MPOL_BIND:
 		/* Lower zones don't get a policy applied */
 		/* Careful: current->mems_allowed might have moved */
-		if (highest_zone(gfp) >= policy_zone)
+		if (gfp_zone(gfp) >= policy_zone)
 			if (cpuset_zonelist_valid_mems_allowed(policy->v.zonelist))
 				return policy->v.zonelist;
 		/*FALL THROUGH*/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
