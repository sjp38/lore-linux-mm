Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0E5B56B0099
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 03:57:21 -0400 (EDT)
Subject: Re: [PATCH 00/22] Cleanup and optimise the page allocator V7
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 27 Apr 2009 15:58:39 +0800
Message-Id: <1240819119.2567.884.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-22 at 14:53 +0100, Mel Gorman wrote:
> Here is V7 of the cleanup and optimisation of the page allocator and
> it should be ready for wider testing. Please consider a possibility for
> merging as a Pass 1 at making the page allocator faster. Other passes will
> occur later when this one has had a bit of exercise. This patchset is based
> on mmotm-2009-04-17 and I've tested it successfully on a small number of
> machines.
We ran some performance benchmarks against V7 patch on top of 2.6.30-rc3.
It seems some counters in kernel are incorrect after we run some ffsb (disk I/O benchmark)
and swap-cp (a simple swap memory testing by cp on tmpfs). Free memory is bigger than
total memory.

[ymzhang@lkp-st02-x8664 ~]$ uname -a
Linux lkp-st02-x8664 2.6.30-rc3-mgpage #1 SMP Thu Apr 23 16:09:43 CST 2009 x86_64 x86_64 x86_64 GNU/Linux
[ymzhang@lkp-st02-x8664 ~]$ free
             total       used       free     shared    buffers     cached
Mem:       8166564 18014398497625640   20022908          0    2364424     247224
-/+ buffers/cache: 18014398495013992   22634556
Swap:            0          0          0
[ymzhang@lkp-st02-x8664 ~]$ cat /proc/meminfo 
MemTotal:        8166564 kB
MemFree:        20022916 kB
Buffers:         2364424 kB
Cached:           247224 kB
SwapCached:            0 kB
Active:          2414520 kB
Inactive:         206168 kB
Active(anon):       4316 kB
Inactive(anon):     4932 kB
Active(file):    2410204 kB
Inactive(file):   201236 kB



[ymzhang@lkp-ne01 ~]$ uname -a
Linux lkp-ne01 2.6.30-rc3-mgpage #1 SMP Thu Apr 23 15:04:27 CST 2009 x86_64 x86_64 x86_64 GNU/Linux
[ymzhang@lkp-ne01 ~]$ free
             total       used       free     shared    buffers     cached
Mem:       6116356 18014398509340432    6257908          0     609804    1053512
-/+ buffers/cache: 18014398507677116    7921224
Swap:     15631204          0   15631204
[ymzhang@lkp-ne01 ~]$ cat /proc/meminfo 
MemTotal:        6116356 kB
MemFree:         6257948 kB
Buffers:          609804 kB
Cached:          1053512 kB
SwapCached:            0 kB
Active:           723152 kB



Or a simple kernel source cp/rm/cp:
[ymzhang@lkp-ne01 linux-2.6.30-rc3_melgorman]$ uname -a
Linux lkp-ne01 2.6.30-rc3-mgpage #1 SMP Thu Apr 23 15:04:27 CST 2009 x86_64 x86_64 x86_64 GNU/Linux
[ymzhang@lkp-ne01 linux-2.6.30-rc3_melgorman]$ free
             total       used       free     shared    buffers     cached
Mem:       6116356    1309940    4806416          0      82184    1259072
-/+ buffers/cache: 18014398509450668    6147672
Swap:     15631204          0   15631204
[ymzhang@lkp-ne01 linux-2.6.30-rc3_melgorman]$ cat /proc/meminfo 
MemTotal:        6116356 kB
MemFree:         4806724 kB
Buffers:           82184 kB
Cached:          1259072 kB
SwapCached:            0 kB
Active:           477396 kB
Inactive:         872388 kB
Active(anon):       8704 kB
Inactive(anon):        0 kB
Active(file):     468692 kB
Inactive(file):   872388 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:      15631204 kB
SwapFree:       15631204 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:          8632 kB
Mapped:             4140 kB
Slab:             174504 kB
SReclaimable:     154976 kB


> 
> The performance improvements are in a wide range depending on the exact
> machine but the results I've seen so fair are approximately;
> 
> kernbench:	0	to	 0.12% (elapsed time)
> 		0.49%	to	 3.20% (sys time)
> aim9:		-4%	to	30% (for page_test and brk_test)
> tbench:		-1%	to	 4%
> hackbench:	-2.5%	to	 3.45% (mostly within the noise though)
> netperf-udp	-1.34%  to	 4.06% (varies between machines a bit)
> netperf-tcp	-0.44%  to	 5.22% (varies between machines a bit)
> 
> I haven't sysbench figures at hand, but previously they were within the -0.5%
> to 2% range.
> 
> On netperf, the client and server were bound to opposite number CPUs to
> maximise the problems with cache line bouncing of the struct pages so I
> expect different people to report different results for netperf depending
> on their exact machine and how they ran the test (different machines, same
> cpus client/server, shared cache but two threads client/server, different
> socket client/server etc).
> 
> I also measured the vmlinux sizes for a single x86-based config with
> CONFIG_DEBUG_INFO enabled but not CONFIG_DEBUG_VM. The core of the .config
> is based on the Debian Lenny kernel config so I expect it to be reasonably
> typical.
> 
>    text	kernel
> 3355726 mmotm-20090417
> 3355718 0001-Replace-__alloc_pages_internal-with-__alloc_pages_.patch
> 3355622 0002-Do-not-sanity-check-order-in-the-fast-path.patch
> 3355574 0003-Do-not-check-NUMA-node-ID-when-the-caller-knows-the.patch
> 3355574 0004-Check-only-once-if-the-zonelist-is-suitable-for-the.patch
> 3355526 0005-Break-up-the-allocator-entry-point-into-fast-and-slo.patch
> 3355420 0006-Move-check-for-disabled-anti-fragmentation-out-of-fa.patch
> 3355452 0007-Calculate-the-preferred-zone-for-allocation-only-onc.patch
> 3355452 0008-Calculate-the-migratetype-for-allocation-only-once.patch
> 3355436 0009-Calculate-the-alloc_flags-for-allocation-only-once.patch
> 3355436 0010-Remove-a-branch-by-assuming-__GFP_HIGH-ALLOC_HIGH.patch
> 3355420 0011-Inline-__rmqueue_smallest.patch
> 3355420 0012-Inline-buffered_rmqueue.patch
> 3355420 0013-Inline-__rmqueue_fallback.patch
> 3355404 0014-Do-not-call-get_pageblock_migratetype-more-than-ne.patch
> 3355300 0015-Do-not-disable-interrupts-in-free_page_mlock.patch
> 3355300 0016-Do-not-setup-zonelist-cache-when-there-is-only-one-n.patch
> 3355188 0017-Do-not-check-for-compound-pages-during-the-page-allo.patch
> 3355161 0018-Use-allocation-flags-as-an-index-to-the-zone-waterma.patch
> 3355129 0019-Update-NR_FREE_PAGES-only-as-necessary.patch
> 3355129 0020-Get-the-pageblock-migratetype-without-disabling-inte.patch
> 3355129 0021-Use-a-pre-calculated-value-instead-of-num_online_nod.patch
> 
> Some patches were dropped in this revision because while I believe they
> improved performance, they also increase the text size so they need to
> be revisited in isolation to show they actually help things and by how
> much. Other than that, the biggest changes were cleaning up accidental
> functional changes identified by Kosaki Motohiro. Massive credit to him for a
> very defailed review of V6, to Christoph Lameter who reviewed earlier versions
> quite heavily and Pekka who kicked through V6 in quite a lot of detail.
> 
>  arch/ia64/hp/common/sba_iommu.c   |    2 
>  arch/ia64/kernel/mca.c            |    3 
>  arch/ia64/kernel/uncached.c       |    3 
>  arch/ia64/sn/pci/pci_dma.c        |    3 
>  arch/powerpc/platforms/cell/ras.c |    2 
>  arch/x86/kvm/vmx.c                |    2 
>  drivers/misc/sgi-gru/grufile.c    |    2 
>  drivers/misc/sgi-xp/xpc_uv.c      |    2 
>  include/linux/gfp.h               |   27 -
>  include/linux/mm.h                |    1 
>  include/linux/mmzone.h            |   11 
>  include/linux/nodemask.h          |   15 -
>  kernel/profile.c                  |    8 
>  mm/filemap.c                      |    2 
>  mm/hugetlb.c                      |    8 
>  mm/internal.h                     |   11 
>  mm/mempolicy.c                    |    2 
>  mm/migrate.c                      |    2 
>  mm/page_alloc.c                   |  555 ++++++++++++++++++++++++--------------
>  mm/slab.c                         |   11 
>  mm/slob.c                         |    4 
>  mm/slub.c                         |    2 
>  net/sunrpc/svc.c                  |    2 
>  23 files changed, 424 insertions(+), 256 deletions(-)
> 
> Changes since V6
>   o Remove unintentional functional changes when splitting into fast and slow paths
>   o Drop patch 7 for zonelist filtering as it modified when zlc_setup() is called
>     for the wrong reasons. The patch that avoids calling it for non-NUMA machines is
>     still there which has the bulk of the saving. cpusets is relatively small
>   o Drop an unnecessary check for in_interrupt() in gfp_to_alloc_flags()
>   o Clarify comment on __GFP_HIGH == ALLOC_HIGH
>   o Redefine the watermark mask to be expessed in terms of ALLOC_MARK_NOWATERMARK
>   o Use BUILD_BUG_ON for checking __GFP_HIGH == ALLOC_HIGH
>   o Drop some patches that were not reducing text sizes as expected
>   o Remove numa_platform from slab
> 
> Change since V5
>   o Rebase to mmotm-2009-04-17
> 
> Changes since V4
>   o Drop the more controversial patches for now and focus on the "obvious win"
>     material.
>   o Add reviewed-by notes
>   o Fix changelog entry to say __rmqueue_fallback instead __rmqueue
>   o Add unlikely() for the clearMlocked check
>   o Change where PGFREE is accounted in free_hot_cold_page() to have symmetry
>     with __free_pages_ok()
>   o Convert num_online_nodes() to use a static value so that callers do
>     not have to be individually updated
>   o Rebase to mmotm-2003-03-13
> 
> Changes since V3
>   o Drop the more controversial patches for now and focus on the "obvious win"
>     material
>   o Add reviewed-by notes
>   o Fix changelog entry to say __rmqueue_fallback instead __rmqueue
>   o Add unlikely() for the clearMlocked check
>   o Change where PGFREE is accounted in free_hot_cold_page() to have symmetry
>     with __free_pages_ok()
> 
> Changes since V2
>   o Remove brances by treating watermark flags as array indices
>   o Remove branch by assuming __GFP_HIGH == ALLOC_HIGH
>   o Do not check for compound on every page free
>   o Remove branch by always ensuring the migratetype is known on free
>   o Simplify buffered_rmqueue further
>   o Reintroduce improved version of batched bulk free of pcp pages
>   o Use allocation flags as an index to zone watermarks
>   o Work out __GFP_COLD only once
>   o Reduce the number of times zone stats are updated
>   o Do not dump reserve pages back into the allocator. Instead treat them
>     as MOVABLE so that MIGRATE_RESERVE gets used on the max-order-overlapped
>     boundaries without causing trouble
>   o Allow pages up to PAGE_ALLOC_COSTLY_ORDER to use the per-cpu allocator.
>     order-1 allocations are frequently enough in particular to justify this
>   o Rearrange inlining such that the hot-path is inlined but not in a way
>     that increases the text size of the page allocator
>   o Make the check for needing additional zonelist filtering due to NUMA
>     or cpusets as light as possible
>   o Do not destroy compound pages going to the PCP lists
>   o Delay the merging of buddies until a high-order allocation needs them
>     or anti-fragmentation is being forced to fallback
> 
> Changes since V1
>   o Remove the ifdef CONFIG_CPUSETS from inside get_page_from_freelist()
>   o Use non-lock bit operations for clearing the mlock flag
>   o Factor out alloc_flags calculation so it is only done once (Peter)
>   o Make gfp.h a bit prettier and clear-cut (Peter)
>   o Instead of deleting a debugging check, replace page_count() in the
>     free path with a version that does not check for compound pages (Nick)
>   o Drop the alteration for hot/cold page freeing until we know if it
>     helps or not
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
