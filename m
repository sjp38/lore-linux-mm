Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D6F638D004B
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:10:49 -0500 (EST)
Message-Id: <20110217162124.322205562@chello.nl>
Date: Thu, 17 Feb 2011 17:19:49 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 1/3] mm: Rename drop_anon_vma to put_anon_vma
References: <20110217161948.045410404@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-rename_drop_anon_vma_to_put_anon_vma.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

The normal code pattern used in the kernel is: get/put.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/rmap.h |    4 ++--
 mm/ksm.c             |   23 +++++------------------
 mm/migrate.c         |    4 ++--
 mm/rmap.c            |    4 ++--
 4 files changed, 11 insertions(+), 24 deletions(-)

Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h
+++ linux-2.6/include/linux/rmap.h
@@ -87,7 +87,7 @@ static inline void get_anon_vma(struct a
 	atomic_inc(&anon_vma->external_refcount);
 }
 
-void drop_anon_vma(struct anon_vma *);
+void put_anon_vma(struct anon_vma *);
 #else
 static inline void anonvma_external_refcount_init(struct anon_vma *anon_vma)
 {
@@ -102,7 +102,7 @@ static inline void get_anon_vma(struct a
 {
 }
 
-static inline void drop_anon_vma(struct anon_vma *anon_vma)
+static inline void put_anon_vma(struct anon_vma *anon_vma)
 {
 }
 #endif /* CONFIG_KSM */
Index: linux-2.6/mm/ksm.c
===================================================================
--- linux-2.6.orig/mm/ksm.c
+++ linux-2.6/mm/ksm.c
@@ -301,20 +301,6 @@ static inline int in_stable_tree(struct 
 	return rmap_item->address & STABLE_FLAG;
 }
 
-static void hold_anon_vma(struct rmap_item *rmap_item,
-			  struct anon_vma *anon_vma)
-{
-	rmap_item->anon_vma = anon_vma;
-	get_anon_vma(anon_vma);
-}
-
-static void ksm_drop_anon_vma(struct rmap_item *rmap_item)
-{
-	struct anon_vma *anon_vma = rmap_item->anon_vma;
-
-	drop_anon_vma(anon_vma);
-}
-
 /*
  * ksmd, and unmerge_and_remove_all_rmap_items(), must not touch an mm's
  * page tables after it has passed through ksm_exit() - which, if necessary,
@@ -397,7 +383,7 @@ static void break_cow(struct rmap_item *
 	 * It is not an accident that whenever we want to break COW
 	 * to undo, we also need to drop a reference to the anon_vma.
 	 */
-	ksm_drop_anon_vma(rmap_item);
+	put_anon_vma(rmap_item->anon_vma);
 
 	down_read(&mm->mmap_sem);
 	if (ksm_test_exit(mm))
@@ -466,7 +452,7 @@ static void remove_node_from_stable_tree
 			ksm_pages_sharing--;
 		else
 			ksm_pages_shared--;
-		ksm_drop_anon_vma(rmap_item);
+		put_anon_vma(rmap_item->anon_vma);
 		rmap_item->address &= PAGE_MASK;
 		cond_resched();
 	}
@@ -554,7 +540,7 @@ static void remove_rmap_item_from_tree(s
 		else
 			ksm_pages_shared--;
 
-		ksm_drop_anon_vma(rmap_item);
+		put_anon_vma(rmap_item->anon_vma);
 		rmap_item->address &= PAGE_MASK;
 
 	} else if (rmap_item->address & UNSTABLE_FLAG) {
@@ -949,7 +935,8 @@ static int try_to_merge_with_ksm_page(st
 		goto out;
 
 	/* Must get reference to anon_vma while still holding mmap_sem */
-	hold_anon_vma(rmap_item, vma->anon_vma);
+	rmap_item->anon_vma = vma->anon_vma;
+	get_anon_vma(vma->anon_vma);
 out:
 	up_read(&mm->mmap_sem);
 	return err;
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -764,7 +764,7 @@ static int unmap_and_move(new_page_t get
 
 	/* Drop an anon_vma reference if we took one */
 	if (anon_vma)
-		drop_anon_vma(anon_vma);
+		put_anon_vma(anon_vma);
 
 uncharge:
 	if (!charge)
@@ -857,7 +857,7 @@ static int unmap_and_move_huge_page(new_
 		remove_migration_ptes(hpage, hpage);
 
 	if (anon_vma)
-		drop_anon_vma(anon_vma);
+		put_anon_vma(anon_vma);
 out:
 	unlock_page(hpage);
 
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -278,7 +278,7 @@ static void anon_vma_unlink(struct anon_
 	if (empty) {
 		/* We no longer need the root anon_vma */
 		if (anon_vma->root != anon_vma)
-			drop_anon_vma(anon_vma->root);
+			put_anon_vma(anon_vma->root);
 		anon_vma_free(anon_vma);
 	}
 }
@@ -1489,7 +1489,7 @@ int try_to_munlock(struct page *page)
  * we know we are the last user, nobody else can get a reference and we
  * can do the freeing without the lock.
  */
-void drop_anon_vma(struct anon_vma *anon_vma)
+void put_anon_vma(struct anon_vma *anon_vma)
 {
 	BUG_ON(atomic_read(&anon_vma->external_refcount) <= 0);
 	if (atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->root->lock)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
