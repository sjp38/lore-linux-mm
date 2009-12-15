Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BEF936B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 17:28:31 -0500 (EST)
Date: Tue, 15 Dec 2009 23:28:11 +0100
From: "Hans J. Koch" <hjk@linutronix.de>
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
Message-ID: <20091215222811.GC2432@local>
References: <1228379942.5092.14.camel@twins>
 <4B22DD89.2020901@agilent.com>
 <20091214192322.GA3245@bluebox.local>
 <4B27905B.4080006@agilent.com>
 <20091215210002.GA2432@local>
 <4B2803D8.10704@agilent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B2803D8.10704@agilent.com>
Sender: owner-linux-mm@kvack.org
To: Earl Chew <earl_chew@agilent.com>
Cc: "Hans J. Koch" <hjk@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, gregkh@suse.de, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 15, 2009 at 01:47:04PM -0800, Earl Chew wrote:
> Hans J. Koch wrote:
> > Sorry, I think I wasn't clear enough: The current interface for static
> > mappings shouldn't be changed. Dynamically added mappings need a new
> > interface.
> 
> Thanks for the quick reply.
> 
> Are you ok with changes to the (internal) struct uio_device ?

Hey, we live in a free world :)
Anything can be changed as long as it's a technically sensible solution and
doesn't break existing interfaces to userspace.

The DMA-for-UIO thing is something that shouldn't be taken lightly. If we
define an interface for that, it should cover all possible applications.
There are not only devices that need to allocate new DMA buffers at runtime,
but also devices which could very well live with one or two statically
allocated DMA buffers. We need to cover all these cases.

One example: An A/D converter has an on-chip 32k buffer. It causes an
interrupt as soon as the buffer is filled up to a certain high-water mark.
Such cases would easily fit into the current UIO system. The UIO core could
simply DMA the data to one of the mappings. A new flag for that mapping and
a few other changes are all it takes. After the DMA transfer is complete, the
interrupt is passed on to userspace, which would find the buffer already
filled with the desired data. Just a thought, unfortunately I haven't got
such hardware to try it.

When it comes to dynamically allocated DMA buffers, it might well be possible
to add a new directory in sysfs besides the "mem" directory, e.g. something
like /sys/class/uio/uioN/dma-mem/. This would save us the trouble of creating
a new device. Maybe the example above would better fit in here, too. Who knows.

These are only some thoughts, I haven't got any DMA capable hardware to deal
with ATM.

You certainly notice that there are important design decisions to make.
Remember that once a kernel interface to userspace exists, it is etched in
stone forever.

Thanks,
Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
