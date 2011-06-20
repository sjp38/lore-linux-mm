Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5F9B66B00EA
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:12:27 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/14] Swap-over-NBD without deadlocking v5
Date: Mon, 20 Jun 2011 14:12:06 +0100
Message-Id: <1308575540-25219-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Changelog since V4
  o Update comment clarifying what protocols can be used		(Michal)
  o Rebase to 3.0-rc3

Changelog since V3
  o Propogate pfmemalloc from packet fragment pages to skb		(Neil)
  o Rebase to 3.0-rc2

Changelog since V2
  o Document that __GFP_NOMEMALLOC overrides __GFP_MEMALLOC		(Neil)
  o Use wait_event_interruptible					(Neil)
  o Use !! when casting to bool to avoid any possibilitity of type
    truncation								(Neil)
  o Nicer logic when using skb_pfmemalloc_protocol			(Neil)

Changelog since V1
  o Rebase on top of mmotm
  o Use atomic_t for memalloc_socks		(David Miller)
  o Remove use of sk_memalloc_socks in vmscan	(Neil Brown)
  o Check throttle within prepare_to_wait	(Neil Brown)
  o Add statistics on throttling instead of printk

Swapping over NBD is something that is technically possible but not
often advised. While there are number of guides on the internet
on how to configure it and nbd-client supports a -swap switch to
"prevent deadlocks", the fact of the matter is a machine using NBD
for swap can be locked up within minutes if swap is used intensively.

The problem is that network block devices do not use mempools like
normal block devices do. As the host cannot control where they receive
packets from, they cannot reliably work out in advance how much memory
they might need.

Some years ago, Peter Ziljstra developed a series of patches that
supported swap over an NFS that some distributions are carrying in
their kernels. This patch series borrows very heavily from Peter's work
to support swapping over NBD (the relatively straight-forward case)
and uses throttling instead of dynamically resized memory reserves
so the series is not too unwieldy for review.

Patch 1 serialises access to min_free_kbytes. It's not strictly needed
	by this series but as the series cares about watermarks in
	general, it's a harmless fix. It could be merged independently.

Patch 2 adds knowledge of the PFMEMALLOC reserves to SLAB and SLUB to
	preserve access to pages allocated under low memory situations
	to callers that are freeying memory.

Patch 3 introduces __GFP_MEMALLOC to allow access to the PFMEMALLOC
	reserves without setting PFMEMALLOC.

Patch 4 opens the possibility for softirqs to use PFMEMALLOC reserves
	for later use by network packet processing.

Patch 5 ignores memory policies when ALLOC_NO_WATERMARKS is set.

Patches 6-10 allows network processing to use PFMEMALLOC reserves when
	the socket has been marked as being used by the VM to clean
	pages. If packets are received and stored in pages that were
	allocated under low-memory situations and are unrelated to
	the VM, the packets are dropped.

Patch 11 is a micro-optimisation to avoid a function call in the
	common case.

Patch 12 tags NBD sockets as being SOCK_MEMALLOC so they can use
	PFMEMALLOC if necessary.

Patch 13 notes that it is still possible for the PFMEMALLOC reserve
	to be depleted. To prevent this, direct reclaimers get
	throttled on a waitqueue if 50% of the PFMEMALLOC reserves are
	depleted.  It is expected that kswapd and the direct reclaimers
	already running will clean enough pages for the low watermark
	to be reached and the throttled processes are woken up.

Patch 14 adds a statistic to track how often processes get throttled

Some basic performance testing was run using kernel builds, netperf
on loopback for UDP and TCP, hackbench (pipes and sockets), iozone
and sysbench. Each of them were expected to use the sl*b allocators
reasonably heavily but there did not appear to be significant
performance variances. Here is the results from netperf using
slab as an example

NETPERF UDP
      64   237.47 ( 0.00%)    237.34 (-0.05%) 
     128   472.69 ( 0.00%)    465.96 (-1.44%) 
     256   926.82 ( 0.00%)    948.40 ( 2.28%) 
    1024  3260.08 ( 0.00%)   3266.50 ( 0.20%) 
    2048  5535.11 ( 0.00%)   5453.55 (-1.50%) 
    3312  7496.60 ( 0.00%)*  7574.44 ( 1.03%) 
             1.12%             1.00%        
    4096  8266.35 ( 0.00%)*  8240.06 (-0.32%)*
             1.18%             1.49%        
    8192 11026.01 ( 0.00%)  11010.44 (-0.14%) 
   16384 14653.98 ( 0.00%)  14666.97 ( 0.09%) 
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       2156.64   1873.27
Total Elapsed Time (seconds)               2570.09   2234.10

NETPERF TCP
                   netperf-tcp       tcp-swapnbd
                  vanilla-slab         v4r3-slab
      64  1250.76 ( 0.00%)   1256.52 ( 0.46%) 
     128  2290.70 ( 0.00%)   2336.43 ( 1.96%) 
     256  3668.42 ( 0.00%)   3751.17 ( 2.21%) 
    1024  7214.33 ( 0.00%)   7237.23 ( 0.32%) 
    2048  8230.01 ( 0.00%)   8280.02 ( 0.60%) 
    3312  8634.95 ( 0.00%)   8758.62 ( 1.41%) 
    4096  8851.18 ( 0.00%)   9045.88 ( 2.15%) 
    8192 10067.59 ( 0.00%)  10263.30 ( 1.91%) 
   16384 11523.26 ( 0.00%)  11654.78 ( 1.13%) 
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1450.23    1389.8
Total Elapsed Time (seconds)               1450.41   1390.35

Here is the equivalent test for SLUB

                   netperf-udp       udp-swapnbd
                  vanilla-slub         v4r3-slub
      64   235.33 ( 0.00%)    237.80 ( 1.04%) 
     128   465.92 ( 0.00%)    469.98 ( 0.86%) 
     256   907.16 ( 0.00%)    907.58 ( 0.05%) 
    1024  3240.25 ( 0.00%)   3255.56 ( 0.47%) 
    2048  5564.87 ( 0.00%)   5446.46 (-2.17%) 
    3312  7427.65 ( 0.00%)*  7650.00 ( 2.91%) 
             1.33%             1.00%        
    4096  8004.51 ( 0.00%)*  8132.79 ( 1.58%)*
             1.05%             1.21%        
    8192 11079.60 ( 0.00%)  10927.09 (-1.40%) 
   16384 14737.38 ( 0.00%)  15019.50 ( 1.88%) 
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       2056.21   2160.38
Total Elapsed Time (seconds)               2426.09   2498.16

NETPERF TCP
                   netperf-tcp       tcp-swapnbd
                  vanilla-slub         v4r3-slub
      64  1251.64 ( 0.00%)   1262.89 ( 0.89%) 
     128  2289.88 ( 0.00%)   2332.94 ( 1.85%) 
     256  3654.34 ( 0.00%)   3736.48 ( 2.20%) 
    1024  7192.47 ( 0.00%)   7286.96 ( 1.30%) 
    2048  8243.55 ( 0.00%)   8291.50 ( 0.58%) 
    3312  8664.16 ( 0.00%)   8799.88 ( 1.54%) 
    4096  8869.13 ( 0.00%)   9018.12 ( 1.65%) 
    8192 10009.53 ( 0.00%)  10214.26 ( 2.00%) 
   16384 11470.78 ( 0.00%)  11685.20 ( 1.83%) 
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1368.28   1511.81
Total Elapsed Time (seconds)               1370.33   1510.42

Time to completion varied a lot but this can happen with netperf as
it tries to find results within a sufficiently high confidence. There
were some small gains and losses but they are close to the variances
seen between kernel releases.

For testing swap-over-NBD, a machine was booted with 2G of RAM with a
swapfile backed by NBD. 8*NUM_CPU processes were started that create
anonymous memory mappings and read them linearly in a loop. The total
size of the mappings were 4*PHYSICAL_MEMORY to use swap heavily under
memory pressure. Without the patches, the machine locks up within
minutes and runs to completion with them applied.

 drivers/block/nbd.c             |    7 +-
 include/linux/gfp.h             |   13 ++-
 include/linux/mm_types.h        |    8 ++
 include/linux/mmzone.h          |    1 +
 include/linux/sched.h           |    7 +
 include/linux/skbuff.h          |   21 +++-
 include/linux/slub_def.h        |    1 +
 include/linux/vm_event_item.h   |    1 +
 include/net/sock.h              |   19 +++
 include/trace/events/gfpflags.h |    1 +
 kernel/softirq.c                |    3 +
 mm/page_alloc.c                 |   57 +++++++--
 mm/slab.c                       |  240 +++++++++++++++++++++++++++++++++------
 mm/slub.c                       |   33 +++++-
 mm/vmscan.c                     |   55 +++++++++
 mm/vmstat.c                     |    1 +
 net/core/dev.c                  |   48 +++++++-
 net/core/filter.c               |    8 ++
 net/core/skbuff.c               |   95 +++++++++++++---
 net/core/sock.c                 |   42 +++++++
 net/ipv4/tcp.c                  |    3 +-
 net/ipv4/tcp_output.c           |   13 +-
 net/ipv6/tcp_ipv6.c             |   12 ++-
 23 files changed, 602 insertions(+), 87 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
