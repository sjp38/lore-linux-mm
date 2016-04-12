Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 50498828E8
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:14:38 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id a140so47168334wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:14:38 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id y185si23095867wmg.9.2016.04.12.03.14.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:14:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id D8E2198FBA
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:14:36 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 24/24] mm, page_alloc: Do not lookup pcp migratetype during bulk free
Date: Tue, 12 Apr 2016 11:12:25 +0100
Message-Id: <1460455945-29644-25-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

During bulk free, the pcp type of the page is known as it was removed
from a specific list. It only needs to be rechecked if an isolated
pageblock exists. This patch removes an unnecessary variable in
the process. The impact is that the round-robin freeing of PCP
lists is distorted when an isolated pageblock is encountered but
that is a rare and harmless corner-case.

The impact on the page allocator microbench of the bulk free patches is
visible for higher batch counts when the bulk free paths are hit.

pagealloc
                                           4.6.0-rc3                  4.6.0-rc3
                                         cpuset-v2r2                 micro-v2r2
Min      free-odr0-1                191.00 (  0.00%)           195.00 ( -2.09%)
Min      free-odr0-2                136.00 (  0.00%)           136.00 (  0.00%)
Min      free-odr0-4                107.00 (  0.00%)           107.00 (  0.00%)
Min      free-odr0-8                 95.00 (  0.00%)            95.00 (  0.00%)
Min      free-odr0-16                87.00 (  0.00%)            87.00 (  0.00%)
Min      free-odr0-32                82.00 (  0.00%)            82.00 (  0.00%)
Min      free-odr0-64                80.00 (  0.00%)            80.00 (  0.00%)
Min      free-odr0-128               79.00 (  0.00%)            79.00 (  0.00%)
Min      free-odr0-256               94.00 (  0.00%)            97.00 ( -3.19%)
Min      free-odr0-512              112.00 (  0.00%)           109.00 (  2.68%)
Min      free-odr0-1024             118.00 (  0.00%)           118.00 (  0.00%)
Min      free-odr0-2048             123.00 (  0.00%)           121.00 (  1.63%)
Min      free-odr0-4096             127.00 (  0.00%)           125.00 (  1.57%)
Min      free-odr0-8192             129.00 (  0.00%)           127.00 (  1.55%)
Min      free-odr0-16384            128.00 (  0.00%)           127.00 (  0.78%)

It's tiny but the patches are trivial.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b1553c1156c..4d4079309760 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -876,7 +876,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		 */
 		do {
 			batch_free++;
-			if (++migratetype == MIGRATE_PCPTYPES)
+			if (++migratetype >= MIGRATE_PCPTYPES)
 				migratetype = 0;
 			list = &pcp->lists[migratetype];
 		} while (list_empty(list));
@@ -886,21 +886,16 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free = count;
 
 		do {
-			int mt;	/* migratetype of the to-be-freed page */
-
 			page = list_last_entry(list, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
 
-			mt = get_pcppage_migratetype(page);
-			/* MIGRATE_ISOLATE page should not go to pcplists */
-			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
 			/* Pageblock could have been isolated meanwhile */
 			if (unlikely(isolated_pageblocks))
-				mt = get_pageblock_migratetype(page);
+				migratetype = get_pageblock_migratetype(page);
 
-			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
-			trace_mm_page_pcpu_drain(page, 0, mt);
+			__free_one_page(page, page_to_pfn(page), zone, 0, migratetype);
+			trace_mm_page_pcpu_drain(page, 0, migratetype);
 		} while (--count && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
