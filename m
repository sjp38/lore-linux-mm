Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F096D6B02A5
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:24:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x23so426513884pgx.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:24:28 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g22si30873881pli.174.2016.11.29.03.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:24:28 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 00/36] ext4: support of huge pages
Date: Tue, 29 Nov 2016 14:22:28 +0300
Message-Id: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's respin of my huge ext4 patchset on top of Matthew's patchset with
few changes and fixes (see below).

Please review and consider applying.

I don't see any xfstests regressions with huge pages enabled. Patch with
new configurations for xfstests-bld is below.

The basics are the same as with tmpfs[1] which is in Linus' tree now and
ext4 built on top of it. The main difference is that we need to handle
read out from and write-back to backing storage.

As with other THPs, the implementation is build around compound pages:
a naturally aligned collection of pages that memory management subsystem
[in most cases] treat as a single entity:

  - head page (the first subpage) on LRU represents whole huge page;
  - head page's flags represent state of whole huge page (with few
    exceptions);
  - mm can't migrate subpages of the compound page individually;

For THP, we use PMD-sized huge pages.

Head page links buffer heads for whole huge page. Dirty/writeback/etc.
tracking happens on per-hugepage level as all subpages share the same page
flags.

lock_page() on any subpage would lock whole hugepage for the same reason.

On radix-tree, a huge page represented as a multi-order entry of the same
order (HPAGE_PMD_ORDER). This allows us to track dirty/writeback on
radix-tree tags with the same granularity as on struct page.

On IO via syscalls, we are still limited by copying upto PAGE_SIZE per
iteration. The limitation here comes from how copy_page_to_iter() and
copy_page_from_iter() work wrt. highmem: it can only handle one small
page a time.

On write side, we also have problem with assuming small pages: write
length and offset within page calculated before we know if small or huge
page is allocated. It's not easy to fix. Looks like it would require
change in ->write_begin() interface to accept len > PAGE_SIZE.

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
if we want to have coherent view on tags. So the first patch converts
tmpfs to use multi-order entries in radix-tree. The same infrastructure
used for ext4.

Encryption doesn't handle huge pages yet. To avoid regressions we just
disable huge pages for the inode if it has EXT4_INODE_ENCRYPT.

Tested with 4k, 1k, encryption and bigalloc. All with and without
huge=always. I think it's reasonable coverage.

The patchset is also in git:

git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugeext4/v5

[1] http://lkml.kernel.org/r/1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com

Changes since v4:
  - Rebase onto updated radix-tree interface;
  - Change interface to page cache lookups wrt. multi-order entries;
  - Do not mess with BIO_MAX_PAGES: ext4_mpage_readpages() now uses
    block_read_full_page() for THP read out;
  - Fix work with memcg enabled;
  - Drop bogus VM_BUG_ON() from wp_huge_pmd();

Changes since v3:
  - account huge page to dirty/writeback/reclaimable/etc. according to its
    size. It fixes background writback.
  - move code that adds huge page to radix-tree to
    page_cache_tree_insert() (Jan);
  - make ramdisk work with huge pages;
  - fix unaccont of shadow entries (Jan);
  - use try_to_release_page() instead of try_to_free_buffers() in
    split_huge_page() (Jan);
  -  make thp_get_unmapped_area() respect S_HUGE_MODE;
  - use huge-page aligned address to zap page range in wp_huge_pmd();
  - use ext4_kvmalloc in ext4_mpage_readpages() instead of
    kmalloc() (Andreas);

Changes since v2:
  - fix intermittent crash in generic/299;
  - typo (condition inversion) in do_generic_file_read(),
    reported by Jitendra;

TODO:
  - on IO via syscalls, copy more than PAGE_SIZE per iteration to/from
    userspace;
  - readahead ?;
  - wire up madvise()/fadvise();
  - encryption with huge pages;
  - reclaim of file huge pages can be optimized -- split_huge_page() is not
    required for pages with backing storage;
