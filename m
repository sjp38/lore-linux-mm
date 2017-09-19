Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A12F66B0038
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 11:42:17 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 93so30704iol.2
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 08:42:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b139sor3859263ioa.38.2017.09.19.08.42.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 08:42:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1505418254.14842.7.camel@intel.com>
References: <1505418254.14842.7.camel@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Sep 2017 08:42:13 -0700
Message-ID: <CAA9_cmcU=UDAYibmxk1RSi59WxN-+SiPWc_-K-DNnt97vs3N7Q@mail.gmail.com>
Subject: Re: [GIT PULL] MAP_SHARED_VALIDATE for 4.14
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Cc: "julia.lawall@lip6.fr" <julia.lawall@lip6.fr>, "jack@suse.cz" <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "luto@kernel.org" <luto@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hch@lst.de" <hch@lst.de>

On Thu, Sep 14, 2017 at 12:44 PM, Williams, Dan J
<dan.j.williams@intel.com> wrote:
> Hi Linus, please consider pulling:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm tags/map-shared-validate-for-4.14


Hi Linus, checking to see you if you declined to merge this because
you missed it, or you don't like the approach.


>
> ...for 4.14 as a pre-requisite for the proposed mmap flags (MAP_SYNC
> and MAP_DIRECT) being developed for 4.15 consideration. As I
> highlighted in the last posting [1] these patches are based on a random
> point in the merge window (state of the tree 2 days ago). They have not
> been in -next. However, they have been exposed to the 0day kbuild robot
> with all reports fixed. A test merge with the state of the tree today
> finds no conflicts, nor new mmap handlers for the coccinelle script to
> convert.
>
> The only change since the last posting was clarifying in commit
> 4aac0d08f6d1 "mm: introduce MAP_SHARED_VALIDATE..." that
> MAP_SHARED_VALIDATE is just MAP_SHARED+validate, not a bitmap to be
> added to new flag values, and that it is a unique MAP_TYPE number not
> necessarily (MAP_SHARED|MAP_PRIVATE) (from Jan's review).
>
> Now, we could wait until 4.15 and do the same rebase, run coccinelle
> script, rinse, and repeat process for 4.15. I.e wait until we also have
> the MAP_SYNC and/or MAP_DIRECT to merge at the same time, but I think
> it is preferable to base that development on early 4.14-rc and get it
> some soak time in -next.
>
> Another alternative is to just get patch1, commit 403fee48224c "vfs:
> add flags...", in for 4.14 and save MAP_SHARED_VALIDATE to arrive in
> the next merge window coincident with the new flags implementation.
>
> Lastly, the alternative to all this thrash is carrying the flags in the
> vma. That bloats vm_area_struct everywhere and complicates vma
> splitting / merging for the handful of mmap implementations that will
> ever care about the new flags.
>
> [1]: https://lwn.net/Articles/733281/
>
> ---
>
> The following changes since commit 8fac2f96ab86b0e14ec4e42851e21e9b518bdc55:
>
>   Merge branch 'for-linus' of git://git.armlinux.org.uk/~rmk/linux-arm (2017-09-12 06:10:44 -0700)
>
> are available in the git repository at:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm tags/map-shared-validate-for-4.14
>
> for you to fetch changes up to 4aac0d08f6d1ae4475bbfe761b943d105e11b82a:
>
>   mm: introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap flags (2017-09-12 10:12:34 -0700)
>
> ----------------------------------------------------------------
> MAP_SHARED_VALIDATE for 4.14
>
> Preparation infrastructure for introducing new mmap flags:
>
> * Introduce MAP_SHARED_VALIDATE as an mmap(2) flag that in addition to
>   creating a MAP_SHARED mapping also arranges for the @flags parameter
>   of mmap(2) to be validated by the endpoint mmap-file-operation. I.e.
>   new mmap flags require per mmap implementation opt-in and run time
>   validation.
>
> * Make the @flags parameter available to all mmap implementations, both
>   top-level 'struct file_operations' and sub-level leaf implementations.
>
> ----------------------------------------------------------------
> Dan Williams (2):
>       vfs: add flags parameter to all ->mmap() handlers
>       mm: introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap flags
>
>  arch/alpha/include/uapi/asm/mman.h                 |  1 +
>  arch/arc/kernel/arc_hostlink.c                     |  3 +-
>  arch/mips/include/uapi/asm/mman.h                  |  1 +
>  arch/mips/kernel/vdso.c                            |  2 +-
>  arch/parisc/include/uapi/asm/mman.h                |  1 +
>  arch/powerpc/kernel/proc_powerpc.c                 |  3 +-
>  arch/powerpc/kvm/book3s_64_vio.c                   |  3 +-
>  arch/powerpc/platforms/cell/spufs/file.c           | 21 +++++++----
>  arch/powerpc/platforms/powernv/memtrace.c          |  3 +-
>  arch/powerpc/platforms/powernv/opal-prd.c          |  3 +-
>  arch/tile/mm/elf.c                                 |  3 +-
>  arch/um/drivers/mmapper_kern.c                     |  3 +-
>  arch/xtensa/include/uapi/asm/mman.h                |  1 +
>  drivers/android/binder.c                           |  3 +-
>  drivers/auxdisplay/cfag12864bfb.c                  |  3 +-
>  drivers/auxdisplay/ht16k33.c                       |  3 +-
>  drivers/char/agp/frontend.c                        |  3 +-
>  drivers/char/bsr.c                                 |  3 +-
>  drivers/char/hpet.c                                |  6 ++-
>  drivers/char/mbcs.c                                |  3 +-
>  drivers/char/mbcs.h                                |  3 +-
>  drivers/char/mem.c                                 | 11 ++++--
>  drivers/char/mspec.c                               |  9 +++--
>  drivers/char/uv_mmtimer.c                          |  6 ++-
>  drivers/dax/device.c                               |  3 +-
>  drivers/dma-buf/dma-buf.c                          | 11 ++++--
>  drivers/firewire/core-cdev.c                       |  3 +-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |  3 +-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h            |  3 +-
>  drivers/gpu/drm/amd/amdkfd/kfd_chardev.c           |  5 ++-
>  drivers/gpu/drm/armada/armada_gem.c                |  3 +-
>  drivers/gpu/drm/ast/ast_drv.h                      |  3 +-
>  drivers/gpu/drm/ast/ast_ttm.c                      |  3 +-
>  drivers/gpu/drm/bochs/bochs.h                      |  3 +-
>  drivers/gpu/drm/bochs/bochs_fbdev.c                |  2 +-
>  drivers/gpu/drm/bochs/bochs_mm.c                   |  3 +-
>  drivers/gpu/drm/cirrus/cirrus_drv.h                |  3 +-
>  drivers/gpu/drm/cirrus/cirrus_ttm.c                |  3 +-
>  drivers/gpu/drm/drm_fb_cma_helper.c                |  8 ++--
>  drivers/gpu/drm/drm_gem.c                          |  4 +-
>  drivers/gpu/drm/drm_gem_cma_helper.c               |  8 ++--
>  drivers/gpu/drm/drm_prime.c                        |  5 ++-
>  drivers/gpu/drm/drm_vm.c                           |  3 +-
>  drivers/gpu/drm/etnaviv/etnaviv_drv.h              |  6 ++-
>  drivers/gpu/drm/etnaviv/etnaviv_gem.c              | 11 +++---
>  drivers/gpu/drm/etnaviv/etnaviv_gem.h              |  3 +-
>  drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c        |  9 +++--
>  drivers/gpu/drm/exynos/exynos_drm_fbdev.c          |  2 +-
>  drivers/gpu/drm/exynos/exynos_drm_gem.c            | 10 +++--
>  drivers/gpu/drm/exynos/exynos_drm_gem.h            |  6 ++-
>  drivers/gpu/drm/gma500/framebuffer.c               |  3 +-
>  drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h    |  3 +-
>  drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c        |  3 +-
>  drivers/gpu/drm/i810/i810_dma.c                    |  3 +-
>  drivers/gpu/drm/i915/i915_gem_dmabuf.c             |  6 ++-
>  drivers/gpu/drm/i915/selftests/mock_dmabuf.c       |  4 +-
>  drivers/gpu/drm/mediatek/mtk_drm_gem.c             |  8 ++--
>  drivers/gpu/drm/mediatek/mtk_drm_gem.h             |  5 ++-
>  drivers/gpu/drm/mgag200/mgag200_drv.h              |  3 +-
>  drivers/gpu/drm/mgag200/mgag200_ttm.c              |  3 +-
>  drivers/gpu/drm/msm/msm_drv.h                      |  6 ++-
>  drivers/gpu/drm/msm/msm_fbdev.c                    |  6 ++-
>  drivers/gpu/drm/msm/msm_gem.c                      |  5 ++-
>  drivers/gpu/drm/msm/msm_gem_prime.c                |  3 +-
>  drivers/gpu/drm/nouveau/nouveau_ttm.c              |  5 ++-
>  drivers/gpu/drm/nouveau/nouveau_ttm.h              |  2 +-
>  drivers/gpu/drm/omapdrm/omap_drv.h                 |  3 +-
>  drivers/gpu/drm/omapdrm/omap_gem.c                 |  5 ++-
>  drivers/gpu/drm/omapdrm/omap_gem_dmabuf.c          |  2 +-
>  drivers/gpu/drm/qxl/qxl_drv.h                      |  6 ++-
>  drivers/gpu/drm/qxl/qxl_prime.c                    |  2 +-
>  drivers/gpu/drm/qxl/qxl_ttm.c                      |  3 +-
>  drivers/gpu/drm/radeon/radeon_drv.c                |  3 +-
>  drivers/gpu/drm/radeon/radeon_ttm.c                |  3 +-
>  drivers/gpu/drm/rockchip/rockchip_drm_fbdev.c      |  5 ++-
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.c        |  7 ++--
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.h        |  5 ++-
>  drivers/gpu/drm/tegra/gem.c                        |  9 +++--
>  drivers/gpu/drm/tegra/gem.h                        |  3 +-
>  drivers/gpu/drm/udl/udl_dmabuf.c                   |  3 +-
>  drivers/gpu/drm/udl/udl_drv.h                      |  3 +-
>  drivers/gpu/drm/udl/udl_fb.c                       |  3 +-
>  drivers/gpu/drm/udl/udl_gem.c                      |  5 ++-
>  drivers/gpu/drm/vc4/vc4_bo.c                       | 10 +++--
>  drivers/gpu/drm/vc4/vc4_drv.h                      |  6 ++-
>  drivers/gpu/drm/vgem/vgem_drv.c                    | 10 +++--
>  drivers/gpu/drm/virtio/virtgpu_drv.h               |  6 ++-
>  drivers/gpu/drm/virtio/virtgpu_prime.c             |  2 +-
>  drivers/gpu/drm/virtio/virtgpu_ttm.c               |  3 +-
>  drivers/gpu/drm/vmwgfx/vmwgfx_drv.h                |  3 +-
>  drivers/gpu/drm/vmwgfx/vmwgfx_prime.c              |  3 +-
>  drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c           |  3 +-
>  drivers/hsi/clients/cmt_speech.c                   |  3 +-
>  drivers/hwtracing/intel_th/msu.c                   |  3 +-
>  drivers/hwtracing/stm/core.c                       |  3 +-
>  drivers/infiniband/core/uverbs_main.c              |  3 +-
>  drivers/infiniband/hw/hfi1/file_ops.c              |  6 ++-
>  drivers/infiniband/hw/qib/qib_file_ops.c           |  5 ++-
>  drivers/media/common/saa7146/saa7146_fops.c        |  3 +-
>  drivers/media/pci/bt8xx/bttv-driver.c              |  3 +-
>  drivers/media/pci/cx18/cx18-fileops.c              |  3 +-
>  drivers/media/pci/cx18/cx18-fileops.h              |  3 +-
>  drivers/media/pci/meye/meye.c                      |  3 +-
>  drivers/media/pci/zoran/zoran_driver.c             |  2 +-
>  drivers/media/platform/davinci/vpfe_capture.c      |  3 +-
>  drivers/media/platform/exynos-gsc/gsc-m2m.c        |  3 +-
>  drivers/media/platform/fsl-viu.c                   |  3 +-
>  drivers/media/platform/m2m-deinterlace.c           |  3 +-
>  drivers/media/platform/mx2_emmaprp.c               |  3 +-
>  drivers/media/platform/omap/omap_vout.c            |  3 +-
>  drivers/media/platform/omap3isp/ispvideo.c         |  3 +-
>  drivers/media/platform/s3c-camif/camif-capture.c   |  3 +-
>  drivers/media/platform/s5p-mfc/s5p_mfc.c           |  3 +-
>  drivers/media/platform/sh_veu.c                    |  3 +-
>  drivers/media/platform/soc_camera/soc_camera.c     |  3 +-
>  drivers/media/platform/via-camera.c                |  3 +-
>  drivers/media/usb/cpia2/cpia2_v4l.c                |  3 +-
>  drivers/media/usb/cx231xx/cx231xx-417.c            |  3 +-
>  drivers/media/usb/cx231xx/cx231xx-video.c          |  3 +-
>  drivers/media/usb/gspca/gspca.c                    |  3 +-
>  drivers/media/usb/stkwebcam/stk-webcam.c           |  3 +-
>  drivers/media/usb/tm6000/tm6000-video.c            |  3 +-
>  drivers/media/usb/usbvision/usbvision-video.c      |  3 +-
>  drivers/media/usb/uvc/uvc_v4l2.c                   |  3 +-
>  drivers/media/usb/zr364xx/zr364xx.c                |  3 +-
>  drivers/media/v4l2-core/v4l2-dev.c                 |  5 ++-
>  drivers/media/v4l2-core/v4l2-mem2mem.c             |  3 +-
>  drivers/media/v4l2-core/videobuf2-dma-contig.c     |  2 +-
>  drivers/media/v4l2-core/videobuf2-dma-sg.c         |  2 +-
>  drivers/media/v4l2-core/videobuf2-v4l2.c           |  3 +-
>  drivers/media/v4l2-core/videobuf2-vmalloc.c        |  2 +-
>  drivers/misc/aspeed-lpc-ctrl.c                     |  3 +-
>  drivers/misc/cxl/api.c                             |  5 ++-
>  drivers/misc/cxl/cxl.h                             |  3 +-
>  drivers/misc/cxl/file.c                            |  3 +-
>  drivers/misc/genwqe/card_dev.c                     |  3 +-
>  drivers/misc/mic/scif/scif_fd.c                    |  3 +-
>  drivers/misc/mic/vop/vop_vringh.c                  |  3 +-
>  drivers/misc/sgi-gru/grufile.c                     |  3 +-
>  drivers/mtd/mtdchar.c                              |  3 +-
>  drivers/pci/proc.c                                 |  3 +-
>  drivers/rapidio/devices/rio_mport_cdev.c           |  3 +-
>  drivers/sbus/char/flash.c                          |  3 +-
>  drivers/sbus/char/jsflash.c                        |  3 +-
>  drivers/scsi/cxlflash/superpipe.c                  |  5 ++-
>  drivers/scsi/sg.c                                  |  3 +-
>  drivers/staging/android/ashmem.c                   |  3 +-
>  drivers/staging/android/ion/ion.c                  |  3 +-
>  drivers/staging/comedi/comedi_fops.c               |  3 +-
>  .../staging/lustre/lustre/llite/llite_internal.h   |  3 +-
>  drivers/staging/lustre/lustre/llite/llite_mmap.c   |  5 ++-
>  .../media/atomisp/pci/atomisp2/atomisp_fops.c      |  6 ++-
>  drivers/staging/media/davinci_vpfe/vpfe_video.c    |  3 +-
>  drivers/staging/media/omap4iss/iss_video.c         |  3 +-
>  drivers/staging/vboxvideo/vbox_drv.h               |  5 ++-
>  drivers/staging/vboxvideo/vbox_prime.c             |  3 +-
>  drivers/staging/vboxvideo/vbox_ttm.c               |  3 +-
>  drivers/staging/vme/devices/vme_user.c             |  3 +-
>  drivers/tee/tee_shm.c                              |  3 +-
>  drivers/uio/uio.c                                  |  3 +-
>  drivers/usb/core/devio.c                           |  3 +-
>  drivers/usb/gadget/function/uvc_v4l2.c             |  3 +-
>  drivers/usb/mon/mon_bin.c                          |  3 +-
>  drivers/vfio/vfio.c                                |  7 +++-
>  drivers/video/fbdev/68328fb.c                      |  6 ++-
>  drivers/video/fbdev/amba-clcd.c                    |  2 +-
>  drivers/video/fbdev/aty/atyfb_base.c               |  6 ++-
>  drivers/video/fbdev/au1100fb.c                     |  3 +-
>  drivers/video/fbdev/au1200fb.c                     |  3 +-
>  drivers/video/fbdev/bw2.c                          |  5 ++-
>  drivers/video/fbdev/cg14.c                         |  5 ++-
>  drivers/video/fbdev/cg3.c                          |  5 ++-
>  drivers/video/fbdev/cg6.c                          |  5 ++-
>  drivers/video/fbdev/controlfb.c                    |  4 +-
>  drivers/video/fbdev/core/fb_defio.c                |  3 +-
>  drivers/video/fbdev/core/fbmem.c                   |  5 ++-
>  drivers/video/fbdev/ep93xx-fb.c                    |  3 +-
>  drivers/video/fbdev/fb-puv3.c                      |  2 +-
>  drivers/video/fbdev/ffb.c                          |  5 ++-
>  drivers/video/fbdev/gbefb.c                        |  2 +-
>  drivers/video/fbdev/igafb.c                        |  2 +-
>  drivers/video/fbdev/leo.c                          |  5 ++-
>  drivers/video/fbdev/omap/omapfb_main.c             |  3 +-
>  drivers/video/fbdev/omap2/omapfb/omapfb-main.c     |  3 +-
>  drivers/video/fbdev/p9100.c                        |  6 ++-
>  drivers/video/fbdev/ps3fb.c                        |  3 +-
>  drivers/video/fbdev/pxa3xx-gcu.c                   |  3 +-
>  drivers/video/fbdev/sa1100fb.c                     |  2 +-
>  drivers/video/fbdev/sh_mobile_lcdcfb.c             |  6 ++-
>  drivers/video/fbdev/smscufx.c                      |  3 +-
>  drivers/video/fbdev/tcx.c                          |  5 ++-
>  drivers/video/fbdev/udlfb.c                        |  3 +-
>  drivers/video/fbdev/vermilion/vermilion.c          |  3 +-
>  drivers/video/fbdev/vfb.c                          |  4 +-
>  drivers/xen/gntalloc.c                             |  3 +-
>  drivers/xen/gntdev.c                               |  3 +-
>  drivers/xen/privcmd.c                              |  3 +-
>  drivers/xen/xenbus/xenbus_dev_backend.c            |  3 +-
>  drivers/xen/xenfs/xenstored.c                      |  3 +-
>  fs/9p/vfs_file.c                                   | 10 +++--
>  fs/aio.c                                           |  3 +-
>  fs/btrfs/file.c                                    |  4 +-
>  fs/ceph/addr.c                                     |  3 +-
>  fs/ceph/super.h                                    |  3 +-
>  fs/cifs/cifsfs.h                                   |  6 ++-
>  fs/cifs/file.c                                     | 10 +++--
>  fs/coda/file.c                                     |  5 ++-
>  fs/ecryptfs/file.c                                 |  5 ++-
>  fs/ext2/file.c                                     |  5 ++-
>  fs/ext4/file.c                                     |  3 +-
>  fs/f2fs/file.c                                     |  3 +-
>  fs/fuse/file.c                                     |  8 ++--
>  fs/gfs2/file.c                                     |  3 +-
>  fs/hugetlbfs/inode.c                               |  3 +-
>  fs/kernfs/file.c                                   |  3 +-
>  fs/ncpfs/mmap.c                                    |  3 +-
>  fs/ncpfs/ncp_fs.h                                  |  2 +-
>  fs/nfs/file.c                                      |  5 ++-
>  fs/nfs/internal.h                                  |  2 +-
>  fs/nilfs2/file.c                                   |  3 +-
>  fs/ocfs2/mmap.c                                    |  3 +-
>  fs/ocfs2/mmap.h                                    |  3 +-
>  fs/orangefs/file.c                                 |  5 ++-
>  fs/proc/inode.c                                    |  7 ++--
>  fs/proc/vmcore.c                                   |  6 ++-
>  fs/ramfs/file-nommu.c                              |  6 ++-
>  fs/romfs/mmap-nommu.c                              |  3 +-
>  fs/ubifs/file.c                                    |  5 ++-
>  fs/xfs/xfs_file.c                                  |  2 +-
>  include/drm/drm_drv.h                              |  3 +-
>  include/drm/drm_gem.h                              |  3 +-
>  include/drm/drm_gem_cma_helper.h                   |  6 ++-
>  include/drm/drm_legacy.h                           |  3 +-
>  include/linux/dma-buf.h                            |  5 ++-
>  include/linux/fb.h                                 |  6 ++-
>  include/linux/fs.h                                 | 14 ++++---
>  include/linux/mm.h                                 |  2 +-
>  include/linux/mman.h                               | 44 ++++++++++++++++++++++
>  include/media/v4l2-dev.h                           |  2 +-
>  include/media/v4l2-mem2mem.h                       |  3 +-
>  include/media/videobuf2-v4l2.h                     |  3 +-
>  include/misc/cxl.h                                 |  3 +-
>  include/uapi/asm-generic/mman-common.h             |  1 +
>  ipc/shm.c                                          |  5 ++-
>  kernel/events/core.c                               |  3 +-
>  kernel/kcov.c                                      |  3 +-
>  kernel/relay.c                                     |  4 +-
>  mm/filemap.c                                       | 15 +++++---
>  mm/mmap.c                                          | 14 +++++--
>  mm/nommu.c                                         |  4 +-
>  mm/shmem.c                                         |  3 +-
>  net/socket.c                                       |  6 ++-
>  security/selinux/selinuxfs.c                       |  6 ++-
>  sound/core/compress_offload.c                      |  3 +-
>  sound/core/hwdep.c                                 |  3 +-
>  sound/core/info.c                                  |  3 +-
>  sound/core/init.c                                  |  3 +-
>  sound/core/oss/pcm_oss.c                           |  3 +-
>  sound/core/pcm_native.c                            |  3 +-
>  sound/oss/soundcard.c                              |  3 +-
>  sound/oss/swarm_cs4297a.c                          |  3 +-
>  tools/include/uapi/asm-generic/mman-common.h       |  1 +
>  virt/kvm/kvm_main.c                                |  3 +-
>  263 files changed, 722 insertions(+), 374 deletions(-)
>
> commit 403fee48224c8fd236a9ec23461e2d752c79101f
> Author: Dan Williams <dan.j.williams@intel.com>
> Date:   Tue Sep 5 17:28:59 2017 -0700
>
>     vfs: add flags parameter to all ->mmap() handlers
>
>     We are running running short of vma->vm_flags. We can avoid needing a
>     new VM_* flag in some cases if the original @flags submitted to mmap(2)
>     is made available to the ->mmap() 'struct file_operations'
>     implementation. For example, the proposed addition of MAP_DIRECT can be
>     implemented without taking up a new vm_flags bit. Another motivation to
>     avoid vm_flags is that they appear in /proc/$pid/smaps, and we have seen
>     software that tries to dangerously (TOCTOU) read smaps to infer the
>     behavior of a virtual address range. Lastly, we may want to reject mmap
>     attempts on a per-mmap-call basis.
>
>     This conversion was performed by the following semantic patch. There
>     were a few manual edits for oddities like proc_reg_mmap, call_mmap,
>     drm_gem_cma_mmap, and cxl_fd_mmap.
>
>     Thanks to Julia for helping me with coccinelle iteration to cover cases
>     where the mmap routine is defined in a separate file from the operations
>     instance that consumes it.
>
>     // Usage:
>     // spatch mmap.cocci --no-includes --include-headers --in-place ./ -j 40 --very-quiet
>
>     virtual after_start
>
>     @initialize:ocaml@
>     @@
>
>     let tbl = Hashtbl.create(100)
>
>     let add_if_not_present fn =
>       if not(Hashtbl.mem tbl fn) then Hashtbl.add tbl fn ()
>
>     @ a @
>     identifier fn;
>     identifier ops;
>     expression E1;
>     @@
>
>     (
>     struct file_operations ops = { ..., .mmap = fn, ...};
>     |
>     struct file_operations ops[E1] = { ..., { ..., .mmap = fn, ...}, ...};
>     |
>     struct etnaviv_gem_ops ops = { ..., .mmap = fn, ...};
>     |
>     struct dma_buf_ops ops = { ..., .mmap = fn, ...};
>     |
>     struct drm_driver ops = { ..., .gem_prime_mmap = fn, ...};
>     |
>     struct fb_ops ops = { ..., .fb_mmap = fn, ...};
>     |
>     struct v4l2_file_operations ops = { ..., .mmap = fn, ...};
>     )
>
>     @script:ocaml@
>     fn << a.fn;
>     @@
>
>     add_if_not_present fn
>
>     @finalize:ocaml depends on !after_start@
>     tbls << merge.tbl;
>     @@
>
>     List.iter (fun t -> Hashtbl.iter (fun f _ -> add_if_not_present f) t) tbls;
>     Hashtbl.iter
>         (fun f _ ->
>           let it = new iteration() in
>           it#add_virtual_rule After_start;
>           it#add_virtual_identifier Fn f;
>           it#register())
>         tbl
>
>     @depends on after_start@
>     identifier virtual.fn;
>     identifier x, y;
>     type T;
>     @@
>
>     int fn(T *x,
>             struct vm_area_struct *y
>     -       )
>     +       , unsigned long map_flags)
>     {
>     ...
>     }
>
>     @depends on after_start@
>     identifier virtual.fn;
>     identifier x, y;
>     type T;
>     @@
>
>     int fn(T *x,
>             struct vm_area_struct *y
>     -       );
>     +       , unsigned long map_flags);
>
>     @depends on after_start@
>     identifier virtual.fn;
>     type T;
>
>     @@
>
>     int fn(T *,
>             struct vm_area_struct *
>     -       );
>     +       , unsigned long);
>
>     @depends on after_start@
>     identifier virtual.fn;
>     expression E1, E2, E3;
>     @@
>
>     E3 = fn(E1, E2
>     - );
>     + , map_flags);
>
>     @depends on after_start@
>     identifier virtual.fn;
>     expression E1, E2;
>     @@
>
>     return fn(E1, E2
>     - );
>     + , map_flags);
>
>     Cc: Takashi Iwai <tiwai@suse.com>
>     Cc: Christoph Hellwig <hch@lst.de>
>     Cc: David Airlie <airlied@linux.ie>
>     Cc: <dri-devel@lists.freedesktop.org>
>     Cc: Daniel Vetter <daniel.vetter@intel.com>
>     Cc: Andrew Morton <akpm@linux-foundation.org>
>     Cc: Linus Torvalds <torvalds@linux-foundation.org>
>     Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>
>     Cc: <linux-media@vger.kernel.org>
>     Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>     Suggested-by: Jan Kara <jack@suse.cz>
>     Acked-by: Jan Kara <jack@suse.cz>
>     Signed-off-by: Julia Lawall <julia.lawall@lip6.fr>
>     Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> commit 4aac0d08f6d1ae4475bbfe761b943d105e11b82a
> Author: Dan Williams <dan.j.williams@intel.com>
> Date:   Mon Aug 14 14:59:39 2017 -0700
>
>     mm: introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap flags
>
>     The mmap(2) syscall suffers from the ABI anti-pattern of not validating
>     unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
>     mechanism to define new behavior that is known to fail on older kernels
>     without the support. Define a new MAP_SHARED_VALIDATE flag pattern that
>     is guaranteed to fail on all legacy mmap implementations.
>
>     It is worth noting that the original proposal was for a standalone
>     MAP_VALIDATE flag. However, when that  could not be supported by all
>     archs Linus observed:
>
>         I see why you *think* you want a bitmap. You think you want
>         a bitmap because you want to make MAP_VALIDATE be part of MAP_SYNC
>         etc, so that people can do
>
>         ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED
>                         | MAP_SYNC, fd, 0);
>
>         and "know" that MAP_SYNC actually takes.
>
>         And I'm saying that whole wish is bogus. You're fundamentally
>         depending on special semantics, just make it explicit. It's already
>         not portable, so don't try to make it so.
>
>         Rename that MAP_VALIDATE as MAP_SHARED_VALIDATE, make it have a value
>         of 0x3, and make people do
>
>         ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED_VALIDATE
>                         | MAP_SYNC, fd, 0);
>
>         and then the kernel side is easier too (none of that random garbage
>         playing games with looking at the "MAP_VALIDATE bit", but just another
>         case statement in that map type thing.
>
>         Boom. Done.
>
>     Similar to ->fallocate() we also want the ability to validate the
>     support for new flags on a per ->mmap() 'struct file_operations'
>     instance basis.  Towards that end arrange for flags to be generically
>     validated against a mmap_supported_mask exported by 'struct
>     file_operations'. By default all existing flags are implicitly
>     supported, but new flags require MAP_SHARED_VALIDATE and
>     per-instance-opt-in.
>
>     Cc: Jan Kara <jack@suse.cz>
>     Cc: Arnd Bergmann <arnd@arndb.de>
>     Cc: Andy Lutomirski <luto@kernel.org>
>     Cc: Andrew Morton <akpm@linux-foundation.org>
>     Suggested-by: Christoph Hellwig <hch@lst.de>
>     Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
>     Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
