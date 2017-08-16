Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 980AA6B02F3
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 03:50:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k3so6635062pfc.0
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:50:32 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e92si185384pld.639.2017.08.16.00.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 00:50:31 -0700 (PDT)
Subject: [PATCH v5 0/5] MAP_DIRECT and block-map-atomic files
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Aug 2017 00:44:06 -0700
Message-ID: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Changes since v4 [1]:
* Drop the new vma ->fs_flags field, it can be replaced by just checking
  ->vm_ops locally in the filesystem. This approach also allows
  non-MAP_DIRECT vmas to be vma_merge() capable since vmas with
  vm_ops->close() disable vma merging. (Jan)

* Drop the new ->fmmap() operation, instead convert all ->mmap()
  implementations tree-wide to take an extra 'map_flags' parameter.
  (Jan)

* Drop the cute (MAP_SHARED|MAP_PRIVATE) hack/mechanism to add new
  validated flags mmap(2) and instead just define a new mmap syscall
  variant (sys_mmap_pgoff_strict). (Andy)

* Fix the fact that MAP_PRIVATE|MAP_DIRECT would silently fallback to
  MAP_SHARED (addressed by the new syscall). (Kirill)

* Require CAP_LINUX_IMMUTABLE for MAP_DIRECT to close any unforeseen
  denial of service for unmanaged + unprivileged MAP_DIRECT usage.
  (Kirill)

* Switch MAP_DIRECT fault failures to SIGBUS (Kirill)

* Add an fcntl mechanism to allow an unprivileged process to use
  MAP_DIRECT on an fd setup by a privileged process.

* Rework the MAP_DIRECT description to allow for future hardware where
  it may not be required to software-pin the file offset to physical
  address relationship.

Given the tree-wide touches in this revision the patchset is starting to
feel more like -mm material than strictly xfs.

[1]: https://lkml.org/lkml/2017/8/15/39

---

This is the next revision of a patch series that aims to enable
applications that otherwise need to resort to DAX mapping a raw device
file to instead move to a filesystem.

In the course of reviewing a previous posting, Christoph said:

    That being said I think we absolutely should support RDMA memory
    registrations for DAX mappings.  I'm just not sure how S_IOMAP_IMMUTABLE
    helps with that.  We'll want a MAP_SYNC | MAP_POPULATE to make sure all
    the blocks are populated and all ptes are set up.  Second we need to
    make sure get_user_page works, which for now means we'll need a struct
    page mapping for the region (which will be really annoying for PCIe
    mappings, like the upcoming NVMe persistent memory region), and we need
    to guarantee that the extent mapping won't change while the
    get_user_pages holds the pages inside it.  I think that is true due to
    side effects even with the current DAX code, but we'll need to make it
    explicit.  And maybe that's where we need to converge - "sealing" the
    extent map makes sense as such a temporary measure that is not persisted
    on disk, which automatically gets released when the holding process
    exits, because we sort of already do this implicitly.  It might also
    make sense to have explicitly breakable seals similar to what I do for
    the pNFS blocks kernel server, as any userspace RDMA file server would
    also need those semantics.

So, this is an attempt to converge on the idea that we need an explicit
and process-lifetime-temporary mechanism for a process to be able to
make assumptions about the mapping to physical page to dax-file-offset
relationship. The "explicitly breakable seals" aspect is not addressed
in these patches, but I wonder if it might be a voluntary mechanism that
can implemented via userfaultfd.

---

Dan Williams (5):
      vfs: add flags parameter to ->mmap() in 'struct file_operations'
      fs, xfs: introduce S_IOMAP_SEALED
      mm: introduce mmap3 for safely defining new mmap flags
      fs, xfs: introduce MAP_DIRECT for creating block-map-atomic file ranges
      fs, fcntl: add F_MAP_DIRECT


Diffstat without patch1:

 arch/x86/entry/syscalls/syscall_32.tbl |   1 +
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 fs/attr.c                              |  10 +++
 fs/fcntl.c                             |  15 +++++
 fs/open.c                              |   6 ++
 fs/read_write.c                        |   3 +
 fs/xfs/libxfs/xfs_bmap.c               |   5 ++
 fs/xfs/xfs_bmap_util.c                 |   3 +
 fs/xfs/xfs_file.c                      | 115 +++++++++++++++++++++++++++++++--
 fs/xfs/xfs_inode.h                     |   1 +
 fs/xfs/xfs_ioctl.c                     |   6 ++
 fs/xfs/xfs_super.c                     |   1 +
 include/linux/fs.h                     |  10 ++-
 include/linux/mm.h                     |   2 +-
 include/linux/mman.h                   |  25 +++++++
 include/linux/syscalls.h               |   3 +
 include/uapi/asm-generic/mman.h        |   1 +
 include/uapi/linux/fcntl.h             |   5 ++
 mm/filemap.c                           |   5 ++
 mm/mmap.c                              |  56 +++++++++++++++-
 20 files changed, 263 insertions(+), 11 deletions(-)

Diffstat with patch1:

 arch/arc/kernel/arc_hostlink.c                   |    3 -
 arch/powerpc/kernel/proc_powerpc.c               |    3 -
 arch/powerpc/kvm/book3s_64_vio.c                 |    3 -
 arch/powerpc/platforms/cell/spufs/file.c         |   21 +++-
 arch/powerpc/platforms/powernv/opal-prd.c        |    3 -
 arch/um/drivers/mmapper_kern.c                   |    3 -
 arch/x86/entry/syscalls/syscall_32.tbl           |    1 
 arch/x86/entry/syscalls/syscall_64.tbl           |    1 
 drivers/android/binder.c                         |    3 -
 drivers/char/agp/frontend.c                      |    3 -
 drivers/char/bsr.c                               |    3 -
 drivers/char/hpet.c                              |    6 +
 drivers/char/mbcs.c                              |    3 -
 drivers/char/mem.c                               |   11 +-
 drivers/char/mspec.c                             |    9 +-
 drivers/char/uv_mmtimer.c                        |    6 +
 drivers/dax/device.c                             |    3 -
 drivers/dma-buf/dma-buf.c                        |    4 +
 drivers/firewire/core-cdev.c                     |    3 -
 drivers/gpu/drm/amd/amdkfd/kfd_chardev.c         |    5 +
 drivers/gpu/drm/arc/arcpgu_drv.c                 |    5 +
 drivers/gpu/drm/ast/ast_drv.h                    |    3 -
 drivers/gpu/drm/ast/ast_ttm.c                    |    3 -
 drivers/gpu/drm/drm_gem.c                        |    3 -
 drivers/gpu/drm/drm_gem_cma_helper.c             |    2 
 drivers/gpu/drm/etnaviv/etnaviv_gem.c            |    2 
 drivers/gpu/drm/exynos/exynos_drm_gem.c          |    2 
 drivers/gpu/drm/i810/i810_dma.c                  |    3 -
 drivers/gpu/drm/i915/i915_gem_dmabuf.c           |    2 
 drivers/gpu/drm/mediatek/mtk_drm_gem.c           |    2 
 drivers/gpu/drm/mgag200/mgag200_drv.h            |    3 -
 drivers/gpu/drm/mgag200/mgag200_ttm.c            |    3 -
 drivers/gpu/drm/msm/msm_gem.c                    |    2 
 drivers/gpu/drm/omapdrm/omap_gem.c               |    2 
 drivers/gpu/drm/radeon/radeon_drv.c              |    3 -
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c      |    2 
 drivers/gpu/drm/tegra/gem.c                      |    2 
 drivers/gpu/drm/udl/udl_gem.c                    |    2 
 drivers/gpu/drm/vc4/vc4_bo.c                     |    2 
 drivers/gpu/drm/vgem/vgem_drv.c                  |    7 +
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h              |    3 -
 drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c         |    3 -
 drivers/hsi/clients/cmt_speech.c                 |    3 -
 drivers/hwtracing/intel_th/msu.c                 |    3 -
 drivers/hwtracing/stm/core.c                     |    3 -
 drivers/infiniband/core/uverbs_main.c            |    3 -
 drivers/infiniband/hw/hfi1/file_ops.c            |    6 +
 drivers/infiniband/hw/qib/qib_file_ops.c         |    5 +
 drivers/media/v4l2-core/v4l2-dev.c               |    3 -
 drivers/misc/aspeed-lpc-ctrl.c                   |    3 -
 drivers/misc/cxl/file.c                          |    3 -
 drivers/misc/genwqe/card_dev.c                   |    3 -
 drivers/misc/mic/scif/scif_fd.c                  |    3 -
 drivers/misc/mic/vop/vop_vringh.c                |    3 -
 drivers/misc/sgi-gru/grufile.c                   |    3 -
 drivers/mtd/mtdchar.c                            |    3 -
 drivers/pci/proc.c                               |    3 -
 drivers/rapidio/devices/rio_mport_cdev.c         |    3 -
 drivers/sbus/char/flash.c                        |    3 -
 drivers/sbus/char/jsflash.c                      |    3 -
 drivers/scsi/cxlflash/superpipe.c                |    3 -
 drivers/scsi/sg.c                                |    3 -
 drivers/staging/android/ashmem.c                 |    3 -
 drivers/staging/comedi/comedi_fops.c             |    3 -
 drivers/staging/lustre/lustre/llite/llite_mmap.c |    2 
 drivers/staging/vme/devices/vme_user.c           |    3 -
 drivers/uio/uio.c                                |    3 -
 drivers/usb/core/devio.c                         |    3 -
 drivers/usb/mon/mon_bin.c                        |    3 -
 drivers/vfio/vfio.c                              |    7 +
 drivers/video/fbdev/core/fbmem.c                 |    3 -
 drivers/video/fbdev/pxa3xx-gcu.c                 |    3 -
 drivers/xen/gntalloc.c                           |    3 -
 drivers/xen/gntdev.c                             |    3 -
 drivers/xen/privcmd.c                            |    3 -
 drivers/xen/xenbus/xenbus_dev_backend.c          |    3 -
 drivers/xen/xenfs/xenstored.c                    |    3 -
 fs/9p/vfs_file.c                                 |   10 +-
 fs/aio.c                                         |    3 -
 fs/attr.c                                        |   10 ++
 fs/btrfs/file.c                                  |    3 -
 fs/cifs/file.c                                   |    4 -
 fs/coda/file.c                                   |    5 +
 fs/ecryptfs/file.c                               |    5 +
 fs/ext2/file.c                                   |    5 +
 fs/ext4/file.c                                   |    3 -
 fs/f2fs/file.c                                   |    3 -
 fs/fcntl.c                                       |   15 +++
 fs/fuse/file.c                                   |    8 +-
 fs/gfs2/file.c                                   |    3 -
 fs/hugetlbfs/inode.c                             |    3 -
 fs/kernfs/file.c                                 |    3 -
 fs/nfs/file.c                                    |    5 +
 fs/nfs/internal.h                                |    2 
 fs/nilfs2/file.c                                 |    3 -
 fs/open.c                                        |    6 +
 fs/orangefs/file.c                               |    5 +
 fs/proc/inode.c                                  |    7 +
 fs/proc/vmcore.c                                 |    6 +
 fs/ramfs/file-nommu.c                            |    6 +
 fs/read_write.c                                  |    3 +
 fs/romfs/mmap-nommu.c                            |    3 -
 fs/ubifs/file.c                                  |    5 +
 fs/xfs/libxfs/xfs_bmap.c                         |    5 +
 fs/xfs/xfs_bmap_util.c                           |    3 +
 fs/xfs/xfs_file.c                                |  114 +++++++++++++++++++++-
 fs/xfs/xfs_inode.h                               |    1 
 fs/xfs/xfs_ioctl.c                               |    6 +
 fs/xfs/xfs_super.c                               |    1 
 include/drm/drm_gem.h                            |    3 -
 include/linux/fs.h                               |   21 +++-
 include/linux/mm.h                               |    2 
 include/linux/mman.h                             |   25 +++++
 include/linux/syscalls.h                         |    3 +
 include/uapi/asm-generic/mman.h                  |    1 
 include/uapi/linux/fcntl.h                       |    5 +
 ipc/shm.c                                        |    5 +
 kernel/events/core.c                             |    3 -
 kernel/kcov.c                                    |    3 -
 kernel/relay.c                                   |    3 -
 mm/filemap.c                                     |   19 +++-
 mm/mmap.c                                        |   56 ++++++++++-
 mm/nommu.c                                       |    4 -
 mm/shmem.c                                       |    3 -
 net/socket.c                                     |    6 +
 security/selinux/selinuxfs.c                     |    6 +
 sound/core/compress_offload.c                    |    3 -
 sound/core/hwdep.c                               |    3 -
 sound/core/info.c                                |    3 -
 sound/core/init.c                                |    3 -
 sound/core/oss/pcm_oss.c                         |    3 -
 sound/oss/soundcard.c                            |    3 -
 sound/oss/swarm_cs4297a.c                        |    3 -
 virt/kvm/kvm_main.c                              |    3 -
 134 files changed, 553 insertions(+), 174 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
