From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070809210716.14702.43074.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Date: Thu,  9 Aug 2007 22:07:16 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Using one zonelist per node requires very frequent use of zone_idx(). This
is costly as it involves a lookup of another structure and a substraction
operation. struct zone is aligned on a node-interleave boundary so the
pointer values of plenty of 0's at the least significant bits of the address.

This patch embeds the zone_id of a zone in the zonelist->zones pointers.
The real zone pointer is found using the zonelist_zone() helper function.
The ID of the zone is found using zonelist_zone_idx().  To avoid accidental
references, the zones field is renamed to _zones.
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/mmzone.h |   59 ++++++++++++++++++++++++++++++++++++++++----
 mm/mempolicy.c         |   22 ++++++++--------
 mm/page_alloc.c        |   36 +++++++++++++-------------
 mm/vmstat.c            |    4 +-
 4 files changed, 85 insertions(+), 36 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-010_use_zonelist/include/linux/mmzone.h linux-2.6.23-rc1-mm2-015_zoneid_zonelist/include/linux/mmzone.h
--- linux-2.6.23-rc1-mm2-010_use_zonelist/include/linux/mmzone.h	2007-08-09 15:08:15.000000000 +0100
+++ linux-2.6.23-rc1-mm2-015_zoneid_zonelist/include/linux/mmzone.h	2007-08-09 18:00:41.000000000 +0100
@@ -436,7 +436,9 @@ struct zonelist_cache;
 
 struct zonelist {
 	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
-	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
+	struct zone *_zones[MAX_ZONES_PER_ZONELIST + 1];     // NULL delimited
+							     // Access with
+							     // zonelist_zone()
 #ifdef CONFIG_NUMA
 	struct zonelist_cache zlcache;			     // optional ...
 #endif
@@ -676,12 +678,57 @@ static inline struct zonelist *node_zone
 	return &NODE_DATA(nid)->node_zonelist;
 }
 
+#if defined(CONFIG_SMP) && INTERNODE_CACHE_SHIFT > ZONES_SHIFT
+
+/* Similar to ZONES_MASK but is not available in this context */
+#define ZONELIST_ZONEIDX_MASK ((1UL << ZONES_SHIFT) - 1)
+
+/* zone_id is small enough to fit at bottom of zone pointer in zonelist */
+static inline struct zone *zonelist_zone(struct zone *zone)
+{
+	return (struct zone *)((unsigned long)zone & ~ZONELIST_ZONEIDX_MASK);
+}
+
+
+static inline int zonelist_zone_idx(struct zone *zone)
+{
+	/* ZONES_MASK not available in this context */
+	return (unsigned long)zone & ZONELIST_ZONEIDX_MASK;
+}
+
+static inline struct zone *encode_zone_idx(struct zone *zone)
+{
+	struct zone *encoded;
+
+	encoded = (struct zone *)((unsigned long)zone | zone_idx(zone));
+	BUG_ON(zonelist_zone(encoded) != zone);
+	return encoded;
+}
+#else
+static inline struct zone *zonelist_zone(struct zone *zone)
+{
+	return zone;
+}
+
+static inline int zonelist_zone_idx(struct zone *zone)
+{
+	return zone_idx(zone);
+}
+
+static inline struct zone *encode_zone_idx(struct zone *zone)
+{
+	return zone;
+}
+#endif
+
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
 static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx)
 {
 	struct zone **z;
-	for (z = zonelist->zones; *z && zone_idx(*z) > highest_zoneidx; z++);
+	for (z = zonelist->_zones;
+		*z && zonelist_zone_idx(*z) > highest_zoneidx;
+		z++);
 	return z;
 }
 
@@ -689,7 +736,9 @@ static inline struct zone **first_zones_
 static inline struct zone **next_zones_zonelist(struct zone **z,
 					enum zone_type highest_zoneidx)
 {
-	for (++z; *z && zone_idx(*z) > highest_zoneidx; z++);
+	for (++z;
+		*z && zonelist_zone_idx(*z) > highest_zoneidx;
+		z++);
 	return z;
 }
 
@@ -703,9 +752,9 @@ static inline struct zone **next_zones_z
  * This iterator iterates though all zones at or below a given zone index.
  */
 #define for_each_zone_zonelist(zone, z, zlist, highidx) \
-	for (z = first_zones_zonelist(zlist, highidx), zone = *z;	\
+	for (z = first_zones_zonelist(zlist, highidx), zone = zonelist_zone(*z);	\
 		zone;							\
-		z = next_zones_zonelist(z, highidx), zone = *z)
+		z = next_zones_zonelist(z, highidx), zone = zonelist_zone(*z))
 
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-010_use_zonelist/mm/mempolicy.c linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/mempolicy.c
--- linux-2.6.23-rc1-mm2-010_use_zonelist/mm/mempolicy.c	2007-08-09 18:34:00.000000000 +0100
+++ linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/mempolicy.c	2007-08-09 18:33:51.000000000 +0100
@@ -156,7 +156,7 @@ static struct zonelist *bind_zonelist(no
 		for_each_node_mask(nd, *nodes) { 
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];
 			if (z->present_pages > 0) 
-				zl->zones[num++] = z;
+				zl->_zones[num++] = encode_zone_idx(z);
 		}
 		if (k == 0)
 			break;
@@ -166,7 +166,7 @@ static struct zonelist *bind_zonelist(no
 		kfree(zl);
 		return ERR_PTR(-EINVAL);
 	}
-	zl->zones[num] = NULL;
+	zl->_zones[num] = NULL;
 	return zl;
 }
 
@@ -486,8 +486,8 @@ static void get_zonemask(struct mempolic
 	nodes_clear(*nodes);
 	switch (p->policy) {
 	case MPOL_BIND:
-		for (i = 0; p->v.zonelist->zones[i]; i++)
-			node_set(zone_to_nid(p->v.zonelist->zones[i]),
+		for (i = 0; p->v.zonelist->_zones[i]; i++)
+			node_set(zone_to_nid(zonelist_zone(p->v.zonelist->_zones[i])),
 				*nodes);
 		break;
 	case MPOL_DEFAULT:
@@ -1154,7 +1154,7 @@ unsigned slab_node(struct mempolicy *pol
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return zone_to_nid(policy->v.zonelist->zones[0]);
+		return zone_to_nid(zonelist_zone(policy->v.zonelist->_zones[0]));
 
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
@@ -1232,7 +1232,7 @@ static struct page *alloc_page_interleav
 
 	zl = node_zonelist(nid);
 	page = __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) == zl->zones[0])
+	if (page && page_zone(page) == zonelist_zone(zl->_zones[0]))
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
 	return page;
 }
@@ -1356,10 +1356,10 @@ int __mpol_equal(struct mempolicy *a, st
 		return a->v.preferred_node == b->v.preferred_node;
 	case MPOL_BIND: {
 		int i;
-		for (i = 0; a->v.zonelist->zones[i]; i++)
-			if (a->v.zonelist->zones[i] != b->v.zonelist->zones[i])
+		for (i = 0; a->v.zonelist->_zones[i]; i++)
+			if (zonelist_zone(a->v.zonelist->_zones[i]) != zonelist_zone(b->v.zonelist->_zones[i]))
 				return 0;
-		return b->v.zonelist->zones[i] == NULL;
+		return b->v.zonelist->_zones[i] == NULL;
 	}
 	default:
 		BUG();
@@ -1682,8 +1682,8 @@ static void mpol_rebind_policy(struct me
 		struct zonelist *zonelist;
 
 		nodes_clear(nodes);
-		for (z = pol->v.zonelist->zones; *z; z++)
-			node_set(zone_to_nid(*z), nodes);
+		for (z = pol->v.zonelist->_zones; *z; z++)
+			node_set(zone_to_nid(zonelist_zone(*z)), nodes);
 		nodes_remap(tmp, nodes, *mpolmask, *newmask);
 		nodes = tmp;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-010_use_zonelist/mm/page_alloc.c linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc1-mm2-010_use_zonelist/mm/page_alloc.c	2007-08-09 15:04:19.000000000 +0100
+++ linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/page_alloc.c	2007-08-09 15:52:12.000000000 +0100
@@ -1360,7 +1360,7 @@ static int zlc_zone_worth_trying(struct 
 	if (!zlc)
 		return 1;
 
-	i = z - zonelist->zones;
+	i = z - zonelist->_zones;
 	n = zlc->z_to_n[i];
 
 	/* This zone is worth trying if it is allowed but not full */
@@ -1381,7 +1381,7 @@ static void zlc_mark_zone_full(struct zo
 	if (!zlc)
 		return;
 
-	i = z - zonelist->zones;
+	i = z - zonelist->_zones;
 
 	set_bit(i, zlc->fullzones);
 }
@@ -1414,7 +1414,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 {
 	struct zone **z;
 	struct page *page = NULL;
-	int classzone_idx = zone_idx(zonelist->zones[0]);
+	int classzone_idx = zonelist_zone_idx(zonelist->_zones[0]);
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
@@ -1431,7 +1431,7 @@ zonelist_scan:
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 		if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
-			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
+			zone->zone_pgdat != zonelist_zone(zonelist->_zones[0])->zone_pgdat))
 				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
@@ -1554,9 +1554,9 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 		return NULL;
 
 restart:
-	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
+	z = zonelist->_zones;  /* the list of zones suitable for gfp_mask */
 
-	if (unlikely(*z == NULL)) {
+	if (unlikely(zonelist_zone(*z) == NULL)) {
 		/* Should this ever happen?? */
 		return NULL;
 	}
@@ -1577,8 +1577,8 @@ restart:
 	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
-	for (z = zonelist->zones; *z; z++)
-		wakeup_kswapd(*z, order);
+	for (z = zonelist->_zones; *z; z++)
+		wakeup_kswapd(zonelist_zone(*z), order);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -1974,7 +1974,7 @@ static int build_zonelists_node(pg_data_
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
 		if (populated_zone(zone)) {
-			zonelist->zones[nr_zones++] = zone;
+			zonelist->_zones[nr_zones++] = encode_zone_idx(zone);
 			check_highest_zone(zone_type);
 		}
 
@@ -2150,10 +2150,10 @@ static void build_zonelists_in_node_orde
 	struct zonelist *zonelist;
 
 	zonelist = &pgdat->node_zonelist;
-	for (j = 0; zonelist->zones[j] != NULL; j++)
+	for (j = 0; zonelist->_zones[j] != NULL; j++)
 		;
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j, MAX_NR_ZONES-1);
-	zonelist->zones[j] = NULL;
+	zonelist->_zones[j] = NULL;
 }
 
 /*
@@ -2178,12 +2178,12 @@ static void build_zonelists_in_zone_orde
 			node = node_order[j];
 			z = &NODE_DATA(node)->node_zones[zone_type];
 			if (populated_zone(z)) {
-				zonelist->zones[pos++] = z;
+				zonelist->_zones[pos++] = encode_zone_idx(z);
 				check_highest_zone(zone_type);
 			}
 		}
 	}
-	zonelist->zones[pos] = NULL;
+	zonelist->_zones[pos] = NULL;
 }
 
 static int default_zonelist_order(void)
@@ -2257,7 +2257,7 @@ static void build_zonelists(pg_data_t *p
 
 	/* initialize zonelist */
 	zonelist = &pgdat->node_zonelist;
-	zonelist->zones[0] = NULL;
+	zonelist->_zones[0] = NULL;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -2304,7 +2304,6 @@ static void build_zonelists(pg_data_t *p
 /* Construct the zonelist performance cache - see further mmzone.h */
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
-	int i;
 	struct zonelist *zonelist;
 	struct zonelist_cache *zlc;
 	struct zone **z;
@@ -2312,8 +2311,9 @@ static void build_zonelist_cache(pg_data
 	zonelist = &pgdat->node_zonelist;
 	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-	for (z = zonelist->zones; *z; z++)
-		zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
+	for (z = zonelist->_zones; *z; z++)
+		zlc->z_to_n[z - zonelist->_zones] =
+			zone_to_nid(zonelist_zone(*z));
 }
 
 
@@ -2356,7 +2356,7 @@ static void build_zonelists(pg_data_t *p
 								MAX_NR_ZONES-1);
 	}
 
-	zonelist->zones[j] = NULL;
+	zonelist->_zones[j] = NULL;
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc1-mm2-010_use_zonelist/mm/vmstat.c linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/vmstat.c
--- linux-2.6.23-rc1-mm2-010_use_zonelist/mm/vmstat.c	2007-08-07 14:45:11.000000000 +0100
+++ linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/vmstat.c	2007-08-09 15:52:12.000000000 +0100
@@ -365,11 +365,11 @@ void refresh_cpu_vm_stats(int cpu)
  */
 void zone_statistics(struct zonelist *zonelist, struct zone *z)
 {
-	if (z->zone_pgdat == zonelist->zones[0]->zone_pgdat) {
+	if (z->zone_pgdat == zonelist_zone(zonelist->_zones[0])->zone_pgdat) {
 		__inc_zone_state(z, NUMA_HIT);
 	} else {
 		__inc_zone_state(z, NUMA_MISS);
-		__inc_zone_state(zonelist->zones[0], NUMA_FOREIGN);
+		__inc_zone_state(zonelist_zone(zonelist->_zones[0]), NUMA_FOREIGN);
 	}
 	if (z->node == numa_node_id())
 		__inc_zone_state(z, NUMA_LOCAL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
