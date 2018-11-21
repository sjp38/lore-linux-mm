Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A95B66B25AD
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 05:14:17 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so2754962edr.7
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 02:14:17 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id t10si685289edq.195.2018.11.21.02.14.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 02:14:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id EE4AA1C25B7
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 10:14:14 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/4] Fragmentation avoidance improvements v4
Date: Wed, 21 Nov 2018 10:14:10 +0000
Message-Id: <20181121101414.21301-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

No major change from v3 really, mostly resending to see if there is any
review reaction. It's rebased but a partial test indicated that the
behaviour is similar to the previous baseline

Changelog since v3
o Rebase to 4.20-rc3
o Remove a stupid warning from the last patch

Changelog since v2
o Drop patch 5 as it was borderline
o Decrease timeout when stalling on fragmentation events

Changelog since v1
o Rebase to v4.20-rc1 for the THP __GFP_THISNODE patch in particular
o Add tracepoint to record fragmentation stall durations
o Add vmstat event to record that a fragmentation stall occurred
o Stalls now alter watermark boosting
o Stalls occur only when the allocation is about to fail

It has been noted before that fragmentation avoidance (aka
anti-fragmentation) is not perfect. Given sufficient time or an adverse
workload, memory gets fragmented and the long-term success of high-order
allocations degrades. This series defines an adverse workload, a definition
of external fragmentation events (including serious) ones and a series
that reduces the level of those fragmentation events.

The details of the workload and the consequences are described in more
detail in the changelogs. However, from patch 1, this is a high-level
summary of the adverse workload. The exact details are found in the
mmtests implementation.

The broad details of the workload are as follows;

1. Create an XFS filesystem (not specified in the configuration but done
   as part of the testing for this patch)
2. Start 4 fio threads that write a number of 64K files inefficiently.
   Inefficiently means that files are created on first access and not
   created in advance (fio parameterr create_on_open=1) and fallocate
   is not used (fallocate=none). With multiple IO issuers this creates
   a mix of slab and page cache allocations over time. The total size
   of the files is 150% physical memory so that the slabs and page cache
   pages get mixed
3. Warm up a number of fio read-only threads accessing the same files
   created in step 2. This part runs for the same length of time it
   took to create the files. It'll fault back in old data and further
   interleave slab and page cache allocations. As it's now low on
   memory due to step 2, fragmentation occurs as pageblocks get
   stolen.
4. While step 3 is still running, start a process that tries to allocate
   75% of memory as huge pages with a number of threads. The number of
   threads is based on a (NR_CPUS_SOCKET - NR_FIO_THREADS)/4 to avoid THP
   threads contending with fio, any other threads or forcing cross-NUMA
   scheduling. Note that the test has not been used on a machine with less
   than 8 cores. The benchmark records whether huge pages were allocated
   and what the fault latency was in microseconds
5. Measure the number of events potentially causing external fragmentation,
   the fault latency and the huge page allocation success rate.
6. Cleanup

Overall the series reduces external fragmentation causing events by over 95%
on 1 and 2 socket machines, which in turn impacts high-order allocation
success rates over the long term. There are differences in latencies and
high-order allocation success rates. Latencies are a mixed bag as they
are vulnerable to exact system state and whether allocations succeeded so
they are treated as a secondary metric.

Patch 1 uses lower zones if they are populated and have free memory
	instead of fragmenting a higher zone. It's special cased to
	handle a Normal->DMA32 fallback with the reasons explained
	in the changelog.

Patch 2+3 boosts watermarks temporarily when an external fragmentation
	event occurs. kswapd wakes to reclaim a small amount of old memory
	and then wakes kcompactd on completion to recover the system
	slightly. This introduces some overhead in the slowpath. The level
	of boosting can be tuned or disabled depending on the tolerance
	for fragmentation vs allocation latency.

Patch 4 is more heavy handed. In the event of a movable allocation
	request that can stall, it'll wake kswapd as in patch 3.  However,
	if the expected fragmentation event is serious then the request
	will stall briefly on pfmemalloc_wait until kswapd completes
	light reclaim work and retry the allocation without stalling.
	This can avoid the fragmentation event entirely in some cases.
	The definition of a serious fragmentation event can be tuned
	or disabled.

The bulk of the improvement in fragmentation avoidance is from patches
1-3 (94-97% reduction in fragmentation events for an adverse workload on
both a 1-socket and 2-socket machine). The primary benefit of patch 4 is
the increase in THP success rates and the fact it reduces fragmentation
events to almost negligible levels with the option of eliminating them.

 Documentation/sysctl/vm.txt   |  42 ++++++++
 include/linux/mm.h            |   2 +
 include/linux/mmzone.h        |  14 ++-
 include/linux/vm_event_item.h |   1 +
 include/trace/events/kmem.h   |  21 ++++
 kernel/sysctl.c               |  18 ++++
 mm/compaction.c               |   2 +-
 mm/internal.h                 |  14 ++-
 mm/page_alloc.c               | 238 ++++++++++++++++++++++++++++++++++++++----
 mm/vmscan.c                   | 123 ++++++++++++++++++++--
 mm/vmstat.c                   |   1 +
 11 files changed, 436 insertions(+), 40 deletions(-)

-- 
2.16.4
