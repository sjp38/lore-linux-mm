Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 0FA646B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 04:03:24 -0500 (EST)
Date: Tue, 20 Dec 2011 11:03:06 +0200
From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
Message-ID: <20111220090306.GO3677@valkosipuli.localdomain>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <201112071340.35267.arnd@arndb.de>
 <CAKMK7uFQiiUbkU-7c3Os0d0FJNyLbqS2HLPRLy3LGnOoCXV5Pw@mail.gmail.com>
 <201112091413.03736.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201112091413.03736.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Daniel Vetter <daniel@ffwll.ch>, "Semwal, Sumit" <sumit.semwal@ti.com>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Hi Arnd,

On Fri, Dec 09, 2011 at 02:13:03PM +0000, Arnd Bergmann wrote:
> On Thursday 08 December 2011, Daniel Vetter wrote:
> > > c) only allowing streaming mappings, even if those are non-coherent
> > > (requiring strict serialization between CPU (in-kernel) and dma users of
> > > the buffer)
> > 
> > I think only allowing streaming access makes the most sense:
> > - I don't see much (if any need) for the kernel to access a dma_buf -
> > in all current usecases it just contains pixel data and no hw-specific
> > things (like sg tables, command buffers, ..). At most I see the need
> > for the kernel to access the buffer for dma bounce buffers, but that
> > is internal to the dma subsystem (and hence does not need to be
> > exposed).
> > - Userspace can still access the contents through the exporting
> > subsystem (e.g. use some gem mmap support). For efficiency reason gpu
> > drivers are already messing around with cache coherency in a platform
> > specific way (and hence violated the dma api a bit), so we could stuff
> > the mmap coherency in there, too. When we later on extend dma_buf
> > support so that other drivers than the gpu can export dma_bufs, we can
> > then extend the official dma api with already a few drivers with
> > use-patterns around.
> > 
> > But I still think that the kernel must not be required to enforce
> > correct access ordering for the reasons outlined in my other mail.
> 
> I still don't think that's possible. Please explain how you expect
> to change the semantics of the streaming mapping API to allow multiple
> mappers without having explicit serialization points that are visible
> to all users. For simplicity, let's assume a cache coherent system
> with bounce buffers where map() copies the buffer to a dma area
> and unmap() copies it back to regular kernel memory. How does a driver
> know if it can touch the buffer in memory or from DMA at any given
> point in time? Note that this problem is the same as the cache coherency
> problem but may be easier to grasp.

(I'm jumping into the discussion in the middle, and might miss something
that has already been talked about. I still hope what I'm about to say is
relevant. :-))

In subsystems such as V4L2 where drivers deal with such large buffers, the
buffers stay mapped all the time. The user explicitly gives the control of
the buffers to the driver and eventually gets them back. This is already
part of those APIs, whether they're using dma_buf or not. The user could
have, and often has, the same buffers mapped elsewhere.

When it comes to passing these buffers between different hardware devices,
either V4L2 or not, the user might not want to perform extra cache flush
when the buffer memory itself is not being touched by the CPU in the process
at all. I'd consider it impossible for the driver to know how the user space
intends to user the buffer.

Flushing the cache is quite expensive: typically it's the best to flush the
whole data cache when one needs to flush buffers. The V4L2 DQBUF and QBUF
IOCTLs already have flags to suggest special cache handling for buffers.

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
