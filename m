Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 976266B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:53:47 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f3-v6so699787plf.1
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 01:53:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l185si925211pgd.108.2018.03.20.01.53.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 01:53:46 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH v2 0/4] Eliminate zone->lock contention for will-it-scale/page_fault1 and parallel free
Date: Tue, 20 Mar 2018 16:54:48 +0800
Message-Id: <20180320085452.24641-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

This series is meant to improve zone->lock scalability for order 0 pages.
With will-it-scale/page_fault1 workload, on a 2 sockets Intel Skylake
server with 112 CPUs, CPU spend 80% of its time spinning on zone->lock.
Perf profile shows the most time consuming part under zone->lock is the
cache miss on "struct page", so here I'm trying to avoid those cache
misses.

Patch 1/4 adds some wrapper functions for page to be added/removed
into/from buddy and doesn't have functionality changes.

Patch 2/4 skip doing merge for order 0 pages to avoid cache misses on
buddy's "struct page". On a 2 sockets Intel Skylake, this has very good
effect on free path for will-it-scale/page_fault1 full load in that it
reduced zone->lock contention on free path from 35% to 1.1%. Also, it
shows good result on parallel free(*) workload by reducing zone->lock
contention from 90% to almost zero(lru lock increased from almost 0 to
90% though).

Patch 3/4 deals with allocation path zone->lock contention by not
touching pages on free_list one by one inside zone->lock. Together with
patch 2/4, zone->lock contention is entirely eliminated for
will-it-scale/page_fault1 full load, though this patch adds some
overhead to manage cluster on free path and it has some bad effects on
parallel free workload in that it increased zone->lock contention from
almost 0 to 25%.

Patch 4/4 is an optimization in free path due to cluster operation. It
decreased the number of times add_to_cluster() has to be called and
restored performance for parallel free workload by reducing zone->lock's
contention to almost 0% again.

The good thing about this patchset is, it eliminated zone->lock
contention for will-it-scale/page_fault1 and parallel free on big
servers(contention shifted to lru_lock). The bad thing are:
 - it added some overhead in compaction path where it will do merging
   for those merge-skipped order 0 pages;
 - it is unfriendly to high order page allocation since we do not do
   merging for order 0 pages now.

To see how much effect it has on compaction, mmtests/stress-highalloc is
used on a Desktop machine with 8 CPUs and 4G memory.
(mmtests/stress-highalloc: make N copies of kernel tree and start
building them to consume almost all memory with reclaimable file page
cache. These file page cache will not be returned to buddy so effectively
makes it a worst case for high order page workload. Then after 5 minutes,
start allocating X order-9 pages to see how well compaction works).

With a delay of 100ms between allocations:
kernel   success_rate  average_time_of_alloc_one_hugepage
base           58%       3.95927e+06 ns
patch2/4       58%       5.45935e+06 ns
patch4/4       57%       6.59174e+06 ns

With a delay of 1ms between allocations:
kernel   success_rate  average_time_of_alloc_one_hugepage
base           53%       3.17362e+06 ns
patch2/4       44%       2.31637e+06 ns
patch4/4       59%       2.73029e+06 ns

If we compare patch4/4's result with base, it performed OK I think.
This is probably due to compaction is a heavy job so the added overhead
doesn't affect much.

To see how much effect it has on workload that uses hugepage, I did the
following test on a 2 sockets Intel Skylake with 112 CPUs/64G memory:
1 Break all high order pages by starting a program that consumes almost
  all memory with anonymous pages and then exit. This is used to create
  an extreme bad case for this patchset compared to vanilla that always
  does merging;
2 Start 56 processes of will-it-scale/page_fault1 that use hugepages
  through calling madvise(MADV_HUGEPAGE). To make things worse for this
  patchset, start another 56 processes of will-it-scale/page_fault1 that
  uses order 0 pages to continually cause trouble for the 56 THP users.
  Let them run for 5 minutes.

Score result(higher is better):

kernel      order0           THP
base        1522246        10540254
patch2/4    5266247 +246%   3309816 -69%
patch4/4    2234073 +47%    9610295 -8.8%

TBH, I'm not sure if the way I tried above is good enough to expose the
problem of this patchset. So if you have any thoughts on this patchset,
please feel free to let me know, thanks.

(*) Parallel free is a workload that I used to see how well parallel
freeing a large VMA can be. I tested this on a 4 sockets Intel Skylake
machine with 768G memory. The test program starts by doing a 512G anon
memory allocation with mmap() and then exit to see how fast it can exit.
The parallel is implemented inside kernel and has been posted before:
http://lkml.kernel.org/r/1489568404-7817-1-git-send-email-aaron.lu@intel.com

A branch is maintained here in case someone wants to give it a try:
https://github.com/aaronlu/linux zone_lock_rfc_v2

v2:
Rewrote allocation path optimization, compaction could happen now and no
crashes that I'm aware of.

v1 is here:
https://lkml.kernel.org/r/20180205053013.GB16980@intel.com

Aaron Lu (4):
  mm/page_alloc: use helper functions to add/remove a page to/from buddy
  mm/__free_one_page: skip merge for order-0 page unless compaction
    failed
  mm/rmqueue_bulk: alloc without touching individual page structure
  mm/free_pcppages_bulk: reduce overhead of cluster operation on free
    path

 Documentation/vm/struct_page_field |  10 +
 include/linux/mm_types.h           |   3 +
 include/linux/mmzone.h             |  35 +++
 mm/compaction.c                    |  17 +-
 mm/internal.h                      |  61 +++++
 mm/page_alloc.c                    | 488 +++++++++++++++++++++++++++++++++----
 6 files changed, 563 insertions(+), 51 deletions(-)
 create mode 100644 Documentation/vm/struct_page_field

-- 
2.14.3
