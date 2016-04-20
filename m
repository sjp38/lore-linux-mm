Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02A7D6B027F
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 15:47:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t124so105982100pfb.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:47:40 -0700 (PDT)
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com. [209.85.220.47])
        by mx.google.com with ESMTPS id p17si5964266pfj.192.2016.04.20.12.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 12:47:39 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id zm5so20826175pac.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:47:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 01/14] vmscan: consider classzone_idx in compaction_ready
Date: Wed, 20 Apr 2016 15:47:14 -0400
Message-Id: <1461181647-8039-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c839adc13efd..3e6347e2a5fc 100644
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
@@ -2589,7 +2589,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
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
