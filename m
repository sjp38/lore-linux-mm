Date: Tue, 15 Jun 2004 12:35:25 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-usb-devel] Patch for UHCI driver (from kernel 2.6.6).
In-Reply-To: <40CE2E24.5060207@pacbell.net>
Message-ID: <Pine.LNX.4.44L0.0406151221220.1960-100000@ida.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Brownell <david-b@pacbell.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Nicolas DET <nd@bplan-gmbh.de>, USB development list <linux-usb-devel@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 2004, David Brownell wrote:

> Seems like the dma_alloc_coherent() API spec can't be
> implemented on such machines then, since it's defined
> to return memory(*) such that:
> 
>    ... a write by either the device or the processor
>    can immediately be read by the processor or device
>    without having to worry about caching effects.
> 
> Seems like the documentation should change to explain
> under what circumstances "coherent" memory will exhibit
> cache-incoherent behavior, and how to cope with that.
> (Then lots of drivers would need to change.)
> 
> OR ... maybe the bug is just that those PPC processors
> can't/shouldn't claim to implement that API.  At which
> point all drivers relying on that API (including all
> the USB HCDs and many of the USB drivers) stop working.
> 
> - Dave
>
> (*) DMA-API.txt uses two terms for this:  "coherent" and "consistent".
>      DMA-mapping.txt only uses "consistent".

That text strikes me as rather ambiguous.  Maybe it's intended to mean
that a write by either side can be read immediately by the other side, and
the values read will be the ones written (i.e., the read won't get stale
data from some cache).  It doesn't specify what happens to the other data
bytes in the same cache line which _weren't_ written -- maybe they'll be
messed up.

In other words, with "coherent" or "consistent" memory (there is some
technical distinction between the two terms but I don't know what it is)  
you don't have to worry about reading stale data from a cache, but you
might still have to worry about data unintentionally being overwritten
with garbage.

Clearly this is not a tremendously useful guarantee, but I guess it's 
better than nothing.

Maybe someone on linux-mm can clarify things for the rest of us.  For
anyone interested, this thread started with:

http://marc.theaimsgroup.com/?l=linux-usb-devel&m=108728413809788&w=2

Alan Stern


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
