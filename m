Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA19032
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 20:06:43 -0500
Date: Mon, 30 Nov 1998 20:29:35 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <871zmldxkd.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.981130202517.274A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 30 Nov 1998, Zlatko Calusic wrote:
> Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> > that (or abolish the percentages completely) kswapd
> > doesn't have an incentive to switch from a succesful
> > round of swap_out() -- which btw doesn't free any
> > actual memory so kswapd just continues doing that --
> > to shrink_mmap().
> 
> Yep, this is the conclusion of my experiments, too.

> I made the following change in do_try_to_free_page():

[SNIP]

> Unfortunately, this really killed swapout performance, so I dropped
> the idea. Even letting swap_out do more passes, before changing state, 
> didn't feel good.
> 
> One other idea I had, was to replace (code at the very beginning of
> do_try_to_free_page()):
> 
> 	if (buffer_over_borrow() || pgcache_over_borrow())
> 		shrink_mmap(i, gfp_mask);
> 
> with:
> 
> 	if (buffer_over_borrow() || pgcache_over_borrow())
> 		state = 0;

I am now trying:
	if (buffer_over_borrow() || pgcache_over_borrow() ||
			atomic_read(&nr_async_pages)
		shrink_mmap(i, gfp_mask);

Note that this doesn't stop kswapd from swapping out so
swapout performance shouldn't suffer. It does however
free up memory so kswapd should _terminate_ and keep the
amount of I/O done to a sane level.

Note that I'm running with my experimentas swapin readahead
patch enabled so the system should be stressed even more
than normally :)

cheers,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
