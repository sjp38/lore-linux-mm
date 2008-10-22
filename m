Message-Id: <20081022225512.717773617@saeurebad.de>
Date: Thu, 23 Oct 2008 00:50:07 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch 1/3] swap: use an array for all pagevecs
References: <20081022225006.010250557@saeurebad.de>
Content-Disposition: inline; filename=swap-use-an-array-for-all-pagevecs.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Use an array for all pagevecs, not just for those we cache new LRU
pages on.  This will ease further refactoring.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---
 include/linux/pagevec.h |    7 +++++++
 mm/swap.c               |   15 +++++++--------
 2 files changed, 14 insertions(+), 8 deletions(-)

--- a/mm/swap.c
+++ b/mm/swap.c
@@ -36,8 +36,7 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
-static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
+static DEFINE_PER_CPU(struct pagevec[NR_LRU_PAGEVECS], lru_pvecs);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -144,7 +143,7 @@ void  rotate_reclaimable_page(struct pag
 
 		page_cache_get(page);
 		local_irq_save(flags);
-		pvec = &__get_cpu_var(lru_rotate_pvecs);
+		pvec = &__get_cpu_var(lru_pvecs)[PAGEVEC_ROTATE];
 		if (!pagevec_add(pvec, page))
 			pagevec_move_tail(pvec);
 		local_irq_restore(flags);
@@ -198,12 +197,12 @@ EXPORT_SYMBOL(mark_page_accessed);
 
 void __lru_cache_add(struct page *page, enum lru_list lru)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
+	struct pagevec *pvec = &get_cpu_var(lru_pvecs)[PAGEVEC_ADD + lru];
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
 		____pagevec_lru_add(pvec, lru);
-	put_cpu_var(lru_add_pvecs);
+	put_cpu_var(lru_pvecs);
 }
 
 /**
@@ -272,17 +271,17 @@ void lru_cache_add_active_or_unevictable
  */
 static void drain_cpu_pagevecs(int cpu)
 {
-	struct pagevec *pvecs = per_cpu(lru_add_pvecs, cpu);
+	struct pagevec *pvecs = per_cpu(lru_pvecs, cpu);
 	struct pagevec *pvec;
 	int lru;
 
 	for_each_lru(lru) {
-		pvec = &pvecs[lru - LRU_BASE];
+		pvec = &pvecs[PAGEVEC_ADD + lru];
 		if (pagevec_count(pvec))
 			____pagevec_lru_add(pvec, lru);
 	}
 
-	pvec = &per_cpu(lru_rotate_pvecs, cpu);
+	pvec = &pvecs[PAGEVEC_ROTATE];
 	if (pagevec_count(pvec)) {
 		unsigned long flags;
 
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -20,6 +20,13 @@ struct pagevec {
 	struct page *pages[PAGEVEC_SIZE];
 };
 
+enum lru_pagevec {
+	PAGEVEC_BASE,
+	PAGEVEC_ADD = PAGEVEC_BASE,
+	PAGEVEC_ROTATE = NR_LRU_LISTS,
+	NR_LRU_PAGEVECS
+};
+
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_release_nonlru(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
