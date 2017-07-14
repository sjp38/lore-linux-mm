Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9915440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 18:16:10 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f66so28613122iof.10
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 15:16:10 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v128si3383370ita.72.2017.07.14.15.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 15:16:09 -0700 (PDT)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 0/6] ktask: multithread cpu-intensive kernel work
Date: Fri, 14 Jul 2017 15:16:07 -0700
Message-Id: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

ktask is a generic framework for parallelizing cpu-intensive work in the
kernel.  The intended use is for big machines that can use their cpu power to
speed up large tasks that can't otherwise be multithreaded in userland.  The
API is generic enough to add concurrency to many different kinds of tasks--for
example, zeroing a range of pages or evicting a list of inodes--and aims to
save its clients the trouble of splitting up the work, choosing the number of
threads to use, starting these threads, and load balancing the work between
them.

Why do we need ktask when the kernel has other APIs for managing concurrency?
After all, kthread_workers and workqueues already provide ways to start
threads, and the kernel can handle large tasks with a single thread by
periodically yielding the cpu with cond_resched or doing the work in fixed size
batches.

Of the existing concurrency facilities, kthread_worker isn't suited for
providing parallelism because each comes with only a single thread.  Workqueues
are a better fit for this, and in fact ktask is built on an unbound workqueue,
but workqueues aren't designed for splitting up a large task.  ktask instead
uses unbound workqueue threads to run "chunks" of a task.

More background is available in the documentation commit (first commit of the
series).

There are two ktask consumers included, with more to come later.  Other
consumers that are in the works include:

  - Page table walking and/or mmu_gather struct page freeing to optimize exit(2)
    and munmap(2) for large processes.  This is inspired by Aaron Lu's work:
        http://marc.info/?l=linux-mm&m=148793643210514&w=2

  - struct page initialization in early boot (use more threads than the current
    pgdatinit threads to reduce boot time).

The core ktask code is based on work by Pavel Tatashin, Steve Sistare, and
Jonathan Adams.

This series is based on 4.12.

Daniel Jordan (6):
  ktask: add documentation
  ktask: multithread cpu-intensive kernel work
  ktask: add /proc/sys/debug/ktask_max_threads
  mm: enlarge type of offset argument in mem_map_offset and
    mem_map_next
  mm: parallelize clear_gigantic_page
  hugetlbfs: parallelize hugetlbfs_fallocate with ktask

 Documentation/core-api/index.rst |    1 +
 Documentation/core-api/ktask.rst |  104 ++++++++++
 fs/hugetlbfs/inode.c             |  122 ++++++++++---
 include/linux/ktask.h            |  228 ++++++++++++++++++++++
 include/linux/ktask_internal.h   |   19 ++
 include/linux/mm.h               |    5 +
 init/Kconfig                     |    7 +
 kernel/Makefile                  |    2 +-
 kernel/ktask.c                   |  389 ++++++++++++++++++++++++++++++++++++++
 kernel/sysctl.c                  |   10 +
 mm/internal.h                    |    7 +-
 mm/memory.c                      |   35 +++-
 12 files changed, 895 insertions(+), 34 deletions(-)
 create mode 100644 Documentation/core-api/ktask.rst
 create mode 100644 include/linux/ktask.h
 create mode 100644 include/linux/ktask_internal.h
 create mode 100644 kernel/ktask.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
