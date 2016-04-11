Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 959CA6B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 02:46:04 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id v188so73031497wme.1
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 23:46:04 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id bh5si27162015wjb.83.2016.04.10.23.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Apr 2016 23:46:03 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a140so18909529wma.2
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 23:46:03 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] vmscan: consider classzone_idx in compaction_ready
Date: Mon, 11 Apr 2016 08:45:50 +0200
Message-Id: <1460357151-25554-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460357151-25554-1-git-send-email-mhocko@kernel.org>
References: <1460357151-25554-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

while playing with the oom detection rework [1] I have noticed
that my heavy order-9 (hugetlb) load close to OOM ended up in an
endless loop where the reclaim hasn't made any progress but
did_some_progress didn't reflect that and compaction_suitable
was backing off because no zone is above low wmark + 1 << order.

It turned out that this is in fact an old standing bug in compaction_ready
which ignores the requested_highidx and did the watermark check for
0 classzone_idx. This succeeds for zone DMA most of the time as the zone
is mostly unused because of lowmem protection. This also means that the
OOM killer wouldn't be triggered for higher order requests even when
there is no reclaim progress and we essentially rely on order-0 request
to find this out. This has been broken in one way or another since
fe4b1b244bdb ("mm: vmscan: when reclaiming for compaction, ensure there
are sufficient free pages available") but only since 7335084d446b ("mm:
vmscan: do not OOM if aborting reclaim to start compaction") we are not
invoking the OOM killer based on the wrong calculation.

Propagate requested_highidx down to compaction_ready and use it for both
the watermak check and compaction_suitable to fix this issue.

[1] http://lkml.kernel.org/r/1459855533-4600-1-git-send-email-mhocko@kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a3b2342dbae..a2ba60aa7b88 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2482,7 +2482,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
  * Returns true if compaction should go ahead for a high-order request, or
  * the high-order allocation would succeed without compaction.
  */
-static inline bool compaction_ready(struct zone *zone, int order)
+static inline bool compaction_ready(struct zone *zone, int order, int classzone_idx)
 {
 	unsigned long balance_gap, watermark;
 	bool watermark_ok;
@@ -2496,7 +2496,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
 			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
 	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
-	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0);
+	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, classzone_idx);
 
 	/*
 	 * If compaction is deferred, reclaim up to a point where
@@ -2509,7 +2509,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	 * If compaction is not ready to start and allocation is not likely
 	 * to succeed without it, then keep reclaiming.
 	 */
-	if (compaction_suitable(zone, order, 0, 0) == COMPACT_SKIPPED)
+	if (compaction_suitable(zone, order, 0, classzone_idx) == COMPACT_SKIPPED)
 		return false;
 
 	return watermark_ok;
@@ -2586,7 +2586,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			if (IS_ENABLED(CONFIG_COMPACTION) &&
 			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
 			    zonelist_zone_idx(z) <= requested_highidx &&
-			    compaction_ready(zone, sc->order)) {
+			    compaction_ready(zone, sc->order, requested_highidx)) {
 				sc->compaction_ready = true;
 				continue;
 			}
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
