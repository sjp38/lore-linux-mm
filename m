Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19172
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 14:09:58 -0500
Date: Wed, 13 Jan 1999 19:52:03 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [PATCH] Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901131755.RAA06476@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990113191421.185E-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 1999, Stephen C. Tweedie wrote:

> I think this is the wrong solution: far better to do the patch below,
> which simply exempts reads from nr_async_pages altogether.  I
> originally added nr_async_pages to serve two functions: to allow
> kswapd to determine how much memory it was already in the process of
> freeing, and to act as a throttle on the number of write IOs submitted
> when swapping.
> 
> We don't need a similar throttling action for reads, because every
> place where we do VM readahead, each readahead IO cluster is followed
> by a synchronous read on one page.  We don't throttle the async
> readaheads on normal file IO, for example.

Note that we don't need nr_async_pages at all. Here when the limit of
nr_async_pages is low it's only a bottleneck for swapout performances. I
have not removed it (because it could be useful to decrease swapout I/O if
somebody needs this strange feature), but I have added a
page_daemon.max_async_pages and set it to something like 256. Now I check
nr_async_pages against the new max_async_pages. 

I _guess_ (not checked) that the _only_ reason Steve seen arca-vm-16 so
high improved changing SWAP_CLUSTER_MAX to 512 instead of 32 is the
removal of the nr_async_pages bottleneck. 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
