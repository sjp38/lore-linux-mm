Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 995F06B02A9
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:15:23 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g61-v6so7581963plb.10
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:15:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k186si5957439pga.676.2018.04.14.07.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:25 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 00/63] Convert page cache to XArray
Date: Sat, 14 Apr 2018 07:12:13 -0700
Message-Id: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

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

Since version 10, I've fixed a few bugs.

 - There were some places in f2fs where the spinlock was being taken in a
   not-irq-safe manner.  I spotted it by review, but lockdep would have
   noticed if anybody had tested this patchset on f2fs.
 - Fixed the bug that Mike Kravetz found where we could end up in an
   infinite loop when doing a tagged iteration.
 - Added UBSAN to the userspace testing framework and fixed some
   problems that it caught (shifting a negative number, shifting by
   BITS_PER_LONG).
 - Fixed an unlikely bug in shmem_partial_swap_usage() where I'd
   forgotten to call xas_retry() in an RCU-protected iteration.
 - Added a patch to fix dax_load_hole; it wasn't returning errors
   properly.

Things that aren't bug fixes:

 - dax_layout_busy_page() got removed, so I dropped the adaptation of
   that function.
 - Made __test_set_page_writeback more efficient by only walking the
   tree once instead of up to three times (once per tag).
 - Redid the shmem_wait_for_pins / shmem_tag_pins patches so they share
   an xa_state between them.  Cuts down stack usage a bit.
 - Removed more radix tree functionality that's not being used
   - radix_tree_for_each_contig
   - radix_tree_update_node_t
   - radix_tree_clear_tags

This is against next-20180413.

If you're going to review anything, please review anything in patches 16
and higher; they're the ones mostly missing review, and most likely where
the bugs are going to be.

Matthew Wilcox (63):
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
  memfd: Convert shmem_wait_for_pins to XArray
  memfd: Convert shmem_tag_pins to XArray
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

 .clang-format                                 |    1 -
 Documentation/core-api/index.rst              |    1 +
 Documentation/core-api/xarray.rst             |  361 ++++
 MAINTAINERS                                   |   12 +
 arch/powerpc/include/asm/book3s/64/pgtable.h  |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h  |    4 +-
 drivers/gpu/drm/i915/i915_gem.c               |   17 +-
 drivers/staging/lustre/lustre/llite/glimpse.c |   12 +-
 .../staging/lustre/lustre/mdc/mdc_request.c   |   16 +-
 fs/btrfs/compression.c                        |    6 +-
 fs/btrfs/extent_io.c                          |   12 +-
 fs/buffer.c                                   |   14 +-
 fs/dax.c                                      |  725 +++----
 fs/ext4/inode.c                               |    2 +-
 fs/f2fs/data.c                                |    5 +-
 fs/f2fs/dir.c                                 |    2 +-
 fs/f2fs/inline.c                              |    4 +-
 fs/f2fs/node.c                                |    9 +-
 fs/fs-writeback.c                             |   25 +-
 fs/gfs2/aops.c                                |    2 +-
 fs/inode.c                                    |    2 +-
 fs/nfs/blocklayout/blocklayout.c              |    2 +-
 fs/nilfs2/btnode.c                            |   37 +-
 fs/nilfs2/page.c                              |   72 +-
 fs/proc/task_mmu.c                            |    2 +-
 include/linux/fs.h                            |   63 +-
 include/linux/pagemap.h                       |   10 +-
 include/linux/pagevec.h                       |    8 +-
 include/linux/radix-tree.h                    |  133 +-
 include/linux/swap.h                          |   22 +-
 include/linux/swapops.h                       |   19 +-
 include/linux/xarray.h                        | 1010 ++++++++++
 lib/Makefile                                  |    2 +-
 lib/idr.c                                     |   67 +-
 lib/radix-tree.c                              |  571 +-----
 lib/xarray.c                                  | 1681 +++++++++++++++++
 mm/filemap.c                                  |  723 +++----
 mm/huge_memory.c                              |   17 +-
 mm/khugepaged.c                               |  177 +-
 mm/madvise.c                                  |    2 +-
 mm/memcontrol.c                               |    2 +-
 mm/migrate.c                                  |   41 +-
 mm/mincore.c                                  |    2 +-
 mm/page-writeback.c                           |   72 +-
 mm/readahead.c                                |   10 +-
 mm/shmem.c                                    |  301 ++-
 mm/swap.c                                     |    6 +-
 mm/swap_state.c                               |  119 +-
 mm/truncate.c                                 |   27 +-
 mm/vmscan.c                                   |    2 +-
 mm/workingset.c                               |   71 +-
 tools/include/linux/spinlock.h                |   13 +-
 tools/testing/radix-tree/.gitignore           |    2 +
 tools/testing/radix-tree/Makefile             |   15 +-
 tools/testing/radix-tree/benchmark.c          |   91 -
 tools/testing/radix-tree/idr-test.c           |    6 +-
 tools/testing/radix-tree/linux/bug.h          |    1 +
 tools/testing/radix-tree/linux/kconfig.h      |    1 +
 tools/testing/radix-tree/linux/kernel.h       |    5 +
 tools/testing/radix-tree/linux/lockdep.h      |   11 +
 tools/testing/radix-tree/linux/rcupdate.h     |    2 +
 tools/testing/radix-tree/linux/xarray.h       |    3 +
 tools/testing/radix-tree/main.c               |   12 +-
 tools/testing/radix-tree/multiorder.c         |  272 +--
 tools/testing/radix-tree/regression1.c        |   68 +-
 tools/testing/radix-tree/regression3.c        |   22 -
 tools/testing/radix-tree/tag_check.c          |   32 +-
 tools/testing/radix-tree/test.c               |   53 +-
 tools/testing/radix-tree/test.h               |    6 +
 tools/testing/radix-tree/xarray-test.c        |  594 ++++++
 70 files changed, 5032 insertions(+), 2684 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 lib/xarray.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/lockdep.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c

-- 
2.17.0
