Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E94D36B0081
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:25:46 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so6818156pdb.7
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:25:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id c8si18124511pat.196.2014.10.08.06.25.44
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 06:25:45 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v1 3/7] mm: Add vm_insert_pfn_pmd()
Date: Wed,  8 Oct 2014 09:25:25 -0400
Message-Id: <1412774729-23956-4-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Similar to vm_insert_pfn(), but for PMDs rather than PTEs.  Should this
be in m/huge_memory.c?

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0a47817..d0de9fa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1960,6 +1960,8 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
+int vm_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
+			unsigned long pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/mm/memory.c b/mm/memory.c
index 3368785..993be2b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1648,6 +1648,54 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
+static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+			pmd_t *pmd, unsigned long pfn, pgprot_t prot)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int retval;
+	pmd_t entry;
+	spinlock_t *ptl;
+
+	ptl = pmd_lock(mm, pmd);
+	retval = -EBUSY;
+	if (!pmd_none(*pmd))
+		goto out_unlock;
+
+	/* Ok, finally just insert the thing.. */
+	entry = pmd_mkspecial(pmd_mkhuge(pfn_pmd(pfn, prot)));
+	set_pmd_at(mm, addr, pmd, entry);
+	update_mmu_cache_pmd(vma, addr, pmd);
+
+	retval = 0;
+ out_unlock:
+	spin_unlock(ptl);
+	return retval;
+}
+
+int vm_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+					pmd_t *pmd, unsigned long pfn)
+{
+	pgprot_t pgprot = vma->vm_page_prot;
+	/*
+	 * Technically, architectures with pte_special can avoid all these
+	 * restrictions (same for remap_pfn_range).  However we would like
+	 * consistency in testing and feature parity among all, so we should
+	 * try to keep these invariants in place for everybody.
+	 */
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
+						(VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return -EFAULT;
+	if (track_pfn_insert(vma, &pgprot, pfn))
+		return -EINVAL;
+	return insert_pfn_pmd(vma, addr, pmd, pfn, pgprot);
+}
+EXPORT_SYMBOL(vm_insert_pfn_pmd);
+
 /*
  * maps a range of physical memory into the requested pages. the old
  * mappings are removed. any references to nonexistent pages results
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
