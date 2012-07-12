Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 894176B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:38 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/16] Swap-over-NBD without deadlocking V15
Date: Thu, 12 Jul 2012 07:40:16 +0100
Message-Id: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

This is a rebase onto current linux-next due to a minor collision with
some NFS changes.

Changelog since V14
  o Rebase to linux-next 20120710

Changelog since V13
  o Rebase to linux-next 20120629

Changelog since V12
  o Rebase to linux-next-20120622
  o Do not alter coalesce handling in the input path		      (eric.dumazet)
  o Avoid unnecessary cast					      (sebastian)

Changelog since V11
  o Rebase to 3.5-rc3
  o Correct order of page flag free				      (sebastian)

Changelog since V10
  o Rebase to 3.4-rc5
  o Coding style fixups						      (davem)
  o API consistency						      (davem)
  o Rename sk_allocation to sk_gfp_atomic and use only when necessary (davem)
  o Use static branches for sk_memalloc_socks			      (davem)
  o Use static branch checks in fast paths			      (davem)
  o Document concerns about PF_MEMALLOC leaking flags		      (davem)
  o Locking fix in slab						      (mel)

Changelog since V9
  o Rebase to 3.4-rc5
  o Clarify comment on why PF_MEMALLOC is cleared in softirq handling (akpm)
  o Only set page->pfmemalloc if ALLOC_NO_WATERMARKS was required     (rientjes)

Changelog since V8
  o Rebase to 3.4-rc2
  o Use page flag instead of slab fields to keep structures the same size
  o Properly detect allocations from softirq context that use PF_MEMALLOC
  o Ensure kswapd does not sleep while processes are throttled
  o Do not accidentally throttle !_GFP_FS processes indefinitely

Changelog since V7
  o Rebase to 3.3-rc2
  o Take greater care propagating page->pfmemalloc to skb
  o Propagate pfmemalloc from netdev_alloc_page to skb where possible
  o Release RCU lock properly on preempt kernel

Changelog since V6
  o Rebase to 3.1-rc8
  o Use wake_up instead of wake_up_interruptible()
  o Do not throttle kernel threads
  o Avoid a potential race between kswapd going to sleep and processes being
    throttled

Changelog since V5
  o Rebase to 3.1-rc5

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

When a user or administrator requires swap for their application, they
create a swap partition and file, format it with mkswap and activate it
with swapon. Swap over the network is considered as an option in diskless
systems. The two likely scenarios are when blade servers are used as part
of a cluster where the form factor or maintenance costs do not allow the
use of disks and thin clients.

The Linux Terminal Server Project recommends the use of the
Network Block Device (NBD) for swap according to the manual at
https://sourceforge.net/projects/ltsp/files/Docs-Admin-Guide/LTSPManual.pdf/download
There is also documentation and tutorials on how to setup swap over NBD
at places like https://help.ubuntu.com/community/UbuntuLTSP/EnableNBDSWAP
The nbd-client also documents the use of NBD as swap. Despite this, the
fact is that a machine using NBD for swap can deadlock within minutes if
swap is used intensively. This patch series addresses the problem.

The core issue is that network block devices do not use mempools like
normal block devices do. As the host cannot control where they receive
packets from, they cannot reliably work out in advance how much memory
they might need. Some years ago, Peter Zijlstra developed a series of
patches that supported swap over an NFS that at least one distribution
is carrying within their kernels. This patch series borrows very heavily
from Peter's work to support swapping over NBD as a pre-requisite to
supporting swap-over-NFS. The bulk of the complexity is concerned with
preserving memory that is allocated from the PFMEMALLOC reserves for use
by the network layer which is needed for both NBD and NFS.

Patch 1 adds knowledge of the PFMEMALLOC reserves to SLAB and SLUB to
	preserve access to pages allocated under low memory situations
	to callers that are freeing memory.

Patch 2 optimises the SLUB fast path to avoid pfmemalloc checks

Patch 3 introduces __GFP_MEMALLOC to allow access to the PFMEMALLOC
	reserves without setting PFMEMALLOC.

Patch 4 opens the possibility for softirqs to use PFMEMALLOC reserves
	for later use by network packet processing.

Patch 5 only sets page->pfmemalloc when ALLOC_NO_WATERMARKS was required

Patch 6 ignores memory policies when ALLOC_NO_WATERMARKS is set.

Patches 7-12 allows network processing to use PFMEMALLOC reserves when
	the socket has been marked as being used by the VM to clean pages. If
	packets are received and stored in pages that were allocated under
	low-memory situations and are unrelated to the VM, the packets
	are dropped.

	Patch 11 reintroduces __skb_alloc_page which the networking
	folk may object to but is needed in some cases to propogate
	pfmemalloc from a newly allocated page to an skb. If there is a
	strong objection, this patch can be dropped with the impact being
	that swap-over-network will be slower in some cases but it should
	not fail.

Patch 13 is a micro-optimisation to avoid a function call in the
	common case.

Patch 14 tags NBD sockets as being SOCK_MEMALLOC so they can use
	PFMEMALLOC if necessary.

Patch 15 notes that it is still possible for the PFMEMALLOC reserve
	to be depleted. To prevent this, direct reclaimers get throttled on
	a waitqueue if 50% of the PFMEMALLOC reserves are depleted.  It is
	expected that kswapd and the direct reclaimers already running
	will clean enough pages for the low watermark to be reached and
	the throttled processes are woken up.

Patch 16 adds a statistic to track how often processes get throttled

Some basic performance testing was run using kernel builds, netperf
on loopback for UDP and TCP, hackbench (pipes and sockets), iozone
and sysbench. Each of them were expected to use the sl*b allocators
reasonably heavily but there did not appear to be significant
performance variances.

For testing swap-over-NBD, a machine was booted with 2G of RAM with a
swapfile backed by NBD. 8*NUM_CPU processes were started that create
anonymous memory mappings and read them linearly in a loop. The total
size of the mappings were 4*PHYSICAL_MEMORY to use swap heavily under
memory pressure.

Without the patches and using SLUB, the machine locks up within minutes and
runs to completion with them applied. With SLAB, the story is different
as an unpatched kernel run to completion. However, the patched kernel
completed the test 45% faster.

MICRO
                                         3.5.0-rc2 3.5.0-rc2
					 vanilla     swapnbd
Unrecognised test vmscan-anon-mmap-write
MMTests Statistics: duration
Sys Time Running Test (seconds)             197.80    173.07
User+Sys Time Running Test (seconds)        206.96    182.03
Total Elapsed Time (seconds)               3240.70   1762.09

 drivers/block/nbd.c                               |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c          |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c        |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    3 +-
 drivers/net/usb/cdc-phonet.c                      |    2 +-
 drivers/usb/gadget/f_phonet.c                     |    2 +-
 include/linux/gfp.h                               |   13 +-
 include/linux/mm_types.h                          |    9 +
 include/linux/mmzone.h                            |    1 +
 include/linux/page-flags.h                        |   28 +++
 include/linux/sched.h                             |    7 +
 include/linux/skbuff.h                            |   80 +++++++-
 include/linux/vm_event_item.h                     |    1 +
 include/net/sock.h                                |   28 +++
 include/trace/events/gfpflags.h                   |    1 +
 kernel/softirq.c                                  |    9 +
 mm/page_alloc.c                                   |   46 ++++-
 mm/slab.c                                         |  216 +++++++++++++++++++--
 mm/slub.c                                         |   30 ++-
 mm/vmscan.c                                       |  131 ++++++++++++-
 mm/vmstat.c                                       |    1 +
 net/core/dev.c                                    |   53 ++++-
 net/core/filter.c                                 |    8 +
 net/core/skbuff.c                                 |  124 +++++++++---
 net/core/sock.c                                   |   43 ++++
 net/ipv4/tcp_output.c                             |   12 +-
 net/ipv6/tcp_ipv6.c                               |    8 +-
 29 files changed, 782 insertions(+), 90 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
