Date: Thu, 4 Nov 1999 18:58:06 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [Patch] shm cleanups
In-Reply-To: <qwwu2n2ctw4.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.9911041851010.5467-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: MM mailing list <linux-mm@kvack.org>, woodman@missioncriticallinux.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 4 Nov 1999, Christoph Rohland wrote:

> I do get swapping also with 8GB of RAM, but it runs out of memory
> before running out of swap space since prepare_highmem_swapout is
> failing way to often.
> 
> (It then locks up since it cannot free the shm segments and so is
> unable to free the memory. This should be perhaps addressed later in
> the oom handler. It cannot handle the case where nearly all memory is
> allocted in shm segments)

ho humm. I think prepare_highmem_swapout() has a design bug. It's way too
naive in low memory situations, it should keep a short list of pages for
emergency swapout. It's the GFP_ATOMIC that is failing too often, right?

i believe we should have some explicit mechanizm that tells vmscan that
there is 'IO in progress which will result in more memory', to distinct
between true out-of-memory and 'wait a little bit to get more RAM' cases?
I think we'd have a lot less to worry about and there would be a much
clearer distinction between true out-of-mem and 'just cannot allocate it
right now but help is on the way' cases.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
