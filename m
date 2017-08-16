Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B19BD6B02F4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 03:50:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r133so53619256pgr.6
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:50:41 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f83si163842pfk.367.2017.08.16.00.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 00:50:36 -0700 (PDT)
Subject: [PATCH v5 1/5] vfs: add flags parameter to ->mmap() in 'struct
 file_operations'
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Aug 2017 00:44:11 -0700
Message-ID: <150286945172.8837.7150786869247758343.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, linux-fsdevel@vger.kernel.org

There is no room for new vm_flags without requiring a 64-bit host
architecture. Also, the flags that are being proposed as additions for
new mmap behavior, like MAP_SYNC and MAP_DIRECT, only have relevance to
a filesystem, the core mm can mostly ignore them. So, we arrange for the
mmap(2) flags to be passed all the way through to ->mmap() so the leaf
implementation can handle them.

This conversion was performed by the following semantic patch, as well
as manual edits to handle the non-local / shared mmap handlers
(drm_gem_mmap, radeon_mmap, vmw_mmap, nfs_file_mmap, generic_file_mmap,
generic_file_readonly_mmap, ast_mmap, mgag200_mmap), and the oddity that
is proc_reg_mmap.

// mmap_flags.cocci: add an 'flags' argument to 'mmap' in 'struct file_operations'
// usage: make coccicheck COCCI=mmap_flags.cocci MODE=patch

@ a @
identifier fn;
identifier ops;
@@

struct file_operations ops = { ..., .mmap = fn, ...};

@@
identifier a.fn;
identifier x, y;
@@

int
- fn(struct file *x, struct vm_area_struct *y)
+ fn(struct file *x, struct vm_area_struct *y, unsigned long map_flags)
{
...
}

@@
expression E1, E2;
@@

- generic_file_mmap(E1, E2)
+ generic_file_mmap(E1, E2, 0)

@@
expression E1, E2;
@@

- generic_file_readonly_mmap(E1, E2)
+ generic_file_readonly_mmap(E1, E2, 0)

@@
expression E1, E2;
@@

- call_mmap(E1, E2)
+ call_mmap(E1, E2, 0)

@@
expression E1, E2;
@@

- drm_gem_mmap(E1, E2)
+ drm_gem_mmap(E1, E2, 0)

@@
expression E1, E2;
@@

- radeon_mmap(E1, E2)
+ radeon_mmap(E1, E2, 0)

@@
identifier a.fn;
expression E1, E2;
@@

- fn(E1, E2)
+ fn(E1, E2, 0)

Suggested-by: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arc/kernel/arc_hostlink.c                   |    3 ++-
 arch/powerpc/kernel/proc_powerpc.c               |    3 ++-
 arch/powerpc/kvm/book3s_64_vio.c                 |    3 ++-
 arch/powerpc/platforms/cell/spufs/file.c         |   21 ++++++++++++++-------
 arch/powerpc/platforms/powernv/opal-prd.c        |    3 ++-
 arch/um/drivers/mmapper_kern.c                   |    3 ++-
 drivers/android/binder.c                         |    3 ++-
 drivers/char/agp/frontend.c                      |    3 ++-
 drivers/char/bsr.c                               |    3 ++-
 drivers/char/hpet.c                              |    6 ++++--
 drivers/char/mbcs.c                              |    3 ++-
 drivers/char/mem.c                               |   11 +++++++----
 drivers/char/mspec.c                             |    9 ++++++---
 drivers/char/uv_mmtimer.c                        |    6 ++++--
 drivers/dax/device.c                             |    3 ++-
 drivers/dma-buf/dma-buf.c                        |    4 +++-
 drivers/firewire/core-cdev.c                     |    3 ++-
 drivers/gpu/drm/amd/amdkfd/kfd_chardev.c         |    5 +++--
 drivers/gpu/drm/arc/arcpgu_drv.c                 |    5 +++--
 drivers/gpu/drm/ast/ast_drv.h                    |    3 ++-
 drivers/gpu/drm/ast/ast_ttm.c                    |    3 ++-
 drivers/gpu/drm/drm_gem.c                        |    3 ++-
 drivers/gpu/drm/drm_gem_cma_helper.c             |    2 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c            |    2 +-
 drivers/gpu/drm/exynos/exynos_drm_gem.c          |    2 +-
 drivers/gpu/drm/i810/i810_dma.c                  |    3 ++-
 drivers/gpu/drm/i915/i915_gem_dmabuf.c           |    2 +-
 drivers/gpu/drm/mediatek/mtk_drm_gem.c           |    2 +-
 drivers/gpu/drm/mgag200/mgag200_drv.h            |    3 ++-
 drivers/gpu/drm/mgag200/mgag200_ttm.c            |    3 ++-
 drivers/gpu/drm/msm/msm_gem.c                    |    2 +-
 drivers/gpu/drm/omapdrm/omap_gem.c               |    2 +-
 drivers/gpu/drm/radeon/radeon_drv.c              |    3 ++-
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c      |    2 +-
 drivers/gpu/drm/tegra/gem.c                      |    2 +-
 drivers/gpu/drm/udl/udl_gem.c                    |    2 +-
 drivers/gpu/drm/vc4/vc4_bo.c                     |    2 +-
 drivers/gpu/drm/vgem/vgem_drv.c                  |    7 ++++---
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h              |    3 ++-
 drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c         |    3 ++-
 drivers/hsi/clients/cmt_speech.c                 |    3 ++-
 drivers/hwtracing/intel_th/msu.c                 |    3 ++-
 drivers/hwtracing/stm/core.c                     |    3 ++-
 drivers/infiniband/core/uverbs_main.c            |    3 ++-
 drivers/infiniband/hw/hfi1/file_ops.c            |    6 ++++--
 drivers/infiniband/hw/qib/qib_file_ops.c         |    5 +++--
 drivers/media/v4l2-core/v4l2-dev.c               |    3 ++-
 drivers/misc/aspeed-lpc-ctrl.c                   |    3 ++-
 drivers/misc/cxl/file.c                          |    3 ++-
 drivers/misc/genwqe/card_dev.c                   |    3 ++-
 drivers/misc/mic/scif/scif_fd.c                  |    3 ++-
 drivers/misc/mic/vop/vop_vringh.c                |    3 ++-
 drivers/misc/sgi-gru/grufile.c                   |    3 ++-
 drivers/mtd/mtdchar.c                            |    3 ++-
 drivers/pci/proc.c                               |    3 ++-
 drivers/rapidio/devices/rio_mport_cdev.c         |    3 ++-
 drivers/sbus/char/flash.c                        |    3 ++-
 drivers/sbus/char/jsflash.c                      |    3 ++-
 drivers/scsi/cxlflash/superpipe.c                |    3 ++-
 drivers/scsi/sg.c                                |    3 ++-
 drivers/staging/android/ashmem.c                 |    3 ++-
 drivers/staging/comedi/comedi_fops.c             |    3 ++-
 drivers/staging/lustre/lustre/llite/llite_mmap.c |    2 +-
 drivers/staging/vme/devices/vme_user.c           |    3 ++-
 drivers/uio/uio.c                                |    3 ++-
 drivers/usb/core/devio.c                         |    3 ++-
 drivers/usb/mon/mon_bin.c                        |    3 ++-
 drivers/vfio/vfio.c                              |    7 +++++--
 drivers/video/fbdev/core/fbmem.c                 |    3 ++-
 drivers/video/fbdev/pxa3xx-gcu.c                 |    3 ++-
 drivers/xen/gntalloc.c                           |    3 ++-
 drivers/xen/gntdev.c                             |    3 ++-
 drivers/xen/privcmd.c                            |    3 ++-
 drivers/xen/xenbus/xenbus_dev_backend.c          |    3 ++-
 drivers/xen/xenfs/xenstored.c                    |    3 ++-
 fs/9p/vfs_file.c                                 |   10 ++++++----
 fs/aio.c                                         |    3 ++-
 fs/btrfs/file.c                                  |    3 ++-
 fs/cifs/file.c                                   |    4 ++--
 fs/coda/file.c                                   |    5 +++--
 fs/ecryptfs/file.c                               |    5 +++--
 fs/ext2/file.c                                   |    5 +++--
 fs/ext4/file.c                                   |    3 ++-
 fs/f2fs/file.c                                   |    3 ++-
 fs/fuse/file.c                                   |    8 +++++---
 fs/gfs2/file.c                                   |    3 ++-
 fs/hugetlbfs/inode.c                             |    3 ++-
 fs/kernfs/file.c                                 |    3 ++-
 fs/nfs/file.c                                    |    5 +++--
 fs/nfs/internal.h                                |    2 +-
 fs/nilfs2/file.c                                 |    3 ++-
 fs/orangefs/file.c                               |    5 +++--
 fs/proc/inode.c                                  |    7 ++++---
 fs/proc/vmcore.c                                 |    6 ++++--
 fs/ramfs/file-nommu.c                            |    6 ++++--
 fs/romfs/mmap-nommu.c                            |    3 ++-
 fs/ubifs/file.c                                  |    5 +++--
 fs/xfs/xfs_file.c                                |    5 ++---
 include/drm/drm_gem.h                            |    3 ++-
 include/linux/fs.h                               |   13 ++++++++-----
 ipc/shm.c                                        |    5 +++--
 kernel/events/core.c                             |    3 ++-
 kernel/kcov.c                                    |    3 ++-
 kernel/relay.c                                   |    3 ++-
 mm/filemap.c                                     |   14 +++++++++-----
 mm/mmap.c                                        |    2 +-
 mm/nommu.c                                       |    4 ++--
 mm/shmem.c                                       |    3 ++-
 net/socket.c                                     |    6 ++++--
 security/selinux/selinuxfs.c                     |    6 ++++--
 sound/core/compress_offload.c                    |    3 ++-
 sound/core/hwdep.c                               |    3 ++-
 sound/core/info.c                                |    3 ++-
 sound/core/init.c                                |    3 ++-
 sound/core/oss/pcm_oss.c                         |    3 ++-
 sound/oss/soundcard.c                            |    3 ++-
 sound/oss/swarm_cs4297a.c                        |    3 ++-
 virt/kvm/kvm_main.c                              |    3 ++-
 118 files changed, 295 insertions(+), 168 deletions(-)

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
index bc28e7575254..f432d76b6cf8 100644
--- a/drivers/gpu/drm/drm_gem_cma_helper.c
+++ b/drivers/gpu/drm/drm_gem_cma_helper.c
@@ -350,7 +350,7 @@ int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma)
 	struct drm_gem_object *gem_obj;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 9a3bea738330..e612ff948cde 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -167,7 +167,7 @@ int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 	struct etnaviv_gem_object *obj;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret) {
 		DBG("mmap failed: %d", ret);
 		return ret;
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index c23479be4850..73359382f218 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -517,7 +517,7 @@ int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 	int ret;
 
 	/* set vm_area_struct. */
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret < 0) {
 		DRM_ERROR("failed to mmap.\n");
 		return ret;
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
index 7abc550ebc00..77667f2ef4e3 100644
--- a/drivers/gpu/drm/mediatek/mtk_drm_gem.c
+++ b/drivers/gpu/drm/mediatek/mtk_drm_gem.c
@@ -195,7 +195,7 @@ int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 	struct drm_gem_object *obj;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
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
diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
index 65f35544c1ec..5ff750e28a95 100644
--- a/drivers/gpu/drm/msm/msm_gem.c
+++ b/drivers/gpu/drm/msm/msm_gem.c
@@ -202,7 +202,7 @@ int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 {
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret) {
 		DBG("mmap failed: %d", ret);
 		return ret;
diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
index 5c5c86ddd6f4..a975b186668f 100644
--- a/drivers/gpu/drm/omapdrm/omap_gem.c
+++ b/drivers/gpu/drm/omapdrm/omap_gem.c
@@ -565,7 +565,7 @@ int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 {
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret) {
 		DBG("mmap failed: %d", ret);
 		return ret;
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
diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
index b74ac717e56a..aae52d73ebee 100644
--- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
+++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
@@ -293,7 +293,7 @@ int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 	struct drm_gem_object *obj;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/tegra/gem.c b/drivers/gpu/drm/tegra/gem.c
index 7a39a355678a..143880e16273 100644
--- a/drivers/gpu/drm/tegra/gem.c
+++ b/drivers/gpu/drm/tegra/gem.c
@@ -487,7 +487,7 @@ int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma)
 	struct tegra_bo *bo;
 	int ret;
 
-	ret = drm_gem_mmap(file, vma);
+	ret = drm_gem_mmap(file, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/udl/udl_gem.c b/drivers/gpu/drm/udl/udl_gem.c
index db9ceceba30e..07a3511ae3ef 100644
--- a/drivers/gpu/drm/udl/udl_gem.c
+++ b/drivers/gpu/drm/udl/udl_gem.c
@@ -88,7 +88,7 @@ int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 {
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
diff --git a/drivers/gpu/drm/vc4/vc4_bo.c b/drivers/gpu/drm/vc4/vc4_bo.c
index 487f96412d35..38b365db5f89 100644
--- a/drivers/gpu/drm/vc4/vc4_bo.c
+++ b/drivers/gpu/drm/vc4/vc4_bo.c
@@ -402,7 +402,7 @@ int vc4_mmap(struct file *filp, struct vm_area_struct *vma)
 	struct vc4_bo *bo;
 	int ret;
 
-	ret = drm_gem_mmap(filp, vma);
+	ret = drm_gem_mmap(filp, vma, 0);
 	if (ret)
 		return ret;
 
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
index 3d2609608f58..49899bc31b39 100644
--- a/drivers/infiniband/core/uverbs_main.c
+++ b/drivers/infiniband/core/uverbs_main.c
@@ -808,7 +808,8 @@ static ssize_t ib_uverbs_write(struct file *filp, const char __user *buf,
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
index 216f923161d1..b3dbbc195753 100644
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
index ad0f9968ccfb..90886c3e9424 100644
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
diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
index 1e82d4128a84..5006c7010e19 100644
--- a/drivers/scsi/sg.c
+++ b/drivers/scsi/sg.c
@@ -1253,7 +1253,8 @@ static const struct vm_operations_struct sg_mmap_vm_ops = {
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
index ca11be21f64b..2fbd860f74e4 100644
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
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index ccc7ae15a943..51a804d3e6fb 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -464,7 +464,7 @@ int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
 		return -EOPNOTSUPP;
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_MAP, 1);
-	rc = generic_file_mmap(file, vma);
+	rc = generic_file_mmap(file, vma, 0);
 	if (rc == 0) {
 		vma->vm_ops = &ll_file_vm_ops;
 		vma->vm_ops->open(vma);
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
 
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index bc09df6b473a..9e4738511d20 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3488,7 +3488,7 @@ int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
 			return rc;
 	}
 
-	rc = generic_file_mmap(file, vma);
+	rc = generic_file_mmap(file, vma, 0);
 	if (rc == 0)
 		vma->vm_ops = &cifs_file_vm_ops;
 	free_xid(xid);
@@ -3507,7 +3507,7 @@ int cifs_file_mmap(struct file *file, struct vm_area_struct *vma)
 		free_xid(xid);
 		return rc;
 	}
-	rc = generic_file_mmap(file, vma);
+	rc = generic_file_mmap(file, vma, 0);
 	if (rc == 0)
 		vma->vm_ops = &cifs_file_vm_ops;
 	free_xid(xid);
diff --git a/fs/coda/file.c b/fs/coda/file.c
index 363402fcb3ed..80076b07c32a 100644
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
+	return call_mmap(host_file, vma, 0);
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
index 58294c9a7e1d..a78537c80ed0 100644
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
index 3ee4fdc3da9e..d095b4992293 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2062,7 +2062,8 @@ static const struct vm_operations_struct fuse_file_vm_ops = {
 	.page_mkwrite	= fuse_page_mkwrite,
 };
 
-static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
+static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma,
+			  unsigned long map_flags)
 {
 	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE))
 		fuse_link_write_file(file);
@@ -2072,7 +2073,8 @@ static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
 	return 0;
 }
 
-static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma)
+static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma,
+			    unsigned long map_flags)
 {
 	/* Can't provide the coherency needed for MAP_SHARED */
 	if (vma->vm_flags & VM_MAYSHARE)
@@ -2080,7 +2082,7 @@ static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma)
 
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
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5713eb32a45e..afa6b89e864f 100644
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
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6e1fd5d21248..4c6d0d9db8e3 100644
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
+	return file->f_op->mmap(file, vma, 0);
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
diff --git a/ipc/shm.c b/ipc/shm.c
index 28a444861a8f..89d2e92971f5 100644
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
+	ret = call_mmap(sfd->file, vma, 0);
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
index b0aa6075d164..f3f9509c7486 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2122,7 +2122,8 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 	return retval;
 }
 
-static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
+static int shmem_mmap(struct file *file, struct vm_area_struct *vma,
+		      unsigned long map_flags)
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
diff --git a/net/socket.c b/net/socket.c
index bf2122691fba..7708f87f1ab6 100644
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
index 82987d457b8b..1b95e925e8e2 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -2398,7 +2398,8 @@ static const struct vm_operations_struct kvm_vcpu_vm_ops = {
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
