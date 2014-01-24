Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 577866B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 19:28:05 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so2529601pbb.37
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 16:28:05 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id g5si15863813pav.114.2014.01.23.16.28.02
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 16:28:03 -0800 (PST)
Message-ID: <52E1B386.4050500@intel.com>
Date: Thu, 23 Jan 2014 16:27:50 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
References: <52E19C7D.7050603@intel.com>
In-Reply-To: <52E19C7D.7050603@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>Santosh Shilimkar <santosh.shilimkar@ti.com>

I've got a second failure mode, too, also memblock related with the same
system but a different config.  In this one, the memblock code looks to
have returned an address for which there is no virtual mapping.  The PMD
is clear.

> [    0.000000] memblock_find_in_range_node():239
> [    0.000000] __memblock_find_range_top_down():150
> [    0.000000] __memblock_find_range_top_down():152 i: 600000001
> [    0.000000] memblock_find_in_range_node():241 ret: 2147479552
> [    0.000000] memblock_reserve: [0x0000007ffff000-0x0000007ffff03f] flags 0x0 numa_set_distance+0xd2/0x252
> [    0.000000] numa_distance phys: 2147479552
> [    0.000000] numa_distance virt: ffff88007ffff000
> [    0.000000] numa_distance size: 64
> [    0.000000] numa_alloc_distance() accessing numa_distance[] at byte: 0
> [    0.000000] BUG: unable to handle kernel paging request at ffff88007ffff000
> [    0.000000] IP: [<ffffffff81d2c1f1>] numa_set_distance+0x186/0x252
> [    0.000000] PGD 211e067 PUD 2121067 PMD 0 
> [    0.000000] Oops: 0002 [#1] SMP 
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0-slub-04156-g90804ed-dirty #825
> [    0.000000] Hardware name: FUJITSU-SV PRIMEQUEST 1800E2/SB, BIOS PRIMEQUEST 1000 Series BIOS Version 1.24 09/14/2011
> [    0.000000] task: ffffffff81c104a0 ti: ffffffff81c00000 task.ti: ffffffff81c00000
> [    0.000000] RIP: 0010:[<ffffffff81d2c1f1>]  [<ffffffff81d2c1f1>] numa_set_distance+0x186/0x252
> [    0.000000] RSP: 0000:ffffffff81c01cd8  EFLAGS: 00010002
> [    0.000000] RAX: 000000000000000a RBX: 0000000000000000 RCX: 0000000000000000
> [    0.000000] RDX: 0000000000000014 RSI: 0000000000000046 RDI: ffffffff81ea4f84
> [    0.000000] RBP: ffffffff81c01d68 R08: 000000000000100d R09: ffff88007ffff000
> [    0.000000] R10: 0000000000000127 R11: 000000000000000d R12: 0000000000000000
> [    0.000000] R13: 000000000000000a R14: 0000000000000008 R15: 0000000000000001
> [    0.000000] FS:  0000000000000000(0000) GS:ffffffff81d00000(0000) knlGS:0000000000000000
> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.000000] CR2: ffff88007ffff000 CR3: 0000000001c0b000 CR4: 00000000000000b0
> [    0.000000] Stack:
> [    0.000000]  0000000000000000 ffffffff00000000 0000000000000000 0000004081c01dd0
> [    0.000000]  00000000000000ff 0000000000000000 0000000000000000 0000000000000000
> [    0.000000]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff81d2c480>] acpi_numa_slit_init+0x47/0x70
> [    0.000000]  [<ffffffff81d52c34>] ? acpi_table_print_srat_entry+0x26/0x26
> [    0.000000]  [<ffffffff81d52c9c>] acpi_parse_slit+0x68/0x6c
> [    0.000000]  [<ffffffff81d5156c>] acpi_table_parse+0x6c/0x82
> [    0.000000]  [<ffffffff81d52dcc>] acpi_numa_init+0x94/0xb0
> [    0.000000]  [<ffffffff81d2c6d9>] ? acpi_numa_arch_fixup+0x6/0x6
> [    0.000000]  [<ffffffff81d2c6d9>] ? acpi_numa_arch_fixup+0x6/0x6
> [    0.000000]  [<ffffffff81d2c6e2>] x86_acpi_numa_init+0x9/0x1b
> [    0.000000]  [<ffffffff81d2bbc2>] numa_init+0xe0/0x589
> [    0.000000]  [<ffffffff8108adba>] ? set_pte_vaddr_pud+0x3a/0x60
> [    0.000000]  [<ffffffff8108ae45>] ? set_pte_vaddr+0x65/0xa0
> [    0.000000]  [<ffffffff810902d5>] ? __native_set_fixmap+0x25/0x30
> [    0.000000]  [<ffffffff81d2c2d6>] x86_numa_init+0x19/0x2b
> [    0.000000]  [<ffffffff81d2c419>] initmem_init+0x9/0xb
> [    0.000000]  [<ffffffff81d1b2f3>] setup_arch+0x923/0xc6e
> [    0.000000]  [<ffffffff817032e0>] ? printk+0x4d/0x4f
> [    0.000000]  [<ffffffff81d14b1a>] start_kernel+0x85/0x3db
> [    0.000000]  [<ffffffff81d145a8>] x86_64_start_reservations+0x2a/0x2c
> [    0.000000]  [<ffffffff81d1469a>] x86_64_start_kernel+0xf0/0xf7
> [    0.000000] Code: ff ff e8 c6 70 9d ff 8b 4d 80 4c 8b 8d 70 ff ff ff b0 0a 4c 03 0d a8 0a 17 00 ba 14 00 00 00 44 39 f9 0f 45 c2 49 ff c7 45 39 fe <41> 88 01 44 8b 85 78 ff ff ff 7f a0 ff c1 45 01 f0 44 39 f1 7c 
> [    0.000000] RIP  [<ffffffff81d2c1f1>] numa_set_distance+0x186/0x252
> [    0.000000]  RSP <ffffffff81c01cd8>
> [    0.000000] CR2: ffff88007ffff000
> [    0.000000] ---[ end trace 1ac9854e9d9aedf2 ]---
> [    0.000000] Kernel panic - not syncing: Attempted to kill the idle task!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
