Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id AC3B56B009D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 09:35:46 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MBX00IBNSFJNE90@mailout3.samsung.com> for
 linux-mm@kvack.org; Mon, 15 Oct 2012 22:35:45 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MBX00GB5SF8PN10@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 15 Oct 2012 22:35:45 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1350192523.10946.4.camel@gitbox> <1350246895.11504.6.camel@gitbox>
 <1350253591.13440.1.camel@gitbox> <1822826.6oRYLvbneG@flatron>
 <1350288210.16750.2.camel@gitbox>
In-reply-to: <1350288210.16750.2.camel@gitbox>
Subject: RE: dma_alloc_coherent fails in framebuffer
Date: Mon, 15 Oct 2012 15:35:31 +0200
Message-id: <03be01cdaad9$f57d57f0$e07807d0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Tony Prisk' <linux@prisktech.co.nz>, 'Tomasz Figa' <tomasz.figa@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, mgorman@suse.de, 'Arnd Bergmann' <arnd@arndb.de>

Hello,

On Monday, October 15, 2012 10:04 AM Tony Prisk wrote:

> On Mon, 2012-10-15 at 08:42 +0200, Tomasz Figa wrote:
> > Hi Tony,
> >
> > On Monday 15 of October 2012 11:26:31 Tony Prisk wrote:
> > > On Mon, 2012-10-15 at 09:34 +1300, Tony Prisk wrote:
> > > > On Sun, 2012-10-14 at 18:28 +1300, Tony Prisk wrote:
> > > > > Up until 07 Oct, drivers/video/wm8505-fb.c was working fine, but on
> > > > > the
> > > > > 11 Oct when I did another pull from linus all of a sudden
> > > > > dma_alloc_coherent is failing to allocate the framebuffer any
> > > > > longer.
> > > > >
> > > > > I did a quick look back and found this:
> > > > >
> > > > > ARM: add coherent dma ops
> > > > >
> > > > > arch_is_coherent is problematic as it is a global symbol. This
> > > > > doesn't work for multi-platform kernels or platforms which can
> > > > > support
> > > > > per device coherent DMA.
> > > > >
> > > > > This adds arm_coherent_dma_ops to be used for devices which
> > > > > connected
> > > > > coherently (i.e. to the ACP port on Cortex-A9 or A15). The
> > > > > arm_dma_ops
> > > > > are modified at boot when arch_is_coherent is true.
> > > > >
> > > > > Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> > > > > Cc: Russell King <linux@arm.linux.org.uk>
> > > > > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > > > > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > > > >
> > > > >
> > > > > This is the only patch lately that I could find (not that I would
> > > > > claim
> > > > > to be any good at finding things) that is related to the problem.
> > > > > Could
> > > > > it have caused the allocations to fail?
> > > > >
> > > > > Regards
> > > > > Tony P
> > > >
> > > > Have done a bit more digging and found the cause - not Rob's patch so
> > > > apologies.
> > > >
> > > > The cause of the regression is this patch:
> > > >
> > > > From f40d1e42bb988d2a26e8e111ea4c4c7bac819b7e Mon Sep 17 00:00:00 2001
> > > > From: Mel Gorman <mgorman@suse.de>
> > > > Date: Mon, 8 Oct 2012 16:32:36 -0700
> > > > Subject: [PATCH 2/3] mm: compaction: acquire the zone->lock as late as
> > > >
> > > >  possible
> > > >
> > > > Up until then, the framebuffer allocation with dma_alloc_coherent(...)
> > > > was fine. From this patch onwards, allocations fail.
> > > >
> > > > I don't know how this patch would effect CMA allocations, but it seems
> > > > to be causing the issue (or at least, it's caused an error in
> > > > arch-vt8500 to become visible).
> > > >
> > > > Perhaps someone who understand -mm could explain the best way to
> > > > troubleshoot the cause of this problem?
> > > >
> > > >
> > > > Regards
> > > > Tony P
> > > >
> > > Have done a bit more testing..
> > >
> > > Disabling Memory Compaction makes no difference.
> > > Disabling CMA fixes/hides the problem. ?!?!?!
> >
> > Could you post your kernel log when it isn't working?
> >
> > Do you have the default CMA reserved pool in Kconfig set big enough to
> > serve this allocation?
> >
> > I'm not sure what kind of allocation this framebuffer driver does, but if
> > it needs to allocate memory from atomic context then possibly this patch
> > series has something to do with it:
> > http://thread.gmane.org/gmane.linux.ports.arm.kernel/182697/focus=182699
> >
> > CC'ing Marek Szyprowski <m.szyprowski@samsung.com>
>
> I set CMA to 16MB (and also tried 32MB) in Kconfig, but it made no
> difference. The framebuffer is only trying to allocate ~1.5MB via
> dma_alloc_coherent().
> 
> I haven't captured a kernel log, but will do.
> 
> Thanks for the feedback.

Commit 627260595ca6abcb16d68a3732bac6b547e112d6 "mm: compaction: fix bit ranges in 
{get,clear,set}_pageblock_skip()" should fix the issues with broken CMA allocations,
please check if todays v3.7-rc1 works for You.

For more information please check http://thread.gmane.org/gmane.linux.kernel/1365503/ 
thread.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
