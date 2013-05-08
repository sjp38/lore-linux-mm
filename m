Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 5D2786B012A
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:11 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 00/22] Per-cpu page allocator replacement prototype
Date: Wed,  8 May 2013 17:02:45 +0100
Message-Id: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Two LSF/MM's ago there was discussion on the per-cpu page allocator and
whether it could be replaced due to it's complexity, frequent drains/refills
and IPI overhead for global drains.  The main obstacle to removal is that
without those lists the zone->lock becomes very heavily contended and
alternatives are inevitably going to share cache lines. I prototyped a
potential replacement on the flight home and then left it on a TODO list
for another year.

Last LSF/MM this was talked about in the hallway again although the meat
of the discussion was different and took into account Andi Kleen's talk
about lock batching. On this flight home, I rebased the old prototype,
added some additional bits and pieces and tidied it up a bit since. This
TODO item is about 3 years old so apparently sometimes the only way to
get someone to do something is to lock them in a metal box for a few hours.

This is a prototype replacement starts with some minor optimisations that
have nothing to do with anything really other than they were floating around
from another flights worth of work.  It then replaces the per-cpu page
allocator with an IRQ-unsafe (no interrupts, no calls with local_irq_save)
magazine that is protected by a spinlock. This effectively has the allocator
use two locks. magazine_lock for non-IRQ users (e.g. page faults) and the
zone->lock for magazine drains/refills and users who have IRQs disabled
(interrupts, slab). It then splits the magazine into two where the preferred
magazine depends on the CPU id of the executing thread. Non-preferred
magazines may also be used and are searched round-robin as they are only
protected by spinlocks. The last part of the series does some mucking
around with lock contention and batching multiple frees due to exit or
compaction under the lock.

It has not been heavily tested in low memory, heavy interrupt situations
or extensively with all the debugging options enabled so it's likely
there are bugs hiding in there. However I'm interested in hearing if
the per-cpu page allocator is something we really want to replace or if
there is a better potential alternative than this prototype. There are
some interesting possibilities with this sort of design. For example, it
would be possible to allocate magazines to allocator-intensive processes
that are chained together for global drains where they are necessary. For
these processes there would be much less contention (only on drains/refills)
without having to use IPIs to drain their pages.

In the follow tests, no debugging was enabled but profiling was running
so the tests are heavily disrupted. Take the results with a grain of
salt. Machine was a single socket i7 with 16G RAM.

kernbench
                               3.9.0                 3.9.0
                             vanilla    magazine
User    min         883.59 (  0.00%)      700.16 ( 20.76%)
User    mean        891.11 (  0.00%)      741.02 ( 16.84%)
User    stddev       12.14 (  0.00%)       50.04 (-312.18%)
User    max         915.30 (  0.00%)      817.50 ( 10.69%)
User    range        31.71 (  0.00%)      117.34 (-270.04%)
System  min          58.85 (  0.00%)       43.65 ( 25.83%)
System  mean         59.65 (  0.00%)       47.65 ( 20.12%)
System  stddev        1.35 (  0.00%)        4.79 (-254.39%)
System  max          62.35 (  0.00%)       55.35 ( 11.23%)
System  range         3.50 (  0.00%)       11.70 (-234.29%)
Elapsed min         127.75 (  0.00%)       99.37 ( 22.22%)
Elapsed mean        129.19 (  0.00%)      105.73 ( 18.16%)
Elapsed stddev        2.07 (  0.00%)        7.56 (-265.78%)
Elapsed max         133.25 (  0.00%)      117.53 ( 11.80%)
Elapsed range         5.50 (  0.00%)       18.16 (-230.18%)
CPU     min         731.00 (  0.00%)      742.00 ( -1.50%)
CPU     mean        735.20 (  0.00%)      745.60 ( -1.41%)
CPU     stddev        2.99 (  0.00%)        3.38 (-12.99%)
CPU     max         739.00 (  0.00%)      751.00 ( -1.62%)
CPU     range         8.00 (  0.00%)        9.00 (-12.50%)

Kernel build benchmark seemed fairly successful, if anything they seem
too good and I suspect this might have been a particularly "lucky" run.
A non-profiling run might reveal more.


pagealloc
                                               3.9.0                      3.9.0
                                             vanilla         magazine
order-0 alloc-1                     671.11 (  0.00%)           734.11 ( -9.39%)
order-0 alloc-2                     520.33 (  0.00%)           517.56 (  0.53%)
order-0 alloc-4                     426.56 (  0.00%)           461.78 ( -8.26%)
order-0 alloc-8                     666.33 (  0.00%)           381.67 ( 42.72%)
order-0 alloc-16                    341.78 (  0.00%)           354.44 ( -3.71%)
order-0 alloc-32                    336.89 (  0.00%)           345.33 ( -2.51%)
order-0 alloc-64                    331.33 (  0.00%)           324.56 (  2.05%)
order-0 alloc-128                   324.56 (  0.00%)           325.89 ( -0.41%)
order-0 alloc-256                   350.44 (  0.00%)           326.22 (  6.91%)
order-0 alloc-512                   369.33 (  0.00%)           345.67 (  6.41%)
order-0 alloc-1024                  381.44 (  0.00%)           352.67 (  7.54%)
order-0 alloc-2048                  387.50 (  0.00%)           348.00 ( 10.19%)
order-0 alloc-4096                  403.00 (  0.00%)           384.50 (  4.59%)
order-0 alloc-8192                  413.00 (  0.00%)           383.00 (  7.26%)
order-0 alloc-16384                 411.00 (  0.00%)           396.80 (  3.45%)
order-0 free-1                      357.22 (  0.00%)           458.89 (-28.46%)
order-0 free-2                      285.11 (  0.00%)           349.89 (-22.72%)
order-0 free-4                      231.33 (  0.00%)           296.00 (-27.95%)
order-0 free-8                      371.56 (  0.00%)           229.33 ( 38.28%)
order-0 free-16                     189.78 (  0.00%)           212.89 (-12.18%)
order-0 free-32                     185.67 (  0.00%)           206.11 (-11.01%)
order-0 free-64                     178.44 (  0.00%)           197.78 (-10.83%)
order-0 free-128                    178.11 (  0.00%)           197.00 (-10.61%)
order-0 free-256                    227.89 (  0.00%)           196.56 ( 13.75%)
order-0 free-512                    280.11 (  0.00%)           194.67 ( 30.50%)
order-0 free-1024                   301.67 (  0.00%)           227.50 ( 24.59%)
order-0 free-2048                   325.50 (  0.00%)           238.00 ( 26.88%)
order-0 free-4096                   328.00 (  0.00%)           278.25 ( 15.17%)
order-0 free-8192                   337.50 (  0.00%)           277.00 ( 17.93%)
order-0 free-16384                  338.00 (  0.00%)           285.20 ( 15.62%)
order-0 total-1                    1031.89 (  0.00%)          1197.22 (-16.02%)
order-0 total-2                     805.44 (  0.00%)           867.44 ( -7.70%)
order-0 total-4                     657.89 (  0.00%)           768.67 (-16.84%)
order-0 total-8                    1039.56 (  0.00%)           611.00 ( 41.22%)
order-0 total-16                    531.56 (  0.00%)           569.33 ( -7.11%)
order-0 total-32                    523.44 (  0.00%)           551.44 ( -5.35%)
order-0 total-64                    509.78 (  0.00%)           522.89 ( -2.57%)
order-0 total-128                   502.67 (  0.00%)           522.89 ( -4.02%)
order-0 total-256                   579.56 (  0.00%)           522.78 (  9.80%)
order-0 total-512                   649.44 (  0.00%)           540.33 ( 16.80%)
order-0 total-1024                  686.44 (  0.00%)           580.17 ( 15.48%)
order-0 total-2048                  713.00 (  0.00%)           586.00 ( 17.81%)
order-0 total-4096                  731.00 (  0.00%)           663.75 (  9.20%)
order-0 total-8192                  750.50 (  0.00%)           660.00 ( 12.06%)
order-0 total-16384                 749.00 (  0.00%)           683.00 (  8.81%)

This is a systemtap-drive page allocator microbenchmark that allocates
order-0 pages in increasingly large "batches" and times the length of
time it takes to allocate and free. The results are a bit all over the
map. Frees are slower because they always wait for the preferred magazine
to be free and freeing single pages in a loop is a worst-case scenario.
For larger patches it tends to perform reasonably well though.

pft
                             3.9.0                 3.9.0
                           vanilla               magazine
Faults/cpu 1  953441.5530 (  0.00%)  954011.8576 (  0.06%)
Faults/cpu 2  923793.1533 (  0.00%)  889436.7293 ( -3.72%)
Faults/cpu 3  876829.2292 (  0.00%)  868230.6471 ( -0.98%)
Faults/cpu 4  819914.9333 (  0.00%)  735264.4793 (-10.32%)
Faults/cpu 5  689049.0107 (  0.00%)  663481.5446 ( -3.71%)
Faults/cpu 6  579924.4065 (  0.00%)  571889.3687 ( -1.39%)
Faults/cpu 7  552024.1040 (  0.00%)  494345.8698 (-10.45%)
Faults/cpu 8  461452.7560 (  0.00%)  457877.1810 ( -0.77%)
Faults/sec 1  938245.7112 (  0.00%)  939198.4047 (  0.10%)
Faults/sec 2 1814498.4087 (  0.00%) 1748800.3800 ( -3.62%)
Faults/sec 3 2544466.6368 (  0.00%) 2359068.2163 ( -7.29%)
Faults/sec 4 3032778.8584 (  0.00%) 2831753.6553 ( -6.63%)
Faults/sec 5 3025180.2736 (  0.00%) 2952758.4589 ( -2.39%)
Faults/sec 6 3131131.0106 (  0.00%) 3058954.4941 ( -2.31%)
Faults/sec 7 3286271.0631 (  0.00%) 3183931.7940 ( -3.11%)
Faults/sec 8 3135331.0027 (  0.00%) 3106746.5908 ( -0.91%)

This is a page faulting microbenchmark that is forced to use base pages only.
Here the new design suffers a bit because the allocation path is likely
to contend on the magazine lock.

So preliminary testing indicates the results are mixed bag. As long as
locks are not contended, it performs fine but parallel fault testing
hits into spinlock contention on the magazine locks. A greater problem
is that because CPUs share magazines it means that the struct pages are
frequently dirtied cache lines. If CPU A frees a page to a magazine and
CPU B immediately allocates it then the cache line for the page and the
magazine bounces and this costs. It's on the TODO list to research if the
available literature has anything useful to say that does not depend on
per-cpu lists and the associated problems with them.

Comments?

 arch/sparc/mm/init_64.c        |    4 +-
 arch/sparc/mm/tsb.c            |    2 +-
 arch/tile/mm/homecache.c       |    2 +-
 fs/fuse/dev.c                  |    2 +-
 include/linux/gfp.h            |   12 +-
 include/linux/mm.h             |    3 -
 include/linux/mmzone.h         |   46 +-
 include/linux/page-isolation.h |    7 +-
 include/linux/pagemap.h        |    2 +-
 include/linux/swap.h           |    2 +-
 include/trace/events/kmem.h    |   22 +-
 init/main.c                    |    1 -
 kernel/power/snapshot.c        |    2 -
 kernel/sysctl.c                |   10 -
 mm/compaction.c                |   18 +-
 mm/memory-failure.c            |    2 +-
 mm/memory_hotplug.c            |   13 +-
 mm/page_alloc.c                | 1109 +++++++++++++++++-----------------------
 mm/page_isolation.c            |   30 +-
 mm/rmap.c                      |    2 +-
 mm/swap.c                      |    6 +-
 mm/swap_state.c                |    2 +-
 mm/vmscan.c                    |    6 +-
 mm/vmstat.c                    |   54 +-
 24 files changed, 571 insertions(+), 788 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
