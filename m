Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA25960
	for <linux-mm@kvack.org>; Sun, 15 Sep 2002 09:57:51 -0700 (PDT)
Message-ID: <3D84BFC8.2D8A7592@digeo.com>
Date: Sun, 15 Sep 2002 10:13:44 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.34-mm2
References: <3D841C8A.682E6A5C@digeo.com> <Pine.LNX.4.44L.0209151156080.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Daniel Phillips <phillips@arcor.de>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Sat, 14 Sep 2002, Andrew Morton wrote:
> > Daniel Phillips wrote:
> 
> > > but that sure looks like the low hanging fruit.
> >
> > It's low alright.  AFAIK Linux has always had this problem of
> > seizing up when there's a lot of dirty data around.
> 
> Somehow I doubt the "seizing up" problem is caused by too much
> scanning.  In fact, I'm pretty convinced it is caused by having
> too much IO submitted at once (and stalling in __get_request_wait).

Yes, the latency is due to request queue contention.

Dirty data reaches the tail of the LRU and "innocent" processes are
forced to write it.  But the queue is full.  They sleep until 32
requests are free.  They wake; but so does the heavy dirtier.  The
heavy dirtier immediately fills the queue again.  The innocent
page allocator finds some more dirty data.  Repeat.

It's DoS-via-request queue.  It's made worse by the fact that
kswapd is also DoS'ed, so pretty much all tasks need to perform
direct reclaim.

There are also latency problems, with similar causes, when page-allocating
processes encounter under-writeback pages at the tail of the LRU, but
this happens less often.

> The scanning is probably not relevant at all and it may be
> beneficial to just ignore the scanning for now and do our best
> to keep the pages in better LRU order.
> 

Yes, I'm not particularly fussed about (moderate) excess CPU use in these
situations, and nor about page replacement accuracy, really - pages
are being slushed through the system so fast that correct aging of the
ones on the inactive list probably just doesn't count.

The use of "how much did we scan" to determine when we're out
of memory is a bit of a problem; but the main problem (of which
I'm aware) is that the global throttling via blk_congestion_wait()
is not a sufficiently accurate indication that "pages came clean
in ZONE_NORMAL" on big highmem boxes.

Processes which are performing GFP_KERNEL allocations can keep
on getting woken up for ZONE_HIGHMEM completion, and they eventually
decide it's OOM.  This has only been observed when the dirty memory
limits are manually increased a lot, but it points to a design problem.

I don't know what's going on in `contest', nor in Alex's X build.  We'll
see...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
