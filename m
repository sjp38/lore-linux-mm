Date: Thu, 4 May 2000 12:17:58 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <Pine.LNX.4.21.0005041559490.23740-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10005041202310.811-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>


On Thu, 4 May 2000, Rik van Riel wrote:

> On Thu, 4 May 2000, Linus Torvalds wrote:
> 
> > Note that changing how hard try_to_free_pages() tries to free a page is
> > exactly part of what Rik has been doing, so this is something that has
> > changed recently. It's not trivial to get right, for a very simple reason:
> > we need to balance the "hardness" between the VM area scanning and the RLU
> > list scanning.
> 
> With the current scheme, it's pretty much impossible to get it
> right.

Not really. That is what the "priority levels" are really there for: for
normal use it's actually sufficient to just make sure that the starter
levels (ie 6) balance reasonably well between VM scanning and RLU
scanning. If they balance ok, then system behaviour will be quite
acceptable.

At the same time it is important to make sure that the higher priorities
(ie 1 and 0) try _much_ harder to swap things out than the lower ones.
They don't need to be very balanced, but they need to be effective. That's
why shrink_mmap() uses a quite grotesque 

	count = nr_lru_pages >> priority;

which means that level 0 will try 64 times harder than level 6 to page
something out. It's also important that once you get to level 0, it really
should scan everything available more than once (once for aging, once for
"everything was aged the first time, the second time we really free
something").

This, I think, is where the new swap_out() falls down flat on its face. It
does a much softer swapout, and the priority is not as aggressive as it is
for shrink_mmap(). Instead of a exponential increase with priority, it
uses a linear one: "counter = nr_threads / (priority+1)".

I suspect that for "priority = 0", we should make sure that "counter" is
at _least_ "nr_threads * 2", simply because we should walk the page tables
at least twice before giving up: the "mm->swap_address" logic means that
walking them once may have started somewhere in the middle and never even
looked at the low values. Because we age, it should probably be more than
that.

So it might be that we should really use something like

	counter = (nr_threads << 1) >> (priority >> 1);

instead (just a completely made up heuristic - I just made up something
that has exponential behaviour while still having a starting point close
to what we have now to get roughly the same balancing).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
