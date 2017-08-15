Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B54E76B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:40:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 123so7633026pga.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:40:20 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p61si5866040plb.165.2017.08.15.02.40.19
        for <linux-mm@kvack.org>;
        Tue, 15 Aug 2017 02:40:19 -0700 (PDT)
Date: Tue, 15 Aug 2017 10:39:01 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [kernel-hardening] [PATCH v5 07/10] arm64/mm: Don't flush the
 data cache if the page is unmapped by XPFO
Message-ID: <20170815093900.GA6090@leverpostej>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-8-tycho@docker.com>
 <20170812115736.GC16374@remoulade>
 <20170814202727.5jm5ndd3nzlwftfb@smitten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814202727.5jm5ndd3nzlwftfb@smitten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Mon, Aug 14, 2017 at 02:27:27PM -0600, Tycho Andersen wrote:
> Hi Mark,
> 
> First, thanks for taking a look!
> 
> On Sat, Aug 12, 2017 at 12:57:37PM +0100, Mark Rutland wrote:
> > On Wed, Aug 09, 2017 at 02:07:52PM -0600, Tycho Andersen wrote:
> > > From: Juerg Haefliger <juerg.haefliger@hpe.com>
> > > 
> > > If the page is unmapped by XPFO, a data cache flush results in a fatal
> > > page fault. So don't flush in that case.
> > 
> > Do you have an example callchain where that happens? We might need to shuffle
> > things around to cater for that case.
> 
> Here's one from the other branch (i.e. xpfo_page_is_unmapped() is true):
> 
> [   15.487293] CPU: 2 PID: 1633 Comm: plymouth Not tainted 4.13.0-rc4-c2+ #242
> [   15.487295] Hardware name: Hardkernel ODROID-C2 (DT)
> [   15.487297] Call trace:
> [   15.487313] [<ffff0000080884f0>] dump_backtrace+0x0/0x248
> [   15.487317] [<ffff00000808878c>] show_stack+0x14/0x20
> [   15.487324] [<ffff000008b3e1b8>] dump_stack+0x98/0xb8
> [   15.487329] [<ffff000008098bb4>] sync_icache_aliases+0x84/0x98
> [   15.487332] [<ffff000008098c74>] __sync_icache_dcache+0x64/0x88
> [   15.487337] [<ffff0000081d4814>] alloc_set_pte+0x4ec/0x6b8
> [   15.487342] [<ffff00000819d920>] filemap_map_pages+0x350/0x360
> [   15.487344] [<ffff0000081d4ccc>] do_fault+0x28c/0x568
> [   15.487347] [<ffff0000081d67a0>] __handle_mm_fault+0x410/0xd08
> [   15.487350] [<ffff0000081d7164>] handle_mm_fault+0xcc/0x1a8
> [   15.487352] [<ffff000008098580>] do_page_fault+0x270/0x380
> [   15.487355] [<ffff00000808128c>] do_mem_abort+0x3c/0x98
> [   15.487358] Exception stack(0xffff800061dabe20 to 0xffff800061dabf50)
> [   15.487362] be20: 0000000000000000 0000800062e19000 ffffffffffffffff 0000ffff8f64ddc8
> [   15.487365] be40: ffff800061dabe80 ffff000008238810 ffff800061d80330 0000000000000018
> [   15.487368] be60: ffffffffffffffff 0000ffff8f5ba958 ffff800061d803d0 ffff800067132e18
> [   15.487370] be80: 0000000000000000 ffff800061d80d08 0000000000000000 0000000000000019
> [   15.487373] bea0: 000000002bd3d0f0 0000000000000000 0000000000000019 ffff800067132e00
> [   15.487376] bec0: 0000000000000000 0000ffff8f657220 0000000000000000 0000000000000000
> [   15.487379] bee0: 8080808000000000 0000000000000000 0000000080808080 fefefeff6f6b6467
> [   15.487381] bf00: 7f7f7f7f7f7f7f7f 000000002bd3fb40 0101010101010101 0000000000000020
> [   15.487384] bf20: 00000000004072b0 00000000004072e0 0000000000000000 0000ffff8f6b2000
> [   15.487386] bf40: 0000ffff8f66b190 0000ffff8f576380
> [   15.487389] [<ffff000008082b74>] el0_da+0x20/0x24
> 
> > > @@ -30,7 +31,9 @@ void sync_icache_aliases(void *kaddr, unsigned long len)
> > >  	unsigned long addr = (unsigned long)kaddr;
> > >  
> > >  	if (icache_is_aliasing()) {
> > > -		__clean_dcache_area_pou(kaddr, len);
> > > +		/* Don't flush if the page is unmapped by XPFO */
> > > +		if (!xpfo_page_is_unmapped(virt_to_page(kaddr)))
> > > +			__clean_dcache_area_pou(kaddr, len);
> > >  		__flush_icache_all();
> > >  	} else {
> > >  		flush_icache_range(addr, addr + len);
> > 
> > I don't think this patch is correct. If data cache maintenance is required in
> > the absence of XPFO, I don't see why it wouldn't be required in the presence of
> > XPFO.
> 
> Ok. I suppose we could do re-map like we do for dma; or is there some
> re-arrangement of things you can see that would help?

Creating a temporary mapping (which I guess you do for DMA) should work.

We might be able to perform the maintenance before we unmap the linear
map alias, but I guess this might not be possible if the that logic is
too far removed from the PTE manipulation.

> > On a more general note, in future it would be good to Cc the arm64 maintainers
> > and the linux-arm-kernel mailing list for patches affecting arm64.
> 
> Yes, I thought about doing that for the series, but since it has x86 patches
> too, I didn't want to spam everyone :). I'll just add x86/arm lists to CC in
> the patches in the future. If there's some better way, let me know.

That sounds fine; thanks.

Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
