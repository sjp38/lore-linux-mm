Date: Thu, 29 Jun 2000 10:09:33 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kmap_kiobuf()
Message-ID: <20000629100933.A3473@redhat.com>
References: <20000628190703.F2392@redhat.com> <Pine.LNX.4.21.0006281930220.987-100000@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0006281930220.987-100000@imladris.demon.co.uk>; from dwmw2@infradead.org on Wed, Jun 28, 2000 at 07:45:57PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, lord@sgi.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 28, 2000 at 07:45:57PM +0100, David Woodhouse wrote:
> On Wed, 28 Jun 2000, Stephen C. Tweedie wrote:
> 
> > The pinning of user buffers is part of the reason we have kiobufs.
> > But why do you need to pass it to functions expecting kernel buffers?  
> 
> So far I've encountered two places where I've wanted to do this.
> 
> First, in copying a packet from userspace to a PCI card, where I have to
> have interrupts disabled locally (spin_lock_irq()).

How much data is involved?

If it's not too much, then your current scheme looks like the right
way to do this.  You really should try to keep things per-page and not
rely on the pages being contiguous, since using the kernel's vmalloc
area for contiguifying the pages will be enormously expensive on SMP.
I can certainly add kiobuf support routines for kmapping and
memcpy()ing kiobuf pages to the kiobuf core patches to clean the code
a bit.

> If it's really that difficult to map them contiguously into VM, I suppose
> it can stay the way it is - actually I can probably get away without the
> array of virtual addresses by discarding the return value of kmap() and
> using page_address() from within the spinlock, can't I?

Yes, that should work fine.

> Secondly, for the character device access to MTD devices. Almost all
> access to MTD devices uses kernel-space buffers. I don't really want to
> bloat _every_ MTD driver by making it conditionally user/kernel.
> 
> The only exception is the direct chardevice access, for which I'm
> currently using bounce buffers, but would like to just lock down the pages
> and pass a contiguously-mapped VM address instead.

Why does it need to be *contiguous*???  The right way to code this is
most definitely in terms of kiobufs.  That's basically the only way
we'll support user-space direct access.  If I can give you a
memcpy_to_kiovec() and memcpy_from_kiovec() patch, then that gives you
a canonical way of representing buffers from either user or kernel
space without any assumption at all that the pages are contiguous, and
you get direct IO for free.

The whole point of kiobufs is to abstract away the source of the
pages.  You don't have to know whether the pages were originally
kernel or user space.

> I noticed that kmap ptes seem to be allocated from array of static size,
> which is different to the method used for vmalloc(). Why is this?

vmalloc() and kmap() are meant for completely different purposes.
vmalloc() is designed for long-term persistent regions (such as
loadable moules).  However, it is slow.  kmap() is very fast, but is
designed for transient mappings of individual pages.  The fixed kmap
pte list is used as a ring buffer.  If we kmap a page twice without
wrapping, we can reuse the old virtual address of the page, so it's
pretty fast to repeatedly kmap and kunmap a single page (there's a
spinlock cost but not much more).  

The big advantage of kmap is that we only have to do an SMP TLB IPI
once every wrap of the kmap ring buffer.  vmalloc incurs that cost
every time.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
