Date: Wed, 26 Apr 2000 09:44:28 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <20000426122448.G3792@redhat.com>
Message-ID: <Pine.LNX.4.10.10004260929340.1492-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: riel@nl.linux.org, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 26 Apr 2000, Stephen C. Tweedie wrote:
> 
> We just shouldn't need to keep much memory free.
> 
> I'd much rather see a scheme in which we have two separate goals for 
> the VM.  Goal one would be to keep a certain number of free pages in 
> each class, for use by atomic allocations.  Goal two would be to have
> a minimum number of pages in each class either free or on a global LRU
> list which contains only pages known to be clean and unmapped (and
> hence available for instant freeing without IO).

This would work. However, there is a rather subtle issue with allocating
contiguous chunks of memory - something that is frowned upon, but however
hard we've triedthere has always been people that really need to do it.

And that subtle issue is that in order for the buddy system to work for
contiguous areas, you cannot have "free" pages _outside_ the buddy system.

The reason the buddy system works for contiguous allocations >1 pages is
_not_ simply that it has the data structures to keep track of power-of-
two pages. The bigger reason for why the buddy system works at all is that
it is inherenty anti-fragmenting - whenever there are free pages, the
buddy system coalesces them, and has a very strong bias to returning
already-fragmented areas over contiguous areas on new allocations.

This advantage of the buddy system is also why keeping a "free list" is
not actually necessarily that great of an idea. Because the free list will
make fragmentation much worse by not allowing the coalescing - which in
turn is needed in order to try to keep future allocations from fragmenting
the heap more.

And yes, part of having memory free is to have low latency - oneof the
huge advantages of kswapd is that it allows us to do background freeing so
that the perceived latency to the occasional page allocator is great. And
that is important, and the "almost free" list would work quite well for
that.

However, the contiguous area concern is also a real concern. That iswhy I
want to keep "alloc_page()" and "free_page()" as the main memory
allocators: the buddy system is certainly not the fastest memory allocator
around, but it's so far the only one I've seen that has reasonable
behaviour wrt contiguous areas without excessive overhead.

[ Side comment: maybe somebody remembers the _original_ page allocator in
  Linux. It was based on a very very simple linked list of free pages -
  and it was fast as hell. There is absolutely no allocator that does it
  faster: getting a new page was not just constant time, but it was just a
  few cycles. FAST. The reason I moved to the buddy allocator was that the
  flexibility of being able to allocate two or four pages at a time
  outweighed the speed disadvantage. I'd hate for people to unwittingly
  lose that advantage by just not thinking about these issues.. ]

However, it's certainly true that ourmemory freeing machinery could be
cleaned up a bit, and having the "two phase" thing encoded explicitly in
the page freeing logic might not be a bad idea. I just wanted to point out
some reasons why it might not be all that sensible to count the "easily
freed queue" as real free memory..

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
