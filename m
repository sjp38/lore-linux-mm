Date: Wed, 4 Sep 2002 19:12:02 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: nonblocking-vm.patch
In-Reply-To: <3D767F45.97D8AAC9@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209041909430.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2002, Andrew Morton wrote:

> OK.  We need to start getting some of that stuff going now.  We're
> way too swappy at present.  I'll merge up your NRU/dropbehind
> patch soon.  I imagine that you're waiting for me to stop changing
> things.

You seemed busy enough already ;)

> > 3) if the page is written to disk, keep it at the end of
> >    the list where we start scanning from
>
> hum.  With the clustered-writeback-from-the-vm regime, this is
> done over in mpage_writepages().  And that walks mapping->dirty_pages,
> and moves the pages to the hot end of the inactive list (if they're
> already on the inactive list).
>
> I suppose we could just move them to the cold end and scan past them,
> but that's a bit lazy.

Better yet, just leave them in place and scan over them only if
they aren't cleaned yet when they reach the end of the list.

The closer page reclaim is done to pure LRU order, the smoother
the VM seems to work. Quite possibly this is a side effect of
not doing too much IO at once, but still ... ;)

> > 4) if we don't write the page to disk (I don't submit too
> >    much IO at once) we move it to the far end of the inactive
> >    list
> >
> > This means that the pages for which IO completed will be found
> > somewhere near the start of the list.
>
> OK.
>
> (Why don't you move them over to inactive_dirty?  I've never understood
> those two lists.  I suspect the names are misleading?)

Sorry, I should have been clearer here.

Page_launder (shrink_cache) scans the inactive_dirty list.

Pages which are ready to be reclaimed get moved to the inactive_clean
list, from where __alloc_pages() deals with them.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
