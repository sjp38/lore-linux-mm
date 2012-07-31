Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 9D3226B0062
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:34:27 -0400 (EDT)
Received: by mail-lpp01m010-f41.google.com with SMTP id i5so4779813lah.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:34:27 -0700 (PDT)
Subject: [PATCH v3 03/10] mm, x86, pat: rework linear pfn-mmap tracking
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:34:23 +0400
Message-ID: <20120731103423.20182.78887.stgit@zurg>
In-Reply-To: <20120731102546.20182.8450.stgit@zurg>
References: <20120731102546.20182.8450.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

This patch replaces generic vma-flag VM_PFN_AT_MMAP with x86-only VM_PAT.

We can toss mapping address from remap_pfn_range() into track_pfn_vma_new(),
and collect all PAT-related logic together in arch/x86/.

This patch also restores orignal frustration-free is_cow_mapping() check in
remap_pfn_range(), as it was before commit v2.6.28-rc8-88-g3c8bb73
("x86: PAT: store vm_pgoff for all linear_over_vma_region mappings - v3")

is_linear_pfn_mapping() checks can be removed from mm/huge_memory.c,
because it already handled by VM_PFNMAP in VM_NO_THP bit-mask.

[suresh.b.siddha@intel.com: Reset the VM_PAT flag as part of untrack_pfn_vma()]

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Venkatesh Pallipadi <venki@google.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Ingo Molnar <mingo@redhat.com>
---
 arch/x86/mm/pat.c             |   17 ++++++++++++-----
 include/asm-generic/pgtable.h |    6 ++++--
 include/linux/mm.h            |   20 +-------------------
 mm/huge_memory.c              |   19 +++----------------
 mm/memory.c                   |   26 ++++++++++----------------
 5 files changed, 30 insertions(+), 58 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 4ad8316..d6b5780 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -677,7 +677,7 @@ int track_pfn_copy(struct vm_area_struct *vma)
 	unsigned long vma_size = vma->vm_end - vma->vm_start;
 	pgprot_t pgprot;
 
-	if (is_linear_pfn_mapping(vma)) {
+	if (vma->vm_flags & VM_PAT) {
 		/*
 		 * reserve the whole chunk covered by vma. We need the
 		 * starting address and protection from pte.
@@ -699,14 +699,20 @@ int track_pfn_copy(struct vm_area_struct *vma)
  * single reserve_pfn_range call.
  */
 int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
-		    unsigned long pfn, unsigned long size)
+		    unsigned long pfn, unsigned long addr, unsigned long size)
 {
 	resource_size_t paddr = (resource_size_t)pfn << PAGE_SHIFT;
 	unsigned long flags;
 
 	/* reserve the whole chunk starting from paddr */
-	if (is_linear_pfn_mapping(vma))
-		return reserve_pfn_range(paddr, size, prot, 0);
+	if (addr == vma->vm_start && size == (vma->vm_end - vma->vm_start)) {
+		int ret;
+
+		ret = reserve_pfn_range(paddr, size, prot, 0);
+		if (!ret)
+			vma->vm_flags |= VM_PAT;
+		return ret;
+	}
 
 	if (!pat_enabled)
 		return 0;
@@ -760,7 +766,7 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 	resource_size_t paddr;
 	unsigned long prot;
 
-	if (!is_linear_pfn_mapping(vma))
+	if (!(vma->vm_flags & VM_PAT))
 		return;
 
 	/* free the chunk starting from pfn or the whole chunk */
@@ -774,6 +780,7 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 		size = vma->vm_end - vma->vm_start;
 	}
 	free_pfn_range(paddr, size);
+	vma->vm_flags &= ~VM_PAT;
 }
 
 pgprot_t pgprot_writecombine(pgprot_t prot)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index d4d4592..c9a6120 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -391,7 +391,8 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
  * by remap_pfn_range() for physical range indicated by pfn and size.
  */
 static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
-				  unsigned long pfn, unsigned long size)
+				  unsigned long pfn, unsigned long addr,
+				  unsigned long size)
 {
 	return 0;
 }
@@ -426,7 +427,8 @@ static inline void untrack_pfn(struct vm_area_struct *vma,
 }
 #else
 extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
-			   unsigned long pfn, unsigned long size);
+			   unsigned long pfn, unsigned long addr,
+			   unsigned long size);
 extern int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 			    unsigned long pfn);
 extern int track_pfn_copy(struct vm_area_struct *vma);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f9f279c..c5db955 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -117,7 +117,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
-#define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
+#define VM_PAT		0x40000000	/* PAT reserves whole VMA at once (x86) */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
 /* Bits set in the VMA until the stack is in its final location */
@@ -159,24 +159,6 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 
 /*
- * This interface is used by x86 PAT code to identify a pfn mapping that is
- * linear over entire vma. This is to optimize PAT code that deals with
- * marking the physical region with a particular prot. This is not for generic
- * mm use. Note also that this check will not work if the pfn mapping is
- * linear for a vma starting at physical address 0. In which case PAT code
- * falls back to slow path of reserving physical range page by page.
- */
-static inline int is_linear_pfn_mapping(struct vm_area_struct *vma)
-{
-	return !!(vma->vm_flags & VM_PFN_AT_MMAP);
-}
-
-static inline int is_pfn_mapping(struct vm_area_struct *vma)
-{
-	return !!(vma->vm_flags & VM_PFNMAP);
-}
-
-/*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
  * ->fault function. The vma's ->fault is responsible for returning a bitmask
  * of VM_FAULT_xxx flags that give details about how the fault was handled.
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 57c4b93..5b31652 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1655,11 +1655,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	/*
-	 * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
-	 * true too, verify it here.
-	 */
-	VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags & VM_NO_THP);
+	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -1913,11 +1909,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out;
 	if (is_vma_temporary_stack(vma))
 		goto out;
-	/*
-	 * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
-	 * true too, verify it here.
-	 */
-	VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags & VM_NO_THP);
+	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -2155,12 +2147,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			goto skip;
 		if (is_vma_temporary_stack(vma))
 			goto skip;
-		/*
-		 * If is_pfn_mapping() is true is_learn_pfn_mapping()
-		 * must be true too, verify it here.
-		 */
-		VM_BUG_ON(is_linear_pfn_mapping(vma) ||
-			  vma->vm_flags & VM_NO_THP);
+		VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 
 		hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 		hend = vma->vm_end & HPAGE_PMD_MASK;
diff --git a/mm/memory.c b/mm/memory.c
index 57148fc..aca6f22 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1055,7 +1055,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
-	if (unlikely(is_pfn_mapping(vma))) {
+	if (unlikely(vma->vm_flags & VM_PFNMAP)) {
 		/*
 		 * We do not free on error cases below as remove_vma
 		 * gets called on error from higher level routine
@@ -1327,7 +1327,7 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 	if (vma->vm_file)
 		uprobe_munmap(vma, start, end);
 
-	if (unlikely(is_pfn_mapping(vma)))
+	if (unlikely(vma->vm_flags & VM_PFNMAP))
 		untrack_pfn(vma, 0, 0);
 
 	if (start != end) {
@@ -2296,26 +2296,20 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	 * There's a horrible special case to handle copy-on-write
 	 * behaviour that some programs depend on. We mark the "original"
 	 * un-COW'ed pages by matching them up with "vma->vm_pgoff".
+	 * See vm_normal_page() for details.
 	 */
-	if (addr == vma->vm_start && end == vma->vm_end) {
+	if (is_cow_mapping(vma->vm_flags)) {
+		if (addr != vma->vm_start || end != vma->vm_end)
+			return -EINVAL;
 		vma->vm_pgoff = pfn;
-		vma->vm_flags |= VM_PFN_AT_MMAP;
-	} else if (is_cow_mapping(vma->vm_flags))
+	}
+
+	err = track_pfn_remap(vma, &prot, pfn, addr, PAGE_ALIGN(size));
+	if (err)
 		return -EINVAL;
 
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
 
-	err = track_pfn_remap(vma, &prot, pfn, PAGE_ALIGN(size));
-	if (err) {
-		/*
-		 * To indicate that track_pfn related cleanup is not
-		 * needed from higher level routine calling unmap_vmas
-		 */
-		vma->vm_flags &= ~(VM_IO | VM_RESERVED | VM_PFNMAP);
-		vma->vm_flags &= ~VM_PFN_AT_MMAP;
-		return -EINVAL;
-	}
-
 	BUG_ON(addr >= end);
 	pfn -= addr >> PAGE_SHIFT;
 	pgd = pgd_offset(mm, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
