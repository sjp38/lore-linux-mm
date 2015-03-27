Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 09E576B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 23:32:50 -0400 (EDT)
Received: by obcjt1 with SMTP id jt1so62179773obc.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 20:32:49 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a129si427072oig.64.2015.03.26.20.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 20:32:33 -0700 (PDT)
Message-ID: <5514CF37.1020403@oracle.com>
Date: Thu, 26 Mar 2015 23:32:07 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: lru_add_drain_all hangs
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

Hi all,

I've started seeing pretty frequent hangs within lru_add_drain_all(). It doesn't
seem to be hanging on a specific thing, and it appears that even a moderate load
can cause it to hang (just 50 trinity threads in this case).

Notice that I've bumped up the hang timer to 20 minutes.

[ 3605.506554] INFO: task trinity-c0:14641 blocked for more than 1200 seconds.
[ 3605.507997]       Not tainted 4.0.0-rc5-next-20150324-sasha-00038-g04b74cc #2088
[ 3605.508889] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 3605.509704] trinity-c0      D ffff8800776efd28 26512 14641   9194 0x10000000
[ 3605.510704]  ffff8800776efd28 ffff880077633ca8 0000000000000000 0000000000000000
[ 3605.511568]  ffff8800261e0558 ffff8800261e0530 ffff880077633008 ffff8802f5c33000
[ 3605.513025]  ffff880077633000 ffff8800776efd08 ffff8800776e8000 ffffed000eedd002
[ 3605.514004] Call Trace:
[ 3605.514368] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.515025] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3605.516025] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3605.517265] ? lru_add_drain_all (mm/swap.c:867)
[ 3605.518663] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3605.519305] ? lru_add_drain_all (mm/swap.c:867)
[ 3605.519879] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3605.520982] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3605.522302] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3605.523610] lru_add_drain_all (mm/swap.c:867)
[ 3605.524628] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3605.526112] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3605.527819] 1 lock held by trinity-c0/14641:
[ 3605.528951] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3605.530561] Mutex: counter: -1 owner: trinity-c7
[ 3605.531727]   task                        PC stack   pid father
[ 3605.533185] init            S ffff880025597d08 24168     1      0 0x10000000
[ 3605.535040]  ffff880025597d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3605.537694]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8806ad1a8008 ffff8802550fb000
[ 3605.540055]  ffff8806ad1a8000 ffff8806ad1a8000 ffff880025590000 ffffed0004ab2002
[ 3605.542100] Call Trace:
[ 3605.542942] ? do_wait (kernel/exit.c:1504)
[ 3605.544288] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.545279] do_wait (kernel/exit.c:1509)
[ 3605.546316] ? wait_consider_task (kernel/exit.c:1465)
[ 3605.547526] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3605.548808] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3605.549836] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3605.550974] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3605.552592] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3605.553822] ? SyS_waitid (kernel/exit.c:1586)
[ 3605.555484] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3605.557460] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3605.559058] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3605.560046] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3605.561012] kthreadd        S ffff8800255a7d78 28464     2      0 0x10000000
[ 3605.562885]  ffff8800255a7d78 0000000000000000 ffffffffa724f434 0000000000000000
[ 3605.564797]  ffff8802253e0558 ffff8802253e0530 ffff880025598008 ffff8800a6dd0000
[ 3605.567298]  ffff880025598000 ffff880025598000 ffff8800255a0000 ffffed0004ab4002
[ 3605.569459] Call Trace:
[ 3605.569879] ? kthreadd (kernel/kthread.c:496)
[ 3605.570759] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.571527] kthreadd (kernel/kthread.c:498)
[ 3605.572706] ? ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.574623] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3605.576779] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3605.578112] ? kthread_create_on_cpu (kernel/kthread.c:484)
[ 3605.578698] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.579706] ? kthread_create_on_cpu (kernel/kthread.c:484)
[ 3605.580463] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.581239] ? kthread_create_on_cpu (kernel/kthread.c:484)
[ 3605.582912] ksoftirqd/0     S ffff8800255dfcd8 29096     3      2 0x10000000
[ 3605.585027]  ffff8800255dfcd8 0000000000000298 ffffffffa71f85b0 ffff880000000000
[ 3605.588846]  ffff8800261e0558 ffff8800261e0530 ffff88002559b008 ffffffffb4839100
[ 3605.590336]  ffff88002559b000 ffff8800255dfce8 ffff8800255d8000 ffffed0004abb002
[ 3605.592243] Call Trace:
[ 3605.593106] ? __do_softirq (kernel/softirq.c:655)
[ 3605.594790] ? tasklet_init (kernel/softirq.c:650)
[ 3605.596583] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.598278] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3605.599552] ? sort_range (kernel/smpboot.c:106)
[ 3605.600473] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.601553] ? __kthread_parkme (kernel/kthread.c:164)
[ 3605.602688] ? sort_range (kernel/smpboot.c:106)
[ 3605.604139] ? sort_range (kernel/smpboot.c:106)
[ 3605.605088] kthread (kernel/kthread.c:207)
[ 3605.606625] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.608281] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3605.609650] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.610639] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.611874] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.612797] kworker/0:0H    S ffff8800255f7ce8 29112     5      2 0x10000000
[ 3605.614667]  ffff8800255f7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3605.616337]  ffff8800261e0558 ffff8800261e0530 ffff8800255e3008 ffffffffb4839100
[ 3605.617619]  ffff8800255e3000 ffff8800255f7cc8 ffff8800255f0000 ffffed0004abe002
[ 3605.618927] Call Trace:
[ 3605.619311] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3605.620198] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.621440] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3605.622821] ? __schedule (kernel/sched/core.c:2806)
[ 3605.624504] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3605.626507] ? process_one_work (kernel/workqueue.c:2101)
[ 3605.628538] kthread (kernel/kthread.c:207)
[ 3605.629480] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.630436] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.631669] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.632736] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.634234] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.635874] kworker/u48:0   S ffff880025607ce8 27832     6      2 0x10000000
[ 3605.638067]  ffff880025607ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3605.639632]  ffff8802253e0558 ffff8802253e0530 ffff8800255f8008 ffff8802cb7c8000
[ 3605.641062]  ffff8800255f8000 ffff880025607cc8 ffff880025600000 ffffed0004ac0002
[ 3605.642709] Call Trace:
[ 3605.643294] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3605.644707] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.646291] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3605.647536] ? process_one_work (kernel/workqueue.c:2101)
[ 3605.648555] kthread (kernel/kthread.c:207)
[ 3605.649365] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.650283] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.651268] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.652524] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.653826] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.656259] rcu_preempt     S ffff8800256279b8 28296     8      2 0x10000000
[ 3605.658035]  ffff8800256279b8 0000000000000000 ffffffffb1be3f43 0000000000000000
[ 3605.659379]  ffff8800533e0558 ffff8800533e0530 ffff880025618008 ffff8801d0dd0000
[ 3605.660742]  ffff880025618000 ffff880025627998 ffff880025620000 ffffed0004ac4002
[ 3605.662810] Call Trace:
[ 3605.663438] ? schedule_timeout (kernel/time/timer.c:1497)
[ 3605.665205] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.666774] schedule_timeout (kernel/time/timer.c:1498)
[ 3605.668071] ? prepare_to_wait_event (kernel/sched/wait.c:219 (discriminator 1))
[ 3605.669089] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3605.670127] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3605.671357] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3605.673288] ? cascade (kernel/time/timer.c:1429)
[ 3605.674756] ? ___might_sleep (kernel/sched/core.c:7316 (discriminator 1))
[ 3605.676848] rcu_gp_kthread (kernel/rcu/tree.c:2029 (discriminator 32))
[ 3605.678610] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3605.679719] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3605.680633] ? cond_synchronize_rcu (kernel/rcu/tree.c:1983)
[ 3605.681705] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3605.683732] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3605.685609] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3605.687204] ? __schedule (kernel/sched/core.c:2806)
[ 3605.688307] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3605.689304] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3605.690279] ? cond_synchronize_rcu (kernel/rcu/tree.c:1983)
[ 3605.691336] kthread (kernel/kthread.c:207)
[ 3605.692539] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.693815] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.694942] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.696324] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.697519] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.698552] rcu_sched       S ffff880025637b38 28296     9      2 0x10000000
[ 3605.699753]  ffff880025637b38 0000000000000000 0000000000000286 0000000000000000
[ 3605.701032]  ffff8800533e0558 ffff8800533e0530 ffff88002561b008 ffff880048128000
[ 3605.702343]  ffff88002561b000 ffffffffb1eae7e0 ffff880025630000 ffffed0004ac6002
[ 3605.703662] Call Trace:
[ 3605.704337] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.705600] rcu_gp_kthread (kernel/rcu/tree.c:2000 (discriminator 13))
[ 3605.706783] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3605.707700] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3605.708597] ? cond_synchronize_rcu (kernel/rcu/tree.c:1983)
[ 3605.709522] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3605.710500] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3605.711493] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3605.712728] ? __schedule (kernel/sched/core.c:2806)
[ 3605.714043] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3605.715556] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3605.717399] ? cond_synchronize_rcu (kernel/rcu/tree.c:1983)
[ 3605.718581] kthread (kernel/kthread.c:207)
[ 3605.719561] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.720527] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.721512] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.722929] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.724505] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.726002] rcu_bh          S ffff880025647b38 30112    10      2 0x10000000
[ 3605.727393]  ffff880025647b38 ffff880025647b28 0000000000000286 0000000000000000
[ 3605.728730]  ffff8800261e0558 ffff8800261e0530 ffff880025638008 ffff8806ad1a8000
[ 3605.729959]  ffff880025638000 ffffffffb1eae7e0 ffff880025640000 ffffed0004ac8002
[ 3605.731312] Call Trace:
[ 3605.731853] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.732856] rcu_gp_kthread (kernel/rcu/tree.c:2000 (discriminator 13))
[ 3605.733751] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3605.734642] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3605.735800] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3605.736768] ? __schedule (kernel/sched/core.c:2801)
[ 3605.737737] ? cond_synchronize_rcu (kernel/rcu/tree.c:1983)
[ 3605.738658] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3605.739619] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3605.740721] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3605.741702] ? __schedule (kernel/sched/core.c:2806)
[ 3605.743226] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3605.744878] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3605.746893] ? cond_synchronize_rcu (kernel/rcu/tree.c:1983)
[ 3605.748272] kthread (kernel/kthread.c:207)
[ 3605.749284] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.750288] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.751580] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.753557] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.755562] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.757520] rcuop/0         S ffff88002564fbe8 28856    11      2 0x10000000
[ 3605.758823]  ffff88002564fbe8 ffff88001e391f98 0000000000000286 0000000000000000
[ 3605.760040]  ffff8800261e0558 ffff8800261e0530 ffff88002563b008 ffffffffb4839100
[ 3605.761963]  ffff88002563b000 ffffffffb1eaecc0 ffff880025648000 ffffed0004ac9002
[ 3605.763987] Call Trace:
[ 3605.764648] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.765989] rcu_nocb_kthread (kernel/rcu/tree_plugin.h:2157 kernel/rcu/tree_plugin.h:2290)
[ 3605.767505] ? rcu_nocb_kthread (kernel/rcu/rcu.h:108 kernel/rcu/tree_plugin.h:2319)
[ 3605.768659] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3605.769737] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3605.770974] ? rcu_implicit_dynticks_qs (kernel/rcu/tree_plugin.h:2279)
[ 3605.772523] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3605.773946] ? __schedule (kernel/sched/core.c:2806)
[ 3605.775478] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3605.777014] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3605.778638] ? rcu_implicit_dynticks_qs (kernel/rcu/tree_plugin.h:2279)
[ 3605.779686] kthread (kernel/kthread.c:207)
[ 3605.780843] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.782299] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.783507] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.784647] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.786072] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.787167] rcuos/0         S ffff88002565fbe8 28856    12      2 0x10000000
[ 3605.788468]  ffff88002565fbe8 ffff880014968030 0000000000000286 0000000000000000
[ 3605.789269]  ffff8800533e0558 ffff8800533e0530 ffff880025650008 ffff880299c80000
[ 3605.790521]  ffff880025650000 ffffffffb1eaecc0 ffff880025658000 ffffed0004acb002
[ 3605.792870] Call Trace:
[ 3605.793599] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.794661] rcu_nocb_kthread (kernel/rcu/tree_plugin.h:2157 kernel/rcu/tree_plugin.h:2290)
[ 3605.796082] ? rcu_nocb_kthread (kernel/rcu/rcu.h:108 kernel/rcu/tree_plugin.h:2319)
[ 3605.797918] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3605.799033] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3605.799996] ? rcu_implicit_dynticks_qs (kernel/rcu/tree_plugin.h:2279)
[ 3605.801221] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3605.802589] ? __schedule (kernel/sched/core.c:2806)
[ 3605.804274] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3605.806024] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3605.807820] ? rcu_implicit_dynticks_qs (kernel/rcu/tree_plugin.h:2279)
[ 3605.809129] kthread (kernel/kthread.c:207)
[ 3605.809864] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.811396] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.813252] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.815013] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.816937] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.818230] rcuob/0         S ffff880025667be8 29552    13      2 0x10000000
[ 3605.819397]  ffff880025667be8 0000000000000000 0000000000000286 0000000000000000
[ 3605.820825]  ffff8800261e0558 ffff8800261e0530 ffff880025653008 ffffffffb4839100
[ 3605.822768]  ffff880025653000 ffffffffb1eaecc0 ffff880025660000 ffffed0004acc002
[ 3605.825424] Call Trace:
[ 3605.826016] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.827414] rcu_nocb_kthread (kernel/rcu/tree_plugin.h:2157 kernel/rcu/tree_plugin.h:2290)
[ 3605.828672] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3605.829643] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3605.830467] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3605.831474] ? rcu_implicit_dynticks_qs (kernel/rcu/tree_plugin.h:2279)
[ 3605.833077] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3605.834645] ? __schedule (kernel/sched/core.c:2806)
[ 3605.836023] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3605.837571] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3605.838562] ? rcu_implicit_dynticks_qs (kernel/rcu/tree_plugin.h:2279)
[ 3605.839521] kthread (kernel/kthread.c:207)
[ 3605.840253] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.841494] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3605.842848] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.844455] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.845532] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.847023] migration/0     S ffff880025677cd8 29096    14      2 0x10000000
[ 3605.848284]  ffff880025677cd8 ffff8800255d3dd0 ffffffffb5590500 ffff880000000000
[ 3605.849690]  ffff8800261e0558 ffff8800261e0530 ffff880025668008 ffffffffb4839100
[ 3605.850938]  ffff880025668000 ffff880025677cb8 ffff880025670000 ffffed0004ace002
[ 3605.852596] Call Trace:
[ 3605.853407] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3605.854605] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.855560] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3605.856757] ? sort_range (kernel/smpboot.c:106)
[ 3605.857874] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.858905] ? __kthread_parkme (kernel/kthread.c:164)
[ 3605.859755] ? sort_range (kernel/smpboot.c:106)
[ 3605.860796] ? sort_range (kernel/smpboot.c:106)
[ 3605.862525] kthread (kernel/kthread.c:207)
[ 3605.863808] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.864967] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3605.866601] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.867980] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.868885] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.869843] watchdog/0      S ffff8800256afcd8 29096    15      2 0x10000000
[ 3605.871464]  ffff8800256afcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880000000000
[ 3605.873803]  ffff8800261e0558 ffff8800261e0530 ffff88002566b008 ffffffffb4839100
[ 3605.875458]  ffff88002566b000 ffffffffb55962a0 ffff8800256a8000 ffffed0004ad5002
[ 3605.877642] Call Trace:
[ 3605.878091] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3605.879155] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.879885] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3605.880896] ? sort_range (kernel/smpboot.c:106)
[ 3605.881814] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.882984] ? __kthread_parkme (kernel/kthread.c:164)
[ 3605.884572] ? sort_range (kernel/smpboot.c:106)
[ 3605.886366] ? sort_range (kernel/smpboot.c:106)
[ 3605.888130] kthread (kernel/kthread.c:207)
[ 3605.889462] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.890383] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3605.892084] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.893906] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.895657] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.897519] watchdog/1      S ffff880052dd7cd8 29096    16      2 0x10000000
[ 3605.899242]  ffff880052dd7cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880000000000
[ 3605.900488]  ffff8800533e0558 ffff8800533e0530 ffff880052dcb008 ffff8801d0dd0000
[ 3605.902641]  ffff880052dcb000 ffffffffb55962a0 ffff880052dd0000 ffffed000a5ba002
[ 3605.904691] Call Trace:
[ 3605.905680] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3605.907757] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.908872] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3605.909775] ? sort_range (kernel/smpboot.c:106)
[ 3605.910819] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.911700] ? __kthread_parkme (kernel/kthread.c:164)
[ 3605.913937] ? sort_range (kernel/smpboot.c:106)
[ 3605.915339] ? sort_range (kernel/smpboot.c:106)
[ 3605.917023] kthread (kernel/kthread.c:207)
[ 3605.917902] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.919105] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3605.920051] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.921177] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.922979] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.925181] migration/1     S ffff880052de7cd8 29096    17      2 0x10000000
[ 3605.927707]  ffff880052de7cd8 ffff880052dbc158 ffffffffb5590500 ffff880000000000
[ 3605.929902]  ffff8800533e0558 ffff8800533e0530 ffff880052dd8008 ffff8801d0dd0000
[ 3605.931487]  ffff880052dd8000 ffff880052de7cb8 ffff880052de0000 ffffed000a5bc002
[ 3605.933632] Call Trace:
[ 3605.934620] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3605.936758] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.938440] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3605.939822] ? sort_range (kernel/smpboot.c:106)
[ 3605.940943] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.942419] ? __kthread_parkme (kernel/kthread.c:164)
[ 3605.944461] ? sort_range (kernel/smpboot.c:106)
[ 3605.946075] ? sort_range (kernel/smpboot.c:106)
[ 3605.947586] kthread (kernel/kthread.c:207)
[ 3605.948986] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.949890] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3605.950996] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.952667] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.954529] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.956730] ksoftirqd/1     S ffff880052defcd8 28800    18      2 0x10000000
[ 3605.959004]  ffff880052defcd8 0000000000000298 ffffffffa71f85b0 ffff880000000000
[ 3605.960440]  ffff8800533e0558 ffff8800533e0530 ffff880052ddb008 ffff8801278cb000
[ 3605.962206]  ffff880052ddb000 ffff880052defce8 ffff880052de8000 ffffed000a5bd002
[ 3605.965010] Call Trace:
[ 3605.966135] ? __do_softirq (kernel/softirq.c:655)
[ 3605.967935] ? tasklet_init (kernel/softirq.c:650)
[ 3605.969060] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.969851] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3605.970899] ? sort_range (kernel/smpboot.c:106)
[ 3605.971847] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.973625] ? __kthread_parkme (kernel/kthread.c:164)
[ 3605.975271] ? sort_range (kernel/smpboot.c:106)
[ 3605.976148] ? sort_range (kernel/smpboot.c:106)
[ 3605.977052] kthread (kernel/kthread.c:207)
[ 3605.977880] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.978970] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3605.979868] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.981046] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3605.982002] ? flush_kthread_work (kernel/kthread.c:176)
[ 3605.984020] kworker/1:0H    S ffff880052e07ce8 30304    20      2 0x10000000
[ 3605.986949]  ffff880052e07ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3605.988991]  ffff8800533e0558 ffff8800533e0530 ffff880052df3008 ffff8806ad1a8000
[ 3605.990147]  ffff880052df3000 ffff880052e07cc8 ffff880052e00000 ffffed000a5c0002
[ 3605.991614] Call Trace:
[ 3605.992184] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3605.993795] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3605.995487] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3605.997169] ? __schedule (kernel/sched/core.c:2806)
[ 3605.998903] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3605.999873] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.000964] kthread (kernel/kthread.c:207)
[ 3606.002030] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.003793] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.005491] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.007155] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.008567] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.009468] watchdog/2      S ffff88007cdefcd8 29096    22      2 0x10000000
[ 3606.010772]  ffff88007cdefcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880000000000
[ 3606.012970]  ffff88007d3e0558 ffff88007d3e0530 ffff88007cde0008 ffff8802ccdd8000
[ 3606.015575]  ffff88007cde0000 ffffffffb55962a0 ffff88007cde8000 ffffed000f9bd002
[ 3606.018069] Call Trace:
[ 3606.018690] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.020206] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.021343] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.022564] ? sort_range (kernel/smpboot.c:106)
[ 3606.024067] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.025734] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.027482] ? sort_range (kernel/smpboot.c:106)
[ 3606.029150] ? sort_range (kernel/smpboot.c:106)
[ 3606.029929] kthread (kernel/kthread.c:207)
[ 3606.030775] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.031850] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.033382] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.034733] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.036696] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.038261] migration/2     S ffff88007cdf7cd8 29096    23      2 0x10000000
[ 3606.039339]  ffff88007cdf7cd8 ffff88007cddc158 ffffffffb5590500 ffff880000000000
[ 3606.040088]  ffff88007d3e0558 ffff88007d3e0530 ffff88007cde3008 ffff8802ccdd8000
[ 3606.041351]  ffff88007cde3000 ffff88007cdf7cb8 ffff88007cdf0000 ffffed000f9be002
[ 3606.042233] Call Trace:
[ 3606.042527] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.043568] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.044172] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.045119] ? sort_range (kernel/smpboot.c:106)
[ 3606.046627] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.048108] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.049116] ? sort_range (kernel/smpboot.c:106)
[ 3606.049891] ? sort_range (kernel/smpboot.c:106)
[ 3606.050758] kthread (kernel/kthread.c:207)
[ 3606.051559] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.053254] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.054574] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.056582] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.057695] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.058796] ksoftirqd/2     S ffff88007ce07cd8 28864    24      2 0x10000000
[ 3606.059862]  ffff88007ce07cd8 0000000000000298 ffffffffa71f85b0 ffff880000000000
[ 3606.061359]  ffff88007d3e0558 ffff88007d3e0530 ffff88007cdf8008 ffff88007c468000
[ 3606.063342]  ffff88007cdf8000 ffff88007ce07ce8 ffff88007ce00000 ffffed000f9c0002
[ 3606.065861] Call Trace:
[ 3606.066558] ? __do_softirq (kernel/softirq.c:655)
[ 3606.067858] ? tasklet_init (kernel/softirq.c:650)
[ 3606.068966] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.069713] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.070633] ? sort_range (kernel/smpboot.c:106)
[ 3606.071499] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.072997] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.074676] ? sort_range (kernel/smpboot.c:106)
[ 3606.075839] ? sort_range (kernel/smpboot.c:106)
[ 3606.076897] kthread (kernel/kthread.c:207)
[ 3606.078193] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.078795] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.079388] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.079968] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.080526] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.081131] kworker/2:0H    S ffff88007ce27ce8 28904    26      2 0x10000000
[ 3606.081952]  ffff88007ce27ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.083714]  ffff88007d3e0558 ffff88007d3e0530 ffff88007ce18008 ffff88007c46b000
[ 3606.086027]  ffff88007ce18000 ffff88007ce27cc8 ffff88007ce20000 ffffed000f9c4002
[ 3606.087971] Call Trace:
[ 3606.088433] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.089216] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.089734] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.090274] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.091151] kthread (kernel/kthread.c:207)
[ 3606.091658] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.092786] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.094379] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.096022] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.097009] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.097861] kworker/u51:0   S ffff88007cfc7ce8 28904    27      2 0x10000000
[ 3606.099267]  ffff88007cfc7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.100123]  ffff88007d3e0558 ffff88007d3e0530 ffff88007ce1b008 ffff8802cc1c3000
[ 3606.101170]  ffff88007ce1b000 ffff88007cfc7cc8 ffff88007cfc0000 ffffed000f9f8002
[ 3606.102062] Call Trace:
[ 3606.102609] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.104001] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.104517] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.105674] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.106949] kthread (kernel/kthread.c:207)
[ 3606.107711] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.108515] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.109262] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.109888] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.110430] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.111077] watchdog/3      S ffff8800a6ddfcd8 29096    28      2 0x10000000
[ 3606.111953]  ffff8800a6ddfcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880000000000
[ 3606.113847]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a6dd3008 ffff8803c8de8000
[ 3606.115412]  ffff8800a6dd3000 ffffffffb55962a0 ffff8800a6dd8000 ffffed0014dbb002
[ 3606.117103] Call Trace:
[ 3606.117514] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.118169] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.118684] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.119241] ? sort_range (kernel/smpboot.c:106)
[ 3606.119739] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.120240] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.121009] ? sort_range (kernel/smpboot.c:106)
[ 3606.121511] ? sort_range (kernel/smpboot.c:106)
[ 3606.122202] kthread (kernel/kthread.c:207)
[ 3606.123000] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.124008] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.124710] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.125519] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.126112] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.126808] migration/3     S ffff8800a6defcd8 29096    29      2 0x10000000
[ 3606.127705]  ffff8800a6defcd8 ffff8800a6dcc158 ffffffffb5590500 ffff880000000000
[ 3606.128603]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a6de0008 ffff8801d9c2b000
[ 3606.129363]  ffff8800a6de0000 ffff8800a6defcb8 ffff8800a6de8000 ffffed0014dbd002
[ 3606.130114] Call Trace:
[ 3606.130368] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.131075] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.131812] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.132636] ? sort_range (kernel/smpboot.c:106)
[ 3606.133304] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.134561] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.135607] ? sort_range (kernel/smpboot.c:106)
[ 3606.136361] ? sort_range (kernel/smpboot.c:106)
[ 3606.136979] kthread (kernel/kthread.c:207)
[ 3606.137501] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.138086] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.138794] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.139369] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.139875] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.140638] ksoftirqd/3     S ffff8800a6df7cd8 29056    30      2 0x10000000
[ 3606.141391]  ffff8800a6df7cd8 0000000000000298 ffffffffa71f85b0 ffff880000000000
[ 3606.142973]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a6de3008 ffff8801d9c2b000
[ 3606.144685]  ffff8800a6de3000 ffff8800a6df7ce8 ffff8800a6df0000 ffffed0014dbe002
[ 3606.145778] Call Trace:
[ 3606.146139] ? __do_softirq (kernel/softirq.c:655)
[ 3606.146747] ? tasklet_init (kernel/softirq.c:650)
[ 3606.147360] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.147884] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.148487] ? sort_range (kernel/smpboot.c:106)
[ 3606.149046] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.149554] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.150108] ? sort_range (kernel/smpboot.c:106)
[ 3606.151037] ? sort_range (kernel/smpboot.c:106)
[ 3606.151917] kthread (kernel/kthread.c:207)
[ 3606.153305] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.155108] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.156154] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.156863] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.157398] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.158001] kworker/3:0H    S ffff8800a6e17ce8 29112    32      2 0x10000000
[ 3606.159016]  ffff8800a6e17ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.159767]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a6e03008 ffff8803c8de8000
[ 3606.160631]  ffff8800a6e03000 ffff8800a6e17cc8 ffff8800a6e10000 ffffed0014dc2002
[ 3606.161979] Call Trace:
[ 3606.162851] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.165009] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.166205] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.167541] ? __schedule (kernel/sched/core.c:2806)
[ 3606.168072] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3606.168863] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.169517] kthread (kernel/kthread.c:207)
[ 3606.169996] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.170682] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.171446] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.172206] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.173326] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.174797] kworker/u52:0   S ffff8800a6fbfce8 28904    33      2 0x10000000
[ 3606.176721]  ffff8800a6fbfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.178190]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a6fb0008 ffff880085d23000
[ 3606.179372]  ffff8800a6fb0000 ffff8800a6fbfcc8 ffff8800a6fb8000 ffffed0014df7002
[ 3606.180629] Call Trace:
[ 3606.181135] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.182194] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.184030] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.185264] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.186581] kthread (kernel/kthread.c:207)
[ 3606.187370] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.188534] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.189532] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.190447] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.191353] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.192976] watchdog/4      S ffff8800cae17cd8 29096    34      2 0x10000000
[ 3606.195120]  ffff8800cae17cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880000000000
[ 3606.197060]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800cae08008 ffff880518df0000
[ 3606.198416]  ffff8800cae08000 ffffffffb55962a0 ffff8800cae10000 ffffed00195c2002
[ 3606.199552] Call Trace:
[ 3606.199918] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.200996] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.202488] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.204590] ? sort_range (kernel/smpboot.c:106)
[ 3606.206250] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.208097] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.209566] ? sort_range (kernel/smpboot.c:106)
[ 3606.210342] ? sort_range (kernel/smpboot.c:106)
[ 3606.211678] kthread (kernel/kthread.c:207)
[ 3606.212895] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.214688] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.216243] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.217339] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.218238] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.219183] migration/4     S ffff8800cae1fcd8 29096    35      2 0x10000000
[ 3606.220242]  ffff8800cae1fcd8 ffff8800cadec158 ffffffffb5590500 ffff880000000000
[ 3606.222151]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800cae0b008 ffff880518df0000
[ 3606.224432]  ffff8800cae0b000 ffff8800cae1fcb8 ffff8800cae18000 ffffed00195c3002
[ 3606.226620] Call Trace:
[ 3606.227072] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.227984] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.228912] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.229785] ? sort_range (kernel/smpboot.c:106)
[ 3606.230928] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.232321] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.234235] ? sort_range (kernel/smpboot.c:106)
[ 3606.235795] ? sort_range (kernel/smpboot.c:106)
[ 3606.237506] kthread (kernel/kthread.c:207)
[ 3606.238070] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.238773] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.239425] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.240062] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.240730] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.241522] ksoftirqd/4     S ffff8800cae2fcd8 29056    36      2 0x10000000
[ 3606.242555]  ffff8800cae2fcd8 0000000000000298 ffffffffa71f85b0 ffff880000000000
[ 3606.243945]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800cae20008 ffff88021aff0000
[ 3606.245065]  ffff8800cae20000 ffff8800cae2fce8 ffff8800cae28000 ffffed00195c5002
[ 3606.246157] Call Trace:
[ 3606.246544] ? __do_softirq (kernel/softirq.c:655)
[ 3606.247518] ? tasklet_init (kernel/softirq.c:650)
[ 3606.248320] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.249147] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.250092] ? sort_range (kernel/smpboot.c:106)
[ 3606.251278] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.252742] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.254130] ? sort_range (kernel/smpboot.c:106)
[ 3606.256123] ? sort_range (kernel/smpboot.c:106)
[ 3606.258106] kthread (kernel/kthread.c:207)
[ 3606.259789] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.261141] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.263134] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.265106] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.266854] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.268441] kworker/4:0H    S ffff8800cae4fce8 29112    38      2 0x10000000
[ 3606.270531]  ffff8800cae4fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.272558]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800cae40008 ffff880518df0000
[ 3606.275219]  ffff8800cae40000 ffff8800cae4fcc8 ffff8800cae48000 ffffed00195c9002
[ 3606.277749] Call Trace:
[ 3606.278394] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.279783] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.280634] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.281589] ? __schedule (kernel/sched/core.c:2806)
[ 3606.283056] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3606.284325] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.286502] kthread (kernel/kthread.c:207)
[ 3606.288093] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.289805] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.290992] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.292179] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.293891] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.296118] kworker/u53:0   S ffff8800cafefce8 29024    39      2 0x10000000
[ 3606.298544]  ffff8800cafefce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.300571]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800cae43008 ffff8800c9e58000
[ 3606.302893]  ffff8800cae43000 ffff8800cafefcc8 ffff8800cafe8000 ffffed00195fd002
[ 3606.305817] Call Trace:
[ 3606.306727] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.308982] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.310287] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.311184] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.312754] kthread (kernel/kthread.c:207)
[ 3606.314300] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.316021] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.317886] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.318909] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.319734] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.320810] watchdog/5      S ffff880128ddfcd8 29096    40      2 0x10000000
[ 3606.322148]  ffff880128ddfcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880100000000
[ 3606.324461]  ffff8801291e0558 ffff8801291e0530 ffff880128dd0008 ffff88065d1d8000
[ 3606.326183]  ffff880128dd0000 ffffffffb55962a0 ffff880128dd8000 ffffed00251bb002
[ 3606.327709] Call Trace:
[ 3606.328094] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.329008] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.329792] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.330666] ? sort_range (kernel/smpboot.c:106)
[ 3606.331824] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.333110] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.334900] ? sort_range (kernel/smpboot.c:106)
[ 3606.336493] ? sort_range (kernel/smpboot.c:106)
[ 3606.338222] kthread (kernel/kthread.c:207)
[ 3606.339556] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.340449] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.341537] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.343254] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.344908] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.346908] migration/5     S ffff880128de7cd8 29096    41      2 0x10000000
[ 3606.348443]  ffff880128de7cd8 ffff880128dcbdd0 ffffffffb5590500 ffff880100000000
[ 3606.349617]  ffff8801291e0558 ffff8801291e0530 ffff880128dd3008 ffff88065d1d8000
[ 3606.351021]  ffff880128dd3000 ffff880128de7cb8 ffff880128de0000 ffffed00251bc002
[ 3606.352674] Call Trace:
[ 3606.353470] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.355413] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.357177] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.358826] ? sort_range (kernel/smpboot.c:106)
[ 3606.359605] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.360389] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.361252] ? sort_range (kernel/smpboot.c:106)
[ 3606.362576] ? sort_range (kernel/smpboot.c:106)
[ 3606.364403] kthread (kernel/kthread.c:207)
[ 3606.365507] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.366968] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.368156] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.369482] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.370275] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.371218] ksoftirqd/5     S ffff880128df7cd8 29056    42      2 0x10000000
[ 3606.372748]  ffff880128df7cd8 0000000000000298 ffffffffa71f85b0 ffff880100000000
[ 3606.375275]  ffff8801291e0558 ffff8801291e0530 ffff880128de8008 ffff880319c78000
[ 3606.377181]  ffff880128de8000 ffff880128df7ce8 ffff880128df0000 ffffed00251be002
[ 3606.378620] Call Trace:
[ 3606.379036] ? __do_softirq (kernel/softirq.c:655)
[ 3606.379864] ? tasklet_init (kernel/softirq.c:650)
[ 3606.380846] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.381663] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.382719] ? sort_range (kernel/smpboot.c:106)
[ 3606.383822] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.384934] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.386264] ? sort_range (kernel/smpboot.c:106)
[ 3606.387064] ? sort_range (kernel/smpboot.c:106)
[ 3606.387916] kthread (kernel/kthread.c:207)
[ 3606.388860] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.389770] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.390717] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.391648] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.392613] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.394322] kworker/5:0H    S ffff880128e17ce8 29112    44      2 0x10000000
[ 3606.396151]  ffff880128e17ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.397907]  ffff8801291e0558 ffff8801291e0530 ffff880128e08008 ffff88065d1d8000
[ 3606.399313]  ffff880128e08000 ffff880128e17cc8 ffff880128e10000 ffffed00251c2002
[ 3606.400457] Call Trace:
[ 3606.400895] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.402488] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.404189] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.405487] ? __schedule (kernel/sched/core.c:2806)
[ 3606.407077] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3606.408184] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.409148] kthread (kernel/kthread.c:207)
[ 3606.410110] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.411278] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.412974] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.414808] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.416592] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.418481] kworker/u54:0   S ffff880128fbfce8 28904    45      2 0x10000000
[ 3606.419745]  ffff880128fbfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.420981]  ffff8801291e0558 ffff8801291e0530 ffff880128e0b008 ffff8802f5c30000
[ 3606.423076]  ffff880128e0b000 ffff880128fbfcc8 ffff880128fb8000 ffffed00251f7002
[ 3606.424992] Call Trace:
[ 3606.425431] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.426576] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.427366] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.428364] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.429404] kthread (kernel/kthread.c:207)
[ 3606.430224] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.431332] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.432904] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.434556] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.435799] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.436931] watchdog/6      S ffff880152e0fcd8 29096    46      2 0x10000000
[ 3606.438236]  ffff880152e0fcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880100000000
[ 3606.439453]  ffff8801533e0558 ffff8801533e0530 ffff880152e00008 ffff88079d1e8000
[ 3606.440636]  ffff880152e00000 ffffffffb55962a0 ffff880152e08000 ffffed002a5c1002
[ 3606.442555] Call Trace:
[ 3606.443198] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.444300] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.445260] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.446764] ? sort_range (kernel/smpboot.c:106)
[ 3606.447645] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.448604] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.449480] ? sort_range (kernel/smpboot.c:106)
[ 3606.450239] ? sort_range (kernel/smpboot.c:106)
[ 3606.451124] kthread (kernel/kthread.c:207)
[ 3606.451994] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.453022] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.454124] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.455254] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.456422] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.457509] migration/6     S ffff880152e17cd8 29096    47      2 0x10000000
[ 3606.458832]  ffff880152e17cd8 ffff880152dec158 ffffffffb5590500 ffff880100000000
[ 3606.459966]  ffff8801533e0558 ffff8801533e0530 ffff880152e03008 ffff88079d1e8000
[ 3606.461210]  ffff880152e03000 ffff880152e17cb8 ffff880152e10000 ffffed002a5c2002
[ 3606.462716] Call Trace:
[ 3606.463693] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.464821] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.466131] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.467189] ? sort_range (kernel/smpboot.c:106)
[ 3606.467980] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.468859] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.469711] ? sort_range (kernel/smpboot.c:106)
[ 3606.470568] ? sort_range (kernel/smpboot.c:106)
[ 3606.471363] kthread (kernel/kthread.c:207)
[ 3606.472511] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.474139] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.475807] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.477624] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.478677] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.479565] ksoftirqd/6     S ffff880152e27cd8 29056    48      2 0x10000000
[ 3606.480860]  ffff880152e27cd8 0000000000000298 ffffffffa71f85b0 ffff880100000000
[ 3606.482749]  ffff8801533e0558 ffff8801533e0530 ffff880152e18008 ffff880299c3b000
[ 3606.484467]  ffff880152e18000 ffff880152e27ce8 ffff880152e20000 ffffed002a5c4002
[ 3606.485751] Call Trace:
[ 3606.486225] ? __do_softirq (kernel/softirq.c:655)
[ 3606.487248] ? tasklet_init (kernel/softirq.c:650)
[ 3606.488115] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.489043] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.489904] ? sort_range (kernel/smpboot.c:106)
[ 3606.490841] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.491960] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.492937] ? sort_range (kernel/smpboot.c:106)
[ 3606.494059] ? sort_range (kernel/smpboot.c:106)
[ 3606.494853] kthread (kernel/kthread.c:207)
[ 3606.495815] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.496868] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.497861] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.498846] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.499689] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.500623] kworker/6:0H    S ffff880152e47ce8 29112    50      2 0x10000000
[ 3606.502392]  ffff880152e47ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.504591]  ffff8801533e0558 ffff8801533e0530 ffff880152e38008 ffff88079d1e8000
[ 3606.506863]  ffff880152e38000 ffff880152e47cc8 ffff880152e40000 ffffed002a5c8002
[ 3606.508948] Call Trace:
[ 3606.509492] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.510357] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.511326] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.512803] ? __schedule (kernel/sched/core.c:2806)
[ 3606.514613] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3606.516463] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.518342] kthread (kernel/kthread.c:207)
[ 3606.519819] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.521302] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.523130] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.525371] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.527364] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.528942] watchdog/7      S ffff88017cde7cd8 29096    52      2 0x10000000
[ 3606.530182]  ffff88017cde7cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880100000000
[ 3606.531639]  ffff88017d3e0558 ffff88017d3e0530 ffff88017cdd3008 ffff8808dd1e0000
[ 3606.533620]  ffff88017cdd3000 ffffffffb55962a0 ffff88017cde0000 ffffed002f9bc002
[ 3606.536788] Call Trace:
[ 3606.537790] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.539076] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.539833] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.540815] ? sort_range (kernel/smpboot.c:106)
[ 3606.541884] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.543494] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.544823] ? sort_range (kernel/smpboot.c:106)
[ 3606.545969] ? sort_range (kernel/smpboot.c:106)
[ 3606.546893] kthread (kernel/kthread.c:207)
[ 3606.547881] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.548904] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.549820] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.550936] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.551743] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.552827] migration/7     S ffff88017cdf7cd8 29096    53      2 0x10000000
[ 3606.554143]  ffff88017cdf7cd8 ffff88017cdc0158 ffffffffb5590500 ffff880100000000
[ 3606.555603]  ffff88017d3e0558 ffff88017d3e0530 ffff88017cde8008 ffff8808dd1e0000
[ 3606.557226]  ffff88017cde8000 ffff88017cdf7cb8 ffff88017cdf0000 ffffed002f9be002
[ 3606.558744] Call Trace:
[ 3606.559123] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.560155] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.561119] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.562092] ? sort_range (kernel/smpboot.c:106)
[ 3606.563359] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.564317] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.565351] ? sort_range (kernel/smpboot.c:106)
[ 3606.566391] ? sort_range (kernel/smpboot.c:106)
[ 3606.567242] kthread (kernel/kthread.c:207)
[ 3606.567990] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.569079] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.570048] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.571232] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.572081] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.573188] ksoftirqd/7     S ffff88017cdffcd8 29056    54      2 0x10000000
[ 3606.574569]  ffff88017cdffcd8 0000000000000298 ffffffffa71f85b0 ffff880100000000
[ 3606.575853]  ffff88017d3e0558 ffff88017d3e0530 ffff88017cdeb008 ffff880126b08000
[ 3606.577616]  ffff88017cdeb000 ffff88017cdffce8 ffff88017cdf8000 ffffed002f9bf002
[ 3606.578993] Call Trace:
[ 3606.579401] ? __do_softirq (kernel/softirq.c:655)
[ 3606.580256] ? tasklet_init (kernel/softirq.c:650)
[ 3606.581092] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.581971] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.583581] ? sort_range (kernel/smpboot.c:106)
[ 3606.585029] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.586808] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.587778] ? sort_range (kernel/smpboot.c:106)
[ 3606.588511] ? sort_range (kernel/smpboot.c:106)
[ 3606.589300] kthread (kernel/kthread.c:207)
[ 3606.589764] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.590255] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.591072] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.591836] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.592647] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.593594] kworker/7:0H    S ffff88017ce1fce8 28872    56      2 0x10000000
[ 3606.595062]  ffff88017ce1fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.596408]  ffff88017d3e0558 ffff88017d3e0530 ffff88017ce0b008 ffff88017c8d8000
[ 3606.597902]  ffff88017ce0b000 ffff88017ce1fcc8 ffff88017ce18000 ffffed002f9c3002
[ 3606.598981] Call Trace:
[ 3606.599187] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.599691] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.600181] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.600982] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.601738] kthread (kernel/kthread.c:207)
[ 3606.602758] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.603807] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.604866] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.605688] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.607049] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.608141] kworker/u56:0   S ffff88017cfc7ce8 28904    57      2 0x10000000
[ 3606.609286]  ffff88017cfc7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.610514]  ffff88017d3e0558 ffff88017d3e0530 ffff88017cfb8008 ffff88017c190000
[ 3606.612078]  ffff88017cfb8000 ffff88017cfc7cc8 ffff88017cfc0000 ffffed002f9f8002
[ 3606.613672] Call Trace:
[ 3606.614323] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.616070] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.617119] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.618257] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.619177] kthread (kernel/kthread.c:207)
[ 3606.619918] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.620941] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.623294] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.624448] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.625915] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.627919] watchdog/8      S ffff8801a6e0fcd8 28824    58      2 0x10000000
[ 3606.629396]  ffff8801a6e0fcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880100000000
[ 3606.630311]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6e00008 ffff8800256f8000
[ 3606.631411]  ffff8801a6e00000 ffffffffb55962a0 ffff8801a6e08000 ffffed0034dc1002
[ 3606.633007] Call Trace:
[ 3606.633558] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.634547] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.635275] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.636327] ? sort_range (kernel/smpboot.c:106)
[ 3606.637482] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.638700] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.639257] ? sort_range (kernel/smpboot.c:106)
[ 3606.639756] ? sort_range (kernel/smpboot.c:106)
[ 3606.640405] kthread (kernel/kthread.c:207)
[ 3606.640944] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.641660] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.642560] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.643912] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.644487] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.645128] migration/8     S ffff8801a6e17cd8 29096    59      2 0x10000000
[ 3606.646999]  ffff8801a6e17cd8 ffff8801a6de4158 ffffffffb5590500 ffff880100000000
[ 3606.647935]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6e03008 ffff8800256f8000
[ 3606.648733]  ffff8801a6e03000 ffff8801a6e17cb8 ffff8801a6e10000 ffffed0034dc2002
[ 3606.649526] Call Trace:
[ 3606.649767] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.650514] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.651064] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.651731] ? sort_range (kernel/smpboot.c:106)
[ 3606.652267] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.653062] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.653785] ? sort_range (kernel/smpboot.c:106)
[ 3606.654331] ? sort_range (kernel/smpboot.c:106)
[ 3606.655023] kthread (kernel/kthread.c:207)
[ 3606.655788] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.657393] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.659027] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.659643] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.660170] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.660872] ksoftirqd/8     S ffff8801a6e27cd8 29056    60      2 0x10000000
[ 3606.661802]  ffff8801a6e27cd8 0000000000000298 ffffffffa71f85b0 ffff880100000000
[ 3606.662951]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6e18008 ffff88005191b000
[ 3606.664415]  ffff8801a6e18000 ffff8801a6e27ce8 ffff8801a6e20000 ffffed0034dc4002
[ 3606.665357] Call Trace:
[ 3606.665626] ? __do_softirq (kernel/softirq.c:655)
[ 3606.666163] ? tasklet_init (kernel/softirq.c:650)
[ 3606.667078] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.667834] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.668405] ? sort_range (kernel/smpboot.c:106)
[ 3606.668925] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.669428] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.669988] ? sort_range (kernel/smpboot.c:106)
[ 3606.670508] ? sort_range (kernel/smpboot.c:106)
[ 3606.671048] kthread (kernel/kthread.c:207)
[ 3606.671624] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.672933] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.673905] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.674605] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.675251] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.677236] kworker/8:0H    S ffff8801a6e3fce8 29112    62      2 0x10000000
[ 3606.678243]  ffff8801a6e3fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.679175]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6e30008 ffff8800256f8000
[ 3606.679922]  ffff8801a6e30000 ffff8801a6e3fcc8 ffff8801a6e38000 ffffed0034dc7002
[ 3606.680682] Call Trace:
[ 3606.680955] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.681913] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.682854] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.683535] ? __schedule (kernel/sched/core.c:2806)
[ 3606.684070] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3606.684689] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.685436] kthread (kernel/kthread.c:207)
[ 3606.686008] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.687118] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.687735] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.688422] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.688943] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.689523] watchdog/9      S ffff8801d0df7cd8 29096    64      2 0x10000000
[ 3606.690258]  ffff8801d0df7cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880100000000
[ 3606.691078]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0dd3008 ffff8801fa268000
[ 3606.691903]  ffff8801d0dd3000 ffffffffb55962a0 ffff8801d0df0000 ffffed003a1be002
[ 3606.693407] Call Trace:
[ 3606.693643] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.694329] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.694860] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.695655] ? sort_range (kernel/smpboot.c:106)
[ 3606.696356] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.697039] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.697822] ? sort_range (kernel/smpboot.c:106)
[ 3606.698939] ? sort_range (kernel/smpboot.c:106)
[ 3606.699499] kthread (kernel/kthread.c:207)
[ 3606.700019] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.700626] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.701311] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.702218] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.703172] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.703809] migration/9     S ffff8801d0e07cd8 29096    65      2 0x10000000
[ 3606.704630]  ffff8801d0e07cd8 ffff8801d0dc0158 ffffffffb5590500 ffff880100000000
[ 3606.705514]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0df8008 ffff8800256fb000
[ 3606.707658]  ffff8801d0df8000 ffff8801d0e07cb8 ffff8801d0e00000 ffffed003a1c0002
[ 3606.709459] Call Trace:
[ 3606.709834] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.710938] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.711704] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.713461] ? sort_range (kernel/smpboot.c:106)
[ 3606.715012] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.716577] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.718262] ? sort_range (kernel/smpboot.c:106)
[ 3606.719721] ? sort_range (kernel/smpboot.c:106)
[ 3606.720574] kthread (kernel/kthread.c:207)
[ 3606.721362] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.723017] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.724866] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.726825] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.727687] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.728831] ksoftirqd/9     S ffff8801d0e0fcd8 29056    66      2 0x10000000
[ 3606.730626]  ffff8801d0e0fcd8 0000000000000298 ffffffffa71f85b0 ffff880100000000
[ 3606.731961]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0dfb008 ffff880319c78000
[ 3606.733673]  ffff8801d0dfb000 ffff8801d0e0fce8 ffff8801d0e08000 ffffed003a1c1002
[ 3606.735238] Call Trace:
[ 3606.735631] ? __do_softirq (kernel/softirq.c:655)
[ 3606.736735] ? tasklet_init (kernel/softirq.c:650)
[ 3606.737667] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.738447] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.739359] ? sort_range (kernel/smpboot.c:106)
[ 3606.740125] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.740962] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.741845] ? sort_range (kernel/smpboot.c:106)
[ 3606.743231] ? sort_range (kernel/smpboot.c:106)
[ 3606.744294] kthread (kernel/kthread.c:207)
[ 3606.745201] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.746439] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.747838] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.748800] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.749628] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.750537] kworker/9:0H    S ffff8801d0e27ce8 29112    68      2 0x10000000
[ 3606.751715]  ffff8801d0e27ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.753052]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0e13008 ffff8800256fb000
[ 3606.754425]  ffff8801d0e13000 ffff8801d0e27cc8 ffff8801d0e20000 ffffed003a1c4002
[ 3606.755724] Call Trace:
[ 3606.756254] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.757634] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.758438] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.759624] ? __schedule (kernel/sched/core.c:2806)
[ 3606.760451] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3606.761436] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.762948] kthread (kernel/kthread.c:207)
[ 3606.764182] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.765738] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.767767] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.769388] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.770737] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.771365] kworker/u58:0   R  running task    28904    69      2 0x10000000
[ 3606.772735]  ffff8801d0fd7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.774027]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0fc8008 ffff88028fe28000
[ 3606.774908]  ffff8801d0fc8000 ffff8801d0fd7cc8 ffff8801d0fd0000 ffffed003a1fa002
[ 3606.776642] Call Trace:
[ 3606.777174] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.777788] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.778523] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.779201] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.779797] kthread (kernel/kthread.c:207)
[ 3606.780458] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.781174] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.782009] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.783167] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.783873] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.784719] watchdog/10     S ffff8801fae17cd8 29096    70      2 0x10000000
[ 3606.785939]  ffff8801fae17cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880100000000
[ 3606.787094]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fae08008 ffff880052dc8000
[ 3606.787878]  ffff8801fae08000 ffffffffb55962a0 ffff8801fae10000 ffffed003f5c2002
[ 3606.788864] Call Trace:
[ 3606.789120] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.789814] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.790439] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.791188] ? sort_range (kernel/smpboot.c:106)
[ 3606.791798] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.792368] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.793216] ? sort_range (kernel/smpboot.c:106)
[ 3606.794023] ? sort_range (kernel/smpboot.c:106)
[ 3606.794763] kthread (kernel/kthread.c:207)
[ 3606.795846] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.797496] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.798215] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.798899] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.799430] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.800066] migration/10    S ffff8801fae1fcd8 29096    71      2 0x10000000
[ 3606.800899]  ffff8801fae1fcd8 ffff8801fadd8158 ffffffffb5590500 ffff880100000000
[ 3606.801853]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fae0b008 ffff880052dc8000
[ 3606.803363]  ffff8801fae0b000 ffff8801fae1fcb8 ffff8801fae18000 ffffed003f5c3002
[ 3606.804289] Call Trace:
[ 3606.804588] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.805602] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.806793] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.807914] ? sort_range (kernel/smpboot.c:106)
[ 3606.809141] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.809779] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.810442] ? sort_range (kernel/smpboot.c:106)
[ 3606.811073] ? sort_range (kernel/smpboot.c:106)
[ 3606.811622] kthread (kernel/kthread.c:207)
[ 3606.812436] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.813578] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.814455] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.815132] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.815695] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.817121] ksoftirqd/10    S ffff8801fae2fcd8 29056    72      2 0x10000000
[ 3606.818315]  ffff8801fae2fcd8 0000000000000298 ffffffffa71f85b0 ffff880100000000
[ 3606.819668]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fae20008 ffff88013ef13000
[ 3606.820502]  ffff8801fae20000 ffff8801fae2fce8 ffff8801fae28000 ffffed003f5c5002
[ 3606.821289] Call Trace:
[ 3606.821645] ? __do_softirq (kernel/softirq.c:655)
[ 3606.822931] ? tasklet_init (kernel/softirq.c:650)
[ 3606.823661] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.824237] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.824857] ? sort_range (kernel/smpboot.c:106)
[ 3606.826140] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.827321] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.827926] ? sort_range (kernel/smpboot.c:106)
[ 3606.828533] ? sort_range (kernel/smpboot.c:106)
[ 3606.829080] kthread (kernel/kthread.c:207)
[ 3606.829579] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.830232] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.831048] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.831789] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.832894] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.833812] kworker/10:0H   S ffff8801fae4fce8 29112    74      2 0x10000000
[ 3606.834721]  ffff8801fae4fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.836473]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fae40008 ffff880052dc8000
[ 3606.838493]  ffff8801fae40000 ffff8801fae4fcc8 ffff8801fae48000 ffffed003f5c9002
[ 3606.839356] Call Trace:
[ 3606.839615] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.840215] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.840767] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.841371] ? __schedule (kernel/sched/core.c:2806)
[ 3606.842288] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3606.843337] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.844148] kthread (kernel/kthread.c:207)
[ 3606.845124] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.846343] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.847425] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.848091] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.848923] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.849612] kworker/u59:0   S ffff8801fafdfce8 28744    75      2 0x10000000
[ 3606.850492]  ffff8801fafdfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.851344]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fae43008 ffff8801f7593000
[ 3606.852808]  ffff8801fae43000 ffff8801fafdfcc8 ffff8801fafd8000 ffffed003f5fb002
[ 3606.853845] Call Trace:
[ 3606.854217] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.854788] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.856016] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.857087] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.857797] kthread (kernel/kthread.c:207)
[ 3606.858460] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.859090] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.859707] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.860422] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.861049] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.861684] watchdog/11     S ffff880224defcd8 29096    76      2 0x10000000
[ 3606.863146]  ffff880224defcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880200000000
[ 3606.864554]  ffff8802253e0558 ffff8802253e0530 ffff880224dd3008 ffff8800a6dd0000
[ 3606.865830]  ffff880224dd3000 ffffffffb55962a0 ffff880224de8000 ffffed00449bd002
[ 3606.867725] Call Trace:
[ 3606.868115] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.869051] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.869503] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.870230] ? sort_range (kernel/smpboot.c:106)
[ 3606.871206] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.872019] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.873580] ? sort_range (kernel/smpboot.c:106)
[ 3606.875094] ? sort_range (kernel/smpboot.c:106)
[ 3606.876413] kthread (kernel/kthread.c:207)
[ 3606.877330] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.878077] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.878864] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.879488] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.880013] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.880892] migration/11    S ffff880224dffcd8 29096    77      2 0x10000000
[ 3606.882099]  ffff880224dffcd8 ffff880224de3dd0 ffffffffb5590500 ffff880200000000
[ 3606.884177]  ffff8802253e0558 ffff8802253e0530 ffff880224df0008 ffff8800a6dd0000
[ 3606.885989]  ffff880224df0000 ffff880224dffcb8 ffff880224df8000 ffffed00449bf002
[ 3606.888029] Call Trace:
[ 3606.888420] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.889582] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.890316] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.891184] ? sort_range (kernel/smpboot.c:106)
[ 3606.891716] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.892395] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.893937] ? sort_range (kernel/smpboot.c:106)
[ 3606.895121] ? sort_range (kernel/smpboot.c:106)
[ 3606.895759] kthread (kernel/kthread.c:207)
[ 3606.896441] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.897352] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.898079] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.898836] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.899379] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.900045] ksoftirqd/11    S ffff880224e07cd8 29056    78      2 0x10000000
[ 3606.900905]  ffff880224e07cd8 0000000000000298 ffffffffa71f85b0 ffff880200000000
[ 3606.902136]  ffff8802253e0558 ffff8802253e0530 ffff880224df3008 ffff880224fbb000
[ 3606.903898]  ffff880224df3000 ffff880224e07ce8 ffff880224e00000 ffffed00449c0002
[ 3606.905245] Call Trace:
[ 3606.905782] ? __do_softirq (kernel/softirq.c:655)
[ 3606.906686] ? tasklet_init (kernel/softirq.c:650)
[ 3606.907481] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.908065] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.908759] ? sort_range (kernel/smpboot.c:106)
[ 3606.909293] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.909879] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.910550] ? sort_range (kernel/smpboot.c:106)
[ 3606.911094] ? sort_range (kernel/smpboot.c:106)
[ 3606.911603] kthread (kernel/kthread.c:207)
[ 3606.912186] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.913172] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.914951] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.916261] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.916964] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.917797] kworker/11:0H   S ffff880224e1fce8 29112    80      2 0x10000000
[ 3606.918673]  ffff880224e1fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.919435]  ffff8802253e0558 ffff8802253e0530 ffff880224e0b008 ffff8800a6dd0000
[ 3606.920276]  ffff880224e0b000 ffff880224e1fcc8 ffff880224e18000 ffffed00449c3002
[ 3606.921132] Call Trace:
[ 3606.921456] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.922513] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.924301] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.925676] ? __schedule (kernel/sched/core.c:2806)
[ 3606.927026] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3606.928419] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.929432] kthread (kernel/kthread.c:207)
[ 3606.930230] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.931156] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.932654] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.934336] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.935367] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.936962] kworker/u60:0   S ffff880224fc7ce8 29024    81      2 0x10000000
[ 3606.938440]  ffff880224fc7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3606.939989]  ffff8802253e0558 ffff8802253e0530 ffff880224fb8008 ffff880223d78000
[ 3606.941370]  ffff880224fb8000 ffff880224fc7cc8 ffff880224fc0000 ffffed00449f8002
[ 3606.943633] Call Trace:
[ 3606.944087] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3606.945309] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.946760] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3606.947916] ? process_one_work (kernel/workqueue.c:2101)
[ 3606.948921] kthread (kernel/kthread.c:207)
[ 3606.949661] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.950725] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3606.952056] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.953620] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.954881] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.956083] watchdog/12     S ffff88024ee17cd8 29096    82      2 0x10000000
[ 3606.957275]  ffff88024ee17cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880200000000
[ 3606.958665]  ffff88024f3e0558 ffff88024f3e0530 ffff88024ee08008 ffff88017cdd0000
[ 3606.959884]  ffff88024ee08000 ffffffffb55962a0 ffff88024ee10000 ffffed0049dc2002
[ 3606.961140] Call Trace:
[ 3606.961533] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3606.963132] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.964168] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.965996] ? sort_range (kernel/smpboot.c:106)
[ 3606.967383] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.968257] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.969199] ? sort_range (kernel/smpboot.c:106)
[ 3606.970066] ? sort_range (kernel/smpboot.c:106)
[ 3606.970869] kthread (kernel/kthread.c:207)
[ 3606.971871] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.973857] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.975640] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.976607] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.977561] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.978651] migration/12    S ffff88024ee1fcd8 29096    83      2 0x10000000
[ 3606.979998]  ffff88024ee1fcd8 ffff88024edec158 ffffffffb5590500 ffff880200000000
[ 3606.981645]  ffff88024f3e0558 ffff88024f3e0530 ffff88024ee0b008 ffff88017cdd0000
[ 3606.983937]  ffff88024ee0b000 ffff88024ee1fcb8 ffff88024ee18000 ffffed0049dc3002
[ 3606.985926] Call Trace:
[ 3606.986632] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3606.987736] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.988551] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3606.989451] ? sort_range (kernel/smpboot.c:106)
[ 3606.990302] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3606.991109] ? __kthread_parkme (kernel/kthread.c:164)
[ 3606.992125] ? sort_range (kernel/smpboot.c:106)
[ 3606.993473] ? sort_range (kernel/smpboot.c:106)
[ 3606.994340] kthread (kernel/kthread.c:207)
[ 3606.995226] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.996528] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3606.997659] ? flush_kthread_work (kernel/kthread.c:176)
[ 3606.998859] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3606.999635] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.000728] ksoftirqd/12    S ffff88024ee2fcd8 29056    84      2 0x10000000
[ 3607.002509]  ffff88024ee2fcd8 0000000000000298 ffffffffa71f85b0 ffff880200000000
[ 3607.004145]  ffff88024f3e0558 ffff88024f3e0530 ffff88024ee20008 ffff88017cdd0000
[ 3607.005664]  ffff88024ee20000 ffff88024ee2fce8 ffff88024ee28000 ffffed0049dc5002
[ 3607.007639] Call Trace:
[ 3607.008004] ? __do_softirq (kernel/softirq.c:655)
[ 3607.008910] ? tasklet_init (kernel/softirq.c:650)
[ 3607.009748] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.010625] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.011958] ? sort_range (kernel/smpboot.c:106)
[ 3607.013567] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.014781] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.016198] ? sort_range (kernel/smpboot.c:106)
[ 3607.017472] ? sort_range (kernel/smpboot.c:106)
[ 3607.018299] kthread (kernel/kthread.c:207)
[ 3607.019044] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.020188] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.021459] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.023356] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.025101] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.027126] kworker/12:0H   S ffff88024ee57ce8 30304    86      2 0x10000000
[ 3607.028381]  ffff88024ee57ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.029684]  ffff88024f3e0558 ffff88024f3e0530 ffff88024ee48008 ffff88017cdd0000
[ 3607.030990]  ffff88024ee48000 ffff88024ee57cc8 ffff88024ee50000 ffffed0049dca002
[ 3607.033429] Call Trace:
[ 3607.035382] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.036642] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.037676] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.038633] ? __schedule (kernel/sched/core.c:2806)
[ 3607.039513] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3607.040512] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.041437] kthread (kernel/kthread.c:207)
[ 3607.042791] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.044437] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.046655] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.047740] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.048594] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.049289] kworker/u61:0   S ffff88024eff7ce8 28712    87      2 0x10000000
[ 3607.051115]  ffff88024eff7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.052023]  ffff88024f3e0558 ffff88024f3e0530 ffff88024ee4b008 ffff88024a093000
[ 3607.052813]  ffff88024ee4b000 ffff88024eff7cc8 ffff88024eff0000 ffffed0049dfe002
[ 3607.054107] Call Trace:
[ 3607.054410] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.055034] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.055711] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.056442] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.057175] kthread (kernel/kthread.c:207)
[ 3607.057721] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.058519] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.059203] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.059842] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.060402] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.060993] watchdog/13     S ffff880278dffcd8 29096    88      2 0x10000000
[ 3607.062165]  ffff880278dffcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880200000000
[ 3607.063855]  ffff8802791e0558 ffff8802791e0530 ffff880278df0008 ffff880224dd0000
[ 3607.065818]  ffff880278df0000 ffffffffb55962a0 ffff880278df8000 ffffed004f1bf002
[ 3607.066703] Call Trace:
[ 3607.067170] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3607.067982] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.068944] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.069521] ? sort_range (kernel/smpboot.c:106)
[ 3607.070034] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.070610] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.071249] ? sort_range (kernel/smpboot.c:106)
[ 3607.072314] ? sort_range (kernel/smpboot.c:106)
[ 3607.072825] kthread (kernel/kthread.c:207)
[ 3607.073371] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.074847] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.075751] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.076441] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.077036] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.077719] migration/13    S ffff880278e07cd8 29096    89      2 0x10000000
[ 3607.078579]  ffff880278e07cd8 ffff880278dd8158 ffffffffb5590500 ffff880200000000
[ 3607.079369]  ffff8802791e0558 ffff8802791e0530 ffff880278df3008 ffff880224dd0000
[ 3607.080193]  ffff880278df3000 ffff880278e07cb8 ffff880278e00000 ffffed004f1c0002
[ 3607.080962] Call Trace:
[ 3607.081278] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3607.082096] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.083248] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.084520] ? sort_range (kernel/smpboot.c:106)
[ 3607.085133] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.085984] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.087205] ? sort_range (kernel/smpboot.c:106)
[ 3607.087769] ? sort_range (kernel/smpboot.c:106)
[ 3607.088353] kthread (kernel/kthread.c:207)
[ 3607.088846] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.089430] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.090144] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.090863] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.091563] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.092538] ksoftirqd/13    S ffff880278e17cd8 29056    90      2 0x10000000
[ 3607.093657]  ffff880278e17cd8 0000000000000298 ffffffffa71f85b0 ffff880200000000
[ 3607.095781]  ffff8802791e0558 ffff8802791e0530 ffff880278e08008 ffff8801d8ae8000
[ 3607.096629]  ffff880278e08000 ffff880278e17ce8 ffff880278e10000 ffffed004f1c2002
[ 3607.097592] Call Trace:
[ 3607.097842] ? __do_softirq (kernel/softirq.c:655)
[ 3607.098477] ? tasklet_init (kernel/softirq.c:650)
[ 3607.099134] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.099626] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.100273] ? sort_range (kernel/smpboot.c:106)
[ 3607.100852] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.101382] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.102161] ? sort_range (kernel/smpboot.c:106)
[ 3607.103404] ? sort_range (kernel/smpboot.c:106)
[ 3607.104639] kthread (kernel/kthread.c:207)
[ 3607.105414] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.106330] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.107284] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.107964] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.108821] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.109475] kworker/13:0H   S ffff880278e37ce8 29112    92      2 0x10000000
[ 3607.110213]  ffff880278e37ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.111050]  ffff8802791e0558 ffff8802791e0530 ffff880278e28008 ffff880224dd0000
[ 3607.112055]  ffff880278e28000 ffff880278e37cc8 ffff880278e30000 ffffed004f1c6002
[ 3607.113378] Call Trace:
[ 3607.113653] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.114335] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.115166] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.115873] ? __schedule (kernel/sched/core.c:2806)
[ 3607.116532] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3607.117247] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.117908] kthread (kernel/kthread.c:207)
[ 3607.118520] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.119188] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.119797] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.120602] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.121265] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.121934] kworker/u62:0   S ffff880278fcfce8 28904    93      2 0x10000000
[ 3607.122779]  ffff880278fcfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.123577]  ffff8802791e0558 ffff8802791e0530 ffff880278e2b008 ffff88027528b000
[ 3607.124491]  ffff880278e2b000 ffff880278fcfcc8 ffff880278fc8000 ffffed004f1f9002
[ 3607.125501] Call Trace:
[ 3607.125816] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.126373] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.126911] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.127453] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.128063] kthread (kernel/kthread.c:207)
[ 3607.128583] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.129171] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.129802] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.130391] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.130923] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.131660] watchdog/14     S ffff8802a2e27cd8 29096    94      2 0x10000000
[ 3607.132695]  ffff8802a2e27cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880200000000
[ 3607.133581]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2e18008 ffff8802ccde0000
[ 3607.134507]  ffff8802a2e18000 ffffffffb55962a0 ffff8802a2e20000 ffffed00545c4002
[ 3607.135433] Call Trace:
[ 3607.135736] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3607.136315] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.136936] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.137507] ? sort_range (kernel/smpboot.c:106)
[ 3607.138028] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.138544] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.139115] ? sort_range (kernel/smpboot.c:106)
[ 3607.139670] ? sort_range (kernel/smpboot.c:106)
[ 3607.140182] kthread (kernel/kthread.c:207)
[ 3607.140693] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.141295] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.142305] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.143009] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.143570] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.144245] migration/14    S ffff8802a2e2fcd8 29096    95      2 0x10000000
[ 3607.145100]  ffff8802a2e2fcd8 ffff8802a2df0158 ffffffffb5590500 ffff880200000000
[ 3607.146185]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2e1b008 ffff8802ccde0000
[ 3607.147092]  ffff8802a2e1b000 ffff8802a2e2fcb8 ffff8802a2e28000 ffffed00545c5002
[ 3607.147858] Call Trace:
[ 3607.148119] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3607.148719] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.149190] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.149760] ? sort_range (kernel/smpboot.c:106)
[ 3607.150254] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.151026] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.151763] ? sort_range (kernel/smpboot.c:106)
[ 3607.152429] ? sort_range (kernel/smpboot.c:106)
[ 3607.152969] kthread (kernel/kthread.c:207)
[ 3607.153507] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.154310] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.154922] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.155743] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.156319] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.157017] ksoftirqd/14    S ffff8802a2e3fcd8 29056    96      2 0x10000000
[ 3607.157786]  ffff8802a2e3fcd8 0000000000000298 ffffffffa71f85b0 ffff880200000000
[ 3607.158887]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2e30008 ffff8802a202b000
[ 3607.159649]  ffff8802a2e30000 ffff8802a2e3fce8 ffff8802a2e38000 ffffed00545c7002
[ 3607.160564] Call Trace:
[ 3607.160817] ? __do_softirq (kernel/softirq.c:655)
[ 3607.161687] ? tasklet_init (kernel/softirq.c:650)
[ 3607.162388] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.162883] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.163491] ? sort_range (kernel/smpboot.c:106)
[ 3607.164226] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.164781] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.165663] ? sort_range (kernel/smpboot.c:106)
[ 3607.166213] ? sort_range (kernel/smpboot.c:106)
[ 3607.166766] kthread (kernel/kthread.c:207)
[ 3607.167326] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.167935] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.168668] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.169256] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.169832] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.170519] kworker/14:0H   S ffff8802a2e57ce8 29112    98      2 0x10000000
[ 3607.171518]  ffff8802a2e57ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.173160]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2e48008 ffff8802ccde0000
[ 3607.174907]  ffff8802a2e48000 ffff8802a2e57cc8 ffff8802a2e50000 ffffed00545ca002
[ 3607.176493] Call Trace:
[ 3607.176826] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.177417] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.177919] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.178922] ? __schedule (kernel/sched/core.c:2806)
[ 3607.179657] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3607.180240] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.181001] kthread (kernel/kthread.c:207)
[ 3607.181725] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.182885] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.183665] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.184173] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.184812] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.185598] kworker/u63:0   S ffff8802a2fefce8 29024    99      2 0x10000000
[ 3607.187511]  ffff8802a2fefce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.189613]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2e4b008 ffff8802a1ca8000
[ 3607.190537]  ffff8802a2e4b000 ffff8802a2fefcc8 ffff8802a2fe8000 ffffed00545fd002
[ 3607.191647] Call Trace:
[ 3607.191904] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.192879] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.193748] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.194556] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.195983] kthread (kernel/kthread.c:207)
[ 3607.196985] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.198172] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.199018] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.199674] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.200199] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.200855] watchdog/15     S ffff8802ccdf7cd8 29096   100      2 0x10000000
[ 3607.201675]  ffff8802ccdf7cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880200000000
[ 3607.203159]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802ccde3008 ffff8803c8df0000
[ 3607.204500]  ffff8802ccde3000 ffffffffb55962a0 ffff8802ccdf0000 ffffed00599be002
[ 3607.207150] Call Trace:
[ 3607.207819] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3607.208865] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.209635] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.210528] ? sort_range (kernel/smpboot.c:106)
[ 3607.211476] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.213096] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.214632] ? sort_range (kernel/smpboot.c:106)
[ 3607.216172] ? sort_range (kernel/smpboot.c:106)
[ 3607.217787] kthread (kernel/kthread.c:207)
[ 3607.219249] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.220231] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.221228] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.222500] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.223829] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.225039] migration/15    S ffff8802ccdffcd8 29096   101      2 0x10000000
[ 3607.226915]  ffff8802ccdffcd8 ffff8802ccdcc158 ffffffffb5590500 ffff880200000000
[ 3607.229150]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802ccddb008 ffff8803c8df0000
[ 3607.230411]  ffff8802ccddb000 ffff8802ccdffcb8 ffff8802ccdf8000 ffffed00599bf002
[ 3607.231847] Call Trace:
[ 3607.232286] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3607.233777] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.234729] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.236385] ? sort_range (kernel/smpboot.c:106)
[ 3607.237558] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.238695] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.239576] ? sort_range (kernel/smpboot.c:106)
[ 3607.240368] ? sort_range (kernel/smpboot.c:106)
[ 3607.241303] kthread (kernel/kthread.c:207)
[ 3607.242673] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.244684] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.246337] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.248210] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.249517] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.250461] ksoftirqd/15    S ffff8802cce0fcd8 29056   102      2 0x10000000
[ 3607.251799]  ffff8802cce0fcd8 0000000000000298 ffffffffa71f85b0 ffff880200000000
[ 3607.253649]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cce00008 ffff88002563b000
[ 3607.255085]  ffff8802cce00000 ffff8802cce0fce8 ffff8802cce08000 ffffed00599c1002
[ 3607.257505] Call Trace:
[ 3607.259711] ? __do_softirq (kernel/softirq.c:655)
[ 3607.260679] ? tasklet_init (kernel/softirq.c:650)
[ 3607.261589] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.262532] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.263873] ? sort_range (kernel/smpboot.c:106)
[ 3607.264802] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.265814] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.266866] ? sort_range (kernel/smpboot.c:106)
[ 3607.267822] ? sort_range (kernel/smpboot.c:106)
[ 3607.268738] kthread (kernel/kthread.c:207)
[ 3607.269594] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.270781] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.271919] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.273242] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.274525] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.275733] kworker/15:0H   S ffff8802cce2fce8 29112   104      2 0x10000000
[ 3607.277036]  ffff8802cce2fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.279211]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cce20008 ffff8803c8df0000
[ 3607.280449]  ffff8802cce20000 ffff8802cce2fcc8 ffff8802cce28000 ffffed00599c5002
[ 3607.281674] Call Trace:
[ 3607.282258] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.283714] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.284602] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.286120] ? __schedule (kernel/sched/core.c:2806)
[ 3607.287792] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3607.289250] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.290224] kthread (kernel/kthread.c:207)
[ 3607.291007] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.292082] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.293972] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.295528] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.297355] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.299236] kworker/u64:0   S ffff8802ccfd7ce8 29024   105      2 0x10000000
[ 3607.299974]  ffff8802ccfd7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.300814]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cce23008 ffff880021778000
[ 3607.301717]  ffff8802cce23000 ffff8802ccfd7cc8 ffff8802ccfd0000 ffffed00599fa002
[ 3607.303219] Call Trace:
[ 3607.303576] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.304193] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.304810] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.305622] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.306985] kthread (kernel/kthread.c:207)
[ 3607.307767] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.309191] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.309896] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.310597] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.311152] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.311771] watchdog/16     S ffff8802f6e2fcd8 29096   106      2 0x10000000
[ 3607.312743]  ffff8802f6e2fcd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880200000000
[ 3607.313638]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6e20008 ffff880518df8000
[ 3607.314568]  ffff8802f6e20000 ffffffffb55962a0 ffff8802f6e28000 ffffed005edc5002
[ 3607.315722] Call Trace:
[ 3607.316013] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3607.316701] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.317579] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.318174] ? sort_range (kernel/smpboot.c:106)
[ 3607.318671] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.319166] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.319720] ? sort_range (kernel/smpboot.c:106)
[ 3607.320340] ? sort_range (kernel/smpboot.c:106)
[ 3607.320930] kthread (kernel/kthread.c:207)
[ 3607.321444] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.322845] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.323680] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.324332] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.325032] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.326090] migration/16    S ffff8802f6e37cd8 29096   107      2 0x10000000
[ 3607.327182]  ffff8802f6e37cd8 ffff8802f6df8158 ffffffffb5590500 ffff880200000000
[ 3607.328094]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6e23008 ffff880518df8000
[ 3607.328895]  ffff8802f6e23000 ffff8802f6e37cb8 ffff8802f6e30000 ffffed005edc6002
[ 3607.329665] Call Trace:
[ 3607.329915] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3607.330548] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.331181] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.331886] ? sort_range (kernel/smpboot.c:106)
[ 3607.332995] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.333773] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.334861] ? sort_range (kernel/smpboot.c:106)
[ 3607.335917] ? sort_range (kernel/smpboot.c:106)
[ 3607.337271] kthread (kernel/kthread.c:207)
[ 3607.338391] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.339124] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.339776] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.340494] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.341080] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.342527] ksoftirqd/16    S ffff8802f6e47cd8 29056   108      2 0x10000000
[ 3607.344648]  ffff8802f6e47cd8 0000000000000298 ffffffffa71f85b0 ffff880200000000
[ 3607.346390]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6e38008 ffff880518df8000
[ 3607.348115]  ffff8802f6e38000 ffff8802f6e47ce8 ffff8802f6e40000 ffffed005edc8002
[ 3607.349563] Call Trace:
[ 3607.349946] ? __do_softirq (kernel/softirq.c:655)
[ 3607.351048] ? tasklet_init (kernel/softirq.c:650)
[ 3607.352528] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.353891] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.355592] ? sort_range (kernel/smpboot.c:106)
[ 3607.356508] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.357345] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.358297] ? sort_range (kernel/smpboot.c:106)
[ 3607.359095] ? sort_range (kernel/smpboot.c:106)
[ 3607.359871] kthread (kernel/kthread.c:207)
[ 3607.360713] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.362130] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.364148] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.365768] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.367036] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.368420] kworker/16:0H   S ffff8802f6e67ce8 30304   110      2 0x10000000
[ 3607.369747]  ffff8802f6e67ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.371159]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6e58008 ffff8802ccaf0000
[ 3607.373011]  ffff8802f6e58000 ffff8802f6e67cc8 ffff8802f6e60000 ffffed005edcc002
[ 3607.374924] Call Trace:
[ 3607.375807] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.377365] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.378263] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.379163] ? __schedule (kernel/sched/core.c:2806)
[ 3607.379988] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3607.381024] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.382117] kthread (kernel/kthread.c:207)
[ 3607.383348] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.384701] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.386270] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.387546] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.388533] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.389581] kworker/u65:0   S ffff8802f6fffce8 29000   111      2 0x10000000
[ 3607.390858]  ffff8802f6fffce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.392184]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6e5b008 ffff8802f6b00000
[ 3607.394088]  ffff8802f6e5b000 ffff8802f6fffcc8 ffff8802f6ff8000 ffffed005edff002
[ 3607.396452] Call Trace:
[ 3607.397153] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.398703] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.399529] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.400406] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.401419] kthread (kernel/kthread.c:207)
[ 3607.403624] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.404797] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.406672] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.407880] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.408851] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.409853] watchdog/17     S ffff880320e17cd8 29096   112      2 0x10000000
[ 3607.411002]  ffff880320e17cd8 ffffffffb2342d20 ffffffffb1ed68a0 ffff880300000000
[ 3607.412373]  ffff8803211e0558 ffff8803211e0530 ffff880320e08008 ffff88060d230000
[ 3607.413754]  ffff880320e08000 ffffffffb55962a0 ffff880320e10000 ffffed00641c2002
[ 3607.415087] Call Trace:
[ 3607.415524] ? touch_nmi_watchdog (kernel/watchdog.c:474)
[ 3607.416598] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.417439] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.419007] ? sort_range (kernel/smpboot.c:106)
[ 3607.419510] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.420013] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.420701] ? sort_range (kernel/smpboot.c:106)
[ 3607.421516] ? sort_range (kernel/smpboot.c:106)
[ 3607.423129] kthread (kernel/kthread.c:207)
[ 3607.424288] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.426782] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.427606] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.428354] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.428936] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.429609] migration/17    S ffff880320e1fcd8 29096   113      2 0x10000000
[ 3607.430698]  ffff880320e1fcd8 ffff880320dd8158 ffffffffb5590500 ffff880300000000
[ 3607.431541]  ffff8803211e0558 ffff8803211e0530 ffff880320e0b008 ffff88060d230000
[ 3607.432781]  ffff880320e0b000 ffff880320e1fcb8 ffff880320e18000 ffffed00641c3002
[ 3607.434031] Call Trace:
[ 3607.434538] ? ikconfig_read_current (kernel/stop_machine.c:437)
[ 3607.435907] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.436724] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.437629] ? sort_range (kernel/smpboot.c:106)
[ 3607.438627] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.439371] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.440334] ? sort_range (kernel/smpboot.c:106)
[ 3607.441174] ? sort_range (kernel/smpboot.c:106)
[ 3607.442218] kthread (kernel/kthread.c:207)
[ 3607.443523] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.444593] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.446346] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.447334] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.448166] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.449182] ksoftirqd/17    S ffff880320e2fcd8 29056   114      2 0x10000000
[ 3607.450490]  ffff880320e2fcd8 0000000000000298 ffffffffa71f85b0 ffff880300000000
[ 3607.451834]  ffff8803211e0558 ffff8803211e0530 ffff880320e20008 ffff880277718000
[ 3607.453496]  ffff880320e20000 ffff880320e2fce8 ffff880320e28000 ffffed00641c5002
[ 3607.455328] Call Trace:
[ 3607.455872] ? __do_softirq (kernel/softirq.c:655)
[ 3607.457275] ? tasklet_init (kernel/softirq.c:650)
[ 3607.458511] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.459432] smpboot_thread_fn (kernel/smpboot.c:158)
[ 3607.460320] ? sort_range (kernel/smpboot.c:106)
[ 3607.461145] ? schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.462072] ? __kthread_parkme (kernel/kthread.c:164)
[ 3607.464084] ? sort_range (kernel/smpboot.c:106)
[ 3607.465511] ? sort_range (kernel/smpboot.c:106)
[ 3607.466837] kthread (kernel/kthread.c:207)
[ 3607.468230] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.469309] ? wait_for_completion (kernel/sched/completion.c:77 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3607.470360] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.471566] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.472698] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.474353] kworker/17:0H   S ffff880320e4fce8 29112   116      2 0x10000000
[ 3607.476330]  ffff880320e4fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.478550]  ffff8803211e0558 ffff8803211e0530 ffff880320e40008 ffff88060d230000
[ 3607.480405]  ffff880320e40000 ffff880320e4fcc8 ffff880320e48000 ffffed00641c9002
[ 3607.481996] Call Trace:
[ 3607.482683] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.484061] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.485735] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.487413] ? __schedule (kernel/sched/core.c:2806)
[ 3607.488994] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3607.490140] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.491575] kthread (kernel/kthread.c:207)
[ 3607.493099] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.495024] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.497164] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.499035] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.500414] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.501340] khelper         S ffff88002515fc28 30336   118      2 0x10000000
[ 3607.503033]  ffff88002515fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.504306]  ffff8800533e0558 ffff8800533e0530 ffff880025150008 ffff8801d0dd0000
[ 3607.506074]  ffff880025150000 ffff88002515fc08 ffff880025158000 ffffed0004a2b002
[ 3607.507313] Call Trace:
[ 3607.507722] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.508599] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.509354] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.510192] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.511112] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.512253] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.513118] ? __schedule (kernel/sched/core.c:2806)
[ 3607.513966] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.514930] kthread (kernel/kthread.c:207)
[ 3607.516039] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.517007] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.518058] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.518986] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.519767] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.520717] kdevtmpfs       S ffff880025177ce8 27448   119      2 0x10000000
[ 3607.521908]  ffff880025177ce8 0000000000000000 ffffffffaa4ce736 0000000000000000
[ 3607.524355]  ffff8800533e0558 ffff8800533e0530 ffff880025153008 ffff8806ad1a8000
[ 3607.526082]  ffff880025153000 ffff880025153000 ffff880025170000 ffffed0004a2e002
[ 3607.528116] Call Trace:
[ 3607.528641] ? devtmpfsd (drivers/base/devtmpfs.c:406 (discriminator 1))
[ 3607.529485] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.530255] devtmpfsd (drivers/base/devtmpfs.c:407 (discriminator 1))
[ 3607.531062] ? __schedule (kernel/sched/core.c:2806)
[ 3607.531909] ? handle_create (drivers/base/devtmpfs.c:377)
[ 3607.533260] ? handle_create (drivers/base/devtmpfs.c:377)
[ 3607.534864] kthread (kernel/kthread.c:207)
[ 3607.536198] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.537125] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.538584] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.539502] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.540323] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.541271] netns           S ffff8800251a7c28 30336   120      2 0x10000000
[ 3607.542731]  ffff8800251a7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.545630]  ffff8800533e0558 ffff8800533e0530 ffff880025198008 ffff8801d0dd0000
[ 3607.548397]  ffff880025198000 ffff8800251a7c08 ffff8800251a0000 ffffed0004a34002
[ 3607.550055] Call Trace:
[ 3607.550466] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.551404] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.552257] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.554157] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.555695] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.556775] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.557723] ? __schedule (kernel/sched/core.c:2806)
[ 3607.558682] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.559511] kthread (kernel/kthread.c:207)
[ 3607.560357] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.561384] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.562636] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.564298] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.565734] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.567464] kworker/u48:1   S ffff8800251afce8 27816   121      2 0x10000000
[ 3607.569049]  ffff8800251afce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.570246]  ffff88007d3e0558 ffff88007d3e0530 ffff88002519b008 ffff8802ccdd8000
[ 3607.571465]  ffff88002519b000 ffff8800251afcc8 ffff8800251a8000 ffffed0004a35002
[ 3607.572976] Call Trace:
[ 3607.573639] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.574576] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.575787] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.576962] ? __schedule (kernel/sched/core.c:2806)
[ 3607.577866] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.578859] kthread (kernel/kthread.c:207)
[ 3607.579614] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.580523] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.581548] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.582939] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.583770] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.585046] perf            S ffff8800251dfc28 30336   123      2 0x10000000
[ 3607.586573]  ffff8800251dfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.587841]  ffff8800533e0558 ffff8800533e0530 ffff8800251bb008 ffff8801d0dd0000
[ 3607.589052]  ffff8800251bb000 ffff8800251dfc08 ffff8800251d8000 ffffed0004a3b002
[ 3607.590255] Call Trace:
[ 3607.590636] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.591485] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.592340] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.593335] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.594267] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.595250] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.596121] ? __schedule (kernel/sched/core.c:2806)
[ 3607.597021] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.597919] kthread (kernel/kthread.c:207)
[ 3607.598717] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.599600] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.600508] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.601449] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.602389] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.603461] kworker/2:1     S ffff88007c477ce8 28256   514      2 0x10000000
[ 3607.604596]  ffff88007c477ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.605950]  ffff88007d3e0558 ffff88007d3e0530 ffff88007c468008 ffff8802ccdd8000
[ 3607.607187]  ffff88007c468000 ffff88007c477cc8 ffff88007c470000 ffffed000f88e002
[ 3607.608460] Call Trace:
[ 3607.608867] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.609712] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.610469] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.611305] ? __schedule (kernel/sched/core.c:2806)
[ 3607.612138] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.613101] kthread (kernel/kthread.c:207)
[ 3607.613872] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.614787] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.615783] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.616740] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.617711] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.618642] kworker/8:1     S ffff8801a6867ce8 27584   577      2 0x10000000
[ 3607.619777]  ffff8801a6867ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.620996]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6858008 ffff8800256f8000
[ 3607.622334]  ffff8801a6858000 ffff8801a6867cc8 ffff8801a6860000 ffffed0034d0c002
[ 3607.623536] Call Trace:
[ 3607.623935] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.624817] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.625699] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.626562] ? __schedule (kernel/sched/core.c:2806)
[ 3607.627437] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.628427] kthread (kernel/kthread.c:207)
[ 3607.629199] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.630118] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.631030] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.632097] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.633156] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.634106] kworker/3:1     S ffff8800a686fce8 27584   730      2 0x10000000
[ 3607.635414]  ffff8800a686fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.636933]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a6fb3008 ffff8803c8de8000
[ 3607.638183]  ffff8800a6fb3000 ffff8800a686fcc8 ffff8800a6868000 ffffed0014d0d002
[ 3607.639471] Call Trace:
[ 3607.639853] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.640725] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.641501] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.642628] ? __schedule (kernel/sched/core.c:2806)
[ 3607.643488] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.644413] kthread (kernel/kthread.c:207)
[ 3607.645195] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.646230] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.647179] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.648140] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.648949] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.649885] kworker/9:1     R  running task    28280   732      2 0x10000000
[ 3607.651013] Workqueue: events wq_barrier_func
[ 3607.651683]  ffff8801d0847af8 ffff8801d0fcbd18 ffffffffb802b7e0 ffff8801d0fcbd48
[ 3607.653080]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0fcb768 ffff8801fa268000
[ 3607.654289]  ffff8801d0fcb000 0000000000000002 ffff8801d0840000 ffffed003a108002
[ 3607.655603] Call Trace:
[ 3607.655984] preempt_schedule_common (./arch/x86/include/asm/preempt.h:77 (discriminator 1) kernel/sched/core.c:2867 (discriminator 1))
[ 3607.656957] preempt_schedule (kernel/sched/core.c:2893)
[ 3607.657885] ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3607.658893] ? _raw_spin_unlock_irqrestore (kernel/locking/spinlock.c:192)
[ 3607.659881] complete (kernel/sched/completion.c:37)
[ 3607.660626] wq_barrier_func (kernel/workqueue.c:2323)
[ 3607.661487] process_one_work (kernel/workqueue.c:2024 include/linux/jump_label.h:114 include/trace/events/workqueue.h:111 kernel/workqueue.c:2029)
[ 3607.663016] ? process_one_work (kernel/workqueue.c:2021)
[ 3607.664749] ? lockdep_init (kernel/locking/lockdep.c:3303)
[ 3607.666030] ? cancel_delayed_work_sync (kernel/workqueue.c:1948)
[ 3607.667597] worker_thread (include/linux/list.h:189 kernel/workqueue.c:2081 kernel/workqueue.c:2158)
[ 3607.668690] ? __schedule (kernel/sched/core.c:2806)
[ 3607.669565] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.670471] kthread (kernel/kthread.c:207)
[ 3607.671206] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.672397] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.673863] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.674971] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.676235] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.677898] kworker/4:1     S ffff8800ca48fce8 28816  2916      2 0x10000000
[ 3607.679088]  ffff8800ca48fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.680306]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800ca480008 ffff880518df0000
[ 3607.683487]  ffff8800ca480000 ffff8800ca48fcc8 ffff8800ca488000 ffffed0019491002
[ 3607.684482] Call Trace:
[ 3607.684757] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.685574] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.686051] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.686690] ? __schedule (kernel/sched/core.c:2806)
[ 3607.687331] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.688029] kthread (kernel/kthread.c:207)
[ 3607.688556] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.689266] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.689856] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.690487] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.691221] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.691996] khungtaskd      R  running task    28888  3362      2 0x10080000
[ 3607.692862]  0000000000000002 00000000c0712d5e ffff8800ca4b7c08 ffffffffa727bfbb
[ 3607.693654]  ffff8800ca4b7be8 ffffffffa733e14c ffff8800ca4b7ca8 ffff8800ca4b7ca8
[ 3607.694486]  dffffc0000000000 ffff8800ca498010 ffff8800ca483770 ffff8800ca483000
[ 3607.695446] Call Trace:
[ 3607.695706] sched_show_task (kernel/sched/core.c:4547)
[ 3607.696349] ? rcu_is_watching (./arch/x86/include/asm/preempt.h:95 kernel/rcu/tree.c:941)
[ 3607.697115] show_state_filter (kernel/sched/core.c:4561)
[ 3607.697757] ? sched_show_task (kernel/sched/core.c:4550)
[ 3607.698743] ? print_lock (kernel/locking/lockdep.c:521 kernel/locking/lockdep.c:580)
[ 3607.699411] ? lockdep_print_held_locks (kernel/locking/lockdep.c:594 (discriminator 3))
[ 3607.700031] watchdog (kernel/hung_task.c:122 kernel/hung_task.c:182 kernel/hung_task.c:238)
[ 3607.700816] ? watchdog (include/linux/rcupdate.h:912 kernel/hung_task.c:171 kernel/hung_task.c:238)
[ 3607.701384] ? reset_hung_task_detector (kernel/hung_task.c:226)
[ 3607.702173] ? reset_hung_task_detector (kernel/hung_task.c:226)
[ 3607.702885] kthread (kernel/kthread.c:207)
[ 3607.703369] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.703985] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.704620] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.705716] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.706509] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.707330] writeback       S ffff8800ca4c7c28 29160  3363      2 0x10000000
[ 3607.708413]  ffff8800ca4c7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.709275]  ffff8801533e0558 ffff8801533e0530 ffff8800ca4b8008 ffff880152913000
[ 3607.710275]  ffff8800ca4b8000 ffff8800ca4c7c08 ffff8800ca4c0000 ffffed0019498002
[ 3607.711137] Call Trace:
[ 3607.711436] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.712704] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.713870] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.714842] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.716347] ? __schedule (kernel/sched/core.c:2806)
[ 3607.717420] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.718293] kthread (kernel/kthread.c:207)
[ 3607.719217] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.720087] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.721321] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.722072] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.723275] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.724390] kworker/13:1    S ffff88027887fce8 27584  3365      2 0x10000000
[ 3607.725954]  ffff88027887fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.729117]  ffff8802791e0558 ffff8802791e0530 ffff880278870008 ffff880224dd0000
[ 3607.730552]  ffff880278870000 ffff88027887fcc8 ffff880278878000 ffffed004f10f002
[ 3607.731620] Call Trace:
[ 3607.732540] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.734250] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.735695] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.736748] ? __schedule (kernel/sched/core.c:2806)
[ 3607.737621] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.738839] kthread (kernel/kthread.c:207)
[ 3607.739453] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.740050] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.741279] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.742794] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.744582] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.745716] ksmd            S ffff8800ca4efc18 28904  3366      2 0x10000000
[ 3607.747748]  ffff8800ca4efc18 ffffffffb55e07c0 0000000000000286 0000000000000000
[ 3607.749455]  ffff8801291e0558 ffff8801291e0530 ffff8800ca4bb008 ffff88065d1d8000
[ 3607.750291]  ffff8800ca4bb000 ffffffffb1f18a80 ffff8800ca4e8000 ffffed001949d002
[ 3607.751870] Call Trace:
[ 3607.752699] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.753867] ksm_scan_thread (include/linux/freezer.h:64 (discriminator 14) mm/ksm.c:1731 (discriminator 14))
[ 3607.755575] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3607.756774] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.758511] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.759583] ? try_to_merge_with_ksm_page (mm/ksm.c:1714)
[ 3607.760774] ? __schedule (kernel/sched/core.c:2806)
[ 3607.762827] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3607.764649] ? try_to_merge_with_ksm_page (mm/ksm.c:1714)
[ 3607.766864] kthread (kernel/kthread.c:207)
[ 3607.768224] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.769757] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.770908] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.771868] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.773359] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.774759] crypto          S ffff8800ca4ffc28 29840  3367      2 0x10000000
[ 3607.776138]  ffff8800ca4ffc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.778010]  ffff8801291e0558 ffff8801291e0530 ffff8800ca4f0008 ffff88065d1d8000
[ 3607.779519]  ffff8800ca4f0000 ffff8800ca4ffc08 ffff8800ca4f8000 ffffed001949f002
[ 3607.780924] Call Trace:
[ 3607.781304] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.782750] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.784078] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.785588] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.787811] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.788990] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.789915] ? __schedule (kernel/sched/core.c:2806)
[ 3607.790933] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.791851] kthread (kernel/kthread.c:207)
[ 3607.793099] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.794665] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.796104] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.797494] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.798651] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.799650] kintegrityd     S ffff8800ca507c28 29840  3368      2 0x10000000
[ 3607.800817]  ffff8800ca507c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.802631]  ffff8801291e0558 ffff8801291e0530 ffff8800ca4f3008 ffff88065d1d8000
[ 3607.804331]  ffff8800ca4f3000 ffff8800ca507c08 ffff8800ca500000 ffffed00194a0002
[ 3607.805994] Call Trace:
[ 3607.806547] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.807819] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.809022] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.809866] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.810834] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.812121] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.813450] ? __schedule (kernel/sched/core.c:2806)
[ 3607.814867] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.816386] kthread (kernel/kthread.c:207)
[ 3607.817690] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.818921] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.819862] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.820897] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.821776] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.823315] bioset          S ffff8800ca517c28 30336  3369      2 0x10000000
[ 3607.824529]  ffff8800ca517c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.825816]  ffff8801291e0558 ffff8801291e0530 ffff8800ca508008 ffff88065d1d8000
[ 3607.827009]  ffff8800ca508000 ffff8800ca517c08 ffff8800ca510000 ffffed00194a2002
[ 3607.828245] Call Trace:
[ 3607.828715] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.829579] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.830315] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.831142] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.832138] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.833210] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.834071] ? __schedule (kernel/sched/core.c:2806)
[ 3607.834901] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.835785] kthread (kernel/kthread.c:207)
[ 3607.836545] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.837444] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.838431] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.839315] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.840108] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.841002] kblockd         S ffff8800ca527c28 30336  3370      2 0x10000000
[ 3607.842196]  ffff8800ca527c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.843657]  ffff8801291e0558 ffff8801291e0530 ffff8800ca50b008 ffff88065d1d8000
[ 3607.844860]  ffff8800ca50b000 ffff8800ca527c08 ffff8800ca520000 ffffed00194a4002
[ 3607.846155] Call Trace:
[ 3607.846545] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.847401] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.848177] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.849001] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.850288] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.850931] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.851512] ? __schedule (kernel/sched/core.c:2806)
[ 3607.852387] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.853260] kthread (kernel/kthread.c:207)
[ 3607.853869] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.854475] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.855321] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.855960] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.856466] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.857228] tifm            S ffff8800ca52fc28 28920  3458      2 0x10000000
[ 3607.858015]  ffff8800ca52fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.858777]  ffff8801291e0558 ffff8801291e0530 ffff88005297b008 ffff88065d1d8000
[ 3607.859520]  ffff88005297b000 ffff8800ca52fc08 ffff8800ca528000 ffffed00194a5002
[ 3607.860317] Call Trace:
[ 3607.860662] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.861229] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.861734] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.863690] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.864592] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.865371] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.866052] ? __schedule (kernel/sched/core.c:2806)
[ 3607.866676] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.867377] kthread (kernel/kthread.c:207)
[ 3607.867985] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.868689] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.869282] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.869887] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.870451] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.871032] ata_sff         S ffff8800ca53fc28 29840  3503      2 0x10000000
[ 3607.871849]  ffff8800ca53fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.873155]  ffff8801291e0558 ffff8801291e0530 ffff88017cac8008 ffff88065d1d8000
[ 3607.873981]  ffff88017cac8000 ffff8800ca53fc08 ffff8800ca538000 ffffed00194a7002
[ 3607.874772] Call Trace:
[ 3607.875035] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.875585] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.876118] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.876666] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.877331] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.878533] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.879093] ? __schedule (kernel/sched/core.c:2806)
[ 3607.879617] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.880203] kthread (kernel/kthread.c:207)
[ 3607.880705] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.881335] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.881978] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.883187] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.883826] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.884728] kworker/7:1     S ffff88017c85fce8 28256  3517      2 0x10000000
[ 3607.885813]  ffff88017c85fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.886688]  ffff88017d3e0558 ffff88017d3e0530 ffff88017c8db008 ffff8808dd1e0000
[ 3607.887493]  ffff88017c8db000 ffff88017c85fcc8 ffff88017c858000 ffffed002f90b002
[ 3607.888465] Call Trace:
[ 3607.888709] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.889244] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.889743] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.890316] ? __schedule (kernel/sched/core.c:2806)
[ 3607.890857] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.891481] kthread (kernel/kthread.c:207)
[ 3607.892201] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.893072] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.893729] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.894375] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.894967] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.895627] md              S ffff8800ca54fc28 29840  3537      2 0x10000000
[ 3607.896387]  ffff8800ca54fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.897227]  ffff8801291e0558 ffff8801291e0530 ffff8800ca540008 ffff88065d1d8000
[ 3607.898384]  ffff8800ca540000 ffff8800ca54fc08 ffff8800ca548000 ffffed00194a9002
[ 3607.899181] Call Trace:
[ 3607.899422] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.899997] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.900539] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.901144] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.901864] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.902746] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.903812] ? __schedule (kernel/sched/core.c:2806)
[ 3607.904296] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.904975] kthread (kernel/kthread.c:207)
[ 3607.905996] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.906609] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.907202] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.908019] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.908685] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.909298] devfreq_wq      S ffff8800ca55fc28 29840  3544      2 0x10000000
[ 3607.910115]  ffff8800ca55fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.911084]  ffff8801291e0558 ffff8801291e0530 ffff8800ca543008 ffff88065d1d8000
[ 3607.911948]  ffff8800ca543000 ffff8800ca55fc08 ffff8800ca558000 ffffed00194ab002
[ 3607.913437] Call Trace:
[ 3607.913921] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.914590] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.915447] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.916541] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.917395] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.918283] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.919039] ? __schedule (kernel/sched/core.c:2806)
[ 3607.919583] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.920190] kthread (kernel/kthread.c:207)
[ 3607.920742] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.921366] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.922450] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.923443] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.924410] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.925164] kworker/11:1    S ffff8802248a7ce8 27832  3558      2 0x10000000
[ 3607.926051]  ffff8802248a7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.926827]  ffff8802253e0558 ffff8802253e0530 ffff880224fbb008 ffff8800a6dd0000
[ 3607.927684]  ffff880224fbb000 ffff8802248a7cc8 ffff8802248a0000 ffffed0044914002
[ 3607.929137] Call Trace:
[ 3607.929399] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.929998] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.930567] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.931100] ? __schedule (kernel/sched/core.c:2806)
[ 3607.931654] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.932960] kthread (kernel/kthread.c:207)
[ 3607.933732] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.934552] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.935413] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.936050] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.936596] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.937377] kworker/1:1     S ffff880052aefce8 27032  3567      2 0x10000000
[ 3607.938320]  ffff880052aefce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.939177]  ffff8800533e0558 ffff8800533e0530 ffff880052fab008 ffff8801d0dd0000
[ 3607.939947]  ffff880052fab000 ffff880052aefcc8 ffff880052ae8000 ffffed000a55d002
[ 3607.940726] Call Trace:
[ 3607.941034] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.941735] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.942460] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.943156] ? __schedule (kernel/sched/core.c:2806)
[ 3607.943877] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.944586] kthread (kernel/kthread.c:207)
[ 3607.945385] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.946366] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.947025] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.947614] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.948277] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.948951] cfg80211        S ffff8800ca56fc28 30336  3568      2 0x10000000
[ 3607.949751]  ffff8800ca56fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3607.950651]  ffff8801291e0558 ffff8801291e0530 ffff8800ca560008 ffff88065d1d8000
[ 3607.951523]  ffff8800ca560000 ffff8800ca56fc08 ffff8800ca568000 ffffed00194ad002
[ 3607.952248] Call Trace:
[ 3607.952861] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3607.953721] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.954140] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3607.954878] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3607.955742] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3607.956511] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.957156] ? __schedule (kernel/sched/core.c:2806)
[ 3607.957723] ? worker_thread (kernel/workqueue.c:2203)
[ 3607.958431] kthread (kernel/kthread.c:207)
[ 3607.959112] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.959756] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.960394] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.961180] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.961852] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.963355] kworker/12:1    S ffff88024e4efce8 27584  3574      2 0x10000000
[ 3607.964429]  ffff88024e4efce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.965946]  ffff88024f3e0558 ffff88024f3e0530 ffff88024e4e0008 ffff88017cdd0000
[ 3607.967116]  ffff88024e4e0000 ffff88024e4efcc8 ffff88024e4e8000 ffffed0049c9d002
[ 3607.967956] Call Trace:
[ 3607.968376] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.968992] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.969479] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.970049] ? __schedule (kernel/sched/core.c:2806)
[ 3607.970706] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.971309] kthread (kernel/kthread.c:207)
[ 3607.971941] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.972894] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.973644] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.974599] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.975357] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.976198] kworker/0:1     S ffff880024e97ce8 27584  3575      2 0x10000000
[ 3607.976989]  ffff880024e97ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.977803]  ffff8800261e0558 ffff8800261e0530 ffff8800253b3008 ffffffffb4839100
[ 3607.978647]  ffff8800253b3000 ffff880024e97cc8 ffff880024e90000 ffffed00049d2002
[ 3607.979430] Call Trace:
[ 3607.979681] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.980334] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.981271] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3607.982076] ? __schedule (kernel/sched/core.c:2806)
[ 3607.983791] ? process_one_work (kernel/workqueue.c:2101)
[ 3607.985563] kthread (kernel/kthread.c:207)
[ 3607.986552] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.987797] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3607.988778] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.989672] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3607.990548] ? flush_kthread_work (kernel/kthread.c:176)
[ 3607.991442] kworker/u50:1   S ffff8800520ffce8 25024  3669      2 0x10000000
[ 3607.992992]  ffff8800520ffce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3607.995094]  ffff8800533e0558 ffff8800533e0530 ffff880052a83008 ffff88003acd3000
[ 3607.996673]  ffff880052a83000 ffff8800520ffcc8 ffff8800520f8000 ffffed000a41f002
[ 3607.997976] Call Trace:
[ 3607.998431] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3607.999252] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3607.999977] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3608.000918] ? __schedule (kernel/sched/core.c:2806)
[ 3608.001824] ? process_one_work (kernel/workqueue.c:2101)
[ 3608.003410] kthread (kernel/kthread.c:207)
[ 3608.004641] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.006123] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.007078] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.008020] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.008949] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.009880] rpciod          S ffff88002413fc28 28920  3670      2 0x10000000
[ 3608.011007]  ffff88002413fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3608.012555]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8800253b0008 ffff8803c8df0000
[ 3608.014521]  ffff8800253b0000 ffff88002413fc08 ffff880024138000 ffffed0004827002
[ 3608.016543] Call Trace:
[ 3608.017026] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3608.018424] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.019175] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3608.019984] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.020992] ? worker_thread (kernel/workqueue.c:2203)
[ 3608.023439] ? __schedule (kernel/sched/core.c:2806)
[ 3608.024181] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3608.024794] ? worker_thread (kernel/workqueue.c:2203)
[ 3608.026154] kthread (kernel/kthread.c:207)
[ 3608.026671] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.027644] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.028417] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.029111] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.029730] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.030420] kworker/6:1     S ffff880152947ce8 27584  3711      2 0x10000000
[ 3608.031236]  ffff880152947ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3608.032519]  ffff8801533e0558 ffff8801533e0530 ffff880152913008 ffff88079d1e8000
[ 3608.033691]  ffff880152913000 ffff880152947cc8 ffff880152940000 ffffed002a528002
[ 3608.034545] Call Trace:
[ 3608.034850] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3608.035484] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.036057] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3608.036688] ? __schedule (kernel/sched/core.c:2806)
[ 3608.037336] ? process_one_work (kernel/workqueue.c:2101)
[ 3608.038080] kthread (kernel/kthread.c:207)
[ 3608.038588] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.039163] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.039738] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.040431] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.041029] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.041944] kswapd0         S ffff880023ff7b58 25848  3785      2 0x10000000
[ 3608.042906]  ffff880023ff7b58 ffff880023ff7af8 ffffffffa8fa262b ffff880000000000
[ 3608.044116]  ffff8800261e0558 ffff8800261e0530 ffff880023810008 ffff880151c5b000
[ 3608.045136]  ffff880023810000 0000000000000001 ffff880023ff0000 ffffed00047fe002
[ 3608.046635] Call Trace:
[ 3608.047029] ? find_next_bit (lib/find_bit.c:65)
[ 3608.047898] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.048909] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.049889] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.050748] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.051591] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.052523] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.053765] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.054499] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.055547] ? __schedule (kernel/sched/core.c:2806)
[ 3608.057144] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.058160] kthread (kernel/kthread.c:207)
[ 3608.058781] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.059396] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.060006] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.060887] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.061464] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.062062] kswapd1         S ffff880023fffb58 26536  3786      2 0x10000000
[ 3608.063324]  ffff880023fffb58 ffff880023fffaf8 ffffffffa8fa262b ffff880000000000
[ 3608.064450]  ffff8800533e0558 ffff8800533e0530 ffff880023813008 ffff88021aff0000
[ 3608.065550]  ffff880023813000 0000000000000001 ffff880023ff8000 ffffed00047ff002
[ 3608.067708] Call Trace:
[ 3608.068187] ? find_next_bit (lib/find_bit.c:65)
[ 3608.069673] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.070219] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.070868] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.071830] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.072729] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.073682] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.074577] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.076080] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.077829] ? __schedule (kernel/sched/core.c:2806)
[ 3608.079055] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.079735] kthread (kernel/kthread.c:207)
[ 3608.080263] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.081051] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.081708] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.082889] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.083514] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.084175] kswapd2         S ffff880023847b58 29376  3787      2 0x10000000
[ 3608.085165]  ffff880023847b58 ffff880023847af8 ffffffffa8fa262b ffff880000000000
[ 3608.086773]  ffff88007d3e0558 ffff88007d3e0530 ffff88002382b008 ffff8802ccdd8000
[ 3608.087704]  ffff88002382b000 0000000000000001 ffff880023840000 ffffed0004708002
[ 3608.088524] Call Trace:
[ 3608.088785] ? find_next_bit (lib/find_bit.c:65)
[ 3608.089344] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.089840] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.090345] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.091172] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.091889] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.092628] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.093464] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.094235] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.094904] ? __schedule (kernel/sched/core.c:2806)
[ 3608.095671] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.096756] kthread (kernel/kthread.c:207)
[ 3608.097407] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.098049] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.098735] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.099337] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.099861] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.100503] kswapd3         S ffff88002384fb58 29376  3788      2 0x10000000
[ 3608.101299]  ffff88002384fb58 ffff88002384faf8 ffffffffa8fa262b ffff880000000000
[ 3608.102087]  ffff8800a73e0558 ffff8800a73e0530 ffff880023828008 ffff8803c8de8000
[ 3608.103291]  ffff880023828000 0000000000000001 ffff880023848000 ffffed0004709002
[ 3608.104097] Call Trace:
[ 3608.104557] ? find_next_bit (lib/find_bit.c:65)
[ 3608.105186] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.105784] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.106291] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.107259] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.108008] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.108927] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.109550] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.110159] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.110944] ? __schedule (kernel/sched/core.c:2806)
[ 3608.111489] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.112178] kthread (kernel/kthread.c:207)
[ 3608.112715] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.113333] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.113942] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.114595] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.115198] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.115842] kswapd4         S ffff880023857b58 29376  3789      2 0x10000000
[ 3608.116596]  ffff880023857b58 ffff880023857af8 ffffffffa8fa262b ffff880000000000
[ 3608.117526]  ffff8800cf3e0558 ffff8800cf3e0530 ffff880024ea8008 ffff880518df0000
[ 3608.118375]  ffff880024ea8000 0000000000000001 ffff880023850000 ffffed000470a002
[ 3608.119162] Call Trace:
[ 3608.119415] ? find_next_bit (lib/find_bit.c:65)
[ 3608.119948] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.120589] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.121117] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.121821] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.122487] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.123171] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.123799] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.124403] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.125052] ? __schedule (kernel/sched/core.c:2806)
[ 3608.125765] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.126496] kthread (kernel/kthread.c:207)
[ 3608.127190] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.127798] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.128507] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.129117] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.129681] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.130438] kswapd5         S ffff88002385fb58 29376  3790      2 0x10000000
[ 3608.131193]  ffff88002385fb58 ffff88002385faf8 ffffffffa8fa262b ffff880000000000
[ 3608.131980]  ffff8801291e0558 ffff8801291e0530 ffff880024eab008 ffff88065d1d8000
[ 3608.132927]  ffff880024eab000 0000000000000001 ffff880023858000 ffffed000470b002
[ 3608.133875] Call Trace:
[ 3608.134140] ? find_next_bit (lib/find_bit.c:65)
[ 3608.134719] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.135388] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.135923] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.136635] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.137378] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.138085] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.138793] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.139397] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.140013] ? __schedule (kernel/sched/core.c:2806)
[ 3608.140653] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.141549] kthread (kernel/kthread.c:207)
[ 3608.142127] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.142789] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.143684] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.144372] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.144963] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.145762] kswapd6         S ffff880000097b58 27920  3791      2 0x10000000
[ 3608.146594]  ffff880000097b58 dffffc0000000000 ffff880153fd3000 ffffea0000000000
[ 3608.147535]  ffff8801533e0558 ffff8801533e0530 ffff8800251b8008 ffff8802f4418000
[ 3608.148421]  ffff8800251b8000 0000000000000001 ffff880000090000 ffffed0000012002
[ 3608.149218] Call Trace:
[ 3608.149492] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.149995] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.150621] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.151333] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.152165] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.152934] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.153679] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.154490] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.155219] ? __schedule (kernel/sched/core.c:2806)
[ 3608.155821] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.156523] kthread (kernel/kthread.c:207)
[ 3608.157490] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.158287] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.158897] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.159496] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.160022] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.160771] kswapd7         S ffff880000087b58 26920  3792      2 0x10000000
[ 3608.161563]  ffff880000087b58 dffffc0000000000 ffff88017dfd3000 ffffea0000000000
[ 3608.162530]  ffff88017d3e0558 ffff88017d3e0530 ffff880023f83008 ffff880319c9b000
[ 3608.163405]  ffff880023f83000 0000000000000001 ffff880000080000 ffffed0000010002
[ 3608.164221] Call Trace:
[ 3608.164473] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.164988] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.165648] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.166387] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.167156] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.167861] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.168513] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.169111] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.169752] ? __schedule (kernel/sched/core.c:2806)
[ 3608.170388] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.171264] kthread (kernel/kthread.c:207)
[ 3608.171807] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.172416] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.173040] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.173730] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.174283] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.174961] kswapd8         S ffff880023fc7b58 27920  3793      2 0x10000000
[ 3608.176045]  ffff880023fc7b58 dffffc0000000000 ffff8801a7fd3000 ffffea0000000000
[ 3608.177000]  ffff8801a73e0558 ffff8801a73e0530 ffff880023f80008 ffff8802753b0000
[ 3608.178132]  ffff880023f80000 0000000000000001 ffff880023fc0000 ffffed00047f8002
[ 3608.179083] Call Trace:
[ 3608.179336] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.179836] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.180492] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.181172] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.181872] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.182517] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.183273] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.183988] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.184734] ? __schedule (kernel/sched/core.c:2806)
[ 3608.185354] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.186696] kthread (kernel/kthread.c:207)
[ 3608.187534] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.188275] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.189006] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.189627] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.190158] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.190830] kswapd9         S ffff880023fd7b58 28328  3794      2 0x10000000
[ 3608.191634]  ffff880023fd7b58 ffff880023fd7af8 ffffffffa8fa262b ffff880000000000
[ 3608.192441]  ffff8801d11e0558 ffff8801d11e0530 ffff880023fc8008 ffff8800256fb000
[ 3608.193521]  ffff880023fc8000 0000000000000001 ffff880023fd0000 ffffed00047fa002
[ 3608.194507] Call Trace:
[ 3608.194737] ? find_next_bit (lib/find_bit.c:65)
[ 3608.195562] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.196116] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.196639] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.197586] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.198443] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.199668] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.200707] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.201649] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.203459] ? __schedule (kernel/sched/core.c:2806)
[ 3608.204651] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.207280] kthread (kernel/kthread.c:207)
[ 3608.208810] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.209799] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.210780] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.211783] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.212922] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.214297] kswapd10        S ffff880023fdfb58 28328  3795      2 0x10000000
[ 3608.216751]  ffff880023fdfb58 ffff880023fdfaf8 ffffffffa8fa262b ffff880000000000
[ 3608.218861]  ffff8801fb3e0558 ffff8801fb3e0530 ffff880023fcb008 ffff880052dc8000
[ 3608.220008]  ffff880023fcb000 0000000000000001 ffff880023fd8000 ffffed00047fb002
[ 3608.221301] Call Trace:
[ 3608.221844] ? find_next_bit (lib/find_bit.c:65)
[ 3608.223303] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.224603] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.225762] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.227150] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.228239] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.229195] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.230156] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.231111] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.232198] ? __schedule (kernel/sched/core.c:2806)
[ 3608.233362] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.234618] kthread (kernel/kthread.c:207)
[ 3608.235433] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.236423] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.237390] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.238538] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.239318] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.240203] kswapd11        S ffff880023fafb58 28328  3796      2 0x10000000
[ 3608.241335]  ffff880023fafb58 ffff880023fafaf8 ffffffffa8fa262b ffff880000000000
[ 3608.242803]  ffff8802253e0558 ffff8802253e0530 ffff880023fa0008 ffff8800a6dd0000
[ 3608.244813]  ffff880023fa0000 0000000000000001 ffff880023fa8000 ffffed00047f5002
[ 3608.246404] Call Trace:
[ 3608.246814] ? find_next_bit (lib/find_bit.c:65)
[ 3608.247635] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.248425] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.249199] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.250255] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.251244] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.252556] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.253754] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.255020] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.256928] ? __schedule (kernel/sched/core.c:2806)
[ 3608.258135] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.259469] kthread (kernel/kthread.c:207)
[ 3608.260198] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.261146] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.263089] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.265365] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.267002] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.268446] kswapd12        S ffff88000008fb58 28328  3797      2 0x10000000
[ 3608.269551]  ffff88000008fb58 ffff88000008faf8 ffffffffa8fa262b ffff880000000000
[ 3608.270836]  ffff88024f3e0558 ffff88024f3e0530 ffff880023fa3008 ffff88017cdd0000
[ 3608.272277]  ffff880023fa3000 0000000000000001 ffff880000088000 ffffed0000011002
[ 3608.274342] Call Trace:
[ 3608.275192] ? find_next_bit (lib/find_bit.c:65)
[ 3608.276584] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.277610] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.278510] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.279522] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.280515] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.281516] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.282581] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.283700] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.284813] ? __schedule (kernel/sched/core.c:2806)
[ 3608.285719] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.287382] kthread (kernel/kthread.c:207)
[ 3608.288271] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.289181] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.290070] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.291030] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.292020] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.293229] kswapd13        S ffff880023fb7b58 28328  3798      2 0x10000000
[ 3608.294586]  ffff880023fb7b58 ffff880023fb7af8 ffffffffa8fa262b ffff880000000000
[ 3608.296676]  ffff8802791e0558 ffff8802791e0530 ffff880000010008 ffff880224dd0000
[ 3608.298948]  ffff880000010000 0000000000000001 ffff880023fb0000 ffffed00047f6002
[ 3608.300357] Call Trace:
[ 3608.300936] ? find_next_bit (lib/find_bit.c:65)
[ 3608.301938] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.303026] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.304626] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.307265] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.308860] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.309877] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.310894] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.311830] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.313673] ? __schedule (kernel/sched/core.c:2806)
[ 3608.314863] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.316236] kthread (kernel/kthread.c:207)
[ 3608.317197] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.318148] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.319071] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.319946] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.320841] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.321799] kswapd14        S ffff880023fbfb58 29376  3799      2 0x10000000
[ 3608.323525]  ffff880023fbfb58 ffff880023fbfaf8 ffffffffa8fa262b ffff880000000000
[ 3608.325194]  ffff8802a33e0558 ffff8802a33e0530 ffff880000013008 ffff8802ccde0000
[ 3608.326453]  ffff880000013000 0000000000000001 ffff880023fb8000 ffffed00047f7002
[ 3608.327592] Call Trace:
[ 3608.327923] ? find_next_bit (lib/find_bit.c:65)
[ 3608.328800] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.329312] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.329962] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.330715] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.331455] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.332143] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.332909] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.334062] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.334646] ? __schedule (kernel/sched/core.c:2806)
[ 3608.335527] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.336409] kthread (kernel/kthread.c:207)
[ 3608.337128] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.337736] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.338400] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.339023] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.339527] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.340119] kswapd15        S ffff88002388fb58 28328  3800      2 0x10000000
[ 3608.340979]  ffff88002388fb58 ffff88002388faf8 ffffffffa8fa262b ffff880000000000
[ 3608.342274]  ffff8802cd3e0558 ffff8802cd3e0530 ffff880023880008 ffff8803c8df0000
[ 3608.343699]  ffff880023880000 0000000000000001 ffff880023888000 ffffed0004711002
[ 3608.345465] Call Trace:
[ 3608.345976] ? find_next_bit (lib/find_bit.c:65)
[ 3608.346856] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.347620] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.348454] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.349523] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.350474] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.351523] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.352559] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.353582] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.354840] ? __schedule (kernel/sched/core.c:2806)
[ 3608.355855] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.356967] kthread (kernel/kthread.c:207)
[ 3608.357712] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.359089] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.359962] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.360981] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.361856] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.363147] kswapd16        S ffff880023897b58 28328  3801      2 0x10000000
[ 3608.364358]  ffff880023897b58 ffff880023897af8 ffffffffa8fa262b ffff880000000000
[ 3608.365660]  ffff8802f73e0558 ffff8802f73e0530 ffff880023883008 ffff880518df8000
[ 3608.366976]  ffff880023883000 0000000000000001 ffff880023890000 ffffed0004712002
[ 3608.368196] Call Trace:
[ 3608.368628] ? find_next_bit (lib/find_bit.c:65)
[ 3608.369457] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.370186] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.370985] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.372149] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.373462] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.374457] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.375367] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.376309] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.377299] ? __schedule (kernel/sched/core.c:2806)
[ 3608.378197] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.379265] kthread (kernel/kthread.c:207)
[ 3608.379987] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.381063] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.382079] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.383440] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.384289] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.385225] kswapd17        S ffff88000001fb58 28328  3802      2 0x10000000
[ 3608.386481]  ffff88000001fb58 ffff88000001faf8 ffffffffa8fa262b ffff880000000000
[ 3608.387783]  ffff8803211e0558 ffff8803211e0530 ffff880023898008 ffff88060d230000
[ 3608.388982]  ffff880023898000 0000000000000001 ffff880000018000 ffffed0000003002
[ 3608.390146] Call Trace:
[ 3608.390583] ? find_next_bit (lib/find_bit.c:65)
[ 3608.391457] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.392407] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.393521] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.394629] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.395672] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.396738] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.397759] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.398715] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.399617] ? __schedule (kernel/sched/core.c:2806)
[ 3608.400477] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.401601] kthread (kernel/kthread.c:207)
[ 3608.402444] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.403559] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.404634] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.405755] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.406613] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.407721] kswapd18        S ffff8800238a7b58 29584  3803      2 0x10000000
[ 3608.408886]  ffff8800238a7b58 ffff8800238a7af8 ffffffffa8fa262b ffff880000000000
[ 3608.410718]  ffff8800533e0558 ffff8800533e0530 ffff88002389b008 ffff8800238a8000
[ 3608.411991]  ffff88002389b000 0000000000000001 ffff8800238a0000 ffffed0004714002
[ 3608.413560] Call Trace:
[ 3608.413961] ? find_next_bit (lib/find_bit.c:65)
[ 3608.414797] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.415658] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.416469] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.417567] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.418575] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.419561] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.420480] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.421462] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.423563] ? __schedule (kernel/sched/core.c:2806)
[ 3608.424149] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.424908] kthread (kernel/kthread.c:207)
[ 3608.425603] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.426283] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.427145] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.427908] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.428596] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.429215] kswapd19        S ffff8800238b7b58 29584  3804      2 0x10000000
[ 3608.429944]  ffff8800238b7b58 ffff8800238b7af8 ffffffffa8fa262b ffff880000000000
[ 3608.431022]  ffff8800533e0558 ffff8800533e0530 ffff8800238a8008 ffff8800238ab000
[ 3608.432632]  ffff8800238a8000 0000000000000001 ffff8800238b0000 ffffed0004716002
[ 3608.433379] Call Trace:
[ 3608.433584] ? find_next_bit (lib/find_bit.c:65)
[ 3608.434079] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.434990] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.436043] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.437336] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.438329] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.439028] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.439603] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.440285] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.441079] ? __schedule (kernel/sched/core.c:2806)
[ 3608.441676] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.442479] kthread (kernel/kthread.c:207)
[ 3608.443051] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.443780] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.444429] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.445132] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.446036] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.446626] kswapd20        S ffff8800238bfb58 29584  3805      2 0x10000000
[ 3608.447669]  ffff8800238bfb58 ffff8800238bfaf8 ffffffffa8fa262b ffff880000000000
[ 3608.448892]  ffff8800533e0558 ffff8800533e0530 ffff8800238ab008 ffff8800238c0000
[ 3608.449654]  ffff8800238ab000 0000000000000001 ffff8800238b8000 ffffed0004717002
[ 3608.450947] Call Trace:
[ 3608.451199] ? find_next_bit (lib/find_bit.c:65)
[ 3608.451763] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.452291] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.452869] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.453591] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.454360] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.455076] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.456043] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.456855] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.457972] ? __schedule (kernel/sched/core.c:2806)
[ 3608.458561] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.459230] kthread (kernel/kthread.c:207)
[ 3608.459707] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.460652] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.461444] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.462128] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.462706] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.463335] kswapd21        S ffff8800238cfb58 29472  3806      2 0x10000000
[ 3608.464069]  ffff8800238cfb58 ffff8800238cfaf8 ffffffffa8fa262b ffff880000000000
[ 3608.464870]  ffff8800533e0558 ffff8800533e0530 ffff8800238c0008 ffff8800238c3000
[ 3608.465982]  ffff8800238c0000 0000000000000001 ffff8800238c8000 ffffed0004719002
[ 3608.466754] Call Trace:
[ 3608.467155] ? find_next_bit (lib/find_bit.c:65)
[ 3608.468483] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.469092] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.469611] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.470521] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.471150] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.471913] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.472671] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.473280] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.473977] ? __schedule (kernel/sched/core.c:2806)
[ 3608.474565] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.475367] kthread (kernel/kthread.c:207)
[ 3608.475859] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.476552] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.477233] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.478672] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.479173] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.479748] kswapd22        S ffff88000002fb58 29584  3807      2 0x10000000
[ 3608.480988]  ffff88000002fb58 ffff88000002faf8 ffffffffa8fa262b ffff880000000000
[ 3608.481856]  ffff8800533e0558 ffff8800533e0530 ffff8800238c3008 ffff880000030000
[ 3608.482936]  ffff8800238c3000 0000000000000001 ffff880000028000 ffffed0000005002
[ 3608.483789] Call Trace:
[ 3608.484047] ? find_next_bit (lib/find_bit.c:65)
[ 3608.484706] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.485242] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.485784] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.486495] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.487550] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.488528] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.489147] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.489846] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.490539] ? __schedule (kernel/sched/core.c:2806)
[ 3608.491149] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.491977] kthread (kernel/kthread.c:207)
[ 3608.492470] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.493151] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.493788] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.494432] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.495079] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.495888] kswapd23        S ffff8800238d7b58 29584  3808      2 0x10000000
[ 3608.496836]  ffff8800238d7b58 ffff8800238d7af8 ffffffffa8fa262b ffff880000000000
[ 3608.497698]  ffff8800533e0558 ffff8800533e0530 ffff880000030008 ffff880000033000
[ 3608.498558]  ffff880000030000 0000000000000001 ffff8800238d0000 ffffed000471a002
[ 3608.499309] Call Trace:
[ 3608.499553] ? find_next_bit (lib/find_bit.c:65)
[ 3608.500092] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.500638] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.501162] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.501944] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.502596] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.503291] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.503891] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.504507] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.505307] ? __schedule (kernel/sched/core.c:2806)
[ 3608.505924] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.506635] kthread (kernel/kthread.c:207)
[ 3608.507266] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.507880] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.508548] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.509211] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.509776] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.510487] kswapd24        S ffff8800238dfb58 28712  3809      2 0x10000000
[ 3608.511261]  ffff8800238dfb58 ffff8800238dfaf8 ffffffffa8fa262b ffff880000000000
[ 3608.512088]  ffff8800533e0558 ffff8800533e0530 ffff880000033008 ffff8801d0dd0000
[ 3608.513184]  ffff880000033000 0000000000000001 ffff8800238d8000 ffffed000471b002
[ 3608.514295] Call Trace:
[ 3608.514569] ? find_next_bit (lib/find_bit.c:65)
[ 3608.515191] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.515783] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.516334] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.517134] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.517862] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.518649] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.519259] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.519836] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.520516] ? __schedule (kernel/sched/core.c:2806)
[ 3608.521220] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.522004] kthread (kernel/kthread.c:207)
[ 3608.522704] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.523934] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.524604] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.525439] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.526222] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.526828] kswapd25        S ffff8800238efb58 29584  3810      2 0x10000000
[ 3608.527884]  ffff8800238efb58 ffff8800238efaf8 ffffffffa8fa262b ffff880000000000
[ 3608.528733]  ffff8800533e0558 ffff8800533e0530 ffff8800238e0008 ffff8800238e3000
[ 3608.529493]  ffff8800238e0000 0000000000000001 ffff8800238e8000 ffffed000471d002
[ 3608.530410] Call Trace:
[ 3608.530744] ? find_next_bit (lib/find_bit.c:65)
[ 3608.531444] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.532267] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.533467] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.534213] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.535114] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.536658] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.538030] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.538887] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.539481] ? __schedule (kernel/sched/core.c:2806)
[ 3608.540022] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.541063] kthread (kernel/kthread.c:207)
[ 3608.542221] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.543037] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.543866] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.544460] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.545150] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.546343] kswapd26        S ffff8800238f7b58 29584  3811      2 0x10000000
[ 3608.547960]  ffff8800238f7b58 ffff8800238f7af8 ffffffffa8fa262b ffff880000000000
[ 3608.549145]  ffff8800533e0558 ffff8800533e0530 ffff8800238e3008 ffff8800238f8000
[ 3608.549937]  ffff8800238e3000 0000000000000001 ffff8800238f0000 ffffed000471e002
[ 3608.550832] Call Trace:
[ 3608.551193] ? find_next_bit (lib/find_bit.c:65)
[ 3608.551792] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.552294] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.552861] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.553597] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.554326] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.555253] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.556449] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.557435] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.558143] ? __schedule (kernel/sched/core.c:2806)
[ 3608.558927] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.559605] kthread (kernel/kthread.c:207)
[ 3608.560120] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.560729] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.561409] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.562337] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.563541] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.564415] kswapd27        S ffff88000003fb58 29584  3812      2 0x10000000
[ 3608.566079]  ffff88000003fb58 ffff88000003faf8 ffffffffa8fa262b ffff880000000000
[ 3608.568005]  ffff8800533e0558 ffff8800533e0530 ffff8800238f8008 ffff8800238fb000
[ 3608.568908]  ffff8800238f8000 0000000000000001 ffff880000038000 ffffed0000007002
[ 3608.569706] Call Trace:
[ 3608.569949] ? find_next_bit (lib/find_bit.c:65)
[ 3608.570560] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.571274] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.572012] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.572783] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.573792] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.574833] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.576488] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.577853] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.579274] ? __schedule (kernel/sched/core.c:2806)
[ 3608.579853] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.580660] kthread (kernel/kthread.c:207)
[ 3608.581150] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.581742] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.582817] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.583950] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.584910] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.585980] kswapd28        S ffff880000047b58 29584  3813      2 0x10000000
[ 3608.587780]  ffff880000047b58 ffff880000047af8 ffffffffa8fa262b ffff880000000000
[ 3608.589240]  ffff8800533e0558 ffff8800533e0530 ffff8800238fb008 ffff880023900000
[ 3608.590059]  ffff8800238fb000 0000000000000001 ffff880000040000 ffffed0000008002
[ 3608.590988] Call Trace:
[ 3608.591329] ? find_next_bit (lib/find_bit.c:65)
[ 3608.591866] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.592645] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.593710] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.595158] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.596941] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.598507] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.599843] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.600587] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.601380] ? __schedule (kernel/sched/core.c:2806)
[ 3608.602024] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.604003] kthread (kernel/kthread.c:207)
[ 3608.605354] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.606922] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.608900] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.610322] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.611155] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.612218] kswapd29        S ffff88002390fb58 29584  3814      2 0x10000000
[ 3608.614206]  ffff88002390fb58 ffff88002390faf8 ffffffffa8fa262b ffff880000000000
[ 3608.616719]  ffff8800533e0558 ffff8800533e0530 ffff880023900008 ffff880023903000
[ 3608.618840]  ffff880023900000 0000000000000001 ffff880023908000 ffffed0004721002
[ 3608.619999] Call Trace:
[ 3608.620427] ? find_next_bit (lib/find_bit.c:65)
[ 3608.621317] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.622431] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.623926] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.625910] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.627468] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.628847] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.629760] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.630696] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.631624] ? __schedule (kernel/sched/core.c:2806)
[ 3608.633023] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.634828] kthread (kernel/kthread.c:207)
[ 3608.636666] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.638171] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.639190] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.640129] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.641121] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.642677] kswapd30        S ffff88002391fb58 28712  3815      2 0x10000000
[ 3608.645027]  ffff88002391fb58 ffff88002391faf8 ffffffffa8fa262b ffff880000000000
[ 3608.647495]  ffff8800533e0558 ffff8800533e0530 ffff880023903008 ffff8801d0dd0000
[ 3608.649456]  ffff880023903000 0000000000000001 ffff880023918000 ffffed0004723002
[ 3608.650640] Call Trace:
[ 3608.651056] ? find_next_bit (lib/find_bit.c:65)
[ 3608.652209] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.653527] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.654917] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.656467] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.657473] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.658593] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.659465] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.660356] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.661301] ? __schedule (kernel/sched/core.c:2806)
[ 3608.662706] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.664046] kthread (kernel/kthread.c:207)
[ 3608.665686] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.667371] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.668834] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.669739] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.670604] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.672113] kswapd31        S ffff88002392fb58 29584  3816      2 0x10000000
[ 3608.673743]  ffff88002392fb58 ffff88002392faf8 ffffffffa8fa262b ffff880000000000
[ 3608.675233]  ffff8800533e0558 ffff8800533e0530 ffff880023920008 ffff880023923000
[ 3608.676884]  ffff880023920000 0000000000000001 ffff880023928000 ffffed0004725002
[ 3608.678354] Call Trace:
[ 3608.678727] ? find_next_bit (lib/find_bit.c:65)
[ 3608.679500] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.680278] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.681294] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.682501] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.683637] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.684731] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.685805] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.686728] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.687806] ? __schedule (kernel/sched/core.c:2806)
[ 3608.688713] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.689728] kthread (kernel/kthread.c:207)
[ 3608.690446] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.691330] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.692474] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.693834] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.694716] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.695984] kswapd32        S ffff88000004fb58 29584  3817      2 0x10000000
[ 3608.697197]  ffff88000004fb58 ffff88000004faf8 ffffffffa8fa262b ffff880000000000
[ 3608.698467]  ffff8800533e0558 ffff8800533e0530 ffff880023923008 ffff880000050000
[ 3608.699607]  ffff880023923000 0000000000000001 ffff880000048000 ffffed0000009002
[ 3608.700737] Call Trace:
[ 3608.701136] ? find_next_bit (lib/find_bit.c:65)
[ 3608.702006] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.703301] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.704204] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.705573] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.706529] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.707599] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.708726] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.709640] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.710577] ? __schedule (kernel/sched/core.c:2806)
[ 3608.711407] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.712865] kthread (kernel/kthread.c:207)
[ 3608.713742] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.714679] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.715880] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.716806] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.718024] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.719097] kswapd33        S ffff880023937b58 29584  3818      2 0x10000000
[ 3608.720194]  ffff880023937b58 ffff880023937af8 ffffffffa8fa262b ffff880000000000
[ 3608.721452]  ffff8800533e0558 ffff8800533e0530 ffff880000050008 ffff880000053000
[ 3608.723160]  ffff880000050000 0000000000000001 ffff880023930000 ffffed0004726002
[ 3608.724937] Call Trace:
[ 3608.725707] ? find_next_bit (lib/find_bit.c:65)
[ 3608.726724] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.727751] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.728665] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.729675] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.730733] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.732126] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.733737] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.734978] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.735945] ? __schedule (kernel/sched/core.c:2806)
[ 3608.736814] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.738256] kthread (kernel/kthread.c:207)
[ 3608.739076] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.739959] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.740859] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.741750] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.742966] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.743959] kswapd34        S ffff88002393fb58 29584  3819      2 0x10000000
[ 3608.745119]  ffff88002393fb58 ffff88002393faf8 ffffffffa8fa262b ffff880000000000
[ 3608.746692]  ffff8800533e0558 ffff8800533e0530 ffff880000053008 ffff880023940000
[ 3608.748252]  ffff880000053000 0000000000000001 ffff880023938000 ffffed0004727002
[ 3608.749498] Call Trace:
[ 3608.749867] ? find_next_bit (lib/find_bit.c:65)
[ 3608.750719] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.751466] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.752338] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.753573] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.754692] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.755892] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.756876] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.758238] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.759417] ? __schedule (kernel/sched/core.c:2806)
[ 3608.760230] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.761353] kthread (kernel/kthread.c:207)
[ 3608.762272] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.763337] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.764444] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.765516] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.766330] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.767537] kswapd35        S ffff88002394fb58 29472  3820      2 0x10000000
[ 3608.768928]  ffff88002394fb58 ffff88002394faf8 ffffffffa8fa262b ffff880000000000
[ 3608.770320]  ffff8800533e0558 ffff8800533e0530 ffff880023940008 ffff880023943000
[ 3608.771536]  ffff880023940000 0000000000000001 ffff880023948000 ffffed0004729002
[ 3608.772916] Call Trace:
[ 3608.773381] ? find_next_bit (lib/find_bit.c:65)
[ 3608.774336] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.775285] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.776122] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3608.777141] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.778304] ? __schedule (kernel/sched/core.c:2801)
[ 3608.779271] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.780229] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.781224] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.782571] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.783792] ? __schedule (kernel/sched/core.c:2806)
[ 3608.784889] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3608.786169] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.787341] kthread (kernel/kthread.c:207)
[ 3608.788137] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.789096] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.790000] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.790918] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.791742] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.792951] kswapd36        S ffff880023957b58 29584  3821      2 0x10000000
[ 3608.794257]  ffff880023957b58 ffff880023957af8 ffffffffa8fa262b ffff880000000000
[ 3608.795554]  ffff8800533e0558 ffff8800533e0530 ffff880023943008 ffff880023958000
[ 3608.796798]  ffff880023943000 0000000000000001 ffff880023950000 ffffed000472a002
[ 3608.798768] Call Trace:
[ 3608.799160] ? find_next_bit (lib/find_bit.c:65)
[ 3608.799960] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.800745] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.801493] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.802853] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.803936] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.804973] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.805993] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.806878] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.807836] ? __schedule (kernel/sched/core.c:2806)
[ 3608.808741] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.809759] kthread (kernel/kthread.c:207)
[ 3608.810522] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.811510] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.812698] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.813753] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.814670] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.815732] kswapd37        S ffff88000005fb58 28712  3822      2 0x10000000
[ 3608.816820]  ffff88000005fb58 ffff88000005faf8 ffffffffa8fa262b ffff880000000000
[ 3608.818128]  ffff8800533e0558 ffff8800533e0530 ffff880023958008 ffff8801d0dd0000
[ 3608.819358]  ffff880023958000 0000000000000001 ffff880000058000 ffffed000000b002
[ 3608.820576] Call Trace:
[ 3608.820959] ? find_next_bit (lib/find_bit.c:65)
[ 3608.821750] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.822818] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.824088] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.825691] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.827803] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.828833] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.829775] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.830732] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.832305] ? __schedule (kernel/sched/core.c:2806)
[ 3608.834176] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.836216] kthread (kernel/kthread.c:207)
[ 3608.837767] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.839586] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.840828] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.842457] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.843864] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.846186] kswapd38        S ffff880000067b58 29584  3823      2 0x10000000
[ 3608.848529]  ffff880000067b58 ffff880000067af8 ffffffffa8fa262b ffff880000000000
[ 3608.850359]  ffff8800533e0558 ffff8800533e0530 ffff88002395b008 ffff880023960000
[ 3608.851414]  ffff88002395b000 0000000000000001 ffff880000060000 ffffed000000c002
[ 3608.852415] Call Trace:
[ 3608.852774] ? find_next_bit (lib/find_bit.c:65)
[ 3608.853469] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.853973] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.854737] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.856089] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.857375] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.858537] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.859523] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.860229] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.860916] ? __schedule (kernel/sched/core.c:2806)
[ 3608.861822] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.862921] kthread (kernel/kthread.c:207)
[ 3608.863603] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.864260] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.865008] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.866849] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.868491] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.870036] kswapd39        S ffff88002396fb58 29584  3824      2 0x10000000
[ 3608.871560]  ffff88002396fb58 ffff88002396faf8 ffffffffa8fa262b ffff880000000000
[ 3608.873639]  ffff8800533e0558 ffff8800533e0530 ffff880023960008 ffff880023963000
[ 3608.875774]  ffff880023960000 0000000000000001 ffff880023968000 ffffed000472d002
[ 3608.878141] Call Trace:
[ 3608.878782] ? find_next_bit (lib/find_bit.c:65)
[ 3608.879668] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.880462] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.881252] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.883198] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.885579] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.887801] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.888915] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.889833] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.890785] ? __schedule (kernel/sched/core.c:2806)
[ 3608.891607] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.893924] kthread (kernel/kthread.c:207)
[ 3608.895358] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.896480] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.897385] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.898320] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.899045] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.899707] kswapd40        S ffff880023977b58 29584  3825      2 0x10000000
[ 3608.900643]  ffff880023977b58 ffff880023977af8 ffffffffa8fa262b ffff880000000000
[ 3608.901615]  ffff8800533e0558 ffff8800533e0530 ffff880023963008 ffff880023978000
[ 3608.903194]  ffff880023963000 0000000000000001 ffff880023970000 ffffed000472e002
[ 3608.905366] Call Trace:
[ 3608.905732] ? find_next_bit (lib/find_bit.c:65)
[ 3608.906387] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.907066] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.907578] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.908366] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.909153] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.909833] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.910456] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.911240] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.912015] ? __schedule (kernel/sched/core.c:2806)
[ 3608.913190] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.914593] kthread (kernel/kthread.c:207)
[ 3608.915584] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.916276] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.916929] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.917515] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.918197] kswapd41        S ffff880023987b58 28712  3826      2 0x10000000
[ 3608.918991]  ffff880023987b58 ffff880023987af8 ffffffffa8fa262b ffff880000000000
[ 3608.919745]  ffff8800533e0558 ffff8800533e0530 ffff880023978008 ffff8801d0dd0000
[ 3608.920604]  ffff880023978000 0000000000000001 ffff880023980000 ffffed0004730002
[ 3608.921377] Call Trace:
[ 3608.921617] ? find_next_bit (lib/find_bit.c:65)
[ 3608.922514] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.924290] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.925459] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.926845] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.928317] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.929325] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.930262] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.931194] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.932360] ? __schedule (kernel/sched/core.c:2806)
[ 3608.933790] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.935365] kthread (kernel/kthread.c:207)
[ 3608.936379] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.937601] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.938495] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.939383] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.940153] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.941134] kswapd42        S ffff88000006fb58 29584  3827      2 0x10000000
[ 3608.942797]  ffff88000006fb58 ffff88000006faf8 ffffffffa8fa262b ffff880000000000
[ 3608.944800]  ffff8800533e0558 ffff8800533e0530 ffff88002397b008 ffff880000070000
[ 3608.946235]  ffff88002397b000 0000000000000001 ffff880000068000 ffffed000000d002
[ 3608.947220] Call Trace:
[ 3608.947499] ? find_next_bit (lib/find_bit.c:65)
[ 3608.948036] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.948769] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.949253] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.949919] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.950621] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.951406] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.952213] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.953555] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.954754] ? __schedule (kernel/sched/core.c:2806)
[ 3608.956665] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.957561] kthread (kernel/kthread.c:207)
[ 3608.958081] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.958734] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.959494] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.960122] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.960747] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.961465] kswapd43        S ffff880023997b58 29584  3828      2 0x10000000
[ 3608.962830]  ffff880023997b58 ffff880023997af8 ffffffffa8fa262b ffff880000000000
[ 3608.964013]  ffff8800533e0558 ffff8800533e0530 ffff880000070008 ffff880000073000
[ 3608.965349]  ffff880000070000 0000000000000001 ffff880023990000 ffffed0004732002
[ 3608.966735] Call Trace:
[ 3608.967480] ? find_next_bit (lib/find_bit.c:65)
[ 3608.968324] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.968885] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.969412] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.970842] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3608.971878] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3608.972937] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3608.974518] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.976225] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3608.977864] ? __schedule (kernel/sched/core.c:2806)
[ 3608.978863] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3608.979921] kthread (kernel/kthread.c:207)
[ 3608.980907] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.982139] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3608.983932] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.985474] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3608.986919] ? flush_kthread_work (kernel/kthread.c:176)
[ 3608.988402] kswapd44        S ffff88002399fb58 29472  3829      2 0x10000000
[ 3608.989486]  ffff88002399fb58 ffff88002399faf8 ffffffffa8fa262b ffff880000000000
[ 3608.990866]  ffff8800533e0558 ffff8800533e0530 ffff880000073008 ffff8800239a0000
[ 3608.992491]  ffff880000073000 0000000000000001 ffff880023998000 ffffed0004733002
[ 3608.994765] Call Trace:
[ 3608.995475] ? find_next_bit (lib/find_bit.c:65)
[ 3608.997253] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3608.998880] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3608.999379] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.000198] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.000880] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.001607] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.002406] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.003824] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.004736] ? __schedule (kernel/sched/core.c:2806)
[ 3609.005977] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.007259] kthread (kernel/kthread.c:207)
[ 3609.007850] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.008596] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.009175] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.009845] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.010427] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.011285] kswapd45        S ffff8800239afb58 29584  3830      2 0x10000000
[ 3609.012860]  ffff8800239afb58 ffff8800239afaf8 ffffffffa8fa262b ffff880000000000
[ 3609.015240]  ffff8800533e0558 ffff8800533e0530 ffff8800239a0008 ffff8800239a3000
[ 3609.016597]  ffff8800239a0000 0000000000000001 ffff8800239a8000 ffffed0004735002
[ 3609.018320] Call Trace:
[ 3609.018600] ? find_next_bit (lib/find_bit.c:65)
[ 3609.019304] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.019857] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.020673] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.021689] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.022926] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.024415] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.026528] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.027818] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.028803] ? __schedule (kernel/sched/core.c:2806)
[ 3609.029915] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.030820] kthread (kernel/kthread.c:207)
[ 3609.031505] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.032553] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.033772] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.035074] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.035898] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.036949] kswapd46        S ffff8800239b7b58 28712  3831      2 0x10000000
[ 3609.037917]  ffff8800239b7b58 ffff8800239b7af8 ffffffffa8fa262b ffff880000000000
[ 3609.038789]  ffff8800533e0558 ffff8800533e0530 ffff8800239a3008 ffff8801d0dd0000
[ 3609.039537]  ffff8800239a3000 0000000000000001 ffff8800239b0000 ffffed0004736002
[ 3609.040306] Call Trace:
[ 3609.040577] ? find_next_bit (lib/find_bit.c:65)
[ 3609.041199] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.041743] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.042277] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.043747] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.044863] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.045815] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.046598] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.047346] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.047990] ? __schedule (kernel/sched/core.c:2806)
[ 3609.048603] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.049256] kthread (kernel/kthread.c:207)
[ 3609.049739] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.050413] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.051077] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.051666] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.052263] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.053205] kswapd47        S ffff88000007fb58 29584  3832      2 0x10000000
[ 3609.054277]  ffff88000007fb58 ffff88000007faf8 ffffffffa8fa262b ffff880000000000
[ 3609.055200]  ffff8800533e0558 ffff8800533e0530 ffff8800239b8008 ffff8800239bb000
[ 3609.056180]  ffff8800239b8000 0000000000000001 ffff880000078000 ffffed000000f002
[ 3609.057130] Call Trace:
[ 3609.057425] ? find_next_bit (lib/find_bit.c:65)
[ 3609.058047] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.058573] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.059065] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.059745] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.060439] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.061098] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.061797] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.062891] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.063730] ? __schedule (kernel/sched/core.c:2806)
[ 3609.064447] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.065257] kthread (kernel/kthread.c:207)
[ 3609.065868] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.066586] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.067339] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.068066] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.068591] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.069166] kswapd48        S ffff8800239c7b58 29584  3833      2 0x10000000
[ 3609.069888]  ffff8800239c7b58 ffff8800239c7af8 ffffffffa8fa262b ffff880000000000
[ 3609.070686]  ffff8800533e0558 ffff8800533e0530 ffff8800239bb008 ffff8800239c8000
[ 3609.071599]  ffff8800239bb000 0000000000000001 ffff8800239c0000 ffffed0004738002
[ 3609.073149] Call Trace:
[ 3609.073626] ? find_next_bit (lib/find_bit.c:65)
[ 3609.074529] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.075228] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.076180] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.077412] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.078338] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.079043] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.079635] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.080252] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.081131] ? __schedule (kernel/sched/core.c:2806)
[ 3609.081834] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.083283] kthread (kernel/kthread.c:207)
[ 3609.083768] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.084622] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.085350] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.086378] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.087090] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.087739] kswapd49        S ffff8800239d7b58 29584  3834      2 0x10000000
[ 3609.088485]  ffff8800239d7b58 ffff8800239d7af8 ffffffffa8fa262b ffff880000000000
[ 3609.089231]  ffff8800533e0558 ffff8800533e0530 ffff8800239c8008 ffff8800239cb000
[ 3609.090014]  ffff8800239c8000 0000000000000001 ffff8800239d0000 ffffed000473a002
[ 3609.090808] Call Trace:
[ 3609.091063] ? find_next_bit (lib/find_bit.c:65)
[ 3609.091908] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.092421] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.093406] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.094333] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.095035] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.095815] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.096824] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.097517] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.098166] ? __schedule (kernel/sched/core.c:2806)
[ 3609.098767] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.099421] kthread (kernel/kthread.c:207)
[ 3609.099898] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.100513] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.101106] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.101709] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.102240] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.103507] kswapd50        S ffff8800239dfb58 29584  3835      2 0x10000000
[ 3609.104884]  ffff8800239dfb58 ffff8800239dfaf8 ffffffffa8fa262b ffff880000000000
[ 3609.105802]  ffff8800533e0558 ffff8800533e0530 ffff8800239cb008 ffff8800239e0000
[ 3609.106592]  ffff8800239cb000 0000000000000001 ffff8800239d8000 ffffed000473b002
[ 3609.107460] Call Trace:
[ 3609.107718] ? find_next_bit (lib/find_bit.c:65)
[ 3609.108285] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.108783] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.109269] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.109940] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.110581] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.111269] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.112110] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.112753] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.114151] ? __schedule (kernel/sched/core.c:2806)
[ 3609.114896] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.116127] kthread (kernel/kthread.c:207)
[ 3609.117631] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.118595] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.119226] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.119836] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.120402] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.121208] kswapd51        S ffff8800239efb58 29584  3836      2 0x10000000
[ 3609.122351]  ffff8800239efb58 ffff8800239efaf8 ffffffffa8fa262b ffff880000000000
[ 3609.124260]  ffff8800533e0558 ffff8800533e0530 ffff8800239e0008 ffff8800239e3000
[ 3609.125452]  ffff8800239e0000 0000000000000001 ffff8800239e8000 ffffed000473d002
[ 3609.126610] Call Trace:
[ 3609.127114] ? find_next_bit (lib/find_bit.c:65)
[ 3609.128214] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.128930] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.129549] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.130383] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.131097] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.131967] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.133047] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.133713] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.134870] ? __schedule (kernel/sched/core.c:2806)
[ 3609.135702] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.136927] kthread (kernel/kthread.c:207)
[ 3609.137611] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.138347] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.138930] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.139518] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.140028] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.140732] kswapd52        S ffff88000010fb58 29584  3837      2 0x10000000
[ 3609.141914]  ffff88000010fb58 ffff88000010faf8 ffffffffa8fa262b ffff880000000000
[ 3609.143536]  ffff8800533e0558 ffff8800533e0530 ffff8800239e3008 ffff8801d0dd0000
[ 3609.144765]  ffff8800239e3000 0000000000000001 ffff880000108000 ffffed0000021002
[ 3609.146206] Call Trace:
[ 3609.146459] ? find_next_bit (lib/find_bit.c:65)
[ 3609.146995] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.147499] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.147992] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.148809] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.149493] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.150125] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.150730] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.151334] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.151975] ? __schedule (kernel/sched/core.c:2806)
[ 3609.153481] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.154514] kthread (kernel/kthread.c:207)
[ 3609.155040] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.156232] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.157529] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.158418] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.159235] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.159964] kswapd53        S ffff8800239f7b58 29584  3838      2 0x10000000
[ 3609.160752]  ffff8800239f7b58 ffff8800239f7af8 ffffffffa8fa262b ffff880000000000
[ 3609.161911]  ffff8800533e0558 ffff8800533e0530 ffff880000110008 ffff880000113000
[ 3609.163911]  ffff880000110000 0000000000000001 ffff8800239f0000 ffffed000473e002
[ 3609.165866] Call Trace:
[ 3609.166815] ? find_next_bit (lib/find_bit.c:65)
[ 3609.168370] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.169138] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.169833] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.170831] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.171844] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.173465] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.174761] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.176073] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.177028] ? __schedule (kernel/sched/core.c:2806)
[ 3609.178002] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.179157] kthread (kernel/kthread.c:207)
[ 3609.179654] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.180411] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.181013] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.181915] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.183303] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.184524] kswapd54        S ffff880023a07b58 29584  3839      2 0x10000000
[ 3609.186974]  ffff880023a07b58 ffff880023a07af8 ffffffffa8fa262b ffff880000000000
[ 3609.188697]  ffff8800533e0558 ffff8800533e0530 ffff880000113008 ffff880023a08000
[ 3609.190202]  ffff880000113000 0000000000000001 ffff880023a00000 ffffed0004740002
[ 3609.191090] Call Trace:
[ 3609.191589] ? find_next_bit (lib/find_bit.c:65)
[ 3609.192636] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.193535] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.194337] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.195434] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.196522] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.197272] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.197950] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.198795] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.199627] ? __schedule (kernel/sched/core.c:2806)
[ 3609.200246] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.201168] kthread (kernel/kthread.c:207)
[ 3609.201654] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.202346] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.203786] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.204923] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.206007] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.207697] kswapd55        S ffff880023a17b58 29472  3840      2 0x10000000
[ 3609.208949]  ffff880023a17b58 ffff880023a17af8 ffffffffa8fa262b ffff880000000000
[ 3609.209777]  ffff8800533e0558 ffff8800533e0530 ffff880023a08008 ffff880023a0b000
[ 3609.210669]  ffff880023a08000 0000000000000001 ffff880023a10000 ffffed0004742002
[ 3609.211511] Call Trace:
[ 3609.211901] ? find_next_bit (lib/find_bit.c:65)
[ 3609.212765] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.213473] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.214025] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.214857] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.215733] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.216434] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.217109] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.217955] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.218710] ? __schedule (kernel/sched/core.c:2806)
[ 3609.219232] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.219887] kthread (kernel/kthread.c:207)
[ 3609.220607] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.221371] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.222207] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.223509] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.224196] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.225126] kswapd56        S ffff880023a1fb58 28712  3841      2 0x10000000
[ 3609.226236]  ffff880023a1fb58 ffff880023a1faf8 ffffffffa8fa262b ffff880000000000
[ 3609.227161]  ffff8800533e0558 ffff8800533e0530 ffff880023a0b008 ffff8801d0dd0000
[ 3609.228093]  ffff880023a0b000 0000000000000001 ffff880023a18000 ffffed0004743002
[ 3609.229056] Call Trace:
[ 3609.229301] ? find_next_bit (lib/find_bit.c:65)
[ 3609.229830] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.230392] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.231019] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.231962] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.232715] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.233797] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.235374] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.236713] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.238100] ? __schedule (kernel/sched/core.c:2806)
[ 3609.239301] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.240421] kthread (kernel/kthread.c:207)
[ 3609.241201] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.242632] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.244331] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.246015] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.247289] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.248293] kswapd57        S ffff880000127b58 28328  3842      2 0x10000000
[ 3609.249379]  ffff880000127b58 ffff880000127af8 ffffffffa8fa262b ffff880000000000
[ 3609.250624]  ffff8800261e0558 ffff8800261e0530 ffff880000118008 ffffffffb4839100
[ 3609.251990]  ffff880000118000 0000000000000001 ffff880000120000 ffffed0000024002
[ 3609.253787] Call Trace:
[ 3609.254285] ? find_next_bit (lib/find_bit.c:65)
[ 3609.255651] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.256414] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.257209] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.258282] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.259372] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.260370] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.261490] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.263570] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.264490] ? __schedule (kernel/sched/core.c:2806)
[ 3609.266097] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.267583] kthread (kernel/kthread.c:207)
[ 3609.268858] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.269832] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.270524] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.271137] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.271830] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.272790] kswapd58        S ffff880023a27b58 29440  3843      2 0x10000000
[ 3609.274317]  ffff880023a27b58 ffff880023a27af8 ffffffffa8fa262b ffff880000000000
[ 3609.277000]  ffff8800533e0558 ffff8800533e0530 ffff88000011b008 ffff880023a28000
[ 3609.278743]  ffff88000011b000 0000000000000001 ffff880023a20000 ffffed0004744002
[ 3609.279926] Call Trace:
[ 3609.280311] ? find_next_bit (lib/find_bit.c:65)
[ 3609.281205] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.282257] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.283515] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.284836] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.286767] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.287795] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.288760] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.289686] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.290688] ? __schedule (kernel/sched/core.c:2806)
[ 3609.291621] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.293620] kthread (kernel/kthread.c:207)
[ 3609.294824] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.296422] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.297474] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.298429] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.299228] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.300171] kswapd59        S ffff880023a37b58 29472  3844      2 0x10000000
[ 3609.301579]  ffff880023a37b58 ffff880023a37af8 ffffffffa8fa262b ffff880000000000
[ 3609.303634]  ffff8800533e0558 ffff8800533e0530 ffff880023a28008 ffff880023a2b000
[ 3609.306255]  ffff880023a28000 0000000000000001 ffff880023a30000 ffffed0004746002
[ 3609.308488] Call Trace:
[ 3609.308953] ? find_next_bit (lib/find_bit.c:65)
[ 3609.309788] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.310618] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.311485] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.313368] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.314931] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.315920] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.316535] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.317175] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.317984] ? __schedule (kernel/sched/core.c:2806)
[ 3609.318876] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.319607] kthread (kernel/kthread.c:207)
[ 3609.320085] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.320776] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.321476] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.322492] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.323299] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.324408] kswapd60        S ffff880023a3fb58 28712  3845      2 0x10000000
[ 3609.325900]  ffff880023a3fb58 ffff880023a3faf8 ffffffffa8fa262b ffff880000000000
[ 3609.326771]  ffff8800533e0558 ffff8800533e0530 ffff880023a2b008 ffff8801d0dd0000
[ 3609.327531]  ffff880023a2b000 0000000000000001 ffff880023a38000 ffffed0004747002
[ 3609.328335] Call Trace:
[ 3609.328588] ? find_next_bit (lib/find_bit.c:65)
[ 3609.329106] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.329609] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.330124] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.330850] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.331598] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.332760] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.333490] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.334094] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.335235] ? __schedule (kernel/sched/core.c:2806)
[ 3609.335799] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.337080] kthread (kernel/kthread.c:207)
[ 3609.337563] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.338193] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.338826] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.339403] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.339914] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.340592] kswapd61        S ffff880023a4fb58 29440  3846      2 0x10000000
[ 3609.341453]  ffff880023a4fb58 ffff880023a4faf8 ffffffffa8fa262b ffff880000000000
[ 3609.342549]  ffff8800533e0558 ffff8800533e0530 ffff880023a40008 ffff880023a43000
[ 3609.343735]  ffff880023a40000 0000000000000001 ffff880023a48000 ffffed0004749002
[ 3609.344864] Call Trace:
[ 3609.345354] ? find_next_bit (lib/find_bit.c:65)
[ 3609.346034] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.346700] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.347301] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.348079] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.348707] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.349357] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.350001] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.350807] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.351607] ? __schedule (kernel/sched/core.c:2806)
[ 3609.352494] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.353427] kthread (kernel/kthread.c:207)
[ 3609.353933] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.354761] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.355605] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.356364] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.356878] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.357547] kswapd62        S ffff88000012fb58 29584  3847      2 0x10000000
[ 3609.358555]  ffff88000012fb58 ffff88000012faf8 ffffffffa8fa262b ffff880000000000
[ 3609.359387]  ffff8800533e0558 ffff8800533e0530 ffff880023a43008 ffff880000130000
[ 3609.360163]
[ 3609.360414]  ffff880023a43000 0000000000000001 ffff880000128000 ffffed0000025002
[ 3609.361225] Call Trace:
[ 3609.361503] ? find_next_bit (lib/find_bit.c:65)
[ 3609.362425] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.363187] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.363802] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.364498] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.365586] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.366291] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.366961] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.368409] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.369317] ? __schedule (kernel/sched/core.c:2806)
[ 3609.370287] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.371476] kthread (kernel/kthread.c:207)
[ 3609.372745] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.374635] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.376671] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.378945] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.380422] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.382261] kswapd63        S ffff880023a57b58 28712  3848      2 0x10000000
[ 3609.384736]  ffff880023a57b58 ffff880023a57af8 ffffffffa8fa262b ffff880000000000
[ 3609.387211]  ffff8800533e0558 ffff8800533e0530 ffff880000130008 ffff8801d0dd0000
[ 3609.389859]  ffff880000130000 0000000000000001 ffff880023a50000 ffffed000474a002
[ 3609.391611] Call Trace:
[ 3609.392035] ? find_next_bit (lib/find_bit.c:65)
[ 3609.393049] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.394363] kswapd (mm/vmscan.c:3375 mm/vmscan.c:3463)
[ 3609.395956] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.397882] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3609.398946] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3609.399910] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.400996] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.402290] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.403932] ? __schedule (kernel/sched/core.c:2806)
[ 3609.405249] ? try_to_free_mem_cgroup_pages (mm/vmscan.c:3401)
[ 3609.407709] kthread (kernel/kthread.c:207)
[ 3609.408757] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.409638] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.410604] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.411612] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.412823] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.415037] fsnotify_mark   S ffff880023b47c98 30120  3977      2 0x10000000
[ 3609.416944]  ffff880023b47c98 ffff880152900fc0 0000000000000286 0000000000000000
[ 3609.418995]  ffff8800533e0558 ffff8800533e0530 ffff880000133008 ffff880051420000
[ 3609.420609]  ffff880000133000 ffffffffb1f38440 ffff880023b40000 ffffed0004768002
[ 3609.422006] Call Trace:
[ 3609.422521] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.423763] fsnotify_mark_destroy (fs/notify/mark.c:477 (discriminator 13))
[ 3609.425814] ? fsnotify_put_mark (fs/notify/mark.c:460)
[ 3609.427522] ? __schedule (kernel/sched/core.c:2806)
[ 3609.429274] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.430266] ? fsnotify_put_mark (fs/notify/mark.c:460)
[ 3609.431213] kthread (kernel/kthread.c:207)
[ 3609.431994] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.433148] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.434181] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.435478] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.436706] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.438422] kworker/10:1    S ffff8801fa667ce8 27832  4032      2 0x10000000
[ 3609.439641]  ffff8801fa667ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3609.440947]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fa5b3008 ffff880052dc8000
[ 3609.442288]  ffff8801fa5b3000 ffff8801fa667cc8 ffff8801fa660000 ffffed003f4cc002
[ 3609.443733] Call Trace:
[ 3609.444116] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3609.445095] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.446509] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3609.447947] ? __schedule (kernel/sched/core.c:2806)
[ 3609.449198] ? process_one_work (kernel/workqueue.c:2101)
[ 3609.450140] kthread (kernel/kthread.c:207)
[ 3609.451069] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.452129] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.453582] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.454581] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.455984] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.457504] kworker/15:1    S ffff8802cca6fce8 28840  4033      2 0x10000000
[ 3609.459757]  ffff8802cca6fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3609.461096]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cca60008 ffff8803c8df0000
[ 3609.463304]  ffff8802cca60000 ffff8802cca6fcc8 ffff8802cca68000 ffffed005994d002
[ 3609.465025] Call Trace:
[ 3609.465902] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3609.467081] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.468206] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3609.469433] ? __schedule (kernel/sched/core.c:2806)
[ 3609.470282] ? process_one_work (kernel/workqueue.c:2101)
[ 3609.471189] kthread (kernel/kthread.c:207)
[ 3609.471929] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.473179] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.474456] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.476220] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.478286] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.479678] ecryptfs-kthrea S ffff8801fa6e7cb8 29304  4044      2 0x10000000
[ 3609.480788]  ffff8801fa6e7cb8 ffff8801fa6e7c88 0000000000000286 0000000000000000
[ 3609.482479]  ffff8802253e0558 ffff8802253e0530 ffff8801fa5b0008 ffff8800a6dd0000
[ 3609.484640]  ffff8801fa5b0000 ffffffffb1feaaa0 ffff8801fa6e0000 ffffed003f4dc002
[ 3609.486765] Call Trace:
[ 3609.487601] ? ecryptfs_add_global_auth_tok (fs/ecryptfs/kthread.c:57)
[ 3609.490197] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.491129] ecryptfs_threadfn (include/linux/freezer.h:64 (discriminator 14) fs/ecryptfs/kthread.c:62 (discriminator 14))
[ 3609.492037] ? ecryptfs_add_global_auth_tok (fs/ecryptfs/kthread.c:57)
[ 3609.493782] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3609.495552] ? ecryptfs_add_global_auth_tok (fs/ecryptfs/kthread.c:57)
[ 3609.497177] kthread (kernel/kthread.c:207)
[ 3609.498108] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.499342] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.500318] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.501396] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.502619] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.504491] nfsiod          S ffff8801fa71fc28 29840  4048      2 0x10000000
[ 3609.506708]  ffff8801fa71fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3609.508408]  ffff8802253e0558 ffff8802253e0530 ffff8801fa640008 ffff8800a6dd0000
[ 3609.509757]  ffff8801fa640000 ffff8801fa71fc08 ffff8801fa718000 ffffed003f4e3002
[ 3609.510967] Call Trace:
[ 3609.511455] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3609.512314] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.513506] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3609.514594] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.516191] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3609.517976] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.519208] ? __schedule (kernel/sched/core.c:2806)
[ 3609.520034] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.520930] kthread (kernel/kthread.c:207)
[ 3609.521803] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.522960] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.524548] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.526392] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.528224] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.529480] cifsiod         S ffff8801fa567c28 29840  4063      2 0x10000000
[ 3609.530597]  ffff8801fa567c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3609.531993]  ffff8802253e0558 ffff8802253e0530 ffff8801fa50b008 ffff8800a6dd0000
[ 3609.533886]  ffff8801fa50b000 ffff8801fa567c08 ffff8801fa560000 ffffed003f4ac002
[ 3609.535795] Call Trace:
[ 3609.536531] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3609.538274] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.539307] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3609.540155] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.541106] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3609.542043] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.543072] ? __schedule (kernel/sched/core.c:2806)
[ 3609.543870] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.544914] kthread (kernel/kthread.c:207)
[ 3609.545646] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.546151] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.546650] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.547447] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.548672] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.549298] jfsIO           S ffff8801fa56fce8 30368  4093      2 0x10000000
[ 3609.550107]  ffff8801fa56fce8 0000000000000000 ffffffffa81e8e43 0000000000000000
[ 3609.551006]  ffff8802253e0558 ffff8802253e0530 ffff8801fa65b008 ffff8800a6dd0000
[ 3609.551790]  ffff8801fa65b000 ffff8801fa56fcc8 ffff8801fa568000 ffffed003f4ad002
[ 3609.552621] Call Trace:
[ 3609.552925] ? jfsIOWait (fs/jfs/jfs_logmgr.c:2360 (discriminator 1))
[ 3609.553549] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.554038] jfsIOWait (fs/jfs/jfs_logmgr.c:2362)
[ 3609.554594] ? lmLogClose (fs/jfs/jfs_logmgr.c:2341)
[ 3609.555406] ? lmLogClose (fs/jfs/jfs_logmgr.c:2341)
[ 3609.556133] ? lmLogClose (fs/jfs/jfs_logmgr.c:2341)
[ 3609.556876] kthread (kernel/kthread.c:207)
[ 3609.557378] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.558558] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.559540] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.560500] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.561347] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.562420] jfsCommit       S ffff8801fa6d7c58 30184  4094      2 0x10000000
[ 3609.563792]  ffff8801fa6d7c58 ffff8801fa6d7c88 ffffffffa81f6b63 0000000000000000
[ 3609.565699]  ffff8802253e0558 ffff8802253e0530 ffff8801fa658008 ffff8800a6dd0000
[ 3609.567726]  ffff8801fa658000 1ffffffff69124f1 ffff8801fa6d0000 ffffed003f4da002
[ 3609.570141] Call Trace:
[ 3609.570699] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.571674] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.572990] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.573848] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.574756] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.576075] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.577132] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.578533] ? __schedule (kernel/sched/core.c:2806)
[ 3609.579429] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.580234] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.581067] kthread (kernel/kthread.c:207)
[ 3609.581859] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.583533] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.585340] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.587494] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.589064] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.590024] jfsCommit       S ffff8801fa59fc58 30224  4095      2 0x10000000
[ 3609.591122]  ffff8801fa59fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.592915]  ffff88024f3e0558 ffff88024f3e0530 ffff8801fa670008 ffff88017cdd0000
[ 3609.594730]  ffff8801fa670000 ffff8801fa59fc38 ffff8801fa598000 ffffed003f4b3002
[ 3609.596475] Call Trace:
[ 3609.596933] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.598679] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.599636] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.600399] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.601384] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.602647] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.604406] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.606545] ? __schedule (kernel/sched/core.c:2806)
[ 3609.608566] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.610535] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.612189] kthread (kernel/kthread.c:207)
[ 3609.613804] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.615930] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.618111] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.620131] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.621021] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.622693] jfsCommit       S ffff8801fa66fc58 30224  4096      2 0x10000000
[ 3609.625412]  ffff8801fa66fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.627844]  ffff8802253e0558 ffff8802253e0530 ffff8801fa673008 ffff8800a6dd0000
[ 3609.629794]  ffff8801fa673000 ffff8801fa66fc38 ffff8801fa668000 ffffed003f4cd002
[ 3609.630986] Call Trace:
[ 3609.631373] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.632644] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.634037] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.634962] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.636697] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.638671] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.640013] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.640927] ? __schedule (kernel/sched/core.c:2806)
[ 3609.641850] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.643356] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.644327] kthread (kernel/kthread.c:207)
[ 3609.646162] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.648292] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.649452] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.650365] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.651294] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.652516] jfsCommit       S ffff8801fa6cfc58 30224  4097      2 0x10000000
[ 3609.654028]  ffff8801fa6cfc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.656222]  ffff8802253e0558 ffff8802253e0530 ffff8801fa508008 ffff8800a6dd0000
[ 3609.658191]  ffff8801fa508000 ffff8801fa6cfc38 ffff8801fa6c8000 ffffed003f4d9002
[ 3609.659451] Call Trace:
[ 3609.659866] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.660764] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.661603] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.662496] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.663586] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.665194] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.666639] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.667688] ? __schedule (kernel/sched/core.c:2806)
[ 3609.668832] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.669848] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.670780] kthread (kernel/kthread.c:207)
[ 3609.671644] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.672986] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.675033] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.676898] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.678855] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.679926] jfsCommit       S ffff8801fa72fc58 30224  4098      2 0x10000000
[ 3609.681215]  ffff8801fa72fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.682889]  ffff8802253e0558 ffff8802253e0530 ffff8801fa6eb008 ffff8800a6dd0000
[ 3609.684758]  ffff8801fa6eb000 ffff8801fa72fc38 ffff8801fa728000 ffffed003f4e5002
[ 3609.687579] Call Trace:
[ 3609.688522] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.690236] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.691073] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.691904] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.693500] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.695272] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.697520] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.699159] ? __schedule (kernel/sched/core.c:2806)
[ 3609.700079] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.700959] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.701786] kthread (kernel/kthread.c:207)
[ 3609.703211] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.704217] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.705761] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.706767] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.707937] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.708968] jfsCommit       S ffff8801fa737c58 30224  4099      2 0x10000000
[ 3609.710073]  ffff8801fa737c58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.711347]  ffff8802253e0558 ffff8802253e0530 ffff8801fa6e8008 ffff8800a6dd0000
[ 3609.712821]  ffff8801fa6e8000 ffff8801fa737c38 ffff8801fa730000 ffffed003f4e6002
[ 3609.714807] Call Trace:
[ 3609.715750] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.716979] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.718570] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.719351] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.720214] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.721137] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.722361] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.724196] ? __schedule (kernel/sched/core.c:2806)
[ 3609.725840] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.727552] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.728388] kthread (kernel/kthread.c:207)
[ 3609.729143] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.730055] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.730970] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.732023] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.733429] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.734455] jfsCommit       S ffff8801fa73fc58 30224  4100      2 0x10000000
[ 3609.735874]  ffff8801fa73fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.736993]  ffff8802253e0558 ffff8802253e0530 ffff8801fa643008 ffff8800a6dd0000
[ 3609.738241]  ffff8801fa643000 ffff8801fa73fc38 ffff8801fa738000 ffffed003f4e7002
[ 3609.739413] Call Trace:
[ 3609.739809] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.740646] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.741533] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.742621] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.744231] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.745458] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.746367] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.747195] ? __schedule (kernel/sched/core.c:2806)
[ 3609.748142] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.748966] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.749776] kthread (kernel/kthread.c:207)
[ 3609.750536] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.751478] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.752557] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.753629] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.754484] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.755498] jfsCommit       S ffff8801fa697c58 30224  4101      2 0x10000000
[ 3609.756580]  ffff8801fa697c58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.757823]  ffff8802253e0558 ffff8802253e0530 ffff8801fa688008 ffff8800a6dd0000
[ 3609.758999]  ffff8801fa688000 ffff8801fa697c38 ffff8801fa690000 ffffed003f4d2002
[ 3609.760179] Call Trace:
[ 3609.760548] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.761408] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.762187] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.762990] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.763836] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.764838] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.765844] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.766660] ? __schedule (kernel/sched/core.c:2806)
[ 3609.767487] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.768321] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.769111] kthread (kernel/kthread.c:207)
[ 3609.770098] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.770699] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.771290] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.771876] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.772446] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.773362] jfsCommit       S ffff8801fa69fc58 28968  4102      2 0x10000000
[ 3609.774095]  ffff8801fa69fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.775031]  ffff8802253e0558 ffff8802253e0530 ffff8801fa68b008 ffff8800a6dd0000
[ 3609.775899]  ffff8801fa68b000 ffff8801fa69fc38 ffff8801fa698000 ffffed003f4d3002
[ 3609.776689] Call Trace:
[ 3609.777107] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.777709] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.778429] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.778903] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.779439] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.780019] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.780613] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.781141] ? __schedule (kernel/sched/core.c:2806)
[ 3609.781670] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.782252] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.783121] kthread (kernel/kthread.c:207)
[ 3609.783610] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.784258] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.785120] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.785960] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.786509] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.787357] jfsCommit       S ffff8801fa6afc58 30224  4103      2 0x10000000
[ 3609.788322]  ffff8801fa6afc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.789073]  ffff8802253e0558 ffff8802253e0530 ffff8801fa6a0008 ffff8800a6dd0000
[ 3609.789912]  ffff8801fa6a0000 ffff8801fa6afc38 ffff8801fa6a8000 ffffed003f4d5002
[ 3609.790696] Call Trace:
[ 3609.790945] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.791505] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.792072] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.792925] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.793567] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.794251] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.794970] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.795525] ? __schedule (kernel/sched/core.c:2806)
[ 3609.796054] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.796579] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.797112] kthread (kernel/kthread.c:207)
[ 3609.797665] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.798274] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.798868] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.799449] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.799961] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.800553] jfsCommit       S ffff8801fa6b7c58 30224  4104      2 0x10000000
[ 3609.801275]  ffff8801fa6b7c58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.802147]  ffff8802253e0558 ffff8802253e0530 ffff8801fa6a3008 ffff8800a6dd0000
[ 3609.803306]  ffff8801fa6a3000 ffff8801fa6b7c38 ffff8801fa6b0000 ffffed003f4d6002
[ 3609.804062] Call Trace:
[ 3609.804340] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.805131] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.805799] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.806493] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.807052] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.807762] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.808405] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.809057] ? __schedule (kernel/sched/core.c:2806)
[ 3609.809617] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.810156] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.810979] kthread (kernel/kthread.c:207)
[ 3609.811508] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.812161] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.813512] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.814263] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.815917] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.817016] jfsCommit       S ffff8801fa747c58 30224  4105      2 0x10000000
[ 3609.818422]  ffff8801fa747c58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.819763]  ffff8802253e0558 ffff8802253e0530 ffff8801fa6b8008 ffff8800a6dd0000
[ 3609.820671]  ffff8801fa6b8000 ffff8801fa747c38 ffff8801fa740000 ffffed003f4e8002
[ 3609.821551] Call Trace:
[ 3609.821932] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.823279] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.823863] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.824397] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.824970] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.826111] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.827263] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.828194] ? __schedule (kernel/sched/core.c:2806)
[ 3609.829302] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.829978] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.830817] kthread (kernel/kthread.c:207)
[ 3609.831285] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.832189] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.833442] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.834069] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.835034] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.835906] jfsCommit       S ffff8801fa74fc58 30224  4106      2 0x10000000
[ 3609.836916]  ffff8801fa74fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.838064]  ffff8802253e0558 ffff8802253e0530 ffff8801fa6bb008 ffff8800a6dd0000
[ 3609.839276]  ffff8801fa6bb000 ffff8801fa74fc38 ffff8801fa748000 ffffed003f4e9002
[ 3609.840056] Call Trace:
[ 3609.840373] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.841139] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.841796] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.842924] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.843892] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.844915] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.845855] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.846623] ? __schedule (kernel/sched/core.c:2806)
[ 3609.847209] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.848030] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.848755] kthread (kernel/kthread.c:207)
[ 3609.849616] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.850263] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.851163] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.851736] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.852334] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.853808] jfsCommit       S ffff8801fa75fc58 30224  4107      2 0x10000000
[ 3609.854872]  ffff8801fa75fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.856250]  ffff8802253e0558 ffff8802253e0530 ffff8801fa750008 ffff8800a6dd0000
[ 3609.857291]  ffff8801fa750000 ffff8801fa75fc38 ffff8801fa758000 ffffed003f4eb002
[ 3609.858491] Call Trace:
[ 3609.858891] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.859561] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.860088] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.860637] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.861221] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.862247] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.863867] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.865566] ? __schedule (kernel/sched/core.c:2806)
[ 3609.867876] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.868687] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.869684] kthread (kernel/kthread.c:207)
[ 3609.870418] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.871324] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.872439] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.873583] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.874035] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.875203] jfsCommit       S ffff8801fa767c58 30224  4108      2 0x10000000
[ 3609.876715]  ffff8801fa767c58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.877585]  ffff8802253e0558 ffff8802253e0530 ffff8801fa753008 ffff8800a6dd0000
[ 3609.878860]  ffff8801fa753000 ffff8801fa767c38 ffff8801fa760000 ffffed003f4ec002
[ 3609.879751] Call Trace:
[ 3609.880118] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.880836] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.881456] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.882014] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.882826] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.884384] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.885930] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.886880] ? __schedule (kernel/sched/core.c:2806)
[ 3609.887606] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.888475] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.889148] kthread (kernel/kthread.c:207)
[ 3609.889689] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.890295] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.890939] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.891589] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.892253] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.894159] jfsCommit       S ffff8801fa777c58 30224  4109      2 0x10000000
[ 3609.895146]  ffff8801fa777c58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.896938]  ffff8802253e0558 ffff8802253e0530 ffff8801fa768008 ffff8800a6dd0000
[ 3609.898017]  ffff8801fa768000 ffff8801fa777c38 ffff8801fa770000 ffffed003f4ee002
[ 3609.899134] Call Trace:
[ 3609.899566] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.900155] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.900766] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.901350] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.902101] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.903047] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.904074] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.905340] ? __schedule (kernel/sched/core.c:2806)
[ 3609.905926] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.906781] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.907708] kthread (kernel/kthread.c:207)
[ 3609.908369] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.909140] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.909920] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.910587] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.911147] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.912034] jfsCommit       S ffff8801fa77fc58 30224  4110      2 0x10000000
[ 3609.913911]  ffff8801fa77fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.915874]  ffff8802253e0558 ffff8802253e0530 ffff8801fa76b008 ffff8800a6dd0000
[ 3609.917230]  ffff8801fa76b000 ffff8801fa77fc38 ffff8801fa778000 ffffed003f4ef002
[ 3609.918523] Call Trace:
[ 3609.918850] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.919770] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.920323] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.920853] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.921504] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.922103] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.923405] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.924391] ? __schedule (kernel/sched/core.c:2806)
[ 3609.924995] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.926725] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.927675] kthread (kernel/kthread.c:207)
[ 3609.928441] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.929146] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.929759] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.930352] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.930984] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.931593] jfsCommit       S ffff8801fa78fc58 30224  4111      2 0x10000000
[ 3609.933477]  ffff8801fa78fc58 0000000000000000 ffffffffa81f6b63 0000000000000000
[ 3609.934841]  ffff8802253e0558 ffff8802253e0530 ffff8801fa780008 ffff8800a6dd0000
[ 3609.935826]  ffff8801fa780000 ffff8801fa78fc38 ffff8801fa788000 ffffed003f4f1002
[ 3609.936663] Call Trace:
[ 3609.936935] ? jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2809 (discriminator 1))
[ 3609.937612] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.938209] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.938723] jfs_lazycommit (fs/jfs/jfs_txnmgr.c:2810 (discriminator 1))
[ 3609.939250] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.939828] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.940498] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.941279] ? __schedule (kernel/sched/core.c:2806)
[ 3609.941866] ? wake_up_state (kernel/sched/core.c:2973)
[ 3609.943049] ? txCommit (fs/jfs/jfs_txnmgr.c:2748)
[ 3609.943636] kthread (kernel/kthread.c:207)
[ 3609.944216] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.944898] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.945656] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.946287] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.946810] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.947629] jfsSync         S ffff8801fa797ca8 30304  4112      2 0x10000000
[ 3609.948608]  ffff8801fa797ca8 0000000000000000 ffffffffa81f7707 0000000000000000
[ 3609.949395]  ffff8802253e0558 ffff8802253e0530 ffff8801fa783008 ffff8800a6dd0000
[ 3609.950292]  ffff8801fa783000 ffff8801fa783000 ffff8801fa790000 ffffed003f4f2002
[ 3609.951150] Call Trace:
[ 3609.951416] ? jfs_sync (fs/jfs/jfs_txnmgr.c:2996 (discriminator 1))
[ 3609.951994] ? txResume (fs/jfs/jfs_txnmgr.c:2932)
[ 3609.953042] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.953619] jfs_sync (fs/jfs/jfs_txnmgr.c:2998)
[ 3609.954114] ? txResume (fs/jfs/jfs_txnmgr.c:2932)
[ 3609.954643] ? __schedule (kernel/sched/core.c:2806)
[ 3609.955400] ? txResume (fs/jfs/jfs_txnmgr.c:2932)
[ 3609.956053] kthread (kernel/kthread.c:207)
[ 3609.956777] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.957648] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.958307] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.959027] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.959530] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.960137] xfsalloc        S ffff8801fa7d7c28 29304  4126      2 0x10000000
[ 3609.960876]  ffff8801fa7d7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3609.961652]  ffff8802253e0558 ffff8802253e0530 ffff8801fa7c0008 ffff8800a6dd0000
[ 3609.962780]  ffff8801fa7c0000 ffff8801fa7d7c08 ffff8801fa7d0000 ffffed003f4fa002
[ 3609.963693] Call Trace:
[ 3609.963944] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3609.964519] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.965102] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3609.965742] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.966496] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3609.967435] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.968137] ? __schedule (kernel/sched/core.c:2806)
[ 3609.968718] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.969255] kthread (kernel/kthread.c:207)
[ 3609.969740] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.970460] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.971077] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.971690] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.972494] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.973403] xfs_mru_cache   S ffff8802ccab7c28 29840  4128      2 0x10000000
[ 3609.974173]  ffff8802ccab7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3609.975184]  ffff8802f73e0558 ffff8802f73e0530 ffff8802cca63008 ffff880518df8000
[ 3609.976418]  ffff8802cca63000 ffff8802ccab7c08 ffff8802ccab0000 ffffed0059956002
[ 3609.977612] Call Trace:
[ 3609.977955] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3609.978698] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.979249] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3609.979778] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.980448] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3609.981210] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.981778] ? __schedule (kernel/sched/core.c:2806)
[ 3609.982910] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.983508] kthread (kernel/kthread.c:207)
[ 3609.983976] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.984599] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.985332] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.986205] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.986913] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.987658] ocfs2_wq        S ffff8802ccadfc28 29840  4142      2 0x10000000
[ 3609.988435]  ffff8802ccadfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3609.989225]  ffff8802f73e0558 ffff8802f73e0530 ffff8802ccad0008 ffff880518df8000
[ 3609.990040]  ffff8802ccad0000 ffff8802ccadfc08 ffff8802ccad8000 ffffed005995b002
[ 3609.990903] Call Trace:
[ 3609.991154] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3609.991781] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3609.992642] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3609.993400] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3609.993997] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3609.994614] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.995379] ? __schedule (kernel/sched/core.c:2806)
[ 3609.995959] ? worker_thread (kernel/workqueue.c:2203)
[ 3609.996629] kthread (kernel/kthread.c:207)
[ 3609.997200] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.997894] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3609.998576] ? flush_kthread_work (kernel/kthread.c:176)
[ 3609.999312] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3609.999858] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.000538] user_dlm        S ffff8802ccae7c28 29840  4144      2 0x10000000
[ 3610.001344]  ffff8802ccae7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.002288]  ffff8802f73e0558 ffff8802f73e0530 ffff8802ccad3008 ffff880518df8000
[ 3610.003506]  ffff8802ccad3000 ffff8802ccae7c08 ffff8802ccae0000 ffffed005995c002
[ 3610.004288] Call Trace:
[ 3610.004592] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.005252] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.005786] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.006411] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.007352] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.008127] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.008864] ? __schedule (kernel/sched/core.c:2806)
[ 3610.009490] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.010067] kthread (kernel/kthread.c:207)
[ 3610.010605] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.011270] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.011869] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.012678] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.013489] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.014079] glock_workqueue S ffff8802ccaffc28 29840  4151      2 0x10000000
[ 3610.014824]  ffff8802ccaffc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.015766]  ffff8802f73e0558 ffff8802f73e0530 ffff8802ccaf0008 ffff880518df8000
[ 3610.016682]  ffff8802ccaf0000 ffff8802ccaffc08 ffff8802ccaf8000 ffffed005995f002
[ 3610.017601] Call Trace:
[ 3610.017859] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.018606] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.019094] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.019626] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.020211] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.020929] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.021561] ? __schedule (kernel/sched/core.c:2806)
[ 3610.022559] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.023382] kthread (kernel/kthread.c:207)
[ 3610.023852] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.024494] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.025208] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.025918] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.026477] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.027169] delete_workqueu S ffff8802ccb07c28 29840  4152      2 0x10000000
[ 3610.028028]  ffff8802ccb07c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.028918]  ffff8802f73e0558 ffff8802f73e0530 ffff8802ccaf3008 ffff880518df8000
[ 3610.029669]  ffff8802ccaf3000 ffff8802ccb07c08 ffff8802ccb00000 ffffed0059960002
[ 3610.030608] Call Trace:
[ 3610.030881] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.031542] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.032217] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.033221] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.033817] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.034445] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.035066] ? __schedule (kernel/sched/core.c:2806)
[ 3610.035639] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.036316] kthread (kernel/kthread.c:207)
[ 3610.036871] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.037559] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.038196] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.038841] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.039344] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.039920] gfs_recovery    S ffff8802ccb17c28 28920  4160      2 0x10000000
[ 3610.040713]  ffff8802ccb17c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.041535]  ffff8802f73e0558 ffff8802f73e0530 ffff8802ccb08008 ffff880518df8000
[ 3610.042590]  ffff8802ccb08000 ffff8802ccb17c08 ffff8802ccb10000 ffffed0059962002
[ 3610.043493] Call Trace:
[ 3610.043735] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.044339] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.044824] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.045602] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.046220] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.046866] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.047433] ? __schedule (kernel/sched/core.c:2806)
[ 3610.048142] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.048753] kthread (kernel/kthread.c:207)
[ 3610.049239] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.049830] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.050481] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.051118] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.051723] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.052401] kworker/16:1    S ffff8802f6a7fce8 27832  4168      2 0x10000000
[ 3610.053255]  ffff8802f6a7fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.054315]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6a70008 ffff8802cc1c0000
[ 3610.055213]  ffff8802f6a70000 ffff8802f6a7fcc8 ffff8802f6a78000 ffffed005ed4f002
[ 3610.056107] Call Trace:
[ 3610.056348] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.057029] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.057533] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.058152] ? __schedule (kernel/sched/core.c:2806)
[ 3610.058731] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.059309] kthread (kernel/kthread.c:207)
[ 3610.059788] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.060428] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.061003] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.061608] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.062234] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.063283] pencrypt        S ffff8802f6aafc28 29304  4200      2 0x10000000
[ 3610.064685]  ffff8802f6aafc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.065728]  ffff8803211e0558 ffff8803211e0530 ffff8802f6a73008 ffff88060d230000
[ 3610.066648]  ffff8802f6a73000 ffff8802f6aafc08 ffff8802f6aa8000 ffffed005ed55002
[ 3610.067542] Call Trace:
[ 3610.067852] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.068575] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.069052] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.069623] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.070253] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.070890] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.071465] ? __schedule (kernel/sched/core.c:2806)
[ 3610.072181] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.072957] kthread (kernel/kthread.c:207)
[ 3610.073597] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.074404] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.075093] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.075864] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.076517] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.077184] pdecrypt        S ffff8802f6b67c28 29840  4202      2 0x10000000
[ 3610.078033]  ffff8802f6b67c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.078912]  ffff8800261e0558 ffff8800261e0530 ffff8802f6aa3008 ffffffffb4839100
[ 3610.079676]  ffff8802f6aa3000 ffff8802f6b67c08 ffff8802f6b60000 ffffed005ed6c002
[ 3610.080482] Call Trace:
[ 3610.080742] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.081307] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.081799] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.082771] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.083577] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.084236] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.084804] ? __schedule (kernel/sched/core.c:2806)
[ 3610.085405] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.086077] kthread (kernel/kthread.c:207)
[ 3610.086591] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.087406] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.088106] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.088729] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.089238] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.089815] kthrotld        S ffff8802f6affc28 29840  4260      2 0x10000000
[ 3610.090675]  ffff8802f6affc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.091464]  ffff8803211e0558 ffff8803211e0530 ffff8802f6aa0008 ffff88060d230000
[ 3610.092343]  ffff8802f6aa0000 ffff8802f6affc08 ffff8802f6af8000 ffffed005ed5f002
[ 3610.093280] Call Trace:
[ 3610.093719] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.094628] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.095260] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.095890] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.096659] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.097399] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.098210] ? __schedule (kernel/sched/core.c:2806)
[ 3610.098828] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.099368] kthread (kernel/kthread.c:207)
[ 3610.099853] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.100594] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.101195] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.101974] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.103027] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.103823] kworker/17:1    S ffff880320ab7ce8 27832  4265      2 0x10000000
[ 3610.104671]  ffff880320ab7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.105597]  ffff8803211e0558 ffff8803211e0530 ffff880320aa8008 ffff88060d230000
[ 3610.106534]  ffff880320aa8000 ffff880320ab7cc8 ffff880320ab0000 ffffed0064156002
[ 3610.107555] Call Trace:
[ 3610.107827] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.108575] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.109083] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.109634] ? __schedule (kernel/sched/core.c:2806)
[ 3610.110207] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.110803] kthread (kernel/kthread.c:207)
[ 3610.111295] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.112020] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.112896] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.114028] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.114559] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.115319] vballoon        S ffff880320ad7988 29504  4409      2 0x10000000
[ 3610.116672]  ffff880320ad7988 ffff880320aab000 ffffffffb5930a40 ffff880300000000
[ 3610.117686]  ffff8800261e0558 ffff8800261e0530 ffff880320aab008 ffffffffb4839100
[ 3610.118520]  ffff880320aab000 ffff880320ad7b08 ffff880320ad0000 ffffed006415a002
[ 3610.119445] Call Trace:
[ 3610.119708] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.120222] schedule_timeout (kernel/time/timer.c:1475)
[ 3610.120812] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3610.121482] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3610.122124] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3610.123247] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3610.124156] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3610.124904] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.126809] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.127741] wait_woken (kernel/sched/wait.c:335)
[ 3610.128592] ? woken_wake_function (kernel/sched/wait.c:327)
[ 3610.129492] ? vp_get (drivers/virtio/virtio_pci_modern.c:165)
[ 3610.130244] balloon (drivers/virtio/virtio_balloon.c:354)
[ 3610.131024] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.131983] ? virtballoon_probe (drivers/virtio/virtio_balloon.c:336)
[ 3610.133636] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.134875] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.136265] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.137218] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.138414] ? wake_atomic_t_function (kernel/sched/wait.c:351)
[ 3610.139347] ? __schedule (kernel/sched/core.c:2806)
[ 3610.140157] ? virtballoon_probe (drivers/virtio/virtio_balloon.c:336)
[ 3610.141120] kthread (kernel/kthread.c:207)
[ 3610.141880] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.142865] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.143801] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.144783] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.145975] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.146945] kworker/5:1     S ffff880128abfce8 27584  4675      2 0x10000000
[ 3610.148262]  ffff880128abfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.149517]  ffff8801291e0558 ffff8801291e0530 ffff880128ab0008 ffff88065d1d8000
[ 3610.150760]  ffff880128ab0000 ffff880128abfcc8 ffff880128ab8000 ffffed0025157002
[ 3610.151938] Call Trace:
[ 3610.152427] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.154292] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.155368] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.156727] ? __schedule (kernel/sched/core.c:2806)
[ 3610.157736] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.158755] kthread (kernel/kthread.c:207)
[ 3610.159497] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.160445] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.161540] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.162717] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.163578] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.164487] kworker/14:1    S ffff8802a2abfce8 27832  4676      2 0x10000000
[ 3610.165873]  ffff8802a2abfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.167648]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2ab0008 ffff8802a202b000
[ 3610.169139]  ffff8802a2ab0000 ffff8802a2abfcc8 ffff8802a2ab8000 ffffed0054557002
[ 3610.170522] Call Trace:
[ 3610.170950] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.171829] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.172672] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.173527] ? __schedule (kernel/sched/core.c:2806)
[ 3610.174405] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.176063] kthread (kernel/kthread.c:207)
[ 3610.177590] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.179338] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.180271] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.181276] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.182122] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.183899] hwrng           S ffff880128affca8 28424  5248      2 0x10000000
[ 3610.186009]  ffff880128affca8 ffff880128affc68 0000000000000286 0000000000000000
[ 3610.187333]  ffff8800533e0558 ffff8800533e0530 ffff880128ab3008 ffff8801d0dd0000
[ 3610.188559]  ffff880128ab3000 ffffffffb24e3520 ffff880128af8000 ffffed002515f002
[ 3610.189747] Call Trace:
[ 3610.190128] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.190978] add_hwgenerator_randomness (drivers/char/random.c:1778 (discriminator 17))
[ 3610.191950] ? random_write (drivers/char/random.c:1771)
[ 3610.192765] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3610.193974] ? rng_dev_read (drivers/char/hw_random/core.c:414)
[ 3610.194834] hwrng_fillfn (drivers/char/hw_random/core.c:417)
[ 3610.195764] kthread (kernel/kthread.c:207)
[ 3610.196530] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.197562] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.198494] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.199405] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.200189] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.201143] kfd_process_wq  S ffff880128b0fc28 29840  5275      2 0x10000000
[ 3610.202293]  ffff880128b0fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.203535]  ffff8801533e0558 ffff8801533e0530 ffff880128b00008 ffff88079d1e8000
[ 3610.204742]  ffff880128b00000 ffff880128b0fc08 ffff880128b08000 ffffed0025161002
[ 3610.206046] Call Trace:
[ 3610.206434] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.207333] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.208081] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.208913] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.209827] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.210714] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.211560] ? __schedule (kernel/sched/core.c:2806)
[ 3610.212399] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.213257] kthread (kernel/kthread.c:207)
[ 3610.214049] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.215092] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.216168] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.217120] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.217956] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.218882] kworker/u49:1   S ffff88002231fce8 28904  5290      2 0x10000000
[ 3610.219999]  ffff88002231fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.221245]  ffff8800261e0558 ffff8800261e0530 ffff880022320008 ffff8802f5c33000
[ 3610.222551]  ffff880022320000 ffff88002231fcc8 ffff880022318000 ffffed0004463002
[ 3610.223740] Call Trace:
[ 3610.224118] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.225053] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.225842] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.226670] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.227569] kthread (kernel/kthread.c:207)
[ 3610.228412] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.229332] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.230245] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.231308] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.232237] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.233412] kworker/u67:0   S ffff880128b47ce8 30368  5326      2 0x10000000
[ 3610.234593]  ffff880128b47ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.235978]  ffff8801533e0558 ffff8801533e0530 ffff880128b03008 ffff880152033000
[ 3610.237424]  ffff880128b03000 ffff880128b47cc8 ffff880128b40000 ffffed0025168002
[ 3610.238701] Call Trace:
[ 3610.239082] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.239924] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.240922] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.241803] ? __schedule (kernel/sched/core.c:2806)
[ 3610.243450] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.245047] kthread (kernel/kthread.c:207)
[ 3610.247022] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.248962] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.249936] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.251076] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.252108] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.254042] kworker/u68:0   S ffff880021c67ce8 26624  5327      2 0x10000000
[ 3610.256542]  ffff880021c67ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.258712]  ffff8800261e0558 ffff8800261e0530 ffff880022323008 ffff8802a1cab000
[ 3610.260067]  ffff880022323000 ffff880021c67cc8 ffff880021c60000 ffffed000438c002
[ 3610.261394] Call Trace:
[ 3610.261840] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.262879] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.263956] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.265399] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.266804] kthread (kernel/kthread.c:207)
[ 3610.268198] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.269215] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.270175] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.271313] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.272309] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.274647] kworker/u69:0   S ffff880052147ce8 26472  5328      2 0x10000000
[ 3610.276569]  ffff880052147ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.278798]  ffff8800533e0558 ffff8800533e0530 ffff880052198008 ffff88024dcb8000
[ 3610.280195]  ffff880052198000 ffff880052147cc8 ffff880052140000 ffffed000a428002
[ 3610.281666] Call Trace:
[ 3610.282213] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.283755] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.284548] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.286104] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.288106] kthread (kernel/kthread.c:207)
[ 3610.289124] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.290177] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.291121] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.292098] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.293115] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.294241] kworker/u70:0   S ffff88007c7a7ce8 27128  5329      2 0x10000000
[ 3610.296330]  ffff88007c7a7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.298174]  ffff88007d3e0558 ffff88007d3e0530 ffff88007c46b008 ffff8802ccdd8000
[ 3610.299541]  ffff88007c46b000 ffff88007c7a7cc8 ffff88007c7a0000 ffffed000f8f4002
[ 3610.300779] Call Trace:
[ 3610.301198] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.302602] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.303593] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.304501] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.306738] kthread (kernel/kthread.c:207)
[ 3610.308064] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.309380] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.310310] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.311684] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.313215] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.314603] kworker/u71:0   S ffff8800a6b6fce8 26640  5330      2 0x10000000
[ 3610.316598]  ffff8800a6b6fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.318516]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a6b60008 ffff8802a202b000
[ 3610.320135]  ffff8800a6b60000 ffff8800a6b6fcc8 ffff8800a6b68000 ffffed0014d6d002
[ 3610.321669] Call Trace:
[ 3610.322309] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.323475] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.324212] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.325958] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.327521] kthread (kernel/kthread.c:207)
[ 3610.328641] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.329567] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.330499] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.331782] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.332780] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.333653] kworker/u72:0   S ffff8800ca7cfce8 26472  5331      2 0x10000000
[ 3610.334778]  ffff8800ca7cfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.336667]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800ca563008 ffff8802a1cab000
[ 3610.338659]  ffff8800ca563000 ffff8800ca7cfcc8 ffff8800ca7c8000 ffffed00194f9002
[ 3610.340044] Call Trace:
[ 3610.340465] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.341483] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.342292] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.343775] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.345238] kthread (kernel/kthread.c:207)
[ 3610.346497] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.347755] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.349090] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.350025] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.350883] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.351972] kworker/u73:0   S ffff880128b57ce8 25384  5332      2 0x10000000
[ 3610.353691]  ffff880128b57ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.355160]  ffff8801291e0558 ffff8801291e0530 ffff880128b48008 ffff88065d1d8000
[ 3610.356802]  ffff880128b48000 ffff880128b57cc8 ffff880128b50000 ffffed002516a002
[ 3610.358149] Call Trace:
[ 3610.358544] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.359397] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.360130] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.361009] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.361934] kthread (kernel/kthread.c:207)
[ 3610.362998] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.364390] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.365570] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.366497] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.367457] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.368461] kworker/u74:0   S ffff880152027ce8 25384  5333      2 0x10000000
[ 3610.369594]  ffff880152027ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.370831]  ffff8801533e0558 ffff8801533e0530 ffff880152033008 ffff88079d1e8000
[ 3610.372166]  ffff880152033000 ffff880152027cc8 ffff880152020000 ffffed002a404002
[ 3610.374013] Call Trace:
[ 3610.374432] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.375777] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.377616] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.379172] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.380105] kthread (kernel/kthread.c:207)
[ 3610.381059] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.382138] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.383441] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.384375] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.385474] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.386802] kworker/u75:0   S ffff88017c8afce8 26640  5334      2 0x10000000
[ 3610.388338]  ffff88017c8afce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.389935]  ffff88017d3e0558 ffff88017d3e0530 ffff88017c8d8008 ffff8808dd1e0000
[ 3610.391241]  ffff88017c8d8000 ffff88017c8afcc8 ffff88017c8a8000 ffffed002f915002
[ 3610.392860] Call Trace:
[ 3610.393568] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.394676] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.395810] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.397261] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.398673] kthread (kernel/kthread.c:207)
[ 3610.399482] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.400415] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.401897] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.403259] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.403992] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.404822] kworker/u76:0   S ffff8801a6b57ce8 30368  5335      2 0x10000000
[ 3610.406999]  ffff8801a6b57ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.408675]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a685b008 ffff8800256f8000
[ 3610.409997]  ffff8801a685b000 ffff8801a6b57cc8 ffff8801a6b50000 ffffed0034d6a002
[ 3610.411464] Call Trace:
[ 3610.412170] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.413551] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.414430] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.415649] ? __schedule (kernel/sched/core.c:2806)
[ 3610.417175] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.418779] kthread (kernel/kthread.c:207)
[ 3610.419678] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.420688] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.421719] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.423475] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.424816] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.426672] kworker/u77:0   S ffff8801d0af7ce8 26640  5336      2 0x10000000
[ 3610.428441]  ffff8801d0af7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.429793]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0ae8008 ffff8801d0268000
[ 3610.431196]  ffff8801d0ae8000 ffff8801d0af7cc8 ffff8801d0af0000 ffffed003a15e002
[ 3610.432928] Call Trace:
[ 3610.433499] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.434859] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.436195] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.437306] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.438592] kthread (kernel/kthread.c:207)
[ 3610.439492] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.440440] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.441574] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.443205] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.444314] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.445772] kworker/u78:0   S ffff8801fa057ce8 26640  5337      2 0x10000000
[ 3610.447338]  ffff8801fa057ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.448950]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fa7fb008 ffff880021778000
[ 3610.450187]  ffff8801fa7fb000 ffff8801fa057cc8 ffff8801fa050000 ffffed003f40a002
[ 3610.451635] Call Trace:
[ 3610.452252] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.453436] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.454602] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.455894] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.456820] kthread (kernel/kthread.c:207)
[ 3610.457744] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.458735] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.459642] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.460612] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.461477] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.462859] kworker/u79:0   S ffff880224af7ce8 28384  5338      2 0x10000000
[ 3610.464450]  ffff880224af7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.465802]  ffff8802253e0558 ffff8802253e0530 ffff880224ae8008 ffff8800a6dd0000
[ 3610.467016]  ffff880224ae8000 ffff880224af7cc8 ffff880224af0000 ffffed004495e002
[ 3610.468298] Call Trace:
[ 3610.468695] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.469557] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.470338] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.471288] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.472342] kthread (kernel/kthread.c:207)
[ 3610.473197] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.474135] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.475171] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.476501] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.477342] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.478381] kworker/u80:0   S ffff88024e76fce8 26296  5339      2 0x10000000
[ 3610.479512]  ffff88024e76fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.480792]  ffff88024f3e0558 ffff88024f3e0530 ffff88024e4e3008 ffff8800c9c1b000
[ 3610.482329]  ffff88024e4e3000 ffff88024e76fcc8 ffff88024e768000 ffffed0049ced002
[ 3610.483842] Call Trace:
[ 3610.484247] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.485287] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.486474] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.487313] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.488326] kthread (kernel/kthread.c:207)
[ 3610.489075] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.489985] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.491109] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.492130] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.493469] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.494405] kworker/u81:0   S ffff880278b7fce8 26640  5340      2 0x10000000
[ 3610.496214]  ffff880278b7fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.497468]  ffff8802791e0558 ffff8802791e0530 ffff880278873008 ffff880278870000
[ 3610.498895]  ffff880278873000 ffff880278b7fcc8 ffff880278b78000 ffffed004f16f002
[ 3610.500101] Call Trace:
[ 3610.500527] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.501461] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.502501] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.503522] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.504486] kthread (kernel/kthread.c:207)
[ 3610.505521] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.506553] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.507546] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.508537] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.509322] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.510226] kworker/u82:0   S ffff8802a2af7ce8 26472  5341      2 0x10000000
[ 3610.511028]  ffff8802a2af7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.511798]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2ab3008 ffff8802ccde0000
[ 3610.512823]  ffff8802a2ab3000 ffff8802a2af7cc8 ffff8802a2af0000 ffffed005455e002
[ 3610.514518] Call Trace:
[ 3610.514928] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.515991] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.516768] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.517684] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.518671] kthread (kernel/kthread.c:207)
[ 3610.519399] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.520341] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.521525] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.522757] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.524045] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.525399] kworker/u83:0   S ffff8802ccbafce8 25384  5342      2 0x10000000
[ 3610.527122]  ffff8802ccbafce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.528452]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802ccb0b008 ffff8803c8df0000
[ 3610.529614]  ffff8802ccb0b000 ffff8802ccbafcc8 ffff8802ccba8000 ffffed0059975002
[ 3610.530808] Call Trace:
[ 3610.531339] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.532350] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.533212] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.534033] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.535159] kthread (kernel/kthread.c:207)
[ 3610.536506] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.537668] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.538735] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.539620] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.540451] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.541656] kworker/u84:0   S ffff8802f6b37ce8 30368  5343      2 0x10000000
[ 3610.543449]  ffff8802f6b37ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.545187]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6ab8008 ffff880518df8000
[ 3610.546798]  ffff8802f6ab8000 ffff8802f6b37cc8 ffff8802f6b30000 ffffed005ed66002
[ 3610.548345] Call Trace:
[ 3610.548746] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.549576] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.550342] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.551345] ? __schedule (kernel/sched/core.c:2806)
[ 3610.552427] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.554092] kthread (kernel/kthread.c:207)
[ 3610.554964] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.556250] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.557316] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.558434] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.559215] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.560140] kworker/u85:0   S ffff880320b6fce8 26640  5344      2 0x10000000
[ 3610.561307]  ffff880320b6fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3610.562778]  ffff8803211e0558 ffff8803211e0530 ffff880320b60008 ffff8801fa268000
[ 3610.564421]  ffff880320b60000 ffff880320b6fcc8 ffff880320b68000 ffffed006416d002
[ 3610.566222] Call Trace:
[ 3610.566590] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3610.567704] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.568585] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3610.569395] ? process_one_work (kernel/workqueue.c:2101)
[ 3610.570353] kthread (kernel/kthread.c:207)
[ 3610.571123] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.572612] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.574011] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.575142] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.576375] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.577682] kloopd          S ffff880128b77c28 29840  5345      2 0x10000000
[ 3610.578951]  ffff880128b77c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.580082]  ffff8801533e0558 ffff8801533e0530 ffff880128b4b008 ffff88079d1e8000
[ 3610.581622]  ffff880128b4b000 ffff880128b77c08 ffff880128b70000 ffffed002516e002
[ 3610.583065] Call Trace:
[ 3610.584226] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.585024] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.586501] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.587371] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.588568] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.589547] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.590413] ? __schedule (kernel/sched/core.c:2806)
[ 3610.591544] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.592662] kthread (kernel/kthread.c:207)
[ 3610.594323] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.596118] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.597789] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.599154] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.599953] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.601057] cciss_scan      S ffff880128ba7ce8 29112  5476      2 0x10000000
[ 3610.602621]  ffff880128ba7ce8 ffff880128ba7c88 ffffffffa8fc3653 ffff880100000000
[ 3610.604557]  ffff8801533e0558 ffff8801533e0530 ffff880128b98008 ffff88079d1e8000
[ 3610.606600]  ffff880128b98000 ffff880128ba7cd8 ffff880128ba0000 ffffed0025174002
[ 3610.608403] Call Trace:
[ 3610.608837] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.609850] ? rebuild_lun_table (drivers/block/cciss.c:3726)
[ 3610.610905] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.611689] scan_thread (drivers/block/cciss.c:3732 (discriminator 1))
[ 3610.612972] ? rebuild_lun_table (drivers/block/cciss.c:3726)
[ 3610.614214] ? rebuild_lun_table (drivers/block/cciss.c:3726)
[ 3610.615802] ? rebuild_lun_table (drivers/block/cciss.c:3726)
[ 3610.616971] kthread (kernel/kthread.c:207)
[ 3610.618015] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.618966] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.619863] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.620991] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.621802] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.623506] nvme            S ffff880128bafc28 29840  5482      2 0x10000000
[ 3610.625070]  ffff880128bafc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.626909]  ffff8801533e0558 ffff8801533e0530 ffff880128b9b008 ffff88079d1e8000
[ 3610.628552]  ffff880128b9b000 ffff880128bafc08 ffff880128ba8000 ffffed0025175002
[ 3610.629705] Call Trace:
[ 3610.630079] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.631003] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.631909] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.633292] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.634524] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.635820] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.636971] ? __schedule (kernel/sched/core.c:2806)
[ 3610.637928] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.638756] kthread (kernel/kthread.c:207)
[ 3610.639481] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.640422] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.641375] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.642786] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.643793] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.644916] bioset          S ffff880128bb7c28 29840  5528      2 0x10000000
[ 3610.646284]  ffff880128bb7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.647475]  ffff8801533e0558 ffff8801533e0530 ffff880128a68008 ffff88079d1e8000
[ 3610.648610]  ffff880128a68000 ffff880128bb7c08 ffff880128bb0000 ffffed0025176002
[ 3610.649759] Call Trace:
[ 3610.650127] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.651046] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.651797] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.653052] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.653995] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.654943] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.656107] ? __schedule (kernel/sched/core.c:2806)
[ 3610.657024] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.657891] kthread (kernel/kthread.c:207)
[ 3610.658687] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.659571] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.660503] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.661557] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.662734] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.663962] drbd-reissue    S ffff880128057c28 29840  5530      2 0x10000000
[ 3610.665499]  ffff880128057c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.667532]  ffff8801533e0558 ffff8801533e0530 ffff880128a6b008 ffff88079d1e8000
[ 3610.669015]  ffff880128a6b000 ffff880128057c08 ffff880128050000 ffffed002500a002
[ 3610.670195] Call Trace:
[ 3610.670603] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.671672] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.673061] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.674715] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.676748] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.678538] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.679139] ? __schedule (kernel/sched/core.c:2806)
[ 3610.679711] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.680274] kthread (kernel/kthread.c:207)
[ 3610.680884] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.681569] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.682649] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.683828] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.684398] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.685885] rbd             S ffff880128067c28 29840  5534      2 0x10000000
[ 3610.687404]  ffff880128067c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.688648]  ffff8801533e0558 ffff8801533e0530 ffff880128058008 ffff88079d1e8000
[ 3610.689610]  ffff880128058000 ffff880128067c08 ffff880128060000 ffffed002500c002
[ 3610.690513] Call Trace:
[ 3610.690901] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.691974] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.692533] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.693278] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.693901] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.694666] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.695365] ? __schedule (kernel/sched/core.c:2806)
[ 3610.695936] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.696631] kthread (kernel/kthread.c:207)
[ 3610.697762] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.698539] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.699138] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.699740] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.700310] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.700946] iscsi_eh        S ffff88012809fc28 28920  5669      2 0x10000000
[ 3610.702283]  ffff88012809fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.704464]  ffff8800261e0558 ffff8800261e0530 ffff88012805b008 ffffffffb4839100
[ 3610.706424]  ffff88012805b000 ffff88012809fc08 ffff880128098000 ffffed0025013002
[ 3610.707747] Call Trace:
[ 3610.708246] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.709081] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.709818] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.710665] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.711691] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.712952] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.714269] ? __schedule (kernel/sched/core.c:2806)
[ 3610.715407] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.716372] kthread (kernel/kthread.c:207)
[ 3610.717231] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.718389] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.719266] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.720169] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.721031] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.722404] kmpath_rdacd    S ffff8801280b7c28 29840  5679      2 0x10000000
[ 3610.723897]  ffff8801280b7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.725665]  ffff8801533e0558 ffff8801533e0530 ffff8801280a8008 ffff88079d1e8000
[ 3610.727232]  ffff8801280a8000 ffff8801280b7c08 ffff8801280b0000 ffffed0025016002
[ 3610.728469] Call Trace:
[ 3610.728829] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.729674] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.730440] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.731387] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.732442] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.733487] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.734404] ? __schedule (kernel/sched/core.c:2806)
[ 3610.735535] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.736603] kthread (kernel/kthread.c:207)
[ 3610.737593] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.738575] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.739454] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.740363] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.741383] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.742553] fc_exch_workque S ffff8801280bfc28 29840  5682      2 0x10000000
[ 3610.744157]  ffff8801280bfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.745794]  ffff8801533e0558 ffff8801533e0530 ffff8801280ab008 ffff88079d1e8000
[ 3610.747792]  ffff8801280ab000 ffff8801280bfc08 ffff8801280b8000 ffffed0025017002
[ 3610.749087] Call Trace:
[ 3610.749460] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.750322] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.751144] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.752306] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.753659] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.755439] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.756400] ? __schedule (kernel/sched/core.c:2806)
[ 3610.757391] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.758352] kthread (kernel/kthread.c:207)
[ 3610.759083] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.759977] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.760959] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.761972] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.763127] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.764102] fc_rport_eq     S ffff8801280cfc28 29840  5683      2 0x10000000
[ 3610.765702]  ffff8801280cfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3610.766998]  ffff8801533e0558 ffff8801533e0530 ffff8800001c3008 ffff88079d1e8000
[ 3610.768226]  ffff8800001c3000 ffff8801280cfc08 ffff8801280c8000 ffffed0025019002
[ 3610.769376] Call Trace:
[ 3610.769743] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3610.770646] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.771412] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3610.772626] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.773791] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.774907] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.775895] ? __schedule (kernel/sched/core.c:2806)
[ 3610.776904] ? worker_thread (kernel/workqueue.c:2203)
[ 3610.777866] kthread (kernel/kthread.c:207)
[ 3610.778720] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.779591] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.780516] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.781739] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.782858] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.783892] fcoethread/0    S ffff880000c67b78 29664  5684      2 0x10000000
[ 3610.785624]  ffff880000c67b78 0000000000000013 ffff8800001c0000 ffff880000000000
[ 3610.787160]  ffff8800261e0558 ffff8800261e0530 ffff8800001c0008 ffffffffb4839100
[ 3610.788456]  ffff8800001c0000 0000000000000201 ffff880000c60000 ffffed000018c002
[ 3610.789607] Call Trace:
[ 3610.790335] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.791100] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.792295] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.793383] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.794239] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.795380] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.796363] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.797310] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.798378] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.799261] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.800184] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.801145] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.802189] kthread (kernel/kthread.c:207)
[ 3610.803228] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.804112] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.805106] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.806020] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.806591] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.807287] fcoethread/1    S ffff88005221fb78 28744  5685      2 0x10000000
[ 3610.808041]  ffff88005221fb78 0000000000000013 ffff880052a9b000 ffff880000000000
[ 3610.808843]  ffff8800533e0558 ffff8800533e0530 ffff880052a9b008 ffff8801d0dd0000
[ 3610.809598]  ffff880052a9b000 0000000000000201 ffff880052218000 ffffed000a443002
[ 3610.810508] Call Trace:
[ 3610.810770] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.811259] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.812024] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.812647] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.813245] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.813840] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.814620] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.815365] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.816014] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.816640] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.817413] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.818072] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.818746] kthread (kernel/kthread.c:207)
[ 3610.819221] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.819841] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.820462] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.821059] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.821630] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.822464] fcoethread/2    S ffff88007bf97b78 29664  5686      2 0x10000000
[ 3610.823408]  ffff88007bf97b78 0000000000000013 ffff88007bf88000 ffff880000000000
[ 3610.824581]  ffff88007d3e0558 ffff88007d3e0530 ffff88007bf88008 ffff8802ccdd8000
[ 3610.825606]  ffff88007bf88000 0000000000000201 ffff88007bf90000 ffffed000f7f2002
[ 3610.826381] Call Trace:
[ 3610.826627] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.827165] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.827826] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.828536] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.829102] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.829725] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.830452] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.831070] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.831699] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.832666] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.833517] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.834298] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.835383] kthread (kernel/kthread.c:207)
[ 3610.836075] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.836738] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.837351] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.837956] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.838467] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.839040] fcoethread/3    S ffff8800a60afb78 28744  5687      2 0x10000000
[ 3610.839740]  ffff8800a60afb78 0000000000000013 ffff8800a6b63000 ffff880000000000
[ 3610.840606]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a6b63008 ffff8803c8de8000
[ 3610.841391]  ffff8800a6b63000 0000000000000201 ffff8800a60a8000 ffffed0014c15002
[ 3610.842373] Call Trace:
[ 3610.842614] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.843119] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.843873] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.844776] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.845512] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.846111] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.846729] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.847360] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.848011] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.848583] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.849155] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.849772] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.850429] kthread (kernel/kthread.c:207)
[ 3610.850922] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.851514] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.852257] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.852922] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.853719] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.854457] fcoethread/4    S ffff8800ca0d7b78 29664  5688      2 0x10000000
[ 3610.855362]  ffff8800ca0d7b78 0000000000000013 ffff8800ca0c8000 ffff880000000000
[ 3610.856135]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800ca0c8008 ffff880518df0000
[ 3610.856969]  ffff8800ca0c8000 0000000000000201 ffff8800ca0d0000 ffffed001941a002
[ 3610.857763] Call Trace:
[ 3610.858119] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.858613] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.859276] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.859898] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.860476] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.861098] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.862131] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.863238] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.864347] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.865637] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.866741] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.867689] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.868699] kthread (kernel/kthread.c:207)
[ 3610.869428] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.870376] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.871287] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.872357] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.873371] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.874468] fcoethread/5    S ffff8801280efb78 29664  5689      2 0x10000000
[ 3610.875963]  ffff8801280efb78 0000000000000013 ffff8801280e0000 ffff880100000000
[ 3610.877296]  ffff8801291e0558 ffff8801291e0530 ffff8801280e0008 ffff88065d1d8000
[ 3610.878611]  ffff8801280e0000 0000000000000201 ffff8801280e8000 ffffed002501d002
[ 3610.879805] Call Trace:
[ 3610.880203] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.881086] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.882539] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.883583] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.884586] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.886068] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.887255] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.888304] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.889267] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.890260] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.891199] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.892515] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.893546] kthread (kernel/kthread.c:207)
[ 3610.894405] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.895710] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.896624] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.897882] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.898683] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.899564] fcoethread/6    S ffff88015204fb78 29304  5690      2 0x10000000
[ 3610.900775]  ffff88015204fb78 0000000000000013 ffff88015292b000 ffff880100000000
[ 3610.902316]  ffff8801533e0558 ffff8801533e0530 ffff88015292b008 ffff88079d1e8000
[ 3610.903625]  ffff88015292b000 0000000000000201 ffff880152048000 ffffed002a409002
[ 3610.905292] Call Trace:
[ 3610.906008] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.906914] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.908086] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.909069] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.909893] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.910821] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.912086] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.913316] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.914594] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.915761] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.916851] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.917935] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.918958] kthread (kernel/kthread.c:207)
[ 3610.919675] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.920633] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.921702] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.923001] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.924198] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.925777] fcoethread/7    S ffff88017c027b78 29664  5691      2 0x10000000
[ 3610.927418]  ffff88017c027b78 0000000000000013 ffff88017cfbb000 ffff880100000000
[ 3610.928769]  ffff88017d3e0558 ffff88017d3e0530 ffff88017cfbb008 ffff8808dd1e0000
[ 3610.929946]  ffff88017cfbb000 0000000000000201 ffff88017c020000 ffffed002f804002
[ 3610.931112] Call Trace:
[ 3610.931574] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.932783] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.933854] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.935666] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.936905] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.937972] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.939157] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.940159] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.941244] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.942409] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.943877] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.945553] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.946831] kthread (kernel/kthread.c:207)
[ 3610.947640] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.948586] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.949499] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.950534] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.951340] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.952590] fcoethread/8    S ffff8801a6067b78 29664  5692      2 0x10000000
[ 3610.954073]  ffff8801a6067b78 0000000000000013 ffff8801a6058000 ffff880100000000
[ 3610.956123]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6058008 ffff8800256f8000
[ 3610.957519]  ffff8801a6058000 0000000000000201 ffff8801a6060000 ffffed0034c0c002
[ 3610.958781] Call Trace:
[ 3610.959150] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.959940] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.960980] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.962091] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.963667] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.965682] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.967418] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.968741] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.969718] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.970676] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.971964] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3610.973138] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.974591] kthread (kernel/kthread.c:207)
[ 3610.975794] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.976724] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.977730] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.978763] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3610.979535] ? flush_kthread_work (kernel/kthread.c:176)
[ 3610.980470] fcoethread/9    S ffff8801d0bf7b78 29664  5693      2 0x10000000
[ 3610.981551]  ffff8801d0bf7b78 0000000000000013 ffff8801d0aeb000 ffff880100000000
[ 3610.983581]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0aeb008 ffff8800256fb000
[ 3610.985070]  ffff8801d0aeb000 0000000000000201 ffff8801d0bf0000 ffffed003a17e002
[ 3610.986931] Call Trace:
[ 3610.987402] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3610.988146] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3610.989147] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3610.990091] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3610.991039] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3610.992111] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3610.993797] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3610.996772] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3610.998186] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3610.999076] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.000057] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.001286] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.002510] kthread (kernel/kthread.c:207)
[ 3611.003559] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.004849] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.006135] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.007304] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.008319] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.009216] fcoethread/10   S ffff8801fa147b78 29664  5694      2 0x10000000
[ 3611.010656]  ffff8801fa147b78 0000000000000013 ffff8801fa7f8000 ffff880100000000
[ 3611.012083]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fa7f8008 ffff880052dc8000
[ 3611.013641]  ffff8801fa7f8000 0000000000000201 ffff8801fa140000 ffffed003f428002
[ 3611.015217] Call Trace:
[ 3611.016074] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.017619] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3611.019219] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3611.020131] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3611.021096] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.022463] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.023876] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.025407] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.026719] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.028045] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.028960] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.029853] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.030882] kthread (kernel/kthread.c:207)
[ 3611.031735] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.033100] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.034363] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.035949] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.036919] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.038614] fcoethread/11   S ffff880224007b78 29664  5695      2 0x10000000
[ 3611.039784]  ffff880224007b78 0000000000000013 ffff880224aeb000 ffff880200000000
[ 3611.041126]  ffff8802253e0558 ffff8802253e0530 ffff880224aeb008 ffff8800a6dd0000
[ 3611.042773]  ffff880224aeb000 0000000000000201 ffff880224000000 ffffed0044800002
[ 3611.044201] Call Trace:
[ 3611.044867] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.046160] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3611.047689] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3611.048790] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3611.049716] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.050785] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.051784] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.053180] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.054311] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.055610] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.057105] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.058643] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.059764] kthread (kernel/kthread.c:207)
[ 3611.060555] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.061702] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.063226] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.064779] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.066163] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.067429] fcoethread/12   S ffff88024e05fb78 29664  5696      2 0x10000000
[ 3611.068717]  ffff88024e05fb78 0000000000000013 ffff88024e050000 ffff880200000000
[ 3611.069896]  ffff88024f3e0558 ffff88024f3e0530 ffff88024e050008 ffff88017cdd0000
[ 3611.071200]  ffff88024e050000 0000000000000201 ffff88024e058000 ffffed0049c0b002
[ 3611.072548] Call Trace:
[ 3611.073017] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.074243] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3611.076575] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3611.078286] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3611.079113] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.080018] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.081121] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.082946] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.085126] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.087292] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.088886] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.089889] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.091033] kthread (kernel/kthread.c:207)
[ 3611.092023] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.093797] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.095679] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.097277] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.098705] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.099605] fcoethread/13   S ffff88027808fb78 29664  5697      2 0x10000000
[ 3611.100859]  ffff88027808fb78 0000000000000013 ffff880278080000 ffff880200000000
[ 3611.102388]  ffff8802791e0558 ffff8802791e0530 ffff880278080008 ffff880224dd0000
[ 3611.104367]  ffff880278080000 0000000000000201 ffff880278088000 ffffed004f011002
[ 3611.107152] Call Trace:
[ 3611.107879] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.109040] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3611.110042] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3611.111183] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3611.112245] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.113645] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.115276] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.116783] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.118830] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.119804] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.120994] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.122076] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.123671] kthread (kernel/kthread.c:207)
[ 3611.124890] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.126255] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.127379] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.128545] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.129349] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.130245] fcoethread/14   S ffff8802a2017b78 29664  5698      2 0x10000000
[ 3611.131461]  ffff8802a2017b78 0000000000000013 ffff8802a2008000 ffff880200000000
[ 3611.133316]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2008008 ffff8802ccde0000
[ 3611.134715]  ffff8802a2008000 0000000000000201 ffff8802a2010000 ffffed0054402002
[ 3611.136629] Call Trace:
[ 3611.137406] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.138795] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3611.139768] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3611.140752] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3611.141644] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.143318] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.144709] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.146351] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.147526] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.148663] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.149554] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.150465] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.151514] kthread (kernel/kthread.c:207)
[ 3611.152681] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.153714] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.154833] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.156232] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.157107] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.158111] fcoethread/15   S ffff8802cc0d7b78 29664  5699      2 0x10000000
[ 3611.159202]  ffff8802cc0d7b78 0000000000000013 ffff8802cc0c8000 ffff880200000000
[ 3611.160360]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cc0c8008 ffff8803c8df0000
[ 3611.161745]  ffff8802cc0c8000 0000000000000201 ffff8802cc0d0000 ffffed005981a002
[ 3611.163432] Call Trace:
[ 3611.163808] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.164951] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3611.166878] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3611.168247] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3611.169123] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.170018] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.171144] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.172232] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.174130] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.176114] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.177958] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.179247] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.180218] kthread (kernel/kthread.c:207)
[ 3611.181076] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.182145] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.183790] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.185510] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.186699] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.187704] fcoethread/16   S ffff8802f607fb78 29664  5700      2 0x10000000
[ 3611.188967]  ffff8802f607fb78 0000000000000013 ffff8802f6abb000 ffff880200000000
[ 3611.190230]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6abb008 ffff880518df8000
[ 3611.191732]  ffff8802f6abb000 0000000000000201 ffff8802f6078000 ffffed005ec0f002
[ 3611.193963] Call Trace:
[ 3611.194640] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.196265] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3611.198783] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3611.199841] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3611.200815] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.202348] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.204238] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.206321] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.208292] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.209477] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.210495] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.211489] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.212854] kthread (kernel/kthread.c:207)
[ 3611.214211] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.216479] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.217806] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.218777] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.219466] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.220105] fcoethread/17   S ffff88032008fb78 29664  5701      2 0x10000000
[ 3611.221614]  ffff88032008fb78 0000000000000013 ffff880320b63000 ffff880300000000
[ 3611.223705]  ffff8803211e0558 ffff8803211e0530 ffff880320b63008 ffff88060d230000
[ 3611.225989]  ffff880320b63000 0000000000000201 ffff880320088000 ffffed0064011002
[ 3611.227483] Call Trace:
[ 3611.228025] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.228841] fcoe_percpu_receive_thread (drivers/scsi/fcoe/fcoe.c:1877)
[ 3611.229828] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3611.230848] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3611.231696] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.233231] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.234421] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.235701] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.236712] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.237886] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.238826] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.239721] ? fcoe_percpu_thread_create (drivers/scsi/fcoe/fcoe.c:1867)
[ 3611.240823] kthread (kernel/kthread.c:207)
[ 3611.241692] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.242780] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.243788] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.245078] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.246570] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.248426] fnic_event_wq   S ffff880128107c28 29840  5706      2 0x10000000
[ 3611.249576]  ffff880128107c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3611.250963]  ffff8801533e0558 ffff8801533e0530 ffff8801280e3008 ffff88079d1e8000
[ 3611.252453]  ffff8801280e3000 ffff880128107c08 ffff880128100000 ffffed0025020002
[ 3611.253913] Call Trace:
[ 3611.254363] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3611.255944] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.257072] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3611.258421] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.259547] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.260481] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.261605] ? __schedule (kernel/sched/core.c:2806)
[ 3611.262731] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.264149] kthread (kernel/kthread.c:207)
[ 3611.265703] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.267280] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.268842] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.269857] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.270433] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.271054] fnic_fip_q      S ffff880128117c28 29840  5707      2 0x10000000
[ 3611.271873]  ffff880128117c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3611.272791]  ffff8801533e0558 ffff8801533e0530 ffff880128108008 ffff88079d1e8000
[ 3611.274121]  ffff880128108000 ffff880128117c08 ffff880128110000 ffffed0025022002
[ 3611.275290] Call Trace:
[ 3611.275706] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3611.276565] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.277356] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3611.278026] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.278908] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.279497] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.280052] ? __schedule (kernel/sched/core.c:2806)
[ 3611.281398] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.282535] kthread (kernel/kthread.c:207)
[ 3611.283897] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.285740] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.287469] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.288757] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.289548] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.290509] bnx2fc_l2_threa S ffff88012811fc48 29872  5709      2 0x10000000
[ 3611.291737]  ffff88012811fc48 ffff8801ffffffec ffff8801533dfb80 0000000000000000
[ 3611.293709]  ffff8801533e0558 ffff8801533e0530 ffff88012810b008 ffff88079d1e8000
[ 3611.295935]  ffff88012810b000 ffff88012810bca0 ffff880128118000 ffffed0025023002
[ 3611.297669] Call Trace:
[ 3611.298552] ? bnx2fc_ulp_start (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:471)
[ 3611.299491] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.300253] bnx2fc_l2_rcv_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:479)
[ 3611.301245] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3611.302641] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.304150] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.305426] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.306410] ? bnx2fc_ulp_start (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:471)
[ 3611.307441] ? __schedule (kernel/sched/core.c:2806)
[ 3611.308393] ? bnx2fc_ulp_start (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:471)
[ 3611.309262] kthread (kernel/kthread.c:207)
[ 3611.310034] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.311024] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.311982] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.313068] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.313984] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.315068] bnx2fc_thread/0 S ffff880000c2fc78 29000  5710      2 0x10000000
[ 3611.316201]  ffff880000c2fc78 00000000ffffffec ffff8800261dfb80 0000000000000000
[ 3611.317525]  ffff8800261e0558 ffff8800261e0530 ffff88002177b008 ffffffffb4839100
[ 3611.318807]  ffff88002177b000 0000000000000000 ffff880000c28000 ffffed0000185002
[ 3611.320043] Call Trace:
[ 3611.320475] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.321243] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.322365] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.323451] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.324579] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.325842] ? __schedule (kernel/sched/core.c:2806)
[ 3611.326722] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.327769] kthread (kernel/kthread.c:207)
[ 3611.328599] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.329487] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.330415] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.331328] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.332241] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.333209] bnx2fc_thread/1 S ffff880052227c78 29920  5711      2 0x10000000
[ 3611.334347]  ffff880052227c78 00000000ffffffec ffff8800533dfb80 0000000000000000
[ 3611.335680]  ffff8800533e0558 ffff8800533e0530 ffff880052a98008 ffff8801d0dd0000
[ 3611.337051]  ffff880052a98000 0000000000000000 ffff880052220000 ffffed000a444002
[ 3611.338424] Call Trace:
[ 3611.338791] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.339524] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.340511] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.341477] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.342430] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.343405] ? __schedule (kernel/sched/core.c:2806)
[ 3611.344334] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.345438] kthread (kernel/kthread.c:207)
[ 3611.346176] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.347262] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.348411] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.349294] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.350091] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.351207] bnx2fc_thread/2 S ffff88007bf9fc78 29920  5712      2 0x10000000
[ 3611.352506]  ffff88007bf9fc78 00000000ffffffec ffff88007d3dfb80 0000000000000000
[ 3611.353770]  ffff88007d3e0558 ffff88007d3e0530 ffff88007bf8b008 ffff8802ccdd8000
[ 3611.355081]  ffff88007bf8b000 0000000000000000 ffff88007bf98000 ffffed000f7f3002
[ 3611.356222] Call Trace:
[ 3611.356615] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.357619] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.358774] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.359662] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.360776] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.361807] ? __schedule (kernel/sched/core.c:2806)
[ 3611.362744] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.363784] kthread (kernel/kthread.c:207)
[ 3611.364604] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.365567] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.366462] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.367504] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.368576] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.369474] bnx2fc_thread/3 S ffff8800a60bfc78 29920  5713      2 0x10000000
[ 3611.370637]  ffff8800a60bfc78 00000000ffffffec ffff8800a73dfb80 0000000000000000
[ 3611.371971]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a60b0008 ffff8803c8de8000
[ 3611.373280]  ffff8800a60b0000 0000000000000000 ffff8800a60b8000 ffffed0014c17002
[ 3611.374686] Call Trace:
[ 3611.375130] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.375994] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.377008] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.377991] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.378874] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.379741] ? __schedule (kernel/sched/core.c:2806)
[ 3611.380728] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.381672] kthread (kernel/kthread.c:207)
[ 3611.382575] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.383741] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.384742] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.385866] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.386677] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.387790] bnx2fc_thread/4 S ffff8800ca0dfc78 29920  5714      2 0x10000000
[ 3611.388951]  ffff8800ca0dfc78 00000000ffffffec ffff8800cf3dfb80 0000000000000000
[ 3611.390226]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800ca0cb008 ffff880518df0000
[ 3611.391534]  ffff8800ca0cb000 0000000000000000 ffff8800ca0d8000 ffffed001941b002
[ 3611.392831] Call Trace:
[ 3611.393254] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.394107] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.395218] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.396125] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.397215] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.398273] ? __schedule (kernel/sched/core.c:2806)
[ 3611.399073] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.399950] kthread (kernel/kthread.c:207)
[ 3611.400838] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.401785] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.402821] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.404058] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.405496] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.406465] bnx2fc_thread/5 S ffff880128137c78 29920  5715      2 0x10000000
[ 3611.408237]  ffff880128137c78 00000000ffffffec ffff8801291dfb80 0000000000000000
[ 3611.409398]  ffff8801291e0558 ffff8801291e0530 ffff880128128008 ffff88065d1d8000
[ 3611.410620]  ffff880128128000 0000000000000000 ffff880128130000 ffffed0025026002
[ 3611.412001] Call Trace:
[ 3611.412443] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.413529] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.414646] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.415735] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.416808] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.417936] ? __schedule (kernel/sched/core.c:2806)
[ 3611.418913] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.419797] kthread (kernel/kthread.c:207)
[ 3611.420659] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.421640] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.422730] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.424484] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.425941] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.427193] bnx2fc_thread/6 S ffff880152bffc78 29304  5716      2 0x10000000
[ 3611.428753]  ffff880152bffc78 00000000ffffffec ffff8801533dfb80 0000000000000000
[ 3611.430342]  ffff8801533e0558 ffff8801533e0530 ffff880152180008 ffff88079d1e8000
[ 3611.431303]  ffff880152180000 0000000000000000 ffff880152bf8000 ffffed002a57f002
[ 3611.432498] Call Trace:
[ 3611.432752] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.433653] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.434574] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.435711] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.436407] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.437137] ? __schedule (kernel/sched/core.c:2806)
[ 3611.437741] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.438687] kthread (kernel/kthread.c:207)
[ 3611.439156] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.439812] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.440793] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.441633] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.442291] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.443282] bnx2fc_thread/7 S ffff88017c02fc78 29920  5717      2 0x10000000
[ 3611.444034]  ffff88017c02fc78 00000000ffffffec ffff88017d3dfb80 0000000000000000
[ 3611.445403]  ffff88017d3e0558 ffff88017d3e0530 ffff88017cbf3008 ffff8808dd1e0000
[ 3611.446335]  ffff88017cbf3000 0000000000000000 ffff88017c028000 ffffed002f805002
[ 3611.447312] Call Trace:
[ 3611.447685] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.448410] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.449046] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.449687] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.450498] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.451172] ? __schedule (kernel/sched/core.c:2806)
[ 3611.451926] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.452795] kthread (kernel/kthread.c:207)
[ 3611.453459] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.454743] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.456611] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.457789] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.458573] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.459168] bnx2fc_thread/8 S ffff8801a60a7c78 29920  5718      2 0x10000000
[ 3611.459933]  ffff8801a60a7c78 00000000ffffffec ffff8801a73dfb80 0000000000000000
[ 3611.460889]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6093008 ffff8800256f8000
[ 3611.461652]  ffff8801a6093000 0000000000000000 ffff8801a60a0000 ffffed0034c14002
[ 3611.462697] Call Trace:
[ 3611.463020] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.463535] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.464379] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.465057] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.465874] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.466547] ? __schedule (kernel/sched/core.c:2806)
[ 3611.467184] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.467781] kthread (kernel/kthread.c:207)
[ 3611.468289] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.469104] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.469685] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.470288] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.470869] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.471506] bnx2fc_thread/9 S ffff8801d0007c78 29920  5719      2 0x10000000
[ 3611.472438]  ffff8801d0007c78 00000000ffffffec ffff8801d11dfb80 0000000000000000
[ 3611.473513]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0bf8008 ffff8800256fb000
[ 3611.474385]  ffff8801d0bf8000 0000000000000000 ffff8801d0000000 ffffed003a000002
[ 3611.475607] Call Trace:
[ 3611.475873] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.476430] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.477139] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.477793] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.478666] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.479282] ? __schedule (kernel/sched/core.c:2806)
[ 3611.479804] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.480606] kthread (kernel/kthread.c:207)
[ 3611.481104] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.481797] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.482618] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.483271] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.483787] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.484750] bnx2fc_thread/1 S ffff8801fa14fc78 29920  5720      2 0x10000000
[ 3611.486108]  ffff8801fa14fc78 00000000ffffffec ffff8801fb3dfb80 0000000000000000
[ 3611.486942]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fa7c3008 ffff880052dc8000
[ 3611.487728]  ffff8801fa7c3000 0000000000000000 ffff8801fa148000 ffffed003f429002
[ 3611.488576] Call Trace:
[ 3611.488816] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.489286] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.490036] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.490866] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.491510] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.492397] ? __schedule (kernel/sched/core.c:2806)
[ 3611.493616] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.494237] kthread (kernel/kthread.c:207)
[ 3611.495176] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.496728] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.497442] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.498312] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.498848] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.499505] bnx2fc_thread/1 S ffff880224017c78 29920  5721      2 0x10000000
[ 3611.500402]  ffff880224017c78 00000000ffffffec ffff8802253dfb80 0000000000000000
[ 3611.501269]  ffff8802253e0558 ffff8802253e0530 ffff880224008008 ffff8800a6dd0000
[ 3611.502484]  ffff880224008000 0000000000000000 ffff880224010000 ffffed0044802002
[ 3611.504215] Call Trace:
[ 3611.504682] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.505398] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.506275] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.506852] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.507597] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.508256] ? __schedule (kernel/sched/core.c:2806)
[ 3611.508805] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.509437] kthread (kernel/kthread.c:207)
[ 3611.509918] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.510809] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.511449] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.512144] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.512672] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.513721] bnx2fc_thread/1 S ffff88024e067c78 29920  5722      2 0x10000000
[ 3611.514973]  ffff88024e067c78 00000000ffffffec ffff88024f3dfb80 0000000000000000
[ 3611.515923]  ffff88024f3e0558 ffff88024f3e0530 ffff88024e053008 ffff88017cdd0000
[ 3611.516747]  ffff88024e053000 0000000000000000 ffff88024e060000 ffffed0049c0c002
[ 3611.517841] Call Trace:
[ 3611.518115] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.518639] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.519273] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.519876] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.520505] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.521110] ? __schedule (kernel/sched/core.c:2806)
[ 3611.521684] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.522394] kthread (kernel/kthread.c:207)
[ 3611.522901] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.523576] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.524264] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.525121] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.525694] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.526407] bnx2fc_thread/1 S ffff880278097c78 29920  5723      2 0x10000000
[ 3611.527182]  ffff880278097c78 00000000ffffffec ffff8802791dfb80 0000000000000000
[ 3611.528042]  ffff8802791e0558 ffff8802791e0530 ffff880278083008 ffff880224dd0000
[ 3611.528798]  ffff880278083000 0000000000000000 ffff880278090000 ffffed004f012002
[ 3611.529617] Call Trace:
[ 3611.529861] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.530346] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.531065] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.531666] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.532338] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.532934] ? __schedule (kernel/sched/core.c:2806)
[ 3611.533713] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.534354] kthread (kernel/kthread.c:207)
[ 3611.534975] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.535659] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.536275] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.536879] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.537480] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.538088] bnx2fc_thread/1 S ffff8802a2027c78 29920  5724      2 0x10000000
[ 3611.538868]  ffff8802a2027c78 00000000ffffffec ffff8802a33dfb80 0000000000000000
[ 3611.539620]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a200b008 ffff8802ccde0000
[ 3611.540427]  ffff8802a200b000 0000000000000000 ffff8802a2020000 ffffed0054404002
[ 3611.541196] Call Trace:
[ 3611.541447] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.542067] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.542708] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.543436] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.544112] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.545054] ? __schedule (kernel/sched/core.c:2806)
[ 3611.545755] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.546340] kthread (kernel/kthread.c:207)
[ 3611.546836] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.547600] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.548206] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.548799] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.549309] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.549903] bnx2fc_thread/1 S ffff8802ccfafc78 29920  5725      2 0x10000000
[ 3611.550740]  ffff8802ccfafc78 00000000ffffffec ffff8802cd3dfb80 0000000000000000
[ 3611.551521]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cc0cb008 ffff8803c8df0000
[ 3611.552417]  ffff8802cc0cb000 0000000000000000 ffff8802ccfa8000 ffffed00599f5002
[ 3611.553292] Call Trace:
[ 3611.553543] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.554201] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.554961] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.555590] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.556198] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.556779] ? __schedule (kernel/sched/core.c:2806)
[ 3611.557462] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.558064] kthread (kernel/kthread.c:207)
[ 3611.558544] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.559122] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.559705] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.560321] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.560976] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.561582] bnx2fc_thread/1 S ffff8802f6087c78 29920  5726      2 0x10000000
[ 3611.562617]  ffff8802f6087c78 00000000ffffffec ffff8802f73dfb80 0000000000000000
[ 3611.563462]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6b2b008 ffff880518df8000
[ 3611.564333]  ffff8802f6b2b000 0000000000000000 ffff8802f6080000 ffffed005ec10002
[ 3611.565403] Call Trace:
[ 3611.565668] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.566149] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.566845] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.567442] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.568056] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.568636] ? __schedule (kernel/sched/core.c:2806)
[ 3611.569158] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.569729] kthread (kernel/kthread.c:207)
[ 3611.570203] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.570832] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.571406] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.572096] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.572665] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.573376] bnx2fc_thread/1 S ffff88032009fc78 29920  5727      2 0x10000000
[ 3611.574161]  ffff88032009fc78 00000000ffffffec ffff8803211dfb80 0000000000000000
[ 3611.575042]  ffff8803211e0558 ffff8803211e0530 ffff880320090008 ffff88060d230000
[ 3611.575869]  ffff880320090000 0000000000000000 ffff880320098000 ffffed0064013002
[ 3611.576774] Call Trace:
[ 3611.577068] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.577550] bnx2fc_percpu_io_thread (include/linux/spinlock.h:317 drivers/scsi/bnx2fc/bnx2fc_fcoe.c:609)
[ 3611.578212] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.578789] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.579367] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.579936] ? __schedule (kernel/sched/core.c:2806)
[ 3611.580582] ? bnx2fc_cpu_callback (drivers/scsi/bnx2fc/bnx2fc_fcoe.c:600)
[ 3611.581154] kthread (kernel/kthread.c:207)
[ 3611.581633] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.582537] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.583147] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.583774] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.584318] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.585016] tcm_qla2xxx_fre S ffff88012815fc28 29840  5743      2 0x10000000
[ 3611.585947]  ffff88012815fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3611.586721]  ffff8801533e0558 ffff8801533e0530 ffff88012812b008 ffff88079d1e8000
[ 3611.588567]  ffff88012812b000 ffff88012815fc08 ffff880128158000 ffffed002502b002
[ 3611.589777] Call Trace:
[ 3611.590144] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3611.591032] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.591763] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3611.592862] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.593852] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.595085] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.596232] ? __schedule (kernel/sched/core.c:2806)
[ 3611.597254] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.598525] kthread (kernel/kthread.c:207)
[ 3611.599003] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.599576] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.600151] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.600809] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.601367] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.602331] bnx2i_thread/0  S ffff880021007c58 29888  5779      2 0x10000000
[ 3611.603645]  ffff880021007c58 0000000000000011 ffff88002173b000 ffff880000000000
[ 3611.604728]  ffff8800261e0558 ffff8800261e0530 ffff88002173b008 ffffffffb4839100
[ 3611.605838]  ffff88002173b000 0000000000000201 ffff880021000000 ffffed0004200002
[ 3611.606709] Call Trace:
[ 3611.607077] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.607740] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.608451] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.609029] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.609746] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.610348] ? __schedule (kernel/sched/core.c:2806)
[ 3611.610981] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.611610] kthread (kernel/kthread.c:207)
[ 3611.612197] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.612877] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.613487] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.614192] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.615044] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.616124] bnx2i_thread/1  S ffff88005222fc58 29888  5780      2 0x10000000
[ 3611.616896]  ffff88005222fc58 0000000000000011 ffff880052978000 ffff880000000000
[ 3611.617831]  ffff8800533e0558 ffff8800533e0530 ffff880052978008 ffff8801d0dd0000
[ 3611.618654]  ffff880052978000 0000000000000201 ffff880052228000 ffffed000a445002
[ 3611.619402] Call Trace:
[ 3611.619642] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.620118] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.620796] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.621505] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.622338] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.623283] ? __schedule (kernel/sched/core.c:2806)
[ 3611.623828] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.624521] kthread (kernel/kthread.c:207)
[ 3611.625078] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.625874] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.626501] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.627143] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.627650] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.628282] bnx2i_thread/2  S ffff88007bfb7c58 29888  5781      2 0x10000000
[ 3611.629023]  ffff88007bfb7c58 0000000000000011 ffff88007bfa8000 ffff880000000000
[ 3611.629827]  ffff88007d3e0558 ffff88007d3e0530 ffff88007bfa8008 ffff8802ccdd8000
[ 3611.630630]  ffff88007bfa8000 0000000000000201 ffff88007bfb0000 ffffed000f7f6002
[ 3611.631381] Call Trace:
[ 3611.631621] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.632338] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.633107] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.633778] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.634440] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.635171] ? __schedule (kernel/sched/core.c:2806)
[ 3611.635703] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.636318] kthread (kernel/kthread.c:207)
[ 3611.636809] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.637392] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.638035] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.638659] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.639161] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.639736] bnx2i_thread/3  S ffff8800a60c7c58 29888  5782      2 0x10000000
[ 3611.640476]  ffff8800a60c7c58 0000000000000011 ffff8800a60b3000 ffff880000000000
[ 3611.641249]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a60b3008 ffff8803c8de8000
[ 3611.642011]  ffff8800a60b3000 0000000000000201 ffff8800a60c0000 ffffed0014c18002
[ 3611.643071] Call Trace:
[ 3611.643316] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.643822] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.644557] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.645368] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.646041] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.646735] ? __schedule (kernel/sched/core.c:2806)
[ 3611.647470] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.648167] kthread (kernel/kthread.c:207)
[ 3611.648667] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.649279] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.649863] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.650490] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.651016] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.651670] bnx2i_thread/4  S ffff8800ca0f7c58 29888  5783      2 0x10000000
[ 3611.652552]  ffff8800ca0f7c58 0000000000000011 ffff8800ca0e8000 ffff880000000000
[ 3611.653351]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800ca0e8008 ffff880518df0000
[ 3611.654275]  ffff8800ca0e8000 0000000000000201 ffff8800ca0f0000 ffffed001941e002
[ 3611.655298] Call Trace:
[ 3611.655612] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.656131] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.656744] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.657350] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.657941] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.658642] ? __schedule (kernel/sched/core.c:2806)
[ 3611.659167] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.659762] kthread (kernel/kthread.c:207)
[ 3611.660339] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.660944] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.661536] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.662364] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.663000] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.663544] bnx2i_thread/5  S ffff88012816fc58 28968  5784      2 0x10000000
[ 3611.664371]  ffff88012816fc58 0000000000000011 ffff880128160000 ffff880100000000
[ 3611.665333]  ffff8801291e0558 ffff8801291e0530 ffff880128160008 ffff88065d1d8000
[ 3611.666405]  ffff880128160000 0000000000000201 ffff880128168000 ffffed002502d002
[ 3611.667190] Call Trace:
[ 3611.667431] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.667938] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.668605] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.669180] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.669772] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.670416] ? __schedule (kernel/sched/core.c:2806)
[ 3611.670970] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.671570] kthread (kernel/kthread.c:207)
[ 3611.672369] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.673032] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.673680] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.674508] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.675060] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.675831] bnx2i_thread/6  S ffff88015212fc58 29888  5785      2 0x10000000
[ 3611.676562]  ffff88015212fc58 0000000000000011 ffff880152183000 ffff880100000000
[ 3611.677390]  ffff8801533e0558 ffff8801533e0530 ffff880152183008 ffff88079d1e8000
[ 3611.678336]  ffff880152183000 0000000000000201 ffff880152128000 ffffed002a425002
[ 3611.679083] Call Trace:
[ 3611.679323] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.679801] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.680425] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.681023] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.681649] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.682410] ? __schedule (kernel/sched/core.c:2806)
[ 3611.683074] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.683749] kthread (kernel/kthread.c:207)
[ 3611.684305] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.685078] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.685758] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.686358] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.686922] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.687506] bnx2i_thread/7  S ffff88017c037c58 29888  5786      2 0x10000000
[ 3611.688255]  ffff88017c037c58 0000000000000011 ffff88017cbf0000 ffff880100000000
[ 3611.689039]  ffff88017d3e0558 ffff88017d3e0530 ffff88017cbf0008 ffff8808dd1e0000
[ 3611.689799]  ffff88017cbf0000 0000000000000201 ffff88017c030000 ffffed002f806002
[ 3611.690555] Call Trace:
[ 3611.690815] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.691292] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.691977] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.692663] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.693252] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.693939] ? __schedule (kernel/sched/core.c:2806)
[ 3611.694489] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.695234] kthread (kernel/kthread.c:207)
[ 3611.695706] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.696315] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.696995] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.697594] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.698135] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.698711] bnx2i_thread/8  S ffff8801a616fc58 29888  5787      2 0x10000000
[ 3611.699418]  ffff8801a616fc58 0000000000000011 ffff8801a60fb000 ffff880100000000
[ 3611.700165]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a60fb008 ffff8800256f8000
[ 3611.700941]  ffff8801a60fb000 0000000000000201 ffff8801a6168000 ffffed0034c2d002
[ 3611.701691] Call Trace:
[ 3611.701932] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.702437] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.703132] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.703891] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.704480] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.705166] ? __schedule (kernel/sched/core.c:2806)
[ 3611.705735] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.706466] kthread (kernel/kthread.c:207)
[ 3611.706958] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.707566] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.708204] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.708772] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.709273] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.709870] bnx2i_thread/9  S ffff8801d000fc58 29888  5788      2 0x10000000
[ 3611.710629]  ffff8801d000fc58 0000000000000011 ffff8801d0bfb000 ffff880100000000
[ 3611.711392]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0bfb008 ffff8800256fb000
[ 3611.712273]  ffff8801d0bfb000 0000000000000201 ffff8801d0008000 ffffed003a001002
[ 3611.713051] Call Trace:
[ 3611.713509] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.714041] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.714646] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.715269] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.715888] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.716616] ? __schedule (kernel/sched/core.c:2806)
[ 3611.717163] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.717786] kthread (kernel/kthread.c:207)
[ 3611.718277] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.718847] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.719416] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.719988] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.720493] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.721080] bnx2i_thread/10 S ffff8801fa157c58 29304  5789      2 0x10000000
[ 3611.721900]  ffff8801fa157c58 0000000000000011 ffff8801fa7db000 ffff880100000000
[ 3611.722690]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fa7db008 ffff880052dc8000
[ 3611.723494]  ffff8801fa7db000 0000000000000201 ffff8801fa150000 ffffed003f42a002
[ 3611.724384] Call Trace:
[ 3611.724634] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.725188] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.725877] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.726492] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.727084] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.727684] ? __schedule (kernel/sched/core.c:2806)
[ 3611.728226] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.728829] kthread (kernel/kthread.c:207)
[ 3611.729305] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.729893] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.730466] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.731068] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.731568] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.732160] bnx2i_thread/11 S ffff88022401fc58 29888  5790      2 0x10000000
[ 3611.732936]  ffff88022401fc58 0000000000000011 ffff88022400b000 ffff880200000000
[ 3611.733760]  ffff8802253e0558 ffff8802253e0530 ffff88022400b008 ffff8800a6dd0000
[ 3611.734544]  ffff88022400b000 0000000000000201 ffff880224018000 ffffed0044803002
[ 3611.735772] Call Trace:
[ 3611.736031] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.736660] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.737269] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.737865] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.738501] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.739097] ? __schedule (kernel/sched/core.c:2806)
[ 3611.739621] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.740220] kthread (kernel/kthread.c:207)
[ 3611.740808] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.741474] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.742245] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.742831] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.743335] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.744015] bnx2i_thread/12 S ffff88024e087c58 29888  5791      2 0x10000000
[ 3611.744761]  ffff88024e087c58 0000000000000011 ffff88024e078000 ffff880200000000
[ 3611.745893]  ffff88024f3e0558 ffff88024f3e0530 ffff88024e078008 ffff88017cdd0000
[ 3611.746779]  ffff88024e078000 0000000000000201 ffff88024e080000 ffffed0049c10002
[ 3611.747542] Call Trace:
[ 3611.747859] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.748457] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.749048] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.749630] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.750213] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.750984] ? __schedule (kernel/sched/core.c:2806)
[ 3611.751513] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.752434] kthread (kernel/kthread.c:207)
[ 3611.752972] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.753617] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.754315] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.755093] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.755915] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.756642] bnx2i_thread/13 S ffff8802780a7c58 29888  5792      2 0x10000000
[ 3611.757466]  ffff8802780a7c58 0000000000000011 ffff880278098000 ffff880200000000
[ 3611.758650]  ffff8802791e0558 ffff8802791e0530 ffff880278098008 ffff880224dd0000
[ 3611.759835]  ffff880278098000 0000000000000201 ffff8802780a0000 ffffed004f014002
[ 3611.761093] Call Trace:
[ 3611.761480] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.762570] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.763563] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.764541] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.765937] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.767230] ? __schedule (kernel/sched/core.c:2806)
[ 3611.768161] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.769237] kthread (kernel/kthread.c:207)
[ 3611.769984] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.770952] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.771909] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.772863] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.773815] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.774753] bnx2i_thread/14 S ffff8802a2037c58 29888  5793      2 0x10000000
[ 3611.776441]  ffff8802a2037c58 0000000000000011 ffff8802a2028000 ffff880200000000
[ 3611.777742]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2028008 ffff8802ccde0000
[ 3611.779061]  ffff8802a2028000 0000000000000201 ffff8802a2030000 ffffed0054406002
[ 3611.780288] Call Trace:
[ 3611.780734] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.781555] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.782704] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.783731] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.785259] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.786968] ? __schedule (kernel/sched/core.c:2806)
[ 3611.787801] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.788837] kthread (kernel/kthread.c:207)
[ 3611.789613] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.790565] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.791514] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.792761] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.794102] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.796162] bnx2i_thread/15 S ffff8802cc0e7c58 28968  5794      2 0x10000000
[ 3611.797606]  ffff8802cc0e7c58 0000000000000011 ffff8802cc0d8000 ffff880200000000
[ 3611.798931]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cc0d8008 ffff8803c8df0000
[ 3611.800190]  ffff8802cc0d8000 0000000000000201 ffff8802cc0e0000 ffffed005981c002
[ 3611.801522] Call Trace:
[ 3611.802167] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.803567] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.805494] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.807555] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.809067] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.810006] ? __schedule (kernel/sched/core.c:2806)
[ 3611.810976] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.812134] kthread (kernel/kthread.c:207)
[ 3611.813784] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.815821] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.817495] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.819075] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.819866] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.821028] bnx2i_thread/16 S ffff8802f608fc58 29888  5795      2 0x10000000
[ 3611.822725]  ffff8802f608fc58 0000000000000011 ffff8802f6b28000 ffff880200000000
[ 3611.824684]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6b28008 ffff880518df8000
[ 3611.827527]  ffff8802f6b28000 0000000000000201 ffff8802f6088000 ffffed005ec11002
[ 3611.829527] Call Trace:
[ 3611.829908] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.830725] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.831901] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.833491] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.834739] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.836866] ? __schedule (kernel/sched/core.c:2806)
[ 3611.838564] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.839694] kthread (kernel/kthread.c:207)
[ 3611.840792] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.841902] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.843708] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.845256] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.847039] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.848542] bnx2i_thread/17 S ffff8803200a7c58 29888  5796      2 0x10000000
[ 3611.849667]  ffff8803200a7c58 0000000000000011 ffff880320093000 ffff880300000000
[ 3611.850929]  ffff8803211e0558 ffff8803211e0530 ffff880320093008 ffff88060d230000
[ 3611.852063]  ffff880320093000 0000000000000201 ffff8803200a0000 ffffed0064014002
[ 3611.853896] Call Trace:
[ 3611.854366] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.855577] bnx2i_percpu_io_thread (drivers/scsi/bnx2i/bnx2i_hwi.c:1877 (discriminator 1))
[ 3611.857672] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.858790] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.859703] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.860692] ? __schedule (kernel/sched/core.c:2806)
[ 3611.861681] ? bnx2i_indicate_kcqe (drivers/scsi/bnx2i/bnx2i_hwi.c:1870)
[ 3611.863589] kthread (kernel/kthread.c:207)
[ 3611.864694] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.866969] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.868919] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.869861] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.870866] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.871981] scsi_eh_0       S ffff88012819fbc8 30080  5823      2 0x10000000
[ 3611.873935]  ffff88012819fbc8 ffffffffa72ee7d0 ffff880a70f2419b ffffffff00000000
[ 3611.876236]  ffff8801533e0558 ffff8801533e0530 ffff880128163008 ffff88079d1e8000
[ 3611.878314]  ffff880128163000 00000000001e0680 ffff880128198000 ffffed0025033002
[ 3611.879529] Call Trace:
[ 3611.879896] ? lockdep_init_map (kernel/locking/lockdep.c:3091)
[ 3611.880995] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.881748] scsi_error_handler (drivers/scsi/scsi_error.c:2181)
[ 3611.882822] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.884260] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3611.886534] ? scsi_eh_get_sense (drivers/scsi/scsi_error.c:2163)
[ 3611.887962] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.888980] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.889908] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.890976] ? __schedule (kernel/sched/core.c:2806)
[ 3611.891918] ? scsi_eh_get_sense (drivers/scsi/scsi_error.c:2163)
[ 3611.893614] kthread (kernel/kthread.c:207)
[ 3611.895087] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.896758] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.897906] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.898920] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.899707] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.900788] scsi_tmf_0      S ffff8801281afc28 29840  5824      2 0x10000000
[ 3611.902057]  ffff8801281afc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3611.903943]  ffff8801533e0558 ffff8801533e0530 ffff8801281a0008 ffff88079d1e8000
[ 3611.906084]  ffff8801281a0000 ffff8801281afc08 ffff8801281a8000 ffffed0025035002
[ 3611.907830] Call Trace:
[ 3611.908362] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3611.909218] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.909982] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3611.911033] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.911998] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.913570] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.915157] ? __schedule (kernel/sched/core.c:2806)
[ 3611.916723] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.917908] kthread (kernel/kthread.c:207)
[ 3611.918781] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.919671] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.920610] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.921567] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.922812] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.924060] target_completi S ffff8801281bfc28 29840  5908      2 0x10000000
[ 3611.925957]  ffff8801281bfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3611.927601]  ffff88017d3e0558 ffff88017d3e0530 ffff8801281a3008 ffff8808dd1e0000
[ 3611.928872]  ffff8801281a3000 ffff8801281bfc08 ffff8801281b8000 ffffed0025037002
[ 3611.930084] Call Trace:
[ 3611.930503] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3611.931508] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.932533] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3611.933517] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.934637] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.936291] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.937483] ? __schedule (kernel/sched/core.c:2806)
[ 3611.938429] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.939254] kthread (kernel/kthread.c:207)
[ 3611.939970] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.940980] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.942058] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.943178] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.943962] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.945887] tmr-rd_mcp      S ffff8801281d7c28 29840  5909      2 0x10000000
[ 3611.947640]  ffff8801281d7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3611.949040]  ffff8801533e0558 ffff8801533e0530 ffff8801281c8008 ffff88079d1e8000
[ 3611.950264]  ffff8801281c8000 ffff8801281d7c08 ffff8801281d0000 ffffed002503a002
[ 3611.951623] Call Trace:
[ 3611.952139] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3611.953558] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.954554] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3611.956119] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.957530] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.958485] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.959305] ? __schedule (kernel/sched/core.c:2806)
[ 3611.960099] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.960992] kthread (kernel/kthread.c:207)
[ 3611.961921] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.963218] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.964137] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.965566] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.967003] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.968174] xcopy_wq        S ffff8801281e7c28 29840  5910      2 0x10000000
[ 3611.969268]  ffff8801281e7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3611.970469]  ffff8801533e0558 ffff8801533e0530 ffff8801281cb008 ffff88079d1e8000
[ 3611.971839]  ffff8801281cb000 ffff8801281e7c08 ffff8801281e0000 ffffed002503c002
[ 3611.973299] Call Trace:
[ 3611.973681] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3611.975168] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.976141] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3611.977111] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3611.978077] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3611.979032] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.979849] ? __schedule (kernel/sched/core.c:2806)
[ 3611.980900] ? worker_thread (kernel/workqueue.c:2203)
[ 3611.981784] kthread (kernel/kthread.c:207)
[ 3611.982800] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.983860] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3611.985681] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.987339] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3611.988647] ? flush_kthread_work (kernel/kthread.c:176)
[ 3611.989545] iscsi_ttx       S ffff8801281f79e8 29600  5916      2 0x10000000
[ 3611.990729]  ffff8801281f79e8 0000000000002300 ffffffffb8038920 ffffed0100000000
[ 3611.992049]  ffff8801533e0558 ffff8801533e0530 ffff8801281e8008 ffff88079d1e8000
[ 3611.993744]  ffff8801281e8000 ffffed002a67c0d2 ffff8801281f0000 ffffed002503e002
[ 3611.995792] Call Trace:
[ 3611.996510] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3611.997636] schedule_timeout (kernel/time/timer.c:1475)
[ 3611.998786] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3611.999812] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.000791] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.001827] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.003040] ? wait_for_completion_interruptible (kernel/sched/completion.c:75 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.004266] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.005340] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.006333] wait_for_completion_interruptible (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.007744] ? wait_for_completion_killable (kernel/sched/completion.c:189)
[ 3612.009125] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.010339] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.011333] ? iscsi_tx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:452)
[ 3612.012611] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3612.013537] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.014549] iscsi_tx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:453)
[ 3612.015729] iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:3976)
[ 3612.016745] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.018030] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.019111] kthread (kernel/kthread.c:207)
[ 3612.019850] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.020823] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.021737] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.022961] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.023774] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.024749] iscsi_trx       S ffff8801281ff6e8 28832  5917      2 0x10000000
[ 3612.026073]  ffff8801281ff6e8 ffff8801281ff698 ffffffffb8038920 ffffed0100000000
[ 3612.027621]  ffff8801533e0558 ffff8801533e0530 ffff8801281eb008 ffff88079d1e8000
[ 3612.028642]  ffff8801281eb000 ffffed002a67c0d2 ffff8801281f8000 ffffed002503f002
[ 3612.029411] Call Trace:
[ 3612.029655] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.030152] schedule_timeout (kernel/time/timer.c:1475)
[ 3612.030805] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3612.031777] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.032432] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.033314] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.034032] ? wait_for_completion_interruptible (kernel/sched/completion.c:75 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.035220] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.036245] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.037267] wait_for_completion_interruptible (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.038139] ? wait_for_completion_killable (kernel/sched/completion.c:189)
[ 3612.038843] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.039369] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.039988] ? iscsi_rx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:399)
[ 3612.040822] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3612.041439] iscsi_rx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:400)
[ 3612.042170] iscsi_target_rx_thread (drivers/target/iscsi/iscsi_target.c:4118)
[ 3612.042987] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3612.043761] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3612.044450] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.045109] ? iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:4104)
[ 3612.046073] ? __lock_acquire (kernel/locking/lockdep.c:3231)
[ 3612.046867] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.047710] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3612.048259] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3612.048805] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3612.049410] ? lockdep_init_map (kernel/locking/lockdep.c:3091)
[ 3612.050024] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.050758] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.051454] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.052155] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.052799] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.053605] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.054300] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.055581] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.056647] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.057619] ? __schedule (kernel/sched/core.c:2806)
[ 3612.058271] ? iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:4104)
[ 3612.059335] kthread (kernel/kthread.c:207)
[ 3612.059897] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.060534] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.061593] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.062375] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.063449] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.064226] iscsi_ttx       S ffff88012820f9e8 29600  5918      2 0x10000000
[ 3612.065654]  ffff88012820f9e8 ffffffffb795bd08 ffffffffb8038920 ffffed0100000000
[ 3612.066830]  ffff8801533e0558 ffff8801533e0530 ffff880128200008 ffff88079d1e8000
[ 3612.067994]  ffff880128200000 ffffed002a67c0d2 ffff880128208000 ffffed0025041002
[ 3612.068789] Call Trace:
[ 3612.069141] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.069633] schedule_timeout (kernel/time/timer.c:1475)
[ 3612.070198] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3612.071044] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.071681] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.072569] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.073478] ? wait_for_completion_interruptible (kernel/sched/completion.c:75 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.074271] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.075197] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.076605] wait_for_completion_interruptible (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.078021] ? wait_for_completion_killable (kernel/sched/completion.c:189)
[ 3612.079284] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.080091] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.081211] ? iscsi_tx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:452)
[ 3612.082403] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3612.083314] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.084589] iscsi_tx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:453)
[ 3612.086239] iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:3976)
[ 3612.087324] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.088395] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.089374] kthread (kernel/kthread.c:207)
[ 3612.090153] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.091177] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.092197] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.093585] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.096239] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.097432] iscsi_trx       S ffff8801282176e8 28832  5919      2 0x10000000
[ 3612.098960]  ffff8801282176e8 ffff8801282176d8 ffffffffb8038920 ffffed0100000000
[ 3612.100143]  ffff8801533e0558 ffff8801533e0530 ffff880128203008 ffff88079d1e8000
[ 3612.101581]  ffff880128203000 ffffed002a67c0d2 ffff880128210000 ffffed0025042002
[ 3612.103077] Call Trace:
[ 3612.103677] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.104749] schedule_timeout (kernel/time/timer.c:1475)
[ 3612.106156] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3612.107675] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.108972] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.109984] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.110867] ? wait_for_completion_interruptible (kernel/sched/completion.c:75 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.112012] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.113448] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.115550] wait_for_completion_interruptible (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.117533] ? wait_for_completion_killable (kernel/sched/completion.c:189)
[ 3612.118971] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.119777] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.120840] ? iscsi_rx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:399)
[ 3612.122188] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3612.124052] iscsi_rx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:400)
[ 3612.124864] iscsi_target_rx_thread (drivers/target/iscsi/iscsi_target.c:4118)
[ 3612.126194] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3612.126784] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3612.127564] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.128191] ? iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:4104)
[ 3612.128943] ? __lock_acquire (kernel/locking/lockdep.c:3231)
[ 3612.129530] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.130091] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3612.130782] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3612.131318] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3612.132049] ? lockdep_init_map (kernel/locking/lockdep.c:3091)
[ 3612.132742] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.133516] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.134166] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.134832] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.135656] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.136272] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.136904] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.137837] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.138461] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.139034] ? __schedule (kernel/sched/core.c:2806)
[ 3612.139550] ? iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:4104)
[ 3612.140195] kthread (kernel/kthread.c:207)
[ 3612.140722] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.141303] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.141933] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.142840] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.143639] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.144315] iscsi_ttx       S ffff8801282279e8 29600  5920      2 0x10000000
[ 3612.145472]  ffff8801282279e8 ffffffffb795bd08 ffffffffb8038920 ffffed0100000000
[ 3612.146319]  ffff8801533e0558 ffff8801533e0530 ffff880128218008 ffff88079d1e8000
[ 3612.147086]  ffff880128218000 ffffed002a67c0d2 ffff880128220000 ffffed0025044002
[ 3612.148004] Call Trace:
[ 3612.148258] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.148736] schedule_timeout (kernel/time/timer.c:1475)
[ 3612.149308] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3612.149969] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.150592] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.151194] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.151764] ? wait_for_completion_interruptible (kernel/sched/completion.c:75 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.152677] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.153486] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.154185] wait_for_completion_interruptible (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.155172] ? wait_for_completion_killable (kernel/sched/completion.c:189)
[ 3612.155859] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.156419] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.157087] ? iscsi_tx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:452)
[ 3612.157820] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3612.158435] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.159090] iscsi_tx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:453)
[ 3612.159741] iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:3976)
[ 3612.160343] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.161004] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.161681] kthread (kernel/kthread.c:207)
[ 3612.162220] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.162966] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.163675] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.164330] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.164895] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.165694] iscsi_trx       S ffff88012822f6e8 28832  5921      2 0x10000000
[ 3612.166395]  ffff88012822f6e8 ffff88012822f6d8 ffffffffb8038920 ffffed0100000000
[ 3612.167183]  ffff8801533e0558 ffff8801533e0530 ffff88012821b008 ffff88079d1e8000
[ 3612.167960]  ffff88012821b000 ffffed002a67c0d2 ffff880128228000 ffffed0025045002
[ 3612.168720] Call Trace:
[ 3612.168965] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.169451] schedule_timeout (kernel/time/timer.c:1475)
[ 3612.170015] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3612.170848] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.171449] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.172111] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.172694] ? wait_for_completion_interruptible (kernel/sched/completion.c:75 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.173612] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.174376] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.175131] wait_for_completion_interruptible (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.175840] ? wait_for_completion_killable (kernel/sched/completion.c:189)
[ 3612.176508] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.177138] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.177812] ? iscsi_rx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:399)
[ 3612.178538] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3612.179079] iscsi_rx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:400)
[ 3612.179708] iscsi_target_rx_thread (drivers/target/iscsi/iscsi_target.c:4118)
[ 3612.180560] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3612.181100] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3612.181714] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.182402] ? iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:4104)
[ 3612.183139] ? __lock_acquire (kernel/locking/lockdep.c:3231)
[ 3612.183729] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.184361] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3612.185143] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3612.185756] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3612.186323] ? lockdep_init_map (kernel/locking/lockdep.c:3091)
[ 3612.186956] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.187569] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.188527] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.189081] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.189692] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.190367] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.191086] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.191740] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.192352] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.193295] ? __schedule (kernel/sched/core.c:2806)
[ 3612.193855] ? iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:4104)
[ 3612.194605] kthread (kernel/kthread.c:207)
[ 3612.195292] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.195895] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.196491] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.197106] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.197942] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.198539] iscsi_ttx       S ffff88012823f9e8 29600  5922      2 0x10000000
[ 3612.199247]  ffff88012823f9e8 ffffffffb795bd08 ffffffffb8038920 ffffed0100000000
[ 3612.199998]  ffff8801533e0558 ffff8801533e0530 ffff880128230008 ffff88079d1e8000
[ 3612.200860]  ffff880128230000 ffffed002a67c0d2 ffff880128238000 ffffed0025047002
[ 3612.201775] Call Trace:
[ 3612.202272] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.203159] schedule_timeout (kernel/time/timer.c:1475)
[ 3612.203754] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3612.204480] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.205458] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.206342] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.207011] ? wait_for_completion_interruptible (kernel/sched/completion.c:75 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.207849] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.208538] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.209159] wait_for_completion_interruptible (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.209889] ? wait_for_completion_killable (kernel/sched/completion.c:189)
[ 3612.210640] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.211169] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.211939] ? iscsi_tx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:452)
[ 3612.212981] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3612.213927] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.215005] iscsi_tx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:453)
[ 3612.216071] iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:3976)
[ 3612.216661] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.217332] ? iscsit_thread_get_cpumask (drivers/target/iscsi/iscsi_target.c:3965)
[ 3612.218043] kthread (kernel/kthread.c:207)
[ 3612.218646] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.219228] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.219807] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.220497] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.221110] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.221776] iscsi_trx       S ffff8801282476e8 28832  5923      2 0x10000000
[ 3612.222994]  ffff8801282476e8 ffff8801282476d8 ffffffffb8038920 ffffed0100000000
[ 3612.224093]  ffff8801533e0558 ffff8801533e0530 ffff880128233008 ffff88079d1e8000
[ 3612.225165]  ffff880128233000 ffffed002a67c0d2 ffff880128240000 ffffed0025048002
[ 3612.226117] Call Trace:
[ 3612.226478] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.227028] schedule_timeout (kernel/time/timer.c:1475)
[ 3612.227633] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3612.228375] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.228929] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.229677] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.230238] ? wait_for_completion_interruptible (kernel/sched/completion.c:75 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.231052] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.231756] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.232664] wait_for_completion_interruptible (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:190)
[ 3612.233828] ? wait_for_completion_killable (kernel/sched/completion.c:189)
[ 3612.234633] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.235246] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.235933] ? iscsi_rx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:399)
[ 3612.236576] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3612.237189] iscsi_rx_thread_pre_handler (drivers/target/iscsi/iscsi_target_tq.c:400)
[ 3612.237872] iscsi_target_rx_thread (drivers/target/iscsi/iscsi_target.c:4118)
[ 3612.238711] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3612.239218] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3612.239796] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.240473] ? iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:4104)
[ 3612.241219] ? __lock_acquire (kernel/locking/lockdep.c:3231)
[ 3612.241868] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.242708] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3612.243534] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3612.244105] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3612.244762] ? lockdep_init_map (kernel/locking/lockdep.c:3091)
[ 3612.245607] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3612.246236] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3612.246840] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3612.247421] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.248012] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.248635] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.249267] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.249900] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.250583] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.251249] ? __schedule (kernel/sched/core.c:2806)
[ 3612.251978] ? iscsi_target_tx_thread (drivers/target/iscsi/iscsi_target.c:4104)
[ 3612.253027] kthread (kernel/kthread.c:207)
[ 3612.253549] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.254153] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.254859] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.255599] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.256120] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.256716] bond0           S ffff880128267c28 29840  5944      2 0x10000000
[ 3612.257660]  ffff880128267c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.258480]  ffff8801533e0558 ffff8801533e0530 ffff880128258008 ffff88079d1e8000
[ 3612.259234]  ffff880128258000 ffff880128267c08 ffff880128260000 ffffed002504c002
[ 3612.259996] Call Trace:
[ 3612.260264] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.260903] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.261436] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.262200] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.262833] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.263724] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.264550] ? __schedule (kernel/sched/core.c:2806)
[ 3612.265354] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.266350] kthread (kernel/kthread.c:207)
[ 3612.267169] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.267878] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.268754] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.269359] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.269895] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.270537] cnic_wq         S ffff88012827fc28 29840  6142      2 0x10000000
[ 3612.271389]  ffff88012827fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.272364]  ffff8801533e0558 ffff8801533e0530 ffff88012825b008 ffff88079d1e8000
[ 3612.273328]  ffff88012825b000 ffff88012827fc08 ffff880128278000 ffffed002504f002
[ 3612.274568] Call Trace:
[ 3612.274852] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.275619] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.276112] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.276901] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.277792] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.278493] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.279128] ? __schedule (kernel/sched/core.c:2806)
[ 3612.279679] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.280268] kthread (kernel/kthread.c:207)
[ 3612.280880] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.281609] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.282408] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.283420] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.284068] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.284825] bnx2x           S ffff880128297c28 29840  6143      2 0x10000000
[ 3612.285772]  ffff880128297c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.286935]  ffff8801533e0558 ffff8801533e0530 ffff880128288008 ffff88079d1e8000
[ 3612.287816]  ffff880128288000 ffff880128297c08 ffff880128290000 ffffed0025052002
[ 3612.288665] Call Trace:
[ 3612.288920] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.289589] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.290093] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.290687] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.291291] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.291999] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.292636] ? __schedule (kernel/sched/core.c:2806)
[ 3612.293259] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.294054] kthread (kernel/kthread.c:207)
[ 3612.294696] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.295628] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.296237] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.296849] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.297492] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.298300] bnx2x_iov       S ffff88012829fc28 29840  6144      2 0x10000000
[ 3612.299074]  ffff88012829fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.299860]  ffff8801533e0558 ffff8801533e0530 ffff88012828b008 ffff88079d1e8000
[ 3612.300840]  ffff88012828b000 ffff88012829fc08 ffff880128298000 ffffed0025053002
[ 3612.301737] Call Trace:
[ 3612.302031] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.302637] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.303241] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.303777] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.304418] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.305301] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.306011] ? __schedule (kernel/sched/core.c:2806)
[ 3612.306574] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.307378] kthread (kernel/kthread.c:207)
[ 3612.307860] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.308505] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.309085] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.309717] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.310256] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.310932] mlx4            S ffff8801282afc28 29840  6184      2 0x10000000
[ 3612.311835]  ffff8801282afc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.312659]  ffff8801533e0558 ffff8801533e0530 ffff8801282a0008 ffff88079d1e8000
[ 3612.313489]  ffff8801282a0000 ffff8801282afc08 ffff8801282a8000 ffffed0025055002
[ 3612.314350] Call Trace:
[ 3612.314618] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.315252] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.315871] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.316433] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.317038] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.317773] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.318355] ? __schedule (kernel/sched/core.c:2806)
[ 3612.318922] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.319461] kthread (kernel/kthread.c:207)
[ 3612.319987] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.320648] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.321250] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.321900] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.322602] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.323332] mlx5_core_wq    S ffff8801282b7c28 29840  6186      2 0x10000000
[ 3612.324133]  ffff8801282b7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.324976]  ffff8801533e0558 ffff8801533e0530 ffff8801282a3008 ffff88079d1e8000
[ 3612.325889]  ffff8801282a3000 ffff8801282b7c08 ffff8801282b0000 ffffed0025056002
[ 3612.326679] Call Trace:
[ 3612.326934] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.327607] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.328128] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.328706] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.329379] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.329978] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.330925] ? __schedule (kernel/sched/core.c:2806)
[ 3612.331959] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.332968] kthread (kernel/kthread.c:207)
[ 3612.333872] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.335042] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.336150] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.337083] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.337978] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.339011] sfc_vfdi        S ffff8801282cfc28 29840  6214      2 0x10000000
[ 3612.340132]  ffff8801282cfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.341389]  ffff8801533e0558 ffff8801533e0530 ffff8801282c0008 ffff88079d1e8000
[ 3612.342702]  ffff8801282c0000 ffff8801282cfc08 ffff8801282c8000 ffffed0025059002
[ 3612.343950] Call Trace:
[ 3612.344336] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.345253] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.346414] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.347447] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.348529] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.349437] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.350302] ? __schedule (kernel/sched/core.c:2806)
[ 3612.351133] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.352003] kthread (kernel/kthread.c:207)
[ 3612.352996] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.354089] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.355039] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.356232] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.357119] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.358261] sfc_reset       S ffff8801282dfc28 29840  6215      2 0x10000000
[ 3612.359355]  ffff8801282dfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.360494]
[ 3612.360788]  ffff8801533e0558 ffff8801533e0530 ffff8801282c3008 ffff88079d1e8000
[ 3612.361939]  ffff8801282c3000 ffff8801282dfc08 ffff8801282d8000 ffffed002505b002
[ 3612.363572] Call Trace:
[ 3612.364271] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.365625] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.366797] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.367843] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.369029] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.369991] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.370950] ? __schedule (kernel/sched/core.c:2806)
[ 3612.371871] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.373103] kthread (kernel/kthread.c:207)
[ 3612.373913] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.375045] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.376533] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.377778] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.378663] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.379568] zd1211rw        S ffff8801282efc28 29840  6270      2 0x10000000
[ 3612.380928]  ffff8801282efc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.382271]  ffff8801533e0558 ffff8801533e0530 ffff8801282e0008 ffff88079d1e8000
[ 3612.383440]  ffff8801282e0000 ffff8801282efc08 ffff8801282e8000 ffffed002505d002
[ 3612.384767] Call Trace:
[ 3612.385401] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.386417] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.387166] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.387995] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.388915] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.389826] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.390817] ? __schedule (kernel/sched/core.c:2806)
[ 3612.391666] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.392739] kthread (kernel/kthread.c:207)
[ 3612.393562] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.394552] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.395992] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.396977] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.397823] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.398751] libertastf      S ffff8801282f7c28 29840  6290      2 0x10000000
[ 3612.399831]  ffff8801282f7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.401053]  ffff8801533e0558 ffff8801533e0530 ffff8801282e3008 ffff88079d1e8000
[ 3612.402394]  ffff8801282e3000 ffff8801282f7c08 ffff8801282f0000 ffffed002505e002
[ 3612.403644] Call Trace:
[ 3612.404022] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.405185] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.406206] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.407109] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.408130] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.409030] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.409853] ? __schedule (kernel/sched/core.c:2806)
[ 3612.410730] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.411554] kthread (kernel/kthread.c:207)
[ 3612.412428] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.413503] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.414458] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.415482] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.416281] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.417194] phy0            S ffff880128307c28 29840  6359      2 0x10000000
[ 3612.418355]  ffff880128307c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.419488]  ffff8801533e0558 ffff8801533e0530 ffff8801282f8008 ffff88079d1e8000
[ 3612.420666]  ffff8801282f8000 ffff880128307c08 ffff880128300000 ffffed0025060002
[ 3612.421862] Call Trace:
[ 3612.422337] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.423242] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.423979] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.424913] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.425900] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.426807] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.427696] ? __schedule (kernel/sched/core.c:2806)
[ 3612.428521] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.429356] kthread (kernel/kthread.c:207)
[ 3612.430096] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.431083] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.432013] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.433102] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.434014] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.435017] firewire        S ffff88012830fc28 29840  6420      2 0x10000000
[ 3612.436113]  ffff88012830fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.437272]  ffff8801533e0558 ffff8801533e0530 ffff8801282fb008 ffff88079d1e8000
[ 3612.438614]  ffff8801282fb000 ffff88012830fc08 ffff880128308000 ffffed0025061002
[ 3612.439764] Call Trace:
[ 3612.440139] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.441091] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.441868] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.442822] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.443780] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.444742] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.446046] ? __schedule (kernel/sched/core.c:2806)
[ 3612.446849] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.447729] kthread (kernel/kthread.c:207)
[ 3612.448577] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.449557] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.450484] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.451382] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.452283] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.453206] firewire_ohci   S ffff880128317c28 29840  6422      2 0x10000000
[ 3612.454392]  ffff880128317c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.455698]  ffff8801533e0558 ffff8801533e0530 ffff8800a61e3008 ffff88079d1e8000
[ 3612.456958]  ffff8800a61e3000 ffff880128317c08 ffff880128310000 ffffed0025062002
[ 3612.458387] Call Trace:
[ 3612.458778] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.459608] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.460378] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.461192] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.462198] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.463213] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.464170] ? __schedule (kernel/sched/core.c:2806)
[ 3612.465064] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.466499] kthread (kernel/kthread.c:207)
[ 3612.467351] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.468342] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.469249] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.470580] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.471394] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.472367] vfio-irqfd-clea S ffff880128327c28 29840  6441      2 0x10000000
[ 3612.474010]  ffff880128327c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.476151]  ffff8801533e0558 ffff8801533e0530 ffff880128318008 ffff88079d1e8000
[ 3612.478091]  ffff880128318000 ffff880128327c08 ffff880128320000 ffffed0025064002
[ 3612.479218] Call Trace:
[ 3612.479475] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.480084] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.480966] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.481861] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.482780] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.483757] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.484571] ? __schedule (kernel/sched/core.c:2806)
[ 3612.485395] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.486277] kthread (kernel/kthread.c:207)
[ 3612.487202] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.488183] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.488974] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.489574] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.490114] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.490894] aoe_tx0         S ffff880128337cb8 29064  6453      2 0x10000000
[ 3612.491699]  ffff880128337cb8 0000000000000000 ffffffffadc1fa42 0000000000000000
[ 3612.492720]  ffff8800533e0558 ffff8800533e0530 ffff88012831b008 ffff8801d0dd0000
[ 3612.493859]  ffff88012831b000 ffff880128337c98 ffff880128330000 ffffed0025066002
[ 3612.495101] Call Trace:
[ 3612.495540] ? kthread (kernel/kthread.c:198)
[ 3612.496395] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.497150] kthread (kernel/kthread.c:198)
[ 3612.497711] ? resend (drivers/block/aoe/aoecmd.c:1289)
[ 3612.498286] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.498805] ? resend (drivers/block/aoe/aoecmd.c:1289)
[ 3612.499289] kthread (kernel/kthread.c:207)
[ 3612.499759] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.500398] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.501011] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.501642] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.502264] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.503062] aoe_ktio0       S ffff880128347cb8 29984  6454      2 0x10000000
[ 3612.503818]  ffff880128347cb8 0000000000000000 ffffffffadc1fa42 0000000000000000
[ 3612.504886]  ffff8801533e0558 ffff8801533e0530 ffff880128338008 ffff88079d1e8000
[ 3612.506134]  ffff880128338000 ffff880128347c98 ffff880128340000 ffffed0025068002
[ 3612.507142] Call Trace:
[ 3612.507416] ? kthread (kernel/kthread.c:198)
[ 3612.507911] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.508446] kthread (kernel/kthread.c:198)
[ 3612.508917] ? resend (drivers/block/aoe/aoecmd.c:1289)
[ 3612.509413] ? wake_up_state (kernel/sched/core.c:2973)
[ 3612.509939] ? resend (drivers/block/aoe/aoecmd.c:1289)
[ 3612.510472] kthread (kernel/kthread.c:207)
[ 3612.510950] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.511548] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.512170] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.512810] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.513592] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.514342] u132            S ffff880128357c28 29840  6489      2 0x10000000
[ 3612.515691]  ffff880128357c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.516674]  ffff8801533e0558 ffff8801533e0530 ffff88012833b008 ffff88079d1e8000
[ 3612.517587]  ffff88012833b000 ffff880128357c08 ffff880128350000 ffffed002506a002
[ 3612.518388] Call Trace:
[ 3612.518627] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.519187] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.519671] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.520226] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.520922] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.521569] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.522219] ? __schedule (kernel/sched/core.c:2806)
[ 3612.523149] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.523982] kthread (kernel/kthread.c:207)
[ 3612.524814] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.525922] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.526633] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.527405] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.528058] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.528638] wusbd           S ffff880128367c28 29840  6499      2 0x10000000
[ 3612.529431]  ffff880128367c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.530235]  ffff8801533e0558 ffff8801533e0530 ffff880128358008 ffff88079d1e8000
[ 3612.531290]  ffff880128358000 ffff880128367c08 ffff880128360000 ffffed002506c002
[ 3612.532306] Call Trace:
[ 3612.532616] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.533458] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.534078] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.534792] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.535679] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.536385] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.536996] ? __schedule (kernel/sched/core.c:2806)
[ 3612.537692] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.538277] kthread (kernel/kthread.c:207)
[ 3612.538739] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.539311] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.539881] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.540700] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.541248] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.541916] appledisplay    S ffff880128377c28 29840  6650      2 0x10000000
[ 3612.542852]  ffff880128377c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.544043]  ffff8801533e0558 ffff8801533e0530 ffff88012835b008 ffff88079d1e8000
[ 3612.544859]  ffff88012835b000 ffff880128377c08 ffff880128370000 ffffed002506e002
[ 3612.546664] Call Trace:
[ 3612.547002] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.547694] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.548244] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.548769] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.549355] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.549943] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.550618] ? __schedule (kernel/sched/core.c:2806)
[ 3612.551136] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.551903] kthread (kernel/kthread.c:207)
[ 3612.552435] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.553319] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.554004] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.554610] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.555424] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.556308] ftdi-status-con S ffff88012837fc28 29840  6656      2 0x10000000
[ 3612.557090]  ffff88012837fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.557940]  ffff8801533e0558 ffff8801533e0530 ffff8801a6110008 ffff88079d1e8000
[ 3612.558719]  ffff8801a6110000 ffff88012837fc08 ffff880128378000 ffffed002506f002
[ 3612.559459] Call Trace:
[ 3612.559701] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.560265] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.560994] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.561690] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.562537] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.563315] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.564045] ? __schedule (kernel/sched/core.c:2806)
[ 3612.564834] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.565795] kthread (kernel/kthread.c:207)
[ 3612.566492] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.567157] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.567787] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.568449] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.568955] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.569541] ftdi-command-en S ffff880128387c28 29840  6657      2 0x10000000
[ 3612.570272]  ffff880128387c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.571252]  ffff8801533e0558 ffff8801533e0530 ffff8801a6090008 ffff88079d1e8000
[ 3612.572224]  ffff8801a6090000 ffff880128387c08 ffff880128380000 ffffed0025070002
[ 3612.573179] Call Trace:
[ 3612.573473] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.574300] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.574906] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.575570] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.576180] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.576946] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.577492] ? __schedule (kernel/sched/core.c:2806)
[ 3612.578344] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.578880] kthread (kernel/kthread.c:207)
[ 3612.579352] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.579956] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.580673] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.581266] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.581831] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.582705] ftdi-respond-en S ffff880128397c28 29840  6658      2 0x10000000
[ 3612.583925]  ffff880128397c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.584876]  ffff8801533e0558 ffff8801533e0530 ffff880128388008 ffff88079d1e8000
[ 3612.587157]  ffff880128388000 ffff880128397c08 ffff880128390000 ffffed0025072002
[ 3612.588640] Call Trace:
[ 3612.589009] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.589858] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.590694] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.591589] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.592747] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.593925] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.594481] ? __schedule (kernel/sched/core.c:2806)
[ 3612.595158] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.595927] kthread (kernel/kthread.c:207)
[ 3612.596411] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.596998] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.597976] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.598686] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.599187] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.599798] kpsmoused       S ffff88012839fc28 28920  6753      2 0x10000000
[ 3612.600993]  ffff88012839fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.602334]  ffff8801d11e0558 ffff8801d11e0530 ffff88012838b008 ffff8800256fb000
[ 3612.604238]  ffff88012838b000 ffff88012839fc08 ffff880128398000 ffffed0025073002
[ 3612.606294] Call Trace:
[ 3612.606711] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.608137] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.609079] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.609906] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3612.610929] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.611828] ? __schedule (kernel/sched/core.c:2806)
[ 3612.613201] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3612.614311] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.615307] kthread (kernel/kthread.c:207)
[ 3612.616051] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.617041] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.618113] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.618997] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.619772] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.620757] rc0             S ffff8801283afc48 30208  7076      2 0x10000000
[ 3612.621894]  ffff8801283afc48 0000000000000000 ffffffffae81316c 0000000000000000
[ 3612.623687]  ffff8801533e0558 ffff8801533e0530 ffff8801a605b008 ffff88079d1e8000
[ 3612.624999]  ffff8801a605b000 ffff8801283afc28 ffff8801283a8000 ffffed0025075002
[ 3612.626301] Call Trace:
[ 3612.626667] ? ir_raw_event_thread (drivers/media/rc/rc-ir-raw.c:53)
[ 3612.627621] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.628387] ir_raw_event_thread (drivers/media/rc/rc-ir-raw.c:41)
[ 3612.629251] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3612.630265] ? ir_raw_event_store_edge (drivers/media/rc/rc-ir-raw.c:35)
[ 3612.631257] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.632398] ? __schedule (kernel/sched/core.c:2806)
[ 3612.633513] ? ir_raw_event_store_edge (drivers/media/rc/rc-ir-raw.c:35)
[ 3612.634572] kthread (kernel/kthread.c:207)
[ 3612.635516] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.636429] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.637532] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.638866] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.639638] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.640593] pvrusb2-context S ffff8801283bfcc8 30336  7231      2 0x10000000
[ 3612.641857]  ffff8801283bfcc8 0000000000000009 0000000000000286 0000000000000000
[ 3612.643879]  ffff8801533e0558 ffff8801533e0530 ffff8801283b0008 ffff88079d1e8000
[ 3612.645382]  ffff8801283b0000 ffffffffb33d2540 ffff8801283b8000 ffffed0025077002
[ 3612.646979] Call Trace:
[ 3612.647593] ? pvr2_context_destroy (drivers/media/usb/pvrusb2/pvrusb2-context.c:163)
[ 3612.649046] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.649808] pvr2_context_thread_func (drivers/media/usb/pvrusb2/pvrusb2-context.c:173 (discriminator 17))
[ 3612.650904] ? pvr2_context_destroy (drivers/media/usb/pvrusb2/pvrusb2-context.c:163)
[ 3612.651906] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3612.653037] ? pvr2_context_destroy (drivers/media/usb/pvrusb2/pvrusb2-context.c:163)
[ 3612.654758] kthread (kernel/kthread.c:207)
[ 3612.655762] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.657002] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.658064] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.659244] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.660014] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.661087] raid5wq         S ffff8801283c7c28 29840  7457      2 0x10000000
[ 3612.662613]  ffff8801283c7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.664568]  ffff8801533e0558 ffff8801533e0530 ffff8801283b3008 ffff88079d1e8000
[ 3612.665887]  ffff8801283b3000 ffff8801283c7c08 ffff8801283c0000 ffffed0025078002
[ 3612.667033] Call Trace:
[ 3612.667527] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.668521] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.669248] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.670101] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.671046] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.671993] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.672944] ? __schedule (kernel/sched/core.c:2806)
[ 3612.673902] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.674756] kthread (kernel/kthread.c:207)
[ 3612.675546] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.676435] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.677524] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.678442] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.679216] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.680104] bcache          S ffff880051effc28 28920  7460      2 0x10000000
[ 3612.681263]  ffff880051effc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.682538]  ffff88007d3e0558 ffff88007d3e0530 ffff8800521f3008 ffff8802ccdd8000
[ 3612.683831]  ffff8800521f3000 ffff880051effc08 ffff880051ef8000 ffffed000a3df002
[ 3612.684999] Call Trace:
[ 3612.685396] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.686355] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.687360] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.688309] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.689199] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.690121] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.691122] ? __schedule (kernel/sched/core.c:2806)
[ 3612.692016] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.693138] kthread (kernel/kthread.c:207)
[ 3612.694313] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.695252] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.696223] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.697174] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.698148] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.699184] dm_bufio_cache  S ffff880051e07c28 29840  7471      2 0x10000000
[ 3612.700290]  ffff880051e07c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.701642]  ffff88007d3e0558 ffff88007d3e0530 ffff8800521f0008 ffff8802ccdd8000
[ 3612.703633]  ffff8800521f0000 ffff880051e07c08 ffff880051e00000 ffffed000a3c0002
[ 3612.705762] Call Trace:
[ 3612.706204] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.707301] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.708333] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.709202] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.710165] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.711229] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.712143] ? __schedule (kernel/sched/core.c:2806)
[ 3612.713317] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.715457] kthread (kernel/kthread.c:207)
[ 3612.716350] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.717410] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.718427] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.719326] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.720118] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.721070] kmpathd         S ffff880051e0fc28 29840  7474      2 0x10000000
[ 3612.722308]  ffff880051e0fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.724040]  ffff88007d3e0558 ffff88007d3e0530 ffff880051e5b008 ffff8802ccdd8000
[ 3612.726575]  ffff880051e5b000 ffff880051e0fc08 ffff880051e08000 ffffed000a3c1002
[ 3612.727530] Call Trace:
[ 3612.727861] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.728446] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.728927] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.729476] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.730073] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.730833] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.731423] ? __schedule (kernel/sched/core.c:2806)
[ 3612.732021] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.732661] kthread (kernel/kthread.c:207)
[ 3612.733288] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.733971] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.734549] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.735260] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.735782] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.736493] kmpath_handlerd S ffff880051e17c28 29840  7475      2 0x10000000
[ 3612.737254]  ffff880051e17c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.738093]  ffff88007d3e0558 ffff88007d3e0530 ffff880051e58008 ffff8802ccdd8000
[ 3612.738851]  ffff880051e58000 ffff880051e17c08 ffff880051e10000 ffffed000a3c2002
[ 3612.739605] Call Trace:
[ 3612.739852] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.740630] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.741127] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.741742] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.742405] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.743406] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.744155] ? __schedule (kernel/sched/core.c:2806)
[ 3612.744824] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.745531] kthread (kernel/kthread.c:207)
[ 3612.746042] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.746634] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.747262] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.747979] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.748530] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.749111] kvub300c        S ffff880051f0fc28 28920  7599      2 0x10000000
[ 3612.749893]  ffff880051f0fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.750708]  ffff88007d3e0558 ffff88007d3e0530 ffff88005219b008 ffff8802ccdd8000
[ 3612.751507]  ffff88005219b000 ffff880051f0fc08 ffff880051f08000 ffffed000a3e1002
[ 3612.752308] Call Trace:
[ 3612.752586] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.753379] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.753890] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.754647] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.755342] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.755989] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.756533] ? __schedule (kernel/sched/core.c:2806)
[ 3612.757355] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.758007] kthread (kernel/kthread.c:207)
[ 3612.758505] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.759084] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.759660] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.760258] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.760858] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.761532] kvub300p        S ffff880051f17c28 28920  7600      2 0x10000000
[ 3612.762265]  ffff880051f17c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.763136]  ffff8800a73e0558 ffff8800a73e0530 ffff880052a80008 ffff8803c8de8000
[ 3612.763923]  ffff880052a80000 ffff880051f17c08 ffff880051f10000 ffffed000a3e2002
[ 3612.764914] Call Trace:
[ 3612.765199] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.765846] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.766327] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.766891] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.767617] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.768264] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.768796] ? __schedule (kernel/sched/core.c:2806)
[ 3612.769320] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.769870] kthread (kernel/kthread.c:207)
[ 3612.770415] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.770999] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.771664] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.772278] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.772806] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.773454] kvub300d        S ffff880051f1fc28 29840  7601      2 0x10000000
[ 3612.774363]  ffff880051f1fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.775409]  ffff88007d3e0558 ffff88007d3e0530 ffff880051e98008 ffff8802ccdd8000
[ 3612.776228]  ffff880051e98000 ffff880051f1fc08 ffff880051f18000 ffffed000a3e3002
[ 3612.777085] Call Trace:
[ 3612.777378] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.778053] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.778565] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.779097] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.779676] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.780382] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.780962] ? __schedule (kernel/sched/core.c:2806)
[ 3612.781543] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.782163] kthread (kernel/kthread.c:207)
[ 3612.782756] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.783680] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.784548] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.785211] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.785871] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.786467] kmemstick       S ffff880051f2fc28 29304  7608      2 0x10000000
[ 3612.787390]  ffff880051f2fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.788260]  ffff88007d3e0558 ffff88007d3e0530 ffff880051f20008 ffff8802ccdd8000
[ 3612.789008]  ffff880051f20000 ffff880051f2fc08 ffff880051f28000 ffffed000a3e5002
[ 3612.789770] Call Trace:
[ 3612.790019] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.790749] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.791233] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.791857] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.792469] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.793267] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.794357] ? __schedule (kernel/sched/core.c:2806)
[ 3612.794889] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.795506] kthread (kernel/kthread.c:207)
[ 3612.796544] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.797157] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.797869] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.798581] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.799091] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.799666] ib_mcast        S ffff880051f37c28 29304  7645      2 0x10000000
[ 3612.800493]  ffff880051f37c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.801261]  ffff88007d3e0558 ffff88007d3e0530 ffff880051f23008 ffff8802ccdd8000
[ 3612.802476]  ffff880051f23000 ffff880051f37c08 ffff880051f30000 ffffed000a3e6002
[ 3612.804015] Call Trace:
[ 3612.804334] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.804970] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.805634] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.806506] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.807136] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.807896] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.808508] ? __schedule (kernel/sched/core.c:2806)
[ 3612.809031] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.809580] kthread (kernel/kthread.c:207)
[ 3612.810064] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.810945] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.811601] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.812349] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.813192] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.813875] ib_cm           S ffff880051f47c28 29304  7647      2 0x10000000
[ 3612.814662]  ffff880051f47c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.815802]  ffff88007d3e0558 ffff88007d3e0530 ffff880051f38008 ffff8802ccdd8000
[ 3612.816600]  ffff880051f38000 ffff880051f47c08 ffff880051f40000 ffffed000a3e8002
[ 3612.817392] Call Trace:
[ 3612.817703] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.818433] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.818908] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.819438] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.820020] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.820771] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.821389] ? __schedule (kernel/sched/core.c:2806)
[ 3612.821947] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.822649] kthread (kernel/kthread.c:207)
[ 3612.823162] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.823753] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.824487] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.825449] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.826162] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.826778] iw_cm_wq        S ffff880051f4fc28 29304  7648      2 0x10000000
[ 3612.827625]  ffff880051f4fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.828482]  ffff88007d3e0558 ffff88007d3e0530 ffff880051f3b008 ffff8802ccdd8000
[ 3612.829228]  ffff880051f3b000 ffff880051f4fc08 ffff880051f48000 ffffed000a3e9002
[ 3612.829981] Call Trace:
[ 3612.830300] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.830981] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.831504] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.832063] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.832698] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.833703] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.835019] ? __schedule (kernel/sched/core.c:2806)
[ 3612.835838] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.836921] kthread (kernel/kthread.c:207)
[ 3612.837567] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.838222] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.838805] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.839391] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.839894] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.840652] ib_addr         S ffff880051f5fc28 29304  7649      2 0x10000000
[ 3612.841477]  ffff880051f5fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.842747]  ffff88007d3e0558 ffff88007d3e0530 ffff880051f50008 ffff8802ccdd8000
[ 3612.843691]  ffff880051f50000 ffff880051f5fc08 ffff880051f58000 ffffed000a3eb002
[ 3612.844654] Call Trace:
[ 3612.844900] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.845700] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.846340] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.846926] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.847708] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.848433] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.848969] ? __schedule (kernel/sched/core.c:2806)
[ 3612.849500] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.850054] kthread (kernel/kthread.c:207)
[ 3612.850621] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.851197] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.851813] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.852420] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.852965] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.853688] rdma_cm         S ffff880051f67c28 29304  7650      2 0x10000000
[ 3612.854636]  ffff880051f67c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.855492]  ffff88007d3e0558 ffff88007d3e0530 ffff880051f53008 ffff8802ccdd8000
[ 3612.856347]  ffff880051f53000 ffff880051f67c08 ffff880051f60000 ffffed000a3ec002
[ 3612.857144] Call Trace:
[ 3612.857538] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.858211] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.858715] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.859246] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.859812] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.860444] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.861076] ? __schedule (kernel/sched/core.c:2806)
[ 3612.861602] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.862213] kthread (kernel/kthread.c:207)
[ 3612.862817] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.863546] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.864200] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.864862] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.865691] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.866402] mthca_catas     S ffff880051f7fc28 29840  7652      2 0x10000000
[ 3612.867861]  ffff880051f7fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.869236]  ffff88007d3e0558 ffff88007d3e0530 ffff880051f70008 ffff8802ccdd8000
[ 3612.870476]  ffff880051f70000 ffff880051f7fc08 ffff880051f78000 ffffed000a3ef002
[ 3612.871790] Call Trace:
[ 3612.872234] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.873290] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.874193] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.875478] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.876716] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.877721] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.878814] ? __schedule (kernel/sched/core.c:2806)
[ 3612.879611] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.880499] kthread (kernel/kthread.c:207)
[ 3612.881280] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.882468] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.884325] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.885795] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.886980] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.888400] iw_cxgb3        S ffff880051f87c28 29304  7658      2 0x10000000
[ 3612.889608]  ffff880051f87c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.890971]  ffff88007d3e0558 ffff88007d3e0530 ffff880051f73008 ffff8802ccdd8000
[ 3612.892174]  ffff880051f73000 ffff880051f87c08 ffff880051f80000 ffffed000a3f0002
[ 3612.894019] Call Trace:
[ 3612.894572] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.896192] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.897235] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.898258] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.899494] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.900512] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.901527] ? __schedule (kernel/sched/core.c:2806)
[ 3612.902673] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.904383] kthread (kernel/kthread.c:207)
[ 3612.906211] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.907308] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.908289] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.909193] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.910038] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.911000] iw_cxgb4        S ffff880051f8fc28 29840  7659      2 0x10000000
[ 3612.912382]  ffff880051f8fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.914804]  ffff88007d3e0558 ffff88007d3e0530 ffff8800a6293008 ffff8802ccdd8000
[ 3612.916753]  ffff8800a6293000 ffff880051f8fc08 ffff880051f88000 ffffed000a3f1002
[ 3612.918019] Call Trace:
[ 3612.918462] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.919327] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.920117] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.921007] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.923033] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.925090] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.926676] ? __schedule (kernel/sched/core.c:2806)
[ 3612.927345] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.928087] kthread (kernel/kthread.c:207)
[ 3612.928618] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.929195] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.929832] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.930731] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.931284] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.932181] mlx4_ib         S ffff880051f97c28 29840  7660      2 0x10000000
[ 3612.933093]  ffff880051f97c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.934477]  ffff88007d3e0558 ffff88007d3e0530 ffff8800a6263008 ffff8802ccdd8000
[ 3612.936429]  ffff8800a6263000 ffff880051f97c08 ffff880051f90000 ffffed000a3f2002
[ 3612.937945] Call Trace:
[ 3612.938413] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.938964] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.939448] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.939986] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.941039] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.941951] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.942620] ? __schedule (kernel/sched/core.c:2806)
[ 3612.943288] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.944276] kthread (kernel/kthread.c:207)
[ 3612.945028] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.946130] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.946848] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.947794] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.948472] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.949056] mlx4_ib_mcg     S ffff880051f9fc28 29840  7661      2 0x10000000
[ 3612.949784]  ffff880051f9fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.950550]  ffff88007d3e0558 ffff88007d3e0530 ffff8800a6260008 ffff8802ccdd8000
[ 3612.951330]  ffff8800a6260000 ffff880051f9fc08 ffff880051f98000 ffffed000a3f3002
[ 3612.952246] Call Trace:
[ 3612.952536] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.953164] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.953672] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.954760] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.956213] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.957035] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.957613] ? __schedule (kernel/sched/core.c:2806)
[ 3612.958499] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.959032] kthread (kernel/kthread.c:207)
[ 3612.959515] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.960159] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.960925] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.961675] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.962537] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.963333] mlx5_ib_page_fa S ffff880051fa7c28 29840  7662      2 0x10000000
[ 3612.964822]  ffff880051fa7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.966907]  ffff88007d3e0558 ffff88007d3e0530 ffff8800a6118008 ffff8802ccdd8000
[ 3612.967796]  ffff8800a6118000 ffff880051fa7c08 ffff880051fa0000 ffffed000a3f4002
[ 3612.968758] Call Trace:
[ 3612.969001] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.969594] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.970080] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.970903] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.971714] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.972724] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.973295] ? __schedule (kernel/sched/core.c:2806)
[ 3612.974184] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.974976] kthread (kernel/kthread.c:207)
[ 3612.975846] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.976622] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.977433] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.978159] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.978751] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.979329] nesewq          S ffff880051fb7c28 29840  7663      2 0x10000000
[ 3612.980041]  ffff880051fb7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3612.981106]  ffff88007d3e0558 ffff88007d3e0530 ffff880051fa8008 ffff8802ccdd8000
[ 3612.982422]  ffff880051fa8000 ffff880051fb7c08 ffff880051fb0000 ffffed000a3f6002
[ 3612.983563] Call Trace:
[ 3612.983976] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3612.985408] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3612.986531] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3612.987178] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3612.988190] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3612.989108] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.989772] ? __schedule (kernel/sched/core.c:2806)
[ 3612.990762] ? worker_thread (kernel/workqueue.c:2203)
[ 3612.991741] kthread (kernel/kthread.c:207)
[ 3612.992603] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.994132] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3612.995627] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.996972] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3612.997957] ? flush_kthread_work (kernel/kthread.c:176)
[ 3612.998971] nesdwq          S ffff880051fbfc28 29840  7664      2 0x10000000
[ 3613.000069]  ffff880051fbfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.001487]  ffff88007d3e0558 ffff88007d3e0530 ffff880051fab008 ffff8802ccdd8000
[ 3613.003416]  ffff880051fab000 ffff880051fbfc08 ffff880051fb8000 ffffed000a3f7002
[ 3613.005846] Call Trace:
[ 3613.006474] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.007598] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.008546] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.009431] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.010354] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.011257] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.012301] ? __schedule (kernel/sched/core.c:2806)
[ 3613.013174] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.014301] kthread (kernel/kthread.c:207)
[ 3613.015027] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.016070] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.017167] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.017952] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.018513] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.019184] ipoib           S ffff880051fcfc28 29840  7666      2 0x10000000
[ 3613.019981]  ffff880051fcfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.020862]  ffff88007d3e0558 ffff88007d3e0530 ffff880051fc0008 ffff8802ccdd8000
[ 3613.021722]  ffff880051fc0000 ffff880051fcfc08 ffff880051fc8000 ffffed000a3f9002
[ 3613.022517] Call Trace:
[ 3613.022878] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.023485] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.023991] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.024606] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.025453] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.027034] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.028001] ? __schedule (kernel/sched/core.c:2806)
[ 3613.028835] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.029742] kthread (kernel/kthread.c:207)
[ 3613.030574] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.031484] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.032423] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.033442] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.034438] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.035514] srp_remove      S ffff880051fd7c28 29840  7667      2 0x10000000
[ 3613.036716]  ffff880051fd7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.038165]  ffff88007d3e0558 ffff88007d3e0530 ffff880051fc3008 ffff8802ccdd8000
[ 3613.039329]  ffff880051fc3000 ffff880051fd7c08 ffff880051fd0000 ffffed000a3fa002
[ 3613.040633] Call Trace:
[ 3613.041015] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.041987] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.042823] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.043740] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.044624] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.045803] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.046703] ? __schedule (kernel/sched/core.c:2806)
[ 3613.047625] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.048509] kthread (kernel/kthread.c:207)
[ 3613.049236] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.050149] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.051193] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.052144] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.052937] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.053855] qat_device_rese S ffff880051fe7c28 29304  7677      2 0x10000000
[ 3613.055247]  ffff880051fe7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.056428]  ffff88007d3e0558 ffff88007d3e0530 ffff880051fd8008 ffff8802ccdd8000
[ 3613.057784]  ffff880051fd8000 ffff880051fe7c08 ffff880051fe0000 ffffed000a3fc002
[ 3613.058971] Call Trace:
[ 3613.059348] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.060186] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.060950] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.061804] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.062765] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.063670] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.064492] ? __schedule (kernel/sched/core.c:2806)
[ 3613.065489] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.066327] kthread (kernel/kthread.c:207)
[ 3613.067198] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.068153] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.069049] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.069951] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.070794] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.071721] elousb          S ffff880051fefc28 29304  7699      2 0x10000000
[ 3613.072813]  ffff880051fefc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.073978]  ffff88007d3e0558 ffff88007d3e0530 ffff880051fdb008 ffff8802ccdd8000
[ 3613.075261]  ffff880051fdb000 ffff880051fefc08 ffff880051fe8000 ffffed000a3fd002
[ 3613.076748] Call Trace:
[ 3613.077187] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.078147] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.078897] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.079710] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.080643] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.081530] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.082426] ? __schedule (kernel/sched/core.c:2806)
[ 3613.083279] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.084103] kthread (kernel/kthread.c:207)
[ 3613.084842] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.086037] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.087157] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.088122] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.088891] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.089810] speakup         S ffff880051807cc8 29304  7831      2 0x10000000
[ 3613.091103]  ffff880051807cc8 ffffffffb6d264e0 ffffffffb6d26530 ffff880000000000
[ 3613.092351]  ffff88007d3e0558 ffff88007d3e0530 ffff8800a6290008 ffff8802ccdd8000
[ 3613.093766]  ffff8800a6290000 ffff880051807ca8 ffff880051800000 ffffed000a300002
[ 3613.094986] Call Trace:
[ 3613.095451] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.096435] speakup_thread (drivers/staging/speakup/thread.c:41)
[ 3613.097402] ? synth_remove (drivers/staging/speakup/thread.c:12)
[ 3613.098287] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3613.099204] ? synth_remove (drivers/staging/speakup/thread.c:12)
[ 3613.100015] kthread (kernel/kthread.c:207)
[ 3613.100985] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.101945] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.103356] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.104924] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.106514] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.107613] k_mode_wimax    S ffff880051827cb8 29304  7850      2 0x10000000
[ 3613.109029]  ffff880051827cb8 0000000000000000 ffffffffb0553bf4 0000000000000000
[ 3613.110238]  ffff88007d3e0558 ffff88007d3e0530 ffff880051818008 ffff8802ccdd8000
[ 3613.111607]  ffff880051818000 ffff880051827c98 ffff880051820000 ffffed000a304002
[ 3613.113023] Call Trace:
[ 3613.113511] ? k_mode_thread (drivers/staging/gdm72xx/gdm_usb.c:744)
[ 3613.114610] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.115957] k_mode_thread (include/linux/spinlock.h:342 drivers/staging/gdm72xx/gdm_usb.c:744)
[ 3613.117005] ? gdm_usb_send_complete (drivers/staging/gdm72xx/gdm_usb.c:696)
[ 3613.118294] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3613.119262] ? gdm_usb_send_complete (drivers/staging/gdm72xx/gdm_usb.c:696)
[ 3613.120203] kthread (kernel/kthread.c:207)
[ 3613.121020] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.122432] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.123558] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.124510] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.125559] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.126728] exec-osm        S ffff880051857c28 29304  7918      2 0x10000000
[ 3613.127931]  ffff880051857c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.129180]  ffff88007d3e0558 ffff88007d3e0530 ffff880051848008 ffff8802ccdd8000
[ 3613.130456]  ffff880051848000 ffff880051857c08 ffff880051850000 ffffed000a30a002
[ 3613.131841] Call Trace:
[ 3613.132232] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.133416] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.134733] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.136242] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.137378] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.138430] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.139271] ? __schedule (kernel/sched/core.c:2806)
[ 3613.140081] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.140957] kthread (kernel/kthread.c:207)
[ 3613.141796] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.142744] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.144211] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.145541] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.147170] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.147768] block-osm       S ffff88005183fc28 29840  7925      2 0x10000000
[ 3613.148684]  ffff88005183fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.149477]  ffff88007d3e0558 ffff88007d3e0530 ffff88005184b008 ffff8802ccdd8000
[ 3613.150344]  ffff88005184b000 ffff88005183fc08 ffff880051838000 ffffed000a307002
[ 3613.151236] Call Trace:
[ 3613.151475] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.152026] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.152546] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.153205] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.153939] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.154560] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.155278] ? __schedule (kernel/sched/core.c:2806)
[ 3613.155903] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.156686] kthread (kernel/kthread.c:207)
[ 3613.157175] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.157778] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.158505] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.159082] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.159586] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.160200] binder          S ffff88005182fc28 28920  8090      2 0x10000000
[ 3613.161123]  ffff88005182fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.162037]  ffff88007d3e0558 ffff88007d3e0530 ffff88005181b008 ffff8802ccdd8000
[ 3613.162873]  ffff88005181b000 ffff88005182fc08 ffff880051828000 ffffed000a305002
[ 3613.163826] Call Trace:
[ 3613.164100] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.164676] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.165803] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.166768] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.167915] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.168838] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.169679] ? __schedule (kernel/sched/core.c:2806)
[ 3613.170564] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.171398] kthread (kernel/kthread.c:207)
[ 3613.172186] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.173442] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.175103] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.176900] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.178104] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.179079] ipv6_addrconf   S ffff88005187fc28 29840  8127      2 0x10000000
[ 3613.180165]  ffff88005187fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.181565]  ffff88007d3e0558 ffff88007d3e0530 ffff880051833008 ffff8802ccdd8000
[ 3613.183113]  ffff880051833000 ffff88005187fc08 ffff880051878000 ffffed000a30f002
[ 3613.184565] Call Trace:
[ 3613.185066] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.186424] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.187273] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.188217] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.189110] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.190014] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.190946] ? __schedule (kernel/sched/core.c:2806)
[ 3613.191853] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.192990] kthread (kernel/kthread.c:207)
[ 3613.195003] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.196450] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.197499] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.198551] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.199339] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.200258] krdsd           S ffff8800518a7c28 29840  8189      2 0x10000000
[ 3613.201605]  ffff8800518a7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.203258]  ffff88007d3e0558 ffff88007d3e0530 ffff8800518a8008 ffff8802ccdd8000
[ 3613.204861]  ffff8800518a8000 ffff8800518a7c08 ffff8800518a0000 ffffed000a314002
[ 3613.206725] Call Trace:
[ 3613.207136] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.208195] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.208994] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.209853] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.211042] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.212131] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.213392] ? __schedule (kernel/sched/core.c:2806)
[ 3613.214819] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.216516] kthread (kernel/kthread.c:207)
[ 3613.217576] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.218685] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.219579] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.220521] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.221379] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.222946] ceph-msgr       S ffff8800518cfc28 29840  8216      2 0x10000000
[ 3613.224241]  ffff8800518cfc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.225727]  ffff88007d3e0558 ffff88007d3e0530 ffff8800518ab008 ffff8802ccdd8000
[ 3613.227459]  ffff8800518ab000 ffff8800518cfc08 ffff8800518c8000 ffffed000a319002
[ 3613.228509] Call Trace:
[ 3613.228834] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.229447] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.229992] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.230706] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.231300] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.231919] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.232588] ? __schedule (kernel/sched/core.c:2806)
[ 3613.233433] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.234001] kthread (kernel/kthread.c:207)
[ 3613.234759] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.236717] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.237933] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.238915] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.239716] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.240799] kafs_vlupdated  S ffff8800518d7c28 29304  8226      2 0x10000000
[ 3613.242051]  ffff8800518d7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.243992]  ffff88007d3e0558 ffff88007d3e0530 ffff880051830008 ffff8802ccdd8000
[ 3613.245780]  ffff880051830000 ffff8800518d7c08 ffff8800518d0000 ffffed000a31a002
[ 3613.246896] Call Trace:
[ 3613.247143] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.247722] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.248270] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.248798] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.249446] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.250056] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.250682] ? __schedule (kernel/sched/core.c:2806)
[ 3613.251304] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.252080] kthread (kernel/kthread.c:207)
[ 3613.252583] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.253424] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.254288] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.254986] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.255715] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.256630] kafs_callbackd  S ffff8800518e7c28 29304  8227      2 0x10000000
[ 3613.257784]  ffff8800518e7c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.258749]  ffff88007d3e0558 ffff88007d3e0530 ffff8800518d8008 ffff8802ccdd8000
[ 3613.259523]  ffff8800518d8000 ffff8800518e7c08 ffff8800518e0000 ffffed000a31c002
[ 3613.260549] Call Trace:
[ 3613.261268] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.262445] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.263815] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.264995] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.266509] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.267625] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.268679] ? __schedule (kernel/sched/core.c:2806)
[ 3613.269572] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.270576] kthread (kernel/kthread.c:207)
[ 3613.271466] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.272864] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.274093] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.275552] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.276600] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.277808] kafsd           S ffff8800518efc28 29304  8228      2 0x10000000
[ 3613.279268]  ffff8800518efc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.280538]  ffff88007d3e0558 ffff88007d3e0530 ffff8800518db008 ffff8802ccdd8000
[ 3613.281851]  ffff8800518db000 ffff8800518efc08 ffff8800518e8000 ffffed000a31d002
[ 3613.284020] Call Trace:
[ 3613.284610] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.285910] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.286443] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.287059] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.287674] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.288352] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.288905] ? __schedule (kernel/sched/core.c:2806)
[ 3613.289651] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.290203] kthread (kernel/kthread.c:207)
[ 3613.290865] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.291484] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.292147] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.292810] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.293602] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.294327] bioset          S ffff8800518ffc28 29840  8241      2 0x10000000
[ 3613.295260]  ffff8800518ffc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.296515]  ffff88007d3e0558 ffff88007d3e0530 ffff8800518f0008 ffff8802ccdd8000
[ 3613.297356]  ffff8800518f0000 ffff8800518ffc08 ffff8800518f8000 ffffed000a31f002
[ 3613.298475] Call Trace:
[ 3613.298711] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.299279] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.299746] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.300527] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.301252] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.301993] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.302863] ? __schedule (kernel/sched/core.c:2806)
[ 3613.303668] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.304471] kthread (kernel/kthread.c:207)
[ 3613.305148] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.306179] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.306955] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.307655] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.308197] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.308845] deferwq         S ffff880051917c28 28920  8280      2 0x10000000
[ 3613.309608]  ffff880051917c28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.310534]  ffff8800a73e0558 ffff8800a73e0530 ffff880051e30008 ffff8803c8de8000
[ 3613.311383]  ffff880051e30000 ffff880051917c08 ffff880051910000 ffffed000a322002
[ 3613.312335] Call Trace:
[ 3613.312750] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.313686] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.314635] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.315579] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.316347] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.316962] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.317761] ? __schedule (kernel/sched/core.c:2806)
[ 3613.318383] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.318943] kthread (kernel/kthread.c:207)
[ 3613.319466] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.320054] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.321000] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.321644] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.322328] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.323189] charger_manager S ffff88005190fc28 29840  8283      2 0x10000000
[ 3613.324479]  ffff88005190fc28 0000000000000000 ffffffffa723c4d9 0000000000000000
[ 3613.326011]  ffff88007d3e0558 ffff88007d3e0530 ffff880051918008 ffff8802ccdd8000
[ 3613.326824]  ffff880051918000 ffff88005190fc08 ffff880051908000 ffffed000a321002
[ 3613.327653] Call Trace:
[ 3613.327937] ? rescuer_thread (kernel/workqueue.c:2301)
[ 3613.328480] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.328944] rescuer_thread (kernel/workqueue.c:2217 (discriminator 8))
[ 3613.329493] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[ 3613.330084] ? finish_task_switch (kernel/sched/sched.h:1070 kernel/sched/core.c:2230)
[ 3613.330800] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.331362] ? __schedule (kernel/sched/core.c:2806)
[ 3613.332111] ? worker_thread (kernel/workqueue.c:2203)
[ 3613.332951] kthread (kernel/kthread.c:207)
[ 3613.333936] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.334788] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.335707] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.336545] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.337207] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.337871] sh              S ffff88001da6fd08 26376  8301      1 0x10000000
[ 3613.338621]  ffff88001da6fd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.339458]  ffff8800261e0558 ffff8800261e0530 ffff880000c80008 ffffffffb4839100
[ 3613.340263]  ffff880000c80000 ffff880000c80000 ffff88001da68000 ffffed0003b4d002
[ 3613.341176] Call Trace:
[ 3613.341495] ? do_wait (kernel/exit.c:1504)
[ 3613.342187] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.342814] do_wait (kernel/exit.c:1509)
[ 3613.343664] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.344620] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.345559] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.346460] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.347159] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.347760] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.348409] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.348984] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.349615] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.350341] runtrin.sh      S ffff88001da7fd08 25872  8302   8301 0x10000000
[ 3613.351427]  ffff88001da7fd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.352504]  ffff88007d3e0558 ffff88007d3e0530 ffff880000c83008 ffff8802cc1c3000
[ 3613.353627]  ffff880000c83000 ffff880000c83000 ffff88001da78000 ffffed0003b4f002
[ 3613.354509] Call Trace:
[ 3613.355017] ? do_wait (kernel/exit.c:1504)
[ 3613.355696] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.356264] do_wait (kernel/exit.c:1509)
[ 3613.357001] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.357759] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.358464] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.359083] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.359626] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.360116] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.360783] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.361509] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3613.362248] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.362925] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.363528] irqbalance      S ffff8800c9e17c88 27608  8308      1 0x10000000
[ 3613.364252]  ffff8800c9e17c88 0000000000000000 000000025264db20 0000000000000000
[ 3613.365132]  ffff88024f3e0558 ffff88024f3e0530 ffff8800ca0eb008 ffff88017cdd0000
[ 3613.366018]  ffff8800ca0eb000 ffff8800c9e17c68 ffff8800c9e10000 ffffed00193c2002
[ 3613.366798] Call Trace:
[ 3613.367056] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.367588] do_nanosleep (./arch/x86/include/asm/current.h:14 include/linux/freezer.h:120 include/linux/freezer.h:172 kernel/time/hrtimer.c:1502)
[ 3613.368196] ? schedule_timeout_uninterruptible (kernel/time/hrtimer.c:1492)
[ 3613.368869] ? memset (mm/kasan/kasan.c:269)
[ 3613.369347] hrtimer_nanosleep (kernel/time/hrtimer.c:1571)
[ 3613.369945] ? hrtimer_run_queues (kernel/time/hrtimer.c:1559)
[ 3613.370671] ? hrtimer_get_res (kernel/time/hrtimer.c:1472)
[ 3613.371307] ? do_nanosleep (kernel/time/hrtimer.c:1024 (discriminator 1) include/linux/hrtimer.h:376 (discriminator 1) kernel/time/hrtimer.c:1497 (discriminator 1))
[ 3613.371981] SyS_nanosleep (kernel/time/hrtimer.c:1609 kernel/time/hrtimer.c:1598)
[ 3613.372571] ? hrtimer_nanosleep (kernel/time/hrtimer.c:1598)
[ 3613.373132] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.373778] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.374319] runtrin.sh      S ffff88022341fd08 26216  8613   8302 0x10000000
[ 3613.375143]  ffff88022341fd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.376227]  ffff8800261e0558 ffff8800261e0530 ffff880223fcb008 ffffffffb4839100
[ 3613.377088]  ffff880223fcb000 ffff880223fcb000 ffff880223418000 ffffed0044683002
[ 3613.378003] Call Trace:
[ 3613.378250] ? do_wait (kernel/exit.c:1504)
[ 3613.378740] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.379217] do_wait (kernel/exit.c:1509)
[ 3613.379727] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.380370] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.380993] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.381655] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.382281] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.382800] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3613.383381] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.383901] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.384491] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3613.385387] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.386346] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.386933] kworker/u64:1   S ffff8802cc887ce8 24680  8841      2 0x10000000
[ 3613.387742]  ffff8802cc887ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.388507]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cc1ab008 ffff8802cc1fb000
[ 3613.389250]  ffff8802cc1ab000 ffff8802cc887cc8 ffff8802cc880000 ffffed0059910002
[ 3613.390001] Call Trace:
[ 3613.390308] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.390861] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.391380] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.391939] ? __schedule (kernel/sched/core.c:2806)
[ 3613.392524] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.393117] kthread (kernel/kthread.c:207)
[ 3613.393601] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.394460] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.395160] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.395873] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.396386] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.397008] kworker/u80:1   S ffff88024e4afce8 29304  8866      2 0x10000000
[ 3613.397752]  ffff88024e4afce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.398533]  ffff88024f3e0558 ffff88024f3e0530 ffff88024dcbb008 ffff880223dd3000
[ 3613.399282]  ffff88024dcbb000 ffff88024e4afcc8 ffff88024e4a8000 ffffed0049c95002
[ 3613.400031] Call Trace:
[ 3613.400305] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.400867] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.401347] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.402030] ? __schedule (kernel/sched/core.c:2806)
[ 3613.402597] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.403303] kthread (kernel/kthread.c:207)
[ 3613.403788] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.404374] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.405125] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.405928] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.406448] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.407131] kworker/u68:1   S ffff88001da8fce8 29112  8867      2 0x10000000
[ 3613.407976]  ffff88001da8fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.408914]  ffff8800261e0558 ffff8800261e0530 ffff880021008008 ffffffffb4839100
[ 3613.409670]  ffff880021008000 ffff88001da8fcc8 ffff88001da88000 ffffed0003b51002
[ 3613.410557] Call Trace:
[ 3613.410845] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.411379] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.411949] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.412614] ? __schedule (kernel/sched/core.c:2806)
[ 3613.413227] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.413825] kthread (kernel/kthread.c:207)
[ 3613.414372] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.414997] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.416020] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.416639] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.417478] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.418221] kworker/u73:1   S ffff880127897ce8 29112  8868      2 0x10000000
[ 3613.418960]  ffff880127897ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.419705]  ffff8801291e0558 ffff8801291e0530 ffff880127c1b008 ffff88065d1d8000
[ 3613.420556]  ffff880127c1b000 ffff880127897cc8 ffff880127890000 ffffed0024f12002
[ 3613.421748] Call Trace:
[ 3613.422001] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.422767] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.423295] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.423828] ? __schedule (kernel/sched/core.c:2806)
[ 3613.424714] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.425559] kthread (kernel/kthread.c:207)
[ 3613.426216] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.426939] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.427560] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.428290] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.428808] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.429388] kworker/u74:1   S ffff880152257ce8 26640  8882      2 0x10000000
[ 3613.430207]  ffff880152257ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.431158]  ffff8801533e0558 ffff8801533e0530 ffff880151c58008 ffff88079d1e8000
[ 3613.432039]  ffff880151c58000 ffff880152257cc8 ffff880152250000 ffffed002a44a002
[ 3613.432846] Call Trace:
[ 3613.433110] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.433733] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.434438] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.435195] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.436284] kthread (kernel/kthread.c:207)
[ 3613.436854] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.437695] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.438320] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.438909] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.439406] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.439967] kworker/u78:1   S ffff8801f9e77ce8 30368  8897      2 0x10000000
[ 3613.440965]  ffff8801f9e77ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.441963]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fa7a3008 ffff880052dc8000
[ 3613.442992]  ffff8801fa7a3000 ffff8801f9e77cc8 ffff8801f9e70000 ffffed003f3ce002
[ 3613.443826] Call Trace:
[ 3613.444175] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.444879] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.445477] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.446243] ? __schedule (kernel/sched/core.c:2806)
[ 3613.446829] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.447579] kthread (kernel/kthread.c:207)
[ 3613.448152] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.448724] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.449282] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.449921] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.450659] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.451320] kworker/u71:1   S ffff8800a5c47ce8 29304  8944      2 0x10000000
[ 3613.452275]  ffff8800a5c47ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.453405]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a611b008 ffff8803c8de8000
[ 3613.454204]  ffff8800a611b000 ffff8800a5c47cc8 ffff8800a5c40000 ffffed0014b88002
[ 3613.455300] Call Trace:
[ 3613.455669] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.456583] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.457381] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.458036] ? __schedule (kernel/sched/core.c:2806)
[ 3613.458631] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.459196] kthread (kernel/kthread.c:207)
[ 3613.459661] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.460230] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.460988] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.461603] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.462235] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.462816] kworker/u75:1   S ffff88017bc7fce8 30256  8969      2 0x10000000
[ 3613.463687]  ffff88017bc7fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.464805]  ffff88017d3e0558 ffff88017d3e0530 ffff88017bc98008 ffff8808dd1e0000
[ 3613.466157]  ffff88017bc98000 ffff88017bc7fcc8 ffff88017bc78000 ffffed002f78f002
[ 3613.467185] Call Trace:
[ 3613.467455] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.468285] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.468746] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.469255] ? __schedule (kernel/sched/core.c:2806)
[ 3613.469774] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.470385] kthread (kernel/kthread.c:207)
[ 3613.470967] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.471632] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.472244] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.472860] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.473447] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.474093] kworker/u81:1   S ffff88027818fce8 30256  8988      2 0x10000000
[ 3613.475132]  ffff88027818fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.475921]  ffff8802791e0558 ffff8802791e0530 ffff88027809b008 ffff880224dd0000
[ 3613.476653]  ffff88027809b000 ffff88027818fcc8 ffff880278188000 ffffed004f031002
[ 3613.477589] Call Trace:
[ 3613.477877] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.478655] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.479128] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.479642] ? __schedule (kernel/sched/core.c:2806)
[ 3613.480202] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.480908] kthread (kernel/kthread.c:207)
[ 3613.481443] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.482104] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.482692] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.483318] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.483994] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.484774] kworker/u77:1   S ffff8801cfd17ce8 29112  8989      2 0x10000000
[ 3613.485759]  ffff8801cfd17ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.486513]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0088008 ffff8800256fb000
[ 3613.487411]  ffff8801d0088000 ffff8801cfd17cc8 ffff8801cfd10000 ffffed0039fa2002
[ 3613.488295] Call Trace:
[ 3613.488561] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.489086] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.489620] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.490142] ? __schedule (kernel/sched/core.c:2806)
[ 3613.490678] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.491341] kthread (kernel/kthread.c:207)
[ 3613.491872] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.492460] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.493040] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.493617] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.494262] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.495084] kworker/u72:1   S ffff8800c9c07ce8 30368  8991      2 0x10000000
[ 3613.495907]  ffff8800c9c07ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.496650]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800ca2bb008 ffff880518df0000
[ 3613.497517]  ffff8800ca2bb000 ffff8800c9c07cc8 ffff8800c9c00000 ffffed0019380002
[ 3613.498417] Call Trace:
[ 3613.498654] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.499189] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.499657] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.500307] ? __schedule (kernel/sched/core.c:2806)
[ 3613.500968] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.501580] kthread (kernel/kthread.c:207)
[ 3613.502545] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.503268] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.503918] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.504695] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.505579] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.506648] kworker/u66:1   S ffff88031fd47ce8 24680  8994      2 0x10000000
[ 3613.507547]  ffff88031fd47ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.508457]  ffff8803211e0558 ffff8803211e0530 ffff88031fc7b008 ffff8802ae7e0000
[ 3613.509194]  ffff88031fc7b000 ffff88031fd47cc8 ffff88031fd40000 ffffed0063fa8002
[ 3613.509996] Call Trace:
[ 3613.510289] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.510901] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.511557] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.512224] ? __schedule (kernel/sched/core.c:2806)
[ 3613.513081] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.513763] kthread (kernel/kthread.c:207)
[ 3613.514503] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.515452] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.516468] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.517704] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.518348] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.518943] kworker/u85:1   S ffff88032018fce8 29112  9004      2 0x10000000
[ 3613.519735]  ffff88032018fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.520750]  ffff8803211e0558 ffff8803211e0530 ffff88031fc78008 ffff88007b83b000
[ 3613.521792]  ffff88031fc78000 ffff88032018fcc8 ffff880320188000 ffffed0064031002
[ 3613.523127] Call Trace:
[ 3613.523583] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.524623] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.525398] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.526241] ? __schedule (kernel/sched/core.c:2806)
[ 3613.526887] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.527490] kthread (kernel/kthread.c:207)
[ 3613.528041] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.528634] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.529233] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.529932] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.530887] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.531599] kworker/u69:1   S ffff880051467ce8 30256  9015      2 0x10000000
[ 3613.532349]  ffff880051467ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.533633]  ffff8800533e0558 ffff8800533e0530 ffff880051423008 ffff8801d0dd0000
[ 3613.535009]  ffff880051423000 ffff880051467cc8 ffff880051460000 ffffed000a28c002
[ 3613.536333] Call Trace:
[ 3613.536643] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.537267] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.537922] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.538576] ? __schedule (kernel/sched/core.c:2806)
[ 3613.539091] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3613.539709] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.540864] kthread (kernel/kthread.c:207)
[ 3613.541496] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.542179] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.543120] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.544015] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.544698] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.545611] kworker/u53:1   S ffff8800c9e57ce8 28640  9019      2 0x10000000
[ 3613.546645]  ffff8800c9e57ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.547536]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800c9e58008 ffff880278120000
[ 3613.548612]  ffff8800c9e58000 ffff8800c9e57cc8 ffff8800c9e50000 ffffed00193ca002
[ 3613.549362] Call Trace:
[ 3613.549602] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.550135] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.550852] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.551474] ? __schedule (kernel/sched/core.c:2806)
[ 3613.552079] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.552789] kthread (kernel/kthread.c:207)
[ 3613.553581] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.554353] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.555138] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.555904] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.556495] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.557234] kworker/u60:1   S ffff880223dafce8 26368  9062      2 0x10000000
[ 3613.558188]  ffff880223dafce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.558966]  ffff8802253e0558 ffff8802253e0530 ffff880223d78008 ffff88013ef13000
[ 3613.559711]  ffff880223d78000 ffff880223dafcc8 ffff880223da8000 ffffed00447b5002
[ 3613.560638] Call Trace:
[ 3613.560939] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.561694] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.562345] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.563169] ? __schedule (kernel/sched/core.c:2806)
[ 3613.563890] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.564703] kthread (kernel/kthread.c:207)
[ 3613.565374] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.566044] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.566612] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.567250] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.567751] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.568485] runtrin.sh      S ffff8802f5c87d08 29144  9063   8302 0x10000000
[ 3613.569177]  ffff8802f5c87d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.569953]  ffff8803211e0558 ffff8803211e0530 ffff8802f6b9b008 ffff8802a202b000
[ 3613.570905]  ffff8802f6b9b000 ffff8802f6b9b000 ffff8802f5c80000 ffffed005eb90002
[ 3613.571895] Call Trace:
[ 3613.572144] ? do_wait (kernel/exit.c:1504)
[ 3613.572750] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.573328] do_wait (kernel/exit.c:1509)
[ 3613.573872] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.574640] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.575527] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.576239] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.576789] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.577298] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.577894] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.578533] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.579133] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.579711] trinity         S ffff880320197d08 25720  9065   9063 0x10000000
[ 3613.580438]  ffff880320197d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.581199]  ffff8801533e0558 ffff8801533e0530 ffff88031fd0b008 ffff88079d1e8000
[ 3613.582250]  ffff88031fd0b000 ffff88031fd0b000 ffff880320190000 ffffed0064032002
[ 3613.583380] Call Trace:
[ 3613.583669] ? do_wait (kernel/exit.c:1504)
[ 3613.584302] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.584996] do_wait (kernel/exit.c:1509)
[ 3613.586540] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.587724] ? find_get_pid (include/linux/rcupdate.h:969 kernel/pid.c:495)
[ 3613.588669] ? find_get_pid (kernel/pid.c:490)
[ 3613.589495] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.590298] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.591338] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.592516] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.593620] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.594553] kworker/u65:1   S ffff8802f6187ce8 28640  9084      2 0x10000000
[ 3613.596708]  ffff8802f6187ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.598857]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6b00008 ffff880278e0b000
[ 3613.600079]  ffff8802f6b00000 ffff8802f6187cc8 ffff8802f6180000 ffffed005ec30002
[ 3613.601395] Call Trace:
[ 3613.601768] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.603291] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.604435] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.606393] ? __schedule (kernel/sched/core.c:2806)
[ 3613.608216] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.609389] kthread (kernel/kthread.c:207)
[ 3613.610132] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.611171] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.612368] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.613799] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.614901] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.616563] trinity-watchdo S ffff88015194fc88 28584  9085   9065 0x10000000
[ 3613.617922]  ffff88015194fc88 0000000000000000 000000003b9aca00 0000000000000000
[ 3613.619170]  ffff8802a33e0558 ffff8802a33e0530 ffff880152928008 ffff8802ccde0000
[ 3613.620417]  ffff880152928000 ffff88015194fc68 ffff880151948000 ffffed002a329002
[ 3613.621753] Call Trace:
[ 3613.622253] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.623484] do_nanosleep (./arch/x86/include/asm/current.h:14 include/linux/freezer.h:120 include/linux/freezer.h:172 kernel/time/hrtimer.c:1502)
[ 3613.624737] ? schedule_timeout_uninterruptible (kernel/time/hrtimer.c:1492)
[ 3613.627026] ? memset (mm/kasan/kasan.c:269)
[ 3613.628240] hrtimer_nanosleep (kernel/time/hrtimer.c:1571)
[ 3613.629099] ? hrtimer_run_queues (kernel/time/hrtimer.c:1559)
[ 3613.630826] ? hrtimer_get_res (kernel/time/hrtimer.c:1472)
[ 3613.631828] ? do_nanosleep (kernel/time/hrtimer.c:1024 (discriminator 1) include/linux/hrtimer.h:376 (discriminator 1) kernel/time/hrtimer.c:1497 (discriminator 1))
[ 3613.632742] SyS_nanosleep (kernel/time/hrtimer.c:1609 kernel/time/hrtimer.c:1598)
[ 3613.633984] ? hrtimer_nanosleep (kernel/time/hrtimer.c:1598)
[ 3613.635542] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.636937] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.638013] trinity-main    S ffff880151867d08 26616  9086   9065 0x10000000
[ 3613.639226]  ffff880151867d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.640547]  ffff88017d3e0558 ffff88017d3e0530 ffff880151d18008 ffff8808dd1e0000
[ 3613.642025]  ffff880151d18000 ffff880151d18000 ffff880151860000 ffffed002a30c002
[ 3613.644101] Call Trace:
[ 3613.644934] ? do_wait (kernel/exit.c:1504)
[ 3613.646948] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.648497] do_wait (kernel/exit.c:1509)
[ 3613.649640] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.650762] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.651839] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.652831] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.653646] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.654577] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3613.656107] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.657820] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.659274] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3613.660306] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.661477] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.662432] kworker/u66:2   S ffff88031fec7ce8 29112  9100      2 0x10000000
[ 3613.663595]  ffff88031fec7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.665253]  ffff8803211e0558 ffff8803211e0530 ffff88031fd08008 ffff88060d230000
[ 3613.666766]  ffff88031fd08000 ffff88031fec7cc8 ffff88031fec0000 ffffed0063fd8002
[ 3613.668145] Call Trace:
[ 3613.668546] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.669396] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.670123] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.671024] ? __schedule (kernel/sched/core.c:2806)
[ 3613.671878] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:51)
[ 3613.672805] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.673783] kthread (kernel/kthread.c:207)
[ 3613.674854] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.676370] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.677715] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.679125] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.679905] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.681005] kworker/u63:1   S ffff8802a28a7ce8 29488  9101      2 0x10000000
[ 3613.682204]  ffff8802a28a7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.683420]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a1ca8008 ffff8802c16db000
[ 3613.684643]  ffff8802a1ca8000 ffff8802a28a7cc8 ffff8802a28a0000 ffffed0054514002
[ 3613.686162] Call Trace:
[ 3613.686670] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.687619] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.688390] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.689214] ? __schedule (kernel/sched/core.c:2806)
[ 3613.690040] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.691015] kthread (kernel/kthread.c:207)
[ 3613.691804] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.692724] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.694298] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.695447] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.696291] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.697167] runtrin.sh      S ffff8802a1c8fd08 29640  9154   8302 0x10000000
[ 3613.698021]  ffff8802a1c8fd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.698836]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802a1c93008 ffff8803c8df0000
[ 3613.699597]  ffff8802a1c93000 ffff8802a1c93000 ffff8802a1c88000 ffffed0054391002
[ 3613.700885] Call Trace:
[ 3613.701267] ? do_wait (kernel/exit.c:1504)
[ 3613.702238] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.703202] do_wait (kernel/exit.c:1509)
[ 3613.704026] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.705700] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.707378] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.708461] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.709303] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.710085] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.710975] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.711928] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.713113] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.715307] trinity         S ffff8802cc1a7d08 26232  9156   9154 0x10000000
[ 3613.717828]  ffff8802cc1a7d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.719258]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cc1a8008 ffff8803c8df0000
[ 3613.720670]  ffff8802cc1a8000 ffff8802cc1a8000 ffff8802cc1a0000 ffffed0059834002
[ 3613.722043] Call Trace:
[ 3613.722474] ? do_wait (kernel/exit.c:1504)
[ 3613.723264] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.724038] do_wait (kernel/exit.c:1509)
[ 3613.724812] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.726617] ? find_get_pid (include/linux/rcupdate.h:969 kernel/pid.c:495)
[ 3613.727621] ? find_get_pid (kernel/pid.c:490)
[ 3613.728539] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.729292] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.730122] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.731179] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.732160] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.733065] trinity-watchdo S ffff8802cc257c88 28712  9193   9156 0x10000000
[ 3613.734335]  ffff8802cc257c88 0000000000000000 000000003b9aca00 0000000000000000
[ 3613.736830]  ffff8802f73e0558 ffff8802f73e0530 ffff8802cc1c0008 ffff880518df8000
[ 3613.738729]  ffff8802cc1c0000 ffff8802cc257c68 ffff8802cc250000 ffffed005984a002
[ 3613.739902] Call Trace:
[ 3613.740330] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.741262] do_nanosleep (./arch/x86/include/asm/current.h:14 include/linux/freezer.h:120 include/linux/freezer.h:172 kernel/time/hrtimer.c:1502)
[ 3613.742207] ? schedule_timeout_uninterruptible (kernel/time/hrtimer.c:1492)
[ 3613.744261] ? memset (mm/kasan/kasan.c:269)
[ 3613.745303] hrtimer_nanosleep (kernel/time/hrtimer.c:1571)
[ 3613.747511] ? hrtimer_run_queues (kernel/time/hrtimer.c:1559)
[ 3613.748466] ? hrtimer_get_res (kernel/time/hrtimer.c:1472)
[ 3613.749299] ? do_nanosleep (kernel/time/hrtimer.c:1024 (discriminator 1) include/linux/hrtimer.h:376 (discriminator 1) kernel/time/hrtimer.c:1497 (discriminator 1))
[ 3613.750215] SyS_nanosleep (kernel/time/hrtimer.c:1609 kernel/time/hrtimer.c:1598)
[ 3613.751342] ? hrtimer_nanosleep (kernel/time/hrtimer.c:1598)
[ 3613.752528] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.753987] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.755288] trinity-main    S ffff8802cc327d08 26616  9194   9156 0x10000000
[ 3613.757047]  ffff8802cc327d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.758402]  ffff8800a73e0558 ffff8800a73e0530 ffff8802cc1c3008 ffff8803c8de8000
[ 3613.759581]  ffff8802cc1c3000 ffff8802cc1c3000 ffff8802cc320000 ffffed0059864002
[ 3613.760933] Call Trace:
[ 3613.761343] ? do_wait (kernel/exit.c:1504)
[ 3613.762206] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.763164] do_wait (kernel/exit.c:1509)
[ 3613.763944] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.765030] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.767137] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.767978] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.768604] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.769087] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3613.769692] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.771726] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.772325] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3613.772964] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.773640] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.774802] runtrin.sh      S ffff8800a6357d08 29144  9260   8302 0x10000000
[ 3613.775987]  ffff8800a6357d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.777033]  ffff8801291e0558 ffff8801291e0530 ffff8800a6208008 ffff88065d1d8000
[ 3613.777979]  ffff8800a6208000 ffff8800a6208000 ffff8800a6350000 ffffed0014c6a002
[ 3613.778831] Call Trace:
[ 3613.779073] ? do_wait (kernel/exit.c:1504)
[ 3613.779568] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.780091] do_wait (kernel/exit.c:1509)
[ 3613.780824] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.781584] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.782319] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.783019] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.783550] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.784295] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.785082] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.786227] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.787204] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.787991] trinity         S ffff88012785fd08 25832  9262   9260 0x10000000
[ 3613.788820]  ffff88012785fd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.789731]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801278c8008 ffff880052dc8000
[ 3613.790594]  ffff8801278c8000 ffff8801278c8000 ffff880127858000 ffffed0024f0b002
[ 3613.791483] Call Trace:
[ 3613.791726] ? do_wait (kernel/exit.c:1504)
[ 3613.792282] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.792778] do_wait (kernel/exit.c:1509)
[ 3613.793259] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.793967] ? find_get_pid (include/linux/rcupdate.h:969 kernel/pid.c:495)
[ 3613.794638] ? find_get_pid (kernel/pid.c:490)
[ 3613.795449] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.796561] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.797613] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.798603] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.799527] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.800720] kworker/7:1H    S ffff88017c1ffce8 29112  9279      2 0x10000000
[ 3613.801813]  ffff88017c1ffce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.803109]  ffff88017d3e0558 ffff88017d3e0530 ffff88017c193008 ffff8808dd1e0000
[ 3613.804423]  ffff88017c193000 ffff88017c1ffcc8 ffff88017c1f8000 ffffed002f83f002
[ 3613.806417] Call Trace:
[ 3613.806856] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.807766] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.808696] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.809510] ? __schedule (kernel/sched/core.c:2806)
[ 3613.810380] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.811480] kthread (kernel/kthread.c:207)
[ 3613.812222] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.813234] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.814237] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.816225] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.817779] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.818875] trinity-watchdo S ffff8801fa297c88 28128  9306   9262 0x10000000
[ 3613.819940]  ffff8801fa297c88 0000000000000000 000000003b9aca00 0000000000000000
[ 3613.821309]  ffff8802253e0558 ffff8802253e0530 ffff8801fa7a0008 ffff8800a6dd0000
[ 3613.822549]  ffff8801fa7a0000 ffff8801fa297c68 ffff8801fa290000 ffffed003f452002
[ 3613.823714] Call Trace:
[ 3613.824116] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.825382] do_nanosleep (./arch/x86/include/asm/current.h:14 include/linux/freezer.h:120 include/linux/freezer.h:172 kernel/time/hrtimer.c:1502)
[ 3613.826403] ? schedule_timeout_uninterruptible (kernel/time/hrtimer.c:1492)
[ 3613.827731] ? memset (mm/kasan/kasan.c:269)
[ 3613.828527] hrtimer_nanosleep (kernel/time/hrtimer.c:1571)
[ 3613.829386] ? hrtimer_run_queues (kernel/time/hrtimer.c:1559)
[ 3613.830347] ? hrtimer_get_res (kernel/time/hrtimer.c:1472)
[ 3613.831480] ? do_nanosleep (kernel/time/hrtimer.c:1024 (discriminator 1) include/linux/hrtimer.h:376 (discriminator 1) kernel/time/hrtimer.c:1497 (discriminator 1))
[ 3613.832375] SyS_nanosleep (kernel/time/hrtimer.c:1609 kernel/time/hrtimer.c:1598)
[ 3613.833267] ? hrtimer_nanosleep (kernel/time/hrtimer.c:1598)
[ 3613.834444] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.836150] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.837992] trinity-main    S ffff8801fa49fd08 25480  9307   9262 0x10000000
[ 3613.839288]  ffff8801fa49fd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.840689]  ffff8803211e0558 ffff8803211e0530 ffff8801fa7d8008 ffff88060d230000
[ 3613.842000]  ffff8801fa7d8000 ffff8801fa7d8000 ffff8801fa498000 ffffed003f493002
[ 3613.843841] Call Trace:
[ 3613.844508] ? do_wait (kernel/exit.c:1504)
[ 3613.846132] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.847290] do_wait (kernel/exit.c:1509)
[ 3613.848193] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.849135] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.850118] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.851310] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.852245] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.853514] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3613.854591] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.855926] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.857255] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3613.858397] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.859322] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.860149] runtrin.sh      S ffff8800a622fd08 29144  9372   8302 0x10000000
[ 3613.861575]  ffff8800a622fd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.862863]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8800a62e0008 ffff880052dc8000
[ 3613.864024]  ffff8800a62e0000 ffff8800a62e0000 ffff8800a6228000 ffffed0014c45002
[ 3613.866386] Call Trace:
[ 3613.867072] ? do_wait (kernel/exit.c:1504)
[ 3613.868691] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.869647] do_wait (kernel/exit.c:1509)
[ 3613.870421] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.871456] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.872575] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.874332] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.876017] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.877606] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.879123] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.880018] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.881086] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.882235] trinity         S ffff8801fa2afd08 25992  9374   9372 0x10000000
[ 3613.884080]  ffff8801fa2afd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.886377]  ffff8802253e0558 ffff8802253e0530 ffff8801f9eeb008 ffff8800a6dd0000
[ 3613.889189]  ffff8801f9eeb000 ffff8801f9eeb000 ffff8801fa2a8000 ffffed003f455002
[ 3613.890546] Call Trace:
[ 3613.891115] ? do_wait (kernel/exit.c:1504)
[ 3613.891964] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.892784] do_wait (kernel/exit.c:1509)
[ 3613.894000] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.896029] ? find_get_pid (include/linux/rcupdate.h:969 kernel/pid.c:495)
[ 3613.897148] ? find_get_pid (kernel/pid.c:490)
[ 3613.898447] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.899954] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.901219] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.902599] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.904481] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3613.906404] trinity-watchdo S ffff880223fc7c88 28264  9409   9374 0x10000000
[ 3613.908849]  ffff880223fc7c88 0000000000000000 000000003b9aca00 0000000000000000
[ 3613.910590]  ffff8800533e0558 ffff8800533e0530 ffff880223cf8008 ffff8801d0dd0000
[ 3613.912004]  ffff880223cf8000 ffff880223fc7c68 ffff880223fc0000 ffffed00447f8002
[ 3613.914114] Call Trace:
[ 3613.914917] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.916610] do_nanosleep (./arch/x86/include/asm/current.h:14 include/linux/freezer.h:120 include/linux/freezer.h:172 kernel/time/hrtimer.c:1502)
[ 3613.918384] ? schedule_timeout_uninterruptible (kernel/time/hrtimer.c:1492)
[ 3613.919700] ? memset (mm/kasan/kasan.c:269)
[ 3613.920536] hrtimer_nanosleep (kernel/time/hrtimer.c:1571)
[ 3613.921495] ? hrtimer_run_queues (kernel/time/hrtimer.c:1559)
[ 3613.923572] ? hrtimer_get_res (kernel/time/hrtimer.c:1472)
[ 3613.925476] ? do_nanosleep (kernel/time/hrtimer.c:1024 (discriminator 1) include/linux/hrtimer.h:376 (discriminator 1) kernel/time/hrtimer.c:1497 (discriminator 1))
[ 3613.927235] SyS_nanosleep (kernel/time/hrtimer.c:1609 kernel/time/hrtimer.c:1598)
[ 3613.928527] ? hrtimer_nanosleep (kernel/time/hrtimer.c:1598)
[ 3613.929515] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.930620] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.931557] trinity-main    S ffff8802234c7d08 26616  9410   9374 0x10000000
[ 3613.933019]  ffff8802234c7d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.934857]  ffff8801a73e0558 ffff8801a73e0530 ffff880223cfb008 ffff8800988ab000
[ 3613.937732]  ffff880223cfb000 ffff880223cfb000 ffff8802234c0000 ffffed0044698002
[ 3613.940038] Call Trace:
[ 3613.940478] ? do_wait (kernel/exit.c:1504)
[ 3613.941409] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.943730] do_wait (kernel/exit.c:1509)
[ 3613.944974] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.947164] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.949037] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.950273] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.951243] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.952295] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3613.953807] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.955430] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.957282] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3613.958851] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.959876] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3613.960779] kworker/u79:1   S ffff880224887ce8 29112  9411      2 0x10000000
[ 3613.962118]  ffff880224887ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3613.964008]  ffff8802253e0558 ffff8802253e0530 ffff880224128008 ffff8800a6dd0000
[ 3613.965948]  ffff880224128000 ffff880224887cc8 ffff880224880000 ffffed0044910002
[ 3613.967893] Call Trace:
[ 3613.968552] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3613.969518] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.970374] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3613.971622] ? __schedule (kernel/sched/core.c:2806)
[ 3613.972695] ? process_one_work (kernel/workqueue.c:2101)
[ 3613.973812] kthread (kernel/kthread.c:207)
[ 3613.974841] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.976239] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3613.977269] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.978191] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3613.979176] ? flush_kthread_work (kernel/kthread.c:176)
[ 3613.979789] runtrin.sh      S ffff880127c9fd08 29272  9473   8302 0x10000000
[ 3613.981033]  ffff880127c9fd08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3613.983424]  ffff8801533e0558 ffff8801533e0530 ffff88012789b008 ffff88079d1e8000
[ 3613.984592]  ffff88012789b000 ffff88012789b000 ffff880127c98000 ffffed0024f93002
[ 3613.986794] Call Trace:
[ 3613.987575] ? do_wait (kernel/exit.c:1504)
[ 3613.988984] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3613.989673] do_wait (kernel/exit.c:1509)
[ 3613.990191] ? wait_consider_task (kernel/exit.c:1465)
[ 3613.991249] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3613.992050] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3613.992953] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3613.993958] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3613.994799] ? SyS_waitid (kernel/exit.c:1586)
[ 3613.995864] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3613.998126] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3613.999310] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3614.000289] trinity         S ffff880152247d08 26248  9475   9473 0x10000000
[ 3614.001535]  ffff880152247d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3614.003775]  ffff8801fb3e0558 ffff8801fb3e0530 ffff880152030008 ffff8802a1cab000
[ 3614.006137]  ffff880152030000 ffff880152030000 ffff880152240000 ffffed002a448002
[ 3614.008909] Call Trace:
[ 3614.009395] ? do_wait (kernel/exit.c:1504)
[ 3614.010344] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.011340] do_wait (kernel/exit.c:1509)
[ 3614.012781] ? wait_consider_task (kernel/exit.c:1465)
[ 3614.015903] ? find_get_pid (include/linux/rcupdate.h:969 kernel/pid.c:495)
[ 3614.016852] ? find_get_pid (kernel/pid.c:490)
[ 3614.018005] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3614.019020] ? SyS_waitid (kernel/exit.c:1586)
[ 3614.019592] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3614.020378] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3614.021469] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3614.023230] trinity-watchdo S ffff8801f9ef7c88 28336  9517   9475 0x10000000
[ 3614.025376]  ffff8801f9ef7c88 0000000000000000 000000003b9aca00 0000000000000000
[ 3614.027472]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801fa26b008 ffff880052dc8000
[ 3614.029346]  ffff8801fa26b000 ffff8801f9ef7c68 ffff8801f9ef0000 ffffed003f3de002
[ 3614.030536] Call Trace:
[ 3614.031047] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.032105] do_nanosleep (./arch/x86/include/asm/current.h:14 include/linux/freezer.h:120 include/linux/freezer.h:172 kernel/time/hrtimer.c:1502)
[ 3614.033651] ? schedule_timeout_uninterruptible (kernel/time/hrtimer.c:1492)
[ 3614.036259] ? memset (mm/kasan/kasan.c:269)
[ 3614.037645] hrtimer_nanosleep (kernel/time/hrtimer.c:1571)
[ 3614.039211] ? hrtimer_run_queues (kernel/time/hrtimer.c:1559)
[ 3614.040180] ? hrtimer_get_res (kernel/time/hrtimer.c:1472)
[ 3614.041330] ? do_nanosleep (kernel/time/hrtimer.c:1024 (discriminator 1) include/linux/hrtimer.h:376 (discriminator 1) kernel/time/hrtimer.c:1497 (discriminator 1))
[ 3614.042871] SyS_nanosleep (kernel/time/hrtimer.c:1609 kernel/time/hrtimer.c:1598)
[ 3614.044108] ? hrtimer_nanosleep (kernel/time/hrtimer.c:1598)
[ 3614.046734] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3614.048010] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.048912] trinity-main    S ffff8801f9dc7d08 26616  9518   9475 0x10000000
[ 3614.050119]  ffff8801f9dc7d08 0000000000000000 ffffffffa71ef074 0000000000000000
[ 3614.051622]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801f9ee8008 ffff880052dc8000
[ 3614.053278]  ffff8801f9ee8000 ffff8801f9ee8000 ffff8801f9dc0000 ffffed003f3b8002
[ 3614.054520] Call Trace:
[ 3614.055390] ? do_wait (kernel/exit.c:1504)
[ 3614.056378] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.057326] do_wait (kernel/exit.c:1509)
[ 3614.058750] ? wait_consider_task (kernel/exit.c:1465)
[ 3614.059345] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3614.059963] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3614.061014] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3614.061838] SyS_wait4 (kernel/exit.c:1618 kernel/exit.c:1586)
[ 3614.063166] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3614.063780] ? SyS_waitid (kernel/exit.c:1586)
[ 3614.064361] ? kill_orphaned_pgrp (kernel/exit.c:1444)
[ 3614.065626] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.066823] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3614.067783] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.068484] mount.ntfs      S ffff88024dcb7978 26184  9521      1 0x10000000
[ 3614.069188]  ffff88024dcb7978 0000000000000000 ffffffffa80f897a 0000000000000000
[ 3614.070026]  ffff8800533e0558 ffff8800533e0530 ffff88024dcb8008 ffff8802f449b000
[ 3614.071064]  ffff88024dcb8000 ffff88024dcb8000 ffff88024dcb0000 ffffed0049b96002
[ 3614.072147] Call Trace:
[ 3614.072650] ? fuse_dev_do_read.isra.11 (fs/fuse/dev.c:1101 fs/fuse/dev.c:1284)
[ 3614.073289] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.073913] fuse_dev_do_read.isra.11 (include/linux/spinlock.h:312 fs/fuse/dev.c:1102 fs/fuse/dev.c:1284)
[ 3614.074865] ? fuse_request_send_background (fs/fuse/dev.c:1269)
[ 3614.076147] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3614.077038] ? fsnotify (include/linux/rcupdate.h:456 include/linux/srcu.h:234 fs/notify/fsnotify.c:281)
[ 3614.077655] ? fsnotify (fs/notify/fsnotify.c:283)
[ 3614.078413] ? fsnotify (include/linux/srcu.h:218 fs/notify/fsnotify.c:217)
[ 3614.078936] ? wake_up_state (kernel/sched/core.c:2973)
[ 3614.079465] fuse_dev_read (fs/fuse/dev.c:1368)
[ 3614.079997] ? might_fault (mm/memory.c:3727 (discriminator 1))
[ 3614.080656] ? fuse_dev_splice_read (fs/fuse/dev.c:1368)
[ 3614.081460] do_sync_read (fs/read_write.c:424)
[ 3614.082277] ? vfs_iter_write (fs/read_write.c:415)
[ 3614.082936] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3614.083529] ? security_file_permission (include/linux/fsnotify.h:60 security/security.c:717)
[ 3614.084248] __vfs_read (fs/read_write.c:465)
[ 3614.085153] vfs_read (fs/read_write.c:481)
[ 3614.086213] ? __fget_light (fs/file.c:684)
[ 3614.087100] SyS_read (fs/read_write.c:613 fs/read_write.c:605)
[ 3614.087768] ? vfs_read (fs/read_write.c:605)
[ 3614.088409] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.089057] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3614.089670] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.090222] sh              S ffff88007baaf8f8 25848  9598   8302 0x10000000
[ 3614.091185]  ffff88007baaf8f8 ffff88007bb40000 ffffffffb5930a40 ffff880000000000
[ 3614.092447]  ffff8800533e0558 ffff8800533e0530 ffff88007bb40008 ffff8801d0dd0000
[ 3614.093237]  ffff88007bb40000 ffffffffb7ff5f80 ffff88007baa8000 ffffed000f755002
[ 3614.094086] Call Trace:
[ 3614.094349] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.095404] schedule_timeout (kernel/time/timer.c:1475)
[ 3614.096681] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3614.097679] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3614.098322] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3614.098828] ? sched_clock_local (kernel/sched/clock.c:202)
[ 3614.099396] ? get_parent_ip (kernel/sched/core.c:2541)
[ 3614.099926] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3614.101146] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3614.101871] wait_woken (kernel/sched/wait.c:335)
[ 3614.103073] ? woken_wake_function (kernel/sched/wait.c:327)
[ 3614.103757] n_tty_read (drivers/tty/n_tty.c:2260)
[ 3614.104322] ? n_tty_open (drivers/tty/n_tty.c:2166)
[ 3614.105519] ? ldsem_down_read (drivers/tty/tty_ldsem.c:337 drivers/tty/tty_ldsem.c:366)
[ 3614.106606] ? tty_ldisc_ref_wait (drivers/tty/tty_ldisc.c:268)
[ 3614.107343] ? __account_scheduler_latency (drivers/tty/tty_ldsem.c:364)
[ 3614.108349] ? __fsnotify_inode_delete (fs/notify/fsnotify.c:193)
[ 3614.108951] ? wake_atomic_t_function (kernel/sched/wait.c:351)
[ 3614.109567] tty_read (drivers/tty/tty_io.c:1071)
[ 3614.110064] __vfs_read (fs/read_write.c:465)
[ 3614.110765] vfs_read (fs/read_write.c:481)
[ 3614.111464] ? __fget_light (fs/file.c:684)
[ 3614.112121] SyS_read (fs/read_write.c:613 fs/read_write.c:605)
[ 3614.112629] ? vfs_read (fs/read_write.c:605)
[ 3614.113183] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3614.113856] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3614.114978] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3614.116221] system_call_fastpath (arch/x86/kernel/entry_64.S:273)
[ 3614.117000] kworker/2:1H    S ffff88007b907ce8 30248  9703      2 0x10000000
[ 3614.118115]  ffff88007b907ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.118879]  ffff88007d3e0558 ffff88007d3e0530 ffff88007b848008 ffff8802ccdd8000
[ 3614.119630]  ffff88007b848000 ffff88007b907cc8 ffff88007b900000 ffffed000f720002
[ 3614.120454] Call Trace:
[ 3614.120777] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.121822] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.122602] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.123127] ? __schedule (kernel/sched/core.c:2806)
[ 3614.123565] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.124117] kthread (kernel/kthread.c:207)
[ 3614.124585] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.125185] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.126342] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.127241] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.127847] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.128580] kworker/u70:1   S ffff88007b90fce8 30248  9704      2 0x10000000
[ 3614.129326]  ffff88007b90fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.130102]  ffff88007d3e0558 ffff88007d3e0530 ffff88007bfab008 ffff8802ccdd8000
[ 3614.131119]  ffff88007bfab000 ffff88007b90fcc8 ffff88007b908000 ffffed000f721002
[ 3614.132088] Call Trace:
[ 3614.132450] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.133100] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.133666] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.134243] ? __schedule (kernel/sched/core.c:2806)
[ 3614.134891] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.136066] kthread (kernel/kthread.c:207)
[ 3614.136810] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.137507] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.138307] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.138890] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.139396] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.139978] kworker/u51:1   S ffff88007b937ce8 24680  9711      2 0x10000000
[ 3614.141099]  ffff88007b937ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.142199]  ffff88007d3e0558 ffff88007d3e0530 ffff88007b863008 ffff88029c010000
[ 3614.143699]  ffff88007b863000 ffff88007b937cc8 ffff88007b930000 ffffed000f726002
[ 3614.144608] Call Trace:
[ 3614.144845] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.145827] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.146820] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.147403] ? __schedule (kernel/sched/core.c:2806)
[ 3614.147999] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.148701] kthread (kernel/kthread.c:207)
[ 3614.149179] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.149766] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.150780] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.151466] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.152414] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.153020] kworker/u83:2   S ffff8802cb2b7ce8 26472  9713      2 0x10000000
[ 3614.153832]  ffff8802cb2b7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.155193]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802cc1f8008 ffff8802cc1ab000
[ 3614.156820]  ffff8802cc1f8000 ffff8802cb2b7cc8 ffff8802cb2b0000 ffffed0059656002
[ 3614.157823] Call Trace:
[ 3614.158182] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.158776] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.159254] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.159779] ? __schedule (kernel/sched/core.c:2806)
[ 3614.160439] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.161128] kthread (kernel/kthread.c:207)
[ 3614.162180] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.163352] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.164026] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.165055] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.166564] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.167842] kworker/u82:1   S ffff88029d30fce8 30248  9716      2 0x10000000
[ 3614.168818]  ffff88029d30fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.169599]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a2150008 ffff8802ccde0000
[ 3614.170546]  ffff8802a2150000 ffff88029d30fcc8 ffff88029d308000 ffffed0053a61002
[ 3614.171531] Call Trace:
[ 3614.171918] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.173194] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.173810] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.174412] ? __schedule (kernel/sched/core.c:2806)
[ 3614.175761] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.177092] kthread (kernel/kthread.c:207)
[ 3614.177664] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.178652] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.179362] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.179947] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.180698] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.181522] kworker/u54:1   S ffff880125c27ce8 29488  9730      2 0x10000000
[ 3614.183500]  ffff880125c27ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.184346]  ffff8801291e0558 ffff8801291e0530 ffff880127ceb008 ffff880128e0b000
[ 3614.186330]  ffff880127ceb000 ffff880125c27cc8 ffff880125c20000 ffffed0024b84002
[ 3614.187610] Call Trace:
[ 3614.188007] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.188777] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.189285] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.189836] ? __schedule (kernel/sched/core.c:2806)
[ 3614.190677] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.191487] kthread (kernel/kthread.c:207)
[ 3614.192348] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.193108] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.193769] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.194420] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.195324] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.196070] kworker/u56:1   S ffff88017bfd7ce8 29488  9739      2 0x10000000
[ 3614.197121]  ffff88017bfd7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.198186]  ffff88017d3e0558 ffff88017d3e0530 ffff88017c190008 ffff880128deb000
[ 3614.199073]  ffff88017c190000 ffff88017bfd7cc8 ffff88017bfd0000 ffffed002f7fa002
[ 3614.199856] Call Trace:
[ 3614.200150] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.200792] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.201455] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.202245] ? __schedule (kernel/sched/core.c:2806)
[ 3614.202905] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.203696] kthread (kernel/kthread.c:207)
[ 3614.204575] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.205603] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.206893] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.207876] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.208479] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.209082] kworker/u58:1   S ffff8801ce117ce8 28712  9823      2 0x10000000
[ 3614.209853]  ffff8801ce117ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.210857]  ffff8801d11e0558 ffff8801d11e0530 ffff8801d0203008 ffff880311ca0000
[ 3614.211693]  ffff8801d0203000 ffff8801ce117cc8 ffff8801ce110000 ffffed0039c22002
[ 3614.212541] Call Trace:
[ 3614.212823] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.213609] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.214179] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.215125] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.215898] kthread (kernel/kthread.c:207)
[ 3614.216565] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.217166] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.218198] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.218787] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.219296] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.219873] kworker/u59:1   S ffff8801f75dfce8 29304 10285      2 0x10000000
[ 3614.220826]  ffff8801f75dfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.221715]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801f7593008 ffff8802a1c90000
[ 3614.222676]  ffff8801f7593000 ffff8801f75dfcc8 ffff8801f75d8000 ffffed003eebb002
[ 3614.223459] Call Trace:
[ 3614.223763] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.224657] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.225409] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.226298] ? __schedule (kernel/sched/core.c:2806)
[ 3614.226925] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.227608] kthread (kernel/kthread.c:207)
[ 3614.228383] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.229008] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.229642] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.230251] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.230873] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.231617] kworker/6:2     S ffff880151177ce8 29304 11064      2 0x10000000
[ 3614.232818]  ffff880151177ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.234240]  ffff8801533e0558 ffff8801533e0530 ffff88014d328008 ffff88023a970000
[ 3614.235864]  ffff88014d328000 ffff880151177cc8 ffff880151170000 ffffed002a22e002
[ 3614.237236] Call Trace:
[ 3614.237550] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.238322] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.238800] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.239320] ? __schedule (kernel/sched/core.c:2806)
[ 3614.239836] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.241159] kthread (kernel/kthread.c:207)
[ 3614.242182] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.243403] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.244796] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.246582] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.247838] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.248909] kworker/u62:1   S ffff8802751f7ce8 29488 11099      2 0x10000000
[ 3614.250012]  ffff8802751f7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.251460]  ffff8802791e0558 ffff8802791e0530 ffff88027528b008 ffff88007cdfb000
[ 3614.253272]  ffff88027528b000 ffff8802751f7cc8 ffff8802751f0000 ffffed004ea3e002
[ 3614.255913] Call Trace:
[ 3614.256814] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.258541] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.259308] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.260109] ? __schedule (kernel/sched/core.c:2806)
[ 3614.261226] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.262609] kthread (kernel/kthread.c:207)
[ 3614.263742] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.265151] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.267156] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.269065] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.269871] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.270960] kworker/u61:1   S ffff88024b557ce8 29304 11995      2 0x10000000
[ 3614.272544]  ffff88024b557ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.274952]  ffff88024f3e0558 ffff88024f3e0530 ffff88024a093008 ffff8801979a3000
[ 3614.277782]  ffff88024a093000 ffff88024b557cc8 ffff88024b550000 ffffed00496aa002
[ 3614.280051] Call Trace:
[ 3614.280469] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.281503] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.282429] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.283779] ? __schedule (kernel/sched/core.c:2806)
[ 3614.285114] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.287404] kthread (kernel/kthread.c:207)
[ 3614.288929] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.290280] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.291335] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.292546] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.294335] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.296435] kworker/u57:2   S ffff880219c17ce8 29272 13762      2 0x10000000
[ 3614.298960]  ffff880219c17ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.300367]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6320008 ffff8801a3790000
[ 3614.301848]  ffff8801a6320000 ffff880219c17cc8 ffff880219c10000 ffffed0043382002
[ 3614.304097] Call Trace:
[ 3614.305177] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.307175] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.308158] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.309008] ? __schedule (kernel/sched/core.c:2806)
[ 3614.309839] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.310906] kthread (kernel/kthread.c:207)
[ 3614.312138] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.313574] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.314847] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.316938] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.317935] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.319032] kworker/u55:2   S ffff8801368b7ce8 28712 14598      2 0x10000000
[ 3614.319806]  ffff8801368b7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.321067]  ffff8801533e0558 ffff8801533e0530 ffff88012f2b0008 ffff8801d8ae8000
[ 3614.323083]  ffff88012f2b0000 ffff8801368b7cc8 ffff8801368b0000 ffffed0026d16002
[ 3614.325510] Call Trace:
[ 3614.326405] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.328270] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.329615] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.330702] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.331817] kthread (kernel/kthread.c:207)
[ 3614.333514] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.335810] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.337594] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.339305] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.340091] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.341469] kworker/u55:3   S ffff88013683fce8 29304 14645      2 0x10000000
[ 3614.343360]  ffff88013683fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.345362]  ffff8801533e0558 ffff8801533e0530 ffff88012f2b3008 ffff88012f2b0000
[ 3614.348134]  ffff88012f2b3000 ffff88013683fcc8 ffff880136838000 ffffed0026d07002
[ 3614.349652] Call Trace:
[ 3614.350026] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.351292] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.352561] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.354107] ? __schedule (kernel/sched/core.c:2806)
[ 3614.355864] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.358030] kthread (kernel/kthread.c:207)
[ 3614.359131] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.360030] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.361351] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.363025] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.364445] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.366390] kworker/u57:3   S ffff8801edccfce8 29112 20746      2 0x10000000
[ 3614.367900]  ffff8801edccfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.369152]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a3790008 ffff8800988ab000
[ 3614.370381]  ffff8801a3790000 ffff8801edccfcc8 ffff8801edcc8000 ffffed003db99002
[ 3614.372004] Call Trace:
[ 3614.372594] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.373797] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.374823] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.376770] ? __schedule (kernel/sched/core.c:2806)
[ 3614.377940] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.378962] kthread (kernel/kthread.c:207)
[ 3614.379700] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.380804] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.381885] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.383267] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.384508] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.386379] kworker/17:2    S ffff880318a57ce8 29112 22182      2 0x10000000
[ 3614.388226]  ffff880318a57ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.389528]  ffff8803211e0558 ffff8803211e0530 ffff880319c7b008 ffff88060d230000
[ 3614.390889]  ffff880319c7b000 ffff880318a57cc8 ffff880318a50000 ffffed006314a002
[ 3614.392434] Call Trace:
[ 3614.393143] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.394714] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.396456] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.397275] ? __schedule (kernel/sched/core.c:2806)
[ 3614.398163] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.399088] kthread (kernel/kthread.c:207)
[ 3614.399875] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.400930] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.401998] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.403611] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.404954] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.406727] kworker/0:2     S ffff88001edd7ce8 30248 26057      2 0x10000000
[ 3614.408016]  ffff88001edd7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.409233]  ffff8800261e0558 ffff8800261e0530 ffff880021778008 ffff880011fb0000
[ 3614.410501]  ffff880021778000 ffff88001edd7cc8 ffff88001edd0000 ffffed0003dba002
[ 3614.411927] Call Trace:
[ 3614.412558] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.414073] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.415500] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.417234] ? __schedule (kernel/sched/core.c:2806)
[ 3614.418664] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.419555] kthread (kernel/kthread.c:207)
[ 3614.420305] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.422246] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.423704] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.425071] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.426979] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.428107] kworker/15:0    S ffff8802c3ee7ce8 29112 27214      2 0x10000000
[ 3614.429195]  ffff8802c3ee7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.430383]  ffff8802cd3e0558 ffff8802cd3e0530 ffff8802a7dc3008 ffff8803c8df0000
[ 3614.431582]  ffff8802a7dc3000 ffff8802c3ee7cc8 ffff8802c3ee0000 ffffed00587dc002
[ 3614.433641] Call Trace:
[ 3614.435686] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.437164] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.438122] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.439027] ? __schedule (kernel/sched/core.c:2806)
[ 3614.439837] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.440896] kthread (kernel/kthread.c:207)
[ 3614.441799] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.443052] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.443998] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.445563] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.446746] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.447711] kworker/u49:2   S ffff880014b7fce8 28840 29215      2 0x10000000
[ 3614.448977]  ffff880014b7fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.450161]  ffff8800261e0558 ffff8800261e0530 ffff880021738008 ffff880022320000
[ 3614.451411]  ffff880021738000 ffff880014b7fcc8 ffff880014b78000 ffffed000296f002
[ 3614.452657] Call Trace:
[ 3614.453047] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.453951] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.454754] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.455850] ? __schedule (kernel/sched/core.c:2806)
[ 3614.456752] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.457723] kthread (kernel/kthread.c:207)
[ 3614.458579] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.459480] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.460557] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.461539] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.462440] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.463557] kworker/16:0    S ffff8802f451fce8 29112   409      2 0x10000000
[ 3614.464741]  ffff8802f451fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.466932]  ffff8802f73e0558 ffff8802f73e0530 ffff8802f6b03008 ffff880202dcb000
[ 3614.468352]  ffff8802f6b03000 ffff8802f451fcc8 ffff8802f4518000 ffffed005e8a3002
[ 3614.469664] Call Trace:
[ 3614.470010] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.470907] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.471776] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.472869] ? __schedule (kernel/sched/core.c:2806)
[ 3614.473728] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.474848] kthread (kernel/kthread.c:207)
[ 3614.476291] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.477618] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.478786] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.479734] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.480607] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.481916] kworker/9:0     S ffff8801ba5afce8 29304  1481      2 0x10000000
[ 3614.483375]  ffff8801ba5afce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.485353]  ffff8801d11e0558 ffff8801d11e0530 ffff8801beb2b008 ffff880051e9b000
[ 3614.487069]  ffff8801beb2b000 ffff8801ba5afcc8 ffff8801ba5a8000 ffffed00374b5002
[ 3614.488454] Call Trace:
[ 3614.488839] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.490713] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.491394] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.492321] ? __schedule (kernel/sched/core.c:2806)
[ 3614.493409] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.494085] kthread (kernel/kthread.c:207)
[ 3614.494597] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.496041] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.497660] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.498620] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.499383] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.500015] trinity-c5      S ffff8802cb21f728 27168  1701   9410 0x10000000
[ 3614.500803]  ffff8802cb21f728 ffff8802cb21f6c8 ffffffffa70258c1 ffff880200000000
[ 3614.502015]  ffff8801291e0558 ffff8801291e0530 ffff8802c10d8008 ffff880275240000
[ 3614.502844]  ffff8802c10d8000 0000000000000005 ffff8802cb218000 ffffed0059643002
[ 3614.504054] Call Trace:
[ 3614.504580] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3614.505496] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.506550] schedule_timeout (kernel/time/timer.c:1475)
[ 3614.508509] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3614.509585] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3614.510270] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3614.511012] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3614.511884] ? release_sock (net/core/sock.c:2387)
[ 3614.512423] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3614.513048] ? __local_bh_enable_ip (./arch/x86/include/asm/paravirt.h:819 kernel/softirq.c:175)
[ 3614.513691] ? _raw_spin_unlock_bh (kernel/locking/spinlock.c:208)
[ 3614.514349] ? release_sock (net/core/sock.c:2387)
[ 3614.515011] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3614.516170] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3614.516835] sk_wait_data (net/core/sock.c:1969 (discriminator 1))
[ 3614.517407] ? release_sock (net/core/sock.c:1963)
[ 3614.518082] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3614.519202] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3614.519826] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3614.520452] ? __local_bh_enable_ip (./arch/x86/include/asm/paravirt.h:819 kernel/softirq.c:175)
[ 3614.521146] ? llc_ui_recvmsg (net/llc/af_llc.c:725)
[ 3614.521847] llc_ui_recvmsg (net/llc/af_llc.c:807)
[ 3614.522877] ? llc_ui_listen (net/llc/af_llc.c:709)
[ 3614.523561] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3614.524621] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3614.526117] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3614.526852] sock_recvmsg (net/socket.c:734)
[ 3614.527521] sock_read_iter (net/socket.c:815)
[ 3614.528196] ? sock_recvmsg (net/socket.c:798)
[ 3614.528762] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3614.529297] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3614.530494] new_sync_read (fs/read_write.c:443)
[ 3614.531144] ? do_sync_write (fs/read_write.c:432)
[ 3614.531887] ? __fsnotify_inode_delete (fs/notify/fsnotify.c:193)
[ 3614.532531] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3614.533263] __vfs_read (fs/read_write.c:465)
[ 3614.533851] vfs_read (fs/read_write.c:481)
[ 3614.534434] ? __fget_light (fs/file.c:684)
[ 3614.535030] SyS_read (fs/read_write.c:613 fs/read_write.c:605)
[ 3614.535685] ? vfs_read (fs/read_write.c:605)
[ 3614.536293] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.536987] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3614.537653] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.538474] kworker/14:0    S ffff88029d3efce8 29112  2967      2 0x10000000
[ 3614.539237]  ffff88029d3efce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.540011]  ffff8802a33e0558 ffff8802a33e0530 ffff8802a202b008 ffff8802ccde0000
[ 3614.540888]  ffff8802a202b000 ffff88029d3efcc8 ffff88029d3e8000 ffffed0053a7d002
[ 3614.541966] Call Trace:
[ 3614.542334] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.543468] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.544213] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.544822] ? __schedule (kernel/sched/core.c:2806)
[ 3614.545531] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.546256] kthread (kernel/kthread.c:207)
[ 3614.546754] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.547525] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.548154] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.548745] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.549262] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.549870] kworker/13:0    S ffff880265257ce8 29112  3319      2 0x10000000
[ 3614.550627]  ffff880265257ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.551427]  ffff8802791e0558 ffff8802791e0530 ffff880255200008 ffff880224dd0000
[ 3614.552267]  ffff880255200000 ffff880265257cc8 ffff880265250000 ffffed004ca4a002
[ 3614.553228] Call Trace:
[ 3614.553652] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.554300] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.554828] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.555475] ? __schedule (kernel/sched/core.c:2806)
[ 3614.556081] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.556691] kthread (kernel/kthread.c:207)
[ 3614.557201] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.557851] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.558463] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.559034] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.559544] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.560139] kworker/u50:2   S ffff880039707ce8 29112  4467      2 0x10000000
[ 3614.560948]  ffff880039707ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.561975]  ffff8800533e0558 ffff8800533e0530 ffff88003acd3008 ffff880052a83000
[ 3614.562790]  ffff88003acd3000 ffff880039707cc8 ffff880039700000 ffffed00072e0002
[ 3614.563954] Call Trace:
[ 3614.564244] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.564889] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.565538] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.566194] ? __schedule (kernel/sched/core.c:2806)
[ 3614.566811] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.567427] kthread (kernel/kthread.c:207)
[ 3614.567912] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.568508] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.569095] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.569736] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.570290] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.570887] kworker/3:2     S ffff88008813fce8 29792  4594      2 0x10000000
[ 3614.571825]  ffff88008813fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.572574]  ffff8800a73e0558 ffff8800a73e0530 ffff880083963008 ffff8803c8de8000
[ 3614.573597]  ffff880083963000 ffff88008813fcc8 ffff880088138000 ffffed0011027002
[ 3614.574436] Call Trace:
[ 3614.574706] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.575361] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.575951] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.576493] ? __schedule (kernel/sched/core.c:2806)
[ 3614.577098] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.577756] kthread (kernel/kthread.c:207)
[ 3614.578275] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.578859] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.579470] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.580061] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.580619] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.581281] kworker/u52:3   S ffff8800868ffce8 29416  4847      2 0x10000000
[ 3614.582186]  ffff8800868ffce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.583009]  ffff8800a73e0558 ffff8800a73e0530 ffff880085d23008 ffff880085d20000
[ 3614.583966]  ffff880085d23000 ffff8800868ffcc8 ffff8800868f8000 ffffed0010d1f002
[ 3614.584823] Call Trace:
[ 3614.585103] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.585890] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.586456] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.587143] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.587779] kthread (kernel/kthread.c:207)
[ 3614.588348] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.588958] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.589589] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.590293] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.590869] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.591617] kworker/12:2    S ffff88024b5bfce8 29112  5301      2 0x10000000
[ 3614.592486]  ffff88024b5bfce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.593555]  ffff88024f3e0558 ffff88024f3e0530 ffff88024ac50008 ffff88017cdd0000
[ 3614.594535]  ffff88024ac50000 ffff88024b5bfcc8 ffff88024b5b8000 ffffed00496b7002
[ 3614.595586] Call Trace:
[ 3614.596004] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.596586] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.597314] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.597896] ? __schedule (kernel/sched/core.c:2806)
[ 3614.598573] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.599221] kthread (kernel/kthread.c:207)
[ 3614.599805] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.600443] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.601047] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.601889] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.602421] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.603076] kworker/5:2     S ffff880116467ce8 29304  5375      2 0x10000000
[ 3614.603918]  ffff880116467ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.605396]  ffff8801291e0558 ffff8801291e0530 ffff880114b48008 ffff88021aff3000
[ 3614.606492]  ffff880114b48000 ffff880116467cc8 ffff880116460000 ffffed0022c8c002
[ 3614.607316] Call Trace:
[ 3614.607556] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.608349] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.608852] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.609472] ? __schedule (kernel/sched/core.c:2806)
[ 3614.610010] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.610625] kthread (kernel/kthread.c:207)
[ 3614.611444] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.612298] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.613309] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.614524] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.615928] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.616815] kworker/2:2     S ffff88006359fce8 29112  6476      2 0x10000000
[ 3614.617799]  ffff88006359fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.618614]  ffff88007d3e0558 ffff88007d3e0530 ffff88007b84b008 ffff880077630000
[ 3614.619401]  ffff88007b84b000 ffff88006359fcc8 ffff880063598000 ffffed000c6b3002
[ 3614.620264] Call Trace:
[ 3614.620588] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.621201] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.622430] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.623633] ? __schedule (kernel/sched/core.c:2806)
[ 3614.624541] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.626335] kthread (kernel/kthread.c:207)
[ 3614.626961] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.627698] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.628595] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.629199] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.629728] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.631248] kworker/4:2     S ffff8800b3577ce8 29112  6586      2 0x10000000
[ 3614.632739]  ffff8800b3577ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.634614]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8800c28e3008 ffff8802705d3000
[ 3614.636433]  ffff8800c28e3000 ffff8800b3577cc8 ffff8800b3570000 ffffed00166ae002
[ 3614.638153] Call Trace:
[ 3614.638717] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.639554] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.640332] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.641338] ? __schedule (kernel/sched/core.c:2806)
[ 3614.642250] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.643475] kthread (kernel/kthread.c:207)
[ 3614.644681] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.646481] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.648480] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.649714] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.650723] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.651822] kworker/10:0    S ffff8801e573fce8 29112  6679      2 0x10000000
[ 3614.654075]  ffff8801e573fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.656896]  ffff8801fb3e0558 ffff8801fb3e0530 ffff8801d9c28008 ffff8802f441b000
[ 3614.659307]  ffff8801d9c28000 ffff8801e573fcc8 ffff8801e5738000 ffffed003cae7002
[ 3614.660618] Call Trace:
[ 3614.661202] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.662173] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.663235] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.664705] ? __schedule (kernel/sched/core.c:2806)
[ 3614.666425] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.668461] kthread (kernel/kthread.c:207)
[ 3614.669410] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.670451] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.671396] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.672386] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.673671] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.675577] kworker/u58:2   S ffff8801cac07ce8 29304  7773      2 0x10000000
[ 3614.678001]  ffff8801cac07ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.679555]  ffff8801d11e0558 ffff8801d11e0530 ffff8801afa30008 ffff8801d0203000
[ 3614.680766]  ffff8801afa30000 ffff8801cac07cc8 ffff8801cac00000 ffffed0039580002
[ 3614.682349] Call Trace:
[ 3614.682917] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.684235] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.685343] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.686897] ? __schedule (kernel/sched/core.c:2806)
[ 3614.687769] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.688789] kthread (kernel/kthread.c:207)
[ 3614.689554] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.690641] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.691613] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.692786] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.694323] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.696339] kworker/1:2     S ffff8800396e7ce8 29304  9493      2 0x10000000
[ 3614.698646]  ffff8800396e7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.699885]  ffff8800533e0558 ffff8800533e0530 ffff8800518f3008 ffff8802f4418000
[ 3614.701455]  ffff8800518f3000 ffff8800396e7cc8 ffff8800396e0000 ffffed00072dc002
[ 3614.703044] Call Trace:
[ 3614.703614] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.704697] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.705992] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.707426] ? __schedule (kernel/sched/core.c:2806)
[ 3614.708504] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.709421] kthread (kernel/kthread.c:207)
[ 3614.710167] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.711090] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.712298] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.713451] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.714545] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.715931] kworker/11:2    S ffff88020d71fce8 29112  9981      2 0x10000000
[ 3614.717386]  ffff88020d71fce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.719091]  ffff8802253e0558 ffff8802253e0530 ffff880202dc8008 ffff880223cfb000
[ 3614.720283]  ffff880202dc8000 ffff88020d71fcc8 ffff88020d718000 ffffed0041ae3002
[ 3614.721512] Call Trace:
[ 3614.722203] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.723267] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.724040] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.725281] ? __schedule (kernel/sched/core.c:2806)
[ 3614.726433] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.727842] kthread (kernel/kthread.c:207)
[ 3614.728749] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.730152] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.730794] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.731454] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.732140] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.733410] trinity-c9      S ffff880272237c98 26976 10525   9194 0x10000000
[ 3614.735299]  ffff880272237c98 0000000000000000 ffffffffa7749840 0000000000000000
[ 3614.736445]  ffff8801d11e0558 ffff8801d11e0530 ffff8802550f8008 ffff8801afa33000
[ 3614.737491]  ffff8802550f8000 ffff880272237c78 ffff880272230000 ffffed004e446002
[ 3614.738425] Call Trace:
[ 3614.738676] ? timerfd_read (fs/timerfd.c:248 (discriminator 23))
[ 3614.739211] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.739689] timerfd_read (include/linux/spinlock.h:342 (discriminator 23) fs/timerfd.c:248 (discriminator 23))
[ 3614.740459] ? do_timerfd_gettime (fs/timerfd.c:237)
[ 3614.741162] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3614.742081] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3614.742902] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3614.743546] __vfs_read (fs/read_write.c:465)
[ 3614.744104] vfs_read (fs/read_write.c:481)
[ 3614.744962] ? __fget_light (fs/file.c:684)
[ 3614.745822] SyS_read (fs/read_write.c:613 fs/read_write.c:605)
[ 3614.746604] ? vfs_read (fs/read_write.c:605)
[ 3614.747309] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.748004] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3614.748661] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.749309] trinity-c6      S ffff88026739f8c8 26832 10551   9194 0x10000000
[ 3614.750146]  ffff88026739f8c8 ffff88026739f868 ffffffffa70258c1 ffff880200000000
[ 3614.750951]  ffff8801533e0558 ffff8801533e0530 ffff880275288008 ffff880223d7b000
[ 3614.751869]  ffff880275288000 0000000000000006 ffff880267398000 ffffed004ce73002
[ 3614.752931] Call Trace:
[ 3614.753375] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3614.753926] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.754558] schedule_timeout (kernel/time/timer.c:1475)
[ 3614.755747] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3614.756362] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3614.757202] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3614.757906] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3614.758784] ? release_sock (net/core/sock.c:2387)
[ 3614.759419] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3614.759994] ? __local_bh_enable_ip (./arch/x86/include/asm/paravirt.h:819 kernel/softirq.c:175)
[ 3614.760817] ? _raw_spin_unlock_bh (kernel/locking/spinlock.c:208)
[ 3614.761465] ? release_sock (net/core/sock.c:2387)
[ 3614.762372] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3614.763594] tipc_wait_for_rcvmsg.isra.45 (include/net/sock.h:1486 net/tipc/socket.c:1246)
[ 3614.764216] ? tipc_bind (net/tipc/socket.c:1230)
[ 3614.765410] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3614.766329] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3614.767465] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3614.768327] ? __local_bh_enable_ip (./arch/x86/include/asm/paravirt.h:819 kernel/softirq.c:175)
[ 3614.769231] ? tipc_recvmsg (net/tipc/socket.c:1292)
[ 3614.769870] tipc_recvmsg (net/tipc/socket.c:1302)
[ 3614.770767] ? set_orig_addr.isra.49 (net/tipc/socket.c:1276)
[ 3614.771810] ? __fget_light (fs/file.c:684)
[ 3614.773001] sock_recvmsg (net/socket.c:734)
[ 3614.775184] SYSC_recvfrom (net/socket.c:1732 (discriminator 4))
[ 3614.776734] ? SYSC_accept4 (net/socket.c:1705)
[ 3614.778282] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3614.779578] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3614.780592] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.781506] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3614.783263] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3614.785431] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.787208] SyS_recvfrom (net/socket.c:1702)
[ 3614.788926] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.789837] kworker/8:0     S ffff8801a6fd7ce8 29304 11979      2 0x10000000
[ 3614.791003]  ffff8801a6fd7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.792555]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6e33008 ffff880085d20000
[ 3614.795031]  ffff8801a6e33000 ffff8801a6fd7cc8 ffff8801a6fd0000 ffffed0034dfa002
[ 3614.797723] Call Trace:
[ 3614.798332] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.799274] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.800035] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.800951] ? __schedule (kernel/sched/core.c:2806)
[ 3614.801951] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.803778] kthread (kernel/kthread.c:207)
[ 3614.805352] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.807192] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.808167] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.809071] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.809864] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.810912] trinity-c0      D ffff8800776efd28 26512 14641   9194 0x10000000
[ 3614.812230]  ffff8800776efd28 ffff880077633ca8 0000000000000000 0000000000000000
[ 3614.814325]  ffff8800261e0558 ffff8800261e0530 ffff880077633008 ffff8802f5c33000
[ 3614.816554]  ffff880077633000 ffff8800776efd08 ffff8800776e8000 ffffed000eedd002
[ 3614.818130] Call Trace:
[ 3614.818519] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.819250] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3614.820203] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3614.821282] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.822679] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.823709] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.824890] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3614.826373] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3614.827861] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3614.828820] lru_add_drain_all (mm/swap.c:867)
[ 3614.829686] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3614.830473] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.831288] trinity-c2      D ffff8802b7f37d28 26296 14667   9086 0x10000004
[ 3614.832621]  ffff8802b7f37d28 ffff8802cb0c3ca8 0000000000000000 0000000000000000
[ 3614.834462]  ffff88007d3e0558 ffff88007d3e0530 ffff8802cb0c3008 ffff8802ccdd8000
[ 3614.836544]  ffff8802cb0c3000 ffff8802b7f37d08 ffff8802b7f30000 ffffed0056fe6002
[ 3614.838103] Call Trace:
[ 3614.838482] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.839219] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3614.840150] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3614.841088] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.842357] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.843436] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.844470] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3614.846086] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3614.847924] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3614.849075] lru_add_drain_all (mm/swap.c:867)
[ 3614.849930] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3614.850839] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.851824] kworker/7:2     S ffff8801693e7ce8 29696 14677      2 0x10000000
[ 3614.853397]  ffff8801693e7ce8 0000000000000000 ffffffffa723b211 0000000000000000
[ 3614.856136]  ffff88017d3e0558 ffff88017d3e0530 ffff88015a410008 ffff8802f6b98000
[ 3614.858447]  ffff88015a410000 ffff8801693e7cc8 ffff8801693e0000 ffffed002d27c002
[ 3614.859920] Call Trace:
[ 3614.860415] ? worker_thread (kernel/workqueue.c:2177 (discriminator 1))
[ 3614.861355] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.862329] worker_thread (include/linux/spinlock.h:342 kernel/workqueue.c:2108)
[ 3614.864244] ? __schedule (kernel/sched/core.c:2806)
[ 3614.866423] ? process_one_work (kernel/workqueue.c:2101)
[ 3614.868563] kthread (kernel/kthread.c:207)
[ 3614.869774] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.870802] ? finish_task_switch (kernel/sched/core.c:2234)
[ 3614.871824] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.872870] ret_from_fork (arch/x86/kernel/entry_64.S:549)
[ 3614.874509] ? flush_kthread_work (kernel/kthread.c:176)
[ 3614.876706] trinity-c6      D ffff8802f28bfa88 26928 15683   9410 0x10000004
[ 3614.879293]  ffff8802f28bfa88 ffff8802f4418ca8 0000000000000000 0000000000000000
[ 3614.880497]  ffff8801533e0558 ffff8801533e0530 ffff8802f4418008 ffff88079d1e8000
[ 3614.881976]  ffff8802f4418000 ffff8802f28bfa68 ffff8802f28b8000 ffffed005e517002
[ 3614.883917] Call Trace:
[ 3614.884418] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.886469] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3614.888130] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3614.889227] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.890255] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.891228] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3614.892270] lru_add_drain_all (mm/swap.c:867)
[ 3614.893669] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3614.895049] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3614.896479] ? migrate_pages (mm/migrate.c:1444)
[ 3614.897729] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3614.898830] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3614.899706] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.900659] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.901792] SyS_move_pages (mm/migrate.c:1440)
[ 3614.902725] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.903859] trinity-c1      D ffff88027add7d28 26688 16133   9086 0x10000004
[ 3614.906334]  ffff88027add7d28 ffff8802929dbca8 0000000000000000 0000000000000000
[ 3614.907264]  ffff8800533e0558 ffff8800533e0530 ffff8802929db008 ffff8801d0dd0000
[ 3614.908265]  ffff8802929db000 ffff88027add7d08 ffff88027add0000 ffffed004f5ba002
[ 3614.909086] Call Trace:
[ 3614.909340] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.909890] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3614.910687] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3614.911636] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.912424] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.913453] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.914160] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3614.915263] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3614.916087] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3614.916801] lru_add_drain_all (mm/swap.c:867)
[ 3614.917623] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3614.918237] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.918852] trinity-c7      D ffff8802f4487b58 26976 16252   9410 0x10000000
[ 3614.919580]  ffff8802f4487b58 ffff8802f6b98ca8 0000000000000000 0000000000000000
[ 3614.920435]  ffff88017d3e0558 ffff88017d3e0530 ffff8802f6b98008 ffff88016bad0000
[ 3614.921219]  ffff8802f6b98000 ffff8802f4487b38 ffff8802f4480000 ffffed005e890002
[ 3614.922069] Call Trace:
[ 3614.922346] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.923023] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3614.923707] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3614.924486] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.925211] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3614.925970] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.926692] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3614.927464] ? mpol_new (mm/mempolicy.c:285)
[ 3614.928044] lru_add_drain_all (mm/swap.c:867)
[ 3614.928608] migrate_prep (mm/migrate.c:64)
[ 3614.929092] SYSC_mbind (mm/mempolicy.c:1188 mm/mempolicy.c:1319)
[ 3614.929619] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.930318] ? __mpol_equal (mm/mempolicy.c:1304)
[ 3614.930877] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3614.931485] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.932184] SyS_mbind (mm/mempolicy.c:1301)
[ 3614.932675] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.933430] trinity-c5      D ffff8801168efd28 26112 16328   9086 0x10000000
[ 3614.934573]  ffff8801168efd28 ffff88021aff3ca8 0000000000000000 0000000000000000
[ 3614.935744]  ffff8801291e0558 ffff8801291e0530 ffff88021aff3008 ffff8802f5c30000
[ 3614.936720]  ffff88021aff3000 ffff8801168efd08 ffff8801168e8000 ffffed0022d1d002
[ 3614.937542] Call Trace:
[ 3614.937844] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.938523] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3614.939155] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3614.939725] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.940413] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.941072] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.941682] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3614.942281] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3614.943230] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3614.944107] lru_add_drain_all (mm/swap.c:867)
[ 3614.945147] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3614.945819] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.946546] trinity-c3      D ffff8800c640fa88 26688 16387   9410 0x10000004
[ 3614.947340]  ffff8800c640fa88 ffff88006a223ca8 0000000000000000 0000000000000000
[ 3614.948174]  ffff8800a73e0558 ffff8800a73e0530 ffff88006a223008 ffff8801d84d3000
[ 3614.948935]  ffff88006a223000 ffff8800c640fa68 ffff8800c6408000 ffffed0018c81002
[ 3614.949698] Call Trace:
[ 3614.949950] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.950489] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3614.951190] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3614.951803] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.952479] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.953267] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3614.954017] lru_add_drain_all (mm/swap.c:867)
[ 3614.954973] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3614.955851] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3614.956593] ? migrate_pages (mm/migrate.c:1444)
[ 3614.957320] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3614.958064] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3614.958677] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.959261] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.959905] SyS_move_pages (mm/migrate.c:1440)
[ 3614.960518] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.961057] trinity-c9      R  running task    26928 16461   9410 0x10000004
[ 3614.962001]  ffff8801ac93fb38 0000000000000000 ffffffffa7749840 0000000000000000
[ 3614.963442]  ffff8801d11e0558 ffff8801d11e0530 ffff88010dc53008 ffff880311ca0000
[ 3614.964428]  ffff88010dc53000 ffff8801ac93fb18 ffff8801ac938000 ffffed0035927002
[ 3614.965429] Call Trace:
[ 3614.965721] ? timerfd_read (fs/timerfd.c:248 (discriminator 23))
[ 3614.966299] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.966823] timerfd_read (include/linux/spinlock.h:342 (discriminator 23) fs/timerfd.c:248 (discriminator 23))
[ 3614.967472] ? do_timerfd_gettime (fs/timerfd.c:237)
[ 3614.968131] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3614.968738] ? rw_verify_area (fs/read_write.c:409 (discriminator 4))
[ 3614.969278] do_readv_writev (fs/read_write.c:749 fs/read_write.c:881)
[ 3614.969835] ? do_timerfd_gettime (fs/timerfd.c:237)
[ 3614.970506] ? rw_copy_check_uvector (fs/read_write.c:843)
[ 3614.971152] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3614.972061] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3614.972937] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.974394] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3614.975174] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3614.976031] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3614.976575] vfs_readv (fs/read_write.c:907)
[ 3614.977144] SyS_readv (fs/read_write.c:933 fs/read_write.c:924)
[ 3614.977658] ? vfs_writev (fs/read_write.c:924)
[ 3614.978167] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.978806] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3614.979410] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.979934] trinity-c2      D ffff880198b3fa88 26224 16494   9194 0x10000000
[ 3614.980739]  ffff880198b3fa88 ffff8801a0a13ca8 0000000000000000 0000000000000000
[ 3614.981714]  ffff88007d3e0558 ffff88007d3e0530 ffff8801a0a13008 ffff88029c010000
[ 3614.982837]  ffff8801a0a13000 ffff880198b3fa68 ffff880198b38000 ffffed0033167002
[ 3614.983721] Call Trace:
[ 3614.983974] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3614.984575] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3614.985433] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3614.986335] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.987083] ? lru_add_drain_all (mm/swap.c:867)
[ 3614.988038] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3614.988580] lru_add_drain_all (mm/swap.c:867)
[ 3614.989154] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3614.989720] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3614.991094] ? migrate_pages (mm/migrate.c:1444)
[ 3614.991946] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3614.993379] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3614.994056] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3614.995765] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3614.996763] SyS_move_pages (mm/migrate.c:1440)
[ 3614.997433] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3614.998151] trinity-c1      D ffff8801c0447d28 26696 16509   9410 0x10000000
[ 3614.998901]  ffff8801c0447d28 ffff8801278cbca8 0000000000000000 0000000000000000
[ 3614.999676]  ffff8800533e0558 ffff8800533e0530 ffff8801278cb008 ffff8801d0dd0000
[ 3615.000518]  ffff8801278cb000 ffff8801c0447d08 ffff8801c0440000 ffffed0038088002
[ 3615.001297] Call Trace:
[ 3615.001667] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.002635] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.003921] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.005383] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.006451] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.007231] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.007918] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.008573] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.009225] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.009815] lru_add_drain_all (mm/swap.c:867)
[ 3615.010474] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.011057] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.011717] trinity-c6      S ffff880319e0fa28 27008 16587   9307 0x10000000
[ 3615.013185]  ffff880319e0fa28 ffff8802a28613b0 ffff8802a2861400 ffff880300000000
[ 3615.015400]  ffff8800261e0558 ffff8800261e0530 ffff880320e43008 ffff8801d84d0000
[ 3615.016604]  ffff880320e43000 ffff8802f8cb81b8 ffff880319e08000 ffffed00633c1002
[ 3615.017551] Call Trace:
[ 3615.017828] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.018422] pipe_wait (fs/pipe.c:114)
[ 3615.018915] ? pipe_double_lock (fs/pipe.c:104)
[ 3615.019487] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3615.020091] ? abort_exclusive_wait (kernel/sched/wait.c:292)
[ 3615.020752] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3615.021467] ? might_fault (mm/memory.c:3726)
[ 3615.022178] splice_to_pipe (fs/splice.c:251)
[ 3615.022931] ? __get_user_pages_fast (arch/x86/mm/gup.c:327)
[ 3615.023753] vmsplice_to_pipe (fs/splice.c:1601)
[ 3615.024342] ? default_file_splice_read (fs/splice.c:1574)
[ 3615.025415] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 3615.026077] ? page_cache_pipe_buf_release (fs/splice.c:266)
[ 3615.026823] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.027602] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3615.028351] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3615.028985] ? trace_hardirqs_on (kernel/locking/lockdep.c:2630)
[ 3615.029561] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.030260] ? __fget_light (fs/file.c:684)
[ 3615.030784] SyS_vmsplice (include/linux/file.h:38 fs/splice.c:1642 fs/splice.c:1623)
[ 3615.031385] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.032101] trinity-c4      D ffff880319c5fa88 26536 16616   9307 0x10000004
[ 3615.033057]  ffff880319c5fa88 ffff88031980bca8 0000000000000000 0000000000000000
[ 3615.033929]  ffff8800cf3e0558 ffff8800cf3e0530 ffff88031980b008 ffff8801d8aeb000
[ 3615.035505]  ffff88031980b000 ffff880319c5fa68 ffff880319c58000 ffffed006338b002
[ 3615.036844] Call Trace:
[ 3615.037259] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.038023] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.038965] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.039629] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.040259] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.040875] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.041589] lru_add_drain_all (mm/swap.c:867)
[ 3615.042222] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.042946] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.043996] ? migrate_pages (mm/migrate.c:1444)
[ 3615.045163] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.046205] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.047539] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.048761] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.049606] SyS_move_pages (mm/migrate.c:1440)
[ 3615.050181] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.050790] trinity-c7      D ffff8801c3d1fd38 27024 16617   9194 0x10000000
[ 3615.051960]  ffff8801c3d1fd38 ffff8801bb6e0ca8 0000000000000000 0000000000000000
[ 3615.053529]  ffff88017d3e0558 ffff88017d3e0530 ffff8801bb6e0008 ffff8802f6b98000
[ 3615.055682]  ffff8801bb6e0000 ffff8801c3d1fd18 ffff8801c3d18000 ffffed00387a3002
[ 3615.057280] Call Trace:
[ 3615.057612] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.058098] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.059225] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.059840] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.060679] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.061305] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.062140] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.062857] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.064015] lru_add_drain_all (mm/swap.c:867)
[ 3615.065432] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.066500] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.067420] trinity-c5      D ffff8802f28a7a88 26552 16667   9518 0x10000000
[ 3615.068358]  ffff8802f28a7a88 ffff8802f5c30ca8 0000000000000000 0000000000000000
[ 3615.069138]  ffff8801291e0558 ffff8801291e0530 ffff8802f5c30008 ffff88065d1d8000
[ 3615.070005]  ffff8802f5c30000 ffff8802f28a7a68 ffff8802f28a0000 ffffed005e514002
[ 3615.071683] Call Trace:
[ 3615.071957] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.072430] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.073392] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.074722] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.076471] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.077138] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.077946] lru_add_drain_all (mm/swap.c:867)
[ 3615.078578] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.079119] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.079701] ? migrate_pages (mm/migrate.c:1444)
[ 3615.080311] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.080992] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.081731] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.082393] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.083285] SyS_move_pages (mm/migrate.c:1440)
[ 3615.083883] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.084442] trinity-c0      D ffff8801d9b87a28 28320 16687   9518 0x10000000
[ 3615.085376]  ffff8801d9b87a28 ffff8801d84d0ca8 0000000000000000 0000000000000000
[ 3615.086254]  ffff8800261e0558 ffff8800261e0530 ffff8801d84d0008 ffff880004143000
[ 3615.087063]  ffff8801d84d0000 ffff8801d9b87a08 ffff8801d9b80000 ffffed003b370002
[ 3615.087853] Call Trace:
[ 3615.088134] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.088608] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.089210] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.089776] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.090421] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:87 arch/x86/kernel/kvmclock.c:85)
[ 3615.090988] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.091626] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.092266] lru_add_drain_all (mm/swap.c:867)
[ 3615.092839] migrate_prep (mm/migrate.c:64)
[ 3615.093568] do_migrate_pages (mm/mempolicy.c:999)
[ 3615.094251] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3615.094860] ? queue_pages_test_walk (mm/mempolicy.c:993)
[ 3615.095590] ? get_task_mm (kernel/fork.c:750)
[ 3615.096205] ? security_capable (security/security.c:204)
[ 3615.096791] SYSC_migrate_pages (mm/mempolicy.c:1424)
[ 3615.097524] ? SYSC_migrate_pages (include/linux/rcupdate.h:912 mm/mempolicy.c:1370)
[ 3615.098176] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.098750] ? do_migrate_pages (mm/mempolicy.c:1345)
[ 3615.099313] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.100143] SyS_migrate_pages (mm/mempolicy.c:1342)
[ 3615.100715] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.101297] trinity-c5      D ffff880176457a88 26112 16694   9194 0x10000004
[ 3615.102041]  ffff880176457a88 ffff880127ce8ca8 0000000000000000 0000000000000000
[ 3615.102888]  ffff8801291e0558 ffff8801291e0530 ffff880127ce8008 ffff88065d1d8000
[ 3615.103688]  ffff880127ce8000 ffff880176457a68 ffff880176450000 ffffed002ec8a002
[ 3615.104660] Call Trace:
[ 3615.104994] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.105742] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.106685] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.107320] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.107907] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.108511] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.109051] lru_add_drain_all (mm/swap.c:867)
[ 3615.109602] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.110219] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.111560] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3615.112453] ? migrate_pages (mm/migrate.c:1444)
[ 3615.114086] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.116177] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.117554] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.118697] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.119739] SyS_move_pages (mm/migrate.c:1440)
[ 3615.120761] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.121688] trinity-c3      D ffff8800a189fd28 26688 16717   9307 0x10000000
[ 3615.122915]  ffff8800a189fd28 ffff8800a3b68ca8 0000000000000000 0000000000000000
[ 3615.124429]  ffff8800a73e0558 ffff8800a73e0530 ffff8800a3b68008 ffff8801d84d3000
[ 3615.125929]  ffff8800a3b68000 ffff8800a189fd08 ffff8800a1898000 ffffed0014313002
[ 3615.127143] Call Trace:
[ 3615.127515] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.128356] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.129283] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.130157] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.131064] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.132042] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.132941] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.133867] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.134970] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.136053] lru_add_drain_all (mm/swap.c:867)
[ 3615.136970] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.137810] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.138636] trinity-c8      D ffff88018dc6fd28 26688 16718   9194 0x10000004
[ 3615.139692]  ffff88018dc6fd28 ffff8801a6e1bca8 0000000000000000 0000000000000000
[ 3615.141000]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a6e1b008 ffff8800256f8000
[ 3615.142157]  ffff8801a6e1b000 ffff88018dc6fd08 ffff88018dc68000 ffffed0031b8d002
[ 3615.143465] Call Trace:
[ 3615.143955] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.144755] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.146284] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.147266] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.148186] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.149193] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.150459] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.151295] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.152328] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.153718] lru_add_drain_all (mm/swap.c:867)
[ 3615.154629] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.155553] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.156442] trinity-c6      D ffff88014447fd38 26600 16727   9086 0x10000000
[ 3615.157712]  ffff88014447fd38 ffff88013ef10ca8 0000000000000000 0000000000000000
[ 3615.158976]  ffff8801533e0558 ffff8801533e0530 ffff88013ef10008 ffff88079d1e8000
[ 3615.160165]  ffff88013ef10000 ffff88014447fd18 ffff880144478000 ffffed002888f002
[ 3615.161349] Call Trace:
[ 3615.161743] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.162508] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.163824] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.164679] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.165789] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.166889] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.167887] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.168907] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.169821] lru_add_drain_all (mm/swap.c:867)
[ 3615.170710] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.171537] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.172473] trinity-c9      R  running task    27168 16739   9518 0x10080000
[ 3615.173863]  ffffffffa72e6ffc ffff8801fa268910 00000000001e8000 0140000000000000
[ 3615.175332]  0000000000004294 ffff8801d11e5000 0000000000000000 ffff8801da9efe58
[ 3615.176648]  ffff8801da9eff18 0000000000000086 ffff8801da9f0000 0000000000000086
[ 3615.177933] Call Trace:
[ 3615.178343] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3615.179328] ? kill_pid (kernel/signal.c:2899)
[ 3615.180090] ? find_get_pid (kernel/pid.c:490)
[ 3615.180910] ? rcu_eqs_enter (kernel/rcu/tree.c:637)
[ 3615.181923] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.183456] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3615.185102] ? tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.186515] trinity-c1      D ffff8801a46afd38 28400 16745   9194 0x10000000
[ 3615.187838]  ffff8801a46afd38 ffff8801a0a88ca8 0000000000000000 0000000000000000
[ 3615.189382]  ffff8800533e0558 ffff8800533e0530 ffff8801a0a88008 ffff8801278cb000
[ 3615.190620]  ffff8801a0a88000 ffff8801a46afd18 ffff8801a46a8000 ffffed00348d5002
[ 3615.191902] Call Trace:
[ 3615.192302] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.193150] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.194254] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.195218] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.196419] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3615.197898] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.198997] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.199828] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.200767] lru_add_drain_all (mm/swap.c:867)
[ 3615.201677] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.202947] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3615.204326] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.205374] ia32_do_call (arch/x86/ia32/ia32entry.S:486)
[ 3615.206547] trinity-c0      D ffff88015db27a88 26944 16748   9307 0x10000004
[ 3615.207868]  ffff88015db27a88 ffff88012889bca8 0000000000000000 0000000000000000
[ 3615.209179]  ffff8800261e0558 ffff8800261e0530 ffff88012889b008 ffff880223d7b000
[ 3615.210480]  ffff88012889b000 ffff88015db27a68 ffff88015db20000 ffffed002bb64002
[ 3615.211837] Call Trace:
[ 3615.212308] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.213169] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.214852] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.216257] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.217336] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.218458] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.219301] lru_add_drain_all (mm/swap.c:867)
[ 3615.220176] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.221183] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.222266] ? migrate_pages (mm/migrate.c:1444)
[ 3615.223659] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.224543] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.225879] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.227397] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.229103] SyS_move_pages (mm/migrate.c:1440)
[ 3615.229988] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.230865] trinity-c7      D ffff88019c09fa88 26688 16749   9307 0x10000004
[ 3615.232206]  ffff88019c09fa88 ffff880128debca8 0000000000000000 0000000000000000
[ 3615.233679]  ffff88017d3e0558 ffff88017d3e0530 ffff880128deb008 ffff8808dd1e0000
[ 3615.235107]  ffff880128deb000 ffff88019c09fa68 ffff88019c098000 ffffed0033813002
[ 3615.236990] Call Trace:
[ 3615.237470] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.238370] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.239313] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.240170] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.241116] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.242094] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.243009] lru_add_drain_all (mm/swap.c:867)
[ 3615.244481] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.245874] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.246970] ? migrate_pages (mm/migrate.c:1444)
[ 3615.248008] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.249041] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.249943] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.250868] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.252065] SyS_move_pages (mm/migrate.c:1440)
[ 3615.253023] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.254421] trinity-c2      D ffff8803188ffd28 26928 16750   9307 0x10000000
[ 3615.255720]  ffff8803188ffd28 ffff880319808ca8 0000000000000000 0000000000000000
[ 3615.256696]  ffff88007d3e0558 ffff88007d3e0530 ffff880319808008 ffff8801a0a13000
[ 3615.258115]  ffff880319808000 ffff8803188ffd08 ffff8803188f8000 ffffed006311f002
[ 3615.259418] Call Trace:
[ 3615.259812] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.260614] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.261575] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.262356] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.263145] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.263747] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.264310] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.264869] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.265765] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.266396] lru_add_drain_all (mm/swap.c:867)
[ 3615.267092] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.267752] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.268747] trinity-c8      D ffff880318947d28 26424 16751   9307 0x10000004
[ 3615.269563]  ffff880318947d28 ffff880320e23ca8 0000000000000000 0000000000000000
[ 3615.270439]  ffff8801a73e0558 ffff8801a73e0530 ffff880320e23008 ffff8800256f8000
[ 3615.271314]  ffff880320e23000 ffff880318947d08 ffff880318940000 ffffed0063128002
[ 3615.272336] Call Trace:
[ 3615.272612] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.273212] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.273865] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.274524] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.276028] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.277187] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.278447] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.279275] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.280254] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.281158] lru_add_drain_all (mm/swap.c:867)
[ 3615.282237] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.283057] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.284327] trinity-c8      D ffff8801f917fd38 27184 16755   9518 0x10000004
[ 3615.285789]  ffff8801f917fd38 ffff8801fae23ca8 0000000000000000 0000000000000000
[ 3615.287325]  ffff8801a73e0558 ffff8801a73e0530 ffff8801fae23008 ffff8800256f8000
[ 3615.288579]  ffff8801fae23000 ffff8801f917fd18 ffff8801f9178000 ffffed003f22f002
[ 3615.289732] Call Trace:
[ 3615.290114] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.291040] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.292112] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.293428] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.294807] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.296271] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.297749] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.298748] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.299622] lru_add_drain_all (mm/swap.c:867)
[ 3615.300704] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.301611] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.302998] trinity-c3      D ffff880277c27d28 26800 16764   9086 0x10000000
[ 3615.304751]  ffff880277c27d28 ffff8802751e8ca8 0000000000000000 0000000000000000
[ 3615.307367]  ffff8802a33e0558 ffff8802a33e0530 ffff8802751e8008 ffff8802ccde0000
[ 3615.309016]  ffff8802751e8000 ffff880277c27d08 ffff880277c20000 ffffed004ef84002
[ 3615.310187] Call Trace:
[ 3615.310619] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.311391] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.312978] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.314476] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.315914] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.317731] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.319315] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.320172] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.321349] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.322800] lru_add_drain_all (mm/swap.c:867)
[ 3615.324144] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.325289] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.326859] trinity-c4      D ffff8801dcc8fd38 27024 16775   9518 0x10000004
[ 3615.328291]  ffff8801dcc8fd38 ffff8801d8aebca8 0000000000000000 0000000000000000
[ 3615.329437]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8801d8aeb008 ffff8802550fb000
[ 3615.330843]  ffff8801d8aeb000 ffff8801dcc8fd18 ffff8801dcc88000 ffffed003b991002
[ 3615.332138] Call Trace:
[ 3615.332519] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.333467] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.335003] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.336701] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.337803] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.338709] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.339536] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.340554] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.341462] lru_add_drain_all (mm/swap.c:867)
[ 3615.342749] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.344063] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.345114] trinity-c8      D ffff880277c97a88 26960 16795   9086 0x10000004
[ 3615.347218]  ffff880277c97a88 ffff880278e0bca8 0000000000000000 0000000000000000
[ 3615.348595]  ffff8801a73e0558 ffff8801a73e0530 ffff880278e0b008 ffff8800256f8000
[ 3615.349742]  ffff880278e0b000 ffff880277c97a68 ffff880277c90000 ffffed004ef92002
[ 3615.350983] Call Trace:
[ 3615.351363] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.352391] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.353626] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.354586] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.356370] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.357465] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.358398] lru_add_drain_all (mm/swap.c:867)
[ 3615.359248] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.360083] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.361217] ? migrate_pages (mm/migrate.c:1444)
[ 3615.362171] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.363118] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.364029] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.365021] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.367164] SyS_move_pages (mm/migrate.c:1440)
[ 3615.368489] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.369298] trinity-c4      D ffff880277d57a88 27304 16801   9086 0x10000004
[ 3615.370429]  ffff880277d57a88 ffff880278120ca8 0000000000000000 0000000000000000
[ 3615.371773]  ffff8800cf3e0558 ffff8800cf3e0530 ffff880278120008 ffff8802550fb000
[ 3615.373315]  ffff880278120000 ffff880277d57a68 ffff880277d50000 ffffed004efaa002
[ 3615.374703] Call Trace:
[ 3615.375317] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.376916] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.378189] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.379051] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.379923] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.380990] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.382162] lru_add_drain_all (mm/swap.c:867)
[ 3615.383457] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.385010] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.386555] ? migrate_pages (mm/migrate.c:1444)
[ 3615.387741] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.388777] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.389686] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.390913] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.392287] SyS_move_pages (mm/migrate.c:1440)
[ 3615.393200] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.394097] trinity-c3      D ffff8801e6777a88 28400 16829   9518 0x10000004
[ 3615.395652]  ffff8801e6777a88 ffff8801d9c2bca8 0000000000000000 0000000000000000
[ 3615.397000]  ffff8800a73e0558 ffff8800a73e0530 ffff8801d9c2b008 ffff8801d84d3000
[ 3615.398412]  ffff8801d9c2b000 ffff8801e6777a68 ffff8801e6770000 ffffed003ccee002
[ 3615.399553] Call Trace:
[ 3615.399920] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.400883] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.401971] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.402945] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.404119] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.405250] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.407490] lru_add_drain_all (mm/swap.c:867)
[ 3615.408576] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.409442] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.410433] ? migrate_pages (mm/migrate.c:1444)
[ 3615.411348] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.412343] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.413408] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.414565] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.416585] SyS_move_pages (mm/migrate.c:1440)
[ 3615.417521] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.418516] trinity-c9      D ffff8802751ffa88 27184 16833   9086 0x10000000
[ 3615.419681]  ffff8802751ffa88 ffff88027771bca8 0000000000000000 0000000000000000
[ 3615.420976]  ffff8801d11e0558 ffff8801d11e0530 ffff88027771b008 ffff88010dc53000
[ 3615.422676]  ffff88027771b000 ffff8802751ffa68 ffff8802751f8000 ffffed004ea3f002
[ 3615.424278] Call Trace:
[ 3615.424854] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.426520] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.427903] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.428972] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.429883] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.431008] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.432171] lru_add_drain_all (mm/swap.c:867)
[ 3615.433621] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.434543] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.436166] ? migrate_pages (mm/migrate.c:1444)
[ 3615.437765] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.439043] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.439945] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.441172] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.442528] SyS_move_pages (mm/migrate.c:1440)
[ 3615.444008] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.445288] trinity-c1      D ffff8801e676fd28 28256 16844   9518 0x10000000
[ 3615.447114]  ffff8801e676fd28 ffff8801f7590ca8 0000000000000000 0000000000000000
[ 3615.448444]  ffff8800533e0558 ffff8800533e0530 ffff8801f7590008 ffff8801a0a88000
[ 3615.449678]  ffff8801f7590000 ffff8801e676fd08 ffff8801e6768000 ffffed003cced002
[ 3615.451645] Call Trace:
[ 3615.452218] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.453673] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.456569] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.457773] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.458773] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.459639] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.460596] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.461620] lru_add_drain_all (mm/swap.c:867)
[ 3615.462699] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.464307] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.465291] ia32_do_call (arch/x86/ia32/ia32entry.S:486)
[ 3615.466774] trinity-c1      D ffff8803195e7d38 28448 16850   9307 0x10000004
[ 3615.467999]  ffff8803195e7d38 ffff880311ca3ca8 0000000000000000 0000000000000000
[ 3615.469202]  ffff8800533e0558 ffff8800533e0530 ffff880311ca3008 ffff8801d0dd0000
[ 3615.470527]  ffff880311ca3000 ffff8803195e7d18 ffff8803195e0000 ffffed00632bc002
[ 3615.471763] Call Trace:
[ 3615.472408] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.473597] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.475236] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.477166] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.478797] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.479689] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.480582] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.481666] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.482713] lru_add_drain_all (mm/swap.c:867)
[ 3615.483959] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.485537] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.487254] trinity-c2      D ffff88007cbbfd28 26960 16869   9410 0x10000004
[ 3615.488756]  ffff88007cbbfd28 ffff88007b860ca8 0000000000000000 0000000000000000
[ 3615.489963]  ffff8801fb3e0558 ffff8801fb3e0530 ffff88007b860008 ffff8801fa5b3000
[ 3615.491282]  ffff88007b860000 ffff88007cbbfd08 ffff88007cbb8000 ffffed000f977002
[ 3615.492581] Call Trace:
[ 3615.493029] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.493852] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.496998] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.498379] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.499293] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.500280] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.501431] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.502404] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.503675] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.505077] lru_add_drain_all (mm/swap.c:867)
[ 3615.506698] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.507629] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.508594] trinity-c9      R  running task    28704 16921   9307 0x10000000
[ 3615.509699]  ffff880319dcfda8 ffff880319dcfd98 ffff880311ca0000 ffff880311ca0ca8
[ 3615.510992]  ffff8801d11e0558 ffff8801d11e0530 ffff880311ca0768 ffff8801fa268000
[ 3615.512340]  ffff880311ca0000 ffff880319dcfda8 ffff880319dc8000 ffffed00633b9002
[ 3615.513745] Call Trace:
[ 3615.514233] preempt_schedule_context (kernel/sched/core.c:2927 include/linux/jump_label.h:114 include/linux/context_tracking_state.h:28 include/linux/context_tracking.h:48 kernel/sched/core.c:2928)
[ 3615.516008] ___preempt_schedule_context (arch/x86/lib/thunk_64.S:53)
[ 3615.518075] ? __perf_sw_event (kernel/events/core.c:6102)
[ 3615.519188] __do_page_fault (include/linux/perf_event.h:745 arch/x86/mm/fault.c:1275)
[ 3615.520025] trace_do_page_fault (arch/x86/mm/fault.c:1327 include/linux/jump_label.h:114 include/linux/context_tracking_state.h:28 include/linux/context_tracking.h:48 arch/x86/mm/fault.c:1328)
[ 3615.521357] do_async_page_fault (arch/x86/kernel/kvm.c:280)
[ 3615.522709] async_page_fault (arch/x86/kernel/entry_64.S:1247)
[ 3615.523625] trinity-c7      D ffff8801fd9c7aa8 26688 16935   9518 0x10000000
[ 3615.525214]  ffff8801fd9c7aa8 ffff8801fd9c7a48 ffffffffb802b7e0 ffffed0100000000
[ 3615.528062]  ffff88017d3e0558 ffff88017d3e0530 ffff8801ee47b008 ffff8801bb6e0000
[ 3615.529887]  ffff8801ee47b000 ffffed002fa7c0d2 ffff8801fd9c0000 ffffed003fb38002
[ 3615.531155] Call Trace:
[ 3615.531560] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.532609] schedule_timeout (kernel/time/timer.c:1475)
[ 3615.533650] ? console_conditional_schedule (kernel/time/timer.c:1460)
[ 3615.534961] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 3615.536960] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3615.539059] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 3615.539912] ? mark_held_locks (kernel/locking/lockdep.c:2546)
[ 3615.540903] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3615.542034] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3615.543579] wait_for_completion (include/linux/spinlock.h:342 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3615.545156] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 3615.546833] ? out_of_line_wait_on_atomic_t (kernel/sched/completion.c:121)
[ 3615.547976] ? wake_up_state (kernel/sched/core.c:2973)
[ 3615.548805] flush_work (kernel/workqueue.c:510 kernel/workqueue.c:2735)
[ 3615.549610] ? flush_work (kernel/workqueue.c:2706 kernel/workqueue.c:2733)
[ 3615.550487] ? __queue_work (kernel/workqueue.c:1388)
[ 3615.551481] ? work_busy (kernel/workqueue.c:2727)
[ 3615.552403] ? destroy_worker (kernel/workqueue.c:2320)
[ 3615.553302] ? wait_for_completion (kernel/sched/completion.c:64 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
[ 3615.554486] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2580 kernel/locking/lockdep.c:2622)
[ 3615.556238] lru_add_drain_all (include/linux/cpumask.h:116 include/linux/cpumask.h:189 mm/swap.c:883)
[ 3615.557283] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.558366] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.559172] trinity-c4      D ffff88024b4a7d28 27136 16966   9410 0x10000004
[ 3615.560286]  ffff88024b4a7d28 ffff88021aff0ca8 0000000000000000 0000000000000000
[ 3615.561496]  ffff8800cf3e0558 ffff8800cf3e0530 ffff88021aff0008 ffff8802550fb000
[ 3615.563168]  ffff88021aff0000 ffff88024b4a7d08 ffff88024b4a0000 ffffed0049694002
[ 3615.564873] Call Trace:
[ 3615.565668] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.567835] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.568725] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.569278] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.569907] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.570654] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.571263] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.572209] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.573100] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.573786] lru_add_drain_all (mm/swap.c:867)
[ 3615.574471] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.575094] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.576280] trinity-c2      D ffff880258877d38 26456 16986   9518 0x10000004
[ 3615.577555]  ffff880258877d38 ffff88029c010ca8 0000000000000000 0000000000000000
[ 3615.578748]  ffff88007d3e0558 ffff88007d3e0530 ffff88029c010008 ffff8802ccdd8000
[ 3615.579497]  ffff88029c010000 ffff880258877d18 ffff880258870000 ffffed004b10e002
[ 3615.580298] Call Trace:
[ 3615.580635] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.581283] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.582024] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.583042] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.583723] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.584419] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.585678] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.586492] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.587182] lru_add_drain_all (mm/swap.c:867)
[ 3615.587753] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.588554] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.589095] trinity-c0      D ffff880014dbfd28 27696 16993   9086 0x10000004
[ 3615.589840]  ffff880014dbfd28 ffff880004143ca8 0000000000000000 0000000000000000
[ 3615.590755]  ffff8800261e0558 ffff8800261e0530 ffff880004143008 ffff88012889b000
[ 3615.591568]  ffff880004143000 ffff880014dbfd08 ffff880014db8000 ffffed00029b7002
[ 3615.592523] Call Trace:
[ 3615.592777] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.593368] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.594066] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.594689] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.595899] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.596870] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.597599] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.598534] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.599161] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.599727] lru_add_drain_all (mm/swap.c:867)
[ 3615.600290] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.600888] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.601422] trinity-subchil R  running task    29776 17003  16739 0x10000000
[ 3615.602393]  ffff88027bf1fd28 ffff8801bb6e3ca8 0000000000000000 0000000000000000
[ 3615.603394]  ffff8801d11e0558 ffff8801d11e0530 ffff8801bb6e3008 ffff8801d0fcb000
[ 3615.604154]  ffff8801bb6e3000 ffff88027bf1fd08 ffff88027bf18000 ffffed004f7e3002
[ 3615.605255] Call Trace:
[ 3615.605740] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.606682] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.607768] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.608629] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.609193] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.609840] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.610510] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.611165] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.611829] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.612444] lru_add_drain_all (mm/swap.c:867)
[ 3615.613056] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.613605] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.614183] trinity-c4      D ffff8802806a7d38 27328 17019   9194 0x10000004
[ 3615.615441]  ffff8802806a7d38 ffff8802550fbca8 0000000000000000 0000000000000000
[ 3615.616601]  ffff8800cf3e0558 ffff8800cf3e0530 ffff8802550fb008 ffff880518df0000
[ 3615.617518]  ffff8802550fb000 ffff8802806a7d18 ffff8802806a0000 ffffed00500d4002
[ 3615.618910] Call Trace:
[ 3615.619154] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.619633] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.620248] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.620877] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.621474] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.622412] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.623135] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.623784] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.624366] lru_add_drain_all (mm/swap.c:867)
[ 3615.625686] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.626691] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.627271] trinity-c9      R  running task    32576 17044  16739 0x100c0000
[ 3615.628298]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[ 3615.629041]  00007ffd55786260 00007ffd55786220 0000000000000246 00007fb1dfa0a9d0
[ 3615.629809]  0000000000004163 0000000000004163 0000000000000000 00007fb1df527576
[ 3615.630699] Call Trace:
[ 3615.630945] trinity-c0      D ffff8802198e7d38 28496 17063   9410 0x10000004
[ 3615.631847]  ffff8802198e7d38 ffff880223d7bca8 0000000000000000 0000000000000000
[ 3615.632643]  ffff8800261e0558 ffff8800261e0530 ffff880223d7b008 ffffffffb4839100
[ 3615.633619]  ffff880223d7b000 ffff8802198e7d18 ffff8802198e0000 ffffed004331c002
[ 3615.634428] Call Trace:
[ 3615.634698] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.635636] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.636569] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.637439] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.638330] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.639078] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.639646] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.640409] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.641140] lru_add_drain_all (mm/swap.c:867)
[ 3615.641747] SyS_mlockall (include/linux/sched.h:3075 include/linux/sched.h:3086 mm/mlock.c:698 mm/mlock.c:683)
[ 3615.642726] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.643593] trinity-c7      D ffff88017bdafd28 27328 17084   9086 0x10000004
[ 3615.644470]  ffff88017bdafd28 ffff88017cacbca8 0000000000000000 0000000000000000
[ 3615.645950]  ffff88017d3e0558 ffff88017d3e0530 ffff88017cacb008 ffff880128deb000
[ 3615.646852]  ffff88017cacb000 ffff88017bdafd08 ffff88017bda8000 ffffed002f7b5002
[ 3615.647819] Call Trace:
[ 3615.648087] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.648580] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.649261] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.649858] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.650443] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.651113] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.651805] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.652727] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.653521] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.654199] lru_add_drain_all (mm/swap.c:867)
[ 3615.654984] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.655507] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.656049] trinity-c3      D ffff880081fafd28 28416 17096   9194 0x10000004
[ 3615.657306]  ffff880081fafd28 ffff880085d20ca8 0000000000000000 0000000000000000
[ 3615.658604]  ffff8800a73e0558 ffff8800a73e0530 ffff880085d20008 ffff8803c8de8000
[ 3615.659384]  ffff880085d20000 ffff880081fafd08 ffff880081fa8000 ffffed00103f5002
[ 3615.660189] Call Trace:
[ 3615.660504] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.661038] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.661741] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.662420] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.663064] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.663716] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.664341] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.665206] ? context_tracking_user_exit (kernel/context_tracking.c:164)
[ 3615.666642] ? perf_syscall_exit (kernel/trace/trace_syscalls.c:549)
[ 3615.667440] lru_add_drain_all (mm/swap.c:867)
[ 3615.668091] SyS_mlock (mm/mlock.c:618 mm/mlock.c:607)
[ 3615.668640] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.669159] trinity-c5      D ffff880319e5fa88 28688 17097   9307 0x10000004
[ 3615.669935]  ffff880319e5fa88 ffff880319c78ca8 0000000000000000 0000000000000000
[ 3615.670701]  ffff8801291e0558 ffff8801291e0530 ffff880319c78008 ffff88065d1d8000
[ 3615.671527]  ffff880319c78000 ffff880319e5fa68 ffff880319e58000 ffffed00633cb002
[ 3615.672511] Call Trace:
[ 3615.672763] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.673317] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.674159] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.675072] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.676746] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.678264] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.678838] lru_add_drain_all (mm/swap.c:867)
[ 3615.679388] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.679948] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.680681] ? migrate_pages (mm/migrate.c:1444)
[ 3615.681275] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.682117] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.682829] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.683544] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.684185] SyS_move_pages (mm/migrate.c:1440)
[ 3615.684806] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.686162] trinity-c8      D ffff88017e677a88 26584 17105   9410 0x10000004
[ 3615.687417]  ffff88017e677a88 ffff8801a60f8ca8 0000000000000000 0000000000000000
[ 3615.688503]  ffff8801a73e0558 ffff8801a73e0530 ffff8801a60f8008 ffff8800256f8000
[ 3615.689250]  ffff8801a60f8000 ffff88017e677a68 ffff88017e670000 ffffed002fcce002
[ 3615.690041] Call Trace:
[ 3615.690453] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.690948] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.691769] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.692554] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.693526] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.694106] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.694585] lru_add_drain_all (mm/swap.c:867)
[ 3615.695741] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.696262] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.697351] ? migrate_pages (mm/migrate.c:1444)
[ 3615.698233] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.698935] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.699531] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.700318] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.701081] SyS_move_pages (mm/migrate.c:1440)
[ 3615.701651] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.702212] trinity-c6      D ffff8801eb6f7a88 28496 17117   9518 0x10000004
[ 3615.703038]  ffff8801eb6f7a88 ffff8801d8ae8ca8 0000000000000000 0000000000000000
[ 3615.703920]  ffff8801533e0558 ffff8801533e0530 ffff8801d8ae8008 ffff88079d1e8000
[ 3615.705080]  ffff8801d8ae8000 ffff8801eb6f7a68 ffff8801eb6f0000 ffffed003d6de002
[ 3615.706299] Call Trace:
[ 3615.706554] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.707067] schedule_preempt_disabled (kernel/sched/core.c:2859)
[ 3615.707819] mutex_lock_nested (kernel/locking/mutex.c:585 kernel/locking/mutex.c:623)
[ 3615.708489] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.709084] ? lru_add_drain_all (mm/swap.c:867)
[ 3615.709691] ? mutex_trylock (kernel/locking/mutex.c:621)
[ 3615.710388] lru_add_drain_all (mm/swap.c:867)
[ 3615.710964] SYSC_move_pages (mm/migrate.c:1301 mm/migrate.c:1495)
[ 3615.711586] ? SYSC_move_pages (include/linux/rcupdate.h:912 mm/migrate.c:1459)
[ 3615.712246] ? migrate_pages (mm/migrate.c:1444)
[ 3615.712854] ? rcu_read_lock_sched_held (./arch/x86/include/asm/paravirt.h:804 include/linux/rcupdate.h:512)
[ 3615.713687] ? trace_rcu_dyntick (include/trace/events/rcu.h:363 (discriminator 19))
[ 3615.714345] ? rcu_eqs_exit_common (kernel/rcu/tree.c:735 (discriminator 8))
[ 3615.715117] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1592)
[ 3615.716285] SyS_move_pages (mm/migrate.c:1440)
[ 3615.716820] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.717510] sleep           S ffff880019777c88 25688 17155   8613 0x10000000
[ 3615.718476]  ffff880019777c88 0000000000000000 0000000df8475800 0000000000000000
[ 3615.719260]  ffff8800261e0558 ffff8800261e0530 ffff880004140008 ffffffffb4839100
[ 3615.720041]  ffff880004140000 ffff880019777c68 ffff880019770000 ffffed00032ee002
[ 3615.720926] Call Trace:
[ 3615.721186] schedule (./arch/x86/include/asm/bitops.h:311 (discriminator 1) kernel/sched/core.c:2827 (discriminator 1))
[ 3615.721827] do_nanosleep (./arch/x86/include/asm/current.h:14 include/linux/freezer.h:120 include/linux/freezer.h:172 kernel/time/hrtimer.c:1502)
[ 3615.722505] ? schedule_timeout_uninterruptible (kernel/time/hrtimer.c:1492)
[ 3615.723295] ? memset (mm/kasan/kasan.c:269)
[ 3615.723804] hrtimer_nanosleep (kernel/time/hrtimer.c:1571)
[ 3615.724438] ? hrtimer_run_queues (kernel/time/hrtimer.c:1559)
[ 3615.725334] ? hrtimer_get_res (kernel/time/hrtimer.c:1472)
[ 3615.726019] ? do_nanosleep (kernel/time/hrtimer.c:1024 (discriminator 1) include/linux/hrtimer.h:376 (discriminator 1) kernel/time/hrtimer.c:1497 (discriminator 1))
[ 3615.727107] SyS_nanosleep (kernel/time/hrtimer.c:1609 kernel/time/hrtimer.c:1598)
[ 3615.727715] ? hrtimer_nanosleep (kernel/time/hrtimer.c:1598)
[ 3615.728397] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 3615.729027] tracesys_phase2 (arch/x86/kernel/entry_64.S:344)
[ 3615.729612] Sched Debug Version: v0.11, 4.0.0-rc5-next-20150324-sasha-00038-g04b74cc #2088
[ 3615.731466] ktime                                   : 3615729.610789
[ 3615.732533] sched_clk                               : 16518191060.305405
[ 3615.734022] cpu_clk                                 : 3615729.608757
[ 3615.735925] jiffies                                 : 4295298870
[ 3615.737894] sched_clock_stable()                    : 0
[ 3615.738759]
[ 3615.738991] sysctl_sched
[ 3615.739404]   .sysctl_sched_latency                    : 24.000000
[ 3615.740348]   .sysctl_sched_min_granularity            : 3.000000
[ 3615.741302]   .sysctl_sched_wakeup_granularity         : 4.000000
[ 3615.742310]   .sysctl_sched_child_runs_first           : 0
[ 3615.743202]   .sysctl_sched_features                   : 220795
[ 3615.744314]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[ 3615.746261]
[ 3615.746555] cpu#0, 2260.998 MHz
[ 3615.747141]   .nr_running                    : 0
[ 3615.747868]   .load                          : 0
[ 3615.748531]   .nr_switches                   : 615758
[ 3615.749351]   .nr_load_updates               : 361575
[ 3615.750135]   .nr_uninterruptible            : 177
[ 3615.751018]   .next_balance                  : 4295.298875
[ 3615.752075]   .curr->pid                     : 0
[ 3615.752824]   .clock                         : 3615746.385414
[ 3615.753882]   .clock_task                    : 3599162.407561
[ 3615.754992]   .cpu_load[0]                   : 0
[ 3615.755964]   .cpu_load[1]                   : 0
[ 3615.756805]   .cpu_load[2]                   : 0
[ 3615.757666]   .cpu_load[3]                   : 0
[ 3615.758395]   .cpu_load[4]                   : 0
[ 3615.759051]   .yld_count                     : 723
[ 3615.759735]   .sched_count                   : 618837
[ 3615.760618]   .sched_goidle                  : 153149
[ 3615.761503]   .avg_idle                      : 1000000
[ 3615.762650]   .max_idle_balance_cost         : 500000
[ 3615.763576]   .ttwu_count                    : 2760015
[ 3615.764397]   .ttwu_local                    : 248208
[ 3615.765834]
[ 3615.765834] cfs_rq[0]:/
[ 3615.766503]   .exec_clock                    : 983515.442755
[ 3615.767517]   .MIN_vruntime                  : 0.000001
[ 3615.768281]   .min_vruntime                  : 7674672.933213
[ 3615.769097]   .max_vruntime                  : 0.000001
[ 3615.769857]   .spread                        : 0.000000
[ 3615.770798]   .spread0                       : 0.000000
[ 3615.771574]   .nr_spread_over                : 1997
[ 3615.772408]   .nr_running                    : 0
[ 3615.773088]   .load                          : 0
[ 3615.773853]   .runnable_load_avg             : 0
[ 3615.774563]   .blocked_load_avg              : 0
[ 3615.775441]   .tg_load_contrib               : 0
[ 3615.775441]   .tg_runnable_contrib           : 11
[ 3615.775441]   .tg_load_avg                   : 2140
[ 3615.775441]   .tg->runnable_avg              : 2060
[ 3615.775441]   .tg->cfs_bandwidth.timer_active: 0
[ 3615.775441]   .throttled                     : 0
[ 3615.775441]   .throttle_count                : 0
[ 3615.775441]   .avg->runnable_avg_sum         : 554
[ 3615.775441]   .avg->runnable_avg_period      : 47965
[ 3615.775441]
[ 3615.775441] rt_rq[0]:/
[ 3615.775441]   .rt_nr_running                 : 0
[ 3615.775441]   .rt_throttled                  : 0
[ 3615.775441]   .rt_time                       : 10.523234
[ 3615.775441]   .rt_runtime                    : 895.573845
[ 3615.775441]
[ 3615.775441] dl_rq[0]:
[ 3615.775441]   .dl_nr_running                 : 0
[ 3615.775441]
[ 3615.775441] runnable tasks:
[ 3615.775441]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3615.775441] ----------------------------------------------------------------------------------------------------------
[ 3615.775441]      ksoftirqd/0     3     47264.105318         9   120     47264.105318         0.340679     89055.899635 0 /
[ 3615.775441]     kworker/0:0H     5      1846.728363         7   100      1846.728363         0.389413     12237.961931 0 /
[ 3615.775441]      rcu_preempt     8         0.000000    202525     0         0.000000     43599.534091         0.000000 0 /
[ 3615.775441]           rcu_bh    10         0.000000         2     0         0.000000         0.033653         0.000000 0 /
[ 3615.775441]          rcuop/0    11   7674663.712219     18895   120   7674663.712219     32158.847823   3538049.654907 0 /
[ 3615.775441]          rcuob/0    13       172.754139         3   120       172.754139         0.073506         1.288812 0 /
[ 3615.775441]      migration/0    14         0.000000       382     0         0.000000        91.002944         0.000000 0 /
[ 3615.775441]       watchdog/0    15         0.000000       907     0         0.000000       103.951028         0.000000 0 /
[ 3615.775441]      kworker/0:1  3575   7674661.367734     14771   120   7674661.367734      3055.664616   3494375.481519 0 /
[ 3615.775441]          kswapd0  3785   7316655.776258     10885   120   7316655.776258     21766.899234   1373167.704296 0 /
[ 3615.775441]         kswapd57  3842      1845.776332         3   120      1845.776332         0.494778        98.622960 0 /
[ 3615.775441]         pdecrypt  4202      1883.899161         2   100      1883.899161         0.278102         0.253816 0 /
[ 3615.775441]         vballoon  4409      2038.305701         2   120      2038.305701         0.384439         0.330747 0 /
[ 3615.775441]    kworker/u49:1  5290   7666195.958895       563   120   7666195.958895       100.886930   1423922.714240 0 /
[ 3615.775441]    kworker/u68:0  5327    118306.515495     15752   100    118306.515495      7992.455356    251433.715172 0 /
[ 3615.775441]         iscsi_eh  5669      2661.786439         3   100      2661.786439         0.656884         0.885584 0 /
[ 3615.775441]     fcoethread/0  5684      2662.013760         2   100      2662.013760         0.619172         0.687713 0 /
[ 3615.775441]  bnx2fc_thread/0  5710      2662.064844         2   100      2662.064844         0.383463         0.678593 0 /
[ 3615.775441]   bnx2i_thread/0  5779      2663.465608         2   100      2663.465608         0.245175         0.123460 0 /
[ 3615.775441]               sh  8301        90.103717       271   120        90.103717        87.563812       117.580948 0 /autogroup-1
[ 3615.775441]       runtrin.sh  8613    453169.321687       391   120    453169.321687       573.926061   3488413.174899 0 /autogroup-1
[ 3615.775441]    kworker/u68:1  8867     50570.739162         2   100     50570.739162         0.674640         0.463839 0 /
[ 3615.775441]      kworker/0:2 26057   3170008.959591         2   120   3170008.959591         0.111444         0.135917 0 /
[ 3615.775441]    kworker/u49:2 29215   6550496.521882       812   120   6550496.521882       152.749114    345504.089345 0 /
[ 3615.775441]       trinity-c0 14641    451575.432301      1092   120    451575.432301      6538.593433     20608.343823 0 /autogroup-1
[ 3615.775441]       trinity-c6 16587       240.027736        95   120       240.027736       970.087200       251.425312 0 /autogroup-2073
[ 3615.775441]       trinity-c0 16687    451556.110077       295   120    451556.110077      1662.273044      1762.554195 0 /autogroup-1
[ 3615.775441]       trinity-c0 16748    452019.058286       317   120    452019.058286      1943.792690      1834.638167 0 /autogroup-1
[ 3615.775441]       trinity-c0 16993        82.887240       213   120        82.887240      1350.834490        36.695510 0 /autogroup-2100
[ 3615.775441]       trinity-c0 17063    452121.559438        73   120    452121.559438       582.241547         0.000000 0 /autogroup-1
[ 3615.775441]            sleep 17155    453207.220440        85   120    453207.220440        35.385973        29.824220 0 /autogroup-1
[ 3615.850740]
[ 3615.850950] cpu#1, 2260.998 MHz
[ 3615.851302]   .nr_running                    : 0
[ 3615.851841]   .load                          : 0
[ 3615.852412]   .nr_switches                   : 391499
[ 3615.853021]   .nr_load_updates               : 361501
[ 3615.853844]   .nr_uninterruptible            : -19
[ 3615.854491]   .next_balance                  : 4295.298893
[ 3615.855377]   .curr->pid                     : 0
[ 3615.856219]   .clock                         : 3615850.408149
[ 3615.856823]   .clock_task                    : 3604389.633316
[ 3615.857589]   .cpu_load[0]                   : 0
[ 3615.858112]   .cpu_load[1]                   : 0
[ 3615.858541]   .cpu_load[2]                   : 0
[ 3615.858967]   .cpu_load[3]                   : 0
[ 3615.859402]   .cpu_load[4]                   : 0
[ 3615.859835]   .yld_count                     : 833
[ 3615.860399]   .sched_count                   : 398198
[ 3615.861066]   .sched_goidle                  : 121772
[ 3615.861801]   .avg_idle                      : 1000000
[ 3615.862523]   .max_idle_balance_cost         : 500000
[ 3615.863229]   .ttwu_count                    : 115768
[ 3615.863995]   .ttwu_local                    : 60354
[ 3615.864614]
[ 3615.864614] cfs_rq[1]:/autogroup-1
[ 3615.865367]   .exec_clock                    : 498901.516422
[ 3615.865367]   .MIN_vruntime                  : 0.000001
[ 3615.865367]   .min_vruntime                  : 794633.567985
[ 3615.865367]   .max_vruntime                  : 0.000001
[ 3615.865367]   .spread                        : 0.000000
[ 3615.865367]   .spread0                       : -6880039.365228
[ 3615.865367]   .nr_spread_over                : 2796
[ 3615.865367]   .nr_running                    : 0
[ 3615.865367]   .load                          : 0
[ 3615.865367]   .runnable_load_avg             : 0
[ 3615.865367]   .blocked_load_avg              : 19
[ 3615.865367]   .tg_load_contrib               : 19
[ 3615.865367]   .tg_runnable_contrib           : 20
[ 3615.865367]   .tg_load_avg                   : 1044
[ 3615.865367]   .tg->runnable_avg              : 1044
[ 3615.865367]   .tg->cfs_bandwidth.timer_active: 0
[ 3615.865367]   .throttled                     : 0
[ 3615.865367]   .throttle_count                : 0
[ 3615.865367]   .se->exec_start                : 3604080.799557
[ 3615.865367]   .se->vruntime                  : 9253755.248017
[ 3615.865367]   .se->sum_exec_runtime          : 498914.012477
[ 3615.865367]   .se->statistics.wait_start     : 0.000000
[ 3615.865367]   .se->statistics.sleep_start    : 0.000000
[ 3615.865367]   .se->statistics.block_start    : 0.000000
[ 3615.865367]   .se->statistics.sleep_max      : 0.000000
[ 3615.865367]   .se->statistics.block_max      : 0.000000
[ 3615.865367]   .se->statistics.exec_max       : 12.368655
[ 3615.865367]   .se->statistics.slice_max      : 459.324205
[ 3615.865367]   .se->statistics.wait_max       : 55601.118868
[ 3615.865367]   .se->statistics.wait_sum       : 374115.358464
[ 3615.865367]   .se->statistics.wait_count     : 86597
[ 3615.865367]   .se->load.weight               : 2
[ 3615.865367]   .se->avg.runnable_avg_sum      : 932
[ 3615.865367]   .se->avg.runnable_avg_period   : 46968
[ 3615.865367]   .se->avg.load_avg_contrib      : 18
[ 3615.865367]   .se->avg.decay_count           : 3437120
[ 3615.865367]
[ 3615.865367] cfs_rq[1]:/
[ 3615.865367]   .exec_clock                    : 899995.771179
[ 3615.865367]   .MIN_vruntime                  : 0.000001
[ 3615.865367]   .min_vruntime                  : 9253755.248017
[ 3615.865367]   .max_vruntime                  : 0.000001
[ 3615.865367]   .spread                        : 0.000000
[ 3615.865367]   .spread0                       : 1579082.314804
[ 3615.865367]   .nr_spread_over                : 2228
[ 3615.865367]   .nr_running                    : 0
[ 3615.865367]   .load                          : 0
[ 3615.865367]   .runnable_load_avg             : 0
[ 3615.865367]   .blocked_load_avg              : 2
[ 3615.865367]   .tg_load_contrib               : 0
[ 3615.865367]   .tg_runnable_contrib           : 2
[ 3615.865367]   .tg_load_avg                   : 2122
[ 3615.865367]   .tg->runnable_avg              : 2078
[ 3615.865367]   .tg->cfs_bandwidth.timer_active: 0
[ 3615.865367]   .throttled                     : 0
[ 3615.865367]   .throttle_count                : 0
[ 3615.865367]   .avg->runnable_avg_sum         : 135
[ 3615.865367]   .avg->runnable_avg_period      : 47812
[ 3615.865367]
[ 3615.865367] rt_rq[1]:/
[ 3615.865367]   .rt_nr_running                 : 0
[ 3615.865367]   .rt_throttled                  : 0
[ 3615.865367]   .rt_time                       : 0.000000
[ 3615.865367]   .rt_runtime                    : 1000.000000
[ 3615.865367]
[ 3615.865367] dl_rq[1]:
[ 3615.865367]   .dl_nr_running                 : 0
[ 3615.865367]
[ 3615.865367] runnable tasks:
[ 3615.865367]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3615.865367] ----------------------------------------------------------------------------------------------------------
[ 3615.865367]        rcu_sched     9         0.000000      1326     0         0.000000       348.808479         0.000000 1 /
[ 3615.865367]          rcuos/0    12   8659190.943964        22   120   8659190.943964         2.789763   1374231.363492 1 /
[ 3615.865367]       watchdog/1    16        -2.810643       908     0        -2.810643       148.967840         0.000000 1 /
[ 3615.865367]      migration/1    17         0.000000       317     0         0.000000        57.909316         0.000000 1 /
[ 3615.865367]      ksoftirqd/1    18   9252709.821462      3414   120   9252709.821462      5744.769084   1379639.041272 1 /
[ 3615.865367]     kworker/1:0H    20     10048.848361         8   100     10048.848361         0.190375     12078.593339 1 /
[ 3615.865367]          khelper   118         7.008938         2   100         7.008938         0.057516         0.250738 1 /
[ 3615.865367]        kdevtmpfs   119     27554.930681      1158   120     27554.930681       278.454881     34034.706524 1 /
[ 3615.865367]            netns   120        26.316847         2   100        26.316847         0.073981         0.263072 1 /
[ 3615.865367]             perf   123        54.514519         2   100        54.514519         0.032861         0.000000 1 /
[ 3615.865367]      kworker/1:1  3567   9253743.386392     18832   120   9253743.386392      6425.555125   3542515.489989 1 /
[ 3615.865367]    kworker/u50:1  3669   9253740.007609       917   120   9253740.007609       179.602653   3605333.274484 1 /
[ 3615.865367]          kswapd1  3786   9193214.421370       890   120   9193214.421370      9849.224293   1403579.950410 1 /
[ 3615.865367]         kswapd18  3803      8903.863007         3   120      8903.863007         0.282833       105.488264 1 /
[ 3615.865367]         kswapd19  3804      8903.840260         3   120      8903.840260         0.265256       104.539200 1 /
[ 3615.865367]         kswapd20  3805      8903.839512         3   120      8903.839512         0.274215       103.450596 1 /
[ 3615.865367]         kswapd21  3806      8903.839657         3   120      8903.839657         1.180750       101.414409 1 /
[ 3615.865367]         kswapd22  3807      8903.836945         3   120      8903.836945         0.564964        99.484924 1 /
[ 3615.865367]         kswapd23  3808      8903.837356         3   120      8903.837356         0.310226        97.822261 1 /
[ 3615.865367]         kswapd24  3809      8903.841481         3   120      8903.841481         0.363883        96.666781 1 /
[ 3615.865367]         kswapd25  3810      8903.880599         3   120      8903.880599         0.291284       104.709555 1 /
[ 3615.865367]         kswapd26  3811      8903.838923         3   120      8903.838923         0.561168       103.464978 1 /
[ 3615.865367]         kswapd27  3812      8903.842475         3   120      8903.842475         0.445586       102.203210 1 /
[ 3615.865367]         kswapd28  3813      8903.838297         3   120      8903.838297         0.455166       100.459194 1 /
[ 3615.865367]         kswapd29  3814      8903.840816         3   120      8903.840816         0.586957        98.429366 1 /
[ 3615.865367]         kswapd30  3815      8903.840186         3   120      8903.840186         0.263132        97.289683 1 /
[ 3615.865367]         kswapd31  3816      8915.955619         3   120      8915.955619         0.283652       106.006682 1 /
[ 3615.865367]         kswapd32  3817      8915.933647         3   120      8915.933647         0.261594       104.707312 1 /
[ 3615.865367]         kswapd33  3818      8915.924360         3   120      8915.924360         0.288061       103.588322 1 /
[ 3615.865367]         kswapd34  3819      8915.923617         3   120      8915.923617         0.267731       102.607057 1 /
[ 3615.865367]         kswapd35  3820      8915.923629         3   120      8915.923629         0.161615        99.603054 1 /
[ 3615.865367]         kswapd36  3821      8915.927197         3   120      8915.927197         0.277126        98.172274 1 /
[ 3615.865367]         kswapd37  3822      8915.921600         3   120      8915.921600         0.739239        96.281192 1 /
[ 3615.865367]         kswapd38  3823      8915.932576         3   120      8915.932576         0.272181       104.435303 1 /
[ 3615.865367]         kswapd39  3824      8915.925814         3   120      8915.925814         0.599881       102.653014 1 /
[ 3615.865367]         kswapd40  3825      8915.929297         4   120      8915.929297         0.816488       100.082168 1 /
[ 3615.865367]         kswapd41  3826      8915.924464         3   120      8915.924464         0.937420        96.721049 1 /
[ 3615.865367]         kswapd42  3827      8915.930715         3   120      8915.930715         0.251605       104.471323 1 /
[ 3615.865367]         kswapd43  3828      8915.927358         3   120      8915.927358         0.445509       103.324556 1 /
[ 3615.865367]         kswapd44  3829      8915.923836         3   120      8915.923836         1.006852       101.250313 1 /
[ 3615.865367]         kswapd45  3830      8915.927058         3   120      8915.927058         0.754283        98.890544 1 /
[ 3615.865367]         kswapd46  3831      8915.925163         3   120      8915.925163         0.456840        96.837027 1 /
[ 3615.865367]         kswapd47  3832      8915.934633         3   120      8915.934633         0.262604       104.588069 1 /
[ 3615.865367]         kswapd48  3833      8915.930090         3   120      8915.930090         0.334772       103.506862 1 /
[ 3615.865367]         kswapd49  3834      8915.925925         3   120      8915.925925         0.333105       102.265420 1 /
[ 3615.865367]         kswapd50  3835      8915.929287         3   120      8915.929287         0.288911        99.887834 1 /
[ 3615.865367]         kswapd51  3836      8915.925140         3   120      8915.925140         0.824888        97.864441 1 /
[ 3615.865367]         kswapd52  3837      8915.926250         3   120      8915.926250         0.357959        96.389090 1 /
[ 3615.865367]         kswapd53  3838      8915.971319         3   120      8915.971319         0.314563       104.339408 1 /
[ 3615.865367]         kswapd54  3839      8915.926727         3   120      8915.926727         0.303087       103.229979 1 /
[ 3615.865367]         kswapd55  3840      8915.925648         3   120      8915.925648         0.613031       100.683548 1 /
[ 3615.865367]         kswapd56  3841      8915.925941         3   120      8915.925941         2.089172        97.209310 1 /
[ 3615.865367]         kswapd58  3843      8915.934338         3   120      8915.934338         0.490086       103.101174 1 /
[ 3615.865367]         kswapd59  3844      8915.924906         3   120      8915.924906         0.848058       100.804849 1 /
[ 3615.865367]         kswapd60  3845      8915.927157         3   120      8915.927157         1.139059        97.575704 1 /
[ 3615.865367]         kswapd61  3846      8916.088222         3   120      8916.088222         1.646764       105.065226 1 /
[ 3615.865367]         kswapd62  3847      8915.940340         3   120      8915.940340         0.501116       104.055445 1 /
[ 3615.865367]         kswapd63  3848      8915.951755         3   120      8915.951755         1.016320       102.323147 1 /
[ 3615.865367]    fsnotify_mark  3977   8195042.160747         7   120   8195042.160747         1.465507   1301118.270676 1 /
[ 3615.865367]            hwrng  5248   9253720.060693     16780   120   9253720.060693      1686.843071   3577115.763465 1 /
[ 3615.865367]    kworker/u69:0  5328   8444658.360557        14   100   8444658.360557         4.245473   1327247.771460 1 /
[ 3615.865367]     fcoethread/1  5685     16954.957850         2   100     16954.957850         0.336449         0.114839 1 /
[ 3615.865367]  bnx2fc_thread/1  5711     16995.643576         2   100     16995.643576         0.260279         0.184195 1 /
[ 3615.865367]   bnx2i_thread/1  5780     17133.306268         2   100     17133.306268         0.283499         0.065598 1 /
[ 3615.865367]          aoe_tx0  6453   9253671.812733        62   110   9253671.812733       107.883661   3549225.051858 1 /
[ 3615.865367]    kworker/u69:1  9015     55931.208683         2   100     55931.208683         0.285984         0.000000 1 /
[ 3615.865367]  trinity-watchdo  9409    794633.567985     21550   120    794633.567985      6010.629640   3402271.846370 1 /autogroup-1
[ 3615.865367]       mount.ntfs  9521      4990.059057     77720   120      4990.059057     49193.793707   1064455.962938 1 /autogroup-3
[ 3615.865367]               sh  9598      7834.804295        79   120      7834.804295        70.478761       102.706556 1 /autogroup-1
[ 3615.865367]    kworker/u50:2  4467   9253740.265364       548   120   9253740.265364        89.318421   2422669.797408 1 /
[ 3615.865367]      kworker/1:2  9493   8810762.755602        46   120   8810762.755602         5.132619    118121.334657 1 /
[ 3615.865367]       trinity-c1 16133    793983.356521       386   120    793983.356521      3166.383121      6796.233999 1 /autogroup-1
[ 3615.865367]       trinity-c1 16509       820.462493       173   120       820.462493      1737.531183      8064.460129 1 /autogroup-2071
[ 3615.865367]       trinity-c1 16745    793984.252255        80   120    793984.252255       677.228163      2001.927043 1 /autogroup-1
[ 3615.865367]       trinity-c1 16844    793966.828101        65   120    793966.828101       913.352427      1616.220166 1 /autogroup-1
[ 3615.865367]       trinity-c1 16850    793975.000650        66   120    793975.000650       623.038255      3784.788397 1 /autogroup-1
[ 3616.033148]
[ 3616.033311] cpu#2, 2260.998 MHz
[ 3616.033629]   .nr_running                    : 0
[ 3616.034136]   .load                          : 0
[ 3616.034825]   .nr_switches                   : 329292
[ 3616.035759]   .nr_load_updates               : 361524
[ 3616.036361]   .nr_uninterruptible            : -29
[ 3616.036857]   .next_balance                  : 4295.298946
[ 3616.037588]   .curr->pid                     : 0
[ 3616.038310]   .clock                         : 3616036.498804
[ 3616.038846]   .clock_task                    : 3606694.176487
[ 3616.039375]   .cpu_load[0]                   : 0
[ 3616.039806]   .cpu_load[1]                   : 0
[ 3616.040412]   .cpu_load[2]                   : 0
[ 3616.040856]   .cpu_load[3]                   : 0
[ 3616.041343]   .cpu_load[4]                   : 0
[ 3616.041832]   .yld_count                     : 822
[ 3616.042391]   .sched_count                   : 338134
[ 3616.043042]   .sched_goidle                  : 94304
[ 3616.043573]   .avg_idle                      : 1000000
[ 3616.044123]   .max_idle_balance_cost         : 500000
[ 3616.044677]   .ttwu_count                    : 97658
[ 3616.045613]   .ttwu_local                    : 22422
[ 3616.046224]
[ 3616.046224] cfs_rq[2]:/
[ 3616.046604]   .exec_clock                    : 896560.189825
[ 3616.047269]   .MIN_vruntime                  : 0.000001
[ 3616.047918]   .min_vruntime                  : 10204195.442966
[ 3616.048532]   .max_vruntime                  : 0.000001
[ 3616.049029]   .spread                        : 0.000000
[ 3616.049545]   .spread0                       : 2529522.509753
[ 3616.050266]   .nr_spread_over                : 4123
[ 3616.050783]   .nr_running                    : 0
[ 3616.051316]   .load                          : 0
[ 3616.051941]   .runnable_load_avg             : 0
[ 3616.052424]   .blocked_load_avg              : 0
[ 3616.053030]   .tg_load_contrib               : 0
[ 3616.053521]   .tg_runnable_contrib           : 0
[ 3616.054017]   .tg_load_avg                   : 2122
[ 3616.054687]   .tg->runnable_avg              : 2056
[ 3616.055601]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.055601]   .throttled                     : 0
[ 3616.055601]   .throttle_count                : 0
[ 3616.055601]   .avg->runnable_avg_sum         : 0
[ 3616.055601]   .avg->runnable_avg_period      : 48551
[ 3616.055601]
[ 3616.055601] rt_rq[2]:/
[ 3616.055601]   .rt_nr_running                 : 0
[ 3616.055601]   .rt_throttled                  : 0
[ 3616.055601]   .rt_time                       : 0.000000
[ 3616.055601]   .rt_runtime                    : 854.426155
[ 3616.055601]
[ 3616.055601] dl_rq[2]:
[ 3616.055601]   .dl_nr_running                 : 0
[ 3616.055601]
[ 3616.055601] runnable tasks:
[ 3616.055601]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.055601] ----------------------------------------------------------------------------------------------------------
[ 3616.055601]       watchdog/2    22        -6.000000       907     0        -6.000000        86.086001         0.000000 2 /
[ 3616.055601]      migration/2    23         0.000000       268     0         0.000000        52.763798         0.000000 2 /
[ 3616.055601]      ksoftirqd/2    24  10204140.425928      2820   120  10204140.425928      4957.690833   1437045.649199 2 /
[ 3616.055601]     kworker/2:0H    26     75775.100716        10   100     75775.100716         2.295481    280299.579114 2 /
[ 3616.055601]    kworker/u51:0    27    102308.324569        29   120    102308.324569         1.801070    285296.583870 2 /
[ 3616.055601]    kworker/u48:1   121  10204194.470171     11572   120  10204194.470171      8682.752559   3596517.747468 2 /
[ 3616.055601]      kworker/2:1   514  10204184.926914     15269   120  10204184.926914      4920.557111   1581986.371398 2 /
[ 3616.055601]          kswapd2  3787     16507.135333         4   120     16507.135333         0.613295       101.679316 2 /
[ 3616.055601]    kworker/u70:0  5329    164877.849868     32703   100    164877.849868      6945.273804    312365.397968 2 /
[ 3616.055601]     fcoethread/2  5686     29597.179147         2   100     29597.179147         0.232600         0.214670 2 /
[ 3616.055601]  bnx2fc_thread/2  5712     29597.227898         2   100     29597.227898         0.376980         0.830894 2 /
[ 3616.055601]   bnx2i_thread/2  5781     29636.586111         2   100     29636.586111         0.254592         0.266439 2 /
[ 3616.055601]           bcache  7460     30009.732195         2   100     30009.732195         0.266078         1.239077 2 /
[ 3616.055601]   dm_bufio_cache  7471     30018.299237         2   100     30018.299237         0.583050         0.919158 2 /
[ 3616.055601]          kmpathd  7474     30026.879778         2   100     30026.879778         0.623121         0.987836 2 /
[ 3616.055601]  kmpath_handlerd  7475     30035.307517         2   100     30035.307517         0.452630         1.420506 2 /
[ 3616.055601]         kvub300c  7599     30043.409232         2   100     30043.409232         0.153751         0.958170 2 /
[ 3616.055601]         kvub300d  7601     30051.547554         2   100     30051.547554         0.196794         0.783837 2 /
[ 3616.055601]        kmemstick  7608     30059.777903         2   100     30059.777903         0.305237         0.796463 2 /
[ 3616.055601]         ib_mcast  7645     30067.957460         2   100     30067.957460         0.200923         0.110852 2 /
[ 3616.055601]            ib_cm  7647     30076.260341         2   100     30076.260341         0.322051         0.169215 2 /
[ 3616.055601]         iw_cm_wq  7648     30084.467660         2   100     30084.467660         0.229996         0.260012 2 /
[ 3616.055601]          ib_addr  7649     30092.635662         2   100     30092.635662         0.184567         0.301885 2 /
[ 3616.055601]          rdma_cm  7650     30100.877301         2   100     30100.877301         0.280098         0.657057 2 /
[ 3616.055601]      mthca_catas  7652     30109.492186         2   100     30109.492186         0.652031         0.760475 2 /
[ 3616.055601]         iw_cxgb3  7658     30117.576178         2   100     30117.576178         0.099397         0.113118 2 /
[ 3616.055601]         iw_cxgb4  7659     30125.767407         2   100     30125.767407         0.209033         0.000000 2 /
[ 3616.055601]          mlx4_ib  7660     30134.573017         2   100     30134.573017         0.828545         0.706263 2 /
[ 3616.055601]      mlx4_ib_mcg  7661     30142.857803         2   100     30142.857803         0.300102         0.229712 2 /
[ 3616.055601]  mlx5_ib_page_fa  7662     30151.970112         2   100     30151.970112         1.353696         0.898614 2 /
[ 3616.055601]           nesewq  7663     30160.756768         2   100     30160.756768         0.804585         0.343993 2 /
[ 3616.055601]           nesdwq  7664     30168.944090         2   100     30168.944090         0.227829         0.738490 2 /
[ 3616.055601]            ipoib  7666     30177.137948         2   100     30177.137948         0.211102         0.161309 2 /
[ 3616.055601]       srp_remove  7667     30185.454962         2   100     30185.454962         0.332267         0.627737 2 /
[ 3616.055601]  qat_device_rese  7677     30193.575879         2   100     30193.575879         0.148627         0.547805 2 /
[ 3616.055601]           elousb  7699     30201.726349         2   100     30201.726349         0.166871         0.637141 2 /
[ 3616.055601]          speakup  7831     30238.282463         2   130     30238.282463         0.294306         0.423779 2 /
[ 3616.055601]     k_mode_wimax  7850     30246.711591         2   120     30246.711591         0.429130         0.758172 2 /
[ 3616.055601]         exec-osm  7918     30280.836750         2   100     30280.836750         0.325004         0.194241 2 /
[ 3616.055601]        block-osm  7925     30292.994841         2   100     30292.994841         0.181533         0.211725 2 /
[ 3616.055601]           binder  8090     30301.122446         2   100     30301.122446         0.146310         0.097188 2 /
[ 3616.055601]    ipv6_addrconf  8127     30309.702412         2   100     30309.702412         0.642554         0.033999 2 /
[ 3616.055601]            krdsd  8189     30349.165088         2   100     30349.165088         0.932919         1.674255 2 /
[ 3616.055601]        ceph-msgr  8216     30357.632707         2   100     30357.632707         0.484165         0.978315 2 /
[ 3616.055601]   kafs_vlupdated  8226     30366.003629         2   100     30366.003629         0.406939         0.173236 2 /
[ 3616.055601]   kafs_callbackd  8227     30374.220621         2   100     30374.220621         0.235778         0.165801 2 /
[ 3616.055601]            kafsd  8228     30382.367933         2   100     30382.367933         0.166098         0.106616 2 /
[ 3616.055601]           bioset  8241     30390.864031         2   100     30390.864031         0.513741         1.277821 2 /
[ 3616.055601]  charger_manager  8283     30588.476983         2   100     30588.476983         1.024134         1.120889 2 /
[ 3616.055601]       runtrin.sh  8302      8233.930315      1659   120      8233.930315      1840.204344    244185.907219 2 /autogroup-1
[ 3616.055601]     kworker/2:1H  9703     75787.080786         2   100     75787.080786         0.375501         1.219662 2 /
[ 3616.055601]    kworker/u70:1  9704     75787.081745         2   100     75787.081745         0.322166         0.361316 2 /
[ 3616.055601]    kworker/u51:1  9711  10201022.201213     15428   120  10201022.201213      3446.045862   1150905.672994 2 /
[ 3616.055601]      kworker/2:2  6476   8250583.615180        77   120   8250583.615180        12.388505    124564.413223 2 /
[ 3616.055601]       trinity-c2 14667     31049.593502       370   139     31049.593502      2956.408842     45343.792896 2 /autogroup-2002
[ 3616.055601]       trinity-c2 16494      1503.544958       284   120      1503.544958      4162.245308      4792.211826 2 /autogroup-2081
[ 3616.055601]       trinity-c2 16750       101.716062       140   120       101.716062      1007.615399      4550.038774 2 /autogroup-2084
[ 3616.055601]       trinity-c2 16986    523593.238385        26   120    523593.238385       754.638867      3118.381302 2 /autogroup-1
[ 3616.199181]
[ 3616.199433] cpu#3, 2260.998 MHz
[ 3616.199908]   .nr_running                    : 0
[ 3616.200791]   .load                          : 0
[ 3616.201526]   .nr_switches                   : 252944
[ 3616.202301]   .nr_load_updates               : 361543
[ 3616.203102]   .nr_uninterruptible            : -7
[ 3616.203814]   .next_balance                  : 4295.298931
[ 3616.204611]   .curr->pid                     : 0
[ 3616.205568]   .clock                         : 3616196.738984
[ 3616.206539]   .clock_task                    : 3605141.518146
[ 3616.207504]   .cpu_load[0]                   : 0
[ 3616.208263]   .cpu_load[1]                   : 0
[ 3616.208965]   .cpu_load[2]                   : 0
[ 3616.209662]   .cpu_load[3]                   : 0
[ 3616.210445]   .cpu_load[4]                   : 0
[ 3616.211163]   .yld_count                     : 887
[ 3616.211928]   .sched_count                   : 261714
[ 3616.212706]   .sched_goidle                  : 68905
[ 3616.213527]   .avg_idle                      : 1000000
[ 3616.214313]   .max_idle_balance_cost         : 500000
[ 3616.215173]   .ttwu_count                    : 74572
[ 3616.215996]   .ttwu_local                    : 24638
[ 3616.216804]
[ 3616.216804] cfs_rq[3]:/
[ 3616.217422]   .exec_clock                    : 884051.849344
[ 3616.218314]   .MIN_vruntime                  : 0.000001
[ 3616.219089]   .min_vruntime                  : 9384633.295012
[ 3616.219917]   .max_vruntime                  : 0.000001
[ 3616.220890]   .spread                        : 0.000000
[ 3616.221708]   .spread0                       : 1709960.361799
[ 3616.222591]   .nr_spread_over                : 3279
[ 3616.223341]   .nr_running                    : 0
[ 3616.224030]   .load                          : 0
[ 3616.224697]   .runnable_load_avg             : 0
[ 3616.225156]   .blocked_load_avg              : 0
[ 3616.225156]   .tg_load_contrib               : 0
[ 3616.225156]   .tg_runnable_contrib           : 0
[ 3616.225156]   .tg_load_avg                   : 2122
[ 3616.225156]   .tg->runnable_avg              : 2053
[ 3616.225156]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.225156]   .throttled                     : 0
[ 3616.225156]   .throttle_count                : 0
[ 3616.225156]   .avg->runnable_avg_sum         : 0
[ 3616.225156]   .avg->runnable_avg_period      : 47876
[ 3616.225156]
[ 3616.225156] rt_rq[3]:/
[ 3616.225156]   .rt_nr_running                 : 0
[ 3616.225156]   .rt_throttled                  : 0
[ 3616.225156]   .rt_time                       : 0.000000
[ 3616.225156]   .rt_runtime                    : 950.000000
[ 3616.225156]
[ 3616.225156] dl_rq[3]:
[ 3616.225156]   .dl_nr_running                 : 0
[ 3616.225156]
[ 3616.225156] runnable tasks:
[ 3616.225156]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.225156] ----------------------------------------------------------------------------------------------------------
[ 3616.225156]       watchdog/3    28        -6.000000       907     0        -6.000000        78.750227         0.000000 3 /
[ 3616.225156]      migration/3    29         0.000000       285     0         0.000000        51.782663         0.000000 3 /
[ 3616.225156]      ksoftirqd/3    30   9372450.763666      3576   120   9372450.763666      6231.585066   1435386.257605 3 /
[ 3616.225156]     kworker/3:0H    32      8568.192440         8   100      8568.192440         0.321149     11958.007391 3 /
[ 3616.225156]    kworker/u52:0    33   8808059.966817      1063   120   8808059.966817       178.802608   1381933.188583 3 /
[ 3616.225156]      kworker/3:1   730   9384623.311487     14785   120   9384623.311487      5420.359896   1671391.058422 3 /
[ 3616.225156]          kswapd3  3788      8580.191396         4   120      8580.191396         0.386431        99.860102 3 /
[ 3616.225156]    kworker/u71:0  5330     47806.343403        21   100     47806.343403         7.614166     78189.064252 3 /
[ 3616.225156]     fcoethread/3  5687     13285.319146         2   100     13285.319146         0.217459         0.443706 3 /
[ 3616.225156]  bnx2fc_thread/3  5713     13285.371751         2   100     13285.371751         0.211735         0.282643 3 /
[ 3616.225156]   bnx2i_thread/3  5782     13285.422570         2   100     13285.422570         0.223851         0.162400 3 /
[ 3616.225156]         kvub300p  7600     13936.121060         2   100     13936.121060         0.141048         1.036663 3 /
[ 3616.225156]          deferwq  8280     14211.895532         2   100     14211.895532         0.653220         0.991039 3 /
[ 3616.225156]    kworker/u71:1  8944     40406.441166         2   100     40406.441166         0.105119         0.651176 3 /
[ 3616.225156]     trinity-main  9194    479209.182189     73144   120    479209.182189    152795.424684   1144493.431954 3 /autogroup-1
[ 3616.225156]      kworker/3:2  4594   9384542.860011        45   120   9384542.860011         6.272227    276317.890805 3 /
[ 3616.225156]    kworker/u52:3  4847   9384185.617247       248   120   9384185.617247        30.954732    248187.294896 3 /
[ 3616.225156]       trinity-c3 16387       174.713005       305   120       174.713005      2855.874549      5092.397054 3 /autogroup-2086
[ 3616.225156]       trinity-c3 16717       606.613479       173   120       606.613479      1359.879266      3332.803093 3 /autogroup-2087
[ 3616.225156]       trinity-c3 16829       163.466999        73   120       163.466999       751.851966      4137.490136 3 /autogroup-2098
[ 3616.225156]       trinity-c3 17096    479731.014689         5   120    479731.014689       524.695482         0.000000 3 /autogroup-1
[ 3616.294273]
[ 3616.294517] cpu#4, 2260.998 MHz
[ 3616.295205]   .nr_running                    : 0
[ 3616.296230]   .load                          : 0
[ 3616.297193]   .nr_switches                   : 249803
[ 3616.298010]   .nr_load_updates               : 361548
[ 3616.298785]   .nr_uninterruptible            : -34
[ 3616.299511]   .next_balance                  : 4295.298983
[ 3616.300342]   .curr->pid                     : 0
[ 3616.301095]   .clock                         : 3616297.095539
[ 3616.302172]   .clock_task                    : 3603115.589929
[ 3616.303057]   .cpu_load[0]                   : 0
[ 3616.303756]   .cpu_load[1]                   : 0
[ 3616.304445]   .cpu_load[2]                   : 0
[ 3616.305250]   .cpu_load[3]                   : 0
[ 3616.306399]   .cpu_load[4]                   : 0
[ 3616.307069]   .yld_count                     : 755
[ 3616.307768]   .sched_count                   : 258833
[ 3616.308293]   .sched_goidle                  : 71475
[ 3616.308859]   .avg_idle                      : 1000000
[ 3616.309482]   .max_idle_balance_cost         : 500000
[ 3616.310000]   .ttwu_count                    : 68075
[ 3616.310696]   .ttwu_local                    : 18797
[ 3616.311179]
[ 3616.311179] cfs_rq[4]:/
[ 3616.311556]   .exec_clock                    : 872556.548598
[ 3616.312171]   .MIN_vruntime                  : 0.000001
[ 3616.312671]   .min_vruntime                  : 9868663.497612
[ 3616.313326]   .max_vruntime                  : 0.000001
[ 3616.313951]   .spread                        : 0.000000
[ 3616.314461]   .spread0                       : 2193990.564399
[ 3616.315233]   .nr_spread_over                : 2928
[ 3616.315233]   .nr_running                    : 0
[ 3616.315233]   .load                          : 0
[ 3616.315233]   .runnable_load_avg             : 0
[ 3616.315233]   .blocked_load_avg              : 0
[ 3616.315233]   .tg_load_contrib               : 0
[ 3616.315233]   .tg_runnable_contrib           : 0
[ 3616.315233]   .tg_load_avg                   : 2178
[ 3616.315233]   .tg->runnable_avg              : 2089
[ 3616.315233]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.315233]   .throttled                     : 0
[ 3616.315233]   .throttle_count                : 0
[ 3616.315233]   .avg->runnable_avg_sum         : 0
[ 3616.315233]   .avg->runnable_avg_period      : 48112
[ 3616.315233]
[ 3616.315233] rt_rq[4]:/
[ 3616.315233]   .rt_nr_running                 : 0
[ 3616.315233]   .rt_throttled                  : 0
[ 3616.315233]   .rt_time                       : 0.000000
[ 3616.315233]   .rt_runtime                    : 950.000000
[ 3616.315233]
[ 3616.315233] dl_rq[4]:
[ 3616.315233]   .dl_nr_running                 : 0
[ 3616.315233]
[ 3616.315233] runnable tasks:
[ 3616.315233]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.315233] ----------------------------------------------------------------------------------------------------------
[ 3616.315233]             init     1    527557.296606      2892   120    527557.296606     33133.219269   1409853.798409 4 /autogroup-1
[ 3616.315233]       watchdog/4    34        -8.896587       908     0        -8.896587        93.238227         0.000000 4 /
[ 3616.315233]      migration/4    35         0.000000       279     0         0.000000        60.247050         0.000000 4 /
[ 3616.315233]      ksoftirqd/4    36   9867067.677530      2883   120   9867067.677530      5261.598155   1438040.073915 4 /
[ 3616.315233]     kworker/4:0H    38      2572.924312         8   100      2572.924312         0.260893     11909.938369 4 /
[ 3616.315233]    kworker/u53:0    39   8383412.921601      1101   120   8383412.921601       176.712896   1248924.694988 4 /
[ 3616.315233]      kworker/4:1  2916   9868652.070131     15094   120   9868652.070131      4318.351099   1640310.598543 4 /
[ 3616.315233]          kswapd4  3789      2572.321081         4   120      2572.321081         0.643913        98.885734 4 /
[ 3616.315233]    kworker/u72:0  5331    249026.076770        23   100    249026.076770         6.826056    389791.701848 4 /
[ 3616.315233]     fcoethread/4  5688      2959.873812         2   100      2959.873812         0.317528         0.193691 4 /
[ 3616.315233]  bnx2fc_thread/4  5714      2959.903929         2   100      2959.903929         0.173458         0.188316 4 /
[ 3616.315233]   bnx2i_thread/4  5783      2959.932847         2   100      2959.932847         0.122568         0.160379 4 /
[ 3616.315233]    kworker/u72:1  8991     39007.073891         2   100
[ 3616.315233]     39007.073891         0.894274         0.908172 4 /
[ 3616.315233]    kworker/u53:1  9019   9866907.717507      1510   120   9866907.717507       223.043546   1349081.642098 4 /
[ 3616.315233]      kworker/4:2  6586   8193932.775056         6   120   8193932.775056         0.821690     10839.403518 4 /
[ 3616.315233]       trinity-c4 16616      4291.228760       256   120      4291.228760      5045.403589      2561.313627 4 /autogroup-2078
[ 3616.315233]       trinity-c4 16775      1099.681340       129   120      1099.681340      1760.949277       836.061065 4 /autogroup-2099
[ 3616.315233]       trinity-c4 16801    527944.696606       107   120    527944.696606       995.811940       144.052331 4 /autogroup-1
[ 3616.315233]       trinity-c4 16966    527946.978106        67   120    527946.978106       596.947549       129.719721 4 /autogroup-1
[ 3616.315233]       trinity-c4 17019         1.714520        44   120         1.714520       722.703094        18.693453 4 /autogroup-2102
[ 3616.379983]
[ 3616.380227] cpu#5, 2260.998 MHz
[ 3616.380714]   .nr_running                    : 1
[ 3616.381392]   .load                          : 1024
[ 3616.382209]   .nr_switches                   : 248897
[ 3616.383139]   .nr_load_updates               : 361502
[ 3616.383881]   .nr_uninterruptible            : -25
[ 3616.384640]   .next_balance                  : 4295.299096
[ 3616.385699]   .curr->pid                     : 3362
[ 3616.386449]   .clock                         : 3616385.689333
[ 3616.387431]   .clock_task                    : 3604014.099716
[ 3616.388366]   .cpu_load[0]                   : 1023
[ 3616.389090]   .cpu_load[1]                   : 1023
[ 3616.389867]   .cpu_load[2]                   : 1023
[ 3616.390599]   .cpu_load[3]                   : 1023
[ 3616.391374]   .cpu_load[4]                   : 1023
[ 3616.392127]   .yld_count                     : 748
[ 3616.392881]   .sched_count                   : 257314
[ 3616.393693]   .sched_goidle                  : 73278
[ 3616.394450]   .avg_idle                      : 1000000
[ 3616.395514]   .max_idle_balance_cost         : 500000
[ 3616.396287]   .ttwu_count                    : 59684
[ 3616.397078]   .ttwu_local                    : 19287
[ 3616.398005]
[ 3616.398005] cfs_rq[5]:/
[ 3616.398624]   .exec_clock                    : 851098.229040
[ 3616.399448]   .MIN_vruntime                  : 0.000001
[ 3616.400222]   .min_vruntime                  : 10975067.441311
[ 3616.401135]   .max_vruntime                  : 0.000001
[ 3616.402367]   .spread                        : 0.000000
[ 3616.402977]   .spread0                       : 3300394.508098
[ 3616.403571]   .nr_spread_over                : 2248
[ 3616.404114]   .nr_running                    : 1
[ 3616.404706]   .load                          : 1024
[ 3616.405268]   .runnable_load_avg             : 1023
[ 3616.405503]   .blocked_load_avg              : 0
[ 3616.405503]   .tg_load_contrib               : 1023
[ 3616.405503]   .tg_runnable_contrib           : 1019
[ 3616.405503]   .tg_load_avg                   : 2178
[ 3616.405503]   .tg->runnable_avg              : 2173
[ 3616.405503]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.405503]   .throttled                     : 0
[ 3616.405503]   .throttle_count                : 0
[ 3616.405503]   .avg->runnable_avg_sum         : 47364
[ 3616.405503]   .avg->runnable_avg_period      : 47364
[ 3616.405503]
[ 3616.405503] rt_rq[5]:/
[ 3616.405503]   .rt_nr_running                 : 0
[ 3616.405503]   .rt_throttled                  : 0
[ 3616.405503]   .rt_time                       : 0.000000
[ 3616.405503]   .rt_runtime                    : 950.000000
[ 3616.405503]
[ 3616.405503] dl_rq[5]:
[ 3616.405503]   .dl_nr_running                 : 0
[ 3616.405503]
[ 3616.405503] runnable tasks:
[ 3616.405503]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.405503] ----------------------------------------------------------------------------------------------------------
[ 3616.405503]       watchdog/5    40        -8.925914       908     0        -8.925914        79.768098         0.000000 5 /
[ 3616.405503]      migration/5    41         0.000000       275     0         0.000000        50.190439         0.000000 5 /
[ 3616.405503]      ksoftirqd/5    42  10963904.272115      2449   120  10963904.272115      4496.381769   1445272.414232 5 /
[ 3616.405503]     kworker/5:0H    44      1045.760156         8   100      1045.760156         0.248022     11859.702881 5 /
[ 3616.405503]    kworker/u54:0    45  10961176.396092      1813   120  10961176.396092       267.137341   1443100.297986 5 /
[ 3616.405503] R     khungtaskd  3362  10975067.441311         6   120  10975067.441311     10867.852754   3599995.936907 5 /
[ 3616.405503]             ksmd  3366     48134.403726         3   125     48134.403726         2.606979    246130.037091 5 /
[ 3616.405503]           crypto  3367       913.855668         2   100       913.855668         1.698239         0.701629 5 /
[ 3616.405503]      kintegrityd  3368       927.278909         2   100       927.278909         1.444185         0.276492 5 /
[ 3616.405503]           bioset  3369       940.415171         2   100       940.415171         1.136268         0.101770 5 /
[ 3616.405503]          kblockd  3370       952.415165         2   100       952.415165         0.000000         0.124684 5 /
[ 3616.405503]             tifm  3458       965.978161         2   100       965.978161         1.598463         1.170234 5 /
[ 3616.405503]          ata_sff  3503       980.404525         2   100       980.404525         2.456435         1.676985 5 /
[ 3616.405503]               md  3537      1006.584132         2   100      1006.584132         2.262905         1.169095 5 /
[ 3616.405503]       devfreq_wq  3544      1019.789391         2   100      1019.789391         1.242825         0.864773 5 /
[ 3616.405503]         cfg80211  3568      1057.042243         2   100      1057.042243         0.000000         0.311513 5 /
[ 3616.405503]          kswapd5  3790      1057.758761         4   120      1057.758761         0.929137        97.475940 5 /
[ 3616.405503]      kworker/5:1  4675  10964203.978172     15242   120  10964203.978172      4613.956976   1690295.566412 5 /
[ 3616.405503]    kworker/u73:0  5332     45677.931803        22   100     45677.931803         7.300447    208604.556979 5 /
[ 3616.405503]     fcoethread/5  5689      1115.772526         2   100      1115.772526         0.545986         0.235958 5 /
[ 3616.405503]  bnx2fc_thread/5  5715      1125.590702         2   100      1125.590702         0.064971         0.261599 5 /
[ 3616.405503]   bnx2i_thread/5  5784      1133.096251         2   100      1133.096251         0.471608         0.631140 5 /
[ 3616.405503]    kworker/u73:1  8868     25382.143278         2   100     25382.143278         0.901806         2.057012 5 /
[ 3616.405503]       runtrin.sh  9260      3656.644312         2   120      3656.644312        16.618145         0.000000 5 /autogroup-1
[ 3616.405503]    kworker/u54:1  9730   9874712.995219       671   120   9874712.995219       102.908012    830479.589520 5 /
[ 3616.405503]       trinity-c5  1701       951.502208       120   120       951.502208      1614.208430       434.248207 5 /autogroup-1306
[ 3616.405503]      kworker/5:2  5375  10762903.792125         7   120  10762903.792125         1.245301    216795.277344 5 /
[ 3616.405503]       trinity-c5 16328    237785.947831       249   139    237785.947831      5358.710969      8904.669788 5 /autogroup-2054
[ 3616.405503]       trinity-c5 16667       238.149867       172   120       238.149867      2251.556704      3881.718666 5 /autogroup-2093
[ 3616.405503]       trinity-c5 16694      1619.007903       146   120      1619.007903      2451.726197      5160.436056 5 /autogroup-2085
[ 3616.405503]       trinity-c5 17097    704683.943911         6   120    704683.943911       552.137458         0.000000 5 /autogroup-1
[ 3616.458063]
[ 3616.458243] cpu#6, 2260.998 MHz
[ 3616.458614]   .nr_running                    : 0
[ 3616.459045]   .load                          : 0
[ 3616.459482]   .nr_switches                   : 313556
[ 3616.459991]   .nr_load_updates               : 361553
[ 3616.460498]   .nr_uninterruptible            : 56
[ 3616.460942]   .next_balance                  : 4295.298974
[ 3616.461543]   .curr->pid                     : 0
[ 3616.461985]   .clock                         : 3616460.060243
[ 3616.462536]   .clock_task                    : 3607249.925122
[ 3616.463119]   .cpu_load[0]                   : 0
[ 3616.463634]   .cpu_load[1]                   : 0
[ 3616.464094]   .cpu_load[2]                   : 0
[ 3616.464583]   .cpu_load[3]                   : 0
[ 3616.465148]   .cpu_load[4]                   : 0
[ 3616.465749]   .yld_count                     : 750
[ 3616.466233]   .sched_count                   : 323675
[ 3616.466768]   .sched_goidle                  : 84641
[ 3616.467250]   .avg_idle                      : 1000000
[ 3616.467798]   .max_idle_balance_cost         : 500000
[ 3616.468342]   .ttwu_count                    : 81000
[ 3616.468871]   .ttwu_local                    : 29632
[ 3616.469411]
[ 3616.469411] cfs_rq[6]:/
[ 3616.469789]   .exec_clock                    : 869806.243750
[ 3616.470398]   .MIN_vruntime                  : 0.000001
[ 3616.470923]   .min_vruntime                  : 8492926.694002
[ 3616.471507]   .max_vruntime                  : 0.000001
[ 3616.472019]   .spread                        : 0.000000
[ 3616.472568]   .spread0                       : 818253.760789
[ 3616.473199]   .nr_spread_over                : 2184
[ 3616.473700]   .nr_running                    : 0
[ 3616.474235]   .load                          : 0
[ 3616.474679]   .runnable_load_avg             : 0
[ 3616.475138]   .blocked_load_avg              : 0
[ 3616.475138]   .tg_load_contrib               : 0
[ 3616.475138]   .tg_runnable_contrib           : 0
[ 3616.475138]   .tg_load_avg                   : 2155
[ 3616.475138]   .tg->runnable_avg              : 2086
[ 3616.475138]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.475138]   .throttled                     : 0
[ 3616.475138]   .throttle_count                : 0
[ 3616.475138]   .avg->runnable_avg_sum         : 0
[ 3616.475138]   .avg->runnable_avg_period      : 46976
[ 3616.475138]
[ 3616.475138] rt_rq[6]:/
[ 3616.475138]   .rt_nr_running                 : 0
[ 3616.475138]   .rt_throttled                  : 0
[ 3616.475138]   .rt_time                       : 0.000000
[ 3616.475138]   .rt_runtime                    : 1000.000000
[ 3616.475138]
[ 3616.475138] dl_rq[6]:
[ 3616.475138]   .dl_nr_running                 : 0
[ 3616.475138]
[ 3616.475138] runnable tasks:
[ 3616.475138]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.475138] ----------------------------------------------------------------------------------------------------------
[ 3616.475138]       watchdog/6    46        -8.910356       908     0        -8.910356        84.461684         0.000000 6 /
[ 3616.475138]      migration/6    47         0.000000       290     0         0.000000        57.655359         0.000000 6 /
[ 3616.475138]      ksoftirqd/6    48   8489871.876755      2722   120   8489871.876755      5367.895196   1435145.464859 6 /
[ 3616.475138]     kworker/6:0H    50      1449.453650         8   100      1449.453650         0.369492     11818.060838 6 /
[ 3616.475138]        writeback  3363   1200245.438699         5   100   1200245.438699         3.169982    594568.422711 6 /
[ 3616.475138]      kworker/6:1  3711   8492926.694002     17170   120   8492926.694002      6722.402305   3589468.399179 6 /
[ 3616.475138]          kswapd6  3791   8140929.084022        11   120   8140929.084022       124.552458   1408695.603016 6 /
[ 3616.475138]   kfd_process_wq  5275      1579.487885         2   100      1579.487885         0.202153         1.220425 6 /
[ 3616.475138]    kworker/u67:0  5326      4136.579313         4   100      4136.579313         0.331629      7771.511671 6 /
[ 3616.475138]    kworker/u74:0  5333    225564.597156     23821   100    225564.597156      4591.193712    350246.632895 6 /
[ 3616.475138]           kloopd  5345      1852.886156         2   100      1852.886156         0.218906         0.417207 6 /
[ 3616.475138]       cciss_scan  5476      1865.058289         2   120      1865.058289         0.172139         0.165055 6 /
[ 3616.475138]             nvme  5482      1877.212211         2   100      1877.212211         0.175370         0.294752 6 /
[ 3616.475138]           bioset  5528      1889.390553         2   100      1889.390553         0.195850         0.443617 6 /
[ 3616.475138]     drbd-reissue  5530      1901.850067         2   100      1901.850067         0.479197         0.526894 6 /
[ 3616.475138]              rbd  5534      1914.017913         2   100      1914.017913         0.185906         0.267919 6 /
[ 3616.475138]     kmpath_rdacd  5679      1971.295314         2   100      1971.295314         0.369275         0.564756 6 /
[ 3616.475138]  fc_exch_workque  5682      1983.848125         2   100      1983.848125         0.582455         0.298535 6 /
[ 3616.475138]      fc_rport_eq  5683      1996.048420         2   100      1996.048420         0.218960         0.193246 6 /
[ 3616.475138]     fcoethread/6  5690      2078.555823         2   100      2078.555823         0.608704         0.359561 6 /
[ 3616.475138]    fnic_event_wq  5706      2227.676512         2   100      2227.676512         0.247149         0.241676 6 /
[ 3616.475138]       fnic_fip_q  5707      2239.972312         2   100      2239.972312         0.314463         0.495571 6 /
[ 3616.475138]  bnx2fc_l2_threa  5709      2252.506734         2   100      2252.506734         0.549005         0.561663 6 /
[ 3616.475138]  bnx2fc_thread/6  5716      2334.076149         2   100      2334.076149         0.487454         0.177878 6 /
[ 3616.475138]  tcm_qla2xxx_fre  5743      2480.676704         2   100      2480.676704         0.943397         0.255009 6 /
[ 3616.475138]   bnx2i_thread/6  5785      2562.081802         2   100      2562.081802         0.221248         0.182469 6 /
[ 3616.475138]        scsi_eh_0  5823      2708.101086         2   120      2708.101086         0.160944         0.342286 6 /
[ 3616.475138]       scsi_tmf_0  5824      2720.449322         2   100      2720.449322         0.368460         0.381706 6 /
[ 3616.475138]       tmr-rd_mcp  5909      2770.763026         2   100      2770.763026         0.192028         0.209634 6 /
[ 3616.475138]         xcopy_wq  5910      2782.974249         2   100      2782.974249         0.230850         0.212314 6 /
[ 3616.475138]        iscsi_ttx  5916      2795.283222         2   120      2795.283222         0.308979         0.239737 6 /
[ 3616.475138]        iscsi_trx  5917      2807.441469         2   120      2807.441469         0.158253         0.778491 6 /
[ 3616.475138]        iscsi_ttx  5918      2819.887908         2   120      2819.887908         0.446445         0.280134 6 /
[ 3616.475138]        iscsi_trx  5919      2832.290272         2   120      2832.290272         0.402370         0.245923 6 /
[ 3616.475138]        iscsi_ttx  5920      2844.806463         2   120      2844.806463         0.516197         0.467944 6 /
[ 3616.475138]        iscsi_trx  5921      2856.976428         2   120      2856.976428         0.169971         1.097428 6 /
[ 3616.475138]        iscsi_ttx  5922      2869.126503         2   120      2869.126503         0.150081         0.443990 6 /
[ 3616.475138]        iscsi_trx  5923      2881.267119         2   120      2881.267119         0.140622         0.195621 6 /
[ 3616.475138]            bond0  5944      2893.725516         2   100      2893.725516         0.475743         0.399431 6 /
[ 3616.475138]          cnic_wq  6142      3074.643185         2   100      3074.643185         0.173151         0.183248 6 /
[ 3616.475138]            bnx2x  6143      3087.184462         2   100      3087.184462         0.581003         0.447192 6 /
[ 3616.475138]        bnx2x_iov  6144      3099.535728         2   100      3099.535728         0.394393         1.075937 6 /
[ 3616.475138]             mlx4  6184      3111.789239         2   100      3111.789239         0.269404         0.324140 6 /
[ 3616.475138]     mlx5_core_wq  6186      3124.158165         2   100      3124.158165         0.388113         0.000000 6 /
[ 3616.475138]         sfc_vfdi  6214      3145.484077         2   100      3145.484077         0.114614         0.103880 6 /
[ 3616.475138]        sfc_reset  6215      3157.577865         2   100      3157.577865         0.108551         0.750432 6 /
[ 3616.475138]         zd1211rw  6270      3194.996484         2   100      3194.996484         0.163091         0.886110 6 /
[ 3616.475138]       libertastf  6290      3207.793239         2   100      3207.793239         0.813026         0.920474 6 /
[ 3616.475138]             phy0  6359      3232.964192         2   100      3232.964192         0.425985         0.224839 6 /
[ 3616.475138]         firewire  6420      3258.038150         2   100      3258.038150         0.186000         0.083716 6 /
[ 3616.475138]    firewire_ohci  6422      3270.485451         2   100      3270.485451         0.467056         0.103570 6 /
[ 3616.475138]  vfio-irqfd-clea  6441      3282.718926         2   100      3282.718926         0.253299         0.089745 6 /
[ 3616.475138]        aoe_ktio0  6454      3307.156614         2   110      3307.156614         0.334012         0.098884 6 /
[ 3616.475138]             u132  6489      3319.773368         2   100      3319.773368         0.637862         0.677242 6 /
[ 3616.475138]            wusbd  6499      3331.921207         2   100      3331.921207         0.166484         0.389080 6 /
[ 3616.475138]     appledisplay  6650      3344.070520         2   100      3344.070520         0.165606         0.356236 6 /
[ 3616.475138]  ftdi-status-con  6656      3356.302663         2   100      3356.302663         0.247910         0.203858 6 /
[ 3616.475138]  ftdi-command-en  6657      3368.502403         2   100      3368.502403         0.219572         0.470565 6 /
[ 3616.475138]  ftdi-respond-en  6658      3381.092120         2   100      3381.092120         0.620956         0.407917 6 /
[ 3616.475138]              rc0  7076      3851.802335         2   120      3851.802335         0.337463         0.567414 6 /
[ 3616.475138]  pvrusb2-context  7231      3864.445442         2   120      3864.445442         0.643113         0.258714 6 /
[ 3616.475138]          raid5wq  7457      4012.014421         2   100      4012.014421         0.336466         0.372739 6 /
[ 3616.475138]    kworker/u74:1  8882     47909.892166         5   100     47909.892166         1.554072    137914.155000 6 /
[ 3616.475138]          trinity  9065      3945.311844       298   120      3945.311844       287.296169     10461.418439 6 /autogroup-1
[ 3616.475138]       runtrin.sh  9473      5971.953398         1   120      5971.953398        19.910173         0.000000 6 /autogroup-1
[ 3616.475138]      kworker/6:2 11064   2536671.681424        19   120   2536671.681424         2.237541    297467.980914 6 /
[ 3616.475138]    kworker/u55:2 14598   8491169.417055       828   120   8491169.417055       118.321047    888540.242054 6 /
[ 3616.475138]    kworker/u55:3 14645   6333361.109666      1374   120   6333361.109666       206.387015    611807.365273 6 /
[ 3616.475138]       trinity-c6 10551      1883.088649       278   120      1883.088649      2919.941834     23313.842526 6 /autogroup-1777
[ 3616.475138]       trinity-c6 15683      5682.382765       703   120      5682.382765      7690.291749     14239.192603 6 /autogroup-2048
[ 3616.475138]       trinity-c6 16727       104.522986       248   120       104.522986      1536.466936      3295.426809 6 /autogroup-2090
[ 3616.475138]       trinity-c6 17117    643320.251131         6   120    643320.251131       634.459352         0.000000 6 /autogroup-1
[ 3616.637271]
[ 3616.637584] cpu#7, 2260.998 MHz
[ 3616.638315]   .nr_running                    : 0
[ 3616.639008]   .load                          : 0
[ 3616.639458]   .nr_switches                   : 207358
[ 3616.639960]   .nr_load_updates               : 361567
[ 3616.640586]   .nr_uninterruptible            : -4
[ 3616.641031]   .next_balance                  : 4295.298995
[ 3616.641545]   .curr->pid                     : 0
[ 3616.641982]   .clock                         : 3616638.126275
[ 3616.642531]   .clock_task                    : 3603884.986585
[ 3616.643108]   .cpu_load[0]                   : 0
[ 3616.643579]   .cpu_load[1]                   : 0
[ 3616.644149]   .cpu_load[2]                   : 0
[ 3616.644710]   .cpu_load[3]                   : 0
[ 3616.645260]   .cpu_load[4]                   : 0
[ 3616.645934]   .yld_count                     : 790
[ 3616.646571]   .sched_count                   : 217033
[ 3616.647286]   .sched_goidle                  : 52337
[ 3616.647800]   .avg_idle                      : 1000000
[ 3616.648466]   .max_idle_balance_cost         : 500000
[ 3616.648963]   .ttwu_count                    : 60336
[ 3616.649442]   .ttwu_local                    : 18608
[ 3616.650586]
[ 3616.650586] cfs_rq[7]:/
[ 3616.650959]   .exec_clock                    : 877066.841985
[ 3616.651490]   .MIN_vruntime                  : 0.000001
[ 3616.652198]   .min_vruntime                  : 8699930.803199
[ 3616.652767]   .max_vruntime                  : 0.000001
[ 3616.653281]   .spread                        : 0.000000
[ 3616.653815]   .spread0                       : 1025257.869986
[ 3616.654362]   .nr_spread_over                : 2398
[ 3616.654858]   .nr_running                    : 0
[ 3616.655250]   .load                          : 0
[ 3616.655250]   .runnable_load_avg             : 0
[ 3616.655250]   .blocked_load_avg              : 0
[ 3616.655250]   .tg_load_contrib               : 0
[ 3616.655250]   .tg_runnable_contrib           : 0
[ 3616.655250]   .tg_load_avg                   : 2175
[ 3616.655250]   .tg->runnable_avg              : 2076
[ 3616.655250]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.655250]   .throttled                     : 0
[ 3616.655250]   .throttle_count                : 0
[ 3616.655250]   .avg->runnable_avg_sum         : 0
[ 3616.655250]   .avg->runnable_avg_period      : 48093
[ 3616.655250]
[ 3616.655250] rt_rq[7]:/
[ 3616.655250]   .rt_nr_running                 : 0
[ 3616.655250]   .rt_throttled                  : 0
[ 3616.655250]   .rt_time                       : 0.000000
[ 3616.655250]   .rt_runtime                    : 950.000000
[ 3616.655250]
[ 3616.655250] dl_rq[7]:
[ 3616.655250]   .dl_nr_running                 : 0
[ 3616.655250]
[ 3616.655250] runnable tasks:
[ 3616.655250]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.655250] ----------------------------------------------------------------------------------------------------------
[ 3616.655250]       watchdog/7    52        -8.900416       908     0        -8.900416        78.116186         0.000000 7 /
[ 3616.655250]      migration/7    53         0.000000       214     0         0.000000        42.996796         0.000000 7 /
[ 3616.655250]      ksoftirqd/7    54   8699825.732518      2759   120   8699825.732518      5010.006958   1438275.676098 7 /
[ 3616.655250]     kworker/7:0H    56     41831.400198        10   100     41831.400198         3.091150    162927.307550 7 /
[ 3616.655250]    kworker/u56:0    57   2057114.239254        80   120   2057114.239254        10.445699    687696.607704 7 /
[ 3616.655250]      kworker/7:1  3517   8699920.030192     15682   120   8699920.030192      5135.548692   1760088.559637 7 /
[ 3616.655250]          kswapd7  3792   2843129.927170        10   120   2843129.927170       140.354646    760994.822717 7 /
[ 3616.655250]    kworker/u75:0  5334     44738.895097        24   100     44738.895097         8.578492    208825.464382 7 /
[ 3616.655250]     fcoethread/7  5691      3179.067515         2   100      3179.067515         0.492241         0.589898 7 /
[ 3616.655250]  bnx2fc_thread/7  5717      3191.830137         2   100      3191.830137         0.320173         0.510168 7 /
[ 3616.655250]   bnx2i_thread/7  5786      3191.871422         2   100      3191.871422         0.209137         0.493961 7 /
[ 3616.655250]  target_completi  5908      3204.024630         2   100      3204.024630         0.175220         0.228996 7 /
[ 3616.655250]    kworker/u75:1  8969     32836.749131         2   100     32836.749131         0.870850         0.375998 7 /
[ 3616.655250]     trinity-main  9086    305638.873310     71743   120    305638.873310    148853.592285   1176947.753376 7 /autogroup-1
[ 3616.655250]     kworker/7:1H  9279     41843.373553         2   100     41843.373553         1.817962         0.396187 7 /
[ 3616.655250]    kworker/u56:1  9739   8699075.579876      2451   120   8699075.579876       367.001303    972234.992499 7 /
[ 3616.655250]      kworker/7:2 14677   8622648.557122        18   120   8622648.557122         1.990165     35580.056792 7 /
[ 3616.655250]       trinity-c7 16252    304827.144863       151   120    304827.144863      1485.669736      8418.414309 7 /autogroup-1
[ 3616.655250]       trinity-c7 16617       180.438019       156   120       180.438019      1203.909931      3049.744063 7 /autogroup-2097
[ 3616.655250]       trinity-c7 16749    306182.567045       136   120    306182.567045       973.101279      4853.315838 7 /autogroup-1
[ 3616.655250]       trinity-c7 16935        85.166462        70   120        85.166462      1024.856867      1503.003985 7 /autogroup-2096
[ 3616.655250]       trinity-c7 17084        26.620507        15   120        26.620507       514.001695         0.139523 7 /autogroup-2101
[ 3616.696120]
[ 3616.696314] cpu#8, 2260.998 MHz
[ 3616.696634]   .nr_running                    : 0
[ 3616.697161]   .load                          : 0
[ 3616.697723]   .nr_switches                   : 234854
[ 3616.698295]   .nr_load_updates               : 361568
[ 3616.698792]   .nr_uninterruptible            : -31
[ 3616.699253]   .next_balance                  : 4295.298994
[ 3616.699804]   .curr->pid                     : 0
[ 3616.700334]   .clock                         : 3616698.201195
[ 3616.700968]   .clock_task                    : 3604723.722816
[ 3616.701515]   .cpu_load[0]                   : 0
[ 3616.702098]   .cpu_load[1]                   : 0
[ 3616.702533]   .cpu_load[2]                   : 0
[ 3616.702992]   .cpu_load[3]                   : 0
[ 3616.703436]   .cpu_load[4]                   : 0
[ 3616.703923]   .yld_count                     : 804
[ 3616.704425]   .sched_count                   : 243435
[ 3616.705113]   .sched_goidle                  : 61835
[ 3616.705942]   .avg_idle                      : 1000000
[ 3616.706667]   .max_idle_balance_cost         : 500000
[ 3616.707271]   .ttwu_count                    : 63047
[ 3616.707933]   .ttwu_local                    : 19270
[ 3616.708482]
[ 3616.708482] cfs_rq[8]:/
[ 3616.708852]   .exec_clock                    : 880893.738850
[ 3616.709391]   .MIN_vruntime                  : 0.000001
[ 3616.709997]   .min_vruntime                  : 8763939.361789
[ 3616.710631]   .max_vruntime                  : 0.000001
[ 3616.711135]   .spread                        : 0.000000
[ 3616.711711]   .spread0                       : 1089266.428576
[ 3616.712278]   .nr_spread_over                : 2399
[ 3616.712751]   .nr_running                    : 0
[ 3616.713387]   .load                          : 0
[ 3616.713905]   .runnable_load_avg             : 0
[ 3616.714393]   .blocked_load_avg              : 0
[ 3616.714876]   .tg_load_contrib               : 0
[ 3616.715103]   .tg_runnable_contrib           : 0
[ 3616.715103]   .tg_load_avg                   : 2142
[ 3616.715103]   .tg->runnable_avg              : 2057
[ 3616.715103]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.715103]   .throttled                     : 0
[ 3616.715103]   .throttle_count                : 0
[ 3616.715103]   .avg->runnable_avg_sum         : 0
[ 3616.715103]   .avg->runnable_avg_period      : 48392
[ 3616.715103]
[ 3616.715103] rt_rq[8]:/
[ 3616.715103]   .rt_nr_running                 : 0
[ 3616.715103]   .rt_throttled                  : 0
[ 3616.715103]   .rt_time                       : 0.000000
[ 3616.715103]   .rt_runtime                    : 950.000000
[ 3616.715103]
[ 3616.715103] dl_rq[8]:
[ 3616.715103]   .dl_nr_running                 : 0
[ 3616.715103]
[ 3616.715103] runnable tasks:
[ 3616.715103]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.715103] ----------------------------------------------------------------------------------------------------------
[ 3616.715103]       watchdog/8    58       -11.905854       908     0       -11.905854       114.398184         0.000000 8 /
[ 3616.715103]      migration/8    59         0.000000       274     0         0.000000        46.307516         0.000000 8 /
[ 3616.715103]      ksoftirqd/8    60   8763894.618145      2876   120   8763894.618145      5111.424036   1445421.559590 8 /
[ 3616.715103]     kworker/8:0H    62      7192.660044         8   100      7192.660044         0.252762     11707.861056 8 /
[ 3616.715103]      kworker/8:1   577   8763928.248362     15353   120   8763928.248362      4844.637038   1762639.241276 8 /
[ 3616.715103]          kswapd8  3793   1396474.576081        16   120   1396474.576081       200.125422    619914.153636 8 /
[ 3616.715103]    kworker/u76:0  5335      8345.737985         4   100      8345.737985         0.589798      7754.594388 8 /
[ 3616.715103]     fcoethread/8  5692      7699.651974         2   100      7699.651974         0.222001         0.252797 8 /
[ 3616.715103]  bnx2fc_thread/8  5718      7699.681200         2   100      7699.681200         0.169133         0.228020 8 /
[ 3616.715103]   bnx2i_thread/8  5787      7715.644344         2   100      7715.644344         0.194447         0.217872 8 /
[ 3616.715103]     trinity-main  9410    673847.915020     76192   120    673847.915020    147691.318525   1095564.735245 8 /autogroup-1
[ 3616.715103]    kworker/u57:2 13762   7693822.788054       751   120   7693822.788054       121.803560    758112.229554 8 /
[ 3616.715103]    kworker/u57:3 20746   8761682.387964      1151   120   8761682.387964       182.919526    715966.350121 8 /
[ 3616.715103]      kworker/8:0 11979   7939866.430281         4   120   7939866.430281         0.715970     53158.077694 8 /
[ 3616.715103]       trinity-c8 16718    673272.417192       219   120    673272.417192      1477.080142      2990.467078 8 /autogroup-1
[ 3616.715103]       trinity-c8 16751    673272.961861       134   120    673272.961861      1115.677683      3289.127775 8 /autogroup-1
[ 3616.715103]       trinity-c8 16755       170.275667       101   120       170.275667       895.251151      3159.862738 8 /autogroup-2088
[ 3616.715103]       trinity-c8 16795       676.328158       169   120       676.328158      1874.146538      3103.757361 8 /autogroup-2091
[ 3616.715103]       trinity-c8 17105    674722.101432        24   120    674722.101432       888.697395      1021.566423 8 /autogroup-1
[ 3616.750651]
[ 3616.750814] cpu#9, 2260.998 MHz
[ 3616.751118]   .nr_running                    : 7
[ 3616.751558]   .load                          : 3149
[ 3616.752042]   .nr_switches                   : 220731
[ 3616.752512]   .nr_load_updates               : 361568
[ 3616.753028]   .nr_uninterruptible            : -26
[ 3616.753495]   .next_balance                  : 4295.299007
[ 3616.754217]   .curr->pid                     : 16739
[ 3616.754677]   .clock                         : 3616747.425600
[ 3616.755471]   .clock_task                    : 3607298.919291
[ 3616.756363]   .cpu_load[0]                   : 1099
[ 3616.756827]   .cpu_load[1]                   : 1099
[ 3616.757475]   .cpu_load[2]                   : 1099
[ 3616.758021]   .cpu_load[3]                   : 1099
[ 3616.758528]   .cpu_load[4]                   : 1099
[ 3616.759003]   .yld_count                     : 772
[ 3616.759478]   .sched_count                   : 244101
[ 3616.760071]   .sched_goidle                  : 51457
[ 3616.760650]   .avg_idle                      : 902425
[ 3616.761150]   .max_idle_balance_cost         : 500000
[ 3616.761751]   .ttwu_count                    : 74608
[ 3616.763027]   .ttwu_local                    : 19164
[ 3616.764189]
[ 3616.764189] cfs_rq[9]:/autogroup-2077
[ 3616.765048]   .exec_clock                    : 531.384441
[ 3616.765461]   .MIN_vruntime                  : 57486.327869
[ 3616.765461]   .min_vruntime                  : 57486.327869
[ 3616.765461]   .max_vruntime                  : 57486.327869
[ 3616.765461]   .spread                        : 0.000000
[ 3616.765461]   .spread0                       : -7617186.605344
[ 3616.765461]   .nr_spread_over                : 11
[ 3616.765461]   .nr_running                    : 1
[ 3616.765461]   .load                          : 3
[ 3616.765461]   .runnable_load_avg             : 0
[ 3616.765461]   .blocked_load_avg              : 0
[ 3616.765461]   .tg_load_contrib               : 0
[ 3616.765461]   .tg_runnable_contrib           : 1023
[ 3616.765461]   .tg_load_avg                   : 0
[ 3616.765461]   .tg->runnable_avg              : 1023
[ 3616.765461]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.765461]   .throttled                     : 0
[ 3616.765461]   .throttle_count                : 0
[ 3616.765461]   .se->exec_start                : 1437085.210648
[ 3616.765461]   .se->vruntime                  : 9722251.577627
[ 3616.765461]   .se->sum_exec_runtime          : 531.384441
[ 3616.765461]   .se->statistics.wait_start     : 1445110.904522
[ 3616.765461]   .se->statistics.sleep_start    : 0.000000
[ 3616.765461]   .se->statistics.block_start    : 0.000000
[ 3616.765461]   .se->statistics.sleep_max      : 0.000000
[ 3616.765461]   .se->statistics.block_max      : 0.000000
[ 3616.765461]   .se->statistics.exec_max       : 10.056084
[ 3616.765461]   .se->statistics.slice_max      : 21.018110
[ 3616.765461]   .se->statistics.wait_max       : 2916.612406
[ 3616.765461]   .se->statistics.wait_sum       : 3542.948642
[ 3616.765461]   .se->statistics.wait_count     : 168
[ 3616.765461]   .se->load.weight               : 1024
[ 3616.765461]   .se->avg.runnable_avg_sum      : 48214
[ 3616.765461]   .se->avg.runnable_avg_period   : 48214
[ 3616.765461]   .se->avg.load_avg_contrib      : 0
[ 3616.765461]   .se->avg.decay_count           : 0
[ 3616.765461]
[ 3616.765461] cfs_rq[9]:/autogroup-1
[ 3616.765461]   .exec_clock                    : 550145.174923
[ 3616.765461]   .MIN_vruntime                  : 626676.895673
[ 3616.765461]   .min_vruntime                  : 626676.895673
[ 3616.765461]   .max_vruntime                  : 626676.895673
[ 3616.765461]   .spread                        : 0.000000
[ 3616.765461]   .spread0                       : -7047996.037540
[ 3616.765461]   .nr_spread_over                : 2989
[ 3616.765461]   .nr_running                    : 1
[ 3616.765461]   .load                          : 1024
[ 3616.765461]   .runnable_load_avg             : 1023
[ 3616.765461]   .blocked_load_avg              : 0
[ 3616.765461]   .tg_load_contrib               : 1023
[ 3616.765461]   .tg_runnable_contrib           : 1022
[ 3616.765461]   .tg_load_avg                   : 1045
[ 3616.765461]   .tg->runnable_avg              : 1045
[ 3616.765461]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.765461]   .throttled                     : 0
[ 3616.765461]   .throttle_count                : 0
[ 3616.765461]   .se->exec_start                : 1437193.383777
[ 3616.765461]   .se->vruntime                  : 9722263.577627
[ 3616.765461]   .se->sum_exec_runtime          : 550155.935776
[ 3616.765461]   .se->statistics.wait_start     : 1444201.052825
[ 3616.765461]   .se->statistics.sleep_start    : 0.000000
[ 3616.765461]   .se->statistics.block_start    : 0.000000
[ 3616.765461]   .se->statistics.sleep_max      : 0.000000
[ 3616.765461]   .se->statistics.block_max      : 0.000000
[ 3616.765461]   .se->statistics.exec_max       : 13.402801
[ 3616.765461]   .se->statistics.slice_max      : 296.042158
[ 3616.765461]   .se->statistics.wait_max       : 3021.555357
[ 3616.765461]   .se->statistics.wait_sum       : 289078.567466
[ 3616.765461]   .se->statistics.wait_count     : 59652
[ 3616.765461]   .se->load.weight               : 77
[ 3616.765461]   .se->avg.runnable_avg_sum      : 48205
[ 3616.765461]   .se->avg.runnable_avg_period   : 48205
[ 3616.765461]   .se->avg.load_avg_contrib      : 994
[ 3616.765461]   .se->avg.decay_count           : 0
[ 3616.765461]
[ 3616.765461] cfs_rq[9]:/
[ 3616.765461]   .exec_clock                    : 882810.234779
[ 3616.765461]   .MIN_vruntime                  : 9722251.577627
[ 3616.765461]   .min_vruntime                  : 9722263.577627
[ 3616.765461]   .max_vruntime                  : 9722263.577627
[ 3616.765461]   .spread                        : 12.000000
[ 3616.765461]   .spread0                       : 2047590.644414
[ 3616.765461]   .nr_spread_over                : 3110
[ 3616.765461]   .nr_running                    : 4
[ 3616.765461]   .load                          : 3149
[ 3616.765461]   .runnable_load_avg             : 1099
[ 3616.765461]   .blocked_load_avg              : 0
[ 3616.765461]   .tg_load_contrib               : 1099
[ 3616.765461]   .tg_runnable_contrib           : 1010
[ 3616.765461]   .tg_load_avg                   : 2142
[ 3616.765461]   .tg->runnable_avg              : 2096
[ 3616.765461]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.765461]   .throttled                     : 0
[ 3616.765461]   .throttle_count                : 0
[ 3616.765461]   .avg->runnable_avg_sum         : 48224
[ 3616.765461]   .avg->runnable_avg_period      : 48224
[ 3616.765461]
[ 3616.765461] rt_rq[9]:/
[ 3616.765461]   .rt_nr_running                 : 3
[ 3616.765461]   .rt_throttled                  : 0
[ 3616.765461]   .rt_time                       : 859.334535
[ 3616.765461]   .rt_runtime                    : 1000.000000
[ 3616.765461]
[ 3616.765461] dl_rq[9]:
[ 3616.765461]   .dl_nr_running                 : 0
[ 3616.765461]
[ 3616.765461] runnable tasks:
[ 3616.765461]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.765461] ----------------------------------------------------------------------------------------------------------
[ 3616.765461]       watchdog/9    64       -12.000000       907     0       -12.000000        76.932807         0.000000 9 /
[ 3616.765461]      migration/9    65         0.000000       251     0         0.000000        46.434135         0.000000 9 /
[ 3616.765461]      ksoftirqd/9    66   9717303.190749      2557   120   9717303.190749      4575.596391   1433190.976314 9 /
[ 3616.765461]     kworker/9:0H    68      4154.889569         8   100      4154.889569         0.352735     11658.113569 9 /
[ 3616.765461]    kworker/u58:0    69   9722251.577627       786   120   9722251.577627       134.539959   1555701.517859 9 /
[ 3616.765461]      kworker/9:1   732   9722251.759438     15772   120   9722251.759438      5030.663845   1429849.176672 9 /
[ 3616.765461]          kswapd9  3794      4166.888666         4   120      4166.888666         0.482062        93.719660 9 /
[ 3616.765461]    kworker/u77:0  5336     40979.669798         7   100     40979.669798         6.016700     75055.163970 9 /
[ 3616.765461]     fcoethread/9  5693      4192.989628         2   100      4192.989628         0.347357         0.263608 9 /
[ 3616.765461]  bnx2fc_thread/9  5719      4245.702780         2   100      4245.702780         0.284729         0.227051 9 /
[ 3616.765461]   bnx2i_thread/9  5788      4702.535141         2   100      4702.535141         0.383356         0.336362 9 /
[ 3616.765461]        kpsmoused  6753      8001.168127         2   100      8001.168127         0.858096         0.000000 9 /
[ 3616.765461]    kworker/u77:1  8989     40991.631926         2   100     40991.631926         0.671925         0.702088 9 /
[ 3616.765461]    kworker/u58:1  9823   9720856.913928      1477   120   9720856.913928       229.022900    964298.241034 9 /
[ 3616.765461]      kworker/9:0  1481   7027425.370697         6   120   7027425.370697         0.755239    137150.369602 9 /
[ 3616.765461]    kworker/u58:2  7773   8284064.720381       130   120   8284064.720381        16.542903     31375.111632 9 /
[ 3616.765461]       trinity-c9 10525    580210.025392       195   120    580210.025392      1561.451919       710.322793 9 /autogroup-1
[ 3616.765461]       trinity-c9 16461     57486.327869       327   120     57486.327869      2244.197973      4402.499443 9 /autogroup-2077
[ 3616.765461] R     trinity-c9 16739        -7.412688       634    92        -7.412688   2173920.944749       114.341654 9 /autogroup-1
[ 3616.765461]       trinity-c9 16833    626565.624416        50   120    626565.624416       629.072822         0.096199 9 /autogroup-1
[ 3616.765461]       trinity-c9 16921    626676.895673        30   120    626676.895673       201.939781         0.000000 9 /autogroup-1
[ 3616.765461]  trinity-subchil 17003         0.000000         1    92         0.000000         4.219014         0.000000 9 /autogroup-1
[ 3616.765461]       trinity-c9 17044         0.000000         0    92         0.000000         0.000000         0.000000 9 /autogroup-1
[ 3616.912557]
[ 3616.912797] cpu#10, 2260.998 MHz
[ 3616.913277]   .nr_running                    : 0
[ 3616.913748]   .load                          : 0
[ 3616.914291]   .nr_switches                   : 532188
[ 3616.914890]   .nr_load_updates               : 361580
[ 3616.915797]   .nr_uninterruptible            : 20
[ 3616.916254]   .next_balance                  : 4295.299010
[ 3616.916767]   .curr->pid                     : 0
[ 3616.917208]   .clock                         : 3616914.698686
[ 3616.917757]   .clock_task                    : 3604834.089558
[ 3616.918520]   .cpu_load[0]                   : 0
[ 3616.918962]   .cpu_load[1]                   : 0
[ 3616.919438]   .cpu_load[2]                   : 0
[ 3616.919881]   .cpu_load[3]                   : 0
[ 3616.920354]   .cpu_load[4]                   : 0
[ 3616.920894]   .yld_count                     : 49
[ 3616.921459]   .sched_count                   : 532684
[ 3616.922161]   .sched_goidle                  : 244434
[ 3616.922846]   .avg_idle                      : 1000000
[ 3616.923423]   .max_idle_balance_cost         : 500000
[ 3616.923905]   .ttwu_count                    : 61540
[ 3616.924398]   .ttwu_local                    : 21030
[ 3616.925010]
[ 3616.925010] cfs_rq[10]:/
[ 3616.925510]   .exec_clock                    : 223581.397429
[ 3616.926053]   .MIN_vruntime                  : 0.000001
[ 3616.926618]   .min_vruntime                  : 1763971.523147
[ 3616.927448]   .max_vruntime                  : 0.000001
[ 3616.927972]   .spread                        : 0.000000
[ 3616.928459]   .spread0                       : -5910701.410066
[ 3616.929044]   .nr_spread_over                : 2803
[ 3616.929546]   .nr_running                    : 0
[ 3616.930025]   .load                          : 0
[ 3616.930542]   .runnable_load_avg             : 0
[ 3616.930975]   .blocked_load_avg              : 0
[ 3616.931418]   .tg_load_contrib               : 0
[ 3616.931945]   .tg_runnable_contrib           : 0
[ 3616.932380]   .tg_load_avg                   : 2122
[ 3616.932849]   .tg->runnable_avg              : 2363
[ 3616.933449]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.933941]   .throttled                     : 0
[ 3616.934481]   .throttle_count                : 0
[ 3616.934956]   .avg->runnable_avg_sum         : 0
[ 3616.934988]   .avg->runnable_avg_period      : 47867
[ 3616.934988]
[ 3616.934988] rt_rq[10]:/
[ 3616.934988]   .rt_nr_running                 : 0
[ 3616.934988]   .rt_throttled                  : 0
[ 3616.934988]   .rt_time                       : 0.000000
[ 3616.934988]   .rt_runtime                    : 950.000000
[ 3616.934988]
[ 3616.934988] dl_rq[10]:
[ 3616.934988]   .dl_nr_running                 : 0
[ 3616.934988]
[ 3616.934988] runnable tasks:
[ 3616.934988]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.934988] ----------------------------------------------------------------------------------------------------------
[ 3616.934988]      watchdog/10    70       -11.887687       908     0       -11.887687        82.302918         0.000000 10 /
[ 3616.934988]     migration/10    71         0.000000      1683     0         0.000000       300.229679         0.000000 10 /
[ 3616.934988]     ksoftirqd/10    72   1759892.206143      2331   120   1759892.206143      4011.964388   1438305.691519 10 /
[ 3616.934988]    kworker/10:0H    74      1517.480885         8   100      1517.480885         0.268553     11611.026649 10 /
[ 3616.934988]    kworker/u59:0    75    272218.506773        28   120    272218.506773         4.046599    491812.789721 10 /
[ 3616.934988]         kswapd10  3795      1292.410695         4   120      1292.410695         0.435869       111.291251 10 /
[ 3616.934988]     kworker/10:1  4032   1761031.855747      6041   120   1761031.855747      3235.253680   1819684.129561 10 /
[ 3616.934988]    kworker/u78:0  5337     39679.340931        17   100     39679.340931         6.205731     79541.540356 10 /
[ 3616.934988]    fcoethread/10  5694      1529.513165         2   100      1529.513165         0.203267         1.681383 10 /
[ 3616.934988]  bnx2fc_thread/1  5720      1529.535862         2   100      1529.535862         0.162968         0.483808 10 /
[ 3616.934988]  bnx2i_thread/10  5789      1672.237753         2   100      1672.237753         0.164188         0.493154 10 /
[ 3616.934988]    kworker/u78:1  8897     30801.597698         2   100     30801.597698         1.102788         1.024524 10 /
[ 3616.934988]          trinity  9262      3949.134377        66   120      3949.134377       183.684449     10199.381690 10 /autogroup-1
[ 3616.934988]       runtrin.sh  9372      4108.377695         1   120      4108.377695        19.991906         0.000000 10 /autogroup-1
[ 3616.934988]          trinity  9475      4562.452009        71   120      4562.452009       137.989336     10236.478240 10 /autogroup-1
[ 3616.934988]  trinity-watchdo  9517    113314.027796     18808   120    113314.027796      5378.624793   3374234.657155 10 /autogroup-1
[ 3616.934988]     trinity-main  9518    111544.942348     42122   120    111544.942348    155963.038077   1081456.383241 10 /autogroup-1
[ 3616.934988]    kworker/u59:1 10285   1744719.359774       178   120   1744719.359774        31.928438    931933.885338 10 /
[ 3616.934988]     kworker/10:0  6679   1663595.251467        10   120   1663595.251467         1.345211    120961.687141 10 /
[ 3616.934988]       trinity-c2 16869       129.073206        59   120       129.073206       859.484045      3303.313383 10 /autogroup-2095
[ 3616.969177]
[ 3616.969341] cpu#11, 2260.998 MHz
[ 3616.969657]   .nr_running                    : 0
[ 3616.970114]   .load                          : 0
[ 3616.970583]   .nr_switches                   : 527884
[ 3616.971121]   .nr_load_updates               : 361580
[ 3616.971611]   .nr_uninterruptible            : -31
[ 3616.972137]   .next_balance                  : 4295.299021
[ 3616.972650]   .curr->pid                     : 0
[ 3616.973156]   .clock                         : 3616964.818208
[ 3616.973724]   .clock_task                    : 3601807.936406
[ 3616.974321]   .cpu_load[0]                   : 0
[ 3616.974759]   .cpu_load[1]                   : 0
[ 3616.975420]   .cpu_load[2]                   : 0
[ 3616.975861]   .cpu_load[3]                   : 0
[ 3616.976294]   .cpu_load[4]                   : 0
[ 3616.976838]   .yld_count                     : 31
[ 3616.977341]   .sched_count                   : 528352
[ 3616.977866]   .sched_goidle                  : 244497
[ 3616.978443]   .avg_idle                      : 1000000
[ 3616.978937]   .max_idle_balance_cost         : 500000
[ 3616.979423]   .ttwu_count                    : 57003
[ 3616.979889]   .ttwu_local                    : 19437
[ 3616.980445]
[ 3616.980445] cfs_rq[11]:/
[ 3616.980865]   .exec_clock                    : 197949.257306
[ 3616.981425]   .MIN_vruntime                  : 0.000001
[ 3616.981917]   .min_vruntime                  : 1302470.916945
[ 3616.982509]   .max_vruntime                  : 0.000001
[ 3616.983081]   .spread                        : 0.000000
[ 3616.983577]   .spread0                       : -6372202.016268
[ 3616.984207]   .nr_spread_over                : 3437
[ 3616.984666]   .nr_running                    : 0
[ 3616.985161]   .load                          : 0
[ 3616.985409]   .runnable_load_avg             : 0
[ 3616.985409]   .blocked_load_avg              : 0
[ 3616.985409]   .tg_load_contrib               : 0
[ 3616.985409]   .tg_runnable_contrib           : 0
[ 3616.985409]   .tg_load_avg                   : 2122
[ 3616.985409]   .tg->runnable_avg              : 2260
[ 3616.985409]   .tg->cfs_bandwidth.timer_active: 0
[ 3616.985409]   .throttled                     : 0
[ 3616.985409]   .throttle_count                : 0
[ 3616.985409]   .avg->runnable_avg_sum         : 0
[ 3616.985409]   .avg->runnable_avg_period      : 48050
[ 3616.985409]
[ 3616.985409] rt_rq[11]:/
[ 3616.985409]   .rt_nr_running                 : 0
[ 3616.985409]   .rt_throttled                  : 0
[ 3616.985409]   .rt_time                       : 0.000000
[ 3616.985409]   .rt_runtime                    : 950.000000
[ 3616.985409]
[ 3616.985409] dl_rq[11]:
[ 3616.985409]   .dl_nr_running                 : 0
[ 3616.985409]
[ 3616.985409] runnable tasks:
[ 3616.985409]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3616.985409] ----------------------------------------------------------------------------------------------------------
[ 3616.985409]         kthreadd     2   1238183.315585       643   120   1238183.315585       386.014621   1391257.021480 11 /
[ 3616.985409]    kworker/u48:0     6   1284365.386234      6767   120   1284365.386234      6132.656621   1414816.174871 11 /
[ 3616.985409]      watchdog/11    76       -11.886682       907     0       -11.886682        79.524935         0.000000 11 /
[ 3616.985409]     migration/11    77         0.000000      1793     0         0.000000       300.870074         0.000000 11 /
[ 3616.985409]     ksoftirqd/11    78   1298499.451354      2408   120   1298499.451354      4559.903630   1439115.666333 11 /
[ 3616.985409]    kworker/11:0H    80      6059.371616         8   100      6059.371616         0.202980     11559.915666 11 /
[ 3616.985409]    kworker/u60:0    81     41762.353266        29   120     41762.353266         2.511275     97218.167225 11 /
[ 3616.985409]     kworker/11:1  3558   1299278.121305      5512   120   1299278.121305      3086.917695   1821839.720753 11 /
[ 3616.985409]         kswapd11  3796      2350.939001         4   120      2350.939001         0.586351       110.048014 11 /
[ 3616.985409]  ecryptfs-kthrea  4044      4854.093067         2   120      4854.093067         0.381834         0.183946 11 /
[ 3616.985409]           nfsiod  4048      4904.360863         2   100      4904.360863         0.253779         1.248328 11 /
[ 3616.985409]          cifsiod  4063      5068.607407         2   100      5068.607407         0.755234         0.294778 11 /
[ 3616.985409]            jfsIO  4093      5428.577609         2   120      5428.577609         0.296197         0.216595 11 /
[ 3616.985409]        jfsCommit  4094      5441.832673         2   120      5441.832673         1.255070         0.268038 11 /
[ 3616.985409]        jfsCommit  4096      5454.056585         2   120      5454.056585         0.223918         0.315328 11 /
[ 3616.985409]        jfsCommit  4097      5466.269571         2   120      5466.269571         0.212992         0.209110 11 /
[ 3616.985409]        jfsCommit  4098      5478.436239         2   120      5478.436239         0.166674         1.424134 11 /
[ 3616.985409]        jfsCommit  4099      5491.149908         2   120      5491.149908         0.713675         0.267869 11 /
[ 3616.985409]        jfsCommit  4100      5503.338132         2   120      5503.338132         0.188230         0.259487 11 /
[ 3616.985409]        jfsCommit  4101      5515.526573         2   120      5515.526573         0.188447         0.210346 11 /
[ 3616.985409]        jfsCommit  4102      5527.668641         2   120      5527.668641         0.142074         0.327252 11 /
[ 3616.985409]        jfsCommit  4103      5539.896027         2   120      5539.896027         0.227392         0.175709 11 /
[ 3616.985409]        jfsCommit  4104      5552.082598         2   120      5552.082598         0.186577         0.207083 11 /
[ 3616.985409]        jfsCommit  4105      5564.308529         2   120      5564.308529         0.225937         0.289761 11 /
[ 3616.985409]        jfsCommit  4106      5576.515048         2   120      5576.515048         0.206525         0.285776 11 /
[ 3616.985409]        jfsCommit  4107      5588.678538         2   120      5588.678538         0.163496         0.112072 11 /
[ 3616.985409]        jfsCommit  4108      5600.939718         2   120      5600.939718         0.261186         0.214470 11 /
[ 3616.985409]        jfsCommit  4109      5613.123485         2   120      5613.123485         0.183773         0.258797 11 /
[ 3616.985409]        jfsCommit  4110      5625.435086         2   120      5625.435086         0.311607         0.256368 11 /
[ 3616.985409]        jfsCommit  4111      5637.768139         2   120      5637.768139         0.333059         0.179375 11 /
[ 3616.985409]          jfsSync  4112      5650.181809         2   120      5650.181809         0.413676         0.234556 11 /
[ 3616.985409]         xfsalloc  4126      5825.674760         2   100      5825.674760         0.428693         0.619626 11 /
[ 3616.985409]    kworker/u79:0  5338     52006.292250        16   100     52006.292250         6.629416    214077.605955 11 /
[ 3616.985409]    fcoethread/11  5695      6071.400518         2   100      6071.400518         0.397949         0.619090 11 /
[ 3616.985409]  bnx2fc_thread/1  5721      6071.431597         2   100      6071.431597         0.175988         0.253270 11 /
[ 3616.985409]  bnx2i_thread/11  5790      6096.642232         2   100      6096.642232         0.181568         0.210922 11 /
[ 3616.985409]    kworker/u60:1  9062   1279948.417202        95   120   1279948.417202        27.588073   1311941.418031 11 /
[ 3616.985409]  trinity-watchdo  9306     60361.659869     23651   120     60361.659869      6691.927412   3431540.444108 11 /autogroup-1
[ 3616.985409]          trinity  9374      5971.876281        75   120      5971.876281       157.954417     10249.406698 11 /autogroup-1
[ 3616.985409]    kworker/u79:1  9411     49092.961580         2   100     49092.961580         0.766523         0.793432 11 /
[ 3616.985409]     kworker/11:2  9981   1236826.116099         3   120   1236826.116099         0.356887     98160.575659 11 /
[ 3617.091161]
[ 3617.091320] cpu#12, 2260.998 MHz
[ 3617.091626]   .nr_running                    : 0
[ 3617.092920]   .load                          : 0
[ 3617.093619]   .nr_switches                   : 563785
[ 3617.094101]   .nr_load_updates               : 361587
[ 3617.094652]   .nr_uninterruptible            : 22
[ 3617.095585]   .next_balance                  : 4295.299012
[ 3617.097166]   .curr->pid                     : 0
[ 3617.097743]   .clock                         : 3617090.407706
[ 3617.098338]   .clock_task                    : 3603690.529694
[ 3617.098910]   .cpu_load[0]                   : 0
[ 3617.099344]   .cpu_load[1]                   : 0
[ 3617.099856]   .cpu_load[2]                   : 0
[ 3617.100400]   .cpu_load[3]                   : 0
[ 3617.100920]   .cpu_load[4]                   : 0
[ 3617.101363]   .yld_count                     : 26
[ 3617.101905]   .sched_count                   : 564331
[ 3617.102745]   .sched_goidle                  : 259372
[ 3617.103653]   .avg_idle                      : 1000000
[ 3617.104360]   .max_idle_balance_cost         : 500000
[ 3617.104884]   .ttwu_count                    : 57844
[ 3617.105682]   .ttwu_local                    : 19678
[ 3617.106252]
[ 3617.106252] cfs_rq[12]:/
[ 3617.106864]   .exec_clock                    : 228009.380451
[ 3617.107514]   .MIN_vruntime                  : 0.000001
[ 3617.108107]   .min_vruntime                  : 1356609.110510
[ 3617.108659]   .max_vruntime                  : 0.000001
[ 3617.109248]   .spread                        : 0.000000
[ 3617.109795]   .spread0                       : -6318063.822703
[ 3617.110466]   .nr_spread_over                : 2494
[ 3617.111001]   .nr_running                    : 0
[ 3617.111431]   .load                          : 0
[ 3617.111982]   .runnable_load_avg             : 0
[ 3617.112518]   .blocked_load_avg              : 0
[ 3617.113081]   .tg_load_contrib               : 0
[ 3617.113596]   .tg_runnable_contrib           : 0
[ 3617.114052]   .tg_load_avg                   : 2149
[ 3617.114537]   .tg->runnable_avg              : 2123
[ 3617.115103]   .tg->cfs_bandwidth.timer_active: 0
[ 3617.115666]   .throttled                     : 0
[ 3617.115666]   .throttle_count                : 0
[ 3617.115666]   .avg->runnable_avg_sum         : 0
[ 3617.115666]   .avg->runnable_avg_period      : 47820
[ 3617.115666]
[ 3617.115666] rt_rq[12]:/
[ 3617.115666]   .rt_nr_running                 : 0
[ 3617.115666]   .rt_throttled                  : 0
[ 3617.115666]   .rt_time                       : 0.000000
[ 3617.115666]   .rt_runtime                    : 950.000000
[ 3617.115666]
[ 3617.115666] dl_rq[12]:
[ 3617.115666]   .dl_nr_running                 : 0
[ 3617.115666]
[ 3617.115666] runnable tasks:
[ 3617.115666]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3617.115666] ----------------------------------------------------------------------------------------------------------
[ 3617.115666]      watchdog/12    82       -11.887468       908     0       -11.887468        76.849254         0.000000 12 /
[ 3617.115666]     migration/12    83         0.000000      2031     0         0.000000       327.188516         0.000000 12 /
[ 3617.115666]     ksoftirqd/12    84   1353075.104920      1853   120   1353075.104920      3429.204733   1440834.636504 12 /
[ 3617.115666]    kworker/12:0H    86       472.996221         8   100       472.996221         0.196582     11518.793293 12 /
[ 3617.115666]    kworker/u61:0    87    340796.800231        28   120    340796.800231         1.535148    523419.942988 12 /
[ 3617.115666]     kworker/12:1  3574   1356597.594885      6964   120   1356597.594885      4526.256216   3597895.331283 12 /
[ 3617.115666]         kswapd12  3797       415.104347         4   120       415.104347         0.714078       103.161233 12 /
[ 3617.115666]        jfsCommit  4095       475.799477         2   120       475.799477         0.208313         0.289628 12 /
[ 3617.115666]    kworker/u80:0  5339     29391.017510        13   100     29391.017510         5.729084     77047.311741 12 /
[ 3617.115666]    fcoethread/12  5696       485.023257         2   100       485.023257         1.306837         0.564189 12 /
[ 3617.115666]  bnx2fc_thread/1  5722       485.121116         2   100       485.121116         0.269846         0.272554 12 /
[ 3617.115666]  bnx2i_thread/12  5791       485.171098         2   100       485.171098         0.223803         0.302044 12 /
[ 3617.115666]       irqbalance  8308      2150.208317       411   120      2150.208317      3672.177053   3566960.652719 12 /autogroup-2
[ 3617.115666]    kworker/u80:1  8866     21304.564682         2   100     21304.564682         1.191421         0.432509 12 /
[ 3617.115666]    kworker/u61:1 11995   1266993.209689        74   120   1266993.209689        21.202337    834353.702557 12 /
[ 3617.115666]     kworker/12:2  5301   1187926.857967         2   120   1187926.857967         0.325925         0.462255 12 /
[ 3617.144995]
[ 3617.145184] cpu#13, 2260.998 MHz
[ 3617.145526]   .nr_running                    : 0
[ 3617.145959]   .load                          : 0
[ 3617.146410]   .nr_switches                   : 662472
[ 3617.147125]   .nr_load_updates               : 361586
[ 3617.147629]   .nr_uninterruptible            : -24
[ 3617.148101]   .next_balance                  : 4295.299023
[ 3617.148610]   .curr->pid                     : 0
[ 3617.149053]   .clock                         : 3617147.990736
[ 3617.149658]   .clock_task                    : 3598003.349854
[ 3617.150280]   .cpu_load[0]                   : 0
[ 3617.150809]   .cpu_load[1]                   : 0
[ 3617.151246]   .cpu_load[2]                   : 0
[ 3617.151836]   .cpu_load[3]                   : 0
[ 3617.152405]   .cpu_load[4]                   : 0
[ 3617.153243]   .yld_count                     : 14
[ 3617.153710]   .sched_count                   : 663210
[ 3617.154178]   .sched_goidle                  : 304691
[ 3617.155304]   .avg_idle                      : 1000000
[ 3617.156072]   .max_idle_balance_cost         : 500000
[ 3617.156629]   .ttwu_count                    : 70084
[ 3617.157152]   .ttwu_local                    : 17766
[ 3617.157973]
[ 3617.157973] cfs_rq[13]:/
[ 3617.158378]   .exec_clock                    : 257444.282622
[ 3617.158907]   .MIN_vruntime                  : 0.000001
[ 3617.159397]   .min_vruntime                  : 1148574.400219
[ 3617.159957]   .max_vruntime                  : 0.000001
[ 3617.160564]   .spread                        : 0.000000
[ 3617.161155]   .spread0                       : -6526098.532994
[ 3617.161891]   .nr_spread_over                : 2823
[ 3617.162590]   .nr_running                    : 0
[ 3617.163184]   .load                          : 0
[ 3617.163638]   .runnable_load_avg             : 0
[ 3617.164112]   .blocked_load_avg              : 0
[ 3617.164680]   .tg_load_contrib               : 0
[ 3617.165274]   .tg_runnable_contrib           : 0
[ 3617.165274]   .tg_load_avg                   : 2149
[ 3617.165274]   .tg->runnable_avg              : 2339
[ 3617.165274]   .tg->cfs_bandwidth.timer_active: 0
[ 3617.165274]   .throttled                     : 0
[ 3617.165274]   .throttle_count                : 0
[ 3617.165274]   .avg->runnable_avg_sum         : 0
[ 3617.165274]   .avg->runnable_avg_period      : 48235
[ 3617.165274]
[ 3617.165274] rt_rq[13]:/
[ 3617.165274]   .rt_nr_running                 : 0
[ 3617.165274]   .rt_throttled                  : 0
[ 3617.165274]   .rt_time                       : 0.000000
[ 3617.165274]   .rt_runtime                    : 950.000000
[ 3617.165274]
[ 3617.165274] dl_rq[13]:
[ 3617.165274]   .dl_nr_running                 : 0
[ 3617.165274]
[ 3617.165274] runnable tasks:
[ 3617.165274]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3617.165274] ----------------------------------------------------------------------------------------------------------
[ 3617.165274]      watchdog/13    88       -11.882081       908     0       -11.882081        88.093607         0.000000 13 /
[ 3617.165274]     migration/13    89         0.000000      1636     0         0.000000       295.590403         0.000000 13 /
[ 3617.165274]     ksoftirqd/13    90   1147726.169164      1898   120   1147726.169164      3110.697647   1438802.329413 13 /
[ 3617.165274]    kworker/13:0H    92      4885.073499         8   100      4885.073499         0.257207     11468.422748 13 /
[ 3617.165274]    kworker/u62:0    93    382382.032824        29   120    382382.032824         1.911868    505640.167546 13 /
[ 3617.165274]     kworker/13:1  3365   1148562.786856      7148   120   1148562.786856      4537.211788   1435381.292709 13 /
[ 3617.165274]         kswapd13  3798      4897.071895         4   120      4897.071895         0.443218       100.728736 13 /
[ 3617.165274]    kworker/u81:0  5340     32463.896832         7   100     32463.896832         2.402323     75037.511843 13 /
[ 3617.165274]    fcoethread/13  5697      4986.912397         2   100      4986.912397         1.190026         0.247636 13 /
[ 3617.165274]  bnx2fc_thread/1  5723      4986.957740         2   100      4986.957740         0.246317         0.250250 13 /
[ 3617.165274]  bnx2i_thread/13  5792      4987.006864         2   100      4987.006864         0.308565         0.439231 13 /
[ 3617.165274]    kworker/u81:1  8988     32475.883885         2   100     32475.883885         1.665413         0.621251 13 /
[ 3617.165274]    kworker/u62:1 11099   1142146.783783        56   120   1142146.783783        11.094155    923274.964051 13 /
[ 3617.165274]     kworker/13:0  3319   1009990.668005         4   120   1009990.668005         1.021935    108589.831555 13 /
[ 3617.203540]
[ 3617.203803] cpu#14, 2260.998 MHz
[ 3617.204179]   .nr_running                    : 0
[ 3617.205831]   .load                          : 0
[ 3617.207186]   .nr_switches                   : 658379
[ 3617.207953]   .nr_load_updates               : 361589
[ 3617.208502]   .nr_uninterruptible            : 5
[ 3617.208942]   .next_balance                  : 4295.299058
[ 3617.209458]   .curr->pid                     : 0
[ 3617.210002]   .clock                         : 3617207.631419
[ 3617.210865]   .clock_task                    : 3600901.738624
[ 3617.211478]   .cpu_load[0]                   : 0
[ 3617.212123]   .cpu_load[1]                   : 0
[ 3617.212833]   .cpu_load[2]                   : 0
[ 3617.213602]   .cpu_load[3]                   : 0
[ 3617.214255]   .cpu_load[4]                   : 0
[ 3617.215263]   .yld_count                     : 28
[ 3617.216942]   .sched_count                   : 658951
[ 3617.218653]   .sched_goidle                  : 305243
[ 3617.219361]   .avg_idle                      : 1000000
[ 3617.219803]   .max_idle_balance_cost         : 500000
[ 3617.220301]   .ttwu_count                    : 64623
[ 3617.220788]   .ttwu_local                    : 17609
[ 3617.221279]
[ 3617.221279] cfs_rq[14]:/
[ 3617.221803]   .exec_clock                    : 255522.112191
[ 3617.222534]   .MIN_vruntime                  : 0.000001
[ 3617.223664]   .min_vruntime                  : 1076206.111095
[ 3617.224139]   .max_vruntime                  : 0.000001
[ 3617.225218]   .spread                        : 0.000000
[ 3617.225233]   .spread0                       : -6598466.822118
[ 3617.225233]   .nr_spread_over                : 2067
[ 3617.225233]   .nr_running                    : 0
[ 3617.225233]   .load                          : 0
[ 3617.225233]   .runnable_load_avg             : 0
[ 3617.225233]   .blocked_load_avg              : 0
[ 3617.225233]   .tg_load_contrib               : 0
[ 3617.225233]   .tg_runnable_contrib           : 0
[ 3617.225233]   .tg_load_avg                   : 2149
[ 3617.225233]   .tg->runnable_avg              : 2159
[ 3617.225233]   .tg->cfs_bandwidth.timer_active: 0
[ 3617.225233]   .throttled                     : 0
[ 3617.225233]   .throttle_count                : 0
[ 3617.225233]   .avg->runnable_avg_sum         : 0
[ 3617.225233]   .avg->runnable_avg_period      : 47920
[ 3617.225233]
[ 3617.225233] rt_rq[14]:/
[ 3617.225233]   .rt_nr_running                 : 0
[ 3617.225233]   .rt_throttled                  : 0
[ 3617.225233]   .rt_time                       : 0.000000
[ 3617.225233]   .rt_runtime                    : 950.000000
[ 3617.225233]
[ 3617.225233] dl_rq[14]:
[ 3617.225233]   .dl_nr_running                 : 0
[ 3617.225233]
[ 3617.225233] runnable tasks:
[ 3617.225233]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3617.225233] ----------------------------------------------------------------------------------------------------------
[ 3617.225233]      watchdog/14    94       -11.824763       908     0       -11.824763        79.276586         0.000000 14 /
[ 3617.225233]     migration/14    95         0.000000      1847     0         0.000000       303.182758         0.000000 14 /
[ 3617.225233]     ksoftirqd/14    96   1070936.020825      1671   120   1070936.020825      3012.787095   1433726.979897 14 /
[ 3617.225233]    kworker/14:0H    98        24.553883         8   100        24.553883         0.465127     11408.311878 14 /
[ 3617.225233]    kworker/u63:0    99     35569.318367        28   120     35569.318367         2.974302    111437.295360 14 /
[ 3617.225233]         kswapd14  3799        36.552070         4   120        36.552070         1.577274        97.432820 14 /
[ 3617.225233]     kworker/14:1  4676   1028354.843008      6201   120   1028354.843008      3951.418774   1368956.805171 14 /
[ 3617.225233]    kworker/u82:0  5341    269198.575832         7   100    269198.575832         2.949104    387638.294191 14 /
[ 3617.225233]    fcoethread/14  5698        74.400199         2   100        74.400199         0.275709         0.327972 14 /
[ 3617.225233]  bnx2fc_thread/1  5724        74.451522         2   100        74.451522         0.208736         0.271924 14 /
[ 3617.225233]  bnx2i_thread/14  5793        74.498980         2   100        74.498980         0.182347         0.465249 14 /
[ 3617.225233]  trinity-watchdo  9085     73819.037115     26815   120     73819.037115      7247.331235   3489677.835209 14 /autogroup-1
[ 3617.225233]    kworker/u63:1  9101   1067880.625433       113   120   1067880.625433        23.359356   1325181.254383 14 /
[ 3617.225233]    kworker/u82:1  9716    269210.548368         2   100    269210.548368         0.784659         0.702744 14 /
[ 3617.225233]     kworker/14:0  2967   1072114.819723       345   120   1072114.819723       146.374084    337479.405723 14 /
[ 3617.225233]       trinity-c3 16764       173.150357        96   120       173.150357      1075.122646      2757.722145 14 /autogroup-2089
[ 3617.273508]
[ 3617.273790] cpu#15, 2260.998 MHz
[ 3617.274337]   .nr_running                    : 0
[ 3617.275708]   .load                          : 0
[ 3617.276849]   .nr_switches                   : 740041
[ 3617.278329]   .nr_load_updates               : 361591
[ 3617.279175]   .nr_uninterruptible            : 3
[ 3617.279884]   .next_balance                  : 4295.299069
[ 3617.280768]   .curr->pid                     : 0
[ 3617.281680]   .clock                         : 3617277.217578
[ 3617.282799]   .clock_task                    : 3599276.985693
[ 3617.284106]   .cpu_load[0]                   : 0
[ 3617.285422]   .cpu_load[1]                   : 0
[ 3617.286560]   .cpu_load[2]                   : 0
[ 3617.287709]   .cpu_load[3]                   : 0
[ 3617.288497]   .cpu_load[4]                   : 0
[ 3617.289184]   .yld_count                     : 19
[ 3617.289933]   .sched_count                   : 740617
[ 3617.290700]   .sched_goidle                  : 325118
[ 3617.291562]   .avg_idle                      : 1000000
[ 3617.293055]   .max_idle_balance_cost         : 500000
[ 3617.294047]   .ttwu_count                    : 54731
[ 3617.295460]   .ttwu_local                    : 16102
[ 3617.296889]
[ 3617.296889] cfs_rq[15]:/
[ 3617.297561]   .exec_clock                    : 234807.212027
[ 3617.298387]   .MIN_vruntime                  : 0.000001
[ 3617.299149]   .min_vruntime                  : 1229513.421033
[ 3617.300007]   .max_vruntime                  : 0.000001
[ 3617.300831]   .spread                        : 0.000000
[ 3617.301604]   .spread0                       : -6445159.512180
[ 3617.303298]   .nr_spread_over                : 3018
[ 3617.304244]   .nr_running                    : 0
[ 3617.305098]   .load                          : 0
[ 3617.305442]   .runnable_load_avg             : 0
[ 3617.305442]   .blocked_load_avg              : 0
[ 3617.305442]   .tg_load_contrib               : 0
[ 3617.305442]   .tg_runnable_contrib           : 0
[ 3617.305442]   .tg_load_avg                   : 2149
[ 3617.305442]   .tg->runnable_avg              : 2153
[ 3617.305442]   .tg->cfs_bandwidth.timer_active: 0
[ 3617.305442]   .throttled                     : 0
[ 3617.305442]   .throttle_count                : 0
[ 3617.305442]   .avg->runnable_avg_sum         : 0
[ 3617.305442]   .avg->runnable_avg_period      : 48358
[ 3617.305442]
[ 3617.305442] rt_rq[15]:/
[ 3617.305442]   .rt_nr_running                 : 0
[ 3617.305442]   .rt_throttled                  : 0
[ 3617.305442]   .rt_time                       : 0.000000
[ 3617.305442]   .rt_runtime                    : 950.000000
[ 3617.305442]
[ 3617.305442] dl_rq[15]:
[ 3617.305442]   .dl_nr_running                 : 0
[ 3617.305442]
[ 3617.305442] runnable tasks:
[ 3617.305442]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3617.305442] ----------------------------------------------------------------------------------------------------------
[ 3617.305442]      watchdog/15   100       -11.865333       907     0       -11.865333        80.506820         0.000000 15 /
[ 3617.305442]     migration/15   101         0.000000      1279     0         0.000000       239.709912         0.000000 15 /
[ 3617.305442]     ksoftirqd/15   102   1229259.686462      1430   120   1229259.686462      2725.563231   1435452.066720 15 /
[ 3617.305442]    kworker/15:0H   104        28.126915         8   100        28.126915         0.421040     11357.948251 15 /
[ 3617.305442]    kworker/u64:0   105     20991.437306        26   120     20991.437306         2.280394     88321.144144 15 /
[ 3617.305442]           rpciod  3670        12.147496         2   100        12.147496         0.446333         0.000000 15 /
[ 3617.305442]         kswapd15  3800        12.602373         4   120        12.602373         1.159243        95.244147 15 /
[ 3617.305442]     kworker/15:1  4033   1229501.841620      6268   120   1229501.841620      4255.240322   1456414.561539 15 /
[ 3617.305442]    kworker/u83:0  5342    194639.727330     64629   100    194639.727330     14086.404502    412633.024497 15 /
[ 3617.305442]    fcoethread/15  5699        53.551403         2   100        53.551403         0.226818         1.002119 15 /
[ 3617.305442]  bnx2fc_thread/1  5725        53.580978         2   100        53.580978         0.190569         0.210063 15 /
[ 3617.305442]  bnx2i_thread/15  5794        53.610212         2   100        53.610212         0.323291         0.227676 15 /
[ 3617.305442]
[ 3617.305442]   kworker/u64:1  8841   1039803.865120     21749   120   1039803.865120      5323.471282   1278207.090364 15 /
[ 3617.305442]       runtrin.sh  9154      4007.389506         1   120      4007.389506        24.333615         0.000000 15 /autogroup-1
[ 3617.305442]          trinity  9156      4055.684510        68   120      4055.684510       144.871042     10240.460175 15 /autogroup-1
[ 3617.305442]    kworker/u83:2  9713    190648.747789       119   100    190648.747789        19.507348     74071.289857 15 /
[ 3617.305442]     kworker/15:0 27214    531887.042605         4   120    531887.042605         1.390419        92.115521 15 /
[ 3617.373793]
[ 3617.374253] cpu#16, 2260.998 MHz
[ 3617.375432]   .nr_running                    : 0
[ 3617.376237]   .load                          : 0
[ 3617.377131]   .nr_switches                   : 541507
[ 3617.378078]   .nr_load_updates               : 361595
[ 3617.378825]   .nr_uninterruptible            : -13
[ 3617.379543]   .next_balance                  : 4295.299046
[ 3617.380405]   .curr->pid                     : 0
[ 3617.381218]   .clock                         : 3617376.024403
[ 3617.382194]   .clock_task                    : 3602421.958095
[ 3617.383513]   .cpu_load[0]                   : 0
[ 3617.384208]   .cpu_load[1]                   : 0
[ 3617.385365]   .cpu_load[2]                   : 0
[ 3617.386865]   .cpu_load[3]                   : 0
[ 3617.387882]   .cpu_load[4]                   : 0
[ 3617.388667]   .yld_count                     : 16
[ 3617.389364]   .sched_count                   : 542007
[ 3617.390132]   .sched_goidle                  : 253961
[ 3617.390940]   .avg_idle                      : 1000000
[ 3617.391754]   .max_idle_balance_cost         : 500000
[ 3617.392538]   .ttwu_count                    : 53352
[ 3617.393412]   .ttwu_local                    : 14532
[ 3617.394174]
[ 3617.394174] cfs_rq[16]:/autogroup-1
[ 3617.394974]   .exec_clock                    : 64756.767883
[ 3617.395347]   .MIN_vruntime                  : 0.000001
[ 3617.395347]   .min_vruntime                  : 63691.691944
[ 3617.395347]   .max_vruntime                  : 0.000001
[ 3617.395347]   .spread                        : 0.000000
[ 3617.395347]   .spread0                       : -7610981.241269
[ 3617.395347]   .nr_spread_over                : 77
[ 3617.395347]   .nr_running                    : 0
[ 3617.395347]   .load                          : 0
[ 3617.395347]   .runnable_load_avg             : 0
[ 3617.395347]   .blocked_load_avg              : 0
[ 3617.395347]   .tg_load_contrib               : 0
[ 3617.395347]   .tg_runnable_contrib           : 0
[ 3617.395347]   .tg_load_avg                   : 1038
[ 3617.395347]   .tg->runnable_avg              : 1072
[ 3617.395347]   .tg->cfs_bandwidth.timer_active: 0
[ 3617.395347]   .throttled                     : 0
[ 3617.395347]   .throttle_count                : 0
[ 3617.395347]   .se->exec_start                : 3601702.757347
[ 3617.395347]   .se->vruntime                  : 818034.955088
[ 3617.395347]   .se->sum_exec_runtime          : 64766.706652
[ 3617.395347]   .se->statistics.wait_start     : 0.000000
[ 3617.395347]   .se->statistics.sleep_start    : 0.000000
[ 3617.395347]   .se->statistics.block_start    : 0.000000
[ 3617.395347]   .se->statistics.sleep_max      : 0.000000
[ 3617.395347]   .se->statistics.block_max      : 0.000000
[ 3617.395347]   .se->statistics.exec_max       : 10.746898
[ 3617.395347]   .se->statistics.slice_max      : 63.142415
[ 3617.395347]   .se->statistics.wait_max       : 19.718389
[ 3617.395347]   .se->statistics.wait_sum       : 4445.748194
[ 3617.395347]   .se->statistics.wait_count     : 48193
[ 3617.395347]   .se->load.weight               : 2
[ 3617.395347]   .se->avg.runnable_avg_sum      : 4
[ 3617.395347]   .se->avg.runnable_avg_period   : 46941
[ 3617.395347]   .se->avg.load_avg_contrib      : 0
[ 3617.395347]   .se->avg.decay_count           : 3434852
[ 3617.395347]
[ 3617.395347] cfs_rq[16]:/
[ 3617.395347]   .exec_clock                    : 206435.680809
[ 3617.395347]   .MIN_vruntime                  : 0.000001
[ 3617.395347]   .min_vruntime                  : 818034.955088
[ 3617.395347]   .max_vruntime                  : 0.000001
[ 3617.395347]   .spread                        : 0.000000
[ 3617.395347]   .spread0                       : -6856637.978125
[ 3617.395347]   .nr_spread_over                : 2352
[ 3617.395347]   .nr_running                    : 0
[ 3617.395347]   .load                          : 0
[ 3617.395347]   .runnable_load_avg             : 0
[ 3617.395347]   .blocked_load_avg              : 0
[ 3617.395347]   .tg_load_contrib               : 0
[ 3617.395347]   .tg_runnable_contrib           : 1
[ 3617.395347]   .tg_load_avg                   : 2152
[ 3617.395347]   .tg->runnable_avg              : 2174
[ 3617.395347]   .tg->cfs_bandwidth.timer_active: 0
[ 3617.395347]   .throttled                     : 0
[ 3617.395347]   .throttle_count                : 0
[ 3617.395347]   .avg->runnable_avg_sum         : 78
[ 3617.395347]   .avg->runnable_avg_period      : 48617
[ 3617.395347]
[ 3617.395347] rt_rq[16]:/
[ 3617.395347]   .rt_nr_running                 : 0
[ 3617.395347]   .rt_throttled                  : 0
[ 3617.395347]   .rt_time                       : 0.080361
[ 3617.395347]   .rt_runtime                    : 950.000000
[ 3617.395347]
[ 3617.395347] dl_rq[16]:
[ 3617.395347]   .dl_nr_running                 : 0
[ 3617.395347]
[ 3617.395347] runnable tasks:
[ 3617.395347]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3617.395347] ----------------------------------------------------------------------------------------------------------
[ 3617.395347]      watchdog/16   106       -11.870560       909     0       -11.870560        80.261471         0.000000 16 /
[ 3617.395347]     migration/16   107         0.000000      1868     0         0.000000       310.971116         0.000000 16 /
[ 3617.395347]     ksoftirqd/16   108    814082.949355      1369   120    814082.949355      2570.644775   1435953.076640 16 /
[ 3617.395347]    kworker/16:0H   110        49.969853         8   100        49.969853         0.383064     11308.970507 16 /
[ 3617.395347]    kworker/u65:0   111     32279.885534        27   120     32279.885534         2.686288    102650.001953 16 /
[ 3617.395347]         kswapd16  3801         0.246750         4   120         0.246750         0.786545        92.657656 16 /
[ 3617.395347]    xfs_mru_cache  4128        24.678017         2   100        24.678017         0.300850         0.292628 16 /
[ 3617.395347]         ocfs2_wq  4142        36.970744         2   100        36.970744         0.325164         0.558324 16 /
[ 3617.395347]         user_dlm  4144        49.792273         2   100        49.792273         0.865490         0.480887 16 /
[ 3617.395347]  glock_workqueue  4151        61.999960         2   100        61.999960         0.251659         0.327711 16 /
[ 3617.395347]  delete_workqueu  4152        74.262687         2   100        74.262687         0.294703         1.707201 16 /
[ 3617.395347]     gfs_recovery  4160        86.409014         2   100        86.409014         0.178367         0.374924 16 /
[ 3617.395347]     kworker/16:1  4168    814579.616985      5307   120    814579.616985      3945.708339   1614072.428023 16 /
[ 3617.395347]    kworker/u84:0  5343       137.872679         4   100       137.872679         0.703726      7730.567915 16 /
[ 3617.395347]    fcoethread/16  5700       137.017923         2   100       137.017923         0.393985         0.535775 16 /
[ 3617.395347]  bnx2fc_thread/1  5726       137.064824         2   100       137.064824         0.193451         0.458754 16 /
[ 3617.395347]  bnx2i_thread/16  5795       137.109878         2   100       137.109878         0.231512         0.112993 16 /
[ 3617.395347]    kworker/u65:1  9084    765352.064017        52   120    765352.064017        11.009801   1266379.853869 16 /
[ 3617.395347]  trinity-watchdo  9193     63691.691944     25146   120     63691.691944      6850.979594   3461329.534035 16 /autogroup-1
[ 3617.395347]     kworker/16:0   409    701137.975147         7   120    701137.975147         0.737795    203871.981215 16 /
[ 3617.492668]
[ 3617.492901] cpu#17, 2260.998 MHz
[ 3617.493463]   .nr_running                    : 0
[ 3617.494260]   .load                          : 0
[ 3617.495625]   .nr_switches                   : 643417
[ 3617.497127]   .nr_load_updates               : 361602
[ 3617.498094]   .nr_uninterruptible            : 3
[ 3617.498887]   .next_balance                  : 4295.299085
[ 3617.499824]   .curr->pid                     : 0
[ 3617.500469]   .clock                         : 3617492.083870
[ 3617.501547]   .clock_task                    : 3602161.963011
[ 3617.502806]   .cpu_load[0]                   : 0
[ 3617.503779]   .cpu_load[1]                   : 0
[ 3617.504472]   .cpu_load[2]                   : 0
[ 3617.505683]   .cpu_load[3]                   : 0
[ 3617.506594]   .cpu_load[4]                   : 0
[ 3617.507451]   .yld_count                     : 33
[ 3617.507950]   .sched_count                   : 644187
[ 3617.508901]   .sched_goidle                  : 294097
[ 3617.509446]   .avg_idle                      : 1000000
[ 3617.509981]   .max_idle_balance_cost         : 500000
[ 3617.510582]   .ttwu_count                    : 64340
[ 3617.511299]   .ttwu_local                    : 15543
[ 3617.511934]
[ 3617.511934] cfs_rq[17]:/
[ 3617.512447]   .exec_clock                    : 242971.028650
[ 3617.513240]   .MIN_vruntime                  : 0.000001
[ 3617.513861]   .min_vruntime                  : 1124956.123825
[ 3617.514449]   .max_vruntime                  : 0.000001
[ 3617.515631]   .spread                        : 0.000000
[ 3617.515631]   .spread0                       : -6549716.809388
[ 3617.515631]   .nr_spread_over                : 2241
[ 3617.515631]   .nr_running                    : 0
[ 3617.515631]   .load                          : 0
[ 3617.515631]   .runnable_load_avg             : 0
[ 3617.515631]   .blocked_load_avg              : 0
[ 3617.515631]   .tg_load_contrib               : 0
[ 3617.515631]   .tg_runnable_contrib           : 1
[ 3617.515631]   .tg_load_avg                   : 2149
[ 3617.515631]   .tg->runnable_avg              : 2102
[ 3617.515631]   .tg->cfs_bandwidth.timer_active: 0
[ 3617.515631]   .throttled                     : 0
[ 3617.515631]   .throttle_count                : 0
[ 3617.515631]   .avg->runnable_avg_sum         : 92
[ 3617.515631]   .avg->runnable_avg_period      : 47310
[ 3617.515631]
[ 3617.515631] rt_rq[17]:/
[ 3617.515631]   .rt_nr_running                 : 0
[ 3617.515631]   .rt_throttled                  : 0
[ 3617.515631]   .rt_time                       : 0.095218
[ 3617.515631]   .rt_runtime                    : 950.000000
[ 3617.515631]
[ 3617.515631] dl_rq[17]:
[ 3617.515631]   .dl_nr_running                 : 0
[ 3617.515631]
[ 3617.515631] runnable tasks:
[ 3617.515631]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[ 3617.515631] ----------------------------------------------------------------------------------------------------------
[ 3617.515631]      watchdog/17   112       -12.000000       908     0       -12.000000        76.138953         0.000000 17 /
[ 3617.515631]     migration/17   113         0.000000      1483     0         0.000000       250.384075         0.000000 17 /
[ 3617.515631]     ksoftirqd/17   114   1124584.403704      1950   120   1124584.403704      4124.328265   1434674.348613 17 /
[ 3617.515631]    kworker/17:0H   116        36.266146         8   100        36.266146         0.428461     11268.021556 17 /
[ 3617.515631]         kswapd17  3802        48.263989         4   120        48.263989         0.531493        98.559564 17 /
[ 3617.515631]         pencrypt  4200       339.515677         2   100       339.515677         0.149702         1.014521 17 /
[ 3617.515631]         kthrotld  4260      1008.520279         2   100      1008.520279         0.226471         1.045144 17 /
[ 3617.515631]     kworker/17:1  4265   1124944.800874      5950   120   1124944.800874      3237.341953   1518050.344767 17 /
[ 3617.515631]    kworker/u85:0  5344     36713.245582     32815   100     36713.245582     12603.277138    194834.472063 17 /
[ 3617.515631]    fcoethread/17  5701      1010.270898         2   100      1010.270898         0.657644         0.813608 17 /
[ 3617.515631]  bnx2fc_thread/1  5727      1010.316574         2   100      1010.316574         0.235413         0.128451 17 /
[ 3617.515631]  bnx2i_thread/17  5796      1010.370131         2   100      1010.370131         0.213808         0.425555 17 /
[ 3617.515631]    kworker/u66:1  8994   1009568.438539      4314   120   1009568.438539      2714.710350   1186216.655503 17 /
[ 3617.515631]    kworker/u85:1  9004     24695.884004         2   100     24695.884004         0.336944         0.392133 17 /
[ 3617.515631]       runtrin.sh  9063      2691.122266         1   120      2691.122266        17.846920         0.000000 17 /autogroup-1
[ 3617.515631]    kworker/u66:2  9100     31400.219769         3   120     31400.219769         0.229990        10.356848 17 /
[ 3617.515631]     trinity-main  9307     73601.777827     77438   120     73601.777827    150931.367451   1123578.827508 17 /autogroup-1
[ 3617.515631]     kworker/17:2 22182    720153.885469         4   120    720153.885469         0.924863       177.491725 17 /
[ 3617.564441]
[ 3617.565021]
[ 3617.565021] Showing all locks held in the system:
[ 3617.566042] 2 locks held by khungtaskd/3362:
[ 3617.566450] #0: (rcu_read_lock){......}, at: watchdog (include/linux/rcupdate.h:912 kernel/hung_task.c:171 kernel/hung_task.c:238)
[ 3617.567562] #1: (tasklist_lock){.+.+..}, at: debug_show_all_locks (kernel/locking/lockdep.c:4201)
[ 3617.568626] 2 locks held by sh/9598:
[ 3617.568998] #0: (&tty->ldisc_sem){++++++}, at: tty_ldisc_ref_wait (drivers/tty/tty_ldisc.c:268)
[ 3617.569983] #1: (&ldata->atomic_read_lock){+.+...}, at: n_tty_read (drivers/tty/n_tty.c:2188)
[ 3617.571147] Mutex: counter: 0 owner: sh
[ 3617.571571] 1 lock held by trinity-c0/14641:
[ 3617.572105] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.573546] Mutex: counter: -1 owner: trinity-c7
[ 3617.574121] 1 lock held by trinity-c2/14667:
[ 3617.575098] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.576298] Mutex: counter: -1 owner: trinity-c7
[ 3617.576905] 1 lock held by trinity-c6/15683:
[ 3617.577316] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.578482] Mutex: counter: -1 owner: trinity-c7
[ 3617.578929] 1 lock held by trinity-c1/16133:
[ 3617.579335] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.580257] Mutex: counter: -1 owner: trinity-c7
[ 3617.580804] 1 lock held by trinity-c7/16252:
[ 3617.581230] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.582461] Mutex: counter: -1 owner: trinity-c7
[ 3617.583409] 1 lock held by trinity-c5/16328:
[ 3617.584387] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.585957] Mutex: counter: -1 owner: trinity-c7
[ 3617.586389] 1 lock held by trinity-c3/16387:
[ 3617.586836] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.587876] Mutex: counter: -1 owner: trinity-c7
[ 3617.588403] 1 lock held by trinity-c2/16494:
[ 3617.588817] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.589720] Mutex: counter: -1 owner: trinity-c7
[ 3617.590182] 1 lock held by trinity-c1/16509:
[ 3617.590639] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.591588] Mutex: counter: -1 owner: trinity-c7
[ 3617.592646] 1 lock held by trinity-c4/16616:
[ 3617.593431] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.594988] Mutex: counter: -1 owner: trinity-c7
[ 3617.596570] 1 lock held by trinity-c7/16617:
[ 3617.597616] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.599224] Mutex: counter: -1 owner: trinity-c7
[ 3617.599733] 1 lock held by trinity-c5/16667:
[ 3617.600263] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.602233] Mutex: counter: -1 owner: trinity-c7
[ 3617.603556] 1 lock held by trinity-c0/16687:
[ 3617.604190] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.606149] Mutex: counter: -1 owner: trinity-c7
[ 3617.606885] 1 lock held by trinity-c5/16694:
[ 3617.607424] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.608322] Mutex: counter: -1 owner: trinity-c7
[ 3617.608765] 1 lock held by trinity-c3/16717:
[ 3617.609188] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.610267] Mutex: counter: -1 owner: trinity-c7
[ 3617.610806] 1 lock held by trinity-c8/16718:
[ 3617.611216] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.612421] Mutex: counter: -1 owner: trinity-c7
[ 3617.613010] 1 lock held by trinity-c6/16727:
[ 3617.613670] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.614726] Mutex: counter: -1 owner: trinity-c7
[ 3617.615846] 1 lock held by trinity-c1/16745:
[ 3617.616383] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.617625] Mutex: counter: -1 owner: trinity-c7
[ 3617.618358] 1 lock held by trinity-c0/16748:
[ 3617.618770] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.619741] Mutex: counter: -1 owner: trinity-c7
[ 3617.620216] 1 lock held by trinity-c7/16749:
[ 3617.620646] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.621630] Mutex: counter: -1 owner: trinity-c7
[ 3617.622469] 1 lock held by trinity-c2/16750:
[ 3617.622979] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.624148] Mutex: counter: -1 owner: trinity-c7
[ 3617.624688] 1 lock held by trinity-c8/16751:
[ 3617.625482] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.626780] Mutex: counter: -1 owner: trinity-c7
[ 3617.627251] 1 lock held by trinity-c8/16755:
[ 3617.627663] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.628772] Mutex: counter: -1 owner: trinity-c7
[ 3617.629295] 1 lock held by trinity-c3/16764:
[ 3617.629798] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.630715] Mutex: counter: -1 owner: trinity-c7
[ 3617.631295] 1 lock held by trinity-c4/16775:
[ 3617.631917] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.633145] Mutex: counter: -1 owner: trinity-c7
[ 3617.633727] 1 lock held by trinity-c8/16795:
[ 3617.634263] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.635969] Mutex: counter: -1 owner: trinity-c7
[ 3617.636443] 1 lock held by trinity-c4/16801:
[ 3617.636908] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.637917] Mutex: counter: -1 owner: trinity-c7
[ 3617.638388] 1 lock held by trinity-c3/16829:
[ 3617.638802] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.639697] Mutex: counter: -1 owner: trinity-c7
[ 3617.640370] 1 lock held by trinity-c9/16833:
[ 3617.640994] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.641992] Mutex: counter: -1 owner: trinity-c7
[ 3617.642464] 1 lock held by trinity-c1/16844:
[ 3617.642975] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.644597] Mutex: counter: -1 owner: trinity-c7
[ 3617.645791] 1 lock held by trinity-c1/16850:
[ 3617.646277] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.647312] Mutex: counter: -1 owner: trinity-c7
[ 3617.647764] 1 lock held by trinity-c2/16869:
[ 3617.648245] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.649107] Mutex: counter: -1 owner: trinity-c7
[ 3617.649550] 2 locks held by trinity-c7/16935:
[ 3617.649991] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.651037] Mutex: counter: -1 owner: trinity-c7
[ 3617.651601] #1: (cpu_hotplug.lock){++++++}, at: get_online_cpus (kernel/cpu.c:96)
[ 3617.653117] 1 lock held by trinity-c4/16966:
[ 3617.653693] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.655599] Mutex: counter: -1 owner: trinity-c7
[ 3617.656227] 1 lock held by trinity-c2/16986:
[ 3617.656658] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.657791] Mutex: counter: -1 owner: trinity-c7
[ 3617.658270] 1 lock held by trinity-c0/16993:
[ 3617.658673] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.659521] Mutex: counter: -1 owner: trinity-c7
[ 3617.660038] 1 lock held by trinity-c4/17019:
[ 3617.660507] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.661549] Mutex: counter: -1 owner: trinity-c7
[ 3617.662135] 1 lock held by trinity-c0/17063:
[ 3617.662572] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.663703] Mutex: counter: -1 owner: trinity-c7
[ 3617.664349] 1 lock held by trinity-c7/17084:
[ 3617.664927] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.666427] Mutex: counter: -1 owner: trinity-c7
[ 3617.666964] 1 lock held by trinity-c3/17096:
[ 3617.667383] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.668351] Mutex: counter: -1 owner: trinity-c7
[ 3617.668782] 1 lock held by trinity-c5/17097:
[ 3617.669187] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.670233] Mutex: counter: -1 owner: trinity-c7
[ 3617.670680] 1 lock held by trinity-c8/17105:
[ 3617.671129] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.672232] Mutex: counter: -1 owner: trinity-c7
[ 3617.672842] 1 lock held by trinity-c6/17117:
[ 3617.673563] #0: (lock#4){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
[ 3617.674671] Mutex: counter: -1 owner: trinity-c7


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
