Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id BD0196B0152
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:25 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 21/22] mm: compaction: Release free page list under a batched magazine lock
Date: Wed,  8 May 2013 17:03:06 +0100
Message-Id: <1368028987-8369-22-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Compaction can reuse the vast bulk of free_base_page() to batch
hold the magazine lock.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h |  1 +
 mm/compaction.c     | 18 ++----------------
 mm/page_alloc.c     | 21 +++++++++++++++++++--
 3 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 45cbc43..53844b4 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -366,6 +366,7 @@ extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_base_page(struct page *page);
 extern void free_base_page_list(struct list_head *list);
+extern unsigned long release_free_page_list(struct list_head *list);
 
 extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
 extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
diff --git a/mm/compaction.c b/mm/compaction.c
index 05ccb4c..e415d92 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -38,20 +38,6 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
 
-static unsigned long release_freepages(struct list_head *freelist)
-{
-	struct page *page, *next;
-	unsigned long count = 0;
-
-	list_for_each_entry_safe(page, next, freelist, lru) {
-		list_del(&page->lru);
-		__free_page(page);
-		count++;
-	}
-
-	return count;
-}
-
 static void map_pages(struct list_head *list)
 {
 	struct page *page;
@@ -382,7 +368,7 @@ isolate_freepages_range(struct compact_control *cc,
 
 	if (pfn < end_pfn) {
 		/* Loop terminated early, cleanup. */
-		release_freepages(&freelist);
+		release_free_page_list(&freelist);
 		return 0;
 	}
 
@@ -1002,7 +988,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 out:
 	/* Release free pages and check accounting */
-	cc->nr_freepages -= release_freepages(&cc->freepages);
+	cc->nr_freepages -= release_free_page_list(&cc->freepages);
 	VM_BUG_ON(cc->nr_freepages != 0);
 
 	return ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cf31191..374adf8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1300,20 +1300,24 @@ void free_base_page(struct page *page)
 }
 
 /* Free a list of 0-order pages */
-void free_base_page_list(struct list_head *list)
+static unsigned long __free_base_page_list(struct list_head *list, bool release)
 {
 	struct page *page, *next;
 	struct zone *locked_zone = NULL;
 	struct free_magazine *mag = NULL;
 	bool use_magazine = (!in_interrupt() && !irqs_disabled());
 	int migratetype = MIGRATE_UNMOVABLE;
+	unsigned long count = 0;
 
-	/* Similar to free_hot_cold_page except magazine lock is batched */
+	/* Similar to free_base_page except magazine lock is batched */
 	list_for_each_entry_safe(page, next, list, lru) {
 		struct zone *zone = page_zone(page);
 		int migratetype;
 
 		trace_mm_page_free_batched(page);
+		if (release)
+			BUG_ON(!put_page_testzero(page));
+
 		migratetype = free_base_page_prep(page);
 		if (migratetype == -1)
 			continue;
@@ -1331,10 +1335,23 @@ void free_base_page_list(struct list_head *list)
 			locked_zone = zone;
 		}
 		__free_base_page(zone, &mag->area, page, migratetype);
+		count++;
 	}
 
 	if (locked_zone)
 		magazine_drain(locked_zone, mag, migratetype);
+
+	return count;
+}
+
+void free_base_page_list(struct list_head *list)
+{
+	__free_base_page_list(list, false);
+}
+
+unsigned long release_free_page_list(struct list_head *list)
+{
+	return __free_base_page_list(list, true);
 }
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
