From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 27 Feb 2008 16:47:34 -0500
Message-Id: <20080227214734.6858.9968.sendpatchset@localhost>
In-Reply-To: <20080227214708.6858.53458.sendpatchset@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost>
Subject: [PATCH 4/6] Use two zonelist that are filtered by GFP mask
Sender: owner-linux-mm@kvack.org
From: Mel Gorman <mel@csn.ul.ie>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 4/6] Use two zonelist that are filtered by GFP mask

V11r3 against 2.6.25-rc2-mm1

Currently a node has two sets of zonelists, one for each zone type in the
system and a second set for GFP_THISNODE allocations. Based on the zones
allowed by a gfp mask, one of these zonelists is selected. All of these
zonelists consume memory and occupy cache lines.

This patch replaces the multiple zonelists per-node with two zonelists. The
first contains all populated zones in the system, ordered by distance, for
fallback allocations when the target/preferred node has no free pages.  The
second contains all populated zones in the node suitable for GFP_THISNODE
allocations.

An iterator macro is introduced called for_each_zone_zonelist() that interates
through each zone allowed by the GFP flags in the selected zonelist.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <clameter@sgi.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 arch/parisc/mm/init.c  |   11 ++-
 fs/buffer.c            |   10 +-
 include/linux/gfp.h    |   13 +++
 include/linux/mmzone.h |   65 ++++++++++++------
 mm/hugetlb.c           |    8 +-
 mm/oom_kill.c          |    8 +-
 mm/page_alloc.c        |  170 +++++++++++++++++++++----------------------------
 mm/slab.c              |    8 +-
 mm/slub.c              |    8 +-
 mm/vmscan.c            |   21 ++----
 10 files changed, 168 insertions(+), 154 deletions(-)

Index: linux-2.6.25-rc2-mm1/arch/parisc/mm/init.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/arch/parisc/mm/init.c	2008-02-27 16:28:03.000000000 -0500
+++ linux-2.6.25-rc2-mm1/arch/parisc/mm/init.c	2008-02-27 16:28:16.000000000 -0500
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
Index: linux-2.6.25-rc2-mm1/fs/buffer.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/fs/buffer.c	2008-02-27 16:28:11.000000000 -0500
+++ linux-2.6.25-rc2-mm1/fs/buffer.c	2008-02-27 16:28:16.000000000 -0500
@@ -368,16 +368,18 @@ void invalidate_bdev(struct block_device
  */
 static void free_more_memory(void)
 {
-	struct zonelist *zonelist;
+	struct zone **zones;
 	int nid;
 
 	wakeup_pdflush(1024);
 	yield();
 
 	for_each_online_node(nid) {
-		zonelist = node_zonelist(nid, GFP_NOFS);
-		if (zonelist->zones[0])
-			try_to_free_pages(zonelist, 0, GFP_NOFS);
+		zones = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
+						gfp_zone(GFP_NOFS));
+		if (*zones)
+			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
+						GFP_NOFS);
 	}
 }
 
Index: linux-2.6.25-rc2-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/gfp.h	2008-02-27 16:28:11.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/gfp.h	2008-02-27 16:28:16.000000000 -0500
@@ -151,17 +151,26 @@ static inline enum zone_type gfp_zone(gf
  * virtual kernel addresses to the allocated page(s).
  */
 
+static inline int gfp_zonelist(gfp_t flags)
+{
+	if (NUMA_BUILD && unlikely(flags & __GFP_THISNODE))
+		return 1;
+
+	return 0;
+}
+
 /*
  * We get the zone list from the current node and the gfp_mask.
  * This zone list contains a maximum of MAXNODES*MAX_NR_ZONES zones.
- * There are many zonelists per node, two for each active zone.
+ * There are two zonelists per node, one for all zones with memory and
+ * one containing just zones from the node the zonelist belongs to.
  *
  * For the normal case of non-DISCONTIGMEM systems the NODE_DATA() gets
  * optimized to &contig_page_data at compile-time.
  */
 static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
 {
-	return NODE_DATA(nid)->node_zonelists + gfp_zone(flags);
+	return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
 }
 
 #ifndef HAVE_ARCH_FREE_PAGE
Index: linux-2.6.25-rc2-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/mmzone.h	2008-02-27 16:28:03.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/mmzone.h	2008-02-27 16:28:16.000000000 -0500
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
@@ -732,6 +714,45 @@ extern struct zone *next_zone(struct zon
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
Index: linux-2.6.25-rc2-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/hugetlb.c	2008-02-27 16:28:03.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/hugetlb.c	2008-02-27 16:28:16.000000000 -0500
@@ -79,11 +79,11 @@ static struct page *dequeue_huge_page(st
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
Index: linux-2.6.25-rc2-mm1/mm/oom_kill.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/oom_kill.c	2008-02-27 16:28:03.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/oom_kill.c	2008-02-27 16:28:16.000000000 -0500
@@ -174,12 +174,14 @@ static inline enum oom_constraint constr
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
 
Index: linux-2.6.25-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/page_alloc.c	2008-02-27 16:28:14.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/page_alloc.c	2008-02-27 16:28:16.000000000 -0500
@@ -1388,42 +1388,29 @@ static void zlc_mark_zone_full(struct zo
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
 	struct zone *zone, *preferred_zone;
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
-	enum zone_type highest_zoneidx = -1; /* Gets set for policy zonelists */
+
+	z = first_zones_zonelist(zonelist, high_zoneidx);
+	classzone_idx = zone_idx(*z);
+	preferred_zone = *z;
 
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	z = zonelist->zones;
-	preferred_zone = *z;
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
@@ -1457,7 +1444,7 @@ try_next_zone:
 			zlc_active = 1;
 			did_zlc_setup = 1;
 		}
-	} while (*(++z) != NULL);
+	}
 
 	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
 		/* Disable zlc cache for second zonelist scan */
@@ -1531,6 +1518,7 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 		struct zonelist *zonelist)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct zone **z;
 	struct page *page;
 	struct reclaim_state reclaim_state;
@@ -1556,7 +1544,7 @@ restart:
 	}
 
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
-				zonelist, ALLOC_WMARK_LOW|ALLOC_CPUSET);
+			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
 		goto got_pg;
 
@@ -1600,7 +1588,8 @@ restart:
 	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	page = get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags);
+	page = get_page_from_freelist(gfp_mask, order, zonelist,
+						high_zoneidx, alloc_flags);
 	if (page)
 		goto got_pg;
 
@@ -1613,7 +1602,7 @@ rebalance:
 nofail_alloc:
 			/* go through the zonelist yet again, ignoring mins */
 			page = get_page_from_freelist(gfp_mask, order,
-				zonelist, ALLOC_NO_WATERMARKS);
+				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
 			if (gfp_mask & __GFP_NOFAIL) {
@@ -1648,7 +1637,7 @@ nofail_alloc:
 
 	if (likely(did_some_progress)) {
 		page = get_page_from_freelist(gfp_mask, order,
-						zonelist, alloc_flags);
+					zonelist, high_zoneidx, alloc_flags);
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
@@ -1664,7 +1653,7 @@ nofail_alloc:
 		 * under heavy pressure.
 		 */
 		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
-				zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+			zonelist, high_zoneidx, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
 		if (page) {
 			clear_zonelist_oom(zonelist);
 			goto got_pg;
@@ -1783,14 +1772,15 @@ EXPORT_SYMBOL(free_pages);
 
 static unsigned int nr_free_zone_pages(int offset)
 {
+	struct zone **z;
+	struct zone *zone;
+
 	/* Just pick one node, since fallback list is circular */
 	unsigned int sum = 0;
 
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
-	struct zone **zonep = zonelist->zones;
-	struct zone *zone;
 
-	for (zone = *zonep++; zone; zone = *zonep++) {
+	for_each_zone_zonelist(zone, z, zonelist, offset) {
 		unsigned long size = zone->present_pages;
 		unsigned long high = zone->pages_high;
 		if (size > high)
@@ -2148,17 +2138,15 @@ static int find_next_best_node(int node,
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
@@ -2166,15 +2154,12 @@ static void build_zonelists_in_node_orde
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
@@ -2187,27 +2172,24 @@ static int node_order[MAX_NUMNODES];
 
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
@@ -2334,19 +2316,15 @@ static void build_zonelists(pg_data_t *p
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
 
 
@@ -2360,45 +2338,43 @@ static void set_zonelist_order(void)
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
-	enum zone_type i,j;
+	enum zone_type j;
+	struct zonelist *zonelist;
 
 	local_node = pgdat->node_id;
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		struct zonelist *zonelist;
-
-		zonelist = pgdat->node_zonelists + i;
 
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
+	zonelist = &pgdat->node_zonelists[0];
+	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
 
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
Index: linux-2.6.25-rc2-mm1/mm/slab.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/slab.c	2008-02-27 16:28:11.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/slab.c	2008-02-27 16:28:16.000000000 -0500
@@ -3245,6 +3245,8 @@ static void *fallback_alloc(struct kmem_
 	struct zonelist *zonelist;
 	gfp_t local_flags;
 	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
 
@@ -3259,10 +3261,10 @@ retry:
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
Index: linux-2.6.25-rc2-mm1/mm/slub.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/slub.c	2008-02-27 16:28:11.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/slub.c	2008-02-27 16:28:16.000000000 -0500
@@ -1300,6 +1300,8 @@ static struct page *get_any_partial(stru
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
 	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(flags);
 	struct page *page;
 
 	/*
@@ -1325,12 +1327,12 @@ static struct page *get_any_partial(stru
 		return NULL;
 
 	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
-	for (z = zonelist->zones; *z; z++) {
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
 
-		n = get_node(s, zone_to_nid(*z));
+		n = get_node(s, zone_to_nid(zone));
 
-		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
+		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > MIN_PARTIAL) {
 			page = get_partial_node(n);
 			if (page)
Index: linux-2.6.25-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/vmscan.c	2008-02-27 16:28:09.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/vmscan.c	2008-02-27 16:28:16.000000000 -0500
@@ -1271,15 +1271,13 @@ static unsigned long shrink_zone(int pri
 static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
+	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	unsigned long nr_reclaimed = 0;
-	struct zone **zones = zonelist->zones;
-	int i;
-
+	struct zone **z;
+	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *zone = zones[i];
-
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		if (!populated_zone(zone))
 			continue;
 		/*
@@ -1333,8 +1331,9 @@ static unsigned long do_try_to_free_page
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
-	struct zone **zones = zonelist->zones;
-	int i;
+	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 
 	if (scan_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
@@ -1342,8 +1341,7 @@ static unsigned long do_try_to_free_page
 	 * mem_cgroup will not do shrink_slab.
 	 */
 	if (scan_global_lru(sc)) {
-		for (i = 0; zones[i] != NULL; i++) {
-			struct zone *zone = zones[i];
+		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
@@ -1409,8 +1407,7 @@ out:
 		priority = 0;
 
 	if (scan_global_lru(sc)) {
-		for (i = 0; zones[i] != NULL; i++) {
-			struct zone *zone = zones[i];
+		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
