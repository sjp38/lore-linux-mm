Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9053A6B0265
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 01:45:40 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k64so11488533itb.5
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 22:45:40 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id a124si1984255itd.84.2016.10.06.22.45.39
        for <linux-mm@kvack.org>;
        Thu, 06 Oct 2016 22:45:40 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/4] mm: adjust reserved highatomic count
Date: Fri,  7 Oct 2016 14:45:33 +0900
Message-Id: <1475819136-24358-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1475819136-24358-1-git-send-email-minchan@kernel.org>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Minchan Kim <minchan@kernel.org>

In page freeing path, migratetype is racy so that a highorderatomic
page could free into non-highorderatomic free list. If that page
is allocated, VM can change the pageblock from higorderatomic to
something. In that case, we should adjust nr_reserved_highatomic.
Otherwise, VM cannot reserve highorderatomic pageblocks any more
although it doesn't reach 1% limit. It means highorder atomic
allocation failure would be higher.

So, this patch decreases the account as well as migratetype
if it was MIGRATE_HIGHATOMIC.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c | 44 ++++++++++++++++++++++++++++++++++++++------
 1 file changed, 38 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 55ad0229ebf3..e7cbb3cc22fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -282,6 +282,9 @@ EXPORT_SYMBOL(nr_node_ids);
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
+static void dec_highatomic_pageblock(struct zone *zone, struct page *page,
+					int migratetype);
+
 int page_group_by_mobility_disabled __read_mostly;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
@@ -1935,7 +1938,14 @@ static void change_pageblock_range(struct page *pageblock_page,
 	int nr_pageblocks = 1 << (start_order - pageblock_order);
 
 	while (nr_pageblocks--) {
-		set_pageblock_migratetype(pageblock_page, migratetype);
+		if (get_pageblock_migratetype(pageblock_page) !=
+			MIGRATE_HIGHATOMIC)
+			set_pageblock_migratetype(pageblock_page,
+							migratetype);
+		else
+			dec_highatomic_pageblock(page_zone(pageblock_page),
+							pageblock_page,
+							migratetype);
 		pageblock_page += pageblock_nr_pages;
 	}
 }
@@ -1996,8 +2006,14 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 	/* Claim the whole block if over half of it is free */
 	if (pages >= (1 << (pageblock_order-1)) ||
-			page_group_by_mobility_disabled)
-		set_pageblock_migratetype(page, start_type);
+			page_group_by_mobility_disabled) {
+		int mt = get_pageblock_migratetype(page);
+
+		if (mt != MIGRATE_HIGHATOMIC)
+			set_pageblock_migratetype(page, start_type);
+		else
+			dec_highatomic_pageblock(zone, page, start_type);
+	}
 }
 
 /*
@@ -2037,6 +2053,17 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 	return -1;
 }
 
+static void dec_highatomic_pageblock(struct zone *zone, struct page *page,
+					int migratetype)
+{
+	if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
+		return;
+
+	zone->nr_reserved_highatomic -= min(pageblock_nr_pages,
+					zone->nr_reserved_highatomic);
+	set_pageblock_migratetype(page, migratetype);
+}
+
 /*
  * Reserve a pageblock for exclusive use of high-order atomic allocations if
  * there are no empty page blocks that contain a page with a suitable order
@@ -2555,9 +2582,14 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
-			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
-				set_pageblock_migratetype(page,
-							  MIGRATE_MOVABLE);
+			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
+				if (mt != MIGRATE_HIGHATOMIC)
+					set_pageblock_migratetype(page,
+							MIGRATE_MOVABLE);
+				else
+					dec_highatomic_pageblock(zone, page,
+							MIGRATE_MOVABLE);
+			}
 		}
 	}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
