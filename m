Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 00D146B004D
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 15:10:36 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so799362eaa.14
        for <linux-mm@kvack.org>; Sat, 01 Dec 2012 12:10:35 -0800 (PST)
Date: Sat, 1 Dec 2012 21:10:30 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 1/2] mm/rmap: Convert the struct anon_vma::mutex to an rwsem
Message-ID: <20121201201030.GA2704@gmail.com>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com>
 <20121201122649.GA20322@gmail.com>
 <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com>
 <20121201184135.GA32449@gmail.com>
 <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


Convert the struct anon_vma::mutex to an rwsem, which will help
in solving a page-migration scalability problem. (Addressed in
a separate patch.)

The conversion is simple and straightforward: in every case
where we mutex_lock()ed we'll now down_write().

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/rmap.h |   16 ++++++++--------
 mm/huge_memory.c     |    4 ++--
 mm/mmap.c            |    8 ++++----
 mm/rmap.c            |   22 +++++++++++-----------
 4 files changed, 25 insertions(+), 25 deletions(-)

Index: linux/include/linux/rmap.h
===================================================================
--- linux.orig/include/linux/rmap.h
+++ linux/include/linux/rmap.h
@@ -7,7 +7,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
-#include <linux/mutex.h>
+#include <linux/rwsem.h>
 #include <linux/memcontrol.h>
 
 /*
@@ -25,8 +25,8 @@
  * pointing to this anon_vma once its vma list is empty.
  */
 struct anon_vma {
-	struct anon_vma *root;	/* Root of this anon_vma tree */
-	struct mutex mutex;	/* Serialize access to vma list */
+	struct anon_vma *root;		/* Root of this anon_vma tree */
+	struct rw_semaphore rwsem;	/* W: modification, R: walking the list */
 	/*
 	 * The refcount is taken on an anon_vma when there is no
 	 * guarantee that the vma of page tables will exist for
@@ -64,7 +64,7 @@ struct anon_vma_chain {
 	struct vm_area_struct *vma;
 	struct anon_vma *anon_vma;
 	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
-	struct rb_node rb;			/* locked by anon_vma->mutex */
+	struct rb_node rb;			/* locked by anon_vma->rwsem */
 	unsigned long rb_subtree_last;
 #ifdef CONFIG_DEBUG_VM_RB
 	unsigned long cached_vma_start, cached_vma_last;
@@ -108,24 +108,24 @@ static inline void vma_lock_anon_vma(str
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		mutex_lock(&anon_vma->root->mutex);
+		down_write(&anon_vma->root->rwsem);
 }
 
 static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		mutex_unlock(&anon_vma->root->mutex);
+		up_write(&anon_vma->root->rwsem);
 }
 
 static inline void anon_vma_lock(struct anon_vma *anon_vma)
 {
-	mutex_lock(&anon_vma->root->mutex);
+	down_write(&anon_vma->root->rwsem);
 }
 
 static inline void anon_vma_unlock(struct anon_vma *anon_vma)
 {
-	mutex_unlock(&anon_vma->root->mutex);
+	up_write(&anon_vma->root->rwsem);
 }
 
 /*
Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c
+++ linux/mm/huge_memory.c
@@ -1388,7 +1388,7 @@ static int __split_huge_page_splitting(s
 		 * We can't temporarily set the pmd to null in order
 		 * to split it, the pmd must remain marked huge at all
 		 * times or the VM won't take the pmd_trans_huge paths
-		 * and it won't wait on the anon_vma->root->mutex to
+		 * and it won't wait on the anon_vma->root->rwsem to
 		 * serialize against split_huge_page*.
 		 */
 		pmdp_splitting_flush(vma, address, pmd);
@@ -1591,7 +1591,7 @@ static int __split_huge_page_map(struct
 	return ret;
 }
 
-/* must be called with anon_vma->root->mutex hold */
+/* must be called with anon_vma->root->rwsem held */
 static void __split_huge_page(struct page *page,
 			      struct anon_vma *anon_vma)
 {
Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c
+++ linux/mm/mmap.c
@@ -2561,15 +2561,15 @@ static void vm_lock_anon_vma(struct mm_s
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		mutex_lock_nest_lock(&anon_vma->root->mutex, &mm->mmap_sem);
+		down_write(&anon_vma->root->rwsem);
 		/*
 		 * We can safely modify head.next after taking the
-		 * anon_vma->root->mutex. If some other vma in this mm shares
+		 * anon_vma->root->rwsem. If some other vma in this mm shares
 		 * the same anon_vma we won't take it again.
 		 *
 		 * No need of atomic instructions here, head.next
 		 * can't change from under us thanks to the
-		 * anon_vma->root->mutex.
+		 * anon_vma->root->rwsem.
 		 */
 		if (__test_and_set_bit(0, (unsigned long *)
 				       &anon_vma->root->rb_root.rb_node))
@@ -2671,7 +2671,7 @@ static void vm_unlock_anon_vma(struct an
 		 *
 		 * No need of atomic instructions here, head.next
 		 * can't change from under us until we release the
-		 * anon_vma->root->mutex.
+		 * anon_vma->root->rwsem.
 		 */
 		if (!__test_and_clear_bit(0, (unsigned long *)
 					  &anon_vma->root->rb_root.rb_node))
Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c
+++ linux/mm/rmap.c
@@ -24,7 +24,7 @@
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
  *       mapping->i_mmap_mutex
- *         anon_vma->mutex
+ *         anon_vma->rwsem
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
  *             swap_lock (in swap_duplicate, swap_info_get)
@@ -37,7 +37,7 @@
  *                           in arch-dependent flush_dcache_mmap_lock,
  *                           within bdi.wb->list_lock in __sync_single_inode)
  *
- * anon_vma->mutex,mapping->i_mutex      (memory_failure, collect_procs_anon)
+ * anon_vma->rwsem,mapping->i_mutex      (memory_failure, collect_procs_anon)
  *   ->tasklist_lock
  *     pte map lock
  */
@@ -103,7 +103,7 @@ static inline void anon_vma_free(struct
 	 * LOCK should suffice since the actual taking of the lock must
 	 * happen _before_ what follows.
 	 */
-	if (mutex_is_locked(&anon_vma->root->mutex)) {
+	if (rwsem_is_locked(&anon_vma->root->rwsem)) {
 		anon_vma_lock(anon_vma);
 		anon_vma_unlock(anon_vma);
 	}
@@ -219,9 +219,9 @@ static inline struct anon_vma *lock_anon
 	struct anon_vma *new_root = anon_vma->root;
 	if (new_root != root) {
 		if (WARN_ON_ONCE(root))
-			mutex_unlock(&root->mutex);
+			up_write(&root->rwsem);
 		root = new_root;
-		mutex_lock(&root->mutex);
+		down_write(&root->rwsem);
 	}
 	return root;
 }
@@ -229,7 +229,7 @@ static inline struct anon_vma *lock_anon
 static inline void unlock_anon_vma_root(struct anon_vma *root)
 {
 	if (root)
-		mutex_unlock(&root->mutex);
+		up_write(&root->rwsem);
 }
 
 /*
@@ -349,7 +349,7 @@ void unlink_anon_vmas(struct vm_area_str
 	/*
 	 * Iterate the list once more, it now only contains empty and unlinked
 	 * anon_vmas, destroy them. Could not do before due to __put_anon_vma()
-	 * needing to acquire the anon_vma->root->mutex.
+	 * needing to write-acquire the anon_vma->root->rwsem.
 	 */
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
 		struct anon_vma *anon_vma = avc->anon_vma;
@@ -365,7 +365,7 @@ static void anon_vma_ctor(void *data)
 {
 	struct anon_vma *anon_vma = data;
 
-	mutex_init(&anon_vma->mutex);
+	init_rwsem(&anon_vma->rwsem);
 	atomic_set(&anon_vma->refcount, 0);
 	anon_vma->rb_root = RB_ROOT;
 }
@@ -457,14 +457,14 @@ struct anon_vma *page_lock_anon_vma(stru
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	root_anon_vma = ACCESS_ONCE(anon_vma->root);
-	if (mutex_trylock(&root_anon_vma->mutex)) {
+	if (down_write_trylock(&root_anon_vma->rwsem)) {
 		/*
 		 * If the page is still mapped, then this anon_vma is still
 		 * its anon_vma, and holding the mutex ensures that it will
 		 * not go away, see anon_vma_free().
 		 */
 		if (!page_mapped(page)) {
-			mutex_unlock(&root_anon_vma->mutex);
+			up_write(&root_anon_vma->rwsem);
 			anon_vma = NULL;
 		}
 		goto out;
@@ -1299,7 +1299,7 @@ out_mlock:
 	/*
 	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
 	 * unstable result and race. Plus, We can't wait here because
-	 * we now hold anon_vma->mutex or mapping->i_mmap_mutex.
+	 * we now hold anon_vma->rwsem or mapping->i_mmap_mutex.
 	 * if trylock failed, the page remain in evictable lru and later
 	 * vmscan could retry to move the page to unevictable lru if the
 	 * page is actually mlocked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
