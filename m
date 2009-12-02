Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D39B96007DB
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 11:36:52 -0500 (EST)
Subject: [PATCH] mlock:  replace stale comments in munlock_vma_page()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 02 Dec 2009 11:35:35 -0500
Message-Id: <1259771735.4088.31.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>



Cleanup stale comments on munlock_vma_page().

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mlock.c |   41 +++++++++++++++++++----------------------
 1 files changed, 19 insertions(+), 22 deletions(-)

Index: linux-2.6.32-rc8/mm/mlock.c
===================================================================
--- linux-2.6.32-rc8.orig/mm/mlock.c	2009-11-24 13:19:58.000000000 -0500
+++ linux-2.6.32-rc8/mm/mlock.c	2009-12-01 13:27:25.000000000 -0500
@@ -88,23 +88,20 @@ void mlock_vma_page(struct page *page)
 	}
 }
 
-/*
- * called from munlock()/munmap() path with page supposedly on the LRU.
+/**
+ * munlock_vma_page - munlock a vma page
+ * @page - page to be unlocked
  *
- * Note:  unlike mlock_vma_page(), we can't just clear the PageMlocked
- * [in try_to_munlock()] and then attempt to isolate the page.  We must
- * isolate the page to keep others from messing with its unevictable
- * and mlocked state while trying to munlock.  However, we pre-clear the
- * mlocked state anyway as we might lose the isolation race and we might
- * not get another chance to clear PageMlocked.  If we successfully
- * isolate the page and try_to_munlock() detects other VM_LOCKED vmas
- * mapping the page, it will restore the PageMlocked state, unless the page
- * is mapped in a non-linear vma.  So, we go ahead and SetPageMlocked(),
- * perhaps redundantly.
- * If we lose the isolation race, and the page is mapped by other VM_LOCKED
- * vmas, we'll detect this in vmscan--via try_to_munlock() or try_to_unmap()
- * either of which will restore the PageMlocked state by calling
- * mlock_vma_page() above, if it can grab the vma's mmap sem.
+ * called from munlock()/munmap() path with page supposedly on the LRU.
+ * When we munlock a page, because the vma where we found the page is being
+ * munlock()ed or munmap()ed, we want to check whether other vmas hold the
+ * page locked so that we can leave it on the unevictable lru list and not
+ * bother vmscan with it.  However, to walk the page's rmap list in
+ * try_to_munlock() we must isolate the page from the LRU.  If some other
+ * task has removed the page from the LRU, we won't be able to do that.
+ * So we clear the PageMlocked as we might not get another chance.  If we
+ * can't isolate the page, we leave it for putback_lru_page() and vmscan
+ * [page_referenced()/try_to_unmap()] to deal with.
  */
 static void munlock_vma_page(struct page *page)
 {
@@ -123,12 +120,12 @@ static void munlock_vma_page(struct page
 			putback_lru_page(page);
 		} else {
 			/*
-			 * We lost the race.  let try_to_unmap() deal
-			 * with it.  At least we get the page state and
-			 * mlock stats right.  However, page is still on
-			 * the noreclaim list.  We'll fix that up when
-			 * the page is eventually freed or we scan the
-			 * noreclaim list.
+			 * Some other task has removed the page from the LRU.
+			 * putback_lru_page() will take care of removing the
+			 * page from the unevictable list, if necessary.
+			 * vmscan [page_referenced()] will move the page back
+			 * to the unevictable list if some other vma has it
+			 * mlocked.
 			 */
 			if (PageUnevictable(page))
 				count_vm_event(UNEVICTABLE_PGSTRANDED);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
