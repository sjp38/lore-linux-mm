Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB30C6B59EF
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 14:58:17 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id t72-v6so1335607ybi.4
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 11:58:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a10-v6sor2613524ybl.160.2018.11.30.11.58.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 11:58:16 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 1/4] mm: infrastructure for page fault page caching
Date: Fri, 30 Nov 2018 14:58:09 -0500
Message-Id: <20181130195812.19536-2-josef@toxicpanda.com>
In-Reply-To: <20181130195812.19536-1-josef@toxicpanda.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

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
index 71d4b9d4d43f..8060ad6a34da 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1230,6 +1230,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 			unsigned long hw_error_code,
 			unsigned long address)
 {
+	struct vm_fault vmf = {};
 	unsigned long sw_error_code;
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
@@ -1420,7 +1421,8 @@ void do_user_addr_fault(struct pt_regs *regs,
 	 * userland). The return to userland is identified whenever
 	 * FAULT_FLAG_USER|FAULT_FLAG_KILLABLE are both set in flags.
 	 */
-	fault = handle_mm_fault(vma, address, flags);
+	vm_fault_init(&vmf, vma, address, flags);
+	fault = handle_mm_fault_cacheable(&vmf);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
@@ -1436,6 +1438,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 			if (!fatal_signal_pending(tsk))
 				goto retry;
 		}
+		vm_fault_cleanup(&vmf);
 
 		/* User mode? Just return to handle the fatal exception */
 		if (flags & FAULT_FLAG_USER)
@@ -1446,6 +1449,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 		return;
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, sw_error_code, address, fault);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..3f1dda389aa7 100644
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
@@ -963,6 +979,14 @@ static inline void put_page(struct page *page)
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
@@ -1425,6 +1449,7 @@ int invalidate_inode_page(struct page *page);
 #ifdef CONFIG_MMU
 extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
+extern vm_fault_t handle_mm_fault_cacheable(struct vm_fault *vmf);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
@@ -1440,6 +1465,12 @@ static inline vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
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
index 4ad2d293ddc2..d16bb4816f9d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3806,36 +3806,34 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
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
@@ -3843,50 +3841,50 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
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
@@ -3895,9 +3893,10 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
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
@@ -3921,9 +3920,9 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		mem_cgroup_enter_user_fault();
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
-		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
+		ret = hugetlb_fault(vma->vm_mm, vma, vmf->address, flags);
 	else
-		ret = __handle_mm_fault(vma, address, flags);
+		ret = __handle_mm_fault(vmf);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_exit_user_fault();
@@ -3939,8 +3938,26 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
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
