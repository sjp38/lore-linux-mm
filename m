Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA13590
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 20:09:58 -0500
Date: Wed, 18 Nov 1998 01:09:41 GMT
Message-Id: <199811180109.BAA04628@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <Pine.LNX.3.95.981117151133.1077O-100000@penguin.transmeta.com>
References: <Pine.LNX.3.96.981117211632.12547C-100000@mirkwood.dummy.home>
	<Pine.LNX.3.95.981117151133.1077O-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Stephen C. Tweedie" <sct@redhat.com>, Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 17 Nov 1998 15:14:10 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> I think it should be in the original position (inside the kswapd loop), I
> think removing it was probably a mistake. I prefer Stephens test there
> rather than in page_io (setting "wait" in page_io.c has more ramifications
> than just getting the IO started, I'm not sure we really actually want to
> wait on the page). 

First, I think it's just a performance issue: I _think_ there are no
correctness issues, since the IO always has a chance to block anyway
(on the request queue if nothing else).  If anyone can spot a
correctness issue then shout!

The main benefit from having the nr_async_pages check in page_io.c is
that this way it also throttles the try_to_free_pages() loop during
normal allocations.

When we get a try_to_free_pages() from get_free_pages(), we are
basically saying "I want free memory, and I can't do anything until
you give it to me".  If we are in this state and don't set the io
wait, we can happily submit SWAP_CLUSTER_MAX pages to the IO request
layer and return without actually having freed up any memory.  That
doesn't help the allocation to succeed and in the worst case may cause
a swap IO flood.

It's not just kswapd which can have the problem of submitting massive
unreasonable swap activity: because get_free_pages() can also submit
async swapout, doing the nr_async_pages check in page_io.c makes sure
we catch both cases.  Andi Kleen has observed massive over-swap (to
the tune of 20 to 40MB at a time) when doing parallel makes: it
doesn't happen on single-threaded make, which suggests that it is not
only kswapd which can cause the swap floods.

Linus, the reason I proposed the breakout on (nr_free_pages >
freepages.max + SWAP_CLUSTER_MAX) in try_to_free_pages() was because
as soon as you have a significant number of memory hungry processes
trying to allocate in a low memory situation, they all start swapping
out SWAP_CLUSTER_MAX pages.  That's a significant amount of memory.
Is there any particular reason you omited that patch from
2.1.129-pre5?  It occurs to me that restoring this check would
actually be quite a good way of making sure that a normal
get_free_pages() doesn't enter a stalling try_to_free_pages()
unnecessarily, which would address some of the negative performance
implications of having the nr_async_pages stall in page_io.c.

--Stephen


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
