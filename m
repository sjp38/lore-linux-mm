Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 98E496B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:34:07 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so4878076lbj.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:34:05 -0700 (PDT)
Subject: [PATCH v3 00/10] mm: vma->vm_flags diet
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:34:01 +0400
Message-ID: <20120731102546.20182.8450.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

This patchset kills some VM_* flags in vma->vm_flags,
as result there appears five free bits.

Changes since v2 [ https://lkml.org/lkml/2012/4/7/67 ]

* killing VM_EXECUTABLE combined back into single patch
* new (the biggest one) patch which kills VM_RESERVED

---

Konstantin Khlebnikov (8):
      mm, x86, pat: rework linear pfn-mmap tracking
      mm: introduce arch-specific vma flag VM_ARCH_1
      mm: kill vma flag VM_INSERTPAGE
      mm: kill vma flag VM_CAN_NONLINEAR
      mm: use mm->exe_file instead of first VM_EXECUTABLE vma->vm_file
      mm: kill vma flag VM_EXECUTABLE and mm->num_exe_file_vmas
      mm: prepare VM_DONTDUMP for using in drivers
      mm: kill vma flag VM_RESERVED and mm->reserved_vm counter

Suresh Siddha (2):
      x86, pat: remove the dependency on 'vm_pgoff' in track/untrack pfn vma routines
      x86, pat: separate the pfn attribute tracking for remap_pfn_range and vm_insert_pfn


 Documentation/vm/unevictable-lru.txt             |    4 -
 arch/alpha/kernel/pci-sysfs.c                    |    2 
 arch/ia64/kernel/perfmon.c                       |    2 
 arch/ia64/mm/init.c                              |    3 -
 arch/powerpc/kvm/book3s_hv.c                     |    2 
 arch/powerpc/oprofile/cell/spu_task_sync.c       |   15 +---
 arch/sparc/kernel/pci.c                          |    2 
 arch/tile/mm/elf.c                               |   19 ++---
 arch/unicore32/kernel/process.c                  |    2 
 arch/x86/mm/pat.c                                |   89 ++++++++++++++++------
 arch/x86/xen/mmu.c                               |    3 -
 drivers/char/mbcs.c                              |    2 
 drivers/char/mem.c                               |    2 
 drivers/char/mspec.c                             |    2 
 drivers/gpu/drm/drm_gem.c                        |    2 
 drivers/gpu/drm/drm_vm.c                         |   10 --
 drivers/gpu/drm/exynos/exynos_drm_gem.c          |    2 
 drivers/gpu/drm/gma500/framebuffer.c             |    3 -
 drivers/gpu/drm/ttm/ttm_bo_vm.c                  |    4 -
 drivers/gpu/drm/udl/udl_fb.c                     |    2 
 drivers/infiniband/hw/ehca/ehca_uverbs.c         |    4 -
 drivers/infiniband/hw/ipath/ipath_file_ops.c     |    2 
 drivers/infiniband/hw/qib/qib_file_ops.c         |    2 
 drivers/media/video/meye.c                       |    2 
 drivers/media/video/omap/omap_vout.c             |    2 
 drivers/media/video/sn9c102/sn9c102_core.c       |    3 -
 drivers/media/video/usbvision/usbvision-video.c  |    3 -
 drivers/media/video/videobuf-dma-sg.c            |    2 
 drivers/media/video/videobuf-vmalloc.c           |    2 
 drivers/media/video/videobuf2-memops.c           |    2 
 drivers/media/video/vino.c                       |    2 
 drivers/misc/carma/carma-fpga.c                  |    2 
 drivers/misc/sgi-gru/grufile.c                   |    5 -
 drivers/mtd/mtdchar.c                            |    2 
 drivers/oprofile/buffer_sync.c                   |   17 +---
 drivers/scsi/sg.c                                |    2 
 drivers/staging/android/ashmem.c                 |    1 
 drivers/staging/media/easycap/easycap_main.c     |    2 
 drivers/staging/omapdrm/omap_gem_dmabuf.c        |    2 
 drivers/staging/tidspbridge/rmgr/drv_interface.c |    2 
 drivers/uio/uio.c                                |    4 -
 drivers/usb/mon/mon_bin.c                        |    2 
 drivers/video/68328fb.c                          |    2 
 drivers/video/aty/atyfb_base.c                   |    3 -
 drivers/video/fb-puv3.c                          |    3 -
 drivers/video/fb_defio.c                         |    2 
 drivers/video/fbmem.c                            |    3 -
 drivers/video/gbefb.c                            |    2 
 drivers/video/omap2/omapfb/omapfb-main.c         |    2 
 drivers/video/sbuslib.c                          |    5 -
 drivers/video/smscufx.c                          |    1 
 drivers/video/udlfb.c                            |    1 
 drivers/video/vermilion/vermilion.c              |    1 
 drivers/video/vfb.c                              |    1 
 drivers/xen/gntalloc.c                           |    2 
 drivers/xen/gntdev.c                             |    2 
 drivers/xen/privcmd.c                            |    3 -
 fs/9p/vfs_file.c                                 |    1 
 fs/binfmt_elf.c                                  |    4 -
 fs/binfmt_elf_fdpic.c                            |    2 
 fs/btrfs/file.c                                  |    2 
 fs/ceph/addr.c                                   |    2 
 fs/cifs/file.c                                   |    1 
 fs/ext4/file.c                                   |    2 
 fs/fuse/file.c                                   |    1 
 fs/gfs2/file.c                                   |    2 
 fs/hugetlbfs/inode.c                             |    2 
 fs/nfs/file.c                                    |    1 
 fs/nilfs2/file.c                                 |    2 
 fs/ocfs2/mmap.c                                  |    2 
 fs/proc/task_mmu.c                               |    2 
 fs/ubifs/file.c                                  |    1 
 fs/xfs/xfs_file.c                                |    2 
 include/asm-generic/pgtable.h                    |   57 ++++++++------
 include/linux/fs.h                               |    2 
 include/linux/mempolicy.h                        |    2 
 include/linux/mm.h                               |   69 +++++++----------
 include/linux/mm_types.h                         |    2 
 include/linux/mman.h                             |    1 
 kernel/auditsc.c                                 |   13 ---
 kernel/events/core.c                             |    2 
 kernel/fork.c                                    |   24 ------
 mm/filemap.c                                     |    2 
 mm/filemap_xip.c                                 |    3 -
 mm/fremap.c                                      |   14 ++-
 mm/huge_memory.c                                 |   22 +----
 mm/ksm.c                                         |    8 +-
 mm/madvise.c                                     |    8 +-
 mm/memory.c                                      |   62 ++++++++-------
 mm/mlock.c                                       |    2 
 mm/mmap.c                                        |   29 +------
 mm/nommu.c                                       |   21 ++---
 mm/shmem.c                                       |    3 -
 mm/vmalloc.c                                     |    3 -
 security/selinux/selinuxfs.c                     |    2 
 security/tomoyo/util.c                           |    9 --
 sound/core/pcm_native.c                          |    6 +
 sound/usb/usx2y/us122l.c                         |    2 
 sound/usb/usx2y/usX2Yhwdep.c                     |    2 
 sound/usb/usx2y/usx2yhwdeppcm.c                  |    2 
 100 files changed, 303 insertions(+), 370 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
