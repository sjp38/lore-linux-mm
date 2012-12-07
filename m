Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 5171C6B00DC
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:22 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 49/49] mm/rmap, migration: Make rmap_walk_anon() and try_to_unmap_anon() more scalable
Date: Fri,  7 Dec 2012 10:23:52 +0000
Message-Id: <1354875832-9700-50-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Ingo Molnar <mingo@kernel.org>

rmap_walk_anon() and try_to_unmap_anon() appears to be too
careful about locking the anon vma: while it needs protection
against anon vma list modifications, it does not need exclusive
access to the list itself.

Transforming this exclusive lock to a read-locked rwsem removes
a global lock from the hot path of page-migration intense
threaded workloads which can cause pathological performance like
this:

    96.43%        process 0  [kernel.kallsyms]  [k] perf_trace_sched_switch
                  |
                  --- perf_trace_sched_switch
                      __schedule
                      schedule
                      schedule_preempt_disabled
                      __mutex_lock_common.isra.6
                      __mutex_lock_slowpath
                      mutex_lock
                     |
                     |--50.61%-- rmap_walk
                     |          move_to_new_page
                     |          migrate_pages
                     |          migrate_misplaced_page
                     |          __do_numa_page.isra.69
                     |          handle_pte_fault
                     |          handle_mm_fault
                     |          __do_page_fault
                     |          do_page_fault
                     |          page_fault
                     |          __memset_sse2
                     |          |
                     |           --100.00%-- worker_thread
                     |                     |
                     |                      --100.00%-- start_thread
                     |
                      --49.39%-- page_lock_anon_vma
                                try_to_unmap_anon
                                try_to_unmap
                                migrate_pages
                                migrate_misplaced_page
                                __do_numa_page.isra.69
                                handle_pte_fault
                                handle_mm_fault
                                __do_page_fault
                                do_page_fault
                                page_fault
                                __memset_sse2
                                |
                                 --100.00%-- worker_thread
                                           start_thread

With this change applied the profile is now nicely flat
and there's no anon-vma related scheduling/blocking.

Rename anon_vma_[un]lock() => anon_vma_[un]lock_write(),
to make it clearer that it's an exclusive write-lock in
that case - suggested by Rik van Riel.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Paul Turner <pjt@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/huge_mm.h |    2 +-
 include/linux/rmap.h    |   17 ++++++++++++++---
 mm/huge_memory.c        |    6 +++---
 mm/ksm.c                |    6 +++---
 mm/memory-failure.c     |    4 ++--
 mm/migrate.c            |    2 +-
 mm/mmap.c               |    2 +-
 mm/mremap.c             |    2 +-
 mm/rmap.c               |   48 +++++++++++++++++++++++------------------------
 9 files changed, 50 insertions(+), 39 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 027ad04..0d1208c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -102,7 +102,7 @@ extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
 #define wait_split_huge_page(__anon_vma, __pmd)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
-		anon_vma_lock(__anon_vma);				\
+		anon_vma_lock_write(__anon_vma);			\
 		anon_vma_unlock(__anon_vma);				\
 		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
 		       pmd_trans_huge(*____pmd));			\
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index f3f41d2..c20635c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -118,7 +118,7 @@ static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
 		up_write(&anon_vma->root->rwsem);
 }
 
-static inline void anon_vma_lock(struct anon_vma *anon_vma)
+static inline void anon_vma_lock_write(struct anon_vma *anon_vma)
 {
 	down_write(&anon_vma->root->rwsem);
 }
@@ -128,6 +128,17 @@ static inline void anon_vma_unlock(struct anon_vma *anon_vma)
 	up_write(&anon_vma->root->rwsem);
 }
 
+static inline void anon_vma_lock_read(struct anon_vma *anon_vma)
+{
+	down_read(&anon_vma->root->rwsem);
+}
+
+static inline void anon_vma_unlock_read(struct anon_vma *anon_vma)
+{
+	up_read(&anon_vma->root->rwsem);
+}
+
+
 /*
  * anon_vma helper functions.
  */
@@ -220,8 +231,8 @@ int try_to_munlock(struct page *);
 /*
  * Called by memory-failure.c to kill processes.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page);
-void page_unlock_anon_vma(struct anon_vma *anon_vma);
+struct anon_vma *page_lock_anon_vma_read(struct page *page);
+void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f0c4928..409b2f3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1548,7 +1548,7 @@ int split_huge_page(struct page *page)
 	int ret = 1;
 
 	BUG_ON(!PageAnon(page));
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma_read(page);
 	if (!anon_vma)
 		goto out;
 	ret = 0;
@@ -1561,7 +1561,7 @@ int split_huge_page(struct page *page)
 
 	BUG_ON(PageCompound(page));
 out_unlock:
-	page_unlock_anon_vma(anon_vma);
+	page_unlock_anon_vma_read(anon_vma);
 out:
 	return ret;
 }
@@ -2073,7 +2073,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!pmd_present(*pmd) || pmd_trans_huge(*pmd))
 		goto out;
 
-	anon_vma_lock(vma->anon_vma);
+	anon_vma_lock_write(vma->anon_vma);
 
 	pte = pte_offset_map(pmd, address);
 	ptl = pte_lockptr(mm, pmd);
diff --git a/mm/ksm.c b/mm/ksm.c
index ae539f0..7fa37de 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1634,7 +1634,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		anon_vma_lock(anon_vma);
+		anon_vma_lock_write(anon_vma);
 		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
 					       0, ULONG_MAX) {
 			vma = vmac->vma;
@@ -1688,7 +1688,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		anon_vma_lock(anon_vma);
+		anon_vma_lock_write(anon_vma);
 		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
 					       0, ULONG_MAX) {
 			vma = vmac->vma;
@@ -1741,7 +1741,7 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
-		anon_vma_lock(anon_vma);
+		anon_vma_lock_write(anon_vma);
 		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
 					       0, ULONG_MAX) {
 			vma = vmac->vma;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ddb68a1..f2cd830 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -402,7 +402,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	struct anon_vma *av;
 	pgoff_t pgoff;
 
-	av = page_lock_anon_vma(page);
+	av = page_lock_anon_vma_read(page);
 	if (av == NULL)	/* Not actually mapped anymore */
 		return;
 
@@ -423,7 +423,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 		}
 	}
 	read_unlock(&tasklist_lock);
-	page_unlock_anon_vma(av);
+	page_unlock_anon_vma_read(av);
 }
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index 6b6567f..da2001b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -754,7 +754,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 */
 	if (PageAnon(page)) {
 		/*
-		 * Only page_lock_anon_vma() understands the subtleties of
+		 * Only page_lock_anon_vma_read() understands the subtleties of
 		 * getting a hold on an anon_vma from outside one of its mms.
 		 */
 		anon_vma = page_get_anon_vma(page);
diff --git a/mm/mmap.c b/mm/mmap.c
index 8840863..68a16b4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -602,7 +602,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (anon_vma) {
 		VM_BUG_ON(adjust_next && next->anon_vma &&
 			  anon_vma != next->anon_vma);
-		anon_vma_lock(anon_vma);
+		anon_vma_lock_write(anon_vma);
 		anon_vma_interval_tree_pre_update_vma(vma);
 		if (adjust_next)
 			anon_vma_interval_tree_pre_update_vma(next);
diff --git a/mm/mremap.c b/mm/mremap.c
index 1b61c2d..3dabd17 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -104,7 +104,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		}
 		if (vma->anon_vma) {
 			anon_vma = vma->anon_vma;
-			anon_vma_lock(anon_vma);
+			anon_vma_lock_write(anon_vma);
 		}
 	}
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 6e3ee3b..b0f612d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -87,24 +87,24 @@ static inline void anon_vma_free(struct anon_vma *anon_vma)
 	VM_BUG_ON(atomic_read(&anon_vma->refcount));
 
 	/*
-	 * Synchronize against page_lock_anon_vma() such that
+	 * Synchronize against page_lock_anon_vma_read() such that
 	 * we can safely hold the lock without the anon_vma getting
 	 * freed.
 	 *
 	 * Relies on the full mb implied by the atomic_dec_and_test() from
 	 * put_anon_vma() against the acquire barrier implied by
-	 * mutex_trylock() from page_lock_anon_vma(). This orders:
+	 * down_read_trylock() from page_lock_anon_vma_read(). This orders:
 	 *
-	 * page_lock_anon_vma()		VS	put_anon_vma()
-	 *   mutex_trylock()			  atomic_dec_and_test()
+	 * page_lock_anon_vma_read()	VS	put_anon_vma()
+	 *   down_read_trylock()		  atomic_dec_and_test()
 	 *   LOCK				  MB
-	 *   atomic_read()			  mutex_is_locked()
+	 *   atomic_read()			  rwsem_is_locked()
 	 *
 	 * LOCK should suffice since the actual taking of the lock must
 	 * happen _before_ what follows.
 	 */
 	if (rwsem_is_locked(&anon_vma->root->rwsem)) {
-		anon_vma_lock(anon_vma);
+		anon_vma_lock_write(anon_vma);
 		anon_vma_unlock(anon_vma);
 	}
 
@@ -146,7 +146,7 @@ static void anon_vma_chain_link(struct vm_area_struct *vma,
  * allocate a new one.
  *
  * Anon-vma allocations are very subtle, because we may have
- * optimistically looked up an anon_vma in page_lock_anon_vma()
+ * optimistically looked up an anon_vma in page_lock_anon_vma_read()
  * and that may actually touch the spinlock even in the newly
  * allocated vma (it depends on RCU to make sure that the
  * anon_vma isn't actually destroyed).
@@ -181,7 +181,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 			allocated = anon_vma;
 		}
 
-		anon_vma_lock(anon_vma);
+		anon_vma_lock_write(anon_vma);
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
@@ -306,7 +306,7 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	get_anon_vma(anon_vma->root);
 	/* Mark this anon_vma as the one where our new (COWed) pages go. */
 	vma->anon_vma = anon_vma;
-	anon_vma_lock(anon_vma);
+	anon_vma_lock_write(anon_vma);
 	anon_vma_chain_link(vma, avc, anon_vma);
 	anon_vma_unlock(anon_vma);
 
@@ -442,7 +442,7 @@ out:
  * atomic op -- the trylock. If we fail the trylock, we fall back to getting a
  * reference like with page_get_anon_vma() and then block on the mutex.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma_read(struct page *page)
 {
 	struct anon_vma *anon_vma = NULL;
 	struct anon_vma *root_anon_vma;
@@ -457,14 +457,14 @@ struct anon_vma *page_lock_anon_vma(struct page *page)
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	root_anon_vma = ACCESS_ONCE(anon_vma->root);
-	if (down_write_trylock(&root_anon_vma->rwsem)) {
+	if (down_read_trylock(&root_anon_vma->rwsem)) {
 		/*
 		 * If the page is still mapped, then this anon_vma is still
 		 * its anon_vma, and holding the mutex ensures that it will
 		 * not go away, see anon_vma_free().
 		 */
 		if (!page_mapped(page)) {
-			up_write(&root_anon_vma->rwsem);
+			up_read(&root_anon_vma->rwsem);
 			anon_vma = NULL;
 		}
 		goto out;
@@ -484,15 +484,15 @@ struct anon_vma *page_lock_anon_vma(struct page *page)
 
 	/* we pinned the anon_vma, its safe to sleep */
 	rcu_read_unlock();
-	anon_vma_lock(anon_vma);
+	anon_vma_lock_read(anon_vma);
 
 	if (atomic_dec_and_test(&anon_vma->refcount)) {
 		/*
 		 * Oops, we held the last refcount, release the lock
 		 * and bail -- can't simply use put_anon_vma() because
-		 * we'll deadlock on the anon_vma_lock() recursion.
+		 * we'll deadlock on the anon_vma_lock_write() recursion.
 		 */
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_read(anon_vma);
 		__put_anon_vma(anon_vma);
 		anon_vma = NULL;
 	}
@@ -504,9 +504,9 @@ out:
 	return anon_vma;
 }
 
-void page_unlock_anon_vma(struct anon_vma *anon_vma)
+void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
 {
-	anon_vma_unlock(anon_vma);
+	anon_vma_unlock_read(anon_vma);
 }
 
 /*
@@ -732,7 +732,7 @@ static int page_referenced_anon(struct page *page,
 	struct anon_vma_chain *avc;
 	int referenced = 0;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma_read(page);
 	if (!anon_vma)
 		return referenced;
 
@@ -754,7 +754,7 @@ static int page_referenced_anon(struct page *page,
 			break;
 	}
 
-	page_unlock_anon_vma(anon_vma);
+	page_unlock_anon_vma_read(anon_vma);
 	return referenced;
 }
 
@@ -1474,7 +1474,7 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma_read(page);
 	if (!anon_vma)
 		return ret;
 
@@ -1501,7 +1501,7 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 			break;
 	}
 
-	page_unlock_anon_vma(anon_vma);
+	page_unlock_anon_vma_read(anon_vma);
 	return ret;
 }
 
@@ -1696,7 +1696,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	int ret = SWAP_AGAIN;
 
 	/*
-	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma()
+	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma_read()
 	 * because that depends on page_mapped(); but not all its usages
 	 * are holding mmap_sem. Users without mmap_sem are required to
 	 * take a reference count to prevent the anon_vma disappearing
@@ -1704,7 +1704,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	anon_vma = page_anon_vma(page);
 	if (!anon_vma)
 		return ret;
-	anon_vma_lock(anon_vma);
+	anon_vma_lock_read(anon_vma);
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
@@ -1712,7 +1712,7 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 		if (ret != SWAP_AGAIN)
 			break;
 	}
-	anon_vma_unlock(anon_vma);
+	anon_vma_unlock_read(anon_vma);
 	return ret;
 }
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
