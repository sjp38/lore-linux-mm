Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8058A6B003D
	for <linux-mm@kvack.org>; Thu, 22 May 2014 23:33:49 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id i7so5060143oag.6
        for <linux-mm@kvack.org>; Thu, 22 May 2014 20:33:49 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id rt10si2182284obb.61.2014.05.22.20.33.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 20:33:49 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 5/5] mm: rename leftover i_mmap_mutex
Date: Thu, 22 May 2014 20:33:26 -0700
Message-Id: <1400816006-3083-6-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, davidlohr@hp.com, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Update the lock to i_mmap_rwsem throughout the kernel.
All changes are in comments and documentation.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/mmu_notifier.h |  2 +-
 kernel/events/uprobes.c      |  2 +-
 mm/filemap.c                 | 10 +++++-----
 mm/hugetlb.c                 | 10 +++++-----
 mm/mremap.c                  |  2 +-
 mm/rmap.c                    |  6 +++---
 6 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca874..f9c11ab 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -151,7 +151,7 @@ struct mmu_notifier_ops {
  * Therefore notifier chains can only be traversed when either
  *
  * 1. mmap_sem is held.
- * 2. One of the reverse map locks is held (i_mmap_mutex or anon_vma->rwsem).
+ * 2. One of the reverse map locks is held (i_mmap_rwsem or anon_vma->rwsem).
  * 3. No other concurrent thread can access the list (release)
  */
 struct mmu_notifier {
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index ccf793c..e809554 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -729,7 +729,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 
 		if (!prev && !more) {
 			/*
-			 * Needs GFP_NOWAIT to avoid i_mmap_mutex recursion through
+			 * Needs GFP_NOWAIT to avoid i_mmap_rwsem recursion through
 			 * reclaim. This is optimistic, no harm done if it fails.
 			 */
 			prev = kmalloc(sizeof(struct map_info),
diff --git a/mm/filemap.c b/mm/filemap.c
index 263cffe..aadf613 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -61,16 +61,16 @@
 /*
  * Lock ordering:
  *
- *  ->i_mmap_mutex		(truncate_pagecache)
+ *  ->i_mmap_rwsem		(truncate_pagecache)
  *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
  *
  *  ->i_mutex
- *    ->i_mmap_mutex		(truncate->unmap_mapping_range)
+ *    ->i_mmap_rwsem		(truncate->unmap_mapping_range)
  *
  *  ->mmap_sem
- *    ->i_mmap_mutex
+ *    ->i_mmap_rwsem
  *      ->page_table_lock or pte_lock	(various, mainly in memory.c)
  *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
  *
@@ -84,7 +84,7 @@
  *    sb_lock			(fs/fs-writeback.c)
  *    ->mapping->tree_lock	(__sync_single_inode)
  *
- *  ->i_mmap_mutex
+ *  ->i_mmap_rwsem
  *    ->anon_vma.lock		(vma_adjust)
  *
  *  ->anon_vma.lock
@@ -104,7 +104,7 @@
  *    ->inode->i_lock		(zap_pte_range->set_page_dirty)
  *    ->private_lock		(zap_pte_range->__set_page_dirty_buffers)
  *
- * ->i_mmap_mutex
+ * ->i_mmap_rwsem
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 161f98d..3ab3ffd 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2713,9 +2713,9 @@ void __unmap_hugepage_range_final(struct mmu_gather *tlb,
 	 * on its way out.  We're lucky that the flag has such an appropriate
 	 * name, and can in fact be safely cleared here. We could clear it
 	 * before the __unmap_hugepage_range above, but all that's necessary
-	 * is to clear it before releasing the i_mmap_mutex. This works
+	 * is to clear it before releasing the i_mmap_rwsem. This works
 	 * because in the context this is called, the VMA is about to be
-	 * destroyed and the i_mmap_mutex is held.
+	 * destroyed and the i_mmap_rwsem is held.
 	 */
 	vma->vm_flags &= ~VM_MAYSHARE;
 }
@@ -3364,9 +3364,9 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		spin_unlock(ptl);
 	}
 	/*
-	 * Must flush TLB before releasing i_mmap_mutex: x86's huge_pmd_unshare
+	 * Must flush TLB before releasing i_mmap_rwsem: x86's huge_pmd_unshare
 	 * may have cleared our pud entry and done put_page on the page table:
-	 * once we release i_mmap_mutex, another task can do the final put_page
+	 * once we release i_mmap_rwsem, another task can do the final put_page
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_tlb_range(vma, start, end);
@@ -3519,7 +3519,7 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
  * and returns the corresponding pte. While this is not necessary for the
  * !shared pmd case because we can allocate the pmd later as well, it makes the
  * code much cleaner. pmd allocation is essential for the shared case because
- * pud has to be populated inside the same i_mmap_mutex section - otherwise
+ * pud has to be populated inside the same i_mmap_rwsem section - otherwise
  * racing tasks could either miss the sharing (see huge_pte_offset) or select a
  * bad pmd for sharing.
  */
diff --git a/mm/mremap.c b/mm/mremap.c
index 60259a2..3f4e487 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -99,7 +99,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	spinlock_t *old_ptl, *new_ptl;
 
 	/*
-	 * When need_rmap_locks is true, we take the i_mmap_mutex and anon_vma
+	 * When need_rmap_locks is true, we take the i_mmap_rwsem and anon_vma
 	 * locks to ensure that rmap will always observe either the old or the
 	 * new ptes. This is the easiest way to avoid races with
 	 * truncate_pagecache(), page migration, etc...
diff --git a/mm/rmap.c b/mm/rmap.c
index 5841dcb..56346c9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -23,7 +23,7 @@
  * inode->i_mutex	(while writing or truncating, not reading or faulting)
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
- *       mapping->i_mmap_mutex
+ *       mapping->i_mmap_rwsem
  *         anon_vma->rwsem
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
@@ -1258,7 +1258,7 @@ out_mlock:
 	/*
 	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
 	 * unstable result and race. Plus, We can't wait here because
-	 * we now hold anon_vma->rwsem or mapping->i_mmap_mutex.
+	 * we now hold anon_vma->rwsem or mapping->i_mmap_rwsem.
 	 * if trylock failed, the page remain in evictable lru and later
 	 * vmscan could retry to move the page to unevictable lru if the
 	 * page is actually mlocked.
@@ -1679,7 +1679,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	 * The page lock not only makes sure that page->mapping cannot
 	 * suddenly be NULLified by truncation, it makes sure that the
 	 * structure at mapping cannot be freed and reused yet,
-	 * so we can safely take mapping->i_mmap_mutex.
+	 * so we can safely take mapping->i_mmap_rwsem.
 	 */
 	VM_BUG_ON(!PageLocked(page));
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
