Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 88F638D0047
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:10:51 -0500 (EST)
Message-Id: <20110217170855.118593065@chello.nl>
Date: Thu, 17 Feb 2011 18:05:27 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 7/8] mm: Convert anon_vma->lock to a mutex
References: <20110217170520.229881980@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-anon_vma-lock_to_mutexes.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

Straight fwd conversion of anon_vma->lock to a mutex.

Acked-by: Hugh Dickins <hughd@google.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/huge_mm.h      |    8 ++------
 include/linux/mmu_notifier.h |    2 +-
 include/linux/rmap.h         |   14 +++++++-------
 mm/huge_memory.c             |    4 ++--
 mm/mmap.c                    |   10 +++++-----
 mm/rmap.c                    |    8 ++++----
 6 files changed, 21 insertions(+), 25 deletions(-)

Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h
+++ linux-2.6/include/linux/rmap.h
@@ -7,7 +7,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
-#include <linux/spinlock.h>
+#include <linux/mutex.h>
 #include <linux/memcontrol.h>
 
 /*
@@ -26,7 +26,7 @@
  */
 struct anon_vma {
 	struct anon_vma *root;	/* Root of this anon_vma tree */
-	spinlock_t lock;	/* Serialize access to vma list */
+	struct mutex mutex;	/* Serialize access to vma list */
 	/*
 	 * The refcount is taken on an anon_vma when there is no
 	 * guarantee that the vma of page tables will exist for
@@ -64,7 +64,7 @@ struct anon_vma_chain {
 	struct vm_area_struct *vma;
 	struct anon_vma *anon_vma;
 	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
-	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
+	struct list_head same_anon_vma;	/* locked by anon_vma->mutex */
 };
 
 #ifdef CONFIG_MMU
@@ -93,24 +93,24 @@ static inline void vma_lock_anon_vma(str
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_lock(&anon_vma->root->lock);
+		mutex_lock(&anon_vma->root->mutex);
 }
 
 static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_unlock(&anon_vma->root->lock);
+		mutex_unlock(&anon_vma->root->mutex);
 }
 
 static inline void anon_vma_lock(struct anon_vma *anon_vma)
 {
-	spin_lock(&anon_vma->root->lock);
+	mutex_lock(&anon_vma->root->mutex);
 }
 
 static inline void anon_vma_unlock(struct anon_vma *anon_vma)
 {
-	spin_unlock(&anon_vma->root->lock);
+	mutex_unlock(&anon_vma->root->mutex);
 }
 
 /*
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -25,7 +25,7 @@
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
  *       mapping->i_mmap_mutex
- *         anon_vma->lock
+ *         anon_vma->mutex
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
  *             swap_lock (in swap_duplicate, swap_info_get)
@@ -39,7 +39,7 @@
  *
  * (code doesn't rely on that order so it could be switched around)
  * ->tasklist_lock
- *   anon_vma->lock      (memory_failure, collect_procs_anon)
+ *   anon_vma->mutex      (memory_failure, collect_procs_anon)
  *     pte map lock
  */
 
@@ -306,7 +306,7 @@ static void anon_vma_ctor(void *data)
 {
 	struct anon_vma *anon_vma = data;
 
-	spin_lock_init(&anon_vma->lock);
+	mutex_init(&anon_vma->mutex);
 	atomic_set(&anon_vma->refcount, 0);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
@@ -1129,7 +1129,7 @@ int try_to_unmap_one(struct page *page, 
 	/*
 	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
 	 * unstable result and race. Plus, We can't wait here because
-	 * we now hold anon_vma->lock or mapping->i_mmap_mutex.
+	 * we now hold anon_vma->mutex or mapping->i_mmap_mutex.
 	 * if trylock failed, the page remain in evictable lru and later
 	 * vmscan could retry to move the page to unevictable lru if the
 	 * page is actually mlocked.
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -2523,15 +2523,15 @@ static void vm_lock_anon_vma(struct mm_s
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_lock_nest_lock(&anon_vma->root->lock, &mm->mmap_sem);
+		mutex_lock_nest_lock(&anon_vma->root->mutex, &mm->mmap_sem);
 		/*
 		 * We can safely modify head.next after taking the
-		 * anon_vma->root->lock. If some other vma in this mm shares
+		 * anon_vma->root->mutex. If some other vma in this mm shares
 		 * the same anon_vma we won't take it again.
 		 *
 		 * No need of atomic instructions here, head.next
 		 * can't change from under us thanks to the
-		 * anon_vma->root->lock.
+		 * anon_vma->root->mutex.
 		 */
 		if (__test_and_set_bit(0, (unsigned long *)
 				       &anon_vma->root->head.next))
@@ -2580,7 +2580,7 @@ static void vm_lock_mapping(struct mm_st
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
- * taking i_mmap_mutex or anon_vma->lock outside the mmap_sem never
+ * taking i_mmap_mutex or anon_vma->mutex outside the mmap_sem never
  * takes more than one of them in a row. Secondly we're protected
  * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
  *
@@ -2636,7 +2636,7 @@ static void vm_unlock_anon_vma(struct an
 		 *
 		 * No need of atomic instructions here, head.next
 		 * can't change from under us until we release the
-		 * anon_vma->root->lock.
+		 * anon_vma->root->mutex.
 		 */
 		if (!__test_and_clear_bit(0, (unsigned long *)
 					  &anon_vma->root->head.next))
Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- linux-2.6.orig/include/linux/mmu_notifier.h
+++ linux-2.6/include/linux/mmu_notifier.h
@@ -150,7 +150,7 @@ struct mmu_notifier_ops {
  * Therefore notifier chains can only be traversed when either
  *
  * 1. mmap_sem is held.
- * 2. One of the reverse map locks is held (i_mmap_mutex or anon_vma->lock).
+ * 2. One of the reverse map locks is held (i_mmap_mutex or anon_vma->mutex).
  * 3. No other concurrent thread can access the list (release)
  */
 struct mmu_notifier {
Index: linux-2.6/mm/huge_memory.c
===================================================================
--- linux-2.6.orig/mm/huge_memory.c
+++ linux-2.6/mm/huge_memory.c
@@ -1128,7 +1128,7 @@ static int __split_huge_page_splitting(s
 		 * We can't temporarily set the pmd to null in order
 		 * to split it, the pmd must remain marked huge at all
 		 * times or the VM won't take the pmd_trans_huge paths
-		 * and it won't wait on the anon_vma->root->lock to
+		 * and it won't wait on the anon_vma->root->mutex to
 		 * serialize against split_huge_page*.
 		 */
 		pmdp_splitting_flush_notify(vma, address, pmd);
@@ -1315,7 +1315,7 @@ static int __split_huge_page_map(struct 
 	return ret;
 }
 
-/* must be called with anon_vma->root->lock hold */
+/* must be called with anon_vma->root->mutex hold */
 static void __split_huge_page(struct page *page,
 			      struct anon_vma *anon_vma)
 {
Index: linux-2.6/include/linux/huge_mm.h
===================================================================
--- linux-2.6.orig/include/linux/huge_mm.h
+++ linux-2.6/include/linux/huge_mm.h
@@ -91,12 +91,8 @@ extern void __split_huge_page_pmd(struct
 #define wait_split_huge_page(__anon_vma, __pmd)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
-		spin_unlock_wait(&(__anon_vma)->root->lock);		\
-		/*							\
-		 * spin_unlock_wait() is just a loop in C and so the	\
-		 * CPU can reorder anything around it.			\
-		 */							\
-		smp_mb();						\
+		anon_vma_lock(__anon_vma);				\
+		anon_vma_unlock(__anon_vma);				\
 		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
 		       pmd_trans_huge(*____pmd));			\
 	} while (0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
