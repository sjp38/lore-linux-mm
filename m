Message-ID: <3D79250B.6D705166@zip.com.au>
Date: Fri, 06 Sep 2002 14:58:35 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: inactive_dirty list
References: <3D7920E8.5E22D27B@zip.com.au> <Pine.LNX.4.44L.0209061845280.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Fri, 6 Sep 2002, Andrew Morton wrote:
> 
> > > It also meant we could have dirty (or formerly dirty) inactive
> > > pages eating up memory and never being recycled for more active
> > > data.
> >
> > The interrupt-time page motion should reduce that...
> 
> Not if you won't scan the dirty list as long as there are "enough"
> clean pages.

Well, something needs to start writeback of dirty pages.  That
is either:

- The VM kicked pdflush or

- We're over dirty limit, so the write(2) callers do it or

- The kupdate function syncs the data.

So why do we need to perform writeback from the VM?  Just for
swapcache, which pdflush doesn't do.

> > > What you need to do instead is:
> > >
> > > - inactive_dirty contains pages from which we're not sure whether
> > >   they're dirty or clean
> > >
> > > - everywhere we add a page to the inactive list now, we add
> > >   the page to the inactive_dirty list
> > >
> > > This means we'll have a fairer scan and eviction rate between
> > > clean and dirty pages.
> >
> > And how do they get onto inactive_clean?
> 
> Once IO completes they get moved onto the clean list.

But if there are clean pages accidentally on inactive_dirty,
we need to scan for them.  If that list only contains
dirty pagecache and pagecache which is under writeback, then
there should be no need to scan it?  Those pages will automatically
come back onto inactive_clean via pdflush/balance_dirty_pages writeout.
 
> > > We can also get rid of this logic. There is no difference between
> > > swap pages and mmap'd file pages. If blk_congestion_wait() works
> > > we can get rid of this special magic and just use it. If it doesn't
> > > work, we need to fix blk_congestion_wait() since otherwise the VM
> > > would fall over under heavy mmap() usage.
> >
> > That would probably work.  We'd need to do the pte_dirty->PageDirty
> > translation carefully.
> 
> Indeed. We probably want to give such pages a second chance on
> the inactive_dirty list without starting the writeout, so we've
> unmapped and PageDirtied all its friends for one big writeout.
> 
> > > With this scheme, we can restrict tasks to scanning only the
> > > inactive_clean list.
> > >
> > > Kswapd's scanning of the inactive_dirty list is always asynchronous
> > > so we don't need to worry about latency.  No need to waste CPU by
> > > having other tasks also scan this very same list and submit IO.
> >
> > Why does kswapd need to scan that list?
> 
> The list should preferably only be scanned by one thread.
> Scanning with multiple threads is a waste of CPU.
> 
> It doesn't really matter which thread is scanning, but I
> think we want some preferably simple way to prevent all
> CPUs in the system from going wild over the nonfreeable
> lists.

Let me rephrase: why does *anybody* need to scan inactive_dirty?
 
> > > > order.   But I think that end_page_writeback() should still move
> > > > cleaned pages onto the far (hot) end of inactive_clean?
> > >
> > > IMHO inactive_clean should just contain KNOWN FREEABLE pages,
> > > as an area beyond the inactive_dirty list.
> >
> > Confused.  So where do anon pages go?
> 
> All pages go onto the inactive_dirty list. When they reach
> the end of the list either we move them to the inactive_clean
> list, we submit IO or (in the case of a mapped page) we give
> them another go-around on the list in order to build up a
> cluster from the other still-mapped pages near it.

hum.  I'm trying to find a model where the VM can just ignore
dirty|writeback pagecache.  We know how many pages are out
there, sure.  But we don't scan them.  Possible?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
