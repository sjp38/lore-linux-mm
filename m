Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C58276B0270
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:42:11 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 200so1483713pge.12
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:42:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d11si938862plr.754.2017.12.05.16.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:09 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 00/73] XArray version 4
Date: Tue,  5 Dec 2017 16:40:46 -0800
Message-Id: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

I looked through some notes and decided this was version 4 of the XArray.
Last posted two weeks ago, this version includes a *lot* of changes.
I'd like to thank Dave Chinner for his feedback, encouragement and
distracting ideas for improvement, which I'll get to once this is merged.

Highlights:
 - Over 2000 words of documentation in patch 8!  And lots more kernel-doc.
 - The page cache is now fully converted to the XArray.
 - Many more tests in the test-suite.

This patch set is not for applying.  0day is still reporting problems,
and I'd feel bad for eating someone's data.  These patches apply on top
of a set of prepatory patches which just aren't interesting.  If you
want to see the patches applied to a tree, I suggest pulling my git tree:
http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-2017-12-04
I also left out the idr_preload removals.  They're still in the git tree,
but I'm not looking for feedback on them.

Changes since v3:

XArray API differences:
 - Store a pointer to the struct xarray in the xa_state (changes almost
   every prototype in the advanced API).
 - Added xas_lock() etc to operate on the XArray stored in the xa_state.
 - Added xa_erase() as a synonym for xa_store(..., NULL, 0).
 - Added __xa_erase() which is an exact replacement for radix_tree_delete();
   it assumes you are holding the xa_lock.
 - Renamed xa_next() to xa_find_after().
 - Renamed xas_next() to xas_next_entry().
 - Renamed xas_prev_any() and xas_next_any() to xas_prev() and xas_next().
 - Changed the semantics of xas_prev() and xas_next() substantially
   (see their kernel-doc).
 - Renamed skip entry to zero entry.
 - Introduced a new XAS_BOUNDS state to distinguish between an xa_state
   that has not been walked and an xa_state that has walked off the
   current end of the array.
 - Changed xas_set_err() to take a negative errno, not a positive one.
   XAS_ERROR still takes a positive errno, but this is an undocumented
   internal part of the implementation, not an API.
 - Changed behaviour when returning a multi-index entry; xas.xa_index
   is now always set to the first (canonical) index of this entry.
   Before, it was never rewound.  Eg if you have an entry occupying
   indices 4-7, and called xas_load() with xas.xa_index set to 6, it
   will now set xas.xa_index to 4.
 - Changed xas_nomem() to release any allocated memory if there is no
   ENOMEM error.  This means that (unless the user explicitly bypasses
   calling xas_nomem() on some path), there's no need to call xas_destroy()
   and it is removed from the API.
 - Added xas_create_range() for the benefit of our current hugepage users.
   I hope to be able to remove it again once they are converted to use
   multi-index entries.
 - Add xa_get_maybe_tag() which will call xa_get_entries() if you specify
   XA_NO_TAG and xa_get_tagged otherwise.

IDR API differences:
 - Removed the IDR cyclic API change (decided not to do it after all).
 - Made idr_alloc_ul() and idr_alloc_u32() assign the ID before inserting
   the pointer into the IDR, so a lookup cannot find an uninitialised object.

Bug fixes:
 - Made INIT_RADIX_TREE() initialise the xa_lock correctly so lockdep
   doesn't whine about it.
 - Fixed a locking bug in the IPC IDR conversion.
 - If we call xas_store(&xas, NULL) and that causes the XArray to shrink,
   set the xas to the XAS_BOUNDS state so we don't dereference a pointer
   to a node which has been passed to RCU free.  This is only a problem
   on !SMP machines.
 - Fixed bug when shrinking the XArray to a single entry at index 0.
 - Fixed bug where we could scan off the end of the slot array when storing
   a NULL.
 - Made xas_pause() not do anything if we're in an error state.  Before, it
   would have dereferenced a NULL pointer.
 - Fixed a bug in xa_find_after().  it just plain didn't work.  Now there is
   a test-case for it.

Conversions:
 - Converted backing dev cgroup code from radix tree to XArray.
 - Converted the USB XHCI driver from radix tree to XArray.
 - Moved btrfs_page_exists_in_range() guts to page cache code.
 - Renamed page_cache_{next,prev}_hole() to ..._gap().  The page cache
   doesn't cache holes.
 - Finished the page cache conversion.

Miscellaneous:
 - Documentation.  Lots and lots of documentation.  xarray.rst, more XArray
   kernel-doc and also IDR kernel-doc which has been missing for years.
 - Added MAINTAINERS entry for XArray/IDR.
 - Deleted the now-unused parts of the radix tree API (see git tree).
 - Added XA_DEBUG code and enable it in test-suite.
 - Improved code generation for initialising xa_state by explicitly
   initialising the struct padding (stupid gcc).
 - Stub out more code if CONFIG_RADIX_TREE_MULTIORDER isn't enabled.
 - Added more tests to the test-suite.
 - Removed the IDR preload conversions from this patch set (see git tree).

Matthew Wilcox (73):
  xfs: Rename xa_ elements to ail_
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
  xarray: Add xa_cmpxchg
  xarray: Add xa_for_each
  xarray: Add xas_for_each_tag
  xarray: Add xa_get_entries, xa_get_tagged and xa_get_maybe_tag
  xarray: Add xa_destroy
  xarray: Add xas_next and xas_prev
  xarray: Add xas_create_range
  xarray: Add MAINTAINERS entry
  idr: Convert to XArray
  ida: Convert to XArray
  page cache: Convert hole search to XArray
  page cache: Add page_cache_range_empty function
  page cache: Add and replace pages using the XArray
  page cache: Convert page deletion to XArray
  page cache: Convert page cache lookups to XArray
  page cache: Convert delete_batch to XArray
  page cache: Remove stray radix comment
  mm: Convert page-writeback to XArray
  mm: Convert workingset to XArray
  mm: Convert truncate to XArray
  mm: Convert add_to_swap_cache to XArray
  mm: Convert delete_from_swap_cache to XArray
  mm: Convert cgroup writeback to XArray
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
  vmalloc: Convert to XArray
  brd: Convert to XArray
  xfs: Convert m_perag_tree to XArray
  xfs: Convert pag_ici_root to XArray
  xfs: Convert xfs dquot to XArray
  xfs: Convert mru cache to XArray
  usb: Convert xhci-mem to XArray

 Documentation/cgroup-v1/memory.txt              |    2 +-
 Documentation/core-api/index.rst                |    1 +
 Documentation/core-api/xarray.rst               |  287 +++++
 Documentation/vm/page_migration                 |   14 +-
 MAINTAINERS                                     |   12 +
 arch/arm/include/asm/cacheflush.h               |    6 +-
 arch/nios2/include/asm/cacheflush.h             |    6 +-
 arch/parisc/include/asm/cacheflush.h            |    6 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h    |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h    |    4 +-
 drivers/block/brd.c                             |   87 +-
 drivers/gpu/drm/i915/i915_gem.c                 |   17 +-
 drivers/staging/lustre/lustre/llite/glimpse.c   |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   16 +-
 drivers/usb/host/xhci-mem.c                     |   70 +-
 drivers/usb/host/xhci.h                         |    6 +-
 fs/afs/write.c                                  |    2 +-
 fs/btrfs/btrfs_inode.h                          |    7 +-
 fs/btrfs/compression.c                          |    6 +-
 fs/btrfs/extent_io.c                            |   16 +-
 fs/btrfs/inode.c                                |   70 --
 fs/buffer.c                                     |   22 +-
 fs/cifs/file.c                                  |    2 +-
 fs/dax.c                                        |  382 +++---
 fs/ext4/inode.c                                 |    2 +-
 fs/f2fs/data.c                                  |    9 +-
 fs/f2fs/dir.c                                   |    5 +-
 fs/f2fs/gc.c                                    |    2 +-
 fs/f2fs/inline.c                                |    6 +-
 fs/f2fs/node.c                                  |   10 +-
 fs/fs-writeback.c                               |   37 +-
 fs/gfs2/aops.c                                  |    2 +-
 fs/inode.c                                      |   11 +-
 fs/nfs/blocklayout/blocklayout.c                |    2 +-
 fs/nilfs2/btnode.c                              |   41 +-
 fs/nilfs2/page.c                                |   78 +-
 fs/proc/task_mmu.c                              |    2 +-
 fs/xfs/libxfs/xfs_sb.c                          |   11 +-
 fs/xfs/libxfs/xfs_sb.h                          |    2 +-
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
 fs/xfs/xfs_mru_cache.c                          |   72 +-
 fs/xfs/xfs_qm.c                                 |   32 +-
 fs/xfs/xfs_qm.h                                 |   18 +-
 fs/xfs/xfs_trans.c                              |   18 +-
 fs/xfs/xfs_trans_ail.c                          |  152 +--
 fs/xfs/xfs_trans_buf.c                          |    4 +-
 fs/xfs/xfs_trans_priv.h                         |   42 +-
 include/linux/backing-dev-defs.h                |    2 +-
 include/linux/backing-dev.h                     |   14 +-
 include/linux/fs.h                              |   68 +-
 include/linux/idr.h                             |  173 ++-
 include/linux/mm.h                              |    2 +-
 include/linux/pagemap.h                         |   16 +-
 include/linux/pagevec.h                         |    8 +-
 include/linux/radix-tree.h                      |   95 +-
 include/linux/swap.h                            |    5 +-
 include/linux/swapops.h                         |   19 +-
 include/linux/xarray.h                          |  887 +++++++++++++
 kernel/pid.c                                    |    2 +-
 lib/Makefile                                    |    2 +-
 lib/idr.c                                       |  617 +++++----
 lib/radix-tree.c                                |  413 ++----
 lib/xarray.c                                    | 1520 +++++++++++++++++++++++
 mm/backing-dev.c                                |   28 +-
 mm/filemap.c                                    |  746 ++++-------
 mm/huge_memory.c                                |   23 +-
 mm/khugepaged.c                                 |  182 ++-
 mm/madvise.c                                    |    2 +-
 mm/memcontrol.c                                 |    4 +-
 mm/migrate.c                                    |   41 +-
 mm/mincore.c                                    |    2 +-
 mm/page-writeback.c                             |   78 +-
 mm/readahead.c                                  |   10 +-
 mm/rmap.c                                       |    4 +-
 mm/shmem.c                                      |  311 ++---
 mm/swap.c                                       |    6 +-
 mm/swap_state.c                                 |  124 +-
 mm/truncate.c                                   |   45 +-
 mm/vmalloc.c                                    |   39 +-
 mm/vmscan.c                                     |   14 +-
 mm/workingset.c                                 |   78 +-
 tools/include/linux/spinlock.h                  |    2 +
 tools/testing/radix-tree/.gitignore             |    2 +
 tools/testing/radix-tree/Makefile               |   15 +-
 tools/testing/radix-tree/idr-test.c             |   29 +-
 tools/testing/radix-tree/linux/bug.h            |    1 +
 tools/testing/radix-tree/linux/kconfig.h        |    1 +
 tools/testing/radix-tree/linux/rcupdate.h       |    2 +
 tools/testing/radix-tree/linux/xarray.h         |    3 +
 tools/testing/radix-tree/multiorder.c           |   53 +-
 tools/testing/radix-tree/regression1.c          |   68 +-
 tools/testing/radix-tree/test.c                 |    8 +-
 tools/testing/radix-tree/xarray-test.c          |  468 +++++++
 103 files changed, 5309 insertions(+), 2908 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 include/linux/xarray.h
 create mode 100644 lib/xarray.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
