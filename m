Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAEB36B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 07:06:51 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id z9-v6so960912iom.14
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:06:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o81-v6si495909itb.99.2018.07.26.04.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 04:06:49 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
Date: Thu, 26 Jul 2018 20:06:24 +0900
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Before applying "an OOM lockup mitigation patch", I want to apply this
"another OOM lockup avoidance" patch.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20180726.txt.xz
(which was captured with

  --- a/mm/oom_kill.c
  +++ b/mm/oom_kill.c
  @@ -1071,6 +1071,12 @@ bool out_of_memory(struct oom_control *oc)
   {
   	unsigned long freed = 0;
   	bool delay = false; /* if set, delay next allocation attempt */
  +	static unsigned long last_warned;
  +	if (!last_warned || time_after(jiffies, last_warned + 10 * HZ)) {
  +		pr_warn("%s(%d) gfp_mask=%#x(%pGg), order=%d\n", current->comm,
  +			current->pid, oc->gfp_mask, &oc->gfp_mask, oc->order);
  +		last_warned = jiffies;
  +	}
   
   	oc->constraint = CONSTRAINT_NONE;
   	if (oom_killer_disabled)

in order to demonstrate that the GFP_NOIO allocation from disk_events_workfn() is
calling out_of_memory() rather than by error failing to give up direct reclaim).

[  258.619119] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
[  268.622732] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
[  278.635344] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
[  288.639360] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
[  298.642715] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
[  308.527975] sysrq: SysRq : Show Memory
[  308.529713] Mem-Info:
[  308.530930] active_anon:855844 inactive_anon:2123 isolated_anon:0
[  308.530930]  active_file:7 inactive_file:12 isolated_file:0
[  308.530930]  unevictable:0 dirty:0 writeback:0 unstable:0
[  308.530930]  slab_reclaimable:3444 slab_unreclaimable:23008
[  308.530930]  mapped:1743 shmem:2272 pagetables:3991 bounce:0
[  308.530930]  free:21206 free_pcp:165 free_cma:0
[  308.542309] Node 0 active_anon:3423376kB inactive_anon:8492kB active_file:28kB inactive_file:48kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:6972kB dirty:0kB writeback:0kB shmem:9088kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 3227648kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  308.550495] Node 0 DMA free:14712kB min:288kB low:360kB high:432kB active_anon:1128kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  308.558420] lowmem_reserve[]: 0 2717 3607 3607
[  308.560197] Node 0 DMA32 free:53860kB min:50684kB low:63352kB high:76020kB active_anon:2727108kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2782536kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  308.568640] lowmem_reserve[]: 0 0 890 890
[  308.570396] Node 0 Normal free:16252kB min:16608kB low:20760kB high:24912kB active_anon:694864kB inactive_anon:8492kB active_file:44kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:911820kB mlocked:0kB kernel_stack:8080kB pagetables:15956kB bounce:0kB free_pcp:660kB local_pcp:660kB free_cma:0kB
[  308.580075] lowmem_reserve[]: 0 0 0 0
[  308.581827] Node 0 DMA: 0*4kB 1*8kB (M) 1*16kB (M) 1*32kB (U) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14712kB
[  308.586271] Node 0 DMA32: 5*4kB (UM) 3*8kB (U) 5*16kB (U) 5*32kB (U) 5*64kB (U) 2*128kB (UM) 2*256kB (UM) 7*512kB (M) 4*1024kB (M) 2*2048kB (UM) 10*4096kB (UM) = 54108kB
[  308.591900] Node 0 Normal: 13*4kB (UM) 5*8kB (UM) 2*16kB (U) 74*32kB (UME) 23*64kB (UME) 6*128kB (UME) 5*256kB (U) 2*512kB (UM) 9*1024kB (M) 0*2048kB 0*4096kB = 16252kB
[  308.597637] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  308.600764] 2273 total pagecache pages
[  308.602712] 0 pages in swap cache
[  308.604532] Swap cache stats: add 0, delete 0, find 0/0
[  308.606843] Free swap  = 0kB
[  308.608632] Total swap = 0kB
[  308.610357] 1048422 pages RAM
[  308.612153] 0 pages HighMem/MovableOnly
[  308.614173] 120864 pages reserved
[  308.615994] 0 pages cma reserved
[  308.617811] 0 pages hwpoisoned
[  308.527975] sysrq: SysRq : Show Memory
[  308.529713] Mem-Info:
[  308.530930] active_anon:855844 inactive_anon:2123 isolated_anon:0
[  308.530930]  active_file:7 inactive_file:12 isolated_file:0
[  308.530930]  unevictable:0 dirty:0 writeback:0 unstable:0
[  308.530930]  slab_reclaimable:3444 slab_unreclaimable:23008
[  308.530930]  mapped:1743 shmem:2272 pagetables:3991 bounce:0
[  308.530930]  free:21206 free_pcp:165 free_cma:0
[  308.542309] Node 0 active_anon:3423376kB inactive_anon:8492kB active_file:28kB inactive_file:48kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:6972kB dirty:0kB writeback:0kB shmem:9088kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 3227648kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  308.550495] Node 0 DMA free:14712kB min:288kB low:360kB high:432kB active_anon:1128kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  308.558420] lowmem_reserve[]: 0 2717 3607 3607
[  308.560197] Node 0 DMA32 free:53860kB min:50684kB low:63352kB high:76020kB active_anon:2727108kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2782536kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  308.568640] lowmem_reserve[]: 0 0 890 890
[  308.570396] Node 0 Normal free:16252kB min:16608kB low:20760kB high:24912kB active_anon:694864kB inactive_anon:8492kB active_file:44kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:911820kB mlocked:0kB kernel_stack:8080kB pagetables:15956kB bounce:0kB free_pcp:660kB local_pcp:660kB free_cma:0kB
[  308.580075] lowmem_reserve[]: 0 0 0 0
[  308.581827] Node 0 DMA: 0*4kB 1*8kB (M) 1*16kB (M) 1*32kB (U) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14712kB
[  308.586271] Node 0 DMA32: 5*4kB (UM) 3*8kB (U) 5*16kB (U) 5*32kB (U) 5*64kB (U) 2*128kB (UM) 2*256kB (UM) 7*512kB (M) 4*1024kB (M) 2*2048kB (UM) 10*4096kB (UM) = 54108kB
[  308.591900] Node 0 Normal: 13*4kB (UM) 5*8kB (UM) 2*16kB (U) 74*32kB (UME) 23*64kB (UME) 6*128kB (UME) 5*256kB (U) 2*512kB (UM) 9*1024kB (M) 0*2048kB 0*4096kB = 16252kB
[  308.597637] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  308.600764] 2273 total pagecache pages
[  308.602712] 0 pages in swap cache
[  308.604532] Swap cache stats: add 0, delete 0, find 0/0
[  308.606843] Free swap  = 0kB
[  308.608632] Total swap = 0kB
[  308.610357] 1048422 pages RAM
[  308.612153] 0 pages HighMem/MovableOnly
[  308.614173] 120864 pages reserved
[  308.615994] 0 pages cma reserved
[  308.617811] 0 pages hwpoisoned

[  310.383005] kworker/0:0     R  running task    13504     5      2 0x80000000
[  310.385328] Workqueue: events_freezable_power_ disk_events_workfn
[  310.387578] Call Trace:
[  310.475050]  ? shrink_node+0xca/0x460
[  310.476614]  shrink_node+0xca/0x460
[  310.478129]  do_try_to_free_pages+0xcb/0x380
[  310.479848]  try_to_free_pages+0xbb/0xf0
[  310.481481]  __alloc_pages_slowpath+0x3c1/0xc50
[  310.483332]  __alloc_pages_nodemask+0x2a6/0x2c0
[  310.485130]  bio_copy_kern+0xcd/0x200
[  310.486710]  blk_rq_map_kern+0xb6/0x130
[  310.488317]  scsi_execute+0x64/0x250
[  310.489859]  sr_check_events+0x9a/0x2b0 [sr_mod]
[  310.491669]  ? __mutex_unlock_slowpath+0x46/0x2b0
[  310.493581]  cdrom_check_events+0xf/0x30 [cdrom]
[  310.495435]  sr_block_check_events+0x7c/0xb0 [sr_mod]
[  310.497434]  disk_check_events+0x5e/0x150
[  310.499172]  process_one_work+0x290/0x4a0
[  310.500878]  ? process_one_work+0x227/0x4a0
[  310.502591]  worker_thread+0x28/0x3d0
[  310.504184]  ? process_one_work+0x4a0/0x4a0
[  310.505916]  kthread+0x107/0x120
[  310.507384]  ? kthread_create_worker_on_cpu+0x70/0x70
[  310.509333]  ret_from_fork+0x24/0x30

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

[  427.593034] sysrq: SysRq : Show Memory
[  427.594680] Mem-Info:
[  427.595882] active_anon:855844 inactive_anon:2123 isolated_anon:0
[  427.595882]  active_file:7 inactive_file:12 isolated_file:0
[  427.595882]  unevictable:0 dirty:0 writeback:0 unstable:0
[  427.595882]  slab_reclaimable:3444 slab_unreclaimable:22960
[  427.595882]  mapped:1743 shmem:2272 pagetables:3991 bounce:0
[  427.595882]  free:21254 free_pcp:165 free_cma:0
[  427.607487] Node 0 active_anon:3423376kB inactive_anon:8492kB active_file:28kB inactive_file:48kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:6972kB dirty:0kB writeback:0kB shmem:9088kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 3227648kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  427.615694] Node 0 DMA free:14712kB min:288kB low:360kB high:432kB active_anon:1128kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  427.623632] lowmem_reserve[]: 0 2717 3607 3607
[  427.625423] Node 0 DMA32 free:53860kB min:50684kB low:63352kB high:76020kB active_anon:2727108kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2782536kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  427.634066] lowmem_reserve[]: 0 0 890 890
[  427.635829] Node 0 Normal free:16444kB min:16608kB low:20760kB high:24912kB active_anon:694864kB inactive_anon:8492kB active_file:44kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:911820kB mlocked:0kB kernel_stack:7444kB pagetables:15956kB bounce:0kB free_pcp:660kB local_pcp:660kB free_cma:0kB
[  427.645560] lowmem_reserve[]: 0 0 0 0
[  427.647320] Node 0 DMA: 0*4kB 1*8kB (M) 1*16kB (M) 1*32kB (U) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14712kB
[  427.651757] Node 0 DMA32: 5*4kB (UM) 3*8kB (U) 5*16kB (U) 5*32kB (U) 5*64kB (U) 2*128kB (UM) 2*256kB (UM) 7*512kB (M) 4*1024kB (M) 2*2048kB (UM) 10*4096kB (UM) = 54108kB
[  427.657428] Node 0 Normal: 13*4kB (UM) 5*8kB (UM) 2*16kB (U) 81*32kB (UME) 23*64kB (UME) 6*128kB (UME) 5*256kB (U) 2*512kB (UM) 9*1024kB (M) 0*2048kB 0*4096kB = 16476kB
[  427.663144] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  427.666283] 2273 total pagecache pages
[  427.668249] 0 pages in swap cache
[  427.670085] Swap cache stats: add 0, delete 0, find 0/0
[  427.672416] Free swap  = 0kB
[  427.674256] Total swap = 0kB
[  427.676011] 1048422 pages RAM
[  427.677746] 0 pages HighMem/MovableOnly
[  427.679704] 120864 pages reserved
[  427.681526] 0 pages cma reserved
[  427.683371] 0 pages hwpoisoned

[  430.083584] kworker/0:0     R  running task    13504     5      2 0x80000000
[  430.085990] Workqueue: events_freezable_power_ disk_events_workfn
[  430.088175] Call Trace:
[  430.175214]  ? shrink_slab+0x240/0x2c0
[  430.176861]  shrink_node+0xe3/0x460
[  430.178402]  do_try_to_free_pages+0xcb/0x380
[  430.180110]  try_to_free_pages+0xbb/0xf0
[  430.181733]  __alloc_pages_slowpath+0x3c1/0xc50
[  430.183516]  __alloc_pages_nodemask+0x2a6/0x2c0
[  430.185292]  bio_copy_kern+0xcd/0x200
[  430.186847]  blk_rq_map_kern+0xb6/0x130
[  430.188475]  scsi_execute+0x64/0x250
[  430.190027]  sr_check_events+0x9a/0x2b0 [sr_mod]
[  430.191844]  ? __mutex_unlock_slowpath+0x46/0x2b0
[  430.193668]  cdrom_check_events+0xf/0x30 [cdrom]
[  430.195466]  sr_block_check_events+0x7c/0xb0 [sr_mod]
[  430.197383]  disk_check_events+0x5e/0x150
[  430.199038]  process_one_work+0x290/0x4a0
[  430.200712]  ? process_one_work+0x227/0x4a0
[  430.202413]  worker_thread+0x28/0x3d0
[  430.204003]  ? process_one_work+0x4a0/0x4a0
[  430.205757]  kthread+0x107/0x120
[  430.207282]  ? kthread_create_worker_on_cpu+0x70/0x70
[  430.209345]  ret_from_fork+0x24/0x30

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

Since the patch shown below was suggested by Michal Hocko at
https://marc.info/?l=linux-mm&m=152723708623015 , it is from Michal Hocko.
