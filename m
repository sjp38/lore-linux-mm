Date: Sat, 25 Sep 1999 16:27:52 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: SV: Need ammo against BSD Fud
In-Reply-To: <015f01bf0473$53fb6e00$daa80ec2@xinit.se>
Message-ID: <Pine.LNX.4.10.9909251615280.1083-100000@laser.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Eric =?ISO-8859-1?Q?Sandstr=F6m?= <hes@xinit.se>
Cc: Rik van Riel <riel@humbolt.geo.uu.nl>, JF Martinez <jfm2@club-internet.fr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[..]
>    shared reference count to manage swap usage.  The overhead is around 
>    3 bytes per swap page (whether it is in use or not), and another pte-sized

The swap_map only needs two bytes per swap page.

>    Linux appears to map all of physical memory into KVM.  This avoids
>    FreeBSD's (struct buf) complexity at the cost of not being able to 
>    deal with huge-memory configurations.  I'm not 100% sure of this, but

In linux 2.3.x it's just been merged the additional code to handle huge
memory configurations without adding any real complexity to the code.

>    Swap allocation is terrible.  Linux uses a linear array which it scans
>    looking for a free swap block.  It does a relatively simple swap
>    cluster cache, but eats the full linear scan if that fails which can be
>    terribly nasty.  The swap clustering algorithm is a piece of crap, 
>    too -- once swap becomes fragmented, the linux swapper falls on its face.
>    It does read-ahead based on the swapblk which wouldn't be bad if it
>    clustered writes by object or didn't have a fragmentation problem.
>    As it stands, their read clustering is useless.  Swap deallocation is 

I fixed this in 2.3.x. I implemented an anti-swap-fragmentation algorithm
and it's just merged in 2.3.18.

>    File read-ahead is half-hazard at best.

read-ahead simply read ahead in the swap. As the swap is going to be low
fragmented these days also the swap readahead will improve.

>    The paging queues ( determing the age of the page and whether to 
>    free or clean it) need to be written... the algorithms being used
>    are terrible.

I implemented a real page-LRU mixed with the reference bit that is set at
every search hit in the buffer cache and in the page cache. My code is
just in 2.3.x.

>     * For the nominal page scan, it is using a one-hand clock algorithm.  
>       All I can say is:  Oh my god!  Are they nuts?  That was abandoned
>       a decade ago.  The priority mechanism they've implemented is nearly
>       useless.

My page-LRU in 2.3.x kills completly the clock algorithm.

>     * To locate pages to swap out, it takes a pass through the task list. 
>       Ostensibly it locates the task with the largest RSS to then try to
>       swap pages out from rather then select pages that are not in use.

Wrong. This is wrong also for 2.2.x as we swapout pages that have not the
accessed bit set in the pte.

>    Linux does not appear to do any page coloring whatsoever, but it would
>    not be hard to add it in.

It seems that page colouring is not interesting for i386 (except for
some not usual case).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
