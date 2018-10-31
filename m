Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 76A3F6B0266
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:06:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b34-v6so11038670ede.5
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:06:48 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id s21-v6si740729ejf.83.2018.10.31.09.06.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Oct 2018 09:06:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 29F9A986CC
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 16:06:46 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/5] Fragmentation avoidance improvements
Date: Wed, 31 Oct 2018 16:06:40 +0000
Message-Id: <20181031160645.7633-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Warning: This is a long intro with long changelogs and this is not a
	trivial area to either analyse or fix. TLDR -- 95% reduction in
	fragmentation events, patches 1-3 should be relatively ok. Patch
	4 and 5 need scrutiny but they are also independent or dropped.

It has been noted before that fragmentation avoidance (aka
anti-fragmentation) is far from perfect. Given a long enough time or an
adverse enough workload, memory still gets fragmented and the long-term
success of high-order allocations degrades. This series defines an adverse
workload, a definition of external fragmentation events (including serious)
ones and a series that reduces the level of those fragmentation events.

This series is *not* directly related to the recent __GFP_THISNODE
discussion and has no impact on the trivial test cases that were discussed
there. This series was also evaluated without the candidate fixes from
that discussion. The series does have consequences for high-order and
THP allocations though that are important to consider so the same people
are cc'd. It's also far from a complete solution but side-issues such as
compaction, usability and other factors would require different series. It's
also extremely important to note that this is analysed in the context of
one adverse workload. While other patterns of fragmentation are possible
(and workloads that are mostly slab allocations have a completely different
solution space), they would need test cases to be properly considered.

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

Patches 4 and 5 can be treated independently or dropped. The bulk of
the improvement in fragmentation avoidance is from patches 1-3 (94-97%
reduction in fragmentation events for an adverse workload on both a
1-socket and 2-socket machine).

 Documentation/sysctl/vm.txt       |  42 +++++++
 include/linux/compaction.h        |   4 +
 include/linux/migrate.h           |   7 +-
 include/linux/mm.h                |   2 +
 include/linux/mmzone.h            |  18 ++-
 include/trace/events/compaction.h |  62 +++++++++++
 kernel/sysctl.c                   |  18 +++
 mm/compaction.c                   | 148 +++++++++++++++++++++++--
 mm/internal.h                     |  14 ++-
 mm/migrate.c                      |   6 +-
 mm/page_alloc.c                   | 228 ++++++++++++++++++++++++++++++++++----
 mm/vmscan.c                       | 123 ++++++++++++++++++--
 12 files changed, 621 insertions(+), 51 deletions(-)

-- 
2.16.4
