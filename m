Message-ID: <3D76549B.3C53D0AC@zip.com.au>
Date: Wed, 04 Sep 2002 11:44:43 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: nonblocking-vm.patch
References: <3D75E054.B341E067@zip.com.au> <Pine.LNX.4.44L.0209041030510.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 4 Sep 2002, Andrew Morton wrote:
> 
> > - If the page is dirty, and mapped into pagetables then write the
> >   thing anyway (haven't tested this yet).  This is to get around the
> >   problem of big dirty mmaps - everything stalls on request queues.
> >   Oh well.
> 
> I don't think we need this.  If the request queue is saturated, and
> free memory is low, the request queue is guaranteed to be full of
> writes, which will result in memory becoming freeable soon.
> 

OK.  But I've gone and removed just about all the VM throttling (with
some glee, I might add).

We do need something in there to prevent kswapd from going berzerk.
I'm thinking something like this:

- My code only addresses write(2) pagecache.  Need to handle the (IMO rare)
  situation of large amounts of dirty MAP_SHARED data.

  We do this by always writing it out, and blocking on the request queue.
  And by waiting on PageWriteback pages.  That's just the pre-me behaviour.
  Should be OK for a first pass.

- Similarly, always write out dirty pagecache, so we throttle on the swapdev's
  request queue.

Which I think just leaves us with the no-swap-available problem. In this case
we really do need to slow page allocators down (I think.  I haven't done _any_
swapless testing).

I have a new function in the block layer `blk_congestion_wait()' which will
make the caller take a nap until some request queue comes unblocked.   That's
probably appropriate.  There's a corner case where there's writeout underway, but
no queues are congested.  In that case we can probably add a wakeup to
end_page_writeback(), and kick it on every 32nd page or whatever.  I'll play
with that a bit.


Now, wrt the magical 40% thing.  I'm thinking that we can change it in
this manner:

maximum amount of dirty+writeback pagecache =
	min((total memory - mapped memory) / 2, 40% or memory)

(Need some more accurate logic to calculate "total memory")

This means that half of the pool of unmapped memory is available to
heavy writers.  So if the machine is busy with lots of mapped memory,
and a burst of writes happens then they will initially be throttled
back fairly hard.  But if the write activity continues, `mapped memory'
will shrink due to swapout and pageout, and the amount of memory which
is available to the heavy writer will climb until it hits the (configurable)
40%.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
