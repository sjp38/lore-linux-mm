Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A93FD6B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 01:33:45 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d18so119732831pgh.2
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 22:33:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y22si11935336pli.233.2017.02.25.22.33.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 25 Feb 2017 22:33:44 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170221094034.GF15595@dhcp22.suse.cz>
	<201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp>
	<20170221155337.GK15595@dhcp22.suse.cz>
	<201702221102.EHH69234.OQLOMFSOtJFVHF@I-love.SAKURA.ne.jp>
	<20170222075450.GA5753@dhcp22.suse.cz>
In-Reply-To: <20170222075450.GA5753@dhcp22.suse.cz>
Message-Id: <201702261530.JDD56292.OFOLFHQtVMJSOF@I-love.SAKURA.ne.jp>
Date: Sun, 26 Feb 2017 15:30:57 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 22-02-17 11:02:21, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 21-02-17 23:35:07, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > OK, so it seems that all the distractions are handled now and linux-next
> > > > > should provide a reasonable base for testing. You said you weren't able
> > > > > to reproduce the original long stalls on too_many_isolated(). I would be
> > > > > still interested to see those oom reports and potential anomalies in the
> > > > > isolated counts before I send the patch for inclusion so your further
> > > > > testing would be more than appreciated. Also stalls > 10s without any
> > > > > previous occurrences would be interesting.
> > > > 
> > > > I confirmed that linux-next-20170221 with kmallocwd applied can reproduce
> > > > infinite too_many_isolated() loop problem. Please send your patches to linux-next.
> > > 
> > > So I assume that you didn't see the lockup with the patch applied and
> > > the OOM killer has resolved the situation by killing other tasks, right?
> > > Can I assume your Tested-by?
> > 
> > No. I tested linux-next-20170221 which does not include your patch.
> > I didn't test linux-next-20170221 with your patch applied. Your patch will
> > avoid infinite too_many_isolated() loop problem in shrink_inactive_list().
> > But we need to test different workloads by other people. Thus, I suggest
> > you to send your patches to linux-next without my testing.
> 
> I will send the patch to Andrew later after merge window closes. It
> would be really helpful, though, to see how it handles your workload
> which is known to reproduce the oom starvation.

I tested http://lkml.kernel.org/r/20170119112336.GN30786@dhcp22.suse.cz
on top of linux-next-20170221 with kmallocwd applied.

I did not hit too_many_isolated() loop problem. But I hit an "unable to invoke
the OOM killer due to !__GFP_FS allocation" lockup problem shown below.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170226.txt.xz .
----------
[  444.281177] Killed process 9477 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  444.287046] oom_reaper: reaped process 9477 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  484.810225] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 38s!
[  484.812907] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 41s!
[  484.815546] Showing busy workqueues and worker pools:
[  484.817595] workqueue events: flags=0x0
[  484.819456]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=3/256
[  484.821666]     pending: vmpressure_work_fn, vmstat_shepherd, vmw_fb_dirty_flush [vmwgfx]
[  484.824356]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  484.826582]     pending: drain_local_pages_wq BAR(9595), e1000_watchdog [e1000]
[  484.829091]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  484.831325]     in-flight: 7418:rht_deferred_worker
[  484.833336]     pending: rht_deferred_worker
[  484.835346] workqueue events_long: flags=0x0
[  484.837343]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  484.839566]     pending: gc_worker [nf_conntrack]
[  484.841691] workqueue events_power_efficient: flags=0x80
[  484.843873]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  484.846103]     pending: fb_flashcursor
[  484.847928]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  484.850149]     pending: neigh_periodic_work, neigh_periodic_work
[  484.852403] workqueue events_freezable_power_: flags=0x84
[  484.854534]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  484.856666]     in-flight: 27:disk_events_workfn
[  484.858621] workqueue writeback: flags=0x4e
[  484.860347]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  484.862415]     in-flight: 8444:wb_workfn wb_workfn
[  484.864602] workqueue vmstat: flags=0xc
[  484.866291]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  484.868307]     pending: vmstat_update
[  484.869876]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  484.871864]     pending: vmstat_update
[  484.874058] workqueue mpt_poll_0: flags=0x8
[  484.875698]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  484.877602]     pending: mpt_fault_reset_work [mptbase]
[  484.879502] workqueue xfs-buf/sda1: flags=0xc
[  484.881148]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/1
[  484.883011]     pending: xfs_buf_ioend_work [xfs]
[  484.884706] workqueue xfs-data/sda1: flags=0xc
[  484.886367]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=27/256 MAYDAY
[  484.888410]     in-flight: 5356:xfs_end_io [xfs], 451(RESCUER):xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs], 10498:xfs_end_io [xfs], 6386:xfs_end_io [xfs]
[  484.893483]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  484.902636]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=21/256 MAYDAY
[  484.904848]     in-flight: 535:xfs_end_io [xfs], 7416:xfs_end_io [xfs], 7415:xfs_end_io [xfs], 65:xfs_end_io [xfs]
[  484.907863]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  484.916767]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=4/256 MAYDAY
[  484.919024]     in-flight: 5357:xfs_end_io [xfs], 193:xfs_end_io [xfs], 52:xfs_end_io [xfs], 5358:xfs_end_io [xfs]
[  484.922143]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  484.924291]     in-flight: 2486:xfs_end_io [xfs]
[  484.926248] workqueue xfs-reclaim/sda1: flags=0xc
[  484.928216]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  484.930362]     pending: xfs_reclaim_worker [xfs]
[  484.932312] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3 6387
[  484.934766] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=38s workers=6 manager: 19
[  484.937206] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=41s workers=6 manager: 157
[  484.939629] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=41s workers=4 manager: 10499
[  484.942303] pool 256: cpus=0-127 flags=0x4 nice=0 hung=38s workers=3 idle: 425 426
[  518.090012] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=8441307
(...snipped...)
[  518.900038] MemAlloc: kswapd0(69) flags=0xa40840 switches=23883 uninterruptible
[  518.902095] kswapd0         D10776    69      2 0x00000000
[  518.903784] Call Trace:
[  518.904849]  __schedule+0x336/0xe00
[  518.906118]  schedule+0x3d/0x90
[  518.907314]  io_schedule+0x16/0x40
[  518.908622]  __xfs_iflock+0x129/0x140 [xfs]
[  518.910027]  ? autoremove_wake_function+0x60/0x60
[  518.911559]  xfs_reclaim_inode+0x162/0x440 [xfs]
[  518.913068]  xfs_reclaim_inodes_ag+0x2cf/0x4f0 [xfs]
[  518.914611]  ? xfs_reclaim_inodes_ag+0xf2/0x4f0 [xfs]
[  518.916148]  ? trace_hardirqs_on+0xd/0x10
[  518.917465]  ? try_to_wake_up+0x59/0x7a0
[  518.918758]  ? wake_up_process+0x15/0x20
[  518.920067]  xfs_reclaim_inodes_nr+0x33/0x40 [xfs]
[  518.921560]  xfs_fs_free_cached_objects+0x19/0x20 [xfs]
[  518.923114]  super_cache_scan+0x181/0x190
[  518.924435]  shrink_slab+0x29f/0x6d0
[  518.925683]  shrink_node+0x2fa/0x310
[  518.926909]  kswapd+0x362/0x9b0
[  518.928061]  kthread+0x10f/0x150
[  518.929218]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
[  518.930953]  ? kthread_create_on_node+0x70/0x70
[  518.932380]  ret_from_fork+0x31/0x40
(...snipped...)
[  553.070829] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=10318507
[  575.432697] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 129s!
[  575.435276] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 131s!
[  575.437863] Showing busy workqueues and worker pools:
[  575.439837] workqueue events: flags=0x0
[  575.441605]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  575.443717]     pending: vmpressure_work_fn, vmstat_shepherd, vmw_fb_dirty_flush [vmwgfx], check_corruption
[  575.446622]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  575.448763]     pending: drain_local_pages_wq BAR(9595), e1000_watchdog [e1000]
[  575.451173]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  575.453323]     in-flight: 7418:rht_deferred_worker
[  575.455243]     pending: rht_deferred_worker
[  575.457100] workqueue events_long: flags=0x0
[  575.458960]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  575.461099]     pending: gc_worker [nf_conntrack]
[  575.463043] workqueue events_power_efficient: flags=0x80
[  575.465110]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  575.467252]     pending: fb_flashcursor
[  575.468966]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  575.471109]     pending: neigh_periodic_work, neigh_periodic_work
[  575.473289] workqueue events_freezable_power_: flags=0x84
[  575.475378]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.477526]     in-flight: 27:disk_events_workfn
[  575.479489] workqueue writeback: flags=0x4e
[  575.481257]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  575.483368]     in-flight: 8444:wb_workfn wb_workfn
[  575.485505] workqueue vmstat: flags=0xc
[  575.487196]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  575.489242]     pending: vmstat_update
[  575.491403] workqueue mpt_poll_0: flags=0x8
[  575.493106]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.495115]     pending: mpt_fault_reset_work [mptbase]
[  575.497086] workqueue xfs-buf/sda1: flags=0xc
[  575.498764]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/1
[  575.500654]     pending: xfs_buf_ioend_work [xfs]
[  575.502372] workqueue xfs-data/sda1: flags=0xc
[  575.504024]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=27/256 MAYDAY
[  575.506060]     in-flight: 5356:xfs_end_io [xfs], 451(RESCUER):xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs], 10498:xfs_end_io [xfs], 6386:xfs_end_io [xfs]
[  575.511096]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  575.520157]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=21/256 MAYDAY
[  575.522340]     in-flight: 535:xfs_end_io [xfs], 7416:xfs_end_io [xfs], 7415:xfs_end_io [xfs], 65:xfs_end_io [xfs]
[  575.525387]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  575.534089]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=4/256 MAYDAY
[  575.536407]     in-flight: 5357:xfs_end_io [xfs], 193:xfs_end_io [xfs], 52:xfs_end_io [xfs], 5358:xfs_end_io [xfs]
[  575.539496]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  575.541648]     in-flight: 2486:xfs_end_io [xfs]
[  575.543591] workqueue xfs-reclaim/sda1: flags=0xc
[  575.545540]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  575.547675]     pending: xfs_reclaim_worker [xfs]
[  575.549719] workqueue xfs-log/sda1: flags=0x1c
[  575.551591]   pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
[  575.553750]     pending: xfs_log_worker [xfs]
[  575.555552] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3 6387
[  575.557979] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=129s workers=6 manager: 19
[  575.560399] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=131s workers=6 manager: 157
[  575.562843] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=132s workers=4 manager: 10499
[  575.565450] pool 256: cpus=0-127 flags=0x4 nice=0 hung=129s workers=3 idle: 425 426
(...snipped...)
[  616.394649] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=13908219
(...snipped...)
[  642.266252] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=15180673
(...snipped...)
[  702.412189] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=18732529
(...snipped...)
[  736.787879] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=20565244
(...snipped...)
[  800.715759] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=24411576
(...snipped...)
[  837.571405] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=26463562
(...snipped...)
[  899.021495] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=30144879
(...snipped...)
[  936.282709] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=32129234
(...snipped...)
[  997.328119] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=35657983
(...snipped...)
[ 1033.977265] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=37659912
(...snipped...)
[ 1095.630961] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40639677
(...snipped...)
[ 1095.632984] MemAlloc: kswapd0(69) flags=0xa40840 switches=23883 uninterruptible
[ 1095.632985] kswapd0         D10776    69      2 0x00000000
[ 1095.632988] Call Trace:
[ 1095.632991]  __schedule+0x336/0xe00
[ 1095.632994]  schedule+0x3d/0x90
[ 1095.632996]  io_schedule+0x16/0x40
[ 1095.633017]  __xfs_iflock+0x129/0x140 [xfs]
[ 1095.633021]  ? autoremove_wake_function+0x60/0x60
[ 1095.633051]  xfs_reclaim_inode+0x162/0x440 [xfs]
[ 1095.633072]  xfs_reclaim_inodes_ag+0x2cf/0x4f0 [xfs]
[ 1095.633106]  ? xfs_reclaim_inodes_ag+0xf2/0x4f0 [xfs]
[ 1095.633114]  ? trace_hardirqs_on+0xd/0x10
[ 1095.633116]  ? try_to_wake_up+0x59/0x7a0
[ 1095.633120]  ? wake_up_process+0x15/0x20
[ 1095.633156]  xfs_reclaim_inodes_nr+0x33/0x40 [xfs]
[ 1095.633178]  xfs_fs_free_cached_objects+0x19/0x20 [xfs]
[ 1095.633180]  super_cache_scan+0x181/0x190
[ 1095.633183]  shrink_slab+0x29f/0x6d0
[ 1095.633189]  shrink_node+0x2fa/0x310
[ 1095.633193]  kswapd+0x362/0x9b0
[ 1095.633200]  kthread+0x10f/0x150
[ 1095.633201]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
[ 1095.633202]  ? kthread_create_on_node+0x70/0x70
[ 1095.633205]  ret_from_fork+0x31/0x40
(...snipped...)
[ 1095.821248] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40646791
(...snipped...)
[ 1125.236970] sysrq: SysRq : Resetting
[ 1125.238669] ACPI MEMORY or I/O RESET_REG.
----------

The switches= value (which is "struct task_struct"->nvcsw +
"struct task_struct"->nivcsw ) of kswapd0(69) remained 23883 which means that
kswapd0 was waiting forever at

----------
void
__xfs_iflock(
        struct xfs_inode        *ip)
{
        wait_queue_head_t *wq = bit_waitqueue(&ip->i_flags, __XFS_IFLOCK_BIT);
        DEFINE_WAIT_BIT(wait, &ip->i_flags, __XFS_IFLOCK_BIT);

        do {
                prepare_to_wait_exclusive(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
                if (xfs_isiflocked(ip))
                        io_schedule();      /***** <= This location. *****/
        } while (!xfs_iflock_nowait(ip));

        finish_wait(wq, &wait.wait);
}
----------

while the oom_count= value (which is number of times out_of_memory() was called)
was increasing over time without emitting "Killed process " message.

Reproducer I used is shown below.

----------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <poll.h>

static char use_delay = 0;

static void sigcld_handler(int unused)
{
        use_delay = 1;
}

int main(int argc, char *argv[])
{
        static char buffer[4096] = { };
        char *buf = NULL;
        unsigned long size;
        int i;
        signal(SIGCLD, sigcld_handler);
        for (i = 0; i < 1024; i++) {
                if (fork() == 0) {
                        int fd = open("/proc/self/oom_score_adj", O_WRONLY);
                        write(fd, "1000", 4);
                        close(fd);
                        sleep(1);
                        if (!i)
                                pause();
                        snprintf(buffer, sizeof(buffer), "/tmp/file.%u", getpid());
                        fd = open(buffer, O_WRONLY | O_CREAT | O_APPEND, 0600);
                        while (write(fd, buffer, sizeof(buffer)) == sizeof(buffer)) {
                                poll(NULL, 0, 10);
                                fsync(fd);
                        }
                        _exit(0);
                }
        }
        for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size >>= 1;
                        break;
                }
                buf = cp;
        }
        sleep(2);
        /* Will cause OOM due to overcommit */
        for (i = 0; i < size; i += 4096)
                buf[i] = 0;
        pause();
        return 0;
}
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
