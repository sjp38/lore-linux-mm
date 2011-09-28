Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB109000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 02:57:32 -0400 (EDT)
Received: by yxi19 with SMTP id 19so8113306yxi.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 23:57:30 -0700 (PDT)
Date: Wed, 28 Sep 2011 15:57:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 1/2]vmscan: correct all_unreclaimable for zone without
 lru pages
Message-ID: <20110928065721.GA15021@barrios-desktop>
References: <1317108184.29510.200.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317108184.29510.200.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@google.com>, Michal Hocko <mhocko@suse.cz>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2011 at 03:23:04PM +0800, Shaohua Li wrote:
> I saw DMA zone always has ->all_unreclaimable set. The reason is the high zones
> are big, so zone_watermark_ok/_safe() will always return false with a high
> classzone_idx for DMA zone, because DMA zone's lowmem_reserve is big for a high
> classzone_idx. When kswapd runs into DMA zone, it doesn't scan/reclaim any
> pages(no pages in lru), but mark the zone as all_unreclaimable. This can
> happen in other low zones too.

Good catch!

> This is confusing and can potentially cause oom. Say a low zone has
> all_unreclaimable when high zone hasn't enough memory. Then allocating
> some pages in low zone(for example reading blkdev with highmem support),
> then run into direct reclaim. Since the zone has all_unreclaimable set,
> direct reclaim might reclaim nothing and an oom reported. If
> all_unreclaimable is unset, the zone can actually reclaim some pages.
> If all_unreclaimable is unset, in the inner loop of balance_pgdat we always have
> all_zones_ok 0 when checking a low zone's watermark. If high zone watermark isn't
> good, there is no problem. Otherwise, we might loop one more time in the outer
> loop, but since high zone watermark is ok, the end_zone will be lower, then low
> zone's watermark check will be ok and the outer loop will break. So looks this
> doesn't bring any problem.

I think it would be better to correct zone_reclaimable.
My point is zone_reclaimable should consider zone->pages_scanned.
The point of the function is how many pages scanned VS how many pages remained in LRU.
If reclaimer doesn't scan the zone at all because of no lru pages, it shouldn't tell
the zone is all_unreclaimable.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4480f67..0749b6e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2150,7 +2150,18 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 
 static bool zone_reclaimable(struct zone *zone)
 {
-       return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+       bool reclaimable = true;
+       /*
+        * Sometime lower(ex, DMA) zone may have no lru page
+        * while it has a big lowmem_reserve for higher zone.
+        * In such case, the zone may set all_unreclaimable
+        * when it is used for fallback high zone. But it wouldn't
+        * be reset as it has no freeable/scannable page.
+        * So, let's return *true* in case of no scanning.
+        */
+       if (zone->pages_scanned)
+               reclaimable = zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+       return reclaimable;
 }

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
