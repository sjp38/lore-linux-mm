Date: Thu, 4 Nov 1999 20:02:55 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [Patch] shm cleanups
In-Reply-To: <Pine.LNX.4.10.9911041851010.5467-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.LNX.4.10.9911042000300.647-100000@imladris.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, MM mailing list <linux-mm@kvack.org>, woodman@missioncriticallinux.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Nov 1999, Ingo Molnar wrote:
> On 4 Nov 1999, Christoph Rohland wrote:
> 
> > I do get swapping also with 8GB of RAM, but it runs out of memory
> > before running out of swap space since prepare_highmem_swapout is
> > failing way to often.
> 
> ho humm. I think prepare_highmem_swapout() has a design bug. It's way too
> naive in low memory situations, it should keep a short list of pages for
> emergency swapout. It's the GFP_ATOMIC that is failing too often, right?
> 
> i believe we should have some explicit mechanizm that tells vmscan that
> there is 'IO in progress which will result in more memory', to distinct
> between true out-of-memory and 'wait a little bit to get more RAM' cases?

I think I see what is going on here. Kswapd sees that memory is
low an "frees" a bunch of high memory pages, causing those pages
to be shifted to low memory so the total number of free pages
stays just as low as when kswapd started.

This can result in in-memory swap storms, we should probably
limit the number of in-transit async himem pages to 256 or some
other even smaller number.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
