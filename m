Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B51A66B0275
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:14:08 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id u206so21292258wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:14:08 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id xb9si33555489wjc.63.2016.04.12.03.14.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:14:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 5E98A98E10
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:14:06 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 18/24] mm, page_alloc: Shortcut watermark checks for order-0 pages
Date: Tue, 12 Apr 2016 11:12:19 +0100
Message-Id: <1460455945-29644-19-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Watermarks have to be checked on every allocation including the number of
pages being allocated and whether reserves can be accessed. The reserves
only matter if memory is limited and the free_pages adjustment only applies
to high-order pages. This patch adds a shortcut for order-0 pages that avoids
numerous calculations if there is plenty of free memory yielding the following
performance difference in a page allocator microbenchmark;

                                           4.6.0-rc2                  4.6.0-rc2
                                       optfair-v1r20             fastmark-v1r20
Min      alloc-odr0-1               380.00 (  0.00%)           364.00 (  4.21%)
Min      alloc-odr0-2               273.00 (  0.00%)           262.00 (  4.03%)
Min      alloc-odr0-4               227.00 (  0.00%)           214.00 (  5.73%)
Min      alloc-odr0-8               196.00 (  0.00%)           186.00 (  5.10%)
Min      alloc-odr0-16              183.00 (  0.00%)           173.00 (  5.46%)
Min      alloc-odr0-32              173.00 (  0.00%)           165.00 (  4.62%)
Min      alloc-odr0-64              169.00 (  0.00%)           161.00 (  4.73%)
Min      alloc-odr0-128             169.00 (  0.00%)           159.00 (  5.92%)
Min      alloc-odr0-256             180.00 (  0.00%)           168.00 (  6.67%)
Min      alloc-odr0-512             190.00 (  0.00%)           180.00 (  5.26%)
Min      alloc-odr0-1024            198.00 (  0.00%)           190.00 (  4.04%)
Min      alloc-odr0-2048            204.00 (  0.00%)           196.00 (  3.92%)
Min      alloc-odr0-4096            209.00 (  0.00%)           202.00 (  3.35%)
Min      alloc-odr0-8192            213.00 (  0.00%)           206.00 (  3.29%)
Min      alloc-odr0-16384           214.00 (  0.00%)           206.00 (  3.74%)

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 25a8ab07b287..c131218913e8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2618,6 +2618,32 @@ bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 					zone_page_state(z, NR_FREE_PAGES));
 }
 
+static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
+		unsigned long mark, int classzone_idx, unsigned int alloc_flags)
+{
+	long free_pages = zone_page_state(z, NR_FREE_PAGES);
+	long cma_pages = 0;
+
+#ifdef CONFIG_CMA
+	/* If allocation can't use CMA areas don't use free CMA pages */
+	if (!(alloc_flags & ALLOC_CMA))
+		cma_pages = zone_page_state(z, NR_FREE_CMA_PAGES);
+#endif
+
+	/*
+	 * Fast check for order-0 only. If this fails then the reserves
+	 * need to be calculated. There is a corner case where the check
+	 * passes but only the high-order atomic reserve are free. If
+	 * the caller is !atomic then it'll uselessly search the free
+	 * list. That corner case is then slower but it is harmless.
+	 */
+	if (!order && (free_pages - cma_pages) > mark + z->lowmem_reserve[classzone_idx])
+		return true;
+
+	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
+					free_pages);
+}
+
 bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
 			unsigned long mark, int classzone_idx)
 {
@@ -2739,7 +2765,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			continue;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
-		if (!zone_watermark_ok(zone, order, mark,
+		if (!zone_watermark_fast(zone, order, mark,
 				       ac->classzone_idx, alloc_flags)) {
 			int ret;
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
