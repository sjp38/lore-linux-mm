Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 5EBC96B0062
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:35:09 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n8so4878076lbj.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:35:08 -0700 (PDT)
Subject: [PATCH v3 10/10] mm: kill vma flag VM_RESERVED and mm->reserved_vm
 counter
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:35:03 +0400
Message-ID: <20120731103503.20182.94365.stgit@zurg>
In-Reply-To: <20120731102546.20182.8450.stgit@zurg>
References: <20120731102546.20182.8450.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

A long time ago, in v2.4, VM_RESERVED kept swapout process off VMA,
currently it lost original meaning but still has some effects:

 | effect                 | alternative flags
-+------------------------+---------------------------------------------
1| account as reserved_vm | VM_IO
2| skip in core dump      | VM_IO, VM_DONTDUMP
3| do not merge or expand | VM_IO, VM_DONTEXPAND, VM_HUGETLB, VM_PFNMAP
4| do not mlock           | VM_IO, VM_DONTEXPAND, VM_HUGETLB, VM_PFNMAP

This patch removes reserved_vm counter from mm_struct.
Seems like nobody cares about it, it does not exported into userspace directly,
it only reduces total_vm showed in proc.

Thus VM_RESERVED can be replaced with VM_IO or pair VM_DONTEXPAND | VM_DONTDUMP.

remap_pfn_range() and io_remap_pfn_range() set VM_IO|VM_DONTEXPAND|VM_DONTDUMP.
remap_vmalloc_range() set VM_DONTEXPAND | VM_DONTDUMP.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Hugh Dickins <hughd@google.com>
---
 Documentation/vm/unevictable-lru.txt             |    4 ++--
 arch/alpha/kernel/pci-sysfs.c                    |    2 +-
 arch/ia64/kernel/perfmon.c                       |    2 +-
 arch/ia64/mm/init.c                              |    3 ++-
 arch/powerpc/kvm/book3s_hv.c                     |    2 +-
 arch/sparc/kernel/pci.c                          |    2 +-
 arch/unicore32/kernel/process.c                  |    2 +-
 arch/x86/xen/mmu.c                               |    3 +--
 drivers/char/mbcs.c                              |    2 +-
 drivers/char/mem.c                               |    2 +-
 drivers/char/mspec.c                             |    2 +-
 drivers/gpu/drm/drm_gem.c                        |    2 +-
 drivers/gpu/drm/drm_vm.c                         |   10 ++--------
 drivers/gpu/drm/exynos/exynos_drm_gem.c          |    2 +-
 drivers/gpu/drm/gma500/framebuffer.c             |    3 +--
 drivers/gpu/drm/ttm/ttm_bo_vm.c                  |    4 ++--
 drivers/gpu/drm/udl/udl_fb.c                     |    2 +-
 drivers/infiniband/hw/ehca/ehca_uverbs.c         |    4 ++--
 drivers/infiniband/hw/ipath/ipath_file_ops.c     |    2 +-
 drivers/infiniband/hw/qib/qib_file_ops.c         |    2 +-
 drivers/media/video/meye.c                       |    2 +-
 drivers/media/video/omap/omap_vout.c             |    2 +-
 drivers/media/video/sn9c102/sn9c102_core.c       |    3 +--
 drivers/media/video/usbvision/usbvision-video.c  |    3 +--
 drivers/media/video/videobuf-dma-sg.c            |    2 +-
 drivers/media/video/videobuf-vmalloc.c           |    2 +-
 drivers/media/video/videobuf2-memops.c           |    2 +-
 drivers/media/video/vino.c                       |    2 +-
 drivers/misc/carma/carma-fpga.c                  |    2 --
 drivers/misc/sgi-gru/grufile.c                   |    5 ++---
 drivers/mtd/mtdchar.c                            |    2 +-
 drivers/scsi/sg.c                                |    2 +-
 drivers/staging/media/easycap/easycap_main.c     |    2 +-
 drivers/staging/omapdrm/omap_gem_dmabuf.c        |    2 +-
 drivers/staging/tidspbridge/rmgr/drv_interface.c |    2 +-
 drivers/uio/uio.c                                |    4 +---
 drivers/usb/mon/mon_bin.c                        |    2 +-
 drivers/video/68328fb.c                          |    2 +-
 drivers/video/aty/atyfb_base.c                   |    3 +--
 drivers/video/fb-puv3.c                          |    3 +--
 drivers/video/fb_defio.c                         |    2 +-
 drivers/video/fbmem.c                            |    3 +--
 drivers/video/gbefb.c                            |    2 +-
 drivers/video/omap2/omapfb/omapfb-main.c         |    2 +-
 drivers/video/sbuslib.c                          |    5 ++---
 drivers/video/smscufx.c                          |    1 -
 drivers/video/udlfb.c                            |    1 -
 drivers/video/vermilion/vermilion.c              |    1 -
 drivers/video/vfb.c                              |    1 -
 drivers/xen/gntalloc.c                           |    2 +-
 drivers/xen/gntdev.c                             |    2 +-
 drivers/xen/privcmd.c                            |    3 ++-
 fs/binfmt_elf.c                                  |    2 +-
 fs/binfmt_elf_fdpic.c                            |    2 +-
 fs/hugetlbfs/inode.c                             |    2 +-
 fs/proc/task_mmu.c                               |    2 +-
 include/linux/mempolicy.h                        |    2 +-
 include/linux/mm.h                               |    3 +--
 include/linux/mm_types.h                         |    1 -
 kernel/events/core.c                             |    2 +-
 mm/ksm.c                                         |    3 +--
 mm/memory.c                                      |   11 +++++------
 mm/mlock.c                                       |    2 +-
 mm/mmap.c                                        |    2 --
 mm/nommu.c                                       |    2 +-
 mm/vmalloc.c                                     |    3 +--
 security/selinux/selinuxfs.c                     |    2 +-
 sound/core/pcm_native.c                          |    6 +++---
 sound/usb/usx2y/us122l.c                         |    2 +-
 sound/usb/usx2y/usX2Yhwdep.c                     |    2 +-
 sound/usb/usx2y/usx2yhwdeppcm.c                  |    2 +-
 71 files changed, 78 insertions(+), 106 deletions(-)

diff --git a/Documentation/vm/unevictable-lru.txt b/Documentation/vm/unevictable-lru.txt
index fa206cc..323ff5d 100644
--- a/Documentation/vm/unevictable-lru.txt
+++ b/Documentation/vm/unevictable-lru.txt
@@ -371,8 +371,8 @@ mlock_fixup() filters several classes of "special" VMAs:
    mlock_fixup() will call make_pages_present() in the hugetlbfs VMA range to
    allocate the huge pages and populate the ptes.
 
-3) VMAs with VM_DONTEXPAND or VM_RESERVED are generally userspace mappings of
-   kernel pages, such as the VDSO page, relay channel pages, etc.  These pages
+3) VMAs with VM_DONTEXPAND are generally userspace mappings of kernel pages,
+   such as the VDSO page, relay channel pages, etc. These pages
    are inherently unevictable and are not managed on the LRU lists.
    mlock_fixup() treats these VMAs the same as hugetlbfs VMAs.  It calls
    make_pages_present() to populate the ptes.
diff --git a/arch/alpha/kernel/pci-sysfs.c b/arch/alpha/kernel/pci-sysfs.c
index 53649c7..b51f7b4 100644
--- a/arch/alpha/kernel/pci-sysfs.c
+++ b/arch/alpha/kernel/pci-sysfs.c
@@ -26,7 +26,7 @@ static int hose_mmap_page_range(struct pci_controller *hose,
 		base = sparse ? hose->sparse_io_base : hose->dense_io_base;
 
 	vma->vm_pgoff += base >> PAGE_SHIFT;
-	vma->vm_flags |= (VM_IO | VM_RESERVED);
+	vma->vm_flags |= VM_IO | VM_DONTEXPAND | VM_DONTDUMP;
 
 	return io_remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
 				  vma->vm_end - vma->vm_start,
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index d7f558c..aada4a2 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2307,7 +2307,7 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 	 */
 	vma->vm_mm	     = mm;
 	vma->vm_file	     = filp;
-	vma->vm_flags	     = VM_READ| VM_MAYREAD |VM_RESERVED;
+	vma->vm_flags	     = VM_READ | VM_MAYREAD | VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_page_prot    = PAGE_READONLY; /* XXX may need to change */
 
 	/*
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 0eab454..082e383 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -138,7 +138,8 @@ ia64_init_addr_space (void)
 			vma->vm_mm = current->mm;
 			vma->vm_end = PAGE_SIZE;
 			vma->vm_page_prot = __pgprot(pgprot_val(PAGE_READONLY) | _PAGE_MA_NAT);
-			vma->vm_flags = VM_READ | VM_MAYREAD | VM_IO | VM_RESERVED;
+			vma->vm_flags = VM_READ | VM_MAYREAD | VM_IO |
+					VM_DONTEXPAND | VM_DONTDUMP;
 			down_write(&current->mm->mmap_sem);
 			if (insert_vm_struct(current->mm, vma)) {
 				up_write(&current->mm->mmap_sem);
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 83e929e..721d460 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1183,7 +1183,7 @@ static const struct vm_operations_struct kvm_rma_vm_ops = {
 
 static int kvm_rma_mmap(struct file *file, struct vm_area_struct *vma)
 {
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = &kvm_rma_vm_ops;
 	return 0;
 }
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 065b88c..1afda82 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -783,7 +783,7 @@ static int __pci_mmap_make_offset(struct pci_dev *pdev,
 static void __pci_mmap_set_flags(struct pci_dev *dev, struct vm_area_struct *vma,
 					    enum pci_mmap_state mmap_state)
 {
-	vma->vm_flags |= (VM_IO | VM_RESERVED);
+	vma->vm_flags |= VM_IO | VM_DONTEXPAND | VM_DONTDUMP;
 }
 
 /* Set vm_page_prot of VMA, as appropriate for this architecture, for a pci
diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/process.c
index b6f0458..b008586 100644
--- a/arch/unicore32/kernel/process.c
+++ b/arch/unicore32/kernel/process.c
@@ -380,7 +380,7 @@ int vectors_user_mapping(void)
 	return install_special_mapping(mm, 0xffff0000, PAGE_SIZE,
 				       VM_READ | VM_EXEC |
 				       VM_MAYREAD | VM_MAYEXEC |
-				       VM_RESERVED,
+				       VM_DONTEXPAND | VM_DONTDUMP,
 				       NULL);
 }
 
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index b65a761..4c5a404 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -2339,8 +2339,7 @@ int xen_remap_domain_mfn_range(struct vm_area_struct *vma,
 
 	prot = __pgprot(pgprot_val(prot) | _PAGE_IOMAP);
 
-	BUG_ON(!((vma->vm_flags & (VM_PFNMAP | VM_RESERVED | VM_IO)) ==
-				(VM_PFNMAP | VM_RESERVED | VM_IO)));
+	BUG_ON(!((vma->vm_flags & (VM_PFNMAP | VM_IO)) == (VM_PFNMAP | VM_IO)));
 
 	rmd.mfn = mfn;
 	rmd.prot = prot;
diff --git a/drivers/char/mbcs.c b/drivers/char/mbcs.c
index 47ff7e4..161b109 100644
--- a/drivers/char/mbcs.c
+++ b/drivers/char/mbcs.c
@@ -507,7 +507,7 @@ static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma)
 
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
-	/* Remap-pfn-range will mark the range VM_IO and VM_RESERVED */
+	/* Remap-pfn-range will mark the range VM_IO */
 	if (remap_pfn_range(vma,
 			    vma->vm_start,
 			    __pa(soft->gscr_addr) >> PAGE_SHIFT,
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index e5eedfa..0537903 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -322,7 +322,7 @@ static int mmap_mem(struct file *file, struct vm_area_struct *vma)
 
 	vma->vm_ops = &mmap_mem_ops;
 
-	/* Remap-pfn-range will mark the range VM_IO and VM_RESERVED */
+	/* Remap-pfn-range will mark the range VM_IO */
 	if (remap_pfn_range(vma,
 			    vma->vm_start,
 			    vma->vm_pgoff,
diff --git a/drivers/char/mspec.c b/drivers/char/mspec.c
index 845f97f..e1f60f9 100644
--- a/drivers/char/mspec.c
+++ b/drivers/char/mspec.c
@@ -286,7 +286,7 @@ mspec_mmap(struct file *file, struct vm_area_struct *vma,
 	atomic_set(&vdata->refcnt, 1);
 	vma->vm_private_data = vdata;
 
-	vma->vm_flags |= (VM_IO | VM_RESERVED | VM_PFNMAP | VM_DONTEXPAND);
+	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
 	if (vdata->type == MSPEC_FETCHOP || vdata->type == MSPEC_UNCACHED)
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 	vma->vm_ops = &mspec_vm_ops;
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index fbe0842..611c99d 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -706,7 +706,7 @@ int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 		goto out_unlock;
 	}
 
-	vma->vm_flags |= VM_RESERVED | VM_IO | VM_PFNMAP | VM_DONTEXPAND;
+	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = obj->dev->driver->gem_vm_ops;
 	vma->vm_private_data = map->handle;
 	vma->vm_page_prot =  pgprot_writecombine(vm_get_page_prot(vma->vm_flags));
diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
index 961ee08..0b2f54d 100644
--- a/drivers/gpu/drm/drm_vm.c
+++ b/drivers/gpu/drm/drm_vm.c
@@ -514,8 +514,7 @@ static int drm_mmap_dma(struct file *filp, struct vm_area_struct *vma)
 
 	vma->vm_ops = &drm_vm_dma_ops;
 
-	vma->vm_flags |= VM_RESERVED;	/* Don't swap */
-	vma->vm_flags |= VM_DONTEXPAND;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 
 	drm_vm_open_locked(dev, vma);
 	return 0;
@@ -652,21 +651,16 @@ int drm_mmap_locked(struct file *filp, struct vm_area_struct *vma)
 	case _DRM_SHM:
 		vma->vm_ops = &drm_vm_shm_ops;
 		vma->vm_private_data = (void *)map;
-		/* Don't let this area swap.  Change when
-		   DRM_KERNEL advisory is supported. */
-		vma->vm_flags |= VM_RESERVED;
 		break;
 	case _DRM_SCATTER_GATHER:
 		vma->vm_ops = &drm_vm_sg_ops;
 		vma->vm_private_data = (void *)map;
-		vma->vm_flags |= VM_RESERVED;
 		vma->vm_page_prot = drm_dma_prot(map->type, vma);
 		break;
 	default:
 		return -EINVAL;	/* This should never happen. */
 	}
-	vma->vm_flags |= VM_RESERVED;	/* Don't swap */
-	vma->vm_flags |= VM_DONTEXPAND;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 
 	drm_vm_open_locked(dev, vma);
 	return 0;
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index f9efde4..c9a1637 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -501,7 +501,7 @@ static int exynos_drm_gem_mmap_buffer(struct file *filp,
 
 	DRM_DEBUG_KMS("%s\n", __FILE__);
 
-	vma->vm_flags |= (VM_IO | VM_RESERVED);
+	vma->vm_flags |= VM_IO | VM_DONTEXPAND | VM_DONTDUMP;
 
 	update_vm_cache_attr(exynos_gem_obj, vma);
 
diff --git a/drivers/gpu/drm/gma500/framebuffer.c b/drivers/gpu/drm/gma500/framebuffer.c
index 5732b57..1c60632 100644
--- a/drivers/gpu/drm/gma500/framebuffer.c
+++ b/drivers/gpu/drm/gma500/framebuffer.c
@@ -178,8 +178,7 @@ static int psbfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
 	 */
 	vma->vm_ops = &psbfb_vm_ops;
 	vma->vm_private_data = (void *)psbfb;
-	vma->vm_flags |= VM_RESERVED | VM_IO |
-					VM_MIXEDMAP | VM_DONTEXPAND;
+	vma->vm_flags |= VM_IO | VM_MIXEDMAP | VM_DONTEXPAND | VM_DONTDUMP;
 	return 0;
 }
 
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index a877813..3ba72db 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -285,7 +285,7 @@ int ttm_bo_mmap(struct file *filp, struct vm_area_struct *vma,
 	 */
 
 	vma->vm_private_data = bo;
-	vma->vm_flags |= VM_RESERVED | VM_IO | VM_MIXEDMAP | VM_DONTEXPAND;
+	vma->vm_flags |= VM_IO | VM_MIXEDMAP | VM_DONTEXPAND | VM_DONTDUMP;
 	return 0;
 out_unref:
 	ttm_bo_unref(&bo);
@@ -300,7 +300,7 @@ int ttm_fbdev_mmap(struct vm_area_struct *vma, struct ttm_buffer_object *bo)
 
 	vma->vm_ops = &ttm_bo_vm_ops;
 	vma->vm_private_data = ttm_bo_reference(bo);
-	vma->vm_flags |= VM_RESERVED | VM_IO | VM_MIXEDMAP | VM_DONTEXPAND;
+	vma->vm_flags |= VM_IO | VM_MIXEDMAP | VM_DONTEXPAND;
 	return 0;
 }
 EXPORT_SYMBOL(ttm_fbdev_mmap);
diff --git a/drivers/gpu/drm/udl/udl_fb.c b/drivers/gpu/drm/udl/udl_fb.c
index ce9a611..0ac95a9 100644
--- a/drivers/gpu/drm/udl/udl_fb.c
+++ b/drivers/gpu/drm/udl/udl_fb.c
@@ -243,7 +243,7 @@ static int udl_fb_mmap(struct fb_info *info, struct vm_area_struct *vma)
 			size = 0;
 	}
 
-	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by remap_pfn_range() */
 	return 0;
 }
 
diff --git a/drivers/infiniband/hw/ehca/ehca_uverbs.c b/drivers/infiniband/hw/ehca/ehca_uverbs.c
index 45ee89b..1a1d5d9 100644
--- a/drivers/infiniband/hw/ehca/ehca_uverbs.c
+++ b/drivers/infiniband/hw/ehca/ehca_uverbs.c
@@ -117,7 +117,7 @@ static int ehca_mmap_fw(struct vm_area_struct *vma, struct h_galpas *galpas,
 	physical = galpas->user.fw_handle;
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 	ehca_gen_dbg("vsize=%llx physical=%llx", vsize, physical);
-	/* VM_IO | VM_RESERVED are set by remap_pfn_range() */
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by remap_pfn_range() */
 	ret = remap_4k_pfn(vma, vma->vm_start, physical >> EHCA_PAGESHIFT,
 			   vma->vm_page_prot);
 	if (unlikely(ret)) {
@@ -139,7 +139,7 @@ static int ehca_mmap_queue(struct vm_area_struct *vma, struct ipz_queue *queue,
 	u64 start, ofs;
 	struct page *page;
 
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	start = vma->vm_start;
 	for (ofs = 0; ofs < queue->queue_length; ofs += PAGE_SIZE) {
 		u64 virt_addr = (u64)ipz_qeit_calc(queue, ofs);
diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
index 736d9ed..3eb7e45 100644
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -1225,7 +1225,7 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u64 pgaddr,
 
 	vma->vm_pgoff = (unsigned long) addr >> PAGE_SHIFT;
 	vma->vm_ops = &ipath_file_vm_ops;
-	vma->vm_flags |= VM_RESERVED | VM_DONTEXPAND;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	ret = 1;
 
 bail:
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index faa44cb..959a5c4 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -971,7 +971,7 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u64 pgaddr,
 
 	vma->vm_pgoff = (unsigned long) addr >> PAGE_SHIFT;
 	vma->vm_ops = &qib_file_vm_ops;
-	vma->vm_flags |= VM_RESERVED | VM_DONTEXPAND;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	ret = 1;
 
 bail:
diff --git a/drivers/media/video/meye.c b/drivers/media/video/meye.c
index 7bc7752..e5a76da 100644
--- a/drivers/media/video/meye.c
+++ b/drivers/media/video/meye.c
@@ -1647,7 +1647,7 @@ static int meye_mmap(struct file *file, struct vm_area_struct *vma)
 
 	vma->vm_ops = &meye_vm_ops;
 	vma->vm_flags &= ~VM_IO;	/* not I/O memory */
-	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_private_data = (void *) (offset / gbufsize);
 	meye_vm_open(vma);
 
diff --git a/drivers/media/video/omap/omap_vout.c b/drivers/media/video/omap/omap_vout.c
index 88cf9d9..45797aa 100644
--- a/drivers/media/video/omap/omap_vout.c
+++ b/drivers/media/video/omap/omap_vout.c
@@ -910,7 +910,7 @@ static int omap_vout_mmap(struct file *file, struct vm_area_struct *vma)
 
 	q->bufs[i]->baddr = vma->vm_start;
 
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 	vma->vm_ops = &omap_vout_vm_ops;
 	vma->vm_private_data = (void *) vout;
diff --git a/drivers/media/video/sn9c102/sn9c102_core.c b/drivers/media/video/sn9c102/sn9c102_core.c
index 19ea780..5bfc8e2 100644
--- a/drivers/media/video/sn9c102/sn9c102_core.c
+++ b/drivers/media/video/sn9c102/sn9c102_core.c
@@ -2126,8 +2126,7 @@ static int sn9c102_mmap(struct file* filp, struct vm_area_struct *vma)
 		return -EINVAL;
 	}
 
-	vma->vm_flags |= VM_IO;
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_IO | VM_DONTEXPAND | VM_DONTDUMP;
 
 	pos = cam->frame[i].bufmem;
 	while (size > 0) { /* size is page-aligned */
diff --git a/drivers/media/video/usbvision/usbvision-video.c b/drivers/media/video/usbvision/usbvision-video.c
index 9bd8f08..ea1481b 100644
--- a/drivers/media/video/usbvision/usbvision-video.c
+++ b/drivers/media/video/usbvision/usbvision-video.c
@@ -1090,8 +1090,7 @@ static int usbvision_v4l2_mmap(struct file *file, struct vm_area_struct *vma)
 	}
 
 	/* VM_IO is eventually going to replace PageReserved altogether */
-	vma->vm_flags |= VM_IO;
-	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
+	vma->vm_flags |= VM_IO | VM_DONTEXPAND | VM_DONTDUMP;
 
 	pos = usbvision->frame[i].data;
 	while (size > 0) {
diff --git a/drivers/media/video/videobuf-dma-sg.c b/drivers/media/video/videobuf-dma-sg.c
index f300dea..828e7c1 100644
--- a/drivers/media/video/videobuf-dma-sg.c
+++ b/drivers/media/video/videobuf-dma-sg.c
@@ -582,7 +582,7 @@ static int __videobuf_mmap_mapper(struct videobuf_queue *q,
 	map->count    = 1;
 	map->q        = q;
 	vma->vm_ops   = &videobuf_vm_ops;
-	vma->vm_flags |= VM_DONTEXPAND | VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_flags &= ~VM_IO; /* using shared anonymous pages */
 	vma->vm_private_data = map;
 	dprintk(1, "mmap %p: q=%p %08lx-%08lx pgoff %08lx bufs %d-%d\n",
diff --git a/drivers/media/video/videobuf-vmalloc.c b/drivers/media/video/videobuf-vmalloc.c
index df14258..2ff7fcc 100644
--- a/drivers/media/video/videobuf-vmalloc.c
+++ b/drivers/media/video/videobuf-vmalloc.c
@@ -270,7 +270,7 @@ static int __videobuf_mmap_mapper(struct videobuf_queue *q,
 	}
 
 	vma->vm_ops          = &videobuf_vm_ops;
-	vma->vm_flags       |= VM_DONTEXPAND | VM_RESERVED;
+	vma->vm_flags       |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_private_data = map;
 
 	dprintk(1, "mmap %p: q=%p %08lx-%08lx (%lx) pgoff %08lx buf %d\n",
diff --git a/drivers/media/video/videobuf2-memops.c b/drivers/media/video/videobuf2-memops.c
index 504cd4c..051ea35 100644
--- a/drivers/media/video/videobuf2-memops.c
+++ b/drivers/media/video/videobuf2-memops.c
@@ -163,7 +163,7 @@ int vb2_mmap_pfn_range(struct vm_area_struct *vma, unsigned long paddr,
 		return ret;
 	}
 
-	vma->vm_flags		|= VM_DONTEXPAND | VM_RESERVED;
+	vma->vm_flags		|= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_private_data	= priv;
 	vma->vm_ops		= vm_ops;
 
diff --git a/drivers/media/video/vino.c b/drivers/media/video/vino.c
index aae1720..cc9110c 100644
--- a/drivers/media/video/vino.c
+++ b/drivers/media/video/vino.c
@@ -3950,7 +3950,7 @@ found:
 
 	fb->map_count = 1;
 
-	vma->vm_flags |= VM_DONTEXPAND | VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_flags &= ~VM_IO;
 	vma->vm_private_data = fb;
 	vma->vm_file = file;
diff --git a/drivers/misc/carma/carma-fpga.c b/drivers/misc/carma/carma-fpga.c
index 8c279da..e79b1a3 100644
--- a/drivers/misc/carma/carma-fpga.c
+++ b/drivers/misc/carma/carma-fpga.c
@@ -1243,8 +1243,6 @@ static int data_mmap(struct file *filp, struct vm_area_struct *vma)
 		return -EINVAL;
 	}
 
-	/* IO memory (stop cacheing) */
-	vma->vm_flags |= VM_IO | VM_RESERVED;
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
 	return io_remap_pfn_range(vma, vma->vm_start, addr, vsize,
diff --git a/drivers/misc/sgi-gru/grufile.c b/drivers/misc/sgi-gru/grufile.c
index ecafa4b..492c8ca 100644
--- a/drivers/misc/sgi-gru/grufile.c
+++ b/drivers/misc/sgi-gru/grufile.c
@@ -108,9 +108,8 @@ static int gru_file_mmap(struct file *file, struct vm_area_struct *vma)
 				vma->vm_end & (GRU_GSEG_PAGESIZE - 1))
 		return -EINVAL;
 
-	vma->vm_flags |=
-	    (VM_IO | VM_DONTCOPY | VM_LOCKED | VM_DONTEXPAND | VM_PFNMAP |
-			VM_RESERVED);
+	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_LOCKED |
+			 VM_DONTCOPY | VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_page_prot = PAGE_SHARED;
 	vma->vm_ops = &gru_vm_ops;
 
diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
index f2f482b..c4e01c5 100644
--- a/drivers/mtd/mtdchar.c
+++ b/drivers/mtd/mtdchar.c
@@ -1146,7 +1146,7 @@ static int mtdchar_mmap(struct file *file, struct vm_area_struct *vma)
 
 		off += start;
 		vma->vm_pgoff = off >> PAGE_SHIFT;
-		vma->vm_flags |= VM_IO | VM_RESERVED;
+		vma->vm_flags |= VM_IO | VM_DONTEXPAND | VM_DONTDUMP;
 
 #ifdef pgprot_noncached
 		if (file->f_flags & O_DSYNC || off >= __pa(high_memory))
diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index 9c5c5f2..be2c9a6 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -1257,7 +1257,7 @@ sg_mmap(struct file *filp, struct vm_area_struct *vma)
 	}
 
 	sfp->mmap_called = 1;
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_private_data = sfp;
 	vma->vm_ops = &sg_mmap_vm_ops;
 	return 0;
diff --git a/drivers/staging/media/easycap/easycap_main.c b/drivers/staging/media/easycap/easycap_main.c
index a1c45e4..81a4618 100644
--- a/drivers/staging/media/easycap/easycap_main.c
+++ b/drivers/staging/media/easycap/easycap_main.c
@@ -2246,7 +2246,7 @@ static int easycap_mmap(struct file *file, struct vm_area_struct *pvma)
 	JOT(8, "\n");
 
 	pvma->vm_ops = &easycap_vm_ops;
-	pvma->vm_flags |= VM_RESERVED;
+	pvma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	if (file)
 		pvma->vm_private_data = file->private_data;
 	easycap_vma_open(pvma);
diff --git a/drivers/staging/omapdrm/omap_gem_dmabuf.c b/drivers/staging/omapdrm/omap_gem_dmabuf.c
index 42728e0..c6f3ef6 100644
--- a/drivers/staging/omapdrm/omap_gem_dmabuf.c
+++ b/drivers/staging/omapdrm/omap_gem_dmabuf.c
@@ -160,7 +160,7 @@ static int omap_gem_dmabuf_mmap(struct dma_buf *buffer,
 		goto out_unlock;
 	}
 
-	vma->vm_flags |= VM_RESERVED | VM_IO | VM_PFNMAP | VM_DONTEXPAND;
+	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = obj->dev->driver->gem_vm_ops;
 	vma->vm_private_data = obj;
 	vma->vm_page_prot =  pgprot_writecombine(vm_get_page_prot(vma->vm_flags));
diff --git a/drivers/staging/tidspbridge/rmgr/drv_interface.c b/drivers/staging/tidspbridge/rmgr/drv_interface.c
index 3cac014..355e6a5 100644
--- a/drivers/staging/tidspbridge/rmgr/drv_interface.c
+++ b/drivers/staging/tidspbridge/rmgr/drv_interface.c
@@ -261,7 +261,7 @@ static int bridge_mmap(struct file *filp, struct vm_area_struct *vma)
 {
 	u32 status;
 
-	vma->vm_flags |= VM_RESERVED | VM_IO;
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by remap_pfn_range() */
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
 	dev_dbg(bridge, "%s: vm filp %p start %lx end %lx page_prot %ulx "
diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
index a783d53..5110f36 100644
--- a/drivers/uio/uio.c
+++ b/drivers/uio/uio.c
@@ -653,8 +653,6 @@ static int uio_mmap_physical(struct vm_area_struct *vma)
 	if (mi < 0)
 		return -EINVAL;
 
-	vma->vm_flags |= VM_IO | VM_RESERVED;
-
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
 	return remap_pfn_range(vma,
@@ -666,7 +664,7 @@ static int uio_mmap_physical(struct vm_area_struct *vma)
 
 static int uio_mmap_logical(struct vm_area_struct *vma)
 {
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = &uio_vm_ops;
 	uio_vma_open(vma);
 	return 0;
diff --git a/drivers/usb/mon/mon_bin.c b/drivers/usb/mon/mon_bin.c
index 91cd850..9a62e89 100644
--- a/drivers/usb/mon/mon_bin.c
+++ b/drivers/usb/mon/mon_bin.c
@@ -1247,7 +1247,7 @@ static int mon_bin_mmap(struct file *filp, struct vm_area_struct *vma)
 {
 	/* don't do anything here: "fault" will set up page table entries */
 	vma->vm_ops = &mon_bin_vm_ops;
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_private_data = filp->private_data;
 	mon_bin_vma_open(vma);
 	return 0;
diff --git a/drivers/video/68328fb.c b/drivers/video/68328fb.c
index a425d65..fa44fbe 100644
--- a/drivers/video/68328fb.c
+++ b/drivers/video/68328fb.c
@@ -400,7 +400,7 @@ static int mc68x328fb_mmap(struct fb_info *info, struct vm_area_struct *vma)
 #ifndef MMU
 	/* this is uClinux (no MMU) specific code */
 
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_start = videomemory;
 
 	return 0;
diff --git a/drivers/video/aty/atyfb_base.c b/drivers/video/aty/atyfb_base.c
index 3f2e8c1..868932f 100644
--- a/drivers/video/aty/atyfb_base.c
+++ b/drivers/video/aty/atyfb_base.c
@@ -1942,8 +1942,7 @@ static int atyfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
 	off = vma->vm_pgoff << PAGE_SHIFT;
 	size = vma->vm_end - vma->vm_start;
 
-	/* To stop the swapper from even considering these pages. */
-	vma->vm_flags |= (VM_IO | VM_RESERVED);
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by remap_pfn_range() */
 
 	if (((vma->vm_pgoff == 0) && (size == info->fix.smem_len)) ||
 	    ((off == info->fix.smem_len) && (size == PAGE_SIZE)))
diff --git a/drivers/video/fb-puv3.c b/drivers/video/fb-puv3.c
index 60a787f..7d106f1f 100644
--- a/drivers/video/fb-puv3.c
+++ b/drivers/video/fb-puv3.c
@@ -653,9 +653,8 @@ int unifb_mmap(struct fb_info *info,
 				vma->vm_page_prot))
 		return -EAGAIN;
 
-	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by remap_pfn_range() */
 	return 0;
-
 }
 
 static struct fb_ops unifb_ops = {
diff --git a/drivers/video/fb_defio.c b/drivers/video/fb_defio.c
index 1ddeb11..136ada5 100644
--- a/drivers/video/fb_defio.c
+++ b/drivers/video/fb_defio.c
@@ -164,7 +164,7 @@ static const struct address_space_operations fb_deferred_io_aops = {
 static int fb_deferred_io_mmap(struct fb_info *info, struct vm_area_struct *vma)
 {
 	vma->vm_ops = &fb_deferred_io_vm_ops;
-	vma->vm_flags |= ( VM_RESERVED | VM_DONTEXPAND );
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	if (!(info->flags & FBINFO_VIRTFB))
 		vma->vm_flags |= VM_IO;
 	vma->vm_private_data = info;
diff --git a/drivers/video/fbmem.c b/drivers/video/fbmem.c
index 0dff12a..3ff0105 100644
--- a/drivers/video/fbmem.c
+++ b/drivers/video/fbmem.c
@@ -1410,8 +1410,7 @@ fb_mmap(struct file *file, struct vm_area_struct * vma)
 		return -EINVAL;
 	off += start;
 	vma->vm_pgoff = off >> PAGE_SHIFT;
-	/* This is an IO map - tell maydump to skip this VMA */
-	vma->vm_flags |= VM_IO | VM_RESERVED;
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by io_remap_pfn_range()*/
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
 	fb_pgprotect(file, vma, off);
 	if (io_remap_pfn_range(vma, vma->vm_start, off >> PAGE_SHIFT,
diff --git a/drivers/video/gbefb.c b/drivers/video/gbefb.c
index 7e7b7a9..05e2a8a 100644
--- a/drivers/video/gbefb.c
+++ b/drivers/video/gbefb.c
@@ -1024,7 +1024,7 @@ static int gbefb_mmap(struct fb_info *info,
 	pgprot_val(vma->vm_page_prot) =
 		pgprot_fb(pgprot_val(vma->vm_page_prot));
 
-	vma->vm_flags |= VM_IO | VM_RESERVED;
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by remap_pfn_range() */
 
 	/* look for the starting tile */
 	tile = &gbe_tiles.cpu[offset >> TILE_SHIFT];
diff --git a/drivers/video/omap2/omapfb/omapfb-main.c b/drivers/video/omap2/omapfb/omapfb-main.c
index 3450ea0..3d8ff69 100644
--- a/drivers/video/omap2/omapfb/omapfb-main.c
+++ b/drivers/video/omap2/omapfb/omapfb-main.c
@@ -1123,7 +1123,7 @@ static int omapfb_mmap(struct fb_info *fbi, struct vm_area_struct *vma)
 	DBG("user mmap region start %lx, len %d, off %lx\n", start, len, off);
 
 	vma->vm_pgoff = off >> PAGE_SHIFT;
-	vma->vm_flags |= VM_IO | VM_RESERVED;
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by remap_pfn_range() */
 	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 	vma->vm_ops = &mmap_user_ops;
 	vma->vm_private_data = rg;
diff --git a/drivers/video/sbuslib.c b/drivers/video/sbuslib.c
index 3c1de98..296afae 100644
--- a/drivers/video/sbuslib.c
+++ b/drivers/video/sbuslib.c
@@ -57,9 +57,8 @@ int sbusfb_mmap_helper(struct sbus_mmap_map *map,
 
 	off = vma->vm_pgoff << PAGE_SHIFT;
 
-	/* To stop the swapper from even considering these pages */
-	vma->vm_flags |= (VM_IO | VM_RESERVED);
-	
+	/* VM_IO | VM_DONTEXPAND | VM_DONTDUMP are set by remap_pfn_range() */
+
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
 	/* Each page, see which map applies */
diff --git a/drivers/video/smscufx.c b/drivers/video/smscufx.c
index 26f8642..d6fbdcd 100644
--- a/drivers/video/smscufx.c
+++ b/drivers/video/smscufx.c
@@ -803,7 +803,6 @@ static int ufx_ops_mmap(struct fb_info *info, struct vm_area_struct *vma)
 			size = 0;
 	}
 
-	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
 	return 0;
 }
 
diff --git a/drivers/video/udlfb.c b/drivers/video/udlfb.c
index 8af6414..f45eba3 100644
--- a/drivers/video/udlfb.c
+++ b/drivers/video/udlfb.c
@@ -345,7 +345,6 @@ static int dlfb_ops_mmap(struct fb_info *info, struct vm_area_struct *vma)
 			size = 0;
 	}
 
-	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
 	return 0;
 }
 
diff --git a/drivers/video/vermilion/vermilion.c b/drivers/video/vermilion/vermilion.c
index 970e43d..89aef34 100644
--- a/drivers/video/vermilion/vermilion.c
+++ b/drivers/video/vermilion/vermilion.c
@@ -1018,7 +1018,6 @@ static int vmlfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
 	offset += vinfo->vram_start;
 	pgprot_val(vma->vm_page_prot) |= _PAGE_PCD;
 	pgprot_val(vma->vm_page_prot) &= ~_PAGE_PWT;
-	vma->vm_flags |= VM_RESERVED | VM_IO;
 	if (remap_pfn_range(vma, vma->vm_start, offset >> PAGE_SHIFT,
 						size, vma->vm_page_prot))
 		return -EAGAIN;
diff --git a/drivers/video/vfb.c b/drivers/video/vfb.c
index 501a922..c7f69252 100644
--- a/drivers/video/vfb.c
+++ b/drivers/video/vfb.c
@@ -439,7 +439,6 @@ static int vfb_mmap(struct fb_info *info,
 			size = 0;
 	}
 
-	vma->vm_flags |= VM_RESERVED;	/* avoid to swap out this VMA */
 	return 0;
 
 }
diff --git a/drivers/xen/gntalloc.c b/drivers/xen/gntalloc.c
index 934985d..4097987 100644
--- a/drivers/xen/gntalloc.c
+++ b/drivers/xen/gntalloc.c
@@ -535,7 +535,7 @@ static int gntalloc_mmap(struct file *filp, struct vm_area_struct *vma)
 
 	vma->vm_private_data = vm_priv;
 
-	vma->vm_flags |= VM_RESERVED | VM_DONTEXPAND;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 
 	vma->vm_ops = &gntalloc_vmops;
 
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 1ffd03b..ee87a98 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -719,7 +719,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 
 	vma->vm_ops = &gntdev_vmops;
 
-	vma->vm_flags |= VM_RESERVED|VM_DONTEXPAND;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 
 	if (use_ptemod)
 		vma->vm_flags |= VM_DONTCOPY;
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index ccee0f1..2f4a94e 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -386,7 +386,8 @@ static int privcmd_mmap(struct file *file, struct vm_area_struct *vma)
 
 	/* DONTCOPY is essential for Xen because copy_page_range doesn't know
 	 * how to recreate these mappings */
-	vma->vm_flags |= VM_RESERVED | VM_IO | VM_DONTCOPY | VM_PFNMAP;
+	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTCOPY |
+			 VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = &privcmd_vm_ops;
 	vma->vm_private_data = NULL;
 
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 3adcc4b..40c4ed5 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1127,7 +1127,7 @@ static unsigned long vma_dump_size(struct vm_area_struct *vma,
 	}
 
 	/* Do not dump I/O mapped devices or special mappings */
-	if (vma->vm_flags & (VM_IO | VM_RESERVED))
+	if (vma->vm_flags & VM_IO)
 		return 0;
 
 	/* By default, dump shared memory if mapped from an anonymous file. */
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index 3d77cf8..8db76e4 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1205,7 +1205,7 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 	int dump_ok;
 
 	/* Do not dump I/O mapped devices or special mappings */
-	if (vma->vm_flags & (VM_IO | VM_RESERVED)) {
+	if (vma->vm_flags & VM_IO) {
 		kdcore("%08lx: %08lx: no (IO)", vma->vm_start, vma->vm_flags);
 		return 0;
 	}
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index e13e9bd..b4267d1 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -110,7 +110,7 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	 * way when do_mmap_pgoff unwinds (may be important on powerpc
 	 * and ia64).
 	 */
-	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
+	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = &hugetlb_vm_ops;
 
 	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4540b8f..79827ce 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -54,7 +54,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmPTE:\t%8lu kB\n"
 		"VmSwap:\t%8lu kB\n",
 		hiwater_vm << (PAGE_SHIFT-10),
-		(total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
+		total_vm << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
 		mm->pinned_vm << (PAGE_SHIFT-10),
 		hiwater_rss << (PAGE_SHIFT-10),
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 95b738c..ba7a0ff 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -239,7 +239,7 @@ extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol,
 /* Check if a vma is migratable */
 static inline int vma_migratable(struct vm_area_struct *vma)
 {
-	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
+	if (vma->vm_flags & (VM_IO | VM_HUGETLB | VM_PFNMAP))
 		return 0;
 	/*
 	 * Migration allocates pages in the highest zone. If we cannot
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 21cad77..04d6196 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -96,7 +96,6 @@ extern unsigned int kobjsize(const void *objp);
 
 #define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
 #define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
-#define VM_RESERVED	0x00080000	/* Count as reserved_vm like IO */
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
@@ -148,7 +147,7 @@ extern unsigned int kobjsize(const void *objp);
  * Special vmas that are non-mergable, non-mlock()able.
  * Note: mm/huge_memory.c VM_NO_THP depends on this definition.
  */
-#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
+#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_PFNMAP)
 
 /*
  * mapping from the currently active vm_flags protection bits (the
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bbd221f..66f86d7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -340,7 +340,6 @@ struct mm_struct {
 	unsigned long shared_vm;	/* Shared pages (files) */
 	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
 	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
-	unsigned long reserved_vm;	/* VM_RESERVED|VM_IO pages */
 	unsigned long def_flags;
 	unsigned long nr_ptes;		/* Page table pages */
 	unsigned long start_code, end_code, start_data, end_data;
diff --git a/kernel/events/core.c b/kernel/events/core.c
index f1cf0ed..ccb53b3 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3669,7 +3669,7 @@ unlock:
 		atomic_inc(&event->mmap_count);
 	mutex_unlock(&event->mmap_mutex);
 
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = &perf_mmap_vmops;
 
 	return ret;
diff --git a/mm/ksm.c b/mm/ksm.c
index f9ccb16..9638620 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1469,8 +1469,7 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		 */
 		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
 				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_RESERVED  | VM_HUGETLB |
-				 VM_NONLINEAR | VM_MIXEDMAP))
+				 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP))
 			return 0;		/* just ignore the advice */
 
 #ifdef VM_SAO
diff --git a/mm/memory.c b/mm/memory.c
index 2fb27a0..183c475 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2294,14 +2294,13 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	 * rest of the world about it:
 	 *   VM_IO tells people not to look at these pages
 	 *	(accesses can have side effects).
-	 *   VM_RESERVED is specified all over the place, because
-	 *	in 2.4 it kept swapout's vma scan off this vma; but
-	 *	in 2.6 the LRU scan won't even find its pages, so this
-	 *	flag means no more than count its pages in reserved_vm,
-	 * 	and omit it from core dump, even when VM_IO turned off.
 	 *   VM_PFNMAP tells the core MM that the base pages are just
 	 *	raw PFN mappings, and do not have a "struct page" associated
 	 *	with them.
+	 *   VM_DONTEXPAND
+	 *      Disable vma merging and expanding with mremap().
+	 *   VM_DONTDUMP
+	 *      Omit vma from core dump, even when VM_IO turned off.
 	 *
 	 * There's a horrible special case to handle copy-on-write
 	 * behaviour that some programs depend on. We mark the "original"
@@ -2318,7 +2317,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	if (err)
 		return -EINVAL;
 
-	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
+	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
 
 	BUG_ON(addr >= end);
 	pfn -= addr >> PAGE_SHIFT;
diff --git a/mm/mlock.c b/mm/mlock.c
index ef726e8..a948be4 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -227,7 +227,7 @@ long mlock_vma_pages_range(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 		goto no_mlock;
 
-	if (!((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
+	if (!((vma->vm_flags & VM_DONTEXPAND) ||
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current->mm))) {
 
diff --git a/mm/mmap.c b/mm/mmap.c
index c9c0e7f..74838aa 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -943,8 +943,6 @@ void vm_stat_account(struct mm_struct *mm, unsigned long flags,
 			mm->exec_vm += pages;
 	} else if (flags & stack_flags)
 		mm->stack_vm += pages;
-	if (flags & (VM_RESERVED|VM_IO))
-		mm->reserved_vm += pages;
 }
 #endif /* CONFIG_PROC_FS */
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 5583325..07f6f60 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1813,7 +1813,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	if (addr != (pfn << PAGE_SHIFT))
 		return -EINVAL;
 
-	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
+	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
 	return 0;
 }
 EXPORT_SYMBOL(remap_pfn_range);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e03f4c7..0af1d88 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2155,8 +2155,7 @@ int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 		usize -= PAGE_SIZE;
 	} while (usize > 0);
 
-	/* Prevent "things" like memory migration? VM_flags need a cleanup... */
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 
 	return 0;
 }
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index 298e695..c86d018 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -485,7 +485,7 @@ static int sel_mmap_policy(struct file *filp, struct vm_area_struct *vma)
 			return -EACCES;
 	}
 
-	vma->vm_flags |= VM_RESERVED;
+	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = &sel_mmap_policy_ops;
 
 	return 0;
diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
index 53b5ada..b312c5d 100644
--- a/sound/core/pcm_native.c
+++ b/sound/core/pcm_native.c
@@ -3038,7 +3038,7 @@ static int snd_pcm_mmap_status(struct snd_pcm_substream *substream, struct file
 		return -EINVAL;
 	area->vm_ops = &snd_pcm_vm_ops_status;
 	area->vm_private_data = substream;
-	area->vm_flags |= VM_RESERVED;
+	area->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	return 0;
 }
 
@@ -3075,7 +3075,7 @@ static int snd_pcm_mmap_control(struct snd_pcm_substream *substream, struct file
 		return -EINVAL;
 	area->vm_ops = &snd_pcm_vm_ops_control;
 	area->vm_private_data = substream;
-	area->vm_flags |= VM_RESERVED;
+	area->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	return 0;
 }
 #else /* ! coherent mmap */
@@ -3169,7 +3169,7 @@ static const struct vm_operations_struct snd_pcm_vm_ops_data_fault = {
 int snd_pcm_lib_default_mmap(struct snd_pcm_substream *substream,
 			     struct vm_area_struct *area)
 {
-	area->vm_flags |= VM_RESERVED;
+	area->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 #ifdef ARCH_HAS_DMA_MMAP_COHERENT
 	if (!substream->ops->page &&
 	    substream->dma_buffer.dev.type == SNDRV_DMA_TYPE_DEV)
diff --git a/sound/usb/usx2y/us122l.c b/sound/usb/usx2y/us122l.c
index c4fd3b1..d0323a6 100644
--- a/sound/usb/usx2y/us122l.c
+++ b/sound/usb/usx2y/us122l.c
@@ -262,7 +262,7 @@ static int usb_stream_hwdep_mmap(struct snd_hwdep *hw,
 	}
 
 	area->vm_ops = &usb_stream_hwdep_vm_ops;
-	area->vm_flags |= VM_RESERVED;
+	area->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	area->vm_private_data = us122l;
 	atomic_inc(&us122l->mmap_count);
 out:
diff --git a/sound/usb/usx2y/usX2Yhwdep.c b/sound/usb/usx2y/usX2Yhwdep.c
index 04aafb4..0b34dbc 100644
--- a/sound/usb/usx2y/usX2Yhwdep.c
+++ b/sound/usb/usx2y/usX2Yhwdep.c
@@ -82,7 +82,7 @@ static int snd_us428ctls_mmap(struct snd_hwdep * hw, struct file *filp, struct v
 		us428->us428ctls_sharedmem->CtlSnapShotLast = -2;
 	}
 	area->vm_ops = &us428ctls_vm_ops;
-	area->vm_flags |= VM_RESERVED | VM_DONTEXPAND;
+	area->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	area->vm_private_data = hw->private_data;
 	return 0;
 }
diff --git a/sound/usb/usx2y/usx2yhwdeppcm.c b/sound/usb/usx2y/usx2yhwdeppcm.c
index 8e40b6e..cc56007 100644
--- a/sound/usb/usx2y/usx2yhwdeppcm.c
+++ b/sound/usb/usx2y/usx2yhwdeppcm.c
@@ -723,7 +723,7 @@ static int snd_usX2Y_hwdep_pcm_mmap(struct snd_hwdep * hw, struct file *filp, st
 		return -ENODEV;
 	}
 	area->vm_ops = &snd_usX2Y_hwdep_pcm_vm_ops;
-	area->vm_flags |= VM_RESERVED | VM_DONTEXPAND;
+	area->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
 	area->vm_private_data = hw->private_data;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
