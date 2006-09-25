From: Paul Jackson <pj@sgi.com>
Date: Mon, 25 Sep 2006 02:14:52 -0700
Message-Id: <20060925091452.14277.9236.sendpatchset@v0>
Subject: [RFC] another way to speed up fake numa node page_alloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Andi Kleen <ak@suse.de>, mbligh@google.com, rohitseth@google.com, menage@google.com, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Here's an entirely different approach to speeding up
get_page_from_freelist() on large fake numa configurations.

Instead of trying to cache the last node that worked, it remembers
the nodes that didn't work recently.  Namely, it remembers the nodes
that were short of free memory in the last second.  And it stashes a
zone-to-node table in the zonelist struct, to optimize that conversion
(minimize its cache footprint.)

Beware.  This code has not been tested.  It has built and booted, once.

It almost certainly has bugs, and I have no idea if it actually speeds
up, or slows down, any load of interest.  I have not yet verified
that it does anything like what I intend it to do.

It applies to 2.6.18-rc7-mm1.

There are two reasons I persued this alternative:

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

 - See the use of "zlf_scan" below, to delay adding any work for this
   new mechanism until we've looked at the first zone in zonelist.
   I figured the odds of the first zone having the memory we needed
   were high enough that we should just look there, first, then get
   fancy only if we need to keep looking.
   
 - Some odd hackery was needed to add items to struct zonelist, while
   not tripping up the custom zonelists built by the mm/mempolicy.c
   code for MPOL_BIND.  My usual wordy comments below explain this.
   Search for "MPOL_BIND".

 - Some per-node data in the struct zonelist is now modified frequently,
   with no locking.  Multiple CPU cores on a node could hit and mangle
   this data.  The theory is that this is just performance hint data,
   and the memory allocator will work just fine despite any such mangling.
   The fields at risk are the struct 'zonelist_faster' fields 'fullnodes'
   (a nodemask_t) and 'last_full_zap' (unsigned long jiffies).  It should
   all be self correcting after at most a one second delay.
 
 - This still does a linear scan of the same lengths as before.  All
   I've optimized is making the scan faster, not algorithmically
   shorter.  It is now able to scan a compact array of 'unsigned
   short' in the case of many full nodes, so one cache line should
   cover quite a few nodes, rather than each node hitting another
   one or two new and distinct cache lines.
 
 - If both Andi and Nick don't find this too complicated, I will be
   (pleasantly) flabbergasted.
 
 - In what really should be a separate patch, I removed the six lines
   of source code following the 'restart' label in __alloc_pages, and
   changed the wakeup_kswapd loop from a do-while loop to a for-loop.
   Eh ... I didn't think four of the six lines were needed, and I
   thought the remaining made more sense written as a for-loop.
   
 - I removed the comment claiming we only use one cachline's worth of
   zonelist.  We seem, at least in the fake numa case, to have put the
   lie to that claim.
   
 - This needs some test builds for variations of NUMA config, not to
   mention various other tests for function and performance.
   
 - I pay no attention to the various watermarks and such in this performance
   hint.  A node could be marked full for one watermark, and then skipped
   over when searching for a page using a different watermark.  I think
   that's actually quite ok, as it will tend to slightly increase the
   spreading of memory over other nodes, away from a memory stressed node.


Signed-off-by: Paul Jackson

---
 include/linux/mmzone.h |   72 +++++++++++++++++++++-
 mm/mempolicy.c         |    2 
 mm/page_alloc.c        |  158 +++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 216 insertions(+), 16 deletions(-)

--- 2.6.18-rc7-mm1.orig/include/linux/mmzone.h	2006-09-22 14:13:18.000000000 -0700
+++ 2.6.18-rc7-mm1/include/linux/mmzone.h	2006-09-24 22:33:58.000000000 -0700
@@ -303,19 +303,83 @@ struct zone {
  */
 #define DEF_PRIORITY 12
 
+#ifdef CONFIG_NUMA
+/*
+ * The node id's of the zone structs are extracted into a parallel
+ * array, for faster (smaller cache footprint) scanning for allowed
+ * nodes in get_page_from_freelist().
+ *
+ * To optimize get_page_from_freelist(), 'fullnodes' tracks which nodes
+ * have come up short of free memory, in searches using this zonelist,
+ * since the last time (last_fullnode_zap) we zero'd fullnodes.
+ *
+ * The get_page_from_freelist() routine does two scans.  During the
+ * first scan, we skip zones whose corresponding node number (in
+ * the node_id[] array) is either set in fullnodes or not set in
+ * current->mems_allowed (which comes from cpusets).
+ *
+ * Once per second, we zero out (zap) fullnodes, forcing us to
+ * reconsider nodes that might have regained more free memory.
+ * The field last_full_zap is the time we last zapped fullnodes.
+ *
+ * This mechanism reduces the amount of time we waste repeatedly
+ * reexaming zones for free memory when they just came up low on
+ * memory momentarilly ago.
+ *
+ * These struct members logically belong in struct zonelist.  However,
+ * the mempolicy zonelists constructed for MPOL_BIND are intentionally
+ * variable length (and usually much shorter).  A general purpose
+ * mechanism for handling structs with multiple variable length
+ * members is more mechanism than we want here.  We resort to some
+ * special case hackery instead.
+ *
+ * The MPOL_BIND zonelists don't need this zonelist_faster stuff
+ * (in good part because they are shorter), so we put the fixed
+ * length stuff at the front of the zonelist struct, ending in a
+ * variable length zones[], as is needed by MPOL_BIND.
+ *
+ * Then we put the optional faster stuff on the end of the zonelist
+ * struct.  This optional stuff is found by a 'zlfast_ptr' pointer in
+ * the fixed length portion at the front of the struct.  This pointer
+ * both enables us to find the faster stuff, and in the case of
+ * MPOL_BIND zonelists, (which will just set the zlfast_ptr to NULL)
+ * to know that the faster stuff is not there.
+ *
+ * The end result is that struct zonelists come in two flavors:
+ *  1) The full, fixed length version, shown below, and
+ *  2) The custom zonelists for MPOL_BIND.
+ * These custom zonelists have a NULL zlfast_ptr and no zlfast.
+ *
+ * Even though there may be multiple CPU cores on a node modifying
+ * fullnodes or last_full_zap in the same zonelist_faster at the same
+ * time, we don't lock it.  This is just hint data - if it is wrong now
+ * and then, the allocator must still function, perhaps slower.
+ */
+struct zonelist_faster {
+	nodemask_t fullnodes;		/* nodes recently lacking free memory */
+	unsigned long last_full_zap;	/* jiffies when fullnodes last zero'd */
+	unsigned short node_id[MAX_NUMNODES * MAX_NR_ZONES]; /* zone -> nid */
+};
+#else
+struct zonelist_faster;
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
+ * If zlfast_ptr is not NULL, then it is just the address of zlfast,
+ * as explained above.  If zlfast_ptr is NULL, there is no zlfast.
  */
+
 struct zonelist {
+	struct zonelist_faster *zlfast_ptr;		     // NULL or &zlfast
 	struct zone *zones[MAX_NUMNODES * MAX_NR_ZONES + 1]; // NULL delimited
+#ifdef CONFIG_NUMA
+	struct zonelist_faster zlfast;			     // optional ...
+#endif
 };
 
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
--- 2.6.18-rc7-mm1.orig/mm/page_alloc.c	2006-09-22 14:13:37.000000000 -0700
+++ 2.6.18-rc7-mm1/mm/page_alloc.c	2006-09-25 01:13:30.000000000 -0700
@@ -935,8 +935,90 @@ int zone_watermark_ok(struct zone *z, in
 	return 1;
 }
 
+#ifdef CONFIG_NUMA
+/*
+ * zlf_setup - Setup for "zonelist faster".  Uses cached zone data
+ * to skip over zones that are not allowed by the cpuset, or that
+ * have been recently (in last second) found to be nearly full.
+ * See further comments in mmzone.h.  Reduces cache footprint of
+ * zonelist scans that have to skip over alot of full or unallowed
+ * nodes.  Returns true if should activate zlf_zone_worth_trying()
+ * this scan.
+ */
+static int zlf_setup(struct zonelist *zonelist, int alloc_flags,
+				nodemask_t *zlf_good)
+{
+	nodemask_t *allowednodes;	/* mems_allowed or all online nodes */
+	struct zonelist_faster *zlf;	/* cached zonelist speedup info */
+
+	zlf = zonelist->zlfast_ptr;
+	if (!zlf)
+		return 0;
+
+	allowednodes = !in_interrupt() && (alloc_flags & ALLOC_CPUSET) ?
+				&current->mems_allowed : &node_online_map;
+
+	if (jiffies - zlf->last_full_zap > 1 * HZ) {
+		nodes_clear(zlf->fullnodes);
+		zlf->last_full_zap = jiffies;
+	}
+	/* Good nodes: allowed but not full nodes */
+	nodes_andnot(*zlf_good, *allowednodes, zlf->fullnodes);
+	return 1;
+}
+
+/*
+ * Given 'z' scanning a zonelist, index into the corresponding node_id
+ * in zlf->node_id[], and determine if that node_id is set in zlf_good.
+ * If it's set, that's a "good" node - allowed by the current cpuset and
+ * so far as we know, not full.  Good nodes are worth examining further
+ * for free memory meeting our requirements.
+ */
+static int zlf_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+				nodemask_t *zlf_good)
+{
+	struct zonelist_faster *zlf;	/* cached zonelist speedup info */
+
+	zlf = zonelist->zlfast_ptr;
+	return node_isset(zlf->node_id[z - zonelist->zones], *zlf_good);
+}
+
 /*
- * get_page_from_freeliest goes through the zonelist trying to allocate
+ * Given 'z' scanning a zonelist, index into the corresponding node_id
+ * in zlf->node_id[], and mark that node_id set in zlf->fullnodes, so
+ * that subsequent attempts to allocate a page on the current node don't
+ * waste time looking at that node.
+ */
+static void zlf_zone_full(struct zonelist *zonelist, struct zone **z)
+{
+	struct zonelist_faster *zlf;	/* cached zonelist speedup info */
+
+	zlf = zonelist->zlfast_ptr;
+	node_set(zlf->node_id[ z - zonelist->zones], zlf->fullnodes);
+}
+
+
+#else	/* CONFIG_NUMA */
+
+static int zlf_setup(struct zonelist *zonelist, int alloc_flags,
+				nodemask_t *zlf_good)
+{
+	return 0;
+}
+
+static int zlf_zone_worth_trying(struct zonelist *zonelist, struct zone **z,
+				nodemask_t *zlf_good)
+{
+	return 1;
+}
+
+static void zlf_zone_full(struct zonelist *zonelist, struct zone **z)
+{
+}
+#endif	/* CONFIG_NUMA */
+
+/*
+ * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
  */
 static struct page *
@@ -947,12 +1029,19 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	struct page *page = NULL;
 	int classzone_idx = zone_idx(*z);
 	struct zone *zone;
+	nodemask_t zlf_good;	/* good means allowed but not full */
+	int zlf_active = 0;	/* if set, then just try good nodes */
+	int zlf_scan = 1;	/* zlf_scan: 1 - do zlf_active; 2 - don't */
 
+retry:
 	/*
 	 * Go through the zonelist once, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
 	do {
+		if (NUMA_BUILD && zlf_active &&
+			!zlf_zone_worth_trying(zonelist, z, &zlf_good))
+				continue;
 		zone = *z;
 		if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
 			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
@@ -972,15 +1061,33 @@ get_page_from_freelist(gfp_t gfp_mask, u
 			if (!zone_watermark_ok(zone , order, mark,
 				    classzone_idx, alloc_flags))
 				if (!zone_reclaim_mode ||
-				    !zone_reclaim(zone, gfp_mask, order))
+				    !zone_reclaim(zone, gfp_mask, order)) {
+				    	if (NUMA_BUILD && zlf_active)
+						zlf_zone_full(zonelist, z);
 					continue;
+				}
 		}
 
 		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
 		if (page) {
 			break;
 		}
+		if (unlikely(NUMA_BUILD && zlf_scan == 1 &&
+						z == zonelist->zones)) {
+			/* delay zlf_setup until 1st zone tried */
+			zlf_active = zlf_setup(zonelist, alloc_flags, &zlf_good);
+			zlf_scan = 2;
+		}
+		if (NUMA_BUILD && zlf_active)
+			zlf_zone_full(zonelist, z);
 	} while (*(++z) != NULL);
+
+	if (unlikely(NUMA_BUILD && page == NULL && zlf_active)) {
+		/* Let's try this again, this time more thoroughly. */
+		zlf_active = 0;
+		z = zonelist->zones;
+		goto retry;
+	}
 	return page;
 }
 
@@ -1055,21 +1162,13 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
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
@@ -1627,6 +1726,29 @@ static void __meminit build_zonelists(pg
 	}
 }
 
+/* Construct the zonelist performance cache - see further mmzone.h */
+static void __meminit build_zonelist_faster(pg_data_t *pgdat)
+{
+	int i;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		struct zonelist *zonelist;
+		struct zonelist_faster *zlf;
+		int j;
+
+		zonelist = pgdat->node_zonelists + i;
+		zonelist->zlfast_ptr = zlf = &zonelist->zlfast;
+		nodes_clear(zlf->fullnodes);
+		for (j = 0; j < ARRAY_SIZE(zlf->node_id); j++) {
+			struct zone *z = zonelist->zones[j];
+
+			if (!z)
+				break;
+			zlf->node_id[j] = zone_to_nid(z);
+		}
+	}
+}
+
 #else	/* CONFIG_NUMA */
 
 static void __meminit build_zonelists(pg_data_t *pgdat)
@@ -1664,14 +1786,26 @@ static void __meminit build_zonelists(pg
 	}
 }
 
+/* non-NUMA variant of zonelist performance cache - just NULL zlfast_ptr */
+static void __meminit build_zonelist_faster(pg_data_t *pgdat)
+{
+	int i;
+
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		pgdat->node_zonelists[i].zlfast_ptr = NULL;
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
+		build_zonelist_faster(NODE_DATA(nid));
+	}
 	return 0;
 }
 
--- 2.6.18-rc7-mm1.orig/mm/mempolicy.c	2006-09-22 14:13:00.000000000 -0700
+++ 2.6.18-rc7-mm1/mm/mempolicy.c	2006-09-23 19:46:15.000000000 -0700
@@ -141,9 +141,11 @@ static struct zonelist *bind_zonelist(no
 	enum zone_type k;
 
 	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
+	max++;			/* space for zlfast_ptr (see mmzone.h) */
 	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
 	if (!zl)
 		return NULL;
+	zl->zlfast_ptr = NULL;
 	num = 0;
 	/* First put in the highest zones from all nodes, then all the next 
 	   lower zones etc. Avoid empty zones because the memory allocator

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
