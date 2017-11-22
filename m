Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF5E6B0268
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:07:54 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id b77so2189043pfl.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:07:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e3si15617626pfg.23.2017.11.22.13.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:07:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 00/62] XArray November 2017 Edition
Date: Wed, 22 Nov 2017 13:06:37 -0800
Message-Id: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

I've lost count of the number of times I've posted the XArray before,
so time for a new numbering scheme.  Here're two earlier versions,
https://lkml.org/lkml/2017/3/17/724
https://lwn.net/Articles/715948/ (this one's more loquacious in its
description of things that are better about the radix tree API than the
XArray).

This time around, I've gone for an approach of many small changes.
Unfortunately, that means you get 62 moderate patches instead of dozens
of big ones.

Some of these can and should go in independently of whether the XArray
is a good idea.  The first four fix some things in the test-suite.
Patch 6 changes the API for the IDR cyclic allocation.  Patch 7 changes
the API for the IDR 'extended' API that was recently added without my
review.

Patch 15 is messy and breaks any time anybody touches the page cache.
I'd like it to go in soon.  All it's doing is removing the page cache's
private spinlock and having it explicitly use the spinlock now embedded
in the xarray.

Patches 16-30 are all the fun infrastructure, adding pieces of the
xarray API.  This is probably a good place to focus review, particularly
if you're intent on critiquing the API.

Patches 31 onwards start actually using the new API, taking advantage of
the built-in locking and memory allocation to get rid of the preload
API.  There's probably the most scope for bugs here; I've tried to
understand the locking schemes used in thirty different places, and
maybe I got some of them wrong.

There will need to be many more patches.  Dozens, maybe hundreds.  Once
we've converted all the calls to radix_tree_insert() over to
xa_store(), we can get rid of the GFP flags stored in the xarray head.
That'll make the mm people a little happier.  Once we've got rid of
idr_preload(), we can get rid of the per-CPU cache of radix_tree_nodes.
I have a lot more enhancements on my todo list, but I'd like to get
something merged in the next cycle, and if I wait until my todo list is
empty, I will get nothing merged.

If you looked at earlier iterations, there was much more support for
huge pages.  That's not in this revision; I couldn't debug the problems
I was seeing.  I still have all that code, and I'm intending to put it
back in; it's just a bit down the todo list right now.

Matthew Wilcox (62):
  tools: Make __test_and_clear_bit available
  radix tree test suite: Remove ARRAY_SIZE
  radix tree test suite: Check reclaim bit
  idr test suite: Fix ida_test_random()
  radix tree: Add a missing cast to gfp_t
  idr: Make cursor explicit for cyclic allocation
  idr: Rewrite extended IDR API
  Explicitly include radix-tree.h
  arm64: Turn flush_dcache_mmap_lock into a no-op
  unicore32: Turn flush_dcache_mmap_lock into a no-op
  Export __set_page_dirty
  xfs: Rename xa_ elements to ail_
  fscache: Use appropriate radix tree accessors
  xarray: Add the xa_lock to the radix_tree_root
  page cache: Use xa_lock
  xarray: Replace exceptional entries
  xarray: Change definition of sibling entries
  xarray: Add definition of struct xarray
  xarray: Define struct xa_node
  xarray: Add xa_load
  xarray: Add xa_get_tag, xa_set_tag and xa_clear_tag
  xarray: Add xa_store
  xarray: Add xa_cmpxchg
  xarray: Add xa_for_each
  xarray: Add xa_init
  xarray: Add xas_for_each_tag
  xarray: Add xa_get_entries and xa_get_tagged
  xarray: Add xa_destroy
  xarray: Add xas_prev_any
  xarray: Add xas_find_any / xas_next_any
  Convert IDR to use xarray
  ida: Convert to using xarray
  page cache: Convert page_cache_next_hole to XArray
  page cache: Use xarray for adding pages
  page cache: Convert page_cache_tree_delete to xarray
  page cache: Convert find_get_entry to xarray
  shmem: Convert replace to xarray
  shmem: Convert shmem_confirm_swap to XArray
  shmem: Convert find_swap_entry to XArray
  shmem: Convert shmem_tag_pins to XArray
  shmem: Convert shmem_wait_for_pins to XArray
  vmalloc: Convert to xarray
  brd: Convert to XArray
  xfs: Convert m_perag_tree to XArray
  xfs: Convert pag_ici_root to XArray
  xfs: Convert xfs dquot to XArray
  xfs: Convert mru cache to XArray
  block: Remove IDR preloading
  rxrpc: Remove IDR preloading
  cgroup: Remove IDR wrappers
  dca: Remove idr_preload calls
  ipc: Remove call to idr_preload
  irq: Remove call to idr_preload
  scsi: Remove idr_preload in st driver
  firewire: Remove call to idr_preload
  drm: Remove drm_minor_lock and idr_preload
  drm: Remove drm_syncobj_fd_to_handle
  drm: Remove qxl driver IDR locks
  drm: Replace virtio IDRs with IDAs
  drm: Replace vmwgfx IDRs with IDAs
  net: Redesign act_api use of IDR
  mm: Convert page-writeback to XArray

 Documentation/cgroup-v1/memory.txt              |    2 +-
 Documentation/vm/page_migration                 |   14 +-
 arch/arm/include/asm/cacheflush.h               |    6 +-
 arch/arm64/include/asm/cacheflush.h             |    6 +-
 arch/nios2/include/asm/cacheflush.h             |    6 +-
 arch/parisc/include/asm/cacheflush.h            |    6 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h    |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h    |    4 +-
 arch/powerpc/platforms/cell/spufs/sched.c       |    2 +-
 arch/unicore32/include/asm/cacheflush.h         |    6 +-
 block/genhd.c                                   |   23 +-
 drivers/block/brd.c                             |   87 +-
 drivers/dca/dca-sysfs.c                         |   22 +-
 drivers/firewire/core-cdev.c                    |   20 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c         |    8 +-
 drivers/gpu/drm/drm_dp_aux_dev.c                |    5 +-
 drivers/gpu/drm/drm_drv.c                       |   25 +-
 drivers/gpu/drm/drm_gem.c                       |   27 +-
 drivers/gpu/drm/drm_syncobj.c                   |   23 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c    |    6 +-
 drivers/gpu/drm/i915/i915_debugfs.c             |    4 +-
 drivers/gpu/drm/i915/i915_gem.c                 |   17 +-
 drivers/gpu/drm/msm/msm_gem_submit.c            |   10 +-
 drivers/gpu/drm/qxl/qxl_cmd.c                   |   26 +-
 drivers/gpu/drm/qxl/qxl_drv.h                   |    2 -
 drivers/gpu/drm/qxl/qxl_kms.c                   |    2 -
 drivers/gpu/drm/qxl/qxl_release.c               |   12 +-
 drivers/gpu/drm/vc4/vc4_gem.c                   |    4 +-
 drivers/gpu/drm/virtio/virtgpu_drv.h            |    6 +-
 drivers/gpu/drm/virtio/virtgpu_kms.c            |   18 +-
 drivers/gpu/drm/virtio/virtgpu_vq.c             |   12 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.c             |    6 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h             |    2 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_resource.c        |   28 +-
 drivers/infiniband/core/cm.c                    |    5 +-
 drivers/infiniband/hw/mlx4/cm.c                 |    3 +-
 drivers/infiniband/hw/mlx4/mlx4_ib.h            |    1 +
 drivers/rapidio/rio_cm.c                        |    3 +-
 drivers/rpmsg/qcom_glink_native.c               |    7 +-
 drivers/scsi/st.c                               |   18 +-
 drivers/staging/lustre/lustre/llite/glimpse.c   |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   10 +-
 drivers/target/target_core_device.c             |    4 +-
 drivers/usb/host/xhci.h                         |    1 +
 fs/afs/write.c                                  |    2 +-
 fs/btrfs/compression.c                          |    4 +-
 fs/btrfs/extent_io.c                            |    8 +-
 fs/btrfs/inode.c                                |    4 +-
 fs/buffer.c                                     |   13 +-
 fs/cifs/file.c                                  |    2 +-
 fs/dax.c                                        |  204 ++--
 fs/f2fs/data.c                                  |    6 +-
 fs/f2fs/dir.c                                   |    6 +-
 fs/f2fs/gc.c                                    |    2 +-
 fs/f2fs/inline.c                                |    6 +-
 fs/f2fs/node.c                                  |    8 +-
 fs/fs-writeback.c                               |   18 +-
 fs/fscache/cookie.c                             |    2 +-
 fs/fscache/object.c                             |    2 +-
 fs/inode.c                                      |   11 +-
 fs/kernfs/dir.c                                 |    5 +-
 fs/nfsd/nfs4state.c                             |    4 +-
 fs/nfsd/state.h                                 |    1 +
 fs/nilfs2/btnode.c                              |   20 +-
 fs/nilfs2/page.c                                |   22 +-
 fs/notify/inotify/inotify_user.c                |   15 +-
 fs/proc/loadavg.c                               |    2 +-
 fs/proc/task_mmu.c                              |    2 +-
 fs/xfs/libxfs/xfs_sb.c                          |   11 +-
 fs/xfs/libxfs/xfs_sb.h                          |    2 +-
 fs/xfs/xfs_aops.c                               |   15 +-
 fs/xfs/xfs_buf_item.c                           |   10 +-
 fs/xfs/xfs_dquot.c                              |   37 +-
 fs/xfs/xfs_dquot_item.c                         |   11 +-
 fs/xfs/xfs_icache.c                             |  142 +--
 fs/xfs/xfs_icache.h                             |   10 +-
 fs/xfs/xfs_inode.c                              |   24 +-
 fs/xfs/xfs_inode_item.c                         |   22 +-
 fs/xfs/xfs_log.c                                |    6 +-
 fs/xfs/xfs_log_recover.c                        |   80 +-
 fs/xfs/xfs_mount.c                              |   22 +-
 fs/xfs/xfs_mount.h                              |    6 +-
 fs/xfs/xfs_mru_cache.c                          |   71 +-
 fs/xfs/xfs_qm.c                                 |   32 +-
 fs/xfs/xfs_qm.h                                 |   18 +-
 fs/xfs/xfs_trans.c                              |   18 +-
 fs/xfs/xfs_trans_ail.c                          |  152 +--
 fs/xfs/xfs_trans_buf.c                          |    4 +-
 fs/xfs/xfs_trans_priv.h                         |   42 +-
 include/drm/drm_file.h                          |    7 +-
 include/linux/backing-dev.h                     |   12 +-
 include/linux/fs.h                              |   68 +-
 include/linux/fscache.h                         |    1 +
 include/linux/fsnotify_backend.h                |    1 +
 include/linux/idr.h                             |  204 ++--
 include/linux/kernfs.h                          |    1 +
 include/linux/mm.h                              |    3 +-
 include/linux/pagemap.h                         |    4 +-
 include/linux/pid_namespace.h                   |    1 +
 include/linux/radix-tree.h                      |  111 +-
 include/linux/swapops.h                         |   19 +-
 include/linux/xarray.h                          |  717 +++++++++++
 include/net/act_api.h                           |   27 +-
 include/net/sctp/sctp.h                         |    1 +
 ipc/util.c                                      |   28 +-
 kernel/bpf/syscall.c                            |    8 +-
 kernel/cgroup/cgroup.c                          |   63 +-
 kernel/irq/timings.c                            |    4 +-
 kernel/pid.c                                    |    6 +-
 kernel/pid_namespace.c                          |   12 +-
 lib/Makefile                                    |    2 +-
 lib/dma-debug.c                                 |    1 +
 lib/idr.c                                       |  470 ++++----
 lib/radix-tree.c                                |  348 ++----
 lib/xarray.c                                    | 1444 +++++++++++++++++++++++
 mm/filemap.c                                    |  306 ++---
 mm/huge_memory.c                                |   10 +-
 mm/khugepaged.c                                 |   51 +-
 mm/madvise.c                                    |    2 +-
 mm/memcontrol.c                                 |    4 +-
 mm/migrate.c                                    |   31 +-
 mm/mincore.c                                    |    2 +-
 mm/page-writeback.c                             |   79 +-
 mm/readahead.c                                  |    4 +-
 mm/rmap.c                                       |    4 +-
 mm/shmem.c                                      |  196 ++-
 mm/swap.c                                       |    2 +-
 mm/swap_state.c                                 |   17 +-
 mm/truncate.c                                   |   34 +-
 mm/vmalloc.c                                    |   37 +-
 mm/vmscan.c                                     |   12 +-
 mm/workingset.c                                 |   34 +-
 net/rxrpc/af_rxrpc.c                            |    2 +-
 net/rxrpc/ar-internal.h                         |    1 +
 net/rxrpc/conn_client.c                         |   21 +-
 net/sched/act_api.c                             |  135 +--
 net/sched/cls_basic.c                           |   20 +-
 net/sched/cls_bpf.c                             |   20 +-
 net/sched/cls_flower.c                          |   32 +-
 net/sched/cls_u32.c                             |   44 +-
 net/sctp/associola.c                            |    3 +-
 net/sctp/protocol.c                             |    1 +
 tools/include/asm-generic/bitops.h              |    1 +
 tools/include/asm-generic/bitops/atomic.h       |    9 -
 tools/include/asm-generic/bitops/non-atomic.h   |  109 ++
 tools/include/linux/spinlock.h                  |    2 +
 tools/testing/radix-tree/.gitignore             |    2 +
 tools/testing/radix-tree/Makefile               |   14 +-
 tools/testing/radix-tree/idr-test.c             |   28 +-
 tools/testing/radix-tree/linux.c                |    2 +-
 tools/testing/radix-tree/linux/kernel.h         |    2 -
 tools/testing/radix-tree/linux/rcupdate.h       |    2 +
 tools/testing/radix-tree/linux/xarray.h         |    2 +
 tools/testing/radix-tree/multiorder.c           |   53 +-
 tools/testing/radix-tree/test.c                 |    8 +-
 tools/testing/radix-tree/xarray-test.c          |  122 ++
 156 files changed, 4178 insertions(+), 2454 deletions(-)
 create mode 100644 include/linux/xarray.h
 create mode 100644 lib/xarray.c
 create mode 100644 tools/include/asm-generic/bitops/non-atomic.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
