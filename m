Date: Wed, 2 Aug 2000 19:08:52 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RFC: design for new VM
Message-ID: <Pine.LNX.4.21.0008021212030.16377-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

here is a (rough) draft of the design for the new VM, as
discussed at UKUUG and OLS. The design is heavily based
on the FreeBSD VM subsystem - a proven design - with some
tweaks where we think things can be improved. Some of the
ideas in this design are not fully developed, but none of
those "new" ideas are essential to the basic design.

The design is based around the following ideas:
- center-balanced page aging, using
    - multiple lists to balance the aging
    - a dynamic inactive target to adjust
      the balance to memory pressure
- physical page based aging, to avoid the "artifacts"
  of virtual page scanning
- separated page aging and dirty page flushing
    - kupdate flushing "old" data
    - kflushd syncing out dirty inactive pages
    - as long as there are enough (dirty) inactive pages,
      never mess up aging by searching for clean active
      pages ... even if we have to wait for disk IO to
      finish
- very light background aging under all circumstances, to
  avoid half-hour old referenced bits hanging around



		Center-balanced page aging:

- goals
    - always know which pages to replace next
    - don't spend too much overhead aging pages
    - do the right thing when the working set is
      big but swapping is very very light (or none)
    - always keep the working set in memory in
      favour of use-once cache

- page aging almost like in 2.0, only on a physical page basis
    - page->age starts at PAGE_AGE_START for new pages
    - if (referenced(page)) page->age += PAGE_AGE_ADV;
    - else page->age is made smaller (linear or exponential?)
    - if page->age == 0, move the page to the inactive list
    - NEW IDEA: age pages with a lower page age

- data structures (page lists)
    - active list
        - per node/pgdat
        - contains pages with page->age > 0
        - pages may be mapped into processes
        - scanned and aged whenever we are short
          on free + inactive pages
        - maybe multiple lists for different ages,
          to be better resistant against streaming IO
          (and for lower overhead)
    - inactive_dirty list
        - per zone
        - contains dirty, old pages (page->age == 0)
        - pages are not mapped in any process
    - inactive_clean list
        - per zone
        - contains clean, old pages
        - can be reused by __alloc_pages, like free pages
        - pages are not mapped in any process
    - free list
        - per zone
        - contains pages with no useful data
        - we want to keep a few (dozen) of these around for
          recursive allocations

- other data structures
    - int memory_pressure
        - on page allocation or reclaim, memory_pressure++
        - on page freeing, memory_pressure--  (keep it >= 0, though)
        - decayed on a regular basis (eg. every second x -= x>>6)
        - used to determine inactive_target
    - inactive_target == one (two?) second(s) worth of memory_pressure,
      which is the amount of page reclaims we'll do in one second
        - free + inactive_clean >= zone->pages_high
        - free + inactive_clean + inactive_dirty >= zone->pages_high \
                + one_second_of_memory_pressure * (zone_size / memory_size)
    - inactive_target will be limited to some sane maximum
      (like, num_physpages / 4)

The idea is that when we have enough old (inactive + free)
pages, we will NEVER move pages from the active list to the
inactive lists. We do that because we'd rather wait for some
IO completion than evict the wrong page.

Kflushd / bdflush will have the honourable task of syncing
the pages in the inactive_dirty list to disk before they
become an issue. We'll run balance_dirty over the set of
free + inactive_clean + inactive_dirty AND we'll try to
keep free+inactive_clean > pages_high .. failing either of
these conditions will cause bdflush to kick into action and
sync some pages to disk.

If memory_pressure is high and we're doing a lot of dirty
disk writes, the bdflush percentage will kick in and we'll
be doing extra-agressive cleaning. In that case bdflush
will automatically become more agressive the more page
replacement is going on, which is a good thing.



		Physical page based page aging

In the new VM we'll need to do physical page based page aging
for a number of reasons. Ben LaHaise said he already has code
to do this and it's "dead easy", so I take it this part of the
code won't be much of a problem.

The reasons we need to do aging on a physical page are:
    - avoid the virtual address based aging "artifacts"
    - more efficient, since we'll only scan what we need
      to scan  (especially when we'll test the idea of
      aging pages with a low age more often than pages
      we know to be in the working set)
    - more direct feedback loop, so less chance of
      screwing up the page aging balance



		IO clustering

IO clustering is not done by the VM code, but nicely abstracted
away into a page->mapping->flush(page) callback. This means that:
- each filesystem (and swap) can implement their own, isolated
  IO clustering scheme
- (in 2.5) we'll no longer have the buffer head list, but a list
  of pages to be written back to disk, this means doing stuff like
  delayed allocation (allocate on flush) or kiobuf based extents
  is fairly trivial to do



		Misc

Page aging and flushing are completely separated in this
scheme. We'll never end up aging and freeing a "wrong" clean
page because we're waiting for IO completion of old and
to-be-freed pages.

Write throttling comes quite naturally in this scheme. If we
have too many dirty inactive pages we'll write throttle. We
don't have to take dirty active pages into account since those
are no candidate for freeing anyway. Under light write loads
we will never write throttle (good) and under heavy write
loads the inactive_target will be bigger and write throttling
is more likely to kick in.

Some background page aging will always be done by the system.
We need to do this to clear away referenced bits every once in
a while. If we don't do this we can end up in the situation where,
once memory pressure kicks in, pages which haven't been referenced
in half an hour still have their referenced bit set and we have no
way of distinguishing between newly referenced pages and ancient
pages we really want to free.   (I believe this is one of the causes
of the "freeze" we can sometimes see in current kernels)



Over the next weeks (months?) I'll be working on implementing the
new VM subsystem for Linux, together with various other people
(Andrea Arcangeli??, Ben LaHaise, Juan Quintela, Stephen Tweedie).
I hope to have it ready in time for 2.5.0, but if the code turns
out to be significantly more stable under load than the current
2.4 code I won't hesitate to submit it for 2.4.bignum...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
         -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
