Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8F66B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 02:22:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a6-v6so4040381pgt.15
        for <linux-mm@kvack.org>; Sun, 20 May 2018 23:22:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1-v6sor6044300plf.38.2018.05.20.23.16.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 May 2018 23:16:47 -0700 (PDT)
Date: Mon, 21 May 2018 15:16:33 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180521061631.GA26882@js1304-desktop>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz>
 <20180517133629.GH23723@intel.com>
 <20180517135832.GI23723@intel.com>
 <20180517164947.GV12670@dhcp22.suse.cz>
 <20180517170816.GW12670@dhcp22.suse.cz>
 <ccbe3eda-0880-1d59-2204-6bd4b317a4fe@redhat.com>
 <20180518040104.GA17433@js1304-desktop>
 <20180519144632.GE23723@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180519144632.GE23723@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Cc: Laura Abbott <labbott@redhat.com>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, May 19, 2018 at 05:46:32PM +0300, Ville Syrjala wrote:
> On Fri, May 18, 2018 at 01:01:04PM +0900, Joonsoo Kim wrote:
> > On Thu, May 17, 2018 at 10:53:32AM -0700, Laura Abbott wrote:
> > > On 05/17/2018 10:08 AM, Michal Hocko wrote:
> > > >On Thu 17-05-18 18:49:47, Michal Hocko wrote:
> > > >>On Thu 17-05-18 16:58:32, Ville Syrjala wrote:
> > > >>>On Thu, May 17, 2018 at 04:36:29PM +0300, Ville Syrjala wrote:
> > > >>>>On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
> > > >>>>>On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
> > > >>>>>>From: Ville Syrjala <ville.syrjala@linux.intel.com>
> > > >>>>>>
> > > >>>>>>This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> > > >>>>>>
> > > >>>>>>Make x86 with HIGHMEM=y and CMA=y boot again.
> > > >>>>>
> > > >>>>>Is there any bug report with some more details? It is much more
> > > >>>>>preferable to fix the issue rather than to revert the whole thing
> > > >>>>>right away.
> > > >>>>
> > > >>>>The machine I have in front of me right now didn't give me anything.
> > > >>>>Black screen, and netconsole was silent. No serial port on this
> > > >>>>machine unfortunately.
> > > >>>
> > > >>>Booted on another machine with serial:
> > > >>
> > > >>Could you provide your .config please?
> > > >>
> > > >>[...]
> > > >>>[    0.000000] cma: Reserved 4 MiB at 0x0000000037000000
> > > >>[...]
> > > >>>[    0.000000] BUG: Bad page state in process swapper  pfn:377fe
> > > >>>[    0.000000] page:f53effc0 count:0 mapcount:-127 mapping:00000000 index:0x0
> > > >>
> > > >>OK, so this looks the be the source of the problem. -128 would be a
> > > >>buddy page but I do not see anything that would set the counter to -127
> > > >>and the real map count updates shouldn't really happen that early.
> > > >>
> > > >>Maybe CONFIG_DEBUG_VM and CONFIG_DEBUG_HIGHMEM will tell us more.
> > > >
> > > >Looking closer, I _think_ that the bug is in set_highmem_pages_init->is_highmem
> > > >and zone_movable_is_highmem might force CMA pages in the zone movable to
> > > >be initialized as highmem. And that sounds supicious to me. Joonsoo?
> > > >
> > > 
> > > For a point of reference, arm with this configuration doesn't hit this bug
> > > because highmem pages are freed via the memblock interface only instead
> > > of iterating through each zone. It looks like the x86 highmem code
> > > assumes only a single highmem zone and/or it's disjoint?
> > 
> > Good point! Reason of the crash is that the span of MOVABLE_ZONE is
> > extended to whole node span for future CMA initialization, and,
> > normal memory is wrongly freed here.
> > 
> > Here goes the fix. Ville, Could you test below patch?
> > I re-generated the issue on my side and this patch fixed it.
> 
> This gets me past the initial hurdles. But when I tried it on a machine
> with an actual 32 bit OS it oopsed again later in the boot.
> 
> [    0.000000] Linux version 4.17.0-rc5-mgm+ () (gcc version 6.4.0 (Gentoo 6.4.0-r1 p1.3)) #57 PREEMPT Sat May 19 17:25:27 EEST 2018
> [    0.000000] x86/fpu: x87 FPU will use FXSAVE
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f7ff] usable
> [    0.000000] BIOS-e820: [mem 0x000000000009f800-0x000000000009ffff] reserved
[snip....]
> [    1.487182] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> [    1.514395] 00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
> [    1.522211] serial 00:05: skipping CIR port at 0x2e8 / 0x0, IRQ 3
> [    1.530173] ata_piix 0000:00:1f.1: enabling device (0005 -> 0007)
> [    1.538301] BUG: unable to handle kernel NULL pointer dereference at 00000000
> [    1.540010] *pde = 00000000 
> [    1.540010] Oops: 0002 [#1] PREEMPT
> [    1.540010] Modules linked in:
> [    1.540010] CPU: 0 PID: 1 Comm: swapper Tainted: G        W         4.17.0-rc5-mgm+ #57
> [    1.540010] Hardware name: FUJITSU SIEMENS LIFEBOOK S6120/FJNB16C, BIOS Version 1.26  05/10/2004
> [    1.540010] EIP: dma_direct_alloc+0x22f/0x260
> [    1.540010] EFLAGS: 00210246 CPU: 0
> [    1.540010] EAX: 00000000 EBX: 00000000 ECX: 00000200 EDX: 00000000
> [    1.540010] ESI: 014000c4 EDI: 00000000 EBP: f58d5cdc ESP: f58d5cb8
> [    1.540010]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> [    1.540010] CR0: 80050033 CR2: 00000000 CR3: 018f2000 CR4: 000006d0
> [    1.540010] Call Trace:
> [    1.540010]  ? dma_direct_mapping_error+0x10/0x10
> [    1.540010]  dmam_alloc_coherent+0xe8/0x160
> [    1.540010]  ata_bmdma_port_start+0x42/0x70
> [    1.540010]  piix_port_start+0x1a/0x20
> [    1.540010]  ata_host_start.part.9+0xcb/0x1c0
> [    1.540010]  ata_host_start+0x18/0x20
> [    1.540010]  ata_pci_sff_activate_host+0x30/0x2b0
> [    1.540010]  ? pci_write_config_byte+0x50/0x60
> [    1.540010]  ? ata_bmdma_port_intr+0xe0/0xe0
> [    1.540010]  piix_init_one+0x2e1/0x5e0
> [    1.540010]  ? _raw_spin_unlock_irqrestore+0x5d/0x80
> [    1.540010]  pci_device_probe+0x9a/0x130
> [    1.540010]  ? devices_kset_move_last+0x67/0xe0
> [    1.540010]  ? sysfs_create_link+0x25/0x50
> [    1.540010]  driver_probe_device+0x319/0x4e0
> [    1.540010]  ? _raw_spin_unlock+0x2c/0x50
> [    1.540010]  ? pci_match_device+0xd2/0x100
> [    1.540010]  __driver_attach+0xd9/0x100
> [    1.540010]  ? klist_next+0x6b/0xe0
> [    1.540010]  ? driver_probe_device+0x4e0/0x4e0
> [    1.540010]  bus_for_each_dev+0x4b/0x90
> [    1.540010]  driver_attach+0x1e/0x20
> [    1.540010]  ? driver_probe_device+0x4e0/0x4e0
> [    1.540010]  bus_add_driver+0x18f/0x280
> [    1.540010]  driver_register+0x5d/0xf0
> [    1.540010]  ? ata_sff_init+0x35/0x35
> [    1.540010]  __pci_register_driver+0x50/0x60
> [    1.540010]  piix_init+0x19/0x29
> [    1.540010]  do_one_initcall+0x62/0x330
> [    1.540010]  ? parse_args+0x1cd/0x410
> [    1.540010]  kernel_init_freeable+0x214/0x31b
> [    1.540010]  ? rest_init+0x1f0/0x1f0
> [    1.540010]  kernel_init+0x10/0x110
> [    1.540010]  ? schedule_tail_wrapper+0x9/0xc
> [    1.540010]  ret_from_fork+0x2e/0x38
> [    1.540010] Code: 0f 84 02 ff ff ff eb d4 8d 74 26 00 f6 c2 01 75 21 f7 c7 02 00 00 00 75 24 f7 c7 04 00 00 00 75 29 89 d9 31 c0 c1 e9 02 83 e3 03 <f3> ab e9 c4 fe ff ff c6 02 00 8d 7a 01 8b 5d e0 eb d4 66 c7 07 
> [    1.540010] EIP: dma_direct_alloc+0x22f/0x260 SS:ESP: 0068:f58d5cb8
> [    1.540010] CR2: 0000000000000000
> [    1.540010] ---[ end trace 37f4adc02e5109c8 ]---
[snip...]
> (gdb) list *(dma_direct_alloc+0x22f)
> 0x573fbf is in dma_direct_alloc (../lib/dma-direct.c:104).
> 94	
> 95		if (!page)
> 96			return NULL;
> 97		ret = page_address(page);
> 98		if (force_dma_unencrypted()) {
> 99			set_memory_decrypted((unsigned long)ret, 1 << page_order);
> 100			*dma_handle = __phys_to_dma(dev, page_to_phys(page));
> 101		} else {
> 102			*dma_handle = phys_to_dma(dev, page_to_phys(page));
> 103		}
> 104		memset(ret, 0, size);
> 105		return ret;
> 106	}
> 

Okay. I find the reason about this error.

page_address() is called in dma_direct_alloc() and it returns 'NULL'
since PageHighMem() for CMA memory returns 'true' after my patches
that manages CMA memory by using the ZONE_MOVABLE.

page_address()
{
        if (!PageHighMem())
                return lowmem_address()
        try to find kmap mapping
        if failed, return NULL
}

I assumed that the caller, who want to get the virtual address of the
page, calls the PageHighMem() and creates a new mapping if
PageHighMem() is 'true', but, it looks not true in this case. It knows
where the memory comes from so it directly call the page_address().
This usecase is valid so I should fix the issue on my side.

I have an idea to fix this case but I think that reverting the patches
is the best at this moment since there is not enough time to test a
new idea before the release.

My idea is to change the implementation of the PageHighMem() like as
below.

-#define PageHighMem(__p) is_highmem_idx(page_zonenum(__p))
+#define PageHighMem(__p) (page_to_pfn(__p) >= max_low_pfn)

And then, I will rename PageHighMem() to !PageDirectMapped().

Current PageHighMem() is mostly used to check if the direct mapping
exists or not. Until now, pages on the higher zones (ZONE_HIGHMEM,
ZONE_MOVABLE when ZONE_HIGHMEM is used) are not direct mapped so
previous implementation that checks higher zone implys the existence
of the direct mapping. However, with my patches, it's not true anymore
so implementation need to be changed.

With above idea that checks pfn rather than the zone type, existence
of the mapping can be determined correctly, regardless of the zone
where the pages are belong to. And, page_address() will work
correctly.

If someone has other opinion, please let me know.

Thanks.
