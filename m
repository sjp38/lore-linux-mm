Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 94FA56B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 10:37:02 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Date: Tue, 20 Dec 2011 15:36:49 +0000
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com> <201112091413.03736.arnd@arndb.de> <20111220090306.GO3677@valkosipuli.localdomain>
In-Reply-To: <20111220090306.GO3677@valkosipuli.localdomain>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201112201536.49754.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sakari Ailus <sakari.ailus@iki.fi>
Cc: Daniel Vetter <daniel@ffwll.ch>, "Semwal, Sumit" <sumit.semwal@ti.com>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tuesday 20 December 2011, Sakari Ailus wrote:
> (I'm jumping into the discussion in the middle, and might miss something
> that has already been talked about. I still hope what I'm about to say is
> relevant. :-))

It certainly is relevant.

> In subsystems such as V4L2 where drivers deal with such large buffers, the
> buffers stay mapped all the time. The user explicitly gives the control of
> the buffers to the driver and eventually gets them back. This is already
> part of those APIs, whether they're using dma_buf or not. The user could
> have, and often has, the same buffers mapped elsewhere.

Do you normally use streaming (dma_{map,sync,unmap}_*) or consistent
(dma_{alloc,free}_*) mappings for this then?

> When it comes to passing these buffers between different hardware devices,
> either V4L2 or not, the user might not want to perform extra cache flush
> when the buffer memory itself is not being touched by the CPU in the process
> at all. I'd consider it impossible for the driver to know how the user space
> intends to user the buffer.

The easiest solution to this problem would be to only allow consistent mappings
to be shared using the dma_buf mechanism. That means we never have to flush.
If you don't need the CPU to touch the buffer, that would not have any cost
at all, we could even have no kernel mapping at all instead of an uncached
mapping on ARM.

> Flushing the cache is quite expensive: typically it's the best to flush the
> whole data cache when one needs to flush buffers. The V4L2 DQBUF and QBUF
> IOCTLs already have flags to suggest special cache handling for buffers.

[sidenote: whether it makes sense to flush individual cache lines or the entire
cache is a decision best left to the architectures. On systems with larger
caches than on ARM, e.g. 64MB instead of 512KB, you really want to keep
the cache intact.]

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
