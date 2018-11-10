Return-Path: <linux-kernel-owner@vger.kernel.org>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.0 \(3445.100.39\))
Subject: Re: kmemleak: Early log buffer exceeded (525980) during boot
From: Qian Cai <cai@gmx.us>
In-Reply-To: <1541712198.12945.12.camel@gmx.us>
Date: Sat, 10 Nov 2018 10:08:10 -0500
Content-Transfer-Encoding: 8BIT
Message-Id: <D7C9EA14-C812-406F-9570-CFF36F4C3983@gmx.us>
References: <1541712198.12945.12.camel@gmx.us>
Sender: linux-kernel-owner@vger.kernel.org
To: open list <linux-kernel@vger.kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



> On Nov 8, 2018, at 4:23 PM, Qian Cai <cai@gmx.us> wrote:
> 
> The maximum value for DEBUG_KMEMLEAK_EARLY_LOG_SIZE is only 40000, so it
> disables kmemleak every time on this aarch64 server running the latest mainline
> (b00d209).
> 
> # echo scan > /sys/kernel/debug/kmemleak 
> -bash: echo: write error: Device or resource busy
> 
> Any idea on how to enable kmemleak there?

I have managed to hard-code DEBUG_KMEMLEAK_EARLY_LOG_SIZE to 600000,

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 877de4fa0720..c10119102c10 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -280,7 +280,7 @@ struct early_log {
 
 /* early logging buffer and current position */
 static struct early_log
-       early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE] __initdata;
+       early_log[600000] __initdata;
 static int crt_early_log __initdata;
 
 static void kmemleak_disable(void);

Even though kmemleak is enabled, there are continuous soft-lockups and eventually
a kernel panic. Is it normal that kmemleak not going to work with large systems (this
aarch64 server has 64-CPU and 100G memory)?

[39418.164687] watchdog: BUG: soft lockup - CPU#20 stuck for 23s! [kworker/20:1:361]
[39418.172172] Modules linked in: vfat fat ses enclosure ipmi_ssif ghash_ce sha2_ce sha256_arm64 sha1_ce sg ipmi_si ipmi_devintf ipmi_msghandler sbsa_gwdt sch_fq_codel xfs libcrc32c marvell mpt3sas raid_class mlx5_core hibmc_drm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ixgbe hisi_sas_v2_hw igb hisi_sas_main libsas hns_dsaf mlxfw hns_enet_drv devlink i2c_designware_platform mdio i2c_algo_bit scsi_transport_sas ehci_platform i2c_designware_core hns_mdio hnae dm_mirror dm_region_hash dm_log dm_mod
[39418.218197] irq event stamp: 56
[39418.221346] hardirqs last  enabled at (55): [<ffff200008fab57c>] _raw_spin_unlock_irq+0x3c/0x78
[39418.230040] hardirqs last disabled at (56): [<ffff200008f9ef64>] __schedule+0x1d4/0xda0
[39418.238040] softirqs last  enabled at (0): [<ffff20000811a668>] copy_process.isra.2+0xda0/0x2e20
[39418.246820] softirqs last disabled at (0): [<0000000000000000>]           (null)
[39418.254215] CPU: 20 PID: 361 Comm: kworker/20:1 Tainted: G    B   W    L    4.20.0-rc1+ #3
[39418.262472] Hardware name: Huawei TaiShan 2280 /BC11SPCD, BIOS 1.50 06/01/2018
[39418.269695] Workqueue: events free_obj_work
[39418.273875] pstate: 20000005 (nzCv daif -PAN -UAO)
[39418.278662] pc : _raw_spin_unlock_irqrestore+0x84/0x88
[39418.283795] lr : _raw_spin_unlock_irqrestore+0x80/0x88
[39418.288926] sp : ffff801ec3556a80
[39418.292234] x29: ffff801ec3556a80 x28: 1ffff003d86aad98 
[39418.297542] x27: ffff2000111a1000 x26: ffff2000111bcd80 
[39418.302850] x25: ffff801ebc5886c8 x24: ffff801ebc5886d0 
[39418.308158] x23: ffff8019ce23b280 x22: ffff2000111a1c40 
[39418.313465] x21: ffff2000087dc9fc x20: ffff2000111bcd88 
[39418.318773] x19: 0000000000000000 x18: 0000000000000000 
[39418.324080] x17: 0000000000000000 x16: 0000000000000000 
[39418.329387] x15: 0000000000001880 x14: ffffffffffff8650 
[39418.334694] x13: 0000000000000000 x12: 000000000000005c 
[39418.340001] x11: 00000000f2f2f2f2 x10: dfff200000000000 
[39418.345309] x9 : ffff20000f669848 x8 : 00000000f2f2f200 
[39418.350616] x7 : ffff2000087dc7ec x6 : 0000000041b58ab3 
[39418.355924] x5 : dfff200000000000 x4 : dfff200000000000 
[39418.361231] x3 : 1ffff003d86aace4 x2 : 0000000000000003 
[39418.366538] x1 : bdf5a6abd51de100 x0 : 0000000000000000 
[39418.371846] Call trace:
[39418.374292]  _raw_spin_unlock_irqrestore+0x84/0x88
[39418.379079]  __debug_object_init+0x39c/0x918
[39418.383342]  debug_object_activate+0x218/0x370
[39418.387782]  __call_rcu+0xdc/0xad0
[39418.391178]  call_rcu+0x30/0x40
[39418.394315]  put_object+0x50/0x68
[39418.397624]  __delete_object+0xfc/0x140
[39418.401455]  delete_object_full+0x2c/0x38
[39418.405459]  kmemleak_free+0xa4/0xb0
[39418.409030]  kmem_cache_free+0x2e4/0x3a8
[39418.412947]  free_obj_work+0x300/0x468
[39418.416692]  process_one_work+0x60c/0xd90
[39418.420695]  worker_thread+0x13c/0xa70
[39418.424440]  kthread+0x1c4/0x1d0
[39418.427663]  ret_from_fork+0x10/0x1c
[39423.435417] BUG: workqueue lockup - pool cpus=20 node=1 flags=0x0 nice=0 stuck for 3608s!
[39423.443658] Showing busy workqueues and worker pools:
[39423.449354] workqueue events: flags=0x0
[39423.453272]   pwq 64: cpus=32 node=2 flags=0x0 nice=0 active=1/256
[39423.459456]     in-flight: 917:key_garbage_collector
[39423.465289]   pwq 40: cpus=20 node=1 flags=0x0 nice=0 active=2/256
[39423.471476]     in-flight: 361:free_obj_work
[39423.475749]     pending: free_obj_work
[39423.480087]   pwq 26: cpus=13 node=0 flags=0x0 nice=0 active=1/256
[39423.486273]     in-flight: 377:hns_nic_service_task [hns_enet_drv]
[39423.493235] workqueue mm_percpu_wq: flags=0x8
[39423.498302]   pwq 40: cpus=20 node=1 flags=0x0 nice=0 active=1/256
[39423.504488]     pending: vmstat_update
[39423.509247] workqueue ixgbe: flags=0xe000a
[39423.513345]   pwq 128: cpus=0-63 flags=0x4 nice=0 active=1/1
[39423.519007]     in-flight: 16574:ixgbe_service_task [ixgbe]
[39423.526001] pool 26: cpus=13 node=0 flags=0x0 nice=0 hung=0s workers=2 idle: 78
[39423.533349] pool 40: cpus=20 node=1 flags=0x0 nice=0 hung=3608s workers=3 idle: 906 114
[39423.542008] pool 64: cpus=32 node=2 flags=0x0 nice=0 hung=71s workers=3 idle: 9912 1737
[39454.155305] BUG: workqueue lockup - pool cpus=20 node=1 flags=0x0 nice=0 stuck for 3638s!
[39454.163547] Showing busy workqueues and worker pools:
[39454.169248] workqueue events: flags=0x0
[39454.173164]   pwq 64: cpus=32 node=2 flags=0x0 nice=0 active=1/256
[39454.179349]     in-flight: 917:key_garbage_collector
[39454.185164]   pwq 40: cpus=20 node=1 flags=0x0 nice=0 active=2/256
[39454.191351]     in-flight: 361:free_obj_work
[39454.195624]     pending: free_obj_work
[39454.199973]   pwq 26: cpus=13 node=0 flags=0x0 nice=0 active=1/256
[39454.206159]     in-flight: 377:hns_nic_service_task [hns_enet_drv]
[39454.213117] workqueue mm_percpu_wq: flags=0x8
[39454.218185]   pwq 40: cpus=20 node=1 flags=0x0 nice=0 active=1/256
[39454.224371]     pending: vmstat_update
[39454.229707] pool 26: cpus=13 node=0 flags=0x0 nice=0 hung=0s workers=2 idle: 78
[39454.237672] pool 40: cpus=20 node=1 flags=0x0 nice=0 hung=3638s workers=3 idle: 906 114
[39454.246320] pool 64: cpus=32 node=2 flags=0x0 nice=0 hung=26s workers=3 idle: 9912 1737
[39480.842570] WARNING: CPU: 8 PID: 2290 at mm/page_alloc.c:4270 __alloc_pages_nodemask+0x1f9c/0x2028
[39480.845824] kmemleak: Cannot allocate a kmemleak_object structure
[39482.325003] Kernel panic - not syncing: corrupted stack end detected inside scheduler
[39482.332839] CPU: 1 PID: 1319 Comm: systemd-journal Tainted: G    B   W    L    4.20.0-rc1+ #3
[39482.341358] Hardware name: Huawei TaiShan 2280 /BC11SPCD, BIOS 1.50 06/01/2018
[39482.348577] Call trace:
[39482.351029]  dump_backtrace+0x0/0x2c8
[39482.354688]  show_stack+0x24/0x30
[39482.358001]  dump_stack+0x118/0x19c
[39482.361484]  panic+0x1b8/0x31c
[39482.364536]  schedule+0x0/0x240
[39482.367673]  preempt_schedule_common+0x3c/0x78
[39482.372110]  _cond_resched+0xfc/0x108
[39482.375769]  shrink_node_memcg+0x368/0x9c0
[39482.379861]  shrink_node+0x200/0x940
[39482.383431]  do_try_to_free_pages+0x234/0x7d0
[39482.387784]  try_to_free_pages+0x228/0x6b0
[39482.391877]  __alloc_pages_nodemask+0xcbc/0x2028
[39482.396492]  alloc_pages_vma+0x1a4/0x208
[39482.400412]  __read_swap_cache_async+0x4fc/0x858
[39482.405025]  read_swap_cache_async+0xa4/0x100
[39482.409378]  swap_cluster_readahead+0x598/0x650
[39482.413904]  shmem_swapin+0xd4/0x150
[39482.417477]  shmem_getpage_gfp+0xf50/0x1c48
[39482.421657]  shmem_fault+0x140/0x340
[39482.425229]  __do_fault+0xd0/0x440
[39482.428625]  do_fault+0x54c/0xf48
[39482.431935]  __handle_mm_fault+0x4c0/0x928
[39482.436028]  handle_mm_fault+0x30c/0x4b8
[39482.439947]  do_page_fault+0x294/0x658
[39482.443690]  do_translation_fault+0x98/0xa8
[39482.447871]  do_mem_abort+0x64/0xf0
[39482.451354]  el0_da+0x24/0x28
[39482.454476] SMP: stopping secondary CPUs
[39482.459038] Kernel Offset: disabled
[39482.462522] CPU features: 0x2,21806008
[39482.466264] Memory Limit: none
[39482.469435] ---[ end Kernel panic - not syncing: corrupted stack end detected inside scheduler ]---
[39483.029013] WARNING: CPU: 1 PID: 1319 at kernel/sched/core.c:1168 set_task_cpu+0x5ac/0x5f8
[39483.037272] Modules linked in: vfat fat ses enclosure ipmi_ssif ghash_ce sha2_ce sha256_arm64 sha1_ce sg ipmi_si ipmi_devintf ipmi_msghandler sbsa_gwdt sch_fq_codel xfs libcrc32c marvell mpt3sas raid_class mlx5_core hibmc_drm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ixgbe hisi_sas_v2_hw igb hisi_sas_main libsas hns_dsaf mlxfw hns_enet_drv devlink i2c_designware_platform mdio i2c_algo_bit scsi_transport_sas ehci_platform i2c_designware_core hns_mdio hnae dm_mirror dm_region_hash dm_log dm_mod
[39483.083295] CPU: 1 PID: 1319 Comm: systemd-journal Tainted: G    B   W    L    4.20.0-rc1+ #3
[39483.091812] Hardware name: Huawei TaiShan 2280 /BC11SPCD, BIOS 1.50 06/01/2018
[39483.099027] pstate: 60000085 (nZCv daIf -PAN -UAO)
[39483.103812] pc : set_task_cpu+0x5ac/0x5f8
[39483.107815] lr : set_task_cpu+0x124/0x5f8
[39483.111817] sp : ffff8016fb0440c0
[39483.115125] x29: ffff8016fb0440c0 x28: 0000000000000000 
[39483.120433] x27: 0000000000000002 x26: 0000000000000004 
[39483.125740] x25: ffff20000f6718b8 x24: ffff80161ac85244 
[39483.131047] x23: ffff20000f669848 x22: 1ffff002df608826 
[39483.136354] x21: 0000000000000002 x20: 0000000000000000 
[39483.141661] x19: ffff80161ac85200 x18: ffff1011daf8d930 
[39483.146968] x17: 0000000000000000 x16: 0000000000000000 
[39483.152274] x15: ffff1011daf8d930 x14: 6863732065646973 
[39483.157581] x13: 6e69206465746365 x12: 74656420646e6520 
[39483.162887] x11: 00000000f2f2f2f2 x10: dfff200000000000 
[39483.168194] x9 : ffff20000f669848 x8 : 00000000f2f2f200 
[39483.173501] x7 : 0000000041b58ab3 x6 : 0000000041b58ab3 
[39483.178808] x5 : dfff200000000000 x4 : dfff200000000000 
[39483.184114] x3 : 00000000f2f2f2f2 x2 : 0000000000000007 
[39483.189421] x1 : ffff20000f6718b8 x0 : 0000000000000000 
[39483.194728] Call trace:
[39483.197170]  set_task_cpu+0x5ac/0x5f8
[39483.200826]  try_to_wake_up+0x380/0xa48
[39483.204656]  wake_up_process+0x28/0x38
[39483.208400]  hrtimer_wakeup+0x30/0x40
[39483.212056]  __run_hrtimer+0x20c/0x988
[39483.215800]  __hrtimer_run_queues+0x16c/0x1f8
[39483.220151]  hrtimer_interrupt+0x18c/0x370
[39483.224243]  arch_timer_handler_phys+0x44/0x58
[39483.228682]  handle_percpu_devid_irq+0x1a0/0x720
[39483.233293]  generic_handle_irq+0x44/0x60
[39483.237296]  __handle_domain_irq+0x88/0xf0
[39483.241386]  gic_handle_irq+0xc0/0x168
[39483.245128]  el1_irq+0xb4/0x140
[39483.248265]  __delay+0x70/0xd8
[39483.251313]  __const_udelay+0x34/0x40
[39483.254969]  panic+0x30c/0x31c
[39483.258018]  schedule+0x0/0x240
[39483.261154]  preempt_schedule_common+0x3c/0x78
[39483.265591]  _cond_resched+0xfc/0x108
[39483.269249]  shrink_node_memcg+0x368/0x9c0
[39483.273339]  shrink_node+0x200/0x940
[39483.276909]  do_try_to_free_pages+0x234/0x7d0
[39483.281260]  try_to_free_pages+0x228/0x6b0
[39483.285351]  __alloc_pages_nodemask+0xcbc/0x2028
[39483.289963]  alloc_pages_vma+0x1a4/0x208
[39483.293880]  __read_swap_cache_async+0x4fc/0x858
[39483.298492]  read_swap_cache_async+0xa4/0x100
[39483.302844]  swap_cluster_readahead+0x598/0x650
[39483.307368]  shmem_swapin+0xd4/0x150
[39483.310938]  shmem_getpage_gfp+0xf50/0x1c48
[39483.315115]  shmem_fault+0x140/0x340
[39483.318684]  __do_fault+0xd0/0x440
[39483.322080]  do_fault+0x54c/0xf48
[39483.325390]  __handle_mm_fault+0x4c0/0x928
[39483.329480]  handle_mm_fault+0x30c/0x4b8
[39483.333397]  do_page_fault+0x294/0x658
[39483.337141]  do_translation_fault+0x98/0xa8
[39483.341318]  do_mem_abort+0x64/0xf0
[39483.344800]  el0_da+0x24/0x28
[39483.347761] irq event stamp: 0
[39483.350810] hardirqs last  enabled at (0): [<0000000000000000>]           (null)
[39483.358200] hardirqs last disabled at (0): [<ffff20000811a668>] copy_process.isra.2+0xda0/0x2e20
[39483.366979] softirqs last  enabled at (0): [<ffff20000811a668>] copy_process.isra.2+0xda0/0x2e20
[39483.375756] softirqs last disabled at (0): [<0000000000000000>]           (null)
[39483.383144] ---[ end trace 0d8bbddd3044cabe ]---
