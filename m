Date: Mon, 8 Jan 2001 09:29:15 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <20010108135700.O9321@redhat.com>
Message-ID: <Pine.LNX.4.10.10101080916180.3750-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 8 Jan 2001, Stephen C. Tweedie wrote:
> 
> > Then, with something like the above, we just try to make sure that we scan
> > the whole virtual memory space every once in a while. Make the "every once
> > in a while" be some simple heuristic like "try to keep the active list to
> > less than 50% of all memory".
> 
> ... which will produce an enormous storm of soft page faults for
> workloads involving mmaping large amounts of data or where we have
> a lot of space devoted to anonymous pages, such as static
> computational workloads.

I don't think you'll find that in practice. 

It would obviously trigger only on low-memory code _anyway_ (we don't even
get into "try_to_free_pages()" unless there is memory pressure), so I
think you're _completely_ off the mark here.

Remember: the thing doesn't require that < 50% of memory is in the page
tables. It only says: if 50% or more of memory is in the page tables, we
will always scan the page tables first when we try to find free pages.

If you have a well-behaving application that doesn't even have memory
pressure, but fills up >50% of memory in its VM, nothing will actually
happen in the steady state. It can have 99% of available memory, and not a
single soft page fault.

But think about what happens if you now start up another application? And
think about what SHOULD happen. The 50% ruls is perfectly fine: if we're
starting to swap, we're better off taking soft page faults that give us a
better LRU than letting the MM scrub the same pages over and over because
it effectively only sees a subset of the total pages (with the mapped
pages being "invisible").

The fact is, that we absolutely _have_ to do the VM scan in order for the
inactive lists to be at all representative of the state of affairs. If we
just rely on page_launder() and refill_inactive() as the #1 way to get
free pages, we will never consider anything but the pages that are already
on the lists.

Stephen: have you tried the behaviour of a working set that is dirty in
the VM's and slightly larger than available ram? Not pretty. We do
_really_ well on many loads, but this one we do badly on. And from what
I've been able to see so far, it's because we're just too damn good at
waiting on page_launder() and doing refill_inactive_scan().

There's another advantage to the 50% rule: if we are under memory
pressure, and somebody is dirtying pages in its VM (which is otherwise an
"invisible" event to the kernel), the 50% rule is much more likely to mean
that we actually _see_ the dirtying, and can slow it down.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
