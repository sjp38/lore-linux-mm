Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E30236B02E2
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 14:32:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y29so16031596pff.6
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 11:32:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 133sor4416413pfa.9.2017.09.11.11.32.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 11:32:30 -0700 (PDT)
Date: Mon, 11 Sep 2017 11:32:25 -0700
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170911183225.crtqa5p7tzxft43a@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170907173609.22696-4-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

Hi all,

On Thu, Sep 07, 2017 at 11:36:01AM -0600, Tycho Andersen wrote:
>
> +inline void xpfo_flush_kernel_tlb(struct page *page, int order)
> +{
> +	int level;
> +	unsigned long size, kaddr;
> +
> +	kaddr = (unsigned long)page_address(page);
> +
> +	if (unlikely(!lookup_address(kaddr, &level))) {
> +		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr, level);
> +		return;
> +	}
> +
> +	switch (level) {
> +	case PG_LEVEL_4K:
> +		size = PAGE_SIZE;
> +		break;
> +	case PG_LEVEL_2M:
> +		size = PMD_SIZE;
> +		break;
> +	case PG_LEVEL_1G:
> +		size = PUD_SIZE;
> +		break;
> +	default:
> +		WARN(1, "xpfo: unsupported page level %x\n", level);
> +		return;
> +	}
> +
> +	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);

Marco was testing and got the stack trace below. The issue is that on x86,
flush_tlb_kernel_range uses on_each_cpu, which causes the WARN() below. Since
this is called from xpfo_kmap/unmap in this interrupt handler, the WARN()
triggers.

I'm not sure what to do about this -- based on the discussion in v6 we need to
flush the TLBs for all CPUs -- but we can't do that with interrupts disabled,
which basically means with this we wouldn't be able to map/unmap pages in
interrupts.

Any thoughts?

Tycho

[    2.712912] ------------[ cut here ]------------
[    2.712922] WARNING: CPU: 0 PID: 0 at kernel/smp.c:414
smp_call_function_many+0x9a/0x270
[    2.712923] Modules linked in: sd_mod ata_generic pata_acpi qxl
drm_kms_helper syscopyarea sysfillrect virtio_console sysimgblt
virtio_blk fb_sys_fops ttm drm 8139too ata_piix libata 8139cp
virtio_pci virtio_ring virtio mii crc32c_intel i2c_core serio_raw
floppy dm_mirror dm_region_hash dm_log dm_mod
[    2.712939] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.13.0+ #8
[    2.712940] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.9.3-1.fc25 04/01/2014
[    2.712941] task: ffffffff81c10480 task.stack: ffffffff81c00000
[    2.712943] RIP: 0010:smp_call_function_many+0x9a/0x270
[    2.712944] RSP: 0018:ffff88023fc03b38 EFLAGS: 00010046
[    2.712945] RAX: 0000000000000000 RBX: ffffffff81072a50 RCX: 0000000000000001
[    2.712946] RDX: ffff88023fc03ba8 RSI: ffffffff81072a50 RDI: ffffffff81e22320
[    2.712947] RBP: ffff88023fc03b70 R08: 0000000000000970 R09: 0000000000000063
[    2.712948] R10: ffff880000000970 R11: 0000000000000000 R12: ffff88023fc03ba8
[    2.712949] R13: 0000000000000000 R14: ffff8802332b8e18 R15: ffffffff81e22320
[    2.712950] FS:  0000000000000000(0000) GS:ffff88023fc00000(0000)
knlGS:0000000000000000
[    2.712951] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    2.712951] CR2: 00007fde22f6b000 CR3: 000000022727b000 CR4: 00000000003406f0
[    2.712954] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    2.712955] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[    2.712955] Call Trace:
[    2.712959]  <IRQ>
[    2.712964]  ? x86_configure_nx+0x50/0x50
[    2.712966]  on_each_cpu+0x2d/0x60
[    2.712967]  flush_tlb_kernel_range+0x79/0x80
[    2.712969]  xpfo_flush_kernel_tlb+0xaa/0xe0
[    2.712975]  xpfo_kunmap+0xa8/0xc0
[    2.712981]  swiotlb_bounce+0xd1/0x1c0
[    2.712982]  swiotlb_tbl_unmap_single+0x10f/0x120
[    2.712984]  unmap_single+0x20/0x30
[    2.712985]  swiotlb_unmap_sg_attrs+0x46/0x70
[    2.712991]  __ata_qc_complete+0xfa/0x150 [libata]
[    2.712994]  ata_qc_complete+0xd2/0x2e0 [libata]
[    2.712998]  ata_hsm_qc_complete+0x6f/0x90 [libata]
[    2.713004]  ata_sff_hsm_move+0xae/0x6b0 [libata]
[    2.713009]  __ata_sff_port_intr+0x8e/0x100 [libata]
[    2.713013]  ata_bmdma_port_intr+0x2f/0xd0 [libata]
[    2.713019]  ata_bmdma_interrupt+0x161/0x1b0 [libata]
[    2.713022]  __handle_irq_event_percpu+0x3c/0x190
[    2.713024]  handle_irq_event_percpu+0x32/0x80
[    2.713026]  handle_irq_event+0x3b/0x60
[    2.713027]  handle_edge_irq+0x8f/0x190
[    2.713029]  handle_irq+0xab/0x120
[    2.713032]  ? _local_bh_enable+0x21/0x30
[    2.713039]  do_IRQ+0x48/0xd0
[    2.713040]  common_interrupt+0x93/0x93
[    2.713042] RIP: 0010:native_safe_halt+0x6/0x10
[    2.713043] RSP: 0018:ffffffff81c03de0 EFLAGS: 00000246 ORIG_RAX:
ffffffffffffffc1
[    2.713044] RAX: 0000000000000000 RBX: ffffffff81c10480 RCX: 0000000000000000
[    2.713045] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[    2.713046] RBP: ffffffff81c03de0 R08: 00000000b656100b R09: 0000000000000000
[    2.713047] R10: 0000000000000006 R11: 0000000000000005 R12: 0000000000000000
[    2.713047] R13: ffffffff81c10480 R14: 0000000000000000 R15: 0000000000000000
[    2.713048]  </IRQ>
[    2.713050]  default_idle+0x1e/0x100
[    2.713052]  arch_cpu_idle+0xf/0x20
[    2.713053]  default_idle_call+0x2c/0x40
[    2.713055]  do_idle+0x158/0x1e0
[    2.713056]  cpu_startup_entry+0x73/0x80
[    2.713058]  rest_init+0xb8/0xc0
[    2.713070]  start_kernel+0x4a2/0x4c3
[    2.713072]  ? set_init_arg+0x5a/0x5a
[    2.713074]  ? early_idt_handler_array+0x120/0x120
[    2.713075]  x86_64_start_reservations+0x2a/0x2c
[    2.713077]  x86_64_start_kernel+0x14c/0x16f
[    2.713079]  secondary_startup_64+0x9f/0x9f
[    2.713080] Code: 44 3b 35 1e 6f d0 00 7c 26 48 83 c4 10 5b 41 5c
41 5d 41 5e 41 5f 5d c3 8b 05 63 38 fc 00 85 c0 75 be 80 3d 20 0d d0
00 00 75 b5 <0f> ff eb b1 48 c7 c2 20 23 e2 81 4c 89 fe 44 89 f7 e8 20
b5 62
[    2.713105] ---[ end trace 4d101d4c176c16b0 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
