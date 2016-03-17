Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2926B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:35:51 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id x3so117437249pfb.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:35:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c90si11983033pfd.233.2016.03.17.04.35.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 04:35:50 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: throttle on IO only when there are too many dirty and writeback pages
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<1450203586-10959-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1450203586-10959-3-git-send-email-mhocko@kernel.org>
Message-Id: <201603172035.CJH95337.SOJOFFFHMLOQVt@I-love.SAKURA.ne.jp>
Date: Thu, 17 Mar 2016 20:35:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Today I was testing

----------
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 6915c950e6e8..aa52e23ac280 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -887,7 +887,7 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 {
 	struct wb_writeback_work *work;
 
-	if (!wb_has_dirty_io(wb))
+	if (!wb_has_dirty_io(wb) || writeback_in_progress(wb))
 		return;
 
 	/*
----------

using next-20160317, and I got below results.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160317.txt.xz .
---------- console log ----------
[ 1354.048836] Out of memory: Kill process 3641 (file_io.02) score 1000 or sacrifice child
[ 1354.054773] Killed process 3641 (file_io.02) total-vm:4308kB, anon-rss:104kB, file-rss:1264kB, shmem-rss:0kB
[ 1593.471245] sysrq: SysRq : Show State
(...snipped...)
[ 1595.944649] kswapd0         D ffff88003681f760     0    53      2 0x00000000
[ 1595.949872]  ffff88003681f760 ffff88003fbfa140 ffff88003681a040 ffff880036820000
[ 1595.955342]  ffff88002b5e0750 ffff88002b5e0768 ffff88003681f958 0000000000000001
[ 1595.960826]  ffff88003681f778 ffffffff81660570 ffff88003681a040 ffff88003681f7d8
[ 1595.966319] Call Trace:
[ 1595.968662]  [<ffffffff81660570>] schedule+0x30/0x80
[ 1595.972552]  [<ffffffff81663fd6>] rwsem_down_read_failed+0xd6/0x140
[ 1595.977199]  [<ffffffff81322d98>] call_rwsem_down_read_failed+0x18/0x30
[ 1595.982087]  [<ffffffff810b8b4b>] down_read_nested+0x3b/0x50
[ 1595.986370]  [<ffffffffa024bcbb>] ? xfs_ilock+0x4b/0xe0 [xfs]
[ 1595.990681]  [<ffffffffa024bcbb>] xfs_ilock+0x4b/0xe0 [xfs]
[ 1595.994898]  [<ffffffffa0236330>] xfs_map_blocks+0x80/0x150 [xfs]
[ 1595.999441]  [<ffffffffa02372db>] xfs_do_writepage+0x15b/0x500 [xfs]
[ 1596.004138]  [<ffffffffa02376b6>] xfs_vm_writepage+0x36/0x70 [xfs]
[ 1596.008692]  [<ffffffff811538ef>] pageout.isra.43+0x18f/0x240
[ 1596.012938]  [<ffffffff81155253>] shrink_page_list+0x803/0xae0
[ 1596.017247]  [<ffffffff81155c8b>] shrink_inactive_list+0x1fb/0x460
[ 1596.021771]  [<ffffffff81156896>] shrink_zone_memcg+0x5b6/0x780
[ 1596.026103]  [<ffffffff81156b34>] shrink_zone+0xd4/0x2f0
[ 1596.030111]  [<ffffffff811579e1>] kswapd+0x441/0x830
[ 1596.033847]  [<ffffffff811575a0>] ? mem_cgroup_shrink_node_zone+0xb0/0xb0
[ 1596.038786]  [<ffffffff8109196e>] kthread+0xee/0x110
[ 1596.042546]  [<ffffffff81665672>] ret_from_fork+0x22/0x50
[ 1596.046591]  [<ffffffff81091880>] ? kthread_create_on_node+0x230/0x230
(...snipped...)
[ 1596.216946] kworker/u128:1  D ffff8800368eaf78     0    70      2 0x00000000
[ 1596.222105] Workqueue: writeback wb_workfn (flush-8:0)
[ 1596.226009]  ffff8800368eaf78 ffff88003aa4c040 ffff88003686c0c0 ffff8800368ec000
[ 1596.231502]  ffff8800368eafb0 ffff88003d610300 000000010013c47d ffff88003ffdf100
[ 1596.237003]  ffff8800368eaf90 ffffffff81660570 ffff88003d610300 ffff8800368eb038
[ 1596.242505] Call Trace:
[ 1596.244750]  [<ffffffff81660570>] schedule+0x30/0x80
[ 1596.248519]  [<ffffffff816645f7>] schedule_timeout+0x117/0x1c0
[ 1596.252841]  [<ffffffff810bc5c6>] ? mark_held_locks+0x66/0x90
[ 1596.257153]  [<ffffffff810df270>] ? init_timer_key+0x40/0x40
[ 1596.261424]  [<ffffffff810e60f7>] ? ktime_get+0xa7/0x130
[ 1596.265390]  [<ffffffff8165fab1>] io_schedule_timeout+0xa1/0x110
[ 1596.269836]  [<ffffffff8116104d>] congestion_wait+0x7d/0xd0
[ 1596.273978]  [<ffffffff810b6620>] ? wait_woken+0x80/0x80
[ 1596.278153]  [<ffffffff8114a982>] __alloc_pages_nodemask+0xb42/0xd50
[ 1596.283301]  [<ffffffff81193876>] alloc_pages_current+0x96/0x1b0
[ 1596.287737]  [<ffffffffa0270d70>] xfs_buf_allocate_memory+0x170/0x2ab [xfs]
[ 1596.292829]  [<ffffffffa023c9aa>] xfs_buf_get_map+0xfa/0x160 [xfs]
[ 1596.297457]  [<ffffffffa023cea9>] xfs_buf_read_map+0x29/0xe0 [xfs]
[ 1596.302034]  [<ffffffffa02670e7>] xfs_trans_read_buf_map+0x97/0x1a0 [xfs]
[ 1596.307004]  [<ffffffffa02171b3>] xfs_btree_read_buf_block.constprop.29+0x73/0xc0 [xfs]
[ 1596.312736]  [<ffffffffa021727b>] xfs_btree_lookup_get_block+0x7b/0xf0 [xfs]
[ 1596.317859]  [<ffffffffa021b981>] xfs_btree_lookup+0xc1/0x580 [xfs]
[ 1596.322448]  [<ffffffffa0205dcc>] ? xfs_allocbt_init_cursor+0x3c/0xc0 [xfs]
[ 1596.327478]  [<ffffffffa0204290>] xfs_alloc_ag_vextent_near+0xb0/0x880 [xfs]
[ 1596.332841]  [<ffffffffa0204b57>] xfs_alloc_ag_vextent+0xf7/0x130 [xfs]
[ 1596.338547]  [<ffffffffa02056a2>] xfs_alloc_vextent+0x3b2/0x480 [xfs]
[ 1596.343706]  [<ffffffffa021316f>] xfs_bmap_btalloc+0x3bf/0x710 [xfs]
[ 1596.348841]  [<ffffffffa02134c9>] xfs_bmap_alloc+0x9/0x10 [xfs]
[ 1596.353988]  [<ffffffffa0213eba>] xfs_bmapi_write+0x47a/0xa10 [xfs]
[ 1596.359255]  [<ffffffffa02493cd>] xfs_iomap_write_allocate+0x16d/0x380 [xfs]
[ 1596.365138]  [<ffffffffa02363ed>] xfs_map_blocks+0x13d/0x150 [xfs]
[ 1596.370046]  [<ffffffffa02372db>] xfs_do_writepage+0x15b/0x500 [xfs]
[ 1596.375322]  [<ffffffff8114d756>] write_cache_pages+0x1f6/0x490
[ 1596.380014]  [<ffffffffa0237180>] ? xfs_aops_discard_page+0x140/0x140 [xfs]
[ 1596.385220]  [<ffffffffa0236fa6>] xfs_vm_writepages+0x66/0xa0 [xfs]
[ 1596.389823]  [<ffffffff8114e8bc>] do_writepages+0x1c/0x30
[ 1596.393865]  [<ffffffff811ed543>] __writeback_single_inode+0x33/0x170
[ 1596.398583]  [<ffffffff811ede3e>] writeback_sb_inodes+0x2ce/0x570
[ 1596.403200]  [<ffffffff811ee167>] __writeback_inodes_wb+0x87/0xc0
[ 1596.407955]  [<ffffffff811ee38b>] wb_writeback+0x1eb/0x220
[ 1596.412037]  [<ffffffff811eea2f>] wb_workfn+0x1df/0x2b0
[ 1596.416133]  [<ffffffff8108b2c5>] process_one_work+0x1a5/0x400
[ 1596.420437]  [<ffffffff8108b261>] ? process_one_work+0x141/0x400
[ 1596.424836]  [<ffffffff8108b646>] worker_thread+0x126/0x490
[ 1596.428948]  [<ffffffff8108b520>] ? process_one_work+0x400/0x400
[ 1596.433635]  [<ffffffff8109196e>] kthread+0xee/0x110
[ 1596.437346]  [<ffffffff81665672>] ret_from_fork+0x22/0x50
[ 1596.441325]  [<ffffffff81091880>] ? kthread_create_on_node+0x230/0x230
(...snipped...)
[ 1599.581883] kworker/0:2     D ffff880036743878     0  3476      2 0x00000080
[ 1599.587099] Workqueue: events_freezable_power_ disk_events_workfn
[ 1599.591615]  ffff880036743878 ffffffff81c0d540 ffff880039c02040 ffff880036744000
[ 1599.597112]  ffff8800367438b0 ffff88003d610300 000000010013d1a9 ffff88003ffdf100
[ 1599.602613]  ffff880036743890 ffffffff81660570 ffff88003d610300 ffff880036743938
[ 1599.608068] Call Trace:
[ 1599.610155]  [<ffffffff81660570>] schedule+0x30/0x80
[ 1599.613996]  [<ffffffff816645f7>] schedule_timeout+0x117/0x1c0
[ 1599.618285]  [<ffffffff810bc5c6>] ? mark_held_locks+0x66/0x90
[ 1599.622537]  [<ffffffff810df270>] ? init_timer_key+0x40/0x40
[ 1599.626721]  [<ffffffff810e60f7>] ? ktime_get+0xa7/0x130
[ 1599.630666]  [<ffffffff8165fab1>] io_schedule_timeout+0xa1/0x110
[ 1599.635108]  [<ffffffff8116104d>] congestion_wait+0x7d/0xd0
[ 1599.639234]  [<ffffffff810b6620>] ? wait_woken+0x80/0x80
[ 1599.643156]  [<ffffffff8114a982>] __alloc_pages_nodemask+0xb42/0xd50
[ 1599.647774]  [<ffffffff810bc500>] ? mark_lock+0x620/0x680
[ 1599.651785]  [<ffffffff81193876>] alloc_pages_current+0x96/0x1b0
[ 1599.656235]  [<ffffffff812e108d>] ? bio_alloc_bioset+0x20d/0x2d0
[ 1599.660662]  [<ffffffff812e2454>] bio_copy_kern+0xc4/0x180
[ 1599.664702]  [<ffffffff812ed070>] blk_rq_map_kern+0x70/0x130
[ 1599.668864]  [<ffffffff8144c4bd>] scsi_execute+0x12d/0x160
[ 1599.672950]  [<ffffffff8144c5e4>] scsi_execute_req_flags+0x84/0xf0
[ 1599.677784]  [<ffffffffa01e8762>] sr_check_events+0xb2/0x2a0 [sr_mod]
[ 1599.682744]  [<ffffffffa01ce163>] cdrom_check_events+0x13/0x30 [cdrom]
[ 1599.687747]  [<ffffffffa01e8ba5>] sr_block_check_events+0x25/0x30 [sr_mod]
[ 1599.692752]  [<ffffffff812f874b>] disk_check_events+0x5b/0x150
[ 1599.697130]  [<ffffffff812f8857>] disk_events_workfn+0x17/0x20
[ 1599.701783]  [<ffffffff8108b2c5>] process_one_work+0x1a5/0x400
[ 1599.706347]  [<ffffffff8108b261>] ? process_one_work+0x141/0x400
[ 1599.710809]  [<ffffffff8108b646>] worker_thread+0x126/0x490
[ 1599.715005]  [<ffffffff8108b520>] ? process_one_work+0x400/0x400
[ 1599.719427]  [<ffffffff8109196e>] kthread+0xee/0x110
[ 1599.723220]  [<ffffffff81665672>] ret_from_fork+0x22/0x50
[ 1599.727240]  [<ffffffff81091880>] ? kthread_create_on_node+0x230/0x230
(...snipped...)
[ 1698.163933] 1 lock held by kswapd0/53:
[ 1698.166948]  #0:  (&xfs_nondir_ilock_class){++++--}, at: [<ffffffffa024bcbb>] xfs_ilock+0x4b/0xe0 [xfs]
[ 1698.174361] 5 locks held by kworker/u128:1/70:
[ 1698.177849]  #0:  ("writeback"){.+.+.+}, at: [<ffffffff8108b261>] process_one_work+0x141/0x400
[ 1698.184626]  #1:  ((&(&wb->dwork)->work)){+.+.+.}, at: [<ffffffff8108b261>] process_one_work+0x141/0x400
[ 1698.191670]  #2:  (&type->s_umount_key#30){++++++}, at: [<ffffffff811c35d6>] trylock_super+0x16/0x50
[ 1698.198449]  #3:  (sb_internal){.+.+.?}, at: [<ffffffff811c35ac>] __sb_start_write+0xcc/0xe0
[ 1698.204743]  #4:  (&xfs_nondir_ilock_class){++++--}, at: [<ffffffffa024bcef>] xfs_ilock+0x7f/0xe0 [xfs]
(...snipped...)
[ 1698.222061] 2 locks held by kworker/0:2/3476:
[ 1698.225546]  #0:  ("events_freezable_power_efficient"){.+.+.+}, at: [<ffffffff8108b261>] process_one_work+0x141/0x400
[ 1698.233350]  #1:  ((&(&ev->dwork)->work)){+.+.+.}, at: [<ffffffff8108b261>] process_one_work+0x141/0x400
(...snipped...)
[ 1718.427909] Showing busy workqueues and worker pools:
[ 1718.432224] workqueue events: flags=0x0
[ 1718.435754]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[ 1718.440769]     in-flight: 52:mptspi_dv_renegotiate_work [mptspi]
[ 1718.445766]     pending: vmpressure_work_fn, cache_reap
[ 1718.450227] workqueue events_power_efficient: flags=0x80
[ 1718.454645]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1718.459663]     pending: fb_flashcursor
[ 1718.463133] workqueue events_freezable_power_: flags=0x84
[ 1718.467620]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1718.472552]     in-flight: 3476:disk_events_workfn
[ 1718.476643] workqueue writeback: flags=0x4e
[ 1718.480197]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/256
[ 1718.484977]     in-flight: 70:wb_workfn
[ 1718.488671] workqueue vmstat: flags=0xc
[ 1718.492312]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256 MAYDAY
[ 1718.497665]     pending: vmstat_update
[ 1718.501304] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3451 3501
[ 1718.507471] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=15s workers=2 manager: 3490
[ 1718.513528] pool 128: cpus=0-63 flags=0x4 nice=0 hung=0s workers=3 manager: 3471 idle: 6
[ 1745.495540] sysrq: SysRq : Show Memory
[ 1745.508581] Mem-Info:
[ 1745.516772] active_anon:182211 inactive_anon:12238 isolated_anon:0
[ 1745.516772]  active_file:6978 inactive_file:19887 isolated_file:32
[ 1745.516772]  unevictable:0 dirty:19697 writeback:214 unstable:0
[ 1745.516772]  slab_reclaimable:2382 slab_unreclaimable:8786
[ 1745.516772]  mapped:6820 shmem:12582 pagetables:1311 bounce:0
[ 1745.516772]  free:1877 free_pcp:132 free_cma:0
[ 1745.563639] Node 0 DMA free:3868kB min:60kB low:72kB high:84kB active_anon:6184kB inactive_anon:1120kB active_file:644kB inactive_file:1784kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:1784kB writeback:0kB mapped:644kB shmem:1172kB slab_reclaimable:220kB slab_unreclaimable:660kB kernel_stack:496kB pagetables:252kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:15392 all_unreclaimable? yes
[ 1745.595872] lowmem_reserve[]: 0 953 953 953
[ 1745.599508] Node 0 DMA32 free:3640kB min:3780kB low:4752kB high:5724kB active_anon:722660kB inactive_anon:47832kB active_file:27268kB inactive_file:77764kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:1032064kB managed:980852kB mlocked:0kB dirty:77004kB writeback:856kB mapped:26636kB shmem:49156kB slab_reclaimable:9308kB slab_unreclaimable:34484kB kernel_stack:19760kB pagetables:4992kB unstable:0kB bounce:0kB free_pcp:528kB local_pcp:60kB free_cma:0kB writeback_tmp:0kB pages_scanned:1387692 all_unreclaimable? yes
[ 1745.633558] lowmem_reserve[]: 0 0 0 0
[ 1745.636871] Node 0 DMA: 25*4kB (UME) 9*8kB (UME) 7*16kB (UME) 2*32kB (ME) 3*64kB (ME) 4*128kB (UE) 3*256kB (UME) 4*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3868kB
[ 1745.648828] Node 0 DMA32: 886*4kB (UE) 8*8kB (UM) 2*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3640kB
[ 1745.658179] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 1745.664712] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1745.671127] 39477 total pagecache pages
[ 1745.674392] 0 pages in swap cache
[ 1745.677315] Swap cache stats: add 0, delete 0, find 0/0
[ 1745.681493] Free swap  = 0kB
[ 1745.684113] Total swap = 0kB
[ 1745.686786] 262013 pages RAM
[ 1745.689386] 0 pages HighMem/MovableOnly
[ 1745.692883] 12824 pages reserved
[ 1745.695779] 0 pages cma reserved
[ 1745.698763] 0 pages hwpoisoned
[ 1746.841678] BUG: workqueue lockup - pool cpus=2 node=0 flags=0x0 nice=0 stuck for 44s!
[ 1746.866634] Showing busy workqueues and worker pools:
[ 1746.881055] workqueue events: flags=0x0
[ 1746.887480]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=3/256
[ 1746.894205]     in-flight: 52:mptspi_dv_renegotiate_work [mptspi]
[ 1746.900892]     pending: vmpressure_work_fn, cache_reap
[ 1746.906938] workqueue events_power_efficient: flags=0x80
[ 1746.912780]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[ 1746.917657]     pending: fb_flashcursor
[ 1746.920983] workqueue events_freezable_power_: flags=0x84
[ 1746.925304]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1746.930114]     in-flight: 3476:disk_events_workfn
[ 1746.934076] workqueue writeback: flags=0x4e
[ 1746.937546]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/256
[ 1746.942258]     in-flight: 70:wb_workfn
[ 1746.945978] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3451 3501
[ 1746.952268] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=44s workers=2 manager: 3490
[ 1746.958276] pool 128: cpus=0-63 flags=0x4 nice=0 hung=0s workers=3 manager: 3471 idle: 6
---------- console log ----------

This is an OOM-livelocked situation where kswapd got stuck and
allocating tasks are sleeping at

	/*
	 * If we didn't make any progress and have a lot of
	 * dirty + writeback pages then we should wait for
	 * an IO to complete to slow down the reclaim and
	 * prevent from pre mature OOM
	 */
	if (!did_some_progress && 2*(writeback + dirty) > reclaimable) {
		congestion_wait(BLK_RW_ASYNC, HZ/10);
		return true;
	}

in should_reclaim_retry(). Presumably out_of_memory() is called (I didn't
confirm it using kmallocwd), and this is a situation where "we need to select
next OOM-victim" or "fail !__GFP_FS && !__GFP_NOFAIL allocation requests".

But what I felt strange is what should_reclaim_retry() is doing.

Michal Hocko wrote:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f77e283fb8c6..b2de8c8761ad 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3044,8 +3045,37 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		 */
>  		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
>  				ac->high_zoneidx, alloc_flags, available)) {
> -			/* Wait for some write requests to complete then retry */
> -			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> +			unsigned long writeback;
> +			unsigned long dirty;
> +
> +			writeback = zone_page_state_snapshot(zone, NR_WRITEBACK);
> +			dirty = zone_page_state_snapshot(zone, NR_FILE_DIRTY);
> +
> +			/*
> +			 * If we didn't make any progress and have a lot of
> +			 * dirty + writeback pages then we should wait for
> +			 * an IO to complete to slow down the reclaim and
> +			 * prevent from pre mature OOM
> +			 */
> +			if (!did_some_progress && 2*(writeback + dirty) > reclaimable) {
> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> +				return true;
> +			}

writeback and dirty are used only when did_some_progress == 0. Thus, we don't
need to calculate writeback and dirty using zone_page_state_snapshot() unless
did_some_progress == 0.

But, does it make sense to take writeback and dirty into account when
disk_events_workfn (trace shown above) is doing GFP_NOIO allocation and
wb_workfn (trace shown above) is doing (presumably) GFP_NOFS allocation?
Shouldn't we use different threshold for GFP_NOIO / GFP_NOFS / GFP_KERNEL?

> +
> +			/*
> +			 * Memory allocation/reclaim might be called from a WQ
> +			 * context and the current implementation of the WQ
> +			 * concurrency control doesn't recognize that
> +			 * a particular WQ is congested if the worker thread is
> +			 * looping without ever sleeping. Therefore we have to
> +			 * do a short sleep here rather than calling
> +			 * cond_resched().
> +			 */
> +			if (current->flags & PF_WQ_WORKER)
> +				schedule_timeout(1);

This schedule_timeout(1) does not sleep. You lost the fix as of next-20160317.
Please update.

> +			else
> +				cond_resched();
> +
>  			return true;
>  		}
>  	}
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
