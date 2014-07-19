Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4B76B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 19:26:57 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so7021541pde.32
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 16:26:57 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id ro10si2017749pbc.207.2014.07.19.16.26.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 16:26:56 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so6907326pdj.22
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 16:26:55 -0700 (PDT)
Date: Sat, 19 Jul 2014 16:25:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: swap: hang in lru_add_drain_all
In-Reply-To: <53C95BBA.90608@oracle.com>
Message-ID: <alpine.LSU.2.11.1407191552001.24073@eggly.anvils>
References: <53C95BBA.90608@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Peter Zijlstra <peterz@infradead.org>, cmetcalf@tilera.com, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 18 Jul 2014, Sasha Levin wrote:

> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following spew:
> 
> [  729.682257] INFO: task trinity-c158:13508 blocked for more than 120 seconds.
> [  729.683191]       Not tainted 3.16.0-rc5-next-20140718-sasha-00052-g4d34feb #902
> [  729.683843] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  729.684633] trinity-c158    D ffff880d32169000 12520 13508   8729 0x00000000
> [  729.685323]  ffff880de6d3fe38 0000000000000002 0000000000000006 ffff880c6c33b000
> [  729.686039]  000000785eb36cd1 ffff880de6d3c010 ffff880de6d3c000 ffff880e2b270000
> [  729.686761]  ffff880c6c33b000 0000000000000000 ffffffffb070b908 0000000026e426e2
> [  729.687483] Call Trace:
> [  729.687736] schedule_preempt_disabled (kernel/sched/core.c:2874)
> [  729.688544] mutex_lock_nested (kernel/locking/mutex.c:532 kernel/locking/mutex.c:584)
> [  729.689127] ? lru_add_drain_all (mm/swap.c:867)
> [  729.689666] ? lru_add_drain_all (mm/swap.c:867)
> [  729.690334] lru_add_drain_all (mm/swap.c:867)
> [  729.690946] SyS_mlockall (./arch/x86/include/asm/current.h:14 include/linux/sched.h:2978 mm/mlock.c:813 mm/mlock.c:798)
> [  729.691437] tracesys (arch/x86/kernel/entry_64.S:541)
> [  729.691883] 1 lock held by trinity-c158/13508:
> [  729.692333] #0: (lock#3){+.+...}, at: lru_add_drain_all (mm/swap.c:867)
> 
> There are quite a few tasks with the same stacktrace. Since the lock we're blocking
> on is static local to the function it's easy to figure out which task actually has it:
> 
> [  739.587839] trinity-c135    D ffff880e1318c000 13096 21051   8729 0x00000000
> [  739.589080]  ffff880bf659fcc0 0000000000000002 ffff880c74223cf0 ffff880c74223000
> [  739.590544]  000000781c3378ed ffff880bf659c010 ffff880bf659c000 ffff880e2b153000
> [  739.591815]  ffff880c74223000 0000000000000000 7fffffffffffffff ffff880bf659fe80
> [  739.593165] Call Trace:
> [  739.593588] schedule (kernel/sched/core.c:2847)
> [  739.594396] schedule_timeout (kernel/time/timer.c:1476)
> [  739.595354] ? mark_lock (kernel/locking/lockdep.c:2894)
> [  739.596229] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [  739.597297] ? get_parent_ip (kernel/sched/core.c:2561)
> [  739.598185] wait_for_completion (include/linux/spinlock.h:328 kernel/sched/completion.c:76 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
> [  739.599191] ? wake_up_state (kernel/sched/core.c:2942)
> [  739.600246] flush_work (kernel/workqueue.c:503 kernel/workqueue.c:2762)
> [  739.601171] ? flush_work (kernel/workqueue.c:2733 kernel/workqueue.c:2760)
> [  739.602084] ? destroy_worker (kernel/workqueue.c:2348)
> [  739.603035] ? wait_for_completion (kernel/sched/completion.c:64 kernel/sched/completion.c:93 kernel/sched/completion.c:101 kernel/sched/completion.c:122)
> [  739.604043] lru_add_drain_all (include/linux/cpumask.h:180 mm/swap.c:883)
> [  739.605076] SyS_mlockall (./arch/x86/include/asm/current.h:14 include/linux/sched.h:2978 mm/mlock.c:813 mm/mlock.c:798)
> [  739.605943] tracesys (arch/x86/kernel/entry_64.S:541)
> 
> Now, you'd expect to see lru_add_drain_per_cpu in one of the tasks, but
> that's not the case.
> 
> Full log attched.

I'm happy to find no "shmem" and no "fallocate" in that log: I agree
that this hang is something different, and I'll sound the all-clear
on that one, once I've made a suggestion on this one.

I know next to nothing about scheduler matters, so the less I say, the
less I'll make a fool of myself.  But I believe this problem may be
self-inflicted by trinity, that it may be using its privilege to abuse
RT priority in a way to hang the system here.

Appended below are relevant cpu#13 lines from your log.txt.  You took
10 watchdog dumps across 20 seconds: here's the first trace and stats,
eight intervening "rt_time" lines, and the last trace and stats.

Bear in mind that I know nothing about RT, and "rt_time", but it seems
fair to show it cycling around in between the first and last.  And it
seems interesting that "nr_switches" is 49357 in the first and 49357
in the last, and the three cpu#13 runnable kworkers show the same
"switches" in the first and the last stats.

I've not checked whether "switches" means what I'd expect it to mean,
but I'm guessing trinity-c13 is looping at RT priority on cpu#13,
and locking out everything else.

In particular, locking out the kworker which would just love to get
in and drain cpu#13's lru_add pagevec, then wake up trinity-c135 to
say the drain is completed, whereupon trinity-c135 can drop the mutex,
to let trinity-c158 and many others in to do... much the same again.

Hugh

[  739.534086] trinity-c13     R  running task    13312 20846   8729 0x00080000
[  739.534875]  000000000000024e ffffffffa9ffc7f7 ffff880ba796bd28 ffffffff00000001
[  739.535696]  ffff880ba796b000 ffff880c00000001 0000000000000000 0000000000000000
[  739.536519]  0000000000000002 0000000000000000 ffffffffa9248135 ffff880c2bd97f28
[  739.537336] Call Trace:
[  739.537613] ? lock_release (kernel/locking/lockdep.c:3475 kernel/locking/lockdep.c:3498 kernel/locking/lockdep.c:3619)
[  739.538202] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[  739.538859] ? _raw_spin_unlock_irqrestore (include/linux/spinlock_api_smp.h:159 kernel/locking/spinlock.c:191)
[  739.539549] ? lock_release (kernel/locking/lockdep.c:3475 kernel/locking/lockdep.c:3498 kernel/locking/lockdep.c:3619)
[  739.540339] ? get_vtime_delta (kernel/sched/cputime.c:649 (discriminator 8))
[  739.541110] ? vtime_account_user (kernel/sched/cputime.c:684)
[  739.541737] ? context_tracking_user_exit (include/linux/vtime.h:89 include/linux/jump_label.h:115 include/trace/events/context_tracking.h:47 kernel/context_tracking.c:180)
[  739.542435] ? vtime_user_enter (kernel/sched/cputime.c:693)
[  739.543044] ? SyS_wait4 (kernel/exit.c:1619 kernel/exit.c:1587)
[  739.543586] ? syscall_trace_leave (arch/x86/kernel/ptrace.c:1531)
[  739.544240] ? tracesys (arch/x86/kernel/entry_64.S:530)
[  739.544782] ? SyS_kill (kernel/signal.c:2890)

[  740.663871] cpu#13, 2260.998 MHz
[  740.664431]   .nr_running                    : 3
[  740.665197]   .load                          : 1024
[  740.666005]   .nr_switches                   : 49357
[  740.666806]   .nr_load_updates               : 48621
[  740.667613]   .nr_uninterruptible            : -55
[  740.668653]   .next_balance                  : 4295.011457
[  740.669538]   .curr->pid                     : 20846
[  740.670452]   .clock                         : 740670.058306
[  740.671471]   .cpu_load[0]                   : 62
[  740.673656]   .cpu_load[1]                   : 62
[  740.674147]   .cpu_load[2]                   : 62
[  740.674636]   .cpu_load[3]                   : 62
[  740.675131]   .cpu_load[4]                   : 62
[  740.675625]   .yld_count                     : 125
[  740.676138]   .sched_count                   : 51104
[  740.676650]   .sched_goidle                  : 9784
[  740.677158]   .avg_idle                      : 1300456
[  740.677695]   .max_idle_balance_cost         : 2394144
[  740.678226]   .ttwu_count                    : 14256
[  740.678743]   .ttwu_local                    : 2997
[  740.679257] 
[  740.679257] cfs_rq[13]:/
[  740.679741]   .exec_clock                    : 170539.871709
[  740.680387]   .MIN_vruntime                  : 956608.992999
[  740.680387]   .min_vruntime                  : 956620.348251
[  740.680387]   .max_vruntime                  : 956608.992999
[  740.680387]   .spread                        : 0.000000
[  740.680387]   .spread0                       : -393069.336040
[  740.680387]   .nr_spread_over                : 1015
[  740.680387]   .nr_running                    : 1
[  740.680387]   .load                          : 1024
[  740.680387]   .runnable_load_avg             : 62
[  740.680387]   .blocked_load_avg              : 0
[  740.680387]   .tg_load_contrib               : 62
[  740.680387]   .tg_runnable_contrib           : 1020
[  740.680387]   .tg_load_avg                   : 72
[  740.680387]   .tg->runnable_avg              : 2046
[  740.680387]   .tg->cfs_bandwidth.timer_active: 0
[  740.680387]   .throttled                     : 0
[  740.680387]   .throttle_count                : 0
[  740.680387]   .avg->runnable_avg_sum         : 48432
[  740.680387]   .avg->runnable_avg_period      : 48432
[  740.680387] 
[  740.680387] rt_rq[13]:/
[  740.680387]   .rt_nr_running                 : 2
[  740.680387]   .rt_throttled                  : 0
[  740.680387]   .rt_time                       : 696.812126
[  740.680387]   .rt_runtime                    : 1000.000000
[  740.680387] 
[  740.680387] runnable tasks:
[  740.680387]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  740.680387] ----------------------------------------------------------------------------------------------------------
[  740.680387]          rcuos/3    53    520765.589523         5   120    520765.589523         0.808313    404091.464092 0 /
[  740.680387]      watchdog/13   201       -11.682136        22     0       -11.682136         6.875011         0.000000 0 /
[  740.680387]     migration/13   202         0.000000        82     0         0.000000        47.887990         0.000000 0 /
[  740.680387]          rcuc/13   203       -12.000000         4    98       -12.000000         0.265959         0.000000 0 /
[  740.680387]     ksoftirqd/13   204    947403.072378        59   120    947403.072378        16.475254    505123.439436 0 /
[  740.680387]     kworker/13:0   205        29.113239        30   120        29.113239         4.337088      9646.893156 0 /
[  740.680387]    kworker/13:0H   206       378.140827         8   100       378.140827         0.489706     14056.057142 0 /
[  740.680387]     kworker/13:1  2406    956608.992999      4136   120    956608.992999      2540.330017    498215.463746 0 /
[  740.680387]    fcoethread/13  5843      6315.295777         2   100      6315.295777         0.320255         0.342003 0 /
[  740.680387]  bnx2fc_thread/1  5888      6315.423773         2   100      6315.423773         0.850324         0.574025 0 /
[  740.680387]  bnx2i_thread/13  5978      6340.922884         3   100      6340.922884         0.546603         0.496749 0 /
[  740.680387]     trinity-c182  9328       301.495168      1054   120       301.495168     10553.961542     76826.313305 0 /autogroup-133
[  740.680387]      trinity-c94  9640       284.370532       531   120       284.370532      6160.616065     55406.177681 0 /autogroup-90
[  740.680387]     trinity-c161 10919        63.826999       494   120        63.826999      3866.730276     55130.167304 0 /autogroup-235
[  740.680387] R    trinity-c13 20846         0.000000        52    97         0.000000    225300.270687         0.000000 0 /
[  740.680387]      trinity-c13 21073         0.000000         0    97         0.000000         0.000000         0.000000 0 /

then over the next 20 seconds, cpu#13 shows:
[  752.910531]   .rt_time                       : 919.040543
[  759.959078]   .rt_time                       : 956.934204
[  760.167586]   .rt_time                       : 169.606765
[  760.375072]   .rt_time                       : 379.091881
[  760.582864]   .rt_time                       : 588.926167
[  760.790587]   .rt_time                       : 798.310732
[  760.998034]   .rt_time                       : 998.004809
[  761.201971]   .rt_time                       : 209.376323
and ends up with this trace and stats:

[  761.390639] trinity-c13     R  running task    13312 20846   8729 0x00080000
[  761.390649]  ffff880ba796b070 ffffffffa9ffc7f7 ffff880c2bd97e40 ffffffffa92119f8
[  761.390658]  0000000000000082 ffffffffa924fa35 0000000000000022 0000000000000000
[  761.390668]  ffff880dd9d80020 0000000000000282 ffffffffadea411c ffff880c2bd97e48
[  761.390670] Call Trace:
[  761.390679] ? rcu_read_lock_held (kernel/rcu/update.c:165)
[  761.390686] ? sched_clock_cpu (kernel/sched/clock.c:311)
[  761.390694] ? rcu_read_lock_held (kernel/rcu/update.c:165)
[  761.390703] ? _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
[  761.390710] ? rcu_eqs_enter (kernel/rcu/tree.c:556)
[  761.390719] ? context_tracking_user_exit (include/linux/vtime.h:89 include/linux/jump_label.h:115 include/trace/events/context_tracking.h:47 kernel/context_tracking.c:180)
[  761.390727] ? SyS_wait4 (kernel/exit.c:1619 kernel/exit.c:1587)
[  761.390735] ? syscall_trace_leave (arch/x86/kernel/ptrace.c:1531)
[  761.390742] ? int_with_check (arch/x86/kernel/entry_64.S:555)

[  761.412307] cpu#13, 2260.998 MHz
[  761.412311]   .nr_running                    : 3
[  761.412314]   .load                          : 1024
[  761.412317]   .nr_switches                   : 49357
[  761.412320]   .nr_load_updates               : 50696
[  761.412323]   .nr_uninterruptible            : -55
[  761.412326]   .next_balance                  : 4295.013537
[  761.412329]   .curr->pid                     : 20846
[  761.412333]   .clock                         : 761410.040099
[  761.412335]   .cpu_load[0]                   : 62
[  761.412338]   .cpu_load[1]                   : 62
[  761.412341]   .cpu_load[2]                   : 62
[  761.412344]   .cpu_load[3]                   : 62
[  761.412347]   .cpu_load[4]                   : 62
[  761.412349]   .yld_count                     : 125
[  761.412352]   .sched_count                   : 51104
[  761.412355]   .sched_goidle                  : 9784
[  761.412358]   .avg_idle                      : 1300456
[  761.412361]   .max_idle_balance_cost         : 2153150
[  761.412364]   .ttwu_count                    : 14256
[  761.412366]   .ttwu_local                    : 2997
[  761.412376] 
[  761.412376] cfs_rq[13]:/
[  761.412379]   .exec_clock                    : 170539.871709
[  761.412387]   .MIN_vruntime                  : 956608.992999
[  761.412390]   .min_vruntime                  : 956620.348251
[  761.412393]   .max_vruntime                  : 956608.992999
[  761.412396]   .spread                        : 0.000000
[  761.412399]   .spread0                       : -395611.774772
[  761.412402]   .nr_spread_over                : 1015
[  761.412404]   .nr_running                    : 1
[  761.412407]   .load                          : 1024
[  761.412409]   .runnable_load_avg             : 62
[  761.412412]   .blocked_load_avg              : 0
[  761.412414]   .tg_load_contrib               : 62
[  761.412417]   .tg_runnable_contrib           : 1020
[  761.412419]   .tg_load_avg                   : 597
[  761.412422]   .tg->runnable_avg              : 2132
[  761.412424]   .tg->cfs_bandwidth.timer_active: 0
[  761.412427]   .throttled                     : 0
[  761.412429]   .throttle_count                : 0
[  761.412432]   .avg->runnable_avg_sum         : 48386
[  761.412434]   .avg->runnable_avg_period      : 48386
[  761.412530] 
[  761.412530] rt_rq[13]:/
[  761.412532]   .rt_nr_running                 : 2
[  761.412535]   .rt_throttled                  : 0
[  761.412538]   .rt_time                       : 419.008925
[  761.412541]   .rt_runtime                    : 1000.000000
[  761.412547] 
[  761.412547] runnable tasks:
[  761.412547]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  761.412547] ----------------------------------------------------------------------------------------------------------
[  761.412607]          rcuos/3    53    520765.589523         5   120    520765.589523         0.808313    404091.464092 0 /
[  761.412736]      watchdog/13   201       -11.682136        22     0       -11.682136         6.875011         0.000000 0 /
[  761.412751]     migration/13   202         0.000000        82     0         0.000000        47.887990         0.000000 0 /
[  761.412767]          rcuc/13   203       -12.000000         4    98       -12.000000         0.265959         0.000000 0 /
[  761.412784]     ksoftirqd/13   204    947403.072378        59   120    947403.072378        16.475254    505123.439436 0 /
[  761.412800]     kworker/13:0   205        29.113239        30   120        29.113239         4.337088      9646.893156 0 /
[  761.412816]    kworker/13:0H   206       378.140827         8   100       378.140827         0.489706     14056.057142 0 /
[  761.412953]     kworker/13:1  2406    956608.992999      4136   120    956608.992999      2540.330017    498215.463746 0 /
[  761.413046]    fcoethread/13  5843      6315.295777         2   100      6315.295777         0.320255         0.342003 0 /
[  761.413095]  bnx2fc_thread/1  5888      6315.423773         2   100      6315.423773         0.850324         0.574025 0 /
[  761.413141]  bnx2i_thread/13  5978      6340.922884         3   100      6340.922884         0.546603         0.496749 0 /
[  761.413298]     trinity-c182  9328       301.495168      1054   120       301.495168     10553.961542     76826.313305 0 /autogroup-133
[  761.413316]      trinity-c94  9640       284.370532       531   120       284.370532      6160.616065     55406.177681 0 /autogroup-90
[  761.413343]     trinity-c161 10919        63.826999       494   120        63.826999      3866.730276     55130.167304 0 /autogroup-235
[  761.413538] R    trinity-c13 20846         0.000000        52    97         0.000000    245950.924182         0.000000 0 /
[  761.413560]      trinity-c13 21073         0.000000         0    97         0.000000         0.000000         0.000000 0 /

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
