Date: Tue, 8 Aug 2006 09:45:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Cleanup: Add zone pointer to get_page_from_freelist
Message-ID: <Pine.LNX.4.64.0608080943520.27620@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There are frequent references to *z in get_page_from_freelist.

Add an explicit zone variable that can be used in all these places.

(This patch should follow the __GFP_THISNODE patch series).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/page_alloc.c	2006-08-08 09:23:23.323396326 -0700
+++ linux-2.6.18-rc3-mm2/mm/page_alloc.c	2006-08-08 09:43:26.038138979 -0700
@@ -910,35 +910,37 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	struct zone **z = zonelist->zones;
 	struct page *page = NULL;
 	int classzone_idx = zone_idx(*z);
+	struct zone *zone;
 
 	/*
 	 * Go through the zonelist once, looking for a zone with enough free.
 	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
 	 */
 	do {
+		zone = *z;
 		if (unlikely((gfp_mask & __GFP_THISNODE) &&
-			(*z)->zone_pgdat != zonelist->zones[0]->zone_pgdat))
+			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
 				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
-				!cpuset_zone_allowed(*z, gfp_mask))
+				!cpuset_zone_allowed(zone, gfp_mask))
 			continue;
 
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
 			if (alloc_flags & ALLOC_WMARK_MIN)
-				mark = (*z)->pages_min;
+				mark = zone->pages_min;
 			else if (alloc_flags & ALLOC_WMARK_LOW)
-				mark = (*z)->pages_low;
+				mark = zone->pages_low;
 			else
-				mark = (*z)->pages_high;
-			if (!zone_watermark_ok(*z, order, mark,
+				mark = zone->pages_high;
+			if (!zone_watermark_ok(zone , order, mark,
 				    classzone_idx, alloc_flags))
 				if (!zone_reclaim_mode ||
-				    !zone_reclaim(*z, gfp_mask, order))
+				    !zone_reclaim(zone, gfp_mask, order))
 					continue;
 		}
 
-		page = buffered_rmqueue(zonelist, *z, order, gfp_mask);
+		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
 		if (page) {
 			break;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
