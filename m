Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D513C6B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 08:35:10 -0500 (EST)
Message-ID: <4B27905B.4080006@agilent.com>
Date: Tue, 15 Dec 2009 05:34:19 -0800
From: Earl Chew <earl_chew@agilent.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
References: <1228379942.5092.14.camel@twins> <4B22DD89.2020901@agilent.com> <20091214192322.GA3245@bluebox.local>
In-Reply-To: <20091214192322.GA3245@bluebox.local>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Hans J. Koch" <hjk@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, gregkh@suse.de, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Hans,

Thanks for the considered reply.


Hans J. Koch wrote:
> The general thing is this: The UIO core supports only static mappings.
> The possible number of mappings is usually set at compile time or module
> load time and is currently limited to MAX_UIO_MAPS (== 5). This number
> is usually sufficient for devices like PCI cards, which have a limited
> number of mappings, too. All drivers currently in the kernel only need
> one or two.


I'd like to proceed by changing struct uio_mem [MAX_UIO_MAPS] to a
linked list.

The driver code in uio_find_mem_index(), uio_dev_add_attributes(), etc,
iterate through the (small) array anyway, and the list space and
performance overhead is not significant for the cases mentioned.

Such a change would make it easier to track dynamically allocated
regions as well as pre-allocated mapping regions in the same data
structure.

It also plays more nicely into the next part ...

> The current implementation of the UIO core is simply not made for
> dynamic allocation of an unlimited amount of new mappings at runtime. As
> we have seen in this patch, it needs raping of a documented kernel
> interface to userspace. This is not acceptable.
> 
> So the easiest correct solution is to create a new device (e.g.
> /dev/uioN-dma, as Peter suggested). It should only be created for a UIO
> driver if it has a certain flag set, something like UIO_NEEDS_DYN_DMA_ALLOC.

An approach which would play better with our existing codebase would
be to introduce a two-step ioctl-mmap.

a. Use an ioctl() to allocate the DMA buffer. The ioctl returns two
   things:

	1.  A mapping (page) number
	2.  A physical (bus) address


b. Use the existing mmap() interface to gain access to the
   DMA buffer allocated in (a). Clients would invoke mmap()
   and use the mapping (page) number returned in (a) to
   obtain userspace access to the DMA buffer.


I think that the second step (b) would play nicely with the existing
mmap() interface exposed by the UIO driver.


Using an ioctl() provides a cleaner way to return the physical
(bus) address of the DMA buffer.


Existing client code that is not interested in DMA buffers do
not incur a penalty because it will not invoke the new ioctl().


Earl


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
