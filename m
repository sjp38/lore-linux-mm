Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF93C6B026B
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:06 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id a107so943915wrc.11
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c5si1436970edm.95.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 8/8] mm, compaction: replace free scanner with direct freelist allocation
Date: Wed, 13 Dec 2017 09:59:15 +0100
Message-Id: <20171213085915.9278-9-vbabka@suse.cz>
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
References: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

The goal of direct compaction is to quickly make a high-order page available
for the pending allocation. The free page scanner can add significant latency
when searching for migration targets, although to succeed the compaction, the
only important limit on the target free pages is that they must not come from
the same order-aligned block as the migrated pages.

This patch therefore makes compaction allocate freepages directly from
freelists. Pages that do come from the same block (which we cannot simply
exclude from the freelist allocation) are skipped and put back to the tail of
freelists.

In addition to reduced stall, another advantage is that we split larger free
pages for migration targets only when smaller pages are depleted, while the
free scanner can split pages up to (order - 1) as it encouters them. Further
advantage is that now the migration scanner can compact the whole zone, while
in the current scheme it has been observed to meet the free scanner in 1/3 to
1/2 of the zone.

One danger of the new scheme is that pages will be migrated back and forth as
the migration scanner would form a range of free pages (except non-movable and
THP pages) and then "slide" this range towards the end of the zone, as long as
the non-movable pages prevent it from succeeding. The previous patches in this
series should make this improbable for direct compaction thanks to the
pre-scanning approach. The same thing could be done for kcompactd, but it's not
clear yet how to handle manually triggered compaction from /proc as that has no
success termination criteria.

For observational purposes, the patch introduces two new counters to
/proc/vmstat. compact_free_list_alloc counts how many pages were allocated
directly without scanning, and compact_free_direct_skip counts the subset of
these allocations that were from the wrong range and had to be put back.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/vm_event_item.h |  1 +
 mm/compaction.c               | 10 ++++--
 mm/internal.h                 |  2 ++
 mm/page_alloc.c               | 71 +++++++++++++++++++++++++++++++++++++++++++
 mm/vmstat.c                   |  2 ++
 5 files changed, 84 insertions(+), 2 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index cf92b1f115ee..04c5dfb245b4 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -56,6 +56,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #ifdef CONFIG_COMPACTION
 		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
 		COMPACTMIGRATE_PRESCANNED,
+		COMPACTFREE_LIST_ALLOC, COMPACTFREE_LIST_SKIP,
 		COMPACTISOLATED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 		KCOMPACTD_WAKE,
diff --git a/mm/compaction.c b/mm/compaction.c
index 3e6a37162d77..0832c4a31181 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1327,14 +1327,20 @@ static struct page *compaction_alloc(struct page *migratepage,
 {
 	struct compact_control *cc = (struct compact_control *)data;
 	struct page *freepage;
+	int queued;
 
 	/*
 	 * Isolate free pages if necessary, and if we are not aborting due to
 	 * contention.
 	 */
 	if (list_empty(&cc->freepages)) {
-		if (!cc->contended)
-			isolate_freepages(cc);
+		if (!cc->contended) {
+			queued = alloc_pages_compact(cc->zone, &cc->freepages,
+				cc->nr_migratepages,
+				(cc->migrate_pfn - 1) >> pageblock_order);
+			cc->nr_freepages += queued;
+			map_pages(&cc->freepages);
+		}
 
 		if (list_empty(&cc->freepages))
 			return NULL;
diff --git a/mm/internal.h b/mm/internal.h
index 35ff677cf731..3e7a28caaa50 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -161,6 +161,8 @@ static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 }
 
 extern int __isolate_free_page(struct page *page, unsigned int order);
+extern int alloc_pages_compact(struct zone *zone, struct list_head *list,
+				int pages, unsigned long pageblock_exclude);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0c9d97e1b0b7..5717135a9222 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2417,6 +2417,77 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 	return alloced;
 }
 
+static
+int __rmqueue_compact(struct zone *zone, struct list_head *list, int pages,
+						unsigned long pageblock_exclude)
+{
+	unsigned int order;
+	struct page *page, *next;
+	int mtype;
+	int fallback;
+	struct list_head * free_list;
+	LIST_HEAD(skip_list);
+	int queued_pages = 0;
+
+	for (order = 0; order < MAX_ORDER; ++order) {
+		for (mtype = MIGRATE_MOVABLE, fallback = 0;
+		     mtype != MIGRATE_TYPES;
+		     mtype = fallbacks[MIGRATE_MOVABLE][fallback++]) {
+
+			free_list = &zone->free_area[order].free_list[mtype];
+			list_for_each_entry_safe(page, next, free_list, lru) {
+				if (page_to_pfn(page) >> pageblock_order
+							== pageblock_exclude) {
+					list_move(&page->lru, &skip_list);
+					count_vm_event(COMPACTFREE_LIST_SKIP);
+					continue;
+				}
+
+
+				list_move(&page->lru, list);
+				zone->free_area[order].nr_free--;
+				rmv_page_order(page);
+				set_page_private(page, order);
+
+				__mod_zone_freepage_state(zone, -(1UL << order),
+					get_pageblock_migratetype(page));
+
+				queued_pages += 1 << order;
+				if (queued_pages >= pages)
+					break;
+			}
+			/*
+			 * Put skipped pages at the end of free list so we are
+			 * less likely to encounter them again.
+			 */
+			list_splice_tail_init(&skip_list, free_list);
+		}
+	}
+	count_vm_events(COMPACTFREE_LIST_ALLOC, queued_pages);
+	count_vm_events(COMPACTISOLATED, queued_pages);
+	return queued_pages;
+}
+
+int alloc_pages_compact(struct zone *zone, struct list_head *list, int pages,
+						unsigned long pageblock_exclude)
+{
+	unsigned long flags;
+	unsigned long watermark;
+	int queued_pages;
+
+	watermark = low_wmark_pages(zone) + pages;
+	if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
+		return 0;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	queued_pages = __rmqueue_compact(zone, list, pages, pageblock_exclude);
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return queued_pages;
+}
+
 #ifdef CONFIG_NUMA
 /*
  * Called from the vmstat counter updater to drain pagesets of this
diff --git a/mm/vmstat.c b/mm/vmstat.c
index cf445f8280e4..3c537237bda7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1224,6 +1224,8 @@ const char * const vmstat_text[] = {
 	"compact_migrate_scanned",
 	"compact_free_scanned",
 	"compact_migrate_prescanned",
+	"compact_free_list_alloc",
+	"compact_free_list_skip",
 	"compact_isolated",
 	"compact_stall",
 	"compact_fail",
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
