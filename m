Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2FC6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 05:48:36 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u62so111444428pfk.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 02:48:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f16si10263485pli.29.2017.03.03.02.48.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 02:48:34 -0800 (PST)
Subject: How to favor memory allocations for WQ_MEM_RECLAIM threads?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp>
Date: Fri, 3 Mar 2017 19:48:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org, linux-mm@kvack.org

Continued from http://lkml.kernel.org/r/201702261530.JDD56292.OFOLFHQtVMJSOF@I-love.SAKURA.ne.jp :

While I was testing a patch which avoids infinite too_many_isolated() loop in
shrink_inactive_list(), I hit a lockup where WQ_MEM_RECLAIM threads got stuck
waiting for memory allocation. I guess that we overlooked a basic thing about
WQ_MEM_RECLAIM.

  WQ_MEM_RECLAIM helps only when the cause of failing to complete
  a work item is lack of "struct task_struct" to run that work item, for
  WQ_MEM_RECLAIM preallocates one "struct task_struct" so that the workqueue
  will not be blocked waiting for memory allocation for "struct task_struct".

  WQ_MEM_RECLAIM does not help when "struct task_struct" running that work
  item is blocked waiting for memory allocation (or is indirectly blocked
  on a lock where the owner of that lock is blocked waiting for memory
  allocation). That is, WQ_MEM_RECLAIM users must guarantee forward progress
  if memory allocation (including indirect memory allocation via
  locks/completions) is needed.

In XFS, "xfs_mru_cache", "xfs-buf/%s", "xfs-data/%s", "xfs-conv/%s", "xfs-cil/%s",
"xfs-reclaim/%s", "xfs-log/%s", "xfs-eofblocks/%s", "xfsalloc" and "xfsdiscard"
workqueues are used, and all but "xfsdiscard" are WQ_MEM_RECLAIM workqueues.

What I observed is at http://I-love.SAKURA.ne.jp/tmp/serial-20170226.txt.xz .
I guess that the key of this lockup is that xfs-data/sda1 and xfs-eofblocks/s
workqueues (which are RESCUER) got stuck waiting for memory allocation.

----------------------------------------
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

[ 1116.758199] Showing busy workqueues and worker pools:
[ 1116.759630] workqueue events: flags=0x0
[ 1116.760882]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=5/256
[ 1116.762484]     pending: vmpressure_work_fn, vmstat_shepherd, vmw_fb_dirty_flush [vmwgfx], check_corruption, console_callback
[ 1116.765197]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 1116.766841]     pending: drain_local_pages_wq BAR(9595), e1000_watchdog [e1000]
[ 1116.768755]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[ 1116.770778]     in-flight: 7418:rht_deferred_worker
[ 1116.772255]     pending: rht_deferred_worker
[ 1116.773648] workqueue events_long: flags=0x0
[ 1116.776610]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[ 1116.778302]     pending: gc_worker [nf_conntrack]
[ 1116.779857] workqueue events_power_efficient: flags=0x80
[ 1116.781485]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[ 1116.783175]     pending: fb_flashcursor
[ 1116.784452]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[ 1116.786265]     pending: neigh_periodic_work, neigh_periodic_work
[ 1116.788056] workqueue events_freezable_power_: flags=0x84
[ 1116.789748]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1116.791490]     in-flight: 27:disk_events_workfn
[ 1116.793092] workqueue writeback: flags=0x4e
[ 1116.794471]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1116.796209]     in-flight: 8444:wb_workfn wb_workfn
[ 1116.798747] workqueue mpt_poll_0: flags=0x8
[ 1116.800223]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1116.801997]     pending: mpt_fault_reset_work [mptbase]
[ 1116.803780] workqueue xfs-data/sda1: flags=0xc
[ 1116.805324]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=27/256 MAYDAY
[ 1116.807272]     in-flight: 5356:xfs_end_io [xfs], 451(RESCUER):xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs], 10498:xfs_end_io [xfs], 6386:xfs_end_io [xfs]
[ 1116.812145]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[ 1116.820988]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=21/256 MAYDAY
[ 1116.823105]     in-flight: 535:xfs_end_io [xfs], 7416:xfs_end_io [xfs], 7415:xfs_end_io [xfs], 65:xfs_end_io [xfs]
[ 1116.826062]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[ 1116.834549]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=4/256 MAYDAY
[ 1116.837139]     in-flight: 5357:xfs_end_io [xfs], 193:xfs_end_io [xfs], 52:xfs_end_io [xfs], 5358:xfs_end_io [xfs]
[ 1116.840182]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1116.842297]     in-flight: 2486:xfs_end_io [xfs]
[ 1116.844230] workqueue xfs-reclaim/sda1: flags=0xc
[ 1116.846168]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1116.848323]     pending: xfs_reclaim_worker [xfs]
[ 1116.850280] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1116.852358]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[ 1116.854601]     in-flight: 456(RESCUER):xfs_eofblocks_worker [xfs]
[ 1116.856826] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3 6387
[ 1116.859293] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=670s workers=6 manager: 19
[ 1116.861762] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=673s workers=6 manager: 157
[ 1116.864240] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=673s workers=4 manager: 10499
[ 1116.866876] pool 256: cpus=0-127 flags=0x4 nice=0 hung=670s workers=3 idle: 425 426
----------------------------------------

kthreadd (PID = 2) is trying to allocate "struct task_struct" requested by
workqueue managers (PID = 19, 157, 10499) but is blocked on memory allocation.
Since "struct task_struct" cannot be allocated for workqueues, RESCUER threads
(PID = 451, 456) are responsible for making forward progress.

----------------------------------------
[ 1039.876146] kworker/1:0     D12872    19      2 0x00000000
[ 1039.877743] Call Trace:
[ 1039.878717]  __schedule+0x336/0xe00
[ 1039.879908]  schedule+0x3d/0x90
[ 1039.881016]  schedule_timeout+0x26a/0x510
[ 1039.882306]  ? wait_for_completion_killable+0x56/0x1e0
[ 1039.883831]  wait_for_completion_killable+0x166/0x1e0
[ 1039.885331]  ? wake_up_q+0x80/0x80
[ 1039.886512]  ? process_one_work+0x760/0x760
[ 1039.887827]  __kthread_create_on_node+0x194/0x240
[ 1039.889255]  kthread_create_on_node+0x49/0x70
[ 1039.890604]  create_worker+0xca/0x1a0
[ 1039.891823]  worker_thread+0x34d/0x4b0
[ 1039.893050]  kthread+0x10f/0x150
[ 1039.894186]  ? process_one_work+0x760/0x760
[ 1039.895518]  ? kthread_create_on_node+0x70/0x70
[ 1039.896921]  ret_from_fork+0x31/0x40

[ 1040.575900] kworker/2:2     D12504   157      2 0x00000000
[ 1040.577485] Call Trace:
[ 1040.578469]  __schedule+0x336/0xe00
[ 1040.579646]  schedule+0x3d/0x90
[ 1040.580748]  schedule_timeout+0x26a/0x510
[ 1040.582031]  ? wait_for_completion_killable+0x56/0x1e0
[ 1040.583548]  wait_for_completion_killable+0x166/0x1e0
[ 1040.585041]  ? wake_up_q+0x80/0x80
[ 1040.586199]  ? process_one_work+0x760/0x760
[ 1040.587859]  __kthread_create_on_node+0x194/0x240
[ 1040.589294]  kthread_create_on_node+0x49/0x70
[ 1040.590662]  create_worker+0xca/0x1a0
[ 1040.591884]  worker_thread+0x34d/0x4b0
[ 1040.593123]  kthread+0x10f/0x150
[ 1040.594243]  ? process_one_work+0x760/0x760
[ 1040.595572]  ? kthread_create_on_node+0x70/0x70
[ 1040.596974]  ret_from_fork+0x31/0x40

[ 1090.480342] kworker/3:1     D11280 10499      2 0x00000080
[ 1090.481966] Call Trace:
[ 1090.482984]  __schedule+0x336/0xe00
[ 1090.484228]  ? account_entity_enqueue+0xdb/0x110
[ 1090.487424]  schedule+0x3d/0x90
[ 1090.488575]  schedule_timeout+0x26a/0x510
[ 1090.489881]  ? wait_for_completion_killable+0x56/0x1e0
[ 1090.491615]  wait_for_completion_killable+0x166/0x1e0
[ 1090.493143]  ? wake_up_q+0x80/0x80
[ 1090.494334]  ? process_one_work+0x760/0x760
[ 1090.495679]  __kthread_create_on_node+0x194/0x240
[ 1090.498150]  kthread_create_on_node+0x49/0x70
[ 1090.499518]  create_worker+0xca/0x1a0
[ 1090.500737]  worker_thread+0x34d/0x4b0
[ 1090.501986]  kthread+0x10f/0x150
[ 1090.503126]  ? process_one_work+0x760/0x760
[ 1090.504459]  ? kthread_create_on_node+0x70/0x70
[ 1090.505857]  ? do_syscall_64+0x195/0x200
[ 1090.507132]  ret_from_fork+0x31/0x40

[ 1095.631379] MemAlloc: kthreadd(2) flags=0x208840 switches=313 seq=5 gfp=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK) order=2 delay=652085 uninterruptible
[ 1095.631380] kthreadd        D11000     2      0 0x00000000
[ 1095.631384] Call Trace:
[ 1095.631387]  __schedule+0x336/0xe00
[ 1095.631388]  ? __mutex_lock+0x1a2/0x9c0
[ 1095.631391]  schedule+0x3d/0x90
[ 1095.631393]  schedule_preempt_disabled+0x15/0x20
[ 1095.631394]  __mutex_lock+0x2ed/0x9c0
[ 1095.631395]  ? __mutex_lock+0xce/0x9c0
[ 1095.631397]  ? radix_tree_gang_lookup_tag+0xd7/0x150
[ 1095.631417]  ? xfs_reclaim_inodes_ag+0x3c6/0x4f0 [xfs]
[ 1095.631439]  ? xfs_perag_get_tag+0x5/0x370 [xfs]
[ 1095.631441]  mutex_lock_nested+0x1b/0x20
[ 1095.631473]  xfs_reclaim_inodes_ag+0x3c6/0x4f0 [xfs]
[ 1095.631500]  ? xfs_reclaim_inodes_ag+0xf2/0x4f0 [xfs]
[ 1095.631507]  ? _raw_spin_unlock_irqrestore+0x3b/0x60
[ 1095.631510]  ? try_to_wake_up+0x59/0x7a0
[ 1095.631514]  ? wake_up_process+0x15/0x20
[ 1095.631557]  xfs_reclaim_inodes_nr+0x33/0x40 [xfs]
[ 1095.631580]  xfs_fs_free_cached_objects+0x19/0x20 [xfs]
[ 1095.631582]  super_cache_scan+0x181/0x190
[ 1095.631585]  shrink_slab+0x29f/0x6d0
[ 1095.631591]  shrink_node+0x2fa/0x310
[ 1095.631594]  do_try_to_free_pages+0xe1/0x300
[ 1095.631597]  try_to_free_pages+0x131/0x3f0
[ 1095.631602]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.631606]  ? _raw_spin_unlock+0x27/0x40
[ 1095.631610]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.631611]  ? cpumask_next_and+0x47/0xa0
[ 1095.631615]  new_slab+0x450/0x6b0
[ 1095.631618]  ___slab_alloc+0x3a3/0x620
[ 1095.631622]  ? find_busiest_group+0x47/0x4d0
[ 1095.631624]  ? copy_process.part.31+0x122/0x21e0
[ 1095.631627]  ? copy_process.part.31+0x122/0x21e0
[ 1095.631629]  __slab_alloc+0x46/0x7d
[ 1095.631631]  kmem_cache_alloc_node+0xab/0x3a0
[ 1095.631633]  ? load_balance+0x1e7/0xb50
[ 1095.631635]  copy_process.part.31+0x122/0x21e0
[ 1095.631638]  ? pick_next_task_fair+0x6c6/0x890
[ 1095.631641]  ? kthread_create_on_node+0x70/0x70
[ 1095.631642]  ? finish_task_switch+0x70/0x240
[ 1095.631644]  _do_fork+0xf3/0x750
[ 1095.631647]  ? kthreadd+0x2f2/0x3c0
[ 1095.631650]  kernel_thread+0x29/0x30
[ 1095.631651]  kthreadd+0x35a/0x3c0
[ 1095.631652]  ? ret_from_fork+0x31/0x40
[ 1095.631656]  ? kthread_create_on_cpu+0xb0/0xb0
[ 1095.631658]  ret_from_fork+0x31/0x40
----------------------------------------

As usual, GFP_NOIO allocation by disk_events_workfn (as a crying
canary indicating a lockup) is stalling there.

----------------------------------------
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
----------------------------------------

Due to __GFP_NOWARN, warn_alloc() cannot warn allocation stalls.
Due to order <= PAGE_ALLOC_COSTLY_ORDER without __GFP_NORETRY, the
"%s(%u) possible memory allocation deadlock size %u in %s (mode:0x%x)"
message cannot be printed because __alloc_pages_nodemask() does not return.
And due to GFP_NOFS with neither __GFP_HIGH nor __GFP_NOFAIL, memory cannot
be allocated to RESCUER threads which are trying to allocate memory for
reclaiming memory.

Setting PF_MEMALLOC will disable direct reclaim and allow access to memory
reserves, but allocation failure is not acceptable due to !KM_MAYFAIL.
Passing __GFP_HIGH and/or __GFP_NOFAIL will allow access to memory reserves,
but allocation might still loop forever inside the page allocator (especially
if order > 0) because commit 06ad276ac18742c6 ("mm, oom: do not enforce OOM
killer for __GFP_NOFAIL automatically") deprived WQ_MEM_RECLAIM users of
the last resort for invoking the OOM killer. If order > 0 allocation request
with __GFP_NOFAIL fails due to fragmentation, there is nothing we can do.
Passing __GFP_NORETRY will allow the
"%s(%u) possible memory allocation deadlock size %u in %s (mode:0x%x)" message
to be printed but that helps only emitting warning.

So, how can we avoid this situation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
