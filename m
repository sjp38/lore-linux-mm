Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA15558
	for <linux-mm@kvack.org>; Wed, 18 Nov 1998 04:19:44 -0500
Date: Wed, 18 Nov 1998 09:19:34 GMT
Message-Id: <199811180919.JAA00748@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <Pine.LNX.3.95.981117171051.1077V-100000@penguin.transmeta.com>
References: <199811180109.BAA04628@dax.scot.redhat.com>
	<Pine.LNX.3.95.981117171051.1077V-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 17 Nov 1998 17:21:23 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> On Wed, 18 Nov 1998, Stephen C. Tweedie wrote:

> Yes. But in that case we already have __GPF_IO set, so in this case we
> _will_ wait synchronously.

Right.

> It's only kswapd that does this asynchronously as far as I can see, and
> it's ok for kswapd to not be that asynchronous. It just must not be _too_
> asynchronous - we must decide to start the requests at some point, to make
> sure there aren't too many things in transit. 

That's exactly my concern, and if it's only kswap which is using the
async code then I don't think it matters too much _where_ we do the
nr_async_pages check.

> So the difference in behaviour then becomes one of "does kswapd actually
> start to synchronously wait on certain pages when it's done a lot of
> asynchronous requests" or "should kswapd just make sure that the async
> requests go out in an orderly manner"? 

There's a related question: should kswapd keep on swapping at all once
it has submitted enough async IO?  Beyond a certain point we _know_ that
these pages will become free; swapping even more dirty pages won't help
us.  There's only any point in kswapd carrying on if we restrict
ourselves to unmapping clean pages: that's the only way we'll actually
increase the free page count right now.

So, should try_to_swap_out skip dirty pages if nr_async_pages is too
high?  This sounds like an attractive answer, if we are below
freepages.low, becuase it will let kswapd find free memory for interrupt
traffic.  If we aren't that low in memory then we don't want to be
unnecessarily unfair to clean pages.

I'm off to SANE now --- back next week.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
