Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 40ECD8D003D
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:22:41 -0500 (EST)
Message-Id: <20110217170855.048229155@chello.nl>
Date: Thu, 17 Feb 2011 18:05:26 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 6/8] mm: Use refcounts for page_lock_anon_vma()
References: <20110217170520.229881980@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-use_refcounts_for_page_lock_anon_vma.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

Convert page_lock_anon_vma() over to use refcounts. This is done to
prepare for the conversion of anon_vma from spinlock to mutex.

Sadly this inceases the cost of page_lock_anon_vma() from one to two
atomics, a follow up patch addresses this, lets keep that simple for
now.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/migrate.c |   17 ++++-------------
 mm/rmap.c    |   42 +++++++++++++++++++++++++++---------------
 2 files changed, 31 insertions(+), 28 deletions(-)

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -336,9 +336,9 @@ void __init anon_vma_init(void)
  * that the anon_vma pointer from page->mapping is valid if there is a
  * mapcount, we can dereference the anon_vma after observing those.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_get_anon_vma(struct page *page)
 {
-	struct anon_vma *anon_vma, *root_anon_vma;
+	struct anon_vma *anon_vma = NULL;
 	unsigned long anon_mapping;
 
 	rcu_read_lock();
@@ -349,30 +349,42 @@ struct anon_vma *page_lock_anon_vma(stru
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	root_anon_vma = ACCESS_ONCE(anon_vma->root);
-	spin_lock(&root_anon_vma->lock);
+	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
+		anon_vma = NULL;
+		goto out;
+	}
 
 	/*
 	 * If this page is still mapped, then its anon_vma cannot have been
-	 * freed.  But if it has been unmapped, we have no security against
-	 * the anon_vma structure being freed and reused (for another anon_vma:
-	 * SLAB_DESTROY_BY_RCU guarantees that - so the spin_lock above cannot
-	 * corrupt): with anon_vma_prepare() or anon_vma_fork() redirecting
-	 * anon_vma->root before page_unlock_anon_vma() is called to unlock.
+	 * freed.  But if it has been unmapped, we have no security against the
+	 * anon_vma structure being freed and reused (for another anon_vma:
+	 * SLAB_DESTROY_BY_RCU guarantees that - so the atomic_inc_not_zero()
+	 * above cannot corrupt).
 	 */
-	if (page_mapped(page))
-		return anon_vma;
-
-	spin_unlock(&root_anon_vma->lock);
+	if (!page_mapped(page)) {
+		put_anon_vma(anon_vma);
+		anon_vma = NULL;
+	}
 out:
 	rcu_read_unlock();
-	return NULL;
+
+	return anon_vma;
+}
+
+struct anon_vma *page_lock_anon_vma(struct page *page)
+{
+	struct anon_vma *anon_vma = page_get_anon_vma(page);
+
+	if (anon_vma)
+		anon_vma_lock(anon_vma);
+
+	return anon_vma;
 }
 
 void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	anon_vma_unlock(anon_vma);
-	rcu_read_unlock();
+	put_anon_vma(anon_vma);
 }
 
 /*
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -703,15 +703,11 @@ static int unmap_and_move(new_page_t get
 		 * Only page_lock_anon_vma() understands the subtleties of
 		 * getting a hold on an anon_vma from outside one of its mms.
 		 */
-		anon_vma = page_lock_anon_vma(page);
+		anon_vma = page_get_anon_vma(page);
 		if (anon_vma) {
 			/*
-			 * Take a reference count on the anon_vma if the
-			 * page is mapped so that it is guaranteed to
-			 * exist when the page is remapped later
+			 * Anon page
 			 */
-			get_anon_vma(anon_vma);
-			page_unlock_anon_vma(anon_vma);
 		} else if (PageSwapCache(page)) {
 			/*
 			 * We cannot be sure that the anon_vma of an unmapped
@@ -840,13 +836,8 @@ static int unmap_and_move_huge_page(new_
 		lock_page(hpage);
 	}
 
-	if (PageAnon(hpage)) {
-		anon_vma = page_lock_anon_vma(hpage);
-		if (anon_vma) {
-			get_anon_vma(anon_vma);
-			page_unlock_anon_vma(anon_vma);
-		}
-	}
+	if (PageAnon(hpage))
+		anon_vma = page_get_anon_vma(hpage);
 
 	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
