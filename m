Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA29273
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 17:10:19 -0500
Date: Wed, 25 Nov 1998 22:21:43 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <199811252102.VAA05466@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981125220910.15920A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: jfm2@club-internet.fr, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 1998, Stephen C. Tweedie wrote:
> <H.H.vanRiel@phys.uu.nl> said:
> 
> It is not there in 2.1.130-pre3, however. :) That misses the point,
> though.  The point is that it is trivial to remove these mappings
> without freeing the swap cache, and the code you point to confirms this:

OK, point taken. {:-)

> > Oh, one question. Can we attach a swap page to the swap cache
> > while there's no program using it? This way we can implement
> > a very primitive swapin readahead right now, improving the
> > algorithm as we go along...
> 
> Yes, rw_swap_page(READ, nowait) does exactly that: it primes the
> swap cache asynchronously but does not map it anywhere.  It should
> be completely safe right now: the normal swap read is just a special
> case of this. 

Then I think it's time to do swapin readahead on the
entire SWAP_CLUSTER (or just from the point where we
faulted) on a dumb-and-dumber basis, awaiting a good
readahead scheme. Of course it will need to be sysctl
tuneable :)

The reason I propose this dumb scheme is because we
can read one SWAP_CLUSTER_MAX sized chunk in one
sweep without having to move the disks head... Plus
Linus might actually accept a change like this :)

> > If we keep a quota of 20% of memory in buffers and unmapped
> > cache, we can also do away with a buffer for the 8 and 16kB
> > area's. We can always find some contiguous area in swap/page
> > cache that we can free...
> 
> That will kill performance if you have a large simulation which has a
> legitimate need to keep 90% of physical memory full of anonymous pages.
> I'd rather do without that 20% magic limit if we can.  The only special
> limit we really need is to make sure that kswapd keeps far enough in
> advance of interrupt memory load that the free list doesn't empty.

OK, then we should let the kernel calculate the limit itself
based on the number of soft faults, swapout pressure, memory
pressure and process priority.

We can also use stats like this to temporarily suspend very
large processes when we've got multiple processes with:
 (p->vm_mm->rss + p->dec_flt) > RSS_THRASH_LIMIT, where
p->dec_flt is a floating average and the RSS limit is
calculated dynamically as well... I know this could be
a slightly expensive trick, but we can easily make that
sysctl tuneable as well.

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
