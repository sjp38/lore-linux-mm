Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4C96B0285
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:34:34 -0500 (EST)
Received: by pacej9 with SMTP id ej9so3071796pac.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:34:34 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xk9si1324948pab.38.2015.12.07.17.34.33
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:34:33 -0800 (PST)
Subject: [PATCH -mm 17/25] mm, dax, gpu: convert vm_insert_mixed to pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:34:06 -0800
Message-ID: <20151208013406.25030.46800.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: David Airlie <airlied@linux.ie>, linux-mm@kvack.org, Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org

Convert the raw unsigned long 'pfn' argument to pfn_t for the purpose
of evaluating the PFN_MAP and PFN_DEV flags.  When both are set it
triggers _PAGE_DEVMAP to be set in the resulting pte.

There are no functional changes to the gpu drivers as a result of this
conversion.

This uncovered several architectures with no local definition for
pfn_pte(), in response pfn_t_pte() is only defined when an arch opts-in
by "#define pfn_pte pfn_pte".

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Airlie <airlied@linux.ie>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/alpha/include/asm/pgtable.h        |    1 +
 arch/parisc/include/asm/pgtable.h       |    1 +
 arch/powerpc/include/asm/pgtable.h      |    1 +
 arch/sparc/include/asm/pgtable_64.h     |    1 +
 arch/tile/include/asm/pgtable.h         |    1 +
 arch/um/include/asm/pgtable-3level.h    |    1 +
 arch/x86/include/asm/pgtable.h          |   12 +++++++++++
 drivers/gpu/drm/exynos/exynos_drm_gem.c |    3 ++-
 drivers/gpu/drm/gma500/framebuffer.c    |    3 ++-
 drivers/gpu/drm/msm/msm_gem.c           |    3 ++-
 drivers/gpu/drm/omapdrm/omap_gem.c      |    6 ++++--
 drivers/gpu/drm/ttm/ttm_bo_vm.c         |    3 ++-
 fs/dax.c                                |    2 +-
 include/linux/mm.h                      |   33 ++++++++++++++++++++++++++++++-
 mm/memory.c                             |   15 ++++++++------
 15 files changed, 72 insertions(+), 14 deletions(-)

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
 
diff --git a/arch/parisc/include/asm/pgtable.h b/arch/parisc/include/asm/pgtable.h
index d8534f95915a..14fb76ccefe7 100644
--- a/arch/parisc/include/asm/pgtable.h
+++ b/arch/parisc/include/asm/pgtable.h
@@ -394,6 +394,7 @@ static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
 
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long pfn, pgprot_t pgprot)
 {
 	pte_t pte;
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index b64b4212b71f..38563174acef 100644
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
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index f5bfcd66aeb5..e1a49f02b5b4 100644
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
diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index 96cecf55522e..983f1ed37d62 100644
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
index bae8523a162f..b7b51db14c2f 100644
--- a/arch/um/include/asm/pgtable-3level.h
+++ b/arch/um/include/asm/pgtable-3level.h
@@ -98,6 +98,7 @@ static inline unsigned long pte_pfn(pte_t pte)
 	return phys_to_pfn(pte_val(pte));
 }
 
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
 {
 	pte_t pte;
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 61e706c9f710..d06baa865a50 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -247,6 +247,11 @@ static inline pte_t pte_mkspecial(pte_t pte)
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
@@ -343,6 +348,7 @@ static inline pgprotval_t massage_pgprot(pgprot_t pgprot)
 	return protval;
 }
 
+#define pfn_pte pfn_pte
 static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
 {
 	return __pte(((phys_addr_t)page_nr << PAGE_SHIFT) |
@@ -457,6 +463,12 @@ static inline int pte_present(pte_t a)
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
+#define pte_devmap pte_devmap
+static inline int pte_devmap(pte_t a)
+{
+	return (pte_flags(a) & _PAGE_DEVMAP) == _PAGE_DEVMAP;
+}
+
 #define pte_accessible pte_accessible
 static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
 {
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index 252eb301470c..973df42fc1eb 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -490,7 +490,8 @@ int exynos_drm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 
 	pfn = page_to_pfn(exynos_gem->pages[page_offset]);
-	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+			pfn_to_pfn_t(pfn, PFN_DEV));
 
 out:
 	switch (ret) {
diff --git a/drivers/gpu/drm/gma500/framebuffer.c b/drivers/gpu/drm/gma500/framebuffer.c
index ee95c03a8c54..ecb5b1f66f87 100644
--- a/drivers/gpu/drm/gma500/framebuffer.c
+++ b/drivers/gpu/drm/gma500/framebuffer.c
@@ -132,7 +132,8 @@ static int psbfb_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	for (i = 0; i < page_num; i++) {
 		pfn = (phys_addr >> PAGE_SHIFT);
 
-		ret = vm_insert_mixed(vma, address, pfn);
+		ret = vm_insert_mixed(vma, address,
+				__pfn_to_pfn_t(pfn, PFN_DEV));
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
index 8fb7213277cc..bab765a7c501 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -229,7 +229,8 @@ static int ttm_bo_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		}
 
 		if (vma->vm_flags & VM_MIXEDMAP)
-			ret = vm_insert_mixed(&cvma, address, pfn);
+			ret = vm_insert_mixed(&cvma, address,
+					__pfn_to_pfn_t(pfn, PFN_DEV));
 		else
 			ret = vm_insert_pfn(&cvma, address, pfn);
 
diff --git a/fs/dax.c b/fs/dax.c
index 82897cf3cca0..00088918baf2 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -362,7 +362,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
-	error = vm_insert_mixed(vma, vaddr, pfn_t_to_pfn(dax.pfn));
+	error = vm_insert_mixed(vma, vaddr, dax.pfn);
 
  out:
 	i_mmap_unlock_read(mapping);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c56f63cec895..fb97d2023769 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1056,6 +1056,33 @@ static inline pfn_t page_to_pfn_t(struct page *page)
 	return pfn_to_pfn_t(page_to_pfn(page));
 }
 
+static inline int pfn_t_valid(pfn_t pfn)
+{
+	return pfn_valid(pfn_t_to_pfn(pfn));
+}
+
+#ifdef pfn_pte
+static inline pte_t pfn_t_pte(pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pte(pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
+
+#ifdef __HAVE_ARCH_PTE_DEVICE
+static inline bool pfn_t_devmap(pfn_t pfn)
+{
+	const unsigned long flags = PFN_DEV|PFN_MAP;
+
+	return (pfn.val & flags) == flags;
+}
+#else
+static inline bool pfn_t_devmap(pfn_t pfn)
+{
+	return false;
+}
+pte_t pte_mkdevmap(pte_t pte);
+#endif
+
 /*
  * Some inline functions in vmstat.h depend on page_zone()
  */
@@ -1847,6 +1874,10 @@ static inline void pgtable_pmd_page_dtor(struct page *page) {}
 
 #endif
 
+#ifndef pte_devmap
+#define pte_devmap(x) (0)
+#endif
+
 static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 {
 	spinlock_t *ptl = pmd_lockptr(mm, pmd);
@@ -2266,7 +2297,7 @@ int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn);
+			pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/mm/memory.c b/mm/memory.c
index ed00801ce0c7..bba5cfbdf1fe 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1500,7 +1500,7 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 EXPORT_SYMBOL(vm_insert_page);
 
 static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t prot)
+			pfn_t pfn, pgprot_t prot)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -1516,7 +1516,10 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 		goto out_unlock;
 
 	/* Ok, finally just insert the thing.. */
-	entry = pte_mkspecial(pfn_pte(pfn, prot));
+	if (pfn_t_devmap(pfn))
+		entry = pte_mkdevmap(pfn_t_pte(pfn, prot));
+	else
+		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
@@ -1566,14 +1569,14 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	if (track_pfn_insert(vma, &pgprot, pfn))
 		return -EINVAL;
 
-	ret = insert_pfn(vma, addr, pfn, pgprot);
+	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
 
 	return ret;
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn)
+			pfn_t pfn)
 {
 	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
 
@@ -1587,10 +1590,10 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
 	 * without pte special, it would there be refcounted as a normal page.
 	 */
-	if (!HAVE_PTE_SPECIAL && pfn_valid(pfn)) {
+	if (!HAVE_PTE_SPECIAL && pfn_t_valid(pfn)) {
 		struct page *page;
 
-		page = pfn_to_page(pfn);
+		page = pfn_t_to_page(pfn);
 		return insert_page(vma, addr, page, vma->vm_page_prot);
 	}
 	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
