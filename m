Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2236B02AA
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 18:37:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u144so509572wmu.1
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 15:37:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j137si17566223wmj.96.2016.11.01.15.37.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 15:37:32 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/20] mm: Change type of vmf->virtual_address
Date: Tue,  1 Nov 2016 23:36:07 +0100
Message-Id: <1478039794-20253-2-git-send-email-jack@suse.cz>
In-Reply-To: <1478039794-20253-1-git-send-email-jack@suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Every single user of vmf->virtual_address typed that entry to unsigned
long before doing anything with it. So just change the type of that
entry to unsigned long immediately.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 arch/powerpc/platforms/cell/spufs/file.c     |  4 ++--
 arch/x86/entry/vdso/vma.c                    |  4 ++--
 drivers/char/agp/alpha-agp.c                 |  2 +-
 drivers/char/mspec.c                         |  2 +-
 drivers/dax/dax.c                            |  2 +-
 drivers/gpu/drm/armada/armada_gem.c          |  2 +-
 drivers/gpu/drm/drm_vm.c                     |  9 ++++-----
 drivers/gpu/drm/etnaviv/etnaviv_gem.c        |  7 +++----
 drivers/gpu/drm/exynos/exynos_drm_gem.c      |  5 ++---
 drivers/gpu/drm/gma500/framebuffer.c         |  2 +-
 drivers/gpu/drm/gma500/gem.c                 |  5 ++---
 drivers/gpu/drm/i915/i915_gem.c              |  5 ++---
 drivers/gpu/drm/msm/msm_gem.c                |  7 +++----
 drivers/gpu/drm/omapdrm/omap_gem.c           | 17 +++++++----------
 drivers/gpu/drm/tegra/gem.c                  |  4 ++--
 drivers/gpu/drm/ttm/ttm_bo_vm.c              |  2 +-
 drivers/gpu/drm/udl/udl_gem.c                |  5 ++---
 drivers/gpu/drm/vgem/vgem_drv.c              |  2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c    |  5 ++---
 drivers/misc/cxl/context.c                   |  2 +-
 drivers/misc/sgi-gru/grumain.c               |  2 +-
 drivers/staging/android/ion/ion.c            |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c |  8 +++++---
 drivers/xen/privcmd.c                        |  2 +-
 fs/dax.c                                     |  4 ++--
 include/linux/mm.h                           |  2 +-
 mm/memory.c                                  |  7 +++----
 27 files changed, 55 insertions(+), 65 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index 06254467e4dd..f7b33a477b95 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -236,7 +236,7 @@ static int
 spufs_mem_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct spu_context *ctx	= vma->vm_file->private_data;
-	unsigned long address = (unsigned long)vmf->virtual_address;
+	unsigned long address = vmf->virtual_address;
 	unsigned long pfn, offset;
 
 	offset = vmf->pgoff << PAGE_SHIFT;
@@ -355,7 +355,7 @@ static int spufs_ps_fault(struct vm_area_struct *vma,
 		down_read(&current->mm->mmap_sem);
 	} else {
 		area = ctx->spu->problem_phys + ps_offs;
-		vm_insert_pfn(vma, (unsigned long)vmf->virtual_address,
+		vm_insert_pfn(vma, vmf->virtual_address,
 					(area + offset) >> PAGE_SHIFT);
 		spu_context_trace(spufs_ps_fault__insert, ctx, ctx->spu);
 	}
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index f840766659a8..113e0155c6b5 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -157,7 +157,7 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 		return VM_FAULT_SIGBUS;
 
 	if (sym_offset == image->sym_vvar_page) {
-		ret = vm_insert_pfn(vma, (unsigned long)vmf->virtual_address,
+		ret = vm_insert_pfn(vma, vmf->virtual_address,
 				    __pa_symbol(&__vvar_page) >> PAGE_SHIFT);
 	} else if (sym_offset == image->sym_pvclock_page) {
 		struct pvclock_vsyscall_time_info *pvti =
@@ -165,7 +165,7 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 		if (pvti && vclock_was_used(VCLOCK_PVCLOCK)) {
 			ret = vm_insert_pfn(
 				vma,
-				(unsigned long)vmf->virtual_address,
+				vmf->virtual_address,
 				__pa(pvti) >> PAGE_SHIFT);
 		}
 	}
diff --git a/drivers/char/agp/alpha-agp.c b/drivers/char/agp/alpha-agp.c
index 199b8e99f7d7..537b1dc14c9f 100644
--- a/drivers/char/agp/alpha-agp.c
+++ b/drivers/char/agp/alpha-agp.c
@@ -19,7 +19,7 @@ static int alpha_core_agp_vm_fault(struct vm_area_struct *vma,
 	unsigned long pa;
 	struct page *page;
 
-	dma_addr = (unsigned long)vmf->virtual_address - vma->vm_start
+	dma_addr = vmf->virtual_address - vma->vm_start
 						+ agp->aperture.bus_base;
 	pa = agp->ops->translate(agp, dma_addr);
 
diff --git a/drivers/char/mspec.c b/drivers/char/mspec.c
index f3f92d5fcda0..36eb17c16951 100644
--- a/drivers/char/mspec.c
+++ b/drivers/char/mspec.c
@@ -227,7 +227,7 @@ mspec_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * be because another thread has installed the pte first, so it
 	 * is no problem.
 	 */
-	vm_insert_pfn(vma, (unsigned long)vmf->virtual_address, pfn);
+	vm_insert_pfn(vma, vmf->virtual_address, pfn);
 
 	return VM_FAULT_NOPAGE;
 }
diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index 29f600f2c447..c4e9e5cdf9dd 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -381,7 +381,7 @@ static phys_addr_t pgoff_to_phys(struct dax_dev *dax_dev, pgoff_t pgoff,
 static int __dax_dev_fault(struct dax_dev *dax_dev, struct vm_area_struct *vma,
 		struct vm_fault *vmf)
 {
-	unsigned long vaddr = (unsigned long) vmf->virtual_address;
+	unsigned long vaddr = vmf->virtual_address;
 	struct device *dev = dax_dev->dev;
 	struct dax_region *dax_region;
 	int rc = VM_FAULT_SIGBUS;
diff --git a/drivers/gpu/drm/armada/armada_gem.c b/drivers/gpu/drm/armada/armada_gem.c
index cb8f0347b934..11cdd8f0273a 100644
--- a/drivers/gpu/drm/armada/armada_gem.c
+++ b/drivers/gpu/drm/armada/armada_gem.c
@@ -17,7 +17,7 @@
 static int armada_gem_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct armada_gem_object *obj = drm_to_armada_gem(vma->vm_private_data);
-	unsigned long addr = (unsigned long)vmf->virtual_address;
+	unsigned long addr = vmf->virtual_address;
 	unsigned long pfn = obj->phys_addr >> PAGE_SHIFT;
 	int ret;
 
diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
index caa4e4ca616d..47b1aed4a142 100644
--- a/drivers/gpu/drm/drm_vm.c
+++ b/drivers/gpu/drm/drm_vm.c
@@ -124,8 +124,7 @@ static int drm_do_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		 * Using vm_pgoff as a selector forces us to use this unusual
 		 * addressing scheme.
 		 */
-		resource_size_t offset = (unsigned long)vmf->virtual_address -
-			vma->vm_start;
+		resource_size_t offset = vmf->virtual_address - vma->vm_start;
 		resource_size_t baddr = map->offset + offset;
 		struct drm_agp_mem *agpmem;
 		struct page *page;
@@ -195,7 +194,7 @@ static int drm_do_vm_shm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (!map)
 		return VM_FAULT_SIGBUS;	/* Nothing allocated */
 
-	offset = (unsigned long)vmf->virtual_address - vma->vm_start;
+	offset = vmf->virtual_address - vma->vm_start;
 	i = (unsigned long)map->handle + offset;
 	page = vmalloc_to_page((void *)i);
 	if (!page)
@@ -301,7 +300,7 @@ static int drm_do_vm_dma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (!dma->pagelist)
 		return VM_FAULT_SIGBUS;	/* Nothing allocated */
 
-	offset = (unsigned long)vmf->virtual_address - vma->vm_start;	/* vm_[pg]off[set] should be 0 */
+	offset = vmf->virtual_address - vma->vm_start;	/* vm_[pg]off[set] should be 0 */
 	page_nr = offset >> PAGE_SHIFT; /* page_nr could just be vmf->pgoff */
 	page = virt_to_page((void *)dma->pagelist[page_nr]);
 
@@ -337,7 +336,7 @@ static int drm_do_vm_sg_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (!entry->pagelist)
 		return VM_FAULT_SIGBUS;	/* Nothing allocated */
 
-	offset = (unsigned long)vmf->virtual_address - vma->vm_start;
+	offset = vmf->virtual_address - vma->vm_start;
 	map_offset = map->offset - (unsigned long)dev->sg->virtual;
 	page_offset = (offset >> PAGE_SHIFT) + (map_offset >> PAGE_SHIFT);
 	page = entry->pagelist[page_offset];
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 5ce3603e6eac..4bfc8e67dbb0 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -202,15 +202,14 @@ int etnaviv_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 
 	/* We don't use vmf->pgoff since that has the fake offset: */
-	pgoff = ((unsigned long)vmf->virtual_address -
-			vma->vm_start) >> PAGE_SHIFT;
+	pgoff = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 
 	page = pages[pgoff];
 
-	VERB("Inserting %p pfn %lx, pa %lx", vmf->virtual_address,
+	VERB("Inserting %p pfn %lx, pa %lx", (void *)vmf->virtual_address,
 	     page_to_pfn(page), page_to_pfn(page) << PAGE_SHIFT);
 
-	ret = vm_insert_page(vma, (unsigned long)vmf->virtual_address, page);
+	ret = vm_insert_page(vma, vmf->virtual_address, page);
 
 out:
 	switch (ret) {
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index f2ae72ba7d5a..283305afa06a 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -455,8 +455,7 @@ int exynos_drm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	pgoff_t page_offset;
 	int ret;
 
-	page_offset = ((unsigned long)vmf->virtual_address -
-			vma->vm_start) >> PAGE_SHIFT;
+	page_offset = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 
 	if (page_offset >= (exynos_gem->size >> PAGE_SHIFT)) {
 		DRM_ERROR("invalid page offset\n");
@@ -465,7 +464,7 @@ int exynos_drm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 
 	pfn = page_to_pfn(exynos_gem->pages[page_offset]);
-	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+	ret = vm_insert_mixed(vma, vmf->virtual_address,
 			__pfn_to_pfn_t(pfn, PFN_DEV));
 
 out:
diff --git a/drivers/gpu/drm/gma500/framebuffer.c b/drivers/gpu/drm/gma500/framebuffer.c
index 0fcdce0817de..a6093bfa57bf 100644
--- a/drivers/gpu/drm/gma500/framebuffer.c
+++ b/drivers/gpu/drm/gma500/framebuffer.c
@@ -126,7 +126,7 @@ static int psbfb_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 				  psbfb->gtt->offset;
 
 	page_num = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
-	address = (unsigned long)vmf->virtual_address - (vmf->pgoff << PAGE_SHIFT);
+	address = vmf->virtual_address - (vmf->pgoff << PAGE_SHIFT);
 
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
diff --git a/drivers/gpu/drm/gma500/gem.c b/drivers/gpu/drm/gma500/gem.c
index 6d1cb6b370b1..a720c46f8ebb 100644
--- a/drivers/gpu/drm/gma500/gem.c
+++ b/drivers/gpu/drm/gma500/gem.c
@@ -197,15 +197,14 @@ int psb_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	/* Page relative to the VMA start - we must calculate this ourselves
 	   because vmf->pgoff is the fake GEM offset */
-	page_offset = ((unsigned long) vmf->virtual_address - vma->vm_start)
-				>> PAGE_SHIFT;
+	page_offset = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 
 	/* CPU view of the page, don't go via the GART for CPU writes */
 	if (r->stolen)
 		pfn = (dev_priv->stolen_base + r->offset) >> PAGE_SHIFT;
 	else
 		pfn = page_to_pfn(r->pages[page_offset]);
-	ret = vm_insert_pfn(vma, (unsigned long)vmf->virtual_address, pfn);
+	ret = vm_insert_pfn(vma, vmf->virtual_address, pfn);
 
 fail:
 	mutex_unlock(&dev_priv->mmap_mutex);
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index a77ce9983f69..b13d929b8cab 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2020,8 +2020,7 @@ int i915_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	intel_runtime_pm_get(dev_priv);
 
 	/* We don't use vmf->pgoff since that has the fake offset */
-	page_offset = ((unsigned long)vmf->virtual_address - vma->vm_start) >>
-		PAGE_SHIFT;
+	page_offset = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 
 	ret = i915_mutex_lock_interruptible(dev);
 	if (ret)
@@ -2112,7 +2111,7 @@ int i915_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 			obj->fault_mappable = true;
 		} else
 			ret = vm_insert_pfn(vma,
-					    (unsigned long)vmf->virtual_address,
+					    vmf->virtual_address,
 					    pfn + page_offset);
 	}
 unpin:
diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
index 85f3047e05ae..e099c43b9875 100644
--- a/drivers/gpu/drm/msm/msm_gem.c
+++ b/drivers/gpu/drm/msm/msm_gem.c
@@ -225,15 +225,14 @@ int msm_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 
 	/* We don't use vmf->pgoff since that has the fake offset: */
-	pgoff = ((unsigned long)vmf->virtual_address -
-			vma->vm_start) >> PAGE_SHIFT;
+	pgoff = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 
 	pfn = page_to_pfn(pages[pgoff]);
 
-	VERB("Inserting %p pfn %lx, pa %lx", vmf->virtual_address,
+	VERB("Inserting %p pfn %lx, pa %lx", (void *)vmf->virtual_address,
 			pfn, pfn << PAGE_SHIFT);
 
-	ret = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+	ret = vm_insert_mixed(vma, vmf->virtual_address,
 			__pfn_to_pfn_t(pfn, PFN_DEV));
 
 out_unlock:
diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
index 505dee0db973..2da0c8f06763 100644
--- a/drivers/gpu/drm/omapdrm/omap_gem.c
+++ b/drivers/gpu/drm/omapdrm/omap_gem.c
@@ -396,8 +396,7 @@ static int fault_1d(struct drm_gem_object *obj,
 	pgoff_t pgoff;
 
 	/* We don't use vmf->pgoff since that has the fake offset: */
-	pgoff = ((unsigned long)vmf->virtual_address -
-			vma->vm_start) >> PAGE_SHIFT;
+	pgoff = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 
 	if (omap_obj->pages) {
 		omap_gem_cpu_sync(obj, pgoff);
@@ -407,10 +406,10 @@ static int fault_1d(struct drm_gem_object *obj,
 		pfn = (omap_obj->paddr >> PAGE_SHIFT) + pgoff;
 	}
 
-	VERB("Inserting %p pfn %lx, pa %lx", vmf->virtual_address,
+	VERB("Inserting %p pfn %lx, pa %lx", (void *)vmf->virtual_address,
 			pfn, pfn << PAGE_SHIFT);
 
-	return vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
+	return vm_insert_mixed(vma, vmf->virtual_address,
 			__pfn_to_pfn_t(pfn, PFN_DEV));
 }
 
@@ -425,7 +424,7 @@ static int fault_2d(struct drm_gem_object *obj,
 	struct page *pages[64];  /* XXX is this too much to have on stack? */
 	unsigned long pfn;
 	pgoff_t pgoff, base_pgoff;
-	void __user *vaddr;
+	unsigned long vaddr;
 	int i, ret, slots;
 
 	/*
@@ -445,8 +444,7 @@ static int fault_2d(struct drm_gem_object *obj,
 	const int m = 1 + ((omap_obj->width << fmt) / PAGE_SIZE);
 
 	/* We don't use vmf->pgoff since that has the fake offset: */
-	pgoff = ((unsigned long)vmf->virtual_address -
-			vma->vm_start) >> PAGE_SHIFT;
+	pgoff = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 
 	/*
 	 * Actual address we start mapping at is rounded down to previous slot
@@ -501,12 +499,11 @@ static int fault_2d(struct drm_gem_object *obj,
 
 	pfn = entry->paddr >> PAGE_SHIFT;
 
-	VERB("Inserting %p pfn %lx, pa %lx", vmf->virtual_address,
+	VERB("Inserting %p pfn %lx, pa %lx", (void *)vmf->virtual_address,
 			pfn, pfn << PAGE_SHIFT);
 
 	for (i = n; i > 0; i--) {
-		vm_insert_mixed(vma, (unsigned long)vaddr,
-				__pfn_to_pfn_t(pfn, PFN_DEV));
+		vm_insert_mixed(vma, vaddr, __pfn_to_pfn_t(pfn, PFN_DEV));
 		pfn += priv->usergart[fmt].stride_pfn;
 		vaddr += PAGE_SIZE * m;
 	}
diff --git a/drivers/gpu/drm/tegra/gem.c b/drivers/gpu/drm/tegra/gem.c
index aa60d9909ea2..55c2d846fd85 100644
--- a/drivers/gpu/drm/tegra/gem.c
+++ b/drivers/gpu/drm/tegra/gem.c
@@ -427,10 +427,10 @@ static int tegra_bo_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (!bo->pages)
 		return VM_FAULT_SIGBUS;
 
-	offset = ((unsigned long)vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
+	offset = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 	page = bo->pages[offset];
 
-	err = vm_insert_page(vma, (unsigned long)vmf->virtual_address, page);
+	err = vm_insert_page(vma, vmf->virtual_address, page);
 	switch (err) {
 	case -EAGAIN:
 	case 0:
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index a6ed9d5e5167..9f703d7ea1a4 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -101,7 +101,7 @@ static int ttm_bo_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct page *page;
 	int ret;
 	int i;
-	unsigned long address = (unsigned long)vmf->virtual_address;
+	unsigned long address = vmf->virtual_address;
 	int retval = VM_FAULT_NOPAGE;
 	struct ttm_mem_type_manager *man =
 		&bdev->man[bo->mem.mem_type];
diff --git a/drivers/gpu/drm/udl/udl_gem.c b/drivers/gpu/drm/udl/udl_gem.c
index 818e70712b18..db3f5b912602 100644
--- a/drivers/gpu/drm/udl/udl_gem.c
+++ b/drivers/gpu/drm/udl/udl_gem.c
@@ -107,14 +107,13 @@ int udl_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	unsigned int page_offset;
 	int ret = 0;
 
-	page_offset = ((unsigned long)vmf->virtual_address - vma->vm_start) >>
-		PAGE_SHIFT;
+	page_offset = (vmf->virtual_address - vma->vm_start) >> PAGE_SHIFT;
 
 	if (!obj->pages)
 		return VM_FAULT_SIGBUS;
 
 	page = obj->pages[page_offset];
-	ret = vm_insert_page(vma, (unsigned long)vmf->virtual_address, page);
+	ret = vm_insert_page(vma, vmf->virtual_address, page);
 	switch (ret) {
 	case -EAGAIN:
 	case 0:
diff --git a/drivers/gpu/drm/vgem/vgem_drv.c b/drivers/gpu/drm/vgem/vgem_drv.c
index c15bafb06665..914c59960d76 100644
--- a/drivers/gpu/drm/vgem/vgem_drv.c
+++ b/drivers/gpu/drm/vgem/vgem_drv.c
@@ -54,7 +54,7 @@ static int vgem_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct drm_vgem_gem_object *obj = vma->vm_private_data;
 	/* We don't use vmf->pgoff since that has the fake offset */
-	unsigned long vaddr = (unsigned long)vmf->virtual_address;
+	unsigned long vaddr = vmf->virtual_address;
 	struct page *page;
 
 	page = shmem_read_mapping_page(file_inode(obj->base.filp)->i_mapping,
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index f300f060b3f3..eaa30933f51b 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -436,13 +436,12 @@ static int videobuf_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct page *page;
 
 	dprintk(3, "fault: fault @ %08lx [vma %08lx-%08lx]\n",
-		(unsigned long)vmf->virtual_address,
-		vma->vm_start, vma->vm_end);
+		vmf->virtual_address, vma->vm_start, vma->vm_end);
 
 	page = alloc_page(GFP_USER | __GFP_DMA32);
 	if (!page)
 		return VM_FAULT_OOM;
-	clear_user_highpage(page, (unsigned long)vmf->virtual_address);
+	clear_user_highpage(page, vmf->virtual_address);
 	vmf->page = page;
 
 	return 0;
diff --git a/drivers/misc/cxl/context.c b/drivers/misc/cxl/context.c
index c466ee2b0c97..76031a56cfb7 100644
--- a/drivers/misc/cxl/context.c
+++ b/drivers/misc/cxl/context.c
@@ -117,7 +117,7 @@ int cxl_context_init(struct cxl_context *ctx, struct cxl_afu *afu, bool master,
 static int cxl_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct cxl_context *ctx = vma->vm_file->private_data;
-	unsigned long address = (unsigned long)vmf->virtual_address;
+	unsigned long address = vmf->virtual_address;
 	u64 area, offset;
 
 	offset = vmf->pgoff << PAGE_SHIFT;
diff --git a/drivers/misc/sgi-gru/grumain.c b/drivers/misc/sgi-gru/grumain.c
index 1525870f460a..e06daa6c2a04 100644
--- a/drivers/misc/sgi-gru/grumain.c
+++ b/drivers/misc/sgi-gru/grumain.c
@@ -932,7 +932,7 @@ int gru_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	unsigned long paddr, vaddr;
 	unsigned long expires;
 
-	vaddr = (unsigned long)vmf->virtual_address;
+	vaddr = vmf->virtual_address;
 	gru_dbg(grudev, "vma %p, vaddr 0x%lx (0x%lx)\n",
 		vma, vaddr, GSEG_BASE(vaddr));
 	STAT(nopfn);
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index a2cf93b59016..da869117fb2f 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -1022,7 +1022,7 @@ static int ion_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	BUG_ON(!buffer->pages || !buffer->pages[vmf->pgoff]);
 
 	pfn = page_to_pfn(ion_buffer_page(buffer->pages[vmf->pgoff]));
-	ret = vm_insert_pfn(vma, (unsigned long)vmf->virtual_address, pfn);
+	ret = vm_insert_pfn(vma, vmf->virtual_address, pfn);
 	mutex_unlock(&buffer->lock);
 	if (ret)
 		return VM_FAULT_ERROR;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 94916dcc6caa..feaf77895727 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -1002,7 +1002,7 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 		       "page %p map %p index %lu flags %lx count %u priv %0lx: got addr %p type NOPAGE\n",
 		       vmf->page, vmf->page->mapping, vmf->page->index,
 		       (long)vmf->page->flags, page_count(vmf->page),
-		       page_private(vmf->page), vmf->virtual_address);
+		       page_private(vmf->page), (void *)vmf->virtual_address);
 		if (unlikely(!(cfio->ft_flags & VM_FAULT_LOCKED))) {
 			lock_page(vmf->page);
 			cfio->ft_flags |= VM_FAULT_LOCKED;
@@ -1013,12 +1013,14 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 	}
 
 	if (cfio->ft_flags & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV)) {
-		CDEBUG(D_PAGE, "got addr %p - SIGBUS\n", vmf->virtual_address);
+		CDEBUG(D_PAGE, "got addr %p - SIGBUS\n",
+		       (void *)vmf->virtual_address);
 		return -EFAULT;
 	}
 
 	if (cfio->ft_flags & VM_FAULT_OOM) {
-		CDEBUG(D_PAGE, "got addr %p - OOM\n", vmf->virtual_address);
+		CDEBUG(D_PAGE, "got addr %p - OOM\n",
+		       (void *)vmf->virtual_address);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 702040fe2001..731eb53aead3 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -602,7 +602,7 @@ static int privcmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	printk(KERN_DEBUG "privcmd_fault: vma=%p %lx-%lx, pgoff=%lx, uv=%p\n",
 	       vma, vma->vm_start, vma->vm_end,
-	       vmf->pgoff, vmf->virtual_address);
+	       vmf->pgoff, (void *)vmf->virtual_address);
 
 	return VM_FAULT_SIGBUS;
 }
diff --git a/fs/dax.c b/fs/dax.c
index cc025f82ef07..0dc251ca77b8 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -794,7 +794,7 @@ static int dax_insert_mapping(struct address_space *mapping,
 		struct block_device *bdev, sector_t sector, size_t size,
 		void **entryp, struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	unsigned long vaddr = (unsigned long)vmf->virtual_address;
+	unsigned long vaddr = vmf->virtual_address;
 	struct blk_dax_ctl dax = {
 		.sector = sector,
 		.size = size,
@@ -832,7 +832,7 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	struct inode *inode = mapping->host;
 	void *entry;
 	struct buffer_head bh;
-	unsigned long vaddr = (unsigned long)vmf->virtual_address;
+	unsigned long vaddr = vmf->virtual_address;
 	unsigned blkbits = inode->i_blkbits;
 	sector_t block;
 	pgoff_t size;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef815b9cd426..a5636d646022 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -295,7 +295,7 @@ struct vm_fault {
 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
 	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
 	pgoff_t pgoff;			/* Logical page offset based on vma */
-	void __user *virtual_address;	/* Faulting virtual address */
+	unsigned long virtual_address;	/* Faulting virtual address */
 
 	struct page *cow_page;		/* Handler may choose to COW */
 	struct page *page;		/* ->fault handlers should return a
diff --git a/mm/memory.c b/mm/memory.c
index 793fe0f9841c..406b8728e141 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2040,7 +2040,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 	struct vm_fault vmf;
 	int ret;
 
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.virtual_address = address & PAGE_MASK;
 	vmf.pgoff = page->index;
 	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 	vmf.gfp_mask = __get_fault_gfp_mask(vma);
@@ -2275,8 +2275,7 @@ static int wp_pfn_shared(struct fault_env *fe,  pte_t orig_pte)
 		struct vm_fault vmf = {
 			.page = NULL,
 			.pgoff = linear_page_index(vma, fe->address),
-			.virtual_address =
-				(void __user *)(fe->address & PAGE_MASK),
+			.virtual_address = fe->address & PAGE_MASK,
 			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
 		};
 		int ret;
@@ -2850,7 +2849,7 @@ static int __do_fault(struct fault_env *fe, pgoff_t pgoff,
 	struct vm_fault vmf;
 	int ret;
 
-	vmf.virtual_address = (void __user *)(fe->address & PAGE_MASK);
+	vmf.virtual_address = fe->address & PAGE_MASK;
 	vmf.pgoff = pgoff;
 	vmf.flags = fe->flags;
 	vmf.page = NULL;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
