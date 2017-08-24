Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54420440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:48:45 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id r199so348962vke.6
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:48:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e1si2166366vkf.205.2017.08.24.13.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 13:48:44 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 0/7] ktask: multithread cpu-intensive kernel work
Date: Thu, 24 Aug 2017 16:49:57 -0400
Message-Id: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

ktask is a generic framework for parallelizing cpu-intensive work in the
kernel.  The intended use is for big machines that can use their cpu power
to speed up large tasks that can't otherwise be multithreaded in userland.
The API is generic enough to add concurrency to many different kinds of
tasks--for example, zeroing a range of pages or evicting a list of
inodes--and aims to save its clients the trouble of splitting up the work,
choosing the number of threads to use, starting these threads, and load
balancing the work between them.

Why do we need ktask when the kernel has other APIs for managing
concurrency?  After all, kthread_workers and workqueues already provide ways
to start threads, and the kernel can handle large tasks with a single thread
by periodically yielding the cpu with cond_resched or doing the work in
fixed size batches.

Of the existing concurrency facilities, kthread_worker isn't suited for
providing parallelism because each comes with only a single thread.
Workqueues are a better fit for this, and in fact ktask is built on an
unbound workqueue, but workqueues aren't designed for splitting up a large
task.  ktask instead uses unbound workqueue threads to run "chunks" of a
task.

More background is available in the documentation commit (first commit of the
series).

This patchset is based on 4.13-rc6 and contains three ktask users so far, with
more to come:
 - clearing gigantic pages
 - fallocate for HugeTLB pages
 - deferred struct page initialization at boot time

The core ktask code is based on work by Pavel Tatashin, Steve Sistare, and
Jonathan Adams.

v1 -> v2:
 - Added deferred struct page initialization use case.
 - Explained the source of the performance improvement from parallelizing
   clear_gigantic_page (comment from Dave Hansen).
 - Fixed Documentation and build warnings from CONFIG_KTASK=n kernels.

link to v1: https://lkml.org/lkml/2017/7/14/666

Daniel Jordan (7):
  ktask: add documentation
  ktask: multithread cpu-intensive kernel work
  ktask: add /proc/sys/debug/ktask_max_threads
  mm: enlarge type of offset argument in mem_map_offset and mem_map_next
  mm: parallelize clear_gigantic_page
  hugetlbfs: parallelize hugetlbfs_fallocate with ktask
  mm: parallelize deferred struct page initialization within each node

 Documentation/core-api/index.rst |   1 +
 Documentation/core-api/ktask.rst | 104 ++++++++++
 fs/hugetlbfs/inode.c             | 117 +++++++++---
 include/linux/ktask.h            | 235 +++++++++++++++++++++++
 include/linux/ktask_internal.h   |  19 ++
 include/linux/mm.h               |   6 +
 init/Kconfig                     |   7 +
 init/main.c                      |   2 +
 kernel/Makefile                  |   2 +-
 kernel/ktask.c                   | 396 +++++++++++++++++++++++++++++++++++++++
 kernel/sysctl.c                  |  10 +
 mm/internal.h                    |   7 +-
 mm/memory.c                      |  35 +++-
 mm/page_alloc.c                  | 174 ++++++++++-------
 14 files changed, 1014 insertions(+), 101 deletions(-)
 create mode 100644 Documentation/core-api/ktask.rst
 create mode 100644 include/linux/ktask.h
 create mode 100644 include/linux/ktask_internal.h
 create mode 100644 kernel/ktask.c

-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
