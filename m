Message-ID: <3D767F45.97D8AAC9@zip.com.au>
Date: Wed, 04 Sep 2002 14:46:45 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: nonblocking-vm.patch
References: <3D767997.B6B76833@zip.com.au> <Pine.LNX.4.44L.0209041832100.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 4 Sep 2002, Andrew Morton wrote:
> 
> > > But only if enough IO completes. Otherwise we'll just end
> > > up doing too much scanning for no gain again.
> >
> > Well we want to _find_ the just-completed IO, yes?  Which implies
> > parking it onto the cold end of the inactive list at interrupt
> > time, or a separate list or something.
> 
> In rmap14 I'm doing the following things when scanning the
> inactive list:
> 
> 1) if the page was referenced, activate
> 2) if the page is clean, reclaim

OK.  We need to start getting some of that stuff going now.  We're
way too swappy at present.  I'll merge up your NRU/dropbehind
patch soon.  I imagine that you're waiting for me to stop changing
things.

> 3) if the page is written to disk, keep it at the end of
>    the list where we start scanning from

hum.  With the clustered-writeback-from-the-vm regime, this is
done over in mpage_writepages().  And that walks mapping->dirty_pages,
and moves the pages to the hot end of the inactive list (if they're
already on the inactive list).

I suppose we could just move them to the cold end and scan past them,
but that's a bit lazy.

They could be taken off the LRU altogether and reattached to the cold end
at IO completion.

But then, very little writeback actually happens from inside shrink_list.
 
> 4) if we don't write the page to disk (I don't submit too
>    much IO at once) we move it to the far end of the inactive
>    list
> 
> This means that the pages for which IO completed will be found
> somewhere near the start of the list.

OK.

(Why don't you move them over to inactive_dirty?  I've never understood
those two lists.  I suspect the names are misleading?)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
