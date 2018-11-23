Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED056B2CED
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:45:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e12so5666866edd.16
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:45:31 -0800 (PST)
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com. [81.17.249.195])
        by mx.google.com with ESMTPS id b6si1776621edc.315.2018.11.23.03.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:45:29 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id 36C38B88AC
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 11:45:29 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/5] Fragmentation avoidance improvements v5
Date: Fri, 23 Nov 2018 11:45:23 +0000
Message-Id: <20181123114528.28802-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

There are some big changes due to both Vlastimil's review feedback on v4 and
some oddities spotted while answering his review.  In some respects, the
series is slightly less effective but the approach is more consistent and
logical overall. The overhead is also lower from the first patch and stalls
are less harmful in the last patch so overall I think it has much improved.

Changelog since v4
o Clarified changelogs in response to review
o Add a compile-time check on where Normal and DMA32 is		(vbabka)
o Restart zone iteration properly in get_page_from_freelist	(vbabka)
o Reduce overhead in the page allocation fast path		(mel)
o Do not over-boost due to a fragmentation event		(vbabka)
o Correct documentation of sysctl				(mel)
o Really do not wake kswapd if the calling context forbids it	(vbabka,mel)
o Do not shrink slab if boosting watermarks as premature
  reclaim of slab can lead to regressions in IO benchmarks	(mel)
o Take zone lock when boosting watermarks if necessary		(vbabka)

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

Overall the series reduces external fragmentation causing events by over 94%
on 1 and 2 socket machines, which in turn impacts high-order allocation
success rates over the long term. There are differences in latencies and
high-order allocation success rates. Latencies are a mixed bag as they
are vulnerable to exact system state and whether allocations succeeded
so they are treated as a secondary metric.

Patch 1 uses lower zones if they are populated and have free memory
	instead of fragmenting a higher zone. It's special cased to
	handle a Normal->DMA32 fallback with the reasons explained
	in the changelog.

Patch 2-4 boosts watermarks temporarily when an external fragmentation
	event occurs. kswapd wakes to reclaim a small amount of old memory
	and then wakes kcompactd on completion to recover the system
	slightly. This introduces some overhead in the slowpath. The level
	of boosting can be tuned or disabled depending on the tolerance
	for fragmentation vs allocation latency.

Patch 5 stalls some movable allocation requests to let kswapd from patch 4
	make some progress. The duration of the stalls is very low but it
	is possible to tune the system to avoid fragmentation events if
	larger stalls can be tolerated.

The bulk of the improvement in fragmentation avoidance is from patches
1-4 but patch 5 can deal with a rare corner case and provides the option
of tuning a system for THP allocation success rates in exchange for
some stalls to control fragmentation.

 Documentation/sysctl/vm.txt   |  44 +++++++
 include/linux/mm.h            |   2 +
 include/linux/mmzone.h        |  14 ++-
 include/linux/vm_event_item.h |   1 +
 include/trace/events/kmem.h   |  21 ++++
 kernel/sysctl.c               |  18 +++
 mm/compaction.c               |   2 +-
 mm/internal.h                 |  15 ++-
 mm/page_alloc.c               | 263 ++++++++++++++++++++++++++++++++++++++----
 mm/vmscan.c                   | 136 ++++++++++++++++++++--
 mm/vmstat.c                   |   1 +
 11 files changed, 473 insertions(+), 44 deletions(-)

-- 
2.16.4
