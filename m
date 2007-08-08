From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070808161545.32320.41940.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/3] Use one zonelist that is filtered instead of multiple zonelists
Date: Wed,  8 Aug 2007 17:15:45 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently a node has a number of zonelists, one for each zone type in
the system. Based on the zones allowed by a gfp mask, one of these zonelists
is selected. All of these zonelists occupy memory and consume cache lines.

This patch replaces the multiple zonelists in the node with a single
zonelist that contains all populated zones in the system. An iterator macro
is introduced called for_each_zone_zonelist() interates through each zone
in the zonelist that is allowed by the GFP flags.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 arch/parisc/mm/init.c     |   11 ++-
 drivers/char/sysrq.c      |    3 
 fs/buffer.c               |    5 -
 include/linux/gfp.h       |    3 
 include/linux/mempolicy.h |    2 
 include/linux/mmzone.h    |   33 +++++++++
 mm/mempolicy.c            |    6 -
 mm/oom_kill.c             |    8 +-
 mm/page_alloc.c           |  138 ++++++++++++++++++-----------------------
 mm/slab.c                 |   11 +--
 mm/slub.c                 |   11 +--
 mm/vmscan.c               |   14 ++--
 12 files changed, 133 insertions(+), 112 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/arch/parisc/mm/init.c linux-2.6.23-rc1-mm2-010_use_zonelist/arch/parisc/mm/init.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/arch/parisc/mm/init.c	2007-07-22 21:41:00.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/arch/parisc/mm/init.c	2007-08-08 11:35:09.000000000 +0100
@@ -599,15 +599,18 @@ void show_mem(void)
 #ifdef CONFIG_DISCONTIGMEM
 	{
 		struct zonelist *zl;
-		int i, j, k;
+		int i, j;
 
 		for (i = 0; i < npmem_ranges; i++) {
+			zl = &NODE_DATA(i)->node_zonelist;
 			for (j = 0; j < MAX_NR_ZONES; j++) {
-				zl = NODE_DATA(i)->node_zonelists + j;
+				struct zone **z;
+				struct zone *zone;
 
 				printk("Zone list for zone %d on node %d: ", j, i);
-				for (k = 0; zl->zones[k] != NULL; k++) 
-					printk("[%ld/%s] ", zone_to_nid(zl->zones[k]), zl->zones[k]->name);
+				for_each_zone_zonelist(zone, z, zl, j)
+					printk(KERN_INFO, "[%ld/%s] ",
+						zone_to_nid(zone), zone->name);
 				printk("\n");
 			}
 		}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/drivers/char/sysrq.c linux-2.6.23-rc1-mm2-010_use_zonelist/drivers/char/sysrq.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/drivers/char/sysrq.c	2007-08-07 14:45:09.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/drivers/char/sysrq.c	2007-08-08 11:36:29.000000000 +0100
@@ -270,8 +270,7 @@ static struct sysrq_key_op sysrq_term_op
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(&NODE_DATA(0)->node_zonelists[ZONE_NORMAL],
-			GFP_KERNEL, 0);
+	out_of_memory(&NODE_DATA(0)->node_zonelist, GFP_KERNEL, 0);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/fs/buffer.c linux-2.6.23-rc1-mm2-010_use_zonelist/fs/buffer.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/fs/buffer.c	2007-08-07 14:45:10.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/fs/buffer.c	2007-08-08 13:42:03.000000000 +0100
@@ -362,9 +362,10 @@ static void free_more_memory(void)
 	yield();
 
 	for_each_online_pgdat(pgdat) {
-		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
+		zones = first_zones_zonelist(&pgdat->node_zonelist,
+			gfp_zone(GFP_NOFS));
 		if (*zones)
-			try_to_free_pages(zones, 0, GFP_NOFS);
+			try_to_free_pages(&pgdat->node_zonelist, 0, GFP_NOFS);
 	}
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/include/linux/gfp.h linux-2.6.23-rc1-mm2-010_use_zonelist/include/linux/gfp.h
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/include/linux/gfp.h	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/include/linux/gfp.h	2007-08-08 11:35:09.000000000 +0100
@@ -175,8 +175,7 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order,
-		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
+	return __alloc_pages(gfp_mask, order, &NODE_DATA(nid)->node_zonelist);
 }
 
 #ifdef CONFIG_NUMA
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/include/linux/mempolicy.h linux-2.6.23-rc1-mm2-010_use_zonelist/include/linux/mempolicy.h
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/include/linux/mempolicy.h	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/include/linux/mempolicy.h	2007-08-08 11:35:09.000000000 +0100
@@ -240,7 +240,7 @@ static inline void mpol_fix_fork_child_f
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 		unsigned long addr, gfp_t gfp_flags)
 {
-	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
+	return &NODE_DATA(0)->node_zonelist;
 }
 
 static inline int do_migrate_pages(struct mm_struct *mm,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/include/linux/mmzone.h linux-2.6.23-rc1-mm2-010_use_zonelist/include/linux/mmzone.h
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/include/linux/mmzone.h	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/include/linux/mmzone.h	2007-08-08 13:45:55.000000000 +0100
@@ -469,7 +469,7 @@ extern struct page *mem_map;
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
-	struct zonelist node_zonelists[MAX_NR_ZONES];
+	struct zonelist node_zonelist;
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;
@@ -670,6 +670,37 @@ extern struct zone *next_zone(struct zon
 	     zone;					\
 	     zone = next_zone(zone))
 
+/* Returns the first zone at or below highest_zoneidx in a zonelist */
+static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
+					enum zone_type highest_zoneidx)
+{
+	struct zone **z;
+	for (z = zonelist->zones; *z && zone_idx(*z) > highest_zoneidx; z++);
+	return z;
+}
+
+/* Returns the next zone at or below highest_zoneidx in a zonelist */
+static inline struct zone **next_zones_zonelist(struct zone **z,
+					enum zone_type highest_zoneidx)
+{
+	for (++z; *z && zone_idx(*z) > highest_zoneidx; z++);
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
+	for (z = first_zones_zonelist(zlist, highidx), zone = *z;	\
+		zone;							\
+		z = next_zones_zonelist(z, highidx), zone = *z)
+
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/mempolicy.c linux-2.6.23-rc1-mm2-010_use_zonelist/mm/mempolicy.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/mempolicy.c	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/mm/mempolicy.c	2007-08-08 11:35:09.000000000 +0100
@@ -1120,7 +1120,7 @@ static struct zonelist *zonelist_policy(
 		nd = 0;
 		BUG();
 	}
-	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
+	return &NODE_DATA(nd)->node_zonelist;
 }
 
 /* Do dynamic interleaving for a process */
@@ -1216,7 +1216,7 @@ struct zonelist *huge_zonelist(struct vm
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
+		return &NODE_DATA(nid)->node_zonelist;
 	}
 	return zonelist_policy(GFP_HIGHUSER, pol);
 }
@@ -1230,7 +1230,7 @@ static struct page *alloc_page_interleav
 	struct zonelist *zl;
 	struct page *page;
 
-	zl = NODE_DATA(nid)->node_zonelists + gfp_zone(gfp);
+	zl = &NODE_DATA(nid)->node_zonelist;
 	page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zl->zones[0])
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/oom_kill.c linux-2.6.23-rc1-mm2-010_use_zonelist/mm/oom_kill.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/oom_kill.c	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/mm/oom_kill.c	2007-08-08 11:35:09.000000000 +0100
@@ -177,8 +177,10 @@ static inline int constrained_alloc(stru
 {
 #ifdef CONFIG_NUMA
 	struct zone **z;
+	struct zone *zone;
 	nodemask_t nodes;
 	int node;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 
 	nodes_clear(nodes);
 	/* node has memory ? */
@@ -186,9 +188,9 @@ static inline int constrained_alloc(stru
 		if (NODE_DATA(node)->node_present_pages)
 			node_set(node, nodes);
 
-	for (z = zonelist->zones; *z; z++)
-		if (cpuset_zone_allowed_softwall(*z, gfp_mask))
-			node_clear(zone_to_nid(*z), nodes);
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
+			node_clear(zone_to_nid(zone), nodes);
 		else
 			return CONSTRAINT_CPUSET;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/page_alloc.c linux-2.6.23-rc1-mm2-010_use_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/page_alloc.c	2007-08-08 11:35:00.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/mm/page_alloc.c	2007-08-08 14:36:42.000000000 +0100
@@ -1416,6 +1416,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	struct page *page = NULL;
 	int classzone_idx = zone_idx(zonelist->zones[0]);
 	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
@@ -1425,13 +1426,10 @@ zonelist_scan:
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	z = zonelist->zones;
-
-	do {
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
-		zone = *z;
 		if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
 			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
 				break;
@@ -1468,7 +1466,7 @@ try_next_zone:
 			zlc_active = 1;
 			did_zlc_setup = 1;
 		}
-	} while (*(++z) != NULL);
+	}
 
 	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
 		/* Disable zlc cache for second zonelist scan */
@@ -1781,15 +1779,16 @@ EXPORT_SYMBOL(free_pages);
 
 static unsigned int nr_free_zone_pages(int offset)
 {
+	enum zone_type high_zoneidx = MAX_NR_ZONES - 1;
+	struct zone **z;
+	struct zone *zone;
+
 	/* Just pick one node, since fallback list is circular */
 	pg_data_t *pgdat = NODE_DATA(numa_node_id());
 	unsigned int sum = 0;
+	struct zonelist *zonelist = &pgdat->node_zonelist;
 
-	struct zonelist *zonelist = pgdat->node_zonelists + offset;
-	struct zone **zonep = zonelist->zones;
-	struct zone *zone;
-
-	for (zone = *zonep++; zone; zone = *zonep++) {
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		unsigned long size = zone->present_pages;
 		unsigned long high = zone->pages_high;
 		if (size > high)
@@ -2148,17 +2147,14 @@ static int find_next_best_node(int node,
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
+	zonelist = &pgdat->node_zonelist;
+	for (j = 0; zonelist->zones[j] != NULL; j++)
+		;
+	j = build_zonelists_node(NODE_DATA(node), zonelist, j, MAX_NR_ZONES-1);
+	zonelist->zones[j] = NULL;
 }
 
 /*
@@ -2171,27 +2167,24 @@ static int node_order[MAX_NUMNODES];
 
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
+	zonelist = &pgdat->node_zonelist;
+	pos = 0;
+	for (zone_type = MAX_NR_ZONES-1; zone_type >= 0; zone_type--) {
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
@@ -2258,17 +2251,14 @@ static void set_zonelist_order(void)
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int j, node, load;
-	enum zone_type i;
 	nodemask_t used_mask;
 	int local_node, prev_node;
 	struct zonelist *zonelist;
 	int order = current_zonelist_order;
 
-	/* initialize zonelists */
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		zonelist = pgdat->node_zonelists + i;
-		zonelist->zones[0] = NULL;
-	}
+	/* initialize zonelist */
+	zonelist = &pgdat->node_zonelist;
+	zonelist->zones[0] = NULL;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -2316,18 +2306,15 @@ static void build_zonelists(pg_data_t *p
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
 	int i;
+	struct zonelist *zonelist;
+	struct zonelist_cache *zlc;
+	struct zone **z;
 
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		struct zonelist *zonelist;
-		struct zonelist_cache *zlc;
-		struct zone **z;
-
-		zonelist = pgdat->node_zonelists + i;
-		zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
-		bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-		for (z = zonelist->zones; *z; z++)
-			zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
-	}
+	zonelist = &pgdat->node_zonelist;
+	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
+	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
+	for (z = zonelist->zones; *z; z++)
+		zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
 }
 
 
@@ -2341,45 +2328,42 @@ static void set_zonelist_order(void)
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
+	zonelist = &pgdat->node_zonelist;
+	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES-1);
 
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
+								MAX_NR_ZONES-1);
+	}
+	for (node = 0; node < local_node; node++) {
+		if (!node_online(node))
+			continue;
+		j = build_zonelists_node(NODE_DATA(node), zonelist, j,
+								MAX_NR_ZONES-1);
 	}
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
+	pgdat->node_zonelist.zlcache_ptr = NULL;
 }
 
 #endif	/* CONFIG_NUMA */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/slab.c linux-2.6.23-rc1-mm2-010_use_zonelist/mm/slab.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/slab.c	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/mm/slab.c	2007-08-08 11:35:09.000000000 +0100
@@ -3239,14 +3239,15 @@ static void *fallback_alloc(struct kmem_
 	struct zonelist *zonelist;
 	gfp_t local_flags;
 	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	zonelist = &NODE_DATA(slab_node(current->mempolicy))
-			->node_zonelists[gfp_zone(flags)];
+	zonelist = &NODE_DATA(slab_node(current->mempolicy))->node_zonelist;
 	local_flags = (flags & GFP_LEVEL_MASK);
 
 retry:
@@ -3254,10 +3255,10 @@ retry:
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/slub.c linux-2.6.23-rc1-mm2-010_use_zonelist/mm/slub.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/slub.c	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/mm/slub.c	2007-08-08 11:35:09.000000000 +0100
@@ -1285,6 +1285,8 @@ static struct page *get_any_partial(stru
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
 	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(flags);
 	struct page *page;
 
 	/*
@@ -1308,14 +1310,13 @@ static struct page *get_any_partial(stru
 	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
 		return NULL;
 
-	zonelist = &NODE_DATA(slab_node(current->mempolicy))
-					->node_zonelists[gfp_zone(flags)];
-	for (z = zonelist->zones; *z; z++) {
+	zonelist = &NODE_DATA(slab_node(current->mempolicy))->node_zonelist;
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
 
-		n = get_node(s, zone_to_nid(*z));
+		n = get_node(s, zone_to_nid(zone));
 
-		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
+		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > MIN_PARTIAL) {
 			page = get_partial_node(n);
 			if (page)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/vmscan.c linux-2.6.23-rc1-mm2-010_use_zonelist/mm/vmscan.c
--- linux-2.6.23-rc1-mm2-005_freepages_zonelist/mm/vmscan.c	2007-08-08 11:35:00.000000000 +0100
+++ linux-2.6.23-rc1-mm2-010_use_zonelist/mm/vmscan.c	2007-08-08 11:35:09.000000000 +0100
@@ -1136,8 +1136,10 @@ unsigned long try_to_free_pages(struct z
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
-	struct zone **zones = zonelist->zones;
+	struct zone **z;
+	struct zone *zone;
 	int i;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
@@ -1150,9 +1152,7 @@ unsigned long try_to_free_pages(struct z
 	delay_swap_prefetch();
 	count_vm_event(ALLOCSTALL);
 
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *zone = zones[i];
-
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
 
@@ -1164,7 +1164,7 @@ unsigned long try_to_free_pages(struct z
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zones, &sc);
+		nr_reclaimed += shrink_zones(priority, zonelist->zones, &sc);
 		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
 		if (reclaim_state) {
 			nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -1206,8 +1206,8 @@ out:
 	 */
 	if (priority < 0)
 		priority = 0;
-	for (i = 0; zones[i] != 0; i++) {
-		struct zone *zone = zones[i];
+	for (i = 0; zonelist->zones[i] != 0; i++) {
+		struct zone *zone = zonelist->zones[i];
 
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
