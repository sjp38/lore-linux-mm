Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DD4B16B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 18:44:30 -0400 (EDT)
Date: Fri, 21 May 2010 00:42:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 6/5] adjust mm_take_all_locks to anon-vma-root locking
Message-ID: <20100520224258.GA12100@random.random>
References: <20100512133815.0d048a86@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100512133815.0d048a86@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is needed as 6/5 to avoid lockups in mm_take_all_locks.

======
Subject: adjust mm_take_all_locks to the root_anon_vma locking

From: Andrea Arcangeli <aarcange@redhat.com>

Track the anon_vma->root->lock.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2480,7 +2480,7 @@ static DEFINE_MUTEX(mm_all_locks_mutex);
 
 static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 {
-	if (!test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (!test_bit(0, (unsigned long *) &anon_vma->root->head.next)) {
 		/*
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
@@ -2488,15 +2488,15 @@ static void vm_lock_anon_vma(struct mm_s
 		spin_lock_nest_lock(&anon_vma->root->lock, &mm->mmap_sem);
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
@@ -2537,12 +2537,12 @@ static void vm_lock_mapping(struct mm_st
  * A single task can't take more than one mm_take_all_locks() in a row
  * or it would deadlock.
  *
- * The LSB in anon_vma->head.next and the AS_MM_ALL_LOCKS bitflag in
+ * The LSB in anon_vma->root->head.next and the AS_MM_ALL_LOCKS bitflag in
  * mapping->flags avoid to take the same lock twice, if more than one
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
- * taking i_mmap_lock or anon_vma->lock outside the mmap_sem never
+ * taking i_mmap_lock or anon_vma->root->lock outside the mmap_sem never
  * takes more than one of them in a row. Secondly we're protected
  * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
  *
@@ -2587,21 +2587,21 @@ out_unlock:
 
 static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	if (test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+	if (test_bit(0, (unsigned long *) &anon_vma->root->head.next)) {
 		/*
 		 * The LSB of head.next can't change to 0 from under
 		 * us because we hold the mm_all_locks_mutex.
 		 *
 		 * We must however clear the bitflag before unlocking
-		 * the vma so the users using the anon_vma->head will
+		 * the vma so the users using the anon_vma->root->head will
 		 * never see our bitflag.
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
