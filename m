Date: Mon, 23 Mar 1998 16:20:47 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: 2.1.90 dies with many procs procs, partial fix
In-Reply-To: <Pine.LNX.3.91.980323203732.771G-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980323155005.17867E-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: Finn Arne Gangstad <finnag@guardian.no>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 1998, Rik van Riel wrote:
...
> Hmm, this is evidence that I was right when I said
> that the free_memory_available() system combined
> with our current allocation scheme gives trouble.
> Linus, what fix do you propose?
> (I don't really feel like coding a fix that will
> be rejected :-)

That sounds about right, but it isn't fixing the underlying problem -
which, as Linus has pointed out, we can't avoid anymore.  Here's a
suggestion that might help:  change get_free_pages not to break larger
order memory blocks for non-atomic allocations that will result in too few
blocks of the upper order remaining.  GFP_ATOMIC is a nice hint that the
memory allocated will be freed soon.  If an atomic allocation does require
breaking up a huge chunk, what happens?  Do the resulting blocks get
consumed by lower priority, yet smaller, allocations before the large
atomically allocated portion is released?

An approach that should help is to use a [large] fixed size block for a
fixed purpose, a la slab.  Using 256KB or so blocks, which once allocated
will only go to simlar uses (just using a breakdown according to order
would be a big help).  If we can also keep all user pages together, then
later on we'll be able to reap large chunks from user memory whenever a
device driver starts up and needs a chunk of memory.

Currently, my experimental page-queue stuff is moving towards this end of
things for user/page cache pages.  Since these allocations are always for
page size objects, there's no need to fiddle with bitmaps, coalescing and
such under normal circumstances in get_free_page (the swap daemon takes
care of running the balancing act).  User allocations will simply be: try
to remove page from the reaped queue, otherwise try to refill the reaped
queue.  If that fails and we're not pushing memory allocation limits, do a
normal get_free_page.  Otherwise sleep until some swapout has completed.

		-ben
