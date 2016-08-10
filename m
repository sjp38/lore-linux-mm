Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 022D1828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:13:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u81so51938692wmu.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:13:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i9si38948658wjg.122.2016.08.10.02.12.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:48 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 11/11] mm, vmscan: make compaction_ready() more accurate and readable
Date: Wed, 10 Aug 2016 11:12:26 +0200
Message-Id: <20160810091226.6709-12-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

The compaction_ready() is used during direct reclaim for costly order
allocations to skip reclaim for zones where compaction should be attempted
instead. It's combining the standard compaction_suitable() check with its own
watermark check based on high watermark with extra gap, and the result is
confusing at best.

This patch attempts to better structure and document the checks involved.
First, compaction_suitable() can determine that the allocation should either
succeed already, or that compaction doesn't have enough free pages to proceed.
The third possibility is that compaction has enough free pages, but we still
decide to reclaim first - unless we are already above the high watermark with
gap.  This does not mean that the reclaim will actually reach this watermark
during single attempt, this is rather an over-reclaim protection. So document
the code as such. The check for compaction_deferred() is removed completely, as
it in fact had no proper role here.

The result after this patch is mainly a less confusing code. We also skip some
over-reclaim in cases where the allocation should already succed.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 43 ++++++++++++++++++++-----------------------
 1 file changed, 20 insertions(+), 23 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b676b4b51db0..f9b3112e963a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2617,38 +2617,35 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 }
 
 /*
- * Returns true if compaction should go ahead for a high-order request, or
- * the high-order allocation would succeed without compaction.
+ * Returns true if compaction should go ahead for a costly-order request, or
+ * the allocation would already succeed without compaction. Return false if we
+ * should reclaim first.
  */
 static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
 {
 	unsigned long watermark;
-	bool watermark_ok;
+	enum compact_result suitable;
 
-	/*
-	 * Compaction takes time to run and there are potentially other
-	 * callers using the pages just freed. Continue reclaiming until
-	 * there is a buffer of free pages available to give compaction
-	 * a reasonable chance of completing and allocating the page
-	 */
-	watermark = high_wmark_pages(zone) + compact_gap(sc->order);
-	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, sc->reclaim_idx);
-
-	/*
-	 * If compaction is deferred, reclaim up to a point where
-	 * compaction will have a chance of success when re-enabled
-	 */
-	if (compaction_deferred(zone, sc->order))
-		return watermark_ok;
+	suitable = compaction_suitable(zone, sc->order, 0, sc->reclaim_idx);
+	if (suitable == COMPACT_SUCCESS)
+		/* Allocation should succeed already. Don't reclaim. */
+		return true;
+	if (suitable == COMPACT_SKIPPED)
+		/* Compaction cannot yet proceed. Do reclaim. */
+		return false;
 
 	/*
-	 * If compaction is not ready to start and allocation is not likely
-	 * to succeed without it, then keep reclaiming.
+	 * Compaction is already possible, but it takes time to run and there
+	 * are potentially other callers using the pages just freed. So proceed
+	 * with reclaim to make a buffer of free pages available to give
+	 * compaction a reasonable chance of completing and allocating the page.
+	 * Note that we won't actually reclaim the whole buffer in one attempt
+	 * as the target watermark in should_continue_reclaim() is lower. But if
+	 * we are already above the high+gap watermark, don't reclaim at all.
 	 */
-	if (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx) == COMPACT_SKIPPED)
-		return false;
+	watermark = high_wmark_pages(zone) + compact_gap(sc->order);
 
-	return watermark_ok;
+	return zone_watermark_ok_safe(zone, 0, watermark, sc->reclaim_idx);
 }
 
 /*
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
