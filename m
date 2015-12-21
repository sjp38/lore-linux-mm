Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 16B686B0012
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:45:33 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id u7so36201063pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:45:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id aj9si2104070pad.211.2015.12.20.21.45.32
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:45:32 -0800 (PST)
Subject: [-mm PATCH v4 11/18] mm, dax, gpu: convert vm_insert_mixed to pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:45:05 -0800
Message-ID: <20151221054505.34542.77632.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
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

Cc: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Airlie <airlied@linux.ie>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/include/asm/pgtable.h          |    5 +++++
 drivers/gpu/drm/exynos/exynos_drm_gem.c |    4 +++-
 drivers/gpu/drm/gma500/framebuffer.c    |    4 +++-
 drivers/gpu/drm/msm/msm_gem.c           |    4 +++-
 drivers/gpu/drm/omapdrm/omap_gem.c      |    7 +++++--
 drivers/gpu/drm/ttm/ttm_bo_vm.c         |    4 +++-
 fs/dax.c                                |    2 +-
 include/linux/mm.h                      |    2 +-
 include/linux/pfn_t.h                   |   27 +++++++++++++++++++++++++++
 mm/memory.c                             |   16 ++++++++++------
 10 files changed, 61 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 9ff592003afd..176b9c4403fc 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -250,6 +250,11 @@ static inline pte_t pte_mkspecial(pte_t pte)
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
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index 252eb301470c..32358c5e3db4 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -14,6 +14,7 @@
 
 #include <linux/shmem_fs.h>
 #include <linux/dma-buf.h>
+#include <linux/pfn_t.h>
 #include <drm/exynos_drm.h>
 
 #include "exynos_drm_drv.h"
@@ -490,7 +491,8 @@ int exynos_drm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 
 	pfn = page_to_pfn(exynos_gem->pages[page_offset]);
-	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+			__pfn_to_pfn_t(pfn, PFN_DEV));
 
 out:
 	switch (ret) {
diff --git a/drivers/gpu/drm/gma500/framebuffer.c b/drivers/gpu/drm/gma500/framebuffer.c
index 2eaf1b31c7bd..72bc979fa0dc 100644
--- a/drivers/gpu/drm/gma500/framebuffer.c
+++ b/drivers/gpu/drm/gma500/framebuffer.c
@@ -21,6 +21,7 @@
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/string.h>
+#include <linux/pfn_t.h>
 #include <linux/mm.h>
 #include <linux/tty.h>
 #include <linux/slab.h>
@@ -132,7 +133,8 @@ static int psbfb_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	for (i = 0; i < page_num; i++) {
 		pfn = (phys_addr >> PAGE_SHIFT);
 
-		ret = vm_insert_mixed(vma, address, pfn);
+		ret = vm_insert_mixed(vma, address,
+				__pfn_to_pfn_t(pfn, PFN_DEV));
 		if (unlikely((ret == -EBUSY) || (ret != 0 && i > 0)))
 			break;
 		else if (unlikely(ret != 0)) {
diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
index c76cc853b08a..3cedb8d5c855 100644
--- a/drivers/gpu/drm/msm/msm_gem.c
+++ b/drivers/gpu/drm/msm/msm_gem.c
@@ -18,6 +18,7 @@
 #include <linux/spinlock.h>
 #include <linux/shmem_fs.h>
 #include <linux/dma-buf.h>
+#include <linux/pfn_t.h>
 
 #include "msm_drv.h"
 #include "msm_gem.h"
@@ -222,7 +223,8 @@ int msm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	VERB("Inserting %p pfn %lx, pa %lx", vmf->virtual_address,
 			pfn, pfn << PAGE_SHIFT);
 
-	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+			__pfn_to_pfn_t(pfn, PFN_DEV));
 
 out_unlock:
 	mutex_unlock(&dev->struct_mutex);
diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
index 7ed08fdc4c42..ceba5459ceb7 100644
--- a/drivers/gpu/drm/omapdrm/omap_gem.c
+++ b/drivers/gpu/drm/omapdrm/omap_gem.c
@@ -19,6 +19,7 @@
 
 #include <linux/shmem_fs.h>
 #include <linux/spinlock.h>
+#include <linux/pfn_t.h>
 
 #include <drm/drm_vma_manager.h>
 
@@ -385,7 +386,8 @@ static int fault_1d(struct drm_gem_object *obj,
 	VERB("Inserting %p pfn %lx, pa %lx", vmf->virtual_address,
 			pfn, pfn << PAGE_SHIFT);
 
-	return vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+	return vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+			__pfn_to_pfn_t(pfn, PFN_DEV));
 }
 
 /* Special handling for the case of faulting in 2d tiled buffers */
@@ -478,7 +480,8 @@ static int fault_2d(struct drm_gem_object *obj,
 			pfn, pfn << PAGE_SHIFT);
 
 	for (i = n; i > 0; i--) {
-		vm_insert_mixed(vma, (unsigned long)vaddr, pfn);
+		vm_insert_mixed(vma, (unsigned long)vaddr,
+				__pfn_to_pfn_t(pfn, PFN_DEV));
 		pfn += usergart[fmt].stride_pfn;
 		vaddr += PAGE_SIZE * m;
 	}
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 8fb7213277cc..06d26dc438b2 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -35,6 +35,7 @@
 #include <ttm/ttm_placement.h>
 #include <drm/drm_vma_manager.h>
 #include <linux/mm.h>
+#include <linux/pfn_t.h>
 #include <linux/rbtree.h>
 #include <linux/module.h>
 #include <linux/uaccess.h>
@@ -229,7 +230,8 @@ static int ttm_bo_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		}
 
 		if (vma->vm_flags & VM_MIXEDMAP)
-			ret = vm_insert_mixed(&cvma, address, pfn);
+			ret = vm_insert_mixed(&cvma, address,
+					__pfn_to_pfn_t(pfn, PFN_DEV));
 		else
 			ret = vm_insert_pfn(&cvma, address, pfn);
 
diff --git a/fs/dax.c b/fs/dax.c
index 6b13d6cd9a9a..574763eed8a3 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -363,7 +363,7 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
-	error = vm_insert_mixed(vma, vaddr, pfn_t_to_pfn(dax.pfn));
+	error = vm_insert_mixed(vma, vaddr, dax.pfn);
 
  out:
 	i_mmap_unlock_read(mapping);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5d448a8600b3..957afd1b10a5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2117,7 +2117,7 @@ int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn);
+			pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index c557a0e0b20c..bdaa275d7623 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -64,4 +64,31 @@ static inline pfn_t page_to_pfn_t(struct page *page)
 {
 	return pfn_to_pfn_t(page_to_pfn(page));
 }
+
+static inline int pfn_t_valid(pfn_t pfn)
+{
+	return pfn_valid(pfn_t_to_pfn(pfn));
+}
+
+#ifdef CONFIG_MMU
+static inline pte_t pfn_t_pte(pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pte(pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
+
+#ifdef __HAVE_ARCH_PTE_DEVMAP
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
 #endif /* _LINUX_PFN_T_H_ */
diff --git a/mm/memory.c b/mm/memory.c
index a624219853ac..d328ea7542b1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -50,6 +50,7 @@
 #include <linux/export.h>
 #include <linux/delayacct.h>
 #include <linux/init.h>
+#include <linux/pfn_t.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
@@ -1500,7 +1501,7 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 EXPORT_SYMBOL(vm_insert_page);
 
 static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t prot)
+			pfn_t pfn, pgprot_t prot)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -1516,7 +1517,10 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 		goto out_unlock;
 
 	/* Ok, finally just insert the thing.. */
-	entry = pte_mkspecial(pfn_pte(pfn, prot));
+	if (pfn_t_devmap(pfn))
+		entry = pte_mkdevmap(pfn_t_pte(pfn, prot));
+	else
+		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
@@ -1566,14 +1570,14 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
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
 
@@ -1587,10 +1591,10 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
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
