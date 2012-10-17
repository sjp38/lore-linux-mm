Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id E7F146B0068
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 17:53:45 -0400 (EDT)
Date: Wed, 17 Oct 2012 23:53:38 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: mm/mmu_notifier: inconsistent lock state in mmu_notifier_register()
Message-ID: <20121017215338.GA3577@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Just got this on 3.7.0-rc1 (last git commit 1867353):

[49048.262912] =================================
[49048.262913] [ INFO: inconsistent lock state ]
[49048.262916] 3.7.0-rc1+ #518 Not tainted
[49048.262918] ---------------------------------
[49048.262919] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
[49048.262922] kswapd0/35 [HC0[0]:SC0[0]:HE1:SE1] takes:
[49048.262924]  (&mapping->i_mmap_mutex){+.+.?.}, at: [<ffffffff81192fbc>] page_referenced+0x9c/0x2e0
[49048.262933] {RECLAIM_FS-ON-W} state was registered at:
[49048.262935]   [<ffffffff810ed5d6>] mark_held_locks+0x86/0x150
[49048.262938]   [<ffffffff810edce7>] lockdep_trace_alloc+0x67/0xc0
[49048.262942]   [<ffffffff811a9323>] kmem_cache_alloc_trace+0x33/0x230
[49048.262945]   [<ffffffff811a1a27>] do_mmu_notifier_register+0x87/0x180
[49048.262948]   [<ffffffff811a1b53>] mmu_notifier_register+0x13/0x20
[49048.262951]   [<ffffffff81006738>] kvm_dev_ioctl+0x428/0x510
[49048.262955]   [<ffffffff811c7ce8>] do_vfs_ioctl+0x98/0x570
[49048.262959]   [<ffffffff811c8251>] sys_ioctl+0x91/0xb0
[49048.262962]   [<ffffffff815df302>] system_call_fastpath+0x16/0x1b
[49048.262966] irq event stamp: 825
[49048.262968] hardirqs last  enabled at (825): [<ffffffff815d6fa0>] _raw_spin_unlock_irq+0x30/0x60
[49048.262971] hardirqs last disabled at (824): [<ffffffff815d6659>] _raw_spin_lock_irq+0x19/0x80
[49048.262975] softirqs last  enabled at (0): [<ffffffff81082170>] copy_process+0x630/0x17c0
[49048.262979] softirqs last disabled at (0): [<          (null)>]           (null)
[49048.262981] 
[49048.262981] other info that might help us debug this:
[49048.262983]  Possible unsafe locking scenario:
[49048.262983] 
[49048.262984]        CPU0
[49048.262986]        ----
[49048.262987]   lock(&mapping->i_mmap_mutex);
[49048.262989]   <Interrupt>
[49048.262991]     lock(&mapping->i_mmap_mutex);
[49048.262993] 
[49048.262993]  *** DEADLOCK ***
[49048.262993] 
[49048.262995] no locks held by kswapd0/35.
[49048.262996] 
[49048.262996] stack backtrace:
[49048.262999] Pid: 35, comm: kswapd0 Not tainted 3.7.0-rc1+ #518
[49048.263000] Call Trace:
[49048.263005]  [<ffffffff815cd988>] print_usage_bug+0x1f5/0x206
[49048.263008]  [<ffffffff8105a21f>] ? save_stack_trace+0x2f/0x50
[49048.263011]  [<ffffffff810ea865>] mark_lock+0x295/0x2f0
[49048.263014]  [<ffffffff810e9c70>] ? print_irq_inversion_bug.part.42+0x1f0/0x1f0
[49048.263017]  [<ffffffff810eae5d>] __lock_acquire+0x59d/0x1c20
[49048.263020]  [<ffffffff815cf163>] ? put_cpu_partial+0x65/0xbd
[49048.263024]  [<ffffffff81052d06>] ? native_sched_clock+0x26/0x90
[49048.263028]  [<ffffffff810c5555>] ? sched_clock_cpu+0xc5/0x120
[49048.263031]  [<ffffffff810ecbe0>] lock_acquire+0x90/0x210
[49048.263034]  [<ffffffff81192fbc>] ? page_referenced+0x9c/0x2e0
[49048.263038]  [<ffffffff815d2ea3>] mutex_lock_nested+0x73/0x3d0
[49048.263041]  [<ffffffff81192fbc>] ? page_referenced+0x9c/0x2e0
[49048.263044]  [<ffffffff81192fbc>] ? page_referenced+0x9c/0x2e0
[49048.263047]  [<ffffffff810e764e>] ? put_lock_stats.isra.26+0xe/0x40
[49048.263051]  [<ffffffff810e7a84>] ? lock_release_holdtime.part.27+0xd4/0x150
[49048.263055]  [<ffffffff8116edab>] ? __remove_mapping+0xab/0x120
[49048.263058]  [<ffffffff81192fbc>] page_referenced+0x9c/0x2e0
[49048.263061]  [<ffffffff81171b94>] shrink_page_list+0x3e4/0xa20
[49048.263064]  [<ffffffff81052d06>] ? native_sched_clock+0x26/0x90
[49048.263068]  [<ffffffff811726f5>] ? shrink_inactive_list+0x165/0x4b0
[49048.263071]  [<ffffffff815d6fa0>] ? _raw_spin_unlock_irq+0x30/0x60
[49048.263075]  [<ffffffff81172787>] shrink_inactive_list+0x1f7/0x4b0
[49048.263079]  [<ffffffff81172e8d>] shrink_lruvec+0x44d/0x550
[49048.263082]  [<ffffffff81173693>] kswapd+0x703/0xdf0
[49048.263086]  [<ffffffff810af470>] ? __init_waitqueue_head+0x60/0x60
[49048.263090]  [<ffffffff81172f90>] ? shrink_lruvec+0x550/0x550
[49048.263093]  [<ffffffff810ae98d>] kthread+0xed/0x100
[49048.263097]  [<ffffffff810ae8a0>] ? flush_kthread_worker+0x190/0x190
[49048.263100]  [<ffffffff815df25c>] ret_from_fork+0x7c/0xb0
[49048.263103]  [<ffffffff810ae8a0>] ? flush_kthread_worker+0x190/0x190

Should we use a GFP_NOFS allocation in mmu_notifier_register() or is
there a better way to fix/avoid this?

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
