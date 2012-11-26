Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4A94C6B006E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 13:33:35 -0500 (EST)
Date: Mon, 26 Nov 2012 13:32:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
Message-ID: <20121126183242.GA9894@cmpxchg.org>
References: <20121126100102.GH8218@suse.de>
 <20121126130504.29434.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126130504.29434.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: mgorman@suse.de, dave@linux.vnet.ibm.com, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

Hi George,

On Mon, Nov 26, 2012 at 08:05:04AM -0500, George Spelvin wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> > Ok, can you try this patch from Rik on top as well please? This is in
> > addition to Dave Hansen's accounting fix.
> > 
> > ---8<---
> > From: Rik van Riel <riel@redhat.com>
> > Subject: mm,vmscan: only loop back if compaction would fail in all zones
> 
> Booted and running.  Judging from the patch, the expected result is
> "stops hanging", as opposed to more informative diagnostics, so I'll
> keep you posted.
> 
> Peraonally, I like to use "bool" for such flags where possible;
> it helps document the intent of the variable better.

Any chance you could test with this fix instead, in addition to Dave's
accounting fix?  It's got bool and everything!

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: vmscan: fix endless loop in kswapd balancing

Kswapd does not in all places have the same criteria for when it
considers a zone balanced.  This leads to zones being not reclaimed
because they are considered just fine and other checks to loop over
the zonelist again because they are considered unbalanced.

Add a function, zone_balanced(), that checks the watermark, and, for
higher order allocations, if compaction has enough free memory.  Then
use it uniformly for when kswapd needs to check if a zone is balanced.

Reported-by: George Spelvin <linux@horizon.com>
Reported-by: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Tested-by: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: stable@kernel.org [3.4+]
---
 mm/vmscan.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 48550c6..3b0aef4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2397,6 +2397,19 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 	} while (memcg);
 }
 
+static bool zone_balanced(struct zone *zone, int order,
+			  unsigned long balance_gap, int classzone_idx)
+{
+	if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone) +
+				    balance_gap, classzone_idx, 0))
+		return false;
+
+	if (COMPACTION_BUILD && order && !compaction_suitable(zone, order))
+		return false;
+
+	return true;
+}
+
 /*
  * pgdat_balanced is used when checking if a node is balanced for high-order
  * allocations. Only zones that meet watermarks and are in a zone allowed
@@ -2475,8 +2488,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 			continue;
 		}
 
-		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
-							i, 0))
+		if (!zone_balanced(zone, order, 0, i))
 			all_zones_ok = false;
 		else
 			balanced += zone->present_pages;
@@ -2585,8 +2597,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				break;
 			}
 
-			if (!zone_watermark_ok_safe(zone, order,
-					high_wmark_pages(zone), 0, 0)) {
+			if (!zone_balanced(zone, order, 0, 0)) {
 				end_zone = i;
 				break;
 			} else {
@@ -2662,9 +2673,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				testorder = 0;
 
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
-				    !zone_watermark_ok_safe(zone, testorder,
-					high_wmark_pages(zone) + balance_gap,
-					end_zone, 0)) {
+			    !zone_balanced(zone, testorder,
+					   balance_gap, end_zone)) {
 				shrink_zone(zone, &sc);
 
 				reclaim_state->reclaimed_slab = 0;
@@ -2691,8 +2701,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				continue;
 			}
 
-			if (!zone_watermark_ok_safe(zone, testorder,
-					high_wmark_pages(zone), end_zone, 0)) {
+			if (!zone_balanced(zone, testorder, 0, end_zone)) {
 				all_zones_ok = 0;
 				/*
 				 * We are still under min water mark.  This
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
