Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF066B02B4
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 05:50:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 97so8295398wrb.1
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 02:50:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si6314071wme.3.2017.09.11.02.50.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 02:50:13 -0700 (PDT)
Date: Mon, 11 Sep 2017 11:50:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH v8 1/2] vfs: add flags parameter to all ->mmap()
 handlers
Message-ID: <20170911095010.GE8503@quack2.suse.cz>
References: <150489930202.29460.5141541423730649272.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150489930799.29460.14755818610291368659.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150489930799.29460.14755818610291368659.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: torvalds@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, David Airlie <airlied@linux.ie>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Takashi Iwai <tiwai@suse.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, Mauro Carvalho Chehab <mchehab@s-opensource.com>, Julia Lawall <julia.lawall@lip6.fr>, linux-mm@kvack.org, linux-api@vger.kernel.org, Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de, linux-media@vger.kernel.org

On Fri 08-09-17 12:35:08, Dan Williams wrote:
> We are running running short of vma->vm_flags. We can avoid needing a
> new VM_* flag in some cases if the original @flags submitted to mmap(2)
> is made available to the ->mmap() 'struct file_operations'
> implementation. For example, the proposed addition of MAP_DIRECT can be
> implemented without taking up a new vm_flags bit. Another motivation to
> avoid vm_flags is that they appear in /proc/$pid/smaps, and we have seen
> software that tries to dangerously (TOCTOU) read smaps to infer the
> behavior of a virtual address range. Lastly, we may want to reject mmap
> attempts on a per-mmap-call basis.
> 
> This conversion was performed by the following semantic patch. There
> were a few manual edits for oddities like proc_reg_mmap, call_mmap,
> drm_gem_cma_mmap, and cxl_fd_mmap.

<snip>

> Cc: Takashi Iwai <tiwai@suse.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: David Airlie <airlied@linux.ie>
> Cc: <dri-devel@lists.freedesktop.org>
> Cc: Daniel Vetter <daniel.vetter@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>
> Cc: <linux-media@vger.kernel.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Julia Lawall <julia.lawall@lip6.fr>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

I've skimmed through the patch and it looks sane. You can add:

Acked-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  arch/arc/kernel/arc_hostlink.c                     |    3 ++-
>  arch/mips/kernel/vdso.c                            |    2 +-
>  arch/powerpc/kernel/proc_powerpc.c                 |    3 ++-
>  arch/powerpc/kvm/book3s_64_vio.c                   |    3 ++-
>  arch/powerpc/platforms/cell/spufs/file.c           |   21 +++++++++++++-------
>  arch/powerpc/platforms/powernv/memtrace.c          |    3 ++-
>  arch/powerpc/platforms/powernv/opal-prd.c          |    3 ++-
>  arch/tile/mm/elf.c                                 |    3 ++-
>  arch/um/drivers/mmapper_kern.c                     |    3 ++-
>  drivers/android/binder.c                           |    3 ++-
>  drivers/auxdisplay/cfag12864bfb.c                  |    3 ++-
>  drivers/auxdisplay/ht16k33.c                       |    3 ++-
>  drivers/char/agp/frontend.c                        |    3 ++-
>  drivers/char/bsr.c                                 |    3 ++-
>  drivers/char/hpet.c                                |    6 ++++--
>  drivers/char/mbcs.c                                |    3 ++-
>  drivers/char/mbcs.h                                |    3 ++-
>  drivers/char/mem.c                                 |   11 +++++++---
>  drivers/char/mspec.c                               |    9 ++++++---
>  drivers/char/uv_mmtimer.c                          |    6 ++++--
>  drivers/dax/device.c                               |    3 ++-
>  drivers/dma-buf/dma-buf.c                          |   11 +++++++---
>  drivers/firewire/core-cdev.c                       |    3 ++-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |    3 ++-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h            |    3 ++-
>  drivers/gpu/drm/amd/amdkfd/kfd_chardev.c           |    5 +++--
>  drivers/gpu/drm/armada/armada_gem.c                |    3 ++-
>  drivers/gpu/drm/ast/ast_drv.h                      |    3 ++-
>  drivers/gpu/drm/ast/ast_ttm.c                      |    3 ++-
>  drivers/gpu/drm/bochs/bochs.h                      |    3 ++-
>  drivers/gpu/drm/bochs/bochs_fbdev.c                |    2 +-
>  drivers/gpu/drm/bochs/bochs_mm.c                   |    3 ++-
>  drivers/gpu/drm/cirrus/cirrus_drv.h                |    3 ++-
>  drivers/gpu/drm/cirrus/cirrus_ttm.c                |    3 ++-
>  drivers/gpu/drm/drm_fb_cma_helper.c                |    8 +++++---
>  drivers/gpu/drm/drm_gem.c                          |    3 ++-
>  drivers/gpu/drm/drm_gem_cma_helper.c               |    8 +++++---
>  drivers/gpu/drm/drm_prime.c                        |    5 +++--
>  drivers/gpu/drm/drm_vm.c                           |    3 ++-
>  drivers/gpu/drm/etnaviv/etnaviv_drv.h              |    6 ++++--
>  drivers/gpu/drm/etnaviv/etnaviv_gem.c              |   11 ++++++----
>  drivers/gpu/drm/etnaviv/etnaviv_gem.h              |    3 ++-
>  drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c        |    9 +++++----
>  drivers/gpu/drm/exynos/exynos_drm_fbdev.c          |    2 +-
>  drivers/gpu/drm/exynos/exynos_drm_gem.c            |   10 ++++++----
>  drivers/gpu/drm/exynos/exynos_drm_gem.h            |    6 ++++--
>  drivers/gpu/drm/gma500/framebuffer.c               |    3 ++-
>  drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h    |    3 ++-
>  drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c        |    3 ++-
>  drivers/gpu/drm/i810/i810_dma.c                    |    3 ++-
>  drivers/gpu/drm/i915/i915_gem_dmabuf.c             |    6 ++++--
>  drivers/gpu/drm/i915/selftests/mock_dmabuf.c       |    4 +++-
>  drivers/gpu/drm/mediatek/mtk_drm_gem.c             |    8 +++++---
>  drivers/gpu/drm/mediatek/mtk_drm_gem.h             |    5 +++--
>  drivers/gpu/drm/mgag200/mgag200_drv.h              |    3 ++-
>  drivers/gpu/drm/mgag200/mgag200_ttm.c              |    3 ++-
>  drivers/gpu/drm/msm/msm_drv.h                      |    6 ++++--
>  drivers/gpu/drm/msm/msm_fbdev.c                    |    6 ++++--
>  drivers/gpu/drm/msm/msm_gem.c                      |    5 +++--
>  drivers/gpu/drm/msm/msm_gem_prime.c                |    3 ++-
>  drivers/gpu/drm/nouveau/nouveau_ttm.c              |    5 +++--
>  drivers/gpu/drm/nouveau/nouveau_ttm.h              |    2 +-
>  drivers/gpu/drm/omapdrm/omap_drv.h                 |    3 ++-
>  drivers/gpu/drm/omapdrm/omap_gem.c                 |    5 +++--
>  drivers/gpu/drm/omapdrm/omap_gem_dmabuf.c          |    2 +-
>  drivers/gpu/drm/qxl/qxl_drv.h                      |    6 ++++--
>  drivers/gpu/drm/qxl/qxl_prime.c                    |    2 +-
>  drivers/gpu/drm/qxl/qxl_ttm.c                      |    3 ++-
>  drivers/gpu/drm/radeon/radeon_drv.c                |    3 ++-
>  drivers/gpu/drm/radeon/radeon_ttm.c                |    3 ++-
>  drivers/gpu/drm/rockchip/rockchip_drm_fbdev.c      |    5 +++--
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.c        |    7 ++++---
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.h        |    5 +++--
>  drivers/gpu/drm/tegra/gem.c                        |    9 ++++++---
>  drivers/gpu/drm/tegra/gem.h                        |    3 ++-
>  drivers/gpu/drm/udl/udl_dmabuf.c                   |    3 ++-
>  drivers/gpu/drm/udl/udl_drv.h                      |    3 ++-
>  drivers/gpu/drm/udl/udl_fb.c                       |    3 ++-
>  drivers/gpu/drm/udl/udl_gem.c                      |    5 +++--
>  drivers/gpu/drm/vc4/vc4_bo.c                       |   10 ++++++----
>  drivers/gpu/drm/vc4/vc4_drv.h                      |    6 ++++--
>  drivers/gpu/drm/vgem/vgem_drv.c                    |   10 ++++++----
>  drivers/gpu/drm/virtio/virtgpu_drv.h               |    6 ++++--
>  drivers/gpu/drm/virtio/virtgpu_prime.c             |    2 +-
>  drivers/gpu/drm/virtio/virtgpu_ttm.c               |    3 ++-
>  drivers/gpu/drm/vmwgfx/vmwgfx_drv.h                |    3 ++-
>  drivers/gpu/drm/vmwgfx/vmwgfx_prime.c              |    3 ++-
>  drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c           |    3 ++-
>  drivers/hsi/clients/cmt_speech.c                   |    3 ++-
>  drivers/hwtracing/intel_th/msu.c                   |    3 ++-
>  drivers/hwtracing/stm/core.c                       |    3 ++-
>  drivers/infiniband/core/uverbs_main.c              |    3 ++-
>  drivers/infiniband/hw/hfi1/file_ops.c              |    6 ++++--
>  drivers/infiniband/hw/qib/qib_file_ops.c           |    5 +++--
>  drivers/media/common/saa7146/saa7146_fops.c        |    3 ++-
>  drivers/media/pci/bt8xx/bttv-driver.c              |    3 ++-
>  drivers/media/pci/cx18/cx18-fileops.c              |    3 ++-
>  drivers/media/pci/cx18/cx18-fileops.h              |    3 ++-
>  drivers/media/pci/meye/meye.c                      |    3 ++-
>  drivers/media/pci/zoran/zoran_driver.c             |    2 +-
>  drivers/media/platform/davinci/vpfe_capture.c      |    3 ++-
>  drivers/media/platform/exynos-gsc/gsc-m2m.c        |    3 ++-
>  drivers/media/platform/fsl-viu.c                   |    3 ++-
>  drivers/media/platform/m2m-deinterlace.c           |    3 ++-
>  drivers/media/platform/mx2_emmaprp.c               |    3 ++-
>  drivers/media/platform/omap/omap_vout.c            |    3 ++-
>  drivers/media/platform/omap3isp/ispvideo.c         |    3 ++-
>  drivers/media/platform/s3c-camif/camif-capture.c   |    3 ++-
>  drivers/media/platform/s5p-mfc/s5p_mfc.c           |    3 ++-
>  drivers/media/platform/sh_veu.c                    |    3 ++-
>  drivers/media/platform/soc_camera/soc_camera.c     |    3 ++-
>  drivers/media/platform/via-camera.c                |    3 ++-
>  drivers/media/usb/cpia2/cpia2_v4l.c                |    3 ++-
>  drivers/media/usb/cx231xx/cx231xx-417.c            |    3 ++-
>  drivers/media/usb/cx231xx/cx231xx-video.c          |    3 ++-
>  drivers/media/usb/gspca/gspca.c                    |    3 ++-
>  drivers/media/usb/stkwebcam/stk-webcam.c           |    3 ++-
>  drivers/media/usb/tm6000/tm6000-video.c            |    3 ++-
>  drivers/media/usb/usbvision/usbvision-video.c      |    3 ++-
>  drivers/media/usb/uvc/uvc_v4l2.c                   |    3 ++-
>  drivers/media/usb/zr364xx/zr364xx.c                |    3 ++-
>  drivers/media/v4l2-core/v4l2-dev.c                 |    5 +++--
>  drivers/media/v4l2-core/v4l2-mem2mem.c             |    3 ++-
>  drivers/media/v4l2-core/videobuf2-dma-contig.c     |    2 +-
>  drivers/media/v4l2-core/videobuf2-dma-sg.c         |    2 +-
>  drivers/media/v4l2-core/videobuf2-v4l2.c           |    3 ++-
>  drivers/media/v4l2-core/videobuf2-vmalloc.c        |    2 +-
>  drivers/misc/aspeed-lpc-ctrl.c                     |    3 ++-
>  drivers/misc/cxl/api.c                             |    5 +++--
>  drivers/misc/cxl/cxl.h                             |    3 ++-
>  drivers/misc/cxl/file.c                            |    3 ++-
>  drivers/misc/genwqe/card_dev.c                     |    3 ++-
>  drivers/misc/mic/scif/scif_fd.c                    |    3 ++-
>  drivers/misc/mic/vop/vop_vringh.c                  |    3 ++-
>  drivers/misc/sgi-gru/grufile.c                     |    3 ++-
>  drivers/mtd/mtdchar.c                              |    3 ++-
>  drivers/pci/proc.c                                 |    3 ++-
>  drivers/rapidio/devices/rio_mport_cdev.c           |    3 ++-
>  drivers/sbus/char/flash.c                          |    3 ++-
>  drivers/sbus/char/jsflash.c                        |    3 ++-
>  drivers/scsi/cxlflash/superpipe.c                  |    5 +++--
>  drivers/scsi/sg.c                                  |    3 ++-
>  drivers/staging/android/ashmem.c                   |    3 ++-
>  drivers/staging/android/ion/ion.c                  |    3 ++-
>  drivers/staging/comedi/comedi_fops.c               |    3 ++-
>  .../staging/lustre/lustre/llite/llite_internal.h   |    3 ++-
>  drivers/staging/lustre/lustre/llite/llite_mmap.c   |    5 +++--
>  .../media/atomisp/pci/atomisp2/atomisp_fops.c      |    6 ++++--
>  drivers/staging/media/davinci_vpfe/vpfe_video.c    |    3 ++-
>  drivers/staging/media/omap4iss/iss_video.c         |    3 ++-
>  drivers/staging/vboxvideo/vbox_drv.h               |    5 +++--
>  drivers/staging/vboxvideo/vbox_prime.c             |    3 ++-
>  drivers/staging/vboxvideo/vbox_ttm.c               |    3 ++-
>  drivers/staging/vme/devices/vme_user.c             |    3 ++-
>  drivers/tee/tee_shm.c                              |    3 ++-
>  drivers/uio/uio.c                                  |    3 ++-
>  drivers/usb/core/devio.c                           |    3 ++-
>  drivers/usb/gadget/function/uvc_v4l2.c             |    3 ++-
>  drivers/usb/mon/mon_bin.c                          |    3 ++-
>  drivers/vfio/vfio.c                                |    7 +++++--
>  drivers/video/fbdev/68328fb.c                      |    6 ++++--
>  drivers/video/fbdev/amba-clcd.c                    |    2 +-
>  drivers/video/fbdev/aty/atyfb_base.c               |    6 ++++--
>  drivers/video/fbdev/au1100fb.c                     |    3 ++-
>  drivers/video/fbdev/au1200fb.c                     |    3 ++-
>  drivers/video/fbdev/bw2.c                          |    5 +++--
>  drivers/video/fbdev/cg14.c                         |    5 +++--
>  drivers/video/fbdev/cg3.c                          |    5 +++--
>  drivers/video/fbdev/cg6.c                          |    5 +++--
>  drivers/video/fbdev/controlfb.c                    |    4 ++--
>  drivers/video/fbdev/core/fb_defio.c                |    3 ++-
>  drivers/video/fbdev/core/fbmem.c                   |    5 +++--
>  drivers/video/fbdev/ep93xx-fb.c                    |    3 ++-
>  drivers/video/fbdev/fb-puv3.c                      |    2 +-
>  drivers/video/fbdev/ffb.c                          |    5 +++--
>  drivers/video/fbdev/gbefb.c                        |    2 +-
>  drivers/video/fbdev/igafb.c                        |    2 +-
>  drivers/video/fbdev/leo.c                          |    5 +++--
>  drivers/video/fbdev/omap/omapfb_main.c             |    3 ++-
>  drivers/video/fbdev/omap2/omapfb/omapfb-main.c     |    3 ++-
>  drivers/video/fbdev/p9100.c                        |    6 ++++--
>  drivers/video/fbdev/ps3fb.c                        |    3 ++-
>  drivers/video/fbdev/pxa3xx-gcu.c                   |    3 ++-
>  drivers/video/fbdev/sa1100fb.c                     |    2 +-
>  drivers/video/fbdev/sh_mobile_lcdcfb.c             |    6 ++++--
>  drivers/video/fbdev/smscufx.c                      |    3 ++-
>  drivers/video/fbdev/tcx.c                          |    5 +++--
>  drivers/video/fbdev/udlfb.c                        |    3 ++-
>  drivers/video/fbdev/vermilion/vermilion.c          |    3 ++-
>  drivers/video/fbdev/vfb.c                          |    4 ++--
>  drivers/xen/gntalloc.c                             |    3 ++-
>  drivers/xen/gntdev.c                               |    3 ++-
>  drivers/xen/privcmd.c                              |    3 ++-
>  drivers/xen/xenbus/xenbus_dev_backend.c            |    3 ++-
>  drivers/xen/xenfs/xenstored.c                      |    3 ++-
>  fs/9p/vfs_file.c                                   |   10 ++++++----
>  fs/aio.c                                           |    3 ++-
>  fs/btrfs/file.c                                    |    4 +++-
>  fs/ceph/addr.c                                     |    3 ++-
>  fs/ceph/super.h                                    |    3 ++-
>  fs/cifs/cifsfs.h                                   |    6 ++++--
>  fs/cifs/file.c                                     |   10 ++++++----
>  fs/coda/file.c                                     |    5 +++--
>  fs/ecryptfs/file.c                                 |    5 +++--
>  fs/ext2/file.c                                     |    5 +++--
>  fs/ext4/file.c                                     |    3 ++-
>  fs/f2fs/file.c                                     |    3 ++-
>  fs/fuse/file.c                                     |    8 +++++---
>  fs/gfs2/file.c                                     |    3 ++-
>  fs/hugetlbfs/inode.c                               |    3 ++-
>  fs/kernfs/file.c                                   |    3 ++-
>  fs/ncpfs/mmap.c                                    |    3 ++-
>  fs/ncpfs/ncp_fs.h                                  |    2 +-
>  fs/nfs/file.c                                      |    5 +++--
>  fs/nfs/internal.h                                  |    2 +-
>  fs/nilfs2/file.c                                   |    3 ++-
>  fs/ocfs2/mmap.c                                    |    3 ++-
>  fs/ocfs2/mmap.h                                    |    3 ++-
>  fs/orangefs/file.c                                 |    5 +++--
>  fs/proc/inode.c                                    |    7 ++++---
>  fs/proc/vmcore.c                                   |    6 ++++--
>  fs/ramfs/file-nommu.c                              |    6 ++++--
>  fs/romfs/mmap-nommu.c                              |    3 ++-
>  fs/ubifs/file.c                                    |    5 +++--
>  fs/xfs/xfs_file.c                                  |    2 +-
>  include/drm/drm_drv.h                              |    3 ++-
>  include/drm/drm_gem.h                              |    3 ++-
>  include/drm/drm_gem_cma_helper.h                   |    6 ++++--
>  include/drm/drm_legacy.h                           |    3 ++-
>  include/linux/dma-buf.h                            |    5 +++--
>  include/linux/fb.h                                 |    6 ++++--
>  include/linux/fs.h                                 |   13 ++++++++----
>  include/linux/mm.h                                 |    2 +-
>  include/media/v4l2-dev.h                           |    2 +-
>  include/media/v4l2-mem2mem.h                       |    3 ++-
>  include/media/videobuf2-v4l2.h                     |    3 ++-
>  include/misc/cxl.h                                 |    3 ++-
>  ipc/shm.c                                          |    5 +++--
>  kernel/events/core.c                               |    3 ++-
>  kernel/kcov.c                                      |    3 ++-
>  kernel/relay.c                                     |    3 ++-
>  mm/filemap.c                                       |   15 ++++++++++----
>  mm/mmap.c                                          |    6 +++---
>  mm/nommu.c                                         |    4 ++--
>  mm/shmem.c                                         |    3 ++-
>  net/socket.c                                       |    6 ++++--
>  security/selinux/selinuxfs.c                       |    6 ++++--
>  sound/core/compress_offload.c                      |    3 ++-
>  sound/core/hwdep.c                                 |    3 ++-
>  sound/core/info.c                                  |    3 ++-
>  sound/core/init.c                                  |    3 ++-
>  sound/core/oss/pcm_oss.c                           |    3 ++-
>  sound/core/pcm_native.c                            |    3 ++-
>  sound/oss/soundcard.c                              |    3 ++-
>  sound/oss/swarm_cs4297a.c                          |    3 ++-
>  virt/kvm/kvm_main.c                                |    3 ++-
>  256 files changed, 661 insertions(+), 374 deletions(-)
> 
> diff --git a/arch/arc/kernel/arc_hostlink.c b/arch/arc/kernel/arc_hostlink.c
> index 47b2a17cc52a..09398a953cca 100644
> --- a/arch/arc/kernel/arc_hostlink.c
> +++ b/arch/arc/kernel/arc_hostlink.c
> @@ -18,7 +18,8 @@
>  
>  static unsigned char __HOSTLINK__[4 * PAGE_SIZE] __aligned(PAGE_SIZE);
>  
> -static int arc_hl_mmap(struct file *fp, struct vm_area_struct *vma)
> +static int arc_hl_mmap(struct file *fp, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
>  
> diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
> index 093517e85a6c..aa143d113aba 100644
> --- a/arch/mips/kernel/vdso.c
> +++ b/arch/mips/kernel/vdso.c
> @@ -111,7 +111,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
>  	base = mmap_region(NULL, STACK_TOP, PAGE_SIZE,
>  			   VM_READ|VM_WRITE|VM_EXEC|
>  			   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
> -			   0, NULL);
> +			   0, NULL, 0);
>  	if (IS_ERR_VALUE(base)) {
>  		ret = base;
>  		goto out;
> diff --git a/arch/powerpc/kernel/proc_powerpc.c b/arch/powerpc/kernel/proc_powerpc.c
> index 56548bf6231f..f9e2b0c7c093 100644
> --- a/arch/powerpc/kernel/proc_powerpc.c
> +++ b/arch/powerpc/kernel/proc_powerpc.c
> @@ -41,7 +41,8 @@ static ssize_t page_map_read( struct file *file, char __user *buf, size_t nbytes
>  			PDE_DATA(file_inode(file)), PAGE_SIZE);
>  }
>  
> -static int page_map_mmap( struct file *file, struct vm_area_struct *vma )
> +static int page_map_mmap( struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	if ((vma->vm_end - vma->vm_start) > PAGE_SIZE)
>  		return -EINVAL;
> diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
> index 53766e2bc029..75eb54e667b0 100644
> --- a/arch/powerpc/kvm/book3s_64_vio.c
> +++ b/arch/powerpc/kvm/book3s_64_vio.c
> @@ -255,7 +255,8 @@ static const struct vm_operations_struct kvm_spapr_tce_vm_ops = {
>  	.fault = kvm_spapr_tce_fault,
>  };
>  
> -static int kvm_spapr_tce_mmap(struct file *file, struct vm_area_struct *vma)
> +static int kvm_spapr_tce_mmap(struct file *file, struct vm_area_struct *vma,
> +			      unsigned long map_flags)
>  {
>  	vma->vm_ops = &kvm_spapr_tce_vm_ops;
>  	return 0;
> diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
> index 5ffcdeb1eb17..4abd3f76ebfd 100644
> --- a/arch/powerpc/platforms/cell/spufs/file.c
> +++ b/arch/powerpc/platforms/cell/spufs/file.c
> @@ -291,7 +291,8 @@ static const struct vm_operations_struct spufs_mem_mmap_vmops = {
>  	.access = spufs_mem_mmap_access,
>  };
>  
> -static int spufs_mem_mmap(struct file *file, struct vm_area_struct *vma)
> +static int spufs_mem_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	if (!(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
> @@ -379,7 +380,8 @@ static const struct vm_operations_struct spufs_cntl_mmap_vmops = {
>  /*
>   * mmap support for problem state control area [0x4000 - 0x4fff].
>   */
> -static int spufs_cntl_mmap(struct file *file, struct vm_area_struct *vma)
> +static int spufs_cntl_mmap(struct file *file, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	if (!(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
> @@ -1059,7 +1061,8 @@ static const struct vm_operations_struct spufs_signal1_mmap_vmops = {
>  	.fault = spufs_signal1_mmap_fault,
>  };
>  
> -static int spufs_signal1_mmap(struct file *file, struct vm_area_struct *vma)
> +static int spufs_signal1_mmap(struct file *file, struct vm_area_struct *vma,
> +			      unsigned long map_flags)
>  {
>  	if (!(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
> @@ -1197,7 +1200,8 @@ static const struct vm_operations_struct spufs_signal2_mmap_vmops = {
>  	.fault = spufs_signal2_mmap_fault,
>  };
>  
> -static int spufs_signal2_mmap(struct file *file, struct vm_area_struct *vma)
> +static int spufs_signal2_mmap(struct file *file, struct vm_area_struct *vma,
> +			      unsigned long map_flags)
>  {
>  	if (!(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
> @@ -1320,7 +1324,8 @@ static const struct vm_operations_struct spufs_mss_mmap_vmops = {
>  /*
>   * mmap support for problem state MFC DMA area [0x0000 - 0x0fff].
>   */
> -static int spufs_mss_mmap(struct file *file, struct vm_area_struct *vma)
> +static int spufs_mss_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	if (!(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
> @@ -1382,7 +1387,8 @@ static const struct vm_operations_struct spufs_psmap_mmap_vmops = {
>  /*
>   * mmap support for full problem state area [0x00000 - 0x1ffff].
>   */
> -static int spufs_psmap_mmap(struct file *file, struct vm_area_struct *vma)
> +static int spufs_psmap_mmap(struct file *file, struct vm_area_struct *vma,
> +			    unsigned long map_flags)
>  {
>  	if (!(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
> @@ -1442,7 +1448,8 @@ static const struct vm_operations_struct spufs_mfc_mmap_vmops = {
>  /*
>   * mmap support for problem state MFC DMA area [0x0000 - 0x0fff].
>   */
> -static int spufs_mfc_mmap(struct file *file, struct vm_area_struct *vma)
> +static int spufs_mfc_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	if (!(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
> diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
> index de470caf0784..1298ce76a543 100644
> --- a/arch/powerpc/platforms/powernv/memtrace.c
> +++ b/arch/powerpc/platforms/powernv/memtrace.c
> @@ -57,7 +57,8 @@ static bool valid_memtrace_range(struct memtrace_entry *dev,
>  	return false;
>  }
>  
> -static int memtrace_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int memtrace_mmap(struct file *filp, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	unsigned long size = vma->vm_end - vma->vm_start;
>  	struct memtrace_entry *dev = filp->private_data;
> diff --git a/arch/powerpc/platforms/powernv/opal-prd.c b/arch/powerpc/platforms/powernv/opal-prd.c
> index de4dd09f4a15..63e55f6b97e5 100644
> --- a/arch/powerpc/platforms/powernv/opal-prd.c
> +++ b/arch/powerpc/platforms/powernv/opal-prd.c
> @@ -109,7 +109,8 @@ static int opal_prd_open(struct inode *inode, struct file *file)
>   * @vma: VMA to map the registers into
>   */
>  
> -static int opal_prd_mmap(struct file *file, struct vm_area_struct *vma)
> +static int opal_prd_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	size_t addr, size;
>  	pgprot_t page_prot;
> diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
> index 889901824400..fb4f16c61b64 100644
> --- a/arch/tile/mm/elf.c
> +++ b/arch/tile/mm/elf.c
> @@ -143,7 +143,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
>  		unsigned long addr = MEM_USER_INTRPT;
>  		addr = mmap_region(NULL, addr, INTRPT_SIZE,
>  				   VM_READ|VM_EXEC|
> -				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0, NULL);
> +				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
> +				   0, NULL, 0);
>  		if (addr > (unsigned long) -PAGE_SIZE)
>  			retval = (int) addr;
>  	}
> diff --git a/arch/um/drivers/mmapper_kern.c b/arch/um/drivers/mmapper_kern.c
> index 3645fcb2a787..046eb23602a2 100644
> --- a/arch/um/drivers/mmapper_kern.c
> +++ b/arch/um/drivers/mmapper_kern.c
> @@ -45,7 +45,8 @@ static long mmapper_ioctl(struct file *file, unsigned int cmd, unsigned long arg
>  	return -ENOIOCTLCMD;
>  }
>  
> -static int mmapper_mmap(struct file *file, struct vm_area_struct *vma)
> +static int mmapper_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	int ret = -EINVAL;
>  	int size;
> diff --git a/drivers/android/binder.c b/drivers/android/binder.c
> index d055b3f2a207..28707987638c 100644
> --- a/drivers/android/binder.c
> +++ b/drivers/android/binder.c
> @@ -4545,7 +4545,8 @@ static const struct vm_operations_struct binder_vm_ops = {
>  	.fault = binder_vm_fault,
>  };
>  
> -static int binder_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int binder_mmap(struct file *filp, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	int ret;
>  	struct binder_proc *proc = filp->private_data;
> diff --git a/drivers/auxdisplay/cfag12864bfb.c b/drivers/auxdisplay/cfag12864bfb.c
> index a3874034e2ce..b8beca99daed 100644
> --- a/drivers/auxdisplay/cfag12864bfb.c
> +++ b/drivers/auxdisplay/cfag12864bfb.c
> @@ -64,7 +64,8 @@ static struct fb_var_screeninfo cfag12864bfb_var = {
>  	.vmode = FB_VMODE_NONINTERLACED,
>  };
>  
> -static int cfag12864bfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int cfag12864bfb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			     unsigned long map_flags)
>  {
>  	return vm_insert_page(vma, vma->vm_start,
>  		virt_to_page(cfag12864b_buffer));
> diff --git a/drivers/auxdisplay/ht16k33.c b/drivers/auxdisplay/ht16k33.c
> index fbfa5b4cc567..f48f159c1645 100644
> --- a/drivers/auxdisplay/ht16k33.c
> +++ b/drivers/auxdisplay/ht16k33.c
> @@ -228,7 +228,8 @@ static const struct backlight_ops ht16k33_bl_ops = {
>  	.check_fb	= ht16k33_bl_check_fb,
>  };
>  
> -static int ht16k33_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int ht16k33_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	struct ht16k33_priv *priv = info->par;
>  
> diff --git a/drivers/char/agp/frontend.c b/drivers/char/agp/frontend.c
> index f6955888e676..c39b90e26c76 100644
> --- a/drivers/char/agp/frontend.c
> +++ b/drivers/char/agp/frontend.c
> @@ -562,7 +562,8 @@ int agp_remove_client(pid_t id)
>  
>  /* File Operations */
>  
> -static int agp_mmap(struct file *file, struct vm_area_struct *vma)
> +static int agp_mmap(struct file *file, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	unsigned int size, current_size;
>  	unsigned long offset;
> diff --git a/drivers/char/bsr.c b/drivers/char/bsr.c
> index a6cef548e01e..93ec4c6f029e 100644
> --- a/drivers/char/bsr.c
> +++ b/drivers/char/bsr.c
> @@ -122,7 +122,8 @@ static struct attribute *bsr_dev_attrs[] = {
>  };
>  ATTRIBUTE_GROUPS(bsr_dev);
>  
> -static int bsr_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int bsr_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	unsigned long size   = vma->vm_end - vma->vm_start;
>  	struct bsr_dev *dev = filp->private_data;
> diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
> index b941e6d59fd6..e817c1b6c52d 100644
> --- a/drivers/char/hpet.c
> +++ b/drivers/char/hpet.c
> @@ -379,7 +379,8 @@ static __init int hpet_mmap_enable(char *str)
>  }
>  __setup("hpet_mmap", hpet_mmap_enable);
>  
> -static int hpet_mmap(struct file *file, struct vm_area_struct *vma)
> +static int hpet_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct hpet_dev *devp;
>  	unsigned long addr;
> @@ -397,7 +398,8 @@ static int hpet_mmap(struct file *file, struct vm_area_struct *vma)
>  	return vm_iomap_memory(vma, addr, PAGE_SIZE);
>  }
>  #else
> -static int hpet_mmap(struct file *file, struct vm_area_struct *vma)
> +static int hpet_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	return -ENOSYS;
>  }
> diff --git a/drivers/char/mbcs.c b/drivers/char/mbcs.c
> index 8c9216a0f62e..2cd165571039 100644
> --- a/drivers/char/mbcs.c
> +++ b/drivers/char/mbcs.c
> @@ -475,7 +475,8 @@ static void mbcs_gscr_pioaddr_set(struct mbcs_soft *soft)
>  	soft->gscr_addr = mbcs_pioaddr(soft, MBCS_GSCR_START);
>  }
>  
> -static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma)
> +static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct cx_dev *cx_dev = fp->private_data;
>  	struct mbcs_soft *soft = cx_dev->soft;
> diff --git a/drivers/char/mbcs.h b/drivers/char/mbcs.h
> index 1a36884c48b5..7d147ed61c67 100644
> --- a/drivers/char/mbcs.h
> +++ b/drivers/char/mbcs.h
> @@ -548,6 +548,7 @@ static ssize_t mbcs_sram_read(struct file *fp, char __user *buf, size_t len,
>  static ssize_t mbcs_sram_write(struct file *fp, const char __user *buf, size_t len,
>  			       loff_t * off);
>  static loff_t mbcs_sram_llseek(struct file *filp, loff_t off, int whence);
> -static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma);
> +static int mbcs_gscr_mmap(struct file *fp, struct vm_area_struct *vma,
> +			  unsigned long map_flags);
>  
>  #endif				// __MBCS_H__
> diff --git a/drivers/char/mem.c b/drivers/char/mem.c
> index 593a8818aca9..79bf151da3bd 100644
> --- a/drivers/char/mem.c
> +++ b/drivers/char/mem.c
> @@ -337,7 +337,8 @@ static const struct vm_operations_struct mmap_mem_ops = {
>  #endif
>  };
>  
> -static int mmap_mem(struct file *file, struct vm_area_struct *vma)
> +static int mmap_mem(struct file *file, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	size_t size = vma->vm_end - vma->vm_start;
>  	phys_addr_t offset = (phys_addr_t)vma->vm_pgoff << PAGE_SHIFT;
> @@ -376,7 +377,8 @@ static int mmap_mem(struct file *file, struct vm_area_struct *vma)
>  	return 0;
>  }
>  
> -static int mmap_kmem(struct file *file, struct vm_area_struct *vma)
> +static int mmap_kmem(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	unsigned long pfn;
>  
> @@ -394,7 +396,7 @@ static int mmap_kmem(struct file *file, struct vm_area_struct *vma)
>  		return -EIO;
>  
>  	vma->vm_pgoff = pfn;
> -	return mmap_mem(file, vma);
> +	return mmap_mem(file, vma, map_flags);
>  }
>  
>  /*
> @@ -679,7 +681,8 @@ static ssize_t read_iter_zero(struct kiocb *iocb, struct iov_iter *iter)
>  	return written;
>  }
>  
> -static int mmap_zero(struct file *file, struct vm_area_struct *vma)
> +static int mmap_zero(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  #ifndef CONFIG_MMU
>  	return -ENOSYS;
> diff --git a/drivers/char/mspec.c b/drivers/char/mspec.c
> index 7b75669d3670..a3496304c4ef 100644
> --- a/drivers/char/mspec.c
> +++ b/drivers/char/mspec.c
> @@ -287,19 +287,22 @@ mspec_mmap(struct file *file, struct vm_area_struct *vma,
>  }
>  
>  static int
> -fetchop_mmap(struct file *file, struct vm_area_struct *vma)
> +fetchop_mmap(struct file *file, struct vm_area_struct *vma,
> +	     unsigned long map_flags)
>  {
>  	return mspec_mmap(file, vma, MSPEC_FETCHOP);
>  }
>  
>  static int
> -cached_mmap(struct file *file, struct vm_area_struct *vma)
> +cached_mmap(struct file *file, struct vm_area_struct *vma,
> +	    unsigned long map_flags)
>  {
>  	return mspec_mmap(file, vma, MSPEC_CACHED);
>  }
>  
>  static int
> -uncached_mmap(struct file *file, struct vm_area_struct *vma)
> +uncached_mmap(struct file *file, struct vm_area_struct *vma,
> +	      unsigned long map_flags)
>  {
>  	return mspec_mmap(file, vma, MSPEC_UNCACHED);
>  }
> diff --git a/drivers/char/uv_mmtimer.c b/drivers/char/uv_mmtimer.c
> index 956ebe2080a5..c95e68ec2ca2 100644
> --- a/drivers/char/uv_mmtimer.c
> +++ b/drivers/char/uv_mmtimer.c
> @@ -40,7 +40,8 @@ MODULE_LICENSE("GPL");
>  
>  static long uv_mmtimer_ioctl(struct file *file, unsigned int cmd,
>  						unsigned long arg);
> -static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma);
> +static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma,
> +			   unsigned long map_flags);
>  
>  /*
>   * Period in femtoseconds (10^-15 s)
> @@ -144,7 +145,8 @@ static long uv_mmtimer_ioctl(struct file *file, unsigned int cmd,
>   * Calls remap_pfn_range() to map the clock's registers into
>   * the calling process' address space.
>   */
> -static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma)
> +static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	unsigned long uv_mmtimer_addr;
>  
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index e9f3b3e4bbf4..52aa8c80f786 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -432,7 +432,8 @@ static const struct vm_operations_struct dax_vm_ops = {
>  	.huge_fault = dev_dax_huge_fault,
>  };
>  
> -static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int dax_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct dev_dax *dev_dax = filp->private_data;
>  	int rc, id;
> diff --git a/drivers/dma-buf/dma-buf.c b/drivers/dma-buf/dma-buf.c
> index 4a038dcf5361..3c0cadb336bd 100644
> --- a/drivers/dma-buf/dma-buf.c
> +++ b/drivers/dma-buf/dma-buf.c
> @@ -81,7 +81,9 @@ static int dma_buf_release(struct inode *inode, struct file *file)
>  	return 0;
>  }
>  
> -static int dma_buf_mmap_internal(struct file *file, struct vm_area_struct *vma)
> +static int dma_buf_mmap_internal(struct file *file,
> +				 struct vm_area_struct *vma,
> +				 unsigned long map_flags)
>  {
>  	struct dma_buf *dmabuf;
>  
> @@ -95,7 +97,7 @@ static int dma_buf_mmap_internal(struct file *file, struct vm_area_struct *vma)
>  	    dmabuf->size >> PAGE_SHIFT)
>  		return -EINVAL;
>  
> -	return dmabuf->ops->mmap(dmabuf, vma);
> +	return dmabuf->ops->mmap(dmabuf, vma, map_flags);
>  }
>  
>  static loff_t dma_buf_llseek(struct file *file, loff_t offset, int whence)
> @@ -936,6 +938,7 @@ EXPORT_SYMBOL_GPL(dma_buf_kunmap);
>   * @vma:	[in]	vma for the mmap
>   * @pgoff:	[in]	offset in pages where this mmap should start within the
>   *			dma-buf buffer.
> + * @map_flags:	[in]	flags that were passed to mmap(2)
>   *
>   * This function adjusts the passed in vma so that it points at the file of the
>   * dma_buf operation. It also adjusts the starting pgoff and does bounds
> @@ -945,7 +948,7 @@ EXPORT_SYMBOL_GPL(dma_buf_kunmap);
>   * Can return negative error values, returns 0 on success.
>   */
>  int dma_buf_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma,
> -		 unsigned long pgoff)
> +		 unsigned long pgoff, unsigned long map_flags)
>  {
>  	struct file *oldfile;
>  	int ret;
> @@ -968,7 +971,7 @@ int dma_buf_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma,
>  	vma->vm_file = dmabuf->file;
>  	vma->vm_pgoff = pgoff;
>  
> -	ret = dmabuf->ops->mmap(dmabuf, vma);
> +	ret = dmabuf->ops->mmap(dmabuf, vma, map_flags);
>  	if (ret) {
>  		/* restore old parameters on failure */
>  		vma->vm_file = oldfile;
> diff --git a/drivers/firewire/core-cdev.c b/drivers/firewire/core-cdev.c
> index a301fcf46e88..07b8983d31ff 100644
> --- a/drivers/firewire/core-cdev.c
> +++ b/drivers/firewire/core-cdev.c
> @@ -1667,7 +1667,8 @@ static long fw_device_op_compat_ioctl(struct file *file,
>  }
>  #endif
>  
> -static int fw_device_op_mmap(struct file *file, struct vm_area_struct *vma)
> +static int fw_device_op_mmap(struct file *file, struct vm_area_struct *vma,
> +			     unsigned long map_flags)
>  {
>  	struct client *client = file->private_data;
>  	unsigned long size;
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> index 8b2c294f6f79..59f4e8f68746 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> @@ -1389,7 +1389,8 @@ void amdgpu_ttm_set_active_vram_size(struct amdgpu_device *adev, u64 size)
>  	man->size = size >> PAGE_SHIFT;
>  }
>  
> -int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma)
> +int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma,
> +		unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct amdgpu_device *adev;
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
> index f22a4758719d..234dda254ec3 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
> @@ -81,7 +81,8 @@ int amdgpu_fill_buffer(struct amdgpu_bo *bo,
>  			struct reservation_object *resv,
>  			struct dma_fence **fence);
>  
> -int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma);
> +int amdgpu_mmap(struct file *filp, struct vm_area_struct *vma,
> +		unsigned long map_flags);
>  bool amdgpu_ttm_is_bound(struct ttm_tt *ttm);
>  int amdgpu_ttm_bind(struct ttm_buffer_object *bo, struct ttm_mem_reg *bo_mem);
>  int amdgpu_ttm_recover_gart(struct amdgpu_device *adev);
> diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c b/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
> index e4a8c2e52cb2..657bfea21ce0 100644
> --- a/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
> +++ b/drivers/gpu/drm/amd/amdkfd/kfd_chardev.c
> @@ -39,7 +39,7 @@
>  
>  static long kfd_ioctl(struct file *, unsigned int, unsigned long);
>  static int kfd_open(struct inode *, struct file *);
> -static int kfd_mmap(struct file *, struct vm_area_struct *);
> +static int kfd_mmap(struct file *, struct vm_area_struct *, unsigned long);
>  
>  static const char kfd_dev_name[] = "kfd";
>  
> @@ -1074,7 +1074,8 @@ static long kfd_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
>  	return retcode;
>  }
>  
> -static int kfd_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int kfd_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct kfd_process *process;
>  
> diff --git a/drivers/gpu/drm/armada/armada_gem.c b/drivers/gpu/drm/armada/armada_gem.c
> index a76ca21d063b..13d2b58f74a2 100644
> --- a/drivers/gpu/drm/armada/armada_gem.c
> +++ b/drivers/gpu/drm/armada/armada_gem.c
> @@ -518,7 +518,8 @@ armada_gem_dmabuf_no_kunmap(struct dma_buf *buf, unsigned long n, void *addr)
>  }
>  
>  static int
> -armada_gem_dmabuf_mmap(struct dma_buf *buf, struct vm_area_struct *vma)
> +armada_gem_dmabuf_mmap(struct dma_buf *buf, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	return -EINVAL;
>  }
> diff --git a/drivers/gpu/drm/ast/ast_drv.h b/drivers/gpu/drm/ast/ast_drv.h
> index e6c4cd3dc50e..514d51df79a4 100644
> --- a/drivers/gpu/drm/ast/ast_drv.h
> +++ b/drivers/gpu/drm/ast/ast_drv.h
> @@ -390,7 +390,8 @@ static inline void ast_bo_unreserve(struct ast_bo *bo)
>  
>  void ast_ttm_placement(struct ast_bo *bo, int domain);
>  int ast_bo_push_sysram(struct ast_bo *bo);
> -int ast_mmap(struct file *filp, struct vm_area_struct *vma);
> +int ast_mmap(struct file *filp, struct vm_area_struct *vma,
> +	     unsigned long map_flags);
>  
>  /* ast post */
>  void ast_enable_vga(struct drm_device *dev);
> diff --git a/drivers/gpu/drm/ast/ast_ttm.c b/drivers/gpu/drm/ast/ast_ttm.c
> index 696a15dc2f3f..12ae616738df 100644
> --- a/drivers/gpu/drm/ast/ast_ttm.c
> +++ b/drivers/gpu/drm/ast/ast_ttm.c
> @@ -417,7 +417,8 @@ int ast_bo_push_sysram(struct ast_bo *bo)
>  	return 0;
>  }
>  
> -int ast_mmap(struct file *filp, struct vm_area_struct *vma)
> +int ast_mmap(struct file *filp, struct vm_area_struct *vma,
> +	     unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct ast_private *ast;
> diff --git a/drivers/gpu/drm/bochs/bochs.h b/drivers/gpu/drm/bochs/bochs.h
> index 76c490c3cdbc..20e9eef85722 100644
> --- a/drivers/gpu/drm/bochs/bochs.h
> +++ b/drivers/gpu/drm/bochs/bochs.h
> @@ -136,7 +136,8 @@ void bochs_hw_setbase(struct bochs_device *bochs,
>  /* bochs_mm.c */
>  int bochs_mm_init(struct bochs_device *bochs);
>  void bochs_mm_fini(struct bochs_device *bochs);
> -int bochs_mmap(struct file *filp, struct vm_area_struct *vma);
> +int bochs_mmap(struct file *filp, struct vm_area_struct *vma,
> +	       unsigned long map_flags);
>  
>  int bochs_gem_create(struct drm_device *dev, u32 size, bool iskernel,
>  		     struct drm_gem_object **obj);
> diff --git a/drivers/gpu/drm/bochs/bochs_fbdev.c b/drivers/gpu/drm/bochs/bochs_fbdev.c
> index 14eb8d0d5a00..558977041df5 100644
> --- a/drivers/gpu/drm/bochs/bochs_fbdev.c
> +++ b/drivers/gpu/drm/bochs/bochs_fbdev.c
> @@ -10,7 +10,7 @@
>  /* ---------------------------------------------------------------------- */
>  
>  static int bochsfb_mmap(struct fb_info *info,
> -			struct vm_area_struct *vma)
> +			struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	struct drm_fb_helper *fb_helper = info->par;
>  	struct bochs_device *bochs =
> diff --git a/drivers/gpu/drm/bochs/bochs_mm.c b/drivers/gpu/drm/bochs/bochs_mm.c
> index c4cadb638460..d4c8b30594d4 100644
> --- a/drivers/gpu/drm/bochs/bochs_mm.c
> +++ b/drivers/gpu/drm/bochs/bochs_mm.c
> @@ -327,7 +327,8 @@ int bochs_bo_unpin(struct bochs_bo *bo)
>  	return 0;
>  }
>  
> -int bochs_mmap(struct file *filp, struct vm_area_struct *vma)
> +int bochs_mmap(struct file *filp, struct vm_area_struct *vma,
> +	       unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct bochs_device *bochs;
> diff --git a/drivers/gpu/drm/cirrus/cirrus_drv.h b/drivers/gpu/drm/cirrus/cirrus_drv.h
> index be2d7e488062..d69c5dd0e5ea 100644
> --- a/drivers/gpu/drm/cirrus/cirrus_drv.h
> +++ b/drivers/gpu/drm/cirrus/cirrus_drv.h
> @@ -232,7 +232,8 @@ void cirrus_mm_fini(struct cirrus_device *cirrus);
>  void cirrus_ttm_placement(struct cirrus_bo *bo, int domain);
>  int cirrus_bo_create(struct drm_device *dev, int size, int align,
>  		     uint32_t flags, struct cirrus_bo **pcirrusbo);
> -int cirrus_mmap(struct file *filp, struct vm_area_struct *vma);
> +int cirrus_mmap(struct file *filp, struct vm_area_struct *vma,
> +		unsigned long map_flags);
>  
>  static inline int cirrus_bo_reserve(struct cirrus_bo *bo, bool no_wait)
>  {
> diff --git a/drivers/gpu/drm/cirrus/cirrus_ttm.c b/drivers/gpu/drm/cirrus/cirrus_ttm.c
> index 1ff1838c0d44..efd01ec99c83 100644
> --- a/drivers/gpu/drm/cirrus/cirrus_ttm.c
> +++ b/drivers/gpu/drm/cirrus/cirrus_ttm.c
> @@ -405,7 +405,8 @@ int cirrus_bo_push_sysram(struct cirrus_bo *bo)
>  	return 0;
>  }
>  
> -int cirrus_mmap(struct file *filp, struct vm_area_struct *vma)
> +int cirrus_mmap(struct file *filp, struct vm_area_struct *vma,
> +		unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct cirrus_device *cirrus;
> diff --git a/drivers/gpu/drm/drm_fb_cma_helper.c b/drivers/gpu/drm/drm_fb_cma_helper.c
> index f2ee88363015..92334f277568 100644
> --- a/drivers/gpu/drm/drm_fb_cma_helper.c
> +++ b/drivers/gpu/drm/drm_fb_cma_helper.c
> @@ -238,7 +238,8 @@ int drm_fb_cma_debugfs_show(struct seq_file *m, void *arg)
>  EXPORT_SYMBOL_GPL(drm_fb_cma_debugfs_show);
>  #endif
>  
> -static int drm_fb_cma_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int drm_fb_cma_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	return dma_mmap_writecombine(info->device, vma, info->screen_base,
>  				     info->fix.smem_start, info->fix.smem_len);
> @@ -254,9 +255,10 @@ static struct fb_ops drm_fbdev_cma_ops = {
>  };
>  
>  static int drm_fbdev_cma_deferred_io_mmap(struct fb_info *info,
> -					  struct vm_area_struct *vma)
> +					  struct vm_area_struct *vma,
> +					  unsigned long map_flags)
>  {
> -	fb_deferred_io_mmap(info, vma);
> +	fb_deferred_io_mmap(info, vma, map_flags);
>  	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
>  
>  	return 0;
> diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
> index c55f338e380b..f0b91a438c16 100644
> --- a/drivers/gpu/drm/drm_gem.c
> +++ b/drivers/gpu/drm/drm_gem.c
> @@ -995,7 +995,8 @@ EXPORT_SYMBOL(drm_gem_mmap_obj);
>   * If the caller is not granted access to the buffer object, the mmap will fail
>   * with EACCES. Please see the vma manager for more information.
>   */
> -int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
> +int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		 unsigned long map_flags)
>  {
>  	struct drm_file *priv = filp->private_data;
>  	struct drm_device *dev = priv->minor->dev;
> diff --git a/drivers/gpu/drm/drm_gem_cma_helper.c b/drivers/gpu/drm/drm_gem_cma_helper.c
> index 373e33f22be4..0eb5db9f0a0d 100644
> --- a/drivers/gpu/drm/drm_gem_cma_helper.c
> +++ b/drivers/gpu/drm/drm_gem_cma_helper.c
> @@ -309,13 +309,14 @@ static int drm_gem_cma_mmap_obj(struct drm_gem_cma_object *cma_obj,
>   * Returns:
>   * 0 on success or a negative error code on failure.
>   */
> -int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma)
> +int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct drm_gem_cma_object *cma_obj;
>  	struct drm_gem_object *gem_obj;
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret)
>  		return ret;
>  
> @@ -512,7 +513,8 @@ EXPORT_SYMBOL_GPL(drm_gem_cma_prime_import_sg_table);
>   * 0 on success or a negative error code on failure.
>   */
>  int drm_gem_cma_prime_mmap(struct drm_gem_object *obj,
> -			   struct vm_area_struct *vma)
> +			   struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	struct drm_gem_cma_object *cma_obj;
>  	int ret;
> diff --git a/drivers/gpu/drm/drm_prime.c b/drivers/gpu/drm/drm_prime.c
> index 22408badc617..3e9c3cc3ea65 100644
> --- a/drivers/gpu/drm/drm_prime.c
> +++ b/drivers/gpu/drm/drm_prime.c
> @@ -386,7 +386,8 @@ static void drm_gem_dmabuf_kunmap(struct dma_buf *dma_buf,
>  }
>  
>  static int drm_gem_dmabuf_mmap(struct dma_buf *dma_buf,
> -			       struct vm_area_struct *vma)
> +			       struct vm_area_struct *vma,
> +			       unsigned long map_flags)
>  {
>  	struct drm_gem_object *obj = dma_buf->priv;
>  	struct drm_device *dev = obj->dev;
> @@ -394,7 +395,7 @@ static int drm_gem_dmabuf_mmap(struct dma_buf *dma_buf,
>  	if (!dev->driver->gem_prime_mmap)
>  		return -ENOSYS;
>  
> -	return dev->driver->gem_prime_mmap(obj, vma);
> +	return dev->driver->gem_prime_mmap(obj, vma, map_flags);
>  }
>  
>  static const struct dma_buf_ops drm_gem_prime_dmabuf_ops =  {
> diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
> index 2660543ad86a..b57d75a540c0 100644
> --- a/drivers/gpu/drm/drm_vm.c
> +++ b/drivers/gpu/drm/drm_vm.c
> @@ -629,7 +629,8 @@ static int drm_mmap_locked(struct file *filp, struct vm_area_struct *vma)
>  	return 0;
>  }
>  
> -int drm_legacy_mmap(struct file *filp, struct vm_area_struct *vma)
> +int drm_legacy_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct drm_file *priv = filp->private_data;
>  	struct drm_device *dev = priv->minor->dev;
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_drv.h b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
> index 058389f93b69..7b62e5238cf6 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_drv.h
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
> @@ -72,14 +72,16 @@ static inline void etnaviv_queue_work(struct drm_device *dev,
>  int etnaviv_ioctl_gem_submit(struct drm_device *dev, void *data,
>  		struct drm_file *file);
>  
> -int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> +int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags);
>  int etnaviv_gem_fault(struct vm_fault *vmf);
>  int etnaviv_gem_mmap_offset(struct drm_gem_object *obj, u64 *offset);
>  struct sg_table *etnaviv_gem_prime_get_sg_table(struct drm_gem_object *obj);
>  void *etnaviv_gem_prime_vmap(struct drm_gem_object *obj);
>  void etnaviv_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
>  int etnaviv_gem_prime_mmap(struct drm_gem_object *obj,
> -			   struct vm_area_struct *vma);
> +			   struct vm_area_struct *vma,
> +			   unsigned long map_flags);
>  struct reservation_object *etnaviv_gem_prime_res_obj(struct drm_gem_object *obj);
>  struct drm_gem_object *etnaviv_gem_prime_import_sg_table(struct drm_device *dev,
>  	struct dma_buf_attachment *attach, struct sg_table *sg);
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> index 5a634594a6ce..a50093045008 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
> @@ -132,7 +132,7 @@ void etnaviv_gem_put_pages(struct etnaviv_gem_object *etnaviv_obj)
>  }
>  
>  static int etnaviv_gem_mmap_obj(struct etnaviv_gem_object *etnaviv_obj,
> -		struct vm_area_struct *vma)
> +		struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	pgprot_t vm_page_prot;
>  
> @@ -162,19 +162,20 @@ static int etnaviv_gem_mmap_obj(struct etnaviv_gem_object *etnaviv_obj,
>  	return 0;
>  }
>  
> -int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma)
> +int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct etnaviv_gem_object *obj;
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret) {
>  		DBG("mmap failed: %d", ret);
>  		return ret;
>  	}
>  
>  	obj = to_etnaviv_bo(vma->vm_private_data);
> -	return obj->ops->mmap(obj, vma);
> +	return obj->ops->mmap(obj, vma, map_flags);
>  }
>  
>  int etnaviv_gem_fault(struct vm_fault *vmf)
> @@ -890,7 +891,7 @@ static void etnaviv_gem_userptr_release(struct etnaviv_gem_object *etnaviv_obj)
>  }
>  
>  static int etnaviv_gem_userptr_mmap_obj(struct etnaviv_gem_object *etnaviv_obj,
> -		struct vm_area_struct *vma)
> +		struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	return -EINVAL;
>  }
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.h b/drivers/gpu/drm/etnaviv/etnaviv_gem.h
> index e437fba1209d..5bbde7a1318b 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_gem.h
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.h
> @@ -80,7 +80,8 @@ struct etnaviv_gem_ops {
>  	int (*get_pages)(struct etnaviv_gem_object *);
>  	void (*release)(struct etnaviv_gem_object *);
>  	void *(*vmap)(struct etnaviv_gem_object *);
> -	int (*mmap)(struct etnaviv_gem_object *, struct vm_area_struct *);
> +	int (*mmap)(struct etnaviv_gem_object *, struct vm_area_struct *,
> +			unsigned long map_flags);
>  };
>  
>  static inline bool is_active(struct etnaviv_gem_object *etnaviv_obj)
> diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c b/drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c
> index ae884723e9b1..0bd30b8f0c29 100644
> --- a/drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c
> +++ b/drivers/gpu/drm/etnaviv/etnaviv_gem_prime.c
> @@ -42,7 +42,8 @@ void etnaviv_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr)
>  }
>  
>  int etnaviv_gem_prime_mmap(struct drm_gem_object *obj,
> -			   struct vm_area_struct *vma)
> +			   struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	struct etnaviv_gem_object *etnaviv_obj = to_etnaviv_bo(obj);
>  	int ret;
> @@ -51,7 +52,7 @@ int etnaviv_gem_prime_mmap(struct drm_gem_object *obj,
>  	if (ret < 0)
>  		return ret;
>  
> -	return etnaviv_obj->ops->mmap(etnaviv_obj, vma);
> +	return etnaviv_obj->ops->mmap(etnaviv_obj, vma, map_flags);
>  }
>  
>  int etnaviv_gem_prime_pin(struct drm_gem_object *obj)
> @@ -100,9 +101,9 @@ static void *etnaviv_gem_prime_vmap_impl(struct etnaviv_gem_object *etnaviv_obj)
>  }
>  
>  static int etnaviv_gem_prime_mmap_obj(struct etnaviv_gem_object *etnaviv_obj,
> -		struct vm_area_struct *vma)
> +		struct vm_area_struct *vma, unsigned long map_flags)
>  {
> -	return dma_buf_mmap(etnaviv_obj->base.dma_buf, vma, 0);
> +	return dma_buf_mmap(etnaviv_obj->base.dma_buf, vma, 0, map_flags);
>  }
>  
>  static const struct etnaviv_gem_ops etnaviv_gem_prime_ops = {
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_fbdev.c b/drivers/gpu/drm/exynos/exynos_drm_fbdev.c
> index c3a068409b48..96a00250f275 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_fbdev.c
> +++ b/drivers/gpu/drm/exynos/exynos_drm_fbdev.c
> @@ -35,7 +35,7 @@ struct exynos_drm_fbdev {
>  };
>  
>  static int exynos_drm_fb_mmap(struct fb_info *info,
> -			struct vm_area_struct *vma)
> +			struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	struct drm_fb_helper *helper = info->par;
>  	struct exynos_drm_fbdev *exynos_fbd = to_exynos_fbdev(helper);
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
> index 077de014d610..8e68deacf506 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
> +++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
> @@ -485,13 +485,14 @@ static int exynos_drm_gem_mmap_obj(struct drm_gem_object *obj,
>  	return ret;
>  }
>  
> -int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
> +int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	struct drm_gem_object *obj;
>  	int ret;
>  
>  	/* set vm_area_struct. */
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret < 0) {
>  		DRM_ERROR("failed to mmap.\n");
>  		return ret;
> @@ -500,7 +501,7 @@ int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
>  	obj = vma->vm_private_data;
>  
>  	if (obj->import_attach)
> -		return dma_buf_mmap(obj->dma_buf, vma, 0);
> +		return dma_buf_mmap(obj->dma_buf, vma, 0, map_flags);
>  
>  	return exynos_drm_gem_mmap_obj(obj, vma);
>  }
> @@ -581,7 +582,8 @@ void exynos_drm_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr)
>  }
>  
>  int exynos_drm_gem_prime_mmap(struct drm_gem_object *obj,
> -			      struct vm_area_struct *vma)
> +			      struct vm_area_struct *vma,
> +			      unsigned long map_flags)
>  {
>  	int ret;
>  
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.h b/drivers/gpu/drm/exynos/exynos_drm_gem.h
> index e86d1a9518c3..d3aacac9da86 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_gem.h
> +++ b/drivers/gpu/drm/exynos/exynos_drm_gem.h
> @@ -114,7 +114,8 @@ int exynos_drm_gem_dumb_create(struct drm_file *file_priv,
>  int exynos_drm_gem_fault(struct vm_fault *vmf);
>  
>  /* set vm_flags and we can change the vm attribute to other one at here. */
> -int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> +int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +			unsigned long map_flags);
>  
>  /* low-level interface prime helpers */
>  struct sg_table *exynos_drm_gem_prime_get_sg_table(struct drm_gem_object *obj);
> @@ -125,6 +126,7 @@ exynos_drm_gem_prime_import_sg_table(struct drm_device *dev,
>  void *exynos_drm_gem_prime_vmap(struct drm_gem_object *obj);
>  void exynos_drm_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
>  int exynos_drm_gem_prime_mmap(struct drm_gem_object *obj,
> -			      struct vm_area_struct *vma);
> +			      struct vm_area_struct *vma,
> +			      unsigned long map_flags);
>  
>  #endif
> diff --git a/drivers/gpu/drm/gma500/framebuffer.c b/drivers/gpu/drm/gma500/framebuffer.c
> index 2570c7f647a6..06777f46324e 100644
> --- a/drivers/gpu/drm/gma500/framebuffer.c
> +++ b/drivers/gpu/drm/gma500/framebuffer.c
> @@ -161,7 +161,8 @@ static const struct vm_operations_struct psbfb_vm_ops = {
>  	.close	= psbfb_vm_close
>  };
>  
> -static int psbfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int psbfb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	struct psb_fbdev *fbdev = info->par;
>  	struct psb_framebuffer *psbfb = &fbdev->pfb;
> diff --git a/drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h b/drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h
> index e195521eb41e..e876e74348ae 100644
> --- a/drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h
> +++ b/drivers/gpu/drm/hisilicon/hibmc/hibmc_drm_drv.h
> @@ -107,7 +107,8 @@ int hibmc_dumb_create(struct drm_file *file, struct drm_device *dev,
>  		      struct drm_mode_create_dumb *args);
>  int hibmc_dumb_mmap_offset(struct drm_file *file, struct drm_device *dev,
>  			   u32 handle, u64 *offset);
> -int hibmc_mmap(struct file *filp, struct vm_area_struct *vma);
> +int hibmc_mmap(struct file *filp, struct vm_area_struct *vma,
> +	       unsigned long map_flags);
>  
>  extern const struct drm_mode_config_funcs hibmc_mode_funcs;
>  
> diff --git a/drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c b/drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c
> index 3518167a7dc4..c9a92ce598b3 100644
> --- a/drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c
> +++ b/drivers/gpu/drm/hisilicon/hibmc/hibmc_ttm.c
> @@ -389,7 +389,8 @@ int hibmc_bo_unpin(struct hibmc_bo *bo)
>  	return 0;
>  }
>  
> -int hibmc_mmap(struct file *filp, struct vm_area_struct *vma)
> +int hibmc_mmap(struct file *filp, struct vm_area_struct *vma,
> +	       unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct hibmc_drm_private *hibmc;
> diff --git a/drivers/gpu/drm/i810/i810_dma.c b/drivers/gpu/drm/i810/i810_dma.c
> index 576a417690d4..c7ff2e7072ca 100644
> --- a/drivers/gpu/drm/i810/i810_dma.c
> +++ b/drivers/gpu/drm/i810/i810_dma.c
> @@ -84,7 +84,8 @@ static int i810_freelist_put(struct drm_device *dev, struct drm_buf *buf)
>  	return 0;
>  }
>  
> -static int i810_mmap_buffers(struct file *filp, struct vm_area_struct *vma)
> +static int i810_mmap_buffers(struct file *filp, struct vm_area_struct *vma,
> +			     unsigned long map_flags)
>  {
>  	struct drm_file *priv = filp->private_data;
>  	struct drm_device *dev;
> diff --git a/drivers/gpu/drm/i915/i915_gem_dmabuf.c b/drivers/gpu/drm/i915/i915_gem_dmabuf.c
> index 6176e589cf09..98b07fd2db3c 100644
> --- a/drivers/gpu/drm/i915/i915_gem_dmabuf.c
> +++ b/drivers/gpu/drm/i915/i915_gem_dmabuf.c
> @@ -154,7 +154,9 @@ static void i915_gem_dmabuf_kunmap(struct dma_buf *dma_buf, unsigned long page_n
>  	i915_gem_object_unpin_pages(obj);
>  }
>  
> -static int i915_gem_dmabuf_mmap(struct dma_buf *dma_buf, struct vm_area_struct *vma)
> +static int i915_gem_dmabuf_mmap(struct dma_buf *dma_buf,
> +				struct vm_area_struct *vma,
> +				unsigned long map_flags)
>  {
>  	struct drm_i915_gem_object *obj = dma_buf_to_obj(dma_buf);
>  	int ret;
> @@ -165,7 +167,7 @@ static int i915_gem_dmabuf_mmap(struct dma_buf *dma_buf, struct vm_area_struct *
>  	if (!obj->base.filp)
>  		return -ENODEV;
>  
> -	ret = call_mmap(obj->base.filp, vma);
> +	ret = call_mmap(obj->base.filp, vma, map_flags);
>  	if (ret)
>  		return ret;
>  
> diff --git a/drivers/gpu/drm/i915/selftests/mock_dmabuf.c b/drivers/gpu/drm/i915/selftests/mock_dmabuf.c
> index 302f7d103635..20f2d4bb4172 100644
> --- a/drivers/gpu/drm/i915/selftests/mock_dmabuf.c
> +++ b/drivers/gpu/drm/i915/selftests/mock_dmabuf.c
> @@ -120,7 +120,9 @@ static void mock_dmabuf_kunmap(struct dma_buf *dma_buf, unsigned long page_num,
>  	return kunmap(mock->pages[page_num]);
>  }
>  
> -static int mock_dmabuf_mmap(struct dma_buf *dma_buf, struct vm_area_struct *vma)
> +static int mock_dmabuf_mmap(struct dma_buf *dma_buf,
> +			    struct vm_area_struct *vma,
> +			    unsigned long map_flags)
>  {
>  	return -ENODEV;
>  }
> diff --git a/drivers/gpu/drm/mediatek/mtk_drm_gem.c b/drivers/gpu/drm/mediatek/mtk_drm_gem.c
> index f595ac816b55..da6e7e72c7ce 100644
> --- a/drivers/gpu/drm/mediatek/mtk_drm_gem.c
> +++ b/drivers/gpu/drm/mediatek/mtk_drm_gem.c
> @@ -154,7 +154,8 @@ static int mtk_drm_gem_object_mmap(struct drm_gem_object *obj,
>  	return ret;
>  }
>  
> -int mtk_drm_gem_mmap_buf(struct drm_gem_object *obj, struct vm_area_struct *vma)
> +int mtk_drm_gem_mmap_buf(struct drm_gem_object *obj,
> +			 struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	int ret;
>  
> @@ -165,12 +166,13 @@ int mtk_drm_gem_mmap_buf(struct drm_gem_object *obj, struct vm_area_struct *vma)
>  	return mtk_drm_gem_object_mmap(obj, vma);
>  }
>  
> -int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
> +int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct drm_gem_object *obj;
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret)
>  		return ret;
>  
> diff --git a/drivers/gpu/drm/mediatek/mtk_drm_gem.h b/drivers/gpu/drm/mediatek/mtk_drm_gem.h
> index 534639b43a1c..c11f89869fd2 100644
> --- a/drivers/gpu/drm/mediatek/mtk_drm_gem.h
> +++ b/drivers/gpu/drm/mediatek/mtk_drm_gem.h
> @@ -46,9 +46,10 @@ struct mtk_drm_gem_obj *mtk_drm_gem_create(struct drm_device *dev, size_t size,
>  					   bool alloc_kmap);
>  int mtk_drm_gem_dumb_create(struct drm_file *file_priv, struct drm_device *dev,
>  			    struct drm_mode_create_dumb *args);
> -int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> +int mtk_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags);
>  int mtk_drm_gem_mmap_buf(struct drm_gem_object *obj,
> -			 struct vm_area_struct *vma);
> +			 struct vm_area_struct *vma, unsigned long map_flags);
>  struct sg_table *mtk_gem_prime_get_sg_table(struct drm_gem_object *obj);
>  struct drm_gem_object *mtk_gem_prime_import_sg_table(struct drm_device *dev,
>  			struct dma_buf_attachment *attach, struct sg_table *sg);
> diff --git a/drivers/gpu/drm/mgag200/mgag200_drv.h b/drivers/gpu/drm/mgag200/mgag200_drv.h
> index 04f1dfba12e5..f014b31d1885 100644
> --- a/drivers/gpu/drm/mgag200/mgag200_drv.h
> +++ b/drivers/gpu/drm/mgag200/mgag200_drv.h
> @@ -296,7 +296,8 @@ int mgag200_bo_create(struct drm_device *dev, int size, int align,
>  		      uint32_t flags, struct mgag200_bo **pastbo);
>  int mgag200_mm_init(struct mga_device *mdev);
>  void mgag200_mm_fini(struct mga_device *mdev);
> -int mgag200_mmap(struct file *filp, struct vm_area_struct *vma);
> +int mgag200_mmap(struct file *filp, struct vm_area_struct *vma,
> +		 unsigned long map_flags);
>  int mgag200_bo_pin(struct mgag200_bo *bo, u32 pl_flag, u64 *gpu_addr);
>  int mgag200_bo_unpin(struct mgag200_bo *bo);
>  int mgag200_bo_push_sysram(struct mgag200_bo *bo);
> diff --git a/drivers/gpu/drm/mgag200/mgag200_ttm.c b/drivers/gpu/drm/mgag200/mgag200_ttm.c
> index 3e7e1cd31395..1f1964e54b0c 100644
> --- a/drivers/gpu/drm/mgag200/mgag200_ttm.c
> +++ b/drivers/gpu/drm/mgag200/mgag200_ttm.c
> @@ -418,7 +418,8 @@ int mgag200_bo_push_sysram(struct mgag200_bo *bo)
>  	return 0;
>  }
>  
> -int mgag200_mmap(struct file *filp, struct vm_area_struct *vma)
> +int mgag200_mmap(struct file *filp, struct vm_area_struct *vma,
> +		 unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct mga_device *mdev;
> diff --git a/drivers/gpu/drm/msm/msm_drv.h b/drivers/gpu/drm/msm/msm_drv.h
> index 5e8109c07560..7b35fa953091 100644
> --- a/drivers/gpu/drm/msm/msm_drv.h
> +++ b/drivers/gpu/drm/msm/msm_drv.h
> @@ -194,7 +194,8 @@ void msm_gem_shrinker_cleanup(struct drm_device *dev);
>  
>  int msm_gem_mmap_obj(struct drm_gem_object *obj,
>  			struct vm_area_struct *vma);
> -int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> +int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		 unsigned long map_flags);
>  int msm_gem_fault(struct vm_fault *vmf);
>  uint64_t msm_gem_mmap_offset(struct drm_gem_object *obj);
>  int msm_gem_get_iova(struct drm_gem_object *obj,
> @@ -212,7 +213,8 @@ int msm_gem_dumb_map_offset(struct drm_file *file, struct drm_device *dev,
>  struct sg_table *msm_gem_prime_get_sg_table(struct drm_gem_object *obj);
>  void *msm_gem_prime_vmap(struct drm_gem_object *obj);
>  void msm_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
> -int msm_gem_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma);
> +int msm_gem_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma,
> +		       unsigned long map_flags);
>  struct reservation_object *msm_gem_prime_res_obj(struct drm_gem_object *obj);
>  struct drm_gem_object *msm_gem_prime_import_sg_table(struct drm_device *dev,
>  		struct dma_buf_attachment *attach, struct sg_table *sg);
> diff --git a/drivers/gpu/drm/msm/msm_fbdev.c b/drivers/gpu/drm/msm/msm_fbdev.c
> index c178563fcd4d..38787f483a8d 100644
> --- a/drivers/gpu/drm/msm/msm_fbdev.c
> +++ b/drivers/gpu/drm/msm/msm_fbdev.c
> @@ -23,7 +23,8 @@
>  
>  extern int msm_gem_mmap_obj(struct drm_gem_object *obj,
>  					struct vm_area_struct *vma);
> -static int msm_fbdev_mmap(struct fb_info *info, struct vm_area_struct *vma);
> +static int msm_fbdev_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			  unsigned long map_flags);
>  
>  /*
>   * fbdev funcs, to implement legacy fbdev interface on top of drm driver
> @@ -51,7 +52,8 @@ static struct fb_ops msm_fb_ops = {
>  	.fb_mmap = msm_fbdev_mmap,
>  };
>  
> -static int msm_fbdev_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int msm_fbdev_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct drm_fb_helper *helper = (struct drm_fb_helper *)info->par;
>  	struct msm_fbdev *fbdev = to_msm_fbdev(helper);
> diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
> index f15821a0d900..d77cfd169f91 100644
> --- a/drivers/gpu/drm/msm/msm_gem.c
> +++ b/drivers/gpu/drm/msm/msm_gem.c
> @@ -198,11 +198,12 @@ int msm_gem_mmap_obj(struct drm_gem_object *obj,
>  	return 0;
>  }
>  
> -int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
> +int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		 unsigned long map_flags)
>  {
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret) {
>  		DBG("mmap failed: %d", ret);
>  		return ret;
> diff --git a/drivers/gpu/drm/msm/msm_gem_prime.c b/drivers/gpu/drm/msm/msm_gem_prime.c
> index 13403c6da6c7..23a3c45be7a0 100644
> --- a/drivers/gpu/drm/msm/msm_gem_prime.c
> +++ b/drivers/gpu/drm/msm/msm_gem_prime.c
> @@ -41,7 +41,8 @@ void msm_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr)
>  	msm_gem_put_vaddr(obj);
>  }
>  
> -int msm_gem_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma)
> +int msm_gem_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	int ret;
>  
> diff --git a/drivers/gpu/drm/nouveau/nouveau_ttm.c b/drivers/gpu/drm/nouveau/nouveau_ttm.c
> index b0ad7fcefcf5..61c8f3a8a33b 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_ttm.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_ttm.c
> @@ -267,13 +267,14 @@ const struct ttm_mem_type_manager_func nv04_gart_manager = {
>  };
>  
>  int
> -nouveau_ttm_mmap(struct file *filp, struct vm_area_struct *vma)
> +nouveau_ttm_mmap(struct file *filp, struct vm_area_struct *vma,
> +		 unsigned long map_flags)
>  {
>  	struct drm_file *file_priv = filp->private_data;
>  	struct nouveau_drm *drm = nouveau_drm(file_priv->minor->dev);
>  
>  	if (unlikely(vma->vm_pgoff < DRM_FILE_PAGE_OFFSET))
> -		return drm_legacy_mmap(filp, vma);
> +		return drm_legacy_mmap(filp, vma, map_flags);
>  
>  	return ttm_bo_mmap(filp, vma, &drm->ttm.bdev);
>  }
> diff --git a/drivers/gpu/drm/nouveau/nouveau_ttm.h b/drivers/gpu/drm/nouveau/nouveau_ttm.h
> index 25b0de413352..9a1d08adae8a 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_ttm.h
> +++ b/drivers/gpu/drm/nouveau/nouveau_ttm.h
> @@ -17,7 +17,7 @@ struct ttm_tt *nouveau_sgdma_create_ttm(struct ttm_bo_device *,
>  
>  int  nouveau_ttm_init(struct nouveau_drm *drm);
>  void nouveau_ttm_fini(struct nouveau_drm *drm);
> -int  nouveau_ttm_mmap(struct file *, struct vm_area_struct *);
> +int  nouveau_ttm_mmap(struct file *, struct vm_area_struct *, unsigned long);
>  
>  int  nouveau_ttm_global_init(struct nouveau_drm *);
>  void nouveau_ttm_global_release(struct nouveau_drm *);
> diff --git a/drivers/gpu/drm/omapdrm/omap_drv.h b/drivers/gpu/drm/omapdrm/omap_drv.h
> index 4bd1e9070b31..f6be59d20781 100644
> --- a/drivers/gpu/drm/omapdrm/omap_drv.h
> +++ b/drivers/gpu/drm/omapdrm/omap_drv.h
> @@ -168,7 +168,8 @@ int omap_gem_dumb_map_offset(struct drm_file *file, struct drm_device *dev,
>  		uint32_t handle, uint64_t *offset);
>  int omap_gem_dumb_create(struct drm_file *file, struct drm_device *dev,
>  		struct drm_mode_create_dumb *args);
> -int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> +int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		  unsigned long map_flags);
>  int omap_gem_mmap_obj(struct drm_gem_object *obj,
>  		struct vm_area_struct *vma);
>  int omap_gem_fault(struct vm_fault *vmf);
> diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
> index 5c5c86ddd6f4..22538ab2fbc8 100644
> --- a/drivers/gpu/drm/omapdrm/omap_gem.c
> +++ b/drivers/gpu/drm/omapdrm/omap_gem.c
> @@ -561,11 +561,12 @@ int omap_gem_fault(struct vm_fault *vmf)
>  }
>  
>  /** We override mainly to fix up some of the vm mapping flags.. */
> -int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma)
> +int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		  unsigned long map_flags)
>  {
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret) {
>  		DBG("mmap failed: %d", ret);
>  		return ret;
> diff --git a/drivers/gpu/drm/omapdrm/omap_gem_dmabuf.c b/drivers/gpu/drm/omapdrm/omap_gem_dmabuf.c
> index afdbad5c866a..287bbdcf5208 100644
> --- a/drivers/gpu/drm/omapdrm/omap_gem_dmabuf.c
> +++ b/drivers/gpu/drm/omapdrm/omap_gem_dmabuf.c
> @@ -132,7 +132,7 @@ static void omap_gem_dmabuf_kunmap(struct dma_buf *buffer,
>  }
>  
>  static int omap_gem_dmabuf_mmap(struct dma_buf *buffer,
> -		struct vm_area_struct *vma)
> +		struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	struct drm_gem_object *obj = buffer->priv;
>  	int ret = 0;
> diff --git a/drivers/gpu/drm/qxl/qxl_drv.h b/drivers/gpu/drm/qxl/qxl_drv.h
> index 3397a1907336..f81d73b32773 100644
> --- a/drivers/gpu/drm/qxl/qxl_drv.h
> +++ b/drivers/gpu/drm/qxl/qxl_drv.h
> @@ -422,7 +422,8 @@ int qxl_mode_dumb_mmap(struct drm_file *filp,
>  /* qxl ttm */
>  int qxl_ttm_init(struct qxl_device *qdev);
>  void qxl_ttm_fini(struct qxl_device *qdev);
> -int qxl_mmap(struct file *filp, struct vm_area_struct *vma);
> +int qxl_mmap(struct file *filp, struct vm_area_struct *vma,
> +	     unsigned long map_flags);
>  
>  /* qxl image */
>  
> @@ -531,7 +532,8 @@ struct drm_gem_object *qxl_gem_prime_import_sg_table(
>  void *qxl_gem_prime_vmap(struct drm_gem_object *obj);
>  void qxl_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
>  int qxl_gem_prime_mmap(struct drm_gem_object *obj,
> -				struct vm_area_struct *vma);
> +				struct vm_area_struct *vma,
> +				unsigned long map_flags);
>  
>  /* qxl_irq.c */
>  int qxl_irq_init(struct qxl_device *qdev);
> diff --git a/drivers/gpu/drm/qxl/qxl_prime.c b/drivers/gpu/drm/qxl/qxl_prime.c
> index 9f029dda1f07..bc20b2c5fc66 100644
> --- a/drivers/gpu/drm/qxl/qxl_prime.c
> +++ b/drivers/gpu/drm/qxl/qxl_prime.c
> @@ -65,7 +65,7 @@ void qxl_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr)
>  }
>  
>  int qxl_gem_prime_mmap(struct drm_gem_object *obj,
> -		       struct vm_area_struct *area)
> +		       struct vm_area_struct *area, unsigned long map_flags)
>  {
>  	WARN_ONCE(1, "not implemented");
>  	return -ENOSYS;
> diff --git a/drivers/gpu/drm/qxl/qxl_ttm.c b/drivers/gpu/drm/qxl/qxl_ttm.c
> index 7ecf8a4b9fe6..598daf8658c2 100644
> --- a/drivers/gpu/drm/qxl/qxl_ttm.c
> +++ b/drivers/gpu/drm/qxl/qxl_ttm.c
> @@ -117,7 +117,8 @@ static int qxl_ttm_fault(struct vm_fault *vmf)
>  	return r;
>  }
>  
> -int qxl_mmap(struct file *filp, struct vm_area_struct *vma)
> +int qxl_mmap(struct file *filp, struct vm_area_struct *vma,
> +	     unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct qxl_device *qdev;
> diff --git a/drivers/gpu/drm/radeon/radeon_drv.c b/drivers/gpu/drm/radeon/radeon_drv.c
> index f4becad0a78c..b71098cbd3d4 100644
> --- a/drivers/gpu/drm/radeon/radeon_drv.c
> +++ b/drivers/gpu/drm/radeon/radeon_drv.c
> @@ -135,7 +135,8 @@ extern int radeon_get_crtc_scanoutpos(struct drm_device *dev, unsigned int crtc,
>  extern bool radeon_is_px(struct drm_device *dev);
>  extern const struct drm_ioctl_desc radeon_ioctls_kms[];
>  extern int radeon_max_kms_ioctl;
> -int radeon_mmap(struct file *filp, struct vm_area_struct *vma);
> +int radeon_mmap(struct file *filp, struct vm_area_struct *vma,
> +		unsigned long map_flags);
>  int radeon_mode_dumb_mmap(struct drm_file *filp,
>  			  struct drm_device *dev,
>  			  uint32_t handle, uint64_t *offset_p);
> diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
> index bf69bf9086bf..0253fb650012 100644
> --- a/drivers/gpu/drm/radeon/radeon_ttm.c
> +++ b/drivers/gpu/drm/radeon/radeon_ttm.c
> @@ -997,7 +997,8 @@ static int radeon_ttm_fault(struct vm_fault *vmf)
>  	return r;
>  }
>  
> -int radeon_mmap(struct file *filp, struct vm_area_struct *vma)
> +int radeon_mmap(struct file *filp, struct vm_area_struct *vma,
> +		unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct radeon_device *rdev;
> diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_fbdev.c b/drivers/gpu/drm/rockchip/rockchip_drm_fbdev.c
> index 724579ebf947..bf49db60cc16 100644
> --- a/drivers/gpu/drm/rockchip/rockchip_drm_fbdev.c
> +++ b/drivers/gpu/drm/rockchip/rockchip_drm_fbdev.c
> @@ -27,12 +27,13 @@
>  		container_of(x, struct rockchip_drm_private, fbdev_helper)
>  
>  static int rockchip_fbdev_mmap(struct fb_info *info,
> -			       struct vm_area_struct *vma)
> +			       struct vm_area_struct *vma,
> +			       unsigned long map_flags)
>  {
>  	struct drm_fb_helper *helper = info->par;
>  	struct rockchip_drm_private *private = to_drm_private(helper);
>  
> -	return rockchip_gem_mmap_buf(private->fbdev_bo, vma);
> +	return rockchip_gem_mmap_buf(private->fbdev_bo, vma, map_flags);
>  }
>  
>  static struct fb_ops rockchip_drm_fbdev_ops = {
> diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> index 1869c8bb76c8..18dc047909bf 100644
> --- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> +++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> @@ -276,7 +276,7 @@ static int rockchip_drm_gem_object_mmap(struct drm_gem_object *obj,
>  }
>  
>  int rockchip_gem_mmap_buf(struct drm_gem_object *obj,
> -			  struct vm_area_struct *vma)
> +			  struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	int ret;
>  
> @@ -288,12 +288,13 @@ int rockchip_gem_mmap_buf(struct drm_gem_object *obj,
>  }
>  
>  /* drm driver mmap file operations */
> -int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma)
> +int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	struct drm_gem_object *obj;
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret)
>  		return ret;
>  
> diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.h b/drivers/gpu/drm/rockchip/rockchip_drm_gem.h
> index f237375582fb..47fa81a9c338 100644
> --- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.h
> +++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.h
> @@ -42,11 +42,12 @@ void *rockchip_gem_prime_vmap(struct drm_gem_object *obj);
>  void rockchip_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
>  
>  /* drm driver mmap file operations */
> -int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> +int rockchip_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		      unsigned long map_flags);
>  
>  /* mmap a gem object to userspace. */
>  int rockchip_gem_mmap_buf(struct drm_gem_object *obj,
> -			  struct vm_area_struct *vma);
> +			  struct vm_area_struct *vma, unsigned long map_flags);
>  
>  struct rockchip_gem_object *
>  	rockchip_gem_create_object(struct drm_device *drm, unsigned int size,
> diff --git a/drivers/gpu/drm/tegra/gem.c b/drivers/gpu/drm/tegra/gem.c
> index ab1e53d434e8..f89044f30a7b 100644
> --- a/drivers/gpu/drm/tegra/gem.c
> +++ b/drivers/gpu/drm/tegra/gem.c
> @@ -497,12 +497,13 @@ static int tegra_gem_mmap(struct drm_gem_object *gem,
>  	return 0;
>  }
>  
> -int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma)
> +int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma,
> +		   unsigned long map_flags)
>  {
>  	struct drm_gem_object *gem;
>  	int err;
>  
> -	err = drm_gem_mmap(file, vma);
> +	err = drm_gem_mmap(file, vma, map_flags);
>  	if (err < 0)
>  		return err;
>  
> @@ -592,7 +593,9 @@ static void tegra_gem_prime_kunmap(struct dma_buf *buf, unsigned long page,
>  {
>  }
>  
> -static int tegra_gem_prime_mmap(struct dma_buf *buf, struct vm_area_struct *vma)
> +static int tegra_gem_prime_mmap(struct dma_buf *buf,
> +				struct vm_area_struct *vma,
> +				unsigned long map_flags)
>  {
>  	struct drm_gem_object *gem = buf->priv;
>  	int err;
> diff --git a/drivers/gpu/drm/tegra/gem.h b/drivers/gpu/drm/tegra/gem.h
> index 8eb9fd24ef0e..b50c3deba7d0 100644
> --- a/drivers/gpu/drm/tegra/gem.h
> +++ b/drivers/gpu/drm/tegra/gem.h
> @@ -68,7 +68,8 @@ void tegra_bo_free_object(struct drm_gem_object *gem);
>  int tegra_bo_dumb_create(struct drm_file *file, struct drm_device *drm,
>  			 struct drm_mode_create_dumb *args);
>  
> -int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma);
> +int tegra_drm_mmap(struct file *file, struct vm_area_struct *vma,
> +		   unsigned long map_flags);
>  
>  extern const struct vm_operations_struct tegra_bo_vm_ops;
>  
> diff --git a/drivers/gpu/drm/udl/udl_dmabuf.c b/drivers/gpu/drm/udl/udl_dmabuf.c
> index 2867ed155ff6..e2dc5f9dd788 100644
> --- a/drivers/gpu/drm/udl/udl_dmabuf.c
> +++ b/drivers/gpu/drm/udl/udl_dmabuf.c
> @@ -179,7 +179,8 @@ static void udl_dmabuf_kunmap_atomic(struct dma_buf *dma_buf,
>  }
>  
>  static int udl_dmabuf_mmap(struct dma_buf *dma_buf,
> -			   struct vm_area_struct *vma)
> +			   struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	/* TODO */
>  
> diff --git a/drivers/gpu/drm/udl/udl_drv.h b/drivers/gpu/drm/udl/udl_drv.h
> index 2a75ab80527a..3faab1a52dad 100644
> --- a/drivers/gpu/drm/udl/udl_drv.h
> +++ b/drivers/gpu/drm/udl/udl_drv.h
> @@ -133,7 +133,8 @@ int udl_gem_get_pages(struct udl_gem_object *obj);
>  void udl_gem_put_pages(struct udl_gem_object *obj);
>  int udl_gem_vmap(struct udl_gem_object *obj);
>  void udl_gem_vunmap(struct udl_gem_object *obj);
> -int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> +int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags);
>  int udl_gem_fault(struct vm_fault *vmf);
>  
>  int udl_handle_damage(struct udl_framebuffer *fb, int x, int y,
> diff --git a/drivers/gpu/drm/udl/udl_fb.c b/drivers/gpu/drm/udl/udl_fb.c
> index b5b335c9b2bb..6edbbac4c96c 100644
> --- a/drivers/gpu/drm/udl/udl_fb.c
> +++ b/drivers/gpu/drm/udl/udl_fb.c
> @@ -155,7 +155,8 @@ int udl_handle_damage(struct udl_framebuffer *fb, int x, int y,
>  	return 0;
>  }
>  
> -static int udl_fb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int udl_fb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	unsigned long start = vma->vm_start;
>  	unsigned long size = vma->vm_end - vma->vm_start;
> diff --git a/drivers/gpu/drm/udl/udl_gem.c b/drivers/gpu/drm/udl/udl_gem.c
> index dee6bd9a3dd1..3dea34f6850d 100644
> --- a/drivers/gpu/drm/udl/udl_gem.c
> +++ b/drivers/gpu/drm/udl/udl_gem.c
> @@ -84,11 +84,12 @@ int udl_dumb_create(struct drm_file *file,
>  			      args->size, &args->handle);
>  }
>  
> -int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
> +int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret)
>  		return ret;
>  
> diff --git a/drivers/gpu/drm/vc4/vc4_bo.c b/drivers/gpu/drm/vc4/vc4_bo.c
> index 3afdbf4bc10b..9695e0a0feb9 100644
> --- a/drivers/gpu/drm/vc4/vc4_bo.c
> +++ b/drivers/gpu/drm/vc4/vc4_bo.c
> @@ -489,13 +489,14 @@ vc4_prime_export(struct drm_device *dev, struct drm_gem_object *obj, int flags)
>  	return drm_gem_prime_export(dev, obj, flags);
>  }
>  
> -int vc4_mmap(struct file *filp, struct vm_area_struct *vma)
> +int vc4_mmap(struct file *filp, struct vm_area_struct *vma,
> +	     unsigned long map_flags)
>  {
>  	struct drm_gem_object *gem_obj;
>  	struct vc4_bo *bo;
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret)
>  		return ret;
>  
> @@ -523,7 +524,8 @@ int vc4_mmap(struct file *filp, struct vm_area_struct *vma)
>  	return ret;
>  }
>  
> -int vc4_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma)
> +int vc4_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma,
> +		   unsigned long map_flags)
>  {
>  	struct vc4_bo *bo = to_vc4_bo(obj);
>  
> @@ -532,7 +534,7 @@ int vc4_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma)
>  		return -EINVAL;
>  	}
>  
> -	return drm_gem_cma_prime_mmap(obj, vma);
> +	return drm_gem_cma_prime_mmap(obj, vma, map_flags);
>  }
>  
>  void *vc4_prime_vmap(struct drm_gem_object *obj)
> diff --git a/drivers/gpu/drm/vc4/vc4_drv.h b/drivers/gpu/drm/vc4/vc4_drv.h
> index 87f2d8e5c134..5c01bad51c7e 100644
> --- a/drivers/gpu/drm/vc4/vc4_drv.h
> +++ b/drivers/gpu/drm/vc4/vc4_drv.h
> @@ -503,9 +503,11 @@ int vc4_get_hang_state_ioctl(struct drm_device *dev, void *data,
>  			     struct drm_file *file_priv);
>  int vc4_label_bo_ioctl(struct drm_device *dev, void *data,
>  		       struct drm_file *file_priv);
> -int vc4_mmap(struct file *filp, struct vm_area_struct *vma);
> +int vc4_mmap(struct file *filp, struct vm_area_struct *vma,
> +	     unsigned long map_flags);
>  struct reservation_object *vc4_prime_res_obj(struct drm_gem_object *obj);
> -int vc4_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma);
> +int vc4_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma,
> +		   unsigned long map_flags);
>  struct drm_gem_object *vc4_prime_import_sg_table(struct drm_device *dev,
>  						 struct dma_buf_attachment *attach,
>  						 struct sg_table *sgt);
> diff --git a/drivers/gpu/drm/vgem/vgem_drv.c b/drivers/gpu/drm/vgem/vgem_drv.c
> index 2524ff116f00..208c7781adbe 100644
> --- a/drivers/gpu/drm/vgem/vgem_drv.c
> +++ b/drivers/gpu/drm/vgem/vgem_drv.c
> @@ -255,12 +255,13 @@ static struct drm_ioctl_desc vgem_ioctls[] = {
>  	DRM_IOCTL_DEF_DRV(VGEM_FENCE_SIGNAL, vgem_fence_signal_ioctl, DRM_AUTH|DRM_RENDER_ALLOW),
>  };
>  
> -static int vgem_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int vgem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	unsigned long flags = vma->vm_flags;
>  	int ret;
>  
> -	ret = drm_gem_mmap(filp, vma);
> +	ret = drm_gem_mmap(filp, vma, map_flags);
>  	if (ret)
>  		return ret;
>  
> @@ -399,7 +400,8 @@ static void vgem_prime_vunmap(struct drm_gem_object *obj, void *vaddr)
>  }
>  
>  static int vgem_prime_mmap(struct drm_gem_object *obj,
> -			   struct vm_area_struct *vma)
> +			   struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	int ret;
>  
> @@ -409,7 +411,7 @@ static int vgem_prime_mmap(struct drm_gem_object *obj,
>  	if (!obj->filp)
>  		return -ENODEV;
>  
> -	ret = call_mmap(obj->filp, vma);
> +	ret = call_mmap(obj->filp, vma, map_flags);
>  	if (ret)
>  		return ret;
>  
> diff --git a/drivers/gpu/drm/virtio/virtgpu_drv.h b/drivers/gpu/drm/virtio/virtgpu_drv.h
> index da2fb585fea4..78c2e7e5457d 100644
> --- a/drivers/gpu/drm/virtio/virtgpu_drv.h
> +++ b/drivers/gpu/drm/virtio/virtgpu_drv.h
> @@ -339,7 +339,8 @@ struct drm_plane *virtio_gpu_plane_init(struct virtio_gpu_device *vgdev,
>  /* virtio_gpu_ttm.c */
>  int virtio_gpu_ttm_init(struct virtio_gpu_device *vgdev);
>  void virtio_gpu_ttm_fini(struct virtio_gpu_device *vgdev);
> -int virtio_gpu_mmap(struct file *filp, struct vm_area_struct *vma);
> +int virtio_gpu_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags);
>  
>  /* virtio_gpu_fence.c */
>  int virtio_gpu_fence_emit(struct virtio_gpu_device *vgdev,
> @@ -368,7 +369,8 @@ struct drm_gem_object *virtgpu_gem_prime_import_sg_table(
>  void *virtgpu_gem_prime_vmap(struct drm_gem_object *obj);
>  void virtgpu_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
>  int virtgpu_gem_prime_mmap(struct drm_gem_object *obj,
> -                                struct vm_area_struct *vma);
> +                                struct vm_area_struct *vma,
> +                                unsigned long map_flags);
>  
>  static inline struct virtio_gpu_object*
>  virtio_gpu_object_ref(struct virtio_gpu_object *bo)
> diff --git a/drivers/gpu/drm/virtio/virtgpu_prime.c b/drivers/gpu/drm/virtio/virtgpu_prime.c
> index 385e0eb9826a..713bbfddef98 100644
> --- a/drivers/gpu/drm/virtio/virtgpu_prime.c
> +++ b/drivers/gpu/drm/virtio/virtgpu_prime.c
> @@ -65,7 +65,7 @@ void virtgpu_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr)
>  }
>  
>  int virtgpu_gem_prime_mmap(struct drm_gem_object *obj,
> -		       struct vm_area_struct *area)
> +		       struct vm_area_struct *area, unsigned long map_flags)
>  {
>  	return -ENODEV;
>  }
> diff --git a/drivers/gpu/drm/virtio/virtgpu_ttm.c b/drivers/gpu/drm/virtio/virtgpu_ttm.c
> index cd389c5eaef5..20817a833e90 100644
> --- a/drivers/gpu/drm/virtio/virtgpu_ttm.c
> +++ b/drivers/gpu/drm/virtio/virtgpu_ttm.c
> @@ -129,7 +129,8 @@ static int virtio_gpu_ttm_fault(struct vm_fault *vmf)
>  }
>  #endif
>  
> -int virtio_gpu_mmap(struct file *filp, struct vm_area_struct *vma)
> +int virtio_gpu_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct virtio_gpu_device *vgdev;
> diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
> index 7e5f30e234b1..07a433bf7511 100644
> --- a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
> +++ b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
> @@ -748,7 +748,8 @@ extern int vmw_fifo_flush(struct vmw_private *dev_priv,
>  
>  extern int vmw_ttm_global_init(struct vmw_private *dev_priv);
>  extern void vmw_ttm_global_release(struct vmw_private *dev_priv);
> -extern int vmw_mmap(struct file *filp, struct vm_area_struct *vma);
> +extern int vmw_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags);
>  
>  /**
>   * TTM buffer object driver - vmwgfx_buffer.c
> diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_prime.c b/drivers/gpu/drm/vmwgfx/vmwgfx_prime.c
> index 0d42a46521fc..faa67d37a839 100644
> --- a/drivers/gpu/drm/vmwgfx/vmwgfx_prime.c
> +++ b/drivers/gpu/drm/vmwgfx/vmwgfx_prime.c
> @@ -96,7 +96,8 @@ static void vmw_prime_dmabuf_kunmap(struct dma_buf *dma_buf,
>  }
>  
>  static int vmw_prime_dmabuf_mmap(struct dma_buf *dma_buf,
> -				 struct vm_area_struct *vma)
> +				 struct vm_area_struct *vma,
> +				 unsigned long map_flags)
>  {
>  	WARN_ONCE(true, "Attempted use of dmabuf mmap. Bad.\n");
>  	return -ENOSYS;
> diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c b/drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c
> index e771091d2cd3..c62bdc337506 100644
> --- a/drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c
> +++ b/drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c
> @@ -28,7 +28,8 @@
>  #include <drm/drmP.h>
>  #include "vmwgfx_drv.h"
>  
> -int vmw_mmap(struct file *filp, struct vm_area_struct *vma)
> +int vmw_mmap(struct file *filp, struct vm_area_struct *vma,
> +	     unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct vmw_private *dev_priv;
> diff --git a/drivers/hsi/clients/cmt_speech.c b/drivers/hsi/clients/cmt_speech.c
> index 727f968ac1cb..507499044727 100644
> --- a/drivers/hsi/clients/cmt_speech.c
> +++ b/drivers/hsi/clients/cmt_speech.c
> @@ -1270,7 +1270,8 @@ static long cs_char_ioctl(struct file *file, unsigned int cmd,
>  	return r;
>  }
>  
> -static int cs_char_mmap(struct file *file, struct vm_area_struct *vma)
> +static int cs_char_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	if (vma->vm_end < vma->vm_start)
>  		return -EINVAL;
> diff --git a/drivers/hwtracing/intel_th/msu.c b/drivers/hwtracing/intel_th/msu.c
> index dfb57eaa9f22..d0803461b448 100644
> --- a/drivers/hwtracing/intel_th/msu.c
> +++ b/drivers/hwtracing/intel_th/msu.c
> @@ -1212,7 +1212,8 @@ static const struct vm_operations_struct msc_mmap_ops = {
>  	.fault	= msc_mmap_fault,
>  };
>  
> -static int intel_th_msc_mmap(struct file *file, struct vm_area_struct *vma)
> +static int intel_th_msc_mmap(struct file *file, struct vm_area_struct *vma,
> +			     unsigned long map_flags)
>  {
>  	unsigned long size = vma->vm_end - vma->vm_start;
>  	struct msc_iter *iter = vma->vm_file->private_data;
> diff --git a/drivers/hwtracing/stm/core.c b/drivers/hwtracing/stm/core.c
> index 9414900575d8..76a59eda527b 100644
> --- a/drivers/hwtracing/stm/core.c
> +++ b/drivers/hwtracing/stm/core.c
> @@ -519,7 +519,8 @@ static const struct vm_operations_struct stm_mmap_vmops = {
>  	.close	= stm_mmap_close,
>  };
>  
> -static int stm_char_mmap(struct file *file, struct vm_area_struct *vma)
> +static int stm_char_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	struct stm_file *stmf = file->private_data;
>  	struct stm_device *stm = stmf->stm;
> diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
> index dc2aed6fb21b..f66f8facbe08 100644
> --- a/drivers/infiniband/core/uverbs_main.c
> +++ b/drivers/infiniband/core/uverbs_main.c
> @@ -799,7 +799,8 @@ static ssize_t ib_uverbs_write(struct file *filp, const char __user *buf,
>  	return ret;
>  }
>  
> -static int ib_uverbs_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int ib_uverbs_mmap(struct file *filp, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct ib_uverbs_file *file = filp->private_data;
>  	struct ib_device *ib_dev;
> diff --git a/drivers/infiniband/hw/hfi1/file_ops.c b/drivers/infiniband/hw/hfi1/file_ops.c
> index 2bc89260235a..7504f0815cea 100644
> --- a/drivers/infiniband/hw/hfi1/file_ops.c
> +++ b/drivers/infiniband/hw/hfi1/file_ops.c
> @@ -75,7 +75,8 @@ static int hfi1_file_open(struct inode *inode, struct file *fp);
>  static int hfi1_file_close(struct inode *inode, struct file *fp);
>  static ssize_t hfi1_write_iter(struct kiocb *kiocb, struct iov_iter *from);
>  static unsigned int hfi1_poll(struct file *fp, struct poll_table_struct *pt);
> -static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma);
> +static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma,
> +			  unsigned long map_flags);
>  
>  static u64 kvirt_to_phys(void *addr);
>  static int assign_ctxt(struct hfi1_filedata *fd, struct hfi1_user_info *uinfo);
> @@ -454,7 +455,8 @@ static ssize_t hfi1_write_iter(struct kiocb *kiocb, struct iov_iter *from)
>  	return reqs;
>  }
>  
> -static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma)
> +static int hfi1_file_mmap(struct file *fp, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct hfi1_filedata *fd = fp->private_data;
>  	struct hfi1_ctxtdata *uctxt = fd->uctxt;
> diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
> index 9396c1807cc3..2482d0fc2a77 100644
> --- a/drivers/infiniband/hw/qib/qib_file_ops.c
> +++ b/drivers/infiniband/hw/qib/qib_file_ops.c
> @@ -59,7 +59,7 @@ static int qib_close(struct inode *, struct file *);
>  static ssize_t qib_write(struct file *, const char __user *, size_t, loff_t *);
>  static ssize_t qib_write_iter(struct kiocb *, struct iov_iter *);
>  static unsigned int qib_poll(struct file *, struct poll_table_struct *);
> -static int qib_mmapf(struct file *, struct vm_area_struct *);
> +static int qib_mmapf(struct file *, struct vm_area_struct *, unsigned long);
>  
>  /*
>   * This is really, really weird shit - write() and writev() here
> @@ -993,7 +993,8 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u64 pgaddr,
>   * buffers in the chip.  We have the open and close entries so we can bump
>   * the ref count and keep the driver from being unloaded while still mapped.
>   */
> -static int qib_mmapf(struct file *fp, struct vm_area_struct *vma)
> +static int qib_mmapf(struct file *fp, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct qib_ctxtdata *rcd;
>  	struct qib_devdata *dd;
> diff --git a/drivers/media/common/saa7146/saa7146_fops.c b/drivers/media/common/saa7146/saa7146_fops.c
> index 930d2c94d5d3..a47d6595b3e2 100644
> --- a/drivers/media/common/saa7146/saa7146_fops.c
> +++ b/drivers/media/common/saa7146/saa7146_fops.c
> @@ -287,7 +287,8 @@ static int fops_release(struct file *file)
>  	return 0;
>  }
>  
> -static int fops_mmap(struct file *file, struct vm_area_struct * vma)
> +static int fops_mmap(struct file *file, struct vm_area_struct * vma,
> +		     unsigned long map_flags)
>  {
>  	struct video_device *vdev = video_devdata(file);
>  	struct saa7146_fh *fh = file->private_data;
> diff --git a/drivers/media/pci/bt8xx/bttv-driver.c b/drivers/media/pci/bt8xx/bttv-driver.c
> index 227086a2e99c..1fd71bbd8de6 100644
> --- a/drivers/media/pci/bt8xx/bttv-driver.c
> +++ b/drivers/media/pci/bt8xx/bttv-driver.c
> @@ -3129,7 +3129,8 @@ static int bttv_release(struct file *file)
>  }
>  
>  static int
> -bttv_mmap(struct file *file, struct vm_area_struct *vma)
> +bttv_mmap(struct file *file, struct vm_area_struct *vma,
> +	  unsigned long map_flags)
>  {
>  	struct bttv_fh *fh = file->private_data;
>  
> diff --git a/drivers/media/pci/cx18/cx18-fileops.c b/drivers/media/pci/cx18/cx18-fileops.c
> index 98467b2089fa..27a560e81117 100644
> --- a/drivers/media/pci/cx18/cx18-fileops.c
> +++ b/drivers/media/pci/cx18/cx18-fileops.c
> @@ -652,7 +652,8 @@ unsigned int cx18_v4l2_enc_poll(struct file *filp, poll_table *wait)
>  	return res;
>  }
>  
> -int cx18_v4l2_mmap(struct file *file, struct vm_area_struct *vma)
> +int cx18_v4l2_mmap(struct file *file, struct vm_area_struct *vma,
> +		   unsigned long map_flags)
>  {
>  	struct cx18_open_id *id = file->private_data;
>  	struct cx18 *cx = id->cx;
> diff --git a/drivers/media/pci/cx18/cx18-fileops.h b/drivers/media/pci/cx18/cx18-fileops.h
> index 58b00b433708..01b15e74d784 100644
> --- a/drivers/media/pci/cx18/cx18-fileops.h
> +++ b/drivers/media/pci/cx18/cx18-fileops.h
> @@ -28,7 +28,8 @@ int cx18_start_capture(struct cx18_open_id *id);
>  void cx18_stop_capture(struct cx18_open_id *id, int gop_end);
>  void cx18_mute(struct cx18 *cx);
>  void cx18_unmute(struct cx18 *cx);
> -int cx18_v4l2_mmap(struct file *file, struct vm_area_struct *vma);
> +int cx18_v4l2_mmap(struct file *file, struct vm_area_struct *vma,
> +		   unsigned long map_flags);
>  void cx18_vb_timeout(unsigned long data);
>  
>  /* Shared with cx18-alsa module */
> diff --git a/drivers/media/pci/meye/meye.c b/drivers/media/pci/meye/meye.c
> index 49e047e4a81e..2513ceceb9be 100644
> --- a/drivers/media/pci/meye/meye.c
> +++ b/drivers/media/pci/meye/meye.c
> @@ -1452,7 +1452,8 @@ static const struct vm_operations_struct meye_vm_ops = {
>  	.close		= meye_vm_close,
>  };
>  
> -static int meye_mmap(struct file *file, struct vm_area_struct *vma)
> +static int meye_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	unsigned long start = vma->vm_start;
>  	unsigned long size = vma->vm_end - vma->vm_start;
> diff --git a/drivers/media/pci/zoran/zoran_driver.c b/drivers/media/pci/zoran/zoran_driver.c
> index a11cb501c550..f7bc18183cc2 100644
> --- a/drivers/media/pci/zoran/zoran_driver.c
> +++ b/drivers/media/pci/zoran/zoran_driver.c
> @@ -2651,7 +2651,7 @@ static const struct vm_operations_struct zoran_vm_ops = {
>  
>  static int
>  zoran_mmap (struct file           *file,
> -	    struct vm_area_struct *vma)
> +	    struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	struct zoran_fh *fh = file->private_data;
>  	struct zoran *zr = fh->zr;
> diff --git a/drivers/media/platform/davinci/vpfe_capture.c b/drivers/media/platform/davinci/vpfe_capture.c
> index 6792da16d9c7..32177a0fbf3b 100644
> --- a/drivers/media/platform/davinci/vpfe_capture.c
> +++ b/drivers/media/platform/davinci/vpfe_capture.c
> @@ -717,7 +717,8 @@ static int vpfe_release(struct file *file)
>   * vpfe_mmap : It is used to map kernel space buffers
>   * into user spaces
>   */
> -static int vpfe_mmap(struct file *file, struct vm_area_struct *vma)
> +static int vpfe_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	/* Get the device object and file handle object */
>  	struct vpfe_device *vpfe_dev = video_drvdata(file);
> diff --git a/drivers/media/platform/exynos-gsc/gsc-m2m.c b/drivers/media/platform/exynos-gsc/gsc-m2m.c
> index 2a2994ef15d5..315a8e232785 100644
> --- a/drivers/media/platform/exynos-gsc/gsc-m2m.c
> +++ b/drivers/media/platform/exynos-gsc/gsc-m2m.c
> @@ -723,7 +723,8 @@ static unsigned int gsc_m2m_poll(struct file *file,
>  	return ret;
>  }
>  
> -static int gsc_m2m_mmap(struct file *file, struct vm_area_struct *vma)
> +static int gsc_m2m_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	struct gsc_ctx *ctx = fh_to_ctx(file->private_data);
>  	struct gsc_dev *gsc = ctx->gsc_dev;
> diff --git a/drivers/media/platform/fsl-viu.c b/drivers/media/platform/fsl-viu.c
> index fb43025df573..494551d851b2 100644
> --- a/drivers/media/platform/fsl-viu.c
> +++ b/drivers/media/platform/fsl-viu.c
> @@ -1319,7 +1319,8 @@ void viu_reset(struct viu_reg *reg)
>  	out_be32(&reg->alpha, 0x000000ff);
>  }
>  
> -static int viu_mmap(struct file *file, struct vm_area_struct *vma)
> +static int viu_mmap(struct file *file, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct viu_fh *fh = file->private_data;
>  	struct viu_dev *dev = fh->dev;
> diff --git a/drivers/media/platform/m2m-deinterlace.c b/drivers/media/platform/m2m-deinterlace.c
> index c8a12493f395..10c0c934ba5b 100644
> --- a/drivers/media/platform/m2m-deinterlace.c
> +++ b/drivers/media/platform/m2m-deinterlace.c
> @@ -963,7 +963,8 @@ static unsigned int deinterlace_poll(struct file *file,
>  	return ret;
>  }
>  
> -static int deinterlace_mmap(struct file *file, struct vm_area_struct *vma)
> +static int deinterlace_mmap(struct file *file, struct vm_area_struct *vma,
> +			    unsigned long map_flags)
>  {
>  	struct deinterlace_ctx *ctx = file->private_data;
>  
> diff --git a/drivers/media/platform/mx2_emmaprp.c b/drivers/media/platform/mx2_emmaprp.c
> index 4a2b1afa19c4..c15c9af7ec29 100644
> --- a/drivers/media/platform/mx2_emmaprp.c
> +++ b/drivers/media/platform/mx2_emmaprp.c
> @@ -851,7 +851,8 @@ static unsigned int emmaprp_poll(struct file *file,
>  	return res;
>  }
>  
> -static int emmaprp_mmap(struct file *file, struct vm_area_struct *vma)
> +static int emmaprp_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	struct emmaprp_dev *pcdev = video_drvdata(file);
>  	struct emmaprp_ctx *ctx = file->private_data;
> diff --git a/drivers/media/platform/omap/omap_vout.c b/drivers/media/platform/omap/omap_vout.c
> index 4d29860d27b4..f4eaa03ca921 100644
> --- a/drivers/media/platform/omap/omap_vout.c
> +++ b/drivers/media/platform/omap/omap_vout.c
> @@ -871,7 +871,8 @@ static const struct vm_operations_struct omap_vout_vm_ops = {
>  	.close	= omap_vout_vm_close,
>  };
>  
> -static int omap_vout_mmap(struct file *file, struct vm_area_struct *vma)
> +static int omap_vout_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	int i;
>  	void *pos;
> diff --git a/drivers/media/platform/omap3isp/ispvideo.c b/drivers/media/platform/omap3isp/ispvideo.c
> index 218e6d7ae93a..4b96d815713b 100644
> --- a/drivers/media/platform/omap3isp/ispvideo.c
> +++ b/drivers/media/platform/omap3isp/ispvideo.c
> @@ -1396,7 +1396,8 @@ static unsigned int isp_video_poll(struct file *file, poll_table *wait)
>  	return ret;
>  }
>  
> -static int isp_video_mmap(struct file *file, struct vm_area_struct *vma)
> +static int isp_video_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct isp_video_fh *vfh = to_isp_video_fh(file->private_data);
>  
> diff --git a/drivers/media/platform/s3c-camif/camif-capture.c b/drivers/media/platform/s3c-camif/camif-capture.c
> index 25c7a7d42292..ea59b7413c6e 100644
> --- a/drivers/media/platform/s3c-camif/camif-capture.c
> +++ b/drivers/media/platform/s3c-camif/camif-capture.c
> @@ -607,7 +607,8 @@ static unsigned int s3c_camif_poll(struct file *file,
>  	return ret;
>  }
>  
> -static int s3c_camif_mmap(struct file *file, struct vm_area_struct *vma)
> +static int s3c_camif_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct camif_vp *vp = video_drvdata(file);
>  	int ret;
> diff --git a/drivers/media/platform/s5p-mfc/s5p_mfc.c b/drivers/media/platform/s5p-mfc/s5p_mfc.c
> index 1afde5021ca6..292d41109286 100644
> --- a/drivers/media/platform/s5p-mfc/s5p_mfc.c
> +++ b/drivers/media/platform/s5p-mfc/s5p_mfc.c
> @@ -1040,7 +1040,8 @@ static unsigned int s5p_mfc_poll(struct file *file,
>  }
>  
>  /* Mmap */
> -static int s5p_mfc_mmap(struct file *file, struct vm_area_struct *vma)
> +static int s5p_mfc_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	struct s5p_mfc_ctx *ctx = fh_to_ctx(file->private_data);
>  	struct s5p_mfc_dev *dev = ctx->dev;
> diff --git a/drivers/media/platform/sh_veu.c b/drivers/media/platform/sh_veu.c
> index 15a562af13c7..e7aa80d66dc8 100644
> --- a/drivers/media/platform/sh_veu.c
> +++ b/drivers/media/platform/sh_veu.c
> @@ -1024,7 +1024,8 @@ static unsigned int sh_veu_poll(struct file *file,
>  	return v4l2_m2m_poll(file, veu_file->veu_dev->m2m_ctx, wait);
>  }
>  
> -static int sh_veu_mmap(struct file *file, struct vm_area_struct *vma)
> +static int sh_veu_mmap(struct file *file, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct sh_veu_file *veu_file = file->private_data;
>  
> diff --git a/drivers/media/platform/soc_camera/soc_camera.c b/drivers/media/platform/soc_camera/soc_camera.c
> index 1f3c450c7a69..e452a13032be 100644
> --- a/drivers/media/platform/soc_camera/soc_camera.c
> +++ b/drivers/media/platform/soc_camera/soc_camera.c
> @@ -781,7 +781,8 @@ static ssize_t soc_camera_read(struct file *file, char __user *buf,
>  	return -EINVAL;
>  }
>  
> -static int soc_camera_mmap(struct file *file, struct vm_area_struct *vma)
> +static int soc_camera_mmap(struct file *file, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	struct soc_camera_device *icd = file->private_data;
>  	struct soc_camera_host *ici = to_soc_camera_host(icd->parent);
> diff --git a/drivers/media/platform/via-camera.c b/drivers/media/platform/via-camera.c
> index 805d4a8fc17e..ae82131f6d17 100644
> --- a/drivers/media/platform/via-camera.c
> +++ b/drivers/media/platform/via-camera.c
> @@ -772,7 +772,8 @@ static unsigned int viacam_poll(struct file *filp, struct poll_table_struct *pt)
>  }
>  
>  
> -static int viacam_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int viacam_mmap(struct file *filp, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct via_camera *cam = video_drvdata(filp);
>  
> diff --git a/drivers/media/usb/cpia2/cpia2_v4l.c b/drivers/media/usb/cpia2/cpia2_v4l.c
> index 3dedd83f0b19..69dd3236075a 100644
> --- a/drivers/media/usb/cpia2/cpia2_v4l.c
> +++ b/drivers/media/usb/cpia2/cpia2_v4l.c
> @@ -998,7 +998,8 @@ static int cpia2_streamoff(struct file *file, void *fh, enum v4l2_buf_type type)
>   *  cpia2_mmap
>   *
>   *****************************************************************************/
> -static int cpia2_mmap(struct file *file, struct vm_area_struct *area)
> +static int cpia2_mmap(struct file *file, struct vm_area_struct *area,
> +		      unsigned long map_flags)
>  {
>  	struct camera_data *cam = video_drvdata(file);
>  	int retval;
> diff --git a/drivers/media/usb/cx231xx/cx231xx-417.c b/drivers/media/usb/cx231xx/cx231xx-417.c
> index d538fa407742..80eea317278b 100644
> --- a/drivers/media/usb/cx231xx/cx231xx-417.c
> +++ b/drivers/media/usb/cx231xx/cx231xx-417.c
> @@ -1834,7 +1834,8 @@ static unsigned int mpeg_poll(struct file *file,
>  	return res;
>  }
>  
> -static int mpeg_mmap(struct file *file, struct vm_area_struct *vma)
> +static int mpeg_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct cx231xx_fh *fh = file->private_data;
>  
> diff --git a/drivers/media/usb/cx231xx/cx231xx-video.c b/drivers/media/usb/cx231xx/cx231xx-video.c
> index 179b8481a870..1175591c1d24 100644
> --- a/drivers/media/usb/cx231xx/cx231xx-video.c
> +++ b/drivers/media/usb/cx231xx/cx231xx-video.c
> @@ -2044,7 +2044,8 @@ static unsigned int cx231xx_v4l2_poll(struct file *filp, poll_table *wait)
>  /*
>   * cx231xx_v4l2_mmap()
>   */
> -static int cx231xx_v4l2_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int cx231xx_v4l2_mmap(struct file *filp, struct vm_area_struct *vma,
> +			     unsigned long map_flags)
>  {
>  	struct cx231xx_fh *fh = filp->private_data;
>  	struct cx231xx *dev = fh->dev;
> diff --git a/drivers/media/usb/gspca/gspca.c b/drivers/media/usb/gspca/gspca.c
> index 0f141762abf1..f3545dbdfb85 100644
> --- a/drivers/media/usb/gspca/gspca.c
> +++ b/drivers/media/usb/gspca/gspca.c
> @@ -1589,7 +1589,8 @@ static int vidioc_s_parm(struct file *filp, void *priv,
>  	return 0;
>  }
>  
> -static int dev_mmap(struct file *file, struct vm_area_struct *vma)
> +static int dev_mmap(struct file *file, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct gspca_dev *gspca_dev = video_drvdata(file);
>  	struct gspca_frame *frame;
> diff --git a/drivers/media/usb/stkwebcam/stk-webcam.c b/drivers/media/usb/stkwebcam/stk-webcam.c
> index c0bba773db25..2bcfe742231c 100644
> --- a/drivers/media/usb/stkwebcam/stk-webcam.c
> +++ b/drivers/media/usb/stkwebcam/stk-webcam.c
> @@ -755,7 +755,8 @@ static const struct vm_operations_struct stk_v4l_vm_ops = {
>  	.close = stk_v4l_vm_close
>  };
>  
> -static int v4l_stk_mmap(struct file *fp, struct vm_area_struct *vma)
> +static int v4l_stk_mmap(struct file *fp, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	unsigned int i;
>  	int ret;
> diff --git a/drivers/media/usb/tm6000/tm6000-video.c b/drivers/media/usb/tm6000/tm6000-video.c
> index ec8c4d2534dc..db89f1360397 100644
> --- a/drivers/media/usb/tm6000/tm6000-video.c
> +++ b/drivers/media/usb/tm6000/tm6000-video.c
> @@ -1519,7 +1519,8 @@ static int tm6000_release(struct file *file)
>  	return 0;
>  }
>  
> -static int tm6000_mmap(struct file *file, struct vm_area_struct * vma)
> +static int tm6000_mmap(struct file *file, struct vm_area_struct * vma,
> +		       unsigned long map_flags)
>  {
>  	struct tm6000_fh *fh = file->private_data;
>  	struct tm6000_core *dev = fh->dev;
> diff --git a/drivers/media/usb/usbvision/usbvision-video.c b/drivers/media/usb/usbvision/usbvision-video.c
> index 960272d3c924..f9325cc93a4a 100644
> --- a/drivers/media/usb/usbvision/usbvision-video.c
> +++ b/drivers/media/usb/usbvision/usbvision-video.c
> @@ -1066,7 +1066,8 @@ static int usbvision_mmap(struct file *file, struct vm_area_struct *vma)
>  	return 0;
>  }
>  
> -static int usbvision_v4l2_mmap(struct file *file, struct vm_area_struct *vma)
> +static int usbvision_v4l2_mmap(struct file *file, struct vm_area_struct *vma,
> +			       unsigned long map_flags)
>  {
>  	struct usb_usbvision *usbvision = video_drvdata(file);
>  	int res;
> diff --git a/drivers/media/usb/uvc/uvc_v4l2.c b/drivers/media/usb/uvc/uvc_v4l2.c
> index 3e7e283a44a8..69aa80e33775 100644
> --- a/drivers/media/usb/uvc/uvc_v4l2.c
> +++ b/drivers/media/usb/uvc/uvc_v4l2.c
> @@ -1413,7 +1413,8 @@ static ssize_t uvc_v4l2_read(struct file *file, char __user *data,
>  	return -EINVAL;
>  }
>  
> -static int uvc_v4l2_mmap(struct file *file, struct vm_area_struct *vma)
> +static int uvc_v4l2_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	struct uvc_fh *handle = file->private_data;
>  	struct uvc_streaming *stream = handle->stream;
> diff --git a/drivers/media/usb/zr364xx/zr364xx.c b/drivers/media/usb/zr364xx/zr364xx.c
> index 4ff8d0aed015..c21f1b8147c5 100644
> --- a/drivers/media/usb/zr364xx/zr364xx.c
> +++ b/drivers/media/usb/zr364xx/zr364xx.c
> @@ -1270,7 +1270,8 @@ static int zr364xx_close(struct file *file)
>  }
>  
>  
> -static int zr364xx_mmap(struct file *file, struct vm_area_struct *vma)
> +static int zr364xx_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	struct zr364xx_camera *cam = video_drvdata(file);
>  	int ret;
> diff --git a/drivers/media/v4l2-core/v4l2-dev.c b/drivers/media/v4l2-core/v4l2-dev.c
> index c647ba648805..84e32c14e29d 100644
> --- a/drivers/media/v4l2-core/v4l2-dev.c
> +++ b/drivers/media/v4l2-core/v4l2-dev.c
> @@ -388,7 +388,8 @@ static unsigned long v4l2_get_unmapped_area(struct file *filp,
>  }
>  #endif
>  
> -static int v4l2_mmap(struct file *filp, struct vm_area_struct *vm)
> +static int v4l2_mmap(struct file *filp, struct vm_area_struct *vm,
> +		     unsigned long map_flags)
>  {
>  	struct video_device *vdev = video_devdata(filp);
>  	int ret = -ENODEV;
> @@ -396,7 +397,7 @@ static int v4l2_mmap(struct file *filp, struct vm_area_struct *vm)
>  	if (!vdev->fops->mmap)
>  		return -ENODEV;
>  	if (video_is_registered(vdev))
> -		ret = vdev->fops->mmap(filp, vm);
> +		ret = vdev->fops->mmap(filp, vm, map_flags);
>  	if (vdev->dev_debug & V4L2_DEV_DEBUG_FOP)
>  		printk(KERN_DEBUG "%s: mmap (%d)\n",
>  			video_device_node_name(vdev), ret);
> diff --git a/drivers/media/v4l2-core/v4l2-mem2mem.c b/drivers/media/v4l2-core/v4l2-mem2mem.c
> index f62e68aa04c4..38353750c57b 100644
> --- a/drivers/media/v4l2-core/v4l2-mem2mem.c
> +++ b/drivers/media/v4l2-core/v4l2-mem2mem.c
> @@ -784,7 +784,8 @@ EXPORT_SYMBOL_GPL(v4l2_m2m_ioctl_streamoff);
>   * for the output and the capture buffer queue.
>   */
>  
> -int v4l2_m2m_fop_mmap(struct file *file, struct vm_area_struct *vma)
> +int v4l2_m2m_fop_mmap(struct file *file, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	struct v4l2_fh *fh = file->private_data;
>  
> diff --git a/drivers/media/v4l2-core/videobuf2-dma-contig.c b/drivers/media/v4l2-core/videobuf2-dma-contig.c
> index 9f389f36566d..e4ae803accfa 100644
> --- a/drivers/media/v4l2-core/videobuf2-dma-contig.c
> +++ b/drivers/media/v4l2-core/videobuf2-dma-contig.c
> @@ -347,7 +347,7 @@ static void *vb2_dc_dmabuf_ops_vmap(struct dma_buf *dbuf)
>  }
>  
>  static int vb2_dc_dmabuf_ops_mmap(struct dma_buf *dbuf,
> -	struct vm_area_struct *vma)
> +	struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	return vb2_dc_mmap(dbuf->priv, vma);
>  }
> diff --git a/drivers/media/v4l2-core/videobuf2-dma-sg.c b/drivers/media/v4l2-core/videobuf2-dma-sg.c
> index 6808231a6bdc..7e1e5eb314f1 100644
> --- a/drivers/media/v4l2-core/videobuf2-dma-sg.c
> +++ b/drivers/media/v4l2-core/videobuf2-dma-sg.c
> @@ -497,7 +497,7 @@ static void *vb2_dma_sg_dmabuf_ops_vmap(struct dma_buf *dbuf)
>  }
>  
>  static int vb2_dma_sg_dmabuf_ops_mmap(struct dma_buf *dbuf,
> -	struct vm_area_struct *vma)
> +	struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	return vb2_dma_sg_mmap(dbuf->priv, vma);
>  }
> diff --git a/drivers/media/v4l2-core/videobuf2-v4l2.c b/drivers/media/v4l2-core/videobuf2-v4l2.c
> index 0c0669976bdc..3259297f8bab 100644
> --- a/drivers/media/v4l2-core/videobuf2-v4l2.c
> +++ b/drivers/media/v4l2-core/videobuf2-v4l2.c
> @@ -823,7 +823,8 @@ EXPORT_SYMBOL_GPL(vb2_ioctl_expbuf);
>  
>  /* v4l2_file_operations helpers */
>  
> -int vb2_fop_mmap(struct file *file, struct vm_area_struct *vma)
> +int vb2_fop_mmap(struct file *file, struct vm_area_struct *vma,
> +		 unsigned long map_flags)
>  {
>  	struct video_device *vdev = video_devdata(file);
>  
> diff --git a/drivers/media/v4l2-core/videobuf2-vmalloc.c b/drivers/media/v4l2-core/videobuf2-vmalloc.c
> index 3a7c80cd1a17..05efd9ceeb2f 100644
> --- a/drivers/media/v4l2-core/videobuf2-vmalloc.c
> +++ b/drivers/media/v4l2-core/videobuf2-vmalloc.c
> @@ -335,7 +335,7 @@ static void *vb2_vmalloc_dmabuf_ops_vmap(struct dma_buf *dbuf)
>  }
>  
>  static int vb2_vmalloc_dmabuf_ops_mmap(struct dma_buf *dbuf,
> -	struct vm_area_struct *vma)
> +	struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	return vb2_vmalloc_mmap(dbuf->priv, vma);
>  }
> diff --git a/drivers/misc/aspeed-lpc-ctrl.c b/drivers/misc/aspeed-lpc-ctrl.c
> index b5439643f54b..c79564d544c3 100644
> --- a/drivers/misc/aspeed-lpc-ctrl.c
> +++ b/drivers/misc/aspeed-lpc-ctrl.c
> @@ -38,7 +38,8 @@ static struct aspeed_lpc_ctrl *file_aspeed_lpc_ctrl(struct file *file)
>  			miscdev);
>  }
>  
> -static int aspeed_lpc_ctrl_mmap(struct file *file, struct vm_area_struct *vma)
> +static int aspeed_lpc_ctrl_mmap(struct file *file, struct vm_area_struct *vma,
> +				unsigned long map_flags)
>  {
>  	struct aspeed_lpc_ctrl *lpc_ctrl = file_aspeed_lpc_ctrl(file);
>  	unsigned long vsize = vma->vm_end - vma->vm_start;
> diff --git a/drivers/misc/cxl/api.c b/drivers/misc/cxl/api.c
> index a0c44d16bf30..5ab1d57341ca 100644
> --- a/drivers/misc/cxl/api.c
> +++ b/drivers/misc/cxl/api.c
> @@ -412,9 +412,10 @@ long cxl_fd_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  	return afu_ioctl(file, cmd, arg);
>  }
>  EXPORT_SYMBOL_GPL(cxl_fd_ioctl);
> -int cxl_fd_mmap(struct file *file, struct vm_area_struct *vm)
> +int cxl_fd_mmap(struct file *file, struct vm_area_struct *vm,
> +		unsigned long map_flags)
>  {
> -	return afu_mmap(file, vm);
> +	return afu_mmap(file, vm, map_flags);
>  }
>  EXPORT_SYMBOL_GPL(cxl_fd_mmap);
>  unsigned int cxl_fd_poll(struct file *file, struct poll_table_struct *poll)
> diff --git a/drivers/misc/cxl/cxl.h b/drivers/misc/cxl/cxl.h
> index b1afeccbb97f..a9c1d4538164 100644
> --- a/drivers/misc/cxl/cxl.h
> +++ b/drivers/misc/cxl/cxl.h
> @@ -1082,7 +1082,8 @@ int afu_allocate_irqs(struct cxl_context *ctx, u32 count);
>  int afu_open(struct inode *inode, struct file *file);
>  int afu_release(struct inode *inode, struct file *file);
>  long afu_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
> -int afu_mmap(struct file *file, struct vm_area_struct *vm);
> +int afu_mmap(struct file *file, struct vm_area_struct *vm,
> +	     unsigned long map_flags);
>  unsigned int afu_poll(struct file *file, struct poll_table_struct *poll);
>  ssize_t afu_read(struct file *file, char __user *buf, size_t count, loff_t *off);
>  extern const struct file_operations afu_fops;
> diff --git a/drivers/misc/cxl/file.c b/drivers/misc/cxl/file.c
> index 4bfad9f6dc9f..879ba7f83969 100644
> --- a/drivers/misc/cxl/file.c
> +++ b/drivers/misc/cxl/file.c
> @@ -309,7 +309,8 @@ static long afu_compat_ioctl(struct file *file, unsigned int cmd,
>  	return afu_ioctl(file, cmd, arg);
>  }
>  
> -int afu_mmap(struct file *file, struct vm_area_struct *vm)
> +int afu_mmap(struct file *file, struct vm_area_struct *vm,
> +	     unsigned long map_flags)
>  {
>  	struct cxl_context *ctx = file->private_data;
>  
> diff --git a/drivers/misc/genwqe/card_dev.c b/drivers/misc/genwqe/card_dev.c
> index dd4617764f14..82a58da65756 100644
> --- a/drivers/misc/genwqe/card_dev.c
> +++ b/drivers/misc/genwqe/card_dev.c
> @@ -435,7 +435,8 @@ static const struct vm_operations_struct genwqe_vma_ops = {
>   * plain buffer, we lookup our dma_mapping list to find the
>   * corresponding DMA address for the associated user-space address.
>   */
> -static int genwqe_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int genwqe_mmap(struct file *filp, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	int rc;
>  	unsigned long pfn, vsize = vma->vm_end - vma->vm_start;
> diff --git a/drivers/misc/mic/scif/scif_fd.c b/drivers/misc/mic/scif/scif_fd.c
> index f7e826142a72..5dfbaa681d2d 100644
> --- a/drivers/misc/mic/scif/scif_fd.c
> +++ b/drivers/misc/mic/scif/scif_fd.c
> @@ -34,7 +34,8 @@ static int scif_fdclose(struct inode *inode, struct file *f)
>  	return scif_close(priv);
>  }
>  
> -static int scif_fdmmap(struct file *f, struct vm_area_struct *vma)
> +static int scif_fdmmap(struct file *f, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct scif_endpt *priv = f->private_data;
>  
> diff --git a/drivers/misc/mic/vop/vop_vringh.c b/drivers/misc/mic/vop/vop_vringh.c
> index fed992e2c258..d80418f503b3 100644
> --- a/drivers/misc/mic/vop/vop_vringh.c
> +++ b/drivers/misc/mic/vop/vop_vringh.c
> @@ -1083,7 +1083,8 @@ vop_query_offset(struct vop_vdev *vdev, unsigned long offset,
>  /*
>   * Maps the device page and virtio rings to user space for readonly access.
>   */
> -static int vop_mmap(struct file *f, struct vm_area_struct *vma)
> +static int vop_mmap(struct file *f, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct vop_vdev *vdev = f->private_data;
>  	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
> diff --git a/drivers/misc/sgi-gru/grufile.c b/drivers/misc/sgi-gru/grufile.c
> index 104a05f6b738..2751d82a259f 100644
> --- a/drivers/misc/sgi-gru/grufile.c
> +++ b/drivers/misc/sgi-gru/grufile.c
> @@ -104,7 +104,8 @@ static void gru_vma_close(struct vm_area_struct *vma)
>   * and private data structure necessary to allocate, track, and free the
>   * underlying pages.
>   */
> -static int gru_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int gru_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	if ((vma->vm_flags & (VM_SHARED | VM_WRITE)) != (VM_SHARED | VM_WRITE))
>  		return -EPERM;
> diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
> index 3568294d4854..7aa296edd4ff 100644
> --- a/drivers/mtd/mtdchar.c
> +++ b/drivers/mtd/mtdchar.c
> @@ -1192,7 +1192,8 @@ static unsigned mtdchar_mmap_capabilities(struct file *file)
>  /*
>   * set up a mapping for shared memory segments
>   */
> -static int mtdchar_mmap(struct file *file, struct vm_area_struct *vma)
> +static int mtdchar_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  #ifdef CONFIG_MMU
>  	struct mtd_file_info *mfi = file->private_data;
> diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
> index 098360d7ff81..4e77aad084d1 100644
> --- a/drivers/pci/proc.c
> +++ b/drivers/pci/proc.c
> @@ -230,7 +230,8 @@ static long proc_bus_pci_ioctl(struct file *file, unsigned int cmd,
>  }
>  
>  #ifdef HAVE_PCI_MMAP
> -static int proc_bus_pci_mmap(struct file *file, struct vm_area_struct *vma)
> +static int proc_bus_pci_mmap(struct file *file, struct vm_area_struct *vma,
> +			     unsigned long map_flags)
>  {
>  	struct pci_dev *dev = PDE_DATA(file_inode(file));
>  	struct pci_filp_private *fpriv = file->private_data;
> diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
> index 5beb0c361076..a3dfd8ea6580 100644
> --- a/drivers/rapidio/devices/rio_mport_cdev.c
> +++ b/drivers/rapidio/devices/rio_mport_cdev.c
> @@ -2261,7 +2261,8 @@ static const struct vm_operations_struct vm_ops = {
>  	.close = mport_mm_close,
>  };
>  
> -static int mport_cdev_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int mport_cdev_mmap(struct file *filp, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	struct mport_cdev_priv *priv = filp->private_data;
>  	struct mport_dev *md;
> diff --git a/drivers/sbus/char/flash.c b/drivers/sbus/char/flash.c
> index a610b8d3d11f..5f748a099d8d 100644
> --- a/drivers/sbus/char/flash.c
> +++ b/drivers/sbus/char/flash.c
> @@ -33,7 +33,8 @@ static struct {
>  #define FLASH_MINOR	152
>  
>  static int
> -flash_mmap(struct file *file, struct vm_area_struct *vma)
> +flash_mmap(struct file *file, struct vm_area_struct *vma,
> +	   unsigned long map_flags)
>  {
>  	unsigned long addr;
>  	unsigned long size;
> diff --git a/drivers/sbus/char/jsflash.c b/drivers/sbus/char/jsflash.c
> index 14f377ac1280..3f278397f064 100644
> --- a/drivers/sbus/char/jsflash.c
> +++ b/drivers/sbus/char/jsflash.c
> @@ -440,7 +440,8 @@ static long jsf_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
>  	return error;
>  }
>  
> -static int jsf_mmap(struct file * file, struct vm_area_struct * vma)
> +static int jsf_mmap(struct file * file, struct vm_area_struct * vma,
> +		    unsigned long map_flags)
>  {
>  	return -ENXIO;
>  }
> diff --git a/drivers/scsi/cxlflash/superpipe.c b/drivers/scsi/cxlflash/superpipe.c
> index ad0f9968ccfb..cc0bfb044a60 100644
> --- a/drivers/scsi/cxlflash/superpipe.c
> +++ b/drivers/scsi/cxlflash/superpipe.c
> @@ -1160,7 +1160,8 @@ static const struct vm_operations_struct cxlflash_mmap_vmops = {
>   *
>   * Return: 0 on success, -errno on failure
>   */
> -static int cxlflash_cxl_mmap(struct file *file, struct vm_area_struct *vma)
> +static int cxlflash_cxl_mmap(struct file *file, struct vm_area_struct *vma,
> +			     unsigned long map_flags)
>  {
>  	struct cxl_context *ctx = cxl_fops_get_context(file);
>  	struct cxlflash_cfg *cfg = container_of(file->f_op, struct cxlflash_cfg,
> @@ -1188,7 +1189,7 @@ static int cxlflash_cxl_mmap(struct file *file, struct vm_area_struct *vma)
>  
>  	dev_dbg(dev, "%s: mmap for context %d\n", __func__, ctxid);
>  
> -	rc = cxl_fd_mmap(file, vma);
> +	rc = cxl_fd_mmap(file, vma, map_flags);
>  	if (likely(!rc)) {
>  		/* Insert ourself in the mmap fault handler path */
>  		ctxi->cxl_mmap_vmops = vma->vm_ops;
> diff --git a/drivers/scsi/sg.c b/drivers/scsi/sg.c
> index 84e782d8e7c3..38b18d4adc20 100644
> --- a/drivers/scsi/sg.c
> +++ b/drivers/scsi/sg.c
> @@ -1227,7 +1227,8 @@ static const struct vm_operations_struct sg_mmap_vm_ops = {
>  };
>  
>  static int
> -sg_mmap(struct file *filp, struct vm_area_struct *vma)
> +sg_mmap(struct file *filp, struct vm_area_struct *vma,
> +	unsigned long map_flags)
>  {
>  	Sg_fd *sfp;
>  	unsigned long req_sz, len, sa;
> diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
> index 6ba270e0494d..ad4f863cdb8e 100644
> --- a/drivers/staging/android/ashmem.c
> +++ b/drivers/staging/android/ashmem.c
> @@ -375,7 +375,8 @@ static inline vm_flags_t calc_vm_may_flags(unsigned long prot)
>  	       _calc_vm_trans(prot, PROT_EXEC,  VM_MAYEXEC);
>  }
>  
> -static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
> +static int ashmem_mmap(struct file *file, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct ashmem_area *asma = file->private_data;
>  	int ret = 0;
> diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
> index 93e2c90fa77d..2c3044a9899e 100644
> --- a/drivers/staging/android/ion/ion.c
> +++ b/drivers/staging/android/ion/ion.c
> @@ -284,7 +284,8 @@ static void ion_unmap_dma_buf(struct dma_buf_attachment *attachment,
>  	dma_unmap_sg(attachment->dev, table->sgl, table->nents, direction);
>  }
>  
> -static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
> +static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct ion_buffer *buffer = dmabuf->priv;
>  	int ret = 0;
> diff --git a/drivers/staging/comedi/comedi_fops.c b/drivers/staging/comedi/comedi_fops.c
> index e19e395b0e44..9c3a4417f491 100644
> --- a/drivers/staging/comedi/comedi_fops.c
> +++ b/drivers/staging/comedi/comedi_fops.c
> @@ -2185,7 +2185,8 @@ static const struct vm_operations_struct comedi_vm_ops = {
>  	.access = comedi_vm_access,
>  };
>  
> -static int comedi_mmap(struct file *file, struct vm_area_struct *vma)
> +static int comedi_mmap(struct file *file, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct comedi_file *cfp = file->private_data;
>  	struct comedi_device *dev = cfp->dev;
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index 0287c751e1cd..6203992b0497 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -912,7 +912,8 @@ static inline struct vvp_io_args *ll_env_args(const struct lu_env *env)
>  /* llite/llite_mmap.c */
>  
>  int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last);
> -int ll_file_mmap(struct file *file, struct vm_area_struct *vma);
> +int ll_file_mmap(struct file *file, struct vm_area_struct *vma,
> +		 unsigned long map_flags);
>  void policy_from_vma(union ldlm_policy_data *policy, struct vm_area_struct *vma,
>  		     unsigned long addr, size_t count);
>  struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
> diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
> index ccc7ae15a943..d34663d33299 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
> @@ -455,7 +455,8 @@ static const struct vm_operations_struct ll_file_vm_ops = {
>  	.close			= ll_vm_close,
>  };
>  
> -int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
> +int ll_file_mmap(struct file *file, struct vm_area_struct *vma,
> +		 unsigned long map_flags)
>  {
>  	struct inode *inode = file_inode(file);
>  	int rc;
> @@ -464,7 +465,7 @@ int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
>  		return -EOPNOTSUPP;
>  
>  	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_MAP, 1);
> -	rc = generic_file_mmap(file, vma);
> +	rc = generic_file_mmap(file, vma, map_flags);
>  	if (rc == 0) {
>  		vma->vm_ops = &ll_file_vm_ops;
>  		vma->vm_ops->open(vma);
> diff --git a/drivers/staging/media/atomisp/pci/atomisp2/atomisp_fops.c b/drivers/staging/media/atomisp/pci/atomisp2/atomisp_fops.c
> index d8cfed358d55..a95f1a7d780d 100644
> --- a/drivers/staging/media/atomisp/pci/atomisp2/atomisp_fops.c
> +++ b/drivers/staging/media/atomisp/pci/atomisp2/atomisp_fops.c
> @@ -1161,7 +1161,8 @@ static int remove_pad_from_frame(struct atomisp_device *isp,
>  	return ret;
>  }
>  
> -static int atomisp_mmap(struct file *file, struct vm_area_struct *vma)
> +static int atomisp_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	struct video_device *vdev = video_devdata(file);
>  	struct atomisp_device *isp = video_get_drvdata(vdev);
> @@ -1253,7 +1254,8 @@ static int atomisp_mmap(struct file *file, struct vm_area_struct *vma)
>  	return ret;
>  }
>  
> -static int atomisp_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int atomisp_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			     unsigned long map_flags)
>  {
>  	struct video_device *vdev = video_devdata(file);
>  	struct atomisp_video_pipe *pipe = atomisp_to_video_pipe(vdev);
> diff --git a/drivers/staging/media/davinci_vpfe/vpfe_video.c b/drivers/staging/media/davinci_vpfe/vpfe_video.c
> index 155e8c758e4b..f93d9804ddc9 100644
> --- a/drivers/staging/media/davinci_vpfe/vpfe_video.c
> +++ b/drivers/staging/media/davinci_vpfe/vpfe_video.c
> @@ -561,7 +561,8 @@ static int vpfe_release(struct file *file)
>   * vpfe_mmap() - It is used to map kernel space buffers
>   * into user spaces
>   */
> -static int vpfe_mmap(struct file *file, struct vm_area_struct *vma)
> +static int vpfe_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct vpfe_video_device *video = video_drvdata(file);
>  	struct vpfe_device *vpfe_dev = video->vpfe_dev;
> diff --git a/drivers/staging/media/omap4iss/iss_video.c b/drivers/staging/media/omap4iss/iss_video.c
> index 9e2f0421a01e..322e9ffea082 100644
> --- a/drivers/staging/media/omap4iss/iss_video.c
> +++ b/drivers/staging/media/omap4iss/iss_video.c
> @@ -1192,7 +1192,8 @@ static unsigned int iss_video_poll(struct file *file, poll_table *wait)
>  	return vb2_poll(&vfh->queue, file, wait);
>  }
>  
> -static int iss_video_mmap(struct file *file, struct vm_area_struct *vma)
> +static int iss_video_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct iss_video_fh *vfh = to_iss_video_fh(file->private_data);
>  
> diff --git a/drivers/staging/vboxvideo/vbox_drv.h b/drivers/staging/vboxvideo/vbox_drv.h
> index 4b9302703b36..6b392d59da65 100644
> --- a/drivers/staging/vboxvideo/vbox_drv.h
> +++ b/drivers/staging/vboxvideo/vbox_drv.h
> @@ -261,7 +261,8 @@ static inline void vbox_bo_unreserve(struct vbox_bo *bo)
>  
>  void vbox_ttm_placement(struct vbox_bo *bo, int domain);
>  int vbox_bo_push_sysram(struct vbox_bo *bo);
> -int vbox_mmap(struct file *filp, struct vm_area_struct *vma);
> +int vbox_mmap(struct file *filp, struct vm_area_struct *vma,
> +	      unsigned long map_flags);
>  
>  /* vbox_prime.c */
>  int vbox_gem_prime_pin(struct drm_gem_object *obj);
> @@ -273,7 +274,7 @@ struct drm_gem_object *vbox_gem_prime_import_sg_table(
>  void *vbox_gem_prime_vmap(struct drm_gem_object *obj);
>  void vbox_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
>  int vbox_gem_prime_mmap(struct drm_gem_object *obj,
> -			struct vm_area_struct *area);
> +			struct vm_area_struct *area, unsigned long map_flags);
>  
>  /* vbox_irq.c */
>  int vbox_irq_init(struct vbox_private *vbox);
> diff --git a/drivers/staging/vboxvideo/vbox_prime.c b/drivers/staging/vboxvideo/vbox_prime.c
> index b7453e427a1d..45165a6c7860 100644
> --- a/drivers/staging/vboxvideo/vbox_prime.c
> +++ b/drivers/staging/vboxvideo/vbox_prime.c
> @@ -67,7 +67,8 @@ void vbox_gem_prime_vunmap(struct drm_gem_object *obj, void *vaddr)
>  	WARN_ONCE(1, "not implemented");
>  }
>  
> -int vbox_gem_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *area)
> +int vbox_gem_prime_mmap(struct drm_gem_object *obj,
> +			struct vm_area_struct *area, unsigned long map_flags)
>  {
>  	WARN_ONCE(1, "not implemented");
>  	return -ENOSYS;
> diff --git a/drivers/staging/vboxvideo/vbox_ttm.c b/drivers/staging/vboxvideo/vbox_ttm.c
> index 4eb410a2a1a8..1f262a6d64db 100644
> --- a/drivers/staging/vboxvideo/vbox_ttm.c
> +++ b/drivers/staging/vboxvideo/vbox_ttm.c
> @@ -457,7 +457,8 @@ int vbox_bo_push_sysram(struct vbox_bo *bo)
>  	return 0;
>  }
>  
> -int vbox_mmap(struct file *filp, struct vm_area_struct *vma)
> +int vbox_mmap(struct file *filp, struct vm_area_struct *vma,
> +	      unsigned long map_flags)
>  {
>  	struct drm_file *file_priv;
>  	struct vbox_private *vbox;
> diff --git a/drivers/staging/vme/devices/vme_user.c b/drivers/staging/vme/devices/vme_user.c
> index a3d4610fbdbe..4edf846529d7 100644
> --- a/drivers/staging/vme/devices/vme_user.c
> +++ b/drivers/staging/vme/devices/vme_user.c
> @@ -484,7 +484,8 @@ static int vme_user_master_mmap(unsigned int minor, struct vm_area_struct *vma)
>  	return 0;
>  }
>  
> -static int vme_user_mmap(struct file *file, struct vm_area_struct *vma)
> +static int vme_user_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	unsigned int minor = MINOR(file_inode(file)->i_rdev);
>  
> diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
> index d356d7f025eb..2845f2bd22e9 100644
> --- a/drivers/tee/tee_shm.c
> +++ b/drivers/tee/tee_shm.c
> @@ -71,7 +71,8 @@ static void *tee_shm_op_map(struct dma_buf *dmabuf, unsigned long pgnum)
>  	return NULL;
>  }
>  
> -static int tee_shm_op_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
> +static int tee_shm_op_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	struct tee_shm *shm = dmabuf->priv;
>  	size_t size = vma->vm_end - vma->vm_start;
> diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
> index ff04b7f8549f..1ddd3f901127 100644
> --- a/drivers/uio/uio.c
> +++ b/drivers/uio/uio.c
> @@ -674,7 +674,8 @@ static int uio_mmap_physical(struct vm_area_struct *vma)
>  			       vma->vm_page_prot);
>  }
>  
> -static int uio_mmap(struct file *filep, struct vm_area_struct *vma)
> +static int uio_mmap(struct file *filep, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct uio_listener *listener = filep->private_data;
>  	struct uio_device *idev = listener->dev;
> diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
> index 318bb3b96687..c90a0bded389 100644
> --- a/drivers/usb/core/devio.c
> +++ b/drivers/usb/core/devio.c
> @@ -215,7 +215,8 @@ static const struct vm_operations_struct usbdev_vm_ops = {
>  	.close = usbdev_vm_close
>  };
>  
> -static int usbdev_mmap(struct file *file, struct vm_area_struct *vma)
> +static int usbdev_mmap(struct file *file, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct usb_memory *usbm = NULL;
>  	struct usb_dev_state *ps = file->private_data;
> diff --git a/drivers/usb/gadget/function/uvc_v4l2.c b/drivers/usb/gadget/function/uvc_v4l2.c
> index 3e22b45687d3..a15658c0518d 100644
> --- a/drivers/usb/gadget/function/uvc_v4l2.c
> +++ b/drivers/usb/gadget/function/uvc_v4l2.c
> @@ -325,7 +325,8 @@ uvc_v4l2_release(struct file *file)
>  }
>  
>  static int
> -uvc_v4l2_mmap(struct file *file, struct vm_area_struct *vma)
> +uvc_v4l2_mmap(struct file *file, struct vm_area_struct *vma,
> +	      unsigned long map_flags)
>  {
>  	struct video_device *vdev = video_devdata(file);
>  	struct uvc_device *uvc = video_get_drvdata(vdev);
> diff --git a/drivers/usb/mon/mon_bin.c b/drivers/usb/mon/mon_bin.c
> index b6d8bf475c92..69aec6194772 100644
> --- a/drivers/usb/mon/mon_bin.c
> +++ b/drivers/usb/mon/mon_bin.c
> @@ -1246,7 +1246,8 @@ static const struct vm_operations_struct mon_bin_vm_ops = {
>  	.fault =    mon_bin_vma_fault,
>  };
>  
> -static int mon_bin_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int mon_bin_mmap(struct file *filp, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	/* don't do anything here: "fault" will set up page table entries */
>  	vma->vm_ops = &mon_bin_vm_ops;
> diff --git a/drivers/vfio/vfio.c b/drivers/vfio/vfio.c
> index 330d50582f40..e972a2de79f6 100644
> --- a/drivers/vfio/vfio.c
> +++ b/drivers/vfio/vfio.c
> @@ -1256,7 +1256,8 @@ static ssize_t vfio_fops_write(struct file *filep, const char __user *buf,
>  	return ret;
>  }
>  
> -static int vfio_fops_mmap(struct file *filep, struct vm_area_struct *vma)
> +static int vfio_fops_mmap(struct file *filep, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct vfio_container *container = filep->private_data;
>  	struct vfio_iommu_driver *driver;
> @@ -1677,7 +1678,9 @@ static ssize_t vfio_device_fops_write(struct file *filep,
>  	return device->ops->write(device->device_data, buf, count, ppos);
>  }
>  
> -static int vfio_device_fops_mmap(struct file *filep, struct vm_area_struct *vma)
> +static int vfio_device_fops_mmap(struct file *filep,
> +				 struct vm_area_struct *vma,
> +				 unsigned long map_flags)
>  {
>  	struct vfio_device *device = filep->private_data;
>  
> diff --git a/drivers/video/fbdev/68328fb.c b/drivers/video/fbdev/68328fb.c
> index c0c6b88d3839..2b6167b06fad 100644
> --- a/drivers/video/fbdev/68328fb.c
> +++ b/drivers/video/fbdev/68328fb.c
> @@ -94,7 +94,8 @@ static int mc68x328fb_setcolreg(u_int regno, u_int red, u_int green, u_int blue,
>  			 u_int transp, struct fb_info *info);
>  static int mc68x328fb_pan_display(struct fb_var_screeninfo *var,
>  			   struct fb_info *info);
> -static int mc68x328fb_mmap(struct fb_info *info, struct vm_area_struct *vma);
> +static int mc68x328fb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			   unsigned long map_flags);
>  
>  static struct fb_ops mc68x328fb_ops = {
>  	.fb_check_var	= mc68x328fb_check_var,
> @@ -389,7 +390,8 @@ static int mc68x328fb_pan_display(struct fb_var_screeninfo *var,
>       *  Most drivers don't need their own mmap function 
>       */
>  
> -static int mc68x328fb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int mc68x328fb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  #ifndef MMU
>  	/* this is uClinux (no MMU) specific code */
> diff --git a/drivers/video/fbdev/amba-clcd.c b/drivers/video/fbdev/amba-clcd.c
> index ffc2c33c6cef..e19b72639b7c 100644
> --- a/drivers/video/fbdev/amba-clcd.c
> +++ b/drivers/video/fbdev/amba-clcd.c
> @@ -426,7 +426,7 @@ static int clcdfb_blank(int blank_mode, struct fb_info *info)
>  }
>  
>  static int clcdfb_mmap(struct fb_info *info,
> -		       struct vm_area_struct *vma)
> +		       struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	struct clcd_fb *fb = to_clcd(info);
>  	unsigned long len, off = vma->vm_pgoff << PAGE_SHIFT;
> diff --git a/drivers/video/fbdev/aty/atyfb_base.c b/drivers/video/fbdev/aty/atyfb_base.c
> index b55fdac9c9f5..61575cd0049d 100644
> --- a/drivers/video/fbdev/aty/atyfb_base.c
> +++ b/drivers/video/fbdev/aty/atyfb_base.c
> @@ -236,7 +236,8 @@ static int atyfb_pan_display(struct fb_var_screeninfo *var,
>  static int atyfb_blank(int blank, struct fb_info *info);
>  static int atyfb_ioctl(struct fb_info *info, u_int cmd, u_long arg);
>  #ifdef __sparc__
> -static int atyfb_mmap(struct fb_info *info, struct vm_area_struct *vma);
> +static int atyfb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		      unsigned long map_flags);
>  #endif
>  static int atyfb_sync(struct fb_info *info);
>  
> @@ -1928,7 +1929,8 @@ static int atyfb_sync(struct fb_info *info)
>  }
>  
>  #ifdef __sparc__
> -static int atyfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int atyfb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	struct atyfb_par *par = (struct atyfb_par *) info->par;
>  	unsigned int size, page, map_size = 0;
> diff --git a/drivers/video/fbdev/au1100fb.c b/drivers/video/fbdev/au1100fb.c
> index 8de42f617d16..391eb89b0457 100644
> --- a/drivers/video/fbdev/au1100fb.c
> +++ b/drivers/video/fbdev/au1100fb.c
> @@ -338,7 +338,8 @@ int au1100fb_fb_pan_display(struct fb_var_screeninfo *var, struct fb_info *fbi)
>   * Map video memory in user space. We don't use the generic fb_mmap method mainly
>   * to allow the use of the TLB streaming flag (CCA=6)
>   */
> -int au1100fb_fb_mmap(struct fb_info *fbi, struct vm_area_struct *vma)
> +int au1100fb_fb_mmap(struct fb_info *fbi, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct au1100fb_device *fbdev;
>  
> diff --git a/drivers/video/fbdev/au1200fb.c b/drivers/video/fbdev/au1200fb.c
> index 5f04b4096c42..e5902d9fd110 100644
> --- a/drivers/video/fbdev/au1200fb.c
> +++ b/drivers/video/fbdev/au1200fb.c
> @@ -1228,7 +1228,8 @@ static int au1200fb_fb_blank(int blank_mode, struct fb_info *fbi)
>   * Map video memory in user space. We don't use the generic fb_mmap
>   * method mainly to allow the use of the TLB streaming flag (CCA=6)
>   */
> -static int au1200fb_fb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int au1200fb_fb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			    unsigned long map_flags)
>  {
>  	struct au1200fb_device *fbdev = info->par;
>  
> diff --git a/drivers/video/fbdev/bw2.c b/drivers/video/fbdev/bw2.c
> index 8c5b281f0b29..24b379dc327f 100644
> --- a/drivers/video/fbdev/bw2.c
> +++ b/drivers/video/fbdev/bw2.c
> @@ -29,7 +29,7 @@
>  
>  static int bw2_blank(int, struct fb_info *);
>  
> -static int bw2_mmap(struct fb_info *, struct vm_area_struct *);
> +static int bw2_mmap(struct fb_info *, struct vm_area_struct *, unsigned long);
>  static int bw2_ioctl(struct fb_info *, unsigned int, unsigned long);
>  
>  /*
> @@ -159,7 +159,8 @@ static struct sbus_mmap_map bw2_mmap_map[] = {
>  	{ .size = 0 }
>  };
>  
> -static int bw2_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int bw2_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct bw2_par *par = (struct bw2_par *)info->par;
>  
> diff --git a/drivers/video/fbdev/cg14.c b/drivers/video/fbdev/cg14.c
> index 43e915eaf606..665c8bb36fb3 100644
> --- a/drivers/video/fbdev/cg14.c
> +++ b/drivers/video/fbdev/cg14.c
> @@ -30,7 +30,7 @@
>  static int cg14_setcolreg(unsigned, unsigned, unsigned, unsigned,
>  			 unsigned, struct fb_info *);
>  
> -static int cg14_mmap(struct fb_info *, struct vm_area_struct *);
> +static int cg14_mmap(struct fb_info *, struct vm_area_struct *, unsigned long);
>  static int cg14_ioctl(struct fb_info *, unsigned int, unsigned long);
>  static int cg14_pan_display(struct fb_var_screeninfo *, struct fb_info *);
>  
> @@ -263,7 +263,8 @@ static int cg14_setcolreg(unsigned regno,
>  	return 0;
>  }
>  
> -static int cg14_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int cg14_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct cg14_par *par = (struct cg14_par *) info->par;
>  
> diff --git a/drivers/video/fbdev/cg3.c b/drivers/video/fbdev/cg3.c
> index 716391f22e75..6513f1e5aa8f 100644
> --- a/drivers/video/fbdev/cg3.c
> +++ b/drivers/video/fbdev/cg3.c
> @@ -31,7 +31,7 @@ static int cg3_setcolreg(unsigned, unsigned, unsigned, unsigned,
>  			 unsigned, struct fb_info *);
>  static int cg3_blank(int, struct fb_info *);
>  
> -static int cg3_mmap(struct fb_info *, struct vm_area_struct *);
> +static int cg3_mmap(struct fb_info *, struct vm_area_struct *, unsigned long);
>  static int cg3_ioctl(struct fb_info *, unsigned int, unsigned long);
>  
>  /*
> @@ -223,7 +223,8 @@ static struct sbus_mmap_map cg3_mmap_map[] = {
>  	{ .size = 0 }
>  };
>  
> -static int cg3_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int cg3_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct cg3_par *par = (struct cg3_par *)info->par;
>  
> diff --git a/drivers/video/fbdev/cg6.c b/drivers/video/fbdev/cg6.c
> index bdf901ed5291..6d7afb826f27 100644
> --- a/drivers/video/fbdev/cg6.c
> +++ b/drivers/video/fbdev/cg6.c
> @@ -35,7 +35,7 @@ static void cg6_imageblit(struct fb_info *, const struct fb_image *);
>  static void cg6_fillrect(struct fb_info *, const struct fb_fillrect *);
>  static void cg6_copyarea(struct fb_info *info, const struct fb_copyarea *area);
>  static int cg6_sync(struct fb_info *);
> -static int cg6_mmap(struct fb_info *, struct vm_area_struct *);
> +static int cg6_mmap(struct fb_info *, struct vm_area_struct *, unsigned long);
>  static int cg6_ioctl(struct fb_info *, unsigned int, unsigned long);
>  static int cg6_pan_display(struct fb_var_screeninfo *, struct fb_info *);
>  
> @@ -588,7 +588,8 @@ static struct sbus_mmap_map cg6_mmap_map[] = {
>  	{ .size	= 0 }
>  };
>  
> -static int cg6_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int cg6_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct cg6_par *par = (struct cg6_par *)info->par;
>  
> diff --git a/drivers/video/fbdev/controlfb.c b/drivers/video/fbdev/controlfb.c
> index 8d14b29aafea..03b2477fe309 100644
> --- a/drivers/video/fbdev/controlfb.c
> +++ b/drivers/video/fbdev/controlfb.c
> @@ -129,7 +129,7 @@ static int controlfb_setcolreg(u_int regno, u_int red, u_int green, u_int blue,
>  	u_int transp, struct fb_info *info);
>  static int controlfb_blank(int blank_mode, struct fb_info *info);
>  static int controlfb_mmap(struct fb_info *info,
> -	struct vm_area_struct *vma);
> +	struct vm_area_struct *vma, unsigned long map_flags);
>  static int controlfb_set_par (struct fb_info *info);
>  static int controlfb_check_var (struct fb_var_screeninfo *var, struct fb_info *info);
>  
> @@ -285,7 +285,7 @@ static int controlfb_pan_display(struct fb_var_screeninfo *var,
>   * Note there's no locking in here; it's done in fb_mmap() in fbmem.c.
>   */
>  static int controlfb_mmap(struct fb_info *info,
> -                       struct vm_area_struct *vma)
> +                       struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	unsigned long mmio_pgoff;
>  	unsigned long start;
> diff --git a/drivers/video/fbdev/core/fb_defio.c b/drivers/video/fbdev/core/fb_defio.c
> index 487d5e336e1b..bbe2d200d24b 100644
> --- a/drivers/video/fbdev/core/fb_defio.c
> +++ b/drivers/video/fbdev/core/fb_defio.c
> @@ -162,7 +162,8 @@ static const struct address_space_operations fb_deferred_io_aops = {
>  	.set_page_dirty = fb_deferred_io_set_page_dirty,
>  };
>  
> -int fb_deferred_io_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +int fb_deferred_io_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	vma->vm_ops = &fb_deferred_io_vm_ops;
>  	vma->vm_flags |= VM_DONTEXPAND | VM_DONTDUMP;
> diff --git a/drivers/video/fbdev/core/fbmem.c b/drivers/video/fbdev/core/fbmem.c
> index 25e862c487f6..4b8b5ccd20c4 100644
> --- a/drivers/video/fbdev/core/fbmem.c
> +++ b/drivers/video/fbdev/core/fbmem.c
> @@ -1381,7 +1381,8 @@ static long fb_compat_ioctl(struct file *file, unsigned int cmd,
>  #endif
>  
>  static int
> -fb_mmap(struct file *file, struct vm_area_struct * vma)
> +fb_mmap(struct file *file, struct vm_area_struct * vma,
> +	unsigned long map_flags)
>  {
>  	struct fb_info *info = file_fb_info(file);
>  	struct fb_ops *fb;
> @@ -1403,7 +1404,7 @@ fb_mmap(struct file *file, struct vm_area_struct * vma)
>  		 * SME protection is removed ahead of the call
>  		 */
>  		vma->vm_page_prot = pgprot_decrypted(vma->vm_page_prot);
> -		res = fb->fb_mmap(info, vma);
> +		res = fb->fb_mmap(info, vma, map_flags);
>  		mutex_unlock(&info->mm_lock);
>  		return res;
>  	}
> diff --git a/drivers/video/fbdev/ep93xx-fb.c b/drivers/video/fbdev/ep93xx-fb.c
> index 75f0db25d19f..e9622f04851a 100644
> --- a/drivers/video/fbdev/ep93xx-fb.c
> +++ b/drivers/video/fbdev/ep93xx-fb.c
> @@ -311,7 +311,8 @@ static int ep93xxfb_check_var(struct fb_var_screeninfo *var,
>  	return 0;
>  }
>  
> -static int ep93xxfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int ep93xxfb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	unsigned int offset = vma->vm_pgoff << PAGE_SHIFT;
>  
> diff --git a/drivers/video/fbdev/fb-puv3.c b/drivers/video/fbdev/fb-puv3.c
> index 88fa2e70a0bb..02e183ae1fbb 100644
> --- a/drivers/video/fbdev/fb-puv3.c
> +++ b/drivers/video/fbdev/fb-puv3.c
> @@ -640,7 +640,7 @@ static int unifb_pan_display(struct fb_var_screeninfo *var,
>  }
>  
>  int unifb_mmap(struct fb_info *info,
> -		    struct vm_area_struct *vma)
> +		    struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
>  
> diff --git a/drivers/video/fbdev/ffb.c b/drivers/video/fbdev/ffb.c
> index dda31e0a45af..c7fd60da4980 100644
> --- a/drivers/video/fbdev/ffb.c
> +++ b/drivers/video/fbdev/ffb.c
> @@ -35,7 +35,7 @@ static void ffb_imageblit(struct fb_info *, const struct fb_image *);
>  static void ffb_fillrect(struct fb_info *, const struct fb_fillrect *);
>  static void ffb_copyarea(struct fb_info *, const struct fb_copyarea *);
>  static int ffb_sync(struct fb_info *);
> -static int ffb_mmap(struct fb_info *, struct vm_area_struct *);
> +static int ffb_mmap(struct fb_info *, struct vm_area_struct *, unsigned long);
>  static int ffb_ioctl(struct fb_info *, unsigned int, unsigned long);
>  static int ffb_pan_display(struct fb_var_screeninfo *, struct fb_info *);
>  
> @@ -848,7 +848,8 @@ static struct sbus_mmap_map ffb_mmap_map[] = {
>  	{ .size = 0 }
>  };
>  
> -static int ffb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int ffb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct ffb_par *par = (struct ffb_par *)info->par;
>  
> diff --git a/drivers/video/fbdev/gbefb.c b/drivers/video/fbdev/gbefb.c
> index 1a242b1338e9..a6e04c834733 100644
> --- a/drivers/video/fbdev/gbefb.c
> +++ b/drivers/video/fbdev/gbefb.c
> @@ -1000,7 +1000,7 @@ static int gbefb_check_var(struct fb_var_screeninfo *var, struct fb_info *info)
>  }
>  
>  static int gbefb_mmap(struct fb_info *info,
> -			struct vm_area_struct *vma)
> +			struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	unsigned long size = vma->vm_end - vma->vm_start;
>  	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
> diff --git a/drivers/video/fbdev/igafb.c b/drivers/video/fbdev/igafb.c
> index 486f18897414..33664c1b71ae 100644
> --- a/drivers/video/fbdev/igafb.c
> +++ b/drivers/video/fbdev/igafb.c
> @@ -219,7 +219,7 @@ static void iga_blank_border(struct iga_par *par)
>  
>  #ifdef CONFIG_SPARC
>  static int igafb_mmap(struct fb_info *info,
> -		      struct vm_area_struct *vma)
> +		      struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	struct iga_par *par = (struct iga_par *)info->par;
>  	unsigned int size, page, map_size = 0;
> diff --git a/drivers/video/fbdev/leo.c b/drivers/video/fbdev/leo.c
> index 62e59dc90ee6..7b970f3ad500 100644
> --- a/drivers/video/fbdev/leo.c
> +++ b/drivers/video/fbdev/leo.c
> @@ -30,7 +30,7 @@ static int leo_setcolreg(unsigned, unsigned, unsigned, unsigned,
>  			 unsigned, struct fb_info *);
>  static int leo_blank(int, struct fb_info *);
>  
> -static int leo_mmap(struct fb_info *, struct vm_area_struct *);
> +static int leo_mmap(struct fb_info *, struct vm_area_struct *, unsigned long);
>  static int leo_ioctl(struct fb_info *, unsigned int, unsigned long);
>  static int leo_pan_display(struct fb_var_screeninfo *, struct fb_info *);
>  
> @@ -412,7 +412,8 @@ static struct sbus_mmap_map leo_mmap_map[] = {
>  	{ .size = 0 }
>  };
>  
> -static int leo_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int leo_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct leo_par *par = (struct leo_par *)info->par;
>  
> diff --git a/drivers/video/fbdev/omap/omapfb_main.c b/drivers/video/fbdev/omap/omapfb_main.c
> index 3479a47a3082..be1be6ab70a9 100644
> --- a/drivers/video/fbdev/omap/omapfb_main.c
> +++ b/drivers/video/fbdev/omap/omapfb_main.c
> @@ -1208,7 +1208,8 @@ static int omapfb_ioctl(struct fb_info *fbi, unsigned int cmd,
>  	return r;
>  }
>  
> -static int omapfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int omapfb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct omapfb_plane_struct *plane = info->par;
>  	struct omapfb_device *fbdev = plane->fbdev;
> diff --git a/drivers/video/fbdev/omap2/omapfb/omapfb-main.c b/drivers/video/fbdev/omap2/omapfb/omapfb-main.c
> index 1d7c012f09db..0866a8770464 100644
> --- a/drivers/video/fbdev/omap2/omapfb/omapfb-main.c
> +++ b/drivers/video/fbdev/omap2/omapfb/omapfb-main.c
> @@ -1096,7 +1096,8 @@ static const struct vm_operations_struct mmap_user_ops = {
>  	.close = mmap_user_close,
>  };
>  
> -static int omapfb_mmap(struct fb_info *fbi, struct vm_area_struct *vma)
> +static int omapfb_mmap(struct fb_info *fbi, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct omapfb_info *ofbi = FB2OFB(fbi);
>  	struct fb_fix_screeninfo *fix = &fbi->fix;
> diff --git a/drivers/video/fbdev/p9100.c b/drivers/video/fbdev/p9100.c
> index 1f6ee76af878..55e9a053dc68 100644
> --- a/drivers/video/fbdev/p9100.c
> +++ b/drivers/video/fbdev/p9100.c
> @@ -29,7 +29,8 @@ static int p9100_setcolreg(unsigned, unsigned, unsigned, unsigned,
>  			   unsigned, struct fb_info *);
>  static int p9100_blank(int, struct fb_info *);
>  
> -static int p9100_mmap(struct fb_info *, struct vm_area_struct *);
> +static int p9100_mmap(struct fb_info *, struct vm_area_struct *,
> +		      unsigned long);
>  static int p9100_ioctl(struct fb_info *, unsigned int, unsigned long);
>  
>  /*
> @@ -216,7 +217,8 @@ static struct sbus_mmap_map p9100_mmap_map[] = {
>  	{ 0,			0,		0		    }
>  };
>  
> -static int p9100_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int p9100_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	struct p9100_par *par = (struct p9100_par *)info->par;
>  
> diff --git a/drivers/video/fbdev/ps3fb.c b/drivers/video/fbdev/ps3fb.c
> index b269abd932aa..dbf0390289ed 100644
> --- a/drivers/video/fbdev/ps3fb.c
> +++ b/drivers/video/fbdev/ps3fb.c
> @@ -703,7 +703,8 @@ static int ps3fb_pan_display(struct fb_var_screeninfo *var,
>       *  As we have a virtual frame buffer, we need our own mmap function
>       */
>  
> -static int ps3fb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int ps3fb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	int r;
>  
> diff --git a/drivers/video/fbdev/pxa3xx-gcu.c b/drivers/video/fbdev/pxa3xx-gcu.c
> index 50bce45e7f3d..bed61712616e 100644
> --- a/drivers/video/fbdev/pxa3xx-gcu.c
> +++ b/drivers/video/fbdev/pxa3xx-gcu.c
> @@ -479,7 +479,8 @@ pxa3xx_gcu_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  }
>  
>  static int
> -pxa3xx_gcu_mmap(struct file *file, struct vm_area_struct *vma)
> +pxa3xx_gcu_mmap(struct file *file, struct vm_area_struct *vma,
> +		unsigned long map_flags)
>  {
>  	unsigned int size = vma->vm_end - vma->vm_start;
>  	struct pxa3xx_gcu_priv *priv = to_pxa3xx_gcu_priv(file);
> diff --git a/drivers/video/fbdev/sa1100fb.c b/drivers/video/fbdev/sa1100fb.c
> index fc2aaa5aca23..3bb625aaa3bc 100644
> --- a/drivers/video/fbdev/sa1100fb.c
> +++ b/drivers/video/fbdev/sa1100fb.c
> @@ -559,7 +559,7 @@ static int sa1100fb_blank(int blank, struct fb_info *info)
>  }
>  
>  static int sa1100fb_mmap(struct fb_info *info,
> -			 struct vm_area_struct *vma)
> +			 struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	struct sa1100fb_info *fbi =
>  		container_of(info, struct sa1100fb_info, fb);
> diff --git a/drivers/video/fbdev/sh_mobile_lcdcfb.c b/drivers/video/fbdev/sh_mobile_lcdcfb.c
> index c3a46506e47e..d66ebc40f939 100644
> --- a/drivers/video/fbdev/sh_mobile_lcdcfb.c
> +++ b/drivers/video/fbdev/sh_mobile_lcdcfb.c
> @@ -1618,7 +1618,8 @@ static int sh_mobile_lcdc_overlay_blank(int blank, struct fb_info *info)
>  }
>  
>  static int
> -sh_mobile_lcdc_overlay_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +sh_mobile_lcdc_overlay_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			    unsigned long map_flags)
>  {
>  	struct sh_mobile_lcdc_overlay *ovl = info->par;
>  
> @@ -2107,7 +2108,8 @@ static int sh_mobile_lcdc_blank(int blank, struct fb_info *info)
>  }
>  
>  static int
> -sh_mobile_lcdc_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +sh_mobile_lcdc_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct sh_mobile_lcdc_chan *ch = info->par;
>  
> diff --git a/drivers/video/fbdev/smscufx.c b/drivers/video/fbdev/smscufx.c
> index 449fceaf79d5..0e2fe19c0037 100644
> --- a/drivers/video/fbdev/smscufx.c
> +++ b/drivers/video/fbdev/smscufx.c
> @@ -775,7 +775,8 @@ static int ufx_set_vid_mode(struct ufx_data *dev, struct fb_var_screeninfo *var)
>  	return 0;
>  }
>  
> -static int ufx_ops_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int ufx_ops_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	unsigned long start = vma->vm_start;
>  	unsigned long size = vma->vm_end - vma->vm_start;
> diff --git a/drivers/video/fbdev/tcx.c b/drivers/video/fbdev/tcx.c
> index 54ad08854c94..8492eeb95a09 100644
> --- a/drivers/video/fbdev/tcx.c
> +++ b/drivers/video/fbdev/tcx.c
> @@ -31,7 +31,7 @@ static int tcx_setcolreg(unsigned, unsigned, unsigned, unsigned,
>  			 unsigned, struct fb_info *);
>  static int tcx_blank(int, struct fb_info *);
>  
> -static int tcx_mmap(struct fb_info *, struct vm_area_struct *);
> +static int tcx_mmap(struct fb_info *, struct vm_area_struct *, unsigned long);
>  static int tcx_ioctl(struct fb_info *, unsigned int, unsigned long);
>  static int tcx_pan_display(struct fb_var_screeninfo *, struct fb_info *);
>  
> @@ -297,7 +297,8 @@ static struct sbus_mmap_map __tcx_mmap_map[TCX_MMAP_ENTRIES] = {
>  	{ .size = 0 }
>  };
>  
> -static int tcx_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int tcx_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct tcx_par *par = (struct tcx_par *)info->par;
>  
> diff --git a/drivers/video/fbdev/udlfb.c b/drivers/video/fbdev/udlfb.c
> index 05ef657235df..81c393237da1 100644
> --- a/drivers/video/fbdev/udlfb.c
> +++ b/drivers/video/fbdev/udlfb.c
> @@ -317,7 +317,8 @@ static int dlfb_set_video_mode(struct dlfb_data *dev,
>  	return retval;
>  }
>  
> -static int dlfb_ops_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int dlfb_ops_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	unsigned long start = vma->vm_start;
>  	unsigned long size = vma->vm_end - vma->vm_start;
> diff --git a/drivers/video/fbdev/vermilion/vermilion.c b/drivers/video/fbdev/vermilion/vermilion.c
> index ce4c4729a5e8..21ba107cb070 100644
> --- a/drivers/video/fbdev/vermilion/vermilion.c
> +++ b/drivers/video/fbdev/vermilion/vermilion.c
> @@ -998,7 +998,8 @@ static int vmlfb_setcolreg(u_int regno, u_int red, u_int green, u_int blue,
>  	return 0;
>  }
>  
> -static int vmlfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> +static int vmlfb_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	struct vml_info *vinfo = container_of(info, struct vml_info, info);
>  	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
> diff --git a/drivers/video/fbdev/vfb.c b/drivers/video/fbdev/vfb.c
> index da653a080394..181b6dff95b6 100644
> --- a/drivers/video/fbdev/vfb.c
> +++ b/drivers/video/fbdev/vfb.c
> @@ -76,7 +76,7 @@ static int vfb_setcolreg(u_int regno, u_int red, u_int green, u_int blue,
>  static int vfb_pan_display(struct fb_var_screeninfo *var,
>  			   struct fb_info *info);
>  static int vfb_mmap(struct fb_info *info,
> -		    struct vm_area_struct *vma);
> +		    struct vm_area_struct *vma, unsigned long map_flags);
>  
>  static struct fb_ops vfb_ops = {
>  	.fb_read        = fb_sys_read,
> @@ -367,7 +367,7 @@ static int vfb_pan_display(struct fb_var_screeninfo *var,
>       */
>  
>  static int vfb_mmap(struct fb_info *info,
> -		    struct vm_area_struct *vma)
> +		    struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	return remap_vmalloc_range(vma, (void *)info->fix.smem_start, vma->vm_pgoff);
>  }
> diff --git a/drivers/xen/gntalloc.c b/drivers/xen/gntalloc.c
> index 1bf55a32a4b3..35ded2a8bba6 100644
> --- a/drivers/xen/gntalloc.c
> +++ b/drivers/xen/gntalloc.c
> @@ -502,7 +502,8 @@ static const struct vm_operations_struct gntalloc_vmops = {
>  	.close = gntalloc_vma_close,
>  };
>  
> -static int gntalloc_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int gntalloc_mmap(struct file *filp, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	struct gntalloc_file_private_data *priv = filp->private_data;
>  	struct gntalloc_vma_private_data *vm_priv;
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 82360594fa8e..46ea8822cb8f 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -972,7 +972,8 @@ static long gntdev_ioctl(struct file *flip,
>  	return 0;
>  }
>  
> -static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
> +static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	struct gntdev_priv *priv = flip->private_data;
>  	int index = vma->vm_pgoff;
> diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
> index feca75b07fdd..3a8278d72375 100644
> --- a/drivers/xen/privcmd.c
> +++ b/drivers/xen/privcmd.c
> @@ -818,7 +818,8 @@ static const struct vm_operations_struct privcmd_vm_ops = {
>  	.fault = privcmd_fault
>  };
>  
> -static int privcmd_mmap(struct file *file, struct vm_area_struct *vma)
> +static int privcmd_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	/* DONTCOPY is essential for Xen because copy_page_range doesn't know
>  	 * how to recreate these mappings */
> diff --git a/drivers/xen/xenbus/xenbus_dev_backend.c b/drivers/xen/xenbus/xenbus_dev_backend.c
> index 1126701e212e..ed7e81ae167a 100644
> --- a/drivers/xen/xenbus/xenbus_dev_backend.c
> +++ b/drivers/xen/xenbus/xenbus_dev_backend.c
> @@ -88,7 +88,8 @@ static long xenbus_backend_ioctl(struct file *file, unsigned int cmd,
>  	}
>  }
>  
> -static int xenbus_backend_mmap(struct file *file, struct vm_area_struct *vma)
> +static int xenbus_backend_mmap(struct file *file, struct vm_area_struct *vma,
> +			       unsigned long map_flags)
>  {
>  	size_t size = vma->vm_end - vma->vm_start;
>  
> diff --git a/drivers/xen/xenfs/xenstored.c b/drivers/xen/xenfs/xenstored.c
> index 82fd2a396d96..259ad78834a4 100644
> --- a/drivers/xen/xenfs/xenstored.c
> +++ b/drivers/xen/xenfs/xenstored.c
> @@ -30,7 +30,8 @@ static int xsd_kva_open(struct inode *inode, struct file *file)
>  	return 0;
>  }
>  
> -static int xsd_kva_mmap(struct file *file, struct vm_area_struct *vma)
> +static int xsd_kva_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>  	size_t size = vma->vm_end - vma->vm_start;
>  
> diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
> index 03c9e325bfbc..8aabe33926f9 100644
> --- a/fs/9p/vfs_file.c
> +++ b/fs/9p/vfs_file.c
> @@ -484,12 +484,13 @@ int v9fs_file_fsync_dotl(struct file *filp, loff_t start, loff_t end,
>  }
>  
>  static int
> -v9fs_file_mmap(struct file *filp, struct vm_area_struct *vma)
> +v9fs_file_mmap(struct file *filp, struct vm_area_struct *vma,
> +	       unsigned long map_flags)
>  {
>  	int retval;
>  
>  
> -	retval = generic_file_mmap(filp, vma);
> +	retval = generic_file_mmap(filp, vma, map_flags);
>  	if (!retval)
>  		vma->vm_ops = &v9fs_file_vm_ops;
>  
> @@ -497,7 +498,8 @@ v9fs_file_mmap(struct file *filp, struct vm_area_struct *vma)
>  }
>  
>  static int
> -v9fs_mmap_file_mmap(struct file *filp, struct vm_area_struct *vma)
> +v9fs_mmap_file_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	int retval;
>  	struct inode *inode;
> @@ -526,7 +528,7 @@ v9fs_mmap_file_mmap(struct file *filp, struct vm_area_struct *vma)
>  	}
>  	mutex_unlock(&v9inode->v_mutex);
>  
> -	retval = generic_file_mmap(filp, vma);
> +	retval = generic_file_mmap(filp, vma, map_flags);
>  	if (!retval)
>  		vma->vm_ops = &v9fs_mmap_file_vm_ops;
>  
> diff --git a/fs/aio.c b/fs/aio.c
> index dcad3a66748c..e07cabf73093 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -353,7 +353,8 @@ static const struct vm_operations_struct aio_ring_vm_ops = {
>  #endif
>  };
>  
> -static int aio_ring_mmap(struct file *file, struct vm_area_struct *vma)
> +static int aio_ring_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	vma->vm_flags |= VM_DONTEXPAND;
>  	vma->vm_ops = &aio_ring_vm_ops;
> diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
> index 9e75d8a39aac..53e129be33ea 100644
> --- a/fs/btrfs/file.c
> +++ b/fs/btrfs/file.c
> @@ -2262,7 +2262,9 @@ static const struct vm_operations_struct btrfs_file_vm_ops = {
>  	.page_mkwrite	= btrfs_page_mkwrite,
>  };
>  
> -static int btrfs_file_mmap(struct file	*filp, struct vm_area_struct *vma)
> +static int btrfs_file_mmap(struct file	*filp,
> +			   struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	struct address_space *mapping = filp->f_mapping;
>  
> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> index 1bc709fe330a..2673bb1cc0bb 100644
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
> @@ -1761,7 +1761,8 @@ static const struct vm_operations_struct ceph_vmops = {
>  	.page_mkwrite	= ceph_page_mkwrite,
>  };
>  
> -int ceph_mmap(struct file *file, struct vm_area_struct *vma)
> +int ceph_mmap(struct file *file, struct vm_area_struct *vma,
> +	      unsigned long map_flags)
>  {
>  	struct address_space *mapping = file->f_mapping;
>  
> diff --git a/fs/ceph/super.h b/fs/ceph/super.h
> index f02a2225fe42..8cf77043bdc6 100644
> --- a/fs/ceph/super.h
> +++ b/fs/ceph/super.h
> @@ -942,7 +942,8 @@ extern void ceph_put_fmode(struct ceph_inode_info *ci, int mode);
>  
>  /* addr.c */
>  extern const struct address_space_operations ceph_aops;
> -extern int ceph_mmap(struct file *file, struct vm_area_struct *vma);
> +extern int ceph_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags);
>  extern int ceph_uninline_data(struct file *filp, struct page *locked_page);
>  extern int ceph_pool_perm_check(struct ceph_inode_info *ci, int need);
>  extern void ceph_pool_perm_destroy(struct ceph_mds_client* mdsc);
> diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
> index 30bf89b1fd9a..c9efc42e4f34 100644
> --- a/fs/cifs/cifsfs.h
> +++ b/fs/cifs/cifsfs.h
> @@ -109,8 +109,10 @@ extern int cifs_lock(struct file *, int, struct file_lock *);
>  extern int cifs_fsync(struct file *, loff_t, loff_t, int);
>  extern int cifs_strict_fsync(struct file *, loff_t, loff_t, int);
>  extern int cifs_flush(struct file *, fl_owner_t id);
> -extern int cifs_file_mmap(struct file * , struct vm_area_struct *);
> -extern int cifs_file_strict_mmap(struct file * , struct vm_area_struct *);
> +extern int cifs_file_mmap(struct file * , struct vm_area_struct *,
> +			  unsigned long);
> +extern int cifs_file_strict_mmap(struct file * , struct vm_area_struct *,
> +				 unsigned long);
>  extern const struct file_operations cifs_dir_ops;
>  extern int cifs_dir_open(struct inode *inode, struct file *file);
>  extern int cifs_readdir(struct file *file, struct dir_context *ctx);
> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> index 0786f19d288f..e59d6e703fd8 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -3475,7 +3475,8 @@ static const struct vm_operations_struct cifs_file_vm_ops = {
>  	.page_mkwrite = cifs_page_mkwrite,
>  };
>  
> -int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
> +int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	int rc, xid;
>  	struct inode *inode = file_inode(file);
> @@ -3488,14 +3489,15 @@ int cifs_file_strict_mmap(struct file *file, struct vm_area_struct *vma)
>  			return rc;
>  	}
>  
> -	rc = generic_file_mmap(file, vma);
> +	rc = generic_file_mmap(file, vma, map_flags);
>  	if (rc == 0)
>  		vma->vm_ops = &cifs_file_vm_ops;
>  	free_xid(xid);
>  	return rc;
>  }
>  
> -int cifs_file_mmap(struct file *file, struct vm_area_struct *vma)
> +int cifs_file_mmap(struct file *file, struct vm_area_struct *vma,
> +		   unsigned long map_flags)
>  {
>  	int rc, xid;
>  
> @@ -3507,7 +3509,7 @@ int cifs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  		free_xid(xid);
>  		return rc;
>  	}
> -	rc = generic_file_mmap(file, vma);
> +	rc = generic_file_mmap(file, vma, map_flags);
>  	if (rc == 0)
>  		vma->vm_ops = &cifs_file_vm_ops;
>  	free_xid(xid);
> diff --git a/fs/coda/file.c b/fs/coda/file.c
> index 363402fcb3ed..902447f0c152 100644
> --- a/fs/coda/file.c
> +++ b/fs/coda/file.c
> @@ -61,7 +61,8 @@ coda_file_write_iter(struct kiocb *iocb, struct iov_iter *to)
>  }
>  
>  static int
> -coda_file_mmap(struct file *coda_file, struct vm_area_struct *vma)
> +coda_file_mmap(struct file *coda_file, struct vm_area_struct *vma,
> +	       unsigned long map_flags)
>  {
>  	struct coda_file_info *cfi;
>  	struct coda_inode_info *cii;
> @@ -96,7 +97,7 @@ coda_file_mmap(struct file *coda_file, struct vm_area_struct *vma)
>  	cfi->cfi_mapcount++;
>  	spin_unlock(&cii->c_lock);
>  
> -	return call_mmap(host_file, vma);
> +	return call_mmap(host_file, vma, map_flags);
>  }
>  
>  int coda_open(struct inode *coda_inode, struct file *coda_file)
> diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
> index c74ed3ca3372..c20617d9f0b4 100644
> --- a/fs/ecryptfs/file.c
> +++ b/fs/ecryptfs/file.c
> @@ -169,7 +169,8 @@ static int read_or_initialize_metadata(struct dentry *dentry)
>  	return rc;
>  }
>  
> -static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma)
> +static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	struct file *lower_file = ecryptfs_file_to_lower(file);
>  	/*
> @@ -179,7 +180,7 @@ static int ecryptfs_mmap(struct file *file, struct vm_area_struct *vma)
>  	 */
>  	if (!lower_file->f_op->mmap)
>  		return -ENODEV;
> -	return generic_file_mmap(file, vma);
> +	return generic_file_mmap(file, vma, map_flags);
>  }
>  
>  /**
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index ff3a3636a5ca..1fb8f39e14bb 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -118,10 +118,11 @@ static const struct vm_operations_struct ext2_dax_vm_ops = {
>  	.pfn_mkwrite	= ext2_dax_fault,
>  };
>  
> -static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	if (!IS_DAX(file_inode(file)))
> -		return generic_file_mmap(file, vma);
> +		return generic_file_mmap(file, vma, map_flags);
>  
>  	file_accessed(file);
>  	vma->vm_ops = &ext2_dax_vm_ops;
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 57dcaea762c3..362a1e5a8687 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -340,7 +340,8 @@ static const struct vm_operations_struct ext4_file_vm_ops = {
>  	.page_mkwrite   = ext4_page_mkwrite,
>  };
>  
> -static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct inode *inode = file->f_mapping->host;
>  
> diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
> index 843a0d99f7ea..9233437b6e81 100644
> --- a/fs/f2fs/file.c
> +++ b/fs/f2fs/file.c
> @@ -425,7 +425,8 @@ static loff_t f2fs_llseek(struct file *file, loff_t offset, int whence)
>  	return -EINVAL;
>  }
>  
> -static int f2fs_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int f2fs_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	struct inode *inode = file_inode(file);
>  	int err;
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index d66789804287..38f3cea418b0 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -2063,7 +2063,8 @@ static const struct vm_operations_struct fuse_file_vm_ops = {
>  	.page_mkwrite	= fuse_page_mkwrite,
>  };
>  
> -static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE))
>  		fuse_link_write_file(file);
> @@ -2073,7 +2074,8 @@ static int fuse_file_mmap(struct file *file, struct vm_area_struct *vma)
>  	return 0;
>  }
>  
> -static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma)
> +static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma,
> +			    unsigned long map_flags)
>  {
>  	/* Can't provide the coherency needed for MAP_SHARED */
>  	if (vma->vm_flags & VM_MAYSHARE)
> @@ -2081,7 +2083,7 @@ static int fuse_direct_mmap(struct file *file, struct vm_area_struct *vma)
>  
>  	invalidate_inode_pages2(file->f_mapping);
>  
> -	return generic_file_mmap(file, vma);
> +	return generic_file_mmap(file, vma, map_flags);
>  }
>  
>  static int convert_fuse_file_lock(struct fuse_conn *fc,
> diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> index 33a0cb5701a3..8bee89124bcf 100644
> --- a/fs/gfs2/file.c
> +++ b/fs/gfs2/file.c
> @@ -506,7 +506,8 @@ static const struct vm_operations_struct gfs2_vm_ops = {
>   * Returns: 0
>   */
>  
> -static int gfs2_mmap(struct file *file, struct vm_area_struct *vma)
> +static int gfs2_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct gfs2_inode *ip = GFS2_I(file->f_mapping->host);
>  
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 7c02b3f738e1..5261b67e7343 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -118,7 +118,8 @@ static void huge_pagevec_release(struct pagevec *pvec)
>  	pagevec_reinit(pvec);
>  }
>  
> -static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			       unsigned long map_flags)
>  {
>  	struct inode *inode = file_inode(file);
>  	loff_t len, vma_len;
> diff --git a/fs/kernfs/file.c b/fs/kernfs/file.c
> index 9698e51656b1..8a5e5be618b9 100644
> --- a/fs/kernfs/file.c
> +++ b/fs/kernfs/file.c
> @@ -467,7 +467,8 @@ static const struct vm_operations_struct kernfs_vm_ops = {
>  #endif
>  };
>  
> -static int kernfs_fop_mmap(struct file *file, struct vm_area_struct *vma)
> +static int kernfs_fop_mmap(struct file *file, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	struct kernfs_open_file *of = kernfs_of(file);
>  	const struct kernfs_ops *ops;
> diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
> index 6719c0be674d..f7f4c64202e7 100644
> --- a/fs/ncpfs/mmap.c
> +++ b/fs/ncpfs/mmap.c
> @@ -100,7 +100,8 @@ static const struct vm_operations_struct ncp_file_mmap =
>  
>  
>  /* This is used for a general mmap of a ncp file */
> -int ncp_mmap(struct file *file, struct vm_area_struct *vma)
> +int ncp_mmap(struct file *file, struct vm_area_struct *vma,
> +	     unsigned long map_flags)
>  {
>  	struct inode *inode = file_inode(file);
>  	
> diff --git a/fs/ncpfs/ncp_fs.h b/fs/ncpfs/ncp_fs.h
> index b9f69e1b1f43..c3a1da959ee3 100644
> --- a/fs/ncpfs/ncp_fs.h
> +++ b/fs/ncpfs/ncp_fs.h
> @@ -92,7 +92,7 @@ extern const struct file_operations ncp_file_operations;
>  int ncp_make_open(struct inode *, int);
>  
>  /* linux/fs/ncpfs/mmap.c */
> -int ncp_mmap(struct file *, struct vm_area_struct *);
> +int ncp_mmap(struct file *, struct vm_area_struct *, unsigned long);
>  
>  /* linux/fs/ncpfs/ncplib_kernel.c */
>  int ncp_make_closed(struct inode *);
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index af330c31f627..b476a3872e99 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -176,7 +176,8 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
>  EXPORT_SYMBOL_GPL(nfs_file_read);
>  
>  int
> -nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
> +nfs_file_mmap(struct file * file, struct vm_area_struct * vma,
> +	      unsigned long map_flags)
>  {
>  	struct inode *inode = file_inode(file);
>  	int	status;
> @@ -186,7 +187,7 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
>  	/* Note: generic_file_mmap() returns ENOSYS on nommu systems
>  	 *       so we call that before revalidating the mapping
>  	 */
> -	status = generic_file_mmap(file, vma);
> +	status = generic_file_mmap(file, vma, map_flags);
>  	if (!status) {
>  		vma->vm_ops = &nfs_file_vm_ops;
>  		status = nfs_revalidate_mapping(inode, file->f_mapping);
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index dc456416d2be..8b913079684d 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -370,7 +370,7 @@ int nfs_rename(struct inode *, struct dentry *,
>  int nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync);
>  loff_t nfs_file_llseek(struct file *, loff_t, int);
>  ssize_t nfs_file_read(struct kiocb *, struct iov_iter *);
> -int nfs_file_mmap(struct file *, struct vm_area_struct *);
> +int nfs_file_mmap(struct file *, struct vm_area_struct *, unsigned long);
>  ssize_t nfs_file_write(struct kiocb *, struct iov_iter *);
>  int nfs_file_release(struct inode *, struct file *);
>  int nfs_lock(struct file *, int, struct file_lock *);
> diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
> index c5fa3dee72fc..71c5a24d78ce 100644
> --- a/fs/nilfs2/file.c
> +++ b/fs/nilfs2/file.c
> @@ -126,7 +126,8 @@ static const struct vm_operations_struct nilfs_file_vm_ops = {
>  	.page_mkwrite	= nilfs_page_mkwrite,
>  };
>  
> -static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	file_accessed(file);
>  	vma->vm_ops = &nilfs_file_vm_ops;
> diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
> index 098f5c712569..4061b83fe7a8 100644
> --- a/fs/ocfs2/mmap.c
> +++ b/fs/ocfs2/mmap.c
> @@ -179,7 +179,8 @@ static const struct vm_operations_struct ocfs2_file_vm_ops = {
>  	.page_mkwrite	= ocfs2_page_mkwrite,
>  };
>  
> -int ocfs2_mmap(struct file *file, struct vm_area_struct *vma)
> +int ocfs2_mmap(struct file *file, struct vm_area_struct *vma,
> +	       unsigned long map_flags)
>  {
>  	int ret = 0, lock_level = 0;
>  
> diff --git a/fs/ocfs2/mmap.h b/fs/ocfs2/mmap.h
> index 1274ee0f1fe2..8ef3830197d3 100644
> --- a/fs/ocfs2/mmap.h
> +++ b/fs/ocfs2/mmap.h
> @@ -1,6 +1,7 @@
>  #ifndef OCFS2_MMAP_H
>  #define OCFS2_MMAP_H
>  
> -int ocfs2_mmap(struct file *file, struct vm_area_struct *vma);
> +int ocfs2_mmap(struct file *file, struct vm_area_struct *vma,
> +	       unsigned long map_flags);
>  
>  #endif  /* OCFS2_MMAP_H */
> diff --git a/fs/orangefs/file.c b/fs/orangefs/file.c
> index 28f38d813ad2..4e69319baf15 100644
> --- a/fs/orangefs/file.c
> +++ b/fs/orangefs/file.c
> @@ -584,7 +584,8 @@ static long orangefs_ioctl(struct file *file, unsigned int cmd, unsigned long ar
>  /*
>   * Memory map a region of a file.
>   */
> -static int orangefs_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int orangefs_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			      unsigned long map_flags)
>  {
>  	gossip_debug(GOSSIP_FILE_DEBUG,
>  		     "orangefs_file_mmap: called on %s\n",
> @@ -597,7 +598,7 @@ static int orangefs_file_mmap(struct file *file, struct vm_area_struct *vma)
>  	vma->vm_flags &= ~VM_RAND_READ;
>  
>  	/* Use readonly mmap since we cannot support writable maps. */
> -	return generic_file_readonly_mmap(file, vma);
> +	return generic_file_readonly_mmap(file, vma, map_flags);
>  }
>  
>  #define mapping_nrpages(idata) ((idata)->nrpages)
> diff --git a/fs/proc/inode.c b/fs/proc/inode.c
> index e250910cffc8..4b7d31616985 100644
> --- a/fs/proc/inode.c
> +++ b/fs/proc/inode.c
> @@ -277,15 +277,16 @@ static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned
>  }
>  #endif
>  
> -static int proc_reg_mmap(struct file *file, struct vm_area_struct *vma)
> +static int proc_reg_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	struct proc_dir_entry *pde = PDE(file_inode(file));
>  	int rv = -EIO;
> -	int (*mmap)(struct file *, struct vm_area_struct *);
> +	int (*mmap)(struct file *, struct vm_area_struct *, unsigned long);
>  	if (use_pde(pde)) {
>  		mmap = pde->proc_fops->mmap;
>  		if (mmap)
> -			rv = mmap(file, vma);
> +			rv = mmap(file, vma, map_flags);
>  		unuse_pde(pde);
>  	}
>  	return rv;
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 885d445afa0d..36463814ffc1 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -406,7 +406,8 @@ static int vmcore_remap_oldmem_pfn(struct vm_area_struct *vma,
>  		return remap_oldmem_pfn_range(vma, from, pfn, size, prot);
>  }
>  
> -static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
> +static int mmap_vmcore(struct file *file, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	size_t size = vma->vm_end - vma->vm_start;
>  	u64 start, end, len, tsz;
> @@ -485,7 +486,8 @@ static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
>  	return -EAGAIN;
>  }
>  #else
> -static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
> +static int mmap_vmcore(struct file *file, struct vm_area_struct *vma,
> +		       unsigned long map_flags)
>  {
>  	return -ENOSYS;
>  }
> diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
> index 3ac1f2387083..0c584bdb71b8 100644
> --- a/fs/ramfs/file-nommu.c
> +++ b/fs/ramfs/file-nommu.c
> @@ -32,7 +32,8 @@ static unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
>  						   unsigned long len,
>  						   unsigned long pgoff,
>  						   unsigned long flags);
> -static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma);
> +static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma,
> +			    unsigned long map_flags);
>  
>  static unsigned ramfs_mmap_capabilities(struct file *file)
>  {
> @@ -257,7 +258,8 @@ static unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
>  /*
>   * set up a mapping for shared memory segments
>   */
> -static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma)
> +static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma,
> +			    unsigned long map_flags)
>  {
>  	if (!(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
>  		return -ENOSYS;
> diff --git a/fs/romfs/mmap-nommu.c b/fs/romfs/mmap-nommu.c
> index 1118a0dc6b45..60a893b5e864 100644
> --- a/fs/romfs/mmap-nommu.c
> +++ b/fs/romfs/mmap-nommu.c
> @@ -65,7 +65,8 @@ static unsigned long romfs_get_unmapped_area(struct file *file,
>   * permit a R/O mapping to be made directly through onto an MTD device if
>   * possible
>   */
> -static int romfs_mmap(struct file *file, struct vm_area_struct *vma)
> +static int romfs_mmap(struct file *file, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	return vma->vm_flags & (VM_SHARED | VM_MAYSHARE) ? 0 : -ENOSYS;
>  }
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
> index f90a466ea5db..5850e2d534b9 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -1612,11 +1612,12 @@ static const struct vm_operations_struct ubifs_file_vm_ops = {
>  	.page_mkwrite = ubifs_vm_page_mkwrite,
>  };
>  
> -static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma)
> +static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	int err;
>  
> -	err = generic_file_mmap(file, vma);
> +	err = generic_file_mmap(file, vma, map_flags);
>  	if (err)
>  		return err;
>  	vma->vm_ops = &ubifs_file_vm_ops;
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index ec3e44fcf771..34bca28655c3 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -1119,7 +1119,7 @@ static const struct vm_operations_struct xfs_file_vm_ops = {
>  STATIC int
>  xfs_file_mmap(
>  	struct file	*filp,
> -	struct vm_area_struct *vma)
> +	struct vm_area_struct *vma, unsigned long map_flags)
>  {
>  	file_accessed(filp);
>  	vma->vm_ops = &xfs_file_vm_ops;
> diff --git a/include/drm/drm_drv.h b/include/drm/drm_drv.h
> index 71bbaaec836d..291244d5573e 100644
> --- a/include/drm/drm_drv.h
> +++ b/include/drm/drm_drv.h
> @@ -478,7 +478,8 @@ struct drm_driver {
>  	void *(*gem_prime_vmap)(struct drm_gem_object *obj);
>  	void (*gem_prime_vunmap)(struct drm_gem_object *obj, void *vaddr);
>  	int (*gem_prime_mmap)(struct drm_gem_object *obj,
> -				struct vm_area_struct *vma);
> +				struct vm_area_struct *vma,
> +				unsigned long map_flags);
>  
>  	/**
>  	 * @dumb_create:
> diff --git a/include/drm/drm_gem.h b/include/drm/drm_gem.h
> index 9c55c2acaa2b..30d201b7d906 100644
> --- a/include/drm/drm_gem.h
> +++ b/include/drm/drm_gem.h
> @@ -199,7 +199,8 @@ void drm_gem_vm_open(struct vm_area_struct *vma);
>  void drm_gem_vm_close(struct vm_area_struct *vma);
>  int drm_gem_mmap_obj(struct drm_gem_object *obj, unsigned long obj_size,
>  		     struct vm_area_struct *vma);
> -int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
> +int drm_gem_mmap(struct file *filp, struct vm_area_struct *vma,
> +		 unsigned long map_flags);
>  
>  /**
>   * drm_gem_object_get - acquire a GEM buffer object reference
> diff --git a/include/drm/drm_gem_cma_helper.h b/include/drm/drm_gem_cma_helper.h
> index 58a739bf15f1..08fb30b12d58 100644
> --- a/include/drm/drm_gem_cma_helper.h
> +++ b/include/drm/drm_gem_cma_helper.h
> @@ -74,7 +74,8 @@ int drm_gem_cma_dumb_create(struct drm_file *file_priv,
>  			    struct drm_mode_create_dumb *args);
>  
>  /* set vm_flags and we can change the VM attribute to other one at here */
> -int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma);
> +int drm_gem_cma_mmap(struct file *filp, struct vm_area_struct *vma,
> +		     unsigned long map_flags);
>  
>  /* allocate physical memory */
>  struct drm_gem_cma_object *drm_gem_cma_create(struct drm_device *drm,
> @@ -100,7 +101,8 @@ drm_gem_cma_prime_import_sg_table(struct drm_device *dev,
>  				  struct dma_buf_attachment *attach,
>  				  struct sg_table *sgt);
>  int drm_gem_cma_prime_mmap(struct drm_gem_object *obj,
> -			   struct vm_area_struct *vma);
> +			   struct vm_area_struct *vma,
> +			   unsigned long map_flags);
>  void *drm_gem_cma_prime_vmap(struct drm_gem_object *obj);
>  void drm_gem_cma_prime_vunmap(struct drm_gem_object *obj, void *vaddr);
>  
> diff --git a/include/drm/drm_legacy.h b/include/drm/drm_legacy.h
> index cf0e7d89bcdf..889510d3b9b8 100644
> --- a/include/drm/drm_legacy.h
> +++ b/include/drm/drm_legacy.h
> @@ -161,7 +161,8 @@ int drm_legacy_rmmap_locked(struct drm_device *d, struct drm_local_map *map);
>  void drm_legacy_master_rmmaps(struct drm_device *dev,
>  			      struct drm_master *master);
>  struct drm_local_map *drm_legacy_getsarea(struct drm_device *dev);
> -int drm_legacy_mmap(struct file *filp, struct vm_area_struct *vma);
> +int drm_legacy_mmap(struct file *filp, struct vm_area_struct *vma,
> +		    unsigned long map_flags);
>  
>  int drm_legacy_addbufs_agp(struct drm_device *d, struct drm_buf_desc *req);
>  int drm_legacy_addbufs_pci(struct drm_device *d, struct drm_buf_desc *req);
> diff --git a/include/linux/dma-buf.h b/include/linux/dma-buf.h
> index 79f27d60ec66..8f5be4af87f8 100644
> --- a/include/linux/dma-buf.h
> +++ b/include/linux/dma-buf.h
> @@ -246,7 +246,8 @@ struct dma_buf_ops {
>  	 *
>  	 * 0 on success or a negative error code on failure.
>  	 */
> -	int (*mmap)(struct dma_buf *, struct vm_area_struct *vma);
> +	int (*mmap)(struct dma_buf *, struct vm_area_struct *vma,
> +			unsigned long map_flags);
>  
>  	void *(*vmap)(struct dma_buf *);
>  	void (*vunmap)(struct dma_buf *, void *vaddr);
> @@ -401,7 +402,7 @@ void *dma_buf_kmap(struct dma_buf *, unsigned long);
>  void dma_buf_kunmap(struct dma_buf *, unsigned long, void *);
>  
>  int dma_buf_mmap(struct dma_buf *, struct vm_area_struct *,
> -		 unsigned long);
> +		 unsigned long, unsigned long);
>  void *dma_buf_vmap(struct dma_buf *);
>  void dma_buf_vunmap(struct dma_buf *, void *vaddr);
>  #endif /* __DMA_BUF_H__ */
> diff --git a/include/linux/fb.h b/include/linux/fb.h
> index a964d076b4dc..4b21f369f291 100644
> --- a/include/linux/fb.h
> +++ b/include/linux/fb.h
> @@ -308,7 +308,8 @@ struct fb_ops {
>  			unsigned long arg);
>  
>  	/* perform fb specific mmap */
> -	int (*fb_mmap)(struct fb_info *info, struct vm_area_struct *vma);
> +	int (*fb_mmap)(struct fb_info *info, struct vm_area_struct *vma,
> +			unsigned long map_flags);
>  
>  	/* get capability given var */
>  	void (*fb_get_caps)(struct fb_info *info, struct fb_blit_caps *caps,
> @@ -673,7 +674,8 @@ static inline void __fb_pad_aligned_buffer(u8 *dst, u32 d_pitch,
>  }
>  
>  /* drivers/video/fb_defio.c */
> -int fb_deferred_io_mmap(struct fb_info *info, struct vm_area_struct *vma);
> +int fb_deferred_io_mmap(struct fb_info *info, struct vm_area_struct *vma,
> +			unsigned long map_flags);
>  extern void fb_deferred_io_init(struct fb_info *info);
>  extern void fb_deferred_io_open(struct fb_info *info,
>  				struct inode *inode,
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 7d6079dceb39..2a4d8016bbf7 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1673,7 +1673,7 @@ struct file_operations {
>  	unsigned int (*poll) (struct file *, struct poll_table_struct *);
>  	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
>  	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
> -	int (*mmap) (struct file *, struct vm_area_struct *);
> +	int (*mmap) (struct file *, struct vm_area_struct *, unsigned long);
>  	int (*open) (struct inode *, struct file *);
>  	int (*flush) (struct file *, fl_owner_t id);
>  	int (*release) (struct inode *, struct file *);
> @@ -1743,9 +1743,10 @@ static inline ssize_t call_write_iter(struct file *file, struct kiocb *kio,
>  	return file->f_op->write_iter(kio, iter);
>  }
>  
> -static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
> +static inline int call_mmap(struct file *file, struct vm_area_struct *vma,
> +			    unsigned long map_flags)
>  {
> -	return file->f_op->mmap(file, vma);
> +	return file->f_op->mmap(file, vma, map_flags);
>  }
>  
>  ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
> @@ -2881,8 +2882,10 @@ extern int set_blocksize(struct block_device *, int);
>  extern int sb_set_blocksize(struct super_block *, int);
>  extern int sb_min_blocksize(struct super_block *, int);
>  
> -extern int generic_file_mmap(struct file *, struct vm_area_struct *);
> -extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
> +extern int generic_file_mmap(struct file *, struct vm_area_struct *,
> +			     unsigned long);
> +extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *,
> +				      unsigned long);
>  extern ssize_t generic_write_checks(struct kiocb *, struct iov_iter *);
>  extern ssize_t generic_file_read_iter(struct kiocb *, struct iov_iter *);
>  extern ssize_t __generic_file_write_iter(struct kiocb *, struct iov_iter *);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 39db8e54c5d5..c0a38d2275ca 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2095,7 +2095,7 @@ extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned lo
>  
>  extern unsigned long mmap_region(struct file *file, unsigned long addr,
>  	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
> -	struct list_head *uf);
> +	struct list_head *uf, unsigned long map_flags);
>  extern unsigned long do_mmap(struct file *file, unsigned long addr,
>  	unsigned long len, unsigned long prot, unsigned long flags,
>  	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate,
> diff --git a/include/media/v4l2-dev.h b/include/media/v4l2-dev.h
> index e657614521e3..498f9dd51337 100644
> --- a/include/media/v4l2-dev.h
> +++ b/include/media/v4l2-dev.h
> @@ -158,7 +158,7 @@ struct v4l2_file_operations {
>  #endif
>  	unsigned long (*get_unmapped_area) (struct file *, unsigned long,
>  				unsigned long, unsigned long, unsigned long);
> -	int (*mmap) (struct file *, struct vm_area_struct *);
> +	int (*mmap) (struct file *, struct vm_area_struct *, unsigned long);
>  	int (*open) (struct file *);
>  	int (*release) (struct file *);
>  };
> diff --git a/include/media/v4l2-mem2mem.h b/include/media/v4l2-mem2mem.h
> index e157d5c9b224..87777f3b59c8 100644
> --- a/include/media/v4l2-mem2mem.h
> +++ b/include/media/v4l2-mem2mem.h
> @@ -600,7 +600,8 @@ int v4l2_m2m_ioctl_streamon(struct file *file, void *fh,
>  				enum v4l2_buf_type type);
>  int v4l2_m2m_ioctl_streamoff(struct file *file, void *fh,
>  				enum v4l2_buf_type type);
> -int v4l2_m2m_fop_mmap(struct file *file, struct vm_area_struct *vma);
> +int v4l2_m2m_fop_mmap(struct file *file, struct vm_area_struct *vma,
> +		      unsigned long map_flags);
>  unsigned int v4l2_m2m_fop_poll(struct file *file, poll_table *wait);
>  
>  #endif /* _MEDIA_V4L2_MEM2MEM_H */
> diff --git a/include/media/videobuf2-v4l2.h b/include/media/videobuf2-v4l2.h
> index 036127c54bbf..55ee04a99bd5 100644
> --- a/include/media/videobuf2-v4l2.h
> +++ b/include/media/videobuf2-v4l2.h
> @@ -255,7 +255,8 @@ int vb2_ioctl_expbuf(struct file *file, void *priv,
>  
>  /* struct v4l2_file_operations helpers */
>  
> -int vb2_fop_mmap(struct file *file, struct vm_area_struct *vma);
> +int vb2_fop_mmap(struct file *file, struct vm_area_struct *vma,
> +		 unsigned long map_flags);
>  int vb2_fop_release(struct file *file);
>  int _vb2_fop_release(struct file *file, struct mutex *lock);
>  ssize_t vb2_fop_write(struct file *file, const char __user *buf,
> diff --git a/include/misc/cxl.h b/include/misc/cxl.h
> index 480d50a0b8ba..2c356a8126ec 100644
> --- a/include/misc/cxl.h
> +++ b/include/misc/cxl.h
> @@ -266,7 +266,8 @@ int cxl_start_work(struct cxl_context *ctx,
>  int cxl_fd_open(struct inode *inode, struct file *file);
>  int cxl_fd_release(struct inode *inode, struct file *file);
>  long cxl_fd_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
> -int cxl_fd_mmap(struct file *file, struct vm_area_struct *vm);
> +int cxl_fd_mmap(struct file *file, struct vm_area_struct *vm,
> +		unsigned long map_flags);
>  unsigned int cxl_fd_poll(struct file *file, struct poll_table_struct *poll);
>  ssize_t cxl_fd_read(struct file *file, char __user *buf, size_t count,
>  			   loff_t *off);
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 8828b4c3a190..96a82d0d00b0 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -411,7 +411,8 @@ static struct mempolicy *shm_get_policy(struct vm_area_struct *vma,
>  }
>  #endif
>  
> -static int shm_mmap(struct file *file, struct vm_area_struct *vma)
> +static int shm_mmap(struct file *file, struct vm_area_struct *vma,
> +		    unsigned long map_flags)
>  {
>  	struct shm_file_data *sfd = shm_file_data(file);
>  	int ret;
> @@ -424,7 +425,7 @@ static int shm_mmap(struct file *file, struct vm_area_struct *vma)
>  	if (ret)
>  		return ret;
>  
> -	ret = call_mmap(sfd->file, vma);
> +	ret = call_mmap(sfd->file, vma, map_flags);
>  	if (ret) {
>  		shm_close(vma);
>  		return ret;
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 3e691b75b2db..3c2b555e302f 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -5255,7 +5255,8 @@ static const struct vm_operations_struct perf_mmap_vmops = {
>  	.page_mkwrite	= perf_mmap_fault,
>  };
>  
> -static int perf_mmap(struct file *file, struct vm_area_struct *vma)
> +static int perf_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct perf_event *event = file->private_data;
>  	unsigned long user_locked, user_lock_limit;
> diff --git a/kernel/kcov.c b/kernel/kcov.c
> index cd771993f96f..453c484ac00a 100644
> --- a/kernel/kcov.c
> +++ b/kernel/kcov.c
> @@ -132,7 +132,8 @@ void kcov_task_exit(struct task_struct *t)
>  	kcov_put(kcov);
>  }
>  
> -static int kcov_mmap(struct file *filep, struct vm_area_struct *vma)
> +static int kcov_mmap(struct file *filep, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	int res = 0;
>  	void *area;
> diff --git a/kernel/relay.c b/kernel/relay.c
> index 39a9dfc69486..58dee7ee8dbb 100644
> --- a/kernel/relay.c
> +++ b/kernel/relay.c
> @@ -906,7 +906,8 @@ static int relay_file_open(struct inode *inode, struct file *filp)
>   *
>   *	Calls upon relay_mmap_buf() to map the file into user space.
>   */
> -static int relay_file_mmap(struct file *filp, struct vm_area_struct *vma)
> +static int relay_file_mmap(struct file *filp, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	struct rchan_buf *buf = filp->private_data;
>  	return relay_mmap_buf(buf, vma);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 9d21afd692b9..f1fb5a7ccdfb 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2580,7 +2580,8 @@ const struct vm_operations_struct generic_file_vm_ops = {
>  
>  /* This is used for a general mmap of a disk file */
>  
> -int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
> +int generic_file_mmap(struct file * file, struct vm_area_struct * vma,
> +		      unsigned long map_flags)
>  {
>  	struct address_space *mapping = file->f_mapping;
>  
> @@ -2594,18 +2595,22 @@ int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
>  /*
>   * This is for filesystems which do not implement ->writepage.
>   */
> -int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma)
> +int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma,
> +			       unsigned long map_flags)
>  {
>  	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE))
>  		return -EINVAL;
> -	return generic_file_mmap(file, vma);
> +	return generic_file_mmap(file, vma, map_flags);
>  }
>  #else
> -int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
> +int generic_file_mmap(struct file * file, struct vm_area_struct * vma,
> +		      unsigned long map_flags)
>  {
>  	return -ENOSYS;
>  }
> -int generic_file_readonly_mmap(struct file * file, struct vm_area_struct * vma)
> +int generic_file_readonly_mmap(struct file * file,
> +			       struct vm_area_struct * vma,
> +			       unsigned long map_flags)
>  {
>  	return -ENOSYS;
>  }
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 4c5981651407..77d5aecf49dc 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1465,7 +1465,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  			vm_flags |= VM_NORESERVE;
>  	}
>  
> -	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf);
> +	addr = mmap_region(file, addr, len, vm_flags, pgoff, uf, 0);
>  	if (!IS_ERR_VALUE(addr) &&
>  	    ((vm_flags & VM_LOCKED) ||
>  	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
> @@ -1602,7 +1602,7 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
>  
>  unsigned long mmap_region(struct file *file, unsigned long addr,
>  		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
> -		struct list_head *uf)
> +		struct list_head *uf, unsigned long map_flags)
>  {
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma, *prev;
> @@ -1687,7 +1687,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  		 * new file must not have been exposed to user-space, yet.
>  		 */
>  		vma->vm_file = get_file(file);
> -		error = call_mmap(file, vma);
> +		error = call_mmap(file, vma, map_flags);
>  		if (error)
>  			goto unmap_and_free_vma;
>  
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 53d5175a5c14..2392aa3f11f2 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1089,7 +1089,7 @@ static int do_mmap_shared_file(struct vm_area_struct *vma)
>  {
>  	int ret;
>  
> -	ret = call_mmap(vma->vm_file, vma);
> +	ret = call_mmap(vma->vm_file, vma, map_flags);
>  	if (ret == 0) {
>  		vma->vm_region->vm_top = vma->vm_region->vm_end;
>  		return 0;
> @@ -1120,7 +1120,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
>  	 * - VM_MAYSHARE will be set if it may attempt to share
>  	 */
>  	if (capabilities & NOMMU_MAP_DIRECT) {
> -		ret = call_mmap(vma->vm_file, vma);
> +		ret = call_mmap(vma->vm_file, vma, map_flags);
>  		if (ret == 0) {
>  			/* shouldn't return success if we're not sharing */
>  			BUG_ON(!(vma->vm_flags & VM_MAYSHARE));
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ace53a582be5..d40318dd26b3 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2132,7 +2132,8 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
>  	return retval;
>  }
>  
> -static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
> +static int shmem_mmap(struct file *file, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	file_accessed(file);
>  	vma->vm_ops = &shmem_vm_ops;
> diff --git a/net/socket.c b/net/socket.c
> index c729625eb5d3..6258fcf61891 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -115,7 +115,8 @@ unsigned int sysctl_net_busy_poll __read_mostly;
>  
>  static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to);
>  static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from);
> -static int sock_mmap(struct file *file, struct vm_area_struct *vma);
> +static int sock_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags);
>  
>  static int sock_close(struct inode *inode, struct file *file);
>  static unsigned int sock_poll(struct file *file,
> @@ -1114,7 +1115,8 @@ static unsigned int sock_poll(struct file *file, poll_table *wait)
>  	return busy_flag | sock->ops->poll(file, sock, wait);
>  }
>  
> -static int sock_mmap(struct file *file, struct vm_area_struct *vma)
> +static int sock_mmap(struct file *file, struct vm_area_struct *vma,
> +		     unsigned long map_flags)
>  {
>  	struct socket *sock = file->private_data;
>  
> diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
> index 00eed842c491..802c801a38dd 100644
> --- a/security/selinux/selinuxfs.c
> +++ b/security/selinux/selinuxfs.c
> @@ -215,7 +215,8 @@ static ssize_t sel_read_handle_status(struct file *filp, char __user *buf,
>  }
>  
>  static int sel_mmap_handle_status(struct file *filp,
> -				  struct vm_area_struct *vma)
> +				  struct vm_area_struct *vma,
> +				  unsigned long map_flags)
>  {
>  	struct page    *status = filp->private_data;
>  	unsigned long	size = vma->vm_end - vma->vm_start;
> @@ -444,7 +445,8 @@ static const struct vm_operations_struct sel_mmap_policy_ops = {
>  	.page_mkwrite = sel_mmap_policy_fault,
>  };
>  
> -static int sel_mmap_policy(struct file *filp, struct vm_area_struct *vma)
> +static int sel_mmap_policy(struct file *filp, struct vm_area_struct *vma,
> +			   unsigned long map_flags)
>  {
>  	if (vma->vm_flags & VM_SHARED) {
>  		/* do not allow mprotect to make mapping writable */
> diff --git a/sound/core/compress_offload.c b/sound/core/compress_offload.c
> index fec1dfdb14ad..884cefaf906e 100644
> --- a/sound/core/compress_offload.c
> +++ b/sound/core/compress_offload.c
> @@ -391,7 +391,8 @@ static ssize_t snd_compr_read(struct file *f, char __user *buf,
>  	return retval;
>  }
>  
> -static int snd_compr_mmap(struct file *f, struct vm_area_struct *vma)
> +static int snd_compr_mmap(struct file *f, struct vm_area_struct *vma,
> +			  unsigned long map_flags)
>  {
>  	return -ENXIO;
>  }
> diff --git a/sound/core/hwdep.c b/sound/core/hwdep.c
> index a73baa1242be..ecff4054196a 100644
> --- a/sound/core/hwdep.c
> +++ b/sound/core/hwdep.c
> @@ -260,7 +260,8 @@ static long snd_hwdep_ioctl(struct file * file, unsigned int cmd,
>  	return -ENOTTY;
>  }
>  
> -static int snd_hwdep_mmap(struct file * file, struct vm_area_struct * vma)
> +static int snd_hwdep_mmap(struct file * file, struct vm_area_struct * vma,
> +			  unsigned long map_flags)
>  {
>  	struct snd_hwdep *hw = file->private_data;
>  	if (hw->ops.mmap)
> diff --git a/sound/core/info.c b/sound/core/info.c
> index bcf6a48cc70d..6551d90aac2c 100644
> --- a/sound/core/info.c
> +++ b/sound/core/info.c
> @@ -232,7 +232,8 @@ static long snd_info_entry_ioctl(struct file *file, unsigned int cmd,
>  				   file, cmd, arg);
>  }
>  
> -static int snd_info_entry_mmap(struct file *file, struct vm_area_struct *vma)
> +static int snd_info_entry_mmap(struct file *file, struct vm_area_struct *vma,
> +			       unsigned long map_flags)
>  {
>  	struct inode *inode = file_inode(file);
>  	struct snd_info_private_data *data;
> diff --git a/sound/core/init.c b/sound/core/init.c
> index 32ebe2f6bc59..e0bd35af9f8a 100644
> --- a/sound/core/init.c
> +++ b/sound/core/init.c
> @@ -354,7 +354,8 @@ static long snd_disconnect_ioctl(struct file *file,
>  	return -ENODEV;
>  }
>  
> -static int snd_disconnect_mmap(struct file *file, struct vm_area_struct *vma)
> +static int snd_disconnect_mmap(struct file *file, struct vm_area_struct *vma,
> +			       unsigned long map_flags)
>  {
>  	return -ENODEV;
>  }
> diff --git a/sound/core/oss/pcm_oss.c b/sound/core/oss/pcm_oss.c
> index e49f448ee04f..abcace0d7234 100644
> --- a/sound/core/oss/pcm_oss.c
> +++ b/sound/core/oss/pcm_oss.c
> @@ -2716,7 +2716,8 @@ static unsigned int snd_pcm_oss_poll(struct file *file, poll_table * wait)
>  	return mask;
>  }
>  
> -static int snd_pcm_oss_mmap(struct file *file, struct vm_area_struct *area)
> +static int snd_pcm_oss_mmap(struct file *file, struct vm_area_struct *area,
> +			    unsigned long map_flags)
>  {
>  	struct snd_pcm_oss_file *pcm_oss_file;
>  	struct snd_pcm_substream *substream = NULL;
> diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
> index 2fec2feac387..e754e9900415 100644
> --- a/sound/core/pcm_native.c
> +++ b/sound/core/pcm_native.c
> @@ -3498,7 +3498,8 @@ int snd_pcm_mmap_data(struct snd_pcm_substream *substream, struct file *file,
>  }
>  EXPORT_SYMBOL(snd_pcm_mmap_data);
>  
> -static int snd_pcm_mmap(struct file *file, struct vm_area_struct *area)
> +static int snd_pcm_mmap(struct file *file, struct vm_area_struct *area,
> +			unsigned long map_flags)
>  {
>  	struct snd_pcm_file * pcm_file;
>  	struct snd_pcm_substream *substream;	
> diff --git a/sound/oss/soundcard.c b/sound/oss/soundcard.c
> index b70c7c8f9c5d..b6e8ba2ec452 100644
> --- a/sound/oss/soundcard.c
> +++ b/sound/oss/soundcard.c
> @@ -420,7 +420,8 @@ static unsigned int sound_poll(struct file *file, poll_table * wait)
>  	return 0;
>  }
>  
> -static int sound_mmap(struct file *file, struct vm_area_struct *vma)
> +static int sound_mmap(struct file *file, struct vm_area_struct *vma,
> +		      unsigned long map_flags)
>  {
>  	int dev_class;
>  	unsigned long size;
> diff --git a/sound/oss/swarm_cs4297a.c b/sound/oss/swarm_cs4297a.c
> index 97899352b15f..4a020d2a53ab 100644
> --- a/sound/oss/swarm_cs4297a.c
> +++ b/sound/oss/swarm_cs4297a.c
> @@ -1962,7 +1962,8 @@ static unsigned int cs4297a_poll(struct file *file,
>  }
>  
>  
> -static int cs4297a_mmap(struct file *file, struct vm_area_struct *vma)
> +static int cs4297a_mmap(struct file *file, struct vm_area_struct *vma,
> +			unsigned long map_flags)
>  {
>          /* XXXKW currently no mmap support */
>          return -EINVAL;
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 4d81f6ded88e..ab7af0295f2a 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -2353,7 +2353,8 @@ static const struct vm_operations_struct kvm_vcpu_vm_ops = {
>  	.fault = kvm_vcpu_fault,
>  };
>  
> -static int kvm_vcpu_mmap(struct file *file, struct vm_area_struct *vma)
> +static int kvm_vcpu_mmap(struct file *file, struct vm_area_struct *vma,
> +			 unsigned long map_flags)
>  {
>  	vma->vm_ops = &kvm_vcpu_vm_ops;
>  	return 0;
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
