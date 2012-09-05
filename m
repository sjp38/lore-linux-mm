Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 192636B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 03:25:46 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC] memory-hotplug: remove MIGRATE_ISOLATE from free_area->free_list
Date: Wed,  5 Sep 2012 16:27:13 +0900
Message-Id: <1346830033-32069-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Normally, MIGRATE_ISOLATE type is used for memory-hotplug.
But it's irony type because the pages isolated would exist
as free page in free_area->free_list[MIGRATE_ISOLATE] so people
can think of it as allocatable pages but it is *never* allocatable.
It ends up confusing NR_FREE_PAGES vmstat so it would be
totally not accurate so some of place which depend on such vmstat
could reach wrong decision by the context.

There were already report about it.[1]
[1] 702d1a6e, memory-hotplug: fix kswapd looping forever problem

Then, there was other report which is other problem.[2]
[2] http://www.spinics.net/lists/linux-mm/msg41251.html

I believe it can make problems in future, too.
So I hope removing such irony type by another design.

I hope this patch solves it and let's revert [1] and doesn't need [2].

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---

It's very early version which show the concept and just tested it with simple
test and works. This patch is needed indepth review from memory-hotplug
guys from fujitsu because I saw there are lots of patches recenlty they sent to
about memory-hotplug change. Please take a look at this patch.

 drivers/xen/balloon.c          |    3 +-
 include/linux/mmzone.h         |    2 +-
 include/linux/page-isolation.h |   11 ++-
 mm/internal.h                  |    4 +
 mm/memory_hotplug.c            |   38 +++++----
 mm/page_alloc.c                |   35 ++++----
 mm/page_isolation.c            |  184 +++++++++++++++++++++++++++++++++++-----
 7 files changed, 218 insertions(+), 59 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 31ab82f..617d7a3 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -50,6 +50,7 @@
 #include <linux/notifier.h>
 #include <linux/memory.h>
 #include <linux/memory_hotplug.h>
+#include <linux/page-isolation.h>
 
 #include <asm/page.h>
 #include <asm/pgalloc.h>
@@ -66,7 +67,6 @@
 #include <xen/balloon.h>
 #include <xen/features.h>
 #include <xen/page.h>
-
 /*
  * balloon_process() state:
  *
@@ -268,6 +268,7 @@ static void xen_online_page(struct page *page)
 	else
 		--balloon_stats.balloon_hotplug;
 
+	delete_from_isolated_list(page);
 	mutex_unlock(&balloon_mutex);
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2daa54f..977dceb 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -57,7 +57,7 @@ enum {
 	 */
 	MIGRATE_CMA,
 #endif
-	MIGRATE_ISOLATE,	/* can't allocate from here */
+	MIGRATE_ISOLATE,
 	MIGRATE_TYPES
 };
 
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 105077a..a26eb8a 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -1,11 +1,16 @@
 #ifndef __LINUX_PAGEISOLATION_H
 #define __LINUX_PAGEISOLATION_H
 
+extern struct list_head isolated_pages;
 
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count);
 void set_pageblock_migratetype(struct page *page, int migratetype);
 int move_freepages_block(struct zone *zone, struct page *page,
 				int migratetype);
+
+void isolate_free_page(struct page *page, unsigned int order);
+void delete_from_isolated_list(struct page *page);
+
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
  * If specified range includes migrate types other than MOVABLE or CMA,
@@ -20,9 +25,13 @@ start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			 unsigned migratetype);
 
 /*
- * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
+ * Changes MIGRATE_ISOLATE to @migratetype.
  * target range is [start_pfn, end_pfn)
  */
+void
+undo_isolate_pageblock(unsigned long start_pfn, unsigned long end_pfn,
+			unsigned migratetype);
+
 int
 undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			unsigned migratetype);
diff --git a/mm/internal.h b/mm/internal.h
index 3314f79..4551179 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -96,6 +96,7 @@ extern void putback_lru_page(struct page *page);
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
+extern int destroy_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
 #endif
@@ -144,6 +145,9 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
  * function for dealing with page's order in buddy system.
  * zone->lock is already acquired when we use these.
  * So, we don't need atomic page->flags operations here.
+ *
+ * Page order should be put on page->private because
+ * memory-hotplug depends on it. Look mm/page_isolate.c.
  */
 static inline unsigned long page_order(struct page *page)
 {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3ad25f9..e297370 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -410,26 +410,29 @@ void __online_page_set_limits(struct page *page)
 	unsigned long pfn = page_to_pfn(page);
 
 	if (pfn >= num_physpages)
-		num_physpages = pfn + 1;
+		num_physpages = pfn + (1 << page_order(page));
 }
 EXPORT_SYMBOL_GPL(__online_page_set_limits);
 
 void __online_page_increment_counters(struct page *page)
 {
-	totalram_pages++;
+	totalram_pages += (1 << page_order(page));
 
 #ifdef CONFIG_HIGHMEM
 	if (PageHighMem(page))
-		totalhigh_pages++;
+		totalhigh_pages += (1 << page_order(page));
 #endif
 }
 EXPORT_SYMBOL_GPL(__online_page_increment_counters);
 
 void __online_page_free(struct page *page)
 {
-	ClearPageReserved(page);
-	init_page_count(page);
-	__free_page(page);
+	int i;
+	unsigned long order = page_order(page);
+	for (i = 0; i < (1 << order); i++)
+		ClearPageReserved(page + i);
+	set_page_private(page, 0);
+	__free_pages(page, order);
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
 
@@ -437,26 +440,29 @@ static void generic_online_page(struct page *page)
 {
 	__online_page_set_limits(page);
 	__online_page_increment_counters(page);
+	delete_from_isolated_list(page);
 	__online_page_free(page);
 }
 
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
 {
-	unsigned long i;
+	unsigned long pfn;
+	unsigned long end_pfn = start_pfn + nr_pages;
 	unsigned long onlined_pages = *(unsigned long *)arg;
-	struct page *page;
-	if (PageReserved(pfn_to_page(start_pfn)))
-		for (i = 0; i < nr_pages; i++) {
-			page = pfn_to_page(start_pfn + i);
-			(*online_page_callback)(page);
-			onlined_pages++;
+	struct page *cursor, *tmp;
+	list_for_each_entry_safe(cursor, tmp, &isolated_pages, lru) {
+		pfn = page_to_pfn(cursor);
+		if (pfn >= start_pfn && pfn < end_pfn) {
+			(*online_page_callback)(cursor);
+			onlined_pages += (1 << page_order(cursor));
 		}
+	}
+
 	*(unsigned long *)arg = onlined_pages;
 	return 0;
 }
 
-
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 {
 	unsigned long onlined_pages = 0;
@@ -954,11 +960,11 @@ repeat:
 		goto failed_removal;
 	}
 	printk(KERN_INFO "Offlined Pages %ld\n", offlined_pages);
-	/* Ok, all of our target is islaoted.
+	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	undo_isolate_pageblock(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
 	zone->present_pages -= offlined_pages;
 	zone->zone_pgdat->node_present_pages -= offlined_pages;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ba3100a..24c1adb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -362,7 +362,7 @@ void prep_compound_page(struct page *page, unsigned long order)
 }
 
 /* update __split_huge_page_refcount if you change this function */
-static int destroy_compound_page(struct page *page, unsigned long order)
+int destroy_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;
@@ -721,6 +721,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
 	int wasMlocked = __TestClearPageMlocked(page);
+	int migratetype;
 
 	if (!free_pages_prepare(page, order))
 		return;
@@ -729,8 +730,14 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	if (unlikely(wasMlocked))
 		free_page_mlock(page);
 	__count_vm_events(PGFREE, 1 << order);
-	free_one_page(page_zone(page), page, order,
-					get_pageblock_migratetype(page));
+
+	migratetype = get_pageblock_migratetype(page);
+	if (likely(migratetype != MIGRATE_ISOLATE))
+		free_one_page(page_zone(page), page, order,
+				migratetype);
+	else
+		isolate_free_page(page, order);
+
 	local_irq_restore(flags);
 }
 
@@ -906,7 +913,6 @@ static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
 #endif
 	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
-	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
 };
 
 /*
@@ -948,8 +954,13 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+		if (migratetype != MIGRATE_ISOLATE) {
+			list_move(&page->lru,
+				&zone->free_area[order].free_list[migratetype]);
+		} else {
+			list_del(&page->lru);
+			isolate_free_page(page, order);
+		}
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -1316,7 +1327,7 @@ void free_hot_cold_page(struct page *page, int cold)
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
 		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
-			free_one_page(zone, page, 0, migratetype);
+			isolate_free_page(page, 0);
 			goto out;
 		}
 		migratetype = MIGRATE_MOVABLE;
@@ -5908,7 +5919,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	struct zone *zone;
 	int order, i;
 	unsigned long pfn;
-	unsigned long flags;
 	/* find the first valid pfn */
 	for (pfn = start_pfn; pfn < end_pfn; pfn++)
 		if (pfn_valid(pfn))
@@ -5916,7 +5926,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	if (pfn == end_pfn)
 		return;
 	zone = page_zone(pfn_to_page(pfn));
-	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
 	while (pfn < end_pfn) {
 		if (!pfn_valid(pfn)) {
@@ -5924,23 +5933,15 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
-		BUG_ON(page_count(page));
-		BUG_ON(!PageBuddy(page));
 		order = page_order(page);
 #ifdef CONFIG_DEBUG_VM
 		printk(KERN_INFO "remove from free list %lx %d %lx\n",
 		       pfn, 1 << order, end_pfn);
 #endif
-		list_del(&page->lru);
-		rmv_page_order(page);
-		zone->free_area[order].nr_free--;
-		__mod_zone_page_state(zone, NR_FREE_PAGES,
-				      - (1UL << order));
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
 	}
-	spin_unlock_irqrestore(&zone->lock, flags);
 }
 #endif
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 247d1f1..918bb5b 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -8,6 +8,136 @@
 #include <linux/memory.h>
 #include "internal.h"
 
+LIST_HEAD(isolated_pages);
+static DEFINE_SPINLOCK(lock);
+
+/*
+ * Add the page into isolated_pages which is sort of pfn ascending list.
+ */
+void __add_isolated_page(struct page *page)
+{
+	struct page *cursor;
+	unsigned long pfn;
+	unsigned long new_pfn = page_to_pfn(page);
+
+	list_for_each_entry_reverse(cursor, &isolated_pages, lru) {
+		pfn = page_to_pfn(cursor);
+		if (pfn < new_pfn)
+			break;
+	}
+
+	list_add(&page->lru, &cursor->lru);
+}
+
+/*
+ * Isolate free page. It is used by memory-hotplug for stealing
+ * free page from free_area or freeing path of allocator.
+ */
+void isolate_free_page(struct page *page, unsigned int order)
+{
+	unsigned long flags;
+
+	/*
+	 * We increase refcount for further freeing when online_pages
+	 * happens and record order into @page->private so that
+	 * online_pages can know what order page freeing.
+	 */
+	set_page_refcounted(page);
+	set_page_private(page, order);
+
+	/* move_freepages is alredy hold zone->lock */
+	if (PageBuddy(page))
+		__ClearPageBuddy(page);
+
+	spin_lock_irqsave(&lock, flags);
+	__add_isolated_page(page);
+	spin_unlock_irqrestore(&lock, flags);
+}
+
+void delete_from_isolated_list(struct page *page)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&lock, flags);
+	list_del(&page->lru);
+	spin_unlock_irqrestore(&lock, flags);
+}
+
+/* free pages in the pageblock which include @page */
+static void free_isolated_pageblock(struct page *page)
+{
+	struct page *cursor;
+	unsigned long start_pfn, end_pfn, pfn;
+	unsigned long flags;
+	bool found = false;
+
+	start_pfn = page_to_pfn(page);
+	start_pfn = start_pfn & ~(pageblock_nr_pages-1);
+	end_pfn = start_pfn + pageblock_nr_pages;
+again:
+	spin_lock_irqsave(&lock, flags);
+
+	list_for_each_entry(cursor, &isolated_pages, lru) {
+		pfn = page_to_pfn(cursor);
+		if (pfn >= start_pfn && pfn < end_pfn) {
+			found = true;
+			break;
+		}
+
+		if (pfn >= end_pfn)
+			break;
+	}
+	if (found)
+		list_del(&cursor->lru);
+
+	spin_unlock_irqrestore(&lock, flags);
+
+	if (found) {
+		int order = page_order(cursor);
+		__free_pages(cursor, order);
+		found = false;
+		goto again;
+	}
+}
+
+/*
+ * Check that *all* [start_pfn...end_pfn) pages are isolated.
+ */
+static bool is_isolate_pfn_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	struct page *start_page, *page;
+	unsigned long pfn;
+	unsigned long prev_pfn;
+	unsigned int prev_order;
+	bool found = false;
+
+	list_for_each_entry(start_page, &isolated_pages, lru) {
+		pfn = page_to_pfn(start_page);
+		if (pfn >= start_pfn && pfn < end_pfn) {
+			found = true;
+			break;
+		}
+	}
+
+	if (!found)
+		return false;
+
+	prev_pfn = page_to_pfn(start_page);
+	prev_order = page_order(start_page);
+
+	list_for_each_entry(page, &start_page->lru, lru) {
+		pfn = page_to_pfn(page);
+		if (pfn >= end_pfn)
+			break;
+		if (pfn != (prev_pfn + (1 << prev_order)))
+			return false;
+		prev_pfn = pfn;
+		prev_order = page_order(page);
+	}
+
+	return true;
+}
+
 /* called while holding zone->lock */
 static void set_pageblock_isolate(struct page *page)
 {
@@ -91,13 +221,15 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	struct zone *zone;
 	unsigned long flags;
 	zone = page_zone(page);
+
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
-	move_freepages_block(zone, page, migratetype);
+
 	restore_pageblock_isolate(page, migratetype);
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
+	free_isolated_pageblock(page);
 }
 
 static inline struct page *
@@ -155,6 +287,30 @@ undo:
 	return -EBUSY;
 }
 
+void undo_isolate_pageblock(unsigned long start_pfn, unsigned long end_pfn,
+		unsigned migratetype)
+{
+	unsigned long pfn;
+	struct page *page;
+	struct zone *zone;
+	unsigned long flags;
+
+	BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
+	BUG_ON((end_pfn) & (pageblock_nr_pages - 1));
+
+	for (pfn = start_pfn;
+			pfn < end_pfn;
+			pfn += pageblock_nr_pages) {
+		page = __first_valid_page(pfn, pageblock_nr_pages);
+		if (!page || get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+			continue;
+		zone = page_zone(page);
+		spin_lock_irqsave(&zone->lock, flags);
+		restore_pageblock_isolate(page, migratetype);
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+}
+
 /*
  * Make isolated pages available again.
  */
@@ -180,30 +336,12 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  * all pages in [start_pfn...end_pfn) must be in the same zone.
  * zone->lock must be held before call this.
  *
- * Returns 1 if all pages in the range are isolated.
+ * Returns true if all pages in the range are isolated.
  */
-static int
+static bool
 __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
 {
-	struct page *page;
-
-	while (pfn < end_pfn) {
-		if (!pfn_valid_within(pfn)) {
-			pfn++;
-			continue;
-		}
-		page = pfn_to_page(pfn);
-		if (PageBuddy(page))
-			pfn += 1 << page_order(page);
-		else if (page_count(page) == 0 &&
-				page_private(page) == MIGRATE_ISOLATE)
-			pfn += 1;
-		else
-			break;
-	}
-	if (pfn < end_pfn)
-		return 0;
-	return 1;
+	return is_isolate_pfn_range(pfn, end_pfn);
 }
 
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
@@ -211,7 +349,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned long pfn, flags;
 	struct page *page;
 	struct zone *zone;
-	int ret;
+	bool ret;
 
 	/*
 	 * Note: pageblock_nr_page != MAX_ORDER. Then, chunks of free page
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
