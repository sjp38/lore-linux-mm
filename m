Message-ID: <3D768C12.6CEBDA74@zip.com.au>
Date: Wed, 04 Sep 2002 15:41:22 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: nonblocking-vm.patch
References: <3D767F45.97D8AAC9@zip.com.au> <Pine.LNX.4.44L.0209041909430.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> ...
> Page_launder (shrink_cache) scans the inactive_dirty list.
> 
> Pages which are ready to be reclaimed get moved to the inactive_clean
> list, from where __alloc_pages() deals with them.
> 

The clang you heard was a penny.  (Nickel?  Dime?)

So you have kswapd running page_launder most of the time, but under
stress, page allocators will do it too.

With all this infrastructure, we can tell beforehand whether
a writeout will block.  And I think that changes everything.  It
presumably means that we can get quite a bit smarter in there - if
kswapd sees a non-blockingly-writeable mapping, go write it and move
the pages <here>.  If kswapd sees some dirty pages which might cause
request queue blockage, then move them <there>.  If the caller is _not_
kswapd then blocking is sometimes desirable, so do something else.

I think I'm pretty much finished mangling vmscan.c (honest).  Let
me get the current stuff settled in and working not-completely-terribly,
then you can get it working properly, OK?  Should be a few days more..

I'll leave the additional instrumentation in place for the while, find some
way of getting the kernel to spit it out on demand.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
