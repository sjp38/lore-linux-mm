Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 821D06B00D9
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:20 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 48/49] mm/rmap: Convert the struct anon_vma::mutex to an rwsem
Date: Fri,  7 Dec 2012 10:23:51 +0000
Message-Id: <1354875832-9700-49-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Ingo Molnar <mingo@kernel.org>

Convert the struct anon_vma::mutex to an rwsem, which will help
in solving a page-migration scalability problem. (Addressed in
a separate patch.)

The conversion is simple and straightforward: in every case
where we mutex_lock()ed we'll now down_write().

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Paul Turner <pjt@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/rmap.h |   16 ++++++++--------
 mm/huge_memory.c     |    4 ++--
 mm/mmap.c            |    8 ++++----
 mm/rmap.c            |   22 +++++++++++-----------
 4 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bfe1f47..f3f41d2 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
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
@@ -108,24 +108,24 @@ static inline void vma_lock_anon_vma(struct vm_area_struct *vma)
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
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 61b66f8..f0c4928 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1291,7 +1291,7 @@ static int __split_huge_page_splitting(struct page *page,
 		 * We can't temporarily set the pmd to null in order
 		 * to split it, the pmd must remain marked huge at all
 		 * times or the VM won't take the pmd_trans_huge paths
-		 * and it won't wait on the anon_vma->root->mutex to
+		 * and it won't wait on the anon_vma->root->rwsem to
 		 * serialize against split_huge_page*.
 		 */
 		pmdp_splitting_flush(vma, address, pmd);
@@ -1494,7 +1494,7 @@ static int __split_huge_page_map(struct page *page,
 	return ret;
 }
 
-/* must be called with anon_vma->root->mutex hold */
+/* must be called with anon_vma->root->rwsem held */
 static void __split_huge_page(struct page *page,
 			      struct anon_vma *anon_vma)
 {
diff --git a/mm/mmap.c b/mm/mmap.c
index 9a796c4..8840863 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2561,15 +2561,15 @@ static void vm_lock_anon_vma(struct mm_struct *mm, struct anon_vma *anon_vma)
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
@@ -2671,7 +2671,7 @@ static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
 		 *
 		 * No need of atomic instructions here, head.next
 		 * can't change from under us until we release the
-		 * anon_vma->root->mutex.
+		 * anon_vma->root->rwsem.
 		 */
 		if (!__test_and_clear_bit(0, (unsigned long *)
 					  &anon_vma->root->rb_root.rb_node))
diff --git a/mm/rmap.c b/mm/rmap.c
index 2ee1ef0..6e3ee3b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
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
@@ -103,7 +103,7 @@ static inline void anon_vma_free(struct anon_vma *anon_vma)
 	 * LOCK should suffice since the actual taking of the lock must
 	 * happen _before_ what follows.
 	 */
-	if (mutex_is_locked(&anon_vma->root->mutex)) {
+	if (rwsem_is_locked(&anon_vma->root->rwsem)) {
 		anon_vma_lock(anon_vma);
 		anon_vma_unlock(anon_vma);
 	}
@@ -219,9 +219,9 @@ static inline struct anon_vma *lock_anon_vma_root(struct anon_vma *root, struct
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
@@ -229,7 +229,7 @@ static inline struct anon_vma *lock_anon_vma_root(struct anon_vma *root, struct
 static inline void unlock_anon_vma_root(struct anon_vma *root)
 {
 	if (root)
-		mutex_unlock(&root->mutex);
+		up_write(&root->rwsem);
 }
 
 /*
@@ -349,7 +349,7 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
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
@@ -457,14 +457,14 @@ struct anon_vma *page_lock_anon_vma(struct page *page)
 
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
