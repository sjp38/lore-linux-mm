From: Mark_H_Johnson@Raytheon.com
Subject: Re: RFC: design for new VM
Message-ID: <OF387389F1.0A607EDA-ON86256931.00466996@hou.us.ray.com>
Date: Fri, 4 Aug 2000 08:52:54 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

I've read through this [and about 25 follow up messages] and have the
following [LONG] set of questions, comments, and concerns:

1. Can someone clearly express what we are trying to fix?
  Is it the "process killing" behavior, the "kswapd runs at 100%" behavior,
or what. The two that I mentioned have been side effects of not having free
pages available [though in some cases, there IS plenty of backing store in
memory mapped files or in the swap partitions]. I cannot map what I read
from Rik's message [nor the follow up] to fixing any specific problems. The
statements made under "goals" fits the closest to what I am asking for, but
something similar to that should be the goal of the existing VM system, not
just the new one.

2. How do we know we have succeeded in fixing these problems?
  Will we "declare success" if and only if 95% of all memory accesses refer
to pages that are in the resident set of the active process is AND if
system overhead is <5% for a set of test cases? Can you characterize the
current performance of 2.2.16, 2.4-testX, and FreeBSD in those terms?

3. By setting a clear goal such as identified the hit rate & overhead
listed above, you can clearly tie the design to making those goals. I've
read the previous messages on physical page scanning vs. per process scans
- it is asserted that physical scans are faster. Good. But if a per process
scan improves the hit rate more than the overhead penalty, it can be better
to do this on a per process basis. Please show us how this new design will
work to meet such a goal.

4. As a system administrator, I know the kind of applications we will be
running. Other SA's know their load too. Give us a FEW adjustments to the
new VM system to tune it. As a developer of large real time applications,
we have two basic loads that are quite different:
  a. Software developers doing coding, unit test, and some system testing
on workstations - X server and display, non real time, may be running heavy
swapping loads to run a load far bigger than the machine has memory for.
  b. Delivered loads that have most of the physical memory locked, want -
no demand low latency (<1msec) since my fastest task runs at 80hz
(12.5msec), with high CPU loading (50-80% for hours), high network traffic,
and little or no I/O to the disk while real time is active.
I seriously doubt you can satisfy varied loads without providing some means
to adjust (i) resident set sizes, (ii) size of free & dirty lists, (iii)
limits on CPU time spent in VM reclamation, (iv) aging parameters, (v)
scanning rates, and so on. Yes - I can rebuild the kernel to do this, but
an interface through /proc or other configuration mechanism would be
better.

5. I have a few "smart applications" that know what their future memory
references will be. To use an example, the "out the window" visual display
for a flight simulator is based on the current terrain around the airplane.
You can predict the next regions needed based on the current air speed,
orientation, and current terrain profile. Can we allow for per process
paging algorithms in the new VM design [to identify pages to take into or
out of the current resident set]? This has been implemented in operating
systems before - I first saw this in the late 70's. For OS's that do not
provide such a mechanism, we end up doing complicated non-blocking I/O to
disk files. This could be implemented as:
 a. address in the per process structure to indicate a paging handler is
available
 b. system call to query & set that address, as well as a system call to
preload pages [essential for real time performance]
 c. handler is called when its time to trim or adjust the resident set
 d. handler is called with a map of current memory & request to replace "X"
pages.
 e. result from handler is list of pages to remove and list of pages to add
to resident set [with net "X" pages removed or replaced.
 f. kernel routines make the adjustments, schedule preload, etc.
I do not expect such a capability in 2.4 [even if a new VM is rolled out in
2.4]

6. I do not see any mention of how we handle "read once" data [example is
grep -ir xxx /], "SMP safety", or "locked memory". Perhaps a few "use
cases" to define the situations that the VM system is expected to handle
are needed. Then the design can relate to those & explain how it will work.
Here are a few examples:
 a. heavy paging to a memory mapped file [mmap02?]
 b. web serving of static [or dynamic] content [1000's of hits per second]
 c. running Netscape on a small (32M) system
 d. large system w/ or w/o NUMA
 e. static load with large regions of locked memory [my real time example
above]
 f. kernel build
 g. same operations in UP, and SMP
 h. deleting a large memory mapped file while it is being flushed to disk
[can you abort the flush operation & delete the file immediately?]
 i. forcing synchronization of in memory data to disk
 j. the floppy disk example [do I/O while drive is running to save energy
or overall time]
>From this list, we should be able to specify what "good enough" is (paging
rates, overhead) for each situation.

7. Take into consideration relative performance of CPU cache, CPU speed,
memory access times, disk transfer times, in the algorithms. This relates
directly to a performance goal such as the one I suggested in #2. I can see
conditions where I have a relatively fast CPU, fast memory, but a NFS
mounted disk . The floppy case mentioned is similar. In that case - it
should be better to keep a steady flow of dirty pages going to that disk.
Other systems will have different situations. Determining this in run time
would be great. User settable parameters through /proc would be OK.

Please take these kind of issues into consideration in the new design.
Thanks.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


                                                                                                                    
                    Rik van Riel                                                                                    
                    <riel@conecti        To:     linux-mm@kvack.org                                                 
                    va.com.br>           cc:     linux-kernel@vger.rutgers.edu, Linus Torvalds                      
                                         <torvalds@transmeta.com>, (bcc: Mark H Johnson/RTS/Raytheon/US)            
                    08/02/00             Subject:     RFC: design for new VM                                        
                    05:08 PM                                                                                        
                                                                                                                    
                                                                                                                    



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

http://www.conectiva.com/                      http://www.surriel.com/





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
