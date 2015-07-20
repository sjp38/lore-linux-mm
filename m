Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 370219003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:29 -0400 (EDT)
Received: by wgmn9 with SMTP id n9so124042282wgm.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:28 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id jf20si11992169wic.44.2015.07.20.01.00.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id BFC1598BBA
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:21 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [PATCH 02/10] mm, page_alloc: Remove unnecessary parameter from zone_watermark_ok_safe
Date: Mon, 20 Jul 2015 09:00:11 +0100
Message-Id: <1437379219-9160-3-git-send-email-mgorman@suse.com>
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

No user of zone_watermark_ok_safe() specifies alloc_flags. This patch
removes the unnecessary parameter.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h | 2 +-
 mm/page_alloc.c        | 5 +++--
 mm/vmscan.c            | 4 ++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 754289f371fa..672ac437c43c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -729,7 +729,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool zone_watermark_ok(struct zone *z, unsigned int order,
 		unsigned long mark, int classzone_idx, int alloc_flags);
 bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
-		unsigned long mark, int classzone_idx, int alloc_flags);
+		unsigned long mark, int classzone_idx);
 enum memmap_context {
 	MEMMAP_EARLY,
 	MEMMAP_HOTPLUG,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8db0b6d66165..4b35b196aeda 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2207,6 +2207,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
+
 #ifdef CONFIG_CMA
 	/* If allocation can't use CMA areas don't use free CMA pages */
 	if (!(alloc_flags & ALLOC_CMA))
@@ -2236,14 +2237,14 @@ bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 }
 
 bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
-			unsigned long mark, int classzone_idx, int alloc_flags)
+			unsigned long mark, int classzone_idx)
 {
 	long free_pages = zone_page_state(z, NR_FREE_PAGES);
 
 	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
 		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
 
-	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
+	return __zone_watermark_ok(z, order, mark, classzone_idx, 0,
 								free_pages);
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e61445dce04e..f1d8eae285f2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2454,7 +2454,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
 			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
 	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
-	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
+	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0);
 
 	/*
 	 * If compaction is deferred, reclaim up to a point where
@@ -2937,7 +2937,7 @@ static bool zone_balanced(struct zone *zone, int order,
 			  unsigned long balance_gap, int classzone_idx)
 {
 	if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone) +
-				    balance_gap, classzone_idx, 0))
+				    balance_gap, classzone_idx))
 		return false;
 
 	if (IS_ENABLED(CONFIG_COMPACTION) && order && compaction_suitable(zone,
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
