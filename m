From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 4/4  -ac to newer rmap
Message-Id: <20021113113716Z80406-30305+1114@imladris.surriel.com>
Date: Wed, 13 Nov 2002 09:37:05 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

fold page_over_rsslimit() into page_referenced()

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.694   -> 1.695  
#	           mm/rmap.c	1.9     -> 1.10   
#	include/linux/swap.h	1.35    -> 1.36   
#	         mm/vmscan.c	1.80    -> 1.81   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/29	riel@imladris.surriel.com	1.695
# fold page_over_rsslimit() into page_referenced()
# --------------------------------------------
#
diff -Nru a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h	Wed Nov 13 08:55:42 2002
+++ b/include/linux/swap.h	Wed Nov 13 08:55:42 2002
@@ -104,11 +104,10 @@
 struct zone_t;
 
 /* linux/mm/rmap.c */
-extern int FASTCALL(page_referenced(struct page *));
+extern int FASTCALL(page_referenced(struct page *, int *));
 extern void FASTCALL(page_add_rmap(struct page *, pte_t *));
 extern void FASTCALL(page_remove_rmap(struct page *, pte_t *));
 extern int FASTCALL(try_to_unmap(struct page *));
-extern int FASTCALL(page_over_rsslimit(struct page *));
 
 /* return values of try_to_unmap */
 #define	SWAP_SUCCESS	0
diff -Nru a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c	Wed Nov 13 08:55:42 2002
+++ b/mm/rmap.c	Wed Nov 13 08:55:42 2002
@@ -58,25 +58,41 @@
 /**
  * page_referenced - test if the page was referenced
  * @page: the page to test
+ * @rsslimit: place to put whether the page is over RSS limit
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of processes which referenced the page.
+ * In addition to this it checks if the processes holding the
+ * page are over or under their RSS limit.
  * Caller needs to hold the pte_chain_lock.
  */
-int page_referenced(struct page * page)
+int page_referenced(struct page * page, int * rsslimit)
 {
+	int referenced = 0, under_rsslimit = 0;
+	struct mm_struct * mm;
 	struct pte_chain * pc;
-	int referenced = 0;
 
 	if (PageTestandClearReferenced(page))
 		referenced++;
 
 	/* Check all the page tables mapping this page. */
 	for (pc = page->pte_chain; pc; pc = pc->next) {
-		if (ptep_test_and_clear_young(pc->ptep))
+		pte_t * ptep = pc->ptep;
+
+		if (ptep_test_and_clear_young(ptep))
 			referenced++;
+
+		mm = ptep_to_mm(ptep);
+		if (mm->rss < mm->rlimit_rss)
+			under_rsslimit++;
 	}
 
+	/*
+	 * We're only over the RSS limit if all the processes sharing the
+	 * page are.
+	 */
+	*rsslimit = !under_rsslimit;
+
 	return referenced;
 }
 
@@ -289,43 +305,6 @@
 	}
 
 	return ret;
-}
-
-/**
- * page_over_rsslimit - test if the page is over its RSS limit
- * @page - page to test
- *
- * This function returns true if the process owning this page
- * is over its RSS (resident set size) limit.  For shared pages
- * we penalise it only if all processes using it are over their
- * rss limits.
- * The caller needs to hold the page's pte_chain_lock.
- */
-int page_over_rsslimit(struct page * page)
-{
-	struct pte_chain * pte_chain = page->pte_chain;
-	struct mm_struct * mm;
-	pte_t * ptep;
-
-	/* No process is using the page. */
-	if (!pte_chain)
-		return 0;
-
-	do {
-		ptep = pte_chain->ptep;
-		mm = ptep_to_mm(ptep);
-
-		/*
-		 * If the process is under its RSS limit, stop
-		 * scanning and don't penalise the page.
-		 */
-		if(!mm->rlimit_rss || mm->rss <= mm->rlimit_rss)
-			return 0;
-		
-		pte_chain = pte_chain->next;
-	} while (pte_chain);
-
-	return 1;
 }
 
 /**
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Wed Nov 13 08:55:42 2002
+++ b/mm/vmscan.c	Wed Nov 13 08:55:42 2002
@@ -211,10 +211,10 @@
  */
 int page_launder_zone(zone_t * zone, int gfp_mask, int full_flush)
 {
-	int maxscan, cleaned_pages, target, maxlaunder, iopages;
+	int maxscan, cleaned_pages, target, maxlaunder, iopages, over_rsslimit;
 	struct list_head * entry, * next;
 
-	target = max(free_plenty(zone), zone->pages_min);
+	target = max_t(int, free_plenty(zone), zone->pages_min);
 	cleaned_pages = iopages = 0;
 
 	/* If we can get away with it, only flush 2 MB worth of dirty pages */
@@ -279,8 +279,8 @@
 		 * the active list and adjust the page age if needed.
 		 */
 		pte_chain_lock(page);
-		if (page_referenced(page) && page_mapping_inuse(page) &&
-				!page_over_rsslimit(page)) {
+		if (page_referenced(page, &over_rsslimit) && !over_rsslimit &&
+				page_mapping_inuse(page)) {
 			del_page_from_inactive_dirty_list(page);
 			add_page_to_active_list(page);
 			page->age = max((int)page->age, PAGE_AGE_START);
@@ -506,9 +506,9 @@
 int refill_inactive_zone(struct zone_struct * zone, int priority)
 {
 	int maxscan = zone->active_pages >> priority;
+	int nr_deactivated = 0, over_rsslimit;
 	int target = inactive_high(zone);
 	struct list_head * page_lru;
-	int nr_deactivated = 0;
 	struct page * page;
 
 	/* Take the lock while messing with the list... */
@@ -550,7 +550,7 @@
 		/*
 		 * Do aging on the pages.
 		 */
-		if (page_referenced(page)) {
+		if (page_referenced(page, &over_rsslimit)) {
 			age_page_up(page);
 		} else {
 			age_page_down(page);
@@ -561,7 +561,7 @@
 		 * page doesn't exceed its RSS limit we keep the page.
 		 * Otherwise we move it to the inactive_dirty list.
 		 */
-		if (page->age && !page_over_rsslimit(page)) {
+		if (page->age && !over_rsslimit) {
 			list_del(page_lru);
 			list_add(page_lru, &zone->active_list);
 		} else {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
