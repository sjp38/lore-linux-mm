Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id AF7B682998
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:38:12 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so8579043pab.28
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:38:12 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vw5si12102222pab.333.2014.05.06.07.38.11
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 07:38:11 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 7/8] mm: kill VM_NONLINEAR and FAULT_FLAG_NONLINEAR
Date: Tue,  6 May 2014 17:37:31 +0300
Message-Id: <1399387052-31660-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Nobody creates nonlinear VMAs. No need to support them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/gpu/drm/drm_vma_manager.c |  3 +--
 fs/proc/task_mmu.c                |  5 -----
 include/linux/mm.h                |  2 --
 mm/ksm.c                          |  2 +-
 mm/madvise.c                      |  2 +-
 mm/memory.c                       | 40 +++++++--------------------------------
 mm/mmap.c                         | 11 ++++-------
 mm/rmap.c                         |  5 ++---
 8 files changed, 16 insertions(+), 54 deletions(-)

diff --git a/drivers/gpu/drm/drm_vma_manager.c b/drivers/gpu/drm/drm_vma_manager.c
index 63b471205072..68c1f32fb086 100644
--- a/drivers/gpu/drm/drm_vma_manager.c
+++ b/drivers/gpu/drm/drm_vma_manager.c
@@ -50,8 +50,7 @@
  *
  * You must not use multiple offset managers on a single address_space.
  * Otherwise, mm-core will be unable to tear down memory mappings as the VM will
- * no longer be linear. Please use VM_NONLINEAR in that case and implement your
- * own offset managers.
+ * no longer be linear.
  *
  * This offset manager works on page-based addresses. That is, every argument
  * and return code (with the exception of drm_vma_node_offset_addr()) is given
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 442177b1119a..1a2d7d3bea28 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -552,7 +552,6 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_ACCOUNT)]	= "ac",
 		[ilog2(VM_NORESERVE)]	= "nr",
 		[ilog2(VM_HUGETLB)]	= "ht",
-		[ilog2(VM_NONLINEAR)]	= "nl",
 		[ilog2(VM_ARCH_1)]	= "ar",
 		[ilog2(VM_DONTDUMP)]	= "dd",
 #ifdef CONFIG_MEM_SOFT_DIRTY
@@ -626,10 +625,6 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   (vma->vm_flags & VM_LOCKED) ?
 			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
 
-	if (vma->vm_flags & VM_NONLINEAR)
-		seq_printf(m, "Nonlinear:      %8lu kB\n",
-				mss.nonlinear >> 10);
-
 	show_smap_vma_flags(m, vma);
 
 	if (m->count < m->size)  /* vma is copied successfully */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d8dc4cd58704..2c9f3288a14a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -125,7 +125,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
-#define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
 
@@ -187,7 +186,6 @@ extern unsigned int kobjsize(const void *objp);
 extern pgprot_t protection_map[16];
 
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
-#define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
 #define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
diff --git a/mm/ksm.c b/mm/ksm.c
index 68710e80994a..48ddff33810b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1749,7 +1749,7 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		 */
 		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
 				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP))
+				 VM_HUGETLB | VM_MIXEDMAP))
 			return 0;		/* just ignore the advice */
 
 #ifdef VM_SAO
diff --git a/mm/madvise.c b/mm/madvise.c
index 1932a1f0feda..cfb458c78e09 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -299,7 +299,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 
 	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
 
-	if (vma->vm_flags & (VM_LOCKED|VM_NONLINEAR|VM_HUGETLB))
+	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB))
 		return -EINVAL;
 
 	f = vma->vm_file;
diff --git a/mm/memory.c b/mm/memory.c
index cc741a7ce71e..a4f4ed739a60 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1024,8 +1024,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
-	if (!(vma->vm_flags & (VM_HUGETLB | VM_NONLINEAR |
-			       VM_PFNMAP | VM_MIXEDMAP))) {
+	if (!(vma->vm_flags & (VM_HUGETLB | VM_PFNMAP | VM_MIXEDMAP))) {
 		if (!vma->anon_vma)
 			return 0;
 	}
@@ -1142,8 +1141,7 @@ again:
 		if (unlikely(details))
 			continue;
 		if (pte_file(ptent)) {
-			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
-				print_bad_pte(vma, addr, ptent, NULL);
+			print_bad_pte(vma, addr, ptent, NULL);
 		} else {
 			swp_entry_t entry = pte_to_swp_entry(ptent);
 
@@ -3623,42 +3621,18 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-/*
- * Fault of a previously existing named mapping. Repopulate the pte
- * from the encoded file_pte if possible. This enables swappable
- * nonlinear vmas.
- *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
- * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
- */
 static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
-	pgoff_t pgoff;
-
-	flags |= FAULT_FLAG_NONLINEAR;
-
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		return 0;
 
-	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
-		/*
-		 * Page table corrupted: show pte and kill process.
-		 */
-		print_bad_pte(vma, address, orig_pte, NULL);
-		return VM_FAULT_SIGBUS;
-	}
-
-	pgoff = pte_to_pgoff(orig_pte);
-	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	/*
+	 * Page table corrupted: show pte and kill process.
+	 */
+	print_bad_pte(vma, address, orig_pte, NULL);
+	return VM_FAULT_SIGBUS;
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
diff --git a/mm/mmap.c b/mm/mmap.c
index 8be242f07439..dcac7eaa76b8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -747,14 +747,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 	if (file) {
 		mapping = file->f_mapping;
-		if (!(vma->vm_flags & VM_NONLINEAR)) {
-			root = &mapping->i_mmap;
-			uprobe_munmap(vma, vma->vm_start, vma->vm_end);
+		root = &mapping->i_mmap;
+		uprobe_munmap(vma, vma->vm_start, vma->vm_end);
 
-			if (adjust_next)
-				uprobe_munmap(next, next->vm_start,
-							next->vm_end);
-		}
+		if (adjust_next)
+			uprobe_munmap(next, next->vm_start, next->vm_end);
 
 		mutex_lock(&mapping->i_mmap_mutex);
 		if (insert) {
diff --git a/mm/rmap.c b/mm/rmap.c
index e031d4ad0a4b..c9d964d0a7c4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -550,9 +550,8 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 		if (!vma->anon_vma || !page__anon_vma ||
 		    vma->anon_vma->root != page__anon_vma->root)
 			return -EFAULT;
-	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
-		if (!vma->vm_file ||
-		    vma->vm_file->f_mapping != page->mapping)
+	} else if (page->mapping) {
+		if (!vma->vm_file || vma->vm_file->f_mapping != page->mapping)
 			return -EFAULT;
 	} else
 		return -EFAULT;
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
