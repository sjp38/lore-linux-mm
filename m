Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 3A5E66B0071
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:37:02 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 23/34] mm: vmscan: When reclaiming for compaction, ensure there are sufficient free pages available
Date: Thu, 19 Jul 2012 15:36:33 +0100
Message-Id: <1342708604-26540-24-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit fe4b1b244bdb96136855f2c694071cb09d140766 upstream.

Stable note: Not tracked on Bugzilla. THP and compaction was found to
	aggressively reclaim pages and stall systems under different
	situations that was addressed piecemeal over time. This patch
	addresses a problem where the fix regressed THP allocation
	success rates.

In commit [e0887c19: vmscan: limit direct reclaim for higher order
allocations], Rik noted that reclaim was too aggressive when THP was
enabled. In his initial patch he used the number of free pages to
decide if reclaim should abort for compaction. My feedback was that
reclaim and compaction should be using the same logic when deciding if
reclaim should be aborted.

Unfortunately, this had the effect of reducing THP success rates when
the workload included something like streaming reads that continually
allocated pages. The window during which compaction could run and return
a THP was too small.

This patch combines Rik's two patches together. compaction_suitable()
is still used to decide if reclaim should be aborted to allow
compaction is used. However, it will also ensure that there is a
reasonable buffer of free pages available. This improves upon the
THP allocation success rates but bounds the number of pages that are
freed for compaction.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel<riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andy Isaacson <adi@hexapodia.org>
Cc: Nai Xia <nai.xia@gmail.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   44 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 39 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8c1fc0..e85abfd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2075,6 +2075,42 @@ restart:
 	throttle_vm_writeout(sc->gfp_mask);
 }
 
+/* Returns true if compaction should go ahead for a high-order request */
+static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
+{
+	unsigned long balance_gap, watermark;
+	bool watermark_ok;
+
+	/* Do not consider compaction for orders reclaim is meant to satisfy */
+	if (sc->order <= PAGE_ALLOC_COSTLY_ORDER)
+		return false;
+
+	/*
+	 * Compaction takes time to run and there are potentially other
+	 * callers using the pages just freed. Continue reclaiming until
+	 * there is a buffer of free pages available to give compaction
+	 * a reasonable chance of completing and allocating the page
+	 */
+	balance_gap = min(low_wmark_pages(zone),
+		(zone->present_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+			KSWAPD_ZONE_BALANCE_GAP_RATIO);
+	watermark = high_wmark_pages(zone) + balance_gap + (2UL << sc->order);
+	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
+
+	/*
+	 * If compaction is deferred, reclaim up to a point where
+	 * compaction will have a chance of success when re-enabled
+	 */
+	if (compaction_deferred(zone))
+		return watermark_ok;
+
+	/* If compaction is not ready to start, keep reclaiming */
+	if (!compaction_suitable(zone, sc->order))
+		return false;
+
+	return watermark_ok;
+}
+
 /*
  * This is the direct reclaim path, for page-allocating processes.  We only
  * try to reclaim pages from zones which will satisfy the caller's allocation
@@ -2092,8 +2128,8 @@ restart:
  * scan then give up on it.
  *
  * This function returns true if a zone is being reclaimed for a costly
- * high-order allocation and compaction is either ready to begin or deferred.
- * This indicates to the caller that it should retry the allocation or fail.
+ * allocation and compaction is ready to begin. This indicates to the caller
+ * that it should retry the allocation or fail.
  */
 static bool shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
@@ -2127,9 +2163,7 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 				 * noticable problem, like transparent huge page
 				 * allocations.
 				 */
-				if (sc->order > PAGE_ALLOC_COSTLY_ORDER &&
-					(compaction_suitable(zone, sc->order) ||
-					 compaction_deferred(zone))) {
+				if (compaction_ready(zone, sc)) {
 					should_abort_reclaim = true;
 					continue;
 				}
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
