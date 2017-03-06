Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 226DF6B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:08:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id l66so95875919pfl.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:08:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q12si19462417pli.218.2017.03.06.08.08.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 08:08:34 -0800 (PST)
Subject: Re: How to favor memory allocations for WQ_MEM_RECLAIM threads?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170303153720.GC21245@bfoster.bfoster>
	<20170303155258.GJ31499@dhcp22.suse.cz>
	<20170303172904.GE21245@bfoster.bfoster>
	<201703042354.DCH17637.JOHSFOQFFVOMLt@I-love.SAKURA.ne.jp>
	<20170306132517.GB3223@bfoster.bfoster>
In-Reply-To: <20170306132517.GB3223@bfoster.bfoster>
Message-Id: <201703070108.DFD48978.SMOVJHFFLFtOOQ@I-love.SAKURA.ne.jp>
Date: Tue, 7 Mar 2017 01:08:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bfoster@redhat.com
Cc: mhocko@kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org

Brian Foster wrote:
> As noted in my previous reply, I'm not sure there's enough here to point
> at allocation failure as the root cause. E.g., kswapd is stuck here:
> 
> [ 1095.632985] kswapd0         D10776    69      2 0x00000000
> [ 1095.632988] Call Trace:
> [ 1095.632991]  __schedule+0x336/0xe00
> [ 1095.632994]  schedule+0x3d/0x90
> [ 1095.632996]  io_schedule+0x16/0x40
> [ 1095.633017]  __xfs_iflock+0x129/0x140 [xfs]
> [ 1095.633021]  ? autoremove_wake_function+0x60/0x60
> [ 1095.633051]  xfs_reclaim_inode+0x162/0x440 [xfs]
> [ 1095.633072]  xfs_reclaim_inodes_ag+0x2cf/0x4f0 [xfs]
> [ 1095.633106]  ? xfs_reclaim_inodes_ag+0xf2/0x4f0 [xfs]
> [ 1095.633114]  ? trace_hardirqs_on+0xd/0x10
> [ 1095.633116]  ? try_to_wake_up+0x59/0x7a0
> [ 1095.633120]  ? wake_up_process+0x15/0x20
> [ 1095.633156]  xfs_reclaim_inodes_nr+0x33/0x40 [xfs]
> [ 1095.633178]  xfs_fs_free_cached_objects+0x19/0x20 [xfs]
> [ 1095.633180]  super_cache_scan+0x181/0x190
> [ 1095.633183]  shrink_slab+0x29f/0x6d0
> [ 1095.633189]  shrink_node+0x2fa/0x310
> [ 1095.633193]  kswapd+0x362/0x9b0
> [ 1095.633200]  kthread+0x10f/0x150
> [ 1095.633201]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
> [ 1095.633202]  ? kthread_create_on_node+0x70/0x70
> [ 1095.633205]  ret_from_fork+0x31/0x40
> 
> ... which is waiting on an inode flush lock. It can't get the lock
> (presumably) because xfsaild has it:
> 
> [ 1041.772095] xfsaild/sda1    D13216   457      2 0x00000000
> [ 1041.773726] Call Trace:
> [ 1041.774734]  __schedule+0x336/0xe00
> [ 1041.775956]  schedule+0x3d/0x90
> [ 1041.777105]  schedule_timeout+0x26a/0x510
> [ 1041.778426]  ? wait_for_completion+0x4c/0x190
> [ 1041.779824]  wait_for_completion+0x12c/0x190
> [ 1041.781273]  ? wake_up_q+0x80/0x80
> [ 1041.782597]  ? _xfs_buf_read+0x44/0x90 [xfs]
> [ 1041.784086]  xfs_buf_submit_wait+0xe9/0x5c0 [xfs]
> [ 1041.785659]  _xfs_buf_read+0x44/0x90 [xfs]
> [ 1041.787067]  xfs_buf_read_map+0xfa/0x400 [xfs]
> [ 1041.788501]  ? xfs_trans_read_buf_map+0x186/0x830 [xfs]
> [ 1041.790103]  xfs_trans_read_buf_map+0x186/0x830 [xfs]
> [ 1041.791672]  xfs_imap_to_bp+0x71/0x110 [xfs]
> [ 1041.793090]  xfs_iflush+0x122/0x3b0 [xfs]
> [ 1041.794444]  xfs_inode_item_push+0x108/0x1c0 [xfs]
> [ 1041.795956]  xfsaild_push+0x1d8/0xb70 [xfs]
> [ 1041.797344]  xfsaild+0x150/0x270 [xfs]
> [ 1041.798623]  kthread+0x10f/0x150
> [ 1041.799819]  ? xfsaild_push+0xb70/0xb70 [xfs]
> [ 1041.801217]  ? kthread_create_on_node+0x70/0x70
> [ 1041.802652]  ret_from_fork+0x31/0x40
> 
> xfsaild is flushing an inode, but is waiting on a read of the underlying
> inode cluster buffer such that it can flush out the in-core inode data
> structure. I cannot tell if the read had actually completed and is
> blocked somewhere else before running the completion. As Dave notes
> earlier, buffer I/O completion relies on the xfs-buf wq. What is evident
> from the logs is that xfs-buf has a rescuer thread that is sitting idle:
> 
> [ 1041.555227] xfs-buf/sda1    S14904   450      2 0x00000000
> [ 1041.556813] Call Trace:
> [ 1041.557796]  __schedule+0x336/0xe00
> [ 1041.558983]  schedule+0x3d/0x90
> [ 1041.560085]  rescuer_thread+0x322/0x3d0
> [ 1041.561333]  kthread+0x10f/0x150
> [ 1041.562464]  ? worker_thread+0x4b0/0x4b0
> [ 1041.563732]  ? kthread_create_on_node+0x70/0x70
> [ 1041.565123]  ret_from_fork+0x31/0x40
> 
> So AFAICT if the buffer I/O completion would run, it would allow xfsaild
> to progress, which would eventually flush the underlying buffer, write
> it, release the flush lock and allow kswapd to continue. The question is
> has the actually I/O completed? If so, is the xfs-buf workqueue stuck
> (waiting on an allocation perhaps)? And if that is the case, why is the
> xfs-buf rescuer thread not doing anything?

[ 1116.803780] workqueue xfs-data/sda1: flags=0xc
[ 1116.805324]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=27/256 MAYDAY
[ 1116.807272]     in-flight: 5356:xfs_end_io [xfs], 451(RESCUER):xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs] xfs_end_io [xfs], 10498:xfs_end_io [xfs], 6386:xfs_end_io [xfs]
[ 1116.812145]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io\
 [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[ 1116.820988]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=21/256 MAYDAY
[ 1116.823105]     in-flight: 535:xfs_end_io [xfs], 7416:xfs_end_io [xfs], 7415:xfs_end_io [xfs], 65:xfs_end_io [xfs]
[ 1116.826062]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io\
 [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
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

As listed below, all in-flight workqueues for processing xfs_end_io (PID = 5356,
451(RESCUER), 10498, 6386, 535, 7416, 7415, 65, 5357, 193, 52, 5358, 2486) are
stuck at memory allocation, and thus cannot call complete() when xfsaild/sda1
(PID = 457) is waiting at wait_for_completion(&bp->b_iowait) in xfs_buf_submit_wait().

[ 1095.644936] MemAlloc: kworker/3:3(5356) flags=0x4228860 switches=29192 seq=6 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652086
[ 1095.644937] kworker/3:3     R  running task    12760  5356      2 0x00000080
[ 1095.644959] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.644960] Call Trace:
[ 1095.644962]  __schedule+0x336/0xe00
[ 1095.644965]  preempt_schedule_common+0x1f/0x31
[ 1095.644966]  _cond_resched+0x1c/0x30
[ 1095.644968]  shrink_slab+0x339/0x6d0
[ 1095.644973]  shrink_node+0x2fa/0x310
[ 1095.644977]  do_try_to_free_pages+0xe1/0x300
[ 1095.644979]  try_to_free_pages+0x131/0x3f0
[ 1095.644984]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.644985]  ? cpuacct_charge+0xf3/0x1e0
[ 1095.644986]  ? cpuacct_charge+0x38/0x1e0
[ 1095.644992]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.644995]  alloc_pages_current+0x97/0x1b0
[ 1095.644998]  new_slab+0x4cb/0x6b0
[ 1095.645001]  ___slab_alloc+0x3a3/0x620
[ 1095.645023]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.645026]  ? ___slab_alloc+0x5c6/0x620
[ 1095.645027]  ? trace_hardirqs_on+0xd/0x10
[ 1095.645058]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.645066]  __slab_alloc+0x46/0x7d
[ 1095.645069]  __kmalloc+0x301/0x3b0
[ 1095.645088]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.645089]  ? kfree+0x1fa/0x330
[ 1095.645110]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.645132]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.645151]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.645169]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.645188]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.645204]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.645221]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.645223]  process_one_work+0x22b/0x760
[ 1095.645224]  ? process_one_work+0x194/0x760
[ 1095.645228]  worker_thread+0x137/0x4b0
[ 1095.645231]  kthread+0x10f/0x150
[ 1095.645232]  ? process_one_work+0x760/0x760
[ 1095.645233]  ? kthread_create_on_node+0x70/0x70
[ 1095.645236]  ret_from_fork+0x31/0x40

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

[ 1095.806606] MemAlloc: kworker/3:0(10498) flags=0x4228060 switches=16222 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652087
[ 1095.806607] kworker/3:0     R  running task    11352 10498      2 0x00000080
[ 1095.806631] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.806633] Call Trace:
[ 1095.806636]  __schedule+0x336/0xe00
[ 1095.806640]  schedule+0x3d/0x90
[ 1095.806641]  schedule_timeout+0x20d/0x510
[ 1095.806644]  ? lock_timer_base+0xa0/0xa0
[ 1095.806649]  schedule_timeout_uninterruptible+0x2a/0x30
[ 1095.806651]  __alloc_pages_slowpath+0x2b5/0xd95
[ 1095.806652]  ? cpuacct_charge+0xf3/0x1e0
[ 1095.806654]  ? cpuacct_charge+0x38/0x1e0
[ 1095.806663]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.806667]  alloc_pages_current+0x97/0x1b0
[ 1095.806671]  new_slab+0x4cb/0x6b0
[ 1095.806675]  ___slab_alloc+0x3a3/0x620
[ 1095.806698]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.806701]  ? ___slab_alloc+0x5c6/0x620
[ 1095.806721]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.806724]  __slab_alloc+0x46/0x7d
[ 1095.806727]  __kmalloc+0x301/0x3b0
[ 1095.806747]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.806749]  ? kfree+0x1fa/0x330
[ 1095.806771]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.806794]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.806813]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.806832]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.806852]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.806868]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.806886]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.806889]  process_one_work+0x22b/0x760
[ 1095.806890]  ? process_one_work+0x194/0x760
[ 1095.806896]  worker_thread+0x137/0x4b0
[ 1095.806899]  kthread+0x10f/0x150
[ 1095.806901]  ? process_one_work+0x760/0x760
[ 1095.806902]  ? kthread_create_on_node+0x70/0x70
[ 1095.806904]  ? do_syscall_64+0x195/0x200
[ 1095.806906]  ret_from_fork+0x31/0x40

[ 1095.647293] MemAlloc: kworker/3:5(6386) flags=0x4228860 switches=43427 seq=15 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652087
[ 1095.647294] kworker/3:5     R  running task    11048  6386      2 0x00000080
[ 1095.647754] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.648203] Call Trace:
[ 1095.648207]  __schedule+0x336/0xe00
[ 1095.648504]  preempt_schedule_common+0x1f/0x31
[ 1095.648806]  _cond_resched+0x1c/0x30
[ 1095.648952]  shrink_slab+0x339/0x6d0
[ 1095.649252]  shrink_node+0x2fa/0x310
[ 1095.649694]  do_try_to_free_pages+0xe1/0x300
[ 1095.649699]  try_to_free_pages+0x131/0x3f0
[ 1095.649996]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.650296]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.650743]  alloc_pages_current+0x97/0x1b0
[ 1095.650892]  new_slab+0x4cb/0x6b0
[ 1095.651193]  ___slab_alloc+0x3a3/0x620
[ 1095.652087]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.652400]  ? ___slab_alloc+0x5c6/0x620
[ 1095.653457]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.653901]  __slab_alloc+0x46/0x7d
[ 1095.654050]  __kmalloc+0x301/0x3b0
[ 1095.654948]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.655396]  ? kfree+0x1fa/0x330
[ 1095.656589]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.656919]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.656941]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.656961]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.658006]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.659053]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.660098]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.660846]  process_one_work+0x22b/0x760
[ 1095.660994]  ? process_one_work+0x194/0x760
[ 1095.661292]  worker_thread+0x137/0x4b0
[ 1095.661439]  kthread+0x10f/0x150
[ 1095.661741]  ? process_one_work+0x760/0x760
[ 1095.661743]  ? kthread_create_on_node+0x70/0x70
[ 1095.661891]  ret_from_fork+0x31/0x40

[ 1095.635223] MemAlloc: kworker/2:3(535) flags=0x4228860 switches=49285 seq=57 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652084
[ 1095.635224] kworker/2:3     R  running task    12272   535      2 0x00000000
[ 1095.635246] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.635247] Call Trace:
[ 1095.635250]  __schedule+0x336/0xe00
[ 1095.635253]  preempt_schedule_common+0x1f/0x31
[ 1095.635254]  _cond_resched+0x1c/0x30
[ 1095.635256]  shrink_slab+0x339/0x6d0
[ 1095.635263]  shrink_node+0x2fa/0x310
[ 1095.635267]  do_try_to_free_pages+0xe1/0x300
[ 1095.635271]  try_to_free_pages+0x131/0x3f0
[ 1095.635293]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.635301]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.635305]  alloc_pages_current+0x97/0x1b0
[ 1095.635308]  new_slab+0x4cb/0x6b0
[ 1095.635312]  ___slab_alloc+0x3a3/0x620
[ 1095.635351]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.635355]  ? ___slab_alloc+0x5c6/0x620
[ 1095.635375]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.635377]  __slab_alloc+0x46/0x7d
[ 1095.635380]  __kmalloc+0x301/0x3b0
[ 1095.635399]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.635400]  ? kfree+0x1fa/0x330
[ 1095.635421]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.635460]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.635494]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.635529]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.635549]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.635566]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.635583]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.635586]  process_one_work+0x22b/0x760
[ 1095.635587]  ? process_one_work+0x194/0x760
[ 1095.635591]  worker_thread+0x137/0x4b0
[ 1095.635594]  kthread+0x10f/0x150
[ 1095.635595]  ? process_one_work+0x760/0x760
[ 1095.635596]  ? kthread_create_on_node+0x70/0x70
[ 1095.635598]  ret_from_fork+0x31/0x40

[ 1095.663708] MemAlloc: kworker/2:5(7416) flags=0x4228060 switches=22830 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652069 uninterruptible
[ 1095.663708] kworker/2:5     D12272  7416      2 0x00000080
[ 1095.663738] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.663740] Call Trace:
[ 1095.663743]  __schedule+0x336/0xe00
[ 1095.663746]  schedule+0x3d/0x90
[ 1095.663747]  schedule_timeout+0x20d/0x510
[ 1095.663749]  ? lock_timer_base+0xa0/0xa0
[ 1095.663753]  schedule_timeout_uninterruptible+0x2a/0x30
[ 1095.663755]  __alloc_pages_slowpath+0x2b5/0xd95
[ 1095.663761]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.663765]  alloc_pages_current+0x97/0x1b0
[ 1095.663768]  new_slab+0x4cb/0x6b0
[ 1095.663771]  ___slab_alloc+0x3a3/0x620
[ 1095.663793]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.663795]  ? ___slab_alloc+0x5c6/0x620
[ 1095.663815]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.663817]  __slab_alloc+0x46/0x7d
[ 1095.663820]  __kmalloc+0x301/0x3b0
[ 1095.663859]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.663861]  ? kfree+0x1fa/0x330
[ 1095.663883]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.663905]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.663924]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.663942]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.663961]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.663996]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.664015]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.664017]  process_one_work+0x22b/0x760
[ 1095.664018]  ? process_one_work+0x194/0x760
[ 1095.664022]  worker_thread+0x137/0x4b0
[ 1095.664025]  kthread+0x10f/0x150
[ 1095.664026]  ? process_one_work+0x760/0x760
[ 1095.664027]  ? kthread_create_on_node+0x70/0x70
[ 1095.664030]  ret_from_fork+0x31/0x40

[ 1095.663334] MemAlloc: kworker/2:4(7415) flags=0x4228060 switches=23221 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652078 uninterruptible
[ 1095.663335] kworker/2:4     D11496  7415      2 0x00000080
[ 1095.663361] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.663362] Call Trace:
[ 1095.663366]  __schedule+0x336/0xe00
[ 1095.663369]  schedule+0x3d/0x90
[ 1095.663371]  schedule_timeout+0x20d/0x510
[ 1095.663407]  ? lock_timer_base+0xa0/0xa0
[ 1095.663412]  schedule_timeout_uninterruptible+0x2a/0x30
[ 1095.663414]  __alloc_pages_slowpath+0x2b5/0xd95
[ 1095.663421]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.663425]  alloc_pages_current+0x97/0x1b0
[ 1095.663428]  new_slab+0x4cb/0x6b0
[ 1095.663431]  ___slab_alloc+0x3a3/0x620
[ 1095.663457]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.663459]  ? ___slab_alloc+0x5c6/0x620
[ 1095.663481]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.663483]  __slab_alloc+0x46/0x7d
[ 1095.663485]  __kmalloc+0x301/0x3b0
[ 1095.663505]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.663507]  ? kfree+0x1fa/0x330
[ 1095.663548]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.663572]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.663591]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.663611]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.663630]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.663647]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.663664]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.663667]  process_one_work+0x22b/0x760
[ 1095.663668]  ? process_one_work+0x194/0x760
[ 1095.663672]  worker_thread+0x137/0x4b0
[ 1095.663674]  kthread+0x10f/0x150
[ 1095.663676]  ? process_one_work+0x760/0x760
[ 1095.663696]  ? kthread_create_on_node+0x70/0x70
[ 1095.663699]  ? do_syscall_64+0x195/0x200
[ 1095.663701]  ret_from_fork+0x31/0x40

[ 1095.632604] MemAlloc: kworker/2:1(65) flags=0x4228060 switches=22879 seq=2 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652043
[ 1095.632604] kworker/2:1     R  running task    12184    65      2 0x00000000
[ 1095.632641] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.632642] Call Trace:
[ 1095.632646]  __schedule+0x336/0xe00
[ 1095.632649]  schedule+0x3d/0x90
[ 1095.632651]  schedule_timeout+0x20d/0x510
[ 1095.632654]  ? lock_timer_base+0xa0/0xa0
[ 1095.632658]  schedule_timeout_uninterruptible+0x2a/0x30
[ 1095.632660]  __alloc_pages_slowpath+0x2b5/0xd95
[ 1095.632668]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.632672]  alloc_pages_current+0x97/0x1b0
[ 1095.632675]  new_slab+0x4cb/0x6b0
[ 1095.632678]  ___slab_alloc+0x3a3/0x620
[ 1095.632700]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.632702]  ? ___slab_alloc+0x5c6/0x620
[ 1095.632704]  ? free_debug_processing+0x27d/0x2af
[ 1095.632723]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.632725]  __slab_alloc+0x46/0x7d
[ 1095.632728]  __kmalloc+0x301/0x3b0
[ 1095.632765]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.632767]  ? kfree+0x1fa/0x330
[ 1095.632804]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.632828]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.632847]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.632865]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.632884]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.632916]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.632935]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.632938]  process_one_work+0x22b/0x760
[ 1095.632939]  ? process_one_work+0x194/0x760
[ 1095.632944]  worker_thread+0x137/0x4b0
[ 1095.632947]  kthread+0x10f/0x150
[ 1095.632949]  ? process_one_work+0x760/0x760
[ 1095.632960]  ? kthread_create_on_node+0x70/0x70
[ 1095.632963]  ret_from_fork+0x31/0x40

[ 1095.645241] MemAlloc: kworker/1:3(5357) flags=0x4228860 switches=30893 seq=3 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652084
[ 1095.645242] kworker/1:3     R  running task    12184  5357      2 0x00000080
[ 1095.645261] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.645262] Call Trace:
[ 1095.645263]  ? shrink_node+0x2fa/0x310
[ 1095.645267]  ? do_try_to_free_pages+0xe1/0x300
[ 1095.645270]  ? try_to_free_pages+0x131/0x3f0
[ 1095.645274]  ? __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.645280]  ? __alloc_pages_nodemask+0x3e4/0x460
[ 1095.645283]  ? alloc_pages_current+0x97/0x1b0
[ 1095.645286]  ? new_slab+0x4cb/0x6b0
[ 1095.645289]  ? ___slab_alloc+0x3a3/0x620
[ 1095.645310]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.645312]  ? ___slab_alloc+0x5c6/0x620
[ 1095.645331]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.645333]  ? __slab_alloc+0x46/0x7d
[ 1095.645335]  ? __kmalloc+0x301/0x3b0
[ 1095.645355]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.645356]  ? kfree+0x1fa/0x330
[ 1095.645377]  ? xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.645398]  ? __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.645417]  ? xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.645435]  ? __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.645453]  ? xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.645470]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.645486]  ? xfs_end_io+0x81/0x110 [xfs]
[ 1095.645489]  ? process_one_work+0x22b/0x760
[ 1095.645490]  ? process_one_work+0x194/0x760
[ 1095.645493]  ? worker_thread+0x137/0x4b0
[ 1095.645496]  ? kthread+0x10f/0x150
[ 1095.645497]  ? process_one_work+0x760/0x760
[ 1095.645498]  ? kthread_create_on_node+0x70/0x70
[ 1095.645501]  ? ret_from_fork+0x31/0x40

[ 1095.633213] MemAlloc: kworker/1:2(193) flags=0x4228860 switches=28494 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652084
[ 1095.633213] kworker/1:2     R  running task    12760   193      2 0x00000000
[ 1095.633236] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.633237] Call Trace:
[ 1095.633240]  __schedule+0x336/0xe00
[ 1095.633260]  preempt_schedule_common+0x1f/0x31
[ 1095.633261]  _cond_resched+0x1c/0x30
[ 1095.633263]  shrink_slab+0x339/0x6d0
[ 1095.633270]  shrink_node+0x2fa/0x310
[ 1095.633275]  do_try_to_free_pages+0xe1/0x300
[ 1095.633278]  try_to_free_pages+0x131/0x3f0
[ 1095.633283]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.633292]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.633295]  alloc_pages_current+0x97/0x1b0
[ 1095.633298]  new_slab+0x4cb/0x6b0
[ 1095.633318]  ___slab_alloc+0x3a3/0x620
[ 1095.633349]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.633353]  ? ___slab_alloc+0x5c6/0x620
[ 1095.633373]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.633375]  __slab_alloc+0x46/0x7d
[ 1095.633378]  __kmalloc+0x301/0x3b0
[ 1095.633397]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.633398]  ? kfree+0x1fa/0x330
[ 1095.633436]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.633464]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.633500]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.633520]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.633538]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.633555]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.633572]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.633575]  process_one_work+0x22b/0x760
[ 1095.633576]  ? process_one_work+0x194/0x760
[ 1095.633597]  worker_thread+0x137/0x4b0
[ 1095.633602]  kthread+0x10f/0x150
[ 1095.633603]  ? process_one_work+0x760/0x760
[ 1095.633604]  ? kthread_create_on_node+0x70/0x70
[ 1095.633607]  ret_from_fork+0x31/0x40

[ 1095.632186] MemAlloc: kworker/1:1(52) flags=0x4228860 switches=28036 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652083
[ 1095.632186] kworker/1:1     R  running task    12760    52      2 0x00000000
[ 1095.632209] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.632210] Call Trace:
[ 1095.632213]  ? _raw_spin_lock+0x69/0x80
[ 1095.632214]  ? __list_lru_count_one.isra.2+0x22/0x80
[ 1095.632216]  ? __list_lru_count_one.isra.2+0x22/0x80
[ 1095.632217]  ? list_lru_count_one+0x23/0x30
[ 1095.632219]  ? super_cache_count+0x6c/0xe0
[ 1095.632221]  ? shrink_slab+0x15c/0x6d0
[ 1095.632241]  ? mem_cgroup_iter+0x14d/0x720
[ 1095.632244]  ? css_next_child+0x17/0xd0
[ 1095.632247]  ? shrink_node+0x2fa/0x310
[ 1095.632251]  ? do_try_to_free_pages+0xe1/0x300
[ 1095.632254]  ? try_to_free_pages+0x131/0x3f0
[ 1095.632258]  ? __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.632265]  ? __alloc_pages_nodemask+0x3e4/0x460
[ 1095.632268]  ? alloc_pages_current+0x97/0x1b0
[ 1095.632271]  ? new_slab+0x4cb/0x6b0
[ 1095.632274]  ? ___slab_alloc+0x3a3/0x620
[ 1095.632313]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.632317]  ? ___slab_alloc+0x5c6/0x620
[ 1095.632337]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.632339]  ? __slab_alloc+0x46/0x7d
[ 1095.632341]  ? __kmalloc+0x301/0x3b0
[ 1095.632371]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.632373]  ? kfree+0x1fa/0x330
[ 1095.632412]  ? xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.632443]  ? __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.632480]  ? xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.632500]  ? __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.632519]  ? xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.632536]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.632553]  ? xfs_end_io+0x81/0x110 [xfs]
[ 1095.632556]  ? process_one_work+0x22b/0x760
[ 1095.632558]  ? process_one_work+0x194/0x760
[ 1095.632588]  ? worker_thread+0x137/0x4b0
[ 1095.632591]  ? kthread+0x10f/0x150
[ 1095.632592]  ? process_one_work+0x760/0x760
[ 1095.632593]  ? kthread_create_on_node+0x70/0x70
[ 1095.632596]  ? ret_from_fork+0x31/0x40

[ 1095.645506] MemAlloc: kworker/1:4(5358) flags=0x4228060 switches=27329 seq=1 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652084
[ 1095.645506] kworker/1:4     R  running task    12272  5358      2 0x00000080
[ 1095.645525] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.645526] Call Trace:
[ 1095.645528]  __schedule+0x336/0xe00
[ 1095.645531]  schedule+0x3d/0x90
[ 1095.645532]  schedule_timeout+0x20d/0x510
[ 1095.645534]  ? lock_timer_base+0xa0/0xa0
[ 1095.645538]  schedule_timeout_uninterruptible+0x2a/0x30
[ 1095.645540]  __alloc_pages_slowpath+0x2b5/0xd95
[ 1095.645546]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.645550]  alloc_pages_current+0x97/0x1b0
[ 1095.645552]  new_slab+0x4cb/0x6b0
[ 1095.645555]  ___slab_alloc+0x3a3/0x620
[ 1095.645576]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.645578]  ? ___slab_alloc+0x5c6/0x620
[ 1095.645597]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.645599]  __slab_alloc+0x46/0x7d
[ 1095.645601]  __kmalloc+0x301/0x3b0
[ 1095.645620]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.645621]  ? kfree+0x1fa/0x330
[ 1095.645642]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.645663]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.645681]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.645699]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.646636]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.647249]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.647269]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.647273]  process_one_work+0x22b/0x760
[ 1095.647274]  ? process_one_work+0x194/0x760
[ 1095.647277]  worker_thread+0x137/0x4b0
[ 1095.647280]  kthread+0x10f/0x150
[ 1095.647281]  ? process_one_work+0x760/0x760
[ 1095.647283]  ? kthread_create_on_node+0x70/0x70
[ 1095.647285]  ret_from_fork+0x31/0x40

[ 1095.638807] MemAlloc: kworker/0:3(2486) flags=0x4228860 switches=76240 seq=10 gfp=0x1604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=652064
[ 1095.638807] kworker/0:3     R  running task    11608  2486      2 0x00000080
[ 1095.638829] Workqueue: xfs-data/sda1 xfs_end_io [xfs]
[ 1095.638830] Call Trace:
[ 1095.638833]  __schedule+0x336/0xe00
[ 1095.638837]  preempt_schedule_common+0x1f/0x31
[ 1095.638838]  _cond_resched+0x1c/0x30
[ 1095.638839]  shrink_slab+0x339/0x6d0
[ 1095.638846]  shrink_node+0x2fa/0x310
[ 1095.638850]  do_try_to_free_pages+0xe1/0x300
[ 1095.638854]  try_to_free_pages+0x131/0x3f0
[ 1095.638859]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1095.638866]  __alloc_pages_nodemask+0x3e4/0x460
[ 1095.638871]  alloc_pages_current+0x97/0x1b0
[ 1095.638874]  new_slab+0x4cb/0x6b0
[ 1095.638878]  ___slab_alloc+0x3a3/0x620
[ 1095.638900]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.638903]  ? ___slab_alloc+0x5c6/0x620
[ 1095.638923]  ? kmem_alloc+0x96/0x120 [xfs]
[ 1095.638925]  __slab_alloc+0x46/0x7d
[ 1095.638928]  __kmalloc+0x301/0x3b0
[ 1095.638947]  kmem_alloc+0x96/0x120 [xfs]
[ 1095.638948]  ? kfree+0x1fa/0x330
[ 1095.638970]  xfs_log_commit_cil+0x489/0x710 [xfs]
[ 1095.638992]  __xfs_trans_commit+0x83/0x260 [xfs]
[ 1095.639011]  xfs_trans_commit+0x10/0x20 [xfs]
[ 1095.639030]  __xfs_setfilesize+0xdb/0x240 [xfs]
[ 1095.639066]  xfs_setfilesize_ioend+0x89/0xb0 [xfs]
[ 1095.639083]  ? xfs_setfilesize_ioend+0x5/0xb0 [xfs]
[ 1095.639100]  xfs_end_io+0x81/0x110 [xfs]
[ 1095.639103]  process_one_work+0x22b/0x760
[ 1095.639104]  ? process_one_work+0x194/0x760
[ 1095.639108]  worker_thread+0x137/0x4b0
[ 1095.639111]  kthread+0x10f/0x150
[ 1095.639112]  ? process_one_work+0x760/0x760
[ 1095.639113]  ? kthread_create_on_node+0x70/0x70
[ 1095.639116]  ? do_syscall_64+0x6c/0x200
[ 1095.639118]  ret_from_fork+0x31/0x40

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
