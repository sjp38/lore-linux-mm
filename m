Date: Wed, 23 May 2001 17:45:47 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Running out of vmalloc space
Message-ID: <20010523174547.G8080@redhat.com>
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com> <3B045546.312BA42E@fc.hp.com> <3B0AF30D.8D25806A@fc.hp.com> <20010523103518.X8080@redhat.com> <3B0BE1D4.59BBB28@fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B0BE1D4.59BBB28@fc.hp.com>; from dp@fc.hp.com on Wed, May 23, 2001 at 10:14:12AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, May 23, 2001 at 10:14:12AM -0600, David Pinedo wrote:

> The graphics kernel driver needs to access the device, so it needs to be
> mapped into kernel vm space. I might be able to get away with not
> mapping all of the device. For example, the driver only accesses a
> subset of the registers on the graphics board, and doesn't access the
> framebuffer. I have a customer waiting for other bug fixes, so such a
> change would have to take a lower priority.

That's the core of the issue.  I can't see why you need direct access
to all 64MB of device address space.  Doing an ioremap() of the
relevant register space is fine.  It's what PCI device drivers are
expected to do, and it will cooperate with other drivers.  Mapping the
entire framebuffer is excessive.

> I could easily imagine a scenario on a future graphics device where the
> kernel driver accesses a large percentage of the address space of the
> device, so the demand on kernel vm memory space would be high. As
> framebuffers get larger in the future, the need for kernel vm space will
> also increase.

I remain to be convinced.  WHY does the kernel need to access the
framebuffer at all?  The X server can map the entire frame
buffer into its own VA without it being in the kernel.  The kernel can
set up DMA into the framebuffer without having that memory mapped
*anywhere*.  It can also talk to the acceleration engine without
having the framebuffer mapped.  I can't see a justification for having
the whole framebuffer kernel-mapped here.

Indeed, the X server is sufficiently performance-critical that you
usually want to avoid the kernel accessing the framebuffer at all: far
better to do it in the X server and avoid any protection switches into
the kernel domain.  

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
