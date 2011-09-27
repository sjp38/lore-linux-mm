Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8EABA9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:18:13 -0400 (EDT)
Subject: [patch 1/2]vmscan: correct all_unreclaimable for zone without lru
 pages
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Sep 2011 15:23:04 +0800
Message-ID: <1317108184.29510.200.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

I saw DMA zone always has ->all_unreclaimable set. The reason is the high zones
are big, so zone_watermark_ok/_safe() will always return false with a high
classzone_idx for DMA zone, because DMA zone's lowmem_reserve is big for a high
classzone_idx. When kswapd runs into DMA zone, it doesn't scan/reclaim any
pages(no pages in lru), but mark the zone as all_unreclaimable. This can
happen in other low zones too.
This is confusing and can potentially cause oom. Say a low zone has
all_unreclaimable when high zone hasn't enough memory. Then allocating
some pages in low zone(for example reading blkdev with highmem support),
then run into direct reclaim. Since the zone has all_unreclaimable set,
direct reclaim might reclaim nothing and an oom reported. If
all_unreclaimable is unset, the zone can actually reclaim some pages.
If all_unreclaimable is unset, in the inner loop of balance_pgdat we always have
all_zones_ok 0 when checking a low zone's watermark. If high zone watermark isn't
good, there is no problem. Otherwise, we might loop one more time in the outer
loop, but since high zone watermark is ok, the end_zone will be lower, then low
zone's watermark check will be ok and the outer loop will break. So looks this
doesn't bring any problem.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/vmscan.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-09-27 13:46:31.000000000 +0800
+++ linux/mm/vmscan.c	2011-09-27 15:09:29.000000000 +0800
@@ -2565,7 +2565,9 @@ loop_again:
 				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 				total_scanned += sc.nr_scanned;
 
-				if (nr_slab == 0 && !zone_reclaimable(zone))
+				if (nr_slab == 0 && !zone_reclaimable(zone) &&
+				    !zone_watermark_ok_safe(zone, order,
+				    high_wmark_pages(zone) + balance_gap, 0, 0))
 					zone->all_unreclaimable = 1;
 			}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
