Date: Thu, 4 Jul 2002 22:49:19 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: vm lock contention reduction
In-Reply-To: <3D24F869.2538BC08@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207042244590.6047-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2002, Andrew Morton wrote:
> Rik van Riel wrote:

> > This is something that can be fixed with rmap, because the
> > kernel _will_ be able to do something useful with the anon
> > pages.
>
> I think that would be quite useful - we just need to be sure that if the
> pages aren't added to swapcache we should park them up on the active
> list out of the way.

Absolutely, that is critical.  It is all too easy to end up with
a TON of non-swappable pages on the inactive list and all the
easily evictable pages on the active list.

If only because the easily evictable pages tend to disappear
quickly and the non-swappable ones stick around forever.

> > Now we just need to get Arjan to tune the O(1) page launder
> > thing he was looking at ;)
>
> We keep seeing mysterious references to this. What is the idea
> behind it?

The idea is that when pages are evicted from the system they
traverse the inactive list _once_.

If a page is dirty, IO is started and the page is added to the
laundry list, if a page is clean it is moved to the clean list.

Every time we need more free pages we first check the clean list
(all pages there are freeable, guaranteed) and the first (few?)
pages of the laundry list. We continue taking pages off of the
laundry list until we've run into {a, too many} unfreeable pages.

This way we won't scan the inactive pages over and over again
every time we free a few.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
