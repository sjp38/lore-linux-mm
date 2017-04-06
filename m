Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D017D6B03E5
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 01:35:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j70so25717814pge.11
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 22:35:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d76si681437pfe.306.2017.04.05.22.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 22:35:47 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v8 0/3] THP swap: Delay splitting THP during swapping out
Date: Thu,  6 Apr 2017 13:35:12 +0800
Message-Id: <20170406053515.4842-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

From: Huang Ying <ying.huang@intel.com>

This patchset is to optimize the performance of Transparent Huge Page
(THP) swap.

Hi, Andrew, could you help me to check whether the overall design is
reasonable?

Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
swap part of the patchset?

Hi, Andrea could you help me to review the THP part of the patchset?

Hi, Johannes, Michal, I am not very confident about the memory cgroup
part.  Could you help me to review it?

And for all, Any comment is welcome!


Recently, the performance of the storage devices improved so fast that
we cannot saturate the disk bandwidth with single logical CPU when do
page swap out even on a high-end server machine.  Because the
performance of the storage device improved faster than that of single
logical CPU.  And it seems that the trend will not change in the near
future.  On the other hand, the THP becomes more and more popular
because of increased memory size.  So it becomes necessary to optimize
THP swap performance.

The advantages of the THP swap support include:

- Batch the swap operations for the THP to reduce lock
  acquiring/releasing, including allocating/freeing the swap space,
  adding/deleting to/from the swap cache, and writing/reading the swap
  space, etc.  This will help improve the performance of the THP swap.

- The THP swap space read/write will be 2M sequential IO.  It is
  particularly helpful for the swap read, which are usually 4k random
  IO.  This will improve the performance of the THP swap too.

- It will help the memory fragmentation, especially when the THP is
  heavily used by the applications.  The 2M continuous pages will be
  free up after THP swapping out.

- It will improve the THP utilization on the system with the swap
  turned on.  Because the speed for khugepaged to collapse the normal
  pages into the THP is quite slow.  After the THP is split during the
  swapping out, it will take quite long time for the normal pages to
  collapse back into the THP after being swapped in.  The high THP
  utilization helps the efficiency of the page based memory management
  too.

There are some concerns regarding THP swap in, mainly because possible
enlarged read/write IO size (for swap in/out) may put more overhead on
the storage device.  To deal with that, the THP swap in should be
turned on only when necessary.  For example, it can be selected via
"always/never/madvise" logic, to be turned on globally, turned off
globally, or turned on only for VMA with MADV_HUGEPAGE, etc.

This patchset is based on 04/04 head of mmotm/master.

This patchset is the first step for the THP swap support.  The plan is
to delay splitting THP step by step, finally avoid splitting THP
during the THP swapping out and swap out/in the THP as a whole.

As the first step, in this patchset, the splitting huge page is
delayed from almost the first step of swapping out to after allocating
the swap space for the THP and adding the THP into the swap cache.
This will reduce lock acquiring/releasing for the locks used for the
swap cache management.

With the patchset, the swap out throughput improves 14.9% (from about
3.77GB/s to about 4.34GB/s) in the vm-scalability swap-w-seq test case
with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
device used is a RAM simulated PMEM (persistent memory) device.  To
test the sequential swapping out, the test case creates 8 processes,
which sequentially allocate and write to the anonymous pages until the
RAM and part of the swap device is used up.

The detailed comparison result is as follow,

base             base+patchset
---------------- -------------------------- 
         %stddev     %change         %stddev
             \          |                \  
   7043990 A+-  0%     +21.2%    8536807 A+-  0%  vm-scalability.throughput
    109.94 A+-  1%     -16.2%      92.09 A+-  0%  vm-scalability.time.elapsed_time
   3957091 A+-  0%     +14.9%    4547173 A+-  0%  vmstat.swap.so
     31.46 A+-  1%     -38.3%      19.42 A+-  0%  perf-stat.cache-miss-rate%
      1.04 A+-  1%     +22.2%       1.27 A+-  0%  perf-stat.ipc
      9.33 A+-  2%     -60.7%       3.67 A+-  1%  perf-profile.calltrace.cycles-pp.add_to_swap.shrink_page_list.shrink_inactive_list.shrink_node_memcg.shrink_node

Changelog:

v8:

- Rebased on latest -mm tree
- Reorganize the patchset per Johannes' comments
- Merge add_to_swap_trans_huge() and add_to_swap() per Johannes' comments

v7:

- Rebased on latest -mm tree
- Revise get_swap_pages() THP support per Tim's comments

v6:

- Rebased on latest -mm tree (cluster lock, etc).
- Fix a potential uninitialized variable bug in __swap_entry_free()
- Revise the swap read-ahead changes to avoid a potential race
  condition between swap off and swap out in theory.

v5:

- Per Hillf's comments, fix a locking bug in error path of
  __add_to_swap_cache().  And merge the code to calculate extra_pins
  into can_split_huge_page().

v4:

- Per Johannes' comments, simplified swap cgroup array accessing code.
- Per Kirill and Dave Hansen's comments, used HPAGE_PMD_NR instead of
  HPAGE_SIZE/PAGE_SIZE.
- Per Anshuman's comments, used HPAGE_PMD_NR instead of 512 in patch
  description.

v3:

- Per Andrew's suggestion, used a more systematical way to determine
  whether to enable THP swap optimization
- Per Andrew's comments, moved as much as possible code into
  #ifdef CONFIG_TRANSPARENT_HUGE_PAGE/#endif or "if (PageTransHuge())"
- Fixed some coding style warning.

v2:

- Original [1/11] sent separately and merged
- Use switch in 10/10 per Hiff's suggestion

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
