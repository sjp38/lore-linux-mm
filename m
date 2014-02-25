Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id A057E6B00DF
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:34:18 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id b10so163540eae.7
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 06:34:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e3si9180756eeo.240.2014.02.25.06.34.15
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 06:34:16 -0800 (PST)
Date: Tue, 25 Feb 2014 09:34:08 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <530ca9e8.03cb0e0a.24f6.4905SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <530C9D6B.8050308@oracle.com>
References: <530C9D6B.8050308@oracle.com>
Subject: Re: mm: lockdep inconsistent state in walk_pte_range
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Sasha,

On Tue, Feb 25, 2014 at 08:40:59AM -0500, Sasha Levin wrote:
> Hi Naoya,
> 
> I've stumbled on another issue with the new page walker code. It
> appears to be on the same line as the NULL deref issue we were
> talking about before.

Thanks. My investigation showed that current hugetlbfs has some fundamental
issue on vma->vm_pgoff, which I guess is indirectly related to this lockdep
problem.

For normal pages, vma->vm_pgoff stores in-file offset for shared file mapping,
OTOH it stores (vma->vm_start >> PAGE_SHIFT) for anonymous page or private file
mapping, which is important for rmapping to work.
For hugepages, however, currently we always have vma->vm_pgoff of "in-file"
offset even for anonymous hugepage, private hugetlbfs file mapping, and
SHM_HUGETLB.  I think that this is because hugetlbfs always has internal files
for every hugepages (hidden from userspace for these private mappings,)
and hugetlbfs doesn't handle private mapping correctly.
And then due to this current behavior, __vma_address() returns invalid address,
which results in unexpected behaviors or simply triggers VM_BUG_ON.

This bug also exists on current mainline kernel. We can easily trigger this
for example by doing mbind() for the second hugepage in 3 hugepages
mmap(MAP_PRIVATE|MAP_ANONYMOUS|MAP_HUGETLB) region.

So I'm now preparing the patches to fix it and will post them in a few days.
Then I'll ask you the reported bugs are reproducible with them.

Thanks,
Naoya Horiguchi

> Here's the spew (codebase is latest -next):
> 
> [ 4040.730843] =================================
> [ 4040.731464] [ INFO: inconsistent lock state ]
> [ 4040.732151] 3.14.0-rc3-next-20140224-sasha-00009-gd197068 #41 Tainted: G        W
> [ 4040.733208] ---------------------------------
> [ 4040.733747] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
> [ 4040.734683] trinity-c833/43238 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [ 4040.735441]  (&(ptlock_ptr(page))->rlock#2){+.+.?.}, at:
> [<include/linux/spinlock.h:303 mm/pagewalk.c:33>]
> walk_pte_range+0xb8/0x170
> [ 4040.737064] {IN-RECLAIM_FS-W} state was registered at:
> [ 4040.737925]   [<kernel/locking/lockdep.c:2821>] mark_irqflags+0x144/0x170
> [ 4040.739003]   [<kernel/locking/lockdep.c:3138>] __lock_acquire+0x2de/0x5a0
> [ 4040.740071]   [<arch/x86/include/asm/current.h:14
> kernel/locking/lockdep.c:3602>] lock_acquire+0x182/0x1d0
> [ 4040.740071]   [<include/linux/spinlock_api_smp.h:143
> kernel/locking/spinlock.c:151>] _raw_spin_lock+0x3b/0x70
> [ 4040.740071]   [<include/linux/spinlock.h:303 mm/rmap.c:628>] __page_check_address+0x1a2/0x230
> [ 4040.740071]   [<mm/rmap.c:710>] page_referenced_one+0xbc/0x190
> [ 4040.740071]   [<mm/rmap.c:1616>] rmap_walk_anon+0x104/0x170
> [ 4040.740071]   [<mm/rmap.c:1688>] rmap_walk+0x2d/0x50
> [ 4040.740071]   [<mm/rmap.c:806>] page_referenced+0xcb/0x100
> [ 4040.740071]   [<mm/vmscan.c:1704>] shrink_active_list+0x202/0x320
> [ 4040.740071]   [<mm/vmscan.c:2741 mm/vmscan.c:2996>] balance_pgdat+0x16b/0x540
> [ 4040.740071]   [<mm/vmscan.c:3296>] kswapd+0x2eb/0x350
> [ 4040.740071]   [<kernel/kthread.c:216>] kthread+0x105/0x110
> [ 4040.740071]   [<arch/x86/kernel/entry_64.S:555>] ret_from_fork+0x7c/0xb0
> [ 4040.740071] irq event stamp: 741081
> [ 4040.740071] hardirqs last  enabled at (741081):
> [<arch/x86/include/asm/paravirt.h:809 include/linux/seqlock.h:81
> include/linux/seqlock.h:146 include/linux/cpuset.h:98 mm/mem
> policy.c:2009>] alloc_pages_vma+0x115/0x230
> [ 4040.740071] hardirqs last disabled at (741080):
> [<include/linux/seqlock.h:79 include/linux/seqlock.h:146
> include/linux/cpuset.h:98 mm/mempolicy.c:2009>] alloc_pages_vma+0xa4
> /0x230
> [ 4040.740071] softirqs last  enabled at (741078):
> [<arch/x86/include/asm/preempt.h:22 kernel/softirq.c:297>]
> __do_softirq+0x447/0x4f0
> [ 4040.740071] softirqs last disabled at (741075):
> [<kernel/softirq.c:347 kernel/softirq.c:388>] irq_exit+0x83/0x160
> [ 4040.740071]
> [ 4040.740071] other info that might help us debug this:
> [ 4040.740071]  Possible unsafe locking scenario:
> [ 4040.740071]
> [ 4040.740071]        CPU0
> [ 4040.740071]        ----
> [ 4040.740071]   lock(&(ptlock_ptr(page))->rlock#2);
> [ 4040.740071]   <Interrupt>
> [ 4040.740071]     lock(&(ptlock_ptr(page))->rlock#2);
> [ 4040.740071]
> [ 4040.740071]  *** DEADLOCK ***
> [ 4040.740071]
> [ 4040.740071] 2 locks held by trinity-c833/43238:
> [ 4040.740071]  #0:  (&mm->mmap_sem){++++++}, at:
> [<arch/x86/include/asm/current.h:14 mm/madvise.c:492
> mm/madvise.c:448>] SyS_madvise+0xf8/0x250
> [ 4040.740071]  #1:  (&(ptlock_ptr(page))->rlock#2){+.+.?.}, at:
> [<include/linux/spinlock.h:303 mm/pagewalk.c:33>]
> walk_pte_range+0xb8/0x170
> [ 4040.740071]
> [ 4040.740071] stack backtrace:
> [ 4040.740071] CPU: 38 PID: 43238 Comm: trinity-c833 Tainted: G
> W 3.14.0-rc3-next-20140224-sasha-00009-gd197068 #41
> [ 4040.740071]  ffff880094990cf8 ffff88008f6fb968 ffffffff843850f8 0000000000000000
> [ 4040.740071]  ffff880094990000 ffff88008f6fb9c8 ffffffff811a0eb7 0000000000000000
> [ 4040.740071]  0000000000000001 ffff880d00000001 ffffffff876aeca8 000000000000000a
> [ 4040.740071] Call Trace:
> [ 4040.740071]  [<lib/dump_stack.c:52>] dump_stack+0x52/0x7f
> [ 4040.740071]  [<kernel/locking/lockdep.c:2254>] print_usage_bug+0x1a7/0x1e0
> [ 4040.740071]  [<kernel/locking/lockdep.c:2371>] ? check_usage_forwards+0x100/0x100
> [ 4040.740071]  [<kernel/locking/lockdep.c:2465>] mark_lock_irq+0xd9/0x2a0
> [ 4040.740071]  [<kernel/locking/lockdep.c:2920>] mark_lock+0x128/0x210
> [ 4040.740071]  [<kernel/locking/lockdep.c:2523>] mark_held_locks+0x6c/0x90
> [ 4040.740071]  [<kernel/locking/lockdep.c:2745
> kernel/locking/lockdep.c:2760>] lockdep_trace_alloc+0xfd/0x140
> [ 4040.740071]  [<mm/page_alloc.c:2703>] __alloc_pages_nodemask+0xc5/0x4f0
> [ 4040.740071]  [<arch/x86/include/asm/preempt.h:98
> kernel/locking/lockdep.c:254>] ? put_lock_stats+0xe/0x30
> [ 4040.740071]  [<kernel/locking/lockdep.c:2523>] ? mark_held_locks+0x6c/0x90
> [ 4040.740071]  [<include/linux/mempolicy.h:76 mm/mempolicy.c:2025>] alloc_pages_vma+0x1df/0x230
> [ 4040.740071]  [<mm/swap_state.c:328>] ? read_swap_cache_async+0x8a/0x220
> [ 4040.740071]  [<arch/x86/lib/delay.c:126>] ? __const_udelay+0x29/0x30
> [ 4040.740071]  [<mm/swap_state.c:328>] read_swap_cache_async+0x8a/0x220
> [ 4040.740071]  [<include/linux/spinlock.h:303 mm/pagewalk.c:33>] ? walk_pte_range+0xb8/0x170
> [ 4040.740071]  [<mm/madvise.c:152>] swapin_walk_pte_entry+0x7c/0xa0
> [ 4040.740071]  [<mm/pagewalk.c:47>] walk_pte_range+0xf8/0x170
> [ 4040.740071]  [<mm/pagewalk.c:90>] walk_pmd_range+0x211/0x240
> [ 4040.740071]  [<mm/pagewalk.c:128>] walk_pud_range+0x12b/0x160
> [ 4040.740071]  [<mm/pagewalk.c:165>] walk_pgd_range+0x109/0x140
> [ 4040.740071]  [<mm/pagewalk.c:259>] __walk_page_range+0x35/0x40
> [ 4040.740071]  [<mm/pagewalk.c:332>] walk_page_range+0xf2/0x130
> [ 4040.740071]  [<mm/madvise.c:167 mm/madvise.c:211>] madvise_willneed+0x76/0x150
> [ 4040.740071]  [<mm/madvise.c:140>] ? madvise_hwpoison+0x160/0x160
> [ 4040.740071]  [<mm/madvise.c:369>] madvise_vma+0x116/0x1c0
> [ 4040.740071]  [<mm/madvise.c:518 mm/madvise.c:448>] SyS_madvise+0x17e/0x250
> [ 4040.740071]  [<arch/x86/ia32/ia32entry.S:430>] ia32_do_call+0x13/0x13
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
