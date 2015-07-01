Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 448C06B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 21:18:07 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so15518237pdb.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 18:18:07 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id p5si390702par.165.2015.06.30.18.18.05
        for <linux-mm@kvack.org>;
        Tue, 30 Jun 2015 18:18:06 -0700 (PDT)
From: minkyung88.kim@lge.com
Subject: [PATCH] fix: decrease NR_FREE_PAGES when isolate page from buddy
Date: Wed,  1 Jul 2015 10:17:58 +0900
Message-Id: <1435713478-19646-1-git-send-email-minkyung88.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Seungho Park <seungho1.park@lge.com>, kmk3210@gmail.com, "minkyung88.kim" <minkyung88.kim@lge.com>

From: "minkyung88.kim" <minkyung88.kim@lge.com>

NR_FREEPAGE should be decreased when pages are isolated from buddy.
Therefore fix the count.

Signed-off-by: minkyung88.kim <minkyung88.kim@lge.com>
---
 mm/page_isolation.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 303c908..16cc172 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -233,10 +233,14 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			 */
 			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
 				struct page *end_page;
+				struct zone *zone = page_zone(page);
+				int mt = get_freepage_migratetype(page);
+				unsigned long nr_pages;
 
 				end_page = page + (1 << page_order(page)) - 1;
-				move_freepages(page_zone(page), page, end_page,
+				nr_pages = move_freepages(zone, page, end_page,
 						MIGRATE_ISOLATE);
+				__mod_zone_freepage_state(zone, -nr_pages, mt);
 			}
 			pfn += 1 << page_order(page);
 		}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
