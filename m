Date: Tue, 14 Apr 1998 19:13:51 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: new kmod.c - debuggers and testers needed
In-Reply-To: <199804142127.OAA09136@sun4.apsoft.com>
Message-ID: <Pine.LNX.3.95.980414185331.9168E-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Perry Harrington <pedward@sun4.apsoft.com>
Cc: H.H.vanRiel@fys.ruu.nl, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Apr 1998, Perry Harrington wrote:
...
> > Hmm, maybe it would be useful for kswapd and bdflush to fork()
> > off threads to do the actual disk I/O, so the main thread won't
> > be blocked and paused... This could remove some bottlenecks.

It's not bottlenecks so much as it is the need to do some things
speculatively, but what I have in mind is too much to do for now.

> I was thinking that kswapd could use some of it's spare time to do an LRU
> paging scan, consolidate free space, and possibly do remapping of process
> memory spaces to make them more efficient (map pages to contiguous chunks
> of memory and swap).

Two techniques that I think should help are:
	1. make it easier to free contiguous pages (that's done and
	working for me)
	2. change the allocation strategy to make our common cases not
	fragment memory all over the place - ie switch to a zone allocator
	for pages

It's far too late in 2.1 for any truely radical changes to combat
fragmention to go into the mainstream kernel, hence we need to stick to
tweaking the behaviour of our existing code.  Perhaps get_free_page
shouldn't break any of the higher memory order allocations for GFP_USER
requests when such actions will leave insufficient high-order pages
around.  Couple that with kswapd now checking the available memory orders
and normal systems shouldn't suffer swapout attacks (or at least those
caused by a lack of free high-order page).

		-ben
