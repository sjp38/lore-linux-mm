Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0AE8A6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:06:16 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LMQ0044U1ADJ4@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 13 Jun 2011 10:06:13 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMQ00DIV1ACC2@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 13 Jun 2011 10:06:12 +0100 (BST)
Date: Mon, 13 Jun 2011 11:05:44 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
In-reply-to: <201106101821.50437.arnd@arndb.de>
Message-id: <006a01cc29a9$1394c330$3abe4990$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <1307699698-29369-9-git-send-email-m.szyprowski@samsung.com>
 <201106101821.50437.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

Hello,

On Friday, June 10, 2011 6:22 PM Arnd Bergmann wrote:

> On Friday 10 June 2011, Marek Szyprowski wrote:
> >The Contiguous Memory Allocator is a set of functions that lets
> >one initialise a region of memory which then can be used to perform
> >allocations of contiguous memory chunks from.
> >
> >CMA allows for creation of separate contexts. Kernel is allowed to
> >allocate movable pages within CMA's managed memory so that it can be
> >used for page cache when CMA devices do not use it. On cm_alloc()
> >request such pages are migrated out of CMA area to free required
> >contiguous block.
> 
> Hi Marek,
> 
> I'm generally happy with the patches 1 through 7, i.e the heavy lifting
> to make contiguous allocations work. Thank you very much for keeping
> up the work and submitting these in a good shape.
> 
> I do think that we need to discuss the driver-visible API a bit more.
> My feeling is that this is rather un-Linux-like and it needs to be
> simplified some more. Of course, I don't mind being overruled by the
> memory management experts here, or if you can argue that it's really
> the right way to do it.

Thanks for your comments!
 
> > + * Driver usage
> > + *
> > + *   CMA should not be used directly by the device drivers. It should
> > + *   be considered as helper framework for dma-mapping subsystm and
> > + *   respective (platform)bus drivers.
> > + *
> > + *   The CMA client needs to have a pointer to a CMA context
> > + *   represented by a struct cma (which is an opaque data type).
> > + *
> > + *   Once such pointer is obtained, a caller may allocate contiguous
> > + *   memory chunk using the following function:
> > + *
> > + *     cm_alloc()
> > + *
> > + *   This function returns a pointer to the first struct page which
> > + *   represent a contiguous memory chunk.  This pointer
> > + *   may be used with the following function:
> > + *
> > + *     cm_free()    -- frees allocated contiguous memory
> 
> Please explain why you want a new top-level API here. I think it
> would be much nicer if a device driver could simply call
> alloc_pages(..., GFP_CMA) or similar, where all the complexity
> in here gets hidden behind a conditional deep inside of the
> page allocator.
> 
> Evidently, the two functions you describe here have an extra argument
> for the context. Can you elaborate why that is really needed? What
> is the specific requirement to have multiple such contexts in one
> system and what is the worst-case effect that you would get when
> the interface is simplified to have only one for all devices?
> 
> Alternatively, would it be possible to provide the cm_alloc/cm_free
> functions only as backing to the dma mapping API and not export them
> as a generic device driver interface?

cm_alloc/free are definitely not meant to be called from device drivers.
They should be only considered as a backend for dma-mapping.

'Raw' contiguous memory block doesn't really make sense for the device
drivers. What the drivers require is a contiguous memory block that is
somehow mapped into respective bus address space, so dma-mapping 
framework is the right interface.

alloc_pages(..., GFP_CMA) looks nice but in fact it is really impractical.
The driver will need to map such buffer to dma context anyway, so imho
dma_alloc_attributed() will give the drivers much more flexibility. In
terms of dma-mapping the context argument isn't anything odd. 

If possible I would like to make cma something similar to 
declare_dma_coherent()&friends, so the board/platform/bus startup code
will just call declare_dma_contiguous() to enable support for cma for
particular devices.

> > + * Platform/machine integration
> > + *
> > + *   CMA context must be created on platform or machine initialisation
> > + *   and passed to respective subsystem that will be a client for CMA.
> > + *   The latter may be done by a global variable or some filed in
> > + *   struct device.  For the former CMA provides the following
> functions:
> > + *
> > + *     cma_init_migratetype()
> > + *     cma_reserve()
> > + *     cma_create()
> > + *
> > + *   The first one initialises a portion of reserved memory so that it
> > + *   can be used with CMA.  The second first tries to reserve memory
> > + *   (using memblock) and then initialise it.
> > + *
> > + *   The cma_reserve() function must be called when memblock is still
> > + *   operational and reserving memory with it is still possible.  On
> > + *   ARM platform the "reserve" machine callback is a perfect place to
> > + *   call it.
> > + *
> > + *   The last function creates a CMA context on a range of previously
> > + *   initialised memory addresses.  Because it uses kmalloc() it needs
> > + *   to be called after SLAB is initialised.
> > + */
> 
> This interface looks flawed to me for multiple reasons:
> 
> * It requires you to call three distinct functions in order to do one
>   thing, and they all take the same arguments (more or less). Why not
>   have one function call at the latest possible point where you can
>   still change the memory attributes, and have everything else
>   happen automatically?

Initialization part will be definitely simplified, I must confess that I
was in hurry to post the patches before the weekend and just forgot to
cleanup this part...
 
> * It requires you to pass the exact location of the area. I can see why
>   you want that on certain machines that require DMA areas to be spread
>   across multiple memory buses, but IMHO it's not appropriate for a
>   generic API.

IMHO we can also use some NULL context to indicate some global, system 
wide CMA area and again -> in terms of dma-mapping api having a context 
isn't anything uncommon.
 
> * It requires you to hardcode the size in a machine specific source file.
>   This probably seems to be a natural thing to do when you have worked a
>   lot on the ARM architecture, but it's really not. We really want to
>   get rid of board files and replace them with generic probing based on
>   the device tree, and the size of the area is more policy than a property
>   of the hardware that can be accurately described in the device tree or
>   a board file.

The problem is the fact that right now, we still have board files and we
have to live with them for a while (with all advantages and disadvantages).
I hope that you won't require me to rewrite the whole support for all ARM 
platforms to get rid of board files to get CMA merged ;)

I see no problem defining CMA areas in device tree, as this is something
really specific to particular board configuration. 

> I'm sure that we can find a solution for all of these problems, it just
> takes a few good ideas. Especially for the last point, I don't have a
> better suggestion yet, but hopefully someone else can come up with one.

I hope we will manage to get agreement :)

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
