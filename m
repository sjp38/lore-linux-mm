Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B55FC6B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 09:41:50 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so794623pab.34
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 06:41:50 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id fk4si47722448pbb.236.2014.12.05.06.41.48
        for <linux-mm@kvack.org>;
        Fri, 05 Dec 2014 06:41:49 -0800 (PST)
Date: Fri, 5 Dec 2014 14:41:35 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <20141205144134.GC7695@localhost>
References: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>
 <20140915113325.GD12361@n2100.arm.linux.org.uk>
 <20141204120305.GC17783@e104818-lin.cambridge.arm.com>
 <35FD53F367049845BC99AC72306C23D103E688B313EA@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313EA@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, Peter Maydell <Peter.Maydell@arm.com>

On Fri, Dec 05, 2014 at 02:35:29AM +0000, Wang, Yalin wrote:
> > -----Original Message-----
> > From: Catalin Marinas [mailto:catalin.marinas@arm.com]
> > Sent: Thursday, December 04, 2014 8:03 PM
> > To: Russell King - ARM Linux
> > Cc: Wang, Yalin; 'linux-mm@kvack.org'; Will Deacon; 'linux-
> > kernel@vger.kernel.org'; 'linux-arm-kernel@lists.infradead.org'; 'linux-
> > arm-msm@vger.kernel.org'; Peter Maydell
> > Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be page
> > aligned
> > 
> > On Mon, Sep 15, 2014 at 12:33:25PM +0100, Russell King - ARM Linux wrote:
> > > On Mon, Sep 15, 2014 at 07:07:20PM +0800, Wang, Yalin wrote:
> > > > @@ -636,6 +646,11 @@ static int keep_initrd;  void
> > > > free_initrd_mem(unsigned long start, unsigned long end)  {
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
> > Maydell). There is no guarantee that the page around start/end of initrd is
> > free, it may contain the dtb for example. This is even more obvious when we
> > have a 64KB page kernel (the boot loader doesn't know the page size that
> > the kernel is going to use).
> > 
> > The bug was there before as we had poison_init_mem() already (not it
> > disappeared since free_reserved_area does the poisoning).
> > 
> > So as a quick fix I think we need the rounding the other way (and in the
> > general case we probably lose a page at the end of initrd):
> > 
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c index
> > 494297c698ca..39fd080683e7 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -335,9 +335,9 @@ void free_initrd_mem(unsigned long start, unsigned long
> > end)  {
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
> > A better fix would be to check what else is around the start/end of initrd.
> I think a better way is add some head info in Image header,
> So that bootloader  can know the kernel CONFIG_PAGE_SIZE ,
> For example we can add PAGE_SIZE in zImage header .
> How about this way?

The problem is that we don't know how many boot loaders are affected. We
could simply mandate in booting.txt that the dtb and initrd are not
closer than 64KB but we have the same issue, existing boot loaders.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
