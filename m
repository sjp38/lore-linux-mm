From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070831205319.22283.45590.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070831205139.22283.71284.sendpatchset@skynet.skynet.ie>
References: <20070831205139.22283.71284.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 5/6] Use one zonelist that is filtered by nodemask
Date: Fri, 31 Aug 2007 21:53:19 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Two zonelists exist so that GFP_THISNODE allocations will be guaranteed to use
memory only from a node local to the CPU. As we can filter the zonelist based
on a nodemask, we can filter the node slightly different when GFP_THISNODE
is specified.

When GFP_THISNODE is used, a temporary nodemask is created with only the
node local to the CPU set. This eliminates the need for having two zonelists.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 drivers/char/sysrq.c      |    2 -
 fs/buffer.c               |    5 +--
 include/linux/gfp.h       |   23 +++-------------
 include/linux/mempolicy.h |    2 -
 include/linux/mmzone.h    |   14 ----------
 mm/mempolicy.c            |    8 ++---
 mm/page_alloc.c           |   57 +++++++++++++++++++++--------------------
 mm/slab.c                 |    2 -
 mm/slub.c                 |    2 -
 9 files changed, 46 insertions(+), 69 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/drivers/char/sysrq.c linux-2.6.23-rc3-mm1-040_use_one_zonelist/drivers/char/sysrq.c
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/drivers/char/sysrq.c	2007-08-31 16:54:56.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/drivers/char/sysrq.c	2007-08-31 17:22:55.000000000 +0100
@@ -270,7 +270,7 @@ static struct sysrq_key_op sysrq_term_op
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
+	out_of_memory(node_zonelist(0), GFP_KERNEL, 0);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/fs/buffer.c linux-2.6.23-rc3-mm1-040_use_one_zonelist/fs/buffer.c
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/fs/buffer.c	2007-08-31 16:55:36.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/fs/buffer.c	2007-08-31 17:22:55.000000000 +0100
@@ -375,11 +375,10 @@ static void free_more_memory(void)
 	yield();
 
 	for_each_online_node(nid) {
-		zones = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
+		zones = first_zones_zonelist(node_zonelist(nid),
 			NULL, gfp_zone(GFP_NOFS));
 		if (*zones)
-			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-								GFP_NOFS);
+			try_to_free_pages(node_zonelist(nid), 0, GFP_NOFS);
 	}
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/include/linux/gfp.h linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/gfp.h
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/include/linux/gfp.h	2007-08-31 16:55:36.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/gfp.h	2007-08-31 17:22:55.000000000 +0100
@@ -150,29 +150,16 @@ static inline gfp_t set_migrateflags(gfp
  * virtual kernel addresses to the allocated page(s).
  */
 
-static inline enum zone_type gfp_zonelist(gfp_t flags)
-{
-	int base = 0;
-
-#ifdef CONFIG_NUMA
-	if (flags & __GFP_THISNODE)
-		base = 1;
-#endif
-
-	return base;
-}
-
 /*
- * We get the zone list from the current node and the gfp_mask.
- * This zonelist contains two zonelists, one for all zones with memory and
- * one containing just zones from the node the zonelist belongs to
+ * We get the zone list from the current node and the list of zones
+ * is filtered based on the GFP flags
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
@@ -199,7 +186,7 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+	return __alloc_pages(gfp_mask, order, node_zonelist(nid));
 }
 
 #ifdef CONFIG_NUMA
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/include/linux/mempolicy.h linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/mempolicy.h
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/include/linux/mempolicy.h	2007-08-31 16:55:36.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/mempolicy.h	2007-08-31 17:22:55.000000000 +0100
@@ -239,7 +239,7 @@ static inline void mpol_fix_fork_child_f
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 		unsigned long addr, gfp_t gfp_flags)
 {
-	return node_zonelist(0, gfp_flags);
+	return node_zonelist(0);
 }
 
 static inline int do_migrate_pages(struct mm_struct *mm,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/include/linux/mmzone.h linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/mmzone.h
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/include/linux/mmzone.h	2007-08-31 18:07:32.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/include/linux/mmzone.h	2007-08-31 18:06:59.000000000 +0100
@@ -356,17 +356,6 @@ struct zone {
 #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
 
 #ifdef CONFIG_NUMA
-
-/*
- * The NUMA zonelists are doubled becausse we need zonelists that restrict the
- * allocations to a single node for GFP_THISNODE.
- *
- * [0]	: Zonelists with fallback
- * [1]	: No fallback (GFP_THISNODE)
- */
-#define MAX_ZONELISTS (2)
-
-
 /*
  * We cache key information from each zonelist for smaller cache
  * footprint when scanning for free pages in get_page_from_freelist().
@@ -432,7 +421,6 @@ struct zonelist_cache {
 	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
 };
 #else
-#define MAX_ZONELISTS 1
 struct zonelist_cache;
 #endif
 
@@ -488,7 +476,7 @@ extern struct page *mem_map;
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
-	struct zonelist node_zonelists[MAX_ZONELISTS];
+	struct zonelist node_zonelist;
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/mm/mempolicy.c linux-2.6.23-rc3-mm1-040_use_one_zonelist/mm/mempolicy.c
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/mm/mempolicy.c	2007-08-31 16:55:36.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/mm/mempolicy.c	2007-08-31 17:22:55.000000000 +0100
@@ -1109,7 +1109,7 @@ static struct zonelist *zonelist_policy(
 		nd = 0;
 		BUG();
 	}
-	return node_zonelist(nd, gfp);
+	return node_zonelist(nd);
 }
 
 /* Do dynamic interleaving for a process */
@@ -1146,7 +1146,7 @@ unsigned slab_node(struct mempolicy *pol
 		struct zonelist *zonelist;
 		unsigned long *z;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
-		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
+		zonelist = &NODE_DATA(numa_node_id())->node_zonelist;
 		z = first_zones_zonelist(zonelist, &policy->v.nodes,
 							highest_zoneidx);
 		return zone_to_nid(zonelist_zone(*z));
@@ -1212,7 +1212,7 @@ struct zonelist *huge_zonelist(struct vm
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		return node_zonelist(nid, gfp_flags);
+		return node_zonelist(nid);
 	}
 	return zonelist_policy(GFP_HIGHUSER, pol);
 }
@@ -1226,7 +1226,7 @@ static struct page *alloc_page_interleav
 	struct zonelist *zl;
 	struct page *page;
 
-	zl = node_zonelist(nid, gfp);
+	zl = node_zonelist(nid);
 	page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zonelist_zone(zl->_zones[0]))
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/mm/page_alloc.c linux-2.6.23-rc3-mm1-040_use_one_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/mm/page_alloc.c	2007-08-31 16:55:36.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/mm/page_alloc.c	2007-08-31 17:22:55.000000000 +0100
@@ -1728,10 +1728,29 @@ got_pg:
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
+	/* Use a temporary nodemask for __GFP_THISNODE allocations */
+	if (unlikely(gfp_mask & __GFP_THISNODE)) {
+		nodemask_t nodemask;
+
+		return __alloc_pages_internal(gfp_mask, order,
+				zonelist, nodemask_thisnode(&nodemask));
+	}
+
 	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
 }
 
@@ -1739,6 +1758,9 @@ struct page * fastcall
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist, nodemask_t *nodemask)
 {
+	/* Specifying both __GFP_THISNODE and nodemask is stupid. Warn user */
+	WARN_ON(gfp_mask & __GFP_THISNODE);
+
 	return __alloc_pages_internal(gfp_mask, order, zonelist, nodemask);
 }
 
@@ -1814,7 +1836,7 @@ static unsigned int nr_free_zone_pages(i
 
 	/* Just pick one node, since fallback list is circular */
 	unsigned int sum = 0;
-	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
+	struct zonelist *zonelist = node_zonelist(numa_node_id());
 
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		unsigned long size = zone->present_pages;
@@ -2187,7 +2209,7 @@ static void build_zonelists_in_node_orde
 	int j;
 	struct zonelist *zonelist;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelist;
 	for (j = 0; zonelist->_zones[j] != 0; j++)
 		;
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j,
@@ -2196,19 +2218,6 @@ static void build_zonelists_in_node_orde
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
-	zonelist->_zones[j] = 0;
-}
-
-/*
  * Build zonelists ordered by zone and nodes within zones.
  * This results in conserving DMA zone[s] until all Normal memory is
  * exhausted, but results in overflowing to remote node while memory
@@ -2223,7 +2232,7 @@ static void build_zonelists_in_zone_orde
 	struct zone *z;
 	struct zonelist *zonelist;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelist;
 	pos = 0;
 	for (zone_type = MAX_NR_ZONES - 1; zone_type >= 0; zone_type--) {
 		for (j = 0; j < nr_nodes; j++) {
@@ -2303,17 +2312,14 @@ static void set_zonelist_order(void)
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
-		zonelist->_zones[0] = 0;
-	}
+	zonelist = &pgdat->node_zonelist;
+	zonelist->_zones[0] = 0;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -2355,8 +2361,6 @@ static void build_zonelists(pg_data_t *p
 		/* calculate node order -- i.e., DMA last! */
 		build_zonelists_in_zone_order(pgdat, j);
 	}
-
-	build_thisnode_zonelists(pgdat);
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */
@@ -2366,7 +2370,7 @@ static void build_zonelist_cache(pg_data
 	struct zonelist_cache *zlc;
 	unsigned long *z;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelist;
 	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
 	for (z = zonelist->_zones; *z; z++)
@@ -2390,7 +2394,7 @@ static void build_zonelists(pg_data_t *p
 
 	local_node = pgdat->node_id;
 
-	zonelist = &pgdat->node_zonelists[0];
+	zonelist = &pgdat->node_zonelist;
 	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
 
 	/*
@@ -2420,8 +2424,7 @@ static void build_zonelists(pg_data_t *p
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
-	pgdat->node_zonelists[0].zlcache_ptr = NULL;
-	pgdat->node_zonelists[1].zlcache_ptr = NULL;
+	pgdat->node_zonelist.zlcache_ptr = NULL;
 }
 
 #endif	/* CONFIG_NUMA */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/mm/slab.c linux-2.6.23-rc3-mm1-040_use_one_zonelist/mm/slab.c
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/mm/slab.c	2007-08-31 16:55:11.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/mm/slab.c	2007-08-31 17:22:55.000000000 +0100
@@ -3250,7 +3250,7 @@ static void *fallback_alloc(struct kmem_
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	zonelist = node_zonelist(slab_node(current->mempolicy));
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 retry:
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-mm1-030_filter_nodemask/mm/slub.c linux-2.6.23-rc3-mm1-040_use_one_zonelist/mm/slub.c
--- linux-2.6.23-rc3-mm1-030_filter_nodemask/mm/slub.c	2007-08-31 16:55:11.000000000 +0100
+++ linux-2.6.23-rc3-mm1-040_use_one_zonelist/mm/slub.c	2007-08-31 17:22:55.000000000 +0100
@@ -1312,7 +1312,7 @@ static struct page *get_any_partial(stru
 	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
 		return NULL;
 
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	zonelist = node_zonelist(slab_node(current->mempolicy));
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
