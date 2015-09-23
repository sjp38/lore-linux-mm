Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0A87A6B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:48:01 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so29323309pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:48:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rq8si734458pbc.226.2015.09.22.21.48.00
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:48:00 -0700 (PDT)
Subject: [PATCH 12/15] mm, dax, gpu: convert vm_insert_mixed to __pfn_t,
 introduce _PAGE_DEVMAP
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:42:16 -0400
Message-ID: <20150923044216.36490.51220.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, David Airlie <airlied@linux.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Convert the raw unsigned long 'pfn' argument to __pfn_t for the purpose of
evaluating the PFN_MAP and PFN_DEV flags.  When both are set the it
triggers _PAGE_DEVMAP to be set in the resulting pte.  This flag will
later be used in the get_user_pages() path to pin the page mapping,
dynamically allocated by devm_memremap_pages(), until all the resulting
pages are released.

There are no functional changes to the gpu drivers as a result of this
conversion.

This uncovered several architectures with no local definition for
pfn_pte(), in response __pfn_t_pte() is only defined when an arch
opts-in by "#define pfn_pte pfn_pte".

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Airlie <airlied@linux.ie>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/alpha/include/asm/pgtable.h        |    1 +
 arch/m68k/include/asm/page_no.h         |    1 +
 arch/parisc/include/asm/pgtable.h       |    1 +
 arch/powerpc/include/asm/pgtable.h      |    1 +
 arch/tile/include/asm/pgtable.h         |    1 +
 arch/um/include/asm/pgtable-3level.h    |    1 +
 arch/x86/include/asm/pgtable.h          |   18 ++++++++++++++++++
 arch/x86/include/asm/pgtable_types.h    |    7 ++++++-
 drivers/gpu/drm/exynos/exynos_drm_gem.c |    3 ++-
 drivers/gpu/drm/gma500/framebuffer.c    |    2 +-
 drivers/gpu/drm/msm/msm_gem.c           |    3 ++-
 drivers/gpu/drm/omapdrm/omap_gem.c      |    6 ++++--
 drivers/gpu/drm/ttm/ttm_bo_vm.c         |    3 ++-
 fs/dax.c                                |    2 +-
 include/linux/mm.h                      |   29 ++++++++++++++++++++++++++++-
 mm/memory.c                             |   15 +++++++++------
 16 files changed, 79 insertions(+), 15 deletions(-)

diff --git a/arch/alpha/include/asm/pgtable.h b/arch/alpha/include/asm/pgtable.h
index a9a119592372..a54050fe867e 100644
--- a/arch/alpha/include/asm/pgtable.h
+++ b/arch/alpha/include/asm/pgtable.h
@@ -216,6 +216,7 @@ extern unsigned long __zero_page(void);
 })
 #endif
 
+#define pfn_pte pfn_pte
 extern inline pte_t pfn_pte(unsigned long physpfn, pgprot_t pgprot)
 { pte_t pte; pte_val(pte) = (PHYS_TWIDDLE(physpfn) << 32) | pgprot_val(pgprot); return pte; }
 
diff --git a/arch/m68k/include/asm/page_no.h b/arch/m68k/include/asm/page_no.h
index ef209169579a..930a42f6db44 100644
--- a/arch/m68k/include/asm/page_no.h
+++ b/arch/m68k/include/asm/page_no.h
@@ -34,6 +34,7 @@ extern unsigned long memory_end;
 
 #define	virt_addr_valid(kaddr)	(((void *)(kaddr) >= (void *)PAGE_OFFSET) && \
 				((void *)(kaddr) < (void *)memory_end))
+#define __pfn_to_phys(pfn)	PFN_PHYS(pfn)
 
 #endif /* __ASSEMBLY__ */
 
diff --git a/arch/parisc/include/asm/pgtable.h b/arch/parisc/include/asm/pgtable.h
index f93c4a4e6580..dde7dd7200bd 100644
--- a/arch/parisc/include/asm/pgtable.h
+++ b/arch/parisc/include/asm/pgtable.h
@@ -377,6 +377,7 @@ static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
 
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long pfn, pgprot_t pgprot)
 {
 	pte_t pte;
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 0717693c8428..8448ff1542e0 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -67,6 +67,7 @@ static inline int pte_present(pte_t pte)
  * Even if PTEs can be unsigned long long, a PFN is always an unsigned
  * long for now.
  */
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long pfn, pgprot_t pgprot) {
 	return __pte(((pte_basic_t)(pfn) << PTE_RPN_SHIFT) |
 		     pgprot_val(pgprot)); }
diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index 2b05ccbebed9..37c9aa3a3f0c 100644
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -275,6 +275,7 @@ static inline unsigned long pte_pfn(pte_t pte)
 extern pgprot_t set_remote_cache_cpu(pgprot_t prot, int cpu);
 extern int get_remote_cache_cpu(pgprot_t prot);
 
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long pfn, pgprot_t prot)
 {
 	return hv_pte_set_pa(prot, PFN_PHYS(pfn));
diff --git a/arch/um/include/asm/pgtable-3level.h b/arch/um/include/asm/pgtable-3level.h
index 2b4274e7c095..4de681d15911 100644
--- a/arch/um/include/asm/pgtable-3level.h
+++ b/arch/um/include/asm/pgtable-3level.h
@@ -98,6 +98,7 @@ static inline unsigned long pte_pfn(pte_t pte)
 	return phys_to_pfn(pte_val(pte));
 }
 
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(pfn_t page_nr, pgprot_t pgprot)
 {
 	pte_t pte;
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 867da5bbb4a3..02a54e5b7930 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -248,6 +248,11 @@ static inline pte_t pte_mkspecial(pte_t pte)
 	return pte_set_flags(pte, _PAGE_SPECIAL);
 }
 
+static inline pte_t pte_mkdevmap(pte_t pte)
+{
+	return pte_set_flags(pte, _PAGE_SPECIAL|_PAGE_DEVMAP);
+}
+
 static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
 {
 	pmdval_t v = native_pmd_val(pmd);
@@ -334,6 +339,7 @@ static inline pgprotval_t massage_pgprot(pgprot_t pgprot)
 	return protval;
 }
 
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
 {
 	return __pte(((phys_addr_t)page_nr << PAGE_SHIFT) |
@@ -446,6 +452,12 @@ static inline int pte_present(pte_t a)
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
+#define pte_devmap pte_devmap
+static inline int pte_devmap(pte_t a)
+{
+	return pte_flags(a) & _PAGE_DEVMAP;
+}
+
 #define pte_accessible pte_accessible
 static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
 {
@@ -464,6 +476,12 @@ static inline int pte_hidden(pte_t pte)
 	return pte_flags(pte) & _PAGE_HIDDEN;
 }
 
+#define pmd_devmap pmd_devmap
+static inline int pmd_devmap(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_DEVMAP;
+}
+
 static inline int pmd_present(pmd_t pmd)
 {
 	/*
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 13f310bfc09a..42d34e795123 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -25,7 +25,9 @@
 #define _PAGE_BIT_SPLITTING	_PAGE_BIT_SOFTW2 /* only valid on a PSE pmd */
 #define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
-#define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
+#define _PAGE_BIT_SOFTW4	58	/* available for programmer */
+#define _PAGE_BIT_DEVMAP		_PAGE_BIT_SOFTW4
+#define _PAGE_BIT_NX		63	/* No execute: only valid after cpuid check */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
@@ -85,8 +87,11 @@
 
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
 #define _PAGE_NX	(_AT(pteval_t, 1) << _PAGE_BIT_NX)
+#define _PAGE_DEVMAP	(_AT(pteval_t, 1) << _PAGE_BIT_DEVMAP)
+#define __HAVE_ARCH_PTE_DEVMAP
 #else
 #define _PAGE_NX	(_AT(pteval_t, 0))
+#define _PAGE_DEVMAP	(_AT(pteval_t, 0))
 #endif
 
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index f12fbc36b120..3df44766a72f 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -492,7 +492,8 @@ int exynos_drm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 
 	pfn = page_to_pfn(exynos_gem_obj->pages[page_offset]);
-	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+			pfn_to_pfn_t(pfn, PFN_DEV));
 
 out:
 	switch (ret) {
diff --git a/drivers/gpu/drm/gma500/framebuffer.c b/drivers/gpu/drm/gma500/framebuffer.c
index 2eaf1b31c7bd..a3e64aca9dce 100644
--- a/drivers/gpu/drm/gma500/framebuffer.c
+++ b/drivers/gpu/drm/gma500/framebuffer.c
@@ -132,7 +132,7 @@ static int psbfb_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	for (i = 0; i < page_num; i++) {
 		pfn = (phys_addr >> PAGE_SHIFT);
 
-		ret = vm_insert_mixed(vma, address, pfn);
+		ret = vm_insert_mixed(vma, address, pfn_to_pfn_t(pfn, PFN_DEV));
 		if (unlikely((ret == -EBUSY) || (ret != 0 && i > 0)))
 			break;
 		else if (unlikely(ret != 0)) {
diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
index c76cc853b08a..0f4ed5bfda83 100644
--- a/drivers/gpu/drm/msm/msm_gem.c
+++ b/drivers/gpu/drm/msm/msm_gem.c
@@ -222,7 +222,8 @@ int msm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	VERB("Inserting %p pfn %lx, pa %lx", vmf->virtual_address,
 			pfn, pfn << PAGE_SHIFT);
 
-	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+			pfn_to_pfn_t(pfn, PFN_DEV));
 
 out_unlock:
 	mutex_unlock(&dev->struct_mutex);
diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
index 7ed08fdc4c42..910cb276a7ea 100644
--- a/drivers/gpu/drm/omapdrm/omap_gem.c
+++ b/drivers/gpu/drm/omapdrm/omap_gem.c
@@ -385,7 +385,8 @@ static int fault_1d(struct drm_gem_object *obj,
 	VERB("Inserting %p pfn %lx, pa %lx", vmf->virtual_address,
 			pfn, pfn << PAGE_SHIFT);
 
-	return vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+	return vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+			pfn_to_pfn_t(pfn, PFN_DEV));
 }
 
 /* Special handling for the case of faulting in 2d tiled buffers */
@@ -478,7 +479,8 @@ static int fault_2d(struct drm_gem_object *obj,
 			pfn, pfn << PAGE_SHIFT);
 
 	for (i = n; i > 0; i--) {
-		vm_insert_mixed(vma, (unsigned long)vaddr, pfn);
+		vm_insert_mixed(vma, (unsigned long)vaddr,
+				pfn_to_pfn_t(pfn, PFN_DEV));
 		pfn += usergart[fmt].stride_pfn;
 		vaddr += PAGE_SIZE * m;
 	}
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 8fb7213277cc..f27fa1534687 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -229,7 +229,8 @@ static int ttm_bo_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		}
 
 		if (vma->vm_flags & VM_MIXEDMAP)
-			ret = vm_insert_mixed(&cvma, address, pfn);
+			ret = vm_insert_mixed(&cvma, address,
+					pfn_to_pfn_t(pfn, PFN_DEV));
 		else
 			ret = vm_insert_pfn(&cvma, address, pfn);
 
diff --git a/fs/dax.c b/fs/dax.c
index 41d4f76e93ef..b93dbf363dc2 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -354,7 +354,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_bh(bh, addr);
 
-	error = vm_insert_mixed(vma, vaddr, __pfn_t_to_pfn(pfn));
+	error = vm_insert_mixed(vma, vaddr, pfn);
 
  out:
 	return error;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6ea922de6870..54fbeda5b896 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -977,6 +977,33 @@ static inline __pfn_t page_to_pfn_t(struct page *page)
 	return pfn;
 }
 
+static inline int __pfn_t_valid(__pfn_t pfn)
+{
+	return pfn_valid(__pfn_t_to_pfn(pfn));
+}
+
+#ifdef pfn_pte
+static inline pte_t __pfn_t_pte(__pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pte(__pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
+
+#ifdef __HAVE_ARCH_PTE_DEVICE
+static inline bool __pfn_t_has_dev_pagemap(__pfn_t pfn)
+{
+	const unsigned long flags = PFN_DEV|PFN_MAP;
+
+	return (pfn.val & flags) == flags;
+}
+#else
+static inline bool __pfn_t_has_dev_pagemap(__pfn_t pfn)
+{
+	return false;
+}
+pte_t pte_mkdevmap(pte_t pte);
+#endif
+
 /*
  * Some inline functions in vmstat.h depend on page_zone()
  */
@@ -2160,7 +2187,7 @@ int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn);
+			__pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/mm/memory.c b/mm/memory.c
index 9cb27470fee9..6ec61c120289 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1517,7 +1517,7 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 EXPORT_SYMBOL(vm_insert_page);
 
 static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t prot)
+			__pfn_t pfn, pgprot_t prot)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -1533,7 +1533,10 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 		goto out_unlock;
 
 	/* Ok, finally just insert the thing.. */
-	entry = pte_mkspecial(pfn_pte(pfn, prot));
+	if (__pfn_t_has_dev_pagemap(pfn))
+		entry = pte_mkdevmap(__pfn_t_pte(pfn, prot));
+	else
+		entry = pte_mkspecial(__pfn_t_pte(pfn, prot));
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
@@ -1583,14 +1586,14 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	if (track_pfn_insert(vma, &pgprot, pfn))
 		return -EINVAL;
 
-	ret = insert_pfn(vma, addr, pfn, pgprot);
+	ret = insert_pfn(vma, addr, pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
 
 	return ret;
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn)
+			__pfn_t pfn)
 {
 	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
 
@@ -1604,10 +1607,10 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
 	 * without pte special, it would there be refcounted as a normal page.
 	 */
-	if (!HAVE_PTE_SPECIAL && pfn_valid(pfn)) {
+	if (!HAVE_PTE_SPECIAL && __pfn_t_valid(pfn)) {
 		struct page *page;
 
-		page = pfn_to_page(pfn);
+		page = __pfn_t_to_page(pfn);
 		return insert_page(vma, addr, page, vma->vm_page_prot);
 	}
 	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
