Message-ID: <3989F22B.F466FA58@norran.net>
Date: Fri, 04 Aug 2000 00:28:59 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: RFC: design for new VM
References: <Pine.LNX.4.21.0008031703250.24022-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 3 Aug 2000, Roger Larsson wrote:
> 
> > > - data structures (page lists)
> > >     - active list
> > >         - per node/pgdat
> > >         - contains pages with page->age > 0
> > >         - pages may be mapped into processes
> > >         - scanned and aged whenever we are short
> > >           on free + inactive pages
> > >         - maybe multiple lists for different ages,
> > >           to be better resistant against streaming IO
> > >           (and for lower overhead)
> >
> > Does this really need to be a list? Since most pages should
> > be on this list can't it be virtual - pages on no other list
> > are on active list. All pages are scanned all the time...
> 
> It doesn't have to be a list per se, but since we have the
> list head in the page struct anyway we might as well make
> it one.
> 

If we do not want to increase the size of the page struct.
A union could be added instead - age info _or_ actual list.
(not on any list unless age is zero)

> > >     - inactive_dirty list
> > >         - per zone
> > >         - contains dirty, old pages (page->age == 0)
> > >         - pages are not mapped in any process
> > >     - inactive_clean list
> > >         - per zone
> > >         - contains clean, old pages
> > >         - can be reused by __alloc_pages, like free pages
> > >         - pages are not mapped in any process
> >
> > What will happen to pages on these lists if pages gets referenced?
> > * Move them back to the active list? Then it is hard to know how
> >   many free able pages there really are...
> 
> Indeed, we will move such a page back to the active list.
> "Luckily" the inactive pages are not mapped, so we have to
> locate them through find_page_nolock() and friends, which
> allows us to move the page back to the active list, adjust
> statistics and maybe even wake up kswapd as needed.
> 
> > > - other data structures
> > >     - int memory_pressure
> > >         - on page allocation or reclaim, memory_pressure++
> > >         - on page freeing, memory_pressure--  (keep it >= 0, though)
> > >         - decayed on a regular basis (eg. every second x -= x>>6)
> > >         - used to determine inactive_target
> > >     - inactive_target == one (two?) second(s) worth of memory_pressure,
> > >       which is the amount of page reclaims we'll do in one second
> > >         - free + inactive_clean >= zone->pages_high
> > >         - free + inactive_clean + inactive_dirty >= zone->pages_high \
> > >                 + one_second_of_memory_pressure * (zone_size / memory_size)
> >
> > One of the most interesting aspects (IMHO) of Scott F. Kaplands
> > "Compressed Cache and Virtual Memory Simulation" was the use of
> > VM time instead of wall time. One second could be too long of a
> > reaction time - relative to X allocations/sec etc.
> 
> It's just the inactive target. Trying to keep one second of
> unmapped pages with page->age==0 around is mainly done to:
> - make sure we can flush all of them on time
> - put an "appropriate" amount of pressure on the
>   pages in the active list, so page aging is smoothed
>   out a little bit
> 

Yes, but why one second? Why not 1/10 second, one jiffie, ...


> > > If memory_pressure is high and we're doing a lot of dirty
> > > disk writes, the bdflush percentage will kick in and we'll
> > > be doing extra-agressive cleaning. In that case bdflush
> > > will automatically become more agressive the more page
> > > replacement is going on, which is a good thing.
> >
> > I think that one of the omissions in Kaplands report is the
> > time it takes to clean dirty pages. (Or have I missed
> > something... Need to select the pages earlier)
> 
> Page replacement (select which page to replace) should always
> be independant from page flushing. You can make pretty decent
> decisions on which page(s) to free and the last thing you want
> is having them messed up by page flushing.
> 
> > >                 Misc
> > >
> > > Page aging and flushing are completely separated in this
> > > scheme. We'll never end up aging and freeing a "wrong" clean
> > > page because we're waiting for IO completion of old and
> > > to-be-freed pages.
> >
> > Is page ageing modification of LRU enough?
> 
> It seems to work fine for FreeBSD. Also, we can always change
> the "aging" of the active pages with something else. The
> system is modular enough that we can do that.
> 
> > In many cases it will probably behave worse than plain LRU
> > (slower phase adaptions).
> 
> We can change that by using exponential decay for the page
> age, or by using some different aging technique...
>

Another research subject...
 
> > The access pattern diagrams in Kaplans report are very
> > enlightening...
> 
> They are very interesting indeed, but I miss one very
> common workload in their report. A lot of systems do
> (multimedia) streaming IO these days, where a lot of
> data passes through the cache quickly, but all of the
> data is only touched once (or maybe twice).

And at the same time browsing www with netscape...
 
/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
