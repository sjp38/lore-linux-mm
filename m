Date: Sat, 20 Jan 2001 14:51:41 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] conditional background scanning
Message-ID: <Pine.LNX.4.21.0101201437130.6647-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

The following patch against pre9 implements the limits (previously
discussed issue) on background scanning.

I removed the pte scanning so this patch is only a obvious bugfix.

I can't read your mind, so please answer when you have a reason for not
accepting a patch. 

I still dont know why you think scanning the pte's when there is no need
to do so (because we already unmapped enough pages) is correct.

And the patch: 

diff -Nur linux.orig/include/linux/swap.h linux/include/linux/swap.h
--- linux.orig/include/linux/swap.h	Sat Jan 20 16:00:18 2001
+++ linux/include/linux/swap.h	Sat Jan 20 16:06:25 2001
@@ -101,6 +101,7 @@
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
+extern int bg_page_aging;
 extern struct page * reclaim_page(zone_t *);
 extern wait_queue_head_t kswapd_wait;
 extern wait_queue_head_t kreclaimd_wait;
diff -Nur linux.orig/mm/swap.c linux/mm/swap.c
--- linux.orig/mm/swap.c	Sat Jan 20 16:00:18 2001
+++ linux/mm/swap.c	Sat Jan 20 16:06:25 2001
@@ -200,17 +200,22 @@
 {
 	if (PageInactiveDirty(page)) {
 		del_page_from_inactive_dirty_list(page);
-		add_page_to_active_list(page);
 	} else if (PageInactiveClean(page)) {
 		del_page_from_inactive_clean_list(page);
-		add_page_to_active_list(page);
 	} else {
 		/*
 		 * The page was not on any list, so we take care
 		 * not to do anything.
 		 */
+		goto inc_age;
 	}
 
+	add_page_to_active_list(page);
+	
+	if(bg_page_aging < num_physpages)
+		bg_page_aging++;
+
+inc_age:
 	/* Make sure the page gets a fair chance at staying active. */
 	if (page->age < PAGE_AGE_START)
 		page->age = PAGE_AGE_START;
diff -Nur linux.orig/mm/vmscan.c linux/mm/vmscan.c
--- linux.orig/mm/vmscan.c	Sat Jan 20 16:00:18 2001
+++ linux/mm/vmscan.c	Sat Jan 20 16:13:16 2001
@@ -24,17 +24,8 @@
 
 #include <asm/pgalloc.h>
 
-/*
- * The swap-out functions return 1 if they successfully
- * threw something out, and we got a free page. It returns
- * zero if it couldn't do anything, and any other value
- * indicates it decreased rss, but the page was shared.
- *
- * NOTE! If it sleeps, it *must* return 1 to make sure we
- * don't continue with the swap-out. Otherwise we may be
- * using a process that no longer actually exists (it might
- * have died while we slept).
- */
+int bg_page_aging = 0;
+
 static void try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page *page)
 {
 	pte_t pte;
@@ -626,22 +617,24 @@
 /**
  * refill_inactive_scan - scan the active list and find pages to deactivate
  * @priority: the priority at which to scan
- * @oneshot: exit after deactivating one page
+ * @background: slightly different behaviour for background scanning
  *
  * This function will scan a portion of the active list to find
  * unused pages, those pages will then be moved to the inactive list.
  */
-int refill_inactive_scan(unsigned int priority, int oneshot)
+int refill_inactive_scan(unsigned int priority, int background)
 {
 	struct list_head * page_lru;
 	struct page * page;
-	int maxscan, page_active = 0;
+	int maxscan;
 	int ret = 0;
+	int deactivate = 1;
 
 	/* Take the lock while messing with the list... */
 	spin_lock(&pagemap_lru_lock);
 	maxscan = nr_active_pages >> priority;
 	while (maxscan-- > 0 && (page_lru = active_list.prev) != &active_list) {
+		int page_active = 0;
 		page = list_entry(page_lru, struct page, lru);
 
 		/* Wrong page on list?! (list corruption, should not happen) */
@@ -656,9 +649,19 @@
 		if (PageTestandClearReferenced(page)) {
 			age_page_up_nolock(page);
 			page_active = 1;
-		} else {
+		} else if (deactivate) {
 			age_page_down_ageonly(page);
 			/*
+			 * We're aging down a page. Decrement the counter if it
+ 			 * has not reached zero yet. If it reached zero, and we 			 * are doing background scan, stop deactivating pages.
+			 */
+			if (bg_page_aging)
+				bg_page_aging--;
+			else if (background) {
+				deactivate = 0;
+				continue;	
+			}
+			/*
 			 * Since we don't hold a reference on the page
 			 * ourselves, we have to do our test a bit more
 			 * strict then deactivate_page(). This is needed
@@ -672,21 +675,20 @@
 						(page->buffers ? 2 : 1)) {
 				deactivate_page_nolock(page);
 				page_active = 0;
-			} else {
-				page_active = 1;
 			}
 		}
 		/*
 		 * If the page is still on the active list, move it
 		 * to the other end of the list. Otherwise it was
-		 * deactivated by age_page_down and we exit successfully.
+		 * deactivated by deactivate_page_nolock and we exit 
+		 * successfully.
 		 */
 		if (page_active || PageActive(page)) {
 			list_del(page_lru);
 			list_add(page_lru, &active_list);
 		} else {
 			ret = 1;
-			if (oneshot)
+			if (!background)
 				break;
 		}
 	}
@@ -800,7 +802,7 @@
 			schedule();
 		}
 
-		while (refill_inactive_scan(DEF_PRIORITY, 1)) {
+		while (refill_inactive_scan(DEF_PRIORITY, 0)) {
 			if (--count <= 0)
 				goto done;
 		}
@@ -919,7 +921,7 @@
 		 * every minute. This clears old referenced bits
 		 * and moves unused pages to the inactive list.
 		 */
-		refill_inactive_scan(DEF_PRIORITY, 0);
+		refill_inactive_scan(DEF_PRIORITY, 1);
 
 		/* Once a second, recalculate some VM stats. */
 		if (time_after(jiffies, recalc + HZ)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
