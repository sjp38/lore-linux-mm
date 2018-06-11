Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDC26B0003
	for <linux-mm@kvack.org>; Sun, 10 Jun 2018 23:24:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j14-v6so10155794wrq.4
        for <linux-mm@kvack.org>; Sun, 10 Jun 2018 20:24:09 -0700 (PDT)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id y31-v6si39682601wrb.46.2018.06.10.20.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jun 2018 20:24:07 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
References: <1527768879-88161-1-git-send-email-xiexiuqi@huawei.com>
 <1527768879-88161-2-git-send-email-xiexiuqi@huawei.com>
 <20180606154516.GL6631@arm.com>
 <CAErSpo6S0qtR42tjGZrFu4aMFFyThx1hkHTSowTt6t3XerpHnA@mail.gmail.com>
 <20180607105514.GA13139@dhcp22.suse.cz>
 <5ed798a0-6c9c-086e-e5e8-906f593ca33e@huawei.com>
 <20180607122152.GP32433@dhcp22.suse.cz>
From: Xie XiuQi <xiexiuqi@huawei.com>
Message-ID: <a880df29-b656-d98d-3037-b04761c7ed78@huawei.com>
Date: Mon, 11 Jun 2018 11:23:18 +0800
MIME-Version: 1.0
In-Reply-To: <20180607122152.GP32433@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Hanjun Guo <guohanjun@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, wanghuiqiang@huawei.com, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, zhongjiang <zhongjiang@huawei.com>

Hi Michal,

On 2018/6/7 20:21, Michal Hocko wrote:
> On Thu 07-06-18 19:55:53, Hanjun Guo wrote:
>> On 2018/6/7 18:55, Michal Hocko wrote:
> [...]
>>> I am not sure I have the full context but pci_acpi_scan_root calls
>>> kzalloc_node(sizeof(*info), GFP_KERNEL, node)
>>> and that should fall back to whatever node that is online. Offline node
>>> shouldn't keep any pages behind. So there must be something else going
>>> on here and the patch is not the right way to handle it. What does
>>> faddr2line __alloc_pages_nodemask+0xf0 tells on this kernel?
>>
>> The whole context is:
>>
>> The system is booted with a NUMA node has no memory attaching to it
>> (memory-less NUMA node), also with NR_CPUS less than CPUs presented
>> in MADT, so CPUs on this memory-less node are not brought up, and
>> this NUMA node will not be online (but SRAT presents this NUMA node);
>>
>> Devices attaching to this NUMA node such as PCI host bridge still
>> return the valid NUMA node via _PXM, but actually that valid NUMA node
>> is not online which lead to this issue.
> 
> But we should have other numa nodes on the zonelists so the allocator
> should fall back to other node. If the zonelist is not intiailized
> properly, though, then this can indeed show up as a problem. Knowing
> which exact place has blown up would help get a better picture...
> 

I specific a non-exist node to allocate memory using kzalloc_node,
and got this following error message.

And I found out there is just a VM_WARN, but it does not prevent the memory
allocation continue.

This nid would be use to access NODE_DADA(nid), so if nid is invalid,
it would cause oops here.

459 /*
460  * Allocate pages, preferring the node given as nid. The node must be valid and
461  * online. For more general interface, see alloc_pages_node().
462  */
463 static inline struct page *
464 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
465 {
466         VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
467         VM_WARN_ON(!node_online(nid));
468
469         return __alloc_pages(gfp_mask, order, nid);
470 }
471

(I wrote a ko, to allocate memory on a non-exist node using kzalloc_node().)

[  120.061693] WARNING: CPU: 6 PID: 3966 at ./include/linux/gfp.h:467 allocate_slab+0x5fd/0x7e0
[  120.070095] Modules linked in: bench(OE+) nls_utf8 isofs loop xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack libcrc32c ipt_REJECT nf_reject_ipv4 tun bridge stp llc ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter dm_mirror dm_region_hash dm_log dm_mod intel_rapl skx_edac nfit vfat libnvdimm fat x86_pkg_temp_thermal coretemp kvm_intel kvm irqbypass iTCO_wdt crct10dif_pclmul iTCO_vendor_support crc32_pclmul ghash_clmulni_intel ses pcbc enclosure aesni_intel scsi_transport_sas crypto_simd cryptd sg glue_helper ipmi_si joydev mei_me i2c_i801 ipmi_devintf ioatdma shpchp pcspkr ipmi_msghandler mei dca i2c_core lpc_ich acpi_power_meter nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables
[  120.140992]  ext4 mbcache jbd2 sd_mod crc32c_intel i40e ahci libahci megaraid_sas libata
[  120.149053] CPU: 6 PID: 3966 Comm: insmod Tainted: G           OE     4.17.0-rc2-RHEL74+ #5
[  120.157369] Hardware name: Huawei 2288H V5/BC11SPSCB0, BIOS 0.62 03/26/2018
[  120.164303] RIP: 0010:allocate_slab+0x5fd/0x7e0
[  120.168817] RSP: 0018:ffff881196947af0 EFLAGS: 00010246
[  120.174022] RAX: 0000000000000000 RBX: 00000000014012c0 RCX: ffffffffb4bc8173
[  120.181126] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff8817aefa7868
[  120.188233] RBP: 00000000014000c0 R08: ffffed02f5df4f0e R09: ffffed02f5df4f0e
[  120.195338] R10: ffffed02f5df4f0d R11: ffff8817aefa786f R12: 0000000000000055
[  120.202444] R13: 0000000000000003 R14: ffff880107c0f800 R15: 0000000000000000
[  120.209550] FS:  00007f6935d8c740(0000) GS:ffff8817aef80000(0000) knlGS:0000000000000000
[  120.217606] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  120.223330] CR2: 0000000000c21b88 CR3: 0000001197fd0006 CR4: 00000000007606e0
[  120.230435] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  120.237541] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  120.244646] PKRU: 55555554
[  120.247346] Call Trace:
[  120.249791]  ? __kasan_slab_free+0xff/0x150
[  120.253960]  ? mpidr_init+0x20/0x30 [bench]
[  120.258129]  new_slab+0x3d/0x90
[  120.261262]  ___slab_alloc+0x371/0x640
[  120.265002]  ? __wake_up_common+0x8a/0x150
[  120.269085]  ? mpidr_init+0x20/0x30 [bench]
[  120.273254]  ? mpidr_init+0x20/0x30 [bench]
[  120.277423]  __slab_alloc+0x40/0x66
[  120.280901]  kmem_cache_alloc_node_trace+0xbc/0x270
[  120.285762]  ? mpidr_init+0x20/0x30 [bench]
[  120.289931]  ? 0xffffffffc0740000
[  120.293236]  mpidr_init+0x20/0x30 [bench]
[  120.297236]  do_one_initcall+0x4b/0x1f5
[  120.301062]  ? do_init_module+0x22/0x233
[  120.304972]  ? kmem_cache_alloc_trace+0xfe/0x220
[  120.309571]  ? do_init_module+0x22/0x233
[  120.313481]  do_init_module+0x77/0x233
[  120.317218]  load_module+0x21ea/0x2960
[  120.320955]  ? m_show+0x1d0/0x1d0
[  120.324264]  ? security_capable+0x39/0x50
[  120.328261]  __do_sys_finit_module+0x94/0xe0
[  120.332516]  do_syscall_64+0x55/0x180
[  120.336171]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  120.341203] RIP: 0033:0x7f69352627f9
[  120.344767] RSP: 002b:00007ffd7d73f718 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[  120.352305] RAX: ffffffffffffffda RBX: 0000000000c201d0 RCX: 00007f69352627f9
[  120.359411] RDX: 0000000000000000 RSI: 000000000041a2d8 RDI: 0000000000000003
[  120.366517] RBP: 000000000041a2d8 R08: 0000000000000000 R09: 00007ffd7d73f8b8
[  120.373622] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[  120.380727] R13: 0000000000c20130 R14: 0000000000000000 R15: 0000000000000000
[  120.387833] Code: 4b e8 ac 97 eb ff e9 e1 fc ff ff 89 de 89 ef e8 7a 35 ff ff 49 89 c7 4d 85 ff 74 71 0f 1f 44 00 00 e9 f1 fa ff ff e8 cf 54 00 00 <0f> 0b 90 e9 c4 fa ff ff 45 89 e8 b9 b1 05 00 00 48 c7 c2 10 79
[  120.406620] ---[ end trace 89f801c36550734e ]---
[  120.411234] BUG: unable to handle kernel paging request at 0000000000002088
[  120.418168] PGD 8000001197c75067 P4D 8000001197c75067 PUD 119858f067 PMD 0
[  120.425103] Oops: 0000 [#1] SMP KASAN PTI
[  120.429097] Modules linked in: bench(OE+) nls_utf8 isofs loop xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack libcrc32c ipt_REJECT nf_reject_ipv4 tun bridge stp llc ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter dm_mirror dm_region_hash dm_log dm_mod intel_rapl skx_edac nfit vfat libnvdimm fat x86_pkg_temp_thermal coretemp kvm_intel kvm irqbypass iTCO_wdt crct10dif_pclmul iTCO_vendor_support crc32_pclmul ghash_clmulni_intel ses pcbc enclosure aesni_intel scsi_transport_sas crypto_simd cryptd sg glue_helper ipmi_si joydev mei_me i2c_i801 ipmi_devintf ioatdma shpchp pcspkr ipmi_msghandler mei dca i2c_core lpc_ich acpi_power_meter nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables
[  120.499986]  ext4 mbcache jbd2 sd_mod crc32c_intel i40e ahci libahci megaraid_sas libata
[  120.508045] CPU: 6 PID: 3966 Comm: insmod Tainted: G        W  OE     4.17.0-rc2-RHEL74+ #5
[  120.516359] Hardware name: Huawei 2288H V5/BC11SPSCB0, BIOS 0.62 03/26/2018
[  120.523296] RIP: 0010:__alloc_pages_nodemask+0x10d/0x2c0
[  120.528586] RSP: 0018:ffff881196947a90 EFLAGS: 00010246
[  120.533790] RAX: 0000000000000001 RBX: 00000000014012c0 RCX: 0000000000000000
[  120.540895] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 0000000000002080
[  120.548000] RBP: 00000000014012c0 R08: ffffed0233ccb8f4 R09: ffffed0233ccb8f4
[  120.555105] R10: ffffed0233ccb8f3 R11: ffff88119e65c79f R12: 0000000000000000
[  120.562210] R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000000
[  120.569316] FS:  00007f6935d8c740(0000) GS:ffff8817aef80000(0000) knlGS:0000000000000000
[  120.577374] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  120.583095] CR2: 0000000000002088 CR3: 0000001197fd0006 CR4: 00000000007606e0
[  120.590200] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  120.597307] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  120.604412] PKRU: 55555554
[  120.607111] Call Trace:
[  120.609554]  allocate_slab+0xd8/0x7e0
[  120.613205]  ? __kasan_slab_free+0xff/0x150
[  120.617376]  ? mpidr_init+0x20/0x30 [bench]
[  120.621545]  new_slab+0x3d/0x90
[  120.624678]  ___slab_alloc+0x371/0x640
[  120.628415]  ? __wake_up_common+0x8a/0x150
[  120.632498]  ? mpidr_init+0x20/0x30 [bench]
[  120.636667]  ? mpidr_init+0x20/0x30 [bench]
[  120.640836]  __slab_alloc+0x40/0x66
[  120.644315]  kmem_cache_alloc_node_trace+0xbc/0x270
[  120.649175]  ? mpidr_init+0x20/0x30 [bench]
[  120.653343]  ? 0xffffffffc0740000
[  120.656649]  mpidr_init+0x20/0x30 [bench]
[  120.660645]  do_one_initcall+0x4b/0x1f5
[  120.664469]  ? do_init_module+0x22/0x233
[  120.668379]  ? kmem_cache_alloc_trace+0xfe/0x220
[  120.672978]  ? do_init_module+0x22/0x233
[  120.676887]  do_init_module+0x77/0x233
[  120.680624]  load_module+0x21ea/0x2960
[  120.684360]  ? m_show+0x1d0/0x1d0
[  120.687667]  ? security_capable+0x39/0x50
[  120.691663]  __do_sys_finit_module+0x94/0xe0
[  120.695920]  do_syscall_64+0x55/0x180
[  120.699571]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  120.704603] RIP: 0033:0x7f69352627f9
[  120.708166] RSP: 002b:00007ffd7d73f718 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[  120.715704] RAX: ffffffffffffffda RBX: 0000000000c201d0 RCX: 00007f69352627f9
[  120.722808] RDX: 0000000000000000 RSI: 000000000041a2d8 RDI: 0000000000000003
[  120.729913] RBP: 000000000041a2d8 R08: 0000000000000000 R09: 00007ffd7d73f8b8
[  120.737019] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[  120.744123] R13: 0000000000c20130 R14: 0000000000000000 R15: 0000000000000000
[  120.751230] Code: 89 c6 74 0d e8 55 ab 5e 00 8b 74 24 1c 48 8b 3c 24 48 8b 54 24 08 89 d9 c1 e9 17 83 e1 01 48 85 d2 88 4c 24 20 0f 85 25 01 00 00 <3b> 77 08 0f 82 1c 01 00 00 48 89 f8 44 89 ea 48 89 e1 44 89 e6
[  120.770020] RIP: __alloc_pages_nodemask+0x10d/0x2c0 RSP: ffff881196947a90
[  120.776780] CR2: 0000000000002088
[  120.780116] ---[ end trace 89f801c36550734f ]---
[  120.978922] Kernel panic - not syncing: Fatal exception
[  120.984186] Kernel Offset: 0x33800000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[  121.209501] ---[ end Kernel panic - not syncing: Fatal exception ]---



-- 
Thanks,
Xie XiuQi
