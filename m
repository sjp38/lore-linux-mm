Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 92A5D6B00EA
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 09:50:15 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
Date: Tue, 14 Jun 2011 15:49:29 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <201106101821.50437.arnd@arndb.de> <006a01cc29a9$1394c330$3abe4990$%szyprowski@samsung.com>
In-Reply-To: <006a01cc29a9$1394c330$3abe4990$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106141549.29315.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

On Monday 13 June 2011, Marek Szyprowski wrote:
> cm_alloc/free are definitely not meant to be called from device drivers.
> They should be only considered as a backend for dma-mapping.
>
> 'Raw' contiguous memory block doesn't really make sense for the device
> drivers. What the drivers require is a contiguous memory block that is
> somehow mapped into respective bus address space, so dma-mapping 
> framework is the right interface.
> 
> alloc_pages(..., GFP_CMA) looks nice but in fact it is really impractical.
> The driver will need to map such buffer to dma context anyway, so imho
> dma_alloc_attributed() will give the drivers much more flexibility. In
> terms of dma-mapping the context argument isn't anything odd. 

Ok.

> If possible I would like to make cma something similar to 
> declare_dma_coherent()&friends, so the board/platform/bus startup code
> will just call declare_dma_contiguous() to enable support for cma for
> particular devices.

Sounds good, I like that.

> > This interface looks flawed to me for multiple reasons:
> > 
> > * It requires you to call three distinct functions in order to do one
> >   thing, and they all take the same arguments (more or less). Why not
> >   have one function call at the latest possible point where you can
> >   still change the memory attributes, and have everything else
> >   happen automatically?
> 
> Initialization part will be definitely simplified, I must confess that I
> was in hurry to post the patches before the weekend and just forgot to
> cleanup this part...

Fair enough. In cases like this, it's often good to add a TODO section
to the patch description, or a FIXME comment in the patch itself.

> > * It requires you to pass the exact location of the area. I can see why
> >   you want that on certain machines that require DMA areas to be spread
> >   across multiple memory buses, but IMHO it's not appropriate for a
> >   generic API.
> 
> IMHO we can also use some NULL context to indicate some global, system 
> wide CMA area and again -> in terms of dma-mapping api having a context 
> isn't anything uncommon.

Please explain the exact requirements that lead you to defining multiple
contexts. My feeling is that in most cases we don't need them and can
simply live with a single area. Depending on how obscure the cases are
where we do need something beyond that, we can then come up with
special-case solutions for them.

> > * It requires you to hardcode the size in a machine specific source file.
> >   This probably seems to be a natural thing to do when you have worked a
> >   lot on the ARM architecture, but it's really not. We really want to
> >   get rid of board files and replace them with generic probing based on
> >   the device tree, and the size of the area is more policy than a property
> >   of the hardware that can be accurately described in the device tree or
> >   a board file.
> 
> The problem is the fact that right now, we still have board files and we
> have to live with them for a while (with all advantages and disadvantages).
> I hope that you won't require me to rewrite the whole support for all ARM 
> platforms to get rid of board files to get CMA merged ;)

Of course not. But we need to know what we want a platform with device
tree support to look like when it's using CMA, so we don't make it
harder to change the platforms over than it already is.

> I see no problem defining CMA areas in device tree, as this is something
> really specific to particular board configuration. 

The problem with defining CMA areas in the device tree is that it's not
a property of the hardware, but really policy. The device tree file
should not contain anything related to a specific operating system
because you might want to boot something on the board that doesn't
know about CMA, and even when you only care about using Linux, the
implementation might change to the point where hardcoded CMA areas
no longer make sense.

IMHO we should first aim for a solution that works almost everywhere
without the kernel knowing what board it's running on, and then we
can add quirks for devices that have special requirements. I think
the situation is similar to the vmalloc virtual address space, which
normally has a hardcoded size that works almost everywhere, but there
are certain drivers etc that require much more, or there are situations
where you want to make it smaller in order to avoid highmem. 

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
