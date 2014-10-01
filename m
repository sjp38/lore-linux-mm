Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B40F36B006E
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 07:32:16 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so98210pdj.27
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 04:32:16 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qa2si672277pbc.40.2014.10.01.04.32.14
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 04:32:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/3] mm: use VM_BUG_ON() instead of VM_BUG_ON_VMA() and VM_BUG_ON_MM()
Date: Wed,  1 Oct 2014 14:32:01 +0300
Message-Id: <1412163121-4295-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1412163121-4295-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Convert VM_BUG_ON_VMA() and VM_BUG_ON_MM() to new VM_BUG_ON(). Dump more
than one data structure where is appropriate.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |  2 +-
 include/linux/mmdebug.h |  4 ----
 include/linux/rmap.h    |  2 +-
 kernel/fork.c           |  2 +-
 kernel/sys.c            |  2 +-
 mm/huge_memory.c        |  8 ++++----
 mm/hugetlb.c            | 14 +++++++-------
 mm/interval_tree.c      |  2 +-
 mm/mlock.c              |  6 +++---
 mm/mmap.c               |  8 ++++----
 mm/mremap.c             |  3 +--
 mm/pagewalk.c           |  2 +-
 mm/rmap.c               |  8 ++++----
 13 files changed, 29 insertions(+), 34 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ad9051bab267..f64e57260d2e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -132,7 +132,7 @@ extern int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
-	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
+	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
 	if (pmd_trans_huge(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma, ptl);
 	else
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 816cbd050ea9..41e0fb8a1522 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -60,15 +60,11 @@ void dump_mm(const struct mm_struct *mm);
 		_VM_BUG_ON_ARG2,					\
 		_VM_BUG_ON_ARG1,					\
 		BUG_ON)(__VA_ARGS__)
-#define VM_BUG_ON_VMA VM_BUG_ON
-#define VM_BUG_ON_MM VM_BUG_ON
 #define VM_WARN_ON(cond) WARN_ON(cond)
 #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
 #else
 #define VM_BUG_ON(cond, ...) BUILD_BUG_ON_INVALID(cond)
-#define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
-#define VM_BUG_ON_MM(cond, mm) VM_BUG_ON(cond)
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index c0c2bce6b0b7..3c90d656175c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -150,7 +150,7 @@ int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 static inline void anon_vma_merge(struct vm_area_struct *vma,
 				  struct vm_area_struct *next)
 {
-	VM_BUG_ON_VMA(vma->anon_vma != next->anon_vma, vma);
+	VM_BUG_ON(vma->anon_vma != next->anon_vma, vma, next);
 	unlink_anon_vmas(next);
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 807633f6074a..39d1db54ec5a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -608,7 +608,7 @@ static void check_mm(struct mm_struct *mm)
 					  "mm:%p idx:%d val:%ld\n", mm, i, x);
 	}
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
-	VM_BUG_ON_MM(mm->pmd_huge_pte, mm);
+	VM_BUG_ON(mm->pmd_huge_pte, mm);
 #endif
 }
 
diff --git a/kernel/sys.c b/kernel/sys.c
index 1eaa2f0b0246..48e8e05b88da 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1640,7 +1640,7 @@ static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
 	struct inode *inode;
 	int err;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem), mm);
 
 	exe = fdget(fd);
 	if (!exe.file)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 83e881610f96..1e540b2cdcd4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1096,7 +1096,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	ptl = pmd_lockptr(mm, pmd);
-	VM_BUG_ON_VMA(!vma->anon_vma, vma);
+	VM_BUG_ON(!vma->anon_vma, vma);
 	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
@@ -2045,7 +2045,7 @@ int __khugepaged_enter(struct mm_struct *mm)
 		return -ENOMEM;
 
 	/* __khugepaged_exit() must not run from under us */
-	VM_BUG_ON_MM(khugepaged_test_exit(mm), mm);
+	VM_BUG_ON(khugepaged_test_exit(mm), mm);
 	if (unlikely(test_and_set_bit(MMF_VM_HUGEPAGE, &mm->flags))) {
 		free_mm_slot(mm_slot);
 		return 0;
@@ -2080,7 +2080,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
+	VM_BUG_ON(vma->vm_flags & VM_NO_THP, vma);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -2403,7 +2403,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
-	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
+	VM_BUG_ON(vma->vm_flags & VM_NO_THP, vma);
 	return true;
 }
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f537e7d1ac92..3ba97ce6bd08 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -434,7 +434,7 @@ static inline struct resv_map *inode_resv_map(struct inode *inode)
 
 static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG_ON(!is_vm_hugetlb_page(vma), vma);
 	if (vma->vm_flags & VM_MAYSHARE) {
 		struct address_space *mapping = vma->vm_file->f_mapping;
 		struct inode *inode = mapping->host;
@@ -449,8 +449,8 @@ static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 
 static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
-	VM_BUG_ON_VMA(vma->vm_flags & VM_MAYSHARE, vma);
+	VM_BUG_ON(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE, vma);
 
 	set_vma_private_data(vma, (get_vma_private_data(vma) &
 				HPAGE_RESV_MASK) | (unsigned long)map);
@@ -458,15 +458,15 @@ static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 
 static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
-	VM_BUG_ON_VMA(vma->vm_flags & VM_MAYSHARE, vma);
+	VM_BUG_ON(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE, vma);
 
 	set_vma_private_data(vma, get_vma_private_data(vma) | flags);
 }
 
 static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG_ON(!is_vm_hugetlb_page(vma), vma);
 
 	return (get_vma_private_data(vma) & flag) != 0;
 }
@@ -474,7 +474,7 @@ static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 /* Reset counters to 0 and clear all HPAGE_RESV_* flags */
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
-	VM_BUG_ON_VMA(!is_vm_hugetlb_page(vma), vma);
+	VM_BUG_ON(!is_vm_hugetlb_page(vma), vma);
 	if (!(vma->vm_flags & VM_MAYSHARE))
 		vma->vm_private_data = (void *)0;
 }
diff --git a/mm/interval_tree.c b/mm/interval_tree.c
index 8da581fa9060..d185a2a51b83 100644
--- a/mm/interval_tree.c
+++ b/mm/interval_tree.c
@@ -34,7 +34,7 @@ void vma_interval_tree_insert_after(struct vm_area_struct *node,
 	struct vm_area_struct *parent;
 	unsigned long last = vma_last_pgoff(node);
 
-	VM_BUG_ON_VMA(vma_start_pgoff(node) != vma_start_pgoff(prev), node);
+	VM_BUG_ON(vma_start_pgoff(node) != vma_start_pgoff(prev), node, prev);
 
 	if (!prev->shared.linear.rb.rb_right) {
 		parent = prev;
diff --git a/mm/mlock.c b/mm/mlock.c
index af98bc02e164..a48f1628347d 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -233,9 +233,9 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
-	VM_BUG_ON_VMA(start < vma->vm_start, vma);
-	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+	VM_BUG_ON(start < vma->vm_start, vma);
+	VM_BUG_ON(end   > vma->vm_end, vma);
+	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem), mm, vma);
 
 	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
 	/*
diff --git a/mm/mmap.c b/mm/mmap.c
index 915661293af9..f9692eeedea5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -429,7 +429,7 @@ static void validate_mm_rb(struct rb_root *root, struct vm_area_struct *ignore)
 	for (nd = rb_first(root); nd; nd = rb_next(nd)) {
 		struct vm_area_struct *vma;
 		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
-		VM_BUG_ON_VMA(vma != ignore &&
+		VM_BUG_ON(vma != ignore &&
 			vma->rb_subtree_gap != vma_compute_subtree_gap(vma),
 			vma);
 	}
@@ -468,7 +468,7 @@ static void validate_mm(struct mm_struct *mm)
 			pr_emerg("map_count %d rb %d\n", mm->map_count, i);
 		bug = 1;
 	}
-	VM_BUG_ON_MM(bug, mm);
+	VM_BUG_ON(bug, mm);
 }
 #else
 #define validate_mm_rb(root, ignore) do { } while (0)
@@ -811,7 +811,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (!anon_vma && adjust_next)
 		anon_vma = next->anon_vma;
 	if (anon_vma) {
-		VM_BUG_ON_VMA(adjust_next && next->anon_vma &&
+		VM_BUG_ON(adjust_next && next->anon_vma &&
 			  anon_vma != next->anon_vma, next);
 		anon_vma_lock_write(anon_vma);
 		anon_vma_interval_tree_pre_update_vma(vma);
@@ -2934,7 +2934,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			 * safe. It is only safe to keep the vm_pgoff
 			 * linear if there are no pages mapped yet.
 			 */
-			VM_BUG_ON_VMA(faulted_in_anon_vma, new_vma);
+			VM_BUG_ON(faulted_in_anon_vma, new_vma);
 			*vmap = vma = new_vma;
 		}
 		*need_rmap_locks = (new_vma->vm_pgoff <= vma->vm_pgoff);
diff --git a/mm/mremap.c b/mm/mremap.c
index 2fbf5e30eab9..0ae195c72f27 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -195,8 +195,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 		if (pmd_trans_huge(*old_pmd)) {
 			int err = 0;
 			if (extent == HPAGE_PMD_SIZE) {
-				VM_BUG_ON_VMA(vma->vm_file || !vma->anon_vma,
-					      vma);
+				VM_BUG_ON(vma->vm_file || !vma->anon_vma, vma);
 				/* See comment in move_ptes() */
 				if (need_rmap_locks)
 					anon_vma_lock_write(vma->anon_vma);
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index ad83195521f2..cdd53f41bdc2 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -177,7 +177,7 @@ int walk_page_range(unsigned long addr, unsigned long end,
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
+	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
 
 	pgd = pgd_offset(walk->mm, addr);
 	do {
diff --git a/mm/rmap.c b/mm/rmap.c
index cc9cf848472c..9d316fdd0404 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -527,7 +527,7 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 	unsigned long address = __vma_address(page, vma);
 
 	/* page should be within @vma mapping range */
-	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end, vma, page);
 
 	return address;
 }
@@ -897,8 +897,8 @@ void page_move_anon_rmap(struct page *page,
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	VM_BUG_ON(!PageLocked(page), page);
-	VM_BUG_ON_VMA(!anon_vma, vma);
-	VM_BUG_ON(page->index != linear_page_index(vma, address), page);
+	VM_BUG_ON(!anon_vma, vma, page);
+	VM_BUG_ON(page->index != linear_page_index(vma, address), vma, page);
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	page->mapping = (struct address_space *) anon_vma;
@@ -1024,7 +1024,7 @@ void do_page_add_anon_rmap(struct page *page,
 void page_add_new_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
-	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
+	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end, vma, page);
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (PageTransHuge(page))
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
