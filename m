Date: Sat, 28 Jul 2007 16:28:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-Id: <20070728162844.9d5b8c6e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070727154519.GA21614@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	<20070725111646.GA9098@skynet.ie>
	<Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	<20070726132336.GA18825@skynet.ie>
	<Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	<20070726225920.GA10225@skynet.ie>
	<Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
	<20070727082046.GA6301@skynet.ie>
	<20070727154519.GA21614@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007 16:45:19 +0100
mel@skynet.ie (Mel Gorman) wrote:

> Obvious things that are outstanding;
> 
> o Compile-test parisc
> o Split patch in two to keep the zone_idx changes separetly
> o Verify zlccache is not broken
> o Have a version of __alloc_pages take a nodemask and ditch
>   bind_zonelist()
> 
> I can work on bringing this up to scratch during the cycle.
> 
> Patch as follows. Comments?
> 

I like this idea in general. My concern is zonelist scan cost.
 Hmm, can this be help ?

---
 include/linux/mmzone.h |    1 
 mm/page_alloc.c        |   51 +++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 50 insertions(+), 2 deletions(-)

Index: linux-2.6.23-rc1.test/include/linux/mmzone.h
===================================================================
--- linux-2.6.23-rc1.test.orig/include/linux/mmzone.h
+++ linux-2.6.23-rc1.test/include/linux/mmzone.h
@@ -406,6 +406,7 @@ struct zonelist_cache;
 
 struct zonelist {
 	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
+	unsigned short gfp_skip[MAX_NR_ZONES];
 	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
 #ifdef CONFIG_NUMA
 	struct zonelist_cache zlcache;			     // optional ...
Index: linux-2.6.23-rc1.test/mm/page_alloc.c
===================================================================
--- linux-2.6.23-rc1.test.orig/mm/page_alloc.c
+++ linux-2.6.23-rc1.test/mm/page_alloc.c
@@ -1158,13 +1158,14 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	enum zone_type highest_zoneidx = gfp_zone(gfp_mask);
+	int default_skip = zonelist->gfp_skip[highest_zoneidx];
 
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
-	z = zonelist->zones;
+	z = zonelist->zones + default_skip;
 
 	do {
 		if (should_filter_zone(*z, highest_zoneidx))
@@ -1235,6 +1236,7 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 	int do_retry;
 	int alloc_flags;
 	int did_some_progress;
+	int gfp_skip = zonelist->gfp_skip[gfp_zone(gfp_mask)];
 
 	might_sleep_if(wait);
 
@@ -1265,7 +1267,7 @@ restart:
 	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
-	for (z = zonelist->zones; *z; z++)
+	for (z = zonelist->zones + gfp_skip; *z; z++)
 		wakeup_kswapd(*z, order);
 
 	/*
@@ -2050,6 +2052,50 @@ static void build_zonelist_cache(pg_data
 
 #endif	/* CONFIG_NUMA */
 
+static inline 
+unsigned short find_first_zone(enum zone_type target, struct zonelist *zl)
+{
+	unsigned short index = 0;
+	struct zone *z;
+	z = zl->zones[index];
+	while (z != NULL) {
+		if (!should_filter_zone(z, target))
+			return index;
+		z = zl->zones[++index];
+	}
+	return 0;
+}
+/*
+ * record the first available zone per gfp.
+ */
+
+static void build_zonelist_skip(pg_data_t *pgdat)
+{
+	enum zone_type target;
+	unsigned short index;
+	struct zonelist *zl = &pgdat->node_zonelist;
+
+	target = gfp_zone(GFP_KERNEL|GFP_DMA);
+	index = find_first_zone(target, zl);
+	zl->gfp_skip[target] = index;
+
+	target = gfp_zone(GFP_KERNEL|GFP_DMA32);
+	index = find_first_zone(target, zl);
+	zl->gfp_skip[target] = index;
+
+	target = gfp_zone(GFP_KERNEL);
+	index = find_first_zone(target, zl);
+	zl->gfp_skip[target] = index;
+
+	target = gfp_zone(GFP_HIGHUSER);
+	index = find_first_zone(target, zl);
+	zl->gfp_skip[target] = index;
+
+	target = gfp_zone(GFP_HIGHUSER_MOVABLE);
+	index = find_first_zone(target, zl);
+	zl->gfp_skip[target] = index;
+}
+
 /* return values int ....just for stop_machine_run() */
 static int __build_all_zonelists(void *dummy)
 {
@@ -2058,6 +2104,7 @@ static int __build_all_zonelists(void *d
 	for_each_online_node(nid) {
 		build_zonelists(NODE_DATA(nid));
 		build_zonelist_cache(NODE_DATA(nid));
+		build_zonelist_skip(NODE_DATA(nid));
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
