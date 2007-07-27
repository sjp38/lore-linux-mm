Date: Fri, 27 Jul 2007 16:45:19 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070727154519.GA21614@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com> <20070726132336.GA18825@skynet.ie> <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com> <20070726225920.GA10225@skynet.ie> <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com> <20070727082046.GA6301@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070727082046.GA6301@skynet.ie>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (27/07/07 09:20), Mel Gorman didst pronounce:
> On (26/07/07 18:22), Christoph Lameter didst pronounce:
> > On Thu, 26 Jul 2007, Mel Gorman wrote:
> > 
> > > Comments?
> > 
> > Lets go with the unconditional filtering and get rid of some of the per 
> > node zonelists?
> 
> I would prefer to go with this for 2.6.23 and work on that for 2.6.24.
> The patch should be relatively straight-forward (I'll work on it today)
> but it would need wider testing than what I can do here, particularly on
> the larger machines that needed things like zlcache.
> 
> > We could f.e. merge the lists for ZONE_MOVABLE and 
> > ZONE_base_of_zone_movable?
> 
> That will be fine for freelist management but a mess with respect to
> reclaim. I'd rather not go down that rathole.
> 
> > That may increase the cacheability of the 
> > zonelists and reduce cache footprint.
> 
> That should be the case. I'll work on the patch today and see what sort
> of results I get.
> 

This was fairly straight-forward but I wouldn't call it a bug fix for 2.6.23
for the policys + ZONE_MOVABLE issue; I still prefer the last patch for
the fix.

This patch uses one zonelist per node and filters based on a gfp_mask where
necessary. It consumes less memory and reduces cache pressure at the cost
of CPU. It also adds a zone_id field to struct zone as zone_idx is used more
than it was previously.

Performance differences on kernbench for Total CPU time ranged from
-0.06% to +1.19%.

Obvious things that are outstanding;

o Compile-test parisc
o Split patch in two to keep the zone_idx changes separetly
o Verify zlccache is not broken
o Have a version of __alloc_pages take a nodemask and ditch
  bind_zonelist()

I can work on bringing this up to scratch during the cycle.

Patch as follows. Comments?

--- 
 arch/parisc/mm/init.c     |    7 ++
 drivers/char/sysrq.c      |    2 
 fs/buffer.c               |    2 
 include/linux/gfp.h       |   10 +++-
 include/linux/mempolicy.h |    4 -
 include/linux/mmzone.h    |    7 +-
 mm/mempolicy.c            |    8 +--
 mm/oom_kill.c             |    7 ++
 mm/page_alloc.c           |  112 ++++++++++++++++++++++------------------------
 mm/slab.c                 |    7 ++
 mm/slub.c                 |    7 ++
 mm/vmscan.c               |    6 ++
 12 files changed, 101 insertions(+), 78 deletions(-)

diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index e724b36..4d417c4 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -602,12 +602,15 @@ void show_mem(void)
 		int i, j, k;
 
 		for (i = 0; i < npmem_ranges; i++) {
+			zl = &NODE_DATA(i)->node_zonelist;
 			for (j = 0; j < MAX_NR_ZONES; j++) {
-				zl = NODE_DATA(i)->node_zonelists + j;
 
 				printk("Zone list for zone %d on node %d: ", j, i);
-				for (k = 0; zl->zones[k] != NULL; k++) 
+				for (k = 0; zl->zones[k] != NULL; k++)  {
+					if (should_filter_zone(zl->zones[k]), j)
+						continue;
 					printk("[%ld/%s] ", zone_to_nid(zl->zones[k]), zl->zones[k]->name);
+				}
 				printk("\n");
 			}
 		}
diff --git a/drivers/char/sysrq.c b/drivers/char/sysrq.c
index 39cc318..b56d17f 100644
--- a/drivers/char/sysrq.c
+++ b/drivers/char/sysrq.c
@@ -270,7 +270,7 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(&NODE_DATA(0)->node_zonelists[ZONE_NORMAL],
+	out_of_memory(&NODE_DATA(0)->node_zonelist,
 			GFP_KERNEL, 0);
 }
 
diff --git a/fs/buffer.c b/fs/buffer.c
index 0e5ec37..8e9bbef 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -354,7 +354,7 @@ static void free_more_memory(void)
 	yield();
 
 	for_each_online_pgdat(pgdat) {
-		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
+		zones = pgdat->node_zonelist.zones;
 		if (*zones)
 			try_to_free_pages(zones, 0, GFP_NOFS);
 	}
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index bc68dd9..f2a597e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -116,6 +116,13 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 	return ZONE_NORMAL;
 }
 
+static inline int should_filter_zone(struct zone *zone, int highest_zoneidx)
+{
+	if (zone_idx(zone) > highest_zoneidx)
+		return 1;
+	return 0;
+}
+
 /*
  * There is only one page-allocator function, and two main namespaces to
  * it. The alloc_page*() variants return 'struct page *' and as such
@@ -151,8 +158,7 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order,
-		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
+	return __alloc_pages(gfp_mask, order, &NODE_DATA(nid)->node_zonelist);
 }
 
 #ifdef CONFIG_NUMA
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index e147cf5..83e5256 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -166,7 +166,7 @@ extern enum zone_type policy_zone;
 
 static inline void check_highest_zone(enum zone_type k)
 {
-	if (k > policy_zone)
+	if (k > policy_zone && k != ZONE_MOVABLE)
 		policy_zone = k;
 }
 
@@ -258,7 +258,7 @@ static inline void mpol_fix_fork_child_flag(struct task_struct *p)
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 		unsigned long addr, gfp_t gfp_flags)
 {
-	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
+	return &NODE_DATA(0)->node_zonelist;
 }
 
 static inline int do_migrate_pages(struct mm_struct *mm,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index da8eb8a..7a0533e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -202,6 +202,7 @@ struct zone {
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
+	int zone_idx;
 #ifdef CONFIG_NUMA
 	int node;
 	/*
@@ -438,7 +439,7 @@ extern struct page *mem_map;
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
-	struct zonelist node_zonelists[MAX_NR_ZONES];
+	struct zonelist node_zonelist;
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;
@@ -502,7 +503,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
-#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+#define zone_idx(zone)		((zone)->zone_idx)
 
 static inline int populated_zone(struct zone *zone)
 {
@@ -544,7 +545,7 @@ static inline int is_normal_idx(enum zone_type idx)
 static inline int is_highmem(struct zone *zone)
 {
 #ifdef CONFIG_HIGHMEM
-	int zone_idx = zone - zone->zone_pgdat->node_zones;
+	int zone_idx = zone_idx(zone);
 	return zone_idx == ZONE_HIGHMEM ||
 		(zone_idx == ZONE_MOVABLE && zone_movable_is_highmem());
 #else
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 71b84b4..8b16ca3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -149,7 +149,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
 	   lower zones etc. Avoid empty zones because the memory allocator
 	   doesn't like them. If you implement node hot removal you
 	   have to fix that. */
-	k = policy_zone;
+	k = MAX_NR_ZONES - 1;
 	while (1) {
 		for_each_node_mask(nd, *nodes) { 
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];
@@ -1116,7 +1116,7 @@ static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
 		nd = 0;
 		BUG();
 	}
-	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
+	return &NODE_DATA(nd)->node_zonelist;
 }
 
 /* Do dynamic interleaving for a process */
@@ -1212,7 +1212,7 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
+		return &NODE_DATA(nid)->node_zonelist;
 	}
 	return zonelist_policy(GFP_HIGHUSER, pol);
 }
@@ -1226,7 +1226,7 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 	struct zonelist *zl;
 	struct page *page;
 
-	zl = NODE_DATA(nid)->node_zonelists + gfp_zone(gfp);
+	zl = &NODE_DATA(nid)->node_zonelist;
 	page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zl->zones[0])
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index a700141..8b36019 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -178,6 +178,7 @@ static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
 	struct zone **z;
 	nodemask_t nodes;
 	int node;
+	enum zone_type highest_zoneidx = gfp_zone(gfp_mask);
 
 	nodes_clear(nodes);
 	/* node has memory ? */
@@ -185,11 +186,15 @@ static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
 		if (NODE_DATA(node)->node_present_pages)
 			node_set(node, nodes);
 
-	for (z = zonelist->zones; *z; z++)
+	for (z = zonelist->zones; *z; z++) {
+
+		if (should_filter_zone(*z, highest_zoneidx))
+			continue;
 		if (cpuset_zone_allowed_softwall(*z, gfp_mask))
 			node_clear(zone_to_nid(*z), nodes);
 		else
 			return CONSTRAINT_CPUSET;
+	}
 
 	if (!nodes_empty(nodes))
 		return CONSTRAINT_MEMORY_POLICY;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40954fb..3ad57af 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1157,6 +1157,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	enum zone_type highest_zoneidx = gfp_zone(gfp_mask);
 
 zonelist_scan:
 	/*
@@ -1166,6 +1167,9 @@ zonelist_scan:
 	z = zonelist->zones;
 
 	do {
+		if (should_filter_zone(*z, highest_zoneidx))
+			continue;
+
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
@@ -1456,11 +1460,11 @@ static unsigned int nr_free_zone_pages(int offset)
 	pg_data_t *pgdat = NODE_DATA(numa_node_id());
 	unsigned int sum = 0;
 
-	struct zonelist *zonelist = pgdat->node_zonelists + offset;
-	struct zone **zonep = zonelist->zones;
-	struct zone *zone;
+	struct zone **zonep = pgdat->node_zonelist.zones;
+	struct zone *zone = *zonep;
 
-	for (zone = *zonep++; zone; zone = *zonep++) {
+	for (zone = *zonep++; zone && zone_idx(zone) > offset; zone = *zonep++);
+	for (; zone; zone = *zonep++) {
 		unsigned long size = zone->present_pages;
 		unsigned long high = zone->pages_high;
 		if (size > high)
@@ -1819,17 +1823,14 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
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
+ 	j = build_zonelists_node(NODE_DATA(node), zonelist, j, MAX_NR_ZONES-1);
+	zonelist->zones[j] = NULL;
 }
 
 /*
@@ -1842,27 +1843,24 @@ static int node_order[MAX_NUMNODES];
 
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
@@ -1929,17 +1927,14 @@ static void set_zonelist_order(void)
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
@@ -1993,7 +1988,7 @@ static void build_zonelist_cache(pg_data_t *pgdat)
 		struct zonelist_cache *zlc;
 		struct zone **z;
 
-		zonelist = pgdat->node_zonelists + i;
+		zonelist = &pgdat->node_zonelist;
 		zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
 		bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
 		for (z = zonelist->zones; *z; z++)
@@ -2012,36 +2007,36 @@ static void set_zonelist_order(void)
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
-
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
+ 	/*
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
 	}
+	for (node = 0; node < local_node; node++) {
+		if (!node_online(node))
+			continue;
+		j = build_zonelists_node(NODE_DATA(node), zonelist, j,
+								MAX_NR_ZONES-1);
+	}
+
+	zonelist->zones[j] = NULL;
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
@@ -2050,7 +2045,7 @@ static void build_zonelist_cache(pg_data_t *pgdat)
 	int i;
 
 	for (i = 0; i < MAX_NR_ZONES; i++)
-		pgdat->node_zonelists[i].zlcache_ptr = NULL;
+		pgdat->node_zonelist.zlcache_ptr = NULL;
 }
 
 #endif	/* CONFIG_NUMA */
@@ -2936,6 +2931,7 @@ static void __meminit free_area_init_core(struct pglist_data *pgdat,
 			nr_kernel_pages += realsize;
 		nr_all_pages += realsize;
 
+		zone->zone_idx = j;
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
 #ifdef CONFIG_NUMA
diff --git a/mm/slab.c b/mm/slab.c
index bde271c..d73fe30 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3216,12 +3216,12 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	struct zone **z;
 	void *obj = NULL;
 	int nid;
+	enum zone_type highest_zoneidx = gfp_zone(flags);
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	zonelist = &NODE_DATA(slab_node(current->mempolicy))
-			->node_zonelists[gfp_zone(flags)];
+	zonelist = &NODE_DATA(slab_node(current->mempolicy))->node_zonelist;
 	local_flags = (flags & GFP_LEVEL_MASK);
 
 retry:
@@ -3230,6 +3230,9 @@ retry:
 	 * from existing per node queues.
 	 */
 	for (z = zonelist->zones; *z && !obj; z++) {
+		if (should_filter_zone(*z, highest_zoneidx))
+			continue;
+
 		nid = zone_to_nid(*z);
 
 		if (cpuset_zone_allowed_hardwall(*z, flags) &&
diff --git a/mm/slub.c b/mm/slub.c
index 9b2d617..a020a12 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1276,6 +1276,7 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 	struct zonelist *zonelist;
 	struct zone **z;
 	struct page *page;
+	enum zone_type highest_zoneidx = gfp_zone(flags);
 
 	/*
 	 * The defrag ratio allows a configuration of the tradeoffs between
@@ -1298,11 +1299,13 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
 		return NULL;
 
-	zonelist = &NODE_DATA(slab_node(current->mempolicy))
-					->node_zonelists[gfp_zone(flags)];
+	zonelist = &NODE_DATA(slab_node(current->mempolicy))->node_zonelist;
 	for (z = zonelist->zones; *z; z++) {
 		struct kmem_cache_node *n;
 
+		if (should_filter_zone(*z, highest_zoneidx))
+			continue;
+
 		n = get_node(s, zone_to_nid(*z));
 
 		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d419e10..8672d61 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1124,6 +1124,7 @@ unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
+	enum zone_type highest_zoneidx;
 	int i;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
@@ -1136,9 +1137,14 @@ unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 
 	count_vm_event(ALLOCSTALL);
 
+	highest_zoneidx = gfp_zone(gfp_mask);
+
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
 
+		if (should_filter_zone(zone, highest_zoneidx))
+			continue;
+
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
