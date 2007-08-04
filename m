Date: Sat, 4 Aug 2007 17:39:16 +0100
Subject: Re: [PATCH] Apply memory policies to top two highest zones when highest zone is ZONE_MOVABLE
Message-ID: <20070804163915.GA31669@skynet.ie>
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de> <20070804002354.GA2841@skynet.ie> <200708041051.14324.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200708041051.14324.ak@suse.de>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (04/08/07 10:51), Andi Kleen didst pronounce:
> 
> > It only affects hot paths in the NUMA case so non-NUMA users will not care.
> 
> For x86-64 most distribution kernels are NUMA these days.
> 
> > For NUMA users,  I have posted patches that eliminate multiple zonelists
> > altogether which will reduce cache footprint (something like 7K per node on
> > x86_64)
> 
> How do you get to 7k? We got worst case 3 zones node (normally less);
> that's three pointers per GFP level.
> 

The zonelists are pretty big. On a 4 node x86_64 machine (elm3b6 from tko),
the size of pg_data_t goes from 13632 bytes to 5824 (almost 8k in fact)
when only one zonelists is used.

> > and make things like MPOL_BIND behave in a consistent manner. That 
> > would cost on CPU but save on cache which would (hopefully) result in a net
> > gain in most cases.
> 
> That might be a good tradeoff, but without seeing the patch 
> the 7k number sounds very dubious.
> 

Proof-of-concept patch is below. It's not suitable for merging and I was
getting the policy issue resolved first before spending more time on it. The
patch was a big too heavy to call a fix for a bug.

> > I would like to go with this patch for now just for policies but for
> > 2.6.23, we could leave it as "policies only apply to ZONE_MOVABLE when it
> > is used" if you really insisted on it. It's less than ideal though for
> > sure.
> 
> Or disable ZONE_MOVABLE. It seems to be clearly not well thought
> out well yet.

The zone is disabled by default. When enabled, the policies are only applied
to it which is expected, but not desirable which is why I wanted to apply
policies to the two highest zones when the highest was ZONE_MOVABLE.

>Perhaps make it dependent on !CONFIG_NUMA.
> 

That would make no sense. The systems that will be using hugepages and
looking to resize their pool will often be NUMA machines and you state
that most x86_64 distros will have NUMA enabled.

This is the prototype patch for removing multiple zonelists altogether.
It would also act as a fix for the
policies-only-applying-to-ZONE_MOVABLE problem. You may not that where
the filtering takes place in __alloc_pages() is in the same place as
with the patch to fix policies so there is a logical progression from
bug fix now to something with wider usefulness later.

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
index 3ea68cd..d2fe32e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -201,6 +201,7 @@ struct zone {
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
+	int zone_idx;
 #ifdef CONFIG_NUMA
 	int node;
 	/*
@@ -437,7 +438,7 @@ extern struct page *mem_map;
 struct bootmem_data;
 typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
-	struct zonelist node_zonelists[MAX_NR_ZONES];
+	struct zonelist node_zonelist;
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
 	struct page *node_mem_map;
@@ -501,7 +502,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
-#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+#define zone_idx(zone)		((zone)->zone_idx)
 
 static inline int populated_zone(struct zone *zone)
 {
@@ -543,7 +544,7 @@ static inline int is_normal_idx(enum zone_type idx)
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
index f9b82ad..1cca18e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -179,6 +179,7 @@ static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
 	struct zone **z;
 	nodemask_t nodes;
 	int node;
+	enum zone_type highest_zoneidx = gfp_zone(gfp_mask);
 
 	nodes_clear(nodes);
 	/* node has memory ? */
@@ -186,11 +187,15 @@ static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
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
index 3da85b8..190994d 100644
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
@@ -1460,11 +1464,11 @@ static unsigned int nr_free_zone_pages(int offset)
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
@@ -1823,17 +1827,14 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
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
@@ -1846,27 +1847,24 @@ static int node_order[MAX_NUMNODES];
 
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
@@ -1933,17 +1931,14 @@ static void set_zonelist_order(void)
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
@@ -1997,7 +1992,7 @@ static void build_zonelist_cache(pg_data_t *pgdat)
 		struct zonelist_cache *zlc;
 		struct zone **z;
 
-		zonelist = pgdat->node_zonelists + i;
+		zonelist = &pgdat->node_zonelist;
 		zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
 		bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
 		for (z = zonelist->zones; *z; z++)
@@ -2016,36 +2011,36 @@ static void set_zonelist_order(void)
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
@@ -2054,7 +2049,7 @@ static void build_zonelist_cache(pg_data_t *pgdat)
 	int i;
 
 	for (i = 0; i < MAX_NR_ZONES; i++)
-		pgdat->node_zonelists[i].zlcache_ptr = NULL;
+		pgdat->node_zonelist.zlcache_ptr = NULL;
 }
 
 #endif	/* CONFIG_NUMA */
@@ -2940,6 +2935,7 @@ static void __meminit free_area_init_core(struct pglist_data *pgdat,
 			nr_kernel_pages += realsize;
 		nr_all_pages += realsize;
 
+		zone->zone_idx = j;
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
 #ifdef CONFIG_NUMA
diff --git a/mm/slab.c b/mm/slab.c
index a684778..558cf96 100644
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
index 6c6d74f..eea184b 100644
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
