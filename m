Subject: Suspect use of "first_zones_zonelist()"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Tue, 22 Apr 2008 11:17:24 -0400
Message-Id: <1208877444.5534.34.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

I was testing my "lazy migration" patches and noticed something
interesting about first_zones_zonelist().  I use this function to find
the target node for MPOL_BIND policy to determine if a page is
"misplaced" and should be migrated.  In my testing, I found that I was
always "off by one".  E.g., if my mempolicy nodemask contained only node
2, I'd migrate to node 3.  If it contained node 3, I'd migrate to node 0
[on a 4-node platform], etc.

Following the usage in slab_node(), I was doing something like:

zr = first_zones_zonelist(node_zonelist(nid, ...), gfp_zone(...),
&pol->v.vnodes, &dummy);
newnid = zonelist_node_idx(zr);

Turns out that the return value is the NEXT zoneref in the zonelist
AFTER the one of interest--i.e., the first that satisfies any nodemask
constraint.  I renamed 'dummy' to 'zone', ignore the return value and
use:  newnid = zone->node.  [I guess I could use zonelist_node_idx(zr
-1) as well.]  This results in page migration to the expected node.

Anyway, after discovering this, I checked other usages of
first_zones_zonelist() outside of the iterator macros, and I THINK they
might be making the same mistake?

Here's a patch that "fixes" these.  Do you agree?  Or am I
misunderstanding this area [again!]?

Lee

PATCH fix off-by-one usage of first_zones_zonelist()

Against:  2.6.25-rc8-mm2

The return value of first_zones_zonelist() is actually the zoneref
AFTER the "requested zone"--i.e., the first zone in the zonelist
that satisfies any nodemask constraint.  The "requested zone" is
returned via the @zone parameter.  The returned zoneref is intended
to be passed to next_zones_zonelist() on subsequent iterations.

Fix up slab_node() and get_page_from_freelist() to use the requested
zone, rather than the next one in the list.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c  |    9 ++++-----
 mm/page_alloc.c |    2 +-
 2 files changed, 5 insertions(+), 6 deletions(-)

Index: linux-2.6.25-rc8-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.25-rc8-mm2.orig/mm/mempolicy.c	2008-04-22 10:06:29.000000000 -0400
+++ linux-2.6.25-rc8-mm2/mm/mempolicy.c	2008-04-22 10:11:22.000000000 -0400
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
Index: linux-2.6.25-rc8-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc8-mm2.orig/mm/page_alloc.c	2008-04-22 10:00:58.000000000 -0400
+++ linux-2.6.25-rc8-mm2/mm/page_alloc.c	2008-04-22 10:16:32.000000000 -0400
@@ -1414,7 +1414,7 @@ get_page_from_freelist(gfp_t gfp_mask, n
 
 	z = first_zones_zonelist(zonelist, high_zoneidx, nodemask,
 							&preferred_zone);
-	classzone_idx = zonelist_zone_idx(z);
+	classzone_idx = zonelist_zone_idx(z - 1); /* z is next zone in list */
 
 zonelist_scan:
 	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
