Date: Sun, 14 May 2000 12:52:21 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.10.10005130819330.1721-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10005141245510.1494-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 May 2000, Linus Torvalds wrote:

> So pre-8 with your suggested for for kswapd() looks pretty good, actually,
> but still has this issue that try_to_free_pages() seems to give up too
> easily and return failure when it shouldn't. [...]

i believe the reason for gfp-NULL failures is the following:
do_try_to_free_pages() _does_ free pages, but we do the sync in the
writeback case _after_ releasing a particular page. This means other
processes can steal our freshly freed pages - rmqueue fails easily. So i'd
suggest the following workaround:

	if (try_to_free_pages() was succesful && final rmqueue() failed)
		goto repeat;

we could as well do the page_cache_release of the buffer-mapped cache
after sync_page_buffers(), but this only saves a single page - multipage
allocations will still have a big window to fail. The problem is that
freed RAM is anonymous right now. We can fundamentally solve this by
manipulating zone->free_pages the following way:

a __free_pages variant that does not increase zone->free_pages. this is
then later on done by the allocator (ie. __alloc_pages). This 'free page
transport' mechanizm guarantees that the non-atomic allocation path does
not 'lose' free pages along the way.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
