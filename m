Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0946F280911
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:20:21 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id r141so7833115ita.6
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 03:20:21 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w10si1816303itf.37.2017.03.10.03.20.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 03:20:19 -0800 (PST)
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
	<20170309143751.05bddcbad82672384947de5f@linux-foundation.org>
	<20170310104047.GF3753@dhcp22.suse.cz>
In-Reply-To: <20170310104047.GF3753@dhcp22.suse.cz>
Message-Id: <201703102019.JHJ58283.MQHtVFOOFOLFJS@I-love.SAKURA.ne.jp>
Date: Fri, 10 Mar 2017 20:19:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru

Andrew Morton wrote:
> On Thu, 9 Mar 2017 19:46:14 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > Tetsuo Handa wrote:
> > > This patch adds a watchdog which periodically reports number of memory
> > > allocating tasks, dying tasks and OOM victim tasks when some task is
> > > spending too long time inside __alloc_pages_slowpath(). This patch also
> > > serves as a hook for obtaining additional information using SystemTap
> > > (e.g. examine other variables using printk(), capture a crash dump by
> > > calling panic()) by triggering a callback only when a stall is detected.
> > > Ability to take administrator-controlled actions based on some threshold
> > > is a big advantage gained by introducing a state tracking.
> > > 
> > > Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
> > > too long") was a great step for reducing possibility of silent hang up
> > > problem caused by memory allocation stalls [1]. However, there are
> > > reports of long stalls (e.g. [2] is over 30 minutes!) and lockups (e.g.
> > > [3] is an "unable to invoke the OOM killer due to !__GFP_FS allocation"
> > > lockup problem) where this patch is more useful than that commit, for
> > > this patch can report possibly related tasks even if allocating tasks
> > > are unexpectedly blocked for so long. Regarding premature OOM killer
> > > invocation, tracepoints which can accumulate samples in short interval
> > > would be useful. But regarding too late to report allocation stalls,
> > > this patch which can capture all tasks (for reporting overall situation)
> > > in longer interval and act as a trigger (for accumulating short interval
> > > samples) would be useful.
> )
> > Andrew, do you have any questions on this patch?
> > I really need this patch for finding bugs which MM people overlook.
> 
> Undecided.  I can see the need but it is indeed quite a large lump of
> code.  Perhaps some additional examples of how this new code was used
> to understand and improve real-world kernel problems would be persuasive.

This patch is aimed for help bisecting whether unexpected hung cases are related to
memory allocation. By merging this patch (and enabling this watchdog in enterprise
systems via kernels supported by distributors), we can identify patterns/cases of
problems (if related to memory allocation) and improve quality of Linux kernels
by fixing problems related to memory allocation.

I was working at a support center for 3 years and had many cases where Linux
systems encountered unexpected silent hangup/reboot problem. In most cases, all
clue available was limited to sar (in sysstat package) showing that free memory
was low just before unexpected hung/reboot.

As a nature of such problems, it is very hard for administrators to collect
information for analysis; let alone identify the cause of problems. As a result,
such problems are left unrecognized/unsolved at the support center, and are
seldom reported to distributors/developers in order to ask for fixes.

Michal Hocko wrote:
> Well, it is true that the watchdog can provide much more information
> than we can gather with other debugging options we currently have when
> allocations run away.  So I am not questioning this is useful when doing
> memory stress testing and trying to trigger corner cases but I am not
> really sure how much this will be useful in production systems, though.
> Tracking is not for free both in runtime and longterm in maintenance.

I don't think that my stress testing is hitting bugs which do not occur in
production systems. But I can't prove it without using watchdog mechanism.
Today I heard about a case where an enterprise system hung last Sunday due to
XFS deadlock by memory allocation. This was rather a lucky case where
administrator of that system was able to capture vmcore. In most cases,
administrators can't capture even SysRq-t; let alone vmcore. Therefore,
automatic watchdog is highly appreciated.



Or, did you mean "some additional examples of how this new code was used
to understand and improve real-world kernel problems" as how this patch
helped in [2] [3] ?

Regarding [3] (now continued as
http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp ),
I used this patch for confirming the following things.

  (1) kswapd cannot make progress waiting for lock.

----------
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
----------

  (2) All WQ_MEM_RECLAIM threads shown by show_workqueue_state()
      cannot make progress waiting for memory allocation.

----------
[ 1095.633625] MemAlloc: xfs-data/sda1(451) flags=0x4228060 switches=45509 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652073
[ 1095.633626] xfs-data/sda1   R  running task    12696   451      2 0x00000000
[ 1095.633663] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.633665] Call Trace:
[ 1095.633668]  __schedule+0x336/0xe00
[ 1095.633671]  schedule+0x3d/0x90
[ 1095.633672]  schedule_timeout+0x20d/0x510
[ 1095.633675]  ? lock_timer_base+0xa0/0xa0
[ 1095.633678]  schedule_timeout_uninterruptible+0x2a/0x30
[ 1095.633680]  __alloc_pages_slowpath+0x2b5/0xd95
[ 1095.633687]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.633699]  alloc_pages_current+0x97/0x1b0
[ 1095.633702]  new_slab+0x4cb/0x6b0
[ 1095.633706]  ___slab_alloc+0x3a3/0x620
[ 1095.633728]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.633730]  ? ___slab_alloc+0x5c6/0x620
[ 1095.633732]  ? cpuacct_charge+0x38/0x1e0
[ 1095.633767]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.633770]  __slab_alloc+0x46/0x7d
[ 1095.633773]  __kmalloc+0x301/0x3b0
[ 1095.633802]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.633804]  ? kfree+0x1fa/0x330
[ 1095.633842]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.633864]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.633883]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.633901]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.633936]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.633954]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.633971]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.633973]  process_one_work+0x22b/0x760
[ 1095.633975]  ? process_one_work+0x194/0x760
[ 1095.633997]  rescuer_thread+0x1f2/0x3d0
[ 1095.634002]  kthread+0x10f/0x150
[ 1095.634003]  ? worker_thread+0x4b0/0x4b0
[ 1095.634004]  ? kthread_create_on_node+0x70/0x70
[ 1095.634007]  ret_from_fork+0x31/0x40
[ 1095.634013] MemAlloc: xfs-eofblocks/s(456) flags=0x4228860 switches=15435 seq=1 gfp=0x1400240(GFP_NOFS|__GFP_NOWARN) order=0 delay=293074
[ 1095.634014] xfs-eofblocks/s R  running task    12032   456      2 0x00000000
[ 1095.634037] Workqueue: xfs-eofblocks/sda1 xfs_eofblocks_worker [xfs]
[ 1095.634038] Call Trace:
[ 1095.634040]  ? _raw_spin_lock+0x3d/0x80
[ 1095.634042]  ? vmpressure+0xd0/0x120
[ 1095.634044]  ? vmpressure+0xd0/0x120
[ 1095.634047]  ? vmpressure_prio+0x21/0x30
[ 1095.634049]  ? do_try_to_free_pages+0x70/0x300
[ 1095.634052]  ? try_to_free_pages+0x131/0x3f0
[ 1095.634058]  ? __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.634065]  ? __alloc_pages_nodemask+0x3e4/0x460
[ 1095.634069]  ? alloc_pages_current+0x97/0x1b0
[ 1095.634111]  ? xfs_buf_allocate_memory+0x160/0x2a3 [xfs]
[ 1095.634133]  ? xfs_buf_get_map+0x2be/0x480 [xfs]
[ 1095.634169]  ? xfs_buf_read_map+0x2c/0x400 [xfs]
[ 1095.634204]  ? xfs_trans_read_buf_map+0x186/0x830 [xfs]
[ 1095.634222]  ? xfs_btree_read_buf_block.constprop.34+0x78/0xc0 [xfs]
[ 1095.634239]  ? xfs_btree_lookup_get_block+0x8a/0x180 [xfs]
[ 1095.634257]  ? xfs_btree_lookup+0xd0/0x3f0 [xfs]
[ 1095.634296]  ? kmem_zone_alloc+0x96/0x120 [xfs]
[ 1095.634299]  ? _raw_spin_unlock+0x27/0x40
[ 1095.634315]  ? xfs_bmbt_lookup_eq+0x1f/0x30 [xfs]
[ 1095.634348]  ? xfs_bmap_del_extent+0x1b2/0x1610 [xfs]
[ 1095.634380]  ? kmem_zone_alloc+0x96/0x120 [xfs]
[ 1095.634400]  ? __xfs_bunmapi+0x4db/0xda0 [xfs]
[ 1095.634421]  ? xfs_bunmapi+0x2b/0x40 [xfs]
[ 1095.634459]  ? xfs_itruncate_extents+0x1df/0x780 [xfs]
[ 1095.634502]  ? xfs_rename+0xc70/0x1080 [xfs]
[ 1095.634525]  ? xfs_free_eofblocks+0x1c4/0x230 [xfs]
[ 1095.634546]  ? xfs_inode_free_eofblocks+0x18d/0x280 [xfs]
[ 1095.634565]  ? xfs_inode_ag_walk.isra.13+0x2b5/0x620 [xfs]
[ 1095.634582]  ? xfs_inode_ag_walk.isra.13+0x91/0x620 [xfs]
[ 1095.634618]  ? xfs_inode_clear_eofblocks_tag+0x1a0/0x1a0 [xfs]
[ 1095.634630]  ? radix_tree_next_chunk+0x10b/0x2d0
[ 1095.634635]  ? radix_tree_gang_lookup_tag+0xd7/0x150
[ 1095.634672]  ? xfs_perag_get_tag+0x11d/0x370 [xfs]
[ 1095.634690]  ? xfs_perag_get_tag+0x5/0x370 [xfs]
[ 1095.634709]  ? xfs_inode_ag_iterator_tag+0x71/0xa0 [xfs]
[ 1095.634726]  ? xfs_inode_clear_eofblocks_tag+0x1a0/0x1a0 [xfs]
[ 1095.634744]  ? __xfs_icache_free_eofblocks+0x3b/0x40 [xfs]
[ 1095.634759]  ? xfs_eofblocks_worker+0x27/0x40 [xfs]
[ 1095.634762]  ? process_one_work+0x22b/0x760
[ 1095.634763]  ? process_one_work+0x194/0x760
[ 1095.634784]  ? rescuer_thread+0x1f2/0x3d0
[ 1095.634788]  ? kthread+0x10f/0x150
[ 1095.634789]  ? worker_thread+0x4b0/0x4b0
[ 1095.634790]  ? kthread_create_on_node+0x70/0x70
[ 1095.634793]  ? ret_from_fork+0x31/0x40
----------

  (3) order-0 GFP_NOIO allocation request cannot make progress
      waiting for memory allocation.

----------
[ 1095.631687] MemAlloc: kworker/2:0(27) flags=0x4208860 switches=38727 seq=21 gfp=0x1400000(GFP_NOIO) order=0 delay=652160
[ 1095.631688] kworker/2:0     R  running task    12680    27      2 0x00000000
[ 1095.631739] Workqueue: events_freezable_power_ disk_events_workfn
[ 1095.631740] Call Trace:
[ 1095.631743]  __schedule+0x336/0xe00
[ 1095.631746]  preempt_schedule_common+0x1f/0x31
[ 1095.631747]  _cond_resched+0x1c/0x30
[ 1095.631749]  shrink_slab+0x339/0x6d0
[ 1095.631754]  shrink_node+0x2fa/0x310
[ 1095.631758]  do_try_to_free_pages+0xe1/0x300
[ 1095.631761]  try_to_free_pages+0x131/0x3f0
[ 1095.631765]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.631771]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.631775]  alloc_pages_current+0x97/0x1b0
[ 1095.631779]  bio_copy_kern+0xc9/0x180
[ 1095.631830]  blk_rq_map_kern+0x70/0x140
[ 1095.631835]  __scsi_execute.isra.22+0x13a/0x1e0
[ 1095.631838]  scsi_execute_req_flags+0x94/0x100
[ 1095.631844]  sr_check_events+0xbf/0x2b0 [sr_mod]
[ 1095.631852]  cdrom_check_events+0x18/0x30 [cdrom]
[ 1095.631854]  sr_block_check_events+0x2a/0x30 [sr_mod]
[ 1095.631856]  disk_check_events+0x60/0x170
[ 1095.631859]  disk_events_workfn+0x1c/0x20
[ 1095.631862]  process_one_work+0x22b/0x760
[ 1095.631863]  ? process_one_work+0x194/0x760
[ 1095.631867]  worker_thread+0x137/0x4b0
[ 1095.631887]  kthread+0x10f/0x150
[ 1095.631889]  ? process_one_work+0x760/0x760
[ 1095.631890]  ? kthread_create_on_node+0x70/0x70
[ 1095.631893]  ret_from_fork+0x31/0x40
----------

  (4) Number of stalling threads does not decrease over time while
      number of out_of_memory() calls increases over time.

----------
[  518.090012] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=8441307
[  553.070829] MemAlloc-Info: stalling=184 dying=1 exiting=0 victim=1 oom_count=10318507
[  616.394649] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=13908219
[  642.266252] MemAlloc-Info: stalling=186 dying=1 exiting=0 victim=1 oom_count=15180673
[  702.412189] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=18732529
[  736.787879] MemAlloc-Info: stalling=187 dying=1 exiting=0 victim=1 oom_count=20565244
[  800.715759] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=24411576
[  837.571405] MemAlloc-Info: stalling=188 dying=1 exiting=0 victim=1 oom_count=26463562
[  899.021495] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=30144879
[  936.282709] MemAlloc-Info: stalling=189 dying=1 exiting=0 victim=1 oom_count=32129234
[  997.328119] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=35657983
[ 1033.977265] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=37659912
[ 1095.630961] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40639677
[ 1095.821248] MemAlloc-Info: stalling=190 dying=1 exiting=0 victim=1 oom_count=40646791
----------

Further interpretation is up to XFS people (Brian and Dave). So far, boosting priority
(lowering watermark) of WQ_MEM_RECLAIM threads based on current_is_workqueue_rescuer()
seems to be considered as a fix because writeback path already has a special case
handling for the rescuer. But I'm not sure whether it helps getting writeback unstuck
when writeback path is blocked on a lock rather than memory allocation. (Threads doing
writeback and/or mempool allocations might be candidates for always reporting as with
kswapd. That would be in followup patches.)

----------
[ 1044.701393] kworker/u256:0  D10024  8444      2 0x00000080
[ 1044.703017] Workqueue: writeback wb_workfn (flush-8:0)
[ 1044.704550] Call Trace:
[ 1044.705550]  __schedule+0x336/0xe00
[ 1044.706761]  schedule+0x3d/0x90
[ 1044.707891]  io_schedule+0x16/0x40
[ 1044.709073]  __lock_page+0x126/0x180
[ 1044.710272]  ? page_cache_tree_insert+0x120/0x120
[ 1044.711728]  write_cache_pages+0x39a/0x6b0
[ 1044.713077]  ? xfs_map_blocks+0x5a0/0x5a0 [xfs]
[ 1044.714499]  ? xfs_vm_writepages+0x48/0xa0 [xfs]
[ 1044.715944]  xfs_vm_writepages+0x6b/0xa0 [xfs]
[ 1044.717362]  do_writepages+0x21/0x40
[ 1044.718577]  __writeback_single_inode+0x72/0x9d0
[ 1044.719998]  ? _raw_spin_unlock+0x27/0x40
[ 1044.721308]  writeback_sb_inodes+0x322/0x750
[ 1044.722662]  __writeback_inodes_wb+0x8c/0xc0
[ 1044.724009]  wb_writeback+0x3be/0x6e0
[ 1044.725238]  wb_workfn+0x146/0x7d0
[ 1044.726413]  ? process_one_work+0x194/0x760
[ 1044.727736]  process_one_work+0x22b/0x760
[ 1044.729017]  ? process_one_work+0x194/0x760
[ 1044.730343]  worker_thread+0x137/0x4b0
[ 1044.731577]  kthread+0x10f/0x150
[ 1044.732702]  ? process_one_work+0x760/0x760
[ 1044.734021]  ? kthread_create_on_node+0x70/0x70
[ 1044.735415]  ? do_syscall_64+0x195/0x200
[ 1044.736684]  ret_from_fork+0x31/0x40
----------

Regarding "infinite too_many_isolated() loop" case
( http://lkml.kernel.org/r/201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp ),
I used this patch for confirming the following things.

  (1) kswapd cannot make progress waiting for lock.

----------
[ 1209.790966] MemAlloc: kswapd0(67) flags=0xa60840 switches=51139 uninterruptible
[ 1209.799726] kswapd0         D10936    67      2 0x00000000
[ 1209.807326] Call Trace:
[ 1209.812581]  __schedule+0x336/0xe00
[ 1209.818599]  schedule+0x3d/0x90
[ 1209.823907]  schedule_timeout+0x26a/0x510
[ 1209.827218]  ? trace_hardirqs_on+0xd/0x10
[ 1209.830535]  __down_common+0xfb/0x131
[ 1209.833801]  ? _xfs_buf_find+0x2cb/0xc10 [xfs]
[ 1209.837372]  __down+0x1d/0x1f
[ 1209.840331]  down+0x41/0x50
[ 1209.843243]  xfs_buf_lock+0x64/0x370 [xfs]
[ 1209.846597]  _xfs_buf_find+0x2cb/0xc10 [xfs]
[ 1209.850031]  ? _xfs_buf_find+0xa4/0xc10 [xfs]
[ 1209.853514]  xfs_buf_get_map+0x2a/0x480 [xfs]
[ 1209.855831]  xfs_buf_read_map+0x2c/0x400 [xfs]
[ 1209.857388]  ? free_debug_processing+0x27d/0x2af
[ 1209.859037]  xfs_trans_read_buf_map+0x186/0x830 [xfs]
[ 1209.860707]  xfs_read_agf+0xc8/0x2b0 [xfs]
[ 1209.862184]  xfs_alloc_read_agf+0x7a/0x300 [xfs]
[ 1209.863728]  ? xfs_alloc_space_available+0x7b/0x120 [xfs]
[ 1209.865385]  xfs_alloc_fix_freelist+0x3bc/0x490 [xfs]
[ 1209.866974]  ? __radix_tree_lookup+0x84/0xf0
[ 1209.868374]  ? xfs_perag_get+0x1a0/0x310 [xfs]
[ 1209.869798]  ? xfs_perag_get+0x5/0x310 [xfs]
[ 1209.871288]  xfs_alloc_vextent+0x161/0xda0 [xfs]
[ 1209.872757]  xfs_bmap_btalloc+0x46c/0x8b0 [xfs]
[ 1209.874182]  ? save_stack_trace+0x1b/0x20
[ 1209.875542]  xfs_bmap_alloc+0x17/0x30 [xfs]
[ 1209.876847]  xfs_bmapi_write+0x74e/0x11d0 [xfs]
[ 1209.878190]  xfs_iomap_write_allocate+0x199/0x3a0 [xfs]
[ 1209.879632]  xfs_map_blocks+0x2cc/0x5a0 [xfs]
[ 1209.880909]  xfs_do_writepage+0x215/0x920 [xfs]
[ 1209.882255]  ? clear_page_dirty_for_io+0xb4/0x310
[ 1209.883598]  xfs_vm_writepage+0x3b/0x70 [xfs]
[ 1209.884841]  pageout.isra.54+0x1a4/0x460
[ 1209.886210]  shrink_page_list+0xa86/0xcf0
[ 1209.887441]  shrink_inactive_list+0x1c5/0x660
[ 1209.888682]  shrink_node_memcg+0x535/0x7f0
[ 1209.889975]  ? mem_cgroup_iter+0x14d/0x720
[ 1209.891197]  shrink_node+0xe1/0x310
[ 1209.892288]  kswapd+0x362/0x9b0
[ 1209.893308]  kthread+0x10f/0x150
[ 1209.894383]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
[ 1209.895703]  ? kthread_create_on_node+0x70/0x70
[ 1209.896956]  ret_from_fork+0x31/0x40
----------

  (2) Both GFP_IO and GFP_KERNEL allocations are stuck at
      too_many_isolated() loop.

----------
[ 1209.898117] MemAlloc: systemd-journal(526) flags=0x400900 switches=33248 seq=121659 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=52772 uninterruptible
[ 1209.902154] systemd-journal D11240   526      1 0x00000000
[ 1209.903642] Call Trace:
[ 1209.904574]  __schedule+0x336/0xe00
[ 1209.905734]  schedule+0x3d/0x90
[ 1209.906817]  schedule_timeout+0x20d/0x510
[ 1209.908025]  ? prepare_to_wait+0x2b/0xc0
[ 1209.909268]  ? lock_timer_base+0xa0/0xa0
[ 1209.910460]  io_schedule_timeout+0x1e/0x50
[ 1209.911681]  congestion_wait+0x86/0x260
[ 1209.912853]  ? remove_wait_queue+0x60/0x60
[ 1209.914115]  shrink_inactive_list+0x5b4/0x660
[ 1209.915385]  ? __list_lru_count_one.isra.2+0x22/0x80
[ 1209.916768]  shrink_node_memcg+0x535/0x7f0
[ 1209.918173]  shrink_node+0xe1/0x310
[ 1209.919288]  do_try_to_free_pages+0xe1/0x300
[ 1209.920548]  try_to_free_pages+0x131/0x3f0
[ 1209.921827]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1209.923137]  __alloc_pages_nodemask+0x3e4/0x460
[ 1209.924454]  ? __radix_tree_lookup+0x84/0xf0
[ 1209.925790]  alloc_pages_current+0x97/0x1b0
[ 1209.927021]  ? find_get_entry+0x5/0x300
[ 1209.928189]  __page_cache_alloc+0x15d/0x1a0
[ 1209.929471]  ? pagecache_get_page+0x2c/0x2b0
[ 1209.930716]  filemap_fault+0x4df/0x8b0
[ 1209.931867]  ? filemap_fault+0x373/0x8b0
[ 1209.933111]  ? xfs_ilock+0x22c/0x360 [xfs]
[ 1209.934510]  ? xfs_filemap_fault+0x64/0x1e0 [xfs]
[ 1209.935857]  ? down_read_nested+0x7b/0xc0
[ 1209.937123]  ? xfs_ilock+0x22c/0x360 [xfs]
[ 1209.938373]  xfs_filemap_fault+0x6c/0x1e0 [xfs]
[ 1209.939691]  __do_fault+0x1e/0xa0
[ 1209.940807]  ? _raw_spin_unlock+0x27/0x40
[ 1209.942002]  __handle_mm_fault+0xbb1/0xf40
[ 1209.943228]  ? mutex_unlock+0x12/0x20
[ 1209.944410]  ? devkmsg_read+0x15c/0x330
[ 1209.945912]  handle_mm_fault+0x16b/0x390
[ 1209.947297]  ? handle_mm_fault+0x49/0x390
[ 1209.948868]  __do_page_fault+0x24a/0x530
[ 1209.950351]  do_page_fault+0x30/0x80
[ 1209.951615]  page_fault+0x28/0x30

[ 1210.538496] MemAlloc: kworker/3:0(6345) flags=0x4208860 switches=10134 seq=22 gfp=0x1400000(GFP_NOIO) order=0 delay=45953 uninterruptible
[ 1210.541487] kworker/3:0     D12560  6345      2 0x00000080
[ 1210.542991] Workqueue: events_freezable_power_ disk_events_workfn
[ 1210.544577] Call Trace:
[ 1210.545468]  __schedule+0x336/0xe00
[ 1210.546606]  schedule+0x3d/0x90
[ 1210.547616]  schedule_timeout+0x20d/0x510
[ 1210.548778]  ? prepare_to_wait+0x2b/0xc0
[ 1210.550013]  ? lock_timer_base+0xa0/0xa0
[ 1210.551208]  io_schedule_timeout+0x1e/0x50
[ 1210.552519]  congestion_wait+0x86/0x260
[ 1210.553650]  ? remove_wait_queue+0x60/0x60
[ 1210.554900]  shrink_inactive_list+0x5b4/0x660
[ 1210.556119]  ? __list_lru_count_one.isra.2+0x22/0x80
[ 1210.557447]  shrink_node_memcg+0x535/0x7f0
[ 1210.558714]  shrink_node+0xe1/0x310
[ 1210.559803]  do_try_to_free_pages+0xe1/0x300
[ 1210.561009]  try_to_free_pages+0x131/0x3f0
[ 1210.562250]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1210.563506]  __alloc_pages_nodemask+0x3e4/0x460
[ 1210.564777]  alloc_pages_current+0x97/0x1b0
[ 1210.566017]  bio_copy_kern+0xc9/0x180
[ 1210.567116]  blk_rq_map_kern+0x70/0x140
[ 1210.568356]  __scsi_execute.isra.22+0x13a/0x1e0
[ 1210.569839]  scsi_execute_req_flags+0x94/0x100
[ 1210.571218]  sr_check_events+0xbf/0x2b0 [sr_mod]
[ 1210.572500]  cdrom_check_events+0x18/0x30 [cdrom]
[ 1210.573934]  sr_block_check_events+0x2a/0x30 [sr_mod]
[ 1210.575335]  disk_check_events+0x60/0x170
[ 1210.576509]  disk_events_workfn+0x1c/0x20
[ 1210.577744]  process_one_work+0x22b/0x760
[ 1210.578934]  ? process_one_work+0x194/0x760
[ 1210.580147]  worker_thread+0x137/0x4b0
[ 1210.581336]  kthread+0x10f/0x150
[ 1210.582365]  ? process_one_work+0x760/0x760
[ 1210.583603]  ? kthread_create_on_node+0x70/0x70
[ 1210.584961]  ? do_syscall_64+0x6c/0x200
[ 1210.586343]  ret_from_fork+0x31/0x40
----------

  (3) Number of stalling threads does not decrease over time and
      number of out_of_memory() calls does not increase over time.

----------
[ 1209.781787] MemAlloc-Info: stalling=32 dying=1 exiting=0 victim=1 oom_count=45896
[ 1212.195351] MemAlloc-Info: stalling=32 dying=1 exiting=0 victim=1 oom_count=45896
[ 1242.551629] MemAlloc-Info: stalling=36 dying=1 exiting=0 victim=1 oom_count=45896
[ 1245.149165] MemAlloc-Info: stalling=36 dying=1 exiting=0 victim=1 oom_count=45896
[ 1275.319189] MemAlloc-Info: stalling=40 dying=1 exiting=0 victim=1 oom_count=45896
[ 1278.241813] MemAlloc-Info: stalling=40 dying=1 exiting=0 victim=1 oom_count=45896
----------

Regarding [2], Alexander, Brian and Dave can explain it better than I. But
I think that "check threads which cannot make progress" principle is same.



> (top-posting repaired - please don't do that)

Hmm, I don't see anything wrong with mail headers of replied one that can
cause top-posting. I think something wired occurred outside of my control.

  Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
  From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
  References: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
  In-Reply-To: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
  Message-Id: <201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
  Date: Thu, 9 Mar 2017 19:46:14 +0900

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
