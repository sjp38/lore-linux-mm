Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB506B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 06:58:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b13so86007564pgn.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 03:58:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z192si3386767pgd.313.2017.06.29.03.58.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 03:58:02 -0700 (PDT)
Subject: mm: Why WQ_MEM_RECLAIM workqueue remains pending?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201706291957.JGH39511.tQMOFSLOFJVHOF@I-love.SAKURA.ne.jp>
Date: Thu, 29 Jun 2017 19:57:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-mm@kvack.org

I hit an unable to invoke the OOM killer lockup shown below. According to
"cpus=1 node=0 flags=0x0 nice=0" part, it seems that drain_local_pages_wq
work stuck despite it is on WQ_MEM_RECLAIM mm_percpu_wq workqueue.

    mm_percpu_wq = alloc_workqueue("mm_percpu_wq", WQ_MEM_RECLAIM, 0);

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170629.txt.xz .
----------
[  423.393025] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 75s!
[  423.405078] Showing busy workqueues and worker pools:
[  423.411988] workqueue events: flags=0x0
[  423.417675]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  423.425512]     pending: vmpressure_work_fn
[  423.431489]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  423.435671]     pending: vmstat_shepherd, rht_deferred_worker, vmw_fb_dirty_flush [vmwgfx]
[  423.439838] workqueue events_power_efficient: flags=0x80
[  423.442709]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  423.445870]     pending: neigh_periodic_work, do_cache_clean
[  423.448884] workqueue events_freezable_power_: flags=0x84
[  423.451809]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  423.454953]     pending: disk_events_workfn
[  423.457371] workqueue mm_percpu_wq: flags=0x8
[  423.459883]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  423.463018]     pending: drain_local_pages_wq BAR(8775), vmstat_update
[  423.465553] workqueue writeback: flags=0x4e
[  423.467221]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  423.469645]     in-flight: 355:wb_workfn wb_workfn
[  423.472129] workqueue ipv6_addrconf: flags=0x40008
[  423.474416]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/1
[  423.476725]     pending: addrconf_verify_work
[  423.478513] workqueue mpt_poll_0: flags=0x8
[  423.480199]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  423.482462]     pending: mpt_fault_reset_work [mptbase]
[  423.484533] workqueue xfs-data/sda1: flags=0xc
[  423.486388]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  423.488674]     in-flight: 95:xfs_end_io [xfs], 8978:xfs_end_io [xfs], 65:xfs_end_io [xfs], 8979:xfs_end_io [xfs]
[  423.492249]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  423.494519]     in-flight: 205:xfs_end_io [xfs], 23:xfs_end_io [xfs]
[  423.496943]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=17/256 MAYDAY
[  423.499432]     in-flight: 17:xfs_end_io [xfs], 8985:xfs_end_io [xfs], 8980:xfs_end_io [xfs], 7805:xfs_end_io [xfs], 8984:xfs_end_io [xfs]
[  423.503673]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  423.511095]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=8/256 MAYDAY
[  423.513586]     in-flight: 8981:xfs_end_io [xfs], 375(RESCUER):xfs_end_io [xfs] xfs_end_io [xfs], 33:xfs_end_io [xfs], 3:xfs_end_io [xfs], 7839:xfs_end_io [xfs], 8976:xfs_end_io [xfs]
[  423.519583]     pending: xfs_end_io [xfs]
[  423.521566] workqueue xfs-eofblocks/sda1: flags=0xc
[  423.523645]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  423.526041]     in-flight: 168:xfs_eofblocks_worker [xfs]
[  423.528253] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=75s workers=6 manager: 217
[  423.531114] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=76s workers=7 manager: 43
[  423.534038] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=8 idle: 8977 7840 60 7837 8983 8982
[  423.537554] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=7 idle: 464 42 29
[  423.540547] pool 128: cpus=0-63 flags=0x4 nice=0 hung=48s workers=3 idle: 354 356
[  453.599480] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 105s!
[  453.613056] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 106s!
[  453.623744] Showing busy workqueues and worker pools:
[  453.631182] workqueue events: flags=0x0
[  453.638161]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  453.644207]     pending: vmpressure_work_fn
[  453.647411]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  453.651569]     pending: vmstat_shepherd, rht_deferred_worker, vmw_fb_dirty_flush [vmwgfx]
[  453.656989] workqueue events_power_efficient: flags=0x80
[  453.660815]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  453.665043]     pending: neigh_periodic_work, do_cache_clean
[  453.669263] workqueue events_freezable_power_: flags=0x84
[  453.672641]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  453.675053]     pending: disk_events_workfn
[  453.676885] workqueue mm_percpu_wq: flags=0x8
[  453.678730]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  453.681075]     pending: drain_local_pages_wq BAR(8775), vmstat_update
[  453.683610] workqueue writeback: flags=0x4e
[  453.685412]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  453.687703]     in-flight: 355:wb_workfn wb_workfn
[  453.690022] workqueue ipv6_addrconf: flags=0x40008
[  453.692018]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/1
[  453.694295]     pending: addrconf_verify_work
[  453.696139] workqueue mpt_poll_0: flags=0x8
[  453.698024]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  453.700362]     pending: mpt_fault_reset_work [mptbase]
[  453.702515] workqueue xfs-data/sda1: flags=0xc
[  453.704470]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  453.706809]     in-flight: 95:xfs_end_io [xfs], 8978:xfs_end_io [xfs], 65:xfs_end_io [xfs], 8979:xfs_end_io [xfs]
[  453.710578]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=2/256
[  453.712956]     in-flight: 205:xfs_end_io [xfs], 23:xfs_end_io [xfs]
[  453.715424]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=17/256 MAYDAY
[  453.717958]     in-flight: 17:xfs_end_io [xfs], 8985:xfs_end_io [xfs], 8980:xfs_end_io [xfs], 7805:xfs_end_io [xfs], 8984:xfs_end_io [xfs]
[  453.722214]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  453.729761]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=8/256 MAYDAY
[  453.732276]     in-flight: 8981:xfs_end_io [xfs], 375(RESCUER):xfs_end_io [xfs] xfs_end_io [xfs], 33:xfs_end_io [xfs], 3:xfs_end_io [xfs], 7839:xfs_end_io [xfs], 8976:xfs_end_io [xfs]
[  453.738334]     pending: xfs_end_io [xfs]
[  453.740136] workqueue xfs-eofblocks/sda1: flags=0xc
[  453.742165]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  453.744507]     in-flight: 168:xfs_eofblocks_worker [xfs]
[  453.746655] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=106s workers=6 manager: 217
[  453.749528] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=106s workers=7 manager: 43
[  453.752382] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=8 idle: 8977 7840 60 7837 8983 8982
[  453.755740] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=7 idle: 464 42 29
[  453.758603] pool 128: cpus=0-63 flags=0x4 nice=0 hung=78s workers=3 idle: 354 356
----------

This might be just another example of being caught by too_many_isolated() trap
in shrink_inactive_list(). But I expected that works in mm_percpu_wq workqueue is
always processed immediately as long as in-flight work calls schedule().

Why "pending: drain_local_pages_wq" was not processed despite all in-flight works on
"pool 2: cpus=1 node=0 flags=0x0 nice=0" (that is, 17, 8985, 8980, 7805, 8984 and 168
shown below) were all sleeping at schedule() ? Or, am I just fooled by appearances that
drain_local_pages_wq was actually processed but constantly/immediately re-queued as if
drain_local_pages_wq was never processed?

----------
[  521.100167] kworker/1:0     D12608    17      2 0x00000000
[  521.102148] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  521.103916] Call Trace:
[  521.104962]  __schedule+0x23f/0x5d0
[  521.106326]  schedule+0x31/0x80
[  521.107569]  schedule_timeout+0x189/0x290
[  521.109033]  ? del_timer_sync+0x40/0x40
[  521.110496]  io_schedule_timeout+0x19/0x40
[  521.112035]  ? io_schedule_timeout+0x19/0x40
[  521.113609]  congestion_wait+0x7d/0xd0
[  521.115128]  ? wait_woken+0x80/0x80
[  521.116440]  shrink_inactive_list+0x3e3/0x4d0
[  521.118048]  shrink_node_memcg+0x360/0x780
[  521.119592]  shrink_node+0xdc/0x310
[  521.120903]  ? shrink_node+0xdc/0x310
[  521.122293]  do_try_to_free_pages+0xea/0x370
[  521.123828]  try_to_free_pages+0xc3/0x100
[  521.125351]  __alloc_pages_slowpath+0x441/0xd50
[  521.126999]  __alloc_pages_nodemask+0x20c/0x250
[  521.128611]  alloc_pages_current+0x65/0xd0
[  521.130129]  new_slab+0x472/0x600
[  521.131405]  ___slab_alloc+0x41b/0x590
[  521.132835]  ? kmem_alloc+0x8a/0x110 [xfs]
[  521.134361]  ? ___slab_alloc+0x1b6/0x590
[  521.135803]  ? kmem_alloc+0x8a/0x110 [xfs]
[  521.137344]  __slab_alloc+0x1b/0x30
[  521.138653]  ? __slab_alloc+0x1b/0x30
[  521.140217]  __kmalloc+0x17e/0x200
[  521.141507]  kmem_alloc+0x8a/0x110 [xfs]
[  521.142980]  xfs_log_commit_cil+0x276/0x750 [xfs]
[  521.144692]  __xfs_trans_commit+0x7d/0x280 [xfs]
[  521.146332]  xfs_trans_commit+0xb/0x10 [xfs]
[  521.147898]  __xfs_setfilesize+0x7c/0xb0 [xfs]
[  521.149522]  xfs_setfilesize_ioend+0x41/0x60 [xfs]
[  521.151215]  xfs_end_io+0x44/0x130 [xfs]
[  521.152724]  process_one_work+0x1f5/0x390
[  521.154187]  worker_thread+0x46/0x410
[  521.155594]  kthread+0xff/0x140
[  521.156836]  ? process_one_work+0x390/0x390
[  521.158356]  ? kthread_create_on_node+0x60/0x60
[  521.160024]  ret_from_fork+0x25/0x30

[  521.760190] kswapd0         D11640    51      2 0x00000000
[  521.762176] Call Trace:
[  521.763204]  __schedule+0x23f/0x5d0
[  521.764581]  schedule+0x31/0x80
[  521.765826]  schedule_timeout+0x1c1/0x290
[  521.767351]  ? save_stack_trace+0x16/0x20
[  521.768827]  ? set_track+0x6b/0x140
[  521.770204]  ? init_object+0x64/0xa0
[  521.771561]  __down+0x85/0xd0
[  521.772765]  ? __down+0x85/0xd0
[  521.773982]  ? cmpxchg_double_slab.isra.73+0x140/0x150
[  521.775827]  down+0x3c/0x50
[  521.776991]  ? down+0x3c/0x50
[  521.778190]  xfs_buf_lock+0x21/0x50 [xfs]
[  521.779716]  _xfs_buf_find+0x3cd/0x640 [xfs]
[  521.781267]  xfs_buf_get_map+0x25/0x150 [xfs]
[  521.782952]  xfs_buf_read_map+0x25/0xc0 [xfs]
[  521.784610]  xfs_trans_read_buf_map+0xef/0x2f0 [xfs]
[  521.786358]  xfs_read_agf+0x86/0x110 [xfs]
[  521.787898]  ? wakeup_preempt_entity.isra.76+0x39/0x50
[  521.789746]  xfs_alloc_read_agf+0x3e/0x140 [xfs]
[  521.791416]  xfs_alloc_fix_freelist+0x3e8/0x4e0 [xfs]
[  521.793231]  ? ttwu_do_activate.isra.66+0x6d/0x80
[  521.794951]  ? try_to_wake_up+0x23b/0x3c0
[  521.796443]  ? radix_tree_lookup+0xd/0x10
[  521.798011]  ? xfs_perag_get+0x16/0x50 [xfs]
[  521.799592]  ? xfs_bmap_longest_free_extent+0x8e/0xb0 [xfs]
[  521.801515]  xfs_alloc_vextent+0x15a/0x4a0 [xfs]
[  521.803210]  xfs_bmap_btalloc+0x33f/0x910 [xfs]
[  521.804884]  xfs_bmap_alloc+0x9/0x10 [xfs]
[  521.806382]  xfs_bmapi_write+0x7ca/0x1170 [xfs]
[  521.808072]  xfs_iomap_write_allocate+0x191/0x3b0 [xfs]
[  521.809953]  xfs_map_blocks+0x180/0x240 [xfs]
[  521.811527]  xfs_do_writepage+0x259/0x780 [xfs]
[  521.813200]  ? list_lru_add+0x3d/0xe0
[  521.814602]  xfs_vm_writepage+0x36/0x70 [xfs]
[  521.816171]  pageout.isra.53+0x195/0x2c0
[  521.817645]  shrink_page_list+0xa72/0xd50
[  521.819112]  shrink_inactive_list+0x239/0x4d0
[  521.820709]  ? radix_tree_gang_lookup_tag+0xd7/0x150
[  521.822599]  shrink_node_memcg+0x360/0x780
[  521.824238]  shrink_node+0xdc/0x310
[  521.825805]  ? shrink_node+0xdc/0x310
[  521.827318]  kswapd+0x373/0x6a0
[  521.828580]  kthread+0xff/0x140
[  521.829912]  ? mem_cgroup_shrink_node+0xb0/0xb0
[  521.831541]  ? kthread_create_on_node+0x60/0x60
[  521.833218]  ret_from_fork+0x25/0x30

[  522.064227] kworker/1:2     D11688   168      2 0x00000000
[  522.066193] Workqueue: xfs-eofblocks/sda1 xfs_eofblocks_worker [xfs]
[  522.068401] Call Trace:
[  522.069479]  __schedule+0x23f/0x5d0
[  522.070807]  schedule+0x31/0x80
[  522.072085]  schedule_timeout+0x1c1/0x290
[  522.073561]  ? init_object+0x64/0xa0
[  522.074956]  __down+0x85/0xd0
[  522.076122]  ? __down+0x85/0xd0
[  522.077381]  ? deactivate_slab.isra.83+0xa0/0x4b0
[  522.079052]  down+0x3c/0x50
[  522.080228]  ? down+0x3c/0x50
[  522.081403]  xfs_buf_lock+0x21/0x50 [xfs]
[  522.082919]  _xfs_buf_find+0x3cd/0x640 [xfs]
[  522.084521]  xfs_buf_get_map+0x25/0x150 [xfs]
[  522.086098]  xfs_buf_read_map+0x25/0xc0 [xfs]
[  522.087723]  xfs_trans_read_buf_map+0xef/0x2f0 [xfs]
[  522.089532]  xfs_read_agf+0x86/0x110 [xfs]
[  522.091034]  xfs_alloc_read_agf+0x3e/0x140 [xfs]
[  522.092730]  xfs_alloc_fix_freelist+0x3e8/0x4e0 [xfs]
[  522.094561]  ? kmem_zone_alloc+0x8a/0x110 [xfs]
[  522.096186]  ? set_track+0x6b/0x140
[  522.097565]  ? init_object+0x64/0xa0
[  522.098912]  ? ___slab_alloc+0x1b6/0x590
[  522.100391]  ? ___slab_alloc+0x1b6/0x590
[  522.101886]  xfs_free_extent_fix_freelist+0x78/0xe0 [xfs]
[  522.103767]  xfs_free_extent+0x6a/0x1d0 [xfs]
[  522.105396]  xfs_trans_free_extent+0x2c/0xb0 [xfs]
[  522.107145]  xfs_extent_free_finish_item+0x21/0x40 [xfs]
[  522.109003]  xfs_defer_finish+0x143/0x2b0 [xfs]
[  522.110686]  xfs_itruncate_extents+0x1a5/0x3d0 [xfs]
[  522.112499]  xfs_free_eofblocks+0x1a8/0x200 [xfs]
[  522.114191]  xfs_inode_free_eofblocks+0xe3/0x110 [xfs]
[  522.116056]  ? xfs_inode_ag_walk_grab+0x63/0xa0 [xfs]
[  522.117888]  xfs_inode_ag_walk.isra.23+0x20a/0x450 [xfs]
[  522.119808]  ? __xfs_inode_clear_eofblocks_tag+0x120/0x120 [xfs]
[  522.121921]  xfs_inode_ag_iterator_tag+0x6e/0xa0 [xfs]
[  522.123744]  ? __xfs_inode_clear_eofblocks_tag+0x120/0x120 [xfs]
[  522.125870]  xfs_eofblocks_worker+0x28/0x40 [xfs]
[  522.127617]  process_one_work+0x1f5/0x390
[  522.129111]  worker_thread+0x46/0x410
[  522.130531]  ? __schedule+0x247/0x5d0
[  522.132044]  kthread+0xff/0x140
[  522.133673]  ? process_one_work+0x390/0x390
[  522.135320]  ? kthread_create_on_node+0x60/0x60
[  522.137024]  ret_from_fork+0x25/0x30

[  526.558822] kworker/1:3     D12608  7805      2 0x00000080
[  526.560825] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  526.562636] Call Trace:
[  526.563678]  __schedule+0x23f/0x5d0
[  526.565058]  schedule+0x31/0x80
[  526.566295]  schedule_timeout+0x189/0x290
[  526.567823]  ? del_timer_sync+0x40/0x40
[  526.569339]  io_schedule_timeout+0x19/0x40
[  526.570849]  ? io_schedule_timeout+0x19/0x40
[  526.572434]  congestion_wait+0x7d/0xd0
[  526.573841]  ? wait_woken+0x80/0x80
[  526.575209]  shrink_inactive_list+0x3e3/0x4d0
[  526.576848]  shrink_node_memcg+0x360/0x780
[  526.578358]  shrink_node+0xdc/0x310
[  526.579760]  ? shrink_node+0xdc/0x310
[  526.581142]  do_try_to_free_pages+0xea/0x370
[  526.582720]  try_to_free_pages+0xc3/0x100
[  526.584251]  __alloc_pages_slowpath+0x441/0xd50
[  526.585882]  __alloc_pages_nodemask+0x20c/0x250
[  526.587539]  alloc_pages_current+0x65/0xd0
[  526.589045]  new_slab+0x472/0x600
[  526.590364]  ___slab_alloc+0x41b/0x590
[  526.591805]  ? kmem_alloc+0x8a/0x110 [xfs]
[  526.593313]  ? ___slab_alloc+0x1b6/0x590
[  526.594838]  ? kmem_alloc+0x8a/0x110 [xfs]
[  526.596346]  __slab_alloc+0x1b/0x30
[  526.598171]  ? __slab_alloc+0x1b/0x30
[  526.599658]  __kmalloc+0x17e/0x200
[  526.600959]  ? __slab_free+0x9f/0x300
[  526.602382]  kmem_alloc+0x8a/0x110 [xfs]
[  526.603839]  xfs_log_commit_cil+0x276/0x750 [xfs]
[  526.605563]  __xfs_trans_commit+0x7d/0x280 [xfs]
[  526.607256]  xfs_trans_commit+0xb/0x10 [xfs]
[  526.608814]  __xfs_setfilesize+0x7c/0xb0 [xfs]
[  526.610494]  xfs_setfilesize_ioend+0x41/0x60 [xfs]
[  526.612224]  xfs_end_io+0x44/0x130 [xfs]
[  526.613680]  process_one_work+0x1f5/0x390
[  526.615232]  worker_thread+0x46/0x410
[  526.616641]  ? __schedule+0x247/0x5d0
[  526.618029]  kthread+0xff/0x140
[  526.619319]  ? process_one_work+0x390/0x390
[  526.620845]  ? kthread_create_on_node+0x60/0x60
[  526.622497]  ret_from_fork+0x25/0x30

[  551.327823] c.out           D11000  8775   7943 0x00000080
[  551.329829] Call Trace:
[  551.330945]  __schedule+0x23f/0x5d0
[  551.332300]  schedule+0x31/0x80
[  551.333552]  schedule_timeout+0x189/0x290
[  551.335052]  ? release_pages+0x30f/0x3d0
[  551.336564]  ? del_timer_sync+0x40/0x40
[  551.338013]  io_schedule_timeout+0x19/0x40
[  551.339583]  ? io_schedule_timeout+0x19/0x40
[  551.341270]  congestion_wait+0x7d/0xd0
[  551.342696]  ? wait_woken+0x80/0x80
[  551.344077]  shrink_inactive_list+0x3e3/0x4d0
[  551.345672]  shrink_node_memcg+0x360/0x780
[  551.347237]  shrink_node+0xdc/0x310
[  551.348636]  ? shrink_node+0xdc/0x310
[  551.350027]  do_try_to_free_pages+0xea/0x370
[  551.351627]  try_to_free_pages+0xc3/0x100
[  551.353115]  __alloc_pages_slowpath+0x441/0xd50
[  551.355045]  ? account_page_dirtied+0x109/0x160
[  551.356768]  __alloc_pages_nodemask+0x20c/0x250
[  551.358458]  alloc_pages_current+0x65/0xd0
[  551.359980]  __page_cache_alloc+0x95/0xb0
[  551.361584]  __do_page_cache_readahead+0x10a/0x2d0
[  551.363307]  ? radix_tree_lookup_slot+0x22/0x50
[  551.364950]  ? find_get_entry+0x19/0x140
[  551.366458]  filemap_fault+0x4b1/0x760
[  551.367872]  ? filemap_fault+0x4b1/0x760
[  551.369430]  ? iomap_apply+0xc8/0x110
[  551.370909]  ? _cond_resched+0x15/0x40
[  551.372895]  xfs_filemap_fault+0x34/0x50 [xfs]
[  551.374640]  __do_fault+0x19/0xf0
[  551.376074]  __handle_mm_fault+0xb0b/0x1030
[  551.377612]  handle_mm_fault+0xf4/0x220
[  551.379086]  __do_page_fault+0x25b/0x4a0
[  551.380540]  do_page_fault+0x30/0x80
[  551.381940]  ? do_syscall_64+0xfd/0x140
[  551.383419]  page_fault+0x28/0x30
[  551.384693] RIP: 0033:0x7f9efff4fc90
[  551.386114] RSP: 002b:00007ffecf5cc0c8 EFLAGS: 00010246
[  551.388004] RAX: 0000000000001000 RBX: 0000000000000003 RCX: 00007f9efff4fc90
[  551.390470] RDX: 0000000000001000 RSI: 00000000006010c0 RDI: 0000000000000003
[  551.392898] RBP: 0000000000000003 R08: 00007f9effeaf938 R09: 000000000000000e
[  551.395300] R10: 00007ffecf5cbe50 R11: 0000000000000246 R12: 000000000040085d
[  551.397912] R13: 00007ffecf5cc1d0 R14: 0000000000000000 R15: 0000000000000000

[  563.729125] kworker/1:4     D11568  8980      2 0x00000080
[  563.731075] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  563.732874] Call Trace:
[  563.733893]  __schedule+0x23f/0x5d0
[  563.735218]  schedule+0x31/0x80
[  563.736493]  schedule_timeout+0x189/0x290
[  563.737985]  ? del_timer_sync+0x40/0x40
[  563.739399]  io_schedule_timeout+0x19/0x40
[  563.741018]  ? io_schedule_timeout+0x19/0x40
[  563.742560]  congestion_wait+0x7d/0xd0
[  563.743979]  ? wait_woken+0x80/0x80
[  563.745311]  shrink_inactive_list+0x3e3/0x4d0
[  563.746909]  shrink_node_memcg+0x360/0x780
[  563.748425]  shrink_node+0xdc/0x310
[  563.749739]  ? shrink_node+0xdc/0x310
[  563.751437]  do_try_to_free_pages+0xea/0x370
[  563.753020]  try_to_free_pages+0xc3/0x100
[  563.754486]  __alloc_pages_slowpath+0x441/0xd50
[  563.756234]  __alloc_pages_nodemask+0x20c/0x250
[  563.757884]  alloc_pages_current+0x65/0xd0
[  563.759375]  new_slab+0x472/0x600
[  563.760771]  ___slab_alloc+0x41b/0x590
[  563.762221]  ? kmem_alloc+0x8a/0x110 [xfs]
[  563.763751]  ? ___slab_alloc+0x1b6/0x590
[  563.765198]  ? kmem_alloc+0x8a/0x110 [xfs]
[  563.766741]  __slab_alloc+0x1b/0x30
[  563.768092]  ? __slab_alloc+0x1b/0x30
[  563.769450]  __kmalloc+0x17e/0x200
[  563.770786]  kmem_alloc+0x8a/0x110 [xfs]
[  563.772260]  xfs_log_commit_cil+0x276/0x750 [xfs]
[  563.773982]  __xfs_trans_commit+0x7d/0x280 [xfs]
[  563.775684]  xfs_trans_commit+0xb/0x10 [xfs]
[  563.777231]  __xfs_setfilesize+0x7c/0xb0 [xfs]
[  563.778850]  xfs_setfilesize_ioend+0x41/0x60 [xfs]
[  563.780580]  xfs_end_io+0x44/0x130 [xfs]
[  563.782051]  process_one_work+0x1f5/0x390
[  563.783573]  worker_thread+0x46/0x410
[  563.784938]  ? __schedule+0x247/0x5d0
[  563.786368]  kthread+0xff/0x140
[  563.787576]  ? process_one_work+0x390/0x390
[  563.789131]  ? kthread_create_on_node+0x60/0x60
[  563.790789]  ? do_syscall_64+0x13a/0x140
[  563.792221]  ret_from_fork+0x25/0x30

[  563.887126] kworker/1:5     D11320  8984      2 0x00000080
[  563.889083] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  563.890905] Call Trace:
[  563.891922]  __schedule+0x23f/0x5d0
[  563.893279]  schedule+0x31/0x80
[  563.894501]  schedule_timeout+0x189/0x290
[  563.896034]  ? del_timer_sync+0x40/0x40
[  563.897450]  io_schedule_timeout+0x19/0x40
[  563.898967]  ? io_schedule_timeout+0x19/0x40
[  563.900541]  congestion_wait+0x7d/0xd0
[  563.901937]  ? wait_woken+0x80/0x80
[  563.903282]  shrink_inactive_list+0x3e3/0x4d0
[  563.904853]  shrink_node_memcg+0x360/0x780
[  563.906403]  shrink_node+0xdc/0x310
[  563.907720]  ? shrink_node+0xdc/0x310
[  563.909133]  do_try_to_free_pages+0xea/0x370
[  563.910731]  try_to_free_pages+0xc3/0x100
[  563.912198]  __alloc_pages_slowpath+0x441/0xd50
[  563.913836]  __alloc_pages_nodemask+0x20c/0x250
[  563.915526]  alloc_pages_current+0x65/0xd0
[  563.917012]  new_slab+0x472/0x600
[  563.918291]  ___slab_alloc+0x41b/0x590
[  563.919687]  ? kmem_alloc+0x8a/0x110 [xfs]
[  563.921204]  ? ___slab_alloc+0x1b6/0x590
[  563.922647]  ? kmem_alloc+0x8a/0x110 [xfs]
[  563.924159]  __slab_alloc+0x1b/0x30
[  563.925593]  ? __slab_alloc+0x1b/0x30
[  563.926952]  __kmalloc+0x17e/0x200
[  563.928286]  kmem_alloc+0x8a/0x110 [xfs]
[  563.929724]  xfs_log_commit_cil+0x276/0x750 [xfs]
[  563.931446]  __xfs_trans_commit+0x7d/0x280 [xfs]
[  563.933086]  xfs_trans_commit+0xb/0x10 [xfs]
[  563.934631]  __xfs_setfilesize+0x7c/0xb0 [xfs]
[  563.936279]  xfs_setfilesize_ioend+0x41/0x60 [xfs]
[  563.938007]  xfs_end_io+0x44/0x130 [xfs]
[  563.939445]  process_one_work+0x1f5/0x390
[  563.941032]  worker_thread+0x46/0x410
[  563.942439]  ? __schedule+0x247/0x5d0
[  563.943850]  kthread+0xff/0x140
[  563.945056]  ? process_one_work+0x390/0x390
[  563.946616]  ? kthread_create_on_node+0x60/0x60
[  563.948261]  ? do_syscall_64+0x13a/0x140
[  563.949698]  ret_from_fork+0x25/0x30

[  563.951084] kworker/1:6     D12128  8985      2 0x00000080
[  563.953006] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[  563.954773] Call Trace:
[  563.955861]  __schedule+0x23f/0x5d0
[  563.957178]  schedule+0x31/0x80
[  563.958430]  schedule_timeout+0x189/0x290
[  563.959893]  ? del_timer_sync+0x40/0x40
[  563.961344]  io_schedule_timeout+0x19/0x40
[  563.962852]  ? io_schedule_timeout+0x19/0x40
[  563.964390]  congestion_wait+0x7d/0xd0
[  563.965843]  ? wait_woken+0x80/0x80
[  563.967153]  shrink_inactive_list+0x3e3/0x4d0
[  563.968781]  shrink_node_memcg+0x360/0x780
[  563.970268]  shrink_node+0xdc/0x310
[  563.971602]  ? shrink_node+0xdc/0x310
[  563.972983]  do_try_to_free_pages+0xea/0x370
[  563.974519]  try_to_free_pages+0xc3/0x100
[  563.976045]  __alloc_pages_slowpath+0x441/0xd50
[  563.977658]  __alloc_pages_nodemask+0x20c/0x250
[  563.979303]  alloc_pages_current+0x65/0xd0
[  563.980818]  new_slab+0x472/0x600
[  563.982079]  ___slab_alloc+0x41b/0x590
[  563.983499]  ? kmem_alloc+0x8a/0x110 [xfs]
[  563.984987]  ? ___slab_alloc+0x1b6/0x590
[  563.986552]  ? kmem_alloc+0x8a/0x110 [xfs]
[  563.988076]  __slab_alloc+0x1b/0x30
[  563.989384]  ? __slab_alloc+0x1b/0x30
[  563.990788]  __kmalloc+0x17e/0x200
[  563.992077]  kmem_alloc+0x8a/0x110 [xfs]
[  563.993586]  xfs_log_commit_cil+0x276/0x750 [xfs]
[  563.995257]  __xfs_trans_commit+0x7d/0x280 [xfs]
[  563.996950]  xfs_trans_commit+0xb/0x10 [xfs]
[  563.998530]  __xfs_setfilesize+0x7c/0xb0 [xfs]
[  564.000132]  xfs_setfilesize_ioend+0x41/0x60 [xfs]
[  564.001882]  xfs_end_io+0x44/0x130 [xfs]
[  564.003348]  process_one_work+0x1f5/0x390
[  564.004814]  worker_thread+0x46/0x410
[  564.006217]  ? __schedule+0x247/0x5d0
[  564.007578]  kthread+0xff/0x140
[  564.008837]  ? process_one_work+0x390/0x390
[  564.010392]  ? kthread_create_on_node+0x60/0x60
[  564.012005]  ret_from_fork+0x25/0x30
----------

I wish we can print how long each work remains
pending or in-flight. Something like below...

----------
diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index c102ef6..444f86f 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -101,6 +101,7 @@ struct work_struct {
 	atomic_long_t data;
 	struct list_head entry;
 	work_func_t func;
+	unsigned long stamp;
 #ifdef CONFIG_LOCKDEP
 	struct lockdep_map lockdep_map;
 #endif
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index a86688f..6be185a 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1296,6 +1296,7 @@ static void insert_work(struct pool_workqueue *pwq, struct work_struct *work,
 	struct worker_pool *pool = pwq->pool;
 
 	/* we own @work, set data and link */
+	work->stamp = jiffies;
 	set_work_pwq(work, pwq, extra_flags);
 	list_add_tail(&work->entry, head);
 	get_pwq(pwq);
@@ -4316,10 +4317,10 @@ static void pr_cont_work(bool comma, struct work_struct *work)
 
 		barr = container_of(work, struct wq_barrier, work);
 
-		pr_cont("%s BAR(%d)", comma ? "," : "",
-			task_pid_nr(barr->task));
+		pr_cont("%s BAR(%d){%lu}", comma ? "," : "",
+			task_pid_nr(barr->task), jiffies - work->stamp);
 	} else {
-		pr_cont("%s %pf", comma ? "," : "", work->func);
+		pr_cont("%s %pf{%lu}", comma ? "," : "", work->func, jiffies - work->stamp);
 	}
 }
 
@@ -4351,10 +4352,11 @@ static void show_pwq(struct pool_workqueue *pwq)
 			if (worker->current_pwq != pwq)
 				continue;
 
-			pr_cont("%s %d%s:%pf", comma ? "," : "",
+			pr_cont("%s %d%s:%pf{%lu}", comma ? "," : "",
 				task_pid_nr(worker->task),
 				worker == pwq->wq->rescuer ? "(RESCUER)" : "",
-				worker->current_func);
+				worker->current_func, worker->current_work ?
+				jiffies - worker->current_work->stamp : 0);
 			list_for_each_entry(work, &worker->scheduled, entry)
 				pr_cont_work(false, work);
 			comma = true;
----------

----------
[  872.639478] Showing busy workqueues and worker pools:
[  872.641577] workqueue events_freezable_power_: flags=0x84
[  872.643751]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  872.646118]     in-flight: 10905:disk_events_workfn{155066}
[  872.648446] workqueue writeback: flags=0x4e
[  872.650194]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[  872.652507]     in-flight: 354:wb_workfn{153828} wb_workfn{153828}
[  872.655406] workqueue xfs-eofblocks/sda1: flags=0xc
[  872.657444]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  872.659827]     in-flight: 3:xfs_eofblocks_worker [xfs]{146617}
[  872.662295] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=7 idle: 94 7730 9860 33 10902
[  872.665704] pool 128: cpus=0-63 flags=0x4 nice=0 hung=22s workers=3 idle: 353 352

[ 1107.349044] Showing busy workqueues and worker pools:
[ 1107.351129] workqueue events_freezable_power_: flags=0x84
[ 1107.353297]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1107.355662]     in-flight: 10905:disk_events_workfn{389810}
[ 1107.357929] workqueue writeback: flags=0x4e
[ 1107.359674]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[ 1107.362093]     in-flight: 354:wb_workfn{388572} wb_workfn{388572}
[ 1107.364976] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1107.366977]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1107.369354]     in-flight: 3:xfs_eofblocks_worker [xfs]{381361}
[ 1107.371770] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 94 7730
[ 1107.374847] pool 128: cpus=0-63 flags=0x4 nice=0 hung=257s workers=3 idle: 353 352

[ 1239.796406] Showing busy workqueues and worker pools:
[ 1239.798505] workqueue events_freezable_power_: flags=0x84
[ 1239.800809]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1239.803200]     in-flight: 10905:disk_events_workfn{522257}
[ 1239.805537] workqueue writeback: flags=0x4e
[ 1239.807338]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=2/256
[ 1239.809714]     in-flight: 354:wb_workfn{521034} wb_workfn{521034}
[ 1239.812589] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1239.814682]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1239.817207]     in-flight: 3:xfs_eofblocks_worker [xfs]{513823}
[ 1239.819686] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 94 7730
[ 1239.822659] pool 128: cpus=0-63 flags=0x4 nice=0 hung=389s workers=3 idle: 353 352
----------

I haven't succeeded reproducing mm_percpu_wq with this patch applied.
What is strange, "BUG: workqueue lockup" messages do not show up even though
SysRq-t says that pool 128 is hung...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
