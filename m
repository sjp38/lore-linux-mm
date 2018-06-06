Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0CE6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 16:39:49 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id e16-v6so5549778ybq.7
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 13:39:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j64-v6sor6321678ywc.440.2018.06.06.13.39.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 13:39:48 -0700 (PDT)
MIME-Version: 1.0
References: <1527768879-88161-1-git-send-email-xiexiuqi@huawei.com>
 <1527768879-88161-2-git-send-email-xiexiuqi@huawei.com> <20180606154516.GL6631@arm.com>
In-Reply-To: <20180606154516.GL6631@arm.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 6 Jun 2018 15:39:34 -0500
Message-ID: <CAErSpo6S0qtR42tjGZrFu4aMFFyThx1hkHTSowTt6t3XerpHnA@mail.gmail.com>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: xiexiuqi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>, wanghuiqiang@huawei.com, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

[+cc akpm, linux-mm, linux-pci]

On Wed, Jun 6, 2018 at 10:44 AM Will Deacon <will.deacon@arm.com> wrote:
>
> On Thu, May 31, 2018 at 08:14:38PM +0800, Xie XiuQi wrote:
> > A numa system may return node which is not online.
> > For example, a numa node:
> > 1) without memory
> > 2) NR_CPUS is very small, and the cpus on the node are not brought up
> >
> > In this situation, we use NUMA_NO_NODE to avoid oops.
> >
> > [   25.732905] Unable to handle kernel NULL pointer dereference at virtual address 00001988
> > [   25.740982] Mem abort info:
> > [   25.743762]   ESR = 0x96000005
> > [   25.746803]   Exception class = DABT (current EL), IL = 32 bits
> > [   25.752711]   SET = 0, FnV = 0
> > [   25.755751]   EA = 0, S1PTW = 0
> > [   25.758878] Data abort info:
> > [   25.761745]   ISV = 0, ISS = 0x00000005
> > [   25.765568]   CM = 0, WnR = 0
> > [   25.768521] [0000000000001988] user address but active_mm is swapper
> > [   25.774861] Internal error: Oops: 96000005 [#1] SMP
> > [   25.779724] Modules linked in:
> > [   25.782768] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.17.0-rc6-mpam+ #115
> > [   25.789714] Hardware name: Huawei D06/D06, BIOS Hisilicon D06 EC UEFI Nemo 2.0 RC0 - B305 05/28/2018
> > [   25.798831] pstate: 80c00009 (Nzcv daif +PAN +UAO)
> > [   25.803612] pc : __alloc_pages_nodemask+0xf0/0xe70
> > [   25.808389] lr : __alloc_pages_nodemask+0x184/0xe70
> > [   25.813252] sp : ffff00000996f660
> > [   25.816553] x29: ffff00000996f660 x28: 0000000000000000
> > [   25.821852] x27: 00000000014012c0 x26: 0000000000000000
> > [   25.827150] x25: 0000000000000003 x24: ffff000008099eac
> > [   25.832449] x23: 0000000000400000 x22: 0000000000000000
> > [   25.837747] x21: 0000000000000001 x20: 0000000000000000
> > [   25.843045] x19: 0000000000400000 x18: 0000000000010e00
> > [   25.848343] x17: 000000000437f790 x16: 0000000000000020
> > [   25.853641] x15: 0000000000000000 x14: 6549435020524541
> > [   25.858939] x13: 20454d502067756c x12: 0000000000000000
> > [   25.864237] x11: ffff00000996f6f0 x10: 0000000000000006
> > [   25.869536] x9 : 00000000000012a4 x8 : ffff8023c000ff90
> > [   25.874834] x7 : 0000000000000000 x6 : ffff000008d73c08
> > [   25.880132] x5 : 0000000000000000 x4 : 0000000000000081
> > [   25.885430] x3 : 0000000000000000 x2 : 0000000000000000
> > [   25.890728] x1 : 0000000000000001 x0 : 0000000000001980
> > [   25.896027] Process swapper/0 (pid: 1, stack limit = 0x        (ptrval))
> > [   25.902712] Call trace:
> > [   25.905146]  __alloc_pages_nodemask+0xf0/0xe70
> > [   25.909577]  allocate_slab+0x94/0x590
> > [   25.913225]  new_slab+0x68/0xc8
> > [   25.916353]  ___slab_alloc+0x444/0x4f8
> > [   25.920088]  __slab_alloc+0x50/0x68
> > [   25.923562]  kmem_cache_alloc_node_trace+0xe8/0x230
> > [   25.928426]  pci_acpi_scan_root+0x94/0x278
> > [   25.932510]  acpi_pci_root_add+0x228/0x4b0
> > [   25.936593]  acpi_bus_attach+0x10c/0x218
> > [   25.940501]  acpi_bus_attach+0xac/0x218
> > [   25.944323]  acpi_bus_attach+0xac/0x218
> > [   25.948144]  acpi_bus_scan+0x5c/0xc0
> > [   25.951708]  acpi_scan_init+0xf8/0x254
> > [   25.955443]  acpi_init+0x310/0x37c
> > [   25.958831]  do_one_initcall+0x54/0x208
> > [   25.962653]  kernel_init_freeable+0x244/0x340
> > [   25.966999]  kernel_init+0x18/0x118
> > [   25.970474]  ret_from_fork+0x10/0x1c
> > [   25.974036] Code: 7100047f 321902a4 1a950095 b5000602 (b9400803)
> > [   25.980162] ---[ end trace 64f0893eb21ec283 ]---
> > [   25.984765] Kernel panic - not syncing: Fatal exception
> >
> > Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
> > Tested-by: Huiqiang Wang <wanghuiqiang@huawei.com>
> > Cc: Hanjun Guo <hanjun.guo@linaro.org>
> > Cc: Tomasz Nowicki <Tomasz.Nowicki@caviumnetworks.com>
> > Cc: Xishi Qiu <qiuxishi@huawei.com>
> > ---
> >  arch/arm64/kernel/pci.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/arch/arm64/kernel/pci.c b/arch/arm64/kernel/pci.c
> > index 0e2ea1c..e17cc45 100644
> > --- a/arch/arm64/kernel/pci.c
> > +++ b/arch/arm64/kernel/pci.c
> > @@ -170,6 +170,9 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
> >       struct pci_bus *bus, *child;
> >       struct acpi_pci_root_ops *root_ops;
> >
> > +     if (node != NUMA_NO_NODE && !node_online(node))
> > +             node = NUMA_NO_NODE;
> > +
>
> This really feels like a bodge, but it does appear to be what other
> architectures do, so:
>
> Acked-by: Will Deacon <will.deacon@arm.com>

I agree, this doesn't feel like something we should be avoiding in the
caller of kzalloc_node().

I would not expect kzalloc_node() to return memory that's offline, no
matter what node we told it to allocate from.  I could imagine it
returning failure, or returning memory from a node that *is* online,
but returning a pointer to offline memory seems broken.

Are we putting memory that's offline in the free list?  I don't know
where to look to figure this out.

Bjorn
