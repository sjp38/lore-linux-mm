Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 205B66B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:07:19 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id x3so262551274pfb.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:07:19 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yp9si2288925pab.121.2016.03.21.05.07.13
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 05:07:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/3] mm, fs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Mon, 21 Mar 2016 15:06:36 +0300
Message-Id: <1458561998-126622-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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

This patch contains automated changes generated with coccinelle using
script below. For some reason, coccinelle doesn't patch header files.
I've called spatch for them manually.

The only adjustment after coccinelle is revert of changes to
PAGE_CAHCE_ALIGN definition: we are going to drop it later.

There are few places in the code where coccinelle didn't reach.
I'll fix them manually in a separate patch. Comments and documentation
also will be addressed with the separate patch.

virtual patch

@@
expression E;
@@
- E << (PAGE_CACHE_SHIFT - PAGE_SHIFT)
+ E

@@
expression E;
@@
- E >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)
+ E

@@
@@
- PAGE_CACHE_SHIFT
+ PAGE_SHIFT

@@
@@
- PAGE_CACHE_SIZE
+ PAGE_SIZE

@@
@@
- PAGE_CACHE_MASK
+ PAGE_MASK

@@
expression E;
@@
- PAGE_CACHE_ALIGN(E)
+ PAGE_ALIGN(E)

@@
expression E;
@@
- page_cache_get(E)
+ get_page(E)

@@
expression E;
@@
- page_cache_release(E)
+ put_page(E)

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/arc/mm/cache.c                                |   2 +-
 arch/arm/mm/flush.c                                |   4 +-
 arch/parisc/kernel/cache.c                         |   2 +-
 arch/powerpc/platforms/cell/spufs/inode.c          |   4 +-
 arch/s390/hypfs/inode.c                            |   4 +-
 block/bio.c                                        |   8 +-
 block/blk-core.c                                   |   2 +-
 block/blk-settings.c                               |  12 +-
 block/blk-sysfs.c                                  |   8 +-
 block/cfq-iosched.c                                |   2 +-
 block/compat_ioctl.c                               |   4 +-
 block/ioctl.c                                      |   4 +-
 block/partition-generic.c                          |   8 +-
 drivers/block/aoe/aoeblk.c                         |   2 +-
 drivers/block/brd.c                                |   2 +-
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
 drivers/staging/lustre/lnet/selftest/selftest.h    |   2 +-
 .../lustre/include/linux/lustre_patchless_compat.h |   2 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |   2 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   4 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |   6 +-
 drivers/staging/lustre/lustre/include/obd.h        |   2 +-
 .../staging/lustre/lustre/include/obd_support.h    |   2 +-
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  12 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   2 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  18 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   8 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   8 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   8 +-
 drivers/staging/lustre/lustre/llite/lloop.c        |  12 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  18 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  22 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  28 +--
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   8 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   8 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   4 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   6 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  22 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   6 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   6 +-
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |   4 +-
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |   6 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   6 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  30 +--
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  16 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  42 ++--
 drivers/staging/lustre/lustre/osc/osc_page.c       |   6 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  26 +--
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
 fs/affs/file.c                                     |  26 +--
 fs/afs/dir.c                                       |   2 +-
 fs/afs/file.c                                      |   4 +-
 fs/afs/mntpt.c                                     |   6 +-
 fs/afs/super.c                                     |   4 +-
 fs/afs/write.c                                     |  26 +--
 fs/binfmt_elf.c                                    |   2 +-
 fs/binfmt_elf_fdpic.c                              |   2 +-
 fs/block_dev.c                                     |   4 +-
 fs/btrfs/check-integrity.c                         |  60 ++---
 fs/btrfs/compression.c                             |  84 +++----
 fs/btrfs/ctree.c                                   |   8 +-
 fs/btrfs/disk-io.c                                 |  14 +-
 fs/btrfs/extent-tree.c                             |   4 +-
 fs/btrfs/extent_io.c                               | 260 ++++++++++-----------
 fs/btrfs/extent_io.h                               |   6 +-
 fs/btrfs/file-item.c                               |   4 +-
 fs/btrfs/file.c                                    |  62 ++---
 fs/btrfs/free-space-cache.c                        |  30 +--
 fs/btrfs/inode-map.c                               |  10 +-
 fs/btrfs/inode.c                                   | 120 +++++-----
 fs/btrfs/ioctl.c                                   |  82 +++----
 fs/btrfs/lzo.c                                     |  32 +--
 fs/btrfs/raid56.c                                  |  28 +--
 fs/btrfs/reada.c                                   |  30 +--
 fs/btrfs/relocation.c                              |  16 +-
 fs/btrfs/scrub.c                                   |  24 +-
 fs/btrfs/send.c                                    |  16 +-
 fs/btrfs/tests/extent-io-tests.c                   |  42 ++--
 fs/btrfs/tests/free-space-tests.c                  |   2 +-
 fs/btrfs/volumes.c                                 |  14 +-
 fs/btrfs/zlib.c                                    |  38 +--
 fs/buffer.c                                        | 100 ++++----
 fs/cachefiles/rdwr.c                               |  38 +--
 fs/ceph/addr.c                                     | 106 ++++-----
 fs/ceph/caps.c                                     |   2 +-
 fs/ceph/dir.c                                      |   4 +-
 fs/ceph/file.c                                     |  32 +--
 fs/ceph/inode.c                                    |   4 +-
 fs/ceph/mds_client.c                               |   2 +-
 fs/ceph/mds_client.h                               |   2 +-
 fs/ceph/super.c                                    |   8 +-
 fs/cifs/cifsfs.c                                   |   2 +-
 fs/cifs/cifssmb.c                                  |  16 +-
 fs/cifs/connect.c                                  |   2 +-
 fs/cifs/file.c                                     |  94 ++++----
 fs/cifs/inode.c                                    |  10 +-
 fs/configfs/mount.c                                |   4 +-
 fs/cramfs/inode.c                                  |  30 +--
 fs/dax.c                                           |  30 +--
 fs/direct-io.c                                     |  26 +--
 fs/dlm/lowcomms.c                                  |   8 +-
 fs/ecryptfs/crypto.c                               |  22 +-
 fs/ecryptfs/inode.c                                |   4 +-
 fs/ecryptfs/keystore.c                             |   2 +-
 fs/ecryptfs/main.c                                 |   8 +-
 fs/ecryptfs/mmap.c                                 |  44 ++--
 fs/ecryptfs/read_write.c                           |  14 +-
 fs/efivarfs/super.c                                |   4 +-
 fs/exofs/dir.c                                     |  30 +--
 fs/exofs/inode.c                                   |  34 +--
 fs/exofs/namei.c                                   |   4 +-
 fs/ext2/dir.c                                      |  32 +--
 fs/ext2/namei.c                                    |   6 +-
 fs/ext4/crypto.c                                   |   8 +-
 fs/ext4/dir.c                                      |   4 +-
 fs/ext4/file.c                                     |   4 +-
 fs/ext4/inline.c                                   |  18 +-
 fs/ext4/inode.c                                    | 116 ++++-----
 fs/ext4/mballoc.c                                  |  36 +--
 fs/ext4/move_extent.c                              |  16 +-
 fs/ext4/page-io.c                                  |   4 +-
 fs/ext4/readpage.c                                 |  10 +-
 fs/ext4/super.c                                    |   4 +-
 fs/ext4/symlink.c                                  |   4 +-
 fs/f2fs/crypto.c                                   |   6 +-
 fs/f2fs/data.c                                     |  50 ++--
 fs/f2fs/debug.c                                    |   6 +-
 fs/f2fs/dir.c                                      |   4 +-
 fs/f2fs/f2fs.h                                     |   2 +-
 fs/f2fs/file.c                                     |  74 +++---
 fs/f2fs/inline.c                                   |  12 +-
 fs/f2fs/namei.c                                    |   4 +-
 fs/f2fs/node.c                                     |  10 +-
 fs/f2fs/recovery.c                                 |   2 +-
 fs/f2fs/segment.c                                  |  18 +-
 fs/f2fs/super.c                                    |   4 +-
 fs/freevxfs/vxfs_immed.c                           |   4 +-
 fs/freevxfs/vxfs_lookup.c                          |  12 +-
 fs/freevxfs/vxfs_subr.c                            |   2 +-
 fs/fs-writeback.c                                  |   2 +-
 fs/fscache/page.c                                  |  10 +-
 fs/fuse/dev.c                                      |  26 +--
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
 fs/hugetlbfs/inode.c                               |   8 +-
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
 fs/logfs/file.c                                    |  26 +--
 fs/logfs/readwrite.c                               |  20 +-
 fs/logfs/segment.c                                 |  28 +--
 fs/logfs/super.c                                   |  16 +-
 fs/minix/dir.c                                     |  18 +-
 fs/minix/namei.c                                   |   4 +-
 fs/mpage.c                                         |  20 +-
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
 fs/ntfs/aops.c                                     |  48 ++--
 fs/ntfs/aops.h                                     |   2 +-
 fs/ntfs/attrib.c                                   |  28 +--
 fs/ntfs/bitmap.c                                   |  10 +-
 fs/ntfs/compress.c                                 |  56 ++---
 fs/ntfs/dir.c                                      |  40 ++--
 fs/ntfs/file.c                                     |  54 ++---
 fs/ntfs/index.c                                    |  12 +-
 fs/ntfs/inode.c                                    |   8 +-
 fs/ntfs/lcnalloc.c                                 |   6 +-
 fs/ntfs/logfile.c                                  |  16 +-
 fs/ntfs/mft.c                                      |  34 +--
 fs/ntfs/ntfs.h                                     |   2 +-
 fs/ntfs/super.c                                    |  58 ++---
 fs/ocfs2/alloc.c                                   |  28 +--
 fs/ocfs2/aops.c                                    |  46 ++--
 fs/ocfs2/cluster/heartbeat.c                       |  10 +-
 fs/ocfs2/dlmfs/dlmfs.c                             |   4 +-
 fs/ocfs2/file.c                                    |  14 +-
 fs/ocfs2/mmap.c                                    |   6 +-
 fs/ocfs2/ocfs2.h                                   |  20 +-
 fs/ocfs2/refcounttree.c                            |  22 +-
 fs/ocfs2/super.c                                   |   4 +-
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
 fs/reiserfs/journal.c                              |   4 +-
 fs/reiserfs/stree.c                                |   4 +-
 fs/reiserfs/tail_conversion.c                      |   4 +-
 fs/reiserfs/xattr.c                                |  18 +-
 fs/splice.c                                        |  32 +--
 fs/squashfs/block.c                                |   4 +-
 fs/squashfs/cache.c                                |  14 +-
 fs/squashfs/decompressor.c                         |   2 +-
 fs/squashfs/file.c                                 |  22 +-
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
 fs/ubifs/file.c                                    |  52 ++---
 fs/ubifs/super.c                                   |   4 +-
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
 fs/xfs/xfs_aops.c                                  |  30 +--
 fs/xfs/xfs_bmap_util.c                             |   4 +-
 fs/xfs/xfs_file.c                                  |  12 +-
 fs/xfs/xfs_linux.h                                 |   2 +-
 fs/xfs/xfs_mount.c                                 |   2 +-
 fs/xfs/xfs_mount.h                                 |   4 +-
 fs/xfs/xfs_pnfs.c                                  |   4 +-
 fs/xfs/xfs_super.c                                 |   4 +-
 include/linux/bio.h                                |   2 +-
 include/linux/blkdev.h                             |   2 +-
 include/linux/buffer_head.h                        |   4 +-
 include/linux/ceph/libceph.h                       |   4 +-
 include/linux/f2fs_fs.h                            |   4 +-
 include/linux/fs.h                                 |   4 +-
 include/linux/nfs_page.h                           |   2 +-
 include/linux/pagemap.h                            |  14 +-
 include/linux/swap.h                               |   2 +-
 ipc/mqueue.c                                       |   4 +-
 kernel/events/uprobes.c                            |   8 +-
 mm/fadvise.c                                       |   8 +-
 mm/filemap.c                                       | 126 +++++-----
 mm/hugetlb.c                                       |   8 +-
 mm/madvise.c                                       |   6 +-
 mm/memory-failure.c                                |   2 +-
 mm/memory.c                                        |  54 ++---
 mm/mincore.c                                       |   4 +-
 mm/nommu.c                                         |   2 +-
 mm/page-writeback.c                                |  12 +-
 mm/page_io.c                                       |   2 +-
 mm/readahead.c                                     |  20 +-
 mm/rmap.c                                          |   2 +-
 mm/shmem.c                                         | 130 +++++------
 mm/swap.c                                          |  12 +-
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
 net/sunrpc/xdr.c                                   |  48 ++--
 379 files changed, 2735 insertions(+), 2734 deletions(-)

diff --git a/arch/arc/mm/cache.c b/arch/arc/mm/cache.c
index b65f797e9ad6..d9bacb4199ea 100644
--- a/arch/arc/mm/cache.c
+++ b/arch/arc/mm/cache.c
@@ -621,7 +621,7 @@ void flush_dcache_page(struct page *page)
 
 		/* kernel reading from page with U-mapping */
 		phys_addr_t paddr = (unsigned long)page_address(page);
-		unsigned long vaddr = page->index << PAGE_CACHE_SHIFT;
+		unsigned long vaddr = page->index << PAGE_SHIFT;
 
 		if (addr_not_cache_congruent(paddr, vaddr))
 			__flush_dcache_page(paddr, vaddr);
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index d0ba3551d49a..3cced8455727 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -235,7 +235,7 @@ void __flush_dcache_page(struct address_space *mapping, struct page *page)
 	 */
 	if (mapping && cache_is_vipt_aliasing())
 		flush_pfn_alias(page_to_pfn(page),
-				page->index << PAGE_CACHE_SHIFT);
+				page->index << PAGE_SHIFT);
 }
 
 static void __flush_dcache_aliases(struct address_space *mapping, struct page *page)
@@ -250,7 +250,7 @@ static void __flush_dcache_aliases(struct address_space *mapping, struct page *p
 	 *   data in the current VM view associated with this page.
 	 * - aliasing VIPT: we only need to find one mapping of this page.
 	 */
-	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff = page->index;
 
 	flush_dcache_mmap_lock(mapping);
 	vma_interval_tree_foreach(mpnt, &mapping->i_mmap, pgoff, pgoff) {
diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
index 91c2a39cd5aa..67001277256c 100644
--- a/arch/parisc/kernel/cache.c
+++ b/arch/parisc/kernel/cache.c
@@ -319,7 +319,7 @@ void flush_dcache_page(struct page *page)
 	if (!mapping)
 		return;
 
-	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff = page->index;
 
 	/* We have carefully arranged in arch_get_unmapped_area() that
 	 * *any* mappings of a file are always congruently mapped (whether
diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index dfa863876778..6ca5f0525e57 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -732,8 +732,8 @@ spufs_fill_super(struct super_block *sb, void *data, int silent)
 		return -ENOMEM;
 
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = SPUFS_MAGIC;
 	sb->s_op = &s_ops;
 	sb->s_fs_info = info;
diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index 0f3da2cb2bd6..255c7eec4481 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -278,8 +278,8 @@ static int hypfs_fill_super(struct super_block *sb, void *data, int silent)
 	sbi->uid = current_uid();
 	sbi->gid = current_gid();
 	sb->s_fs_info = sbi;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = HYPFS_MAGIC;
 	sb->s_op = &hypfs_s_ops;
 	if (hypfs_parse_options(data, sb))
diff --git a/block/bio.c b/block/bio.c
index f124a0a624fc..168531517694 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1339,7 +1339,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 		 * release the pages we didn't map into the bio, if any
 		 */
 		while (j < page_limit)
-			page_cache_release(pages[j++]);
+			put_page(pages[j++]);
 	}
 
 	kfree(pages);
@@ -1365,7 +1365,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	for (j = 0; j < nr_pages; j++) {
 		if (!pages[j])
 			break;
-		page_cache_release(pages[j]);
+		put_page(pages[j]);
 	}
  out:
 	kfree(pages);
@@ -1385,7 +1385,7 @@ static void __bio_unmap_user(struct bio *bio)
 		if (bio_data_dir(bio) == READ)
 			set_page_dirty_lock(bvec->bv_page);
 
-		page_cache_release(bvec->bv_page);
+		put_page(bvec->bv_page);
 	}
 
 	bio_put(bio);
@@ -1658,7 +1658,7 @@ void bio_check_pages_dirty(struct bio *bio)
 		struct page *page = bvec->bv_page;
 
 		if (PageDirty(page) || PageCompound(page)) {
-			page_cache_release(page);
+			put_page(page);
 			bvec->bv_page = NULL;
 		} else {
 			nr_clean_pages++;
diff --git a/block/blk-core.c b/block/blk-core.c
index 827f8badd143..b60537b2c35b 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -706,7 +706,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 		goto fail_id;
 
 	q->backing_dev_info.ra_pages =
-			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+			(VM_MAX_READAHEAD * 1024) / PAGE_SIZE;
 	q->backing_dev_info.capabilities = BDI_CAP_CGROUP_WRITEBACK;
 	q->backing_dev_info.name = "block";
 	q->node = node_id;
diff --git a/block/blk-settings.c b/block/blk-settings.c
index c7bb666aafd1..331e4eee0dda 100644
--- a/block/blk-settings.c
+++ b/block/blk-settings.c
@@ -239,8 +239,8 @@ void blk_queue_max_hw_sectors(struct request_queue *q, unsigned int max_hw_secto
 	struct queue_limits *limits = &q->limits;
 	unsigned int max_sectors;
 
-	if ((max_hw_sectors << 9) < PAGE_CACHE_SIZE) {
-		max_hw_sectors = 1 << (PAGE_CACHE_SHIFT - 9);
+	if ((max_hw_sectors << 9) < PAGE_SIZE) {
+		max_hw_sectors = 1 << (PAGE_SHIFT - 9);
 		printk(KERN_INFO "%s: set to minimum %d\n",
 		       __func__, max_hw_sectors);
 	}
@@ -329,8 +329,8 @@ EXPORT_SYMBOL(blk_queue_max_segments);
  **/
 void blk_queue_max_segment_size(struct request_queue *q, unsigned int max_size)
 {
-	if (max_size < PAGE_CACHE_SIZE) {
-		max_size = PAGE_CACHE_SIZE;
+	if (max_size < PAGE_SIZE) {
+		max_size = PAGE_SIZE;
 		printk(KERN_INFO "%s: set to minimum %d\n",
 		       __func__, max_size);
 	}
@@ -760,8 +760,8 @@ EXPORT_SYMBOL_GPL(blk_queue_dma_drain);
  **/
 void blk_queue_segment_boundary(struct request_queue *q, unsigned long mask)
 {
-	if (mask < PAGE_CACHE_SIZE - 1) {
-		mask = PAGE_CACHE_SIZE - 1;
+	if (mask < PAGE_SIZE - 1) {
+		mask = PAGE_SIZE - 1;
 		printk(KERN_INFO "%s: set to minimum %lx\n",
 		       __func__, mask);
 	}
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index dd93763057ce..995b58d46ed1 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -76,7 +76,7 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
 static ssize_t queue_ra_show(struct request_queue *q, char *page)
 {
 	unsigned long ra_kb = q->backing_dev_info.ra_pages <<
-					(PAGE_CACHE_SHIFT - 10);
+					(PAGE_SHIFT - 10);
 
 	return queue_var_show(ra_kb, (page));
 }
@@ -90,7 +90,7 @@ queue_ra_store(struct request_queue *q, const char *page, size_t count)
 	if (ret < 0)
 		return ret;
 
-	q->backing_dev_info.ra_pages = ra_kb >> (PAGE_CACHE_SHIFT - 10);
+	q->backing_dev_info.ra_pages = ra_kb >> (PAGE_SHIFT - 10);
 
 	return ret;
 }
@@ -117,7 +117,7 @@ static ssize_t queue_max_segment_size_show(struct request_queue *q, char *page)
 	if (blk_queue_cluster(q))
 		return queue_var_show(queue_max_segment_size(q), (page));
 
-	return queue_var_show(PAGE_CACHE_SIZE, (page));
+	return queue_var_show(PAGE_SIZE, (page));
 }
 
 static ssize_t queue_logical_block_size_show(struct request_queue *q, char *page)
@@ -198,7 +198,7 @@ queue_max_sectors_store(struct request_queue *q, const char *page, size_t count)
 {
 	unsigned long max_sectors_kb,
 		max_hw_sectors_kb = queue_max_hw_sectors(q) >> 1,
-			page_kb = 1 << (PAGE_CACHE_SHIFT - 10);
+			page_kb = 1 << (PAGE_SHIFT - 10);
 	ssize_t ret = queue_var_store(&max_sectors_kb, page, count);
 
 	if (ret < 0)
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index e3c591dd8f19..4a349787bc62 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -4075,7 +4075,7 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		 * idle timer unplug to continue working.
 		 */
 		if (cfq_cfqq_wait_request(cfqq)) {
-			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
+			if (blk_rq_bytes(rq) > PAGE_SIZE ||
 			    cfqd->busy_queues > 1) {
 				cfq_del_timer(cfqd, cfqq);
 				cfq_clear_cfqq_wait_request(cfqq);
diff --git a/block/compat_ioctl.c b/block/compat_ioctl.c
index f678c733df40..556826ac7cb4 100644
--- a/block/compat_ioctl.c
+++ b/block/compat_ioctl.c
@@ -710,7 +710,7 @@ long compat_blkdev_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 			return -EINVAL;
 		bdi = blk_get_backing_dev_info(bdev);
 		return compat_put_long(arg,
-				       (bdi->ra_pages * PAGE_CACHE_SIZE) / 512);
+				       (bdi->ra_pages * PAGE_SIZE) / 512);
 	case BLKROGET: /* compatible */
 		return compat_put_int(arg, bdev_read_only(bdev) != 0);
 	case BLKBSZGET_32: /* get the logical block size (cf. BLKSSZGET) */
@@ -729,7 +729,7 @@ long compat_blkdev_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 		if (!capable(CAP_SYS_ADMIN))
 			return -EACCES;
 		bdi = blk_get_backing_dev_info(bdev);
-		bdi->ra_pages = (arg * 512) / PAGE_CACHE_SIZE;
+		bdi->ra_pages = (arg * 512) / PAGE_SIZE;
 		return 0;
 	case BLKGETSIZE:
 		size = i_size_read(bdev->bd_inode);
diff --git a/block/ioctl.c b/block/ioctl.c
index d8996bbd7f12..4ff1f92f89ca 100644
--- a/block/ioctl.c
+++ b/block/ioctl.c
@@ -550,7 +550,7 @@ int blkdev_ioctl(struct block_device *bdev, fmode_t mode, unsigned cmd,
 		if (!arg)
 			return -EINVAL;
 		bdi = blk_get_backing_dev_info(bdev);
-		return put_long(arg, (bdi->ra_pages * PAGE_CACHE_SIZE) / 512);
+		return put_long(arg, (bdi->ra_pages * PAGE_SIZE) / 512);
 	case BLKROGET:
 		return put_int(arg, bdev_read_only(bdev) != 0);
 	case BLKBSZGET: /* get block device soft block size (cf. BLKSSZGET) */
@@ -578,7 +578,7 @@ int blkdev_ioctl(struct block_device *bdev, fmode_t mode, unsigned cmd,
 		if(!capable(CAP_SYS_ADMIN))
 			return -EACCES;
 		bdi = blk_get_backing_dev_info(bdev);
-		bdi->ra_pages = (arg * 512) / PAGE_CACHE_SIZE;
+		bdi->ra_pages = (arg * 512) / PAGE_SIZE;
 		return 0;
 	case BLKBSZSET:
 		return blkdev_bszset(bdev, mode, argp);
diff --git a/block/partition-generic.c b/block/partition-generic.c
index 5d8701941054..2c6ae2aed2c4 100644
--- a/block/partition-generic.c
+++ b/block/partition-generic.c
@@ -566,8 +566,8 @@ static struct page *read_pagecache_sector(struct block_device *bdev, sector_t n)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	return read_mapping_page(mapping, (pgoff_t)(n >> (PAGE_CACHE_SHIFT-9)),
-			NULL);
+	return read_mapping_page(mapping, (pgoff_t)(n >> (PAGE_SHIFT-9)),
+				 NULL);
 }
 
 unsigned char *read_dev_sector(struct block_device *bdev, sector_t n, Sector *p)
@@ -584,9 +584,9 @@ unsigned char *read_dev_sector(struct block_device *bdev, sector_t n, Sector *p)
 		if (PageError(page))
 			goto fail;
 		p->v = page;
-		return (unsigned char *)page_address(page) +  ((n & ((1 << (PAGE_CACHE_SHIFT - 9)) - 1)) << 9);
+		return (unsigned char *)page_address(page) +  ((n & ((1 << (PAGE_SHIFT - 9)) - 1)) << 9);
 fail:
-		page_cache_release(page);
+		put_page(page);
 	}
 	p->v = NULL;
 	return NULL;
diff --git a/drivers/block/aoe/aoeblk.c b/drivers/block/aoe/aoeblk.c
index dd73e1ff1759..ec9d8610b25f 100644
--- a/drivers/block/aoe/aoeblk.c
+++ b/drivers/block/aoe/aoeblk.c
@@ -397,7 +397,7 @@ aoeblk_gdalloc(void *vp)
 	WARN_ON(d->flags & DEVFL_UP);
 	blk_queue_max_hw_sectors(q, BLK_DEF_MAX_SECTORS);
 	q->backing_dev_info.name = "aoe";
-	q->backing_dev_info.ra_pages = READ_AHEAD / PAGE_CACHE_SIZE;
+	q->backing_dev_info.ra_pages = READ_AHEAD / PAGE_SIZE;
 	d->bufpool = mp;
 	d->blkq = gd->queue = q;
 	q->queuedata = d;
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index f7ecc287d733..51a071e32221 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -374,7 +374,7 @@ static int brd_rw_page(struct block_device *bdev, sector_t sector,
 		       struct page *page, int rw)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
-	int err = brd_do_bvec(brd, page, PAGE_CACHE_SIZE, 0, rw, sector);
+	int err = brd_do_bvec(brd, page, PAGE_SIZE, 0, rw, sector);
 	page_endio(page, rw & WRITE, err);
 	return err;
 }
diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 226eb0c9f0fb..1fd1dccebb6b 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -1178,7 +1178,7 @@ static void drbd_setup_queue_param(struct drbd_device *device, struct drbd_backi
 	blk_queue_max_hw_sectors(q, max_hw_sectors);
 	/* This is the workaround for "bio would need to, but cannot, be split" */
 	blk_queue_max_segments(q, max_segments ? max_segments : BLK_MAX_SEGMENTS);
-	blk_queue_segment_boundary(q, PAGE_CACHE_SIZE-1);
+	blk_queue_segment_boundary(q, PAGE_SIZE-1);
 
 	if (b) {
 		struct drbd_connection *connection = first_peer_device(device)->connection;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 7b82e57aa09c..382748da8693 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -573,7 +573,7 @@ static void amdgpu_ttm_tt_unpin_userptr(struct ttm_tt *ttm)
 			set_page_dirty(page);
 
 		mark_page_accessed(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	sg_free_table(ttm->sg);
diff --git a/drivers/gpu/drm/armada/armada_gem.c b/drivers/gpu/drm/armada/armada_gem.c
index 6e731db31aa4..aca7f9cc6109 100644
--- a/drivers/gpu/drm/armada/armada_gem.c
+++ b/drivers/gpu/drm/armada/armada_gem.c
@@ -481,7 +481,7 @@ armada_gem_prime_map_dma_buf(struct dma_buf_attachment *attach,
 
  release:
 	for_each_sg(sgt->sgl, sg, num, i)
-		page_cache_release(sg_page(sg));
+		put_page(sg_page(sg));
  free_table:
 	sg_free_table(sgt);
  free_sgt:
@@ -502,7 +502,7 @@ static void armada_gem_prime_unmap_dma_buf(struct dma_buf_attachment *attach,
 	if (dobj->obj.filp) {
 		struct scatterlist *sg;
 		for_each_sg(sgt->sgl, sg, sgt->nents, i)
-			page_cache_release(sg_page(sg));
+			put_page(sg_page(sg));
 	}
 
 	sg_free_table(sgt);
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 2e8c77e71e1f..da0c5320789f 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -534,7 +534,7 @@ struct page **drm_gem_get_pages(struct drm_gem_object *obj)
 
 fail:
 	while (i--)
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 
 	drm_free_large(pages);
 	return ERR_CAST(p);
@@ -569,7 +569,7 @@ void drm_gem_put_pages(struct drm_gem_object *obj, struct page **pages,
 			mark_page_accessed(pages[i]);
 
 		/* Undo the reference we took when populating the table */
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 
 	drm_free_large(pages);
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index bb44bad15403..7d6468407fd6 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -177,7 +177,7 @@ i915_gem_object_get_pages_phys(struct drm_i915_gem_object *obj)
 		drm_clflush_virt_range(vaddr, PAGE_SIZE);
 		kunmap_atomic(src);
 
-		page_cache_release(page);
+		put_page(page);
 		vaddr += PAGE_SIZE;
 	}
 
@@ -243,7 +243,7 @@ i915_gem_object_put_pages_phys(struct drm_i915_gem_object *obj)
 			set_page_dirty(page);
 			if (obj->madv == I915_MADV_WILLNEED)
 				mark_page_accessed(page);
-			page_cache_release(page);
+			put_page(page);
 			vaddr += PAGE_SIZE;
 		}
 		obj->dirty = 0;
@@ -2204,7 +2204,7 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj)
 		if (obj->madv == I915_MADV_WILLNEED)
 			mark_page_accessed(page);
 
-		page_cache_release(page);
+		put_page(page);
 	}
 	obj->dirty = 0;
 
@@ -2344,7 +2344,7 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 err_pages:
 	sg_mark_end(sg);
 	for_each_sg_page(st->sgl, &sg_iter, st->nents, 0)
-		page_cache_release(sg_page_iter_page(&sg_iter));
+		put_page(sg_page_iter_page(&sg_iter));
 	sg_free_table(st);
 	kfree(st);
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 90dbf8121210..f35fa6698994 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -764,7 +764,7 @@ i915_gem_userptr_put_pages(struct drm_i915_gem_object *obj)
 			set_page_dirty(page);
 
 		mark_page_accessed(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	obj->dirty = 0;
 
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index 6d8c32377c6f..0deb7f047be0 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -609,7 +609,7 @@ static void radeon_ttm_tt_unpin_userptr(struct ttm_tt *ttm)
 			set_page_dirty(page);
 
 		mark_page_accessed(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	sg_free_table(ttm->sg);
diff --git a/drivers/gpu/drm/ttm/ttm_tt.c b/drivers/gpu/drm/ttm/ttm_tt.c
index 4e19d0f9cc30..077ae9b2865d 100644
--- a/drivers/gpu/drm/ttm/ttm_tt.c
+++ b/drivers/gpu/drm/ttm/ttm_tt.c
@@ -311,7 +311,7 @@ int ttm_tt_swapin(struct ttm_tt *ttm)
 			goto out_err;
 
 		copy_highpage(to_page, from_page);
-		page_cache_release(from_page);
+		put_page(from_page);
 	}
 
 	if (!(ttm->page_flags & TTM_PAGE_FLAG_PERSISTENT_SWAP))
@@ -361,7 +361,7 @@ int ttm_tt_swapout(struct ttm_tt *ttm, struct file *persistent_swap_storage)
 		copy_highpage(to_page, from_page);
 		set_page_dirty(to_page);
 		mark_page_accessed(to_page);
-		page_cache_release(to_page);
+		put_page(to_page);
 	}
 
 	ttm_tt_unpopulate(ttm);
diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index e797dfc07ae3..7e2a12c4fed2 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -188,7 +188,7 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 			if (NULL != (page = vsg->pages[i])) {
 				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
 					SetPageDirty(page);
-				page_cache_release(page);
+				put_page(page);
 			}
 		}
 	case dr_via_pages_alloc:
diff --git a/drivers/md/bitmap.c b/drivers/md/bitmap.c
index d80cce499a56..df77ddc96467 100644
--- a/drivers/md/bitmap.c
+++ b/drivers/md/bitmap.c
@@ -323,7 +323,7 @@ __clear_page_buffers(struct page *page)
 {
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
-	page_cache_release(page);
+	put_page(page);
 }
 static void free_buffers(struct page *page)
 {
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index df4c052c6bd6..f300f060b3f3 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -349,7 +349,7 @@ int videobuf_dma_free(struct videobuf_dmabuf *dma)
 
 	if (dma->pages) {
 		for (i = 0; i < dma->nr_pages; i++)
-			page_cache_release(dma->pages[i]);
+			put_page(dma->pages[i]);
 		kfree(dma->pages);
 		dma->pages = NULL;
 	}
diff --git a/drivers/misc/ibmasm/ibmasmfs.c b/drivers/misc/ibmasm/ibmasmfs.c
index e8b933111e0d..9c677f3f3c26 100644
--- a/drivers/misc/ibmasm/ibmasmfs.c
+++ b/drivers/misc/ibmasm/ibmasmfs.c
@@ -116,8 +116,8 @@ static int ibmasmfs_fill_super (struct super_block *sb, void *data, int silent)
 {
 	struct inode *root;
 
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = IBMASMFS_MAGIC;
 	sb->s_op = &ibmasmfs_s_ops;
 	sb->s_time_gran = 1;
diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index f42d9c4e4561..f84a4275ca29 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -728,7 +728,7 @@ static void qp_release_pages(struct page **pages,
 		if (dirty)
 			set_page_dirty(pages[i]);
 
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 		pages[i] = NULL;
 	}
 }
diff --git a/drivers/mmc/core/host.c b/drivers/mmc/core/host.c
index 0aecd5c00b86..8f86feff3e3a 100644
--- a/drivers/mmc/core/host.c
+++ b/drivers/mmc/core/host.c
@@ -355,11 +355,11 @@ struct mmc_host *mmc_alloc_host(int extra, struct device *dev)
 	 * They have to set these according to their abilities.
 	 */
 	host->max_segs = 1;
-	host->max_seg_size = PAGE_CACHE_SIZE;
+	host->max_seg_size = PAGE_SIZE;
 
-	host->max_req_size = PAGE_CACHE_SIZE;
+	host->max_req_size = PAGE_SIZE;
 	host->max_blk_size = 512;
-	host->max_blk_count = PAGE_CACHE_SIZE / 512;
+	host->max_blk_count = PAGE_SIZE / 512;
 
 	return host;
 }
diff --git a/drivers/mmc/host/sh_mmcif.c b/drivers/mmc/host/sh_mmcif.c
index 6234eab38ff3..a8f001d44683 100644
--- a/drivers/mmc/host/sh_mmcif.c
+++ b/drivers/mmc/host/sh_mmcif.c
@@ -1513,7 +1513,7 @@ static int sh_mmcif_probe(struct platform_device *pdev)
 		mmc->caps |= pd->caps;
 	mmc->max_segs = 32;
 	mmc->max_blk_size = 512;
-	mmc->max_req_size = PAGE_CACHE_SIZE * mmc->max_segs;
+	mmc->max_req_size = PAGE_SIZE * mmc->max_segs;
 	mmc->max_blk_count = mmc->max_req_size / mmc->max_blk_size;
 	mmc->max_seg_size = mmc->max_req_size;
 
diff --git a/drivers/mmc/host/tmio_mmc_dma.c b/drivers/mmc/host/tmio_mmc_dma.c
index 4a0d6b80eaa3..c3122c9e468f 100644
--- a/drivers/mmc/host/tmio_mmc_dma.c
+++ b/drivers/mmc/host/tmio_mmc_dma.c
@@ -63,7 +63,7 @@ static void tmio_mmc_start_dma_rx(struct tmio_mmc_host *host)
 		}
 	}
 
-	if ((!aligned && (host->sg_len > 1 || sg->length > PAGE_CACHE_SIZE ||
+	if ((!aligned && (host->sg_len > 1 || sg->length > PAGE_SIZE ||
 			  (align & PAGE_MASK))) || !multiple) {
 		ret = -EINVAL;
 		goto pio;
@@ -139,7 +139,7 @@ static void tmio_mmc_start_dma_tx(struct tmio_mmc_host *host)
 		}
 	}
 
-	if ((!aligned && (host->sg_len > 1 || sg->length > PAGE_CACHE_SIZE ||
+	if ((!aligned && (host->sg_len > 1 || sg->length > PAGE_SIZE ||
 			  (align & PAGE_MASK))) || !multiple) {
 		ret = -EINVAL;
 		goto pio;
diff --git a/drivers/mmc/host/tmio_mmc_pio.c b/drivers/mmc/host/tmio_mmc_pio.c
index a10fde40b6c3..233627e20299 100644
--- a/drivers/mmc/host/tmio_mmc_pio.c
+++ b/drivers/mmc/host/tmio_mmc_pio.c
@@ -1122,7 +1122,7 @@ int tmio_mmc_host_probe(struct tmio_mmc_host *_host,
 	mmc->caps2 |= pdata->capabilities2;
 	mmc->max_segs = 32;
 	mmc->max_blk_size = 512;
-	mmc->max_blk_count = (PAGE_CACHE_SIZE / mmc->max_blk_size) *
+	mmc->max_blk_count = (PAGE_SIZE / mmc->max_blk_size) *
 		mmc->max_segs;
 	mmc->max_req_size = mmc->max_blk_size * mmc->max_blk_count;
 	mmc->max_seg_size = mmc->max_req_size;
diff --git a/drivers/mmc/host/usdhi6rol0.c b/drivers/mmc/host/usdhi6rol0.c
index b47122d3e8d8..8eeca2b0f34a 100644
--- a/drivers/mmc/host/usdhi6rol0.c
+++ b/drivers/mmc/host/usdhi6rol0.c
@@ -1789,7 +1789,7 @@ static int usdhi6_probe(struct platform_device *pdev)
 	/* Set .max_segs to some random number. Feel free to adjust. */
 	mmc->max_segs = 32;
 	mmc->max_blk_size = 512;
-	mmc->max_req_size = PAGE_CACHE_SIZE * mmc->max_segs;
+	mmc->max_req_size = PAGE_SIZE * mmc->max_segs;
 	mmc->max_blk_count = mmc->max_req_size / mmc->max_blk_size;
 	/*
 	 * Setting .max_seg_size to 1 page would simplify our page-mapping code,
diff --git a/drivers/mtd/devices/block2mtd.c b/drivers/mtd/devices/block2mtd.c
index e2c0057737e6..7c887f111a7d 100644
--- a/drivers/mtd/devices/block2mtd.c
+++ b/drivers/mtd/devices/block2mtd.c
@@ -75,7 +75,7 @@ static int _block2mtd_erase(struct block2mtd_dev *dev, loff_t to, size_t len)
 				break;
 			}
 
-		page_cache_release(page);
+		put_page(page);
 		pages--;
 		index++;
 	}
@@ -124,7 +124,7 @@ static int block2mtd_read(struct mtd_info *mtd, loff_t from, size_t len,
 			return PTR_ERR(page);
 
 		memcpy(buf, page_address(page) + offset, cpylen);
-		page_cache_release(page);
+		put_page(page);
 
 		if (retlen)
 			*retlen += cpylen;
@@ -164,7 +164,7 @@ static int _block2mtd_write(struct block2mtd_dev *dev, const u_char *buf,
 			unlock_page(page);
 			balance_dirty_pages_ratelimited(mapping);
 		}
-		page_cache_release(page);
+		put_page(page);
 
 		if (retlen)
 			*retlen += cpylen;
diff --git a/drivers/mtd/nand/nandsim.c b/drivers/mtd/nand/nandsim.c
index 1fd519503bb1..a58169a28741 100644
--- a/drivers/mtd/nand/nandsim.c
+++ b/drivers/mtd/nand/nandsim.c
@@ -1339,7 +1339,7 @@ static void put_pages(struct nandsim *ns)
 	int i;
 
 	for (i = 0; i < ns->held_cnt; i++)
-		page_cache_release(ns->held_pages[i]);
+		put_page(ns->held_pages[i]);
 }
 
 /* Get page cache pages in advance to provide NOFS memory allocation */
@@ -1349,8 +1349,8 @@ static int get_pages(struct nandsim *ns, struct file *file, size_t count, loff_t
 	struct page *page;
 	struct address_space *mapping = file->f_mapping;
 
-	start_index = pos >> PAGE_CACHE_SHIFT;
-	end_index = (pos + count - 1) >> PAGE_CACHE_SHIFT;
+	start_index = pos >> PAGE_SHIFT;
+	end_index = (pos + count - 1) >> PAGE_SHIFT;
 	if (end_index - start_index + 1 > NS_MAX_HELD_PAGES)
 		return -EINVAL;
 	ns->held_cnt = 0;
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index c32cbb593600..f068b6513cd2 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -1204,7 +1204,7 @@ static int btt_rw_page(struct block_device *bdev, sector_t sector,
 {
 	struct btt *btt = bdev->bd_disk->private_data;
 
-	btt_do_bvec(btt, NULL, page, PAGE_CACHE_SIZE, 0, rw, sector);
+	btt_do_bvec(btt, NULL, page, PAGE_SIZE, 0, rw, sector);
 	page_endio(page, rw & WRITE, 0);
 	return 0;
 }
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index ca5721c306bb..a1a29c711532 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -151,7 +151,7 @@ static int pmem_rw_page(struct block_device *bdev, sector_t sector,
 	struct pmem_device *pmem = bdev->bd_disk->private_data;
 	int rc;
 
-	rc = pmem_do_bvec(pmem, page, PAGE_CACHE_SIZE, 0, rw, sector);
+	rc = pmem_do_bvec(pmem, page, PAGE_SIZE, 0, rw, sector);
 	if (rw & WRITE)
 		wmb_pmem();
 
diff --git a/drivers/oprofile/oprofilefs.c b/drivers/oprofile/oprofilefs.c
index b48ac6300c79..a0e5260bd006 100644
--- a/drivers/oprofile/oprofilefs.c
+++ b/drivers/oprofile/oprofilefs.c
@@ -239,8 +239,8 @@ static int oprofilefs_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct inode *root_inode;
 
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = OPROFILEFS_MAGIC;
 	sb->s_op = &s_ops;
 	sb->s_time_gran = 1;
diff --git a/drivers/scsi/sd.c b/drivers/scsi/sd.c
index 5a5457ac9cdb..1bd0753f678a 100644
--- a/drivers/scsi/sd.c
+++ b/drivers/scsi/sd.c
@@ -2891,7 +2891,7 @@ static int sd_revalidate_disk(struct gendisk *disk)
 	if (sdkp->opt_xfer_blocks &&
 	    sdkp->opt_xfer_blocks <= dev_max &&
 	    sdkp->opt_xfer_blocks <= SD_DEF_XFER_BLOCKS &&
-	    sdkp->opt_xfer_blocks * sdp->sector_size >= PAGE_CACHE_SIZE)
+	    sdkp->opt_xfer_blocks * sdp->sector_size >= PAGE_SIZE)
 		rw_max = q->limits.io_opt =
 			sdkp->opt_xfer_blocks * sdp->sector_size;
 	else
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index 71c5138ddf94..dbf1882cfbac 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -4941,7 +4941,7 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
  out_unmap:
 	if (res > 0) {
 		for (j=0; j < res; j++)
-			page_cache_release(pages[j]);
+			put_page(pages[j]);
 		res = 0;
 	}
 	kfree(pages);
@@ -4963,7 +4963,7 @@ static int sgl_unmap_user_pages(struct st_buffer *STbp,
 		/* FIXME: cache flush missing for rw==READ
 		 * FIXME: call the correct reference counting function
 		 */
-		page_cache_release(page);
+		put_page(page);
 	}
 	kfree(STbp->mapped_pages);
 	STbp->mapped_pages = NULL;
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index dab486261154..13335437c69c 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -88,7 +88,7 @@ do {								    \
 } while (0)
 
 #ifndef LIBCFS_VMALLOC_SIZE
-#define LIBCFS_VMALLOC_SIZE	(2 << PAGE_CACHE_SHIFT) /* 2 pages */
+#define LIBCFS_VMALLOC_SIZE	(2 << PAGE_SHIFT) /* 2 pages */
 #endif
 
 #define LIBCFS_ALLOC_PRE(size, mask)					    \
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
index 0f2fd79e5ec8..837eb22749c3 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
@@ -57,7 +57,7 @@
 #include "../libcfs_cpu.h"
 #endif
 
-#define CFS_PAGE_MASK		   (~((__u64)PAGE_CACHE_SIZE-1))
+#define CFS_PAGE_MASK		   (~((__u64)PAGE_SIZE-1))
 #define page_index(p)       ((p)->index)
 
 #define memory_pressure_get() (current->flags & PF_MEMALLOC)
@@ -67,7 +67,7 @@
 #if BITS_PER_LONG == 32
 /* limit to lowmem on 32-bit systems */
 #define NUM_CACHEPAGES \
-	min(totalram_pages, 1UL << (30 - PAGE_CACHE_SHIFT) * 3 / 4)
+	min(totalram_pages, 1UL << (30 - PAGE_SHIFT) * 3 / 4)
 #else
 #define NUM_CACHEPAGES totalram_pages
 #endif
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 3e1f24e77f64..d4ce06d0aeeb 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -291,7 +291,7 @@ ksocknal_lib_kiov_vmap(lnet_kiov_t *kiov, int niov,
 
 	for (nob = i = 0; i < niov; i++) {
 		if ((kiov[i].kiov_offset && i > 0) ||
-		    (kiov[i].kiov_offset + kiov[i].kiov_len != PAGE_CACHE_SIZE && i < niov - 1))
+		    (kiov[i].kiov_offset + kiov[i].kiov_len != PAGE_SIZE && i < niov - 1))
 			return NULL;
 
 		pages[i] = kiov[i].kiov_page;
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index c90e5102fe06..c3d628bac5b8 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -517,7 +517,7 @@ int libcfs_debug_init(unsigned long bufsize)
 		max = TCD_MAX_PAGES;
 	} else {
 		max = max / num_possible_cpus();
-		max <<= (20 - PAGE_CACHE_SHIFT);
+		max <<= (20 - PAGE_SHIFT);
 	}
 	rc = cfs_tracefile_init(max);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index ec3bc04bd89f..244eb89eef68 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -182,7 +182,7 @@ cfs_trace_get_tage_try(struct cfs_trace_cpu_data *tcd, unsigned long len)
 	if (tcd->tcd_cur_pages > 0) {
 		__LASSERT(!list_empty(&tcd->tcd_pages));
 		tage = cfs_tage_from_list(tcd->tcd_pages.prev);
-		if (tage->used + len <= PAGE_CACHE_SIZE)
+		if (tage->used + len <= PAGE_SIZE)
 			return tage;
 	}
 
@@ -260,7 +260,7 @@ static struct cfs_trace_page *cfs_trace_get_tage(struct cfs_trace_cpu_data *tcd,
 	 * from here: this will lead to infinite recursion.
 	 */
 
-	if (len > PAGE_CACHE_SIZE) {
+	if (len > PAGE_SIZE) {
 		pr_err("cowardly refusing to write %lu bytes in a page\n", len);
 		return NULL;
 	}
@@ -349,7 +349,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	for (i = 0; i < 2; i++) {
 		tage = cfs_trace_get_tage(tcd, needed + known_size + 1);
 		if (!tage) {
-			if (needed + known_size > PAGE_CACHE_SIZE)
+			if (needed + known_size > PAGE_SIZE)
 				mask |= D_ERROR;
 
 			cfs_trace_put_tcd(tcd);
@@ -360,7 +360,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 		string_buf = (char *)page_address(tage->page) +
 					tage->used + known_size;
 
-		max_nob = PAGE_CACHE_SIZE - tage->used - known_size;
+		max_nob = PAGE_SIZE - tage->used - known_size;
 		if (max_nob <= 0) {
 			printk(KERN_EMERG "negative max_nob: %d\n",
 			       max_nob);
@@ -424,7 +424,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	__LASSERT(debug_buf == string_buf);
 
 	tage->used += needed;
-	__LASSERT(tage->used <= PAGE_CACHE_SIZE);
+	__LASSERT(tage->used <= PAGE_SIZE);
 
 console:
 	if ((mask & libcfs_printk) == 0) {
@@ -835,7 +835,7 @@ EXPORT_SYMBOL(cfs_trace_copyout_string);
 
 int cfs_trace_allocate_string_buffer(char **str, int nob)
 {
-	if (nob > 2 * PAGE_CACHE_SIZE)	    /* string must be "sensible" */
+	if (nob > 2 * PAGE_SIZE)	    /* string must be "sensible" */
 		return -EINVAL;
 
 	*str = kmalloc(nob, GFP_KERNEL | __GFP_ZERO);
@@ -951,7 +951,7 @@ int cfs_trace_set_debug_mb(int mb)
 	}
 
 	mb /= num_possible_cpus();
-	pages = mb << (20 - PAGE_CACHE_SHIFT);
+	pages = mb << (20 - PAGE_SHIFT);
 
 	cfs_tracefile_write_lock();
 
@@ -977,7 +977,7 @@ int cfs_trace_get_debug_mb(void)
 
 	cfs_tracefile_read_unlock();
 
-	return (total_pages >> (20 - PAGE_CACHE_SHIFT)) + 1;
+	return (total_pages >> (20 - PAGE_SHIFT)) + 1;
 }
 
 static int tracefiled(void *arg)
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 4c77f9044dd3..ac84e7f4c859 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -87,7 +87,7 @@ void libcfs_unregister_panic_notifier(void);
 extern int  libcfs_panic_in_progress;
 int cfs_trace_max_debug_mb(void);
 
-#define TCD_MAX_PAGES (5 << (20 - PAGE_CACHE_SHIFT))
+#define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
 #define TCD_STOCK_PAGES (TCD_MAX_PAGES)
 #define CFS_TRACEFILE_SIZE (500 << 20)
 
@@ -96,7 +96,7 @@ int cfs_trace_max_debug_mb(void);
 /*
  * Private declare for tracefile
  */
-#define TCD_MAX_PAGES (5 << (20 - PAGE_CACHE_SHIFT))
+#define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
 #define TCD_STOCK_PAGES (TCD_MAX_PAGES)
 
 #define CFS_TRACEFILE_SIZE (500 << 20)
@@ -257,7 +257,7 @@ do {								    \
 do {								    \
 	__LASSERT(tage);					\
 	__LASSERT(tage->page);				  \
-	__LASSERT(tage->used <= PAGE_CACHE_SIZE);			 \
+	__LASSERT(tage->used <= PAGE_SIZE);			 \
 	__LASSERT(page_count(tage->page) > 0);		      \
 } while (0)
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index c74514f99f90..75d31217bf92 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -139,7 +139,7 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 		for (i = 0; i < (int)niov; i++) {
 			/* We take the page pointer on trust */
 			if (lmd->md_iov.kiov[i].kiov_offset +
-			    lmd->md_iov.kiov[i].kiov_len > PAGE_CACHE_SIZE)
+			    lmd->md_iov.kiov[i].kiov_len > PAGE_SIZE)
 				return -EINVAL; /* invalid length */
 
 			total_length += lmd->md_iov.kiov[i].kiov_len;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 0009a8de77d5..f19aa9320e34 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -549,12 +549,12 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 		if (len <= frag_len) {
 			dst->kiov_len = len;
 			LASSERT(dst->kiov_offset + dst->kiov_len
-					<= PAGE_CACHE_SIZE);
+					<= PAGE_SIZE);
 			return niov;
 		}
 
 		dst->kiov_len = frag_len;
-		LASSERT(dst->kiov_offset + dst->kiov_len <= PAGE_CACHE_SIZE);
+		LASSERT(dst->kiov_offset + dst->kiov_len <= PAGE_SIZE);
 
 		len -= frag_len;
 		dst++;
@@ -887,7 +887,7 @@ lnet_msg2bufpool(lnet_msg_t *msg)
 	rbp = &the_lnet.ln_rtrpools[cpt][0];
 
 	LASSERT(msg->msg_len <= LNET_MTU);
-	while (msg->msg_len > (unsigned int)rbp->rbp_npages * PAGE_CACHE_SIZE) {
+	while (msg->msg_len > (unsigned int)rbp->rbp_npages * PAGE_SIZE) {
 		rbp++;
 		LASSERT(rbp < &the_lnet.ln_rtrpools[cpt][LNET_NRBPOOLS]);
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index cc0c2753dd63..891fd59401d7 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -166,9 +166,9 @@ lnet_ipif_enumerate(char ***namesp)
 	nalloc = 16;	/* first guess at max interfaces */
 	toobig = 0;
 	for (;;) {
-		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
+		if (nalloc * sizeof(*ifr) > PAGE_SIZE) {
 			toobig = 1;
-			nalloc = PAGE_CACHE_SIZE / sizeof(*ifr);
+			nalloc = PAGE_SIZE / sizeof(*ifr);
 			CWARN("Too many interfaces: only enumerating first %d\n",
 			      nalloc);
 		}
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 61459cf9d58f..b01dc424c514 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -27,8 +27,8 @@
 #define LNET_NRB_SMALL_PAGES	1
 #define LNET_NRB_LARGE_MIN	256	/* min value for each CPT */
 #define LNET_NRB_LARGE		(LNET_NRB_LARGE_MIN * 4)
-#define LNET_NRB_LARGE_PAGES   ((LNET_MTU + PAGE_CACHE_SIZE - 1) >> \
-				 PAGE_CACHE_SHIFT)
+#define LNET_NRB_LARGE_PAGES   ((LNET_MTU + PAGE_SIZE - 1) >> \
+				 PAGE_SHIFT)
 
 static char *forwarding = "";
 module_param(forwarding, charp, 0444);
@@ -1338,7 +1338,7 @@ lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
 			return NULL;
 		}
 
-		rb->rb_kiov[i].kiov_len = PAGE_CACHE_SIZE;
+		rb->rb_kiov[i].kiov_len = PAGE_SIZE;
 		rb->rb_kiov[i].kiov_offset = 0;
 		rb->rb_kiov[i].kiov_page = page;
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index eebc92412061..dcb6e506f592 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -90,7 +90,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 		 * NB: this is not going to work for variable page size,
 		 * but we have to keep it for compatibility
 		 */
-		len = npg * PAGE_CACHE_SIZE;
+		len = npg * PAGE_SIZE;
 
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
@@ -104,7 +104,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		len = breq->blk_len;
-		npg = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		npg = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	}
 
 	if (npg > LNET_MAX_IOV || npg <= 0)
@@ -167,13 +167,13 @@ brw_fill_page(struct page *pg, int pattern, __u64 magic)
 
 	if (pattern == LST_BRW_CHECK_SIMPLE) {
 		memcpy(addr, &magic, BRW_MSIZE);
-		addr += PAGE_CACHE_SIZE - BRW_MSIZE;
+		addr += PAGE_SIZE - BRW_MSIZE;
 		memcpy(addr, &magic, BRW_MSIZE);
 		return;
 	}
 
 	if (pattern == LST_BRW_CHECK_FULL) {
-		for (i = 0; i < PAGE_CACHE_SIZE / BRW_MSIZE; i++)
+		for (i = 0; i < PAGE_SIZE / BRW_MSIZE; i++)
 			memcpy(addr + i * BRW_MSIZE, &magic, BRW_MSIZE);
 		return;
 	}
@@ -198,7 +198,7 @@ brw_check_page(struct page *pg, int pattern, __u64 magic)
 		if (data != magic)
 			goto bad_data;
 
-		addr += PAGE_CACHE_SIZE - BRW_MSIZE;
+		addr += PAGE_SIZE - BRW_MSIZE;
 		data = *((__u64 *)addr);
 		if (data != magic)
 			goto bad_data;
@@ -207,7 +207,7 @@ brw_check_page(struct page *pg, int pattern, __u64 magic)
 	}
 
 	if (pattern == LST_BRW_CHECK_FULL) {
-		for (i = 0; i < PAGE_CACHE_SIZE / BRW_MSIZE; i++) {
+		for (i = 0; i < PAGE_SIZE / BRW_MSIZE; i++) {
 			data = *(((__u64 *)addr) + i);
 			if (data != magic)
 				goto bad_data;
@@ -278,7 +278,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		npg = breq->blk_npg;
-		len = npg * PAGE_CACHE_SIZE;
+		len = npg * PAGE_SIZE;
 
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
@@ -292,7 +292,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		opc = breq->blk_opc;
 		flags = breq->blk_flags;
 		len = breq->blk_len;
-		npg = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		npg = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	}
 
 	rc = sfw_create_test_rpc(tsu, dest, sn->sn_features, npg, len, &rpc);
@@ -463,10 +463,10 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 			reply->brw_status = EINVAL;
 			return 0;
 		}
-		npg = reqst->brw_len >> PAGE_CACHE_SHIFT;
+		npg = reqst->brw_len >> PAGE_SHIFT;
 
 	} else {
-		npg = (reqst->brw_len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		npg = (reqst->brw_len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	}
 
 	replymsg->msg_ses_feats = reqstmsg->msg_ses_feats;
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 5c7cb72eac9a..79ee6c0bf7c1 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -743,7 +743,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	if (args->lstio_tes_param &&
 	    (args->lstio_tes_param_len <= 0 ||
 	     args->lstio_tes_param_len >
-	     PAGE_CACHE_SIZE - sizeof(lstcon_test_t)))
+	     PAGE_SIZE - sizeof(lstcon_test_t)))
 		return -EINVAL;
 
 	LIBCFS_ALLOC(batch_name, args->lstio_tes_bat_nmlen + 1);
@@ -819,7 +819,7 @@ lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 
 	opc = data->ioc_u32[0];
 
-	if (data->ioc_plen1 > PAGE_CACHE_SIZE)
+	if (data->ioc_plen1 > PAGE_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(buf, data->ioc_plen1);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index bcd78888f9cc..35a227d0c657 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -786,8 +786,8 @@ lstcon_bulkrpc_v0_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
 	test_bulk_req_t *brq = &req->tsr_u.bulk_v0;
 
 	brq->blk_opc = param->blk_opc;
-	brq->blk_npg = (param->blk_size + PAGE_CACHE_SIZE - 1) /
-			PAGE_CACHE_SIZE;
+	brq->blk_npg = (param->blk_size + PAGE_SIZE - 1) /
+			PAGE_SIZE;
 	brq->blk_flags = param->blk_flags;
 
 	return 0;
@@ -822,7 +822,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 	if (transop == LST_TRANS_TSBCLIADD) {
 		npg = sfw_id_pages(test->tes_span);
 		nob = !(feats & LST_FEAT_BULK_LEN) ?
-		      npg * PAGE_CACHE_SIZE :
+		      npg * PAGE_SIZE :
 		      sizeof(lnet_process_id_packed_t) * test->tes_span;
 	}
 
@@ -851,8 +851,8 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 			LASSERT(nob > 0);
 
 			len = !(feats & LST_FEAT_BULK_LEN) ?
-			      PAGE_CACHE_SIZE :
-			      min_t(int, nob, PAGE_CACHE_SIZE);
+			      PAGE_SIZE :
+			      min_t(int, nob, PAGE_SIZE);
 			nob -= len;
 
 			bulk->bk_iovs[i].kiov_offset = 0;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 926c3970c498..e2c532399366 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -1161,7 +1161,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 		int len;
 
 		if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
-			len = npg * PAGE_CACHE_SIZE;
+			len = npg * PAGE_SIZE;
 
 		} else {
 			len = sizeof(lnet_process_id_packed_t) *
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 69be7d6f48fa..7d7748d96332 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -90,7 +90,7 @@ void srpc_set_counters(const srpc_counters_t *cnt)
 static int
 srpc_add_bulk_page(srpc_bulk_t *bk, struct page *pg, int i, int nob)
 {
-	nob = min_t(int, nob, PAGE_CACHE_SIZE);
+	nob = min_t(int, nob, PAGE_SIZE);
 
 	LASSERT(nob > 0);
 	LASSERT(i >= 0 && i < bk->bk_niov);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 288522d4d7b9..5321ddec9580 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -393,7 +393,7 @@ typedef struct sfw_test_instance {
 /* XXX: trailing (PAGE_CACHE_SIZE % sizeof(lnet_process_id_t)) bytes at
  * the end of pages are not used */
 #define SFW_MAX_CONCUR	   LST_MAX_CONCUR
-#define SFW_ID_PER_PAGE    (PAGE_CACHE_SIZE / sizeof(lnet_process_id_packed_t))
+#define SFW_ID_PER_PAGE    (PAGE_SIZE / sizeof(lnet_process_id_packed_t))
 #define SFW_MAX_NDESTS	   (LNET_MAX_IOV * SFW_ID_PER_PAGE)
 #define sfw_id_pages(n)    (((n) + SFW_ID_PER_PAGE - 1) / SFW_ID_PER_PAGE)
 
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
index 33e0b99e1fb4..c6c7f54637fb 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
@@ -52,7 +52,7 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 		return;
 
 	if (PagePrivate(page))
-		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		page->mapping->a_ops->invalidatepage(page, 0, PAGE_SIZE);
 
 	cancel_dirty_page(page);
 	ClearPageMappedToDisk(page);
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index da8bc6eadd13..1e2ebe5cc998 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1031,7 +1031,7 @@ static inline int lu_dirent_size(struct lu_dirent *ent)
 #define LU_PAGE_SIZE  (1UL << LU_PAGE_SHIFT)
 #define LU_PAGE_MASK  (~(LU_PAGE_SIZE - 1))
 
-#define LU_PAGE_COUNT (1 << (PAGE_CACHE_SHIFT - LU_PAGE_SHIFT))
+#define LU_PAGE_COUNT (1 << (PAGE_SHIFT - LU_PAGE_SHIFT))
 
 /** @} lu_dir */
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index df94f9f3bef2..af77eb359c43 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -155,12 +155,12 @@ static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
 		if (cli->cl_max_mds_easize < body->max_mdsize) {
 			cli->cl_max_mds_easize = body->max_mdsize;
 			cli->cl_default_mds_easize =
-			    min_t(__u32, body->max_mdsize, PAGE_CACHE_SIZE);
+			    min_t(__u32, body->max_mdsize, PAGE_SIZE);
 		}
 		if (cli->cl_max_mds_cookiesize < body->max_cookiesize) {
 			cli->cl_max_mds_cookiesize = body->max_cookiesize;
 			cli->cl_default_mds_cookiesize =
-			    min_t(__u32, body->max_cookiesize, PAGE_CACHE_SIZE);
+			    min_t(__u32, body->max_cookiesize, PAGE_SIZE);
 		}
 	}
 }
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 4fa1a18b7d15..a5e9095fbf36 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -99,13 +99,13 @@
  */
 #define PTLRPC_MAX_BRW_BITS	(LNET_MTU_BITS + PTLRPC_BULK_OPS_BITS)
 #define PTLRPC_MAX_BRW_SIZE	(1 << PTLRPC_MAX_BRW_BITS)
-#define PTLRPC_MAX_BRW_PAGES	(PTLRPC_MAX_BRW_SIZE >> PAGE_CACHE_SHIFT)
+#define PTLRPC_MAX_BRW_PAGES	(PTLRPC_MAX_BRW_SIZE >> PAGE_SHIFT)
 
 #define ONE_MB_BRW_SIZE		(1 << LNET_MTU_BITS)
 #define MD_MAX_BRW_SIZE		(1 << LNET_MTU_BITS)
-#define MD_MAX_BRW_PAGES	(MD_MAX_BRW_SIZE >> PAGE_CACHE_SHIFT)
+#define MD_MAX_BRW_PAGES	(MD_MAX_BRW_SIZE >> PAGE_SHIFT)
 #define DT_MAX_BRW_SIZE		PTLRPC_MAX_BRW_SIZE
-#define DT_MAX_BRW_PAGES	(DT_MAX_BRW_SIZE >> PAGE_CACHE_SHIFT)
+#define DT_MAX_BRW_PAGES	(DT_MAX_BRW_SIZE >> PAGE_SHIFT)
 #define OFD_MAX_BRW_SIZE	(1 << LNET_MTU_BITS)
 
 /* When PAGE_SIZE is a constant, we can check our arithmetic here with cpp! */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 4a0f2e8b19f6..f4167db65b5d 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1318,7 +1318,7 @@ bad_format:
 
 static inline int cli_brw_size(struct obd_device *obd)
 {
-	return obd->u.cli.cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
+	return obd->u.cli.cl_max_pages_per_rpc << PAGE_SHIFT;
 }
 
 #endif /* __OBD_H */
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 225262fa67b6..f8ee3a3254ba 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -500,7 +500,7 @@ extern char obd_jobid_var[];
 
 #ifdef POISON_BULK
 #define POISON_PAGE(page, val) do {		  \
-	memset(kmap(page), val, PAGE_CACHE_SIZE); \
+	memset(kmap(page), val, PAGE_SIZE); \
 	kunmap(page);				  \
 } while (0)
 #else
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index aced41ab93a1..96141d17d07f 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -758,9 +758,9 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 				 * --bug 17336
 				 */
 				loff_t size = cl_isize_read(inode);
-				loff_t cur_index = start >> PAGE_CACHE_SHIFT;
+				loff_t cur_index = start >> PAGE_SHIFT;
 				loff_t size_index = (size - 1) >>
-						    PAGE_CACHE_SHIFT;
+						    PAGE_SHIFT;
 
 				if ((size == 0 && cur_index != 0) ||
 				    size_index < cur_index)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index b586d5a88d00..7dd7df59aa1f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -307,8 +307,8 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	cli->cl_avail_grant = 0;
 	/* FIXME: Should limit this for the sum of all cl_dirty_max. */
 	cli->cl_dirty_max = OSC_MAX_DIRTY_DEFAULT * 1024 * 1024;
-	if (cli->cl_dirty_max >> PAGE_CACHE_SHIFT > totalram_pages / 8)
-		cli->cl_dirty_max = totalram_pages << (PAGE_CACHE_SHIFT - 3);
+	if (cli->cl_dirty_max >> PAGE_SHIFT > totalram_pages / 8)
+		cli->cl_dirty_max = totalram_pages << (PAGE_SHIFT - 3);
 	INIT_LIST_HEAD(&cli->cl_cache_waiters);
 	INIT_LIST_HEAD(&cli->cl_loi_ready_list);
 	INIT_LIST_HEAD(&cli->cl_loi_hp_ready_list);
@@ -353,15 +353,15 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	 * In the future this should likely be increased. LU-1431
 	 */
 	cli->cl_max_pages_per_rpc = min_t(int, PTLRPC_MAX_BRW_PAGES,
-					  LNET_MTU >> PAGE_CACHE_SHIFT);
+					  LNET_MTU >> PAGE_SHIFT);
 
 	if (!strcmp(name, LUSTRE_MDC_NAME)) {
 		cli->cl_max_rpcs_in_flight = MDC_MAX_RIF_DEFAULT;
-	} else if (totalram_pages >> (20 - PAGE_CACHE_SHIFT) <= 128 /* MB */) {
+	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 128 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 2;
-	} else if (totalram_pages >> (20 - PAGE_CACHE_SHIFT) <= 256 /* MB */) {
+	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 256 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 3;
-	} else if (totalram_pages >> (20 - PAGE_CACHE_SHIFT) <= 512 /* MB */) {
+	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 512 /* MB */) {
 		cli->cl_max_rpcs_in_flight = 4;
 	} else {
 		cli->cl_max_rpcs_in_flight = OSC_MAX_RIF_DEFAULT;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 3e937b050203..b913ba9cf97c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -107,7 +107,7 @@
 /*
  * 50 ldlm locks for 1MB of RAM.
  */
-#define LDLM_POOL_HOST_L ((NUM_CACHEPAGES >> (20 - PAGE_CACHE_SHIFT)) * 50)
+#define LDLM_POOL_HOST_L ((NUM_CACHEPAGES >> (20 - PAGE_SHIFT)) * 50)
 
 /*
  * Maximal possible grant step plan in %.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index c7904a96f9af..74e193e52cd6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -546,7 +546,7 @@ static inline int ldlm_req_handles_avail(int req_size, int off)
 {
 	int avail;
 
-	avail = min_t(int, LDLM_MAXREQSIZE, PAGE_CACHE_SIZE - 512) - req_size;
+	avail = min_t(int, LDLM_MAXREQSIZE, PAGE_SIZE - 512) - req_size;
 	if (likely(avail >= 0))
 		avail /= (int)sizeof(struct lustre_handle);
 	else
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 4e0a3e583330..a7c02e07fd75 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -153,7 +153,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	struct page **page_pool;
 	struct page *page;
 	struct lu_dirpage *dp;
-	int max_pages = ll_i2sbi(inode)->ll_md_brw_size >> PAGE_CACHE_SHIFT;
+	int max_pages = ll_i2sbi(inode)->ll_md_brw_size >> PAGE_SHIFT;
 	int nrdpgs = 0; /* number of pages read actually */
 	int npages;
 	int i;
@@ -193,8 +193,8 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 		if (body->valid & OBD_MD_FLSIZE)
 			cl_isize_write(inode, body->size);
 
-		nrdpgs = (request->rq_bulk->bd_nob_transferred+PAGE_CACHE_SIZE-1)
-			 >> PAGE_CACHE_SHIFT;
+		nrdpgs = (request->rq_bulk->bd_nob_transferred+PAGE_SIZE-1)
+			 >> PAGE_SHIFT;
 		SetPageUptodate(page0);
 	}
 	unlock_page(page0);
@@ -209,7 +209,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 		page = page_pool[i];
 
 		if (rc < 0 || i >= nrdpgs) {
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -230,7 +230,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 			CDEBUG(D_VFSTRACE, "page %lu add to page cache failed: %d\n",
 			       offset, ret);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	if (page_pool != &page0)
@@ -247,7 +247,7 @@ void ll_release_page(struct page *page, int remove)
 			truncate_complete_page(page->mapping, page);
 		unlock_page(page);
 	}
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -273,7 +273,7 @@ static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
 	if (found > 0 && !radix_tree_exceptional_entry(page)) {
 		struct lu_dirpage *dp;
 
-		page_cache_get(page);
+		get_page(page);
 		spin_unlock_irq(&mapping->tree_lock);
 		/*
 		 * In contrast to find_lock_page() we are sure that directory
@@ -313,7 +313,7 @@ static struct page *ll_dir_page_locate(struct inode *dir, __u64 *hash,
 				page = NULL;
 			}
 		} else {
-			page_cache_release(page);
+			put_page(page);
 			page = ERR_PTR(-EIO);
 		}
 
@@ -1507,7 +1507,7 @@ skip_lmm:
 			st.st_gid     = body->gid;
 			st.st_rdev    = body->rdev;
 			st.st_size    = body->size;
-			st.st_blksize = PAGE_CACHE_SIZE;
+			st.st_blksize = PAGE_SIZE;
 			st.st_blocks  = body->blocks;
 			st.st_atime   = body->atime;
 			st.st_mtime   = body->mtime;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 973f5cdec192..5394365cc595 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -310,10 +310,10 @@ static inline struct ll_inode_info *ll_i2info(struct inode *inode)
 /* default to about 40meg of readahead on a given system.  That much tied
  * up in 512k readahead requests serviced at 40ms each is about 1GB/s.
  */
-#define SBI_DEFAULT_READAHEAD_MAX (40UL << (20 - PAGE_CACHE_SHIFT))
+#define SBI_DEFAULT_READAHEAD_MAX (40UL << (20 - PAGE_SHIFT))
 
 /* default to read-ahead full files smaller than 2MB on the second read */
-#define SBI_DEFAULT_READAHEAD_WHOLE_MAX (2UL << (20 - PAGE_CACHE_SHIFT))
+#define SBI_DEFAULT_READAHEAD_WHOLE_MAX (2UL << (20 - PAGE_SHIFT))
 
 enum ra_stat {
 	RA_STAT_HIT = 0,
@@ -975,13 +975,13 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 static inline void ll_invalidate_page(struct page *vmpage)
 {
 	struct address_space *mapping = vmpage->mapping;
-	loff_t offset = vmpage->index << PAGE_CACHE_SHIFT;
+	loff_t offset = vmpage->index << PAGE_SHIFT;
 
 	LASSERT(PageLocked(vmpage));
 	if (!mapping)
 		return;
 
-	ll_teardown_mmaps(mapping, offset, offset + PAGE_CACHE_SIZE);
+	ll_teardown_mmaps(mapping, offset, offset + PAGE_SIZE);
 	truncate_complete_page(mapping, vmpage);
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 6d6bb33e3655..b57a992688a8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -85,7 +85,7 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 
 	si_meminfo(&si);
 	pages = si.totalram - si.totalhigh;
-	if (pages >> (20 - PAGE_CACHE_SHIFT) < 512)
+	if (pages >> (20 - PAGE_SHIFT) < 512)
 		lru_page_max = pages / 2;
 	else
 		lru_page_max = (pages / 4) * 3;
@@ -272,12 +272,12 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	    valid != CLIENT_CONNECT_MDT_REQD) {
 		char *buf;
 
-		buf = kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+		buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
 		if (!buf) {
 			err = -ENOMEM;
 			goto out_md_fid;
 		}
-		obd_connect_flags2str(buf, PAGE_CACHE_SIZE,
+		obd_connect_flags2str(buf, PAGE_SIZE,
 				      valid ^ CLIENT_CONNECT_MDT_REQD, ",");
 		LCONSOLE_ERROR_MSG(0x170, "Server %s does not support feature(s) needed for correct operation of this client (%s). Please upgrade server or downgrade client.\n",
 				   sbi->ll_md_exp->exp_obd->obd_name, buf);
@@ -335,7 +335,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	if (data->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
 		sbi->ll_md_brw_size = data->ocd_brw_size;
 	else
-		sbi->ll_md_brw_size = PAGE_CACHE_SIZE;
+		sbi->ll_md_brw_size = PAGE_SIZE;
 
 	if (data->ocd_connect_flags & OBD_CONNECT_LAYOUTLOCK) {
 		LCONSOLE_INFO("Layout lock feature supported.\n");
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 69445a9f2011..5b484e62ffd0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -58,7 +58,7 @@ void policy_from_vma(ldlm_policy_data_t *policy,
 		     size_t count)
 {
 	policy->l_extent.start = ((addr - vma->vm_start) & CFS_PAGE_MASK) +
-				 (vma->vm_pgoff << PAGE_CACHE_SHIFT);
+				 (vma->vm_pgoff << PAGE_SHIFT);
 	policy->l_extent.end = (policy->l_extent.start + count - 1) |
 			       ~CFS_PAGE_MASK;
 }
@@ -321,7 +321,7 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 		vmpage = vio->u.fault.ft_vmpage;
 		if (result != 0 && vmpage) {
-			page_cache_release(vmpage);
+			put_page(vmpage);
 			vmf->page = NULL;
 		}
 	}
@@ -360,7 +360,7 @@ restart:
 		lock_page(vmpage);
 		if (unlikely(!vmpage->mapping)) { /* unlucky */
 			unlock_page(vmpage);
-			page_cache_release(vmpage);
+			put_page(vmpage);
 			vmf->page = NULL;
 
 			if (!printed && ++count > 16) {
@@ -457,7 +457,7 @@ int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last)
 	LASSERTF(last > first, "last %llu first %llu\n", last, first);
 	if (mapping_mapped(mapping)) {
 		rc = 0;
-		unmap_mapping_range(mapping, first + PAGE_CACHE_SIZE - 1,
+		unmap_mapping_range(mapping, first + PAGE_SIZE - 1,
 				    last - first + 1, 0);
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index b725fc16cf49..f169c0db63b4 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -218,7 +218,7 @@ static int do_bio_lustrebacked(struct lloop_device *lo, struct bio *head)
 		offset = (pgoff_t)(bio->bi_iter.bi_sector << 9) + lo->lo_offset;
 		bio_for_each_segment(bvec, bio, iter) {
 			BUG_ON(bvec.bv_offset != 0);
-			BUG_ON(bvec.bv_len != PAGE_CACHE_SIZE);
+			BUG_ON(bvec.bv_len != PAGE_SIZE);
 
 			pages[page_count] = bvec.bv_page;
 			offsets[page_count] = offset;
@@ -232,7 +232,7 @@ static int do_bio_lustrebacked(struct lloop_device *lo, struct bio *head)
 			(rw == WRITE) ? LPROC_LL_BRW_WRITE : LPROC_LL_BRW_READ,
 			page_count);
 
-	pvec->ldp_size = page_count << PAGE_CACHE_SHIFT;
+	pvec->ldp_size = page_count << PAGE_SHIFT;
 	pvec->ldp_nr = page_count;
 
 	/* FIXME: in ll_direct_rw_pages, it has to allocate many cl_page{}s to
@@ -507,7 +507,7 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
 
 	set_device_ro(bdev, (lo_flags & LO_FLAGS_READ_ONLY) != 0);
 
-	lo->lo_blocksize = PAGE_CACHE_SIZE;
+	lo->lo_blocksize = PAGE_SIZE;
 	lo->lo_device = bdev;
 	lo->lo_flags = lo_flags;
 	lo->lo_backing_file = file;
@@ -525,11 +525,11 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
 	lo->lo_queue->queuedata = lo;
 
 	/* queue parameters */
-	CLASSERT(PAGE_CACHE_SIZE < (1 << (sizeof(unsigned short) * 8)));
+	CLASSERT(PAGE_SIZE < (1 << (sizeof(unsigned short) * 8)));
 	blk_queue_logical_block_size(lo->lo_queue,
-				     (unsigned short)PAGE_CACHE_SIZE);
+				     (unsigned short)PAGE_SIZE);
 	blk_queue_max_hw_sectors(lo->lo_queue,
-				 LLOOP_MAX_SEGMENTS << (PAGE_CACHE_SHIFT - 9));
+				 LLOOP_MAX_SEGMENTS << (PAGE_SHIFT - 9));
 	blk_queue_max_segments(lo->lo_queue, LLOOP_MAX_SEGMENTS);
 
 	set_capacity(disks[lo->lo_number], size);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 45941a6600fe..27ab1261400e 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -233,7 +233,7 @@ static ssize_t max_read_ahead_mb_show(struct kobject *kobj,
 	pages_number = sbi->ll_ra_info.ra_max_pages;
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
 }
 
@@ -251,12 +251,12 @@ static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	pages_number *= 1 << (20 - PAGE_CACHE_SHIFT); /* MB -> pages */
+	pages_number *= 1 << (20 - PAGE_SHIFT); /* MB -> pages */
 
 	if (pages_number > totalram_pages / 2) {
 
 		CERROR("can't set file readahead more than %lu MB\n",
-		       totalram_pages >> (20 - PAGE_CACHE_SHIFT + 1)); /*1/2 of RAM*/
+		       totalram_pages >> (20 - PAGE_SHIFT + 1)); /*1/2 of RAM*/
 		return -ERANGE;
 	}
 
@@ -281,7 +281,7 @@ static ssize_t max_read_ahead_per_file_mb_show(struct kobject *kobj,
 	pages_number = sbi->ll_ra_info.ra_max_pages_per_file;
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
 }
 
@@ -326,7 +326,7 @@ static ssize_t max_read_ahead_whole_mb_show(struct kobject *kobj,
 	pages_number = sbi->ll_ra_info.ra_max_read_ahead_whole_pages;
 	spin_unlock(&sbi->ll_lock);
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	return lprocfs_read_frac_helper(buf, PAGE_SIZE, pages_number, mult);
 }
 
@@ -349,7 +349,7 @@ static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
 	 */
 	if (pages_number > sbi->ll_ra_info.ra_max_pages_per_file) {
 		CERROR("can't set max_read_ahead_whole_mb more than max_read_ahead_per_file_mb: %lu\n",
-		       sbi->ll_ra_info.ra_max_pages_per_file >> (20 - PAGE_CACHE_SHIFT));
+		       sbi->ll_ra_info.ra_max_pages_per_file >> (20 - PAGE_SHIFT));
 		return -ERANGE;
 	}
 
@@ -366,7 +366,7 @@ static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 	struct super_block     *sb    = m->private;
 	struct ll_sb_info      *sbi   = ll_s2sbi(sb);
 	struct cl_client_cache *cache = &sbi->ll_cache;
-	int shift = 20 - PAGE_CACHE_SHIFT;
+	int shift = 20 - PAGE_SHIFT;
 	int max_cached_mb;
 	int unused_mb;
 
@@ -405,7 +405,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 		return -EFAULT;
 	kernbuf[count] = 0;
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	buffer += lprocfs_find_named_value(kernbuf, "max_cached_mb:", &count) -
 		  kernbuf;
 	rc = lprocfs_write_frac_helper(buffer, count, &pages_number, mult);
@@ -415,7 +415,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 	if (pages_number < 0 || pages_number > totalram_pages) {
 		CERROR("%s: can't set max cache more than %lu MB\n",
 		       ll_get_fsname(sb, NULL, 0),
-		       totalram_pages >> (20 - PAGE_CACHE_SHIFT));
+		       totalram_pages >> (20 - PAGE_SHIFT));
 		return -ERANGE;
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 34614acf3f8e..4c7250ab54e6 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -146,10 +146,10 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 		 */
 		io->ci_lockreq = CILR_NEVER;
 
-		pos = vmpage->index << PAGE_CACHE_SHIFT;
+		pos = vmpage->index << PAGE_SHIFT;
 
 		/* Create a temp IO to serve write. */
-		result = cl_io_rw_init(env, io, CIT_WRITE, pos, PAGE_CACHE_SIZE);
+		result = cl_io_rw_init(env, io, CIT_WRITE, pos, PAGE_SIZE);
 		if (result == 0) {
 			cio->cui_fd = LUSTRE_FPRIVATE(file);
 			cio->cui_iter = NULL;
@@ -498,7 +498,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 		}
 		if (rc != 1)
 			unlock_page(vmpage);
-		page_cache_release(vmpage);
+		put_page(vmpage);
 	} else {
 		which = RA_STAT_FAILED_GRAB_PAGE;
 		msg   = "g_c_p_n failed";
@@ -527,7 +527,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
  * and max_read_ahead_per_file_mb otherwise the readahead budget can be used
  * up quickly which will affect read performance significantly. See LU-2816
  */
-#define RAS_INCREASE_STEP(inode) (ONE_MB_BRW_SIZE >> PAGE_CACHE_SHIFT)
+#define RAS_INCREASE_STEP(inode) (ONE_MB_BRW_SIZE >> PAGE_SHIFT)
 
 static inline int stride_io_mode(struct ll_readahead_state *ras)
 {
@@ -739,7 +739,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			end = rpc_boundary;
 
 		/* Truncate RA window to end of file */
-		end = min(end, (unsigned long)((kms - 1) >> PAGE_CACHE_SHIFT));
+		end = min(end, (unsigned long)((kms - 1) >> PAGE_SHIFT));
 
 		ras->ras_next_readahead = max(end, end + 1);
 		RAS_CDEBUG(ras);
@@ -776,7 +776,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	if (reserved != 0)
 		ll_ra_count_put(ll_i2sbi(inode), reserved);
 
-	if (ra_end == end + 1 && ra_end == (kms >> PAGE_CACHE_SHIFT))
+	if (ra_end == end + 1 && ra_end == (kms >> PAGE_SHIFT))
 		ll_ra_stats_inc(mapping, RA_STAT_EOF);
 
 	/* if we didn't get to the end of the region we reserved from
@@ -985,8 +985,8 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	if (ras->ras_requests == 2 && !ras->ras_request_index) {
 		__u64 kms_pages;
 
-		kms_pages = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
-			    PAGE_CACHE_SHIFT;
+		kms_pages = (i_size_read(inode) + PAGE_SIZE - 1) >>
+			    PAGE_SHIFT;
 
 		CDEBUG(D_READA, "kmsp %llu mwp %lu mp %lu\n", kms_pages,
 		       ra->ra_max_read_ahead_whole_pages, ra->ra_max_pages_per_file);
@@ -1173,7 +1173,7 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 		 * PageWriteback or clean the page.
 		 */
 		result = cl_sync_file_range(inode, offset,
-					    offset + PAGE_CACHE_SIZE - 1,
+					    offset + PAGE_SIZE - 1,
 					    CL_FSYNC_LOCAL, 1);
 		if (result > 0) {
 			/* actually we may have written more than one page.
@@ -1211,7 +1211,7 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	int ignore_layout = 0;
 
 	if (wbc->range_cyclic) {
-		start = mapping->writeback_index << PAGE_CACHE_SHIFT;
+		start = mapping->writeback_index << PAGE_SHIFT;
 		end = OBD_OBJECT_EOF;
 	} else {
 		start = wbc->range_start;
@@ -1241,7 +1241,7 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0)) {
 		if (end == OBD_OBJECT_EOF)
 			end = i_size_read(inode);
-		mapping->writeback_index = (end >> PAGE_CACHE_SHIFT) + 1;
+		mapping->writeback_index = (end >> PAGE_SHIFT) + 1;
 	}
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 7a5db67bc680..69aa15e8e3ef 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -87,7 +87,7 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 	 * below because they are run with page locked and all our io is
 	 * happening with locked page too
 	 */
-	if (offset == 0 && length == PAGE_CACHE_SIZE) {
+	if (offset == 0 && length == PAGE_SIZE) {
 		env = cl_env_get(&refcheck);
 		if (!IS_ERR(env)) {
 			inode = vmpage->mapping->host;
@@ -193,8 +193,8 @@ static inline int ll_get_user_pages(int rw, unsigned long user_addr,
 		return -EFBIG;
 	}
 
-	*max_pages = (user_addr + size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	*max_pages -= user_addr >> PAGE_CACHE_SHIFT;
+	*max_pages = (user_addr + size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	*max_pages -= user_addr >> PAGE_SHIFT;
 
 	*pages = libcfs_kvzalloc(*max_pages * sizeof(**pages), GFP_NOFS);
 	if (*pages) {
@@ -217,7 +217,7 @@ static void ll_free_user_pages(struct page **pages, int npages, int do_dirty)
 	for (i = 0; i < npages; i++) {
 		if (do_dirty)
 			set_page_dirty_lock(pages[i]);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 	kvfree(pages);
 }
@@ -357,7 +357,7 @@ static ssize_t ll_direct_IO_26_seg(const struct lu_env *env, struct cl_io *io,
  * up to 22MB for 128kB kmalloc and up to 682MB for 4MB kmalloc.
  */
 #define MAX_DIO_SIZE ((KMALLOC_MAX_SIZE / sizeof(struct brw_page) *	  \
-		       PAGE_CACHE_SIZE) & ~(DT_MAX_BRW_SIZE - 1))
+		       PAGE_SIZE) & ~(DT_MAX_BRW_SIZE - 1))
 static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 			       loff_t file_offset)
 {
@@ -382,8 +382,8 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:inode=%lu/%u(%p), size=%zd (max %lu), offset=%lld=%llx, pages %zd (max %lu)\n",
 	       inode->i_ino, inode->i_generation, inode, count, MAX_DIO_SIZE,
-	       file_offset, file_offset, count >> PAGE_CACHE_SHIFT,
-	       MAX_DIO_SIZE >> PAGE_CACHE_SHIFT);
+	       file_offset, file_offset, count >> PAGE_SHIFT,
+	       MAX_DIO_SIZE >> PAGE_SHIFT);
 
 	/* Check that all user buffers are aligned as well */
 	if (iov_iter_alignment(iter) & ~CFS_PAGE_MASK)
@@ -432,8 +432,8 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 			 * page worth of page pointers = 4MB on i386.
 			 */
 			if (result == -ENOMEM &&
-			    size > (PAGE_CACHE_SIZE / sizeof(*pages)) *
-				   PAGE_CACHE_SIZE) {
+			    size > (PAGE_SIZE / sizeof(*pages)) *
+			    PAGE_SIZE) {
 				size = ((((size / 2) - 1) |
 					 ~CFS_PAGE_MASK) + 1) &
 					CFS_PAGE_MASK;
@@ -474,10 +474,10 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			  loff_t pos, unsigned len, unsigned flags,
 			  struct page **pagep, void **fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	int rc;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
@@ -488,7 +488,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	rc = ll_prepare_write(file, page, from, from + len);
 	if (rc) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return rc;
 }
@@ -497,12 +497,12 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	int rc;
 
 	rc = ll_commit_write(file, page, from, from + copied);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return rc ?: copied;
 }
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index fb0c26ee7ff3..75d4df71cab8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -514,7 +514,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 		/*
 		 * XXX: explicit PAGE_CACHE_SIZE
 		 */
-		bead->lrr_count = cl_index(obj, tot + PAGE_CACHE_SIZE - 1);
+		bead->lrr_count = cl_index(obj, tot + PAGE_SIZE - 1);
 		ll_ra_read_in(file, bead);
 	}
 
@@ -959,7 +959,7 @@ static int vvp_io_prepare_write(const struct lu_env *env,
 		 * We're completely overwriting an existing page, so _don't_
 		 * set it up to date until commit_write
 		 */
-		if (from == 0 && to == PAGE_CACHE_SIZE) {
+		if (from == 0 && to == PAGE_SIZE) {
 			CL_PAGE_HEADER(D_PAGE, env, pg, "full page write\n");
 			POISON_PAGE(page, 0x11);
 		} else
@@ -1022,7 +1022,7 @@ static int vvp_io_commit_write(const struct lu_env *env,
 			set_page_dirty(vmpage);
 			vvp_write_pending(cl2ccc(obj), cp);
 		} else if (result == -EDQUOT) {
-			pgoff_t last_index = i_size_read(inode) >> PAGE_CACHE_SHIFT;
+			pgoff_t last_index = i_size_read(inode) >> PAGE_SHIFT;
 			bool need_clip = true;
 
 			/*
@@ -1040,7 +1040,7 @@ static int vvp_io_commit_write(const struct lu_env *env,
 			 * being.
 			 */
 			if (last_index > pg->cp_index) {
-				to = PAGE_CACHE_SIZE;
+				to = PAGE_SIZE;
 				need_clip = false;
 			} else if (last_index == pg->cp_index) {
 				int size_to = i_size_read(inode) & ~CFS_PAGE_MASK;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 850bae734075..33ca3eb34965 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -57,7 +57,7 @@ static void vvp_page_fini_common(struct ccc_page *cp)
 	struct page *vmpage = cp->cpg_page;
 
 	LASSERT(vmpage);
-	page_cache_release(vmpage);
+	put_page(vmpage);
 }
 
 static void vvp_page_fini(const struct lu_env *env,
@@ -164,12 +164,12 @@ static int vvp_page_unmap(const struct lu_env *env,
 	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 
-	offset = vmpage->index << PAGE_CACHE_SHIFT;
+	offset = vmpage->index << PAGE_SHIFT;
 
 	/*
 	 * XXX is it safe to call this with the page lock held?
 	 */
-	ll_teardown_mmaps(vmpage->mapping, offset, offset + PAGE_CACHE_SIZE);
+	ll_teardown_mmaps(vmpage->mapping, offset, offset + PAGE_SIZE);
 	return 0;
 }
 
@@ -537,7 +537,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
 
 	cpg->cpg_page = vmpage;
-	page_cache_get(vmpage);
+	get_page(vmpage);
 
 	INIT_LIST_HEAD(&cpg->cpg_pending_linkage);
 	if (page->cp_type == CPT_CACHEABLE) {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 0f776cf8a5aa..ce7e8b70dd44 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2129,8 +2129,8 @@ static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc != 0)
 		return rc;
 
-	ncfspgs = ((*request)->rq_bulk->bd_nob_transferred + PAGE_CACHE_SIZE - 1)
-		 >> PAGE_CACHE_SHIFT;
+	ncfspgs = ((*request)->rq_bulk->bd_nob_transferred + PAGE_SIZE - 1)
+		 >> PAGE_SHIFT;
 	nlupgs = (*request)->rq_bulk->bd_nob_transferred >> LU_PAGE_SHIFT;
 	LASSERT(!((*request)->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK));
 	LASSERT(ncfspgs > 0 && ncfspgs <= op_data->op_npages);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 55dd8ef9525b..b91d3ff18b02 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1002,10 +1002,10 @@ restart_bulk:
 
 	/* NB req now owns desc and will free it when it gets freed */
 	for (i = 0; i < op_data->op_npages; i++)
-		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_CACHE_SIZE);
+		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_SIZE);
 
 	mdc_readdir_pack(req, op_data->op_offset,
-			 PAGE_CACHE_SIZE * op_data->op_npages,
+			 PAGE_SIZE * op_data->op_npages,
 			 &op_data->op_fid1);
 
 	ptlrpc_request_set_replen(req);
@@ -1037,7 +1037,7 @@ restart_bulk:
 	if (req->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK) {
 		CERROR("Unexpected # bytes transferred: %d (%ld expected)\n",
 		       req->rq_bulk->bd_nob_transferred,
-		       PAGE_CACHE_SIZE * op_data->op_npages);
+		       PAGE_SIZE * op_data->op_npages);
 		ptlrpc_req_finished(req);
 		return -EPROTO;
 	}
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 65caffe8c42e..830ca10507d4 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1113,7 +1113,7 @@ static int mgc_import_event(struct obd_device *obd,
 }
 
 enum {
-	CONFIG_READ_NRPAGES_INIT = 1 << (20 - PAGE_CACHE_SHIFT),
+	CONFIG_READ_NRPAGES_INIT = 1 << (20 - PAGE_SHIFT),
 	CONFIG_READ_NRPAGES      = 4
 };
 
@@ -1137,19 +1137,19 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	LASSERT(cfg->cfg_instance);
 	LASSERT(cfg->cfg_sb == cfg->cfg_instance);
 
-	inst = kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+	inst = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!inst)
 		return -ENOMEM;
 
-	pos = snprintf(inst, PAGE_CACHE_SIZE, "%p", cfg->cfg_instance);
-	if (pos >= PAGE_CACHE_SIZE) {
+	pos = snprintf(inst, PAGE_SIZE, "%p", cfg->cfg_instance);
+	if (pos >= PAGE_SIZE) {
 		kfree(inst);
 		return -E2BIG;
 	}
 
 	++pos;
 	buf   = inst + pos;
-	bufsz = PAGE_CACHE_SIZE - pos;
+	bufsz = PAGE_SIZE - pos;
 
 	while (datalen > 0) {
 		int   entry_len = sizeof(*entry);
@@ -1181,7 +1181,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		/* Keep this swab for normal mixed endian handling. LU-1644 */
 		if (mne_swab)
 			lustre_swab_mgs_nidtbl_entry(entry);
-		if (entry->mne_length > PAGE_CACHE_SIZE) {
+		if (entry->mne_length > PAGE_SIZE) {
 			CERROR("MNE too large (%u)\n", entry->mne_length);
 			break;
 		}
@@ -1371,7 +1371,7 @@ again:
 	}
 	body->mcb_offset = cfg->cfg_last_idx + 1;
 	body->mcb_type   = cld->cld_type;
-	body->mcb_bits   = PAGE_CACHE_SHIFT;
+	body->mcb_bits   = PAGE_SHIFT;
 	body->mcb_units  = nrpages;
 
 	/* allocate bulk transfer descriptor */
@@ -1383,7 +1383,7 @@ again:
 	}
 
 	for (i = 0; i < nrpages; i++)
-		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_CACHE_SIZE);
+		ptlrpc_prep_bulk_page_pin(desc, pages[i], 0, PAGE_SIZE);
 
 	ptlrpc_request_set_replen(req);
 	rc = ptlrpc_queue_wait(req);
@@ -1411,7 +1411,7 @@ again:
 		goto out;
 	}
 
-	if (ealen > nrpages << PAGE_CACHE_SHIFT) {
+	if (ealen > nrpages << PAGE_SHIFT) {
 		rc = -EINVAL;
 		goto out;
 	}
@@ -1439,7 +1439,7 @@ again:
 
 		ptr = kmap(pages[i]);
 		rc2 = mgc_apply_recover_logs(obd, cld, res->mcr_offset, ptr,
-					     min_t(int, ealen, PAGE_CACHE_SIZE),
+					     min_t(int, ealen, PAGE_SIZE),
 					     mne_swab);
 		kunmap(pages[i]);
 		if (rc2 < 0) {
@@ -1448,7 +1448,7 @@ again:
 			break;
 		}
 
-		ealen -= PAGE_CACHE_SIZE;
+		ealen -= PAGE_SIZE;
 	}
 
 out:
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 231a2f26c693..394580016638 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -1477,7 +1477,7 @@ loff_t cl_offset(const struct cl_object *obj, pgoff_t idx)
 	/*
 	 * XXX for now.
 	 */
-	return (loff_t)idx << PAGE_CACHE_SHIFT;
+	return (loff_t)idx << PAGE_SHIFT;
 }
 EXPORT_SYMBOL(cl_offset);
 
@@ -1489,13 +1489,13 @@ pgoff_t cl_index(const struct cl_object *obj, loff_t offset)
 	/*
 	 * XXX for now.
 	 */
-	return offset >> PAGE_CACHE_SHIFT;
+	return offset >> PAGE_SHIFT;
 }
 EXPORT_SYMBOL(cl_index);
 
 int cl_page_size(const struct cl_object *obj)
 {
-	return 1 << PAGE_CACHE_SHIFT;
+	return 1 << PAGE_SHIFT;
 }
 EXPORT_SYMBOL(cl_page_size);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 1a938e1376f9..c2cf015962dd 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -461,9 +461,9 @@ static int obd_init_checks(void)
 		CWARN("LPD64 wrong length! strlen(%s)=%d != 2\n", buf, len);
 		ret = -EINVAL;
 	}
-	if ((u64val & ~CFS_PAGE_MASK) >= PAGE_CACHE_SIZE) {
+	if ((u64val & ~CFS_PAGE_MASK) >= PAGE_SIZE) {
 		CWARN("mask failed: u64val %llu >= %llu\n", u64val,
-		      (__u64)PAGE_CACHE_SIZE);
+		      (__u64)PAGE_SIZE);
 		ret = -EINVAL;
 	}
 
@@ -509,7 +509,7 @@ static int __init obdclass_init(void)
 	 * For clients with less memory, a larger fraction is needed
 	 * for other purposes (mostly for BGL).
 	 */
-	if (totalram_pages <= 512 << (20 - PAGE_CACHE_SHIFT))
+	if (totalram_pages <= 512 << (20 - PAGE_SHIFT))
 		obd_max_dirty_pages = totalram_pages / 4;
 	else
 		obd_max_dirty_pages = totalram_pages / 2;
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
index 9496c09b2b69..4a2baaff3dc1 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
@@ -71,8 +71,8 @@ void obdo_refresh_inode(struct inode *dst, struct obdo *src, u32 valid)
 	if (valid & OBD_MD_FLBLKSZ && src->o_blksize > (1 << dst->i_blkbits))
 		dst->i_blkbits = ffs(src->o_blksize) - 1;
 
-	if (dst->i_blkbits < PAGE_CACHE_SHIFT)
-		dst->i_blkbits = PAGE_CACHE_SHIFT;
+	if (dst->i_blkbits < PAGE_SHIFT)
+		dst->i_blkbits = PAGE_SHIFT;
 
 	/* allocation of space */
 	if (valid & OBD_MD_FLBLOCKS && src->o_blocks > dst->i_blocks)
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index fd333b9e968c..e6bf414a4444 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -100,7 +100,7 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj, struct attribute *attr,
 				 char *buf)
 {
 	return sprintf(buf, "%ul\n",
-			obd_max_dirty_pages / (1 << (20 - PAGE_CACHE_SHIFT)));
+			obd_max_dirty_pages / (1 << (20 - PAGE_SHIFT)));
 }
 
 static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
@@ -113,14 +113,14 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
 	if (rc)
 		return rc;
 
-	val *= 1 << (20 - PAGE_CACHE_SHIFT); /* convert to pages */
+	val *= 1 << (20 - PAGE_SHIFT); /* convert to pages */
 
 	if (val > ((totalram_pages / 10) * 9)) {
 		/* Somebody wants to assign too much memory to dirty pages */
 		return -EINVAL;
 	}
 
-	if (val < 4 << (20 - PAGE_CACHE_SHIFT)) {
+	if (val < 4 << (20 - PAGE_SHIFT)) {
 		/* Less than 4 Mb for dirty cache is also bad */
 		return -EINVAL;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 65a4746c89ca..978568ada8e9 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -840,8 +840,8 @@ static int lu_htable_order(void)
 
 #if BITS_PER_LONG == 32
 	/* limit hashtable size for lowmem systems to low RAM */
-	if (cache_size > 1 << (30 - PAGE_CACHE_SHIFT))
-		cache_size = 1 << (30 - PAGE_CACHE_SHIFT) * 3 / 4;
+	if (cache_size > 1 << (30 - PAGE_SHIFT))
+		cache_size = 1 << (30 - PAGE_SHIFT) * 3 / 4;
 #endif
 
 	/* clear off unreasonable cache setting. */
@@ -853,7 +853,7 @@ static int lu_htable_order(void)
 		lu_cache_percent = LU_CACHE_PERCENT_DEFAULT;
 	}
 	cache_size = cache_size / 100 * lu_cache_percent *
-		(PAGE_CACHE_SIZE / 1024);
+		(PAGE_SIZE / 1024);
 
 	for (bits = 1; (1 << bits) < cache_size; ++bits) {
 		;
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 64ffe243f870..1e83669c204d 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -278,7 +278,7 @@ static void echo_page_fini(const struct lu_env *env,
 	struct page *vmpage      = ep->ep_vmpage;
 
 	atomic_dec(&eco->eo_npages);
-	page_cache_release(vmpage);
+	put_page(vmpage);
 }
 
 static int echo_page_prep(const struct lu_env *env,
@@ -373,7 +373,7 @@ static int echo_page_init(const struct lu_env *env, struct cl_object *obj,
 	struct echo_object *eco = cl2echo_obj(obj);
 
 	ep->ep_vmpage = vmpage;
-	page_cache_get(vmpage);
+	get_page(vmpage);
 	mutex_init(&ep->ep_lock);
 	cl_page_slice_add(page, &ep->ep_cl, obj, &echo_page_ops);
 	atomic_inc(&eco->eo_npages);
@@ -1138,7 +1138,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 	LASSERT(rc == 0);
 
 	rc = cl_echo_enqueue0(env, eco, offset,
-			      offset + npages * PAGE_CACHE_SIZE - 1,
+			      offset + npages * PAGE_SIZE - 1,
 			      rw == READ ? LCK_PR : LCK_PW, &lh.cookie,
 			      CEF_NEVER);
 	if (rc < 0)
@@ -1311,11 +1311,11 @@ echo_client_page_debug_setup(struct page *page, int rw, u64 id,
 	int      delta;
 
 	/* no partial pages on the client */
-	LASSERT(count == PAGE_CACHE_SIZE);
+	LASSERT(count == PAGE_SIZE);
 
 	addr = kmap(page);
 
-	for (delta = 0; delta < PAGE_CACHE_SIZE; delta += OBD_ECHO_BLOCK_SIZE) {
+	for (delta = 0; delta < PAGE_SIZE; delta += OBD_ECHO_BLOCK_SIZE) {
 		if (rw == OBD_BRW_WRITE) {
 			stripe_off = offset + delta;
 			stripe_id = id;
@@ -1341,11 +1341,11 @@ static int echo_client_page_debug_check(struct page *page, u64 id,
 	int     rc2;
 
 	/* no partial pages on the client */
-	LASSERT(count == PAGE_CACHE_SIZE);
+	LASSERT(count == PAGE_SIZE);
 
 	addr = kmap(page);
 
-	for (rc = delta = 0; delta < PAGE_CACHE_SIZE; delta += OBD_ECHO_BLOCK_SIZE) {
+	for (rc = delta = 0; delta < PAGE_SIZE; delta += OBD_ECHO_BLOCK_SIZE) {
 		stripe_off = offset + delta;
 		stripe_id = id;
 
@@ -1391,7 +1391,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 		return -EINVAL;
 
 	/* XXX think again with misaligned I/O */
-	npages = count >> PAGE_CACHE_SHIFT;
+	npages = count >> PAGE_SHIFT;
 
 	if (rw == OBD_BRW_WRITE)
 		brw_flags = OBD_BRW_ASYNC;
@@ -1408,7 +1408,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 
 	for (i = 0, pgp = pga, off = offset;
 	     i < npages;
-	     i++, pgp++, off += PAGE_CACHE_SIZE) {
+	     i++, pgp++, off += PAGE_SIZE) {
 
 		LASSERT(!pgp->pg);      /* for cleanup */
 
@@ -1418,7 +1418,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 			goto out;
 
 		pages[i] = pgp->pg;
-		pgp->count = PAGE_CACHE_SIZE;
+		pgp->count = PAGE_SIZE;
 		pgp->off = off;
 		pgp->flag = brw_flags;
 
@@ -1473,8 +1473,8 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	if (count <= 0 || (count & (~CFS_PAGE_MASK)) != 0)
 		return -EINVAL;
 
-	npages = batch >> PAGE_CACHE_SHIFT;
-	tot_pages = count >> PAGE_CACHE_SHIFT;
+	npages = batch >> PAGE_SHIFT;
+	tot_pages = count >> PAGE_SHIFT;
 
 	lnb = kcalloc(npages, sizeof(struct niobuf_local), GFP_NOFS);
 	rnb = kcalloc(npages, sizeof(struct niobuf_remote), GFP_NOFS);
@@ -1497,9 +1497,9 @@ static int echo_client_prep_commit(const struct lu_env *env,
 		if (tot_pages < npages)
 			npages = tot_pages;
 
-		for (i = 0; i < npages; i++, off += PAGE_CACHE_SIZE) {
+		for (i = 0; i < npages; i++, off += PAGE_SIZE) {
 			rnb[i].offset = off;
-			rnb[i].len = PAGE_CACHE_SIZE;
+			rnb[i].len = PAGE_SIZE;
 			rnb[i].flags = brw_flags;
 		}
 
@@ -1878,7 +1878,7 @@ static int __init obdecho_init(void)
 {
 	LCONSOLE_INFO("Echo OBD driver; http://www.lustre.org/\n");
 
-	LASSERT(PAGE_CACHE_SIZE % OBD_ECHO_BLOCK_SIZE == 0);
+	LASSERT(PAGE_SIZE % OBD_ECHO_BLOCK_SIZE == 0);
 
 	return echo_client_init();
 }
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 57c43c506ef2..a3358c39b2f1 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -162,15 +162,15 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	pages_number *= 1 << (20 - PAGE_CACHE_SHIFT); /* MB -> pages */
+	pages_number *= 1 << (20 - PAGE_SHIFT); /* MB -> pages */
 
 	if (pages_number <= 0 ||
-	    pages_number > OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_CACHE_SHIFT) ||
+	    pages_number > OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_SHIFT) ||
 	    pages_number > totalram_pages / 4) /* 1/4 of RAM */
 		return -ERANGE;
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
-	cli->cl_dirty_max = (u32)(pages_number << PAGE_CACHE_SHIFT);
+	cli->cl_dirty_max = (u32)(pages_number << PAGE_SHIFT);
 	osc_wake_cache_waiters(cli);
 	client_obd_list_unlock(&cli->cl_loi_list_lock);
 
@@ -182,7 +182,7 @@ static int osc_cached_mb_seq_show(struct seq_file *m, void *v)
 {
 	struct obd_device *dev = m->private;
 	struct client_obd *cli = &dev->u.cli;
-	int shift = 20 - PAGE_CACHE_SHIFT;
+	int shift = 20 - PAGE_SHIFT;
 
 	seq_printf(m,
 		   "used_mb: %d\n"
@@ -211,7 +211,7 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 		return -EFAULT;
 	kernbuf[count] = 0;
 
-	mult = 1 << (20 - PAGE_CACHE_SHIFT);
+	mult = 1 << (20 - PAGE_SHIFT);
 	buffer += lprocfs_find_named_value(kernbuf, "used_mb:", &count) -
 		  kernbuf;
 	rc = lprocfs_write_frac_helper(buffer, count, &pages_number, mult);
@@ -569,12 +569,12 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 
 	/* if the max_pages is specified in bytes, convert to pages */
 	if (val >= ONE_MB_BRW_SIZE)
-		val >>= PAGE_CACHE_SHIFT;
+		val >>= PAGE_SHIFT;
 
-	chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_CACHE_SHIFT)) - 1);
+	chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_SHIFT)) - 1);
 	/* max_pages_per_rpc must be chunk aligned */
 	val = (val + ~chunk_mask) & chunk_mask;
-	if (val == 0 || val > ocd->ocd_brw_size >> PAGE_CACHE_SHIFT) {
+	if (val == 0 || val > ocd->ocd_brw_size >> PAGE_SHIFT) {
 		return -ERANGE;
 	}
 	client_obd_list_lock(&cli->cl_loi_list_lock);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 63363111380c..4e0a357ed43d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -544,7 +544,7 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 		return -ERANGE;
 
 	LASSERT(cur->oe_osclock == victim->oe_osclock);
-	ppc_bits = osc_cli(obj)->cl_chunkbits - PAGE_CACHE_SHIFT;
+	ppc_bits = osc_cli(obj)->cl_chunkbits - PAGE_SHIFT;
 	chunk_start = cur->oe_start >> ppc_bits;
 	chunk_end = cur->oe_end >> ppc_bits;
 	if (chunk_start != (victim->oe_end >> ppc_bits) + 1 &&
@@ -647,8 +647,8 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	lock = cl_lock_at_pgoff(env, osc2cl(obj), index, NULL, 1, 0);
 	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
 
-	LASSERT(cli->cl_chunkbits >= PAGE_CACHE_SHIFT);
-	ppc_bits = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
+	LASSERT(cli->cl_chunkbits >= PAGE_SHIFT);
+	ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 	chunk_mask = ~((1 << ppc_bits) - 1);
 	chunksize = 1 << cli->cl_chunkbits;
 	chunk = index >> ppc_bits;
@@ -871,8 +871,8 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 
 	if (!sent) {
 		lost_grant = ext->oe_grants;
-	} else if (blocksize < PAGE_CACHE_SIZE &&
-		   last_count != PAGE_CACHE_SIZE) {
+	} else if (blocksize < PAGE_SIZE &&
+		   last_count != PAGE_SIZE) {
 		/* For short writes we shouldn't count parts of pages that
 		 * span a whole chunk on the OST side, or our accounting goes
 		 * wrong.  Should match the code in filter_grant_check.
@@ -884,7 +884,7 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 		if (end)
 			count += blocksize - end;
 
-		lost_grant = PAGE_CACHE_SIZE - count;
+		lost_grant = PAGE_SIZE - count;
 	}
 	if (ext->oe_grants > 0)
 		osc_free_grant(cli, nr_pages, lost_grant);
@@ -967,7 +967,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	struct osc_async_page *oap;
 	struct osc_async_page *tmp;
 	int pages_in_chunk = 0;
-	int ppc_bits = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
+	int ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 	__u64 trunc_chunk = trunc_index >> ppc_bits;
 	int grants = 0;
 	int nr_pages = 0;
@@ -1125,7 +1125,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	if (!(last->oap_async_flags & ASYNC_COUNT_STABLE)) {
 		last->oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
 		LASSERT(last->oap_count > 0);
-		LASSERT(last->oap_page_off + last->oap_count <= PAGE_CACHE_SIZE);
+		LASSERT(last->oap_page_off + last->oap_count <= PAGE_SIZE);
 		last->oap_async_flags |= ASYNC_COUNT_STABLE;
 	}
 
@@ -1134,7 +1134,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	 */
 	list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
 		if (!(oap->oap_async_flags & ASYNC_COUNT_STABLE)) {
-			oap->oap_count = PAGE_CACHE_SIZE - oap->oap_page_off;
+			oap->oap_count = PAGE_SIZE - oap->oap_page_off;
 			oap->oap_async_flags |= ASYNC_COUNT_STABLE;
 		}
 	}
@@ -1158,7 +1158,7 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index, int *grants)
 	struct osc_object *obj = ext->oe_obj;
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *next;
-	int ppc_bits = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
+	int ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 	pgoff_t chunk = index >> ppc_bits;
 	pgoff_t end_chunk;
 	pgoff_t end_index;
@@ -1293,9 +1293,9 @@ static int osc_refresh_count(const struct lu_env *env,
 		return 0;
 	else if (cl_offset(obj, page->cp_index + 1) > kms)
 		/* catch sub-page write at end of file */
-		return kms % PAGE_CACHE_SIZE;
+		return kms % PAGE_SIZE;
 	else
-		return PAGE_CACHE_SIZE;
+		return PAGE_SIZE;
 }
 
 static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
@@ -1376,10 +1376,10 @@ static void osc_consume_write_grant(struct client_obd *cli,
 	assert_spin_locked(&cli->cl_loi_list_lock.lock);
 	LASSERT(!(pga->flag & OBD_BRW_FROM_GRANT));
 	atomic_inc(&obd_dirty_pages);
-	cli->cl_dirty += PAGE_CACHE_SIZE;
+	cli->cl_dirty += PAGE_SIZE;
 	pga->flag |= OBD_BRW_FROM_GRANT;
 	CDEBUG(D_CACHE, "using %lu grant credits for brw %p page %p\n",
-	       PAGE_CACHE_SIZE, pga, pga->pg);
+	       PAGE_SIZE, pga, pga->pg);
 	osc_update_next_shrink(cli);
 }
 
@@ -1396,11 +1396,11 @@ static void osc_release_write_grant(struct client_obd *cli,
 
 	pga->flag &= ~OBD_BRW_FROM_GRANT;
 	atomic_dec(&obd_dirty_pages);
-	cli->cl_dirty -= PAGE_CACHE_SIZE;
+	cli->cl_dirty -= PAGE_SIZE;
 	if (pga->flag & OBD_BRW_NOCACHE) {
 		pga->flag &= ~OBD_BRW_NOCACHE;
 		atomic_dec(&obd_dirty_transit_pages);
-		cli->cl_dirty_transit -= PAGE_CACHE_SIZE;
+		cli->cl_dirty_transit -= PAGE_SIZE;
 	}
 }
 
@@ -1469,7 +1469,7 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
 	atomic_sub(nr_pages, &obd_dirty_pages);
-	cli->cl_dirty -= nr_pages << PAGE_CACHE_SHIFT;
+	cli->cl_dirty -= nr_pages << PAGE_SHIFT;
 	cli->cl_lost_grant += lost_grant;
 	if (cli->cl_avail_grant < grant && cli->cl_lost_grant >= grant) {
 		/* borrow some grant from truncate to avoid the case that
@@ -1512,11 +1512,11 @@ static int osc_enter_cache_try(struct client_obd *cli,
 	if (rc < 0)
 		return 0;
 
-	if (cli->cl_dirty + PAGE_CACHE_SIZE <= cli->cl_dirty_max &&
+	if (cli->cl_dirty + PAGE_SIZE <= cli->cl_dirty_max &&
 	    atomic_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
 		osc_consume_write_grant(cli, &oap->oap_brw_page);
 		if (transient) {
-			cli->cl_dirty_transit += PAGE_CACHE_SIZE;
+			cli->cl_dirty_transit += PAGE_SIZE;
 			atomic_inc(&obd_dirty_transit_pages);
 			oap->oap_brw_flags |= OBD_BRW_NOCACHE;
 		}
@@ -1562,7 +1562,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	 * of queued writes and create a discontiguous rpc stream
 	 */
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_NO_GRANT) ||
-	    cli->cl_dirty_max < PAGE_CACHE_SIZE     ||
+	    cli->cl_dirty_max < PAGE_SIZE     ||
 	    cli->cl_ar.ar_force_sync || loi->loi_ar.ar_force_sync) {
 		rc = -EDQUOT;
 		goto out;
@@ -1632,7 +1632,7 @@ void osc_wake_cache_waiters(struct client_obd *cli)
 
 		ocw->ocw_rc = -EDQUOT;
 		/* we can't dirty more */
-		if ((cli->cl_dirty + PAGE_CACHE_SIZE > cli->cl_dirty_max) ||
+		if ((cli->cl_dirty + PAGE_SIZE > cli->cl_dirty_max) ||
 		    (atomic_read(&obd_dirty_pages) + 1 >
 		     obd_max_dirty_pages)) {
 			CDEBUG(D_CACHE, "no dirty room: dirty: %ld osc max %ld, sys max %d\n",
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index d720b1a1c18c..ce9ddd515f64 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -410,7 +410,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	int result;
 
 	opg->ops_from = 0;
-	opg->ops_to = PAGE_CACHE_SIZE;
+	opg->ops_to = PAGE_SIZE;
 
 	result = osc_prep_async_page(osc, opg, vmpage,
 				     cl_offset(obj, page->cp_index));
@@ -487,9 +487,9 @@ static atomic_t osc_lru_waiters = ATOMIC_INIT(0);
 /* LRU pages are freed in batch mode. OSC should at least free this
  * number of pages to avoid running out of LRU budget, and..
  */
-static const int lru_shrink_min = 2 << (20 - PAGE_CACHE_SHIFT);  /* 2M */
+static const int lru_shrink_min = 2 << (20 - PAGE_SHIFT);  /* 2M */
 /* free this number at most otherwise it will take too long time to finish. */
-static const int lru_shrink_max = 32 << (20 - PAGE_CACHE_SHIFT); /* 32M */
+static const int lru_shrink_max = 32 << (20 - PAGE_SHIFT); /* 32M */
 
 /* Check if we can free LRU slots from this OSC. If there exists LRU waiters,
  * we should free slots aggressively. In this way, slots are freed in a steady
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 74805f1ae888..30526ebcad04 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -826,7 +826,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		oa->o_undirty = 0;
 	} else {
 		long max_in_flight = (cli->cl_max_pages_per_rpc <<
-				      PAGE_CACHE_SHIFT)*
+				      PAGE_SHIFT)*
 				     (cli->cl_max_rpcs_in_flight + 1);
 		oa->o_undirty = max(cli->cl_dirty_max, max_in_flight);
 	}
@@ -909,11 +909,11 @@ static void osc_shrink_grant_local(struct client_obd *cli, struct obdo *oa)
 static int osc_shrink_grant(struct client_obd *cli)
 {
 	__u64 target_bytes = (cli->cl_max_rpcs_in_flight + 1) *
-			     (cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT);
+			     (cli->cl_max_pages_per_rpc << PAGE_SHIFT);
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
 	if (cli->cl_avail_grant <= target_bytes)
-		target_bytes = cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
+		target_bytes = cli->cl_max_pages_per_rpc << PAGE_SHIFT;
 	client_obd_list_unlock(&cli->cl_loi_list_lock);
 
 	return osc_shrink_grant_to_target(cli, target_bytes);
@@ -929,8 +929,8 @@ int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
 	 * We don't want to shrink below a single RPC, as that will negatively
 	 * impact block allocation and long-term performance.
 	 */
-	if (target_bytes < cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT)
-		target_bytes = cli->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
+	if (target_bytes < cli->cl_max_pages_per_rpc << PAGE_SHIFT)
+		target_bytes = cli->cl_max_pages_per_rpc << PAGE_SHIFT;
 
 	if (target_bytes >= cli->cl_avail_grant) {
 		client_obd_list_unlock(&cli->cl_loi_list_lock);
@@ -978,7 +978,7 @@ static int osc_should_shrink_grant(struct client_obd *client)
 		 * cli_brw_size(obd->u.cli.cl_import->imp_obd->obd_self_export)
 		 * Keep comment here so that it can be found by searching.
 		 */
-		int brw_size = client->cl_max_pages_per_rpc << PAGE_CACHE_SHIFT;
+		int brw_size = client->cl_max_pages_per_rpc << PAGE_SHIFT;
 
 		if (client->cl_import->imp_state == LUSTRE_IMP_FULL &&
 		    client->cl_avail_grant > brw_size)
@@ -1052,7 +1052,7 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	}
 
 	/* determine the appropriate chunk size used by osc_extent. */
-	cli->cl_chunkbits = max_t(int, PAGE_CACHE_SHIFT, ocd->ocd_blocksize);
+	cli->cl_chunkbits = max_t(int, PAGE_SHIFT, ocd->ocd_blocksize);
 	client_obd_list_unlock(&cli->cl_loi_list_lock);
 
 	CDEBUG(D_CACHE, "%s, setting cl_avail_grant: %ld cl_lost_grant: %ld chunk bits: %d\n",
@@ -1317,9 +1317,9 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		LASSERT(pg->count > 0);
 		/* make sure there is no gap in the middle of page array */
 		LASSERTF(page_count == 1 ||
-			 (ergo(i == 0, poff + pg->count == PAGE_CACHE_SIZE) &&
+			 (ergo(i == 0, poff + pg->count == PAGE_SIZE) &&
 			  ergo(i > 0 && i < page_count - 1,
-			       poff == 0 && pg->count == PAGE_CACHE_SIZE)   &&
+			       poff == 0 && pg->count == PAGE_SIZE)   &&
 			  ergo(i == page_count - 1, poff == 0)),
 			 "i: %d/%d pg: %p off: %llu, count: %u\n",
 			 i, page_count, pg, pg->off, pg->count);
@@ -1877,7 +1877,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 						oap->oap_count;
 			else
 				LASSERT(oap->oap_page_off + oap->oap_count ==
-					PAGE_CACHE_SIZE);
+					PAGE_SIZE);
 		}
 	}
 
@@ -1993,7 +1993,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		tmp->oap_request = ptlrpc_request_addref(req);
 
 	client_obd_list_lock(&cli->cl_loi_list_lock);
-	starting_offset >>= PAGE_CACHE_SHIFT;
+	starting_offset >>= PAGE_SHIFT;
 	if (cmd == OBD_BRW_READ) {
 		cli->cl_r_in_flight++;
 		lprocfs_oh_tally_log2(&cli->cl_read_page_hist, page_count);
@@ -2790,12 +2790,12 @@ out:
 						CFS_PAGE_MASK;
 
 		if (OBD_OBJECT_EOF - fm_key->fiemap.fm_length <=
-		    fm_key->fiemap.fm_start + PAGE_CACHE_SIZE - 1)
+		    fm_key->fiemap.fm_start + PAGE_SIZE - 1)
 			policy.l_extent.end = OBD_OBJECT_EOF;
 		else
 			policy.l_extent.end = (fm_key->fiemap.fm_start +
 				fm_key->fiemap.fm_length +
-				PAGE_CACHE_SIZE - 1) & CFS_PAGE_MASK;
+				PAGE_SIZE - 1) & CFS_PAGE_MASK;
 
 		ostid_build_res_name(&fm_key->oa.o_oi, &res_id);
 		mode = ldlm_lock_match(exp->exp_obd->obd_namespace,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 1b7673eec4d7..cf3ac8eee9ee 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -174,12 +174,12 @@ void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
 	LASSERT(page);
 	LASSERT(pageoffset >= 0);
 	LASSERT(len > 0);
-	LASSERT(pageoffset + len <= PAGE_CACHE_SIZE);
+	LASSERT(pageoffset + len <= PAGE_SIZE);
 
 	desc->bd_nob += len;
 
 	if (pin)
-		page_cache_get(page);
+		get_page(page);
 
 	ptlrpc_add_bulk_page(desc, page, pageoffset, len);
 }
@@ -206,7 +206,7 @@ void __ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc, int unpin)
 
 	if (unpin) {
 		for (i = 0; i < desc->bd_iov_count; i++)
-			page_cache_release(desc->bd_iov[i].kiov_page);
+			put_page(desc->bd_iov[i].kiov_page);
 	}
 
 	kfree(desc);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index b4eddf291269..cd94fed0ffdf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1092,7 +1092,7 @@ finish:
 
 		if (ocd->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
 			cli->cl_max_pages_per_rpc =
-				min(ocd->ocd_brw_size >> PAGE_CACHE_SHIFT,
+				min(ocd->ocd_brw_size >> PAGE_SHIFT,
 				    cli->cl_max_pages_per_rpc);
 		else if (imp->imp_connect_op == MDS_CONNECT ||
 			 imp->imp_connect_op == MGS_CONNECT)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index cee04efb6fb5..c95a91ce26c9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -308,7 +308,7 @@ ptlrpc_lprocfs_req_history_max_seq_write(struct file *file,
 	 * hose a kernel by allowing the request history to grow too
 	 * far.
 	 */
-	bufpages = (svc->srv_buf_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	bufpages = (svc->srv_buf_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (val > totalram_pages / (2 * bufpages))
 		return -ERANGE;
 
@@ -1226,7 +1226,7 @@ int lprocfs_wr_import(struct file *file, const char __user *buffer,
 	const char prefix[] = "connection=";
 	const int prefix_len = sizeof(prefix) - 1;
 
-	if (count > PAGE_CACHE_SIZE - 1 || count <= prefix_len)
+	if (count > PAGE_SIZE - 1 || count <= prefix_len)
 		return -EINVAL;
 
 	kbuf = kzalloc(count + 1, GFP_NOFS);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 5f27d9c2e4ef..30d9a164e52d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -195,7 +195,7 @@ int ptlrpc_resend(struct obd_import *imp)
 	}
 
 	list_for_each_entry_safe(req, next, &imp->imp_sending_list, rq_list) {
-		LASSERTF((long)req > PAGE_CACHE_SIZE && req != LP_POISON,
+		LASSERTF((long)req > PAGE_SIZE && req != LP_POISON,
 			 "req %p bad\n", req);
 		LASSERTF(req->rq_type != LI_POISON, "req %p freed\n", req);
 		if (!ptlrpc_no_resend(req))
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 72d5b9bf5b29..d3872b8c9a6e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -58,7 +58,7 @@
  * bulk encryption page pools	   *
  ****************************************/
 
-#define POINTERS_PER_PAGE	(PAGE_CACHE_SIZE / sizeof(void *))
+#define POINTERS_PER_PAGE	(PAGE_SIZE / sizeof(void *))
 #define PAGES_PER_POOL		(POINTERS_PER_PAGE)
 
 #define IDLE_IDX_MAX	 (100)
diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index 8cfce105c7ee..e21ca2bd6839 100644
--- a/drivers/usb/gadget/function/f_fs.c
+++ b/drivers/usb/gadget/function/f_fs.c
@@ -1147,8 +1147,8 @@ static int ffs_sb_fill(struct super_block *sb, void *_data, int silent)
 	ffs->sb              = sb;
 	data->ffs_data       = NULL;
 	sb->s_fs_info        = ffs;
-	sb->s_blocksize      = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize      = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic          = FUNCTIONFS_MAGIC;
 	sb->s_op             = &ffs_sb_operations;
 	sb->s_time_gran      = 1;
diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index 5cdaf0150a4e..e64479f882a5 100644
--- a/drivers/usb/gadget/legacy/inode.c
+++ b/drivers/usb/gadget/legacy/inode.c
@@ -1954,8 +1954,8 @@ gadgetfs_fill_super (struct super_block *sb, void *opts, int silent)
 		return -ENODEV;
 
 	/* superblock */
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = GADGETFS_MAGIC;
 	sb->s_op = &gadget_fs_operations;
 	sb->s_time_gran = 1;
diff --git a/drivers/usb/storage/scsiglue.c b/drivers/usb/storage/scsiglue.c
index dba51362d2e2..90901861bfc0 100644
--- a/drivers/usb/storage/scsiglue.c
+++ b/drivers/usb/storage/scsiglue.c
@@ -123,7 +123,7 @@ static int slave_configure(struct scsi_device *sdev)
 		unsigned int max_sectors = 64;
 
 		if (us->fflags & US_FL_MAX_SECTORS_MIN)
-			max_sectors = PAGE_CACHE_SIZE >> 9;
+			max_sectors = PAGE_SIZE >> 9;
 		if (queue_max_hw_sectors(sdev->request_queue) > max_sectors)
 			blk_queue_max_hw_sectors(sdev->request_queue,
 					      max_sectors);
diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
index 71a923e53f93..3b1ca4411073 100644
--- a/drivers/video/fbdev/pvr2fb.c
+++ b/drivers/video/fbdev/pvr2fb.c
@@ -735,7 +735,7 @@ out:
 
 out_unmap:
 	for (i = 0; i < nr_pages; i++)
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 
 	kfree(pages);
 
diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index e9e04376c52c..ac9225e86bf3 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -153,7 +153,7 @@ static void v9fs_invalidate_page(struct page *page, unsigned int offset,
 	 * If called with zero offset, we should release
 	 * the private state assocated with the page
 	 */
-	if (offset == 0 && length == PAGE_CACHE_SIZE)
+	if (offset == 0 && length == PAGE_SIZE)
 		v9fs_fscache_invalidate_page(page);
 }
 
@@ -166,10 +166,10 @@ static int v9fs_vfs_writepage_locked(struct page *page)
 	struct bio_vec bvec;
 	int err, len;
 
-	if (page->index == size >> PAGE_CACHE_SHIFT)
-		len = size & ~PAGE_CACHE_MASK;
+	if (page->index == size >> PAGE_SHIFT)
+		len = size & ~PAGE_MASK;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 
 	bvec.bv_page = page;
 	bvec.bv_offset = 0;
@@ -271,7 +271,7 @@ static int v9fs_write_begin(struct file *filp, struct address_space *mapping,
 	int retval = 0;
 	struct page *page;
 	struct v9fs_inode *v9inode;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct inode *inode = mapping->host;
 
 
@@ -288,11 +288,11 @@ start:
 	if (PageUptodate(page))
 		goto out;
 
-	if (len == PAGE_CACHE_SIZE)
+	if (len == PAGE_SIZE)
 		goto out;
 
 	retval = v9fs_fid_readpage(v9inode->writeback_fid, page);
-	page_cache_release(page);
+	put_page(page);
 	if (!retval)
 		goto start;
 out:
@@ -313,7 +313,7 @@ static int v9fs_write_end(struct file *filp, struct address_space *mapping,
 		/*
 		 * zero out the rest of the area
 		 */
-		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+		unsigned from = pos & (PAGE_SIZE - 1);
 
 		zero_user(page, from + copied, len - copied);
 		flush_dcache_page(page);
@@ -331,7 +331,7 @@ static int v9fs_write_end(struct file *filp, struct address_space *mapping,
 	}
 	set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index eadc894faea2..b84c291ba1eb 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -421,8 +421,8 @@ v9fs_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 		struct inode *inode = file_inode(file);
 		loff_t i_size;
 		unsigned long pg_start, pg_end;
-		pg_start = origin >> PAGE_CACHE_SHIFT;
-		pg_end = (origin + retval - 1) >> PAGE_CACHE_SHIFT;
+		pg_start = origin >> PAGE_SHIFT;
+		pg_end = (origin + retval - 1) >> PAGE_SHIFT;
 		if (inode->i_mapping && inode->i_mapping->nrpages)
 			invalidate_inode_pages2_range(inode->i_mapping,
 						      pg_start, pg_end);
diff --git a/fs/9p/vfs_super.c b/fs/9p/vfs_super.c
index bf495cedec26..de3ed8629196 100644
--- a/fs/9p/vfs_super.c
+++ b/fs/9p/vfs_super.c
@@ -87,7 +87,7 @@ v9fs_fill_super(struct super_block *sb, struct v9fs_session_info *v9ses,
 		sb->s_op = &v9fs_super_ops;
 	sb->s_bdi = &v9ses->bdi;
 	if (v9ses->cache)
-		sb->s_bdi->ra_pages = (VM_MAX_READAHEAD * 1024)/PAGE_CACHE_SIZE;
+		sb->s_bdi->ra_pages = (VM_MAX_READAHEAD * 1024)/PAGE_SIZE;
 
 	sb->s_flags |= MS_ACTIVE | MS_DIRSYNC | MS_NOATIME;
 	if (!v9ses->cache)
diff --git a/fs/affs/file.c b/fs/affs/file.c
index 22fc7c802d69..0cde550050e8 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -510,9 +510,9 @@ affs_do_readpage_ofs(struct page *page, unsigned to)
 
 	pr_debug("%s(%lu, %ld, 0, %d)\n", __func__, inode->i_ino,
 		 page->index, to);
-	BUG_ON(to > PAGE_CACHE_SIZE);
+	BUG_ON(to > PAGE_SIZE);
 	bsize = AFFS_SB(sb)->s_data_blksize;
-	tmp = page->index << PAGE_CACHE_SHIFT;
+	tmp = page->index << PAGE_SHIFT;
 	bidx = tmp / bsize;
 	boff = tmp % bsize;
 
@@ -613,10 +613,10 @@ affs_readpage_ofs(struct file *file, struct page *page)
 	int err;
 
 	pr_debug("%s(%lu, %ld)\n", __func__, inode->i_ino, page->index);
-	to = PAGE_CACHE_SIZE;
-	if (((page->index + 1) << PAGE_CACHE_SHIFT) > inode->i_size) {
-		to = inode->i_size & ~PAGE_CACHE_MASK;
-		memset(page_address(page) + to, 0, PAGE_CACHE_SIZE - to);
+	to = PAGE_SIZE;
+	if (((page->index + 1) << PAGE_SHIFT) > inode->i_size) {
+		to = inode->i_size & ~PAGE_MASK;
+		memset(page_address(page) + to, 0, PAGE_SIZE - to);
 	}
 
 	err = affs_do_readpage_ofs(page, to);
@@ -646,7 +646,7 @@ static int affs_write_begin_ofs(struct file *file, struct address_space *mapping
 			return err;
 	}
 
-	index = pos >> PAGE_CACHE_SHIFT;
+	index = pos >> PAGE_SHIFT;
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
@@ -656,10 +656,10 @@ static int affs_write_begin_ofs(struct file *file, struct address_space *mapping
 		return 0;
 
 	/* XXX: inefficient but safe in the face of short writes */
-	err = affs_do_readpage_ofs(page, PAGE_CACHE_SIZE);
+	err = affs_do_readpage_ofs(page, PAGE_SIZE);
 	if (err) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return err;
 }
@@ -677,7 +677,7 @@ static int affs_write_end_ofs(struct file *file, struct address_space *mapping,
 	u32 tmp;
 	int written;
 
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = pos & (PAGE_SIZE - 1);
 	to = pos + len;
 	/*
 	 * XXX: not sure if this can handle short copies (len < copied), but
@@ -692,7 +692,7 @@ static int affs_write_end_ofs(struct file *file, struct address_space *mapping,
 
 	bh = NULL;
 	written = 0;
-	tmp = (page->index << PAGE_CACHE_SHIFT) + from;
+	tmp = (page->index << PAGE_SHIFT) + from;
 	bidx = tmp / bsize;
 	boff = tmp % bsize;
 	if (boff) {
@@ -788,13 +788,13 @@ static int affs_write_end_ofs(struct file *file, struct address_space *mapping,
 
 done:
 	affs_brelse(bh);
-	tmp = (page->index << PAGE_CACHE_SHIFT) + from;
+	tmp = (page->index << PAGE_SHIFT) + from;
 	if (tmp > inode->i_size)
 		inode->i_size = AFFS_I(inode)->mmu_private = tmp;
 
 err_first_bh:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return written;
 
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index e10e17788f06..5fda2bc53cd7 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -181,7 +181,7 @@ error:
 static inline void afs_dir_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
diff --git a/fs/afs/file.c b/fs/afs/file.c
index 999bc3caec92..6344aee4ac4b 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -164,7 +164,7 @@ int afs_page_filler(void *data, struct page *page)
 		_debug("cache said ENOBUFS");
 	default:
 	go_on:
-		offset = page->index << PAGE_CACHE_SHIFT;
+		offset = page->index << PAGE_SHIFT;
 		len = min_t(size_t, i_size_read(inode) - offset, PAGE_SIZE);
 
 		/* read the contents of the file from the server into the
@@ -319,7 +319,7 @@ static void afs_invalidatepage(struct page *page, unsigned int offset,
 	BUG_ON(!PageLocked(page));
 
 	/* we clean up only if the entire page is being invalidated */
-	if (offset == 0 && length == PAGE_CACHE_SIZE) {
+	if (offset == 0 && length == PAGE_SIZE) {
 #ifdef CONFIG_AFS_FSCACHE
 		if (PageFsCache(page)) {
 			struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index ccd0b212e82a..81dd075356b9 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -93,7 +93,7 @@ int afs_mntpt_check_symlink(struct afs_vnode *vnode, struct key *key)
 
 	kunmap(page);
 out_free:
-	page_cache_release(page);
+	put_page(page);
 out:
 	_leave(" = %d", ret);
 	return ret;
@@ -189,7 +189,7 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 		buf = kmap_atomic(page);
 		memcpy(devname, buf, size);
 		kunmap_atomic(buf);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 
@@ -211,7 +211,7 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 	return mnt;
 
 error:
-	page_cache_release(page);
+	put_page(page);
 error_no_page:
 	free_page((unsigned long) options);
 error_no_options:
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 81afefe7d8a6..fbdb022b75a2 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -315,8 +315,8 @@ static int afs_fill_super(struct super_block *sb,
 	_enter("");
 
 	/* fill in the superblock */
-	sb->s_blocksize		= PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits	= PAGE_CACHE_SHIFT;
+	sb->s_blocksize		= PAGE_SIZE;
+	sb->s_blocksize_bits	= PAGE_SHIFT;
 	sb->s_magic		= AFS_FS_MAGIC;
 	sb->s_op		= &afs_super_ops;
 	sb->s_bdi		= &as->volume->bdi;
diff --git a/fs/afs/write.c b/fs/afs/write.c
index dfef94f70667..65de439bdc4f 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -93,10 +93,10 @@ static int afs_fill_page(struct afs_vnode *vnode, struct key *key,
 	_enter(",,%llu", (unsigned long long)pos);
 
 	i_size = i_size_read(&vnode->vfs_inode);
-	if (pos + PAGE_CACHE_SIZE > i_size)
+	if (pos + PAGE_SIZE > i_size)
 		len = i_size - pos;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 
 	ret = afs_vnode_fetch_data(vnode, key, pos, len, page);
 	if (ret < 0) {
@@ -123,9 +123,9 @@ int afs_write_begin(struct file *file, struct address_space *mapping,
 	struct afs_vnode *vnode = AFS_FS_I(file_inode(file));
 	struct page *page;
 	struct key *key = file->private_data;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + len;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	int ret;
 
 	_enter("{%x:%u},{%lx},%u,%u",
@@ -151,8 +151,8 @@ int afs_write_begin(struct file *file, struct address_space *mapping,
 	*pagep = page;
 	/* page won't leak in error case: it eventually gets cleaned off LRU */
 
-	if (!PageUptodate(page) && len != PAGE_CACHE_SIZE) {
-		ret = afs_fill_page(vnode, key, index << PAGE_CACHE_SHIFT, page);
+	if (!PageUptodate(page) && len != PAGE_SIZE) {
+		ret = afs_fill_page(vnode, key, index << PAGE_SHIFT, page);
 		if (ret < 0) {
 			kfree(candidate);
 			_leave(" = %d [prep]", ret);
@@ -266,7 +266,7 @@ int afs_write_end(struct file *file, struct address_space *mapping,
 	if (PageDirty(page))
 		_debug("dirtied");
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
@@ -480,7 +480,7 @@ static int afs_writepages_region(struct address_space *mapping,
 
 		if (page->index > end) {
 			*_next = index;
-			page_cache_release(page);
+			put_page(page);
 			_leave(" = 0 [%lx]", *_next);
 			return 0;
 		}
@@ -494,7 +494,7 @@ static int afs_writepages_region(struct address_space *mapping,
 
 		if (page->mapping != mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -515,7 +515,7 @@ static int afs_writepages_region(struct address_space *mapping,
 
 		ret = afs_write_back_from_locked_page(wb, page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (ret < 0) {
 			_leave(" = %d", ret);
 			return ret;
@@ -551,13 +551,13 @@ int afs_writepages(struct address_space *mapping,
 						    &next);
 		mapping->writeback_index = next;
 	} else if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX) {
-		end = (pgoff_t)(LLONG_MAX >> PAGE_CACHE_SHIFT);
+		end = (pgoff_t)(LLONG_MAX >> PAGE_SHIFT);
 		ret = afs_writepages_region(mapping, wbc, 0, end, &next);
 		if (wbc->nr_to_write > 0)
 			mapping->writeback_index = next;
 	} else {
-		start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		start = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		ret = afs_writepages_region(mapping, wbc, start, end, &next);
 	}
 
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 7d914c67a9d0..81381cc0dd17 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -2292,7 +2292,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 				void *kaddr = kmap(page);
 				stop = !dump_emit(cprm, kaddr, PAGE_SIZE);
 				kunmap(page);
-				page_cache_release(page);
+				put_page(page);
 			} else
 				stop = !dump_skip(cprm, PAGE_SIZE);
 			if (stop)
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index b1adb92e69de..083ea2bc60ab 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1533,7 +1533,7 @@ static bool elf_fdpic_dump_segments(struct coredump_params *cprm)
 				void *kaddr = kmap(page);
 				res = dump_emit(cprm, kaddr, PAGE_SIZE);
 				kunmap(page);
-				page_cache_release(page);
+				put_page(page);
 			} else {
 				res = dump_skip(cprm, PAGE_SIZE);
 			}
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 3172c4e2f502..20a2c02b77c4 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -331,7 +331,7 @@ static int blkdev_write_end(struct file *file, struct address_space *mapping,
 	ret = block_write_end(file, mapping, pos, len, copied, page, fsdata);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return ret;
 }
@@ -1149,7 +1149,7 @@ void bd_set_size(struct block_device *bdev, loff_t size)
 	inode_lock(bdev->bd_inode);
 	i_size_write(bdev->bd_inode, size);
 	inode_unlock(bdev->bd_inode);
-	while (bsize < PAGE_CACHE_SIZE) {
+	while (bsize < PAGE_SIZE) {
 		if (size & bsize)
 			break;
 		bsize <<= 1;
diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index 861d472564c1..748df9040e41 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -755,7 +755,7 @@ static int btrfsic_process_superblock(struct btrfsic_state *state,
 			BUG_ON(NULL == l);
 
 			ret = btrfsic_read_block(state, &tmp_next_block_ctx);
-			if (ret < (int)PAGE_CACHE_SIZE) {
+			if (ret < (int)PAGE_SIZE) {
 				printk(KERN_INFO
 				       "btrfsic: read @logical %llu failed!\n",
 				       tmp_next_block_ctx.start);
@@ -1229,15 +1229,15 @@ static void btrfsic_read_from_block_data(
 	size_t offset_in_page;
 	char *kaddr;
 	char *dst = (char *)dstv;
-	size_t start_offset = block_ctx->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + offset) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = block_ctx->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + offset) >> PAGE_SHIFT;
 
 	WARN_ON(offset + len > block_ctx->len);
-	offset_in_page = (start_offset + offset) & (PAGE_CACHE_SIZE - 1);
+	offset_in_page = (start_offset + offset) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
-		cur = min(len, ((size_t)PAGE_CACHE_SIZE - offset_in_page));
-		BUG_ON(i >= DIV_ROUND_UP(block_ctx->len, PAGE_CACHE_SIZE));
+		cur = min(len, ((size_t)PAGE_SIZE - offset_in_page));
+		BUG_ON(i >= DIV_ROUND_UP(block_ctx->len, PAGE_SIZE));
 		kaddr = block_ctx->datav[i];
 		memcpy(dst, kaddr + offset_in_page, cur);
 
@@ -1603,8 +1603,8 @@ static void btrfsic_release_block_ctx(struct btrfsic_block_data_ctx *block_ctx)
 
 		BUG_ON(!block_ctx->datav);
 		BUG_ON(!block_ctx->pagev);
-		num_pages = (block_ctx->len + (u64)PAGE_CACHE_SIZE - 1) >>
-			    PAGE_CACHE_SHIFT;
+		num_pages = (block_ctx->len + (u64)PAGE_SIZE - 1) >>
+			    PAGE_SHIFT;
 		while (num_pages > 0) {
 			num_pages--;
 			if (block_ctx->datav[num_pages]) {
@@ -1635,15 +1635,15 @@ static int btrfsic_read_block(struct btrfsic_state *state,
 	BUG_ON(block_ctx->datav);
 	BUG_ON(block_ctx->pagev);
 	BUG_ON(block_ctx->mem_to_free);
-	if (block_ctx->dev_bytenr & ((u64)PAGE_CACHE_SIZE - 1)) {
+	if (block_ctx->dev_bytenr & ((u64)PAGE_SIZE - 1)) {
 		printk(KERN_INFO
 		       "btrfsic: read_block() with unaligned bytenr %llu\n",
 		       block_ctx->dev_bytenr);
 		return -1;
 	}
 
-	num_pages = (block_ctx->len + (u64)PAGE_CACHE_SIZE - 1) >>
-		    PAGE_CACHE_SHIFT;
+	num_pages = (block_ctx->len + (u64)PAGE_SIZE - 1) >>
+		    PAGE_SHIFT;
 	block_ctx->mem_to_free = kzalloc((sizeof(*block_ctx->datav) +
 					  sizeof(*block_ctx->pagev)) *
 					 num_pages, GFP_NOFS);
@@ -1674,8 +1674,8 @@ static int btrfsic_read_block(struct btrfsic_state *state,
 
 		for (j = i; j < num_pages; j++) {
 			ret = bio_add_page(bio, block_ctx->pagev[j],
-					   PAGE_CACHE_SIZE, 0);
-			if (PAGE_CACHE_SIZE != ret)
+					   PAGE_SIZE, 0);
+			if (PAGE_SIZE != ret)
 				break;
 		}
 		if (j == i) {
@@ -1691,7 +1691,7 @@ static int btrfsic_read_block(struct btrfsic_state *state,
 			return -1;
 		}
 		bio_put(bio);
-		dev_bytenr += (j - i) * PAGE_CACHE_SIZE;
+		dev_bytenr += (j - i) * PAGE_SIZE;
 		i = j;
 	}
 	for (i = 0; i < num_pages; i++) {
@@ -1767,9 +1767,9 @@ static int btrfsic_test_for_metadata(struct btrfsic_state *state,
 	u32 crc = ~(u32)0;
 	unsigned int i;
 
-	if (num_pages * PAGE_CACHE_SIZE < state->metablock_size)
+	if (num_pages * PAGE_SIZE < state->metablock_size)
 		return 1; /* not metadata */
-	num_pages = state->metablock_size >> PAGE_CACHE_SHIFT;
+	num_pages = state->metablock_size >> PAGE_SHIFT;
 	h = (struct btrfs_header *)datav[0];
 
 	if (memcmp(h->fsid, state->root->fs_info->fsid, BTRFS_UUID_SIZE))
@@ -1777,8 +1777,8 @@ static int btrfsic_test_for_metadata(struct btrfsic_state *state,
 
 	for (i = 0; i < num_pages; i++) {
 		u8 *data = i ? datav[i] : (datav[i] + BTRFS_CSUM_SIZE);
-		size_t sublen = i ? PAGE_CACHE_SIZE :
-				    (PAGE_CACHE_SIZE - BTRFS_CSUM_SIZE);
+		size_t sublen = i ? PAGE_SIZE :
+				    (PAGE_SIZE - BTRFS_CSUM_SIZE);
 
 		crc = btrfs_crc32c(crc, data, sublen);
 	}
@@ -1824,14 +1824,14 @@ again:
 		if (block->is_superblock) {
 			bytenr = btrfs_super_bytenr((struct btrfs_super_block *)
 						    mapped_datav[0]);
-			if (num_pages * PAGE_CACHE_SIZE <
+			if (num_pages * PAGE_SIZE <
 			    BTRFS_SUPER_INFO_SIZE) {
 				printk(KERN_INFO
 				       "btrfsic: cannot work with too short bios!\n");
 				return;
 			}
 			is_metadata = 1;
-			BUG_ON(BTRFS_SUPER_INFO_SIZE & (PAGE_CACHE_SIZE - 1));
+			BUG_ON(BTRFS_SUPER_INFO_SIZE & (PAGE_SIZE - 1));
 			processed_len = BTRFS_SUPER_INFO_SIZE;
 			if (state->print_mask &
 			    BTRFSIC_PRINT_MASK_TREE_BEFORE_SB_WRITE) {
@@ -1842,7 +1842,7 @@ again:
 		}
 		if (is_metadata) {
 			if (!block->is_superblock) {
-				if (num_pages * PAGE_CACHE_SIZE <
+				if (num_pages * PAGE_SIZE <
 				    state->metablock_size) {
 					printk(KERN_INFO
 					       "btrfsic: cannot work with too short bios!\n");
@@ -1878,7 +1878,7 @@ again:
 			}
 			block->logical_bytenr = bytenr;
 		} else {
-			if (num_pages * PAGE_CACHE_SIZE <
+			if (num_pages * PAGE_SIZE <
 			    state->datablock_size) {
 				printk(KERN_INFO
 				       "btrfsic: cannot work with too short bios!\n");
@@ -2011,7 +2011,7 @@ again:
 			block->logical_bytenr = bytenr;
 			block->is_metadata = 1;
 			if (block->is_superblock) {
-				BUG_ON(PAGE_CACHE_SIZE !=
+				BUG_ON(PAGE_SIZE !=
 				       BTRFS_SUPER_INFO_SIZE);
 				ret = btrfsic_process_written_superblock(
 						state,
@@ -2170,8 +2170,8 @@ again:
 continue_loop:
 	BUG_ON(!processed_len);
 	dev_bytenr += processed_len;
-	mapped_datav += processed_len >> PAGE_CACHE_SHIFT;
-	num_pages -= processed_len >> PAGE_CACHE_SHIFT;
+	mapped_datav += processed_len >> PAGE_SHIFT;
+	num_pages -= processed_len >> PAGE_SHIFT;
 	goto again;
 }
 
@@ -2952,7 +2952,7 @@ static void __btrfsic_submit_bio(int rw, struct bio *bio)
 			goto leave;
 		cur_bytenr = dev_bytenr;
 		for (i = 0; i < bio->bi_vcnt; i++) {
-			BUG_ON(bio->bi_io_vec[i].bv_len != PAGE_CACHE_SIZE);
+			BUG_ON(bio->bi_io_vec[i].bv_len != PAGE_SIZE);
 			mapped_datav[i] = kmap(bio->bi_io_vec[i].bv_page);
 			if (!mapped_datav[i]) {
 				while (i > 0) {
@@ -3035,16 +3035,16 @@ int btrfsic_mount(struct btrfs_root *root,
 	struct list_head *dev_head = &fs_devices->devices;
 	struct btrfs_device *device;
 
-	if (root->nodesize & ((u64)PAGE_CACHE_SIZE - 1)) {
+	if (root->nodesize & ((u64)PAGE_SIZE - 1)) {
 		printk(KERN_INFO
 		       "btrfsic: cannot handle nodesize %d not being a multiple of PAGE_CACHE_SIZE %ld!\n",
-		       root->nodesize, PAGE_CACHE_SIZE);
+		       root->nodesize, PAGE_SIZE);
 		return -1;
 	}
-	if (root->sectorsize & ((u64)PAGE_CACHE_SIZE - 1)) {
+	if (root->sectorsize & ((u64)PAGE_SIZE - 1)) {
 		printk(KERN_INFO
 		       "btrfsic: cannot handle sectorsize %d not being a multiple of PAGE_CACHE_SIZE %ld!\n",
-		       root->sectorsize, PAGE_CACHE_SIZE);
+		       root->sectorsize, PAGE_SIZE);
 		return -1;
 	}
 	state = kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 3346cd8f9910..ff61a41ac90b 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -119,7 +119,7 @@ static int check_compressed_csum(struct inode *inode,
 		csum = ~(u32)0;
 
 		kaddr = kmap_atomic(page);
-		csum = btrfs_csum_data(kaddr, csum, PAGE_CACHE_SIZE);
+		csum = btrfs_csum_data(kaddr, csum, PAGE_SIZE);
 		btrfs_csum_final(csum, (char *)&csum);
 		kunmap_atomic(kaddr);
 
@@ -190,7 +190,7 @@ csum_failed:
 	for (index = 0; index < cb->nr_pages; index++) {
 		page = cb->compressed_pages[index];
 		page->mapping = NULL;
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	/* do io completion on the original bio */
@@ -224,8 +224,8 @@ out:
 static noinline void end_compressed_writeback(struct inode *inode,
 					      const struct compressed_bio *cb)
 {
-	unsigned long index = cb->start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = (cb->start + cb->len - 1) >> PAGE_CACHE_SHIFT;
+	unsigned long index = cb->start >> PAGE_SHIFT;
+	unsigned long end_index = (cb->start + cb->len - 1) >> PAGE_SHIFT;
 	struct page *pages[16];
 	unsigned long nr_pages = end_index - index + 1;
 	int i;
@@ -247,7 +247,7 @@ static noinline void end_compressed_writeback(struct inode *inode,
 			if (cb->errors)
 				SetPageError(pages[i]);
 			end_page_writeback(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 		nr_pages -= ret;
 		index += ret;
@@ -304,7 +304,7 @@ static void end_compressed_bio_write(struct bio *bio)
 	for (index = 0; index < cb->nr_pages; index++) {
 		page = cb->compressed_pages[index];
 		page->mapping = NULL;
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	/* finally free the cb struct */
@@ -341,7 +341,7 @@ int btrfs_submit_compressed_write(struct inode *inode, u64 start,
 	int ret;
 	int skip_sum = BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM;
 
-	WARN_ON(start & ((u64)PAGE_CACHE_SIZE - 1));
+	WARN_ON(start & ((u64)PAGE_SIZE - 1));
 	cb = kmalloc(compressed_bio_size(root, compressed_len), GFP_NOFS);
 	if (!cb)
 		return -ENOMEM;
@@ -374,14 +374,14 @@ int btrfs_submit_compressed_write(struct inode *inode, u64 start,
 		page->mapping = inode->i_mapping;
 		if (bio->bi_iter.bi_size)
 			ret = io_tree->ops->merge_bio_hook(WRITE, page, 0,
-							   PAGE_CACHE_SIZE,
+							   PAGE_SIZE,
 							   bio, 0);
 		else
 			ret = 0;
 
 		page->mapping = NULL;
-		if (ret || bio_add_page(bio, page, PAGE_CACHE_SIZE, 0) <
-		    PAGE_CACHE_SIZE) {
+		if (ret || bio_add_page(bio, page, PAGE_SIZE, 0) <
+		    PAGE_SIZE) {
 			bio_get(bio);
 
 			/*
@@ -410,15 +410,15 @@ int btrfs_submit_compressed_write(struct inode *inode, u64 start,
 			BUG_ON(!bio);
 			bio->bi_private = cb;
 			bio->bi_end_io = end_compressed_bio_write;
-			bio_add_page(bio, page, PAGE_CACHE_SIZE, 0);
+			bio_add_page(bio, page, PAGE_SIZE, 0);
 		}
-		if (bytes_left < PAGE_CACHE_SIZE) {
+		if (bytes_left < PAGE_SIZE) {
 			btrfs_info(BTRFS_I(inode)->root->fs_info,
 					"bytes left %lu compress len %lu nr %lu",
 			       bytes_left, cb->compressed_len, cb->nr_pages);
 		}
-		bytes_left -= PAGE_CACHE_SIZE;
-		first_byte += PAGE_CACHE_SIZE;
+		bytes_left -= PAGE_SIZE;
+		first_byte += PAGE_SIZE;
 		cond_resched();
 	}
 	bio_get(bio);
@@ -457,17 +457,17 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 	int misses = 0;
 
 	page = cb->orig_bio->bi_io_vec[cb->orig_bio->bi_vcnt - 1].bv_page;
-	last_offset = (page_offset(page) + PAGE_CACHE_SIZE);
+	last_offset = (page_offset(page) + PAGE_SIZE);
 	em_tree = &BTRFS_I(inode)->extent_tree;
 	tree = &BTRFS_I(inode)->io_tree;
 
 	if (isize == 0)
 		return 0;
 
-	end_index = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
+	end_index = (i_size_read(inode) - 1) >> PAGE_SHIFT;
 
 	while (last_offset < compressed_end) {
-		pg_index = last_offset >> PAGE_CACHE_SHIFT;
+		pg_index = last_offset >> PAGE_SHIFT;
 
 		if (pg_index > end_index)
 			break;
@@ -488,11 +488,11 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 			break;
 
 		if (add_to_page_cache_lru(page, mapping, pg_index, GFP_NOFS)) {
-			page_cache_release(page);
+			put_page(page);
 			goto next;
 		}
 
-		end = last_offset + PAGE_CACHE_SIZE - 1;
+		end = last_offset + PAGE_SIZE - 1;
 		/*
 		 * at this point, we have a locked page in the page cache
 		 * for these bytes in the file.  But, we have to make
@@ -502,27 +502,27 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		lock_extent(tree, last_offset, end);
 		read_lock(&em_tree->lock);
 		em = lookup_extent_mapping(em_tree, last_offset,
-					   PAGE_CACHE_SIZE);
+					   PAGE_SIZE);
 		read_unlock(&em_tree->lock);
 
 		if (!em || last_offset < em->start ||
-		    (last_offset + PAGE_CACHE_SIZE > extent_map_end(em)) ||
+		    (last_offset + PAGE_SIZE > extent_map_end(em)) ||
 		    (em->block_start >> 9) != cb->orig_bio->bi_iter.bi_sector) {
 			free_extent_map(em);
 			unlock_extent(tree, last_offset, end);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			break;
 		}
 		free_extent_map(em);
 
 		if (page->index == end_index) {
 			char *userpage;
-			size_t zero_offset = isize & (PAGE_CACHE_SIZE - 1);
+			size_t zero_offset = isize & (PAGE_SIZE - 1);
 
 			if (zero_offset) {
 				int zeros;
-				zeros = PAGE_CACHE_SIZE - zero_offset;
+				zeros = PAGE_SIZE - zero_offset;
 				userpage = kmap_atomic(page);
 				memset(userpage + zero_offset, 0, zeros);
 				flush_dcache_page(page);
@@ -531,19 +531,19 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		}
 
 		ret = bio_add_page(cb->orig_bio, page,
-				   PAGE_CACHE_SIZE, 0);
+				   PAGE_SIZE, 0);
 
-		if (ret == PAGE_CACHE_SIZE) {
+		if (ret == PAGE_SIZE) {
 			nr_pages++;
-			page_cache_release(page);
+			put_page(page);
 		} else {
 			unlock_extent(tree, last_offset, end);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			break;
 		}
 next:
-		last_offset += PAGE_CACHE_SIZE;
+		last_offset += PAGE_SIZE;
 	}
 	return 0;
 }
@@ -567,7 +567,7 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	struct extent_map_tree *em_tree;
 	struct compressed_bio *cb;
 	struct btrfs_root *root = BTRFS_I(inode)->root;
-	unsigned long uncompressed_len = bio->bi_vcnt * PAGE_CACHE_SIZE;
+	unsigned long uncompressed_len = bio->bi_vcnt * PAGE_SIZE;
 	unsigned long compressed_len;
 	unsigned long nr_pages;
 	unsigned long pg_index;
@@ -589,7 +589,7 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	read_lock(&em_tree->lock);
 	em = lookup_extent_mapping(em_tree,
 				   page_offset(bio->bi_io_vec->bv_page),
-				   PAGE_CACHE_SIZE);
+				   PAGE_SIZE);
 	read_unlock(&em_tree->lock);
 	if (!em)
 		return -EIO;
@@ -617,7 +617,7 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	cb->compress_type = extent_compress_type(bio_flags);
 	cb->orig_bio = bio;
 
-	nr_pages = DIV_ROUND_UP(compressed_len, PAGE_CACHE_SIZE);
+	nr_pages = DIV_ROUND_UP(compressed_len, PAGE_SIZE);
 	cb->compressed_pages = kcalloc(nr_pages, sizeof(struct page *),
 				       GFP_NOFS);
 	if (!cb->compressed_pages)
@@ -640,7 +640,7 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	add_ra_bio_pages(inode, em_start + em_len, cb);
 
 	/* include any pages we added in add_ra-bio_pages */
-	uncompressed_len = bio->bi_vcnt * PAGE_CACHE_SIZE;
+	uncompressed_len = bio->bi_vcnt * PAGE_SIZE;
 	cb->len = uncompressed_len;
 
 	comp_bio = compressed_bio_alloc(bdev, cur_disk_byte, GFP_NOFS);
@@ -653,18 +653,18 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	for (pg_index = 0; pg_index < nr_pages; pg_index++) {
 		page = cb->compressed_pages[pg_index];
 		page->mapping = inode->i_mapping;
-		page->index = em_start >> PAGE_CACHE_SHIFT;
+		page->index = em_start >> PAGE_SHIFT;
 
 		if (comp_bio->bi_iter.bi_size)
 			ret = tree->ops->merge_bio_hook(READ, page, 0,
-							PAGE_CACHE_SIZE,
+							PAGE_SIZE,
 							comp_bio, 0);
 		else
 			ret = 0;
 
 		page->mapping = NULL;
-		if (ret || bio_add_page(comp_bio, page, PAGE_CACHE_SIZE, 0) <
-		    PAGE_CACHE_SIZE) {
+		if (ret || bio_add_page(comp_bio, page, PAGE_SIZE, 0) <
+		    PAGE_SIZE) {
 			bio_get(comp_bio);
 
 			ret = btrfs_bio_wq_end_io(root->fs_info, comp_bio,
@@ -702,9 +702,9 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 			comp_bio->bi_private = cb;
 			comp_bio->bi_end_io = end_compressed_bio_read;
 
-			bio_add_page(comp_bio, page, PAGE_CACHE_SIZE, 0);
+			bio_add_page(comp_bio, page, PAGE_SIZE, 0);
 		}
-		cur_disk_byte += PAGE_CACHE_SIZE;
+		cur_disk_byte += PAGE_SIZE;
 	}
 	bio_get(comp_bio);
 
@@ -1013,8 +1013,8 @@ int btrfs_decompress_buf2page(char *buf, unsigned long buf_start,
 
 	/* copy bytes from the working buffer into the pages */
 	while (working_bytes > 0) {
-		bytes = min(PAGE_CACHE_SIZE - *pg_offset,
-			    PAGE_CACHE_SIZE - buf_offset);
+		bytes = min(PAGE_SIZE - *pg_offset,
+			    PAGE_SIZE - buf_offset);
 		bytes = min(bytes, working_bytes);
 		kaddr = kmap_atomic(page_out);
 		memcpy(kaddr + *pg_offset, buf + buf_offset, bytes);
@@ -1027,7 +1027,7 @@ int btrfs_decompress_buf2page(char *buf, unsigned long buf_start,
 		current_buf_start += bytes;
 
 		/* check if we need to pick another page */
-		if (*pg_offset == PAGE_CACHE_SIZE) {
+		if (*pg_offset == PAGE_SIZE) {
 			(*pg_index)++;
 			if (*pg_index >= vcnt)
 				return 0;
diff --git a/fs/btrfs/ctree.c b/fs/btrfs/ctree.c
index 769e0ff1b4ce..1ef1c40d70f4 100644
--- a/fs/btrfs/ctree.c
+++ b/fs/btrfs/ctree.c
@@ -523,7 +523,7 @@ alloc_tree_mod_elem(struct extent_buffer *eb, int slot,
 	if (!tm)
 		return NULL;
 
-	tm->index = eb->start >> PAGE_CACHE_SHIFT;
+	tm->index = eb->start >> PAGE_SHIFT;
 	if (op != MOD_LOG_KEY_ADD) {
 		btrfs_node_key(eb, &tm->key, slot);
 		tm->blockptr = btrfs_node_blockptr(eb, slot);
@@ -588,7 +588,7 @@ tree_mod_log_insert_move(struct btrfs_fs_info *fs_info,
 		goto free_tms;
 	}
 
-	tm->index = eb->start >> PAGE_CACHE_SHIFT;
+	tm->index = eb->start >> PAGE_SHIFT;
 	tm->slot = src_slot;
 	tm->move.dst_slot = dst_slot;
 	tm->move.nr_items = nr_items;
@@ -699,7 +699,7 @@ tree_mod_log_insert_root(struct btrfs_fs_info *fs_info,
 		goto free_tms;
 	}
 
-	tm->index = new_root->start >> PAGE_CACHE_SHIFT;
+	tm->index = new_root->start >> PAGE_SHIFT;
 	tm->old_root.logical = old_root->start;
 	tm->old_root.level = btrfs_header_level(old_root);
 	tm->generation = btrfs_header_generation(old_root);
@@ -739,7 +739,7 @@ __tree_mod_log_search(struct btrfs_fs_info *fs_info, u64 start, u64 min_seq,
 	struct rb_node *node;
 	struct tree_mod_elem *cur = NULL;
 	struct tree_mod_elem *found = NULL;
-	u64 index = start >> PAGE_CACHE_SHIFT;
+	u64 index = start >> PAGE_SHIFT;
 
 	tree_mod_log_read_lock(fs_info);
 	tm_root = &fs_info->tree_mod_log;
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 5699bbc23feb..20ce055700f5 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1055,7 +1055,7 @@ static void btree_invalidatepage(struct page *page, unsigned int offset,
 			   (unsigned long long)page_offset(page));
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
@@ -1756,7 +1756,7 @@ static int setup_bdi(struct btrfs_fs_info *info, struct backing_dev_info *bdi)
 	if (err)
 		return err;
 
-	bdi->ra_pages = VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE;
+	bdi->ra_pages = VM_MAX_READAHEAD * 1024 / PAGE_SIZE;
 	bdi->congested_fn	= btrfs_congested_fn;
 	bdi->congested_data	= info;
 	bdi->capabilities |= BDI_CAP_CGROUP_WRITEBACK;
@@ -2534,7 +2534,7 @@ int open_ctree(struct super_block *sb,
 		err = ret;
 		goto fail_bdi;
 	}
-	fs_info->dirty_metadata_batch = PAGE_CACHE_SIZE *
+	fs_info->dirty_metadata_batch = PAGE_SIZE *
 					(1 + ilog2(nr_cpu_ids));
 
 	ret = percpu_counter_init(&fs_info->delalloc_bytes, 0, GFP_KERNEL);
@@ -2778,7 +2778,7 @@ int open_ctree(struct super_block *sb,
 	 * flag our filesystem as having big metadata blocks if
 	 * they are bigger than the page size
 	 */
-	if (btrfs_super_nodesize(disk_super) > PAGE_CACHE_SIZE) {
+	if (btrfs_super_nodesize(disk_super) > PAGE_SIZE) {
 		if (!(features & BTRFS_FEATURE_INCOMPAT_BIG_METADATA))
 			printk(KERN_INFO "BTRFS: flagging fs with big metadata feature\n");
 		features |= BTRFS_FEATURE_INCOMPAT_BIG_METADATA;
@@ -2828,7 +2828,7 @@ int open_ctree(struct super_block *sb,
 
 	fs_info->bdi.ra_pages *= btrfs_super_num_devices(disk_super);
 	fs_info->bdi.ra_pages = max(fs_info->bdi.ra_pages,
-				    SZ_4M / PAGE_CACHE_SIZE);
+				    SZ_4M / PAGE_SIZE);
 
 	tree_root->nodesize = nodesize;
 	tree_root->sectorsize = sectorsize;
@@ -4060,9 +4060,9 @@ static int btrfs_check_super_valid(struct btrfs_fs_info *fs_info,
 		ret = -EINVAL;
 	}
 	/* Only PAGE SIZE is supported yet */
-	if (sectorsize != PAGE_CACHE_SIZE) {
+	if (sectorsize != PAGE_SIZE) {
 		printk(KERN_ERR "BTRFS: sectorsize %llu not supported yet, only support %lu\n",
-				sectorsize, PAGE_CACHE_SIZE);
+				sectorsize, PAGE_SIZE);
 		ret = -EINVAL;
 	}
 	if (!is_power_of_2(nodesize) || nodesize < sectorsize ||
diff --git a/fs/btrfs/extent-tree.c b/fs/btrfs/extent-tree.c
index e2287c7c10be..e50a13ea4dd8 100644
--- a/fs/btrfs/extent-tree.c
+++ b/fs/btrfs/extent-tree.c
@@ -3452,7 +3452,7 @@ again:
 		num_pages = 1;
 
 	num_pages *= 16;
-	num_pages *= PAGE_CACHE_SIZE;
+	num_pages *= PAGE_SIZE;
 
 	ret = btrfs_check_data_free_space(inode, 0, num_pages);
 	if (ret)
@@ -4639,7 +4639,7 @@ static void shrink_delalloc(struct btrfs_root *root, u64 to_reclaim, u64 orig,
 	loops = 0;
 	while (delalloc_bytes && loops < 3) {
 		max_reclaim = min(delalloc_bytes, to_reclaim);
-		nr_pages = max_reclaim >> PAGE_CACHE_SHIFT;
+		nr_pages = max_reclaim >> PAGE_SHIFT;
 		btrfs_writeback_inodes_sb_nr(root, nr_pages, items);
 		/*
 		 * We need to wait for the async pages to actually start before
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 392592dc7010..ce50203e5855 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -1365,23 +1365,23 @@ int try_lock_extent(struct extent_io_tree *tree, u64 start, u64 end)
 
 void extent_range_clear_dirty_for_io(struct inode *inode, u64 start, u64 end)
 {
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	struct page *page;
 
 	while (index <= end_index) {
 		page = find_get_page(inode->i_mapping, index);
 		BUG_ON(!page); /* Pages should be in the extent_io_tree */
 		clear_page_dirty_for_io(page);
-		page_cache_release(page);
+		put_page(page);
 		index++;
 	}
 }
 
 void extent_range_redirty_for_io(struct inode *inode, u64 start, u64 end)
 {
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	struct page *page;
 
 	while (index <= end_index) {
@@ -1389,7 +1389,7 @@ void extent_range_redirty_for_io(struct inode *inode, u64 start, u64 end)
 		BUG_ON(!page); /* Pages should be in the extent_io_tree */
 		__set_page_dirty_nobuffers(page);
 		account_page_redirty(page);
-		page_cache_release(page);
+		put_page(page);
 		index++;
 	}
 }
@@ -1399,15 +1399,15 @@ void extent_range_redirty_for_io(struct inode *inode, u64 start, u64 end)
  */
 static void set_range_writeback(struct extent_io_tree *tree, u64 start, u64 end)
 {
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	struct page *page;
 
 	while (index <= end_index) {
 		page = find_get_page(tree->mapping, index);
 		BUG_ON(!page); /* Pages should be in the extent_io_tree */
 		set_page_writeback(page);
-		page_cache_release(page);
+		put_page(page);
 		index++;
 	}
 }
@@ -1558,8 +1558,8 @@ static noinline void __unlock_for_delalloc(struct inode *inode,
 {
 	int ret;
 	struct page *pages[16];
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	unsigned long nr_pages = end_index - index + 1;
 	int i;
 
@@ -1573,7 +1573,7 @@ static noinline void __unlock_for_delalloc(struct inode *inode,
 		for (i = 0; i < ret; i++) {
 			if (pages[i] != locked_page)
 				unlock_page(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 		nr_pages -= ret;
 		index += ret;
@@ -1586,9 +1586,9 @@ static noinline int lock_delalloc_pages(struct inode *inode,
 					u64 delalloc_start,
 					u64 delalloc_end)
 {
-	unsigned long index = delalloc_start >> PAGE_CACHE_SHIFT;
+	unsigned long index = delalloc_start >> PAGE_SHIFT;
 	unsigned long start_index = index;
-	unsigned long end_index = delalloc_end >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = delalloc_end >> PAGE_SHIFT;
 	unsigned long pages_locked = 0;
 	struct page *pages[16];
 	unsigned long nrpages;
@@ -1621,11 +1621,11 @@ static noinline int lock_delalloc_pages(struct inode *inode,
 				    pages[i]->mapping != inode->i_mapping) {
 					ret = -EAGAIN;
 					unlock_page(pages[i]);
-					page_cache_release(pages[i]);
+					put_page(pages[i]);
 					goto done;
 				}
 			}
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 			pages_locked++;
 		}
 		nrpages -= ret;
@@ -1638,7 +1638,7 @@ done:
 		__unlock_for_delalloc(inode, locked_page,
 			      delalloc_start,
 			      ((u64)(start_index + pages_locked - 1)) <<
-			      PAGE_CACHE_SHIFT);
+			      PAGE_SHIFT);
 	}
 	return ret;
 }
@@ -1698,7 +1698,7 @@ again:
 		free_extent_state(cached_state);
 		cached_state = NULL;
 		if (!loops) {
-			max_bytes = PAGE_CACHE_SIZE;
+			max_bytes = PAGE_SIZE;
 			loops = 1;
 			goto again;
 		} else {
@@ -1737,8 +1737,8 @@ void extent_clear_unlock_delalloc(struct inode *inode, u64 start, u64 end,
 	struct extent_io_tree *tree = &BTRFS_I(inode)->io_tree;
 	int ret;
 	struct page *pages[16];
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	unsigned long nr_pages = end_index - index + 1;
 	int i;
 
@@ -1759,7 +1759,7 @@ void extent_clear_unlock_delalloc(struct inode *inode, u64 start, u64 end,
 				SetPagePrivate2(pages[i]);
 
 			if (pages[i] == locked_page) {
-				page_cache_release(pages[i]);
+				put_page(pages[i]);
 				continue;
 			}
 			if (page_ops & PAGE_CLEAR_DIRTY)
@@ -1772,7 +1772,7 @@ void extent_clear_unlock_delalloc(struct inode *inode, u64 start, u64 end,
 				end_page_writeback(pages[i]);
 			if (page_ops & PAGE_UNLOCK)
 				unlock_page(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 		nr_pages -= ret;
 		index += ret;
@@ -1961,7 +1961,7 @@ int test_range_bit(struct extent_io_tree *tree, u64 start, u64 end,
 static void check_page_uptodate(struct extent_io_tree *tree, struct page *page)
 {
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 	if (test_range_bit(tree, start, end, EXTENT_UPTODATE, 1, NULL))
 		SetPageUptodate(page);
 }
@@ -2071,11 +2071,11 @@ int repair_eb_io_failure(struct btrfs_root *root, struct extent_buffer *eb,
 		struct page *p = eb->pages[i];
 
 		ret = repair_io_failure(root->fs_info->btree_inode, start,
-					PAGE_CACHE_SIZE, start, p,
+					PAGE_SIZE, start, p,
 					start - page_offset(p), mirror_num);
 		if (ret)
 			break;
-		start += PAGE_CACHE_SIZE;
+		start += PAGE_SIZE;
 	}
 
 	return ret;
@@ -2471,8 +2471,8 @@ static void end_bio_extent_writepage(struct bio *bio)
 		 * advance bv_offset and adjust bv_len to compensate.
 		 * Print a warning for nonzero offsets, and an error
 		 * if they don't add up to a full page.  */
-		if (bvec->bv_offset || bvec->bv_len != PAGE_CACHE_SIZE) {
-			if (bvec->bv_offset + bvec->bv_len != PAGE_CACHE_SIZE)
+		if (bvec->bv_offset || bvec->bv_len != PAGE_SIZE) {
+			if (bvec->bv_offset + bvec->bv_len != PAGE_SIZE)
 				btrfs_err(BTRFS_I(page->mapping->host)->root->fs_info,
 				   "partial page write in btrfs with offset %u and length %u",
 					bvec->bv_offset, bvec->bv_len);
@@ -2546,8 +2546,8 @@ static void end_bio_extent_readpage(struct bio *bio)
 		 * advance bv_offset and adjust bv_len to compensate.
 		 * Print a warning for nonzero offsets, and an error
 		 * if they don't add up to a full page.  */
-		if (bvec->bv_offset || bvec->bv_len != PAGE_CACHE_SIZE) {
-			if (bvec->bv_offset + bvec->bv_len != PAGE_CACHE_SIZE)
+		if (bvec->bv_offset || bvec->bv_len != PAGE_SIZE) {
+			if (bvec->bv_offset + bvec->bv_len != PAGE_SIZE)
 				btrfs_err(BTRFS_I(page->mapping->host)->root->fs_info,
 				   "partial page read in btrfs with offset %u and length %u",
 					bvec->bv_offset, bvec->bv_len);
@@ -2603,13 +2603,13 @@ static void end_bio_extent_readpage(struct bio *bio)
 readpage_ok:
 		if (likely(uptodate)) {
 			loff_t i_size = i_size_read(inode);
-			pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+			pgoff_t end_index = i_size >> PAGE_SHIFT;
 			unsigned off;
 
 			/* Zero out the end if this page straddles i_size */
-			off = i_size & (PAGE_CACHE_SIZE-1);
+			off = i_size & (PAGE_SIZE-1);
 			if (page->index == end_index && off)
-				zero_user_segment(page, off, PAGE_CACHE_SIZE);
+				zero_user_segment(page, off, PAGE_SIZE);
 			SetPageUptodate(page);
 		} else {
 			ClearPageUptodate(page);
@@ -2773,7 +2773,7 @@ static int submit_extent_page(int rw, struct extent_io_tree *tree,
 	struct bio *bio;
 	int contig = 0;
 	int old_compressed = prev_bio_flags & EXTENT_BIO_COMPRESSED;
-	size_t page_size = min_t(size_t, size, PAGE_CACHE_SIZE);
+	size_t page_size = min_t(size_t, size, PAGE_SIZE);
 
 	if (bio_ret && *bio_ret) {
 		bio = *bio_ret;
@@ -2826,7 +2826,7 @@ static void attach_extent_buffer_page(struct extent_buffer *eb,
 {
 	if (!PagePrivate(page)) {
 		SetPagePrivate(page);
-		page_cache_get(page);
+		get_page(page);
 		set_page_private(page, (unsigned long)eb);
 	} else {
 		WARN_ON(page->private != (unsigned long)eb);
@@ -2837,7 +2837,7 @@ void set_page_extent_mapped(struct page *page)
 {
 	if (!PagePrivate(page)) {
 		SetPagePrivate(page);
-		page_cache_get(page);
+		get_page(page);
 		set_page_private(page, EXTENT_PAGE_PRIVATE);
 	}
 }
@@ -2885,7 +2885,7 @@ static int __do_readpage(struct extent_io_tree *tree,
 {
 	struct inode *inode = page->mapping->host;
 	u64 start = page_offset(page);
-	u64 page_end = start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = start + PAGE_SIZE - 1;
 	u64 end;
 	u64 cur = start;
 	u64 extent_offset;
@@ -2914,12 +2914,12 @@ static int __do_readpage(struct extent_io_tree *tree,
 		}
 	}
 
-	if (page->index == last_byte >> PAGE_CACHE_SHIFT) {
+	if (page->index == last_byte >> PAGE_SHIFT) {
 		char *userpage;
-		size_t zero_offset = last_byte & (PAGE_CACHE_SIZE - 1);
+		size_t zero_offset = last_byte & (PAGE_SIZE - 1);
 
 		if (zero_offset) {
-			iosize = PAGE_CACHE_SIZE - zero_offset;
+			iosize = PAGE_SIZE - zero_offset;
 			userpage = kmap_atomic(page);
 			memset(userpage + zero_offset, 0, iosize);
 			flush_dcache_page(page);
@@ -2927,14 +2927,14 @@ static int __do_readpage(struct extent_io_tree *tree,
 		}
 	}
 	while (cur <= end) {
-		unsigned long pnr = (last_byte >> PAGE_CACHE_SHIFT) + 1;
+		unsigned long pnr = (last_byte >> PAGE_SHIFT) + 1;
 		bool force_bio_submit = false;
 
 		if (cur >= last_byte) {
 			char *userpage;
 			struct extent_state *cached = NULL;
 
-			iosize = PAGE_CACHE_SIZE - pg_offset;
+			iosize = PAGE_SIZE - pg_offset;
 			userpage = kmap_atomic(page);
 			memset(userpage + pg_offset, 0, iosize);
 			flush_dcache_page(page);
@@ -3117,7 +3117,7 @@ static inline void __do_contiguous_readpages(struct extent_io_tree *tree,
 	for (index = 0; index < nr_pages; index++) {
 		__do_readpage(tree, pages[index], get_extent, em_cached, bio,
 			      mirror_num, bio_flags, rw, prev_em_start);
-		page_cache_release(pages[index]);
+		put_page(pages[index]);
 	}
 }
 
@@ -3139,10 +3139,10 @@ static void __extent_readpages(struct extent_io_tree *tree,
 		page_start = page_offset(pages[index]);
 		if (!end) {
 			start = page_start;
-			end = start + PAGE_CACHE_SIZE - 1;
+			end = start + PAGE_SIZE - 1;
 			first_index = index;
 		} else if (end + 1 == page_start) {
-			end += PAGE_CACHE_SIZE;
+			end += PAGE_SIZE;
 		} else {
 			__do_contiguous_readpages(tree, &pages[first_index],
 						  index - first_index, start,
@@ -3150,7 +3150,7 @@ static void __extent_readpages(struct extent_io_tree *tree,
 						  bio, mirror_num, bio_flags,
 						  rw, prev_em_start);
 			start = page_start;
-			end = start + PAGE_CACHE_SIZE - 1;
+			end = start + PAGE_SIZE - 1;
 			first_index = index;
 		}
 	}
@@ -3172,7 +3172,7 @@ static int __extent_read_full_page(struct extent_io_tree *tree,
 	struct inode *inode = page->mapping->host;
 	struct btrfs_ordered_extent *ordered;
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 	int ret;
 
 	while (1) {
@@ -3231,7 +3231,7 @@ static noinline_for_stack int writepage_delalloc(struct inode *inode,
 			      unsigned long *nr_written)
 {
 	struct extent_io_tree *tree = epd->tree;
-	u64 page_end = delalloc_start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = delalloc_start + PAGE_SIZE - 1;
 	u64 nr_delalloc;
 	u64 delalloc_to_write = 0;
 	u64 delalloc_end = 0;
@@ -3273,8 +3273,8 @@ static noinline_for_stack int writepage_delalloc(struct inode *inode,
 		 * PAGE_CACHE_SIZE
 		 */
 		delalloc_to_write += (delalloc_end - delalloc_start +
-				      PAGE_CACHE_SIZE) >>
-				      PAGE_CACHE_SHIFT;
+				      PAGE_SIZE) >>
+				      PAGE_SHIFT;
 		delalloc_start = delalloc_end + 1;
 	}
 	if (wbc->nr_to_write < delalloc_to_write) {
@@ -3323,7 +3323,7 @@ static noinline_for_stack int __extent_writepage_io(struct inode *inode,
 {
 	struct extent_io_tree *tree = epd->tree;
 	u64 start = page_offset(page);
-	u64 page_end = start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = start + PAGE_SIZE - 1;
 	u64 end;
 	u64 cur = start;
 	u64 extent_offset;
@@ -3438,7 +3438,7 @@ static noinline_for_stack int __extent_writepage_io(struct inode *inode,
 		if (ret) {
 			SetPageError(page);
 		} else {
-			unsigned long max_nr = (i_size >> PAGE_CACHE_SHIFT) + 1;
+			unsigned long max_nr = (i_size >> PAGE_SHIFT) + 1;
 
 			set_range_writeback(tree, cur, cur + iosize - 1);
 			if (!PageWriteback(page)) {
@@ -3481,12 +3481,12 @@ static int __extent_writepage(struct page *page, struct writeback_control *wbc,
 	struct inode *inode = page->mapping->host;
 	struct extent_page_data *epd = data;
 	u64 start = page_offset(page);
-	u64 page_end = start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = start + PAGE_SIZE - 1;
 	int ret;
 	int nr = 0;
 	size_t pg_offset = 0;
 	loff_t i_size = i_size_read(inode);
-	unsigned long end_index = i_size >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = i_size >> PAGE_SHIFT;
 	int write_flags;
 	unsigned long nr_written = 0;
 
@@ -3501,10 +3501,10 @@ static int __extent_writepage(struct page *page, struct writeback_control *wbc,
 
 	ClearPageError(page);
 
-	pg_offset = i_size & (PAGE_CACHE_SIZE - 1);
+	pg_offset = i_size & (PAGE_SIZE - 1);
 	if (page->index > end_index ||
 	   (page->index == end_index && !pg_offset)) {
-		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		page->mapping->a_ops->invalidatepage(page, 0, PAGE_SIZE);
 		unlock_page(page);
 		return 0;
 	}
@@ -3514,7 +3514,7 @@ static int __extent_writepage(struct page *page, struct writeback_control *wbc,
 
 		userpage = kmap_atomic(page);
 		memset(userpage + pg_offset, 0,
-		       PAGE_CACHE_SIZE - pg_offset);
+		       PAGE_SIZE - pg_offset);
 		kunmap_atomic(userpage);
 		flush_dcache_page(page);
 	}
@@ -3752,7 +3752,7 @@ static noinline_for_stack int write_one_eb(struct extent_buffer *eb,
 		clear_page_dirty_for_io(p);
 		set_page_writeback(p);
 		ret = submit_extent_page(rw, tree, wbc, p, offset >> 9,
-					 PAGE_CACHE_SIZE, 0, bdev, &epd->bio,
+					 PAGE_SIZE, 0, bdev, &epd->bio,
 					 -1, end_bio_extent_buffer_writepage,
 					 0, epd->bio_flags, bio_flags, false);
 		epd->bio_flags = bio_flags;
@@ -3764,7 +3764,7 @@ static noinline_for_stack int write_one_eb(struct extent_buffer *eb,
 			ret = -EIO;
 			break;
 		}
-		offset += PAGE_CACHE_SIZE;
+		offset += PAGE_SIZE;
 		update_nr_written(p, wbc, 1);
 		unlock_page(p);
 	}
@@ -3808,8 +3808,8 @@ int btree_write_cache_pages(struct address_space *mapping,
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		scanned = 1;
 	}
 	if (wbc->sync_mode == WB_SYNC_ALL)
@@ -3952,8 +3952,8 @@ static int extent_write_cache_pages(struct extent_io_tree *tree,
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		scanned = 1;
 	}
 	if (wbc->sync_mode == WB_SYNC_ALL)
@@ -4087,8 +4087,8 @@ int extent_write_locked_range(struct extent_io_tree *tree, struct inode *inode,
 	int ret = 0;
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
-	unsigned long nr_pages = (end - start + PAGE_CACHE_SIZE) >>
-		PAGE_CACHE_SHIFT;
+	unsigned long nr_pages = (end - start + PAGE_SIZE) >>
+		PAGE_SHIFT;
 
 	struct extent_page_data epd = {
 		.bio = NULL,
@@ -4106,18 +4106,18 @@ int extent_write_locked_range(struct extent_io_tree *tree, struct inode *inode,
 	};
 
 	while (start <= end) {
-		page = find_get_page(mapping, start >> PAGE_CACHE_SHIFT);
+		page = find_get_page(mapping, start >> PAGE_SHIFT);
 		if (clear_page_dirty_for_io(page))
 			ret = __extent_writepage(page, &wbc_writepages, &epd);
 		else {
 			if (tree->ops && tree->ops->writepage_end_io_hook)
 				tree->ops->writepage_end_io_hook(page, start,
-						 start + PAGE_CACHE_SIZE - 1,
+						 start + PAGE_SIZE - 1,
 						 NULL, 1);
 			unlock_page(page);
 		}
-		page_cache_release(page);
-		start += PAGE_CACHE_SIZE;
+		put_page(page);
+		start += PAGE_SIZE;
 	}
 
 	flush_epd_write_bio(&epd);
@@ -4167,7 +4167,7 @@ int extent_readpages(struct extent_io_tree *tree,
 		list_del(&page->lru);
 		if (add_to_page_cache_lru(page, mapping,
 					page->index, GFP_NOFS)) {
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -4201,7 +4201,7 @@ int extent_invalidatepage(struct extent_io_tree *tree,
 {
 	struct extent_state *cached_state = NULL;
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 	size_t blocksize = page->mapping->host->i_sb->s_blocksize;
 
 	start += ALIGN(offset, blocksize);
@@ -4227,7 +4227,7 @@ static int try_release_extent_state(struct extent_map_tree *map,
 				    struct page *page, gfp_t mask)
 {
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 	int ret = 1;
 
 	if (test_range_bit(tree, start, end,
@@ -4266,7 +4266,7 @@ int try_release_extent_mapping(struct extent_map_tree *map,
 {
 	struct extent_map *em;
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 
 	if (gfpflags_allow_blocking(mask) &&
 	    page->mapping->host->i_size > SZ_16M) {
@@ -4591,14 +4591,14 @@ static void btrfs_release_extent_buffer_page(struct extent_buffer *eb)
 			ClearPagePrivate(page);
 			set_page_private(page, 0);
 			/* One for the page private */
-			page_cache_release(page);
+			put_page(page);
 		}
 
 		if (mapped)
 			spin_unlock(&page->mapping->private_lock);
 
 		/* One for when we alloced the page */
-		page_cache_release(page);
+		put_page(page);
 	} while (index != 0);
 }
 
@@ -4783,7 +4783,7 @@ struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
 
 	rcu_read_lock();
 	eb = radix_tree_lookup(&fs_info->buffer_radix,
-			       start >> PAGE_CACHE_SHIFT);
+			       start >> PAGE_SHIFT);
 	if (eb && atomic_inc_not_zero(&eb->refs)) {
 		rcu_read_unlock();
 		/*
@@ -4833,7 +4833,7 @@ again:
 		goto free_eb;
 	spin_lock(&fs_info->buffer_lock);
 	ret = radix_tree_insert(&fs_info->buffer_radix,
-				start >> PAGE_CACHE_SHIFT, eb);
+				start >> PAGE_SHIFT, eb);
 	spin_unlock(&fs_info->buffer_lock);
 	radix_tree_preload_end();
 	if (ret == -EEXIST) {
@@ -4866,7 +4866,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 	unsigned long len = fs_info->tree_root->nodesize;
 	unsigned long num_pages = num_extent_pages(start, len);
 	unsigned long i;
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
 	struct extent_buffer *eb;
 	struct extent_buffer *exists = NULL;
 	struct page *p;
@@ -4900,7 +4900,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 			if (atomic_inc_not_zero(&exists->refs)) {
 				spin_unlock(&mapping->private_lock);
 				unlock_page(p);
-				page_cache_release(p);
+				put_page(p);
 				mark_extent_buffer_accessed(exists, p);
 				goto free_eb;
 			}
@@ -4912,7 +4912,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 			 */
 			ClearPagePrivate(p);
 			WARN_ON(PageDirty(p));
-			page_cache_release(p);
+			put_page(p);
 		}
 		attach_extent_buffer_page(eb, p);
 		spin_unlock(&mapping->private_lock);
@@ -4935,7 +4935,7 @@ again:
 
 	spin_lock(&fs_info->buffer_lock);
 	ret = radix_tree_insert(&fs_info->buffer_radix,
-				start >> PAGE_CACHE_SHIFT, eb);
+				start >> PAGE_SHIFT, eb);
 	spin_unlock(&fs_info->buffer_lock);
 	radix_tree_preload_end();
 	if (ret == -EEXIST) {
@@ -4998,7 +4998,7 @@ static int release_extent_buffer(struct extent_buffer *eb)
 
 			spin_lock(&fs_info->buffer_lock);
 			radix_tree_delete(&fs_info->buffer_radix,
-					  eb->start >> PAGE_CACHE_SHIFT);
+					  eb->start >> PAGE_SHIFT);
 			spin_unlock(&fs_info->buffer_lock);
 		} else {
 			spin_unlock(&eb->refs_lock);
@@ -5172,8 +5172,8 @@ int read_extent_buffer_pages(struct extent_io_tree *tree,
 
 	if (start) {
 		WARN_ON(start < eb->start);
-		start_i = (start >> PAGE_CACHE_SHIFT) -
-			(eb->start >> PAGE_CACHE_SHIFT);
+		start_i = (start >> PAGE_SHIFT) -
+			(eb->start >> PAGE_SHIFT);
 	} else {
 		start_i = 0;
 	}
@@ -5256,18 +5256,18 @@ void read_extent_buffer(struct extent_buffer *eb, void *dstv,
 	struct page *page;
 	char *kaddr;
 	char *dst = (char *)dstv;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 
-		cur = min(len, (PAGE_CACHE_SIZE - offset));
+		cur = min(len, (PAGE_SIZE - offset));
 		kaddr = page_address(page);
 		memcpy(dst, kaddr + offset, cur);
 
@@ -5287,19 +5287,19 @@ int read_extent_buffer_to_user(struct extent_buffer *eb, void __user *dstv,
 	struct page *page;
 	char *kaddr;
 	char __user *dst = (char __user *)dstv;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 	int ret = 0;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 
-		cur = min(len, (PAGE_CACHE_SIZE - offset));
+		cur = min(len, (PAGE_SIZE - offset));
 		kaddr = page_address(page);
 		if (copy_to_user(dst, kaddr + offset, cur)) {
 			ret = -EFAULT;
@@ -5320,13 +5320,13 @@ int map_private_extent_buffer(struct extent_buffer *eb, unsigned long start,
 			       unsigned long *map_start,
 			       unsigned long *map_len)
 {
-	size_t offset = start & (PAGE_CACHE_SIZE - 1);
+	size_t offset = start & (PAGE_SIZE - 1);
 	char *kaddr;
 	struct page *p;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 	unsigned long end_i = (start_offset + start + min_len - 1) >>
-		PAGE_CACHE_SHIFT;
+		PAGE_SHIFT;
 
 	if (i != end_i)
 		return -EINVAL;
@@ -5336,7 +5336,7 @@ int map_private_extent_buffer(struct extent_buffer *eb, unsigned long start,
 		*map_start = 0;
 	} else {
 		offset = 0;
-		*map_start = ((u64)i << PAGE_CACHE_SHIFT) - start_offset;
+		*map_start = ((u64)i << PAGE_SHIFT) - start_offset;
 	}
 
 	if (start + min_len > eb->len) {
@@ -5349,7 +5349,7 @@ int map_private_extent_buffer(struct extent_buffer *eb, unsigned long start,
 	p = eb->pages[i];
 	kaddr = page_address(p);
 	*map = kaddr + offset;
-	*map_len = PAGE_CACHE_SIZE - offset;
+	*map_len = PAGE_SIZE - offset;
 	return 0;
 }
 
@@ -5362,19 +5362,19 @@ int memcmp_extent_buffer(struct extent_buffer *eb, const void *ptrv,
 	struct page *page;
 	char *kaddr;
 	char *ptr = (char *)ptrv;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 	int ret = 0;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 
-		cur = min(len, (PAGE_CACHE_SIZE - offset));
+		cur = min(len, (PAGE_SIZE - offset));
 
 		kaddr = page_address(page);
 		ret = memcmp(ptr, kaddr + offset, cur);
@@ -5397,19 +5397,19 @@ void write_extent_buffer(struct extent_buffer *eb, const void *srcv,
 	struct page *page;
 	char *kaddr;
 	char *src = (char *)srcv;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 		WARN_ON(!PageUptodate(page));
 
-		cur = min(len, PAGE_CACHE_SIZE - offset);
+		cur = min(len, PAGE_SIZE - offset);
 		kaddr = page_address(page);
 		memcpy(kaddr + offset, src, cur);
 
@@ -5427,19 +5427,19 @@ void memset_extent_buffer(struct extent_buffer *eb, char c,
 	size_t offset;
 	struct page *page;
 	char *kaddr;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 		WARN_ON(!PageUptodate(page));
 
-		cur = min(len, PAGE_CACHE_SIZE - offset);
+		cur = min(len, PAGE_SIZE - offset);
 		kaddr = page_address(page);
 		memset(kaddr + offset, c, cur);
 
@@ -5458,19 +5458,19 @@ void copy_extent_buffer(struct extent_buffer *dst, struct extent_buffer *src,
 	size_t offset;
 	struct page *page;
 	char *kaddr;
-	size_t start_offset = dst->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + dst_offset) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = dst->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + dst_offset) >> PAGE_SHIFT;
 
 	WARN_ON(src->len != dst_len);
 
 	offset = (start_offset + dst_offset) &
-		(PAGE_CACHE_SIZE - 1);
+		(PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = dst->pages[i];
 		WARN_ON(!PageUptodate(page));
 
-		cur = min(len, (unsigned long)(PAGE_CACHE_SIZE - offset));
+		cur = min(len, (unsigned long)(PAGE_SIZE - offset));
 
 		kaddr = page_address(page);
 		read_extent_buffer(src, kaddr + offset, src_offset, cur);
@@ -5512,7 +5512,7 @@ static inline void eb_bitmap_offset(struct extent_buffer *eb,
 				    unsigned long *page_index,
 				    size_t *page_offset)
 {
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
 	size_t byte_offset = BIT_BYTE(nr);
 	size_t offset;
 
@@ -5523,8 +5523,8 @@ static inline void eb_bitmap_offset(struct extent_buffer *eb,
 	 */
 	offset = start_offset + start + byte_offset;
 
-	*page_index = offset >> PAGE_CACHE_SHIFT;
-	*page_offset = offset & (PAGE_CACHE_SIZE - 1);
+	*page_index = offset >> PAGE_SHIFT;
+	*page_offset = offset & (PAGE_SIZE - 1);
 }
 
 /**
@@ -5576,7 +5576,7 @@ void extent_buffer_bitmap_set(struct extent_buffer *eb, unsigned long start,
 		len -= bits_to_set;
 		bits_to_set = BITS_PER_BYTE;
 		mask_to_set = ~0U;
-		if (++offset >= PAGE_CACHE_SIZE && len > 0) {
+		if (++offset >= PAGE_SIZE && len > 0) {
 			offset = 0;
 			page = eb->pages[++i];
 			WARN_ON(!PageUptodate(page));
@@ -5618,7 +5618,7 @@ void extent_buffer_bitmap_clear(struct extent_buffer *eb, unsigned long start,
 		len -= bits_to_clear;
 		bits_to_clear = BITS_PER_BYTE;
 		mask_to_clear = ~0U;
-		if (++offset >= PAGE_CACHE_SIZE && len > 0) {
+		if (++offset >= PAGE_SIZE && len > 0) {
 			offset = 0;
 			page = eb->pages[++i];
 			WARN_ON(!PageUptodate(page));
@@ -5665,7 +5665,7 @@ void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 	size_t cur;
 	size_t dst_off_in_page;
 	size_t src_off_in_page;
-	size_t start_offset = dst->start & ((u64)PAGE_CACHE_SIZE - 1);
+	size_t start_offset = dst->start & ((u64)PAGE_SIZE - 1);
 	unsigned long dst_i;
 	unsigned long src_i;
 
@@ -5684,17 +5684,17 @@ void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 
 	while (len > 0) {
 		dst_off_in_page = (start_offset + dst_offset) &
-			(PAGE_CACHE_SIZE - 1);
+			(PAGE_SIZE - 1);
 		src_off_in_page = (start_offset + src_offset) &
-			(PAGE_CACHE_SIZE - 1);
+			(PAGE_SIZE - 1);
 
-		dst_i = (start_offset + dst_offset) >> PAGE_CACHE_SHIFT;
-		src_i = (start_offset + src_offset) >> PAGE_CACHE_SHIFT;
+		dst_i = (start_offset + dst_offset) >> PAGE_SHIFT;
+		src_i = (start_offset + src_offset) >> PAGE_SHIFT;
 
-		cur = min(len, (unsigned long)(PAGE_CACHE_SIZE -
+		cur = min(len, (unsigned long)(PAGE_SIZE -
 					       src_off_in_page));
 		cur = min_t(unsigned long, cur,
-			(unsigned long)(PAGE_CACHE_SIZE - dst_off_in_page));
+			(unsigned long)(PAGE_SIZE - dst_off_in_page));
 
 		copy_pages(dst->pages[dst_i], dst->pages[src_i],
 			   dst_off_in_page, src_off_in_page, cur);
@@ -5713,7 +5713,7 @@ void memmove_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 	size_t src_off_in_page;
 	unsigned long dst_end = dst_offset + len - 1;
 	unsigned long src_end = src_offset + len - 1;
-	size_t start_offset = dst->start & ((u64)PAGE_CACHE_SIZE - 1);
+	size_t start_offset = dst->start & ((u64)PAGE_SIZE - 1);
 	unsigned long dst_i;
 	unsigned long src_i;
 
@@ -5732,13 +5732,13 @@ void memmove_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 		return;
 	}
 	while (len > 0) {
-		dst_i = (start_offset + dst_end) >> PAGE_CACHE_SHIFT;
-		src_i = (start_offset + src_end) >> PAGE_CACHE_SHIFT;
+		dst_i = (start_offset + dst_end) >> PAGE_SHIFT;
+		src_i = (start_offset + src_end) >> PAGE_SHIFT;
 
 		dst_off_in_page = (start_offset + dst_end) &
-			(PAGE_CACHE_SIZE - 1);
+			(PAGE_SIZE - 1);
 		src_off_in_page = (start_offset + src_end) &
-			(PAGE_CACHE_SIZE - 1);
+			(PAGE_SIZE - 1);
 
 		cur = min_t(unsigned long, len, src_off_in_page + 1);
 		cur = min(cur, dst_off_in_page + 1);
diff --git a/fs/btrfs/extent_io.h b/fs/btrfs/extent_io.h
index 880d5292e972..9c5abfac3338 100644
--- a/fs/btrfs/extent_io.h
+++ b/fs/btrfs/extent_io.h
@@ -120,7 +120,7 @@ struct extent_state {
 };
 
 #define INLINE_EXTENT_BUFFER_PAGES 16
-#define MAX_INLINE_EXTENT_BUFFER_SIZE (INLINE_EXTENT_BUFFER_PAGES * PAGE_CACHE_SIZE)
+#define MAX_INLINE_EXTENT_BUFFER_SIZE (INLINE_EXTENT_BUFFER_PAGES * PAGE_SIZE)
 struct extent_buffer {
 	u64 start;
 	unsigned long len;
@@ -366,8 +366,8 @@ void wait_on_extent_buffer_writeback(struct extent_buffer *eb);
 
 static inline unsigned long num_extent_pages(u64 start, u64 len)
 {
-	return ((start + len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT) -
-		(start >> PAGE_CACHE_SHIFT);
+	return ((start + len + PAGE_SIZE - 1) >> PAGE_SHIFT) -
+		(start >> PAGE_SHIFT);
 }
 
 static inline void extent_buffer_get(struct extent_buffer *eb)
diff --git a/fs/btrfs/file-item.c b/fs/btrfs/file-item.c
index a67e1c828d0f..9311b524b1c1 100644
--- a/fs/btrfs/file-item.c
+++ b/fs/btrfs/file-item.c
@@ -31,7 +31,7 @@
 				  size) - 1))
 
 #define MAX_CSUM_ITEMS(r, size) (min_t(u32, __MAX_CSUM_ITEMS(r, size), \
-				       PAGE_CACHE_SIZE))
+				       PAGE_SIZE))
 
 #define MAX_ORDERED_SUM_BYTES(r) ((PAGE_SIZE - \
 				   sizeof(struct btrfs_ordered_sum)) / \
@@ -201,7 +201,7 @@ static int __btrfs_lookup_bio_sums(struct btrfs_root *root,
 		csum = (u8 *)dst;
 	}
 
-	if (bio->bi_iter.bi_size > PAGE_CACHE_SIZE * 8)
+	if (bio->bi_iter.bi_size > PAGE_SIZE * 8)
 		path->reada = READA_FORWARD;
 
 	WARN_ON(bio->bi_vcnt <= 0);
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 098bb8f690c9..bbb4b4a618a6 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -413,11 +413,11 @@ static noinline int btrfs_copy_from_user(loff_t pos, size_t write_bytes,
 	size_t copied = 0;
 	size_t total_copied = 0;
 	int pg = 0;
-	int offset = pos & (PAGE_CACHE_SIZE - 1);
+	int offset = pos & (PAGE_SIZE - 1);
 
 	while (write_bytes > 0) {
 		size_t count = min_t(size_t,
-				     PAGE_CACHE_SIZE - offset, write_bytes);
+				     PAGE_SIZE - offset, write_bytes);
 		struct page *page = prepared_pages[pg];
 		/*
 		 * Copy data from userspace to the current page
@@ -447,7 +447,7 @@ static noinline int btrfs_copy_from_user(loff_t pos, size_t write_bytes,
 		if (unlikely(copied == 0))
 			break;
 
-		if (copied < PAGE_CACHE_SIZE - offset) {
+		if (copied < PAGE_SIZE - offset) {
 			offset += copied;
 		} else {
 			pg++;
@@ -472,7 +472,7 @@ static void btrfs_drop_pages(struct page **pages, size_t num_pages)
 		 */
 		ClearPageChecked(pages[i]);
 		unlock_page(pages[i]);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 }
 
@@ -1296,7 +1296,7 @@ static int prepare_uptodate_page(struct inode *inode,
 {
 	int ret = 0;
 
-	if (((pos & (PAGE_CACHE_SIZE - 1)) || force_uptodate) &&
+	if (((pos & (PAGE_SIZE - 1)) || force_uptodate) &&
 	    !PageUptodate(page)) {
 		ret = btrfs_readpage(NULL, page);
 		if (ret)
@@ -1322,7 +1322,7 @@ static noinline int prepare_pages(struct inode *inode, struct page **pages,
 				  size_t write_bytes, bool force_uptodate)
 {
 	int i;
-	unsigned long index = pos >> PAGE_CACHE_SHIFT;
+	unsigned long index = pos >> PAGE_SHIFT;
 	gfp_t mask = btrfs_alloc_write_mask(inode->i_mapping);
 	int err = 0;
 	int faili;
@@ -1344,7 +1344,7 @@ again:
 			err = prepare_uptodate_page(inode, pages[i],
 						    pos + write_bytes, false);
 		if (err) {
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 			if (err == -EAGAIN) {
 				err = 0;
 				goto again;
@@ -1359,7 +1359,7 @@ again:
 fail:
 	while (faili >= 0) {
 		unlock_page(pages[faili]);
-		page_cache_release(pages[faili]);
+		put_page(pages[faili]);
 		faili--;
 	}
 	return err;
@@ -1387,8 +1387,8 @@ lock_and_cleanup_extent_if_need(struct inode *inode, struct page **pages,
 	int i;
 	int ret = 0;
 
-	start_pos = pos & ~((u64)PAGE_CACHE_SIZE - 1);
-	last_pos = start_pos + ((u64)num_pages << PAGE_CACHE_SHIFT) - 1;
+	start_pos = pos & ~((u64)PAGE_SIZE - 1);
+	last_pos = start_pos + ((u64)num_pages << PAGE_SHIFT) - 1;
 
 	if (start_pos < inode->i_size) {
 		struct btrfs_ordered_extent *ordered;
@@ -1404,7 +1404,7 @@ lock_and_cleanup_extent_if_need(struct inode *inode, struct page **pages,
 					     cached_state, GFP_NOFS);
 			for (i = 0; i < num_pages; i++) {
 				unlock_page(pages[i]);
-				page_cache_release(pages[i]);
+				put_page(pages[i]);
 			}
 			btrfs_start_ordered_extent(inode, ordered, 1);
 			btrfs_put_ordered_extent(ordered);
@@ -1493,8 +1493,8 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 	bool force_page_uptodate = false;
 	bool need_unlock;
 
-	nrptrs = min(DIV_ROUND_UP(iov_iter_count(i), PAGE_CACHE_SIZE),
-			PAGE_CACHE_SIZE / (sizeof(struct page *)));
+	nrptrs = min(DIV_ROUND_UP(iov_iter_count(i), PAGE_SIZE),
+			PAGE_SIZE / (sizeof(struct page *)));
 	nrptrs = min(nrptrs, current->nr_dirtied_pause - current->nr_dirtied);
 	nrptrs = max(nrptrs, 8);
 	pages = kmalloc_array(nrptrs, sizeof(struct page *), GFP_KERNEL);
@@ -1502,12 +1502,12 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 		return -ENOMEM;
 
 	while (iov_iter_count(i) > 0) {
-		size_t offset = pos & (PAGE_CACHE_SIZE - 1);
+		size_t offset = pos & (PAGE_SIZE - 1);
 		size_t write_bytes = min(iov_iter_count(i),
-					 nrptrs * (size_t)PAGE_CACHE_SIZE -
+					 nrptrs * (size_t)PAGE_SIZE -
 					 offset);
 		size_t num_pages = DIV_ROUND_UP(write_bytes + offset,
-						PAGE_CACHE_SIZE);
+						PAGE_SIZE);
 		size_t reserve_bytes;
 		size_t dirty_pages;
 		size_t copied;
@@ -1523,7 +1523,7 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 			break;
 		}
 
-		reserve_bytes = num_pages << PAGE_CACHE_SHIFT;
+		reserve_bytes = num_pages << PAGE_SHIFT;
 
 		if (BTRFS_I(inode)->flags & (BTRFS_INODE_NODATACOW |
 					     BTRFS_INODE_PREALLOC)) {
@@ -1541,8 +1541,8 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 				 * write_bytes, so scale down.
 				 */
 				num_pages = DIV_ROUND_UP(write_bytes + offset,
-							 PAGE_CACHE_SIZE);
-				reserve_bytes = num_pages << PAGE_CACHE_SHIFT;
+							 PAGE_SIZE);
+				reserve_bytes = num_pages << PAGE_SHIFT;
 				goto reserve_metadata;
 			}
 		}
@@ -1602,7 +1602,7 @@ again:
 		} else {
 			force_page_uptodate = false;
 			dirty_pages = DIV_ROUND_UP(copied + offset,
-						   PAGE_CACHE_SIZE);
+						   PAGE_SIZE);
 		}
 
 		/*
@@ -1614,7 +1614,7 @@ again:
 		 */
 		if (num_pages > dirty_pages) {
 			release_bytes = (num_pages - dirty_pages) <<
-				PAGE_CACHE_SHIFT;
+				PAGE_SHIFT;
 			if (copied > 0) {
 				spin_lock(&BTRFS_I(inode)->lock);
 				BTRFS_I(inode)->outstanding_extents++;
@@ -1627,13 +1627,13 @@ again:
 				u64 __pos;
 
 				__pos = round_down(pos, root->sectorsize) +
-					(dirty_pages << PAGE_CACHE_SHIFT);
+					(dirty_pages << PAGE_SHIFT);
 				btrfs_delalloc_release_space(inode, __pos,
 							     release_bytes);
 			}
 		}
 
-		release_bytes = dirty_pages << PAGE_CACHE_SHIFT;
+		release_bytes = dirty_pages << PAGE_SHIFT;
 
 		if (copied > 0)
 			ret = btrfs_dirty_pages(root, inode, pages,
@@ -1655,7 +1655,7 @@ again:
 		if (only_release_metadata && copied > 0) {
 			lockstart = round_down(pos, root->sectorsize);
 			lockend = lockstart +
-				(dirty_pages << PAGE_CACHE_SHIFT) - 1;
+				(dirty_pages << PAGE_SHIFT) - 1;
 
 			set_extent_bit(&BTRFS_I(inode)->io_tree, lockstart,
 				       lockend, EXTENT_NORESERVE, NULL,
@@ -1668,7 +1668,7 @@ again:
 		cond_resched();
 
 		balance_dirty_pages_ratelimited(inode->i_mapping);
-		if (dirty_pages < (root->nodesize >> PAGE_CACHE_SHIFT) + 1)
+		if (dirty_pages < (root->nodesize >> PAGE_SHIFT) + 1)
 			btrfs_btree_balance_dirty(root);
 
 		pos += copied;
@@ -1724,8 +1724,8 @@ static ssize_t __btrfs_direct_write(struct kiocb *iocb,
 		goto out;
 	written += written_buffered;
 	iocb->ki_pos = pos + written_buffered;
-	invalidate_mapping_pages(file->f_mapping, pos >> PAGE_CACHE_SHIFT,
-				 endbyte >> PAGE_CACHE_SHIFT);
+	invalidate_mapping_pages(file->f_mapping, pos >> PAGE_SHIFT,
+				 endbyte >> PAGE_SHIFT);
 out:
 	return written ? written : err;
 }
@@ -2304,7 +2304,7 @@ static int btrfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 		return ret;
 
 	inode_lock(inode);
-	ino_size = round_up(inode->i_size, PAGE_CACHE_SIZE);
+	ino_size = round_up(inode->i_size, PAGE_SIZE);
 	ret = find_first_non_hole(inode, &offset, &len);
 	if (ret < 0)
 		goto out_only_mutex;
@@ -2317,8 +2317,8 @@ static int btrfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	lockstart = round_up(offset, BTRFS_I(inode)->root->sectorsize);
 	lockend = round_down(offset + len,
 			     BTRFS_I(inode)->root->sectorsize) - 1;
-	same_page = ((offset >> PAGE_CACHE_SHIFT) ==
-		    ((offset + len - 1) >> PAGE_CACHE_SHIFT));
+	same_page = ((offset >> PAGE_SHIFT) ==
+		     ((offset + len - 1) >> PAGE_SHIFT));
 
 	/*
 	 * We needn't truncate any page which is beyond the end of the file
@@ -2328,7 +2328,7 @@ static int btrfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	 * Only do this if we are in the same page and we aren't doing the
 	 * entire page.
 	 */
-	if (same_page && len < PAGE_CACHE_SIZE) {
+	if (same_page && len < PAGE_SIZE) {
 		if (offset < ino_size) {
 			truncated_page = true;
 			ret = btrfs_truncate_page(inode, offset, len, 0);
diff --git a/fs/btrfs/free-space-cache.c b/fs/btrfs/free-space-cache.c
index 8f835bfa1bdd..5e6062c26129 100644
--- a/fs/btrfs/free-space-cache.c
+++ b/fs/btrfs/free-space-cache.c
@@ -29,7 +29,7 @@
 #include "inode-map.h"
 #include "volumes.h"
 
-#define BITS_PER_BITMAP		(PAGE_CACHE_SIZE * 8)
+#define BITS_PER_BITMAP		(PAGE_SIZE * 8)
 #define MAX_CACHE_BYTES_PER_GIG	SZ_32K
 
 struct btrfs_trim_range {
@@ -295,7 +295,7 @@ static int readahead_cache(struct inode *inode)
 		return -ENOMEM;
 
 	file_ra_state_init(ra, inode->i_mapping);
-	last_index = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
+	last_index = (i_size_read(inode) - 1) >> PAGE_SHIFT;
 
 	page_cache_sync_readahead(inode->i_mapping, ra, NULL, 0, last_index);
 
@@ -310,14 +310,14 @@ static int io_ctl_init(struct btrfs_io_ctl *io_ctl, struct inode *inode,
 	int num_pages;
 	int check_crcs = 0;
 
-	num_pages = DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE);
+	num_pages = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 
 	if (btrfs_ino(inode) != BTRFS_FREE_INO_OBJECTID)
 		check_crcs = 1;
 
 	/* Make sure we can fit our crcs into the first page */
 	if (write && check_crcs &&
-	    (num_pages * sizeof(u32)) >= PAGE_CACHE_SIZE)
+	    (num_pages * sizeof(u32)) >= PAGE_SIZE)
 		return -ENOSPC;
 
 	memset(io_ctl, 0, sizeof(struct btrfs_io_ctl));
@@ -354,9 +354,9 @@ static void io_ctl_map_page(struct btrfs_io_ctl *io_ctl, int clear)
 	io_ctl->page = io_ctl->pages[io_ctl->index++];
 	io_ctl->cur = page_address(io_ctl->page);
 	io_ctl->orig = io_ctl->cur;
-	io_ctl->size = PAGE_CACHE_SIZE;
+	io_ctl->size = PAGE_SIZE;
 	if (clear)
-		memset(io_ctl->cur, 0, PAGE_CACHE_SIZE);
+		memset(io_ctl->cur, 0, PAGE_SIZE);
 }
 
 static void io_ctl_drop_pages(struct btrfs_io_ctl *io_ctl)
@@ -369,7 +369,7 @@ static void io_ctl_drop_pages(struct btrfs_io_ctl *io_ctl)
 		if (io_ctl->pages[i]) {
 			ClearPageChecked(io_ctl->pages[i]);
 			unlock_page(io_ctl->pages[i]);
-			page_cache_release(io_ctl->pages[i]);
+			put_page(io_ctl->pages[i]);
 		}
 	}
 }
@@ -475,7 +475,7 @@ static void io_ctl_set_crc(struct btrfs_io_ctl *io_ctl, int index)
 		offset = sizeof(u32) * io_ctl->num_pages;
 
 	crc = btrfs_csum_data(io_ctl->orig + offset, crc,
-			      PAGE_CACHE_SIZE - offset);
+			      PAGE_SIZE - offset);
 	btrfs_csum_final(crc, (char *)&crc);
 	io_ctl_unmap_page(io_ctl);
 	tmp = page_address(io_ctl->pages[0]);
@@ -503,7 +503,7 @@ static int io_ctl_check_crc(struct btrfs_io_ctl *io_ctl, int index)
 
 	io_ctl_map_page(io_ctl, 0);
 	crc = btrfs_csum_data(io_ctl->orig + offset, crc,
-			      PAGE_CACHE_SIZE - offset);
+			      PAGE_SIZE - offset);
 	btrfs_csum_final(crc, (char *)&crc);
 	if (val != crc) {
 		btrfs_err_rl(io_ctl->root->fs_info,
@@ -561,7 +561,7 @@ static int io_ctl_add_bitmap(struct btrfs_io_ctl *io_ctl, void *bitmap)
 		io_ctl_map_page(io_ctl, 0);
 	}
 
-	memcpy(io_ctl->cur, bitmap, PAGE_CACHE_SIZE);
+	memcpy(io_ctl->cur, bitmap, PAGE_SIZE);
 	io_ctl_set_crc(io_ctl, io_ctl->index - 1);
 	if (io_ctl->index < io_ctl->num_pages)
 		io_ctl_map_page(io_ctl, 0);
@@ -621,7 +621,7 @@ static int io_ctl_read_bitmap(struct btrfs_io_ctl *io_ctl,
 	if (ret)
 		return ret;
 
-	memcpy(entry->bitmap, io_ctl->cur, PAGE_CACHE_SIZE);
+	memcpy(entry->bitmap, io_ctl->cur, PAGE_SIZE);
 	io_ctl_unmap_page(io_ctl);
 
 	return 0;
@@ -775,7 +775,7 @@ static int __load_free_space_cache(struct btrfs_root *root, struct inode *inode,
 		} else {
 			ASSERT(num_bitmaps);
 			num_bitmaps--;
-			e->bitmap = kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+			e->bitmap = kzalloc(PAGE_SIZE, GFP_NOFS);
 			if (!e->bitmap) {
 				kmem_cache_free(
 					btrfs_free_space_cachep, e);
@@ -1660,7 +1660,7 @@ static void recalculate_thresholds(struct btrfs_free_space_ctl *ctl)
 	 * sure we don't go over our overall goal of MAX_CACHE_BYTES_PER_GIG as
 	 * we add more bitmaps.
 	 */
-	bitmap_bytes = (ctl->total_bitmaps + 1) * PAGE_CACHE_SIZE;
+	bitmap_bytes = (ctl->total_bitmaps + 1) * PAGE_SIZE;
 
 	if (bitmap_bytes >= max_bytes) {
 		ctl->extents_thresh = 0;
@@ -2111,7 +2111,7 @@ new_bitmap:
 		}
 
 		/* allocate the bitmap */
-		info->bitmap = kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+		info->bitmap = kzalloc(PAGE_SIZE, GFP_NOFS);
 		spin_lock(&ctl->tree_lock);
 		if (!info->bitmap) {
 			ret = -ENOMEM;
@@ -3580,7 +3580,7 @@ again:
 	}
 
 	if (!map) {
-		map = kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+		map = kzalloc(PAGE_SIZE, GFP_NOFS);
 		if (!map) {
 			kmem_cache_free(btrfs_free_space_cachep, info);
 			return -ENOMEM;
diff --git a/fs/btrfs/inode-map.c b/fs/btrfs/inode-map.c
index e50316c4af15..72e34e25dd8e 100644
--- a/fs/btrfs/inode-map.c
+++ b/fs/btrfs/inode-map.c
@@ -283,7 +283,7 @@ void btrfs_unpin_free_ino(struct btrfs_root *root)
 }
 
 #define INIT_THRESHOLD	((SZ_32K / 2) / sizeof(struct btrfs_free_space))
-#define INODES_PER_BITMAP (PAGE_CACHE_SIZE * 8)
+#define INODES_PER_BITMAP (PAGE_SIZE * 8)
 
 /*
  * The goal is to keep the memory used by the free_ino tree won't
@@ -317,7 +317,7 @@ static void recalculate_thresholds(struct btrfs_free_space_ctl *ctl)
 	}
 
 	ctl->extents_thresh = (max_bitmaps - ctl->total_bitmaps) *
-				PAGE_CACHE_SIZE / sizeof(*info);
+				PAGE_SIZE / sizeof(*info);
 }
 
 /*
@@ -481,12 +481,12 @@ again:
 
 	spin_lock(&ctl->tree_lock);
 	prealloc = sizeof(struct btrfs_free_space) * ctl->free_extents;
-	prealloc = ALIGN(prealloc, PAGE_CACHE_SIZE);
-	prealloc += ctl->total_bitmaps * PAGE_CACHE_SIZE;
+	prealloc = ALIGN(prealloc, PAGE_SIZE);
+	prealloc += ctl->total_bitmaps * PAGE_SIZE;
 	spin_unlock(&ctl->tree_lock);
 
 	/* Just to make sure we have enough space */
-	prealloc += 8 * PAGE_CACHE_SIZE;
+	prealloc += 8 * PAGE_SIZE;
 
 	ret = btrfs_delalloc_reserve_space(inode, 0, prealloc);
 	if (ret)
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index d96f5cf38a2d..ad15bbfc5003 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -194,7 +194,7 @@ static int insert_inline_extent(struct btrfs_trans_handle *trans,
 		while (compressed_size > 0) {
 			cpage = compressed_pages[i];
 			cur_size = min_t(unsigned long, compressed_size,
-				       PAGE_CACHE_SIZE);
+				       PAGE_SIZE);
 
 			kaddr = kmap_atomic(cpage);
 			write_extent_buffer(leaf, kaddr, ptr, cur_size);
@@ -208,13 +208,13 @@ static int insert_inline_extent(struct btrfs_trans_handle *trans,
 						  compress_type);
 	} else {
 		page = find_get_page(inode->i_mapping,
-				     start >> PAGE_CACHE_SHIFT);
+				     start >> PAGE_SHIFT);
 		btrfs_set_file_extent_compression(leaf, ei, 0);
 		kaddr = kmap_atomic(page);
-		offset = start & (PAGE_CACHE_SIZE - 1);
+		offset = start & (PAGE_SIZE - 1);
 		write_extent_buffer(leaf, kaddr + offset, ptr, size);
 		kunmap_atomic(kaddr);
-		page_cache_release(page);
+		put_page(page);
 	}
 	btrfs_mark_buffer_dirty(leaf);
 	btrfs_release_path(path);
@@ -263,7 +263,7 @@ static noinline int cow_file_range_inline(struct btrfs_root *root,
 		data_len = compressed_size;
 
 	if (start > 0 ||
-	    actual_end > PAGE_CACHE_SIZE ||
+	    actual_end > PAGE_SIZE ||
 	    data_len > BTRFS_MAX_INLINE_DATA_SIZE(root) ||
 	    (!compressed_size &&
 	    (actual_end & (root->sectorsize - 1)) == 0) ||
@@ -322,7 +322,7 @@ out:
 	 * And at reserve time, it's always aligned to page size, so
 	 * just free one page here.
 	 */
-	btrfs_qgroup_free_data(inode, 0, PAGE_CACHE_SIZE);
+	btrfs_qgroup_free_data(inode, 0, PAGE_SIZE);
 	btrfs_free_path(path);
 	btrfs_end_transaction(trans, root);
 	return ret;
@@ -435,8 +435,8 @@ static noinline void compress_file_range(struct inode *inode,
 	actual_end = min_t(u64, isize, end + 1);
 again:
 	will_compress = 0;
-	nr_pages = (end >> PAGE_CACHE_SHIFT) - (start >> PAGE_CACHE_SHIFT) + 1;
-	nr_pages = min_t(unsigned long, nr_pages, SZ_128K / PAGE_CACHE_SIZE);
+	nr_pages = (end >> PAGE_SHIFT) - (start >> PAGE_SHIFT) + 1;
+	nr_pages = min_t(unsigned long, nr_pages, SZ_128K / PAGE_SIZE);
 
 	/*
 	 * we don't want to send crud past the end of i_size through
@@ -514,7 +514,7 @@ again:
 
 		if (!ret) {
 			unsigned long offset = total_compressed &
-				(PAGE_CACHE_SIZE - 1);
+				(PAGE_SIZE - 1);
 			struct page *page = pages[nr_pages_ret - 1];
 			char *kaddr;
 
@@ -524,7 +524,7 @@ again:
 			if (offset) {
 				kaddr = kmap_atomic(page);
 				memset(kaddr + offset, 0,
-				       PAGE_CACHE_SIZE - offset);
+				       PAGE_SIZE - offset);
 				kunmap_atomic(kaddr);
 			}
 			will_compress = 1;
@@ -580,7 +580,7 @@ cont:
 		 * one last check to make sure the compression is really a
 		 * win, compare the page count read with the blocks on disk
 		 */
-		total_in = ALIGN(total_in, PAGE_CACHE_SIZE);
+		total_in = ALIGN(total_in, PAGE_SIZE);
 		if (total_compressed >= total_in) {
 			will_compress = 0;
 		} else {
@@ -594,7 +594,7 @@ cont:
 		 */
 		for (i = 0; i < nr_pages_ret; i++) {
 			WARN_ON(pages[i]->mapping);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 		kfree(pages);
 		pages = NULL;
@@ -650,7 +650,7 @@ cleanup_and_bail_uncompressed:
 free_pages_out:
 	for (i = 0; i < nr_pages_ret; i++) {
 		WARN_ON(pages[i]->mapping);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 	kfree(pages);
 }
@@ -664,7 +664,7 @@ static void free_async_extent_pages(struct async_extent *async_extent)
 
 	for (i = 0; i < async_extent->nr_pages; i++) {
 		WARN_ON(async_extent->pages[i]->mapping);
-		page_cache_release(async_extent->pages[i]);
+		put_page(async_extent->pages[i]);
 	}
 	kfree(async_extent->pages);
 	async_extent->nr_pages = 0;
@@ -966,7 +966,7 @@ static noinline int cow_file_range(struct inode *inode,
 				     PAGE_END_WRITEBACK);
 
 			*nr_written = *nr_written +
-			     (end - start + PAGE_CACHE_SIZE) / PAGE_CACHE_SIZE;
+			     (end - start + PAGE_SIZE) / PAGE_SIZE;
 			*page_started = 1;
 			goto out;
 		} else if (ret < 0) {
@@ -1106,8 +1106,8 @@ static noinline void async_cow_submit(struct btrfs_work *work)
 	async_cow = container_of(work, struct async_cow, work);
 
 	root = async_cow->root;
-	nr_pages = (async_cow->end - async_cow->start + PAGE_CACHE_SIZE) >>
-		PAGE_CACHE_SHIFT;
+	nr_pages = (async_cow->end - async_cow->start + PAGE_SIZE) >>
+		PAGE_SHIFT;
 
 	/*
 	 * atomic_sub_return implies a barrier for waitqueue_active
@@ -1164,8 +1164,8 @@ static int cow_file_range_async(struct inode *inode, struct page *locked_page,
 				async_cow_start, async_cow_submit,
 				async_cow_free);
 
-		nr_pages = (cur_end - start + PAGE_CACHE_SIZE) >>
-			PAGE_CACHE_SHIFT;
+		nr_pages = (cur_end - start + PAGE_SIZE) >>
+			PAGE_SHIFT;
 		atomic_add(nr_pages, &root->fs_info->async_delalloc_pages);
 
 		btrfs_queue_work(root->fs_info->delalloc_workers,
@@ -1960,7 +1960,7 @@ static noinline int add_pending_csums(struct btrfs_trans_handle *trans,
 int btrfs_set_extent_delalloc(struct inode *inode, u64 start, u64 end,
 			      struct extent_state **cached_state)
 {
-	WARN_ON((end & (PAGE_CACHE_SIZE - 1)) == 0);
+	WARN_ON((end & (PAGE_SIZE - 1)) == 0);
 	return set_extent_delalloc(&BTRFS_I(inode)->io_tree, start, end,
 				   cached_state, GFP_NOFS);
 }
@@ -1993,7 +1993,7 @@ again:
 
 	inode = page->mapping->host;
 	page_start = page_offset(page);
-	page_end = page_offset(page) + PAGE_CACHE_SIZE - 1;
+	page_end = page_offset(page) + PAGE_SIZE - 1;
 
 	lock_extent_bits(&BTRFS_I(inode)->io_tree, page_start, page_end,
 			 &cached_state);
@@ -2013,7 +2013,7 @@ again:
 	}
 
 	ret = btrfs_delalloc_reserve_space(inode, page_start,
-					   PAGE_CACHE_SIZE);
+					   PAGE_SIZE);
 	if (ret) {
 		mapping_set_error(page->mapping, ret);
 		end_extent_writepage(page, ret, page_start, page_end);
@@ -2029,7 +2029,7 @@ out:
 			     &cached_state, GFP_NOFS);
 out_page:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	kfree(fixup);
 }
 
@@ -2062,7 +2062,7 @@ static int btrfs_writepage_start_hook(struct page *page, u64 start, u64 end)
 		return -EAGAIN;
 
 	SetPageChecked(page);
-	page_cache_get(page);
+	get_page(page);
 	btrfs_init_work(&fixup->work, btrfs_fixup_helper,
 			btrfs_writepage_fixup_worker, NULL, NULL);
 	fixup->page = page;
@@ -4236,7 +4236,7 @@ static int truncate_inline_extent(struct inode *inode,
 
 	if (btrfs_file_extent_compression(leaf, fi) != BTRFS_COMPRESS_NONE) {
 		loff_t offset = new_size;
-		loff_t page_end = ALIGN(offset, PAGE_CACHE_SIZE);
+		loff_t page_end = ALIGN(offset, PAGE_SIZE);
 
 		/*
 		 * Zero out the remaining of the last page of our inline extent,
@@ -4621,8 +4621,8 @@ int btrfs_truncate_page(struct inode *inode, loff_t from, loff_t len,
 	struct extent_state *cached_state = NULL;
 	char *kaddr;
 	u32 blocksize = root->sectorsize;
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	struct page *page;
 	gfp_t mask = btrfs_alloc_write_mask(mapping);
 	int ret = 0;
@@ -4633,7 +4633,7 @@ int btrfs_truncate_page(struct inode *inode, loff_t from, loff_t len,
 	    (!len || ((len & (blocksize - 1)) == 0)))
 		goto out;
 	ret = btrfs_delalloc_reserve_space(inode,
-			round_down(from, PAGE_CACHE_SIZE), PAGE_CACHE_SIZE);
+			round_down(from, PAGE_SIZE), PAGE_SIZE);
 	if (ret)
 		goto out;
 
@@ -4641,21 +4641,21 @@ again:
 	page = find_or_create_page(mapping, index, mask);
 	if (!page) {
 		btrfs_delalloc_release_space(inode,
-				round_down(from, PAGE_CACHE_SIZE),
-				PAGE_CACHE_SIZE);
+				round_down(from, PAGE_SIZE),
+				PAGE_SIZE);
 		ret = -ENOMEM;
 		goto out;
 	}
 
 	page_start = page_offset(page);
-	page_end = page_start + PAGE_CACHE_SIZE - 1;
+	page_end = page_start + PAGE_SIZE - 1;
 
 	if (!PageUptodate(page)) {
 		ret = btrfs_readpage(NULL, page);
 		lock_page(page);
 		if (page->mapping != mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto again;
 		}
 		if (!PageUptodate(page)) {
@@ -4673,7 +4673,7 @@ again:
 		unlock_extent_cached(io_tree, page_start, page_end,
 				     &cached_state, GFP_NOFS);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		btrfs_start_ordered_extent(inode, ordered, 1);
 		btrfs_put_ordered_extent(ordered);
 		goto again;
@@ -4692,9 +4692,9 @@ again:
 		goto out_unlock;
 	}
 
-	if (offset != PAGE_CACHE_SIZE) {
+	if (offset != PAGE_SIZE) {
 		if (!len)
-			len = PAGE_CACHE_SIZE - offset;
+			len = PAGE_SIZE - offset;
 		kaddr = kmap(page);
 		if (front)
 			memset(kaddr, 0, offset);
@@ -4711,9 +4711,9 @@ again:
 out_unlock:
 	if (ret)
 		btrfs_delalloc_release_space(inode, page_start,
-					     PAGE_CACHE_SIZE);
+					     PAGE_SIZE);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out:
 	return ret;
 }
@@ -6701,7 +6701,7 @@ static noinline int uncompress_inline(struct btrfs_path *path,
 
 	read_extent_buffer(leaf, tmp, ptr, inline_size);
 
-	max_size = min_t(unsigned long, PAGE_CACHE_SIZE, max_size);
+	max_size = min_t(unsigned long, PAGE_SIZE, max_size);
 	ret = btrfs_decompress(compress_type, tmp, page,
 			       extent_offset, inline_size, max_size);
 	kfree(tmp);
@@ -6863,8 +6863,8 @@ next:
 
 		size = btrfs_file_extent_inline_len(leaf, path->slots[0], item);
 		extent_offset = page_offset(page) + pg_offset - extent_start;
-		copy_size = min_t(u64, PAGE_CACHE_SIZE - pg_offset,
-				size - extent_offset);
+		copy_size = min_t(u64, PAGE_SIZE - pg_offset,
+				  size - extent_offset);
 		em->start = extent_start + extent_offset;
 		em->len = ALIGN(copy_size, root->sectorsize);
 		em->orig_block_len = em->len;
@@ -6883,9 +6883,9 @@ next:
 				map = kmap(page);
 				read_extent_buffer(leaf, map + pg_offset, ptr,
 						   copy_size);
-				if (pg_offset + copy_size < PAGE_CACHE_SIZE) {
+				if (pg_offset + copy_size < PAGE_SIZE) {
 					memset(map + pg_offset + copy_size, 0,
-					       PAGE_CACHE_SIZE - pg_offset -
+					       PAGE_SIZE - pg_offset -
 					       copy_size);
 				}
 				kunmap(page);
@@ -7320,12 +7320,12 @@ bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
 	int start_idx;
 	int end_idx;
 
-	start_idx = start >> PAGE_CACHE_SHIFT;
+	start_idx = start >> PAGE_SHIFT;
 
 	/*
 	 * end is the last byte in the last page.  end == start is legal
 	 */
-	end_idx = end >> PAGE_CACHE_SHIFT;
+	end_idx = end >> PAGE_SHIFT;
 
 	rcu_read_lock();
 
@@ -7366,7 +7366,7 @@ bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
 		 * include/linux/pagemap.h for details.
 		 */
 		if (unlikely(page != *pagep)) {
-			page_cache_release(page);
+			put_page(page);
 			page = NULL;
 		}
 	}
@@ -7374,7 +7374,7 @@ bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
 	if (page) {
 		if (page->index <= end_idx)
 			found = true;
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	rcu_read_unlock();
@@ -8621,7 +8621,7 @@ static int __btrfs_releasepage(struct page *page, gfp_t gfp_flags)
 	if (ret == 1) {
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return ret;
 }
@@ -8641,7 +8641,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 	struct btrfs_ordered_extent *ordered;
 	struct extent_state *cached_state = NULL;
 	u64 page_start = page_offset(page);
-	u64 page_end = page_start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = page_start + PAGE_SIZE - 1;
 	int inode_evicting = inode->i_state & I_FREEING;
 
 	/*
@@ -8692,7 +8692,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 
 			if (btrfs_dec_test_ordered_pending(inode, &ordered,
 							   page_start,
-							   PAGE_CACHE_SIZE, 1))
+							   PAGE_SIZE, 1))
 				btrfs_finish_ordered_io(ordered);
 		}
 		btrfs_put_ordered_extent(ordered);
@@ -8714,7 +8714,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 	 * 2) Not written to disk
 	 *    This means the reserved space should be freed here.
 	 */
-	btrfs_qgroup_free_data(inode, page_start, PAGE_CACHE_SIZE);
+	btrfs_qgroup_free_data(inode, page_start, PAGE_SIZE);
 	if (!inode_evicting) {
 		clear_extent_bit(tree, page_start, page_end,
 				 EXTENT_LOCKED | EXTENT_DIRTY |
@@ -8729,7 +8729,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
@@ -8766,10 +8766,10 @@ int btrfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	sb_start_pagefault(inode->i_sb);
 	page_start = page_offset(page);
-	page_end = page_start + PAGE_CACHE_SIZE - 1;
+	page_end = page_start + PAGE_SIZE - 1;
 
 	ret = btrfs_delalloc_reserve_space(inode, page_start,
-					   PAGE_CACHE_SIZE);
+					   PAGE_SIZE);
 	if (!ret) {
 		ret = file_update_time(vma->vm_file);
 		reserved = 1;
@@ -8836,14 +8836,14 @@ again:
 	ret = 0;
 
 	/* page is wholly or partially inside EOF */
-	if (page_start + PAGE_CACHE_SIZE > size)
-		zero_start = size & ~PAGE_CACHE_MASK;
+	if (page_start + PAGE_SIZE > size)
+		zero_start = size & ~PAGE_MASK;
 	else
-		zero_start = PAGE_CACHE_SIZE;
+		zero_start = PAGE_SIZE;
 
-	if (zero_start != PAGE_CACHE_SIZE) {
+	if (zero_start != PAGE_SIZE) {
 		kaddr = kmap(page);
-		memset(kaddr + zero_start, 0, PAGE_CACHE_SIZE - zero_start);
+		memset(kaddr + zero_start, 0, PAGE_SIZE - zero_start);
 		flush_dcache_page(page);
 		kunmap(page);
 	}
@@ -8864,7 +8864,7 @@ out_unlock:
 	}
 	unlock_page(page);
 out:
-	btrfs_delalloc_release_space(inode, page_start, PAGE_CACHE_SIZE);
+	btrfs_delalloc_release_space(inode, page_start, PAGE_SIZE);
 out_noreserve:
 	sb_end_pagefault(inode->i_sb);
 	return ret;
@@ -9250,7 +9250,7 @@ static int btrfs_getattr(struct vfsmount *mnt,
 
 	generic_fillattr(inode, stat);
 	stat->dev = BTRFS_I(inode)->root->anon_dev;
-	stat->blksize = PAGE_CACHE_SIZE;
+	stat->blksize = PAGE_SIZE;
 
 	spin_lock(&BTRFS_I(inode)->lock);
 	delalloc_bytes = BTRFS_I(inode)->delalloc_bytes;
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 48aee9846329..095a135ef6a2 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -900,7 +900,7 @@ static int check_defrag_in_cache(struct inode *inode, u64 offset, u32 thresh)
 	u64 end;
 
 	read_lock(&em_tree->lock);
-	em = lookup_extent_mapping(em_tree, offset, PAGE_CACHE_SIZE);
+	em = lookup_extent_mapping(em_tree, offset, PAGE_SIZE);
 	read_unlock(&em_tree->lock);
 
 	if (em) {
@@ -990,7 +990,7 @@ static struct extent_map *defrag_lookup_extent(struct inode *inode, u64 start)
 	struct extent_map_tree *em_tree = &BTRFS_I(inode)->extent_tree;
 	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
 	struct extent_map *em;
-	u64 len = PAGE_CACHE_SIZE;
+	u64 len = PAGE_SIZE;
 
 	/*
 	 * hopefully we have this extent in the tree already, try without
@@ -1126,15 +1126,15 @@ static int cluster_pages_for_defrag(struct inode *inode,
 	struct extent_io_tree *tree;
 	gfp_t mask = btrfs_alloc_write_mask(inode->i_mapping);
 
-	file_end = (isize - 1) >> PAGE_CACHE_SHIFT;
+	file_end = (isize - 1) >> PAGE_SHIFT;
 	if (!isize || start_index > file_end)
 		return 0;
 
 	page_cnt = min_t(u64, (u64)num_pages, (u64)file_end - start_index + 1);
 
 	ret = btrfs_delalloc_reserve_space(inode,
-			start_index << PAGE_CACHE_SHIFT,
-			page_cnt << PAGE_CACHE_SHIFT);
+			start_index << PAGE_SHIFT,
+			page_cnt << PAGE_SHIFT);
 	if (ret)
 		return ret;
 	i_done = 0;
@@ -1150,7 +1150,7 @@ again:
 			break;
 
 		page_start = page_offset(page);
-		page_end = page_start + PAGE_CACHE_SIZE - 1;
+		page_end = page_start + PAGE_SIZE - 1;
 		while (1) {
 			lock_extent_bits(tree, page_start, page_end,
 					 &cached_state);
@@ -1171,7 +1171,7 @@ again:
 			 */
 			if (page->mapping != inode->i_mapping) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				goto again;
 			}
 		}
@@ -1181,7 +1181,7 @@ again:
 			lock_page(page);
 			if (!PageUptodate(page)) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				ret = -EIO;
 				break;
 			}
@@ -1189,7 +1189,7 @@ again:
 
 		if (page->mapping != inode->i_mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto again;
 		}
 
@@ -1210,7 +1210,7 @@ again:
 		wait_on_page_writeback(pages[i]);
 
 	page_start = page_offset(pages[0]);
-	page_end = page_offset(pages[i_done - 1]) + PAGE_CACHE_SIZE;
+	page_end = page_offset(pages[i_done - 1]) + PAGE_SIZE;
 
 	lock_extent_bits(&BTRFS_I(inode)->io_tree,
 			 page_start, page_end - 1, &cached_state);
@@ -1224,8 +1224,8 @@ again:
 		BTRFS_I(inode)->outstanding_extents++;
 		spin_unlock(&BTRFS_I(inode)->lock);
 		btrfs_delalloc_release_space(inode,
-				start_index << PAGE_CACHE_SHIFT,
-				(page_cnt - i_done) << PAGE_CACHE_SHIFT);
+				start_index << PAGE_SHIFT,
+				(page_cnt - i_done) << PAGE_SHIFT);
 	}
 
 
@@ -1242,17 +1242,17 @@ again:
 		set_page_extent_mapped(pages[i]);
 		set_page_dirty(pages[i]);
 		unlock_page(pages[i]);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 	return i_done;
 out:
 	for (i = 0; i < i_done; i++) {
 		unlock_page(pages[i]);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 	btrfs_delalloc_release_space(inode,
-			start_index << PAGE_CACHE_SHIFT,
-			page_cnt << PAGE_CACHE_SHIFT);
+			start_index << PAGE_SHIFT,
+			page_cnt << PAGE_SHIFT);
 	return ret;
 
 }
@@ -1275,7 +1275,7 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 	int defrag_count = 0;
 	int compress_type = BTRFS_COMPRESS_ZLIB;
 	u32 extent_thresh = range->extent_thresh;
-	unsigned long max_cluster = SZ_256K >> PAGE_CACHE_SHIFT;
+	unsigned long max_cluster = SZ_256K >> PAGE_SHIFT;
 	unsigned long cluster = max_cluster;
 	u64 new_align = ~((u64)SZ_128K - 1);
 	struct page **pages = NULL;
@@ -1319,9 +1319,9 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 	/* find the last page to defrag */
 	if (range->start + range->len > range->start) {
 		last_index = min_t(u64, isize - 1,
-			 range->start + range->len - 1) >> PAGE_CACHE_SHIFT;
+			 range->start + range->len - 1) >> PAGE_SHIFT;
 	} else {
-		last_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		last_index = (isize - 1) >> PAGE_SHIFT;
 	}
 
 	if (newer_than) {
@@ -1333,11 +1333,11 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 			 * we always align our defrag to help keep
 			 * the extents in the file evenly spaced
 			 */
-			i = (newer_off & new_align) >> PAGE_CACHE_SHIFT;
+			i = (newer_off & new_align) >> PAGE_SHIFT;
 		} else
 			goto out_ra;
 	} else {
-		i = range->start >> PAGE_CACHE_SHIFT;
+		i = range->start >> PAGE_SHIFT;
 	}
 	if (!max_to_defrag)
 		max_to_defrag = last_index - i + 1;
@@ -1350,7 +1350,7 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 		inode->i_mapping->writeback_index = i;
 
 	while (i <= last_index && defrag_count < max_to_defrag &&
-	       (i < DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE))) {
+	       (i < DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE))) {
 		/*
 		 * make sure we stop running if someone unmounts
 		 * the FS
@@ -1364,7 +1364,7 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 			break;
 		}
 
-		if (!should_defrag_range(inode, (u64)i << PAGE_CACHE_SHIFT,
+		if (!should_defrag_range(inode, (u64)i << PAGE_SHIFT,
 					 extent_thresh, &last_len, &skip,
 					 &defrag_end, range->flags &
 					 BTRFS_DEFRAG_RANGE_COMPRESS)) {
@@ -1373,14 +1373,14 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 			 * the should_defrag function tells us how much to skip
 			 * bump our counter by the suggested amount
 			 */
-			next = DIV_ROUND_UP(skip, PAGE_CACHE_SIZE);
+			next = DIV_ROUND_UP(skip, PAGE_SIZE);
 			i = max(i + 1, next);
 			continue;
 		}
 
 		if (!newer_than) {
-			cluster = (PAGE_CACHE_ALIGN(defrag_end) >>
-				   PAGE_CACHE_SHIFT) - i;
+			cluster = (PAGE_ALIGN(defrag_end) >>
+				   PAGE_SHIFT) - i;
 			cluster = min(cluster, max_cluster);
 		} else {
 			cluster = max_cluster;
@@ -1414,20 +1414,20 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 				i += ret;
 
 			newer_off = max(newer_off + 1,
-					(u64)i << PAGE_CACHE_SHIFT);
+					(u64)i << PAGE_SHIFT);
 
 			ret = find_new_extents(root, inode, newer_than,
 					       &newer_off, SZ_64K);
 			if (!ret) {
 				range->start = newer_off;
-				i = (newer_off & new_align) >> PAGE_CACHE_SHIFT;
+				i = (newer_off & new_align) >> PAGE_SHIFT;
 			} else {
 				break;
 			}
 		} else {
 			if (ret > 0) {
 				i += ret;
-				last_len += ret << PAGE_CACHE_SHIFT;
+				last_len += ret << PAGE_SHIFT;
 			} else {
 				i++;
 				last_len = 0;
@@ -1724,7 +1724,7 @@ static noinline int btrfs_ioctl_snap_create_v2(struct file *file,
 	if (vol_args->flags & BTRFS_SUBVOL_RDONLY)
 		readonly = true;
 	if (vol_args->flags & BTRFS_SUBVOL_QGROUP_INHERIT) {
-		if (vol_args->size > PAGE_CACHE_SIZE) {
+		if (vol_args->size > PAGE_SIZE) {
 			ret = -EINVAL;
 			goto free_args;
 		}
@@ -2808,12 +2808,12 @@ static struct page *extent_same_get_page(struct inode *inode, pgoff_t index)
 		lock_page(page);
 		if (!PageUptodate(page)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			return ERR_PTR(-EIO);
 		}
 		if (page->mapping != inode->i_mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			return ERR_PTR(-EAGAIN);
 		}
 	}
@@ -2825,7 +2825,7 @@ static int gather_extent_pages(struct inode *inode, struct page **pages,
 			       int num_pages, u64 off)
 {
 	int i;
-	pgoff_t index = off >> PAGE_CACHE_SHIFT;
+	pgoff_t index = off >> PAGE_SHIFT;
 
 	for (i = 0; i < num_pages; i++) {
 again:
@@ -2934,12 +2934,12 @@ static void btrfs_cmp_data_free(struct cmp_pages *cmp)
 		pg = cmp->src_pages[i];
 		if (pg) {
 			unlock_page(pg);
-			page_cache_release(pg);
+			put_page(pg);
 		}
 		pg = cmp->dst_pages[i];
 		if (pg) {
 			unlock_page(pg);
-			page_cache_release(pg);
+			put_page(pg);
 		}
 	}
 	kfree(cmp->src_pages);
@@ -2951,7 +2951,7 @@ static int btrfs_cmp_data_prepare(struct inode *src, u64 loff,
 				  u64 len, struct cmp_pages *cmp)
 {
 	int ret;
-	int num_pages = PAGE_CACHE_ALIGN(len) >> PAGE_CACHE_SHIFT;
+	int num_pages = PAGE_ALIGN(len) >> PAGE_SHIFT;
 	struct page **src_pgarr, **dst_pgarr;
 
 	/*
@@ -2989,12 +2989,12 @@ static int btrfs_cmp_data(struct inode *src, u64 loff, struct inode *dst,
 	int ret = 0;
 	int i;
 	struct page *src_page, *dst_page;
-	unsigned int cmp_len = PAGE_CACHE_SIZE;
+	unsigned int cmp_len = PAGE_SIZE;
 	void *addr, *dst_addr;
 
 	i = 0;
 	while (len) {
-		if (len < PAGE_CACHE_SIZE)
+		if (len < PAGE_SIZE)
 			cmp_len = len;
 
 		BUG_ON(i >= cmp->num_pages);
@@ -3190,7 +3190,7 @@ ssize_t btrfs_dedupe_file_range(struct file *src_file, u64 loff, u64 olen,
 	if (olen > BTRFS_MAX_DEDUPE_LEN)
 		olen = BTRFS_MAX_DEDUPE_LEN;
 
-	if (WARN_ON_ONCE(bs < PAGE_CACHE_SIZE)) {
+	if (WARN_ON_ONCE(bs < PAGE_SIZE)) {
 		/*
 		 * Btrfs does not support blocksize < page_size. As a
 		 * result, btrfs_cmp_data() won't correctly handle
@@ -3890,7 +3890,7 @@ static noinline int btrfs_clone_files(struct file *file, struct file *file_src,
 	 * data immediately and not the previous data.
 	 */
 	truncate_inode_pages_range(&inode->i_data, destoff,
-				   PAGE_CACHE_ALIGN(destoff + len) - 1);
+				   PAGE_ALIGN(destoff + len) - 1);
 out_unlock:
 	if (!same_inode)
 		btrfs_double_inode_unlock(src, inode);
@@ -4122,7 +4122,7 @@ static long btrfs_ioctl_space_info(struct btrfs_root *root, void __user *arg)
 	/* we generally have at most 6 or so space infos, one for each raid
 	 * level.  So, a whole page should be more than enough for everyone
 	 */
-	if (alloc_size > PAGE_CACHE_SIZE)
+	if (alloc_size > PAGE_SIZE)
 		return -ENOMEM;
 
 	space_args.total_spaces = 0;
diff --git a/fs/btrfs/lzo.c b/fs/btrfs/lzo.c
index a2f051347731..1adfbe7be6b8 100644
--- a/fs/btrfs/lzo.c
+++ b/fs/btrfs/lzo.c
@@ -55,8 +55,8 @@ static struct list_head *lzo_alloc_workspace(void)
 		return ERR_PTR(-ENOMEM);
 
 	workspace->mem = vmalloc(LZO1X_MEM_COMPRESS);
-	workspace->buf = vmalloc(lzo1x_worst_compress(PAGE_CACHE_SIZE));
-	workspace->cbuf = vmalloc(lzo1x_worst_compress(PAGE_CACHE_SIZE));
+	workspace->buf = vmalloc(lzo1x_worst_compress(PAGE_SIZE));
+	workspace->cbuf = vmalloc(lzo1x_worst_compress(PAGE_SIZE));
 	if (!workspace->mem || !workspace->buf || !workspace->cbuf)
 		goto fail;
 
@@ -116,7 +116,7 @@ static int lzo_compress_pages(struct list_head *ws,
 	*total_out = 0;
 	*total_in = 0;
 
-	in_page = find_get_page(mapping, start >> PAGE_CACHE_SHIFT);
+	in_page = find_get_page(mapping, start >> PAGE_SHIFT);
 	data_in = kmap(in_page);
 
 	/*
@@ -133,10 +133,10 @@ static int lzo_compress_pages(struct list_head *ws,
 	tot_out = LZO_LEN;
 	pages[0] = out_page;
 	nr_pages = 1;
-	pg_bytes_left = PAGE_CACHE_SIZE - LZO_LEN;
+	pg_bytes_left = PAGE_SIZE - LZO_LEN;
 
 	/* compress at most one page of data each time */
-	in_len = min(len, PAGE_CACHE_SIZE);
+	in_len = min(len, PAGE_SIZE);
 	while (tot_in < len) {
 		ret = lzo1x_1_compress(data_in, in_len, workspace->cbuf,
 				       &out_len, workspace->mem);
@@ -201,7 +201,7 @@ static int lzo_compress_pages(struct list_head *ws,
 				cpage_out = kmap(out_page);
 				pages[nr_pages++] = out_page;
 
-				pg_bytes_left = PAGE_CACHE_SIZE;
+				pg_bytes_left = PAGE_SIZE;
 				out_offset = 0;
 			}
 		}
@@ -221,12 +221,12 @@ static int lzo_compress_pages(struct list_head *ws,
 
 		bytes_left = len - tot_in;
 		kunmap(in_page);
-		page_cache_release(in_page);
+		put_page(in_page);
 
-		start += PAGE_CACHE_SIZE;
-		in_page = find_get_page(mapping, start >> PAGE_CACHE_SHIFT);
+		start += PAGE_SIZE;
+		in_page = find_get_page(mapping, start >> PAGE_SHIFT);
 		data_in = kmap(in_page);
-		in_len = min(bytes_left, PAGE_CACHE_SIZE);
+		in_len = min(bytes_left, PAGE_SIZE);
 	}
 
 	if (tot_out > tot_in)
@@ -248,7 +248,7 @@ out:
 
 	if (in_page) {
 		kunmap(in_page);
-		page_cache_release(in_page);
+		put_page(in_page);
 	}
 
 	return ret;
@@ -266,7 +266,7 @@ static int lzo_decompress_biovec(struct list_head *ws,
 	char *data_in;
 	unsigned long page_in_index = 0;
 	unsigned long page_out_index = 0;
-	unsigned long total_pages_in = DIV_ROUND_UP(srclen, PAGE_CACHE_SIZE);
+	unsigned long total_pages_in = DIV_ROUND_UP(srclen, PAGE_SIZE);
 	unsigned long buf_start;
 	unsigned long buf_offset = 0;
 	unsigned long bytes;
@@ -289,7 +289,7 @@ static int lzo_decompress_biovec(struct list_head *ws,
 	tot_in = LZO_LEN;
 	in_offset = LZO_LEN;
 	tot_len = min_t(size_t, srclen, tot_len);
-	in_page_bytes_left = PAGE_CACHE_SIZE - LZO_LEN;
+	in_page_bytes_left = PAGE_SIZE - LZO_LEN;
 
 	tot_out = 0;
 	pg_offset = 0;
@@ -345,12 +345,12 @@ cont:
 
 				data_in = kmap(pages_in[++page_in_index]);
 
-				in_page_bytes_left = PAGE_CACHE_SIZE;
+				in_page_bytes_left = PAGE_SIZE;
 				in_offset = 0;
 			}
 		}
 
-		out_len = lzo1x_worst_compress(PAGE_CACHE_SIZE);
+		out_len = lzo1x_worst_compress(PAGE_SIZE);
 		ret = lzo1x_decompress_safe(buf, in_len, workspace->buf,
 					    &out_len);
 		if (need_unmap)
@@ -399,7 +399,7 @@ static int lzo_decompress(struct list_head *ws, unsigned char *data_in,
 	in_len = read_compress_length(data_in);
 	data_in += LZO_LEN;
 
-	out_len = PAGE_CACHE_SIZE;
+	out_len = PAGE_SIZE;
 	ret = lzo1x_decompress_safe(data_in, in_len, workspace->buf, &out_len);
 	if (ret != LZO_E_OK) {
 		printk(KERN_WARNING "BTRFS: decompress failed!\n");
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index 55161369fab1..0b7792e02dd5 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -270,7 +270,7 @@ static void cache_rbio_pages(struct btrfs_raid_bio *rbio)
 		s = kmap(rbio->bio_pages[i]);
 		d = kmap(rbio->stripe_pages[i]);
 
-		memcpy(d, s, PAGE_CACHE_SIZE);
+		memcpy(d, s, PAGE_SIZE);
 
 		kunmap(rbio->bio_pages[i]);
 		kunmap(rbio->stripe_pages[i]);
@@ -962,7 +962,7 @@ static struct page *page_in_rbio(struct btrfs_raid_bio *rbio,
  */
 static unsigned long rbio_nr_pages(unsigned long stripe_len, int nr_stripes)
 {
-	return DIV_ROUND_UP(stripe_len, PAGE_CACHE_SIZE) * nr_stripes;
+	return DIV_ROUND_UP(stripe_len, PAGE_SIZE) * nr_stripes;
 }
 
 /*
@@ -1078,7 +1078,7 @@ static int rbio_add_io_page(struct btrfs_raid_bio *rbio,
 	u64 disk_start;
 
 	stripe = &rbio->bbio->stripes[stripe_nr];
-	disk_start = stripe->physical + (page_index << PAGE_CACHE_SHIFT);
+	disk_start = stripe->physical + (page_index << PAGE_SHIFT);
 
 	/* if the device is missing, just fail this stripe */
 	if (!stripe->dev->bdev)
@@ -1096,8 +1096,8 @@ static int rbio_add_io_page(struct btrfs_raid_bio *rbio,
 		if (last_end == disk_start && stripe->dev->bdev &&
 		    !last->bi_error &&
 		    last->bi_bdev == stripe->dev->bdev) {
-			ret = bio_add_page(last, page, PAGE_CACHE_SIZE, 0);
-			if (ret == PAGE_CACHE_SIZE)
+			ret = bio_add_page(last, page, PAGE_SIZE, 0);
+			if (ret == PAGE_SIZE)
 				return 0;
 		}
 	}
@@ -1111,7 +1111,7 @@ static int rbio_add_io_page(struct btrfs_raid_bio *rbio,
 	bio->bi_bdev = stripe->dev->bdev;
 	bio->bi_iter.bi_sector = disk_start >> 9;
 
-	bio_add_page(bio, page, PAGE_CACHE_SIZE, 0);
+	bio_add_page(bio, page, PAGE_SIZE, 0);
 	bio_list_add(bio_list, bio);
 	return 0;
 }
@@ -1154,7 +1154,7 @@ static void index_rbio_pages(struct btrfs_raid_bio *rbio)
 	bio_list_for_each(bio, &rbio->bio_list) {
 		start = (u64)bio->bi_iter.bi_sector << 9;
 		stripe_offset = start - rbio->bbio->raid_map[0];
-		page_index = stripe_offset >> PAGE_CACHE_SHIFT;
+		page_index = stripe_offset >> PAGE_SHIFT;
 
 		for (i = 0; i < bio->bi_vcnt; i++) {
 			p = bio->bi_io_vec[i].bv_page;
@@ -1253,7 +1253,7 @@ static noinline void finish_rmw(struct btrfs_raid_bio *rbio)
 		} else {
 			/* raid5 */
 			memcpy(pointers[nr_data], pointers[0], PAGE_SIZE);
-			run_xor(pointers + 1, nr_data - 1, PAGE_CACHE_SIZE);
+			run_xor(pointers + 1, nr_data - 1, PAGE_SIZE);
 		}
 
 
@@ -1914,7 +1914,7 @@ pstripe:
 			/* Copy parity block into failed block to start with */
 			memcpy(pointers[faila],
 			       pointers[rbio->nr_data],
-			       PAGE_CACHE_SIZE);
+			       PAGE_SIZE);
 
 			/* rearrange the pointer array */
 			p = pointers[faila];
@@ -1923,7 +1923,7 @@ pstripe:
 			pointers[rbio->nr_data - 1] = p;
 
 			/* xor in the rest */
-			run_xor(pointers, rbio->nr_data - 1, PAGE_CACHE_SIZE);
+			run_xor(pointers, rbio->nr_data - 1, PAGE_SIZE);
 		}
 		/* if we're doing this rebuild as part of an rmw, go through
 		 * and set all of our private rbio pages in the
@@ -2250,7 +2250,7 @@ void raid56_add_scrub_pages(struct btrfs_raid_bio *rbio, struct page *page,
 	ASSERT(logical + PAGE_SIZE <= rbio->bbio->raid_map[0] +
 				rbio->stripe_len * rbio->nr_data);
 	stripe_offset = (int)(logical - rbio->bbio->raid_map[0]);
-	index = stripe_offset >> PAGE_CACHE_SHIFT;
+	index = stripe_offset >> PAGE_SHIFT;
 	rbio->bio_pages[index] = page;
 }
 
@@ -2365,14 +2365,14 @@ static noinline void finish_parity_scrub(struct btrfs_raid_bio *rbio,
 		} else {
 			/* raid5 */
 			memcpy(pointers[nr_data], pointers[0], PAGE_SIZE);
-			run_xor(pointers + 1, nr_data - 1, PAGE_CACHE_SIZE);
+			run_xor(pointers + 1, nr_data - 1, PAGE_SIZE);
 		}
 
 		/* Check scrubbing pairty and repair it */
 		p = rbio_stripe_page(rbio, rbio->scrubp, pagenr);
 		parity = kmap(p);
-		if (memcmp(parity, pointers[rbio->scrubp], PAGE_CACHE_SIZE))
-			memcpy(parity, pointers[rbio->scrubp], PAGE_CACHE_SIZE);
+		if (memcmp(parity, pointers[rbio->scrubp], PAGE_SIZE))
+			memcpy(parity, pointers[rbio->scrubp], PAGE_SIZE);
 		else
 			/* Parity is right, needn't writeback */
 			bitmap_clear(rbio->dbitmap, pagenr, 1);
diff --git a/fs/btrfs/reada.c b/fs/btrfs/reada.c
index 619f92963e27..bacc55e2655b 100644
--- a/fs/btrfs/reada.c
+++ b/fs/btrfs/reada.c
@@ -116,7 +116,7 @@ static int __readahead_hook(struct btrfs_root *root, struct extent_buffer *eb,
 	struct reada_extent *re;
 	struct btrfs_fs_info *fs_info = root->fs_info;
 	struct list_head list;
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
 	struct btrfs_device *for_dev;
 
 	if (eb)
@@ -259,7 +259,7 @@ static struct reada_zone *reada_find_zone(struct btrfs_fs_info *fs_info,
 	zone = NULL;
 	spin_lock(&fs_info->reada_lock);
 	ret = radix_tree_gang_lookup(&dev->reada_zones, (void **)&zone,
-				     logical >> PAGE_CACHE_SHIFT, 1);
+				     logical >> PAGE_SHIFT, 1);
 	if (ret == 1)
 		kref_get(&zone->refcnt);
 	spin_unlock(&fs_info->reada_lock);
@@ -300,13 +300,13 @@ static struct reada_zone *reada_find_zone(struct btrfs_fs_info *fs_info,
 
 	spin_lock(&fs_info->reada_lock);
 	ret = radix_tree_insert(&dev->reada_zones,
-				(unsigned long)(zone->end >> PAGE_CACHE_SHIFT),
+				(unsigned long)(zone->end >> PAGE_SHIFT),
 				zone);
 
 	if (ret == -EEXIST) {
 		kfree(zone);
 		ret = radix_tree_gang_lookup(&dev->reada_zones, (void **)&zone,
-					     logical >> PAGE_CACHE_SHIFT, 1);
+					     logical >> PAGE_SHIFT, 1);
 		if (ret == 1)
 			kref_get(&zone->refcnt);
 	}
@@ -331,7 +331,7 @@ static struct reada_extent *reada_find_extent(struct btrfs_root *root,
 	int real_stripes;
 	int nzones = 0;
 	int i;
-	unsigned long index = logical >> PAGE_CACHE_SHIFT;
+	unsigned long index = logical >> PAGE_SHIFT;
 	int dev_replace_is_ongoing;
 
 	spin_lock(&fs_info->reada_lock);
@@ -497,7 +497,7 @@ static void reada_extent_put(struct btrfs_fs_info *fs_info,
 			     struct reada_extent *re)
 {
 	int i;
-	unsigned long index = re->logical >> PAGE_CACHE_SHIFT;
+	unsigned long index = re->logical >> PAGE_SHIFT;
 
 	spin_lock(&fs_info->reada_lock);
 	if (--re->refcnt) {
@@ -542,7 +542,7 @@ static void reada_zone_release(struct kref *kref)
 	struct reada_zone *zone = container_of(kref, struct reada_zone, refcnt);
 
 	radix_tree_delete(&zone->device->reada_zones,
-			  zone->end >> PAGE_CACHE_SHIFT);
+			  zone->end >> PAGE_SHIFT);
 
 	kfree(zone);
 }
@@ -591,7 +591,7 @@ static int reada_add_block(struct reada_control *rc, u64 logical,
 static void reada_peer_zones_set_lock(struct reada_zone *zone, int lock)
 {
 	int i;
-	unsigned long index = zone->end >> PAGE_CACHE_SHIFT;
+	unsigned long index = zone->end >> PAGE_SHIFT;
 
 	for (i = 0; i < zone->ndevs; ++i) {
 		struct reada_zone *peer;
@@ -626,7 +626,7 @@ static int reada_pick_zone(struct btrfs_device *dev)
 					     (void **)&zone, index, 1);
 		if (ret == 0)
 			break;
-		index = (zone->end >> PAGE_CACHE_SHIFT) + 1;
+		index = (zone->end >> PAGE_SHIFT) + 1;
 		if (zone->locked) {
 			if (zone->elems > top_locked_elems) {
 				top_locked_elems = zone->elems;
@@ -678,7 +678,7 @@ static int reada_start_machine_dev(struct btrfs_fs_info *fs_info,
 	 * plugging to speed things up
 	 */
 	ret = radix_tree_gang_lookup(&dev->reada_extents, (void **)&re,
-				     dev->reada_next >> PAGE_CACHE_SHIFT, 1);
+				     dev->reada_next >> PAGE_SHIFT, 1);
 	if (ret == 0 || re->logical >= dev->reada_curr_zone->end) {
 		ret = reada_pick_zone(dev);
 		if (!ret) {
@@ -687,7 +687,7 @@ static int reada_start_machine_dev(struct btrfs_fs_info *fs_info,
 		}
 		re = NULL;
 		ret = radix_tree_gang_lookup(&dev->reada_extents, (void **)&re,
-					dev->reada_next >> PAGE_CACHE_SHIFT, 1);
+					dev->reada_next >> PAGE_SHIFT, 1);
 	}
 	if (ret == 0) {
 		spin_unlock(&fs_info->reada_lock);
@@ -836,7 +836,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 				printk(KERN_CONT " curr off %llu",
 					device->reada_next - zone->start);
 			printk(KERN_CONT "\n");
-			index = (zone->end >> PAGE_CACHE_SHIFT) + 1;
+			index = (zone->end >> PAGE_SHIFT) + 1;
 		}
 		cnt = 0;
 		index = 0;
@@ -863,7 +863,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 				}
 			}
 			printk(KERN_CONT "\n");
-			index = (re->logical >> PAGE_CACHE_SHIFT) + 1;
+			index = (re->logical >> PAGE_SHIFT) + 1;
 			if (++cnt > 15)
 				break;
 		}
@@ -879,7 +879,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 		if (ret == 0)
 			break;
 		if (!re->scheduled_for) {
-			index = (re->logical >> PAGE_CACHE_SHIFT) + 1;
+			index = (re->logical >> PAGE_SHIFT) + 1;
 			continue;
 		}
 		printk(KERN_DEBUG
@@ -902,7 +902,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 			}
 		}
 		printk(KERN_CONT "\n");
-		index = (re->logical >> PAGE_CACHE_SHIFT) + 1;
+		index = (re->logical >> PAGE_SHIFT) + 1;
 	}
 	spin_unlock(&fs_info->reada_lock);
 }
diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
index 2bd0011450df..3c93968b539d 100644
--- a/fs/btrfs/relocation.c
+++ b/fs/btrfs/relocation.c
@@ -3129,10 +3129,10 @@ static int relocate_file_extent_cluster(struct inode *inode,
 	if (ret)
 		goto out;
 
-	index = (cluster->start - offset) >> PAGE_CACHE_SHIFT;
-	last_index = (cluster->end - offset) >> PAGE_CACHE_SHIFT;
+	index = (cluster->start - offset) >> PAGE_SHIFT;
+	last_index = (cluster->end - offset) >> PAGE_SHIFT;
 	while (index <= last_index) {
-		ret = btrfs_delalloc_reserve_metadata(inode, PAGE_CACHE_SIZE);
+		ret = btrfs_delalloc_reserve_metadata(inode, PAGE_SIZE);
 		if (ret)
 			goto out;
 
@@ -3145,7 +3145,7 @@ static int relocate_file_extent_cluster(struct inode *inode,
 						   mask);
 			if (!page) {
 				btrfs_delalloc_release_metadata(inode,
-							PAGE_CACHE_SIZE);
+							PAGE_SIZE);
 				ret = -ENOMEM;
 				goto out;
 			}
@@ -3162,16 +3162,16 @@ static int relocate_file_extent_cluster(struct inode *inode,
 			lock_page(page);
 			if (!PageUptodate(page)) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				btrfs_delalloc_release_metadata(inode,
-							PAGE_CACHE_SIZE);
+							PAGE_SIZE);
 				ret = -EIO;
 				goto out;
 			}
 		}
 
 		page_start = page_offset(page);
-		page_end = page_start + PAGE_CACHE_SIZE - 1;
+		page_end = page_start + PAGE_SIZE - 1;
 
 		lock_extent(&BTRFS_I(inode)->io_tree, page_start, page_end);
 
@@ -3191,7 +3191,7 @@ static int relocate_file_extent_cluster(struct inode *inode,
 		unlock_extent(&BTRFS_I(inode)->io_tree,
 			      page_start, page_end);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		index++;
 		balance_dirty_pages_ratelimited(inode->i_mapping);
diff --git a/fs/btrfs/scrub.c b/fs/btrfs/scrub.c
index 92bf5ee732fb..1c6d3267029f 100644
--- a/fs/btrfs/scrub.c
+++ b/fs/btrfs/scrub.c
@@ -703,7 +703,7 @@ static int scrub_fixup_readpage(u64 inum, u64 offset, u64 root, void *fixup_ctx)
 	if (IS_ERR(inode))
 		return PTR_ERR(inode);
 
-	index = offset >> PAGE_CACHE_SHIFT;
+	index = offset >> PAGE_SHIFT;
 
 	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
 	if (!page) {
@@ -1636,7 +1636,7 @@ static int scrub_write_page_to_dev_replace(struct scrub_block *sblock,
 	if (spage->io_error) {
 		void *mapped_buffer = kmap_atomic(spage->page);
 
-		memset(mapped_buffer, 0, PAGE_CACHE_SIZE);
+		memset(mapped_buffer, 0, PAGE_SIZE);
 		flush_dcache_page(spage->page);
 		kunmap_atomic(mapped_buffer);
 	}
@@ -4292,8 +4292,8 @@ static int copy_nocow_pages_for_inode(u64 inum, u64 offset, u64 root,
 		goto out;
 	}
 
-	while (len >= PAGE_CACHE_SIZE) {
-		index = offset >> PAGE_CACHE_SHIFT;
+	while (len >= PAGE_SIZE) {
+		index = offset >> PAGE_SHIFT;
 again:
 		page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
 		if (!page) {
@@ -4324,7 +4324,7 @@ again:
 			 */
 			if (page->mapping != inode->i_mapping) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				goto again;
 			}
 			if (!PageUptodate(page)) {
@@ -4346,15 +4346,15 @@ again:
 			ret = err;
 next_page:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		if (ret)
 			break;
 
-		offset += PAGE_CACHE_SIZE;
-		physical_for_dev_replace += PAGE_CACHE_SIZE;
-		nocow_ctx_logical += PAGE_CACHE_SIZE;
-		len -= PAGE_CACHE_SIZE;
+		offset += PAGE_SIZE;
+		physical_for_dev_replace += PAGE_SIZE;
+		nocow_ctx_logical += PAGE_SIZE;
+		len -= PAGE_SIZE;
 	}
 	ret = COPY_COMPLETE;
 out:
@@ -4388,8 +4388,8 @@ static int write_page_nocow(struct scrub_ctx *sctx,
 	bio->bi_iter.bi_size = 0;
 	bio->bi_iter.bi_sector = physical_for_dev_replace >> 9;
 	bio->bi_bdev = dev->bdev;
-	ret = bio_add_page(bio, page, PAGE_CACHE_SIZE, 0);
-	if (ret != PAGE_CACHE_SIZE) {
+	ret = bio_add_page(bio, page, PAGE_SIZE, 0);
+	if (ret != PAGE_SIZE) {
 leave_with_eio:
 		bio_put(bio);
 		btrfs_dev_stat_inc_and_print(dev, BTRFS_DEV_STAT_WRITE_ERRS);
diff --git a/fs/btrfs/send.c b/fs/btrfs/send.c
index 63a6152be04b..f5b875c8c2d8 100644
--- a/fs/btrfs/send.c
+++ b/fs/btrfs/send.c
@@ -4448,9 +4448,9 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 	struct page *page;
 	char *addr;
 	struct btrfs_key key;
-	pgoff_t index = offset >> PAGE_CACHE_SHIFT;
+	pgoff_t index = offset >> PAGE_SHIFT;
 	pgoff_t last_index;
-	unsigned pg_offset = offset & ~PAGE_CACHE_MASK;
+	unsigned pg_offset = offset & ~PAGE_MASK;
 	ssize_t ret = 0;
 
 	key.objectid = sctx->cur_ino;
@@ -4470,7 +4470,7 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 	if (len == 0)
 		goto out;
 
-	last_index = (offset + len - 1) >> PAGE_CACHE_SHIFT;
+	last_index = (offset + len - 1) >> PAGE_SHIFT;
 
 	/* initial readahead */
 	memset(&sctx->ra, 0, sizeof(struct file_ra_state));
@@ -4480,7 +4480,7 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 
 	while (index <= last_index) {
 		unsigned cur_len = min_t(unsigned, len,
-					 PAGE_CACHE_SIZE - pg_offset);
+					 PAGE_SIZE - pg_offset);
 		page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
 		if (!page) {
 			ret = -ENOMEM;
@@ -4492,7 +4492,7 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 			lock_page(page);
 			if (!PageUptodate(page)) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				ret = -EIO;
 				break;
 			}
@@ -4502,7 +4502,7 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 		memcpy(sctx->read_buf + ret, addr + pg_offset, cur_len);
 		kunmap(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		index++;
 		pg_offset = 0;
 		len -= cur_len;
@@ -4803,7 +4803,7 @@ static int clone_range(struct send_ctx *sctx,
 		type = btrfs_file_extent_type(leaf, ei);
 		if (type == BTRFS_FILE_EXTENT_INLINE) {
 			ext_len = btrfs_file_extent_inline_len(leaf, slot, ei);
-			ext_len = PAGE_CACHE_ALIGN(ext_len);
+			ext_len = PAGE_ALIGN(ext_len);
 		} else {
 			ext_len = btrfs_file_extent_num_bytes(leaf, ei);
 		}
@@ -4885,7 +4885,7 @@ static int send_write_or_clone(struct send_ctx *sctx,
 		 * but there may be items after this page.  Make
 		 * sure to send the whole thing
 		 */
-		len = PAGE_CACHE_ALIGN(len);
+		len = PAGE_ALIGN(len);
 	} else {
 		len = btrfs_file_extent_num_bytes(path->nodes[0], ei);
 	}
diff --git a/fs/btrfs/tests/extent-io-tests.c b/fs/btrfs/tests/extent-io-tests.c
index 669b58201e36..ac3a06d28531 100644
--- a/fs/btrfs/tests/extent-io-tests.c
+++ b/fs/btrfs/tests/extent-io-tests.c
@@ -32,8 +32,8 @@ static noinline int process_page_range(struct inode *inode, u64 start, u64 end,
 {
 	int ret;
 	struct page *pages[16];
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	unsigned long nr_pages = end_index - index + 1;
 	int i;
 	int count = 0;
@@ -49,9 +49,9 @@ static noinline int process_page_range(struct inode *inode, u64 start, u64 end,
 				count++;
 			if (flags & PROCESS_UNLOCK && PageLocked(pages[i]))
 				unlock_page(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 			if (flags & PROCESS_RELEASE)
-				page_cache_release(pages[i]);
+				put_page(pages[i]);
 		}
 		nr_pages -= ret;
 		index += ret;
@@ -93,7 +93,7 @@ static int test_find_delalloc(void)
 	 * everything to make sure our pages don't get evicted and screw up our
 	 * test.
 	 */
-	for (index = 0; index < (total_dirty >> PAGE_CACHE_SHIFT); index++) {
+	for (index = 0; index < (total_dirty >> PAGE_SHIFT); index++) {
 		page = find_or_create_page(inode->i_mapping, index, GFP_KERNEL);
 		if (!page) {
 			test_msg("Failed to allocate test page\n");
@@ -104,7 +104,7 @@ static int test_find_delalloc(void)
 		if (index) {
 			unlock_page(page);
 		} else {
-			page_cache_get(page);
+			get_page(page);
 			locked_page = page;
 		}
 	}
@@ -129,7 +129,7 @@ static int test_find_delalloc(void)
 	}
 	unlock_extent(&tmp, start, end);
 	unlock_page(locked_page);
-	page_cache_release(locked_page);
+	put_page(locked_page);
 
 	/*
 	 * Test this scenario
@@ -139,7 +139,7 @@ static int test_find_delalloc(void)
 	 */
 	test_start = SZ_64M;
 	locked_page = find_lock_page(inode->i_mapping,
-				     test_start >> PAGE_CACHE_SHIFT);
+				     test_start >> PAGE_SHIFT);
 	if (!locked_page) {
 		test_msg("Couldn't find the locked page\n");
 		goto out_bits;
@@ -165,7 +165,7 @@ static int test_find_delalloc(void)
 	}
 	unlock_extent(&tmp, start, end);
 	/* locked_page was unlocked above */
-	page_cache_release(locked_page);
+	put_page(locked_page);
 
 	/*
 	 * Test this scenario
@@ -174,7 +174,7 @@ static int test_find_delalloc(void)
 	 */
 	test_start = max_bytes + 4096;
 	locked_page = find_lock_page(inode->i_mapping, test_start >>
-				     PAGE_CACHE_SHIFT);
+				     PAGE_SHIFT);
 	if (!locked_page) {
 		test_msg("Could'nt find the locked page\n");
 		goto out_bits;
@@ -225,13 +225,13 @@ static int test_find_delalloc(void)
 	 * range we want to find.
 	 */
 	page = find_get_page(inode->i_mapping,
-			     (max_bytes + SZ_1M) >> PAGE_CACHE_SHIFT);
+			     (max_bytes + SZ_1M) >> PAGE_SHIFT);
 	if (!page) {
 		test_msg("Couldn't find our page\n");
 		goto out_bits;
 	}
 	ClearPageDirty(page);
-	page_cache_release(page);
+	put_page(page);
 
 	/* We unlocked it in the previous test */
 	lock_page(locked_page);
@@ -249,9 +249,9 @@ static int test_find_delalloc(void)
 		test_msg("Didn't find our range\n");
 		goto out_bits;
 	}
-	if (start != test_start && end != test_start + PAGE_CACHE_SIZE - 1) {
+	if (start != test_start && end != test_start + PAGE_SIZE - 1) {
 		test_msg("Expected start %Lu end %Lu, got start %Lu end %Lu\n",
-			 test_start, test_start + PAGE_CACHE_SIZE - 1, start,
+			 test_start, test_start + PAGE_SIZE - 1, start,
 			 end);
 		goto out_bits;
 	}
@@ -265,7 +265,7 @@ out_bits:
 	clear_extent_bits(&tmp, 0, total_dirty - 1, (unsigned)-1, GFP_KERNEL);
 out:
 	if (locked_page)
-		page_cache_release(locked_page);
+		put_page(locked_page);
 	process_page_range(inode, 0, total_dirty - 1,
 			   PROCESS_UNLOCK | PROCESS_RELEASE);
 	iput(inode);
@@ -298,9 +298,9 @@ static int __test_eb_bitmaps(unsigned long *bitmap, struct extent_buffer *eb,
 		return -EINVAL;
 	}
 
-	bitmap_set(bitmap, (PAGE_CACHE_SIZE - sizeof(long) / 2) * BITS_PER_BYTE,
+	bitmap_set(bitmap, (PAGE_SIZE - sizeof(long) / 2) * BITS_PER_BYTE,
 		   sizeof(long) * BITS_PER_BYTE);
-	extent_buffer_bitmap_set(eb, PAGE_CACHE_SIZE - sizeof(long) / 2, 0,
+	extent_buffer_bitmap_set(eb, PAGE_SIZE - sizeof(long) / 2, 0,
 				 sizeof(long) * BITS_PER_BYTE);
 	if (memcmp_extent_buffer(eb, bitmap, 0, len) != 0) {
 		test_msg("Setting straddling pages failed\n");
@@ -309,10 +309,10 @@ static int __test_eb_bitmaps(unsigned long *bitmap, struct extent_buffer *eb,
 
 	bitmap_set(bitmap, 0, len * BITS_PER_BYTE);
 	bitmap_clear(bitmap,
-		     (PAGE_CACHE_SIZE - sizeof(long) / 2) * BITS_PER_BYTE,
+		     (PAGE_SIZE - sizeof(long) / 2) * BITS_PER_BYTE,
 		     sizeof(long) * BITS_PER_BYTE);
 	extent_buffer_bitmap_set(eb, 0, 0, len * BITS_PER_BYTE);
-	extent_buffer_bitmap_clear(eb, PAGE_CACHE_SIZE - sizeof(long) / 2, 0,
+	extent_buffer_bitmap_clear(eb, PAGE_SIZE - sizeof(long) / 2, 0,
 				   sizeof(long) * BITS_PER_BYTE);
 	if (memcmp_extent_buffer(eb, bitmap, 0, len) != 0) {
 		test_msg("Clearing straddling pages failed\n");
@@ -353,7 +353,7 @@ static int __test_eb_bitmaps(unsigned long *bitmap, struct extent_buffer *eb,
 
 static int test_eb_bitmaps(void)
 {
-	unsigned long len = PAGE_CACHE_SIZE * 4;
+	unsigned long len = PAGE_SIZE * 4;
 	unsigned long *bitmap;
 	struct extent_buffer *eb;
 	int ret;
@@ -379,7 +379,7 @@ static int test_eb_bitmaps(void)
 
 	/* Do it over again with an extent buffer which isn't page-aligned. */
 	free_extent_buffer(eb);
-	eb = __alloc_dummy_extent_buffer(NULL, PAGE_CACHE_SIZE / 2, len);
+	eb = __alloc_dummy_extent_buffer(NULL, PAGE_SIZE / 2, len);
 	if (!eb) {
 		test_msg("Couldn't allocate test extent buffer\n");
 		kfree(bitmap);
diff --git a/fs/btrfs/tests/free-space-tests.c b/fs/btrfs/tests/free-space-tests.c
index c9ad97b1e690..514247515312 100644
--- a/fs/btrfs/tests/free-space-tests.c
+++ b/fs/btrfs/tests/free-space-tests.c
@@ -22,7 +22,7 @@
 #include "../disk-io.h"
 #include "../free-space-cache.h"
 
-#define BITS_PER_BITMAP		(PAGE_CACHE_SIZE * 8)
+#define BITS_PER_BITMAP		(PAGE_SIZE * 8)
 
 /*
  * This test just does basic sanity checking, making sure we can add an exten
diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index 366b335946fa..eeb6da7976a5 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -1024,16 +1024,16 @@ int btrfs_scan_one_device(const char *path, fmode_t flags, void *holder,
 	}
 
 	/* make sure our super fits in the device */
-	if (bytenr + PAGE_CACHE_SIZE >= i_size_read(bdev->bd_inode))
+	if (bytenr + PAGE_SIZE >= i_size_read(bdev->bd_inode))
 		goto error_bdev_put;
 
 	/* make sure our super fits in the page */
-	if (sizeof(*disk_super) > PAGE_CACHE_SIZE)
+	if (sizeof(*disk_super) > PAGE_SIZE)
 		goto error_bdev_put;
 
 	/* make sure our super doesn't straddle pages on disk */
-	index = bytenr >> PAGE_CACHE_SHIFT;
-	if ((bytenr + sizeof(*disk_super) - 1) >> PAGE_CACHE_SHIFT != index)
+	index = bytenr >> PAGE_SHIFT;
+	if ((bytenr + sizeof(*disk_super) - 1) >> PAGE_SHIFT != index)
 		goto error_bdev_put;
 
 	/* pull in the page with our super */
@@ -1046,7 +1046,7 @@ int btrfs_scan_one_device(const char *path, fmode_t flags, void *holder,
 	p = kmap(page);
 
 	/* align our pointer to the offset of the super block */
-	disk_super = p + (bytenr & ~PAGE_CACHE_MASK);
+	disk_super = p + (bytenr & ~PAGE_MASK);
 
 	if (btrfs_super_bytenr(disk_super) != bytenr ||
 	    btrfs_super_magic(disk_super) != BTRFS_MAGIC)
@@ -1074,7 +1074,7 @@ int btrfs_scan_one_device(const char *path, fmode_t flags, void *holder,
 
 error_unmap:
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 
 error_bdev_put:
 	blkdev_put(bdev, flags);
@@ -6522,7 +6522,7 @@ int btrfs_read_sys_array(struct btrfs_root *root)
 	 * but sb spans only this function. Add an explicit SetPageUptodate call
 	 * to silence the warning eg. on PowerPC 64.
 	 */
-	if (PAGE_CACHE_SIZE > BTRFS_SUPER_INFO_SIZE)
+	if (PAGE_SIZE > BTRFS_SUPER_INFO_SIZE)
 		SetPageUptodate(sb->pages[0]);
 
 	write_extent_buffer(sb, super_copy, 0, BTRFS_SUPER_INFO_SIZE);
diff --git a/fs/btrfs/zlib.c b/fs/btrfs/zlib.c
index 82990b8f872b..88d274e8ecf2 100644
--- a/fs/btrfs/zlib.c
+++ b/fs/btrfs/zlib.c
@@ -59,7 +59,7 @@ static struct list_head *zlib_alloc_workspace(void)
 	workspacesize = max(zlib_deflate_workspacesize(MAX_WBITS, MAX_MEM_LEVEL),
 			zlib_inflate_workspacesize());
 	workspace->strm.workspace = vmalloc(workspacesize);
-	workspace->buf = kmalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+	workspace->buf = kmalloc(PAGE_SIZE, GFP_NOFS);
 	if (!workspace->strm.workspace || !workspace->buf)
 		goto fail;
 
@@ -103,7 +103,7 @@ static int zlib_compress_pages(struct list_head *ws,
 	workspace->strm.total_in = 0;
 	workspace->strm.total_out = 0;
 
-	in_page = find_get_page(mapping, start >> PAGE_CACHE_SHIFT);
+	in_page = find_get_page(mapping, start >> PAGE_SHIFT);
 	data_in = kmap(in_page);
 
 	out_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
@@ -117,8 +117,8 @@ static int zlib_compress_pages(struct list_head *ws,
 
 	workspace->strm.next_in = data_in;
 	workspace->strm.next_out = cpage_out;
-	workspace->strm.avail_out = PAGE_CACHE_SIZE;
-	workspace->strm.avail_in = min(len, PAGE_CACHE_SIZE);
+	workspace->strm.avail_out = PAGE_SIZE;
+	workspace->strm.avail_in = min(len, PAGE_SIZE);
 
 	while (workspace->strm.total_in < len) {
 		ret = zlib_deflate(&workspace->strm, Z_SYNC_FLUSH);
@@ -156,7 +156,7 @@ static int zlib_compress_pages(struct list_head *ws,
 			cpage_out = kmap(out_page);
 			pages[nr_pages] = out_page;
 			nr_pages++;
-			workspace->strm.avail_out = PAGE_CACHE_SIZE;
+			workspace->strm.avail_out = PAGE_SIZE;
 			workspace->strm.next_out = cpage_out;
 		}
 		/* we're all done */
@@ -170,14 +170,14 @@ static int zlib_compress_pages(struct list_head *ws,
 
 			bytes_left = len - workspace->strm.total_in;
 			kunmap(in_page);
-			page_cache_release(in_page);
+			put_page(in_page);
 
-			start += PAGE_CACHE_SIZE;
+			start += PAGE_SIZE;
 			in_page = find_get_page(mapping,
-						start >> PAGE_CACHE_SHIFT);
+						start >> PAGE_SHIFT);
 			data_in = kmap(in_page);
 			workspace->strm.avail_in = min(bytes_left,
-							   PAGE_CACHE_SIZE);
+							   PAGE_SIZE);
 			workspace->strm.next_in = data_in;
 		}
 	}
@@ -205,7 +205,7 @@ out:
 
 	if (in_page) {
 		kunmap(in_page);
-		page_cache_release(in_page);
+		put_page(in_page);
 	}
 	return ret;
 }
@@ -223,18 +223,18 @@ static int zlib_decompress_biovec(struct list_head *ws, struct page **pages_in,
 	size_t total_out = 0;
 	unsigned long page_in_index = 0;
 	unsigned long page_out_index = 0;
-	unsigned long total_pages_in = DIV_ROUND_UP(srclen, PAGE_CACHE_SIZE);
+	unsigned long total_pages_in = DIV_ROUND_UP(srclen, PAGE_SIZE);
 	unsigned long buf_start;
 	unsigned long pg_offset;
 
 	data_in = kmap(pages_in[page_in_index]);
 	workspace->strm.next_in = data_in;
-	workspace->strm.avail_in = min_t(size_t, srclen, PAGE_CACHE_SIZE);
+	workspace->strm.avail_in = min_t(size_t, srclen, PAGE_SIZE);
 	workspace->strm.total_in = 0;
 
 	workspace->strm.total_out = 0;
 	workspace->strm.next_out = workspace->buf;
-	workspace->strm.avail_out = PAGE_CACHE_SIZE;
+	workspace->strm.avail_out = PAGE_SIZE;
 	pg_offset = 0;
 
 	/* If it's deflate, and it's got no preset dictionary, then
@@ -274,7 +274,7 @@ static int zlib_decompress_biovec(struct list_head *ws, struct page **pages_in,
 		}
 
 		workspace->strm.next_out = workspace->buf;
-		workspace->strm.avail_out = PAGE_CACHE_SIZE;
+		workspace->strm.avail_out = PAGE_SIZE;
 
 		if (workspace->strm.avail_in == 0) {
 			unsigned long tmp;
@@ -288,7 +288,7 @@ static int zlib_decompress_biovec(struct list_head *ws, struct page **pages_in,
 			workspace->strm.next_in = data_in;
 			tmp = srclen - workspace->strm.total_in;
 			workspace->strm.avail_in = min(tmp,
-							   PAGE_CACHE_SIZE);
+							   PAGE_SIZE);
 		}
 	}
 	if (ret != Z_STREAM_END)
@@ -325,7 +325,7 @@ static int zlib_decompress(struct list_head *ws, unsigned char *data_in,
 	workspace->strm.total_in = 0;
 
 	workspace->strm.next_out = workspace->buf;
-	workspace->strm.avail_out = PAGE_CACHE_SIZE;
+	workspace->strm.avail_out = PAGE_SIZE;
 	workspace->strm.total_out = 0;
 	/* If it's deflate, and it's got no preset dictionary, then
 	   we can tell zlib to skip the adler32 check. */
@@ -368,8 +368,8 @@ static int zlib_decompress(struct list_head *ws, unsigned char *data_in,
 		else
 			buf_offset = 0;
 
-		bytes = min(PAGE_CACHE_SIZE - pg_offset,
-			    PAGE_CACHE_SIZE - buf_offset);
+		bytes = min(PAGE_SIZE - pg_offset,
+			    PAGE_SIZE - buf_offset);
 		bytes = min(bytes, bytes_left);
 
 		kaddr = kmap_atomic(dest_page);
@@ -380,7 +380,7 @@ static int zlib_decompress(struct list_head *ws, unsigned char *data_in,
 		bytes_left -= bytes;
 next:
 		workspace->strm.next_out = workspace->buf;
-		workspace->strm.avail_out = PAGE_CACHE_SIZE;
+		workspace->strm.avail_out = PAGE_SIZE;
 	}
 
 	if (ret != Z_STREAM_END && bytes_left != 0)
diff --git a/fs/buffer.c b/fs/buffer.c
index 33be29675358..af0d9a82a8ed 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -129,7 +129,7 @@ __clear_page_buffers(struct page *page)
 {
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static void buffer_io_error(struct buffer_head *bh, char *msg)
@@ -207,7 +207,7 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 	struct page *page;
 	int all_mapped = 1;
 
-	index = block >> (PAGE_CACHE_SHIFT - bd_inode->i_blkbits);
+	index = block >> (PAGE_SHIFT - bd_inode->i_blkbits);
 	page = find_get_page_flags(bd_mapping, index, FGP_ACCESSED);
 	if (!page)
 		goto out;
@@ -245,7 +245,7 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 	}
 out_unlock:
 	spin_unlock(&bd_mapping->private_lock);
-	page_cache_release(page);
+	put_page(page);
 out:
 	return ret;
 }
@@ -1040,7 +1040,7 @@ done:
 	ret = (block < end_block) ? 1 : -ENXIO;
 failed:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return ret;
 }
 
@@ -1533,7 +1533,7 @@ void block_invalidatepage(struct page *page, unsigned int offset,
 	/*
 	 * Check for overflow
 	 */
-	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+	BUG_ON(stop > PAGE_SIZE || stop < length);
 
 	head = page_buffers(page);
 	bh = head;
@@ -1716,7 +1716,7 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 	blocksize = bh->b_size;
 	bbits = block_size_bits(blocksize);
 
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	block = (sector_t)page->index << (PAGE_SHIFT - bbits);
 	last_block = (i_size_read(inode) - 1) >> bbits;
 
 	/*
@@ -1894,7 +1894,7 @@ EXPORT_SYMBOL(page_zero_new_buffers);
 int __block_write_begin(struct page *page, loff_t pos, unsigned len,
 		get_block_t *get_block)
 {
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + len;
 	struct inode *inode = page->mapping->host;
 	unsigned block_start, block_end;
@@ -1904,15 +1904,15 @@ int __block_write_begin(struct page *page, loff_t pos, unsigned len,
 	struct buffer_head *bh, *head, *wait[2], **wait_bh=wait;
 
 	BUG_ON(!PageLocked(page));
-	BUG_ON(from > PAGE_CACHE_SIZE);
-	BUG_ON(to > PAGE_CACHE_SIZE);
+	BUG_ON(from > PAGE_SIZE);
+	BUG_ON(to > PAGE_SIZE);
 	BUG_ON(from > to);
 
 	head = create_page_buffers(page, inode, 0);
 	blocksize = head->b_size;
 	bbits = block_size_bits(blocksize);
 
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	block = (sector_t)page->index << (PAGE_SHIFT - bbits);
 
 	for(bh = head, block_start = 0; bh != head || !block_start;
 	    block++, block_start=block_end, bh = bh->b_this_page) {
@@ -2020,7 +2020,7 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
 		unsigned flags, struct page **pagep, get_block_t *get_block)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	int status;
 
@@ -2031,7 +2031,7 @@ int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
 	status = __block_write_begin(page, pos, len, get_block);
 	if (unlikely(status)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 
@@ -2047,7 +2047,7 @@ int block_write_end(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	unsigned start;
 
-	start = pos & (PAGE_CACHE_SIZE - 1);
+	start = pos & (PAGE_SIZE - 1);
 
 	if (unlikely(copied < len)) {
 		/*
@@ -2099,7 +2099,7 @@ int generic_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (old_size < pos)
 		pagecache_isize_extended(inode, old_size, pos);
@@ -2136,9 +2136,9 @@ int block_is_partially_uptodate(struct page *page, unsigned long from,
 
 	head = page_buffers(page);
 	blocksize = head->b_size;
-	to = min_t(unsigned, PAGE_CACHE_SIZE - from, count);
+	to = min_t(unsigned, PAGE_SIZE - from, count);
 	to = from + to;
-	if (from < blocksize && to > PAGE_CACHE_SIZE - blocksize)
+	if (from < blocksize && to > PAGE_SIZE - blocksize)
 		return 0;
 
 	bh = head;
@@ -2181,7 +2181,7 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 	blocksize = head->b_size;
 	bbits = block_size_bits(blocksize);
 
-	iblock = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	iblock = (sector_t)page->index << (PAGE_SHIFT - bbits);
 	lblock = (i_size_read(inode)+blocksize-1) >> bbits;
 	bh = head;
 	nr = 0;
@@ -2295,16 +2295,16 @@ static int cont_expand_zero(struct file *file, struct address_space *mapping,
 	unsigned zerofrom, offset, len;
 	int err = 0;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	offset = pos & ~PAGE_CACHE_MASK;
+	index = pos >> PAGE_SHIFT;
+	offset = pos & ~PAGE_MASK;
 
-	while (index > (curidx = (curpos = *bytes)>>PAGE_CACHE_SHIFT)) {
-		zerofrom = curpos & ~PAGE_CACHE_MASK;
+	while (index > (curidx = (curpos = *bytes)>>PAGE_SHIFT)) {
+		zerofrom = curpos & ~PAGE_MASK;
 		if (zerofrom & (blocksize-1)) {
 			*bytes |= (blocksize-1);
 			(*bytes)++;
 		}
-		len = PAGE_CACHE_SIZE - zerofrom;
+		len = PAGE_SIZE - zerofrom;
 
 		err = pagecache_write_begin(file, mapping, curpos, len,
 						AOP_FLAG_UNINTERRUPTIBLE,
@@ -2329,7 +2329,7 @@ static int cont_expand_zero(struct file *file, struct address_space *mapping,
 
 	/* page covers the boundary, find the boundary offset */
 	if (index == curidx) {
-		zerofrom = curpos & ~PAGE_CACHE_MASK;
+		zerofrom = curpos & ~PAGE_MASK;
 		/* if we will expand the thing last block will be filled */
 		if (offset <= zerofrom) {
 			goto out;
@@ -2375,7 +2375,7 @@ int cont_write_begin(struct file *file, struct address_space *mapping,
 	if (err)
 		return err;
 
-	zerofrom = *bytes & ~PAGE_CACHE_MASK;
+	zerofrom = *bytes & ~PAGE_MASK;
 	if (pos+len > *bytes && zerofrom & (blocksize-1)) {
 		*bytes |= (blocksize-1);
 		(*bytes)++;
@@ -2430,10 +2430,10 @@ int block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	}
 
 	/* page is wholly or partially inside EOF */
-	if (((page->index + 1) << PAGE_CACHE_SHIFT) > size)
-		end = size & ~PAGE_CACHE_MASK;
+	if (((page->index + 1) << PAGE_SHIFT) > size)
+		end = size & ~PAGE_MASK;
 	else
-		end = PAGE_CACHE_SIZE;
+		end = PAGE_SIZE;
 
 	ret = __block_write_begin(page, 0, end, get_block);
 	if (!ret)
@@ -2508,8 +2508,8 @@ int nobh_write_begin(struct address_space *mapping,
 	int ret = 0;
 	int is_mapped_to_disk = 1;
 
-	index = pos >> PAGE_CACHE_SHIFT;
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	index = pos >> PAGE_SHIFT;
+	from = pos & (PAGE_SIZE - 1);
 	to = from + len;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
@@ -2543,7 +2543,7 @@ int nobh_write_begin(struct address_space *mapping,
 		goto out_release;
 	}
 
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 
 	/*
 	 * We loop across all blocks in the page, whether or not they are
@@ -2551,7 +2551,7 @@ int nobh_write_begin(struct address_space *mapping,
 	 * page is fully mapped-to-disk.
 	 */
 	for (block_start = 0, block_in_page = 0, bh = head;
-		  block_start < PAGE_CACHE_SIZE;
+		  block_start < PAGE_SIZE;
 		  block_in_page++, block_start += blocksize, bh = bh->b_this_page) {
 		int create;
 
@@ -2623,7 +2623,7 @@ failed:
 
 out_release:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	*pagep = NULL;
 
 	return ret;
@@ -2653,7 +2653,7 @@ int nobh_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	while (head) {
 		bh = head;
@@ -2675,7 +2675,7 @@ int nobh_writepage(struct page *page, get_block_t *get_block,
 {
 	struct inode * const inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	const pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
 	int ret;
 
@@ -2684,7 +2684,7 @@ int nobh_writepage(struct page *page, get_block_t *get_block,
 		goto out;
 
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = i_size & (PAGE_SIZE-1);
 	if (page->index >= end_index+1 || !offset) {
 		/*
 		 * The page may have dirty, unmapped buffers.  For example,
@@ -2707,7 +2707,7 @@ int nobh_writepage(struct page *page, get_block_t *get_block,
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 out:
 	ret = mpage_writepage(page, get_block, wbc);
 	if (ret == -EAGAIN)
@@ -2720,8 +2720,8 @@ EXPORT_SYMBOL(nobh_writepage);
 int nobh_truncate_page(struct address_space *mapping,
 			loff_t from, get_block_t *get_block)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize;
 	sector_t iblock;
 	unsigned length, pos;
@@ -2738,7 +2738,7 @@ int nobh_truncate_page(struct address_space *mapping,
 		return 0;
 
 	length = blocksize - length;
-	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	iblock = (sector_t)index << (PAGE_SHIFT - inode->i_blkbits);
 
 	page = grab_cache_page(mapping, index);
 	err = -ENOMEM;
@@ -2748,7 +2748,7 @@ int nobh_truncate_page(struct address_space *mapping,
 	if (page_has_buffers(page)) {
 has_buffers:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return block_truncate_page(mapping, from, get_block);
 	}
 
@@ -2772,7 +2772,7 @@ has_buffers:
 	if (!PageUptodate(page)) {
 		err = mapping->a_ops->readpage(NULL, page);
 		if (err) {
-			page_cache_release(page);
+			put_page(page);
 			goto out;
 		}
 		lock_page(page);
@@ -2789,7 +2789,7 @@ has_buffers:
 
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out:
 	return err;
 }
@@ -2798,8 +2798,8 @@ EXPORT_SYMBOL(nobh_truncate_page);
 int block_truncate_page(struct address_space *mapping,
 			loff_t from, get_block_t *get_block)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize;
 	sector_t iblock;
 	unsigned length, pos;
@@ -2816,7 +2816,7 @@ int block_truncate_page(struct address_space *mapping,
 		return 0;
 
 	length = blocksize - length;
-	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	iblock = (sector_t)index << (PAGE_SHIFT - inode->i_blkbits);
 	
 	page = grab_cache_page(mapping, index);
 	err = -ENOMEM;
@@ -2865,7 +2865,7 @@ int block_truncate_page(struct address_space *mapping,
 
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out:
 	return err;
 }
@@ -2879,7 +2879,7 @@ int block_write_full_page(struct page *page, get_block_t *get_block,
 {
 	struct inode * const inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	const pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
 
 	/* Is the page fully inside i_size? */
@@ -2888,14 +2888,14 @@ int block_write_full_page(struct page *page, get_block_t *get_block,
 					       end_buffer_async_write);
 
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = i_size & (PAGE_SIZE-1);
 	if (page->index >= end_index+1 || !offset) {
 		/*
 		 * The page may have dirty, unmapped buffers.  For example,
 		 * they may have been added in ext3_writepage().  Make them
 		 * freeable here, so the page does not leak.
 		 */
-		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		do_invalidatepage(page, 0, PAGE_SIZE);
 		unlock_page(page);
 		return 0; /* don't care */
 	}
@@ -2907,7 +2907,7 @@ int block_write_full_page(struct page *page, get_block_t *get_block,
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 	return __block_write_full_page(inode, page, get_block, wbc,
 							end_buffer_async_write);
 }
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index c0f3da3926a0..afbdc418966d 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -194,10 +194,10 @@ static void cachefiles_read_copier(struct fscache_operation *_op)
 			error = -EIO;
 		}
 
-		page_cache_release(monitor->back_page);
+		put_page(monitor->back_page);
 
 		fscache_end_io(op, monitor->netfs_page, error);
-		page_cache_release(monitor->netfs_page);
+		put_page(monitor->netfs_page);
 		fscache_retrieval_complete(op, 1);
 		fscache_put_retrieval(op);
 		kfree(monitor);
@@ -288,8 +288,8 @@ monitor_backing_page:
 	_debug("- monitor add");
 
 	/* install the monitor */
-	page_cache_get(monitor->netfs_page);
-	page_cache_get(backpage);
+	get_page(monitor->netfs_page);
+	get_page(backpage);
 	monitor->back_page = backpage;
 	monitor->monitor.private = backpage;
 	add_page_wait_queue(backpage, &monitor->monitor);
@@ -310,7 +310,7 @@ backing_page_already_present:
 	_debug("- present");
 
 	if (newpage) {
-		page_cache_release(newpage);
+		put_page(newpage);
 		newpage = NULL;
 	}
 
@@ -342,7 +342,7 @@ success:
 
 out:
 	if (backpage)
-		page_cache_release(backpage);
+		put_page(backpage);
 	if (monitor) {
 		fscache_put_retrieval(monitor->op);
 		kfree(monitor);
@@ -363,7 +363,7 @@ io_error:
 	goto out;
 
 nomem_page:
-	page_cache_release(newpage);
+	put_page(newpage);
 nomem_monitor:
 	fscache_put_retrieval(monitor->op);
 	kfree(monitor);
@@ -530,7 +530,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 					    netpage->index, cachefiles_gfp);
 		if (ret < 0) {
 			if (ret == -EEXIST) {
-				page_cache_release(netpage);
+				put_page(netpage);
 				fscache_retrieval_complete(op, 1);
 				continue;
 			}
@@ -538,10 +538,10 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		}
 
 		/* install a monitor */
-		page_cache_get(netpage);
+		get_page(netpage);
 		monitor->netfs_page = netpage;
 
-		page_cache_get(backpage);
+		get_page(backpage);
 		monitor->back_page = backpage;
 		monitor->monitor.private = backpage;
 		add_page_wait_queue(backpage, &monitor->monitor);
@@ -555,10 +555,10 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 			unlock_page(backpage);
 		}
 
-		page_cache_release(backpage);
+		put_page(backpage);
 		backpage = NULL;
 
-		page_cache_release(netpage);
+		put_page(netpage);
 		netpage = NULL;
 		continue;
 
@@ -603,7 +603,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 					    netpage->index, cachefiles_gfp);
 		if (ret < 0) {
 			if (ret == -EEXIST) {
-				page_cache_release(netpage);
+				put_page(netpage);
 				fscache_retrieval_complete(op, 1);
 				continue;
 			}
@@ -612,14 +612,14 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 
 		copy_highpage(netpage, backpage);
 
-		page_cache_release(backpage);
+		put_page(backpage);
 		backpage = NULL;
 
 		fscache_mark_page_cached(op, netpage);
 
 		/* the netpage is unlocked and marked up to date here */
 		fscache_end_io(op, netpage, 0);
-		page_cache_release(netpage);
+		put_page(netpage);
 		netpage = NULL;
 		fscache_retrieval_complete(op, 1);
 		continue;
@@ -632,11 +632,11 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 out:
 	/* tidy up */
 	if (newpage)
-		page_cache_release(newpage);
+		put_page(newpage);
 	if (netpage)
-		page_cache_release(netpage);
+		put_page(netpage);
 	if (backpage)
-		page_cache_release(backpage);
+		put_page(backpage);
 	if (monitor) {
 		fscache_put_retrieval(op);
 		kfree(monitor);
@@ -644,7 +644,7 @@ out:
 
 	list_for_each_entry_safe(netpage, _n, list, lru) {
 		list_del(&netpage->lru);
-		page_cache_release(netpage);
+		put_page(netpage);
 		fscache_retrieval_complete(op, 1);
 	}
 
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 19adeb0ef82a..355e2bc794cd 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -143,7 +143,7 @@ static void ceph_invalidatepage(struct page *page, unsigned int offset,
 	inode = page->mapping->host;
 	ci = ceph_inode(inode);
 
-	if (offset != 0 || length != PAGE_CACHE_SIZE) {
+	if (offset != 0 || length != PAGE_SIZE) {
 		dout("%p invalidatepage %p idx %lu partial dirty page %u~%u\n",
 		     inode, page, page->index, offset, length);
 		return;
@@ -197,10 +197,10 @@ static int readpage_nounlock(struct file *filp, struct page *page)
 		&ceph_inode_to_client(inode)->client->osdc;
 	int err = 0;
 	u64 off = page_offset(page);
-	u64 len = PAGE_CACHE_SIZE;
+	u64 len = PAGE_SIZE;
 
 	if (off >= i_size_read(inode)) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		return 0;
 	}
@@ -212,7 +212,7 @@ static int readpage_nounlock(struct file *filp, struct page *page)
 		 */
 		if (off == 0)
 			return -EINVAL;
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		return 0;
 	}
@@ -234,9 +234,9 @@ static int readpage_nounlock(struct file *filp, struct page *page)
 		ceph_fscache_readpage_cancel(inode, page);
 		goto out;
 	}
-	if (err < PAGE_CACHE_SIZE)
+	if (err < PAGE_SIZE)
 		/* zero fill remainder of page */
-		zero_user_segment(page, err, PAGE_CACHE_SIZE);
+		zero_user_segment(page, err, PAGE_SIZE);
 	else
 		flush_dcache_page(page);
 
@@ -278,10 +278,10 @@ static void finish_read(struct ceph_osd_request *req, struct ceph_msg *msg)
 
 		if (rc < 0 && rc != ENOENT)
 			goto unlock;
-		if (bytes < (int)PAGE_CACHE_SIZE) {
+		if (bytes < (int)PAGE_SIZE) {
 			/* zero (remainder of) page */
 			int s = bytes < 0 ? 0 : bytes;
-			zero_user_segment(page, s, PAGE_CACHE_SIZE);
+			zero_user_segment(page, s, PAGE_SIZE);
 		}
  		dout("finish_read %p uptodate %p idx %lu\n", inode, page,
 		     page->index);
@@ -290,8 +290,8 @@ static void finish_read(struct ceph_osd_request *req, struct ceph_msg *msg)
 		ceph_readpage_to_fscache(inode, page);
 unlock:
 		unlock_page(page);
-		page_cache_release(page);
-		bytes -= PAGE_CACHE_SIZE;
+		put_page(page);
+		bytes -= PAGE_SIZE;
 	}
 	kfree(osd_data->pages);
 }
@@ -336,7 +336,7 @@ static int start_read(struct inode *inode, struct list_head *page_list, int max)
 		if (max && nr_pages == max)
 			break;
 	}
-	len = nr_pages << PAGE_CACHE_SHIFT;
+	len = nr_pages << PAGE_SHIFT;
 	dout("start_read %p nr_pages %d is %lld~%lld\n", inode, nr_pages,
 	     off, len);
 	vino = ceph_vino(inode);
@@ -364,7 +364,7 @@ static int start_read(struct inode *inode, struct list_head *page_list, int max)
 		if (add_to_page_cache_lru(page, &inode->i_data, page->index,
 					  GFP_KERNEL)) {
 			ceph_fscache_uncache_page(inode, page);
-			page_cache_release(page);
+			put_page(page);
 			dout("start_read %p add_to_page_cache failed %p\n",
 			     inode, page);
 			nr_pages = i;
@@ -415,8 +415,8 @@ static int ceph_readpages(struct file *file, struct address_space *mapping,
 	if (rc == 0)
 		goto out;
 
-	if (fsc->mount_options->rsize >= PAGE_CACHE_SIZE)
-		max = (fsc->mount_options->rsize + PAGE_CACHE_SIZE - 1)
+	if (fsc->mount_options->rsize >= PAGE_SIZE)
+		max = (fsc->mount_options->rsize + PAGE_SIZE - 1)
 			>> PAGE_SHIFT;
 
 	dout("readpages %p file %p nr_pages %d max %d\n", inode,
@@ -484,7 +484,7 @@ static int writepage_nounlock(struct page *page, struct writeback_control *wbc)
 	long writeback_stat;
 	u64 truncate_size;
 	u32 truncate_seq;
-	int err = 0, len = PAGE_CACHE_SIZE;
+	int err = 0, len = PAGE_SIZE;
 
 	dout("writepage %p idx %lu\n", page, page->index);
 
@@ -725,9 +725,9 @@ static int ceph_writepages_start(struct address_space *mapping,
 	}
 	if (fsc->mount_options->wsize && fsc->mount_options->wsize < wsize)
 		wsize = fsc->mount_options->wsize;
-	if (wsize < PAGE_CACHE_SIZE)
-		wsize = PAGE_CACHE_SIZE;
-	max_pages_ever = wsize >> PAGE_CACHE_SHIFT;
+	if (wsize < PAGE_SIZE)
+		wsize = PAGE_SIZE;
+	max_pages_ever = wsize >> PAGE_SHIFT;
 
 	pagevec_init(&pvec, 0);
 
@@ -737,8 +737,8 @@ static int ceph_writepages_start(struct address_space *mapping,
 		end = -1;
 		dout(" cyclic, start at %lu\n", start);
 	} else {
-		start = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		start = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		should_loop = 0;
@@ -953,14 +953,14 @@ get_more_pages:
 
 		/* Format the osd request message and submit the write */
 		offset = page_offset(pages[0]);
-		len = (u64)locked_pages << PAGE_CACHE_SHIFT;
+		len = (u64)locked_pages << PAGE_SHIFT;
 		if (snap_size == -1) {
 			len = min(len, (u64)i_size_read(inode) - offset);
 			 /* writepages_finish() clears writeback pages
 			  * according to the data length, so make sure
 			  * data length covers all locked pages */
 			len = max(len, 1 +
-				((u64)(locked_pages - 1) << PAGE_CACHE_SHIFT));
+				((u64)(locked_pages - 1) << PAGE_SHIFT));
 		} else {
 			len = min(len, snap_size - offset);
 		}
@@ -1048,8 +1048,8 @@ static int ceph_update_writeable_page(struct file *file,
 {
 	struct inode *inode = file_inode(file);
 	struct ceph_inode_info *ci = ceph_inode(inode);
-	loff_t page_off = pos & PAGE_CACHE_MASK;
-	int pos_in_page = pos & ~PAGE_CACHE_MASK;
+	loff_t page_off = pos & PAGE_MASK;
+	int pos_in_page = pos & ~PAGE_MASK;
 	int end_in_page = pos_in_page + len;
 	loff_t i_size;
 	int r;
@@ -1104,7 +1104,7 @@ retry_locked:
 	}
 
 	/* full page? */
-	if (pos_in_page == 0 && len == PAGE_CACHE_SIZE)
+	if (pos_in_page == 0 && len == PAGE_SIZE)
 		return 0;
 
 	/* past end of file? */
@@ -1112,12 +1112,12 @@ retry_locked:
 
 	if (page_off >= i_size ||
 	    (pos_in_page == 0 && (pos+len) >= i_size &&
-	     end_in_page - pos_in_page != PAGE_CACHE_SIZE)) {
+	     end_in_page - pos_in_page != PAGE_SIZE)) {
 		dout(" zeroing %p 0 - %d and %d - %d\n",
-		     page, pos_in_page, end_in_page, (int)PAGE_CACHE_SIZE);
+		     page, pos_in_page, end_in_page, (int)PAGE_SIZE);
 		zero_user_segments(page,
 				   0, pos_in_page,
-				   end_in_page, PAGE_CACHE_SIZE);
+				   end_in_page, PAGE_SIZE);
 		return 0;
 	}
 
@@ -1141,7 +1141,7 @@ static int ceph_write_begin(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = file_inode(file);
 	struct page *page;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	int r;
 
 	do {
@@ -1155,7 +1155,7 @@ static int ceph_write_begin(struct file *file, struct address_space *mapping,
 
 		r = ceph_update_writeable_page(file, pos, len, page);
 		if (r < 0)
-			page_cache_release(page);
+			put_page(page);
 		else
 			*pagep = page;
 	} while (r == -EAGAIN);
@@ -1172,7 +1172,7 @@ static int ceph_write_end(struct file *file, struct address_space *mapping,
 			  struct page *page, void *fsdata)
 {
 	struct inode *inode = file_inode(file);
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	int check_cap = 0;
 
 	dout("write_end file %p inode %p page %p %d~%d (%d)\n", file,
@@ -1192,7 +1192,7 @@ static int ceph_write_end(struct file *file, struct address_space *mapping,
 	set_page_dirty(page);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (check_cap)
 		ceph_check_caps(ceph_inode(inode), CHECK_CAPS_AUTHONLY, NULL);
@@ -1235,11 +1235,11 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_file_info *fi = vma->vm_file->private_data;
 	struct page *pinned_page = NULL;
-	loff_t off = vmf->pgoff << PAGE_CACHE_SHIFT;
+	loff_t off = vmf->pgoff << PAGE_SHIFT;
 	int want, got, ret;
 
 	dout("filemap_fault %p %llx.%llx %llu~%zd trying to get caps\n",
-	     inode, ceph_vinop(inode), off, (size_t)PAGE_CACHE_SIZE);
+	     inode, ceph_vinop(inode), off, (size_t)PAGE_SIZE);
 	if (fi->fmode & CEPH_FILE_MODE_LAZY)
 		want = CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LAZYIO;
 	else
@@ -1256,7 +1256,7 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		}
 	}
 	dout("filemap_fault %p %llu~%zd got cap refs on %s\n",
-	     inode, off, (size_t)PAGE_CACHE_SIZE, ceph_cap_string(got));
+	     inode, off, (size_t)PAGE_SIZE, ceph_cap_string(got));
 
 	if ((got & (CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LAZYIO)) ||
 	    ci->i_inline_version == CEPH_INLINE_NONE)
@@ -1265,16 +1265,16 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		ret = -EAGAIN;
 
 	dout("filemap_fault %p %llu~%zd dropping cap refs on %s ret %d\n",
-	     inode, off, (size_t)PAGE_CACHE_SIZE, ceph_cap_string(got), ret);
+	     inode, off, (size_t)PAGE_SIZE, ceph_cap_string(got), ret);
 	if (pinned_page)
-		page_cache_release(pinned_page);
+		put_page(pinned_page);
 	ceph_put_cap_refs(ci, got);
 
 	if (ret != -EAGAIN)
 		return ret;
 
 	/* read inline data */
-	if (off >= PAGE_CACHE_SIZE) {
+	if (off >= PAGE_SIZE) {
 		/* does not support inline data > PAGE_SIZE */
 		ret = VM_FAULT_SIGBUS;
 	} else {
@@ -1291,12 +1291,12 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 					 CEPH_STAT_CAP_INLINE_DATA, true);
 		if (ret1 < 0 || off >= i_size_read(inode)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			ret = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		if (ret1 < PAGE_CACHE_SIZE)
-			zero_user_segment(page, ret1, PAGE_CACHE_SIZE);
+		if (ret1 < PAGE_SIZE)
+			zero_user_segment(page, ret1, PAGE_SIZE);
 		else
 			flush_dcache_page(page);
 		SetPageUptodate(page);
@@ -1305,7 +1305,7 @@ static int ceph_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 out:
 	dout("filemap_fault %p %llu~%zd read inline data ret %d\n",
-	     inode, off, (size_t)PAGE_CACHE_SIZE, ret);
+	     inode, off, (size_t)PAGE_SIZE, ret);
 	return ret;
 }
 
@@ -1343,10 +1343,10 @@ static int ceph_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		}
 	}
 
-	if (off + PAGE_CACHE_SIZE <= size)
-		len = PAGE_CACHE_SIZE;
+	if (off + PAGE_SIZE <= size)
+		len = PAGE_SIZE;
 	else
-		len = size & ~PAGE_CACHE_MASK;
+		len = size & ~PAGE_MASK;
 
 	dout("page_mkwrite %p %llx.%llx %llu~%zd getting caps i_size %llu\n",
 	     inode, ceph_vinop(inode), off, len, size);
@@ -1432,7 +1432,7 @@ void ceph_fill_inline_data(struct inode *inode, struct page *locked_page,
 			return;
 		if (PageUptodate(page)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			return;
 		}
 	}
@@ -1447,14 +1447,14 @@ void ceph_fill_inline_data(struct inode *inode, struct page *locked_page,
 	}
 
 	if (page != locked_page) {
-		if (len < PAGE_CACHE_SIZE)
-			zero_user_segment(page, len, PAGE_CACHE_SIZE);
+		if (len < PAGE_SIZE)
+			zero_user_segment(page, len, PAGE_SIZE);
 		else
 			flush_dcache_page(page);
 
 		SetPageUptodate(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
@@ -1491,7 +1491,7 @@ int ceph_uninline_data(struct file *filp, struct page *locked_page)
 				from_pagecache = true;
 				lock_page(page);
 			} else {
-				page_cache_release(page);
+				put_page(page);
 				page = NULL;
 			}
 		}
@@ -1499,8 +1499,8 @@ int ceph_uninline_data(struct file *filp, struct page *locked_page)
 
 	if (page) {
 		len = i_size_read(inode);
-		if (len > PAGE_CACHE_SIZE)
-			len = PAGE_CACHE_SIZE;
+		if (len > PAGE_SIZE)
+			len = PAGE_SIZE;
 	} else {
 		page = __page_cache_alloc(GFP_NOFS);
 		if (!page) {
@@ -1584,7 +1584,7 @@ out:
 	if (page && page != locked_page) {
 		if (from_pagecache) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		} else
 			__free_pages(page, 0);
 	}
diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index 6fe0ad26a7df..835b1d9a8873 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -2507,7 +2507,7 @@ int ceph_get_caps(struct ceph_inode_info *ci, int need, int want,
 					*pinned_page = page;
 					break;
 				}
-				page_cache_release(page);
+				put_page(page);
 			}
 			/*
 			 * drop cap refs first because getattr while
diff --git a/fs/ceph/dir.c b/fs/ceph/dir.c
index fd11fb231a2e..b91369988eaa 100644
--- a/fs/ceph/dir.c
+++ b/fs/ceph/dir.c
@@ -146,7 +146,7 @@ static int __dcache_readdir(struct file *file,  struct dir_context *ctx,
 	struct inode *dir = d_inode(parent);
 	struct dentry *dentry, *last = NULL;
 	struct ceph_dentry_info *di;
-	unsigned nsize = PAGE_CACHE_SIZE / sizeof(struct dentry *);
+	unsigned nsize = PAGE_SIZE / sizeof(struct dentry *);
 	int err = 0;
 	loff_t ptr_pos = 0;
 	struct ceph_readdir_cache_control cache_ctl = {};
@@ -171,7 +171,7 @@ static int __dcache_readdir(struct file *file,  struct dir_context *ctx,
 		}
 
 		err = -EAGAIN;
-		pgoff = ptr_pos >> PAGE_CACHE_SHIFT;
+		pgoff = ptr_pos >> PAGE_SHIFT;
 		if (!cache_ctl.page || pgoff != page_index(cache_ctl.page)) {
 			ceph_readdir_cache_release(&cache_ctl);
 			cache_ctl.page = find_lock_page(&dir->i_data, pgoff);
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index eb9028e8cfc5..04040daaf5f1 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -459,7 +459,7 @@ more:
 			ret += zlen;
 		}
 
-		didpages = (page_align + ret) >> PAGE_CACHE_SHIFT;
+		didpages = (page_align + ret) >> PAGE_SHIFT;
 		pos += ret;
 		read = pos - off;
 		left -= ret;
@@ -800,8 +800,8 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 
 	if (write) {
 		ret = invalidate_inode_pages2_range(inode->i_mapping,
-					pos >> PAGE_CACHE_SHIFT,
-					(pos + count) >> PAGE_CACHE_SHIFT);
+					pos >> PAGE_SHIFT,
+					(pos + count) >> PAGE_SHIFT);
 		if (ret < 0)
 			dout("invalidate_inode_pages2_range returned %d\n", ret);
 
@@ -866,7 +866,7 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 			 * may block.
 			 */
 			truncate_inode_pages_range(inode->i_mapping, pos,
-					(pos+len) | (PAGE_CACHE_SIZE - 1));
+					(pos+len) | (PAGE_SIZE - 1));
 
 			osd_req_op_init(req, 1, CEPH_OSD_OP_STARTSYNC, 0);
 		}
@@ -1001,8 +1001,8 @@ ceph_sync_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos,
 		return ret;
 
 	ret = invalidate_inode_pages2_range(inode->i_mapping,
-					    pos >> PAGE_CACHE_SHIFT,
-					    (pos + count) >> PAGE_CACHE_SHIFT);
+					    pos >> PAGE_SHIFT,
+					    (pos + count) >> PAGE_SHIFT);
 	if (ret < 0)
 		dout("invalidate_inode_pages2_range returned %d\n", ret);
 
@@ -1031,7 +1031,7 @@ ceph_sync_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos,
 		 * write from beginning of first page,
 		 * regardless of io alignment
 		 */
-		num_pages = (len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		num_pages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 		pages = ceph_alloc_page_vector(num_pages, GFP_KERNEL);
 		if (IS_ERR(pages)) {
@@ -1154,7 +1154,7 @@ again:
 	dout("aio_read %p %llx.%llx dropping cap refs on %s = %d\n",
 	     inode, ceph_vinop(inode), ceph_cap_string(got), (int)ret);
 	if (pinned_page) {
-		page_cache_release(pinned_page);
+		put_page(pinned_page);
 		pinned_page = NULL;
 	}
 	ceph_put_cap_refs(ci, got);
@@ -1183,10 +1183,10 @@ again:
 		if (retry_op == READ_INLINE) {
 			BUG_ON(ret > 0 || read > 0);
 			if (iocb->ki_pos < i_size &&
-			    iocb->ki_pos < PAGE_CACHE_SIZE) {
+			    iocb->ki_pos < PAGE_SIZE) {
 				loff_t end = min_t(loff_t, i_size,
 						   iocb->ki_pos + len);
-				end = min_t(loff_t, end, PAGE_CACHE_SIZE);
+				end = min_t(loff_t, end, PAGE_SIZE);
 				if (statret < end)
 					zero_user_segment(page, statret, end);
 				ret = copy_page_to_iter(page,
@@ -1458,21 +1458,21 @@ static inline void ceph_zero_partial_page(
 	struct inode *inode, loff_t offset, unsigned size)
 {
 	struct page *page;
-	pgoff_t index = offset >> PAGE_CACHE_SHIFT;
+	pgoff_t index = offset >> PAGE_SHIFT;
 
 	page = find_lock_page(inode->i_mapping, index);
 	if (page) {
 		wait_on_page_writeback(page);
-		zero_user(page, offset & (PAGE_CACHE_SIZE - 1), size);
+		zero_user(page, offset & (PAGE_SIZE - 1), size);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
 static void ceph_zero_pagecache_range(struct inode *inode, loff_t offset,
 				      loff_t length)
 {
-	loff_t nearly = round_up(offset, PAGE_CACHE_SIZE);
+	loff_t nearly = round_up(offset, PAGE_SIZE);
 	if (offset < nearly) {
 		loff_t size = nearly - offset;
 		if (length < size)
@@ -1481,8 +1481,8 @@ static void ceph_zero_pagecache_range(struct inode *inode, loff_t offset,
 		offset += size;
 		length -= size;
 	}
-	if (length >= PAGE_CACHE_SIZE) {
-		loff_t size = round_down(length, PAGE_CACHE_SIZE);
+	if (length >= PAGE_SIZE) {
+		loff_t size = round_down(length, PAGE_SIZE);
 		truncate_pagecache_range(inode, offset, offset + size - 1);
 		offset += size;
 		length -= size;
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index e48fd8b23257..d5572db245e5 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -1333,7 +1333,7 @@ void ceph_readdir_cache_release(struct ceph_readdir_cache_control *ctl)
 {
 	if (ctl->page) {
 		kunmap(ctl->page);
-		page_cache_release(ctl->page);
+		put_page(ctl->page);
 		ctl->page = NULL;
 	}
 }
@@ -1343,7 +1343,7 @@ static int fill_readdir_cache(struct inode *dir, struct dentry *dn,
 			      struct ceph_mds_request *req)
 {
 	struct ceph_inode_info *ci = ceph_inode(dir);
-	unsigned nsize = PAGE_CACHE_SIZE / sizeof(struct dentry*);
+	unsigned nsize = PAGE_SIZE / sizeof(struct dentry*);
 	unsigned idx = ctl->index % nsize;
 	pgoff_t pgoff = ctl->index / nsize;
 
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 911d64d865f1..859c0444d3b9 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -1610,7 +1610,7 @@ again:
 	while (!list_empty(&tmp_list)) {
 		if (!msg) {
 			msg = ceph_msg_new(CEPH_MSG_CLIENT_CAPRELEASE,
-					PAGE_CACHE_SIZE, GFP_NOFS, false);
+					PAGE_SIZE, GFP_NOFS, false);
 			if (!msg)
 				goto out_err;
 			head = msg->front.iov_base;
diff --git a/fs/ceph/mds_client.h b/fs/ceph/mds_client.h
index 37712ccffcc6..ee69a537dba5 100644
--- a/fs/ceph/mds_client.h
+++ b/fs/ceph/mds_client.h
@@ -97,7 +97,7 @@ struct ceph_mds_reply_info_parsed {
 /*
  * cap releases are batched and sent to the MDS en masse.
  */
-#define CEPH_CAPS_PER_RELEASE ((PAGE_CACHE_SIZE -			\
+#define CEPH_CAPS_PER_RELEASE ((PAGE_SIZE -			\
 				sizeof(struct ceph_mds_cap_release)) /	\
 			       sizeof(struct ceph_mds_cap_item))
 
diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index ca4d5e8457f1..98acbf7b3efc 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -560,7 +560,7 @@ static struct ceph_fs_client *create_fs_client(struct ceph_mount_options *fsopt,
 
 	/* set up mempools */
 	err = -ENOMEM;
-	page_count = fsc->mount_options->wsize >> PAGE_CACHE_SHIFT;
+	page_count = fsc->mount_options->wsize >> PAGE_SHIFT;
 	size = sizeof (struct page *) * (page_count ? page_count : 1);
 	fsc->wb_pagevec_pool = mempool_create_kmalloc_pool(10, size);
 	if (!fsc->wb_pagevec_pool)
@@ -915,13 +915,13 @@ static int ceph_register_bdi(struct super_block *sb,
 	int err;
 
 	/* set ra_pages based on rasize mount option? */
-	if (fsc->mount_options->rasize >= PAGE_CACHE_SIZE)
+	if (fsc->mount_options->rasize >= PAGE_SIZE)
 		fsc->backing_dev_info.ra_pages =
-			(fsc->mount_options->rasize + PAGE_CACHE_SIZE - 1)
+			(fsc->mount_options->rasize + PAGE_SIZE - 1)
 			>> PAGE_SHIFT;
 	else
 		fsc->backing_dev_info.ra_pages =
-			VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE;
+			VM_MAX_READAHEAD * 1024 / PAGE_SIZE;
 
 	err = bdi_register(&fsc->backing_dev_info, NULL, "ceph-%ld",
 			   atomic_long_inc_return(&bdi_seq));
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 1d86fc620e5c..89201564c346 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -962,7 +962,7 @@ static int cifs_clone_file_range(struct file *src_file, loff_t off,
 	cifs_dbg(FYI, "about to flush pages\n");
 	/* should we flush first and last page first */
 	truncate_inode_pages_range(&target_inode->i_data, destoff,
-				   PAGE_CACHE_ALIGN(destoff + len)-1);
+				   PAGE_ALIGN(destoff + len)-1);
 
 	if (target_tcon->ses->server->ops->duplicate_extents)
 		rc = target_tcon->ses->server->ops->duplicate_extents(xid,
diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
index 76fcb50295a3..a894bf809ff7 100644
--- a/fs/cifs/cifssmb.c
+++ b/fs/cifs/cifssmb.c
@@ -1929,17 +1929,17 @@ cifs_writev_requeue(struct cifs_writedata *wdata)
 
 		wsize = server->ops->wp_retry_size(inode);
 		if (wsize < rest_len) {
-			nr_pages = wsize / PAGE_CACHE_SIZE;
+			nr_pages = wsize / PAGE_SIZE;
 			if (!nr_pages) {
 				rc = -ENOTSUPP;
 				break;
 			}
-			cur_len = nr_pages * PAGE_CACHE_SIZE;
-			tailsz = PAGE_CACHE_SIZE;
+			cur_len = nr_pages * PAGE_SIZE;
+			tailsz = PAGE_SIZE;
 		} else {
-			nr_pages = DIV_ROUND_UP(rest_len, PAGE_CACHE_SIZE);
+			nr_pages = DIV_ROUND_UP(rest_len, PAGE_SIZE);
 			cur_len = rest_len;
-			tailsz = rest_len - (nr_pages - 1) * PAGE_CACHE_SIZE;
+			tailsz = rest_len - (nr_pages - 1) * PAGE_SIZE;
 		}
 
 		wdata2 = cifs_writedata_alloc(nr_pages, cifs_writev_complete);
@@ -1957,7 +1957,7 @@ cifs_writev_requeue(struct cifs_writedata *wdata)
 		wdata2->sync_mode = wdata->sync_mode;
 		wdata2->nr_pages = nr_pages;
 		wdata2->offset = page_offset(wdata2->pages[0]);
-		wdata2->pagesz = PAGE_CACHE_SIZE;
+		wdata2->pagesz = PAGE_SIZE;
 		wdata2->tailsz = tailsz;
 		wdata2->bytes = cur_len;
 
@@ -1975,7 +1975,7 @@ cifs_writev_requeue(struct cifs_writedata *wdata)
 			if (rc != 0 && rc != -EAGAIN) {
 				SetPageError(wdata2->pages[j]);
 				end_page_writeback(wdata2->pages[j]);
-				page_cache_release(wdata2->pages[j]);
+				put_page(wdata2->pages[j]);
 			}
 		}
 
@@ -2018,7 +2018,7 @@ cifs_writev_complete(struct work_struct *work)
 		else if (wdata->result < 0)
 			SetPageError(page);
 		end_page_writeback(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (wdata->result != -EAGAIN)
 		mapping_set_error(inode->i_mapping, wdata->result);
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index a763cd3d9e7c..6f62ac821a84 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -3630,7 +3630,7 @@ try_mount_again:
 	cifs_sb->rsize = server->ops->negotiate_rsize(tcon, volume_info);
 
 	/* tune readahead according to rsize */
-	cifs_sb->bdi.ra_pages = cifs_sb->rsize / PAGE_CACHE_SIZE;
+	cifs_sb->bdi.ra_pages = cifs_sb->rsize / PAGE_SIZE;
 
 remote_path_check:
 #ifdef CONFIG_CIFS_DFS_UPCALL
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index ff882aeaccc6..5ce540dc6996 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1833,7 +1833,7 @@ refind_writable:
 static int cifs_partialpagewrite(struct page *page, unsigned from, unsigned to)
 {
 	struct address_space *mapping = page->mapping;
-	loff_t offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	loff_t offset = (loff_t)page->index << PAGE_SHIFT;
 	char *write_data;
 	int rc = -EFAULT;
 	int bytes_written = 0;
@@ -1849,7 +1849,7 @@ static int cifs_partialpagewrite(struct page *page, unsigned from, unsigned to)
 	write_data = kmap(page);
 	write_data += from;
 
-	if ((to > PAGE_CACHE_SIZE) || (from > to)) {
+	if ((to > PAGE_SIZE) || (from > to)) {
 		kunmap(page);
 		return -EIO;
 	}
@@ -1991,7 +1991,7 @@ wdata_prepare_pages(struct cifs_writedata *wdata, unsigned int found_pages,
 
 	/* put any pages we aren't going to use */
 	for (i = nr_pages; i < found_pages; i++) {
-		page_cache_release(wdata->pages[i]);
+		put_page(wdata->pages[i]);
 		wdata->pages[i] = NULL;
 	}
 
@@ -2009,11 +2009,11 @@ wdata_send_pages(struct cifs_writedata *wdata, unsigned int nr_pages,
 	wdata->sync_mode = wbc->sync_mode;
 	wdata->nr_pages = nr_pages;
 	wdata->offset = page_offset(wdata->pages[0]);
-	wdata->pagesz = PAGE_CACHE_SIZE;
+	wdata->pagesz = PAGE_SIZE;
 	wdata->tailsz = min(i_size_read(mapping->host) -
 			page_offset(wdata->pages[nr_pages - 1]),
-			(loff_t)PAGE_CACHE_SIZE);
-	wdata->bytes = ((nr_pages - 1) * PAGE_CACHE_SIZE) + wdata->tailsz;
+			(loff_t)PAGE_SIZE);
+	wdata->bytes = ((nr_pages - 1) * PAGE_SIZE) + wdata->tailsz;
 
 	if (wdata->cfile != NULL)
 		cifsFileInfo_put(wdata->cfile);
@@ -2047,15 +2047,15 @@ static int cifs_writepages(struct address_space *mapping,
 	 * If wsize is smaller than the page cache size, default to writing
 	 * one page at a time via cifs_writepage
 	 */
-	if (cifs_sb->wsize < PAGE_CACHE_SIZE)
+	if (cifs_sb->wsize < PAGE_SIZE)
 		return generic_writepages(mapping, wbc);
 
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = true;
 		scanned = true;
@@ -2071,7 +2071,7 @@ retry:
 		if (rc)
 			break;
 
-		tofind = min((wsize / PAGE_CACHE_SIZE) - 1, end - index) + 1;
+		tofind = min((wsize / PAGE_SIZE) - 1, end - index) + 1;
 
 		wdata = wdata_alloc_and_fillpages(tofind, mapping, end, &index,
 						  &found_pages);
@@ -2111,7 +2111,7 @@ retry:
 				else
 					SetPageError(wdata->pages[i]);
 				end_page_writeback(wdata->pages[i]);
-				page_cache_release(wdata->pages[i]);
+				put_page(wdata->pages[i]);
 			}
 			if (rc != -EAGAIN)
 				mapping_set_error(mapping, rc);
@@ -2154,7 +2154,7 @@ cifs_writepage_locked(struct page *page, struct writeback_control *wbc)
 
 	xid = get_xid();
 /* BB add check for wbc flags */
-	page_cache_get(page);
+	get_page(page);
 	if (!PageUptodate(page))
 		cifs_dbg(FYI, "ppw - page not up to date\n");
 
@@ -2170,7 +2170,7 @@ cifs_writepage_locked(struct page *page, struct writeback_control *wbc)
 	 */
 	set_page_writeback(page);
 retry_write:
-	rc = cifs_partialpagewrite(page, 0, PAGE_CACHE_SIZE);
+	rc = cifs_partialpagewrite(page, 0, PAGE_SIZE);
 	if (rc == -EAGAIN && wbc->sync_mode == WB_SYNC_ALL)
 		goto retry_write;
 	else if (rc == -EAGAIN)
@@ -2180,7 +2180,7 @@ retry_write:
 	else
 		SetPageUptodate(page);
 	end_page_writeback(page);
-	page_cache_release(page);
+	put_page(page);
 	free_xid(xid);
 	return rc;
 }
@@ -2214,12 +2214,12 @@ static int cifs_write_end(struct file *file, struct address_space *mapping,
 		if (copied == len)
 			SetPageUptodate(page);
 		ClearPageChecked(page);
-	} else if (!PageUptodate(page) && copied == PAGE_CACHE_SIZE)
+	} else if (!PageUptodate(page) && copied == PAGE_SIZE)
 		SetPageUptodate(page);
 
 	if (!PageUptodate(page)) {
 		char *page_data;
-		unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+		unsigned offset = pos & (PAGE_SIZE - 1);
 		unsigned int xid;
 
 		xid = get_xid();
@@ -2248,7 +2248,7 @@ static int cifs_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return rc;
 }
@@ -3286,9 +3286,9 @@ cifs_readv_complete(struct work_struct *work)
 		    (rdata->result == -EAGAIN && got_bytes))
 			cifs_readpage_to_fscache(rdata->mapping->host, page);
 
-		got_bytes -= min_t(unsigned int, PAGE_CACHE_SIZE, got_bytes);
+		got_bytes -= min_t(unsigned int, PAGE_SIZE, got_bytes);
 
-		page_cache_release(page);
+		put_page(page);
 		rdata->pages[i] = NULL;
 	}
 	kref_put(&rdata->refcount, cifs_readdata_release);
@@ -3307,21 +3307,21 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 
 	/* determine the eof that the server (probably) has */
 	eof = CIFS_I(rdata->mapping->host)->server_eof;
-	eof_index = eof ? (eof - 1) >> PAGE_CACHE_SHIFT : 0;
+	eof_index = eof ? (eof - 1) >> PAGE_SHIFT : 0;
 	cifs_dbg(FYI, "eof=%llu eof_index=%lu\n", eof, eof_index);
 
 	rdata->got_bytes = 0;
-	rdata->tailsz = PAGE_CACHE_SIZE;
+	rdata->tailsz = PAGE_SIZE;
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page = rdata->pages[i];
 
-		if (len >= PAGE_CACHE_SIZE) {
+		if (len >= PAGE_SIZE) {
 			/* enough data to fill the page */
 			iov.iov_base = kmap(page);
-			iov.iov_len = PAGE_CACHE_SIZE;
+			iov.iov_len = PAGE_SIZE;
 			cifs_dbg(FYI, "%u: idx=%lu iov_base=%p iov_len=%zu\n",
 				 i, page->index, iov.iov_base, iov.iov_len);
-			len -= PAGE_CACHE_SIZE;
+			len -= PAGE_SIZE;
 		} else if (len > 0) {
 			/* enough for partial page, fill and zero the rest */
 			iov.iov_base = kmap(page);
@@ -3329,7 +3329,7 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 			cifs_dbg(FYI, "%u: idx=%lu iov_base=%p iov_len=%zu\n",
 				 i, page->index, iov.iov_base, iov.iov_len);
 			memset(iov.iov_base + len,
-				'\0', PAGE_CACHE_SIZE - len);
+				'\0', PAGE_SIZE - len);
 			rdata->tailsz = len;
 			len = 0;
 		} else if (page->index > eof_index) {
@@ -3341,12 +3341,12 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 			 * to prevent the VFS from repeatedly attempting to
 			 * fill them until the writes are flushed.
 			 */
-			zero_user(page, 0, PAGE_CACHE_SIZE);
+			zero_user(page, 0, PAGE_SIZE);
 			lru_cache_add_file(page);
 			flush_dcache_page(page);
 			SetPageUptodate(page);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			rdata->pages[i] = NULL;
 			rdata->nr_pages--;
 			continue;
@@ -3354,7 +3354,7 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 			/* no need to hold page hostage */
 			lru_cache_add_file(page);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			rdata->pages[i] = NULL;
 			rdata->nr_pages--;
 			continue;
@@ -3402,8 +3402,8 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 	}
 
 	/* move first page to the tmplist */
-	*offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
-	*bytes = PAGE_CACHE_SIZE;
+	*offset = (loff_t)page->index << PAGE_SHIFT;
+	*bytes = PAGE_SIZE;
 	*nr_pages = 1;
 	list_move_tail(&page->lru, tmplist);
 
@@ -3415,7 +3415,7 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 			break;
 
 		/* would this page push the read over the rsize? */
-		if (*bytes + PAGE_CACHE_SIZE > rsize)
+		if (*bytes + PAGE_SIZE > rsize)
 			break;
 
 		__SetPageLocked(page);
@@ -3424,7 +3424,7 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 			break;
 		}
 		list_move_tail(&page->lru, tmplist);
-		(*bytes) += PAGE_CACHE_SIZE;
+		(*bytes) += PAGE_SIZE;
 		expected_index++;
 		(*nr_pages)++;
 	}
@@ -3493,7 +3493,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 		 * reach this point however since we set ra_pages to 0 when the
 		 * rsize is smaller than a cache page.
 		 */
-		if (unlikely(rsize < PAGE_CACHE_SIZE)) {
+		if (unlikely(rsize < PAGE_SIZE)) {
 			add_credits_and_wake_if(server, credits, 0);
 			return 0;
 		}
@@ -3512,7 +3512,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 				list_del(&page->lru);
 				lru_cache_add_file(page);
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 			}
 			rc = -ENOMEM;
 			add_credits_and_wake_if(server, credits, 0);
@@ -3524,7 +3524,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 		rdata->offset = offset;
 		rdata->bytes = bytes;
 		rdata->pid = pid;
-		rdata->pagesz = PAGE_CACHE_SIZE;
+		rdata->pagesz = PAGE_SIZE;
 		rdata->read_into_pages = cifs_readpages_read_into_pages;
 		rdata->credits = credits;
 
@@ -3542,7 +3542,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 				page = rdata->pages[i];
 				lru_cache_add_file(page);
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 			}
 			/* Fallback to the readpage in error/reconnect cases */
 			kref_put(&rdata->refcount, cifs_readdata_release);
@@ -3577,7 +3577,7 @@ static int cifs_readpage_worker(struct file *file, struct page *page,
 	read_data = kmap(page);
 	/* for reads over a certain size could initiate async read ahead */
 
-	rc = cifs_read(file, read_data, PAGE_CACHE_SIZE, poffset);
+	rc = cifs_read(file, read_data, PAGE_SIZE, poffset);
 
 	if (rc < 0)
 		goto io_error;
@@ -3587,8 +3587,8 @@ static int cifs_readpage_worker(struct file *file, struct page *page,
 	file_inode(file)->i_atime =
 		current_fs_time(file_inode(file)->i_sb);
 
-	if (PAGE_CACHE_SIZE > rc)
-		memset(read_data + rc, 0, PAGE_CACHE_SIZE - rc);
+	if (PAGE_SIZE > rc)
+		memset(read_data + rc, 0, PAGE_SIZE - rc);
 
 	flush_dcache_page(page);
 	SetPageUptodate(page);
@@ -3608,7 +3608,7 @@ read_complete:
 
 static int cifs_readpage(struct file *file, struct page *page)
 {
-	loff_t offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	loff_t offset = (loff_t)page->index << PAGE_SHIFT;
 	int rc = -EACCES;
 	unsigned int xid;
 
@@ -3679,8 +3679,8 @@ static int cifs_write_begin(struct file *file, struct address_space *mapping,
 			struct page **pagep, void **fsdata)
 {
 	int oncethru = 0;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	loff_t offset = pos & (PAGE_CACHE_SIZE - 1);
+	pgoff_t index = pos >> PAGE_SHIFT;
+	loff_t offset = pos & (PAGE_SIZE - 1);
 	loff_t page_start = pos & PAGE_MASK;
 	loff_t i_size;
 	struct page *page;
@@ -3703,7 +3703,7 @@ start:
 	 * the server. If the write is short, we'll end up doing a sync write
 	 * instead.
 	 */
-	if (len == PAGE_CACHE_SIZE)
+	if (len == PAGE_SIZE)
 		goto out;
 
 	/*
@@ -3718,7 +3718,7 @@ start:
 		    (offset == 0 && (pos + len) >= i_size)) {
 			zero_user_segments(page, 0, offset,
 					   offset + len,
-					   PAGE_CACHE_SIZE);
+					   PAGE_SIZE);
 			/*
 			 * PageChecked means that the parts of the page
 			 * to which we're not writing are considered up
@@ -3737,7 +3737,7 @@ start:
 		 * do a sync write instead since PG_uptodate isn't set.
 		 */
 		cifs_readpage_worker(file, page, &page_start);
-		page_cache_release(page);
+		put_page(page);
 		oncethru = 1;
 		goto start;
 	} else {
@@ -3764,7 +3764,7 @@ static void cifs_invalidate_page(struct page *page, unsigned int offset,
 {
 	struct cifsInodeInfo *cifsi = CIFS_I(page->mapping->host);
 
-	if (offset == 0 && length == PAGE_CACHE_SIZE)
+	if (offset == 0 && length == PAGE_SIZE)
 		cifs_fscache_invalidate_page(page, &cifsi->vfs_inode);
 }
 
@@ -3772,7 +3772,7 @@ static int cifs_launder_page(struct page *page)
 {
 	int rc = 0;
 	loff_t range_start = page_offset(page);
-	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
+	loff_t range_end = range_start + (loff_t)(PAGE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = 0,
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index aeb26dbfa1bf..5f9ad5c42180 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -59,7 +59,7 @@ static void cifs_set_ops(struct inode *inode)
 
 		/* check if server can support readpages */
 		if (cifs_sb_master_tcon(cifs_sb)->ses->server->maxBuf <
-				PAGE_CACHE_SIZE + MAX_CIFS_HDR_SIZE)
+				PAGE_SIZE + MAX_CIFS_HDR_SIZE)
 			inode->i_data.a_ops = &cifs_addr_ops_smallbuf;
 		else
 			inode->i_data.a_ops = &cifs_addr_ops;
@@ -2019,8 +2019,8 @@ int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 
 static int cifs_truncate_page(struct address_space *mapping, loff_t from)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE - 1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE - 1);
 	struct page *page;
 	int rc = 0;
 
@@ -2028,9 +2028,9 @@ static int cifs_truncate_page(struct address_space *mapping, loff_t from)
 	if (!page)
 		return -ENOMEM;
 
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return rc;
 }
 
diff --git a/fs/configfs/mount.c b/fs/configfs/mount.c
index a8f3b589a2df..cfd91320e869 100644
--- a/fs/configfs/mount.c
+++ b/fs/configfs/mount.c
@@ -71,8 +71,8 @@ static int configfs_fill_super(struct super_block *sb, void *data, int silent)
 	struct inode *inode;
 	struct dentry *root;
 
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = CONFIGFS_MAGIC;
 	sb->s_op = &configfs_ops;
 	sb->s_time_gran = 1;
diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index b862bc219cd7..2096654dd26d 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -152,7 +152,7 @@ static struct inode *get_cramfs_inode(struct super_block *sb,
  */
 #define BLKS_PER_BUF_SHIFT	(2)
 #define BLKS_PER_BUF		(1 << BLKS_PER_BUF_SHIFT)
-#define BUFFER_SIZE		(BLKS_PER_BUF*PAGE_CACHE_SIZE)
+#define BUFFER_SIZE		(BLKS_PER_BUF*PAGE_SIZE)
 
 static unsigned char read_buffers[READ_BUFFERS][BUFFER_SIZE];
 static unsigned buffer_blocknr[READ_BUFFERS];
@@ -173,8 +173,8 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 
 	if (!len)
 		return NULL;
-	blocknr = offset >> PAGE_CACHE_SHIFT;
-	offset &= PAGE_CACHE_SIZE - 1;
+	blocknr = offset >> PAGE_SHIFT;
+	offset &= PAGE_SIZE - 1;
 
 	/* Check if an existing buffer already has the data.. */
 	for (i = 0; i < READ_BUFFERS; i++) {
@@ -184,14 +184,14 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 			continue;
 		if (blocknr < buffer_blocknr[i])
 			continue;
-		blk_offset = (blocknr - buffer_blocknr[i]) << PAGE_CACHE_SHIFT;
+		blk_offset = (blocknr - buffer_blocknr[i]) << PAGE_SHIFT;
 		blk_offset += offset;
 		if (blk_offset + len > BUFFER_SIZE)
 			continue;
 		return read_buffers[i] + blk_offset;
 	}
 
-	devsize = mapping->host->i_size >> PAGE_CACHE_SHIFT;
+	devsize = mapping->host->i_size >> PAGE_SHIFT;
 
 	/* Ok, read in BLKS_PER_BUF pages completely first. */
 	for (i = 0; i < BLKS_PER_BUF; i++) {
@@ -213,7 +213,7 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 			wait_on_page_locked(page);
 			if (!PageUptodate(page)) {
 				/* asynchronous error */
-				page_cache_release(page);
+				put_page(page);
 				pages[i] = NULL;
 			}
 		}
@@ -229,12 +229,12 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 		struct page *page = pages[i];
 
 		if (page) {
-			memcpy(data, kmap(page), PAGE_CACHE_SIZE);
+			memcpy(data, kmap(page), PAGE_SIZE);
 			kunmap(page);
-			page_cache_release(page);
+			put_page(page);
 		} else
-			memset(data, 0, PAGE_CACHE_SIZE);
-		data += PAGE_CACHE_SIZE;
+			memset(data, 0, PAGE_SIZE);
+		data += PAGE_SIZE;
 	}
 	return read_buffers[buffer] + offset;
 }
@@ -353,7 +353,7 @@ static int cramfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	u64 id = huge_encode_dev(sb->s_bdev->bd_dev);
 
 	buf->f_type = CRAMFS_MAGIC;
-	buf->f_bsize = PAGE_CACHE_SIZE;
+	buf->f_bsize = PAGE_SIZE;
 	buf->f_blocks = CRAMFS_SB(sb)->blocks;
 	buf->f_bfree = 0;
 	buf->f_bavail = 0;
@@ -496,7 +496,7 @@ static int cramfs_readpage(struct file *file, struct page *page)
 	int bytes_filled;
 	void *pgdata;
 
-	maxblock = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	maxblock = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	bytes_filled = 0;
 	pgdata = kmap(page);
 
@@ -516,14 +516,14 @@ static int cramfs_readpage(struct file *file, struct page *page)
 
 		if (compr_len == 0)
 			; /* hole */
-		else if (unlikely(compr_len > (PAGE_CACHE_SIZE << 1))) {
+		else if (unlikely(compr_len > (PAGE_SIZE << 1))) {
 			pr_err("bad compressed blocksize %u\n",
 				compr_len);
 			goto err;
 		} else {
 			mutex_lock(&read_mutex);
 			bytes_filled = cramfs_uncompress_block(pgdata,
-				 PAGE_CACHE_SIZE,
+				 PAGE_SIZE,
 				 cramfs_read(sb, start_offset, compr_len),
 				 compr_len);
 			mutex_unlock(&read_mutex);
@@ -532,7 +532,7 @@ static int cramfs_readpage(struct file *file, struct page *page)
 		}
 	}
 
-	memset(pgdata + bytes_filled, 0, PAGE_CACHE_SIZE - bytes_filled);
+	memset(pgdata + bytes_filled, 0, PAGE_SIZE - bytes_filled);
 	flush_dcache_page(page);
 	kunmap(page);
 	SetPageUptodate(page);
diff --git a/fs/dax.c b/fs/dax.c
index bbb2ad783770..9df3f192d625 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -318,7 +318,7 @@ static int dax_load_hole(struct address_space *mapping, struct page *page,
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return VM_FAULT_SIGBUS;
 	}
 
@@ -346,7 +346,7 @@ static int copy_user_bh(struct page *to, struct inode *inode,
 }
 
 #define NO_SECTOR -1
-#define DAX_PMD_INDEX(page_index) (page_index & (PMD_MASK >> PAGE_CACHE_SHIFT))
+#define DAX_PMD_INDEX(page_index) (page_index & (PMD_MASK >> PAGE_SHIFT))
 
 static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
 		sector_t sector, bool pmd_entry, bool dirty)
@@ -501,8 +501,8 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 	if (!mapping->nrexceptional || wbc->sync_mode != WB_SYNC_ALL)
 		return 0;
 
-	start_index = wbc->range_start >> PAGE_CACHE_SHIFT;
-	end_index = wbc->range_end >> PAGE_CACHE_SHIFT;
+	start_index = wbc->range_start >> PAGE_SHIFT;
+	end_index = wbc->range_end >> PAGE_SHIFT;
 	pmd_index = DAX_PMD_INDEX(start_index);
 
 	rcu_read_lock();
@@ -637,12 +637,12 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	page = find_get_page(mapping, vmf->pgoff);
 	if (page) {
 		if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
-			page_cache_release(page);
+			put_page(page);
 			return VM_FAULT_RETRY;
 		}
 		if (unlikely(page->mapping != mapping)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
@@ -706,10 +706,10 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 
 	if (page) {
 		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
-							PAGE_CACHE_SIZE, 0);
+							PAGE_SIZE, 0);
 		delete_from_page_cache(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 
@@ -742,7 +742,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
  unlock_page:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	goto out;
 }
@@ -1099,18 +1099,18 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 							get_block_t get_block)
 {
 	struct buffer_head bh;
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	int err;
 
 	/* Block boundary? Nothing to do */
 	if (!length)
 		return 0;
-	BUG_ON((offset + length) > PAGE_CACHE_SIZE);
+	BUG_ON((offset + length) > PAGE_SIZE);
 
 	memset(&bh, 0, sizeof(bh));
 	bh.b_bdev = inode->i_sb->s_bdev;
-	bh.b_size = PAGE_CACHE_SIZE;
+	bh.b_size = PAGE_SIZE;
 	err = get_block(inode, index, &bh, 0);
 	if (err < 0)
 		return err;
@@ -1118,7 +1118,7 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
 		struct block_device *bdev = bh.b_bdev;
 		struct blk_dax_ctl dax = {
 			.sector = to_sector(&bh, inode),
-			.size = PAGE_CACHE_SIZE,
+			.size = PAGE_SIZE,
 		};
 
 		if (dax_map_atomic(bdev, &dax) < 0)
@@ -1149,7 +1149,7 @@ EXPORT_SYMBOL_GPL(dax_zero_page_range);
  */
 int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 {
-	unsigned length = PAGE_CACHE_ALIGN(from) - from;
+	unsigned length = PAGE_ALIGN(from) - from;
 	return dax_zero_page_range(inode, from, length, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_truncate_page);
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 0a8d937c6775..9a65345a57ad 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -172,7 +172,7 @@ static inline int dio_refill_pages(struct dio *dio, struct dio_submit *sdio)
 		 */
 		if (dio->page_errors == 0)
 			dio->page_errors = ret;
-		page_cache_get(page);
+		get_page(page);
 		dio->pages[0] = page;
 		sdio->head = 0;
 		sdio->tail = 1;
@@ -419,7 +419,7 @@ static inline void dio_bio_submit(struct dio *dio, struct dio_submit *sdio)
 static inline void dio_cleanup(struct dio *dio, struct dio_submit *sdio)
 {
 	while (sdio->head < sdio->tail)
-		page_cache_release(dio->pages[sdio->head++]);
+		put_page(dio->pages[sdio->head++]);
 }
 
 /*
@@ -482,7 +482,7 @@ static int dio_bio_complete(struct dio *dio, struct bio *bio)
 			if (dio->rw == READ && !PageCompound(page) &&
 					dio->should_dirty)
 				set_page_dirty_lock(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 		err = bio->bi_error;
 		bio_put(bio);
@@ -691,7 +691,7 @@ static inline int dio_bio_add_page(struct dio_submit *sdio)
 		 */
 		if ((sdio->cur_page_len + sdio->cur_page_offset) == PAGE_SIZE)
 			sdio->pages_in_io--;
-		page_cache_get(sdio->cur_page);
+		get_page(sdio->cur_page);
 		sdio->final_block_in_bio = sdio->cur_page_block +
 			(sdio->cur_page_len >> sdio->blkbits);
 		ret = 0;
@@ -805,13 +805,13 @@ submit_page_section(struct dio *dio, struct dio_submit *sdio, struct page *page,
 	 */
 	if (sdio->cur_page) {
 		ret = dio_send_cur_page(dio, sdio, map_bh);
-		page_cache_release(sdio->cur_page);
+		put_page(sdio->cur_page);
 		sdio->cur_page = NULL;
 		if (ret)
 			return ret;
 	}
 
-	page_cache_get(page);		/* It is in dio */
+	get_page(page);		/* It is in dio */
 	sdio->cur_page = page;
 	sdio->cur_page_offset = offset;
 	sdio->cur_page_len = len;
@@ -825,7 +825,7 @@ out:
 	if (sdio->boundary) {
 		ret = dio_send_cur_page(dio, sdio, map_bh);
 		dio_bio_submit(dio, sdio);
-		page_cache_release(sdio->cur_page);
+		put_page(sdio->cur_page);
 		sdio->cur_page = NULL;
 	}
 	return ret;
@@ -942,7 +942,7 @@ static int do_direct_IO(struct dio *dio, struct dio_submit *sdio,
 
 				ret = get_more_blocks(dio, sdio, map_bh);
 				if (ret) {
-					page_cache_release(page);
+					put_page(page);
 					goto out;
 				}
 				if (!buffer_mapped(map_bh))
@@ -983,7 +983,7 @@ do_holes:
 
 				/* AKPM: eargh, -ENOTBLK is a hack */
 				if (dio->rw & WRITE) {
-					page_cache_release(page);
+					put_page(page);
 					return -ENOTBLK;
 				}
 
@@ -996,7 +996,7 @@ do_holes:
 				if (sdio->block_in_file >=
 						i_size_aligned >> blkbits) {
 					/* We hit eof */
-					page_cache_release(page);
+					put_page(page);
 					goto out;
 				}
 				zero_user(page, from, 1 << blkbits);
@@ -1036,7 +1036,7 @@ do_holes:
 						  sdio->next_block_for_io,
 						  map_bh);
 			if (ret) {
-				page_cache_release(page);
+				put_page(page);
 				goto out;
 			}
 			sdio->next_block_for_io += this_chunk_blocks;
@@ -1052,7 +1052,7 @@ next_block:
 		}
 
 		/* Drop the ref which was taken in get_user_pages() */
-		page_cache_release(page);
+		put_page(page);
 	}
 out:
 	return ret;
@@ -1276,7 +1276,7 @@ do_blockdev_direct_IO(struct kiocb *iocb, struct inode *inode,
 		ret2 = dio_send_cur_page(dio, &sdio, &map_bh);
 		if (retval == 0)
 			retval = ret2;
-		page_cache_release(sdio.cur_page);
+		put_page(sdio.cur_page);
 		sdio.cur_page = NULL;
 	}
 	if (sdio.bio)
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 00640e70ed7a..1ab012a27d9f 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -640,7 +640,7 @@ static int receive_from_sock(struct connection *con)
 		con->rx_page = alloc_page(GFP_ATOMIC);
 		if (con->rx_page == NULL)
 			goto out_resched;
-		cbuf_init(&con->cb, PAGE_CACHE_SIZE);
+		cbuf_init(&con->cb, PAGE_SIZE);
 	}
 
 	/*
@@ -657,7 +657,7 @@ static int receive_from_sock(struct connection *con)
 	 * buffer and the start of the currently used section (cb.base)
 	 */
 	if (cbuf_data(&con->cb) >= con->cb.base) {
-		iov[0].iov_len = PAGE_CACHE_SIZE - cbuf_data(&con->cb);
+		iov[0].iov_len = PAGE_SIZE - cbuf_data(&con->cb);
 		iov[1].iov_len = con->cb.base;
 		iov[1].iov_base = page_address(con->rx_page);
 		nvec = 2;
@@ -675,7 +675,7 @@ static int receive_from_sock(struct connection *con)
 	ret = dlm_process_incoming_buffer(con->nodeid,
 					  page_address(con->rx_page),
 					  con->cb.base, con->cb.len,
-					  PAGE_CACHE_SIZE);
+					  PAGE_SIZE);
 	if (ret == -EBADMSG) {
 		log_print("lowcomms: addr=%p, base=%u, len=%u, read=%d",
 			  page_address(con->rx_page), con->cb.base,
@@ -1416,7 +1416,7 @@ void *dlm_lowcomms_get_buffer(int nodeid, int len, gfp_t allocation, char **ppc)
 	spin_lock(&con->writequeue_lock);
 	e = list_entry(con->writequeue.prev, struct writequeue_entry, list);
 	if ((&e->list == &con->writequeue) ||
-	    (PAGE_CACHE_SIZE - e->end < len)) {
+	    (PAGE_SIZE - e->end < len)) {
 		e = NULL;
 	} else {
 		offset = e->end;
diff --git a/fs/ecryptfs/crypto.c b/fs/ecryptfs/crypto.c
index 64026e53722a..d09cb4cdd09f 100644
--- a/fs/ecryptfs/crypto.c
+++ b/fs/ecryptfs/crypto.c
@@ -286,7 +286,7 @@ int virt_to_scatterlist(const void *addr, int size, struct scatterlist *sg,
 		pg = virt_to_page(addr);
 		offset = offset_in_page(addr);
 		sg_set_page(&sg[i], pg, 0, offset);
-		remainder_of_page = PAGE_CACHE_SIZE - offset;
+		remainder_of_page = PAGE_SIZE - offset;
 		if (size >= remainder_of_page) {
 			sg[i].length = remainder_of_page;
 			addr += remainder_of_page;
@@ -400,7 +400,7 @@ static loff_t lower_offset_for_page(struct ecryptfs_crypt_stat *crypt_stat,
 				    struct page *page)
 {
 	return ecryptfs_lower_header_size(crypt_stat) +
-	       ((loff_t)page->index << PAGE_CACHE_SHIFT);
+	       ((loff_t)page->index << PAGE_SHIFT);
 }
 
 /**
@@ -428,7 +428,7 @@ static int crypt_extent(struct ecryptfs_crypt_stat *crypt_stat,
 	size_t extent_size = crypt_stat->extent_size;
 	int rc;
 
-	extent_base = (((loff_t)page_index) * (PAGE_CACHE_SIZE / extent_size));
+	extent_base = (((loff_t)page_index) * (PAGE_SIZE / extent_size));
 	rc = ecryptfs_derive_iv(extent_iv, crypt_stat,
 				(extent_base + extent_offset));
 	if (rc) {
@@ -498,7 +498,7 @@ int ecryptfs_encrypt_page(struct page *page)
 	}
 
 	for (extent_offset = 0;
-	     extent_offset < (PAGE_CACHE_SIZE / crypt_stat->extent_size);
+	     extent_offset < (PAGE_SIZE / crypt_stat->extent_size);
 	     extent_offset++) {
 		rc = crypt_extent(crypt_stat, enc_extent_page, page,
 				  extent_offset, ENCRYPT);
@@ -512,7 +512,7 @@ int ecryptfs_encrypt_page(struct page *page)
 	lower_offset = lower_offset_for_page(crypt_stat, page);
 	enc_extent_virt = kmap(enc_extent_page);
 	rc = ecryptfs_write_lower(ecryptfs_inode, enc_extent_virt, lower_offset,
-				  PAGE_CACHE_SIZE);
+				  PAGE_SIZE);
 	kunmap(enc_extent_page);
 	if (rc < 0) {
 		ecryptfs_printk(KERN_ERR,
@@ -560,7 +560,7 @@ int ecryptfs_decrypt_page(struct page *page)
 
 	lower_offset = lower_offset_for_page(crypt_stat, page);
 	page_virt = kmap(page);
-	rc = ecryptfs_read_lower(page_virt, lower_offset, PAGE_CACHE_SIZE,
+	rc = ecryptfs_read_lower(page_virt, lower_offset, PAGE_SIZE,
 				 ecryptfs_inode);
 	kunmap(page);
 	if (rc < 0) {
@@ -571,7 +571,7 @@ int ecryptfs_decrypt_page(struct page *page)
 	}
 
 	for (extent_offset = 0;
-	     extent_offset < (PAGE_CACHE_SIZE / crypt_stat->extent_size);
+	     extent_offset < (PAGE_SIZE / crypt_stat->extent_size);
 	     extent_offset++) {
 		rc = crypt_extent(crypt_stat, page, page,
 				  extent_offset, DECRYPT);
@@ -659,11 +659,11 @@ void ecryptfs_set_default_sizes(struct ecryptfs_crypt_stat *crypt_stat)
 	if (crypt_stat->flags & ECRYPTFS_METADATA_IN_XATTR)
 		crypt_stat->metadata_size = ECRYPTFS_MINIMUM_HEADER_EXTENT_SIZE;
 	else {
-		if (PAGE_CACHE_SIZE <= ECRYPTFS_MINIMUM_HEADER_EXTENT_SIZE)
+		if (PAGE_SIZE <= ECRYPTFS_MINIMUM_HEADER_EXTENT_SIZE)
 			crypt_stat->metadata_size =
 				ECRYPTFS_MINIMUM_HEADER_EXTENT_SIZE;
 		else
-			crypt_stat->metadata_size = PAGE_CACHE_SIZE;
+			crypt_stat->metadata_size = PAGE_SIZE;
 	}
 }
 
@@ -1442,7 +1442,7 @@ int ecryptfs_read_metadata(struct dentry *ecryptfs_dentry)
 						ECRYPTFS_VALIDATE_HEADER_SIZE);
 	if (rc) {
 		/* metadata is not in the file header, so try xattrs */
-		memset(page_virt, 0, PAGE_CACHE_SIZE);
+		memset(page_virt, 0, PAGE_SIZE);
 		rc = ecryptfs_read_xattr_region(page_virt, ecryptfs_inode);
 		if (rc) {
 			printk(KERN_DEBUG "Valid eCryptfs headers not found in "
@@ -1475,7 +1475,7 @@ int ecryptfs_read_metadata(struct dentry *ecryptfs_dentry)
 	}
 out:
 	if (page_virt) {
-		memset(page_virt, 0, PAGE_CACHE_SIZE);
+		memset(page_virt, 0, PAGE_SIZE);
 		kmem_cache_free(ecryptfs_header_cache, page_virt);
 	}
 	return rc;
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 121114e9a464..2a988f3a0cdb 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -765,8 +765,8 @@ static int truncate_upper(struct dentry *dentry, struct iattr *ia,
 		 * in which ia->ia_size is located. Fill in the end of
 		 * that page from (ia->ia_size & ~PAGE_CACHE_MASK) to
 		 * PAGE_CACHE_SIZE with zeros. */
-		size_t num_zeros = (PAGE_CACHE_SIZE
-				    - (ia->ia_size & ~PAGE_CACHE_MASK));
+		size_t num_zeros = (PAGE_SIZE
+				    - (ia->ia_size & ~PAGE_MASK));
 
 		if (!(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 			truncate_setsize(inode, ia->ia_size);
diff --git a/fs/ecryptfs/keystore.c b/fs/ecryptfs/keystore.c
index c5c84dfb5b3e..3274c469b42f 100644
--- a/fs/ecryptfs/keystore.c
+++ b/fs/ecryptfs/keystore.c
@@ -1800,7 +1800,7 @@ int ecryptfs_parse_packet_set(struct ecryptfs_crypt_stat *crypt_stat,
 	 * added the our &auth_tok_list */
 	next_packet_is_auth_tok_packet = 1;
 	while (next_packet_is_auth_tok_packet) {
-		size_t max_packet_size = ((PAGE_CACHE_SIZE - 8) - i);
+		size_t max_packet_size = ((PAGE_SIZE - 8) - i);
 
 		switch (src[i]) {
 		case ECRYPTFS_TAG_3_PACKET_TYPE:
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index 8b0b4a73116d..1698132d0e57 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -695,12 +695,12 @@ static struct ecryptfs_cache_info {
 	{
 		.cache = &ecryptfs_header_cache,
 		.name = "ecryptfs_headers",
-		.size = PAGE_CACHE_SIZE,
+		.size = PAGE_SIZE,
 	},
 	{
 		.cache = &ecryptfs_xattr_cache,
 		.name = "ecryptfs_xattr_cache",
-		.size = PAGE_CACHE_SIZE,
+		.size = PAGE_SIZE,
 	},
 	{
 		.cache = &ecryptfs_key_record_cache,
@@ -818,7 +818,7 @@ static int __init ecryptfs_init(void)
 {
 	int rc;
 
-	if (ECRYPTFS_DEFAULT_EXTENT_SIZE > PAGE_CACHE_SIZE) {
+	if (ECRYPTFS_DEFAULT_EXTENT_SIZE > PAGE_SIZE) {
 		rc = -EINVAL;
 		ecryptfs_printk(KERN_ERR, "The eCryptfs extent size is "
 				"larger than the host's page size, and so "
@@ -826,7 +826,7 @@ static int __init ecryptfs_init(void)
 				"default eCryptfs extent size is [%u] bytes; "
 				"the page size is [%lu] bytes.\n",
 				ECRYPTFS_DEFAULT_EXTENT_SIZE,
-				(unsigned long)PAGE_CACHE_SIZE);
+				(unsigned long)PAGE_SIZE);
 		goto out;
 	}
 	rc = ecryptfs_init_kmem_caches();
diff --git a/fs/ecryptfs/mmap.c b/fs/ecryptfs/mmap.c
index 1f5865263b3e..e6b1d80952b9 100644
--- a/fs/ecryptfs/mmap.c
+++ b/fs/ecryptfs/mmap.c
@@ -122,7 +122,7 @@ ecryptfs_copy_up_encrypted_with_header(struct page *page,
 				       struct ecryptfs_crypt_stat *crypt_stat)
 {
 	loff_t extent_num_in_page = 0;
-	loff_t num_extents_per_page = (PAGE_CACHE_SIZE
+	loff_t num_extents_per_page = (PAGE_SIZE
 				       / crypt_stat->extent_size);
 	int rc = 0;
 
@@ -138,7 +138,7 @@ ecryptfs_copy_up_encrypted_with_header(struct page *page,
 			char *page_virt;
 
 			page_virt = kmap_atomic(page);
-			memset(page_virt, 0, PAGE_CACHE_SIZE);
+			memset(page_virt, 0, PAGE_SIZE);
 			/* TODO: Support more than one header extent */
 			if (view_extent_num == 0) {
 				size_t written;
@@ -164,8 +164,8 @@ ecryptfs_copy_up_encrypted_with_header(struct page *page,
 				 - crypt_stat->metadata_size);
 
 			rc = ecryptfs_read_lower_page_segment(
-				page, (lower_offset >> PAGE_CACHE_SHIFT),
-				(lower_offset & ~PAGE_CACHE_MASK),
+				page, (lower_offset >> PAGE_SHIFT),
+				(lower_offset & ~PAGE_MASK),
 				crypt_stat->extent_size, page->mapping->host);
 			if (rc) {
 				printk(KERN_ERR "%s: Error attempting to read "
@@ -198,7 +198,7 @@ static int ecryptfs_readpage(struct file *file, struct page *page)
 
 	if (!crypt_stat || !(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 		rc = ecryptfs_read_lower_page_segment(page, page->index, 0,
-						      PAGE_CACHE_SIZE,
+						      PAGE_SIZE,
 						      page->mapping->host);
 	} else if (crypt_stat->flags & ECRYPTFS_VIEW_AS_ENCRYPTED) {
 		if (crypt_stat->flags & ECRYPTFS_METADATA_IN_XATTR) {
@@ -215,7 +215,7 @@ static int ecryptfs_readpage(struct file *file, struct page *page)
 
 		} else {
 			rc = ecryptfs_read_lower_page_segment(
-				page, page->index, 0, PAGE_CACHE_SIZE,
+				page, page->index, 0, PAGE_SIZE,
 				page->mapping->host);
 			if (rc) {
 				printk(KERN_ERR "Error reading page; rc = "
@@ -250,12 +250,12 @@ static int fill_zeros_to_end_of_page(struct page *page, unsigned int to)
 	struct inode *inode = page->mapping->host;
 	int end_byte_in_page;
 
-	if ((i_size_read(inode) / PAGE_CACHE_SIZE) != page->index)
+	if ((i_size_read(inode) / PAGE_SIZE) != page->index)
 		goto out;
-	end_byte_in_page = i_size_read(inode) % PAGE_CACHE_SIZE;
+	end_byte_in_page = i_size_read(inode) % PAGE_SIZE;
 	if (to > end_byte_in_page)
 		end_byte_in_page = to;
-	zero_user_segment(page, end_byte_in_page, PAGE_CACHE_SIZE);
+	zero_user_segment(page, end_byte_in_page, PAGE_SIZE);
 out:
 	return 0;
 }
@@ -279,7 +279,7 @@ static int ecryptfs_write_begin(struct file *file,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	loff_t prev_page_end_size;
 	int rc = 0;
@@ -289,14 +289,14 @@ static int ecryptfs_write_begin(struct file *file,
 		return -ENOMEM;
 	*pagep = page;
 
-	prev_page_end_size = ((loff_t)index << PAGE_CACHE_SHIFT);
+	prev_page_end_size = ((loff_t)index << PAGE_SHIFT);
 	if (!PageUptodate(page)) {
 		struct ecryptfs_crypt_stat *crypt_stat =
 			&ecryptfs_inode_to_private(mapping->host)->crypt_stat;
 
 		if (!(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 			rc = ecryptfs_read_lower_page_segment(
-				page, index, 0, PAGE_CACHE_SIZE, mapping->host);
+				page, index, 0, PAGE_SIZE, mapping->host);
 			if (rc) {
 				printk(KERN_ERR "%s: Error attempting to read "
 				       "lower page segment; rc = [%d]\n",
@@ -322,7 +322,7 @@ static int ecryptfs_write_begin(struct file *file,
 				SetPageUptodate(page);
 			} else {
 				rc = ecryptfs_read_lower_page_segment(
-					page, index, 0, PAGE_CACHE_SIZE,
+					page, index, 0, PAGE_SIZE,
 					mapping->host);
 				if (rc) {
 					printk(KERN_ERR "%s: Error reading "
@@ -336,9 +336,9 @@ static int ecryptfs_write_begin(struct file *file,
 		} else {
 			if (prev_page_end_size
 			    >= i_size_read(page->mapping->host)) {
-				zero_user(page, 0, PAGE_CACHE_SIZE);
+				zero_user(page, 0, PAGE_SIZE);
 				SetPageUptodate(page);
-			} else if (len < PAGE_CACHE_SIZE) {
+			} else if (len < PAGE_SIZE) {
 				rc = ecryptfs_decrypt_page(page);
 				if (rc) {
 					printk(KERN_ERR "%s: Error decrypting "
@@ -371,11 +371,11 @@ static int ecryptfs_write_begin(struct file *file,
 	 * of page?  Zero it out. */
 	if ((i_size_read(mapping->host) == prev_page_end_size)
 	    && (pos != 0))
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+		zero_user(page, 0, PAGE_SIZE);
 out:
 	if (unlikely(rc)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		*pagep = NULL;
 	}
 	return rc;
@@ -437,7 +437,7 @@ static int ecryptfs_write_inode_size_to_xattr(struct inode *ecryptfs_inode)
 	}
 	inode_lock(lower_inode);
 	size = lower_inode->i_op->getxattr(lower_dentry, ECRYPTFS_XATTR_NAME,
-					   xattr_virt, PAGE_CACHE_SIZE);
+					   xattr_virt, PAGE_SIZE);
 	if (size < 0)
 		size = 8;
 	put_unaligned_be64(i_size_read(ecryptfs_inode), xattr_virt);
@@ -479,8 +479,8 @@ static int ecryptfs_write_end(struct file *file,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	pgoff_t index = pos >> PAGE_SHIFT;
+	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + copied;
 	struct inode *ecryptfs_inode = mapping->host;
 	struct ecryptfs_crypt_stat *crypt_stat =
@@ -500,7 +500,7 @@ static int ecryptfs_write_end(struct file *file,
 		goto out;
 	}
 	if (!PageUptodate(page)) {
-		if (copied < PAGE_CACHE_SIZE) {
+		if (copied < PAGE_SIZE) {
 			rc = 0;
 			goto out;
 		}
@@ -533,7 +533,7 @@ static int ecryptfs_write_end(struct file *file,
 		rc = copied;
 out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return rc;
 }
 
diff --git a/fs/ecryptfs/read_write.c b/fs/ecryptfs/read_write.c
index 09fe622274e4..158a3a39f82d 100644
--- a/fs/ecryptfs/read_write.c
+++ b/fs/ecryptfs/read_write.c
@@ -74,7 +74,7 @@ int ecryptfs_write_lower_page_segment(struct inode *ecryptfs_inode,
 	loff_t offset;
 	int rc;
 
-	offset = ((((loff_t)page_for_lower->index) << PAGE_CACHE_SHIFT)
+	offset = ((((loff_t)page_for_lower->index) << PAGE_SHIFT)
 		  + offset_in_page);
 	virt = kmap(page_for_lower);
 	rc = ecryptfs_write_lower(ecryptfs_inode, virt, offset, size);
@@ -123,9 +123,9 @@ int ecryptfs_write(struct inode *ecryptfs_inode, char *data, loff_t offset,
 	else
 		pos = offset;
 	while (pos < (offset + size)) {
-		pgoff_t ecryptfs_page_idx = (pos >> PAGE_CACHE_SHIFT);
-		size_t start_offset_in_page = (pos & ~PAGE_CACHE_MASK);
-		size_t num_bytes = (PAGE_CACHE_SIZE - start_offset_in_page);
+		pgoff_t ecryptfs_page_idx = (pos >> PAGE_SHIFT);
+		size_t start_offset_in_page = (pos & ~PAGE_MASK);
+		size_t num_bytes = (PAGE_SIZE - start_offset_in_page);
 		loff_t total_remaining_bytes = ((offset + size) - pos);
 
 		if (fatal_signal_pending(current)) {
@@ -165,7 +165,7 @@ int ecryptfs_write(struct inode *ecryptfs_inode, char *data, loff_t offset,
 			 * Fill in zero values to the end of the page */
 			memset(((char *)ecryptfs_page_virt
 				+ start_offset_in_page), 0,
-				PAGE_CACHE_SIZE - start_offset_in_page);
+				PAGE_SIZE - start_offset_in_page);
 		}
 
 		/* pos >= offset, we are now writing the data request */
@@ -186,7 +186,7 @@ int ecryptfs_write(struct inode *ecryptfs_inode, char *data, loff_t offset,
 						ecryptfs_page,
 						start_offset_in_page,
 						data_offset);
-		page_cache_release(ecryptfs_page);
+		put_page(ecryptfs_page);
 		if (rc) {
 			printk(KERN_ERR "%s: Error encrypting "
 			       "page; rc = [%d]\n", __func__, rc);
@@ -262,7 +262,7 @@ int ecryptfs_read_lower_page_segment(struct page *page_for_ecryptfs,
 	loff_t offset;
 	int rc;
 
-	offset = ((((loff_t)page_index) << PAGE_CACHE_SHIFT) + offset_in_page);
+	offset = ((((loff_t)page_index) << PAGE_SHIFT) + offset_in_page);
 	virt = kmap(page_for_ecryptfs);
 	rc = ecryptfs_read_lower(virt, offset, size, ecryptfs_inode);
 	if (rc > 0)
diff --git a/fs/efivarfs/super.c b/fs/efivarfs/super.c
index dd029d13ea61..553c5d2db4a4 100644
--- a/fs/efivarfs/super.c
+++ b/fs/efivarfs/super.c
@@ -197,8 +197,8 @@ static int efivarfs_fill_super(struct super_block *sb, void *data, int silent)
 	efivarfs_sb = sb;
 
 	sb->s_maxbytes          = MAX_LFS_FILESIZE;
-	sb->s_blocksize         = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits    = PAGE_CACHE_SHIFT;
+	sb->s_blocksize         = PAGE_SIZE;
+	sb->s_blocksize_bits    = PAGE_SHIFT;
 	sb->s_magic             = EFIVARFS_MAGIC;
 	sb->s_op                = &efivarfs_ops;
 	sb->s_d_op		= &efivarfs_d_ops;
diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index e5bb2abf77f9..547b93cbea63 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -41,16 +41,16 @@ static inline unsigned exofs_chunk_size(struct inode *inode)
 static inline void exofs_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static unsigned exofs_last_byte(struct inode *inode, unsigned long page_nr)
 {
 	loff_t last_byte = inode->i_size;
 
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << PAGE_SHIFT;
+	if (last_byte > PAGE_SIZE)
+		last_byte = PAGE_SIZE;
 	return last_byte;
 }
 
@@ -85,13 +85,13 @@ static void exofs_check_page(struct page *page)
 	unsigned chunk_size = exofs_chunk_size(dir);
 	char *kaddr = page_address(page);
 	unsigned offs, rec_len;
-	unsigned limit = PAGE_CACHE_SIZE;
+	unsigned limit = PAGE_SIZE;
 	struct exofs_dir_entry *p;
 	char *error;
 
 	/* if the page is the last one in the directory */
-	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
-		limit = dir->i_size & ~PAGE_CACHE_MASK;
+	if ((dir->i_size >> PAGE_SHIFT) == page->index) {
+		limit = dir->i_size & ~PAGE_MASK;
 		if (limit & (chunk_size - 1))
 			goto Ebadsize;
 		if (!limit)
@@ -138,7 +138,7 @@ bad_entry:
 	EXOFS_ERR(
 		"ERROR [exofs_check_page]: bad entry in directory(0x%lx): %s - "
 		"offset=%lu, inode=0x%llu, rec_len=%d, name_len=%d\n",
-		dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		dir->i_ino, error, (page->index<<PAGE_SHIFT)+offs,
 		_LLU(le64_to_cpu(p->inode_no)),
 		rec_len, p->name_len);
 	goto fail;
@@ -147,7 +147,7 @@ Eend:
 	EXOFS_ERR("ERROR [exofs_check_page]: "
 		"entry in directory(0x%lx) spans the page boundary"
 		"offset=%lu, inode=0x%llx\n",
-		dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		dir->i_ino, (page->index<<PAGE_SHIFT)+offs,
 		_LLU(le64_to_cpu(p->inode_no)));
 fail:
 	SetPageChecked(page);
@@ -237,8 +237,8 @@ exofs_readdir(struct file *file, struct dir_context *ctx)
 {
 	loff_t pos = ctx->pos;
 	struct inode *inode = file_inode(file);
-	unsigned int offset = pos & ~PAGE_CACHE_MASK;
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
+	unsigned int offset = pos & ~PAGE_MASK;
+	unsigned long n = pos >> PAGE_SHIFT;
 	unsigned long npages = dir_pages(inode);
 	unsigned chunk_mask = ~(exofs_chunk_size(inode)-1);
 	int need_revalidate = (file->f_version != inode->i_version);
@@ -254,7 +254,7 @@ exofs_readdir(struct file *file, struct dir_context *ctx)
 		if (IS_ERR(page)) {
 			EXOFS_ERR("ERROR: bad page in directory(0x%lx)\n",
 				  inode->i_ino);
-			ctx->pos += PAGE_CACHE_SIZE - offset;
+			ctx->pos += PAGE_SIZE - offset;
 			return PTR_ERR(page);
 		}
 		kaddr = page_address(page);
@@ -262,7 +262,7 @@ exofs_readdir(struct file *file, struct dir_context *ctx)
 			if (offset) {
 				offset = exofs_validate_entry(kaddr, offset,
 								chunk_mask);
-				ctx->pos = (n<<PAGE_CACHE_SHIFT) + offset;
+				ctx->pos = (n<<PAGE_SHIFT) + offset;
 			}
 			file->f_version = inode->i_version;
 			need_revalidate = 0;
@@ -449,7 +449,7 @@ int exofs_add_link(struct dentry *dentry, struct inode *inode)
 		kaddr = page_address(page);
 		dir_end = kaddr + exofs_last_byte(dir, n);
 		de = (struct exofs_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - reclen;
+		kaddr += PAGE_SIZE - reclen;
 		while ((char *)de <= kaddr) {
 			if ((char *)de == dir_end) {
 				name_len = 0;
@@ -602,7 +602,7 @@ int exofs_make_empty(struct inode *inode, struct inode *parent)
 	kunmap_atomic(kaddr);
 	err = exofs_commit_chunk(page, 0, chunk_size);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 9eaf595aeaf8..49e1bd00b4ec 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -317,7 +317,7 @@ static int read_exec(struct page_collect *pcol)
 
 	if (!pcol->ios) {
 		int ret = ore_get_rw_state(&pcol->sbi->layout, &oi->oc, true,
-					     pcol->pg_first << PAGE_CACHE_SHIFT,
+					     pcol->pg_first << PAGE_SHIFT,
 					     pcol->length, &pcol->ios);
 
 		if (ret)
@@ -383,7 +383,7 @@ static int readpage_strip(void *data, struct page *page)
 	struct inode *inode = pcol->inode;
 	struct exofs_i_info *oi = exofs_i(inode);
 	loff_t i_size = i_size_read(inode);
-	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	pgoff_t end_index = i_size >> PAGE_SHIFT;
 	size_t len;
 	int ret;
 
@@ -397,9 +397,9 @@ static int readpage_strip(void *data, struct page *page)
 	pcol->that_locked_page = page;
 
 	if (page->index < end_index)
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 	else if (page->index == end_index)
-		len = i_size & ~PAGE_CACHE_MASK;
+		len = i_size & ~PAGE_MASK;
 	else
 		len = 0;
 
@@ -442,8 +442,8 @@ try_again:
 			goto fail;
 	}
 
-	if (len != PAGE_CACHE_SIZE)
-		zero_user(page, len, PAGE_CACHE_SIZE - len);
+	if (len != PAGE_SIZE)
+		zero_user(page, len, PAGE_SIZE - len);
 
 	EXOFS_DBGMSG2("    readpage_strip(0x%lx, 0x%lx) len=0x%zx\n",
 		     inode->i_ino, page->index, len);
@@ -609,7 +609,7 @@ static void __r4w_put_page(void *priv, struct page *page)
 
 	if ((pcol->that_locked_page != page) && (ZERO_PAGE(0) != page)) {
 		EXOFS_DBGMSG2("index=0x%lx\n", page->index);
-		page_cache_release(page);
+		put_page(page);
 		return;
 	}
 	EXOFS_DBGMSG2("that_locked_page index=0x%lx\n",
@@ -633,7 +633,7 @@ static int write_exec(struct page_collect *pcol)
 
 	BUG_ON(pcol->ios);
 	ret = ore_get_rw_state(&pcol->sbi->layout, &oi->oc, false,
-				 pcol->pg_first << PAGE_CACHE_SHIFT,
+				 pcol->pg_first << PAGE_SHIFT,
 				 pcol->length, &pcol->ios);
 	if (unlikely(ret))
 		goto err;
@@ -696,7 +696,7 @@ static int writepage_strip(struct page *page,
 	struct inode *inode = pcol->inode;
 	struct exofs_i_info *oi = exofs_i(inode);
 	loff_t i_size = i_size_read(inode);
-	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	pgoff_t end_index = i_size >> PAGE_SHIFT;
 	size_t len;
 	int ret;
 
@@ -708,9 +708,9 @@ static int writepage_strip(struct page *page,
 
 	if (page->index < end_index)
 		/* in this case, the page is within the limits of the file */
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 	else {
-		len = i_size & ~PAGE_CACHE_MASK;
+		len = i_size & ~PAGE_MASK;
 
 		if (page->index > end_index || !len) {
 			/* in this case, the page is outside the limits
@@ -790,10 +790,10 @@ static int exofs_writepages(struct address_space *mapping,
 	long start, end, expected_pages;
 	int ret;
 
-	start = wbc->range_start >> PAGE_CACHE_SHIFT;
+	start = wbc->range_start >> PAGE_SHIFT;
 	end = (wbc->range_end == LLONG_MAX) ?
 			start + mapping->nrpages :
-			wbc->range_end >> PAGE_CACHE_SHIFT;
+			wbc->range_end >> PAGE_SHIFT;
 
 	if (start || end)
 		expected_pages = end - start + 1;
@@ -881,15 +881,15 @@ int exofs_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	 /* read modify write */
-	if (!PageUptodate(page) && (len != PAGE_CACHE_SIZE)) {
+	if (!PageUptodate(page) && (len != PAGE_SIZE)) {
 		loff_t i_size = i_size_read(mapping->host);
-		pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+		pgoff_t end_index = i_size >> PAGE_SHIFT;
 		size_t rlen;
 
 		if (page->index < end_index)
-			rlen = PAGE_CACHE_SIZE;
+			rlen = PAGE_SIZE;
 		else if (page->index == end_index)
-			rlen = i_size & ~PAGE_CACHE_MASK;
+			rlen = i_size & ~PAGE_MASK;
 		else
 			rlen = 0;
 
diff --git a/fs/exofs/namei.c b/fs/exofs/namei.c
index c20d77df2679..622a686bb08b 100644
--- a/fs/exofs/namei.c
+++ b/fs/exofs/namei.c
@@ -292,11 +292,11 @@ static int exofs_rename(struct inode *old_dir, struct dentry *old_dentry,
 out_dir:
 	if (dir_de) {
 		kunmap(dir_page);
-		page_cache_release(dir_page);
+		put_page(dir_page);
 	}
 out_old:
 	kunmap(old_page);
-	page_cache_release(old_page);
+	put_page(old_page);
 out:
 	return err;
 }
diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
index 0c6638b40f21..1b45694de316 100644
--- a/fs/ext2/dir.c
+++ b/fs/ext2/dir.c
@@ -67,7 +67,7 @@ static inline unsigned ext2_chunk_size(struct inode *inode)
 static inline void ext2_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -79,9 +79,9 @@ ext2_last_byte(struct inode *inode, unsigned long page_nr)
 {
 	unsigned last_byte = inode->i_size;
 
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << PAGE_SHIFT;
+	if (last_byte > PAGE_SIZE)
+		last_byte = PAGE_SIZE;
 	return last_byte;
 }
 
@@ -118,12 +118,12 @@ static void ext2_check_page(struct page *page, int quiet)
 	char *kaddr = page_address(page);
 	u32 max_inumber = le32_to_cpu(EXT2_SB(sb)->s_es->s_inodes_count);
 	unsigned offs, rec_len;
-	unsigned limit = PAGE_CACHE_SIZE;
+	unsigned limit = PAGE_SIZE;
 	ext2_dirent *p;
 	char *error;
 
-	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
-		limit = dir->i_size & ~PAGE_CACHE_MASK;
+	if ((dir->i_size >> PAGE_SHIFT) == page->index) {
+		limit = dir->i_size & ~PAGE_MASK;
 		if (limit & (chunk_size - 1))
 			goto Ebadsize;
 		if (!limit)
@@ -176,7 +176,7 @@ bad_entry:
 	if (!quiet)
 		ext2_error(sb, __func__, "bad entry in directory #%lu: : %s - "
 			"offset=%lu, inode=%lu, rec_len=%d, name_len=%d",
-			dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
+			dir->i_ino, error, (page->index<<PAGE_SHIFT)+offs,
 			(unsigned long) le32_to_cpu(p->inode),
 			rec_len, p->name_len);
 	goto fail;
@@ -186,7 +186,7 @@ Eend:
 		ext2_error(sb, "ext2_check_page",
 			"entry in directory #%lu spans the page boundary"
 			"offset=%lu, inode=%lu",
-			dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs,
+			dir->i_ino, (page->index<<PAGE_SHIFT)+offs,
 			(unsigned long) le32_to_cpu(p->inode));
 	}
 fail:
@@ -287,8 +287,8 @@ ext2_readdir(struct file *file, struct dir_context *ctx)
 	loff_t pos = ctx->pos;
 	struct inode *inode = file_inode(file);
 	struct super_block *sb = inode->i_sb;
-	unsigned int offset = pos & ~PAGE_CACHE_MASK;
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
+	unsigned int offset = pos & ~PAGE_MASK;
+	unsigned long n = pos >> PAGE_SHIFT;
 	unsigned long npages = dir_pages(inode);
 	unsigned chunk_mask = ~(ext2_chunk_size(inode)-1);
 	unsigned char *types = NULL;
@@ -309,14 +309,14 @@ ext2_readdir(struct file *file, struct dir_context *ctx)
 			ext2_error(sb, __func__,
 				   "bad page in #%lu",
 				   inode->i_ino);
-			ctx->pos += PAGE_CACHE_SIZE - offset;
+			ctx->pos += PAGE_SIZE - offset;
 			return PTR_ERR(page);
 		}
 		kaddr = page_address(page);
 		if (unlikely(need_revalidate)) {
 			if (offset) {
 				offset = ext2_validate_entry(kaddr, offset, chunk_mask);
-				ctx->pos = (n<<PAGE_CACHE_SHIFT) + offset;
+				ctx->pos = (n<<PAGE_SHIFT) + offset;
 			}
 			file->f_version = inode->i_version;
 			need_revalidate = 0;
@@ -406,7 +406,7 @@ struct ext2_dir_entry_2 *ext2_find_entry (struct inode * dir,
 		if (++n >= npages)
 			n = 0;
 		/* next page is past the blocks we've got */
-		if (unlikely(n > (dir->i_blocks >> (PAGE_CACHE_SHIFT - 9)))) {
+		if (unlikely(n > (dir->i_blocks >> (PAGE_SHIFT - 9)))) {
 			ext2_error(dir->i_sb, __func__,
 				"dir %lu size %lld exceeds block count %llu",
 				dir->i_ino, dir->i_size,
@@ -511,7 +511,7 @@ int ext2_add_link (struct dentry *dentry, struct inode *inode)
 		kaddr = page_address(page);
 		dir_end = kaddr + ext2_last_byte(dir, n);
 		de = (ext2_dirent *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - reclen;
+		kaddr += PAGE_SIZE - reclen;
 		while ((char *)de <= kaddr) {
 			if ((char *)de == dir_end) {
 				/* We hit i_size */
@@ -655,7 +655,7 @@ int ext2_make_empty(struct inode *inode, struct inode *parent)
 	kunmap_atomic(kaddr);
 	err = ext2_commit_chunk(page, 0, chunk_size);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/ext2/namei.c b/fs/ext2/namei.c
index 7a2be8f7f3c3..d34843925b23 100644
--- a/fs/ext2/namei.c
+++ b/fs/ext2/namei.c
@@ -398,7 +398,7 @@ static int ext2_rename (struct inode * old_dir, struct dentry * old_dentry,
 			ext2_set_link(old_inode, dir_de, dir_page, new_dir, 0);
 		else {
 			kunmap(dir_page);
-			page_cache_release(dir_page);
+			put_page(dir_page);
 		}
 		inode_dec_link_count(old_dir);
 	}
@@ -408,11 +408,11 @@ static int ext2_rename (struct inode * old_dir, struct dentry * old_dentry,
 out_dir:
 	if (dir_de) {
 		kunmap(dir_page);
-		page_cache_release(dir_page);
+		put_page(dir_page);
 	}
 out_old:
 	kunmap(old_page);
-	page_cache_release(old_page);
+	put_page(old_page);
 out:
 	return err;
 }
diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
index edc053a81914..2580ef3346ca 100644
--- a/fs/ext4/crypto.c
+++ b/fs/ext4/crypto.c
@@ -283,10 +283,10 @@ static int ext4_page_crypto(struct inode *inode,
 	       EXT4_XTS_TWEAK_SIZE - sizeof(index));
 
 	sg_init_table(&dst, 1);
-	sg_set_page(&dst, dest_page, PAGE_CACHE_SIZE, 0);
+	sg_set_page(&dst, dest_page, PAGE_SIZE, 0);
 	sg_init_table(&src, 1);
-	sg_set_page(&src, src_page, PAGE_CACHE_SIZE, 0);
-	skcipher_request_set_crypt(req, &src, &dst, PAGE_CACHE_SIZE,
+	sg_set_page(&src, src_page, PAGE_SIZE, 0);
+	skcipher_request_set_crypt(req, &src, &dst, PAGE_SIZE,
 				   xts_tweak);
 	if (rw == EXT4_DECRYPT)
 		res = crypto_skcipher_decrypt(req);
@@ -396,7 +396,7 @@ int ext4_encrypted_zeroout(struct inode *inode, ext4_lblk_t lblk,
 		 (unsigned long) inode->i_ino, lblk, len);
 #endif
 
-	BUG_ON(inode->i_sb->s_blocksize != PAGE_CACHE_SIZE);
+	BUG_ON(inode->i_sb->s_blocksize != PAGE_SIZE);
 
 	ctx = ext4_get_crypto_ctx(inode);
 	if (IS_ERR(ctx))
diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index 33f5e2a50cf8..a887efeb7027 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -155,13 +155,13 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 		err = ext4_map_blocks(NULL, inode, &map, 0);
 		if (err > 0) {
 			pgoff_t index = map.m_pblk >>
-					(PAGE_CACHE_SHIFT - inode->i_blkbits);
+					(PAGE_SHIFT - inode->i_blkbits);
 			if (!ra_has_index(&file->f_ra, index))
 				page_cache_sync_readahead(
 					sb->s_bdev->bd_inode->i_mapping,
 					&file->f_ra, file,
 					index, 1);
-			file->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
+			file->f_ra.prev_pos = (loff_t)index << PAGE_SHIFT;
 			bh = ext4_bread(NULL, inode, map.m_lblk, 0);
 			if (IS_ERR(bh)) {
 				err = PTR_ERR(bh);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 6659e216385e..0caece398eb8 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -428,8 +428,8 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 	lastoff = startoff;
 	endoff = (loff_t)end_blk << blkbits;
 
-	index = startoff >> PAGE_CACHE_SHIFT;
-	end = endoff >> PAGE_CACHE_SHIFT;
+	index = startoff >> PAGE_SHIFT;
+	end = endoff >> PAGE_SHIFT;
 
 	pagevec_init(&pvec, 0);
 	do {
diff --git a/fs/ext4/inline.c b/fs/ext4/inline.c
index 7cbdd3752ba5..7bc6c855cc18 100644
--- a/fs/ext4/inline.c
+++ b/fs/ext4/inline.c
@@ -482,7 +482,7 @@ static int ext4_read_inline_page(struct inode *inode, struct page *page)
 	ret = ext4_read_inline_data(inode, kaddr, len, &iloc);
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
-	zero_user_segment(page, len, PAGE_CACHE_SIZE);
+	zero_user_segment(page, len, PAGE_SIZE);
 	SetPageUptodate(page);
 	brelse(iloc.bh);
 
@@ -507,7 +507,7 @@ int ext4_readpage_inline(struct inode *inode, struct page *page)
 	if (!page->index)
 		ret = ext4_read_inline_page(inode, page);
 	else if (!PageUptodate(page)) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 	}
 
@@ -595,7 +595,7 @@ retry:
 
 	if (ret) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 		ext4_orphan_add(handle, inode);
 		up_write(&EXT4_I(inode)->xattr_sem);
@@ -621,7 +621,7 @@ retry:
 out:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (sem_held)
 		up_write(&EXT4_I(inode)->xattr_sem);
@@ -690,7 +690,7 @@ int ext4_try_to_write_inline_data(struct address_space *mapping,
 	if (!ext4_has_inline_data(inode)) {
 		ret = 0;
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		goto out_up_read;
 	}
 
@@ -815,7 +815,7 @@ static int ext4_da_convert_inline_data_to_extent(struct address_space *mapping,
 	if (ret) {
 		up_read(&EXT4_I(inode)->xattr_sem);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		ext4_truncate_failed_write(inode);
 		return ret;
 	}
@@ -829,7 +829,7 @@ out:
 	up_read(&EXT4_I(inode)->xattr_sem);
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return ret;
 }
@@ -919,7 +919,7 @@ retry_journal:
 out_release_page:
 	up_read(&EXT4_I(inode)->xattr_sem);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out_journal:
 	ext4_journal_stop(handle);
 out:
@@ -947,7 +947,7 @@ int ext4_da_write_inline_data_end(struct inode *inode, loff_t pos,
 		i_size_changed = 1;
 	}
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	/*
 	 * Don't mark the inode dirty under page lock. First, it unnecessarily
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b2e9576450eb..9cfce0489339 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1057,7 +1057,7 @@ int do_journal_get_write_access(handle_t *handle,
 static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 				  get_block_t *get_block)
 {
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + len;
 	struct inode *inode = page->mapping->host;
 	unsigned block_start, block_end;
@@ -1069,15 +1069,15 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 	bool decrypt = false;
 
 	BUG_ON(!PageLocked(page));
-	BUG_ON(from > PAGE_CACHE_SIZE);
-	BUG_ON(to > PAGE_CACHE_SIZE);
+	BUG_ON(from > PAGE_SIZE);
+	BUG_ON(to > PAGE_SIZE);
 	BUG_ON(from > to);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
 	head = page_buffers(page);
 	bbits = ilog2(blocksize);
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - bbits);
+	block = (sector_t)page->index << (PAGE_SHIFT - bbits);
 
 	for (bh = head, block_start = 0; bh != head || !block_start;
 	    block++, block_start = block_end, bh = bh->b_this_page) {
@@ -1159,8 +1159,8 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 	 * we allocate blocks but write fails for some reason
 	 */
 	needed_blocks = ext4_writepage_trans_blocks(inode) + 1;
-	index = pos >> PAGE_CACHE_SHIFT;
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	index = pos >> PAGE_SHIFT;
+	from = pos & (PAGE_SIZE - 1);
 	to = from + len;
 
 	if (ext4_test_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA)) {
@@ -1188,7 +1188,7 @@ retry_grab:
 retry_journal:
 	handle = ext4_journal_start(inode, EXT4_HT_WRITE_PAGE, needed_blocks);
 	if (IS_ERR(handle)) {
-		page_cache_release(page);
+		put_page(page);
 		return PTR_ERR(handle);
 	}
 
@@ -1196,7 +1196,7 @@ retry_journal:
 	if (page->mapping != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		ext4_journal_stop(handle);
 		goto retry_grab;
 	}
@@ -1252,7 +1252,7 @@ retry_journal:
 		if (ret == -ENOSPC &&
 		    ext4_should_retry_alloc(inode->i_sb, &retries))
 			goto retry_journal;
-		page_cache_release(page);
+		put_page(page);
 		return ret;
 	}
 	*pagep = page;
@@ -1295,7 +1295,7 @@ static int ext4_write_end(struct file *file,
 		ret = ext4_jbd2_file_inode(handle, inode);
 		if (ret) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto errout;
 		}
 	}
@@ -1315,7 +1315,7 @@ static int ext4_write_end(struct file *file,
 	 */
 	i_size_changed = ext4_update_inode_size(inode, pos + copied);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (old_size < pos)
 		pagecache_isize_extended(inode, old_size, pos);
@@ -1399,7 +1399,7 @@ static int ext4_journalled_write_end(struct file *file,
 	int size_changed = 0;
 
 	trace_ext4_journalled_write_end(inode, pos, len, copied);
-	from = pos & (PAGE_CACHE_SIZE - 1);
+	from = pos & (PAGE_SIZE - 1);
 	to = from + len;
 
 	BUG_ON(!ext4_handle_valid(handle));
@@ -1423,7 +1423,7 @@ static int ext4_journalled_write_end(struct file *file,
 	ext4_set_inode_state(inode, EXT4_STATE_JDATA);
 	EXT4_I(inode)->i_datasync_tid = handle->h_transaction->t_tid;
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (old_size < pos)
 		pagecache_isize_extended(inode, old_size, pos);
@@ -1537,7 +1537,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	int num_clusters;
 	ext4_fsblk_t lblk;
 
-	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+	BUG_ON(stop > PAGE_SIZE || stop < length);
 
 	head = page_buffers(page);
 	bh = head;
@@ -1553,7 +1553,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 			clear_buffer_delay(bh);
 		} else if (contiguous_blks) {
 			lblk = page->index <<
-			       (PAGE_CACHE_SHIFT - inode->i_blkbits);
+			       (PAGE_SHIFT - inode->i_blkbits);
 			lblk += (curr_off >> inode->i_blkbits) -
 				contiguous_blks;
 			ext4_es_remove_extent(inode, lblk, contiguous_blks);
@@ -1563,7 +1563,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	} while ((bh = bh->b_this_page) != head);
 
 	if (contiguous_blks) {
-		lblk = page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		lblk = page->index << (PAGE_SHIFT - inode->i_blkbits);
 		lblk += (curr_off >> inode->i_blkbits) - contiguous_blks;
 		ext4_es_remove_extent(inode, lblk, contiguous_blks);
 	}
@@ -1572,7 +1572,7 @@ static void ext4_da_page_release_reservation(struct page *page,
 	 * need to release the reserved space for that cluster. */
 	num_clusters = EXT4_NUM_B2C(sbi, to_release);
 	while (num_clusters > 0) {
-		lblk = (page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits)) +
+		lblk = (page->index << (PAGE_SHIFT - inode->i_blkbits)) +
 			((num_clusters - 1) << sbi->s_cluster_bits);
 		if (sbi->s_cluster_ratio == 1 ||
 		    !ext4_find_delalloc_cluster(inode, lblk))
@@ -1619,8 +1619,8 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 	end   = mpd->next_page - 1;
 	if (invalidate) {
 		ext4_lblk_t start, last;
-		start = index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
-		last = end << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		start = index << (PAGE_SHIFT - inode->i_blkbits);
+		last = end << (PAGE_SHIFT - inode->i_blkbits);
 		ext4_es_remove_extent(inode, start, last - start + 1);
 	}
 
@@ -1636,7 +1636,7 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 			BUG_ON(!PageLocked(page));
 			BUG_ON(PageWriteback(page));
 			if (invalidate) {
-				block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+				block_invalidatepage(page, 0, PAGE_SIZE);
 				ClearPageUptodate(page);
 			}
 			unlock_page(page);
@@ -2007,10 +2007,10 @@ static int ext4_writepage(struct page *page,
 
 	trace_ext4_writepage(page);
 	size = i_size_read(inode);
-	if (page->index == size >> PAGE_CACHE_SHIFT)
-		len = size & ~PAGE_CACHE_MASK;
+	if (page->index == size >> PAGE_SHIFT)
+		len = size & ~PAGE_MASK;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 
 	page_bufs = page_buffers(page);
 	/*
@@ -2034,7 +2034,7 @@ static int ext4_writepage(struct page *page,
 				   ext4_bh_delay_or_unwritten)) {
 		redirty_page_for_writepage(wbc, page);
 		if ((current->flags & PF_MEMALLOC) ||
-		    (inode->i_sb->s_blocksize == PAGE_CACHE_SIZE)) {
+		    (inode->i_sb->s_blocksize == PAGE_SIZE)) {
 			/*
 			 * For memory cleaning there's no point in writing only
 			 * some buffers. So just bail out. Warn if we came here
@@ -2076,10 +2076,10 @@ static int mpage_submit_page(struct mpage_da_data *mpd, struct page *page)
 	int err;
 
 	BUG_ON(page->index != mpd->first_page);
-	if (page->index == size >> PAGE_CACHE_SHIFT)
-		len = size & ~PAGE_CACHE_MASK;
+	if (page->index == size >> PAGE_SHIFT)
+		len = size & ~PAGE_MASK;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 	clear_page_dirty_for_io(page);
 	err = ext4_bio_write_page(&mpd->io_submit, page, len, mpd->wbc, false);
 	if (!err)
@@ -2213,7 +2213,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 	int nr_pages, i;
 	struct inode *inode = mpd->inode;
 	struct buffer_head *head, *bh;
-	int bpp_bits = PAGE_CACHE_SHIFT - inode->i_blkbits;
+	int bpp_bits = PAGE_SHIFT - inode->i_blkbits;
 	pgoff_t start, end;
 	ext4_lblk_t lblk;
 	sector_t pblock;
@@ -2274,7 +2274,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 			 * supports blocksize < pagesize as we will try to
 			 * convert potentially unmapped parts of inode.
 			 */
-			mpd->io_submit.io_end->size += PAGE_CACHE_SIZE;
+			mpd->io_submit.io_end->size += PAGE_SIZE;
 			/* Page fully mapped - let IO run! */
 			err = mpage_submit_page(mpd, page);
 			if (err < 0) {
@@ -2426,7 +2426,7 @@ update_disksize:
 	 * Update on-disk size after IO is submitted.  Races with
 	 * truncate are avoided by checking i_size under i_data_sem.
 	 */
-	disksize = ((loff_t)mpd->first_page) << PAGE_CACHE_SHIFT;
+	disksize = ((loff_t)mpd->first_page) << PAGE_SHIFT;
 	if (disksize > EXT4_I(inode)->i_disksize) {
 		int err2;
 		loff_t i_size;
@@ -2562,7 +2562,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 			mpd->next_page = page->index + 1;
 			/* Add all dirty buffers to mpd */
 			lblk = ((ext4_lblk_t)page->index) <<
-				(PAGE_CACHE_SHIFT - blkbits);
+				(PAGE_SHIFT - blkbits);
 			head = page_buffers(page);
 			err = mpage_process_page_bufs(mpd, head, head, lblk);
 			if (err <= 0)
@@ -2647,7 +2647,7 @@ static int ext4_writepages(struct address_space *mapping,
 		 * We may need to convert up to one extent per block in
 		 * the page and we may dirty the inode.
 		 */
-		rsv_blocks = 1 + (PAGE_CACHE_SIZE >> inode->i_blkbits);
+		rsv_blocks = 1 + (PAGE_SIZE >> inode->i_blkbits);
 	}
 
 	/*
@@ -2678,8 +2678,8 @@ static int ext4_writepages(struct address_space *mapping,
 		mpd.first_page = writeback_index;
 		mpd.last_page = -1;
 	} else {
-		mpd.first_page = wbc->range_start >> PAGE_CACHE_SHIFT;
-		mpd.last_page = wbc->range_end >> PAGE_CACHE_SHIFT;
+		mpd.first_page = wbc->range_start >> PAGE_SHIFT;
+		mpd.last_page = wbc->range_end >> PAGE_SHIFT;
 	}
 
 	mpd.inode = inode;
@@ -2838,7 +2838,7 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	handle_t *handle;
 
-	index = pos >> PAGE_CACHE_SHIFT;
+	index = pos >> PAGE_SHIFT;
 
 	if (ext4_nonda_switch(inode->i_sb)) {
 		*fsdata = (void *)FALL_BACK_TO_NONDELALLOC;
@@ -2881,7 +2881,7 @@ retry_journal:
 	handle = ext4_journal_start(inode, EXT4_HT_WRITE_PAGE,
 				ext4_da_write_credits(inode, pos, len));
 	if (IS_ERR(handle)) {
-		page_cache_release(page);
+		put_page(page);
 		return PTR_ERR(handle);
 	}
 
@@ -2889,7 +2889,7 @@ retry_journal:
 	if (page->mapping != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		ext4_journal_stop(handle);
 		goto retry_grab;
 	}
@@ -2917,7 +2917,7 @@ retry_journal:
 		    ext4_should_retry_alloc(inode->i_sb, &retries))
 			goto retry_journal;
 
-		page_cache_release(page);
+		put_page(page);
 		return ret;
 	}
 
@@ -2965,7 +2965,7 @@ static int ext4_da_write_end(struct file *file,
 				      len, copied, page, fsdata);
 
 	trace_ext4_da_write_end(inode, pos, len, copied);
-	start = pos & (PAGE_CACHE_SIZE - 1);
+	start = pos & (PAGE_SIZE - 1);
 	end = start + copied - 1;
 
 	/*
@@ -3187,7 +3187,7 @@ static int __ext4_journalled_invalidatepage(struct page *page,
 	/*
 	 * If it's a full truncate we just forget about the pending dirtying
 	 */
-	if (offset == 0 && length == PAGE_CACHE_SIZE)
+	if (offset == 0 && length == PAGE_SIZE)
 		ClearPageChecked(page);
 
 	return jbd2_journal_invalidatepage(journal, page, offset, length);
@@ -3546,8 +3546,8 @@ void ext4_set_aops(struct inode *inode)
 static int __ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
-	ext4_fsblk_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	ext4_fsblk_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize, pos;
 	ext4_lblk_t iblock;
 	struct inode *inode = mapping->host;
@@ -3555,14 +3555,14 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 	struct page *page;
 	int err = 0;
 
-	page = find_or_create_page(mapping, from >> PAGE_CACHE_SHIFT,
+	page = find_or_create_page(mapping, from >> PAGE_SHIFT,
 				   mapping_gfp_constraint(mapping, ~__GFP_FS));
 	if (!page)
 		return -ENOMEM;
 
 	blocksize = inode->i_sb->s_blocksize;
 
-	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
@@ -3604,7 +3604,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		    ext4_encrypted_inode(inode)) {
 			/* We expect the key to be set. */
 			BUG_ON(!ext4_has_encryption_key(inode));
-			BUG_ON(blocksize != PAGE_CACHE_SIZE);
+			BUG_ON(blocksize != PAGE_SIZE);
 			WARN_ON_ONCE(ext4_decrypt(page));
 		}
 	}
@@ -3628,7 +3628,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
@@ -3643,7 +3643,7 @@ static int ext4_block_zero_page_range(handle_t *handle,
 		struct address_space *mapping, loff_t from, loff_t length)
 {
 	struct inode *inode = mapping->host;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize = inode->i_sb->s_blocksize;
 	unsigned max = blocksize - (offset & (blocksize - 1));
 
@@ -3668,7 +3668,7 @@ static int ext4_block_zero_page_range(handle_t *handle,
 static int ext4_block_truncate_page(handle_t *handle,
 		struct address_space *mapping, loff_t from)
 {
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned length;
 	unsigned blocksize;
 	struct inode *inode = mapping->host;
@@ -3806,7 +3806,7 @@ int ext4_punch_hole(struct inode *inode, loff_t offset, loff_t length)
 	 */
 	if (offset + length > inode->i_size) {
 		length = inode->i_size +
-		   PAGE_CACHE_SIZE - (inode->i_size & (PAGE_CACHE_SIZE - 1)) -
+		   PAGE_SIZE - (inode->i_size & (PAGE_SIZE - 1)) -
 		   offset;
 	}
 
@@ -4881,23 +4881,23 @@ static void ext4_wait_for_tail_page_commit(struct inode *inode)
 	tid_t commit_tid = 0;
 	int ret;
 
-	offset = inode->i_size & (PAGE_CACHE_SIZE - 1);
+	offset = inode->i_size & (PAGE_SIZE - 1);
 	/*
 	 * All buffers in the last page remain valid? Then there's nothing to
 	 * do. We do the check mainly to optimize the common PAGE_CACHE_SIZE ==
 	 * blocksize case
 	 */
-	if (offset > PAGE_CACHE_SIZE - (1 << inode->i_blkbits))
+	if (offset > PAGE_SIZE - (1 << inode->i_blkbits))
 		return;
 	while (1) {
 		page = find_lock_page(inode->i_mapping,
-				      inode->i_size >> PAGE_CACHE_SHIFT);
+				      inode->i_size >> PAGE_SHIFT);
 		if (!page)
 			return;
 		ret = __ext4_journalled_invalidatepage(page, offset,
-						PAGE_CACHE_SIZE - offset);
+						PAGE_SIZE - offset);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (ret != -EBUSY)
 			return;
 		commit_tid = 0;
@@ -5536,10 +5536,10 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		goto out;
 	}
 
-	if (page->index == size >> PAGE_CACHE_SHIFT)
-		len = size & ~PAGE_CACHE_MASK;
+	if (page->index == size >> PAGE_SHIFT)
+		len = size & ~PAGE_MASK;
 	else
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 	/*
 	 * Return if we have all the buffers mapped. This avoids the need to do
 	 * journal_start/journal_stop which can block and take a long time
@@ -5570,7 +5570,7 @@ retry_alloc:
 	ret = block_page_mkwrite(vma, vmf, get_block);
 	if (!ret && ext4_should_journal_data(inode)) {
 		if (ext4_walk_page_buffers(handle, page_buffers(page), 0,
-			  PAGE_CACHE_SIZE, NULL, do_journal_get_write_access)) {
+			  PAGE_SIZE, NULL, do_journal_get_write_access)) {
 			unlock_page(page);
 			ret = VM_FAULT_SIGBUS;
 			ext4_journal_stop(handle);
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 50e05df28f66..c12174711ce2 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -839,7 +839,7 @@ static int ext4_mb_init_cache(struct page *page, char *incore, gfp_t gfp)
 	sb = inode->i_sb;
 	ngroups = ext4_get_groups_count(sb);
 	blocksize = 1 << inode->i_blkbits;
-	blocks_per_page = PAGE_CACHE_SIZE / blocksize;
+	blocks_per_page = PAGE_SIZE / blocksize;
 
 	groups_per_page = blocks_per_page >> 1;
 	if (groups_per_page == 0)
@@ -993,7 +993,7 @@ static int ext4_mb_get_buddy_page_lock(struct super_block *sb,
 	e4b->bd_buddy_page = NULL;
 	e4b->bd_bitmap_page = NULL;
 
-	blocks_per_page = PAGE_CACHE_SIZE / sb->s_blocksize;
+	blocks_per_page = PAGE_SIZE / sb->s_blocksize;
 	/*
 	 * the buddy cache inode stores the block bitmap
 	 * and buddy information in consecutive blocks.
@@ -1028,11 +1028,11 @@ static void ext4_mb_put_buddy_page_lock(struct ext4_buddy *e4b)
 {
 	if (e4b->bd_bitmap_page) {
 		unlock_page(e4b->bd_bitmap_page);
-		page_cache_release(e4b->bd_bitmap_page);
+		put_page(e4b->bd_bitmap_page);
 	}
 	if (e4b->bd_buddy_page) {
 		unlock_page(e4b->bd_buddy_page);
-		page_cache_release(e4b->bd_buddy_page);
+		put_page(e4b->bd_buddy_page);
 	}
 }
 
@@ -1125,7 +1125,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 	might_sleep();
 	mb_debug(1, "load group %u\n", group);
 
-	blocks_per_page = PAGE_CACHE_SIZE / sb->s_blocksize;
+	blocks_per_page = PAGE_SIZE / sb->s_blocksize;
 	grp = ext4_get_group_info(sb, group);
 
 	e4b->bd_blkbits = sb->s_blocksize_bits;
@@ -1167,7 +1167,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 			 * is yet to initialize the same. So
 			 * wait for it to initialize.
 			 */
-			page_cache_release(page);
+			put_page(page);
 		page = find_or_create_page(inode->i_mapping, pnum, gfp);
 		if (page) {
 			BUG_ON(page->mapping != inode->i_mapping);
@@ -1203,7 +1203,7 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 	page = find_get_page_flags(inode->i_mapping, pnum, FGP_ACCESSED);
 	if (page == NULL || !PageUptodate(page)) {
 		if (page)
-			page_cache_release(page);
+			put_page(page);
 		page = find_or_create_page(inode->i_mapping, pnum, gfp);
 		if (page) {
 			BUG_ON(page->mapping != inode->i_mapping);
@@ -1238,11 +1238,11 @@ ext4_mb_load_buddy_gfp(struct super_block *sb, ext4_group_t group,
 
 err:
 	if (page)
-		page_cache_release(page);
+		put_page(page);
 	if (e4b->bd_bitmap_page)
-		page_cache_release(e4b->bd_bitmap_page);
+		put_page(e4b->bd_bitmap_page);
 	if (e4b->bd_buddy_page)
-		page_cache_release(e4b->bd_buddy_page);
+		put_page(e4b->bd_buddy_page);
 	e4b->bd_buddy = NULL;
 	e4b->bd_bitmap = NULL;
 	return ret;
@@ -1257,9 +1257,9 @@ static int ext4_mb_load_buddy(struct super_block *sb, ext4_group_t group,
 static void ext4_mb_unload_buddy(struct ext4_buddy *e4b)
 {
 	if (e4b->bd_bitmap_page)
-		page_cache_release(e4b->bd_bitmap_page);
+		put_page(e4b->bd_bitmap_page);
 	if (e4b->bd_buddy_page)
-		page_cache_release(e4b->bd_buddy_page);
+		put_page(e4b->bd_buddy_page);
 }
 
 
@@ -2833,8 +2833,8 @@ static void ext4_free_data_callback(struct super_block *sb,
 		/* No more items in the per group rb tree
 		 * balance refcounts from ext4_mb_free_metadata()
 		 */
-		page_cache_release(e4b.bd_buddy_page);
-		page_cache_release(e4b.bd_bitmap_page);
+		put_page(e4b.bd_buddy_page);
+		put_page(e4b.bd_bitmap_page);
 	}
 	ext4_unlock_group(sb, entry->efd_group);
 	kmem_cache_free(ext4_free_data_cachep, entry);
@@ -4385,9 +4385,9 @@ static int ext4_mb_release_context(struct ext4_allocation_context *ac)
 		ext4_mb_put_pa(ac, ac->ac_sb, pa);
 	}
 	if (ac->ac_bitmap_page)
-		page_cache_release(ac->ac_bitmap_page);
+		put_page(ac->ac_bitmap_page);
 	if (ac->ac_buddy_page)
-		page_cache_release(ac->ac_buddy_page);
+		put_page(ac->ac_buddy_page);
 	if (ac->ac_flags & EXT4_MB_HINT_GROUP_ALLOC)
 		mutex_unlock(&ac->ac_lg->lg_mutex);
 	ext4_mb_collect_stats(ac);
@@ -4599,8 +4599,8 @@ ext4_mb_free_metadata(handle_t *handle, struct ext4_buddy *e4b,
 		 * otherwise we'll refresh it from
 		 * on-disk bitmap and lose not-yet-available
 		 * blocks */
-		page_cache_get(e4b->bd_buddy_page);
-		page_cache_get(e4b->bd_bitmap_page);
+		get_page(e4b->bd_buddy_page);
+		get_page(e4b->bd_bitmap_page);
 	}
 	while (*n) {
 		parent = *n;
diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index 4098acc701c3..675b67e5d5c2 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -156,7 +156,7 @@ mext_page_double_lock(struct inode *inode1, struct inode *inode2,
 	page[1] = grab_cache_page_write_begin(mapping[1], index2, fl);
 	if (!page[1]) {
 		unlock_page(page[0]);
-		page_cache_release(page[0]);
+		put_page(page[0]);
 		return -ENOMEM;
 	}
 	/*
@@ -192,7 +192,7 @@ mext_page_mkuptodate(struct page *page, unsigned from, unsigned to)
 		create_empty_buffers(page, blocksize, 0);
 
 	head = page_buffers(page);
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	block = (sector_t)page->index << (PAGE_SHIFT - inode->i_blkbits);
 	for (bh = head, block_start = 0; bh != head || !block_start;
 	     block++, block_start = block_end, bh = bh->b_this_page) {
 		block_end = block_start + blocksize;
@@ -268,7 +268,7 @@ move_extent_per_page(struct file *o_filp, struct inode *donor_inode,
 	int i, err2, jblocks, retries = 0;
 	int replaced_count = 0;
 	int from = data_offset_in_page << orig_inode->i_blkbits;
-	int blocks_per_page = PAGE_CACHE_SIZE >> orig_inode->i_blkbits;
+	int blocks_per_page = PAGE_SIZE >> orig_inode->i_blkbits;
 	struct super_block *sb = orig_inode->i_sb;
 	struct buffer_head *bh = NULL;
 
@@ -404,9 +404,9 @@ data_copy:
 
 unlock_pages:
 	unlock_page(pagep[0]);
-	page_cache_release(pagep[0]);
+	put_page(pagep[0]);
 	unlock_page(pagep[1]);
-	page_cache_release(pagep[1]);
+	put_page(pagep[1]);
 stop_journal:
 	ext4_journal_stop(handle);
 	if (*err == -ENOSPC &&
@@ -554,7 +554,7 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp, __u64 orig_blk,
 	struct inode *orig_inode = file_inode(o_filp);
 	struct inode *donor_inode = file_inode(d_filp);
 	struct ext4_ext_path *path = NULL;
-	int blocks_per_page = PAGE_CACHE_SIZE >> orig_inode->i_blkbits;
+	int blocks_per_page = PAGE_SIZE >> orig_inode->i_blkbits;
 	ext4_lblk_t o_end, o_start = orig_blk;
 	ext4_lblk_t d_start = donor_blk;
 	int ret;
@@ -648,9 +648,9 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp, __u64 orig_blk,
 		if (o_end - o_start < cur_len)
 			cur_len = o_end - o_start;
 
-		orig_page_index = o_start >> (PAGE_CACHE_SHIFT -
+		orig_page_index = o_start >> (PAGE_SHIFT -
 					       orig_inode->i_blkbits);
-		donor_page_index = d_start >> (PAGE_CACHE_SHIFT -
+		donor_page_index = d_start >> (PAGE_SHIFT -
 					       donor_inode->i_blkbits);
 		offset_in_page = o_start % blocks_per_page;
 		if (cur_len > blocks_per_page- offset_in_page)
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 349d7aa04fe7..741599a011c1 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -442,8 +442,8 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	 * the page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	if (len < PAGE_CACHE_SIZE)
-		zero_user_segment(page, len, PAGE_CACHE_SIZE);
+	if (len < PAGE_SIZE)
+		zero_user_segment(page, len, PAGE_SIZE);
 	/*
 	 * In the first loop we prepare and mark buffers to submit. We have to
 	 * mark all buffers in the page before submitting so that
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 5dc5e95063de..ea27aa1a778c 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -140,7 +140,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 
 	struct inode *inode = mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	sector_t block_in_file;
 	sector_t last_block;
@@ -173,7 +173,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 		if (page_has_buffers(page))
 			goto confused;
 
-		block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+		block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 		last_block = block_in_file + nr_pages * blocks_per_page;
 		last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
 		if (last_block > last_block_in_file)
@@ -217,7 +217,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 				set_error_page:
 					SetPageError(page);
 					zero_user_segment(page, 0,
-							  PAGE_CACHE_SIZE);
+							  PAGE_SIZE);
 					unlock_page(page);
 					goto next_page;
 				}
@@ -250,7 +250,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 		}
 		if (first_hole != blocks_per_page) {
 			zero_user_segment(page, first_hole << blkbits,
-					  PAGE_CACHE_SIZE);
+					  PAGE_SIZE);
 			if (first_hole == 0) {
 				SetPageUptodate(page);
 				unlock_page(page);
@@ -319,7 +319,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			unlock_page(page);
 	next_page:
 		if (pages)
-			page_cache_release(page);
+			put_page(page);
 	}
 	BUG_ON(pages && !list_empty(pages));
 	if (bio)
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 99996e9a8f57..75b229414ee8 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1782,7 +1782,7 @@ static int parse_options(char *options, struct super_block *sb,
 		int blocksize =
 			BLOCK_SIZE << le32_to_cpu(sbi->s_es->s_log_block_size);
 
-		if (blocksize < PAGE_CACHE_SIZE) {
+		if (blocksize < PAGE_SIZE) {
 			ext4_msg(sb, KERN_ERR, "can't mount with "
 				 "dioread_nolock if block size != PAGE_SIZE");
 			return 0;
@@ -3806,7 +3806,7 @@ no_journal:
 	}
 
 	if ((DUMMY_ENCRYPTION_ENABLED(sbi) || ext4_has_feature_encrypt(sb)) &&
-	    (blocksize != PAGE_CACHE_SIZE)) {
+	    (blocksize != PAGE_SIZE)) {
 		ext4_msg(sb, KERN_ERR,
 			 "Unsupported blocksize for fs encryption");
 		goto failed_mount_wq;
diff --git a/fs/ext4/symlink.c b/fs/ext4/symlink.c
index 6f7ee30a89ce..75ed5c2f0c16 100644
--- a/fs/ext4/symlink.c
+++ b/fs/ext4/symlink.c
@@ -80,12 +80,12 @@ static const char *ext4_encrypted_get_link(struct dentry *dentry,
 	if (res <= plen)
 		paddr[res] = '\0';
 	if (cpage)
-		page_cache_release(cpage);
+		put_page(cpage);
 	set_delayed_call(done, kfree_link, paddr);
 	return paddr;
 errout:
 	if (cpage)
-		page_cache_release(cpage);
+		put_page(cpage);
 	kfree(paddr);
 	return ERR_PTR(res);
 }
diff --git a/fs/f2fs/crypto.c b/fs/f2fs/crypto.c
index 95c5cf039711..da186961a5f0 100644
--- a/fs/f2fs/crypto.c
+++ b/fs/f2fs/crypto.c
@@ -350,10 +350,10 @@ static int f2fs_page_crypto(struct f2fs_crypto_ctx *ctx,
 			F2FS_XTS_TWEAK_SIZE - sizeof(index));
 
 	sg_init_table(&dst, 1);
-	sg_set_page(&dst, dest_page, PAGE_CACHE_SIZE, 0);
+	sg_set_page(&dst, dest_page, PAGE_SIZE, 0);
 	sg_init_table(&src, 1);
-	sg_set_page(&src, src_page, PAGE_CACHE_SIZE, 0);
-	skcipher_request_set_crypt(req, &src, &dst, PAGE_CACHE_SIZE,
+	sg_set_page(&src, src_page, PAGE_SIZE, 0);
+	skcipher_request_set_crypt(req, &src, &dst, PAGE_SIZE,
 				   xts_tweak);
 	if (rw == F2FS_DECRYPT)
 		res = crypto_skcipher_decrypt(req);
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 5c06db17e41f..8654e83bcea1 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -153,7 +153,7 @@ int f2fs_submit_page_bio(struct f2fs_io_info *fio)
 	/* Allocate a new bio */
 	bio = __bio_alloc(fio->sbi, fio->blk_addr, 1, is_read_io(fio->rw));
 
-	if (bio_add_page(bio, page, PAGE_CACHE_SIZE, 0) < PAGE_CACHE_SIZE) {
+	if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE) {
 		bio_put(bio);
 		return -EFAULT;
 	}
@@ -192,8 +192,8 @@ alloc_new:
 
 	bio_page = fio->encrypted_page ? fio->encrypted_page : fio->page;
 
-	if (bio_add_page(io->bio, bio_page, PAGE_CACHE_SIZE, 0) <
-							PAGE_CACHE_SIZE) {
+	if (bio_add_page(io->bio, bio_page, PAGE_SIZE, 0) <
+							PAGE_SIZE) {
 		__submit_merged_bio(io);
 		goto alloc_new;
 	}
@@ -326,7 +326,7 @@ got_it:
 	 * see, f2fs_add_link -> get_new_data_page -> init_inode_metadata.
 	 */
 	if (dn.data_blkaddr == NEW_ADDR) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		unlock_page(page);
 		return page;
@@ -437,7 +437,7 @@ struct page *get_new_data_page(struct inode *inode,
 		goto got_it;
 
 	if (dn.data_blkaddr == NEW_ADDR) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 	} else {
 		f2fs_put_page(page, 1);
@@ -450,8 +450,8 @@ struct page *get_new_data_page(struct inode *inode,
 	}
 got_it:
 	if (new_i_size && i_size_read(inode) <
-				((loff_t)(index + 1) << PAGE_CACHE_SHIFT)) {
-		i_size_write(inode, ((loff_t)(index + 1) << PAGE_CACHE_SHIFT));
+				((loff_t)(index + 1) << PAGE_SHIFT)) {
+		i_size_write(inode, ((loff_t)(index + 1) << PAGE_SHIFT));
 		/* Only the directory inode sets new_i_size */
 		set_inode_flag(F2FS_I(inode), FI_UPDATE_DIR);
 	}
@@ -491,9 +491,9 @@ alloc:
 	/* update i_size */
 	fofs = start_bidx_of_node(ofs_of_node(dn->node_page), fi) +
 							dn->ofs_in_node;
-	if (i_size_read(dn->inode) < ((loff_t)(fofs + 1) << PAGE_CACHE_SHIFT))
+	if (i_size_read(dn->inode) < ((loff_t)(fofs + 1) << PAGE_SHIFT))
 		i_size_write(dn->inode,
-				((loff_t)(fofs + 1) << PAGE_CACHE_SHIFT));
+				((loff_t)(fofs + 1) << PAGE_SHIFT));
 	return 0;
 }
 
@@ -940,7 +940,7 @@ got_it:
 				goto confused;
 			}
 		} else {
-			zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+			zero_user_segment(page, 0, PAGE_SIZE);
 			SetPageUptodate(page);
 			unlock_page(page);
 			goto next_page;
@@ -990,7 +990,7 @@ submit_and_realloc:
 		goto next_page;
 set_error_page:
 		SetPageError(page);
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 		unlock_page(page);
 		goto next_page;
 confused:
@@ -1001,7 +1001,7 @@ confused:
 		unlock_page(page);
 next_page:
 		if (pages)
-			page_cache_release(page);
+			put_page(page);
 	}
 	BUG_ON(pages && !list_empty(pages));
 	if (bio)
@@ -1107,7 +1107,7 @@ static int f2fs_write_data_page(struct page *page,
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = ((unsigned long long) i_size)
-							>> PAGE_CACHE_SHIFT;
+							>> PAGE_SHIFT;
 	unsigned offset = 0;
 	bool need_balance_fs = false;
 	int err = 0;
@@ -1128,11 +1128,11 @@ static int f2fs_write_data_page(struct page *page,
 	 * If the offset is out-of-range of file size,
 	 * this page does not have to be written to disk.
 	 */
-	offset = i_size & (PAGE_CACHE_SIZE - 1);
+	offset = i_size & (PAGE_SIZE - 1);
 	if ((page->index >= end_index + 1) || !offset)
 		goto out;
 
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 write:
 	if (unlikely(is_sbi_flag_set(sbi, SBI_POR_DOING)))
 		goto redirty_out;
@@ -1232,8 +1232,8 @@ next:
 			cycled = 0;
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		cycled = 1; /* ignore range_cyclic tests */
@@ -1407,7 +1407,7 @@ static int prepare_write_begin(struct f2fs_sb_info *sbi,
 	int err = 0;
 
 	if (f2fs_has_inline_data(inode) ||
-			(pos & PAGE_CACHE_MASK) >= i_size_read(inode)) {
+			(pos & PAGE_MASK) >= i_size_read(inode)) {
 		f2fs_lock_op(sbi);
 		locked = true;
 	}
@@ -1472,7 +1472,7 @@ static int f2fs_write_begin(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 	struct page *page = NULL;
-	pgoff_t index = ((unsigned long long) pos) >> PAGE_CACHE_SHIFT;
+	pgoff_t index = ((unsigned long long) pos) >> PAGE_SHIFT;
 	bool need_balance = false;
 	block_t blkaddr = NULL_ADDR;
 	int err = 0;
@@ -1520,22 +1520,22 @@ repeat:
 	if (f2fs_encrypted_inode(inode) && S_ISREG(inode->i_mode))
 		f2fs_wait_on_encrypted_page_writeback(sbi, blkaddr);
 
-	if (len == PAGE_CACHE_SIZE)
+	if (len == PAGE_SIZE)
 		goto out_update;
 	if (PageUptodate(page))
 		goto out_clear;
 
-	if ((pos & PAGE_CACHE_MASK) >= i_size_read(inode)) {
-		unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	if ((pos & PAGE_MASK) >= i_size_read(inode)) {
+		unsigned start = pos & (PAGE_SIZE - 1);
 		unsigned end = start + len;
 
 		/* Reading beyond i_size is simple: memset to zero */
-		zero_user_segments(page, 0, start, end, PAGE_CACHE_SIZE);
+		zero_user_segments(page, 0, start, end, PAGE_SIZE);
 		goto out_update;
 	}
 
 	if (blkaddr == NEW_ADDR) {
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 	} else {
 		struct f2fs_io_info fio = {
 			.sbi = sbi,
@@ -1660,7 +1660,7 @@ void f2fs_invalidate_page(struct page *page, unsigned int offset,
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 
 	if (inode->i_ino >= F2FS_ROOT_INO(sbi) &&
-		(offset % PAGE_CACHE_SIZE || length != PAGE_CACHE_SIZE))
+		(offset % PAGE_SIZE || length != PAGE_SIZE))
 		return;
 
 	if (PageDirty(page)) {
diff --git a/fs/f2fs/debug.c b/fs/f2fs/debug.c
index 4fb6ef88a34f..f4a61a5ff79f 100644
--- a/fs/f2fs/debug.c
+++ b/fs/f2fs/debug.c
@@ -164,7 +164,7 @@ static void update_mem_info(struct f2fs_sb_info *sbi)
 
 	/* build curseg */
 	si->base_mem += sizeof(struct curseg_info) * NR_CURSEG_TYPE;
-	si->base_mem += PAGE_CACHE_SIZE * NR_CURSEG_TYPE;
+	si->base_mem += PAGE_SIZE * NR_CURSEG_TYPE;
 
 	/* build dirty segmap */
 	si->base_mem += sizeof(struct dirty_seglist_info);
@@ -201,9 +201,9 @@ get_cache:
 
 	si->page_mem = 0;
 	npages = NODE_MAPPING(sbi)->nrpages;
-	si->page_mem += (unsigned long long)npages << PAGE_CACHE_SHIFT;
+	si->page_mem += (unsigned long long)npages << PAGE_SHIFT;
 	npages = META_MAPPING(sbi)->nrpages;
-	si->page_mem += (unsigned long long)npages << PAGE_CACHE_SHIFT;
+	si->page_mem += (unsigned long long)npages << PAGE_SHIFT;
 }
 
 static int stat_show(struct seq_file *s, void *v)
diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index faa7495e2d7e..8e07acbaeae6 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -17,8 +17,8 @@
 
 static unsigned long dir_blocks(struct inode *inode)
 {
-	return ((unsigned long long) (i_size_read(inode) + PAGE_CACHE_SIZE - 1))
-							>> PAGE_CACHE_SHIFT;
+	return ((unsigned long long) (i_size_read(inode) + PAGE_SIZE - 1))
+							>> PAGE_SHIFT;
 }
 
 static unsigned int dir_buckets(unsigned int level, int dir_level)
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index ff79054c6cf6..0de2ee482828 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1306,7 +1306,7 @@ static inline void f2fs_put_page(struct page *page, int unlock)
 		f2fs_bug_on(F2FS_P_SB(page), !PageLocked(page));
 		unlock_page(page);
 	}
-	page_cache_release(page);
+	put_page(page);
 }
 
 static inline void f2fs_put_dnode(struct dnode_of_data *dn)
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index ea272be62677..eafaa6dceefc 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -74,11 +74,11 @@ static int f2fs_vm_page_mkwrite(struct vm_area_struct *vma,
 		goto mapped;
 
 	/* page is wholly or partially inside EOF */
-	if (((loff_t)(page->index + 1) << PAGE_CACHE_SHIFT) >
+	if (((loff_t)(page->index + 1) << PAGE_SHIFT) >
 						i_size_read(inode)) {
 		unsigned offset;
-		offset = i_size_read(inode) & ~PAGE_CACHE_MASK;
-		zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+		offset = i_size_read(inode) & ~PAGE_MASK;
+		zero_user_segment(page, offset, PAGE_SIZE);
 	}
 	set_page_dirty(page);
 	SetPageUptodate(page);
@@ -346,11 +346,11 @@ static loff_t f2fs_seek_block(struct file *file, loff_t offset, int whence)
 		goto found;
 	}
 
-	pgofs = (pgoff_t)(offset >> PAGE_CACHE_SHIFT);
+	pgofs = (pgoff_t)(offset >> PAGE_SHIFT);
 
 	dirty = __get_first_dirty_index(inode->i_mapping, pgofs, whence);
 
-	for (; data_ofs < isize; data_ofs = (loff_t)pgofs << PAGE_CACHE_SHIFT) {
+	for (; data_ofs < isize; data_ofs = (loff_t)pgofs << PAGE_SHIFT) {
 		set_new_dnode(&dn, inode, NULL, NULL, 0);
 		err = get_dnode_of_data(&dn, pgofs, LOOKUP_NODE_RA);
 		if (err && err != -ENOENT) {
@@ -371,7 +371,7 @@ static loff_t f2fs_seek_block(struct file *file, loff_t offset, int whence)
 		/* find data/hole in dnode block */
 		for (; dn.ofs_in_node < end_offset;
 				dn.ofs_in_node++, pgofs++,
-				data_ofs = (loff_t)pgofs << PAGE_CACHE_SHIFT) {
+				data_ofs = (loff_t)pgofs << PAGE_SHIFT) {
 			block_t blkaddr;
 			blkaddr = datablock_addr(dn.node_page, dn.ofs_in_node);
 
@@ -501,8 +501,8 @@ void truncate_data_blocks(struct dnode_of_data *dn)
 static int truncate_partial_data_page(struct inode *inode, u64 from,
 								bool cache_only)
 {
-	unsigned offset = from & (PAGE_CACHE_SIZE - 1);
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE - 1);
+	pgoff_t index = from >> PAGE_SHIFT;
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
 
@@ -522,7 +522,7 @@ static int truncate_partial_data_page(struct inode *inode, u64 from,
 		return 0;
 truncate_out:
 	f2fs_wait_on_page_writeback(page, DATA);
-	zero_user(page, offset, PAGE_CACHE_SIZE - offset);
+	zero_user(page, offset, PAGE_SIZE - offset);
 	if (!cache_only || !f2fs_encrypted_inode(inode) || !S_ISREG(inode->i_mode))
 		set_page_dirty(page);
 	f2fs_put_page(page, 1);
@@ -791,11 +791,11 @@ static int punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	if (ret)
 		return ret;
 
-	pg_start = ((unsigned long long) offset) >> PAGE_CACHE_SHIFT;
-	pg_end = ((unsigned long long) offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = ((unsigned long long) offset) >> PAGE_SHIFT;
+	pg_end = ((unsigned long long) offset + len) >> PAGE_SHIFT;
 
-	off_start = offset & (PAGE_CACHE_SIZE - 1);
-	off_end = (offset + len) & (PAGE_CACHE_SIZE - 1);
+	off_start = offset & (PAGE_SIZE - 1);
+	off_end = (offset + len) & (PAGE_SIZE - 1);
 
 	if (pg_start == pg_end) {
 		ret = fill_zero(inode, pg_start, off_start,
@@ -805,7 +805,7 @@ static int punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	} else {
 		if (off_start) {
 			ret = fill_zero(inode, pg_start++, off_start,
-						PAGE_CACHE_SIZE - off_start);
+						PAGE_SIZE - off_start);
 			if (ret)
 				return ret;
 		}
@@ -822,8 +822,8 @@ static int punch_hole(struct inode *inode, loff_t offset, loff_t len)
 
 			f2fs_balance_fs(sbi, true);
 
-			blk_start = (loff_t)pg_start << PAGE_CACHE_SHIFT;
-			blk_end = (loff_t)pg_end << PAGE_CACHE_SHIFT;
+			blk_start = (loff_t)pg_start << PAGE_SHIFT;
+			blk_end = (loff_t)pg_end << PAGE_SHIFT;
 			truncate_inode_pages_range(mapping, blk_start,
 					blk_end - 1);
 
@@ -950,8 +950,8 @@ static int f2fs_collapse_range(struct inode *inode, loff_t offset, loff_t len)
 	if (ret)
 		return ret;
 
-	pg_start = offset >> PAGE_CACHE_SHIFT;
-	pg_end = (offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = offset >> PAGE_SHIFT;
+	pg_end = (offset + len) >> PAGE_SHIFT;
 
 	/* write out all dirty pages from offset */
 	ret = filemap_write_and_wait_range(inode->i_mapping, offset, LLONG_MAX);
@@ -1002,11 +1002,11 @@ static int f2fs_zero_range(struct inode *inode, loff_t offset, loff_t len,
 
 	truncate_pagecache_range(inode, offset, offset + len - 1);
 
-	pg_start = ((unsigned long long) offset) >> PAGE_CACHE_SHIFT;
-	pg_end = ((unsigned long long) offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = ((unsigned long long) offset) >> PAGE_SHIFT;
+	pg_end = ((unsigned long long) offset + len) >> PAGE_SHIFT;
 
-	off_start = offset & (PAGE_CACHE_SIZE - 1);
-	off_end = (offset + len) & (PAGE_CACHE_SIZE - 1);
+	off_start = offset & (PAGE_SIZE - 1);
+	off_end = (offset + len) & (PAGE_SIZE - 1);
 
 	if (pg_start == pg_end) {
 		ret = fill_zero(inode, pg_start, off_start,
@@ -1020,12 +1020,12 @@ static int f2fs_zero_range(struct inode *inode, loff_t offset, loff_t len,
 	} else {
 		if (off_start) {
 			ret = fill_zero(inode, pg_start++, off_start,
-						PAGE_CACHE_SIZE - off_start);
+						PAGE_SIZE - off_start);
 			if (ret)
 				return ret;
 
 			new_size = max_t(loff_t, new_size,
-					(loff_t)pg_start << PAGE_CACHE_SHIFT);
+					(loff_t)pg_start << PAGE_SHIFT);
 		}
 
 		for (index = pg_start; index < pg_end; index++) {
@@ -1061,7 +1061,7 @@ static int f2fs_zero_range(struct inode *inode, loff_t offset, loff_t len,
 			f2fs_unlock_op(sbi);
 
 			new_size = max_t(loff_t, new_size,
-				(loff_t)(index + 1) << PAGE_CACHE_SHIFT);
+				(loff_t)(index + 1) << PAGE_SHIFT);
 		}
 
 		if (off_end) {
@@ -1118,8 +1118,8 @@ static int f2fs_insert_range(struct inode *inode, loff_t offset, loff_t len)
 
 	truncate_pagecache(inode, offset);
 
-	pg_start = offset >> PAGE_CACHE_SHIFT;
-	pg_end = (offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = offset >> PAGE_SHIFT;
+	pg_end = (offset + len) >> PAGE_SHIFT;
 	delta = pg_end - pg_start;
 	nrpages = (i_size_read(inode) + PAGE_SIZE - 1) / PAGE_SIZE;
 
@@ -1159,11 +1159,11 @@ static int expand_inode_data(struct inode *inode, loff_t offset,
 
 	f2fs_balance_fs(sbi, true);
 
-	pg_start = ((unsigned long long) offset) >> PAGE_CACHE_SHIFT;
-	pg_end = ((unsigned long long) offset + len) >> PAGE_CACHE_SHIFT;
+	pg_start = ((unsigned long long) offset) >> PAGE_SHIFT;
+	pg_end = ((unsigned long long) offset + len) >> PAGE_SHIFT;
 
-	off_start = offset & (PAGE_CACHE_SIZE - 1);
-	off_end = (offset + len) & (PAGE_CACHE_SIZE - 1);
+	off_start = offset & (PAGE_SIZE - 1);
+	off_end = (offset + len) & (PAGE_SIZE - 1);
 
 	f2fs_lock_op(sbi);
 
@@ -1181,12 +1181,12 @@ noalloc:
 		if (pg_start == pg_end)
 			new_size = offset + len;
 		else if (index == pg_start && off_start)
-			new_size = (loff_t)(index + 1) << PAGE_CACHE_SHIFT;
+			new_size = (loff_t)(index + 1) << PAGE_SHIFT;
 		else if (index == pg_end)
-			new_size = ((loff_t)index << PAGE_CACHE_SHIFT) +
+			new_size = ((loff_t)index << PAGE_SHIFT) +
 								off_end;
 		else
-			new_size += PAGE_CACHE_SIZE;
+			new_size += PAGE_SIZE;
 	}
 
 	if (!(mode & FALLOC_FL_KEEP_SIZE) &&
@@ -1662,8 +1662,8 @@ static int f2fs_defragment_range(struct f2fs_sb_info *sbi,
 	if (need_inplace_update(inode))
 		return -EINVAL;
 
-	pg_start = range->start >> PAGE_CACHE_SHIFT;
-	pg_end = (range->start + range->len) >> PAGE_CACHE_SHIFT;
+	pg_start = range->start >> PAGE_SHIFT;
+	pg_end = (range->start + range->len) >> PAGE_SHIFT;
 
 	f2fs_balance_fs(sbi, true);
 
@@ -1780,7 +1780,7 @@ clear_out:
 out:
 	inode_unlock(inode);
 	if (!err)
-		range->len = (u64)total << PAGE_CACHE_SHIFT;
+		range->len = (u64)total << PAGE_SHIFT;
 	return err;
 }
 
diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
index c3f0b7d4cfca..b42042e79558 100644
--- a/fs/f2fs/inline.c
+++ b/fs/f2fs/inline.c
@@ -51,7 +51,7 @@ void read_inline_data(struct page *page, struct page *ipage)
 
 	f2fs_bug_on(F2FS_P_SB(page), page->index);
 
-	zero_user_segment(page, MAX_INLINE_DATA, PAGE_CACHE_SIZE);
+	zero_user_segment(page, MAX_INLINE_DATA, PAGE_SIZE);
 
 	/* Copy the whole inline data block */
 	src_addr = inline_data_addr(ipage);
@@ -93,7 +93,7 @@ int f2fs_read_inline_data(struct inode *inode, struct page *page)
 	}
 
 	if (page->index)
-		zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+		zero_user_segment(page, 0, PAGE_SIZE);
 	else
 		read_inline_data(page, ipage);
 
@@ -129,7 +129,7 @@ int f2fs_convert_inline_page(struct dnode_of_data *dn, struct page *page)
 	if (PageUptodate(page))
 		goto no_update;
 
-	zero_user_segment(page, MAX_INLINE_DATA, PAGE_CACHE_SIZE);
+	zero_user_segment(page, MAX_INLINE_DATA, PAGE_SIZE);
 
 	/* Copy the whole inline data block */
 	src_addr = inline_data_addr(dn->inode_page);
@@ -390,7 +390,7 @@ static int f2fs_convert_inline_dir(struct inode *dir, struct page *ipage,
 		goto out;
 
 	f2fs_wait_on_page_writeback(page, DATA);
-	zero_user_segment(page, MAX_INLINE_DATA, PAGE_CACHE_SIZE);
+	zero_user_segment(page, MAX_INLINE_DATA, PAGE_SIZE);
 
 	dentry_blk = kmap_atomic(page);
 
@@ -420,8 +420,8 @@ static int f2fs_convert_inline_dir(struct inode *dir, struct page *ipage,
 	stat_dec_inline_dir(dir);
 	clear_inode_flag(F2FS_I(dir), FI_INLINE_DENTRY);
 
-	if (i_size_read(dir) < PAGE_CACHE_SIZE) {
-		i_size_write(dir, PAGE_CACHE_SIZE);
+	if (i_size_read(dir) < PAGE_SIZE) {
+		i_size_write(dir, PAGE_SIZE);
 		set_inode_flag(F2FS_I(dir), FI_UPDATE_DIR);
 	}
 
diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index 6f944e5eb76e..5a5538f2b53b 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -1007,13 +1007,13 @@ static const char *f2fs_encrypted_get_link(struct dentry *dentry,
 	/* Null-terminate the name */
 	paddr[res] = '\0';
 
-	page_cache_release(cpage);
+	put_page(cpage);
 	set_delayed_call(done, kfree_link, paddr);
 	return paddr;
 errout:
 	kfree(cstr.name);
 	f2fs_fname_crypto_free_buffer(&pstr);
-	page_cache_release(cpage);
+	put_page(cpage);
 	return ERR_PTR(res);
 }
 
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 342597a5897f..7b9ff127093a 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -46,11 +46,11 @@ bool available_free_memory(struct f2fs_sb_info *sbi, int type)
 	 */
 	if (type == FREE_NIDS) {
 		mem_size = (nm_i->fcnt * sizeof(struct free_nid)) >>
-							PAGE_CACHE_SHIFT;
+							PAGE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 2);
 	} else if (type == NAT_ENTRIES) {
 		mem_size = (nm_i->nat_cnt * sizeof(struct nat_entry)) >>
-							PAGE_CACHE_SHIFT;
+							PAGE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 2);
 	} else if (type == DIRTY_DENTS) {
 		if (sbi->sb->s_bdi->wb.dirty_exceeded)
@@ -62,13 +62,13 @@ bool available_free_memory(struct f2fs_sb_info *sbi, int type)
 
 		for (i = 0; i <= UPDATE_INO; i++)
 			mem_size += (sbi->im[i].ino_num *
-				sizeof(struct ino_entry)) >> PAGE_CACHE_SHIFT;
+				sizeof(struct ino_entry)) >> PAGE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 1);
 	} else if (type == EXTENT_CACHE) {
 		mem_size = (atomic_read(&sbi->total_ext_tree) *
 				sizeof(struct extent_tree) +
 				atomic_read(&sbi->total_ext_node) *
-				sizeof(struct extent_node)) >> PAGE_CACHE_SHIFT;
+				sizeof(struct extent_node)) >> PAGE_SHIFT;
 		res = mem_size < ((avail_ram * nm_i->ram_thresh / 100) >> 1);
 	} else {
 		if (!sbi->sb->s_bdi->wb.dirty_exceeded)
@@ -121,7 +121,7 @@ static struct page *get_next_nat_page(struct f2fs_sb_info *sbi, nid_t nid)
 
 	src_addr = page_address(src_page);
 	dst_addr = page_address(dst_page);
-	memcpy(dst_addr, src_addr, PAGE_CACHE_SIZE);
+	memcpy(dst_addr, src_addr, PAGE_SIZE);
 	set_page_dirty(dst_page);
 	f2fs_put_page(src_page, 1);
 
diff --git a/fs/f2fs/recovery.c b/fs/f2fs/recovery.c
index 589b20b8677b..45f53f27a5f6 100644
--- a/fs/f2fs/recovery.c
+++ b/fs/f2fs/recovery.c
@@ -593,7 +593,7 @@ out:
 
 	/* truncate meta pages to be used by the recovery */
 	truncate_inode_pages_range(META_MAPPING(sbi),
-			(loff_t)MAIN_BLKADDR(sbi) << PAGE_CACHE_SHIFT, -1);
+			(loff_t)MAIN_BLKADDR(sbi) << PAGE_SHIFT, -1);
 
 	if (err) {
 		truncate_inode_pages_final(NODE_MAPPING(sbi));
diff --git a/fs/f2fs/segment.c b/fs/f2fs/segment.c
index 5904a411c86f..89ba77786772 100644
--- a/fs/f2fs/segment.c
+++ b/fs/f2fs/segment.c
@@ -804,12 +804,12 @@ int npages_for_summary_flush(struct f2fs_sb_info *sbi, bool for_ra)
 		}
 	}
 
-	sum_in_page = (PAGE_CACHE_SIZE - 2 * SUM_JOURNAL_SIZE -
+	sum_in_page = (PAGE_SIZE - 2 * SUM_JOURNAL_SIZE -
 			SUM_FOOTER_SIZE) / SUMMARY_SIZE;
 	if (valid_sum_count <= sum_in_page)
 		return 1;
 	else if ((valid_sum_count - sum_in_page) <=
-		(PAGE_CACHE_SIZE - SUM_FOOTER_SIZE) / SUMMARY_SIZE)
+		(PAGE_SIZE - SUM_FOOTER_SIZE) / SUMMARY_SIZE)
 		return 2;
 	return 3;
 }
@@ -828,9 +828,9 @@ void update_meta_page(struct f2fs_sb_info *sbi, void *src, block_t blk_addr)
 	void *dst = page_address(page);
 
 	if (src)
-		memcpy(dst, src, PAGE_CACHE_SIZE);
+		memcpy(dst, src, PAGE_SIZE);
 	else
-		memset(dst, 0, PAGE_CACHE_SIZE);
+		memset(dst, 0, PAGE_SIZE);
 	set_page_dirty(page);
 	f2fs_put_page(page, 1);
 }
@@ -1527,7 +1527,7 @@ static int read_compacted_summaries(struct f2fs_sb_info *sbi)
 			s = (struct f2fs_summary *)(kaddr + offset);
 			seg_i->sum_blk->entries[j] = *s;
 			offset += SUMMARY_SIZE;
-			if (offset + SUMMARY_SIZE <= PAGE_CACHE_SIZE -
+			if (offset + SUMMARY_SIZE <= PAGE_SIZE -
 						SUM_FOOTER_SIZE)
 				continue;
 
@@ -1599,7 +1599,7 @@ static int read_normal_summaries(struct f2fs_sb_info *sbi, int type)
 	/* set uncompleted segment to curseg */
 	curseg = CURSEG_I(sbi, type);
 	mutex_lock(&curseg->curseg_mutex);
-	memcpy(curseg->sum_blk, sum, PAGE_CACHE_SIZE);
+	memcpy(curseg->sum_blk, sum, PAGE_SIZE);
 	curseg->next_segno = segno;
 	reset_curseg(sbi, type, 0);
 	curseg->alloc_type = ckpt->alloc_type[type];
@@ -1682,7 +1682,7 @@ static void write_compacted_summaries(struct f2fs_sb_info *sbi, block_t blkaddr)
 			*summary = seg_i->sum_blk->entries[j];
 			written_size += SUMMARY_SIZE;
 
-			if (written_size + SUMMARY_SIZE <= PAGE_CACHE_SIZE -
+			if (written_size + SUMMARY_SIZE <= PAGE_SIZE -
 							SUM_FOOTER_SIZE)
 				continue;
 
@@ -1773,7 +1773,7 @@ static struct page *get_next_sit_page(struct f2fs_sb_info *sbi,
 
 	src_addr = page_address(src_page);
 	dst_addr = page_address(dst_page);
-	memcpy(dst_addr, src_addr, PAGE_CACHE_SIZE);
+	memcpy(dst_addr, src_addr, PAGE_SIZE);
 
 	set_page_dirty(dst_page);
 	f2fs_put_page(src_page, 1);
@@ -2096,7 +2096,7 @@ static int build_curseg(struct f2fs_sb_info *sbi)
 
 	for (i = 0; i < NR_CURSEG_TYPE; i++) {
 		mutex_init(&array[i].curseg_mutex);
-		array[i].sum_blk = kzalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+		array[i].sum_blk = kzalloc(PAGE_SIZE, GFP_KERNEL);
 		if (!array[i].sum_blk)
 			return -ENOMEM;
 		array[i].segno = NULL_SEGNO;
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 6134832baaaf..6d35862ce113 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1012,10 +1012,10 @@ static int sanity_check_raw_super(struct super_block *sb,
 	}
 
 	/* Currently, support only 4KB page cache size */
-	if (F2FS_BLKSIZE != PAGE_CACHE_SIZE) {
+	if (F2FS_BLKSIZE != PAGE_SIZE) {
 		f2fs_msg(sb, KERN_INFO,
 			"Invalid page_cache_size (%lu), supports only 4KB\n",
-			PAGE_CACHE_SIZE);
+			PAGE_SIZE);
 		return 1;
 	}
 
diff --git a/fs/freevxfs/vxfs_immed.c b/fs/freevxfs/vxfs_immed.c
index cb84f0fcc72a..bfc780c682fb 100644
--- a/fs/freevxfs/vxfs_immed.c
+++ b/fs/freevxfs/vxfs_immed.c
@@ -66,11 +66,11 @@ static int
 vxfs_immed_readpage(struct file *fp, struct page *pp)
 {
 	struct vxfs_inode_info	*vip = VXFS_INO(pp->mapping->host);
-	u_int64_t	offset = (u_int64_t)pp->index << PAGE_CACHE_SHIFT;
+	u_int64_t	offset = (u_int64_t)pp->index << PAGE_SHIFT;
 	caddr_t		kaddr;
 
 	kaddr = kmap(pp);
-	memcpy(kaddr, vip->vii_immed.vi_immed + offset, PAGE_CACHE_SIZE);
+	memcpy(kaddr, vip->vii_immed.vi_immed + offset, PAGE_SIZE);
 	kunmap(pp);
 	
 	flush_dcache_page(pp);
diff --git a/fs/freevxfs/vxfs_lookup.c b/fs/freevxfs/vxfs_lookup.c
index 1cff72df0389..a49e0cfbb686 100644
--- a/fs/freevxfs/vxfs_lookup.c
+++ b/fs/freevxfs/vxfs_lookup.c
@@ -45,7 +45,7 @@
 /*
  * Number of VxFS blocks per page.
  */
-#define VXFS_BLOCK_PER_PAGE(sbp)  ((PAGE_CACHE_SIZE / (sbp)->s_blocksize))
+#define VXFS_BLOCK_PER_PAGE(sbp)  ((PAGE_SIZE / (sbp)->s_blocksize))
 
 
 static struct dentry *	vxfs_lookup(struct inode *, struct dentry *, unsigned int);
@@ -175,7 +175,7 @@ vxfs_inode_by_name(struct inode *dip, struct dentry *dp)
 	if (de) {
 		ino = de->d_ino;
 		kunmap(pp);
-		page_cache_release(pp);
+		put_page(pp);
 	}
 	
 	return (ino);
@@ -255,8 +255,8 @@ vxfs_readdir(struct file *fp, struct dir_context *ctx)
 	nblocks = dir_blocks(ip);
 	pblocks = VXFS_BLOCK_PER_PAGE(sbp);
 
-	page = pos >> PAGE_CACHE_SHIFT;
-	offset = pos & ~PAGE_CACHE_MASK;
+	page = pos >> PAGE_SHIFT;
+	offset = pos & ~PAGE_MASK;
 	block = (u_long)(pos >> sbp->s_blocksize_bits) % pblocks;
 
 	for (; page < npages; page++, block = 0) {
@@ -289,7 +289,7 @@ vxfs_readdir(struct file *fp, struct dir_context *ctx)
 					continue;
 
 				offset = (char *)de - kaddr;
-				ctx->pos = ((page << PAGE_CACHE_SHIFT) | offset) + 2;
+				ctx->pos = ((page << PAGE_SHIFT) | offset) + 2;
 				if (!dir_emit(ctx, de->d_name, de->d_namelen,
 					de->d_ino, DT_UNKNOWN)) {
 					vxfs_put_page(pp);
@@ -301,6 +301,6 @@ vxfs_readdir(struct file *fp, struct dir_context *ctx)
 		vxfs_put_page(pp);
 		offset = 0;
 	}
-	ctx->pos = ((page << PAGE_CACHE_SHIFT) | offset) + 2;
+	ctx->pos = ((page << PAGE_SHIFT) | offset) + 2;
 	return 0;
 }
diff --git a/fs/freevxfs/vxfs_subr.c b/fs/freevxfs/vxfs_subr.c
index 5d318c44f855..e806694d4145 100644
--- a/fs/freevxfs/vxfs_subr.c
+++ b/fs/freevxfs/vxfs_subr.c
@@ -50,7 +50,7 @@ inline void
 vxfs_put_page(struct page *pp)
 {
 	kunmap(pp);
-	page_cache_release(pp);
+	put_page(pp);
 }
 
 /**
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 5c46ed9f3e14..671e1780afc3 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -33,7 +33,7 @@
 /*
  * 4MB minimal write chunk size
  */
-#define MIN_WRITEBACK_PAGES	(4096UL >> (PAGE_CACHE_SHIFT - 10))
+#define MIN_WRITEBACK_PAGES	(4096UL >> (PAGE_SHIFT - 10))
 
 struct wb_completion {
 	atomic_t		cnt;
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 6b35fc4860a0..3078b679fcd1 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -113,7 +113,7 @@ try_again:
 
 	wake_up_bit(&cookie->flags, 0);
 	if (xpage)
-		page_cache_release(xpage);
+		put_page(xpage);
 	__fscache_uncache_page(cookie, page);
 	return true;
 
@@ -164,7 +164,7 @@ static void fscache_end_page_write(struct fscache_object *object,
 	}
 	spin_unlock(&object->lock);
 	if (xpage)
-		page_cache_release(xpage);
+		put_page(xpage);
 }
 
 /*
@@ -884,7 +884,7 @@ void fscache_invalidate_writes(struct fscache_cookie *cookie)
 		spin_unlock(&cookie->stores_lock);
 
 		for (i = n - 1; i >= 0; i--)
-			page_cache_release(results[i]);
+			put_page(results[i]);
 	}
 
 	_leave("");
@@ -982,7 +982,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 
 	radix_tree_tag_set(&cookie->stores, page->index,
 			   FSCACHE_COOKIE_PENDING_TAG);
-	page_cache_get(page);
+	get_page(page);
 
 	/* we only want one writer at a time, but we do need to queue new
 	 * writers after exclusive ops */
@@ -1026,7 +1026,7 @@ submit_failed:
 	radix_tree_delete(&cookie->stores, page->index);
 	spin_unlock(&cookie->stores_lock);
 	wake_cookie = __fscache_unuse_cookie(cookie);
-	page_cache_release(page);
+	put_page(page);
 	ret = -ENOBUFS;
 	goto nobufs;
 
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index ebb5e37455a0..cbece1221417 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -897,7 +897,7 @@ static int fuse_try_move_page(struct fuse_copy_state *cs, struct page **pagep)
 		return err;
 	}
 
-	page_cache_get(newpage);
+	get_page(newpage);
 
 	if (!(buf->flags & PIPE_BUF_FLAG_LRU))
 		lru_cache_add_file(newpage);
@@ -912,12 +912,12 @@ static int fuse_try_move_page(struct fuse_copy_state *cs, struct page **pagep)
 
 	if (err) {
 		unlock_page(newpage);
-		page_cache_release(newpage);
+		put_page(newpage);
 		return err;
 	}
 
 	unlock_page(oldpage);
-	page_cache_release(oldpage);
+	put_page(oldpage);
 	cs->len = 0;
 
 	return 0;
@@ -951,7 +951,7 @@ static int fuse_ref_page(struct fuse_copy_state *cs, struct page *page,
 	fuse_copy_finish(cs);
 
 	buf = cs->pipebufs;
-	page_cache_get(page);
+	get_page(page);
 	buf->page = page;
 	buf->offset = offset;
 	buf->len = count;
@@ -1435,7 +1435,7 @@ out_unlock:
 
 out:
 	for (; page_nr < cs.nr_segs; page_nr++)
-		page_cache_release(bufs[page_nr].page);
+		put_page(bufs[page_nr].page);
 
 	kfree(bufs);
 	return ret;
@@ -1632,8 +1632,8 @@ static int fuse_notify_store(struct fuse_conn *fc, unsigned int size,
 		goto out_up_killsb;
 
 	mapping = inode->i_mapping;
-	index = outarg.offset >> PAGE_CACHE_SHIFT;
-	offset = outarg.offset & ~PAGE_CACHE_MASK;
+	index = outarg.offset >> PAGE_SHIFT;
+	offset = outarg.offset & ~PAGE_MASK;
 	file_size = i_size_read(inode);
 	end = outarg.offset + outarg.size;
 	if (end > file_size) {
@@ -1652,13 +1652,13 @@ static int fuse_notify_store(struct fuse_conn *fc, unsigned int size,
 		if (!page)
 			goto out_iput;
 
-		this_num = min_t(unsigned, num, PAGE_CACHE_SIZE - offset);
+		this_num = min_t(unsigned, num, PAGE_SIZE - offset);
 		err = fuse_copy_page(cs, &page, offset, this_num, 0);
 		if (!err && offset == 0 &&
-		    (this_num == PAGE_CACHE_SIZE || file_size == end))
+		    (this_num == PAGE_SIZE || file_size == end))
 			SetPageUptodate(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		if (err)
 			goto out_iput;
@@ -1697,7 +1697,7 @@ static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
 	size_t total_len = 0;
 	int num_pages;
 
-	offset = outarg->offset & ~PAGE_CACHE_MASK;
+	offset = outarg->offset & ~PAGE_MASK;
 	file_size = i_size_read(inode);
 
 	num = outarg->size;
@@ -1720,7 +1720,7 @@ static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
 	req->page_descs[0].offset = offset;
 	req->end = fuse_retrieve_end;
 
-	index = outarg->offset >> PAGE_CACHE_SHIFT;
+	index = outarg->offset >> PAGE_SHIFT;
 
 	while (num && req->num_pages < num_pages) {
 		struct page *page;
@@ -1730,7 +1730,7 @@ static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
 		if (!page)
 			break;
 
-		this_num = min_t(unsigned, num, PAGE_CACHE_SIZE - offset);
+		this_num = min_t(unsigned, num, PAGE_SIZE - offset);
 		req->pages[req->num_pages] = page;
 		req->page_descs[req->num_pages].length = this_num;
 		req->num_pages++;
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index b03d253ece15..6fc09c6fc80c 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -348,7 +348,7 @@ static bool fuse_range_is_writeback(struct inode *inode, pgoff_t idx_from,
 		pgoff_t curr_index;
 
 		BUG_ON(req->inode != inode);
-		curr_index = req->misc.write.in.offset >> PAGE_CACHE_SHIFT;
+		curr_index = req->misc.write.in.offset >> PAGE_SHIFT;
 		if (idx_from < curr_index + req->num_pages &&
 		    curr_index <= idx_to) {
 			found = true;
@@ -676,11 +676,11 @@ static void fuse_short_read(struct fuse_req *req, struct inode *inode,
 		 * present there.
 		 */
 		int i;
-		int start_idx = num_read >> PAGE_CACHE_SHIFT;
-		size_t off = num_read & (PAGE_CACHE_SIZE - 1);
+		int start_idx = num_read >> PAGE_SHIFT;
+		size_t off = num_read & (PAGE_SIZE - 1);
 
 		for (i = start_idx; i < req->num_pages; i++) {
-			zero_user_segment(req->pages[i], off, PAGE_CACHE_SIZE);
+			zero_user_segment(req->pages[i], off, PAGE_SIZE);
 			off = 0;
 		}
 	} else {
@@ -697,7 +697,7 @@ static int fuse_do_readpage(struct file *file, struct page *page)
 	struct fuse_req *req;
 	size_t num_read;
 	loff_t pos = page_offset(page);
-	size_t count = PAGE_CACHE_SIZE;
+	size_t count = PAGE_SIZE;
 	u64 attr_ver;
 	int err;
 
@@ -782,7 +782,7 @@ static void fuse_readpages_end(struct fuse_conn *fc, struct fuse_req *req)
 		else
 			SetPageError(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (req->ff)
 		fuse_file_put(req->ff, false);
@@ -793,7 +793,7 @@ static void fuse_send_readpages(struct fuse_req *req, struct file *file)
 	struct fuse_file *ff = file->private_data;
 	struct fuse_conn *fc = ff->fc;
 	loff_t pos = page_offset(req->pages[0]);
-	size_t count = req->num_pages << PAGE_CACHE_SHIFT;
+	size_t count = req->num_pages << PAGE_SHIFT;
 
 	req->out.argpages = 1;
 	req->out.page_zeroing = 1;
@@ -829,7 +829,7 @@ static int fuse_readpages_fill(void *_data, struct page *page)
 
 	if (req->num_pages &&
 	    (req->num_pages == FUSE_MAX_PAGES_PER_REQ ||
-	     (req->num_pages + 1) * PAGE_CACHE_SIZE > fc->max_read ||
+	     (req->num_pages + 1) * PAGE_SIZE > fc->max_read ||
 	     req->pages[req->num_pages - 1]->index + 1 != page->index)) {
 		int nr_alloc = min_t(unsigned, data->nr_pages,
 				     FUSE_MAX_PAGES_PER_REQ);
@@ -851,7 +851,7 @@ static int fuse_readpages_fill(void *_data, struct page *page)
 		return -EIO;
 	}
 
-	page_cache_get(page);
+	get_page(page);
 	req->pages[req->num_pages] = page;
 	req->page_descs[req->num_pages].length = PAGE_SIZE;
 	req->num_pages++;
@@ -996,17 +996,17 @@ static size_t fuse_send_write_pages(struct fuse_req *req, struct file *file,
 	for (i = 0; i < req->num_pages; i++) {
 		struct page *page = req->pages[i];
 
-		if (!req->out.h.error && !offset && count >= PAGE_CACHE_SIZE)
+		if (!req->out.h.error && !offset && count >= PAGE_SIZE)
 			SetPageUptodate(page);
 
-		if (count > PAGE_CACHE_SIZE - offset)
-			count -= PAGE_CACHE_SIZE - offset;
+		if (count > PAGE_SIZE - offset)
+			count -= PAGE_SIZE - offset;
 		else
 			count = 0;
 		offset = 0;
 
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	return res;
@@ -1017,7 +1017,7 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 			       struct iov_iter *ii, loff_t pos)
 {
 	struct fuse_conn *fc = get_fuse_conn(mapping->host);
-	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned offset = pos & (PAGE_SIZE - 1);
 	size_t count = 0;
 	int err;
 
@@ -1027,8 +1027,8 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 	do {
 		size_t tmp;
 		struct page *page;
-		pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-		size_t bytes = min_t(size_t, PAGE_CACHE_SIZE - offset,
+		pgoff_t index = pos >> PAGE_SHIFT;
+		size_t bytes = min_t(size_t, PAGE_SIZE - offset,
 				     iov_iter_count(ii));
 
 		bytes = min_t(size_t, bytes, fc->max_write - count);
@@ -1052,7 +1052,7 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 		iov_iter_advance(ii, tmp);
 		if (!tmp) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			bytes = min(bytes, iov_iter_single_seg_count(ii));
 			goto again;
 		}
@@ -1065,7 +1065,7 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 		count += tmp;
 		pos += tmp;
 		offset += tmp;
-		if (offset == PAGE_CACHE_SIZE)
+		if (offset == PAGE_SIZE)
 			offset = 0;
 
 		if (!fc->big_writes)
@@ -1079,8 +1079,8 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
 static inline unsigned fuse_wr_pages(loff_t pos, size_t len)
 {
 	return min_t(unsigned,
-		     ((pos + len - 1) >> PAGE_CACHE_SHIFT) -
-		     (pos >> PAGE_CACHE_SHIFT) + 1,
+		     ((pos + len - 1) >> PAGE_SHIFT) -
+		     (pos >> PAGE_SHIFT) + 1,
 		     FUSE_MAX_PAGES_PER_REQ);
 }
 
@@ -1198,8 +1198,8 @@ static ssize_t fuse_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 			goto out;
 
 		invalidate_mapping_pages(file->f_mapping,
-					 pos >> PAGE_CACHE_SHIFT,
-					 endbyte >> PAGE_CACHE_SHIFT);
+					 pos >> PAGE_SHIFT,
+					 endbyte >> PAGE_SHIFT);
 
 		written += written_buffered;
 		iocb->ki_pos = pos + written_buffered;
@@ -1308,8 +1308,8 @@ ssize_t fuse_direct_io(struct fuse_io_priv *io, struct iov_iter *iter,
 	size_t nmax = write ? fc->max_write : fc->max_read;
 	loff_t pos = *ppos;
 	size_t count = iov_iter_count(iter);
-	pgoff_t idx_from = pos >> PAGE_CACHE_SHIFT;
-	pgoff_t idx_to = (pos + count - 1) >> PAGE_CACHE_SHIFT;
+	pgoff_t idx_from = pos >> PAGE_SHIFT;
+	pgoff_t idx_to = (pos + count - 1) >> PAGE_SHIFT;
 	ssize_t res = 0;
 	struct fuse_req *req;
 
@@ -1460,7 +1460,7 @@ __acquires(fc->lock)
 {
 	struct fuse_inode *fi = get_fuse_inode(req->inode);
 	struct fuse_write_in *inarg = &req->misc.write.in;
-	__u64 data_size = req->num_pages * PAGE_CACHE_SIZE;
+	__u64 data_size = req->num_pages * PAGE_SIZE;
 
 	if (!fc->connected)
 		goto out_free;
@@ -1721,7 +1721,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 	list_del(&new_req->writepages_entry);
 	list_for_each_entry(old_req, &fi->writepages, writepages_entry) {
 		BUG_ON(old_req->inode != new_req->inode);
-		curr_index = old_req->misc.write.in.offset >> PAGE_CACHE_SHIFT;
+		curr_index = old_req->misc.write.in.offset >> PAGE_SHIFT;
 		if (curr_index <= page->index &&
 		    page->index < curr_index + old_req->num_pages) {
 			found = true;
@@ -1736,7 +1736,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 	new_req->num_pages = 1;
 	for (tmp = old_req; tmp != NULL; tmp = tmp->misc.write.next) {
 		BUG_ON(tmp->inode != new_req->inode);
-		curr_index = tmp->misc.write.in.offset >> PAGE_CACHE_SHIFT;
+		curr_index = tmp->misc.write.in.offset >> PAGE_SHIFT;
 		if (tmp->num_pages == 1 &&
 		    curr_index == page->index) {
 			old_req = tmp;
@@ -1793,7 +1793,7 @@ static int fuse_writepages_fill(struct page *page,
 
 	if (req && req->num_pages &&
 	    (is_writeback || req->num_pages == FUSE_MAX_PAGES_PER_REQ ||
-	     (req->num_pages + 1) * PAGE_CACHE_SIZE > fc->max_write ||
+	     (req->num_pages + 1) * PAGE_SIZE > fc->max_write ||
 	     data->orig_pages[req->num_pages - 1]->index + 1 != page->index)) {
 		fuse_writepages_send(data);
 		data->req = NULL;
@@ -1918,7 +1918,7 @@ static int fuse_write_begin(struct file *file, struct address_space *mapping,
 		loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, void **fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct fuse_conn *fc = get_fuse_conn(file_inode(file));
 	struct page *page;
 	loff_t fsize;
@@ -1932,15 +1932,15 @@ static int fuse_write_begin(struct file *file, struct address_space *mapping,
 
 	fuse_wait_on_page_writeback(mapping->host, page->index);
 
-	if (PageUptodate(page) || len == PAGE_CACHE_SIZE)
+	if (PageUptodate(page) || len == PAGE_SIZE)
 		goto success;
 	/*
 	 * Check if the start this page comes after the end of file, in which
 	 * case the readpage can be optimized away.
 	 */
 	fsize = i_size_read(mapping->host);
-	if (fsize <= (pos & PAGE_CACHE_MASK)) {
-		size_t off = pos & ~PAGE_CACHE_MASK;
+	if (fsize <= (pos & PAGE_MASK)) {
+		size_t off = pos & ~PAGE_MASK;
 		if (off)
 			zero_user_segment(page, 0, off);
 		goto success;
@@ -1954,7 +1954,7 @@ success:
 
 cleanup:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 error:
 	return err;
 }
@@ -1967,16 +1967,16 @@ static int fuse_write_end(struct file *file, struct address_space *mapping,
 
 	if (!PageUptodate(page)) {
 		/* Zero any unwritten bytes at the end of the page */
-		size_t endoff = (pos + copied) & ~PAGE_CACHE_MASK;
+		size_t endoff = (pos + copied) & ~PAGE_MASK;
 		if (endoff)
-			zero_user_segment(page, endoff, PAGE_CACHE_SIZE);
+			zero_user_segment(page, endoff, PAGE_SIZE);
 		SetPageUptodate(page);
 	}
 
 	fuse_write_update_size(inode, pos + copied);
 	set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 4d69d5c0bedc..1ce67668a8e1 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -339,11 +339,11 @@ int fuse_reverse_inval_inode(struct super_block *sb, u64 nodeid,
 
 	fuse_invalidate_attr(inode);
 	if (offset >= 0) {
-		pg_start = offset >> PAGE_CACHE_SHIFT;
+		pg_start = offset >> PAGE_SHIFT;
 		if (len <= 0)
 			pg_end = -1;
 		else
-			pg_end = (offset + len - 1) >> PAGE_CACHE_SHIFT;
+			pg_end = (offset + len - 1) >> PAGE_SHIFT;
 		invalidate_inode_pages2_range(inode->i_mapping,
 					      pg_start, pg_end);
 	}
@@ -864,7 +864,7 @@ static void process_init_reply(struct fuse_conn *fc, struct fuse_req *req)
 		process_init_limits(fc, arg);
 
 		if (arg->minor >= 6) {
-			ra_pages = arg->max_readahead / PAGE_CACHE_SIZE;
+			ra_pages = arg->max_readahead / PAGE_SIZE;
 			if (arg->flags & FUSE_ASYNC_READ)
 				fc->async_read = 1;
 			if (!(arg->flags & FUSE_POSIX_LOCKS))
@@ -901,7 +901,7 @@ static void process_init_reply(struct fuse_conn *fc, struct fuse_req *req)
 			if (arg->time_gran && arg->time_gran <= 1000000000)
 				fc->sb->s_time_gran = arg->time_gran;
 		} else {
-			ra_pages = fc->max_read / PAGE_CACHE_SIZE;
+			ra_pages = fc->max_read / PAGE_SIZE;
 			fc->no_lock = 1;
 			fc->no_flock = 1;
 		}
@@ -922,7 +922,7 @@ static void fuse_send_init(struct fuse_conn *fc, struct fuse_req *req)
 
 	arg->major = FUSE_KERNEL_VERSION;
 	arg->minor = FUSE_KERNEL_MINOR_VERSION;
-	arg->max_readahead = fc->bdi.ra_pages * PAGE_CACHE_SIZE;
+	arg->max_readahead = fc->bdi.ra_pages * PAGE_SIZE;
 	arg->flags |= FUSE_ASYNC_READ | FUSE_POSIX_LOCKS | FUSE_ATOMIC_O_TRUNC |
 		FUSE_EXPORT_SUPPORT | FUSE_BIG_WRITES | FUSE_DONT_MASK |
 		FUSE_SPLICE_WRITE | FUSE_SPLICE_MOVE | FUSE_SPLICE_READ |
@@ -955,7 +955,7 @@ static int fuse_bdi_init(struct fuse_conn *fc, struct super_block *sb)
 	int err;
 
 	fc->bdi.name = "fuse";
-	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_SIZE;
 	/* fuse does it's own writeback accounting */
 	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB | BDI_CAP_STRICTLIMIT;
 
@@ -1053,8 +1053,8 @@ static int fuse_fill_super(struct super_block *sb, void *data, int silent)
 			goto err;
 #endif
 	} else {
-		sb->s_blocksize = PAGE_CACHE_SIZE;
-		sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+		sb->s_blocksize = PAGE_SIZE;
+		sb->s_blocksize_bits = PAGE_SHIFT;
 	}
 	sb->s_magic = FUSE_SUPER_MAGIC;
 	sb->s_op = &fuse_super_operations;
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index aa016e4b8bec..1bbbee945f46 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -101,7 +101,7 @@ static int gfs2_writepage_common(struct page *page,
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	loff_t i_size = i_size_read(inode);
-	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
 
 	if (gfs2_assert_withdraw(sdp, gfs2_glock_is_held_excl(ip->i_gl)))
@@ -109,9 +109,9 @@ static int gfs2_writepage_common(struct page *page,
 	if (current->journal_info)
 		goto redirty;
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = i_size & (PAGE_SIZE-1);
 	if (page->index > end_index || (page->index == end_index && !offset)) {
-		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		page->mapping->a_ops->invalidatepage(page, 0, PAGE_SIZE);
 		goto out;
 	}
 	return 1;
@@ -238,7 +238,7 @@ static int gfs2_write_jdata_pagevec(struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
-	unsigned nrblocks = nr_pages * (PAGE_CACHE_SIZE/inode->i_sb->s_blocksize);
+	unsigned nrblocks = nr_pages * (PAGE_SIZE/inode->i_sb->s_blocksize);
 	int i;
 	int ret;
 
@@ -366,8 +366,8 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
 			cycled = 0;
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		cycled = 1; /* ignore range_cyclic tests */
@@ -458,7 +458,7 @@ static int stuffed_readpage(struct gfs2_inode *ip, struct page *page)
 	 * so we need to supply one here. It doesn't happen often.
 	 */
 	if (unlikely(page->index)) {
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+		zero_user(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		return 0;
 	}
@@ -471,7 +471,7 @@ static int stuffed_readpage(struct gfs2_inode *ip, struct page *page)
 	if (dsize > (dibh->b_size - sizeof(struct gfs2_dinode)))
 		dsize = (dibh->b_size - sizeof(struct gfs2_dinode));
 	memcpy(kaddr, dibh->b_data + sizeof(struct gfs2_dinode), dsize);
-	memset(kaddr + dsize, 0, PAGE_CACHE_SIZE - dsize);
+	memset(kaddr + dsize, 0, PAGE_SIZE - dsize);
 	kunmap_atomic(kaddr);
 	flush_dcache_page(page);
 	brelse(dibh);
@@ -560,8 +560,8 @@ int gfs2_internal_read(struct gfs2_inode *ip, char *buf, loff_t *pos,
                        unsigned size)
 {
 	struct address_space *mapping = ip->i_inode.i_mapping;
-	unsigned long index = *pos / PAGE_CACHE_SIZE;
-	unsigned offset = *pos & (PAGE_CACHE_SIZE - 1);
+	unsigned long index = *pos / PAGE_SIZE;
+	unsigned offset = *pos & (PAGE_SIZE - 1);
 	unsigned copied = 0;
 	unsigned amt;
 	struct page *page;
@@ -569,15 +569,15 @@ int gfs2_internal_read(struct gfs2_inode *ip, char *buf, loff_t *pos,
 
 	do {
 		amt = size - copied;
-		if (offset + size > PAGE_CACHE_SIZE)
-			amt = PAGE_CACHE_SIZE - offset;
+		if (offset + size > PAGE_SIZE)
+			amt = PAGE_SIZE - offset;
 		page = read_cache_page(mapping, index, __gfs2_readpage, NULL);
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 		p = kmap_atomic(page);
 		memcpy(buf + copied, p + offset, amt);
 		kunmap_atomic(p);
-		page_cache_release(page);
+		put_page(page);
 		copied += amt;
 		index++;
 		offset = 0;
@@ -651,8 +651,8 @@ static int gfs2_write_begin(struct file *file, struct address_space *mapping,
 	unsigned requested = 0;
 	int alloc_required;
 	int error = 0;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	pgoff_t index = pos >> PAGE_SHIFT;
+	unsigned from = pos & (PAGE_SIZE - 1);
 	struct page *page;
 
 	gfs2_holder_init(ip->i_gl, LM_ST_EXCLUSIVE, 0, &ip->i_gh);
@@ -697,7 +697,7 @@ static int gfs2_write_begin(struct file *file, struct address_space *mapping,
 		rblocks += gfs2_rg_blocks(ip, requested);
 
 	error = gfs2_trans_begin(sdp, rblocks,
-				 PAGE_CACHE_SIZE/sdp->sd_sb.sb_bsize);
+				 PAGE_SIZE/sdp->sd_sb.sb_bsize);
 	if (error)
 		goto out_trans_fail;
 
@@ -727,7 +727,7 @@ out:
 		return 0;
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	gfs2_trans_end(sdp);
 	if (pos + len > ip->i_inode.i_size)
@@ -827,7 +827,7 @@ static int gfs2_stuffed_write_end(struct inode *inode, struct buffer_head *dibh,
 	if (!PageUptodate(page))
 		SetPageUptodate(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (copied) {
 		if (inode->i_size < to)
@@ -877,7 +877,7 @@ static int gfs2_write_end(struct file *file, struct address_space *mapping,
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	struct gfs2_inode *m_ip = GFS2_I(sdp->sd_statfs_inode);
 	struct buffer_head *dibh;
-	unsigned int from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned int from = pos & (PAGE_SIZE - 1);
 	unsigned int to = from + len;
 	int ret;
 	struct gfs2_trans *tr = current->journal_info;
@@ -888,7 +888,7 @@ static int gfs2_write_end(struct file *file, struct address_space *mapping,
 	ret = gfs2_meta_inode_buffer(ip, &dibh);
 	if (unlikely(ret)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		goto failed;
 	}
 
@@ -992,7 +992,7 @@ static void gfs2_invalidatepage(struct page *page, unsigned int offset,
 {
 	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
 	unsigned int stop = offset + length;
-	int partial_page = (offset || length < PAGE_CACHE_SIZE);
+	int partial_page = (offset || length < PAGE_SIZE);
 	struct buffer_head *bh, *head;
 	unsigned long pos = 0;
 
@@ -1082,7 +1082,7 @@ static ssize_t gfs2_direct_IO(struct kiocb *iocb, struct iov_iter *iter,
 	 * the first place, mapping->nr_pages will always be zero.
 	 */
 	if (mapping->nrpages) {
-		loff_t lstart = offset & ~(PAGE_CACHE_SIZE - 1);
+		loff_t lstart = offset & ~(PAGE_SIZE - 1);
 		loff_t len = iov_iter_count(iter);
 		loff_t end = PAGE_ALIGN(offset + len) - 1;
 
diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 0860f0b5b3f1..24ce1cdd434a 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -75,7 +75,7 @@ static int gfs2_unstuffer_page(struct gfs2_inode *ip, struct buffer_head *dibh,
 			dsize = dibh->b_size - sizeof(struct gfs2_dinode);
 
 		memcpy(kaddr, dibh->b_data + sizeof(struct gfs2_dinode), dsize);
-		memset(kaddr + dsize, 0, PAGE_CACHE_SIZE - dsize);
+		memset(kaddr + dsize, 0, PAGE_SIZE - dsize);
 		kunmap(page);
 
 		SetPageUptodate(page);
@@ -98,7 +98,7 @@ static int gfs2_unstuffer_page(struct gfs2_inode *ip, struct buffer_head *dibh,
 
 	if (release) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	return 0;
@@ -932,8 +932,8 @@ static int gfs2_block_truncate_page(struct address_space *mapping, loff_t from)
 {
 	struct inode *inode = mapping->host;
 	struct gfs2_inode *ip = GFS2_I(inode);
-	unsigned long index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned long index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize, iblock, length, pos;
 	struct buffer_head *bh;
 	struct page *page;
@@ -945,7 +945,7 @@ static int gfs2_block_truncate_page(struct address_space *mapping, loff_t from)
 
 	blocksize = inode->i_sb->s_blocksize;
 	length = blocksize - (offset & (blocksize - 1));
-	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
@@ -989,7 +989,7 @@ static int gfs2_block_truncate_page(struct address_space *mapping, loff_t from)
 	mark_buffer_dirty(bh);
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index c9384f932975..208efc70ad49 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -354,8 +354,8 @@ static int gfs2_allocate_page_backing(struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct buffer_head bh;
-	unsigned long size = PAGE_CACHE_SIZE;
-	u64 lblock = page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	unsigned long size = PAGE_SIZE;
+	u64 lblock = page->index << (PAGE_SHIFT - inode->i_blkbits);
 
 	do {
 		bh.b_state = 0;
@@ -386,7 +386,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	struct gfs2_alloc_parms ap = { .aflags = 0, };
 	unsigned long last_index;
-	u64 pos = page->index << PAGE_CACHE_SHIFT;
+	u64 pos = page->index << PAGE_SHIFT;
 	unsigned int data_blocks, ind_blocks, rblocks;
 	struct gfs2_holder gh;
 	loff_t size;
@@ -401,7 +401,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (ret)
 		goto out;
 
-	gfs2_size_hint(vma->vm_file, pos, PAGE_CACHE_SIZE);
+	gfs2_size_hint(vma->vm_file, pos, PAGE_SIZE);
 
 	gfs2_holder_init(ip->i_gl, LM_ST_EXCLUSIVE, 0, &gh);
 	ret = gfs2_glock_nq(&gh);
@@ -411,7 +411,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	set_bit(GLF_DIRTY, &ip->i_gl->gl_flags);
 	set_bit(GIF_SW_PAGED, &ip->i_flags);
 
-	if (!gfs2_write_alloc_required(ip, pos, PAGE_CACHE_SIZE)) {
+	if (!gfs2_write_alloc_required(ip, pos, PAGE_SIZE)) {
 		lock_page(page);
 		if (!PageUptodate(page) || page->mapping != inode->i_mapping) {
 			ret = -EAGAIN;
@@ -424,7 +424,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (ret)
 		goto out_unlock;
 
-	gfs2_write_calc_reserv(ip, PAGE_CACHE_SIZE, &data_blocks, &ind_blocks);
+	gfs2_write_calc_reserv(ip, PAGE_SIZE, &data_blocks, &ind_blocks);
 	ap.target = data_blocks + ind_blocks;
 	ret = gfs2_quota_lock_check(ip, &ap);
 	if (ret)
@@ -447,7 +447,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	lock_page(page);
 	ret = -EINVAL;
 	size = i_size_read(inode);
-	last_index = (size - 1) >> PAGE_CACHE_SHIFT;
+	last_index = (size - 1) >> PAGE_SHIFT;
 	/* Check page index against inode size */
 	if (size == 0 || (page->index > last_index))
 		goto out_trans_end;
@@ -873,7 +873,7 @@ static long __gfs2_fallocate(struct file *file, int mode, loff_t offset, loff_t
 			rblocks += data_blocks ? data_blocks : 1;
 
 		error = gfs2_trans_begin(sdp, rblocks,
-					 PAGE_CACHE_SIZE/sdp->sd_sb.sb_bsize);
+					 PAGE_SIZE/sdp->sd_sb.sb_bsize);
 		if (error)
 			goto out_trans_fail;
 
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index e137d96f1b17..0448524c11bc 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -124,7 +124,7 @@ struct buffer_head *gfs2_getbuf(struct gfs2_glock *gl, u64 blkno, int create)
 	if (mapping == NULL)
 		mapping = &sdp->sd_aspace;
 
-	shift = PAGE_CACHE_SHIFT - sdp->sd_sb.sb_bsize_shift;
+	shift = PAGE_SHIFT - sdp->sd_sb.sb_bsize_shift;
 	index = blkno >> shift;             /* convert block to page */
 	bufnum = blkno - (index << shift);  /* block buf index within page */
 
@@ -154,7 +154,7 @@ struct buffer_head *gfs2_getbuf(struct gfs2_glock *gl, u64 blkno, int create)
 		map_bh(bh, sdp->sd_vfs, blkno);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return bh;
 }
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index a39891344259..ce7d69a2fdc0 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -701,7 +701,7 @@ static int gfs2_write_buf_to_page(struct gfs2_inode *ip, unsigned long index,
 	unsigned to_write = bytes, pg_off = off;
 	int done = 0;
 
-	blk = index << (PAGE_CACHE_SHIFT - sdp->sd_sb.sb_bsize_shift);
+	blk = index << (PAGE_SHIFT - sdp->sd_sb.sb_bsize_shift);
 	boff = off % bsize;
 
 	page = find_or_create_page(mapping, index, GFP_NOFS);
@@ -753,13 +753,13 @@ static int gfs2_write_buf_to_page(struct gfs2_inode *ip, unsigned long index,
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return 0;
 
 unlock_out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return -EIO;
 }
 
@@ -773,13 +773,13 @@ static int gfs2_write_disk_quota(struct gfs2_inode *ip, struct gfs2_quota *qp,
 
 	nbytes = sizeof(struct gfs2_quota);
 
-	pg_beg = loc >> PAGE_CACHE_SHIFT;
-	pg_off = loc % PAGE_CACHE_SIZE;
+	pg_beg = loc >> PAGE_SHIFT;
+	pg_off = loc % PAGE_SIZE;
 
 	/* If the quota straddles a page boundary, split the write in two */
-	if ((pg_off + nbytes) > PAGE_CACHE_SIZE) {
+	if ((pg_off + nbytes) > PAGE_SIZE) {
 		pg_oflow = 1;
-		overflow = (pg_off + nbytes) - PAGE_CACHE_SIZE;
+		overflow = (pg_off + nbytes) - PAGE_SIZE;
 	}
 
 	ptr = qp;
diff --git a/fs/gfs2/rgrp.c b/fs/gfs2/rgrp.c
index 07c0265aa195..99a0bdac8796 100644
--- a/fs/gfs2/rgrp.c
+++ b/fs/gfs2/rgrp.c
@@ -918,9 +918,8 @@ static int read_rindex_entry(struct gfs2_inode *ip)
 		goto fail;
 
 	rgd->rd_gl->gl_object = rgd;
-	rgd->rd_gl->gl_vm.start = (rgd->rd_addr * bsize) & PAGE_CACHE_MASK;
-	rgd->rd_gl->gl_vm.end = PAGE_CACHE_ALIGN((rgd->rd_addr +
-						  rgd->rd_length) * bsize) - 1;
+	rgd->rd_gl->gl_vm.start = (rgd->rd_addr * bsize) & PAGE_MASK;
+	rgd->rd_gl->gl_vm.end = PAGE_ALIGN((rgd->rd_addr + rgd->rd_length) * bsize) - 1;
 	rgd->rd_rgl = (struct gfs2_rgrp_lvb *)rgd->rd_gl->gl_lksb.sb_lvbptr;
 	rgd->rd_flags &= ~(GFS2_RDF_UPTODATE | GFS2_RDF_PREFERRED);
 	if (rgd->rd_data > sdp->sd_max_rg_data)
diff --git a/fs/hfs/bnode.c b/fs/hfs/bnode.c
index 221719eac5de..d77d844b668b 100644
--- a/fs/hfs/bnode.c
+++ b/fs/hfs/bnode.c
@@ -278,14 +278,14 @@ static struct hfs_bnode *__hfs_bnode_create(struct hfs_btree *tree, u32 cnid)
 
 	mapping = tree->inode->i_mapping;
 	off = (loff_t)cnid * tree->node_size;
-	block = off >> PAGE_CACHE_SHIFT;
-	node->page_offset = off & ~PAGE_CACHE_MASK;
+	block = off >> PAGE_SHIFT;
+	node->page_offset = off & ~PAGE_MASK;
 	for (i = 0; i < tree->pages_per_bnode; i++) {
 		page = read_mapping_page(mapping, block++, NULL);
 		if (IS_ERR(page))
 			goto fail;
 		if (PageError(page)) {
-			page_cache_release(page);
+			put_page(page);
 			goto fail;
 		}
 		node->page[i] = page;
@@ -401,7 +401,7 @@ void hfs_bnode_free(struct hfs_bnode *node)
 
 	for (i = 0; i < node->tree->pages_per_bnode; i++)
 		if (node->page[i])
-			page_cache_release(node->page[i]);
+			put_page(node->page[i]);
 	kfree(node);
 }
 
@@ -429,11 +429,11 @@ struct hfs_bnode *hfs_bnode_create(struct hfs_btree *tree, u32 num)
 
 	pagep = node->page;
 	memset(kmap(*pagep) + node->page_offset, 0,
-	       min((int)PAGE_CACHE_SIZE, (int)tree->node_size));
+	       min((int)PAGE_SIZE, (int)tree->node_size));
 	set_page_dirty(*pagep);
 	kunmap(*pagep);
 	for (i = 1; i < tree->pages_per_bnode; i++) {
-		memset(kmap(*++pagep), 0, PAGE_CACHE_SIZE);
+		memset(kmap(*++pagep), 0, PAGE_SIZE);
 		set_page_dirty(*pagep);
 		kunmap(*pagep);
 	}
diff --git a/fs/hfs/btree.c b/fs/hfs/btree.c
index 1ab19e660e69..37cdd955eceb 100644
--- a/fs/hfs/btree.c
+++ b/fs/hfs/btree.c
@@ -116,14 +116,14 @@ struct hfs_btree *hfs_btree_open(struct super_block *sb, u32 id, btree_keycmp ke
 	}
 
 	tree->node_size_shift = ffs(size) - 1;
-	tree->pages_per_bnode = (tree->node_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	tree->pages_per_bnode = (tree->node_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 	return tree;
 
 fail_page:
-	page_cache_release(page);
+	put_page(page);
 free_inode:
 	tree->inode->i_mapping->a_ops = &hfs_aops;
 	iput(tree->inode);
@@ -257,9 +257,9 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 	off = off16;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
+	pagep = node->page + (off >> PAGE_SHIFT);
 	data = kmap(*pagep);
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 	idx = 0;
 
 	for (;;) {
@@ -279,7 +279,7 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 					}
 				}
 			}
-			if (++off >= PAGE_CACHE_SIZE) {
+			if (++off >= PAGE_SIZE) {
 				kunmap(*pagep);
 				data = kmap(*++pagep);
 				off = 0;
@@ -302,9 +302,9 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 		len = hfs_brec_lenoff(node, 0, &off16);
 		off = off16;
 		off += node->page_offset;
-		pagep = node->page + (off >> PAGE_CACHE_SHIFT);
+		pagep = node->page + (off >> PAGE_SHIFT);
 		data = kmap(*pagep);
-		off &= ~PAGE_CACHE_MASK;
+		off &= ~PAGE_MASK;
 	}
 }
 
@@ -348,9 +348,9 @@ void hfs_bmap_free(struct hfs_bnode *node)
 		len = hfs_brec_lenoff(node, 0, &off);
 	}
 	off += node->page_offset + nidx / 8;
-	page = node->page[off >> PAGE_CACHE_SHIFT];
+	page = node->page[off >> PAGE_SHIFT];
 	data = kmap(page);
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 	m = 1 << (~nidx & 7);
 	byte = data[off];
 	if (!(byte & m)) {
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index 6686bf39a5b5..cb1e5faa2fb7 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -91,8 +91,8 @@ static int hfs_releasepage(struct page *page, gfp_t mask)
 	if (!tree)
 		return 0;
 
-	if (tree->node_size >= PAGE_CACHE_SIZE) {
-		nidx = page->index >> (tree->node_size_shift - PAGE_CACHE_SHIFT);
+	if (tree->node_size >= PAGE_SIZE) {
+		nidx = page->index >> (tree->node_size_shift - PAGE_SHIFT);
 		spin_lock(&tree->hash_lock);
 		node = hfs_bnode_findhash(tree, nidx);
 		if (!node)
@@ -105,8 +105,8 @@ static int hfs_releasepage(struct page *page, gfp_t mask)
 		}
 		spin_unlock(&tree->hash_lock);
 	} else {
-		nidx = page->index << (PAGE_CACHE_SHIFT - tree->node_size_shift);
-		i = 1 << (PAGE_CACHE_SHIFT - tree->node_size_shift);
+		nidx = page->index << (PAGE_SHIFT - tree->node_size_shift);
+		i = 1 << (PAGE_SHIFT - tree->node_size_shift);
 		spin_lock(&tree->hash_lock);
 		do {
 			node = hfs_bnode_findhash(tree, nidx++);
diff --git a/fs/hfsplus/bitmap.c b/fs/hfsplus/bitmap.c
index d2954451519e..c0ae274c0a22 100644
--- a/fs/hfsplus/bitmap.c
+++ b/fs/hfsplus/bitmap.c
@@ -13,7 +13,7 @@
 #include "hfsplus_fs.h"
 #include "hfsplus_raw.h"
 
-#define PAGE_CACHE_BITS	(PAGE_CACHE_SIZE * 8)
+#define PAGE_CACHE_BITS	(PAGE_SIZE * 8)
 
 int hfsplus_block_allocate(struct super_block *sb, u32 size,
 		u32 offset, u32 *max)
diff --git a/fs/hfsplus/bnode.c b/fs/hfsplus/bnode.c
index 63924662aaf3..ce014ceb89ef 100644
--- a/fs/hfsplus/bnode.c
+++ b/fs/hfsplus/bnode.c
@@ -24,16 +24,16 @@ void hfs_bnode_read(struct hfs_bnode *node, void *buf, int off, int len)
 	int l;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
-	off &= ~PAGE_CACHE_MASK;
+	pagep = node->page + (off >> PAGE_SHIFT);
+	off &= ~PAGE_MASK;
 
-	l = min_t(int, len, PAGE_CACHE_SIZE - off);
+	l = min_t(int, len, PAGE_SIZE - off);
 	memcpy(buf, kmap(*pagep) + off, l);
 	kunmap(*pagep);
 
 	while ((len -= l) != 0) {
 		buf += l;
-		l = min_t(int, len, PAGE_CACHE_SIZE);
+		l = min_t(int, len, PAGE_SIZE);
 		memcpy(buf, kmap(*++pagep), l);
 		kunmap(*pagep);
 	}
@@ -77,17 +77,17 @@ void hfs_bnode_write(struct hfs_bnode *node, void *buf, int off, int len)
 	int l;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
-	off &= ~PAGE_CACHE_MASK;
+	pagep = node->page + (off >> PAGE_SHIFT);
+	off &= ~PAGE_MASK;
 
-	l = min_t(int, len, PAGE_CACHE_SIZE - off);
+	l = min_t(int, len, PAGE_SIZE - off);
 	memcpy(kmap(*pagep) + off, buf, l);
 	set_page_dirty(*pagep);
 	kunmap(*pagep);
 
 	while ((len -= l) != 0) {
 		buf += l;
-		l = min_t(int, len, PAGE_CACHE_SIZE);
+		l = min_t(int, len, PAGE_SIZE);
 		memcpy(kmap(*++pagep), buf, l);
 		set_page_dirty(*pagep);
 		kunmap(*pagep);
@@ -107,16 +107,16 @@ void hfs_bnode_clear(struct hfs_bnode *node, int off, int len)
 	int l;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
-	off &= ~PAGE_CACHE_MASK;
+	pagep = node->page + (off >> PAGE_SHIFT);
+	off &= ~PAGE_MASK;
 
-	l = min_t(int, len, PAGE_CACHE_SIZE - off);
+	l = min_t(int, len, PAGE_SIZE - off);
 	memset(kmap(*pagep) + off, 0, l);
 	set_page_dirty(*pagep);
 	kunmap(*pagep);
 
 	while ((len -= l) != 0) {
-		l = min_t(int, len, PAGE_CACHE_SIZE);
+		l = min_t(int, len, PAGE_SIZE);
 		memset(kmap(*++pagep), 0, l);
 		set_page_dirty(*pagep);
 		kunmap(*pagep);
@@ -136,20 +136,20 @@ void hfs_bnode_copy(struct hfs_bnode *dst_node, int dst,
 	tree = src_node->tree;
 	src += src_node->page_offset;
 	dst += dst_node->page_offset;
-	src_page = src_node->page + (src >> PAGE_CACHE_SHIFT);
-	src &= ~PAGE_CACHE_MASK;
-	dst_page = dst_node->page + (dst >> PAGE_CACHE_SHIFT);
-	dst &= ~PAGE_CACHE_MASK;
+	src_page = src_node->page + (src >> PAGE_SHIFT);
+	src &= ~PAGE_MASK;
+	dst_page = dst_node->page + (dst >> PAGE_SHIFT);
+	dst &= ~PAGE_MASK;
 
 	if (src == dst) {
-		l = min_t(int, len, PAGE_CACHE_SIZE - src);
+		l = min_t(int, len, PAGE_SIZE - src);
 		memcpy(kmap(*dst_page) + src, kmap(*src_page) + src, l);
 		kunmap(*src_page);
 		set_page_dirty(*dst_page);
 		kunmap(*dst_page);
 
 		while ((len -= l) != 0) {
-			l = min_t(int, len, PAGE_CACHE_SIZE);
+			l = min_t(int, len, PAGE_SIZE);
 			memcpy(kmap(*++dst_page), kmap(*++src_page), l);
 			kunmap(*src_page);
 			set_page_dirty(*dst_page);
@@ -161,12 +161,12 @@ void hfs_bnode_copy(struct hfs_bnode *dst_node, int dst,
 		do {
 			src_ptr = kmap(*src_page) + src;
 			dst_ptr = kmap(*dst_page) + dst;
-			if (PAGE_CACHE_SIZE - src < PAGE_CACHE_SIZE - dst) {
-				l = PAGE_CACHE_SIZE - src;
+			if (PAGE_SIZE - src < PAGE_SIZE - dst) {
+				l = PAGE_SIZE - src;
 				src = 0;
 				dst += l;
 			} else {
-				l = PAGE_CACHE_SIZE - dst;
+				l = PAGE_SIZE - dst;
 				src += l;
 				dst = 0;
 			}
@@ -195,11 +195,11 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 	dst += node->page_offset;
 	if (dst > src) {
 		src += len - 1;
-		src_page = node->page + (src >> PAGE_CACHE_SHIFT);
-		src = (src & ~PAGE_CACHE_MASK) + 1;
+		src_page = node->page + (src >> PAGE_SHIFT);
+		src = (src & ~PAGE_MASK) + 1;
 		dst += len - 1;
-		dst_page = node->page + (dst >> PAGE_CACHE_SHIFT);
-		dst = (dst & ~PAGE_CACHE_MASK) + 1;
+		dst_page = node->page + (dst >> PAGE_SHIFT);
+		dst = (dst & ~PAGE_MASK) + 1;
 
 		if (src == dst) {
 			while (src < len) {
@@ -208,7 +208,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 				set_page_dirty(*dst_page);
 				kunmap(*dst_page);
 				len -= src;
-				src = PAGE_CACHE_SIZE;
+				src = PAGE_SIZE;
 				src_page--;
 				dst_page--;
 			}
@@ -226,32 +226,32 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 				dst_ptr = kmap(*dst_page) + dst;
 				if (src < dst) {
 					l = src;
-					src = PAGE_CACHE_SIZE;
+					src = PAGE_SIZE;
 					dst -= l;
 				} else {
 					l = dst;
 					src -= l;
-					dst = PAGE_CACHE_SIZE;
+					dst = PAGE_SIZE;
 				}
 				l = min(len, l);
 				memmove(dst_ptr - l, src_ptr - l, l);
 				kunmap(*src_page);
 				set_page_dirty(*dst_page);
 				kunmap(*dst_page);
-				if (dst == PAGE_CACHE_SIZE)
+				if (dst == PAGE_SIZE)
 					dst_page--;
 				else
 					src_page--;
 			} while ((len -= l));
 		}
 	} else {
-		src_page = node->page + (src >> PAGE_CACHE_SHIFT);
-		src &= ~PAGE_CACHE_MASK;
-		dst_page = node->page + (dst >> PAGE_CACHE_SHIFT);
-		dst &= ~PAGE_CACHE_MASK;
+		src_page = node->page + (src >> PAGE_SHIFT);
+		src &= ~PAGE_MASK;
+		dst_page = node->page + (dst >> PAGE_SHIFT);
+		dst &= ~PAGE_MASK;
 
 		if (src == dst) {
-			l = min_t(int, len, PAGE_CACHE_SIZE - src);
+			l = min_t(int, len, PAGE_SIZE - src);
 			memmove(kmap(*dst_page) + src,
 				kmap(*src_page) + src, l);
 			kunmap(*src_page);
@@ -259,7 +259,7 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 			kunmap(*dst_page);
 
 			while ((len -= l) != 0) {
-				l = min_t(int, len, PAGE_CACHE_SIZE);
+				l = min_t(int, len, PAGE_SIZE);
 				memmove(kmap(*++dst_page),
 					kmap(*++src_page), l);
 				kunmap(*src_page);
@@ -272,13 +272,13 @@ void hfs_bnode_move(struct hfs_bnode *node, int dst, int src, int len)
 			do {
 				src_ptr = kmap(*src_page) + src;
 				dst_ptr = kmap(*dst_page) + dst;
-				if (PAGE_CACHE_SIZE - src <
-						PAGE_CACHE_SIZE - dst) {
-					l = PAGE_CACHE_SIZE - src;
+				if (PAGE_SIZE - src <
+						PAGE_SIZE - dst) {
+					l = PAGE_SIZE - src;
 					src = 0;
 					dst += l;
 				} else {
-					l = PAGE_CACHE_SIZE - dst;
+					l = PAGE_SIZE - dst;
 					src += l;
 					dst = 0;
 				}
@@ -444,14 +444,14 @@ static struct hfs_bnode *__hfs_bnode_create(struct hfs_btree *tree, u32 cnid)
 
 	mapping = tree->inode->i_mapping;
 	off = (loff_t)cnid << tree->node_size_shift;
-	block = off >> PAGE_CACHE_SHIFT;
-	node->page_offset = off & ~PAGE_CACHE_MASK;
+	block = off >> PAGE_SHIFT;
+	node->page_offset = off & ~PAGE_MASK;
 	for (i = 0; i < tree->pages_per_bnode; block++, i++) {
 		page = read_mapping_page(mapping, block, NULL);
 		if (IS_ERR(page))
 			goto fail;
 		if (PageError(page)) {
-			page_cache_release(page);
+			put_page(page);
 			goto fail;
 		}
 		node->page[i] = page;
@@ -569,7 +569,7 @@ void hfs_bnode_free(struct hfs_bnode *node)
 
 	for (i = 0; i < node->tree->pages_per_bnode; i++)
 		if (node->page[i])
-			page_cache_release(node->page[i]);
+			put_page(node->page[i]);
 	kfree(node);
 }
 
@@ -597,11 +597,11 @@ struct hfs_bnode *hfs_bnode_create(struct hfs_btree *tree, u32 num)
 
 	pagep = node->page;
 	memset(kmap(*pagep) + node->page_offset, 0,
-	       min_t(int, PAGE_CACHE_SIZE, tree->node_size));
+	       min_t(int, PAGE_SIZE, tree->node_size));
 	set_page_dirty(*pagep);
 	kunmap(*pagep);
 	for (i = 1; i < tree->pages_per_bnode; i++) {
-		memset(kmap(*++pagep), 0, PAGE_CACHE_SIZE);
+		memset(kmap(*++pagep), 0, PAGE_SIZE);
 		set_page_dirty(*pagep);
 		kunmap(*pagep);
 	}
diff --git a/fs/hfsplus/btree.c b/fs/hfsplus/btree.c
index 3345c7553edc..d9d1a36ba826 100644
--- a/fs/hfsplus/btree.c
+++ b/fs/hfsplus/btree.c
@@ -236,15 +236,15 @@ struct hfs_btree *hfs_btree_open(struct super_block *sb, u32 id)
 	tree->node_size_shift = ffs(size) - 1;
 
 	tree->pages_per_bnode =
-		(tree->node_size + PAGE_CACHE_SIZE - 1) >>
-		PAGE_CACHE_SHIFT;
+		(tree->node_size + PAGE_SIZE - 1) >>
+		PAGE_SHIFT;
 
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 	return tree;
 
  fail_page:
-	page_cache_release(page);
+	put_page(page);
  free_inode:
 	tree->inode->i_mapping->a_ops = &hfsplus_aops;
 	iput(tree->inode);
@@ -380,9 +380,9 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 	off = off16;
 
 	off += node->page_offset;
-	pagep = node->page + (off >> PAGE_CACHE_SHIFT);
+	pagep = node->page + (off >> PAGE_SHIFT);
 	data = kmap(*pagep);
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 	idx = 0;
 
 	for (;;) {
@@ -403,7 +403,7 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 					}
 				}
 			}
-			if (++off >= PAGE_CACHE_SIZE) {
+			if (++off >= PAGE_SIZE) {
 				kunmap(*pagep);
 				data = kmap(*++pagep);
 				off = 0;
@@ -426,9 +426,9 @@ struct hfs_bnode *hfs_bmap_alloc(struct hfs_btree *tree)
 		len = hfs_brec_lenoff(node, 0, &off16);
 		off = off16;
 		off += node->page_offset;
-		pagep = node->page + (off >> PAGE_CACHE_SHIFT);
+		pagep = node->page + (off >> PAGE_SHIFT);
 		data = kmap(*pagep);
-		off &= ~PAGE_CACHE_MASK;
+		off &= ~PAGE_MASK;
 	}
 }
 
@@ -475,9 +475,9 @@ void hfs_bmap_free(struct hfs_bnode *node)
 		len = hfs_brec_lenoff(node, 0, &off);
 	}
 	off += node->page_offset + nidx / 8;
-	page = node->page[off >> PAGE_CACHE_SHIFT];
+	page = node->page[off >> PAGE_SHIFT];
 	data = kmap(page);
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 	m = 1 << (~nidx & 7);
 	byte = data[off];
 	if (!(byte & m)) {
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index 1a6394cdb54e..b28f39865c3a 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -87,9 +87,9 @@ static int hfsplus_releasepage(struct page *page, gfp_t mask)
 	}
 	if (!tree)
 		return 0;
-	if (tree->node_size >= PAGE_CACHE_SIZE) {
+	if (tree->node_size >= PAGE_SIZE) {
 		nidx = page->index >>
-			(tree->node_size_shift - PAGE_CACHE_SHIFT);
+			(tree->node_size_shift - PAGE_SHIFT);
 		spin_lock(&tree->hash_lock);
 		node = hfs_bnode_findhash(tree, nidx);
 		if (!node)
@@ -103,8 +103,8 @@ static int hfsplus_releasepage(struct page *page, gfp_t mask)
 		spin_unlock(&tree->hash_lock);
 	} else {
 		nidx = page->index <<
-			(PAGE_CACHE_SHIFT - tree->node_size_shift);
-		i = 1 << (PAGE_CACHE_SHIFT - tree->node_size_shift);
+			(PAGE_SHIFT - tree->node_size_shift);
+		i = 1 << (PAGE_SHIFT - tree->node_size_shift);
 		spin_lock(&tree->hash_lock);
 		do {
 			node = hfs_bnode_findhash(tree, nidx++);
diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
index 5d54490a136d..c35911362ff9 100644
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -438,7 +438,7 @@ static int hfsplus_fill_super(struct super_block *sb, void *data, int silent)
 	err = -EFBIG;
 	last_fs_block = sbi->total_blocks - 1;
 	last_fs_page = (last_fs_block << sbi->alloc_blksz_shift) >>
-			PAGE_CACHE_SHIFT;
+			PAGE_SHIFT;
 
 	if ((last_fs_block > (sector_t)(~0ULL) >> (sbi->alloc_blksz_shift - 9)) ||
 	    (last_fs_page > (pgoff_t)(~0ULL))) {
diff --git a/fs/hfsplus/xattr.c b/fs/hfsplus/xattr.c
index ab01530b4930..70e445ff0cff 100644
--- a/fs/hfsplus/xattr.c
+++ b/fs/hfsplus/xattr.c
@@ -220,7 +220,7 @@ check_attr_tree_state_again:
 
 	index = 0;
 	written = 0;
-	for (; written < node_size; index++, written += PAGE_CACHE_SIZE) {
+	for (; written < node_size; index++, written += PAGE_SIZE) {
 		void *kaddr;
 
 		page = read_mapping_page(mapping, index, NULL);
@@ -231,11 +231,11 @@ check_attr_tree_state_again:
 
 		kaddr = kmap_atomic(page);
 		memcpy(kaddr, buf + written,
-			min_t(size_t, PAGE_CACHE_SIZE, node_size - written));
+			min_t(size_t, PAGE_SIZE, node_size - written));
 		kunmap_atomic(kaddr);
 
 		set_page_dirty(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	hfsplus_mark_inode_dirty(attr_file, HFSPLUS_I_ATTR_DIRTY);
diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index d1abbee281d1..7016653f3e41 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -410,12 +410,12 @@ static int hostfs_writepage(struct page *page, struct writeback_control *wbc)
 	struct inode *inode = mapping->host;
 	char *buffer;
 	loff_t base = page_offset(page);
-	int count = PAGE_CACHE_SIZE;
-	int end_index = inode->i_size >> PAGE_CACHE_SHIFT;
+	int count = PAGE_SIZE;
+	int end_index = inode->i_size >> PAGE_SHIFT;
 	int err;
 
 	if (page->index >= end_index)
-		count = inode->i_size & (PAGE_CACHE_SIZE-1);
+		count = inode->i_size & (PAGE_SIZE-1);
 
 	buffer = kmap(page);
 
@@ -447,7 +447,7 @@ static int hostfs_readpage(struct file *file, struct page *page)
 
 	buffer = kmap(page);
 	bytes_read = read_file(FILE_HOSTFS_I(file)->fd, &start, buffer,
-			PAGE_CACHE_SIZE);
+			PAGE_SIZE);
 	if (bytes_read < 0) {
 		ClearPageUptodate(page);
 		SetPageError(page);
@@ -455,7 +455,7 @@ static int hostfs_readpage(struct file *file, struct page *page)
 		goto out;
 	}
 
-	memset(buffer + bytes_read, 0, PAGE_CACHE_SIZE - bytes_read);
+	memset(buffer + bytes_read, 0, PAGE_SIZE - bytes_read);
 
 	ClearPageError(page);
 	SetPageUptodate(page);
@@ -471,7 +471,7 @@ static int hostfs_write_begin(struct file *file, struct address_space *mapping,
 			      loff_t pos, unsigned len, unsigned flags,
 			      struct page **pagep, void **fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 
 	*pagep = grab_cache_page_write_begin(mapping, index, flags);
 	if (!*pagep)
@@ -485,14 +485,14 @@ static int hostfs_write_end(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	void *buffer;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	int err;
 
 	buffer = kmap(page);
 	err = write_file(FILE_HOSTFS_I(file)->fd, &pos, buffer + from, copied);
 	kunmap(page);
 
-	if (!PageUptodate(page) && err == PAGE_CACHE_SIZE)
+	if (!PageUptodate(page) && err == PAGE_SIZE)
 		SetPageUptodate(page);
 
 	/*
@@ -502,7 +502,7 @@ static int hostfs_write_end(struct file *file, struct address_space *mapping,
 	if (err > 0 && (pos > inode->i_size))
 		inode->i_size = pos;
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return err;
 }
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index e1f465a389d5..afb7c7f05de5 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -213,12 +213,12 @@ hugetlbfs_read_actor(struct page *page, unsigned long offset,
 	int i, chunksize;
 
 	/* Find which 4k chunk and offset with in that chunk */
-	i = offset >> PAGE_CACHE_SHIFT;
-	offset = offset & ~PAGE_CACHE_MASK;
+	i = offset >> PAGE_SHIFT;
+	offset = offset & ~PAGE_MASK;
 
 	while (size) {
 		size_t n;
-		chunksize = PAGE_CACHE_SIZE;
+		chunksize = PAGE_SIZE;
 		if (offset)
 			chunksize -= offset;
 		if (chunksize > size)
@@ -285,7 +285,7 @@ static ssize_t hugetlbfs_read_iter(struct kiocb *iocb, struct iov_iter *to)
 			 * We have the page, copy it to user space buffer.
 			 */
 			copied = hugetlbfs_read_actor(page, offset, to, nr);
-			page_cache_release(page);
+			put_page(page);
 		}
 		offset += copied;
 		retval += copied;
diff --git a/fs/isofs/compress.c b/fs/isofs/compress.c
index f311bf084015..2e4e834d1a98 100644
--- a/fs/isofs/compress.c
+++ b/fs/isofs/compress.c
@@ -26,7 +26,7 @@
 #include "zisofs.h"
 
 /* This should probably be global. */
-static char zisofs_sink_page[PAGE_CACHE_SIZE];
+static char zisofs_sink_page[PAGE_SIZE];
 
 /*
  * This contains the zlib memory allocation and the mutex for the
@@ -70,11 +70,11 @@ static loff_t zisofs_uncompress_block(struct inode *inode, loff_t block_start,
 		for ( i = 0 ; i < pcount ; i++ ) {
 			if (!pages[i])
 				continue;
-			memset(page_address(pages[i]), 0, PAGE_CACHE_SIZE);
+			memset(page_address(pages[i]), 0, PAGE_SIZE);
 			flush_dcache_page(pages[i]);
 			SetPageUptodate(pages[i]);
 		}
-		return ((loff_t)pcount) << PAGE_CACHE_SHIFT;
+		return ((loff_t)pcount) << PAGE_SHIFT;
 	}
 
 	/* Because zlib is not thread-safe, do all the I/O at the top. */
@@ -121,11 +121,11 @@ static loff_t zisofs_uncompress_block(struct inode *inode, loff_t block_start,
 			if (pages[curpage]) {
 				stream.next_out = page_address(pages[curpage])
 						+ poffset;
-				stream.avail_out = PAGE_CACHE_SIZE - poffset;
+				stream.avail_out = PAGE_SIZE - poffset;
 				poffset = 0;
 			} else {
 				stream.next_out = (void *)&zisofs_sink_page;
-				stream.avail_out = PAGE_CACHE_SIZE;
+				stream.avail_out = PAGE_SIZE;
 			}
 		}
 		if (!stream.avail_in) {
@@ -220,14 +220,14 @@ static int zisofs_fill_pages(struct inode *inode, int full_page, int pcount,
 	 * pages with the data we have anyway...
 	 */
 	start_off = page_offset(pages[full_page]);
-	end_off = min_t(loff_t, start_off + PAGE_CACHE_SIZE, inode->i_size);
+	end_off = min_t(loff_t, start_off + PAGE_SIZE, inode->i_size);
 
 	cstart_block = start_off >> zisofs_block_shift;
 	cend_block = (end_off + (1 << zisofs_block_shift) - 1)
 			>> zisofs_block_shift;
 
-	WARN_ON(start_off - (full_page << PAGE_CACHE_SHIFT) !=
-		((cstart_block << zisofs_block_shift) & PAGE_CACHE_MASK));
+	WARN_ON(start_off - (full_page << PAGE_SHIFT) !=
+		((cstart_block << zisofs_block_shift) & PAGE_MASK));
 
 	/* Find the pointer to this specific chunk */
 	/* Note: we're not using isonum_731() here because the data is known aligned */
@@ -260,10 +260,10 @@ static int zisofs_fill_pages(struct inode *inode, int full_page, int pcount,
 		ret = zisofs_uncompress_block(inode, block_start, block_end,
 					      pcount, pages, poffset, &err);
 		poffset += ret;
-		pages += poffset >> PAGE_CACHE_SHIFT;
-		pcount -= poffset >> PAGE_CACHE_SHIFT;
-		full_page -= poffset >> PAGE_CACHE_SHIFT;
-		poffset &= ~PAGE_CACHE_MASK;
+		pages += poffset >> PAGE_SHIFT;
+		pcount -= poffset >> PAGE_SHIFT;
+		full_page -= poffset >> PAGE_SHIFT;
+		poffset &= ~PAGE_MASK;
 
 		if (err) {
 			brelse(bh);
@@ -282,7 +282,7 @@ static int zisofs_fill_pages(struct inode *inode, int full_page, int pcount,
 
 	if (poffset && *pages) {
 		memset(page_address(*pages) + poffset, 0,
-		       PAGE_CACHE_SIZE - poffset);
+		       PAGE_SIZE - poffset);
 		flush_dcache_page(*pages);
 		SetPageUptodate(*pages);
 	}
@@ -302,12 +302,12 @@ static int zisofs_readpage(struct file *file, struct page *page)
 	int i, pcount, full_page;
 	unsigned int zisofs_block_shift = ISOFS_I(inode)->i_format_parm[1];
 	unsigned int zisofs_pages_per_cblock =
-		PAGE_CACHE_SHIFT <= zisofs_block_shift ?
-		(1 << (zisofs_block_shift - PAGE_CACHE_SHIFT)) : 0;
+		PAGE_SHIFT <= zisofs_block_shift ?
+		(1 << (zisofs_block_shift - PAGE_SHIFT)) : 0;
 	struct page *pages[max_t(unsigned, zisofs_pages_per_cblock, 1)];
 	pgoff_t index = page->index, end_index;
 
-	end_index = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	end_index = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	/*
 	 * If this page is wholly outside i_size we just return zero;
 	 * do_generic_file_read() will handle this for us
@@ -318,7 +318,7 @@ static int zisofs_readpage(struct file *file, struct page *page)
 		return 0;
 	}
 
-	if (PAGE_CACHE_SHIFT <= zisofs_block_shift) {
+	if (PAGE_SHIFT <= zisofs_block_shift) {
 		/* We have already been given one page, this is the one
 		   we must do. */
 		full_page = index & (zisofs_pages_per_cblock - 1);
@@ -351,7 +351,7 @@ static int zisofs_readpage(struct file *file, struct page *page)
 			kunmap(pages[i]);
 			unlock_page(pages[i]);
 			if (i != full_page)
-				page_cache_release(pages[i]);
+				put_page(pages[i]);
 		}
 	}			
 
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index bcd2d41b318a..131dedc920d8 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -1021,7 +1021,7 @@ int isofs_get_blocks(struct inode *inode, sector_t iblock,
 		 * the page with useless information without generating any
 		 * I/O errors.
 		 */
-		if (b_off > ((inode->i_size + PAGE_CACHE_SIZE - 1) >> ISOFS_BUFFER_BITS(inode))) {
+		if (b_off > ((inode->i_size + PAGE_SIZE - 1) >> ISOFS_BUFFER_BITS(inode))) {
 			printk(KERN_DEBUG "%s: block >= EOF (%lu, %llu)\n",
 				__func__, b_off,
 				(unsigned long long)inode->i_size);
diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index 517f2de784cf..2ad98d6e19f4 100644
--- a/fs/jbd2/commit.c
+++ b/fs/jbd2/commit.c
@@ -81,11 +81,11 @@ static void release_buffer_page(struct buffer_head *bh)
 	if (!trylock_page(page))
 		goto nope;
 
-	page_cache_get(page);
+	get_page(page);
 	__brelse(bh);
 	try_to_free_buffers(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return;
 
 nope:
diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index de73a9516a54..435f0b26ac20 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2221,7 +2221,7 @@ void jbd2_journal_ack_err(journal_t *journal)
 
 int jbd2_journal_blocks_per_page(struct inode *inode)
 {
-	return 1 << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	return 1 << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 }
 
 /*
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 01e4652d88f6..67c103867bf8 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -2263,7 +2263,7 @@ int jbd2_journal_invalidatepage(journal_t *journal,
 	struct buffer_head *head, *bh, *next;
 	unsigned int stop = offset + length;
 	unsigned int curr_off = 0;
-	int partial_page = (offset || length < PAGE_CACHE_SIZE);
+	int partial_page = (offset || length < PAGE_SIZE);
 	int may_free = 1;
 	int ret = 0;
 
@@ -2272,7 +2272,7 @@ int jbd2_journal_invalidatepage(journal_t *journal,
 	if (!page_has_buffers(page))
 		return 0;
 
-	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+	BUG_ON(stop > PAGE_SIZE || stop < length);
 
 	/* We will potentially be playing with lists other than just the
 	 * data lists (especially for journaled data mode), so be
diff --git a/fs/jffs2/debug.c b/fs/jffs2/debug.c
index 1090eb64b90d..9d26b1b9fc01 100644
--- a/fs/jffs2/debug.c
+++ b/fs/jffs2/debug.c
@@ -95,15 +95,15 @@ __jffs2_dbg_fragtree_paranoia_check_nolock(struct jffs2_inode_info *f)
 			   rather than mucking around with actually reading the node
 			   and checking the compression type, which is the real way
 			   to tell a hole node. */
-			if (frag->ofs & (PAGE_CACHE_SIZE-1) && frag_prev(frag)
-					&& frag_prev(frag)->size < PAGE_CACHE_SIZE && frag_prev(frag)->node) {
+			if (frag->ofs & (PAGE_SIZE-1) && frag_prev(frag)
+					&& frag_prev(frag)->size < PAGE_SIZE && frag_prev(frag)->node) {
 				JFFS2_ERROR("REF_PRISTINE node at 0x%08x had a previous non-hole frag in the same page. Tell dwmw2.\n",
 					ref_offset(fn->raw));
 				bitched = 1;
 			}
 
-			if ((frag->ofs+frag->size) & (PAGE_CACHE_SIZE-1) && frag_next(frag)
-					&& frag_next(frag)->size < PAGE_CACHE_SIZE && frag_next(frag)->node) {
+			if ((frag->ofs+frag->size) & (PAGE_SIZE-1) && frag_next(frag)
+					&& frag_next(frag)->size < PAGE_SIZE && frag_next(frag)->node) {
 				JFFS2_ERROR("REF_PRISTINE node at 0x%08x (%08x-%08x) had a following non-hole frag in the same page. Tell dwmw2.\n",
 				       ref_offset(fn->raw), frag->ofs, frag->ofs+frag->size);
 				bitched = 1;
diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index cad86bac3453..0e62dec3effc 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -87,14 +87,15 @@ static int jffs2_do_readpage_nolock (struct inode *inode, struct page *pg)
 	int ret;
 
 	jffs2_dbg(2, "%s(): ino #%lu, page at offset 0x%lx\n",
-		  __func__, inode->i_ino, pg->index << PAGE_CACHE_SHIFT);
+		  __func__, inode->i_ino, pg->index << PAGE_SHIFT);
 
 	BUG_ON(!PageLocked(pg));
 
 	pg_buf = kmap(pg);
 	/* FIXME: Can kmap fail? */
 
-	ret = jffs2_read_inode_range(c, f, pg_buf, pg->index << PAGE_CACHE_SHIFT, PAGE_CACHE_SIZE);
+	ret = jffs2_read_inode_range(c, f, pg_buf, pg->index << PAGE_SHIFT,
+				     PAGE_SIZE);
 
 	if (ret) {
 		ClearPageUptodate(pg);
@@ -137,8 +138,8 @@ static int jffs2_write_begin(struct file *filp, struct address_space *mapping,
 	struct page *pg;
 	struct inode *inode = mapping->host;
 	struct jffs2_inode_info *f = JFFS2_INODE_INFO(inode);
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	uint32_t pageofs = index << PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
+	uint32_t pageofs = index << PAGE_SHIFT;
 	int ret = 0;
 
 	pg = grab_cache_page_write_begin(mapping, index, flags);
@@ -230,7 +231,7 @@ static int jffs2_write_begin(struct file *filp, struct address_space *mapping,
 
 out_page:
 	unlock_page(pg);
-	page_cache_release(pg);
+	put_page(pg);
 	return ret;
 }
 
@@ -245,14 +246,14 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 	struct jffs2_inode_info *f = JFFS2_INODE_INFO(inode);
 	struct jffs2_sb_info *c = JFFS2_SB_INFO(inode->i_sb);
 	struct jffs2_raw_inode *ri;
-	unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned start = pos & (PAGE_SIZE - 1);
 	unsigned end = start + copied;
 	unsigned aligned_start = start & ~3;
 	int ret = 0;
 	uint32_t writtenlen = 0;
 
 	jffs2_dbg(1, "%s(): ino #%lu, page at 0x%lx, range %d-%d, flags %lx\n",
-		  __func__, inode->i_ino, pg->index << PAGE_CACHE_SHIFT,
+		  __func__, inode->i_ino, pg->index << PAGE_SHIFT,
 		  start, end, pg->flags);
 
 	/* We need to avoid deadlock with page_cache_read() in
@@ -261,7 +262,7 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 	   to re-lock it. */
 	BUG_ON(!PageUptodate(pg));
 
-	if (end == PAGE_CACHE_SIZE) {
+	if (end == PAGE_SIZE) {
 		/* When writing out the end of a page, write out the
 		   _whole_ page. This helps to reduce the number of
 		   nodes in files which have many short writes, like
@@ -275,7 +276,7 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 		jffs2_dbg(1, "%s(): Allocation of raw inode failed\n",
 			  __func__);
 		unlock_page(pg);
-		page_cache_release(pg);
+		put_page(pg);
 		return -ENOMEM;
 	}
 
@@ -292,7 +293,7 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 	kmap(pg);
 
 	ret = jffs2_write_inode_range(c, f, ri, page_address(pg) + aligned_start,
-				      (pg->index << PAGE_CACHE_SHIFT) + aligned_start,
+				      (pg->index << PAGE_SHIFT) + aligned_start,
 				      end - aligned_start, &writtenlen);
 
 	kunmap(pg);
@@ -329,6 +330,6 @@ static int jffs2_write_end(struct file *filp, struct address_space *mapping,
 	jffs2_dbg(1, "%s() returning %d\n",
 		  __func__, writtenlen > 0 ? writtenlen : ret);
 	unlock_page(pg);
-	page_cache_release(pg);
+	put_page(pg);
 	return writtenlen > 0 ? writtenlen : ret;
 }
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index bead25ae8fe4..ae2ebb26b446 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -586,8 +586,8 @@ int jffs2_do_fill_super(struct super_block *sb, void *data, int silent)
 		goto out_root;
 
 	sb->s_maxbytes = 0xFFFFFFFF;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = JFFS2_SUPER_MAGIC;
 	if (!(sb->s_flags & MS_RDONLY))
 		jffs2_start_garbage_collect_thread(c);
@@ -685,7 +685,7 @@ unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
 	struct inode *inode = OFNI_EDONI_2SFFJ(f);
 	struct page *pg;
 
-	pg = read_cache_page(inode->i_mapping, offset >> PAGE_CACHE_SHIFT,
+	pg = read_cache_page(inode->i_mapping, offset >> PAGE_SHIFT,
 			     (void *)jffs2_do_readpage_unlock, inode);
 	if (IS_ERR(pg))
 		return (void *)pg;
@@ -701,7 +701,7 @@ void jffs2_gc_release_page(struct jffs2_sb_info *c,
 	struct page *pg = (void *)*priv;
 
 	kunmap(pg);
-	page_cache_release(pg);
+	put_page(pg);
 }
 
 static int jffs2_flash_setup(struct jffs2_sb_info *c) {
diff --git a/fs/jffs2/gc.c b/fs/jffs2/gc.c
index 95d5880a63ee..7c82e6159826 100644
--- a/fs/jffs2/gc.c
+++ b/fs/jffs2/gc.c
@@ -532,7 +532,7 @@ static int jffs2_garbage_collect_live(struct jffs2_sb_info *c,  struct jffs2_era
 				goto upnout;
 		}
 		/* We found a datanode. Do the GC */
-		if((start >> PAGE_CACHE_SHIFT) < ((end-1) >> PAGE_CACHE_SHIFT)) {
+		if((start >> PAGE_SHIFT) < ((end-1) >> PAGE_SHIFT)) {
 			/* It crosses a page boundary. Therefore, it must be a hole. */
 			ret = jffs2_garbage_collect_hole(c, jeb, f, fn, start, end);
 		} else {
@@ -1172,8 +1172,8 @@ static int jffs2_garbage_collect_dnode(struct jffs2_sb_info *c, struct jffs2_era
 		struct jffs2_node_frag *frag;
 		uint32_t min, max;
 
-		min = start & ~(PAGE_CACHE_SIZE-1);
-		max = min + PAGE_CACHE_SIZE;
+		min = start & ~(PAGE_SIZE-1);
+		max = min + PAGE_SIZE;
 
 		frag = jffs2_lookup_node_frag(&f->fragtree, start);
 
@@ -1331,7 +1331,7 @@ static int jffs2_garbage_collect_dnode(struct jffs2_sb_info *c, struct jffs2_era
 		cdatalen = min_t(uint32_t, alloclen - sizeof(ri), end - offset);
 		datalen = end - offset;
 
-		writebuf = pg_ptr + (offset & (PAGE_CACHE_SIZE -1));
+		writebuf = pg_ptr + (offset & (PAGE_SIZE -1));
 
 		comprtype = jffs2_compress(c, f, writebuf, &comprbuf, &datalen, &cdatalen);
 
diff --git a/fs/jffs2/nodelist.c b/fs/jffs2/nodelist.c
index 9a5449bc3afb..b86c78d178c6 100644
--- a/fs/jffs2/nodelist.c
+++ b/fs/jffs2/nodelist.c
@@ -90,7 +90,7 @@ uint32_t jffs2_truncate_fragtree(struct jffs2_sb_info *c, struct rb_root *list,
 
 	/* If the last fragment starts at the RAM page boundary, it is
 	 * REF_PRISTINE irrespective of its size. */
-	if (frag->node && (frag->ofs & (PAGE_CACHE_SIZE - 1)) == 0) {
+	if (frag->node && (frag->ofs & (PAGE_SIZE - 1)) == 0) {
 		dbg_fragtree2("marking the last fragment 0x%08x-0x%08x REF_PRISTINE.\n",
 			frag->ofs, frag->ofs + frag->size);
 		frag->node->raw->flash_offset = ref_offset(frag->node->raw) | REF_PRISTINE;
@@ -237,7 +237,7 @@ static int jffs2_add_frag_to_fragtree(struct jffs2_sb_info *c, struct rb_root *r
 		   If so, both 'this' and the new node get marked REF_NORMAL so
 		   the GC can take a look.
 		*/
-		if (lastend && (lastend-1) >> PAGE_CACHE_SHIFT == newfrag->ofs >> PAGE_CACHE_SHIFT) {
+		if (lastend && (lastend-1) >> PAGE_SHIFT == newfrag->ofs >> PAGE_SHIFT) {
 			if (this->node)
 				mark_ref_normal(this->node->raw);
 			mark_ref_normal(newfrag->node->raw);
@@ -382,7 +382,7 @@ int jffs2_add_full_dnode_to_inode(struct jffs2_sb_info *c, struct jffs2_inode_in
 
 	/* If we now share a page with other nodes, mark either previous
 	   or next node REF_NORMAL, as appropriate.  */
-	if (newfrag->ofs & (PAGE_CACHE_SIZE-1)) {
+	if (newfrag->ofs & (PAGE_SIZE-1)) {
 		struct jffs2_node_frag *prev = frag_prev(newfrag);
 
 		mark_ref_normal(fn->raw);
@@ -391,7 +391,7 @@ int jffs2_add_full_dnode_to_inode(struct jffs2_sb_info *c, struct jffs2_inode_in
 			mark_ref_normal(prev->node->raw);
 	}
 
-	if ((newfrag->ofs+newfrag->size) & (PAGE_CACHE_SIZE-1)) {
+	if ((newfrag->ofs+newfrag->size) & (PAGE_SIZE-1)) {
 		struct jffs2_node_frag *next = frag_next(newfrag);
 
 		if (next) {
diff --git a/fs/jffs2/write.c b/fs/jffs2/write.c
index b634de4c8101..7fb187ab2682 100644
--- a/fs/jffs2/write.c
+++ b/fs/jffs2/write.c
@@ -172,8 +172,8 @@ struct jffs2_full_dnode *jffs2_write_dnode(struct jffs2_sb_info *c, struct jffs2
 	   beginning of a page and runs to the end of the file, or if
 	   it's a hole node, mark it REF_PRISTINE, else REF_NORMAL.
 	*/
-	if ((je32_to_cpu(ri->dsize) >= PAGE_CACHE_SIZE) ||
-	    ( ((je32_to_cpu(ri->offset)&(PAGE_CACHE_SIZE-1))==0) &&
+	if ((je32_to_cpu(ri->dsize) >= PAGE_SIZE) ||
+	    ( ((je32_to_cpu(ri->offset)&(PAGE_SIZE-1))==0) &&
 	      (je32_to_cpu(ri->dsize)+je32_to_cpu(ri->offset) ==  je32_to_cpu(ri->isize)))) {
 		flash_ofs |= REF_PRISTINE;
 	} else {
@@ -366,7 +366,8 @@ int jffs2_write_inode_range(struct jffs2_sb_info *c, struct jffs2_inode_info *f,
 			break;
 		}
 		mutex_lock(&f->sem);
-		datalen = min_t(uint32_t, writelen, PAGE_CACHE_SIZE - (offset & (PAGE_CACHE_SIZE-1)));
+		datalen = min_t(uint32_t, writelen,
+				PAGE_SIZE - (offset & (PAGE_SIZE-1)));
 		cdatalen = min_t(uint32_t, alloclen - sizeof(*ri), datalen);
 
 		comprtype = jffs2_compress(c, f, buf, &comprbuf, &datalen, &cdatalen);
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
index a3eb316b1ac3..b60e015cc757 100644
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -80,7 +80,7 @@ static inline void lock_metapage(struct metapage *mp)
 static struct kmem_cache *metapage_cache;
 static mempool_t *metapage_mempool;
 
-#define MPS_PER_PAGE (PAGE_CACHE_SIZE >> L2PSIZE)
+#define MPS_PER_PAGE (PAGE_SIZE >> L2PSIZE)
 
 #if MPS_PER_PAGE > 1
 
@@ -316,7 +316,7 @@ static void last_write_complete(struct page *page)
 	struct metapage *mp;
 	unsigned int offset;
 
-	for (offset = 0; offset < PAGE_CACHE_SIZE; offset += PSIZE) {
+	for (offset = 0; offset < PAGE_SIZE; offset += PSIZE) {
 		mp = page_to_mp(page, offset);
 		if (mp && test_bit(META_io, &mp->flag)) {
 			if (mp->lsn)
@@ -366,12 +366,12 @@ static int metapage_writepage(struct page *page, struct writeback_control *wbc)
 	int bad_blocks = 0;
 
 	page_start = (sector_t)page->index <<
-		     (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		     (PAGE_SHIFT - inode->i_blkbits);
 	BUG_ON(!PageLocked(page));
 	BUG_ON(PageWriteback(page));
 	set_page_writeback(page);
 
-	for (offset = 0; offset < PAGE_CACHE_SIZE; offset += PSIZE) {
+	for (offset = 0; offset < PAGE_SIZE; offset += PSIZE) {
 		mp = page_to_mp(page, offset);
 
 		if (!mp || !test_bit(META_dirty, &mp->flag))
@@ -416,7 +416,7 @@ static int metapage_writepage(struct page *page, struct writeback_control *wbc)
 			bio = NULL;
 		} else
 			inc_io(page);
-		xlen = (PAGE_CACHE_SIZE - offset) >> inode->i_blkbits;
+		xlen = (PAGE_SIZE - offset) >> inode->i_blkbits;
 		pblock = metapage_get_blocks(inode, lblock, &xlen);
 		if (!pblock) {
 			printk(KERN_ERR "JFS: metapage_get_blocks failed\n");
@@ -485,7 +485,7 @@ static int metapage_readpage(struct file *fp, struct page *page)
 	struct inode *inode = page->mapping->host;
 	struct bio *bio = NULL;
 	int block_offset;
-	int blocks_per_page = PAGE_CACHE_SIZE >> inode->i_blkbits;
+	int blocks_per_page = PAGE_SIZE >> inode->i_blkbits;
 	sector_t page_start;	/* address of page in fs blocks */
 	sector_t pblock;
 	int xlen;
@@ -494,7 +494,7 @@ static int metapage_readpage(struct file *fp, struct page *page)
 
 	BUG_ON(!PageLocked(page));
 	page_start = (sector_t)page->index <<
-		     (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		     (PAGE_SHIFT - inode->i_blkbits);
 
 	block_offset = 0;
 	while (block_offset < blocks_per_page) {
@@ -542,7 +542,7 @@ static int metapage_releasepage(struct page *page, gfp_t gfp_mask)
 	int ret = 1;
 	int offset;
 
-	for (offset = 0; offset < PAGE_CACHE_SIZE; offset += PSIZE) {
+	for (offset = 0; offset < PAGE_SIZE; offset += PSIZE) {
 		mp = page_to_mp(page, offset);
 
 		if (!mp)
@@ -568,7 +568,7 @@ static int metapage_releasepage(struct page *page, gfp_t gfp_mask)
 static void metapage_invalidatepage(struct page *page, unsigned int offset,
 				    unsigned int length)
 {
-	BUG_ON(offset || length < PAGE_CACHE_SIZE);
+	BUG_ON(offset || length < PAGE_SIZE);
 
 	BUG_ON(PageWriteback(page));
 
@@ -599,10 +599,10 @@ struct metapage *__get_metapage(struct inode *inode, unsigned long lblock,
 		 inode->i_ino, lblock, absolute);
 
 	l2bsize = inode->i_blkbits;
-	l2BlocksPerPage = PAGE_CACHE_SHIFT - l2bsize;
+	l2BlocksPerPage = PAGE_SHIFT - l2bsize;
 	page_index = lblock >> l2BlocksPerPage;
 	page_offset = (lblock - (page_index << l2BlocksPerPage)) << l2bsize;
-	if ((page_offset + size) > PAGE_CACHE_SIZE) {
+	if ((page_offset + size) > PAGE_SIZE) {
 		jfs_err("MetaData crosses page boundary!!");
 		jfs_err("lblock = %lx, size  = %d", lblock, size);
 		dump_stack();
@@ -621,7 +621,7 @@ struct metapage *__get_metapage(struct inode *inode, unsigned long lblock,
 		mapping = inode->i_mapping;
 	}
 
-	if (new && (PSIZE == PAGE_CACHE_SIZE)) {
+	if (new && (PSIZE == PAGE_SIZE)) {
 		page = grab_cache_page(mapping, page_index);
 		if (!page) {
 			jfs_err("grab_cache_page failed!");
@@ -693,7 +693,7 @@ unlock:
 void grab_metapage(struct metapage * mp)
 {
 	jfs_info("grab_metapage: mp = 0x%p", mp);
-	page_cache_get(mp->page);
+	get_page(mp->page);
 	lock_page(mp->page);
 	mp->count++;
 	lock_metapage(mp);
@@ -706,12 +706,12 @@ void force_metapage(struct metapage *mp)
 	jfs_info("force_metapage: mp = 0x%p", mp);
 	set_bit(META_forcewrite, &mp->flag);
 	clear_bit(META_sync, &mp->flag);
-	page_cache_get(page);
+	get_page(page);
 	lock_page(page);
 	set_page_dirty(page);
 	write_one_page(page, 1);
 	clear_bit(META_forcewrite, &mp->flag);
-	page_cache_release(page);
+	put_page(page);
 }
 
 void hold_metapage(struct metapage *mp)
@@ -726,7 +726,7 @@ void put_metapage(struct metapage *mp)
 		unlock_page(mp->page);
 		return;
 	}
-	page_cache_get(mp->page);
+	get_page(mp->page);
 	mp->count++;
 	lock_metapage(mp);
 	unlock_page(mp->page);
@@ -746,7 +746,7 @@ void release_metapage(struct metapage * mp)
 	assert(mp->count);
 	if (--mp->count || mp->nohomeok) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return;
 	}
 
@@ -764,13 +764,13 @@ void release_metapage(struct metapage * mp)
 	drop_metapage(page, mp);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 void __invalidate_metapages(struct inode *ip, s64 addr, int len)
 {
 	sector_t lblock;
-	int l2BlocksPerPage = PAGE_CACHE_SHIFT - ip->i_blkbits;
+	int l2BlocksPerPage = PAGE_SHIFT - ip->i_blkbits;
 	int BlocksPerPage = 1 << l2BlocksPerPage;
 	/* All callers are interested in block device's mapping */
 	struct address_space *mapping =
@@ -788,7 +788,7 @@ void __invalidate_metapages(struct inode *ip, s64 addr, int len)
 		page = find_lock_page(mapping, lblock >> l2BlocksPerPage);
 		if (!page)
 			continue;
-		for (offset = 0; offset < PAGE_CACHE_SIZE; offset += PSIZE) {
+		for (offset = 0; offset < PAGE_SIZE; offset += PSIZE) {
 			mp = page_to_mp(page, offset);
 			if (!mp)
 				continue;
@@ -803,7 +803,7 @@ void __invalidate_metapages(struct inode *ip, s64 addr, int len)
 				remove_from_logsync(mp);
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
diff --git a/fs/jfs/jfs_metapage.h b/fs/jfs/jfs_metapage.h
index 337e9e51ac06..a869fb4a20d6 100644
--- a/fs/jfs/jfs_metapage.h
+++ b/fs/jfs/jfs_metapage.h
@@ -106,7 +106,7 @@ static inline void metapage_nohomeok(struct metapage *mp)
 	lock_page(page);
 	if (!mp->nohomeok++) {
 		mark_metapage_dirty(mp);
-		page_cache_get(page);
+		get_page(page);
 		wait_on_page_writeback(page);
 	}
 	unlock_page(page);
@@ -128,7 +128,7 @@ static inline void metapage_wait_for_io(struct metapage *mp)
 static inline void _metapage_homeok(struct metapage *mp)
 {
 	if (!--mp->nohomeok)
-		page_cache_release(mp->page);
+		put_page(mp->page);
 }
 
 static inline void metapage_homeok(struct metapage *mp)
diff --git a/fs/jfs/super.c b/fs/jfs/super.c
index 4f5d85ba8e23..78d599198bf5 100644
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -596,7 +596,7 @@ static int jfs_fill_super(struct super_block *sb, void *data, int silent)
 	 * Page cache is indexed by long.
 	 * I would use MAX_LFS_FILESIZE, but it's only half as big
 	 */
-	sb->s_maxbytes = min(((u64) PAGE_CACHE_SIZE << 32) - 1,
+	sb->s_maxbytes = min(((u64) PAGE_SIZE << 32) - 1,
 			     (u64)sb->s_maxbytes);
 #endif
 	sb->s_time_gran = 1;
diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index 8eaf417187f1..43393e1008d1 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -69,8 +69,8 @@ static int kernfs_fill_super(struct super_block *sb, unsigned long magic)
 	struct dentry *root;
 
 	info->sb = sb;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = magic;
 	sb->s_op = &kernfs_sops;
 	sb->s_time_gran = 1;
diff --git a/fs/libfs.c b/fs/libfs.c
index 0ca80b2af420..f3fa82ce9b70 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -25,7 +25,7 @@ int simple_getattr(struct vfsmount *mnt, struct dentry *dentry,
 {
 	struct inode *inode = d_inode(dentry);
 	generic_fillattr(inode, stat);
-	stat->blocks = inode->i_mapping->nrpages << (PAGE_CACHE_SHIFT - 9);
+	stat->blocks = inode->i_mapping->nrpages << (PAGE_SHIFT - 9);
 	return 0;
 }
 EXPORT_SYMBOL(simple_getattr);
@@ -33,7 +33,7 @@ EXPORT_SYMBOL(simple_getattr);
 int simple_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	buf->f_type = dentry->d_sb->s_magic;
-	buf->f_bsize = PAGE_CACHE_SIZE;
+	buf->f_bsize = PAGE_SIZE;
 	buf->f_namelen = NAME_MAX;
 	return 0;
 }
@@ -395,7 +395,7 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
 	struct page *page;
 	pgoff_t index;
 
-	index = pos >> PAGE_CACHE_SHIFT;
+	index = pos >> PAGE_SHIFT;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
@@ -403,10 +403,10 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
 
 	*pagep = page;
 
-	if (!PageUptodate(page) && (len != PAGE_CACHE_SIZE)) {
-		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	if (!PageUptodate(page) && (len != PAGE_SIZE)) {
+		unsigned from = pos & (PAGE_SIZE - 1);
 
-		zero_user_segments(page, 0, from, from + len, PAGE_CACHE_SIZE);
+		zero_user_segments(page, 0, from, from + len, PAGE_SIZE);
 	}
 	return 0;
 }
@@ -442,7 +442,7 @@ int simple_write_end(struct file *file, struct address_space *mapping,
 
 	/* zero the stale part of the page if we did a short copy */
 	if (copied < len) {
-		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+		unsigned from = pos & (PAGE_SIZE - 1);
 
 		zero_user(page, from + copied, len - copied);
 	}
@@ -458,7 +458,7 @@ int simple_write_end(struct file *file, struct address_space *mapping,
 
 	set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
@@ -477,8 +477,8 @@ int simple_fill_super(struct super_block *s, unsigned long magic,
 	struct dentry *dentry;
 	int i;
 
-	s->s_blocksize = PAGE_CACHE_SIZE;
-	s->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	s->s_blocksize = PAGE_SIZE;
+	s->s_blocksize_bits = PAGE_SHIFT;
 	s->s_magic = magic;
 	s->s_op = &simple_super_operations;
 	s->s_time_gran = 1;
@@ -994,12 +994,12 @@ int generic_check_addressable(unsigned blocksize_bits, u64 num_blocks)
 {
 	u64 last_fs_block = num_blocks - 1;
 	u64 last_fs_page =
-		last_fs_block >> (PAGE_CACHE_SHIFT - blocksize_bits);
+		last_fs_block >> (PAGE_SHIFT - blocksize_bits);
 
 	if (unlikely(num_blocks == 0))
 		return 0;
 
-	if ((blocksize_bits < 9) || (blocksize_bits > PAGE_CACHE_SHIFT))
+	if ((blocksize_bits < 9) || (blocksize_bits > PAGE_SHIFT))
 		return -EINVAL;
 
 	if ((last_fs_block > (sector_t)(~0ULL) >> (blocksize_bits - 9)) ||
diff --git a/fs/logfs/dev_bdev.c b/fs/logfs/dev_bdev.c
index a709d80c8ebc..cc26f8f215f5 100644
--- a/fs/logfs/dev_bdev.c
+++ b/fs/logfs/dev_bdev.c
@@ -64,7 +64,7 @@ static void writeseg_end_io(struct bio *bio)
 
 	bio_for_each_segment_all(bvec, bio, i) {
 		end_page_writeback(bvec->bv_page);
-		page_cache_release(bvec->bv_page);
+		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
 	if (atomic_dec_and_test(&super->s_pending_writes))
diff --git a/fs/logfs/dev_mtd.c b/fs/logfs/dev_mtd.c
index 9c501449450d..b76a62b1978f 100644
--- a/fs/logfs/dev_mtd.c
+++ b/fs/logfs/dev_mtd.c
@@ -46,9 +46,9 @@ static int loffs_mtd_write(struct super_block *sb, loff_t ofs, size_t len,
 
 	BUG_ON((ofs >= mtd->size) || (len > mtd->size - ofs));
 	BUG_ON(ofs != (ofs >> super->s_writeshift) << super->s_writeshift);
-	BUG_ON(len > PAGE_CACHE_SIZE);
-	page_start = ofs & PAGE_CACHE_MASK;
-	page_end = PAGE_CACHE_ALIGN(ofs + len) - 1;
+	BUG_ON(len > PAGE_SIZE);
+	page_start = ofs & PAGE_MASK;
+	page_end = PAGE_ALIGN(ofs + len) - 1;
 	ret = mtd_write(mtd, ofs, len, &retlen, buf);
 	if (ret || (retlen != len))
 		return -EIO;
@@ -82,7 +82,7 @@ static int logfs_mtd_erase_mapping(struct super_block *sb, loff_t ofs,
 		if (!page)
 			continue;
 		memset(page_address(page), 0xFF, PAGE_SIZE);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return 0;
 }
@@ -195,7 +195,7 @@ static int __logfs_mtd_writeseg(struct super_block *sb, u64 ofs, pgoff_t index,
 		err = loffs_mtd_write(sb, page->index << PAGE_SHIFT, PAGE_SIZE,
 					page_address(page));
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (err)
 			return err;
 	}
diff --git a/fs/logfs/dir.c b/fs/logfs/dir.c
index 542468e9bfb4..ddbed2be5366 100644
--- a/fs/logfs/dir.c
+++ b/fs/logfs/dir.c
@@ -183,7 +183,7 @@ static struct page *logfs_get_dd_page(struct inode *dir, struct dentry *dentry)
 		if (name->len != be16_to_cpu(dd->namelen) ||
 				memcmp(name->name, dd->name, name->len)) {
 			kunmap_atomic(dd);
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -238,7 +238,7 @@ static int logfs_unlink(struct inode *dir, struct dentry *dentry)
 		return PTR_ERR(page);
 	}
 	index = page->index;
-	page_cache_release(page);
+	put_page(page);
 
 	mutex_lock(&super->s_dirop_mutex);
 	logfs_add_transaction(dir, ta);
@@ -316,7 +316,7 @@ static int logfs_readdir(struct file *file, struct dir_context *ctx)
 				be16_to_cpu(dd->namelen),
 				be64_to_cpu(dd->ino), dd->type);
 		kunmap(page);
-		page_cache_release(page);
+		put_page(page);
 		if (full)
 			break;
 	}
@@ -349,7 +349,7 @@ static struct dentry *logfs_lookup(struct inode *dir, struct dentry *dentry,
 	dd = kmap_atomic(page);
 	ino = be64_to_cpu(dd->ino);
 	kunmap_atomic(dd);
-	page_cache_release(page);
+	put_page(page);
 
 	inode = logfs_iget(dir->i_sb, ino);
 	if (IS_ERR(inode))
@@ -392,7 +392,7 @@ static int logfs_write_dir(struct inode *dir, struct dentry *dentry,
 
 		err = logfs_write_buf(dir, page, WF_LOCK);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (!err)
 			grow_dir(dir, index);
 		return err;
@@ -561,7 +561,7 @@ static int logfs_get_dd(struct inode *dir, struct dentry *dentry,
 	map = kmap_atomic(page);
 	memcpy(dd, map, sizeof(*dd));
 	kunmap_atomic(map);
-	page_cache_release(page);
+	put_page(page);
 	return 0;
 }
 
diff --git a/fs/logfs/file.c b/fs/logfs/file.c
index 61eaeb1b6cac..f01ddfb1a03b 100644
--- a/fs/logfs/file.c
+++ b/fs/logfs/file.c
@@ -15,21 +15,21 @@ static int logfs_write_begin(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	struct page *page;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
 
-	if ((len == PAGE_CACHE_SIZE) || PageUptodate(page))
+	if ((len == PAGE_SIZE) || PageUptodate(page))
 		return 0;
-	if ((pos & PAGE_CACHE_MASK) >= i_size_read(inode)) {
-		unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	if ((pos & PAGE_MASK) >= i_size_read(inode)) {
+		unsigned start = pos & (PAGE_SIZE - 1);
 		unsigned end = start + len;
 
 		/* Reading beyond i_size is simple: memset to zero */
-		zero_user_segments(page, 0, start, end, PAGE_CACHE_SIZE);
+		zero_user_segments(page, 0, start, end, PAGE_SIZE);
 		return 0;
 	}
 	return logfs_readpage_nolock(page);
@@ -41,11 +41,11 @@ static int logfs_write_end(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	pgoff_t index = page->index;
-	unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned start = pos & (PAGE_SIZE - 1);
 	unsigned end = start + copied;
 	int ret = 0;
 
-	BUG_ON(PAGE_CACHE_SIZE != inode->i_sb->s_blocksize);
+	BUG_ON(PAGE_SIZE != inode->i_sb->s_blocksize);
 	BUG_ON(page->index > I3_BLOCKS);
 
 	if (copied < len) {
@@ -61,8 +61,8 @@ static int logfs_write_end(struct file *file, struct address_space *mapping,
 	if (copied == 0)
 		goto out; /* FIXME: do we need to update inode? */
 
-	if (i_size_read(inode) < (index << PAGE_CACHE_SHIFT) + end) {
-		i_size_write(inode, (index << PAGE_CACHE_SHIFT) + end);
+	if (i_size_read(inode) < (index << PAGE_SHIFT) + end) {
+		i_size_write(inode, (index << PAGE_SHIFT) + end);
 		mark_inode_dirty_sync(inode);
 	}
 
@@ -75,7 +75,7 @@ static int logfs_write_end(struct file *file, struct address_space *mapping,
 	}
 out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return ret ? ret : copied;
 }
 
@@ -118,7 +118,7 @@ static int logfs_writepage(struct page *page, struct writeback_control *wbc)
 {
 	struct inode *inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
-	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
 	u64 bix;
 	level_t level;
@@ -142,7 +142,7 @@ static int logfs_writepage(struct page *page, struct writeback_control *wbc)
 		return __logfs_writepage(page);
 
 	 /* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = i_size & (PAGE_SIZE-1);
 	if (bix > end_index || offset == 0) {
 		unlock_page(page);
 		return 0; /* don't care */
@@ -155,7 +155,7 @@ static int logfs_writepage(struct page *page, struct writeback_control *wbc)
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 	return __logfs_writepage(page);
 }
 
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index 20973c9e52f8..3fb8c6d67303 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -281,7 +281,7 @@ static struct page *logfs_get_read_page(struct inode *inode, u64 bix,
 static void logfs_put_read_page(struct page *page)
 {
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static void logfs_lock_write_page(struct page *page)
@@ -323,7 +323,7 @@ repeat:
 			return NULL;
 		err = add_to_page_cache_lru(page, mapping, index, GFP_NOFS);
 		if (unlikely(err)) {
-			page_cache_release(page);
+			put_page(page);
 			if (err == -EEXIST)
 				goto repeat;
 			return NULL;
@@ -342,7 +342,7 @@ static void logfs_unlock_write_page(struct page *page)
 static void logfs_put_write_page(struct page *page)
 {
 	logfs_unlock_write_page(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static struct page *logfs_get_page(struct inode *inode, u64 bix, level_t level,
@@ -562,7 +562,7 @@ static void indirect_free_block(struct super_block *sb,
 
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
-		page_cache_release(page);
+		put_page(page);
 		set_page_private(page, 0);
 	}
 	__free_block(sb, block);
@@ -655,7 +655,7 @@ static void alloc_data_block(struct inode *inode, struct page *page)
 	block->page = page;
 
 	SetPagePrivate(page);
-	page_cache_get(page);
+	get_page(page);
 	set_page_private(page, (unsigned long) block);
 
 	block->ops = &indirect_block_ops;
@@ -709,7 +709,7 @@ static u64 block_get_pointer(struct page *page, int index)
 
 static int logfs_read_empty(struct page *page)
 {
-	zero_user_segment(page, 0, PAGE_CACHE_SIZE);
+	zero_user_segment(page, 0, PAGE_SIZE);
 	return 0;
 }
 
@@ -1660,7 +1660,7 @@ static int truncate_data_block(struct inode *inode, struct page *page,
 	if (err)
 		return err;
 
-	zero_user_segment(page, size - pageofs, PAGE_CACHE_SIZE);
+	zero_user_segment(page, size - pageofs, PAGE_SIZE);
 	return logfs_segment_write(inode, page, shadow);
 }
 
@@ -1919,7 +1919,7 @@ static void move_page_to_inode(struct inode *inode, struct page *page)
 	block->page = NULL;
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
-		page_cache_release(page);
+		put_page(page);
 		set_page_private(page, 0);
 	}
 }
@@ -1940,7 +1940,7 @@ static void move_inode_to_page(struct page *page, struct inode *inode)
 
 	if (!PagePrivate(page)) {
 		SetPagePrivate(page);
-		page_cache_get(page);
+		get_page(page);
 		set_page_private(page, (unsigned long) block);
 	}
 
@@ -1971,7 +1971,7 @@ int logfs_read_inode(struct inode *inode)
 	logfs_disk_to_inode(di, inode);
 	kunmap_atomic(di);
 	move_page_to_inode(inode, page);
-	page_cache_release(page);
+	put_page(page);
 	return 0;
 }
 
diff --git a/fs/logfs/segment.c b/fs/logfs/segment.c
index d270e4b2ab6b..1efd6055f4b0 100644
--- a/fs/logfs/segment.c
+++ b/fs/logfs/segment.c
@@ -90,9 +90,9 @@ int __logfs_buf_write(struct logfs_area *area, u64 ofs, void *buf, size_t len,
 
 		if (!PagePrivate(page)) {
 			SetPagePrivate(page);
-			page_cache_get(page);
+			get_page(page);
 		}
-		page_cache_release(page);
+		put_page(page);
 
 		buf += copylen;
 		len -= copylen;
@@ -117,9 +117,9 @@ static void pad_partial_page(struct logfs_area *area)
 		memset(page_address(page) + offset, 0xff, len);
 		if (!PagePrivate(page)) {
 			SetPagePrivate(page);
-			page_cache_get(page);
+			get_page(page);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
@@ -129,20 +129,20 @@ static void pad_full_pages(struct logfs_area *area)
 	struct logfs_super *super = logfs_super(sb);
 	u64 ofs = dev_ofs(sb, area->a_segno, area->a_used_bytes);
 	u32 len = super->s_segsize - area->a_used_bytes;
-	pgoff_t index = PAGE_CACHE_ALIGN(ofs) >> PAGE_CACHE_SHIFT;
-	pgoff_t no_indizes = len >> PAGE_CACHE_SHIFT;
+	pgoff_t index = PAGE_ALIGN(ofs) >> PAGE_SHIFT;
+	pgoff_t no_indizes = len >> PAGE_SHIFT;
 	struct page *page;
 
 	while (no_indizes) {
 		page = get_mapping_page(sb, index, 0);
 		BUG_ON(!page); /* FIXME: reserve a pool */
 		SetPageUptodate(page);
-		memset(page_address(page), 0xff, PAGE_CACHE_SIZE);
+		memset(page_address(page), 0xff, PAGE_SIZE);
 		if (!PagePrivate(page)) {
 			SetPagePrivate(page);
-			page_cache_get(page);
+			get_page(page);
 		}
-		page_cache_release(page);
+		put_page(page);
 		index++;
 		no_indizes--;
 	}
@@ -411,7 +411,7 @@ int wbuf_read(struct super_block *sb, u64 ofs, size_t len, void *buf)
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 		memcpy(buf, page_address(page) + offset, copylen);
-		page_cache_release(page);
+		put_page(page);
 
 		buf += copylen;
 		len -= copylen;
@@ -499,7 +499,7 @@ static void move_btree_to_page(struct inode *inode, struct page *page,
 
 	if (!PagePrivate(page)) {
 		SetPagePrivate(page);
-		page_cache_get(page);
+		get_page(page);
 		set_page_private(page, (unsigned long) block);
 	}
 	block->ops = &indirect_block_ops;
@@ -554,7 +554,7 @@ void move_page_to_btree(struct page *page)
 
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
-		page_cache_release(page);
+		put_page(page);
 		set_page_private(page, 0);
 	}
 	block->ops = &btree_block_ops;
@@ -723,9 +723,9 @@ void freeseg(struct super_block *sb, u32 segno)
 			continue;
 		if (PagePrivate(page)) {
 			ClearPagePrivate(page);
-			page_cache_release(page);
+			put_page(page);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
diff --git a/fs/logfs/super.c b/fs/logfs/super.c
index 54360293bcb5..5751082dba52 100644
--- a/fs/logfs/super.c
+++ b/fs/logfs/super.c
@@ -48,7 +48,7 @@ void emergency_read_end(struct page *page)
 	if (page == emergency_page)
 		mutex_unlock(&emergency_mutex);
 	else
-		page_cache_release(page);
+		put_page(page);
 }
 
 static void dump_segfile(struct super_block *sb)
@@ -206,7 +206,7 @@ static int write_one_sb(struct super_block *sb,
 	logfs_set_segment_erased(sb, segno, ec, 0);
 	logfs_write_ds(sb, ds, segno, ec);
 	err = super->s_devops->write_sb(sb, page);
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
@@ -366,24 +366,24 @@ static struct page *find_super_block(struct super_block *sb)
 		return NULL;
 	last = super->s_devops->find_last_sb(sb, &super->s_sb_ofs[1]);
 	if (!last || IS_ERR(last)) {
-		page_cache_release(first);
+		put_page(first);
 		return NULL;
 	}
 
 	if (!logfs_check_ds(page_address(first))) {
-		page_cache_release(last);
+		put_page(last);
 		return first;
 	}
 
 	/* First one didn't work, try the second superblock */
 	if (!logfs_check_ds(page_address(last))) {
-		page_cache_release(first);
+		put_page(first);
 		return last;
 	}
 
 	/* Neither worked, sorry folks */
-	page_cache_release(first);
-	page_cache_release(last);
+	put_page(first);
+	put_page(last);
 	return NULL;
 }
 
@@ -425,7 +425,7 @@ static int __logfs_read_sb(struct super_block *sb)
 	super->s_data_levels = ds->ds_data_levels;
 	super->s_total_levels = super->s_ifile_levels + super->s_iblock_levels
 		+ super->s_data_levels;
-	page_cache_release(page);
+	put_page(page);
 	return 0;
 }
 
diff --git a/fs/minix/dir.c b/fs/minix/dir.c
index d19ac258105a..33957c07cd11 100644
--- a/fs/minix/dir.c
+++ b/fs/minix/dir.c
@@ -28,7 +28,7 @@ const struct file_operations minix_dir_operations = {
 static inline void dir_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -38,10 +38,10 @@ static inline void dir_put_page(struct page *page)
 static unsigned
 minix_last_byte(struct inode *inode, unsigned long page_nr)
 {
-	unsigned last_byte = PAGE_CACHE_SIZE;
+	unsigned last_byte = PAGE_SIZE;
 
-	if (page_nr == (inode->i_size >> PAGE_CACHE_SHIFT))
-		last_byte = inode->i_size & (PAGE_CACHE_SIZE - 1);
+	if (page_nr == (inode->i_size >> PAGE_SHIFT))
+		last_byte = inode->i_size & (PAGE_SIZE - 1);
 	return last_byte;
 }
 
@@ -92,8 +92,8 @@ static int minix_readdir(struct file *file, struct dir_context *ctx)
 	if (pos >= inode->i_size)
 		return 0;
 
-	offset = pos & ~PAGE_CACHE_MASK;
-	n = pos >> PAGE_CACHE_SHIFT;
+	offset = pos & ~PAGE_MASK;
+	n = pos >> PAGE_SHIFT;
 
 	for ( ; n < npages; n++, offset = 0) {
 		char *p, *kaddr, *limit;
@@ -229,7 +229,7 @@ int minix_add_link(struct dentry *dentry, struct inode *inode)
 		lock_page(page);
 		kaddr = (char*)page_address(page);
 		dir_end = kaddr + minix_last_byte(dir, n);
-		limit = kaddr + PAGE_CACHE_SIZE - sbi->s_dirsize;
+		limit = kaddr + PAGE_SIZE - sbi->s_dirsize;
 		for (p = kaddr; p <= limit; p = minix_next_entry(p, sbi)) {
 			de = (minix_dirent *)p;
 			de3 = (minix3_dirent *)p;
@@ -327,7 +327,7 @@ int minix_make_empty(struct inode *inode, struct inode *dir)
 	}
 
 	kaddr = kmap_atomic(page);
-	memset(kaddr, 0, PAGE_CACHE_SIZE);
+	memset(kaddr, 0, PAGE_SIZE);
 
 	if (sbi->s_version == MINIX_V3) {
 		minix3_dirent *de3 = (minix3_dirent *)kaddr;
@@ -350,7 +350,7 @@ int minix_make_empty(struct inode *inode, struct inode *dir)
 
 	err = dir_commit_chunk(page, 0, 2 * sbi->s_dirsize);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/minix/namei.c b/fs/minix/namei.c
index a795a11e50c7..2887d1d95ce2 100644
--- a/fs/minix/namei.c
+++ b/fs/minix/namei.c
@@ -243,11 +243,11 @@ static int minix_rename(struct inode * old_dir, struct dentry *old_dentry,
 out_dir:
 	if (dir_de) {
 		kunmap(dir_page);
-		page_cache_release(dir_page);
+		put_page(dir_page);
 	}
 out_old:
 	kunmap(old_page);
-	page_cache_release(old_page);
+	put_page(old_page);
 out:
 	return err;
 }
diff --git a/fs/mpage.c b/fs/mpage.c
index 6bd9fd90964e..243c9f68f696 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -107,7 +107,7 @@ map_buffer_to_page(struct page *page, struct buffer_head *bh, int page_block)
 		 * don't make any buffers if there is only one buffer on
 		 * the page and the page just needs to be set up to date
 		 */
-		if (inode->i_blkbits == PAGE_CACHE_SHIFT && 
+		if (inode->i_blkbits == PAGE_SHIFT && 
 		    buffer_uptodate(bh)) {
 			SetPageUptodate(page);    
 			return;
@@ -145,7 +145,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 {
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	sector_t block_in_file;
 	sector_t last_block;
@@ -162,7 +162,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	if (page_has_buffers(page))
 		goto confused;
 
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 	last_block = block_in_file + nr_pages * blocks_per_page;
 	last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
 	if (last_block > last_block_in_file)
@@ -249,7 +249,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	}
 
 	if (first_hole != blocks_per_page) {
-		zero_user_segment(page, first_hole << blkbits, PAGE_CACHE_SIZE);
+		zero_user_segment(page, first_hole << blkbits, PAGE_SIZE);
 		if (first_hole == 0) {
 			SetPageUptodate(page);
 			unlock_page(page);
@@ -380,7 +380,7 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 					&first_logical_block,
 					get_block, gfp);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 	BUG_ON(!list_empty(pages));
 	if (bio)
@@ -472,7 +472,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
 	unsigned long end_index;
-	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
+	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
 	sector_t last_block;
 	sector_t block_in_file;
 	sector_t blocks[MAX_BUF_PER_PAGE];
@@ -542,7 +542,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	 * The page has no buffers: map it to disk
 	 */
 	BUG_ON(!PageUptodate(page));
-	block_in_file = (sector_t)page->index << (PAGE_CACHE_SHIFT - blkbits);
+	block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 	last_block = (i_size - 1) >> blkbits;
 	map_bh.b_page = page;
 	for (page_block = 0; page_block < blocks_per_page; ) {
@@ -574,7 +574,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
 	first_unmapped = page_block;
 
 page_is_mapped:
-	end_index = i_size >> PAGE_CACHE_SHIFT;
+	end_index = i_size >> PAGE_SHIFT;
 	if (page->index >= end_index) {
 		/*
 		 * The page straddles i_size.  It must be zeroed out on each
@@ -584,11 +584,11 @@ page_is_mapped:
 		 * is zeroed when mapped, and writes to that region are not
 		 * written out to the file."
 		 */
-		unsigned offset = i_size & (PAGE_CACHE_SIZE - 1);
+		unsigned offset = i_size & (PAGE_SIZE - 1);
 
 		if (page->index > end_index || !offset)
 			goto confused;
-		zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+		zero_user_segment(page, offset, PAGE_SIZE);
 	}
 
 	/*
diff --git a/fs/ncpfs/dir.c b/fs/ncpfs/dir.c
index b7f8eaeea5d8..bfdad003ee56 100644
--- a/fs/ncpfs/dir.c
+++ b/fs/ncpfs/dir.c
@@ -510,7 +510,7 @@ static int ncp_readdir(struct file *file, struct dir_context *ctx)
 			kunmap(ctl.page);
 			SetPageUptodate(ctl.page);
 			unlock_page(ctl.page);
-			page_cache_release(ctl.page);
+			put_page(ctl.page);
 			ctl.page = NULL;
 		}
 		ctl.idx  = 0;
@@ -520,7 +520,7 @@ invalid_cache:
 	if (ctl.page) {
 		kunmap(ctl.page);
 		unlock_page(ctl.page);
-		page_cache_release(ctl.page);
+		put_page(ctl.page);
 		ctl.page = NULL;
 	}
 	ctl.cache = cache;
@@ -554,14 +554,14 @@ finished:
 		kunmap(ctl.page);
 		SetPageUptodate(ctl.page);
 		unlock_page(ctl.page);
-		page_cache_release(ctl.page);
+		put_page(ctl.page);
 	}
 	if (page) {
 		cache->head = ctl.head;
 		kunmap(page);
 		SetPageUptodate(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 out:
 	return result;
@@ -649,7 +649,7 @@ ncp_fill_cache(struct file *file, struct dir_context *ctx,
 			kunmap(ctl.page);
 			SetPageUptodate(ctl.page);
 			unlock_page(ctl.page);
-			page_cache_release(ctl.page);
+			put_page(ctl.page);
 		}
 		ctl.cache = NULL;
 		ctl.idx  -= NCP_DIRCACHE_SIZE;
diff --git a/fs/ncpfs/ncplib_kernel.h b/fs/ncpfs/ncplib_kernel.h
index 5233fbc1747a..17cfb743b5bf 100644
--- a/fs/ncpfs/ncplib_kernel.h
+++ b/fs/ncpfs/ncplib_kernel.h
@@ -191,7 +191,7 @@ struct ncp_cache_head {
 	int		eof;
 };
 
-#define NCP_DIRCACHE_SIZE	((int)(PAGE_CACHE_SIZE/sizeof(struct dentry *)))
+#define NCP_DIRCACHE_SIZE	((int)(PAGE_SIZE/sizeof(struct dentry *)))
 union ncp_dir_cache {
 	struct ncp_cache_head	head;
 	struct dentry		*dentry[NCP_DIRCACHE_SIZE];
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index ddd0138f410c..bba0ba9f7eb1 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -231,7 +231,7 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 	size_t bytes_left = header->args.count;
 	unsigned int pg_offset = header->args.pgbase, pg_len;
 	struct page **pages = header->args.pages;
-	int pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
+	int pg_index = header->args.pgbase >> PAGE_SHIFT;
 	const bool is_dio = (header->dreq != NULL);
 	struct blk_plug plug;
 	int i;
@@ -263,13 +263,13 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 		}
 
 		if (is_dio) {
-			if (pg_offset + bytes_left > PAGE_CACHE_SIZE)
-				pg_len = PAGE_CACHE_SIZE - pg_offset;
+			if (pg_offset + bytes_left > PAGE_SIZE)
+				pg_len = PAGE_SIZE - pg_offset;
 			else
 				pg_len = bytes_left;
 		} else {
 			BUG_ON(pg_offset != 0);
-			pg_len = PAGE_CACHE_SIZE;
+			pg_len = PAGE_SIZE;
 		}
 
 		if (is_hole(&be)) {
@@ -339,9 +339,9 @@ static void bl_write_cleanup(struct work_struct *work)
 
 	if (likely(!hdr->pnfs_error)) {
 		struct pnfs_block_layout *bl = BLK_LSEG2EXT(hdr->lseg);
-		u64 start = hdr->args.offset & (loff_t)PAGE_CACHE_MASK;
+		u64 start = hdr->args.offset & (loff_t)PAGE_MASK;
 		u64 end = (hdr->args.offset + hdr->args.count +
-			PAGE_CACHE_SIZE - 1) & (loff_t)PAGE_CACHE_MASK;
+			PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
 
 		ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
 					(end - start) >> SECTOR_SHIFT);
@@ -373,7 +373,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 	loff_t offset = header->args.offset;
 	size_t count = header->args.count;
 	struct page **pages = header->args.pages;
-	int pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
+	int pg_index = header->args.pgbase >> PAGE_SHIFT;
 	unsigned int pg_len;
 	struct blk_plug plug;
 	int i;
@@ -392,7 +392,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 	blk_start_plug(&plug);
 
 	/* we always write out the whole page */
-	offset = offset & (loff_t)PAGE_CACHE_MASK;
+	offset = offset & (loff_t)PAGE_MASK;
 	isect = offset >> SECTOR_SHIFT;
 
 	for (i = pg_index; i < header->page_array.npages; i++) {
@@ -408,7 +408,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 			extent_length = be.be_length - (isect - be.be_f_offset);
 		}
 
-		pg_len = PAGE_CACHE_SIZE;
+		pg_len = PAGE_SIZE;
 		bio = do_add_page_to_bio(bio, header->page_array.npages - i,
 					 WRITE, isect, pages[i], &map, &be,
 					 bl_end_io_write, par,
@@ -806,7 +806,7 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
 	pgoff_t end;
 
 	/* Optimize common case that writes from 0 to end of file */
-	end = DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE);
+	end = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 	if (end != inode->i_mapping->nrpages) {
 		rcu_read_lock();
 		end = page_cache_next_hole(mapping, idx + 1, ULONG_MAX);
@@ -814,9 +814,9 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
 	}
 
 	if (!end)
-		return i_size_read(inode) - (idx << PAGE_CACHE_SHIFT);
+		return i_size_read(inode) - (idx << PAGE_SHIFT);
 	else
-		return (end - idx) << PAGE_CACHE_SHIFT;
+		return (end - idx) << PAGE_SHIFT;
 }
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index c556640dcf3b..f99371796c63 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -40,8 +40,8 @@
 #include "../pnfs.h"
 #include "../netns.h"
 
-#define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> SECTOR_SHIFT)
-#define PAGE_CACHE_SECTOR_SHIFT (PAGE_CACHE_SHIFT - SECTOR_SHIFT)
+#define PAGE_CACHE_SECTORS (PAGE_SIZE >> SECTOR_SHIFT)
+#define PAGE_CACHE_SECTOR_SHIFT (PAGE_SHIFT - SECTOR_SHIFT)
 #define SECTOR_SIZE (1 << SECTOR_SHIFT)
 
 struct pnfs_block_dev;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d6d5d2a48e83..0c96528db94a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -736,7 +736,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 		server->rsize = max_rpc_payload;
 	if (server->rsize > NFS_MAX_FILE_IO_SIZE)
 		server->rsize = NFS_MAX_FILE_IO_SIZE;
-	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	server->rpages = (server->rsize + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	server->backing_dev_info.name = "nfs";
 	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
@@ -745,13 +745,13 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 		server->wsize = max_rpc_payload;
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
-	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	server->wpages = (server->wsize + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
 	server->dtsize = nfs_block_size(fsinfo->dtpref, NULL);
-	if (server->dtsize > PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES)
-		server->dtsize = PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES;
+	if (server->dtsize > PAGE_SIZE * NFS_MAX_READDIR_PAGES)
+		server->dtsize = PAGE_SIZE * NFS_MAX_READDIR_PAGES;
 	if (server->dtsize > server->rsize)
 		server->dtsize = server->rsize;
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4bfa7d8bcade..adef506c5786 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -707,7 +707,7 @@ void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
 	if (!desc->page->mapping)
 		nfs_readdir_clear_array(desc->page);
-	page_cache_release(desc->page);
+	put_page(desc->page);
 	desc->page = NULL;
 }
 
@@ -1923,7 +1923,7 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 		 * add_to_page_cache_lru() grabs an extra page refcount.
 		 * Drop it here to avoid leaking this page later.
 		 */
-		page_cache_release(page);
+		put_page(page);
 	} else
 		__free_page(page);
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 7a0cfd3266e5..c93826e4a8c6 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -269,7 +269,7 @@ static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 {
 	unsigned int i;
 	for (i = 0; i < npages; i++)
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 }
 
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
@@ -1003,7 +1003,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 		      iov_iter_count(iter));
 
 	pos = iocb->ki_pos;
-	end = (pos + iov_iter_count(iter) - 1) >> PAGE_CACHE_SHIFT;
+	end = (pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT;
 
 	inode_lock(inode);
 
@@ -1013,7 +1013,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 
 	if (mapping->nrpages) {
 		result = invalidate_inode_pages2_range(mapping,
-					pos >> PAGE_CACHE_SHIFT, end);
+					pos >> PAGE_SHIFT, end);
 		if (result)
 			goto out_unlock;
 	}
@@ -1042,7 +1042,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 
 	if (mapping->nrpages) {
 		invalidate_inode_pages2_range(mapping,
-					      pos >> PAGE_CACHE_SHIFT, end);
+					      pos >> PAGE_SHIFT, end);
 	}
 
 	inode_unlock(inode);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 748bb813b8ec..1ef3ac728ff4 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -318,7 +318,7 @@ static int nfs_want_read_modify_write(struct file *file, struct page *page,
 			loff_t pos, unsigned len)
 {
 	unsigned int pglen = nfs_page_length(page);
-	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned int offset = pos & (PAGE_SIZE - 1);
 	unsigned int end = offset + len;
 
 	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
@@ -349,7 +349,7 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 			struct page **pagep, void **fsdata)
 {
 	int ret;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	int once_thru = 0;
 
@@ -378,12 +378,12 @@ start:
 	ret = nfs_flush_incompatible(file, page);
 	if (ret) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	} else if (!once_thru &&
 		   nfs_want_read_modify_write(file, page, pos, len)) {
 		once_thru = 1;
 		ret = nfs_readpage(file, page);
-		page_cache_release(page);
+		put_page(page);
 		if (!ret)
 			goto start;
 	}
@@ -394,7 +394,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned offset = pos & (PAGE_SIZE - 1);
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	int status;
 
@@ -411,20 +411,20 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 		if (pglen == 0) {
 			zero_user_segments(page, 0, offset,
-					end, PAGE_CACHE_SIZE);
+					end, PAGE_SIZE);
 			SetPageUptodate(page);
 		} else if (end >= pglen) {
-			zero_user_segment(page, end, PAGE_CACHE_SIZE);
+			zero_user_segment(page, end, PAGE_SIZE);
 			if (offset == 0)
 				SetPageUptodate(page);
 		} else
-			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
+			zero_user_segment(page, pglen, PAGE_SIZE);
 	}
 
 	status = nfs_updatepage(file, page, offset, copied);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (status < 0)
 		return status;
@@ -452,7 +452,7 @@ static void nfs_invalidate_page(struct page *page, unsigned int offset,
 	dfprintk(PAGECACHE, "NFS: invalidate_page(%p, %u, %u)\n",
 		 page, offset, length);
 
-	if (offset != 0 || length < PAGE_CACHE_SIZE)
+	if (offset != 0 || length < PAGE_SIZE)
 		return;
 	/* Cancel any unstarted writes on this page */
 	nfs_wb_page_cancel(page_file_mapping(page)->host, page);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9a547aa3ec8e..dd822c9a052d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -642,11 +642,11 @@ unsigned int nfs_page_length(struct page *page)
 
 	if (i_size > 0) {
 		pgoff_t page_index = page_file_index(page);
-		pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
+		pgoff_t end_index = (i_size - 1) >> PAGE_SHIFT;
 		if (page_index < end_index)
-			return PAGE_CACHE_SIZE;
+			return PAGE_SIZE;
 		if (page_index == end_index)
-			return ((i_size - 1) & ~PAGE_CACHE_MASK) + 1;
+			return ((i_size - 1) & ~PAGE_MASK) + 1;
 	}
 	return 0;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e4441216804..88474a4fc669 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5001,7 +5001,7 @@ static int decode_space_limit(struct xdr_stream *xdr,
 		blocksize = be32_to_cpup(p);
 		maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
 	}
-	maxsize >>= PAGE_CACHE_SHIFT;
+	maxsize >>= PAGE_SHIFT;
 	*pagemod_limit = min_t(u64, maxsize, ULONG_MAX);
 	return 0;
 out_overflow:
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9aebffb40505..049c1b1f2932 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -486,7 +486,7 @@ static void __r4w_put_page(void *priv, struct page *page)
 	dprintk("%s: index=0x%lx\n", __func__,
 		(page == ZERO_PAGE(0)) ? -1UL : page->index);
 	if (ZERO_PAGE(0) != page)
-		page_cache_release(page);
+		put_page(page);
 	return;
 }
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8ce4f61cbaa5..1f6db4231057 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -342,7 +342,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
 	req->wb_index	= page_file_index(page);
-	page_cache_get(page);
+	get_page(page);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
@@ -392,7 +392,7 @@ static void nfs_clear_request(struct nfs_page *req)
 	struct nfs_lock_context *l_ctx = req->wb_lock_context;
 
 	if (page != NULL) {
-		page_cache_release(page);
+		put_page(page);
 		req->wb_page = NULL;
 	}
 	if (l_ctx != NULL) {
@@ -904,7 +904,7 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 				return false;
 		} else {
 			if (req->wb_pgbase != 0 ||
-			    prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
+			    prev->wb_pgbase + prev->wb_bytes != PAGE_SIZE)
 				return false;
 		}
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2fa483e6dbe2..89a5ef4df08a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -841,7 +841,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 		i_size = i_size_read(ino);
 
-		lgp->args.minlength = PAGE_CACHE_SIZE;
+		lgp->args.minlength = PAGE_SIZE;
 		if (lgp->args.minlength > range->length)
 			lgp->args.minlength = range->length;
 		if (range->iomode == IOMODE_READ) {
@@ -1618,13 +1618,13 @@ lookup_again:
 		spin_unlock(&clp->cl_lock);
 	}
 
-	pg_offset = arg.offset & ~PAGE_CACHE_MASK;
+	pg_offset = arg.offset & ~PAGE_MASK;
 	if (pg_offset) {
 		arg.offset -= pg_offset;
 		arg.length += pg_offset;
 	}
 	if (arg.length != NFS4_MAX_UINT64)
-		arg.length = PAGE_CACHE_ALIGN(arg.length);
+		arg.length = PAGE_ALIGN(arg.length);
 
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
 	atomic_dec(&lo->plh_outstanding);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index eb31e23e7def..6776d7a7839e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -46,7 +46,7 @@ static void nfs_readhdr_free(struct nfs_pgio_header *rhdr)
 static
 int nfs_return_empty_page(struct page *page)
 {
-	zero_user(page, 0, PAGE_CACHE_SIZE);
+	zero_user(page, 0, PAGE_SIZE);
 	SetPageUptodate(page);
 	unlock_page(page);
 	return 0;
@@ -118,8 +118,8 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		unlock_page(page);
 		return PTR_ERR(new);
 	}
-	if (len < PAGE_CACHE_SIZE)
-		zero_user_segment(page, len, PAGE_CACHE_SIZE);
+	if (len < PAGE_SIZE)
+		zero_user_segment(page, len, PAGE_SIZE);
 
 	nfs_pageio_init_read(&pgio, inode, false,
 			     &nfs_async_read_completion_ops);
@@ -295,7 +295,7 @@ int nfs_readpage(struct file *file, struct page *page)
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
-		page, PAGE_CACHE_SIZE, page_file_index(page));
+		page, PAGE_SIZE, page_file_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
 	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
@@ -361,8 +361,8 @@ readpage_async_filler(void *data, struct page *page)
 	if (IS_ERR(new))
 		goto out_error;
 
-	if (len < PAGE_CACHE_SIZE)
-		zero_user_segment(page, len, PAGE_CACHE_SIZE);
+	if (len < PAGE_SIZE)
+		zero_user_segment(page, len, PAGE_SIZE);
 	if (!nfs_pageio_add_request(desc->pgio, new)) {
 		nfs_list_remove_request(new);
 		nfs_readpage_release(new);
@@ -424,8 +424,8 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 
 	pgm = &pgio.pg_mirrors[0];
 	NFS_I(inode)->read_io += pgm->pg_bytes_written;
-	npages = (pgm->pg_bytes_written + PAGE_CACHE_SIZE - 1) >>
-		 PAGE_CACHE_SHIFT;
+	npages = (pgm->pg_bytes_written + PAGE_SIZE - 1) >>
+		 PAGE_SHIFT;
 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 read_complete:
 	put_nfs_open_context(desc.ctx);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5754835a2886..5f4fd53e5764 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -150,7 +150,7 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
 
 	spin_lock(&inode->i_lock);
 	i_size = i_size_read(inode);
-	end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
+	end_index = (i_size - 1) >> PAGE_SHIFT;
 	if (i_size > 0 && page_file_index(page) < end_index)
 		goto out;
 	end = page_file_offset(page) + ((loff_t)offset+count);
@@ -1942,7 +1942,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder)
 {
 	loff_t range_start = page_file_offset(page);
-	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
+	loff_t range_end = range_start + (loff_t)(PAGE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = 0,
diff --git a/fs/nilfs2/bmap.c b/fs/nilfs2/bmap.c
index 27f75bcbeb30..a9fb3636c142 100644
--- a/fs/nilfs2/bmap.c
+++ b/fs/nilfs2/bmap.c
@@ -458,7 +458,7 @@ __u64 nilfs_bmap_data_get_key(const struct nilfs_bmap *bmap,
 	struct buffer_head *pbh;
 	__u64 key;
 
-	key = page_index(bh->b_page) << (PAGE_CACHE_SHIFT -
+	key = page_index(bh->b_page) << (PAGE_SHIFT -
 					 bmap->b_inode->i_blkbits);
 	for (pbh = page_buffers(bh->b_page); pbh != bh; pbh = pbh->b_this_page)
 		key++;
diff --git a/fs/nilfs2/btnode.c b/fs/nilfs2/btnode.c
index a35ae35e6932..e0c9daf9aa22 100644
--- a/fs/nilfs2/btnode.c
+++ b/fs/nilfs2/btnode.c
@@ -62,7 +62,7 @@ nilfs_btnode_create_block(struct address_space *btnc, __u64 blocknr)
 	set_buffer_uptodate(bh);
 
 	unlock_page(bh->b_page);
-	page_cache_release(bh->b_page);
+	put_page(bh->b_page);
 	return bh;
 }
 
@@ -128,7 +128,7 @@ found:
 
 out_locked:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
@@ -146,7 +146,7 @@ void nilfs_btnode_delete(struct buffer_head *bh)
 	pgoff_t index = page_index(page);
 	int still_dirty;
 
-	page_cache_get(page);
+	get_page(page);
 	lock_page(page);
 	wait_on_page_writeback(page);
 
@@ -154,7 +154,7 @@ void nilfs_btnode_delete(struct buffer_head *bh)
 	still_dirty = PageDirty(page);
 	mapping = page->mapping;
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (!still_dirty && mapping)
 		invalidate_inode_pages2_range(mapping, index, index);
@@ -181,7 +181,7 @@ int nilfs_btnode_prepare_change_key(struct address_space *btnc,
 	obh = ctxt->bh;
 	ctxt->newbh = NULL;
 
-	if (inode->i_blkbits == PAGE_CACHE_SHIFT) {
+	if (inode->i_blkbits == PAGE_SHIFT) {
 		lock_page(obh->b_page);
 		/*
 		 * We cannot call radix_tree_preload for the kernels older
diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
index 6b8b92b19cec..e08f064e4bd7 100644
--- a/fs/nilfs2/dir.c
+++ b/fs/nilfs2/dir.c
@@ -58,7 +58,7 @@ static inline unsigned nilfs_chunk_size(struct inode *inode)
 static inline void nilfs_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -69,9 +69,9 @@ static unsigned nilfs_last_byte(struct inode *inode, unsigned long page_nr)
 {
 	unsigned last_byte = inode->i_size;
 
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << PAGE_SHIFT;
+	if (last_byte > PAGE_SIZE)
+		last_byte = PAGE_SIZE;
 	return last_byte;
 }
 
@@ -109,12 +109,12 @@ static void nilfs_check_page(struct page *page)
 	unsigned chunk_size = nilfs_chunk_size(dir);
 	char *kaddr = page_address(page);
 	unsigned offs, rec_len;
-	unsigned limit = PAGE_CACHE_SIZE;
+	unsigned limit = PAGE_SIZE;
 	struct nilfs_dir_entry *p;
 	char *error;
 
-	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
-		limit = dir->i_size & ~PAGE_CACHE_MASK;
+	if ((dir->i_size >> PAGE_SHIFT) == page->index) {
+		limit = dir->i_size & ~PAGE_MASK;
 		if (limit & (chunk_size - 1))
 			goto Ebadsize;
 		if (!limit)
@@ -161,7 +161,7 @@ Espan:
 bad_entry:
 	nilfs_error(sb, "nilfs_check_page", "bad entry in directory #%lu: %s - "
 		    "offset=%lu, inode=%lu, rec_len=%d, name_len=%d",
-		    dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		    dir->i_ino, error, (page->index<<PAGE_SHIFT)+offs,
 		    (unsigned long) le64_to_cpu(p->inode),
 		    rec_len, p->name_len);
 	goto fail;
@@ -170,7 +170,7 @@ Eend:
 	nilfs_error(sb, "nilfs_check_page",
 		    "entry in directory #%lu spans the page boundary"
 		    "offset=%lu, inode=%lu",
-		    dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		    dir->i_ino, (page->index<<PAGE_SHIFT)+offs,
 		    (unsigned long) le64_to_cpu(p->inode));
 fail:
 	SetPageChecked(page);
@@ -256,8 +256,8 @@ static int nilfs_readdir(struct file *file, struct dir_context *ctx)
 	loff_t pos = ctx->pos;
 	struct inode *inode = file_inode(file);
 	struct super_block *sb = inode->i_sb;
-	unsigned int offset = pos & ~PAGE_CACHE_MASK;
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
+	unsigned int offset = pos & ~PAGE_MASK;
+	unsigned long n = pos >> PAGE_SHIFT;
 	unsigned long npages = dir_pages(inode);
 /*	unsigned chunk_mask = ~(nilfs_chunk_size(inode)-1); */
 
@@ -272,7 +272,7 @@ static int nilfs_readdir(struct file *file, struct dir_context *ctx)
 		if (IS_ERR(page)) {
 			nilfs_error(sb, __func__, "bad page in #%lu",
 				    inode->i_ino);
-			ctx->pos += PAGE_CACHE_SIZE - offset;
+			ctx->pos += PAGE_SIZE - offset;
 			return -EIO;
 		}
 		kaddr = page_address(page);
@@ -361,7 +361,7 @@ nilfs_find_entry(struct inode *dir, const struct qstr *qstr,
 		if (++n >= npages)
 			n = 0;
 		/* next page is past the blocks we've got */
-		if (unlikely(n > (dir->i_blocks >> (PAGE_CACHE_SHIFT - 9)))) {
+		if (unlikely(n > (dir->i_blocks >> (PAGE_SHIFT - 9)))) {
 			nilfs_error(dir->i_sb, __func__,
 			       "dir %lu size %lld exceeds block count %llu",
 			       dir->i_ino, dir->i_size,
@@ -401,7 +401,7 @@ ino_t nilfs_inode_by_name(struct inode *dir, const struct qstr *qstr)
 	if (de) {
 		res = le64_to_cpu(de->inode);
 		kunmap(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return res;
 }
@@ -460,7 +460,7 @@ int nilfs_add_link(struct dentry *dentry, struct inode *inode)
 		kaddr = page_address(page);
 		dir_end = kaddr + nilfs_last_byte(dir, n);
 		de = (struct nilfs_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - reclen;
+		kaddr += PAGE_SIZE - reclen;
 		while ((char *)de <= kaddr) {
 			if ((char *)de == dir_end) {
 				/* We hit i_size */
@@ -603,7 +603,7 @@ int nilfs_make_empty(struct inode *inode, struct inode *parent)
 	kunmap_atomic(kaddr);
 	nilfs_commit_chunk(page, mapping, 0, chunk_size);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/nilfs2/gcinode.c b/fs/nilfs2/gcinode.c
index 748ca238915a..0224b7826ace 100644
--- a/fs/nilfs2/gcinode.c
+++ b/fs/nilfs2/gcinode.c
@@ -115,7 +115,7 @@ int nilfs_gccache_submit_read_data(struct inode *inode, sector_t blkoff,
 
  failed:
 	unlock_page(bh->b_page);
-	page_cache_release(bh->b_page);
+	put_page(bh->b_page);
 	return err;
 }
 
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 21a1e2e0d92f..534631358b13 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -249,7 +249,7 @@ static int nilfs_set_page_dirty(struct page *page)
 		if (nr_dirty)
 			nilfs_set_file_dirty(inode, nr_dirty);
 	} else if (ret) {
-		unsigned nr_dirty = 1 << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		unsigned nr_dirty = 1 << (PAGE_SHIFT - inode->i_blkbits);
 
 		nilfs_set_file_dirty(inode, nr_dirty);
 	}
@@ -291,7 +291,7 @@ static int nilfs_write_end(struct file *file, struct address_space *mapping,
 			   struct page *page, void *fsdata)
 {
 	struct inode *inode = mapping->host;
-	unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned start = pos & (PAGE_SIZE - 1);
 	unsigned nr_dirty;
 	int err;
 
diff --git a/fs/nilfs2/mdt.c b/fs/nilfs2/mdt.c
index 1125f40233ff..f6982b9153d5 100644
--- a/fs/nilfs2/mdt.c
+++ b/fs/nilfs2/mdt.c
@@ -110,7 +110,7 @@ static int nilfs_mdt_create_block(struct inode *inode, unsigned long block,
 
  failed_bh:
 	unlock_page(bh->b_page);
-	page_cache_release(bh->b_page);
+	put_page(bh->b_page);
 	brelse(bh);
 
  failed_unlock:
@@ -170,7 +170,7 @@ nilfs_mdt_submit_block(struct inode *inode, unsigned long blkoff,
 
  failed_bh:
 	unlock_page(bh->b_page);
-	page_cache_release(bh->b_page);
+	put_page(bh->b_page);
 	brelse(bh);
  failed:
 	return ret;
@@ -363,7 +363,7 @@ int nilfs_mdt_delete_block(struct inode *inode, unsigned long block)
 int nilfs_mdt_forget_block(struct inode *inode, unsigned long block)
 {
 	pgoff_t index = (pgoff_t)block >>
-		(PAGE_CACHE_SHIFT - inode->i_blkbits);
+		(PAGE_SHIFT - inode->i_blkbits);
 	struct page *page;
 	unsigned long first_block;
 	int ret = 0;
@@ -376,7 +376,7 @@ int nilfs_mdt_forget_block(struct inode *inode, unsigned long block)
 	wait_on_page_writeback(page);
 
 	first_block = (unsigned long)index <<
-		(PAGE_CACHE_SHIFT - inode->i_blkbits);
+		(PAGE_SHIFT - inode->i_blkbits);
 	if (page_has_buffers(page)) {
 		struct buffer_head *bh;
 
@@ -385,7 +385,7 @@ int nilfs_mdt_forget_block(struct inode *inode, unsigned long block)
 	}
 	still_dirty = PageDirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (still_dirty ||
 	    invalidate_inode_pages2_range(inode->i_mapping, index, index) != 0)
@@ -578,7 +578,7 @@ int nilfs_mdt_freeze_buffer(struct inode *inode, struct buffer_head *bh)
 	}
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return 0;
 }
 
@@ -597,7 +597,7 @@ nilfs_mdt_get_frozen_buffer(struct inode *inode, struct buffer_head *bh)
 			bh_frozen = nilfs_page_get_nth_block(page, n);
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return bh_frozen;
 }
diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
index 7ccdb961eea9..151bc19d47c0 100644
--- a/fs/nilfs2/namei.c
+++ b/fs/nilfs2/namei.c
@@ -431,11 +431,11 @@ static int nilfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 out_dir:
 	if (dir_de) {
 		kunmap(dir_page);
-		page_cache_release(dir_page);
+		put_page(dir_page);
 	}
 out_old:
 	kunmap(old_page);
-	page_cache_release(old_page);
+	put_page(old_page);
 out:
 	nilfs_transaction_abort(old_dir->i_sb);
 	return err;
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index c20df77eff99..489391561cda 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -50,7 +50,7 @@ __nilfs_get_page_block(struct page *page, unsigned long block, pgoff_t index,
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, 1 << blkbits, b_state);
 
-	first_block = (unsigned long)index << (PAGE_CACHE_SHIFT - blkbits);
+	first_block = (unsigned long)index << (PAGE_SHIFT - blkbits);
 	bh = nilfs_page_get_nth_block(page, block - first_block);
 
 	touch_buffer(bh);
@@ -64,7 +64,7 @@ struct buffer_head *nilfs_grab_buffer(struct inode *inode,
 				      unsigned long b_state)
 {
 	int blkbits = inode->i_blkbits;
-	pgoff_t index = blkoff >> (PAGE_CACHE_SHIFT - blkbits);
+	pgoff_t index = blkoff >> (PAGE_SHIFT - blkbits);
 	struct page *page;
 	struct buffer_head *bh;
 
@@ -75,7 +75,7 @@ struct buffer_head *nilfs_grab_buffer(struct inode *inode,
 	bh = __nilfs_get_page_block(page, blkoff, index, blkbits, b_state);
 	if (unlikely(!bh)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return NULL;
 	}
 	return bh;
@@ -288,7 +288,7 @@ repeat:
 		__set_page_dirty_nobuffers(dpage);
 
 		unlock_page(dpage);
-		page_cache_release(dpage);
+		put_page(dpage);
 		unlock_page(page);
 	}
 	pagevec_release(&pvec);
@@ -333,7 +333,7 @@ repeat:
 			WARN_ON(PageDirty(dpage));
 			nilfs_copy_page(dpage, page, 0);
 			unlock_page(dpage);
-			page_cache_release(dpage);
+			put_page(dpage);
 		} else {
 			struct page *page2;
 
@@ -350,7 +350,7 @@ repeat:
 			if (unlikely(err < 0)) {
 				WARN_ON(err == -EEXIST);
 				page->mapping = NULL;
-				page_cache_release(page); /* for cache */
+				put_page(page); /* for cache */
 			} else {
 				page->mapping = dmap;
 				dmap->nrpages++;
@@ -523,8 +523,8 @@ unsigned long nilfs_find_uncommitted_extent(struct inode *inode,
 	if (inode->i_mapping->nrpages == 0)
 		return 0;
 
-	index = start_blk >> (PAGE_CACHE_SHIFT - inode->i_blkbits);
-	nblocks_in_page = 1U << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	index = start_blk >> (PAGE_SHIFT - inode->i_blkbits);
+	nblocks_in_page = 1U << (PAGE_SHIFT - inode->i_blkbits);
 
 	pagevec_init(&pvec, 0);
 
@@ -537,7 +537,7 @@ repeat:
 	if (length > 0 && pvec.pages[0]->index > index)
 		goto out;
 
-	b = pvec.pages[0]->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	b = pvec.pages[0]->index << (PAGE_SHIFT - inode->i_blkbits);
 	i = 0;
 	do {
 		page = pvec.pages[i];
diff --git a/fs/nilfs2/recovery.c b/fs/nilfs2/recovery.c
index 9b4f205d1173..5afa77fadc11 100644
--- a/fs/nilfs2/recovery.c
+++ b/fs/nilfs2/recovery.c
@@ -544,14 +544,14 @@ static int nilfs_recover_dsync_blocks(struct the_nilfs *nilfs,
 				blocksize, page, NULL);
 
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		(*nr_salvaged_blocks)++;
 		goto next;
 
  failed_page:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
  failed_inode:
 		printk(KERN_WARNING
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index 3b65adaae7e4..4317f72568e6 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -2070,7 +2070,7 @@ static int nilfs_segctor_do_construct(struct nilfs_sc_info *sci, int mode)
 			goto failed_to_write;
 
 		if (nilfs_sc_cstage_get(sci) == NILFS_ST_DONE ||
-		    nilfs->ns_blocksize_bits != PAGE_CACHE_SHIFT) {
+		    nilfs->ns_blocksize_bits != PAGE_SHIFT) {
 			/*
 			 * At this point, we avoid double buffering
 			 * for blocksize < pagesize because page dirty
diff --git a/fs/ntfs/aops.c b/fs/ntfs/aops.c
index 7521e11db728..a474e7ef92ea 100644
--- a/fs/ntfs/aops.c
+++ b/fs/ntfs/aops.c
@@ -74,7 +74,7 @@ static void ntfs_end_buffer_async_read(struct buffer_head *bh, int uptodate)
 
 		set_buffer_uptodate(bh);
 
-		file_ofs = ((s64)page->index << PAGE_CACHE_SHIFT) +
+		file_ofs = ((s64)page->index << PAGE_SHIFT) +
 				bh_offset(bh);
 		read_lock_irqsave(&ni->size_lock, flags);
 		init_size = ni->initialized_size;
@@ -142,7 +142,7 @@ static void ntfs_end_buffer_async_read(struct buffer_head *bh, int uptodate)
 		u32 rec_size;
 
 		rec_size = ni->itype.index.block_size;
-		recs = PAGE_CACHE_SIZE / rec_size;
+		recs = PAGE_SIZE / rec_size;
 		/* Should have been verified before we got here... */
 		BUG_ON(!recs);
 		local_irq_save(flags);
@@ -229,7 +229,7 @@ static int ntfs_read_block(struct page *page)
 	 * fully truncated, truncate will throw it away as soon as we unlock
 	 * it so no need to worry what we do with it.
 	 */
-	iblock = (s64)page->index << (PAGE_CACHE_SHIFT - blocksize_bits);
+	iblock = (s64)page->index << (PAGE_SHIFT - blocksize_bits);
 	read_lock_irqsave(&ni->size_lock, flags);
 	lblock = (ni->allocated_size + blocksize - 1) >> blocksize_bits;
 	init_size = ni->initialized_size;
@@ -412,9 +412,9 @@ retry_readpage:
 	vi = page->mapping->host;
 	i_size = i_size_read(vi);
 	/* Is the page fully outside i_size? (truncate in progress) */
-	if (unlikely(page->index >= (i_size + PAGE_CACHE_SIZE - 1) >>
-			PAGE_CACHE_SHIFT)) {
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+	if (unlikely(page->index >= (i_size + PAGE_SIZE - 1) >>
+			PAGE_SHIFT)) {
+		zero_user(page, 0, PAGE_SIZE);
 		ntfs_debug("Read outside i_size - truncated?");
 		goto done;
 	}
@@ -463,7 +463,7 @@ retry_readpage:
 	 * ok to ignore the compressed flag here.
 	 */
 	if (unlikely(page->index > 0)) {
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+		zero_user(page, 0, PAGE_SIZE);
 		goto done;
 	}
 	if (!NInoAttr(ni))
@@ -509,7 +509,7 @@ retry_readpage:
 			le16_to_cpu(ctx->attr->data.resident.value_offset),
 			attr_len);
 	/* Zero the remainder of the page. */
-	memset(addr + attr_len, 0, PAGE_CACHE_SIZE - attr_len);
+	memset(addr + attr_len, 0, PAGE_SIZE - attr_len);
 	flush_dcache_page(page);
 	kunmap_atomic(addr);
 put_unm_err_out:
@@ -599,7 +599,7 @@ static int ntfs_write_block(struct page *page, struct writeback_control *wbc)
 	/* NOTE: Different naming scheme to ntfs_read_block()! */
 
 	/* The first block in the page. */
-	block = (s64)page->index << (PAGE_CACHE_SHIFT - blocksize_bits);
+	block = (s64)page->index << (PAGE_SHIFT - blocksize_bits);
 
 	read_lock_irqsave(&ni->size_lock, flags);
 	i_size = i_size_read(vi);
@@ -925,7 +925,7 @@ static int ntfs_write_mst_block(struct page *page,
 	ntfs_volume *vol = ni->vol;
 	u8 *kaddr;
 	unsigned int rec_size = ni->itype.index.block_size;
-	ntfs_inode *locked_nis[PAGE_CACHE_SIZE / rec_size];
+	ntfs_inode *locked_nis[PAGE_SIZE / rec_size];
 	struct buffer_head *bh, *head, *tbh, *rec_start_bh;
 	struct buffer_head *bhs[MAX_BUF_PER_PAGE];
 	runlist_element *rl;
@@ -949,7 +949,7 @@ static int ntfs_write_mst_block(struct page *page,
 			(NInoAttr(ni) && ni->type == AT_INDEX_ALLOCATION)));
 	bh_size = vol->sb->s_blocksize;
 	bh_size_bits = vol->sb->s_blocksize_bits;
-	max_bhs = PAGE_CACHE_SIZE / bh_size;
+	max_bhs = PAGE_SIZE / bh_size;
 	BUG_ON(!max_bhs);
 	BUG_ON(max_bhs > MAX_BUF_PER_PAGE);
 
@@ -961,13 +961,13 @@ static int ntfs_write_mst_block(struct page *page,
 	BUG_ON(!bh);
 
 	rec_size_bits = ni->itype.index.block_size_bits;
-	BUG_ON(!(PAGE_CACHE_SIZE >> rec_size_bits));
+	BUG_ON(!(PAGE_SIZE >> rec_size_bits));
 	bhs_per_rec = rec_size >> bh_size_bits;
 	BUG_ON(!bhs_per_rec);
 
 	/* The first block in the page. */
 	rec_block = block = (sector_t)page->index <<
-			(PAGE_CACHE_SHIFT - bh_size_bits);
+			(PAGE_SHIFT - bh_size_bits);
 
 	/* The first out of bounds block for the data size. */
 	dblock = (i_size_read(vi) + bh_size - 1) >> bh_size_bits;
@@ -1133,7 +1133,7 @@ lock_retry_remap:
 			unsigned long mft_no;
 
 			/* Get the mft record number. */
-			mft_no = (((s64)page->index << PAGE_CACHE_SHIFT) + ofs)
+			mft_no = (((s64)page->index << PAGE_SHIFT) + ofs)
 					>> rec_size_bits;
 			/* Check whether to write this mft record. */
 			tni = NULL;
@@ -1249,7 +1249,7 @@ do_mirror:
 				continue;
 			ofs = bh_offset(tbh);
 			/* Get the mft record number. */
-			mft_no = (((s64)page->index << PAGE_CACHE_SHIFT) + ofs)
+			mft_no = (((s64)page->index << PAGE_SHIFT) + ofs)
 					>> rec_size_bits;
 			if (mft_no < vol->mftmirr_size)
 				ntfs_sync_mft_mirror(vol, mft_no,
@@ -1300,7 +1300,7 @@ done:
 		 * Set page error if there is only one ntfs record in the page.
 		 * Otherwise we would loose per-record granularity.
 		 */
-		if (ni->itype.index.block_size == PAGE_CACHE_SIZE)
+		if (ni->itype.index.block_size == PAGE_SIZE)
 			SetPageError(page);
 		NVolSetErrors(vol);
 	}
@@ -1308,7 +1308,7 @@ done:
 		ntfs_debug("Page still contains one or more dirty ntfs "
 				"records.  Redirtying the page starting at "
 				"record 0x%lx.", page->index <<
-				(PAGE_CACHE_SHIFT - rec_size_bits));
+				(PAGE_SHIFT - rec_size_bits));
 		redirty_page_for_writepage(wbc, page);
 		unlock_page(page);
 	} else {
@@ -1365,13 +1365,13 @@ retry_writepage:
 	BUG_ON(!PageLocked(page));
 	i_size = i_size_read(vi);
 	/* Is the page fully outside i_size? (truncate in progress) */
-	if (unlikely(page->index >= (i_size + PAGE_CACHE_SIZE - 1) >>
-			PAGE_CACHE_SHIFT)) {
+	if (unlikely(page->index >= (i_size + PAGE_SIZE - 1) >>
+			PAGE_SHIFT)) {
 		/*
 		 * The page may have dirty, unmapped buffers.  Make them
 		 * freeable here, so the page does not leak.
 		 */
-		block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		block_invalidatepage(page, 0, PAGE_SIZE);
 		unlock_page(page);
 		ntfs_debug("Write outside i_size - truncated?");
 		return 0;
@@ -1414,10 +1414,10 @@ retry_writepage:
 	/* NInoNonResident() == NInoIndexAllocPresent() */
 	if (NInoNonResident(ni)) {
 		/* We have to zero every time due to mmap-at-end-of-file. */
-		if (page->index >= (i_size >> PAGE_CACHE_SHIFT)) {
+		if (page->index >= (i_size >> PAGE_SHIFT)) {
 			/* The page straddles i_size. */
-			unsigned int ofs = i_size & ~PAGE_CACHE_MASK;
-			zero_user_segment(page, ofs, PAGE_CACHE_SIZE);
+			unsigned int ofs = i_size & ~PAGE_MASK;
+			zero_user_segment(page, ofs, PAGE_SIZE);
 		}
 		/* Handle mst protected attributes. */
 		if (NInoMstProtected(ni))
@@ -1500,7 +1500,7 @@ retry_writepage:
 			le16_to_cpu(ctx->attr->data.resident.value_offset),
 			addr, attr_len);
 	/* Zero out of bounds area in the page cache page. */
-	memset(addr + attr_len, 0, PAGE_CACHE_SIZE - attr_len);
+	memset(addr + attr_len, 0, PAGE_SIZE - attr_len);
 	kunmap_atomic(addr);
 	flush_dcache_page(page);
 	flush_dcache_mft_record_page(ctx->ntfs_ino);
diff --git a/fs/ntfs/aops.h b/fs/ntfs/aops.h
index caecc58f529c..37cd7e45dcbc 100644
--- a/fs/ntfs/aops.h
+++ b/fs/ntfs/aops.h
@@ -40,7 +40,7 @@
 static inline void ntfs_unmap_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /**
diff --git a/fs/ntfs/attrib.c b/fs/ntfs/attrib.c
index 250ed5b20c8f..44a39a099b54 100644
--- a/fs/ntfs/attrib.c
+++ b/fs/ntfs/attrib.c
@@ -152,7 +152,7 @@ int ntfs_map_runlist_nolock(ntfs_inode *ni, VCN vcn, ntfs_attr_search_ctx *ctx)
 			if (old_ctx.base_ntfs_ino && old_ctx.ntfs_ino !=
 					old_ctx.base_ntfs_ino) {
 				put_this_page = old_ctx.ntfs_ino->page;
-				page_cache_get(put_this_page);
+				get_page(put_this_page);
 			}
 			/*
 			 * Reinitialize the search context so we can lookup the
@@ -275,7 +275,7 @@ retry_map:
 		 * the pieces anyway.
 		 */
 		if (put_this_page)
-			page_cache_release(put_this_page);
+			put_page(put_this_page);
 	}
 	return err;
 }
@@ -1660,7 +1660,7 @@ int ntfs_attr_make_non_resident(ntfs_inode *ni, const u32 data_size)
 		memcpy(kaddr, (u8*)a +
 				le16_to_cpu(a->data.resident.value_offset),
 				attr_size);
-		memset(kaddr + attr_size, 0, PAGE_CACHE_SIZE - attr_size);
+		memset(kaddr + attr_size, 0, PAGE_SIZE - attr_size);
 		kunmap_atomic(kaddr);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
@@ -1748,7 +1748,7 @@ int ntfs_attr_make_non_resident(ntfs_inode *ni, const u32 data_size)
 	if (page) {
 		set_page_dirty(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	ntfs_debug("Done.");
 	return 0;
@@ -1835,7 +1835,7 @@ rl_err_out:
 		ntfs_free(rl);
 page_err_out:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (err == -EINVAL)
 		err = -EIO;
@@ -2513,17 +2513,17 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 	BUG_ON(NInoEncrypted(ni));
 	mapping = VFS_I(ni)->i_mapping;
 	/* Work out the starting index and page offset. */
-	idx = ofs >> PAGE_CACHE_SHIFT;
-	start_ofs = ofs & ~PAGE_CACHE_MASK;
+	idx = ofs >> PAGE_SHIFT;
+	start_ofs = ofs & ~PAGE_MASK;
 	/* Work out the ending index and page offset. */
 	end = ofs + cnt;
-	end_ofs = end & ~PAGE_CACHE_MASK;
+	end_ofs = end & ~PAGE_MASK;
 	/* If the end is outside the inode size return -ESPIPE. */
 	if (unlikely(end > i_size_read(VFS_I(ni)))) {
 		ntfs_error(vol->sb, "Request exceeds end of attribute.");
 		return -ESPIPE;
 	}
-	end >>= PAGE_CACHE_SHIFT;
+	end >>= PAGE_SHIFT;
 	/* If there is a first partial page, need to do it the slow way. */
 	if (start_ofs) {
 		page = read_mapping_page(mapping, idx, NULL);
@@ -2536,7 +2536,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		 * If the last page is the same as the first page, need to
 		 * limit the write to the end offset.
 		 */
-		size = PAGE_CACHE_SIZE;
+		size = PAGE_SIZE;
 		if (idx == end)
 			size = end_ofs;
 		kaddr = kmap_atomic(page);
@@ -2544,7 +2544,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
 		set_page_dirty(page);
-		page_cache_release(page);
+		put_page(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
 		if (idx == end)
@@ -2561,7 +2561,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 			return -ENOMEM;
 		}
 		kaddr = kmap_atomic(page);
-		memset(kaddr, val, PAGE_CACHE_SIZE);
+		memset(kaddr, val, PAGE_SIZE);
 		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
 		/*
@@ -2585,7 +2585,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		set_page_dirty(page);
 		/* Finally unlock and release the page. */
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
 	}
@@ -2602,7 +2602,7 @@ int ntfs_attr_set(ntfs_inode *ni, const s64 ofs, const s64 cnt, const u8 val)
 		flush_dcache_page(page);
 		kunmap_atomic(kaddr);
 		set_page_dirty(page);
-		page_cache_release(page);
+		put_page(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
 	}
diff --git a/fs/ntfs/bitmap.c b/fs/ntfs/bitmap.c
index 0809cf876098..ec130c588d2b 100644
--- a/fs/ntfs/bitmap.c
+++ b/fs/ntfs/bitmap.c
@@ -67,8 +67,8 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 	 * Calculate the indices for the pages containing the first and last
 	 * bits, i.e. @start_bit and @start_bit + @cnt - 1, respectively.
 	 */
-	index = start_bit >> (3 + PAGE_CACHE_SHIFT);
-	end_index = (start_bit + cnt - 1) >> (3 + PAGE_CACHE_SHIFT);
+	index = start_bit >> (3 + PAGE_SHIFT);
+	end_index = (start_bit + cnt - 1) >> (3 + PAGE_SHIFT);
 
 	/* Get the page containing the first bit (@start_bit). */
 	mapping = vi->i_mapping;
@@ -82,7 +82,7 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 	kaddr = page_address(page);
 
 	/* Set @pos to the position of the byte containing @start_bit. */
-	pos = (start_bit >> 3) & ~PAGE_CACHE_MASK;
+	pos = (start_bit >> 3) & ~PAGE_MASK;
 
 	/* Calculate the position of @start_bit in the first byte. */
 	bit = start_bit & 7;
@@ -108,7 +108,7 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 	 * Depending on @value, modify all remaining whole bytes in the page up
 	 * to @cnt.
 	 */
-	len = min_t(s64, cnt >> 3, PAGE_CACHE_SIZE - pos);
+	len = min_t(s64, cnt >> 3, PAGE_SIZE - pos);
 	memset(kaddr + pos, value ? 0xff : 0, len);
 	cnt -= len << 3;
 
@@ -132,7 +132,7 @@ int __ntfs_bitmap_set_bits_in_run(struct inode *vi, const s64 start_bit,
 		 * Depending on @value, modify all remaining whole bytes in the
 		 * page up to @cnt.
 		 */
-		len = min_t(s64, cnt >> 3, PAGE_CACHE_SIZE);
+		len = min_t(s64, cnt >> 3, PAGE_SIZE);
 		memset(kaddr, value ? 0xff : 0, len);
 		cnt -= len << 3;
 	}
diff --git a/fs/ntfs/compress.c b/fs/ntfs/compress.c
index f82498c35e78..b6074a56661b 100644
--- a/fs/ntfs/compress.c
+++ b/fs/ntfs/compress.c
@@ -104,7 +104,7 @@ static void zero_partial_compressed_page(struct page *page,
 	unsigned int kp_ofs;
 
 	ntfs_debug("Zeroing page region outside initialized size.");
-	if (((s64)page->index << PAGE_CACHE_SHIFT) >= initialized_size) {
+	if (((s64)page->index << PAGE_SHIFT) >= initialized_size) {
 		/*
 		 * FIXME: Using clear_page() will become wrong when we get
 		 * PAGE_CACHE_SIZE != PAGE_SIZE but for now there is no problem.
@@ -112,8 +112,8 @@ static void zero_partial_compressed_page(struct page *page,
 		clear_page(kp);
 		return;
 	}
-	kp_ofs = initialized_size & ~PAGE_CACHE_MASK;
-	memset(kp + kp_ofs, 0, PAGE_CACHE_SIZE - kp_ofs);
+	kp_ofs = initialized_size & ~PAGE_MASK;
+	memset(kp + kp_ofs, 0, PAGE_SIZE - kp_ofs);
 	return;
 }
 
@@ -123,7 +123,7 @@ static void zero_partial_compressed_page(struct page *page,
 static inline void handle_bounds_compressed_page(struct page *page,
 		const loff_t i_size, const s64 initialized_size)
 {
-	if ((page->index >= (initialized_size >> PAGE_CACHE_SHIFT)) &&
+	if ((page->index >= (initialized_size >> PAGE_SHIFT)) &&
 			(initialized_size < i_size))
 		zero_partial_compressed_page(page, initialized_size);
 	return;
@@ -241,7 +241,7 @@ return_error:
 				if (di == xpage)
 					*xpage_done = 1;
 				else
-					page_cache_release(dp);
+					put_page(dp);
 				dest_pages[di] = NULL;
 			}
 		}
@@ -274,7 +274,7 @@ return_error:
 		cb = cb_sb_end;
 
 		/* Advance destination position to next sub-block. */
-		*dest_ofs = (*dest_ofs + NTFS_SB_SIZE) & ~PAGE_CACHE_MASK;
+		*dest_ofs = (*dest_ofs + NTFS_SB_SIZE) & ~PAGE_MASK;
 		if (!*dest_ofs && (++*dest_index > dest_max_index))
 			goto return_overflow;
 		goto do_next_sb;
@@ -301,7 +301,7 @@ return_error:
 
 		/* Advance destination position to next sub-block. */
 		*dest_ofs += NTFS_SB_SIZE;
-		if (!(*dest_ofs &= ~PAGE_CACHE_MASK)) {
+		if (!(*dest_ofs &= ~PAGE_MASK)) {
 finalize_page:
 			/*
 			 * First stage: add current page index to array of
@@ -335,7 +335,7 @@ do_next_tag:
 			*dest_ofs += nr_bytes;
 		}
 		/* We have finished the current sub-block. */
-		if (!(*dest_ofs &= ~PAGE_CACHE_MASK))
+		if (!(*dest_ofs &= ~PAGE_MASK))
 			goto finalize_page;
 		goto do_next_sb;
 	}
@@ -498,13 +498,13 @@ int ntfs_read_compressed_block(struct page *page)
 	VCN vcn;
 	LCN lcn;
 	/* The first wanted vcn (minimum alignment is PAGE_CACHE_SIZE). */
-	VCN start_vcn = (((s64)index << PAGE_CACHE_SHIFT) & ~cb_size_mask) >>
+	VCN start_vcn = (((s64)index << PAGE_SHIFT) & ~cb_size_mask) >>
 			vol->cluster_size_bits;
 	/*
 	 * The first vcn after the last wanted vcn (minimum alignment is again
 	 * PAGE_CACHE_SIZE.
 	 */
-	VCN end_vcn = ((((s64)(index + 1UL) << PAGE_CACHE_SHIFT) + cb_size - 1)
+	VCN end_vcn = ((((s64)(index + 1UL) << PAGE_SHIFT) + cb_size - 1)
 			& ~cb_size_mask) >> vol->cluster_size_bits;
 	/* Number of compression blocks (cbs) in the wanted vcn range. */
 	unsigned int nr_cbs = (end_vcn - start_vcn) << vol->cluster_size_bits
@@ -515,7 +515,7 @@ int ntfs_read_compressed_block(struct page *page)
 	 * guarantees of start_vcn and end_vcn, no need to round up here.
 	 */
 	unsigned int nr_pages = (end_vcn - start_vcn) <<
-			vol->cluster_size_bits >> PAGE_CACHE_SHIFT;
+			vol->cluster_size_bits >> PAGE_SHIFT;
 	unsigned int xpage, max_page, cur_page, cur_ofs, i;
 	unsigned int cb_clusters, cb_max_ofs;
 	int block, max_block, cb_max_page, bhs_size, nr_bhs, err = 0;
@@ -549,7 +549,7 @@ int ntfs_read_compressed_block(struct page *page)
 	 * We have already been given one page, this is the one we must do.
 	 * Once again, the alignment guarantees keep it simple.
 	 */
-	offset = start_vcn << vol->cluster_size_bits >> PAGE_CACHE_SHIFT;
+	offset = start_vcn << vol->cluster_size_bits >> PAGE_SHIFT;
 	xpage = index - offset;
 	pages[xpage] = page;
 	/*
@@ -560,13 +560,13 @@ int ntfs_read_compressed_block(struct page *page)
 	i_size = i_size_read(VFS_I(ni));
 	initialized_size = ni->initialized_size;
 	read_unlock_irqrestore(&ni->size_lock, flags);
-	max_page = ((i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT) -
+	max_page = ((i_size + PAGE_SIZE - 1) >> PAGE_SHIFT) -
 			offset;
 	/* Is the page fully outside i_size? (truncate in progress) */
 	if (xpage >= max_page) {
 		kfree(bhs);
 		kfree(pages);
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+		zero_user(page, 0, PAGE_SIZE);
 		ntfs_debug("Compressed read outside i_size - truncated?");
 		SetPageUptodate(page);
 		unlock_page(page);
@@ -591,7 +591,7 @@ int ntfs_read_compressed_block(struct page *page)
 				continue;
 			}
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			pages[i] = NULL;
 		}
 	}
@@ -735,9 +735,9 @@ lock_retry_remap:
 	ntfs_debug("Successfully read the compression block.");
 
 	/* The last page and maximum offset within it for the current cb. */
-	cb_max_page = (cur_page << PAGE_CACHE_SHIFT) + cur_ofs + cb_size;
-	cb_max_ofs = cb_max_page & ~PAGE_CACHE_MASK;
-	cb_max_page >>= PAGE_CACHE_SHIFT;
+	cb_max_page = (cur_page << PAGE_SHIFT) + cur_ofs + cb_size;
+	cb_max_ofs = cb_max_page & ~PAGE_MASK;
+	cb_max_page >>= PAGE_SHIFT;
 
 	/* Catch end of file inside a compression block. */
 	if (cb_max_page > max_page)
@@ -762,7 +762,7 @@ lock_retry_remap:
 					clear_page(page_address(page));
 				else
 					memset(page_address(page) + cur_ofs, 0,
-							PAGE_CACHE_SIZE -
+							PAGE_SIZE -
 							cur_ofs);
 				flush_dcache_page(page);
 				kunmap(page);
@@ -771,10 +771,10 @@ lock_retry_remap:
 				if (cur_page == xpage)
 					xpage_done = 1;
 				else
-					page_cache_release(page);
+					put_page(page);
 				pages[cur_page] = NULL;
 			}
-			cb_pos += PAGE_CACHE_SIZE - cur_ofs;
+			cb_pos += PAGE_SIZE - cur_ofs;
 			cur_ofs = 0;
 			if (cb_pos >= cb_end)
 				break;
@@ -816,8 +816,8 @@ lock_retry_remap:
 			page = pages[cur_page];
 			if (page)
 				memcpy(page_address(page) + cur_ofs, cb_pos,
-						PAGE_CACHE_SIZE - cur_ofs);
-			cb_pos += PAGE_CACHE_SIZE - cur_ofs;
+						PAGE_SIZE - cur_ofs);
+			cb_pos += PAGE_SIZE - cur_ofs;
 			cur_ofs = 0;
 			if (cb_pos >= cb_end)
 				break;
@@ -850,10 +850,10 @@ lock_retry_remap:
 				if (cur2_page == xpage)
 					xpage_done = 1;
 				else
-					page_cache_release(page);
+					put_page(page);
 				pages[cur2_page] = NULL;
 			}
-			cb_pos2 += PAGE_CACHE_SIZE - cur_ofs2;
+			cb_pos2 += PAGE_SIZE - cur_ofs2;
 			cur_ofs2 = 0;
 			if (cb_pos2 >= cb_end)
 				break;
@@ -884,7 +884,7 @@ lock_retry_remap:
 					kunmap(page);
 					unlock_page(page);
 					if (prev_cur_page != xpage)
-						page_cache_release(page);
+						put_page(page);
 					pages[prev_cur_page] = NULL;
 				}
 			}
@@ -914,7 +914,7 @@ lock_retry_remap:
 			kunmap(page);
 			unlock_page(page);
 			if (cur_page != xpage)
-				page_cache_release(page);
+				put_page(page);
 			pages[cur_page] = NULL;
 		}
 	}
@@ -961,7 +961,7 @@ err_out:
 			kunmap(page);
 			unlock_page(page);
 			if (i != xpage)
-				page_cache_release(page);
+				put_page(page);
 		}
 	}
 	kfree(pages);
diff --git a/fs/ntfs/dir.c b/fs/ntfs/dir.c
index b2eff5816adc..3cdce162592d 100644
--- a/fs/ntfs/dir.c
+++ b/fs/ntfs/dir.c
@@ -319,7 +319,7 @@ descend_into_child_node:
 	 * disk if necessary.
 	 */
 	page = ntfs_map_page(ia_mapping, vcn <<
-			dir_ni->itype.index.vcn_size_bits >> PAGE_CACHE_SHIFT);
+			dir_ni->itype.index.vcn_size_bits >> PAGE_SHIFT);
 	if (IS_ERR(page)) {
 		ntfs_error(sb, "Failed to map directory index page, error %ld.",
 				-PTR_ERR(page));
@@ -331,9 +331,9 @@ descend_into_child_node:
 fast_descend_into_child_node:
 	/* Get to the index allocation block. */
 	ia = (INDEX_ALLOCATION*)(kaddr + ((vcn <<
-			dir_ni->itype.index.vcn_size_bits) & ~PAGE_CACHE_MASK));
+			dir_ni->itype.index.vcn_size_bits) & ~PAGE_MASK));
 	/* Bounds checks. */
-	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_CACHE_SIZE) {
+	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Out of bounds check failed. Corrupt directory "
 				"inode 0x%lx or driver bug.", dir_ni->mft_no);
 		goto unm_err_out;
@@ -366,7 +366,7 @@ fast_descend_into_child_node:
 		goto unm_err_out;
 	}
 	index_end = (u8*)ia + dir_ni->itype.index.block_size;
-	if (index_end > kaddr + PAGE_CACHE_SIZE) {
+	if (index_end > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Index buffer (VCN 0x%llx) of directory inode "
 				"0x%lx crosses page boundary. Impossible! "
 				"Cannot access! This is probably a bug in the "
@@ -559,9 +559,9 @@ found_it2:
 			/* If vcn is in the same page cache page as old_vcn we
 			 * recycle the mapped page. */
 			if (old_vcn << vol->cluster_size_bits >>
-					PAGE_CACHE_SHIFT == vcn <<
+					PAGE_SHIFT == vcn <<
 					vol->cluster_size_bits >>
-					PAGE_CACHE_SHIFT)
+					PAGE_SHIFT)
 				goto fast_descend_into_child_node;
 			unlock_page(page);
 			ntfs_unmap_page(page);
@@ -1246,15 +1246,15 @@ skip_index_root:
 		goto iput_err_out;
 	}
 	/* Get the starting bit position in the current bitmap page. */
-	cur_bmp_pos = bmp_pos & ((PAGE_CACHE_SIZE * 8) - 1);
-	bmp_pos &= ~(u64)((PAGE_CACHE_SIZE * 8) - 1);
+	cur_bmp_pos = bmp_pos & ((PAGE_SIZE * 8) - 1);
+	bmp_pos &= ~(u64)((PAGE_SIZE * 8) - 1);
 get_next_bmp_page:
 	ntfs_debug("Reading bitmap with page index 0x%llx, bit ofs 0x%llx",
-			(unsigned long long)bmp_pos >> (3 + PAGE_CACHE_SHIFT),
+			(unsigned long long)bmp_pos >> (3 + PAGE_SHIFT),
 			(unsigned long long)bmp_pos &
-			(unsigned long long)((PAGE_CACHE_SIZE * 8) - 1));
+			(unsigned long long)((PAGE_SIZE * 8) - 1));
 	bmp_page = ntfs_map_page(bmp_mapping,
-			bmp_pos >> (3 + PAGE_CACHE_SHIFT));
+			bmp_pos >> (3 + PAGE_SHIFT));
 	if (IS_ERR(bmp_page)) {
 		ntfs_error(sb, "Reading index bitmap failed.");
 		err = PTR_ERR(bmp_page);
@@ -1270,9 +1270,9 @@ find_next_index_buffer:
 		 * If we have reached the end of the bitmap page, get the next
 		 * page, and put away the old one.
 		 */
-		if (unlikely((cur_bmp_pos >> 3) >= PAGE_CACHE_SIZE)) {
+		if (unlikely((cur_bmp_pos >> 3) >= PAGE_SIZE)) {
 			ntfs_unmap_page(bmp_page);
-			bmp_pos += PAGE_CACHE_SIZE * 8;
+			bmp_pos += PAGE_SIZE * 8;
 			cur_bmp_pos = 0;
 			goto get_next_bmp_page;
 		}
@@ -1285,8 +1285,8 @@ find_next_index_buffer:
 	ntfs_debug("Handling index buffer 0x%llx.",
 			(unsigned long long)bmp_pos + cur_bmp_pos);
 	/* If the current index buffer is in the same page we reuse the page. */
-	if ((prev_ia_pos & (s64)PAGE_CACHE_MASK) !=
-			(ia_pos & (s64)PAGE_CACHE_MASK)) {
+	if ((prev_ia_pos & (s64)PAGE_MASK) !=
+			(ia_pos & (s64)PAGE_MASK)) {
 		prev_ia_pos = ia_pos;
 		if (likely(ia_page != NULL)) {
 			unlock_page(ia_page);
@@ -1296,7 +1296,7 @@ find_next_index_buffer:
 		 * Map the page cache page containing the current ia_pos,
 		 * reading it from disk if necessary.
 		 */
-		ia_page = ntfs_map_page(ia_mapping, ia_pos >> PAGE_CACHE_SHIFT);
+		ia_page = ntfs_map_page(ia_mapping, ia_pos >> PAGE_SHIFT);
 		if (IS_ERR(ia_page)) {
 			ntfs_error(sb, "Reading index allocation data failed.");
 			err = PTR_ERR(ia_page);
@@ -1307,10 +1307,10 @@ find_next_index_buffer:
 		kaddr = (u8*)page_address(ia_page);
 	}
 	/* Get the current index buffer. */
-	ia = (INDEX_ALLOCATION*)(kaddr + (ia_pos & ~PAGE_CACHE_MASK &
-			~(s64)(ndir->itype.index.block_size - 1)));
+	ia = (INDEX_ALLOCATION*)(kaddr + (ia_pos & ~PAGE_MASK &
+					  ~(s64)(ndir->itype.index.block_size - 1)));
 	/* Bounds checks. */
-	if (unlikely((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_CACHE_SIZE)) {
+	if (unlikely((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_SIZE)) {
 		ntfs_error(sb, "Out of bounds check failed. Corrupt directory "
 				"inode 0x%lx or driver bug.", vdir->i_ino);
 		goto err_out;
@@ -1348,7 +1348,7 @@ find_next_index_buffer:
 		goto err_out;
 	}
 	index_end = (u8*)ia + ndir->itype.index.block_size;
-	if (unlikely(index_end > kaddr + PAGE_CACHE_SIZE)) {
+	if (unlikely(index_end > kaddr + PAGE_SIZE)) {
 		ntfs_error(sb, "Index buffer (VCN 0x%llx) of directory inode "
 				"0x%lx crosses page boundary. Impossible! "
 				"Cannot access! This is probably a bug in the "
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index bed4d427dfae..2dae60857544 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -220,8 +220,8 @@ do_non_resident_extend:
 		m = NULL;
 	}
 	mapping = vi->i_mapping;
-	index = old_init_size >> PAGE_CACHE_SHIFT;
-	end_index = (new_init_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	index = old_init_size >> PAGE_SHIFT;
+	end_index = (new_init_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	do {
 		/*
 		 * Read the page.  If the page is not present, this will zero
@@ -233,7 +233,7 @@ do_non_resident_extend:
 			goto init_err_out;
 		}
 		if (unlikely(PageError(page))) {
-			page_cache_release(page);
+			put_page(page);
 			err = -EIO;
 			goto init_err_out;
 		}
@@ -242,13 +242,13 @@ do_non_resident_extend:
 		 * enough to make ntfs_writepage() work.
 		 */
 		write_lock_irqsave(&ni->size_lock, flags);
-		ni->initialized_size = (s64)(index + 1) << PAGE_CACHE_SHIFT;
+		ni->initialized_size = (s64)(index + 1) << PAGE_SHIFT;
 		if (ni->initialized_size > new_init_size)
 			ni->initialized_size = new_init_size;
 		write_unlock_irqrestore(&ni->size_lock, flags);
 		/* Set the page dirty so it gets written out. */
 		set_page_dirty(page);
-		page_cache_release(page);
+		put_page(page);
 		/*
 		 * Play nice with the vm and the rest of the system.  This is
 		 * very much needed as we can potentially be modifying the
@@ -543,7 +543,7 @@ out:
 err_out:
 	while (nr > 0) {
 		unlock_page(pages[--nr]);
-		page_cache_release(pages[nr]);
+		put_page(pages[nr]);
 	}
 	goto out;
 }
@@ -653,7 +653,7 @@ static int ntfs_prepare_pages_for_non_resident_write(struct page **pages,
 	u = 0;
 do_next_page:
 	page = pages[u];
-	bh_pos = (s64)page->index << PAGE_CACHE_SHIFT;
+	bh_pos = (s64)page->index << PAGE_SHIFT;
 	bh = head = page_buffers(page);
 	do {
 		VCN cdelta;
@@ -810,11 +810,11 @@ map_buffer_cached:
 					
 				kaddr = kmap_atomic(page);
 				if (bh_pos < pos) {
-					pofs = bh_pos & ~PAGE_CACHE_MASK;
+					pofs = bh_pos & ~PAGE_MASK;
 					memset(kaddr + pofs, 0, pos - bh_pos);
 				}
 				if (bh_end > end) {
-					pofs = end & ~PAGE_CACHE_MASK;
+					pofs = end & ~PAGE_MASK;
 					memset(kaddr + pofs, 0, bh_end - end);
 				}
 				kunmap_atomic(kaddr);
@@ -942,7 +942,7 @@ rl_not_mapped_enoent:
 		 * unmapped.  This can only happen when the cluster size is
 		 * less than the page cache size.
 		 */
-		if (unlikely(vol->cluster_size < PAGE_CACHE_SIZE)) {
+		if (unlikely(vol->cluster_size < PAGE_SIZE)) {
 			bh_cend = (bh_end + vol->cluster_size - 1) >>
 					vol->cluster_size_bits;
 			if ((bh_cend <= cpos || bh_cpos >= cend)) {
@@ -1208,7 +1208,7 @@ rl_not_mapped_enoent:
 		wait_on_buffer(bh);
 		if (likely(buffer_uptodate(bh))) {
 			page = bh->b_page;
-			bh_pos = ((s64)page->index << PAGE_CACHE_SHIFT) +
+			bh_pos = ((s64)page->index << PAGE_SHIFT) +
 					bh_offset(bh);
 			/*
 			 * If the buffer overflows the initialized size, need
@@ -1350,7 +1350,7 @@ rl_not_mapped_enoent:
 		bh = head = page_buffers(page);
 		do {
 			if (u == nr_pages &&
-					((s64)page->index << PAGE_CACHE_SHIFT) +
+					((s64)page->index << PAGE_SHIFT) +
 					bh_offset(bh) >= end)
 				break;
 			if (!buffer_new(bh))
@@ -1422,7 +1422,7 @@ static inline int ntfs_commit_pages_after_non_resident_write(
 		bool partial;
 
 		page = pages[u];
-		bh_pos = (s64)page->index << PAGE_CACHE_SHIFT;
+		bh_pos = (s64)page->index << PAGE_SHIFT;
 		bh = head = page_buffers(page);
 		partial = false;
 		do {
@@ -1639,7 +1639,7 @@ static int ntfs_commit_pages_after_write(struct page **pages,
 		if (end < attr_len)
 			memcpy(kaddr + end, kattr + end, attr_len - end);
 		/* Zero the region outside the end of the attribute value. */
-		memset(kaddr + attr_len, 0, PAGE_CACHE_SIZE - attr_len);
+		memset(kaddr + attr_len, 0, PAGE_SIZE - attr_len);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
 	}
@@ -1706,7 +1706,7 @@ static size_t ntfs_copy_from_user_iter(struct page **pages, unsigned nr_pages,
 	unsigned len, copied;
 
 	do {
-		len = PAGE_CACHE_SIZE - ofs;
+		len = PAGE_SIZE - ofs;
 		if (len > bytes)
 			len = bytes;
 		copied = iov_iter_copy_from_user_atomic(*pages, &data, ofs,
@@ -1724,14 +1724,14 @@ out:
 	return total;
 err:
 	/* Zero the rest of the target like __copy_from_user(). */
-	len = PAGE_CACHE_SIZE - copied;
+	len = PAGE_SIZE - copied;
 	do {
 		if (len > bytes)
 			len = bytes;
 		zero_user(*pages, copied, len);
 		bytes -= len;
 		copied = 0;
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 	} while (++pages < last_page);
 	goto out;
 }
@@ -1787,8 +1787,8 @@ static ssize_t ntfs_perform_write(struct file *file, struct iov_iter *i,
 	 * attributes.
 	 */
 	nr_pages = 1;
-	if (vol->cluster_size > PAGE_CACHE_SIZE && NInoNonResident(ni))
-		nr_pages = vol->cluster_size >> PAGE_CACHE_SHIFT;
+	if (vol->cluster_size > PAGE_SIZE && NInoNonResident(ni))
+		nr_pages = vol->cluster_size >> PAGE_SHIFT;
 	last_vcn = -1;
 	do {
 		VCN vcn;
@@ -1796,9 +1796,9 @@ static ssize_t ntfs_perform_write(struct file *file, struct iov_iter *i,
 		unsigned ofs, do_pages, u;
 		size_t copied;
 
-		start_idx = idx = pos >> PAGE_CACHE_SHIFT;
-		ofs = pos & ~PAGE_CACHE_MASK;
-		bytes = PAGE_CACHE_SIZE - ofs;
+		start_idx = idx = pos >> PAGE_SHIFT;
+		ofs = pos & ~PAGE_MASK;
+		bytes = PAGE_SIZE - ofs;
 		do_pages = 1;
 		if (nr_pages > 1) {
 			vcn = pos >> vol->cluster_size_bits;
@@ -1832,7 +1832,7 @@ static ssize_t ntfs_perform_write(struct file *file, struct iov_iter *i,
 				if (lcn == LCN_HOLE) {
 					start_idx = (pos & ~(s64)
 							vol->cluster_size_mask)
-							>> PAGE_CACHE_SHIFT;
+							>> PAGE_SHIFT;
 					bytes = vol->cluster_size - (pos &
 							vol->cluster_size_mask);
 					do_pages = nr_pages;
@@ -1871,12 +1871,12 @@ again:
 			if (unlikely(status)) {
 				do {
 					unlock_page(pages[--do_pages]);
-					page_cache_release(pages[do_pages]);
+					put_page(pages[do_pages]);
 				} while (do_pages);
 				break;
 			}
 		}
-		u = (pos >> PAGE_CACHE_SHIFT) - pages[0]->index;
+		u = (pos >> PAGE_SHIFT) - pages[0]->index;
 		copied = ntfs_copy_from_user_iter(pages + u, do_pages - u, ofs,
 					i, bytes);
 		ntfs_flush_dcache_pages(pages + u, do_pages - u);
@@ -1889,7 +1889,7 @@ again:
 		}
 		do {
 			unlock_page(pages[--do_pages]);
-			page_cache_release(pages[do_pages]);
+			put_page(pages[do_pages]);
 		} while (do_pages);
 		if (unlikely(status < 0))
 			break;
@@ -1921,7 +1921,7 @@ again:
 		}
 	} while (iov_iter_count(i));
 	if (cached_page)
-		page_cache_release(cached_page);
+		put_page(cached_page);
 	ntfs_debug("Done.  Returning %s (written 0x%lx, status %li).",
 			written ? "written" : "status", (unsigned long)written,
 			(long)status);
diff --git a/fs/ntfs/index.c b/fs/ntfs/index.c
index 096c135691ae..02a83a46ead2 100644
--- a/fs/ntfs/index.c
+++ b/fs/ntfs/index.c
@@ -276,7 +276,7 @@ descend_into_child_node:
 	 * disk if necessary.
 	 */
 	page = ntfs_map_page(ia_mapping, vcn <<
-			idx_ni->itype.index.vcn_size_bits >> PAGE_CACHE_SHIFT);
+			idx_ni->itype.index.vcn_size_bits >> PAGE_SHIFT);
 	if (IS_ERR(page)) {
 		ntfs_error(sb, "Failed to map index page, error %ld.",
 				-PTR_ERR(page));
@@ -288,9 +288,9 @@ descend_into_child_node:
 fast_descend_into_child_node:
 	/* Get to the index allocation block. */
 	ia = (INDEX_ALLOCATION*)(kaddr + ((vcn <<
-			idx_ni->itype.index.vcn_size_bits) & ~PAGE_CACHE_MASK));
+			idx_ni->itype.index.vcn_size_bits) & ~PAGE_MASK));
 	/* Bounds checks. */
-	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_CACHE_SIZE) {
+	if ((u8*)ia < kaddr || (u8*)ia > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Out of bounds check failed.  Corrupt inode "
 				"0x%lx or driver bug.", idx_ni->mft_no);
 		goto unm_err_out;
@@ -323,7 +323,7 @@ fast_descend_into_child_node:
 		goto unm_err_out;
 	}
 	index_end = (u8*)ia + idx_ni->itype.index.block_size;
-	if (index_end > kaddr + PAGE_CACHE_SIZE) {
+	if (index_end > kaddr + PAGE_SIZE) {
 		ntfs_error(sb, "Index buffer (VCN 0x%llx) of inode 0x%lx "
 				"crosses page boundary.  Impossible!  Cannot "
 				"access!  This is probably a bug in the "
@@ -427,9 +427,9 @@ ia_done:
 		 * the mapped page.
 		 */
 		if (old_vcn << vol->cluster_size_bits >>
-				PAGE_CACHE_SHIFT == vcn <<
+				PAGE_SHIFT == vcn <<
 				vol->cluster_size_bits >>
-				PAGE_CACHE_SHIFT)
+				PAGE_SHIFT)
 			goto fast_descend_into_child_node;
 		unlock_page(page);
 		ntfs_unmap_page(page);
diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index d284f07eda77..3eda6d4bcc65 100644
--- a/fs/ntfs/inode.c
+++ b/fs/ntfs/inode.c
@@ -868,12 +868,12 @@ skip_attr_list_load:
 					ni->itype.index.block_size);
 			goto unm_err_out;
 		}
-		if (ni->itype.index.block_size > PAGE_CACHE_SIZE) {
+		if (ni->itype.index.block_size > PAGE_SIZE) {
 			ntfs_error(vi->i_sb, "Index block size (%u) > "
 					"PAGE_CACHE_SIZE (%ld) is not "
 					"supported.  Sorry.",
 					ni->itype.index.block_size,
-					PAGE_CACHE_SIZE);
+					PAGE_SIZE);
 			err = -EOPNOTSUPP;
 			goto unm_err_out;
 		}
@@ -1585,10 +1585,10 @@ static int ntfs_read_locked_index_inode(struct inode *base_vi, struct inode *vi)
 				"two.", ni->itype.index.block_size);
 		goto unm_err_out;
 	}
-	if (ni->itype.index.block_size > PAGE_CACHE_SIZE) {
+	if (ni->itype.index.block_size > PAGE_SIZE) {
 		ntfs_error(vi->i_sb, "Index block size (%u) > PAGE_CACHE_SIZE "
 				"(%ld) is not supported.  Sorry.",
-				ni->itype.index.block_size, PAGE_CACHE_SIZE);
+				ni->itype.index.block_size, PAGE_SIZE);
 		err = -EOPNOTSUPP;
 		goto unm_err_out;
 	}
diff --git a/fs/ntfs/lcnalloc.c b/fs/ntfs/lcnalloc.c
index 1711b710b641..27a24a42f712 100644
--- a/fs/ntfs/lcnalloc.c
+++ b/fs/ntfs/lcnalloc.c
@@ -283,15 +283,15 @@ runlist_element *ntfs_cluster_alloc(ntfs_volume *vol, const VCN start_vcn,
 			ntfs_unmap_page(page);
 		}
 		page = ntfs_map_page(mapping, last_read_pos >>
-				PAGE_CACHE_SHIFT);
+				PAGE_SHIFT);
 		if (IS_ERR(page)) {
 			err = PTR_ERR(page);
 			ntfs_error(vol->sb, "Failed to map page.");
 			goto out;
 		}
-		buf_size = last_read_pos & ~PAGE_CACHE_MASK;
+		buf_size = last_read_pos & ~PAGE_MASK;
 		buf = page_address(page) + buf_size;
-		buf_size = PAGE_CACHE_SIZE - buf_size;
+		buf_size = PAGE_SIZE - buf_size;
 		if (unlikely(last_read_pos + buf_size > i_size))
 			buf_size = i_size - last_read_pos;
 		buf_size <<= 3;
diff --git a/fs/ntfs/logfile.c b/fs/ntfs/logfile.c
index c71de292c5ad..9d71213ca81e 100644
--- a/fs/ntfs/logfile.c
+++ b/fs/ntfs/logfile.c
@@ -381,7 +381,7 @@ static int ntfs_check_and_load_restart_page(struct inode *vi,
 	 * completely inside @rp, just copy it from there.  Otherwise map all
 	 * the required pages and copy the data from them.
 	 */
-	size = PAGE_CACHE_SIZE - (pos & ~PAGE_CACHE_MASK);
+	size = PAGE_SIZE - (pos & ~PAGE_MASK);
 	if (size >= le32_to_cpu(rp->system_page_size)) {
 		memcpy(trp, rp, le32_to_cpu(rp->system_page_size));
 	} else {
@@ -394,8 +394,8 @@ static int ntfs_check_and_load_restart_page(struct inode *vi,
 		/* Copy the remaining data one page at a time. */
 		have_read = size;
 		to_read = le32_to_cpu(rp->system_page_size) - size;
-		idx = (pos + size) >> PAGE_CACHE_SHIFT;
-		BUG_ON((pos + size) & ~PAGE_CACHE_MASK);
+		idx = (pos + size) >> PAGE_SHIFT;
+		BUG_ON((pos + size) & ~PAGE_MASK);
 		do {
 			page = ntfs_map_page(vi->i_mapping, idx);
 			if (IS_ERR(page)) {
@@ -406,7 +406,7 @@ static int ntfs_check_and_load_restart_page(struct inode *vi,
 					err = -EIO;
 				goto err_out;
 			}
-			size = min_t(int, to_read, PAGE_CACHE_SIZE);
+			size = min_t(int, to_read, PAGE_SIZE);
 			memcpy((u8*)trp + have_read, page_address(page), size);
 			ntfs_unmap_page(page);
 			have_read += size;
@@ -509,11 +509,11 @@ bool ntfs_check_logfile(struct inode *log_vi, RESTART_PAGE_HEADER **rp)
 	 * log page size if the page cache size is between the default log page
 	 * size and twice that.
 	 */
-	if (PAGE_CACHE_SIZE >= DefaultLogPageSize && PAGE_CACHE_SIZE <=
+	if (PAGE_SIZE >= DefaultLogPageSize && PAGE_SIZE <=
 			DefaultLogPageSize * 2)
 		log_page_size = DefaultLogPageSize;
 	else
-		log_page_size = PAGE_CACHE_SIZE;
+		log_page_size = PAGE_SIZE;
 	log_page_mask = log_page_size - 1;
 	/*
 	 * Use ntfs_ffs() instead of ffs() to enable the compiler to
@@ -539,7 +539,7 @@ bool ntfs_check_logfile(struct inode *log_vi, RESTART_PAGE_HEADER **rp)
 	 * to be empty.
 	 */
 	for (pos = 0; pos < size; pos <<= 1) {
-		pgoff_t idx = pos >> PAGE_CACHE_SHIFT;
+		pgoff_t idx = pos >> PAGE_SHIFT;
 		if (!page || page->index != idx) {
 			if (page)
 				ntfs_unmap_page(page);
@@ -550,7 +550,7 @@ bool ntfs_check_logfile(struct inode *log_vi, RESTART_PAGE_HEADER **rp)
 				goto err_out;
 			}
 		}
-		kaddr = (u8*)page_address(page) + (pos & ~PAGE_CACHE_MASK);
+		kaddr = (u8*)page_address(page) + (pos & ~PAGE_MASK);
 		/*
 		 * A non-empty block means the logfile is not empty while an
 		 * empty block after a non-empty block has been encountered
diff --git a/fs/ntfs/mft.c b/fs/ntfs/mft.c
index 3014a36a255b..37b2501caaa4 100644
--- a/fs/ntfs/mft.c
+++ b/fs/ntfs/mft.c
@@ -61,16 +61,16 @@ static inline MFT_RECORD *map_mft_record_page(ntfs_inode *ni)
 	 * here if the volume was that big...
 	 */
 	index = (u64)ni->mft_no << vol->mft_record_size_bits >>
-			PAGE_CACHE_SHIFT;
-	ofs = (ni->mft_no << vol->mft_record_size_bits) & ~PAGE_CACHE_MASK;
+			PAGE_SHIFT;
+	ofs = (ni->mft_no << vol->mft_record_size_bits) & ~PAGE_MASK;
 
 	i_size = i_size_read(mft_vi);
 	/* The maximum valid index into the page cache for $MFT's data. */
-	end_index = i_size >> PAGE_CACHE_SHIFT;
+	end_index = i_size >> PAGE_SHIFT;
 
 	/* If the wanted index is out of bounds the mft record doesn't exist. */
 	if (unlikely(index >= end_index)) {
-		if (index > end_index || (i_size & ~PAGE_CACHE_MASK) < ofs +
+		if (index > end_index || (i_size & ~PAGE_MASK) < ofs +
 				vol->mft_record_size) {
 			page = ERR_PTR(-ENOENT);
 			ntfs_error(vol->sb, "Attempt to read mft record 0x%lx, "
@@ -487,7 +487,7 @@ int ntfs_sync_mft_mirror(ntfs_volume *vol, const unsigned long mft_no,
 	}
 	/* Get the page containing the mirror copy of the mft record @m. */
 	page = ntfs_map_page(vol->mftmirr_ino->i_mapping, mft_no >>
-			(PAGE_CACHE_SHIFT - vol->mft_record_size_bits));
+			(PAGE_SHIFT - vol->mft_record_size_bits));
 	if (IS_ERR(page)) {
 		ntfs_error(vol->sb, "Failed to map mft mirror page.");
 		err = PTR_ERR(page);
@@ -497,7 +497,7 @@ int ntfs_sync_mft_mirror(ntfs_volume *vol, const unsigned long mft_no,
 	BUG_ON(!PageUptodate(page));
 	ClearPageUptodate(page);
 	/* Offset of the mft mirror record inside the page. */
-	page_ofs = (mft_no << vol->mft_record_size_bits) & ~PAGE_CACHE_MASK;
+	page_ofs = (mft_no << vol->mft_record_size_bits) & ~PAGE_MASK;
 	/* The address in the page of the mirror copy of the mft record @m. */
 	kmirr = page_address(page) + page_ofs;
 	/* Copy the mst protected mft record to the mirror. */
@@ -1178,8 +1178,8 @@ static int ntfs_mft_bitmap_find_and_alloc_free_rec_nolock(ntfs_volume *vol,
 	for (; pass <= 2;) {
 		/* Cap size to pass_end. */
 		ofs = data_pos >> 3;
-		page_ofs = ofs & ~PAGE_CACHE_MASK;
-		size = PAGE_CACHE_SIZE - page_ofs;
+		page_ofs = ofs & ~PAGE_MASK;
+		size = PAGE_SIZE - page_ofs;
 		ll = ((pass_end + 7) >> 3) - ofs;
 		if (size > ll)
 			size = ll;
@@ -1190,7 +1190,7 @@ static int ntfs_mft_bitmap_find_and_alloc_free_rec_nolock(ntfs_volume *vol,
 		 */
 		if (size) {
 			page = ntfs_map_page(mftbmp_mapping,
-					ofs >> PAGE_CACHE_SHIFT);
+					ofs >> PAGE_SHIFT);
 			if (IS_ERR(page)) {
 				ntfs_error(vol->sb, "Failed to read mft "
 						"bitmap, aborting.");
@@ -1328,13 +1328,13 @@ static int ntfs_mft_bitmap_extend_allocation_nolock(ntfs_volume *vol)
 	 */
 	ll = lcn >> 3;
 	page = ntfs_map_page(vol->lcnbmp_ino->i_mapping,
-			ll >> PAGE_CACHE_SHIFT);
+			ll >> PAGE_SHIFT);
 	if (IS_ERR(page)) {
 		up_write(&mftbmp_ni->runlist.lock);
 		ntfs_error(vol->sb, "Failed to read from lcn bitmap.");
 		return PTR_ERR(page);
 	}
-	b = (u8*)page_address(page) + (ll & ~PAGE_CACHE_MASK);
+	b = (u8*)page_address(page) + (ll & ~PAGE_MASK);
 	tb = 1 << (lcn & 7ull);
 	down_write(&vol->lcnbmp_lock);
 	if (*b != 0xff && !(*b & tb)) {
@@ -2103,14 +2103,14 @@ static int ntfs_mft_record_format(const ntfs_volume *vol, const s64 mft_no)
 	 * The index into the page cache and the offset within the page cache
 	 * page of the wanted mft record.
 	 */
-	index = mft_no << vol->mft_record_size_bits >> PAGE_CACHE_SHIFT;
-	ofs = (mft_no << vol->mft_record_size_bits) & ~PAGE_CACHE_MASK;
+	index = mft_no << vol->mft_record_size_bits >> PAGE_SHIFT;
+	ofs = (mft_no << vol->mft_record_size_bits) & ~PAGE_MASK;
 	/* The maximum valid index into the page cache for $MFT's data. */
 	i_size = i_size_read(mft_vi);
-	end_index = i_size >> PAGE_CACHE_SHIFT;
+	end_index = i_size >> PAGE_SHIFT;
 	if (unlikely(index >= end_index)) {
 		if (unlikely(index > end_index || ofs + vol->mft_record_size >=
-				(i_size & ~PAGE_CACHE_MASK))) {
+				(i_size & ~PAGE_MASK))) {
 			ntfs_error(vol->sb, "Tried to format non-existing mft "
 					"record 0x%llx.", (long long)mft_no);
 			return -ENOENT;
@@ -2515,8 +2515,8 @@ mft_rec_already_initialized:
 	 * We now have allocated and initialized the mft record.  Calculate the
 	 * index of and the offset within the page cache page the record is in.
 	 */
-	index = bit << vol->mft_record_size_bits >> PAGE_CACHE_SHIFT;
-	ofs = (bit << vol->mft_record_size_bits) & ~PAGE_CACHE_MASK;
+	index = bit << vol->mft_record_size_bits >> PAGE_SHIFT;
+	ofs = (bit << vol->mft_record_size_bits) & ~PAGE_MASK;
 	/* Read, map, and pin the page containing the mft record. */
 	page = ntfs_map_page(vol->mft_ino->i_mapping, index);
 	if (IS_ERR(page)) {
diff --git a/fs/ntfs/ntfs.h b/fs/ntfs/ntfs.h
index c581e26a350d..12de47b96ca9 100644
--- a/fs/ntfs/ntfs.h
+++ b/fs/ntfs/ntfs.h
@@ -43,7 +43,7 @@ typedef enum {
 	NTFS_MAX_NAME_LEN	= 255,
 	NTFS_MAX_ATTR_NAME_LEN	= 255,
 	NTFS_MAX_CLUSTER_SIZE	= 64 * 1024,	/* 64kiB */
-	NTFS_MAX_PAGES_PER_CLUSTER = NTFS_MAX_CLUSTER_SIZE / PAGE_CACHE_SIZE,
+	NTFS_MAX_PAGES_PER_CLUSTER = NTFS_MAX_CLUSTER_SIZE / PAGE_SIZE,
 } NTFS_CONSTANTS;
 
 /* Global variables. */
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index 1b38abdaa3ed..ab2b0930054e 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -826,11 +826,11 @@ static bool parse_ntfs_boot_sector(ntfs_volume *vol, const NTFS_BOOT_SECTOR *b)
 	 * We cannot support mft record sizes above the PAGE_CACHE_SIZE since
 	 * we store $MFT/$DATA, the table of mft records in the page cache.
 	 */
-	if (vol->mft_record_size > PAGE_CACHE_SIZE) {
+	if (vol->mft_record_size > PAGE_SIZE) {
 		ntfs_error(vol->sb, "Mft record size (%i) exceeds the "
 				"PAGE_CACHE_SIZE on your system (%lu).  "
 				"This is not supported.  Sorry.",
-				vol->mft_record_size, PAGE_CACHE_SIZE);
+				vol->mft_record_size, PAGE_SIZE);
 		return false;
 	}
 	/* We cannot support mft record sizes below the sector size. */
@@ -1096,7 +1096,7 @@ static bool check_mft_mirror(ntfs_volume *vol)
 
 	ntfs_debug("Entering.");
 	/* Compare contents of $MFT and $MFTMirr. */
-	mrecs_per_page = PAGE_CACHE_SIZE / vol->mft_record_size;
+	mrecs_per_page = PAGE_SIZE / vol->mft_record_size;
 	BUG_ON(!mrecs_per_page);
 	BUG_ON(!vol->mftmirr_size);
 	mft_page = mirr_page = NULL;
@@ -1615,20 +1615,20 @@ static bool load_and_init_attrdef(ntfs_volume *vol)
 	if (!vol->attrdef)
 		goto iput_failed;
 	index = 0;
-	max_index = i_size >> PAGE_CACHE_SHIFT;
-	size = PAGE_CACHE_SIZE;
+	max_index = i_size >> PAGE_SHIFT;
+	size = PAGE_SIZE;
 	while (index < max_index) {
 		/* Read the attrdef table and copy it into the linear buffer. */
 read_partial_attrdef_page:
 		page = ntfs_map_page(ino->i_mapping, index);
 		if (IS_ERR(page))
 			goto free_iput_failed;
-		memcpy((u8*)vol->attrdef + (index++ << PAGE_CACHE_SHIFT),
+		memcpy((u8*)vol->attrdef + (index++ << PAGE_SHIFT),
 				page_address(page), size);
 		ntfs_unmap_page(page);
 	};
-	if (size == PAGE_CACHE_SIZE) {
-		size = i_size & ~PAGE_CACHE_MASK;
+	if (size == PAGE_SIZE) {
+		size = i_size & ~PAGE_MASK;
 		if (size)
 			goto read_partial_attrdef_page;
 	}
@@ -1684,20 +1684,20 @@ static bool load_and_init_upcase(ntfs_volume *vol)
 	if (!vol->upcase)
 		goto iput_upcase_failed;
 	index = 0;
-	max_index = i_size >> PAGE_CACHE_SHIFT;
-	size = PAGE_CACHE_SIZE;
+	max_index = i_size >> PAGE_SHIFT;
+	size = PAGE_SIZE;
 	while (index < max_index) {
 		/* Read the upcase table and copy it into the linear buffer. */
 read_partial_upcase_page:
 		page = ntfs_map_page(ino->i_mapping, index);
 		if (IS_ERR(page))
 			goto iput_upcase_failed;
-		memcpy((char*)vol->upcase + (index++ << PAGE_CACHE_SHIFT),
+		memcpy((char*)vol->upcase + (index++ << PAGE_SHIFT),
 				page_address(page), size);
 		ntfs_unmap_page(page);
 	};
-	if (size == PAGE_CACHE_SIZE) {
-		size = i_size & ~PAGE_CACHE_MASK;
+	if (size == PAGE_SIZE) {
+		size = i_size & ~PAGE_MASK;
 		if (size)
 			goto read_partial_upcase_page;
 	}
@@ -2474,11 +2474,11 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
 	 * multiples of PAGE_CACHE_SIZE, rounding up so that if we have one
 	 * full and one partial page max_index = 2.
 	 */
-	max_index = (((vol->nr_clusters + 7) >> 3) + PAGE_CACHE_SIZE - 1) >>
-			PAGE_CACHE_SHIFT;
+	max_index = (((vol->nr_clusters + 7) >> 3) + PAGE_SIZE - 1) >>
+			PAGE_SHIFT;
 	/* Use multiples of 4 bytes, thus max_size is PAGE_CACHE_SIZE / 4. */
 	ntfs_debug("Reading $Bitmap, max_index = 0x%lx, max_size = 0x%lx.",
-			max_index, PAGE_CACHE_SIZE / 4);
+			max_index, PAGE_SIZE / 4);
 	for (index = 0; index < max_index; index++) {
 		unsigned long *kaddr;
 
@@ -2491,7 +2491,7 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
 		if (IS_ERR(page)) {
 			ntfs_debug("read_mapping_page() error. Skipping "
 					"page (index 0x%lx).", index);
-			nr_free -= PAGE_CACHE_SIZE * 8;
+			nr_free -= PAGE_SIZE * 8;
 			continue;
 		}
 		kaddr = kmap_atomic(page);
@@ -2503,9 +2503,9 @@ static s64 get_nr_free_clusters(ntfs_volume *vol)
 		 * ntfs_readpage().
 		 */
 		nr_free -= bitmap_weight(kaddr,
-					PAGE_CACHE_SIZE * BITS_PER_BYTE);
+					PAGE_SIZE * BITS_PER_BYTE);
 		kunmap_atomic(kaddr);
-		page_cache_release(page);
+		put_page(page);
 	}
 	ntfs_debug("Finished reading $Bitmap, last index = 0x%lx.", index - 1);
 	/*
@@ -2549,7 +2549,7 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
 	ntfs_debug("Entering.");
 	/* Use multiples of 4 bytes, thus max_size is PAGE_CACHE_SIZE / 4. */
 	ntfs_debug("Reading $MFT/$BITMAP, max_index = 0x%lx, max_size = "
-			"0x%lx.", max_index, PAGE_CACHE_SIZE / 4);
+			"0x%lx.", max_index, PAGE_SIZE / 4);
 	for (index = 0; index < max_index; index++) {
 		unsigned long *kaddr;
 
@@ -2562,7 +2562,7 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
 		if (IS_ERR(page)) {
 			ntfs_debug("read_mapping_page() error. Skipping "
 					"page (index 0x%lx).", index);
-			nr_free -= PAGE_CACHE_SIZE * 8;
+			nr_free -= PAGE_SIZE * 8;
 			continue;
 		}
 		kaddr = kmap_atomic(page);
@@ -2574,9 +2574,9 @@ static unsigned long __get_nr_free_mft_records(ntfs_volume *vol,
 		 * ntfs_readpage().
 		 */
 		nr_free -= bitmap_weight(kaddr,
-					PAGE_CACHE_SIZE * BITS_PER_BYTE);
+					PAGE_SIZE * BITS_PER_BYTE);
 		kunmap_atomic(kaddr);
-		page_cache_release(page);
+		put_page(page);
 	}
 	ntfs_debug("Finished reading $MFT/$BITMAP, last index = 0x%lx.",
 			index - 1);
@@ -2618,17 +2618,17 @@ static int ntfs_statfs(struct dentry *dentry, struct kstatfs *sfs)
 	/* Type of filesystem. */
 	sfs->f_type   = NTFS_SB_MAGIC;
 	/* Optimal transfer block size. */
-	sfs->f_bsize  = PAGE_CACHE_SIZE;
+	sfs->f_bsize  = PAGE_SIZE;
 	/*
 	 * Total data blocks in filesystem in units of f_bsize and since
 	 * inodes are also stored in data blocs ($MFT is a file) this is just
 	 * the total clusters.
 	 */
 	sfs->f_blocks = vol->nr_clusters << vol->cluster_size_bits >>
-				PAGE_CACHE_SHIFT;
+				PAGE_SHIFT;
 	/* Free data blocks in filesystem in units of f_bsize. */
 	size	      = get_nr_free_clusters(vol) << vol->cluster_size_bits >>
-				PAGE_CACHE_SHIFT;
+				PAGE_SHIFT;
 	if (size < 0LL)
 		size = 0LL;
 	/* Free blocks avail to non-superuser, same as above on NTFS. */
@@ -2643,7 +2643,7 @@ static int ntfs_statfs(struct dentry *dentry, struct kstatfs *sfs)
 	 * have one full and one partial page max_index = 2.
 	 */
 	max_index = ((((mft_ni->initialized_size >> vol->mft_record_size_bits)
-			+ 7) >> 3) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+			+ 7) >> 3) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	read_unlock_irqrestore(&mft_ni->size_lock, flags);
 	/* Number of inodes in filesystem (at this point in time). */
 	sfs->f_files = size;
@@ -2766,14 +2766,14 @@ static int ntfs_fill_super(struct super_block *sb, void *opt, const int silent)
 		goto err_out_now;
 
 	/* We support sector sizes up to the PAGE_CACHE_SIZE. */
-	if (bdev_logical_block_size(sb->s_bdev) > PAGE_CACHE_SIZE) {
+	if (bdev_logical_block_size(sb->s_bdev) > PAGE_SIZE) {
 		if (!silent)
 			ntfs_error(sb, "Device has unsupported sector size "
 					"(%i).  The maximum supported sector "
 					"size on this architecture is %lu "
 					"bytes.",
 					bdev_logical_block_size(sb->s_bdev),
-					PAGE_CACHE_SIZE);
+					PAGE_SIZE);
 		goto err_out_now;
 	}
 	/*
diff --git a/fs/ocfs2/alloc.c b/fs/ocfs2/alloc.c
index d002579c6f2b..7b45d061096e 100644
--- a/fs/ocfs2/alloc.c
+++ b/fs/ocfs2/alloc.c
@@ -6648,7 +6648,7 @@ static void ocfs2_zero_cluster_pages(struct inode *inode, loff_t start,
 {
 	int i;
 	struct page *page;
-	unsigned int from, to = PAGE_CACHE_SIZE;
+	unsigned int from, to = PAGE_SIZE;
 	struct super_block *sb = inode->i_sb;
 
 	BUG_ON(!ocfs2_sparse_alloc(OCFS2_SB(sb)));
@@ -6656,21 +6656,21 @@ static void ocfs2_zero_cluster_pages(struct inode *inode, loff_t start,
 	if (numpages == 0)
 		goto out;
 
-	to = PAGE_CACHE_SIZE;
+	to = PAGE_SIZE;
 	for(i = 0; i < numpages; i++) {
 		page = pages[i];
 
-		from = start & (PAGE_CACHE_SIZE - 1);
-		if ((end >> PAGE_CACHE_SHIFT) == page->index)
-			to = end & (PAGE_CACHE_SIZE - 1);
+		from = start & (PAGE_SIZE - 1);
+		if ((end >> PAGE_SHIFT) == page->index)
+			to = end & (PAGE_SIZE - 1);
 
-		BUG_ON(from > PAGE_CACHE_SIZE);
-		BUG_ON(to > PAGE_CACHE_SIZE);
+		BUG_ON(from > PAGE_SIZE);
+		BUG_ON(to > PAGE_SIZE);
 
 		ocfs2_map_and_dirty_page(inode, handle, from, to, page, 1,
 					 &phys);
 
-		start = (page->index + 1) << PAGE_CACHE_SHIFT;
+		start = (page->index + 1) << PAGE_SHIFT;
 	}
 out:
 	if (pages)
@@ -6689,7 +6689,7 @@ int ocfs2_grab_pages(struct inode *inode, loff_t start, loff_t end,
 
 	numpages = 0;
 	last_page_bytes = PAGE_ALIGN(end);
-	index = start >> PAGE_CACHE_SHIFT;
+	index = start >> PAGE_SHIFT;
 	do {
 		pages[numpages] = find_or_create_page(mapping, index, GFP_NOFS);
 		if (!pages[numpages]) {
@@ -6700,7 +6700,7 @@ int ocfs2_grab_pages(struct inode *inode, loff_t start, loff_t end,
 
 		numpages++;
 		index++;
-	} while (index < (last_page_bytes >> PAGE_CACHE_SHIFT));
+	} while (index < (last_page_bytes >> PAGE_SHIFT));
 
 out:
 	if (ret != 0) {
@@ -6927,8 +6927,8 @@ int ocfs2_convert_inline_data_to_extents(struct inode *inode,
 		 * to do that now.
 		 */
 		if (!ocfs2_sparse_alloc(osb) &&
-		    PAGE_CACHE_SIZE < osb->s_clustersize)
-			end = PAGE_CACHE_SIZE;
+		    PAGE_SIZE < osb->s_clustersize)
+			end = PAGE_SIZE;
 
 		ret = ocfs2_grab_eof_pages(inode, 0, end, pages, &num_pages);
 		if (ret) {
@@ -6948,8 +6948,8 @@ int ocfs2_convert_inline_data_to_extents(struct inode *inode,
 			goto out_unlock;
 		}
 
-		page_end = PAGE_CACHE_SIZE;
-		if (PAGE_CACHE_SIZE > osb->s_clustersize)
+		page_end = PAGE_SIZE;
+		if (PAGE_SIZE > osb->s_clustersize)
 			page_end = osb->s_clustersize;
 
 		for (i = 0; i < num_pages; i++)
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index cda0361e95a4..29b843028b93 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -234,7 +234,7 @@ int ocfs2_read_inline_data(struct inode *inode, struct page *page,
 
 	size = i_size_read(inode);
 
-	if (size > PAGE_CACHE_SIZE ||
+	if (size > PAGE_SIZE ||
 	    size > ocfs2_max_inline_data_with_xattr(inode->i_sb, di)) {
 		ocfs2_error(inode->i_sb,
 			    "Inode %llu has with inline data has bad size: %Lu\n",
@@ -247,7 +247,7 @@ int ocfs2_read_inline_data(struct inode *inode, struct page *page,
 	if (size)
 		memcpy(kaddr, di->id2.i_data.id_data, size);
 	/* Clear the remaining part of the page */
-	memset(kaddr + size, 0, PAGE_CACHE_SIZE - size);
+	memset(kaddr + size, 0, PAGE_SIZE - size);
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
 
@@ -282,7 +282,7 @@ static int ocfs2_readpage(struct file *file, struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct ocfs2_inode_info *oi = OCFS2_I(inode);
-	loff_t start = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	loff_t start = (loff_t)page->index << PAGE_SHIFT;
 	int ret, unlock = 1;
 
 	trace_ocfs2_readpage((unsigned long long)oi->ip_blkno,
@@ -385,7 +385,7 @@ static int ocfs2_readpages(struct file *filp, struct address_space *mapping,
 	 * drop out in that case as it's not worth handling here.
 	 */
 	last = list_entry(pages->prev, struct page, lru);
-	start = (loff_t)last->index << PAGE_CACHE_SHIFT;
+	start = (loff_t)last->index << PAGE_SHIFT;
 	if (start >= i_size_read(inode))
 		goto out_unlock;
 
@@ -1015,12 +1015,12 @@ static void ocfs2_figure_cluster_boundaries(struct ocfs2_super *osb,
 					    unsigned int *start,
 					    unsigned int *end)
 {
-	unsigned int cluster_start = 0, cluster_end = PAGE_CACHE_SIZE;
+	unsigned int cluster_start = 0, cluster_end = PAGE_SIZE;
 
-	if (unlikely(PAGE_CACHE_SHIFT > osb->s_clustersize_bits)) {
+	if (unlikely(PAGE_SHIFT > osb->s_clustersize_bits)) {
 		unsigned int cpp;
 
-		cpp = 1 << (PAGE_CACHE_SHIFT - osb->s_clustersize_bits);
+		cpp = 1 << (PAGE_SHIFT - osb->s_clustersize_bits);
 
 		cluster_start = cpos % cpp;
 		cluster_start = cluster_start << osb->s_clustersize_bits;
@@ -1191,10 +1191,10 @@ next_bh:
 #if (PAGE_CACHE_SIZE >= OCFS2_MAX_CLUSTERSIZE)
 #define OCFS2_MAX_CTXT_PAGES	1
 #else
-#define OCFS2_MAX_CTXT_PAGES	(OCFS2_MAX_CLUSTERSIZE / PAGE_CACHE_SIZE)
+#define OCFS2_MAX_CTXT_PAGES	(OCFS2_MAX_CLUSTERSIZE / PAGE_SIZE)
 #endif
 
-#define OCFS2_MAX_CLUSTERS_PER_PAGE	(PAGE_CACHE_SIZE / OCFS2_MIN_CLUSTERSIZE)
+#define OCFS2_MAX_CLUSTERS_PER_PAGE	(PAGE_SIZE / OCFS2_MIN_CLUSTERSIZE)
 
 /*
  * Describe the state of a single cluster to be written to.
@@ -1277,7 +1277,7 @@ void ocfs2_unlock_and_free_pages(struct page **pages, int num_pages)
 		if (pages[i]) {
 			unlock_page(pages[i]);
 			mark_page_accessed(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 	}
 }
@@ -1300,7 +1300,7 @@ static void ocfs2_unlock_pages(struct ocfs2_write_ctxt *wc)
 			}
 		}
 		mark_page_accessed(wc->w_target_page);
-		page_cache_release(wc->w_target_page);
+		put_page(wc->w_target_page);
 	}
 	ocfs2_unlock_and_free_pages(wc->w_pages, wc->w_num_pages);
 }
@@ -1330,7 +1330,7 @@ static int ocfs2_alloc_write_ctxt(struct ocfs2_write_ctxt **wcp,
 	get_bh(di_bh);
 	wc->w_di_bh = di_bh;
 
-	if (unlikely(PAGE_CACHE_SHIFT > osb->s_clustersize_bits))
+	if (unlikely(PAGE_SHIFT > osb->s_clustersize_bits))
 		wc->w_large_pages = 1;
 	else
 		wc->w_large_pages = 0;
@@ -1392,7 +1392,7 @@ static void ocfs2_write_failure(struct inode *inode,
 				loff_t user_pos, unsigned user_len)
 {
 	int i;
-	unsigned from = user_pos & (PAGE_CACHE_SIZE - 1),
+	unsigned from = user_pos & (PAGE_SIZE - 1),
 		to = user_pos + user_len;
 	struct page *tmppage;
 
@@ -1431,7 +1431,7 @@ static int ocfs2_prepare_page_for_write(struct inode *inode, u64 *p_blkno,
 			(page_offset(page) <= user_pos));
 
 	if (page == wc->w_target_page) {
-		map_from = user_pos & (PAGE_CACHE_SIZE - 1);
+		map_from = user_pos & (PAGE_SIZE - 1);
 		map_to = map_from + user_len;
 
 		if (new)
@@ -1505,7 +1505,7 @@ static int ocfs2_grab_pages_for_write(struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	loff_t last_byte;
 
-	target_index = user_pos >> PAGE_CACHE_SHIFT;
+	target_index = user_pos >> PAGE_SHIFT;
 
 	/*
 	 * Figure out how many pages we'll be manipulating here. For
@@ -1524,7 +1524,7 @@ static int ocfs2_grab_pages_for_write(struct address_space *mapping,
 		 */
 		last_byte = max(user_pos + user_len, i_size_read(inode));
 		BUG_ON(last_byte < 1);
-		end_index = ((last_byte - 1) >> PAGE_CACHE_SHIFT) + 1;
+		end_index = ((last_byte - 1) >> PAGE_SHIFT) + 1;
 		if ((start + wc->w_num_pages) > end_index)
 			wc->w_num_pages = end_index - start;
 	} else {
@@ -1551,7 +1551,7 @@ static int ocfs2_grab_pages_for_write(struct address_space *mapping,
 				goto out;
 			}
 
-			page_cache_get(mmap_page);
+			get_page(mmap_page);
 			wc->w_pages[i] = mmap_page;
 			wc->w_target_locked = true;
 		} else {
@@ -1731,7 +1731,7 @@ static void ocfs2_set_target_boundaries(struct ocfs2_super *osb,
 {
 	struct ocfs2_write_cluster_desc *desc;
 
-	wc->w_target_from = pos & (PAGE_CACHE_SIZE - 1);
+	wc->w_target_from = pos & (PAGE_SIZE - 1);
 	wc->w_target_to = wc->w_target_from + len;
 
 	if (alloc == 0)
@@ -1768,7 +1768,7 @@ static void ocfs2_set_target_boundaries(struct ocfs2_super *osb,
 							&wc->w_target_to);
 	} else {
 		wc->w_target_from = 0;
-		wc->w_target_to = PAGE_CACHE_SIZE;
+		wc->w_target_to = PAGE_SIZE;
 	}
 }
 
@@ -2368,7 +2368,7 @@ int ocfs2_write_end_nolock(struct address_space *mapping,
 			   struct page *page, void *fsdata)
 {
 	int i, ret;
-	unsigned from, to, start = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from, to, start = pos & (PAGE_SIZE - 1);
 	struct inode *inode = mapping->host;
 	struct ocfs2_super *osb = OCFS2_SB(inode->i_sb);
 	struct ocfs2_write_ctxt *wc = fsdata;
@@ -2405,8 +2405,8 @@ int ocfs2_write_end_nolock(struct address_space *mapping,
 			from = wc->w_target_from;
 			to = wc->w_target_to;
 
-			BUG_ON(from > PAGE_CACHE_SIZE ||
-			       to > PAGE_CACHE_SIZE ||
+			BUG_ON(from > PAGE_SIZE ||
+			       to > PAGE_SIZE ||
 			       to < from);
 		} else {
 			/*
@@ -2415,7 +2415,7 @@ int ocfs2_write_end_nolock(struct address_space *mapping,
 			 * to flush their entire range.
 			 */
 			from = 0;
-			to = PAGE_CACHE_SIZE;
+			to = PAGE_SIZE;
 		}
 
 		if (page_has_buffers(tmppage)) {
diff --git a/fs/ocfs2/cluster/heartbeat.c b/fs/ocfs2/cluster/heartbeat.c
index ef6a2ec494de..2c85f5330e12 100644
--- a/fs/ocfs2/cluster/heartbeat.c
+++ b/fs/ocfs2/cluster/heartbeat.c
@@ -417,13 +417,13 @@ static struct bio *o2hb_setup_one_bio(struct o2hb_region *reg,
 	bio->bi_private = wc;
 	bio->bi_end_io = o2hb_bio_end_io;
 
-	vec_start = (cs << bits) % PAGE_CACHE_SIZE;
+	vec_start = (cs << bits) % PAGE_SIZE;
 	while(cs < max_slots) {
 		current_page = cs / spp;
 		page = reg->hr_slot_data[current_page];
 
-		vec_len = min(PAGE_CACHE_SIZE - vec_start,
-			      (max_slots-cs) * (PAGE_CACHE_SIZE/spp) );
+		vec_len = min(PAGE_SIZE - vec_start,
+			      (max_slots-cs) * (PAGE_SIZE/spp) );
 
 		mlog(ML_HB_BIO, "page %d, vec_len = %u, vec_start = %u\n",
 		     current_page, vec_len, vec_start);
@@ -431,7 +431,7 @@ static struct bio *o2hb_setup_one_bio(struct o2hb_region *reg,
 		len = bio_add_page(bio, page, vec_len, vec_start);
 		if (len != vec_len) break;
 
-		cs += vec_len / (PAGE_CACHE_SIZE/spp);
+		cs += vec_len / (PAGE_SIZE/spp);
 		vec_start = 0;
 	}
 
@@ -1576,7 +1576,7 @@ static ssize_t o2hb_region_dev_show(struct config_item *item, char *page)
 
 static void o2hb_init_region_params(struct o2hb_region *reg)
 {
-	reg->hr_slots_per_page = PAGE_CACHE_SIZE >> reg->hr_block_bits;
+	reg->hr_slots_per_page = PAGE_SIZE >> reg->hr_block_bits;
 	reg->hr_timeout_ms = O2HB_REGION_TIMEOUT_MS;
 
 	mlog(ML_HEARTBEAT, "hr_start_block = %llu, hr_blocks = %u\n",
diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index 03768bb3aab1..47b3b2d4e775 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -571,8 +571,8 @@ static int dlmfs_fill_super(struct super_block * sb,
 			    int silent)
 {
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = DLMFS_MAGIC;
 	sb->s_op = &dlmfs_ops;
 	sb->s_root = d_make_root(dlmfs_get_root_inode(sb));
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 7cb38fdca229..32e19a63a4fa 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -770,14 +770,14 @@ static int ocfs2_write_zero_page(struct inode *inode, u64 abs_from,
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
-	unsigned long index = abs_from >> PAGE_CACHE_SHIFT;
+	unsigned long index = abs_from >> PAGE_SHIFT;
 	handle_t *handle;
 	int ret = 0;
 	unsigned zero_from, zero_to, block_start, block_end;
 	struct ocfs2_dinode *di = (struct ocfs2_dinode *)di_bh->b_data;
 
 	BUG_ON(abs_from >= abs_to);
-	BUG_ON(abs_to > (((u64)index + 1) << PAGE_CACHE_SHIFT));
+	BUG_ON(abs_to > (((u64)index + 1) << PAGE_SHIFT));
 	BUG_ON(abs_from & (inode->i_blkbits - 1));
 
 	handle = ocfs2_zero_start_ordered_transaction(inode, di_bh);
@@ -794,10 +794,10 @@ static int ocfs2_write_zero_page(struct inode *inode, u64 abs_from,
 	}
 
 	/* Get the offsets within the page that we want to zero */
-	zero_from = abs_from & (PAGE_CACHE_SIZE - 1);
-	zero_to = abs_to & (PAGE_CACHE_SIZE - 1);
+	zero_from = abs_from & (PAGE_SIZE - 1);
+	zero_to = abs_to & (PAGE_SIZE - 1);
 	if (!zero_to)
-		zero_to = PAGE_CACHE_SIZE;
+		zero_to = PAGE_SIZE;
 
 	trace_ocfs2_write_zero_page(
 			(unsigned long long)OCFS2_I(inode)->ip_blkno,
@@ -851,7 +851,7 @@ static int ocfs2_write_zero_page(struct inode *inode, u64 abs_from,
 
 out_unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out_commit_trans:
 	if (handle)
 		ocfs2_commit_trans(OCFS2_SB(inode->i_sb), handle);
@@ -959,7 +959,7 @@ static int ocfs2_zero_extend_range(struct inode *inode, u64 range_start,
 	BUG_ON(range_start >= range_end);
 
 	while (zero_pos < range_end) {
-		next_pos = (zero_pos & PAGE_CACHE_MASK) + PAGE_CACHE_SIZE;
+		next_pos = (zero_pos & PAGE_MASK) + PAGE_SIZE;
 		if (next_pos > range_end)
 			next_pos = range_end;
 		rc = ocfs2_write_zero_page(inode, zero_pos, next_pos, di_bh);
diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index 77ebc2bc1cca..872e6800267f 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -65,13 +65,13 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
 	struct inode *inode = file_inode(file);
 	struct address_space *mapping = inode->i_mapping;
 	loff_t pos = page_offset(page);
-	unsigned int len = PAGE_CACHE_SIZE;
+	unsigned int len = PAGE_SIZE;
 	pgoff_t last_index;
 	struct page *locked_page = NULL;
 	void *fsdata;
 	loff_t size = i_size_read(inode);
 
-	last_index = (size - 1) >> PAGE_CACHE_SHIFT;
+	last_index = (size - 1) >> PAGE_SHIFT;
 
 	/*
 	 * There are cases that lead to the page no longer bebongs to the
@@ -102,7 +102,7 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
 	 * because the "write" would invalidate their data.
 	 */
 	if (page->index == last_index)
-		len = ((size - 1) & ~PAGE_CACHE_MASK) + 1;
+		len = ((size - 1) & ~PAGE_MASK) + 1;
 
 	ret = ocfs2_write_begin_nolock(file, mapping, pos, len, 0, &locked_page,
 				       &fsdata, di_bh, page);
diff --git a/fs/ocfs2/ocfs2.h b/fs/ocfs2/ocfs2.h
index 7a0126267847..7a592877c33b 100644
--- a/fs/ocfs2/ocfs2.h
+++ b/fs/ocfs2/ocfs2.h
@@ -814,10 +814,10 @@ static inline unsigned int ocfs2_page_index_to_clusters(struct super_block *sb,
 	u32 clusters = pg_index;
 	unsigned int cbits = OCFS2_SB(sb)->s_clustersize_bits;
 
-	if (unlikely(PAGE_CACHE_SHIFT > cbits))
-		clusters = pg_index << (PAGE_CACHE_SHIFT - cbits);
-	else if (PAGE_CACHE_SHIFT < cbits)
-		clusters = pg_index >> (cbits - PAGE_CACHE_SHIFT);
+	if (unlikely(PAGE_SHIFT > cbits))
+		clusters = pg_index << (PAGE_SHIFT - cbits);
+	else if (PAGE_SHIFT < cbits)
+		clusters = pg_index >> (cbits - PAGE_SHIFT);
 
 	return clusters;
 }
@@ -831,10 +831,10 @@ static inline pgoff_t ocfs2_align_clusters_to_page_index(struct super_block *sb,
 	unsigned int cbits = OCFS2_SB(sb)->s_clustersize_bits;
         pgoff_t index = clusters;
 
-	if (PAGE_CACHE_SHIFT > cbits) {
-		index = (pgoff_t)clusters >> (PAGE_CACHE_SHIFT - cbits);
-	} else if (PAGE_CACHE_SHIFT < cbits) {
-		index = (pgoff_t)clusters << (cbits - PAGE_CACHE_SHIFT);
+	if (PAGE_SHIFT > cbits) {
+		index = (pgoff_t)clusters >> (PAGE_SHIFT - cbits);
+	} else if (PAGE_SHIFT < cbits) {
+		index = (pgoff_t)clusters << (cbits - PAGE_SHIFT);
 	}
 
 	return index;
@@ -845,8 +845,8 @@ static inline unsigned int ocfs2_pages_per_cluster(struct super_block *sb)
 	unsigned int cbits = OCFS2_SB(sb)->s_clustersize_bits;
 	unsigned int pages_per_cluster = 1;
 
-	if (PAGE_CACHE_SHIFT < cbits)
-		pages_per_cluster = 1 << (cbits - PAGE_CACHE_SHIFT);
+	if (PAGE_SHIFT < cbits)
+		pages_per_cluster = 1 << (cbits - PAGE_SHIFT);
 
 	return pages_per_cluster;
 }
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 3eff031aaf26..881242c3a8d2 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -2937,16 +2937,16 @@ int ocfs2_duplicate_clusters_by_page(handle_t *handle,
 		end = i_size_read(inode);
 
 	while (offset < end) {
-		page_index = offset >> PAGE_CACHE_SHIFT;
-		map_end = ((loff_t)page_index + 1) << PAGE_CACHE_SHIFT;
+		page_index = offset >> PAGE_SHIFT;
+		map_end = ((loff_t)page_index + 1) << PAGE_SHIFT;
 		if (map_end > end)
 			map_end = end;
 
 		/* from, to is the offset within the page. */
-		from = offset & (PAGE_CACHE_SIZE - 1);
-		to = PAGE_CACHE_SIZE;
-		if (map_end & (PAGE_CACHE_SIZE - 1))
-			to = map_end & (PAGE_CACHE_SIZE - 1);
+		from = offset & (PAGE_SIZE - 1);
+		to = PAGE_SIZE;
+		if (map_end & (PAGE_SIZE - 1))
+			to = map_end & (PAGE_SIZE - 1);
 
 		page = find_or_create_page(mapping, page_index, GFP_NOFS);
 		if (!page) {
@@ -2959,7 +2959,7 @@ int ocfs2_duplicate_clusters_by_page(handle_t *handle,
 		 * In case PAGE_CACHE_SIZE <= CLUSTER_SIZE, This page
 		 * can't be dirtied before we CoW it out.
 		 */
-		if (PAGE_CACHE_SIZE <= OCFS2_SB(sb)->s_clustersize)
+		if (PAGE_SIZE <= OCFS2_SB(sb)->s_clustersize)
 			BUG_ON(PageDirty(page));
 
 		if (!PageUptodate(page)) {
@@ -2987,7 +2987,7 @@ int ocfs2_duplicate_clusters_by_page(handle_t *handle,
 		mark_page_accessed(page);
 unlock:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 		offset = map_end;
 		if (ret)
@@ -3165,8 +3165,8 @@ int ocfs2_cow_sync_writeback(struct super_block *sb,
 	}
 
 	while (offset < end) {
-		page_index = offset >> PAGE_CACHE_SHIFT;
-		map_end = ((loff_t)page_index + 1) << PAGE_CACHE_SHIFT;
+		page_index = offset >> PAGE_SHIFT;
+		map_end = ((loff_t)page_index + 1) << PAGE_SHIFT;
 		if (map_end > end)
 			map_end = end;
 
@@ -3182,7 +3182,7 @@ int ocfs2_cow_sync_writeback(struct super_block *sb,
 			mark_page_accessed(page);
 
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 		offset = map_end;
 		if (ret)
diff --git a/fs/ocfs2/super.c b/fs/ocfs2/super.c
index 302854ee0985..455155ca742e 100644
--- a/fs/ocfs2/super.c
+++ b/fs/ocfs2/super.c
@@ -610,8 +610,8 @@ static unsigned long long ocfs2_max_file_offset(unsigned int bbits,
 	/*
 	 * We might be limited by page cache size.
 	 */
-	if (bytes > PAGE_CACHE_SIZE) {
-		bytes = PAGE_CACHE_SIZE;
+	if (bytes > PAGE_SIZE) {
+		bytes = PAGE_SIZE;
 		trim = 1;
 		/*
 		 * Shift by 31 here so that we don't get larger than
diff --git a/fs/pipe.c b/fs/pipe.c
index ab8dad3ccb6a..0d3f5165cb0b 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -134,7 +134,7 @@ static void anon_pipe_buf_release(struct pipe_inode_info *pipe,
 	if (page_count(page) == 1 && !pipe->tmp_page)
 		pipe->tmp_page = page;
 	else
-		page_cache_release(page);
+		put_page(page);
 }
 
 /**
@@ -180,7 +180,7 @@ EXPORT_SYMBOL(generic_pipe_buf_steal);
  */
 void generic_pipe_buf_get(struct pipe_inode_info *pipe, struct pipe_buffer *buf)
 {
-	page_cache_get(buf->page);
+	get_page(buf->page);
 }
 EXPORT_SYMBOL(generic_pipe_buf_get);
 
@@ -211,7 +211,7 @@ EXPORT_SYMBOL(generic_pipe_buf_confirm);
 void generic_pipe_buf_release(struct pipe_inode_info *pipe,
 			      struct pipe_buffer *buf)
 {
-	page_cache_release(buf->page);
+	put_page(buf->page);
 }
 EXPORT_SYMBOL(generic_pipe_buf_release);
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9df431642042..229cb546bee0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -553,7 +553,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 		if (radix_tree_exceptional_entry(page))
 			mss->swap += PAGE_SIZE;
 		else
-			page_cache_release(page);
+			put_page(page);
 
 		return;
 	}
diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 55bb57e6a30d..8afe10cf7df8 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -279,12 +279,12 @@ static int mmap_vmcore_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (!page)
 		return VM_FAULT_OOM;
 	if (!PageUptodate(page)) {
-		offset = (loff_t) index << PAGE_CACHE_SHIFT;
+		offset = (loff_t) index << PAGE_SHIFT;
 		buf = __va((page_to_pfn(page) << PAGE_SHIFT));
 		rc = __read_vmcore(buf, PAGE_SIZE, &offset, 0);
 		if (rc < 0) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			return (rc == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
 		}
 		SetPageUptodate(page);
diff --git a/fs/pstore/inode.c b/fs/pstore/inode.c
index dc645b66cd79..45d6110744cb 100644
--- a/fs/pstore/inode.c
+++ b/fs/pstore/inode.c
@@ -420,8 +420,8 @@ static int pstore_fill_super(struct super_block *sb, void *data, int silent)
 	pstore_sb = sb;
 
 	sb->s_maxbytes		= MAX_LFS_FILESIZE;
-	sb->s_blocksize		= PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits	= PAGE_CACHE_SHIFT;
+	sb->s_blocksize		= PAGE_SIZE;
+	sb->s_blocksize_bits	= PAGE_SHIFT;
 	sb->s_magic		= PSTOREFS_MAGIC;
 	sb->s_op		= &pstore_ops;
 	sb->s_time_gran		= 1;
diff --git a/fs/qnx6/dir.c b/fs/qnx6/dir.c
index e1f37278cf97..144ceda4948e 100644
--- a/fs/qnx6/dir.c
+++ b/fs/qnx6/dir.c
@@ -35,9 +35,9 @@ static struct page *qnx6_get_page(struct inode *dir, unsigned long n)
 static unsigned last_entry(struct inode *inode, unsigned long page_nr)
 {
 	unsigned long last_byte = inode->i_size;
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << PAGE_SHIFT;
+	if (last_byte > PAGE_SIZE)
+		last_byte = PAGE_SIZE;
 	return last_byte / QNX6_DIR_ENTRY_SIZE;
 }
 
@@ -47,9 +47,9 @@ static struct qnx6_long_filename *qnx6_longname(struct super_block *sb,
 {
 	struct qnx6_sb_info *sbi = QNX6_SB(sb);
 	u32 s = fs32_to_cpu(sbi, de->de_long_inode); /* in block units */
-	u32 n = s >> (PAGE_CACHE_SHIFT - sb->s_blocksize_bits); /* in pages */
+	u32 n = s >> (PAGE_SHIFT - sb->s_blocksize_bits); /* in pages */
 	/* within page */
-	u32 offs = (s << sb->s_blocksize_bits) & ~PAGE_CACHE_MASK;
+	u32 offs = (s << sb->s_blocksize_bits) & ~PAGE_MASK;
 	struct address_space *mapping = sbi->longfile->i_mapping;
 	struct page *page = read_mapping_page(mapping, n, NULL);
 	if (IS_ERR(page))
@@ -115,8 +115,8 @@ static int qnx6_readdir(struct file *file, struct dir_context *ctx)
 	struct qnx6_sb_info *sbi = QNX6_SB(s);
 	loff_t pos = ctx->pos & ~(QNX6_DIR_ENTRY_SIZE - 1);
 	unsigned long npages = dir_pages(inode);
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
-	unsigned start = (pos & ~PAGE_CACHE_MASK) / QNX6_DIR_ENTRY_SIZE;
+	unsigned long n = pos >> PAGE_SHIFT;
+	unsigned start = (pos & ~PAGE_MASK) / QNX6_DIR_ENTRY_SIZE;
 	bool done = false;
 
 	ctx->pos = pos;
@@ -131,7 +131,7 @@ static int qnx6_readdir(struct file *file, struct dir_context *ctx)
 
 		if (IS_ERR(page)) {
 			pr_err("%s(): read failed\n", __func__);
-			ctx->pos = (n + 1) << PAGE_CACHE_SHIFT;
+			ctx->pos = (n + 1) << PAGE_SHIFT;
 			return PTR_ERR(page);
 		}
 		de = ((struct qnx6_dir_entry *)page_address(page)) + start;
diff --git a/fs/qnx6/inode.c b/fs/qnx6/inode.c
index 47bb1de07155..1192422a1c56 100644
--- a/fs/qnx6/inode.c
+++ b/fs/qnx6/inode.c
@@ -542,8 +542,8 @@ struct inode *qnx6_iget(struct super_block *sb, unsigned ino)
 		iget_failed(inode);
 		return ERR_PTR(-EIO);
 	}
-	n = (ino - 1) >> (PAGE_CACHE_SHIFT - QNX6_INODE_SIZE_BITS);
-	offs = (ino - 1) & (~PAGE_CACHE_MASK >> QNX6_INODE_SIZE_BITS);
+	n = (ino - 1) >> (PAGE_SHIFT - QNX6_INODE_SIZE_BITS);
+	offs = (ino - 1) & (~PAGE_MASK >> QNX6_INODE_SIZE_BITS);
 	mapping = sbi->inodes->i_mapping;
 	page = read_mapping_page(mapping, n, NULL);
 	if (IS_ERR(page)) {
diff --git a/fs/qnx6/qnx6.h b/fs/qnx6/qnx6.h
index d3fb2b698800..f23b5c4a66ad 100644
--- a/fs/qnx6/qnx6.h
+++ b/fs/qnx6/qnx6.h
@@ -128,7 +128,7 @@ extern struct qnx6_super_block *qnx6_mmi_fill_super(struct super_block *s,
 static inline void qnx6_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 extern unsigned qnx6_find_entry(int len, struct inode *dir, const char *name,
diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index 38981b037524..1ab6e6c2e60e 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -223,8 +223,8 @@ int ramfs_fill_super(struct super_block *sb, void *data, int silent)
 		return err;
 
 	sb->s_maxbytes		= MAX_LFS_FILESIZE;
-	sb->s_blocksize		= PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits	= PAGE_CACHE_SHIFT;
+	sb->s_blocksize		= PAGE_SIZE;
+	sb->s_blocksize_bits	= PAGE_SHIFT;
 	sb->s_magic		= RAMFS_MAGIC;
 	sb->s_op		= &ramfs_ops;
 	sb->s_time_gran		= 1;
diff --git a/fs/reiserfs/file.c b/fs/reiserfs/file.c
index 9424a4ba93a9..389773711de4 100644
--- a/fs/reiserfs/file.c
+++ b/fs/reiserfs/file.c
@@ -180,11 +180,11 @@ int reiserfs_commit_page(struct inode *inode, struct page *page,
 	int partial = 0;
 	unsigned blocksize;
 	struct buffer_head *bh, *head;
-	unsigned long i_size_index = inode->i_size >> PAGE_CACHE_SHIFT;
+	unsigned long i_size_index = inode->i_size >> PAGE_SHIFT;
 	int new;
 	int logit = reiserfs_file_data_log(inode);
 	struct super_block *s = inode->i_sb;
-	int bh_per_page = PAGE_CACHE_SIZE / s->s_blocksize;
+	int bh_per_page = PAGE_SIZE / s->s_blocksize;
 	struct reiserfs_transaction_handle th;
 	int ret = 0;
 
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index ae9e5b308cf9..d5c2e9c865de 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -386,7 +386,7 @@ static int _get_block_create_0(struct inode *inode, sector_t block,
 		goto finished;
 	}
 	/* read file tail into part of page */
-	offset = (cpu_key_k_offset(&key) - 1) & (PAGE_CACHE_SIZE - 1);
+	offset = (cpu_key_k_offset(&key) - 1) & (PAGE_SIZE - 1);
 	copy_item_head(&tmp_ih, ih);
 
 	/*
@@ -587,10 +587,10 @@ static int convert_tail_for_hole(struct inode *inode,
 		return -EIO;
 
 	/* always try to read until the end of the block */
-	tail_start = tail_offset & (PAGE_CACHE_SIZE - 1);
+	tail_start = tail_offset & (PAGE_SIZE - 1);
 	tail_end = (tail_start | (bh_result->b_size - 1)) + 1;
 
-	index = tail_offset >> PAGE_CACHE_SHIFT;
+	index = tail_offset >> PAGE_SHIFT;
 	/*
 	 * hole_page can be zero in case of direct_io, we are sure
 	 * that we cannot get here if we write with O_DIRECT into tail page
@@ -629,7 +629,7 @@ static int convert_tail_for_hole(struct inode *inode,
 unlock:
 	if (tail_page != hole_page) {
 		unlock_page(tail_page);
-		page_cache_release(tail_page);
+		put_page(tail_page);
 	}
 out:
 	return retval;
@@ -2189,11 +2189,11 @@ static int grab_tail_page(struct inode *inode,
 	 * we want the page with the last byte in the file,
 	 * not the page that will hold the next byte for appending
 	 */
-	unsigned long index = (inode->i_size - 1) >> PAGE_CACHE_SHIFT;
+	unsigned long index = (inode->i_size - 1) >> PAGE_SHIFT;
 	unsigned long pos = 0;
 	unsigned long start = 0;
 	unsigned long blocksize = inode->i_sb->s_blocksize;
-	unsigned long offset = (inode->i_size) & (PAGE_CACHE_SIZE - 1);
+	unsigned long offset = (inode->i_size) & (PAGE_SIZE - 1);
 	struct buffer_head *bh;
 	struct buffer_head *head;
 	struct page *page;
@@ -2251,7 +2251,7 @@ out:
 
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return error;
 }
 
@@ -2265,7 +2265,7 @@ int reiserfs_truncate_file(struct inode *inode, int update_timestamps)
 {
 	struct reiserfs_transaction_handle th;
 	/* we want the offset for the first byte after the end of the file */
-	unsigned long offset = inode->i_size & (PAGE_CACHE_SIZE - 1);
+	unsigned long offset = inode->i_size & (PAGE_SIZE - 1);
 	unsigned blocksize = inode->i_sb->s_blocksize;
 	unsigned length;
 	struct page *page = NULL;
@@ -2345,7 +2345,7 @@ int reiserfs_truncate_file(struct inode *inode, int update_timestamps)
 			}
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	reiserfs_write_unlock(inode->i_sb);
@@ -2354,7 +2354,7 @@ int reiserfs_truncate_file(struct inode *inode, int update_timestamps)
 out:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	reiserfs_write_unlock(inode->i_sb);
@@ -2426,7 +2426,7 @@ research:
 	} else if (is_direct_le_ih(ih)) {
 		char *p;
 		p = page_address(bh_result->b_page);
-		p += (byte_offset - 1) & (PAGE_CACHE_SIZE - 1);
+		p += (byte_offset - 1) & (PAGE_SIZE - 1);
 		copy_size = ih_item_len(ih) - pos_in_item;
 
 		fs_gen = get_generation(inode->i_sb);
@@ -2525,7 +2525,7 @@ static int reiserfs_write_full_page(struct page *page,
 				    struct writeback_control *wbc)
 {
 	struct inode *inode = page->mapping->host;
-	unsigned long end_index = inode->i_size >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = inode->i_size >> PAGE_SHIFT;
 	int error = 0;
 	unsigned long block;
 	sector_t last_block;
@@ -2535,7 +2535,7 @@ static int reiserfs_write_full_page(struct page *page,
 	int checked = PageChecked(page);
 	struct reiserfs_transaction_handle th;
 	struct super_block *s = inode->i_sb;
-	int bh_per_page = PAGE_CACHE_SIZE / s->s_blocksize;
+	int bh_per_page = PAGE_SIZE / s->s_blocksize;
 	th.t_trans_id = 0;
 
 	/* no logging allowed when nonblocking or from PF_MEMALLOC */
@@ -2564,16 +2564,16 @@ static int reiserfs_write_full_page(struct page *page,
 	if (page->index >= end_index) {
 		unsigned last_offset;
 
-		last_offset = inode->i_size & (PAGE_CACHE_SIZE - 1);
+		last_offset = inode->i_size & (PAGE_SIZE - 1);
 		/* no file contents in this page */
 		if (page->index >= end_index + 1 || !last_offset) {
 			unlock_page(page);
 			return 0;
 		}
-		zero_user_segment(page, last_offset, PAGE_CACHE_SIZE);
+		zero_user_segment(page, last_offset, PAGE_SIZE);
 	}
 	bh = head;
-	block = page->index << (PAGE_CACHE_SHIFT - s->s_blocksize_bits);
+	block = page->index << (PAGE_SHIFT - s->s_blocksize_bits);
 	last_block = (i_size_read(inode) - 1) >> inode->i_blkbits;
 	/* first map all the buffers, logging any direct items we find */
 	do {
@@ -2774,7 +2774,7 @@ static int reiserfs_write_begin(struct file *file,
 		*fsdata = (void *)(unsigned long)flags;
 	}
 
-	index = pos >> PAGE_CACHE_SHIFT;
+	index = pos >> PAGE_SHIFT;
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
@@ -2822,7 +2822,7 @@ static int reiserfs_write_begin(struct file *file,
 	}
 	if (ret) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		/* Truncate allocated blocks */
 		reiserfs_truncate_failed_write(inode);
 	}
@@ -2909,7 +2909,7 @@ static int reiserfs_write_end(struct file *file, struct address_space *mapping,
 	else
 		th = NULL;
 
-	start = pos & (PAGE_CACHE_SIZE - 1);
+	start = pos & (PAGE_SIZE - 1);
 	if (unlikely(copied < len)) {
 		if (!PageUptodate(page))
 			copied = 0;
@@ -2974,7 +2974,7 @@ out:
 	if (locked)
 		reiserfs_write_unlock(inode->i_sb);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (pos + len > inode->i_size)
 		reiserfs_truncate_failed_write(inode);
@@ -2996,7 +2996,7 @@ int reiserfs_commit_write(struct file *f, struct page *page,
 			  unsigned from, unsigned to)
 {
 	struct inode *inode = page->mapping->host;
-	loff_t pos = ((loff_t) page->index << PAGE_CACHE_SHIFT) + to;
+	loff_t pos = ((loff_t) page->index << PAGE_SHIFT) + to;
 	int ret = 0;
 	int update_sd = 0;
 	struct reiserfs_transaction_handle *th = NULL;
@@ -3181,7 +3181,7 @@ static void reiserfs_invalidatepage(struct page *page, unsigned int offset,
 	struct inode *inode = page->mapping->host;
 	unsigned int curr_off = 0;
 	unsigned int stop = offset + length;
-	int partial_page = (offset || length < PAGE_CACHE_SIZE);
+	int partial_page = (offset || length < PAGE_SIZE);
 	int ret = 1;
 
 	BUG_ON(!PageLocked(page));
diff --git a/fs/reiserfs/ioctl.c b/fs/reiserfs/ioctl.c
index 036a1fc0a8c3..57045f423893 100644
--- a/fs/reiserfs/ioctl.c
+++ b/fs/reiserfs/ioctl.c
@@ -203,7 +203,7 @@ int reiserfs_unpack(struct inode *inode, struct file *filp)
 	 * __reiserfs_write_begin on that page.  This will force a
 	 * reiserfs_get_block to unpack the tail for us.
 	 */
-	index = inode->i_size >> PAGE_CACHE_SHIFT;
+	index = inode->i_size >> PAGE_SHIFT;
 	mapping = inode->i_mapping;
 	page = grab_cache_page(mapping, index);
 	retval = -ENOMEM;
@@ -221,7 +221,7 @@ int reiserfs_unpack(struct inode *inode, struct file *filp)
 
 out_unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 out:
 	inode_unlock(inode);
diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
index 44c2bdced1c8..8c6487238bb3 100644
--- a/fs/reiserfs/journal.c
+++ b/fs/reiserfs/journal.c
@@ -605,12 +605,12 @@ static void release_buffer_page(struct buffer_head *bh)
 {
 	struct page *page = bh->b_page;
 	if (!page->mapping && trylock_page(page)) {
-		page_cache_get(page);
+		get_page(page);
 		put_bh(bh);
 		if (!page->mapping)
 			try_to_free_buffers(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	} else {
 		put_bh(bh);
 	}
diff --git a/fs/reiserfs/stree.c b/fs/reiserfs/stree.c
index 24cbe013240f..5feacd689241 100644
--- a/fs/reiserfs/stree.c
+++ b/fs/reiserfs/stree.c
@@ -1342,7 +1342,7 @@ int reiserfs_delete_item(struct reiserfs_transaction_handle *th,
 		 */
 
 		data = kmap_atomic(un_bh->b_page);
-		off = ((le_ih_k_offset(&s_ih) - 1) & (PAGE_CACHE_SIZE - 1));
+		off = ((le_ih_k_offset(&s_ih) - 1) & (PAGE_SIZE - 1));
 		memcpy(data + off,
 		       ih_item_body(PATH_PLAST_BUFFER(path), &s_ih),
 		       ret_value);
@@ -1511,7 +1511,7 @@ static void unmap_buffers(struct page *page, loff_t pos)
 
 	if (page) {
 		if (page_has_buffers(page)) {
-			tail_index = pos & (PAGE_CACHE_SIZE - 1);
+			tail_index = pos & (PAGE_SIZE - 1);
 			cur_index = 0;
 			head = page_buffers(page);
 			bh = head;
diff --git a/fs/reiserfs/tail_conversion.c b/fs/reiserfs/tail_conversion.c
index f41e19b4bb42..2d5489b0a269 100644
--- a/fs/reiserfs/tail_conversion.c
+++ b/fs/reiserfs/tail_conversion.c
@@ -151,7 +151,7 @@ int direct2indirect(struct reiserfs_transaction_handle *th, struct inode *inode,
 	 */
 	if (up_to_date_bh) {
 		unsigned pgoff =
-		    (tail_offset + total_tail - 1) & (PAGE_CACHE_SIZE - 1);
+		    (tail_offset + total_tail - 1) & (PAGE_SIZE - 1);
 		char *kaddr = kmap_atomic(up_to_date_bh->b_page);
 		memset(kaddr + pgoff, 0, blk_size - total_tail);
 		kunmap_atomic(kaddr);
@@ -271,7 +271,7 @@ int indirect2direct(struct reiserfs_transaction_handle *th,
 	 * the page was locked and this part of the page was up to date when
 	 * indirect2direct was called, so we know the bytes are still valid
 	 */
-	tail = tail + (pos & (PAGE_CACHE_SIZE - 1));
+	tail = tail + (pos & (PAGE_SIZE - 1));
 
 	PATH_LAST_POSITION(path)++;
 
diff --git a/fs/reiserfs/xattr.c b/fs/reiserfs/xattr.c
index 57e0b2310532..28f5f8b11370 100644
--- a/fs/reiserfs/xattr.c
+++ b/fs/reiserfs/xattr.c
@@ -415,7 +415,7 @@ out:
 static inline void reiserfs_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static struct page *reiserfs_get_page(struct inode *dir, size_t n)
@@ -427,7 +427,7 @@ static struct page *reiserfs_get_page(struct inode *dir, size_t n)
 	 * and an unlink/rmdir has just occurred - GFP_NOFS avoids this
 	 */
 	mapping_set_gfp_mask(mapping, GFP_NOFS);
-	page = read_mapping_page(mapping, n >> PAGE_CACHE_SHIFT, NULL);
+	page = read_mapping_page(mapping, n >> PAGE_SHIFT, NULL);
 	if (!IS_ERR(page)) {
 		kmap(page);
 		if (PageError(page))
@@ -526,10 +526,10 @@ reiserfs_xattr_set_handle(struct reiserfs_transaction_handle *th,
 	while (buffer_pos < buffer_size || buffer_pos == 0) {
 		size_t chunk;
 		size_t skip = 0;
-		size_t page_offset = (file_pos & (PAGE_CACHE_SIZE - 1));
+		size_t page_offset = (file_pos & (PAGE_SIZE - 1));
 
-		if (buffer_size - buffer_pos > PAGE_CACHE_SIZE)
-			chunk = PAGE_CACHE_SIZE;
+		if (buffer_size - buffer_pos > PAGE_SIZE)
+			chunk = PAGE_SIZE;
 		else
 			chunk = buffer_size - buffer_pos;
 
@@ -546,8 +546,8 @@ reiserfs_xattr_set_handle(struct reiserfs_transaction_handle *th,
 			struct reiserfs_xattr_header *rxh;
 
 			skip = file_pos = sizeof(struct reiserfs_xattr_header);
-			if (chunk + skip > PAGE_CACHE_SIZE)
-				chunk = PAGE_CACHE_SIZE - skip;
+			if (chunk + skip > PAGE_SIZE)
+				chunk = PAGE_SIZE - skip;
 			rxh = (struct reiserfs_xattr_header *)data;
 			rxh->h_magic = cpu_to_le32(REISERFS_XATTR_MAGIC);
 			rxh->h_hash = cpu_to_le32(xahash);
@@ -675,8 +675,8 @@ reiserfs_xattr_get(struct inode *inode, const char *name, void *buffer,
 		char *data;
 		size_t skip = 0;
 
-		if (isize - file_pos > PAGE_CACHE_SIZE)
-			chunk = PAGE_CACHE_SIZE;
+		if (isize - file_pos > PAGE_SIZE)
+			chunk = PAGE_SIZE;
 		else
 			chunk = isize - file_pos;
 
diff --git a/fs/splice.c b/fs/splice.c
index 9947b5c69664..b018eb485019 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -88,7 +88,7 @@ out_unlock:
 static void page_cache_pipe_buf_release(struct pipe_inode_info *pipe,
 					struct pipe_buffer *buf)
 {
-	page_cache_release(buf->page);
+	put_page(buf->page);
 	buf->flags &= ~PIPE_BUF_FLAG_LRU;
 }
 
@@ -268,7 +268,7 @@ EXPORT_SYMBOL_GPL(splice_to_pipe);
 
 void spd_release_page(struct splice_pipe_desc *spd, unsigned int i)
 {
-	page_cache_release(spd->pages[i]);
+	put_page(spd->pages[i]);
 }
 
 /*
@@ -328,9 +328,9 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 	if (splice_grow_spd(pipe, &spd))
 		return -ENOMEM;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	loff = *ppos & ~PAGE_CACHE_MASK;
-	req_pages = (len + loff + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	index = *ppos >> PAGE_SHIFT;
+	loff = *ppos & ~PAGE_MASK;
+	req_pages = (len + loff + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	nr_pages = min(req_pages, spd.nr_pages_max);
 
 	/*
@@ -365,7 +365,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 			error = add_to_page_cache_lru(page, mapping, index,
 				   mapping_gfp_constraint(mapping, GFP_KERNEL));
 			if (unlikely(error)) {
-				page_cache_release(page);
+				put_page(page);
 				if (error == -EEXIST)
 					continue;
 				break;
@@ -385,7 +385,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 	 * Now loop over the map and see if we need to start IO on any
 	 * pages, fill in the partial map, etc.
 	 */
-	index = *ppos >> PAGE_CACHE_SHIFT;
+	index = *ppos >> PAGE_SHIFT;
 	nr_pages = spd.nr_pages;
 	spd.nr_pages = 0;
 	for (page_nr = 0; page_nr < nr_pages; page_nr++) {
@@ -397,7 +397,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 		/*
 		 * this_len is the max we'll use from this page
 		 */
-		this_len = min_t(unsigned long, len, PAGE_CACHE_SIZE - loff);
+		this_len = min_t(unsigned long, len, PAGE_SIZE - loff);
 		page = spd.pages[page_nr];
 
 		if (PageReadahead(page))
@@ -426,7 +426,7 @@ retry_lookup:
 					error = -ENOMEM;
 					break;
 				}
-				page_cache_release(spd.pages[page_nr]);
+				put_page(spd.pages[page_nr]);
 				spd.pages[page_nr] = page;
 			}
 			/*
@@ -456,7 +456,7 @@ fill_it:
 		 * i_size must be checked after PageUptodate.
 		 */
 		isize = i_size_read(mapping->host);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		end_index = (isize - 1) >> PAGE_SHIFT;
 		if (unlikely(!isize || index > end_index))
 			break;
 
@@ -470,7 +470,7 @@ fill_it:
 			/*
 			 * max good bytes in this page
 			 */
-			plen = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			plen = ((isize - 1) & ~PAGE_MASK) + 1;
 			if (plen <= loff)
 				break;
 
@@ -494,8 +494,8 @@ fill_it:
 	 * we got, 'nr_pages' is how many pages are in the map.
 	 */
 	while (page_nr < nr_pages)
-		page_cache_release(spd.pages[page_nr++]);
-	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
+		put_page(spd.pages[page_nr++]);
+	in->f_ra.prev_pos = (loff_t)index << PAGE_SHIFT;
 
 	if (spd.nr_pages)
 		error = splice_to_pipe(pipe, &spd);
@@ -636,8 +636,8 @@ ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 			goto shrink_ret;
 	}
 
-	offset = *ppos & ~PAGE_CACHE_MASK;
-	nr_pages = (len + offset + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	offset = *ppos & ~PAGE_MASK;
+	nr_pages = (len + offset + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	for (i = 0; i < nr_pages && i < spd.nr_pages_max && len; i++) {
 		struct page *page;
@@ -647,7 +647,7 @@ ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 		if (!page)
 			goto err;
 
-		this_len = min_t(size_t, len, PAGE_CACHE_SIZE - offset);
+		this_len = min_t(size_t, len, PAGE_SIZE - offset);
 		vec[i].iov_base = (void __user *) page_address(page);
 		vec[i].iov_len = this_len;
 		spd.pages[i] = page;
diff --git a/fs/squashfs/block.c b/fs/squashfs/block.c
index 0cea9b9236d0..2c2618410d51 100644
--- a/fs/squashfs/block.c
+++ b/fs/squashfs/block.c
@@ -181,11 +181,11 @@ int squashfs_read_data(struct super_block *sb, u64 index, int length,
 			in = min(bytes, msblk->devblksize - offset);
 			bytes -= in;
 			while (in) {
-				if (pg_offset == PAGE_CACHE_SIZE) {
+				if (pg_offset == PAGE_SIZE) {
 					data = squashfs_next_page(output);
 					pg_offset = 0;
 				}
-				avail = min_t(int, in, PAGE_CACHE_SIZE -
+				avail = min_t(int, in, PAGE_SIZE -
 						pg_offset);
 				memcpy(data + pg_offset, bh[k]->b_data + offset,
 						avail);
diff --git a/fs/squashfs/cache.c b/fs/squashfs/cache.c
index 1cb70a0b2168..27e501af0e8b 100644
--- a/fs/squashfs/cache.c
+++ b/fs/squashfs/cache.c
@@ -255,7 +255,7 @@ struct squashfs_cache *squashfs_cache_init(char *name, int entries,
 	cache->unused = entries;
 	cache->entries = entries;
 	cache->block_size = block_size;
-	cache->pages = block_size >> PAGE_CACHE_SHIFT;
+	cache->pages = block_size >> PAGE_SHIFT;
 	cache->pages = cache->pages ? cache->pages : 1;
 	cache->name = name;
 	cache->num_waiters = 0;
@@ -275,7 +275,7 @@ struct squashfs_cache *squashfs_cache_init(char *name, int entries,
 		}
 
 		for (j = 0; j < cache->pages; j++) {
-			entry->data[j] = kmalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+			entry->data[j] = kmalloc(PAGE_SIZE, GFP_KERNEL);
 			if (entry->data[j] == NULL) {
 				ERROR("Failed to allocate %s buffer\n", name);
 				goto cleanup;
@@ -314,10 +314,10 @@ int squashfs_copy_data(void *buffer, struct squashfs_cache_entry *entry,
 		return min(length, entry->length - offset);
 
 	while (offset < entry->length) {
-		void *buff = entry->data[offset / PAGE_CACHE_SIZE]
-				+ (offset % PAGE_CACHE_SIZE);
+		void *buff = entry->data[offset / PAGE_SIZE]
+				+ (offset % PAGE_SIZE);
 		int bytes = min_t(int, entry->length - offset,
-				PAGE_CACHE_SIZE - (offset % PAGE_CACHE_SIZE));
+				PAGE_SIZE - (offset % PAGE_SIZE));
 
 		if (bytes >= remaining) {
 			memcpy(buffer, buff, remaining);
@@ -415,7 +415,7 @@ struct squashfs_cache_entry *squashfs_get_datablock(struct super_block *sb,
  */
 void *squashfs_read_table(struct super_block *sb, u64 block, int length)
 {
-	int pages = (length + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	int pages = (length + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	int i, res;
 	void *table, *buffer, **data;
 	struct squashfs_page_actor *actor;
@@ -436,7 +436,7 @@ void *squashfs_read_table(struct super_block *sb, u64 block, int length)
 		goto failed2;
 	}
 
-	for (i = 0; i < pages; i++, buffer += PAGE_CACHE_SIZE)
+	for (i = 0; i < pages; i++, buffer += PAGE_SIZE)
 		data[i] = buffer;
 
 	res = squashfs_read_data(sb, block, length |
diff --git a/fs/squashfs/decompressor.c b/fs/squashfs/decompressor.c
index e9034bf6e5ae..d2bc13636f79 100644
--- a/fs/squashfs/decompressor.c
+++ b/fs/squashfs/decompressor.c
@@ -102,7 +102,7 @@ static void *get_comp_opts(struct super_block *sb, unsigned short flags)
 	 * Read decompressor specific options from file system if present
 	 */
 	if (SQUASHFS_COMP_OPTS(flags)) {
-		buffer = kmalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+		buffer = kmalloc(PAGE_SIZE, GFP_KERNEL);
 		if (buffer == NULL) {
 			comp_opts = ERR_PTR(-ENOMEM);
 			goto out;
diff --git a/fs/squashfs/file.c b/fs/squashfs/file.c
index e5c9689062ba..437de9e89221 100644
--- a/fs/squashfs/file.c
+++ b/fs/squashfs/file.c
@@ -175,7 +175,7 @@ static long long read_indexes(struct super_block *sb, int n,
 {
 	int err, i;
 	long long block = 0;
-	__le32 *blist = kmalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+	__le32 *blist = kmalloc(PAGE_SIZE, GFP_KERNEL);
 
 	if (blist == NULL) {
 		ERROR("read_indexes: Failed to allocate block_list\n");
@@ -183,7 +183,7 @@ static long long read_indexes(struct super_block *sb, int n,
 	}
 
 	while (n) {
-		int blocks = min_t(int, n, PAGE_CACHE_SIZE >> 2);
+		int blocks = min_t(int, n, PAGE_SIZE >> 2);
 
 		err = squashfs_read_metadata(sb, blist, start_block,
 				offset, blocks << 2);
@@ -377,7 +377,7 @@ void squashfs_copy_cache(struct page *page, struct squashfs_cache_entry *buffer,
 	struct inode *inode = page->mapping->host;
 	struct squashfs_sb_info *msblk = inode->i_sb->s_fs_info;
 	void *pageaddr;
-	int i, mask = (1 << (msblk->block_log - PAGE_CACHE_SHIFT)) - 1;
+	int i, mask = (1 << (msblk->block_log - PAGE_SHIFT)) - 1;
 	int start_index = page->index & ~mask, end_index = start_index | mask;
 
 	/*
@@ -387,9 +387,9 @@ void squashfs_copy_cache(struct page *page, struct squashfs_cache_entry *buffer,
 	 * been called to fill.
 	 */
 	for (i = start_index; i <= end_index && bytes > 0; i++,
-			bytes -= PAGE_CACHE_SIZE, offset += PAGE_CACHE_SIZE) {
+			bytes -= PAGE_SIZE, offset += PAGE_SIZE) {
 		struct page *push_page;
-		int avail = buffer ? min_t(int, bytes, PAGE_CACHE_SIZE) : 0;
+		int avail = buffer ? min_t(int, bytes, PAGE_SIZE) : 0;
 
 		TRACE("bytes %d, i %d, available_bytes %d\n", bytes, i, avail);
 
@@ -404,14 +404,14 @@ void squashfs_copy_cache(struct page *page, struct squashfs_cache_entry *buffer,
 
 		pageaddr = kmap_atomic(push_page);
 		squashfs_copy_data(pageaddr, buffer, offset, avail);
-		memset(pageaddr + avail, 0, PAGE_CACHE_SIZE - avail);
+		memset(pageaddr + avail, 0, PAGE_SIZE - avail);
 		kunmap_atomic(pageaddr);
 		flush_dcache_page(push_page);
 		SetPageUptodate(push_page);
 skip_page:
 		unlock_page(push_page);
 		if (i != page->index)
-			page_cache_release(push_page);
+			put_page(push_page);
 	}
 }
 
@@ -454,7 +454,7 @@ static int squashfs_readpage(struct file *file, struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct squashfs_sb_info *msblk = inode->i_sb->s_fs_info;
-	int index = page->index >> (msblk->block_log - PAGE_CACHE_SHIFT);
+	int index = page->index >> (msblk->block_log - PAGE_SHIFT);
 	int file_end = i_size_read(inode) >> msblk->block_log;
 	int res;
 	void *pageaddr;
@@ -462,8 +462,8 @@ static int squashfs_readpage(struct file *file, struct page *page)
 	TRACE("Entered squashfs_readpage, page index %lx, start block %llx\n",
 				page->index, squashfs_i(inode)->start);
 
-	if (page->index >= ((i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
-					PAGE_CACHE_SHIFT))
+	if (page->index >= ((i_size_read(inode) + PAGE_SIZE - 1) >>
+					PAGE_SHIFT))
 		goto out;
 
 	if (index < file_end || squashfs_i(inode)->fragment_block ==
@@ -487,7 +487,7 @@ error_out:
 	SetPageError(page);
 out:
 	pageaddr = kmap_atomic(page);
-	memset(pageaddr, 0, PAGE_CACHE_SIZE);
+	memset(pageaddr, 0, PAGE_SIZE);
 	kunmap_atomic(pageaddr);
 	flush_dcache_page(page);
 	if (!PageError(page))
diff --git a/fs/squashfs/file_direct.c b/fs/squashfs/file_direct.c
index 43e7a7eddac0..cb485d8e0e91 100644
--- a/fs/squashfs/file_direct.c
+++ b/fs/squashfs/file_direct.c
@@ -30,8 +30,8 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize)
 	struct inode *inode = target_page->mapping->host;
 	struct squashfs_sb_info *msblk = inode->i_sb->s_fs_info;
 
-	int file_end = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
-	int mask = (1 << (msblk->block_log - PAGE_CACHE_SHIFT)) - 1;
+	int file_end = (i_size_read(inode) - 1) >> PAGE_SHIFT;
+	int mask = (1 << (msblk->block_log - PAGE_SHIFT)) - 1;
 	int start_index = target_page->index & ~mask;
 	int end_index = start_index | mask;
 	int i, n, pages, missing_pages, bytes, res = -ENOMEM;
@@ -68,7 +68,7 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize)
 
 		if (PageUptodate(page[i])) {
 			unlock_page(page[i]);
-			page_cache_release(page[i]);
+			put_page(page[i]);
 			page[i] = NULL;
 			missing_pages++;
 		}
@@ -96,10 +96,10 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize)
 		goto mark_errored;
 
 	/* Last page may have trailing bytes not filled */
-	bytes = res % PAGE_CACHE_SIZE;
+	bytes = res % PAGE_SIZE;
 	if (bytes) {
 		pageaddr = kmap_atomic(page[pages - 1]);
-		memset(pageaddr + bytes, 0, PAGE_CACHE_SIZE - bytes);
+		memset(pageaddr + bytes, 0, PAGE_SIZE - bytes);
 		kunmap_atomic(pageaddr);
 	}
 
@@ -109,7 +109,7 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize)
 		SetPageUptodate(page[i]);
 		unlock_page(page[i]);
 		if (page[i] != target_page)
-			page_cache_release(page[i]);
+			put_page(page[i]);
 	}
 
 	kfree(actor);
@@ -127,7 +127,7 @@ mark_errored:
 		flush_dcache_page(page[i]);
 		SetPageError(page[i]);
 		unlock_page(page[i]);
-		page_cache_release(page[i]);
+		put_page(page[i]);
 	}
 
 out:
@@ -153,21 +153,21 @@ static int squashfs_read_cache(struct page *target_page, u64 block, int bsize,
 	}
 
 	for (n = 0; n < pages && bytes > 0; n++,
-			bytes -= PAGE_CACHE_SIZE, offset += PAGE_CACHE_SIZE) {
-		int avail = min_t(int, bytes, PAGE_CACHE_SIZE);
+			bytes -= PAGE_SIZE, offset += PAGE_SIZE) {
+		int avail = min_t(int, bytes, PAGE_SIZE);
 
 		if (page[n] == NULL)
 			continue;
 
 		pageaddr = kmap_atomic(page[n]);
 		squashfs_copy_data(pageaddr, buffer, offset, avail);
-		memset(pageaddr + avail, 0, PAGE_CACHE_SIZE - avail);
+		memset(pageaddr + avail, 0, PAGE_SIZE - avail);
 		kunmap_atomic(pageaddr);
 		flush_dcache_page(page[n]);
 		SetPageUptodate(page[n]);
 		unlock_page(page[n]);
 		if (page[n] != target_page)
-			page_cache_release(page[n]);
+			put_page(page[n]);
 	}
 
 out:
diff --git a/fs/squashfs/lz4_wrapper.c b/fs/squashfs/lz4_wrapper.c
index c31e2bc9c081..ff4468bd18b0 100644
--- a/fs/squashfs/lz4_wrapper.c
+++ b/fs/squashfs/lz4_wrapper.c
@@ -117,13 +117,13 @@ static int lz4_uncompress(struct squashfs_sb_info *msblk, void *strm,
 	data = squashfs_first_page(output);
 	buff = stream->output;
 	while (data) {
-		if (bytes <= PAGE_CACHE_SIZE) {
+		if (bytes <= PAGE_SIZE) {
 			memcpy(data, buff, bytes);
 			break;
 		}
-		memcpy(data, buff, PAGE_CACHE_SIZE);
-		buff += PAGE_CACHE_SIZE;
-		bytes -= PAGE_CACHE_SIZE;
+		memcpy(data, buff, PAGE_SIZE);
+		buff += PAGE_SIZE;
+		bytes -= PAGE_SIZE;
 		data = squashfs_next_page(output);
 	}
 	squashfs_finish_page(output);
diff --git a/fs/squashfs/lzo_wrapper.c b/fs/squashfs/lzo_wrapper.c
index 244b9fbfff7b..934c17e96590 100644
--- a/fs/squashfs/lzo_wrapper.c
+++ b/fs/squashfs/lzo_wrapper.c
@@ -102,13 +102,13 @@ static int lzo_uncompress(struct squashfs_sb_info *msblk, void *strm,
 	data = squashfs_first_page(output);
 	buff = stream->output;
 	while (data) {
-		if (bytes <= PAGE_CACHE_SIZE) {
+		if (bytes <= PAGE_SIZE) {
 			memcpy(data, buff, bytes);
 			break;
 		} else {
-			memcpy(data, buff, PAGE_CACHE_SIZE);
-			buff += PAGE_CACHE_SIZE;
-			bytes -= PAGE_CACHE_SIZE;
+			memcpy(data, buff, PAGE_SIZE);
+			buff += PAGE_SIZE;
+			bytes -= PAGE_SIZE;
 			data = squashfs_next_page(output);
 		}
 	}
diff --git a/fs/squashfs/page_actor.c b/fs/squashfs/page_actor.c
index 5a1c11f56441..9b7b1b6a7892 100644
--- a/fs/squashfs/page_actor.c
+++ b/fs/squashfs/page_actor.c
@@ -48,7 +48,7 @@ struct squashfs_page_actor *squashfs_page_actor_init(void **buffer,
 	if (actor == NULL)
 		return NULL;
 
-	actor->length = length ? : pages * PAGE_CACHE_SIZE;
+	actor->length = length ? : pages * PAGE_SIZE;
 	actor->buffer = buffer;
 	actor->pages = pages;
 	actor->next_page = 0;
@@ -88,7 +88,7 @@ struct squashfs_page_actor *squashfs_page_actor_init_special(struct page **page,
 	if (actor == NULL)
 		return NULL;
 
-	actor->length = length ? : pages * PAGE_CACHE_SIZE;
+	actor->length = length ? : pages * PAGE_SIZE;
 	actor->page = page;
 	actor->pages = pages;
 	actor->next_page = 0;
diff --git a/fs/squashfs/page_actor.h b/fs/squashfs/page_actor.h
index 26dd82008b82..98537eab27e2 100644
--- a/fs/squashfs/page_actor.h
+++ b/fs/squashfs/page_actor.h
@@ -24,7 +24,7 @@ static inline struct squashfs_page_actor *squashfs_page_actor_init(void **page,
 	if (actor == NULL)
 		return NULL;
 
-	actor->length = length ? : pages * PAGE_CACHE_SIZE;
+	actor->length = length ? : pages * PAGE_SIZE;
 	actor->page = page;
 	actor->pages = pages;
 	actor->next_page = 0;
diff --git a/fs/squashfs/super.c b/fs/squashfs/super.c
index 5e79bfa4f260..cf01e15a7b16 100644
--- a/fs/squashfs/super.c
+++ b/fs/squashfs/super.c
@@ -152,7 +152,7 @@ static int squashfs_fill_super(struct super_block *sb, void *data, int silent)
 	 * Check the system page size is not larger than the filesystem
 	 * block size (by default 128K).  This is currently not supported.
 	 */
-	if (PAGE_CACHE_SIZE > msblk->block_size) {
+	if (PAGE_SIZE > msblk->block_size) {
 		ERROR("Page size > filesystem block size (%d).  This is "
 			"currently not supported!\n", msblk->block_size);
 		goto failed_mount;
diff --git a/fs/squashfs/symlink.c b/fs/squashfs/symlink.c
index dbcc2f54bad4..d688ef42a6a1 100644
--- a/fs/squashfs/symlink.c
+++ b/fs/squashfs/symlink.c
@@ -48,10 +48,10 @@ static int squashfs_symlink_readpage(struct file *file, struct page *page)
 	struct inode *inode = page->mapping->host;
 	struct super_block *sb = inode->i_sb;
 	struct squashfs_sb_info *msblk = sb->s_fs_info;
-	int index = page->index << PAGE_CACHE_SHIFT;
+	int index = page->index << PAGE_SHIFT;
 	u64 block = squashfs_i(inode)->start;
 	int offset = squashfs_i(inode)->offset;
-	int length = min_t(int, i_size_read(inode) - index, PAGE_CACHE_SIZE);
+	int length = min_t(int, i_size_read(inode) - index, PAGE_SIZE);
 	int bytes, copied;
 	void *pageaddr;
 	struct squashfs_cache_entry *entry;
@@ -94,7 +94,7 @@ static int squashfs_symlink_readpage(struct file *file, struct page *page)
 		copied = squashfs_copy_data(pageaddr + bytes, entry, offset,
 								length - bytes);
 		if (copied == length - bytes)
-			memset(pageaddr + length, 0, PAGE_CACHE_SIZE - length);
+			memset(pageaddr + length, 0, PAGE_SIZE - length);
 		else
 			block = entry->next_index;
 		kunmap_atomic(pageaddr);
diff --git a/fs/squashfs/xz_wrapper.c b/fs/squashfs/xz_wrapper.c
index c609624e4b8a..6bfaef73d065 100644
--- a/fs/squashfs/xz_wrapper.c
+++ b/fs/squashfs/xz_wrapper.c
@@ -141,7 +141,7 @@ static int squashfs_xz_uncompress(struct squashfs_sb_info *msblk, void *strm,
 	stream->buf.in_pos = 0;
 	stream->buf.in_size = 0;
 	stream->buf.out_pos = 0;
-	stream->buf.out_size = PAGE_CACHE_SIZE;
+	stream->buf.out_size = PAGE_SIZE;
 	stream->buf.out = squashfs_first_page(output);
 
 	do {
@@ -158,7 +158,7 @@ static int squashfs_xz_uncompress(struct squashfs_sb_info *msblk, void *strm,
 			stream->buf.out = squashfs_next_page(output);
 			if (stream->buf.out != NULL) {
 				stream->buf.out_pos = 0;
-				total += PAGE_CACHE_SIZE;
+				total += PAGE_SIZE;
 			}
 		}
 
diff --git a/fs/squashfs/zlib_wrapper.c b/fs/squashfs/zlib_wrapper.c
index 8727caba6882..2ec24d128bce 100644
--- a/fs/squashfs/zlib_wrapper.c
+++ b/fs/squashfs/zlib_wrapper.c
@@ -69,7 +69,7 @@ static int zlib_uncompress(struct squashfs_sb_info *msblk, void *strm,
 	int zlib_err, zlib_init = 0, k = 0;
 	z_stream *stream = strm;
 
-	stream->avail_out = PAGE_CACHE_SIZE;
+	stream->avail_out = PAGE_SIZE;
 	stream->next_out = squashfs_first_page(output);
 	stream->avail_in = 0;
 
@@ -85,7 +85,7 @@ static int zlib_uncompress(struct squashfs_sb_info *msblk, void *strm,
 		if (stream->avail_out == 0) {
 			stream->next_out = squashfs_next_page(output);
 			if (stream->next_out != NULL)
-				stream->avail_out = PAGE_CACHE_SIZE;
+				stream->avail_out = PAGE_SIZE;
 		}
 
 		if (!zlib_init) {
diff --git a/fs/sync.c b/fs/sync.c
index dd5d1711c7ac..2a54c1f22035 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -302,7 +302,7 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
 		goto out;
 
 	if (sizeof(pgoff_t) == 4) {
-		if (offset >= (0x100000000ULL << PAGE_CACHE_SHIFT)) {
+		if (offset >= (0x100000000ULL << PAGE_SHIFT)) {
 			/*
 			 * The range starts outside a 32 bit machine's
 			 * pagecache addressing capabilities.  Let it "succeed"
@@ -310,7 +310,7 @@ SYSCALL_DEFINE4(sync_file_range, int, fd, loff_t, offset, loff_t, nbytes,
 			ret = 0;
 			goto out;
 		}
-		if (endbyte >= (0x100000000ULL << PAGE_CACHE_SHIFT)) {
+		if (endbyte >= (0x100000000ULL << PAGE_SHIFT)) {
 			/*
 			 * Out to EOF
 			 */
diff --git a/fs/sysv/dir.c b/fs/sysv/dir.c
index 63c1bcb224ee..c0f0a3e643eb 100644
--- a/fs/sysv/dir.c
+++ b/fs/sysv/dir.c
@@ -30,7 +30,7 @@ const struct file_operations sysv_dir_operations = {
 static inline void dir_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 static int dir_commit_chunk(struct page *page, loff_t pos, unsigned len)
@@ -73,8 +73,8 @@ static int sysv_readdir(struct file *file, struct dir_context *ctx)
 	if (pos >= inode->i_size)
 		return 0;
 
-	offset = pos & ~PAGE_CACHE_MASK;
-	n = pos >> PAGE_CACHE_SHIFT;
+	offset = pos & ~PAGE_MASK;
+	n = pos >> PAGE_SHIFT;
 
 	for ( ; n < npages; n++, offset = 0) {
 		char *kaddr, *limit;
@@ -85,7 +85,7 @@ static int sysv_readdir(struct file *file, struct dir_context *ctx)
 			continue;
 		kaddr = (char *)page_address(page);
 		de = (struct sysv_dir_entry *)(kaddr+offset);
-		limit = kaddr + PAGE_CACHE_SIZE - SYSV_DIRSIZE;
+		limit = kaddr + PAGE_SIZE - SYSV_DIRSIZE;
 		for ( ;(char*)de <= limit; de++, ctx->pos += sizeof(*de)) {
 			char *name = de->name;
 
@@ -146,7 +146,7 @@ struct sysv_dir_entry *sysv_find_entry(struct dentry *dentry, struct page **res_
 		if (!IS_ERR(page)) {
 			kaddr = (char*)page_address(page);
 			de = (struct sysv_dir_entry *) kaddr;
-			kaddr += PAGE_CACHE_SIZE - SYSV_DIRSIZE;
+			kaddr += PAGE_SIZE - SYSV_DIRSIZE;
 			for ( ; (char *) de <= kaddr ; de++) {
 				if (!de->inode)
 					continue;
@@ -190,7 +190,7 @@ int sysv_add_link(struct dentry *dentry, struct inode *inode)
 			goto out;
 		kaddr = (char*)page_address(page);
 		de = (struct sysv_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - SYSV_DIRSIZE;
+		kaddr += PAGE_SIZE - SYSV_DIRSIZE;
 		while ((char *)de <= kaddr) {
 			if (!de->inode)
 				goto got_it;
@@ -261,7 +261,7 @@ int sysv_make_empty(struct inode *inode, struct inode *dir)
 	kmap(page);
 
 	base = (char*)page_address(page);
-	memset(base, 0, PAGE_CACHE_SIZE);
+	memset(base, 0, PAGE_SIZE);
 
 	de = (struct sysv_dir_entry *) base;
 	de->inode = cpu_to_fs16(SYSV_SB(inode->i_sb), inode->i_ino);
@@ -273,7 +273,7 @@ int sysv_make_empty(struct inode *inode, struct inode *dir)
 	kunmap(page);
 	err = dir_commit_chunk(page, 0, 2 * SYSV_DIRSIZE);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
@@ -296,7 +296,7 @@ int sysv_empty_dir(struct inode * inode)
 
 		kaddr = (char *)page_address(page);
 		de = (struct sysv_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE-SYSV_DIRSIZE;
+		kaddr += PAGE_SIZE-SYSV_DIRSIZE;
 
 		for ( ;(char *)de <= kaddr; de++) {
 			if (!de->inode)
diff --git a/fs/sysv/namei.c b/fs/sysv/namei.c
index 11e83ed0b4bf..90b60c03b588 100644
--- a/fs/sysv/namei.c
+++ b/fs/sysv/namei.c
@@ -264,11 +264,11 @@ static int sysv_rename(struct inode * old_dir, struct dentry * old_dentry,
 out_dir:
 	if (dir_de) {
 		kunmap(dir_page);
-		page_cache_release(dir_page);
+		put_page(dir_page);
 	}
 out_old:
 	kunmap(old_page);
-	page_cache_release(old_page);
+	put_page(old_page);
 out:
 	return err;
 }
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 065c88f8e4b8..1a9c6640e604 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -121,7 +121,7 @@ static int do_readpage(struct page *page)
 	if (block >= beyond) {
 		/* Reading beyond inode */
 		SetPageChecked(page);
-		memset(addr, 0, PAGE_CACHE_SIZE);
+		memset(addr, 0, PAGE_SIZE);
 		goto out;
 	}
 
@@ -223,7 +223,7 @@ static int write_begin_slow(struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct ubifs_budget_req req = { .new_page = 1 };
 	int uninitialized_var(err), appending = !!(pos + len > inode->i_size);
 	struct page *page;
@@ -254,13 +254,13 @@ static int write_begin_slow(struct address_space *mapping,
 	}
 
 	if (!PageUptodate(page)) {
-		if (!(pos & ~PAGE_CACHE_MASK) && len == PAGE_CACHE_SIZE)
+		if (!(pos & ~PAGE_MASK) && len == PAGE_SIZE)
 			SetPageChecked(page);
 		else {
 			err = do_readpage(page);
 			if (err) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				ubifs_release_budget(c, &req);
 				return err;
 			}
@@ -428,7 +428,7 @@ static int ubifs_write_begin(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
 	struct ubifs_inode *ui = ubifs_inode(inode);
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	int uninitialized_var(err), appending = !!(pos + len > inode->i_size);
 	int skipped_read = 0;
 	struct page *page;
@@ -446,7 +446,7 @@ static int ubifs_write_begin(struct file *file, struct address_space *mapping,
 
 	if (!PageUptodate(page)) {
 		/* The page is not loaded from the flash */
-		if (!(pos & ~PAGE_CACHE_MASK) && len == PAGE_CACHE_SIZE) {
+		if (!(pos & ~PAGE_MASK) && len == PAGE_SIZE) {
 			/*
 			 * We change whole page so no need to load it. But we
 			 * do not know whether this page exists on the media or
@@ -462,7 +462,7 @@ static int ubifs_write_begin(struct file *file, struct address_space *mapping,
 			err = do_readpage(page);
 			if (err) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				return err;
 			}
 		}
@@ -494,7 +494,7 @@ static int ubifs_write_begin(struct file *file, struct address_space *mapping,
 			mutex_unlock(&ui->ui_mutex);
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		return write_begin_slow(mapping, pos, len, pagep, flags);
 	}
@@ -549,7 +549,7 @@ static int ubifs_write_end(struct file *file, struct address_space *mapping,
 	dbg_gen("ino %lu, pos %llu, pg %lu, len %u, copied %d, i_size %lld",
 		inode->i_ino, pos, page->index, len, copied, inode->i_size);
 
-	if (unlikely(copied < len && len == PAGE_CACHE_SIZE)) {
+	if (unlikely(copied < len && len == PAGE_SIZE)) {
 		/*
 		 * VFS copied less data to the page that it intended and
 		 * declared in its '->write_begin()' call via the @len
@@ -593,7 +593,7 @@ static int ubifs_write_end(struct file *file, struct address_space *mapping,
 
 out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return copied;
 }
 
@@ -621,10 +621,10 @@ static int populate_page(struct ubifs_info *c, struct page *page,
 
 	addr = zaddr = kmap(page);
 
-	end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
+	end_index = (i_size - 1) >> PAGE_SHIFT;
 	if (!i_size || page->index > end_index) {
 		hole = 1;
-		memset(addr, 0, PAGE_CACHE_SIZE);
+		memset(addr, 0, PAGE_SIZE);
 		goto out_hole;
 	}
 
@@ -673,7 +673,7 @@ static int populate_page(struct ubifs_info *c, struct page *page,
 	}
 
 	if (end_index == page->index) {
-		int len = i_size & (PAGE_CACHE_SIZE - 1);
+		int len = i_size & (PAGE_SIZE - 1);
 
 		if (len && len < read)
 			memset(zaddr + len, 0, read - len);
@@ -773,7 +773,7 @@ static int ubifs_do_bulk_read(struct ubifs_info *c, struct bu_info *bu,
 	isize = i_size_read(inode);
 	if (isize == 0)
 		goto out_free;
-	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+	end_index = ((isize - 1) >> PAGE_SHIFT);
 
 	for (page_idx = 1; page_idx < page_cnt; page_idx++) {
 		pgoff_t page_offset = offset + page_idx;
@@ -788,7 +788,7 @@ static int ubifs_do_bulk_read(struct ubifs_info *c, struct bu_info *bu,
 		if (!PageUptodate(page))
 			err = populate_page(c, page, bu, &n);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		if (err)
 			break;
 	}
@@ -905,7 +905,7 @@ static int do_writepage(struct page *page, int len)
 #ifdef UBIFS_DEBUG
 	struct ubifs_inode *ui = ubifs_inode(inode);
 	spin_lock(&ui->ui_lock);
-	ubifs_assert(page->index <= ui->synced_i_size >> PAGE_CACHE_SHIFT);
+	ubifs_assert(page->index <= ui->synced_i_size >> PAGE_SHIFT);
 	spin_unlock(&ui->ui_lock);
 #endif
 
@@ -1001,8 +1001,8 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 	struct inode *inode = page->mapping->host;
 	struct ubifs_inode *ui = ubifs_inode(inode);
 	loff_t i_size =  i_size_read(inode), synced_i_size;
-	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
-	int err, len = i_size & (PAGE_CACHE_SIZE - 1);
+	pgoff_t end_index = i_size >> PAGE_SHIFT;
+	int err, len = i_size & (PAGE_SIZE - 1);
 	void *kaddr;
 
 	dbg_gen("ino %lu, pg %lu, pg flags %#lx",
@@ -1021,7 +1021,7 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 
 	/* Is the page fully inside @i_size? */
 	if (page->index < end_index) {
-		if (page->index >= synced_i_size >> PAGE_CACHE_SHIFT) {
+		if (page->index >= synced_i_size >> PAGE_SHIFT) {
 			err = inode->i_sb->s_op->write_inode(inode, NULL);
 			if (err)
 				goto out_unlock;
@@ -1034,7 +1034,7 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 			 * with this.
 			 */
 		}
-		return do_writepage(page, PAGE_CACHE_SIZE);
+		return do_writepage(page, PAGE_SIZE);
 	}
 
 	/*
@@ -1045,7 +1045,7 @@ static int ubifs_writepage(struct page *page, struct writeback_control *wbc)
 	 * writes to that region are not written out to the file."
 	 */
 	kaddr = kmap_atomic(page);
-	memset(kaddr + len, 0, PAGE_CACHE_SIZE - len);
+	memset(kaddr + len, 0, PAGE_SIZE - len);
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
 
@@ -1138,7 +1138,7 @@ static int do_truncation(struct ubifs_info *c, struct inode *inode,
 	truncate_setsize(inode, new_size);
 
 	if (offset) {
-		pgoff_t index = new_size >> PAGE_CACHE_SHIFT;
+		pgoff_t index = new_size >> PAGE_SHIFT;
 		struct page *page;
 
 		page = find_lock_page(inode->i_mapping, index);
@@ -1157,9 +1157,9 @@ static int do_truncation(struct ubifs_info *c, struct inode *inode,
 				clear_page_dirty_for_io(page);
 				if (UBIFS_BLOCKS_PER_PAGE_SHIFT)
 					offset = new_size &
-						 (PAGE_CACHE_SIZE - 1);
+						 (PAGE_SIZE - 1);
 				err = do_writepage(page, offset);
-				page_cache_release(page);
+				put_page(page);
 				if (err)
 					goto out_budg;
 				/*
@@ -1173,7 +1173,7 @@ static int do_truncation(struct ubifs_info *c, struct inode *inode,
 				 * having to read it.
 				 */
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 			}
 		}
 	}
@@ -1285,7 +1285,7 @@ static void ubifs_invalidatepage(struct page *page, unsigned int offset,
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
 
 	ubifs_assert(PagePrivate(page));
-	if (offset || length < PAGE_CACHE_SIZE)
+	if (offset || length < PAGE_SIZE)
 		/* Partial page remains dirty */
 		return;
 
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index a233ba913be4..20daea9aa657 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2240,9 +2240,9 @@ static int __init ubifs_init(void)
 	 * We require that PAGE_CACHE_SIZE is greater-than-or-equal-to
 	 * UBIFS_BLOCK_SIZE. It is assumed that both are powers of 2.
 	 */
-	if (PAGE_CACHE_SIZE < UBIFS_BLOCK_SIZE) {
+	if (PAGE_SIZE < UBIFS_BLOCK_SIZE) {
 		pr_err("UBIFS error (pid %d): VFS page cache size is %u bytes, but UBIFS requires at least 4096 bytes",
-		       current->pid, (unsigned int)PAGE_CACHE_SIZE);
+		       current->pid, (unsigned int)PAGE_SIZE);
 		return -EINVAL;
 	}
 
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index a5697de763f5..425e6a36637f 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -70,8 +70,8 @@
 #define UBIFS_SUPER_MAGIC 0x24051905
 
 /* Number of UBIFS blocks per VFS page */
-#define UBIFS_BLOCKS_PER_PAGE (PAGE_CACHE_SIZE / UBIFS_BLOCK_SIZE)
-#define UBIFS_BLOCKS_PER_PAGE_SHIFT (PAGE_CACHE_SHIFT - UBIFS_BLOCK_SHIFT)
+#define UBIFS_BLOCKS_PER_PAGE (PAGE_SIZE / UBIFS_BLOCK_SIZE)
+#define UBIFS_BLOCKS_PER_PAGE_SHIFT (PAGE_SHIFT - UBIFS_BLOCK_SHIFT)
 
 /* "File system end of life" sequence number watermark */
 #define SQNUM_WARN_WATERMARK 0xFFFFFFFF00000000ULL
diff --git a/fs/udf/file.c b/fs/udf/file.c
index 1af98963d860..877ba1c9b461 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -46,7 +46,7 @@ static void __udf_adinicb_readpage(struct page *page)
 
 	kaddr = kmap(page);
 	memcpy(kaddr, iinfo->i_ext.i_data + iinfo->i_lenEAttr, inode->i_size);
-	memset(kaddr + inode->i_size, 0, PAGE_CACHE_SIZE - inode->i_size);
+	memset(kaddr + inode->i_size, 0, PAGE_SIZE - inode->i_size);
 	flush_dcache_page(page);
 	SetPageUptodate(page);
 	kunmap(page);
@@ -87,14 +87,14 @@ static int udf_adinicb_write_begin(struct file *file,
 {
 	struct page *page;
 
-	if (WARN_ON_ONCE(pos >= PAGE_CACHE_SIZE))
+	if (WARN_ON_ONCE(pos >= PAGE_SIZE))
 		return -EIO;
 	page = grab_cache_page_write_begin(mapping, 0, flags);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
 
-	if (!PageUptodate(page) && len != PAGE_CACHE_SIZE)
+	if (!PageUptodate(page) && len != PAGE_SIZE)
 		__udf_adinicb_readpage(page);
 	return 0;
 }
diff --git a/fs/udf/inode.c b/fs/udf/inode.c
index 166d3ed32c39..2dc461eeb415 100644
--- a/fs/udf/inode.c
+++ b/fs/udf/inode.c
@@ -287,7 +287,7 @@ int udf_expand_file_adinicb(struct inode *inode)
 	if (!PageUptodate(page)) {
 		kaddr = kmap(page);
 		memset(kaddr + iinfo->i_lenAlloc, 0x00,
-		       PAGE_CACHE_SIZE - iinfo->i_lenAlloc);
+		       PAGE_SIZE - iinfo->i_lenAlloc);
 		memcpy(kaddr, iinfo->i_ext.i_data + iinfo->i_lenEAttr,
 			iinfo->i_lenAlloc);
 		flush_dcache_page(page);
@@ -319,7 +319,7 @@ int udf_expand_file_adinicb(struct inode *inode)
 		inode->i_data.a_ops = &udf_adinicb_aops;
 		up_write(&iinfo->i_data_sem);
 	}
-	page_cache_release(page);
+	put_page(page);
 	mark_inode_dirty(inode);
 
 	return err;
diff --git a/fs/ufs/balloc.c b/fs/ufs/balloc.c
index dc5fae601c24..0447b949c7f5 100644
--- a/fs/ufs/balloc.c
+++ b/fs/ufs/balloc.c
@@ -237,7 +237,7 @@ static void ufs_change_blocknr(struct inode *inode, sector_t beg,
 			       sector_t newb, struct page *locked_page)
 {
 	const unsigned blks_per_page =
-		1 << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		1 << (PAGE_SHIFT - inode->i_blkbits);
 	const unsigned mask = blks_per_page - 1;
 	struct address_space * const mapping = inode->i_mapping;
 	pgoff_t index, cur_index, last_index;
@@ -255,9 +255,9 @@ static void ufs_change_blocknr(struct inode *inode, sector_t beg,
 
 	cur_index = locked_page->index;
 	end = count + beg;
-	last_index = end >> (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	last_index = end >> (PAGE_SHIFT - inode->i_blkbits);
 	for (i = beg; i < end; i = (i | mask) + 1) {
-		index = i >> (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		index = i >> (PAGE_SHIFT - inode->i_blkbits);
 
 		if (likely(cur_index != index)) {
 			page = ufs_get_locked_page(mapping, index);
diff --git a/fs/ufs/dir.c b/fs/ufs/dir.c
index 74f2e80288bf..0b1457292734 100644
--- a/fs/ufs/dir.c
+++ b/fs/ufs/dir.c
@@ -62,7 +62,7 @@ static int ufs_commit_chunk(struct page *page, loff_t pos, unsigned len)
 static inline void ufs_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 ino_t ufs_inode_by_name(struct inode *dir, const struct qstr *qstr)
@@ -111,13 +111,13 @@ static void ufs_check_page(struct page *page)
 	struct super_block *sb = dir->i_sb;
 	char *kaddr = page_address(page);
 	unsigned offs, rec_len;
-	unsigned limit = PAGE_CACHE_SIZE;
+	unsigned limit = PAGE_SIZE;
 	const unsigned chunk_mask = UFS_SB(sb)->s_uspi->s_dirblksize - 1;
 	struct ufs_dir_entry *p;
 	char *error;
 
-	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
-		limit = dir->i_size & ~PAGE_CACHE_MASK;
+	if ((dir->i_size >> PAGE_SHIFT) == page->index) {
+		limit = dir->i_size & ~PAGE_MASK;
 		if (limit & chunk_mask)
 			goto Ebadsize;
 		if (!limit)
@@ -170,7 +170,7 @@ Einumber:
 bad_entry:
 	ufs_error (sb, "ufs_check_page", "bad entry in directory #%lu: %s - "
 		   "offset=%lu, rec_len=%d, name_len=%d",
-		   dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		   dir->i_ino, error, (page->index<<PAGE_SHIFT)+offs,
 		   rec_len, ufs_get_de_namlen(sb, p));
 	goto fail;
 Eend:
@@ -178,7 +178,7 @@ Eend:
 	ufs_error(sb, __func__,
 		   "entry in directory #%lu spans the page boundary"
 		   "offset=%lu",
-		   dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs);
+		   dir->i_ino, (page->index<<PAGE_SHIFT)+offs);
 fail:
 	SetPageChecked(page);
 	SetPageError(page);
@@ -211,9 +211,9 @@ ufs_last_byte(struct inode *inode, unsigned long page_nr)
 {
 	unsigned last_byte = inode->i_size;
 
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << PAGE_SHIFT;
+	if (last_byte > PAGE_SIZE)
+		last_byte = PAGE_SIZE;
 	return last_byte;
 }
 
@@ -341,7 +341,7 @@ int ufs_add_link(struct dentry *dentry, struct inode *inode)
 		kaddr = page_address(page);
 		dir_end = kaddr + ufs_last_byte(dir, n);
 		de = (struct ufs_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - reclen;
+		kaddr += PAGE_SIZE - reclen;
 		while ((char *)de <= kaddr) {
 			if ((char *)de == dir_end) {
 				/* We hit i_size */
@@ -432,8 +432,8 @@ ufs_readdir(struct file *file, struct dir_context *ctx)
 	loff_t pos = ctx->pos;
 	struct inode *inode = file_inode(file);
 	struct super_block *sb = inode->i_sb;
-	unsigned int offset = pos & ~PAGE_CACHE_MASK;
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
+	unsigned int offset = pos & ~PAGE_MASK;
+	unsigned long n = pos >> PAGE_SHIFT;
 	unsigned long npages = dir_pages(inode);
 	unsigned chunk_mask = ~(UFS_SB(sb)->s_uspi->s_dirblksize - 1);
 	int need_revalidate = file->f_version != inode->i_version;
@@ -454,14 +454,14 @@ ufs_readdir(struct file *file, struct dir_context *ctx)
 			ufs_error(sb, __func__,
 				  "bad page in #%lu",
 				  inode->i_ino);
-			ctx->pos += PAGE_CACHE_SIZE - offset;
+			ctx->pos += PAGE_SIZE - offset;
 			return -EIO;
 		}
 		kaddr = page_address(page);
 		if (unlikely(need_revalidate)) {
 			if (offset) {
 				offset = ufs_validate_entry(sb, kaddr, offset, chunk_mask);
-				ctx->pos = (n<<PAGE_CACHE_SHIFT) + offset;
+				ctx->pos = (n<<PAGE_SHIFT) + offset;
 			}
 			file->f_version = inode->i_version;
 			need_revalidate = 0;
@@ -574,7 +574,7 @@ int ufs_make_empty(struct inode * inode, struct inode *dir)
 
 	kmap(page);
 	base = (char*)page_address(page);
-	memset(base, 0, PAGE_CACHE_SIZE);
+	memset(base, 0, PAGE_SIZE);
 
 	de = (struct ufs_dir_entry *) base;
 
@@ -594,7 +594,7 @@ int ufs_make_empty(struct inode * inode, struct inode *dir)
 
 	err = ufs_commit_chunk(page, 0, chunk_size);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index d897e169ab9c..9f49431e798d 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -1051,13 +1051,13 @@ static int ufs_alloc_lastblock(struct inode *inode, loff_t size)
 	lastfrag--;
 
 	lastpage = ufs_get_locked_page(mapping, lastfrag >>
-				       (PAGE_CACHE_SHIFT - inode->i_blkbits));
+				       (PAGE_SHIFT - inode->i_blkbits));
        if (IS_ERR(lastpage)) {
                err = -EIO;
                goto out;
        }
 
-       end = lastfrag & ((1 << (PAGE_CACHE_SHIFT - inode->i_blkbits)) - 1);
+       end = lastfrag & ((1 << (PAGE_SHIFT - inode->i_blkbits)) - 1);
        bh = page_buffers(lastpage);
        for (i = 0; i < end; ++i)
                bh = bh->b_this_page;
diff --git a/fs/ufs/namei.c b/fs/ufs/namei.c
index acf4a3b61b81..a1559f762805 100644
--- a/fs/ufs/namei.c
+++ b/fs/ufs/namei.c
@@ -305,7 +305,7 @@ static int ufs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			ufs_set_link(old_inode, dir_de, dir_page, new_dir, 0);
 		else {
 			kunmap(dir_page);
-			page_cache_release(dir_page);
+			put_page(dir_page);
 		}
 		inode_dec_link_count(old_dir);
 	}
@@ -315,11 +315,11 @@ static int ufs_rename(struct inode *old_dir, struct dentry *old_dentry,
 out_dir:
 	if (dir_de) {
 		kunmap(dir_page);
-		page_cache_release(dir_page);
+		put_page(dir_page);
 	}
 out_old:
 	kunmap(old_page);
-	page_cache_release(old_page);
+	put_page(old_page);
 out:
 	return err;
 }
diff --git a/fs/ufs/util.c b/fs/ufs/util.c
index b6c2f94e041e..a409e3e7827a 100644
--- a/fs/ufs/util.c
+++ b/fs/ufs/util.c
@@ -261,14 +261,14 @@ struct page *ufs_get_locked_page(struct address_space *mapping,
 		if (unlikely(page->mapping == NULL)) {
 			/* Truncate got there first */
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			page = NULL;
 			goto out;
 		}
 
 		if (!PageUptodate(page) || PageError(page)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 
 			printk(KERN_ERR "ufs_change_blocknr: "
 			       "can not read page: ino %lu, index: %lu\n",
diff --git a/fs/ufs/util.h b/fs/ufs/util.h
index 954175928240..b7fbf53dbc81 100644
--- a/fs/ufs/util.h
+++ b/fs/ufs/util.h
@@ -283,7 +283,7 @@ extern struct page *ufs_get_locked_page(struct address_space *mapping,
 static inline void ufs_put_locked_page(struct page *page)
 {
        unlock_page(page);
-       page_cache_release(page);
+       put_page(page);
 }
 
 
diff --git a/fs/xfs/libxfs/xfs_bmap.c b/fs/xfs/libxfs/xfs_bmap.c
index ef00156f4f96..aafecc12a8e2 100644
--- a/fs/xfs/libxfs/xfs_bmap.c
+++ b/fs/xfs/libxfs/xfs_bmap.c
@@ -3745,11 +3745,11 @@ xfs_bmap_btalloc(
 		args.prod = align;
 		if ((args.mod = (xfs_extlen_t)do_mod(ap->offset, args.prod)))
 			args.mod = (xfs_extlen_t)(args.prod - args.mod);
-	} else if (mp->m_sb.sb_blocksize >= PAGE_CACHE_SIZE) {
+	} else if (mp->m_sb.sb_blocksize >= PAGE_SIZE) {
 		args.prod = 1;
 		args.mod = 0;
 	} else {
-		args.prod = PAGE_CACHE_SIZE >> mp->m_sb.sb_blocklog;
+		args.prod = PAGE_SIZE >> mp->m_sb.sb_blocklog;
 		if ((args.mod = (xfs_extlen_t)(do_mod(ap->offset, args.prod))))
 			args.mod = (xfs_extlen_t)(args.prod - args.mod);
 	}
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 5c57b7b40728..27fe4cc80d4a 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -726,7 +726,7 @@ xfs_convert_page(
 	 * count of buffers on the page.
 	 */
 	end_offset = min_t(unsigned long long,
-			(xfs_off_t)(page->index + 1) << PAGE_CACHE_SHIFT,
+			(xfs_off_t)(page->index + 1) << PAGE_SHIFT,
 			i_size_read(inode));
 
 	/*
@@ -749,9 +749,9 @@ xfs_convert_page(
 		goto fail_unlock_page;
 
 	len = 1 << inode->i_blkbits;
-	p_offset = min_t(unsigned long, end_offset & (PAGE_CACHE_SIZE - 1),
-					PAGE_CACHE_SIZE);
-	p_offset = p_offset ? roundup(p_offset, len) : PAGE_CACHE_SIZE;
+	p_offset = min_t(unsigned long, end_offset & (PAGE_SIZE - 1),
+					PAGE_SIZE);
+	p_offset = p_offset ? roundup(p_offset, len) : PAGE_SIZE;
 	page_dirty = p_offset / len;
 
 	/*
@@ -927,7 +927,7 @@ next_buffer:
 
 	xfs_iunlock(ip, XFS_ILOCK_EXCL);
 out_invalidate:
-	xfs_vm_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
 	return;
 }
 
@@ -984,8 +984,8 @@ xfs_vm_writepage(
 
 	/* Is this page beyond the end of the file? */
 	offset = i_size_read(inode);
-	end_index = offset >> PAGE_CACHE_SHIFT;
-	last_index = (offset - 1) >> PAGE_CACHE_SHIFT;
+	end_index = offset >> PAGE_SHIFT;
+	last_index = (offset - 1) >> PAGE_SHIFT;
 
 	/*
 	 * The page index is less than the end_index, adjust the end_offset
@@ -999,7 +999,7 @@ xfs_vm_writepage(
 	 * ---------------------------------^------------------|
 	 */
 	if (page->index < end_index)
-		end_offset = (xfs_off_t)(page->index + 1) << PAGE_CACHE_SHIFT;
+		end_offset = (xfs_off_t)(page->index + 1) << PAGE_SHIFT;
 	else {
 		/*
 		 * Check whether the page to write out is beyond or straddles
@@ -1012,7 +1012,7 @@ xfs_vm_writepage(
 		 * |				    |      Straddles     |
 		 * ---------------------------------^-----------|--------|
 		 */
-		unsigned offset_into_page = offset & (PAGE_CACHE_SIZE - 1);
+		unsigned offset_into_page = offset & (PAGE_SIZE - 1);
 
 		/*
 		 * Skip the page if it is fully outside i_size, e.g. due to a
@@ -1043,7 +1043,7 @@ xfs_vm_writepage(
 		 * memory is zeroed when mapped, and writes to that region are
 		 * not written out to the file."
 		 */
-		zero_user_segment(page, offset_into_page, PAGE_CACHE_SIZE);
+		zero_user_segment(page, offset_into_page, PAGE_SIZE);
 
 		/* Adjust the end_offset to the end of file */
 		end_offset = offset;
@@ -1162,7 +1162,7 @@ xfs_vm_writepage(
 		end_index <<= inode->i_blkbits;
 
 		/* to pages */
-		end_index = (end_index - 1) >> PAGE_CACHE_SHIFT;
+		end_index = (end_index - 1) >> PAGE_SHIFT;
 
 		/* check against file size */
 		if (end_index > last_index)
@@ -1753,7 +1753,7 @@ xfs_vm_write_failed(
 	loff_t			block_offset;
 	loff_t			block_start;
 	loff_t			block_end;
-	loff_t			from = pos & (PAGE_CACHE_SIZE - 1);
+	loff_t			from = pos & (PAGE_SIZE - 1);
 	loff_t			to = from + len;
 	struct buffer_head	*bh, *head;
 
@@ -1768,7 +1768,7 @@ xfs_vm_write_failed(
 	 * start of the page by using shifts rather than masks the mismatch
 	 * problem.
 	 */
-	block_offset = (pos >> PAGE_CACHE_SHIFT) << PAGE_CACHE_SHIFT;
+	block_offset = (pos >> PAGE_SHIFT) << PAGE_SHIFT;
 
 	ASSERT(block_offset + from == pos);
 
@@ -1825,7 +1825,7 @@ xfs_vm_write_begin(
 	struct page		**pagep,
 	void			**fsdata)
 {
-	pgoff_t			index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t			index = pos >> PAGE_SHIFT;
 	struct page		*page;
 	int			status;
 
@@ -1854,7 +1854,7 @@ xfs_vm_write_begin(
 			truncate_pagecache_range(inode, start, pos + len);
 		}
 
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 
diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 6c876012b2e5..d788858da5e1 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -1235,7 +1235,7 @@ xfs_free_file_space(
 	/* wait for the completion of any pending DIOs */
 	inode_dio_wait(VFS_I(ip));
 
-	rounding = max_t(xfs_off_t, 1 << mp->m_sb.sb_blocklog, PAGE_CACHE_SIZE);
+	rounding = max_t(xfs_off_t, 1 << mp->m_sb.sb_blocklog, PAGE_SIZE);
 	ioffset = round_down(offset, rounding);
 	iendoffset = round_up(offset + len, rounding) - 1;
 	error = filemap_write_and_wait_range(VFS_I(ip)->i_mapping, ioffset,
@@ -1464,7 +1464,7 @@ xfs_shift_file_space(
 	if (error)
 		return error;
 	error = invalidate_inode_pages2_range(VFS_I(ip)->i_mapping,
-					offset >> PAGE_CACHE_SHIFT, -1);
+					offset >> PAGE_SHIFT, -1);
 	if (error)
 		return error;
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 52883ac3cf84..aab748adf273 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -106,8 +106,8 @@ xfs_iozero(
 		unsigned offset, bytes;
 		void *fsdata;
 
-		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
-		bytes = PAGE_CACHE_SIZE - offset;
+		offset = (pos & (PAGE_SIZE -1)); /* Within page */
+		bytes = PAGE_SIZE - offset;
 		if (bytes > count)
 			bytes = count;
 
@@ -799,8 +799,8 @@ xfs_file_dio_aio_write(
 	/* see generic_file_direct_write() for why this is necessary */
 	if (mapping->nrpages) {
 		invalidate_inode_pages2_range(mapping,
-					      pos >> PAGE_CACHE_SHIFT,
-					      end >> PAGE_CACHE_SHIFT);
+					      pos >> PAGE_SHIFT,
+					      end >> PAGE_SHIFT);
 	}
 
 	if (ret > 0) {
@@ -1207,9 +1207,9 @@ xfs_find_get_desired_pgoff(
 
 	pagevec_init(&pvec, 0);
 
-	index = startoff >> PAGE_CACHE_SHIFT;
+	index = startoff >> PAGE_SHIFT;
 	endoff = XFS_FSB_TO_B(mp, map->br_startoff + map->br_blockcount);
-	end = endoff >> PAGE_CACHE_SHIFT;
+	end = endoff >> PAGE_SHIFT;
 	do {
 		int		want;
 		unsigned	nr_pages;
diff --git a/fs/xfs/xfs_linux.h b/fs/xfs/xfs_linux.h
index ec0e239a0fa9..a8192dc797dc 100644
--- a/fs/xfs/xfs_linux.h
+++ b/fs/xfs/xfs_linux.h
@@ -135,7 +135,7 @@ typedef __u32			xfs_nlink_t;
  * Size of block device i/o is parameterized here.
  * Currently the system supports page-sized i/o.
  */
-#define	BLKDEV_IOSHIFT		PAGE_CACHE_SHIFT
+#define	BLKDEV_IOSHIFT		PAGE_SHIFT
 #define	BLKDEV_IOSIZE		(1<<BLKDEV_IOSHIFT)
 /* number of BB's per block device block */
 #define	BLKDEV_BB		BTOBB(BLKDEV_IOSIZE)
diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
index bb753b359bee..9091e2fe1e0c 100644
--- a/fs/xfs/xfs_mount.c
+++ b/fs/xfs/xfs_mount.c
@@ -171,7 +171,7 @@ xfs_sb_validate_fsb_count(
 	ASSERT(sbp->sb_blocklog >= BBSHIFT);
 
 	/* Limited by ULONG_MAX of page cache index */
-	if (nblocks >> (PAGE_CACHE_SHIFT - sbp->sb_blocklog) > ULONG_MAX)
+	if (nblocks >> (PAGE_SHIFT - sbp->sb_blocklog) > ULONG_MAX)
 		return -EFBIG;
 	return 0;
 }
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index b57098481c10..cd2cb5ef4c08 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -221,12 +221,12 @@ static inline unsigned long
 xfs_preferred_iosize(xfs_mount_t *mp)
 {
 	if (mp->m_flags & XFS_MOUNT_COMPAT_IOSIZE)
-		return PAGE_CACHE_SIZE;
+		return PAGE_SIZE;
 	return (mp->m_swidth ?
 		(mp->m_swidth << mp->m_sb.sb_blocklog) :
 		((mp->m_flags & XFS_MOUNT_DFLT_IOSIZE) ?
 			(1 << (int)MAX(mp->m_readio_log, mp->m_writeio_log)) :
-			PAGE_CACHE_SIZE));
+			PAGE_SIZE));
 }
 
 #define XFS_LAST_UNMOUNT_WAS_CLEAN(mp)	\
diff --git a/fs/xfs/xfs_pnfs.c b/fs/xfs/xfs_pnfs.c
index ade236e90bb3..51ddaf2c2b8c 100644
--- a/fs/xfs/xfs_pnfs.c
+++ b/fs/xfs/xfs_pnfs.c
@@ -293,8 +293,8 @@ xfs_fs_commit_blocks(
 		 * Make sure reads through the pagecache see the new data.
 		 */
 		error = invalidate_inode_pages2_range(inode->i_mapping,
-					start >> PAGE_CACHE_SHIFT,
-					(end - 1) >> PAGE_CACHE_SHIFT);
+					start >> PAGE_SHIFT,
+					(end - 1) >> PAGE_SHIFT);
 		WARN_ON_ONCE(error);
 
 		error = xfs_iomap_write_unwritten(ip, start, length);
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 59c9b7bd958d..aadd6fe75f8f 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -561,10 +561,10 @@ xfs_max_file_offset(
 #if BITS_PER_LONG == 32
 # if defined(CONFIG_LBDAF)
 	ASSERT(sizeof(sector_t) == 8);
-	pagefactor = PAGE_CACHE_SIZE;
+	pagefactor = PAGE_SIZE;
 	bitshift = BITS_PER_LONG;
 # else
-	pagefactor = PAGE_CACHE_SIZE >> (PAGE_CACHE_SHIFT - blockshift);
+	pagefactor = PAGE_SIZE >> (PAGE_SHIFT - blockshift);
 # endif
 #endif
 
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 88bc64f00bb5..6b7481f62218 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -41,7 +41,7 @@
 #endif
 
 #define BIO_MAX_PAGES		256
-#define BIO_MAX_SIZE		(BIO_MAX_PAGES << PAGE_CACHE_SHIFT)
+#define BIO_MAX_SIZE		(BIO_MAX_PAGES << PAGE_SHIFT)
 #define BIO_MAX_SECTORS		(BIO_MAX_SIZE >> 9)
 
 /*
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 7e5d7e018bea..669e419d6234 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1372,7 +1372,7 @@ unsigned char *read_dev_sector(struct block_device *, sector_t, Sector *);
 
 static inline void put_dev_sector(Sector p)
 {
-	page_cache_release(p.v);
+	put_page(p.v);
 }
 
 static inline bool __bvec_gap_to_prev(struct request_queue *q,
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index c67f052cc5e5..d48daa3f6f20 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -43,7 +43,7 @@ enum bh_state_bits {
 			 */
 };
 
-#define MAX_BUF_PER_PAGE (PAGE_CACHE_SIZE / 512)
+#define MAX_BUF_PER_PAGE (PAGE_SIZE / 512)
 
 struct page;
 struct buffer_head;
@@ -263,7 +263,7 @@ void buffer_init(void);
 static inline void attach_page_buffers(struct page *page,
 		struct buffer_head *head)
 {
-	page_cache_get(page);
+	get_page(page);
 	SetPagePrivate(page);
 	set_page_private(page, (unsigned long)head);
 }
diff --git a/include/linux/ceph/libceph.h b/include/linux/ceph/libceph.h
index 3e3799cdc6e6..9092a92400ac 100644
--- a/include/linux/ceph/libceph.h
+++ b/include/linux/ceph/libceph.h
@@ -172,8 +172,8 @@ extern void ceph_put_snap_context(struct ceph_snap_context *sc);
  */
 static inline int calc_pages_for(u64 off, u64 len)
 {
-	return ((off+len+PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT) -
-		(off >> PAGE_CACHE_SHIFT);
+	return ((off+len+PAGE_SIZE-1) >> PAGE_SHIFT) -
+		(off >> PAGE_SHIFT);
 }
 
 extern struct kmem_cache *ceph_inode_cachep;
diff --git a/include/linux/f2fs_fs.h b/include/linux/f2fs_fs.h
index e59c3be92106..4a793b045efa 100644
--- a/include/linux/f2fs_fs.h
+++ b/include/linux/f2fs_fs.h
@@ -262,7 +262,7 @@ struct f2fs_node {
 /*
  * For NAT entries
  */
-#define NAT_ENTRY_PER_BLOCK (PAGE_CACHE_SIZE / sizeof(struct f2fs_nat_entry))
+#define NAT_ENTRY_PER_BLOCK (PAGE_SIZE / sizeof(struct f2fs_nat_entry))
 
 struct f2fs_nat_entry {
 	__u8 version;		/* latest version of cached nat entry */
@@ -282,7 +282,7 @@ struct f2fs_nat_block {
  * Not allow to change this.
  */
 #define SIT_VBLOCK_MAP_SIZE 64
-#define SIT_ENTRY_PER_BLOCK (PAGE_CACHE_SIZE / sizeof(struct f2fs_sit_entry))
+#define SIT_ENTRY_PER_BLOCK (PAGE_SIZE / sizeof(struct f2fs_sit_entry))
 
 /*
  * Note that f2fs_sit_entry->vblocks has the following bit-field information.
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bb703ef728d1..8f30e69a8501 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -923,7 +923,7 @@ static inline struct file *get_file(struct file *f)
 /* Page cache limit. The filesystems should put that into their s_maxbytes 
    limits, otherwise bad things can happen in VM. */ 
 #if BITS_PER_LONG==32
-#define MAX_LFS_FILESIZE	(((loff_t)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1) 
+#define MAX_LFS_FILESIZE	(((loff_t)PAGE_SIZE << (BITS_PER_LONG-1))-1) 
 #elif BITS_PER_LONG==64
 #define MAX_LFS_FILESIZE 	((loff_t)0x7fffffffffffffffLL)
 #endif
@@ -2059,7 +2059,7 @@ extern int generic_update_time(struct inode *, struct timespec *, int);
 /* /sys/fs */
 extern struct kobject *fs_kobj;
 
-#define MAX_RW_COUNT (INT_MAX & PAGE_CACHE_MASK)
+#define MAX_RW_COUNT (INT_MAX & PAGE_MASK)
 
 #ifdef CONFIG_MANDATORY_FILE_LOCKING
 extern int locks_mandatory_locked(struct file *);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index f2f650f136ee..efada239205e 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -184,7 +184,7 @@ nfs_list_entry(struct list_head *head)
 static inline
 loff_t req_offset(struct nfs_page *req)
 {
-	return (((loff_t)req->wb_index) << PAGE_CACHE_SHIFT) + req->wb_offset;
+	return (((loff_t)req->wb_index) << PAGE_SHIFT) + req->wb_offset;
 }
 
 #endif /* _LINUX_NFS_PAGE_H */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 1ebd65c91422..f396ccb900cc 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -390,13 +390,13 @@ static inline pgoff_t page_to_pgoff(struct page *page)
 		return page->index << compound_order(page);
 
 	if (likely(!PageTransTail(page)))
-		return page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+		return page->index;
 
 	/*
 	 *  We don't initialize ->index for tail pages: calculate based on
 	 *  head page
 	 */
-	pgoff = compound_head(page)->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff = compound_head(page)->index;
 	pgoff += page - compound_head(page);
 	return pgoff;
 }
@@ -406,12 +406,12 @@ static inline pgoff_t page_to_pgoff(struct page *page)
  */
 static inline loff_t page_offset(struct page *page)
 {
-	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
+	return ((loff_t)page->index) << PAGE_SHIFT;
 }
 
 static inline loff_t page_file_offset(struct page *page)
 {
-	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
+	return ((loff_t)page_file_index(page)) << PAGE_SHIFT;
 }
 
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
@@ -425,7 +425,7 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 		return linear_hugepage_index(vma, address);
 	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
 	pgoff += vma->vm_pgoff;
-	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	return pgoff;
 }
 
 extern void __lock_page(struct page *page);
@@ -671,8 +671,8 @@ static inline int add_to_page_cache(struct page *page,
 
 static inline unsigned long dir_pages(struct inode *inode)
 {
-	return (unsigned long)(inode->i_size + PAGE_CACHE_SIZE - 1) >>
-			       PAGE_CACHE_SHIFT;
+	return (unsigned long)(inode->i_size + PAGE_SIZE - 1) >>
+			       PAGE_SHIFT;
 }
 
 #endif /* _LINUX_PAGEMAP_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index d18b65c53dbb..3d980ea1c946 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -435,7 +435,7 @@ struct backing_dev_info;
 /* only sparc can not include linux/pagemap.h in this file
  * so leave page_cache_release and release_pages undeclared... */
 #define free_page_and_swap_cache(page) \
-	page_cache_release(page)
+	put_page(page)
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), false);
 
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 781c1399c6a3..ade739f67f1d 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -307,8 +307,8 @@ static int mqueue_fill_super(struct super_block *sb, void *data, int silent)
 	struct inode *inode;
 	struct ipc_namespace *ns = data;
 
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = MQUEUE_MAGIC;
 	sb->s_op = &mqueue_super_ops;
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 220fc17b9718..7edc95edfaee 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -321,7 +321,7 @@ retry:
 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
 
 	ret = __replace_page(vma, vaddr, old_page, new_page);
-	page_cache_release(new_page);
+	put_page(new_page);
 put_old:
 	put_page(old_page);
 
@@ -539,14 +539,14 @@ static int __copy_insn(struct address_space *mapping, struct file *filp,
 	 * see uprobe_register().
 	 */
 	if (mapping->a_ops->readpage)
-		page = read_mapping_page(mapping, offset >> PAGE_CACHE_SHIFT, filp);
+		page = read_mapping_page(mapping, offset >> PAGE_SHIFT, filp);
 	else
-		page = shmem_read_mapping_page(mapping, offset >> PAGE_CACHE_SHIFT);
+		page = shmem_read_mapping_page(mapping, offset >> PAGE_SHIFT);
 	if (IS_ERR(page))
 		return PTR_ERR(page);
 
 	copy_from_page(page, offset, insn, nbytes);
-	page_cache_release(page);
+	put_page(page);
 
 	return 0;
 }
diff --git a/mm/fadvise.c b/mm/fadvise.c
index b8a5bc66b0c0..b8024fa7101d 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -97,8 +97,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		break;
 	case POSIX_FADV_WILLNEED:
 		/* First and last PARTIAL page! */
-		start_index = offset >> PAGE_CACHE_SHIFT;
-		end_index = endbyte >> PAGE_CACHE_SHIFT;
+		start_index = offset >> PAGE_SHIFT;
+		end_index = endbyte >> PAGE_SHIFT;
 
 		/* Careful about overflow on the "+1" */
 		nrpages = end_index - start_index + 1;
@@ -124,8 +124,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		 * preserved on the expectation that it is better to preserve
 		 * needed memory than to discard unneeded memory.
 		 */
-		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
-		end_index = (endbyte >> PAGE_CACHE_SHIFT);
+		start_index = (offset+(PAGE_SIZE-1)) >> PAGE_SHIFT;
+		end_index = (endbyte >> PAGE_SHIFT);
 
 		if (end_index >= start_index) {
 			unsigned long count = invalidate_mapping_pages(mapping,
diff --git a/mm/filemap.c b/mm/filemap.c
index 7c00f105845e..96f3b0322652 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -265,7 +265,7 @@ void delete_from_page_cache(struct page *page)
 
 	if (freepage)
 		freepage(page);
-	page_cache_release(page);
+	put_page(page);
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
@@ -352,8 +352,8 @@ EXPORT_SYMBOL(filemap_flush);
 static int __filemap_fdatawait_range(struct address_space *mapping,
 				     loff_t start_byte, loff_t end_byte)
 {
-	pgoff_t index = start_byte >> PAGE_CACHE_SHIFT;
-	pgoff_t end = end_byte >> PAGE_CACHE_SHIFT;
+	pgoff_t index = start_byte >> PAGE_SHIFT;
+	pgoff_t end = end_byte >> PAGE_SHIFT;
 	struct pagevec pvec;
 	int nr_pages;
 	int ret = 0;
@@ -550,7 +550,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		pgoff_t offset = old->index;
 		freepage = mapping->a_ops->freepage;
 
-		page_cache_get(new);
+		get_page(new);
 		new->mapping = mapping;
 		new->index = offset;
 
@@ -572,7 +572,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		radix_tree_preload_end();
 		if (freepage)
 			freepage(old);
-		page_cache_release(old);
+		put_page(old);
 	}
 
 	return error;
@@ -651,7 +651,7 @@ static int __add_to_page_cache_locked(struct page *page,
 		return error;
 	}
 
-	page_cache_get(page);
+	get_page(page);
 	page->mapping = mapping;
 	page->index = offset;
 
@@ -675,7 +675,7 @@ err_insert:
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!huge)
 		mem_cgroup_cancel_charge(page, memcg, false);
-	page_cache_release(page);
+	put_page(page);
 	return error;
 }
 
@@ -1083,7 +1083,7 @@ repeat:
 		 * include/linux/pagemap.h for details.
 		 */
 		if (unlikely(page != *pagep)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 	}
@@ -1121,7 +1121,7 @@ repeat:
 		/* Has the page been truncated? */
 		if (unlikely(page->mapping != mapping)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 		VM_BUG_ON_PAGE(page->index != offset, page);
@@ -1168,7 +1168,7 @@ repeat:
 	if (fgp_flags & FGP_LOCK) {
 		if (fgp_flags & FGP_NOWAIT) {
 			if (!trylock_page(page)) {
-				page_cache_release(page);
+				put_page(page);
 				return NULL;
 			}
 		} else {
@@ -1178,7 +1178,7 @@ repeat:
 		/* Has the page been truncated? */
 		if (unlikely(page->mapping != mapping)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 		VM_BUG_ON_PAGE(page->index != offset, page);
@@ -1209,7 +1209,7 @@ no_page:
 		err = add_to_page_cache_lru(page, mapping, offset,
 				gfp_mask & GFP_RECLAIM_MASK);
 		if (unlikely(err)) {
-			page_cache_release(page);
+			put_page(page);
 			page = NULL;
 			if (err == -EEXIST)
 				goto repeat;
@@ -1278,7 +1278,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 export:
@@ -1343,7 +1343,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -1405,7 +1405,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -1415,7 +1415,7 @@ repeat:
 		 * negatives, which is just confusing to the caller.
 		 */
 		if (page->mapping == NULL || page->index != iter.index) {
-			page_cache_release(page);
+			put_page(page);
 			break;
 		}
 
@@ -1482,7 +1482,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -1549,7 +1549,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 export:
@@ -1610,11 +1610,11 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 	unsigned int prev_offset;
 	int error = 0;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	prev_index = ra->prev_pos >> PAGE_CACHE_SHIFT;
-	prev_offset = ra->prev_pos & (PAGE_CACHE_SIZE-1);
-	last_index = (*ppos + iter->count + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	index = *ppos >> PAGE_SHIFT;
+	prev_index = ra->prev_pos >> PAGE_SHIFT;
+	prev_offset = ra->prev_pos & (PAGE_SIZE-1);
+	last_index = (*ppos + iter->count + PAGE_SIZE-1) >> PAGE_SHIFT;
+	offset = *ppos & ~PAGE_MASK;
 
 	for (;;) {
 		struct page *page;
@@ -1648,7 +1648,7 @@ find_page:
 			if (PageUptodate(page))
 				goto page_ok;
 
-			if (inode->i_blkbits == PAGE_CACHE_SHIFT ||
+			if (inode->i_blkbits == PAGE_SHIFT ||
 					!mapping->a_ops->is_partially_uptodate)
 				goto page_not_up_to_date;
 			if (!trylock_page(page))
@@ -1672,18 +1672,18 @@ page_ok:
 		 */
 
 		isize = i_size_read(inode);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		end_index = (isize - 1) >> PAGE_SHIFT;
 		if (unlikely(!isize || index > end_index)) {
-			page_cache_release(page);
+			put_page(page);
 			goto out;
 		}
 
 		/* nr is the maximum number of bytes to copy from this page */
-		nr = PAGE_CACHE_SIZE;
+		nr = PAGE_SIZE;
 		if (index == end_index) {
-			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			nr = ((isize - 1) & ~PAGE_MASK) + 1;
 			if (nr <= offset) {
-				page_cache_release(page);
+				put_page(page);
 				goto out;
 			}
 		}
@@ -1711,11 +1711,11 @@ page_ok:
 
 		ret = copy_page_to_iter(page, offset, nr, iter);
 		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		index += offset >> PAGE_SHIFT;
+		offset &= ~PAGE_MASK;
 		prev_offset = offset;
 
-		page_cache_release(page);
+		put_page(page);
 		written += ret;
 		if (!iov_iter_count(iter))
 			goto out;
@@ -1735,7 +1735,7 @@ page_not_up_to_date_locked:
 		/* Did it get truncated before we got the lock? */
 		if (!page->mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -1757,7 +1757,7 @@ readpage:
 
 		if (unlikely(error)) {
 			if (error == AOP_TRUNCATED_PAGE) {
-				page_cache_release(page);
+				put_page(page);
 				error = 0;
 				goto find_page;
 			}
@@ -1774,7 +1774,7 @@ readpage:
 					 * invalidate_mapping_pages got it
 					 */
 					unlock_page(page);
-					page_cache_release(page);
+					put_page(page);
 					goto find_page;
 				}
 				unlock_page(page);
@@ -1789,7 +1789,7 @@ readpage:
 
 readpage_error:
 		/* UHHUH! A synchronous read error occurred. Report it */
-		page_cache_release(page);
+		put_page(page);
 		goto out;
 
 no_cached_page:
@@ -1805,7 +1805,7 @@ no_cached_page:
 		error = add_to_page_cache_lru(page, mapping, index,
 				mapping_gfp_constraint(mapping, GFP_KERNEL));
 		if (error) {
-			page_cache_release(page);
+			put_page(page);
 			if (error == -EEXIST) {
 				error = 0;
 				goto find_page;
@@ -1817,10 +1817,10 @@ no_cached_page:
 
 out:
 	ra->prev_pos = prev_index;
-	ra->prev_pos <<= PAGE_CACHE_SHIFT;
+	ra->prev_pos <<= PAGE_SHIFT;
 	ra->prev_pos |= prev_offset;
 
-	*ppos = ((loff_t)index << PAGE_CACHE_SHIFT) + offset;
+	*ppos = ((loff_t)index << PAGE_SHIFT) + offset;
 	file_accessed(filp);
 	return written ? written : error;
 }
@@ -1911,7 +1911,7 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
 		else if (ret == -EEXIST)
 			ret = 0; /* losing race to add is OK */
 
-		page_cache_release(page);
+		put_page(page);
 
 	} while (ret == AOP_TRUNCATED_PAGE);
 
@@ -2021,8 +2021,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	loff_t size;
 	int ret = 0;
 
-	size = round_up(i_size_read(inode), PAGE_CACHE_SIZE);
-	if (offset >= size >> PAGE_CACHE_SHIFT)
+	size = round_up(i_size_read(inode), PAGE_SIZE);
+	if (offset >= size >> PAGE_SHIFT)
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -2048,7 +2048,7 @@ retry_find:
 	}
 
 	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
-		page_cache_release(page);
+		put_page(page);
 		return ret | VM_FAULT_RETRY;
 	}
 
@@ -2071,10 +2071,10 @@ retry_find:
 	 * Found the page and have a reference on it.
 	 * We must recheck i_size under page lock.
 	 */
-	size = round_up(i_size_read(inode), PAGE_CACHE_SIZE);
-	if (unlikely(offset >= size >> PAGE_CACHE_SHIFT)) {
+	size = round_up(i_size_read(inode), PAGE_SIZE);
+	if (unlikely(offset >= size >> PAGE_SHIFT)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return VM_FAULT_SIGBUS;
 	}
 
@@ -2119,7 +2119,7 @@ page_not_uptodate:
 		if (!PageUptodate(page))
 			error = -EIO;
 	}
-	page_cache_release(page);
+	put_page(page);
 
 	if (!error || error == AOP_TRUNCATED_PAGE)
 		goto retry_find;
@@ -2163,7 +2163,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -2177,8 +2177,8 @@ repeat:
 		if (page->mapping != mapping || !PageUptodate(page))
 			goto unlock;
 
-		size = round_up(i_size_read(mapping->host), PAGE_CACHE_SIZE);
-		if (page->index >= size >> PAGE_CACHE_SHIFT)
+		size = round_up(i_size_read(mapping->host), PAGE_SIZE);
+		if (page->index >= size >> PAGE_SHIFT)
 			goto unlock;
 
 		pte = vmf->pte + page->index - vmf->pgoff;
@@ -2194,7 +2194,7 @@ repeat:
 unlock:
 		unlock_page(page);
 skip:
-		page_cache_release(page);
+		put_page(page);
 next:
 		if (iter.index == vmf->max_pgoff)
 			break;
@@ -2277,7 +2277,7 @@ static struct page *wait_on_page_read(struct page *page)
 	if (!IS_ERR(page)) {
 		wait_on_page_locked(page);
 		if (!PageUptodate(page)) {
-			page_cache_release(page);
+			put_page(page);
 			page = ERR_PTR(-EIO);
 		}
 	}
@@ -2300,7 +2300,7 @@ repeat:
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
 		if (unlikely(err)) {
-			page_cache_release(page);
+			put_page(page);
 			if (err == -EEXIST)
 				goto repeat;
 			/* Presumably ENOMEM for radix tree node */
@@ -2310,7 +2310,7 @@ repeat:
 filler:
 		err = filler(data, page);
 		if (err < 0) {
-			page_cache_release(page);
+			put_page(page);
 			return ERR_PTR(err);
 		}
 
@@ -2363,7 +2363,7 @@ filler:
 	/* Case c or d, restart the operation */
 	if (!page->mapping) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		goto repeat;
 	}
 
@@ -2510,7 +2510,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos)
 	struct iov_iter data;
 
 	write_len = iov_iter_count(from);
-	end = (pos + write_len - 1) >> PAGE_CACHE_SHIFT;
+	end = (pos + write_len - 1) >> PAGE_SHIFT;
 
 	written = filemap_write_and_wait_range(mapping, pos, pos + write_len - 1);
 	if (written)
@@ -2524,7 +2524,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos)
 	 */
 	if (mapping->nrpages) {
 		written = invalidate_inode_pages2_range(mapping,
-					pos >> PAGE_CACHE_SHIFT, end);
+					pos >> PAGE_SHIFT, end);
 		/*
 		 * If a page can not be invalidated, return 0 to fall back
 		 * to buffered write.
@@ -2549,7 +2549,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos)
 	 */
 	if (mapping->nrpages) {
 		invalidate_inode_pages2_range(mapping,
-					      pos >> PAGE_CACHE_SHIFT, end);
+					      pos >> PAGE_SHIFT, end);
 	}
 
 	if (written > 0) {
@@ -2610,8 +2610,8 @@ ssize_t generic_perform_write(struct file *file,
 		size_t copied;		/* Bytes copied from user */
 		void *fsdata;
 
-		offset = (pos & (PAGE_CACHE_SIZE - 1));
-		bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
+		offset = (pos & (PAGE_SIZE - 1));
+		bytes = min_t(unsigned long, PAGE_SIZE - offset,
 						iov_iter_count(i));
 
 again:
@@ -2664,7 +2664,7 @@ again:
 			 * because not all segments in the iov can be copied at
 			 * once without a pagefault.
 			 */
-			bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
+			bytes = min_t(unsigned long, PAGE_SIZE - offset,
 						iov_iter_single_seg_count(i));
 			goto again;
 		}
@@ -2751,8 +2751,8 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 			iocb->ki_pos = endbyte + 1;
 			written += status;
 			invalidate_mapping_pages(mapping,
-						 pos >> PAGE_CACHE_SHIFT,
-						 endbyte >> PAGE_CACHE_SHIFT);
+						 pos >> PAGE_SHIFT,
+						 endbyte >> PAGE_SHIFT);
 		} else {
 			/*
 			 * We don't know how much we wrote, so just return
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 06058eaa173b..19d0d08b396f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3346,7 +3346,7 @@ retry_avoidcopy:
 			old_page != pagecache_page)
 		outside_reserve = 1;
 
-	page_cache_get(old_page);
+	get_page(old_page);
 
 	/*
 	 * Drop page table lock as buddy allocator may be called. It will
@@ -3364,7 +3364,7 @@ retry_avoidcopy:
 		 * may get SIGKILLed if it later faults.
 		 */
 		if (outside_reserve) {
-			page_cache_release(old_page);
+			put_page(old_page);
 			BUG_ON(huge_pte_none(pte));
 			unmap_ref_private(mm, vma, old_page, address);
 			BUG_ON(huge_pte_none(pte));
@@ -3425,9 +3425,9 @@ retry_avoidcopy:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 out_release_all:
-	page_cache_release(new_page);
+	put_page(new_page);
 out_release_old:
-	page_cache_release(old_page);
+	put_page(old_page);
 
 	spin_lock(ptl); /* Caller expects lock to be held */
 	return ret;
diff --git a/mm/madvise.c b/mm/madvise.c
index a01147359f3b..07427d3fcead 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -170,7 +170,7 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
 								vma, index);
 		if (page)
-			page_cache_release(page);
+			put_page(page);
 	}
 
 	return 0;
@@ -204,14 +204,14 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
 		page = find_get_entry(mapping, index);
 		if (!radix_tree_exceptional_entry(page)) {
 			if (page)
-				page_cache_release(page);
+				put_page(page);
 			continue;
 		}
 		swap = radix_to_swp_entry(page);
 		page = read_swap_cache_async(swap, GFP_HIGHUSER_MOVABLE,
 								NULL, 0);
 		if (page)
-			page_cache_release(page);
+			put_page(page);
 	}
 
 	lru_add_drain();	/* Push any new pages onto the LRU now */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 5a544c6c0717..78f5f2641b91 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -538,7 +538,7 @@ static int delete_from_lru_cache(struct page *p)
 		/*
 		 * drop the page count elevated by isolate_lru_page()
 		 */
-		page_cache_release(p);
+		put_page(p);
 		return 0;
 	}
 	return -EIO;
diff --git a/mm/memory.c b/mm/memory.c
index 81dca0083fcd..a2b97af99124 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2051,7 +2051,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 		VM_BUG_ON_PAGE(PageAnon(page), page);
 		mapping = page->mapping;
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		if ((dirtied || page_mkwrite) && mapping) {
 			/*
@@ -2185,7 +2185,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	if (new_page)
-		page_cache_release(new_page);
+		put_page(new_page);
 
 	pte_unmap_unlock(page_table, ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
@@ -2200,14 +2200,14 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 				munlock_vma_page(old_page);
 			unlock_page(old_page);
 		}
-		page_cache_release(old_page);
+		put_page(old_page);
 	}
 	return page_copied ? VM_FAULT_WRITE : 0;
 oom_free_new:
-	page_cache_release(new_page);
+	put_page(new_page);
 oom:
 	if (old_page)
-		page_cache_release(old_page);
+		put_page(old_page);
 	return VM_FAULT_OOM;
 }
 
@@ -2255,7 +2255,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	int page_mkwrite = 0;
 
-	page_cache_get(old_page);
+	get_page(old_page);
 
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
 		int tmp;
@@ -2264,7 +2264,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 		tmp = do_page_mkwrite(vma, old_page, address);
 		if (unlikely(!tmp || (tmp &
 				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
-			page_cache_release(old_page);
+			put_page(old_page);
 			return tmp;
 		}
 		/*
@@ -2278,7 +2278,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (!pte_same(*page_table, orig_pte)) {
 			unlock_page(old_page);
 			pte_unmap_unlock(page_table, ptl);
-			page_cache_release(old_page);
+			put_page(old_page);
 			return 0;
 		}
 		page_mkwrite = 1;
@@ -2338,7 +2338,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (PageAnon(old_page) && !PageKsm(old_page)) {
 		if (!trylock_page(old_page)) {
-			page_cache_get(old_page);
+			get_page(old_page);
 			pte_unmap_unlock(page_table, ptl);
 			lock_page(old_page);
 			page_table = pte_offset_map_lock(mm, pmd, address,
@@ -2346,10 +2346,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
 				pte_unmap_unlock(page_table, ptl);
-				page_cache_release(old_page);
+				put_page(old_page);
 				return 0;
 			}
-			page_cache_release(old_page);
+			put_page(old_page);
 		}
 		if (reuse_swap_page(old_page)) {
 			/*
@@ -2372,7 +2372,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
-	page_cache_get(old_page);
+	get_page(old_page);
 
 	pte_unmap_unlock(page_table, ptl);
 	return wp_page_copy(mm, vma, address, page_table, pmd,
@@ -2616,7 +2616,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * parallel locked swapcache.
 		 */
 		unlock_page(swapcache);
-		page_cache_release(swapcache);
+		put_page(swapcache);
 	}
 
 	if (flags & FAULT_FLAG_WRITE) {
@@ -2638,10 +2638,10 @@ out_nomap:
 out_page:
 	unlock_page(page);
 out_release:
-	page_cache_release(page);
+	put_page(page);
 	if (page != swapcache) {
 		unlock_page(swapcache);
-		page_cache_release(swapcache);
+		put_page(swapcache);
 	}
 	return ret;
 }
@@ -2749,7 +2749,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (userfaultfd_missing(vma)) {
 		pte_unmap_unlock(page_table, ptl);
 		mem_cgroup_cancel_charge(page, memcg, false);
-		page_cache_release(page);
+		put_page(page);
 		return handle_userfault(vma, address, flags,
 					VM_UFFD_MISSING);
 	}
@@ -2768,10 +2768,10 @@ unlock:
 	return 0;
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
-	page_cache_release(page);
+	put_page(page);
 	goto unlock;
 oom_free_page:
-	page_cache_release(page);
+	put_page(page);
 oom:
 	return VM_FAULT_OOM;
 }
@@ -2804,7 +2804,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	if (unlikely(PageHWPoison(vmf.page))) {
 		if (ret & VM_FAULT_LOCKED)
 			unlock_page(vmf.page);
-		page_cache_release(vmf.page);
+		put_page(vmf.page);
 		return VM_FAULT_HWPOISON;
 	}
 
@@ -2993,7 +2993,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		put_page(fault_page);
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
@@ -3021,7 +3021,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 
 	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg, false)) {
-		page_cache_release(new_page);
+		put_page(new_page);
 		return VM_FAULT_OOM;
 	}
 
@@ -3038,7 +3038,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 		if (fault_page) {
 			unlock_page(fault_page);
-			page_cache_release(fault_page);
+			put_page(fault_page);
 		} else {
 			/*
 			 * The fault handler has no page to lock, so it holds
@@ -3054,7 +3054,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 	if (fault_page) {
 		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		put_page(fault_page);
 	} else {
 		/*
 		 * The fault handler has no page to lock, so it holds
@@ -3065,7 +3065,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ret;
 uncharge_out:
 	mem_cgroup_cancel_charge(new_page, memcg, false);
-	page_cache_release(new_page);
+	put_page(new_page);
 	return ret;
 }
 
@@ -3093,7 +3093,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		tmp = do_page_mkwrite(vma, fault_page, address);
 		if (unlikely(!tmp ||
 				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
-			page_cache_release(fault_page);
+			put_page(fault_page);
 			return tmp;
 		}
 	}
@@ -3102,7 +3102,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		put_page(fault_page);
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, true, false);
@@ -3733,7 +3733,7 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 						    buf, maddr + offset, bytes);
 			}
 			kunmap(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 		len -= bytes;
 		buf += bytes;
diff --git a/mm/mincore.c b/mm/mincore.c
index 563f32045490..8551c0b53519 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -75,7 +75,7 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 #endif
 	if (page) {
 		present = PageUptodate(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	return present;
@@ -226,7 +226,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	unsigned char *tmp;
 
 	/* Check the start address: needs to be page-aligned.. */
- 	if (start & ~PAGE_CACHE_MASK)
+ 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
 	/* ..and we need to be passed a valid user-space range */
diff --git a/mm/nommu.c b/mm/nommu.c
index de8b6b6580c1..102e257cc6c3 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -141,7 +141,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		if (pages) {
 			pages[i] = virt_to_page(start);
 			if (pages[i])
-				page_cache_get(pages[i]);
+				get_page(pages[i]);
 		}
 		if (vmas)
 			vmas[i] = vma;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 11ff8f758631..999792d35ccc 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2176,8 +2176,8 @@ int write_cache_pages(struct address_space *mapping,
 			cycled = 0;
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		cycled = 1; /* ignore range_cyclic tests */
@@ -2382,14 +2382,14 @@ int write_one_page(struct page *page, int wait)
 		wait_on_page_writeback(page);
 
 	if (clear_page_dirty_for_io(page)) {
-		page_cache_get(page);
+		get_page(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
 		if (ret == 0 && wait) {
 			wait_on_page_writeback(page);
 			if (PageError(page))
 				ret = -EIO;
 		}
-		page_cache_release(page);
+		put_page(page);
 	} else {
 		unlock_page(page);
 	}
@@ -2431,7 +2431,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
 		__inc_wb_stat(wb, WB_DIRTIED);
-		task_io_account_write(PAGE_CACHE_SIZE);
+		task_io_account_write(PAGE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
 	}
@@ -2450,7 +2450,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
-		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
+		task_io_account_cancelled_write(PAGE_SIZE);
 	}
 }
 
diff --git a/mm/page_io.c b/mm/page_io.c
index ff74e512f029..729cc6ee21a6 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -246,7 +246,7 @@ out:
 
 static sector_t swap_page_sector(struct page *page)
 {
-	return (sector_t)__page_file_index(page) << (PAGE_CACHE_SHIFT - 9);
+	return (sector_t)__page_file_index(page) << (PAGE_SHIFT - 9);
 }
 
 int __swap_writepage(struct page *page, struct writeback_control *wbc,
diff --git a/mm/readahead.c b/mm/readahead.c
index 20e58e820e44..40be3ae0afe3 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -47,11 +47,11 @@ static void read_cache_pages_invalidate_page(struct address_space *mapping,
 		if (!trylock_page(page))
 			BUG();
 		page->mapping = mapping;
-		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		do_invalidatepage(page, 0, PAGE_SIZE);
 		page->mapping = NULL;
 		unlock_page(page);
 	}
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -93,14 +93,14 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			read_cache_pages_invalidate_page(mapping, page);
 			continue;
 		}
-		page_cache_release(page);
+		put_page(page);
 
 		ret = filler(data, page);
 		if (unlikely(ret)) {
 			read_cache_pages_invalidate_pages(mapping, pages);
 			break;
 		}
-		task_io_account_read(PAGE_CACHE_SIZE);
+		task_io_account_read(PAGE_SIZE);
 	}
 	return ret;
 }
@@ -130,7 +130,7 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 				mapping_gfp_constraint(mapping, GFP_KERNEL))) {
 			mapping->a_ops->readpage(filp, page);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 	ret = 0;
 
@@ -163,7 +163,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	if (isize == 0)
 		goto out;
 
-	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+	end_index = ((isize - 1) >> PAGE_SHIFT);
 
 	/*
 	 * Preallocate as many pages as we will need.
@@ -216,7 +216,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	while (nr_to_read) {
 		int err;
 
-		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
+		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_SIZE;
 
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
@@ -425,7 +425,7 @@ ondemand_readahead(struct address_space *mapping,
 	 * trivial case: (offset - prev_offset) == 1
 	 * unaligned reads: (offset - prev_offset) == 0
 	 */
-	prev_offset = (unsigned long long)ra->prev_pos >> PAGE_CACHE_SHIFT;
+	prev_offset = (unsigned long long)ra->prev_pos >> PAGE_SHIFT;
 	if (offset - prev_offset <= 1UL)
 		goto initial_readahead;
 
@@ -558,8 +558,8 @@ SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
 	if (f.file) {
 		if (f.file->f_mode & FMODE_READ) {
 			struct address_space *mapping = f.file->f_mapping;
-			pgoff_t start = offset >> PAGE_CACHE_SHIFT;
-			pgoff_t end = (offset + count - 1) >> PAGE_CACHE_SHIFT;
+			pgoff_t start = offset >> PAGE_SHIFT;
+			pgoff_t end = (offset + count - 1) >> PAGE_SHIFT;
 			unsigned long len = end - start + 1;
 			ret = do_readahead(mapping, f.file, start, len);
 		}
diff --git a/mm/rmap.c b/mm/rmap.c
index c399a0d41b31..525b92f866a7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1555,7 +1555,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 discard:
 	page_remove_rmap(page, PageHuge(page));
-	page_cache_release(page);
+	put_page(page);
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
diff --git a/mm/shmem.c b/mm/shmem.c
index 9428c51ab2d6..719bd6b88d98 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -75,8 +75,8 @@ static struct vfsmount *shm_mnt;
 
 #include "internal.h"
 
-#define BLOCKS_PER_PAGE  (PAGE_CACHE_SIZE/512)
-#define VM_ACCT(size)    (PAGE_CACHE_ALIGN(size) >> PAGE_SHIFT)
+#define BLOCKS_PER_PAGE  (PAGE_SIZE/512)
+#define VM_ACCT(size)    (PAGE_ALIGN(size) >> PAGE_SHIFT)
 
 /* Pretend that each entry is of this size in directory's i_size */
 #define BOGO_DIRENT_SIZE 20
@@ -176,13 +176,13 @@ static inline int shmem_reacct_size(unsigned long flags,
 static inline int shmem_acct_block(unsigned long flags)
 {
 	return (flags & VM_NORESERVE) ?
-		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_CACHE_SIZE)) : 0;
+		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_SIZE)) : 0;
 }
 
 static inline void shmem_unacct_blocks(unsigned long flags, long pages)
 {
 	if (flags & VM_NORESERVE)
-		vm_unacct_memory(pages * VM_ACCT(PAGE_CACHE_SIZE));
+		vm_unacct_memory(pages * VM_ACCT(PAGE_SIZE));
 }
 
 static const struct super_operations shmem_ops;
@@ -300,7 +300,7 @@ static int shmem_add_to_page_cache(struct page *page,
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	page_cache_get(page);
+	get_page(page);
 	page->mapping = mapping;
 	page->index = index;
 
@@ -318,7 +318,7 @@ static int shmem_add_to_page_cache(struct page *page,
 	} else {
 		page->mapping = NULL;
 		spin_unlock_irq(&mapping->tree_lock);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return error;
 }
@@ -338,7 +338,7 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	__dec_zone_page_state(page, NR_SHMEM);
 	spin_unlock_irq(&mapping->tree_lock);
-	page_cache_release(page);
+	put_page(page);
 	BUG_ON(error);
 }
 
@@ -474,10 +474,10 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	pgoff_t end = (lend + 1) >> PAGE_CACHE_SHIFT;
-	unsigned int partial_start = lstart & (PAGE_CACHE_SIZE - 1);
-	unsigned int partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
+	pgoff_t start = (lstart + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	pgoff_t end = (lend + 1) >> PAGE_SHIFT;
+	unsigned int partial_start = lstart & (PAGE_SIZE - 1);
+	unsigned int partial_end = (lend + 1) & (PAGE_SIZE - 1);
 	struct pagevec pvec;
 	pgoff_t indices[PAGEVEC_SIZE];
 	long nr_swaps_freed = 0;
@@ -530,7 +530,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		struct page *page = NULL;
 		shmem_getpage(inode, start - 1, &page, SGP_READ, NULL);
 		if (page) {
-			unsigned int top = PAGE_CACHE_SIZE;
+			unsigned int top = PAGE_SIZE;
 			if (start > end) {
 				top = partial_end;
 				partial_end = 0;
@@ -538,7 +538,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			zero_user_segment(page, partial_start, top);
 			set_page_dirty(page);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 	}
 	if (partial_end) {
@@ -548,7 +548,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			zero_user_segment(page, 0, partial_end);
 			set_page_dirty(page);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 	}
 	if (start >= end)
@@ -833,7 +833,7 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 		mem_cgroup_commit_charge(page, memcg, true, false);
 out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return error;
 }
 
@@ -1080,7 +1080,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	if (!newpage)
 		return -ENOMEM;
 
-	page_cache_get(newpage);
+	get_page(newpage);
 	copy_highpage(newpage, oldpage);
 	flush_dcache_page(newpage);
 
@@ -1120,8 +1120,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	set_page_private(oldpage, 0);
 
 	unlock_page(oldpage);
-	page_cache_release(oldpage);
-	page_cache_release(oldpage);
+	put_page(oldpage);
+	put_page(oldpage);
 	return error;
 }
 
@@ -1145,7 +1145,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	int once = 0;
 	int alloced = 0;
 
-	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
+	if (index > (MAX_LFS_FILESIZE >> PAGE_SHIFT))
 		return -EFBIG;
 repeat:
 	swap.val = 0;
@@ -1156,7 +1156,7 @@ repeat:
 	}
 
 	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
-	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
+	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
 		goto unlock;
 	}
@@ -1169,7 +1169,7 @@ repeat:
 		if (sgp != SGP_READ)
 			goto clear;
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 	if (page || (sgp == SGP_READ && !swap.val)) {
@@ -1327,7 +1327,7 @@ clear:
 
 	/* Perhaps the file has been truncated since we checked */
 	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
-	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
+	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
 		if (alloced) {
 			ClearPageDirty(page);
 			delete_from_page_cache(page);
@@ -1355,7 +1355,7 @@ failed:
 unlock:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (error == -ENOSPC && !once++) {
 		info = SHMEM_I(inode);
@@ -1577,7 +1577,7 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 
 	/* i_mutex is held by caller */
 	if (unlikely(info->seals)) {
@@ -1601,16 +1601,16 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 		i_size_write(inode, pos + copied);
 
 	if (!PageUptodate(page)) {
-		if (copied < PAGE_CACHE_SIZE) {
-			unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+		if (copied < PAGE_SIZE) {
+			unsigned from = pos & (PAGE_SIZE - 1);
 			zero_user_segments(page, 0, from,
-					from + copied, PAGE_CACHE_SIZE);
+					from + copied, PAGE_SIZE);
 		}
 		SetPageUptodate(page);
 	}
 	set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
@@ -1635,8 +1635,8 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (!iter_is_iovec(to))
 		sgp = SGP_DIRTY;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	index = *ppos >> PAGE_SHIFT;
+	offset = *ppos & ~PAGE_MASK;
 
 	for (;;) {
 		struct page *page = NULL;
@@ -1644,11 +1644,11 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		unsigned long nr, ret;
 		loff_t i_size = i_size_read(inode);
 
-		end_index = i_size >> PAGE_CACHE_SHIFT;
+		end_index = i_size >> PAGE_SHIFT;
 		if (index > end_index)
 			break;
 		if (index == end_index) {
-			nr = i_size & ~PAGE_CACHE_MASK;
+			nr = i_size & ~PAGE_MASK;
 			if (nr <= offset)
 				break;
 		}
@@ -1666,14 +1666,14 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		 * We must evaluate after, since reads (unlike writes)
 		 * are called without i_mutex protection against truncate
 		 */
-		nr = PAGE_CACHE_SIZE;
+		nr = PAGE_SIZE;
 		i_size = i_size_read(inode);
-		end_index = i_size >> PAGE_CACHE_SHIFT;
+		end_index = i_size >> PAGE_SHIFT;
 		if (index == end_index) {
-			nr = i_size & ~PAGE_CACHE_MASK;
+			nr = i_size & ~PAGE_MASK;
 			if (nr <= offset) {
 				if (page)
-					page_cache_release(page);
+					put_page(page);
 				break;
 			}
 		}
@@ -1694,7 +1694,7 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 				mark_page_accessed(page);
 		} else {
 			page = ZERO_PAGE(0);
-			page_cache_get(page);
+			get_page(page);
 		}
 
 		/*
@@ -1704,10 +1704,10 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		ret = copy_page_to_iter(page, offset, nr, to);
 		retval += ret;
 		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		index += offset >> PAGE_SHIFT;
+		offset &= ~PAGE_MASK;
 
-		page_cache_release(page);
+		put_page(page);
 		if (!iov_iter_count(to))
 			break;
 		if (ret < nr) {
@@ -1717,7 +1717,7 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		cond_resched();
 	}
 
-	*ppos = ((loff_t) index << PAGE_CACHE_SHIFT) + offset;
+	*ppos = ((loff_t) index << PAGE_SHIFT) + offset;
 	file_accessed(file);
 	return retval ? retval : error;
 }
@@ -1755,9 +1755,9 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	if (splice_grow_spd(pipe, &spd))
 		return -ENOMEM;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	loff = *ppos & ~PAGE_CACHE_MASK;
-	req_pages = (len + loff + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	index = *ppos >> PAGE_SHIFT;
+	loff = *ppos & ~PAGE_MASK;
+	req_pages = (len + loff + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	nr_pages = min(req_pages, spd.nr_pages_max);
 
 	spd.nr_pages = find_get_pages_contig(mapping, index,
@@ -1774,7 +1774,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 		index++;
 	}
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
+	index = *ppos >> PAGE_SHIFT;
 	nr_pages = spd.nr_pages;
 	spd.nr_pages = 0;
 
@@ -1784,7 +1784,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 		if (!len)
 			break;
 
-		this_len = min_t(unsigned long, len, PAGE_CACHE_SIZE - loff);
+		this_len = min_t(unsigned long, len, PAGE_SIZE - loff);
 		page = spd.pages[page_nr];
 
 		if (!PageUptodate(page) || page->mapping != mapping) {
@@ -1793,19 +1793,19 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 			if (error)
 				break;
 			unlock_page(page);
-			page_cache_release(spd.pages[page_nr]);
+			put_page(spd.pages[page_nr]);
 			spd.pages[page_nr] = page;
 		}
 
 		isize = i_size_read(inode);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		end_index = (isize - 1) >> PAGE_SHIFT;
 		if (unlikely(!isize || index > end_index))
 			break;
 
 		if (end_index == index) {
 			unsigned int plen;
 
-			plen = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			plen = ((isize - 1) & ~PAGE_MASK) + 1;
 			if (plen <= loff)
 				break;
 
@@ -1822,7 +1822,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	}
 
 	while (page_nr < nr_pages)
-		page_cache_release(spd.pages[page_nr++]);
+		put_page(spd.pages[page_nr++]);
 
 	if (spd.nr_pages)
 		error = splice_to_pipe(pipe, &spd);
@@ -1904,10 +1904,10 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 	else if (offset >= inode->i_size)
 		offset = -ENXIO;
 	else {
-		start = offset >> PAGE_CACHE_SHIFT;
-		end = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		start = offset >> PAGE_SHIFT;
+		end = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		new_offset = shmem_seek_hole_data(mapping, start, end, whence);
-		new_offset <<= PAGE_CACHE_SHIFT;
+		new_offset <<= PAGE_SHIFT;
 		if (new_offset > offset) {
 			if (new_offset < inode->i_size)
 				offset = new_offset;
@@ -2203,8 +2203,8 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		goto out;
 	}
 
-	start = offset >> PAGE_CACHE_SHIFT;
-	end = (offset + len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	start = offset >> PAGE_SHIFT;
+	end = (offset + len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	/* Try to avoid a swapstorm if len is impossible to satisfy */
 	if (sbinfo->max_blocks && end - start > sbinfo->max_blocks) {
 		error = -ENOSPC;
@@ -2237,8 +2237,8 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		if (error) {
 			/* Remove the !PageUptodate pages we added */
 			shmem_undo_range(inode,
-				(loff_t)start << PAGE_CACHE_SHIFT,
-				(loff_t)index << PAGE_CACHE_SHIFT, true);
+				(loff_t)start << PAGE_SHIFT,
+				(loff_t)index << PAGE_SHIFT, true);
 			goto undone;
 		}
 
@@ -2259,7 +2259,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		 */
 		set_page_dirty(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		cond_resched();
 	}
 
@@ -2280,7 +2280,7 @@ static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
 	struct shmem_sb_info *sbinfo = SHMEM_SB(dentry->d_sb);
 
 	buf->f_type = TMPFS_MAGIC;
-	buf->f_bsize = PAGE_CACHE_SIZE;
+	buf->f_bsize = PAGE_SIZE;
 	buf->f_namelen = NAME_MAX;
 	if (sbinfo->max_blocks) {
 		buf->f_blocks = sbinfo->max_blocks;
@@ -2523,7 +2523,7 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 	struct shmem_inode_info *info;
 
 	len = strlen(symname) + 1;
-	if (len > PAGE_CACHE_SIZE)
+	if (len > PAGE_SIZE)
 		return -ENAMETOOLONG;
 
 	inode = shmem_get_inode(dir->i_sb, dir, S_IFLNK|S_IRWXUGO, 0, VM_NORESERVE);
@@ -2562,7 +2562,7 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		SetPageUptodate(page);
 		set_page_dirty(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	dir->i_size += BOGO_DIRENT_SIZE;
 	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
@@ -2835,7 +2835,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			if (*rest)
 				goto bad_val;
 			sbinfo->max_blocks =
-				DIV_ROUND_UP(size, PAGE_CACHE_SIZE);
+				DIV_ROUND_UP(size, PAGE_SIZE);
 		} else if (!strcmp(this_char,"nr_blocks")) {
 			sbinfo->max_blocks = memparse(value, &rest);
 			if (*rest)
@@ -2940,7 +2940,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 
 	if (sbinfo->max_blocks != shmem_default_max_blocks())
 		seq_printf(seq, ",size=%luk",
-			sbinfo->max_blocks << (PAGE_CACHE_SHIFT - 10));
+			sbinfo->max_blocks << (PAGE_SHIFT - 10));
 	if (sbinfo->max_inodes != shmem_default_max_inodes())
 		seq_printf(seq, ",nr_inodes=%lu", sbinfo->max_inodes);
 	if (sbinfo->mode != (S_IRWXUGO | S_ISVTX))
@@ -3082,8 +3082,8 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	sbinfo->free_inodes = sbinfo->max_inodes;
 
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = TMPFS_MAGIC;
 	sb->s_op = &shmem_ops;
 	sb->s_time_gran = 1;
diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e97714a..ea641e247033 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -114,7 +114,7 @@ void put_pages_list(struct list_head *pages)
 
 		victim = list_entry(pages->prev, struct page, lru);
 		list_del(&victim->lru);
-		page_cache_release(victim);
+		put_page(victim);
 	}
 }
 EXPORT_SYMBOL(put_pages_list);
@@ -142,7 +142,7 @@ int get_kernel_pages(const struct kvec *kiov, int nr_segs, int write,
 			return seg;
 
 		pages[seg] = kmap_to_page(kiov[seg].iov_base);
-		page_cache_get(pages[seg]);
+		get_page(pages[seg]);
 	}
 
 	return seg;
@@ -236,7 +236,7 @@ void rotate_reclaimable_page(struct page *page)
 		struct pagevec *pvec;
 		unsigned long flags;
 
-		page_cache_get(page);
+		get_page(page);
 		local_irq_save(flags);
 		pvec = this_cpu_ptr(&lru_rotate_pvecs);
 		if (!pagevec_add(pvec, page))
@@ -294,7 +294,7 @@ void activate_page(struct page *page)
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
 
-		page_cache_get(page);
+		get_page(page);
 		if (!pagevec_add(pvec, page))
 			pagevec_lru_move_fn(pvec, __activate_page, NULL);
 		put_cpu_var(activate_page_pvecs);
@@ -389,7 +389,7 @@ static void __lru_cache_add(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
 
-	page_cache_get(page);
+	get_page(page);
 	if (!pagevec_space(pvec))
 		__pagevec_lru_add(pvec);
 	pagevec_add(pvec, page);
@@ -646,7 +646,7 @@ void deactivate_page(struct page *page)
 	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
 		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
 
-		page_cache_get(page);
+		get_page(page);
 		if (!pagevec_add(pvec, page))
 			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
 		put_cpu_var(lru_deactivate_pvecs);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 69cb2464e7dc..366ce3518703 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -85,7 +85,7 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 	VM_BUG_ON_PAGE(PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	page_cache_get(page);
+	get_page(page);
 	SetPageSwapCache(page);
 	set_page_private(page, entry.val);
 
@@ -109,7 +109,7 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 		VM_BUG_ON(error == -EEXIST);
 		set_page_private(page, 0UL);
 		ClearPageSwapCache(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	return error;
@@ -226,7 +226,7 @@ void delete_from_swap_cache(struct page *page)
 	spin_unlock_irq(&address_space->tree_lock);
 
 	swapcache_free(entry);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /* 
@@ -252,7 +252,7 @@ static inline void free_swap_cache(struct page *page)
 void free_page_and_swap_cache(struct page *page)
 {
 	free_swap_cache(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -380,7 +380,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 	} while (err != -ENOMEM);
 
 	if (new_page)
-		page_cache_release(new_page);
+		put_page(new_page);
 	return found_page;
 }
 
@@ -495,7 +495,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			continue;
 		if (offset != entry_offset)
 			SetPageReadahead(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	blk_finish_plug(&plug);
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index b86cf26a586b..555069ca3eae 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -113,7 +113,7 @@ __try_to_reclaim_swap(struct swap_info_struct *si, unsigned long offset)
 		ret = try_to_free_swap(page);
 		unlock_page(page);
 	}
-	page_cache_release(page);
+	put_page(page);
 	return ret;
 }
 
@@ -994,7 +994,7 @@ int free_swap_and_cache(swp_entry_t entry)
 			page = find_get_page(swap_address_space(entry),
 						entry.val);
 			if (page && !trylock_page(page)) {
-				page_cache_release(page);
+				put_page(page);
 				page = NULL;
 			}
 		}
@@ -1011,7 +1011,7 @@ int free_swap_and_cache(swp_entry_t entry)
 			SetPageDirty(page);
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return p != NULL;
 }
@@ -1512,7 +1512,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		}
 		if (retval) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			break;
 		}
 
@@ -1564,7 +1564,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		 */
 		SetPageDirty(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		/*
 		 * Make sure that we aren't completely killing
@@ -2568,7 +2568,7 @@ bad_swap:
 out:
 	if (page && !IS_ERR(page)) {
 		kunmap(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (name)
 		putname(name);
diff --git a/mm/truncate.c b/mm/truncate.c
index 7598b552ae03..b00272810871 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -118,7 +118,7 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 		return -EIO;
 
 	if (page_has_private(page))
-		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		do_invalidatepage(page, 0, PAGE_SIZE);
 
 	/*
 	 * Some filesystems seem to re-dirty the page even after
@@ -159,8 +159,8 @@ int truncate_inode_page(struct address_space *mapping, struct page *page)
 {
 	if (page_mapped(page)) {
 		unmap_mapping_range(mapping,
-				   (loff_t)page->index << PAGE_CACHE_SHIFT,
-				   PAGE_CACHE_SIZE, 0);
+				   (loff_t)page->index << PAGE_SHIFT,
+				   PAGE_SIZE, 0);
 	}
 	return truncate_complete_page(mapping, page);
 }
@@ -241,8 +241,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		return;
 
 	/* Offsets within partial pages */
-	partial_start = lstart & (PAGE_CACHE_SIZE - 1);
-	partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
+	partial_start = lstart & (PAGE_SIZE - 1);
+	partial_end = (lend + 1) & (PAGE_SIZE - 1);
 
 	/*
 	 * 'start' and 'end' always covers the range of pages to be fully
@@ -250,7 +250,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	 * start of the range and 'partial_end' at the end of the range.
 	 * Note that 'end' is exclusive while 'lend' is inclusive.
 	 */
-	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	start = (lstart + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (lend == -1)
 		/*
 		 * lend == -1 indicates end-of-file so we have to set 'end'
@@ -259,7 +259,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		 */
 		end = -1;
 	else
-		end = (lend + 1) >> PAGE_CACHE_SHIFT;
+		end = (lend + 1) >> PAGE_SHIFT;
 
 	pagevec_init(&pvec, 0);
 	index = start;
@@ -298,7 +298,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	if (partial_start) {
 		struct page *page = find_lock_page(mapping, start - 1);
 		if (page) {
-			unsigned int top = PAGE_CACHE_SIZE;
+			unsigned int top = PAGE_SIZE;
 			if (start > end) {
 				/* Truncation within a single page */
 				top = partial_end;
@@ -311,7 +311,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				do_invalidatepage(page, partial_start,
 						  top - partial_start);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 	}
 	if (partial_end) {
@@ -324,7 +324,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				do_invalidatepage(page, 0,
 						  partial_end);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 	}
 	/*
@@ -538,7 +538,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	if (mapping->a_ops->freepage)
 		mapping->a_ops->freepage(page);
 
-	page_cache_release(page);	/* pagecache ref */
+	put_page(page);	/* pagecache ref */
 	return 1;
 failed:
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -608,18 +608,18 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 					 * Zap the rest of the file in one hit.
 					 */
 					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_CACHE_SHIFT,
+					   (loff_t)index << PAGE_SHIFT,
 					   (loff_t)(1 + end - index)
-							 << PAGE_CACHE_SHIFT,
-					    0);
+							 << PAGE_SHIFT,
+							 0);
 					did_range_unmap = 1;
 				} else {
 					/*
 					 * Just zap this page
 					 */
 					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_CACHE_SHIFT,
-					   PAGE_CACHE_SIZE, 0);
+					   (loff_t)index << PAGE_SHIFT,
+					   PAGE_SIZE, 0);
 				}
 			}
 			BUG_ON(page_mapped(page));
@@ -744,14 +744,14 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 
 	WARN_ON(to > inode->i_size);
 
-	if (from >= to || bsize == PAGE_CACHE_SIZE)
+	if (from >= to || bsize == PAGE_SIZE)
 		return;
 	/* Page straddling @from will not have any hole block created? */
 	rounded_from = round_up(from, bsize);
-	if (to <= rounded_from || !(rounded_from & (PAGE_CACHE_SIZE - 1)))
+	if (to <= rounded_from || !(rounded_from & (PAGE_SIZE - 1)))
 		return;
 
-	index = from >> PAGE_CACHE_SHIFT;
+	index = from >> PAGE_SHIFT;
 	page = find_lock_page(inode->i_mapping, index);
 	/* Page not cached? Nothing to do */
 	if (!page)
@@ -763,7 +763,7 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 	if (page_mkclean(page))
 		set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 }
 EXPORT_SYMBOL(pagecache_isize_extended);
 
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 9f3a0290b273..af817e5060fb 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -93,7 +93,7 @@ out_release_uncharge_unlock:
 	pte_unmap_unlock(dst_pte, ptl);
 	mem_cgroup_cancel_charge(page, memcg, false);
 out_release:
-	page_cache_release(page);
+	put_page(page);
 	goto out;
 }
 
@@ -287,7 +287,7 @@ out_unlock:
 	up_read(&dst_mm->mmap_sem);
 out:
 	if (page)
-		page_cache_release(page);
+		put_page(page);
 	BUG_ON(copied < 0);
 	BUG_ON(err > 0);
 	BUG_ON(!copied && !err);
diff --git a/mm/zswap.c b/mm/zswap.c
index bf14508afd64..91dad80d068b 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -869,7 +869,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 
 	case ZSWAP_SWAPCACHE_EXIST:
 		/* page is already in the swap cache, ignore for now */
-		page_cache_release(page);
+		put_page(page);
 		ret = -EEXIST;
 		goto fail;
 
@@ -897,7 +897,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 
 	/* start writeback */
 	__swap_writepage(page, &wbc, end_swap_bio_write);
-	page_cache_release(page);
+	put_page(page);
 	zswap_written_back_pages++;
 
 	spin_lock(&tree->lock);
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 9382619a405b..298770cf66e5 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -275,7 +275,7 @@ static void _ceph_msgr_exit(void)
 	}
 
 	BUG_ON(zero_page == NULL);
-	page_cache_release(zero_page);
+	put_page(zero_page);
 	zero_page = NULL;
 
 	ceph_msgr_slab_exit();
@@ -288,7 +288,7 @@ int ceph_msgr_init(void)
 
 	BUG_ON(zero_page != NULL);
 	zero_page = ZERO_PAGE(0);
-	page_cache_get(zero_page);
+	get_page(zero_page);
 
 	/*
 	 * The number of active work items is limited by the number of
@@ -1614,7 +1614,7 @@ static int write_partial_skip(struct ceph_connection *con)
 
 	dout("%s %p %d left\n", __func__, con, con->out_skip);
 	while (con->out_skip > 0) {
-		size_t size = min(con->out_skip, (int) PAGE_CACHE_SIZE);
+		size_t size = min(con->out_skip, (int) PAGE_SIZE);
 
 		ret = ceph_tcp_sendpage(con->sock, zero_page, 0, size, true);
 		if (ret <= 0)
diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index c7c220a736e5..6864007e64fc 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -56,7 +56,7 @@ int ceph_pagelist_append(struct ceph_pagelist *pl, const void *buf, size_t len)
 		size_t bit = pl->room;
 		int ret;
 
-		memcpy(pl->mapped_tail + (pl->length & ~PAGE_CACHE_MASK),
+		memcpy(pl->mapped_tail + (pl->length & ~PAGE_MASK),
 		       buf, bit);
 		pl->length += bit;
 		pl->room -= bit;
@@ -67,7 +67,7 @@ int ceph_pagelist_append(struct ceph_pagelist *pl, const void *buf, size_t len)
 			return ret;
 	}
 
-	memcpy(pl->mapped_tail + (pl->length & ~PAGE_CACHE_MASK), buf, len);
+	memcpy(pl->mapped_tail + (pl->length & ~PAGE_MASK), buf, len);
 	pl->length += len;
 	pl->room -= len;
 	return 0;
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 10297f7a89ba..00d2601407c5 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -95,19 +95,19 @@ int ceph_copy_user_to_page_vector(struct page **pages,
 					 loff_t off, size_t len)
 {
 	int i = 0;
-	int po = off & ~PAGE_CACHE_MASK;
+	int po = off & ~PAGE_MASK;
 	int left = len;
 	int l, bad;
 
 	while (left > 0) {
-		l = min_t(int, PAGE_CACHE_SIZE-po, left);
+		l = min_t(int, PAGE_SIZE-po, left);
 		bad = copy_from_user(page_address(pages[i]) + po, data, l);
 		if (bad == l)
 			return -EFAULT;
 		data += l - bad;
 		left -= l - bad;
 		po += l - bad;
-		if (po == PAGE_CACHE_SIZE) {
+		if (po == PAGE_SIZE) {
 			po = 0;
 			i++;
 		}
@@ -121,17 +121,17 @@ void ceph_copy_to_page_vector(struct page **pages,
 				    loff_t off, size_t len)
 {
 	int i = 0;
-	size_t po = off & ~PAGE_CACHE_MASK;
+	size_t po = off & ~PAGE_MASK;
 	size_t left = len;
 
 	while (left > 0) {
-		size_t l = min_t(size_t, PAGE_CACHE_SIZE-po, left);
+		size_t l = min_t(size_t, PAGE_SIZE-po, left);
 
 		memcpy(page_address(pages[i]) + po, data, l);
 		data += l;
 		left -= l;
 		po += l;
-		if (po == PAGE_CACHE_SIZE) {
+		if (po == PAGE_SIZE) {
 			po = 0;
 			i++;
 		}
@@ -144,17 +144,17 @@ void ceph_copy_from_page_vector(struct page **pages,
 				    loff_t off, size_t len)
 {
 	int i = 0;
-	size_t po = off & ~PAGE_CACHE_MASK;
+	size_t po = off & ~PAGE_MASK;
 	size_t left = len;
 
 	while (left > 0) {
-		size_t l = min_t(size_t, PAGE_CACHE_SIZE-po, left);
+		size_t l = min_t(size_t, PAGE_SIZE-po, left);
 
 		memcpy(data, page_address(pages[i]) + po, l);
 		data += l;
 		left -= l;
 		po += l;
-		if (po == PAGE_CACHE_SIZE) {
+		if (po == PAGE_SIZE) {
 			po = 0;
 			i++;
 		}
@@ -168,25 +168,25 @@ EXPORT_SYMBOL(ceph_copy_from_page_vector);
  */
 void ceph_zero_page_vector_range(int off, int len, struct page **pages)
 {
-	int i = off >> PAGE_CACHE_SHIFT;
+	int i = off >> PAGE_SHIFT;
 
-	off &= ~PAGE_CACHE_MASK;
+	off &= ~PAGE_MASK;
 
 	dout("zero_page_vector_page %u~%u\n", off, len);
 
 	/* leading partial page? */
 	if (off) {
-		int end = min((int)PAGE_CACHE_SIZE, off + len);
+		int end = min((int)PAGE_SIZE, off + len);
 		dout("zeroing %d %p head from %d\n", i, pages[i],
 		     (int)off);
 		zero_user_segment(pages[i], off, end);
 		len -= (end - off);
 		i++;
 	}
-	while (len >= PAGE_CACHE_SIZE) {
+	while (len >= PAGE_SIZE) {
 		dout("zeroing %d %p len=%d\n", i, pages[i], len);
-		zero_user_segment(pages[i], 0, PAGE_CACHE_SIZE);
-		len -= PAGE_CACHE_SIZE;
+		zero_user_segment(pages[i], 0, PAGE_SIZE);
+		len -= PAGE_SIZE;
 		i++;
 	}
 	/* trailing partial page? */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cabf586f47d7..a9fc819429ef 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1728,8 +1728,8 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
 		return 0;
 	}
 
-	first = snd_buf->page_base >> PAGE_CACHE_SHIFT;
-	last = (snd_buf->page_base + snd_buf->page_len - 1) >> PAGE_CACHE_SHIFT;
+	first = snd_buf->page_base >> PAGE_SHIFT;
+	last = (snd_buf->page_base + snd_buf->page_len - 1) >> PAGE_SHIFT;
 	rqstp->rq_enc_pages_num = last - first + 1 + 1;
 	rqstp->rq_enc_pages
 		= kmalloc(rqstp->rq_enc_pages_num * sizeof(struct page *),
@@ -1775,10 +1775,10 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	status = alloc_enc_pages(rqstp);
 	if (status)
 		return status;
-	first = snd_buf->page_base >> PAGE_CACHE_SHIFT;
+	first = snd_buf->page_base >> PAGE_SHIFT;
 	inpages = snd_buf->pages + first;
 	snd_buf->pages = rqstp->rq_enc_pages;
-	snd_buf->page_base -= first << PAGE_CACHE_SHIFT;
+	snd_buf->page_base -= first << PAGE_SHIFT;
 	/*
 	 * Give the tail its own page, in case we need extra space in the
 	 * head when wrapping:
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index d94a8e1e9f05..045e11ecd332 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -465,7 +465,7 @@ encryptor(struct scatterlist *sg, void *data)
 	page_pos = desc->pos - outbuf->head[0].iov_len;
 	if (page_pos >= 0 && page_pos < outbuf->page_len) {
 		/* pages are not in place: */
-		int i = (page_pos + outbuf->page_base) >> PAGE_CACHE_SHIFT;
+		int i = (page_pos + outbuf->page_base) >> PAGE_SHIFT;
 		in_page = desc->pages[i];
 	} else {
 		in_page = sg_page(sg);
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 765088e4ad84..a737c2da0837 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -79,9 +79,9 @@ gss_krb5_remove_padding(struct xdr_buf *buf, int blocksize)
 		len -= buf->head[0].iov_len;
 	if (len <= buf->page_len) {
 		unsigned int last = (buf->page_base + len - 1)
-					>>PAGE_CACHE_SHIFT;
+					>>PAGE_SHIFT;
 		unsigned int offset = (buf->page_base + len - 1)
-					& (PAGE_CACHE_SIZE - 1);
+					& (PAGE_SIZE - 1);
 		ptr = kmap_atomic(buf->pages[last]);
 		pad = *(ptr + offset);
 		kunmap_atomic(ptr);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 273bc3a35425..e59a6d952b57 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -881,7 +881,7 @@ static ssize_t cache_downcall(struct address_space *mapping,
 	char *kaddr;
 	ssize_t ret = -ENOMEM;
 
-	if (count >= PAGE_CACHE_SIZE)
+	if (count >= PAGE_SIZE)
 		goto out_slow;
 
 	page = find_or_create_page(mapping, 0, GFP_KERNEL);
@@ -892,7 +892,7 @@ static ssize_t cache_downcall(struct address_space *mapping,
 	ret = cache_do_downcall(kaddr, buf, count, cd);
 	kunmap(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return ret;
 out_slow:
 	return cache_slow_downcall(buf, count, cd);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 31789ef3e614..fc48eca21fd2 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1390,8 +1390,8 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	int err;
 
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = RPCAUTH_GSSMAGIC;
 	sb->s_op = &s_ops;
 	sb->s_d_op = &simple_dentry_operations;
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 2df87f78e518..de70c78025d7 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -96,8 +96,8 @@ ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, struct
 	if (base || xdr->page_base) {
 		pglen -= base;
 		base += xdr->page_base;
-		ppage += base >> PAGE_CACHE_SHIFT;
-		base &= ~PAGE_CACHE_MASK;
+		ppage += base >> PAGE_SHIFT;
+		base &= ~PAGE_MASK;
 	}
 	do {
 		char *kaddr;
@@ -113,7 +113,7 @@ ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, struct
 			}
 		}
 
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 		kaddr = kmap_atomic(*ppage);
 		if (base) {
 			len -= base;
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 4439ac4c1b53..1e6aba0501a1 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -181,20 +181,20 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 	pgto_base += len;
 	pgfrom_base += len;
 
-	pgto = pages + (pgto_base >> PAGE_CACHE_SHIFT);
-	pgfrom = pages + (pgfrom_base >> PAGE_CACHE_SHIFT);
+	pgto = pages + (pgto_base >> PAGE_SHIFT);
+	pgfrom = pages + (pgfrom_base >> PAGE_SHIFT);
 
-	pgto_base &= ~PAGE_CACHE_MASK;
-	pgfrom_base &= ~PAGE_CACHE_MASK;
+	pgto_base &= ~PAGE_MASK;
+	pgfrom_base &= ~PAGE_MASK;
 
 	do {
 		/* Are any pointers crossing a page boundary? */
 		if (pgto_base == 0) {
-			pgto_base = PAGE_CACHE_SIZE;
+			pgto_base = PAGE_SIZE;
 			pgto--;
 		}
 		if (pgfrom_base == 0) {
-			pgfrom_base = PAGE_CACHE_SIZE;
+			pgfrom_base = PAGE_SIZE;
 			pgfrom--;
 		}
 
@@ -236,11 +236,11 @@ _copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
 	char *vto;
 	size_t copy;
 
-	pgto = pages + (pgbase >> PAGE_CACHE_SHIFT);
-	pgbase &= ~PAGE_CACHE_MASK;
+	pgto = pages + (pgbase >> PAGE_SHIFT);
+	pgbase &= ~PAGE_MASK;
 
 	for (;;) {
-		copy = PAGE_CACHE_SIZE - pgbase;
+		copy = PAGE_SIZE - pgbase;
 		if (copy > len)
 			copy = len;
 
@@ -253,7 +253,7 @@ _copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
 			break;
 
 		pgbase += copy;
-		if (pgbase == PAGE_CACHE_SIZE) {
+		if (pgbase == PAGE_SIZE) {
 			flush_dcache_page(*pgto);
 			pgbase = 0;
 			pgto++;
@@ -280,11 +280,11 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 	char *vfrom;
 	size_t copy;
 
-	pgfrom = pages + (pgbase >> PAGE_CACHE_SHIFT);
-	pgbase &= ~PAGE_CACHE_MASK;
+	pgfrom = pages + (pgbase >> PAGE_SHIFT);
+	pgbase &= ~PAGE_MASK;
 
 	do {
-		copy = PAGE_CACHE_SIZE - pgbase;
+		copy = PAGE_SIZE - pgbase;
 		if (copy > len)
 			copy = len;
 
@@ -293,7 +293,7 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 		kunmap_atomic(vfrom);
 
 		pgbase += copy;
-		if (pgbase == PAGE_CACHE_SIZE) {
+		if (pgbase == PAGE_SIZE) {
 			pgbase = 0;
 			pgfrom++;
 		}
@@ -1038,8 +1038,8 @@ xdr_buf_subsegment(struct xdr_buf *buf, struct xdr_buf *subbuf,
 	if (base < buf->page_len) {
 		subbuf->page_len = min(buf->page_len - base, len);
 		base += buf->page_base;
-		subbuf->page_base = base & ~PAGE_CACHE_MASK;
-		subbuf->pages = &buf->pages[base >> PAGE_CACHE_SHIFT];
+		subbuf->page_base = base & ~PAGE_MASK;
+		subbuf->pages = &buf->pages[base >> PAGE_SHIFT];
 		len -= subbuf->page_len;
 		base = 0;
 	} else {
@@ -1297,9 +1297,9 @@ xdr_xcode_array2(struct xdr_buf *buf, unsigned int base,
 		todo -= avail_here;
 
 		base += buf->page_base;
-		ppages = buf->pages + (base >> PAGE_CACHE_SHIFT);
-		base &= ~PAGE_CACHE_MASK;
-		avail_page = min_t(unsigned int, PAGE_CACHE_SIZE - base,
+		ppages = buf->pages + (base >> PAGE_SHIFT);
+		base &= ~PAGE_MASK;
+		avail_page = min_t(unsigned int, PAGE_SIZE - base,
 					avail_here);
 		c = kmap(*ppages) + base;
 
@@ -1383,7 +1383,7 @@ xdr_xcode_array2(struct xdr_buf *buf, unsigned int base,
 			}
 
 			avail_page = min(avail_here,
-				 (unsigned int) PAGE_CACHE_SIZE);
+				 (unsigned int) PAGE_SIZE);
 		}
 		base = buf->page_len;  /* align to start of tail */
 	}
@@ -1479,9 +1479,9 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 		if (page_len > len)
 			page_len = len;
 		len -= page_len;
-		page_offset = (offset + buf->page_base) & (PAGE_CACHE_SIZE - 1);
-		i = (offset + buf->page_base) >> PAGE_CACHE_SHIFT;
-		thislen = PAGE_CACHE_SIZE - page_offset;
+		page_offset = (offset + buf->page_base) & (PAGE_SIZE - 1);
+		i = (offset + buf->page_base) >> PAGE_SHIFT;
+		thislen = PAGE_SIZE - page_offset;
 		do {
 			if (thislen > page_len)
 				thislen = page_len;
@@ -1492,7 +1492,7 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 			page_len -= thislen;
 			i++;
 			page_offset = 0;
-			thislen = PAGE_CACHE_SIZE;
+			thislen = PAGE_SIZE;
 		} while (page_len != 0);
 		offset = 0;
 	}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
