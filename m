Message-ID: <3D2530B9.8BC0C0AE@zip.com.au>
Date: Thu, 04 Jul 2002 22:38:01 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <Pine.LNX.4.44L.0207042315560.6047-100000@imladris.surriel.com> <Pine.LNX.4.44.0207042135270.7343-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> ...
> Think batching. It's _more_ efficient to batch stuff than it is to try to
> switch back and forth between working and waiting as quickly as you can.

Yup.

I've been moaning about this for months.  Trivial example:  run
`vmstat 1' and then start pounding the disk.  vmstat will exhibit
very long pauses when *clearly* thousands of pages are coming
clean every second.  Unreasonably long pauses.   Sometimes in
get_request_wait(), sometimes in shrink_cache->wait_on_page/buffer.

We should be giving some of those pages to vmstat more promptly.
After all, that process is not a heavy allocator of pages.
 
> So don't just nod your heads when you see something that sounds sane.
> Think critically. And the critical thinking says:
> 
>  - you should wait the _maximum_ amount that
>    (a) is fair
>    (b) doesn't introduce bad latency issues
>    (c) still allows overlap of IO and processing
> 
> Get away from this "minimum wait" thing, because it is WRONG.

Well yes, we do want to batch work up.  And a crude way of doing that
is "each time 64 pages have come clean, wake up one waiter".  Or 
"as soon as the number of reclaimable pages exceeds zone->pages_min".
Some logic would also be needed to prevent new page allocators from
jumping the queue, of course.

We're still throttling on I/O, but we're throttling against
*any* I/O, and not a single randomly-chosen disk block.

This scheme is more fair - processes which are allocating more pages
get to wait more.

> Try to shoot me down, but do so with real logic and real arguments, not
> some fuzzy feeling about "we shouldn't wait unless we have to". We _do_
> have to wait.

Sure, page allocators must throttle their allocation rate to that at
which the IO system can retire writes.  But by waiting on a randomly-chosen
disk block, we're at the mercy of the elevator.  If you happen to
choose a page whose blocks are at the far side of the disk, you lose.
There could easily be 100 megabytes of reclaimable memory by the time
you start running again.

We can fit 256 seeks into the request queue.  That's 1-2 seconds.

I started developing a dumb prototype of this a while back, but
it locks up.   I'll dust it off and get it going as a "technology
demonstration".

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
