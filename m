Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA31963
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 02:35:18 -0500
Date: Thu, 26 Nov 1998 08:30:20 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <199811252229.WAA05737@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981126082011.24048K-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: jfm2@club-internet.fr, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 1998, Stephen C. Tweedie wrote:
> On Wed, 25 Nov 1998 22:21:43 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > Then I think it's time to do swapin readahead on the
> > entire SWAP_CLUSTER
> 
> Yep, although I'm not sure that reading a whole SWAP_CLUSTER would
> be a good idea.  Contrary to popular belief, disks are still quite
> slow at sequential data transfer.

I have a better idea for a default limit:
	swap_stream.max = num_physpages >> 9;
	if (swap_stream.max > SWAP_CLUSTER_MAX)
		swap_stream.max = SWAP_CLUSTER_MAX;
	swap_stream.enabled = 0;

> Non-sequential IO is obviously enormously slower still, but doing
> readahead on a whole SWAP_CLUSTER (128k) is definitely _not_ free. 
> It will increase the VM latency enormously if we start reading in a
> lot of unnecessary data. 

We could simply increase the readahead if we were more
than 50% succesful (ie. 80% of swap requests can be
satisfied from the swap cache) and decrease it if we
drop below 40% (or less than 50% of swap requests can
be serviced from the swap cache).

One thing that helps us enormously is the way kswapd
pages out stuff. If pages (within a process) have the
same kind of usage pattern and are near eachother, they
will be swapped out together. Now since they have the
same usage pattern, it is likely that they are needed
together as well.

Especially without page aging we are likely to store
adjecant pages next to eachother in swap.

Later on (when the simple code has been proven to
work and Linus doesn't pay attention) we can introduce
a really intelligent swapin readahead mechanism that
will make Linux rock :)

It's just that we need something simple now because
Linus wants the kernel to stay relatively unchanged
at the moment...

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
