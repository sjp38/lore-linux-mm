Received: from penguin.e-mind.com ([195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA26707
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 14:31:45 -0400
Date: Mon, 6 Jul 1998 16:20:53 +0200 (CEST)
From: Andrea Arcangeli <arcangeli@mbox.queen.it>
Reply-To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705212422.2416D-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.980706134011.349E-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 1998, Rik van Riel wrote:

>A few months ago someone (who?) posted a patch that modified
>kswapd's internals to only unmap clean pages when told to.
>
>If I can find the patch, I'll integrate it and let kswapd
>only swap clean pages when:
>- page_cache_size * 100 > num_physpages * page_cache.borrow_percent

I don' t agree with swapping out if there are enough freeable pages in the
cache (or at least the aging should be very more clever than now).

It seems that setting to 1 2 3 pagecache, buffers and freepages and
setting 1 1 1 kswapd (so that kswapd can only swap one page at time) help
a lot to make the system _usable_ (when I press a key I see it on the
console)  during `cp file /dev/null' (the cache got reduced to 3Mbyte
against the default 10Mbyte if memtest 10000000 is running at the same
time).  Sometimes I get out of memory with these settings while `cp file
/dev/null' is running, since the cache is allocated and the less priority
of kswapd can' t free a lot of memory I think. 

Now I have a new question. What would happen if kswapd would be stopped
while `cp file /dev/null' is running? The cache memory allocated by cp is
reused or it' s always allocated from the free memory?

And is it possible to know how much memory is unmappable (and then
freeable) from the cache? If so we should use the swap_out() method in
do_try_to_free_page() only if there isn' t enough freeable memory in the
cache. If swap_out() is not used kswapd will free memory from the cache or
buffers without swapout, or no?

Think about a 128Mbyte system. I think that is a no sense swapping out 3/4
Mbyte of RAM and have 40/50Mbyte of cache and a lot of buffers allocated.
If I buy memory _I_ don' t want to see the swap used. I _hate_ the swap. I
would run with swapoff -a if the machine would not deadlock (with kswapd
loading 100% of the CPU) instead of return out of memory.

And how is handled the aging of the pages? i386 (and MIPS if I remeber
well) (don' t tell me "and every other modern CPU" because I can guess
that ;-) provides a flag in every page that should be usable to take care
of the page recently read/write against the unused pages. Is that flags
used to take care of the aging or the aging is done all by software
without take advantages of CPU facilites? I ask this because it seems that
the aging doesn' t work since my bash is swapped out (or removed from the
RAM) when read(2) allocate the cache while in 2.0.34 all is perfect. 

Now I am using this simple program to test kswapd:

#include <unistd.h>

main()
{
  char buf[4096];
  while (read(0, buf, sizeof(buf)) == sizeof(buf));
}

./a.out < /tmp/zero

Where zero is a big file. When there is no more memory free (because
it' s all allocated in the cache) bash is not more responsive to keypress
and the swap/in/out start.

Fortunately at least the 2.0.34 mm algorithms seems to works _perfect_
under all kind of conditions so in the worst case I' ll try to port for my
machine the linux/mm/* interesting things from 2.0.34 to 108 and I' ll
start rejecting every other kernel official mm patch (you can see that I
am really irritate due too much swapping in the last month ;-). It will be
an hard work but at least I will be sure of the good result...  Somebody
has really _screwed_ the really _perfect_ 2.0.34 kswapd in the 2.1.x way.

As far as I known, nobody except me is working to fix kswapd. I had also
to tell that I never used Linux in a machine with > 32Mbyte of ram so I
don' t know if there 2.1.108 works perfect as 2.0.34. So please tell me to
buy other 32Mbyte of memory or help me to fix kswapd instead of developing
new things for memory defragmentation for example.

Andrea[s] Arcangeli

PS. Now I am running 2.0.34 and it' s very very more efficient than
    2.1.108. 108 is sure very faster in all things but _here_ the "always
    swapping" thing remove all other improvements and make the system very
    very less fluid :-(.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
