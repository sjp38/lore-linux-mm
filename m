Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 416D36B006C
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 12:07:58 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so1038186pab.16
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 09:07:58 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id q3si38043759pdp.113.2014.12.05.09.07.54
        for <linux-mm@kvack.org>;
        Fri, 05 Dec 2014 09:07:55 -0800 (PST)
Date: Fri, 5 Dec 2014 17:07:45 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <20141205170745.GA31222@e104818-lin.cambridge.arm.com>
References: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>
 <20140915113325.GD12361@n2100.arm.linux.org.uk>
 <20141204120305.GC17783@e104818-lin.cambridge.arm.com>
 <20141205120506.GH1630@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141205120506.GH1630@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, Peter Maydell <Peter.Maydell@arm.com>

On Fri, Dec 05, 2014 at 12:05:06PM +0000, Will Deacon wrote:
> On Thu, Dec 04, 2014 at 12:03:05PM +0000, Catalin Marinas wrote:
> > On Mon, Sep 15, 2014 at 12:33:25PM +0100, Russell King - ARM Linux wrote:
> > > On Mon, Sep 15, 2014 at 07:07:20PM +0800, Wang, Yalin wrote:
> > > > @@ -636,6 +646,11 @@ static int keep_initrd;
> > > >  void free_initrd_mem(unsigned long start, unsigned long end)
> > > >  {
> > > >  	if (!keep_initrd) {
> > > > +		if (start == initrd_start)
> > > > +			start = round_down(start, PAGE_SIZE);
> > > > +		if (end == initrd_end)
> > > > +			end = round_up(end, PAGE_SIZE);
> > > > +
> > > >  		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
> > > >  		free_reserved_area((void *)start, (void *)end, -1, "initrd");
> > > >  	}
> > > 
> > > is the only bit of code you likely need to achieve your goal.
> > > 
> > > Thinking about this, I think that you are quite right to align these.
> > > The memory around the initrd is defined to be system memory, and we
> > > already free the pages around it, so it *is* wrong not to free the
> > > partial initrd pages.
> > 
> > Actually, I think we have a problem, at least on arm64 (raised by Peter
> > Maydell). There is no guarantee that the page around start/end of initrd
> > is free, it may contain the dtb for example. This is even more obvious
> > when we have a 64KB page kernel (the boot loader doesn't know the page
> > size that the kernel is going to use).
> > 
> > The bug was there before as we had poison_init_mem() already (not it
> > disappeared since free_reserved_area does the poisoning).
> > 
> > So as a quick fix I think we need the rounding the other way (and in the
> > general case we probably lose a page at the end of initrd):
> > 
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > index 494297c698ca..39fd080683e7 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -335,9 +335,9 @@ void free_initrd_mem(unsigned long start, unsigned long end)
> >  {
> >  	if (!keep_initrd) {
> >  		if (start == initrd_start)
> > -			start = round_down(start, PAGE_SIZE);
> > +			start = round_up(start, PAGE_SIZE);
> >  		if (end == initrd_end)
> > -			end = round_up(end, PAGE_SIZE);
> > +			end = round_down(end, PAGE_SIZE);
> >  
> >  		free_reserved_area((void *)start, (void *)end, 0, "initrd");
> >  	}
> > 
> > A better fix would be to check what else is around the start/end of
> > initrd.
> 
> Care to submit this as a proper patch? We should at least fix Peter's issue
> before doing things like extending headers, which won't work for older
> kernels anyway.

Quick fix is the revert of the whole patch, together with removing
PAGE_ALIGN(end) in poison_init_mem() on arm32. If Russell is ok with
this patch, we can take it via the arm64 tree, otherwise I'll send you a
partial revert only for the arm64 part.

-------------8<-----------------------
