Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 29A0B6B005A
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:34 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 00/23] Transparent huge page cache: phase 1, everything but mmap()
Date: Sun,  4 Aug 2013 05:17:02 +0300
Message-Id: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is the second part of my transparent huge page cache work.
It brings thp support for ramfs, but without mmap() -- it will be posted
separately.

Intro
-----

The goal of the project is preparing kernel infrastructure to handle huge
pages in page cache.

To proof that the proposed changes are functional we enable the feature
for the most simple file system -- ramfs. ramfs is not that useful by
itself, but it's good pilot project.

Design overview
---------------

Every huge page is represented in page cache radix-tree by HPAGE_PMD_NR
(512 on x86-64) entries: one entry for head page and HPAGE_PMD_NR-1 entries
for tail pages.

Radix tree manipulations are implemented in batched way: we add and remove
whole huge page at once, under one tree_lock. To make it possible, we
extended radix-tree interface to be able to pre-allocate memory enough to
insert a number of *contiguous* elements (kudos to Matthew Wilcox).

Huge pages can be added to page cache three ways:
 - write(2) to file or page;
 - read(2) from sparse file;
 - fault sparse file.

Potentially, one more way is collapsing small page, but it's outside initial
implementation.

For now we still write/read at most PAGE_CACHE_SIZE bytes a time. There's
some room for speed up later.

Since mmap() isn't targeted for this patchset, we just split huge page on
page fault.

To minimize memory overhead for small file we setup fops->release helper
-- simple_thp_release() --  which splits the last page in file, when last
writer goes away.

truncate_inode_pages_range() drops whole huge page at once if it's fully
inside the range. If a huge page is only partly in the range we zero out
the part, exactly like we do for partial small pages.

split_huge_page() for file pages works similar to anon pages, but we
walk by mapping->i_mmap rather then anon_vma->rb_root. At the end we call
truncate_inode_pages() to drop small pages beyond i_size, if any.

Locking model around split_huge_page() rather complicated and I still
don't feel myself confident enough with it. Looks like we need to
serialize over i_mutex in split_huge_page(), but it breaks locking
ordering for i_mutex->mmap_sem. I don't see how it can be fixed easily.
Any ideas are welcome.

Performance indicators will be posted separately.

Please, review.

Kirill A. Shutemov (23):
  radix-tree: implement preload for multiple contiguous elements
  memcg, thp: charge huge cache pages
  thp: compile-time and sysfs knob for thp pagecache
  thp, mm: introduce mapping_can_have_hugepages() predicate
  thp: represent file thp pages in meminfo and friends
  thp, mm: rewrite add_to_page_cache_locked() to support huge pages
  mm: trace filemap: dump page order
  block: implement add_bdi_stat()
  thp, mm: rewrite delete_from_page_cache() to support huge pages
  thp, mm: warn if we try to use replace_page_cache_page() with THP
  thp, mm: handle tail pages in page_cache_get_speculative()
  thp, mm: add event counters for huge page alloc on file write or read
  thp, mm: allocate huge pages in grab_cache_page_write_begin()
  thp, mm: naive support of thp in generic_perform_write
  mm, fs: avoid page allocation beyond i_size on read
  thp, mm: handle transhuge pages in do_generic_file_read()
  thp, libfs: initial thp support
  thp: libfs: introduce simple_thp_release()
  truncate: support huge pages
  thp: handle file pages in split_huge_page()
  thp: wait_split_huge_page(): serialize over i_mmap_mutex too
  thp, mm: split huge page on mmap file page
  ramfs: enable transparent huge page cache

 Documentation/vm/transhuge.txt |  16 ++++
 drivers/base/node.c            |   4 +
 fs/libfs.c                     |  80 ++++++++++++++++++-
 fs/proc/meminfo.c              |   3 +
 fs/ramfs/file-mmu.c            |   3 +-
 fs/ramfs/inode.c               |   6 +-
 include/linux/backing-dev.h    |  10 +++
 include/linux/fs.h             |  10 +++
 include/linux/huge_mm.h        |  53 ++++++++++++-
 include/linux/mmzone.h         |   1 +
 include/linux/page-flags.h     |  33 ++++++++
 include/linux/pagemap.h        |  48 +++++++++++-
 include/linux/radix-tree.h     |  11 +++
 include/linux/vm_event_item.h  |   4 +
 include/trace/events/filemap.h |   7 +-
 lib/radix-tree.c               |  41 +++++++---
 mm/Kconfig                     |  12 +++
 mm/filemap.c                   | 171 +++++++++++++++++++++++++++++++++++------
 mm/huge_memory.c               | 116 ++++++++++++++++++++++++----
 mm/memcontrol.c                |   2 -
 mm/memory.c                    |   4 +-
 mm/truncate.c                  | 108 ++++++++++++++++++++------
 mm/vmstat.c                    |   5 ++
 23 files changed, 658 insertions(+), 90 deletions(-)

-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
