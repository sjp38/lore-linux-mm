Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l7V7otdr022426
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 31 Aug 2007 16:50:55 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 209FD2AC046
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:50:55 +0900 (JST)
Received: from s9.gw.fujitsu.co.jp (s9.gw.fujitsu.co.jp [10.0.50.99])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D98F012C10A
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:50:54 +0900 (JST)
Received: from s9.gw.fujitsu.co.jp (s9 [127.0.0.1])
	by s9.gw.fujitsu.co.jp (Postfix) with ESMTP id BAB8D1818028
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:50:54 +0900 (JST)
Received: from fjm506.ms.jp.fujitsu.com (fjm506.ms.jp.fujitsu.com [10.56.99.86])
	by s9.gw.fujitsu.co.jp (Postfix) with ESMTP id 2239E1818027
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:50:54 +0900 (JST)
Received: from fjmscan501.ms.jp.fujitsu.com (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm506.ms.jp.fujitsu.com with ESMTP id l7V7o5sR023981
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 16:50:05 +0900
Date: Fri, 31 Aug 2007 16:52:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] patch for mulitiple lru in a zone [2/2] separate lru form
 zone (just for hearing advice/opinion)
Message-Id: <20070831165225.3f12d7a4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070831164611.2c29de69.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070831164611.2c29de69.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Remove zone's LRU list from zone and add page_group struct.
A base patch for prural LRU in a zone.

 - page_group struct is added for support LRU list of pages.
 - page_group struct has active_list , inactive_list and flag.
 - I'm now considering add following flag types.
	- can't reclaim		- for swapless anon/shmfs and ramdisk.
	- locked		- mlocked pages.
	- pages in special range  - ?

Pros(possible).
 - there may be good usage of this lru-group.
   lru-group is not necessary to be tied to zone, maybe.
 - list for "not reclaimable pages" can be built on this."
 - Can we do "add lru list for DMA pages and remove ZONE_DMA" ?
 - By reuse page->group pointer, we can remove PG_buddy.
 - Can this kind of structure be used for container's memory control method ?

Cons.
 - overhead in reclaim path.
 - need good scheduling where pages should be reclaimed from.
 - increase size of page struct.

This patch is just a scracth and not well tested/reviewed.
just tested on i386/UP system, works well.

I'm now trying to add LRU-for mlocked pages. (but not yet.)

Do you have any idea around zone's LRU ?
Any comment (including "Don't do that") is welcome.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/mm_inline.h |   26 ++---
 include/linux/mmzone.h    |   34 ++++++-
 mm/filemap.c              |    4 
 mm/migrate.c              |   10 +-
 mm/page_alloc.c           |    5 -
 mm/swap.c                 |   94 +++++++++----------
 mm/vmscan.c               |  222 +++++++++++++++++++++++++++++-----------------
 7 files changed, 242 insertions(+), 153 deletions(-)

Index: linux-2.6.23-rc4/include/linux/mmzone.h
===================================================================
--- linux-2.6.23-rc4.orig/include/linux/mmzone.h
+++ linux-2.6.23-rc4/include/linux/mmzone.h
@@ -188,6 +188,29 @@ enum zone_type {
 #endif
 #undef __ZONE_COUNT
 
+
+/*
+ * Page grouping structure for memory reclaim.
+ */
+
+struct page_group {
+	struct list_head list;		/* list of scan list */
+	struct zone *z;			/* zone of this. */
+	spinlock_t	lru_lock;	/* lock for active/inactive list */
+	struct list_head active_list;
+	struct list_head inactive_list;
+	unsigned long	flags;
+#define DONTRECLAIM	0x1	/* This page group just contianes not-reclaimable pages */
+	atomic_t	refcnt; /* not used but will be used at dynamic page group handling */
+};
+
+/* for page recaliming interface */
+enum lru_type {
+	LRU_ACTIVE,
+	LRU_INACTIVE,
+};
+
+
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 	unsigned long		pages_min, pages_low, pages_high;
@@ -224,11 +247,9 @@ struct zone {
 
 
 	ZONE_PADDING(_pad1_)
-
-	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;	
-	struct list_head	active_list;
-	struct list_head	inactive_list;
+	spinlock_t		pg_lock;
+	struct page_group	*pg_token;
+	struct page_group	zone_lru;/* default lru for page reclaim */
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
@@ -612,6 +633,7 @@ extern int numa_zonelist_order_handler(s
 extern char numa_zonelist_order[];
 #define NUMA_ZONELIST_ORDER_LEN 16	/* string buffer size */
 
+extern void init_page_group(struct zone *z, struct page_group *pg);
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
 #ifndef numa_node_id
Index: linux-2.6.23-rc4/include/linux/mm_inline.h
===================================================================
--- linux-2.6.23-rc4.orig/include/linux/mm_inline.h
+++ linux-2.6.23-rc4/include/linux/mm_inline.h
@@ -1,40 +1,64 @@
 static inline void
-add_page_to_active_list(struct zone *zone, struct page *page)
+add_page_to_active_list(struct page_group *pg, struct page *page)
 {
-	list_add(&page->lru, &zone->active_list);
-	__inc_zone_state(zone, NR_ACTIVE);
+	list_add(&page->lru, &pg->active_list);
+	__inc_zone_state(page_zone(page), NR_ACTIVE);
 }
 
 static inline void
-add_page_to_inactive_list(struct zone *zone, struct page *page)
+add_page_to_inactive_list(struct page_group *pg, struct page *page)
 {
-	list_add(&page->lru, &zone->inactive_list);
-	__inc_zone_state(zone, NR_INACTIVE);
+	list_add(&page->lru, &pg->inactive_list);
+	__inc_zone_state(page_zone(page), NR_INACTIVE);
 }
 
 static inline void
-del_page_from_active_list(struct zone *zone, struct page *page)
+del_page_from_active_list(struct page_group *pg, struct page *page)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_ACTIVE);
+	__dec_zone_state(page_zone(page), NR_ACTIVE);
 }
 
 static inline void
-del_page_from_inactive_list(struct zone *zone, struct page *page)
+del_page_from_inactive_list(struct page_group *pg, struct page *page)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_INACTIVE);
+	__dec_zone_state(page_zone(page), NR_INACTIVE);
 }
 
 static inline void
-del_page_from_lru(struct zone *zone, struct page *page)
+del_page_from_lru(struct page_group *pg, struct page *page)
 {
 	list_del(&page->lru);
 	if (PageActive(page)) {
 		__ClearPageActive(page);
-		__dec_zone_state(zone, NR_ACTIVE);
+		__dec_zone_state(page_zone(page), NR_ACTIVE);
 	} else {
-		__dec_zone_state(zone, NR_INACTIVE);
+		__dec_zone_state(page_zone(page), NR_INACTIVE);
 	}
 }
+/*
+ * Should be done under page_lock() ?
+ */
 
+static inline struct page_group * page_group(struct page *page)
+{
+	return page->group;
+}
+
+static inline void set_page_group(struct page *page, struct page_group *pg)
+{
+	page->group = pg;
+}
+
+/*
+ * Just for preparing 'dynamic page group addition/deletion
+ * it is not used now.
+ */
+static inline void get_pagegroup(struct page_group *pg)
+{
+}
+
+static inline void put_pagegroup(struct page_group *pg)
+{
+}
Index: linux-2.6.23-rc4/mm/vmscan.c
===================================================================
--- linux-2.6.23-rc4.orig/mm/vmscan.c
+++ linux-2.6.23-rc4/mm/vmscan.c
@@ -132,6 +132,19 @@ void unregister_shrinker(struct shrinker
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
+
+int pagegroup_should_be_reclaimed(struct page_group *pg, enum lru_type type)
+{
+	if (pg->flags & DONTRECLAIM)
+		return 0;
+	if (type == LRU_ACTIVE && list_empty(&pg->active_list))
+		return 0;
+	if (type == LRU_INACTIVE && list_empty(&pg->inactive_list))
+		return 0;
+	return 1;
+}
+
+
 #define SHRINK_BATCH 128
 /*
  * Call the shrink functions to age shrinkable caches
@@ -657,7 +670,7 @@ static int __isolate_lru_page(struct pag
 }
 
 /*
- * zone->lru_lock is heavily contended.  Some of the functions that
+ * page_group->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
  *
@@ -778,6 +791,48 @@ static unsigned long clear_active_flags(
 	return nr_active;
 }
 
+static struct page_group *zone_isolate_lru(unsigned long nr_to_scan,
+		struct zone *zone, struct list_head *dst, enum lru_type type,
+		unsigned long *scanned, unsigned long *taken, int order, int mode)
+{
+	struct page_group *pg, *start_pg;
+	*taken = 0;
+	*scanned = 0;
+
+	spin_lock(&zone->pg_lock);
+	/* do we need some intelligent scheduler ? */
+	if (zone->pg_token)
+		pg = zone->pg_token;
+	else
+		pg = &zone->zone_lru;
+	start_pg = pg;
+	do {
+		if (pagegroup_should_be_reclaimed(pg, type))
+			break;
+		pg = list_entry(pg->list.next, struct page_group, list);
+	} while (pg != start_pg);
+	get_pagegroup(pg);
+	spin_unlock(&zone->pg_lock);
+
+	if (pagegroup_should_be_reclaimed(pg, type)) {
+		if (type == LRU_ACTIVE)
+			*taken = isolate_lru_pages(nr_to_scan,
+				&pg->active_list, dst, scanned, order, mode);
+		else
+			*taken = isolate_lru_pages(nr_to_scan,
+				&pg->inactive_list, dst, scanned, order, mode);
+	} else
+		pg = NULL;
+
+	if (zone->pg_token) {
+		put_pagegroup(zone->pg_token);
+		get_pagegroup(pg);
+		zone->pg_token = pg;
+	}
+	return pg;
+}
+
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -789,11 +844,11 @@ static unsigned long shrink_inactive_lis
 	struct pagevec pvec;
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
+	struct page_group *pg;
 
 	pagevec_init(&pvec, 1);
 
 	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
 	do {
 		struct page *page;
 		unsigned long nr_taken;
@@ -801,9 +856,9 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_freed;
 		unsigned long nr_active;
 
-		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-			     &zone->inactive_list,
-			     &page_list, &nr_scan, sc->order,
+		pg = zone_isolate_lru(sc->swap_cluster_max,
+			     zone, &page_list, LRU_INACTIVE,
+			     &nr_scan, &nr_taken, sc->order,
 			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
 					     ISOLATE_BOTH : ISOLATE_INACTIVE);
 		nr_active = clear_active_flags(&page_list);
@@ -813,7 +868,6 @@ static unsigned long shrink_inactive_lis
 		__mod_zone_page_state(zone, NR_INACTIVE,
 						-(nr_taken - nr_active));
 		zone->pages_scanned += nr_scan;
-		spin_unlock_irq(&zone->lru_lock);
 
 		nr_scanned += nr_scan;
 		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
@@ -851,27 +905,27 @@ static unsigned long shrink_inactive_lis
 		if (nr_taken == 0)
 			goto done;
 
-		spin_lock(&zone->lru_lock);
 		/*
 		 * Put back any unfreeable pages.
 		 */
+		spin_lock(&pg->lru_lock);
 		while (!list_empty(&page_list)) {
 			page = lru_to_page(&page_list);
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
 			if (PageActive(page))
-				add_page_to_active_list(zone, page);
+				add_page_to_active_list(pg, page);
 			else
-				add_page_to_inactive_list(zone, page);
+				add_page_to_inactive_list(pg, page);
 			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&zone->lru_lock);
+				spin_unlock_irq(&pg->lru_lock);
 				__pagevec_release(&pvec);
-				spin_lock_irq(&zone->lru_lock);
+				spin_lock_irq(&pg->lru_lock);
 			}
 		}
+		spin_unlock(&pg->lru_lock);
   	} while (nr_scanned < max_scan);
-	spin_unlock(&zone->lru_lock);
 done:
 	local_irq_enable();
 	pagevec_release(&pvec);
@@ -926,6 +980,7 @@ static void shrink_active_list(unsigned 
 	LIST_HEAD(l_active);	/* Pages to go onto the active_list */
 	struct page *page;
 	struct pagevec pvec;
+	struct page_group *pg;
 	int reclaim_mapped = 0;
 
 	if (sc->may_swap) {
@@ -975,83 +1030,85 @@ force_reclaim_mapped:
 			reclaim_mapped = 1;
 	}
 
-	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-			    &l_hold, &pgscanned, sc->order, ISOLATE_ACTIVE);
-	zone->pages_scanned += pgscanned;
-	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
-	spin_unlock_irq(&zone->lru_lock);
-
-	while (!list_empty(&l_hold)) {
-		cond_resched();
-		page = lru_to_page(&l_hold);
-		list_del(&page->lru);
-		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0)) {
-				list_add(&page->lru, &l_active);
+	while (nr_pages > 0) {
+		lru_add_drain();
+		pg = zone_isolate_lru(nr_pages, zone, &l_hold, LRU_ACTIVE,
+			    &pgscanned, &pgmoved, sc->order, ISOLATE_ACTIVE);
+		zone->pages_scanned += pgscanned;
+		__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
+		if (!pgscanned)
+			break;
+		nr_pages -= pgscanned;
+		while (!list_empty(&l_hold)) {
+			cond_resched();
+			page = lru_to_page(&l_hold);
+			list_del(&page->lru);
+			if (page_mapped(page)) {
+				if (!reclaim_mapped ||
+			    	(total_swap_pages == 0 && PageAnon(page)) ||
+			    	page_referenced(page, 0)) {
+					list_add(&page->lru, &l_active);
 				continue;
+				}
 			}
+			list_add(&page->lru, &l_inactive);
 		}
-		list_add(&page->lru, &l_inactive);
-	}
 
-	pagevec_init(&pvec, 1);
-	pgmoved = 0;
-	spin_lock_irq(&zone->lru_lock);
-	while (!list_empty(&l_inactive)) {
-		page = lru_to_page(&l_inactive);
-		prefetchw_prev_lru_page(page, &l_inactive, flags);
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		VM_BUG_ON(!PageActive(page));
-		ClearPageActive(page);
+		pagevec_init(&pvec, 1);
+		pgmoved = 0;
+		spin_lock_irq(&pg->lru_lock);
+		while (!list_empty(&l_inactive)) {
+			page = lru_to_page(&l_inactive);
+			prefetchw_prev_lru_page(page, &l_inactive, flags);
+			VM_BUG_ON(PageLRU(page));
+			SetPageLRU(page);
+			VM_BUG_ON(!PageActive(page));
+			ClearPageActive(page);
 
-		list_move(&page->lru, &zone->inactive_list);
-		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
-			spin_unlock_irq(&zone->lru_lock);
-			pgdeactivate += pgmoved;
-			pgmoved = 0;
-			if (buffer_heads_over_limit)
-				pagevec_strip(&pvec);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+			list_move(&page->lru, &pg->inactive_list);
+			pgmoved++;
+			if (!pagevec_add(&pvec, page)) {
+				__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+				spin_unlock_irq(&pg->lru_lock);
+				pgdeactivate += pgmoved;
+				pgmoved = 0;
+				if (buffer_heads_over_limit)
+					pagevec_strip(&pvec);
+				__pagevec_release(&pvec);
+				spin_lock_irq(&pg->lru_lock);
+			}
+		}
+		__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+		pgdeactivate += pgmoved;
+		if (buffer_heads_over_limit) {
+			spin_unlock_irq(&pg->lru_lock);
+			pagevec_strip(&pvec);
+			spin_lock_irq(&pg->lru_lock);
 		}
-	}
-	__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
-	pgdeactivate += pgmoved;
-	if (buffer_heads_over_limit) {
-		spin_unlock_irq(&zone->lru_lock);
-		pagevec_strip(&pvec);
-		spin_lock_irq(&zone->lru_lock);
-	}
 
-	pgmoved = 0;
-	while (!list_empty(&l_active)) {
-		page = lru_to_page(&l_active);
-		prefetchw_prev_lru_page(page, &l_active, flags);
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		VM_BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
-		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
-			pgmoved = 0;
-			spin_unlock_irq(&zone->lru_lock);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+		pgmoved = 0;
+		while (!list_empty(&l_active)) {
+			page = lru_to_page(&l_active);
+			prefetchw_prev_lru_page(page, &l_active, flags);
+			VM_BUG_ON(PageLRU(page));
+			SetPageLRU(page);
+			VM_BUG_ON(!PageActive(page));
+			list_move(&page->lru, &pg->active_list);
+			pgmoved++;
+			if (!pagevec_add(&pvec, page)) {
+				__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+				pgmoved = 0;
+				spin_unlock_irq(&pg->lru_lock);
+				__pagevec_release(&pvec);
+				spin_lock_irq(&pg->lru_lock);
+			}
 		}
-	}
-	__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+		__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 
-	__count_zone_vm_events(PGREFILL, zone, pgscanned);
-	__count_vm_events(PGDEACTIVATE, pgdeactivate);
-	spin_unlock_irq(&zone->lru_lock);
+		__count_zone_vm_events(PGREFILL, zone, pgscanned);
+		__count_vm_events(PGDEACTIVATE, pgdeactivate);
+		spin_unlock_irq(&pg->lru_lock);
+	}
 
 	pagevec_release(&pvec);
 }
Index: linux-2.6.23-rc4/mm/swap.c
===================================================================
--- linux-2.6.23-rc4.orig/mm/swap.c
+++ linux-2.6.23-rc4/mm/swap.c
@@ -42,13 +42,13 @@ static void fastcall __page_cache_releas
 {
 	if (PageLRU(page)) {
 		unsigned long flags;
-		struct zone *zone = page_zone(page);
+		struct page_group *pg = page_group(page);
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		spin_lock_irqsave(&pg->lru_lock, flags);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
-		del_page_from_lru(zone, page);
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		del_page_from_lru(pg, page);
+		spin_unlock_irqrestore(&pg->lru_lock, flags);
 	}
 	free_hot_page(page);
 }
@@ -110,7 +110,7 @@ EXPORT_SYMBOL(put_pages_list);
  */
 int rotate_reclaimable_page(struct page *page)
 {
-	struct zone *zone;
+	struct page_group *pg;
 	unsigned long flags;
 
 	if (PageLocked(page))
@@ -122,15 +122,15 @@ int rotate_reclaimable_page(struct page 
 	if (!PageLRU(page))
 		return 1;
 
-	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lru_lock, flags);
+	pg = page_group(page);
+	spin_lock_irqsave(&pg->lru_lock, flags);
 	if (PageLRU(page) && !PageActive(page)) {
-		list_move_tail(&page->lru, &zone->inactive_list);
+		list_move_tail(&page->lru, &pg->inactive_list);
 		__count_vm_event(PGROTATED);
 	}
 	if (!test_clear_page_writeback(page))
 		BUG();
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	spin_unlock_irqrestore(&pg->lru_lock, flags);
 	return 0;
 }
 
@@ -139,16 +139,16 @@ int rotate_reclaimable_page(struct page 
  */
 void fastcall activate_page(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct page_group *pg = page_group(page);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(&pg->lru_lock);
 	if (PageLRU(page) && !PageActive(page)) {
-		del_page_from_inactive_list(zone, page);
+		del_page_from_inactive_list(pg, page);
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		add_page_to_active_list(pg, page);
 		__count_vm_event(PGACTIVATE);
 	}
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(&pg->lru_lock);
 }
 
 /*
@@ -257,16 +257,16 @@ void release_pages(struct page **pages, 
 {
 	int i;
 	struct pagevec pages_to_free;
-	struct zone *zone = NULL;
+	struct page_group *pg= NULL;
 
 	pagevec_init(&pages_to_free, cold);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
 		if (unlikely(PageCompound(page))) {
-			if (zone) {
-				spin_unlock_irq(&zone->lru_lock);
-				zone = NULL;
+			if (pg) {
+				spin_unlock_irq(&pg->lru_lock);
+				pg = NULL;
 			}
 			put_compound_page(page);
 			continue;
@@ -276,29 +276,29 @@ void release_pages(struct page **pages, 
 			continue;
 
 		if (PageLRU(page)) {
-			struct zone *pagezone = page_zone(page);
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irq(&zone->lru_lock);
-				zone = pagezone;
-				spin_lock_irq(&zone->lru_lock);
+			struct page_group *group = page_group(page);
+			if (group != pg) {
+				if (pg)
+					spin_unlock_irq(&pg->lru_lock);
+				pg = group;
+				spin_lock_irq(&pg->lru_lock);
 			}
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
-			del_page_from_lru(zone, page);
+			del_page_from_lru(pg, page);
 		}
 
 		if (!pagevec_add(&pages_to_free, page)) {
-			if (zone) {
-				spin_unlock_irq(&zone->lru_lock);
-				zone = NULL;
+			if (pg) {
+				spin_unlock_irq(&pg->lru_lock);
+				pg = NULL;
 			}
 			__pagevec_free(&pages_to_free);
 			pagevec_reinit(&pages_to_free);
   		}
 	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
+	if (pg)
+		spin_unlock_irq(&pg->lru_lock);
 
 	pagevec_free(&pages_to_free);
 }
@@ -351,24 +351,24 @@ void __pagevec_release_nonlru(struct pag
 void __pagevec_lru_add(struct pagevec *pvec)
 {
 	int i;
-	struct zone *zone = NULL;
+	struct page_group *pg = NULL;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
+		struct page_group *group = page_group(page);
 
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
+		if (group != pg) {
+			if (pg)
+				spin_unlock_irq(&pg->lru_lock);
+			pg = group;
+			spin_lock_irq(&pg->lru_lock);
 		}
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
-		add_page_to_inactive_list(zone, page);
+		add_page_to_inactive_list(pg, page);
 	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
+	if (pg)
+		spin_unlock_irq(&pg->lru_lock);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
@@ -378,26 +378,26 @@ EXPORT_SYMBOL(__pagevec_lru_add);
 void __pagevec_lru_add_active(struct pagevec *pvec)
 {
 	int i;
-	struct zone *zone = NULL;
+	struct page_group *pg = NULL;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
+		struct page_group *group = page_group(page);
 
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
+		if (group != pg) {
+			if (pg)
+				spin_unlock_irq(&pg->lru_lock);
+			pg = group;
+			spin_lock_irq(&pg->lru_lock);
 		}
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		add_page_to_active_list(pg, page);
 	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
+	if (pg)
+		spin_unlock_irq(&pg->lru_lock);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
Index: linux-2.6.23-rc4/mm/page_alloc.c
===================================================================
--- linux-2.6.23-rc4.orig/mm/page_alloc.c
+++ linux-2.6.23-rc4/mm/page_alloc.c
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/mm_inline.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -615,6 +616,7 @@ static int prep_new_page(struct page *pa
 			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
 	set_page_private(page, 0);
 	set_page_refcounted(page);
+	set_page_group(page, &(page_zone(page)->zone_lru)); /* default */
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
@@ -2963,15 +2965,14 @@ static void __meminit free_area_init_cor
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
+		spin_lock_init(&zone->pg_lock);
+		init_page_group(zone, &zone->zone_lru);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
 		zone->prev_priority = DEF_PRIORITY;
 
 		zone_pcp_init(zone);
-		INIT_LIST_HEAD(&zone->active_list);
-		INIT_LIST_HEAD(&zone->inactive_list);
 		zone->nr_scan_active = 0;
 		zone->nr_scan_inactive = 0;
 		zap_zone_vm_stats(zone);
Index: linux-2.6.23-rc4/mm/filemap.c
===================================================================
--- linux-2.6.23-rc4.orig/mm/filemap.c
+++ linux-2.6.23-rc4/mm/filemap.c
@@ -95,8 +95,8 @@ generic_file_direct_IO(int rw, struct ki
  *    ->swap_lock		(try_to_unmap_one)
  *    ->private_lock		(try_to_unmap_one)
  *    ->tree_lock		(try_to_unmap_one)
- *    ->zone.lru_lock		(follow_page->mark_page_accessed)
- *    ->zone.lru_lock		(check_pte_range->isolate_lru_page)
+ *    ->page_group.lru_lock	(follow_page->mark_page_accessed)
+ *    ->page_group.lru_lock	(check_pte_range->isolate_lru_page)
  *    ->private_lock		(page_remove_rmap->set_page_dirty)
  *    ->tree_lock		(page_remove_rmap->set_page_dirty)
  *    ->inode_lock		(page_remove_rmap->set_page_dirty)
Index: linux-2.6.23-rc4/mm/rmap.c
===================================================================
--- linux-2.6.23-rc4.orig/mm/rmap.c
+++ linux-2.6.23-rc4/mm/rmap.c
@@ -27,7 +27,7 @@
  *       mapping->i_mmap_lock
  *         anon_vma->lock
  *           mm->page_table_lock or pte_lock
- *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
+ *             page_group->lru_lock (in mark_page_accessed, isolate_lru_page)
  *             swap_lock (in swap_duplicate, swap_info_get)
  *               mmlist_lock (in mmput, drain_mmlist and others)
  *               mapping->private_lock (in __set_page_dirty_buffers)
Index: linux-2.6.23-rc4/mm/mmzone.c
===================================================================
--- linux-2.6.23-rc4.orig/mm/mmzone.c
+++ linux-2.6.23-rc4/mm/mmzone.c
@@ -9,6 +9,18 @@
 #include <linux/mmzone.h>
 #include <linux/module.h>
 
+void init_page_group(struct zone *zone, struct page_group *pg)
+{
+	INIT_LIST_HEAD(&pg->list);
+	INIT_LIST_HEAD(&pg->active_list);
+	INIT_LIST_HEAD(&pg->inactive_list);
+	spin_lock_init(&pg->lru_lock);
+	pg->z = zone;
+	pg->flags = 0;
+	atomic_set(&pg->refcnt, 1);
+}
+
+
 struct pglist_data *first_online_pgdat(void)
 {
 	return NODE_DATA(first_online_node);
Index: linux-2.6.23-rc4/include/linux/mm_types.h
===================================================================
--- linux-2.6.23-rc4.orig/include/linux/mm_types.h
+++ linux-2.6.23-rc4/include/linux/mm_types.h
@@ -64,6 +64,7 @@ struct page {
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
 					 */
+	struct page_group	*group;
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
Index: linux-2.6.23-rc4/mm/migrate.c
===================================================================
--- linux-2.6.23-rc4.orig/mm/migrate.c
+++ linux-2.6.23-rc4/mm/migrate.c
@@ -46,9 +46,9 @@ int isolate_lru_page(struct page *page, 
 	int ret = -EBUSY;
 
 	if (PageLRU(page)) {
-		struct zone *zone = page_zone(page);
+		struct page_group *pg = page_group(page);
 
-		spin_lock_irq(&zone->lru_lock);
+		spin_lock_irq(&pg->lru_lock);
 		if (PageLRU(page) && get_page_unless_zero(page)) {
 			ret = 0;
 			ClearPageLRU(page);
@@ -58,7 +58,7 @@ int isolate_lru_page(struct page *page, 
 				del_page_from_inactive_list(zone, page);
 			list_add_tail(&page->lru, pagelist);
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(&pg->lru_lock);
 	}
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
