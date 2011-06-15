Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A1E676B004A
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 04:03:24 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LMT00551NPLMY40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Jun 2011 09:03:22 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMT00E9DNPJLM@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Jun 2011 09:03:20 +0100 (BST)
Date: Wed, 15 Jun 2011 10:02:48 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
In-reply-to: <201106141549.29315.arnd@arndb.de>
Message-id: <000601cc2b32$9e2a4030$da7ec090$%szyprowski@samsung.com>
Content-language: pl
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <201106101821.50437.arnd@arndb.de>
 <006a01cc29a9$1394c330$3abe4990$%szyprowski@samsung.com>
 <201106141549.29315.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Tuesday, June 14, 2011 3:49 PM Arnd Bergmann wrote:

> On Monday 13 June 2011, Marek Szyprowski wrote:
> > cm_alloc/free are definitely not meant to be called from device drivers.
> > They should be only considered as a backend for dma-mapping.
> >
> > 'Raw' contiguous memory block doesn't really make sense for the device
> > drivers. What the drivers require is a contiguous memory block that is
> > somehow mapped into respective bus address space, so dma-mapping
> > framework is the right interface.
> >
> > alloc_pages(..., GFP_CMA) looks nice but in fact it is really impractical.
> > The driver will need to map such buffer to dma context anyway, so imho
> > dma_alloc_attributed() will give the drivers much more flexibility. In
> > terms of dma-mapping the context argument isn't anything odd.
> 
> Ok.
> 
> > If possible I would like to make cma something similar to
> > declare_dma_coherent()&friends, so the board/platform/bus startup code
> > will just call declare_dma_contiguous() to enable support for cma for
> > particular devices.
> 
> Sounds good, I like that.
 
Thanks. I thought a bit more on this and decided that I want to make this
declare_dma_contiguous() optional for the drivers. It should be used only
for some sophisticated cases like for example our video codec with two
memory interfaces for 2 separate banks. By default the dma-mapping will
use system-wide cma pool.

(snipped)

> > > * It requires you to pass the exact location of the area. I can see why
> > >   you want that on certain machines that require DMA areas to be spread
> > >   across multiple memory buses, but IMHO it's not appropriate for a
> > >   generic API.
> >
> > IMHO we can also use some NULL context to indicate some global, system
> > wide CMA area and again -> in terms of dma-mapping api having a context
> > isn't anything uncommon.
> 
> Please explain the exact requirements that lead you to defining multiple
> contexts. My feeling is that in most cases we don't need them and can
> simply live with a single area. Depending on how obscure the cases are
> where we do need something beyond that, we can then come up with
> special-case solutions for them.

Like it was already stated we need such feature for our multimedia codec
to allocate buffers from different memory banks. I really don't see any
problems with the possibility to have additional cma areas for special
purposes.

> > > * It requires you to hardcode the size in a machine specific source
> file.
> > >   This probably seems to be a natural thing to do when you have worked
> a
> > >   lot on the ARM architecture, but it's really not. We really want to
> > >   get rid of board files and replace them with generic probing based on
> > >   the device tree, and the size of the area is more policy than a
> property
> > >   of the hardware that can be accurately described in the device tree
> or
> > >   a board file.
> >
> > The problem is the fact that right now, we still have board files and we
> > have to live with them for a while (with all advantages and
> disadvantages).
> > I hope that you won't require me to rewrite the whole support for all ARM
> > platforms to get rid of board files to get CMA merged ;)
> 
> Of course not. But we need to know what we want a platform with device
> tree support to look like when it's using CMA, so we don't make it
> harder to change the platforms over than it already is.
> 
> > I see no problem defining CMA areas in device tree, as this is something
> > really specific to particular board configuration.
> 
> The problem with defining CMA areas in the device tree is that it's not
> a property of the hardware, but really policy. The device tree file
> should not contain anything related to a specific operating system
> because you might want to boot something on the board that doesn't
> know about CMA, and even when you only care about using Linux, the
> implementation might change to the point where hardcoded CMA areas
> no longer make sense.

I really doubt that the device tree will carry only system-independent
information. Anyway, the preferred or required memory areas/banks for
buffer allocation is something that is a property of the hardware not
the OS policy.

> IMHO we should first aim for a solution that works almost everywhere
> without the kernel knowing what board it's running on, and then we
> can add quirks for devices that have special requirements. I think
> the situation is similar to the vmalloc virtual address space, which
> normally has a hardcoded size that works almost everywhere, but there
> are certain drivers etc that require much more, or there are situations
> where you want to make it smaller in order to avoid highmem.

I'm trying to create something that will fulfill the requirements of my
hardware, that's why I cannot focus on a generic case only.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
