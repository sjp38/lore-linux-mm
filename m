Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21591
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:36:55 -0500
Date: Sun, 10 Jan 1999 19:33:42 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <Pine.LNX.3.95.990109213225.4665G-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990110191755.327I-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, 9 Jan 1999, Linus Torvalds wrote:

> Can you run pre6+zlatko with just the mm/page_alloc.c one-liner reverted
> to pre5? That is, take pre6+zlatko, and just change 

I have no time to try code these days :(

> 	try_to_free_pages(gfp_mask, freepages.high - nr_free_pages);
> 
> back to
> 
> 	try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX);
> 
> That particular one-liner was almost certainly a mistake, it was done on
> the mistaken assumption that the clustering problem was due to
> insufficient write-time clustering - while zlatko found that it was
> actually due to fragmentation in the swap area. With zlatkos patch, the
> original SWAP_CLUSTER_MAX is probably better and almost certainly results
> in smoother behaviour due to less extreme free_pages.. 

I don't know which is zlatkos patch but my point is that it's
try_to_free_pages that has to care to be balanced and to do things at
best. I want to be allowed to ask try_to_free_pages to free any kind of
space and such function has to run _always_ efficient. 

My current free_user_and_cache() (arca-vm-13) is bad because it doesn't
swapout aggressively. I am fixing it right now. When I'll have finished
I'll post the new patch.

BTW, the reason pre6 is slower than my current _bad_ free_user_and_cache() 
(arca-vm-13) in low memory machines is that in high memory machines the
freepages.min is something like 255 while in low memory machines
freepages.min it's close to SWAP_CUSTER_MAX. So in low memory machines the
swapout cluster has to be reduced (because now swapout doesn't free
pages). free_user_and_cache() has to care about these issues and I see
plain wrong to hardwire the swap cluster size to a constant number since
the freepages values are dynamic (and also changable via sysctl).

I am not sure of all this, but this is currently my thought.

Comments?

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
