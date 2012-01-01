Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D874F6B00A7
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:48:10 -0500 (EST)
Received: by iacb35 with SMTP id b35so33334766iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:48:10 -0800 (PST)
Date: Sat, 31 Dec 2011 23:48:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 6/6] mm: rearrange putback_inactive_pages
In-Reply-To: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312346400.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

There is sometimes confusion between the global putback_lru_pages()
in migrate.c and the static putback_lru_pages() in vmscan.c: rename
the latter putback_inactive_pages(): it helps shrink_inactive_list()
rather as move_active_pages_to_lru() helps shrink_active_list().

Remove unused scan_control arg from putback_inactive_pages() and
from update_isolated_counts().  Move clear_active_flags() inside
update_isolated_counts().  Move NR_ISOLATED accounting up into
shrink_inactive_list() itself, so the balance is clearer.

Do the spin_lock_irq() before calling putback_inactive_pages() and
spin_unlock_irq() after return from it, so that it better matches
update_isolated_counts() and move_active_pages_to_lru().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/vmscan.c |   96 ++++++++++++++++++++++----------------------------
 1 file changed, 44 insertions(+), 52 deletions(-)

--- mmotm.orig/mm/vmscan.c	2011-12-31 14:58:45.680036183 -0800
+++ mmotm/mm/vmscan.c	2011-12-31 17:26:25.264246809 -0800
@@ -1284,32 +1284,6 @@ static unsigned long isolate_lru_pages(u
 	return nr_taken;
 }
 
-/*
- * clear_active_flags() is a helper for shrink_active_list(), clearing
- * any active bits from the pages in the list.
- */
-static unsigned long clear_active_flags(struct list_head *page_list,
-					unsigned int *count)
-{
-	int nr_active = 0;
-	int lru;
-	struct page *page;
-
-	list_for_each_entry(page, page_list, lru) {
-		int numpages = hpage_nr_pages(page);
-		lru = page_lru_base_type(page);
-		if (PageActive(page)) {
-			lru += LRU_ACTIVE;
-			ClearPageActive(page);
-			nr_active += numpages;
-		}
-		if (count)
-			count[lru] += numpages;
-	}
-
-	return nr_active;
-}
-
 /**
  * isolate_lru_page - tries to isolate a page from its LRU list
  * @page: page to isolate from its LRU list
@@ -1383,26 +1357,21 @@ static int too_many_isolated(struct zone
 	return isolated > inactive;
 }
 
-/*
- * TODO: Try merging with migrations version of putback_lru_pages
- */
 static noinline_for_stack void
-putback_lru_pages(struct mem_cgroup_zone *mz, struct scan_control *sc,
-		  unsigned long nr_anon, unsigned long nr_file,
-		  struct list_head *page_list)
+putback_inactive_pages(struct mem_cgroup_zone *mz,
+		       struct list_head *page_list)
 {
-	struct page *page;
-	LIST_HEAD(pages_to_free);
-	struct zone *zone = mz->zone;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
+	struct zone *zone = mz->zone;
+	LIST_HEAD(pages_to_free);
 
 	/*
 	 * Put back any unfreeable pages.
 	 */
-	spin_lock(&zone->lru_lock);
 	while (!list_empty(page_list)) {
+		struct page *page = lru_to_page(page_list);
 		int lru;
-		page = lru_to_page(page_list);
+
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page, NULL))) {
@@ -1432,26 +1401,40 @@ putback_lru_pages(struct mem_cgroup_zone
 				list_add(&page->lru, &pages_to_free);
 		}
 	}
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
-	spin_unlock_irq(&zone->lru_lock);
-	free_hot_cold_page_list(&pages_to_free, 1);
+	/*
+	 * To save our caller's stack, now use input list for pages to free.
+	 */
+	list_splice(&pages_to_free, page_list);
 }
 
 static noinline_for_stack void
 update_isolated_counts(struct mem_cgroup_zone *mz,
-		       struct scan_control *sc,
+		       struct list_head *page_list,
 		       unsigned long *nr_anon,
-		       unsigned long *nr_file,
-		       struct list_head *isolated_list)
+		       unsigned long *nr_file)
 {
-	unsigned long nr_active;
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
 	struct zone *zone = mz->zone;
 	unsigned int count[NR_LRU_LISTS] = { 0, };
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
+	unsigned long nr_active = 0;
+	struct page *page;
+	int lru;
+
+	/*
+	 * Count pages and clear active flags
+	 */
+	list_for_each_entry(page, page_list, lru) {
+		int numpages = hpage_nr_pages(page);
+		lru = page_lru_base_type(page);
+		if (PageActive(page)) {
+			lru += LRU_ACTIVE;
+			ClearPageActive(page);
+			nr_active += numpages;
+		}
+		count[lru] += numpages;
+	}
 
-	nr_active = clear_active_flags(isolated_list, count);
 	__count_vm_events(PGDEACTIVATE, nr_active);
 
 	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
@@ -1465,8 +1448,6 @@ update_isolated_counts(struct mem_cgroup
 
 	*nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
 	*nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, *nr_anon);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, *nr_file);
 
 	reclaim_stat->recent_scanned[0] += *nr_anon;
 	reclaim_stat->recent_scanned[1] += *nr_file;
@@ -1571,7 +1552,10 @@ shrink_inactive_list(unsigned long nr_to
 		return 0;
 	}
 
-	update_isolated_counts(mz, sc, &nr_anon, &nr_file, &page_list);
+	update_isolated_counts(mz, &page_list, &nr_anon, &nr_file);
+
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
 
 	spin_unlock_irq(&zone->lru_lock);
 
@@ -1585,12 +1569,20 @@ shrink_inactive_list(unsigned long nr_to
 					priority, &nr_dirty, &nr_writeback);
 	}
 
-	local_irq_disable();
+	spin_lock_irq(&zone->lru_lock);
+
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_lru_pages(mz, sc, nr_anon, nr_file, &page_list);
+	putback_inactive_pages(mz, &page_list);
+
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
+
+	spin_unlock_irq(&zone->lru_lock);
+
+	free_hot_cold_page_list(&page_list, 1);
 
 	/*
 	 * If reclaim is isolating dirty pages under writeback, it implies

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
