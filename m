Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4A706B025E
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:38:41 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so5494058pad.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:38:41 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ag10si10064697pad.184.2016.08.12.11.38.39
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, 00/41] ext4: support of huge pages
Date: Fri, 12 Aug 2016 21:37:43 +0300
Message-Id: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's stabilized version of my patchset which intended to bring huge pages
to ext4.

The basics are the same as with tmpfs[1] which is in Linus' tree now and
ext4 built on top of it. The main difference is that we need to handle
read out from and write-back to backing storage.

Head page links buffers for whole huge page. Dirty/writeback tracking
happens on per-hugepage level.

We read out whole huge page at once. It required bumping BIO_MAX_PAGES to
not less than HPAGE_PMD_NR. I defined BIO_MAX_PAGES to HPAGE_PMD_NR if
huge pagecache enabled.

On split_huge_page() we need to free buffers before splitting the page.
Page buffers takes additional pin on the page and can be a vector to mess
with the page during split. We want to avoid this.
If try_to_free_buffers() fails, split_huge_page() would return -EBUSY.

Readahead doesn't play with huge pages well: 128k max readahead window,
assumption on page size, PageReadahead() to track hit/miss.  I've got it
to allocate huge pages, but it doesn't provide any readahead as such.
I don't know how to do this right. It's not clear at this point if we
really need readahead with huge pages. I guess it's good enough for now.

Shadow entries ignored on allocation -- recently evicted page is not
promoted to active list. Not sure if current workingset logic is adequate
for huge pages. On eviction, we split the huge page and setup 4k shadow
entries as usual.

Unlike tmpfs, ext4 makes use of tags in radix-tree. The approach I used
for tmpfs -- 512 entries in radix-tree per-hugepages -- doesn't work well
if we want to have coherent view on tags. So the first 8 patches of the
patchset converts tmpfs to use multi-order entries in radix-tree.
The same infrastructure used for ext4.

Encryption doesn't handle huge pages yet. To avoid regressions we just
disable huge pages for the inode if it has EXT4_INODE_ENCRYPT.

With this version I don't see any xfstests regressions with huge pages enabled.
Patch with new configurations for xfstests-bld is below.

Tested with 4k, 1k, encryption and bigalloc. All with and without
huge=always. I think it's reasonable coverage.

The patchset is also in git:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugeext4/v2

Please review and consider applying.

[1] http://lkml.kernel.org/r/1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com

TODO:
  - readahead ?;
  - wire up madvise()/fadvise();
  - encryption with huge pages;
  - reclaim of file huge pages can be optimized -- split_huge_page() is not
    required for pages with backing storage;

Kirill A. Shutemov (34):
  mm, shmem: swich huge tmpfs to multi-order radix-tree entries
  Revert "radix-tree: implement radix_tree_maybe_preload_order()"
  page-flags: relax page flag policy for few flags
  mm, rmap: account file thp pages
  thp: try to free page's buffers before attempt split
  thp: handle write-protection faults for file THP
  truncate: make sure invalidate_mapping_pages() can discard huge pages
  filemap: allocate huge page in page_cache_read(), if allowed
  filemap: handle huge pages in do_generic_file_read()
  filemap: allocate huge page in pagecache_get_page(), if allowed
  filemap: handle huge pages in filemap_fdatawait_range()
  HACK: readahead: alloc huge pages, if allowed
  block: define BIO_MAX_PAGES to HPAGE_PMD_NR if huge page cache enabled
  mm: make write_cache_pages() work on huge pages
  thp: introduce hpage_size() and hpage_mask()
  thp: do not threat slab pages as huge in hpage_{nr_pages,size,mask}
  fs: make block_read_full_page() be able to read huge page
  fs: make block_write_{begin,end}() be able to handle huge pages
  fs: make block_page_mkwrite() aware about huge pages
  truncate: make truncate_inode_pages_range() aware about huge pages
  truncate: make invalidate_inode_pages2_range() aware about huge pages
  ext4: make ext4_mpage_readpages() hugepage-aware
  ext4: make ext4_writepage() work on huge pages
  ext4: handle huge pages in ext4_page_mkwrite()
  ext4: handle huge pages in __ext4_block_zero_page_range()
  ext4: make ext4_block_write_begin() aware about huge pages
  ext4: handle huge pages in ext4_da_write_end()
  ext4: make ext4_da_page_release_reservation() aware about huge pages
  ext4: handle writeback with huge pages
  ext4: make EXT4_IOC_MOVE_EXT work with huge pages
  ext4: fix SEEK_DATA/SEEK_HOLE for huge pages
  ext4: make fallocate() operations work with huge pages
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

Naoya Horiguchi (1):
  mm, hugetlb: switch hugetlbfs to multi-order radix-tree entries

 drivers/base/node.c                   |   6 +
 fs/buffer.c                           |  89 +++---
 fs/ext4/ext4.h                        |   5 +
 fs/ext4/extents.c                     |  10 +-
 fs/ext4/file.c                        |  18 +-
 fs/ext4/inode.c                       | 159 ++++++----
 fs/ext4/move_extent.c                 |  12 +-
 fs/ext4/page-io.c                     |  11 +-
 fs/ext4/readpage.c                    |  38 ++-
 fs/ext4/super.c                       |  26 ++
 fs/hugetlbfs/inode.c                  |  22 +-
 fs/proc/meminfo.c                     |   4 +
 fs/proc/task_mmu.c                    |   5 +-
 include/linux/bio.h                   |   4 +
 include/linux/buffer_head.h           |  10 +-
 include/linux/fs.h                    |   5 +
 include/linux/huge_mm.h               |  18 +-
 include/linux/mm.h                    |   1 +
 include/linux/mmzone.h                |   2 +
 include/linux/page-flags.h            |  12 +-
 include/linux/pagemap.h               |  32 +-
 include/linux/radix-tree.h            |  10 +-
 lib/radix-tree.c                      | 357 ++++++++++++++++-------
 mm/filemap.c                          | 529 ++++++++++++++++++++++++----------
 mm/huge_memory.c                      |  69 ++++-
 mm/hugetlb.c                          |  19 +-
 mm/khugepaged.c                       |  26 +-
 mm/memory.c                           |  15 +-
 mm/page-writeback.c                   |  19 +-
 mm/page_alloc.c                       |   5 +
 mm/readahead.c                        |  17 +-
 mm/rmap.c                             |  12 +-
 mm/shmem.c                            |  36 +--
 mm/truncate.c                         | 138 +++++++--
 mm/vmstat.c                           |   2 +
 tools/include/asm/bug.h               |  11 +
 tools/testing/radix-tree/Makefile     |   2 +-
 tools/testing/radix-tree/linux.c      |   7 +-
 tools/testing/radix-tree/linux/bug.h  |   2 +-
 tools/testing/radix-tree/linux/gfp.h  |  24 +-
 tools/testing/radix-tree/linux/slab.h |   5 -
 tools/testing/radix-tree/multiorder.c |  82 ++++++
 tools/testing/radix-tree/test.h       |   9 +
 43 files changed, 1373 insertions(+), 512 deletions(-)


------8<------
