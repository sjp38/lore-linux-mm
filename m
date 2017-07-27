Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01FA76B04B9
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:07:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 77so3839752wms.0
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:07:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 77si1978865wmo.114.2017.07.27.09.07.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 09:07:13 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 5/6] mm, compaction: stop when number of free pages goes below watermark
Date: Thu, 27 Jul 2017 18:07:00 +0200
Message-Id: <20170727160701.9245-6-vbabka@suse.cz>
In-Reply-To: <20170727160701.9245-1-vbabka@suse.cz>
References: <20170727160701.9245-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

When isolating free pages as miration targets in __isolate_free_page(),
compaction respects the min watermark. Although it checks that there's enough
free pages above the watermark in __compaction_suitable() before starting to
compact, parallel allocation may result in their depletion. Compaction will
detect this only after needlessly scanning many pages for migration,
potentially wasting CPU time.

After this patch, we check if we are still above the watermark in
__compact_finished(). For kcompactd, we check the low watermark instead of min
watermark, because that's the point when kswapd is woken up and it's better to
let kswapd finish freeing memory before doing kcompactd work.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 613c59e928cb..6647359dc8e3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1291,6 +1291,7 @@ static enum compact_result __compact_finished(struct zone *zone,
 {
 	unsigned int order;
 	const int migratetype = cc->migratetype;
+	unsigned long watermark;
 
 	if (cc->contended || fatal_signal_pending(current))
 		return COMPACT_CONTENDED;
@@ -1374,6 +1375,23 @@ static enum compact_result __compact_finished(struct zone *zone,
 		}
 	}
 
+	/*
+	 * It's possible that the number of free pages has dropped below
+	 * watermark during our compaction, and __isolate_free_page() would fail.
+	 * In that case, let's stop now and not waste time searching for migrate
+	 * pages.
+	 * For direct compaction, the check is close to the one in
+	 * __isolate_free_page().  For kcompactd, we use the low watermark,
+	 * because that's the point when kswapd gets woken up, so it's better
+	 * for kcompactd to let kswapd free memory first.
+	 */
+	if (cc->direct_compaction)
+		watermark = min_wmark_pages(zone);
+	else
+		watermark = low_wmark_pages(zone);
+	if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
+		return COMPACT_PARTIAL_SKIPPED;
+
 	return COMPACT_NO_SUITABLE_PAGE;
 }
 
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
