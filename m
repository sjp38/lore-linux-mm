Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA07173
	for <linux-mm@kvack.org>; Wed, 17 Jun 1998 12:45:55 -0400
Date: Wed, 17 Jun 1998 18:03:14 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: PTE chaining, kswapd and swapin readahead
In-Reply-To: <m17m2gz8hq.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.96.980617173630.722A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 17 Jun 1998, Eric W. Biederman wrote:
> >>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> RR> This has the advantage of deallocating memory in physically
> RR> adjecant chunks, which will be nice while we still have the
> RR> primitive buddy allocator we're using now.
> 
> Also it has the advantage that shared pages are only scanned once, and
> empty address space needn't be scanned.

OK, this is a _very_ big advantage which I overlooked...

> Just what is your zone allocator?  I have a few ideas based on the
> name but my ideas don't seem to jive with your descriptions.
> This part about not needing physically contigous memory is really
> puzzling.

Well, the idea is to divide memory into different areas
(of 32 to 256 pages in size, depending on the amount of
main memory) for different uses.
There are 3 different uses:
- process pages, buffers and page cache
- pagetables and small (order 0, 1 and maybe 2) SLAB areas
- large SLAB allocations (order 2, 3, 4 and 5)
On large memory machines (>=128M) we might even split the
SLAB areas into 3 types...

Allocation is always done in the fullest area. We keep
track of this by hashing the area's in a doubly linked
list, using perhaps 8 different degrees of 'fullness'.
When an area get's fuller than the queue is meant to be,
it 'promotes' one level up and is added to the _tail_ of
the queue above. When an area get's emptier than it's
queue is supposed to be, it get's added to the _head_
of the queue below.

This way, the emptier areas get emptier and the fullest
area's get fuller. This way we can force-free an area
(with PTE chaining) when we're short of memory.

Inside the user area's, we can simply use a linked list
to mark free pages. Alternatively, we can keep the
administration in a separate area of memory. This has
the advantage that we don't have to reread a page when
it's needed shortly after we swapped it out. Then we
can simply use a bitmap and a slightly optimized
function.

For the SLAB area's, where we use different sizes of
allocation, we could use a simple buddy allocator.
Because the SLAB data is usually either long-lived
or _very_ short-lived and because we use only a few
different sizes in one area, the buddy allocator could
actually work here. Maybe we want the SLAB allocator
to give us a hint on whether it needs the memory for
a long or a short period and using separate area's...

There's no code yet, because I'm having a lot of
trouble switching to glibc _and_ keeping PPP working :(
Maybe later this month.

> RR> I write this to let the PTE people (Stephen and Ben) know
> RR> that they probably shouldn't remove the pagetable walking
> RR> routines from kswapd...
> 
> If we get around to using a true LRU algorithm we aren't too likely
> too to swap out address space adjacent pages...  Though I can see the
> advantage for pages of the same age.

True LRU swapping might actually be a disadvantage. The way
we do things now (walking process address space) can result
in a much larger I/O bandwidth to/from the swapping device.

> Also for swapin readahead the only effective strategy I know is to
> implement a kernel system call, that says I'm going to be accessing

There are more possibilities. One of them is to use the
same readahead tactic that is being used for mmap()
readahead. To do this, we'll either have to rewrite
the mmap() stuff, or we can piggyback the mmap() code
by writing a vnode system for normal memory area's.
The vnode system is probably easier, since that would
also allow for an easy implementation of shared memory
and easier tracking of memory movement (since we never
loose track of pages). Also, this vnode system will
make it possible to turn off memory overcommitment
(something that a lot of people have requested) and
do some other nice tricks...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
