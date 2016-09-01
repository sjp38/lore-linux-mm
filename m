Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 538156B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 11:18:08 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id h3so61972521ybi.1
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 08:18:08 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n4si6083386pan.58.2016.09.01.08.18.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 08:18:07 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v2 00/10] THP swap: Delay splitting THP during swapping out
Date: Thu,  1 Sep 2016 08:16:53 -0700
Message-Id: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

From: Huang Ying <ying.huang@intel.com>

This patchset is to optimize the performance of Transparent Huge Page
(THP) swap.

Hi, Andrew, could you help me to check whether the overall design is
reasonable?

Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
swap part of the patchset?  Especially [01/10], [04/10], [05/10],
[06/10], [07/10], [10/10].

Hi, Andrea and Kirill, could you help me to review the THP part of the
patchset?  Especially [02/10], [03/10], [09/10] and [10/10].

Hi, Johannes, Michal and Vladimir, I am not very confident about the
memory cgroup part, especially [02/10] and [03/10].  Could you help me
to review it?

And for all, Any comment is welcome!


Recently, the performance of the storage devices improved so fast that
we cannot saturate the disk bandwidth when do page swap out even on a
high-end server machine.  Because the performance of the storage
device improved faster than that of CPU.  And it seems that the trend
will not change in the near future.  On the other hand, the THP
becomes more and more popular because of increased memory size.  So it
becomes necessary to optimize THP swap performance.

The advantages of the THP swap support include:

- Batch the swap operations for the THP to reduce lock
  acquiring/releasing, including allocating/freeing the swap space,
  adding/deleting to/from the swap cache, and writing/reading the swap
  space, etc.  This will help improve the performance of the THP swap.

- The THP swap space read/write will be 2M sequential IO.  It is
  particularly helpful for the swap read, which usually are 4k random
  IO.  This will improve the performance of the THP swap too.

- It will help the memory fragmentation, especially when the THP is
  heavily used by the applications.  The 2M continuous pages will be
  free up after THP swapping out.


This patchset is based on 8/25 head of mmotm/master.

This patchset is the first step for the THP swap support.  The plan is
to delay splitting THP step by step, finally avoid splitting THP
during the THP swapping out and swap out/in the THP as a whole.

As the first step, in this patchset, the splitting huge page is
delayed from almost the first step of swapping out to after allocating
the swap space for the THP and adding the THP into the swap cache.
This will reduce lock acquiring/releasing for the locks used for the
swap cache management.

With the patchset, the swap out throughput improves 12.1% (from about
1.12GB/s to about 1.25GB/s) in the vm-scalability swap-w-seq test case
with 16 processes.  The test is done on a Xeon E5 v3 system.  The swap
device used is a RAM simulated PMEM (persistent memory) device.  To
test the sequential swapping out, the test case uses 16 processes,
which sequentially allocate and write to the anonymous pages until the
RAM and part of the swap device is used up.

The detailed compare result is as follow,

base             base+patchset
---------------- -------------------------- 
         %stddev     %change         %stddev
             \          |                \  
   1118821 A+-  0%     +12.1%    1254241 A+-  1%  vmstat.swap.so
   2460636 A+-  1%     +10.6%    2720983 A+-  1%  vm-scalability.throughput
    308.79 A+-  1%      -7.9%     284.53 A+-  1%  vm-scalability.time.elapsed_time
      1639 A+-  4%    +232.3%       5446 A+-  1%  meminfo.SwapCached
      0.70 A+-  3%      +8.7%       0.77 A+-  5%  perf-stat.ipc
      9.82 A+-  8%     -31.6%       6.72 A+-  2%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list


>From the swap out throughput number, we can find, even tested on a RAM
simulated PMEM (Persistent Memory) device, the swap out throughput can
reach only about 1.1GB/s.  While, in the file IO test, the sequential
write throughput of an Intel P3700 SSD can reach about 1.8GB/s
steadily.  And according the following URL,

https://www-ssl.intel.com/content/www/us/en/solid-state-drives/intel-ssd-dc-family-for-pcie.html

The sequential write throughput of Intel P3608 SSD can reach about
3.0GB/s, while the random read IOPS can reach about 850k.  It is clear
that the bottleneck has moved from the disk to the kernel swap
component itself.

The improved storage device performance should have made the swap
becomes a better feature than before with better performance.  But
because of the issues of kernel swap component itself, the swap
performance is still kept at the low level.  That prevents the swap
feature to be used by more users.  And this in turn causes few kernel
developers think it is necessary to optimize kernel swap component.
To break the loop, we need to optimize the performance of kernel swap
component.  Optimize the THP swap performance is part of it.


Changelog:

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
