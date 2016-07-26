Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2FE6B0262
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:36:19 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hh10so364689512pac.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:36:19 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id n89si26411280pfa.261.2016.07.25.17.35.59
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 17:36:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 00/33] ext4: support of huge pages
Date: Tue, 26 Jul 2016 03:35:02 +0300
Message-Id: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's the first version of my patchset which intended to bring huge pages
to ext4. It's not yet ready for applying or serious use, but good enough
to show the approach.

The basics are the same as with tmpfs[1] which is in -mm tree and ext4
built on of it. The main difference is that we need to handle read out
from and write-back to backing storage.

Head page links buffers for whole huge page. Dirty/writeback tracking
happens on per-hugepage level.

We read out whole huge page at once. It required bumping BIO_MAX_PAGES to
512 to get it work on x86-64, which is hack. I'm not sure how to handle it
properly.

Readahead doesn't play with huge pages well too: 128k max readahead window,
assumption on page size, PageReadahead() to track hit/miss.
I've got it to allocate huge pages, but it doesn't provide any readahead as
such. I don't know how to do this right.

Unlike tmpfs, ext4 makes use of tags in radix-tree. The approach I used
for tmpfs -- 512 entries in radix-tree per-hugepages -- doesn't work well
if we want to have coherent view on tags. So the first 8 patches of the
patchset converts tmpfs to use multi-order entries in radix-tree.
The same infrastructure used for ext4.

Writeback works for simple cases, but xfstests manages to trigger BUG_ON()
eventually. That's what I work on currently. My understanding of writeback
process is still rather limited and any help would be appreciated.

For now I try to make xfstests run smoothly on filesystem with huge=always
and 4k block size. Once it will be done, I'll widen testing to 1k blocks,
encryption and bigalloc.

Any comments?

[1] http://lkml.kernel.org/r/1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com

TODO:
  - stabilize writeback;
  - make ext4_move_extents() work with huge pages (split them?);
  - check if memory reclaim process is adequate for huge pages with
    backing storage (unnecessary split_huge_page() ?);
  - handle shadow entries properly;
  - encryption, 1k blocks, bigalloc, ...
Kirill A. Shutemov (27):
  mm, shmem: swich huge tmpfs to multi-order radix-tree entries
  Revert "radix-tree: implement radix_tree_maybe_preload_order()"
  page-flags: relax page flag poliry for PG_error and PG_writeback
  mm, rmap: account file thp pages
  thp: allow splitting non-shmem file-backed THPs
  truncate: make sure invalidate_mapping_pages() can discard huge pages
  filemap: allocate huge page in page_cache_read(), if allowed
  filemap: handle huge pages in do_generic_file_read()
  filemap: allocate huge page in pagecache_get_page(), if allowed
  filemap: handle huge pages in filemap_fdatawait_range()
  HACK: readahead: alloc huge pages, if allowed
  HACK: block: bump BIO_MAX_PAGES
  mm: make write_cache_pages() work on huge pages
  thp: introduce hpage_size() and hpage_mask()
  fs: make block_read_full_page() be able to read huge page
  fs: make block_write_{begin,end}() be able to handle huge pages
  fs: make block_page_mkwrite() aware about huge pages
  truncate: make truncate_inode_pages_range() aware about huge pages
  ext4: make ext4_mpage_readpages() hugepage-aware
  ext4: make ext4_writepage() work on huge pages
  ext4: handle huge pages in ext4_page_mkwrite()
  ext4: handle huge pages in __ext4_block_zero_page_range()
  ext4: handle huge pages in ext4_da_write_end()
  ext4: relax assert in ext4_da_page_release_reservation()
  WIP: ext4: handle writeback with huge pages
  mm, fs, ext4: expand use of page_mapping() and page_to_pgoff()
  ext4, vfs: add huge= mount option

Matthew Wilcox (6):
  tools: Add WARN_ON_ONCE
  radix tree test suite: Allow GFP_ATOMIC allocations to fail
  radix-tree: Add radix_tree_join
  radix-tree: Add radix_tree_split
  radix-tree: Add radix_tree_split_preload()
  radix-tree: Handle multiorder entries being deleted by
    replace_clear_tags

 drivers/base/node.c                   |   6 +
 fs/buffer.c                           |  89 ++++---
 fs/ext4/ext4.h                        |   5 +
 fs/ext4/inode.c                       | 106 +++++---
 fs/ext4/page-io.c                     |  11 +-
 fs/ext4/readpage.c                    |  38 ++-
 fs/ext4/super.c                       |  19 ++
 fs/proc/meminfo.c                     |   4 +
 fs/proc/task_mmu.c                    |   5 +-
 include/linux/bio.h                   |   2 +-
 include/linux/buffer_head.h           |   9 +-
 include/linux/fs.h                    |   5 +
 include/linux/huge_mm.h               |  16 ++
 include/linux/mm.h                    |   1 +
 include/linux/mmzone.h                |   2 +
 include/linux/page-flags.h            |   8 +-
 include/linux/pagemap.h               |  22 +-
 include/linux/radix-tree.h            |  10 +-
 lib/radix-tree.c                      | 357 ++++++++++++++++++--------
 mm/filemap.c                          | 458 +++++++++++++++++++++++-----------
 mm/huge_memory.c                      |  51 +++-
 mm/khugepaged.c                       |  26 +-
 mm/memory.c                           |   4 +-
 mm/page-writeback.c                   |  19 +-
 mm/page_alloc.c                       |   5 +
 mm/readahead.c                        |  16 +-
 mm/rmap.c                             |  12 +-
 mm/shmem.c                            |  36 +--
 mm/truncate.c                         | 106 +++++++-
 mm/vmstat.c                           |   2 +
 tools/include/asm/bug.h               |  11 +
 tools/testing/radix-tree/Makefile     |   2 +-
 tools/testing/radix-tree/linux.c      |   7 +-
 tools/testing/radix-tree/linux/bug.h  |   2 +-
 tools/testing/radix-tree/linux/gfp.h  |  24 +-
 tools/testing/radix-tree/linux/slab.h |   5 -
 tools/testing/radix-tree/multiorder.c |  82 ++++++
 tools/testing/radix-tree/test.h       |   9 +
 38 files changed, 1162 insertions(+), 430 deletions(-)

-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
