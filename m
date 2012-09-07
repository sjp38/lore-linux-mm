Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DCB106B0070
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 20:38:07 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 4/4] memory-hotplug: fix pages missed by race rather than failng
Date: Fri,  7 Sep 2012 09:39:32 +0900
Message-Id: <1346978372-17903-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1346978372-17903-1-git-send-email-minchan@kernel.org>
References: <1346978372-17903-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>

If race between allocation and isolation in memory-hotplug offline
happens, some pages could be in MIGRATE_MOVABLE of free_list although
the pageblock's migratetype of the page is MIGRATE_ISOLATE.

The race could be detected by get_freepage_migratetype
in __test_page_isolated_in_pageblock. If it is detected, now EBUSY
gets bubbled all the way up and the hotplug operations fails.

But better idea is instead of returning and failing memory-hotremove,
move the free page to the correct list at the time it is detected.
It could enhance memory-hotremove operation success ratio although
the race is really rare.

Suggested-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/page-isolation.h |    4 ++++
 mm/page_alloc.c                |    2 +-
 mm/page_isolation.c            |   15 +++++++++++++--
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 105077a..fca8c0a 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -6,6 +6,10 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count);
 void set_pageblock_migratetype(struct page *page, int migratetype);
 int move_freepages_block(struct zone *zone, struct page *page,
 				int migratetype);
+int move_freepages(struct zone *zone,
+			  struct page *start_page, struct page *end_page,
+			  int migratetype);
+
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
  * If specified range includes migrate types other than MOVABLE or CMA,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8531fa3..5a4c4d8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -918,7 +918,7 @@ static int fallbacks[MIGRATE_TYPES][4] = {
  * Note that start_page and end_pages are not aligned on a pageblock
  * boundary. If alignment is required, use move_freepages_block()
  */
-static int move_freepages(struct zone *zone,
+int move_freepages(struct zone *zone,
 			  struct page *start_page, struct page *end_page,
 			  int migratetype)
 {
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 7ba7405..a42fa8d 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -194,8 +194,19 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
 		}
 		page = pfn_to_page(pfn);
 		if (PageBuddy(page)) {
-			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE)
-				break;
+			/*
+			 * If race between isolatation and allocation happens,
+			 * some free pages could be in MIGRATE_MOVABLE list
+			 * although pageblock's migratation type of the page
+			 * is MIGRATE_ISOLATE. Catch it and move the page into
+			 * MIGRATE_ISOLATE list.
+			 */
+			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
+				struct page *end_page = page +
+						(1 << page_order(page)) - 1;
+				move_freepages(page_zone(page), page, end_page,
+						MIGRATE_ISOLATE);
+			}
 			pfn += 1 << page_order(page);
 		}
 		else if (page_count(page) == 0 &&
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
