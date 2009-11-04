Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 576A06B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 23:10:35 -0500 (EST)
Subject: Re: RFC: Transparent Hugepage support
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20091103111829.GJ11981@random.random>
References: <20091026185130.GC4868@random.random>
	 <1257024567.7907.17.camel@pasglop>  <20091103111829.GJ11981@random.random>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 Nov 2009 15:10:26 +1100
Message-ID: <1257307826.13611.45.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-11-03 at 12:18 +0100, Andrea Arcangeli wrote:
> On Sun, Nov 01, 2009 at 08:29:27AM +1100, Benjamin Herrenschmidt wrote:
> > This isn't possible on all architectures. Some archs have "segment"
> > constraints which mean only one page size per such "segment". Server
> > ppc's for example (segment size being either 256M or 1T depending on the
> > CPU).
> 
> Hmm 256M is already too large for a transparent allocation. 

Right.

> It will
> require reservation and hugetlbfs to me actually seems a perfect fit
> for this hardware limitation. The software limits of hugetlbfs matches
> the hardware limit perfectly and it already provides all necessary
> permission and reservation features needed to deal with extremely huge
> page sizes that probabilistically would never be found in the buddy
> (even if we were to extend it to make it not impossible). 

Yes. Note that powerpc -embedded- processors don't have that limitation
though (in large part because they are mostly SW loaded TLBs and they
support a wider collection of page sizes). So it would be possible to
implement your transparent scheme on those.

> That are
> hugely expensive to defrag dynamically even if we could [and we can't
> hope to defrag many of those because of slab]. Just in case it's not
> obvious the probability we can defrag degrades exponentially with the
> increase of the hugepagesize (which also means 256M is already orders
> of magnitude more realistic to function than than 1G).

True. 256M might even be worth toying with as an experiment on huge
machines with TBs of memory in fact :-)

>  Clearly if we
> increase slab to allocate with a front allocator in 256M chunk then
> our probability increases substantially, but to make something
> realistic there's at minimum an order of 10000 times between
> hugepagesize and total ram size. I.e. if 2M page makes some
> probabilistic sense with slab front-allocating 2M pages on a 64G
> system, for 256M pages to make an equivalent sense, system would
> require minimum 8Terabyte of ram.

Well... such systems aren't that far around the corner, so as I said, it
might still make sense to toy a bit with it. That would definitely -not-
include my G5 workstation though :-)

>  If pages were 1G sized system would
> require 32 Terabyte of ram (and the bigger overhead and trouble we
> would have considering some allocation would still happen in 4k ptes
> and the fixed overhead of relocating those 4k ranges would be much
> bigger if the hugepage size is a lot bigger than 2M and the regular
> page size is still 4k).
> 
> > > The most important design choice is: always fallback to 4k allocation
> > > if the hugepage allocation fails! This is the _very_ opposite of some
> > > large pagecache patches that failed with -EIO back then if a 64k (or
> > > similar) allocation failed...
> > 
> > Precisely because the approach cannot work on all architectures ?
> 
> I thought the main reason for those patches was to allow a fs
> blocksize bigger than PAGE_SIZE, a PAGE_CACHE_SIZE of 64k would allow
> for a 64k fs blocksize without much fs changes. But yes, if the mmu
> can't fallback, then software can't fallback either and so it impedes
> the transparent design on those architectures... To me hugetlbfs looks
> as best as you can get on those mmu.

Right.

I need to look whether your patch would work "better" for us with our
embedded processors though.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
