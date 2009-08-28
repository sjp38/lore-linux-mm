Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 58C996B009E
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 04:44:26 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/3] Reduce searching in the page allocator fast-path
Date: Fri, 28 Aug 2009 09:44:25 +0100
Message-Id: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The following two patches remove searching in the page allocator fast-path
by maintaining multiple free-lists in the per-cpu structure. At the time the
search was introduced, increasing the per-cpu structures would waste a lot of
memory as per-cpu structures were statically allocated at compile-time. This
is no longer the case.

The patches are as follows. They are based on mmotm-2009-08-27.

Patch 1 adds multiple lists to struct per_cpu_pages, one per
	migratetype that can be stored on the PCP lists.

Patch 2 notes that the pcpu drain path check empty lists multiple times. The
	patch reduces the number of checks by maintaining a count of free
	lists encountered. Lists containing pages will then free multiple
	pages in batch

The patches were tested with kernbench, netperf udp/tcp, hackbench and
sysbench.  The netperf tests were not bound to any CPU in particular and
were run such that the results should be 99% confidence that the reported
results are within 1% of the estimated mean. sysbench was run with a postgres
background and read-only tests. Similar to netperf, it was run multiple
times so that it's 99% confidence results are within 1%. The patches were
tested on x86, x86-64 and ppc64 as

x86:	Intel Pentium D 3GHz with 8G RAM (no-brand machine)
	kernbench	- No significant difference, variance well within noise
	netperf-udp	- 1.34% to 2.28% gain
	netperf-tcp	- 0.45% to 1.22% gain
	hackbench	- Small variances, very close to noise
	sysbench	- Very small gains

x86-64:	AMD Phenom 9950 1.3GHz with 8G RAM (no-brand machine)
	kernbench	- No significant difference, variance well within noise
	netperf-udp	- 1.83% to 10.42% gains
	netperf-tcp	- No conclusive until buffer >= PAGE_SIZE
				4096	+15.83%
				8192	+ 0.34% (not significant)
				16384	+ 1%
	hackbench	- Small gains, very close to noise
	sysbench	- 0.79% to 1.6% gain

ppc64:	PPC970MP 2.5GHz with 10GB RAM (it's a terrasoft powerstation)
	kernbench	- No significant difference, variance well within noise
	netperf-udp	- 2-3% gain for almost all buffer sizes tested
	netperf-tcp	- losses on small buffers, gains on larger buffers
			  possibly indicates some bad caching effect.
	hackbench	- No significant difference
	sysbench	- 2-4% gain

 include/linux/mmzone.h |    5 ++-
 mm/page_alloc.c        |  119 +++++++++++++++++++++++++++--------------------
 2 files changed, 72 insertions(+), 52 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
