Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF5DE6B0537
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 13:38:25 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id n18-v6so2315551edt.3
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 10:38:25 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id m5si583875edv.193.2018.11.07.10.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 10:38:23 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 643051C1E17
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 18:38:23 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/5] Fragmentation avoidance improvements v2
Date: Wed,  7 Nov 2018 18:38:17 +0000
Message-Id: <20181107183822.15567-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The 1-socket machine is different to the one used in v1 so some of the
results are changed on that basis. The baseline has changed to 4.20-rc1 so
the __GFP_THISNODE removal for THP is in effect which alters the behaviour
on 2-socket in particular.  The biggest changes are in the fourth patch,
both in terms of functional changes and the fact it adds a vmstat and
tracepoint for measuring stall latency.

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

Patch 5 is the hardest to prove it's a real benefit. In the event
	that fragmentation was unavoidable, it'll queue a pageblock for
	kcompactd to clean. It's a fixed-length queue that is neither
	guaranteed to have a slot available or successfully clean a
	pageblock.

Patches 4 and 5 can be treated independently or dropped if necessary. This
is particularly true of patch 5 as the benefit is difficult to detect
given the impact of the first 4 patches. The bulk of the improvement
in fragmentation avoidance is from patches 1-3 (94-97% reduction in
fragmentation events for an adverse workload on both a 1-socket and
2-socket machine). The primary benefit of patch 4 is the increase in
THP success rates and the fact it reduces fragmentation events to almost
negligible levels with the option of eliminating them.

 Documentation/sysctl/vm.txt       |  42 +++++++
 include/linux/compaction.h        |   4 +
 include/linux/migrate.h           |   7 +-
 include/linux/mm.h                |   2 +
 include/linux/mmzone.h            |  18 ++-
 include/linux/vm_event_item.h     |   1 +
 include/trace/events/compaction.h |  62 ++++++++++
 include/trace/events/kmem.h       |  21 ++++
 kernel/sysctl.c                   |  18 +++
 mm/compaction.c                   | 147 +++++++++++++++++++++--
 mm/internal.h                     |  14 ++-
 mm/migrate.c                      |   6 +-
 mm/page_alloc.c                   | 246 ++++++++++++++++++++++++++++++++++----
 mm/vmscan.c                       | 123 +++++++++++++++++--
 mm/vmstat.c                       |   1 +
 15 files changed, 661 insertions(+), 51 deletions(-)

-- 
2.16.4
