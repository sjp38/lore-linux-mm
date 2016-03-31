Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF6B6B0260
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 04:51:10 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id 20so104103579wmh.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 01:51:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nw5si10664113wjb.32.2016.03.31.01.51.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 01:51:01 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 4/4] mm, compaction: direct freepage allocation for async direct compaction
Date: Thu, 31 Mar 2016 10:50:36 +0200
Message-Id: <1459414236-9219-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
References: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

The goal of direct compaction is to quickly make a high-order page available
for the pending allocation. The free page scanner can add significant latency
when searching for migration targets, although to succeed the compaction, the
only important limit on the target free pages is that they must not come from
the same order-aligned block as the migrated pages.

This patch therefore makes direct async compaction allocate freepages directly
from freelists. Pages that do come from the same block (which we cannot simply
exclude from the freelist allocation) are put on separate list and released
only after migration to allow them to merge.

In addition to reduced stall, another advantage is that we split larger free
pages for migration targets only when smaller pages are depleted, while the
free scanner can split pages up to (order - 1) as it encouters them. However,
this approach likely sacrifices some of the long-term anti-fragmentation
features of a thorough compaction, so we limit the direct allocation approach
to direct async compaction.

For observational purposes, the patch introduces two new counters to
/proc/vmstat. compact_free_direct_alloc counts how many pages were allocated
directly without scanning, and compact_free_direct_miss counts the subset of
these allocations that were from the wrong range and had to be held on the
separate list.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/vm_event_item.h |  1 +
 mm/compaction.c               | 52 ++++++++++++++++++++++++++++++++++++++++++-
 mm/internal.h                 |  5 +++++
 mm/page_alloc.c               | 27 ++++++++++++++++++++++
 mm/vmstat.c                   |  2 ++
 5 files changed, 86 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index ec084321fe09..9ec29406a01e 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -51,6 +51,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 #ifdef CONFIG_COMPACTION
 		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
+		COMPACTFREE_DIRECT_ALLOC, COMPACTFREE_DIRECT_MISS,
 		COMPACTISOLATED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 		KCOMPACTD_WAKE,
diff --git a/mm/compaction.c b/mm/compaction.c
index fe94d22d9144..215db281ecaf 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1083,6 +1083,41 @@ static void isolate_freepages(struct compact_control *cc)
 	cc->free_pfn = isolate_start_pfn;
 }
 
+static void isolate_freepages_direct(struct compact_control *cc)
+{
+	unsigned long nr_pages;
+	unsigned long flags;
+
+	nr_pages = cc->nr_migratepages - cc->nr_freepages;
+
+	if (!compact_trylock_irqsave(&cc->zone->lock, &flags, cc))
+		return;
+
+	while (nr_pages) {
+		struct page *page;
+		unsigned long pfn;
+
+		page = alloc_pages_zone(cc->zone, 0, MIGRATE_MOVABLE);
+		if (!page)
+			break;
+		pfn = page_to_pfn(page);
+
+		count_compact_event(COMPACTFREE_DIRECT_ALLOC);
+
+		/* Is the free page in the block we are migrating from? */
+		if (pfn >> cc->order ==	(cc->migrate_pfn - 1) >> cc->order) {
+			list_add(&page->lru, &cc->freepages_held);
+			count_compact_event(COMPACTFREE_DIRECT_MISS);
+		} else {
+			list_add(&page->lru, &cc->freepages);
+			cc->nr_freepages++;
+			nr_pages--;
+		}
+	}
+
+	spin_unlock_irqrestore(&cc->zone->lock, flags);
+}
+
 /*
  * This is a migrate-callback that "allocates" freepages by taking pages
  * from the isolated freelists in the block we are migrating to.
@@ -1099,7 +1134,12 @@ static struct page *compaction_alloc(struct page *migratepage,
 	 * contention.
 	 */
 	if (list_empty(&cc->freepages)) {
-		if (!cc->contended)
+		if (cc->contended)
+			return NULL;
+
+		if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC))
+			isolate_freepages_direct(cc);
+		else
 			isolate_freepages(cc);
 
 		if (list_empty(&cc->freepages))
@@ -1475,6 +1515,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 						(cc->mode == MIGRATE_ASYNC)) {
 				cc->migrate_pfn = block_end_pfn(
 						cc->migrate_pfn - 1, cc->order);
+
+				if (!list_empty(&cc->freepages_held))
+					release_freepages(&cc->freepages_held);
+
 				/* Draining pcplists is useless in this case */
 				cc->last_migrated_pfn = 0;
 
@@ -1495,6 +1539,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 				block_start_pfn(cc->migrate_pfn, cc->order);
 
 			if (cc->last_migrated_pfn < current_block_start) {
+				if (!list_empty(&cc->freepages_held))
+					release_freepages(&cc->freepages_held);
 				cpu = get_cpu();
 				lru_add_drain_cpu(cpu);
 				drain_local_pages(zone);
@@ -1525,6 +1571,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		if (free_pfn > zone->compact_cached_free_pfn)
 			zone->compact_cached_free_pfn = free_pfn;
 	}
+	if (!list_empty(&cc->freepages_held))
+		release_freepages(&cc->freepages_held);
 
 	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync, ret);
@@ -1553,6 +1601,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
+	INIT_LIST_HEAD(&cc.freepages_held);
 
 	ret = compact_zone(zone, &cc);
 
@@ -1698,6 +1747,7 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		cc->zone = zone;
 		INIT_LIST_HEAD(&cc->freepages);
 		INIT_LIST_HEAD(&cc->migratepages);
+		INIT_LIST_HEAD(&cc->freepages_held);
 
 		/*
 		 * When called via /proc/sys/vm/compact_memory
diff --git a/mm/internal.h b/mm/internal.h
index b79abb6721cf..a0c0286a9567 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -145,6 +145,8 @@ static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 }
 
 extern int __isolate_free_page(struct page *page, unsigned int order);
+extern struct page * alloc_pages_zone(struct zone *zone, unsigned int order,
+							int migratetype);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
@@ -165,6 +167,9 @@ extern int user_min_free_kbytes;
 struct compact_control {
 	struct list_head freepages;	/* List of free pages to migrate to */
 	struct list_head migratepages;	/* List of pages being migrated */
+	struct list_head freepages_held;/* List of free pages from the block
+					 * that's being migrated
+					 */
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d5d3a3..3ee83fe02274 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2343,6 +2343,33 @@ int split_free_page(struct page *page)
 }
 
 /*
+ * Like split_free_page, but given the zone, it will grab a free page from
+ * the freelists.
+ */
+struct page *
+alloc_pages_zone(struct zone *zone, unsigned int order, int migratetype)
+{
+	struct page *page;
+	unsigned long watermark;
+
+	watermark = low_wmark_pages(zone) + (1 << order);
+	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+		return NULL;
+
+	page = __rmqueue(zone, order, migratetype);
+	if (!page)
+		return NULL;
+
+	__mod_zone_freepage_state(zone, -(1 << order),
+					  get_pcppage_migratetype(page));
+
+	set_page_owner(page, order, __GFP_MOVABLE);
+	set_page_refcounted(page);
+
+	return page;
+}
+
+/*
  * Allocate a page from the given zone. Use pcplists for order-0 allocations.
  */
 static inline
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5e4300482897..9e07d11afa0d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -822,6 +822,8 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_COMPACTION
 	"compact_migrate_scanned",
 	"compact_free_scanned",
+	"compact_free_direct_alloc",
+	"compact_free_direct_miss",
 	"compact_isolated",
 	"compact_stall",
 	"compact_fail",
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
