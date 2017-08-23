Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA8F02803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 19:55:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a186so20187727pge.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:55:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 5si1760169pff.564.2017.08.23.16.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 16:54:59 -0700 (PDT)
Subject: [PATCH v6 0/5] MAP_DIRECT and block-map-atomic files
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Aug 2017 16:48:34 -0700
Message-ID: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Airlie <airlied@linux.ie>, linux-api@vger.kernel.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, Takashi Iwai <tiwai@suse.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Daniel Vetter <daniel.vetter@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Changes since v5 [1]:
* Compile fixes from a much improved coccinelle semantic patch (thanks
  Julia!) that adds a 'flags' argument to all the ->mmap()
  implementations in the kernel. (0day-kbuild-robot)

* Make the deprecated MAP_DENYWRITE and MAP_EXECUTABLE flags return
  EOPNOTSUPP with the new mmap3() syscall. (Kirill)

* Minor changelog updates.

* Updated cover letter with a clarified summary and checklist of
  questions to answer before proceeding further.

---

MAP_DIRECT is a mechanism to ask the kernel to atomically manage the
file-offset to physical-address block relationship of a mapping relative
to any memory-mapped access. It is complimentary to the proposed
MAP_SYNC mechanism which makes the same guarantee relative to cpu
faults. MAP_DIRECT goes a step further and makes this guarantee for
agents that may not generate mmu faults, but at the cost of restricting
the kernel's ability to mutate the block-map at will.

MAP_SYNC is preferred for scenarios that want full filesystem feature
support while avoiding fsync/msync overhead, but also do not need to
contend with hypervisors or RDMA agents that do not give the kernel an
mmu fault. In other words, the need for MAP_DIRECT is driven by the
scarcity of SVM capable hardware (Shared Virtual Memory, where hardware
generates mmu faults), hypervisors like Xen that need to interrogate the
physical address layout of a file to maintain their own physical-address
mapping metadata outside the kernel, and peer-to-peer DMA use cases that
always bypass the mmu.

The MAP_DIRECT mechanism allows a filesystem to be used for capacity
provisioning and access control where these aforementioned applications
would otherwise be forced to roll a custom solution on top of a raw
device-file.

Questions:
1/ Is the definition of MAP_DIRECT constrained enough to allow us to
   make the restrictions it imposes on the kernel finer grained over time?

2/ Do the XFS changes look sane? They attempt to avoid adding any
   overhead to the non-MAP_DIRECT case at the expense of the new
   i_mapdcount atomic counter in the XFS inode.

3/ While the generic MAP_DIRECT description warns that the block-map may
   not be actually be immutable for the lifetime of the mapping it also
   does not preclude a filesystem from making that guarantee. In fact,
   Dave wants to be able to get a stable view of the physical mapping
   [2], and Xen has a need to do the same [3]. Do we want userspace to
   start making "XFS + MAP_DIRECT == Immutable" assumptions, or do we
   need a separate mechanism for that guarantee?

[1]: https://lkml.org/lkml/2017/8/16/114
[2]: https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1467677.html
[3]: https://lists.xen.org/archives/html/xen-devel/2017-04/msg00419.html

---

Dan Williams (5):
      vfs: add flags parameter to ->mmap() in 'struct file_operations'
      fs, xfs: introduce S_IOMAP_SEALED
      mm: introduce mmap3 for safely defining new mmap flags
      fs, xfs: introduce MAP_DIRECT for creating block-map-atomic file ranges
      fs, fcntl: add F_MAP_DIRECT


 arch/arc/kernel/arc_hostlink.c                     |    3 -
 arch/mips/kernel/vdso.c                            |    2 
 arch/powerpc/kernel/proc_powerpc.c                 |    3 -
 arch/powerpc/kvm/book3s_64_vio.c                   |    3 -
 arch/powerpc/platforms/cell/spufs/file.c           |   21 ++--
 arch/powerpc/platforms/powernv/opal-prd.c          |    3 -
 arch/um/drivers/mmapper_kern.c                     |    3 -
 arch/x86/entry/syscalls/syscall_32.tbl             |    1 
 arch/x86/entry/syscalls/syscall_64.tbl             |    1 
 drivers/android/binder.c                           |    3 -
 drivers/char/agp/frontend.c                        |    3 -
 drivers/char/bsr.c                                 |    3 -
 drivers/char/hpet.c                                |    6 +
 drivers/char/mbcs.c                                |    3 -
 drivers/char/mbcs.h                                |    3 -
 drivers/char/mem.c                                 |   11 +-
 drivers/char/mspec.c                               |    9 +-
 drivers/char/uv_mmtimer.c                          |    6 +
 drivers/dax/device.c                               |    3 -
 drivers/dma-buf/dma-buf.c                          |    4 +
 drivers/firewire/core-cdev.c                       |    3 -
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |    3 -
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h            |    3 -
 drivers/gpu/drm/amd/amdkfd/kfd_chardev.c           |    5 +
 drivers/gpu/drm/arc/arcpgu_drv.c                   |    5 +
 drivers/gpu/drm/ast/ast_drv.h                      |    3 -
 drivers/gpu/drm/ast/ast_ttm.c                      |    3 -
 drivers/gpu/drm/bochs/bochs.h                      |    3 -
 drivers/gpu/drm/bochs/bochs_mm.c                   |    3 -
 drivers/gpu/drm/cirrus/cirrus_drv.h                |    3 -
 drivers/gpu/drm/cirrus/cirrus_ttm.c                |    3 -
 drivers/gpu/drm/drm_gem.c                          |    3 -
 drivers/gpu/drm/drm_gem_cma_helper.c               |    6 +
 drivers/gpu/drm/drm_vm.c                           |    3 -
 drivers/gpu/drm/etnaviv/etnaviv_drv.h              |    3 -
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |    5 +
 drivers/gpu/drm/exynos/exynos_drm_gem.c            |    5 +
 drivers/gpu/drm/exynos/exynos_drm_gem.h            |    3 -
 drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h    |    3 -
 drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c        |    3 -
 drivers/gpu/drm/i810/i810_dma.c                    |    3 -
 drivers/gpu/drm/i915/i915_gem_dmabuf.c             |    2 
 drivers/gpu/drm/mediatek/mtk_drm_gem.c             |    5 +
 drivers/gpu/drm/mediatek/mtk_drm_gem.h             |    3 -
 drivers/gpu/drm/mgag200/mgag200_drv.h              |    3 -
 drivers/gpu/drm/mgag200/mgag200_ttm.c              |    3 -
 drivers/gpu/drm/msm/msm_drv.h                      |    3 -
 drivers/gpu/drm/msm/msm_gem.c                      |    5 +
 drivers/gpu/drm/nouveau/nouveau_ttm.c              |    5 +
 drivers/gpu/drm/nouveau/nouveau_ttm.h              |    2 
 drivers/gpu/drm/omapdrm/omap_drv.h                 |    3 -
 drivers/gpu/drm/omapdrm/omap_gem.c                 |    5 +
 drivers/gpu/drm/qxl/qxl_drv.h                      |    3 -
 drivers/gpu/drm/qxl/qxl_ttm.c                      |    3 -
 drivers/gpu/drm/radeon/radeon_drv.c                |    3 -
 drivers/gpu/drm/radeon/radeon_ttm.c                |    3 -
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c        |    5 +
 drivers/gpu/drm/rockchip/rockchip_drm_gem.h        |    3 -
 drivers/gpu/drm/tegra/gem.c                        |    5 +
 drivers/gpu/drm/tegra/gem.h                        |    3 -
 drivers/gpu/drm/udl/udl_drv.h                      |    3 -
 drivers/gpu/drm/udl/udl_gem.c                      |    5 +
 drivers/gpu/drm/vc4/vc4_bo.c                       |    5 +
 drivers/gpu/drm/vc4/vc4_drv.h                      |    3 -
 drivers/gpu/drm/vgem/vgem_drv.c                    |    7 +
 drivers/gpu/drm/virtio/virtgpu_drv.h               |    3 -
 drivers/gpu/drm/virtio/virtgpu_ttm.c               |    3 -
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h                |    3 -
 drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c           |    3 -
 drivers/hsi/clients/cmt_speech.c                   |    3 -
 drivers/hwtracing/intel_th/msu.c                   |    3 -
 drivers/hwtracing/stm/core.c                       |    3 -
 drivers/infiniband/core/uverbs_main.c              |    3 -
 drivers/infiniband/hw/hfi1/file_ops.c              |    6 +
 drivers/infiniband/hw/qib/qib_file_ops.c           |    5 +
 drivers/media/v4l2-core/v4l2-dev.c                 |    3 -
 drivers/misc/aspeed-lpc-ctrl.c                     |    3 -
 drivers/misc/cxl/api.c                             |    5 +
 drivers/misc/cxl/cxl.h                             |    3 -
 drivers/misc/cxl/file.c                            |    3 -
 drivers/misc/genwqe/card_dev.c                     |    3 -
 drivers/misc/mic/scif/scif_fd.c                    |    3 -
 drivers/misc/mic/vop/vop_vringh.c                  |    3 -
 drivers/misc/sgi-gru/grufile.c                     |    3 -
 drivers/mtd/mtdchar.c                              |    3 -
 drivers/pci/proc.c                                 |    3 -
 drivers/rapidio/devices/rio_mport_cdev.c           |    3 -
 drivers/sbus/char/flash.c                          |    3 -
 drivers/sbus/char/jsflash.c                        |    3 -
 drivers/scsi/cxlflash/superpipe.c                  |    5 +
 drivers/scsi/sg.c                                  |    3 -
 drivers/staging/android/ashmem.c                   |    3 -
 drivers/staging/comedi/comedi_fops.c               |    3 -
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 -
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    5 +
 drivers/staging/vboxvideo/vbox_drv.h               |    3 -
 drivers/staging/vboxvideo/vbox_ttm.c               |    3 -
 drivers/staging/vme/devices/vme_user.c             |    3 -
 drivers/uio/uio.c                                  |    3 -
 drivers/usb/core/devio.c                           |    3 -
 drivers/usb/mon/mon_bin.c                          |    3 -
 drivers/vfio/vfio.c                                |    7 +
 drivers/video/fbdev/core/fbmem.c                   |    3 -
 drivers/video/fbdev/pxa3xx-gcu.c                   |    3 -
 drivers/xen/gntalloc.c                             |    3 -
 drivers/xen/gntdev.c                               |    3 -
 drivers/xen/privcmd.c                              |    3 -
 drivers/xen/xenbus/xenbus_dev_backend.c            |    3 -
 drivers/xen/xenfs/xenstored.c                      |    3 -
 fs/9p/vfs_file.c                                   |   10 +-
 fs/aio.c                                           |    3 -
 fs/attr.c                                          |   10 ++
 fs/btrfs/file.c                                    |    3 -
 fs/ceph/addr.c                                     |    3 -
 fs/ceph/super.h                                    |    3 -
 fs/cifs/cifsfs.h                                   |    6 +
 fs/cifs/file.c                                     |   10 +-
 fs/coda/file.c                                     |    5 +
 fs/ecryptfs/file.c                                 |    5 +
 fs/ext2/file.c                                     |    5 +
 fs/ext4/file.c                                     |    3 -
 fs/f2fs/file.c                                     |    3 -
 fs/fcntl.c                                         |   15 +++
 fs/fuse/file.c                                     |    8 +
 fs/gfs2/file.c                                     |    3 -
 fs/hugetlbfs/inode.c                               |    3 -
 fs/kernfs/file.c                                   |    3 -
 fs/ncpfs/mmap.c                                    |    3 -
 fs/ncpfs/ncp_fs.h                                  |    2 
 fs/nfs/file.c                                      |    5 +
 fs/nfs/internal.h                                  |    2 
 fs/nilfs2/file.c                                   |    3 -
 fs/ocfs2/mmap.c                                    |    3 -
 fs/ocfs2/mmap.h                                    |    3 -
 fs/open.c                                          |    6 +
 fs/orangefs/file.c                                 |    5 +
 fs/proc/inode.c                                    |    7 +
 fs/proc/vmcore.c                                   |    6 +
 fs/ramfs/file-nommu.c                              |    6 +
 fs/read_write.c                                    |    3 +
 fs/romfs/mmap-nommu.c                              |    3 -
 fs/ubifs/file.c                                    |    5 +
 fs/xfs/libxfs/xfs_bmap.c                           |    5 +
 fs/xfs/xfs_bmap_util.c                             |    3 +
 fs/xfs/xfs_file.c                                  |  114 +++++++++++++++++++-
 fs/xfs/xfs_inode.h                                 |    1 
 fs/xfs/xfs_ioctl.c                                 |    6 +
 fs/xfs/xfs_super.c                                 |    1 
 include/drm/drm_gem.h                              |    3 -
 include/drm/drm_gem_cma_helper.h                   |    3 -
 include/drm/drm_legacy.h                           |    3 -
 include/linux/fs.h                                 |   21 ++--
 include/linux/mm.h                                 |    2 
 include/linux/mman.h                               |   46 ++++++++
 include/linux/syscalls.h                           |    3 +
 include/misc/cxl.h                                 |    3 -
 include/uapi/asm-generic/mman.h                    |    1 
 include/uapi/linux/fcntl.h                         |    5 +
 ipc/shm.c                                          |    5 +
 kernel/events/core.c                               |    3 -
 kernel/kcov.c                                      |    3 -
 kernel/relay.c                                     |    3 -
 mm/filemap.c                                       |   19 ++-
 mm/mmap.c                                          |   56 +++++++++-
 mm/nommu.c                                         |    4 -
 mm/shmem.c                                         |    3 -
 net/socket.c                                       |    6 +
 security/selinux/selinuxfs.c                       |    6 +
 sound/core/compress_offload.c                      |    3 -
 sound/core/hwdep.c                                 |    3 -
 sound/core/info.c                                  |    3 -
 sound/core/init.c                                  |    3 -
 sound/core/oss/pcm_oss.c                           |    3 -
 sound/core/pcm_native.c                            |    3 -
 sound/oss/soundcard.c                              |    3 -
 sound/oss/swarm_cs4297a.c                          |    3 -
 virt/kvm/kvm_main.c                                |    3 -
 177 files changed, 689 insertions(+), 234 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
