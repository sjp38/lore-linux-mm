Date: Wed, 4 Sep 2002 19:46:39 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: nonblocking-vm.patch
In-Reply-To: <3D768C12.6CEBDA74@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209041944510.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2002, Andrew Morton wrote:
> Rik van Riel wrote:
> >
> > ...
> > Page_launder (shrink_cache) scans the inactive_dirty list.
> >
> > Pages which are ready to be reclaimed get moved to the inactive_clean
> > list, from where __alloc_pages() deals with them.
>
> The clang you heard was a penny.  (Nickel?  Dime?)
>
> So you have kswapd running page_launder most of the time, but under
> stress, page allocators will do it too.

kswapd (well, page_launde) moves pages from the inactive_dirty list to the
inactive_clean list.  Page allocators grab pages from the inactive_clean
list.

> With all this infrastructure, we can tell beforehand whether
> a writeout will block.  And I think that changes everything.  It
> presumably means that we can get quite a bit smarter in there - if
> kswapd sees a non-blockingly-writeable mapping, go write it and move
> the pages <here>.  If kswapd sees some dirty pages which might cause
> request queue blockage, then move them <there>.  If the caller is _not_
> kswapd then blocking is sometimes desirable, so do something else.

Absolutely.

> I think I'm pretty much finished mangling vmscan.c (honest).  Let
> me get the current stuff settled in and working not-completely-terribly,
> then you can get it working properly, OK?  Should be a few days more..
>
> I'll leave the additional instrumentation in place for the while, find some
> way of getting the kernel to spit it out on demand.

Sounds great.  Btw, what I have found is that once the right mechanism
is in place, additional tweaking of magic numbers achieves exactly ...
nothing.

A good mechanism balances itself.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
