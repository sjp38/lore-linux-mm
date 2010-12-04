Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4EC1F6B00A0
	for <linux-mm@kvack.org>; Sat,  4 Dec 2010 02:30:57 -0500 (EST)
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx3-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id oB47UtDm007496
	for <linux-mm@kvack.org>; Sat, 4 Dec 2010 02:30:55 -0500
Date: Sat, 4 Dec 2010 02:30:55 -0500 (EST)
From: caiqian@redhat.com
Message-ID: <1527296193.8541291447855619.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <254859941.6601291447527808.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: continuous oom caused system deadlock
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Running this LTP test a few times for mmotm tree caused system hung hard,
http://people.redhat.com/qcai/oom01.c

I tried to bisect but only found it was also present in the tree a few months back as well.

SysRq-W output indicated that kswapd0 might stuck,
[  373.943002] kswapd0       R  running task        0    34      2 0x00000000
[  373.943002]  ffff88022abdbc80 ffffffff8146e4ce ffff88022abdbcb0 ffffffff81232698
[  373.943002]  0000000000000001 ffffffff81a248f0 0000000000000000 0000000000000000
[  373.943002]  ffff88022abdbcc0 ffffffff8112d59d ffff88022abdbcd0 ffffffff8146e4ce
[  373.943002] Call Trace:
[  373.943002]  [<ffffffff8146e4ce>] ? _raw_spin_lock+0xe/0x10
[  373.943002]  [<ffffffff81232698>] ? __percpu_counter_sum+0x4d/0x63
[  373.943002]  [<ffffffff8112d59d>] ? get_nr_inodes_unused+0x15/0x23
[  373.943002]  [<ffffffff8146e4ce>] ? _raw_spin_lock+0xe/0x10
[  373.943002]  [<ffffffff8146ea0e>] ? common_interrupt+0xe/0x13
[  373.943002]  [<ffffffff810e2add>] ? balance_pgdat+0x29b/0x417
[  373.943002]  [<ffffffff810e2e83>] ? kswapd+0x22a/0x240
[  373.943002]  [<ffffffff8106af63>] ? autoremove_wake_function+0x0/0x39
[  373.943002]  [<ffffffff810e2c59>] ? kswapd+0x0/0x240
[  373.943002]  [<ffffffff8106aaae>] ? kthread+0x82/0x8a
[  373.943002]  [<ffffffff8100bae4>] ? kernel_thread_helper+0x4/0x10
[  373.943002]  [<ffffffff8106aa2c>] ? kthread+0x0/0x8a
[  373.943002]  [<ffffffff8100bae0>] ? kernel_thread_helper+0x0/0x10

full SysRq-W output:
[  373.943002] Sched Debug Version: v0.09, 2.6.37-rc3+ #1
[  373.943002] now at 381511.273166 msecs
[  373.943002]   .jiffies                                 : 4295041238
[  373.943002]   .sysctl_sched_latency                    : 18.000000
[  373.943002]   .sysctl_sched_min_granularity            : 2.250000
[  373.943002]   .sysctl_sched_wakeup_granularity         : 3.000000
[  373.943002]   .sysctl_sched_child_runs_first           : 0
[  373.943002]   .sysctl_sched_features                   : 31855
[  373.943002]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[  373.943002] 
[  373.943002] cpu#0, 2826.236 MHz
[  373.943002]   .nr_running                    : 1
[  373.943002]   .load                          : 1024
[  373.943002]   .nr_switches                   : 69769
[  373.943002]   .nr_load_updates               : 115459
[  373.943002]   .nr_uninterruptible            : 0
[  373.943002]   .next_balance                  : 4295.041289
[  373.943002]   .curr->pid                     : 34
[  373.943002]   .clock                         : 373942.002254
[  373.943002]   .cpu_load[0]                   : 1024
[  373.943002]   .cpu_load[1]                   : 1024
[  373.943002]   .cpu_load[2]                   : 1024
[  373.943002]   .cpu_load[3]                   : 1024
[  373.943002]   .cpu_load[4]                   : 1024
[  373.943002]   .yld_count                     : 100
[  373.943002]   .sched_switch                  : 0
[  373.943002]   .sched_count                   : 82123
[  373.943002]   .sched_goidle                  : 26687
[  373.943002]   .avg_idle                      : 1000000
[  373.943002]   .ttwu_count                    : 30804
[  373.943002]   .ttwu_local                    : 8525
[  373.943002]   .bkl_count                     : 0
[  373.943002] 
[  373.943002] cfs_rq[0]:/
[  373.943002]   .exec_clock                    : 107322.196661
[  373.943002]   .MIN_vruntime                  : 0.000001
[  373.943002]   .min_vruntime                  : 55990.920524
[  373.943002]   .max_vruntime                  : 0.000001
[  373.943002]   .spread                        : 0.000000
[  373.943002]   .spread0                       : 0.000000
[  373.943002]   .nr_running                    : 1
[  373.943002]   .load                          : 1024
[  373.943002]   .nr_spread_over                : 9
[  373.943002]   .shares                        : 0
[  373.943002] 
[  373.943002] rt_rq[0]:/
[  373.943002]   .rt_nr_running                 : 0
[  373.943002]   .rt_throttled                  : 0
[  373.943002]   .rt_time                       : 0.000000
[  373.943002]   .rt_runtime                    : 1000.000000
[  373.943002] 
[  373.943002] runnable tasks:
[  373.943002]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  373.943002] ----------------------------------------------------------------------------------------------------------
[  373.943002] R        kswapd0    34     55990.920524     43568   120     55990.920524     38575.283576    287944.752314 /
[  373.943002] 
[  373.943002] cpu#1, 2826.236 MHz
[  373.943002]   .nr_running                    : 2
[  373.943002]   .load                          : 2048
[  373.943002]   .nr_switches                   : 80939
[  373.943002]   .nr_load_updates               : 141862
[  373.943002]   .nr_uninterruptible            : 1
[  373.943002]   .next_balance                  : 4295.041423
[  373.943002]   .curr->pid                     : 925
[  373.943002]   .clock                         : 382530.001465
[  373.943002]   .cpu_load[0]                   : 2048
[  373.943002]   .cpu_load[1]                   : 1920
[  373.943002]   .cpu_load[2]                   : 1806
[  373.943002]   .cpu_load[3]                   : 1743
[  373.943002]   .cpu_load[4]                   : 1716
[  373.943002]   .yld_count                     : 127
[  373.943002]   .sched_switch                  : 0
[  373.943002]   .sched_count                   : 87429
[  373.943002]   .sched_goidle                  : 29877
[  373.943002]   .avg_idle                      : 1000000
[  373.943002]   .ttwu_count                    : 33588
[  373.943002]   .ttwu_local                    : 9295
[  373.943002]   .bkl_count                     : 0
[  373.943002] 
[  373.943002] cfs_rq[1]:/
[  373.943002]   .exec_clock                    : 132931.075561
[  373.943002]   .MIN_vruntime                  : 66573.481283
[  373.943002]   .min_vruntime                  : 66573.481283
[  373.943002]   .max_vruntime                  : 66573.481283
[  373.943002]   .spread                        : 0.000000
[  373.943002]   .spread0                       : 10582.560759
[  373.943002]   .nr_running                    : 2
[  373.943002]   .load                          : 2048
[  373.943002]   .nr_spread_over                : 10
[  373.943002]   .shares                        : 0
[  373.943002] 
[  373.943002] rt_rq[1]:/
[  373.943002]   .rt_nr_running                 : 0
[  373.943002]   .rt_throttled                  : 0
[  373.943002]   .rt_time                       : 0.000000
[  373.943002]   .rt_runtime                    : 850.000000
[  373.943002] 
[  373.943002] runnable tasks:
[  373.943002]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  373.943002] ----------------------------------------------------------------------------------------------------------
[  373.943002] R        rpcbind   925     75167.155023      3118   120     75167.155023     33682.358086    277604.838691 /
[  373.943002]  console-kit-dae  1328     66573.481283       716   120     66573.481283      2306.020280    277814.482610 /
[  373.943002] 
[  373.943002] cpu#2, 2826.236 MHz
[  373.943002]   .nr_running                    : 1
[  373.943002]   .load                          : 1024
[  373.943002]   .nr_switches                   : 25657
[  373.943002]   .nr_load_updates               : 133265
[  373.943002]   .nr_uninterruptible            : 6
[  373.943002]   .next_balance                  : 4295.041381
[  373.943002]   .curr->pid                     : 1473
[  373.943002]   .clock                         : 382530.001959
[  373.943002]   .cpu_load[0]                   : 1024
[  373.943002]   .cpu_load[1]                   : 732
[  373.943002]   .cpu_load[2]                   : 703
[  373.943002]   .cpu_load[3]                   : 726
[  373.943002]   .cpu_load[4]                   : 777
[  373.943002]   .yld_count                     : 143
[  373.943002]   .sched_switch                  : 0
[  373.943002]   .sched_count                   : 33466
[  373.943002]   .sched_goidle                  : 5814
[  373.943002]   .avg_idle                      : 1000000
[  373.943002]   .ttwu_count                    : 9228
[  373.943002]   .ttwu_local                    : 6942
[  373.943002]   .bkl_count                     : 0
[  373.943002] 
[  373.943002] cfs_rq[2]:/
[  373.943002]   .exec_clock                    : 125235.081389
[  373.943002]   .MIN_vruntime                  : 0.000001
[  373.943002]   .min_vruntime                  : 64653.378538
[  373.943002]   .max_vruntime                  : 0.000001
[  373.943002]   .spread                        : 0.000000
[  373.943002]   .spread0                       : 8662.458014
[  373.943002]   .nr_running                    : 1
[  373.943002]   .load                          : 1024
[  373.943002]   .nr_spread_over                : 28
[  373.943002]   .shares                        : 0
[  373.943002] 
[  373.943002] rt_rq[2]:/
[  373.943002]   .rt_nr_running                 : 0
[  373.943002]   .rt_throttled                  : 0
[  373.943002]   .rt_time                       : 0.000000
[  373.943002]   .rt_runtime                    : 1000.000000
[  373.943002] 
[  373.943002] runnable tasks:
[  373.943002]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  373.943002] ----------------------------------------------------------------------------------------------------------
[  373.943002] R          oom01  1473     64653.378538      3405   120     64653.378538     44153.912865      3897.833338 /
[  373.943002] 
[  373.943002] cpu#3, 2826.236 MHz
[  373.943002]   .nr_running                    : 2
[  373.943002]   .load                          : 2048
[  373.943002]   .nr_switches                   : 27316
[  373.943002]   .nr_load_updates               : 137905
[  373.943002]   .nr_uninterruptible            : 5
[  373.943002]   .next_balance                  : 4295.041253
[  373.943002]   .curr->pid                     : 1336
[  373.943002]   .clock                         : 382530.002311
[  373.943002]   .cpu_load[0]                   : 2048
[  373.943002]   .cpu_load[1]                   : 1980
[  373.943002]   .cpu_load[2]                   : 1820
[  373.943002]   .cpu_load[3]                   : 1754
[  373.943002]   .cpu_load[4]                   : 1790
[  373.943002]   .yld_count                     : 9
[  373.943002]   .sched_switch                  : 0
[  373.943002]   .sched_count                   : 36031
[  373.943002]   .sched_goidle                  : 6309
[  373.943002]   .avg_idle                      : 1000000
[  373.943002]   .ttwu_count                    : 9803
[  373.943002]   .ttwu_local                    : 7501
[  373.943002]   .bkl_count                     : 0
[  373.943002] 
[  373.943002] cfs_rq[3]:/
[  373.943002]   .exec_clock                    : 131690.185382
[  373.943002]   .MIN_vruntime                  : 72546.296158
[  373.943002]   .min_vruntime                  : 72546.296158
[  373.943002]   .max_vruntime                  : 72546.296158
[  373.943002]   .spread                        : 0.000000
[  373.943002]   .spread0                       : 16555.375634
[  373.943002]   .nr_running                    : 2
[  373.943002]   .load                          : 2048
[  373.943002]   .nr_spread_over                : 4
[  373.943002]   .shares                        : 0
[  373.943002] 
[  373.943002] rt_rq[3]:/
[  373.943002]   .rt_nr_running                 : 0
[  373.943002]   .rt_throttled                  : 0
[  373.943002]   .rt_time                       : 0.000000
[  373.943002]   .rt_runtime                    : 950.000000
[  373.943002] 
[  373.943002] runnable tasks:
[  373.943002]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  373.943002] ----------------------------------------------------------------------------------------------------------
[  373.943002]       irqbalance   908     72546.296158      5882   120     72546.296158     30782.122083    264942.728048 /
[  373.943002] R           bash  1336     81138.830657       744   120     81138.830657     10827.322162    278614.352123 /
[  373.943002] 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
