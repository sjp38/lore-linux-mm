From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070529173810.1570.17754.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/7] Introduce a means of compacting memory within a zone
Date: Tue, 29 May 2007 18:38:10 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch is the core of the memory compaction mechanism. It compacts memory
in a zone such that movable pages are relocated towards the end of the zone.

A single compaction run involves a migration scanner and a free scanner.
Both scanners operate on pageblock-sized areas in the zone. The migration
scanner starts at the bottom of the zone and searches for all movable pages
within each area, isolating them onto a private list called migratelist.
The free scanner starts at the top of the zone and searches for suitable
areas and consumes the free pages within making them available for the
migration scanner.

Note that after this patch is applied there is still no means of triggering
a compaction run. Later patches will introduce the triggers, initially a
manual trigger.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 include/linux/mm.h |    1 
 mm/compaction.c    |  288 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c    |   40 ++++++
 3 files changed, 329 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-105_measure_fragmentation/include/linux/mm.h linux-2.6.22-rc2-mm1-110_compact_zone/include/linux/mm.h
--- linux-2.6.22-rc2-mm1-105_measure_fragmentation/include/linux/mm.h	2007-05-28 14:13:44.000000000 +0100
+++ linux-2.6.22-rc2-mm1-110_compact_zone/include/linux/mm.h	2007-05-29 10:22:15.000000000 +0100
@@ -337,6 +337,7 @@ void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
+int split_pagebuddy_page(struct page *page);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-105_measure_fragmentation/mm/compaction.c linux-2.6.22-rc2-mm1-110_compact_zone/mm/compaction.c
--- linux-2.6.22-rc2-mm1-105_measure_fragmentation/mm/compaction.c	2007-05-29 10:20:32.000000000 +0100
+++ linux-2.6.22-rc2-mm1-110_compact_zone/mm/compaction.c	2007-05-29 10:22:15.000000000 +0100
@@ -5,6 +5,29 @@
  * Copyright IBM Corp. 2007 Mel Gorman <mel@csn.ul.ie>
  */
 #include <linux/mmzone.h>
+#include <linux/gfp.h>
+#include <linux/list.h>
+#include <linux/vmstat.h>
+#include <linux/swap.h>
+#include <linux/migrate.h>
+#include <linux/swap-prefetch.h>
+#include "internal.h"
+
+/*
+ * compact_control is used to track pages being migrated and the free pages
+ * they are being migrated to during memory compaction. The free_pfn starts
+ * at the end of a zone and migrate_pfn begins at the start. Movable pages
+ * are moved to the end of a zone during a compaction run and the run
+ * completes when free_pfn <= migrate_pfn
+ */
+struct compact_control {
+	struct list_head freepages;	/* List of free pages to migrate to */
+	struct list_head migratepages;	/* List of pages being migated */
+	unsigned long nr_freepages;	/* Number of free pages */
+	unsigned long nr_migratepages;	/* Number of migrate pages */
+	unsigned long free_pfn;		/* isolate_freepages search area */
+	unsigned long migrate_pfn;	/* isolate_migratepages search area */
+};
 
 /*
  * Calculate the number of free pages in a zone and how many contiguous
@@ -84,3 +107,268 @@ int fragmentation_index(struct zone *zon
 
 	return 100 - ((freepages / (1 << target_order)) * 100) / areas_free;
 }
+
+static int release_freepages(struct zone *zone, struct list_head *freelist)
+{
+	struct page *page, *next;
+	int count = 0;
+
+	list_for_each_entry_safe(page, next, freelist, lru) {
+		list_del(&page->lru);
+		__free_page(page);
+		count++;
+	}
+
+	return count;
+}
+
+/* Isolate free pages onto a private freelist. Must hold zone->lock */
+static int isolate_freepages_block(struct zone *zone,
+				unsigned long blockpfn,
+				struct list_head *freelist)
+{
+	unsigned long zone_end_pfn, end_pfn;
+	int total_isolated = 0;
+
+	/* Get the last PFN we should scan for free pages at */
+	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	end_pfn = blockpfn + pageblock_nr_pages;
+	if (end_pfn > zone_end_pfn)
+		end_pfn = zone_end_pfn;
+
+	/* Isolate free pages */
+	for (; blockpfn < end_pfn; blockpfn++) {
+		struct page *page;
+		int isolated, i;
+
+		if (!pfn_valid_within(blockpfn))
+			continue;
+
+		page = pfn_to_page(blockpfn);
+		if (!PageBuddy(page))
+			continue;
+
+		/* Found a free page, break it into order-0 pages */
+		isolated = split_pagebuddy_page(page);
+		total_isolated += isolated;
+		for (i = 0; i < isolated; i++) {
+			list_add(&page->lru, freelist);
+			page++;
+		}
+		blockpfn += isolated - 1;
+	}
+
+	return total_isolated;
+}
+
+/* Returns 1 if the page is within a block suitable for migration to */
+static int pageblock_suitable_migration(struct page *page)
+{
+	/* If the page is a large free page, then allow migration */
+	if (PageBuddy(page) && page_order(page) >= pageblock_order)
+		return 1;
+
+	/* If the block is MIGRATE_MOVABLE, allow migration */
+	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE)
+		return 1;
+
+	/* Otherwise skip the block */
+	return 0;
+}
+
+/*
+ * Based on information in the current compact_control, find blocks
+ * suitable for isolating free pages within
+ */
+static void isolate_freepages(struct zone *zone,
+				struct compact_control *cc)
+{
+	struct page *page;
+	unsigned long highpfn, lowpfn, pfn;
+	int nr_freepages = cc->nr_freepages;
+	struct list_head *freelist = &cc->freepages;
+	unsigned long flags;
+
+	pfn = cc->free_pfn;
+	lowpfn = cc->migrate_pfn + pageblock_nr_pages;
+	highpfn = lowpfn;
+
+	/*
+	 * Isolate free pages until enough are available to migrate the
+	 * pages on cc->migratepages. We stop searching if the migrate
+	 * and free page scanners meet or enough free pages are isolated.
+	 */
+	spin_lock_irqsave(&zone->lock, flags);
+	for (; pfn > lowpfn && cc->nr_migratepages > nr_freepages;
+					pfn -= pageblock_nr_pages) {
+		int isolated;
+
+		if (!pfn_valid(pfn))
+			continue;
+
+		/* Check for overlapping nodes/zones */
+		page = pfn_to_page(pfn);
+		if (page_zone(page) != zone)
+			continue;
+
+		/* Check the block is suitable for migration */
+		if (!pageblock_suitable_migration(page))
+			continue;
+
+		/* Found a block suitable for isolating free pages from */
+		isolated = isolate_freepages_block(zone, pfn, freelist);
+		nr_freepages += isolated;
+
+		/*
+		 * Record the highest PFN we isolated pages from. When next
+		 * looking for free pages, the search will start here in case
+		 * migration did not use all free pages.
+		 */
+		if (isolated)
+			highpfn = max(highpfn, pfn);
+	}
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	cc->free_pfn = highpfn;
+	cc->nr_freepages = nr_freepages;
+}
+
+/*
+ * Isolate all pages that can be migrated from the block pointed to by
+ * the migrate scanner within compact_control. We migrate pages from
+ * all block-types as the intention is to have all movable pages towards
+ * the end of the zone.
+ */
+static int isolate_migratepages(struct zone *zone,
+					struct compact_control *cc)
+{
+	unsigned long highpfn, lowpfn, end_pfn, start_pfn;
+	struct page *page;
+	int isolated = 0;
+	struct list_head *migratelist;
+
+	highpfn = cc->free_pfn;
+	lowpfn = ALIGN(cc->migrate_pfn, pageblock_nr_pages);
+	migratelist = &cc->migratepages;
+
+	/* Do not scan outside zone boundaries */
+	if (lowpfn < zone->zone_start_pfn)
+		lowpfn = zone->zone_start_pfn;
+
+	/* Setup to scan one block but not past where we are migrating to */
+	end_pfn = ALIGN(lowpfn + pageblock_nr_pages, pageblock_nr_pages);
+	if (end_pfn > highpfn)
+		end_pfn = highpfn;
+	start_pfn = lowpfn;
+
+	/* Time to isolate some pages for migration */
+	spin_lock_irq(&zone->lru_lock);
+	for (; lowpfn < end_pfn; lowpfn++) {
+		if (!pfn_valid_within(lowpfn))
+			continue;
+
+		/* Get the page and skip if free */
+		page = pfn_to_page(lowpfn);
+		if (PageBuddy(page)) {
+			lowpfn += (1 << page_order(page)) - 1;
+			continue;
+		}
+
+		/* Try isolate the page */
+		if (isolate_lru_page_nolock(zone, page, migratelist) == 0)
+			isolated++;
+	}
+	spin_unlock_irq(&zone->lru_lock);
+
+	cc->migrate_pfn = end_pfn;
+	cc->nr_migratepages += isolated;
+	return isolated;
+}
+
+/*
+ * This is a migrate-callback that "allocates" freepages by taking pages
+ * from the isolated freelists in the block we are migrating to.
+ */
+static struct page *compaction_alloc(struct page *migratepage,
+					unsigned long data,
+					int **result)
+{
+	struct compact_control *cc = (struct compact_control *)data;
+	struct page *freepage;
+
+	VM_BUG_ON(cc == NULL);
+	if (list_empty(&cc->freepages))
+		return NULL;
+
+	freepage = list_entry(cc->freepages.next, struct page, lru);
+	list_del(&freepage->lru);
+	cc->nr_freepages--;
+
+#ifdef CONFIG_PAGE_OWNER
+	freepage->order = migratepage->order;
+	freepage->gfp_mask = migratepage->gfp_mask;
+	memcpy(freepage->trace, migratepage->trace, sizeof(freepage->trace));
+#endif
+
+	return freepage;
+}
+
+/*
+ * We cannot control nr_migratepages and nr_freepages fully when migation is
+ * running as migrate_pages() has no knowledge of compact_control. When
+ * migration is complete, we count the number of pages on the lists by hand.
+ */
+static void update_nr_listpages(struct compact_control *cc)
+{
+	int nr_migratepages = 0;
+	int nr_freepages = 0;
+	struct page *page;
+	list_for_each_entry(page, &cc->migratepages, lru)
+		nr_migratepages++;
+	list_for_each_entry(page, &cc->freepages, lru)
+		nr_freepages++;
+
+	cc->nr_migratepages = nr_migratepages;
+	cc->nr_freepages = nr_freepages;
+}
+
+static unsigned long compact_zone(struct zone *zone, struct compact_control *cc)
+{
+	/* Setup to move all movable pages to the end of the zone */
+	cc->migrate_pfn = zone->zone_start_pfn;
+	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
+	cc->free_pfn &= ~(pageblock_nr_pages-1);
+
+	/* Flush pening updates to the LRU lists */
+	lru_add_drain_all();
+
+	/* Compact until the two PFN pointers cross */
+	while (cc->free_pfn > cc->migrate_pfn) {
+		isolate_migratepages(zone, cc);
+
+		if (!cc->nr_migratepages)
+			continue;
+
+		/* Isolate free pages if necessary */
+		if (cc->nr_freepages < cc->nr_migratepages)
+			isolate_freepages(zone, cc);
+
+		/* Stop compacting if we cannot get enough free pages */
+		if (cc->nr_freepages < cc->nr_migratepages)
+			break;
+
+		migrate_pages_nocontext(&cc->migratepages, compaction_alloc,
+							(unsigned long)cc);
+		update_nr_listpages(cc);
+	}
+
+	/* Release free pages and check accounting */
+	cc->nr_freepages -= release_freepages(zone, &cc->freepages);
+	WARN_ON(cc->nr_freepages != 0);
+
+	/* Release LRU pages not migrated */
+	if (!list_empty(&cc->migratepages))
+		putback_lru_pages(&cc->migratepages);
+
+	return 0;
+}
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-105_measure_fragmentation/mm/page_alloc.c linux-2.6.22-rc2-mm1-110_compact_zone/mm/page_alloc.c
--- linux-2.6.22-rc2-mm1-105_measure_fragmentation/mm/page_alloc.c	2007-05-28 14:09:40.000000000 +0100
+++ linux-2.6.22-rc2-mm1-110_compact_zone/mm/page_alloc.c	2007-05-29 10:22:15.000000000 +0100
@@ -1065,6 +1065,46 @@ void split_page(struct page *page, unsig
 }
 
 /*
+ * Similar to split_page except the page is already free.
+ *
+ * TODO: This potentially goes below watermarks and knowing we are going
+ *       to free the pages soon is no good because we may need to make small
+ *       allocations for migration to succeed. Obey watermarks
+ */
+int split_pagebuddy_page(struct page *page)
+{
+	int order;
+	struct zone *zone;
+
+	/* Should never happen but lets handle it anyway */
+	if (!page || !PageBuddy(page))
+		return 0;
+
+	zone = page_zone(page);
+	order = page_order(page);
+
+	/* Remove page from free list */
+	list_del(&page->lru);
+	zone->free_area[order].nr_free--;
+	rmv_page_order(page);
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+
+	/* Split into individual pages */
+	set_page_refcounted(page);
+	split_page(page, order);
+
+	/* Set the migratetype of the block if necessary */
+	if (order >= pageblock_order - 1 &&
+			get_pageblock_migratetype(page) != MIGRATE_MOVABLE) {
+		struct page *endpage = page + (1 << order) - 1;
+		for (; page < endpage; page += pageblock_nr_pages)
+			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+	}
+
+	return 1 << order;
+}
+
+/*
  * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
  * or two.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
