Date: Tue, 22 Apr 2008 17:15:25 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Suspect use of "first_zones_zonelist()"
Message-ID: <20080422161524.GA27624@csn.ul.ie>
References: <1208877444.5534.34.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1208877444.5534.34.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On (22/04/08 11:17), Lee Schermerhorn didst pronounce:
> Mel:
> 
> I was testing my "lazy migration" patches and noticed something
> interesting about first_zones_zonelist().  I use this function to find
> the target node for MPOL_BIND policy to determine if a page is
> "misplaced" and should be migrated.  In my testing, I found that I was
> always "off by one".  E.g., if my mempolicy nodemask contained only node
> 2, I'd migrate to node 3.  If it contained node 3, I'd migrate to node 0
> [on a 4-node platform], etc.
> 
> Following the usage in slab_node(), I was doing something like:
> 
> zr = first_zones_zonelist(node_zonelist(nid, ...), gfp_zone(...),
> &pol->v.vnodes, &dummy);
> newnid = zonelist_node_idx(zr);
> 
> Turns out that the return value is the NEXT zoneref in the zonelist
> AFTER the one of interest

Yes, the intention was that the cursor (zr) was meant to be pointing to
the next reference likely to be of interest. Bad usage of the cursor was
a pretty stupid mistake particularly as the cursor was implemented this
way intentionally.

/me beats self with clue-stick

> --i.e., the first that satisfies any nodemask
> constraint.  I renamed 'dummy' to 'zone', ignore the return value and
> use:  newnid = zone->node.  [I guess I could use zonelist_node_idx(zr
> -1) as well.] 

zr - 1 would be vunerable to the iterator implementation changing.

>  This results in page migration to the expected node.
> 

This use of zone instead of the zoneref cursor should be made throughout.

> Anyway, after discovering this, I checked other usages of
> first_zones_zonelist() outside of the iterator macros, and I THINK they
> might be making the same mistake?
> 

Yes, you're right.

> Here's a patch that "fixes" these.  Do you agree?  Or am I
> misunderstanding this area [again!]?
> 

No, I screwed up with the use of cursors and didn't get caught for it as
the effect would be very difficult to spot normally. I extended your patch
slightly below to catch the other callers. Can you take a read-through please?

> Lee
> 
> PATCH fix off-by-one usage of first_zones_zonelist()
> 
> Against:  2.6.25-rc8-mm2
> 
> The return value of first_zones_zonelist() is actually the zoneref
> AFTER the "requested zone"--i.e., the first zone in the zonelist
> that satisfies any nodemask constraint.  The "requested zone" is
> returned via the @zone parameter.  The returned zoneref is intended
> to be passed to next_zones_zonelist() on subsequent iterations.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/buffer.c     |    9 ++++-----
 mm/mempolicy.c  |    9 ++++-----
 mm/page_alloc.c |    4 ++--
 3 files changed, 10 insertions(+), 12 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/fs/buffer.c linux-2.6.25-mm1-fix-first_zone_zonelist/fs/buffer.c
--- linux-2.6.25-mm1-clean/fs/buffer.c	2008-04-22 10:30:02.000000000 +0100
+++ linux-2.6.25-mm1-fix-first_zone_zonelist/fs/buffer.c	2008-04-22 16:53:31.000000000 +0100
@@ -368,18 +368,17 @@ void invalidate_bdev(struct block_device
  */
 static void free_more_memory(void)
 {
-	struct zoneref *zrefs;
-	struct zone *dummy;
+	struct zone *zone;
 	int nid;
 
 	wakeup_pdflush(1024);
 	yield();
 
 	for_each_online_node(nid) {
-		zrefs = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
+		(void)first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
 						gfp_zone(GFP_NOFS), NULL,
-						&dummy);
-		if (zrefs->zone)
+						&zone);
+		if (zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
 						GFP_NOFS);
 	}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/mm/mempolicy.c linux-2.6.25-mm1-fix-first_zone_zonelist/mm/mempolicy.c
--- linux-2.6.25-mm1-clean/mm/mempolicy.c	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-fix-first_zone_zonelist/mm/mempolicy.c	2008-04-22 16:54:38.000000000 +0100
@@ -1396,14 +1396,13 @@ unsigned slab_node(struct mempolicy *pol
 		 * first node.
 		 */
 		struct zonelist *zonelist;
-		struct zoneref *z;
-		struct zone *dummy;
+		struct zone *zone;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
 		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
-		z = first_zones_zonelist(zonelist, highest_zoneidx,
+		(void)first_zones_zonelist(zonelist, highest_zoneidx,
 							&policy->v.nodes,
-							&dummy);
-		return zonelist_node_idx(z);
+							&zone);
+		return zone->node;
 	}
 
 	default:
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/mm/page_alloc.c linux-2.6.25-mm1-fix-first_zone_zonelist/mm/page_alloc.c
--- linux-2.6.25-mm1-clean/mm/page_alloc.c	2008-04-22 10:30:04.000000000 +0100
+++ linux-2.6.25-mm1-fix-first_zone_zonelist/mm/page_alloc.c	2008-04-22 16:58:19.000000000 +0100
@@ -1412,9 +1412,9 @@ get_page_from_freelist(gfp_t gfp_mask, n
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
-	z = first_zones_zonelist(zonelist, high_zoneidx, nodemask,
+	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
 							&preferred_zone);
-	classzone_idx = zonelist_zone_idx(z);
+	classzone_idx = zone_idx(preferred_zone);
 
 zonelist_scan:
 	/*

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
