Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 588A8900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 13:00:01 -0400 (EDT)
Date: Thu, 23 Jun 2011 17:59:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: sandy bridge kswapd0 livelock with pagecache
Message-ID: <20110623165955.GO9396@suse.de>
References: <20110621113447.GG9396@suse.de>
 <4E008784.80107@draigBrady.com>
 <20110621130756.GH9396@suse.de>
 <4E00A96D.8020806@draigBrady.com>
 <20110622094401.GJ9396@suse.de>
 <4E01C19F.20204@draigBrady.com>
 <20110623114646.GM9396@suse.de>
 <4E0339CF.8080407@draigBrady.com>
 <20110623152418.GN9396@suse.de>
 <4E035C8B.1080905@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E035C8B.1080905@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: P?draig Brady <P@draigBrady.com>
Cc: linux-mm@kvack.org

On Thu, Jun 23, 2011 at 04:32:27PM +0100, P?draig Brady wrote:
> On 23/06/11 16:24, Mel Gorman wrote:
> > 
> > Theory 2 it is then. This is to be applied on top of the patch for
> > theory 1.
> > 
> > ==== CUT HERE ====
> > mm: vmscan: Prevent kswapd doing excessive work when classzone is unreclaimable
> 
> No joy :(
> 

Joy is indeed rapidly fleeing the vicinity.

Check /proc/sys/vm/laptop_mode . If it's set, unset it and try again.
If it's still broken, it's time for theory 3. Still against 2.6.38
and on top of theories 1+2.

==== CUT HERE ====
mm: vmscan: Do not apply pressure to slab if we are not applying pressure to zone

When kswapd applies pressure to zones during node balancing, it checks
if the zone is above a high+balance_gap threshold. If it is, it does
not apply pressure but it unconditionally shrinks slab on a global
basis which is excessive. In the event kswapd is being kept awake due to
a high small unreclaimable zone, it can end up spinning calling
shrink_slab() uselessly.

Once pressure has been applied, the check for zone being unreclaimable
is being made before the check is made if all_unreclaimable should
be set and avoids accounting for scanned in laptop_mode. This miss
of an unreclaimable check can cause has_under_min_watermark_zone to
be set due to an unreclaimable zone preventing kswapd backing off
on congestion_wait().

---
 mm/vmscan.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dce95dd..c8c0f5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2426,19 +2426,19 @@ loop_again:
 			 * zone has way too many pages free already.
 			 */
 			if (!zone_watermark_ok_safe(zone, order,
-					8*high_wmark_pages(zone), end_zone, 0))
-				shrink_zone(priority, zone, &sc);
-			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-			total_scanned += sc.nr_scanned;
+					8*high_wmark_pages(zone), end_zone, 0)) {
+				shrink_zone(priority, zone, &sc); 
+
+				reclaim_state->reclaimed_slab = 0;
+				nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
+							lru_pages);
+				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+				total_scanned += sc.nr_scanned;
+
+				if (nr_slab == 0 && !zone_reclaimable(zone))
+					zone->all_unreclaimable = 1;
+			}
 
-			if (zone->all_unreclaimable)
-				continue;
-			if (nr_slab == 0 &&
-			    !zone_reclaimable(zone))
-				zone->all_unreclaimable = 1;
 			/*
 			 * If we've done a decent amount of scanning and
 			 * the reclaim ratio is low, start doing writepage
@@ -2448,6 +2448,9 @@ loop_again:
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
 
+			if (zone->all_unreclaimable)
+				continue;
+
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), end_zone, 0)) {
 				all_zones_ok = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
