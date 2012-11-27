Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E3E0C6B005A
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 15:49:45 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: vmscan: fix kswapd endless loop on higher order allocation
Date: Tue, 27 Nov 2012 15:48:35 -0500
Message-Id: <1354049315-12874-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Kswapd does not in all places have the same criteria for a balanced
zone.  Zones are only being reclaimed when their high watermark is
breached, but compaction checks loop over the zonelist again when the
zone does not meet the low watermark plus two times the size of the
allocation.  This gets kswapd stuck in an endless loop over a small
zone, like the DMA zone, where the high watermark is smaller than the
compaction requirement.

Add a function, zone_balanced(), that checks the watermark, and, for
higher order allocations, if compaction has enough free memory.  Then
use it uniformly to check for balanced zones.

This makes sure that when the compaction watermark is not met, at
least reclaim happens and progress is made - or the zone is declared
unreclaimable at some point and skipped entirely.

Reported-by: George Spelvin <linux@horizon.com>
Reported-by: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Reported-by: Tomas Racek <tracek@redhat.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Tested-by: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
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
