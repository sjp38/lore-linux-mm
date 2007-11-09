From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20071109143326.23540.7193.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/6] Use two zonelist that are filtered by GFP mask
Date: Fri,  9 Nov 2007 14:33:26 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee.Schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Currently a node has a number of zonelists, one for each zone type in the
system and a second set for GFP_THISNODE allocations. Based on the zones allowed
by a gfp mask, one of these zonelists is selected. All of these zonelists
consume memory and occupy cache lines.

This patch replaces the multiple zonelists per-node with two zonelists. The
first contains all populated zones in the system and the second contains all
populated zones in node suitable for GFP_THISNODE allocations. An iterator
macro is introduced called for_each_zone_zonelist() interates through each
zone in the zonelist that is allowed by the GFP flags.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <clameter@sgi.com>
---

 arch/parisc/mm/init.c  |   11 +-
 fs/buffer.c            |    6 +
 include/linux/gfp.h    |   17 +---
 include/linux/mmzone.h |   65 +++++++++++-----
 mm/hugetlb.c           |    8 +-
 mm/oom_kill.c          |    8 +-
 mm/page_alloc.c        |  169 +++++++++++++++++++-------------------------
 mm/slab.c              |    8 +-
 mm/slub.c              |    8 +-
 mm/vmscan.c            |   20 ++---
 10 files changed, 159 insertions(+), 161 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/arch/parisc/mm/init.c linux-2.6.24-rc1-mm-010_use_two_zonelists/arch/parisc/mm/init.c
--- linux-2.6.24-rc1-mm-007_node_zonelist/arch/parisc/mm/init.c	2007-11-08 19:04:11.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/arch/parisc/mm/init.c	2007-11-08 19:11:18.000000000 +0000
@@ -603,15 +603,18 @@ void show_mem(void)
 #ifdef CONFIG_DISCONTIGMEM
 	{
 		struct zonelist *zl;
-		int i, j, k;
+		int i, j;
 
 		for (i = 0; i < npmem_ranges; i++) {
+			zl = node_zonelist(i);
 			for (j = 0; j < MAX_NR_ZONES; j++) {
-				zl = NODE_DATA(i)->node_zonelists + j;
+				struct zone **z;
+				struct zone *zone;
 
 				printk("Zone list for zone %d on node %d: ", j, i);
-				for (k = 0; zl->zones[k] != NULL; k++) 
-					printk("[%d/%s] ", zone_to_nid(zl->zones[k]), zl->zones[k]->name);
+				for_each_zone_zonelist(zone, z, zl, j)
+					printk("[%d/%s] ", zone_to_nid(zone),
+								zone->name);
 				printk("\n");
 			}
 		}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/fs/buffer.c linux-2.6.24-rc1-mm-010_use_two_zonelists/fs/buffer.c
--- linux-2.6.24-rc1-mm-007_node_zonelist/fs/buffer.c	2007-11-08 19:08:12.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/fs/buffer.c	2007-11-08 19:11:18.000000000 +0000
@@ -375,9 +375,11 @@ static void free_more_memory(void)
 	yield();
 
 	for_each_online_node(nid) {
-		zones = node_zonelist(nid, GFP_NOFS);
+		zones = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
+						gfp_zone(GFP_NOFS));
 		if (*zones)
-			try_to_free_pages(zones, 0, GFP_NOFS);
+			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
+						GFP_NOFS);
 	}
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/include/linux/gfp.h linux-2.6.24-rc1-mm-010_use_two_zonelists/include/linux/gfp.h
--- linux-2.6.24-rc1-mm-007_node_zonelist/include/linux/gfp.h	2007-11-08 19:08:12.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/include/linux/gfp.h	2007-11-08 19:11:18.000000000 +0000
@@ -119,29 +119,22 @@ static inline int allocflags_to_migratet
 
 static inline enum zone_type gfp_zone(gfp_t flags)
 {
-	int base = 0;
-
-#ifdef CONFIG_NUMA
-	if (flags & __GFP_THISNODE)
-		base = MAX_NR_ZONES;
-#endif
-
 #ifdef CONFIG_ZONE_DMA
 	if (flags & __GFP_DMA)
-		return base + ZONE_DMA;
+		return ZONE_DMA;
 #endif
 #ifdef CONFIG_ZONE_DMA32
 	if (flags & __GFP_DMA32)
-		return base + ZONE_DMA32;
+		return ZONE_DMA32;
 #endif
 	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
 			(__GFP_HIGHMEM | __GFP_MOVABLE))
-		return base + ZONE_MOVABLE;
+		return ZONE_MOVABLE;
 #ifdef CONFIG_HIGHMEM
 	if (flags & __GFP_HIGHMEM)
-		return base + ZONE_HIGHMEM;
+		return ZONE_HIGHMEM;
 #endif
-	return base + ZONE_NORMAL;
+	return ZONE_NORMAL;
 }
 
 static inline gfp_t set_migrateflags(gfp_t gfp, gfp_t migrate_flags)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/include/linux/mmzone.h linux-2.6.24-rc1-mm-010_use_two_zonelists/include/linux/mmzone.h
--- linux-2.6.24-rc1-mm-007_node_zonelist/include/linux/mmzone.h	2007-10-24 04:50:57.000000000 +0100
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/include/linux/mmzone.h	2007-11-08 19:11:18.000000000 +0000
@@ -393,10 +393,10 @@ static inline int zone_is_oom_locked(con
  * The NUMA zonelists are doubled becausse we need zonelists that restrict the
  * allocations to a single node for GFP_THISNODE.
  *
- * [0 .. MAX_NR_ZONES -1] 		: Zonelists with fallback
- * [MAZ_NR_ZONES ... MAZ_ZONELISTS -1]  : No fallback (GFP_THISNODE)
+ * [0]	: Zonelist with fallback
+ * [1]	: No fallback (GFP_THISNODE)
  */
-#define MAX_ZONELISTS (2 * MAX_NR_ZONES)
+#define MAX_ZONELISTS 2
 
 
 /*
@@ -464,7 +464,7 @@ struct zonelist_cache {
 	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
 };
 #else
-#define MAX_ZONELISTS MAX_NR_ZONES
+#define MAX_ZONELISTS 1
 struct zonelist_cache;
 #endif
 
@@ -486,24 +486,6 @@ struct zonelist {
 #endif
 };
 
-#ifdef CONFIG_NUMA
-/*
- * Only custom zonelists like MPOL_BIND need to be filtered as part of
- * policies. As described in the comment for struct zonelist_cache, these
- * zonelists will not have a zlcache so zlcache_ptr will not be set. Use
- * that to determine if the zonelists needs to be filtered or not.
- */
-static inline int alloc_should_filter_zonelist(struct zonelist *zonelist)
-{
-	return !zonelist->zlcache_ptr;
-}
-#else
-static inline int alloc_should_filter_zonelist(struct zonelist *zonelist)
-{
-	return 0;
-}
-#endif /* CONFIG_NUMA */
-
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
 struct node_active_region {
 	unsigned long start_pfn;
@@ -731,6 +713,45 @@ extern struct zone *next_zone(struct zon
 	     zone;					\
 	     zone = next_zone(zone))
 
+/* Returns the first zone at or below highest_zoneidx in a zonelist */
+static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
+					enum zone_type highest_zoneidx)
+{
+	struct zone **z;
+
+	/* Find the first suitable zone to use for the allocation */
+	z = zonelist->zones;
+	while (*z && zone_idx(*z) > highest_zoneidx)
+		z++;
+
+	return z;
+}
+
+/* Returns the next zone at or below highest_zoneidx in a zonelist */
+static inline struct zone **next_zones_zonelist(struct zone **z,
+					enum zone_type highest_zoneidx)
+{
+	/* Find the next suitable zone to use for the allocation */
+	while (*z && zone_idx(*z) > highest_zoneidx)
+		z++;
+
+	return z;
+}
+
+/**
+ * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
+ * @zone - The current zone in the iterator
+ * @z - The current pointer within zonelist->zones being iterated
+ * @zlist - The zonelist being iterated
+ * @highidx - The zone index of the highest zone to return
+ *
+ * This iterator iterates though all zones at or below a given zone index.
+ */
+#define for_each_zone_zonelist(zone, z, zlist, highidx) \
+	for (z = first_zones_zonelist(zlist, highidx), zone = *z++;	\
+		zone;							\
+		z = next_zones_zonelist(z, highidx), zone = *z++)
+
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/mm/hugetlb.c linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/hugetlb.c
--- linux-2.6.24-rc1-mm-007_node_zonelist/mm/hugetlb.c	2007-11-08 19:03:59.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/hugetlb.c	2007-11-08 19:11:18.000000000 +0000
@@ -78,11 +78,11 @@ static struct page *dequeue_huge_page(st
 	struct mempolicy *mpol;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
 					htlb_alloc_mask, &mpol);
-	struct zone **z;
+	struct zone *zone, **z;
 
-	for (z = zonelist->zones; *z; z++) {
-		nid = zone_to_nid(*z);
-		if (cpuset_zone_allowed_softwall(*z, htlb_alloc_mask) &&
+	for_each_zone_zonelist(zone, z, zonelist, MAX_NR_ZONES - 1) {
+		nid = zone_to_nid(zone);
+		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask) &&
 		    !list_empty(&hugepage_freelists[nid])) {
 			page = list_entry(hugepage_freelists[nid].next,
 					  struct page, lru);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/mm/oom_kill.c linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/oom_kill.c
--- linux-2.6.24-rc1-mm-007_node_zonelist/mm/oom_kill.c	2007-11-08 19:04:09.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/oom_kill.c	2007-11-08 19:11:18.000000000 +0000
@@ -175,12 +175,14 @@ static inline enum oom_constraint constr
 						    gfp_t gfp_mask)
 {
 #ifdef CONFIG_NUMA
+	struct zone *zone;
 	struct zone **z;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	nodemask_t nodes = node_states[N_HIGH_MEMORY];
 
-	for (z = zonelist->zones; *z; z++)
-		if (cpuset_zone_allowed_softwall(*z, gfp_mask))
-			node_clear(zone_to_nid(*z), nodes);
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
+			node_clear(zone_to_nid(zone), nodes);
 		else
 			return CONSTRAINT_CPUSET;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/mm/page_alloc.c linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/page_alloc.c
--- linux-2.6.24-rc1-mm-007_node_zonelist/mm/page_alloc.c	2007-11-08 19:08:12.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/page_alloc.c	2007-11-08 19:11:18.000000000 +0000
@@ -1400,41 +1400,28 @@ static void zlc_mark_zone_full(struct zo
  */
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
-		struct zonelist *zonelist, int alloc_flags)
+		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
 {
 	struct zone **z;
 	struct page *page = NULL;
-	int classzone_idx = zone_idx(zonelist->zones[0]);
+	int classzone_idx;
 	struct zone *zone;
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
-	enum zone_type highest_zoneidx = -1; /* Gets set for policy zonelists */
+
+	z = first_zones_zonelist(zonelist, high_zoneidx);
+	classzone_idx = zone_idx(*z);
 
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	z = zonelist->zones;
-
-	do {
-		/*
-		 * In NUMA, this could be a policy zonelist which contains
-		 * zones that may not be allowed by the current gfp_mask.
-		 * Check the zone is allowed by the current flags
-		 */
-		if (unlikely(alloc_should_filter_zonelist(zonelist))) {
-			if (highest_zoneidx == -1)
-				highest_zoneidx = gfp_zone(gfp_mask);
-			if (zone_idx(*z) > highest_zoneidx)
-				continue;
-		}
-
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
-		zone = *z;
 		if ((alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				goto try_next_zone;
@@ -1468,7 +1455,7 @@ try_next_zone:
 			zlc_active = 1;
 			did_zlc_setup = 1;
 		}
-	} while (*(++z) != NULL);
+	}
 
 	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
 		/* Disable zlc cache for second zonelist scan */
@@ -1542,6 +1529,7 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 		struct zonelist *zonelist)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct zone **z;
 	struct page *page;
 	struct reclaim_state reclaim_state;
@@ -1567,7 +1555,7 @@ restart:
 	}
 
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
-				zonelist, ALLOC_WMARK_LOW|ALLOC_CPUSET);
+			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
 		goto got_pg;
 
@@ -1611,7 +1599,8 @@ restart:
 	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	page = get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags);
+	page = get_page_from_freelist(gfp_mask, order, zonelist,
+						high_zoneidx, alloc_flags);
 	if (page)
 		goto got_pg;
 
@@ -1624,7 +1613,7 @@ rebalance:
 nofail_alloc:
 			/* go through the zonelist yet again, ignoring mins */
 			page = get_page_from_freelist(gfp_mask, order,
-				zonelist, ALLOC_NO_WATERMARKS);
+				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
 			if (gfp_mask & __GFP_NOFAIL) {
@@ -1659,7 +1648,7 @@ nofail_alloc:
 
 	if (likely(did_some_progress)) {
 		page = get_page_from_freelist(gfp_mask, order,
-						zonelist, alloc_flags);
+					zonelist, high_zoneidx, alloc_flags);
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
@@ -1675,7 +1664,7 @@ nofail_alloc:
 		 * under heavy pressure.
 		 */
 		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
-				zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+			zonelist, high_zoneidx, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
 		if (page) {
 			clear_zonelist_oom(zonelist);
 			goto got_pg;
@@ -1794,14 +1783,16 @@ EXPORT_SYMBOL(free_pages);
 
 static unsigned int nr_free_zone_pages(int offset)
 {
+	enum zone_type high_zoneidx = MAX_NR_ZONES - 1;
+	struct zone **z;
+	struct zone *zone;
+
 	/* Just pick one node, since fallback list is circular */
 	unsigned int sum = 0;
 
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
-	struct zone **zonep = zonelist->zones;
-	struct zone *zone;
 
-	for (zone = *zonep++; zone; zone = *zonep++) {
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		unsigned long size = zone->present_pages;
 		unsigned long high = zone->pages_high;
 		if (size > high)
@@ -2160,17 +2151,15 @@ static int find_next_best_node(int node,
  */
 static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 {
-	enum zone_type i;
 	int j;
 	struct zonelist *zonelist;
 
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		zonelist = pgdat->node_zonelists + i;
-		for (j = 0; zonelist->zones[j] != NULL; j++)
-			;
- 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
-		zonelist->zones[j] = NULL;
-	}
+	zonelist = &pgdat->node_zonelists[0];
+	for (j = 0; zonelist->zones[j] != NULL; j++)
+		;
+	j = build_zonelists_node(NODE_DATA(node), zonelist, j,
+							MAX_NR_ZONES - 1);
+	zonelist->zones[j] = NULL;
 }
 
 /*
@@ -2178,15 +2167,12 @@ static void build_zonelists_in_node_orde
  */
 static void build_thisnode_zonelists(pg_data_t *pgdat)
 {
-	enum zone_type i;
 	int j;
 	struct zonelist *zonelist;
 
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		zonelist = pgdat->node_zonelists + MAX_NR_ZONES + i;
-		j = build_zonelists_node(pgdat, zonelist, 0, i);
-		zonelist->zones[j] = NULL;
-	}
+	zonelist = &pgdat->node_zonelists[1];
+	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
+	zonelist->zones[j] = NULL;
 }
 
 /*
@@ -2199,27 +2185,24 @@ static int node_order[MAX_NUMNODES];
 
 static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 {
-	enum zone_type i;
 	int pos, j, node;
 	int zone_type;		/* needs to be signed */
 	struct zone *z;
 	struct zonelist *zonelist;
 
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		zonelist = pgdat->node_zonelists + i;
-		pos = 0;
-		for (zone_type = i; zone_type >= 0; zone_type--) {
-			for (j = 0; j < nr_nodes; j++) {
-				node = node_order[j];
-				z = &NODE_DATA(node)->node_zones[zone_type];
-				if (populated_zone(z)) {
-					zonelist->zones[pos++] = z;
-					check_highest_zone(zone_type);
-				}
+	zonelist = &pgdat->node_zonelists[0];
+	pos = 0;
+	for (zone_type = MAX_NR_ZONES - 1; zone_type >= 0; zone_type--) {
+		for (j = 0; j < nr_nodes; j++) {
+			node = node_order[j];
+			z = &NODE_DATA(node)->node_zones[zone_type];
+			if (populated_zone(z)) {
+				zonelist->zones[pos++] = z;
+				check_highest_zone(zone_type);
 			}
 		}
-		zonelist->zones[pos] = NULL;
 	}
+	zonelist->zones[pos] = NULL;
 }
 
 static int default_zonelist_order(void)
@@ -2346,19 +2329,15 @@ static void build_zonelists(pg_data_t *p
 /* Construct the zonelist performance cache - see further mmzone.h */
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
-	int i;
-
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		struct zonelist *zonelist;
-		struct zonelist_cache *zlc;
-		struct zone **z;
+	struct zonelist *zonelist;
+	struct zonelist_cache *zlc;
+	struct zone **z;
 
-		zonelist = pgdat->node_zonelists + i;
-		zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
-		bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-		for (z = zonelist->zones; *z; z++)
-			zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
-	}
+	zonelist = &pgdat->node_zonelists[0];
+	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
+	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
+	for (z = zonelist->zones; *z; z++)
+		zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
 }
 
 
@@ -2372,45 +2351,43 @@ static void set_zonelist_order(void)
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
-	enum zone_type i,j;
+	enum zone_type j;
+	struct zonelist *zonelist;
 
 	local_node = pgdat->node_id;
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		struct zonelist *zonelist;
 
-		zonelist = pgdat->node_zonelists + i;
+	zonelist = &pgdat->node_zonelists[0];
+	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
 
- 		j = build_zonelists_node(pgdat, zonelist, 0, i);
- 		/*
- 		 * Now we build the zonelist so that it contains the zones
- 		 * of all the other nodes.
- 		 * We don't want to pressure a particular node, so when
- 		 * building the zones for node N, we make sure that the
- 		 * zones coming right after the local ones are those from
- 		 * node N+1 (modulo N)
- 		 */
-		for (node = local_node + 1; node < MAX_NUMNODES; node++) {
-			if (!node_online(node))
-				continue;
-			j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
-		}
-		for (node = 0; node < local_node; node++) {
-			if (!node_online(node))
-				continue;
-			j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
-		}
-
-		zonelist->zones[j] = NULL;
+	/*
+	 * Now we build the zonelist so that it contains the zones
+	 * of all the other nodes.
+	 * We don't want to pressure a particular node, so when
+	 * building the zones for node N, we make sure that the
+	 * zones coming right after the local ones are those from
+	 * node N+1 (modulo N)
+	 */
+	for (node = local_node + 1; node < MAX_NUMNODES; node++) {
+		if (!node_online(node))
+			continue;
+		j = build_zonelists_node(NODE_DATA(node), zonelist, j,
+							MAX_NR_ZONES - 1);
 	}
+	for (node = 0; node < local_node; node++) {
+		if (!node_online(node))
+			continue;
+		j = build_zonelists_node(NODE_DATA(node), zonelist, j,
+							MAX_NR_ZONES - 1);
+	}
+
+	zonelist->zones[j] = NULL;
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
-	int i;
-
-	for (i = 0; i < MAX_NR_ZONES; i++)
-		pgdat->node_zonelists[i].zlcache_ptr = NULL;
+	pgdat->node_zonelists[0].zlcache_ptr = NULL;
+	pgdat->node_zonelists[1].zlcache_ptr = NULL;
 }
 
 #endif	/* CONFIG_NUMA */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/mm/slab.c linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/slab.c
--- linux-2.6.24-rc1-mm-007_node_zonelist/mm/slab.c	2007-11-08 19:08:12.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/slab.c	2007-11-08 19:11:18.000000000 +0000
@@ -3240,6 +3240,8 @@ static void *fallback_alloc(struct kmem_
 	struct zonelist *zonelist;
 	gfp_t local_flags;
 	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
 
@@ -3254,10 +3256,10 @@ retry:
 	 * Look through allowed nodes for objects available
 	 * from existing per node queues.
 	 */
-	for (z = zonelist->zones; *z && !obj; z++) {
-		nid = zone_to_nid(*z);
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+		nid = zone_to_nid(zone);
 
-		if (cpuset_zone_allowed_hardwall(*z, flags) &&
+		if (cpuset_zone_allowed_hardwall(zone, flags) &&
 			cache->nodelists[nid] &&
 			cache->nodelists[nid]->free_objects)
 				obj = ____cache_alloc_node(cache,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/mm/slub.c linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/slub.c
--- linux-2.6.24-rc1-mm-007_node_zonelist/mm/slub.c	2007-11-08 19:08:12.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/slub.c	2007-11-08 19:12:25.000000000 +0000
@@ -1325,6 +1325,8 @@ static unsigned long get_any_partial(str
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
 	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(flags);
 	unsigned long state;
 
 	/*
@@ -1350,12 +1352,12 @@ static unsigned long get_any_partial(str
 		return 0;
 
 	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
-	for (z = zonelist->zones; *z; z++) {
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
 
-		n = get_node(s, zone_to_nid(*z));
+		n = get_node(s, zone_to_nid(zone));
 
-		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
+		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > MIN_PARTIAL) {
 			state = get_partial_node(n, c);
 			if (state)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc1-mm-007_node_zonelist/mm/vmscan.c linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/vmscan.c
--- linux-2.6.24-rc1-mm-007_node_zonelist/mm/vmscan.c	2007-11-08 19:06:49.000000000 +0000
+++ linux-2.6.24-rc1-mm-010_use_two_zonelists/mm/vmscan.c	2007-11-08 19:17:37.000000000 +0000
@@ -1220,13 +1220,11 @@ static unsigned long shrink_zones(int pr
 					struct scan_control *sc)
 {
 	unsigned long nr_reclaimed = 0;
-	struct zone **zones = zonelist->zones;
-	int i;
+	struct zone **z;
+	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *zone = zones[i];
-
+	for_each_zone_zonelist(zone, z, zonelist, MAX_NR_ZONES - 1) {
 		if (!populated_zone(zone))
 			continue;
 
@@ -1267,14 +1265,13 @@ static unsigned long do_try_to_free_page
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
-	struct zone **zones = zonelist->zones;
-	int i;
+	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 
 	count_vm_event(ALLOCSTALL);
 
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *zone = zones[i];
-
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
 
@@ -1335,9 +1332,8 @@ out:
 	 */
 	if (priority < 0)
 		priority = 0;
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *zone = zones[i];
 
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
