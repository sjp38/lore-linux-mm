Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD1D6B0278
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:15:58 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id u206so93211825wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:15:58 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id h128si17101859wmf.4.2016.04.11.01.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:15:56 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id A66031C170B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:15:56 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 18/22] mm, page_alloc: Shortcut watermark checks for order-0 pages
Date: Mon, 11 Apr 2016 09:13:41 +0100
Message-Id: <1460362424-26369-19-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
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
                                       optfair-v1r12             fastmark-v1r14
Min      alloc-odr0-1               370.00 (  0.00%)           359.00 (  2.97%)
Min      alloc-odr0-2               271.00 (  0.00%)           259.00 (  4.43%)
Min      alloc-odr0-4               227.00 (  0.00%)           219.00 (  3.52%)
Min      alloc-odr0-8               197.00 (  0.00%)           190.00 (  3.55%)
Min      alloc-odr0-16              182.00 (  0.00%)           176.00 (  3.30%)
Min      alloc-odr0-32              175.00 (  0.00%)           169.00 (  3.43%)
Min      alloc-odr0-64              171.00 (  0.00%)           166.00 (  2.92%)
Min      alloc-odr0-128             169.00 (  0.00%)           164.00 (  2.96%)
Min      alloc-odr0-256             179.00 (  0.00%)           174.00 (  2.79%)
Min      alloc-odr0-512             192.00 (  0.00%)           186.00 (  3.12%)
Min      alloc-odr0-1024            201.00 (  0.00%)           192.00 (  4.48%)
Min      alloc-odr0-2048            205.00 (  0.00%)           197.00 (  3.90%)
Min      alloc-odr0-4096            211.00 (  0.00%)           204.00 (  3.32%)
Min      alloc-odr0-8192            214.00 (  0.00%)           206.00 (  3.74%)
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
