Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8D5CA6B0228
	for <linux-mm@kvack.org>; Thu, 13 May 2010 10:35:11 -0400 (EDT)
Date: Thu, 13 May 2010 10:33:56 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -v2 4/5] always lock the root (oldest) anon_vma
Message-ID: <20100513103356.25665186@annuminas.surriel.com>
In-Reply-To: <20100513095439.GA27949@csn.ul.ie>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512134029.36c286c4@annuminas.surriel.com>
	<20100512210216.GP24989@csn.ul.ie>
	<4BEB18BB.5010803@redhat.com>
	<20100513095439.GA27949@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> Looking at the if condition, brk() would appear to be the most important
> case, right? This would appear to correlate with the reasoning behind
> that condition in the first place in commit
> 252c5f94d944487e9f50ece7942b0fbf659c5c31 where sbrk contended on the
> lock heavily.

You are right.  Here is a new patch 4/5:
---------------------

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
v2:
 - conditionally take the anon_vma lock in vma_adjust, like introduced
   in 252c5f94d944487e9f50ece7942b0fbf659c5c31  (with a proper comment)

 include/linux/rmap.h |    8 ++++----
 mm/ksm.c             |    2 +-
 mm/mmap.c            |   16 +++++++++++++++-
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 457ae1e..33ffe14 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -95,24 +95,24 @@ static inline void vma_lock_anon_vma(struct vm_area_struct *vma)
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
diff --git a/mm/ksm.c b/mm/ksm.c
index d488012..7ca0dd7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -325,7 +325,7 @@ static void drop_anon_vma(struct rmap_item *rmap_item)
 {
 	struct anon_vma *anon_vma = rmap_item->anon_vma;
 
-	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->lock)) {
+	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->root->lock)) {
 		int empty = list_empty(&anon_vma->head);
 		anon_vma_unlock(anon_vma);
 		if (empty)
diff --git a/mm/mmap.c b/mm/mmap.c
index f70bc65..a543359 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -506,6 +506,7 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
 	struct prio_tree_root *root = NULL;
+	struct anon_vma *anon_vma = NULL;
 	struct file *file = vma->vm_file;
 	long adjust_next = 0;
 	int remove_next = 0;
@@ -553,6 +554,17 @@ again:			remove_next = 1 + (end > next->vm_end);
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
 	if (file) {
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
@@ -619,6 +631,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
+	if (anon_vma)
+		anon_vma_unlock(anon_vma);
 
 	if (remove_next) {
 		if (file) {
@@ -2471,7 +2485,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_lock_nest_lock(&anon_vma->lock, &mm->mmap_sem);
+		spin_lock_nest_lock(&anon_vma->root->lock, &mm->mmap_sem);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->lock. If some other vma in this mm shares

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
