Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA26514
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 14:00:52 -0500
Date: Tue, 1 Dec 1998 19:32:52 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead
In-Reply-To: <87vhjvkccu.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.981201192554.4046A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 1 Dec 1998, Zlatko Calusic wrote:
> Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> > In my experience allocations aren't the big problem but
> > deallocations. I guess we lose some memory there :(
> 
> Yes. something like that. Since nobody asked pages to swap in (we
> decided to swap them in) it looks like nobody frees them. :)
> So we should free them somewhere, probably.

I took the bet that shrink_mmap() would take care of that, but
aperrantly not always :(

> > > Also, looking at the patch source, it looks like the comment there is
> > > completely misleading, as the for() loop is not doing anything, at

> +		read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset),
> +0);
> +			break;
> +	}               ^^^^^^
> 
> Last break in the for() loop, exits the loop after the very first
> pass. Why don't you get get rid of the loop, then:

Whoops, this break was left there from a previous editing
round and is removed now. I completely oversaw that one,
I guess that means I should go over the code with a comb
now... :)

> I wish you luck with the swapin readahed. I'm also very interested
> in the impact it could made, since my tests revealed that swapping
> in adjacent pages from swap is quite common operation, so in some
> workloads it could be a big win (hogmem, for instance, would
> probably be much faster :)). 

For the pure readahead cache system we'd only need a 10%
hit rate to increase performance twofold (Rogier Wolff and
I calculated this once on the transfer/seek ratio of disks).

Of course a 10% hit ratio means we swap out 90% of stuff
that'd otherwise stay in memory, so it's not a clear picture
at all.

We probably want to increase the readahead when we satisfy
more than 20% of all page faults (that involve a swap area)
from the cache and decrease it when we go below 10%.

Then, of course, we'd also need to weigh average over a minute
or 300 swapins, whichever takes longer. And we need to take
memory and I/O pressure into account so we don't fill up memory
and I/O bandwidth with useless work...

cheers,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
