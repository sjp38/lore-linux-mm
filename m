Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 118516B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 20:24:08 -0500 (EST)
Date: Wed, 16 Dec 2009 02:23:49 +0100
From: "Hans J. Koch" <hjk@linutronix.de>
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
Message-ID: <20091216012347.GD2432@local>
References: <1228379942.5092.14.camel@twins>
 <4B22DD89.2020901@agilent.com>
 <20091214192322.GA3245@bluebox.local>
 <4B27905B.4080006@agilent.com>
 <20091215210002.GA2432@local>
 <4B2803D8.10704@agilent.com>
 <20091215222811.GC2432@local>
 <4B2827E8.60602@agilent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B2827E8.60602@agilent.com>
Sender: owner-linux-mm@kvack.org
To: Earl Chew <earl_chew@agilent.com>
Cc: "Hans J. Koch" <hjk@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, gregkh@suse.de, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 15, 2009 at 04:20:56PM -0800, Earl Chew wrote:
> Hans J. Koch wrote:
> > One example: An A/D converter has an on-chip 32k buffer. It causes an
> > interrupt as soon as the buffer is filled up to a certain high-water mark.
> > Such cases would easily fit into the current UIO system. The UIO core could
> > simply DMA the data to one of the mappings. A new flag for that mapping and
> > a few other changes are all it takes. After the DMA transfer is complete, the
> > interrupt is passed on to userspace, which would find the buffer already
> > filled with the desired data. Just a thought, unfortunately I haven't got
> > such hardware to try it.
> 
> Hans,
> 
> Is this case already covered by the pre-existing UIO_MEM_LOGICAL
> option ?
> 
> I'm thinking that since the memory is statically defined, it can be
> described using one of the existing struct uio_mem mem[] slots in
> struct uio_info and marked as UIO_MEM_LOGICAL.
> 
> The userspace program can map that into its process space using the
> existing mmap() interface.
> 
> What am I missing?

Nothing. The UIO core can map all kinds of memory. I thought about a generic
DMA routine that does the transfer if a flag like UIO_DMA_FROM_DEVICE_PRE_USER
is set.

> 
> > When it comes to dynamically allocated DMA buffers, it might well be possible
> > to add a new directory in sysfs besides the "mem" directory, e.g. something
> > like /sys/class/uio/uioN/dma-mem/. This would save us the trouble of creating
> > a new device. Maybe the example above would better fit in here, too. Who knows.
> 
> I looked at the 2.6.32 source at
> 
> http://lxr.linux.no/#linux+v2.6.32/drivers/uio/uio.c
> 
> and didn't see any reference to /sys/class/uio/uioN/mem .  Perhaps
> you're referring to something new.

Just look at the sysfs files you get when creating a UIO device, then look at
uio.c to see how it is done.

> 
> In any case, I think you're describing adding
> 
> /sys/class/uio/uioN/dma-mem
> 
> as a means to control /dev/uioN .  Presumably writing to
> /sys/class/uio/uioN/dma-mem would create additional dynamic
> DMA buffers.

No, dma-mem would be a directory containing some more attributes. Maybe one
called "create" that allocates a new buffer.

> 
> I can't yet see a way to make this request-response. When requesting
> a dynamic buffer I need to indicate the size that I want, and in
> return I need to obtain a handle to the buffer (either its mapping
> number, address, etc). Once I have that, I can query other
> interesting information (eg its bus address).

Writing the size to that supposed "create" attribute could allocate the
buffer and and create more attributes that contain the information you need.

Thanks,
Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
