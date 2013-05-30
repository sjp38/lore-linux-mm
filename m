Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C48376B0032
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:04:32 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 00/10] mm: thrash detection-based file cache sizing
Date: Thu, 30 May 2013 14:03:56 -0400
Message-Id: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

The VM maintains cached filesystem pages on two types of lists.  One
list holds the pages recently faulted into the cache, the other list
holds pages that have been referenced repeatedly on that first list.
The idea is to prefer reclaiming young pages over those that have
shown to benefit from caching in the past.  We call the recently used
list "inactive list" and the frequently used list "active list".

The tricky part of this model is finding the right balance between
them.  A big inactive list may not leave enough room for the active
list to protect all the frequently used pages.  A big active list may
not leave enough room for the inactive list for a new set of
frequently used pages, "working set", to establish itself because the
young pages get pushed out of memory before having a chance to get
promoted.

Historically, every reclaim scan of the inactive list also took a
smaller number of pages from the tail of the active list and moved
them to the head of the inactive list.  This model gave established
working sets more gracetime in the face of temporary use once streams,
but was not satisfactory when use once streaming persisted over longer
periods of time and the established working set was temporarily
suspended, like a nightly backup evicting all the interactive user
program data.
    
Subsequently, the rules were changed to only age active pages when
they exceeded the amount of inactive pages, i.e. leave the working set
alone as long as the other half of memory is easy to reclaim use once
pages.  This works well until working set transitions exceed the size
of half of memory and the average access distance between the pages of
the new working set is bigger than the inactive list.  The VM will
mistake the thrashing new working set for use once streaming, while
the unused old working set pages are stuck on the active list.

This happens on file servers and media streaming servers, where the
popular set of files changes over time.  Even though the individual
files might be smaller than half of memory, concurrent access to many
of them may still result in their inter-reference distance being
greater than half of memory.  It's also been reported on database
workloads that switch back and forth between tables that are bigger
than half of memory.

This series solves the problem by maintaining a history of pages
evicted from the inactive list, enabling the VM to tell actual use
once streaming from inactive list thrashing and subsequently adjust
the balance between the lists.

Version 2 of this series includes many updates to the comments,
documentation, code structure, and eviction history tracking in
response to Peter Zijlstra, Rik van Riel, Minchan Kim, Andrea
Arcangeli, Andrew Morton, and Mel Gorman.  Thanks a lot!!

wschange - test adaptiveness to new workingsets
-----------------------------------------------

On a 16G machine, a sequence of 12G files is read into the cache.
Every file is read repeatedly until fully cached in memory, then the
test moves on to the next file to show how quickly the VM adapts to a
new workingset.

--- vanilla:
Dropping caches...
Reading files until fully cached (+2 reads for activation):
data-1 (1):  9.32 4.48 4.14 4.10
data-2 (1):  9.73 9.95 10.00 10.00 9.99 9.75 9.99 9.56 10.04 9.56 10.02
    9.62 10.02 9.56 10.06 9.57 10.04 9.58 9.74 10.06 10.04 10.04 10.06
    9.60 10.07 10.07 9.70 10.03 10.07 9.65
ERROR: data-2 not fully cached after reading it 30x

The vanilla kernel never adapts to new workingsets with
inter-reference distances bigger than half of memory. The active list
is simply not challenged as long as it is bigger than the inactive
list, i.e. effectively half of memory in size, which does not give the
new pages enough time for activation.  As a result, they are thrashing
on the inactive list, which the VM mistakes for "plenty of used-once
cache" and protects the stale cache indefinitely.

--- patched:
Dropping caches...
Reading files until fully cached (+2 reads for activation):
data-1 (1):  9.41 4.58 4.21 4.16
data-2 (1):  9.58 10.00 9.72 10.22 5.77 4.29 4.22 4.20
data-3 (1):  9.71 9.71 10.13 10.25 6.08 4.42 4.19 4.17
data-1 (2):  10.00 9.79 10.32 7.53 4.49 4.21 4.18
data-2 (2):  10.02 10.27 9.10 4.64 4.25 4.19
data-3 (2):  10.02 10.33 9.14 4.66 4.25 4.21
data-1 (3):  10.04 10.35 9.18 4.67 4.27 4.22
data-2 (3):  10.08 10.36 9.33 4.72 4.26 4.23
data-3 (3):  10.09 10.41 9.31 4.72 4.29 4.24
...

The patched kernel detects the thrashing on the inactive list and
challenges the stale cache on the active list, which is eventually
evicted to make room for the new workingset.

wsprotect - test protection of workingset in presence of streaming
------------------------------------------------------------------

Streaming data does not benefit from caching, and repeatedly access
data that is bigger than memory can not be reasonably cached at this
point.  That's why the VM needs to protect an existing working set in
the presence of such streaming / uncachable competetitor sets.

On a 16G machine, a 4G file is read into cache.  When a 17G file is
read repeatedly, the 4G workingset data should remain cached as much
as possible.

--- vanilla:
Dropping caches...
Caching workingset file 'ws':
3.13
1.49
1.37
1.36
1.37
mincore: ws: 1048576/1048576 (100%)
Repeatedly streaming bigger than memory file 'stream':
13.46
14.09
14.09
14.14
14.09
14.00
13.45
13.43
13.47
14.04
mincore: ws: 1048576/1048576 (100%)

--- patched:
Dropping caches...
Caching workingset file 'ws':
3.18
1.56
1.43
1.41
1.41
mincore: ws: 1048576/1048576 (100%)
Repeatedly streaming bigger than memory file 'stream':
13.45
13.66
13.69
13.75
13.85
13.83
13.95
14.36
14.38
14.40
mincore: ws: 1048576/1048576 (100%)

The patched kernel observes refaulting streaming pages, but recognizes
that the set is bigger than memory and could never be fully cached.
As a result, it continues to protect the existing cache.

pft - page fault overhead
-------------------------

The zone round robin allocator (RRALLOC) adds some overhead that shows
in this microbenchmark which serves tmpfs faults purely out of memory.
There is no significant impact from the remaining workingset patches:

pft
                              BASE               RRALLOC            WORKINGSET
User       1       0.0235 (  0.00%)       0.0275 (-17.02%)       0.0270 (-14.89%)
User       2       0.0275 (  0.00%)       0.0275 ( -0.00%)       0.0285 ( -3.64%)
User       3       0.0330 (  0.00%)       0.0365 (-10.61%)       0.0335 ( -1.52%)
User       4       0.0390 (  0.00%)       0.0390 (  0.00%)       0.0380 (  2.56%)
System     1       0.2645 (  0.00%)       0.2620 (  0.95%)       0.2625 (  0.76%)
System     2       0.3215 (  0.00%)       0.3310 ( -2.95%)       0.3285 ( -2.18%)
System     3       0.3935 (  0.00%)       0.4080 ( -3.68%)       0.4130 ( -4.96%)
System     4       0.4920 (  0.00%)       0.5030 ( -2.24%)       0.5045 ( -2.54%)
Elapsed    1       0.2905 (  0.00%)       0.2905 (  0.00%)       0.2905 (  0.00%)
Elapsed    2       0.1800 (  0.00%)       0.1800 (  0.00%)       0.1800 (  0.00%)
Elapsed    3       0.1500 (  0.00%)       0.1600 ( -6.67%)       0.1600 ( -6.67%)
Elapsed    4       0.1305 (  0.00%)       0.1420 ( -8.81%)       0.1415 ( -8.43%)
Faults/cpu 1  667251.7997 (  0.00%)  666296.4749 ( -0.14%)  667880.8099 (  0.09%)
Faults/cpu 2  551464.0345 (  0.00%)  536113.4630 ( -2.78%)  538286.2087 ( -2.39%)
Faults/cpu 3  452403.4425 (  0.00%)  433856.5320 ( -4.10%)  432193.9888 ( -4.47%)
Faults/cpu 4  362691.4491 (  0.00%)  356514.8821 ( -1.70%)  356436.5711 ( -1.72%)
Faults/sec 1  663612.5980 (  0.00%)  662501.4959 ( -0.17%)  664037.3123 (  0.06%)
Faults/sec 2 1096166.5317 (  0.00%) 1064679.7154 ( -2.87%) 1068906.1040 ( -2.49%)
Faults/sec 3 1272925.4995 (  0.00%) 1209241.9167 ( -5.00%) 1202868.9190 ( -5.50%)
Faults/sec 4 1437691.1054 (  0.00%) 1362549.9877 ( -5.23%) 1381633.9889 ( -3.90%)

                BASE     RRALLOC  WORKINGSET
User            2.53        2.63        2.59
System         34.01       34.94       35.08
Elapsed        18.93       19.49       19.52

kernbench - impact on kernel hacker workloads
---------------------------------------------

In a workload that is not purely allocator bound and also does some
computation and IO, the added allocator overhead is in the noise:

                                BASE               RRALLOC            WORKINGSET
User    min        1163.95 (  0.00%)     1131.79 (  2.76%)     1123.41 (  3.48%)
User    mean       1170.76 (  0.00%)     1139.68 (  2.65%)     1125.63 (  3.85%)
User    stddev        6.38 (  0.00%)        7.91 (-24.00%)        1.37 ( 78.60%)
User    max        1182.17 (  0.00%)     1149.63 (  2.75%)     1127.55 (  4.62%)
User    range        18.22 (  0.00%)       17.84 (  2.09%)        4.14 ( 77.28%)
System  min          79.97 (  0.00%)       80.13 ( -0.20%)       78.21 (  2.20%)
System  mean         80.55 (  0.00%)       80.68 ( -0.16%)       78.93 (  2.01%)
System  stddev        0.80 (  0.00%)        0.55 ( 31.73%)        0.44 ( 44.91%)
System  max          82.11 (  0.00%)       81.38 (  0.89%)       79.33 (  3.39%)
System  range         2.14 (  0.00%)        1.25 ( 41.59%)        1.12 ( 47.66%)
Elapsed min         319.04 (  0.00%)      310.75 (  2.60%)      307.69 (  3.56%)
Elapsed mean        320.98 (  0.00%)      313.65 (  2.28%)      309.33 (  3.63%)
Elapsed stddev        2.37 (  0.00%)        2.27 (  4.37%)        1.40 ( 40.92%)
Elapsed max         325.52 (  0.00%)      316.83 (  2.67%)      311.69 (  4.25%)
Elapsed range         6.48 (  0.00%)        6.08 (  6.17%)        4.00 ( 38.27%)
CPU     min         388.00 (  0.00%)      386.00 (  0.52%)      386.00 (  0.52%)
CPU     mean        389.40 (  0.00%)      388.60 (  0.21%)      389.00 (  0.10%)
CPU     stddev        0.80 (  0.00%)        1.50 (-87.08%)        1.55 (-93.65%)
CPU     max         390.00 (  0.00%)      390.00 (  0.00%)      390.00 (  0.00%)
CPU     range         2.00 (  0.00%)        4.00 (-100.00%)        4.00 (-100.00%)

                BASE     RRALLOC  WORKINGSET
User         7009.94     6821.10     6755.85
System        489.88      490.82      481.82
Elapsed      1974.68     1930.58     1909.76

micro - reclaim micro benchmark
-------------------------------

This multi-threaded micro benchmark creates memory pressure with a mix
of anonymous and mapped file memory.  By spreading memory among the
available nodes more evently, reclaim behavior is greatly improved by
the round-robin allocator in terms of overall IO, swapping,
efficiency, direct reclaim invocations, reclaim writeback:

                BASE     RRALLOC  WORKINGSET
User          558.11      566.39      564.37
System         28.36       25.60       24.29
Elapsed       394.70      387.38      386.07

                                  BASE     RRALLOC  WORKINGSET
Page Ins                       6853744     5764336     5672052
Page Outs                     12136640    10673568    10617640
Swap Ins                             0           0           0
Swap Outs                         6702           0           0
Direct pages scanned           1751264      176965      238264
Kswapd pages scanned           4832689     3751475     3595031
Kswapd pages reclaimed         2347185     2325232     2239671
Direct pages reclaimed          419104      176226      236990
Kswapd efficiency                  48%         61%         62%
Kswapd velocity              12243.955    9684.225    9311.863
Direct efficiency                  23%         99%         99%
Direct velocity               4436.950     456.825     617.152
Percentage direct scans            26%          4%          6%
Page writes by reclaim          661863       10182       11310
Page writes file                655161       10182       11310
Page writes anon                  6702           0           0
Page reclaim immediate         1083840       15373       24797
Page rescued immediate               0           0           0
Slabs scanned                    10240       13312       11776
Direct inode steals                  0           0           0
Kswapd inode steals                  0           0           0
Kswapd skipped wait                  0           0           0
THP fault alloc                   2057        2249        3163
THP collapse alloc                   0           0           0
THP splits                           6           0           0
THP fault fallback                5824        5630        4719
THP collapse fail                    0           0           0
Compaction stalls                  551         484         610
Compaction success                 105          47          91
Compaction failures                446         437         484
Page migrate success            176065      103764      135377
Page migrate failure                 0           0           0
Compaction pages isolated       443314      263699      346198
Compaction migrate scanned      687684      598263      640277
Compaction free scanned       14437356     5061851     4744974
Compaction cost                    195         116         151
NUMA PTE updates                     0           0           0
NUMA hint faults                     0           0           0
NUMA hint local faults               0           0           0
NUMA pages migrated                  0           0           0
AutoNUMA cost                        0           0           0

memcachetest - streaming IO impact on anonyomus workingset
----------------------------------------------------------

This test runs a latency-sensitive in-core workload that is
accompanied by use once page cache streams of increasing size in the
background.

It too shows great improvements in allocation/reclaim behavior.  The
in-core workload is much less affected by the background IO, even
though IO throughput itself increased.  Same reclaim improvements as
before: reduced swapping, page faults, increased reclaim efficiency,
less writeback from reclaim:

                                              BASE                     RRALLOC                  WORKINGSET
Ops memcachetest-0M             15294.00 (  0.00%)          15492.00 (  1.29%)          16420.00 (  7.36%)
Ops memcachetest-375M           15574.00 (  0.00%)          15510.00 ( -0.41%)          16602.00 (  6.60%)
Ops memcachetest-1252M           8908.00 (  0.00%)          15733.00 ( 76.62%)          16640.00 ( 86.80%)
Ops memcachetest-2130M           2652.00 (  0.00%)          16089.00 (506.67%)          16764.00 (532.13%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-375M                6.00 (  0.00%)              5.00 ( 16.67%)              6.00 (  0.00%)
Ops io-duration-1252M              52.00 (  0.00%)             17.00 ( 67.31%)             17.00 ( 67.31%)
Ops io-duration-2130M             124.00 (  0.00%)             30.00 ( 75.81%)             30.00 ( 75.81%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-375M                  0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-1252M            169167.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-2130M            278835.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-375M                     0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-1252M                78117.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-2130M               135073.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops minorfaults-0M             776489.00 (  0.00%)         779312.00 ( -0.36%)         783329.00 ( -0.88%)
Ops minorfaults-375M           778665.00 (  0.00%)         780201.00 ( -0.20%)         784954.00 ( -0.81%)
Ops minorfaults-1252M          898776.00 (  0.00%)         781391.00 ( 13.06%)         785025.00 ( 12.66%)
Ops minorfaults-2130M          838654.00 (  0.00%)         782741.00 (  6.67%)         785580.00 (  6.33%)
Ops majorfaults-0M                  0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops majorfaults-375M                0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops majorfaults-1252M           10916.00 (  0.00%)             38.00 ( 99.65%)             38.00 ( 99.65%)
Ops majorfaults-2130M           19278.00 (  0.00%)             38.00 ( 99.80%)             38.00 ( 99.80%)

                BASE     RRALLOC  WORKINGSET
User          521.34      654.91      671.03
System       1694.60     2181.44     2157.61
Elapsed      4781.91     4701.73     4700.31

                                  BASE     RRALLOC  WORKINGSET
Page Ins                       3609444       18304       18296
Page Outs                     23111464    19283920    19285644
Swap Ins                        831734           0           0
Swap Outs                       950459           0           0
Direct pages scanned            354478           0        1061
Kswapd pages scanned           6490315     2808074     2875760
Kswapd pages reclaimed         3116126     2808050     2875738
Direct pages reclaimed          324821           0        1061
Kswapd efficiency                  48%         99%         99%
Kswapd velocity               1357.264     597.243     611.823
Direct efficiency                  91%        100%        100%
Direct velocity                 74.129       0.000       0.226
Percentage direct scans             5%          0%          0%
Page writes by reclaim         2088376           0           0
Page writes file               1137917           0           0
Page writes anon                950459           0           0
Page reclaim immediate          195121           0           0
Page rescued immediate               0           0           0
Slabs scanned                    35328           0           0
Direct inode steals                  0           0           0
Kswapd inode steals              19613           0           0
Kswapd skipped wait                  0           0           0
THP fault alloc                      8           3           0
THP collapse alloc                2495         871        1025
THP splits                          18          10           7
THP fault fallback                   0           0           0
THP collapse fail                   24          65          59
Compaction stalls                   66           2           2
Compaction success                  45           0           0
Compaction failures                 21           2           2
Page migrate success             39331           0           0
Page migrate failure                 0           0           0
Compaction pages isolated        84996           0           0
Compaction migrate scanned       59149           0           0
Compaction free scanned         916327           0           0
Compaction cost                     42           0           0
NUMA PTE updates                     0           0           0
NUMA hint faults                     0           0           0
NUMA hint local faults               0           0           0
NUMA pages migrated                  0           0           0
AutoNUMA cost                        0           0           0

---

Patch #1 solves a fairness problem we have with the per-zone LRU
lists, where the time a file cache page gets in memory is dependent on
the zone it gets allocated from.  The proposed solution is a very
simple (and maybe too crude) round-robin allocator.  It's a problem
that exists without this patch series, but the thrash detection
fundamentally relies on fair aging, so this is included here.

Patches #2-#6 prepare the page cache radix tree for non-page entries
that represent evicted pages.

Patch #7 prepares the page cache allocation path for passing down
refault information from the fault handler down to the page allocator,
which will later use it to prime the reclaim scanner for list
rebalancing.

Patch #9 is the thrash detection code.

Patch #10 is to keep the eviction history in check by both throttling
the number of non-page entries remembered in the radix trees when the
per-file refault ratio is very small and by having a shrinker that
trims those entries when they still grow excessively.

 fs/btrfs/compression.c           |   9 +-
 fs/cachefiles/rdwr.c             |  25 ++-
 fs/ceph/xattr.c                  |   2 +-
 fs/inode.c                       |   8 +-
 fs/logfs/readwrite.c             |   9 +-
 fs/nfs/blocklayout/blocklayout.c |   2 +-
 fs/nilfs2/inode.c                |   4 +-
 fs/ntfs/file.c                   |  10 +-
 fs/splice.c                      |   9 +-
 include/linux/fs.h               |   3 +
 include/linux/gfp.h              |  18 +-
 include/linux/mm.h               |   8 +
 include/linux/mmzone.h           |   9 +
 include/linux/pagemap.h          |  59 ++++--
 include/linux/pagevec.h          |   3 +
 include/linux/radix-tree.h       |   5 +-
 include/linux/shmem_fs.h         |   1 +
 include/linux/swap.h             |   9 +
 include/linux/vm_event_item.h    |   1 +
 include/linux/writeback.h        |   1 +
 lib/radix-tree.c                 | 105 +++------
 mm/Makefile                      |   2 +-
 mm/filemap.c                     | 289 ++++++++++++++++++++-----
 mm/memcontrol.c                  |   3 +
 mm/mempolicy.c                   |  17 +-
 mm/mincore.c                     |  20 +-
 mm/mmzone.c                      |   1 +
 mm/page-writeback.c              |   2 +-
 mm/page_alloc.c                  |  90 +++++---
 mm/readahead.c                   |  12 +-
 mm/shmem.c                       | 122 +++--------
 mm/swap.c                        |  22 ++
 mm/truncate.c                    |  78 +++++--
 mm/vmscan.c                      |  45 +++-
 mm/vmstat.c                      |   4 +
 mm/workingset.c                  | 423 +++++++++++++++++++++++++++++++++++++
 net/ceph/pagelist.c              |   4 +-
 net/ceph/pagevec.c               |   2 +-
 38 files changed, 1083 insertions(+), 353 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
