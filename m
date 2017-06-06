Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 313356B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 13:15:34 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id w1so72623752qtg.6
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 10:15:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e128si3485653qkc.302.2017.06.06.10.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 10:15:32 -0700 (PDT)
Date: Tue, 6 Jun 2017 13:15:29 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: x86/mm/64: Possible bug with remove_pagetable in v4.12-rc1
Message-ID: <20170606171527.GB6052@redhat.com>
References: <7960e084-820e-e022-1272-191b0d5eeb32@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7960e084-820e-e022-1272-191b0d5eeb32@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stephen Bates <sbates@raithlin.com>

On Fri, Jun 02, 2017 at 12:49:34PM -0600, Logan Gunthorpe wrote:
> Hi Friends,
> 
> I may have hit on a possible bug with remove_pagetables. However, so
> far, I have only been able to reproduce it with my out-of-tree p2pmem
> patchset (so I understand if you don't consider it a bug). At this time,
> I have not able been able to reproduce it using device-dax.
> 
> Starting with v4.12-rc1 and including rc3, if I insert PCI bar memory
> using devm_memremap_pages, then remove it, then insert it again I hit a
> kernel BUG (see below).
> 
> I did a quick bisect to find the commit that causes this is:
> 
> e6ab9c4d4: x86/mm/64: Fix crash in remove_pagetable()
> 
> If I print the output of pgd_page_vaddr and p4d_offset, I get very
> different addresses:
> 
> pgd_page_vaddr: ffff88026c04d000
> p4d_offset: ffffffff81e0aea8
> 
> The version of p4d_offset my kernel is using is the one in
> pgtable-nop4d.h which simply returns a casted version of pgd. This seems
> slightly suspect but I can't say I understand this code all that well.
> 
> Thanks for your help,
> 
> Logan

I am about to post a patch for this. I will cc you.

Cheers,
Jerome

> 
> 
> > [  111.501162] ------------[ cut here ]------------
> > [  111.506427] kernel BUG at arch/x86/mm/init_64.c:128!
> > [  111.512080] invalid opcode: 0000 [#1] SMP
> > [  111.516662] Modules linked in: mtr_p2pmem(O+) [last unloaded: mtr_p2pmem]
> > [  111.524357] CPU: 4 PID: 2317 Comm: insmod Tainted: G           O    4.11.0-rc5.direct-00148-g052a6536f8db #435
> > [  111.535667] Hardware name: Supermicro SYS-7047GR-TRF/X9DRG-QF, BIOS 3.0a 12/05/2013
> > [  111.544352] task: ffff880274d54300 task.stack: ffffc90002edc000
> > [  111.551079] RIP: 0010:sync_global_pgds+0x134/0x140
> > [  111.556535] RSP: 0018:ffffc90002edfaa8 EFLAGS: 00010287
> > [  111.562477] RAX: 00003ffffffff000 RBX: 0000000000000c00 RCX: ffffc08000000000
> > [  111.570556] RDX: 0000000000000001 RSI: ffff88046d462000 RDI: ffff8802749ed000
> > [  111.578628] RBP: ffff880000000000 R08: ffffffff81e0ac00 R09: 000000046d462067
> > [  111.586710] R10: ffff88046d462000 R11: ffff880474bdd1e0 R12: ffffffff81e0ac00
> > [  111.594789] R13: ffff8804775f3c00 R14: ffff8804775c1400 R15: ffffea0011dd7cc0
> > [  111.602871] FS:  00007f3f39999700(0000) GS:ffff88047fc00000(0000) knlGS:0000000000000000
> > [  111.612043] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  111.618569] CR2: 000055e04c19f1d8 CR3: 00000004771f0000 CR4: 00000000000406e0
> > [  111.626651] Call Trace:
> > [  111.629491]  ? kernel_physical_mapping_init+0x1c2/0x1e2
> > [  111.635438]  ? init_memory_mapping+0x1c0/0x370
> > [  111.640509]  ? walk_system_ram_range+0x6d/0xb0
> > [  111.645578]  ? arch_add_memory+0x4b/0xe0
> > [  111.650067]  ? devm_memremap_pages+0x276/0x3c0
> > [  111.655141]  ? p2pmem_add_resource+0x25/0xc0
> > [  111.660016]  ? mtramon_init+0x17a/0x1000 [mtr_p2pmem]
> > [  111.665764]  ? 0xffffffffa000a000
> > [  111.669570]  ? do_one_initcall+0x39/0x170
> > [  111.674154]  ? do_init_module+0x55/0x1e5
> > [  111.678643]  ? load_module+0x24ae/0x29a0
> > [  111.683130]  ? SYSC_finit_module+0x91/0xc0
> > [  111.687811]  ? SYSC_finit_module+0x91/0xc0
> > [  111.692492]  ? entry_SYSCALL_64_fastpath+0x13/0x94
> > [  111.697950] Code: 49 f7 45 00 9f ff ff ff 75 a3 49 89 75 00 eb 9d c6 05 a8 85 00 01 00 e9 06 ff ff ff 48 83 c4 10 5b 5d 41 5c 41 5d 41 5e 41 5f c3 <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 55 53 48 89 f3 48 89 d5 e8 
> > [  111.719213] RIP: sync_global_pgds+0x134/0x140 RSP: ffffc90002edfaa8
> > [  111.726340] ---[ end trace 34982079c1a73cd0 ]---
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
