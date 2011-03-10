Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E4FAD8D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 00:30:40 -0500 (EST)
Subject: [PATCH 1/2 v4]mm: simplify code of swap.c
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Mar 2011 13:30:18 +0800
Message-ID: <1299735018.2337.62.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

Clean up code and remove duplicate code. Next patch will use
pagevec_lru_move_fn introduced here too.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/swap.c |  133 +++++++++++++++++++++++++++-----------------------------------
 1 file changed, 58 insertions(+), 75 deletions(-)

Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2011-03-09 12:47:09.000000000 +0800
+++ linux/mm/swap.c	2011-03-09 13:39:26.000000000 +0800
@@ -179,15 +179,13 @@ void put_pages_list(struct list_head *pa
 }
 EXPORT_SYMBOL(put_pages_list);
 
-/*
- * pagevec_move_tail() must be called with IRQ disabled.
- * Otherwise this may cause nasty races.
- */
-static void pagevec_move_tail(struct pagevec *pvec)
+static void pagevec_lru_move_fn(struct pagevec *pvec,
+				void (*move_fn)(struct page *page, void *arg),
+				void *arg)
 {
 	int i;
-	int pgmoved = 0;
 	struct zone *zone = NULL;
+	unsigned long flags = 0;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
@@ -195,30 +193,50 @@ static void pagevec_move_tail(struct pag
 
 		if (pagezone != zone) {
 			if (zone)
-				spin_unlock(&zone->lru_lock);
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
 			zone = pagezone;
-			spin_lock(&zone->lru_lock);
-		}
-		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-			enum lru_list lru = page_lru_base_type(page);
-			list_move_tail(&page->lru, &zone->lru[lru].list);
-			mem_cgroup_rotate_reclaimable_page(page);
-			pgmoved++;
+			spin_lock_irqsave(&zone->lru_lock, flags);
 		}
+
+		(*move_fn)(page, arg);
 	}
 	if (zone)
-		spin_unlock(&zone->lru_lock);
-	__count_vm_events(PGROTATED, pgmoved);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
 
+static void pagevec_move_tail_fn(struct page *page, void *arg)
+{
+	int *pgmoved = arg;
+	struct zone *zone = page_zone(page);
+
+	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+		enum lru_list lru = page_lru_base_type(page);
+		list_move_tail(&page->lru, &zone->lru[lru].list);
+		mem_cgroup_rotate_reclaimable_page(page);
+		(*pgmoved)++;
+	}
+}
+
+/*
+ * pagevec_move_tail() must be called with IRQ disabled.
+ * Otherwise this may cause nasty races.
+ */
+static void pagevec_move_tail(struct pagevec *pvec)
+{
+	int pgmoved = 0;
+
+	pagevec_lru_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
+	__count_vm_events(PGROTATED, pgmoved);
+}
+
 /*
  * Writeback is about to end against a page which has been marked for immediate
  * reclaim.  If it still appears to be reclaimable, move it to the tail of the
  * inactive list.
  */
-void  rotate_reclaimable_page(struct page *page)
+void rotate_reclaimable_page(struct page *page)
 {
 	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
 	    !PageUnevictable(page) && PageLRU(page)) {
@@ -369,10 +387,11 @@ void add_page_to_unevictable_list(struct
  * be write it out by flusher threads as this is much more effective
  * than the single-page writeout from reclaim.
  */
-static void lru_deactivate(struct page *page, struct zone *zone)
+static void lru_deactivate_fn(struct page *page, void *arg)
 {
 	int lru, file;
 	bool active;
+	struct zone *zone = page_zone(page);
 
 	if (!PageLRU(page))
 		return;
@@ -412,31 +431,6 @@ static void lru_deactivate(struct page *
 	update_page_reclaim_stat(zone, page, file, 0);
 }
 
-static void ____pagevec_lru_deactivate(struct pagevec *pvec)
-{
-	int i;
-	struct zone *zone = NULL;
-
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		lru_deactivate(page, zone);
-	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
-
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
-}
-
-
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
@@ -466,7 +460,7 @@ static void drain_cpu_pagevecs(int cpu)
 
 	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
 	if (pagevec_count(pvec))
-		____pagevec_lru_deactivate(pvec);
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
 }
 
 /**
@@ -483,7 +477,7 @@ void deactivate_page(struct page *page)
 		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
 
 		if (!pagevec_add(pvec, page))
-			____pagevec_lru_deactivate(pvec);
+			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
 		put_cpu_var(lru_deactivate_pvecs);
 	}
 }
@@ -630,44 +624,33 @@ void lru_add_page_tail(struct zone* zone
 	}
 }
 
+static void ____pagevec_lru_add_fn(struct page *page, void *arg)
+{
+	enum lru_list lru = (enum lru_list)arg;
+	struct zone *zone = page_zone(page);
+	int file = is_file_lru(lru);
+	int active = is_active_lru(lru);
+
+	VM_BUG_ON(PageActive(page));
+	VM_BUG_ON(PageUnevictable(page));
+	VM_BUG_ON(PageLRU(page));
+
+	SetPageLRU(page);
+	if (active)
+		SetPageActive(page);
+	update_page_reclaim_stat(zone, page, file, active);
+	add_page_to_lru_list(zone, page, lru);
+}
+
 /*
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
 void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 {
-	int i;
-	struct zone *zone = NULL;
-
 	VM_BUG_ON(is_unevictable_lru(lru));
 
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
-		int file;
-		int active;
-
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irq(&zone->lru_lock);
-			zone = pagezone;
-			spin_lock_irq(&zone->lru_lock);
-		}
-		VM_BUG_ON(PageActive(page));
-		VM_BUG_ON(PageUnevictable(page));
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		active = is_active_lru(lru);
-		file = is_file_lru(lru);
-		if (active)
-			SetPageActive(page);
-		update_page_reclaim_stat(zone, page, file, active);
-		add_page_to_lru_list(zone, page, lru);
-	}
-	if (zone)
-		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
+	pagevec_lru_move_fn(pvec, ____pagevec_lru_add_fn, (void *)lru);
 }
 
 EXPORT_SYMBOL(____pagevec_lru_add);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
