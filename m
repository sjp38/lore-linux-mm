Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64FA728024E
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 01:45:44 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 189so11640241ity.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 22:45:44 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y99si1970573ita.100.2016.10.06.22.45.39
        for <linux-mm@kvack.org>;
        Thu, 06 Oct 2016 22:45:40 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 4/4] mm: skip to reserve pageblock crossed zone boundary for HIGHATOMIC
Date: Fri,  7 Oct 2016 14:45:36 +0900
Message-Id: <1475819136-24358-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1475819136-24358-1-git-send-email-minchan@kernel.org>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Minchan Kim <minchan@kernel.org>

In CONFIG_SPARSEMEM, VM shares a pageblock_flags of a mem_section
between two zones if the pageblock cross zone boundaries. It means
a zone lock cannot protect pageblock migratype change's race.

It might be not a problem because migratetype inherently was racy
but intrdocuing with CMA, it was not true any more and have been fixed.
(I hope it should be solved more general approach however...)
And then, it's time for MIGRATE_HIGHATOMIC.

More importantly, HIGHATOMIC migratetype is not big(i.e., 1%) reserve
in system so let's skip such crippled pageblock to try to reserve
full 1% free memory.

Debugged-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eeb047bb0e9d..d76bb50baf61 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2098,6 +2098,24 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 	mt = get_pageblock_migratetype(page);
 	if (mt != MIGRATE_HIGHATOMIC &&
 			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
+		/*
+		 * If the pageblock cross zone boundaries, we need both
+		 * zone locks but doesn't want to make complex because
+		 * highatomic pageblock is small so that we want to reserve
+		 * sane(?) pageblock.
+		 */
+		unsigned long start_pfn, end_pfn;
+
+		start_pfn = page_to_pfn(page);
+		start_pfn = start_pfn & ~(pageblock_nr_pages - 1);
+
+		if (!zone_spans_pfn(zone, start_pfn))
+			goto out_unlock;
+
+		end_pfn = start_pfn + pageblock_nr_pages - 1;
+		if (!zone_spans_pfn(zone, end_pfn))
+			goto out_unlock;
+
 		zone->nr_reserved_highatomic += pageblock_nr_pages;
 		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
 		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
