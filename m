Date: Thu, 18 Jan 2001 20:15:26 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] Limited background active list [and pte] scanning 
Message-ID: <Pine.LNX.4.21.0101181958290.4610-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi,

Right now, the background scanning (done by kswapd) is unconditional.
Without VM activity, the background scanning will make all pages have the
same age. 

The following patch limits background active list scanning to avoid the
problem described above.

Also it adds background pte scanning. 

Comments?

diff -Nur linux.orig/mm/swap.c linux/mm/swap.c
--- linux.orig/mm/swap.c	Thu Jan 18 17:20:47 2001
+++ linux/mm/swap.c	Thu Jan 18 17:21:44 2001
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
--- linux.orig/mm/vmscan.c	Thu Jan 18 17:20:47 2001
+++ linux/mm/vmscan.c	Thu Jan 18 17:23:00 2001
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
@@ -42,9 +33,7 @@
 
 	/* Don't look at this pte if it's been accessed recently. */
 	if (ptep_test_and_clear_young(page_table)) {
-		page->age += PAGE_AGE_ADV;
-		if (page->age > PAGE_AGE_MAX)
-			page->age = PAGE_AGE_MAX;
+		age_page_up(page);
 		return;
 	}
 
@@ -121,6 +110,8 @@
 	/* Add it to the swap cache and mark it dirty */
 	add_to_swap_cache(page, entry);
 	set_page_dirty(page);
+	if (bg_page_aging)
+		bg_page_aging--;
 	goto set_swap_pte;
 
 out_unlock_restore:
@@ -269,7 +260,7 @@
 	return nr < SWAP_MIN ? SWAP_MIN : nr;
 }
 
-static int swap_out(unsigned int priority, int gfp_mask)
+static int swap_out(unsigned int priority, int background)
 {
 	int counter;
 	int retval = 0;
@@ -301,6 +292,13 @@
 		/* Walk about 6% of the address space each time */
 		retval |= swap_out_mm(mm, swap_amount(mm));
 		mmput(mm);
+		/* 
+		 *  In the case of background aging, stop
+		 *  the scan when we aged the necessary amount
+		 *  of pages.
+		 */
+		if (background && !bg_page_aging)
+			break;
 	} while (--counter >= 0);
 	return retval;
 
@@ -626,22 +624,24 @@
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
@@ -656,9 +656,19 @@
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
@@ -672,21 +682,20 @@
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
@@ -800,13 +809,13 @@
 			schedule();
 		}
 
-		while (refill_inactive_scan(DEF_PRIORITY, 1)) {
+		while (refill_inactive_scan(DEF_PRIORITY, 0)) {
 			if (--count <= 0)
 				goto done;
 		}
 
 		/* If refill_inactive_scan failed, try to page stuff out.. */
-		swap_out(DEF_PRIORITY, gfp_mask);
+		swap_out(DEF_PRIORITY, 0);
 
 		if (--maxtry <= 0)
 				return 0;
@@ -919,7 +928,11 @@
 		 * every minute. This clears old referenced bits
 		 * and moves unused pages to the inactive list.
 		 */
-		refill_inactive_scan(DEF_PRIORITY, 0);
+		refill_inactive_scan(DEF_PRIORITY, 1);
+
+		/* Walk the pte's and age them. */
+		if (bg_page_aging)
+			swap_out(DEF_PRIORITY, 1);
 
 		/* Once a second, recalculate some VM stats. */
 		if (time_after(jiffies, recalc + HZ)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
