Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19145
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 14:07:31 -0400
Date: Sun, 5 Jul 1998 19:00:04 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705131034.327C-100000@dragon.bogus>
Message-ID: <Pine.LNX.3.96.980705185219.1574D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 1998, Andrea Arcangeli wrote:
> On Sun, 5 Jul 1998, Rik van Riel wrote:
> 
> >We can achieve this by switching off readahead when we
> >reach the maximum RSS of the inode. Then we should probably
> 
> I run hdparm -a0 /dev/hda and nothing change. Now the cache take 20Mbyte
> of memory running cp file /dev/null while memtest 10000000 is running.

Hdparm only affects _hardware_ readahead and has nothing
to do with software readahead.

> >instruct kswapd in some way to remove pages from that inode,
> >but I'm not completely sure how to do that...
> 
> Where does the cache is allocated? Is it allocated in the inode? If so
> kswapd should shrink the inode before start swapping out! 

The cache is also mapped into a process'es address space.
Currently we would have to walk all pagetables to find a
specific page ;(
When Stephen and Ben have merged their PTE stuff, we can
do the freeing much easier though...

> >For the buffer cache, we might be able to use the same
> >kind of algorithm, but I'm not completely sure of that.
> 
> The buffer memory seems to be reduced better than the cache memory though.

This is partly because buffer memory is not mapped in any
pagetable and because buffer memory generally isn't worth
keeping around. Because of that we can and do just throw
it out on the next opportunity.

> >Both can be avoided by using (not yet implemented)
> >balancing code. It is on the priority list of the MM
> I had to ask "2.0.34 has balancing code implemented and running?". The

2.0 has no balancing code at all. At least, not AFAIK...

> current mm layer is not able to shrink the cache memory and I consider it
> a bug that must be fixed without adding other code. 

How do you propose we solve a bug without programming :)

> Is there a function call (such us shrink_mmap for mmap or
> kmem_cache_reap() for slab or shrink_dcache_memory() for dcache) that is
> able to shrink the cache allocated by cp file /dev/zero?

shrink_mmap() can only shrink unlocked and clean buffer pages
and unmapped cache pages. We need to go through either bdflush
(for buffer) or try_to_swap_out() first, in order to make some
easy victims for shrink_mmap()...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
