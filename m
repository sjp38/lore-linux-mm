Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEA156B02F1
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 18:48:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so122547899pgq.7
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:48:17 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y17si28681724pgh.106.2016.11.15.15.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 15:48:17 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v3 0/8] mm/swap: Regular page swap optimizations 
Date: Tue, 15 Nov 2016 15:47:33 -0800
Message-Id: <cover.1479252493.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

Andrew,

It seems like there are no objections to this patch series so far.
Can you help us get this patch series to be code reviewed in more 
depth so it can be considered for inclusion to 4.10?
Will appreciate if Mel, Johannes, Rik or others can take a look.
 
We appreciate feedback about this patch series from the
community.  Historically, neither the performance nor latency of the swap
path mattered.  The underlying I/O was slow enough to hide any latency
coming from software and the low IOPS kept the overall CPU impact low.

Times have changed.  Coming generation of Solid state Block device
latencies are getting down to sub 100 usec, which is within an order of
magnitude of DRAM, and their performance is orders of magnitude higher
than the single- spindle rotational media we've swapped to historically.

This could benefit many usage scenearios.  For example cloud providers who
overcommit their memory (as VM don't use all the memory provisioned).
Having a fast swap will allow them to be more aggressive in memory
overcommit and fit more VMs to a platform.

In our testing [see footnote], the median latency that the
kernel adds to a page fault is 15 usec, which comes quite close
to the amount that will be contributed by the underlying I/O
devices.

The software latency comes mostly from contentions on the locks
protecting the radix tree of the swap cache and also the locks protecting
the individual swap devices.  The lock contentions already consumed
35% of cpu cycles in our test.  In the very near future,
software latency will become the bottleneck to swap performnace as
block device I/O latency gets within the shouting distance of DRAM speed.

This patch set, plus a previous patch Ying already posted
(commit: f6498b3f) reduced the median page fault latency
from 15 usec to 4 usec (375% reduction) for DRAM based pmem
block device.

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
We tested mmotm-2016-10-11-15-46 kernel with/without optimizations from
this patche series plus one additional patch Ying posted earlier on
removing radix tree write back tag in swap cache.  Eight threads performed
random memory access on a 2 socket Haswell using swap mounted on RAM
based PMEM block device.  This emulated a moderate load and a SWAP
device unbounded by I/O speed. The aggregate working set is twice the
RAM size. We instrumented the kernel to measure the page fault latency.

Change Log:
v3:
1. Fix bug that didn't check for page already in swap cache before skipping
read ahead and return null page.
2. Fix bug that didn't try to allocate from global pool if allocation
from swap slot cache did not succeed.
3. Fix memory allocation bug for spaces to store split up 64MB radix tree
4. Fix problems caused by races between get_swap_page, cpu online/offline and
swap_on/off

v2: 
1. Fix bug in the index limit used in scan_swap_map_try_ssd_cluster
when searching for empty slots in cluster.
2. Fix bug in swap off that incorrectly determines if we still have
swap devices left.
3. Port patches to mmotm-2016-10-11-15-46 branch


Huang, Ying (3):
  mm/swap: Fix kernel message in swap_info_get()
  mm/swap: Add cluster lock
  mm/swap: Split swap cache into 64MB trunks

Tim Chen (5):
  mm/swap: skip read ahead for unreferenced swap slots
  mm/swap: Allocate swap slots in batches
  mm/swap: Free swap slots in batch
  mm/swap: Add cache for swap slots allocation
  mm/swap: Enable swap slots cache usage

 include/linux/swap.h       |  36 ++-
 include/linux/swap_slots.h |  28 +++
 mm/Makefile                |   2 +-
 mm/swap.c                  |   6 -
 mm/swap_slots.c            | 364 ++++++++++++++++++++++++++++++
 mm/swap_state.c            |  74 ++++++-
 mm/swapfile.c              | 542 +++++++++++++++++++++++++++++++++++----------
 7 files changed, 911 insertions(+), 141 deletions(-)
 create mode 100644 include/linux/swap_slots.h
 create mode 100644 mm/swap_slots.c

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
