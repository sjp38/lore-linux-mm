Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA24908
	for <linux-mm@kvack.org>; Wed, 18 Mar 1998 19:07:35 -0500
Date: Wed, 18 Mar 1998 21:16:24 GMT
Message-Id: <199803182116.VAA02805@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] pre3 corrections!
In-Reply-To: <Pine.LNX.3.95.980317104435.5051E-100000@penguin.transmeta.com>
References: <Pine.LNX.3.91.980317105548.385B-100000@mirkwood.dummy.home>
	<Pine.LNX.3.95.980317104435.5051E-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 17 Mar 1998 11:09:52 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> I decided that it was time to stop with the band-aid patches, and
> just wait for the problem to be fixed _correctly_

Indeed --- we've had a series of vm tuning/balancing fixups (remember
1.2.4/1.2.5 and 2.0.30?) which have improved a few cases but have made
for catastrophically bad worst-case behaviour.  If we are upgrading
the mechanism, we do finish that first and _then_ concentrate on
policy tuning.

> , which I didn't think this patch does:

> Basically, I consider any patch that adds another "nr_free_pages" 
> occurrence to be buggy. 

> Why? Because I have 512 MB (yes, that's half a gig) of memory, and I don't
> think it is valid to compare the number of free pages against anything,
> because they have so little relevance when they may not be the basic
> reason for why an allocation failed. 

Yes.

> That is why I want to have the "free_memory_available()" approach of
> checking that there are free large-page areas still, and continuing to
> swap out IN THE BACKGROUND when this isn't true. 

Absolutely, and this has the second advantage of clearly making the
distinction between the mechanism code and the decision-making policy
code.

> What I _think_ the patch should look like is roughly something like

> 	do {
> 		if (free_memory_available())
> 			break;
> 		gfp_mask = __GFP_IO;
> 		if (!try_to_free_page(gfp_mask))
> 			break;
> 		run_task_queue(&tq_disk); /* or whatever */
> 	} while (--tries);

Actually, I'm trying to eliminate some of the GFP_IO stuff in the
future.  Something I did a while ago was to separate out the page
scanner from the swap IO code, with separate kswapd and kswiod
threads.  That allows us to continue scanning for clean pages to free
even if the IO of dirty pages to disk is blocked.  A possible
extension would be to keep a reserved pool of buffer_heads for swap IO
(in much the same way that we have a static struct request pool), to
guarantee that the swapout code can never be deadlocked on memory
failure.

> (Btw, I think my original "free_memory_available()" function that only
> tested the highest memory order was probably a better one: the only reason
> it was downgraded was due to the interactive issues due to swap_tick() and
> the pageout loop disagreeing about when things should be done). 

I'd actually like to see _all_ memory scanning reclamation done from
within kswapd.  It makes it much more obvious where and when things
are being done.  There's no reason why we can't simply wakeup kswapd
and block on a free-memory waitq (or perhaps semaphore, but that's
more messy) when we are want to wait for free memory.  If free_page()
wakes up that waitq, then we have all the synchronisation we need, but
with several advantages.  In particular, we can minimise context
switching and mmscan restart overhead by keeping in kswapd until we
have freed a small number of pages (still minimising the per-run CPU
usage, of course).  I'm still open to persuasion either way on this
one, since at least some cases (such as a single task reclaiming page
cache) may run more slowly due to the extra context switch necessary,
but if kswapd is doing its job properly anyway then there's no point
in letting *everybody* dabble in page reclamation.

> One other thing that should probably be more aggressively looked
> into: the buffer cache. It used to be that the buffer cache was of
> supreme importance for performance, and we needed to keep the buffer
> cache big because it was also our source of shared pages. That is no
> longer true.

> These days we should penalize the buffer cache _heavily_: _especially_
> dirty data pages that have been written out should generally be thrown
> away as quickly as possible instead of leaving them in memory. 

True, and on my TODO list.  I really want to make writes do a
write-through from the page cache, and use alias buffer_heads to mark
the dirty data.  This requires minimal change to the existing code,
but eliminates our extra copy, keeps the written data in the page
cache where it can be found again more quickly, and makes it simple to
keep parity between read and write data in the page cache.  

Having said that, Linus, there is a _big_ problem with penalising the
buffer cache today.  If there is no space to grow the buffer cache,
then getting a new buffer tries to reuse an old one rather than obtain
a new free page for the cache.  If the use of the buffer cache is
readonly, then it is easy to find an unused buffer, so we can end up
making heavy use of the buffer cache but only having a handful of
buffers there.  I've spotted quite busy machines doing lots of
directory tree access but with only a dozen or so pages of buffer
cache, and you can hear the results as the disk is thrashing
unnecessarily.  This is also a major limiting factor in swap file
performance, since we end up thrashing the swap file's inode
indirection blocks for the same reason.

So, we do need to be careful to avoid arbitrarily penalising _all_ use
of the buffer cache.  Writes are the obvious target for elimination
from memory, but other buffers may be much more valuable to us: I
think all metadata buffers ought to get more, not less, protection
than they have right now, since this is generally random-access data
which is more expensive to reread than sequential file data.

> Not immediately, because re-writing parts of some file is fairly
> common, but they should be aged much more aggressively (but we
> should not age the metadata pages all that quickly - only the pages
> we have used for write-outs).

Doing writes through the page cache, combined with a variant on Ben's
page queues, should allow us to identify such pages quite easily.

Cheers,
 Stephen.
