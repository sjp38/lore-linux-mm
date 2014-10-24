Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1D96B0082
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 18:06:46 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so2179941pde.14
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 15:06:45 -0700 (PDT)
Received: from homiemail-a38.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id xg3si5071831pab.211.2014.10.24.15.06.44
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 15:06:44 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 00/10] mm: improve usage of the i_mmap lock
Date: Fri, 24 Oct 2014 15:06:10 -0700
Message-Id: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>

Hello,

This series is a continuation of the conversion of the 
i_mmap_mutex to rwsem, following what we have for the
anon memory counterpart. With Hugh's feedback from the
first iteration (sorry about leaving this fall behind for
so long, but I've just finally had time to re-look at this
-- see https://lkml.org/lkml/2014/5/22/797), several
additional opportunities for sharing the lock are proposed.

Ultimately, the most obvious paths that require exclusive
ownership of the lock is when we modify the VMA interval
tree, via vma_interval_tree_insert() and vma_interval_tree_remove()
families. Cases such as unmapping, where the ptes content is
changed but the tree remains untouched should make it safe
to share the i_mmap_rwsem.

As such, the code of course is straightforward, however
the devil is very much in the details. While its been tested
on a number of workloads without anything exploding, I would
not be surprised if there are some less documented/known
assumptions about the lock that could suffer from these
changes. Or maybe I'm just missing something, but either way
I believe its at the point where it could use more eyes and
hopefully some time in linux-next.

Because the lock type conversion is the heart of this patchset,
its worth noting a few comparisons between mutex vs rwsem (xadd):

  (i) Same size, no extra footprint.

  (ii) Both have CONFIG_XXX_SPIN_ON_OWNER capabilities for
       exclusive lock ownership.

  (iii) Both can be slightly unfair wrt exclusive ownership, with
  	writer lock stealing properties, not necessarily respecting
	FIFO order for granting the lock when contended.

  (iv) Mutexes can be slightly faster than rwsems when
       the lock is non-contended.

  (v) Both suck at performance for debug (slowpaths), which
      shouldn't matter anyway.

Sharing the lock is obviously beneficial, and sem writer ownership
is close enough to mutexes. The biggest winner of these changes
is migration.

As for concrete numbers, the following performance results are
for a 4-socket 60-core IvyBridge-EX with 130Gb of RAM.

Both alltests and disk (xfs+ramdisk) workloads of aim7 suite do quite
well with this set, with a steady ~60% throughput (jpm) increase
for alltests and up to ~30% for disk for high amounts of concurrency.
Lower counts of workload users (< 100) does not show much difference
at all, so at least no regressions.

		    3.18-rc1		3.18-rc1-i_mmap_rwsem
alltests-100     17918.72 (  0.00%)    28417.97 ( 58.59%)
alltests-200     16529.39 (  0.00%)    26807.92 ( 62.18%)
alltests-300     16591.17 (  0.00%)    26878.08 ( 62.00%)
alltests-400     16490.37 (  0.00%)    26664.63 ( 61.70%)
alltests-500     16593.17 (  0.00%)    26433.72 ( 59.30%)
alltests-600     16508.56 (  0.00%)    26409.20 ( 59.97%)
alltests-700     16508.19 (  0.00%)    26298.58 ( 59.31%)
alltests-800     16437.58 (  0.00%)    26433.02 ( 60.81%)
alltests-900     16418.35 (  0.00%)    26241.61 ( 59.83%)
alltests-1000    16369.00 (  0.00%)    26195.76 ( 60.03%)
alltests-1100    16330.11 (  0.00%)    26133.46 ( 60.03%)
alltests-1200    16341.30 (  0.00%)    26084.03 ( 59.62%)
alltests-1300    16304.75 (  0.00%)    26024.74 ( 59.61%)
alltests-1400    16231.08 (  0.00%)    25952.35 ( 59.89%)
alltests-1500    16168.06 (  0.00%)    25850.58 ( 59.89%)
alltests-1600    16142.56 (  0.00%)    25767.42 ( 59.62%)
alltests-1700    16118.91 (  0.00%)    25689.58 ( 59.38%)
alltests-1800    16068.06 (  0.00%)    25599.71 ( 59.32%)
alltests-1900    16046.94 (  0.00%)    25525.92 ( 59.07%)
alltests-2000    16007.26 (  0.00%)    25513.07 ( 59.38%)

disk-100          7582.14 (  0.00%)     7257.48 ( -4.28%)
disk-200          6962.44 (  0.00%)     7109.15 (  2.11%)
disk-300          6435.93 (  0.00%)     6904.75 (  7.28%)
disk-400          6370.84 (  0.00%)     6861.26 (  7.70%)
disk-500          6353.42 (  0.00%)     6846.71 (  7.76%)
disk-600          6368.82 (  0.00%)     6806.75 (  6.88%)
disk-700          6331.37 (  0.00%)     6796.01 (  7.34%)
disk-800          6324.22 (  0.00%)     6788.00 (  7.33%)
disk-900          6253.52 (  0.00%)     6750.43 (  7.95%)
disk-1000         6242.53 (  0.00%)     6855.11 (  9.81%)
disk-1100         6234.75 (  0.00%)     6858.47 ( 10.00%)
disk-1200         6312.76 (  0.00%)     6845.13 (  8.43%)
disk-1300         6309.95 (  0.00%)     6834.51 (  8.31%)
disk-1400         6171.76 (  0.00%)     6787.09 (  9.97%)
disk-1500         6139.81 (  0.00%)     6761.09 ( 10.12%)
disk-1600         4807.12 (  0.00%)     6725.33 ( 39.90%)
disk-1700         4669.50 (  0.00%)     5985.38 ( 28.18%)
disk-1800         4663.51 (  0.00%)     5972.99 ( 28.08%)
disk-1900         4674.31 (  0.00%)     5949.94 ( 27.29%)
disk-2000         4668.36 (  0.00%)     5834.93 ( 24.99%)

In addition, a 67.5% increase in successfully migrated NUMA pages,
thus improving node locality.

The patch layout is simple but designed for bisection (in case
reversion is needed if the changes break upstream) and easier
review:

o Patches 1-4 convert the i_mmap lock from mutex to rwsem.
o Patches 5-10 share the lock in specific paths, each patch
  details the rationale behind why it should be safe.

This patchset has been tested with: postgres 9.4 (with brand new
hugetlb support), hugetlbfs test suite (all tests pass, in fact more
tests pass with these changes than with an upstream kernel), ltp, aim7
benchmarks, memcached and iozone with the -B option for mmap'ing.
*Untested* paths are nommu, memory-failure, uprobes and xip.

Applies on top of Linus' latest (3.18-rc1+c3351dfabf5c).

Thanks!

Davidlohr Bueso (10):
  mm,fs: introduce helpers around the i_mmap_mutex
  mm: use new helper functions around the i_mmap_mutex
  mm: convert i_mmap_mutex to rwsem
  mm/rmap: share the i_mmap_rwsem
  uprobes: share the i_mmap_rwsem
  mm/xip: share the i_mmap_rwsem
  mm/memory-failure: share the i_mmap_rwsem
  mm/mremap: share the i_mmap_rwsem
  mm/nommu: share the i_mmap_rwsem
  mm/hugetlb: share the i_mmap_rwsem

 fs/hugetlbfs/inode.c         | 14 +++++++-------
 fs/inode.c                   |  2 +-
 include/linux/fs.h           | 23 ++++++++++++++++++++++-
 include/linux/mmu_notifier.h |  2 +-
 kernel/events/uprobes.c      |  6 +++---
 kernel/fork.c                |  4 ++--
 mm/filemap.c                 | 10 +++++-----
 mm/filemap_xip.c             | 23 +++++++++--------------
 mm/fremap.c                  |  4 ++--
 mm/hugetlb.c                 | 22 +++++++++++-----------
 mm/memory-failure.c          |  4 ++--
 mm/memory.c                  |  8 ++++----
 mm/mmap.c                    | 22 +++++++++++-----------
 mm/mremap.c                  |  6 +++---
 mm/nommu.c                   | 17 ++++++++---------
 mm/rmap.c                    | 12 ++++++------
 16 files changed, 97 insertions(+), 82 deletions(-)

--
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
