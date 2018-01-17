Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 057586B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:22:31 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f5so12105022pgp.18
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:22:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 61si5073867plz.68.2018.01.17.12.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:28 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 00/99] XArray version 6
Date: Wed, 17 Jan 2018 12:20:24 -0800
Message-Id: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This version of the XArray has no known bugs.  I have converted the
radix tree test suite entirely over to the XArray and fixed all bugs
that it has uncovered.  There are additional tests in the test suite for
the XArray, so I now claim the XArray has better test coverage than the
Radix Tree did.  Of course, that is not the same thing as fewer bugs,
but it now stands up to the tender embraces of Trinity without crashing.

You can get this version from my git tree here:
http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-2018-01-09
which includes a number of other patches that are at least tangentially
related to this patch set.

Most of the work I've done recently has been converting additional users
from the radix tree to the XArray.  That's going pretty well; still 24
radix tree users left to convert.  It's been worth doing because I've
spotted several common patterns that have led to changes (the lock_type,
reserve/release) and some common patterns that I'll add support for
later (chaining multiple entries from a single index, wanting to use
64-bit indices on 32-bit machines, having an array of XArrays, various
workarounds for not having range entries yet).

As far as line count goes, for the whole git tree, we're at:
 212 files changed, 7764 insertions(+), 7002 deletions(-)
with another 1376 lines to delete from radix-tree.[ch].  That doesn't take
into account the 371 lines of xarray.rst, the 587 lines of xarray-test.c,
and the fact that almost half of lib/xarray.c and include/linux/xarray.h
is documentation.

Changes since version 5:

 - Rebased to 4.15-rc8

API changes:
 - Renamed __xa_init() to xa_init_flags().
 - Added DEFINE_XARRAY_FLAGS().
 - Renamed xa_ctx to xa_lock_type; store it in the XA_FLAGS and use separate
   locking classes for each type so that lockdep doesn't emit spurious
   warnings.  It also reduces the amount of boilerplate.
 - Combined __xa_store_bh, __xa_store_irq and __xa_store into __xa_store().
 - Ditto for __xa_cmpxchg().
 - Renamed xa_store_empty() to xa_insert().
 - Added __xa_insert().
 - Added xa_reserve() and xa_release().
 - Renamed XA_NO_TAG to XA_PRESENT.
 - Combined xa_get_entries(), xa_get_tagged() and xa_get_maybe_tag()
   into xa_extract().
 - Added 'filter' argument to xa_find(), xa_find_after() and xa_for_each()
   to match xa_extract() and provide the functionality that would
   have otherwise had to be added in the form of xa_find_tag(),
   xa_find_tag_after() and xa_for_each_tag().
 - Replaced workingset_lookup_update() with mapping_set_update().
 - Renamed page_cache_tree_delete() to page_cache_delete().

New xarray users:
 - Converted SuperH interrupt controller radix tree to XArray.
 - Converted blk-cgroup radix tree to XArray.
 - Converted blk-ioc radix tree to XArray.
 - Converted i915 handles_vma radix tree to XArray.
 - Converted s390 gmap radix trees to XArray.
 - Converted hwspinlock to XArray.
 - Converted btrfs fs_roots to XArray.
 - Converted btrfs reada_zones to XArray.
 - Converted btrfs reada_extents to XArray.
 - Converted btrfs reada_tree to XArray.
 - Converted btrfs buffer_radix to XArray.
 - Converted btrfs delayed_nodes to XArray.
 - Converted btrfs name_cache to XArray.
 - Converted f2fs pids radix tree to XArray.
 - Converted f2fs ino_root radix tree to XArray.
 - Converted f2fs extent_tree to XArray.
 - Converted f2fs gclist radix tree to XArray.
 - Converted dma-debug active cacheline radix tree to XArray.
 - Converted Xen pvcalls-back socketpass_mappings to XArray.
 - Converted net/qrtr radix tree to XArray.
 - Converted null_blk radix trees to XArray.

Documentation:
 - Added a bit more internals documentation.
 - Rewrote xa_init_flags documentation.
 - Added the __xa_ functions to the locking table.
 - Rewrote the section on using the __xa_ functions.

Internal changes:
 - Free up the bottom four bits of the xa_flags, since these are not
   valid GFP flags to pass to kmem_cache_alloc().
 - Moved the XA_FLAGS_TRACK_FREE bit to the bottom bits of the flags to leave
   space for more tags (later).
 - Fixed multiple bugs in xas_find() and xas_find_tag().
 - Fixed bug in shrinking XArray (and add a test case that exercises it).
 - Fixed bug in erasing multi-index entries.
 - Fixed a compile warning with CONFIG_RADIX_TREE_MULTIORDER=n.
 - Added an xas_update() helper.
 - Use ->array to track an xa_node's state through its lifecycle
   (allocated -> rcu_free -> actually free).
 - Made XA_BUG_ON dump the entire tree while XA_NODE_BUG_ON dumps only the
   node that appears suspect.
 - Fixed debugging printks to use %px and pr_cont/pr_info etc.
 - Renamed some internal tag functions.
 - Moved xa_track_free() from xarray.h to xarray.c.

Test suite:
 - Added new tests for xas_find() and xas_find_tag().
 - Added new tests for the update_node functionality.
 - Converted the radix tree test suite to the xarray API.

Matthew Wilcox (99):
  xarray: Add the xa_lock to the radix_tree_root
  page cache: Use xa_lock
  xarray: Replace exceptional entries
  xarray: Change definition of sibling entries
  xarray: Add definition of struct xarray
  xarray: Define struct xa_node
  xarray: Add documentation
  xarray: Add xa_load
  xarray: Add xa_get_tag, xa_set_tag and xa_clear_tag
  xarray: Add xa_store
  xarray: Add xa_cmpxchg and xa_insert
  xarray: Add xa_for_each
  xarray: Add xa_extract
  xarray: Add xa_destroy
  xarray: Add xas_next and xas_prev
  xarray: Add xas_create_range
  xarray: Add MAINTAINERS entry
  xarray: Add ability to store errno values
  idr: Convert to XArray
  ida: Convert to XArray
  xarray: Add xa_reserve and xa_release
  page cache: Convert hole search to XArray
  page cache: Add page_cache_range_empty function
  page cache: Add and replace pages using the XArray
  page cache: Convert page deletion to XArray
  page cache: Convert page cache lookups to XArray
  page cache: Convert delete_batch to XArray
  page cache: Remove stray radix comment
  page cache: Convert filemap_range_has_page to XArray
  mm: Convert page-writeback to XArray
  mm: Convert workingset to XArray
  mm: Convert truncate to XArray
  mm: Convert add_to_swap_cache to XArray
  mm: Convert delete_from_swap_cache to XArray
  mm: Convert __do_page_cache_readahead to XArray
  mm: Convert page migration to XArray
  mm: Convert huge_memory to XArray
  mm: Convert collapse_shmem to XArray
  mm: Convert khugepaged_scan_shmem to XArray
  pagevec: Use xa_tag_t
  shmem: Convert replace to XArray
  shmem: Convert shmem_confirm_swap to XArray
  shmem: Convert find_swap_entry to XArray
  shmem: Convert shmem_tag_pins to XArray
  shmem: Convert shmem_wait_for_pins to XArray
  shmem: Convert shmem_add_to_page_cache to XArray
  shmem: Convert shmem_alloc_hugepage to XArray
  shmem: Convert shmem_free_swap to XArray
  shmem: Convert shmem_partial_swap_usage to XArray
  shmem: Comment fixups
  btrfs: Convert page cache to XArray
  fs: Convert buffer to XArray
  fs: Convert writeback to XArray
  nilfs2: Convert to XArray
  f2fs: Convert to XArray
  lustre: Convert to XArray
  dax: Convert dax_unlock_mapping_entry to XArray
  dax: Convert lock_slot to XArray
  dax: More XArray conversion
  dax: Convert __dax_invalidate_mapping_entry to XArray
  dax: Convert dax_writeback_one to XArray
  dax: Convert dax_insert_pfn_mkwrite to XArray
  dax: Convert dax_insert_mapping_entry to XArray
  dax: Convert grab_mapping_entry to XArray
  dax: Fix sparse warning
  page cache: Finish XArray conversion
  mm: Convert cgroup writeback to XArray
  vmalloc: Convert to XArray
  brd: Convert to XArray
  xfs: Convert m_perag_tree to XArray
  xfs: Convert pag_ici_root to XArray
  xfs: Convert xfs dquot to XArray
  xfs: Convert mru cache to XArray
  usb: Convert xhci-mem to XArray
  md: Convert raid5-cache to XArray
  irqdomain: Convert to XArray
  fscache: Convert to XArray
  sh: intc: Convert to XArray
  blk-cgroup: Convert to XArray
  blk-ioc: Convert to XArray
  i915: Convert handles_vma to XArray
  s390: Convert gmap to XArray
  hwspinlock: Convert to XArray
  btrfs: Convert fs_roots_radix to XArray
  btrfs: Remove unused spinlock
  btrfs: Convert reada_zones to XArray
  btrfs: Convert reada_extents to XArray
  btrfs: Convert reada_tree to XArray
  btrfs: Convert buffer_radix to XArray
  btrfs: Convert delayed_nodes_tree to XArray
  btrfs: Convert name_cache to XArray
  f2fs: Convert pids radix tree to XArray
  f2fs: Convert ino_root to XArray
  f2fs: Convert extent_tree_root to XArray
  f2fs: Convert gclist.iroot to XArray
  dma-debug: Convert to XArray
  xen: Convert pvcalls-back to XArray
  qrtr: Convert to XArray
  null_blk: Convert to XArray

 Documentation/cgroup-v1/memory.txt              |    2 +-
 Documentation/core-api/index.rst                |    1 +
 Documentation/core-api/xarray.rst               |  371 +++++
 Documentation/vm/page_migration                 |   14 +-
 MAINTAINERS                                     |   12 +
 arch/arm/include/asm/cacheflush.h               |    6 +-
 arch/nios2/include/asm/cacheflush.h             |    6 +-
 arch/parisc/include/asm/cacheflush.h            |    6 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h    |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h    |    4 +-
 arch/s390/include/asm/gmap.h                    |   12 +-
 arch/s390/mm/gmap.c                             |  133 +-
 block/bfq-cgroup.c                              |    4 +-
 block/blk-cgroup.c                              |   52 +-
 block/blk-ioc.c                                 |   13 +-
 block/cfq-iosched.c                             |    4 +-
 drivers/block/brd.c                             |   93 +-
 drivers/block/null_blk.c                        |   87 +-
 drivers/gpu/drm/i915/i915_gem.c                 |   19 +-
 drivers/gpu/drm/i915/i915_gem_context.c         |   12 +-
 drivers/gpu/drm/i915/i915_gem_context.h         |    4 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c      |    6 +-
 drivers/gpu/drm/i915/selftests/mock_context.c   |    2 +-
 drivers/hwspinlock/hwspinlock_core.c            |  151 +-
 drivers/md/raid5-cache.c                        |  119 +-
 drivers/sh/intc/core.c                          |    9 +-
 drivers/sh/intc/internals.h                     |    5 +-
 drivers/sh/intc/virq.c                          |   72 +-
 drivers/staging/lustre/lustre/llite/glimpse.c   |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   16 +-
 drivers/usb/host/xhci-mem.c                     |   68 +-
 drivers/usb/host/xhci.h                         |    6 +-
 drivers/xen/pvcalls-back.c                      |   51 +-
 fs/afs/write.c                                  |    9 +-
 fs/btrfs/btrfs_inode.h                          |    7 +-
 fs/btrfs/compression.c                          |    6 +-
 fs/btrfs/ctree.h                                |   31 +-
 fs/btrfs/delayed-inode.c                        |   65 +-
 fs/btrfs/disk-io.c                              |   73 +-
 fs/btrfs/extent_io.c                            |  106 +-
 fs/btrfs/inode.c                                |   72 +-
 fs/btrfs/reada.c                                |  205 ++-
 fs/btrfs/send.c                                 |   19 +-
 fs/btrfs/tests/btrfs-tests.c                    |   29 +-
 fs/btrfs/transaction.c                          |   87 +-
 fs/btrfs/volumes.c                              |    5 +-
 fs/btrfs/volumes.h                              |    5 +-
 fs/buffer.c                                     |   25 +-
 fs/cifs/file.c                                  |    9 +-
 fs/dax.c                                        |  383 ++---
 fs/ext4/inode.c                                 |    2 +-
 fs/f2fs/checkpoint.c                            |   85 +-
 fs/f2fs/data.c                                  |    9 +-
 fs/f2fs/dir.c                                   |    5 +-
 fs/f2fs/extent_cache.c                          |   59 +-
 fs/f2fs/f2fs.h                                  |    6 +-
 fs/f2fs/gc.c                                    |   14 +-
 fs/f2fs/gc.h                                    |    2 +-
 fs/f2fs/inline.c                                |    6 +-
 fs/f2fs/node.c                                  |   10 +-
 fs/f2fs/super.c                                 |    2 -
 fs/f2fs/trace.c                                 |   60 +-
 fs/f2fs/trace.h                                 |    2 -
 fs/fs-writeback.c                               |   37 +-
 fs/fscache/cookie.c                             |    6 +-
 fs/fscache/internal.h                           |    2 +-
 fs/fscache/object.c                             |    2 +-
 fs/fscache/page.c                               |  152 +-
 fs/fscache/stats.c                              |    6 +-
 fs/gfs2/aops.c                                  |    2 +-
 fs/inode.c                                      |   11 +-
 fs/nfs/blocklayout/blocklayout.c                |    2 +-
 fs/nilfs2/btnode.c                              |   41 +-
 fs/nilfs2/page.c                                |   78 +-
 fs/proc/task_mmu.c                              |    2 +-
 fs/xfs/libxfs/xfs_sb.c                          |   11 +-
 fs/xfs/libxfs/xfs_sb.h                          |    2 +-
 fs/xfs/xfs_dquot.c                              |   38 +-
 fs/xfs/xfs_icache.c                             |  146 +-
 fs/xfs/xfs_icache.h                             |   11 +-
 fs/xfs/xfs_inode.c                              |   24 +-
 fs/xfs/xfs_mount.c                              |   22 +-
 fs/xfs/xfs_mount.h                              |    6 +-
 fs/xfs/xfs_mru_cache.c                          |   72 +-
 fs/xfs/xfs_qm.c                                 |   36 +-
 fs/xfs/xfs_qm.h                                 |   18 +-
 include/linux/backing-dev-defs.h                |    2 +-
 include/linux/backing-dev.h                     |   14 +-
 include/linux/blk-cgroup.h                      |    5 +-
 include/linux/fs.h                              |   68 +-
 include/linux/fscache.h                         |    8 +-
 include/linux/idr.h                             |  168 ++-
 include/linux/iocontext.h                       |    6 +-
 include/linux/irqdomain.h                       |   10 +-
 include/linux/mm.h                              |   17 +-
 include/linux/pagemap.h                         |   16 +-
 include/linux/pagevec.h                         |    8 +-
 include/linux/radix-tree.h                      |   97 +-
 include/linux/swap.h                            |   22 +-
 include/linux/swapops.h                         |   19 +-
 include/linux/xarray.h                          | 1052 ++++++++++++++
 kernel/irq/irqdomain.c                          |   39 +-
 kernel/pid.c                                    |    2 +-
 lib/Makefile                                    |    2 +-
 lib/dma-debug.c                                 |  105 +-
 lib/idr.c                                       |  633 ++++----
 lib/radix-tree.c                                |  399 ++----
 lib/xarray.c                                    | 1753 +++++++++++++++++++++++
 mm/backing-dev.c                                |   22 +-
 mm/filemap.c                                    |  766 ++++------
 mm/huge_memory.c                                |   23 +-
 mm/khugepaged.c                                 |  182 +--
 mm/madvise.c                                    |    2 +-
 mm/memcontrol.c                                 |    6 +-
 mm/memory.c                                     |   16 +-
 mm/migrate.c                                    |   41 +-
 mm/mincore.c                                    |    2 +-
 mm/page-writeback.c                             |   78 +-
 mm/readahead.c                                  |   10 +-
 mm/rmap.c                                       |    4 +-
 mm/shmem.c                                      |  312 ++--
 mm/swap.c                                       |    6 +-
 mm/swap_state.c                                 |  124 +-
 mm/truncate.c                                   |   45 +-
 mm/vmalloc.c                                    |   39 +-
 mm/vmscan.c                                     |   14 +-
 mm/workingset.c                                 |   89 +-
 net/qrtr/qrtr.c                                 |   21 +-
 tools/include/linux/spinlock.h                  |   12 +-
 tools/testing/radix-tree/.gitignore             |    2 +
 tools/testing/radix-tree/Makefile               |   15 +-
 tools/testing/radix-tree/idr-test.c             |   40 +-
 tools/testing/radix-tree/linux/bug.h            |    1 +
 tools/testing/radix-tree/linux/kconfig.h        |    1 +
 tools/testing/radix-tree/linux/kernel.h         |    5 +
 tools/testing/radix-tree/linux/lockdep.h        |   11 +
 tools/testing/radix-tree/linux/rcupdate.h       |    2 +
 tools/testing/radix-tree/linux/xarray.h         |    3 +
 tools/testing/radix-tree/multiorder.c           |   83 +-
 tools/testing/radix-tree/regression1.c          |   68 +-
 tools/testing/radix-tree/test.c                 |   53 +-
 tools/testing/radix-tree/test.h                 |    6 +
 tools/testing/radix-tree/xarray-test.c          |  587 ++++++++
 143 files changed, 6647 insertions(+), 3990 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 include/linux/xarray.h
 create mode 100644 lib/xarray.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/lockdep.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
