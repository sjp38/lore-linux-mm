Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 186DD6B0269
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:35:00 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r184-v6so13310156ith.0
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:35:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s7-v6si10678136jan.4.2018.07.30.07.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 07:34:54 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
 <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
 <20180730093257.GG24267@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
Date: Mon, 30 Jul 2018 23:34:23 +0900
MIME-Version: 1.0
In-Reply-To: <20180730093257.GG24267@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/07/30 18:32, Michal Hocko wrote:
>>>> Since the patch shown below was suggested by Michal Hocko at
>>>> https://marc.info/?l=linux-mm&m=152723708623015 , it is from Michal Hocko.
>>>>
>>>> >From cd8095242de13ace61eefca0c3d6f2a5a7b40032 Mon Sep 17 00:00:00 2001
>>>> From: Michal Hocko <mhocko@suse.com>
>>>> Date: Thu, 26 Jul 2018 14:40:03 +0900
>>>> Subject: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at should_reclaim_retry().
>>>>
>>>> Tetsuo Handa has reported that it is possible to bypass the short sleep
>>>> for PF_WQ_WORKER threads which was introduced by commit 373ccbe5927034b5
>>>> ("mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make
>>>> any progress") and moved by commit ede37713737834d9 ("mm: throttle on IO
>>>> only when there are too many dirty and writeback pages") and lock up the
>>>> system if OOM.
>>>>
>>>> This is because we are implicitly counting on falling back to
>>>> schedule_timeout_uninterruptible() in __alloc_pages_may_oom() when
>>>> schedule_timeout_uninterruptible() in should_reclaim_retry() was not
>>>> called due to __zone_watermark_ok() == false.
>>>
>>> How do we rely on that?
>>
>> Unless disk_events_workfn() (PID=5) sleeps at schedule_timeout_uninterruptible()
>> in __alloc_pages_may_oom(), drain_local_pages_wq() which a thread doing __GFP_FS
>> allocation (PID=498) is waiting for cannot be started.
> 
> Now you are losing me again. What is going on about
> drain_local_pages_wq? I can see that all __GFP_FS allocations are
> waiting for a completion which depends on the kworker context to run but
> I fail to see why drain_local_pages_wq matters. The memory on the pcp
> lists is not accounted to NR_FREE_PAGES IIRC but that should be a
> relatively small amount of memory so this cannot be a fundamental
> problem here.

If you look at "busy workqueues and worker pools", you will find that not only
vmstat_update and drain_local_pages_wq (which is WQ_MEM_RECLAIM) but also
other works such as xlog_cil_push_work and xfs_reclaim_worker (which is also
WQ_MEM_RECLAIM) remain "pending:" state.

[  324.960731] Showing busy workqueues and worker pools:
[  324.962577] workqueue events: flags=0x0
[  324.964137]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=13/256
[  324.966231]     pending: vmw_fb_dirty_flush [vmwgfx], vmstat_shepherd, vmpressure_work_fn, free_work, mmdrop_async_fn, mmdrop_async_fn, mmdrop_async_fn, mmdrop_async_fn, e1000_watchdog [e1000], mmdrop_async_fn, mmdrop_async_fn, check_corruption, console_callback
[  324.973425] workqueue events_freezable: flags=0x4
[  324.975247]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  324.977393]     pending: vmballoon_work [vmw_balloon]
[  324.979310] workqueue events_power_efficient: flags=0x80
[  324.981298]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=5/256
[  324.983543]     pending: gc_worker [nf_conntrack], fb_flashcursor, neigh_periodic_work, neigh_periodic_work, check_lifetime
[  324.987240] workqueue events_freezable_power_: flags=0x84
[  324.989292]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  324.991482]     in-flight: 5:disk_events_workfn
[  324.993371] workqueue mm_percpu_wq: flags=0x8
[  324.995167]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  324.997363]     pending: vmstat_update, drain_local_pages_wq BAR(498)
[  324.999977] workqueue ipv6_addrconf: flags=0x40008
[  325.001899]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/1
[  325.004092]     pending: addrconf_verify_work
[  325.005911] workqueue mpt_poll_0: flags=0x8
[  325.007686]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  325.009914]     pending: mpt_fault_reset_work [mptbase]
[  325.012044] workqueue xfs-cil/sda1: flags=0xc
[  325.013897]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  325.016190]     pending: xlog_cil_push_work [xfs] BAR(2344)
[  325.018354] workqueue xfs-reclaim/sda1: flags=0xc
[  325.020293]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  325.022549]     pending: xfs_reclaim_worker [xfs]
[  325.024540] workqueue xfs-sync/sda1: flags=0x4
[  325.026425]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  325.028691]     pending: xfs_log_worker [xfs]
[  325.030546] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=189s workers=4 idle: 977 65 13

[  444.206334] Showing busy workqueues and worker pools:
[  444.208472] workqueue events: flags=0x0
[  444.210193]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=15/256
[  444.212389]     pending: vmw_fb_dirty_flush [vmwgfx], vmstat_shepherd, vmpressure_work_fn, free_work, mmdrop_async_fn, mmdrop_async_fn, mmdrop_async_fn, mmdrop_async_fn, e1000_watchdog [e1000], mmdrop_async_fn, mmdrop_async_fn, check_corruption, console_callback, sysrq_reinject_alt_sysrq, moom_callback
[  444.220547] workqueue events_freezable: flags=0x4
[  444.222562]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  444.224852]     pending: vmballoon_work [vmw_balloon]
[  444.227022] workqueue events_power_efficient: flags=0x80
[  444.229103]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=5/256
[  444.231271]     pending: gc_worker [nf_conntrack], fb_flashcursor, neigh_periodic_work, neigh_periodic_work, check_lifetime
[  444.234824] workqueue events_freezable_power_: flags=0x84
[  444.236937]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  444.239138]     in-flight: 5:disk_events_workfn
[  444.241022] workqueue mm_percpu_wq: flags=0x8
[  444.242829]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  444.245057]     pending: vmstat_update, drain_local_pages_wq BAR(498)
[  444.247646] workqueue ipv6_addrconf: flags=0x40008
[  444.249582]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/1
[  444.251784]     pending: addrconf_verify_work
[  444.253620] workqueue mpt_poll_0: flags=0x8
[  444.255427]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  444.257666]     pending: mpt_fault_reset_work [mptbase]
[  444.259800] workqueue xfs-cil/sda1: flags=0xc
[  444.261646]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  444.263903]     pending: xlog_cil_push_work [xfs] BAR(2344)
[  444.266101] workqueue xfs-reclaim/sda1: flags=0xc
[  444.268104]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  444.270454]     pending: xfs_reclaim_worker [xfs]
[  444.272425] workqueue xfs-eofblocks/sda1: flags=0xc
[  444.274432]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  444.276729]     pending: xfs_eofblocks_worker [xfs]
[  444.278739] workqueue xfs-sync/sda1: flags=0x4
[  444.280641]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  444.282967]     pending: xfs_log_worker [xfs]
[  444.285195] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=309s workers=3 idle: 977 65

>>>> Tetsuo is observing that GFP_NOIO
>>>> allocation request from disk_events_workfn() is preventing other pending
>>>> works from starting.
>>>
>>> What about any other allocation from !PF_WQ_WORKER context? Why those do
>>> not jump in?
>>
>> All __GFP_FS allocations got stuck at direct reclaim or workqueue.
>>
>>>
>>>> Since should_reclaim_retry() should be a natural reschedule point,
>>>> let's do the short sleep for PF_WQ_WORKER threads unconditionally
>>>> in order to guarantee that other pending works are started.
>>>
>>> OK, this is finally makes some sense. But it doesn't explain why it
>>> handles the live lock.
>>
>> As explained above, if disk_events_workfn() (PID=5) explicitly sleeps,
>> vmstat_update and drain_local_pages_wq from WQ_MEM_RECLAIM workqueue will
>> start, and unblock PID=498 which is waiting for drain_local_pages_wq and
>> allow PID=498 to invoke the OOM killer.
> 
> [  313.714537] systemd-journal D12600   498      1 0x00000000
> [  313.716538] Call Trace:
> [  313.717683]  ? __schedule+0x245/0x7f0
> [  313.719221]  schedule+0x23/0x80
> [  313.720586]  schedule_timeout+0x21f/0x400
> [  313.722163]  wait_for_completion+0xb2/0x130
> [  313.723750]  ? wake_up_q+0x70/0x70
> [  313.725134]  flush_work+0x1db/0x2b0
> [  313.726535]  ? flush_workqueue_prep_pwqs+0x1b0/0x1b0
> [  313.728336]  ? page_alloc_cpu_dead+0x30/0x30
> [  313.729936]  drain_all_pages+0x174/0x1e0
> [  313.731446]  __alloc_pages_slowpath+0x428/0xc50
> [  313.733120]  __alloc_pages_nodemask+0x2a6/0x2c0
> [  313.734826]  filemap_fault+0x437/0x8e0
> [  313.736296]  ? lock_acquire+0x51/0x70
> [  313.737769]  ? xfs_ilock+0x86/0x190 [xfs]
> [  313.739309]  __xfs_filemap_fault.constprop.21+0x37/0xc0 [xfs]
> [  313.741291]  __do_fault+0x13/0x126
> [  313.742667]  __handle_mm_fault+0xc8d/0x11c0
> [  313.744245]  handle_mm_fault+0x17a/0x390
> [  313.745755]  __do_page_fault+0x24c/0x4d0
> [  313.747290]  do_page_fault+0x2a/0x70
> [  313.748728]  ? page_fault+0x8/0x30
> [  313.750148]  page_fault+0x1e/0x30
> 
> This one is waiting for draining and we are in mm_percpu_wq WQ context
> which has its rescuer so no other activity can block us for ever. So
> this certainly shouldn't deadlock. It can be dead slow but well, this is
> what you will get when your shoot your system to death.

We need schedule_timeout_*() to allow such WQ_MEM_RECLAIM workqueues to wake up. (Tejun,
is my understanding correct?) Lack of schedule_timeout_*() does block WQ_MEM_RECLAIM
workqueues forever.

Did you count how many threads were running from SysRq-t output?
If you did, you won't say "when you shoot your system to death". :-(

(Tester processes stuck at D state are omitted from below excerpt.
You can see that the system is almost idle.)

[  310.265293] systemd         D12240     1      0 0x00000000
[  310.345487] kthreadd        S14024     2      0 0x80000000
[  310.355813] rcu_gp          I15176     3      2 0x80000000
[  310.369297] rcu_par_gp      I15176     4      2 0x80000000
[  310.383005] kworker/0:0     R  running task    13504     5      2 0x80000000
[  310.385328] Workqueue: events_freezable_power_ disk_events_workfn
[  310.510953] kworker/0:0H    I14648     6      2 0x80000000
[  310.513024] Workqueue:            (null) (xfs-log/sda1)
[  310.527289] kworker/u256:0  I12816     7      2 0x80000000
[  310.529282] Workqueue:            (null) (events_unbound)
[  310.543584] mm_percpu_wq    I15176     8      2 0x80000000
[  310.557527] ksoftirqd/0     S14664     9      2 0x80000000
[  310.573041] rcu_sched       I14360    10      2 0x80000000
[  310.586582] rcu_bh          I15192    11      2 0x80000000
[  310.603372] migration/0     S14664    12      2 0x80000000
[  310.617362] kworker/0:1     I13312    13      2 0x80000000
[  310.619297] Workqueue:            (null) (cgroup_pidlist_destroy)
[  310.633055] cpuhp/0         S13920    14      2 0x80000000
[  310.647134] cpuhp/1         P13992    15      2 0x80000000
[  310.662731] migration/1     P14664    16      2 0x80000000
[  310.678559] ksoftirqd/1     P14656    17      2 0x80000000
[  310.694278] kworker/1:0     I13808    18      2 0x80000000
[  310.696221] Workqueue:            (null) (events)
[  310.709753] kworker/1:0H    I14648    19      2 0x80000000
[  310.711701] Workqueue:            (null) (kblockd)
[  310.725166] cpuhp/2         P13992    20      2 0x80000000
[  310.740708] migration/2     P14664    21      2 0x80000000
[  310.756255] ksoftirqd/2     P14664    22      2 0x80000000
[  310.771832] kworker/2:0     I14648    23      2 0x80000000
[  310.773789] Workqueue:            (null) (events)
[  310.787215] kworker/2:0H    I14480    24      2 0x80000000
[  310.789156] Workqueue:            (null) (xfs-log/sda1)
[  310.802735] cpuhp/3         P14056    25      2 0x80000000
[  310.818282] migration/3     P14664    26      2 0x80000000
[  310.833806] ksoftirqd/3     P14600    27      2 0x80000000
[  310.849330] kworker/3:0     I14648    28      2 0x80000000
[  310.851269] Workqueue:            (null) (events)
[  310.864855] kworker/3:0H    I15192    29      2 0x80000000
[  310.878479] cpuhp/4         P13696    30      2 0x80000000
[  310.894006] migration/4     P14664    31      2 0x80000000
[  310.909697] ksoftirqd/4     P14664    32      2 0x80000000
[  310.925546] kworker/4:0     I14464    33      2 0x80000000
[  310.927482] Workqueue:            (null) (events)
[  310.940917] kworker/4:0H    I14808    34      2 0x80000000
[  310.942872] Workqueue:            (null) (kblockd)
[  310.956699] cpuhp/5         P13960    35      2 0x80000000
[  310.972274] migration/5     P14664    36      2 0x80000000
[  310.987850] ksoftirqd/5     P14664    37      2 0x80000000
[  311.003382] kworker/5:0     I14400    38      2 0x80000000
[  311.005322] Workqueue:            (null) (events)
[  311.018758] kworker/5:0H    I15184    39      2 0x80000000
[  311.032629] cpuhp/6         P14024    40      2 0x80000000
[  311.048609] migration/6     P14664    41      2 0x80000000
[  311.064377] ksoftirqd/6     P14600    42      2 0x80000000
[  311.079858] kworker/6:0     I14616    43      2 0x80000000
[  311.081800] Workqueue:            (null) (cgroup_pidlist_destroy)
[  311.095610] kworker/6:0H    I14616    44      2 0x80000000
[  311.097549] Workqueue:            (null) (kblockd)
[  311.111033] cpuhp/7         P13992    45      2 0x80000000
[  311.127639] migration/7     P14664    46      2 0x80000000
[  311.143797] ksoftirqd/7     P14856    47      2 0x80000000
[  311.159383] kworker/7:0     I14576    48      2 0x80000000
[  311.161324] Workqueue:            (null) (events)
[  311.174750] kworker/7:0H    I14808    49      2 0x80000000
[  311.176690] Workqueue:            (null) (xfs-log/sda1)
[  311.190305] kdevtmpfs       S13552    50      2 0x80000000
[  311.205199] netns           I15152    51      2 0x80000000
[  311.218718] kworker/1:1     I14808    52      2 0x80000000
[  311.220630] Workqueue:            (null) (ata_sff)
[  311.234003] kauditd         S14640    53      2 0x80000000
[  311.251581] khungtaskd      S14368    54      2 0x80000000
[  311.268573] oom_reaper      S14464    55      2 0x80000000
[  311.283432] writeback       I15152    56      2 0x80000000
[  311.296825] kcompactd0      S14856    57      2 0x80000000
[  311.311451] ksmd            S15032    58      2 0x80000000
[  311.331290] khugepaged      D13832    59      2 0x80000000
[  311.402468] crypto          I15192    60      2 0x80000000
[  311.421397] kintegrityd     I15152    61      2 0x80000000
[  311.435436] kblockd         I15192    62      2 0x80000000
[  311.449503] kworker/3:1     I14264    63      2 0x80000000
[  311.451420] Workqueue:            (null) (events)
[  311.464883] kworker/5:1     I13568    64      2 0x80000000
[  311.466846] Workqueue:            (null) (events)
[  311.480784] kworker/0:2     I13104    65      2 0x80000000
[  311.482780] Workqueue:            (null) (cgroup_pidlist_destroy)
[  311.497643] md              I15152    66      2 0x80000000
[  311.513651] edac-poller     I15192    67      2 0x80000000
[  311.528223] devfreq_wq      I15152    68      2 0x80000000
[  311.542243] watchdogd       S15192    69      2 0x80000000
[  311.557627] kworker/2:1     I13848    70      2 0x80000000
[  311.559557] Workqueue:            (null) (cgroup_pidlist_destroy)
[  311.573158] kswapd0         S11528    71      2 0x80000000
[  311.588482] kworker/4:1     I13976    82      2 0x80000000
[  311.590418] Workqueue:            (null) (events)
[  311.603683] kthrotld        I14712    88      2 0x80000000
[  311.617936] kworker/6:1     I14280    89      2 0x80000000
[  311.619855] Workqueue:            (null) (events)
[  311.633386] kworker/7:1     I13976    90      2 0x80000000
[  311.635309] Workqueue:            (null) (events_power_efficient)
[  311.649001] acpi_thermal_pm I14856    91      2 0x80000000
[  311.662606] kworker/u256:1  I13168    92      2 0x80000000
[  311.664551] Workqueue:            (null) (events_unbound)
[  311.678115] kmpath_rdacd    I15176    93      2 0x80000000
[  311.691756] kaluad          I14712    94      2 0x80000000
[  311.705839] nvme-wq         I14712    95      2 0x80000000
[  311.720293] nvme-reset-wq   I14712    96      2 0x80000000
[  311.734252] nvme-delete-wq  I15176    97      2 0x80000000
[  311.747801] kworker/u256:2  I14088    98      2 0x80000000
[  311.749766] Workqueue:            (null) (events_unbound)
[  311.763307] kworker/u256:3  I13560    99      2 0x80000000
[  311.765273] Workqueue:            (null) (events_unbound)
[  311.778791] ipv6_addrconf   I15176   100      2 0x80000000
[  311.792413] kworker/5:2     I14728   134      2 0x80000000
[  311.794381] Workqueue:            (null) (events)
[  311.809119] kworker/2:2     I13952   156      2 0x80000000
[  311.811554] Workqueue:            (null) (events)
[  311.829185] kworker/6:2     I14264   158      2 0x80000000
[  311.831332] Workqueue:            (null) (events)
[  311.844858] kworker/4:2     I14648   200      2 0x80000000
[  311.846876] Workqueue:            (null) (cgroup_pidlist_destroy)
[  311.860651] kworker/3:2     I14728   251      2 0x80000000
[  311.862598] Workqueue:            (null) (cgroup_pidlist_destroy)
[  311.876388] kworker/7:2     I13520   282      2 0x80000000
[  311.878336] Workqueue:            (null) (events)
[  311.891701] ata_sff         I15152   284      2 0x80000000
[  311.905381] scsi_eh_0       S14504   285      2 0x80000000
[  311.922693] scsi_tmf_0      I14952   286      2 0x80000000
[  311.936327] scsi_eh_1       S13560   287      2 0x80000000
[  311.953512] scsi_tmf_1      I14952   288      2 0x80000000
[  311.967137] mpt_poll_0      I15152   289      2 0x80000000
[  311.980810] mpt/0           I14952   290      2 0x80000000
[  311.994421] scsi_eh_2       S13320   291      2 0x80000000
[  312.011558] scsi_tmf_2      I15152   292      2 0x80000000
[  312.026613] scsi_eh_3       S13656   293      2 0x80000000
[  312.046380] scsi_tmf_3      I15152   294      2 0x80000000
[  312.063536] scsi_eh_4       S13656   295      2 0x80000000
[  312.082705] scsi_tmf_4      I15176   296      2 0x80000000
[  312.097973] scsi_eh_5       S13320   297      2 0x80000000
[  312.117232] scsi_tmf_5      I15152   298      2 0x80000000
[  312.132573] scsi_eh_6       S13320   299      2 0x80000000
[  312.151843] scsi_tmf_6      I15152   300      2 0x80000000
[  312.167109] ttm_swap        I15176   301      2 0x80000000
[  312.182415] scsi_eh_7       S13320   302      2 0x80000000
[  312.201595] scsi_tmf_7      I15064   303      2 0x80000000
[  312.216695] scsi_eh_8       S13320   304      2 0x80000000
[  312.236470] scsi_tmf_8      I14856   305      2 0x80000000
[  312.251403] scsi_eh_9       S13656   306      2 0x80000000
[  312.270443] scsi_tmf_9      I15152   307      2 0x80000000
[  312.284642] irq/16-vmwgfx   S14784   308      2 0x80000000
[  312.301877] scsi_eh_10      S13320   309      2 0x80000000
[  312.319679] scsi_tmf_10     I15152   310      2 0x80000000
[  312.333461] scsi_eh_11      S13320   311      2 0x80000000
[  312.350681] scsi_tmf_11     I15176   312      2 0x80000000
[  312.364444] scsi_eh_12      S13656   313      2 0x80000000
[  312.382093] scsi_tmf_12     I15152   314      2 0x80000000
[  312.395952] scsi_eh_13      S13656   315      2 0x80000000
[  312.413378] scsi_tmf_13     I15032   316      2 0x80000000
[  312.427103] scsi_eh_14      S13624   317      2 0x80000000
[  312.444286] scsi_tmf_14     I15176   318      2 0x80000000
[  312.457978] scsi_eh_15      S15192   319      2 0x80000000
[  312.477516] scsi_tmf_15     I15176   320      2 0x80000000
[  312.491641] scsi_eh_16      S13656   321      2 0x80000000
[  312.509443] scsi_tmf_16     I15032   322      2 0x80000000
[  312.523573] scsi_eh_17      S13320   323      2 0x80000000
[  312.540983] scsi_tmf_17     I15152   324      2 0x80000000
[  312.554847] scsi_eh_18      S13320   325      2 0x80000000
[  312.572062] scsi_tmf_18     I15152   326      2 0x80000000
[  312.585722] scsi_eh_19      S13320   327      2 0x80000000
[  312.603012] scsi_tmf_19     I14952   328      2 0x80000000
[  312.616683] scsi_eh_20      S13320   329      2 0x80000000
[  312.633915] scsi_tmf_20     I14856   330      2 0x80000000
[  312.647594] scsi_eh_21      S13624   331      2 0x80000000
[  312.664791] scsi_tmf_21     I15152   332      2 0x80000000
[  312.678495] scsi_eh_22      S13320   333      2 0x80000000
[  312.695697] scsi_tmf_22     I15176   334      2 0x80000000
[  312.709366] scsi_eh_23      S13656   335      2 0x80000000
[  312.738358] scsi_tmf_23     I14984   336      2 0x80000000
[  312.752608] scsi_eh_24      S13320   337      2 0x80000000
[  312.770582] scsi_tmf_24     I15176   338      2 0x80000000
[  312.784878] scsi_eh_25      S13624   339      2 0x80000000
[  312.802234] scsi_tmf_25     I14984   340      2 0x80000000
[  312.815906] scsi_eh_26      S13624   341      2 0x80000000
[  312.833209] scsi_tmf_26     I14984   342      2 0x80000000
[  312.847120] scsi_eh_27      S13656   343      2 0x80000000
[  312.864431] scsi_tmf_27     I14984   344      2 0x80000000
[  312.878111] scsi_eh_28      S13656   345      2 0x80000000
[  312.895298] scsi_tmf_28     I15152   346      2 0x80000000
[  312.908979] scsi_eh_29      S13656   348      2 0x80000000
[  312.926273] scsi_tmf_29     I15152   349      2 0x80000000
[  312.939917] scsi_eh_30      S13656   350      2 0x80000000
[  312.957305] scsi_tmf_30     I15152   351      2 0x80000000
[  312.970959] scsi_eh_31      S13008   352      2 0x80000000
[  312.988336] scsi_tmf_31     I14856   353      2 0x80000000
[  313.002016] scsi_eh_32      S13624   354      2 0x80000000
[  313.019231] scsi_tmf_32     I15152   355      2 0x80000000
[  313.033116] kworker/u256:4  I14616   356      2 0x80000000
[  313.035122] Workqueue:            (null) (events_unbound)
[  313.048958] kworker/u256:5  I14408   357      2 0x80000000
[  313.050911] Workqueue:            (null) (events_unbound)
[  313.064605] kworker/u256:6  I14616   358      2 0x80000000
[  313.066588] Workqueue:            (null) (events_unbound)
[  313.080184] kworker/u256:7  I14392   359      2 0x80000000
[  313.082139] Workqueue:            (null) (events_unbound)
[  313.095693] kworker/u256:8  I14616   360      2 0x80000000
[  313.097625] Workqueue:            (null) (events_unbound)
[  313.111206] kworker/u256:9  I14088   362      2 0x80000000
[  313.113130] Workqueue:            (null) (events_unbound)
[  313.126701] kworker/u256:10 I14440   364      2 0x80000000
[  313.128630] Workqueue:            (null) (events_unbound)
[  313.142204] kworker/u256:11 I14440   365      2 0x80000000
[  313.144133] Workqueue:            (null) (events_unbound)
[  313.157836] kworker/u256:12 I14440   366      2 0x80000000
[  313.159834] Workqueue:            (null) (events_unbound)
[  313.173426] kworker/u256:13 I14440   367      2 0x80000000
[  313.175360] Workqueue:            (null) (events_unbound)
[  313.188953] kworker/u256:14 I14440   368      2 0x80000000
[  313.190883] Workqueue:            (null) (events_unbound)
[  313.204529] kworker/u256:15 I14440   369      2 0x80000000
[  313.206524] Workqueue:            (null) (events_unbound)
[  313.220106] kworker/u256:16 I14440   370      2 0x80000000
[  313.222040] Workqueue:            (null) (events_unbound)
[  313.235845] kworker/u256:17 I14440   371      2 0x80000000
[  313.238007] Workqueue:            (null) (events_unbound)
[  313.251879] kworker/u256:18 I14440   372      2 0x80000000
[  313.253880] Workqueue:            (null) (events_unbound)
[  313.268276] kworker/u256:19 I14440   373      2 0x80000000
[  313.270312] Workqueue:            (null) (events_unbound)
[  313.284299] kworker/u256:20 I14440   374      2 0x80000000
[  313.286254] Workqueue:            (null) (events_unbound)
[  313.300548] kworker/u256:21 I14440   375      2 0x80000000
[  313.302563] Workqueue:            (null) (events_unbound)
[  313.316925] kworker/u256:22 I14440   376      2 0x80000000
[  313.318857] Workqueue:            (null) (events_unbound)
[  313.333454] kworker/u256:23 I14440   377      2 0x80000000
[  313.335460] Workqueue:            (null) (events_unbound)
[  313.349943] kworker/u256:24 I14392   378      2 0x80000000
[  313.351872] Workqueue:            (null) (events_unbound)
[  313.366316] kworker/u256:25 I14392   379      2 0x80000000
[  313.368369] Workqueue:            (null) (events_unbound)
[  313.382706] kworker/u256:26 I14440   380      2 0x80000000
[  313.384638] Workqueue:            (null) (events_unbound)
[  313.398913] kworker/u256:27 I14440   381      2 0x80000000
[  313.400995] Workqueue:            (null) (events_unbound)
[  313.415395] kworker/u256:28 I14440   382      2 0x80000000
[  313.417325] Workqueue:            (null) (events_unbound)
[  313.431863] kworker/u256:29 I14440   383      2 0x80000000
[  313.433880] Workqueue:            (null) (events_unbound)
[  313.448121] kworker/u256:30 I12872   384      2 0x80000000
[  313.450050] Workqueue:            (null) (events_unbound)
[  313.464862] kworker/u256:31 I10848   385      2 0x80000000
[  313.467082] Workqueue:            (null) (flush-8:0)
[  313.481995] kworker/u256:32 I14440   386      2 0x80000000
[  313.484013] Workqueue:            (null) (events_unbound)
[  313.498207] kworker/u256:33 I15032   387      2 0x80000000
[  313.500272] Workqueue:            (null) (events_unbound)
[  313.514300] kworker/1:2     I14728   411      2 0x80000000
[  313.516350] Workqueue:            (null) (cgroup_pidlist_destroy)
[  313.530409] kworker/6:1H    I15144   414      2 0x80000000
[  313.532422] Workqueue:            (null) (kblockd)
[  313.545957] xfsalloc        I15176   419      2 0x80000000
[  313.559714] xfs_mru_cache   I15176   420      2 0x80000000
[  313.573541] xfs-buf/sda1    I15176   421      2 0x80000000
[  313.587184] xfs-data/sda1   I15176   422      2 0x80000000
[  313.600830] xfs-conv/sda1   I15176   423      2 0x80000000
[  313.614464] xfs-cil/sda1    I15176   424      2 0x80000000
[  313.628114] xfs-reclaim/sda I15152   425      2 0x80000000
[  313.641772] xfs-log/sda1    I15176   426      2 0x80000000
[  313.655372] xfs-eofblocks/s I15176   427      2 0x80000000
[  313.668954] xfsaild/sda1    S13560   428      2 0x80000000
[  313.685728] kworker/7:1H    I14648   429      2 0x80000000
[  313.687693] Workqueue:            (null) (kblockd)
[  313.701018] kworker/1:1H    I14648   497      2 0x80000000
[  313.714537] systemd-journal D12600   498      1 0x00000000
[  313.767803] systemd-udevd   S12648   529      1 0x00000000
[  313.804733] auditd          D12808   546      1 0x00000000
[  313.874023] auditd          S13584   547      1 0x00000000
[  313.910947] kworker/4:1H    I15184   552      2 0x80000080
[  313.912888] Workqueue:            (null) (kblockd)
[  313.927331] polkitd         S12536   593      1 0x00000080
[  313.981730] gmain           S14032   604      1 0x00000080
[  314.041923] gdbus           S13760   605      1 0x00000080
[  314.094085] JS GC Helper    S14696   611      1 0x00000080
[  314.136686] JS Sour~ Thread S14696   616      1 0x00000080
[  314.180020] polkitd         S14200   621      1 0x00000080
[  314.238165] irqbalance      D12904   594      1 0x80000080
[  314.307023] avahi-daemon    S12632   597      1 0x00000080
[  314.357108] dbus-daemon     S12632   598      1 0x00000080
[  314.390871] avahi-daemon    S12888   603    597 0x00000080
[  314.439229] abrtd           S12488   606      1 0x00000080
[  314.503323] systemd-logind  D12904   608      1 0x00000080
[  314.572804] atd             S12728   612      1 0x00000080
[  314.608670] crond           D12536   614      1 0x00000080
[  314.677690] ksmtuned        S13312   619      1 0x00000080
[  314.714501] firewalld       S12456   623      1 0x00000080
[  314.767120] gmain           S14248   756      1 0x00000080
[  314.824569] NetworkManager  S11816   662      1 0x00000080
[  314.881313] gmain           D12544   669      1 0x00000080
[  314.949419] gdbus           S13432   672      1 0x00000080
[  315.000239] kworker/0:1H    I14096   742      2 0x80000080
[  315.002178] Workqueue:            (null) (kblockd)
[  315.015633] dhclient        S12328   759    662 0x00000080
[  315.082950] kworker/2:1H    I14480   768      2 0x80000080
[  315.084945] Workqueue:            (null) (xfs-log/sda1)
[  315.098501] tuned           S12552   949      1 0x00000080
[  315.165944] gmain           S14248   995      1 0x00000080
[  315.224133] tuned           D12328   996      1 0x80000080
[  315.292809] tuned           S14408   997      1 0x00000080
[  315.330274] tuned           S14248  1011      1 0x00000080
[  315.389366] smbd            S11288   951      1 0x00000080
[  315.427197] sshd            S12552   952      1 0x00000080
[  315.509092] rsyslogd        S12696   954      1 0x00000080
[  315.578028] in:imjournal    D12048   965      1 0x80000080
[  315.645481] rs:main Q:Reg   S12792   966      1 0x00000080
[  315.681641] sendmail        D13176   967      1 0x00000080
[  315.751526] kworker/0:3     I13376   977      2 0x80000080
[  315.753526] Workqueue:            (null) (ata_sff)
[  315.766860] agetty          S12904   989      1 0x00000080
[  315.810543] login           S12488   990      1 0x00000080
[  315.849297] sendmail        S14256   991      1 0x00000080
[  315.877525] smbd-notifyd    D12792  1012    951 0x00000080
[  315.947463] cleanupd        D13144  1013    951 0x00000080
[  316.016683] lpqd            S12888  1016    951 0x00000080
[  316.054304] bash            S12656  1019    990 0x00000080
[  316.092765] sleep           D12808  1614    619 0x00000080

[  429.965904] systemd         D12240     1      0 0x00000000
[  430.045240] kthreadd        S14024     2      0 0x80000000
[  430.055553] rcu_gp          I15176     3      2 0x80000000
[  430.069575] rcu_par_gp      I15176     4      2 0x80000000
[  430.083584] kworker/0:0     R  running task    13504     5      2 0x80000000
[  430.085990] Workqueue: events_freezable_power_ disk_events_workfn
[  430.210920] kworker/0:0H    I14648     6      2 0x80000000
[  430.212997] Workqueue:            (null) (xfs-log/sda1)
[  430.227747] mm_percpu_wq    I15176     8      2 0x80000000
[  430.242131] ksoftirqd/0     S14664     9      2 0x80000000
[  430.257645] rcu_sched       I14360    10      2 0x80000000
[  430.271300] rcu_bh          I15192    11      2 0x80000000
[  430.288804] migration/0     S14664    12      2 0x80000000
[  430.302736] cpuhp/0         S13920    14      2 0x80000000
[  430.316785] cpuhp/1         P13992    15      2 0x80000000
[  430.332349] migration/1     P14664    16      2 0x80000000
[  430.347965] ksoftirqd/1     P14656    17      2 0x80000000
[  430.363616] kworker/1:0     I13808    18      2 0x80000000
[  430.365571] Workqueue:            (null) (events)
[  430.379215] kworker/1:0H    I14648    19      2 0x80000000
[  430.381183] Workqueue:            (null) (kblockd)
[  430.394637] cpuhp/2         P13992    20      2 0x80000000
[  430.410289] migration/2     P14664    21      2 0x80000000
[  430.425871] ksoftirqd/2     P14664    22      2 0x80000000
[  430.441401] kworker/2:0H    I14480    24      2 0x80000000
[  430.443354] Workqueue:            (null) (xfs-log/sda1)
[  430.456923] cpuhp/3         P14056    25      2 0x80000000
[  430.472692] migration/3     P14664    26      2 0x80000000
[  430.488439] ksoftirqd/3     P14600    27      2 0x80000000
[  430.504382] kworker/3:0H    I15192    29      2 0x80000000
[  430.518385] cpuhp/4         P13696    30      2 0x80000000
[  430.534771] migration/4     P14664    31      2 0x80000000
[  430.550345] ksoftirqd/4     P14664    32      2 0x80000000
[  430.565951] kworker/4:0H    I14808    34      2 0x80000000
[  430.567894] Workqueue:            (null) (kblockd)
[  430.581313] cpuhp/5         P13960    35      2 0x80000000
[  430.596904] migration/5     P14664    36      2 0x80000000
[  430.612501] ksoftirqd/5     P14664    37      2 0x80000000
[  430.628142] kworker/5:0H    I15184    39      2 0x80000000
[  430.641797] cpuhp/6         P14024    40      2 0x80000000
[  430.657356] migration/6     P14664    41      2 0x80000000
[  430.672944] ksoftirqd/6     P14600    42      2 0x80000000
[  430.688512] kworker/6:0H    I14616    44      2 0x80000000
[  430.690475] Workqueue:            (null) (kblockd)
[  430.704778] cpuhp/7         P13992    45      2 0x80000000
[  430.721362] migration/7     P14664    46      2 0x80000000
[  430.737498] ksoftirqd/7     P14856    47      2 0x80000000
[  430.753602] kworker/7:0H    I14808    49      2 0x80000000
[  430.755618] Workqueue:            (null) (xfs-log/sda1)
[  430.769558] kdevtmpfs       S13552    50      2 0x80000000
[  430.784541] netns           I15152    51      2 0x80000000
[  430.798092] kauditd         S14640    53      2 0x80000000
[  430.816061] khungtaskd      S14368    54      2 0x80000000
[  430.832568] oom_reaper      S14464    55      2 0x80000000
[  430.847090] writeback       I15152    56      2 0x80000000
[  430.860445] kcompactd0      S14856    57      2 0x80000000
[  430.875004] ksmd            S15032    58      2 0x80000000
[  430.894691] khugepaged      D13832    59      2 0x80000000
[  430.941897] crypto          I15192    60      2 0x80000000
[  430.955462] kintegrityd     I15152    61      2 0x80000000
[  430.970103] kblockd         I15192    62      2 0x80000000
[  430.985679] kworker/3:1     I14264    63      2 0x80000000
[  430.987830] Workqueue:            (null) (events)
[  431.006463] kworker/5:1     I13568    64      2 0x80000000
[  431.008721] Workqueue:            (null) (events)
[  431.022691] kworker/0:2     I13104    65      2 0x80000000
[  431.024683] Workqueue:            (null) (cgroup_pidlist_destroy)
[  431.039039] md              I15152    66      2 0x80000000
[  431.052855] edac-poller     I15192    67      2 0x80000000
[  431.066622] devfreq_wq      I15152    68      2 0x80000000
[  431.082179] watchdogd       S15192    69      2 0x80000000
[  431.099273] kworker/2:1     I13848    70      2 0x80000000
[  431.101428] Workqueue:            (null) (cgroup_pidlist_destroy)
[  431.115249] kswapd0         S11528    71      2 0x80000000
[  431.130196] kworker/4:1     I13976    82      2 0x80000000
[  431.132110] Workqueue:            (null) (events)
[  431.145382] kthrotld        I14712    88      2 0x80000000
[  431.159018] kworker/6:1     I14280    89      2 0x80000000
[  431.160998] Workqueue:            (null) (events)
[  431.174300] kworker/7:1     I13976    90      2 0x80000000
[  431.176275] Workqueue:            (null) (events_power_efficient)
[  431.190169] acpi_thermal_pm I14856    91      2 0x80000000
[  431.204078] kmpath_rdacd    I15176    93      2 0x80000000
[  431.218355] kaluad          I14712    94      2 0x80000000
[  431.232512] nvme-wq         I14712    95      2 0x80000000
[  431.246066] nvme-reset-wq   I14712    96      2 0x80000000
[  431.259655] nvme-delete-wq  I15176    97      2 0x80000000
[  431.273200] ipv6_addrconf   I15176   100      2 0x80000000
[  431.287563] kworker/5:2     I14728   134      2 0x80000000
[  431.289707] Workqueue:            (null) (events)
[  431.303527] kworker/2:2     I13952   156      2 0x80000000
[  431.305447] Workqueue:            (null) (events)
[  431.318965] kworker/6:2     I14264   158      2 0x80000000
[  431.320882] Workqueue:            (null) (events)
[  431.334236] kworker/4:2     I14648   200      2 0x80000000
[  431.336153] Workqueue:            (null) (cgroup_pidlist_destroy)
[  431.349824] kworker/3:2     I14728   251      2 0x80000000
[  431.351745] Workqueue:            (null) (cgroup_pidlist_destroy)
[  431.365438] kworker/7:2     I13520   282      2 0x80000000
[  431.367360] Workqueue:            (null) (events)
[  431.383306] ata_sff         I15152   284      2 0x80000000
[  431.397949] scsi_eh_0       S14504   285      2 0x80000000
[  431.418707] scsi_tmf_0      I14952   286      2 0x80000000
[  431.432417] scsi_eh_1       S13560   287      2 0x80000000
[  431.449499] scsi_tmf_1      I14952   288      2 0x80000000
[  431.463159] mpt_poll_0      I15152   289      2 0x80000000
[  431.477194] mpt/0           I14952   290      2 0x80000000
[  431.491369] scsi_eh_2       S13320   291      2 0x80000000
[  431.509148] scsi_tmf_2      I15152   292      2 0x80000000
[  431.523419] scsi_eh_3       S13656   293      2 0x80000000
[  431.540836] scsi_tmf_3      I15152   294      2 0x80000000
[  431.554526] scsi_eh_4       S13656   295      2 0x80000000
[  431.573951] scsi_tmf_4      I15176   296      2 0x80000000
[  431.590636] scsi_eh_5       S13320   297      2 0x80000000
[  431.610073] scsi_tmf_5      I15152   298      2 0x80000000
[  431.625309] scsi_eh_6       S13320   299      2 0x80000000
[  431.645255] scsi_tmf_6      I15152   300      2 0x80000000
[  431.660850] ttm_swap        I15176   301      2 0x80000000
[  431.676590] scsi_eh_7       S13320   302      2 0x80000000
[  431.696192] scsi_tmf_7      I15064   303      2 0x80000000
[  431.711927] scsi_eh_8       S13320   304      2 0x80000000
[  431.731901] scsi_tmf_8      I14856   305      2 0x80000000
[  431.747401] scsi_eh_9       S13656   306      2 0x80000000
[  431.767158] scsi_tmf_9      I15152   307      2 0x80000000
[  431.782141] irq/16-vmwgfx   S14784   308      2 0x80000000
[  431.801432] scsi_eh_10      S13320   309      2 0x80000000
[  431.819869] scsi_tmf_10     I15152   310      2 0x80000000
[  431.834047] scsi_eh_11      S13320   311      2 0x80000000
[  431.851641] scsi_tmf_11     I15176   312      2 0x80000000
[  431.865316] scsi_eh_12      S13656   313      2 0x80000000
[  431.882579] scsi_tmf_12     I15152   314      2 0x80000000
[  431.896275] scsi_eh_13      S13656   315      2 0x80000000
[  431.913545] scsi_tmf_13     I15032   316      2 0x80000000
[  431.927339] scsi_eh_14      S13624   317      2 0x80000000
[  431.944787] scsi_tmf_14     I15176   318      2 0x80000000
[  431.958953] scsi_eh_15      S15192   319      2 0x80000000
[  431.977842] scsi_tmf_15     I15176   320      2 0x80000000
[  431.991927] scsi_eh_16      S13656   321      2 0x80000000
[  432.009353] scsi_tmf_16     I15032   322      2 0x80000000
[  432.023012] scsi_eh_17      S13320   323      2 0x80000000
[  432.040219] scsi_tmf_17     I15152   324      2 0x80000000
[  432.053920] scsi_eh_18      S13320   325      2 0x80000000
[  432.071121] scsi_tmf_18     I15152   326      2 0x80000000
[  432.084940] scsi_eh_19      S13320   327      2 0x80000000
[  432.102554] scsi_tmf_19     I14952   328      2 0x80000000
[  432.116239] scsi_eh_20      S13320   329      2 0x80000000
[  432.133434] scsi_tmf_20     I14856   330      2 0x80000000
[  432.147092] scsi_eh_21      S13624   331      2 0x80000000
[  432.164292] scsi_tmf_21     I15152   332      2 0x80000000
[  432.179198] scsi_eh_22      S13320   333      2 0x80000000
[  432.197105] scsi_tmf_22     I15176   334      2 0x80000000
[  432.211388] scsi_eh_23      S13656   335      2 0x80000000
[  432.228948] scsi_tmf_23     I14984   336      2 0x80000000
[  432.242745] scsi_eh_24      S13320   337      2 0x80000000
[  432.260114] scsi_tmf_24     I15176   338      2 0x80000000
[  432.273909] scsi_eh_25      S13624   339      2 0x80000000
[  432.292257] scsi_tmf_25     I14984   340      2 0x80000000
[  432.306667] scsi_eh_26      S13624   341      2 0x80000000
[  432.324014] scsi_tmf_26     I14984   342      2 0x80000000
[  432.337927] scsi_eh_27      S13656   343      2 0x80000000
[  432.355175] scsi_tmf_27     I14984   344      2 0x80000000
[  432.368970] scsi_eh_28      S13656   345      2 0x80000000
[  432.386277] scsi_tmf_28     I15152   346      2 0x80000000
[  432.400001] scsi_eh_29      S13656   348      2 0x80000000
[  432.417628] scsi_tmf_29     I15152   349      2 0x80000000
[  432.431300] scsi_eh_30      S13656   350      2 0x80000000
[  432.448517] scsi_tmf_30     I15152   351      2 0x80000000
[  432.462367] scsi_eh_31      S13008   352      2 0x80000000
[  432.480180] scsi_tmf_31     I14856   353      2 0x80000000
[  432.494334] scsi_eh_32      S13624   354      2 0x80000000
[  432.512183] scsi_tmf_32     I15152   355      2 0x80000000
[  432.526539] kworker/u256:30 I12872   384      2 0x80000000
[  432.528477] Workqueue:            (null) (events_unbound)
[  432.542276] kworker/u256:31 I10848   385      2 0x80000000
[  432.544216] Workqueue:            (null) (flush-8:0)
[  432.557869] kworker/1:2     I14728   411      2 0x80000000
[  432.559806] Workqueue:            (null) (cgroup_pidlist_destroy)
[  432.573637] kworker/6:1H    I15144   414      2 0x80000000
[  432.575578] Workqueue:            (null) (kblockd)
[  432.589008] xfsalloc        I15176   419      2 0x80000000
[  432.602765] xfs_mru_cache   I15176   420      2 0x80000000
[  432.616433] xfs-buf/sda1    I15176   421      2 0x80000000
[  432.630080] xfs-data/sda1   I15176   422      2 0x80000000
[  432.643719] xfs-conv/sda1   I15176   423      2 0x80000000
[  432.657334] xfs-cil/sda1    I15176   424      2 0x80000000
[  432.670935] xfs-reclaim/sda I15152   425      2 0x80000000
[  432.684559] xfs-log/sda1    I15176   426      2 0x80000000
[  432.698196] xfs-eofblocks/s I15176   427      2 0x80000000
[  432.712330] xfsaild/sda1    S13560   428      2 0x80000000
[  432.729342] kworker/7:1H    I14648   429      2 0x80000000
[  432.731277] Workqueue:            (null) (kblockd)
[  432.745674] kworker/1:1H    I14648   497      2 0x80000000
[  432.759743] systemd-journal D12600   498      1 0x00000000
[  432.815707] systemd-udevd   S12648   529      1 0x00000000
[  432.854484] auditd          D12808   546      1 0x00000000
[  432.928413] auditd          S13584   547      1 0x00000000
[  432.967315] kworker/4:1H    I15184   552      2 0x80000080
[  432.969349] Workqueue:            (null) (kblockd)
[  432.983507] polkitd         S12536   593      1 0x00000080
[  433.040141] gmain           S14032   604      1 0x00000080
[  433.103106] gdbus           S13760   605      1 0x00000080
[  433.154604] JS GC Helper    S14696   611      1 0x00000080
[  433.196161] JS Sour~ Thread S14696   616      1 0x00000080
[  433.240104] polkitd         S14200   621      1 0x00000080
[  433.299587] irqbalance      D12904   594      1 0x80000080
[  433.367588] avahi-daemon    S12632   597      1 0x00000080
[  433.417623] dbus-daemon     S12632   598      1 0x00000080
[  433.451459] avahi-daemon    S12888   603    597 0x00000080
[  433.499393] abrtd           S12488   606      1 0x00000080
[  433.562968] systemd-logind  D12904   608      1 0x00000080
[  433.632571] atd             S12728   612      1 0x00000080
[  433.668235] crond           D12536   614      1 0x00000080
[  433.737767] ksmtuned        S13312   619      1 0x00000080
[  433.775017] firewalld       S12456   623      1 0x00000080
[  433.828076] gmain           S14248   756      1 0x00000080
[  433.885072] NetworkManager  D11816   662      1 0x00000080
[  433.954132] gmain           D12544   669      1 0x00000080
[  434.023109] gdbus           S13432   672      1 0x00000080
[  434.073500] kworker/0:1H    I14096   742      2 0x80000080
[  434.075444] Workqueue:            (null) (kblockd)
[  434.088969] dhclient        S12328   759    662 0x00000080
[  434.157035] kworker/2:1H    I14480   768      2 0x80000080
[  434.159035] Workqueue:            (null) (xfs-log/sda1)
[  434.172628] tuned           S12552   949      1 0x00000080
[  434.240578] gmain           S14248   995      1 0x00000080
[  434.300681] tuned           D12328   996      1 0x80000080
[  434.369863] tuned           S14408   997      1 0x00000080
[  434.407096] tuned           S14248  1011      1 0x00000080
[  434.464385] smbd            S11288   951      1 0x00000080
[  434.502579] sshd            S12552   952      1 0x00000080
[  434.574892] rsyslogd        S12696   954      1 0x00000080
[  434.644123] in:imjournal    D12048   965      1 0x80000080
[  434.711494] rs:main Q:Reg   S12792   966      1 0x00000080
[  434.746928] sendmail        D13176   967      1 0x00000080
[  434.816872] kworker/0:3     I13376   977      2 0x80000080
[  434.818821] Workqueue:            (null) (ata_sff)
[  434.832423] agetty          S12904   989      1 0x00000080
[  434.877203] login           S12488   990      1 0x00000080
[  434.917384] sendmail        S14256   991      1 0x00000080
[  434.947588] smbd-notifyd    D12792  1012    951 0x00000080
[  435.021389] cleanupd        D13144  1013    951 0x00000080
[  435.094050] lpqd            S12888  1016    951 0x00000080
[  435.133174] bash            S12656  1019    990 0x00000080
[  435.172224] sleep           D12808  1614    619 0x00000080

>>>
>>> I do not mind this change per se but I am not happy about _your_ changelog.
>>> It doesn't explain the underlying problem IMHO. Having a natural and
>>> unconditional scheduling point in should_reclaim_retry is a reasonable
>>> thing. But how the hack it relates to the livelock you are seeing. So
>>> namely the changelog should explain
>>> 1) why nobody is able to make forward progress during direct reclaim
>>
>> Because GFP_NOIO allocation from one workqueue prevented WQ_MEM_RECLAIM
>> workqueues from starting, for it did not call schedule_timeout_*() because
>> mutex_trylock(&oom_lock) did not fail because nobody else could call
>> __alloc_pages_may_oom().
> 
> Why hasn't the rescuer helped here?

Rescuer does not work without schedule_timeout_*().

> 
>>> 2) why nobody is able to trigger oom killer as the last resort
>>
>> Because only one !__GFP_FS allocating thread which did not get stuck at
>> direct reclaim was able to call __alloc_pages_may_oom().
> 
> All the remaining allocations got stuck waiting for completion which
> depends on !WQ_MEM_RECLAIM workers right?
> 

A !WQ_MEM_RECLAIM worker did not call schedule_timeout_*() is preventing
anyone who is waiting for WQ_MEM_RECLAIM workers from making progress.
