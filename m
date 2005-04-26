From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17005.64094.860824.34597@gargle.gargle.HOWL>
Date: Tue, 26 Apr 2005 12:22:54 +0400
Subject: Re: [PATCH]: VM 5/8 async-writepage
In-Reply-To: <20050425205706.55fe9833.akpm@osdl.org>
References: <16994.40662.865338.484778@gargle.gargle.HOWL>
	<20050425205706.55fe9833.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:

[...]

 > 
 > I don't understand this at all.  ->writepage() is _already_ asynchronous. 
 > It will only block under rare circumstances such as needing to perform a
 > metadata read or encountering disk queue congestion.

This patch tries to decrease latency of direct reclaim by avoiding

  - occasional stalls you mentioned, and

  - CPU cost of ->writepage().

Plus, deferred pageouts will be easier to cluster.

 > 
 > In a way, kswapd already does what these new threads are supposed to do
 > anyway.  If you were to do your PG_skipped trick with direct-reclaim
 > threads and not with kswapd then you'd get a smiliar effect to this patch,
 > no?

I see them as orthogonal: PG_skipped just declares dirty pages more
valuable, it changes the order of page reclamation, but doesn't change
total number of pageouts (except for a case when PG_skipped page was
redirtied). async-writepage on the other hand, doesn't change order of
reclamation significantly (up to KPGOUT_THROTTLE pages only), and tries
to shift pageout burden from what should be fast-path.

Below is new version, that uses pdflush.

Nikita.

Perform calls to the ->writepage() asynchronously.

VM scanner starts pageout for dirty pages found at tail of the inactive list
during scan. It is supposed (or at least desired) that under normal conditions
amount of such write back is small.

Even if few pages are paged out by scanner, they still stall "direct reclaim"
path (__alloc_pages()->try_to_free_pages()->...->shrink_list()->writepage()),
and to decrease allocation latency it makes sense to perform pageout
asynchronously.

Current design is very simple: asynchronous page-out is done through pdflush
operation kpgout(). If shrink_list() decides that page is eligible for the
asynchronous pageout, it is placed into shared queue and later processed by
one of pdflush threads.

Most interesting part of this patch is async_writepage() that decides when
page should be paged out asynchronously. Currently this function allows
asynchronous writepage only from direct reclaim, only if zone memory pressure
is not too high, and only if expected number of dirty pages in the scanned
chunk is larger than some threshold: if there are only few dirty pages on the
list, context switch to the pdflush outwieghts advantages of asynchronous
writepage.

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 include/linux/page-flags.h |    1 
 mm/page-writeback.c        |   21 +++
 mm/page_alloc.c            |    5 
 mm/vmscan.c                |  238 ++++++++++++++++++++++++++++++++++++++-------
 4 files changed, 226 insertions(+), 39 deletions(-)

diff -puN mm/vmscan.c~async-writepage mm/vmscan.c
--- bk-linux/mm/vmscan.c~async-writepage	2005-04-21 17:57:29.000000000 +0400
+++ bk-linux-nikita/mm/vmscan.c	2005-04-22 12:07:41.000000000 +0400
@@ -47,6 +47,8 @@ typedef enum {
 	PAGE_ACTIVATE,
 	/* page has been sent to the disk successfully, page is unlocked */
 	PAGE_SUCCESS,
+	/* page was queued for asynchronous pageout */
+	PAGE_ASYNC,
 	/* page is clean and locked */
 	PAGE_CLEAN,
 } pageout_t;
@@ -79,9 +81,28 @@ struct scan_control {
 	 * In this context, it doesn't matter that we scan the
 	 * whole list at once. */
 	int swap_cluster_max;
+	/* number of dirty pages in the currently processed chunk of inactive
+	 * list */
+	int nr_dirty;
 };
 
 /*
+ * Asynchronous writepage tunables.
+ */
+enum {
+	KPGOUT_PRIORITY     = DEF_PRIORITY - 4,
+	KPGOUT_THROTTLE     = 128,
+	KPGOUT_CLUSTER_SIZE = 0
+};
+
+static spinlock_t kpgout_queue_lock = SPIN_LOCK_UNLOCKED;
+static unsigned int kpgout_nr_requests = 0;
+static LIST_HEAD(kpgout_queue);
+static unsigned int kpgout_active_threads = 0;
+static void kpgout(unsigned long __unused);
+static void __kpgout(void);
+
+/*
  * The list of shrinker callbacks used by to apply pressure to
  * ageable caches.
  */
@@ -290,9 +311,50 @@ static void handle_write_error(struct ad
 }
 
 /*
+ * check whether writepage should be done asynchronously by pdflush operation
+ * kpgout().
+ */
+static int async_writepage(struct page *page, struct scan_control *sc)
+{
+	/*
+	 * we are called from kpgout(), time to really send page out.
+	 */
+	if (sc == NULL)
+		return 0;
+	/* goal of doing writepage asynchronously is to decrease latency of
+	 * memory allocations involving direct reclaim, which is inapplicable
+	 * to the kswapd */
+	if (current_is_kswapd())
+		return 0;
+	/* limit number of pending async-writepage requests */
+	else if (kpgout_nr_requests > KPGOUT_THROTTLE)
+		return 0;
+	/* if we are under memory pressure---do pageout synchronously to
+	 * throttle scanner. */
+	else if (page_zone(page)->prev_priority < KPGOUT_PRIORITY)
+		return 0;
+	/* if expected number of writepage requests submitted by this
+	 * invocation of shrink_list() is large enough---do them
+	 * asynchronously */
+	else if (sc->nr_dirty > KPGOUT_CLUSTER_SIZE)
+		return 1;
+	else
+		return 0;
+}
+
+static void send_page_to_kpgout(struct page *page)
+{
+	spin_lock(&kpgout_queue_lock);
+	list_add_tail(&page->lru, &kpgout_queue);
+	kpgout_nr_requests ++;
+	spin_unlock(&kpgout_queue_lock);
+}
+
+/*
  * Called by shrink_list() for each dirty page. Calls ->writepage().
  */
-static pageout_t pageout(struct page *page, struct address_space *mapping)
+static pageout_t pageout(struct page *page, struct address_space *mapping,
+			 struct scan_control *sc)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write will be
@@ -345,6 +407,8 @@ static pageout_t pageout(struct page *pa
 	 */
 	if (!TestSetPageSkipped(page))
 		return PAGE_KEEP;
+	if (async_writepage(page, sc))
+		return PAGE_ASYNC;
 	if (clear_page_dirty_for_io(page)) {
 		int res;
 
@@ -396,6 +460,7 @@ static int shrink_list(struct list_head 
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
+	int pgaio = 0;
 	int reclaimed = 0;
 
 	cond_resched();
@@ -469,11 +534,16 @@ static int shrink_list(struct list_head 
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
-			switch(pageout(page, mapping)) {
+			switch(pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
 				goto keep_locked;
 			case PAGE_ACTIVATE:
 				goto activate_locked;
+			case PAGE_ASYNC:
+				pgaio ++;
+				unlock_page(page);
+				send_page_to_kpgout(page);
+				continue;
 			case PAGE_SUCCESS:
 				if (PageWriteback(page) || PageDirty(page))
 					goto keep;
@@ -565,6 +635,22 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		BUG_ON(PageLRU(page));
 	}
+	if (pgaio > 0) {
+		if (pdflush_operation(kpgout, 0) == 0) {
+			add_page_state(nr_async_writeback, pgaio);
+		} else {
+			spin_lock(&kpgout_queue_lock);
+			/*
+			 * if at least one kpgout instance is active, it will
+			 * process our requests, otherwise (all pdflush
+			 * instances are busy, and none of them is kpgout), do
+			 * pageout synchronously.
+			 */
+			if (kpgout_active_threads == 0)
+				__kpgout();
+			spin_unlock(&kpgout_queue_lock);
+		}
+	}
 	list_splice(&ret_pages, page_list);
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
@@ -587,11 +673,12 @@ keep:
  * @src:	The LRU list to pull pages off.
  * @dst:	The temp list to put pages on to.
  * @scanned:	The number of pages that were scanned.
+ * @dirty:	The number of dirty pages found during scan.
  *
  * returns how many pages were moved onto *@dst.
  */
 static int isolate_lru_pages(int nr_to_scan, struct list_head *src,
-			     struct list_head *dst, int *scanned)
+			     struct list_head *dst, int *scanned, int *dirty)
 {
 	int nr_taken = 0;
 	struct page *page;
@@ -615,6 +702,8 @@ static int isolate_lru_pages(int nr_to_s
 		} else {
 			list_add(&page->lru, dst);
 			nr_taken++;
+			if (PageDirty(page))
+				++*dirty;
 		}
 	}
 
@@ -623,33 +712,71 @@ static int isolate_lru_pages(int nr_to_s
 }
 
 /*
+ * Move pages from @list to active or inactive list according to PageActive(),
+ * and release one reference on each processed page.
+ */
+static void distribute_lru_pages(struct list_head *list)
+{
+	struct pagevec pvec;
+	struct page *page;
+	struct zone *zone = NULL;
+
+	pagevec_init(&pvec, 1);
+
+	while (!list_empty(list)) {
+		page = lru_to_page(list);
+		if (page_zone(page) != zone) {
+			if (zone != NULL)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = page_zone(page);
+			spin_lock_irq(&zone->lru_lock);
+		}
+		if (TestSetPageLRU(page))
+			BUG();
+		list_del(&page->lru);
+		if (PageActive(page)) {
+			if (PageSkipped(page))
+				ClearPageSkipped(page);
+			add_page_to_active_list(zone, page);
+		} else {
+			add_page_to_inactive_list(zone, page);
+		}
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	if (zone != NULL)
+		spin_unlock_irq(&zone->lru_lock);
+	pagevec_release(&pvec);
+}
+
+/*
  * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
  */
 static void shrink_cache(struct zone *zone, struct scan_control *sc)
 {
 	LIST_HEAD(page_list);
-	struct pagevec pvec;
 	int max_scan = sc->nr_to_scan;
 
-	pagevec_init(&pvec, 1);
-
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	while (max_scan > 0) {
-		struct page *page;
 		int nr_taken;
 		int nr_scan;
 		int nr_freed;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
 					     &zone->inactive_list,
-					     &page_list, &nr_scan);
+					     &page_list, &nr_scan,
+					     &sc->nr_dirty);
 		zone->nr_inactive -= nr_taken;
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
 		if (nr_taken == 0)
-			goto done;
+			return;
 
 		max_scan -= nr_scan;
 		if (current_is_kswapd())
@@ -662,32 +789,13 @@ static void shrink_cache(struct zone *zo
 		mod_page_state_zone(zone, pgsteal, nr_freed);
 		sc->nr_to_reclaim -= nr_freed;
 
-		spin_lock_irq(&zone->lru_lock);
 		/*
 		 * Put back any unfreeable pages.
 		 */
-		while (!list_empty(&page_list)) {
-			page = lru_to_page(&page_list);
-			if (TestSetPageLRU(page))
-				BUG();
-			list_del(&page->lru);
-			if (PageActive(page)) {
-				if (PageSkipped(page))
-					ClearPageSkipped(page);
-				add_page_to_active_list(zone, page);
-			} else {
-				add_page_to_inactive_list(zone, page);
-			}
-			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&zone->lru_lock);
-				__pagevec_release(&pvec);
-				spin_lock_irq(&zone->lru_lock);
-			}
-		}
+		distribute_lru_pages(&page_list);
+		spin_lock_irq(&zone->lru_lock);
   	}
 	spin_unlock_irq(&zone->lru_lock);
-done:
-	pagevec_release(&pvec);
 }
 
 /*
@@ -727,7 +835,7 @@ refill_inactive_zone(struct zone *zone, 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-				    &l_hold, &pgscanned);
+				    &l_hold, &pgscanned, &sc->nr_dirty);
 	zone->pages_scanned += pgscanned;
 	zone->nr_active -= pgmoved;
 	spin_unlock_irq(&zone->lru_lock);
@@ -997,8 +1105,12 @@ int try_to_free_pages(struct zone **zone
 		}
 
 		/* Take a nap, wait for some writeback to complete */
-		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
-			blk_congestion_wait(WRITE, HZ/10);
+		if (priority < DEF_PRIORITY - 2) {
+			if (sc.nr_scanned)
+				blk_congestion_wait(WRITE, HZ/10);
+			while (read_page_state(nr_async_writeback) > 0)
+				blk_congestion_wait(WRITE, HZ/10);
+		}
 	}
 out:
 	for (i = 0; zones[i] != 0; i++) {
@@ -1184,6 +1296,66 @@ out:
 	return total_reclaimed;
 }
 
+static void __kpgout(void)
+{
+	LIST_HEAD(todo);
+	LIST_HEAD(done);
+	struct page *page;
+	int nr_pages;
+
+	list_splice_init(&kpgout_queue, &todo);
+	nr_pages = kpgout_nr_requests;
+	kpgout_nr_requests = 0;
+	spin_unlock(&kpgout_queue_lock);
+
+	while (!list_empty(&todo)) {
+		pageout_t outcome;
+
+		page = lru_to_page(&todo);
+		list_del(&page->lru);
+
+		if (TestSetPageLocked(page))
+			outcome = PAGE_SUCCESS;
+		else if (PageWriteback(page))
+			outcome = PAGE_KEEP;
+		else if (PageDirty(page))
+			outcome = pageout(page,
+					  page_mapping(page), NULL);
+		else
+			outcome = PAGE_KEEP;
+
+		switch (outcome) {
+		case PAGE_ASYNC:
+			BUG();
+		case PAGE_ACTIVATE:
+			SetPageActive(page);
+		case PAGE_KEEP:
+		case PAGE_CLEAN:
+			unlock_page(page);
+		case PAGE_SUCCESS:
+			list_add(&page->lru, &done);
+			BUG_ON(PageLRU(page));
+		}
+	}
+	distribute_lru_pages(&done);
+	sub_page_state(nr_async_writeback, nr_pages);
+	spin_lock(&kpgout_queue_lock);
+}
+
+static void kpgout(unsigned long __unused)
+{
+	current->flags |= PF_MEMALLOC|PF_KSWAPD;
+
+	spin_lock(&kpgout_queue_lock);
+	++ kpgout_active_threads;
+
+	while (kpgout_nr_requests > 0)
+		__kpgout();
+
+	-- kpgout_active_threads;
+	spin_unlock(&kpgout_queue_lock);
+}
+
 /*
  * The background pageout daemon, started as a kernel thread
  * from the init process.
diff -puN include/linux/sched.h~async-writepage include/linux/sched.h
diff -puN include/linux/page-flags.h~async-writepage include/linux/page-flags.h
--- bk-linux/include/linux/page-flags.h~async-writepage	2005-04-21 17:57:29.000000000 +0400
+++ bk-linux-nikita/include/linux/page-flags.h	2005-04-21 17:57:29.000000000 +0400
@@ -86,6 +86,7 @@ struct page_state {
 	unsigned long nr_dirty;		/* Dirty writeable pages */
 	unsigned long nr_writeback;	/* Pages under writeback */
 	unsigned long nr_unstable;	/* NFS unstable pages */
+	unsigned long nr_async_writeback; /* Pages set for async writeback */
 	unsigned long nr_page_table_pages;/* Pages used for pagetables */
 	unsigned long nr_mapped;	/* mapped into pagetables */
 	unsigned long nr_slab;		/* In slab */
diff -puN mm/page_alloc.c~async-writepage mm/page_alloc.c
--- bk-linux/mm/page_alloc.c~async-writepage	2005-04-21 17:57:29.000000000 +0400
+++ bk-linux-nikita/mm/page_alloc.c	2005-04-22 11:40:36.000000000 +0400
@@ -1250,12 +1250,14 @@ void show_free_areas(void)
 		K(nr_free_pages()),
 		K(nr_free_highpages()));
 
-	printk("Active:%lu inactive:%lu dirty:%lu writeback:%lu "
+	printk("Active:%lu inactive:%lu dirty:%lu "
+		"writeback:%lu async-writeback:%lu "
 		"unstable:%lu free:%u slab:%lu mapped:%lu pagetables:%lu\n",
 		active,
 		inactive,
 		ps.nr_dirty,
 		ps.nr_writeback,
+		ps.nr_async_writeback,
 		ps.nr_unstable,
 		nr_free_pages(),
 		ps.nr_slab,
@@ -1946,6 +1948,7 @@ static char *vmstat_text[] = {
 	"nr_dirty",
 	"nr_writeback",
 	"nr_unstable",
+	"nr_async_writeback",
 	"nr_page_table_pages",
 	"nr_mapped",
 	"nr_slab",
diff -puN mm/page-writeback.c~async-writepage mm/page-writeback.c
--- bk-linux/mm/page-writeback.c~async-writepage	2005-04-21 17:57:29.000000000 +0400
+++ bk-linux-nikita/mm/page-writeback.c	2005-04-21 17:57:29.000000000 +0400
@@ -105,6 +105,7 @@ struct writeback_state
 	unsigned long nr_unstable;
 	unsigned long nr_mapped;
 	unsigned long nr_writeback;
+	unsigned long nr_async_writeback;
 };
 
 static void get_writeback_state(struct writeback_state *wbs)
@@ -113,6 +114,7 @@ static void get_writeback_state(struct w
 	wbs->nr_unstable = read_page_state(nr_unstable);
 	wbs->nr_mapped = read_page_state(nr_mapped);
 	wbs->nr_writeback = read_page_state(nr_writeback);
+	wbs->nr_async_writeback = read_page_state(nr_async_writeback);
 }
 
 /*
@@ -181,6 +183,14 @@ get_dirty_limits(struct writeback_state 
 }
 
 /*
+ * pages that count as dirty, but will be clean some time in the future.
+ */
+static inline unsigned long nr_transient_pages(struct writeback_state *wbs)
+{
+	return wbs->nr_writeback + wbs->nr_async_writeback;
+}
+
+/*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
@@ -209,7 +219,7 @@ static void balance_dirty_pages(struct a
 		get_dirty_limits(&wbs, &background_thresh,
 					&dirty_thresh, mapping);
 		nr_reclaimable = wbs.nr_dirty + wbs.nr_unstable;
-		if (nr_reclaimable + wbs.nr_writeback <= dirty_thresh)
+		if (nr_reclaimable + nr_transient_pages(&wbs) <= dirty_thresh)
 			break;
 
 		dirty_exceeded = 1;
@@ -225,7 +235,8 @@ static void balance_dirty_pages(struct a
 			get_dirty_limits(&wbs, &background_thresh,
 					&dirty_thresh, mapping);
 			nr_reclaimable = wbs.nr_dirty + wbs.nr_unstable;
-			if (nr_reclaimable + wbs.nr_writeback <= dirty_thresh)
+			if (nr_reclaimable +
+			    nr_transient_pages(&wbs) <= dirty_thresh)
 				break;
 			pages_written += write_chunk - wbc.nr_to_write;
 			if (pages_written >= write_chunk)
@@ -234,7 +245,7 @@ static void balance_dirty_pages(struct a
 		blk_congestion_wait(WRITE, HZ/10);
 	}
 
-	if (nr_reclaimable + wbs.nr_writeback <= dirty_thresh)
+	if (nr_reclaimable + nr_transient_pages(&wbs) <= dirty_thresh)
 		dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
@@ -304,7 +315,7 @@ void throttle_vm_writeout(void)
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
-                if (wbs.nr_unstable + wbs.nr_writeback <= dirty_thresh)
+                if (wbs.nr_unstable + nr_transient_pages(&wbs) <= dirty_thresh)
                         break;
                 blk_congestion_wait(WRITE, HZ/10);
         }
@@ -698,7 +709,7 @@ int set_page_dirty_lock(struct page *pag
 EXPORT_SYMBOL(set_page_dirty_lock);
 
 /*
- * Clear a page's dirty flag, while caring for dirty memory accounting. 
+ * Clear a page's dirty flag, while caring for dirty memory accounting.
  * Returns true if the page was previously dirty.
  */
 int test_clear_page_dirty(struct page *page)

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
