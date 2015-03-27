Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2779E6B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 06:07:45 -0400 (EDT)
Received: by wgbgs4 with SMTP id gs4so2692325wgb.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 03:07:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu17si3128015wid.50.2015.03.27.03.07.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 03:07:43 -0700 (PDT)
Message-ID: <55152BED.9050500@suse.cz>
Date: Fri, 27 Mar 2015 11:07:41 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: mm: lru_add_drain_all hangs
References: <5514CF37.1020403@oracle.com>
In-Reply-To: <5514CF37.1020403@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On 03/27/2015 04:32 AM, Sasha Levin wrote:
> Hi all,
> 
> I've started seeing pretty frequent hangs within lru_add_drain_all(). It doesn't
> seem to be hanging on a specific thing, and it appears that even a moderate load
> can cause it to hang (just 50 trinity threads in this case).
> 
> Notice that I've bumped up the hang timer to 20 minutes.
> 
> [ 3605.506554] INFO: task trinity-c0:14641 blocked for more than 1200 seconds.
> [ 3605.507997]       Not tainted 4.0.0-rc5-next-20150324-sasha-00038-g04b74cc #2088
> [ 3605.508889] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 3605.509704] trinity-c0      D ffff8800776efd28 26512 14641   9194 0x10000000
> [ 3605.510704]  ffff8800776efd28 ffff880077633ca8 0000000000000000 0000000000000000
> [ 3605.511568]  ffff8800261e0558 ffff8800261e0530 ffff880077633008 ffff8802f5c33000
> [ 3605.513025]  ffff880077633000 ffff8800776efd08 ffff8800776e8000 ffffed000eedd002
> [ 3605.514004] Call Trace:
> [ 3605.514368] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
> [ 3605.515025] schedule_preempt_disabled (kernel/sched/core.c:2859)
> [ 3605.516025] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
> [ 3605.517265] ? lru_add_drain_all (mm/swap.c:867)
> [ 3605.518663] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
> [ 3605.519305] ? lru_add_drain_all (mm/swap.c:867)
> [ 3605.519879] ? mutex_trylock (kernel/locking/mutex.c:621)
> [ 3605.520982] ? context_tracking_user_exit (kernel/context_tracking.c:164)
> [ 3605.522302] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
> [ 3605.523610] lru_add_drain_all (mm/swap.c:867)
> [ 3605.524628] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
> [ 3605.526112] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
> [ 3605.527819] 1 lock held by trinity-c0/14641:
> [ 3605.528951] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
> [ 3605.530561] Mutex: counter: -1 owner: trinity-c7

So that's the statically defined mutex in lru_add_drain_all() itself, right?
Many processes are waiting for it, except the owner trinity-c7:

> [ 3614.918852] trinity-c7      D ffff8802f4487b58 26976 16252   9410 0x10000000
> [ 3614.919580]  ffff8802f4487b58 ffff8802f6b98ca8 0000000000000000 0000000000000000
> [ 3614.920435]  ffff88017d3e0558 ffff88017d3e0530 ffff8802f6b98008 ffff88016bad0000
> [ 3614.921219]  ffff8802f6b98000 ffff8802f4487b38 ffff8802f4480000 ffffed005e890002
> [ 3614.922069] Call Trace:
> [ 3614.922346] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
> [ 3614.923023] schedule_preempt_disabled (kernel/sched/core.c:2859)
> [ 3614.923707] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
> [ 3614.924486] ? lru_add_drain_all (mm/swap.c:867)
> [ 3614.925211] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
> [ 3614.925970] ? lru_add_drain_all (mm/swap.c:867)
> [ 3614.926692] ? mutex_trylock (kernel/locking/mutex.c:621)
> [ 3614.927464] ? mpol_new (mm/mempolicy.c:285)
> [ 3614.928044] lru_add_drain_all (mm/swap.c:867)
> [ 3614.928608] migrate_prep (mm/migrate.c:64)
> [ 3614.929092] SYSC_mbind (mm/mempolicy.c:1188 mm/mempolicy.c:1319)
> [ 3614.929619] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
> [ 3614.930318] ? __mpol_equal (mm/mempolicy.c:1304)
> [ 3614.930877] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
> [ 3614.931485] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
> [ 3614.932184] SyS_mbind (mm/mempolicy.c:1301)

That looks like trinity-c7 is waiting ot in too, but later on (after some more
listings like this for trinity-c7, probably threads?) we have:

> [ 3615.523625] trinity-c7      D ffff8801fd9c7aa8 26688 16935   9518 0x10000000
> [ 3615.525214]  ffff8801fd9c7aa8 ffff8801fd9c7a48 ffffffffb802b7e0 ffffed0100000000
> [ 3615.528062]  ffff88017d3e0558 ffff88017d3e0530 ffff8801ee47b008 ffff8801bb6e0000
> [ 3615.529887]  ffff8801ee47b000 ffffed002fa7c0d2 ffff8801fd9c0000 ffffed003fb38002
> [ 3615.531155] Call Trace:
> [ 3615.531560] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
> [ 3615.532609] schedule_timeout (kernel/time/timer.c:1475)
> [ 3615.533650] ? console_conditional_schedule (kernel/time/timer.c:1460)
> [ 3615.534961] ? sched_clock_cpu (kernel/sched/clock.c:311)
> [ 3615.536960] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
> [ 3615.539059] ? get_lock_stats (kernel/locking/lockdep.c:249)
> [ 3615.539912] ? mark_held_locks (kernel/locking/lockdep.c:2546)
> [ 3615.540903] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [ 3615.542034] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
> [ 3615.543579] wait_for_completion (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
> [ 3615.545156] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
> [ 3615.546833] ? out_of_line_wait_on_atomic_t (kernel/sched/completion.c:121)
> [ 3615.547976] ? wake_up_state (kernel/sched/core.c:2973)
> [ 3615.548805] flush_work (kernel/workqueue.c:510 kernel/workqueue.c:2735)
> [ 3615.549610] ? flush_work (kernel/workqueue.c:2706 kernel/workqueue.c:2733)
> [ 3615.550487] ? __queue_work (kernel/workqueue.c:1388)
> [ 3615.551481] ? work_busy (kernel/workqueue.c:2727)
> [ 3615.552403] ? destroy_worker (kernel/workqueue.c:2320)
> [ 3615.553302] ? wait_for_completion (kernel/sched/completion.c:64 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
> [ 3615.554486] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
> [ 3615.556238] lru_add_drain_all (include/linux/cpumask.h:116 include/linux/cpumask.h:189 mm/swap.c:883)
> [ 3615.557283] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
> [ 3615.558366] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)

This one is waiting for work queue completion and could be the culprit?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
