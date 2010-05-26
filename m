Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D6EAB6B01EA
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:29:08 -0400 (EDT)
Date: Wed, 26 May 2010 11:27:06 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH 4/5] always lock the root (oldest) anon_vma
Message-ID: <20100526112706.145f72eb@annuminas.surriel.com>
In-Reply-To: <20100526112403.635be0ed@annuminas.surriel.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512134029.36c286c4@annuminas.surriel.com>
	<20100512210216.GP24989@csn.ul.ie>
	<4BEB18BB.5010803@redhat.com>
	<20100513095439.GA27949@csn.ul.ie>
	<20100513103356.25665186@annuminas.surriel.com>
	<20100513140919.0a037845.akpm@linux-foundation.org>
	<4BFC9CCF.6000809@redhat.com>
	<20100526112403.635be0ed@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Subject: always lock the root (oldest) anon_vma

Always (and only) lock the root (oldest) anon_vma whenever we do something in an
anon_vma.  The recently introduced anon_vma scalability is due to the rmap code
scanning only the VMAs that need to be scanned.  Many common operations still
took the anon_vma lock on the root anon_vma, so always taking that lock is not
expected to introduce any scalability issues.

However, always taking the same lock does mean we only need to take one lock,
which means rmap_walk on pages from any anon_vma in the vma is excluded from
occurring during an munmap, expand_stack or other operation that needs to
exclude rmap_walk and similar functions.

Also add the proper locking to vma_adjust.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
v3:
 - fix locking inversion in vma_adjust, spotted by Andrea
 - mm_take_all locks needs to use the bitflag in the root anon_vma,
   since that is the one that gets locked (Andrea Arcangeli)
v2:
 - conditionally take the anon_vma lock in vma_adjust, like introduced
   in 252c5f94d944487e9f50ece7942b0fbf659c5c31  (with a proper comment)

 include/linux/rmap.h |    8 ++++----
 mm/ksm.c             |    2 +-
 mm/migrate.c         |    2 +-
 mm/mmap.c            |   30 ++++++++++++++++++++++--------
 4 files changed, 28 insertions(+), 14 deletions(-)

Index: linux-2.6.34/include/linux/rmap.h
===================================================================
--- linux-2.6.34.orig/include/linux/rmap.h
+++ linux-2.6.34/include/linux/rmap.h
@@ -104,24 +104,24 @@ static inline void vma_lock_anon_vma(str
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_lock(&anon_vma->lock);
+		spin_lock(&anon_vma->root->lock);
 }
 
 static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		spin_unlock(&anon_vma->root->lock);
 }
 
 static inline void anon_vma_lock(struct anon_vma *anon_vma)
 {
-	spin_lock(&anon_vma->lock);
+	spin_lock(&anon_vma->root->lock);
 }
 
 static inline void anon_vma_unlock(struct anon_vma *anon_vma)
 {
-	spin_unlock(&anon_vma->lock);
+	spin_unlock(&anon_vma->root->lock);
 }
 
 /*
Index: linux-2.6.34/mm/ksm.c
===================================================================
--- linux-2.6.34.orig/mm/ksm.c
+++ linux-2.6.34/mm/ksm.c
@@ -325,7 +325,7 @@ static void drop_anon_vma(struct rmap_it
 {
 	struct anon_vma *anon_vma = rmap_item->anon_vma;
 
-	if (atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
+	if (atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->root->lock)) {
 		int empty = list_empty(&anon_vma->head);
 		anon_vma_unlock(anon_vma);
 		if (empty)
Index: linux-2.6.34/mm/mmap.c
===================================================================
--- linux-2.6.34.orig/mm/mmap.c
+++ linux-2.6.34/mm/mmap.c
@@ -506,6 +506,7 @@ int vma_adjust(struct vm_area_struct *vm
 	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
 	struct prio_tree_root *root = NULL;
+	struct anon_vma *anon_vma = NULL;
 	struct file *file = vma->vm_file;
 	long adjust_next = 0;
 	int remove_next = 0;
@@ -578,6 +579,17 @@ again:			remove_next = 1 + (end > next->
 		}
 	}
 
+	/*
+	 * When changing only vma->vm_end, we don't really need anon_vma
+	 * lock. This is a fairly rare case by itself, but the anon_vma
+	 * lock may be shared between many sibling processes.  Skipping
+	 * the lock for brk adjustments makes a difference sometimes.
+	 */
+	if (vma->anon_vma && (insert || importer || start != vma->vm_start)) {
+		anon_vma = vma->anon_vma;
+		anon_vma_lock(anon_vma);
+	}
+
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -617,6 +629,8 @@ again:			remove_next = 1 + (end > next->
 		__insert_vm_struct(mm, insert);
 	}
 
+	if (anon_vma)
+		anon_vma_unlock(anon_vma);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
@@ -2466,23 +2480,23 @@ static DEFINE_MUTEX(mm_all_locks_mutex);
 
 static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 {
-	if (!test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (!test_bit(0, (unsigned long *) &anon_vma->root->head.next)) {
 		/*
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_lock_nest_lock(&anon_vma->lock, &mm->mmap_sem);
+		spin_lock_nest_lock(&anon_vma->root->lock, &mm->mmap_sem);
 		/*
 		 * We can safely modify head.next after taking the
-		 * anon_vma->lock. If some other vma in this mm shares
+		 * anon_vma->root->lock. If some other vma in this mm shares
 		 * the same anon_vma we won't take it again.
 		 *
 		 * No need of atomic instructions here, head.next
 		 * can't change from under us thanks to the
-		 * anon_vma->lock.
+		 * anon_vma->root->lock.
 		 */
 		if (__test_and_set_bit(0, (unsigned long *)
-				       &anon_vma->head.next))
+				       &anon_vma->root->head.next))
 			BUG();
 	}
 }
@@ -2573,7 +2587,7 @@ out_unlock:
 
 static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	if (test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (test_bit(0, (unsigned long *) &anon_vma->root->head.next)) {
 		/*
 		 * The LSB of head.next can't change to 0 from under
 		 * us because we hold the mm_all_locks_mutex.
@@ -2584,10 +2598,10 @@ static void vm_unlock_anon_vma(struct an
 		 *
 		 * No need of atomic instructions here, head.next
 		 * can't change from under us until we release the
-		 * anon_vma->lock.
+		 * anon_vma->root->lock.
 		 */
 		if (!__test_and_clear_bit(0, (unsigned long *)
-					  &anon_vma->head.next))
+					  &anon_vma->root->head.next))
 			BUG();
 		anon_vma_unlock(anon_vma);
 	}
Index: linux-2.6.34/mm/migrate.c
===================================================================
--- linux-2.6.34.orig/mm/migrate.c
+++ linux-2.6.34/mm/migrate.c
@@ -682,7 +682,7 @@ skip_unmap:
 rcu_unlock:
 
 	/* Drop an anon_vma reference if we took one */
-	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
+	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->root->lock)) {
 		int empty = list_empty(&anon_vma->head);
 		anon_vma_unlock(anon_vma);
 		if (empty)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
