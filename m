Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5F7D6B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 14:49:31 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id f9so1094906qtf.6
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 11:49:31 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 13si216146qtp.385.2017.12.05.11.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 11:49:30 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v3 0/7] ktask: multithread CPU-intensive kernel work
Date: Tue,  5 Dec 2017 14:52:13 -0500
Message-Id: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

What do people think of the overall design and direction?

There's documentation describing the design in the first patch of the
series and the second patch has the API in ktask.h.

         Thanks,
            Daniel


Changelog:

v2 -> v3:
 - Changed cpu to CPU in the ktask Documentation, as suggested by Randy Dunlap
 - Saved more boot time now that Pavel Tatashin's deferred struct page init
   patches are in mainline (https://lkml.org/lkml/2017/10/13/692).  New
   performance results in patch 7.
 - Added resource limits, per-node and system-wide, to maintain efficient
   concurrency levels (addresses a concern from my Plumbers talk)
 - ktask no longer allocates memory internally during a task so it can be used
   in sensitive contexts
 - Added the option to run work anywhere on the system rather than always
   confining it to a specific node
 - Updated Documentation patch with these changes and reworked motivation
   section

v1 -> v2:
 - Added deferred struct page initialization use case.
 - Explained the source of the performance improvement from parallelizing
   clear_gigantic_page (comment from Dave Hansen).
 - Fixed Documentation and build warnings from CONFIG_KTASK=n kernels.

My Linux Plumbers Unconference Talk:
  https://www.linuxplumbersconf.org/2017/ocw/proposals/4837
  (please ignore OpenID's misapprehension that James Bottomley was speaker)

ktask is a generic framework for parallelizing CPU-intensive work in the
kernel.  The intended use is for big machines that can use their CPU power
to speed up large tasks that can't otherwise be multithreaded in userland.
The API is generic enough to add concurrency to many different kinds of
tasks--for example, zeroing a range of pages or evicting a list of
inodes--and aims to save its clients the trouble of splitting up the work,
choosing the number of threads to use, starting these threads, and load
balancing the work between them.

This patchset is based on 4.15-rc2 plus one mmots fix[*] and contains three
ktask users:
 - deferred struct page initialization at boot time
 - clearing gigantic pages
 - fallocate for HugeTLB pages

Work in progress:
 - Parallelizing page freeing in the exit/munmap paths
 - CPU hotplug support

The core ktask code is based on work by Pavel Tatashin, Steve Sistare, and
Jonathan Adams.

ktask v1 RFC: https://lkml.org/lkml/2017/7/14/666
ktask v2 RFC: https://lkml.org/lkml/2017/8/24/801

[*] http://ozlabs.org/~akpm/mmots/broken-out/mm-split-deferred_init_range-into-initializing-and-freeing-parts.patch


Daniel Jordan (7):
  ktask: add documentation
  ktask: multithread CPU-intensive kernel work
  ktask: add /proc/sys/debug/ktask_max_threads
  mm: enlarge type of offset argument in mem_map_offset and mem_map_next
  mm: parallelize clear_gigantic_page
  hugetlbfs: parallelize hugetlbfs_fallocate with ktask
  mm: parallelize deferred struct page initialization within each node

 Documentation/core-api/index.rst |   1 +
 Documentation/core-api/ktask.rst | 173 ++++++++++++
 fs/hugetlbfs/inode.c             | 116 ++++++--
 include/linux/ktask.h            | 255 ++++++++++++++++++
 include/linux/ktask_internal.h   |  22 ++
 include/linux/mm.h               |   6 +
 init/Kconfig                     |  12 +
 init/main.c                      |   2 +
 kernel/Makefile                  |   2 +-
 kernel/ktask.c                   | 556 +++++++++++++++++++++++++++++++++++++++
 kernel/sysctl.c                  |  10 +
 mm/internal.h                    |   7 +-
 mm/memory.c                      |  35 ++-
 mm/page_alloc.c                  |  78 ++++--
 14 files changed, 1226 insertions(+), 49 deletions(-)
 create mode 100644 Documentation/core-api/ktask.rst
 create mode 100644 include/linux/ktask.h
 create mode 100644 include/linux/ktask_internal.h
 create mode 100644 kernel/ktask.c

-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
