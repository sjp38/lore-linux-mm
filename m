Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A7CA8900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 06:41:42 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/12] Swap-over-NBD without deadlocking v1
Date: Thu, 14 Apr 2011 11:41:26 +0100
Message-Id: <1302777698-28237-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

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

Patches 6-9 allows network processing to use PFMEMALLOC reserves when
	the socket has been marked as being used by the VM to clean
	pages. If packets are received and stored in pages that were
	allocated under low-memory situations and are unrelated to
	the VM, the packets are dropped.

Patch 10 is a micro-optimisation to avoid a function call in the
	common case.

Patch 11 tags NBD sockets as being SOCK_MEMALLOC so they can use
	PFMEMALLOC if necessary.

Patch 12 notes that it is still possible for the PFMEMALLOC reserve
	to be depleted. To prevent this, direct reclaimers get
	throttled on a waitqueue if 50% of the PFMEMALLOC reserves are
	depleted.  It is expected that kswapd and the direct reclaimers
	already running will clean enough pages for the low watermark
	to be reached and the throttled processes are woken up.

Some basic performance testing was run using kernel builds, netperf
on loopback for UDP and TCP, hackbench (pipes and sockets), iozone
and sysbench. Each of them were expected to use the sl*b allocators
reasonably heavily but there did not appear to be significant
performance variances. Here is the results from netperf using
slab as an example

NETPERF UDP
                   netperf-udp       udp-swapnbd
                  vanilla-slab        v1r17-slab
      64   178.06 ( 0.00%)*   189.46 ( 6.02%) 
             1.02%             1.00%        
     128   355.06 ( 0.00%)    370.75 ( 4.23%) 
     256   662.47 ( 0.00%)    721.62 ( 8.20%) 
    1024  2229.39 ( 0.00%)   2567.04 (13.15%) 
    2048  3974.20 ( 0.00%)   4114.70 ( 3.41%) 
    3312  5619.89 ( 0.00%)   5800.09 ( 3.11%) 
    4096  6460.45 ( 0.00%)   6702.45 ( 3.61%) 
    8192  9580.24 ( 0.00%)   9927.97 ( 3.50%) 
   16384 13259.14 ( 0.00%)  13493.88 ( 1.74%) 
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       2960.17   2540.14
Total Elapsed Time (seconds)               3554.10   3050.10

NETPERF TCP
                   netperf-tcp       tcp-swapnbd
                  vanilla-slab        v1r17-slab
      64  1230.29 ( 0.00%)   1273.17 ( 3.37%) 
     128  2309.97 ( 0.00%)   2375.22 ( 2.75%) 
     256  3659.32 ( 0.00%)   3704.87 ( 1.23%) 
    1024  7267.80 ( 0.00%)   7251.02 (-0.23%) 
    2048  8358.26 ( 0.00%)   8204.74 (-1.87%) 
    3312  8631.07 ( 0.00%)   8637.62 ( 0.08%) 
    4096  8770.95 ( 0.00%)   8704.08 (-0.77%) 
    8192  9749.33 ( 0.00%)   9769.06 ( 0.20%) 
   16384 11151.71 ( 0.00%)  11135.32 (-0.15%) 
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1245.04   1619.89
Total Elapsed Time (seconds)               1250.66   1622.18

Here is the equivalent test for SLUB

NETPERF UDP
                   netperf-udp       udp-swapnbd
                  vanilla-slub        v1r17-slub
      64   180.83 ( 0.00%)    183.68 ( 1.55%) 
     128   357.29 ( 0.00%)    367.11 ( 2.67%) 
     256   679.64 ( 0.00%)*   724.03 ( 6.13%) 
             1.15%             1.00%        
    1024  2343.40 ( 0.00%)*  2610.63 (10.24%) 
             1.68%             1.00%        
    2048  3971.53 ( 0.00%)   4102.21 ( 3.19%)*
             1.00%             1.40%        
    3312  5677.04 ( 0.00%)   5748.69 ( 1.25%) 
    4096  6436.75 ( 0.00%)   6549.41 ( 1.72%) 
    8192  9698.56 ( 0.00%)   9808.84 ( 1.12%) 
   16384 13337.06 ( 0.00%)  13404.38 ( 0.50%) 
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       2880.15   2180.13
Total Elapsed Time (seconds)               3458.10   2618.09

NETPERF TCP
                   netperf-tcp       tcp-swapnbd
                  vanilla-slub        v1r17-slub
      64  1256.79 ( 0.00%)   1287.32 ( 2.37%) 
     128  2308.71 ( 0.00%)   2371.09 ( 2.63%) 
     256  3672.03 ( 0.00%)   3771.05 ( 2.63%) 
    1024  7245.08 ( 0.00%)   7261.60 ( 0.23%) 
    2048  8315.17 ( 0.00%)   8244.14 (-0.86%) 
    3312  8611.43 ( 0.00%)   8616.90 ( 0.06%) 
    4096  8711.64 ( 0.00%)   8695.97 (-0.18%) 
    8192  9795.71 ( 0.00%)   9774.11 (-0.22%) 
   16384 11145.48 ( 0.00%)  11225.70 ( 0.71%) 
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1345.05   1425.06
Total Elapsed Time (seconds)               1350.61   1430.66

Time to completion varied a lot but this can happen with netperf as
it tries to find results within a sufficiently high confidence. I
wouldn't read too much into the performance gains of netperf-udp
as it can sometimes be affected by code just shuffling around for
whatever reason.

For testing swap-over-NBD, a machine was booted with 2G of RAM with a
swapfile backed by NBD. 16*NUM_CPU processes were started that create
anonymous memory mappings and read them linearly in a loop. The total
size of the mappings were 4*PHYSICAL_MEMORY to use swap heavily under
memory pressure. Without the patches, the machine locks up within
minutes and runs to completion with them applied.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
