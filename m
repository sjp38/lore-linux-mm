Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6D956B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:36:55 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id u10so11438755otc.21
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:36:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 189sor5515303oii.149.2017.12.19.12.36.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 12:36:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-1-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Dec 2017 12:36:53 -0800
Message-ID: <CAPcyv4hLncPScEYoU2JA3B0C-jEve03it_-JbDJb1cpeP5pyMA@mail.gmail.com>
Subject: Re: revamp vmem_altmap / dev_pagemap handling V2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
>
> Hi all,
>
> this series started with two patches from Logan that now are in the
> middle of the series to kill the memremap-internal pgmap structure
> and to redo the dev_memreamp_pages interface to be better suitable
> for future PCI P2P uses.  I reviewed them and noticed that there
> isn't really any good reason to keep struct vmem_altmap either,
> and that a lot of these alternative device page map access should
> be better abstracted out instead of being sprinkled all over the
> mm code.  But when we got the RCU warnings in V1 I went for yet
> another approach, and now struct vmem_altmap is kept for now,
> but passed explicitly through the memory hotplug code instead of
> having to do unprotected lookups through the radix tree.  The
> end result is that only the get_user_pages path ever looks up
> struct dev_pagemap, and struct vmem_altmap is now always embedded
> into struct dev_pagemap, and explicitly passed where needed.
>
> Please review carefully, this has only been tested with my legacy
> e820 NVDIMM system.

I hit the following regression in the error path with these patches
applied. I'm working on a bisect and updating the unit tests to
capture this scenario. 4.15-rc2 works as expected.

[   47.102064] ------------[ cut here ]------------
[   47.103099] dax_pmem dax1.0: devm_memremap_pages_release: failed to
free all reserved pages
[   47.104773] WARNING: CPU: 6 PID: 1226 at kernel/memremap.c:306
devm_memremap_pages_release+0x399/0x3e0
[   47.106578] Modules linked in: ip6t_rpfilter ip6t_REJECT
nf_reject_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip
6table_mangle ip6table_raw ip6table_security iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
iptable_mangle iptable_raw iptable_security ebtable_filter ebtables
ip6table_filter ip6_tables crct10dif_pclmul crc32_pclmul crc32c_intel
ghash_clmulni_intel dax_pmem(O) nd_pmem(O) device_dax(O) nd_btt(O)
nd_e820(O) nfit(O) serio_raw libnvdimm(O) nfit_test_i
omap(O)
[   47.114722] CPU: 6 PID: 1226 Comm: ndctl Tainted: G           O
4.15.0-rc2+ #981
[   47.116082] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   47.117993] task: 00000000f9fb534d task.stack: 00000000575f2a25
[   47.119004] RIP: 0010:devm_memremap_pages_release+0x399/0x3e0
[   47.119993] RSP: 0018:ffffc90002f2fd30 EFLAGS: 00010282
[   47.120909] RAX: 0000000000000000 RBX: ffff88043715fa80 RCX: 0000000000000000
[   47.122095] RDX: ffff8801f88d6900 RSI: ffff8801f88ce478 RDI: ffff8801f88ce478
[   47.123284] RBP: ffffc90002f2fd50 R08: 0000000000000000 R09: 0000000000000000
[   47.124466] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8801f1fd2d10
[   47.125648] R13: 0000000440000000 R14: ffff8801f4dc8018 R15: ffffffff81ed6dfe
[   47.126831] FS:  00007fd93f2ba840(0000) GS:ffff8801f88c0000(0000)
knlGS:0000000000000000
[   47.128233] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   47.129216] CR2: 000055fa3e090fc0 CR3: 00000001f3dce000 CR4: 00000000000406e0
[   47.130404] Call Trace:
[   47.130913]  release_nodes+0x160/0x2a0
[   47.131617]  driver_probe_device+0xf9/0x490
[   47.132378]  bind_store+0x109/0x160
[   47.133035]  kernfs_fop_write+0x110/0x1b0
[   47.133775]  __vfs_write+0x33/0x170
[   47.134438]  ? rcu_read_lock_sched_held+0x3f/0x70
[   47.135275]  ? rcu_sync_lockdep_assert+0x2a/0x50
[   47.136091]  ? __sb_start_write+0xd0/0x1b0
[   47.136840]  ? vfs_write+0x18b/0x1b0
[   47.137519]  vfs_write+0xc5/0x1b0
[   47.138151]  SyS_write+0x55/0xc0
[   47.138776]  entry_SYSCALL_64_fastpath+0x1f/0x96
[   47.139600] RIP: 0033:0x7fd93e3a8f84
[   47.140270] RSP: 002b:00007ffca9dc0f68 EFLAGS: 00000246 ORIG_RAX:
0000000000000001
[   47.141593] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fd93e3a8f84
[   47.142778] RDX: 0000000000000007 RSI: 0000000001d2de90 RDI: 0000000000000004
[   47.143962] RBP: 00007ffca9dc0fa0 R08: 0000000001d283d0 R09: 00000000fffffff8
[   47.145147] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000407d50
[   47.146330] R13: 00007ffca9dc15a0 R14: 0000000000000000 R15: 0000000000000000
[   47.147520] Code: f9 57 16 01 01 48 85 db 74 55 4c 89 f7 e8 00 21
44 00 48 c7 c1 80 62 c2 81 48 89 da 48 89 c6 48 c7 c7 08 6a ee 81 e8
c7 9f ea ff <0f> ff e9 ce fe ff ff 48 c7 c2 08 cf ec 81 be ed 02 00 00
48 c7
[   47.150607] ---[ end trace f384c72daa2ac9c5 ]---
[   47.151458] dax_pmem dax1.0: dax_pmem_percpu_exit
[   47.152478] dax_pmem: probe of dax1.0 failed with error -12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
