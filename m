Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D294F6B0068
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 06:46:35 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/9] mm: compaction: Acquire the zone->lock as late as possible
Date: Fri, 21 Sep 2012 11:46:20 +0100
Message-Id: <1348224383-1499-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1348224383-1499-1-git-send-email-mgorman@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Compactions free scanner acquires the zone->lock when checking for PageBuddy
pages and isolating them. It does this even if there are no PageBuddy pages
in the range.

This patch defers acquiring the zone lock for as long as possible. In the
event there are no free pages in the pageblock then the lock will not be
acquired at all which reduces contention on zone->lock.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c |  141 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 78 insertions(+), 63 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a6068ff..8e56594 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -93,6 +93,28 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
 	return compact_checklock_irqsave(lock, flags, false, cc);
 }
 
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
+	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
+	if (migrate_async_suitable(migratetype))
+		return true;
+
+	/* Otherwise skip the block */
+	return false;
+}
+
 static void compact_capture_page(struct compact_control *cc)
 {
 	unsigned long flags;
@@ -153,13 +175,16 @@ static void compact_capture_page(struct compact_control *cc)
  * pages inside of the pageblock (even though it may still end up isolating
  * some pages).
  */
-static unsigned long isolate_freepages_block(unsigned long blockpfn,
+static unsigned long isolate_freepages_block(struct compact_control *cc,
+				unsigned long blockpfn,
 				unsigned long end_pfn,
 				struct list_head *freelist,
 				bool strict)
 {
 	int nr_scanned = 0, total_isolated = 0;
 	struct page *cursor;
+	unsigned long flags;
+	bool locked = false;
 
 	cursor = pfn_to_page(blockpfn);
 
@@ -168,23 +193,38 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
 		int isolated, i;
 		struct page *page = cursor;
 
-		if (!pfn_valid_within(blockpfn)) {
-			if (strict)
-				return 0;
-			continue;
-		}
+		if (!pfn_valid_within(blockpfn))
+			goto strict_check;
 		nr_scanned++;
 
-		if (!PageBuddy(page)) {
-			if (strict)
-				return 0;
-			continue;
-		}
+		if (!PageBuddy(page))
+			goto strict_check;
+
+		/*
+		 * The zone lock must be held to isolate freepages. This
+		 * unfortunately this is a very coarse lock and can be
+		 * heavily contended if there are parallel allocations
+		 * or parallel compactions. For async compaction do not
+		 * spin on the lock and we acquire the lock as late as
+		 * possible.
+		 */
+		locked = compact_checklock_irqsave(&cc->zone->lock, &flags,
+								locked, cc);
+		if (!locked)
+			break;
+
+		/* Recheck this is a suitable migration target under lock */
+		if (!strict && !suitable_migration_target(page))
+			break;
+
+		/* Recheck this is a buddy page under lock */
+		if (!PageBuddy(page))
+			goto strict_check;
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
 		if (!isolated && strict)
-			return 0;
+			goto strict_check;
 		total_isolated += isolated;
 		for (i = 0; i < isolated; i++) {
 			list_add(&page->lru, freelist);
@@ -196,9 +236,23 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
 			blockpfn += isolated - 1;
 			cursor += isolated - 1;
 		}
+
+		continue;
+
+strict_check:
+		/* Abort isolation if the caller requested strict isolation */
+		if (strict) {
+			total_isolated = 0;
+			goto out;
+		}
 	}
 
 	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
+
+out:
+	if (locked)
+		spin_unlock_irqrestore(&cc->zone->lock, flags);
+
 	return total_isolated;
 }
 
@@ -218,13 +272,18 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
 unsigned long
 isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 {
-	unsigned long isolated, pfn, block_end_pfn, flags;
+	unsigned long isolated, pfn, block_end_pfn;
 	struct zone *zone = NULL;
 	LIST_HEAD(freelist);
+	struct compact_control cc;
 
 	if (pfn_valid(start_pfn))
 		zone = page_zone(pfn_to_page(start_pfn));
 
+	/* cc needed for isolate_freepages_block to acquire zone->lock */
+	cc.zone = zone;
+	cc.sync = true;
+
 	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
 		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))
 			break;
@@ -236,10 +295,8 @@ isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		spin_lock_irqsave(&zone->lock, flags);
-		isolated = isolate_freepages_block(pfn, block_end_pfn,
+		isolated = isolate_freepages_block(&cc, pfn, block_end_pfn,
 						   &freelist, true);
-		spin_unlock_irqrestore(&zone->lock, flags);
 
 		/*
 		 * In strict mode, isolate_freepages_block() returns 0 if
@@ -481,29 +538,6 @@ next_pageblock:
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
-
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
-	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
-		return true;
-
-	/* Otherwise skip the block */
-	return false;
-}
-
 /*
  * Returns the start pfn of the last page block in a zone.  This is the starting
  * point for full compaction of a zone.  Compaction searches for free pages from
@@ -527,7 +561,6 @@ static void isolate_freepages(struct zone *zone,
 {
 	struct page *page;
 	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
-	unsigned long flags;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -575,30 +608,12 @@ static void isolate_freepages(struct zone *zone,
 		if (!suitable_migration_target(page))
 			continue;
 
-		/*
-		 * Found a block suitable for isolating free pages from. Now
-		 * we disabled interrupts, double check things are ok and
-		 * isolate the pages. This is to minimise the time IRQs
-		 * are disabled
-		 */
+		/* Found a block suitable for isolating free pages from */
 		isolated = 0;
-
-		/*
-		 * The zone lock must be held to isolate freepages. This
-		 * unfortunately this is a very coarse lock and can be
-		 * heavily contended if there are parallel allocations
-		 * or parallel compactions. For async compaction do not
-		 * spin on the lock
-		 */
-		if (!compact_trylock_irqsave(&zone->lock, &flags, cc))
-			break;
-		if (suitable_migration_target(page)) {
-			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
-			isolated = isolate_freepages_block(pfn, end_pfn,
-							   freelist, false);
-			nr_freepages += isolated;
-		}
-		spin_unlock_irqrestore(&zone->lock, flags);
+		end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
+		isolated = isolate_freepages_block(cc, pfn, end_pfn,
+						   freelist, false);
+		nr_freepages += isolated;
 
 		/*
 		 * Record the highest PFN we isolated pages from. When next
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
