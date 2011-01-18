Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 54C318D003A
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:07:02 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: compaction: prevent division-by-zero during user-requested compaction
Date: Tue, 18 Jan 2011 18:06:52 +0100
Message-Id: <1295370412-2645-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Up until '3e7d344 mm: vmscan: reclaim order-0 and use compaction
instead of lumpy reclaim', compaction skipped calculating the
fragmentation index of a zone when compaction was explicitely
requested through the procfs knob.

However, when compaction_suitable was introduced, it did not come with
an extra check for order == -1, set on explicit compaction requests,
and passed this order on to the fragmentation index calculation, where
it overshifts the number of requested pages, leading to a division by
zero.

This patch makes sure that order == -1 is recognized as the flag it is
rather than passing it along as valid order parameter.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/compaction.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6d592a0..114c145 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -453,6 +453,9 @@ unsigned long compaction_suitable(struct zone *zone, int order)
 	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 		return COMPACT_SKIPPED;
 
+	if (order == -1)
+		return COMPACT_CONTINUE;
+
 	/*
 	 * fragmentation index determines if allocation failures are due to
 	 * low memory or external fragmentation
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
