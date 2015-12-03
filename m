Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 16B0F6B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:11:07 -0500 (EST)
Received: by wmww144 with SMTP id w144so11024266wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:11:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si6821905wmc.49.2015.12.03.00.11.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 00:11:02 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 3/3] mm, compaction: direct freepage allocation for async direct compaction
Date: Thu,  3 Dec 2015 09:10:47 +0100
Message-Id: <1449130247-8040-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Aaron Lu <aaron.lu@intel.com>
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

The goal of direct compaction is to quickly make a high-order page available.
The free page scanner can add significant latency when searching for free
pages, although to succeed the compaction, the only important limit on the free
pages for migration targets is that they must not come from the same
order-aligned block as the migration sources.

This patch therefore makes direct async compaction allocate freepages directly
from freelists. Pages that do come from the same block (which we cannot simply
exclude from the allocation) are put on separate list and released afterwards
to facilitate merging.

Another advantage is that we split larger free pages only when necessary, while
the free scanner can split potentially up to order-1. However, we still likely
sacrifice some of the long-term anti-fragmentation features of a thorough
compaction, hence the limiting of this approach to direct async compaction.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/vm_event_item.h |  1 +
 mm/compaction.c               | 47 ++++++++++++++++++++++++++++++++++++++++++-
 mm/internal.h                 |  3 +++
 mm/page_alloc.c               | 27 +++++++++++++++++++++++++
 mm/vmstat.c                   |  2 ++
 5 files changed, 79 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index e623d392db0c..614291613408 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -50,6 +50,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 #ifdef CONFIG_COMPACTION
 		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
+		COMPACTFREE_DIRECT, COMPACTFREE_DIRECT_MISS,
 		COMPACTISOLATED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 #endif
diff --git a/mm/compaction.c b/mm/compaction.c
index f94518b5b1c9..74b5b5ddebb0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1088,6 +1088,40 @@ static void isolate_freepages(struct compact_control *cc)
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
+		/* Is the free page in the block we are migrating from? */
+		if (pfn >> cc->order ==	(cc->migrate_pfn - 1) >> cc->order) {
+			list_add(&page->lru, &cc->culled_freepages);
+			count_compact_event(COMPACTFREE_DIRECT_MISS);
+		} else {
+			list_add(&page->lru, &cc->freepages);
+			cc->nr_freepages++;
+			nr_pages--;
+			count_compact_event(COMPACTFREE_DIRECT);
+		}
+	}
+
+	spin_unlock_irqrestore(&cc->zone->lock, flags);
+}
+
 /*
  * This is a migrate-callback that "allocates" freepages by taking pages
  * from the isolated freelists in the block we are migrating to.
@@ -1104,7 +1138,12 @@ static struct page *compaction_alloc(struct page *migratepage,
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
@@ -1481,6 +1520,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 				cc->migrate_pfn & ~((1UL << cc->order) - 1);
 
 			if (cc->last_migrated_pfn < current_block_start) {
+				if (!list_empty(&cc->culled_freepages))
+					release_freepages(&cc->culled_freepages);
 				cpu = get_cpu();
 				lru_add_drain_cpu(cpu);
 				drain_local_pages(zone);
@@ -1511,6 +1552,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		if (free_pfn > zone->compact_cached_free_pfn)
 			zone->compact_cached_free_pfn = free_pfn;
 	}
+	if (!list_empty(&cc->culled_freepages))
+		release_freepages(&cc->culled_freepages);
 
 	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync, ret);
@@ -1539,6 +1582,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
+	INIT_LIST_HEAD(&cc.culled_freepages);
 
 	ret = compact_zone(zone, &cc);
 
@@ -1684,6 +1728,7 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		cc->zone = zone;
 		INIT_LIST_HEAD(&cc->freepages);
 		INIT_LIST_HEAD(&cc->migratepages);
+		INIT_LIST_HEAD(&cc->culled_freepages);
 
 		/*
 		 * When called via /proc/sys/vm/compact_memory
diff --git a/mm/internal.h b/mm/internal.h
index 079ba14afe55..cb6a3f6ca631 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -175,6 +175,8 @@ __find_buddy_index(unsigned long page_idx, unsigned int order)
 }
 
 extern int __isolate_free_page(struct page *page, unsigned int order);
+extern struct page * alloc_pages_zone(struct zone *zone, unsigned int order,
+							int migratetype);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
@@ -198,6 +200,7 @@ extern int user_min_free_kbytes;
 struct compact_control {
 	struct list_head freepages;	/* List of free pages to migrate to */
 	struct list_head migratepages;	/* List of pages being migrated */
+	struct list_head culled_freepages;
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17a3c66639a9..715f0e6047c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2185,6 +2185,33 @@ int split_free_page(struct page *page)
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
+	page = __rmqueue(zone, order, migratetype, 0);
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
index 879a2be23325..20e2affdc08e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -819,6 +819,8 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_COMPACTION
 	"compact_migrate_scanned",
 	"compact_free_scanned",
+	"compact_free_direct",
+	"compact_free_direct_miss",
 	"compact_isolated",
 	"compact_stall",
 	"compact_fail",
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
