Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA16980
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 14:44:27 -0500
Date: Mon, 30 Nov 1998 13:37:37 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <8767c0q55d.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.981130133229.17889E-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 27 Nov 1998, Zlatko Calusic wrote:
> "Stephen C. Tweedie" <sct@redhat.com> writes:
> 
> > The real problem seems to be that shrink_mmap() can fail for two
> > completely separate reasons.  First of all, we might fail to find a
> > free page because all of the cache pages we find are recently
> > referenced.  Secondly, we might fail to find a cache page at all.
> 
> Yesterday, I was trying to understand the very same problem you're
> speaking of. Sometimes kswapd decides to swapout lots of things,
> sometimes not.
> 
> I applied your patch, but it didn't solve the problem.
> To be honest, things are now even slightly worse. :(

The 'fix' is to lower the borrow percentages for both
the buffer cache and the page cache. If we don't do
that (or abolish the percentages completely) kswapd
doesn't have an incentive to switch from a succesful
round of swap_out() -- which btw doesn't free any
actual memory so kswapd just continues doing that --
to shrink_mmap().

Another thing we might want to try is inserting the
following test in do_try_to_free_page():

if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster)
	state = 0;

This will switch kswapd to shrink_mmap() when we have enough
pages queued for efficient swap I/O. Of course this 'fix'
decreases swap throughput so we might want to think up something
more clever instead...

regards,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
