Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 438D36B0278
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s3-v6so7684054plp.21
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z11-v6si11518165pfd.357.2018.06.16.19.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:07 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 00/74] Convert page cache to XArray
Date: Sat, 16 Jun 2018 18:59:38 -0700
Message-Id: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

The XArray is a replacement for the radix tree.  For the moment it uses
the same data structures, enabling a gradual replacement.  This patch
set implements the XArray and converts the page cache to use it.

A version of these patches has been running under xfstests for over
48 hours, so I have some confidence in them.  The DAX changes have now
also had a reasonable test outing.  This is based on next-20180615 and
is available as a git tree at
git://git.infradead.org/users/willy/linux-dax.git xarray-20180615

I shall create a git branch from -rc1 and ask for that to be included in
-next.  I'm a little concerned I still have no reviews on some of the
later patches.

Changes since v13:
 - Actually fixed bug in workingset conversion that led to exceptional
   entries not being deleted from the XArray.  Not sure how I dropped
   that patch for v13.  Thanks to David Sterba for noticing.
 - Fixed bug in DAX writeback conversion that failed to wake up waiters.
   Thanks to Ross for testing, and to Dan & Jeff for helping me get a
   setup working to reproduce the problem.
 - Converted the new dax_lock_page / dax_unlock_page functions.
 - Moved XArray test suite entirely into the test_xarray kernel module
   to match other test suites.  It can still be built in userspace as
   part of the radix tree test suite.
 - Changed email address.
 - Moved a few functions into different patches to make the test-suite
   additions more logical.
 - Fixed a bug in XA_BUG_ON (oh the irony) where it evaluated the
   condition twice.
 - Constified xa_head() / xa_parent() / xa_entry() and their _locked
   variants.
 - Moved xa_parent() to xarray.h so it can be used from the workingset code.
 - Call the xarray testsuite from the radix tree test suite to ensure
   that I remember to run both test suites ;-)
 - Added some more tests to the test suite.

Matthew Wilcox (74):
  Update email address
  radix tree test suite: Enable ubsan
  dax: Fix use of zero page
  xarray: Replace exceptional entries
  xarray: Change definition of sibling entries
  xarray: Add definition of struct xarray
  xarray: Define struct xa_node
  xarray: Add documentation
  xarray: Add XArray load operation
  xarray: Add XArray tags
  xarray: Add XArray unconditional store operations
  xarray: Add XArray conditional store operations
  xarray: Add XArray iterators
  xarray: Extract entries from an XArray
  xarray: Destroy an XArray
  xarray: Step through an XArray
  xarray: Add xas_for_each_conflict
  xarray: Add xas_create_range
  xarray: Add MAINTAINERS entry
  page cache: Rearrange address_space
  page cache: Convert hole search to XArray
  page cache: Add and replace pages using the XArray
  page cache: Convert page deletion to XArray
  page cache: Convert find_get_entry to XArray
  page cache: Convert find_get_entries to XArray
  page cache: Convert find_get_pages_range to XArray
  page cache: Convert find_get_pages_contig to XArray
  page cache; Convert find_get_pages_range_tag to XArray
  page cache: Convert find_get_entries_tag to XArray
  page cache: Convert filemap_map_pages to XArray
  radix tree test suite: Convert regression1 to XArray
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
  mm: Convert is_page_cache_freeable to XArray
  pagevec: Use xa_tag_t
  shmem: Convert shmem_radix_tree_replace to XArray
  shmem: Convert shmem_confirm_swap to XArray
  shmem: Convert find_swap_entry to XArray
  shmem: Convert shmem_add_to_page_cache to XArray
  shmem: Convert shmem_alloc_hugepage to XArray
  shmem: Convert shmem_free_swap to XArray
  shmem: Convert shmem_partial_swap_usage to XArray
  memfd: Convert memfd_wait_for_pins to XArray
  memfd: Convert memfd_tag_pins to XArray
  shmem: Comment fixups
  btrfs: Convert page cache to XArray
  fs: Convert buffer to XArray
  fs: Convert writeback to XArray
  nilfs2: Convert to XArray
  f2fs: Convert to XArray
  dax: Rename some functions
  dax: Hash on XArray instead of mapping
  dax: Convert dax_insert_pfn_mkwrite to XArray
  dax: Convert dax_layout_busy_page to XArray
  dax: Convert __dax_invalidate_entry to XArray
  dax: Convert dax writeback to XArray
  dax: Convert dax_lock_page to XArray
  dax: Convert page fault handlers to XArray
  page cache: Finish XArray conversion
  radix tree: Remove radix_tree_update_node_t
  radix tree: Remove split/join code
  radix tree: Remove radix_tree_maybe_preload_order
  radix tree: Remove radix_tree_clear_tags

 .clang-format                                 |    1 -
 .mailmap                                      |    7 +
 Documentation/core-api/index.rst              |    1 +
 Documentation/core-api/xarray.rst             |  395 ++++
 MAINTAINERS                                   |   17 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h  |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h  |    4 +-
 drivers/gpu/drm/i915/i915_gem.c               |   17 +-
 fs/btrfs/compression.c                        |    6 +-
 fs/btrfs/extent_io.c                          |   12 +-
 fs/buffer.c                                   |   14 +-
 fs/dax.c                                      |  878 ++++-----
 fs/ext4/inode.c                               |    2 +-
 fs/f2fs/data.c                                |    6 +-
 fs/f2fs/dir.c                                 |    2 +-
 fs/f2fs/f2fs.h                                |    2 +-
 fs/f2fs/inline.c                              |    2 +-
 fs/f2fs/node.c                                |    6 +-
 fs/fs-writeback.c                             |   25 +-
 fs/gfs2/aops.c                                |    2 +-
 fs/inode.c                                    |    2 +-
 fs/nfs/blocklayout/blocklayout.c              |    2 +-
 fs/nilfs2/btnode.c                            |   26 +-
 fs/nilfs2/page.c                              |   29 +-
 fs/proc/task_mmu.c                            |    2 +-
 include/linux/fs.h                            |   63 +-
 include/linux/pagemap.h                       |   10 +-
 include/linux/pagevec.h                       |    8 +-
 include/linux/radix-tree.h                    |  136 +-
 include/linux/swap.h                          |   22 +-
 include/linux/swapops.h                       |   19 +-
 include/linux/xarray.h                        | 1047 +++++++++-
 lib/Kconfig.debug                             |    3 +
 lib/Makefile                                  |    3 +-
 lib/idr.c                                     |   66 +-
 lib/radix-tree.c                              |  575 +-----
 lib/test_xarray.c                             |  676 +++++++
 lib/xarray.c                                  | 1753 +++++++++++++++++
 mm/filemap.c                                  |  723 +++----
 mm/huge_memory.c                              |   17 +-
 mm/khugepaged.c                               |  177 +-
 mm/madvise.c                                  |    2 +-
 mm/memcontrol.c                               |    2 +-
 mm/memfd.c                                    |  105 +-
 mm/migrate.c                                  |   48 +-
 mm/mincore.c                                  |    2 +-
 mm/page-writeback.c                           |   72 +-
 mm/readahead.c                                |   10 +-
 mm/shmem.c                                    |  201 +-
 mm/swap.c                                     |    6 +-
 mm/swap_state.c                               |  119 +-
 mm/truncate.c                                 |   27 +-
 mm/vmscan.c                                   |   10 +-
 mm/workingset.c                               |   69 +-
 tools/include/asm-generic/bitops.h            |    1 +
 tools/include/asm-generic/bitops/atomic.h     |    9 -
 tools/include/asm-generic/bitops/non-atomic.h |  109 +
 tools/include/linux/bitmap.h                  |    1 +
 tools/include/linux/kernel.h                  |    1 +
 tools/include/linux/spinlock.h                |   12 +-
 tools/testing/radix-tree/.gitignore           |    1 +
 tools/testing/radix-tree/Makefile             |   16 +-
 tools/testing/radix-tree/benchmark.c          |   91 -
 tools/testing/radix-tree/bitmap.c             |   23 +
 tools/testing/radix-tree/idr-test.c           |    6 +-
 tools/testing/radix-tree/linux/bug.h          |    1 +
 tools/testing/radix-tree/linux/kconfig.h      |    1 +
 tools/testing/radix-tree/linux/kernel.h       |    5 +
 tools/testing/radix-tree/linux/lockdep.h      |   11 +
 tools/testing/radix-tree/linux/radix-tree.h   |    1 -
 tools/testing/radix-tree/linux/rcupdate.h     |    2 +
 tools/testing/radix-tree/linux/xarray.h       |    2 +
 tools/testing/radix-tree/main.c               |   21 +-
 tools/testing/radix-tree/multiorder.c         |  272 +--
 tools/testing/radix-tree/regression1.c        |   58 +-
 tools/testing/radix-tree/regression3.c        |   23 -
 tools/testing/radix-tree/tag_check.c          |   29 -
 tools/testing/radix-tree/test.c               |    8 +-
 tools/testing/radix-tree/test.h               |    1 +
 tools/testing/radix-tree/xarray.c             |   33 +
 80 files changed, 5462 insertions(+), 2711 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 lib/test_xarray.c
 create mode 100644 lib/xarray.c
 create mode 100644 tools/include/asm-generic/bitops/non-atomic.h
 create mode 100644 tools/testing/radix-tree/bitmap.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/lockdep.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray.c

-- 
2.17.1
