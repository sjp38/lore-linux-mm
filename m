Received: from sco.COM (scol.london.sco.COM [150.126.1.48])
	by kvack.org (8.8.7/8.8.7) with SMTP id JAA32584
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 09:25:50 -0400
Date: Mon, 5 Apr 1999 14:23:03 +0100 (BST)
From: Mark Hemment <markhe@sco.COM>
Reply-To: Mark Hemment <markhe@sco.COM>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904050033340.779-100000@laser.random>
Message-ID: <Pine.SCO.3.94.990405122223.26431B-100000@tyne.london.sco.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrea/All,

  I'm just throwing some ideas around.....

> The page_hash looked like to me a quite obvious improvement while swapping
> in/out shm entreis (it will improve the swap cache queries) but looks my
> comment below...

  One worthwhile improvement to the page-hash is to reduce the need to
re-check the hash after a blocking operation (ie. page allocation).
  Changing the page-hash from an array of page ptrs to an array of;
	typedef struct page_hash_s {
		struct page	*ph_page;
		unsigned int	 ph_cookie;
	} page_hash_t;

  	page_hash_t page_hash[PAGE_HASH_TABLE];

  Whenever a new page is linked into a hash line, the ph_cookie for that
line is incremented.
  Before a page allocation, take a copy of the cookie for the hash line
where the page will be inserted.  If, after the allocation, the cookie
hasn't changed, then there is no reason to re-search the hash.

  This does double the size of the page-hash, and would require profiling
to determine if it is worthwhile.

  (Note: If the VM sub-system was threaded, there would be a different
solution than the above.)

> Note also (you didn't asked about that but I bet you noticed that ;) that
> in my tree I also made every pagemap entry L1 cacheline aliged. I asked to
> people that was complainig about page colouring (and I still don't know
> what is exactly page colouring , I only have a guess but I would like to
> read something about implementation details, pointers???) to try out my
> patch to see if it made differences; but I had no feedback :(. I also
> made the irq_state entry cacheline aligned (when I understood the
> cacheline issue I agreed with it).

  Yikes!!!!
  The page structure needs to be as small as possible.  If its size
happens to L1 align, then that is great, but otherwise it isn't worth the
effort - the extra memory used to store the "padding" is much better used
else where.
  Most accesses to the page struct are reads, this means it can live in
the Shared state across mutilple L1 caches.  The "slightly" common
operation of incremented the ref-count/changing-flag-bits doesn't really
come into play often enough to matter.
  Keeping the struct small can result in part of the page struct of
interest in the L1 cache, along with part of the next one.  As it isn't a
heavily modified structure, with no spin locks, "false sharing" isn't a
problem.  Besides, the VM isn't threaded, so it isn't going to be playing
ping-pong with the cache lines anyway.
  OK, with a smaller than h/w cache sized structure, whose size isn't a
a power of 2 (assuming cache-line sizes only come in power of 2) there may
need to be 2 cache-line faults to load the required members of a struct.
Smaller the page struct, the less lightly this is to happen.

  If you want to reduce the page struct size, it is possible to unionize
the "inode" and "buffers" pointers into one member, indicating which is
active via bits in the flag fields.  (Note:  If you do this change, the
flag-bit doesn't need to be set for the Swap-Cache state - this is a
special case for anonymous pages - looks like it drops out nicely.)

  Adding an extra member to page-struct, to count I/O write operations on
a page, is useful.  When a page is under going I/O, it has the PG_locked
bit set.  Fine.  If the I/O is write, then in many cases there is no
reason to block waiting for the I/O to finish.  eg.  Under a fault for
page not present, provided the returned mapping for the page is read-only,
why wait for the write operation to finish?  There is no need.
  Why use a count for I/O write ops?  Take the case of a WP fault.  This
does a page allocation as its first operation, just so the following
operations occur atomically.  It may be possible (I haven't checked it
through fully) to simply I/O write lock the faulting page, this (along
with some other code re-arrangement in do_wp_page() and shrink_mmap())
could allow this allocation to occur later - when we are more sure that it
is requried.

  Page-colouring is a bast*rd.  Modifying the page allocator to take a
'suggested' colour into account isn't too difficult.  I messed around with
this about 16mths ago (for added performance, changed the coalescing from
eager to lazy).  The problem end is page fragmentation.  Some of the 
fragmentation can be over come with a more intelligent page reaper, but
going as far as adding pte-chaining is way, way, over the top.  Going the
BSD 4.4 route, with linked lists of shadow objects, is possible, and gets
very interesting. :)
  Some of the fragmentation probs can be handled better by dropping the
static virt-to-phys mapping, and making it dynamic.  Allowing the page
allocator to give out virtually contigious pages (as well as the current
physically contigious pages) gives it more flexibility.  This has a _lot_
of issues, not least with device drivers - either they have strict
requirements on the type of memory they perform I/O on (ie. they accept
phys contigious only), or they need to be changed to perform
scatter/gather.


Regards,
Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
