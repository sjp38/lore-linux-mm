Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 013C26B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 22:45:47 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ey11so203317pad.6
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 19:45:47 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rz7si5019136pab.123.2014.09.11.19.45.46
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 19:45:46 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [Bugfix] x86, NUMA, ACPI: Online node earlier when doing CPU hot-addition
Date: Fri, 12 Sep 2014 10:48:20 +0800
Message-Id: <1410490100-6386-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

With typical CPU hot-addition flow on x86, PCI host bridges embedded
in physical processor are always associated with NOMA_NO_NODE, which
may cause sub-optimal performance.
1) Handle CPU hot-addition notification
	acpi_processor_add()
		acpi_processor_get_info()
			acpi_processor_hotadd_init()
				acpi_map_lsapic()
1.a)					acpi_map_cpu2node()

2) Handle PCI host bridge hot-addition notification
	acpi_pci_root_add()
		pci_acpi_scan_root()
2.a)			if (node != NUMA_NO_NODE && !node_online(node)) node = NUMA_NO_NODE;

3) Handle memory hot-addition notification
	acpi_memory_device_add()
		acpi_memory_enable_device()
			add_memory()
3.a)				node_set_online();

4) Online CPUs through sysfs interfaces
	cpu_subsys_online()
		cpu_up()
			try_online_node()
4.a)				node_set_online();

So associated node is always in offline state because it is onlined
until step 3.a or 4.a.

We could improve performance by online node at step 1.a. This change
also makes the code symmetric. Nodes are always created when handling
CPU/memory hot-addition events instead of handling user requests from
sysfs interfaces, and are destroyed when handling CPU/memory hot-removal
events.

It also close a race window caused by kmalloc_node(cpu_to_node(cpu)),
which may cause system panic as below.
[ 3663.324476] BUG: unable to handle kernel paging request at 0000000000001f08
[ 3663.332348] IP: [<ffffffff81172219>] __alloc_pages_nodemask+0xb9/0x2d0
[ 3663.339719] PGD 82fe10067 PUD 82ebef067 PMD 0
[ 3663.344773] Oops: 0000 [#1] SMP
[ 3663.348455] Modules linked in: shpchp gpio_ich x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd microcode joydev sb_edac edac_core lpc_ich ipmi_si tpm_tis ipmi_msghandler ioatdma wmi acpi_pad mac_hid lp parport ixgbe isci mpt2sas dca ahci ptp libsas libahci raid_class pps_core scsi_transport_sas mdio hid_generic usbhid hid
[ 3663.394393] CPU: 61 PID: 2416 Comm: cron Tainted: G        W    3.14.0-rc5+ #21
[ 3663.402643] Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS BRIVTIN1.86B.0047.F03.1403031049 03/03/2014
[ 3663.414299] task: ffff88082fe54b00 ti: ffff880845fba000 task.ti: ffff880845fba000
[ 3663.422741] RIP: 0010:[<ffffffff81172219>]  [<ffffffff81172219>] __alloc_pages_nodemask+0xb9/0x2d0
[ 3663.432857] RSP: 0018:ffff880845fbbcd0  EFLAGS: 00010246
[ 3663.439265] RAX: 0000000000001f00 RBX: 0000000000000000 RCX: 0000000000000000
[ 3663.447291] RDX: 0000000000000000 RSI: 0000000000000a8d RDI: ffffffff81a8d950
[ 3663.455318] RBP: ffff880845fbbd58 R08: ffff880823293400 R09: 0000000000000001
[ 3663.463345] R10: 0000000000000001 R11: 0000000000000000 R12: 00000000002052d0
[ 3663.471363] R13: ffff880854c07600 R14: 0000000000000002 R15: 0000000000000000
[ 3663.479389] FS:  00007f2e8b99e800(0000) GS:ffff88105a400000(0000) knlGS:0000000000000000
[ 3663.488514] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3663.495018] CR2: 0000000000001f08 CR3: 00000008237b1000 CR4: 00000000001407e0
[ 3663.503476] Stack:
[ 3663.505757]  ffffffff811bd74d ffff880854c01d98 ffff880854c01df0 ffff880854c01dd0
[ 3663.514167]  00000003208ca420 000000075a5d84d0 ffff88082fe54b00 ffffffff811bb35f
[ 3663.522567]  ffff880854c07600 0000000000000003 0000000000001f00 ffff880845fbbd48
[ 3663.530976] Call Trace:
[ 3663.533753]  [<ffffffff811bd74d>] ? deactivate_slab+0x41d/0x4f0
[ 3663.540421]  [<ffffffff811bb35f>] ? new_slab+0x3f/0x2d0
[ 3663.546307]  [<ffffffff811bb3c5>] new_slab+0xa5/0x2d0
[ 3663.552001]  [<ffffffff81768c97>] __slab_alloc+0x35d/0x54a
[ 3663.558185]  [<ffffffff810a4845>] ? local_clock+0x25/0x30
[ 3663.564686]  [<ffffffff8177a34c>] ? __do_page_fault+0x4ec/0x5e0
[ 3663.571356]  [<ffffffff810b0054>] ? alloc_fair_sched_group+0xc4/0x190
[ 3663.578609]  [<ffffffff810c77f1>] ? __raw_spin_lock_init+0x21/0x60
[ 3663.585570]  [<ffffffff811be476>] kmem_cache_alloc_node_trace+0xa6/0x1d0
[ 3663.593112]  [<ffffffff810b0054>] ? alloc_fair_sched_group+0xc4/0x190
[ 3663.600363]  [<ffffffff810b0054>] alloc_fair_sched_group+0xc4/0x190
[ 3663.607423]  [<ffffffff810a359f>] sched_create_group+0x3f/0x80
[ 3663.613994]  [<ffffffff810b611f>] sched_autogroup_create_attach+0x3f/0x1b0
[ 3663.621732]  [<ffffffff8108258a>] sys_setsid+0xea/0x110
[ 3663.628020]  [<ffffffff8177f42d>] system_call_fastpath+0x1a/0x1f
[ 3663.634780] Code: 00 44 89 e7 e8 b9 f8 f4 ff 41 f6 c4 10 74 18 31 d2 be 8d 0a 00 00 48 c7 c7 50 d9 a8 81 e8 70 6a f2 ff e8 db dd 5f 00 48 8b 45 c8 <48> 83 78 08 00 0f 84 b5 01 00 00 48 83 c0 08 44 89 75 c0 4d 89
[ 3663.657032] RIP  [<ffffffff81172219>] __alloc_pages_nodemask+0xb9/0x2d0
[ 3663.664491]  RSP <ffff880845fbbcd0>
[ 3663.668429] CR2: 0000000000001f08
[ 3663.672659] ---[ end trace df13f08ed9de18ad ]---

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/x86/kernel/acpi/boot.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index b436fc735aa4..2451cf0008d2 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -707,6 +707,11 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 
 	nid = acpi_get_node(handle);
 	if (nid != -1) {
+		if (try_online_node(nid)) {
+			pr_warn("failed to online node%d for CPU%d, use node%d instead.\n",
+				nid, cpu, first_node(node_online_map));
+			nid = first_node(node_online_map);
+		}
 		set_apicid_to_node(physid, nid);
 		numa_set_node(cpu, nid);
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
