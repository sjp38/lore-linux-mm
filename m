Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 3F56D6B009E
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 07:39:19 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LWY007JKTTGCG@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 29 Dec 2011 12:39:16 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWY00HDUTTFGR@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Dec 2011 12:39:16 +0000 (GMT)
Date: Thu, 29 Dec 2011 13:39:04 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 03/11] mm: compaction: export some of the functions
In-reply-to: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1325162352-24709-4-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

From: Michal Nazarewicz <mina86@mina86.com>

This commit exports some of the functions from compaction.c file
outside of it adding their declaration into internal.h header
file so that other mm related code can use them.

This forced compaction.c to always be compiled (as opposed to being
compiled only if CONFIG_COMPACTION is defined) but as to avoid
introducing code that user did not ask for, part of the compaction.c
is now wrapped in on #ifdef.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/Makefile     |    3 +-
 mm/compaction.c |  342 ++++++++++++++++++++++++++-----------------------------
 mm/internal.h   |   35 ++++++
 3 files changed, 200 insertions(+), 180 deletions(-)

diff --git a/mm/Makefile b/mm/Makefile
index 50ec00e..8aada89 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -13,7 +13,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   page_isolation.o mm_init.o mmu_context.o percpu.o \
-			   $(mmu-y)
+			   compaction.o $(mmu-y)
 obj-y += init-mm.o
 
 ifdef CONFIG_NO_BOOTMEM
@@ -32,7 +32,6 @@ obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
-obj-$(CONFIG_COMPACTION) += compaction.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
diff --git a/mm/compaction.c b/mm/compaction.c
index ae73b6f..8733441 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -16,44 +16,11 @@
 #include <linux/sysfs.h>
 #include "internal.h"
 
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
 
-/*
- * compact_control is used to track pages being migrated and the free pages
- * they are being migrated to during memory compaction. The free_pfn starts
- * at the end of a zone and migrate_pfn begins at the start. Movable pages
- * are moved to the end of a zone during a compaction run and the run
- * completes when free_pfn <= migrate_pfn
- */
-struct compact_control {
-	struct list_head freepages;	/* List of free pages to migrate to */
-	struct list_head migratepages;	/* List of pages being migrated */
-	unsigned long nr_freepages;	/* Number of isolated free pages */
-	unsigned long nr_migratepages;	/* Number of pages to migrate */
-	unsigned long free_pfn;		/* isolate_freepages search base */
-	unsigned long migrate_pfn;	/* isolate_migratepages search base */
-	bool sync;			/* Synchronous migration */
-
-	unsigned int order;		/* order a direct compactor needs */
-	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
-	struct zone *zone;
-};
-
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
 /**
  * isolate_freepages_range() - isolate free pages, must hold zone->lock.
  * @zone:	Zone pages are in.
@@ -71,7 +38,7 @@ static unsigned long release_freepages(struct list_head *freelist)
  * Returns number of isolated pages.  This may be more then end_pfn-start_pfn
  * if end fell in a middle of a free page.
  */
-static unsigned long
+unsigned long
 isolate_freepages_range(struct zone *zone,
 			unsigned long start_pfn, unsigned long end_pfn,
 			struct list_head *freelist)
@@ -136,120 +103,6 @@ cleanup:
 	return 0;
 }
 
-/* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
-{
-
-	int migratetype = get_pageblock_migratetype(page);
-
-	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
-	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
-		return false;
-
-	/* If the page is a large free page, then allow migration */
-	if (PageBuddy(page) && page_order(page) >= pageblock_order)
-		return true;
-
-	/* If the block is MIGRATE_MOVABLE, allow migration */
-	if (migratetype == MIGRATE_MOVABLE)
-		return true;
-
-	/* Otherwise skip the block */
-	return false;
-}
-
-/*
- * Based on information in the current compact_control, find blocks
- * suitable for isolating free pages from and then isolate them.
- */
-static void isolate_freepages(struct zone *zone,
-				struct compact_control *cc)
-{
-	struct page *page;
-	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
-	unsigned long flags;
-	int nr_freepages = cc->nr_freepages;
-	struct list_head *freelist = &cc->freepages;
-
-	/*
-	 * Initialise the free scanner. The starting point is where we last
-	 * scanned from (or the end of the zone if starting). The low point
-	 * is the end of the pageblock the migration scanner is using.
-	 */
-	pfn = cc->free_pfn;
-	low_pfn = cc->migrate_pfn + pageblock_nr_pages;
-
-	/*
-	 * Take care that if the migration scanner is at the end of the zone
-	 * that the free scanner does not accidentally move to the next zone
-	 * in the next isolation cycle.
-	 */
-	high_pfn = min(low_pfn, pfn);
-
-	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-
-	/*
-	 * Isolate free pages until enough are available to migrate the
-	 * pages on cc->migratepages. We stop searching if the migrate
-	 * and free page scanners meet or enough free pages are isolated.
-	 */
-	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
-					pfn -= pageblock_nr_pages) {
-		unsigned long isolated;
-
-		if (!pfn_valid(pfn))
-			continue;
-
-		/*
-		 * Check for overlapping nodes/zones. It's possible on some
-		 * configurations to have a setup like
-		 * node0 node1 node0
-		 * i.e. it's possible that all pages within a zones range of
-		 * pages do not belong to a single zone.
-		 */
-		page = pfn_to_page(pfn);
-		if (page_zone(page) != zone)
-			continue;
-
-		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
-			continue;
-
-		/*
-		 * Found a block suitable for isolating free pages from. Now
-		 * we disabled interrupts, double check things are ok and
-		 * isolate the pages. This is to minimise the time IRQs
-		 * are disabled
-		 */
-		isolated = 0;
-		spin_lock_irqsave(&zone->lock, flags);
-		if (suitable_migration_target(page)) {
-			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
-			isolated = isolate_freepages_range(zone, pfn,
-					end_pfn, freelist);
-			nr_freepages += isolated;
-		}
-		spin_unlock_irqrestore(&zone->lock, flags);
-
-		/*
-		 * Record the highest PFN we isolated pages from. When next
-		 * looking for free pages, the search will restart here as
-		 * page migration may have returned some pages to the allocator
-		 */
-		if (isolated)
-			high_pfn = max(high_pfn, pfn);
-	}
-
-	/* split_free_page does not map the pages */
-	list_for_each_entry(page, freelist, lru) {
-		arch_alloc_page(page, 0);
-		kernel_map_pages(page, 1, 1);
-	}
-
-	cc->free_pfn = high_pfn;
-	cc->nr_freepages = nr_freepages;
-}
-
 /* Update the number of anon and file isolated pages in the zone */
 static void acct_isolated(struct zone *zone, struct compact_control *cc)
 {
@@ -278,13 +131,6 @@ static bool too_many_isolated(struct zone *zone)
 	return isolated > (inactive + active) / 2;
 }
 
-/* possible outcome of isolate_migratepages */
-typedef enum {
-	ISOLATE_ABORT,		/* Abort compaction now */
-	ISOLATE_NONE,		/* No pages isolated, continue scanning */
-	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
-} isolate_migrate_t;
-
 /**
  * isolate_migratepages_range() - isolate all migrate-able pages in range.
  * @zone:	Zone pages are in.
@@ -304,7 +150,7 @@ typedef enum {
  * does not modify any cc's fields, ie. it does not modify (or read
  * for that matter) cc->migrate_pfn.
  */
-static unsigned long
+unsigned long
 isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			   unsigned long low_pfn, unsigned long end_pfn)
 {
@@ -418,35 +264,135 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	return low_pfn;
 }
 
+#endif /* CONFIG_COMPACTION || CONFIG_CMA */
+#ifdef CONFIG_COMPACTION
+
+static unsigned long release_freepages(struct list_head *freelist)
+{
+	struct page *page, *next;
+	unsigned long count = 0;
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
+/* Returns true if the page is within a block suitable for migration to */
+static bool suitable_migration_target(struct page *page)
+{
+
+	int migratetype = get_pageblock_migratetype(page);
+
+	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
+	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
+		return false;
+
+	/* If the page is a large free page, then allow migration */
+	if (PageBuddy(page) && page_order(page) >= pageblock_order)
+		return true;
+
+	/* If the block is MIGRATE_MOVABLE, allow migration */
+	if (migratetype == MIGRATE_MOVABLE)
+		return true;
+
+	/* Otherwise skip the block */
+	return false;
+}
+
 /*
- * Isolate all pages that can be migrated from the block pointed to by
- * the migrate scanner within compact_control.
+ * Based on information in the current compact_control, find blocks
+ * suitable for isolating free pages from and then isolate them.
  */
-static isolate_migrate_t isolate_migratepages(struct zone *zone,
-					struct compact_control *cc)
+static void isolate_freepages(struct zone *zone,
+				struct compact_control *cc)
 {
-	unsigned long low_pfn, end_pfn;
+	struct page *page;
+	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
+	unsigned long flags;
+	int nr_freepages = cc->nr_freepages;
+	struct list_head *freelist = &cc->freepages;
 
-	/* Do not scan outside zone boundaries */
-	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
+	/*
+	 * Initialise the free scanner. The starting point is where we last
+	 * scanned from (or the end of the zone if starting). The low point
+	 * is the end of the pageblock the migration scanner is using.
+	 */
+	pfn = cc->free_pfn;
+	low_pfn = cc->migrate_pfn + pageblock_nr_pages;
 
-	/* Only scan within a pageblock boundary */
-	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
+	/*
+	 * Take care that if the migration scanner is at the end of the zone
+	 * that the free scanner does not accidentally move to the next zone
+	 * in the next isolation cycle.
+	 */
+	high_pfn = min(low_pfn, pfn);
 
-	/* Do not cross the free scanner or scan within a memory hole */
-	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
-		cc->migrate_pfn = end_pfn;
-		return ISOLATE_NONE;
-	}
+	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 
-	/* Perform the isolation */
-	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
-	if (!low_pfn)
-		return ISOLATE_ABORT;
+	/*
+	 * Isolate free pages until enough are available to migrate the
+	 * pages on cc->migratepages. We stop searching if the migrate
+	 * and free page scanners meet or enough free pages are isolated.
+	 */
+	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
+					pfn -= pageblock_nr_pages) {
+		unsigned long isolated;
 
-	cc->migrate_pfn = low_pfn;
+		if (!pfn_valid(pfn))
+			continue;
 
-	return ISOLATE_SUCCESS;
+		/*
+		 * Check for overlapping nodes/zones. It's possible on some
+		 * configurations to have a setup like
+		 * node0 node1 node0
+		 * i.e. it's possible that all pages within a zones range of
+		 * pages do not belong to a single zone.
+		 */
+		page = pfn_to_page(pfn);
+		if (page_zone(page) != zone)
+			continue;
+
+		/* Check the block is suitable for migration */
+		if (!suitable_migration_target(page))
+			continue;
+
+		/*
+		 * Found a block suitable for isolating free pages from. Now
+		 * we disabled interrupts, double check things are ok and
+		 * isolate the pages. This is to minimise the time IRQs
+		 * are disabled
+		 */
+		isolated = 0;
+		spin_lock_irqsave(&zone->lock, flags);
+		if (suitable_migration_target(page)) {
+			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
+			isolated = isolate_freepages_range(zone, pfn,
+					end_pfn, freelist);
+			nr_freepages += isolated;
+		}
+		spin_unlock_irqrestore(&zone->lock, flags);
+
+		/*
+		 * Record the highest PFN we isolated pages from. When next
+		 * looking for free pages, the search will restart here as
+		 * page migration may have returned some pages to the allocator
+		 */
+		if (isolated)
+			high_pfn = max(high_pfn, pfn);
+	}
+
+	/* split_free_page does not map the pages */
+	list_for_each_entry(page, freelist, lru) {
+		arch_alloc_page(page, 0);
+		kernel_map_pages(page, 1, 1);
+	}
+
+	cc->free_pfn = high_pfn;
+	cc->nr_freepages = nr_freepages;
 }
 
 /*
@@ -495,6 +441,44 @@ static void update_nr_listpages(struct compact_control *cc)
 	cc->nr_freepages = nr_freepages;
 }
 
+/* possible outcome of isolate_migratepages */
+typedef enum {
+	ISOLATE_ABORT,		/* Abort compaction now */
+	ISOLATE_NONE,		/* No pages isolated, continue scanning */
+	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
+} isolate_migrate_t;
+
+/*
+ * Isolate all pages that can be migrated from the block pointed to by
+ * the migrate scanner within compact_control.
+ */
+static isolate_migrate_t isolate_migratepages(struct zone *zone,
+					struct compact_control *cc)
+{
+	unsigned long low_pfn, end_pfn;
+
+	/* Do not scan outside zone boundaries */
+	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
+
+	/* Only scan within a pageblock boundary */
+	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
+
+	/* Do not cross the free scanner or scan within a memory hole */
+	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
+		cc->migrate_pfn = end_pfn;
+		return ISOLATE_NONE;
+	}
+
+	/* Perform the isolation */
+	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
+	if (!low_pfn)
+		return ISOLATE_ABORT;
+
+	cc->migrate_pfn = low_pfn;
+
+	return ISOLATE_SUCCESS;
+}
+
 static int compact_finished(struct zone *zone,
 			    struct compact_control *cc)
 {
@@ -811,3 +795,5 @@ void compaction_unregister_node(struct node *node)
 	return sysdev_remove_file(&node->sysdev, &attr_compact);
 }
 #endif /* CONFIG_SYSFS && CONFIG_NUMA */
+
+#endif /* CONFIG_COMPACTION */
diff --git a/mm/internal.h b/mm/internal.h
index 2189af4..4a226d8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -100,6 +100,41 @@ extern void prep_compound_page(struct page *page, unsigned long order);
 extern bool is_free_buddy_page(struct page *page);
 #endif
 
+#if defined CONFIG_COMPACTION || defined CONFIG_CMA
+
+/*
+ * in mm/compaction.c
+ */
+/*
+ * compact_control is used to track pages being migrated and the free pages
+ * they are being migrated to during memory compaction. The free_pfn starts
+ * at the end of a zone and migrate_pfn begins at the start. Movable pages
+ * are moved to the end of a zone during a compaction run and the run
+ * completes when free_pfn <= migrate_pfn
+ */
+struct compact_control {
+	struct list_head freepages;	/* List of free pages to migrate to */
+	struct list_head migratepages;	/* List of pages being migrated */
+	unsigned long nr_freepages;	/* Number of isolated free pages */
+	unsigned long nr_migratepages;	/* Number of pages to migrate */
+	unsigned long free_pfn;		/* isolate_freepages search base */
+	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	bool sync;			/* Synchronous migration */
+
+	unsigned int order;		/* order a direct compactor needs */
+	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
+	struct zone *zone;
+};
+
+unsigned long
+isolate_freepages_range(struct zone *zone,
+			unsigned long start, unsigned long end,
+			struct list_head *freelist);
+unsigned long
+isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
+			   unsigned long low_pfn, unsigned long end_pfn);
+
+#endif
 
 /*
  * function for dealing with page's order in buddy system.
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
