Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C963E6B0071
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 10:22:47 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 4/5] page allocator: Pre-emptively wake kswapd when high-order watermarks are hit
Date: Thu, 22 Oct 2009 15:22:35 +0100
Message-Id: <1256221356-26049-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When a high-order allocation fails, kswapd is kicked so that it reclaims
at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
allocations. Something has changed in recent kernels that affect the timing
where high-order GFP_ATOMIC allocations are now failing with more frequency,
particularly under pressure.

This patch pre-emptively checks if watermarks have been hit after a
high-order allocation completes successfully. If the watermarks have been
reached, kswapd is woken in the hope it fixes the watermarks before the
next GFP_ATOMIC allocation fails.

Warning, this patch is somewhat of a band-aid. If this makes a difference,
it still implies that something has changed that is either causing more
GFP_ATOMIC allocations to occur (such as the case with iwlagn wireless
driver) or make them more likely to fail.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   33 ++++++++++++++++++++++-----------
 1 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7f2aa3e..851df40 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1596,6 +1596,17 @@ try_next_zone:
 	return page;
 }
 
+static inline
+void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
+						enum zone_type high_zoneidx)
+{
+	struct zoneref *z;
+	struct zone *zone;
+
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
+		wakeup_kswapd(zone, order);
+}
+
 static inline int
 should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 				unsigned long pages_reclaimed)
@@ -1730,18 +1741,18 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			congestion_wait(BLK_RW_ASYNC, HZ/50);
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
-	return page;
-}
-
-static inline
-void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
-						enum zone_type high_zoneidx)
-{
-	struct zoneref *z;
-	struct zone *zone;
+	/*
+	 * If after a high-order allocation we are now below watermarks,
+	 * pre-emptively kick kswapd rather than having the next allocation
+	 * fail and have to wake up kswapd, potentially failing GFP_ATOMIC
+	 * allocations or entering direct reclaim
+	 */
+	if (unlikely(order) && page && !zone_watermark_ok(preferred_zone, order,
+				preferred_zone->watermark[ALLOC_WMARK_LOW],
+				zone_idx(preferred_zone), ALLOC_WMARK_LOW))
+		wake_all_kswapd(order, zonelist, high_zoneidx);
 
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
-		wakeup_kswapd(zone, order);
+	return page;
 }
 
 static inline int
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
