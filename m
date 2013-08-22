Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 109816B0033
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 23:58:26 -0400 (EDT)
Message-ID: <52158C49.2040009@huawei.com>
Date: Thu, 22 Aug 2013 11:58:01 +0800
From: Libin <huawei.libin@huawei.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT]kernel panic with kmemcheck config
References: <5212D7F2.3020308@huawei.com> <521381A9.4020501@intel.com> <521429D5.8070003@huawei.com> <5214461D.9000009@intel.com>
In-Reply-To: <5214461D.9000009@intel.com>
Content-Type: text/plain; charset="gb18030"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, guohanjun@huawei.com, zhangdianfang@huawei.com

On 2013/8/21 12:46, Dave Hansen wrote:
> On 08/20/2013 07:45 PM, Libin wrote:
>> [    3.158023] ------------[ cut here ]------------
>> [    3.162626] WARNING: CPU: 0 PID: 1 at arch/x86/mm/kmemcheck/kmemcheck.c:634 kmemcheck_fault+0xb1/0xc0()
> ...
>> [    3.314877]  [<ffffffff81046aa7>] ? kmemcheck_trap+0x17/0x30
>> [    3.320507]  <<EOE>>  <#DB>  [<ffffffff8150de8a>] do_debug+0x16a/0x1c0
>> [    3.327029]  [<ffffffff8150d815>] debug+0x25/0x40
>> [    3.331714]  [<ffffffff812776cc>] ? rb_insert_color+0xcc/0x150
>> [    3.337518]  <<EOE>>  [<ffffffff811eefd8>] sysfs_link_sibling+0xa8/0xf0
>> [    3.344124]  [<ffffffff811ef46a>] ? __sysfs_add_one+0x6a/0x120
>> [    3.349931]  [<ffffffff811ef477>] __sysfs_add_one+0x77/0x120
>> [    3.355563]  [<ffffffff811ef546>] sysfs_add_one+0x26/0xe0
>> [    3.360937]  [<ffffffff811f007c>] create_dir+0x7c/0xd0
>> [    3.366050]  [<ffffffff811f0163>] sysfs_create_dir+0x93/0xd0
>> [    3.371684]  [<ffffffff81274249>] kobject_add_internal+0xe9/0x270
>> [    3.377748]  [<ffffffff81274598>] kobject_add_varg+0x38/0x60
>> [    3.383380]  [<ffffffff8127464e>] ? kobject_add+0x1e/0x70
>> [    3.388751]  [<ffffffff81274674>] kobject_add+0x44/0x70
>> [    3.393954]  [<ffffffff81364f72>] ? device_add+0xc2/0x580
>> [    3.399328]  [<ffffffff81364f83>] device_add+0xd3/0x580
>> [    3.404529]  [<ffffffff8136455b>] ? device_initialize+0xab/0xc0
>> [    3.410422]  [<ffffffff81365449>] device_register+0x19/0x20
>> [    3.415971]  [<ffffffff8137abeb>] init_memory_block+0xfb/0x120
>> [    3.421776]  [<ffffffff8137aebc>] add_memory_section+0xdc/0x140
>> [    3.427672]  [<ffffffff81b33274>] memory_dev_init+0xa3/0xc1
>> [    3.433264]  [<ffffffff81b32eef>] driver_init+0x2f/0x31
>> [    3.438466]  [<ffffffff81aee7ed>] do_basic_setup+0x29/0xce
>> [    3.443929]  [<ffffffff81b0ffd5>] ? sched_init_smp+0x14f/0x156
>> [    3.449735]  [<ffffffff81aeea9f>] kernel_init_freeable+0x20d/0x291
>> [    3.455886]  [<ffffffff81501330>] ? rest_init+0x80/0x80
>> [    3.461084]  [<ffffffff81501339>] kernel_init+0x9/0x180
>> [    3.466285]  [<ffffffff8151562c>] ret_from_fork+0x7c/0xb0
>> [    3.471659]  [<ffffffff81501330>] ? rest_init+0x80/0x80
>> [    3.476865] ---[ end trace bae4d98dd36296b7 ]---
> 
> So it's a kmemcheck trap while poking sysfs in the middle of the memory
> kobjects getting created.  This code gets run at boot on a *LOT* of
> systems, so it's probably something specific to your hardware.  I'd

I test it on IBM System x3850 X5 platform, and also trigger oops in boot
process. But if don't config the kmemcheck, it can boot up normally.
Hardware information and oops information as following:

[    0.205976] BUG: unable to handle kernel paging request at 000000103f8ae420
[    0.249553] IP: [<000000007e372522>] 0x7e372521
[    0.278328] PGD 1e90067 PUD 406ff91067 PMD 406fd94067 PTE 800000103f8ae962
[    0.321462] Oops: 0000 [#1] SMP
[    0.342366] Modules linked in:
[    0.362173] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.0-rc6-kmemcheck #3
[    0.406711] Hardware name: IBM System x3850 X5 -[7143O3G]-/Node 1, Processor Card, BIOS -[G0E171AUS-1.71]- 09/23/2011
[    0.473627] task: ffffffff81a11420 ti: ffffffff81a00000 task.ti: ffffffff81a00000
[    0.521570] RIP: 0010:[<000000007e372522>]  [<000000007e372522>] 0x7e372521
[    0.565103] RSP: 0000:ffffffff81a01e18  EFLAGS: 00010002
[    0.598574] RAX: 000000007eb6ce18 RBX: 000000007eb6cda0 RCX: 000000103f8ae400
[    0.643109] RDX: 000000007e371b78 RSI: 000000007e372290 RDI: 0000000060000202
[    0.687644] RBP: ffffffff81a01f78 R08: 0000000000000000 R09: 0000000000000015
[    0.732182] R10: 0000000000000030 R11: 8000000000000000 R12: 000077ff80000000
[    0.776720] R13: 0000000000000030 R14: ffff8810bf8ae400 R15: 0000000000000015
[    0.821258] FS:  0000000000000000(0000) GS:ffff88103fc00000(0000) knlGS:0000000000000000
[    0.872889] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.908993] CR2: ffff88103f886d70 CR3: 0000000001a0c000 CR4: 00000000000006b0
[    0.953528] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    0.998064] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
[    1.042598] Stack:
[    1.056043]  000000007e371a9f 0000000000000030 ffff8810bf8ae400 0000000000000015
[    1.103638]  ffffffff81a01e48 ffffffff815112d9 000000007e372604 ffffffff8150daf2
[    1.151236]  0000000000000015 ffff8810bf8ae400 0000000000000030 0000000000000001
[    1.198824] Call Trace:
[    1.214912]  [<ffffffff815112d9>] ? do_page_fault+0x9/0x10
[    1.249439]  [<ffffffff8150daf2>] ? page_fault+0x22/0x30
[    1.282913]  [<ffffffff81049b46>] ? efi_call4+0x46/0x80
[    1.315859]  [<ffffffff81b0add8>] ? efi_enter_virtual_mode+0x105/0x3f2
[    1.356711]  [<ffffffff81af0128>] start_kernel+0x39f/0x430
[    1.391235]  [<ffffffff81aefb7b>] ? repair_env_string+0x58/0x58
[    1.428397]  [<ffffffff81aef4d8>] x86_64_start_reservations+0x1b/0x35
[    1.468721]  [<ffffffff81aef652>] x86_64_start_kernel+0x160/0x167
[    1.506934] Code:  Bad RIP value.
[    1.528367] RIP  [<000000007e372522>] 0x7e372521
[    1.557667]  RSP <ffffffff81a01e18>
[    1.580072] CR2: 000000103f8ae420
[    1.601429] ---[ end trace 26e748e9242ceebc ]---
[    1.630684] Kernel panic - not syncing: Attempted to kill the idle task!


--------------------
Hardware information
--------------------
Summary:	IBM System x3850 X5, 1 x Xeon E7- 4820 2.00GHz, 252GB / 256GB 1333MHz
System:		IBM System x3850 X5
Processors:	1 (of 4) x Xeon E7- 4820 2.00GHz 5866MHz FSB (HT enabled, 10 cores, 64/70 threads)
Memory:		252GB / 256GB 1333MHz == 32 x 8GB, 32 x empty
Disk:		sda (megaraid_sas0): 299GB (99%) JBOD == 1 x ServeRAID-M5015
Disk-Control:	ata_piix0:
Disk-Control:	ata_piix0: Intel 82801JI (ICH10 Family) 4 port SATA IDE Controller #1
Disk-Control:	megaraid_sas0: LSI Logic / Symbios Logic LSI MegaSAS 9260
Chipset:	Intel 82801JIB (ICH10)
Network:	eth0 (bnx2): Broadcom NetXtreme II BCM5709 Gigabit, 5c:f3:fc:db:08:c8, 1000Mb/s <full-duplex>
Network:	eth1 (bnx2): Broadcom NetXtreme II BCM5709 Gigabit, 5c:f3:fc:db:08:ca, 1000Mb/s <full-duplex>
Network:	usb0 (cdc_ether): 5e:f3:fd:36:08:7b, no carrier
OS:		Linux 2.6.32.12-0.7-default x86_64, 64-bit
BIOS:		IBM_Corp. G0E171AUS-1.71 09/23/2011

> suspect something like a memory section getting added twice, or a bug in
> some error handling path.
> 
> You might want to double-check that all the calls to
> add_memory_section() look sane.  It's also a bummer that kmemcheck
> doesn't dump out the actual faulting address.
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
