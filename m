Date: Thu, 26 Jul 2007 23:59:20 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070726225920.GA10225@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com> <20070726132336.GA18825@skynet.ie> <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (26/07/07 11:07), Christoph Lameter didst pronounce:
> On Thu, 26 Jul 2007, Mel Gorman wrote:
> 
> > > How about changing __alloc_pages to lookup the zonelist on its own based 
> > > on a node parameter and a set of allowed nodes? That may significantly 
> > > clean up the memory policy layer and the cpuset layer. But it will 
> > > increase the effort to scan zonelists on each allocation. A large system 
> > > with 1024 nodes may have more than 1024 zones on each nodelist!
> > > 
> > 
> > That sounds like it would require the creation of a zonelist for each
> > allocation attempt. That is not ideal as there is no place to allocate
> > the zonelist during __alloc_pages(). It's not like it can call
> > kmalloc().
> 
> Nope it would just require scanning the full zonelists on every alloc as 
> you already propose.
> 

Right. For this current problem, I would rather not to that. I would rather
fix the bug at hand for 2.6.23 and aim to reduce the number of zonelists in
the next timeframe after a spell in -mm and wider testing. This is to reduce
the risk of introducing performance regressions for a bugfix.

> > > Nope it would not fail. NUMAQ has policy_zone == HIGHMEM and slab 
> > > allocations do not use highmem.
> > 
> > It would fail if policy_zone didn't exist, that was my point. Without
> > policy_zone, we apply policy to all allocations and that causes
> > problems.
> 
> policy_zone can not exist due to ZONE_DMA32 ZONE_NORMAL issues. See my 
> other email.
> 
> 
> > I ran the patch on a wide variety of machines, NUMA and non-NUMA. The
> > non-NUMA machines showed no differences as you would expect for
> > kernbench and aim9. On NUMA machines, I saw both small gains and small
> > regressions. By and large, the performance was the same or within 0.08%
> > for kernbench which is within noise basically.
> 
> Sound okay.
> 
> > It might be more pronounced on larger NUMA machines though, I cannot
> > generate those figures.
> 
> I say lets go with the filtering. That would allow us to also catch other 
> issues that are now developing on x86_64 with ZONE_NORMAL and ZONE_DMA32.
>  
> > I'll try adding a should_filter to zonelist that is only set for
> > MPOL_BIND and see what it looks like.
> 
> Maybe that is not worth it.

This patch filters only when MPOL_BIND is in use. In non-numa, the
checks do not exist and in NUMA cases, the filtering usually does not
take place. I'd like this to be the bug fix for policy + ZONE_MOVABLE
and then deal with reducing zonelists to see if there is any performance
gain as well as a simplification in how policies and cpusets are
implemented.

Testing shows no difference on non-numa as you'd expect and on NUMA machines,
there are very small differences on NUMA (kernbench figures range from -0.02%
to 0.15% differences on machines). Lee, can you test this patch in relation
to MPOL_BIND?  I'll look at the numactl tests tomorrow as well.

Comments?

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index e147cf5..5bdd656 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -166,7 +166,7 @@ extern enum zone_type policy_zone;
 
 static inline void check_highest_zone(enum zone_type k)
 {
-	if (k > policy_zone)
+	if (k > policy_zone && k != ZONE_MOVABLE)
 		policy_zone = k;
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index da8eb8a..eb7cb56 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -411,6 +411,24 @@ struct zonelist {
 #endif
 };
 
+#ifdef CONFIG_NUMA
+/*
+ * Only custom zonelists like MPOL_BIND need to be filtered as part of
+ * policies. As described in the comment for struct zonelist_cache, these
+ * zonelists will not have a zlcache so zlcache_ptr will not be set. Use
+ * that to determine if the zonelists needs to be filtered or not.
+ */
+static inline int alloc_should_filter_zonelist(struct zonelist *zonelist)
+{
+	return !zonelist->zlcache_ptr;
+}
+#else
+static inline int alloc_should_filter_zonelist(struct zonelist *zonelist)
+{
+	return 0;
+}
+#endif /* CONFIG_NUMA */
+
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
 struct node_active_region {
 	unsigned long start_pfn;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 71b84b4..172abff 100644
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40954fb..99c5a53 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1157,6 +1157,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	enum zone_type highest_zoneidx = -1; /* Gets set for policy zonelists */
 
 zonelist_scan:
 	/*
@@ -1166,6 +1167,18 @@ zonelist_scan:
 	z = zonelist->zones;
 
 	do {
+		/*
+		 * In NUMA, this could be a policy zonelist which contains
+		 * zones that may not be allowed by the current gfp_mask.
+		 * Check the zone is allowed by the current flags
+		 */
+		if (unlikely(alloc_should_filter_zonelist(zonelist))) {
+			if (highest_zoneidx == -1)
+				highest_zoneidx = gfp_zone(gfp_mask);
+			if (zone_idx(*z) > highest_zoneidx)
+				continue;
+		}
+
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
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
