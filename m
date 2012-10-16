Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 954786B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 01:54:45 -0400 (EDT)
Message-ID: <1350366893.26424.5.camel@gitbox>
Subject: Re: dma_alloc_coherent fails in framebuffer
From: Tony Prisk <linux@prisktech.co.nz>
Date: Tue, 16 Oct 2012 18:54:53 +1300
In-Reply-To: <CAA_GA1cPE+m8N1LQA2iOym4jbFwcHG+K2p-3iBovPWuf1N1q+g@mail.gmail.com>
References: <1350192523.10946.4.camel@gitbox>
	 <1350246895.11504.6.camel@gitbox> <20121015094547.GC29125@suse.de>
	 <1350325704.31162.16.camel@gitbox>
	 <CAA_GA1cPE+m8N1LQA2iOym4jbFwcHG+K2p-3iBovPWuf1N1q+g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Arnd Bergmann <arnd@arndb.de>, Mel Gorman <mgorman@suse.de>, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>

On Tue, 2012-10-16 at 10:17 +0800, Bob Liu wrote:
> On Tue, Oct 16, 2012 at 2:28 AM, Tony Prisk <linux@prisktech.co.nz> wrote:
> > On Mon, 2012-10-15 at 10:45 +0100, Mel Gorman wrote:
> >> On Mon, Oct 15, 2012 at 09:34:55AM +1300, Tony Prisk wrote:
> >> > On Sun, 2012-10-14 at 18:28 +1300, Tony Prisk wrote:
> >> > > Up until 07 Oct, drivers/video/wm8505-fb.c was working fine, but on the
> >> > > 11 Oct when I did another pull from linus all of a sudden
> >> > > dma_alloc_coherent is failing to allocate the framebuffer any longer.
> >> > >
> >> > > I did a quick look back and found this:
> >> > >
> >> > > ARM: add coherent dma ops
> >> > >
> >> > > arch_is_coherent is problematic as it is a global symbol. This
> >> > > doesn't work for multi-platform kernels or platforms which can support
> >> > > per device coherent DMA.
> >> > >
> >> > > This adds arm_coherent_dma_ops to be used for devices which connected
> >> > > coherently (i.e. to the ACP port on Cortex-A9 or A15). The arm_dma_ops
> >> > > are modified at boot when arch_is_coherent is true.
> >> > >
> >> > > Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> >> > > Cc: Russell King <linux@arm.linux.org.uk>
> >> > > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> >> > > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> >> > >
> >> > >
> >> > > This is the only patch lately that I could find (not that I would claim
> >> > > to be any good at finding things) that is related to the problem. Could
> >> > > it have caused the allocations to fail?
> >> > >
> >> > > Regards
> >> > > Tony P
> >> >
> >> > Have done a bit more digging and found the cause - not Rob's patch so
> >> > apologies.
> >> >
> >> > The cause of the regression is this patch:
> >> >
> >> > From f40d1e42bb988d2a26e8e111ea4c4c7bac819b7e Mon Sep 17 00:00:00 2001
> >> > From: Mel Gorman <mgorman@suse.de>
> >> > Date: Mon, 8 Oct 2012 16:32:36 -0700
> >> > Subject: [PATCH 2/3] mm: compaction: acquire the zone->lock as late as
> >> >  possible
> >> >
> >> > Up until then, the framebuffer allocation with dma_alloc_coherent(...)
> >> > was fine. From this patch onwards, allocations fail.
> >> >
> >>
> >> Was this found through bisection or some other means?
> >>
> >> There was a bug in that series that broke CMA but it was commit bb13ffeb
> >> (mm: compaction: cache if a pageblock was scanned and no pages were
> >> isolated) and it was fixed by 62726059 (mm: compaction: fix bit ranges
> >> in {get,clear,set}_pageblock_skip()). So it should have been fixed by
> >> 3.7-rc1 and probably was included by the time you pulled in October 11th
> >> but bisection would be a pain. There were problems with that series during
> >> development but tests were completing for other people.
> >>
> >> Just in case, is this still broken in 3.7-rc1?
> >
> > Still broken. Although the printk's might have cleared it up a bit.
> >>
> >> > I don't know how this patch would effect CMA allocations, but it seems
> >> > to be causing the issue (or at least, it's caused an error in
> >> > arch-vt8500 to become visible).
> >> >
> >> > Perhaps someone who understand -mm could explain the best way to
> >> > troubleshoot the cause of this problem?
> >> >
> >>
> >> If you are comfortable with ftrace, it can be used to narrow down where
> >> the exact failure is occurring but if you're not comfortable with that
> >> then the easiest is a bunch of printks starting in alloc_contig_range()
> >> to see at what point and why it returns failure.
> >>
> >> It's not obvious at the moment why that patch would cause an allocation
> >> problem. It's the type of patch that if it was wrong it would fail every
> >> time for everyone, not just for a single driver.
> >>
> >
> > I added some printk's to see what was happening.
> >
> > from arch/arm/mm/dma-mapping.c: arm_dma_alloc(..) it calls out to:
> > dma_alloc_from_coherent().
> >
> > This returns 0, because:
> > mem = dev->dma_mem
> > if (!mem) return 0;
> >
> > and then arm_dma_alloc() falls back on __dma_alloc(..)
> >
> >
> > I suspect the reason this fault is a bit 'weird' is because its
> > effectively not using alloc_from_coherent at all, but falling back on
> > __dma_alloc all the time, and sometimes it fails.
> >
> 
> I think you need to declare that memory using
> dma_declare_coherent_memory() before
> alloc_from_coherent.
> 
> > Why it caused a problem on that particular commit I don't know - but it
> > was reproducible by adding/removing it.
> >
> >
> > Regards
> > Tony P
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


I finally found the link to this patch which caused the problem - and
may still be the cause of my problems :)

> >>>
> >>> From f40d1e42bb988d2a26e8e111ea4c4c7bac819b7e Mon Sep 17 00:00:00 2001
> >>> From: Mel Gorman <mgorman@suse.de>
> >>> Date: Mon, 8 Oct 2012 16:32:36 -0700
> >>> Subject: [PATCH 2/3] mm: compaction: acquire the zone->lock as late as
> >>>  possible

In mm/page_alloc.c:alloc_contig_range()

...
	outer_end = isolate_freepages_range(&cc, outer_start, end);
	if (!outer_end) {
		ret = -EBUSY;
		goto done;
	}
..

It is always returning via the !outer_end test with -EBUSY.

isolate_freepages_range() was one of the functions modified by
the above mentioned patch.

Around in a big circle and back to the start :)

Regards
Tony P

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
