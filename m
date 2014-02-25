Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC5F6B00DF
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 08:41:11 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id q9so1001941ykb.2
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 05:41:11 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s18si3841732yhj.63.2014.02.25.05.41.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 05:41:10 -0800 (PST)
Message-ID: <530C9D6B.8050308@oracle.com>
Date: Tue, 25 Feb 2014 08:40:59 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: lockdep inconsistent state in walk_pte_range
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Naoya,

I've stumbled on another issue with the new page walker code. It appears to be on the same line as 
the NULL deref issue we were talking about before.

Here's the spew (codebase is latest -next):

[ 4040.730843] =================================
[ 4040.731464] [ INFO: inconsistent lock state ]
[ 4040.732151] 3.14.0-rc3-next-20140224-sasha-00009-gd197068 #41 Tainted: G        W
[ 4040.733208] ---------------------------------
[ 4040.733747] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
[ 4040.734683] trinity-c833/43238 [HC0[0]:SC0[0]:HE1:SE1] takes:
[ 4040.735441]  (&(ptlock_ptr(page))->rlock#2){+.+.?.}, at: [<include/linux/spinlock.h:303 
mm/pagewalk.c:33>] walk_pte_range+0xb8/0x170
[ 4040.737064] {IN-RECLAIM_FS-W} state was registered at:
[ 4040.737925]   [<kernel/locking/lockdep.c:2821>] mark_irqflags+0x144/0x170
[ 4040.739003]   [<kernel/locking/lockdep.c:3138>] __lock_acquire+0x2de/0x5a0
[ 4040.740071]   [<arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602>] 
lock_acquire+0x182/0x1d0
[ 4040.740071]   [<include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151>] 
_raw_spin_lock+0x3b/0x70
[ 4040.740071]   [<include/linux/spinlock.h:303 mm/rmap.c:628>] __page_check_address+0x1a2/0x230
[ 4040.740071]   [<mm/rmap.c:710>] page_referenced_one+0xbc/0x190
[ 4040.740071]   [<mm/rmap.c:1616>] rmap_walk_anon+0x104/0x170
[ 4040.740071]   [<mm/rmap.c:1688>] rmap_walk+0x2d/0x50
[ 4040.740071]   [<mm/rmap.c:806>] page_referenced+0xcb/0x100
[ 4040.740071]   [<mm/vmscan.c:1704>] shrink_active_list+0x202/0x320
[ 4040.740071]   [<mm/vmscan.c:2741 mm/vmscan.c:2996>] balance_pgdat+0x16b/0x540
[ 4040.740071]   [<mm/vmscan.c:3296>] kswapd+0x2eb/0x350
[ 4040.740071]   [<kernel/kthread.c:216>] kthread+0x105/0x110
[ 4040.740071]   [<arch/x86/kernel/entry_64.S:555>] ret_from_fork+0x7c/0xb0
[ 4040.740071] irq event stamp: 741081
[ 4040.740071] hardirqs last  enabled at (741081): [<arch/x86/include/asm/paravirt.h:809 
include/linux/seqlock.h:81 include/linux/seqlock.h:146 include/linux/cpuset.h:98 mm/mem
policy.c:2009>] alloc_pages_vma+0x115/0x230
[ 4040.740071] hardirqs last disabled at (741080): [<include/linux/seqlock.h:79 
include/linux/seqlock.h:146 include/linux/cpuset.h:98 mm/mempolicy.c:2009>] alloc_pages_vma+0xa4
/0x230
[ 4040.740071] softirqs last  enabled at (741078): [<arch/x86/include/asm/preempt.h:22 
kernel/softirq.c:297>] __do_softirq+0x447/0x4f0
[ 4040.740071] softirqs last disabled at (741075): [<kernel/softirq.c:347 kernel/softirq.c:388>] 
irq_exit+0x83/0x160
[ 4040.740071]
[ 4040.740071] other info that might help us debug this:
[ 4040.740071]  Possible unsafe locking scenario:
[ 4040.740071]
[ 4040.740071]        CPU0
[ 4040.740071]        ----
[ 4040.740071]   lock(&(ptlock_ptr(page))->rlock#2);
[ 4040.740071]   <Interrupt>
[ 4040.740071]     lock(&(ptlock_ptr(page))->rlock#2);
[ 4040.740071]
[ 4040.740071]  *** DEADLOCK ***
[ 4040.740071]
[ 4040.740071] 2 locks held by trinity-c833/43238:
[ 4040.740071]  #0:  (&mm->mmap_sem){++++++}, at: [<arch/x86/include/asm/current.h:14 
mm/madvise.c:492 mm/madvise.c:448>] SyS_madvise+0xf8/0x250
[ 4040.740071]  #1:  (&(ptlock_ptr(page))->rlock#2){+.+.?.}, at: [<include/linux/spinlock.h:303 
mm/pagewalk.c:33>] walk_pte_range+0xb8/0x170
[ 4040.740071]
[ 4040.740071] stack backtrace:
[ 4040.740071] CPU: 38 PID: 43238 Comm: trinity-c833 Tainted: G        W 
3.14.0-rc3-next-20140224-sasha-00009-gd197068 #41
[ 4040.740071]  ffff880094990cf8 ffff88008f6fb968 ffffffff843850f8 0000000000000000
[ 4040.740071]  ffff880094990000 ffff88008f6fb9c8 ffffffff811a0eb7 0000000000000000
[ 4040.740071]  0000000000000001 ffff880d00000001 ffffffff876aeca8 000000000000000a
[ 4040.740071] Call Trace:
[ 4040.740071]  [<lib/dump_stack.c:52>] dump_stack+0x52/0x7f
[ 4040.740071]  [<kernel/locking/lockdep.c:2254>] print_usage_bug+0x1a7/0x1e0
[ 4040.740071]  [<kernel/locking/lockdep.c:2371>] ? check_usage_forwards+0x100/0x100
[ 4040.740071]  [<kernel/locking/lockdep.c:2465>] mark_lock_irq+0xd9/0x2a0
[ 4040.740071]  [<kernel/locking/lockdep.c:2920>] mark_lock+0x128/0x210
[ 4040.740071]  [<kernel/locking/lockdep.c:2523>] mark_held_locks+0x6c/0x90
[ 4040.740071]  [<kernel/locking/lockdep.c:2745 kernel/locking/lockdep.c:2760>] 
lockdep_trace_alloc+0xfd/0x140
[ 4040.740071]  [<mm/page_alloc.c:2703>] __alloc_pages_nodemask+0xc5/0x4f0
[ 4040.740071]  [<arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254>] ? 
put_lock_stats+0xe/0x30
[ 4040.740071]  [<kernel/locking/lockdep.c:2523>] ? mark_held_locks+0x6c/0x90
[ 4040.740071]  [<include/linux/mempolicy.h:76 mm/mempolicy.c:2025>] alloc_pages_vma+0x1df/0x230
[ 4040.740071]  [<mm/swap_state.c:328>] ? read_swap_cache_async+0x8a/0x220
[ 4040.740071]  [<arch/x86/lib/delay.c:126>] ? __const_udelay+0x29/0x30
[ 4040.740071]  [<mm/swap_state.c:328>] read_swap_cache_async+0x8a/0x220
[ 4040.740071]  [<include/linux/spinlock.h:303 mm/pagewalk.c:33>] ? walk_pte_range+0xb8/0x170
[ 4040.740071]  [<mm/madvise.c:152>] swapin_walk_pte_entry+0x7c/0xa0
[ 4040.740071]  [<mm/pagewalk.c:47>] walk_pte_range+0xf8/0x170
[ 4040.740071]  [<mm/pagewalk.c:90>] walk_pmd_range+0x211/0x240
[ 4040.740071]  [<mm/pagewalk.c:128>] walk_pud_range+0x12b/0x160
[ 4040.740071]  [<mm/pagewalk.c:165>] walk_pgd_range+0x109/0x140
[ 4040.740071]  [<mm/pagewalk.c:259>] __walk_page_range+0x35/0x40
[ 4040.740071]  [<mm/pagewalk.c:332>] walk_page_range+0xf2/0x130
[ 4040.740071]  [<mm/madvise.c:167 mm/madvise.c:211>] madvise_willneed+0x76/0x150
[ 4040.740071]  [<mm/madvise.c:140>] ? madvise_hwpoison+0x160/0x160
[ 4040.740071]  [<mm/madvise.c:369>] madvise_vma+0x116/0x1c0
[ 4040.740071]  [<mm/madvise.c:518 mm/madvise.c:448>] SyS_madvise+0x17e/0x250
[ 4040.740071]  [<arch/x86/ia32/ia32entry.S:430>] ia32_do_call+0x13/0x13

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
