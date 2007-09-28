From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070928142526.16783.97067.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/6] Use one zonelist that is filtered by nodemask
Date: Fri, 28 Sep 2007 15:25:27 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee.Schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Two zonelists exist so that GFP_THISNODE allocations will be guaranteed
to use memory only from a node local to the CPU. As we can now filter the
zonelist based on a nodemask, we filter the standard node zonelist for zones
on the local node when GFP_THISNODE is specified.

When GFP_THISNODE is used, a temporary nodemask is created with only the
node local to the CPU set. This allows us to eliminate the second zonelist.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <clameter@sgi.com>
---

 drivers/char/sysrq.c      |    2 -
 fs/buffer.c               |    5 +--
 include/linux/gfp.h       |   20 ++-----------
 include/linux/mempolicy.h |    2 -
 include/linux/mmzone.h    |   14 ---------
 mm/mempolicy.c            |    8 ++---
 mm/page_alloc.c           |   61 ++++++++++++++++++++++-------------------
 mm/slab.c                 |    2 -
 mm/slub.c                 |    2 -
 mm/vmscan.c               |    2 -
 10 files changed, 50 insertions(+), 68 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/drivers/char/sysrq.c linux-2.6.23-rc8-mm2-040_use_one_zonelist/drivers/char/sysrq.c
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/drivers/char/sysrq.c	2007-09-28 15:48:55.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/drivers/char/sysrq.c	2007-09-28 15:54:13.000000000 +0100
@@ -271,7 +271,7 @@ static struct sysrq_key_op sysrq_term_op
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
+	out_of_memory(node_zonelist(0), GFP_KERNEL, 0);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/fs/buffer.c linux-2.6.23-rc8-mm2-040_use_one_zonelist/fs/buffer.c
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/fs/buffer.c	2007-09-28 15:49:57.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/fs/buffer.c	2007-09-28 15:54:13.000000000 +0100
@@ -375,11 +375,10 @@ static void free_more_memory(void)
 	yield();
 
 	for_each_online_node(nid) {
-		zrefs = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
+		zrefs = first_zones_zonelist(node_zonelist(nid),
 						NULL, gfp_zone(GFP_NOFS));
 		if (zrefs->zone)
-			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS);
+			try_to_free_pages(node_zonelist(nid), 0, GFP_NOFS);
 	}
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/gfp.h linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/gfp.h
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/gfp.h	2007-09-28 15:49:57.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/gfp.h	2007-09-28 15:55:03.000000000 +0100
@@ -150,28 +150,16 @@ static inline gfp_t set_migrateflags(gfp
  * virtual kernel addresses to the allocated page(s).
  */
 
-static inline enum zone_type gfp_zonelist(gfp_t flags)
-{
-	int base = 0;
-
-	if (NUMA_BUILD && (flags & __GFP_THISNODE))
-		base = 1;
-
-	return base;
-}
-
 /*
- * We get the zone list from the current node and the gfp_mask.
+ * We get the zone list based on a node ID as there is one zone list per node.
  * This zone list contains a maximum of MAXNODES*MAX_NR_ZONES zones.
- * There are two zonelists per node, one for all zones with memory and
- * one containing just zones from the node the zonelist belongs to.
  *
  * For the normal case of non-DISCONTIGMEM systems the NODE_DATA() gets
  * optimized to &contig_page_data at compile-time.
  */
-static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
+static inline struct zonelist *node_zonelist(int nid)
 {
-	return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
+	return &NODE_DATA(nid)->node_zonelist;
 }
 
 #ifndef HAVE_ARCH_FREE_PAGE
@@ -198,7 +186,7 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+	return __alloc_pages(gfp_mask, order, node_zonelist(nid));
 }
 
 #ifdef CONFIG_NUMA
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mempolicy.h linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/mempolicy.h
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mempolicy.h	2007-09-28 15:49:57.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/mempolicy.h	2007-09-28 15:54:13.000000000 +0100
@@ -240,7 +240,7 @@ static inline void mpol_fix_fork_child_f
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
  		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol)
 {
-	return node_zonelist(0, gfp_flags);
+	return node_zonelist(0);
 }
 
 static inline int do_migrate_pages(struct mm_struct *mm,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mmzone.h linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/mmzone.h
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/mmzone.h	2007-09-28 15:49:57.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/mmzone.h	2007-09-28 15:54:13.000000000 +0100
@@ -390,17 +390,6 @@ static inline int zone_is_oom_locked(con
 #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
 
 #ifdef CONFIG_NUMA
-
-/*
- * The NUMA zonelists are doubled becausse we need zonelists that restrict the
- * allocations to a single node for GFP_THISNODE.
- *
- * [0]	: Zonelist with fallback
- * [1]	: No fallback (GFP_THISNODE)
- */
-#define MAX_ZONELISTS 2
-
-
 /*
  * We cache key information from each zonelist for smaller cache
  * footprint when scanning for free pages in get_page_from_freelist().
@@ -466,7 +455,6 @@ struct zonelist_cache {
 	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
 };
 #else
-#define MAX_ZONELISTS 1
 struct zonelist_cache;
 #endif
 
@@ -531,7 +519,7 @@ extern struct page *mem_map;
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
-	struct zonelist node_zonelists[MAX_ZONELISTS];
+	struct zonelist node_zonelist;
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/mempolicy.c linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/mempolicy.c
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/mempolicy.c	2007-09-28 15:49:57.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/mempolicy.c	2007-09-28 15:54:13.000000000 +0100
@@ -1136,7 +1136,7 @@ static struct zonelist *zonelist_policy(
 		nd = 0;
 		BUG();
 	}
-	return node_zonelist(nd, gfp);
+	return node_zonelist(nd);
 }
 
 /* Do dynamic interleaving for a process */
@@ -1173,7 +1173,7 @@ unsigned slab_node(struct mempolicy *pol
 		struct zonelist *zonelist;
 		struct zoneref *z;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
-		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
+		zonelist = &NODE_DATA(numa_node_id())->node_zonelist;
 		z = first_zones_zonelist(zonelist, &policy->v.nodes,
 							highest_zoneidx);
 		return zonelist_node_idx(z);
@@ -1257,7 +1257,7 @@ struct zonelist *huge_zonelist(struct vm
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
 		__mpol_free(pol);		/* finished with pol */
-		return node_zonelist(nid, gfp_flags);
+		return node_zonelist(nid);
 	}
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
@@ -1279,7 +1279,7 @@ static struct page *alloc_page_interleav
 	struct zonelist *zl;
 	struct page *page;
 
-	zl = node_zonelist(nid, gfp);
+	zl = node_zonelist(nid);
 	page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zonelist_zone(&zl->_zonerefs[0]))
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/page_alloc.c linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/page_alloc.c	2007-09-28 15:49:57.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/page_alloc.c	2007-09-28 15:54:13.000000000 +0100
@@ -1741,10 +1741,33 @@ got_pg:
 	return page;
 }
 
+static nodemask_t *nodemask_thisnode(nodemask_t *nodemask)
+{
+	/* Build a nodemask for just this node */
+	int nid = numa_node_id();
+
+	nodes_clear(*nodemask);
+	node_set(nid, *nodemask);
+
+	return nodemask;
+}
+
 struct page * fastcall
 __alloc_pages(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist)
 {
+	/*
+	 * Use a temporary nodemask for __GFP_THISNODE allocations. If the
+	 * cost of allocating on the stack or the stack usage becomes
+	 * noticable, allocate the nodemasks per node at boot or compile time
+	 */
+	if (unlikely(gfp_mask & __GFP_THISNODE)) {
+		nodemask_t nodemask;
+
+		return __alloc_pages_internal(gfp_mask, order,
+				zonelist, nodemask_thisnode(&nodemask));
+	}
+
 	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
 }
 
@@ -1752,6 +1775,9 @@ struct page * fastcall
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist, nodemask_t *nodemask)
 {
+	/* Specifying both __GFP_THISNODE and nodemask is stupid. Warn user */
+	WARN_ON(gfp_mask & __GFP_THISNODE);
+
 	return __alloc_pages_internal(gfp_mask, order, zonelist, nodemask);
 }
 
@@ -1828,7 +1854,7 @@ static unsigned int nr_free_zone_pages(i
 	/* Just pick one node, since fallback list is circular */
 	unsigned int sum = 0;
 
-	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
+	struct zonelist *zonelist = node_zonelist(numa_node_id());
 
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		unsigned long size = zone->present_pages;
@@ -2192,7 +2218,7 @@ static void build_zonelists_in_node_orde
 	int j;
 	struct zonelist *zonelist;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelist;
 	for (j = 0; zonelist->_zonerefs[j].zone != NULL; j++)
 		;
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j,
@@ -2201,19 +2227,6 @@ static void build_zonelists_in_node_orde
 }
 
 /*
- * Build gfp_thisnode zonelists
- */
-static void build_thisnode_zonelists(pg_data_t *pgdat)
-{
-	int j;
-	struct zonelist *zonelist;
-
-	zonelist = &pgdat->node_zonelists[1];
-	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
-	zonelist->_zonerefs[j].zone = NULL;
-}
-
-/*
  * Build zonelists ordered by zone and nodes within zones.
  * This results in conserving DMA zone[s] until all Normal memory is
  * exhausted, but results in overflowing to remote node while memory
@@ -2228,7 +2241,7 @@ static void build_zonelists_in_zone_orde
 	struct zone *z;
 	struct zonelist *zonelist;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelist;
 	pos = 0;
 	for (zone_type = MAX_NR_ZONES - 1; zone_type >= 0; zone_type--) {
 		for (j = 0; j < nr_nodes; j++) {
@@ -2308,17 +2321,14 @@ static void set_zonelist_order(void)
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int j, node, load;
-	enum zone_type i;
 	nodemask_t used_mask;
 	int local_node, prev_node;
 	struct zonelist *zonelist;
 	int order = current_zonelist_order;
 
 	/* initialize zonelists */
-	for (i = 0; i < MAX_ZONELISTS; i++) {
-		zonelist = pgdat->node_zonelists + i;
-		zonelist->_zonerefs[0].zone = NULL;
-	}
+	zonelist = &pgdat->node_zonelist;
+	zonelist->_zonerefs[0].zone = NULL;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -2360,8 +2370,6 @@ static void build_zonelists(pg_data_t *p
 		/* calculate node order -- i.e., DMA last! */
 		build_zonelists_in_zone_order(pgdat, j);
 	}
-
-	build_thisnode_zonelists(pgdat);
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */
@@ -2371,7 +2379,7 @@ static void build_zonelist_cache(pg_data
 	struct zonelist_cache *zlc;
 	struct zoneref *z;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelist;
 	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
 	for (z = zonelist->_zonerefs; z->zone; z++)
@@ -2394,7 +2402,7 @@ static void build_zonelists(pg_data_t *p
 
 	local_node = pgdat->node_id;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelist;
 	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
 
 	/*
@@ -2424,8 +2432,7 @@ static void build_zonelists(pg_data_t *p
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
-	pgdat->node_zonelists[0].zlcache_ptr = NULL;
-	pgdat->node_zonelists[1].zlcache_ptr = NULL;
+	pgdat->node_zonelist.zlcache_ptr = NULL;
 }
 
 #endif	/* CONFIG_NUMA */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/slab.c linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/slab.c
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/slab.c	2007-09-28 15:49:39.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/slab.c	2007-09-28 15:54:13.000000000 +0100
@@ -3248,7 +3248,7 @@ static void *fallback_alloc(struct kmem_
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	zonelist = node_zonelist(slab_node(current->mempolicy));
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 retry:
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/slub.c linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/slub.c
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/slub.c	2007-09-28 15:49:39.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/slub.c	2007-09-28 15:54:13.000000000 +0100
@@ -1305,7 +1305,7 @@ static struct page *get_any_partial(stru
 	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
 		return NULL;
 
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	zonelist = node_zonelist(slab_node(current->mempolicy));
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/vmscan.c linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/vmscan.c
--- linux-2.6.23-rc8-mm2-030_filter_nodemask/mm/vmscan.c	2007-09-28 15:49:39.000000000 +0100
+++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/vmscan.c	2007-09-28 15:54:13.000000000 +0100
@@ -1363,7 +1363,7 @@ unsigned long try_to_free_mem_cgroup_pag
 	struct zonelist *zonelist;
 
 	for_each_online_node(node) {
-		zonelist = &NODE_DATA(node)->node_zonelists[0];
+		zonelist = &NODE_DATA(node)->node_zonelist;
 		if (do_try_to_free_pages(zonelist, sc.gfp_mask, &sc))
 			return 1;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
