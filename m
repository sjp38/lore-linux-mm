Date: Wed, 25 Jul 2007 12:16:46 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070725111646.GA9098@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On (24/07/07 21:20), Christoph Lameter didst pronounce:
> The outcome of the 2.6.23 merge was surprising. No antifrag but only 
> ZONE_MOVABLE. ZONE_MOVABLE is the highest zone.
> 
> For the NUMA layer this has some weird consequences if ZONE_MOVABLE is populated
> 
> 1. It is the highest zone.
> 
> 2. Thus policy_zone == ZONE_MOVABLE
> 
> ZONE_MOVABLE contains only movable allocs by default. That is anonymous 
> pages and page cache pages?
> 
> The NUMA layer only supports NUMA policies for the highest zone. 
> Thus NUMA policies can control anonymous pages and the page cache pages 
> allocated from ZONE_MOVABLE. 
> 
> However, NUMA policies will no longer affect non pagecache and non 
> anonymous allocations. So policies can no longer redirect slab allocations 
> and huge page allocations (unless huge page allocations are moved to 
> ZONE_MOVABLE). And there are likely other allocations that are not 
> movable.
> 
> If ZONE_MOVABLE is off then things should be working as normal.
> 
> Doesnt this mean that ZONE_MOVABLE is incompatible with CONFIG_NUMA?
>  

No but it has to be dealt with. I would have preferred this was highlighted
earlier but there is a candidate fix below.  It appears to be the minimum
solution to allow policies to work as they do today but remaining compatible
with ZONE_MOVABLE. It works by

o check_highest_zone will be the highest populated zone that is not ZONE_MOVEABLE
o bind_zonelist builds a zonelist of all populated zones, not policy_zone and lower
o The page allocator checks what the highest usable zone is and ignores
  zones in the zonelist that should not be used

This allows some other interesting possibilities

o We could have just one zonelist per node if the page allocator will
  skip over unsuitable zones for the gfp_mask. That would save memory
o We could get rid of policy_zone altogether.

On the second point here, policy_zone and how it is used is a bit
mad. Particularly, its behaviour on machines with multiple zones is a
little unpredictable with cross-platform applications potentially behaving
different on IA64 than x86_64 for example.  However, a test patch that would
delete it looked as if it would break NUMAQ if a process was bound to nodes
2 and 3 but not 0 for example because slab allocations would fail. Similar,
it would have consequences on x86_64 with NORMAL and DMA32.

Here is the patch just to handle policies with ZONE_MOVABLE. The highest
zone still gets treated as it does today but allocations using ZONE_MOVABLE
will still be policied. It has been boot-tested and a basic compile job run
on a x86_64 NUMA machine (elm3b6 on test.kernel.org). Is there a
standard test for regression testing policies?

Comments?

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

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
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 71b84b4..e798be5 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -149,7 +144,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
 	   lower zones etc. Avoid empty zones because the memory allocator
 	   doesn't like them. If you implement node hot removal you
 	   have to fix that. */
-	k = policy_zone;
+	k = MAX_NR_ZONES - 1;
 	while (1) {
 		for_each_node_mask(nd, *nodes) { 
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40954fb..22485d5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1157,6 +1157,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	enum zone_type highest_zoneidx;
 
 zonelist_scan:
 	/*
@@ -1165,10 +1166,23 @@ zonelist_scan:
 	 */
 	z = zonelist->zones;
 
+	/* For memory policies, get the highest allowed zone by the flags */
+	if (NUMA_BUILD)
+		highest_zoneidx = gfp_zone(gfp_mask);
+
 	do {
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
+
+		/*
+		 * In NUMA, this could be a policy zonelist which contains
+		 * zones that may not be allowed by the current gfp_mask.
+		 * Check the zone is allowed by the current flags
+		 */
+		if (NUMA_BUILD && zone_idx(*z) > highest_zoneidx)
+			continue;
+
 		zone = *z;
 		if (unlikely(NUMA_BUILD && (gfp_mask & __GFP_THISNODE) &&
 			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
