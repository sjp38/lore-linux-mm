Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 48AAA6B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:13:19 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Date: Fri, 9 Dec 2011 14:13:03 +0000
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com> <201112071340.35267.arnd@arndb.de> <CAKMK7uFQiiUbkU-7c3Os0d0FJNyLbqS2HLPRLy3LGnOoCXV5Pw@mail.gmail.com>
In-Reply-To: <CAKMK7uFQiiUbkU-7c3Os0d0FJNyLbqS2HLPRLy3LGnOoCXV5Pw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201112091413.03736.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: "Semwal, Sumit" <sumit.semwal@ti.com>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Thursday 08 December 2011, Daniel Vetter wrote:
> > c) only allowing streaming mappings, even if those are non-coherent
> > (requiring strict serialization between CPU (in-kernel) and dma users of
> > the buffer)
> 
> I think only allowing streaming access makes the most sense:
> - I don't see much (if any need) for the kernel to access a dma_buf -
> in all current usecases it just contains pixel data and no hw-specific
> things (like sg tables, command buffers, ..). At most I see the need
> for the kernel to access the buffer for dma bounce buffers, but that
> is internal to the dma subsystem (and hence does not need to be
> exposed).
> - Userspace can still access the contents through the exporting
> subsystem (e.g. use some gem mmap support). For efficiency reason gpu
> drivers are already messing around with cache coherency in a platform
> specific way (and hence violated the dma api a bit), so we could stuff
> the mmap coherency in there, too. When we later on extend dma_buf
> support so that other drivers than the gpu can export dma_bufs, we can
> then extend the official dma api with already a few drivers with
> use-patterns around.
> 
> But I still think that the kernel must not be required to enforce
> correct access ordering for the reasons outlined in my other mail.

I still don't think that's possible. Please explain how you expect
to change the semantics of the streaming mapping API to allow multiple
mappers without having explicit serialization points that are visible
to all users. For simplicity, let's assume a cache coherent system
with bounce buffers where map() copies the buffer to a dma area
and unmap() copies it back to regular kernel memory. How does a driver
know if it can touch the buffer in memory or from DMA at any given
point in time? Note that this problem is the same as the cache coherency
problem but may be easier to grasp.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
