Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA13688
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 20:22:11 -0500
Date: Tue, 17 Nov 1998 17:21:23 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <199811180109.BAA04628@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981117171051.1077V-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Wed, 18 Nov 1998, Stephen C. Tweedie wrote:
> 
> When we get a try_to_free_pages() from get_free_pages(), we are
> basically saying "I want free memory, and I can't do anything until
> you give it to me".  If we are in this state and don't set the io
> wait, we can happily submit SWAP_CLUSTER_MAX pages to the IO request
> layer and return without actually having freed up any memory.  That
> doesn't help the allocation to succeed and in the worst case may cause
> a swap IO flood.

Yes. But in that case we already have __GPF_IO set, so in this case we
_will_ wait synchronously.

It's only kswapd that does this asynchronously as far as I can see, and
it's ok for kswapd to not be that asynchronous. It just must not be _too_
asynchronous - we must decide to start the requests at some point, to make
sure there aren't too many things in transit. 

So the difference in behaviour then becomes one of "does kswapd actually
start to synchronously wait on certain pages when it's done a lot of
asynchronous requests" or "should kswapd just make sure that the async
requests go out in an orderly manner"? 

I don't know. Maybe waiting synchronously every once in a while is the
right answer. 

> Linus, the reason I proposed the breakout on (nr_free_pages >
> freepages.max + SWAP_CLUSTER_MAX) in try_to_free_pages() was because
> as soon as you have a significant number of memory hungry processes
> trying to allocate in a low memory situation, they all start swapping
> out SWAP_CLUSTER_MAX pages.  That's a significant amount of memory.
> Is there any particular reason you omited that patch from
> 2.1.129-pre5?

We shouldn't have gotten to try_to_free_pages() unless kswapd couldn't
keep up with the number of memory allocations, and in that case I think
the right answer _is_ to let everybody who wants to get memory free up
noticeable more memory than they need - we don't want to get into the
trickle situation where we are constantly trickling out a small amount of
swapspace. 

>		  It occurs to me that restoring this check would
> actually be quite a good way of making sure that a normal
> get_free_pages() doesn't enter a stalling try_to_free_pages()
> unnecessarily, which would address some of the negative performance
> implications of having the nr_async_pages stall in page_io.c.

I don't want a normal get_free_pages() ever to get even _close_ to calling
try_to_free_pages(). The normal action should be that kswapd happily
throws out pages at the same rate they are needed, so that any other
process never needs to get into try_to_free_pages() at all. 

Whenever you see processes that actually try to synchronously free memory,
you're much much too low on memory already. At least that's the idea, and
that's why I thought your patch was not right. 

I do know that my system feels a _lot_ better with recent kernels, now
that the main heavy lifting is done by kswapd. Interactive performance is
just great (and yes, I have half a gig of RAM, but I still page heavily
occasionally), so I'm fairly certain that this is basically the right
approach. 

But whether kswapd should go page-synchronous at some point? Maybe. I can
see arguments both for and against (the "for" argument is that we prefer
to have more intense bouts of IO followed by a nice clean wait, while the
"against" argument is that maybe we want to spread out the thing). 

Still looking for more argument..

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
