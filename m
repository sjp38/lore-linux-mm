Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 30E4C6B004D
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 03:05:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9E750a0031991
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Oct 2009 16:05:01 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A4D845DE55
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:05:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A9EA45DE64
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:05:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9716C1DB803C
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:04:59 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4238F1DB8041
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:04:59 +0900 (JST)
Date: Wed, 14 Oct 2009 16:02:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: coalescing charge by percpu (Oct/9)
Message-Id: <20091014160237.1ac8d1b8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091014154211.08f33001.nishimura@mxp.nes.nec.co.jp>
References: <20091009165826.59c6f6e3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091009170105.170e025f.kamezawa.hiroyu@jp.fujitsu.com>
	<20091009165002.629a91d2.akpm@linux-foundation.org>
	<72e9a96ea399491948f396dab01b4c77.squirrel@webmail-b.css.fujitsu.com>
	<20091013165719.c5781bfa.nishimura@mxp.nes.nec.co.jp>
	<20091013170545.3af1cf7b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091014154211.08f33001.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, h-shimamoto@ct.jp.nec.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Oct 2009 15:42:11 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> It clears WORK_STRUCT_PENDING bit and initializes the list_head of the work_struct.
> So I think a following race can happen.
> 
>     work_pending() ->false
>     INIT_WORK()
>     schedule_work_on()    
>       queue_work_on()        
>                                   work_pending() -> false
>         test_and_seet_bit()
>           -> sets WORK_STRUCT_PENDING
>                                   INIT_WORK() -> clears WORK_STRUCT_PENDING
>                              
> 
> And actually, I've seen BUG several times in testing mmotm-2009-10-09-01-07 + these 2 patches.
> This seems not to happen on plain mmotm-2009-10-09-01-07.
> 
> 
> [ 2264.213803] ------------[ cut here ]------------
> [ 2264.214058] WARNING: at lib/list_debug.c:30 __list_add+0x6e/0x87()
> [ 2264.214058] Hardware name: Express5800/140Rd-4 [N8100-1065]
> [ 2264.214058] list_add corruption. prev->next should be next (ffff880029fd8e80), but was
> ffff880029fd36b8. (prev=ffff880029fd36b8).
> [ 2264.214058] Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables b
> ridge stp autofs4 hidp rfcomm l2cap crc16 bluetooth lockd sunrpc ib_iser rdma_cm ib_cm iw_
> cm ib_sa ib_mad ib_core ib_addr iscsi_tcp bnx2i cnic uio ipv6 cxgb3i cxgb3 mdio libiscsi_t
> cp libiscsi scsi_transport_iscsi dm_mirror dm_multipath scsi_dh video output sbs sbshc bat
> tery ac lp sg ide_cd_mod cdrom serio_raw acpi_memhotplug button parport_pc parport rtc_cmo
> s rtc_core rtc_lib e1000 i2c_i801 i2c_core pata_acpi ata_generic pcspkr dm_region_hash dm_
> log dm_mod ata_piix libata shpchp megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd uhci_
> hcd ohci_hcd ehci_hcd [last unloaded: freq_table]
> [ 2264.214058] Pid: 14398, comm: shmem_test_02 Tainted: G      D W  2.6.32-rc3-mmotm-2009-
> 10-09-01-07-00249-g1112566 #2
> [ 2264.214058] Call Trace:
> [ 2264.214058]  [<ffffffff811e0f43>] ? __list_add+0x6e/0x87
> [ 2264.214058]  [<ffffffff8104af21>] warn_slowpath_common+0x7c/0x94
> [ 2264.214058]  [<ffffffff8104afb8>] warn_slowpath_fmt+0x69/0x6b
> [ 2264.214058]  [<ffffffff81077354>] ? print_lock_contention_bug+0x1b/0xe0
> [ 2264.214058]  [<ffffffff810b819d>] ? probe_workqueue_insertion+0x40/0x9f
> [ 2264.214058]  [<ffffffff81076720>] ? trace_hardirqs_off+0xd/0xf
> [ 2264.214058]  [<ffffffff81386bef>] ? _spin_unlock_irqrestore+0x3d/0x4c
> [ 2264.214058]  [<ffffffff811e0f43>] __list_add+0x6e/0x87
> [ 2264.214058]  [<ffffffff81065230>] insert_work+0x78/0x9a
> [ 2264.214058]  [<ffffffff81065c47>] __queue_work+0x2f/0x43
> [ 2264.214058]  [<ffffffff81065cdb>] queue_work_on+0x44/0x50
> [ 2264.214058]  [<ffffffff81065d02>] schedule_work_on+0x1b/0x1d
> [ 2264.214058]  [<ffffffff81104623>] mem_cgroup_hierarchical_reclaim+0x232/0x40e
> [ 2264.214058]  [<ffffffff81077eeb>] ? trace_hardirqs_on+0xd/0xf
> [ 2264.214058]  [<ffffffff81104ec9>] __mem_cgroup_try_charge+0x14c/0x25b
> [ 2264.214058]  [<ffffffff811058df>] mem_cgroup_charge_common+0x55/0x82
> [ 2264.214058]  [<ffffffff810d5f9d>] ? shmem_swp_entry+0x134/0x140
> [ 2264.214058]  [<ffffffff81106a44>] mem_cgroup_cache_charge+0xef/0x118
> [ 2264.214058]  [<ffffffff810f766e>] ? alloc_page_vma+0xe0/0xef
> [ 2264.214058]  [<ffffffff810d689a>] shmem_getpage+0x6a7/0x86b
> [ 2264.214058]  [<ffffffff81077eeb>] ? trace_hardirqs_on+0xd/0xf
> [ 2264.214058]  [<ffffffff810ce1d4>] ? get_page_from_freelist+0x4fc/0x6ce
> [ 2264.214058]  [<ffffffff81386794>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [ 2264.214058]  [<ffffffff8100e385>] ? do_softirq+0x77/0x86
> [ 2264.214058]  [<ffffffff8100c5bc>] ? restore_args+0x0/0x30
> [ 2264.214058]  [<ffffffff810502bf>] ? current_fs_time+0x27/0x2e
> [ 2264.214058]  [<ffffffff81077354>] ? print_lock_contention_bug+0x1b/0xe0
> [ 2264.214058]  [<ffffffff811236c2>] ? file_update_time+0x44/0x144
> [ 2264.214058]  [<ffffffff810d6b11>] shmem_fault+0x42/0x63
> [ 2264.214058]  [<ffffffff810e07db>] __do_fault+0x55/0x484
> [ 2264.214058]  [<ffffffff81077354>] ? print_lock_contention_bug+0x1b/0xe0
> [ 2264.214058]  [<ffffffff810e28e1>] handle_mm_fault+0x1ea/0x813
> [ 2264.214058]  [<ffffffff81389770>] do_page_fault+0x25a/0x2ea
> [ 2264.214058]  [<ffffffff8138757f>] page_fault+0x1f/0x30
> [ 2264.214058] ---[ end trace d435092dd749cff5 ]---
> [ 2264.538186] ------------[ cut here ]------------
> [ 2264.538219] ------------[ cut here ]------------
> [ 2264.538231] kernel BUG at kernel/workqueue.c:287!
> [ 2264.538240] invalid opcode: 0000 [#2] SMP
> [ 2264.538251] last sysfs file: /sys/devices/system/cpu/cpu15/cache/index1/shared_cpu_map
> [ 2264.538259] CPU 0
> [ 2264.538270] Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables b
> ridge stp autofs4 hidp rfcomm l2cap crc16 bluetooth lockd sunrpc ib_iser rdma_cm ib_cm iw_
> cm ib_sa ib_mad ib_core ib_addr iscsi_tcp bnx2i cnic uio ipv6 cxgb3i cxgb3 mdio libiscsi_t
> cp libiscsi scsi_transport_iscsi dm_mirror dm_multipath scsi_dh video output sbs sbshc bat
> tery ac lp sg ide_cd_mod cdrom serio_raw acpi_memhotplug button parport_pc parport rtc_cmo
> s rtc_core rtc_lib e1000 i2c_i801 i2c_core pata_acpi ata_generic pcspkr dm_region_hash dm_
> log dm_mod ata_piix libata shpchp megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd uhci_
> hcd ohci_hcd ehci_hcd [last unloaded: freq_table]
> [ 2264.538627] Pid: 51, comm: events/0 Tainted: G      D W  2.6.32-rc3-mmotm-2009-10-09-01
> -07-00249-g1112566 #2 Express5800/140Rd-4 [N8100-1065]
> [ 2264.538638] RIP: 0010:[<ffffffff81065f56>]  [<ffffffff81065f56>] worker_thread+0x157/0x
> 2b3
> [ 2264.538663] RSP: 0000:ffff8803a068fe10  EFLAGS: 00010207
> [ 2264.538670] RAX: 0000000000000000 RBX: ffff8803a045a478 RCX: ffff880029fd36b8
> [ 2264.538679] RDX: 0000000000001918 RSI: 00000001a068fdd0 RDI: ffffffff81386bad
> [ 2264.538684] RBP: ffff8803a068feb0 R08: 0000000000000002 R09: 0000000000000001
> [ 2264.538694] R10: ffffffff81389860 R11: ffff880029fd6518 R12: ffff880029fd36b0
> [ 2264.538701] R13: ffff880029fd8e40 R14: ffff8803a067e590 R15: ffffffff811049f3
> [ 2264.538719] FS:  0000000000000000(0000) GS:ffff880029e00000(0000) knlGS:000000000000000
> 0
> [ 2264.538734] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> [ 2264.538742] CR2: 00007ffcc30a0001 CR3: 0000000001001000 CR4: 00000000000006f0
> [ 2264.538755] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 2264.538766] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 2264.538773] Process events/0 (pid: 51, threadinfo ffff8803a068e000, task ffff8803a067e5
> 90)
> [ 2264.538783] Stack:
> [ 2264.538788]  ffffffff81065f5a ffffffff813847ec ffffffff827d6a20 0000000000000000
> [ 2264.538807] <0> ffffffff814f5a42 0000000000000002 0000000000000000 ffff8803a067e948
> [ 2264.538835] <0> 0000000000000000 ffff8803a067e590 ffffffff8106a61b ffff8803a068fe68
> [ 2264.538857] Call Trace:
> [ 2264.538868]  [<ffffffff81065f5a>] ? worker_thread+0x15b/0x2b3
> [ 2264.538883]  [<ffffffff813847ec>] ? thread_return+0x3e/0xee
> [ 2264.538887]  [<ffffffff8106a61b>] ? autoremove_wake_function+0x0/0x3d
> [ 2264.538887]  [<ffffffff81065dff>] ? worker_thread+0x0/0x2b3
> [ 2264.538887]  [<ffffffff8106a510>] kthread+0x82/0x8a
> [ 2264.538887]  [<ffffffff8100cc1a>] child_rip+0xa/0x20
> [ 2264.538887]  [<ffffffff8100c5bc>] ? restore_args+0x0/0x30
> [ 2264.538887]  [<ffffffff8106a46d>] ? kthreadd+0xd5/0xf6
> [ 2264.538887]  [<ffffffff8106a48e>] ? kthread+0x0/0x8a
> [ 2264.538887]  [<ffffffff8100cc10>] ? child_rip+0x0/0x20
> [ 2264.538887] Code: 00 4c 89 ef 48 8b 08 48 8b 50 08 48 89 51 08 48 89 0a 48 89 40 08 48
> 89 00 e8 34 0c 32 00 49 8b 04 24 48 83 e0 fc 4c 39 e8 74 04 <0f> 0b eb fe f0 41 80 24 24 f
> e 49 8b bd a8 00 00 00 48 8d 9d 70
> [ 2264.538887] RIP  [<ffffffff81065f56>] worker_thread+0x157/0x2b3
> [ 2264.538887]  RSP <ffff8803a068fe10>
> [ 2264.539304] ---[ end trace d435092dd749cff6 ]---
> 
> 
> How about doing INIT_WORK() once in initialization like this ?
> After this patch, it has survived the same test for more than 6 hours w/o causing the BUG,
> while it survived for only 1 hour at most before.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Don't do INIT_WORK() repeatedly against the same work_struct.
> Just do it once in initialization.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks. you're much quicker than me.

Regards,
-Kame

> ---
>  mm/memcontrol.c |   13 ++++++++-----
>  1 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bc57916..fd8f65f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1349,8 +1349,8 @@ static void drain_all_stock_async(void)
>  	/* This function is for scheduling "drain" in asynchronous way.
>  	 * The result of "drain" is not directly handled by callers. Then,
>  	 * if someone is calling drain, we don't have to call drain more.
> -	 * Anyway, work_pending() will catch if there is a race. We just do
> -	 * loose check here.
> +	 * Anyway, WORK_STRUCT_PENDING check in queue_work_on() will catch if
> +	 * there is a race. We just do loose check here.
>  	 */
>  	if (atomic_read(&memcg_drain_count))
>  		return;
> @@ -1359,9 +1359,6 @@ static void drain_all_stock_async(void)
>  	get_online_cpus();
>  	for_each_online_cpu(cpu) {
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> -		if (work_pending(&stock->work))
> -			continue;
> -		INIT_WORK(&stock->work, drain_local_stock);
>  		schedule_work_on(cpu, &stock->work);
>  	}
>   	put_online_cpus();
> @@ -3327,11 +3324,17 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  
>  	/* root ? */
>  	if (cont->parent == NULL) {
> +		int cpu;
>  		enable_swap_cgroup();
>  		parent = NULL;
>  		root_mem_cgroup = mem;
>  		if (mem_cgroup_soft_limit_tree_init())
>  			goto free_out;
> +		for_each_possible_cpu(cpu) {
> +			struct memcg_stock_pcp *stock =
> +						&per_cpu(memcg_stock, cpu);
> +			INIT_WORK(&stock->work, drain_local_stock);
> +		}
>  		hotcpu_notifier(memcg_stock_cpu_callback, 0);
>  
>  	} else {
> -- 
> 1.5.6.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
