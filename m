Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 751648E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 18:38:51 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 80so10154252qkd.0
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:38:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s189sor48718766qkf.100.2019.01.17.15.38.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 15:38:49 -0800 (PST)
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame
 Ownership
References: <cover.1547153058.git.khalid.aziz@oracle.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <38897e25-c07f-9da1-1671-ae31ac64c864@redhat.com>
Date: Thu, 17 Jan 2019 15:38:44 -0800
MIME-Version: 1.0
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/10/19 1:09 PM, Khalid Aziz wrote:
> I am continuing to build on the work Juerg, Tycho and Julian have done
> on XPFO. After the last round of updates, we were seeing very
> significant performance penalties when stale TLB entries were flushed
> actively after an XPFO TLB update. Benchmark for measuring performance
> is kernel build using parallel make. To get full protection from
> ret2dir attackes, we must flush stale TLB entries. Performance
> penalty from flushing stale TLB entries goes up as the number of
> cores goes up. On a desktop class machine with only 4 cores,
> enabling TLB flush for stale entries causes system time for "make
> -j4" to go up by a factor of 2.614x but on a larger machine with 96
> cores, system time with "make -j60" goes up by a factor of 26.366x!
> I have been working on reducing this performance penalty.
> 
> I implemented a solution to reduce performance penalty and
> that has had large impact. When XPFO code flushes stale TLB entries,
> it does so for all CPUs on the system which may include CPUs that
> may not have any matching TLB entries or may never be scheduled to
> run the userspace task causing TLB flush. Problem is made worse by
> the fact that if number of entries being flushed exceeds
> tlb_single_page_flush_ceiling, it results in a full TLB flush on
> every CPU. A rogue process can launch a ret2dir attack only from a
> CPU that has dual mapping for its pages in physmap in its TLB. We
> can hence defer TLB flush on a CPU until a process that would have
> caused a TLB flush is scheduled on that CPU. I have added a cpumask
> to task_struct which is then used to post pending TLB flush on CPUs
> other than the one a process is running on. This cpumask is checked
> when a process migrates to a new CPU and TLB is flushed at that
> time. I measured system time for parallel make with unmodified 4.20
> kernel, 4.20 with XPFO patches before this optimization and then
> again after applying this optimization. Here are the results:
> 
> Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
> make -j60 all
> 
> 4.20				915.183s
> 4.20+XPFO			24129.354s	26.366x
> 4.20+XPFO+Deferred flush	1216.987s	 1.330xx
> 
> 
> Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
> make -j4 all
> 
> 4.20				607.671s
> 4.20+XPFO			1588.646s	2.614x
> 4.20+XPFO+Deferred flush	794.473s	1.307xx
> 
> 30+% overhead is still very high and there is room for improvement.
> Dave Hansen had suggested batch updating TLB entries and Tycho had
> created an initial implementation but I have not been able to get
> that to work correctly. I am still working on it and I suspect we
> will see a noticeable improvement in performance with that. In the
> code I added, I post a pending full TLB flush to all other CPUs even
> when number of TLB entries being flushed on current CPU does not
> exceed tlb_single_page_flush_ceiling. There has to be a better way
> to do this. I just haven't found an efficient way to implemented
> delayed limited TLB flush on other CPUs.
> 
> I am not entirely sure if switch_mm_irqs_off() is indeed the right
> place to perform the pending TLB flush for a CPU. Any feedback on
> that will be very helpful. Delaying full TLB flushes on other CPUs
> seems to help tremendously, so if there is a better way to implement
> the same thing than what I have done in patch 16, I am open to
> ideas.
> 
> Performance with this patch set is good enough to use these as
> starting point for further refinement before we merge it into main
> kernel, hence RFC.
> 
> Since not flushing stale TLB entries creates a false sense of
> security, I would recommend making TLB flush mandatory and eliminate
> the "xpfotlbflush" kernel parameter (patch "mm, x86: omit TLB
> flushing by default for XPFO page table modifications").
> 
> What remains to be done beyond this patch series:
> 
> 1. Performance improvements
> 2. Remove xpfotlbflush parameter
> 3. Re-evaluate the patch "arm64/mm: Add support for XPFO to swiotlb"
>     from Juerg. I dropped it for now since swiotlb code for ARM has
>     changed a lot in 4.20.
> 4. Extend the patch "xpfo, mm: Defer TLB flushes for non-current
>     CPUs" to other architectures besides x86.
> 
> 
> ---------------------------------------------------------
> 
> Juerg Haefliger (5):
>    mm, x86: Add support for eXclusive Page Frame Ownership (XPFO)
>    swiotlb: Map the buffer if it was unmapped by XPFO
>    arm64/mm: Add support for XPFO
>    arm64/mm, xpfo: temporarily map dcache regions
>    lkdtm: Add test for XPFO
> 
> Julian Stecklina (4):
>    mm, x86: omit TLB flushing by default for XPFO page table
>      modifications
>    xpfo, mm: remove dependency on CONFIG_PAGE_EXTENSION
>    xpfo, mm: optimize spinlock usage in xpfo_kunmap
>    EXPERIMENTAL: xpfo, mm: optimize spin lock usage in xpfo_kmap
> 
> Khalid Aziz (2):
>    xpfo, mm: Fix hang when booting with "xpfotlbflush"
>    xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
> 
> Tycho Andersen (5):
>    mm: add MAP_HUGETLB support to vm_mmap
>    x86: always set IF before oopsing from page fault
>    xpfo: add primitives for mapping underlying memory
>    arm64/mm: disable section/contiguous mappings if XPFO is enabled
>    mm: add a user_virt_to_phys symbol
> 
>   .../admin-guide/kernel-parameters.txt         |   2 +
>   arch/arm64/Kconfig                            |   1 +
>   arch/arm64/mm/Makefile                        |   2 +
>   arch/arm64/mm/flush.c                         |   7 +
>   arch/arm64/mm/mmu.c                           |   2 +-
>   arch/arm64/mm/xpfo.c                          |  58 ++++
>   arch/x86/Kconfig                              |   1 +
>   arch/x86/include/asm/pgtable.h                |  26 ++
>   arch/x86/include/asm/tlbflush.h               |   1 +
>   arch/x86/mm/Makefile                          |   2 +
>   arch/x86/mm/fault.c                           |  10 +
>   arch/x86/mm/pageattr.c                        |  23 +-
>   arch/x86/mm/tlb.c                             |  27 ++
>   arch/x86/mm/xpfo.c                            | 171 ++++++++++++
>   drivers/misc/lkdtm/Makefile                   |   1 +
>   drivers/misc/lkdtm/core.c                     |   3 +
>   drivers/misc/lkdtm/lkdtm.h                    |   5 +
>   drivers/misc/lkdtm/xpfo.c                     | 194 ++++++++++++++
>   include/linux/highmem.h                       |  15 +-
>   include/linux/mm.h                            |   2 +
>   include/linux/mm_types.h                      |   8 +
>   include/linux/page-flags.h                    |  13 +
>   include/linux/sched.h                         |   9 +
>   include/linux/xpfo.h                          |  90 +++++++
>   include/trace/events/mmflags.h                |  10 +-
>   kernel/dma/swiotlb.c                          |   3 +-
>   mm/Makefile                                   |   1 +
>   mm/mmap.c                                     |  19 +-
>   mm/page_alloc.c                               |   3 +
>   mm/util.c                                     |  32 +++
>   mm/xpfo.c                                     | 247 ++++++++++++++++++
>   security/Kconfig                              |  29 ++
>   32 files changed, 974 insertions(+), 43 deletions(-)
>   create mode 100644 arch/arm64/mm/xpfo.c
>   create mode 100644 arch/x86/mm/xpfo.c
>   create mode 100644 drivers/misc/lkdtm/xpfo.c
>   create mode 100644 include/linux/xpfo.h
>   create mode 100644 mm/xpfo.c
> 

Also gave this a boot on my X1 Carbon and I got some lockdep splat:

[   16.863110] ================================
[   16.863119] WARNING: inconsistent lock state
[   16.863128] 4.20.0-xpfo+ #6 Not tainted
[   16.863136] --------------------------------
[   16.863145] inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
[   16.863157] swapper/5/0 [HC1[1]:SC1[1]:HE0:SE0] takes:
[   16.863168] 00000000301e129a (&(&page->xpfo_lock)->rlock){?.+.}, at: xpfo_do_map+0x1b/0x90
[   16.863188] {HARDIRQ-ON-W} state was registered at:
[   16.863200]   _raw_spin_lock+0x30/0x70
[   16.863208]   xpfo_do_map+0x1b/0x90
[   16.863217]   simple_write_begin+0xc7/0x240
[   16.863227]   generic_perform_write+0xf7/0x1c0
[   16.863237]   __generic_file_write_iter+0xfa/0x1c0
[   16.863247]   generic_file_write_iter+0xab/0x150
[   16.863257]   __vfs_write+0x139/0x1a0
[   16.863264]   vfs_write+0xba/0x1c0
[   16.863272]   ksys_write+0x52/0xc0
[   16.863281]   xwrite+0x29/0x5a
[   16.863288]   do_copy+0x2b/0xc8
[   16.863296]   write_buffer+0x2a/0x3a
[   16.863304]   unpack_to_rootfs+0x107/0x2c8
[   16.863312]   populate_rootfs+0x5d/0x10a
[   16.863322]   do_one_initcall+0x5d/0x2be
[   16.863541]   kernel_init_freeable+0x21b/0x2c9
[   16.863764]   kernel_init+0xa/0x109
[   16.863988]   ret_from_fork+0x3a/0x50
[   16.864220] irq event stamp: 337503
[   16.864456] hardirqs last  enabled at (337502): [<ffffffff8ce000a7>] __do_softirq+0xa7/0x47c
[   16.864715] hardirqs last disabled at (337503): [<ffffffff8c0037e8>] trace_hardirqs_off_thunk+0x1a/0x1c
[   16.864985] softirqs last  enabled at (337500): [<ffffffff8c0c6d88>] irq_enter+0x68/0x70
[   16.865263] softirqs last disabled at (337501): [<ffffffff8c0c6ea9>] irq_exit+0x119/0x120
[   16.865546]
                other info that might help us debug this:
[   16.866128]  Possible unsafe locking scenario:

[   16.866733]        CPU0
[   16.867039]        ----
[   16.867370]   lock(&(&page->xpfo_lock)->rlock);
[   16.867693]   <Interrupt>
[   16.868019]     lock(&(&page->xpfo_lock)->rlock);
[   16.868354]
                 *** DEADLOCK ***

[   16.869373] 1 lock held by swapper/5/0:
[   16.869727]  #0: 00000000800b2c51 (&(&ctx->completion_lock)->rlock){-.-.}, at: aio_complete+0x3c/0x460
[   16.870106]
                stack backtrace:
[   16.870868] CPU: 5 PID: 0 Comm: swapper/5 Not tainted 4.20.0-xpfo+ #6
[   16.871270] Hardware name: LENOVO 20KGS23S00/20KGS23S00, BIOS N23ET40W (1.15 ) 04/13/2018
[   16.871686] Call Trace:
[   16.872106]  <IRQ>
[   16.872531]  dump_stack+0x85/0xc0
[   16.872962]  print_usage_bug.cold.60+0x1a8/0x1e2
[   16.873407]  ? print_shortest_lock_dependencies+0x40/0x40
[   16.873856]  mark_lock+0x502/0x600
[   16.874308]  ? check_usage_backwards+0x120/0x120
[   16.874769]  __lock_acquire+0x6e2/0x1650
[   16.875236]  ? find_held_lock+0x34/0xa0
[   16.875710]  ? sched_clock_cpu+0xc/0xb0
[   16.876185]  lock_acquire+0x9e/0x180
[   16.876668]  ? xpfo_do_map+0x1b/0x90
[   16.877154]  _raw_spin_lock+0x30/0x70
[   16.877649]  ? xpfo_do_map+0x1b/0x90
[   16.878144]  xpfo_do_map+0x1b/0x90
[   16.878647]  aio_complete+0xb2/0x460
[   16.879154]  blkdev_bio_end_io+0x71/0x150
[   16.879665]  blk_update_request+0xd7/0x2e0
[   16.880170]  blk_mq_end_request+0x1a/0x100
[   16.880669]  blk_mq_complete_request+0x98/0x120
[   16.881175]  nvme_irq+0x192/0x210 [nvme]
[   16.881675]  __handle_irq_event_percpu+0x46/0x2a0
[   16.882174]  handle_irq_event_percpu+0x30/0x80
[   16.882670]  handle_irq_event+0x34/0x51
[   16.883252]  handle_edge_irq+0x7b/0x190
[   16.883772]  handle_irq+0xbf/0x100
[   16.883774]  do_IRQ+0x5f/0x120
[   16.883776]  common_interrupt+0xf/0xf
[   16.885469] RIP: 0010:__do_softirq+0xae/0x47c
[   16.885470] Code: 0c 00 00 01 c7 44 24 24 0a 00 00 00 44 89 7c 24 04 48 c7 c0 c0 1e 1e 00 65 66 c7 00 00 00 e8 69 3d 3e ff fb 66 0f 1f 44 00 00 <48> c7 44 24 08 80 51 60 8d b8 ff ff ff ff 0f bc 44 24 04 83 c0 01
[   16.885471] RSP: 0018:ffff8bde5e003f68 EFLAGS: 00000202 ORIG_RAX: ffffffffffffffdd
[   16.887291] RAX: ffff8bde5b303740 RBX: ffff8bde5b303740 RCX: 0000000000000000
[   16.887291] RDX: ffff8bde5b303740 RSI: 0000000000000000 RDI: ffff8bde5b303740
[   16.887292] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
[   16.887293] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[   16.887294] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000202
[   16.887296]  ? common_interrupt+0xa/0xf
[   16.890885]  ? __do_softirq+0xa7/0x47c
[   16.890887]  ? hrtimer_interrupt+0x12e/0x220
[   16.890889]  irq_exit+0x119/0x120
[   16.890920]  smp_apic_timer_interrupt+0xa2/0x230
[   16.890921]  apic_timer_interrupt+0xf/0x20
[   16.890922]  </IRQ>
[   16.890955] RIP: 0010:cpuidle_enter_state+0xbe/0x350
[   16.890956] Code: 80 7c 24 0b 00 74 17 9c 58 0f 1f 44 00 00 f6 c4 02 0f 85 6d 02 00 00 31 ff e8 8e 61 91 ff e8 19 77 98 ff fb 66 0f 1f 44 00 00 <85> ed 0f 88 36 02 00 00 48 b8 ff ff ff ff f3 01 00 00 48 2b 1c 24
[   16.890957] RSP: 0018:ffffa91a41997ea0 EFLAGS: 00000206 ORIG_RAX: ffffffffffffff13
[   16.891025] RAX: ffff8bde5b303740 RBX: 00000003ed1dca4d RCX: 0000000000000000
[   16.891026] RDX: ffff8bde5b303740 RSI: 0000000000000001 RDI: ffff8bde5b303740
[   16.891027] RBP: 0000000000000004 R08: 0000000000000000 R09: 0000000000000000
[   16.891028] R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff8d7f8898
[   16.891028] R13: ffffc91a3f800a00 R14: 0000000000000004 R15: 0000000000000000
[   16.891032]  do_idle+0x23e/0x280
[   16.891119]  cpu_startup_entry+0x19/0x20
[   16.891122]  start_secondary+0x1b3/0x200
[   16.891124]  secondary_startup_64+0xa4/0xb0

This was 4.20 + this series. config was based on what Fedora has.

Thanks,
Laura
