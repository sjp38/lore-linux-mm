Date: Mon, 23 Feb 1998 19:08:59 -0500 (U)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <199802232317.XAA06136@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980223184015.28517B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Mon, 23 Feb 1998, Stephen C. Tweedie wrote:
...
> The patch below, against 2.1.88, adds a bunch of new functionality to
> the swapper.  The main changes are:
> 
> * All swapping goes through the swap cache (aka. page cache) now.
...

I noticed you're using just one inode for the swapper/page cache...  What
I've been working on is a slightly different approach:  Create inodes for
each anonymous mapping.  The actual implementation uses one inode per
mm_struct, with the virtual address within the process providing the
offset.  This has the advantage of giving us an easy way to find all ptes
that use an anonymous page.  Anonymous mappings end up looking more like
shared mappings, which gives us some interesting possibilities - it
becomes almost trivial to implement a MAP_SHARED on another process'
address space.  What do you think of this approach?  My main goal is to
reimplement the page-oriented swapping my pte-list patch performed, which
makes the running time try_to_free_page drastically shorter, even
predictable... (at most 1 pass over mem_map to find a page using the old
style aging, or just one list operation using the inactive list approach) 

		-ben
