Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 940C68D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 08:41:25 -0500 (EST)
Date: Thu, 27 Jan 2011 13:40:58 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110127134057.GA32039@csn.ul.ie>
References: <1295841406.1949.953.camel@sli10-conroe> <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie> <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110126174236.GV18984@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2011 at 05:42:37PM +0000, Mel Gorman wrote:
> On Wed, Jan 26, 2011 at 04:36:55PM +0000, Mel Gorman wrote:
> > > But the wmarks don't
> > > seem the real offender, maybe it's something related to the tiny pci32
> > > zone that materialize on 4g systems that relocate some little memory
> > > over 4g to make space for the pci32 mmio. I didn't yet finish to debug
> > > it.
> > > 
> > 
> > This has to be it. What I think is happening is that we're in balance_pgdat(),
> > the "Normal" zone is never hitting the watermark and we constantly call
> > "goto loop_again" trying to "rebalance" all zones.
> > 
> 
> Confirmed.
> <SNIP>

How about the following? Functionally it would work but I am concerned
that the logic in balance_pgdat() and kswapd() is getting out of hand
having being adjusted to work with a number of corner cases already. In
the next cycle, it could do with a "do-over" attempt to make it easier
to follow.

==== CUT HERE ====
mm: kswapd: Do not reclaim excessive pages from already balanced zones

When reclaiming for order-0 pages, kswapd requires that all zones be
balanced. Each cycle through balance_pgdat() does background ageing on all
zones if necessary and applies equal pressure on the inactive zone unless
a lot of pages are free already.

A "lot of free pages" is defined as 8*high_watermark which historically has
been reasonably fine as min_free_kbytes was small. However, on systems using
huge pages, it is recommended that min_free_kbytes is higher and it is tuned
with hugeadm --set-recommended-min_free_kbytes. With the introduction of
transparent huge page support, this recommended value is also applied. The
problem then is in the corner cases.

On X86-64 with 4G of memory, min_free_kbytes becomes 67584 so one would
expect around 68M of memory to be free. The Normal zone is approximately
35000 pages so under even normal memory pressure such as copying a large
file, it gets exhausted quickly. As it is getting exhausted, kswapd
applies pressure equally to all zones, including the DMA32 zone. DMA32 is
approximately 700,000 pages with a high watermark of around 23,000 pages. In
this situation, kswapd will reclaim around (23000*8) pages or 718M of pages
before the zone is ignored. What the user sees is kswapd constantly stuck
in D state and free memory far higher than it should be.

This patch addresses the problem by taking into account if kswapd is looping
in balance_pgdat() when deciding if a zone is balanced or not.  If the zone
is relatively small and kswapd is looping or preparing to sleep, then the
zone is considered balanced. If an allocator has hit the low watermark,
kswapd will stay awake (pgdat->kswapd_max_order or classzone_idx) will be
set and reread or will get woken later when real memory pressure exists.

Using a very basic test of cp /dev/sda6 /dev/null where sda6 was an 80G
partition, the amount of free memory without this patch hovered around
the 700M mark and around the 90M mark when applied which is closer to
expectations for the larger default min_free_kbytes with THP enabled.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   44 ++++++++++++++++++++++++++++++++++++++------
 1 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f5d90de..3d4ffd3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2228,6 +2228,35 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 	return balanced_pages > (present_pages >> 2);
 }
 
+static bool zone_balanced(struct zone *zone, int order, unsigned long mark,
+				int classzone_idx, bool firstscan)
+{
+	pg_data_t *pgdat = zone->zone_pgdat;
+
+	/*
+	 * If this is a relatively small zone and kswapd is looping
+	 * for order-0 pages, consider the zone to be balanced so
+	 * kswapd has a chance to go back to sleep. Direct reclaimers
+	 * will wake kswapd again if necessary. Otherwise there is a
+	 * risk that kswapd will reclaim an excessive number of pages
+	 * from larger zones even when allocators do not require it
+	 * due to balance_pgdat reclaiming pages from each zone unless
+	 * free pages > 8*high_watermark which is potentially a large
+	 * number of pages. 
+	 *
+	 * Small is considered to be node_present_pages >> 2 due to
+	 * the "free pages > 8*high_watermark" heuristic. The 
+	 * smallest possible low zone (DMA) and a small high zone
+	 * should in combination be related to the maximum amount
+	 * of memory kswapd will reclaim from the other zones.
+	 */
+	if (!firstscan && order == 0 &&
+			zone->present_pages < pgdat->node_present_pages >> 2)
+		return true;
+
+	return zone_watermark_ok_safe(zone, order, mark, classzone_idx, 0);
+}
+
 /* is kswapd sleeping prematurely? */
 static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 					int classzone_idx)
@@ -2258,8 +2287,8 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 			continue;
 		}
 
-		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
-							classzone_idx, 0))
+		if (!zone_balanced(zone, order, high_wmark_pages(zone),
+							classzone_idx, false))
 			all_zones_ok = false;
 		else
 			balanced += zone->present_pages;
@@ -2306,6 +2335,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
+	bool firstscan;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
@@ -2444,16 +2474,16 @@ loop_again:
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
 
-			if (!zone_watermark_ok_safe(zone, order,
-					high_wmark_pages(zone), end_zone, 0)) {
+			if (!zone_balanced(zone, order,
+					high_wmark_pages(zone), end_zone, firstscan)) {
 				all_zones_ok = 0;
 				/*
 				 * We are still under min water mark.  This
 				 * means that we have a GFP_ATOMIC allocation
 				 * failure risk. Hurry up!
 				 */
-				if (!zone_watermark_ok_safe(zone, order,
-					    min_wmark_pages(zone), end_zone, 0))
+				if (!zone_balanced(zone, order,
+					    min_wmark_pages(zone), end_zone, firstscan))
 					has_under_min_watermark_zone = 1;
 			} else {
 				/*
@@ -2520,6 +2550,8 @@ out:
 		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
 			order = sc.order = 0;
 
+		firstscan = false;
+
 		goto loop_again;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
