Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B6DE86B003D
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:06:47 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/9] adding compaction to zone_reclaim_mode v3
Date: Fri,  2 Aug 2013 18:06:27 +0200
Message-Id: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

Hi,

This v3 is incremental with Johannes roundrobin allocator v2. It
should be good to be included in -mm and applied right after the
roundrobin allocator (the roundrobin allocator also improves the
zone_reclaim_mode for those nodes where there's more than one zone,
like node 0 with the pci32 zone).

Without the patch, when THP is disabled, zone_reclaim_mode set to 1
(or higher) tends to allocate memory in the local node with quite some
accuracy in presence of CPU node bindings (and weak or no memory
bindings). However when THP is enabled, it tends to spread the memory
to other nodes erroneously.

This patch adds compaction to zone_reclaim_mode (default enabled on
big NUMA) so THP doesn't risk to regress the NUMA placement when
zone_reclaim_mode is enabled.

I also found zone_reclaim_mode is quite unreliable in presence of
multiple threads allocating memory at the same time from different
CPUs in the same node, even when THP is disabled and there's plenty of
clean cache to trivially reclaim.

After setting zone_reclaim_mode to 1 and booting with
numa_zonelist_order=n, with this patchset applied I get this NUMA placement:

  PID COMMAND         CPUMASK     TOTAL [     N0     N1 ]
 7088 breakthp              0      2.1M [   2.1M     0  ]
 7089 breakthp              1      2.1M [   2.1M     0  ]
 7090 breakthp              2      2.1M [   2.1M     0  ]
 7091 breakthp              3      2.1M [   2.1M     0  ]
 7092 breakthp              6      2.1M [     0    2.1M ]
 7093 breakthp              7      2.1M [     0    2.1M ]
 7094 breakthp              8      2.1M [     0    2.1M ]
 7095 breakthp              9      2.1M [     0    2.1M ]
 7097 breakthp              0      2.1M [   2.1M     0  ]
 7098 breakthp              1      2.1M [   2.1M     0  ]
 7099 breakthp              2      2.1M [   2.1M     0  ]
 7100 breakthp              3      2.1M [   2.1M     0  ]
 7101 breakthp              6      2.1M [     0    2.1M ]
 7102 breakthp              7      2.1M [     0    2.1M ]
 7103 breakthp              8      2.1M [     0    2.1M ]
 7104 breakthp              9      2.1M [     0    2.1M ]
  PID COMMAND         CPUMASK     TOTAL [     N0     N1 ]
 7106 usemem                0     1.00G [  1.00G     0  ]
 7107 usemem                1     1.00G [  1.00G     0  ]
 7108 usemem                2     1.00G [  1.00G     0  ]
 7109 usemem                3     1.00G [  1.00G     0  ]
 7110 usemem                6     1.00G [     0   1.00G ]
 7111 usemem                7     1.00G [     0   1.00G ]
 7112 usemem                8     1.00G [     0   1.00G ]
 7113 usemem                9     1.00G [     0   1.00G ]

Without current upstream without the patchset and still
zone_reclaim_mode = 1 and booting with numa_zonelist_order=n:

  PID COMMAND         CPUMASK     TOTAL [     N0     N1 ]
 2950 breakthp              0      2.1M [   2.1M     0  ]
 2951 breakthp              1      2.1M [   2.1M     0  ]
 2952 breakthp              2      2.1M [   2.1M     0  ]
 2953 breakthp              3      2.1M [   2.1M     0  ]
 2954 breakthp              6      2.1M [     0    2.1M ]
 2955 breakthp              7      2.1M [     0    2.1M ]
 2956 breakthp              8      2.1M [     0    2.1M ]
 2957 breakthp              9      2.1M [     0    2.1M ]
 2966 breakthp              0      2.1M [   2.0M    96K ]
 2967 breakthp              1      2.1M [   2.0M    96K ]
 2968 breakthp              2      1.9M [   1.9M    96K ]
 2969 breakthp              3      2.1M [   2.0M    96K ]
 2970 breakthp              6      2.1M [   228K   1.8M ]
 2971 breakthp              7      2.1M [    72K   2.0M ]
 2972 breakthp              8      2.1M [    60K   2.0M ]
 2973 breakthp              9      2.1M [   204K   1.9M ]
  PID COMMAND         CPUMASK     TOTAL [     N0     N1 ]
 3088 usemem                0     1.00G [ 856.2M 168.0M ]
 3089 usemem                1     1.00G [ 860.2M 164.0M ]
 3090 usemem                2     1.00G [ 860.2M 164.0M ]
 3091 usemem                3     1.00G [ 858.2M 166.0M ]
 3092 usemem                6     1.00G [ 248.0M 776.2M ]
 3093 usemem                7     1.00G [ 248.0M 776.2M ]
 3094 usemem                8     1.00G [ 250.0M 774.2M ]
 3095 usemem                9     1.00G [ 246.0M 778.2M ]

The testcase always uses CPU bindings (half processes in one node, and
half processes in the other node). It first fragments all memory
(breakthp) by breaking lots of hugepages with mremap, and then another
process (usemem) allocates lots of memory, in turn exercising the
reliability of compaction with zone_reclaim_mode > 0.

Very few hugepages are available when usemem starts, but compaction
has a trivial time to generate as many hugepages as needed without any
risk of failure.

The memory layout when usemem starts is like this:

4k page anon
4k page free
another 512-2 4k pages free
4k page anon
4k page free
another 512-2 4k pages free
[..]

The heuristic that decides the default of numa_zonelist_order=z should
also be dropped or at least be improved (not addressed by this
patchset). The =z default makes no sense on my hardware for example,
and the coming roundrobin allocator from Johannes will defeats any
benefit of =z. Only =n default will make sense with the roundrobin
allocator.

The roundrobin allocator entirely depends on the lowmem_reserve logic
for its safety with regard to lowmem zones.

Andrea Arcangeli (9):
  mm: zone_reclaim: remove ZONE_RECLAIM_LOCKED
  mm: zone_reclaim: compaction: scan all memory with
    /proc/sys/vm/compact_memory
  mm: zone_reclaim: compaction: don't depend on kswapd to invoke
    reset_isolation_suitable
  mm: zone_reclaim: compaction: reset before initializing the scan
    cursors
  mm: compaction: don't require high order pages below min wmark
  mm: zone_reclaim: compaction: increase the high order pages in the
    watermarks
  mm: zone_reclaim: compaction: export compact_zone_order()
  mm: zone_reclaim: after a successful zone_reclaim check the min
    watermark
  mm: zone_reclaim: compaction: add compaction to zone_reclaim_mode

 include/linux/compaction.h |  11 +++--
 include/linux/mmzone.h     |   9 ----
 include/linux/swap.h       |   8 ++-
 mm/compaction.c            |  40 ++++++++-------
 mm/page_alloc.c            |  45 +++++++++++++++--
 mm/vmscan.c                | 121 ++++++++++++++++++++++++++++++++++-----------
 6 files changed, 168 insertions(+), 66 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
