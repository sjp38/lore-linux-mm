From: Paul Jackson <pj@sgi.com>
Date: Mon, 09 Oct 2006 03:54:57 -0700
Message-Id: <20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
In-Reply-To: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
Subject: [RFC] memory page_alloc zonelist caching speedup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Andi Kleen <ak@suse.de>, mbligh@google.com, rohitseth@google.com, menage@google.com, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Optimize the critical zonelist scanning for free pages in the kernel
memory allocator by caching the zones that were found to be full
recently, and skipping them.

Remembers the zones in a zonelist that were short of free memory in
the last second.  And it stashes a zone-to-node table in the zonelist
struct, to optimize that conversion (minimize its cache footprint.)

It applies to 2.6.18-mm3, plus the patch:

	memory page alloc minor cleanups

I'll backport it to 2.6.18 so that Rohit can test it, in a subsequent
post.

Recent changes:

    This differs in a significant way from a similar patch that I
    posted a week ago.  Now, instead of having a nodemask_t of
    recently full nodes, I have a bitmask of recently full zones.
    This solves a problem that last weeks patch had, which on
    systems with multiple zones per node (such as DMA zone) would
    take seeing any of these zones full as meaning that all zones
    on that node were full.

    Also I changed names - from "zonelist faster" to "zonelist cache",
    as that seemed to better convey what we're doing here - caching
    some of the key zonelist state (for faster access.)
    
    See below for some performance benchmark results.  After all that
    discussion with David on why I didn't need them, I went and got
    some ;).  I wanted to verify that I had not hurt the normal case
    of memory allocation noticeably.  At least for my one little
    microbenchmark, I found (1) the normal case wasn't affected, and
    (2) workloads that forced scanning across multiple nodes for
    memory improved up to 10% fewer System CPU cycles and lower
    elapsed clock time ('sys' and 'real').  Good.  See details, below.
    
    I didn't have the logic in get_page_from_freelist() for various
    full nodes and zone reclaim failures correct.  That should be
    fixed up now - notice the new goto labels zonelist_scan,
    this_zone_full, and try_next_zone, in get_page_from_freelist().

There are two reasons I persued this alternative, over some earlier
proposals that would have focused on optimizing the fake numa
emulation case by caching the last useful zone:

 1) Contrary to what I said before, we (SGI, on large ia64 sn2 systems)
    have seen real customer loads where the cost to scan the zonelist
    was a problem, due to many nodes being full of memory before
    we got to a node we could use.  Or at least, I think we have.
    This was related to me by another engineer, based on experiences
    from some time past.  So this is not guaranteed.  Most likely, though.

    The following approach should help such real numa systems just as
    much as it helps fake numa systems, or any combination thereof.
    
 2) The effort to distinguish fake from real numa, using node_distance,
    so that we could cache a fake numa node and optimize choosing
    it over equivalent distance fake nodes, while continuing to
    properly scan all real nodes in distance order, was going to
    require a nasty blob of zonelist and node distance munging.

    The following approach has no new dependency on node distances or
    zone sorting.

See comment in the patch below for a description of what it actually does.

Technical details of note (or controversy):

 - See the use of "zlc_active" and "did_zlc_setup" below, to delay
   adding any work for this new mechanism until we've looked at the
   first zone in zonelist.  I figured the odds of the first zone
   having the memory we needed were high enough that we should just
   look there, first, then get fancy only if we need to keep looking.
   
 - Some odd hackery was needed to add items to struct zonelist, while
   not tripping up the custom zonelists built by the mm/mempolicy.c
   code for MPOL_BIND.  My usual wordy comments below explain this.
   Search for "MPOL_BIND".

 - Some per-node data in the struct zonelist is now modified frequently,
   with no locking.  Multiple CPU cores on a node could hit and mangle
   this data.  The theory is that this is just performance hint data,
   and the memory allocator will work just fine despite any such mangling.
   The fields at risk are the struct 'zonelist_cache' fields 'fullzones'
   (a bitmask) and 'last_full_zap' (unsigned long jiffies).  It should
   all be self correcting after at most a one second delay.
 
 - This still does a linear scan of the same lengths as before.  All
   I've optimized is making the scan faster, not algorithmically
   shorter.  It is now able to scan a compact array of 'unsigned
   short' in the case of many full nodes, so one cache line should
   cover quite a few nodes, rather than each node hitting another
   one or two new and distinct cache lines.
 
 - If both Andi and Nick don't find this too complicated, I will be
   (pleasantly) flabbergasted.
   
 - I removed the comment claiming we only use one cachline's worth of
   zonelist.  We seem, at least in the fake numa case, to have put the
   lie to that claim.
   
 - I pay no attention to the various watermarks and such in this performance
   hint.  A node could be marked full for one watermark, and then skipped
   over when searching for a page using a different watermark.  I think
   that's actually quite ok, as it will tend to slightly increase the
   spreading of memory over other nodes, away from a memory stressed node.

===============

Performance - some benchmark results and analysis:

This benchmark runs a memory hog program that uses multiple
threads to touch alot of memory as quickly as it can.

Multiple runs were made, touching 12, 38, 64 or 90 GBytes out of
the total 96 GBytes on the system, and using 1, 19, 37, or 55
threads (on a 56 CPU system.)  System, user and real (elapsed)
timings were recorded for each run, shown in units of seconds,
in the table below.

Two kernels were tested - 2.6.18-mm3 and the same kernel with
this zonelist caching patch added.  The table also shows the
difference in timings, between these two kernels, and what
percentage improvement the zonelist caching sys time is over
(lower than) the stock *-mm kernel.


      number     2.6.18-mm3	   zonelist-cache    delta (< 0 good)	percent
 GBs    N  	------------	   --------------    ----------------	systime
 mem threads   sys user  real	  sys  user  real     sys  user  real	 better
  12	 1     153   24   177	  151	 24   176      -2     0    -1	   1%
  12	19	99   22     8	   99	 22	8	0     0     0	   0%
  12	37     111   25     6	  112	 25	6	1     0     0	  -0%
  12	55     115   25     5	  110	 23	5      -5    -2     0	   4%
  38	 1     502   74   576	  497	 73   570      -5    -1    -6	   0%
  38	19     426   78    48	  373	 76    39     -53    -2    -9	  12%
  38	37     544   83    36	  547	 82    36	3    -1     0	  -0%
  38	55     501   77    23	  511	 80    24      10     3     1	  -1%
  64	 1     917  125  1042	  890	124  1014     -27    -1   -28	   2%
  64	19    1118  138   119	  965	141   103    -153     3   -16	  13%
  64	37    1202  151    94	 1136	150    81     -66    -1   -13	   5%
  64	55    1118  141    61	 1072	140    58     -46    -1    -3	   4%
  90	 1    1342  177  1519	 1275	174  1450     -67    -3   -69	   4%
  90	19    2392  199   192	 2116	189   176    -276   -10   -16	  11%
  90	37    3313  238   175	 2972	225   145    -341   -13   -30	  10%
  90	55    1948  210   104	 1843	213   100    -105     3    -4	   5%

Notes:
 1) This test ran a memory hog program that started a specified number N of
    threads, and had each thread allocate and touch 1/N'th of
    the total memory to be used in the test run in a single loop,
    writing a constant word to memory, one store every 4096 bytes.
    Watching this test during some earlier trial runs, I would see
    each of these threads sit down on one CPU and stay there, for
    the remainder of the pass, a different CPU for each thread.

 2) The 'real' column is not comparable to the 'sys' or 'user' columns.
    The 'real' column is seconds wall clock time elapsed, from beginning
    to end of that test pass.  The 'sys' and 'user' columns are total
    CPU seconds spent on that test pass.  For a 19 thread test run,
    for example, the sum of 'sys' and 'user' could be up to 19 times the
    number of 'real' elapsed wall clock seconds.
  
 3) Tests were run on a fresh, single-user boot, to minimize the amount
    of memory already in use at the start of the test, and to minimize
    the amount of background activity that might interfere.
 
 4) Tests were done on a 56 CPU, 28 Node system with 96 GBytes of RAM.
 
 5) Notice that the 'real' time gets large for the single thread runs, even
    though the measured 'sys' and 'user' times are modest.  I'm not sure what
    that means - probably something to do with it being slow for one thread to
    be accessing memory along ways away.  Perhaps the fake numa system, running
    ostensibly the same workload, would not show this substantial degradation
    of 'real' time for one thread on many nodes -- lets hope not.

 6) The high thread count passes (one thread per CPU - on 55 of 56 CPUs)
    ran quite efficiently, as one might expect.  Each pair of threads needed
    to allocate and touch the memory on the node the two threads shared, a
    pleasantly parallizable workload.
  
 7) The intermediate thread count passes, when asking for alot of memory forcing
    them to go to a few neighboring nodes, improved the most with this zonelist
    caching patch.

Conclusions:
 * This zonelist cache patch probably makes little difference one way or the
   other for most workloads on real numa hardware, if those workloads avoid
   heavy off node allocations.
 * For memory intensive workloads requiring substantial off-node allocations
   on real numa hardware, this patch improves both kernel and elapsed timings
   up to ten per-cent.
 * For fake numa systems, I'm optimistic, but will have to leave that up to
   Rohit Seth to actually test (once I get him a 2.6.18 backport.)

===============

Signed-off-by: Paul Jackson

---
 include/linux/cpuset.h |    2 
 include/linux/mmzone.h |   83 ++++++++++++++++++++-
 mm/mempolicy.c         |    2 
 mm/page_alloc.c        |  188 +++++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 263 insertions(+), 12 deletions(-)

--- 2.6.18-mm3.orig/include/linux/mmzone.h	2006-10-06 15:33:56.000000000 -0700
+++ 2.6.18-mm3/include/linux/mmzone.h	2006-10-06 16:41:49.000000000 -0700
@@ -315,19 +315,92 @@ struct zone {
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
+ * fullzones or last_full_zap in the same zonelist_cache at the same
+ * time, we don't lock it.  This is just hint data - if it is wrong now
+ * and then, the allocator will still function, perhaps a bit slower.
+ */
+
+#define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
+
+struct zonelist_cache {
+	DECLARE_BITMAP(fullzones, MAX_ZONES_PER_ZONELIST);	/* zone full? */
+	unsigned short z_to_n[MAX_ZONES_PER_ZONELIST];		/* zone->nid */
+	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
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
 
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
--- 2.6.18-mm3.orig/mm/page_alloc.c	2006-10-06 15:33:56.000000000 -0700
+++ 2.6.18-mm3/mm/page_alloc.c	2006-10-07 01:58:02.000000000 -0700
@@ -936,6 +936,126 @@ int zone_watermark_ok(struct zone *z, in
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
+ * a second since last zap'd) then we zap it out (clear its bits.)
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
+	if (jiffies - zlc->last_full_zap > 1 * HZ) {
+		bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
+		zlc->last_full_zap = jiffies;
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
+/*
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
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -944,23 +1064,32 @@ static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 		struct zonelist *zonelist, int alloc_flags)
 {
-	struct zone **z = zonelist->zones;
+	struct zone **z;
 	struct page *page = NULL;
-	int classzone_idx = zone_idx(*z);
+	int classzone_idx = zone_idx(zonelist->zones[0]);
 	struct zone *zone;
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
 		zone = *z;
 		if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
 			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
 				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
 			!cpuset_zone_allowed(zone, gfp_mask))
-				continue;
+				goto try_next_zone;
 
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
@@ -974,15 +1103,30 @@ get_page_from_freelist(gfp_t gfp_mask, u
 				    classzone_idx, alloc_flags)) {
 				if (!zone_reclaim_mode ||
 				    !zone_reclaim(zone, gfp_mask, order))
-					continue;
+					goto this_zone_full;
 			}
 		}
 
 		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
 		if (page)
 			break;
-
+this_zone_full:
+		if (NUMA_BUILD)
+			zlc_mark_zone_full(zonelist, z);
+try_next_zone:
+		if (NUMA_BUILD && !did_zlc_setup) {
+			/* we do zlc_setup after the first zone is tried */
+			allowednodes = zlc_setup(zonelist, alloc_flags);
+			zlc_active = 1;
+			did_zlc_setup = 1;
+		}
 	} while (*(++z) != NULL);
+
+	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
+		/* Disable zlc cache for second zonelist scan */
+		zlc_active = 0;
+		goto zonelist_scan;
+	}
 	return page;
 }
 
@@ -1621,6 +1765,24 @@ static void __meminit build_zonelists(pg
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
+			zlc->z_to_n[z - zonelist->zones] = zone_to_nid(*z);
+	}
+}
+
 #else	/* CONFIG_NUMA */
 
 static void __meminit build_zonelists(pg_data_t *pgdat)
@@ -1658,14 +1820,26 @@ static void __meminit build_zonelists(pg
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
 
--- 2.6.18-mm3.orig/mm/mempolicy.c	2006-10-06 15:33:56.000000000 -0700
+++ 2.6.18-mm3/mm/mempolicy.c	2006-10-06 16:41:49.000000000 -0700
@@ -141,9 +141,11 @@ static struct zonelist *bind_zonelist(no
 	enum zone_type k;
 
 	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
+	max++;			/* space for zlcache_ptr (see mmzone.h) */
 	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
 	if (!zl)
 		return NULL;
+	zl->zlcache_ptr = NULL;
 	num = 0;
 	/* First put in the highest zones from all nodes, then all the next 
 	   lower zones etc. Avoid empty zones because the memory allocator
--- 2.6.18-mm3.orig/include/linux/cpuset.h	2006-10-06 15:33:56.000000000 -0700
+++ 2.6.18-mm3/include/linux/cpuset.h	2006-10-06 16:41:49.000000000 -0700
@@ -23,6 +23,7 @@ extern void cpuset_fork(struct task_stru
 extern void cpuset_exit(struct task_struct *p);
 extern cpumask_t cpuset_cpus_allowed(struct task_struct *p);
 extern nodemask_t cpuset_mems_allowed(struct task_struct *p);
+#define cpuset_current_mems_allowed (current->mems_allowed)
 void cpuset_init_current_mems_allowed(void);
 void cpuset_update_task_memory_state(void);
 #define cpuset_nodes_subset_current_mems_allowed(nodes) \
@@ -83,6 +84,7 @@ static inline nodemask_t cpuset_mems_all
 	return node_possible_map;
 }
 
+#define cpuset_current_mems_allowed (node_online_map)
 static inline void cpuset_init_current_mems_allowed(void) {}
 static inline void cpuset_update_task_memory_state(void) {}
 #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
