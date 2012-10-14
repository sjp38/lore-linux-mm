Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3D2E56B002B
	for <linux-mm@kvack.org>; Sun, 14 Oct 2012 18:26:27 -0400 (EDT)
Message-ID: <1350253591.13440.1.camel@gitbox>
Subject: Re: dma_alloc_coherent fails in framebuffer
From: Tony Prisk <linux@prisktech.co.nz>
Date: Mon, 15 Oct 2012 11:26:31 +1300
In-Reply-To: <1350246895.11504.6.camel@gitbox>
References: <1350192523.10946.4.camel@gitbox>
	 <1350246895.11504.6.camel@gitbox>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org, mgorman@suse.de, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>

On Mon, 2012-10-15 at 09:34 +1300, Tony Prisk wrote:
> On Sun, 2012-10-14 at 18:28 +1300, Tony Prisk wrote:
> > Up until 07 Oct, drivers/video/wm8505-fb.c was working fine, but on the
> > 11 Oct when I did another pull from linus all of a sudden
> > dma_alloc_coherent is failing to allocate the framebuffer any longer.
> > 
> > I did a quick look back and found this:
> > 
> > ARM: add coherent dma ops
> > 
> > arch_is_coherent is problematic as it is a global symbol. This
> > doesn't work for multi-platform kernels or platforms which can support
> > per device coherent DMA.
> > 
> > This adds arm_coherent_dma_ops to be used for devices which connected
> > coherently (i.e. to the ACP port on Cortex-A9 or A15). The arm_dma_ops
> > are modified at boot when arch_is_coherent is true.
> > 
> > Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> > Cc: Russell King <linux@arm.linux.org.uk>
> > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > 
> > 
> > This is the only patch lately that I could find (not that I would claim
> > to be any good at finding things) that is related to the problem. Could
> > it have caused the allocations to fail?
> > 
> > Regards
> > Tony P
> 
> Have done a bit more digging and found the cause - not Rob's patch so
> apologies.
> 
> The cause of the regression is this patch:
> 
> From f40d1e42bb988d2a26e8e111ea4c4c7bac819b7e Mon Sep 17 00:00:00 2001
> From: Mel Gorman <mgorman@suse.de>
> Date: Mon, 8 Oct 2012 16:32:36 -0700
> Subject: [PATCH 2/3] mm: compaction: acquire the zone->lock as late as
>  possible
> 
> Up until then, the framebuffer allocation with dma_alloc_coherent(...)
> was fine. From this patch onwards, allocations fail.
> 
> I don't know how this patch would effect CMA allocations, but it seems
> to be causing the issue (or at least, it's caused an error in
> arch-vt8500 to become visible).
> 
> Perhaps someone who understand -mm could explain the best way to
> troubleshoot the cause of this problem?
> 
> 
> Regards
> Tony P
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

Have done a bit more testing..

Disabling Memory Compaction makes no difference.
Disabling CMA fixes/hides the problem. ?!?!?!

Regards
Tony P

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
