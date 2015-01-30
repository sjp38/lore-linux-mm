Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 319456B0070
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:34:42 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so52029018pab.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:34:41 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id qp2si13616495pdb.123.2015.01.30.04.34.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 04:34:41 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so52021775pad.7
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:34:41 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 3/4] mm/page_alloc: separate steal decision from steal behaviour part
Date: Fri, 30 Jan 2015 21:34:11 +0900
Message-Id: <1422621252-29859-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo <iamjoonsoo.kim@lge.com>

This is preparation step to use page allocator's anti fragmentation logic
in compaction. This patch just separates steal decision part from actual
steal behaviour part so there is no functional change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 49 ++++++++++++++++++++++++++++++++-----------------
 1 file changed, 32 insertions(+), 17 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8d52ab1..ef74750 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1122,6 +1122,24 @@ static void change_pageblock_range(struct page *pageblock_page,
 	}
 }
 
+static bool can_steal_freepages(unsigned int order,
+				int start_mt, int fallback_mt)
+{
+	if (is_migrate_cma(fallback_mt))
+		return false;
+
+	if (order >= pageblock_order)
+		return true;
+
+	if (order >= pageblock_order / 2 ||
+		start_mt == MIGRATE_RECLAIMABLE ||
+		start_mt == MIGRATE_UNMOVABLE ||
+		page_group_by_mobility_disabled)
+		return true;
+
+	return false;
+}
+
 /*
  * When we are falling back to another migratetype during allocation, try to
  * steal extra free pages from the same pageblocks to satisfy further
@@ -1138,9 +1156,10 @@ static void change_pageblock_range(struct page *pageblock_page,
  * as well.
  */
 static void try_to_steal_freepages(struct zone *zone, struct page *page,
-				  int start_type, int fallback_type)
+				  int start_type)
 {
 	int current_order = page_order(page);
+	int pages;
 
 	/* Take ownership for orders >= pageblock_order */
 	if (current_order >= pageblock_order) {
@@ -1148,19 +1167,12 @@ static void try_to_steal_freepages(struct zone *zone, struct page *page,
 		return;
 	}
 
-	if (current_order >= pageblock_order / 2 ||
-	    start_type == MIGRATE_RECLAIMABLE ||
-	    start_type == MIGRATE_UNMOVABLE ||
-	    page_group_by_mobility_disabled) {
-		int pages;
+	pages = move_freepages_block(zone, page, start_type);
 
-		pages = move_freepages_block(zone, page, start_type);
-
-		/* Claim the whole block if over half of it is free */
-		if (pages >= (1 << (pageblock_order-1)) ||
-				page_group_by_mobility_disabled)
-			set_pageblock_migratetype(page, start_type);
-	}
+	/* Claim the whole block if over half of it is free */
+	if (pages >= (1 << (pageblock_order-1)) ||
+			page_group_by_mobility_disabled)
+		set_pageblock_migratetype(page, start_type);
 }
 
 /* Remove an element from the buddy allocator from the fallback list */
@@ -1170,6 +1182,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	struct free_area *area;
 	unsigned int current_order;
 	struct page *page;
+	bool can_steal;
 
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1;
@@ -1192,10 +1205,11 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 					struct page, lru);
 			area->nr_free--;
 
-			if (!is_migrate_cma(migratetype)) {
+			can_steal = can_steal_freepages(current_order,
+					start_migratetype, migratetype);
+			if (can_steal) {
 				try_to_steal_freepages(zone, page,
-							start_migratetype,
-							migratetype);
+							start_migratetype);
 			} else {
 				/*
 				 * When borrowing from MIGRATE_CMA, we need to
@@ -1203,7 +1217,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 				 * itself, and we do not try to steal extra
 				 * free pages.
 				 */
-				buddy_type = migratetype;
+				if (is_migrate_cma(migratetype))
+					buddy_type = migratetype;
 			}
 
 			/* Remove the page from the freelists */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
