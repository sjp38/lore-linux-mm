Received: from toomuch.toronto.redhat.com (toomuch.toronto.redhat.com [172.16.14.22])
	by lacrosse.corp.redhat.com (8.9.3/8.9.3) with ESMTP id WAA11250
	for <linux-mm@kvack.org>; Sun, 8 Jul 2001 22:44:58 -0400
Date: Thu, 5 Jul 2001 10:13:25 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.21.0107051737340.1577-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33.0107050957010.22305-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33.0107082243450.30164@toomuch.toronto.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ben LaHaise <bcrl@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jul 2001, Hugh Dickins wrote:
>
> I'm interested in larger pages, but wary of multipage PAGE_CACHE_SIZE:
> partly because it relies on non-0-order page allocations, partly because
> it seems a shame then to break I/O into smaller units below the cache.

Note that once PAGE_CACHE_SIZE is of a higher order, then they effectively
become the same as the current order-0 pages - it's just that the buddy
system can always allocate "fractional" pages too.

We shouldn't get the same fragmentation issues, as the new order-N
allocation should be the common one, and the sub-oder-N fragments should
clump nicely together.

Also note that the I/O _would_ happen in PAGE_CACHE_SIZE - you'd never
break it into smaller chunks. That's the whole point of having a bigger
PAGE_CACHE_SIZE.

Now, I actually think your approach basically does the very same thing,
and I don't think there are necessarily any real differences between the
two. It's more of a perception issue: which "direction" do you look at it
from.

You take the approach that pages are bigger, but that you can map partial
pages into VM spaces. That is 100% equivalent to saying that the caching
fragment size is a order-N page, I think.

Obviously your world-view ends up very much impacting how you actually
implement it, so in that sense perception certainly does matter.

>  * One subpage is represented by one Page Table Entry at the MMU level,
>  * and corresponds to one page at the user process level: its size is
>  * the same as param.h EXEC_PAGESIZE (for getpagesize(2) and mmap(2)).
>  */
> #define SUBPAGE_SHIFT	12
> #define SUBPAGE_SIZE	(1UL << SUBPAGE_SHIFT)
> #define SUBPAGE_MASK	(~(SUBPAGE_SIZE-1))

I would _really_ prefer to make it clear that "SUBPAGE" is a VM mapping
issue and nothing more (which is your approach), and would much prefer
that to be made very explicit. So I'd not call them "SUBPAGES", but
something like

	#define VM_PAGE_SHIFT	12
	#define VM_PAGE_SIZE ..

However, once you do this, who cares about "PAGE_SIZE" at all? In the end,
PAGE_SIZE has no meaning except for the internal VM memory management:
it's nothing but the smallest fragment-size that the buddy system works
with.

What does that matter? It makes a huge difference for page accounting.
That's really the only thing that should care about PAGE_SIZE, and the
difference here between the two approaches isn't all that big:

 - in your approach, PAGE_SIZE equals PAGE_CACHE_SIZE, so a PAGE_CACHE
   page only has one page count arrociated with it. That's good, because
   it simplifies "release_page_cache()" and friends.

 - going the other way, each VM "dirty" entity has a "struct page *"
   associated with it. That makes page count handling a bit nastier, but
   on the other hand it makes VM attributes much easier to handle, notably
   things like "dirty" bits.

Which is the right one? Frankly, don't know. It may be quite acceptable to
have just a single dirty bit for bigger regions. That would simplify
things, for sure.

On the other hand, maybe we will eventually have a per-mapping "page
size". That would be pretty much impossible with your approach, while the
"page size is the smallest VM granularity, PAGE_CACHE_SIZE is something
else" approach lends itself to that extension (just add a "size_shift" to
"struct address_space", and make the #defines use that instead. "Small
matter of programming").

> I've said enough for now: either you're already disgusted, and will
> reply "Never!", or you'll sometime want to cast an eye over the patch
> itself (or nominate someone else to do so), to get the measure of it.

I'd really like both of you to think about both of the approaches as the
same thing, but with different mindsets. Maybe there is something that
clearly makes one mindset better. And maybe there is some way to just make
the two be completely equivalent..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
