Message-ID: <3989C752.DFA26462@norran.net>
Date: Thu, 03 Aug 2000 21:26:10 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: RFC: design for new VM
References: <Pine.LNX.4.21.0008021212030.16377-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
List-ID: <linux-mm.kvack.org>

Hi,

My comments (IMHO).

Rik van Riel wrote:
> 
> Hi,
> 
> here is a (rough) draft of the design for the new VM, as
> discussed at UKUUG and OLS. The design is heavily based
> on the FreeBSD VM subsystem - a proven design - with some
> tweaks where we think things can be improved. Some of the
> ideas in this design are not fully developed, but none of
> those "new" ideas are essential to the basic design.
> 
> The design is based around the following ideas:
> - center-balanced page aging, using
>     - multiple lists to balance the aging
>     - a dynamic inactive target to adjust
>       the balance to memory pressure
> - physical page based aging, to avoid the "artifacts"
>   of virtual page scanning
> - separated page aging and dirty page flushing
>     - kupdate flushing "old" data
>     - kflushd syncing out dirty inactive pages
>     - as long as there are enough (dirty) inactive pages,
>       never mess up aging by searching for clean active
>       pages ... even if we have to wait for disk IO to
>       finish
> - very light background aging under all circumstances, to
>   avoid half-hour old referenced bits hanging around
> 
>                 Center-balanced page aging:
> 
> - goals
>     - always know which pages to replace next
>     - don't spend too much overhead aging pages
>     - do the right thing when the working set is
>       big but swapping is very very light (or none)
>     - always keep the working set in memory in
>       favour of use-once cache
> 
> - page aging almost like in 2.0, only on a physical page basis
>     - page->age starts at PAGE_AGE_START for new pages
>     - if (referenced(page)) page->age += PAGE_AGE_ADV;
>     - else page->age is made smaller (linear or exponential?)
>     - if page->age == 0, move the page to the inactive list
>     - NEW IDEA: age pages with a lower page age
> 
> - data structures (page lists)
>     - active list
>         - per node/pgdat
>         - contains pages with page->age > 0
>         - pages may be mapped into processes
>         - scanned and aged whenever we are short
>           on free + inactive pages
>         - maybe multiple lists for different ages,
>           to be better resistant against streaming IO
>           (and for lower overhead)

Does this really need to be a list? Since most pages should
be on this list can't it be virtual - pages on no other list
are on active list. All pages are scanned all the time...


>     - inactive_dirty list
>         - per zone
>         - contains dirty, old pages (page->age == 0)
>         - pages are not mapped in any process
>     - inactive_clean list
>         - per zone
>         - contains clean, old pages
>         - can be reused by __alloc_pages, like free pages
>         - pages are not mapped in any process

What will happen to pages on these lists if pages gets referenced?
* Move them back to the active list? Then it is hard to know how
  many free able pages there really are...

>     - free list
>         - per zone
>         - contains pages with no useful data
>         - we want to keep a few (dozen) of these around for
>           recursive allocations
> 
> - other data structures
>     - int memory_pressure
>         - on page allocation or reclaim, memory_pressure++
>         - on page freeing, memory_pressure--  (keep it >= 0, though)
>         - decayed on a regular basis (eg. every second x -= x>>6)
>         - used to determine inactive_target
>     - inactive_target == one (two?) second(s) worth of memory_pressure,
>       which is the amount of page reclaims we'll do in one second
>         - free + inactive_clean >= zone->pages_high
>         - free + inactive_clean + inactive_dirty >= zone->pages_high \
>                 + one_second_of_memory_pressure * (zone_size / memory_size)

One of the most interesting aspects (IMHO) of Scott F. Kaplands
"Compressed Cache
and Virtual Memory Simulation" was the use of VM time instead of wall
time.
One second could be too long of a reaction time - relative to X
allocations/sec etc.

>     - inactive_target will be limited to some sane maximum
>       (like, num_physpages / 4)

Question: Why is this needed?
Answer: Due to high memory_pressure can only exist momentarily. And can
pollute our
statistics.


> The idea is that when we have enough old (inactive + free)
> pages, we will NEVER move pages from the active list to the
> inactive lists. We do that because we'd rather wait for some
> IO completion than evict the wrong page.
> 

So, will the scanning stop then??? And referenced builds up.
Or will there be pages with age == 0 on the active list?
(This is one of the reasons VM time is nice as time base for ageing -
 little happens time goes slower)
This contradicts "very light background ageing" earlier.

> Kflushd / bdflush will have the honourable task of syncing
> the pages in the inactive_dirty list to disk before they
> become an issue. We'll run balance_dirty over the set of
> free + inactive_clean + inactive_dirty AND we'll try to
> keep free+inactive_clean > pages_high .. failing either of
> these conditions will cause bdflush to kick into action and
> sync some pages to disk.
> 
> If memory_pressure is high and we're doing a lot of dirty
> disk writes, the bdflush percentage will kick in and we'll
> be doing extra-agressive cleaning. In that case bdflush
> will automatically become more agressive the more page
> replacement is going on, which is a good thing.

I think that one of the omissions in Kaplands report is the
time it takes to clean dirty pages. (Or have I missed
something... Need to select the pages earlier)

> 
>                 Physical page based page aging
> 
> In the new VM we'll need to do physical page based page aging
> for a number of reasons. Ben LaHaise said he already has code
> to do this and it's "dead easy", so I take it this part of the
> code won't be much of a problem.
> 
> The reasons we need to do aging on a physical page are:
>     - avoid the virtual address based aging "artifacts"
>     - more efficient, since we'll only scan what we need
>       to scan  (especially when we'll test the idea of
>       aging pages with a low age more often than pages
>       we know to be in the working set)
>     - more direct feedback loop, so less chance of
>       screwing up the page aging balance

Nod.

> 
>                 IO clustering
> 
> IO clustering is not done by the VM code, but nicely abstracted
> away into a page->mapping->flush(page) callback. This means that:
> - each filesystem (and swap) can implement their own, isolated
>   IO clustering scheme
> - (in 2.5) we'll no longer have the buffer head list, but a list
>   of pages to be written back to disk, this means doing stuff like
>   delayed allocation (allocate on flush) or kiobuf based extents
>   is fairly trivial to do
>

Nod.
 
>                 Misc
> 
> Page aging and flushing are completely separated in this
> scheme. We'll never end up aging and freeing a "wrong" clean
> page because we're waiting for IO completion of old and
> to-be-freed pages.
>

Is page ageing modification of LRU enough?
In many cases it will probably behave worse than plain LRU
(slower phase adaptions).
The access pattern diagrams in Kaplans report are very
enlightening...


/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
