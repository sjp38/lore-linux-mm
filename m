Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6B804405EF
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:06:08 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id g49so38654680qta.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:06:08 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id c83si5398546qkg.91.2017.02.17.07.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 07:06:07 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 00/14] Accelerating page migrations
Date: Fri, 17 Feb 2017 10:05:37 -0500
Message-Id: <20170217150551.117028-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dnellans@nvidia.com, apopple@au1.ibm.com, paulmck@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Zi Yan <zi.yan@cs.rutgers.edu>

Hi all,

I was asked to post my complete patcheset for comment, so this patchset includes
parallel page migration patches I sent before. It is rebased on
mmotm-2017-02-07-15-20.

This RFC is trying to accelerate huge page migrations, so it relies on
THP migration from Naoya (https://lwn.net/Articles/713667/). There are a lot of
rough edges in the code, but I want to get comments about how those ideas look
to you.

You can find kernel code with this patchset and THP migration patchset here:
https://github.com/x-y-z/linux-thp-migration/tree/page_migration_opt_linux-mm

General description:
=======================================================

There are four parts:
1. Parallel page migration (Patch 1-6). It uses multi-threaded process instead of
   existing single-threaded one to transfer huge pages, where each thread will
   transfer a part of a huge page. It makes better use of existing memory 
   bandwidth.

2. Concurrent page migration (Patch 7,8). Linux currently transfer a list of pages
   sequentially. This is good for error handling, but bad for utilizing 
   memory bandwidth. This part batches page migration. It first
   unmaps all pages, then copy all pages together, finally reinstates PTEs
   after data copy is done. Only anonymous page is supported.

3. Exchange page migration (Patch 9-11). This is trying to save new page allocations
   when two-way page migrations are performed between two memory nodes. 
   Instead of repeating new page allocation then page migraiton, it simply 
   exchange page content of two peer pages. Only anonymous page is supported.

4. DMA page migration (Patch 12-14). This is trying to free CPUs from data copy.
   It uses DMA engine in a system to copy page data instead of CPU threads.

Experiment results:
=======================================================

I did page migration micro-benchmark with the changes on a two-socket Intel
E5-2640v3 with DDR4 at 1866MHz and cross-socket BW 32.0GB/s. This machine also
has 16 channel IOAT DMA, which provides ~11GB/s data copy throughput.

1. Parallel page migration: it increases 2MB page migration throughput from
   3.0GB/s (1-thread) to 8.6GB/s (8-thread).
2. Concurrent page migration: it increases 16 2MB page migration throughput from
   3.3GB/s (1-thread) to 14.4GB/s (8-thread).
3. Exchange page migration: it increases 16 two-way 2MB page migration throughput
   from 3.3GB/s (1-thread) to 17.8GB/s (8-thread).
4. DMA page migration: it can saturate Intel DMA engine's 11GB/s data copy throughput.

The improvements (except for DMA) was also tested on a IBM Power8 and NVIDIA
ARM64 systems and the range of improvements in results is very similar.

Best Regards,
Yan Zi


Zi Yan (14):
  mm/migrate: Add new mode parameter to migrate_page_copy() function
  mm/migrate: Make migrate_mode types non-exclussive
  mm/migrate: Add copy_pages_mthread function
  mm/migrate: Add new migrate mode MIGRATE_MT
  mm/migrate: Add new migration flag MPOL_MF_MOVE_MT for syscalls
  sysctl: Add global tunable mt_page_copy
  migrate: Add copy_page_lists_mthread() function.
  mm: migrate: Add concurrent page migration into move_pages syscall.
  mm: migrate: Add exchange_page_mthread() and
    exchange_page_lists_mthread() to exchange two pages or two page
    lists.
  mm: Add exchange_pages and exchange_pages_concur functions to exchange
    two lists of pages instead of two migrate_pages().
  mm: migrate: Add exchange_pages syscall to exchange two page lists.
  migrate: Add copy_page_dma to use DMA Engine to copy pages.
  mm: migrate: Add copy_page_dma into migrate_page_copy.
  mm: Add copy_page_lists_dma_always to support copy a list of pages.

 arch/x86/entry/syscalls/syscall_64.tbl |    2 +
 fs/aio.c                               |    2 +-
 fs/f2fs/data.c                         |    2 +-
 fs/hugetlbfs/inode.c                   |    2 +-
 fs/ubifs/file.c                        |    2 +-
 include/linux/highmem.h                |    3 +
 include/linux/ksm.h                    |    5 +
 include/linux/migrate.h                |    6 +-
 include/linux/migrate_mode.h           |   10 +-
 include/linux/sched/sysctl.h           |    4 +
 include/linux/syscalls.h               |    5 +
 include/uapi/linux/mempolicy.h         |    6 +-
 kernel/sysctl.c                        |   32 +
 mm/Makefile                            |    3 +
 mm/compaction.c                        |   20 +-
 mm/copy_pages.c                        |  720 ++++++++++++++++++
 mm/exchange.c                          | 1257 ++++++++++++++++++++++++++++++++
 mm/internal.h                          |   11 +
 mm/ksm.c                               |   35 +
 mm/mempolicy.c                         |    7 +-
 mm/migrate.c                           |  573 ++++++++++++++-
 mm/shmem.c                             |    2 +-
 22 files changed, 2662 insertions(+), 47 deletions(-)
 create mode 100644 mm/copy_pages.c
 create mode 100644 mm/exchange.c

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
