Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 759BC6B0253
	for <linux-mm@kvack.org>; Tue,  3 May 2016 01:23:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so18754863pfz.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:09 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id c68si2317376pfd.116.2016.05.02.22.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 22:23:08 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id c189so5318668pfb.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:08 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 1/6] mm/compaction: split freepages without holding the zone lock
Date: Tue,  3 May 2016 14:22:59 +0900
Message-Id: <1462252984-8524-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We don't need to split freepages with holding the zone lock. It will cause
more contention on zone lock so not desirable.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mm.h |  1 -
 mm/compaction.c    | 42 ++++++++++++++++++++++++++++++------------
 mm/page_alloc.c    | 27 ---------------------------
 3 files changed, 30 insertions(+), 40 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7b52750..9608f33 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -523,7 +523,6 @@ void __put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
-int split_free_page(struct page *page);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff --git a/mm/compaction.c b/mm/compaction.c
index c9a95c1..ecf0252 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -65,13 +65,31 @@ static unsigned long release_freepages(struct list_head *freelist)
 
 static void map_pages(struct list_head *list)
 {
-	struct page *page;
+	unsigned int i, order, nr_pages;
+	struct page *page, *next;
+	LIST_HEAD(tmp_list);
+
+	list_for_each_entry_safe(page, next, list, lru) {
+		list_del(&page->lru);
+
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
 
-	list_for_each_entry(page, list, lru) {
-		arch_alloc_page(page, 0);
-		kernel_map_pages(page, 1, 1);
-		kasan_alloc_pages(page, 0);
+		for (i = 0; i < nr_pages; i++) {
+			list_add(&page->lru, &tmp_list);
+			page++;
+		}
 	}
+
+	list_splice(&tmp_list, list);
 }
 
 static inline bool migrate_async_suitable(int migratetype)
@@ -368,12 +386,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
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
@@ -439,13 +458,12 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 				goto isolate_fail;
 		}
 
-		/* Found a free page, break it into order-0 pages */
-		isolated = split_free_page(page);
+		/* Found a free page, will break it into order-0 pages */
+		order = page_order(page);
+		isolated = __isolate_free_page(page, page_order(page));
+		set_page_private(page, order);
 		total_isolated += isolated;
-		for (i = 0; i < isolated; i++) {
-			list_add(&page->lru, freelist);
-			page++;
-		}
+		list_add_tail(&page->lru, freelist);
 
 		/* If a page was split, advance to the end of it */
 		if (isolated) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dd65d9..60d7f10 100644
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
