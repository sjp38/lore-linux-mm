Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCB616B0008
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 14:24:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m198so8054937pga.4
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 11:24:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u2-v6si11541757plm.476.2018.03.06.11.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 11:24:19 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v8 00/63] XArray v8
Date: Tue,  6 Mar 2018 11:23:10 -0800
Message-Id: <20180306192413.5499-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This patchset is, I believe, appropriate for merging for 4.17.
It contains the XArray implementation, to eventually replace the radix
tree, and converts the page cache to use it.

This conversion keeps the radix tree and XArray data structures in sync
at all times.  That allows us to convert the page cache one function at
a time and should allow for easier bisection.  Other than renaming some
elements of the structures, the data structures are fundamentally
unchanged; a radix tree walk and an XArray walk will touch the same
number of cachelines.  I have changes planned to the XArray data
structure, but those will happen in future patches.

Improvements the XArray has over the radix tree:

 - The radix tree provides operations like other trees do; 'insert' and
   'delete'.  But what most users really want is an automatically resizing
   array, and so it makes more sense to give users an API that is like
   an array -- 'load' and 'store'.  We still have an 'insert' operation
   for users that really want that semantic.
 - The XArray considers locking as part of its API.  This simplifies a lot
   of users who formerly had to manage their own locking just for the
   radix tree.  It also improves code generation as we can now tell RCU
   that we're holding a lock and it doesn't need to generate as much
   fencing code.  The other advantage is that tree nodes can be moved
   (not yet implemented).
 - GFP flags are now parameters to calls which may need to allocate
   memory.  The radix tree forced users to decide what the allocation
   flags would be at creation time.  It's much clearer to specify them
   at allocation time.
 - Memory is not preloaded; we don't tie up dozens of pages on the
   off chance that the slab allocator fails.  Instead, we drop the lock,
   allocate a new node and retry the operation.  We have to convert all
   the radix tree, IDA and IDR preload users before we can realise this
   benefit, but I have not yet found a user which cannot be converted.
 - The XArray provides a cmpxchg operation.  The radix tree forces users
   to roll their own (and at least four have).
 - Iterators take a 'max' parameter.  That simplifies many users and
   will reduce the amount of iteration done.
 - Iteration can proceed backwards.  We only have one user for this, but
   since it's called as part of the pagefault readahead algorithm, that
   seemed worth mentioning.
 - RCU-protected pointers are not exposed as part of the API.  There are
   some fun bugs where the page cache forgets to use rcu_dereference()
   in the current codebase.
 - Value entries gain an extra bit compared to radix tree exceptional
   entries.  That gives us the extra bit we need to put huge page swap
   entries in the page cache.
 - Some iterators now take a 'filter' argument instead of having
   separate iterators for tagged/untagged iterations.

The page cache is improved by this:
 - Shorter, easier to read code
 - More efficient iterations
 - Reduction in size of struct address_space
 - Fewer walks from the top of the data structure; the XArray API
   encourages staying at the leaf node and conducting operations there.

Changes since v7:
 - Added acks from Jeff Layton (thanks!)
 - Renamed the address_space ->pages to ->i_pages
 - Used GFP_ZONEMASK instead of the more obtuse shifting by 4 (Jeff Layton)
 - Realised that page_cache_range_empty() and filemap_range_has_page()
   were essentially the same function, so redid that pair of patches
 - A few checkpatch fixes
 - Added an SPDX tag to a missed file
 - Rebased on next-20180306
   - memfd moved out of shmem
   - nds32 needed its flush_dcache_mmap_lock fixed
   - mac80211_hwsim had added a use of IDA_INIT
 - Improved some documentation and commit messages
 - Split the rearrangement of struct address_space into its own patch (Kirill)
 - address_space documentation improvements had somehow worked their way
   into an unrelated patch; move them into the rearrangement patch.
 - Removed chunks of radix tree functionality that are not used any more.

Matthew Wilcox (63):
  mac80211_hwsim: Use DEFINE_IDA
  radix tree: Use GFP_ZONEMASK bits of gfp_t for flags
  arm64: Turn flush_dcache_mmap_lock into a no-op
  unicore32: Turn flush_dcache_mmap_lock into a no-op
  Export __set_page_dirty
  btrfs: Use filemap_range_has_page()
  xfs: Rename xa_ elements to ail_
  fscache: Use appropriate radix tree accessors
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
  page cache: Rearrange address_space
  page cache: Convert hole search to XArray
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
  shmem: Convert shmem_add_to_page_cache to XArray
  shmem: Convert shmem_alloc_hugepage to XArray
  shmem: Convert shmem_free_swap to XArray
  shmem: Convert shmem_partial_swap_usage to XArray
  memfd: Convert shmem_tag_pins to XArray
  memfd: Convert shmem_wait_for_pins to XArray
  shmem: Comment fixups
  btrfs: Convert page cache to XArray
  fs: Convert buffer to XArray
  fs: Convert writeback to XArray
  nilfs2: Convert to XArray
  f2fs: Convert to XArray
  lustre: Convert to XArray
  dax: Convert to XArray
  page cache: Finish XArray conversion
  radix tree: Remove unused functions

 Documentation/cgroup-v1/memory.txt              |    2 +-
 Documentation/core-api/index.rst                |    1 +
 Documentation/core-api/xarray.rst               |  361 +++++
 Documentation/vm/page_migration                 |   14 +-
 MAINTAINERS                                     |   12 +
 arch/arm/include/asm/cacheflush.h               |    6 +-
 arch/arm64/include/asm/cacheflush.h             |    6 +-
 arch/nds32/include/asm/cacheflush.h             |    4 +-
 arch/nios2/include/asm/cacheflush.h             |    6 +-
 arch/parisc/include/asm/cacheflush.h            |    6 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h    |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h    |    4 +-
 arch/unicore32/include/asm/cacheflush.h         |    6 +-
 drivers/gpu/drm/i915/i915_gem.c                 |   17 +-
 drivers/net/wireless/mac80211_hwsim.c           |    2 +-
 drivers/staging/lustre/lustre/llite/glimpse.c   |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   16 +-
 fs/afs/write.c                                  |    9 +-
 fs/btrfs/btrfs_inode.h                          |    6 +-
 fs/btrfs/compression.c                          |    6 +-
 fs/btrfs/extent_io.c                            |   26 +-
 fs/btrfs/inode.c                                |   70 -
 fs/buffer.c                                     |   28 +-
 fs/cifs/file.c                                  |    9 +-
 fs/dax.c                                        |  460 +++----
 fs/ext4/inode.c                                 |    2 +-
 fs/f2fs/data.c                                  |    9 +-
 fs/f2fs/dir.c                                   |    5 +-
 fs/f2fs/gc.c                                    |    2 +-
 fs/f2fs/inline.c                                |    6 +-
 fs/f2fs/node.c                                  |   10 +-
 fs/fs-writeback.c                               |   39 +-
 fs/fscache/cookie.c                             |    2 +-
 fs/fscache/object.c                             |    2 +-
 fs/gfs2/aops.c                                  |    2 +-
 fs/inode.c                                      |   11 +-
 fs/nfs/blocklayout/blocklayout.c                |    2 +-
 fs/nilfs2/btnode.c                              |   41 +-
 fs/nilfs2/page.c                                |   78 +-
 fs/proc/task_mmu.c                              |    2 +-
 fs/xfs/xfs_aops.c                               |   15 +-
 fs/xfs/xfs_buf_item.c                           |   10 +-
 fs/xfs/xfs_dquot.c                              |    4 +-
 fs/xfs/xfs_dquot_item.c                         |   11 +-
 fs/xfs/xfs_inode_item.c                         |   22 +-
 fs/xfs/xfs_log.c                                |    6 +-
 fs/xfs/xfs_log_recover.c                        |   80 +-
 fs/xfs/xfs_trans.c                              |   18 +-
 fs/xfs/xfs_trans_ail.c                          |  152 +--
 fs/xfs/xfs_trans_buf.c                          |    4 +-
 fs/xfs/xfs_trans_priv.h                         |   42 +-
 include/linux/backing-dev.h                     |   14 +-
 include/linux/fs.h                              |   67 +-
 include/linux/idr.h                             |   22 +-
 include/linux/mm.h                              |    3 +-
 include/linux/pagemap.h                         |   14 +-
 include/linux/pagevec.h                         |    8 +-
 include/linux/radix-tree.h                      |  112 +-
 include/linux/swap.h                            |   22 +-
 include/linux/swapops.h                         |   19 +-
 include/linux/xarray.h                          | 1015 ++++++++++++++
 kernel/pid.c                                    |    2 +-
 lib/Makefile                                    |    2 +-
 lib/idr.c                                       |   65 +-
 lib/radix-tree.c                                |  524 ++-----
 lib/xarray.c                                    | 1667 +++++++++++++++++++++++
 mm/filemap.c                                    |  757 ++++------
 mm/huge_memory.c                                |   21 +-
 mm/khugepaged.c                                 |  182 +--
 mm/madvise.c                                    |    2 +-
 mm/memcontrol.c                                 |    6 +-
 mm/memfd.c                                      |  102 +-
 mm/migrate.c                                    |   41 +-
 mm/mincore.c                                    |    2 +-
 mm/page-writeback.c                             |   78 +-
 mm/readahead.c                                  |   10 +-
 mm/rmap.c                                       |    4 +-
 mm/shmem.c                                      |  214 ++-
 mm/swap.c                                       |    6 +-
 mm/swap_state.c                                 |  124 +-
 mm/truncate.c                                   |   45 +-
 mm/vmscan.c                                     |   14 +-
 mm/workingset.c                                 |   89 +-
 tools/include/linux/spinlock.h                  |   14 +-
 tools/testing/radix-tree/.gitignore             |    2 +
 tools/testing/radix-tree/Makefile               |   15 +-
 tools/testing/radix-tree/idr-test.c             |    6 +-
 tools/testing/radix-tree/linux/bug.h            |    1 +
 tools/testing/radix-tree/linux/gfp.h            |    1 +
 tools/testing/radix-tree/linux/kconfig.h        |    1 +
 tools/testing/radix-tree/linux/kernel.h         |    5 +
 tools/testing/radix-tree/linux/lockdep.h        |   11 +
 tools/testing/radix-tree/linux/rcupdate.h       |    2 +
 tools/testing/radix-tree/linux/xarray.h         |    3 +
 tools/testing/radix-tree/multiorder.c           |   83 +-
 tools/testing/radix-tree/regression1.c          |   68 +-
 tools/testing/radix-tree/test.c                 |   53 +-
 tools/testing/radix-tree/test.h                 |    6 +
 tools/testing/radix-tree/xarray-test.c          |  549 ++++++++
 99 files changed, 5200 insertions(+), 2543 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 include/linux/xarray.h
 create mode 100644 lib/xarray.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/lockdep.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
