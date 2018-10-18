Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7CE96B0007
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 16:23:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t18-v6so7477259qki.22
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 13:23:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o23sor24253170qvc.7.2018.10.18.13.23.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 13:23:29 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 1/7] mm: infrastructure for page fault page caching
Date: Thu, 18 Oct 2018 16:23:12 -0400
Message-Id: <20181018202318.9131-2-josef@toxicpanda.com>
In-Reply-To: <20181018202318.9131-1-josef@toxicpanda.com>
References: <20181018202318.9131-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

We want to be able to cache the result of a previous loop of a page
fault in the case that we use VM_FAULT_RETRY, so introduce
handle_mm_fault_cacheable that will take a struct vm_fault directly, add
a ->cached_page field to vm_fault, and add helpers to init/cleanup the
struct vm_fault.

I've converted x86, other arch's can follow suit if they so wish, it's
relatively straightforward.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 arch/x86/mm/fault.c |  6 +++-
 include/linux/mm.h  | 31 +++++++++++++++++++++
 mm/memory.c         | 79 ++++++++++++++++++++++++++++++++---------------------
 3 files changed, 84 insertions(+), 32 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 47bebfe6efa7..ef6e538c4931 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1211,6 +1211,7 @@ static noinline void
 __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		unsigned long address)
 {
+	struct vm_fault vmf = {};
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
@@ -1392,7 +1393,8 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 * fault, so we read the pkey beforehand.
 	 */
 	pkey = vma_pkey(vma);
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault_cacheable(&vmf);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
@@ -1408,6 +1410,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 			if (!fatal_signal_pending(tsk))
 				goto retry;
 		}
+		vm_fault_cleanup(&vmf);
 
 		/* User mode? Just return to handle the fatal exception */
 		if (flags & FAULT_FLAG_USER)
@@ -1418,6 +1421,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, &pkey, fault);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..4a84ec976dfc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -360,6 +360,12 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
+	struct page *cached_page;	/* ->fault handlers that return
+					 * VM_FAULT_RETRY can store their
+					 * previous page here to be reused the
+					 * next time we loop through the fault
+					 * handler for faster lookup.
+					 */
 	/* These three entries are valid only while holding ptl lock */
 	pte_t *pte;			/* Pointer to pte entry matching
 					 * the 'address'. NULL if the page
@@ -378,6 +384,16 @@ struct vm_fault {
 					 */
 };
 
+static inline void vm_fault_init(struct vm_fault *vmf,
+				 struct vm_area_struct *vma,
+				 unsigned long address,
+				 unsigned int flags)
+{
+	vmf->vma = vma;
+	vmf->address = address;
+	vmf->flags = flags;
+}
+
 /* page entry size for vm->huge_fault() */
 enum page_entry_size {
 	PE_SIZE_PTE = 0,
@@ -943,6 +959,14 @@ static inline void put_page(struct page *page)
 		__put_page(page);
 }
 
+static inline void vm_fault_cleanup(struct vm_fault *vmf)
+{
+	if (vmf->cached_page) {
+		put_page(vmf->cached_page);
+		vmf->cached_page = NULL;
+	}
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
@@ -1405,6 +1429,7 @@ int invalidate_inode_page(struct page *page);
 #ifdef CONFIG_MMU
 extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
+extern vm_fault_t handle_mm_fault_cacheable(struct vm_fault *vmf);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
@@ -1420,6 +1445,12 @@ static inline vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
 	BUG();
 	return VM_FAULT_SIGBUS;
 }
+static inline vm_fault_t handle_mm_fault_cacheable(struct vm_fault *vmf)
+{
+	/* should never happen if there's no MMU */
+	BUG();
+	return VM_FAULT_SIGBUS;
+}
 static inline int fixup_user_fault(struct task_struct *tsk,
 		struct mm_struct *mm, unsigned long address,
 		unsigned int fault_flags, bool *unlocked)
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..433075f722ea 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4024,36 +4024,34 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+static vm_fault_t __handle_mm_fault(struct vm_fault *vmf)
 {
-	struct vm_fault vmf = {
-		.vma = vma,
-		.address = address & PAGE_MASK,
-		.flags = flags,
-		.pgoff = linear_page_index(vma, address),
-		.gfp_mask = __get_fault_gfp_mask(vma),
-	};
-	unsigned int dirty = flags & FAULT_FLAG_WRITE;
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long address = vmf->address;
+	unsigned int dirty = vmf->flags & FAULT_FLAG_WRITE;
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
 	p4d_t *p4d;
 	vm_fault_t ret;
 
+	vmf->address = address & PAGE_MASK;
+	vmf->pgoff = linear_page_index(vma, address);
+	vmf->gfp_mask = __get_fault_gfp_mask(vma);
+
 	pgd = pgd_offset(mm, address);
 	p4d = p4d_alloc(mm, pgd, address);
 	if (!p4d)
 		return VM_FAULT_OOM;
 
-	vmf.pud = pud_alloc(mm, p4d, address);
-	if (!vmf.pud)
+	vmf->pud = pud_alloc(mm, p4d, address);
+	if (!vmf->pud)
 		return VM_FAULT_OOM;
-	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)) {
-		ret = create_huge_pud(&vmf);
+	if (pud_none(*vmf->pud) && transparent_hugepage_enabled(vma)) {
+		ret = create_huge_pud(vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-		pud_t orig_pud = *vmf.pud;
+		pud_t orig_pud = *vmf->pud;
 
 		barrier();
 		if (pud_trans_huge(orig_pud) || pud_devmap(orig_pud)) {
@@ -4061,50 +4059,50 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 			/* NUMA case for anonymous PUDs would go here */
 
 			if (dirty && !pud_write(orig_pud)) {
-				ret = wp_huge_pud(&vmf, orig_pud);
+				ret = wp_huge_pud(vmf, orig_pud);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-				huge_pud_set_accessed(&vmf, orig_pud);
+				huge_pud_set_accessed(vmf, orig_pud);
 				return 0;
 			}
 		}
 	}
 
-	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
-	if (!vmf.pmd)
+	vmf->pmd = pmd_alloc(mm, vmf->pud, address);
+	if (!vmf->pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
-		ret = create_huge_pmd(&vmf);
+	if (pmd_none(*vmf->pmd) && transparent_hugepage_enabled(vma)) {
+		ret = create_huge_pmd(vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
 	} else {
-		pmd_t orig_pmd = *vmf.pmd;
+		pmd_t orig_pmd = *vmf->pmd;
 
 		barrier();
 		if (unlikely(is_swap_pmd(orig_pmd))) {
 			VM_BUG_ON(thp_migration_supported() &&
 					  !is_pmd_migration_entry(orig_pmd));
 			if (is_pmd_migration_entry(orig_pmd))
-				pmd_migration_entry_wait(mm, vmf.pmd);
+				pmd_migration_entry_wait(mm, vmf->pmd);
 			return 0;
 		}
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
-				return do_huge_pmd_numa_page(&vmf, orig_pmd);
+				return do_huge_pmd_numa_page(vmf, orig_pmd);
 
 			if (dirty && !pmd_write(orig_pmd)) {
-				ret = wp_huge_pmd(&vmf, orig_pmd);
+				ret = wp_huge_pmd(vmf, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
 			} else {
-				huge_pmd_set_accessed(&vmf, orig_pmd);
+				huge_pmd_set_accessed(vmf, orig_pmd);
 				return 0;
 			}
 		}
 	}
 
-	return handle_pte_fault(&vmf);
+	return handle_pte_fault(vmf);
 }
 
 /*
@@ -4113,9 +4111,10 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+static vm_fault_t do_handle_mm_fault(struct vm_fault *vmf)
 {
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned int flags = vmf->flags;
 	vm_fault_t ret;
 
 	__set_current_state(TASK_RUNNING);
@@ -4139,9 +4138,9 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		mem_cgroup_enter_user_fault();
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
-		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
+		ret = hugetlb_fault(vma->vm_mm, vma, vmf->address, flags);
 	else
-		ret = __handle_mm_fault(vma, address, flags);
+		ret = __handle_mm_fault(vmf);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_exit_user_fault();
@@ -4157,8 +4156,26 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
 	return ret;
 }
+
+vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+			   unsigned int flags)
+{
+	struct vm_fault vmf = {};
+	vm_fault_t ret;
+
+	vm_fault_init(&vmf, vma, address, flags);
+	ret = do_handle_mm_fault(&vmf);
+	vm_fault_cleanup(&vmf);
+	return ret;
+}
 EXPORT_SYMBOL_GPL(handle_mm_fault);
 
+vm_fault_t handle_mm_fault_cacheable(struct vm_fault *vmf)
+{
+	return do_handle_mm_fault(vmf);
+}
+EXPORT_SYMBOL_GPL(handle_mm_fault_cacheable);
+
 #ifndef __PAGETABLE_P4D_FOLDED
 /*
  * Allocate p4d page table.
-- 
2.14.3
