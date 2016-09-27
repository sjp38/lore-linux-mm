Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18E0F28024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:17:43 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id bv10so35158975pad.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:17:43 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id qj2si3533788pac.7.2016.09.27.10.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 10:17:42 -0700 (PDT)
Date: Tue, 27 Sep 2016 10:17:41 -0700
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 0/8] mm/swap: Regular page swap optimizations
Message-ID: <20160927171740.GA17793@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Historically, neither the performance nor latency of the swap
path mattered.  The underlying I/O was slow enough to hide any
latency coming from software and the low IOPS kept the overall
CPU impact low.

Times have changed.  Coming generation of Solid state Block device
latencies are getting down to sub 100 usec, which is within an order of
magnitude of DRAM, and their performance is orders of magnitude higher
than the single- spindle rotational media we've swapped to historically.

This could benefit many usage scenearios.  For example cloud providers who
overcommit their memory (as VM don't use all the memory provisioned).
Having a fast swap will allow them to be more aggressive in memory
overcommit and fit more VMs to a platform.

In our testing [see footnote], the median latency that the
kernel adds to a page fault is 15 usec, which is shockingly close
to the amount that will be contributed by the underlying I/O
devices.

The software latency comes mostly from contentions on the locks
protecting the radix tree of the swap cache and also the locks protecting
the individual swap devices.  The lock contentions consumed
35% of cpu cycles in our test.  In the very near future,
software latency will become the bottleneck to swap performnace.

This patch set, plus a previous patch Ying already posted
(http://www.gossamer-threads.com/lists/linux/kernel/2515356),
reduced the median page fault latency from 15 usec to 4 usec (375% reduction).

Patch 1 is a clean up patch.
Patch 2 creates a lock per cluster, this gives us a more fine graind lock
        that can be used for accessing swap_map, and not lock the whole
        swap device
Patch 3 splits the swap cache radix tree into 64MB chunks, reducing
        the rate that we have to contende for the radix tree.
Patch 4 eliminates unnecessary page allocation for read ahead.
Patch 5-8 create a per cpu cache of the swap slots, so we don't have
        to contend on the swap device to get a swap slot or to release
        a swap slot.  And we allocate and release the swap slots
        in batches for better efficiency.

Ying Huang & Tim Chen

Footnote:
Testing was done on 4.8-rc3-mm1 kernel with/without optimizations from
this patche series plus one additional patch Ying posted earlier on
removing radix tree write back tag in swap cache.  Eight threads performed
random memory access on a 2 socket Haswell using swap mounted on RAM
based PMEM block device.  This emulated a moderate load and a SWAP
device unbounded by I/O speed. The aggregate working set is twice the
RAM size. We instrumented the kernel to measure the page fault latency.


Huang Ying (3):
  mm/swap: Fix kernel message in swap_info_get()
  mm/swap: Add cluster lock
  mm/swap: Split swap cache into 64MB trunks

Tim Chen (5):
  mm/swap: skip read ahead for unreferenced swap slots
  mm/swap: Allocate swap slots in batches
  mm/swap: Free swap slots in batch
  mm/swap: Add cache for swap slots allocation
  mm/swap: Enable swap slots cache usage

 include/linux/swap.h       |  35 ++-
 include/linux/swap_slots.h |  37 +++
 mm/Makefile                |   2 +-
 mm/swap.c                  |   6 -
 mm/swap_slots.c            | 305 +++++++++++++++++++++++++
 mm/swap_state.c            |  76 ++++++-
 mm/swapfile.c              | 552 +++++++++++++++++++++++++++++++++++----------
 7 files changed, 870 insertions(+), 143 deletions(-)
 create mode 100644 include/linux/swap_slots.h
 create mode 100644 mm/swap_slots.c

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
