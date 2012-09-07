Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B34836B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 05:32:09 -0400 (EDT)
Date: Fri, 7 Sep 2012 10:32:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
Message-ID: <20120907093203.GX11266@suse.de>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
 <1346832673-12512-2-git-send-email-minchan@kernel.org>
 <20120905105611.GI11266@suse.de>
 <20120906053112.GA16231@bbox>
 <20120906082935.GN11266@suse.de>
 <20120906090325.GO11266@suse.de>
 <20120907022434.GG16231@bbox>
 <20120907082145.GV11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120907082145.GV11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Fri, Sep 07, 2012 at 09:21:45AM +0100, Mel Gorman wrote:
> 
> So other than the mix up of order parameters I think this should work.
> 

But I'd be wrong, isolated page accounting is not fixed up so it will
eventually hang on too_many_isolated. It turns out it is necessary
to pass in zone after all. The following patch passed a high order
allocation stress test. To actually exercise the path I had compaction
call reclaim_clean_pages_from_list() in a separate debugging patch.

Minchan, can you test your CMA allocation latency test with this patch?
If the figures are satisfactory could you add them to the changelog and
consider replacing the MIGRATE_DISCARD pair of patches with this version
please?

---8<---
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: cma: Discard clean pages during contiguous allocation
 instead of migration

This patch drops clean cache pages instead of migration during
alloc_contig_range() to minimise allocation latency by reducing the amount
of migration is necessary. It's useful for CMA because latency of migration
is more important than evicting the background processes working set.
In addition, as pages are reclaimed then fewer free pages for migration
targets are required so it avoids memory reclaiming to get free pages,
which is a contributory factor to increased latency.

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/internal.h   |    2 ++
 mm/page_alloc.c |    2 ++
 mm/vmscan.c     |   43 +++++++++++++++++++++++++++++++++++++------
 3 files changed, 41 insertions(+), 6 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index b8c91b3..ec2f304 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -356,3 +356,5 @@ extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
         unsigned long, unsigned long);
 
 extern void set_pageblock_order(void);
+unsigned long reclaim_clean_pages_from_list(struct zone *zone,
+					    struct list_head *page_list);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c66fb87..977bdb2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5670,6 +5670,8 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 			break;
 		}
 
+		reclaim_clean_pages_from_list(&cc.migratepages);
+
 		ret = migrate_pages(&cc.migratepages,
 				    __alloc_contig_migrate_alloc,
 				    0, false, MIGRATE_SYNC);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d01243..795d963 100644
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
+	ret = shrink_page_list(&clean_pages, NULL, &sc,
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
