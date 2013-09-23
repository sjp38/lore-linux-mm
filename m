Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 05B3E6B0068
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:45 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so3110668pbb.20
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything but mmap()
Date: Mon, 23 Sep 2013 15:05:28 +0300
Message-Id: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It brings thp support for ramfs, but without mmap() -- it will be posted
separately.

Please review and consider applying.

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
(512 on x86-64) entries. All entries points to head page -- refcounting for
tail pages is pretty expensive.

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

To minimize memory overhead for small files we aviod write-allocation in
first huge page area (2M on x86-64) of the file.

truncate_inode_pages_range() drops whole huge page at once if it's fully
inside the range. If a huge page is only partly in the range we zero out
the part, exactly like we do for partial small pages.

split_huge_page() for file pages works similar to anon pages, but we
walk by mapping->i_mmap rather then anon_vma->rb_root. At the end we call
truncate_inode_pages() to drop small pages beyond i_size, if any.

inode->i_split_sem taken on read will protect hugepages in inode's pagecache
against splitting. We take it on write during splitting.

Changes since v5
----------------
 - change how hugepage stored in pagecache: head page for all relevant
   indexes;
 - introduce i_split_sem;
 - do not create huge pages on write(2) into first hugepage area;
 - compile-disabled by default;
 - fix transparent_hugepage_pagecache();

Benchmarks
----------

Since the patchset doesn't include mmap() support, we should expect much
change in performance. We just need to check that we don't introduce any
major regression.

On average read/write on ramfs with thp is a bit slower, but I don't think
it's a stopper -- ramfs is a toy anyway, on real world filesystems I
expect difference to be smaller.

postmark
========

workload1:
chmod +x postmark
mount -t ramfs none /mnt
cat >/root/workload1 <<EOF
set transactions 250000
set size 5120 524288
set number 500
run
quit

workload2:
set transactions 10000
set size 2097152 10485760
set number 100
run
quit

throughput (transactions/sec)
                workload1       workload2
baseline        8333            416
patched         8333            454

FS-Mark
=======

throughput (files/sec)

                2000 files by 1M        200 files by 10M
baseline        5326.1                  548.1
patched         5192.8                  528.4

tiobench
========

baseline:
Tiotest results for 16 concurrent io threads:
,----------------------------------------------------------------------.
| Item                  | Time     | Rate         | Usr CPU  | Sys CPU |
+-----------------------+----------+--------------+----------+---------+
| Write        2048 MBs |    0.2 s | 8667.792 MB/s | 445.2 %  | 5535.9 % |
| Random Write   62 MBs |    0.0 s | 8341.118 MB/s |   0.0 %  | 2615.8 % |
| Read         2048 MBs |    0.2 s | 11680.431 MB/s | 339.9 %  | 5470.6 % |
| Random Read    62 MBs |    0.0 s | 9451.081 MB/s | 786.3 %  | 1451.7 % |
`----------------------------------------------------------------------'
Tiotest latency results:
,-------------------------------------------------------------------------.
| Item         | Average latency | Maximum latency | % >2 sec | % >10 sec |
+--------------+-----------------+-----------------+----------+-----------+
| Write        |        0.006 ms |       28.019 ms |  0.00000 |   0.00000 |
| Random Write |        0.002 ms |        5.574 ms |  0.00000 |   0.00000 |
| Read         |        0.005 ms |       28.018 ms |  0.00000 |   0.00000 |
| Random Read  |        0.002 ms |        4.852 ms |  0.00000 |   0.00000 |
|--------------+-----------------+-----------------+----------+-----------|
| Total        |        0.005 ms |       28.019 ms |  0.00000 |   0.00000 |
`--------------+-----------------+-----------------+----------+-----------'

patched:
Tiotest results for 16 concurrent io threads:
,----------------------------------------------------------------------.
| Item                  | Time     | Rate         | Usr CPU  | Sys CPU |
+-----------------------+----------+--------------+----------+---------+
| Write        2048 MBs |    0.3 s | 7942.818 MB/s | 442.1 %  | 5533.6 % |
| Random Write   62 MBs |    0.0 s | 9425.426 MB/s | 723.9 %  | 965.2 % |
| Read         2048 MBs |    0.2 s | 11998.008 MB/s | 374.9 %  | 5485.8 % |
| Random Read    62 MBs |    0.0 s | 9823.955 MB/s | 251.5 %  | 2011.9 % |
`----------------------------------------------------------------------'
Tiotest latency results:
,-------------------------------------------------------------------------.
| Item         | Average latency | Maximum latency | % >2 sec | % >10 sec |
+--------------+-----------------+-----------------+----------+-----------+
| Write        |        0.007 ms |       28.020 ms |  0.00000 |   0.00000 |
| Random Write |        0.001 ms |        0.022 ms |  0.00000 |   0.00000 |
| Read         |        0.004 ms |       24.011 ms |  0.00000 |   0.00000 |
| Random Read  |        0.001 ms |        0.019 ms |  0.00000 |   0.00000 |
|--------------+-----------------+-----------------+----------+-----------|
| Total        |        0.005 ms |       28.020 ms |  0.00000 |   0.00000 |
`--------------+-----------------+-----------------+----------+-----------'

IOZone
======

Syscalls, not mmap.

** Initial writers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80
baseline:	    4741691    7986408    9149064    9898695    9868597    9629383    9469202   11605064    9507802   10641869   11360701   11040376
patched:	    4682864    7275535    8691034    8872887    8712492    8771912    8397216    7701346    7366853    8839736    8299893   10788439
speed-up(times):       0.99       0.91       0.95       0.90       0.88       0.91       0.89       0.66       0.77       0.83       0.73       0.98

** Rewriters **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80
baseline:	    5807891    9554869   12101083   13113533   12989751   14359910   16998236   16833861   24735659   17502634   17396706   20448655
patched:	    6161690    9981294   12285789   13428846   13610058   13669153   20060182   17328347   24109999   19247934   24225103   34686574
speed-up(times):       1.06       1.04       1.02       1.02       1.05       0.95       1.18       1.03       0.97       1.10       1.39       1.70

** Readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80
baseline:	    7978066   11825735   13808941   14049598   14765175   14422642   17322681   23209831   21386483   20060744   22032935   31166663
patched:	    7723293   11481500   13796383   14363808   14353966   14979865   17648225   18701258   29192810   23973723   22163317   23104638
speed-up(times):       0.97       0.97       1.00       1.02       0.97       1.04       1.02       0.81       1.37       1.20       1.01       0.74

** Re-readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80
baseline:	    7966269   11878323   14000782   14678206   14154235   14271991   15170829   20924052   27393344   19114990   12509316   18495597
patched:	    7719350   11410937   13710233   13232756   14040928   15895021   16279330   17256068   26023572   18364678   27834483   23288680
speed-up(times):       0.97       0.96       0.98       0.90       0.99       1.11       1.07       0.82       0.95       0.96       2.23       1.26

** Reverse readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80
baseline:	    6630795   10331013   12839501   13157433   12783323   13580283   15753068   15434572   21928982   17636994   14737489   19470679
patched:	    6502341    9887711   12639278   12979232   13212825   12928255   13961195   14695786   21370667   19873807   20902582   21892899
speed-up(times):       0.98       0.96       0.98       0.99       1.03       0.95       0.89       0.95       0.97       1.13       1.42       1.12

** Random_readers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80
baseline:	    5152935    9043813   11752615   11996078   12283579   12484039   14588004   15781507   23847538   15748906   13698335   27195847
patched:	    5009089    8438137   11266015   11631218   12093650   12779308   17768691   13640378   30468890   19269033   23444358   22775908
speed-up(times):       0.97       0.93       0.96       0.97       0.98       1.02       1.22       0.86       1.28       1.22       1.71       0.84

** Random_writers **
threads:	          1          2          4          8         10         20         30         40         50         60         70         80
baseline:	    3886268    7405345   10531192   10858984   10994693   12758450   10729531    9656825   10370144   13139452    4528331   12615812
patched:	    4335323    7916132   10978892   11423247   11790932   11424525   11798171   11413452   12230616   13075887   11165314   16925679
speed-up(times):       1.12       1.07       1.04       1.05       1.07       0.90       1.10       1.18       1.18       1.00       2.47       1.34

Kirill A. Shutemov (22):
  mm: implement zero_huge_user_segment and friends
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
  thp, mm: add event counters for huge page alloc on file write or read
  mm, vfs: introduce i_split_sem
  thp, mm: allocate huge pages in grab_cache_page_write_begin()
  thp, mm: naive support of thp in generic_perform_write
  thp, mm: handle transhuge pages in do_generic_file_read()
  thp, libfs: initial thp support
  truncate: support huge pages
  thp: handle file pages in split_huge_page()
  thp: wait_split_huge_page(): serialize over i_mmap_mutex too
  thp, mm: split huge page on mmap file page
  ramfs: enable transparent huge page cache

 Documentation/vm/transhuge.txt |  16 ++++
 drivers/base/node.c            |   4 +
 fs/inode.c                     |   3 +
 fs/libfs.c                     |  58 +++++++++++-
 fs/proc/meminfo.c              |   3 +
 fs/ramfs/file-mmu.c            |   2 +-
 fs/ramfs/inode.c               |   6 +-
 include/linux/backing-dev.h    |  10 +++
 include/linux/fs.h             |  11 +++
 include/linux/huge_mm.h        |  68 +++++++++++++-
 include/linux/mm.h             |  18 ++++
 include/linux/mmzone.h         |   1 +
 include/linux/page-flags.h     |  13 +++
 include/linux/pagemap.h        |  31 +++++++
 include/linux/radix-tree.h     |  11 +++
 include/linux/vm_event_item.h  |   4 +
 include/trace/events/filemap.h |   7 +-
 lib/radix-tree.c               |  94 ++++++++++++++++++--
 mm/Kconfig                     |  11 +++
 mm/filemap.c                   | 196 ++++++++++++++++++++++++++++++++---------
 mm/huge_memory.c               | 147 +++++++++++++++++++++++++++----
 mm/memcontrol.c                |   3 +-
 mm/memory.c                    |  40 ++++++++-
 mm/truncate.c                  | 125 ++++++++++++++++++++------
 mm/vmstat.c                    |   5 ++
 25 files changed, 779 insertions(+), 108 deletions(-)

-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
