Date: Wed, 28 Jun 2000 19:45:57 +0100 (BST)
From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: kmap_kiobuf()
In-Reply-To: <20000628190703.F2392@redhat.com>
Message-ID: <Pine.LNX.4.21.0006281930220.987-100000@imladris.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: lord@sgi.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jun 2000, Stephen C. Tweedie wrote:

> The pinning of user buffers is part of the reason we have kiobufs.
> But why do you need to pass it to functions expecting kernel buffers?  

So far I've encountered two places where I've wanted to do this.

First, in copying a packet from userspace to a PCI card, where I have to
have interrupts disabled locally (spin_lock_irq()).

Currently, it does:
	lock_iobuf()
	foreach(page)
		kmap(page) (and store the address in an array)
	spin_lock_irq()
	foreach(page or part thereof)
		memcpy_toio() (using the virtadr returned by kmap)
	spin_unlock_irq()
	foreach(page)
		kunmap(page)
	unlock_iobuf()


The memcpy_toio() has to be split into page-sized chunks, and because we
have to do the kmap from outside the spinlock, I have to keep an array of
virtual addresses.

If it's really that difficult to map them contiguously into VM, I suppose
it can stay the way it is - actually I can probably get away without the
array of virtual addresses by discarding the return value of kmap() and
using page_address() from within the spinlock, can't I?


Secondly, for the character device access to MTD devices. Almost all
access to MTD devices uses kernel-space buffers. I don't really want to
bloat _every_ MTD driver by making it conditionally user/kernel.

The only exception is the direct chardevice access, for which I'm
currently using bounce buffers, but would like to just lock down the pages
and pass a contiguously-mapped VM address instead.

Again, if it's really that much of a problem, I can work round it. It just
seemed like the ideal solution, that's all.

> For any moderately large sized kiobuf, that just means that we risk
> running out of kmaps.  You need to treat kmaps as a scarce resource;
> on PAE36-configured machines we only have 512 of them right now.

I noticed that kmap ptes seem to be allocated from array of static size,
which is different to the method used for vmalloc(). Why is this?

-- 
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
