Message-Id: <200610201953.k9KJrjbD032332@shell0.pdx.osdl.net>
Subject: [patch 3/4] vmscan: fix temp_priority in __zone_reclaim
From: akpm@osdl.org
Date: Fri, 20 Oct 2006 12:53:45 -0700
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, clameter@engr.sgi.com, mbligh@mbligh.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

__zone_reclaim() isn't modifying zone->prev_priority.  But zone->prev_priority
is used in the decision whether or not to bring mapped pages onto the inactive
list.  Hence there's a risk here that __zone_reclaim() will fail because
zone->prev_priority ir large (ie: low urgency) and lots of mapped pages end up
stuck on the active list.

Fix that up by decreasing (ie making more urgent) zone->prev_priority as
__zone_reclaim() scans the zone's pages.

This bug perhaps explains why ZONE_RECLAIM_PRIORITY was created.  It should be
possible to remove that now, and to just start out at DEF_PRIORITY?

Cc: Martin Bligh <mbligh@mbligh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/vmscan.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN mm/vmscan.c~vmscan-fix-temp_priority-in-__zone-reclaim mm/vmscan.c
--- a/mm/vmscan.c~vmscan-fix-temp_priority-in-__zone-reclaim
+++ a/mm/vmscan.c
@@ -1640,6 +1640,7 @@ static int __zone_reclaim(struct zone *z
 		 */
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
+			note_zone_scanning_priority(zone, priority);
 			nr_reclaimed += shrink_zone(priority, zone, &sc);
 			priority--;
 		} while (priority >= 0 && nr_reclaimed < nr_pages);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
