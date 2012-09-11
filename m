Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id BE53C6B0069
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 20:39:59 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: cma: Discard clean pages during contiguous allocation instead of migration
Date: Tue, 11 Sep 2012 09:41:52 +0900
Message-Id: <1347324112-14134-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kmpark@infradead.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

This patch drops clean cache pages instead of migration during
alloc_contig_range() to minimise allocation latency by reducing the amount
of migration is necessary. It's useful for CMA because latency of migration
is more important than evicting the background processes working set.
In addition, as pages are reclaimed then fewer free pages for migration
targets are required so it avoids memory reclaiming to get free pages,
which is a contributory factor to increased latency.

* from v1
  * drop migrate_mode_t
  * add reclaim_clean_pages_from_list instad of MIGRATE_DISCARD support - Mel

I measured elapsed time of __alloc_contig_migrate_range which migrates
10M in 40M movable zone in QEMU machine.

Before - 146ms, After - 7ms

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
Andrew, this patch is based on (mmotm-2012-09-06-16-46 -
drop mm-support-migrate_discard.patch removed from -mm tree +
drop mm-support-migrate_discard.patch removed from -mm tree)

 mm/internal.h   |    3 ++-
 mm/page_alloc.c |    2 ++
 mm/vmscan.c     |   43 +++++++++++++++++++++++++++++++++++++------
 3 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index bbd7b34..8312d4f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -356,5 +356,6 @@ extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long);
 
 extern void set_pageblock_order(void);
-
+unsigned long reclaim_clean_pages_from_list(struct zone *zone,
+					    struct list_head *page_list);
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 941b6ac..48b63d9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5705,6 +5705,8 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 			break;
 		}
 
+		reclaim_clean_pages_from_list(cc.zone, &cc.migratepages);
+
 		ret = migrate_pages(&cc.migratepages,
 				    __alloc_contig_migrate_alloc,
 				    0, false, MIGRATE_SYNC);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d16bf5a..f8f56f8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -674,8 +674,10 @@ static enum page_references page_check_references(struct page *page,
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
+				      enum ttu_flags ttu_flags,
 				      unsigned long *ret_nr_dirty,
-				      unsigned long *ret_nr_writeback)
+				      unsigned long *ret_nr_writeback,
+				      bool force_reclaim)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -689,10 +691,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 	mem_cgroup_uncharge_start();
 	while (!list_empty(page_list)) {
-		enum page_references references;
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
+		enum page_references references = PAGEREF_RECLAIM;
 
 		cond_resched();
 
@@ -758,7 +760,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			wait_on_page_writeback(page);
 		}
 
-		references = page_check_references(page, sc);
+		if (!force_reclaim)
+			references = page_check_references(page, sc);
+
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
@@ -788,7 +792,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, TTU_UNMAP)) {
+			switch (try_to_unmap(page, ttu_flags)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -960,6 +964,33 @@ keep:
 	return nr_reclaimed;
 }
 
+unsigned long reclaim_clean_pages_from_list(struct zone *zone,
+					    struct list_head *page_list)
+{
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.priority = DEF_PRIORITY,
+		.may_unmap = 1,
+	};
+	unsigned long ret, dummy1, dummy2;
+	struct page *page, *next;
+	LIST_HEAD(clean_pages);
+
+	list_for_each_entry_safe(page, next, page_list, lru) {
+		if (page_is_file_cache(page) && !PageDirty(page)) {
+			ClearPageActive(page);
+			list_move(&page->lru, &clean_pages);
+		}
+	}
+
+	ret = shrink_page_list(&clean_pages, zone, &sc,
+				TTU_UNMAP|TTU_IGNORE_ACCESS,
+				&dummy1, &dummy2, true);
+	list_splice(&clean_pages, page_list);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
+	return ret;
+}
+
 /*
  * Attempt to remove the specified page from its LRU.  Only take this page
  * if it is of the appropriate PageActive status.  Pages which are being
@@ -1278,8 +1309,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
-						&nr_dirty, &nr_writeback);
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
+					&nr_dirty, &nr_writeback, false);
 
 	spin_lock_irq(&zone->lru_lock);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
