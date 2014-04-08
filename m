Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 57DED6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:27:27 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so1162429pde.10
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 08:27:26 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f8si1235499pbc.501.2014.04.08.08.27.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 08:27:26 -0700 (PDT)
Message-ID: <53441540.7070102@oracle.com>
Date: Tue, 08 Apr 2014 11:26:56 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: sched: long running interrupts breaking spinlocks
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

Hi all,

(all the below happened inside mm/ code, so while I don't suspect
it's a mm/ issue you folks got cc'ed anyways!)

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following:

[ 4071.166362] BUG: spinlock lockup suspected on CPU#19, trinity-c19/17092
[ 4071.167188]  lock: 0xffff8803dbae5900, .magic: dead4ead, .owner: trinity-main/1289, .owner_cpu: 0
[ 4071.168213] CPU: 19 PID: 17092 Comm: trinity-c19 Not tainted 3.14.0-next-20140407-sasha-00023-gd35b0d6 #382
[ 4071.169197]  ffff8803dbae5900 ffff8802cabc9838 ffffffffa752ee51 0000000000005bf0
[ 4071.170123]  ffff8800c6a60000 ffff8802cabc9858 ffffffffa7521d7f ffff8803dbae5900
[ 4071.171007]  0000000086c41770 ffff8802cabc9888 ffffffffa41caab4 ffff8803dbae5918
[ 4071.171881] Call Trace:
[ 4071.172170] dump_stack (lib/dump_stack.c:52)
[ 4071.172705] spin_dump (kernel/locking/spinlock_debug.c:68 (discriminator 6))
[ 4071.173246] do_raw_spin_lock (include/linux/nmi.h:35 kernel/locking/spinlock_debug.c:119 kernel/locking/spinlock_debug.c:137)
[ 4071.173855] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[ 4071.174422] ? remove_migration_pte (mm/migrate.c:137)
[ 4071.175092] remove_migration_pte (mm/migrate.c:137)
[ 4071.175799] rmap_walk (mm/rmap.c:1628 mm/rmap.c:1699)
[ 4071.176334] remove_migration_ptes (mm/migrate.c:224)
[ 4071.176954] ? new_page_node (mm/migrate.c:107)
[ 4071.177548] ? remove_migration_pte (mm/migrate.c:195)
[ 4071.178205] move_to_new_page (mm/migrate.c:787)
[ 4071.178806] ? try_to_unmap (mm/rmap.c:1520)
[ 4071.179370] ? try_to_unmap_nonlinear (mm/rmap.c:1117)
[ 4071.180181] ? invalid_migration_vma (mm/rmap.c:1476)
[ 4071.180832] ? page_remove_rmap (mm/rmap.c:1384)
[ 4071.181450] ? page_get_anon_vma (mm/rmap.c:446)
[ 4071.182071] migrate_pages (mm/migrate.c:921 mm/migrate.c:960 mm/migrate.c:1126)
[ 4071.182642] ? perf_trace_mm_numa_migrate_ratelimit (mm/migrate.c:1574)
[ 4071.183440] ? __handle_mm_fault (mm/memory.c:3626 mm/memory.c:3683 mm/memory.c:3796)
[ 4071.184071] migrate_misplaced_page (mm/migrate.c:1733)
[ 4071.184722] __handle_mm_fault (mm/memory.c:3633 mm/memory.c:3683 mm/memory.c:3796)
[ 4071.185354] ? __const_udelay (arch/x86/lib/delay.c:126)
[ 4071.185951] ? __rcu_read_unlock (kernel/rcu/update.c:97)
[ 4071.186564] handle_mm_fault (mm/memory.c:3819)
[ 4071.187157] ? __do_page_fault (arch/x86/mm/fault.c:1153)
[ 4071.187819] __do_page_fault (arch/x86/mm/fault.c:1220)
[ 4071.188420] ? getname_flags (fs/namei.c:145)
[ 4071.189006] ? getname_flags (fs/namei.c:145)
[ 4071.189588] ? set_track (mm/slub.c:527)
[ 4071.190274] ? __slab_alloc (mm/slub.c:2381 (discriminator 2))
[ 4071.190914] ? __slab_alloc (mm/slub.c:2381 (discriminator 2))
[ 4071.191539] ? context_tracking_user_exit (kernel/context_tracking.c:182)
[ 4071.192215] do_page_fault (arch/x86/mm/fault.c:1272 include/linux/jump_label.h:105 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1273)
[ 4071.192748] do_async_page_fault (arch/x86/kernel/kvm.c:263)
[ 4071.193330] async_page_fault (arch/x86/kernel/entry_64.S:1496)
[ 4071.193882] ? strncpy_from_user (lib/strncpy_from_user.c:41 lib/strncpy_from_user.c:109)
[ 4071.194460] getname_flags (fs/namei.c:159)
[ 4071.194996] user_path_at_empty (fs/namei.c:2121)
[ 4071.195597] ? get_parent_ip (kernel/sched/core.c:2471)
[ 4071.196143] ? preempt_count_sub (kernel/sched/core.c:2526)
[ 4071.196728] ? context_tracking_user_exit (arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:182 (discriminator 2))
[ 4071.197397] ? context_tracking_user_exit (arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:182 (discriminator 2))
[ 4071.198084] user_path_at (fs/namei.c:2137)
[ 4071.198615] SyS_lchown (fs/open.c:610 fs/open.c:596 fs/open.c:634 fs/open.c:632)
[ 4071.199121] tracesys (arch/x86/kernel/entry_64.S:749)

Okay, interesting, CPU0 stuck with lock held. Let's see what's going on there:

[ 4071.200151] NMI backtrace for cpu 0
[ 4071.200900] CPU: 0 PID: 1289 Comm: trinity-main Not tainted 3.14.0-next-20140407-sasha-00023-gd35b0d6 #382
[ 4071.202471] task: ffff8800c6a60000 ti: ffff8800c6264000 task.ti: ffff8800c6264000
[ 4071.203747] RIP: delay_tsc (arch/x86/lib/delay.c:68)
[ 4071.205057] RSP: 0018:ffff880030e03c40  EFLAGS: 00000006
[ 4071.205916] RAX: 0000000000000105 RBX: 00000000249fb952 RCX: 0000000000000000
[ 4071.207066] RDX: 0000000000000106 RSI: 0000000000498000 RDI: 0000000000000001
[ 4071.208315] RBP: ffff880030e03c60 R08: 000000000025f4ec R09: ffff8800c6a60e18
[ 4071.209487] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000005853
[ 4071.210042] R13: 0000000000000000 R14: 00000000249fc99c R15: 0000000000000000
[ 4071.210042] FS:  00007ff69a983700(0000) GS:ffff880030e00000(0000) knlGS:0000000000000000
[ 4071.210042] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 4071.210042] CR2: 0000000000000000 CR3: 00000000c5d74000 CR4: 00000000000006b0
[ 4071.210042] DR0: 0000000000696000 DR1: 0000000000696000 DR2: 0000000000000000
[ 4071.210042] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000030602
[ 4071.210042] Stack:
[ 4071.210042]  ffff8800c6a60000 ffffffffa9acfaa0 0000000000000004 0000000000004c34
[ 4071.210042]  ffff880030e03c70 ffffffffa4b0f869 ffff880030e03c90 ffffffffa41dbbe4
[ 4071.210042]  0000000000004c34 ffffffffa8e866e0 ffff880030e03cd0 ffffffffa41bcce5
[ 4071.210042] Call Trace:
[ 4071.210042]  <IRQ>
[ 4071.210042] __const_udelay (arch/x86/lib/delay.c:126)
[ 4071.210042] __rcu_read_unlock (kernel/rcu/update.c:97)
[ 4071.210042] cpuacct_account_field (kernel/sched/cpuacct.c:276)
[ 4071.210042] ? cpuacct_account_field (kernel/sched/cpuacct.c:264)
[ 4071.210042] account_system_time (kernel/sched/cputime.c:201 kernel/sched/cputime.c:228)
[ 4071.210042] __vtime_account_system (kernel/sched/cputime.c:660)
[ 4071.210042] vtime_account_system (include/linux/seqlock.h:239 include/linux/seqlock.h:306 kernel/sched/cputime.c:666)
[ 4071.210042] ? vtime_common_account_irq_enter (kernel/sched/cputime.c:430)
[ 4071.210042] ? dn_neigh_elist (net/decnet/dn_timer.c:49)
[ 4071.210042] vtime_common_account_irq_enter (kernel/sched/cputime.c:430)
[ 4071.210042] irq_enter (include/linux/vtime.h:63 include/linux/vtime.h:115 kernel/softirq.c:336)
[ 4071.210042] smp_apic_timer_interrupt (arch/x86/include/asm/apic.h:685 arch/x86/include/asm/apic.h:691 arch/x86/kernel/apic/apic.c:943)
[ 4071.210042] apic_timer_interrupt (arch/x86/kernel/entry_64.S:1164)
[ 4071.210042] ? retint_restore_args (arch/x86/kernel/entry_64.S:1040)
[ 4071.210042] ? _raw_spin_unlock_irq (arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
[ 4071.210042] ? _raw_spin_unlock_irq (arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
[ 4071.210042] run_timer_softirq (kernel/timer.c:1212 kernel/timer.c:1403)
[ 4071.210042] __do_softirq (kernel/softirq.c:271 include/linux/jump_label.h:105 include/trace/events/irq.h:126 kernel/softirq.c:272)
[ 4071.210042] ? irq_exit (include/linux/vtime.h:82 include/linux/vtime.h:121 kernel/softirq.c:386)
[ 4071.210042] irq_exit (kernel/softirq.c:348 kernel/softirq.c:389)
[ 4071.210042] smp_apic_timer_interrupt (arch/x86/include/asm/irq_regs.h:26 arch/x86/kernel/apic/apic.c:947)
[ 4071.210042] apic_timer_interrupt (arch/x86/kernel/entry_64.S:1164)
[ 4071.210042]  <EOI>
[ 4071.210042] ? retint_restore_args (arch/x86/kernel/entry_64.S:1040)
[ 4071.210042] ? lock_acquire (arch/x86/include/asm/paravirt.h:809 kernel/locking/lockdep.c:3603)
[ 4071.210042] ? __swap_duplicate (mm/swapfile.c:2624)
[ 4071.210042] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[ 4071.210042] ? __swap_duplicate (mm/swapfile.c:2624)
[ 4071.210042] __swap_duplicate (mm/swapfile.c:2624)
[ 4071.210042] swap_duplicate (mm/swapfile.c:2697 (discriminator 2))
[ 4071.210042] copy_pte_range (mm/memory.c:811 mm/memory.c:920)
[ 4071.210042] ? sched_clock_cpu (kernel/sched/clock.c:310)
[ 4071.210042] copy_page_range (mm/memory.c:970 mm/memory.c:1056)
[ 4071.210042] ? rwsem_wake (kernel/locking/rwsem-xadd.c:271)
[ 4071.210042] ? anon_vma_fork (mm/rmap.c:313 mm/rmap.c:311)
[ 4071.210042] copy_process (kernel/fork.c:457 kernel/fork.c:827 kernel/fork.c:887 kernel/fork.c:1344)
[ 4071.210042] ? put_lock_stats.isra.12 (arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[ 4071.210042] do_fork (kernel/fork.c:1605)
[ 4071.210042] ? context_tracking_user_exit (arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:182 (discriminator 2))
[ 4071.210042] ? context_tracking_user_exit (arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:182 (discriminator 2))
[ 4071.210042] SyS_clone (kernel/fork.c:1687)
[ 4071.210042] stub_clone (arch/x86/kernel/entry_64.S:844)
[ 4071.210042] ? tracesys (arch/x86/kernel/entry_64.S:749)
[ 4071.210042] Code: 41 89 c6 29 d8 44 39 e0 bf 01 00 00 00 73 5a e8 85 0d a7 02 65 8b 04 25 a0 da 00 00 85 c0 75 09 e8 44 c3 56 ff 0f 1f 40 00 f3 90 <bf> 01 00 00 00 e8 94 0e a7 02 e8 ff d1 01 00 41 39 c5 74 aa e8

Long running interrupts while spinlock is held? hrm...

On CPU0, the code points to:

static inline void __raw_spin_lock(raw_spinlock_t *lock)
{
        preempt_disable();
        spin_acquire(&lock->dep_map, 0, 0, _RET_IP_);
        LOCK_CONTENDED(lock, do_raw_spin_trylock, do_raw_spin_lock); <== Here
}

So we already disabled preemption.

Something here seems odd. Help?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
