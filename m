From: Paul Jackson <pj@sgi.com>
Date: Mon, 09 Oct 2006 18:17:53 -0700
Message-Id: <20061010011753.21530.69993.sendpatchset@jackhammer.engr.sgi.com>
Subject: [TESTING ONLY PATCH] memory zonelist caching 2.6.18 backport
Sender: owner-linux-mm@kvack.org
From: Paul Jackson <pj@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: Andrew Morton <akpm@osdl.org>, menage@google.com, Paul Jackson <pj@sgi.com>, mbligh@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rohit - here's a backport to 2.6.18 of my zonelist caching
patches.  This patch combines the following four patches:

    memory_page_alloc_minor_cleanups
    memory_page_alloc_empty_zonelist
    memory_fast_zonelist_scan
    memory_fast_zonelist_cache_counter_expiration

These patches are actually slightly ahead of what I've sent
to linux-mm for general consideration.  They rework the check
for an empty zonelist in __alloc_pages, and they add a counter
along side the timer based expiration triggers on resetting
the zonelist cache.

This patch is intended only for use in your testing.

I'll be sending the real patches for general consideration,
against 2.6.18-mm*, in separate messages.

Signed-of-by: Paul Jackson <pj@sgi.com>

---

 include/linux/cpuset.h |    2 
 include/linux/mmzone.h |   91 ++++++++++++++++++-
 mm/mempolicy.c         |    2 
 mm/page_alloc.c        |  224 ++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 295 insertions(+), 24 deletions(-)

--- 2.6.18.orig/include/linux/cpuset.h	2006-10-09 17:59:27.393441859 -0700
+++ 2.6.18/include/linux/cpuset.h	2006-10-09 18:01:17.706758824 -0700
@@ -23,6 +23,7 @@ extern void cpuset_fork(struct task_stru
 extern void cpuset_exit(struct task_struct *p);
 extern cpumask_t cpuset_cpus_allowed(struct task_struct *p);
 extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
+#define cpuset_current_mems_allowed (current->mems_allowed)
 void cpuset_init_current_mems_allowed(void);
 void cpuset_update_task_memory_state(void);
 #define cpuset_nodes_subset_current_mems_allowed(nodes) \
@@ -81,6 +82,7 @@ static inline nodemask_t cpuset_mems_all
 	return node_possible_map;
 }
 
+#define cpuset_current_mems_allowed (node_online_map)
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_task_memory_state(void) {}
 #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)
--- 2.6.18.orig/include/linux/mmzone.h	2006-10-09 17:59:27.393441859 -0700
+++ 2.6.18/include/linux/mmzone.h	2006-10-09 18:01:17.710758872 -0700
@@ -274,19 +274,100 @@ struct zone {
  */
 #define DEF_PRIORITY 12
 
+#ifdef CONFIG_NUMA
+/*
+ * We cache key information from each zonelist for smaller cache
+ * footprint when scanning for free pages in get_page_from_freelist().
+ *
+ * 1) The BITMAP fullzones tracks which zones in a zonelist have come
+ *    up short of free memory since the last time (last_fullzone_zap)
+ *    we zero'd fullzones.
+ * 2) The array z_to_n[] maps each zone in the zonelist to its node
+ *    id, so that we can efficiently evaluate whether that node is
+ *    set in the current tasks mems_allowed.
+ *
+ * Both fullzones and z_to_n[] are one-to-one with the zonelist,
+ * indexed by a zones offset in the zonelist zones[] array.
+ *
+ * The get_page_from_freelist() routine does two scans.  During the
+ * first scan, we skip zones whose corresponding bit in 'fullzones'
+ * is set or whose corresponding node in current->mems_allowed (which
+ * comes from cpusets) is not set.  During the second scan, we bypass
+ * this zonelist_cache, to ensure we look methodically at each zone.
+ *
+ * Once per second, we zero out (zap) fullzones, forcing us to
+ * reconsider nodes that might have regained more free memory.
+ * The field last_full_zap is the time we last zapped fullzones.
+ *
+ * We also zap this cache if it has been used more than
+ * ZLC_COUNTER_LIMIT times since the last zap, as tracked by the
+ * counter field, in case we on fast hardware with a fast allocator.
+ * Much can change in a ZLC_COUNTER_LIMIT allocations.
+ *
+ * This mechanism reduces the amount of time we waste repeatedly
+ * reexaming zones for free memory when they just came up low on
+ * memory momentarilly ago.
+ *
+ * The zonelist_cache struct members logically belong in struct
+ * zonelist.  However, the mempolicy zonelists constructed for
+ * MPOL_BIND are intentionally variable length (and usually much
+ * shorter).  A general purpose mechanism for handling structs with
+ * multiple variable length members is more mechanism than we want
+ * here.  We resort to some special case hackery instead.
+ *
+ * The MPOL_BIND zonelists don't need this zonelist_cache (in good
+ * part because they are shorter), so we put the fixed length stuff
+ * at the front of the zonelist struct, ending in a variable length
+ * zones[], as is needed by MPOL_BIND.
+ *
+ * Then we put the optional zonelist cache on the end of the zonelist
+ * struct.  This optional stuff is found by a 'zlcache_ptr' pointer in
+ * the fixed length portion at the front of the struct.  This pointer
+ * both enables us to find the zonelist cache, and in the case of
+ * MPOL_BIND zonelists, (which will just set the zlcache_ptr to NULL)
+ * to know that the zonelist cache is not there.
+ *
+ * The end result is that struct zonelists come in two flavors:
+ *  1) The full, fixed length version, shown below, and
+ *  2) The custom zonelists for MPOL_BIND.
+ * The custom MPOL_BIND zonelists have a NULL zlcache_ptr and no zlcache.
+ *
+ * Even though there may be multiple CPU cores on a node modifying
+ * fullzones, last_full_zap, or counter in the same zonelist_cache
+ * at the same time, we don't lock it.  This is just hint data -
+ * if it is wrong now and then, the allocator will still function,
+ * perhaps a bit slower.
+ */
+
+#define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
+#define ZLC_COUNTER_LIMIT 1000
+
+struct zonelist_cache {
+	DECLARE_BITMAP(fullzones, MAX_ZONES_PER_ZONELIST);	/* zone full? */
+	unsigned short z_to_n[MAX_ZONES_PER_ZONELIST];		/* zone->nid */
+	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
+	unsigned int counter;			/* cache uses since last zap */
+};
+#else
+struct zonelist_cache;
+#endif
+
 /*
  * One allocation request operates on a zonelist. A zonelist
  * is a list of zones, the first one is the 'goal' of the
  * allocation, the other zones are fallback zones, in decreasing
  * priority.
  *
- * Right now a zonelist takes up less than a cacheline. We never
- * modify it apart from boot-up, and only a few indices are used,
- * so despite the zonelist table being relatively big, the cache
- * footprint of this construct is very small.
+ * If zlcache_ptr is not NULL, then it is just the address of zlcache,
+ * as explained above.  If zlcache_ptr is NULL, there is no zlcache.
  */
+
 struct zonelist {
-	struct zone *zones[MAX_NUMNODES * MAX_NR_ZONES + 1]; // NULL delimited
+	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
+	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
+#ifdef CONFIG_NUMA
+	struct zonelist_cache zlcache;			     // optional ...
+#endif
 };
 
 
--- 2.6.18.orig/mm/mempolicy.c	2006-10-09 17:59:27.393441859 -0700
+++ 2.6.18/mm/mempolicy.c	2006-10-09 18:01:17.706758824 -0700
@@ -140,9 +140,11 @@ static struct zonelist *bind_zonelist(no
 	int num, max, nd, k;
 
 	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
+	max++;			/* space for zlcache_ptr (see mmzone.h) */
 	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
 	if (!zl)
 		return NULL;
+	zl->zlcache_ptr = NULL;
 	num = 0;
 	/* First put in the highest zones from all nodes, then all the next 
 	   lower zones etc. Avoid empty zones because the memory allocator
--- 2.6.18.orig/mm/page_alloc.c	2006-10-09 17:59:27.561443863 -0700
+++ 2.6.18/mm/page_alloc.c	2006-10-09 18:01:17.710758872 -0700
@@ -859,26 +859,166 @@ int zone_watermark_ok(struct zone *z, in
 	return 1;
 }
 
+#ifdef CONFIG_NUMA
+/*
+ * zlc_setup - Setup for "zonelist cache".  Uses cached zone data to
+ * skip over zones that are not allowed by the cpuset, or that have
+ * been recently (in last second) found to be nearly full.  See further
+ * comments in mmzone.h.  Reduces cache footprint of zonelist scans
+ * that have to skip over alot of full or unallowed zones.
+ *
+ * If the zonelist cache is present in the passed in zonelist, then
+ * returns a pointer to the allowed node mask (either the current
+ * tasks mems_allowed, or node_online_map.)
+ *
+ * If the zonelist cache is not available for this zonelist, does
+ * nothing and returns NULL.
+ *
+ * If the fullzones BITMAP in the zonelist cache is stale (more than
+ * a second or more than ZLC_COUNTER_LIMIT uses since last zap'd) then
+ * we zap it out.
+ *
+ * We hold off even calling zlc_setup, until after we've checked the
+ * first zone in the zonelist, on the theory that most allocations will
+ * be satisfied from that first zone, so best to examine that zone as
+ * quickly as we can.
+ */
+static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
+{
+	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
+	nodemask_t *allowednodes;	/* zonelist_cache approximation */
+
+	zlc = zonelist->zlcache_ptr;
+	if (!zlc)
+		return NULL;
+
+	zlc->counter++;
+	if (jiffies - zlc->last_full_zap > 1 * HZ ||
+					zlc->counter > ZLC_COUNTER_LIMIT) {
+		bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
+		zlc->last_full_zap = jiffies;
+		zlc->counter = 0;
+	}
+
+	allowednodes = !in_interrupt() && (alloc_flags & ALLOC_CPUSET) ?
+					&cpuset_current_mems_allowed :
+					&node_online_map;
+	return allowednodes;
+}
+
+/*
+ * Given 'z' scanning a zonelist, run a couple of quick checks to see
+ * if it is worth looking at further for free memory:
+ *  1) Check that the zone isn't thought to be full (doesn't have its
+ *     bit set in the zonelist_cache fullzones BITMAP).
+ *  2) Check that the zones node (obtained from the zonelist_cache
+ *     z_to_n[] mapping) is allowed in the passed in allowednodes mask.
+ * Return true (non-zero) if zone is worth looking at further, or
+ * else return false (zero) if it is not.
+ *
+ * This check -ignores- the distinction between various watermarks,
+ * such as GFP_HIGH, GFP_ATOMIC, PF_MEMALLOC, ...  If a zone is
+ * found to be full for any variation of these watermarks, it will
+ * be considered full for up to one second by all requests, unless
+ * we are so low on memory on all allowed nodes that we are forced
+ * into the second scan of the zonelist.
+ *
+ * In the second scan we ignore this zonelist cache and exactly
+ * apply the watermarks to all zones, even it is slower to do so.
+ * We are low on memory in the second scan, and should leave no stone
+ * unturned looking for a free page.
+ */
+static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+						nodemask_t *allowednodes)
+{
+	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
+	int i;				/* index of *z in zonelist zones */
+	int n;				/* node that zone *z is on */
+
+	zlc = zonelist->zlcache_ptr;
+	if (!zlc)
+		return 1;
+
+	i = z - zonelist->zones;
+	n = zlc->z_to_n[i];
+
+	/* This zone is worth trying if it is allowed but not full */
+	return node_isset(n, *allowednodes) && !test_bit(i, zlc->fullzones);
+}
+
 /*
- * get_page_from_freeliest goes through the zonelist trying to allocate
+ * Given 'z' scanning a zonelist, set the corresponding bit in
+ * zlc->fullzones, so that subsequent attempts to allocate a page
+ * from that zone don't waste time re-examining it.
+ */
+static void zlc_mark_zone_full(struct zonelist *zonelist, struct zone **z)
+{
+	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
+	int i;				/* index of *z in zonelist zones */
+
+	zlc = zonelist->zlcache_ptr;
+	if (!zlc)
+		return;
+
+	i = z - zonelist->zones;
+
+	set_bit(i, zlc->fullzones);
+}
+
+#else	/* CONFIG_NUMA */
+
+static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
+{
+	return NULL;
+}
+
+static int zlc_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+				nodemask_t *allowednodes)
+{
+	return 1;
+}
+
+static void zlc_mark_zone_full(struct zonelist *zonelist, struct zone **z)
+{
+}
+#endif	/* CONFIG_NUMA */
+
+/* This helps us to avoid #ifdef CONFIG_NUMA */
+#ifdef CONFIG_NUMA
+#define NUMA_BUILD 1
+#else
+#define NUMA_BUILD 0
+#endif
+
+/*
+ * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
  */
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist, int alloc_flags)
 {
-	struct zone **z = zonelist->zones;
+	struct zone **z;
 	struct page *page = NULL;
-	int classzone_idx = zone_idx(*z);
+	int classzone_idx = zone_idx(zonelist->zones[0]);
+	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
+	int zlc_active = 0;		/* set if using zonelist_cache */
+	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
+zonelist_scan:
 	/*
-	 * Go through the zonelist once, looking for a zone with enough free.
+	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
+	z = zonelist->zones;
+
 	do {
+		if (NUMA_BUILD && zlc_active &&
+			!zlc_zone_worth_trying(zonelist, z, allowednodes))
+				continue;
 		if ((alloc_flags & ALLOC_CPUSET) &&
-				!cpuset_zone_allowed(*z, gfp_mask))
-			continue;
+			!cpuset_zone_allowed(*z, gfp_mask))
+				goto try_next_zone;
 
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
@@ -889,17 +1029,33 @@ get_page_from_freelist(gfp_t gfp_mask, u
 			else
 				mark = (*z)->pages_high;
 			if (!zone_watermark_ok(*z, order, mark,
-				    classzone_idx, alloc_flags))
+				    classzone_idx, alloc_flags)) {
 				if (!zone_reclaim_mode ||
 				    !zone_reclaim(*z, gfp_mask, order))
-					continue;
+					goto this_zone_full;
+			}
 		}
 
 		page = buffered_rmqueue(zonelist, *z, order, gfp_mask);
-		if (page) {
+		if (page)
 			break;
+this_zone_full:
+		if (NUMA_BUILD)
+			zlc_mark_zone_full(zonelist, z);
+try_next_zone:
+		if (NUMA_BUILD && !did_zlc_setup) {
+			/* we do zlc_setup after the first zone is tried */
+			allowednodes = zlc_setup(zonelist, alloc_flags);
+			zlc_active = 1;
+			did_zlc_setup = 1;
 		}
 	} while (*(++z) != NULL);
+
+	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
+		/* Disable zlc cache for second zonelist scan */
+		zlc_active = 0;
+		goto zonelist_scan;
+	}
 	return page;
 }
 
@@ -922,21 +1078,13 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 	might_sleep_if(wait);
 
 restart:
-	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
-
-	if (unlikely(*z == NULL)) {
-		/* Should this ever happen?? */
-		return NULL;
-	}
-
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
 				zonelist, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
 		goto got_pg;
 
-	do {
+	for (z = zonelist->zones; *z; z++)
 		wakeup_kswapd(*z, order);
-	} while (*(++z));
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
@@ -968,6 +1116,14 @@ restart:
 	if (page)
 		goto got_pg;
 
+	/*
+	 * Someone called us with an empty zonelist.  Shouldn't happen.
+	 * But if it did, better to give up now than to stumble along
+	 * in the following code.
+	 */
+	if (unlikely(zonelist->zones[0] == NULL))
+		return NULL;
+
 	/* This allocation should allow future memory freeing. */
 
 	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
@@ -1506,6 +1662,24 @@ static void __meminit build_zonelists(pg
 	}
 }
 
+/* Construct the zonelist performance cache - see further mmzone.h */
+static void __meminit build_zonelist_cache(pg_data_t *pgdat)
+{
+	int i;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		struct zonelist *zonelist;
+		struct zonelist_cache *zlc;
+		struct zone **z;
+
+		zonelist = pgdat->node_zonelists + i;
+		zonelist->zlcache_ptr = zlc = &zonelist->zlcache;
+		bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
+		for (z = zonelist->zones; *z; z++)
+			zlc->z_to_n[z - zonelist->zones] = (*z)->zone_pgdat->node_id;
+	}
+}
+
 #else	/* CONFIG_NUMA */
 
 static void __meminit build_zonelists(pg_data_t *pgdat)
@@ -1544,14 +1718,26 @@ static void __meminit build_zonelists(pg
 	}
 }
 
+/* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
+static void __meminit build_zonelist_cache(pg_data_t *pgdat)
+{
+	int i;
+
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		pgdat->node_zonelists[i].zlcache_ptr = NULL;
+}
+
 #endif	/* CONFIG_NUMA */
 
 /* return values int ....just for stop_machine_run() */
 static int __meminit __build_all_zonelists(void *dummy)
 {
 	int nid;
-	for_each_online_node(nid)
+
+	for_each_online_node(nid) {
 		build_zonelists(NODE_DATA(nid));
+		build_zonelist_cache(NODE_DATA(nid));
+	}
 	return 0;
 }
 

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
