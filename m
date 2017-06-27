Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA5326B02B4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:36:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u18so20988995pfa.8
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:36:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r26si1696903pfb.22.2017.06.27.03.36.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 03:36:00 -0700 (PDT)
Received: from fsav107.sakura.ne.jp (fsav107.sakura.ne.jp [27.133.134.234])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id v5RAZxd4057391
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 19:35:59 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126227147111.bbtec.net [126.227.147.111])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id v5RAZxN7057388
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 19:35:59 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: mm/slab: What is cache_reap work for?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201706271935.DJJ18719.OMFLFFHJSOVtQO@I-love.SAKURA.ne.jp>
Date: Tue, 27 Jun 2017 19:35:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I hit an unable to invoke the OOM killer lockup shown below. According to
"cpus=2 node=0 flags=0x0 nice=0" part, it seems that cache_reap (in mm/slab.c)
work stuck waiting for disk_events_workfn (in block/genhd.c) work to complete.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170627.txt.xz .
----------
[ 1065.687546] Out of memory: Kill process 8984 (c.out) score 999 or sacrifice child
[ 1065.691538] Killed process 8984 (c.out) total-vm:4168kB, anon-rss:88kB, file-rss:4kB, shmem-rss:0kB
[ 1065.696238] oom_reaper: reaped process 8984 (c.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 1117.878766] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 50s!
[ 1117.895518] Showing busy workqueues and worker pools:
[ 1117.901236] workqueue events: flags=0x0
[ 1117.906101]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[ 1117.912773]     pending: vmw_fb_dirty_flush, e1000_watchdog [e1000], cache_reap
[ 1117.920313] workqueue events_long: flags=0x0
[ 1117.925347]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1117.928559]     pending: gc_worker [nf_conntrack]
[ 1117.931138] workqueue events_power_efficient: flags=0x80
[ 1117.933918]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1117.936952]     pending: fb_flashcursor
[ 1117.939175] workqueue events_freezable_power_: flags=0x84
[ 1117.942147]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1117.945174]     in-flight: 290:disk_events_workfn
[ 1117.947783] workqueue writeback: flags=0x4e
[ 1117.950133]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[ 1117.953086]     in-flight: 205:wb_workfn wb_workfn
[ 1117.956370] workqueue xfs-data/sda1: flags=0xc
[ 1117.958886]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1117.961833]     in-flight: 41:xfs_end_io [xfs]
[ 1117.964283] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1117.966794]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[ 1117.969706]     in-flight: 57:xfs_eofblocks_worker [xfs]
[ 1117.972460] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 8996 8989
[ 1117.976029] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 209 8994
[ 1117.979513] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=50s workers=2 manager: 8990
[ 1117.983023] pool 128: cpus=0-63 flags=0x4 nice=0 hung=51s workers=3 idle: 206 207
(...snipped...)
[ 1843.876962] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 776s!
[ 1843.893267] Showing busy workqueues and worker pools:
[ 1843.904317] workqueue events: flags=0x0
[ 1843.909119]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[ 1843.915809]     pending: vmw_fb_dirty_flush, e1000_watchdog [e1000], cache_reap
[ 1843.923780] workqueue events_long: flags=0x0
[ 1843.929056]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1843.934993]     pending: gc_worker [nf_conntrack]
[ 1843.937894] workqueue events_power_efficient: flags=0x80
[ 1843.941036]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[ 1843.944488]     pending: fb_flashcursor, check_lifetime
[ 1843.947609] workqueue events_freezable_power_: flags=0x84
[ 1843.950849]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1843.954335]     in-flight: 290:disk_events_workfn
[ 1843.957541] workqueue writeback: flags=0x4e
[ 1843.960148]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[ 1843.963547]     in-flight: 205:wb_workfn wb_workfn
[ 1843.966962] workqueue ipv6_addrconf: flags=0x40008
[ 1843.969869]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/1
[ 1843.973271]     pending: addrconf_verify_work
[ 1843.976127] workqueue xfs-data/sda1: flags=0xc
[ 1843.978872]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1843.982344]     in-flight: 41:xfs_end_io [xfs]
[ 1843.985150] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1843.988094]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[ 1843.991502]     in-flight: 57:xfs_eofblocks_worker [xfs]
[ 1843.994590] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 8996 8989
[ 1843.998117] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 209 8994
[ 1844.001573] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=776s workers=2 manager: 8990
[ 1844.005030] pool 128: cpus=0-63 flags=0x4 nice=0 hung=777s workers=3 idle: 206 207
----------

Although there is kswapd0 stuck as usual, none of all works is rescuer, and
all in-flight works are calling schedule().

----------
[ 1689.488050] kworker/0:1     D12144    41      2 0x00000000
[ 1689.490494] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1689.492742] Call Trace:
[ 1689.494016]  __schedule+0x403/0xae0
[ 1689.495698]  ? mark_held_locks+0x76/0xa0
[ 1689.497527]  schedule+0x3d/0x90
[ 1689.499502]  ? rwsem_down_write_failed+0x30a/0x510
[ 1689.501713]  rwsem_down_write_failed+0x30f/0x510
[ 1689.503827]  ? __xfs_setfilesize+0x30/0x220 [xfs]
[ 1689.505934]  call_rwsem_down_write_failed+0x17/0x30
[ 1689.508106]  ? call_rwsem_down_write_failed+0x17/0x30
[ 1689.510372]  ? xfs_ilock+0x189/0x240 [xfs]
[ 1689.512260]  down_write_nested+0x91/0xc0
[ 1689.514251]  xfs_ilock+0x189/0x240 [xfs]
[ 1689.516109]  __xfs_setfilesize+0x30/0x220 [xfs]
[ 1689.518215]  xfs_setfilesize_ioend+0x82/0xb0 [xfs]
[ 1689.520390]  xfs_end_io+0x6a/0xb0 [xfs]
[ 1689.522182]  process_one_work+0x250/0x690
[ 1689.524041]  worker_thread+0x4e/0x3b0
[ 1689.525766]  kthread+0x117/0x150
[ 1689.527325]  ? process_one_work+0x690/0x690
[ 1689.529371]  ? kthread_create_on_node+0x70/0x70
[ 1689.531430]  ret_from_fork+0x2a/0x40
(...snipped...)
[ 1689.841434] kworker/1:1     D10848    57      2 0x00000000
[ 1689.843901] Workqueue: xfs-eofblocks/sda1 xfs_eofblocks_worker [xfs]
[ 1689.846643] Call Trace:
[ 1689.847927]  __schedule+0x403/0xae0
[ 1689.849601]  ? sched_clock+0x9/0x10
[ 1689.851271]  ? __down+0x85/0x100
[ 1689.852840]  schedule+0x3d/0x90
[ 1689.854373]  schedule_timeout+0x29f/0x510
[ 1689.856234]  ? mark_held_locks+0x76/0xa0
[ 1689.858126]  ? _raw_spin_unlock_irq+0x2c/0x40
[ 1689.860112]  ? __down+0x85/0x100
[ 1689.861676]  ? __down+0x85/0x100
[ 1689.863233]  __down+0xa6/0x100
[ 1689.864723]  ? __down+0xa6/0x100
[ 1689.866310]  ? _xfs_buf_find+0x3b1/0xb10 [xfs]
[ 1689.868320]  down+0x41/0x50
[ 1689.869709]  ? down+0x41/0x50
[ 1689.871185]  xfs_buf_lock+0x5f/0x2d0 [xfs]
[ 1689.873192]  _xfs_buf_find+0x3b1/0xb10 [xfs]
[ 1689.875160]  xfs_buf_get_map+0x2a/0x510 [xfs]
[ 1689.877158]  xfs_buf_read_map+0x2c/0x350 [xfs]
[ 1689.879191]  xfs_trans_read_buf_map+0x176/0x620 [xfs]
[ 1689.881448]  xfs_read_agf+0xb2/0x200 [xfs]
[ 1689.883347]  xfs_alloc_read_agf+0x6c/0x250 [xfs]
[ 1689.885444]  xfs_alloc_fix_freelist+0x38c/0x3f0 [xfs]
[ 1689.887769]  ? sched_clock+0x9/0x10
[ 1689.889579]  ? xfs_perag_get+0x9b/0x280 [xfs]
[ 1689.891573]  ? xfs_free_extent_fix_freelist+0x64/0xc0 [xfs]
[ 1689.894002]  ? rcu_read_lock_sched_held+0x4a/0x80
[ 1689.896189]  ? xfs_perag_get+0x21e/0x280 [xfs]
[ 1689.898247]  xfs_free_extent_fix_freelist+0x78/0xc0 [xfs]
[ 1689.900640]  xfs_free_extent+0x57/0x140 [xfs]
[ 1689.902645]  xfs_trans_free_extent+0x63/0x210 [xfs]
[ 1689.905119]  ? xfs_trans_add_item+0x5d/0x90 [xfs]
[ 1689.907260]  xfs_extent_free_finish_item+0x26/0x40 [xfs]
[ 1689.909622]  xfs_defer_finish+0x1a4/0x810 [xfs]
[ 1689.911720]  xfs_itruncate_extents+0x14a/0x4e0 [xfs]
[ 1689.913960]  xfs_free_eofblocks+0x174/0x1e0 [xfs]
[ 1689.916098]  xfs_inode_free_eofblocks+0x1ba/0x390 [xfs]
[ 1689.918447]  xfs_inode_ag_walk.isra.11+0x29b/0x6f0 [xfs]
[ 1689.921072]  ? __xfs_inode_clear_eofblocks_tag+0x120/0x120 [xfs]
[ 1689.923830]  ? save_stack_trace+0x1b/0x20
[ 1689.925760]  ? save_trace+0x3b/0xb0
[ 1689.927542]  xfs_inode_ag_iterator_tag+0x73/0xa0 [xfs]
[ 1689.929932]  ? __xfs_inode_clear_eofblocks_tag+0x120/0x120 [xfs]
[ 1689.932661]  xfs_eofblocks_worker+0x2d/0x40 [xfs]
[ 1689.935338]  process_one_work+0x250/0x690
[ 1689.937378]  worker_thread+0x4e/0x3b0
[ 1689.939243]  kthread+0x117/0x150
[ 1689.940943]  ? process_one_work+0x690/0x690
[ 1689.942939]  ? kthread_create_on_node+0x70/0x70
[ 1689.945001]  ret_from_fork+0x2a/0x40
(...snipped...)
[ 1689.985819] kswapd0         D 9720    62      2 0x00000000
[ 1689.988261] Call Trace:
[ 1689.989559]  __schedule+0x403/0xae0
[ 1689.991243]  ? mark_held_locks+0x76/0xa0
[ 1689.993088]  ? rwsem_down_read_failed+0x12a/0x190
[ 1689.995221]  schedule+0x3d/0x90
[ 1689.996866]  rwsem_down_read_failed+0x12a/0x190
[ 1689.999245]  ? xfs_map_blocks+0x82/0x440 [xfs]
[ 1690.001430]  call_rwsem_down_read_failed+0x18/0x30
[ 1690.003615]  ? call_rwsem_down_read_failed+0x18/0x30
[ 1690.005879]  ? xfs_ilock+0x101/0x240 [xfs]
[ 1690.007786]  down_read_nested+0xa7/0xb0
[ 1690.009618]  xfs_ilock+0x101/0x240 [xfs]
[ 1690.011479]  xfs_map_blocks+0x82/0x440 [xfs]
[ 1690.013614]  xfs_do_writepage+0x305/0x860 [xfs]
[ 1690.015684]  ? clear_page_dirty_for_io+0x1cd/0x2c0
[ 1690.017863]  xfs_vm_writepage+0x3b/0x70 [xfs]
[ 1690.019859]  pageout.isra.52+0x1a0/0x430
[ 1690.021692]  shrink_page_list+0xa5b/0xce0
[ 1690.023561]  shrink_inactive_list+0x1ba/0x590
[ 1690.025548]  ? __lock_acquire+0x3d8/0x1370
[ 1690.027443]  shrink_node_memcg+0x378/0x750
[ 1690.029514]  shrink_node+0xe1/0x310
[ 1690.031176]  ? shrink_node+0xe1/0x310
[ 1690.032903]  kswapd+0x3eb/0x9d0
[ 1690.034434]  kthread+0x117/0x150
[ 1690.035988]  ? mem_cgroup_shrink_node+0x350/0x350
[ 1690.038093]  ? kthread_create_on_node+0x70/0x70
[ 1690.040133]  ret_from_fork+0x2a/0x40
(...snipped...)
[ 1691.352089] kworker/u128:29 D 9488   205      2 0x00000000
[ 1691.354805] Workqueue: writeback wb_workfn (flush-8:0)
[ 1691.357088] Call Trace:
[ 1691.358365]  __schedule+0x403/0xae0
[ 1691.360032]  schedule+0x3d/0x90
[ 1691.361564]  io_schedule+0x16/0x40
[ 1691.363188]  __lock_page+0xe3/0x180
[ 1691.364845]  ? page_cache_tree_insert+0x170/0x170
[ 1691.366982]  write_cache_pages+0x3a2/0x680
[ 1691.368900]  ? xfs_add_to_ioend+0x260/0x260 [xfs]
[ 1691.371139]  ? xfs_vm_writepages+0x5b/0xe0 [xfs]
[ 1691.373253]  xfs_vm_writepages+0xb9/0xe0 [xfs]
[ 1691.375279]  do_writepages+0x25/0x80
[ 1691.376976]  __writeback_single_inode+0x68/0x7f0
[ 1691.379065]  ? _raw_spin_unlock+0x27/0x40
[ 1691.380928]  writeback_sb_inodes+0x328/0x700
[ 1691.382894]  __writeback_inodes_wb+0x92/0xc0
[ 1691.384897]  wb_writeback+0x3c0/0x5f0
[ 1691.386691]  wb_workfn+0xaf/0x650
[ 1691.388286]  ? wb_workfn+0xaf/0x650
[ 1691.389949]  ? process_one_work+0x1c2/0x690
[ 1691.391871]  process_one_work+0x250/0x690
[ 1691.393730]  worker_thread+0x4e/0x3b0
[ 1691.395459]  kthread+0x117/0x150
[ 1691.397018]  ? process_one_work+0x690/0x690
[ 1691.398933]  ? kthread_create_on_node+0x70/0x70
[ 1691.401096]  ret_from_fork+0x2a/0x40
(...snipped...)
[ 1691.514602] kworker/2:2     D12136   290      2 0x00000000
[ 1691.517020] Workqueue: events_freezable_power_ disk_events_workfn
[ 1691.519664] Call Trace:
[ 1691.520943]  __schedule+0x403/0xae0
[ 1691.522611]  ? mark_held_locks+0x76/0xa0
[ 1691.524444]  schedule+0x3d/0x90
[ 1691.526114]  schedule_timeout+0x23b/0x510
[ 1691.528079]  ? init_timer_on_stack_key+0x60/0x60
[ 1691.530225]  io_schedule_timeout+0x1e/0x50
[ 1691.532153]  ? io_schedule_timeout+0x1e/0x50
[ 1691.534117]  congestion_wait+0x86/0x210
[ 1691.535938]  ? remove_wait_queue+0x70/0x70
[ 1691.537840]  shrink_inactive_list+0x45e/0x590
[ 1691.539843]  shrink_node_memcg+0x378/0x750
[ 1691.541862]  shrink_node+0xe1/0x310
[ 1691.543607]  ? shrink_node+0xe1/0x310
[ 1691.545342]  do_try_to_free_pages+0xef/0x370
[ 1691.547304]  try_to_free_pages+0x12c/0x370
[ 1691.549196]  ? check_blkcg_changed+0xa8/0x370
[ 1691.551211]  __alloc_pages_slowpath+0x4d8/0x1190
[ 1691.553314]  __alloc_pages_nodemask+0x329/0x3e0
[ 1691.555373]  alloc_pages_current+0xa1/0x1f0
[ 1691.557395]  bio_copy_kern+0xce/0x1f0
[ 1691.559145]  blk_rq_map_kern+0x9e/0x140
[ 1691.561039]  scsi_execute+0x7b/0x270
[ 1691.562779]  sr_check_events+0xb1/0x2d0
[ 1691.564690]  cdrom_check_events+0x18/0x30
[ 1691.566591]  sr_block_check_events+0x2a/0x30
[ 1691.568601]  disk_check_events+0x62/0x140
[ 1691.570561]  ? process_one_work+0x1c2/0x690
[ 1691.572829]  disk_events_workfn+0x1c/0x20
[ 1691.574684]  process_one_work+0x250/0x690
[ 1691.576539]  worker_thread+0x4e/0x3b0
[ 1691.578262]  kthread+0x117/0x150
[ 1691.579813]  ? process_one_work+0x690/0x690
[ 1691.581728]  ? kthread_create_on_node+0x70/0x70
[ 1691.583772]  ret_from_fork+0x2a/0x40
----------

Is this just another example of being caught by too_many_isolated() trap
in shrink_inactive_list()? Or, cache_reap work should have been processed
(without waiting for disk_check_events work) in order to make progress for
disk_check_events work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
