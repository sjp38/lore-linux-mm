Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3E85290023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 10:45:04 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/4] mm: vmscan: Do not apply pressure to slab if we are not applying pressure to zone
Date: Fri, 24 Jun 2011 15:44:55 +0100
Message-Id: <1308926697-22475-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1308926697-22475-1-git-send-email-mgorman@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

During allocator-intensive workloads, kswapd will be woken frequently
causing free memory to oscillate between the high and min watermark.
This is expected behaviour.

When kswapd applies pressure to zones during node balancing, it checks
if the zone is above a high+balance_gap threshold. If it is, it does
not apply pressure but it unconditionally shrinks slab on a global
basis which is excessive. In the event kswapd is being kept awake due to
a high small unreclaimable zone, it skips zone shrinking but still
calls shrink_slab().

Once pressure has been applied, the check for zone being unreclaimable
is being made before the check is made if all_unreclaimable should be
set. This miss of unreclaimable can cause has_under_min_watermark_zone
to be set due to an unreclaimable zone preventing kswapd backing off
on congestion_wait().

Reported-and-tested-by: PA!draig Brady <P@draigBrady.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 841e3bf..9cebed1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2507,18 +2507,18 @@ loop_again:
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone) + balance_gap,
-					end_zone, 0))
+					end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);
-			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-			total_scanned += sc.nr_scanned;
 
-			if (zone->all_unreclaimable)
-				continue;
-			if (nr_slab == 0 &&
-			    !zone_reclaimable(zone))
-				zone->all_unreclaimable = 1;
+				reclaim_state->reclaimed_slab = 0;
+				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
+				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+				total_scanned += sc.nr_scanned;
+
+				if (nr_slab == 0 && !zone_reclaimable(zone))
+					zone->all_unreclaimable = 1;
+			}
+
 			/*
 			 * If we've done a decent amount of scanning and
 			 * the reclaim ratio is low, start doing writepage
@@ -2528,6 +2528,9 @@ loop_again:
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
 
+			if (zone->all_unreclaimable)
+				continue;
+
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), end_zone, 0)) {
 				all_zones_ok = 0;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
