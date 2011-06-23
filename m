Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB2F900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 11:24:26 -0400 (EDT)
Date: Thu, 23 Jun 2011 16:24:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: sandy bridge kswapd0 livelock with pagecache
Message-ID: <20110623152418.GN9396@suse.de>
References: <20110621103920.GF9396@suse.de>
 <4E0076C7.4000809@draigBrady.com>
 <20110621113447.GG9396@suse.de>
 <4E008784.80107@draigBrady.com>
 <20110621130756.GH9396@suse.de>
 <4E00A96D.8020806@draigBrady.com>
 <20110622094401.GJ9396@suse.de>
 <4E01C19F.20204@draigBrady.com>
 <20110623114646.GM9396@suse.de>
 <4E0339CF.8080407@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4E0339CF.8080407@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: P?draig Brady <P@draigBrady.com>
Cc: linux-mm@kvack.org

On Thu, Jun 23, 2011 at 02:04:15PM +0100, P?draig Brady wrote:
> On 23/06/11 12:46, Mel Gorman wrote:
> > Based on the information you have provided from sysrq and the profile,
> > I put together a theory as to what is going wrong for your machine at
> > least although I somehow doubt the same fix will work for Dan. Can you
> > try out the following please? It's against 2.6.38.8 (and presumably
> > Fedora) but will apply with offset against 2.6.39 and 3.0-rc4.
> > 
> > ==== CUT HERE ====
> > mm: vmscan: Correct check for kswapd sleeping in sleeping_prematurely
> > 
> > <SNIP>
> 
> No joy :(
> 

Theory 2 it is then. This is to be applied on top of the patch for
theory 1.

==== CUT HERE ====
mm: vmscan: Prevent kswapd doing excessive work when classzone is unreclaimable

During allocator-intensive workloads, kswapd will be woken frequently
causing free memory to oscillate between the high and min watermark.
This is expected behaviour.  Unfortunately, if the highest zone is
small, a problem occurs.

When the lower zones are below their min watermark, kswapd gets woken
as expected and starts to balance zones. If zones are unreclaimable,
they are ignored when the priority raises but priority is reset to
DEF_PRIORITY if SWAP_RECLAIM_MAX pages are reclaimed.

If the highest zone is small, kswapd can then get into a loop
reclaiming from lower zones and shrinking slab while never balancing
the node due to the highest zone being unreclaimable. As a small
highest zone is also first on the zonelist, it can easily get under its
min watermark quickly. This causes kswapd to miss a congestion_wait and
instead use a lot of CPU while reclaiming an excessive number of pages.

This patch checks if the node is balanced overall if the classzone
is unreclaimable. If the node is balanced overall, kswapd will stop
reclaiming and attempt to go to sleep.

Reported-by: Padraig Brady <P@draigBrady.com>
Not-signed-off-awaiting-confirmation: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a578535..dce95dd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2221,12 +2221,13 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 #endif
 
 /*
- * pgdat_balanced is used when checking if a node is balanced for high-order
- * allocations. Only zones that meet watermarks and are in a zone allowed
+ * pgdat_balanced is used for high-order allocations and for unreclaimable
+ * classzones. Only zones that meet watermarks and are in a zone allowed
  * by the callers classzone_idx are added to balanced_pages. The total of
  * balanced pages must be at least 25% of the zones allowed by classzone_idx
  * for the node to be considered balanced. Forcing all zones to be balanced
- * for high orders can cause excessive reclaim when there are imbalanced zones.
+ * for high orders can cause excessive reclaim when there are imbalanced zones
+ * or when the highest zone is very small.
  * The choice of 25% is due to
  *   o a 16M DMA zone that is balanced will not balance a zone on any
  *     reasonable sized machine
@@ -2381,7 +2382,6 @@ loop_again:
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
-				*classzone_idx = i;
 				break;
 			}
 		}
@@ -2468,12 +2468,12 @@ loop_again:
 				 * spectulatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
-				if (i <= *classzone_idx)
+				if (i <= end_zone)
 					balanced += zone->present_pages;
 			}
 
 		}
-		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
+		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, end_zone)))
 			break;		/* kswapd: all done */
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
@@ -2496,13 +2496,26 @@ loop_again:
 			break;
 	}
 out:
+	/*
+	 * When the classzone is a high zone but small, it is very easy for
+	 * it to become unreclaimable with the bulk of reclaim happening
+	 * at lower zones. At higher priorities, they are ignored but as
+	 * priority gets reset after SWAP_CLUSTER_MAX pages, kswapd can
+	 * loop continually trying to balance a small unreclaimable high
+	 * zone. If the classzone is unreclaimable, check if the node overall
+	 * is ok and if no, discontinue reclaiming to avoid excessive reclaim
+	 * and CPU usage.
+	 */
+	if (pgdat->node_zones[*classzone_idx].all_unreclaimable &&
+			pgdat_balanced(pgdat, balanced, *classzone_idx))
+		all_zones_ok = 1;
 
 	/*
 	 * order-0: All zones must meet high watermark for a balanced node
 	 * high-order: Balanced zones must make up at least 25% of the node
 	 *             for the node to be balanced
 	 */
-	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))) {
+	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced, end_zone)))) {
 		cond_resched();
 
 		try_to_freeze();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
