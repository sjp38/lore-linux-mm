Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C3CDE6B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 05:51:16 -0500 (EST)
Date: Mon, 21 Dec 2009 10:50:17 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: CPU consumption is going as high as 95% on ARM Cortex A8
Message-ID: <20091221105017.GB11669@n2100.arm.linux.org.uk>
References: <19F8576C6E063C45BE387C64729E73940449F43857@dbde02.ent.ti.com> <20091217095641.GA399@n2100.arm.linux.org.uk> <19F8576C6E063C45BE387C64729E73940449F43E29@dbde02.ent.ti.com> <20091221090750.GA11669@n2100.arm.linux.org.uk> <19F8576C6E063C45BE387C64729E73940449F43EEE@dbde02.ent.ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19F8576C6E063C45BE387C64729E73940449F43EEE@dbde02.ent.ti.com>
Sender: owner-linux-mm@kvack.org
To: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 21, 2009 at 02:51:13PM +0530, Hiremath, Vaibhav wrote:
> > On Mon, Dec 21, 2009 at 11:56:23AM +0530, Hiremath, Vaibhav wrote:
> > > >         vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> > > >
> > > > will result in the memory being mapped as 'Strongly Ordered',
> > > > resulting
> > > > in there being multiple mappings with differing types.  In later
> > > > kernels, we have pgprot_dmacoherent() and I'd suggest changing
> > the
> > > > above
> > > > macro for that.
> > > >
> > >
> > > I tried with your suggestion above but unfortunately it didn't
> > work for
> > > me. I am seeing the same behavior with the pgprot_dmacoherent(). I
> > > pulled your patch (which got applied cleanly on 2.6.32-rc5) -
> > 
> > What happens if you comment out the pgprot_dmacoherent() /
> > pgprot_noncached()
> > line completely?
>
> If I comment the line completely then I am seeing
> CPU consumption similar to when I was setting PAGE_READONLY/PAGE_SHARED
> flag, which is 25-32%.
> 
> > I suspect that will "solve" the problem - but you'll then no longer
> > have
> > DMA coherency with userspace, so its not really a solution.

So it _is_ down to purely the amount of time it takes to read from a
non-cacheable buffer.  I think you need to investigate the userspace
program and see whether it's doing anything silly - I don't think the
lack of performance is a kernel problem as such.

How large is this buffer?  What userspace program is reading from it?
Could the userspace program be unnecessarily re-reading from the
multiple times for the same frame?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
