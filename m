Received: from penguin.e-mind.com ([195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA17845
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 08:45:14 -0400
Date: Sun, 5 Jul 1998 13:32:10 +0200 (CEST)
From: Andrea Arcangeli <arcangeli@mbox.queen.it>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980705072829.17879D-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.980705131034.327C-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 1998, Rik van Riel wrote:

>The current allocator is often unable to keep fragmentation
>from happening when too many allocations are done. When we

So I don' t bother about fragmentation and about the zone allocator.

>I have a better idea. The RSS for an inode shouldn't be
>allowed to grow larger than 50% of the size of the page
>cache when:
>- we are tight on memory; and
>- the page cache takes more than 25% of memory
>
>We can achieve this by switching off readahead when we
>reach the maximum RSS of the inode. Then we should probably

I run hdparm -a0 /dev/hda and nothing change. Now the cache take 20Mbyte
of memory running cp file /dev/null while memtest 10000000 is running.

>instruct kswapd in some way to remove pages from that inode,
>but I'm not completely sure how to do that...

Where does the cache is allocated? Is it allocated in the inode? If so
kswapd should shrink the inode before start swapping out! 

>For the buffer cache, we might be able to use the same
>kind of algorithm, but I'm not completely sure of that.

The buffer memory seems to be reduced better than the cache memory though.

>> I would ask to people to really run the kernel with mem=30Mbyte and then
>> run a `cp /dev/zero file' and then a `cp file /dev/null' to really see
>> what happens.
>
>In the first case, the buffer cache will grow without
>bounds and without it being needed. In the second case
>the page cache will grow a bit too much.

10Mbyte of 108 against 1Mbyte of 2.0.34 is not only a bit ;-).

>Both can be avoided by using (not yet implemented)
>balancing code. It is on the priority list of the MM

I had to ask "2.0.34 has balancing code implemented and running?". The
current mm layer is not able to shrink the cache memory and I consider it
a bug that must be fixed without adding other code. 

Is there a function call (such us shrink_mmap for mmap or
kmem_cache_reap() for slab or shrink_dcache_memory() for dcache) that is
able to shrink the cache allocated by cp file /dev/zero? I could also try
to apply to my kernel the memleak detector to see where the cache is
really allocated... 

>team, so we will be working on it some day. There

Good!

>are some stability issues to be solved first, however.

I wasn' t aware of these stability problems...

>Try the MM team first: linux-mm@kvack.org.
>Or read our TODO list: http://www.phys.uu.nl/~riel/mm-patch/todo.html

OK.

Andrea[s] Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
