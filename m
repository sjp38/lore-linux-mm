Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B13EA6B04A0
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 15:41:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g13so6204513pfm.0
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 12:41:29 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o5si2057702pfh.318.2017.09.08.12.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 12:41:27 -0700 (PDT)
Subject: [RFC PATCH v8 0/2] mmap: safely enable support for new flags
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 08 Sep 2017 12:35:02 -0700
Message-ID: <150489930202.29460.5141541423730649272.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, David Airlie <airlied@linux.ie>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Takashi Iwai <tiwai@suse.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, Mauro Carvalho Chehab <mchehab@s-opensource.com>, Julia Lawall <julia.lawall@lip6.fr>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, linux-api@vger.kernel.org, Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de, linux-media@vger.kernel.org

Changes since v7 [1]:
* rebase on the mid-merge-window state of the tree to pick up new mmap
  implementations.

* expand the mmap operation handler conversion beyond 'struct
  file_operations' to include, 'struct etnaviv_gem_ops', 'struct
  dma_buf_ops', 'struct drm_driver', 'struct fb_ops', and 'struct
  v4l2_file_operations'

* pass 'map_flags' through to all sub-handlers (Christoph)

* rework the mmap flag validation mechanism to the MAP_SHARED_VALIDATE
  scheme (Linus)

[1]: https://lwn.net/Articles/732886/

---

In order to safely add new mmap flags we want all mmap implementations
to both opt-in to the new flags they support and have the ability to
reject flags on a per-mmap-call basis. An alternative to all the churn
in patch1 is to add a new ->map_flags attribute to 'struct
vma_area_struct', but that bloats the runtime state everywhere for the
few mmap implementations that will care about new flags. Of course, this
also assumes that there are no general objections to the plans to
eventually add MAP_SYNC and/or MAP_DIRECT for DAX mappings [2].

The current request is to merge the final version of patch1 next week,
right before -rc1, i.e. before new ->mmap() handlers start landing in
-next. Given that the drm, media, and sound pull requests are already
merged only some small tweaks are expected from here on out. Patch2 is
included for review, but it can wait and go in with the new MAP_ flags.

Please holler if anything does not look right.

[2]: "Two more approaches to persistent-memory writes"
     https://lwn.net/Articles/731706/

---

Dan Williams (2):
      vfs: add flags parameter to all ->mmap() handlers
      mm: introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap flags


 arch/alpha/include/uapi/asm/mman.h                 |    1 
 arch/arc/kernel/arc_hostlink.c                     |    3 +
 arch/mips/include/uapi/asm/mman.h                  |    1 
 arch/mips/kernel/vdso.c                            |    2 -
 arch/parisc/include/uapi/asm/mman.h                |    1 
 arch/powerpc/kernel/proc_powerpc.c                 |    3 +
 arch/powerpc/kvm/book3s_64_vio.c                   |    3 +
 arch/powerpc/platforms/cell/spufs/file.c           |   21 ++++++----
 arch/powerpc/platforms/powernv/memtrace.c          |    3 +
 arch/powerpc/platforms/powernv/opal-prd.c          |    3 +
 arch/tile/mm/elf.c                                 |    3 +
 arch/um/drivers/mmapper_kern.c                     |    3 +
 arch/xtensa/include/uapi/asm/mman.h                |    1 
 drivers/android/binder.c                           |    3 +
 drivers/auxdisplay/cfag12864bfb.c                  |    3 +
 drivers/auxdisplay/ht16k33.c                       |    3 +
 drivers/char/agp/frontend.c                        |    3 +
 drivers/char/bsr.c                                 |    3 +
 drivers/char/hpet.c                                |    6 ++-
 drivers/char/mbcs.c                                |    3 +
 drivers/char/mbcs.h                                |    3 +
 drivers/char/mem.c                                 |   11 +++--
 drivers/char/mspec.c                               |    9 +++-
 drivers/char/uv_mmtimer.c                          |    6 ++-
 drivers/dax/device.c                               |    3 +
 drivers/dma-buf/dma-buf.c                          |   11 +++--
 drivers/firewire/core-cdev.c                       |    3 +
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |    3 +
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h            |    3 +
 drivers/gpu/drm/amd/amdkfd/kfd_chardev.c           |    5 +-
 drivers/gpu/drm/armada/armada_gem.c                |    3 +
 drivers/gpu/drm/ast/ast_drv.h                      |    3 +
 drivers/gpu/drm/ast/ast_ttm.c                      |    3 +
 drivers/gpu/drm/bochs/bochs.h                      |    3 +
 drivers/gpu/drm/bochs/bochs_fbdev.c                |    2 -
 drivers/gpu/drm/bochs/bochs_mm.c                   |    3 +
 drivers/gpu/drm/cirrus/cirrus_drv.h                |    3 +
 drivers/gpu/drm/cirrus/cirrus_ttm.c                |    3 +
 drivers/gpu/drm/drm_fb_cma_helper.c                |    8 ++--
 drivers/gpu/drm/drm_gem.c                          |    3 +
 drivers/gpu/drm/drm_gem_cma_helper.c               |    8 ++--
 drivers/gpu/drm/drm_prime.c                        |    5 +-
 drivers/gpu/drm/drm_vm.c                           |    3 +
 drivers/gpu/drm/etnaviv/etnaviv_drv.h              |    6 ++-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c              |   11 +++--
 drivers/gpu/drm/etnaviv/etnaviv_gem.h              |    3 +
 drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c        |    9 ++--
 drivers/gpu/drm/exynos/exynos_drm_fbdev.c          |    2 -
 drivers/gpu/drm/exynos/exynos_drm_gem.c            |   10 +++--
 drivers/gpu/drm/exynos/exynos_drm_gem.h            |    6 ++-
 drivers/gpu/drm/gma500/framebuffer.c               |    3 +
 drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h    |    3 +
 drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c        |    3 +
 drivers/gpu/drm/i810/i810_dma.c                    |    3 +
 drivers/gpu/drm/i915/i915_gem_dmabuf.c             |    6 ++-
 drivers/gpu/drm/i915/selftests/mock_dmabuf.c       |    4 +-
 drivers/gpu/drm/mediatek/mtk_drm_gem.c             |    8 ++--
 drivers/gpu/drm/mediatek/mtk_drm_gem.h             |    5 +-
 drivers/gpu/drm/mgag200/mgag200_drv.h              |    3 +
 drivers/gpu/drm/mgag200/mgag200_ttm.c              |    3 +
 drivers/gpu/drm/msm/msm_drv.h                      |    6 ++-
 drivers/gpu/drm/msm/msm_fbdev.c                    |    6 ++-
 drivers/gpu/drm/msm/msm_gem.c                      |    5 +-
 drivers/gpu/drm/msm/msm_gem_prime.c                |    3 +
 drivers/gpu/drm/nouveau/nouveau_ttm.c              |    5 +-
 drivers/gpu/drm/nouveau/nouveau_ttm.h              |    2 -
 drivers/gpu/drm/omapdrm/omap_drv.h                 |    3 +
 drivers/gpu/drm/omapdrm/omap_gem.c                 |    5 +-
 drivers/gpu/drm/omapdrm/omap_gem_dmabuf.c          |    2 -
 drivers/gpu/drm/qxl/qxl_drv.h                      |    6 ++-
 drivers/gpu/drm/qxl/qxl_prime.c                    |    2 -
 drivers/gpu/drm/qxl/qxl_ttm.c                      |    3 +
 drivers/gpu/drm/radeon/radeon_drv.c                |    3 +
 drivers/gpu/drm/radeon/radeon_ttm.c                |    3 +
 drivers/gpu/drm/rockchip/rockchip_drm_fbdev.c      |    5 +-
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c        |    7 ++-
 drivers/gpu/drm/rockchip/rockchip_drm_gem.h        |    5 +-
 drivers/gpu/drm/tegra/gem.c                        |    9 +++-
 drivers/gpu/drm/tegra/gem.h                        |    3 +
 drivers/gpu/drm/udl/udl_dmabuf.c                   |    3 +
 drivers/gpu/drm/udl/udl_drv.h                      |    3 +
 drivers/gpu/drm/udl/udl_fb.c                       |    3 +
 drivers/gpu/drm/udl/udl_gem.c                      |    5 +-
 drivers/gpu/drm/vc4/vc4_bo.c                       |   10 +++--
 drivers/gpu/drm/vc4/vc4_drv.h                      |    6 ++-
 drivers/gpu/drm/vgem/vgem_drv.c                    |   10 +++--
 drivers/gpu/drm/virtio/virtgpu_drv.h               |    6 ++-
 drivers/gpu/drm/virtio/virtgpu_prime.c             |    2 -
 drivers/gpu/drm/virtio/virtgpu_ttm.c               |    3 +
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h                |    3 +
 drivers/gpu/drm/vmwgfx/vmwgfx_prime.c              |    3 +
 drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c           |    3 +
 drivers/hsi/clients/cmt_speech.c                   |    3 +
 drivers/hwtracing/intel_th/msu.c                   |    3 +
 drivers/hwtracing/stm/core.c                       |    3 +
 drivers/infiniband/core/uverbs_main.c              |    3 +
 drivers/infiniband/hw/hfi1/file_ops.c              |    6 ++-
 drivers/infiniband/hw/qib/qib_file_ops.c           |    5 +-
 drivers/media/common/saa7146/saa7146_fops.c        |    3 +
 drivers/media/pci/bt8xx/bttv-driver.c              |    3 +
 drivers/media/pci/cx18/cx18-fileops.c              |    3 +
 drivers/media/pci/cx18/cx18-fileops.h              |    3 +
 drivers/media/pci/meye/meye.c                      |    3 +
 drivers/media/pci/zoran/zoran_driver.c             |    2 -
 drivers/media/platform/davinci/vpfe_capture.c      |    3 +
 drivers/media/platform/exynos-gsc/gsc-m2m.c        |    3 +
 drivers/media/platform/fsl-viu.c                   |    3 +
 drivers/media/platform/m2m-deinterlace.c           |    3 +
 drivers/media/platform/mx2_emmaprp.c               |    3 +
 drivers/media/platform/omap/omap_vout.c            |    3 +
 drivers/media/platform/omap3isp/ispvideo.c         |    3 +
 drivers/media/platform/s3c-camif/camif-capture.c   |    3 +
 drivers/media/platform/s5p-mfc/s5p_mfc.c           |    3 +
 drivers/media/platform/sh_veu.c                    |    3 +
 drivers/media/platform/soc_camera/soc_camera.c     |    3 +
 drivers/media/platform/via-camera.c                |    3 +
 drivers/media/usb/cpia2/cpia2_v4l.c                |    3 +
 drivers/media/usb/cx231xx/cx231xx-417.c            |    3 +
 drivers/media/usb/cx231xx/cx231xx-video.c          |    3 +
 drivers/media/usb/gspca/gspca.c                    |    3 +
 drivers/media/usb/stkwebcam/stk-webcam.c           |    3 +
 drivers/media/usb/tm6000/tm6000-video.c            |    3 +
 drivers/media/usb/usbvision/usbvision-video.c      |    3 +
 drivers/media/usb/uvc/uvc_v4l2.c                   |    3 +
 drivers/media/usb/zr364xx/zr364xx.c                |    3 +
 drivers/media/v4l2-core/v4l2-dev.c                 |    5 +-
 drivers/media/v4l2-core/v4l2-mem2mem.c             |    3 +
 drivers/media/v4l2-core/videobuf2-dma-contig.c     |    2 -
 drivers/media/v4l2-core/videobuf2-dma-sg.c         |    2 -
 drivers/media/v4l2-core/videobuf2-v4l2.c           |    3 +
 drivers/media/v4l2-core/videobuf2-vmalloc.c        |    2 -
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
 drivers/staging/android/ion/ion.c                  |    3 +
 drivers/staging/comedi/comedi_fops.c               |    3 +
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 +
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    5 +-
 .../media/atomisp/pci/atomisp2/atomisp_fops.c      |    6 ++-
 drivers/staging/media/davinci_vpfe/vpfe_video.c    |    3 +
 drivers/staging/media/omap4iss/iss_video.c         |    3 +
 drivers/staging/vboxvideo/vbox_drv.h               |    5 +-
 drivers/staging/vboxvideo/vbox_prime.c             |    3 +
 drivers/staging/vboxvideo/vbox_ttm.c               |    3 +
 drivers/staging/vme/devices/vme_user.c             |    3 +
 drivers/tee/tee_shm.c                              |    3 +
 drivers/uio/uio.c                                  |    3 +
 drivers/usb/core/devio.c                           |    3 +
 drivers/usb/gadget/function/uvc_v4l2.c             |    3 +
 drivers/usb/mon/mon_bin.c                          |    3 +
 drivers/vfio/vfio.c                                |    7 ++-
 drivers/video/fbdev/68328fb.c                      |    6 ++-
 drivers/video/fbdev/amba-clcd.c                    |    2 -
 drivers/video/fbdev/aty/atyfb_base.c               |    6 ++-
 drivers/video/fbdev/au1100fb.c                     |    3 +
 drivers/video/fbdev/au1200fb.c                     |    3 +
 drivers/video/fbdev/bw2.c                          |    5 +-
 drivers/video/fbdev/cg14.c                         |    5 +-
 drivers/video/fbdev/cg3.c                          |    5 +-
 drivers/video/fbdev/cg6.c                          |    5 +-
 drivers/video/fbdev/controlfb.c                    |    4 +-
 drivers/video/fbdev/core/fb_defio.c                |    3 +
 drivers/video/fbdev/core/fbmem.c                   |    5 +-
 drivers/video/fbdev/ep93xx-fb.c                    |    3 +
 drivers/video/fbdev/fb-puv3.c                      |    2 -
 drivers/video/fbdev/ffb.c                          |    5 +-
 drivers/video/fbdev/gbefb.c                        |    2 -
 drivers/video/fbdev/igafb.c                        |    2 -
 drivers/video/fbdev/leo.c                          |    5 +-
 drivers/video/fbdev/omap/omapfb_main.c             |    3 +
 drivers/video/fbdev/omap2/omapfb/omapfb-main.c     |    3 +
 drivers/video/fbdev/p9100.c                        |    6 ++-
 drivers/video/fbdev/ps3fb.c                        |    3 +
 drivers/video/fbdev/pxa3xx-gcu.c                   |    3 +
 drivers/video/fbdev/sa1100fb.c                     |    2 -
 drivers/video/fbdev/sh_mobile_lcdcfb.c             |    6 ++-
 drivers/video/fbdev/smscufx.c                      |    3 +
 drivers/video/fbdev/tcx.c                          |    5 +-
 drivers/video/fbdev/udlfb.c                        |    3 +
 drivers/video/fbdev/vermilion/vermilion.c          |    3 +
 drivers/video/fbdev/vfb.c                          |    4 +-
 drivers/xen/gntalloc.c                             |    3 +
 drivers/xen/gntdev.c                               |    3 +
 drivers/xen/privcmd.c                              |    3 +
 drivers/xen/xenbus/xenbus_dev_backend.c            |    3 +
 drivers/xen/xenfs/xenstored.c                      |    3 +
 fs/9p/vfs_file.c                                   |   10 +++--
 fs/aio.c                                           |    3 +
 fs/btrfs/file.c                                    |    4 +-
 fs/ceph/addr.c                                     |    3 +
 fs/ceph/super.h                                    |    3 +
 fs/cifs/cifsfs.h                                   |    6 ++-
 fs/cifs/file.c                                     |   10 +++--
 fs/coda/file.c                                     |    5 +-
 fs/ecryptfs/file.c                                 |    5 +-
 fs/ext2/file.c                                     |    5 +-
 fs/ext4/file.c                                     |    3 +
 fs/f2fs/file.c                                     |    3 +
 fs/fuse/file.c                                     |    8 ++--
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
 fs/proc/vmcore.c                                   |    6 ++-
 fs/ramfs/file-nommu.c                              |    6 ++-
 fs/romfs/mmap-nommu.c                              |    3 +
 fs/ubifs/file.c                                    |    5 +-
 fs/xfs/xfs_file.c                                  |    2 -
 include/drm/drm_drv.h                              |    3 +
 include/drm/drm_gem.h                              |    3 +
 include/drm/drm_gem_cma_helper.h                   |    6 ++-
 include/drm/drm_legacy.h                           |    3 +
 include/linux/dma-buf.h                            |    5 +-
 include/linux/fb.h                                 |    6 ++-
 include/linux/fs.h                                 |   14 ++++--
 include/linux/mm.h                                 |    2 -
 include/linux/mman.h                               |   44 ++++++++++++++++++++
 include/media/v4l2-dev.h                           |    2 -
 include/media/v4l2-mem2mem.h                       |    3 +
 include/media/videobuf2-v4l2.h                     |    3 +
 include/misc/cxl.h                                 |    3 +
 include/uapi/asm-generic/mman-common.h             |    1 
 ipc/shm.c                                          |    5 +-
 kernel/events/core.c                               |    3 +
 kernel/kcov.c                                      |    3 +
 kernel/relay.c                                     |    3 +
 mm/filemap.c                                       |   15 +++++--
 mm/mmap.c                                          |   14 +++++-
 mm/nommu.c                                         |    4 +-
 mm/shmem.c                                         |    3 +
 net/socket.c                                       |    6 ++-
 security/selinux/selinuxfs.c                       |    6 ++-
 sound/core/compress_offload.c                      |    3 +
 sound/core/hwdep.c                                 |    3 +
 sound/core/info.c                                  |    3 +
 sound/core/init.c                                  |    3 +
 sound/core/oss/pcm_oss.c                           |    3 +
 sound/core/pcm_native.c                            |    3 +
 sound/oss/soundcard.c                              |    3 +
 sound/oss/swarm_cs4297a.c                          |    3 +
 tools/include/uapi/asm-generic/mman-common.h       |    1 
 virt/kvm/kvm_main.c                                |    3 +
 263 files changed, 720 insertions(+), 374 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
