Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA28170
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 14:00:48 -0500
Date: Wed, 25 Nov 1998 17:47:18 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <199811251446.OAA01094@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981125173723.11080C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: jfm2@club-internet.fr, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 1998, Stephen C. Tweedie wrote:
> On Wed, 25 Nov 1998 14:08:47 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > If we tried to implement RSS limits now, it would mean that
> > the large task(s) we limited would be continuously thrashing
> > and keep the I/O subsystem busy -- this impacts the rest of
> > the system a lot.
> 
> WRONG.  We can very very easily unlink pages from a process's pte
> (hence reducing the process's RSS) without removing that page from
> memory.  It's trivial.  We do it all the time.  Rik, you should
> probably try to work out how try_to_swap_out() actually works one of
> these days.

I just looked in mm/vmscan.c of kernel version 2.1.129, and
line 173, 191 and 205 feature a prominent:
			free_page_and_swap_cache(page);

> We are really a lot closer to having a proper unified page handling
> mechanism than you think.  The handling of dirty pages is pretty
> much the only missing part of the mechanism right now. 

I know how close we are. I think I posted an assesment on
what to do and what to leave yesterday :)) The most essential
things can probably be coded in a day or two, if we want to.

Oh, one question. Can we attach a swap page to the swap cache
while there's no program using it? This way we can implement
a very primitive swapin readahead right now, improving the
algorithm as we go along...

> Even that is not necessarily a bad thing: there are good performance
> reasons why we might want the swap cache to contain only clean
> pages:  for example, it makes it easier to guarantee that those
> pages can be reclaimed for another use at short notice. 

IMHO it would be a big loss to have dirty pages in the swap
cache. Writing out swap pages is cheap since we do proper
I/O clustering, not writing them out immediately will result
in them being written out in the order that shrink_mmap()
comes across them, which is a suboptimal way for when we
want to read the pages back.

Besides, having a large/huge clean swap cache means that we
can very easily free up memory when we need to, this is
essential for NFS buffers, networking stuff, etc.

If we keep a quota of 20% of memory in buffers and unmapped
cache, we can also do away with a buffer for the 8 and 16kB
area's. We can always find some contiguous area in swap/page
cache that we can free...

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
