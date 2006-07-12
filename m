From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:44:38 +0200
Message-Id: <20060712144438.16998.90664.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 39/39] mm: use-once: cleanup of the insertion logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Make the use-once policy use only a single PCP for insertion.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

 mm/useonce.c |   24 +-----------------------
 1 file changed, 1 insertion(+), 23 deletions(-)

Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:10:56.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:10:56.000000000 +0200
@@ -26,9 +26,8 @@ void __init pgrep_init_zone(struct zone 
  * @page: the page to add
  */
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
-static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
 
-static inline void lru_cache_add(struct page *page)
+void fastcall pgrep_add(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
 
@@ -38,33 +37,12 @@ static inline void lru_cache_add(struct 
 	put_cpu_var(lru_add_pvecs);
 }
 
-static inline void lru_cache_add_active(struct page *page)
-{
-	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
-
-	page_cache_get(page);
-	if (!pagevec_add(pvec, page))
-		__pagevec_pgrep_add(pvec);
-	put_cpu_var(lru_add_active_pvecs);
-}
-
-void fastcall pgrep_add(struct page *page)
-{
-	if (PageActive(page))
-		lru_cache_add_active(page);
-	else
-		lru_cache_add(page);
-}
-
 void __pgrep_add_drain(unsigned int cpu)
 {
 	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
 
 	if (pagevec_count(pvec))
 		__pagevec_pgrep_add(pvec);
-	pvec = &per_cpu(lru_add_active_pvecs, cpu);
-	if (pagevec_count(pvec))
-		__pagevec_pgrep_add(pvec);
 }
 
 void pgrep_reinsert(struct list_head *page_list)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
