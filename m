Date: Mon, 15 Jan 2001 10:24:19 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: swapout selection change in pre1
In-Reply-To: <20010115102445.B18014@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.10.10101151011340.6108-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Ed Tomlinson <tomlins@cam.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 15 Jan 2001, Jamie Lokier wrote:
> 
> Freeing pages aggressively from a process that's paging lots will make
> that process page more, meaning more aggressive freeing etc. etc.
> Either it works and reduces overall paging fairly (great), it spirals
> out of control, which will be obvious, or it'll simply be stable at many
> different rates which is undesirable but not so obvious in testing.

I doubt that it gets to any of the bad cases.

See - when the VM layer frees pages from a virtual mapping, it doesn't
throw them away. The pages are still there, and there won't be any "spiral
of death". If the faulter faults them in quickly, a soft-fault will happen
without any new memory allocation, and you won't see any more vmascanning.
It doesn't get "worse", if the working set actually fits in memory.

So the only case that actually triggers a "meltdown" is when the working
set does _not_ fit in memory, in which case not only will the pages be
unmapped, but they'll also get freed aggressively by the page_launder()
logic. At that point, the big process will actually end up waiting for the
pages, and will end up penalizing itself, which is exactly what we want. 

So it should never "spiral out of control", simply because of the fact
that if we fit in memory it has no other impact than initially doing more
soft page faults when it tries to find the right balancing point. It only
really kicks in for real when people are continually trying to free
memory: which is only true when we really have a working set bigger than
available memory, and which is exactly the case where we _want_ to
penalize the people who seem to be the worst offenders.

So I woubt you get any "subtle cases".

Note that this ties in to the thread issue too: if you have a single VM
and 50 threads that all fault in, that single VM _will_ be penalized. Not
because it has 50 threads (like the old code did), but because it has a
very active paging behaviour.

Which again is exactly what we want: we don't want to penalize threads per
se, because threads are often used for user interfaces etc and can often
be largely dormant. What we really want to penalize is bad VM behaviour,
and that's exactly the information we get from heavy page faulting.

NOTE! I'm not saying that tuning isn't necessary. Of course it is. And I
suspect that we actually want to add a page allocation flag (__GPF_VM)
that says that "this allocation is for growing our VM", and perhaps make
the VM shrinking conditional on that - so that the VM shrinking really
only kicks in for the big VM offenders, not for people who just read files
into the page cache.

So yes, we'll have VM tuning, the same as 2.2.x had and probably still
has. But I think our algorithms are a lot more "fundamentally stable" than
they were before. Which is not to say that the tuning is obvious - I just
claim that we will probably have a lot better time doing it, and that we
have more tools in our tool-chest.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
