Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA01185
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 11:57:57 -0400
Date: Mon, 5 Apr 1999 17:56:35 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.SCO.3.94.990405122223.26431B-100000@tyne.london.sco.com>
Message-ID: <Pine.LNX.4.05.9904051723490.507-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mark Hemment <markhe@sco.COM>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 1999, Mark Hemment wrote:

>Hi Andrea/All,
>
>  I'm just throwing some ideas around.....
>
>> The page_hash looked like to me a quite obvious improvement while swapping
>> in/out shm entreis (it will improve the swap cache queries) but looks my
>> comment below...
>
>  One worthwhile improvement to the page-hash is to reduce the need to
>re-check the hash after a blocking operation (ie. page allocation).

Yes, I just thought about that some time ago.

>  Changing the page-hash from an array of page ptrs to an array of;
>	typedef struct page_hash_s {
>		struct page	*ph_page;
>		unsigned int	 ph_cookie;
>	} page_hash_t;
>
>  	page_hash_t page_hash[PAGE_HASH_TABLE];
>
>  Whenever a new page is linked into a hash line, the ph_cookie for that
>line is incremented.
>  Before a page allocation, take a copy of the cookie for the hash line
>where the page will be inserted.  If, after the allocation, the cookie
>hasn't changed, then there is no reason to re-search the hash.
>
>  This does double the size of the page-hash, and would require profiling
>to determine if it is worthwhile.

I don't think it's worthwhile simply because most of the time you'll have
only to pass as _worse_ one or two chains of the hash entry. And passing
one or two chains will be far more ligther than the new mechanism.

If you have gigabyte of cache you will be hurted by performances anyway
and you'll enlarge the hash size anyway and so you'll return in no need of
the mechanizm.

But maybe I am plain wrong. If you'll try let me know the profiling (I am
very courious). At least the bench will be trivial ;). Just do a 'time cat
/usr/bin/* >/dev/null' with 100mbyte of cache and then with 10mbyte of
memory usable for the cache with the two kernels and you'll see if it's
worthwhile.

>  (Note: If the VM sub-system was threaded, there would be a different
>solution than the above.)

Which is the other solution? And which is the point of the threaded issue?
We are just playing games with threaded issues exactly because we have a
sleep to allocate memory.

>> Note also (you didn't asked about that but I bet you noticed that ;) that
>> in my tree I also made every pagemap entry L1 cacheline aliged. I asked to
>> people that was complainig about page colouring (and I still don't know
>> what is exactly page colouring , I only have a guess but I would like to
>> read something about implementation details, pointers???) to try out my
>> patch to see if it made differences; but I had no feedback :(. I also
>> made the irq_state entry cacheline aligned (when I understood the
>> cacheline issue I agreed with it).
>
>  Yikes!!!!
>  The page structure needs to be as small as possible.  If its size
>happens to L1 align, then that is great, but otherwise it isn't worth the
>effort - the extra memory used to store the "padding" is much better used
>else where.

Note that in UP I am not enlarging the pagemap struct size. I will agree
that the padding is much better used else where when somebody that
complains about page colouring will show me no difference in numbers
between L1 cache alignment and zero padding.

>  Most accesses to the page struct are reads, this means it can live in
>the Shared state across mutilple L1 caches.  The "slightly" common
>operation of incremented the ref-count/changing-flag-bits doesn't really
>come into play often enough to matter.

Also setting swapcache/locked/update and whatever SMP-locking flags
etc..etc...

>problem.  Besides, the VM isn't threaded, so it isn't going to be playing
>ping-pong with the cache lines anyway.

It's not threaded now but I was just making shrink_mmap() threaded here.
With my new pagemap_lru it's trivial to make shrink_mmap() threaded (just 
add some spinlock to add_cache/del_cache/mkyoung() and use
by hand releasekernellock reaquirekernellock).

>  If you want to reduce the page struct size, it is possible to unionize
>the "inode" and "buffers" pointers into one member, indicating which is
>active via bits in the flag fields.  (Note:  If you do this change, the

Agreed!

>flag-bit doesn't need to be set for the Swap-Cache state - this is a
>special case for anonymous pages - looks like it drops out nicely.)

I think that PG_swap_cache is simply overhead to get performances. It's
not needed right now _too_, because you only need to compare page->inode
with &swapper_inode to know if it's a swap cache page or not. The ->buffer
field has nothing to do with that.

>  Adding an extra member to page-struct, to count I/O write operations on
>a page, is useful.  When a page is under going I/O, it has the PG_locked
>bit set.  Fine.  If the I/O is write, then in many cases there is no
>reason to block waiting for the I/O to finish.  eg.  Under a fault for

Agreed it would make sense, even if I don't know how much this will make
difference while I am sure that the complexity will increase a good bit...

>page not present, provided the returned mapping for the page is read-only,
>why wait for the write operation to finish?  There is no need.
>  Why use a count for I/O write ops?  Take the case of a WP fault.  This
>does a page allocation as its first operation, just so the following
>operations occur atomically.  It may be possible (I haven't checked it
>through fully) to simply I/O write lock the faulting page, this (along
>with some other code re-arrangement in do_wp_page() and shrink_mmap())
>could allow this allocation to occur later - when we are more sure that it
>is requried.

When you return from a fault if you don't map a new page you'll get a
second fault. If you fault you need the (maybe writable) page alloced
_now_. Maybe I am missing your point...

Many thanks your interesting comments/thoughts.

Andrea Arcangeli

BTW, Did you seen my kmem_cache_destroy()? I got zero feedback about it
    ;). It worked fine so far here and it's always included in my
    arca-tree patches. Alexander Viro (or others?, i don't remeber
    well) asked for it in order to avoid a two level modules.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
