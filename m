Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 45DD56B01AC
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 20:18:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U0IoY5028771
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 30 Jun 2010 09:18:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 77FB845DE4E
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:18:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E00145DE55
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:18:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 09D68E1800F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:18:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 67E53E1800D
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:18:48 +0900 (JST)
Date: Wed, 30 Jun 2010 09:14:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] fs,xfs: Allow kswapd to writeback pages
Message-Id: <20100630091411.49f92cff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100629125143.GB31561@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
	<1277811288-5195-15-git-send-email-mel@csn.ul.ie>
	<20100629123722.GA725@infradead.org>
	<20100629125143.GB31561@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 2010 13:51:43 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Tue, Jun 29, 2010 at 08:37:22AM -0400, Christoph Hellwig wrote:
> > I don't see a patch in this set which refuses writeback from the memcg
> > context, which we identified as having large stack footprint in hte
> > discussion of the last patch set.
> > 
> 
> It wasn't clear to me what the right approach was there and should
> have noted that in the intro. The last note I have on it is this message
> http://kerneltrap.org/mailarchive/linux-kernel/2010/6/17/4584087 which might
> avoid the deep stack usage but I wasn't 100% sure. As kswapd doesn't clean
> pages for memcg, I left memcg being able to direct writeback to see what
> the memcg people preferred.
> 

Hmm. If some filesystems don't support direct ->writeback, memcg shouldn't
depends on it. If so, memcg should depends on some writeback-thread (as kswapd).
ok.

Then, my concern here is that which kswapd we should wake up and how it can stop.
IOW, how kswapd can know a memcg has some remaining writeback and struck on it.

One idea is here. (this patch will not work...not tested at all.)
If we can have "victim page list" and kswapd can depend on it to know
"which pages should be written", kswapd can know when it should work.

cpu usage by memcg will be a new problem...but...

==
Add a new LRU "CLEANING" and make kswapd launder it.
This patch also changes PG_reclaim behavior. New PG_reclaim works
as
 - If PG_reclaim is set, a page is on CLEAINING LIST.

And when kswapd launder a page
 - issue an writeback. (I'm thinking whehter I should put this
   cleaned page back to CLEANING lru and free it later.) 
 - if it can free directly, free it.
This just use current shrink_list().

Maybe this patch itself inlcludes many bad point...

---
 fs/proc/meminfo.c         |    2 
 include/linux/mm_inline.h |    9 ++
 include/linux/mmzone.h    |    7 ++
 mm/filemap.c              |    3 
 mm/internal.h             |    1 
 mm/page-writeback.c       |    1 
 mm/page_io.c              |    1 
 mm/swap.c                 |   31 ++-------
 mm/vmscan.c               |  153 +++++++++++++++++++++++++++++++++++++++++++++-
 9 files changed, 176 insertions(+), 32 deletions(-)

Index: mmotm-0611/include/linux/mmzone.h
===================================================================
--- mmotm-0611.orig/include/linux/mmzone.h
+++ mmotm-0611/include/linux/mmzone.h
@@ -85,6 +85,7 @@ enum zone_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
+	NR_CLEANING,		/*  "     "     "   "       "         */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
@@ -133,6 +134,7 @@ enum lru_list {
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
 	LRU_UNEVICTABLE,
+	LRU_CLEANING,
 	NR_LRU_LISTS
 };
 
@@ -155,6 +157,11 @@ static inline int is_unevictable_lru(enu
 	return (l == LRU_UNEVICTABLE);
 }
 
+static inline int is_cleaning_lru(enum lru_list l)
+{
+	return (l == LRU_CLEANING);
+}
+
 enum zone_watermarks {
 	WMARK_MIN,
 	WMARK_LOW,
Index: mmotm-0611/include/linux/mm_inline.h
===================================================================
--- mmotm-0611.orig/include/linux/mm_inline.h
+++ mmotm-0611/include/linux/mm_inline.h
@@ -56,7 +56,10 @@ del_page_from_lru(struct zone *zone, str
 	enum lru_list l;
 
 	list_del(&page->lru);
-	if (PageUnevictable(page)) {
+	if (PageReclaim(page)) {
+		ClearPageReclaim(page);
+		l = LRU_CLEANING;
+	} else if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
 		l = LRU_UNEVICTABLE;
 	} else {
@@ -81,7 +84,9 @@ static inline enum lru_list page_lru(str
 {
 	enum lru_list lru;
 
-	if (PageUnevictable(page))
+	if (PageReclaim(page)) {
+		lru = LRU_CLEANING;
+	} else if (PageUnevictable(page))
 		lru = LRU_UNEVICTABLE;
 	else {
 		lru = page_lru_base_type(page);
Index: mmotm-0611/fs/proc/meminfo.c
===================================================================
--- mmotm-0611.orig/fs/proc/meminfo.c
+++ mmotm-0611/fs/proc/meminfo.c
@@ -65,6 +65,7 @@ static int meminfo_proc_show(struct seq_
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
 		"Unevictable:    %8lu kB\n"
+		"Cleaning:       %8lu kB\n"
 		"Mlocked:        %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
@@ -114,6 +115,7 @@ static int meminfo_proc_show(struct seq_
 		K(pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_FILE]),
 		K(pages[LRU_UNEVICTABLE]),
+		K(pages[LRU_CLEANING]),
 		K(global_page_state(NR_MLOCK)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
Index: mmotm-0611/mm/swap.c
===================================================================
--- mmotm-0611.orig/mm/swap.c
+++ mmotm-0611/mm/swap.c
@@ -118,8 +118,8 @@ static void pagevec_move_tail(struct pag
 			zone = pagezone;
 			spin_lock(&zone->lru_lock);
 		}
-		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-			int lru = page_lru_base_type(page);
+		if (PageLRU(page)) {
+			int lru = page_lru(page);
 			list_move_tail(&page->lru, &zone->lru[lru].list);
 			pgmoved++;
 		}
@@ -131,27 +131,6 @@ static void pagevec_move_tail(struct pag
 	pagevec_reinit(pvec);
 }
 
-/*
- * Writeback is about to end against a page which has been marked for immediate
- * reclaim.  If it still appears to be reclaimable, move it to the tail of the
- * inactive list.
- */
-void  rotate_reclaimable_page(struct page *page)
-{
-	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
-	    !PageUnevictable(page) && PageLRU(page)) {
-		struct pagevec *pvec;
-		unsigned long flags;
-
-		page_cache_get(page);
-		local_irq_save(flags);
-		pvec = &__get_cpu_var(lru_rotate_pvecs);
-		if (!pagevec_add(pvec, page))
-			pagevec_move_tail(pvec);
-		local_irq_restore(flags);
-	}
-}
-
 static void update_page_reclaim_stat(struct zone *zone, struct page *page,
 				     int file, int rotated)
 {
@@ -235,10 +214,16 @@ void lru_cache_add_lru(struct page *page
 {
 	if (PageActive(page)) {
 		VM_BUG_ON(PageUnevictable(page));
+		VM_BUG_ON(PageReclaim(page));
 		ClearPageActive(page);
 	} else if (PageUnevictable(page)) {
 		VM_BUG_ON(PageActive(page));
+		VM_BUG_ON(PageReclaim(page));
 		ClearPageUnevictable(page);
+	} else if (PageReclaim(page)) {
+		VM_BUG_ON(PageReclaim(page));
+		VM_BUG_ON(PageUnevictable(page));
+		ClearPageReclaim(page);
 	}
 
 	VM_BUG_ON(PageLRU(page) || PageActive(page) || PageUnevictable(page));
Index: mmotm-0611/mm/filemap.c
===================================================================
--- mmotm-0611.orig/mm/filemap.c
+++ mmotm-0611/mm/filemap.c
@@ -560,9 +560,6 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
-	if (TestClearPageReclaim(page))
-		rotate_reclaimable_page(page);
-
 	if (!test_clear_page_writeback(page))
 		BUG();
 
Index: mmotm-0611/mm/internal.h
===================================================================
--- mmotm-0611.orig/mm/internal.h
+++ mmotm-0611/mm/internal.h
@@ -259,3 +259,4 @@ extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
 extern u64 hwpoison_filter_memcg;
 extern u32 hwpoison_filter_enable;
+
Index: mmotm-0611/mm/page-writeback.c
===================================================================
--- mmotm-0611.orig/mm/page-writeback.c
+++ mmotm-0611/mm/page-writeback.c
@@ -1252,7 +1252,6 @@ int clear_page_dirty_for_io(struct page 
 
 	BUG_ON(!PageLocked(page));
 
-	ClearPageReclaim(page);
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		/*
 		 * Yes, Virginia, this is indeed insane.
Index: mmotm-0611/mm/page_io.c
===================================================================
--- mmotm-0611.orig/mm/page_io.c
+++ mmotm-0611/mm/page_io.c
@@ -60,7 +60,6 @@ static void end_swap_bio_write(struct bi
 				imajor(bio->bi_bdev->bd_inode),
 				iminor(bio->bi_bdev->bd_inode),
 				(unsigned long long)bio->bi_sector);
-		ClearPageReclaim(page);
 	}
 	end_page_writeback(page);
 	bio_put(bio);
Index: mmotm-0611/mm/vmscan.c
===================================================================
--- mmotm-0611.orig/mm/vmscan.c
+++ mmotm-0611/mm/vmscan.c
@@ -364,6 +364,12 @@ static pageout_t pageout(struct page *pa
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
+	if (!current_is_kswapd()) {
+		/* pass this page to kswapd. */
+		SetPageReclaim(page);
+		return PAGE_KEEP;
+	}
+
 	if (clear_page_dirty_for_io(page)) {
 		int res;
 		struct writeback_control wbc = {
@@ -503,6 +509,8 @@ void putback_lru_page(struct page *page)
 
 redo:
 	ClearPageUnevictable(page);
+	/* This function never puts pages to CLEANING queue */
+	ClearPageReclaim(page);
 
 	if (page_evictable(page, NULL)) {
 		/*
@@ -883,6 +891,8 @@ int __isolate_lru_page(struct page *page
 		 * page release code relies on it.
 		 */
 		ClearPageLRU(page);
+		/* when someone isolate this page, clear reclaim status */
+		ClearPageReclaim(page);
 		ret = 0;
 	}
 
@@ -1020,7 +1030,7 @@ static unsigned long isolate_pages_globa
  * # of pages of each types and clearing any active bits.
  */
 static unsigned long count_page_types(struct list_head *page_list,
-				unsigned int *count, int clear_active)
+				unsigned int *count, int clear_actives)
 {
 	int nr_active = 0;
 	int lru;
@@ -1076,6 +1086,7 @@ int isolate_lru_page(struct page *page)
 			int lru = page_lru(page);
 			ret = 0;
 			ClearPageLRU(page);
+			ClearPageReclaim(page);
 
 			del_page_from_lru_list(zone, page, lru);
 		}
@@ -1109,6 +1120,103 @@ static int too_many_isolated(struct zone
 	return isolated > inactive;
 }
 
+/* only called by kswapd to do I/O and put back clean paes to its LRU */
+static void shrink_cleaning_list(struct zone *zone)
+{
+	LIST_HEAD(page_list);
+	struct list_head *src;
+	struct pagevec pvec;
+	unsigned long nr_pageout;
+	unsigned long nr_cleaned;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.may_unmap = 1,
+		.may_swap = 1,
+		.nr_to_reclaim = ULONG_MAX,
+		.swappiness = vm_swappiness,
+		.order = 1,
+		.mem_cgroup = NULL,
+	};
+
+	pagevec_init(&pvec, 1);
+	lru_add_drain();
+
+	src = &zone->lru[LRU_CLEANING].list;
+	nr_pageout = 0;
+	nr_cleaned = 0;
+	spin_lock_irq(&zone->lru_lock);
+	do {
+		unsigned int count[NR_LRU_LISTS] = {0,};
+		unsigned int nr_anon, nr_file, nr_taken, check_clean, nr_freed;
+		unsigned long nr_scan;
+
+		if (list_empty(src))
+			goto done;
+
+		check_clean = max((unsigned long)SWAP_CLUSTER_MAX,
+				zone_page_state(zone, NR_CLEANING)/8);
+		/* we do global-only */
+		nr_taken = isolate_lru_pages(check_clean,
+					src, &page_list, &nr_scan,
+					0, ISOLATE_BOTH, 0);
+		zone->pages_scanned += nr_scan;
+		__count_zone_vm_events(PGSCAN_KSWAPD, zone, nr_scan);
+		if (nr_taken == 0)
+			goto done;
+		__mod_zone_page_state(zone, NR_CLEANING, -nr_taken);
+		spin_unlock_irq(&zone->lru_lock);
+		/*
+		 * Because PG_reclaim flag is deleted by isolate_lru_page(),
+		 * we can count correct value
+		 */
+		count_page_types(&page_list, count, 0);
+		nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
+		nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
+		__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
+		__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
+
+		nr_freed = shrink_page_list(&page_list, &sc, PAGEOUT_IO_ASYNC);
+		/*
+		 * Put back any unfreeable pages.
+		 */
+		while (!list_empty(&page_list)) {
+			int lru;
+			struct page *page;
+
+			page = lru_to_page(&page_list);
+			VM_BUG_ON(PageLRU(page));
+			list_del(&page->lru);
+			if (!unlikely(!page_evictable(page, NULL))) {
+				spin_unlock_irq(&zone->lru_lock);
+				putback_lru_page(page);
+				spin_lock_irq(&zone->lru_lock);
+				continue;
+			}
+			SetPageLRU(page);
+			lru = page_lru(page);
+			add_page_to_lru_list(zone, page, lru);
+			if (!pagevec_add(&pvec, page)) {
+				spin_unlock_irq(&zone->lru_lock);
+				__pagevec_release(&pvec);
+				spin_lock_irq(&zone->lru_lock);
+			}
+		}
+		__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
+		__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
+		nr_pageout += nr_taken - nr_freed;
+		nr_cleaned += nr_freed;
+		if (nr_pageout > SWAP_CLUSTER_MAX) {
+			/* there are remaining I/Os */
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			nr_pageout /= 2;
+		}
+	} while(nr_cleaned < SWAP_CLUSTER_MAX);
+done:
+	spin_unlock_irq(&zone->lru_lock);
+	pagevec_release(&pvec);
+	return;
+}
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -1736,6 +1844,9 @@ static bool shrink_zones(int priority, s
 					sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
+
+		if (current_is_kswapd())
+			shrink_cleaning_list(zone);
 		/*
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
@@ -2222,6 +2333,42 @@ out:
 	return sc.nr_reclaimed;
 }
 
+static void launder_pgdat(pg_data_t *pgdat)
+{
+	struct zone *zone;
+	int i;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+
+		zone = &pgdat->node_zones[i];
+		if (!populated_zone(zone))
+			continue;
+		if (zone_page_state(zone, NR_CLEANING))
+			break;
+		shrink_cleaning_list(zone);
+	}
+}
+
+/*
+ * Find a zone which has cleaning list.
+ */
+static int need_to_cleaning_node(pg_data_t *pgdat)
+{
+	int i;
+	struct zone *zone;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+
+		zone = &pgdat->node_zones[i];
+		if (!populated_zone(zone))
+			continue;
+		if (zone_page_state(zone, NR_CLEANING))
+			break;
+	}
+	return (i != MAX_NR_ZONES);
+}
+
+
 /*
  * The background pageout daemon, started as a kernel thread
  * from the init process.
@@ -2275,7 +2422,9 @@ static int kswapd(void *p)
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 		new_order = pgdat->kswapd_max_order;
 		pgdat->kswapd_max_order = 0;
-		if (order < new_order) {
+		if (need_to_cleaning_node(pgdat)) {
+			launder_pgdat(pgdat);
+		} else if (order < new_order) {
 			/*
 			 * Don't sleep if someone wants a larger 'order'
 			 * allocation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
