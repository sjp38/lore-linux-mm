Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBC726B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 22:51:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 62so4754130pfw.21
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 19:51:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 186si1959797pfg.141.2018.04.30.19.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 19:51:18 -0700 (PDT)
Date: Mon, 30 Apr 2018 19:51:17 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [GIT] XArray v12
Message-ID: <20180501025117.GC532@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org


I've made version 12 of the XArray and page cache conversion available at
git://git.infradead.org/users/willy/linux-dax.git xarray-20180430

Changes since v11:

 - At Goldwyn's request, renamed xas_for_each_tag -> xas_for_each_tagged,
   xas_find_tag -> xas_find_tagged and xas_next_tag -> xas_next_tagged
 - Fix performance regression (relative to radix_tree_tag_clear) when
   using xas_clear_tag to clear an already-cleared tag.
 - Use __test_and_set_bit in node_set_tag() rather than testing
   node_get_tag() before calling node_set_tag().
 - Added asm-generic/bitops/non-atomic.h to tools/include
 - Removed xas_create() from the exported API.  All callers can use xas_load
   instead.  It makes the callers more understanable and it reduces the
   size of the API.
 - Documented xas_create_range().
 - Improved the documentation for xas_store(), explaining the return value
   for a multi-index xa_state.
 - Re-re-did the memfd patches on top of the current state of play.
 - Used xas_set_order() to zero out all entries for a THP page instead
   of a loop in page_cache_delete().  Goldwyn pointed out the loop was
   ugly, and then so did everybody at LSFMM.
 - Rewrote the nilfs patch to be closer to the original radix tree-based
   code since I have no way of verifying it and the maintainer isn't
   responding to requests to see if it works.
 - f2fs dropped its copy of __set_page_dirty_buffers, so dropped my
   modification of it.
 - Fixed a missing irq-disable in shmem_free_swap().

Matthew Wilcox (63):
      xarray: Replace exceptional entries
      xarray: Change definition of sibling entries
      xarray: Add definition of struct xarray
      xarray: Define struct xa_node
      xarray: Add documentation
      xarray: Add xa_load
      xarray: Add XArray tags
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
      memfd: Convert memfd_wait_for_pins to XArray
      memfd: Convert memfd_tag_pins to XArray
      shmem: Comment fixups
      btrfs: Convert page cache to XArray
      fs: Convert buffer to XArray
      fs: Convert writeback to XArray
      nilfs2: Convert to XArray
      f2fs: Convert to XArray
      lustre: Convert to XArray
      dax: Fix use of zero page
      dax: dax_insert_mapping_entry always succeeds
      dax: Rename some functions
      dax: Hash on XArray instead of mapping
      dax: Convert dax_insert_pfn_mkwrite to XArray
      dax: Convert __dax_invalidate_entry to XArray
      dax: Convert dax writeback to XArray
      dax: Convert page fault handlers to XArray
      dax: Return fault code from dax_load_hole
      page cache: Finish XArray conversion
      radix tree: Remove unused functions
      radix tree: Remove radix_tree_update_node_t
      radix tree: Remove radix_tree_clear_tags

 .clang-format                                   |    1 -
 Documentation/core-api/index.rst                |    1 +
 Documentation/core-api/xarray.rst               |  360 +++++
 MAINTAINERS                                     |   12 +
 arch/powerpc/include/asm/book3s/64/pgtable.h    |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h    |    4 +-
 drivers/gpu/drm/i915/i915_gem.c                 |   17 +-
 drivers/staging/lustre/lustre/llite/glimpse.c   |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   16 +-
 fs/btrfs/compression.c                          |    6 +-
 fs/btrfs/extent_io.c                            |   12 +-
 fs/buffer.c                                     |   14 +-
 fs/dax.c                                        |  725 ++++------
 fs/ext4/inode.c                                 |    2 +-
 fs/f2fs/data.c                                  |    2 +-
 fs/f2fs/dir.c                                   |    2 +-
 fs/f2fs/inline.c                                |    4 +-
 fs/f2fs/node.c                                  |    9 +-
 fs/fs-writeback.c                               |   25 +-
 fs/gfs2/aops.c                                  |    2 +-
 fs/inode.c                                      |    2 +-
 fs/nfs/blocklayout/blocklayout.c                |    2 +-
 fs/nilfs2/btnode.c                              |   27 +-
 fs/nilfs2/page.c                                |   29 +-
 fs/proc/task_mmu.c                              |    2 +-
 include/linux/fs.h                              |   63 +-
 include/linux/pagemap.h                         |   10 +-
 include/linux/pagevec.h                         |    8 +-
 include/linux/radix-tree.h                      |  133 +-
 include/linux/swap.h                            |   22 +-
 include/linux/swapops.h                         |   19 +-
 include/linux/xarray.h                          | 1009 ++++++++++++++
 lib/Makefile                                    |    2 +-
 lib/idr.c                                       |   66 +-
 lib/radix-tree.c                                |  571 ++------
 lib/xarray.c                                    | 1688 +++++++++++++++++++++++
 mm/filemap.c                                    |  720 ++++------
 mm/huge_memory.c                                |   17 +-
 mm/khugepaged.c                                 |  177 +--
 mm/madvise.c                                    |    2 +-
 mm/memcontrol.c                                 |    2 +-
 mm/memfd.c                                      |  105 +-
 mm/migrate.c                                    |   48 +-
 mm/mincore.c                                    |    2 +-
 mm/page-writeback.c                             |   72 +-
 mm/readahead.c                                  |   10 +-
 mm/shmem.c                                      |  201 ++-
 mm/swap.c                                       |    6 +-
 mm/swap_state.c                                 |  119 +-
 mm/truncate.c                                   |   27 +-
 mm/vmscan.c                                     |    2 +-
 mm/workingset.c                                 |   71 +-
 tools/include/asm-generic/bitops.h              |    1 +
 tools/include/asm-generic/bitops/atomic.h       |    9 -
 tools/include/asm-generic/bitops/non-atomic.h   |  109 ++
 tools/include/linux/spinlock.h                  |   13 +-
 tools/testing/radix-tree/.gitignore             |    2 +
 tools/testing/radix-tree/Makefile               |   15 +-
 tools/testing/radix-tree/benchmark.c            |   91 --
 tools/testing/radix-tree/idr-test.c             |    6 +-
 tools/testing/radix-tree/linux/bug.h            |    1 +
 tools/testing/radix-tree/linux/kconfig.h        |    1 +
 tools/testing/radix-tree/linux/kernel.h         |    5 +
 tools/testing/radix-tree/linux/lockdep.h        |   11 +
 tools/testing/radix-tree/linux/rcupdate.h       |    2 +
 tools/testing/radix-tree/linux/xarray.h         |    3 +
 tools/testing/radix-tree/main.c                 |   12 +-
 tools/testing/radix-tree/multiorder.c           |  272 +---
 tools/testing/radix-tree/regression1.c          |   68 +-
 tools/testing/radix-tree/regression3.c          |   23 -
 tools/testing/radix-tree/tag_check.c            |   32 +-
 tools/testing/radix-tree/test.c                 |   53 +-
 tools/testing/radix-tree/test.h                 |    6 +
 tools/testing/radix-tree/xarray-test.c          |  597 ++++++++
 74 files changed, 5113 insertions(+), 2683 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 lib/xarray.c
 create mode 100644 tools/include/asm-generic/bitops/non-atomic.h
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/lockdep.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c
