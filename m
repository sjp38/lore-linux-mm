Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 429B06B005C
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 15:53:58 -0500 (EST)
Date: Sun, 1 Jan 2012 22:53:52 +0200
From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
Message-ID: <20120101205352.GI3677@valkosipuli.localdomain>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <201112091413.03736.arnd@arndb.de>
 <20111220090306.GO3677@valkosipuli.localdomain>
 <201112201536.49754.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201112201536.49754.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Daniel Vetter <daniel@ffwll.ch>, "Semwal, Sumit" <sumit.semwal@ti.com>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, laurent.pinchart@ideasonboard.com

Hi Arnd,

On Tue, Dec 20, 2011 at 03:36:49PM +0000, Arnd Bergmann wrote:
> On Tuesday 20 December 2011, Sakari Ailus wrote:
> > (I'm jumping into the discussion in the middle, and might miss something
> > that has already been talked about. I still hope what I'm about to say is
> > relevant. :-))
> 
> It certainly is relevant.
> 
> > In subsystems such as V4L2 where drivers deal with such large buffers, the
> > buffers stay mapped all the time. The user explicitly gives the control of
> > the buffers to the driver and eventually gets them back. This is already
> > part of those APIs, whether they're using dma_buf or not. The user could
> > have, and often has, the same buffers mapped elsewhere.
> 
> Do you normally use streaming (dma_{map,sync,unmap}_*) or consistent
> (dma_{alloc,free}_*) mappings for this then?

The OMAP 3 ISP driver I'm familiar with uses the OMAP 3 IOMMU / IOVMM API
which is to be replaced by dmabuf. I'm trying to understand how the dma
api / dma-buf should be used to achieve a superset of that functionality.

I think I'm interested in the DMA mapping API. I replied to Sumit's new
patchset, you're cc'd.

> > When it comes to passing these buffers between different hardware devices,
> > either V4L2 or not, the user might not want to perform extra cache flush
> > when the buffer memory itself is not being touched by the CPU in the process
> > at all. I'd consider it impossible for the driver to know how the user space
> > intends to user the buffer.
> 
> The easiest solution to this problem would be to only allow consistent mappings
> to be shared using the dma_buf mechanism. That means we never have to flush.

Do you mean the memory would be non-cacheable? Accessing memory w/o caching
is typically prohibitively expensive, so I don't think this could ever be
the primary means to do the above.

In some cases non-cacheable can perform better, taking into account the time
which is required for flusing the cache and the other consequences of that,
but I still think it's more of an exception than a rule.

> If you don't need the CPU to touch the buffer, that would not have any cost
> at all, we could even have no kernel mapping at all instead of an uncached
> mapping on ARM.

I think in general creating unused mappings should really be avoided.
Creating them consumes time, effort at creation time and possibly also in
cache related operations.

> > Flushing the cache is quite expensive: typically it's the best to flush the
> > whole data cache when one needs to flush buffers. The V4L2 DQBUF and QBUF
> > IOCTLs already have flags to suggest special cache handling for buffers.
> 
> [sidenote: whether it makes sense to flush individual cache lines or the entire
> cache is a decision best left to the architectures. On systems with larger
> caches than on ARM, e.g. 64MB instead of 512KB, you really want to keep
> the cache intact.]

That also depend on the buffer size and what the rest of the system is
doing. I could imagine buffer size, system memory data rate, CPU frequency,
cache line width and the properties of the cache all affect how fast both of
the operations are.

It would probably be possible to perform a heuristic analysis on this at
system startup similar to different software raid algorithm implementations
( e.g. to use MMX or SSE for sw raid).

Some additional complexity will arise from the fact that on some ARM machines
one must know all the CPU MMU mappings pointing to a piece of physical
memory to properly flush them, AFAIR. Naturally a good alternative on such
system is to pperform full dcache flush / cleaning.

Also, cache handling only affects systems without coherent cache. ARM CPUs
are finding their ways to servers as well, but I'd guess it'll still take a
while before we have ARM CPUs with 64 MiB of cache..

Kind regards,

-- 
Sakari Ailus
e-mail: sakari.ailus@iki.fi	jabber/XMPP/Gmail: sailus@retiisi.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
