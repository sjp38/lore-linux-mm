Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA17125
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 15:06:30 -0500
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
References: <Pine.LNX.3.96.981130133229.17889E-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 30 Nov 1998 16:12:18 +0100
In-Reply-To: Rik van Riel's message of "Mon, 30 Nov 1998 13:37:37 +0100 (CET)"
Message-ID: <871zmldxkd.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> On 27 Nov 1998, Zlatko Calusic wrote:
> > "Stephen C. Tweedie" <sct@redhat.com> writes:
> > 
> > > The real problem seems to be that shrink_mmap() can fail for two
> > > completely separate reasons.  First of all, we might fail to find a
> > > free page because all of the cache pages we find are recently
> > > referenced.  Secondly, we might fail to find a cache page at all.
> > 
> > Yesterday, I was trying to understand the very same problem you're
> > speaking of. Sometimes kswapd decides to swapout lots of things,
> > sometimes not.
> > 
> > I applied your patch, but it didn't solve the problem.
> > To be honest, things are now even slightly worse. :(
> 
> The 'fix' is to lower the borrow percentages for both
> the buffer cache and the page cache. If we don't do
> that (or abolish the percentages completely) kswapd
> doesn't have an incentive to switch from a succesful
> round of swap_out() -- which btw doesn't free any
> actual memory so kswapd just continues doing that --
> to shrink_mmap().

Yep, this is the conclusion of my experiments, too.

> 
> Another thing we might want to try is inserting the
> following test in do_try_to_free_page():
> 
> if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster)
> 	state = 0;
> 
> This will switch kswapd to shrink_mmap() when we have enough
> pages queued for efficient swap I/O. Of course this 'fix'
> decreases swap throughput so we might want to think up something
> more clever instead...
> 

Exactly.

It is funny how we tried same things in order to find a solution. :)

I made the following change in do_try_to_free_page():

(writing from memory, notice the concept)

...
		case 2:
>>			swapouts++;
>>			if (swapouts > pager_daemon.swap_cluster) {
>>				swapouts = 0;
>>				state = 3;
>>			}
			if (swap_out(i, gfp_mask))
				return 1;
			state = 3;
		case 3:
			shrink_dcache_memory(i, gfp_mask);
			state = 0;
		i--;
		} while (i >= 0);


Unfortunately, this really killed swapout performance, so I dropped
the idea. Even letting swap_out do more passes, before changing state, 
didn't feel good.

One other idea I had, was to replace (code at the very beginning of
do_try_to_free_page()):

	if (buffer_over_borrow() || pgcache_over_borrow())
		shrink_mmap(i, gfp_mask);

with:

	if (buffer_over_borrow() || pgcache_over_borrow())
		state = 0;

While this looks like a good idea, it in fact makes kswapd a CPU hog,
and also doesn't help performance, because it makes limits too hard,
and there's slight debalance.

I'll keep hacking... :)
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	  If you don't think women are explosive, drop one!
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
