Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9135E6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 06:25:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so145092945pfx.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 03:25:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b84si3810874pfl.88.2017.02.07.03.25.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 03:25:08 -0800 (PST)
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <daa0ad53-4561-98d6-7a9f-c36c3a0659a8@I-love.SAKURA.ne.jp>
Date: Tue, 7 Feb 2017 20:24:13 +0900
MIME-Version: 1.0
In-Reply-To: <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On 2017/02/07 7:05, Mel Gorman wrote:
> On Mon, Feb 06, 2017 at 08:13:35PM +0100, Dmitry Vyukov wrote:
>> On Mon, Jan 30, 2017 at 4:48 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On Sun, Jan 29, 2017 at 6:22 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>> On 29.1.2017 13:44, Dmitry Vyukov wrote:
>>>>> Hello,
>>>>>
>>>>> I've got the following deadlock report while running syzkaller fuzzer
>>>>> on f37208bc3c9c2f811460ef264909dfbc7f605a60:
>>>>>
>>>>> [ INFO: possible circular locking dependency detected ]
>>>>> 4.10.0-rc5-next-20170125 #1 Not tainted
>>>>> -------------------------------------------------------
>>>>> syz-executor3/14255 is trying to acquire lock:
>>>>>  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff814271c7>]
>>>>> get_online_cpus+0x37/0x90 kernel/cpu.c:239
>>>>>
>>>>> but task is already holding lock:
>>>>>  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff81937fee>]
>>>>> pcpu_alloc+0xbfe/0x1290 mm/percpu.c:897
>>>>>
>>>>> which lock already depends on the new lock.
>>>>
>>>> I suspect the dependency comes from recent changes in drain_all_pages(). They
>>>> were later redone (for other reasons, but nice to have another validation) in
>>>> the mmots patch [1], which AFAICS is not yet in mmotm and thus linux-next. Could
>>>> you try if it helps?
>>>
>>> It happened only once on linux-next, so I can't verify the fix. But I
>>> will watch out for other occurrences.
>>
>> Unfortunately it does not seem to help.
> 
> I'm a little stuck on how to best handle this. get_online_cpus() can
> halt forever if the hotplug operation is holding the mutex when calling
> pcpu_alloc. One option would be to add a try_get_online_cpus() helper which
> trylocks the mutex. However, given that drain is so unlikely to actually
> make that make a difference when racing against parallel allocations,
> I think this should be acceptable.
> 
> Any objections?

Why below change on top of current linux.git (8b1b41ee74f9) insufficient?
I think it can eliminate IPIs a lot without introducing lockdep warnings.

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f3e0c69..ae6e7aa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2354,6 +2354,7 @@ void drain_local_pages(struct zone *zone)
  */
 void drain_all_pages(struct zone *zone)
 {
+	static DEFINE_MUTEX(lock);
 	int cpu;
 
 	/*
@@ -2362,6 +2363,7 @@ void drain_all_pages(struct zone *zone)
 	 */
 	static cpumask_t cpus_with_pcps;
 
+	mutex_lock(&lock);
 	/*
 	 * We don't care about racing with CPU hotplug event
 	 * as offline notification will cause the notified
@@ -2394,6 +2396,7 @@ void drain_all_pages(struct zone *zone)
 	}
 	on_each_cpu_mask(&cpus_with_pcps, (smp_call_func_t) drain_local_pages,
 								zone, 1);
+	mutex_unlock(&lock);
 }
 
 #ifdef CONFIG_HIBERNATION
----------

By the way, drain_all_pages() is a sleepable context, isn't it?
I don't get get soft lockup using current linux.git (8b1b41ee74f9).
But I trivially get soft lockup if I try above change after reverting
"mm, page_alloc: use static global work_struct for draining per-cpu pages" and
"mm, page_alloc: drain per-cpu pages from workqueue context" on linux-next-20170207 .
List corruption also came in with linux-next-20170207 .

----------
[   32.672890] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   33.109860] Ebtables v2.0 registered
[   33.410293] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   33.935512] IPv6: ADDRCONF(NETDEV_UP): eno16777728: link is not ready
[   33.937478] e1000: eno16777728 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
[   33.939777] IPv6: ADDRCONF(NETDEV_CHANGE): eno16777728: link becomes ready
[   34.194000] Netfilter messages via NETLINK v0.30.
[   34.258828] ip_set: protocol 6
[   38.518375] nf_conntrack: default automatic helper assignment has been turned off for security reasons and CT-based  firewall rule not found. Use the iptables CT target to attach helpers instead.
[   43.911609] cp (5167) used greatest stack depth: 10488 bytes left
[   48.174125] cp (5860) used greatest stack depth: 10224 bytes left
[  101.075280] ------------[ cut here ]------------
[  101.076743] WARNING: CPU: 0 PID: 9766 at lib/list_debug.c:25 __list_add_valid+0x46/0xa0
[  101.079095] list_add corruption. next->prev should be prev (ffffea00013dfce0), but was ffff88006d3e1d40. (next=ffff88006d3e1d40).
[  101.081863] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd ppdev glue_helper vmw_balloon pcspkr sg parport_pc parport i2c_piix4 shpchp vmw_vsock_vmci_transport vsock vmw_vmci ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel vmwgfx serio_raw drm_kms_helper syscopyarea sysfillrect
[  101.098346]  sysimgblt fb_sys_fops ttm mptspi scsi_transport_spi ata_piix mptscsih ahci drm libahci mptbase libata e1000 i2c_core
[  101.101279] CPU: 0 PID: 9766 Comm: oom-write Tainted: G        W       4.10.0-rc7-next-20170207+ #500
[  101.103519] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  101.106031] Call Trace:
[  101.107069]  dump_stack+0x85/0xc9
[  101.108239]  __warn+0xd1/0xf0
[  101.109566]  warn_slowpath_fmt+0x5f/0x80
[  101.110843]  __list_add_valid+0x46/0xa0
[  101.112187]  free_hot_cold_page+0x205/0x460
[  101.113593]  free_hot_cold_page_list+0x3c/0x1c0
[  101.115046]  shrink_page_list+0x4dd/0xd10
[  101.116388]  shrink_inactive_list+0x1c5/0x660
[  101.117796]  shrink_node_memcg+0x535/0x7f0
[  101.119158]  ? mem_cgroup_iter+0x1e0/0x720
[  101.120873]  shrink_node+0xe1/0x310
[  101.122250]  do_try_to_free_pages+0xe1/0x300
[  101.123611]  try_to_free_pages+0x131/0x3f0
[  101.124998]  __alloc_pages_slowpath+0x479/0xe32
[  101.126421]  __alloc_pages_nodemask+0x382/0x3d0
[  101.128053]  alloc_pages_vma+0xae/0x2f0
[  101.129353]  do_anonymous_page+0x111/0x5d0
[  101.130725]  __handle_mm_fault+0xbc9/0xeb0
[  101.132127]  ? sched_clock+0x9/0x10
[  101.133389]  ? sched_clock_cpu+0x11/0xc0
[  101.134764]  handle_mm_fault+0x16b/0x390
[  101.136147]  ? handle_mm_fault+0x49/0x390
[  101.137545]  __do_page_fault+0x24a/0x530
[  101.138999]  do_page_fault+0x30/0x80
[  101.140375]  page_fault+0x28/0x30
[  101.141685] RIP: 0033:0x4006a0
[  101.142880] RSP: 002b:00007ffe3a4acc10 EFLAGS: 00010206
[  101.144638] RAX: 0000000037f8e000 RBX: 0000000080000000 RCX: 00007fc5a1fda650
[  101.146653] RDX: 0000000000000000 RSI: 00007ffe3a4aca30 RDI: 00007ffe3a4aca30
[  101.148768] RBP: 00007fc4a2111010 R08: 00007ffe3a4acb40 R09: 00007ffe3a4ac980
[  101.150893] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000007
[  101.152937] R13: 00007fc4a2111010 R14: 0000000000000000 R15: 0000000000000000
[  101.155240] ---[ end trace 5d8b63572ab78be3 ]---
[  128.945470] NMI watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [oom-write:9766]
[  128.947878] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd ppdev glue_helper vmw_balloon pcspkr sg parport_pc parport i2c_piix4 shpchp vmw_vsock_vmci_transport vsock vmw_vmci ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel vmwgfx serio_raw drm_kms_helper syscopyarea sysfillrect
[  128.966961]  sysimgblt fb_sys_fops ttm mptspi scsi_transport_spi ata_piix mptscsih ahci drm libahci mptbase libata e1000 i2c_core
[  128.970135] irq event stamp: 2491700
[  128.971666] hardirqs last  enabled at (2491699): [<ffffffff817e5d70>] restore_regs_and_iret+0x0/0x1d
[  128.974560] hardirqs last disabled at (2491700): [<ffffffff817e7198>] apic_timer_interrupt+0x98/0xb0
[  128.977148] softirqs last  enabled at (2445236): [<ffffffff817eab39>] __do_softirq+0x349/0x52d
[  128.979639] softirqs last disabled at (2445215): [<ffffffff810a99e5>] irq_exit+0xf5/0x110
[  128.982019] CPU: 2 PID: 9766 Comm: oom-write Tainted: G        W       4.10.0-rc7-next-20170207+ #500
[  128.984598] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  128.987490] task: ffff880067ed8040 task.stack: ffffc9001117c000
[  128.989464] RIP: 0010:smp_call_function_many+0x25c/0x320
[  128.991305] RSP: 0000:ffffc9001117fad0 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
[  128.993609] RAX: 0000000000000000 RBX: ffff88006d7dd640 RCX: 0000000000000001
[  128.995823] RDX: 0000000000000001 RSI: ffff88006d3e3398 RDI: ffff88006c528dc8
[  128.998058] RBP: ffffc9001117fb18 R08: 0000000000000009 R09: 0000000000000000
[  129.000284] R10: 0000000000000001 R11: ffff88005486d4a8 R12: 0000000000000000
[  129.002521] R13: ffffffff811fe6e0 R14: 0000000000000000 R15: 0000000000000080
[  129.004788] FS:  00007fc5a24ec740(0000) GS:ffff88006d600000(0000) knlGS:0000000000000000
[  129.007235] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  129.009211] CR2: 00007fc4da0c5010 CR3: 0000000044314000 CR4: 00000000001406e0
[  129.011641] Call Trace:
[  129.012993]  ? page_alloc_cpu_dead+0x30/0x30
[  129.014701]  on_each_cpu_mask+0x30/0xb0
[  129.016318]  drain_all_pages+0x113/0x170
[  129.017949]  __alloc_pages_slowpath+0x520/0xe32
[  129.019710]  __alloc_pages_nodemask+0x382/0x3d0
[  129.021472]  alloc_pages_vma+0xae/0x2f0
[  129.023080]  do_anonymous_page+0x111/0x5d0
[  129.024760]  __handle_mm_fault+0xbc9/0xeb0
[  129.026449]  ? sched_clock+0x9/0x10
[  129.028042]  ? sched_clock_cpu+0x11/0xc0
[  129.029729]  handle_mm_fault+0x16b/0x390
[  129.031418]  ? handle_mm_fault+0x49/0x390
[  129.033077]  __do_page_fault+0x24a/0x530
[  129.034721]  do_page_fault+0x30/0x80
[  129.036279]  page_fault+0x28/0x30
[  129.038160] RIP: 0033:0x4006a0
[  129.039600] RSP: 002b:00007ffe3a4acc10 EFLAGS: 00010206
[  129.041488] RAX: 0000000037fb4000 RBX: 0000000080000000 RCX: 00007fc5a1fda650
[  129.043758] RDX: 0000000000000000 RSI: 00007ffe3a4aca30 RDI: 00007ffe3a4aca30
[  129.046037] RBP: 00007fc4a2111010 R08: 00007ffe3a4acb40 R09: 00007ffe3a4ac980
[  129.048324] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000007
[  129.050587] R13: 00007fc4a2111010 R14: 0000000000000000 R15: 0000000000000000
[  129.052829] Code: 7b 3e 2b 00 3b 05 69 b6 d5 00 41 89 c4 0f 8d 3f fe ff ff 48 63 d0 48 8b 33 48 03 34 d5 60 c4 ab 81 8b 56 18 83 e2 01 74 0a f3 90 <8b> 4e 18 83 e1 01 75 f6 83 f8 ff 48 8b 7b 08 74 2a 48 63 35 30 
[  156.945366] NMI watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [oom-write:9766]
[  156.947797] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd ppdev glue_helper vmw_balloon pcspkr sg parport_pc parport i2c_piix4 shpchp vmw_vsock_vmci_transport vsock vmw_vmci ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel vmwgfx serio_raw drm_kms_helper syscopyarea sysfillrect
[  156.968021]  sysimgblt fb_sys_fops ttm mptspi scsi_transport_spi ata_piix mptscsih ahci drm libahci mptbase libata e1000 i2c_core
[  156.971269] irq event stamp: 2547400
[  156.972865] hardirqs last  enabled at (2547399): [<ffffffff817e5d70>] restore_regs_and_iret+0x0/0x1d
[  156.975579] hardirqs last disabled at (2547400): [<ffffffff817e7198>] apic_timer_interrupt+0x98/0xb0
[  156.978287] softirqs last  enabled at (2445236): [<ffffffff817eab39>] __do_softirq+0x349/0x52d
[  156.980863] softirqs last disabled at (2445215): [<ffffffff810a99e5>] irq_exit+0xf5/0x110
[  156.983393] CPU: 2 PID: 9766 Comm: oom-write Tainted: G        W    L  4.10.0-rc7-next-20170207+ #500
[  156.986111] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  156.989117] task: ffff880067ed8040 task.stack: ffffc9001117c000
[  156.991179] RIP: 0010:smp_call_function_many+0x25c/0x320
[  156.993113] RSP: 0000:ffffc9001117fad0 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
[  156.995501] RAX: 0000000000000000 RBX: ffff88006d7dd640 RCX: 0000000000000001
[  156.997803] RDX: 0000000000000001 RSI: ffff88006d3e3398 RDI: ffff88006c528dc8
[  157.000111] RBP: ffffc9001117fb18 R08: 0000000000000009 R09: 0000000000000000
[  157.002402] R10: 0000000000000001 R11: ffff88005486d4a8 R12: 0000000000000000
[  157.004700] R13: ffffffff811fe6e0 R14: 0000000000000000 R15: 0000000000000080
[  157.006980] FS:  00007fc5a24ec740(0000) GS:ffff88006d600000(0000) knlGS:0000000000000000
[  157.009477] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  157.011494] CR2: 00007fc4da0c5010 CR3: 0000000044314000 CR4: 00000000001406e0
[  157.013844] Call Trace:
[  157.015231]  ? page_alloc_cpu_dead+0x30/0x30
[  157.016975]  on_each_cpu_mask+0x30/0xb0
[  157.018723]  drain_all_pages+0x113/0x170
[  157.020410]  __alloc_pages_slowpath+0x520/0xe32
[  157.022219]  __alloc_pages_nodemask+0x382/0x3d0
[  157.024036]  alloc_pages_vma+0xae/0x2f0
[  157.025704]  do_anonymous_page+0x111/0x5d0
[  157.027430]  __handle_mm_fault+0xbc9/0xeb0
[  157.029143]  ? sched_clock+0x9/0x10
[  157.030739]  ? sched_clock_cpu+0x11/0xc0
[  157.032416]  handle_mm_fault+0x16b/0x390
[  157.034100]  ? handle_mm_fault+0x49/0x390
[  157.035843]  __do_page_fault+0x24a/0x530
[  157.037537]  do_page_fault+0x30/0x80
[  157.039160]  page_fault+0x28/0x30
[  157.040792] RIP: 0033:0x4006a0
[  157.042290] RSP: 002b:00007ffe3a4acc10 EFLAGS: 00010206
[  157.044231] RAX: 0000000037fb4000 RBX: 0000000080000000 RCX: 00007fc5a1fda650
[  157.046635] RDX: 0000000000000000 RSI: 00007ffe3a4aca30 RDI: 00007ffe3a4aca30
[  157.048941] RBP: 00007fc4a2111010 R08: 00007ffe3a4acb40 R09: 00007ffe3a4ac980
[  157.051324] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000007
[  157.053577] R13: 00007fc4a2111010 R14: 0000000000000000 R15: 0000000000000000
[  157.055822] Code: 7b 3e 2b 00 3b 05 69 b6 d5 00 41 89 c4 0f 8d 3f fe ff ff 48 63 d0 48 8b 33 48 03 34 d5 60 c4 ab 81 8b 56 18 83 e2 01 74 0a f3 90 <8b> 4e 18 83 e1 01 75 f6 83 f8 ff 48 8b 7b 08 74 2a 48 63 35 30 
[  171.241423] BUG: spinlock lockup suspected on CPU#3, swapper/3/0
[  171.243575]  lock: 0xffff88007ffddd00, .magic: dead4ead, .owner: kworker/0:3/9777, .owner_cpu: 0
[  171.246136] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G        W    L  4.10.0-rc7-next-20170207+ #500
[  171.248706] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  171.251617] Call Trace:
[  171.252854]  <IRQ>
[  171.253989]  dump_stack+0x85/0xc9
[  171.255376]  spin_dump+0x90/0x95
[  171.256741]  do_raw_spin_lock+0x9a/0x130
[  171.258246]  _raw_spin_lock_irqsave+0x75/0x90
[  171.259822]  ? free_pcppages_bulk+0x37/0x910
[  171.261359]  free_pcppages_bulk+0x37/0x910
[  171.262843]  ? sched_clock_cpu+0x11/0xc0
[  171.264289]  ? sched_clock_tick+0x2d/0x80
[  171.265747]  drain_pages_zone+0x82/0x90
[  171.267154]  ? page_alloc_cpu_dead+0x30/0x30
[  171.268644]  drain_pages+0x3f/0x60
[  171.269955]  drain_local_pages+0x25/0x30
[  171.271366]  flush_smp_call_function_queue+0x7b/0x170
[  171.273014]  generic_smp_call_function_single_interrupt+0x13/0x30
[  171.274878]  smp_call_function_interrupt+0x27/0x40
[  171.276460]  call_function_interrupt+0x9d/0xb0
[  171.277963] RIP: 0010:native_safe_halt+0x6/0x10
[  171.279467] RSP: 0018:ffffc900003a3e70 EFLAGS: 00000206 ORIG_RAX: ffffffffffffff03
[  171.281610] RAX: ffff88006c5c0040 RBX: 0000000000000000 RCX: 0000000000000000
[  171.283662] RDX: ffff88006c5c0040 RSI: 0000000000000001 RDI: ffff88006c5c0040
[  171.285727] RBP: ffffc900003a3e70 R08: 0000000000000000 R09: 0000000000000000
[  171.287778] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000003
[  171.289831] R13: ffff88006c5c0040 R14: ffff88006c5c0040 R15: 0000000000000000
[  171.291882]  </IRQ>
[  171.292934]  default_idle+0x23/0x1d0
[  171.294287]  arch_cpu_idle+0xf/0x20
[  171.295618]  default_idle_call+0x23/0x40
[  171.297040]  do_idle+0x162/0x230
[  171.298308]  cpu_startup_entry+0x71/0x80
[  171.299732]  start_secondary+0x17f/0x1f0
[  171.301146]  start_cpu+0x14/0x14
[  171.302432] NMI backtrace for cpu 3
[  171.303764] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G        W    L  4.10.0-rc7-next-20170207+ #500
[  171.306218] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  171.309065] Call Trace:
[  171.310500]  <IRQ>
[  171.311569]  dump_stack+0x85/0xc9
[  171.312946]  nmi_cpu_backtrace+0xc0/0xe0
[  171.314396]  ? irq_force_complete_move+0x170/0x170
[  171.316012]  nmi_trigger_cpumask_backtrace+0x12a/0x188
[  171.317679]  arch_trigger_cpumask_backtrace+0x19/0x20
[  171.319294]  do_raw_spin_lock+0xa8/0x130
[  171.320686]  _raw_spin_lock_irqsave+0x75/0x90
[  171.322148]  ? free_pcppages_bulk+0x37/0x910
[  171.323585]  free_pcppages_bulk+0x37/0x910
[  171.325037]  ? sched_clock_cpu+0x11/0xc0
[  171.326615]  ? sched_clock_tick+0x2d/0x80
[  171.327974]  drain_pages_zone+0x82/0x90
[  171.329294]  ? page_alloc_cpu_dead+0x30/0x30
[  171.330707]  drain_pages+0x3f/0x60
[  171.331938]  drain_local_pages+0x25/0x30
[  171.333283]  flush_smp_call_function_queue+0x7b/0x170
[  171.334855]  generic_smp_call_function_single_interrupt+0x13/0x30
[  171.336643]  smp_call_function_interrupt+0x27/0x40
[  171.338456]  call_function_interrupt+0x9d/0xb0
[  171.339911] RIP: 0010:native_safe_halt+0x6/0x10
[  171.341522] RSP: 0018:ffffc900003a3e70 EFLAGS: 00000206 ORIG_RAX: ffffffffffffff03
[  171.343860] RAX: ffff88006c5c0040 RBX: 0000000000000000 RCX: 0000000000000000
[  171.346001] RDX: ffff88006c5c0040 RSI: 0000000000000001 RDI: ffff88006c5c0040
[  171.348134] RBP: ffffc900003a3e70 R08: 0000000000000000 R09: 0000000000000000
[  171.350270] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000003
[  171.352384] R13: ffff88006c5c0040 R14: ffff88006c5c0040 R15: 0000000000000000
[  171.354503]  </IRQ>
[  171.355616]  default_idle+0x23/0x1d0
[  171.357055]  arch_cpu_idle+0xf/0x20
[  171.361577]  default_idle_call+0x23/0x40
[  171.364329]  do_idle+0x162/0x230
[  171.365799]  cpu_startup_entry+0x71/0x80
[  171.367172]  start_secondary+0x17f/0x1f0
[  171.368530]  start_cpu+0x14/0x14
[  171.369748] Sending NMI from CPU 3 to CPUs 0-2:
[  171.371367] NMI backtrace for cpu 2
[  171.371368] CPU: 2 PID: 9766 Comm: oom-write Tainted: G        W    L  4.10.0-rc7-next-20170207+ #500
[  171.371368] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  171.371369] task: ffff880067ed8040 task.stack: ffffc9001117c000
[  171.371369] RIP: 0010:smp_call_function_many+0x25c/0x320
[  171.371370] RSP: 0000:ffffc9001117fad0 EFLAGS: 00000202
[  171.371371] RAX: 0000000000000000 RBX: ffff88006d7dd640 RCX: 0000000000000001
[  171.371372] RDX: 0000000000000001 RSI: ffff88006d3e3398 RDI: ffff88006c528dc8
[  171.371372] RBP: ffffc9001117fb18 R08: 0000000000000009 R09: 0000000000000000
[  171.371372] R10: 0000000000000001 R11: ffff88005486d4a8 R12: 0000000000000000
[  171.371373] R13: ffffffff811fe6e0 R14: 0000000000000000 R15: 0000000000000080
[  171.371373] FS:  00007fc5a24ec740(0000) GS:ffff88006d600000(0000) knlGS:0000000000000000
[  171.371374] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  171.371374] CR2: 00007fc4da0c5010 CR3: 0000000044314000 CR4: 00000000001406e0
[  171.371375] Call Trace:
[  171.371375]  ? page_alloc_cpu_dead+0x30/0x30
[  171.371375]  on_each_cpu_mask+0x30/0xb0
[  171.371376]  drain_all_pages+0x113/0x170
[  171.371376]  __alloc_pages_slowpath+0x520/0xe32
[  171.371377]  __alloc_pages_nodemask+0x382/0x3d0
[  171.371377]  alloc_pages_vma+0xae/0x2f0
[  171.371377]  do_anonymous_page+0x111/0x5d0
[  171.371378]  __handle_mm_fault+0xbc9/0xeb0
[  171.371378]  ? sched_clock+0x9/0x10
[  171.371379]  ? sched_clock_cpu+0x11/0xc0
[  171.371379]  handle_mm_fault+0x16b/0x390
[  171.371379]  ? handle_mm_fault+0x49/0x390
[  171.371380]  __do_page_fault+0x24a/0x530
[  171.371380]  do_page_fault+0x30/0x80
[  171.371381]  page_fault+0x28/0x30
[  171.371381] RIP: 0033:0x4006a0
[  171.371381] RSP: 002b:00007ffe3a4acc10 EFLAGS: 00010206
[  171.371382] RAX: 0000000037fb4000 RBX: 0000000080000000 RCX: 00007fc5a1fda650
[  171.371383] RDX: 0000000000000000 RSI: 00007ffe3a4aca30 RDI: 00007ffe3a4aca30
[  171.371383] RBP: 00007fc4a2111010 R08: 00007ffe3a4acb40 R09: 00007ffe3a4ac980
[  171.371384] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000007
[  171.371384] R13: 00007fc4a2111010 R14: 0000000000000000 R15: 0000000000000000
[  171.371385] Code: 7b 3e 2b 00 3b 05 69 b6 d5 00 41 89 c4 0f 8d 3f fe ff ff 48 63 d0 48 8b 33 48 03 34 d5 60 c4 ab 81 8b 56 18 83 e2 01 74 0a f3 90 <8b> 4e 18 83 e1 01 75 f6 83 f8 ff 48 8b 7b 08 74 2a 48 63 35 30 
[  171.372317] NMI backtrace for cpu 0
[  171.372317] CPU: 0 PID: 9777 Comm: kworker/0:3 Tainted: G        W    L  4.10.0-rc7-next-20170207+ #500
[  171.372318] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  171.372318] Workqueue: events vmw_fb_dirty_flush [vmwgfx]
[  171.372319] task: ffff880064082540 task.stack: ffffc90013b54000
[  171.372320] RIP: 0010:free_pcppages_bulk+0xbb/0x910
[  171.372320] RSP: 0000:ffff88006d203eb0 EFLAGS: 00000002
[  171.372321] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000010
[  171.372322] RDX: 0000000000000000 RSI: 00000000357cc759 RDI: ffff88006d3e1d50
[  171.372322] RBP: ffff88006d203f38 R08: ffff88006d3e1d20 R09: 0000000000000002
[  171.372323] R10: 0000000000000000 R11: 000000000004f7f0 R12: ffff88007ffdd8f8
[  171.372323] R13: ffffea00013dfc20 R14: ffffea00013dfc00 R15: ffff88007ffdd740
[  171.372324] FS:  0000000000000000(0000) GS:ffff88006d200000(0000) knlGS:0000000000000000
[  171.372324] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  171.372325] CR2: 00007fc4da09f010 CR3: 0000000044314000 CR4: 00000000001406f0
[  171.372325] Call Trace:
[  171.372325]  <IRQ>
[  171.372326]  ? trace_hardirqs_off+0xd/0x10
[  171.372326]  drain_pages_zone+0x82/0x90
[  171.372327]  ? page_alloc_cpu_dead+0x30/0x30
[  171.372327]  drain_pages+0x3f/0x60
[  171.372327]  drain_local_pages+0x25/0x30
[  171.372328]  flush_smp_call_function_queue+0x7b/0x170
[  171.372328]  generic_smp_call_function_single_interrupt+0x13/0x30
[  171.372329]  smp_call_function_interrupt+0x27/0x40
[  171.372329]  call_function_interrupt+0x9d/0xb0
[  171.372330] RIP: 0010:memcpy_orig+0x19/0x110
[  171.372330] RSP: 0000:ffffc90013b57d98 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff03
[  171.372331] RAX: ffffc90003f1c400 RBX: ffff880063b54a88 RCX: 0000000000000004
[  171.372331] RDX: 00000000000010e0 RSI: ffffc900037d3900 RDI: ffffc90003f1c6e0
[  171.372332] RBP: ffffc90013b57e08 R08: 0000000000000000 R09: 0000000000000000
[  171.372332] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000001400
[  171.372333] R13: 000000000000011e R14: ffff880063b55168 R15: ffffc900037d3620
[  171.372333]  </IRQ>
[  171.372333]  ? vmw_fb_dirty_flush+0x1ef/0x2b0 [vmwgfx]
[  171.372334]  process_one_work+0x22b/0x760
[  171.372334]  ? process_one_work+0x194/0x760
[  171.372335]  worker_thread+0x137/0x4b0
[  171.372335]  kthread+0x10f/0x150
[  171.372335]  ? process_one_work+0x760/0x760
[  171.372336]  ? kthread_create_on_node+0x70/0x70
[  171.372336]  ? do_syscall_64+0x6c/0x200
[  171.372337]  ret_from_fork+0x31/0x40
[  171.372337] Code: 00 00 4d 89 cf 8b 45 98 8b 75 9c 31 d2 4c 8b 85 78 ff ff ff 83 c0 01 83 c6 01 83 f8 03 0f 44 c2 48 63 c8 48 83 c1 01 48 c1 e1 04 <4c> 01 c1 48 8b 39 48 39 f9 74 de 89 45 98 83 fe 03 89 f0 0f 44 
[  171.372357] NMI backtrace for cpu 1
[  171.372357] CPU: 1 PID: 47 Comm: khugepaged Tainted: G        W    L  4.10.0-rc7-next-20170207+ #500
[  171.372358] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  171.372358] task: ffff88006bd22540 task.stack: ffffc90000890000
[  171.372359] RIP: 0010:delay_tsc+0x48/0x70
[  171.372359] RSP: 0018:ffffc90000893520 EFLAGS: 00000006
[  171.372360] RAX: 000000004e0ee6be RBX: ffff88007ffddd00 RCX: 000000774e0ee6a6
[  171.372360] RDX: 0000000000000077 RSI: 0000000000000001 RDI: 0000000000000001
[  171.372361] RBP: ffffc90000893520 R08: 0000000000000000 R09: 0000000000000000
[  171.372361] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000a6822110
[  171.372362] R13: 0000000083093e7f R14: 0000000000000001 R15: ffffea000137a020
[  171.372362] FS:  0000000000000000(0000) GS:ffff88006d400000(0000) knlGS:0000000000000000
[  171.372363] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  171.372363] CR2: 00007ff5aeb82000 CR3: 0000000068093000 CR4: 00000000001406e0
[  171.372363] Call Trace:
[  171.372364]  __delay+0xf/0x20
[  171.372364]  do_raw_spin_lock+0x86/0x130
[  171.372365]  _raw_spin_lock_irqsave+0x75/0x90
[  171.372365]  ? free_pcppages_bulk+0x37/0x910
[  171.372365]  free_pcppages_bulk+0x37/0x910
[  171.372366]  ? __kernel_map_pages+0x87/0x120
[  171.372366]  free_hot_cold_page+0x373/0x460
[  171.372367]  free_hot_cold_page_list+0x3c/0x1c0
[  171.372367]  shrink_page_list+0x4dd/0xd10
[  171.372368]  shrink_inactive_list+0x1c5/0x660
[  171.372368]  shrink_node_memcg+0x535/0x7f0
[  171.372368]  ? mem_cgroup_iter+0x14d/0x720
[  171.372369]  shrink_node+0xe1/0x310
[  171.372369]  do_try_to_free_pages+0xe1/0x300
[  171.372370]  try_to_free_pages+0x131/0x3f0
[  171.372370]  __alloc_pages_slowpath+0x479/0xe32
[  171.372370]  __alloc_pages_nodemask+0x382/0x3d0
[  171.372371]  khugepaged_alloc_page+0x6d/0xd0
[  171.372371]  collapse_huge_page+0x81/0x1240
[  171.372372]  ? sched_clock_cpu+0x11/0xc0
[  171.372372]  ? khugepaged_scan_mm_slot+0xc26/0x1000
[  171.372373]  khugepaged_scan_mm_slot+0xc49/0x1000
[  171.372373]  ? sched_clock_cpu+0x11/0xc0
[  171.372373]  ? finish_wait+0x75/0x90
[  171.372374]  khugepaged+0x327/0x5e0
[  171.372374]  ? remove_wait_queue+0x60/0x60
[  171.372375]  kthread+0x10f/0x150
[  171.372375]  ? khugepaged_scan_mm_slot+0x1000/0x1000
[  171.372375]  ? kthread_create_on_node+0x70/0x70
[  171.372376]  ret_from_fork+0x31/0x40
[  171.372376] Code: 89 d1 48 c1 e1 20 48 09 c1 eb 1b 65 ff 0d c9 0a c1 7e f3 90 65 ff 05 c0 0a c1 7e 65 8b 05 51 d7 c0 7e 39 c6 75 20 0f ae e8 0f 31 <48> c1 e2 20 48 09 c2 48 89 d0 48 29 c8 48 39 f8 72 ce 65 ff 0d 
----------

I also got soft lockup without any change using linux-next-20170202.
Something is wrong with calling multiple CPUs? List corruption?

----------
[   80.556598] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   84.020374] IPv6: ADDRCONF(NETDEV_UP): eno16777728: link is not ready
[   84.024423] e1000: eno16777728 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
[   84.030731] IPv6: ADDRCONF(NETDEV_CHANGE): eno16777728: link becomes ready
[   84.212613] Ebtables v2.0 registered
[   86.841246] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   90.594709] Netfilter messages via NETLINK v0.30.
[   90.756119] ip_set: protocol 6
[  161.309259] NMI watchdog: BUG: soft lockup - CPU#3 stuck for 23s! [ip6tables-resto:4210]
[  162.329982] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd ppdev glue_helper vmw_balloon pcspkr sg parport_pc parport i2c_piix4 shpchp vmw_vsock_vmci_transport vsock vmw_vmci ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect
[  162.486639]  sysimgblt fb_sys_fops ttm e1000 mptspi ahci scsi_transport_spi drm libahci ata_piix mptscsih i2c_core mptbase libata
[  162.486651] irq event stamp: 306010
[  162.486656] hardirqs last  enabled at (306009): [<ffffffff817e4970>] restore_regs_and_iret+0x0/0x1d
[  162.486658] hardirqs last disabled at (306010): [<ffffffff817e5d98>] apic_timer_interrupt+0x98/0xb0
[  162.486661] softirqs last  enabled at (306008): [<ffffffff817e9739>] __do_softirq+0x349/0x52d
[  162.486664] softirqs last disabled at (306001): [<ffffffff810a98c5>] irq_exit+0xf5/0x110
[  162.486666] CPU: 3 PID: 4210 Comm: ip6tables-resto Not tainted 4.10.0-rc6-next-20170202 #498
[  162.486667] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  162.486668] task: ffff880062eb4a40 task.stack: ffffc900054e8000
[  162.486671] RIP: 0010:smp_call_function_many+0x25c/0x320
[  162.486672] RSP: 0018:ffffc900054ebc98 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
[  162.486674] RAX: 0000000000000000 RBX: ffff88006d9dd680 RCX: 0000000000000001
[  162.486675] RDX: 0000000000000001 RSI: ffff88006d3e3600 RDI: ffff88006c52ad68
[  162.486675] RBP: ffffc900054ebce0 R08: 0000000000000007 R09: 0000000000000000
[  162.486676] R10: 0000000000000001 R11: ffff880067ecd768 R12: 0000000000000000
[  162.486677] R13: ffffffff81080790 R14: ffffc900054ebd18 R15: 0000000000000080
[  162.486678] FS:  00007f37a4b86740(0000) GS:ffff88006d800000(0000) knlGS:0000000000000000
[  162.486679] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  162.486680] CR2: 00000000008ed017 CR3: 0000000053f70000 CR4: 00000000001406e0
[  162.486719] Call Trace:
[  162.486725]  ? x86_configure_nx+0x50/0x50
[  162.486727]  on_each_cpu+0x3b/0xa0
[  162.486730]  flush_tlb_kernel_range+0x79/0x80
[  162.486734]  remove_vm_area+0xb1/0xc0
[  162.486737]  __vunmap+0x2e/0x110
[  162.486739]  vfree+0x2e/0x70
[  162.486744]  do_ip6t_get_ctl+0x2de/0x370 [ip6_tables]
[  162.486751]  nf_getsockopt+0x49/0x70
[  162.486755]  ipv6_getsockopt+0xd3/0x130
[  162.486758]  rawv6_getsockopt+0x2c/0x70
[  162.486761]  sock_common_getsockopt+0x14/0x20
[  162.486763]  SyS_getsockopt+0x77/0xe0
[  162.486767]  do_syscall_64+0x6c/0x200
[  162.486770]  entry_SYSCALL64_slow_path+0x25/0x25
[  162.486771] RIP: 0033:0x7f37a3d9151a
[  162.486772] RSP: 002b:00007ffeecccd9e8 EFLAGS: 00000202 ORIG_RAX: 0000000000000037
[  162.486774] RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 00007f37a3d9151a
[  162.486774] RDX: 0000000000000041 RSI: 0000000000000029 RDI: 0000000000000003
[  162.486775] RBP: 00000000008e90c0 R08: 00007ffeecccda30 R09: feff7164736b6865
[  162.486776] R10: 00000000008e90c0 R11: 0000000000000202 R12: 00007ffeecccdf60
[  162.486777] R13: 00000000008e9010 R14: 00007ffeecccda40 R15: 0000000000000000
[  162.486783] Code: bb 39 2b 00 3b 05 a9 40 c7 00 41 89 c4 0f 8d 3f fe ff ff 48 63 d0 48 8b 33 48 03 34 d5 60 c4 ab 81 8b 56 18 83 e2 01 74 0a f3 90 <8b> 4e 18 83 e1 01 75 f6 83 f8 ff 48 8b 7b 08 74 2a 48 63 35 70 
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
