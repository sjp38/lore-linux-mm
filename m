Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8A3316B01F4
	for <linux-mm@kvack.org>; Wed, 12 May 2010 13:42:04 -0400 (EDT)
Date: Wed, 12 May 2010 13:40:29 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH 4/5] always lock the root (oldest) anon_vma
Message-ID: <20100512134029.36c286c4@annuminas.surriel.com>
In-Reply-To: <20100512133815.0d048a86@annuminas.surriel.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
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
 include/linux/rmap.h |    8 ++++----
 mm/ksm.c             |    2 +-
 mm/mmap.c            |    6 +++++-
 3 files changed, 10 insertions(+), 6 deletions(-)

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
index f70bc65..b7dfe30 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -553,6 +553,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	vma_lock_anon_vma(vma);
+
 	if (file) {
 		mapping = file->f_mapping;
 		if (!(vma->vm_flags & VM_NONLINEAR))
@@ -600,6 +602,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		flush_dcache_mmap_unlock(mapping);
 	}
 
+	vma_unlock_anon_vma(vma);
+
 	if (remove_next) {
 		/*
 		 * vma_merge has merged next into vma, and needs
@@ -2471,7 +2475,7 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
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
