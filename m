Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 169536B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 19:14:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a2so13734158pfj.2
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:14:42 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m12si5468917pln.230.2017.08.30.16.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 16:14:39 -0700 (PDT)
Subject: [PATCH 0/2] MAP_VALIDATE and mmap flags validation
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Aug 2017 16:08:15 -0700
Message-ID: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: jack@suse.cz, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, David Airlie <airlied@linux.ie>, linux-api@vger.kernel.org, Takashi Iwai <tiwai@suse.com>, dri-devel@lists.freedesktop.org, Julia Lawall <julia.lawall@lip6.fr>, luto@kernel.org, Daniel Vetter <daniel.vetter@intel.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, hch@lst.de

As noted in patch2:

    The mmap(2) syscall suffers from the ABI anti-pattern of not validating
    unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
    mechanism to define new behavior that is known to fail on older kernels
    without the support. Define a new MAP_VALIDATE flag pattern that is
    guaranteed to fail on all legacy mmap implementations.

On the assumption that it is too late to finalize either MAP_SYNC or
MAP_DIRECT for 4.14 inclusion I would still like to pursue getting at
least patch1 in for 4.14. This allows development of these new flags for
4.15 without worrying about new ->mmap() operation instances added
during the cycle. I.e. I would rebase these from v4.13-rc5 to the state
of the tree right before v4.14-rc1 and re-run the Coccinelle script.

Questions:

1/ Are there any objections to MAP_VALIDATE? I think we bottomed out on
   the parisc compatibility concern with the realization that it is
   missing fundamental pmem pre-requisite features, like ZONE_DEVICE,
   and can otherwise define a new mmap syscall variant.

2/ Linus, are you open to taking a rebased version of patch1 late in the
   4.14 window, or have a different suggestion?

---

Dan Williams (2):
      vfs: add flags parameter to ->mmap() in 'struct file_operations'
      mm: introduce MAP_VALIDATE, a mechanism for for safely defining new mmap flags


 arch/arc/kernel/arc_hostlink.c                     |    3 +
 arch/mips/kernel/vdso.c                            |    2 -
 arch/powerpc/kernel/proc_powerpc.c                 |    3 +
 arch/powerpc/kvm/book3s_64_vio.c                   |    3 +
 arch/powerpc/platforms/cell/spufs/file.c           |   21 ++++++--
 arch/powerpc/platforms/powernv/opal-prd.c          |    3 +
 arch/um/drivers/mmapper_kern.c                     |    3 +
 drivers/android/binder.c                           |    3 +
 drivers/char/agp/frontend.c                        |    3 +
 drivers/char/bsr.c                                 |    3 +
 drivers/char/hpet.c                                |    6 ++
 drivers/char/mbcs.c                                |    3 +
 drivers/char/mbcs.h                                |    3 +
 drivers/char/mem.c                                 |   11 +++-
 drivers/char/mspec.c                               |    9 ++--
 drivers/char/uv_mmtimer.c                          |    6 ++
 drivers/dax/device.c                               |    3 +
 drivers/dma-buf/dma-buf.c                          |    4 +-
 drivers/firewire/core-cdev.c                       |    3 +
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |    3 +
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h            |    3 +
 drivers/gpu/drm/amd/amdkfd/kfd_chardev.c           |    5 +-
 drivers/gpu/drm/arc/arcpgu_drv.c                   |    5 +-
 drivers/gpu/drm/ast/ast_drv.h                      |    3 +
 drivers/gpu/drm/ast/ast_ttm.c                      |    3 +
 drivers/gpu/drm/bochs/bochs.h                      |    3 +
 drivers/gpu/drm/bochs/bochs_mm.c                   |    3 +
 drivers/gpu/drm/cirrus/cirrus_drv.h                |    3 +
 drivers/gpu/drm/cirrus/cirrus_ttm.c                |    3 +
 drivers/gpu/drm/drm_gem.c                          |    3 +
 drivers/gpu/drm/drm_gem_cma_helper.c               |    6 ++
 drivers/gpu/drm/drm_vm.c                           |    3 +
 drivers/gpu/drm/etnaviv/etnaviv_drv.h              |    3 +
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |    5 +-
 drivers/gpu/drm/exynos/exynos_drm_gem.c            |    5 +-
 drivers/gpu/drm/exynos/exynos_drm_gem.h            |    3 +
 drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h    |    3 +
 drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c        |    3 +
 drivers/gpu/drm/i810/i810_dma.c                    |    3 +
 drivers/gpu/drm/i915/i915_gem_dmabuf.c             |    2 -
 drivers/gpu/drm/mediatek/mtk_drm_gem.c             |    5 +-
 drivers/gpu/drm/mediatek/mtk_drm_gem.h             |    3 +
 drivers/gpu/drm/mgag200/mgag200_drv.h              |    3 +
 drivers/gpu/drm/mgag200/mgag200_ttm.c              |    3 +
 drivers/gpu/drm/msm/msm_drv.h                      |    3 +
 drivers/gpu/drm/msm/msm_gem.c                      |    5 +-
 drivers/gpu/drm/nouveau/nouveau_ttm.c              |    5 +-
 drivers/gpu/drm/nouveau/nouveau_ttm.h              |    2 -
 drivers/gpu/drm/omapdrm/omap_drv.h                 |    3 +
 drivers/gpu/drm/omapdrm/omap_gem.c                 |    5 +-
 drivers/gpu/drm/qxl/qxl_drv.h                      |    3 +
 drivers/gpu/drm/qxl/qxl_ttm.c                      |    3 +
 drivers/gpu/drm/radeon/radeon_drv.c                |    3 +
 drivers/gpu/drm/radeon/radeon_ttm.c                |    3 +
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c        |    5 +-
 drivers/gpu/drm/rockchip/rockchip_drm_gem.h        |    3 +
 drivers/gpu/drm/tegra/gem.c                        |    5 +-
 drivers/gpu/drm/tegra/gem.h                        |    3 +
 drivers/gpu/drm/udl/udl_drv.h                      |    3 +
 drivers/gpu/drm/udl/udl_gem.c                      |    5 +-
 drivers/gpu/drm/vc4/vc4_bo.c                       |    5 +-
 drivers/gpu/drm/vc4/vc4_drv.h                      |    3 +
 drivers/gpu/drm/vgem/vgem_drv.c                    |    7 ++-
 drivers/gpu/drm/virtio/virtgpu_drv.h               |    3 +
 drivers/gpu/drm/virtio/virtgpu_ttm.c               |    3 +
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h                |    3 +
 drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c           |    3 +
 drivers/hsi/clients/cmt_speech.c                   |    3 +
 drivers/hwtracing/intel_th/msu.c                   |    3 +
 drivers/hwtracing/stm/core.c                       |    3 +
 drivers/infiniband/core/uverbs_main.c              |    3 +
 drivers/infiniband/hw/hfi1/file_ops.c              |    6 ++
 drivers/infiniband/hw/qib/qib_file_ops.c           |    5 +-
 drivers/media/v4l2-core/v4l2-dev.c                 |    3 +
 drivers/misc/aspeed-lpc-ctrl.c                     |    3 +
 drivers/misc/cxl/api.c                             |    5 +-
 drivers/misc/cxl/cxl.h                             |    3 +
 drivers/misc/cxl/file.c                            |    3 +
 drivers/misc/genwqe/card_dev.c                     |    3 +
 drivers/misc/mic/scif/scif_fd.c                    |    3 +
 drivers/misc/mic/vop/vop_vringh.c                  |    3 +
 drivers/misc/sgi-gru/grufile.c                     |    3 +
 drivers/mtd/mtdchar.c                              |    3 +
 drivers/pci/proc.c                                 |    3 +
 drivers/rapidio/devices/rio_mport_cdev.c           |    3 +
 drivers/sbus/char/flash.c                          |    3 +
 drivers/sbus/char/jsflash.c                        |    3 +
 drivers/scsi/cxlflash/superpipe.c                  |    5 +-
 drivers/scsi/sg.c                                  |    3 +
 drivers/staging/android/ashmem.c                   |    3 +
 drivers/staging/comedi/comedi_fops.c               |    3 +
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 +
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    5 +-
 drivers/staging/vboxvideo/vbox_drv.h               |    3 +
 drivers/staging/vboxvideo/vbox_ttm.c               |    3 +
 drivers/staging/vme/devices/vme_user.c             |    3 +
 drivers/uio/uio.c                                  |    3 +
 drivers/usb/core/devio.c                           |    3 +
 drivers/usb/mon/mon_bin.c                          |    3 +
 drivers/vfio/vfio.c                                |    7 ++-
 drivers/video/fbdev/core/fbmem.c                   |    3 +
 drivers/video/fbdev/pxa3xx-gcu.c                   |    3 +
 drivers/xen/gntalloc.c                             |    3 +
 drivers/xen/gntdev.c                               |    3 +
 drivers/xen/privcmd.c                              |    3 +
 drivers/xen/xenbus/xenbus_dev_backend.c            |    3 +
 drivers/xen/xenfs/xenstored.c                      |    3 +
 fs/9p/vfs_file.c                                   |   10 ++--
 fs/aio.c                                           |    3 +
 fs/btrfs/file.c                                    |    3 +
 fs/ceph/addr.c                                     |    3 +
 fs/ceph/super.h                                    |    3 +
 fs/cifs/cifsfs.h                                   |    6 ++
 fs/cifs/file.c                                     |   10 ++--
 fs/coda/file.c                                     |    5 +-
 fs/ecryptfs/file.c                                 |    5 +-
 fs/ext2/file.c                                     |    5 +-
 fs/ext4/file.c                                     |    3 +
 fs/f2fs/file.c                                     |    3 +
 fs/fuse/file.c                                     |    8 ++-
 fs/gfs2/file.c                                     |    3 +
 fs/hugetlbfs/inode.c                               |    3 +
 fs/kernfs/file.c                                   |    3 +
 fs/ncpfs/mmap.c                                    |    3 +
 fs/ncpfs/ncp_fs.h                                  |    2 -
 fs/nfs/file.c                                      |    5 +-
 fs/nfs/internal.h                                  |    2 -
 fs/nilfs2/file.c                                   |    3 +
 fs/ocfs2/mmap.c                                    |    3 +
 fs/ocfs2/mmap.h                                    |    3 +
 fs/orangefs/file.c                                 |    5 +-
 fs/proc/inode.c                                    |    7 ++-
 fs/proc/vmcore.c                                   |    6 ++
 fs/ramfs/file-nommu.c                              |    6 ++
 fs/romfs/mmap-nommu.c                              |    3 +
 fs/ubifs/file.c                                    |    5 +-
 fs/xfs/xfs_file.c                                  |    5 +-
 include/drm/drm_gem.h                              |    3 +
 include/drm/drm_gem_cma_helper.h                   |    3 +
 include/drm/drm_legacy.h                           |    3 +
 include/linux/fs.h                                 |   14 ++++--
 include/linux/mm.h                                 |    2 -
 include/linux/mman.h                               |   50 ++++++++++++++++++++
 include/misc/cxl.h                                 |    3 +
 include/uapi/asm-generic/mman-common.h             |    1 
 ipc/shm.c                                          |    5 +-
 kernel/events/core.c                               |    3 +
 kernel/kcov.c                                      |    3 +
 kernel/relay.c                                     |    3 +
 mm/filemap.c                                       |   14 ++++--
 mm/mmap.c                                          |   22 ++++++++-
 mm/nommu.c                                         |    4 +-
 mm/shmem.c                                         |    3 +
 net/socket.c                                       |    6 ++
 security/selinux/selinuxfs.c                       |    6 ++
 sound/core/compress_offload.c                      |    3 +
 sound/core/hwdep.c                                 |    3 +
 sound/core/info.c                                  |    3 +
 sound/core/init.c                                  |    3 +
 sound/core/oss/pcm_oss.c                           |    3 +
 sound/core/pcm_native.c                            |    3 +
 sound/oss/soundcard.c                              |    3 +
 sound/oss/swarm_cs4297a.c                          |    3 +
 virt/kvm/kvm_main.c                                |    3 +
 164 files changed, 481 insertions(+), 231 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
