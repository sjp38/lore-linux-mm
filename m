Date: Mon, 2 Sep 2002 17:50:11 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: About the free page pool
In-Reply-To: <3D73CB28.D2F7C7B0@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209021747250.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Sep 2002, Andrew Morton wrote:

> > How important is it to maintain a list of free pages?  That is, how
> > critical is it that there be some pool of free pages from which the only
> > bookkeeping required is the removal of that page from the free list.
>
> There are several reasons, all messy.

[snip]

> It's feasible.  It'd take some work.  Probably it would best be implemented
> via a third list.  That list would be protected by an IRQ-safe lock,

I don't think we need to bother with the IRQ-safe part.

It's much simpler if we just do:

1) have a normal free list, but have it smaller ...
   say, between zone->pages_min and zone->pages_low

2) if the free pages drop below the low water mark,
   have either a normal allocator or a kernel thread
   refill it to the high water mark, from the clean
   pages list

3) have the free+clean target set to something higher,
   say zone->pages_high ... we could even tune this
   automatically, if we run out of free+clean pages too
   often kswapd should probably try to keep more pages
   clean

What do you think, would this work?

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
