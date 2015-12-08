Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id EC1BD6B0287
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:34:39 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so3067315pac.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:34:39 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id va5si1265533pac.165.2015.12.07.17.34.39
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:34:39 -0800 (PST)
Subject: [PATCH -mm 18/25] mm, dax: convert vmf_insert_pfn_pmd() to pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:34:11 -0800
Message-ID: <20151208013411.25030.86914.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-nvdimm@lists.01.org, Dave Hansen <dave@sr71.net>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

Similar to the conversion of vm_insert_mixed() use pfn_t in the
vmf_insert_pfn_pmd() to tag the resulting pte with _PAGE_DEVICE when the
pfn is backed by a devm_memremap_pages() mapping.

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/sparc/include/asm/pgtable_64.h     |    1 +
 arch/x86/include/asm/pgtable.h          |    6 ++++++
 arch/x86/mm/pat.c                       |    4 ++--
 drivers/gpu/drm/exynos/exynos_drm_gem.c |    2 +-
 drivers/gpu/drm/msm/msm_gem.c           |    2 +-
 drivers/gpu/drm/omapdrm/omap_gem.c      |    4 ++--
 fs/dax.c                                |    2 +-
 include/asm-generic/pgtable.h           |    6 ++++--
 include/linux/huge_mm.h                 |    2 +-
 include/linux/mm.h                      |   10 +++++++++-
 mm/huge_memory.c                        |   10 ++++++----
 mm/memory.c                             |    2 +-
 12 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index e1a49f02b5b4..fdfd8c3a0887 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -245,6 +245,7 @@ static inline pte_t pfn_pte(unsigned long pfn, pgprot_t prot)
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pfn_pmd pfn_pmd
 static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 {
 	pte_t pte = pfn_pte(page_nr, pgprot);
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index d06baa865a50..5209ca1161d2 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -281,6 +281,11 @@ static inline pmd_t pmd_mkdirty(pmd_t pmd)
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
@@ -355,6 +360,7 @@ static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
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
index 973df42fc1eb..d6a6dd7d0ffe 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -491,7 +491,7 @@ int exynos_drm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	pfn = page_to_pfn(exynos_gem->pages[page_offset]);
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
index 00088918baf2..b9ab7138f5cb 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -692,7 +692,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		dax_unmap_atomic(bdev, &dax);
 
 		result |= vmf_insert_pfn_pmd(vma, address, pmd,
-				pfn_t_to_pfn(dax.pfn), write);
+				dax.pfn, write);
 	}
 
  out:
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 63abda1ac06d..bdff35e90889 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_GENERIC_PGTABLE_H
 #define _ASM_GENERIC_PGTABLE_H
 
+#include <linux/pfn.h>
+
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
 
@@ -549,7 +551,7 @@ static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
  * by vm_insert_pfn().
  */
 static inline int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-				   unsigned long pfn)
+				   pfn_t pfn)
 {
 	return 0;
 }
@@ -577,7 +579,7 @@ extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 			   unsigned long pfn, unsigned long addr,
 			   unsigned long size);
 extern int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
-			    unsigned long pfn);
+			    pfn_t pfn);
 extern int track_pfn_copy(struct vm_area_struct *vma);
 extern void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 			unsigned long size);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 72cd942edb22..0af95c1a2666 100644
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
index fb97d2023769..68b11b68b160 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1068,7 +1068,14 @@ static inline pte_t pfn_t_pte(pfn_t pfn, pgprot_t pgprot)
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
 static inline bool pfn_t_devmap(pfn_t pfn)
 {
 	const unsigned long flags = PFN_DEV|PFN_MAP;
@@ -1081,6 +1088,7 @@ static inline bool pfn_t_devmap(pfn_t pfn)
 	return false;
 }
 pte_t pte_mkdevmap(pte_t pte);
+pmd_t pmd_mkdevmap(pmd_t pmd);
 #endif
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 70323839bd0d..c1491ce1d8ac 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -960,14 +960,16 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
+		pmd_t *pmd, pfn_t pfn, pgprot_t prot, bool write)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t entry;
 	spinlock_t *ptl;
 
 	ptl = pmd_lock(mm, pmd);
-	entry = pmd_mkhuge(pfn_pmd(pfn, prot));
+	entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
+	if (pfn_t_devmap(pfn))
+		entry = pmd_mkdevmap(entry);
 	if (write) {
 		entry = pmd_mkyoung(pmd_mkdirty(entry));
 		entry = maybe_pmd_mkwrite(entry, vma);
@@ -978,7 +980,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 }
 
 int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-			pmd_t *pmd, unsigned long pfn, bool write)
+			pmd_t *pmd, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
 	/*
@@ -990,7 +992,7 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+	BUG_ON(!pfn_t_devmap(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
diff --git a/mm/memory.c b/mm/memory.c
index bba5cfbdf1fe..42a812d3c3af 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1566,7 +1566,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
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
