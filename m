Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA13083
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 10:57:32 -0500
Date: Tue, 26 Jan 1999 16:44:12 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.4.03.9901261314450.26867-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.990126162710.559D-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@nl.linux.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Dr. Werner Fink" <werner@suse.de>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 1999, Rik van Riel wrote:

> The only thing we really need now is a way to keep
> track of (and manage) that buffer of freeable pages.
> I believe Andrea has a patch for that -- we should
> check it out and incorporate something like that ASAP.

It's just running fine here. If somebody want to run it too, just
go in sync with my current tree:

	ftp://e-mind.com/pub/linux/arca-tree/2.2.0-pre9_arca-3.gz

When you'll press SHIFT+SCROLL-LOCK you'll see both a Free and Freeable
fields.  The freeable fields tell you how many freeable pages you have on
your machine between both the buffer and the file cache. And my VM just
autobalance in function of the percentage of freeable pages in the system.
This works very well.

The only remark of my implementation is that I added a check in the
free_pages() common path. Doing that the accounting of the freeable pages
in the cache it's been trivial. I didn't changed the way the cache is
allocated and deallocated because I wanted to see how much knowing the
freeable pages number could be useful in the try_to_free_pages() alogrithm
before going into major hacks. So now I have the right number with the
minimal changes with a bit (really only a bit) of overhead in
free_pages()). I am sure that the overhead I added in free_pages() is
_not_ noticable in benchmarks (it's the same of checking for __GFP_WAIT at
the start of every __get_free_pages()). 

> There are several reasons why we need it:
> - we should never run out of freeable pages
>   because that can introduce too much latency
>   and possibly even system instability

Hmm, that's look like mostly a performances probelem (but I am supposing
that try_to_free_pages() has a safe implementation of course ;). 

> - page aging only is effective/optimal when the
>   freeable buffer is large enough

Infact. This is the major point. And the nice side effect is that once the
freeable pages are balanced to a certain number, everything else between
cache and buffers got automagically balanced. We don't need min limitis of
buffers or of cache anymore and this allow to use _all_ the memory as
best.

> - when the freeable buffer is too large, we might
>   have too many soft pagefaults or other overhead
>   (not very much of a concern, but still...)

Agreed.

> - keeping a more or less fixed distance between
>   both hands could make the I/O less bursty and
>   improve system I/O performance

Exactly this is the other major point. Keeping a balance of freeable pages
force the algorithm do swapout and shrink_mmap in a way that scale very
well.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
