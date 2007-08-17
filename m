From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070817201748.14792.37660.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/6] Embed zone_id information within the zonelist->zones pointer
Date: Fri, 17 Aug 2007 21:17:48 +0100 (IST)
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

 arch/parisc/mm/init.c  |    2 -
 fs/buffer.c            |    2 -
 include/linux/mmzone.h |   74 ++++++++++++++++++++++++++++++++++++++------
 kernel/cpuset.c        |    4 +-
 mm/hugetlb.c           |    3 +
 mm/mempolicy.c         |   32 +++++++++++--------
 mm/oom_kill.c          |    2 -
 mm/page_alloc.c        |   51 +++++++++++++++---------------
 mm/slab.c              |    2 -
 mm/slub.c              |    2 -
 mm/vmscan.c            |    4 +-
 mm/vmstat.c            |    5 +-
 12 files changed, 124 insertions(+), 59 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/arch/parisc/mm/init.c linux-2.6.23-rc3-015_zoneid_zonelist/arch/parisc/mm/init.c
--- linux-2.6.23-rc3-010_use_zonelist/arch/parisc/mm/init.c	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/arch/parisc/mm/init.c	2007-08-17 16:36:04.000000000 +0100
@@ -604,7 +604,7 @@ void show_mem(void)
 		for (i = 0; i < npmem_ranges; i++) {
 			zl = node_zonelist(i);
 			for (j = 0; j < MAX_NR_ZONES; j++) {
-				struct zone **z;
+				unsigned long *z;
 				struct zone *zone;
 
 				printk("Zone list for zone %d on node %d: ", j, i);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/fs/buffer.c linux-2.6.23-rc3-015_zoneid_zonelist/fs/buffer.c
--- linux-2.6.23-rc3-010_use_zonelist/fs/buffer.c	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/fs/buffer.c	2007-08-17 16:36:04.000000000 +0100
@@ -347,7 +347,7 @@ void invalidate_bdev(struct block_device
  */
 static void free_more_memory(void)
 {
-	struct zone **zones;
+	unsigned long *zones;
 	int nid;
 
 	wakeup_pdflush(1024);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/include/linux/mmzone.h linux-2.6.23-rc3-015_zoneid_zonelist/include/linux/mmzone.h
--- linux-2.6.23-rc3-010_use_zonelist/include/linux/mmzone.h	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/include/linux/mmzone.h	2007-08-17 16:52:13.000000000 +0100
@@ -404,7 +404,10 @@ struct zonelist_cache;
 
 struct zonelist {
 	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
-	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
+	unsigned long _zones[MAX_ZONES_PER_ZONELIST + 1];    /* Encoded pointer,
+							      * 0 delimited, use
+							      * zonelist_zone()
+							      */
 #ifdef CONFIG_NUMA
 	struct zonelist_cache zlcache;			     // optional ...
 #endif
@@ -637,6 +640,55 @@ extern struct zone *next_zone(struct zon
 	     zone;					\
 	     zone = next_zone(zone))
 
+
+/*
+ * SMP will align zones to a large boundary so the zone ID will fit in the
+ * least significant biuts. Otherwise, ZONES_SHIFT must be 2 or less to
+ * fit
+ */
+#if (defined(CONFIG_SMP) && INTERNODE_CACHE_SHIFT > ZONES_SHIFT) || \
+	ZONES_SHIFT <= 2
+
+/* Similar to ZONES_MASK but is not available in this context */
+#define ZONELIST_ZONEIDX_MASK ((1UL << ZONES_SHIFT) - 1)
+
+/* zone_id is small enough to fit at bottom of zone pointer in zonelist */
+static inline struct zone *zonelist_zone(unsigned long zone_addr)
+{
+	return (struct zone *)(zone_addr & ~ZONELIST_ZONEIDX_MASK);
+}
+
+static inline int zonelist_zone_idx(unsigned long zone_addr)
+{
+	/* ZONES_MASK not available in this context */
+	return zone_addr & ZONELIST_ZONEIDX_MASK;
+}
+
+static inline unsigned long encode_zone_idx(struct zone *zone)
+{
+	unsigned long encoded;
+
+	encoded = (unsigned long)zone | zone_idx(zone);
+	BUG_ON(zonelist_zone(encoded) != zone);
+	return encoded;
+}
+#else
+static inline struct zone *zonelist_zone(unsigned long zone_addr)
+{
+	return (struct zone *)zone_addr;
+}
+
+static inline int zonelist_zone_idx(unsigned long zone_addr)
+{
+	return zone_idx((struct zone *)zone_addr);
+}
+
+static inline struct zone *encode_zone_idx(struct zone *zone)
+{
+	return (unsigned long)zone;
+}
+#endif
+
 /* Return the zonelist belonging to a node of a given ID */
 static inline struct zonelist *node_zonelist(int nid)
 {
@@ -644,19 +696,23 @@ static inline struct zonelist *node_zone
 }
 
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
-static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
+static inline unsigned long *first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx)
 {
-	struct zone **z;
-	for (z = zonelist->zones; zone_idx(*z) > highest_zoneidx; z++);
+	unsigned long *z;
+	for (z = zonelist->_zones;
+		zonelist_zone_idx(*z) > highest_zoneidx;
+		z++);
 	return z;
 }
 
 /* Returns the next zone at or below highest_zoneidx in a zonelist */
-static inline struct zone **next_zones_zonelist(struct zone **z,
+static inline unsigned long *next_zones_zonelist(unsigned long *z,
 					enum zone_type highest_zoneidx)
 {
-	for (++z; zone_idx(*z) > highest_zoneidx; z++);
+	for (++z;
+		zonelist_zone_idx(*z) > highest_zoneidx;
+		z++);
 	return z;
 }
 
@@ -670,9 +726,9 @@ static inline struct zone **next_zones_z
  * This iterator iterates though all zones at or below a given zone index.
  */
 #define for_each_zone_zonelist(zone, z, zlist, highidx) \
-	for (z = first_zones_zonelist(zlist, highidx), zone = *z;	\
-		zone;							\
-		z = next_zones_zonelist(z, highidx), zone = *z)
+	for (z = first_zones_zonelist(zlist, highidx), zone = zonelist_zone(*z); \
+		zone; \
+		z = next_zones_zonelist(z, highidx), zone = zonelist_zone(*z))
 
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/kernel/cpuset.c linux-2.6.23-rc3-015_zoneid_zonelist/kernel/cpuset.c
--- linux-2.6.23-rc3-010_use_zonelist/kernel/cpuset.c	2007-08-13 05:25:24.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/kernel/cpuset.c	2007-08-17 16:36:04.000000000 +0100
@@ -2336,8 +2336,8 @@ int cpuset_zonelist_valid_mems_allowed(s
 {
 	int i;
 
-	for (i = 0; zl->zones[i]; i++) {
-		int nid = zone_to_nid(zl->zones[i]);
+	for (i = 0; zl->_zones[i]; i++) {
+		int nid = zone_to_nid(zonelist_zone(zl->_zones[i]));
 
 		if (node_isset(nid, current->mems_allowed))
 			return 1;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/mm/hugetlb.c linux-2.6.23-rc3-015_zoneid_zonelist/mm/hugetlb.c
--- linux-2.6.23-rc3-010_use_zonelist/mm/hugetlb.c	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/mm/hugetlb.c	2007-08-17 16:36:04.000000000 +0100
@@ -73,7 +73,8 @@ static struct page *dequeue_huge_page(st
 	struct page *page = NULL;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
 						htlb_alloc_mask);
-	struct zone *zone, **z;
+	struct zone *zone;
+	unsigned long *z;
 
 	for_each_zone_zonelist(zone, z, zonelist, MAX_NR_ZONES - 1) {
 		nid = zone_to_nid(zone);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/mm/mempolicy.c linux-2.6.23-rc3-015_zoneid_zonelist/mm/mempolicy.c
--- linux-2.6.23-rc3-010_use_zonelist/mm/mempolicy.c	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/mm/mempolicy.c	2007-08-17 16:54:10.000000000 +0100
@@ -154,7 +154,7 @@ static struct zonelist *bind_zonelist(no
 		for_each_node_mask(nd, *nodes) { 
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];
 			if (z->present_pages > 0) 
-				zl->zones[num++] = z;
+				zl->_zones[num++] = encode_zone_idx(z);
 		}
 		if (k == 0)
 			break;
@@ -164,7 +164,7 @@ static struct zonelist *bind_zonelist(no
 		kfree(zl);
 		return ERR_PTR(-EINVAL);
 	}
-	zl->zones[num] = NULL;
+	zl->_zones[num] = 0;
 	return zl;
 }
 
@@ -484,9 +484,11 @@ static void get_zonemask(struct mempolic
 	nodes_clear(*nodes);
 	switch (p->policy) {
 	case MPOL_BIND:
-		for (i = 0; p->v.zonelist->zones[i]; i++)
-			node_set(zone_to_nid(p->v.zonelist->zones[i]),
-				*nodes);
+		for (i = 0; p->v.zonelist->_zones[i]; i++) {
+			struct zone *zone;
+			zone = zonelist_zone(p->v.zonelist->_zones[i]);
+			node_set(zone_to_nid(zone), *nodes);
+		}
 		break;
 	case MPOL_DEFAULT:
 		break;
@@ -1150,7 +1152,7 @@ unsigned slab_node(struct mempolicy *pol
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return zone_to_nid(policy->v.zonelist->zones[0]);
+		return zone_to_nid(zonelist_zone(policy->v.zonelist->_zones[0]));
 
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
@@ -1228,7 +1230,7 @@ static struct page *alloc_page_interleav
 
 	zl = node_zonelist(nid);
 	page = __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) == zl->zones[0])
+	if (page && page_zone(page) == zonelist_zone(zl->_zones[0]))
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
 	return page;
 }
@@ -1353,10 +1355,14 @@ int __mpol_equal(struct mempolicy *a, st
 		return a->v.preferred_node == b->v.preferred_node;
 	case MPOL_BIND: {
 		int i;
-		for (i = 0; a->v.zonelist->zones[i]; i++)
-			if (a->v.zonelist->zones[i] != b->v.zonelist->zones[i])
+		for (i = 0; a->v.zonelist->_zones[i]; i++) {
+			struct zone *za, *zb;
+			za = zonelist_zone(a->v.zonelist->_zones[i]);
+			zb = zonelist_zone(b->v.zonelist->_zones[i]);
+			if (za != zb)
 				return 0;
-		return b->v.zonelist->zones[i] == NULL;
+		}
+		return b->v.zonelist->_zones[i] == 0;
 	}
 	default:
 		BUG();
@@ -1674,12 +1680,12 @@ void mpol_rebind_policy(struct mempolicy
 		break;
 	case MPOL_BIND: {
 		nodemask_t nodes;
-		struct zone **z;
+		unsigned long *z;
 		struct zonelist *zonelist;
 
 		nodes_clear(nodes);
-		for (z = pol->v.zonelist->zones; *z; z++)
-			node_set(zone_to_nid(*z), nodes);
+		for (z = pol->v.zonelist->_zones; *z; z++)
+			node_set(zone_to_nid(zonelist_zone(*z)), nodes);
 		nodes_remap(tmp, nodes, *mpolmask, *newmask);
 		nodes = tmp;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/mm/oom_kill.c linux-2.6.23-rc3-015_zoneid_zonelist/mm/oom_kill.c
--- linux-2.6.23-rc3-010_use_zonelist/mm/oom_kill.c	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/mm/oom_kill.c	2007-08-17 16:36:04.000000000 +0100
@@ -176,7 +176,7 @@ unsigned long badness(struct task_struct
 static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
 {
 #ifdef CONFIG_NUMA
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 	nodemask_t nodes;
 	int node;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/mm/page_alloc.c linux-2.6.23-rc3-015_zoneid_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc3-010_use_zonelist/mm/page_alloc.c	2007-08-17 17:02:38.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/mm/page_alloc.c	2007-08-17 16:44:24.000000000 +0100
@@ -1087,7 +1087,7 @@ static nodemask_t *zlc_setup(struct zone
  * We are low on memory in the second scan, and should leave no stone
  * unturned looking for a free page.
  */
-static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+static int zlc_zone_worth_trying(struct zonelist *zonelist, unsigned long *z,
 						nodemask_t *allowednodes)
 {
 	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
@@ -1098,7 +1098,7 @@ static int zlc_zone_worth_trying(struct 
 	if (!zlc)
 		return 1;
 
-	i = z - zonelist->zones;
+	i = z - zonelist->_zones;
 	n = zlc->z_to_n[i];
 
 	/* This zone is worth trying if it is allowed but not full */
@@ -1110,7 +1110,7 @@ static int zlc_zone_worth_trying(struct 
  * zlc->fullzones, so that subsequent attempts to allocate a page
  * from that zone don't waste time re-examining it.
  */
-static void zlc_mark_zone_full(struct zonelist *zonelist, struct zone **z)
+static void zlc_mark_zone_full(struct zonelist *zonelist, unsigned long *z)
 {
 	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
 	int i;				/* index of *z in zonelist zones */
@@ -1119,7 +1119,7 @@ static void zlc_mark_zone_full(struct zo
 	if (!zlc)
 		return;
 
-	i = z - zonelist->zones;
+	i = z - zonelist->_zones;
 
 	set_bit(i, zlc->fullzones);
 }
@@ -1131,13 +1131,13 @@ static nodemask_t *zlc_setup(struct zone
 	return NULL;
 }
 
-static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+static int zlc_zone_worth_trying(struct zonelist *zonelist, unsigned long *z,
 				nodemask_t *allowednodes)
 {
 	return 1;
 }
 
-static void zlc_mark_zone_full(struct zonelist *zonelist, struct zone **z)
+static void zlc_mark_zone_full(struct zonelist *zonelist, unsigned long *z)
 {
 }
 #endif	/* CONFIG_NUMA */
@@ -1150,7 +1150,7 @@ static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
 {
-	struct zone **z;
+	unsigned long *z;
 	struct page *page = NULL;
 	struct zone *classzone;
 	int classzone_idx;
@@ -1160,8 +1160,8 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
 	z = first_zones_zonelist(zonelist, high_zoneidx);
-	classzone = *z;
-	classzone_idx = zone_idx(*z);
+	classzone = zonelist_zone(*z);
+	classzone_idx = zonelist_zone_idx(*z);
 
 zonelist_scan:
 	/*
@@ -1227,7 +1227,7 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	struct zone **z;
+	unsigned long *z;
 	struct page *page;
 	struct reclaim_state reclaim_state;
 	struct task_struct *p = current;
@@ -1241,9 +1241,9 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 		return NULL;
 
 restart:
-	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
+	z = zonelist->_zones;  /* the list of zones suitable for gfp_mask */
 
-	if (unlikely(*z == NULL)) {
+	if (unlikely(zonelist_zone(*z) == NULL)) {
 		/* Should this ever happen?? */
 		return NULL;
 	}
@@ -1264,8 +1264,8 @@ restart:
 	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
-	for (z = zonelist->zones; *z; z++)
-		wakeup_kswapd(*z, order);
+	for (z = zonelist->_zones; *z; z++)
+		wakeup_kswapd(zonelist_zone(*z), order);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -1461,7 +1461,7 @@ EXPORT_SYMBOL(free_pages);
 static unsigned int nr_free_zone_pages(int offset)
 {
 	enum zone_type high_zoneidx = MAX_NR_ZONES - 1;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 
 	/* Just pick one node, since fallback list is circular */
@@ -1655,7 +1655,7 @@ static int build_zonelists_node(pg_data_
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
 		if (populated_zone(zone)) {
-			zonelist->zones[nr_zones++] = zone;
+			zonelist->_zones[nr_zones++] = encode_zone_idx(zone);
 			check_highest_zone(zone_type);
 		}
 
@@ -1831,10 +1831,10 @@ static void build_zonelists_in_node_orde
 	struct zonelist *zonelist;
 
 	zonelist = &pgdat->node_zonelist;
-	for (j = 0; zonelist->zones[j] != NULL; j++)
+	for (j = 0; zonelist->_zones[j] != 0; j++)
 		;
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j, MAX_NR_ZONES-1);
-	zonelist->zones[j] = NULL;
+	zonelist->_zones[j] = 0;
 }
 
 /*
@@ -1859,12 +1859,12 @@ static void build_zonelists_in_zone_orde
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
+	zonelist->_zones[pos] = 0;
 }
 
 static int default_zonelist_order(void)
@@ -1938,7 +1938,7 @@ static void build_zonelists(pg_data_t *p
 
 	/* initialize zonelist */
 	zonelist = &pgdat->node_zonelist;
-	zonelist->zones[0] = NULL;
+	zonelist->_zones[0] = 0;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -1987,13 +1987,14 @@ static void build_zonelist_cache(pg_data
 {
 	struct zonelist *zonelist;
 	struct zonelist_cache *zlc;
-	struct zone **z;
+	unsigned long *z;
 
 	zonelist = &pgdat->node_zonelist;
 	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-	for (z = zonelist->zones; *z; z++)
-		zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
+	for (z = zonelist->_zones; *z; z++)
+		zlc->z_to_n[z - zonelist->_zones] =
+			zone_to_nid(zonelist_zone(*z));
 }
 
 
@@ -2036,7 +2037,7 @@ static void build_zonelists(pg_data_t *p
 								MAX_NR_ZONES-1);
 	}
 
-	zonelist->zones[j] = NULL;
+	zonelist->_zones[j] = 0;
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/mm/slab.c linux-2.6.23-rc3-015_zoneid_zonelist/mm/slab.c
--- linux-2.6.23-rc3-010_use_zonelist/mm/slab.c	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/mm/slab.c	2007-08-17 16:36:04.000000000 +0100
@@ -3213,7 +3213,7 @@ static void *fallback_alloc(struct kmem_
 {
 	struct zonelist *zonelist;
 	gfp_t local_flags;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/mm/slub.c linux-2.6.23-rc3-015_zoneid_zonelist/mm/slub.c
--- linux-2.6.23-rc3-010_use_zonelist/mm/slub.c	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/mm/slub.c	2007-08-17 16:36:04.000000000 +0100
@@ -1275,7 +1275,7 @@ static struct page *get_any_partial(stru
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	struct page *page;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/mm/vmscan.c linux-2.6.23-rc3-015_zoneid_zonelist/mm/vmscan.c
--- linux-2.6.23-rc3-010_use_zonelist/mm/vmscan.c	2007-08-17 16:35:55.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/mm/vmscan.c	2007-08-17 16:36:04.000000000 +0100
@@ -1079,7 +1079,7 @@ static unsigned long shrink_zones(int pr
 					struct scan_control *sc)
 {
 	unsigned long nr_reclaimed = 0;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
@@ -1124,7 +1124,7 @@ unsigned long try_to_free_pages(struct z
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct scan_control sc = {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-010_use_zonelist/mm/vmstat.c linux-2.6.23-rc3-015_zoneid_zonelist/mm/vmstat.c
--- linux-2.6.23-rc3-010_use_zonelist/mm/vmstat.c	2007-08-13 05:25:24.000000000 +0100
+++ linux-2.6.23-rc3-015_zoneid_zonelist/mm/vmstat.c	2007-08-17 16:52:54.000000000 +0100
@@ -381,11 +381,12 @@ EXPORT_SYMBOL(refresh_vm_stats);
  */
 void zone_statistics(struct zonelist *zonelist, struct zone *z)
 {
-	if (z->zone_pgdat == zonelist->zones[0]->zone_pgdat) {
+	if (z->zone_pgdat == zonelist_zone(zonelist->_zones[0])->zone_pgdat) {
 		__inc_zone_state(z, NUMA_HIT);
 	} else {
 		__inc_zone_state(z, NUMA_MISS);
-		__inc_zone_state(zonelist->zones[0], NUMA_FOREIGN);
+		__inc_zone_state(zonelist_zone(zonelist->_zones[0]),
+								NUMA_FOREIGN);
 	}
 	if (z->node == numa_node_id())
 		__inc_zone_state(z, NUMA_LOCAL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
