Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 70AF76B0132
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:13 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/22] mm: page allocator: Only check migratetype of pages being drained while CMA active
Date: Wed,  8 May 2013 17:02:49 +0100
Message-Id: <1368028987-8369-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

CMA added a is_migrate_isolate_page in the bulk page free path which
does a pageblock migratetype lookup for every page being drained. This
is only necessary when CMA is active so skip the expensive checks in the
normal case.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h         |  8 ++++++--
 include/linux/page-isolation.h |  7 ++++---
 mm/page_alloc.c                |  2 +-
 mm/page_isolation.c            | 27 +++++++++++++++++++++++----
 4 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e71e3a6..57f03b3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -354,12 +354,16 @@ struct zone {
 	spinlock_t		lock;
 	int                     all_unreclaimable; /* All pages pinned */
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
+	unsigned long		compact_cached_free_pfn;
+	unsigned long		compact_cached_migrate_pfn;
+
 	/* Set to true when the PG_migrate_skip bits should be cleared */
 	bool			compact_blockskip_flush;
 
 	/* pfns where compaction scanners should start */
-	unsigned long		compact_cached_free_pfn;
-	unsigned long		compact_cached_migrate_pfn;
+#endif
+#ifdef CONFIG_MEMORY_ISOLATION
+	bool			memory_isolation_active;
 #endif
 #ifdef CONFIG_MEMORY_HOTPLUG
 	/* see spanned/present_pages for more description */
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 3fff8e7..81287bb 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -2,16 +2,17 @@
 #define __LINUX_PAGEISOLATION_H
 
 #ifdef CONFIG_MEMORY_ISOLATION
-static inline bool is_migrate_isolate_page(struct page *page)
+static inline bool is_migrate_isolate_page(struct zone *zone, struct page *page)
 {
-	return get_pageblock_migratetype(page) == MIGRATE_ISOLATE;
+	return zone->memory_isolation_active &&
+		get_pageblock_migratetype(page) == MIGRATE_ISOLATE;
 }
 static inline bool is_migrate_isolate(int migratetype)
 {
 	return migratetype == MIGRATE_ISOLATE;
 }
 #else
-static inline bool is_migrate_isolate_page(struct page *page)
+static inline bool is_migrate_isolate_page(struct zone *zone, struct page *page)
 {
 	return false;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4a07771..f170260 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -674,7 +674,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
-			if (likely(!is_migrate_isolate_page(page))) {
+			if (likely(!is_migrate_isolate_page(zone, page))) {
 				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
 				if (is_migrate_cma(mt))
 					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 383bdbb..9f0c068 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -118,6 +118,8 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long pfn;
 	unsigned long undo_pfn;
 	struct page *page;
+	struct zone *zone = NULL;
+	unsigned long flags;
 
 	BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
 	BUG_ON((end_pfn) & (pageblock_nr_pages - 1));
@@ -126,12 +128,20 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (page &&
-		    set_migratetype_isolate(page, skip_hwpoisoned_pages)) {
-			undo_pfn = pfn;
-			goto undo;
+		if (page) {
+			if (!zone)
+				zone = page_zone(page);
+			if (set_migratetype_isolate(page,
+						    skip_hwpoisoned_pages)) {
+				undo_pfn = pfn;
+				goto undo;
+			}
 		}
 	}
+
+	spin_lock_irqsave(&zone->lock, flags);
+	zone->memory_isolation_active = true;
+	spin_unlock_irqrestore(&zone->lock, flags);
 	return 0;
 undo:
 	for (pfn = start_pfn;
@@ -150,6 +160,9 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 {
 	unsigned long pfn;
 	struct page *page;
+	struct zone *zone = NULL;
+	unsigned long flags;
+
 	BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
 	BUG_ON((end_pfn) & (pageblock_nr_pages - 1));
 	for (pfn = start_pfn;
@@ -159,7 +172,13 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 		if (!page || get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 			continue;
 		unset_migratetype_isolate(page, migratetype);
+		if (!zone)
+			zone = page_zone(page);
 	}
+
+	spin_lock_irqsave(&zone->lock, flags);
+	zone->memory_isolation_active = true;
+	spin_unlock_irqrestore(&zone->lock, flags);
 	return 0;
 }
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
