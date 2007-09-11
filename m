From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070911152059.11117.46517.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070911151939.11117.30384.sendpatchset@skynet.skynet.ie>
References: <20070911151939.11117.30384.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/6] Embed zone_id information within the zonelist->zones pointer
Date: Tue, 11 Sep 2007 16:20:59 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Using two zonelists per node requires very frequent use of zone_idx(). This
is costly as it involves a lookup of another structure and a substraction
operation. As struct zone is always word aligned and normally cache-line
aligned, the pointer values have a number of 0's at the least significant
bits of the address.

This patch embeds the zone_id of a zone in the zonelist->zones pointers.
The real zone pointer is retrieved using the zonelist_zone() helper function.
The ID of the zone is found using zonelist_zone_idx().  To avoid accidental
references, the zones field is renamed to _zones and the type changed to
unsigned long.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <clameter@sgi.com>
---

 arch/parisc/mm/init.c  |    2 -
 fs/buffer.c            |    6 ++--
 include/linux/mmzone.h |   58 ++++++++++++++++++++++++++++++++++++--------
 kernel/cpuset.c        |    4 +--
 mm/hugetlb.c           |    3 +-
 mm/mempolicy.c         |   37 +++++++++++++++++-----------
 mm/oom_kill.c          |    2 -
 mm/page_alloc.c        |   52 ++++++++++++++++++++-------------------
 mm/slab.c              |    2 -
 mm/slub.c              |    2 -
 mm/vmscan.c            |    5 +--
 mm/vmstat.c            |    5 ++-
 12 files changed, 114 insertions(+), 64 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/arch/parisc/mm/init.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/arch/parisc/mm/init.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/arch/parisc/mm/init.c	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/arch/parisc/mm/init.c	2007-09-10 16:06:31.000000000 +0100
@@ -604,7 +604,7 @@ void show_mem(void)
 		for (i = 0; i < npmem_ranges; i++) {
 			zl = node_zonelist(i);
 			for (j = 0; j < MAX_NR_ZONES; j++) {
-				struct zone **z;
+				unsigned long *z;
 				struct zone *zone;
 
 				printk("Zone list for zone %d on node %d: ", j, i);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/fs/buffer.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/fs/buffer.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/fs/buffer.c	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/fs/buffer.c	2007-09-10 16:06:31.000000000 +0100
@@ -368,7 +368,7 @@ void invalidate_bdev(struct block_device
  */
 static void free_more_memory(void)
 {
-	struct zone **zones;
+	unsigned long *zones;
 	int nid;
 
 	wakeup_pdflush(1024);
@@ -376,10 +376,10 @@ static void free_more_memory(void)
 
 	for_each_online_node(nid) {
 		zones = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
-						gfp_zone(GFP_NOFS));
+							gfp_zone(GFP_NOFS));
 		if (*zones)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS);
+							GFP_NOFS);
 	}
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/include/linux/mmzone.h linux-2.6.23-rc4-mm1-020_zoneid_zonelist/include/linux/mmzone.h
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/include/linux/mmzone.h	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/include/linux/mmzone.h	2007-09-10 16:06:31.000000000 +0100
@@ -444,11 +444,18 @@ struct zonelist_cache;
  *
  * If zlcache_ptr is not NULL, then it is just the address of zlcache,
  * as explained above.  If zlcache_ptr is NULL, there is no zlcache.
+ * *
+ * To speed the reading of _zones, additional information is encoded in the
+ * least significant bits of zonelist->_zones. The following helpers are used
+ *
+ * zonelist_zone()	- Return the struct zone * for an entry in _zones
+ * zonelist_zone_idx()	- Return the index of the zone for an entry
  */
-
 struct zonelist {
 	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
-	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
+	unsigned long _zones[MAX_ZONES_PER_ZONELIST + 1];    /* Encoded pointer,
+							      * 0 delimited
+							      */
 #ifdef CONFIG_NUMA
 	struct zonelist_cache zlcache;			     // optional ...
 #endif
@@ -682,14 +689,43 @@ extern struct zone *next_zone(struct zon
 	     zone;					\
 	     zone = next_zone(zone))
 
+/*
+ * SMP will align zones to a large boundary so the zone ID will fit in the
+ * least significant bits. Otherwise, ZONES_SHIFT must be 2 or less
+ */
+#if (defined(CONFIG_SMP) && INTERNODE_CACHE_SHIFT < ZONES_SHIFT) || \
+	ZONES_SHIFT > 2
+#error There is not enough space to embed zone IDs in the zonelist
+#endif
+
+#define ZONELIST_ZONEIDX_MASK ((1UL << ZONES_SHIFT) - 1)
+static inline struct zone *zonelist_zone(unsigned long zone_addr)
+{
+	return (struct zone *)(zone_addr & ~ZONELIST_ZONEIDX_MASK);
+}
+
+static inline int zonelist_zone_idx(unsigned long zone_addr)
+{
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
+
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
-static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
+static inline unsigned long *first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx)
 {
-	struct zone **z;
+	unsigned long *z;
 
-	for (z = zonelist->zones;
-			*z && zone_idx(*z) > highest_zoneidx;
+	for (z = zonelist->_zones;
+			zonelist_zone_idx(*z) > highest_zoneidx;
 			z++)
 		;
 
@@ -697,11 +733,11 @@ static inline struct zone **first_zones_
 }
 
 /* Returns the next zone at or below highest_zoneidx in a zonelist */
-static inline struct zone **next_zones_zonelist(struct zone **z,
+static inline unsigned long *next_zones_zonelist(unsigned long *z,
 					enum zone_type highest_zoneidx)
 {
 	/* Find the next suitable zone to use for the allocation */
-	for (; *z && zone_idx(*z) > highest_zoneidx; z++)
+	for (; zonelist_zone_idx(*z) > highest_zoneidx; z++)
 		;
 
 	return z;
@@ -717,9 +753,11 @@ static inline struct zone **next_zones_z
  * This iterator iterates though all zones at or below a given zone index.
  */
 #define for_each_zone_zonelist(zone, z, zlist, highidx) \
-	for (z = first_zones_zonelist(zlist, highidx), zone = *z++;	\
+	for (z = first_zones_zonelist(zlist, highidx),			\
+					zone = zonelist_zone(*z++);	\
 		zone;							\
-		z = next_zones_zonelist(z, highidx), zone = *z++)
+		z = next_zones_zonelist(z, highidx),			\
+					zone = zonelist_zone(*z++))
 
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/kernel/cpuset.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/kernel/cpuset.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/kernel/cpuset.c	2007-09-10 09:29:14.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/kernel/cpuset.c	2007-09-10 16:06:31.000000000 +0100
@@ -1525,8 +1525,8 @@ int cpuset_zonelist_valid_mems_allowed(s
 {
 	int i;
 
-	for (i = 0; zl->zones[i]; i++) {
-		int nid = zone_to_nid(zl->zones[i]);
+	for (i = 0; zl->_zones[i]; i++) {
+		int nid = zone_to_nid(zonelist_zone(zl->_zones[i]));
 
 		if (node_isset(nid, current->mems_allowed))
 			return 1;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/hugetlb.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/hugetlb.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/hugetlb.c	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/hugetlb.c	2007-09-10 16:06:31.000000000 +0100
@@ -73,7 +73,8 @@ static struct page *dequeue_huge_page(st
 	struct page *page = NULL;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
 						htlb_alloc_mask);
-	struct zone *zone, **z;
+	struct zone *zone;
+	unsigned long *z;
 
 	for_each_zone_zonelist(zone, z, zonelist, MAX_NR_ZONES - 1) {
 		nid = zone_to_nid(zone);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/mempolicy.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/mempolicy.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/mempolicy.c	2007-09-10 16:06:13.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/mempolicy.c	2007-09-10 16:06:31.000000000 +0100
@@ -157,7 +157,7 @@ static struct zonelist *bind_zonelist(no
 		for_each_node_mask(nd, *nodes) { 
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];
 			if (z->present_pages > 0) 
-				zl->zones[num++] = z;
+				zl->_zones[num++] = encode_zone_idx(z);
 		}
 		if (k == 0)
 			break;
@@ -167,7 +167,7 @@ static struct zonelist *bind_zonelist(no
 		kfree(zl);
 		return ERR_PTR(-EINVAL);
 	}
-	zl->zones[num] = NULL;
+	zl->_zones[num] = 0;
 	return zl;
 }
 
@@ -489,9 +489,11 @@ static void get_zonemask(struct mempolic
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
@@ -1159,12 +1161,15 @@ unsigned slab_node(struct mempolicy *pol
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);
 
-	case MPOL_BIND:
+	case MPOL_BIND: {
 		/*
 		 * Follow bind policy behavior and start allocation at the
 		 * first node.
 		 */
-		return zone_to_nid(policy->v.zonelist->zones[0]);
+		struct zonelist *zonelist;
+		zonelist = policy->v.zonelist;
+		return zone_to_nid(zonelist_zone(zonelist->_zones[0]));
+	}
 
 	case MPOL_PREFERRED:
 		if (policy->v.preferred_node >= 0)
@@ -1242,7 +1247,7 @@ static struct page *alloc_page_interleav
 
 	zl = node_zonelist(nid, gfp);
 	page = __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) == zl->zones[0])
+	if (page && page_zone(page) == zonelist_zone(zl->_zones[0]))
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
 	return page;
 }
@@ -1366,10 +1371,14 @@ int __mpol_equal(struct mempolicy *a, st
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
@@ -1688,12 +1697,12 @@ static void mpol_rebind_policy(struct me
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
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/oom_kill.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/oom_kill.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/oom_kill.c	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/oom_kill.c	2007-09-10 16:06:31.000000000 +0100
@@ -186,7 +186,7 @@ static inline int constrained_alloc(stru
 {
 #ifdef CONFIG_NUMA
 	struct zone *zone;
-	struct zone **z;
+	unsigned long *z;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	nodemask_t nodes = node_states[N_HIGH_MEMORY];
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/page_alloc.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/page_alloc.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/page_alloc.c	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/page_alloc.c	2007-09-10 16:06:31.000000000 +0100
@@ -1359,7 +1359,7 @@ static nodemask_t *zlc_setup(struct zone
  * We are low on memory in the second scan, and should leave no stone
  * unturned looking for a free page.
  */
-static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+static int zlc_zone_worth_trying(struct zonelist *zonelist, unsigned long *z,
 						nodemask_t *allowednodes)
 {
 	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
@@ -1370,7 +1370,7 @@ static int zlc_zone_worth_trying(struct 
 	if (!zlc)
 		return 1;
 
-	i = z - zonelist->zones;
+	i = z - zonelist->_zones;
 	n = zlc->z_to_n[i];
 
 	/* This zone is worth trying if it is allowed but not full */
@@ -1382,7 +1382,7 @@ static int zlc_zone_worth_trying(struct 
  * zlc->fullzones, so that subsequent attempts to allocate a page
  * from that zone don't waste time re-examining it.
  */
-static void zlc_mark_zone_full(struct zonelist *zonelist, struct zone **z)
+static void zlc_mark_zone_full(struct zonelist *zonelist, unsigned long *z)
 {
 	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
 	int i;				/* index of *z in zonelist zones */
@@ -1391,7 +1391,7 @@ static void zlc_mark_zone_full(struct zo
 	if (!zlc)
 		return;
 
-	i = z - zonelist->zones;
+	i = z - zonelist->_zones;
 
 	set_bit(i, zlc->fullzones);
 }
@@ -1403,13 +1403,13 @@ static nodemask_t *zlc_setup(struct zone
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
@@ -1422,7 +1422,7 @@ static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
 {
-	struct zone **z;
+	unsigned long *z;
 	struct page *page = NULL;
 	int classzone_idx;
 	struct zone *zone;
@@ -1431,7 +1431,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
 	z = first_zones_zonelist(zonelist, high_zoneidx);
-	classzone_idx = zone_idx(*z);
+	classzone_idx = zonelist_zone_idx(*z);
 
 zonelist_scan:
 	/*
@@ -1550,7 +1550,8 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	struct zone **z;
+	unsigned long *z;
+	struct zone *zone;
 	struct page *page;
 	struct reclaim_state reclaim_state;
 	struct task_struct *p = current;
@@ -1564,9 +1565,9 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 		return NULL;
 
 restart:
-	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
+	z = zonelist->_zones;  /* the list of zones suitable for gfp_mask */
 
-	if (unlikely(*z == NULL)) {
+	if (unlikely(*z == 0)) {
 		/*
 		 * Happens if we have an empty zonelist as a result of
 		 * GFP_THISNODE being used on a memoryless node
@@ -1590,8 +1591,8 @@ restart:
 	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
-	for (z = zonelist->zones; *z; z++)
-		wakeup_kswapd(*z, order);
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+		wakeup_kswapd(zone, order);
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -1794,7 +1795,7 @@ EXPORT_SYMBOL(free_pages);
 static unsigned int nr_free_zone_pages(int offset)
 {
 	enum zone_type high_zoneidx = MAX_NR_ZONES - 1;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 
 	/* Just pick one node, since fallback list is circular */
@@ -1989,7 +1990,7 @@ static int build_zonelists_node(pg_data_
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
 		if (populated_zone(zone)) {
-			zonelist->zones[nr_zones++] = zone;
+			zonelist->_zones[nr_zones++] = encode_zone_idx(zone);
 			check_highest_zone(zone_type);
 		}
 
@@ -2166,11 +2167,11 @@ static void build_zonelists_in_node_orde
 	struct zonelist *zonelist;
 
 	zonelist = &pgdat->node_zonelists[0];
-	for (j = 0; zonelist->zones[j] != NULL; j++)
+	for (j = 0; zonelist->_zones[j] != 0; j++)
 		;
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j,
 							MAX_NR_ZONES - 1);
-	zonelist->zones[j] = NULL;
+	zonelist->_zones[j] = 0;
 }
 
 /*
@@ -2183,7 +2184,7 @@ static void build_thisnode_zonelists(pg_
 
 	zonelist = &pgdat->node_zonelists[1];
 	j = build_zonelists_node(pgdat, zonelist, 0, MAX_NR_ZONES - 1);
-	zonelist->zones[j] = NULL;
+	zonelist->_zones[j] = 0;
 }
 
 /*
@@ -2208,12 +2209,12 @@ static void build_zonelists_in_zone_orde
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
@@ -2290,7 +2291,7 @@ static void build_zonelists(pg_data_t *p
 	/* initialize zonelists */
 	for (i = 0; i < MAX_ZONELISTS; i++) {
 		zonelist = pgdat->node_zonelists + i;
-		zonelist->zones[0] = NULL;
+		zonelist->_zones[0] = 0;
 	}
 
 	/* NUMA-aware ordering of nodes */
@@ -2342,13 +2343,14 @@ static void build_zonelist_cache(pg_data
 {
 	struct zonelist *zonelist;
 	struct zonelist_cache *zlc;
-	struct zone **z;
+	unsigned long *z;
 
 	zonelist = &pgdat->node_zonelists[0];
 	zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
 	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
-	for (z = zonelist->zones; *z; z++)
-		zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
+	for (z = zonelist->_zones; *z; z++)
+		zlc->z_to_n[z - zonelist->_zones] =
+			zone_to_nid(zonelist_zone(*z));
 }
 
 
@@ -2391,7 +2393,7 @@ static void build_zonelists(pg_data_t *p
 							MAX_NR_ZONES - 1);
 	}
 
-	zonelist->zones[j] = NULL;
+	zonelist->_zones[j] = 0;
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/slab.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/slab.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/slab.c	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/slab.c	2007-09-10 16:06:31.000000000 +0100
@@ -3241,7 +3241,7 @@ static void *fallback_alloc(struct kmem_
 {
 	struct zonelist *zonelist;
 	gfp_t local_flags;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/slub.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/slub.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/slub.c	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/slub.c	2007-09-10 16:06:31.000000000 +0100
@@ -1257,7 +1257,7 @@ static struct page *get_any_partial(stru
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	struct page *page;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/vmscan.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/vmscan.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/vmscan.c	2007-09-10 16:06:22.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/vmscan.c	2007-09-10 16:06:31.000000000 +0100
@@ -1211,7 +1211,7 @@ static unsigned long shrink_zones(int pr
 					struct scan_control *sc)
 {
 	unsigned long nr_reclaimed = 0;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
@@ -1256,10 +1256,9 @@ unsigned long do_try_to_free_pages(struc
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
-	struct zone **z;
+	unsigned long *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	int i;
 
 	count_vm_event(ALLOCSTALL);
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/vmstat.c linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/vmstat.c
--- linux-2.6.23-rc4-mm1-010_use_two_zonelists/mm/vmstat.c	2007-09-10 09:29:14.000000000 +0100
+++ linux-2.6.23-rc4-mm1-020_zoneid_zonelist/mm/vmstat.c	2007-09-10 16:06:31.000000000 +0100
@@ -365,11 +365,12 @@ void refresh_cpu_vm_stats(int cpu)
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
