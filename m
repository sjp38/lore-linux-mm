Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id E547782F62
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 06:45:47 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so22025300wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 03:45:47 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id qq4si9873566wjc.5.2015.08.12.03.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 03:45:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id D558499007
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:45:36 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 02/10] mm, page_alloc: Remove unnecessary parameter from zone_watermark_ok_safe
Date: Wed, 12 Aug 2015 11:45:27 +0100
Message-Id: <1439376335-17895-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

No user of zone_watermark_ok_safe() specifies alloc_flags. This patch
removes the unnecessary parameter.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h | 2 +-
 mm/page_alloc.c        | 5 +++--
 mm/vmscan.c            | 4 ++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index decc99a007f5..8b86ec5df968 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -731,7 +731,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool zone_watermark_ok(struct zone *z, unsigned int order,
 		unsigned long mark, int classzone_idx, int alloc_flags);
 bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
-		unsigned long mark, int classzone_idx, int alloc_flags);
+		unsigned long mark, int classzone_idx);
 enum memmap_context {
 	MEMMAP_EARLY,
 	MEMMAP_HOTPLUG,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 41c0799b9049..5e1f6f4370bc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2209,6 +2209,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
+
 #ifdef CONFIG_CMA
 	/* If allocation can't use CMA areas don't use free CMA pages */
 	if (!(alloc_flags & ALLOC_CMA))
@@ -2238,14 +2239,14 @@ bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
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
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
