Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B5A559003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:46 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so173158264pab.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dx5si4577642pbc.22.2015.07.10.13.29.36
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:36 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 06/10] mm: Add vmf_insert_pfn_pmd()
Date: Fri, 10 Jul 2015 16:29:21 -0400
Message-Id: <1436560165-8943-7-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Similar to vm_insert_pfn(), but for PMDs rather than PTEs.  The 'vmf_'
prefix instead of 'vm_' prefix is intended to indicate that it returns
a VMF_ value rather than an errno (which would only have to be converted
into a VMF_ value anyway).

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/huge_mm.h |  2 ++
 mm/huge_memory.c        | 43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 70587ea..f9b612f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -33,6 +33,8 @@ extern int move_huge_pmd(struct vm_area_struct *vma,
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
+int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
+			unsigned long pfn, bool write);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index db3180f..26d0fc1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -837,6 +837,49 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
+static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pmd_t entry;
+	spinlock_t *ptl;
+
+	ptl = pmd_lock(mm, pmd);
+	if (pmd_none(*pmd)) {
+		entry = pmd_mkhuge(pfn_pmd(pfn, prot));
+		if (write) {
+			entry = pmd_mkyoung(pmd_mkdirty(entry));
+			entry = maybe_pmd_mkwrite(entry, vma);
+		}
+		set_pmd_at(mm, addr, pmd, entry);
+		update_mmu_cache_pmd(vma, addr, pmd);
+	}
+	spin_unlock(ptl);
+	return VM_FAULT_NOPAGE;
+}
+
+int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+			pmd_t *pmd, unsigned long pfn, bool write)
+{
+	pgprot_t pgprot = vma->vm_page_prot;
+	/*
+	 * If we had pmd_special, we could avoid all these restrictions,
+	 * but we need to be consistent with PTEs and architectures that
+	 * can't support a 'special' bit.
+	 */
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
+						(VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return VM_FAULT_SIGBUS;
+	if (track_pfn_insert(vma, &pgprot, pfn))
+		return VM_FAULT_SIGBUS;
+	return insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write);
+}
+
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
