Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 32B4582F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:29 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so42211682pab.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:29 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zp7si6401862pac.216.2015.10.09.18.02.28
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:28 -0700 (PDT)
Subject: [PATCH v2 15/20] mm, dax: convert vmf_insert_pfn_pmd() to pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:56:44 -0400
Message-ID: <20151010005644.17221.68344.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, ross.zwisler@linux.intel.com, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de

Similar to the conversion of vm_insert_mixed() use pfn_t in the
vmf_insert_pfn_pmd() to tag the resulting pte with _PAGE_DEVICE when the
pfn is backed by a devm_memremap_pages() mapping.

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/sparc/include/asm/pgtable_64.h     |    2 ++
 arch/x86/include/asm/pgtable.h          |    6 ++++++
 arch/x86/mm/pat.c                       |    4 ++--
 drivers/gpu/drm/exynos/exynos_drm_gem.c |    2 +-
 drivers/gpu/drm/msm/msm_gem.c           |    2 +-
 drivers/gpu/drm/omapdrm/omap_gem.c      |    4 ++--
 fs/dax.c                                |    2 +-
 include/asm-generic/pgtable.h           |    6 ++++--
 include/linux/huge_mm.h                 |    2 +-
 include/linux/mm.h                      |   18 +++++++++++++++++-
 mm/huge_memory.c                        |   10 ++++++----
 mm/memory.c                             |    2 +-
 12 files changed, 44 insertions(+), 16 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 131d36fcd07a..496ef783c68c 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -234,6 +234,7 @@ extern struct page *mem_map_zero;
  * the first physical page in the machine is at some huge physical address,
  * such as 4GB.   This is common on a partitioned E10000, for example.
  */
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long pfn, pgprot_t prot)
 {
 	unsigned long paddr = pfn << PAGE_SHIFT;
@@ -244,6 +245,7 @@ static inline pte_t pfn_pte(unsigned long pfn, pgprot_t prot)
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pfn_pmd pfn_pmd
 static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 {
 	pte_t pte = pfn_pte(page_nr, pgprot);
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 02a54e5b7930..84d1346e1cda 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -282,6 +282,11 @@ static inline pmd_t pmd_mkdirty(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
 }
 
+static inline pmd_t pmd_mkdevmap(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_DEVMAP);
+}
+
 static inline pmd_t pmd_mkhuge(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_PSE);
@@ -346,6 +351,7 @@ static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
 		     massage_pgprot(pgprot));
 }
 
+#define pfn_pmd pfn_pmd
 static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 {
 	return __pmd(((phys_addr_t)page_nr << PAGE_SHIFT) |
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 188e3e07eeeb..98efd3c02374 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -949,7 +949,7 @@ int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 }
 
 int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-		     unsigned long pfn)
+		     pfn_t pfn)
 {
 	enum page_cache_mode pcm;
 
@@ -957,7 +957,7 @@ int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 		return 0;
 
 	/* Set prot based on lookup */
-	pcm = lookup_memtype((resource_size_t)pfn << PAGE_SHIFT);
+	pcm = lookup_memtype(pfn_t_to_phys(pfn));
 	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
 			 cachemode2protval(pcm));
 
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index 778764bebc00..aa7709ed9ae2 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -480,7 +480,7 @@ int exynos_drm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	pfn = page_to_pfn(exynos_gem_obj->pages[page_offset]);
 	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
-			pfn_to_pfn_t(pfn, PFN_DEV));
+			__pfn_to_pfn_t(pfn, PFN_DEV));
 
 out:
 	switch (ret) {
diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
index 0f4ed5bfda83..6509d9b23912 100644
--- a/drivers/gpu/drm/msm/msm_gem.c
+++ b/drivers/gpu/drm/msm/msm_gem.c
@@ -223,7 +223,7 @@ int msm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 			pfn, pfn << PAGE_SHIFT);
 
 	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
-			pfn_to_pfn_t(pfn, PFN_DEV));
+			__pfn_to_pfn_t(pfn, PFN_DEV));
 
 out_unlock:
 	mutex_unlock(&dev->struct_mutex);
diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
index 910cb276a7ea..94b6d23ec202 100644
--- a/drivers/gpu/drm/omapdrm/omap_gem.c
+++ b/drivers/gpu/drm/omapdrm/omap_gem.c
@@ -386,7 +386,7 @@ static int fault_1d(struct drm_gem_object *obj,
 			pfn, pfn << PAGE_SHIFT);
 
 	return vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
-			pfn_to_pfn_t(pfn, PFN_DEV));
+			__pfn_to_pfn_t(pfn, PFN_DEV));
 }
 
 /* Special handling for the case of faulting in 2d tiled buffers */
@@ -480,7 +480,7 @@ static int fault_2d(struct drm_gem_object *obj,
 
 	for (i = n; i > 0; i--) {
 		vm_insert_mixed(vma, (unsigned long)vaddr,
-				pfn_to_pfn_t(pfn, PFN_DEV));
+				__pfn_to_pfn_t(pfn, PFN_DEV));
 		pfn += usergart[fmt].stride_pfn;
 		vaddr += PAGE_SIZE * m;
 	}
diff --git a/fs/dax.c b/fs/dax.c
index 1588edf297a2..87a070d6e6dc 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -685,7 +685,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		dax_unmap_atomic(bdev, kaddr);
 
 		result |= vmf_insert_pfn_pmd(vma, address, pmd,
-				pfn_t_to_pfn(pfn), write);
+				pfn, write);
 	}
 
  out:
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 29c57b2cb344..16d2244c686f 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_GENERIC_PGTABLE_H
 #define _ASM_GENERIC_PGTABLE_H
 
+#include <linux/pfn.h>
+
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
 
@@ -521,7 +523,7 @@ static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
  * by vm_insert_pfn().
  */
 static inline int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-				   unsigned long pfn)
+				   pfn_t pfn)
 {
 	return 0;
 }
@@ -549,7 +551,7 @@ extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 			   unsigned long pfn, unsigned long addr,
 			   unsigned long size);
 extern int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-			    unsigned long pfn);
+			    pfn_t pfn);
 extern int track_pfn_copy(struct vm_area_struct *vma);
 extern void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 			unsigned long size);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ecb080d6ff42..d218abedfeb9 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -34,7 +34,7 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
-			unsigned long pfn, bool write);
+			pfn_t pfn, bool write);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1d405ca21c9f..ce173327215d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1109,7 +1109,14 @@ static inline pte_t pfn_t_pte(pfn_t pfn, pgprot_t pgprot)
 }
 #endif
 
-#ifdef __HAVE_ARCH_PTE_DEVICE
+#ifdef pfn_pmd
+static inline pmd_t pfn_t_pmd(pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pmd(pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
+
+#ifdef __HAVE_ARCH_PTE_DEVMAP
 static inline bool pfn_t_has_dev_pagemap(pfn_t pfn)
 {
 	const unsigned long flags = PFN_DEV|PFN_MAP;
@@ -1122,6 +1129,7 @@ static inline bool pfn_t_has_dev_pagemap(pfn_t pfn)
 	return false;
 }
 pte_t pte_mkdevmap(pte_t pte);
+pmd_t pmd_mkdevmap(pmd_t pmd);
 #endif
 
 /*
@@ -1887,6 +1895,14 @@ static inline void pgtable_pmd_page_dtor(struct page *page) {}
 
 #endif
 
+#ifndef pmd_devmap
+#define pmd_devmap(x) (0)
+#endif
+
+#ifndef pte_devmap
+#define pte_devmap(x) (0)
+#endif
+
 static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 {
 	spinlock_t *ptl = pmd_lockptr(mm, pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b06b8db9df2..952b65a55bc9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -870,7 +870,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
+		pmd_t *pmd, pfn_t pfn, pgprot_t prot, bool write)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t entry;
@@ -878,7 +878,9 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_none(*pmd)) {
-		entry = pmd_mkhuge(pfn_pmd(pfn, prot));
+		entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
+		if (pfn_t_has_dev_pagemap(pfn))
+			entry = pmd_mkdevmap(entry);
 		if (write) {
 			entry = pmd_mkyoung(pmd_mkdirty(entry));
 			entry = maybe_pmd_mkwrite(entry, vma);
@@ -890,7 +892,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 }
 
 int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-			pmd_t *pmd, unsigned long pfn, bool write)
+			pmd_t *pmd, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
 	/*
@@ -902,7 +904,7 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_t_valid(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
diff --git a/mm/memory.c b/mm/memory.c
index 5fc858570f58..06d78ac37343 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1583,7 +1583,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
-	if (track_pfn_insert(vma, &pgprot, pfn))
+	if (track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV)))
 		return -EINVAL;
 
 	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
