Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 792BF6B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 03:00:08 -0500 (EST)
Subject: [PATCH 1/2]mm: simplify code of swap.c
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 16:00:04 +0800
Message-ID: <1294214404.1949.572.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Clean up code and remove duplicate code. Next patch will use
pagevec_lru_move_fn introduced here too.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/swap.c |  101 +++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 54 insertions(+), 47 deletions(-)

Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2011-01-04 11:06:33.000000000 +0800
+++ linux/mm/swap.c	2011-01-04 13:56:12.000000000 +0800
@@ -98,15 +98,13 @@ void put_pages_list(struct list_head *pa
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
@@ -114,29 +112,49 @@ static void pagevec_move_tail(struct pag
 
 		if (pagezone != zone) {
 			if (zone)
-				spin_unlock(&zone->lru_lock);
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
 			zone = pagezone;
-			spin_lock(&zone->lru_lock);
-		}
-		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-			int lru = page_lru_base_type(page);
-			list_move_tail(&page->lru, &zone->lru[lru].list);
-			pgmoved++;
+			spin_lock_irqsave(&zone->lru_lock, flags);
 		}
+
+		(*move_fn)(page, arg);
 	}
 	if (zone)
-		spin_unlock(&zone->lru_lock);
-	__count_vm_events(PGROTATED, pgmoved);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
 	pagevec_reinit(pvec);
 }
 
+static void pagevec_move_tail_fn(struct page *page, void *arg)
+{
+	int *pgmoved = arg;
+	struct zone *zone = page_zone(page);
+
+	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+		int lru = page_lru_base_type(page);
+		list_move_tail(&page->lru, &zone->lru[lru].list);
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
@@ -399,44 +417,33 @@ void __pagevec_release(struct pagevec *p
 
 EXPORT_SYMBOL(__pagevec_release);
 
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
