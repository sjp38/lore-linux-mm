Message-ID: <40CF5D1B.6000302@pacbell.net>
Date: Tue, 15 Jun 2004 13:33:31 -0700
From: David Brownell <david-b@pacbell.net>
MIME-Version: 1.0
Subject: Re: [linux-usb-devel] Patch for UHCI driver (from kernel 2.6.6).
References: <Pine.LNX.4.44L0.0406151511150.7814-100000@ida.rowland.org>
In-Reply-To: <Pine.LNX.4.44L0.0406151511150.7814-100000@ida.rowland.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Nicolas DET <nd@bplan-gmbh.de>, USB development list <linux-usb-devel@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>That text strikes me as rather ambiguous.  ...
>>>...  It doesn't specify what happens to the other data
>>>bytes in the same cache line which _weren't_ written -- maybe they'll be
>>>messed up.
>>
>>Actually I thought it was quite explicit:  "without having
>>to worry about caching effects".  What you described is
>>clearly a caching effect:  caused by caching.  And maybe
>>fixable by appropriate cache-flushing, or other cache-aware
>>driver logic ... making it "worry about caching effects".
>>Like the patch from Nicolas.
> 
> 
> No, you misunderstood what I wrote and misinterpreted the text.  The text 
> says:
> 
> 	... a write by either the device or the processor
> 	can immediately be read by the processor or device 
> 	without having to worry about caching effects.
> 
> This means that when you read _the data that was written_ you don't have 
> to worry about caching effects.

It doesn't limit the "without having to worry" to just the bytes
written.  And the rest of that API spec doesn't even suggest that
there might be an issue there.  I think you're trying to read
things into that text that aren't there.

On the other hand, see dma_alloc_noncoherent() ... I hope you'll
agree that the specification for "noncoherent" memory clearly
expects those caching effects to exist.  It specifically says
that you need to understand cache line sharing issues to use the
API correctly, and even exposes the cache line size.

It seems most likely to me that this particular PPC hardware
can't implement dma_alloc_coherent(), and the code implementing
that routine should be called dma_alloc_noncoherent() instead.



>>Maybe what we really need is patches to make USB switch to
>>dma_alloc_noncoherent(), checking dma_is_consistent() to
>>see whether a given QH/TD/ED/iTD/sITD/FSTN/... needs to be
>>explicitly flushed from cpu cache before handover to HC.
> 
> 
> Will flushing the CPU cache really solve these problems?  If the hardware

That's why we need PPC expertise applied here.  Nicolas didn't
seem to have answers for all the questions I was asking.


> that handles the DMA transfer always writes an entire cache line, and if
> it doesn't read the old contents before doing a partial write, then data
> stored in the same cache line as a DMA buffer is subject to overwriting
> whether it has been flushed or not.

Addressed by using dma_alloc_noncoherent() and dma_cache_sync(); yes?

- Dave




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
