Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A91136B02A1
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:23:39 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a10-v6so5410279itc.9
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 05:23:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v66-v6si9996152ioe.171.2018.07.25.05.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 05:23:37 -0700 (PDT)
Subject: Re: cgroup-aware OOM killer, how to move forward
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <9ef76b45-d50f-7dc6-d224-683ab23efdb0@I-love.SAKURA.ne.jp>
 <20180725001001.GA30802@castle.DHCP.thefacebook.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <33510f1b-e038-8266-6482-f8f8891e5514@i-love.sakura.ne.jp>
Date: Wed, 25 Jul 2018 21:23:11 +0900
MIME-Version: 1.0
In-Reply-To: <20180725001001.GA30802@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

Michal, I think that I hit WQ OOM lockup caused by lack of guaranteed schedule_timeout_*() for WQ.
I think we should immediately send https://marc.info/?l=linux-mm&m=153062798103081
(or both http://lkml.kernel.org/r/20180709074706.30635-1-mhocko@kernel.org and
https://marc.info/?l=linux-mm&m=152723708623015 ) to linux.git so that we can send
to stable kernels without waiting for "mm, oom: cgroup-aware OOM killer" patchset.



Log file is at http://I-love.SAKURA.ne.jp/tmp/serial-20180725.txt.xz .
( Output up to last two OOM killer invocations are omitted from below excerpt. )

$ grep lockup serial-20180725.txt
[ 3512.401044] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 72s!
[ 3545.156052] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 105s!
[ 3575.364044] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 135s!
[ 3693.429456] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 253s!
[ 3785.795525] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 346s!
[ 3906.627292] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 467s!

$ grep out_of_memory serial-20180725.txt
[ 3439.486723]  out_of_memory+0x3fc/0x780
[ 3439.674515]  out_of_memory+0x3fc/0x780

$ grep sysrq: serial-20180725.txt
[ 3473.136366] sysrq: SysRq : Show State
[ 3575.779715] sysrq: SysRq : Show backtrace of all active CPUs
[ 3621.473841] sysrq: SysRq : Show Memory
[ 3654.129996] sysrq: SysRq : Show State
[ 3733.447398] sysrq: SysRq : Manual OOM execution
[ 3808.956565] sysrq: SysRq : Show backtrace of all active CPUs
[ 3857.741374] sysrq: SysRq : Manual OOM execution
[ 3871.848122] sysrq: SysRq : Show backtrace of all active CPUs
[ 3930.529273] sysrq: SysRq : Show backtrace of all active CPUs
[ 3946.694858] sysrq: SysRq : Terminate All Tasks

$ grep -A 100 -F 3575.779715 serial-20180725.txt
[ 3575.779715] sysrq: SysRq : Show backtrace of all active CPUs
[ 3575.782255] NMI backtrace for cpu 0
[ 3575.784104] CPU: 0 PID: 82423 Comm: kworker/0:3 Not tainted 4.18.0-rc6-next-20180724+ #246
[ 3575.787142] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[ 3575.790847] Workqueue: events_freezable_power_ disk_events_workfn
[ 3575.793317] Call Trace:
[ 3575.794818]  <IRQ>
[ 3575.796180]  dump_stack+0x85/0xcb
[ 3575.797858]  nmi_cpu_backtrace+0xa1/0xb0
[ 3575.799710]  ? lapic_can_unplug_cpu+0x90/0x90
[ 3575.801712]  nmi_trigger_cpumask_backtrace+0xf0/0x130
[ 3575.803894]  __handle_sysrq+0xbe/0x200
[ 3575.805733]  sysrq_filter+0x82/0x400
[ 3575.807513]  input_to_handler+0x43/0xe0
[ 3575.809339]  input_pass_values.part.9+0x1ab/0x260
[ 3575.811404]  input_handle_event+0xd6/0x570
[ 3575.813330]  input_event+0x45/0x70
[ 3575.815020]  atkbd_interrupt+0x4ff/0x780
[ 3575.816810]  serio_interrupt+0x3b/0x80
[ 3575.818517]  i8042_interrupt+0x25d/0x410
[ 3575.820305]  __handle_irq_event_percpu+0x2c/0xe0
[ 3575.822256]  handle_irq_event_percpu+0x2b/0x70
[ 3575.824148]  handle_irq_event+0x2f/0x50
[ 3575.825882]  handle_edge_irq+0x6c/0x180
[ 3575.827598]  handle_irq+0xa0/0x110
[ 3575.829158]  do_IRQ+0x4e/0x100
[ 3575.830611]  common_interrupt+0xf/0xf
[ 3575.832244]  </IRQ>
[ 3575.833439] RIP: 0010:lock_release+0x36/0x1d0
[ 3575.835346] Code: 25 c0 5d 01 00 48 83 ec 18 44 8b 8b d4 0b 00 00 65 48 8b 04 25 28 00 00 00 48 89 44 24 10 31 c0 45 85 c9 0f 85 e1 00 00 00 9c <58> 66 66 90 66 90 48 89 c5 fa 66 66 90 66 66 90 44 8b 05 43 54 0f
[ 3575.841978] RSP: 0000:ffffabfb43b3b898 EFLAGS: 00000246 ORIG_RAX: ffffffffffffffcc
[ 3575.844683] RAX: 0000000000000000 RBX: ffff8bfb94e8c240 RCX: 0000000000000000
[ 3575.847296] RDX: ffffffff8919647a RSI: 0000000000000001 RDI: ffffffff8a0597c0
[ 3575.849896] RBP: ffffabfb43b3b908 R08: ffffffff891963d0 R09: 0000000000000000
[ 3575.852506] R10: ffffabfb43b3b8a8 R11: 0000000000000001 R12: ffffffffffffffff
[ 3575.855104] R13: ffff8bfbb6373028 R14: 0000000000000000 R15: ffff8bfbb61a3b20
[ 3575.857713]  ? __list_lru_init+0x280/0x280
[ 3575.859567]  ? list_lru_count_one+0xaa/0x1e0
[ 3575.861453]  ? list_lru_count_one+0xc2/0x1e0
[ 3575.863290]  ? super_cache_count+0x74/0xf0
[ 3575.865135]  ? do_shrink_slab+0x35/0x190
[ 3575.866878]  ? shrink_slab+0x1d3/0x2c0
[ 3575.868565]  ? shrink_slab+0x240/0x2c0
[ 3575.870238]  ? shrink_node+0xe3/0x460
[ 3575.871863]  ? do_try_to_free_pages+0xcb/0x380
[ 3575.873700]  ? try_to_free_pages+0xbb/0xf0
[ 3575.875450]  ? __alloc_pages_slowpath+0x3c1/0xc50
[ 3575.877311]  ? __alloc_pages_nodemask+0x2a6/0x2c0
[ 3575.879187]  ? bio_copy_kern+0xcd/0x200
[ 3575.880976]  ? blk_rq_map_kern+0xb6/0x130
[ 3575.882760]  ? scsi_execute+0x64/0x250
[ 3575.884459]  ? sr_check_events+0x9a/0x2b0 [sr_mod]
[ 3575.886424]  ? __mutex_unlock_slowpath+0x46/0x2b0
[ 3575.888257]  ? cdrom_check_events+0xf/0x30 [cdrom]
[ 3575.890119]  ? sr_block_check_events+0x7c/0xb0 [sr_mod]
[ 3575.892152]  ? disk_check_events+0x5e/0x150
[ 3575.893890]  ? process_one_work+0x290/0x4a0
[ 3575.895660]  ? process_one_work+0x227/0x4a0
[ 3575.897411]  ? worker_thread+0x28/0x3d0
[ 3575.899006]  ? process_one_work+0x4a0/0x4a0
[ 3575.900727]  ? kthread+0x107/0x120
[ 3575.902191]  ? kthread_create_worker_on_cpu+0x70/0x70
[ 3575.904132]  ? ret_from_fork+0x24/0x30
[ 3621.473841] sysrq: SysRq : Show Memory
[ 3621.475640] Mem-Info:
[ 3621.476934] active_anon:831608 inactive_anon:5544 isolated_anon:0
[ 3621.476934]  active_file:0 inactive_file:0 isolated_file:0
[ 3621.476934]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 3621.476934]  slab_reclaimable:3620 slab_unreclaimable:31654
[ 3621.476934]  mapped:1463 shmem:10471 pagetables:8448 bounce:0
[ 3621.476934]  free:21327 free_pcp:66 free_cma:0
[ 3621.488816] Node 0 active_anon:3326432kB inactive_anon:22176kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:5852kB dirty:0kB writeback:0kB shmem:41884kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2816000kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 3621.497230] Node 0 DMA free:14712kB min:288kB low:360kB high:432kB active_anon:1128kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 3621.505476] lowmem_reserve[]: 0 2679 3607 3607
[ 3621.507341] Node 0 DMA32 free:53596kB min:49968kB low:62460kB high:74952kB active_anon:2686544kB inactive_anon:8kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2743316kB mlocked:0kB kernel_stack:48kB pagetables:120kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 3621.516007] lowmem_reserve[]: 0 0 928 928
[ 3621.517799] Node 0 Normal free:17000kB min:17320kB low:21648kB high:25976kB active_anon:638644kB inactive_anon:22168kB active_file:56kB inactive_file:200kB unevictable:0kB writepending:0kB present:1048576kB managed:951040kB mlocked:0kB kernel_stack:17888kB pagetables:33668kB bounce:0kB free_pcp:264kB local_pcp:264kB free_cma:0kB
[ 3621.527702] lowmem_reserve[]: 0 0 0 0
[ 3621.529458] Node 0 DMA: 0*4kB 1*8kB (M) 1*16kB (M) 1*32kB (U) 1*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14712kB
[ 3621.533965] Node 0 DMA32: 13*4kB (UM) 17*8kB (UM) 20*16kB (UM) 67*32kB (UM) 50*64kB (U) 27*128kB (UM) 27*256kB (UM) 7*512kB (U) 33*1024kB (UM) 0*2048kB 0*4096kB = 53596kB
[ 3621.539631] Node 0 Normal: 29*4kB (UME) 3*8kB (UE) 13*16kB (UME) 74*32kB (UME) 67*64kB (UME) 38*128kB (UE) 17*256kB (UE) 2*512kB (UM) 0*1024kB 0*2048kB 0*4096kB = 17244kB
[ 3621.545487] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 3621.548666] 10482 total pagecache pages
[ 3621.550795] 0 pages in swap cache
[ 3621.552891] Swap cache stats: add 0, delete 0, find 0/0
[ 3621.555539] Free swap  = 0kB
[ 3621.557299] Total swap = 0kB
[ 3621.559054] 1048422 pages RAM
[ 3621.560836] 0 pages HighMem/MovableOnly
[ 3621.562838] 120864 pages reserved
[ 3621.564724] 0 pages cma reserved
[ 3621.566586] 0 pages hwpoisoned
[ 3654.129996] sysrq: SysRq : Show State
[ 3654.132038]   task                        PC stack   pid father
[ 3654.134654] systemd         D12240     1      0 0x00000000
[ 3654.137087] Call Trace:
[ 3654.138710]  ? __schedule+0x245/0x7f0
[ 3654.140687]  ? xfs_reclaim_inodes_ag+0x3b8/0x470 [xfs]
[ 3654.143007]  schedule+0x23/0x80
[ 3654.144835]  schedule_preempt_disabled+0x5/0x10
[ 3654.146999]  __mutex_lock+0x3f5/0x9b0

$ grep -A 61 -F 3930.529273 serial-20180725.txt
[ 3930.529273] sysrq: SysRq : Show backtrace of all active CPUs
[ 3930.532004] NMI backtrace for cpu 0
[ 3930.533974] CPU: 0 PID: 82423 Comm: kworker/0:3 Not tainted 4.18.0-rc6-next-20180724+ #246
[ 3930.537201] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[ 3930.541173] Workqueue: events_freezable_power_ disk_events_workfn
[ 3930.543773] Call Trace:
[ 3930.545341]  <IRQ>
[ 3930.546766]  dump_stack+0x85/0xcb
[ 3930.548558]  nmi_cpu_backtrace+0xa1/0xb0
[ 3930.550566]  ? lapic_can_unplug_cpu+0x90/0x90
[ 3930.552640]  nmi_trigger_cpumask_backtrace+0xf0/0x130
[ 3930.554930]  __handle_sysrq+0xbe/0x200
[ 3930.556834]  sysrq_filter+0x82/0x400
[ 3930.558669]  input_to_handler+0x43/0xe0
[ 3930.560558]  input_pass_values.part.9+0x1ab/0x260
[ 3930.562688]  input_handle_event+0xd6/0x570
[ 3930.564602]  input_event+0x45/0x70
[ 3930.566309]  atkbd_interrupt+0x4ff/0x780
[ 3930.568187]  serio_interrupt+0x3b/0x80
[ 3930.569981]  i8042_interrupt+0x25d/0x410
[ 3930.571819]  __handle_irq_event_percpu+0x2c/0xe0
[ 3930.573860]  handle_irq_event_percpu+0x2b/0x70
[ 3930.575796]  handle_irq_event+0x2f/0x50
[ 3930.577561]  handle_edge_irq+0x6c/0x180
[ 3930.579313]  handle_irq+0xa0/0x110
[ 3930.580994]  do_IRQ+0x4e/0x100
[ 3930.582607]  common_interrupt+0xf/0xf
[ 3930.584360]  </IRQ>
[ 3930.585642] RIP: 0010:lock_acquire+0x1/0x70
[ 3930.587495] Code: c6 08 3c e0 89 48 c7 c7 c4 d6 df 89 e8 78 8e fa ff 0f 0b e9 3a ff ff ff e8 cc 90 fa ff 66 90 66 2e 0f 1f 84 00 00 00 00 00 55 <53> 65 48 8b 2c 25 c0 5d 01 00 8b 85 d4 0b 00 00 85 c0 75 54 4d 89
[ 3930.594222] RSP: 0000:ffffabfb43b3b8d0 EFLAGS: 00000246 ORIG_RAX: ffffffffffffffcc
[ 3930.597083] RAX: 0000000000000000 RBX: ffff8bfbb14b9ed8 RCX: 0000000000000002
[ 3930.599825] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff8a0597c0
[ 3930.602605] RBP: ffffabfb43b3b908 R08: 0000000000000000 R09: 0000000000000000
[ 3930.605348] R10: ffffabfb43b3b8a8 R11: 0000000000000001 R12: ffffabfb43b3b9b0
[ 3930.608076] R13: ffff8bfbb8b90008 R14: 0000000000000000 R15: ffff8bfbb17e1880
[ 3930.610804]  list_lru_count_one+0x3b/0x1e0
[ 3930.612662]  ? __list_lru_init+0x280/0x280
[ 3930.614559]  super_cache_count+0x74/0xf0
[ 3930.616362]  do_shrink_slab+0x35/0x190
[ 3930.618100]  ? shrink_slab+0x1d3/0x2c0
[ 3930.619844]  shrink_slab+0x240/0x2c0
[ 3930.621531]  shrink_node+0xe3/0x460
[ 3930.623184]  do_try_to_free_pages+0xcb/0x380
[ 3930.625049]  try_to_free_pages+0xbb/0xf0
[ 3930.626869]  __alloc_pages_slowpath+0x3c1/0xc50
[ 3930.628803]  __alloc_pages_nodemask+0x2a6/0x2c0
[ 3930.630904]  bio_copy_kern+0xcd/0x200
[ 3930.632639]  blk_rq_map_kern+0xb6/0x130
[ 3930.634408]  scsi_execute+0x64/0x250
[ 3930.636079]  sr_check_events+0x9a/0x2b0 [sr_mod]
[ 3930.637998]  ? __mutex_unlock_slowpath+0x46/0x2b0
[ 3930.639934]  cdrom_check_events+0xf/0x30 [cdrom]
[ 3930.641822]  sr_block_check_events+0x7c/0xb0 [sr_mod]
[ 3930.643889]  disk_check_events+0x5e/0x150
[ 3930.645611]  process_one_work+0x290/0x4a0
[ 3930.647628]  ? process_one_work+0x227/0x4a0
[ 3930.649590]  worker_thread+0x28/0x3d0
[ 3930.651394]  ? process_one_work+0x4a0/0x4a0
[ 3930.653216]  kthread+0x107/0x120
[ 3930.654709]  ? kthread_create_worker_on_cpu+0x70/0x70
[ 3930.656745]  ret_from_fork+0x24/0x30



Roman Gushchin wrote:
> On Tue, Jul 24, 2018 at 08:59:58PM +0900, Tetsuo Handa wrote:
> > Roman, will you check this cleanup patch? This patch applies on top of next-20180724.
> > I assumed that your series do not kill processes which current thread should not
> > wait for termination.
> 
> Hi Tetsuo!
> 
> > 
> > From 86ba99fbf73a9eda0df5ee4ae70c075781e83f81 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Tue, 24 Jul 2018 14:00:45 +0900
> > Subject: [PATCH] mm,oom: Check pending victims earlier in out_of_memory().
> > 
> > The "mm, oom: cgroup-aware OOM killer" patchset introduced INFLIGHT_VICTIM
> > in order to replace open-coded ((void *)-1UL). But (regarding CONFIG_MMU=y
> > case) we have a list of inflight OOM victim threads which are connected to
> > oom_reaper_list. Thus we can check whether there are inflight OOM victims
> > before starting process/memcg list traversal. Since it is likely that only
> > few threads are linked to oom_reaper_list, checking all victims' OOM domain
> > will not matter.
> 
> I have a couple of top-level concerns:
> 1) You're doubling the size of oom_reaper memory footprint in task_struct.
>    I doubt, that code cleanup really worth it. If it's absolutely necessary
>    to resolve the lockup, which you mentioned, it should be explained
>    explicitly.

Doubling the size of oom_reaper memory footprint in task_struct is irrelevant
with mitigating the lockup. The patch for mitigating the lockup is very simple
(like shown above). But since that patch conflicts with your series, we can't
apply that patch unless we make that patch on top of your series. I really
appreciate if you rebase your series after applying that patch.

Doubling the size is not unique to my changes. David is trying to avoid
unnecessary killing of additional processes using timeout
( http://lkml.kernel.org/r/alpine.DEB.2.21.1807241443390.206335@chino.kir.corp.google.com )
and I agree that using "struct list_head" can make the code easier to read,
especially when your series is about to generate many OOM victims.

> 
> 2) There are several cosmetic changes in this patch, which makes reviewing
>    harder. Can you, please, split it into several parts.

The patch is shorter ( https://marc.info/?l=linux-mm&m=153062797803080 )
if we could apply it before your series.

FYI, a splitted series is at https://marc.info/?l=linux-mm&m=153062796003073 .

> 
> 
> Thanks!
> 
