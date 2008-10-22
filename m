Message-Id: <20081022225513.040237161@saeurebad.de>
Date: Thu, 23 Oct 2008 00:50:09 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch 3/3] swap: cache page activation
References: <20081022225006.010250557@saeurebad.de>
Content-Disposition: inline; filename=swap-cache-page-activation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of acquiring the highly contented LRU lock on each page
activation, use a pagevec and activate pages batch-wise.

Also factor out the add-to-cache-maybe-flush mechanism that is
shared between page rotation and activation code.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---
 include/linux/pagevec.h |    1 
 mm/swap.c               |   80 +++++++++++++++++++++++++++---------------------
 2 files changed, 47 insertions(+), 34 deletions(-)

--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -24,6 +24,7 @@ enum lru_pagevec {
 	PAGEVEC_BASE,
 	PAGEVEC_ADD = PAGEVEC_BASE,
 	PAGEVEC_ROTATE = NR_LRU_LISTS,
+	PAGEVEC_ACTIVATE,
 	NR_LRU_PAGEVECS
 };
 
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -120,6 +120,24 @@ static void pagevec_flush_rotate(struct 
 	__count_vm_event(PGROTATED);
 }
 
+static void pagevec_flush_activate(struct zone *zone, struct page *page)
+{
+	int file, lru;
+
+	if (!PageLRU(page) || PageActive(page) || PageUnevictable(page))
+		return;
+	file = page_is_file_cache(page);
+	lru = LRU_BASE + file;
+	del_page_from_lru_list(zone, page, lru);
+	SetPageActive(page);
+	lru += LRU_ACTIVE;
+	add_page_to_lru_list(zone, page, lru);
+	mem_cgroup_move_lists(page, lru);
+	__count_vm_event(PGACTIVATE);
+	zone->recent_rotated[!!file]++;
+	zone->recent_scanned[!!file]++;
+}
+
 static enum lru_pagevec target_mode(enum lru_pagevec target)
 {
 	if (target > PAGEVEC_ADD && target < PAGEVEC_ROTATE)
@@ -152,6 +170,9 @@ static void ____pagevec_flush(struct pag
 		case PAGEVEC_ROTATE:
 			pagevec_flush_rotate(zone, page);
 			break;
+		case PAGEVEC_ACTIVATE:
+			pagevec_flush_activate(zone, page);
+			break;
 		default:
 			BUG();
 		}
@@ -170,50 +191,41 @@ void __pagevec_flush(struct pagevec *pve
 }
 EXPORT_SYMBOL(__pagevec_flush);
 
+static void move_page(struct page *page, enum lru_pagevec target)
+{
+	struct pagevec *pvec;
+
+	pvec = &__get_cpu_var(lru_pvecs)[target];
+	if (!pagevec_add(pvec, page))
+		____pagevec_flush(pvec, target);
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
-	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
-	    !PageUnevictable(page) && PageLRU(page)) {
-		struct pagevec *pvec;
-		unsigned long flags;
-
-		page_cache_get(page);
-		local_irq_save(flags);
-		pvec = &__get_cpu_var(lru_pvecs)[PAGEVEC_ROTATE];
-		if (!pagevec_add(pvec, page))
-			____pagevec_flush(pvec, PAGEVEC_ROTATE);
-		local_irq_restore(flags);
-	}
+	unsigned long flags;
+
+	if (!PageLRU(page) || PageActive(page) || PageUnevictable(page))
+		return;
+	if (PageLocked(page) || PageDirty(page))
+		return;
+	page_cache_get(page);
+	local_irq_save(flags);
+	move_page(page, PAGEVEC_ROTATE);
+	local_irq_restore(flags);
 }
 
-/*
- * FIXME: speed this up?
- */
 void activate_page(struct page *page)
 {
-	struct zone *zone = page_zone(page);
-
-	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		int file = page_is_file_cache(page);
-		int lru = LRU_BASE + file;
-		del_page_from_lru_list(zone, page, lru);
-
-		SetPageActive(page);
-		lru += LRU_ACTIVE;
-		add_page_to_lru_list(zone, page, lru);
-		__count_vm_event(PGACTIVATE);
-		mem_cgroup_move_lists(page, lru);
-
-		zone->recent_rotated[!!file]++;
-		zone->recent_scanned[!!file]++;
-	}
-	spin_unlock_irq(&zone->lru_lock);
+	if (!PageLRU(page) || PageActive(page) || PageUnevictable(page))
+		return;
+	local_irq_disable();
+	move_page(page, PAGEVEC_ACTIVATE);
+	local_irq_enable();
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
