Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F08636B02C3
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 19:14:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c15so13746276pfm.0
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:14:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f16si5474956pli.219.2017.08.30.16.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 16:14:46 -0700 (PDT)
Subject: [PATCH 1/2] vfs: add flags parameter to ->mmap() in 'struct
 file_operations'
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Aug 2017 16:08:20 -0700
Message-ID: <150413450036.5923.13851061508172314879.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: jack@suse.cz, linux-nvdimm@lists.01.org, David Airlie <airlied@linux.ie>, linux-api@vger.kernel.org, Takashi Iwai <tiwai@suse.com>, dri-devel@lists.freedesktop.org, Julia Lawall <julia.lawall@lip6.fr>, luto@kernel.org, Daniel Vetter <daniel.vetter@intel.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, hch@lst.de

We are running running short of vma->vm_flags. We can avoid needing a
new VM_* flag in some cases if the original @flags submitted to mmap(2)
is made available to the ->mmap() 'struct file_operations'
implementation. For example, the proposed addition of MAP_DIRECT can be
implemented without taking up a new vm_flags bit. Another motivation to
avoid vm_flags is that they appear in /proc/$pid/smaps, and we have seen
software that tries to dangerously (TOCTOU) read smaps to infer the
behavior of a virtual address range.

This conversion was performed by the following semantic patch. There
were a few manual edits for oddities like proc_reg_mmap.

Thanks to Julia for helping me with coccinelle iteration to cover cases
where the mmap routine is defined in a separate file from the 'struct
file_operations' instance that consumes it.

// Usage:
// $ spatch mmap.cocci --no-includes --include-headers --dir .
// 	--in-place ./ -j $num_cpus --very-quiet

virtual after_start

@initialize:ocaml@
@@

let tbl = Hashtbl.create(100)

let add_if_not_present fn =
  if not(Hashtbl.mem tbl fn) then Hashtbl.add tbl fn ()

@ a @
identifier fn;
identifier ops;
@@

struct file_operations ops = { ..., .mmap = fn, ...};

@script:ocaml@
fn << a.fn;
@@

add_if_not_present fn

@finalize:ocaml depends on !after_start@
tbls << merge.tbl;
@@

List.iter (fun t -> Hashtbl.iter (fun f _ -> add_if_not_present f) t) tbls;
Hashtbl.iter
    (fun f _ ->
      let it = new iteration() in
      it#add_virtual_rule After_start;
      it#add_virtual_identifier Fn f;
      it#register())
    tbl

@depends on after_start@
identifier virtual.fn;
identifier x, y;
@@

int fn(struct file *x,
        struct vm_area_struct *y
-       )
+       , unsigned long map_flags)
{
...
}

@depends on after_start@
identifier virtual.fn;
identifier x, y;
@@

int fn(struct file *x,
        struct vm_area_struct *y
-       );
+       , unsigned long map_flags);

@depends on after_start@
identifier virtual.fn;


@@

int fn(struct file *,
        struct vm_area_struct *
-       );
+       , unsigned long);

Cc: Takashi Iwai <tiwai@suse.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: David Airlie <airlied@linux.ie>
Cc: <dri-devel@lists.freedesktop.org>
Cc: Daniel Vetter <daniel.vetter@intel.com>
Signed-off-by: Julia Lawall <julia.lawall@lip6.fr>
Suggested-by: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arc/kernel/arc_hostlink.c                     |    3 ++-
 arch/mips/kernel/vdso.c                            |    2 +-
 arch/powerpc/kernel/proc_powerpc.c                 |    3 ++-
 arch/powerpc/kvm/book3s_64_vio.c                   |    3 ++-
 arch/powerpc/platforms/cell/spufs/file.c           |   21 +++++++++++++-------
 arch/powerpc/platforms/powernv/opal-prd.c          |    3 ++-
 arch/um/drivers/mmapper_kern.c                     |    3 ++-
 drivers/android/binder.c                           |    3 ++-
 drivers/char/agp/frontend.c                        |    3 ++-
 drivers/char/bsr.c                                 |    3 ++-
 drivers/char/hpet.c                                |    6 ++++--
 drivers/char/mbcs.c                                |    3 ++-
 drivers/char/mbcs.h                                |    3 ++-
 drivers/char/mem.c                                 |   11 +++++++---
 drivers/char/mspec.c                               |    9 ++++++---
 drivers/char/uv_mmtimer.c                          |    6 ++++--
 drivers/dax/device.c                               |    3 ++-
 drivers/dma-buf/dma-buf.c                          |    4 +++-
 drivers/firewire/core-cdev.c                       |    3 ++-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |    3 ++-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h            |    3 ++-
 drivers/gpu/drm/amd/amdkfd/kfd_chardev.c           |    5 +++--
 drivers/gpu/drm/arc/arcpgu_drv.c                   |    5 +++--
 drivers/gpu/drm/ast/ast_drv.h                      |    3 ++-
 drivers/gpu/drm/ast/ast_ttm.c                      |    3 ++-
 drivers/gpu/drm/bochs/bochs.h                      |    3 ++-
 drivers/gpu/drm/bochs/bochs_mm.c                   |    3 ++-
 drivers/gpu/drm/cirrus/cirrus_drv.h                |    3 ++-
 drivers/gpu/drm/cirrus/cirrus_ttm.c                |    3 ++-
 drivers/gpu/drm/drm_gem.c                          |    3 ++-
 drivers/gpu/drm/drm_gem_cma_helper.c               |    6 ++++--
 drivers/gpu/drm/drm_vm.c                           |    3 ++-
 drivers/gpu/drm/etnaviv/etnaviv_drv.h              |    3 ++-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |    5 +++--
 drivers/gpu/drm/exynos/exynos_drm_gem.c            |    5 +++--
 drivers/gpu/drm/exynos/exynos_drm_gem.h            |    3 ++-
 drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h    |    3 ++-
 drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c        |    3 ++-
 drivers/gpu/drm/i810/i810_dma.c                    |    3 ++-
 drivers/gpu/drm/i915/i915_gem_dmabuf.c             |    2 +-
 drivers/gpu/drm/mediatek/mtk_drm_gem.c             |    5 +++--
 drivers/gpu/drm/mediatek/mtk_drm_gem.h             |    3 ++-
 drivers/gpu/drm/mgag200/mgag200_drv.h              |    3 ++-
 drivers/gpu/drm/mgag200/mgag200_ttm.c              |    3 ++-
 drivers/gpu/drm/msm/msm_drv.h                      |    3 ++-
 drivers/gpu/drm/msm/msm_gem.c                      |    5 +++--
 drivers/gpu/drm/nouveau/nouveau_ttm.c              |    5 +++--
 drivers/gpu/drm/nouveau/nouveau_ttm.h              |    2 +-
 drivers/gpu/drm/omapdrm/omap_drv.h                 |    3 ++-
 drivers/gpu/drm/omapdrm/omap_gem.c                 |    5 +++--
 drivers/gpu/drm/qxl/qxl_drv.h                      |    3 ++-
 drivers/gpu/drm/qxl/qxl_ttm.c                      |    3 ++-
 drivers/gpu/drm/radeon/radeon_drv.c                |    3 ++-
 drivers/gpu/drm/radeon/radeon_ttm.c                |    3 ++-
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c        |    5 +++--
 drivers/gpu/drm/rockchip/rockchip_drm_gem.h        |    3 ++-
 drivers/gpu/drm/tegra/gem.c                        |    5 +++--
 drivers/gpu/drm/tegra/gem.h                        |    3 ++-
 drivers/gpu/drm/udl/udl_drv.h                      |    3 ++-
 drivers/gpu/drm/udl/udl_gem.c                      |    5 +++--
 drivers/gpu/drm/vc4/vc4_bo.c                       |    5 +++--
 drivers/gpu/drm/vc4/vc4_drv.h                      |    3 ++-
 drivers/gpu/drm/vgem/vgem_drv.c                    |    7 ++++---
 drivers/gpu/drm/virtio/virtgpu_drv.h               |    3 ++-
 drivers/gpu/drm/virtio/virtgpu_ttm.c               |    3 ++-
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h                |    3 ++-
 drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c           |    3 ++-
 drivers/hsi/clients/cmt_speech.c                   |    3 ++-
 drivers/hwtracing/intel_th/msu.c                   |    3 ++-
 drivers/hwtracing/stm/core.c                       |    3 ++-
 drivers/infiniband/core/uverbs_main.c              |    3 ++-
 drivers/infiniband/hw/hfi1/file_ops.c              |    6 ++++--
 drivers/infiniband/hw/qib/qib_file_ops.c           |    5 +++--
 drivers/media/v4l2-core/v4l2-dev.c                 |    3 ++-
 drivers/misc/aspeed-lpc-ctrl.c                     |    3 ++-
 drivers/misc/cxl/api.c                             |    5 +++--
 drivers/misc/cxl/cxl.h                             |    3 ++-
 drivers/misc/cxl/file.c                            |    3 ++-
 drivers/misc/genwqe/card_dev.c                     |    3 ++-
 drivers/misc/mic/scif/scif_fd.c                    |    3 ++-
 drivers/misc/mic/vop/vop_vringh.c                  |    3 ++-
 drivers/misc/sgi-gru/grufile.c                     |    3 ++-
 drivers/mtd/mtdchar.c                              |    3 ++-
 drivers/pci/proc.c                                 |    3 ++-
 drivers/rapidio/devices/rio_mport_cdev.c           |    3 ++-
 drivers/sbus/char/flash.c                          |    3 ++-
 drivers/sbus/char/jsflash.c                        |    3 ++-
 drivers/scsi/cxlflash/superpipe.c                  |    5 +++--
 drivers/scsi/sg.c                                  |    3 ++-
 drivers/staging/android/ashmem.c                   |    3 ++-
 drivers/staging/comedi/comedi_fops.c               |    3 ++-
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 ++-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    5 +++--
 drivers/staging/vboxvideo/vbox_drv.h               |    3 ++-
 drivers/staging/vboxvideo/vbox_ttm.c               |    3 ++-
 drivers/staging/vme/devices/vme_user.c             |    3 ++-
 drivers/uio/uio.c                                  |    3 ++-
 drivers/usb/core/devio.c                           |    3 ++-
 drivers/usb/mon/mon_bin.c                          |    3 ++-
 drivers/vfio/vfio.c                                |    7 +++++--
 drivers/video/fbdev/core/fbmem.c                   |    3 ++-
 drivers/video/fbdev/pxa3xx-gcu.c                   |    3 ++-
 drivers/xen/gntalloc.c                             |    3 ++-
 drivers/xen/gntdev.c                               |    3 ++-
 drivers/xen/privcmd.c                              |    3 ++-
 drivers/xen/xenbus/xenbus_dev_backend.c            |    3 ++-
 drivers/xen/xenfs/xenstored.c                      |    3 ++-
 fs/9p/vfs_file.c                                   |   10 ++++++----
 fs/aio.c                                           |    3 ++-
 fs/btrfs/file.c                                    |    3 ++-
 fs/ceph/addr.c                                     |    3 ++-
 fs/ceph/super.h                                    |    3 ++-
 fs/cifs/cifsfs.h                                   |    6 ++++--
 fs/cifs/file.c                                     |   10 ++++++----
 fs/coda/file.c                                     |    5 +++--
 fs/ecryptfs/file.c                                 |    5 +++--
 fs/ext2/file.c                                     |    5 +++--
 fs/ext4/file.c                                     |    3 ++-
 fs/f2fs/file.c                                     |    3 ++-
 fs/fuse/file.c                                     |    8 +++++---
 fs/gfs2/file.c                                     |    3 ++-
 fs/hugetlbfs/inode.c                               |    3 ++-
 fs/kernfs/file.c                                   |    3 ++-
 fs/ncpfs/mmap.c                                    |    3 ++-
 fs/ncpfs/ncp_fs.h                                  |    2 +-
 fs/nfs/file.c                                      |    5 +++--
 fs/nfs/internal.h                                  |    2 +-
 fs/nilfs2/file.c                                   |    3 ++-
 fs/ocfs2/mmap.c                                    |    3 ++-
 fs/ocfs2/mmap.h                                    |    3 ++-
 fs/orangefs/file.c                                 |    5 +++--
 fs/proc/inode.c                                    |    7 ++++---
 fs/proc/vmcore.c                                   |    6 ++++--
 fs/ramfs/file-nommu.c                              |    6 ++++--
 fs/romfs/mmap-nommu.c                              |    3 ++-
 fs/ubifs/file.c                                    |    5 +++--
 fs/xfs/xfs_file.c                                  |    5 ++---
 include/drm/drm_gem.h                              |    3 ++-
 include/drm/drm_gem_cma_helper.h                   |    3 ++-
 include/drm/drm_legacy.h                           |    3 ++-
 include/linux/fs.h                                 |   13 ++++++++----
 include/misc/cxl.h                                 |    3 ++-
 ipc/shm.c                                          |    5 +++--
 kernel/events/core.c                               |    3 ++-
 kernel/kcov.c                                      |    3 ++-
 kernel/relay.c                                     |    3 ++-
 mm/filemap.c                                       |   14 +++++++++----
 mm/mmap.c                                          |    2 +-
 mm/nommu.c                                         |    4 ++--
 mm/shmem.c                                         |    3 ++-
 net/socket.c                                       |    6 ++++--
 security/selinux/selinuxfs.c                       |    6 ++++--
 sound/core/compress_offload.c                      |    3 ++-
 sound/core/hwdep.c                                 |    3 ++-
 sound/core/info.c                                  |    3 ++-
 sound/core/init.c                                  |    3 ++-
 sound/core/oss/pcm_oss.c                           |    3 ++-
 sound/core/pcm_native.c                            |    3 ++-
 sound/oss/soundcard.c                              |    3 ++-
 sound/oss/swarm_cs4297a.c                          |    3 ++-
 virt/kvm/kvm_main.c                                |    3 ++-
 161 files changed, 410 insertions(+), 228 deletions(-)

diff --git a/arch/arc/kernel/arc_hostlink.c b/arch/arc/kernel/arc_hostlink.c
index 47b2a17cc52a..09398a953cca 100644
--- a/arch/arc/kernel/arc_hostlink.c
+++ b/arch/arc/kernel/arc_hostlink.c
@@ -18,7 +18,8 @@
 
 static unsigned char __HOSTLINK__[4 * PAGE_SIZE] __aligned(PAGE_SIZE);
 
-static int arc_hl_mmap(struct file *fp, struct vm_area_struct *vma)
+static int arc_hl_mmap(struct file *fp, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index 093517e85a6c..aa143d113aba 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -111,7 +111,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	base = mmap_region(NULL, STACK_TOP, PAGE_SIZE,
 			   VM_READ|VM_WRITE|VM_EXEC|
 			   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-			   0, NULL);
+			   0, NULL, 0);
 	if (IS_ERR_VALUE(base)) {
 		ret = base;
 		goto out;
diff --git a/arch/powerpc/kernel/proc_powerpc.c b/arch/powerpc/kernel/proc_powerpc.c
index 56548bf6231f..77ba2cc4be66 100644
--- a/arch/powerpc/kernel/proc_powerpc.c
+++ b/arch/powerpc/kernel/proc_powerpc.c
@@ -41,7 +41,8 @@ static ssize_t page_map_read( struct file *file, char __user *buf, size_t nbytes
 			PDE_DATA(file_inode(file)), PAGE_SIZE);
 }
 
-static int page_map_mmap( struct file *file, struct vm_area_struct *vma )
+static int page_map_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	if ((vma->vm_end - vma->vm_start) > PAGE_SIZE)
 		return -EINVAL;
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index a160c14304eb..79147b5b014c 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -255,7 +255,8 @@ static const struct vm_operations_struct kvm_spapr_tce_vm_ops = {
 	.fault = kvm_spapr_tce_fault,
 };
 
-static int kvm_spapr_tce_mmap(struct file *file, struct vm_area_struct *vma)
+static int kvm_spapr_tce_mmap(struct file *file, struct vm_area_struct *vma,
+			      unsigned long map_flags)
 {
 	vma->vm_ops = &kvm_spapr_tce_vm_ops;
 	return 0;
diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index ae2f740a82f1..e785e96707cf 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -291,7 +291,8 @@ static const struct vm_operations_struct spufs_mem_mmap_vmops = {
 	.access = spufs_mem_mmap_access,
 };
 
-static int spufs_mem_mmap(struct file *file, struct vm_area_struct *vma)
+static int spufs_mem_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	if (!(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
@@ -379,7 +380,8 @@ static const struct vm_operations_struct spufs_cntl_mmap_vmops = {
 /*
  * mmap support for problem state control area [0x4000 - 0x4fff].
  */
-static int spufs_cntl_mmap(struct file *file, struct vm_area_struct *vma)
+static int spufs_cntl_mmap(struct file *file, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	if (!(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
@@ -1059,7 +1061,8 @@ static const struct vm_operations_struct spufs_signal1_mmap_vmops = {
 	.fault = spufs_signal1_mmap_fault,
 };
 
-static int spufs_signal1_mmap(struct file *file, struct vm_area_struct *vma)
+static int spufs_signal1_mmap(struct file *file, struct vm_area_struct *vma,
+			      unsigned long map_flags)
 {
 	if (!(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
@@ -1197,7 +1200,8 @@ static const struct vm_operations_struct spufs_signal2_mmap_vmops = {
 	.fault = spufs_signal2_mmap_fault,
 };
 
-static int spufs_signal2_mmap(struct file *file, struct vm_area_struct *vma)
+static int spufs_signal2_mmap(struct file *file, struct vm_area_struct *vma,
+			      unsigned long map_flags)
 {
 	if (!(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
@@ -1320,7 +1324,8 @@ static const struct vm_operations_struct spufs_mss_mmap_vmops = {
 /*
  * mmap support for problem state MFC DMA area [0x0000 - 0x0fff].
  */
-static int spufs_mss_mmap(struct file *file, struct vm_area_struct *vma)
+static int spufs_mss_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	if (!(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
@@ -1382,7 +1387,8 @@ static const struct vm_operations_struct spufs_psmap_mmap_vmops = {
 /*
  * mmap support for full problem state area [0x00000 - 0x1ffff].
  */
-static int spufs_psmap_mmap(struct file *file, struct vm_area_struct *vma)
+static int spufs_psmap_mmap(struct file *file, struct vm_area_struct *vma,
+			    unsigned long map_flags)
 {
 	if (!(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
@@ -1442,7 +1448,8 @@ static const struct vm_operations_struct spufs_mfc_mmap_vmops = {
 /*
  * mmap support for problem state MFC DMA area [0x0000 - 0x0fff].
  */
-static int spufs_mfc_mmap(struct file *file, struct vm_area_struct *vma)
+static int spufs_mfc_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	if (!(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
diff --git a/arch/powerpc/platforms/powernv/opal-prd.c b/arch/powerpc/platforms/powernv/opal-prd.c
index 2d6ee1c5ad85..5a4ee5d6f223 100644
--- a/arch/powerpc/platforms/powernv/opal-prd.c
+++ b/arch/powerpc/platforms/powernv/opal-prd.c
@@ -109,7 +109,8 @@ static int opal_prd_open(struct inode *inode, struct file *file)
  * @vma: VMA to map the registers into
  */
 
-static int opal_prd_mmap(struct file *file, struct vm_area_struct *vma)
+static int opal_prd_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	size_t addr, size;
 	pgprot_t page_prot;
diff --git a/arch/um/drivers/mmapper_kern.c b/arch/um/drivers/mmapper_kern.c
index 3645fcb2a787..046eb23602a2 100644
--- a/arch/um/drivers/mmapper_kern.c
+++ b/arch/um/drivers/mmapper_kern.c
@@ -45,7 +45,8 @@ static long mmapper_ioctl(struct file *file, unsigned int cmd, unsigned long arg
 	return -ENOIOCTLCMD;
 }
 
-static int mmapper_mmap(struct file *file, struct vm_area_struct *vma)
+static int mmapper_mmap(struct file *file, struct vm_area_struct *vma,
+			unsigned long map_flags)
 {
 	int ret = -EINVAL;
 	int size;
diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index f7665c31feca..f105e2a9d39b 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -3354,7 +3354,8 @@ static const struct vm_operations_struct binder_vm_ops = {
 	.fault = binder_vm_fault,
 };
 
-static int binder_mmap(struct file *filp, struct vm_area_struct *vma)
+static int binder_mmap(struct file *filp, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	int ret;
 	struct vm_struct *area;
diff --git a/drivers/char/agp/frontend.c b/drivers/char/agp/frontend.c
index f6955888e676..c39b90e26c76 100644
--- a/drivers/char/agp/frontend.c
+++ b/drivers/char/agp/frontend.c
@@ -562,7 +562,8 @@ int agp_remove_client(pid_t id)
 
 /* File Operations */
 
-static int agp_mmap(struct file *file, struct vm_area_struct *vma)
+static int agp_mmap(struct file *file, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	unsigned int size, current_size;
 	unsigned long offset;
diff --git a/drivers/char/bsr.c b/drivers/char/bsr.c
index a6cef548e01e..93ec4c6f029e 100644
--- a/drivers/char/bsr.c
+++ b/drivers/char/bsr.c
@@ -122,7 +122,8 @@ static struct attribute *bsr_dev_attrs[] = {
 };
 ATTRIBUTE_GROUPS(bsr_dev);
 
-static int bsr_mmap(struct file *filp, struct vm_area_struct *vma)
+static int bsr_mmap(struct file *filp, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	unsigned long size   = vma->vm_end - vma->vm_start;
 	struct bsr_dev *dev = filp->private_data;
diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
index b941e6d59fd6..e817c1b6c52d 100644
--- a/drivers/char/hpet.c
+++ b/drivers/char/hpet.c
@@ -379,7 +379,8 @@ static __init int hpet_mmap_enable(char *str)
 }
 __setup("hpet_mmap", hpet_mmap_enable);
 
-static int hpet_mmap(struct file *file, struct vm_area_struct *vma)
+static int hpet_mmap(struct file *file, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	struct hpet_dev *devp;
 	unsigned long addr;
@@ -397,7 +398,8 @@ static int hpet_mmap(struct file *file, struct vm_area_struct *vma)
 	return vm_iomap_memory(vma, addr, PAGE_SIZE);
 }
 #else
-static int hpet_mmap(struct file *file, struct vm_area_struct *vma)
+static int hpet_mmap(struct file *file, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	return -ENOSYS;
 }
diff --git a/drivers/char/mbcs.c b/drivers/char/mbcs.c
index 8c9216a0f62e..2cd165571039 100644
--- a/drivers/char/mbcs.c
+++ b/drivers/char/mbcs.c
@@ -475,7 +475,8 @@ static void mbcs_gscr_pioaddr_set(struct mbcs_soft *soft)
 	soft->gscr_addr = mbcs_pioaddr(soft, MBCS_GSCR_START);
 }
 
-static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma)
+static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	struct cx_dev *cx_dev = fp->private_data;
 	struct mbcs_soft *soft = cx_dev->soft;
diff --git a/drivers/char/mbcs.h b/drivers/char/mbcs.h
index 1a36884c48b5..7d147ed61c67 100644
--- a/drivers/char/mbcs.h
+++ b/drivers/char/mbcs.h
@@ -548,6 +548,7 @@ static ssize_t mbcs_sram_read(struct file *fp, char __user *buf, size_t len,
 static ssize_t mbcs_sram_write(struct file *fp, const char __user *buf, size_t len,
 			       loff_t * off);
 static loff_t mbcs_sram_llseek(struct file *filp, loff_t off, int whence);
-static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma);
+static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma,
+			  unsigned long map_flags);
 
 #endif				// __MBCS_H__
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 593a8818aca9..e786e1920f3a 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -337,7 +337,8 @@ static const struct vm_operations_struct mmap_mem_ops = {
 #endif
 };
 
-static int mmap_mem(struct file *file, struct vm_area_struct *vma)
+static int mmap_mem(struct file *file, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	size_t size = vma->vm_end - vma->vm_start;
 	phys_addr_t offset = (phys_addr_t)vma->vm_pgoff << PAGE_SHIFT;
@@ -376,7 +377,8 @@ static int mmap_mem(struct file *file, struct vm_area_struct *vma)
 	return 0;
 }
 
-static int mmap_kmem(struct file *file, struct vm_area_struct *vma)
+static int mmap_kmem(struct file *file, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	unsigned long pfn;
 
@@ -394,7 +396,7 @@ static int mmap_kmem(struct file *file, struct vm_area_struct *vma)
 		return -EIO;
 
 	vma->vm_pgoff = pfn;
-	return mmap_mem(file, vma);
+	return mmap_mem(file, vma, 0);
 }
 
 /*
@@ -679,7 +681,8 @@ static ssize_t read_iter_zero(struct kiocb *iocb, struct iov_iter *iter)
 	return written;
 }
 
-static int mmap_zero(struct file *file, struct vm_area_struct *vma)
+static int mmap_zero(struct file *file, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 #ifndef CONFIG_MMU
 	return -ENOSYS;
diff --git a/drivers/char/mspec.c b/drivers/char/mspec.c
index 7b75669d3670..a3496304c4ef 100644
--- a/drivers/char/mspec.c
+++ b/drivers/char/mspec.c
@@ -287,19 +287,22 @@ mspec_mmap(struct file *file, struct vm_area_struct *vma,
 }
 
 static int
-fetchop_mmap(struct file *file, struct vm_area_struct *vma)
+fetchop_mmap(struct file *file, struct vm_area_struct *vma,
+	     unsigned long map_flags)
 {
 	return mspec_mmap(file, vma, MSPEC_FETCHOP);
 }
 
 static int
-cached_mmap(struct file *file, struct vm_area_struct *vma)
+cached_mmap(struct file *file, struct vm_area_struct *vma,
+	    unsigned long map_flags)
 {
 	return mspec_mmap(file, vma, MSPEC_CACHED);
 }
 
 static int
-uncached_mmap(struct file *file, struct vm_area_struct *vma)
+uncached_mmap(struct file *file, struct vm_area_struct *vma,
+	      unsigned long map_flags)
 {
 	return mspec_mmap(file, vma, MSPEC_UNCACHED);
 }
diff --git a/drivers/char/uv_mmtimer.c b/drivers/char/uv_mmtimer.c
index 956ebe2080a5..c95e68ec2ca2 100644
--- a/drivers/char/uv_mmtimer.c
+++ b/drivers/char/uv_mmtimer.c
@@ -40,7 +40,8 @@ MODULE_LICENSE("GPL");
 
 static long uv_mmtimer_ioctl(struct file *file, unsigned int cmd,
 						unsigned long arg);
-static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma);
+static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma,
+			   unsigned long map_flags);
 
 /*
  * Period in femtoseconds (10^-15 s)
@@ -144,7 +145,8 @@ static long uv_mmtimer_ioctl(struct file *file, unsigned int cmd,
  * Calls remap_pfn_range() to map the clock's registers into
  * the calling process' address space.
  */
-static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma)
+static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	unsigned long uv_mmtimer_addr;
 
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index e9f3b3e4bbf4..52aa8c80f786 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -432,7 +432,8 @@ static const struct vm_operations_struct dax_vm_ops = {
 	.huge_fault = dev_dax_huge_fault,
 };
 
-static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
+static int dax_mmap(struct file *filp, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	struct dev_dax *dev_dax = filp->private_data;
 	int rc, id;
diff --git a/drivers/dma-buf/dma-buf.c b/drivers/dma-buf/dma-buf.c
index 4a038dcf5361..41aab156fc18 100644
--- a/drivers/dma-buf/dma-buf.c
+++ b/drivers/dma-buf/dma-buf.c
@@ -81,7 +81,9 @@ static int dma_buf_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int dma_buf_mmap_internal(struct file *file, struct vm_area_struct *vma)
+static int dma_buf_mmap_internal(struct file *file,
+				 struct vm_area_struct *vma,
+				 unsigned long map_flags)
 {
 	struct dma_buf *dmabuf;
 
diff --git a/drivers/firewire/core-cdev.c b/drivers/firewire/core-cdev.c
index a301fcf46e88..07b8983d31ff 100644
--- a/drivers/firewire/core-cdev.c
+++ b/drivers/firewire/core-cdev.c
@@ -1667,7 +1667,8 @@ static long fw_device_op_compat_ioctl(struct file *file,
 }
 #endif
 
-static int fw_device_op_mmap(struct file *file, struct vm_area_struct *vma)
+static int fw_device_op_mmap(struct file *file, struct vm_area_struct *vma,
+			     unsigned long map_flags)
 {
 	struct client *client = file->private_data;
 	unsigned long size;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index c9b131b13ef7..aa4dd9c1dbe8 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -1240,7 +1240,8 @@ void amdgpu_ttm_set_active_vram_size(struct amdgpu_device *adev, u64 size)
 	man->size = size >> PAGE_SHIFT;
 }
 
-int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma)
+int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct amdgpu_device *adev;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
index 6bdede8ff12b..6bbfd04b0f43 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
@@ -72,7 +72,8 @@ int amdgpu_fill_buffer(struct amdgpu_bo *bo,
 			struct reservation_object *resv,
 			struct dma_fence **fence);
 
-int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma);
+int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 bool amdgpu_ttm_is_bound(struct ttm_tt *ttm);
 int amdgpu_ttm_bind(struct ttm_buffer_object *bo, struct ttm_mem_reg *bo_mem);
 
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c b/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
index 6316aad43a73..483a11e530f9 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
@@ -39,7 +39,7 @@
 
 static long kfd_ioctl(struct file *, unsigned int, unsigned long);
 static int kfd_open(struct inode *, struct file *);
-static int kfd_mmap(struct file *, struct vm_area_struct *);
+static int kfd_mmap(struct file *, struct vm_area_struct *, unsigned long);
 
 static const char kfd_dev_name[] = "kfd";
 
@@ -991,7 +991,8 @@ static long kfd_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
 	return retcode;
 }
 
-static int kfd_mmap(struct file *filp, struct vm_area_struct *vma)
+static int kfd_mmap(struct file *filp, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	struct kfd_process *process;
 
diff --git a/drivers/gpu/drm/arc/arcpgu_drv.c b/drivers/gpu/drm/arc/arcpgu_drv.c
index 3e43a5d4fb09..e816e53c95ec 100644
--- a/drivers/gpu/drm/arc/arcpgu_drv.c
+++ b/drivers/gpu/drm/arc/arcpgu_drv.c
@@ -48,11 +48,12 @@ static void arcpgu_setup_mode_config(struct drm_device *drm)
 	drm->mode_config.funcs = &arcpgu_drm_modecfg_funcs;
 }
 
-static int arcpgu_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+static int arcpgu_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/ast/ast_drv.h b/drivers/gpu/drm/ast/ast_drv.h
index 8880f0b62e9c..b9b4e16a196b 100644
--- a/drivers/gpu/drm/ast/ast_drv.h
+++ b/drivers/gpu/drm/ast/ast_drv.h
@@ -391,7 +391,8 @@ static inline void ast_bo_unreserve(struct ast_bo *bo)
 
 void ast_ttm_placement(struct ast_bo *bo, int domain);
 int ast_bo_push_sysram(struct ast_bo *bo);
-int ast_mmap(struct file *filp, struct vm_area_struct *vma);
+int ast_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 
 /* ast post */
 void ast_enable_vga(struct drm_device *dev);
diff --git a/drivers/gpu/drm/ast/ast_ttm.c b/drivers/gpu/drm/ast/ast_ttm.c
index 58084985e6cf..11d8be1af8e3 100644
--- a/drivers/gpu/drm/ast/ast_ttm.c
+++ b/drivers/gpu/drm/ast/ast_ttm.c
@@ -420,7 +420,8 @@ int ast_bo_push_sysram(struct ast_bo *bo)
 	return 0;
 }
 
-int ast_mmap(struct file *filp, struct vm_area_struct *vma)
+int ast_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct ast_private *ast;
diff --git a/drivers/gpu/drm/bochs/bochs.h b/drivers/gpu/drm/bochs/bochs.h
index 76c490c3cdbc..20e9eef85722 100644
--- a/drivers/gpu/drm/bochs/bochs.h
+++ b/drivers/gpu/drm/bochs/bochs.h
@@ -136,7 +136,8 @@ void bochs_hw_setbase(struct bochs_device *bochs,
 /* bochs_mm.c */
 int bochs_mm_init(struct bochs_device *bochs);
 void bochs_mm_fini(struct bochs_device *bochs);
-int bochs_mmap(struct file *filp, struct vm_area_struct *vma);
+int bochs_mmap(struct file *filp, struct vm_area_struct *vma,
+	       unsigned long map_flags);
 
 int bochs_gem_create(struct drm_device *dev, u32 size, bool iskernel,
 		     struct drm_gem_object **obj);
diff --git a/drivers/gpu/drm/bochs/bochs_mm.c b/drivers/gpu/drm/bochs/bochs_mm.c
index c4cadb638460..d4c8b30594d4 100644
--- a/drivers/gpu/drm/bochs/bochs_mm.c
+++ b/drivers/gpu/drm/bochs/bochs_mm.c
@@ -327,7 +327,8 @@ int bochs_bo_unpin(struct bochs_bo *bo)
 	return 0;
 }
 
-int bochs_mmap(struct file *filp, struct vm_area_struct *vma)
+int bochs_mmap(struct file *filp, struct vm_area_struct *vma,
+	       unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct bochs_device *bochs;
diff --git a/drivers/gpu/drm/cirrus/cirrus_drv.h b/drivers/gpu/drm/cirrus/cirrus_drv.h
index 8690352d96f7..ff6755ef441e 100644
--- a/drivers/gpu/drm/cirrus/cirrus_drv.h
+++ b/drivers/gpu/drm/cirrus/cirrus_drv.h
@@ -240,7 +240,8 @@ void cirrus_mm_fini(struct cirrus_device *cirrus);
 void cirrus_ttm_placement(struct cirrus_bo *bo, int domain);
 int cirrus_bo_create(struct drm_device *dev, int size, int align,
 		     uint32_t flags, struct cirrus_bo **pcirrusbo);
-int cirrus_mmap(struct file *filp, struct vm_area_struct *vma);
+int cirrus_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 
 static inline int cirrus_bo_reserve(struct cirrus_bo *bo, bool no_wait)
 {
diff --git a/drivers/gpu/drm/cirrus/cirrus_ttm.c b/drivers/gpu/drm/cirrus/cirrus_ttm.c
index 1ff1838c0d44..efd01ec99c83 100644
--- a/drivers/gpu/drm/cirrus/cirrus_ttm.c
+++ b/drivers/gpu/drm/cirrus/cirrus_ttm.c
@@ -405,7 +405,8 @@ int cirrus_bo_push_sysram(struct cirrus_bo *bo)
 	return 0;
 }
 
-int cirrus_mmap(struct file *filp, struct vm_area_struct *vma)
+int cirrus_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct cirrus_device *cirrus;
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 8dc11064253d..18cf11227af7 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -956,7 +956,8 @@ EXPORT_SYMBOL(drm_gem_mmap_obj);
  * If the caller is not granted access to the buffer object, the mmap will fail
  * with EACCES. Please see the vma manager for more information.
  */
-int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *priv = filp->private_data;
 	struct drm_device *dev = priv->minor->dev;
diff --git a/drivers/gpu/drm/drm_gem_cma_helper.c b/drivers/gpu/drm/drm_gem_cma_helper.c
index bc28e7575254..80f3356f23fc 100644
--- a/drivers/gpu/drm/drm_gem_cma_helper.c
+++ b/drivers/gpu/drm/drm_gem_cma_helper.c
@@ -330,6 +330,7 @@ static int drm_gem_cma_mmap_obj(struct drm_gem_cma_object *cma_obj,
  * drm_gem_cma_mmap - memory-map a CMA GEM object
  * @filp: file object
  * @vma: VMA for the area to be mapped
+ * @map_flags: the MAP_* flags passed to mmap(2)
  *
  * This function implements an augmented version of the GEM DRM file mmap
  * operation for CMA objects: In addition to the usual GEM VMA setup it
@@ -344,13 +345,14 @@ static int drm_gem_cma_mmap_obj(struct drm_gem_cma_object *cma_obj,
  * Returns:
  * 0 on success or a negative error code on failure.
  */
-int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma)
+int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_gem_cma_object *cma_obj;
 	struct drm_gem_object *gem_obj;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
index 1170b3209a12..acd4e8bf115c 100644
--- a/drivers/gpu/drm/drm_vm.c
+++ b/drivers/gpu/drm/drm_vm.c
@@ -625,7 +625,8 @@ static int drm_mmap_locked(struct file *filp, struct vm_area_struct *vma)
 	return 0;
 }
 
-int drm_legacy_mmap(struct file *filp, struct vm_area_struct *vma)
+int drm_legacy_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *priv = filp->private_data;
 	struct drm_device *dev = priv->minor->dev;
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_drv.h b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
index 058389f93b69..22a9732e8609 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_drv.h
+++ b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
@@ -72,7 +72,8 @@ static inline void etnaviv_queue_work(struct drm_device *dev,
 int etnaviv_ioctl_gem_submit(struct drm_device *dev, void *data,
 		struct drm_file *file);
 
-int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma);
+int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		     unsigned long map_flags);
 int etnaviv_gem_fault(struct vm_fault *vmf);
 int etnaviv_gem_mmap_offset(struct drm_gem_object *obj, u64 *offset);
 struct sg_table *etnaviv_gem_prime_get_sg_table(struct drm_gem_object *obj);
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 9a3bea738330..89cf44f6d5b7 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -162,12 +162,13 @@ static int etnaviv_gem_mmap_obj(struct etnaviv_gem_object *etnaviv_obj,
 	return 0;
 }
 
-int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	struct etnaviv_gem_object *obj;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret) {
 		DBG("mmap failed: %d", ret);
 		return ret;
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index c23479be4850..d4fd8979a89f 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -511,13 +511,14 @@ static int exynos_drm_gem_mmap_obj(struct drm_gem_object *obj,
 	return ret;
 }
 
-int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+			unsigned long map_flags)
 {
 	struct drm_gem_object *obj;
 	int ret;
 
 	/* set vm_area_struct. */
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret < 0) {
 		DRM_ERROR("failed to mmap.\n");
 		return ret;
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.h b/drivers/gpu/drm/exynos/exynos_drm_gem.h
index 85457255fcd1..db537106ada8 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.h
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.h
@@ -119,7 +119,8 @@ int exynos_drm_gem_dumb_map_offset(struct drm_file *file_priv,
 int exynos_drm_gem_fault(struct vm_fault *vmf);
 
 /* set vm_flags and we can change the vm attribute to other one at here. */
-int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
+int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+			unsigned long map_flags);
 
 /* low-level interface prime helpers */
 struct sg_table *exynos_drm_gem_prime_get_sg_table(struct drm_gem_object *obj);
diff --git a/drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h b/drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h
index e195521eb41e..e876e74348ae 100644
--- a/drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h
+++ b/drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h
@@ -107,7 +107,8 @@ int hibmc_dumb_create(struct drm_file *file, struct drm_device *dev,
 		      struct drm_mode_create_dumb *args);
 int hibmc_dumb_mmap_offset(struct drm_file *file, struct drm_device *dev,
 			   u32 handle, u64 *offset);
-int hibmc_mmap(struct file *filp, struct vm_area_struct *vma);
+int hibmc_mmap(struct file *filp, struct vm_area_struct *vma,
+	       unsigned long map_flags);
 
 extern const struct drm_mode_config_funcs hibmc_mode_funcs;
 
diff --git a/drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c b/drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c
index ac457c779caa..77bb7cf13911 100644
--- a/drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c
+++ b/drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c
@@ -389,7 +389,8 @@ int hibmc_bo_unpin(struct hibmc_bo *bo)
 	return 0;
 }
 
-int hibmc_mmap(struct file *filp, struct vm_area_struct *vma)
+int hibmc_mmap(struct file *filp, struct vm_area_struct *vma,
+	       unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct hibmc_drm_private *hibmc;
diff --git a/drivers/gpu/drm/i810/i810_dma.c b/drivers/gpu/drm/i810/i810_dma.c
index 576a417690d4..c7ff2e7072ca 100644
--- a/drivers/gpu/drm/i810/i810_dma.c
+++ b/drivers/gpu/drm/i810/i810_dma.c
@@ -84,7 +84,8 @@ static int i810_freelist_put(struct drm_device *dev, struct drm_buf *buf)
 	return 0;
 }
 
-static int i810_mmap_buffers(struct file *filp, struct vm_area_struct *vma)
+static int i810_mmap_buffers(struct file *filp, struct vm_area_struct *vma,
+			     unsigned long map_flags)
 {
 	struct drm_file *priv = filp->private_data;
 	struct drm_device *dev;
diff --git a/drivers/gpu/drm/i915/i915_gem_dmabuf.c b/drivers/gpu/drm/i915/i915_gem_dmabuf.c
index 6176e589cf09..296cd09dd3aa 100644
--- a/drivers/gpu/drm/i915/i915_gem_dmabuf.c
+++ b/drivers/gpu/drm/i915/i915_gem_dmabuf.c
@@ -165,7 +165,7 @@ static int i915_gem_dmabuf_mmap(struct dma_buf *dma_buf, struct vm_area_struct *
 	if (!obj->base.filp)
 		return -ENODEV;
 
-	ret = call_mmap(obj->base.filp, vma);
+	ret = call_mmap(obj->base.filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/mediatek/mtk_drm_gem.c b/drivers/gpu/drm/mediatek/mtk_drm_gem.c
index 7abc550ebc00..53fcadf8a820 100644
--- a/drivers/gpu/drm/mediatek/mtk_drm_gem.c
+++ b/drivers/gpu/drm/mediatek/mtk_drm_gem.c
@@ -190,12 +190,13 @@ int mtk_drm_gem_mmap_buf(struct drm_gem_object *obj, struct vm_area_struct *vma)
 	return mtk_drm_gem_object_mmap(obj, vma);
 }
 
-int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	struct drm_gem_object *obj;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/mediatek/mtk_drm_gem.h b/drivers/gpu/drm/mediatek/mtk_drm_gem.h
index 2752718fa5b2..67df89160cf2 100644
--- a/drivers/gpu/drm/mediatek/mtk_drm_gem.h
+++ b/drivers/gpu/drm/mediatek/mtk_drm_gem.h
@@ -49,7 +49,8 @@ int mtk_drm_gem_dumb_create(struct drm_file *file_priv, struct drm_device *dev,
 int mtk_drm_gem_dumb_map_offset(struct drm_file *file_priv,
 				struct drm_device *dev, uint32_t handle,
 				uint64_t *offset);
-int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
+int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		     unsigned long map_flags);
 int mtk_drm_gem_mmap_buf(struct drm_gem_object *obj,
 			 struct vm_area_struct *vma);
 struct sg_table *mtk_gem_prime_get_sg_table(struct drm_gem_object *obj);
diff --git a/drivers/gpu/drm/mgag200/mgag200_drv.h b/drivers/gpu/drm/mgag200/mgag200_drv.h
index c88b6ec88dd2..42317765c982 100644
--- a/drivers/gpu/drm/mgag200/mgag200_drv.h
+++ b/drivers/gpu/drm/mgag200/mgag200_drv.h
@@ -301,7 +301,8 @@ int mgag200_bo_create(struct drm_device *dev, int size, int align,
 		      uint32_t flags, struct mgag200_bo **pastbo);
 int mgag200_mm_init(struct mga_device *mdev);
 void mgag200_mm_fini(struct mga_device *mdev);
-int mgag200_mmap(struct file *filp, struct vm_area_struct *vma);
+int mgag200_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 int mgag200_bo_pin(struct mgag200_bo *bo, u32 pl_flag, u64 *gpu_addr);
 int mgag200_bo_unpin(struct mgag200_bo *bo);
 int mgag200_bo_push_sysram(struct mgag200_bo *bo);
diff --git a/drivers/gpu/drm/mgag200/mgag200_ttm.c b/drivers/gpu/drm/mgag200/mgag200_ttm.c
index 3e7e1cd31395..8d850fb0bbe3 100644
--- a/drivers/gpu/drm/mgag200/mgag200_ttm.c
+++ b/drivers/gpu/drm/mgag200/mgag200_ttm.c
@@ -418,7 +418,8 @@ int mgag200_bo_push_sysram(struct mgag200_bo *bo)
 	return 0;
 }
 
-int mgag200_mmap(struct file *filp, struct vm_area_struct *vma)
+int mgag200_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct mga_device *mdev;
diff --git a/drivers/gpu/drm/msm/msm_drv.h b/drivers/gpu/drm/msm/msm_drv.h
index fc8d24f7c084..0075b5beec33 100644
--- a/drivers/gpu/drm/msm/msm_drv.h
+++ b/drivers/gpu/drm/msm/msm_drv.h
@@ -196,7 +196,8 @@ void msm_gem_shrinker_cleanup(struct drm_device *dev);
 
 int msm_gem_mmap_obj(struct drm_gem_object *obj,
 			struct vm_area_struct *vma);
-int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
+int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		 unsigned long map_flags);
 int msm_gem_fault(struct vm_fault *vmf);
 uint64_t msm_gem_mmap_offset(struct drm_gem_object *obj);
 int msm_gem_get_iova(struct drm_gem_object *obj,
diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
index a0c60e738db8..307bf45b23c7 100644
--- a/drivers/gpu/drm/msm/msm_gem.c
+++ b/drivers/gpu/drm/msm/msm_gem.c
@@ -198,11 +198,12 @@ int msm_gem_mmap_obj(struct drm_gem_object *obj,
 	return 0;
 }
 
-int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		 unsigned long map_flags)
 {
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret) {
 		DBG("mmap failed: %d", ret);
 		return ret;
diff --git a/drivers/gpu/drm/nouveau/nouveau_ttm.c b/drivers/gpu/drm/nouveau/nouveau_ttm.c
index 999c35a25498..8624ed5faf35 100644
--- a/drivers/gpu/drm/nouveau/nouveau_ttm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_ttm.c
@@ -265,13 +265,14 @@ const struct ttm_mem_type_manager_func nv04_gart_manager = {
 };
 
 int
-nouveau_ttm_mmap(struct file *filp, struct vm_area_struct *vma)
+nouveau_ttm_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *file_priv = filp->private_data;
 	struct nouveau_drm *drm = nouveau_drm(file_priv->minor->dev);
 
 	if (unlikely(vma->vm_pgoff < DRM_FILE_PAGE_OFFSET))
-		return drm_legacy_mmap(filp, vma);
+		return drm_legacy_mmap(filp, vma, map_flags);
 
 	return ttm_bo_mmap(filp, vma, &drm->ttm.bdev);
 }
diff --git a/drivers/gpu/drm/nouveau/nouveau_ttm.h b/drivers/gpu/drm/nouveau/nouveau_ttm.h
index 25b0de413352..9a1d08adae8a 100644
--- a/drivers/gpu/drm/nouveau/nouveau_ttm.h
+++ b/drivers/gpu/drm/nouveau/nouveau_ttm.h
@@ -17,7 +17,7 @@ struct ttm_tt *nouveau_sgdma_create_ttm(struct ttm_bo_device *,
 
 int  nouveau_ttm_init(struct nouveau_drm *drm);
 void nouveau_ttm_fini(struct nouveau_drm *drm);
-int  nouveau_ttm_mmap(struct file *, struct vm_area_struct *);
+int  nouveau_ttm_mmap(struct file *, struct vm_area_struct *, unsigned long);
 
 int  nouveau_ttm_global_init(struct nouveau_drm *);
 void nouveau_ttm_global_release(struct nouveau_drm *);
diff --git a/drivers/gpu/drm/omapdrm/omap_drv.h b/drivers/gpu/drm/omapdrm/omap_drv.h
index 4bd1e9070b31..f6be59d20781 100644
--- a/drivers/gpu/drm/omapdrm/omap_drv.h
+++ b/drivers/gpu/drm/omapdrm/omap_drv.h
@@ -168,7 +168,8 @@ int omap_gem_dumb_map_offset(struct drm_file *file, struct drm_device *dev,
 		uint32_t handle, uint64_t *offset);
 int omap_gem_dumb_create(struct drm_file *file, struct drm_device *dev,
 		struct drm_mode_create_dumb *args);
-int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma);
+int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		  unsigned long map_flags);
 int omap_gem_mmap_obj(struct drm_gem_object *obj,
 		struct vm_area_struct *vma);
 int omap_gem_fault(struct vm_fault *vmf);
diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
index 5c5c86ddd6f4..47b3f7b84480 100644
--- a/drivers/gpu/drm/omapdrm/omap_gem.c
+++ b/drivers/gpu/drm/omapdrm/omap_gem.c
@@ -561,11 +561,12 @@ int omap_gem_fault(struct vm_fault *vmf)
 }
 
 /** We override mainly to fix up some of the vm mapping flags.. */
-int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		  unsigned long map_flags)
 {
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret) {
 		DBG("mmap failed: %d", ret);
 		return ret;
diff --git a/drivers/gpu/drm/qxl/qxl_drv.h b/drivers/gpu/drm/qxl/qxl_drv.h
index 3591d2330a09..51d0b7063045 100644
--- a/drivers/gpu/drm/qxl/qxl_drv.h
+++ b/drivers/gpu/drm/qxl/qxl_drv.h
@@ -421,7 +421,8 @@ int qxl_mode_dumb_mmap(struct drm_file *filp,
 /* qxl ttm */
 int qxl_ttm_init(struct qxl_device *qdev);
 void qxl_ttm_fini(struct qxl_device *qdev);
-int qxl_mmap(struct file *filp, struct vm_area_struct *vma);
+int qxl_mmap(struct file *filp, struct vm_area_struct *vma,
+	     unsigned long map_flags);
 
 /* qxl image */
 
diff --git a/drivers/gpu/drm/qxl/qxl_ttm.c b/drivers/gpu/drm/qxl/qxl_ttm.c
index 87fc1dbd0a2f..156df612426b 100644
--- a/drivers/gpu/drm/qxl/qxl_ttm.c
+++ b/drivers/gpu/drm/qxl/qxl_ttm.c
@@ -117,7 +117,8 @@ static int qxl_ttm_fault(struct vm_fault *vmf)
 	return r;
 }
 
-int qxl_mmap(struct file *filp, struct vm_area_struct *vma)
+int qxl_mmap(struct file *filp, struct vm_area_struct *vma,
+	     unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct qxl_device *qdev;
diff --git a/drivers/gpu/drm/radeon/radeon_drv.c b/drivers/gpu/drm/radeon/radeon_drv.c
index 74abd161237b..4e1f63f36bff 100644
--- a/drivers/gpu/drm/radeon/radeon_drv.c
+++ b/drivers/gpu/drm/radeon/radeon_drv.c
@@ -135,7 +135,8 @@ extern int radeon_get_crtc_scanoutpos(struct drm_device *dev, unsigned int crtc,
 extern bool radeon_is_px(struct drm_device *dev);
 extern const struct drm_ioctl_desc radeon_ioctls_kms[];
 extern int radeon_max_kms_ioctl;
-int radeon_mmap(struct file *filp, struct vm_area_struct *vma);
+int radeon_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 int radeon_mode_dumb_mmap(struct drm_file *filp,
 			  struct drm_device *dev,
 			  uint32_t handle, uint64_t *offset_p);
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index faa021396da3..eef5930aadd2 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -997,7 +997,8 @@ static int radeon_ttm_fault(struct vm_fault *vmf)
 	return r;
 }
 
-int radeon_mmap(struct file *filp, struct vm_area_struct *vma)
+int radeon_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct radeon_device *rdev;
diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
index b74ac717e56a..0cdc19c7d5ec 100644
--- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
+++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
@@ -288,12 +288,13 @@ int rockchip_gem_mmap_buf(struct drm_gem_object *obj,
 }
 
 /* drm driver mmap file operations */
-int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		      unsigned long map_flags)
 {
 	struct drm_gem_object *obj;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.h b/drivers/gpu/drm/rockchip/rockchip_drm_gem.h
index 3f6ea4d18a5c..a10564450bda 100644
--- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.h
+++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.h
@@ -42,7 +42,8 @@ void *rockchip_gem_prime_vmap(struct drm_gem_object *obj);
 void rockchip_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
 
 /* drm driver mmap file operations */
-int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma);
+int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		      unsigned long map_flags);
 
 /* mmap a gem object to userspace. */
 int rockchip_gem_mmap_buf(struct drm_gem_object *obj,
diff --git a/drivers/gpu/drm/tegra/gem.c b/drivers/gpu/drm/tegra/gem.c
index 7a39a355678a..965d6058b9f5 100644
--- a/drivers/gpu/drm/tegra/gem.c
+++ b/drivers/gpu/drm/tegra/gem.c
@@ -481,13 +481,14 @@ const struct vm_operations_struct tegra_bo_vm_ops = {
 	.close = drm_gem_vm_close,
 };
 
-int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma)
+int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma,
+		   unsigned long map_flags)
 {
 	struct drm_gem_object *gem;
 	struct tegra_bo *bo;
 	int ret;
 
-	ret = drm_gem_mmap(file, vma);
+	ret = drm_gem_mmap(file, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/tegra/gem.h b/drivers/gpu/drm/tegra/gem.h
index 8b32a6fd586d..105a85d74f4d 100644
--- a/drivers/gpu/drm/tegra/gem.h
+++ b/drivers/gpu/drm/tegra/gem.h
@@ -70,7 +70,8 @@ int tegra_bo_dumb_create(struct drm_file *file, struct drm_device *drm,
 int tegra_bo_dumb_map_offset(struct drm_file *file, struct drm_device *drm,
 			     u32 handle, u64 *offset);
 
-int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma);
+int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma,
+		   unsigned long map_flags);
 
 extern const struct vm_operations_struct tegra_bo_vm_ops;
 
diff --git a/drivers/gpu/drm/udl/udl_drv.h b/drivers/gpu/drm/udl/udl_drv.h
index 2a75ab80527a..04510ea0e3fe 100644
--- a/drivers/gpu/drm/udl/udl_drv.h
+++ b/drivers/gpu/drm/udl/udl_drv.h
@@ -133,7 +133,8 @@ int udl_gem_get_pages(struct udl_gem_object *obj);
 void udl_gem_put_pages(struct udl_gem_object *obj);
 int udl_gem_vmap(struct udl_gem_object *obj);
 void udl_gem_vunmap(struct udl_gem_object *obj);
-int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
+int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 int udl_gem_fault(struct vm_fault *vmf);
 
 int udl_handle_damage(struct udl_framebuffer *fb, int x, int y,
diff --git a/drivers/gpu/drm/udl/udl_gem.c b/drivers/gpu/drm/udl/udl_gem.c
index db9ceceba30e..2b867c6e8dcf 100644
--- a/drivers/gpu/drm/udl/udl_gem.c
+++ b/drivers/gpu/drm/udl/udl_gem.c
@@ -84,11 +84,12 @@ int udl_dumb_create(struct drm_file *file,
 			      args->size, &args->handle);
 }
 
-int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/vc4/vc4_bo.c b/drivers/gpu/drm/vc4/vc4_bo.c
index 487f96412d35..10321d757d72 100644
--- a/drivers/gpu/drm/vc4/vc4_bo.c
+++ b/drivers/gpu/drm/vc4/vc4_bo.c
@@ -396,13 +396,14 @@ vc4_prime_export(struct drm_device *dev, struct drm_gem_object *obj, int flags)
 	return drm_gem_prime_export(dev, obj, flags);
 }
 
-int vc4_mmap(struct file *filp, struct vm_area_struct *vma)
+int vc4_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_gem_object *gem_obj;
 	struct vc4_bo *bo;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/vc4/vc4_drv.h b/drivers/gpu/drm/vc4/vc4_drv.h
index df22698d62ee..bb84d31d39eb 100644
--- a/drivers/gpu/drm/vc4/vc4_drv.h
+++ b/drivers/gpu/drm/vc4/vc4_drv.h
@@ -478,7 +478,8 @@ int vc4_get_tiling_ioctl(struct drm_device *dev, void *data,
 			 struct drm_file *file_priv);
 int vc4_get_hang_state_ioctl(struct drm_device *dev, void *data,
 			     struct drm_file *file_priv);
-int vc4_mmap(struct file *filp, struct vm_area_struct *vma);
+int vc4_mmap(struct file *filp, struct vm_area_struct *vma,
+	     unsigned long map_flags);
 struct reservation_object *vc4_prime_res_obj(struct drm_gem_object *obj);
 int vc4_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma);
 struct drm_gem_object *vc4_prime_import_sg_table(struct drm_device *dev,
diff --git a/drivers/gpu/drm/vgem/vgem_drv.c b/drivers/gpu/drm/vgem/vgem_drv.c
index 18f401b442c2..b0221f2a2ada 100644
--- a/drivers/gpu/drm/vgem/vgem_drv.c
+++ b/drivers/gpu/drm/vgem/vgem_drv.c
@@ -248,12 +248,13 @@ static struct drm_ioctl_desc vgem_ioctls[] = {
 	DRM_IOCTL_DEF_DRV(VGEM_FENCE_SIGNAL, vgem_fence_signal_ioctl, DRM_AUTH|DRM_RENDER_ALLOW),
 };
 
-static int vgem_mmap(struct file *filp, struct vm_area_struct *vma)
+static int vgem_mmap(struct file *filp, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	unsigned long flags = vma->vm_flags;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
@@ -370,7 +371,7 @@ static int vgem_prime_mmap(struct drm_gem_object *obj,
 	if (!obj->filp)
 		return -ENODEV;
 
-	ret = call_mmap(obj->filp, vma);
+	ret = call_mmap(obj->filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/virtio/virtgpu_drv.h b/drivers/gpu/drm/virtio/virtgpu_drv.h
index 3a66abb8fd50..382e92eb9cec 100644
--- a/drivers/gpu/drm/virtio/virtgpu_drv.h
+++ b/drivers/gpu/drm/virtio/virtgpu_drv.h
@@ -342,7 +342,8 @@ struct drm_plane *virtio_gpu_plane_init(struct virtio_gpu_device *vgdev,
 /* virtio_gpu_ttm.c */
 int virtio_gpu_ttm_init(struct virtio_gpu_device *vgdev);
 void virtio_gpu_ttm_fini(struct virtio_gpu_device *vgdev);
-int virtio_gpu_mmap(struct file *filp, struct vm_area_struct *vma);
+int virtio_gpu_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 
 /* virtio_gpu_fence.c */
 int virtio_gpu_fence_emit(struct virtio_gpu_device *vgdev,
diff --git a/drivers/gpu/drm/virtio/virtgpu_ttm.c b/drivers/gpu/drm/virtio/virtgpu_ttm.c
index c1f2af4ca4ca..de62b57066f8 100644
--- a/drivers/gpu/drm/virtio/virtgpu_ttm.c
+++ b/drivers/gpu/drm/virtio/virtgpu_ttm.c
@@ -129,7 +129,8 @@ static int virtio_gpu_ttm_fault(struct vm_fault *vmf)
 }
 #endif
 
-int virtio_gpu_mmap(struct file *filp, struct vm_area_struct *vma)
+int virtio_gpu_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct virtio_gpu_device *vgdev;
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
index 4b948fba9eec..5e0216ac6a5a 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
@@ -742,7 +742,8 @@ extern int vmw_fifo_flush(struct vmw_private *dev_priv,
 
 extern int vmw_ttm_global_init(struct vmw_private *dev_priv);
 extern void vmw_ttm_global_release(struct vmw_private *dev_priv);
-extern int vmw_mmap(struct file *filp, struct vm_area_struct *vma);
+extern int vmw_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 
 /**
  * TTM buffer object driver - vmwgfx_buffer.c
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c b/drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c
index e771091d2cd3..0bb831de1f33 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c
@@ -28,7 +28,8 @@
 #include <drm/drmP.h>
 #include "vmwgfx_drv.h"
 
-int vmw_mmap(struct file *filp, struct vm_area_struct *vma)
+int vmw_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct vmw_private *dev_priv;
diff --git a/drivers/hsi/clients/cmt_speech.c b/drivers/hsi/clients/cmt_speech.c
index 727f968ac1cb..507499044727 100644
--- a/drivers/hsi/clients/cmt_speech.c
+++ b/drivers/hsi/clients/cmt_speech.c
@@ -1270,7 +1270,8 @@ static long cs_char_ioctl(struct file *file, unsigned int cmd,
 	return r;
 }
 
-static int cs_char_mmap(struct file *file, struct vm_area_struct *vma)
+static int cs_char_mmap(struct file *file, struct vm_area_struct *vma,
+			unsigned long map_flags)
 {
 	if (vma->vm_end < vma->vm_start)
 		return -EINVAL;
diff --git a/drivers/hwtracing/intel_th/msu.c b/drivers/hwtracing/intel_th/msu.c
index dbbe31df74df..cb943291eb8c 100644
--- a/drivers/hwtracing/intel_th/msu.c
+++ b/drivers/hwtracing/intel_th/msu.c
@@ -1212,7 +1212,8 @@ static const struct vm_operations_struct msc_mmap_ops = {
 	.fault	= msc_mmap_fault,
 };
 
-static int intel_th_msc_mmap(struct file *file, struct vm_area_struct *vma)
+static int intel_th_msc_mmap(struct file *file, struct vm_area_struct *vma,
+			     unsigned long map_flags)
 {
 	unsigned long size = vma->vm_end - vma->vm_start;
 	struct msc_iter *iter = vma->vm_file->private_data;
diff --git a/drivers/hwtracing/stm/core.c b/drivers/hwtracing/stm/core.c
index 0e731143f6a4..4b35b3dfc82e 100644
--- a/drivers/hwtracing/stm/core.c
+++ b/drivers/hwtracing/stm/core.c
@@ -519,7 +519,8 @@ static const struct vm_operations_struct stm_mmap_vmops = {
 	.close	= stm_mmap_close,
 };
 
-static int stm_char_mmap(struct file *file, struct vm_area_struct *vma)
+static int stm_char_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	struct stm_file *stmf = file->private_data;
 	struct stm_device *stm = stmf->stm;
diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
index c023e2c81b8f..3bde88087d6f 100644
--- a/drivers/infiniband/core/uverbs_main.c
+++ b/drivers/infiniband/core/uverbs_main.c
@@ -809,7 +809,8 @@ static ssize_t ib_uverbs_write(struct file *filp, const char __user *buf,
 	return ret;
 }
 
-static int ib_uverbs_mmap(struct file *filp, struct vm_area_struct *vma)
+static int ib_uverbs_mmap(struct file *filp, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	struct ib_uverbs_file *file = filp->private_data;
 	struct ib_device *ib_dev;
diff --git a/drivers/infiniband/hw/hfi1/file_ops.c b/drivers/infiniband/hw/hfi1/file_ops.c
index 3158128d57e8..1868b3558d51 100644
--- a/drivers/infiniband/hw/hfi1/file_ops.c
+++ b/drivers/infiniband/hw/hfi1/file_ops.c
@@ -75,7 +75,8 @@ static int hfi1_file_open(struct inode *inode, struct file *fp);
 static int hfi1_file_close(struct inode *inode, struct file *fp);
 static ssize_t hfi1_write_iter(struct kiocb *kiocb, struct iov_iter *from);
 static unsigned int hfi1_poll(struct file *fp, struct poll_table_struct *pt);
-static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma);
+static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma,
+			  unsigned long map_flags);
 
 static u64 kvirt_to_phys(void *addr);
 static int assign_ctxt(struct hfi1_filedata *fd, struct hfi1_user_info *uinfo);
@@ -450,7 +451,8 @@ static ssize_t hfi1_write_iter(struct kiocb *kiocb, struct iov_iter *from)
 	return reqs;
 }
 
-static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma)
+static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	struct hfi1_filedata *fd = fp->private_data;
 	struct hfi1_ctxtdata *uctxt = fd->uctxt;
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index 9396c1807cc3..2482d0fc2a77 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -59,7 +59,7 @@ static int qib_close(struct inode *, struct file *);
 static ssize_t qib_write(struct file *, const char __user *, size_t, loff_t *);
 static ssize_t qib_write_iter(struct kiocb *, struct iov_iter *);
 static unsigned int qib_poll(struct file *, struct poll_table_struct *);
-static int qib_mmapf(struct file *, struct vm_area_struct *);
+static int qib_mmapf(struct file *, struct vm_area_struct *, unsigned long);
 
 /*
  * This is really, really weird shit - write() and writev() here
@@ -993,7 +993,8 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u64 pgaddr,
  * buffers in the chip.  We have the open and close entries so we can bump
  * the ref count and keep the driver from being unloaded while still mapped.
  */
-static int qib_mmapf(struct file *fp, struct vm_area_struct *vma)
+static int qib_mmapf(struct file *fp, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	struct qib_ctxtdata *rcd;
 	struct qib_devdata *dd;
diff --git a/drivers/media/v4l2-core/v4l2-dev.c b/drivers/media/v4l2-core/v4l2-dev.c
index c647ba648805..1c2980e51708 100644
--- a/drivers/media/v4l2-core/v4l2-dev.c
+++ b/drivers/media/v4l2-core/v4l2-dev.c
@@ -388,7 +388,8 @@ static unsigned long v4l2_get_unmapped_area(struct file *filp,
 }
 #endif
 
-static int v4l2_mmap(struct file *filp, struct vm_area_struct *vm)
+static int v4l2_mmap(struct file *filp, struct vm_area_struct *vm,
+		     unsigned long map_flags)
 {
 	struct video_device *vdev = video_devdata(filp);
 	int ret = -ENODEV;
diff --git a/drivers/misc/aspeed-lpc-ctrl.c b/drivers/misc/aspeed-lpc-ctrl.c
index b5439643f54b..c79564d544c3 100644
--- a/drivers/misc/aspeed-lpc-ctrl.c
+++ b/drivers/misc/aspeed-lpc-ctrl.c
@@ -38,7 +38,8 @@ static struct aspeed_lpc_ctrl *file_aspeed_lpc_ctrl(struct file *file)
 			miscdev);
 }
 
-static int aspeed_lpc_ctrl_mmap(struct file *file, struct vm_area_struct *vma)
+static int aspeed_lpc_ctrl_mmap(struct file *file, struct vm_area_struct *vma,
+				unsigned long map_flags)
 {
 	struct aspeed_lpc_ctrl *lpc_ctrl = file_aspeed_lpc_ctrl(file);
 	unsigned long vsize = vma->vm_end - vma->vm_start;
diff --git a/drivers/misc/cxl/api.c b/drivers/misc/cxl/api.c
index 1a138c83f877..0eb62ecf5a64 100644
--- a/drivers/misc/cxl/api.c
+++ b/drivers/misc/cxl/api.c
@@ -408,9 +408,10 @@ long cxl_fd_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	return afu_ioctl(file, cmd, arg);
 }
 EXPORT_SYMBOL_GPL(cxl_fd_ioctl);
-int cxl_fd_mmap(struct file *file, struct vm_area_struct *vm)
+int cxl_fd_mmap(struct file *file, struct vm_area_struct *vm,
+		unsigned long map_flags)
 {
-	return afu_mmap(file, vm);
+	return afu_mmap(file, vm, map_flags);
 }
 EXPORT_SYMBOL_GPL(cxl_fd_mmap);
 unsigned int cxl_fd_poll(struct file *file, struct poll_table_struct *poll)
diff --git a/drivers/misc/cxl/cxl.h b/drivers/misc/cxl/cxl.h
index b1afeccbb97f..a9c1d4538164 100644
--- a/drivers/misc/cxl/cxl.h
+++ b/drivers/misc/cxl/cxl.h
@@ -1082,7 +1082,8 @@ int afu_allocate_irqs(struct cxl_context *ctx, u32 count);
 int afu_open(struct inode *inode, struct file *file);
 int afu_release(struct inode *inode, struct file *file);
 long afu_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
-int afu_mmap(struct file *file, struct vm_area_struct *vm);
+int afu_mmap(struct file *file, struct vm_area_struct *vm,
+	     unsigned long map_flags);
 unsigned int afu_poll(struct file *file, struct poll_table_struct *poll);
 ssize_t afu_read(struct file *file, char __user *buf, size_t count, loff_t *off);
 extern const struct file_operations afu_fops;
diff --git a/drivers/misc/cxl/file.c b/drivers/misc/cxl/file.c
index 0761271d68c5..47059fb264c9 100644
--- a/drivers/misc/cxl/file.c
+++ b/drivers/misc/cxl/file.c
@@ -303,7 +303,8 @@ static long afu_compat_ioctl(struct file *file, unsigned int cmd,
 	return afu_ioctl(file, cmd, arg);
 }
 
-int afu_mmap(struct file *file, struct vm_area_struct *vm)
+int afu_mmap(struct file *file, struct vm_area_struct *vm,
+	     unsigned long map_flags)
 {
 	struct cxl_context *ctx = file->private_data;
 
diff --git a/drivers/misc/genwqe/card_dev.c b/drivers/misc/genwqe/card_dev.c
index dd4617764f14..82a58da65756 100644
--- a/drivers/misc/genwqe/card_dev.c
+++ b/drivers/misc/genwqe/card_dev.c
@@ -435,7 +435,8 @@ static const struct vm_operations_struct genwqe_vma_ops = {
  * plain buffer, we lookup our dma_mapping list to find the
  * corresponding DMA address for the associated user-space address.
  */
-static int genwqe_mmap(struct file *filp, struct vm_area_struct *vma)
+static int genwqe_mmap(struct file *filp, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	int rc;
 	unsigned long pfn, vsize = vma->vm_end - vma->vm_start;
diff --git a/drivers/misc/mic/scif/scif_fd.c b/drivers/misc/mic/scif/scif_fd.c
index f7e826142a72..5dfbaa681d2d 100644
--- a/drivers/misc/mic/scif/scif_fd.c
+++ b/drivers/misc/mic/scif/scif_fd.c
@@ -34,7 +34,8 @@ static int scif_fdclose(struct inode *inode, struct file *f)
 	return scif_close(priv);
 }
 
-static int scif_fdmmap(struct file *f, struct vm_area_struct *vma)
+static int scif_fdmmap(struct file *f, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	struct scif_endpt *priv = f->private_data;
 
diff --git a/drivers/misc/mic/vop/vop_vringh.c b/drivers/misc/mic/vop/vop_vringh.c
index fed992e2c258..d80418f503b3 100644
--- a/drivers/misc/mic/vop/vop_vringh.c
+++ b/drivers/misc/mic/vop/vop_vringh.c
@@ -1083,7 +1083,8 @@ vop_query_offset(struct vop_vdev *vdev, unsigned long offset,
 /*
  * Maps the device page and virtio rings to user space for readonly access.
  */
-static int vop_mmap(struct file *f, struct vm_area_struct *vma)
+static int vop_mmap(struct file *f, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	struct vop_vdev *vdev = f->private_data;
 	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
diff --git a/drivers/misc/sgi-gru/grufile.c b/drivers/misc/sgi-gru/grufile.c
index 104a05f6b738..2751d82a259f 100644
--- a/drivers/misc/sgi-gru/grufile.c
+++ b/drivers/misc/sgi-gru/grufile.c
@@ -104,7 +104,8 @@ static void gru_vma_close(struct vm_area_struct *vma)
  * and private data structure necessary to allocate, track, and free the
  * underlying pages.
  */
-static int gru_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int gru_file_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	if ((vma->vm_flags & (VM_SHARED | VM_WRITE)) != (VM_SHARED | VM_WRITE))
 		return -EPERM;
diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
index 3568294d4854..7aa296edd4ff 100644
--- a/drivers/mtd/mtdchar.c
+++ b/drivers/mtd/mtdchar.c
@@ -1192,7 +1192,8 @@ static unsigned mtdchar_mmap_capabilities(struct file *file)
 /*
  * set up a mapping for shared memory segments
  */
-static int mtdchar_mmap(struct file *file, struct vm_area_struct *vma)
+static int mtdchar_mmap(struct file *file, struct vm_area_struct *vma,
+			unsigned long map_flags)
 {
 #ifdef CONFIG_MMU
 	struct mtd_file_info *mfi = file->private_data;
diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
index 098360d7ff81..4e77aad084d1 100644
--- a/drivers/pci/proc.c
+++ b/drivers/pci/proc.c
@@ -230,7 +230,8 @@ static long proc_bus_pci_ioctl(struct file *file, unsigned int cmd,
 }
 
 #ifdef HAVE_PCI_MMAP
-static int proc_bus_pci_mmap(struct file *file, struct vm_area_struct *vma)
+static int proc_bus_pci_mmap(struct file *file, struct vm_area_struct *vma,
+			     unsigned long map_flags)
 {
 	struct pci_dev *dev = PDE_DATA(file_inode(file));
 	struct pci_filp_private *fpriv = file->private_data;
diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
index 5beb0c361076..a3dfd8ea6580 100644
--- a/drivers/rapidio/devices/rio_mport_cdev.c
+++ b/drivers/rapidio/devices/rio_mport_cdev.c
@@ -2261,7 +2261,8 @@ static const struct vm_operations_struct vm_ops = {
 	.close = mport_mm_close,
 };
 
-static int mport_cdev_mmap(struct file *filp, struct vm_area_struct *vma)
+static int mport_cdev_mmap(struct file *filp, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	struct mport_cdev_priv *priv = filp->private_data;
 	struct mport_dev *md;
diff --git a/drivers/sbus/char/flash.c b/drivers/sbus/char/flash.c
index a610b8d3d11f..5f748a099d8d 100644
--- a/drivers/sbus/char/flash.c
+++ b/drivers/sbus/char/flash.c
@@ -33,7 +33,8 @@ static struct {
 #define FLASH_MINOR	152
 
 static int
-flash_mmap(struct file *file, struct vm_area_struct *vma)
+flash_mmap(struct file *file, struct vm_area_struct *vma,
+	   unsigned long map_flags)
 {
 	unsigned long addr;
 	unsigned long size;
diff --git a/drivers/sbus/char/jsflash.c b/drivers/sbus/char/jsflash.c
index 14f377ac1280..e497152ce317 100644
--- a/drivers/sbus/char/jsflash.c
+++ b/drivers/sbus/char/jsflash.c
@@ -440,7 +440,8 @@ static long jsf_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
 	return error;
 }
 
-static int jsf_mmap(struct file * file, struct vm_area_struct * vma)
+static int jsf_mmap(struct file *file, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	return -ENXIO;
 }
diff --git a/drivers/scsi/cxlflash/superpipe.c b/drivers/scsi/cxlflash/superpipe.c
index ad0f9968ccfb..cc0bfb044a60 100644
--- a/drivers/scsi/cxlflash/superpipe.c
+++ b/drivers/scsi/cxlflash/superpipe.c
@@ -1160,7 +1160,8 @@ static const struct vm_operations_struct cxlflash_mmap_vmops = {
  *
  * Return: 0 on success, -errno on failure
  */
-static int cxlflash_cxl_mmap(struct file *file, struct vm_area_struct *vma)
+static int cxlflash_cxl_mmap(struct file *file, struct vm_area_struct *vma,
+			     unsigned long map_flags)
 {
 	struct cxl_context *ctx = cxl_fops_get_context(file);
 	struct cxlflash_cfg *cfg = container_of(file->f_op, struct cxlflash_cfg,
@@ -1188,7 +1189,7 @@ static int cxlflash_cxl_mmap(struct file *file, struct vm_area_struct *vma)
 
 	dev_dbg(dev, "%s: mmap for context %d\n", __func__, ctxid);
 
-	rc = cxl_fd_mmap(file, vma);
+	rc = cxl_fd_mmap(file, vma, map_flags);
 	if (likely(!rc)) {
 		/* Insert ourself in the mmap fault handler path */
 		ctxi->cxl_mmap_vmops = vma->vm_ops;
diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index d7ff71e0c85c..ed70002b7c87 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -1227,7 +1227,8 @@ static const struct vm_operations_struct sg_mmap_vm_ops = {
 };
 
 static int
-sg_mmap(struct file *filp, struct vm_area_struct *vma)
+sg_mmap(struct file *filp, struct vm_area_struct *vma,
+	unsigned long map_flags)
 {
 	Sg_fd *sfp;
 	unsigned long req_sz, len, sa;
diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 6ba270e0494d..ad4f863cdb8e 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -375,7 +375,8 @@ static inline vm_flags_t calc_vm_may_flags(unsigned long prot)
 	       _calc_vm_trans(prot, PROT_EXEC,  VM_MAYEXEC);
 }
 
-static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
+static int ashmem_mmap(struct file *file, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	struct ashmem_area *asma = file->private_data;
 	int ret = 0;
diff --git a/drivers/staging/comedi/comedi_fops.c b/drivers/staging/comedi/comedi_fops.c
index 34ca7823255d..05f5833f75e9 100644
--- a/drivers/staging/comedi/comedi_fops.c
+++ b/drivers/staging/comedi/comedi_fops.c
@@ -2185,7 +2185,8 @@ static const struct vm_operations_struct comedi_vm_ops = {
 	.access = comedi_vm_access,
 };
 
-static int comedi_mmap(struct file *file, struct vm_area_struct *vma)
+static int comedi_mmap(struct file *file, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	struct comedi_file *cfp = file->private_data;
 	struct comedi_device *dev = cfp->dev;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cd3311abf999..2064afaf8f3b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -912,7 +912,8 @@ static inline struct vvp_io_args *ll_env_args(const struct lu_env *env)
 /* llite/llite_mmap.c */
 
 int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last);
-int ll_file_mmap(struct file *file, struct vm_area_struct *vma);
+int ll_file_mmap(struct file *file, struct vm_area_struct *vma,
+		 unsigned long map_flags);
 void policy_from_vma(union ldlm_policy_data *policy, struct vm_area_struct *vma,
 		     unsigned long addr, size_t count);
 struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index ccc7ae15a943..30f562cb3355 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -455,7 +455,8 @@ static const struct vm_operations_struct ll_file_vm_ops = {
 	.close			= ll_vm_close,
 };
 
-int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
+int ll_file_mmap(struct file *file, struct vm_area_struct *vma,
+		 unsigned long map_flags)
 {
 	struct inode *inode = file_inode(file);
 	int rc;
@@ -464,7 +465,7 @@ int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
 		return -EOPNOTSUPP;
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_MAP, 1);
-	rc = generic_file_mmap(file, vma);
+	rc = generic_file_mmap(file, vma, 0);
 	if (rc == 0) {
 		vma->vm_ops = &ll_file_vm_ops;
 		vma->vm_ops->open(vma);
diff --git a/drivers/staging/vboxvideo/vbox_drv.h b/drivers/staging/vboxvideo/vbox_drv.h
index 4b9302703b36..337f5dfb8dd0 100644
--- a/drivers/staging/vboxvideo/vbox_drv.h
+++ b/drivers/staging/vboxvideo/vbox_drv.h
@@ -261,7 +261,8 @@ static inline void vbox_bo_unreserve(struct vbox_bo *bo)
 
 void vbox_ttm_placement(struct vbox_bo *bo, int domain);
 int vbox_bo_push_sysram(struct vbox_bo *bo);
-int vbox_mmap(struct file *filp, struct vm_area_struct *vma);
+int vbox_mmap(struct file *filp, struct vm_area_struct *vma,
+	      unsigned long map_flags);
 
 /* vbox_prime.c */
 int vbox_gem_prime_pin(struct drm_gem_object *obj);
diff --git a/drivers/staging/vboxvideo/vbox_ttm.c b/drivers/staging/vboxvideo/vbox_ttm.c
index 34a905d40735..fc7b291691a7 100644
--- a/drivers/staging/vboxvideo/vbox_ttm.c
+++ b/drivers/staging/vboxvideo/vbox_ttm.c
@@ -457,7 +457,8 @@ int vbox_bo_push_sysram(struct vbox_bo *bo)
 	return 0;
 }
 
-int vbox_mmap(struct file *filp, struct vm_area_struct *vma)
+int vbox_mmap(struct file *filp, struct vm_area_struct *vma,
+	      unsigned long map_flags)
 {
 	struct drm_file *file_priv;
 	struct vbox_private *vbox;
diff --git a/drivers/staging/vme/devices/vme_user.c b/drivers/staging/vme/devices/vme_user.c
index a3d4610fbdbe..4edf846529d7 100644
--- a/drivers/staging/vme/devices/vme_user.c
+++ b/drivers/staging/vme/devices/vme_user.c
@@ -484,7 +484,8 @@ static int vme_user_master_mmap(unsigned int minor, struct vm_area_struct *vma)
 	return 0;
 }
 
-static int vme_user_mmap(struct file *file, struct vm_area_struct *vma)
+static int vme_user_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	unsigned int minor = MINOR(file_inode(file)->i_rdev);
 
diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
index ff04b7f8549f..1ddd3f901127 100644
--- a/drivers/uio/uio.c
+++ b/drivers/uio/uio.c
@@ -674,7 +674,8 @@ static int uio_mmap_physical(struct vm_area_struct *vma)
 			       vma->vm_page_prot);
 }
 
-static int uio_mmap(struct file *filep, struct vm_area_struct *vma)
+static int uio_mmap(struct file *filep, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	struct uio_listener *listener = filep->private_data;
 	struct uio_device *idev = listener->dev;
diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
index ebe27595c4af..36b0ff19531a 100644
--- a/drivers/usb/core/devio.c
+++ b/drivers/usb/core/devio.c
@@ -215,7 +215,8 @@ static struct vm_operations_struct usbdev_vm_ops = {
 	.close = usbdev_vm_close
 };
 
-static int usbdev_mmap(struct file *file, struct vm_area_struct *vma)
+static int usbdev_mmap(struct file *file, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	struct usb_memory *usbm = NULL;
 	struct usb_dev_state *ps = file->private_data;
diff --git a/drivers/usb/mon/mon_bin.c b/drivers/usb/mon/mon_bin.c
index b6d8bf475c92..69aec6194772 100644
--- a/drivers/usb/mon/mon_bin.c
+++ b/drivers/usb/mon/mon_bin.c
@@ -1246,7 +1246,8 @@ static const struct vm_operations_struct mon_bin_vm_ops = {
 	.fault =    mon_bin_vma_fault,
 };
 
-static int mon_bin_mmap(struct file *filp, struct vm_area_struct *vma)
+static int mon_bin_mmap(struct file *filp, struct vm_area_struct *vma,
+			unsigned long map_flags)
 {
 	/* don't do anything here: "fault" will set up page table entries */
 	vma->vm_ops = &mon_bin_vm_ops;
diff --git a/drivers/vfio/vfio.c b/drivers/vfio/vfio.c
index 330d50582f40..e972a2de79f6 100644
--- a/drivers/vfio/vfio.c
+++ b/drivers/vfio/vfio.c
@@ -1256,7 +1256,8 @@ static ssize_t vfio_fops_write(struct file *filep, const char __user *buf,
 	return ret;
 }
 
-static int vfio_fops_mmap(struct file *filep, struct vm_area_struct *vma)
+static int vfio_fops_mmap(struct file *filep, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	struct vfio_container *container = filep->private_data;
 	struct vfio_iommu_driver *driver;
@@ -1677,7 +1678,9 @@ static ssize_t vfio_device_fops_write(struct file *filep,
 	return device->ops->write(device->device_data, buf, count, ppos);
 }
 
-static int vfio_device_fops_mmap(struct file *filep, struct vm_area_struct *vma)
+static int vfio_device_fops_mmap(struct file *filep,
+				 struct vm_area_struct *vma,
+				 unsigned long map_flags)
 {
 	struct vfio_device *device = filep->private_data;
 
diff --git a/drivers/video/fbdev/core/fbmem.c b/drivers/video/fbdev/core/fbmem.c
index 7a42238db446..ba675464cc27 100644
--- a/drivers/video/fbdev/core/fbmem.c
+++ b/drivers/video/fbdev/core/fbmem.c
@@ -1380,7 +1380,8 @@ static long fb_compat_ioctl(struct file *file, unsigned int cmd,
 #endif
 
 static int
-fb_mmap(struct file *file, struct vm_area_struct * vma)
+fb_mmap(struct file *file, struct vm_area_struct *vma,
+	unsigned long map_flags)
 {
 	struct fb_info *info = file_fb_info(file);
 	struct fb_ops *fb;
diff --git a/drivers/video/fbdev/pxa3xx-gcu.c b/drivers/video/fbdev/pxa3xx-gcu.c
index 50bce45e7f3d..bed61712616e 100644
--- a/drivers/video/fbdev/pxa3xx-gcu.c
+++ b/drivers/video/fbdev/pxa3xx-gcu.c
@@ -479,7 +479,8 @@ pxa3xx_gcu_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 }
 
 static int
-pxa3xx_gcu_mmap(struct file *file, struct vm_area_struct *vma)
+pxa3xx_gcu_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	unsigned int size = vma->vm_end - vma->vm_start;
 	struct pxa3xx_gcu_priv *priv = to_pxa3xx_gcu_priv(file);
diff --git a/drivers/xen/gntalloc.c b/drivers/xen/gntalloc.c
index 1bf55a32a4b3..35ded2a8bba6 100644
--- a/drivers/xen/gntalloc.c
+++ b/drivers/xen/gntalloc.c
@@ -502,7 +502,8 @@ static const struct vm_operations_struct gntalloc_vmops = {
 	.close = gntalloc_vma_close,
 };
 
-static int gntalloc_mmap(struct file *filp, struct vm_area_struct *vma)
+static int gntalloc_mmap(struct file *filp, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	struct gntalloc_file_private_data *priv = filp->private_data;
 	struct gntalloc_vma_private_data *vm_priv;
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index f3bf8f4e2d6c..2b3971ce0062 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -980,7 +980,8 @@ static long gntdev_ioctl(struct file *flip,
 	return 0;
 }
 
-static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
+static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	struct gntdev_priv *priv = flip->private_data;
 	int index = vma->vm_pgoff;
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index feca75b07fdd..3a8278d72375 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -818,7 +818,8 @@ static const struct vm_operations_struct privcmd_vm_ops = {
 	.fault = privcmd_fault
 };
 
-static int privcmd_mmap(struct file *file, struct vm_area_struct *vma)
+static int privcmd_mmap(struct file *file, struct vm_area_struct *vma,
+			unsigned long map_flags)
 {
 	/* DONTCOPY is essential for Xen because copy_page_range doesn't know
 	 * how to recreate these mappings */
diff --git a/drivers/xen/xenbus/xenbus_dev_backend.c b/drivers/xen/xenbus/xenbus_dev_backend.c
index 1126701e212e..ed7e81ae167a 100644
--- a/drivers/xen/xenbus/xenbus_dev_backend.c
+++ b/drivers/xen/xenbus/xenbus_dev_backend.c
@@ -88,7 +88,8 @@ static long xenbus_backend_ioctl(struct file *file, unsigned int cmd,
 	}
 }
 
-static int xenbus_backend_mmap(struct file *file, struct vm_area_struct *vma)
+static int xenbus_backend_mmap(struct file *file, struct vm_area_struct *vma,
+			       unsigned long map_flags)
 {
 	size_t size = vma->vm_end - vma->vm_start;
 
diff --git a/drivers/xen/xenfs/xenstored.c b/drivers/xen/xenfs/xenstored.c
index 82fd2a396d96..259ad78834a4 100644
--- a/drivers/xen/xenfs/xenstored.c
+++ b/drivers/xen/xenfs/xenstored.c
@@ -30,7 +30,8 @@ static int xsd_kva_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int xsd_kva_mmap(struct file *file, struct vm_area_struct *vma)
+static int xsd_kva_mmap(struct file *file, struct vm_area_struct *vma,
+			unsigned long map_flags)
 {
 	size_t size = vma->vm_end - vma->vm_start;
 
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index 3de3b4a89d89..c8b2fdd53411 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -484,12 +484,13 @@ int v9fs_file_fsync_dotl(struct file *filp, loff_t start, loff_t end,
 }
 
 static int
-v9fs_file_mmap(struct file *filp, struct vm_area_struct *vma)
+v9fs_file_mmap(struct file *filp, struct vm_area_struct *vma,
+	       unsigned long map_flags)
 {
 	int retval;
 
 
-	retval = generic_file_mmap(filp, vma);
+	retval = generic_file_mmap(filp, vma, 0);
 	if (!retval)
 		vma->vm_ops = &v9fs_file_vm_ops;
 
@@ -497,7 +498,8 @@ v9fs_file_mmap(struct file *filp, struct vm_area_struct *vma)
 }
 
 static int
-v9fs_mmap_file_mmap(struct file *filp, struct vm_area_struct *vma)
+v9fs_mmap_file_mmap(struct file *filp, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	int retval;
 	struct inode *inode;
@@ -526,7 +528,7 @@ v9fs_mmap_file_mmap(struct file *filp, struct vm_area_struct *vma)
 	}
 	mutex_unlock(&v9inode->v_mutex);
 
-	retval = generic_file_mmap(filp, vma);
+	retval = generic_file_mmap(filp, vma, 0);
 	if (!retval)
 		vma->vm_ops = &v9fs_mmap_file_vm_ops;
 
diff --git a/fs/aio.c b/fs/aio.c
index dcad3a66748c..e07cabf73093 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -353,7 +353,8 @@ static const struct vm_operations_struct aio_ring_vm_ops = {
 #endif
 };
 
-static int aio_ring_mmap(struct file *file, struct vm_area_struct *vma)
+static int aio_ring_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	vma->vm_flags |= VM_DONTEXPAND;
 	vma->vm_ops = &aio_ring_vm_ops;
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 9e75d8a39aac..fee72875f075 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2262,7 +2262,8 @@ static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.page_mkwrite	= btrfs_page_mkwrite,
 };
 
-static int btrfs_file_mmap(struct file	*filp, struct vm_area_struct *vma)
+static int btrfs_file_mmap(struct file *filp, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	struct address_space *mapping = filp->f_mapping;
 
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 50836280a6f8..35589f2b2c2c 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1755,7 +1755,8 @@ static const struct vm_operations_struct ceph_vmops = {
 	.page_mkwrite	= ceph_page_mkwrite,
 };
 
-int ceph_mmap(struct file *file, struct vm_area_struct *vma)
+int ceph_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct address_space *mapping = file->f_mapping;
 
diff --git a/fs/ceph/super.h b/fs/ceph/super.h
index f02a2225fe42..20e4b4e58418 100644
--- a/fs/ceph/super.h
+++ b/fs/ceph/super.h
@@ -942,7 +942,8 @@ extern void ceph_put_fmode(struct ceph_inode_info *ci, int mode);
 
 /* addr.c */
 extern const struct address_space_operations ceph_aops;
-extern int ceph_mmap(struct file *file, struct vm_area_struct *vma);
+extern int ceph_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags);
 extern int ceph_uninline_data(struct file *filp, struct page *locked_page);
 extern int ceph_pool_perm_check(struct ceph_inode_info *ci, int need);
 extern void ceph_pool_perm_destroy(struct ceph_mds_client* mdsc);
diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index 30bf89b1fd9a..98e793a9e70d 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -109,8 +109,10 @@ extern int cifs_lock(struct file *, int, struct file_lock *);
 extern int cifs_fsync(struct file *, loff_t, loff_t, int);
 extern int cifs_strict_fsync(struct file *, loff_t, loff_t, int);
 extern int cifs_flush(struct file *, fl_owner_t id);
-extern int cifs_file_mmap(struct file * , struct vm_area_struct *);
-extern int cifs_file_strict_mmap(struct file * , struct vm_area_struct *);
+extern int cifs_file_mmap(struct file *, struct vm_area_struct *,
+			  unsigned long);
+extern int cifs_file_strict_mmap(struct file *, struct vm_area_struct *,
+				 unsigned long);
 extern const struct file_operations cifs_dir_ops;
 extern int cifs_dir_open(struct inode *inode, struct file *file);
 extern int cifs_readdir(struct file *file, struct dir_context *ctx);
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index bc09df6b473a..f00394133f61 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3475,7 +3475,8 @@ static const struct vm_operations_struct cifs_file_vm_ops = {
 	.page_mkwrite = cifs_page_mkwrite,
 };
 
-int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
+int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	int rc, xid;
 	struct inode *inode = file_inode(file);
@@ -3488,14 +3489,15 @@ int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
 			return rc;
 	}
 
-	rc = generic_file_mmap(file, vma);
+	rc = generic_file_mmap(file, vma, 0);
 	if (rc == 0)
 		vma->vm_ops = &cifs_file_vm_ops;
 	free_xid(xid);
 	return rc;
 }
 
-int cifs_file_mmap(struct file *file, struct vm_area_struct *vma)
+int cifs_file_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	int rc, xid;
 
@@ -3507,7 +3509,7 @@ int cifs_file_mmap(struct file *file, struct vm_area_struct *vma)
 		free_xid(xid);
 		return rc;
 	}
-	rc = generic_file_mmap(file, vma);
+	rc = generic_file_mmap(file, vma, 0);
 	if (rc == 0)
 		vma->vm_ops = &cifs_file_vm_ops;
 	free_xid(xid);
diff --git a/fs/coda/file.c b/fs/coda/file.c
index 363402fcb3ed..902447f0c152 100644
--- a/fs/coda/file.c
+++ b/fs/coda/file.c
@@ -61,7 +61,8 @@ coda_file_write_iter(struct kiocb *iocb, struct iov_iter *to)
 }
 
 static int
-coda_file_mmap(struct file *coda_file, struct vm_area_struct *vma)
+coda_file_mmap(struct file *coda_file, struct vm_area_struct *vma,
+	       unsigned long map_flags)
 {
 	struct coda_file_info *cfi;
 	struct coda_inode_info *cii;
@@ -96,7 +97,7 @@ coda_file_mmap(struct file *coda_file, struct vm_area_struct *vma)
 	cfi->cfi_mapcount++;
 	spin_unlock(&cii->c_lock);
 
-	return call_mmap(host_file, vma);
+	return call_mmap(host_file, vma, map_flags);
 }
 
 int coda_open(struct inode *coda_inode, struct file *coda_file)
diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
index ca4e83750214..6a2ae381f16a 100644
--- a/fs/ecryptfs/file.c
+++ b/fs/ecryptfs/file.c
@@ -169,7 +169,8 @@ static int read_or_initialize_metadata(struct dentry *dentry)
 	return rc;
 }
 
-static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma)
+static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	struct file *lower_file = ecryptfs_file_to_lower(file);
 	/*
@@ -179,7 +180,7 @@ static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma)
 	 */
 	if (!lower_file->f_op->mmap)
 		return -ENODEV;
-	return generic_file_mmap(file, vma);
+	return generic_file_mmap(file, vma, 0);
 }
 
 /**
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index d34d32bdc944..ffcec18bc332 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -141,10 +141,11 @@ static const struct vm_operations_struct ext2_dax_vm_ops = {
 	.pfn_mkwrite	= ext2_dax_pfn_mkwrite,
 };
 
-static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	if (!IS_DAX(file_inode(file)))
-		return generic_file_mmap(file, vma);
+		return generic_file_mmap(file, vma, 0);
 
 	file_accessed(file);
 	vma->vm_ops = &ext2_dax_vm_ops;
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 0d7cf0cc9b87..d53f11f6b775 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -357,7 +357,8 @@ static const struct vm_operations_struct ext4_file_vm_ops = {
 	.page_mkwrite   = ext4_page_mkwrite,
 };
 
-static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	struct inode *inode = file->f_mapping->host;
 
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 2706130c261b..47ba41af9b94 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -425,7 +425,8 @@ static loff_t f2fs_llseek(struct file *file, loff_t offset, int whence)
 	return -EINVAL;
 }
 
-static int f2fs_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int f2fs_file_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	struct inode *inode = file_inode(file);
 	int err;
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index ab60051be6e5..1657bd7186dc 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2063,7 +2063,8 @@ static const struct vm_operations_struct fuse_file_vm_ops = {
 	.page_mkwrite	= fuse_page_mkwrite,
 };
 
-static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE))
 		fuse_link_write_file(file);
@@ -2073,7 +2074,8 @@ static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
 	return 0;
 }
 
-static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma)
+static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma,
+			    unsigned long map_flags)
 {
 	/* Can't provide the coherency needed for MAP_SHARED */
 	if (vma->vm_flags & VM_MAYSHARE)
@@ -2081,7 +2083,7 @@ static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma)
 
 	invalidate_inode_pages2(file->f_mapping);
 
-	return generic_file_mmap(file, vma);
+	return generic_file_mmap(file, vma, 0);
 }
 
 static int convert_fuse_file_lock(struct fuse_conn *fc,
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index c2062a108d19..50ea01d6c33e 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -506,7 +506,8 @@ static const struct vm_operations_struct gfs2_vm_ops = {
  * Returns: 0
  */
 
-static int gfs2_mmap(struct file *file, struct vm_area_struct *vma)
+static int gfs2_mmap(struct file *file, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	struct gfs2_inode *ip = GFS2_I(file->f_mapping->host);
 
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 28d2753be094..5bf5a3ec4818 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -118,7 +118,8 @@ static void huge_pagevec_release(struct pagevec *pvec)
 	pagevec_reinit(pvec);
 }
 
-static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma,
+			       unsigned long map_flags)
 {
 	struct inode *inode = file_inode(file);
 	loff_t len, vma_len;
diff --git a/fs/kernfs/file.c b/fs/kernfs/file.c
index ac2dfe0c5a9c..58a85c61c657 100644
--- a/fs/kernfs/file.c
+++ b/fs/kernfs/file.c
@@ -467,7 +467,8 @@ static const struct vm_operations_struct kernfs_vm_ops = {
 #endif
 };
 
-static int kernfs_fop_mmap(struct file *file, struct vm_area_struct *vma)
+static int kernfs_fop_mmap(struct file *file, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	struct kernfs_open_file *of = kernfs_of(file);
 	const struct kernfs_ops *ops;
diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
index 6719c0be674d..94f6eb021a89 100644
--- a/fs/ncpfs/mmap.c
+++ b/fs/ncpfs/mmap.c
@@ -100,7 +100,8 @@ static const struct vm_operations_struct ncp_file_mmap =
 
 
 /* This is used for a general mmap of a ncp file */
-int ncp_mmap(struct file *file, struct vm_area_struct *vma)
+int ncp_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	struct inode *inode = file_inode(file);
 	
diff --git a/fs/ncpfs/ncp_fs.h b/fs/ncpfs/ncp_fs.h
index b9f69e1b1f43..c3a1da959ee3 100644
--- a/fs/ncpfs/ncp_fs.h
+++ b/fs/ncpfs/ncp_fs.h
@@ -92,7 +92,7 @@ extern const struct file_operations ncp_file_operations;
 int ncp_make_open(struct inode *, int);
 
 /* linux/fs/ncpfs/mmap.c */
-int ncp_mmap(struct file *, struct vm_area_struct *);
+int ncp_mmap(struct file *, struct vm_area_struct *, unsigned long);
 
 /* linux/fs/ncpfs/ncplib_kernel.c */
 int ncp_make_closed(struct inode *);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index af330c31f627..9e364d43dfb4 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -176,7 +176,8 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 EXPORT_SYMBOL_GPL(nfs_file_read);
 
 int
-nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
+nfs_file_mmap(struct file *file, struct vm_area_struct *vma,
+	      unsigned long map_flags)
 {
 	struct inode *inode = file_inode(file);
 	int	status;
@@ -186,7 +187,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 	/* Note: generic_file_mmap() returns ENOSYS on nommu systems
 	 *       so we call that before revalidating the mapping
 	 */
-	status = generic_file_mmap(file, vma);
+	status = generic_file_mmap(file, vma, 0);
 	if (!status) {
 		vma->vm_ops = &nfs_file_vm_ops;
 		status = nfs_revalidate_mapping(inode, file->f_mapping);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dc456416d2be..8b913079684d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -370,7 +370,7 @@ int nfs_rename(struct inode *, struct dentry *,
 int nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync);
 loff_t nfs_file_llseek(struct file *, loff_t, int);
 ssize_t nfs_file_read(struct kiocb *, struct iov_iter *);
-int nfs_file_mmap(struct file *, struct vm_area_struct *);
+int nfs_file_mmap(struct file *, struct vm_area_struct *, unsigned long);
 ssize_t nfs_file_write(struct kiocb *, struct iov_iter *);
 int nfs_file_release(struct inode *, struct file *);
 int nfs_lock(struct file *, int, struct file_lock *);
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index c5fa3dee72fc..71c5a24d78ce 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -126,7 +126,8 @@ static const struct vm_operations_struct nilfs_file_vm_ops = {
 	.page_mkwrite	= nilfs_page_mkwrite,
 };
 
-static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	file_accessed(file);
 	vma->vm_ops = &nilfs_file_vm_ops;
diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index 098f5c712569..a164bcd56f0e 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -179,7 +179,8 @@ static const struct vm_operations_struct ocfs2_file_vm_ops = {
 	.page_mkwrite	= ocfs2_page_mkwrite,
 };
 
-int ocfs2_mmap(struct file *file, struct vm_area_struct *vma)
+int ocfs2_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	int ret = 0, lock_level = 0;
 
diff --git a/fs/ocfs2/mmap.h b/fs/ocfs2/mmap.h
index 1274ee0f1fe2..3aecb132ab44 100644
--- a/fs/ocfs2/mmap.h
+++ b/fs/ocfs2/mmap.h
@@ -1,6 +1,7 @@
 #ifndef OCFS2_MMAP_H
 #define OCFS2_MMAP_H
 
-int ocfs2_mmap(struct file *file, struct vm_area_struct *vma);
+int ocfs2_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags);
 
 #endif  /* OCFS2_MMAP_H */
diff --git a/fs/orangefs/file.c b/fs/orangefs/file.c
index 28f38d813ad2..9b8fda1279e9 100644
--- a/fs/orangefs/file.c
+++ b/fs/orangefs/file.c
@@ -584,7 +584,8 @@ static long orangefs_ioctl(struct file *file, unsigned int cmd, unsigned long ar
 /*
  * Memory map a region of a file.
  */
-static int orangefs_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int orangefs_file_mmap(struct file *file, struct vm_area_struct *vma,
+			      unsigned long map_flags)
 {
 	gossip_debug(GOSSIP_FILE_DEBUG,
 		     "orangefs_file_mmap: called on %s\n",
@@ -597,7 +598,7 @@ static int orangefs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	vma->vm_flags &= ~VM_RAND_READ;
 
 	/* Use readonly mmap since we cannot support writable maps. */
-	return generic_file_readonly_mmap(file, vma);
+	return generic_file_readonly_mmap(file, vma, 0);
 }
 
 #define mapping_nrpages(idata) ((idata)->nrpages)
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index e250910cffc8..4b7d31616985 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -277,15 +277,16 @@ static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned
 }
 #endif
 
-static int proc_reg_mmap(struct file *file, struct vm_area_struct *vma)
+static int proc_reg_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	struct proc_dir_entry *pde = PDE(file_inode(file));
 	int rv = -EIO;
-	int (*mmap)(struct file *, struct vm_area_struct *);
+	int (*mmap)(struct file *, struct vm_area_struct *, unsigned long);
 	if (use_pde(pde)) {
 		mmap = pde->proc_fops->mmap;
 		if (mmap)
-			rv = mmap(file, vma);
+			rv = mmap(file, vma, map_flags);
 		unuse_pde(pde);
 	}
 	return rv;
diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 885d445afa0d..36463814ffc1 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -406,7 +406,8 @@ static int vmcore_remap_oldmem_pfn(struct vm_area_struct *vma,
 		return remap_oldmem_pfn_range(vma, from, pfn, size, prot);
 }
 
-static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
+static int mmap_vmcore(struct file *file, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	size_t size = vma->vm_end - vma->vm_start;
 	u64 start, end, len, tsz;
@@ -485,7 +486,8 @@ static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
 	return -EAGAIN;
 }
 #else
-static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
+static int mmap_vmcore(struct file *file, struct vm_area_struct *vma,
+		       unsigned long map_flags)
 {
 	return -ENOSYS;
 }
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 2ef7ce75c062..a41eba2c5ff9 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -32,7 +32,8 @@ static unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
 						   unsigned long len,
 						   unsigned long pgoff,
 						   unsigned long flags);
-static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma);
+static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma,
+			    unsigned long map_flags);
 
 static unsigned ramfs_mmap_capabilities(struct file *file)
 {
@@ -257,7 +258,8 @@ static unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
 /*
  * set up a mapping for shared memory segments
  */
-static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma)
+static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma,
+			    unsigned long map_flags)
 {
 	if (!(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
 		return -ENOSYS;
diff --git a/fs/romfs/mmap-nommu.c b/fs/romfs/mmap-nommu.c
index 1118a0dc6b45..60a893b5e864 100644
--- a/fs/romfs/mmap-nommu.c
+++ b/fs/romfs/mmap-nommu.c
@@ -65,7 +65,8 @@ static unsigned long romfs_get_unmapped_area(struct file *file,
  * permit a R/O mapping to be made directly through onto an MTD device if
  * possible
  */
-static int romfs_mmap(struct file *file, struct vm_area_struct *vma)
+static int romfs_mmap(struct file *file, struct vm_area_struct *vma,
+		      unsigned long map_flags)
 {
 	return vma->vm_flags & (VM_SHARED | VM_MAYSHARE) ? 0 : -ENOSYS;
 }
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 8cad0b19b404..9edcd7f68c0b 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1612,11 +1612,12 @@ static const struct vm_operations_struct ubifs_file_vm_ops = {
 	.page_mkwrite = ubifs_vm_page_mkwrite,
 };
 
-static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	int err;
 
-	err = generic_file_mmap(file, vma);
+	err = generic_file_mmap(file, vma, 0);
 	if (err)
 		return err;
 	vma->vm_ops = &ubifs_file_vm_ops;
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index c4893e226fd8..cacc0162a41a 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1146,9 +1146,8 @@ static const struct vm_operations_struct xfs_file_vm_ops = {
 };
 
 STATIC int
-xfs_file_mmap(
-	struct file	*filp,
-	struct vm_area_struct *vma)
+xfs_file_mmap(struct file *filp, struct vm_area_struct *vma,
+	      unsigned long map_flags)
 {
 	file_accessed(filp);
 	vma->vm_ops = &xfs_file_vm_ops;
diff --git a/include/drm/drm_gem.h b/include/drm/drm_gem.h
index 663d80358057..3de33c5e374e 100644
--- a/include/drm/drm_gem.h
+++ b/include/drm/drm_gem.h
@@ -214,7 +214,8 @@ void drm_gem_vm_open(struct vm_area_struct *vma);
 void drm_gem_vm_close(struct vm_area_struct *vma);
 int drm_gem_mmap_obj(struct drm_gem_object *obj, unsigned long obj_size,
 		     struct vm_area_struct *vma);
-int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
+int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 
 /**
  * drm_gem_object_get - acquire a GEM buffer object reference
diff --git a/include/drm/drm_gem_cma_helper.h b/include/drm/drm_gem_cma_helper.h
index b42529e0fae0..6c3d3a09f364 100644
--- a/include/drm/drm_gem_cma_helper.h
+++ b/include/drm/drm_gem_cma_helper.h
@@ -79,7 +79,8 @@ int drm_gem_cma_dumb_map_offset(struct drm_file *file_priv,
 				u64 *offset);
 
 /* set vm_flags and we can change the VM attribute to other one at here */
-int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma);
+int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma,
+		unsigned long map_flags);
 
 /* allocate physical memory */
 struct drm_gem_cma_object *drm_gem_cma_create(struct drm_device *drm,
diff --git a/include/drm/drm_legacy.h b/include/drm/drm_legacy.h
index cf0e7d89bcdf..889510d3b9b8 100644
--- a/include/drm/drm_legacy.h
+++ b/include/drm/drm_legacy.h
@@ -161,7 +161,8 @@ int drm_legacy_rmmap_locked(struct drm_device *d, struct drm_local_map *map);
 void drm_legacy_master_rmmaps(struct drm_device *dev,
 			      struct drm_master *master);
 struct drm_local_map *drm_legacy_getsarea(struct drm_device *dev);
-int drm_legacy_mmap(struct file *filp, struct vm_area_struct *vma);
+int drm_legacy_mmap(struct file *filp, struct vm_area_struct *vma,
+		    unsigned long map_flags);
 
 int drm_legacy_addbufs_agp(struct drm_device *d, struct drm_buf_desc *req);
 int drm_legacy_addbufs_pci(struct drm_device *d, struct drm_buf_desc *req);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6e1fd5d21248..47249bbe973c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1673,7 +1673,7 @@ struct file_operations {
 	unsigned int (*poll) (struct file *, struct poll_table_struct *);
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
-	int (*mmap) (struct file *, struct vm_area_struct *);
+	int (*mmap) (struct file *, struct vm_area_struct *, unsigned long);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
 	int (*release) (struct inode *, struct file *);
@@ -1743,9 +1743,10 @@ static inline ssize_t call_write_iter(struct file *file, struct kiocb *kio,
 	return file->f_op->write_iter(kio, iter);
 }
 
-static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
+static inline int call_mmap(struct file *file, struct vm_area_struct *vma,
+			    unsigned long flags)
 {
-	return file->f_op->mmap(file, vma);
+	return file->f_op->mmap(file, vma, flags);
 }
 
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
@@ -2864,8 +2865,10 @@ extern int set_blocksize(struct block_device *, int);
 extern int sb_set_blocksize(struct super_block *, int);
 extern int sb_min_blocksize(struct super_block *, int);
 
-extern int generic_file_mmap(struct file *, struct vm_area_struct *);
-extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
+extern int generic_file_mmap(struct file *, struct vm_area_struct *,
+		unsigned long);
+extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *,
+		unsigned long);
 extern ssize_t generic_write_checks(struct kiocb *, struct iov_iter *);
 extern ssize_t generic_file_read_iter(struct kiocb *, struct iov_iter *);
 extern ssize_t __generic_file_write_iter(struct kiocb *, struct iov_iter *);
diff --git a/include/misc/cxl.h b/include/misc/cxl.h
index 480d50a0b8ba..2c356a8126ec 100644
--- a/include/misc/cxl.h
+++ b/include/misc/cxl.h
@@ -266,7 +266,8 @@ int cxl_start_work(struct cxl_context *ctx,
 int cxl_fd_open(struct inode *inode, struct file *file);
 int cxl_fd_release(struct inode *inode, struct file *file);
 long cxl_fd_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
-int cxl_fd_mmap(struct file *file, struct vm_area_struct *vm);
+int cxl_fd_mmap(struct file *file, struct vm_area_struct *vm,
+		unsigned long map_flags);
 unsigned int cxl_fd_poll(struct file *file, struct poll_table_struct *poll);
 ssize_t cxl_fd_read(struct file *file, char __user *buf, size_t count,
 			   loff_t *off);
diff --git a/ipc/shm.c b/ipc/shm.c
index 8828b4c3a190..96a82d0d00b0 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -411,7 +411,8 @@ static struct mempolicy *shm_get_policy(struct vm_area_struct *vma,
 }
 #endif
 
-static int shm_mmap(struct file *file, struct vm_area_struct *vma)
+static int shm_mmap(struct file *file, struct vm_area_struct *vma,
+		    unsigned long map_flags)
 {
 	struct shm_file_data *sfd = shm_file_data(file);
 	int ret;
@@ -424,7 +425,7 @@ static int shm_mmap(struct file *file, struct vm_area_struct *vma)
 	if (ret)
 		return ret;
 
-	ret = call_mmap(sfd->file, vma);
+	ret = call_mmap(sfd->file, vma, map_flags);
 	if (ret) {
 		shm_close(vma);
 		return ret;
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 426c2ffba16d..1a32d165db88 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5219,7 +5219,8 @@ static const struct vm_operations_struct perf_mmap_vmops = {
 	.page_mkwrite	= perf_mmap_fault,
 };
 
-static int perf_mmap(struct file *file, struct vm_area_struct *vma)
+static int perf_mmap(struct file *file, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	struct perf_event *event = file->private_data;
 	unsigned long user_locked, user_lock_limit;
diff --git a/kernel/kcov.c b/kernel/kcov.c
index cd771993f96f..453c484ac00a 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -132,7 +132,8 @@ void kcov_task_exit(struct task_struct *t)
 	kcov_put(kcov);
 }
 
-static int kcov_mmap(struct file *filep, struct vm_area_struct *vma)
+static int kcov_mmap(struct file *filep, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	int res = 0;
 	void *area;
diff --git a/kernel/relay.c b/kernel/relay.c
index 39a9dfc69486..58dee7ee8dbb 100644
--- a/kernel/relay.c
+++ b/kernel/relay.c
@@ -906,7 +906,8 @@ static int relay_file_open(struct inode *inode, struct file *filp)
  *
  *	Calls upon relay_mmap_buf() to map the file into user space.
  */
-static int relay_file_mmap(struct file *filp, struct vm_area_struct *vma)
+static int relay_file_mmap(struct file *filp, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	struct rchan_buf *buf = filp->private_data;
 	return relay_mmap_buf(buf, vma);
diff --git a/mm/filemap.c b/mm/filemap.c
index a49702445ce0..2457e34d10e0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2569,7 +2569,8 @@ const struct vm_operations_struct generic_file_vm_ops = {
 
 /* This is used for a general mmap of a disk file */
 
-int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
+int generic_file_mmap(struct file * file, struct vm_area_struct * vma,
+		unsigned long map_flags)
 {
 	struct address_space *mapping = file->f_mapping;
 
@@ -2583,18 +2584,21 @@ int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
 /*
  * This is for filesystems which do not implement ->writepage.
  */
-int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma)
+int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma,
+		unsigned long map_flags)
 {
 	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE))
 		return -EINVAL;
-	return generic_file_mmap(file, vma);
+	return generic_file_mmap(file, vma, 0);
 }
 #else
-int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
+int generic_file_mmap(struct file * file, struct vm_area_struct * vma,
+		unsigned long map_flags)
 {
 	return -ENOSYS;
 }
-int generic_file_readonly_mmap(struct file * file, struct vm_area_struct * vma)
+int generic_file_readonly_mmap(struct file * file, struct vm_area_struct * vma,
+		unsigned long map_flags)
 {
 	return -ENOSYS;
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index f19efcf75418..744faae86781 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1686,7 +1686,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 * new file must not have been exposed to user-space, yet.
 		 */
 		vma->vm_file = get_file(file);
-		error = call_mmap(file, vma);
+		error = call_mmap(file, vma, 0);
 		if (error)
 			goto unmap_and_free_vma;
 
diff --git a/mm/nommu.c b/mm/nommu.c
index fc184f597d59..3eb3bd76c405 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1089,7 +1089,7 @@ static int do_mmap_shared_file(struct vm_area_struct *vma)
 {
 	int ret;
 
-	ret = call_mmap(vma->vm_file, vma);
+	ret = call_mmap(vma->vm_file, vma, 0);
 	if (ret == 0) {
 		vma->vm_region->vm_top = vma->vm_region->vm_end;
 		return 0;
@@ -1120,7 +1120,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
 	 * - VM_MAYSHARE will be set if it may attempt to share
 	 */
 	if (capabilities & NOMMU_MAP_DIRECT) {
-		ret = call_mmap(vma->vm_file, vma);
+		ret = call_mmap(vma->vm_file, vma, 0);
 		if (ret == 0) {
 			/* shouldn't return success if we're not sharing */
 			BUG_ON(!(vma->vm_flags & VM_MAYSHARE));
diff --git a/mm/shmem.c b/mm/shmem.c
index 6540e5982444..446aca49f1eb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2130,7 +2130,8 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 	return retval;
 }
 
-static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
+static int shmem_mmap(struct file *file, struct vm_area_struct *vma,
+		      unsigned long map_flags)
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
diff --git a/net/socket.c b/net/socket.c
index ad22df1ffbd1..8189ea8ba415 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -115,7 +115,8 @@ unsigned int sysctl_net_busy_poll __read_mostly;
 
 static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to);
 static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from);
-static int sock_mmap(struct file *file, struct vm_area_struct *vma);
+static int sock_mmap(struct file *file, struct vm_area_struct *vma,
+		     unsigned long map_flags);
 
 static int sock_close(struct inode *inode, struct file *file);
 static unsigned int sock_poll(struct file *file,
@@ -1100,7 +1101,8 @@ static unsigned int sock_poll(struct file *file, poll_table *wait)
 	return busy_flag | sock->ops->poll(file, sock, wait);
 }
 
-static int sock_mmap(struct file *file, struct vm_area_struct *vma)
+static int sock_mmap(struct file *file, struct vm_area_struct *vma,
+		     unsigned long map_flags)
 {
 	struct socket *sock = file->private_data;
 
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index 00eed842c491..802c801a38dd 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -215,7 +215,8 @@ static ssize_t sel_read_handle_status(struct file *filp, char __user *buf,
 }
 
 static int sel_mmap_handle_status(struct file *filp,
-				  struct vm_area_struct *vma)
+				  struct vm_area_struct *vma,
+				  unsigned long map_flags)
 {
 	struct page    *status = filp->private_data;
 	unsigned long	size = vma->vm_end - vma->vm_start;
@@ -444,7 +445,8 @@ static const struct vm_operations_struct sel_mmap_policy_ops = {
 	.page_mkwrite = sel_mmap_policy_fault,
 };
 
-static int sel_mmap_policy(struct file *filp, struct vm_area_struct *vma)
+static int sel_mmap_policy(struct file *filp, struct vm_area_struct *vma,
+			   unsigned long map_flags)
 {
 	if (vma->vm_flags & VM_SHARED) {
 		/* do not allow mprotect to make mapping writable */
diff --git a/sound/core/compress_offload.c b/sound/core/compress_offload.c
index fec1dfdb14ad..884cefaf906e 100644
--- a/sound/core/compress_offload.c
+++ b/sound/core/compress_offload.c
@@ -391,7 +391,8 @@ static ssize_t snd_compr_read(struct file *f, char __user *buf,
 	return retval;
 }
 
-static int snd_compr_mmap(struct file *f, struct vm_area_struct *vma)
+static int snd_compr_mmap(struct file *f, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	return -ENXIO;
 }
diff --git a/sound/core/hwdep.c b/sound/core/hwdep.c
index a73baa1242be..070b83091c60 100644
--- a/sound/core/hwdep.c
+++ b/sound/core/hwdep.c
@@ -260,7 +260,8 @@ static long snd_hwdep_ioctl(struct file * file, unsigned int cmd,
 	return -ENOTTY;
 }
 
-static int snd_hwdep_mmap(struct file * file, struct vm_area_struct * vma)
+static int snd_hwdep_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	struct snd_hwdep *hw = file->private_data;
 	if (hw->ops.mmap)
diff --git a/sound/core/info.c b/sound/core/info.c
index bcf6a48cc70d..6551d90aac2c 100644
--- a/sound/core/info.c
+++ b/sound/core/info.c
@@ -232,7 +232,8 @@ static long snd_info_entry_ioctl(struct file *file, unsigned int cmd,
 				   file, cmd, arg);
 }
 
-static int snd_info_entry_mmap(struct file *file, struct vm_area_struct *vma)
+static int snd_info_entry_mmap(struct file *file, struct vm_area_struct *vma,
+			       unsigned long map_flags)
 {
 	struct inode *inode = file_inode(file);
 	struct snd_info_private_data *data;
diff --git a/sound/core/init.c b/sound/core/init.c
index b4365bcf28a7..b83ca6424fae 100644
--- a/sound/core/init.c
+++ b/sound/core/init.c
@@ -356,7 +356,8 @@ static long snd_disconnect_ioctl(struct file *file,
 	return -ENODEV;
 }
 
-static int snd_disconnect_mmap(struct file *file, struct vm_area_struct *vma)
+static int snd_disconnect_mmap(struct file *file, struct vm_area_struct *vma,
+			       unsigned long map_flags)
 {
 	return -ENODEV;
 }
diff --git a/sound/core/oss/pcm_oss.c b/sound/core/oss/pcm_oss.c
index e49f448ee04f..abcace0d7234 100644
--- a/sound/core/oss/pcm_oss.c
+++ b/sound/core/oss/pcm_oss.c
@@ -2716,7 +2716,8 @@ static unsigned int snd_pcm_oss_poll(struct file *file, poll_table * wait)
 	return mask;
 }
 
-static int snd_pcm_oss_mmap(struct file *file, struct vm_area_struct *area)
+static int snd_pcm_oss_mmap(struct file *file, struct vm_area_struct *area,
+			    unsigned long map_flags)
 {
 	struct snd_pcm_oss_file *pcm_oss_file;
 	struct snd_pcm_substream *substream = NULL;
diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
index 22995cb3bd44..498de2cb9e94 100644
--- a/sound/core/pcm_native.c
+++ b/sound/core/pcm_native.c
@@ -3585,7 +3585,8 @@ int snd_pcm_mmap_data(struct snd_pcm_substream *substream, struct file *file,
 }
 EXPORT_SYMBOL(snd_pcm_mmap_data);
 
-static int snd_pcm_mmap(struct file *file, struct vm_area_struct *area)
+static int snd_pcm_mmap(struct file *file, struct vm_area_struct *area,
+		unsigned long map_flags)
 {
 	struct snd_pcm_file * pcm_file;
 	struct snd_pcm_substream *substream;	
diff --git a/sound/oss/soundcard.c b/sound/oss/soundcard.c
index b70c7c8f9c5d..b6e8ba2ec452 100644
--- a/sound/oss/soundcard.c
+++ b/sound/oss/soundcard.c
@@ -420,7 +420,8 @@ static unsigned int sound_poll(struct file *file, poll_table * wait)
 	return 0;
 }
 
-static int sound_mmap(struct file *file, struct vm_area_struct *vma)
+static int sound_mmap(struct file *file, struct vm_area_struct *vma,
+		      unsigned long map_flags)
 {
 	int dev_class;
 	unsigned long size;
diff --git a/sound/oss/swarm_cs4297a.c b/sound/oss/swarm_cs4297a.c
index 97899352b15f..4a020d2a53ab 100644
--- a/sound/oss/swarm_cs4297a.c
+++ b/sound/oss/swarm_cs4297a.c
@@ -1962,7 +1962,8 @@ static unsigned int cs4297a_poll(struct file *file,
 }
 
 
-static int cs4297a_mmap(struct file *file, struct vm_area_struct *vma)
+static int cs4297a_mmap(struct file *file, struct vm_area_struct *vma,
+			unsigned long map_flags)
 {
         /* XXXKW currently no mmap support */
         return -EINVAL;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 15252d723b54..ec30aa99018d 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -2395,7 +2395,8 @@ static const struct vm_operations_struct kvm_vcpu_vm_ops = {
 	.fault = kvm_vcpu_fault,
 };
 
-static int kvm_vcpu_mmap(struct file *file, struct vm_area_struct *vma)
+static int kvm_vcpu_mmap(struct file *file, struct vm_area_struct *vma,
+			 unsigned long map_flags)
 {
 	vma->vm_ops = &kvm_vcpu_vm_ops;
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
