Received: from penguin.e-mind.com ([195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19539
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 14:40:51 -0400
Date: Sun, 5 Jul 1998 20:38:57 +0200 (CEST)
From: Andrea Arcangeli <arcangeli@mbox.queen.it>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705185219.1574D-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.980705202128.12985B-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 1998, Rik van Riel wrote:

>Hdparm only affects _hardware_ readahead and has nothing
>to do with software readahead.

Wooops.

>The cache is also mapped into a process'es address space.
>Currently we would have to walk all pagetables to find a
>specific page ;(
>When Stephen and Ben have merged their PTE stuff, we can
>do the freeing much easier though...

I start to think that the problem is kswapd. Running cp file /dev/null the
system remains fluid (when press a key I see the char on the _console_) 
until there is free (wasted because not used) memory. While there is free
memory the swap is 0. When the free memory finish, the system die and when
I press a key I don' t see the character on the screen immediatly. I think
that it' s kswapd that is irratiting me. So now I am trying to fuck kswapd
(I am starting to hate it since I really hate swap ;-). kswapd must swap
_nothing_ if _freeable_ cache memory is allocated.  kswapd _must_ consider
freeable cache memory as _free_ not used memory and so it must not start
swapping out useful code and data for make space for allocating more
cache.  With 2.0.34 when the cache eat all free memory nothing gone
swapped out and all perform better.

>> >Both can be avoided by using (not yet implemented)
>> >balancing code. It is on the priority list of the MM
>> I had to ask "2.0.34 has balancing code implemented and running?". The
>
>2.0 has no balancing code at all. At least, not AFAIK...

So 2.1.108 must be able to perform as 2.0.34.

>> current mm layer is not able to shrink the cache memory and I consider it
>> a bug that must be fixed without adding other code. 
>
>How do you propose we solve a bug without programming :)

;-). I want to tell "without adding new features or replacing the most of
the code"... 

>> Is there a function call (such us shrink_mmap for mmap or
>> kmem_cache_reap() for slab or shrink_dcache_memory() for dcache) that is
>> able to shrink the cache allocated by cp file /dev/zero?
>
>shrink_mmap() can only shrink unlocked and clean buffer pages
>and unmapped cache pages. We need to go through either bdflush

...unmapped cache pages. Good.

>(for buffer) or try_to_swap_out() first, in order to make some

try_to_swap_out() should unmap the cache pages? Then I had to recall
shrink_mmap()?

>easy victims for shrink_mmap()...

Rik reading vmscan.c I noticed that you are the one that worked on kswapd
(for example removing hard page limits and checking instead
free_memory_available(nr)). Could you tell me what you changed (or in
which kernel-patch I can find the kswapd patches) to force kswapd to swap
so much? 

Andrea[s] Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
