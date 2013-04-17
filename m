Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 818CB6B003B
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 20:36:32 -0400 (EDT)
Received: by mail-da0-f51.google.com with SMTP id g27so492941dan.10
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 17:36:31 -0700 (PDT)
Date: Tue, 16 Apr 2013 17:36:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug fix PATCH v3] Reusing a resource structure allocated by
 bootmem
In-Reply-To: <516DEC34.7040008@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1304161733340.14583@chino.kir.corp.google.com>
References: <516DEC34.7040008@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, toshi.kani@hp.com, linuxram@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Apr 2013, Yasuaki Ishimatsu wrote:

> When hot removing memory presented at boot time, following messages are shown:
> 
> [  296.867031] ------------[ cut here ]------------
> [  296.922273] kernel BUG at mm/slub.c:3409!
> [  296.970229] invalid opcode: 0000 [#1] SMP
> [  297.019453] Modules linked in: ebtable_nat ebtables xt_CHECKSUM iptable_mangle bridge stp llc ipmi_devintf ipmi_msghandler sunrpc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables binfmt_misc vfat fat dm_mirror dm_region_hash dm_log dm_mod vhost_net macvtap macvlan tun uinput iTCO_wdt iTCO_vendor_support coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode pcspkr sg i2c_i801 lpc_ich mfd_core igb i2c_algo_bit i2c_core e1000e ptp pps_core tpm_infineon ioatdma dca sr_mod cdrom sd_mod crc_t10dif usb_storage megaraid_sas lpfc scsi_transport_fc scsi_tgt scsi_mod
> [  297.747808] CPU 0
> [  297.769764] Pid: 5091, comm: kworker/0:2 Tainted: G        W    3.9.0-rc6+ #15
> [  297.897917] RIP: 0010:[<ffffffff811c41d2>]  [<ffffffff811c41d2>] kfree+0x232/0x240
> [  297.988634] RSP: 0018:ffff88084678d968  EFLAGS: 00010246
> [  298.052196] RAX: 0060000000000400 RBX: ffff8987fffffea0 RCX: 0000000000000000
> [  298.137595] RDX: ffffffff8107a5ae RSI: 0000000000000001 RDI: ffff8987fffffea0
> [  298.222994] RBP: ffff88084678d998 R08: 0000000080000200 R09: 0000000000000001
> [  298.308390] R10: 0000000000000000 R11: 0000000000000000 R12: 0000030000000000
> [  298.393792] R13: ffffea061fffffc0 R14: 00000303ffffffff R15: 0000000000000080
> [  298.479190] FS:  0000000000000000(0000) GS:ffff88085aa00000(0000) knlGS:0000000000000000
> [  298.576030] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  298.644791] CR2: 00000000025d3f78 CR3: 0000000001c0c000 CR4: 00000000001407f0
> [  298.730192] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  298.815590] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  298.900997] Process kworker/0:2 (pid: 5091, threadinfo ffff88084678c000, task ffff88083928ca80)
> [  299.005121] Stack:
> [  299.029156]  00000303ffffffff ffff8987fffffea0 0000030000000000 ffff8987fffffe90
> [  299.118116]  00000303ffffffff 0000000000000080 ffff88084678d9c8 ffffffff8107a5d4
> [  299.207084]  0000000030000000 ffff8987fffb2680 0000000000000080 0000000030000000
> [  299.296045] Call Trace:
> [  299.325288]  [<ffffffff8107a5d4>] __release_region+0xd4/0xe0
> [  299.393020]  [<ffffffff811c96f2>] __remove_pages+0x52/0x110
> [  299.459707]  [<ffffffff816ada89>] arch_remove_memory+0x89/0xd0
> [  299.529505]  [<ffffffff816aec94>] remove_memory+0xc4/0x100
> [  299.595145]  [<ffffffff814103c5>] acpi_memory_device_remove+0x6d/0xb1
> [  299.672230]  [<ffffffff813cbfe3>] acpi_device_remove+0x89/0xab
> [  299.742033]  [<ffffffff81479f4c>] __device_release_driver+0x7c/0xf0
> [  299.817048]  [<ffffffff8147a0cf>] device_release_driver+0x2f/0x50
> [  299.889972]  [<ffffffff813cce98>] acpi_bus_device_detach+0x6c/0x70
> [  299.963938]  [<ffffffff813f80f6>] acpi_ns_walk_namespace+0x11a/0x250
> [  300.039982]  [<ffffffff813cce2c>] ? power_state_show+0x36/0x36
> [  300.109800]  [<ffffffff813cce2c>] ? power_state_show+0x36/0x36
> [  300.179612]  [<ffffffff813f874d>] acpi_walk_namespace+0xee/0x137
> [  300.251492]  [<ffffffff813ccecf>] acpi_bus_trim+0x33/0x7a
> [  300.316089]  [<ffffffff816c182a>] ? mutex_lock_nested+0x4a/0x60
> [  300.386927]  [<ffffffff813cdca6>] acpi_bus_hot_remove_device+0xc4/0x1a1
> [  300.466096]  [<ffffffff813c8009>] acpi_os_execute_deferred+0x27/0x34
> [  300.542137]  [<ffffffff81093467>] process_one_work+0x1f7/0x590
> [  300.611940]  [<ffffffff810933f5>] ? process_one_work+0x185/0x590
> [  300.683823]  [<ffffffff81094bba>] worker_thread+0x11a/0x370
> [  300.750502]  [<ffffffff81094aa0>] ? manage_workers+0x180/0x180
> [  300.820308]  [<ffffffff8109adfe>] kthread+0xee/0x100
> [  300.879714]  [<ffffffff810e139b>] ? __lock_release+0x12b/0x190
> [  300.949512]  [<ffffffff8109ad10>] ? __init_kthread_worker+0x70/0x70
> [  301.024517]  [<ffffffff816cf32c>] ret_from_fork+0x7c/0xb0
> [  301.089135]  [<ffffffff8109ad10>] ? __init_kthread_worker+0x70/0x70
> [  301.164138] Code: 89 ef e8 c2 2c fb ff e9 0b ff ff ff 4d 8b 6d 30 e9 5c fe ff ff 4c 89 f1 48 89 da 4c 89 ee 4c 89 e7 e8 03 f9 ff ff e9 ec fe ff ff <0f> 0b eb fe 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 48 83 ec
> [  301.397214] RIP  [<ffffffff811c41d2>] kfree+0x232/0x240
> [  301.459855]  RSP <ffff88084678d968>
> [  301.501675] ---[ end trace 8679967aa8606ed8 ]---
> 
> The reason why the messages are shown is to release a resource structure,
> allocated by bootmem, by kfree(). So when we release a resource structure,
> we should check whether it is allocated by bootmem or not.
> 
> But even if we know a resource structure is allocated by bootmem, we cannot
> release it since SLxB cannot treat it. So for reusing a resource structure,
> this patch remembers it by using bootmem_resource as follows:
> 
> When releasing a resource structure by free_resource(), free_resource() checks
> whether the resource structure is allocated by bootmem or not. If it is
> allocated by bootmem, free_resource() adds it to bootmem_resource. If it is
> not allocated by bootmem, free_resource() release it by kfree().
> 
> And when getting a new resource structure by get_resource(), get_resource()
> checks whether bootmem_resource has released resource structures or not. If
> there is a released resource structure, get_resource() returns it. If there is
> not a releaed resource structure, get_resource() returns new resource structure
> allocated by kzalloc().
> 

I think this is _way_ too complex and could be done without leaking memory 
that you may never allocate again through get_resource().

Why not simply do what generic sparsemem support does by testing 
PageSlab(virt_to_head_page(res)) and calling kfree() if true and freeing 
back to bootmem if false?  This should be like a five line patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
