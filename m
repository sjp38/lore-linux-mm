Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA3A96B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:46:14 -0400 (EDT)
Date: Tue, 25 Aug 2009 12:10:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
Message-ID: <20090825111031.GD21335@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org> <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com> <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com> <20090819100553.GE24809@csn.ul.ie> <202cde0e0908200003w43b91ac3v8a149ec1ace45d6d@mail.gmail.com> <20090825104731.GA21335@csn.ul.ie> <1251198054.15197.40.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1251198054.15197.40.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Alexey Korolev <akorolex@gmail.com>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 09:00:54PM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2009-08-25 at 11:47 +0100, Mel Gorman wrote:
> 
> > Why? One hugepage of default size will be one TLB entry. Each hugepage
> > after that will be additional TLB entries so there is no savings on
> > translation overhead.
> > 
> > Getting contiguous pages beyond the hugepage boundary is not a matter
> > for GFP flags.
> 
> Note: This patch reminds me of something else I had on the backburner
> for a while and never got a chance to actually implement...
> 
> There's various cases of drivers that could have good uses of hugetlb
> mappings of device memory. For example, framebuffers.
> 

Where is the buffer located? If it's in kernel space, than any contiguous
allocation will be automatically backed by huge PTEs. As framebuffer allocation
is probably happening early in boot, just calling alloc_pages() might do?

> I looked at it a while back and it occured to me (and Nick) that
> ideally, we should split hugetlb and hugetlbfs.
> 

Yeah, you're not the first to come to that conclusion :)

> Basically, on one side, we have the (mostly arch specific) populating
> and walking of page tables with hugetlb translations, associated huge
> VMAs, etc... 
> 
> On the other side, hugetlbfs is backing that with memory.
> 
> Ideally, the former would have some kind of "standard" ops that
> hugetlbfs can hook into for the existing case (moving some stuff out of
> the common data structure and splitting it in two),

Adam Litke at one point posted a pagetable-abstraction that would have
been the first step on a path like this. It hurt the normal fastpath
though and was ultimately put aside.

> allowing the driver
> to instanciate hugetlb VMAs that are backed up by something else,
> typically a simple mapping of IOs.
> 
> Anybody wants to do that or I keep it on my back burner until the time I
> finally get to do it ? :-)
> 

It's the sort of thing that has been resisted in the past, largely
because the only user at the time was about transparent hugepage
promotion/demotion. It would need to be a really strong incentive to
revive the effort.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
