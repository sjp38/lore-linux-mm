Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB8826B0253
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:26:25 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id 41so12385830qtn.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:26:25 -0800 (PST)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id g87si16832327qkh.156.2016.11.22.08.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 08:26:25 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH 0/5] Parallel hugepage migration optimization
Date: Tue, 22 Nov 2016 11:25:25 -0500
Message-Id: <20161122162530.2370-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

Hi all,

This patchset boosts the hugepage migration throughput and helps THP migration
which is added by Naoya's patches: https://lwn.net/Articles/705879/.

Motivation
===============================

In x86, 4KB page migrations are underutilizing the memory bandwidth compared
to 2MB THP migrations. I did some page migration benchmarking on a two-socket
Intel Xeon E5-2640v3 box, which has 23.4GB/s bandwidth, and discover
there are big throughput gap, ~3x, between 4KB and 2MB page migrations.

Here are the throughput numbers for different page sizes and page numbers:
        | 512 4KB pages | 1 2MB THP  |  1 4KB page
x86_64  |  0.98GB/s     |  2.97GB/s  |   0.06GB/s

As Linux currently use single-threaded page migration, the throughput is still
much lower than the hardware bandwidth, 2.97GB/s vs 23.4GB/s. So I parallelize
the copy_page() part of THP migration with workqueue and achieve 2.8x throughput.

Here are the throughput numbers of 2MB page migration:
           |  single-threaded   | 8-thread
x86_64 2MB |    2.97GB/s        | 8.58GB/s

Here is the benchmark you can use to compare page migration time:
https://github.com/x-y-z/thp-migration-bench

As this patchset requires Naoya's patch, this repo has both patchset applied:
https://github.com/x-y-z/linux-thp-migration/tree/page_migration_opt_upstream


Patchset desciption
===============================

This patchset adds a new migrate_mode MIGRATE_MT, which leads to parallelized
page migration routine. Only copy_huge_page() will be parallelized. This
MIGRATE_MT is enabled by a sysctl knob, vm.accel_page_copy, or an additional
flag, MPOL_MF_MOVE_MT, to move_pages() system call.

The parallelized copy page routine distributes a single huge page into 4 
workqueue threads and wait until they finish.

Discussion
===============================
1. For testing purpose, I choose to use sysctl to enable and disable the
parallel huge page migration. I need comments on how to enable and disable it,
or just enable it for all huge page migrations.

2. The hard-coded "4" workqueue threads is not adaptive, any suggestion?
Like boot time benchmark to find an appropriate number?

3. The parallel huge page migration works best with threads allocated at 
different physical cores, not all in the same hyper-threaded core. Is there
any way to find out the core topology easily?


Any comments are welcome. Thanks.

--
Best Regards,
Zi Yan


Zi Yan (5):
  mm: migrate: Add mode parameter to support additional page copy
    routines.
  mm: migrate: Change migrate_mode to support combination migration
    modes.
  migrate: Add copy_page_mt to use multi-threaded page migration.
  mm: migrate: Add copy_page_mt into migrate_pages.
  mm: migrate: Add vm.accel_page_copy in sysfs to control whether to use
    multi-threaded to accelerate page copy.

 fs/aio.c                       |  2 +-
 fs/hugetlbfs/inode.c           |  2 +-
 fs/ubifs/file.c                |  2 +-
 include/linux/highmem.h        |  2 +
 include/linux/migrate.h        |  6 ++-
 include/linux/migrate_mode.h   |  7 +--
 include/uapi/linux/mempolicy.h |  2 +
 kernel/sysctl.c                | 12 ++++++
 mm/Makefile                    |  2 +
 mm/compaction.c                | 20 ++++-----
 mm/copy_page.c                 | 96 ++++++++++++++++++++++++++++++++++++++++++
 mm/migrate.c                   | 61 ++++++++++++++++++---------
 12 files changed, 175 insertions(+), 39 deletions(-)
 create mode 100644 mm/copy_page.c

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
