Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3BBE6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 12:55:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f144so267061443pfa.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:55:36 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m13si6442061pga.262.2017.01.11.09.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 09:55:35 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v5 0/9] mm/swap: Regular page swap optimizations 
Date: Wed, 11 Jan 2017 09:55:10 -0800
Message-Id: <cover.1484082593.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

Change Log:
v5:
1. Rebase patch series on 4.10-rc3 kernel. Update patch series to remove
usage of obsoleted hot plug functions: cpu_notifier_register_begin(),
cpu_notifier_register_done(), and __register_hotcpu_notifier() 
2. Fix a bug returning uninitialized swap slot when we run
out of swap slots on all swap devices.
3. Minor code style clean ups.

v4:
1. Fix a bug in unlock cluster in add_swap_count_continuation(). We
should use unlock_cluster() instead of unlock_cluser_or_swap_info().
2. During swap off, handle race when swap slot is marked unused but allocated,
and not yet placed in swap cache.  Wait for swap slot to be placed in swap cache
and not abort swap off.
3. Initialize n_ret in get_swap_pages().

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

Andrew,

We're updating this patch series with some minor fixes and rebased to 4.10-rc3.
Please consider this patch series for inclusion to the mm kernel. 
 
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

This patch set, reduced the median page fault latency
from 15 usec to 4 usec (375% reduction) for DRAM based pmem
block device.

Patch 1 is a clean up patch.
Patch 2 creates a lock per cluster, this gives us a more fine graind lock
        that can be used for accessing swap_map, and not lock the whole
        swap device
Patch 3 splits the swap cache radix tree into 64MB chunks, reducing
        the rate that we have to contende for the radix tree.
Patch 4 eliminates unnecessary page allocation for read ahead.
Patch 5-9 create a per cpu cache of the swap slots, so we don't have
        to contend on the swap device to get a swap slot or to release
        a swap slot.  And we allocate and release the swap slots
        in batches for better efficiency.

We describe below the changes in swap throughput and
lock contentions. Test was done with PMEM block swap device
for 32 processes on Xeon E5 v3 system. The swap device used is a RAM
simulated PMEM (persistent memory) device.  To test the sequential
swapping out, the test case created 32 processes, which sequentially
allocate and write to the anonymous pages until the RAM and part of the
swap device is used.  This gives an indication of the effect of each
successive patch.  Test was done on patch version 4 which is functionally
identical to version 5.

Vanilla kernel 4.9-rc8:
 Throughput:
  vmstat.swap.so: 1428002 kB/sec,
 Top lock contentions in %cpu.
  perf-profile.calltrace.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list: 13.94%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_node_memcg: 13.75%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.swap_info_get.swapcache_free.__remove_mapping.shrink_page_list: 7.05%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.swap_info_get.page_swapcount.try_to_free_swap.swap_writepage: 7.03%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.__swap_duplicate.swap_duplicate.try_to_unmap_one.rmap_walk_anon: 7.02%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_page.add_to_swap.shrink_page_list.shrink_inactive_list: 6.83%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.page_check_address_transhuge.page_referenced_one.rmap_walk_anon.rmap_walk: 0.81%,

Patch 1-2: 
Swap throughput slightly improved 4%, swap_info_get and __swap_duplicate contention on swap_info lock eliminated.
  Throughput:
  vmstat.swap.so: 1481704 kB/sec,  (4% increase over vanilla)
  Top lock contentions in %cpu:
  perf-profile.calltrace.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list: 27.53%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_node_memcg: 27.01%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.free_pcppages_bulk.drain_pages_zone.drain_pages.drain_local_pages: 1.03%,

Patch 1-3
Swap throughput improved 44%, add_to_swap_cache contention on radix tree lock is eliminated.
  Throughput:
  vmstat.swap.so: 2050097 kB/sec,  (44% increase over vanilla)
  Top lock contentions in %cpu:
  perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_page.add_to_swap.shrink_page_list.shrink_inactive_list: 43.27,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_mm_fault: 4.84,

Patch 1-9
Swap throughput improved 192%, get_swap_page contention on swap_info lock eliminated. 
  Throughput:
  vmstat.swap.so: 4170746 kB/sec, (192% increase over vanilla)
  Top lock contentions in %cpu:
  perf-profile.calltrace.cycles-pp._raw_spin_lock.swapcache_free_entries.free_swap_slot.free_swap_and_cache.unmap_page_range: 13.91%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_mm_fault: 8.56%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_slowpath.__alloc_pages_nodemask.alloc_pages_vma: 2.56%,
  perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_pages.get_swap_page.add_to_swap.shrink_page_list: 2.47%,

Ying Huang & Tim Chen

Footnote:
We tested the patch series for page latency with/without optimizations from
this patche series plus one additional patch Ying posted earlier on
removing radix tree write back tag in swap cache.  Eight threads performed
random memory access on a 2 socket Haswell using swap mounted on RAM
based PMEM block device.  This emulated a moderate load and a SWAP
device unbounded by I/O speed. The aggregate working set is twice the
RAM size. We instrumented the kernel to measure the page fault latency.


Huang Ying (1):
  mm/swap: Skip readahead only when swap slot cache is enabled

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

 include/linux/swap.h       |  37 +++-
 include/linux/swap_slots.h |  30 +++
 mm/Makefile                |   2 +-
 mm/swap.c                  |   6 -
 mm/swap_slots.c            | 333 ++++++++++++++++++++++++++++
 mm/swap_state.c            |  80 ++++++-
 mm/swapfile.c              | 540 +++++++++++++++++++++++++++++++++++----------
 7 files changed, 887 insertions(+), 141 deletions(-)
 create mode 100644 include/linux/swap_slots.h
 create mode 100644 mm/swap_slots.c

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
