Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDD16B025F
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:57:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so147687766pfa.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:57:48 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id b10si15745822pan.98.2016.06.17.00.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:57:47 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i123so2732103pfg.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:57:47 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 1/9] mm/compaction: split freepages without holding the zone lock
Date: Fri, 17 Jun 2016 16:57:31 +0900
Message-Id: <1466150259-27727-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We don't need to split freepages with holding the zone lock.  It will
cause more contention on zone lock so not desirable.

v3: fix un-isolated case

Link: http://lkml.kernel.org/r/1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Alexander Potapenko <glider@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 include/linux/mm.h |  1 -
 mm/compaction.c    | 47 +++++++++++++++++++++++++++++++++--------------
 mm/page_alloc.c    | 27 ---------------------------
 3 files changed, 33 insertions(+), 42 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 558949e..15b3bc9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -562,7 +562,6 @@ void __put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
-int split_free_page(struct page *page);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff --git a/mm/compaction.c b/mm/compaction.c
index d1d2063..5557421 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -64,13 +64,31 @@ static unsigned long release_freepages(struct list_head *freelist)
 
 static void map_pages(struct list_head *list)
 {
-	struct page *page;
+	unsigned int i, order, nr_pages;
+	struct page *page, *next;
+	LIST_HEAD(tmp_list);
+
+	list_for_each_entry_safe(page, next, list, lru) {
+		list_del(&page->lru);
 
-	list_for_each_entry(page, list, lru) {
-		arch_alloc_page(page, 0);
-		kernel_map_pages(page, 1, 1);
-		kasan_alloc_pages(page, 0);
+		order = page_private(page);
+		nr_pages = 1 << order;
+		set_page_private(page, 0);
+		set_page_refcounted(page);
+
+		arch_alloc_page(page, order);
+		kernel_map_pages(page, nr_pages, 1);
+		kasan_alloc_pages(page, order);
+		if (order)
+			split_page(page, order);
+
+		for (i = 0; i < nr_pages; i++) {
+			list_add(&page->lru, &tmp_list);
+			page++;
+		}
 	}
+
+	list_splice(&tmp_list, list);
 }
 
 static inline bool migrate_async_suitable(int migratetype)
@@ -405,12 +423,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	unsigned long flags = 0;
 	bool locked = false;
 	unsigned long blockpfn = *start_pfn;
+	unsigned int order;
 
 	cursor = pfn_to_page(blockpfn);
 
 	/* Isolate free pages. */
 	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
-		int isolated, i;
+		int isolated;
 		struct page *page = cursor;
 
 		/*
@@ -476,16 +495,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 				goto isolate_fail;
 		}
 
-		/* Found a free page, break it into order-0 pages */
-		isolated = split_free_page(page);
-		total_isolated += isolated;
-		for (i = 0; i < isolated; i++) {
-			list_add(&page->lru, freelist);
-			page++;
-		}
+		/* Found a free page, will break it into order-0 pages */
+		order = page_order(page);
+		isolated = __isolate_free_page(page, order);
 
-		/* If a page was split, advance to the end of it */
+		/* If a page was isolated, advance to the end of it */
 		if (isolated) {
+			set_page_private(page, order);
+			total_isolated += isolated;
+			list_add_tail(&page->lru, freelist);
+
 			cc->nr_freepages += isolated;
 			if (!strict &&
 				cc->nr_migratepages <= cc->nr_freepages) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e08186a..e07f424 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2532,33 +2532,6 @@ int __isolate_free_page(struct page *page, unsigned int order)
 }
 
 /*
- * Similar to split_page except the page is already free. As this is only
- * being used for migration, the migratetype of the block also changes.
- * As this is called with interrupts disabled, the caller is responsible
- * for calling arch_alloc_page() and kernel_map_page() after interrupts
- * are enabled.
- *
- * Note: this is probably too low level an operation for use in drivers.
- * Please consult with lkml before using this in your driver.
- */
-int split_free_page(struct page *page)
-{
-	unsigned int order;
-	int nr_pages;
-
-	order = page_order(page);
-
-	nr_pages = __isolate_free_page(page, order);
-	if (!nr_pages)
-		return 0;
-
-	/* Split into individual pages */
-	set_page_refcounted(page);
-	split_page(page, order);
-	return nr_pages;
-}
-
-/*
  * Update NUMA hit/miss statistics
  *
  * Must be called with interrupts disabled.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
