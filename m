Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A26276B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 14:23:42 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x23-v6so5102126pln.11
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 11:23:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w123-v6si8987653pfb.362.2018.07.06.11.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 11:23:40 -0700 (PDT)
Received: from mail-vk0-f42.google.com (mail-vk0-f42.google.com [209.85.213.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5CBAD20873
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 18:23:40 +0000 (UTC)
Received: by mail-vk0-f42.google.com with SMTP id y9-v6so7324718vky.3
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 11:23:40 -0700 (PDT)
MIME-Version: 1.0
References: <20180702154325.12196-1-osalvador@techadventures.net> <CAGM2reZz3=OM7W_VbCGgnAMumo+AiPaG7sGUaichG_QNngYKsg@mail.gmail.com>
In-Reply-To: <CAGM2reZz3=OM7W_VbCGgnAMumo+AiPaG7sGUaichG_QNngYKsg@mail.gmail.com>
From: Ross Zwisler <zwisler@kernel.org>
Date: Fri, 6 Jul 2018 12:23:28 -0600
Message-ID: <CAOxpaSVkLh23jN_=0GpZ77EhKdAYaiWKkppnxWwf_MRa5FvopA@mail.gmail.com>
Subject: Re: [PATCH] mm/sparse: Make sparse_init_one_section void and remove check
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com, linux-nvdimm@lists.01.org
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, bhe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Mon, Jul 2, 2018 at 12:48 PM Pavel Tatashin
<pasha.tatashin@oracle.com> wrote:
>
> On Mon, Jul 2, 2018 at 11:43 AM <osalvador@techadventures.net> wrote:
> >
> > From: Oscar Salvador <osalvador@suse.de>
> >
> > sparse_init_one_section() is being called from two sites:
> > sparse_init() and sparse_add_one_section().
> > The former calls it from a for_each_present_section_nr() loop,
> > and the latter marks the section as present before calling it.
> > This means that when sparse_init_one_section() gets called, we already know
> > that the section is present.
> > So there is no point to double check that in the function.
> >
> > This removes the check and makes the function void.
> >
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
>
> Thank you Oscar.
>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

It looks like this change breaks "fsdax" mode namespaces in
next-20180705.  The offending commit is:

commit 054620849110 ("mm/sparse.c: make sparse_init_one_section void
and remove check")

Here is the stack trace I get when converting a raw mode namespace to
fsdax mode, and from then on during each reboot as the namespace is
being initialized:

[    6.067166] BUG: unable to handle kernel paging request at ffffea0005000080
[    6.068084] PGD 13ffdd067 P4D 13ffdd067 PUD 13ffdc067 PMD 0
[    6.068771] Oops: 0002 [#1] PREEMPT SMP PTI
[    6.069262] CPU: 11 PID: 180 Comm: kworker/u24:2 Not tainted
4.18.0-rc3-00193-g054620849110 #1
[    6.070440] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS rel-1.11.1-0-g0551a4be2c-prebuilt.qemu-project.org 04/01/2014
[    6.071689] Workqueue: events_unbound async_run_entry_fn
[    6.072261] RIP: 0010:memmap_init_zone+0x154/0x1cf
[    6.072882] Code: 48 89 c3 48 c1 eb 0c e9 82 00 00 00 48 89 da 48
b8 00 00 00 00 00 ea ff ff b9 10 00 00 00 48 c1 e2 06 48 01 c2 31 c0
48 89 d7 <f3> ab 48 b8 ff ff ff ff ff ff 7f 00 48 23 45 c0 c7 42 34 01
00 00
[    6.075396] RSP: 0018:ffffc900024bfa70 EFLAGS: 00010246
[    6.076052] RAX: 0000000000000000 RBX: 0000000000140002 RCX: 0000000000000010
[    6.076845] RDX: ffffea0005000080 RSI: 0000000000000000 RDI: ffffea0005000080
[    6.077604] RBP: ffffc900024bfab0 R08: 0000000000000001 R09: ffff88010eb50d38
[    6.078394] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[    6.079331] R13: 0000000000000004 R14: 0000000000000001 R15: 0000000000000000
[    6.080274] FS:  0000000000000000(0000) GS:ffff880115a00000(0000)
knlGS:0000000000000000
[    6.081337] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    6.082092] CR2: ffffea0005000080 CR3: 0000000002824000 CR4: 00000000000006e0
[    6.083032] Call Trace:
[    6.083371]  move_pfn_range_to_zone+0x168/0x180
[    6.083965]  devm_memremap_pages+0x29b/0x480
[    6.084550]  pmem_attach_disk+0x1ae/0x6c0 [nd_pmem]
[    6.085204]  ? devm_memremap+0x79/0xb0
[    6.085714]  nd_pmem_probe+0x7e/0xa0 [nd_pmem]
[    6.086320]  nvdimm_bus_probe+0x6e/0x160 [libnvdimm]
[    6.086977]  driver_probe_device+0x310/0x480
[    6.087543]  __device_attach_driver+0x86/0x100
[    6.088136]  ? __driver_attach+0x110/0x110
[    6.088681]  bus_for_each_drv+0x6e/0xb0
[    6.089190]  __device_attach+0xe2/0x160
[    6.089705]  device_initial_probe+0x13/0x20
[    6.090266]  bus_probe_device+0xa6/0xc0
[    6.090772]  device_add+0x41b/0x660
[    6.091249]  ? lock_acquire+0xa3/0x210
[    6.091743]  nd_async_device_register+0x12/0x40 [libnvdimm]
[    6.092398]  async_run_entry_fn+0x3e/0x170
[    6.092921]  process_one_work+0x230/0x680
[    6.093455]  worker_thread+0x3f/0x3b0
[    6.093930]  kthread+0x12f/0x150
[    6.094362]  ? process_one_work+0x680/0x680
[    6.094903]  ? kthread_create_worker_on_cpu+0x70/0x70
[    6.095574]  ret_from_fork+0x3a/0x50
[    6.096069] Modules linked in: nd_pmem nd_btt dax_pmem device_dax
nfit libnvdimm
[    6.097179] CR2: ffffea0005000080
[    6.097764] ---[ end trace a5b8bd6a5500b68c ]---

- Ross
