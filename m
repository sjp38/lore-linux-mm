Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C65A68D003B
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 09:44:19 -0500 (EST)
Received: by mail-iw0-f169.google.com with SMTP id 42so1987742iwl.14
        for <linux-mm@kvack.org>; Sun, 20 Feb 2011 06:44:18 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v6 3/3] Reclaim invalidated page ASAP
Date: Sun, 20 Feb 2011 23:43:38 +0900
Message-Id: <62711cef6888401f34f366af64651dac3795fdf4.1298212517.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1298212517.git.minchan.kim@gmail.com>
References: <cover.1298212517.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1298212517.git.minchan.kim@gmail.com>
References: <cover.1298212517.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

invalidate_mapping_pages is very big hint to reclaimer.
It means user doesn't want to use the page any more.
So in order to prevent working set page eviction, this patch
move the page into tail of inactive list by PG_reclaim.

Please, remember that pages in inactive list are working set
as well as active list. If we don't move pages into inactive list's
tail, pages near by tail of inactive list can be evicted although
we have a big clue about useless pages. It's totally bad.

Now PG_readahead/PG_reclaim is shared.
fe3cba17 added ClearPageReclaim into clear_page_dirty_for_io for
preventing fast reclaiming readahead marker page.

In this series, PG_reclaim is used by invalidated page, too.
If VM find the page is invalidated and it's dirty, it sets PG_reclaim
to reclaim asap. Then, when the dirty page will be writeback,
clear_page_dirty_for_io will clear PG_reclaim unconditionally.
It disturbs this serie's goal.

I think it's okay to clear PG_readahead when the page is dirty, not
writeback time. So this patch moves ClearPageReadahead.
In v4, ClearPageReadahead in set_page_dirty has a problem which is reported
by Steven Barrett. It's due to compound page. Some driver(ex, audio) calls
set_page_dirty with compound page which isn't on LRU. but my patch does
ClearPageRelcaim on compound page. In non-CONFIG_PAGEFLAGS_EXTENDED, it breaks
PageTail flag.

I think it doesn't affect THP and pass my test with THP enabling
but Cced Andrea for double check.

Reported-by: Steven Barrett <damentz@liquorix.net>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/page-writeback.c |   12 +++++++++++-
 mm/swap.c           |   41 ++++++++++++++++++++++++++++++++++++++---
 2 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2cb01f6..b437fe6 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1211,6 +1211,17 @@ int set_page_dirty(struct page *page)
 
 	if (likely(mapping)) {
 		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
+		/*
+		 * readahead/lru_deactivate_page could remain
+		 * PG_readahead/PG_reclaim due to race with end_page_writeback
+		 * About readahead, if the page is written, the flags would be
+		 * reset. So no problem.
+		 * About lru_deactivate_page, if the page is redirty, the flag
+		 * will be reset. So no problem. but if the page is used by readahead
+		 * it will confuse readahead and make it restart the size rampup
+		 * process. But it's a trivial problem.
+		 */
+		ClearPageReclaim(page);
 #ifdef CONFIG_BLOCK
 		if (!spd)
 			spd = __set_page_dirty_buffers;
@@ -1266,7 +1277,6 @@ int clear_page_dirty_for_io(struct page *page)
 
 	BUG_ON(!PageLocked(page));
 
-	ClearPageReclaim(page);
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		/*
 		 * Yes, Virginia, this is indeed insane.
diff --git a/mm/swap.c b/mm/swap.c
index 1b9e4eb..0a33714 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -354,26 +354,61 @@ void add_page_to_unevictable_list(struct page *page)
  * head of the list, rather than the tail, to give the flusher
  * threads some time to write it out, as this is much more
  * effective than the single-page writeout from reclaim.
+ *
+ * If the page isn't page_mapped and dirty/writeback, the page
+ * could reclaim asap using PG_reclaim.
+ *
+ * 1. active, mapped page -> none
+ * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
+ * 3. inactive, mapped page -> none
+ * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
+ * 5. inactive, clean -> inactive, tail
+ * 6. Others -> none
+ *
+ * In 4, why it moves inactive's head, the VM expects the page would
+ * be write it out by flusher threads as this is much more effective
+ * than the single-page writeout from reclaim.
  */
 static void lru_deactivate(struct page *page, struct zone *zone)
 {
 	int lru, file;
+	bool active;
 
-	if (!PageLRU(page) || !PageActive(page))
+	if (!PageLRU(page))
 		return;
 
 	/* Some processes are using the page */
 	if (page_mapped(page))
 		return;
 
+	active = PageActive(page);
+
 	file = page_is_file_cache(page);
 	lru = page_lru_base_type(page);
-	del_page_from_lru_list(zone, page, lru + LRU_ACTIVE);
+	del_page_from_lru_list(zone, page, lru + active);
 	ClearPageActive(page);
 	ClearPageReferenced(page);
 	add_page_to_lru_list(zone, page, lru);
-	__count_vm_event(PGDEACTIVATE);
 
+	if (PageWriteback(page) || PageDirty(page)) {
+		/*
+		 * PG_reclaim could be raced with end_page_writeback
+		 * It can make readahead confusing.  But race window
+		 * is _really_ small and  it's non-critical problem.
+		 */
+		SetPageReclaim(page);
+	} else {
+		/*
+		 * The page's writeback ends up during pagevec
+		 * We moves tha page into tail of inactive.
+		 */
+		list_move_tail(&page->lru, &zone->lru[lru].list);
+		mem_cgroup_rotate_reclaimable_page(page);
+		__count_vm_event(PGROTATED);
+	}
+
+	if (active)
+		__count_vm_event(PGDEACTIVATE);
 	update_page_reclaim_stat(zone, page, file, 0);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
