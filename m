Date: Tue, 15 Jun 2004 15:35:03 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-usb-devel] Patch for UHCI driver (from kernel 2.6.6).
In-Reply-To: <40CF2CF5.5000209@pacbell.net>
Message-ID: <Pine.LNX.4.44L0.0406151511150.7814-100000@ida.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Brownell <david-b@pacbell.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Nicolas DET <nd@bplan-gmbh.de>, USB development list <linux-usb-devel@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2004, David Brownell wrote:

> Alan Stern wrote:
> > On Mon, 14 Jun 2004, David Brownell wrote:
> > 
> > 
> >>Seems like the dma_alloc_coherent() API spec can't be
> >>implemented on such machines then, since it's defined
> >>to return memory(*) such that:
> >>
> >>   ... a write by either the device or the processor
> >>   can immediately be read by the processor or device
> >>   without having to worry about caching effects.
> >>
> >>...
> > 
> > That text strikes me as rather ambiguous.  ...
> > ...  It doesn't specify what happens to the other data
> > bytes in the same cache line which _weren't_ written -- maybe they'll be
> > messed up.
> 
> Actually I thought it was quite explicit:  "without having
> to worry about caching effects".  What you described is
> clearly a caching effect:  caused by caching.  And maybe
> fixable by appropriate cache-flushing, or other cache-aware
> driver logic ... making it "worry about caching effects".
> Like the patch from Nicolas.

No, you misunderstood what I wrote and misinterpreted the text.  The text 
says:

	... a write by either the device or the processor
	can immediately be read by the processor or device 
	without having to worry about caching effects.

This means that when you read _the data that was written_ you don't have 
to worry about caching effects.

This does _not_ mean that when you read _other data stored nearby_ you
don't have to worry about caching effects.

That is the problem Nicolas wants to solve.  According to him, the problem 
occurs not when reading the data stored by the device but when reading 
data stored nearby by the CPU and mangled during the DMA transfer.

Now maybe the intention behind "consistent" or "coherent" mappings is that 
the memory really will behave as one would naively expect, and a write to 
one portion of a cache line won't mess up the contents of the remainder.  
But the text doesn't say this.  That's why I said it is ambiguous.

> Maybe what we really need is patches to make USB switch to
> dma_alloc_noncoherent(), checking dma_is_consistent() to
> see whether a given QH/TD/ED/iTD/sITD/FSTN/... needs to be
> explicitly flushed from cpu cache before handover to HC.

Will flushing the CPU cache really solve these problems?  If the hardware
that handles the DMA transfer always writes an entire cache line, and if
it doesn't read the old contents before doing a partial write, then data
stored in the same cache line as a DMA buffer is subject to overwriting
whether it has been flushed or not.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
