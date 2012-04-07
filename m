Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 0E1576B0083
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 15:01:11 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so3469210bkw.14
        for <linux-mm@kvack.org>; Sat, 07 Apr 2012 12:01:11 -0700 (PDT)
Subject: [PATCH v2 03/10] mm, x86, pat: rework linear pfn-mmap tracking
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 07 Apr 2012 23:01:07 +0400
Message-ID: <20120407190107.9726.29901.stgit@zurg>
In-Reply-To: <20120407185546.9726.62260.stgit@zurg>
References: <20120407185546.9726.62260.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Venkatesh Pallipadi <venki@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

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
 include/linux/mm.h            |   15 +--------------
 mm/huge_memory.c              |    7 +++----
 mm/memory.c                   |   12 ++++++------
 5 files changed, 26 insertions(+), 31 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index d5b6759..59ee27d 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -665,7 +665,7 @@ int track_pfn_copy(struct vm_area_struct *vma)
 	unsigned long vma_size = vma->vm_end - vma->vm_start;
 	pgprot_t pgprot;
 
-	if (is_linear_pfn_mapping(vma)) {
+	if (vma->vm_flags & VM_PAT) {
 		/*
 		 * reserve the whole chunk covered by vma. We need the
 		 * starting address and protection from pte.
@@ -687,14 +687,20 @@ int track_pfn_copy(struct vm_area_struct *vma)
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
@@ -748,7 +754,7 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 	resource_size_t paddr;
 	unsigned long prot;
 
-	if (!is_linear_pfn_mapping(vma))
+	if (!(vma->vm_flags & VM_PAT))
 		return;
 
 	/* free the chunk starting from pfn or the whole chunk */
@@ -762,6 +768,7 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 		size = vma->vm_end - vma->vm_start;
 	}
 	free_pfn_range(paddr, size);
+	vma->vm_flags &= ~VM_PAT;
 }
 
 pgprot_t pgprot_writecombine(pgprot_t prot)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index a877649..ddd613e 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -392,7 +392,8 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
  * by remap_pfn_range() for physical range indicated by pfn and size.
  */
 static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
-				  unsigned long pfn, unsigned long size)
+				  unsigned long pfn, unsigned long addr,
+				  unsigned long size)
 {
 	return 0;
 }
@@ -427,7 +428,8 @@ static inline void untrack_pfn(struct vm_area_struct *vma,
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
index d8738a4..b8e5fe5 100644
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
@@ -158,19 +158,6 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 
-/*
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
 static inline int is_pfn_mapping(struct vm_area_struct *vma)
 {
 	return !!(vma->vm_flags & VM_PFNMAP);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f0e5306..cf827da 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1650,7 +1650,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 	 * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
 	 * true too, verify it here.
 	 */
-	VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags & VM_NO_THP);
+	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -1908,7 +1908,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
 	 * true too, verify it here.
 	 */
-	VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags & VM_NO_THP);
+	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -2150,8 +2150,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		 * If is_pfn_mapping() is true is_learn_pfn_mapping()
 		 * must be true too, verify it here.
 		 */
-		VM_BUG_ON(is_linear_pfn_mapping(vma) ||
-			  vma->vm_flags & VM_NO_THP);
+		VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 
 		hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 		hend = vma->vm_end & HPAGE_PMD_MASK;
diff --git a/mm/memory.c b/mm/memory.c
index 4cdcf53..2ade15b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2282,23 +2282,23 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
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
-		return -EINVAL;
+	}
 
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
 
-	err = track_pfn_remap(vma, &prot, pfn, PAGE_ALIGN(size));
+	err = track_pfn_remap(vma, &prot, pfn, addr, PAGE_ALIGN(size));
 	if (err) {
 		/*
 		 * To indicate that track_pfn related cleanup is not
 		 * needed from higher level routine calling unmap_vmas
 		 */
 		vma->vm_flags &= ~(VM_IO | VM_RESERVED | VM_PFNMAP);
-		vma->vm_flags &= ~VM_PFN_AT_MMAP;
 		return -EINVAL;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
