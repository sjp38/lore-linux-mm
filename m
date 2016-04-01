Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E32C06B0269
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 08:30:10 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id 4so93565877pfd.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 05:30:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id di9si6101718pad.129.2016.04.01.05.30.08
        for <linux-mm@kvack.org>;
        Fri, 01 Apr 2016 05:30:09 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, REBASED 0/3] fs, mm: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Fri,  1 Apr 2016 15:29:46 +0300
Message-Id: <1459513789-146254-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

[
Rebased to current Linus' tree -- c05c2ec96bb8.

The first patch was regenerated with coccinelle, the rest just re-applied
on top.
]

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - <foo> >> (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

The first patches with most changes has been done with coccinelle.
The second is manual fixups on top.

The third patch which removes macros definition can be postponed to allow more
gradual transition.

Please, consider applying.

Kirill A. Shutemov (3):
  mm, fs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
  mm, fs: remove remaining PAGE_CACHE_* and page_cache_{get,release}
    usage
  mm: drop PAGE_CACHE_* and page_cache_{get,release} definition

 Documentation/filesystems/cramfs.txt               |   2 +-
 Documentation/filesystems/tmpfs.txt                |   2 +-
 Documentation/filesystems/vfs.txt                  |   4 +-
 arch/arc/mm/cache.c                                |   2 +-
 arch/arm/mm/flush.c                                |   4 +-
 arch/parisc/kernel/cache.c                         |   2 +-
 arch/parisc/mm/init.c                              |   2 +-
 arch/powerpc/platforms/cell/spufs/inode.c          |   4 +-
 arch/s390/hypfs/inode.c                            |   4 +-
 block/bio.c                                        |  12 +-
 block/blk-core.c                                   |   2 +-
 block/blk-settings.c                               |  12 +-
 block/blk-sysfs.c                                  |   8 +-
 block/cfq-iosched.c                                |   2 +-
 block/compat_ioctl.c                               |   4 +-
 block/ioctl.c                                      |   4 +-
 block/partition-generic.c                          |   8 +-
 drivers/block/aoe/aoeblk.c                         |   2 +-
 drivers/block/brd.c                                |   2 +-
 drivers/block/drbd/drbd_int.h                      |   4 +-
 drivers/block/drbd/drbd_nl.c                       |   2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |   2 +-
 drivers/gpu/drm/armada/armada_gem.c                |   4 +-
 drivers/gpu/drm/drm_gem.c                          |   4 +-
 drivers/gpu/drm/i915/i915_gem.c                    |   8 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            |   2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c                |   2 +-
 drivers/gpu/drm/ttm/ttm_tt.c                       |   4 +-
 drivers/gpu/drm/via/via_dmablit.c                  |   2 +-
 drivers/md/bitmap.c                                |   2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c          |   2 +-
 drivers/misc/ibmasm/ibmasmfs.c                     |   4 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c            |   2 +-
 drivers/mmc/core/host.c                            |   6 +-
 drivers/mmc/host/sh_mmcif.c                        |   2 +-
 drivers/mmc/host/tmio_mmc_dma.c                    |   4 +-
 drivers/mmc/host/tmio_mmc_pio.c                    |   2 +-
 drivers/mmc/host/usdhi6rol0.c                      |   2 +-
 drivers/mtd/devices/block2mtd.c                    |   6 +-
 drivers/mtd/nand/nandsim.c                         |   6 +-
 drivers/nvdimm/btt.c                               |   2 +-
 drivers/nvdimm/pmem.c                              |   2 +-
 drivers/oprofile/oprofilefs.c                      |   4 +-
 drivers/scsi/sd.c                                  |   2 +-
 drivers/scsi/st.c                                  |   4 +-
 .../lustre/include/linux/libcfs/libcfs_private.h   |   2 +-
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |   4 +-
 drivers/staging/lustre/include/linux/lnet/types.h  |   2 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |   2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |  16 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |   6 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   6 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   4 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   6 +-
 drivers/staging/lustre/lnet/selftest/brw_test.c    |  20 +-
 drivers/staging/lustre/lnet/selftest/conctl.c      |   4 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  10 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |   2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |   2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |   6 +-
 .../lustre/include/linux/lustre_patchless_compat.h |   2 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |   2 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |   6 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   4 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |  10 +-
 drivers/staging/lustre/lustre/include/obd.h        |   4 +-
 .../staging/lustre/lustre/include/obd_support.h    |   2 +-
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  12 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   2 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  23 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   8 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   8 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   8 +-
 drivers/staging/lustre/lustre/llite/lloop.c        |  12 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  18 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  24 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  28 +--
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  10 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   8 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   6 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  22 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   6 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   6 +-
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |   5 +-
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |   6 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   6 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  30 +--
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  16 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  44 ++--
 drivers/staging/lustre/lustre/osc/osc_page.c       |   6 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  26 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   2 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   2 +-
 drivers/usb/gadget/function/f_fs.c                 |   4 +-
 drivers/usb/gadget/legacy/inode.c                  |   4 +-
 drivers/usb/storage/scsiglue.c                     |   2 +-
 drivers/video/fbdev/pvr2fb.c                       |   2 +-
 fs/9p/vfs_addr.c                                   |  18 +-
 fs/9p/vfs_file.c                                   |   4 +-
 fs/9p/vfs_super.c                                  |   2 +-
 fs/affs/file.c                                     |  26 +-
 fs/afs/dir.c                                       |   2 +-
 fs/afs/file.c                                      |   4 +-
 fs/afs/mntpt.c                                     |   6 +-
 fs/afs/super.c                                     |   4 +-
 fs/afs/write.c                                     |  26 +-
 fs/binfmt_elf.c                                    |   2 +-
 fs/binfmt_elf_fdpic.c                              |   2 +-
 fs/block_dev.c                                     |   4 +-
 fs/btrfs/check-integrity.c                         |  64 ++---
 fs/btrfs/compression.c                             |  84 +++----
 fs/btrfs/disk-io.c                                 |  14 +-
 fs/btrfs/extent-tree.c                             |   4 +-
 fs/btrfs/extent_io.c                               | 266 ++++++++++-----------
 fs/btrfs/extent_io.h                               |   6 +-
 fs/btrfs/file-item.c                               |   4 +-
 fs/btrfs/file.c                                    |  40 ++--
 fs/btrfs/free-space-cache.c                        |  30 +--
 fs/btrfs/inode-map.c                               |  10 +-
 fs/btrfs/inode.c                                   | 104 ++++----
 fs/btrfs/ioctl.c                                   |  84 +++----
 fs/btrfs/lzo.c                                     |  32 +--
 fs/btrfs/raid56.c                                  |  28 +--
 fs/btrfs/reada.c                                   |  30 +--
 fs/btrfs/relocation.c                              |  16 +-
 fs/btrfs/scrub.c                                   |  24 +-
 fs/btrfs/send.c                                    |  16 +-
 fs/btrfs/struct-funcs.c                            |   4 +-
 fs/btrfs/tests/extent-io-tests.c                   |  44 ++--
 fs/btrfs/tests/free-space-tests.c                  |   2 +-
 fs/btrfs/volumes.c                                 |  14 +-
 fs/btrfs/zlib.c                                    |  38 +--
 fs/buffer.c                                        | 100 ++++----
 fs/cachefiles/rdwr.c                               |  38 +--
 fs/ceph/addr.c                                     | 114 ++++-----
 fs/ceph/caps.c                                     |   2 +-
 fs/ceph/dir.c                                      |   4 +-
 fs/ceph/file.c                                     |  32 +--
 fs/ceph/inode.c                                    |   6 +-
 fs/ceph/mds_client.c                               |   2 +-
 fs/ceph/mds_client.h                               |   2 +-
 fs/ceph/super.c                                    |   8 +-
 fs/cifs/cifsfs.c                                   |   2 +-
 fs/cifs/cifsglob.h                                 |   4 +-
 fs/cifs/cifssmb.c                                  |  16 +-
 fs/cifs/connect.c                                  |   2 +-
 fs/cifs/file.c                                     |  96 ++++----
 fs/cifs/inode.c                                    |  10 +-
 fs/configfs/mount.c                                |   4 +-
 fs/cramfs/README                                   |  26 +-
 fs/cramfs/inode.c                                  |  32 +--
 fs/crypto/crypto.c                                 |   8 +-
 fs/dax.c                                           |  34 +--
 fs/direct-io.c                                     |  26 +-
 fs/dlm/lowcomms.c                                  |   8 +-
 fs/ecryptfs/crypto.c                               |  22 +-
 fs/ecryptfs/inode.c                                |   8 +-
 fs/ecryptfs/keystore.c                             |   2 +-
 fs/ecryptfs/main.c                                 |   8 +-
 fs/ecryptfs/mmap.c                                 |  44 ++--
 fs/ecryptfs/read_write.c                           |  14 +-
 fs/efivarfs/super.c                                |   4 +-
 fs/exofs/dir.c                                     |  30 +--
 fs/exofs/inode.c                                   |  34 +--
 fs/exofs/namei.c                                   |   4 +-
 fs/ext2/dir.c                                      |  36 +--
 fs/ext2/namei.c                                    |   6 +-
 fs/ext4/crypto.c                                   |   8 +-
 fs/ext4/dir.c                                      |   4 +-
 fs/ext4/ext4.h                                     |   4 +-
 fs/ext4/file.c                                     |   4 +-
 fs/ext4/inline.c                                   |  18 +-
 fs/ext4/inode.c                                    | 118 ++++-----
 fs/ext4/mballoc.c                                  |  40 ++--
 fs/ext4/move_extent.c                              |  16 +-
 fs/ext4/page-io.c                                  |   4 +-
 fs/ext4/readpage.c                                 |  12 +-
 fs/ext4/super.c                                    |   4 +-
 fs/ext4/symlink.c                                  |   4 +-
 fs/f2fs/data.c                                     |  52 ++--
 fs/f2fs/debug.c                                    |   6 +-
 fs/f2fs/dir.c                                      |   4 +-
 fs/f2fs/f2fs.h                                     |   2 +-
 fs/f2fs/file.c                                     |  74 +++---
 fs/f2fs/inline.c                                   |  10 +-
 fs/f2fs/namei.c                                    |   4 +-
 fs/f2fs/node.c                                     |  10 +-
 fs/f2fs/recovery.c                                 |   2 +-
 fs/f2fs/segment.c                                  |  16 +-
 fs/f2fs/super.c                                    |   4 +-
 fs/freevxfs/vxfs_immed.c                           |   4 +-
 fs/freevxfs/vxfs_lookup.c                          |  12 +-
 fs/freevxfs/vxfs_subr.c                            |   2 +-
 fs/fs-writeback.c                                  |   2 +-
 fs/fscache/page.c                                  |  10 +-
 fs/fuse/dev.c                                      |  26 +-
 fs/fuse/file.c                                     |  72 +++---
 fs/fuse/inode.c                                    |  16 +-
 fs/gfs2/aops.c                                     |  44 ++--
 fs/gfs2/bmap.c                                     |  12 +-
 fs/gfs2/file.c                                     |  16 +-
 fs/gfs2/meta_io.c                                  |   4 +-
 fs/gfs2/quota.c                                    |  14 +-
 fs/gfs2/rgrp.c                                     |   5 +-
 fs/hfs/bnode.c                                     |  12 +-
 fs/hfs/btree.c                                     |  20 +-
 fs/hfs/inode.c                                     |   8 +-
 fs/hfsplus/bitmap.c                                |   2 +-
 fs/hfsplus/bnode.c                                 |  90 +++----
 fs/hfsplus/btree.c                                 |  22 +-
 fs/hfsplus/inode.c                                 |   8 +-
 fs/hfsplus/super.c                                 |   2 +-
 fs/hfsplus/xattr.c                                 |   6 +-
 fs/hostfs/hostfs_kern.c                            |  18 +-
 fs/hugetlbfs/inode.c                               |  10 +-
 fs/isofs/compress.c                                |  36 +--
 fs/isofs/inode.c                                   |   2 +-
 fs/jbd2/commit.c                                   |   4 +-
 fs/jbd2/journal.c                                  |   2 +-
 fs/jbd2/transaction.c                              |   4 +-
 fs/jffs2/debug.c                                   |   8 +-
 fs/jffs2/file.c                                    |  23 +-
 fs/jffs2/fs.c                                      |   8 +-
 fs/jffs2/gc.c                                      |   8 +-
 fs/jffs2/nodelist.c                                |   8 +-
 fs/jffs2/write.c                                   |   7 +-
 fs/jfs/jfs_metapage.c                              |  42 ++--
 fs/jfs/jfs_metapage.h                              |   4 +-
 fs/jfs/super.c                                     |   2 +-
 fs/kernfs/mount.c                                  |   4 +-
 fs/libfs.c                                         |  24 +-
 fs/logfs/dev_bdev.c                                |   2 +-
 fs/logfs/dev_mtd.c                                 |  10 +-
 fs/logfs/dir.c                                     |  12 +-
 fs/logfs/file.c                                    |  26 +-
 fs/logfs/readwrite.c                               |  20 +-
 fs/logfs/segment.c                                 |  28 +--
 fs/logfs/super.c                                   |  16 +-
 fs/minix/dir.c                                     |  18 +-
 fs/minix/namei.c                                   |   4 +-
 fs/mpage.c                                         |  22 +-
 fs/ncpfs/dir.c                                     |  10 +-
 fs/ncpfs/ncplib_kernel.h                           |   2 +-
 fs/nfs/blocklayout/blocklayout.c                   |  24 +-
 fs/nfs/blocklayout/blocklayout.h                   |   4 +-
 fs/nfs/client.c                                    |   8 +-
 fs/nfs/dir.c                                       |   4 +-
 fs/nfs/direct.c                                    |   8 +-
 fs/nfs/file.c                                      |  20 +-
 fs/nfs/internal.h                                  |   6 +-
 fs/nfs/nfs4xdr.c                                   |   2 +-
 fs/nfs/objlayout/objio_osd.c                       |   2 +-
 fs/nfs/pagelist.c                                  |   6 +-
 fs/nfs/pnfs.c                                      |   6 +-
 fs/nfs/read.c                                      |  16 +-
 fs/nfs/write.c                                     |   4 +-
 fs/nilfs2/bmap.c                                   |   2 +-
 fs/nilfs2/btnode.c                                 |  10 +-
 fs/nilfs2/dir.c                                    |  32 +--
 fs/nilfs2/gcinode.c                                |   2 +-
 fs/nilfs2/inode.c                                  |   4 +-
 fs/nilfs2/mdt.c                                    |  14 +-
 fs/nilfs2/namei.c                                  |   4 +-
 fs/nilfs2/page.c                                   |  18 +-
 fs/nilfs2/recovery.c                               |   4 +-
 fs/nilfs2/segment.c                                |   2 +-
 fs/ntfs/aops.c                                     |  50 ++--
 fs/ntfs/aops.h                                     |   4 +-
 fs/ntfs/attrib.c                                   |  28 +--
 fs/ntfs/bitmap.c                                   |  10 +-
 fs/ntfs/compress.c                                 |  77 +++---
 fs/ntfs/dir.c                                      |  56 ++---
 fs/ntfs/file.c                                     |  56 ++---
 fs/ntfs/index.c                                    |  14 +-
 fs/ntfs/inode.c                                    |  12 +-
 fs/ntfs/lcnalloc.c                                 |   6 +-
 fs/ntfs/logfile.c                                  |  16 +-
 fs/ntfs/mft.c                                      |  34 +--
 fs/ntfs/ntfs.h                                     |   2 +-
 fs/ntfs/super.c                                    |  72 +++---
 fs/ocfs2/alloc.c                                   |  28 +--
 fs/ocfs2/aops.c                                    |  50 ++--
 fs/ocfs2/cluster/heartbeat.c                       |  10 +-
 fs/ocfs2/dlmfs/dlmfs.c                             |   4 +-
 fs/ocfs2/file.c                                    |  14 +-
 fs/ocfs2/mmap.c                                    |   6 +-
 fs/ocfs2/ocfs2.h                                   |  20 +-
 fs/ocfs2/refcounttree.c                            |  24 +-
 fs/ocfs2/super.c                                   |   4 +-
 fs/orangefs/inode.c                                |  10 +-
 fs/orangefs/orangefs-bufmap.c                      |   4 +-
 fs/orangefs/orangefs-utils.c                       |   2 +-
 fs/pipe.c                                          |   6 +-
 fs/proc/task_mmu.c                                 |   2 +-
 fs/proc/vmcore.c                                   |   4 +-
 fs/pstore/inode.c                                  |   4 +-
 fs/qnx6/dir.c                                      |  16 +-
 fs/qnx6/inode.c                                    |   4 +-
 fs/qnx6/qnx6.h                                     |   2 +-
 fs/ramfs/inode.c                                   |   4 +-
 fs/reiserfs/file.c                                 |   4 +-
 fs/reiserfs/inode.c                                |  44 ++--
 fs/reiserfs/ioctl.c                                |   4 +-
 fs/reiserfs/journal.c                              |   6 +-
 fs/reiserfs/stree.c                                |   4 +-
 fs/reiserfs/tail_conversion.c                      |   4 +-
 fs/reiserfs/xattr.c                                |  18 +-
 fs/splice.c                                        |  32 +--
 fs/squashfs/block.c                                |   4 +-
 fs/squashfs/cache.c                                |  18 +-
 fs/squashfs/decompressor.c                         |   2 +-
 fs/squashfs/file.c                                 |  24 +-
 fs/squashfs/file_direct.c                          |  22 +-
 fs/squashfs/lz4_wrapper.c                          |   8 +-
 fs/squashfs/lzo_wrapper.c                          |   8 +-
 fs/squashfs/page_actor.c                           |   4 +-
 fs/squashfs/page_actor.h                           |   2 +-
 fs/squashfs/super.c                                |   2 +-
 fs/squashfs/symlink.c                              |   6 +-
 fs/squashfs/xz_wrapper.c                           |   4 +-
 fs/squashfs/zlib_wrapper.c                         |   4 +-
 fs/sync.c                                          |   4 +-
 fs/sysv/dir.c                                      |  18 +-
 fs/sysv/namei.c                                    |   4 +-
 fs/ubifs/file.c                                    |  54 ++---
 fs/ubifs/super.c                                   |   6 +-
 fs/ubifs/ubifs.h                                   |   4 +-
 fs/udf/file.c                                      |   6 +-
 fs/udf/inode.c                                     |   4 +-
 fs/ufs/balloc.c                                    |   6 +-
 fs/ufs/dir.c                                       |  32 +--
 fs/ufs/inode.c                                     |   4 +-
 fs/ufs/namei.c                                     |   6 +-
 fs/ufs/util.c                                      |   4 +-
 fs/ufs/util.h                                      |   2 +-
 fs/xfs/libxfs/xfs_bmap.c                           |   4 +-
 fs/xfs/xfs_aops.c                                  |  22 +-
 fs/xfs/xfs_bmap_util.c                             |   4 +-
 fs/xfs/xfs_file.c                                  |  12 +-
 fs/xfs/xfs_linux.h                                 |   2 +-
 fs/xfs/xfs_mount.c                                 |   2 +-
 fs/xfs/xfs_mount.h                                 |   4 +-
 fs/xfs/xfs_pnfs.c                                  |   4 +-
 fs/xfs/xfs_super.c                                 |   8 +-
 include/linux/backing-dev-defs.h                   |   2 +-
 include/linux/bio.h                                |   2 +-
 include/linux/blkdev.h                             |   2 +-
 include/linux/buffer_head.h                        |   4 +-
 include/linux/ceph/libceph.h                       |   4 +-
 include/linux/f2fs_fs.h                            |   4 +-
 include/linux/fs.h                                 |   4 +-
 include/linux/mm.h                                 |   2 +-
 include/linux/mm_types.h                           |   2 +-
 include/linux/nfs_page.h                           |   6 +-
 include/linux/nilfs2_fs.h                          |   4 +-
 include/linux/pagemap.h                            |  32 +--
 include/linux/sunrpc/svc.h                         |   2 +-
 include/linux/swap.h                               |   4 +-
 ipc/mqueue.c                                       |   4 +-
 kernel/events/uprobes.c                            |   8 +-
 mm/fadvise.c                                       |   8 +-
 mm/filemap.c                                       | 126 +++++-----
 mm/gup.c                                           |   2 +-
 mm/hugetlb.c                                       |   8 +-
 mm/madvise.c                                       |   6 +-
 mm/memory-failure.c                                |   2 +-
 mm/memory.c                                        |  55 +++--
 mm/mincore.c                                       |   8 +-
 mm/nommu.c                                         |   2 +-
 mm/page-writeback.c                                |  12 +-
 mm/page_io.c                                       |   2 +-
 mm/readahead.c                                     |  20 +-
 mm/rmap.c                                          |   2 +-
 mm/shmem.c                                         | 130 +++++-----
 mm/swap.c                                          |  14 +-
 mm/swap_state.c                                    |  12 +-
 mm/swapfile.c                                      |  12 +-
 mm/truncate.c                                      |  40 ++--
 mm/userfaultfd.c                                   |   4 +-
 mm/zswap.c                                         |   4 +-
 net/ceph/messenger.c                               |   6 +-
 net/ceph/pagelist.c                                |   4 +-
 net/ceph/pagevec.c                                 |  30 +--
 net/sunrpc/auth_gss/auth_gss.c                     |   8 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c              |   2 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c                |   4 +-
 net/sunrpc/cache.c                                 |   4 +-
 net/sunrpc/rpc_pipe.c                              |   4 +-
 net/sunrpc/socklib.c                               |   6 +-
 net/sunrpc/xdr.c                                   |  50 ++--
 398 files changed, 2840 insertions(+), 2869 deletions(-)

-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
