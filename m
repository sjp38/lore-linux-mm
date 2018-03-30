Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9A0A6B028C
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:44:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s21so6251670pfm.15
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:44:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v14si4820371pgc.344.2018.03.29.20.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 20:42:55 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v10 00/62] Convert page cache to XArray
Date: Thu, 29 Mar 2018 20:41:43 -0700
Message-Id: <20180330034245.10462-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

I'd like to thank Andrew for taking the first eight XArray patches
into -next.  He's understandably nervous about taking the rest of the
patches into -next given how few of the remaining patches have review
tags on them.  So ... if you're on the cc, I'd really appreciate a review
on something that you feel somewhat responsible for, eg the particular
filesystem (nilfs, f2fs, lustre) that I've touched, or something in the
mm/ or fs/ directories that you've worked on recently.

This is against next-20180329.

Patch 1 is just cleanup of a couple of merge glitches.  You can ignore
this one, unless you're Andrew Morton, in which case I'd appreciate it
being added to -next.

Patch 2 is huge and mostly mechanical and boring.  Probably best to
ignore it.

Patches 3-16 are the XArray implementation.  You don't have to read
through them unless you really want to.  If you're going to look at
anything, spotting where I have gaps in the test-suite would probably
be a good use of time.  Some of the tests aren't added until much later
in the series (eg some of the xa_load tests aren't added until xa_store
is added because it's a pain to use the radix tree API to do the stores
and then use the XArray API to do the loads).

Patches 17-45 are generic code.  This is where I could really use some
review.  Each one is pretty small, usually only touching a single
function.  It should bisect perfectly to any point in this series
because the radix tree & XArray are interoperable (for now ...).  It
should be easy to review.  If not, let me know.

Patch 46 is btrfs and has been reviewed by David Sterba.  Yay!

Patches 47-48 are more generic code.  Hmm, probably should have
reordered them to be with 17-37.  This is what I get for working
alphabetically.

Patches 49-51 are individual filesystems.  If you're an expert in that
filesystem, please test and be sure I didn't break you.

Patches 52-60 are DAX patches.  I just redid the DAX patches and I'm
finally happy with how this part of the series came out; I think it
should be much easier to review, and I even fixed a few minor bugs.

Patches 61 & 62 are the icing on the cake, just some small cleanups.
I'm sure everybody wants to review patch 62 since it's just deleting
unused code.

Changes from v9:

 - Rebased on next-20180329
 - Added XA_STATE_ORDER
 - Decided that xas_load should return non-NULL if *any* entry overlapping
   the specified range is non-NULL (it won't necessarily be any of the
   entries in the range)
 - Added test suite for both above items
 - Redid DAX XArray conversion; should be easier to review now.

Matthew Wilcox (62):
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
  dax: Fix use of zero page
  dax: dax_insert_mapping_entry always succeeds
  dax: Rename some functions
  dax: Hash on XArray instead of mapping
  dax: Convert dax_insert_pfn_mkwrite to XArray
  dax: Convert dax_layout_busy_page to XArray
  dax: Convert __dax_invalidate_entry to XArray
  dax: Convert dax writeback to XArray
  dax: Convert page fault handlers to XArray
  page cache: Finish XArray conversion
  radix tree: Remove unused functions

 Documentation/core-api/index.rst                |    1 +
 Documentation/core-api/xarray.rst               |  361 +++++
 MAINTAINERS                                     |   12 +
 arch/nds32/include/asm/cacheflush.h             |    4 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h    |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h    |    4 +-
 drivers/gpu/drm/i915/i915_gem.c                 |   17 +-
 drivers/staging/lustre/lustre/llite/glimpse.c   |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   16 +-
 fs/btrfs/compression.c                          |    6 +-
 fs/btrfs/extent_io.c                            |   12 +-
 fs/buffer.c                                     |   14 +-
 fs/dax.c                                        |  768 +++++------
 fs/ext4/inode.c                                 |    2 +-
 fs/f2fs/data.c                                  |    5 +-
 fs/f2fs/dir.c                                   |    5 +-
 fs/f2fs/inline.c                                |    6 +-
 fs/f2fs/node.c                                  |   10 +-
 fs/fs-writeback.c                               |   25 +-
 fs/gfs2/aops.c                                  |    2 +-
 fs/inode.c                                      |    2 +-
 fs/nfs/blocklayout/blocklayout.c                |    2 +-
 fs/nilfs2/btnode.c                              |   37 +-
 fs/nilfs2/page.c                                |   72 +-
 fs/proc/task_mmu.c                              |    2 +-
 include/linux/fs.h                              |   63 +-
 include/linux/pagemap.h                         |   10 +-
 include/linux/pagevec.h                         |    8 +-
 include/linux/radix-tree.h                      |  110 +-
 include/linux/swap.h                            |   22 +-
 include/linux/swapops.h                         |   19 +-
 include/linux/xarray.h                          | 1008 ++++++++++++++
 lib/Makefile                                    |    2 +-
 lib/idr.c                                       |   65 +-
 lib/radix-tree.c                                |  535 ++------
 lib/xarray.c                                    | 1681 +++++++++++++++++++++++
 mm/filemap.c                                    |  723 ++++------
 mm/huge_memory.c                                |   17 +-
 mm/khugepaged.c                                 |  177 +--
 mm/madvise.c                                    |    2 +-
 mm/memcontrol.c                                 |    2 +-
 mm/memfd.c                                      |  102 +-
 mm/migrate.c                                    |   41 +-
 mm/mincore.c                                    |    2 +-
 mm/page-writeback.c                             |   63 +-
 mm/readahead.c                                  |   10 +-
 mm/shmem.c                                      |  198 ++-
 mm/swap.c                                       |    6 +-
 mm/swap_state.c                                 |  119 +-
 mm/truncate.c                                   |   27 +-
 mm/vmscan.c                                     |    2 +-
 mm/workingset.c                                 |   71 +-
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
 tools/testing/radix-tree/multiorder.c           |  270 +---
 tools/testing/radix-tree/regression1.c          |   68 +-
 tools/testing/radix-tree/test.c                 |   53 +-
 tools/testing/radix-tree/test.h                 |    6 +
 tools/testing/radix-tree/xarray-test.c          |  594 ++++++++
 68 files changed, 5008 insertions(+), 2619 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 lib/xarray.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/lockdep.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c

-- 
2.16.2
