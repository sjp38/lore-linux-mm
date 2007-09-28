From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070928142446.16783.9970.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/6] Have zonelist contains structs with both a zone pointer and zone_idx
Date: Fri, 28 Sep 2007 15:24:46 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee.Schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Filtering zonelists requires very frequent use of zone_idx(). This is costly
as it involves a lookup of another structure and a substraction operation. As
the zone_idx is often required, it should be quickly accessible.  The node
idx could also be stored here if it was found that accessing zone->node is
significant which may be the case on workloads where nodemasks are heavily
used.

This patch introduces a struct zoneref to store a zone pointer and a zone
index.  The zonelist then consists of an array of this struct zonerefs which
are looked up as necessary. Helpers are given for accessing the zone index
as well as the node index.

[kamezawa.hiroyu@jp.fujitsu.com: Suggested struct zoneref instead of embedding information in pointers]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <clameter@sgi.com>
---

 arch/parisc/mm/init.c  |    2 -
 fs/buffer.c            |    6 ++--
 include/linux/mmzone.h |   64 +++++++++++++++++++++++++++++++++++++-------
 include/linux/oom.h    |    4 +-
 kernel/cpuset.c        |    4 +-
 mm/hugetlb.c           |    3 +-
 mm/mempolicy.c         |   35 ++++++++++++++----------
 mm/oom_kill.c          |   45 +++++++++++++++---------------
 mm/page_alloc.c        |   59 ++++++++++++++++++++--------------------
 mm/slab.c              |    2 -
 mm/slub.c              |    2 -
 mm/vmscan.c            |    7 ++--
 mm/vmstat.c            |    5 ++-
 13 files changed, 145 insertions(+), 93 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/arch/parisc/mm/init.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/arch/parisc/mm/init.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/arch/parisc/mm/init.c	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/arch/parisc/mm/init.c	2007-09-28 15:49:39.000000000 +0100
@@ -604,7 +604,7 @@ void show_mem(void)
 		for (i = 0; i < npmem_ranges; i++) {
 			zl = node_zonelist(i);
 			for (j = 0; j < MAX_NR_ZONES; j++) {
-				struct zone **z;
+				struct zoneref *z;
 				struct zone *zone;
 
 				printk("Zone list for zone %d on node %d: ", j, i);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/fs/buffer.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/fs/buffer.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/fs/buffer.c	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/fs/buffer.c	2007-09-28 15:49:39.000000000 +0100
@@ -368,16 +368,16 @@ void invalidate_bdev(struct block_device
  */
 static void free_more_memory(void)
 {
-	struct zone **zones;
+	struct zoneref *zrefs;
 	int nid;
 
 	wakeup_pdflush(1024);
 	yield();
 
 	for_each_online_node(nid) {
-		zones = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
+		zrefs = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
 						gfp_zone(GFP_NOFS));
-		if (*zones)
+		if (zrefs->zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
 						GFP_NOFS);
 	}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/include/linux/mmzone.h linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mmzone.h
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/include/linux/mmzone.h	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/mmzone.h	2007-09-28 15:49:39.000000000 +0100
@@ -471,6 +471,15 @@ struct zonelist_cache;
 #endif
 
 /*
+ * This struct contains information about a zone in a zonelist. It is stored
+ * here to avoid dereferences into large structures and lookups of tables
+ */
+struct zoneref {
+	struct zone *zone;	/* Pointer to actual zone */
+	int zone_idx;		/* zone_idx(zoneref->zone) */
+};
+
+/*
  * One allocation request operates on a zonelist. A zonelist
  * is a list of zones, the first one is the 'goal' of the
  * allocation, the other zones are fallback zones, in decreasing
@@ -478,11 +487,18 @@ struct zonelist_cache;
  *
  * If zlcache_ptr is not NULL, then it is just the address of zlcache,
  * as explained above.  If zlcache_ptr is NULL, there is no zlcache.
+ * *
+ * To speed the reading of the zonelist, the zonerefs contain the zone index
+ * of the entry being read. Helper functions to access information given
+ * a struct zoneref are
+ *
+ * zonelist_zone()	- Return the struct zone * for an entry in _zonerefs
+ * zonelist_zone_idx()	- Return the index of the zone for an entry
+ * zonelist_node_idx()	- Return the index of the node for an entry
  */
-
 struct zonelist {
 	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
-	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
+	struct zoneref _zonerefs[MAX_ZONES_PER_ZONELIST + 1];
 #ifdef CONFIG_NUMA
 	struct zonelist_cache zlcache;			     // optional ...
 #endif
@@ -716,26 +732,52 @@ extern struct zone *next_zone(struct zon
 	     zone;					\
 	     zone = next_zone(zone))
 
+static inline struct zone *zonelist_zone(struct zoneref *zoneref)
+{
+	return zoneref->zone;
+}
+
+static inline int zonelist_zone_idx(struct zoneref *zoneref)
+{
+	return zoneref->zone_idx;
+}
+
+static inline int zonelist_node_idx(struct zoneref *zoneref)
+{
+#ifdef CONFIG_NUMA
+	/* zone_to_nid not available in this context */
+	return zoneref->zone->node;
+#else
+	return 0;
+#endif /* CONFIG_NUMA */
+}
+
+static inline void encode_zoneref(struct zone *zone, struct zoneref *zoneref)
+{
+	zoneref->zone = zone;
+	zoneref->zone_idx = zone_idx(zone);
+}
+
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
-static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
+static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx)
 {
-	struct zone **z;
+	struct zoneref *z;
 
 	/* Find the first suitable zone to use for the allocation */
-	z = zonelist->zones;
-	while (*z && zone_idx(*z) > highest_zoneidx)
+	z = zonelist->_zonerefs;
+	while (zonelist_zone_idx(z) > highest_zoneidx)
 		z++;
 
 	return z;
 }
 
 /* Returns the next zone at or below highest_zoneidx in a zonelist */
-static inline struct zone **next_zones_zonelist(struct zone **z,
+static inline struct zoneref *next_zones_zonelist(struct zoneref *z,
 					enum zone_type highest_zoneidx)
 {
 	/* Find the next suitable zone to use for the allocation */
-	while (*z && zone_idx(*z) > highest_zoneidx)
+	while (zonelist_zone_idx(z) > highest_zoneidx)
 		z++;
 
 	return z;
@@ -751,9 +793,11 @@ static inline struct zone **next_zones_z
  * This iterator iterates though all zones at or below a given zone index.
  */
 #define for_each_zone_zonelist(zone, z, zlist, highidx) \
-	for (z = first_zones_zonelist(zlist, highidx), zone = *z++;	\
+	for (z = first_zones_zonelist(zlist, highidx),			\
+					zone = zonelist_zone(z++);	\
 		zone;							\
-		z = next_zones_zonelist(z, highidx), zone = *z++)
+		z = next_zones_zonelist(z, highidx),			\
+					zone = zonelist_zone(z++))
 
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/include/linux/oom.h linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/oom.h
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/include/linux/oom.h	2007-09-27 14:41:05.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/include/linux/oom.h	2007-09-28 15:49:39.000000000 +0100
@@ -23,8 +23,8 @@ enum oom_constraint {
 	CONSTRAINT_MEMORY_POLICY,
 };
 
-extern int try_set_zone_oom(struct zonelist *zonelist);
-extern void clear_zonelist_oom(struct zonelist *zonelist);
+extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
+extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
 extern int register_oom_notifier(struct notifier_block *nb);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/kernel/cpuset.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/kernel/cpuset.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/kernel/cpuset.c	2007-09-27 14:41:05.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/kernel/cpuset.c	2007-09-28 15:49:39.000000000 +0100
@@ -1525,8 +1525,8 @@ int cpuset_zonelist_valid_mems_allowed(s
 {
 	int i;
 
-	for (i = 0; zl->zones[i]; i++) {
-		int nid = zone_to_nid(zl->zones[i]);
+	for (i = 0; zl->_zonerefs[i].zone; i++) {
+		int nid = zonelist_node_idx(zl->_zonerefs[i]);
 
 		if (node_isset(nid, current->mems_allowed))
 			return 1;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/hugetlb.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/hugetlb.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/hugetlb.c	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/hugetlb.c	2007-09-28 15:49:39.000000000 +0100
@@ -74,7 +74,8 @@ static struct page *dequeue_huge_page(st
 	struct mempolicy *mpol;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
 					htlb_alloc_mask, &mpol);
-	struct zone *zone, **z;
+	struct zone *zone;
+	struct zoneref *z;
 
 	for_each_zone_zonelist(zone, z, zonelist, MAX_NR_ZONES - 1) {
 		nid = zone_to_nid(zone);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/mempolicy.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/mempolicy.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/mempolicy.c	2007-09-28 15:48:55.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/mempolicy.c	2007-09-28 15:49:39.000000000 +0100
@@ -157,7 +157,7 @@ static struct zonelist *bind_zonelist(no
 		for_each_node_mask(nd, *nodes) { 
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];
 			if (z->present_pages > 0) 
-				zl->zones[num++] = z;
+				encode_zoneref(z, &zl->_zonerefs[num++]);
 		}
 		if (k == 0)
 			break;
@@ -167,7 +167,7 @@ static struct zonelist *bind_zonelist(no
 		kfree(zl);
 		return ERR_PTR(-EINVAL);
 	}
-	zl->zones[num] = NULL;
+	zl->_zonerefs[num].zone = NULL;
 	return zl;
 }
 
@@ -489,9 +489,11 @@ static void get_zonemask(struct mempolic
 	nodes_clear(*nodes);
 	switch (p->policy) {
 	case MPOL_BIND:
-		for (i = 0; p->v.zonelist->zones[i]; i++)
-			node_set(zone_to_nid(p->v.zonelist->zones[i]),
-				*nodes);
+		for (i = 0; p->v.zonelist->_zonerefs[i].zone; i++) {
+			struct zoneref *zref;
+			zref = &p->v.zonelist->_zonerefs[i];
+			node_set(zonelist_node_idx(zref), *nodes);
+		}
 		break;
 	case MPOL_DEFAULT:
 		break;
@@ -1184,12 +1186,13 @@ unsigned slab_node(struct mempolicy *pol
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);
 
-	case MPOL_BIND:
+	case MPOL_BIND: {
 		/*
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return zone_to_nid(policy->v.zonelist->zones[0]);
+		return zonelist_node_idx(policy->v.zonelist->_zonerefs);
+	}
 
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
@@ -1293,7 +1296,7 @@ static struct page *alloc_page_interleav
 
 	zl = node_zonelist(nid, gfp);
 	page = __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) == zl->zones[0])
+	if (page && page_zone(page) == zonelist_zone(&zl->_zonerefs[0]))
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
 	return page;
 }
@@ -1430,10 +1433,14 @@ int __mpol_equal(struct mempolicy *a, st
 		return a->v.preferred_node == b->v.preferred_node;
 	case MPOL_BIND: {
 		int i;
-		for (i = 0; a->v.zonelist->zones[i]; i++)
-			if (a->v.zonelist->zones[i] != b->v.zonelist->zones[i])
+		for (i = 0; a->v.zonelist->_zonerefs[i].zone; i++) {
+			struct zone *za, *zb;
+			za = zonelist_zone(&a->v.zonelist->_zonerefs[i]);
+			zb = zonelist_zone(&b->v.zonelist->_zonerefs[i]);
+			if (za != zb)
 				return 0;
-		return b->v.zonelist->zones[i] == NULL;
+		}
+		return b->v.zonelist->_zonerefs[i].zone == NULL;
 	}
 	default:
 		BUG();
@@ -1752,12 +1759,12 @@ static void mpol_rebind_policy(struct me
 		break;
 	case MPOL_BIND: {
 		nodemask_t nodes;
-		struct zone **z;
+		struct zoneref *z;
 		struct zonelist *zonelist;
 
 		nodes_clear(nodes);
-		for (z = pol->v.zonelist->zones; *z; z++)
-			node_set(zone_to_nid(*z), nodes);
+		for (z = pol->v.zonelist->_zonerefs; z->zone; z++)
+			node_set(zonelist_node_idx(z), nodes);
 		nodes_remap(tmp, nodes, *mpolmask, *newmask);
 		nodes = tmp;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/oom_kill.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/oom_kill.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/oom_kill.c	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/oom_kill.c	2007-09-28 15:49:39.000000000 +0100
@@ -182,7 +182,7 @@ static inline enum oom_constraint constr
 {
 #ifdef CONFIG_NUMA
 	struct zone *zone;
-	struct zone **z;
+	struct zoneref *z;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	nodemask_t nodes = node_states[N_HIGH_MEMORY];
 
@@ -425,29 +425,29 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifie
  * if a parallel OOM killing is already taking place that includes a zone in
  * the zonelist.  Otherwise, locks all zones in the zonelist and returns 1.
  */
-int try_set_zone_oom(struct zonelist *zonelist)
+int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_mask)
 {
-	struct zone **z;
+	struct zoneref *z;
+	struct zone *zone;
 	int ret = 1;
 
-	z = zonelist->zones;
-
 	spin_lock(&zone_scan_mutex);
-	do {
-		if (zone_is_oom_locked(*z)) {
+	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask)) {
+		if (zone_is_oom_locked(zone)) {
 			ret = 0;
 			goto out;
 		}
-	} while (*(++z) != NULL);
+	}
+
+	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask)) {
+		/*
+		 * Lock each zone in the zonelist under zone_scan_mutex so a
+		 * parallel invocation of try_set_zone_oom() doesn't succeed
+		 * when it shouldn't.
+		 */
+		zone_set_flag(zone, ZONE_OOM_LOCKED);
+	}
 
-	/*
-	 * Lock each zone in the zonelist under zone_scan_mutex so a parallel
-	 * invocation of try_set_zone_oom() doesn't succeed when it shouldn't.
-	 */
-	z = zonelist->zones;
-	do {
-		zone_set_flag(*z, ZONE_OOM_LOCKED);
-	} while (*(++z) != NULL);
 out:
 	spin_unlock(&zone_scan_mutex);
 	return ret;
@@ -458,16 +458,15 @@ out:
  * allocation attempts with zonelists containing them may now recall the OOM
  * killer, if necessary.
  */
-void clear_zonelist_oom(struct zonelist *zonelist)
+void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
 {
-	struct zone **z;
-
-	z = zonelist->zones;
+	struct zoneref *z;
+	struct zone *zone;
 
 	spin_lock(&zone_scan_mutex);
-	do {
-		zone_clear_flag(*z, ZONE_OOM_LOCKED);
-	} while (*(++z) != NULL);
+	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask)) {
+		zone_clear_flag(zone, ZONE_OOM_LOCKED);
+	}
 	spin_unlock(&zone_scan_mutex);
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/page_alloc.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/page_alloc.c	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/page_alloc.c	2007-09-28 15:49:39.000000000 +0100
@@ -1360,7 +1360,7 @@ static nodemask_t *zlc_setup(struct zone
  * We are low on memory in the second scan, and should leave no stone
  * unturned looking for a free page.
  */
-static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zoneref *z,
 						nodemask_t *allowednodes)
 {
 	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
@@ -1371,7 +1371,7 @@ static int zlc_zone_worth_trying(struct 
 	if (!zlc)
 		return 1;
 
-	i = z - zonelist->zones;
+	i = z - zonelist->_zonerefs;
 	n = zlc->z_to_n[i];
 
 	/* This zone is worth trying if it is allowed but not full */
@@ -1383,7 +1383,7 @@ static int zlc_zone_worth_trying(struct 
  * zlc->fullzones, so that subsequent attempts to allocate a page
  * from that zone don't waste time re-examining it.
  */
-static void zlc_mark_zone_full(struct zonelist *zonelist, struct zone **z)
+static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
 {
 	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
 	int i;				/* index of *z in zonelist zones */
@@ -1392,7 +1392,7 @@ static void zlc_mark_zone_full(struct zo
 	if (!zlc)
 		return;
 
-	i = z - zonelist->zones;
+	i = z - zonelist->_zonerefs;
 
 	set_bit(i, zlc->fullzones);
 }
@@ -1404,13 +1404,13 @@ static nodemask_t *zlc_setup(struct zone
 	return NULL;
 }
 
-static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zoneref *z,
 				nodemask_t *allowednodes)
 {
 	return 1;
 }
 
-static void zlc_mark_zone_full(struct zonelist *zonelist, struct zone **z)
+static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
 {
 }
 #endif	/* CONFIG_NUMA */
@@ -1423,7 +1423,7 @@ static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
 {
-	struct zone **z;
+	struct zoneref *z;
 	struct page *page = NULL;
 	int classzone_idx;
 	struct zone *zone;
@@ -1432,7 +1432,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
 	z = first_zones_zonelist(zonelist, high_zoneidx);
-	classzone_idx = zone_idx(*z);
+	classzone_idx = zonelist_zone_idx(z);
 
 zonelist_scan:
 	/*
@@ -1551,7 +1551,8 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	struct zone **z;
+	struct zoneref *z;
+	struct zone *zone;
 	struct page *page;
 	struct reclaim_state reclaim_state;
 	struct task_struct *p = current;
@@ -1565,9 +1566,9 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 		return NULL;
 
 restart:
-	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
+	z = zonelist->_zonerefs;  /* the list of zones suitable for gfp_mask */
 
-	if (unlikely(*z == NULL)) {
+	if (unlikely(!z->zone)) {
 		/*
 		 * Happens if we have an empty zonelist as a result of
 		 * GFP_THISNODE being used on a memoryless node
@@ -1591,8 +1592,8 @@ restart:
 	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
-	for (z = zonelist->zones; *z; z++)
-		wakeup_kswapd(*z, order);
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+		wakeup_kswapd(zone, order);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -1673,7 +1674,7 @@ nofail_alloc:
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
-		if (!try_set_zone_oom(zonelist)) {
+		if (!try_set_zone_oom(zonelist, gfp_mask)) {
 			schedule_timeout_uninterruptible(1);
 			goto restart;
 		}
@@ -1687,18 +1688,18 @@ nofail_alloc:
 		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
 			zonelist, high_zoneidx, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
 		if (page) {
-			clear_zonelist_oom(zonelist);
+			clear_zonelist_oom(zonelist, gfp_mask);
 			goto got_pg;
 		}
 
 		/* The OOM killer will not help higher order allocs so fail */
 		if (order > PAGE_ALLOC_COSTLY_ORDER) {
-			clear_zonelist_oom(zonelist);
+			clear_zonelist_oom(zonelist, gfp_mask);
 			goto nopage;
 		}
 
 		out_of_memory(zonelist, gfp_mask, order);
-		clear_zonelist_oom(zonelist);
+		clear_zonelist_oom(zonelist, gfp_mask);
 		goto restart;
 	}
 
@@ -1805,7 +1806,7 @@ EXPORT_SYMBOL(free_pages);
 static unsigned int nr_free_zone_pages(int offset)
 {
 	enum zone_type high_zoneidx = MAX_NR_ZONES - 1;
-	struct zone **z;
+	struct zoneref *z;
 	struct zone *zone;
 
 	/* Just pick one node, since fallback list is circular */
@@ -2000,7 +2001,7 @@ static int build_zonelists_node(pg_data_
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
 		if (populated_zone(zone)) {
-			zonelist->zones[nr_zones++] = zone;
+			encode_zoneref(zone, &zonelist->_zonerefs[nr_zones++]);
 			check_highest_zone(zone_type);
 		}
 
@@ -2176,11 +2177,11 @@ static void build_zonelists_in_node_orde
 	struct zonelist *zonelist;
 
 	zonelist = &pgdat->node_zonelists[0];
-	for (j = 0; zonelist->zones[j] != NULL; j++)
+	for (j = 0; zonelist->_zonerefs[j].zone != NULL; j++)
 		;
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j,
 							MAX_NR_ZONES - 1);
-	zonelist->zones[j] = NULL;
+	zonelist->_zonerefs[j].zone = NULL;
 }
 
 /*
@@ -2193,7 +2194,7 @@ static void build_thisnode_zonelists(pg_
 
 	zonelist = &pgdat->node_zonelists[1];
 	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
-	zonelist->zones[j] = NULL;
+	zonelist->_zonerefs[j].zone = NULL;
 }
 
 /*
@@ -2218,12 +2219,12 @@ static void build_zonelists_in_zone_orde
 			node = node_order[j];
 			z = &NODE_DATA(node)->node_zones[zone_type];
 			if (populated_zone(z)) {
-				zonelist->zones[pos++] = z;
+				encode_zoneref(z, &zonelist->_zonerefs[pos++]);
 				check_highest_zone(zone_type);
 			}
 		}
 	}
-	zonelist->zones[pos] = NULL;
+	zonelist->_zonerefs[pos].zone = NULL;
 }
 
 static int default_zonelist_order(void)
@@ -2300,7 +2301,7 @@ static void build_zonelists(pg_data_t *p
 	/* initialize zonelists */
 	for (i = 0; i < MAX_ZONELISTS; i++) {
 		zonelist = pgdat->node_zonelists + i;
-		zonelist->zones[0] = NULL;
+		zonelist->_zonerefs[0].zone = NULL;
 	}
 
 	/* NUMA-aware ordering of nodes */
@@ -2352,13 +2353,13 @@ static void build_zonelist_cache(pg_data
 {
 	struct zonelist *zonelist;
 	struct zonelist_cache *zlc;
-	struct zone **z;
+	struct zoneref *z;
 
 	zonelist = &pgdat->node_zonelists[0];
 	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-	for (z = zonelist->zones; *z; z++)
-		zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
+	for (z = zonelist->_zonerefs; z->zone; z++)
+		zlc->z_to_n[z - zonelist->_zonerefs] = zonelist_node_idx(z);
 }
 
 
@@ -2401,7 +2402,7 @@ static void build_zonelists(pg_data_t *p
 							MAX_NR_ZONES - 1);
 	}
 
-	zonelist->zones[j] = NULL;
+	zonelist->_zonerefs[j].zone = NULL;
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/slab.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/slab.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/slab.c	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/slab.c	2007-09-28 15:49:39.000000000 +0100
@@ -3239,7 +3239,7 @@ static void *fallback_alloc(struct kmem_
 {
 	struct zonelist *zonelist;
 	gfp_t local_flags;
-	struct zone **z;
+	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/slub.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/slub.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/slub.c	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/slub.c	2007-09-28 15:49:39.000000000 +0100
@@ -1279,7 +1279,7 @@ static struct page *get_any_partial(stru
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
-	struct zone **z;
+	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	struct page *page;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/vmscan.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/vmscan.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/vmscan.c	2007-09-28 15:49:16.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/vmscan.c	2007-09-28 15:49:39.000000000 +0100
@@ -1208,7 +1208,7 @@ static unsigned long shrink_zones(int pr
 					struct scan_control *sc)
 {
 	unsigned long nr_reclaimed = 0;
-	struct zone **z;
+	struct zoneref *z;
 	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
@@ -1253,7 +1253,7 @@ static unsigned long do_try_to_free_page
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
-	struct zone **z;
+	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 
@@ -1361,10 +1361,9 @@ unsigned long try_to_free_mem_cgroup_pag
 	};
 	int node;
 	struct zonelist *zonelist;
-	int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
 
 	for_each_online_node(node) {
-		zonelist = &NODE_DATA(node)->node_zonelists[target_zone];
+		zonelist = &NODE_DATA(node)->node_zonelists[0];
 		if (do_try_to_free_pages(zonelist, sc.gfp_mask, &sc))
 			return 1;
 	}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/vmstat.c linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/vmstat.c
--- linux-2.6.23-rc8-mm2-010_use_two_zonelists/mm/vmstat.c	2007-09-27 14:41:05.000000000 +0100
+++ linux-2.6.23-rc8-mm2-020_zoneid_zonelist/mm/vmstat.c	2007-09-28 15:49:39.000000000 +0100
@@ -365,11 +365,12 @@ void refresh_cpu_vm_stats(int cpu)
  */
 void zone_statistics(struct zonelist *zonelist, struct zone *z)
 {
-	if (z->zone_pgdat == zonelist->zones[0]->zone_pgdat) {
+	if (z->zone_pgdat == zonelist_zone(&zonelist->_zonerefs[0])->zone_pgdat) {
 		__inc_zone_state(z, NUMA_HIT);
 	} else {
 		__inc_zone_state(z, NUMA_MISS);
-		__inc_zone_state(zonelist->zones[0], NUMA_FOREIGN);
+		__inc_zone_state(zonelist_zone(&zonelist->_zonerefs[0]),
+								NUMA_FOREIGN);
 	}
 	if (z->node == numa_node_id())
 		__inc_zone_state(z, NUMA_LOCAL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
