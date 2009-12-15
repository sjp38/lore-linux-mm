Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 118B16B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 16:01:11 -0500 (EST)
Date: Tue, 15 Dec 2009 22:00:03 +0100
From: "Hans J. Koch" <hjk@linutronix.de>
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
Message-ID: <20091215210002.GA2432@local>
References: <1228379942.5092.14.camel@twins>
 <4B22DD89.2020901@agilent.com>
 <20091214192322.GA3245@bluebox.local>
 <4B27905B.4080006@agilent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B27905B.4080006@agilent.com>
Sender: owner-linux-mm@kvack.org
To: Earl Chew <earl_chew@agilent.com>
Cc: "Hans J. Koch" <hjk@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, gregkh@suse.de, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 15, 2009 at 05:34:19AM -0800, Earl Chew wrote:
> Hans,

Hi Earl,

> 
> Thanks for the considered reply.
> 
> 
> Hans J. Koch wrote:
> > The general thing is this: The UIO core supports only static mappings.
> > The possible number of mappings is usually set at compile time or module
> > load time and is currently limited to MAX_UIO_MAPS (== 5). This number
> > is usually sufficient for devices like PCI cards, which have a limited
> > number of mappings, too. All drivers currently in the kernel only need
> > one or two.
> 
> 
> I'd like to proceed by changing struct uio_mem [MAX_UIO_MAPS] to a
> linked list.
> 
> The driver code in uio_find_mem_index(), uio_dev_add_attributes(), etc,
> iterate through the (small) array anyway, and the list space and
> performance overhead is not significant for the cases mentioned.
> 
> Such a change would make it easier to track dynamically allocated
> regions as well as pre-allocated mapping regions in the same data
> structure.

Sorry, I think I wasn't clear enough: The current interface for static
mappings shouldn't be changed. Dynamically added mappings need a new
interface.

> 
> It also plays more nicely into the next part ...
> 
> > The current implementation of the UIO core is simply not made for
> > dynamic allocation of an unlimited amount of new mappings at runtime. As
> > we have seen in this patch, it needs raping of a documented kernel
> > interface to userspace. This is not acceptable.
> > 
> > So the easiest correct solution is to create a new device (e.g.
> > /dev/uioN-dma, as Peter suggested). It should only be created for a UIO
> > driver if it has a certain flag set, something like UIO_NEEDS_DYN_DMA_ALLOC.
> 
> An approach which would play better with our existing codebase would
> be to introduce a two-step ioctl-mmap.
> 
> a. Use an ioctl() to allocate the DMA buffer. The ioctl returns two
>    things:

No. We don't want any new ioctls in the kernel.

> 
> 	1.  A mapping (page) number
> 	2.  A physical (bus) address
> 
> 
> b. Use the existing mmap() interface to gain access to the
>    DMA buffer allocated in (a). Clients would invoke mmap()
>    and use the mapping (page) number returned in (a) to
>    obtain userspace access to the DMA buffer.
> 
> 
> I think that the second step (b) would play nicely with the existing
> mmap() interface exposed by the UIO driver.

The existing interface is for static mappings only.

> 
> 
> Using an ioctl() provides a cleaner way to return the physical
> (bus) address of the DMA buffer.

ioctl() is out of fashion today. We have sysfs. Note that ioctls are neither
typesafe nor much faster than sysfs.

> 
> 
> Existing client code that is not interested in DMA buffers do
> not incur a penalty because it will not invoke the new ioctl().

What about userspace tools that rely on the fact that the number of mappings
for a UIO device cannot change? This is a documented property of UIO.

Dynamically allocated mappings really call for a new device as Peter suggested.
In fact, that would make life much easier for you. Since your the one who
implements that stuff, your free to define a new interface. Surely that new
interface will be discussed and rejected two or three times, but in the end
we'll have a nice interface that allows UIO to use DMA, even with dyynamically
allocated buffers.

Use that freedom and create a new device with a new interface. There's no
point in trying to change existing and well documented interfaces to userspace.

Thanks,
Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
