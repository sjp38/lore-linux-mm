Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AFE628D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 10:16:40 -0500 (EST)
Date: Tue, 15 Feb 2011 16:16:33 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [2.6.32 ubuntu] I/O hang at start_this_handle
Message-ID: <20110215151633.GG17313@quack.suse.cz>
References: <201102080526.p185Q0mL034909@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201102080526.p185Q0mL034909@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue 08-02-11 14:26:00, Tetsuo Handa wrote:
> I got below hangup. Is this known problem?
> 
> Installing: grub-0.97-173.6 [91%]
> 
> # dmesg
> [14280.252030] INFO: task sh:17496 blocked for more than 120 seconds.
> [14280.252228] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [14280.252447] sh            D 00000000     0 17496  17470 0x00000000
> [14280.252455]  f6f8fcf8 00200082 c02084a3 00000000 00000000 c088e4c0 f6d39c24 c088e4c0
> [14280.252468]  15e72f78 00000ccd c088e4c0 c088e4c0 f6d39c24 c088e4c0 c088e4c0 f40c2a80
> [14280.252480]  15e50702 00000ccd f6d39980 f4d2b63c f4d2b600 00000000 f6f8fd54 c02c7ead
> [14280.252492] Call Trace:
> [14280.252503]  [<c02084a3>] ? __slab_alloc+0x163/0x220
> [14280.252512]  [<c02c7ead>] start_this_handle+0x22d/0x390
> [14280.252519]  [<c016ff90>] ? autoremove_wake_function+0x0/0x50
> [14280.252525]  [<c02c8188>] journal_start+0x98/0xd0
> [14280.252532]  [<c027b06e>] ext3_journal_start_sb+0x2e/0x50
> [14280.252538]  [<c0272f02>] ext3_dirty_inode+0x32/0x80
> [14280.252545]  [<c0231c71>] __mark_inode_dirty+0x31/0x180
> [14280.252552]  [<c022900a>] inode_setattr+0xaa/0x170
> [14280.252557]  [<c0273091>] ext3_setattr+0x141/0x1f0
> [14280.252563]  [<c0229213>] notify_change+0x143/0x340
> [14280.252571]  [<c02122d2>] do_truncate+0x62/0x90
> [14280.252578]  [<c03018ea>] ? security_path_truncate+0x3a/0x50
> [14280.252584]  [<c021c710>] may_open+0x1d0/0x200
> [14280.252591]  [<c021f9fc>] do_filp_open+0xfc/0x990
> [14280.252597]  [<c01efb74>] ? do_wp_page+0x104/0x910
> [14280.252605]  [<c02111d5>] do_sys_open+0x55/0x160
> [14280.252611]  [<c021134e>] sys_open+0x2e/0x40
> [14280.252617]  [<c01096c3>] sysenter_do_call+0x12/0x28
  Ext3 looks innocent here. That is a standard call path for open(..,
O_TRUNC). But apparently something broke in SLUB allocator. Adding proper
list to CC...

> [14400.252032] INFO: task sh:17496 blocked for more than 120 seconds.
> [14400.252201] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [14400.252429] sh            D 00000000     0 17496  17470 0x00000000
> [14400.252437]  f6f8fcf8 00200082 c02084a3 00000000 00000000 c088e4c0 f6d39c24 c088e4c0
> [14400.252450]  15e72f78 00000ccd c088e4c0 c088e4c0 f6d39c24 c088e4c0 c088e4c0 f40c2a80
> [14400.252461]  15e50702 00000ccd f6d39980 f4d2b63c f4d2b600 00000000 f6f8fd54 c02c7ead
> [14400.252473] Call Trace:
> [14400.252484]  [<c02084a3>] ? __slab_alloc+0x163/0x220
> [14400.252492]  [<c02c7ead>] start_this_handle+0x22d/0x390
> [14400.252500]  [<c016ff90>] ? autoremove_wake_function+0x0/0x50
> [14400.252506]  [<c02c8188>] journal_start+0x98/0xd0
> [14400.252512]  [<c027b06e>] ext3_journal_start_sb+0x2e/0x50
> [14400.252518]  [<c0272f02>] ext3_dirty_inode+0x32/0x80
> [14400.252525]  [<c0231c71>] __mark_inode_dirty+0x31/0x180
> [14400.252532]  [<c022900a>] inode_setattr+0xaa/0x170
> [14400.252537]  [<c0273091>] ext3_setattr+0x141/0x1f0
> [14400.252543]  [<c0229213>] notify_change+0x143/0x340
> [14400.252550]  [<c02122d2>] do_truncate+0x62/0x90
> [14400.252557]  [<c03018ea>] ? security_path_truncate+0x3a/0x50
> [14400.252564]  [<c021c710>] may_open+0x1d0/0x200
> [14400.252570]  [<c021f9fc>] do_filp_open+0xfc/0x990
> [14400.252577]  [<c01efb74>] ? do_wp_page+0x104/0x910
> [14400.252584]  [<c02111d5>] do_sys_open+0x55/0x160
> [14400.252590]  [<c021134e>] sys_open+0x2e/0x40
> [14400.252596]  [<c01096c3>] sysenter_do_call+0x12/0x28
> 
> CPU usage is almost 0%. Below is some sysrq info.
> 
> [15460.045190] SysRq : Show Blocked State
> [15460.053012]   task                PC stack   pid father
> [15460.053012] sh            D 00000000     0 17496  17470 0x00000000
> [15460.053012]  f6f8fcf8 00200082 c02084a3 00000000 00000000 c088e4c0 f6d39c24 c088e4c0
> [15460.053012]  15e72f78 00000ccd c088e4c0 c088e4c0 f6d39c24 c088e4c0 c088e4c0 f40c2a80
> [15460.053012]  15e50702 00000ccd f6d39980 f4d2b63c f4d2b600 00000000 f6f8fd54 c02c7ead
> [15460.053012] Call Trace:
> [15460.053012]  [<c02084a3>] ? __slab_alloc+0x163/0x220
> [15460.053012]  [<c02c7ead>] start_this_handle+0x22d/0x390
> [15460.053012]  [<c016ff90>] ? autoremove_wake_function+0x0/0x50
> [15460.053012]  [<c02c8188>] journal_start+0x98/0xd0
> [15460.053012]  [<c027b06e>] ext3_journal_start_sb+0x2e/0x50
> [15460.053012]  [<c0272f02>] ext3_dirty_inode+0x32/0x80
> [15460.053012]  [<c0231c71>] __mark_inode_dirty+0x31/0x180
> [15460.053012]  [<c022900a>] inode_setattr+0xaa/0x170
> [15460.053012]  [<c0273091>] ext3_setattr+0x141/0x1f0
> [15460.053012]  [<c0229213>] notify_change+0x143/0x340
> [15460.053012]  [<c02122d2>] do_truncate+0x62/0x90
> [15460.053012]  [<c03018ea>] ? security_path_truncate+0x3a/0x50
> [15460.053012]  [<c021c710>] may_open+0x1d0/0x200
> [15460.053012]  [<c021f9fc>] do_filp_open+0xfc/0x990
> [15460.053012]  [<c01efb74>] ? do_wp_page+0x104/0x910
> [15460.053012]  [<c02111d5>] do_sys_open+0x55/0x160
> [15460.053012]  [<c021134e>] sys_open+0x2e/0x40
> [15460.053012]  [<c01096c3>] sysenter_do_call+0x12/0x28
> [15460.053012] Sched Debug Version: v0.09, 2.6.32-28-generic-pae #55-Ubuntu
> [15460.053012] now at 15460053.551044 msecs
> [15460.053012]   .jiffies                                 : 3790013
> [15460.053012]   .sysctl_sched_latency                    : 10.000000
> [15460.053012]   .sysctl_sched_min_granularity            : 2.000000
> [15460.053012]   .sysctl_sched_wakeup_granularity         : 2.000000
> [15460.053012]   .sysctl_sched_child_runs_first           : 0.000000
> [15460.053012]   .sysctl_sched_features                   : 15834235
> [15460.053012]
> [15460.053012] cpu#0, 2194.944 MHz
> [15460.053012]   .nr_running                    : 1
> [15460.053012]   .load                          : 1024
> [15460.053012]   .nr_switches                   : 1773885
> [15460.053012]   .nr_load_updates               : 494855
> [15460.053012]   .nr_uninterruptible            : 1
> [15460.053012]   .next_balance                  : 3.789648
> [15460.053012]   .curr->pid                     : 17674
> [15460.053012]   .clock                         : 15460045.031387
> [15460.053012]   .cpu_load[0]                   : 0
> [15460.053012]   .cpu_load[1]                   : 0
> [15460.053012]   .cpu_load[2]                   : 0
> [15460.053012]   .cpu_load[3]                   : 0
> [15460.053012]   .cpu_load[4]                   : 0
> [15460.053012]   .yld_count                     : 1006
> [15460.053012]   .sched_switch                  : 0
> [15460.053012]   .sched_count                   : 1819077
> [15460.053012]   .sched_goidle                  : 758147
> [15460.053012]   .avg_idle                      : 1000000
> [15460.053012]   .ttwu_count                    : 922833
> [15460.053012]   .ttwu_local                    : 721258
> [15460.053012]   .bkl_count                     : 113
> [15460.053012]
> [15460.053012] cfs_rq[0]:/
> [15460.053012]   .exec_clock                    : 565672.449837
> [15460.053012]   .MIN_vruntime                  : 0.000001
> [15460.053012]   .min_vruntime                  : 684253.393210
> [15460.053012]   .max_vruntime                  : 0.000001
> [15460.053012]   .spread                        : 0.000000
> [15460.053012]   .spread0                       : 0.000000
> [15460.053012]   .nr_running                    : 1
> [15460.053012]   .load                          : 1024
> [15460.053012]   .nr_spread_over                : 2
> [15460.053012]   .shares                        : 0
> [15460.053012]
> [15460.053012] rt_rq[0]:/
> [15460.053012]   .rt_nr_running                 : 0
> [15460.053012]   .rt_throttled                  : 0
> [15460.053012]   .rt_time                       : 0.000000
> [15460.053012]   .rt_runtime                    : 950.000000
> [15460.053012]
> [15460.053012] runnable tasks:
> [15460.053012]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [15460.053012] ----------------------------------------------------------------------------------------------------------
> [15460.053012] R           bash 17674    684253.393210       448   120    684253.393210       168.337420    700111.995795 /
> [15460.053012]
> [15460.053012] cpu#1, 2194.944 MHz
> [15460.053012]   .nr_running                    : 0
> [15460.053012]   .load                          : 0
> [15460.053012]   .nr_switches                   : 2781711
> [15460.053012]   .nr_load_updates               : 585052
> [15460.053012]   .nr_uninterruptible            : 0
> [15460.053012]   .next_balance                  : 3.790015
> [15460.053012]   .curr->pid                     : 0
> [15460.053012]   .clock                         : 15460053.425771
> [15460.053012]   .cpu_load[0]                   : 0
> [15460.053012]   .cpu_load[1]                   : 0
> [15460.053012]   .cpu_load[2]                   : 0
> [15460.053012]   .cpu_load[3]                   : 0
> [15460.053012]   .cpu_load[4]                   : 0
> [15460.053012]   .yld_count                     : 971
> [15460.053012]   .sched_switch                  : 0
> [15460.053012]   .sched_count                   : 2828076
> [15460.053012]   .sched_goidle                  : 1319436
> [15460.053012]   .avg_idle                      : 875273
> [15460.053012]   .ttwu_count                    : 1398861
> [15460.053012]   .ttwu_local                    : 1163642
> [15460.053012]   .bkl_count                     : 79
> [15460.053012]
> [15460.053012] cfs_rq[1]:/
> [15460.053012]   .exec_clock                    : 415244.483606
> [15460.053012]   .MIN_vruntime                  : 0.000001
> [15460.053012]   .min_vruntime                  : 507085.016198
> [15460.053012]   .max_vruntime                  : 0.000001
> [15460.053012]   .spread                        : 0.000000
> [15460.053012]   .spread0                       : -177168.377012
> [15460.053012]   .nr_running                    : 0
> [15460.053012]   .load                          : 0
> [15460.053012]   .nr_spread_over                : 1
> [15460.053012]   .shares                        : 0
> [15460.053012]
> [15460.053012] rt_rq[1]:/
> [15460.053012]   .rt_nr_running                 : 0
> [15460.053012]   .rt_throttled                  : 0
> [15460.053012]   .rt_time                       : 0.000000
> [15460.053012]   .rt_runtime                    : 950.000000
> [15460.053012]
> [15460.053012] runnable tasks:
> [15460.053012]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [15460.053012] ----------------------------------------------------------------------------------------------------------
> [15460.053012]
> 
> [15492.337181] SysRq : Show clockevent devices & pending hrtimers (no others)
> [15492.341016] Timer List Version: v0.5
> [15492.341016] HRTIMER_MAX_CLOCK_BASES: 2
> [15492.341016] now at 15492345437343 nsecs
> [15492.341016]
> [15492.341016] cpu: 0
> [15492.341016]  clock 0:
> [15492.341016]   .base:       c70049a4
> [15492.341016]   .index:      0
> [15492.341016]   .resolution: 1 nsecs
> [15492.341016]   .get_time:   ktime_get_real
> [15492.341016]   .offset:     1297125938059809325 nsecs
> [15492.341016] active timers:
> [15492.341016]  clock 1:
> [15492.341016]   .base:       c70049d0
> [15492.341016]   .index:      1
> [15492.341016]   .resolution: 1 nsecs
> [15492.341016]   .get_time:   ktime_get
> [15492.341016]   .offset:     0 nsecs
> [15492.341016] active timers:
> [15492.341016]  #0: <c7004a60>, tick_sched_timer, S:01, hrtimer_start_range_ns, swapper/0
> [15492.341016]  # expires at 15492340000000-15492340000000 nsecs [in -5437343 to -5437343 nsecs]
> [15492.341016]  #1: <f5105ad8>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, zypper/28960
> [15492.341016]  # expires at 15497197764475-15497202764474 nsecs [in 4852327132 to 4857327131 nsecs]
> [15492.341016]  #2: <f6e09f40>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, cron/884
> [15492.341016]  # expires at 15503084128363-15503084178363 nsecs [in 10738691020 to 10738741020 nsecs]
> [15492.341016]  #3: <f4f19ad8>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, winbindd/917
> [15492.341016]  # expires at 15510366264172-15510396264171 nsecs [in 18020826829 to 18050826828 nsecs]
> [15492.341016]  #4: <f52bfef4>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, rsyslogd/17711
> [15492.341016]  # expires at 15520060947543-15520060997543 nsecs [in 27715510200 to 27715560200 nsecs]
> [15492.341016]  #5: <f4f37f40>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, atd/885
> [15492.341016]  # expires at 18011893116083-18011893166083 nsecs [in 2519547678740 to 2519547728740 nsecs]
> [15492.341016]  #6: <f4cc3ad8>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, smbd/836
> [15492.341016]  # expires at 20009829520272-20009929520272 nsecs [in 4517484082929 to 4517584082929 nsecs]
> [15492.341016]   .expires_next   : 15492340000000 nsecs
> [15492.341016]   .hres_active    : 1
> [15492.341016]   .nr_events      : 641821
> [15492.341016]   .nr_retries     : 26332
> [15492.341016]   .nr_hangs       : 0
> [15492.341016]   .max_hang_time  : 0 nsecs
> [15492.341016]   .nohz_mode      : 2
> [15492.341016]   .idle_tick      : 15492236000000 nsecs
> [15492.341016]   .tick_stopped   : 0
> [15492.341016]   .idle_jiffies   : 3798058
> [15492.341016]   .idle_calls     : 1096583
> [15492.341016]   .idle_sleeps    : 330634
> [15492.341016]   .idle_entrytime : 15492232028728 nsecs
> [15492.341016]   .idle_waketime  : 15492232000843 nsecs
> [15492.341016]   .idle_exittime  : 15492337016034 nsecs
> [15492.341016]   .idle_sleeptime : 14901605968046 nsecs
> [15492.341016]   .last_jiffies   : 3798058
> [15492.341016]   .next_jiffies   : 3798120
> [15492.341016]   .idle_expires   : 15492480000000 nsecs
> [15492.341016] jiffies: 3798086
> [15492.341016]
> [15492.341016] cpu: 1
> [15492.341016]  clock 0:
> [15492.341016]   .base:       c71049a4
> [15492.341016]   .index:      0
> [15492.341016]   .resolution: 1 nsecs
> [15492.341016]   .get_time:   ktime_get_real
> [15492.341016]   .offset:     1297125938059809325 nsecs
> [15492.341016] active timers:
> [15492.341016]  clock 1:
> [15492.341016]   .base:       c71049d0
> [15492.341016]   .index:      1
> [15492.341016]   .resolution: 1 nsecs
> [15492.341016]   .get_time:   ktime_get
> [15492.341016]   .offset:     0 nsecs
> [15492.341016] active timers:
> [15492.341016]  #0: <c7104a60>, tick_sched_timer, S:01, hrtimer_start_range_ns, swapper/0
> [15492.341016]  # expires at 15492349000000-15492349000000 nsecs [in 3562657 to 3562657 nsecs]
> [15492.341016]  #1: <f4c8bad8>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, apache2/947
> [15492.341016]  # expires at 15492556578781-15492557578780 nsecs [in 211141438 to 212141437 nsecs]
> [15492.341016]  #2: <f5359ad8>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, smbd/1140
> [15492.341016]  # expires at 15496084626915-15496121504563 nsecs [in 3739189572 to 3776067220 nsecs]
> [15492.341016]  #3: <f4f3bad8>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, rsyslogd/806
> [15492.341016]  # expires at 15507004032991-15507034032990 nsecs [in 14658595648 to 14688595647 nsecs]
> [15492.341016]  #4: <f4d29ad8>, hrtimer_wakeup, S:01, hrtimer_start_range_ns, smbd/796
> [15492.341016]  # expires at 20130936331799-20131036331799 nsecs [in 4638590894456 to 4638690894456 nsecs]
> [15492.341016]   .expires_next   : 15492349000000 nsecs
> [15492.341016]   .hres_active    : 1
> [15492.341016]   .nr_events      : 793193
> [15492.341016]   .nr_retries     : 26862
> [15492.341016]   .nr_hangs       : 0
> [15492.341016]   .max_hang_time  : 0 nsecs
> [15492.341016]   .nohz_mode      : 2
> [15492.341016]   .idle_tick      : 15492253000000 nsecs
> [15492.341016]   .tick_stopped   : 0
> [15492.341016]   .idle_jiffies   : 3798063
> [15492.341016]   .idle_calls     : 2433134
> [15492.341016]   .idle_sleeps    : 913836
> [15492.341016]   .idle_entrytime : 15492345003341 nsecs
> [15492.341016]   .idle_waketime  : 15492332763723 nsecs
> [15492.341016]   .idle_exittime  : 15492332774252 nsecs
> [15492.341016]   .idle_sleeptime : 15052885462990 nsecs
> [15492.341016]   .last_jiffies   : 3798086
> [15492.341016]   .next_jiffies   : 3798097
> [15492.341016]   .idle_expires   : 15492444000000 nsecs
> [15492.341016] jiffies: 3798086
> [15492.341016]
> [15492.341016]
> [15492.341016] Tick Device: mode:     1
> [15492.341016] Broadcast device
> [15492.341016] Clock Event Device: hpet
> [15492.341016]  max_delta_ns:   2147483647
> [15492.341016]  min_delta_ns:   5000
> [15492.341016]  mult:           61496114
> [15492.341016]  shift:          32
> [15492.341016]  mode:           3
> [15492.341016]  next_event:     9223372036854775807 nsecs
> [15492.341016]  set_next_event: hpet_legacy_next_event
> [15492.341016]  set_mode:       hpet_legacy_set_mode
> [15492.341016]  event_handler:  tick_handle_oneshot_broadcast
> [15492.341016] tick_broadcast_mask: 00000000
> [15492.341016] tick_broadcast_oneshot_mask: 00000000
> [15492.341016]
> [15492.341016]
> [15492.341016] Tick Device: mode:     1
> [15492.341016] Per CPU device: 0
> [15492.341016] Clock Event Device: lapic
> [15492.341016]  max_delta_ns:   672820093
> [15492.341016]  min_delta_ns:   1203
> [15492.341016]  mult:           53548925
> [15492.341016]  shift:          32
> [15492.341016]  mode:           3
> [15492.341016]  next_event:     15492340000000 nsecs
> [15492.341016]  set_next_event: lapic_next_event
> [15492.341016]  set_mode:       lapic_timer_setup
> [15492.341016]  event_handler:  hrtimer_interrupt
> [15492.341016]
> [15492.341016] Tick Device: mode:     1
> [15492.341016] Per CPU device: 1
> [15492.341016] Clock Event Device: lapic
> [15492.341016]  max_delta_ns:   672820093
> [15492.341016]  min_delta_ns:   1203
> [15492.341016]  mult:           53548925
> [15492.341016]  shift:          32
> [15492.341016]  mode:           3
> [15492.341016]  next_event:     15492349000000 nsecs
> [15492.341016]  set_next_event: lapic_next_event
> [15492.341016]  set_mode:       lapic_timer_setup
> [15492.341016]  event_handler:  hrtimer_interrupt
> [15492.341016]
> 
> [15676.361191] SysRq : Show Memory
> [15676.365011] Mem-Info:
> [15676.365011] DMA per-cpu:
> [15676.365011] CPU    0: hi:    0, btch:   1 usd:   0
> [15676.365011] CPU    1: hi:    0, btch:   1 usd:   0
> [15676.365011] Normal per-cpu:
> [15676.365011] CPU    0: hi:  186, btch:  31 usd:  73
> [15676.365011] CPU    1: hi:  186, btch:  31 usd: 176
> [15676.365011] HighMem per-cpu:
> [15676.365011] CPU    0: hi:  186, btch:  31 usd:  76
> [15676.365011] CPU    1: hi:  186, btch:  31 usd:  99
> [15676.365011] active_anon:5431 inactive_anon:7392 isolated_anon:0
> [15676.365011]  active_file:199148 inactive_file:241880 isolated_file:0
> [15676.365011]  unevictable:11 dirty:0 writeback:0 unstable:0
> [15676.365011]  free:13441 slab_reclaimable:21971 slab_unreclaimable:2072
> [15676.365011]  mapped:4822 shmem:254 pagetables:345 bounce:0
> [15676.365011] DMA free:8100kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:20kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15804kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> [15676.365011] lowmem_reserve[]: 0 867 2005 2005
> [15676.365011] Normal free:42564kB min:3732kB low:4664kB high:5596kB active_anon:0kB inactive_anon:488kB active_file:294868kB inactive_file:354120kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:887976kB mlocked:0kB dirty:0kB writeback:0kB mapped:720kB shmem:0kB slab_reclaimable:87884kB slab_unreclaimable:8280kB kernel_stack:1248kB pagetables:28kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [15676.365011] lowmem_reserve[]: 0 0 9106 9106
> [15676.365011] HighMem free:3100kB min:512kB low:1736kB high:2960kB active_anon:21724kB inactive_anon:29080kB active_file:501724kB inactive_file:613380kB unevictable:44kB isolated(anon):0kB isolated(file):0kB present:1165660kB mlocked:0kB dirty:0kB writeback:0kB mapped:18568kB shmem:1016kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:1352kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [15676.365011] lowmem_reserve[]: 0 0 0 0
> [15676.365011] DMA: 1*4kB 6*8kB 5*16kB 5*32kB 4*64kB 3*128kB 2*256kB 3*512kB 1*1024kB 2*2048kB 0*4096kB = 8100kB
> [15676.365011] Normal: 535*4kB 303*8kB 563*16kB 326*32kB 116*64kB 33*128kB 3*256kB 0*512kB 0*1024kB 1*2048kB 1*4096kB = 42564kB
> [15676.365011] HighMem: 19*4kB 26*8kB 30*16kB 17*32kB 10*64kB 5*128kB 2*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3100kB
> [15676.365011] 441294 total pagecache pages
> [15676.365011] 0 pages in swap cache
> [15676.365011] Swap cache stats: add 0, delete 0, find 0/0
> [15676.365011] Free swap  = 0kB
> [15676.365011] Total swap = 0kB
> [15676.365011] 521532 pages RAM
> [15676.365011] 293710 pages HighMem
> [15676.365011] 25301 pages reserved
> [15676.365011] 410815 pages shared
> [15676.365011] 81402 pages non-shared
> 
> # cat /proc/17496/status
> Name:   sh
> State:  D (disk sleep)
> Tgid:   17496
> Pid:    17496
> PPid:   17470
> TracerPid:      0
> Uid:    0       0       0       0
> Gid:    0       0       0       0
> FDSize: 256
> Groups: 0
> VmPeak:     3008 kB
> VmSize:     3008 kB
> VmLck:         0 kB
> VmHWM:       400 kB
> VmRSS:       400 kB
> VmData:      196 kB
> VmStk:        88 kB
> VmExe:       580 kB
> VmLib:      2064 kB
> VmPTE:        20 kB
> Threads:        1
> SigQ:   2/16382
> SigPnd: 0000000000000000
> ShdPnd: 0000000000000002
> SigBlk: 0000000000000000
> SigIgn: 0000000000000000
> SigCgt: 0000000000010002
> CapInh: 0000000000000000
> CapPrm: ffffffffffffffff
> CapEff: ffffffffffffffff
> CapBnd: ffffffffffffffff
> Cpus_allowed:   3
> Cpus_allowed_list:      0-1
> Mems_allowed:   1
> Mems_allowed_list:      0
> voluntary_ctxt_switches:        1
> nonvoluntary_ctxt_switches:     0
> 
> # cat /proc/version
> Linux version 2.6.32-28-generic-pae (buildd@palmer) (gcc version 4.4.3 (Ubuntu 4.4.3-4ubuntu5) ) #55-Ubuntu SMP Mon Jan 10 22:34:08 UTC 2011
> 
> # cat /proc/cmdline
> BOOT_IMAGE=/boot/vmlinuz-2.6.32-28-generic-pae root=UUID=59b657e8-f757-4b9b-807f-56541a7cefa6 ro crashkernel=384M-2G:64M,2G-:128M quiet splash

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
