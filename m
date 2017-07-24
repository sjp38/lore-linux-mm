Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02A906B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:18:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v68so120425728pfi.13
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:18:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r85si5471938pfb.477.2017.07.23.22.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 22:18:48 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 00/12] mm, THP, swap: Delay splitting THP after swapped out
Date: Mon, 24 Jul 2017 13:18:28 +0800
Message-Id: <20170724051840.2309-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Ming Lei <ming.lei@redhat.com>, Huang Ying <ying.huang@intel.com>

From: Huang Ying <ying.huang@intel.com>

Hi, Andrew, could you help me to check whether the overall design is
reasonable?

Hi, Johannes and Minchan, Thanks a lot for your review to the first
step of the THP swap optimization!  Could you help me to review the
second step in this patchset?

Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
swap part of the patchset?  Especially [01/12], [02/12], [03/12],
[04/12], [11/12], and [12/12].

Hi, Andrea and Kirill, could you help me to review the THP part of the
patchset?  Especially [01/12], [03/12], [07/12], [08/12], [09/12],
[11/12].

Hi, Johannes, Michal, could you help me to review the cgroup part of
the patchset?  Especially [08/12], [09/12], and [10/12].

And for all, Any comment is welcome!

Because the THP swap writing support patch [06/12] needs to be rebased
on multipage bvec patchset which hasn't been merged yet.  The [06/12]
in this patchset is just a test patch and will be rewritten later.
The patchset depends on multipage bvec patchset too.

This is the second step of THP (Transparent Huge Page) swap
optimization.  In the first step, the splitting huge page is delayed
from almost the first step of swapping out to after allocating the
swap space for the THP and adding the THP into the swap cache.  In the
second step, the splitting is delayed further to after the swapping
out finished.  The plan is to delay splitting THP step by step,
finally avoid splitting THP for the THP swapping out and swap out/in
the THP as a whole.

In the patchset, more operations for the anonymous THP reclaiming,
such as TLB flushing, writing the THP to the swap device, removing the
THP from the swap cache are batched.  So that the performance of
anonymous THP swapping out are improved.

This patchset is based on the 7/14 head of mmotm/master.

During the development, the following scenarios/code paths have been
checked,

- swap out/in
- swap off
- write protect page fault
- madvise_free
- process exit
- split huge page

Please let me know if I missed something.

With the patchset, the swap out throughput improves 42% (from about
5.81GB/s to about 8.25GB/s) in the vm-scalability swap-w-seq test case
with 16 processes.  At the same time, the IPI (reflect TLB flushing)
reduced about 78.9%.  The test is done on a Xeon E5 v3 system.  The
swap device used is a RAM simulated PMEM (persistent memory) device.
To test the sequential swapping out, the test case creates 8
processes, which sequentially allocate and write to the anonymous
pages until the RAM and part of the swap device is used up.

Below is the part of the cover letter for the first step patchset of
THP swap optimization which applies to all steps.

----------------------------------------------------------------->

Recently, the performance of the storage devices improved so fast that
we cannot saturate the disk bandwidth with single logical CPU when do
page swap out even on a high-end server machine.  Because the
performance of the storage device improved faster than that of single
logical CPU.  And it seems that the trend will not change in the near
future.  On the other hand, the THP becomes more and more popular
because of increased memory size.  So it becomes necessary to optimize
THP swap performance.

The advantages of the THP swap support include:

- Batch the swap operations for the THP to reduce TLB flushing and
  lock acquiring/releasing, including allocating/freeing the swap
  space, adding/deleting to/from the swap cache, and writing/reading
  the swap space, etc.  This will help improve the performance of the
  THP swap.

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

Changelog:

v3:

- Rebased on latest -mm tree
- Some minor fixes

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
