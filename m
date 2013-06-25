Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id CB1506B003B
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:21:50 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 5/5] mm: rename leftover i_mmap_mutex
Date: Mon, 24 Jun 2013 17:21:38 -0700
Message-Id: <1372119698-13147-6-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
References: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, akpm@linux-foundation.org
Cc: walken@google.com, alex.shi@intel.com, tim.c.chen@linux.intel.com, a.p.zijlstra@chello.nl, riel@redhat.com, peter@hurleysoftware.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

Update the lock to i_mmap_rwsem throughout the kernel.
All changes are in comments and documentation.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 Documentation/lockstat.txt   |  2 +-
 Documentation/vm/locking     |  2 +-
 arch/x86/mm/hugetlbpage.c    |  2 +-
 include/linux/mmu_notifier.h |  2 +-
 kernel/events/uprobes.c      |  2 +-
 mm/filemap.c                 | 10 +++++-----
 mm/hugetlb.c                 |  8 ++++----
 mm/mmap.c                    |  6 +++---
 mm/mremap.c                  |  2 +-
 mm/rmap.c                    |  8 ++++----
 10 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/Documentation/lockstat.txt b/Documentation/lockstat.txt
index dd2f7b2..96b8233 100644
--- a/Documentation/lockstat.txt
+++ b/Documentation/lockstat.txt
@@ -168,7 +168,7 @@ View the top contending locks:
                              dcache_lock:          1037           1161           0.38          45.32         774.51           6611         243371           0.15         306.48       77387.24
                          &inode->i_mutex:           161            286 18446744073709       62882.54     1244614.55           3653          20598 18446744073709       62318.60     1693822.74
                          &zone->lru_lock:            94             94           0.53           7.33          92.10           4366          32690           0.29          59.81       16350.06
-              &inode->i_data.i_mmap_mutex:            79             79           0.40           3.77          53.03          11779          87755           0.28         116.93       29898.44
+              &inode->i_data.i_mmap_rwsem:           79             79           0.40           3.77          53.03          11779          87755           0.28         116.93       29898.44
                         &q->__queue_lock:            48             50           0.52          31.62          86.31            774          13131           0.17         113.08       12277.52
                         &rq->rq_lock_key:            43             47           0.74          68.50         170.63           3706          33929           0.22         107.99       17460.62
                       &rq->rq_lock_key#2:            39             46           0.75           6.68          49.03           2979          32292           0.17         125.17       17137.63
diff --git a/Documentation/vm/locking b/Documentation/vm/locking
index f61228b..fb64028 100644
--- a/Documentation/vm/locking
+++ b/Documentation/vm/locking
@@ -66,7 +66,7 @@ in some cases it is not really needed. Eg, vm_start is modified by
 expand_stack(), it is hard to come up with a destructive scenario without 
 having the vmlist protection in this case.
 
-The page_table_lock nests with the inode i_mmap_mutex and the kmem cache
+The page_table_lock nests with the inode i_mmap_rwsem and the kmem cache
 c_spinlock spinlocks.  This is okay, since the kmem code asks for pages after
 dropping c_spinlock.  The page_table_lock also nests with pagecache_lock and
 pagemap_lru_lock spinlocks, and no code asks for memory with these locks
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 9c61a1e..df68d13 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -60,7 +60,7 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
  * and returns the corresponding pte. While this is not necessary for the
  * !shared pmd case because we can allocate the pmd later as well, it makes the
  * code much cleaner. pmd allocation is essential for the shared case because
- * pud has to be populated inside the same i_mmap_mutex section - otherwise
+ * pud has to be populated inside the same i_mmap_rwsem section - otherwise
  * racing tasks could either miss the sharing (see huge_pte_offset) or select a
  * bad pmd for sharing.
  */
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
index c7b9f45..4ca146e 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -700,7 +700,7 @@ build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
 
 		if (!prev && !more) {
 			/*
-			 * Needs GFP_NOWAIT to avoid i_mmap_mutex recursion through
+			 * Needs GFP_NOWAIT to avoid i_mmap_rwsem recursion through
 			 * reclaim. This is optimistic, no harm done if it fails.
 			 */
 			prev = kmalloc(sizeof(struct map_info),
diff --git a/mm/filemap.c b/mm/filemap.c
index 7905fe7..5d3ae93 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -60,16 +60,16 @@
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
@@ -83,7 +83,7 @@
  *    sb_lock			(fs/fs-writeback.c)
  *    ->mapping->tree_lock	(__sync_single_inode)
  *
- *  ->i_mmap_mutex
+ *  ->i_mmap_rwsem
  *    ->anon_vma.lock		(vma_adjust)
  *
  *  ->anon_vma.lock
@@ -103,7 +103,7 @@
  *    ->inode->i_lock		(zap_pte_range->set_page_dirty)
  *    ->private_lock		(zap_pte_range->__set_page_dirty_buffers)
  *
- * ->i_mmap_mutex
+ * ->i_mmap_rwsem
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1becd0a..041f58f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2458,9 +2458,9 @@ void __unmap_hugepage_range_final(struct mmu_gather *tlb,
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
@@ -3067,9 +3067,9 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	}
 	spin_unlock(&mm->page_table_lock);
 	/*
-	 * Must flush TLB before releasing i_mmap_mutex: x86's huge_pmd_unshare
+	 * Must flush TLB before releasing i_mmap_rwsem: x86's huge_pmd_unshare
 	 * may have cleared our pud entry and done put_page on the page table:
-	 * once we release i_mmap_mutex, another task can do the final put_page
+	 * once we release i_mmap_rwsem, another task can do the final put_page
 	 * and that page table be reused and filled with junk.
 	 */
 	flush_tlb_range(vma, start, end);
diff --git a/mm/mmap.c b/mm/mmap.c
index b4e142a..b4ca52a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -205,7 +205,7 @@ error:
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_mutex
+ * Requires inode->i_mapping->i_mmap_rwsem
  */
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
@@ -2759,7 +2759,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
- * then i_mmap_mutex is taken here.
+ * then i_mmap_rwsem is taken here.
  */
 int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
@@ -3043,7 +3043,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
- * taking i_mmap_mutex or anon_vma->rwsem outside the mmap_sem never
+ * taking i_mmap_rwsem or anon_vma->rwsem outside the mmap_sem never
  * takes more than one of them in a row. Secondly we're protected
  * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
  *
diff --git a/mm/mremap.c b/mm/mremap.c
index 02fc5df..742fe28 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -81,7 +81,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	spinlock_t *old_ptl, *new_ptl;
 
 	/*
-	 * When need_rmap_locks is true, we take the i_mmap_mutex and anon_vma
+	 * When need_rmap_locks is true, we take the i_mmap_rwsem and anon_vma
 	 * locks to ensure that rmap will always observe either the old or the
 	 * new ptes. This is the easiest way to avoid races with
 	 * truncate_pagecache(), page migration, etc...
diff --git a/mm/rmap.c b/mm/rmap.c
index 98b986d..1bfde51 100644
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
@@ -804,14 +804,14 @@ static int page_referenced_file(struct page *page,
 	 * The page lock not only makes sure that page->mapping cannot
 	 * suddenly be NULLified by truncation, it makes sure that the
 	 * structure at mapping cannot be freed and reused yet,
-	 * so we can safely take mapping->i_mmap_mutex.
+	 * so we can safely take mapping->i_mmap_rwsem.
 	 */
 	BUG_ON(!PageLocked(page));
 
 	i_mmap_lock_read(mapping);
 
 	/*
-	 * i_mmap_mutex does not stabilize mapcount at all, but mapcount
+	 * i_mmap_rwsem does not stabilize mapcount at all, but mapcount
 	 * is more likely to be accurate if we note it after spinning.
 	 */
 	mapcount = page_mapcount(page);
@@ -1291,7 +1291,7 @@ out_mlock:
 	/*
 	 * We need mmap_sem locking, Otherwise VM_LOCKED check makes
 	 * unstable result and race. Plus, We can't wait here because
-	 * we now hold anon_vma->rwsem or mapping->i_mmap_mutex.
+	 * we now hold anon_vma->rwsem or mapping->i_mmap_rwsem.
 	 * if trylock failed, the page remain in evictable lru and later
 	 * vmscan could retry to move the page to unevictable lru if the
 	 * page is actually mlocked.
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
