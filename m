Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 229758D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 12:58:36 -0500 (EST)
Message-Id: <20110302175726.425254077@chello.nl>
Date: Wed, 02 Mar 2011 18:55:06 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 8/8] mm: Optimize page_lock_anon_vma() fast-path
References: <20110302175458.726109015@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-optimize_page_lock_anon_vma_fast-path.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

Optimize the page_lock_anon_vma() fast path to be one LOCKed op,
instead of two.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/rmap.c |   86 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 82 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -85,6 +85,29 @@ static inline struct anon_vma *anon_vma_
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
 	VM_BUG_ON(atomic_read(&anon_vma->refcount));
+
+	/*
+	 * Synchronize against page_lock_anon_vma() such that
+	 * we can safely hold the lock without the anon_vma getting
+	 * freed.
+	 *
+	 * Relies on the full mb implied by the atomic_dec_and_test() from
+	 * put_anon_vma() against the acquire barrier implied by
+	 * mutex_trylock() from page_lock_anon_vma(). This orders:
+	 *
+	 * page_lock_anon_vma()		VS	put_anon_vma()
+	 *   mutex_trylock()			  atomic_dec_and_test()
+	 *   LOCK				  MB
+	 *   atomic_read()			  mutex_is_locked()
+	 *
+	 * LOCK should suffice since the actual taking of the lock must
+	 * happen _before_ what follows.
+	 */
+	if (mutex_is_locked(&anon_vma->root->mutex)) {
+		anon_vma_lock(anon_vma);
+		anon_vma_unlock(anon_vma);
+	}
+
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
@@ -371,20 +394,75 @@ struct anon_vma *page_get_anon_vma(struc
 	return anon_vma;
 }
 
+/*
+ * Similar to page_get_anon_vma() except it locks the anon_vma.
+ *
+ * Its a little more complex as it tries to keep the fast path to a single
+ * atomic op -- the trylock. If we fail the trylock, we fall back to getting a
+ * reference like with page_get_anon_vma() and then block on the mutex.
+ */
 struct anon_vma *page_lock_anon_vma(struct page *page)
 {
-	struct anon_vma *anon_vma = page_get_anon_vma(page);
+	struct anon_vma *anon_vma = NULL;
+	unsigned long anon_mapping;
 
-	if (anon_vma)
-		anon_vma_lock(anon_vma);
+	rcu_read_lock();
+	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
+	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
+		goto out;
+	if (!page_mapped(page))
+		goto out;
+
+	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
+	if (mutex_trylock(&anon_vma->root->mutex)) {
+		/*
+		 * If we observe a !0 refcount, then holding the lock ensures
+		 * the anon_vma will not go away, see __put_anon_vma().
+		 */
+		if (!atomic_read(&anon_vma->refcount)) {
+			anon_vma_unlock(anon_vma);
+			anon_vma = NULL;
+		}
+		goto out;
+	}
+
+	/* trylock failed, we got to sleep */
+	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
+		anon_vma = NULL;
+		goto out;
+	}
 
+	if (!page_mapped(page)) {
+		put_anon_vma(anon_vma);
+		anon_vma = NULL;
+		goto out;
+	}
+
+	/* we pinned the anon_vma, its safe to sleep */
+	rcu_read_unlock();
+	anon_vma_lock(anon_vma);
+
+	if (atomic_dec_and_test(&anon_vma->refcount)) {
+		/*
+		 * Oops, we held the last refcount, release the lock
+		 * and bail -- can't simply use put_anon_vma() because
+		 * we'll deadlock on the anon_vma_lock() recursion.
+		 */
+		anon_vma_unlock(anon_vma);
+		__put_anon_vma(anon_vma);
+		anon_vma = NULL;
+	}
+
+	return anon_vma;
+
+out:
+	rcu_read_unlock();
 	return anon_vma;
 }
 
 void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	anon_vma_unlock(anon_vma);
-	put_anon_vma(anon_vma);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
