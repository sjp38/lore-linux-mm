Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2016B025E
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 21:47:27 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id uy17so151064igb.3
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 18:47:27 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y8si4047745icp.22.2014.03.20.18.47.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 18:47:26 -0700 (PDT)
Message-ID: <532B9A18.8020606@oracle.com>
Date: Thu, 20 Mar 2014 21:47:04 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/11] madvise: redefine callback functions for page table
 walker
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1392068676-30627-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1392068676-30627-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On 02/10/2014 04:44 PM, Naoya Horiguchi wrote:
> swapin_walk_pmd_entry() is defined as pmd_entry(), but it has no code
> about pmd handling (except pmd_none_or_trans_huge_or_clear_bad, but the
> same check are now done in core page table walk code).
> So let's move this function on pte_entry() as swapin_walk_pte_entry().
>
> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>

This patch seems to generate:

[  305.267354] =================================
[  305.268051] [ INFO: inconsistent lock state ]
[  305.268678] 3.14.0-rc7-next-20140320-sasha-00015-gd752393-dirty #261 Tainted: G        W
[  305.269992] ---------------------------------
[  305.270152] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
[  305.270152] trinity-c57/13619 [HC0[0]:SC0[0]:HE1:SE1] takes:
[  305.270152]  (&(ptlock_ptr(page))->rlock#2){+.+.?.}, at: walk_pte_range (include/linux/spinlock.h:303 mm/pagewalk.c:33)
[  305.270152] {IN-RECLAIM_FS-W} state was registered at:
[  305.270152]   mark_irqflags (kernel/locking/lockdep.c:2821)
[  305.270152]   __lock_acquire (kernel/locking/lockdep.c:3138)
[  305.270152]   lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
[  305.270152]   _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[  305.270152]   __page_check_address (include/linux/spinlock.h:303 mm/rmap.c:624)
[  305.270152]   page_referenced_one (mm/rmap.c:706)
[  305.270152]   rmap_walk_anon (mm/rmap.c:1613)
[  305.270152]   rmap_walk (mm/rmap.c:1685)
[  305.270152]   page_referenced (mm/rmap.c:802)
[  305.270152]   shrink_active_list (mm/vmscan.c:1704)
[  305.270152]   balance_pgdat (mm/vmscan.c:2741 mm/vmscan.c:2996)
[  305.270152]   kswapd (mm/vmscan.c:3296)
[  305.270152]   kthread (kernel/kthread.c:216)
[  305.270152]   ret_from_fork (arch/x86/kernel/entry_64.S:555)
[  305.270152] irq event stamp: 20863
[  305.270152] hardirqs last  enabled at (20863): alloc_pages_vma (arch/x86/include/asm/paravirt.h:809 include/linux/seqlock.h:81 include/linux/seqlock.h:146 include/linux/cpus
et.h:98 mm/mempolicy.c:1990)
[  305.270152] hardirqs last disabled at (20862): alloc_pages_vma (include/linux/seqlock.h:79 include/linux/seqlock.h:146 include/linux/cpuset.h:98 mm/mempolicy.c:1990)
[  305.270152] softirqs last  enabled at (19858): __do_softirq (arch/x86/include/asm/preempt.h:22 kernel/softirq.c:298)
[  305.270152] softirqs last disabled at (19855): irq_exit (kernel/softirq.c:348 kernel/softirq.c:389)
[  305.270152]
[  305.270152] other info that might help us debug this:
[  305.270152]  Possible unsafe locking scenario:
[  305.270152]
[  305.270152]        CPU0
[  305.270152]        ----
[  305.270152]   lock(&(ptlock_ptr(page))->rlock#2);
[  305.270152]   <Interrupt>
[  305.270152]     lock(&(ptlock_ptr(page))->rlock#2);
[  305.270152]
[  305.270152]  *** DEADLOCK ***
[  305.270152]
[  305.270152] 2 locks held by trinity-c57/13619:
[  305.270152]  #0:  (&mm->mmap_sem){++++++}, at: SyS_madvise (arch/x86/include/asm/current.h:14 mm/madvise.c:492 mm/madvise.c:448)
[  305.270152]  #1:  (&(ptlock_ptr(page))->rlock#2){+.+.?.}, at: walk_pte_range (include/linux/spinlock.h:303 mm/pagewalk.c:33)
[  305.270152]
[  305.270152] stack backtrace:
[  305.270152] CPU: 23 PID: 13619 Comm: trinity-c57 Tainted: G        W     3.14.0-rc7-next-20140320-sasha-00015-gd752393-dirty #261
[  305.270152]  ffff8804ab8e0d28 ffff8804ab9c5968 ffffffff844b76e7 0000000000000001
[  305.270152]  ffff8804ab8e0000 ffff8804ab9c59c8 ffffffff811a55f7 0000000000000000
[  305.270152]  0000000000000001 ffff880400000001 ffffffff87e18ed8 000000000000000a
[  305.270152] Call Trace:
[  305.270152]  dump_stack (lib/dump_stack.c:52)
[  305.270152]  print_usage_bug (kernel/locking/lockdep.c:2254)
[  305.270152]  ? check_usage_forwards (kernel/locking/lockdep.c:2371)
[  305.270152]  mark_lock_irq (kernel/locking/lockdep.c:2465)
[  305.270152]  mark_lock (kernel/locking/lockdep.c:2920)
[  305.270152]  mark_held_locks (kernel/locking/lockdep.c:2523)
[  305.270152]  lockdep_trace_alloc (kernel/locking/lockdep.c:2745 kernel/locking/lockdep.c:2760)
[  305.270152]  __alloc_pages_nodemask (mm/page_alloc.c:2722)
[  305.270152]  ? mark_held_locks (kernel/locking/lockdep.c:2523)
[  305.270152]  ? alloc_pages_vma (arch/x86/include/asm/paravirt.h:809 include/linux/seqlock.h:81 include/linux/seqlock.h:146 include/linux/cpuset.h:98 mm/mempolicy.c:1990)
[  305.270152]  alloc_pages_vma (include/linux/mempolicy.h:76 mm/mempolicy.c:2006)
[  305.270152]  ? read_swap_cache_async (mm/swap_state.c:328)
[  305.270152]  ? __const_udelay (arch/x86/lib/delay.c:126)
[  305.270152]  read_swap_cache_async (mm/swap_state.c:328)
[  305.270152]  ? walk_pte_range (include/linux/spinlock.h:303 mm/pagewalk.c:33)
[  305.270152]  swapin_walk_pte_entry (mm/madvise.c:152)
[  305.270152]  walk_pte_range (mm/pagewalk.c:47)
[  305.270152]  ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[  305.270152]  walk_pmd_range (mm/pagewalk.c:90)
[  305.270152]  ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[  305.270152]  ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[  305.270152]  walk_pud_range (mm/pagewalk.c:128)
[  305.270152]  walk_pgd_range (mm/pagewalk.c:165)
[  305.270152]  __walk_page_range (mm/pagewalk.c:259)
[  305.270152]  walk_page_range (mm/pagewalk.c:333)
[  305.270152]  madvise_willneed (mm/madvise.c:167 mm/madvise.c:211)
[  305.270152]  ? madvise_hwpoison (mm/madvise.c:140)
[  305.270152]  madvise_vma (mm/madvise.c:369)
[  305.270152]  ? find_vma (mm/mmap.c:2021)
[  305.270152]  SyS_madvise (mm/madvise.c:518 mm/madvise.c:448)
[  305.270152]  ia32_do_call (arch/x86/ia32/ia32entry.S:430)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
