Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D46376B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 12:13:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g13-v6so7383488pgv.11
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 09:13:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h130-v6si17204053pfe.119.2018.08.13.09.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 Aug 2018 09:13:58 -0700 (PDT)
Date: Mon, 13 Aug 2018 09:13:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [GIT PULL] XArray for 4.19
Message-ID: <20180813161357.GB1199@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Linus,

Please consider pulling the XArray patch set.  The XArray provides an
improved interface to the radix tree data structure, providing locking
as part of the API, specifying GFP flags at allocation time, eliminating
preloading, less re-walking the tree, more efficient iterations and not
exposing RCU-protected pointers to its users.

This patch set introduces the XArray implementation and converts the
pagecache over to use it.  The page cache is the most complex and
important user of the radix tree, so converting it was most important.
I have followup patches to convert the other users of the radix tree
over to the XArray, but that'll be another hundred or so patches and I
want to get this part in first.

There are two conflicts I wanted to flag; the first is against the
linux-nvdimm tree.  I rebased on top of one of the branches that went
into that tree, so if you pull my tree before linux-nvdimm, you'll get
fifteen commits I've had no involvement with.

The other is a fairly trivial one with ext4.  I've incorporated the
change from Ross that Ted merged into that tree into my tree, so please
take the resolution in my tree.

----------------------------------------------------------------
The following changes since commit 0c3a2a2ae2d76df077cf5a3c36ab8ac700058447:

  libnvdimm, pmem: Restore page attributes when clearing errors (2018-07-24 08:53:37 -0700)

are available in the Git repository at:

  git://git.infradead.org/users/willy/linux-dax.git xarray

for you to fetch changes up to 8d7cf3e16ed4a12ab6bfc05ccb60d70cb6200ffb:

  radix tree: Remove radix_tree_clear_tags (2018-08-10 00:49:25 -0400)

----------------------------------------------------------------
Matthew Wilcox (75):
      Update email address
      radix tree test suite: Enable ubsan
      dax: Fix use of zero page
      idr: Permit any valid kernel pointer to be stored
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
      dax: Convert dax_lock_mapping_entry to XArray
      dax: Convert page fault handlers to XArray
      page cache: Finish XArray conversion
      radix tree: Remove radix_tree_update_node_t
      radix tree: Remove split/join code
      radix tree: Remove radix_tree_maybe_preload_order
      radix tree: Remove radix_tree_clear_tags

 .clang-format                                 |    1 -
 .mailmap                                      |    7 +
 Documentation/core-api/index.rst              |    1 +
 Documentation/core-api/xarray.rst             |  392 ++++++
 MAINTAINERS                                   |   17 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h  |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h  |    4 +-
 drivers/gpu/drm/i915/i915_gem.c               |   17 +-
 fs/btrfs/compression.c                        |    6 +-
 fs/btrfs/extent_io.c                          |   12 +-
 fs/buffer.c                                   |   14 +-
 fs/dax.c                                      |  910 ++++++-------
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
 include/linux/xarray.h                        | 1054 ++++++++++++++-
 lib/Kconfig                                   |    7 +
 lib/Kconfig.debug                             |    3 +
 lib/Makefile                                  |    3 +-
 lib/idr.c                                     |   70 +-
 lib/radix-tree.c                              |  592 ++------
 lib/test_xarray.c                             |  837 ++++++++++++
 lib/xarray.c                                  | 1784 +++++++++++++++++++++++++
 mm/filemap.c                                  |  724 +++++-----
 mm/huge_memory.c                              |   17 +-
 mm/khugepaged.c                               |  178 +--
 mm/madvise.c                                  |    2 +-
 mm/memcontrol.c                               |    2 +-
 mm/memfd.c                                    |  105 +-
 mm/migrate.c                                  |   48 +-
 mm/mincore.c                                  |    2 +-
 mm/page-writeback.c                           |   72 +-
 mm/readahead.c                                |   10 +-
 mm/shmem.c                                    |  193 +--
 mm/swap.c                                     |    6 +-
 mm/swap_state.c                               |  119 +-
 mm/truncate.c                                 |   27 +-
 mm/vmscan.c                                   |   10 +-
 mm/workingset.c                               |   70 +-
 tools/include/asm-generic/bitops.h            |    1 +
 tools/include/asm-generic/bitops/atomic.h     |    9 -
 tools/include/asm-generic/bitops/non-atomic.h |  109 ++
 tools/include/linux/bitmap.h                  |    1 +
 tools/include/linux/kernel.h                  |    1 +
 tools/include/linux/spinlock.h                |   12 +-
 tools/testing/radix-tree/.gitignore           |    1 +
 tools/testing/radix-tree/Makefile             |   16 +-
 tools/testing/radix-tree/benchmark.c          |   91 --
 tools/testing/radix-tree/bitmap.c             |   23 +
 tools/testing/radix-tree/generated/autoconf.h |    1 +
 tools/testing/radix-tree/idr-test.c           |   69 +-
 tools/testing/radix-tree/linux/bug.h          |    1 +
 tools/testing/radix-tree/linux/kconfig.h      |    1 +
 tools/testing/radix-tree/linux/kernel.h       |    5 +
 tools/testing/radix-tree/linux/lockdep.h      |   11 +
 tools/testing/radix-tree/linux/radix-tree.h   |    1 -
 tools/testing/radix-tree/linux/rcupdate.h     |    2 +
 tools/testing/radix-tree/linux/xarray.h       |    2 +
 tools/testing/radix-tree/main.c               |   21 +-
 tools/testing/radix-tree/multiorder.c         |  272 +---
 tools/testing/radix-tree/regression1.c        |   58 +-
 tools/testing/radix-tree/regression3.c        |   23 -
 tools/testing/radix-tree/tag_check.c          |   29 -
 tools/testing/radix-tree/test.c               |    8 +-
 tools/testing/radix-tree/test.h               |    1 +
 tools/testing/radix-tree/xarray.c             |   35 +
 82 files changed, 5749 insertions(+), 2741 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 lib/test_xarray.c
 create mode 100644 lib/xarray.c
 create mode 100644 tools/include/asm-generic/bitops/non-atomic.h
 create mode 100644 tools/testing/radix-tree/bitmap.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/lockdep.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray.c
