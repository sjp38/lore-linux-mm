Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 48F456B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 06:02:07 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm1so2526675bkc.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 03:02:05 -0700 (PDT)
Subject: Re: [PATCH v3 10/10] mm: kill vma flag VM_RESERVED and
 mm->reserved_vm counter
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20120731104239.20515.702.stgit@zurg>
References: <20120731103724.20515.60334.stgit@zurg>
	 <20120731104239.20515.702.stgit@zurg>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Oct 2012 12:02:01 +0200
Message-ID: <1349776921.21172.4091.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>, Alex Williamson <alex.williamson@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

On Tue, 2012-07-31 at 14:42 +0400, Konstantin Khlebnikov wrote:
> A long time ago, in v2.4, VM_RESERVED kept swapout process off VMA,
> currently it lost original meaning but still has some effects:
> 
>  | effect                 | alternative flags
> -+------------------------+---------------------------------------------
> 1| account as reserved_vm | VM_IO
> 2| skip in core dump      | VM_IO, VM_DONTDUMP
> 3| do not merge or expand | VM_IO, VM_DONTEXPAND, VM_HUGETLB, VM_PFNMAP
> 4| do not mlock           | VM_IO, VM_DONTEXPAND, VM_HUGETLB, VM_PFNMAP
> 
> This patch removes reserved_vm counter from mm_struct.
> Seems like nobody cares about it, it does not exported into userspace directly,
> it only reduces total_vm showed in proc.
> 
> Thus VM_RESERVED can be replaced with VM_IO or pair VM_DONTEXPAND | VM_DONTDUMP.
> 
> remap_pfn_range() and io_remap_pfn_range() set VM_IO|VM_DONTEXPAND|VM_DONTDUMP.
> remap_vmalloc_range() set VM_DONTEXPAND | VM_DONTDUMP.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Hugh Dickins <hughd@google.com>
> ---
>  Documentation/vm/unevictable-lru.txt             |    4 ++--
>  arch/alpha/kernel/pci-sysfs.c                    |    2 +-
>  arch/ia64/kernel/perfmon.c                       |    2 +-
>  arch/ia64/mm/init.c                              |    3 ++-
>  arch/powerpc/kvm/book3s_hv.c                     |    2 +-
>  arch/sparc/kernel/pci.c                          |    2 +-
>  arch/unicore32/kernel/process.c                  |    2 +-
>  arch/x86/xen/mmu.c                               |    3 +--
>  drivers/char/mbcs.c                              |    2 +-
>  drivers/char/mem.c                               |    2 +-
>  drivers/char/mspec.c                             |    2 +-
>  drivers/gpu/drm/drm_gem.c                        |    2 +-
>  drivers/gpu/drm/drm_vm.c                         |   10 ++--------
>  drivers/gpu/drm/exynos/exynos_drm_gem.c          |    2 +-
>  drivers/gpu/drm/gma500/framebuffer.c             |    3 +--
>  drivers/gpu/drm/ttm/ttm_bo_vm.c                  |    4 ++--
>  drivers/gpu/drm/udl/udl_fb.c                     |    2 +-
>  drivers/infiniband/hw/ehca/ehca_uverbs.c         |    4 ++--
>  drivers/infiniband/hw/ipath/ipath_file_ops.c     |    2 +-
>  drivers/infiniband/hw/qib/qib_file_ops.c         |    2 +-
>  drivers/media/video/meye.c                       |    2 +-
>  drivers/media/video/omap/omap_vout.c             |    2 +-
>  drivers/media/video/sn9c102/sn9c102_core.c       |    3 +--
>  drivers/media/video/usbvision/usbvision-video.c  |    3 +--
>  drivers/media/video/videobuf-dma-sg.c            |    2 +-
>  drivers/media/video/videobuf-vmalloc.c           |    2 +-
>  drivers/media/video/videobuf2-memops.c           |    2 +-
>  drivers/media/video/vino.c                       |    2 +-
>  drivers/misc/carma/carma-fpga.c                  |    2 --
>  drivers/misc/sgi-gru/grufile.c                   |    5 ++---
>  drivers/mtd/mtdchar.c                            |    2 +-
>  drivers/scsi/sg.c                                |    2 +-
>  drivers/staging/media/easycap/easycap_main.c     |    2 +-
>  drivers/staging/omapdrm/omap_gem_dmabuf.c        |    2 +-
>  drivers/staging/tidspbridge/rmgr/drv_interface.c |    2 +-
>  drivers/uio/uio.c                                |    4 +---
>  drivers/usb/mon/mon_bin.c                        |    2 +-
>  drivers/video/68328fb.c                          |    2 +-
>  drivers/video/aty/atyfb_base.c                   |    3 +--
>  drivers/video/fb-puv3.c                          |    3 +--
>  drivers/video/fb_defio.c                         |    2 +-
>  drivers/video/fbmem.c                            |    3 +--
>  drivers/video/gbefb.c                            |    2 +-
>  drivers/video/omap2/omapfb/omapfb-main.c         |    2 +-
>  drivers/video/sbuslib.c                          |    5 ++---
>  drivers/video/smscufx.c                          |    1 -
>  drivers/video/udlfb.c                            |    1 -
>  drivers/video/vermilion/vermilion.c              |    1 -
>  drivers/video/vfb.c                              |    1 -
>  drivers/xen/gntalloc.c                           |    2 +-
>  drivers/xen/gntdev.c                             |    2 +-
>  drivers/xen/privcmd.c                            |    3 ++-
>  fs/binfmt_elf.c                                  |    2 +-
>  fs/binfmt_elf_fdpic.c                            |    2 +-
>  fs/hugetlbfs/inode.c                             |    2 +-
>  fs/proc/task_mmu.c                               |    2 +-
>  include/linux/mempolicy.h                        |    2 +-
>  include/linux/mm.h                               |    3 +--
>  include/linux/mm_types.h                         |    1 -
>  kernel/events/core.c                             |    2 +-
>  mm/ksm.c                                         |    3 +--
>  mm/memory.c                                      |   11 +++++------
>  mm/mlock.c                                       |    2 +-
>  mm/mmap.c                                        |    2 --
>  mm/nommu.c                                       |    2 +-
>  mm/vmalloc.c                                     |    3 +--
>  security/selinux/selinuxfs.c                     |    2 +-
>  sound/core/pcm_native.c                          |    6 +++---
>  sound/usb/usx2y/us122l.c                         |    2 +-
>  sound/usb/usx2y/usX2Yhwdep.c                     |    2 +-
>  sound/usb/usx2y/usx2yhwdeppcm.c                  |    2 +-
>  71 files changed, 78 insertions(+), 106 deletions(-)


It seems drivers/vfio/pci/vfio_pci.c uses VM_RESERVED

  CC [M]  drivers/watchdog/advantechwdt.o
drivers/vfio/pci/vfio_pci.c: In function a??vfio_pci_mmapa??:
drivers/vfio/pci/vfio_pci.c:464:28: erreur: a??VM_RESERVEDa?? undeclared (first use in this function)
drivers/vfio/pci/vfio_pci.c:464:28: note: each undeclared identifier is reported only once for each function it appears in



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
