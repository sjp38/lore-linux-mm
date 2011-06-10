Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C484D6B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 12:22:32 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
Date: Fri, 10 Jun 2011 18:21:50 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <1307699698-29369-9-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1307699698-29369-9-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201106101821.50437.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>

On Friday 10 June 2011, Marek Szyprowski wrote:
>The Contiguous Memory Allocator is a set of functions that lets
>one initialise a region of memory which then can be used to perform
>allocations of contiguous memory chunks from.
>
>CMA allows for creation of separate contexts. Kernel is allowed to
>allocate movable pages within CMA's managed memory so that it can be
>used for page cache when CMA devices do not use it. On cm_alloc()
>request such pages are migrated out of CMA area to free required
>contiguous block.

Hi Marek,

I'm generally happy with the patches 1 through 7, i.e the heavy lifting
to make contiguous allocations work. Thank you very much for keeping
up the work and submitting these in a good shape.

I do think that we need to discuss the driver-visible API a bit more.
My feeling is that this is rather un-Linux-like and it needs to be
simplified some more. Of course, I don't mind being overruled by the
memory management experts here, or if you can argue that it's really
the right way to do it.

> + * Driver usage
> + *
> + *   CMA should not be used directly by the device drivers. It should
> + *   be considered as helper framework for dma-mapping subsystm and
> + *   respective (platform)bus drivers.
> + *
> + *   The CMA client needs to have a pointer to a CMA context
> + *   represented by a struct cma (which is an opaque data type).
> + *
> + *   Once such pointer is obtained, a caller may allocate contiguous
> + *   memory chunk using the following function:
> + *
> + *     cm_alloc()
> + *
> + *   This function returns a pointer to the first struct page which
> + *   represent a contiguous memory chunk.  This pointer
> + *   may be used with the following function:
> + *
> + *     cm_free()    -- frees allocated contiguous memory

Please explain why you want a new top-level API here. I think it
would be much nicer if a device driver could simply call 
alloc_pages(..., GFP_CMA) or similar, where all the complexity
in here gets hidden behind a conditional deep inside of the
page allocator.

Evidently, the two functions you describe here have an extra argument
for the context. Can you elaborate why that is really needed? What
is the specific requirement to have multiple such contexts in one
system and what is the worst-case effect that you would get when
the interface is simplified to have only one for all devices?

Alternatively, would it be possible to provide the cm_alloc/cm_free
functions only as backing to the dma mapping API and not export them
as a generic device driver interface?

> + * Platform/machine integration
> + *
> + *   CMA context must be created on platform or machine initialisation
> + *   and passed to respective subsystem that will be a client for CMA.
> + *   The latter may be done by a global variable or some filed in
> + *   struct device.  For the former CMA provides the following functions:
> + *
> + *     cma_init_migratetype()
> + *     cma_reserve()
> + *     cma_create()
> + *
> + *   The first one initialises a portion of reserved memory so that it
> + *   can be used with CMA.  The second first tries to reserve memory
> + *   (using memblock) and then initialise it.
> + *
> + *   The cma_reserve() function must be called when memblock is still
> + *   operational and reserving memory with it is still possible.  On
> + *   ARM platform the "reserve" machine callback is a perfect place to
> + *   call it.
> + *
> + *   The last function creates a CMA context on a range of previously
> + *   initialised memory addresses.  Because it uses kmalloc() it needs
> + *   to be called after SLAB is initialised.
> + */

This interface looks flawed to me for multiple reasons:

* It requires you to call three distinct functions in order to do one
  thing, and they all take the same arguments (more or less). Why not
  have one function call at the latest possible point where you can
  still change the memory attributes, and have everything else
  happen automatically?

* It requires you to pass the exact location of the area. I can see why
  you want that on certain machines that require DMA areas to be spread
  across multiple memory buses, but IMHO it's not appropriate for a
  generic API.

* It requires you to hardcode the size in a machine specific source file.
  This probably seems to be a natural thing to do when you have worked a
  lot on the ARM architecture, but it's really not. We really want to
  get rid of board files and replace them with generic probing based on
  the device tree, and the size of the area is more policy than a property
  of the hardware that can be accurately described in the device tree or
  a board file.

I'm sure that we can find a solution for all of these problems, it just
takes a few good ideas. Especially for the last point, I don't have a
better suggestion yet, but hopefully someone else can come up with one.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
