Date: Tue, 21 Mar 2000 16:15:07 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: Extensions to mincore
Message-ID: <20000321161507.D5291@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321024731.C4271@pcep-jamie.cern.ch> <m1puso1ydn.fsf@flinx.hidden> <20000321113448.A6991@dukat.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000321113448.A6991@dukat.scot.redhat.com>; from Stephen C. Tweedie on Tue, Mar 21, 2000 at 11:34:48AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@scot.redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:
> > > > [Aside: is there the possibility to have mincore return the
> > > > "!accessed" and "!dirty" bits of each page, perhaps as bits 1
> > > > and 2 of the returned bytes?  I can imagine a bunch of garbage
> > > > collection algorithms that could make good use of those bits.
> > > > Currently some GC systems mprotect() regions and unprotect them
> > > > on SEGV -- simply reading the !dirty status would obviously be
> > > > much simpler and faster.]
> 
> No it wouldn't.  

Yes it would.

> Dirty kernel wise means the page needs to be swapped out. Clean kernel
> wise mean the page is in the swap cache, and hasn't been written
> since it was swapped in.
> 
> Dirty GC wise the page has changes since the last GC pass over it.

Of course, I thought that was obvious :-)

You're right, that for GC the "!dirty" bit has to mean "since the last
time we called mincore".

To get the correct behaviour without maintaining extra state in the
kernel (apart from a bit or two per struct page), you'd say that mincore
returns "!dirty since the last time _anyone_ called mincore on this
page", and you'd disallow it for shared mappings.

It works for threads too.

All threads sharing a page have to synchronise their mincore calls for
that page, but that situation is no different to the SEGV method: all
threads have to synchronise with the information collected from that,
too.

Stephen C. Tweedie wrote:
> Worse than that, returning dirty status bits in mincore() just wouldn't 
> work for threads.  mincore() is a valid optimisation when you just treat
> it as a hint: if a page gets swapped out between calling mincore() and 
> using the page, nothing breaks, you just get an extra page fault.  

[Aside: I regard this as a bug.  mincore() should have an option to set
the accessed bit on each page that is in core, to avoid the "just
missed" condition.  If it sets the accessed bit, then under most
circumstances the just missed condition will never happen.  If it does
not (it doesn't now), the just missed condition will always happen
sometimes under the slightest non-zero paging load.  The difference for
an application that does "call mincore; if not in core, spawn thread to
pull in page" under low system load will be between no stalls and
occasional stalls.  Thus mincore() is missing a flag parameter IMO]

> The same is not true for the sort of garbage collection or distributed
> memory mechanisms which use mprotect().  If you find that a page is clean
> via mincore() and discard the data based on that, there is nothing to 
> stop another thread from dirtying the data after the mincore() and losing
> its modification.

In general, you have to be very careful about what you allow other
threads to modify during GC.  For a full collection, some kind of
synchronisation point with everyone is usually required.

(Disclaimer: I am not a GC expert so if you know of GC mechanisms that
use mprotect and don't require threads to be synchronised, please speak up!)

1. Stop all the other threads, copy the state of their roots
   (i.e. processor registers, individual stack roots), call mprotect(),
   restart the threads, and let SEGVs mprotect() pages back to writable
   status while putting them on a list.  Watch out for concurrent SEGVs
   on the same page!

   Disadvantage: lots of SEGV handling, SEGV code is processor specific
   (until siginfo is reliable), lots of individual page mprotect calls,
   lots of vmas, page fault slowdown even for non-GC-using threads due
   to all the tiny vmas.

1a. Using mincore(): call mincore() instead of mprotect() in method 1.
    Threads are stopped so it just works :-)

    Advantage: everything runs faster and the code is more portable
    (among Linux systems).

2. Method 1 has a large mprotect() call.  Quite apart from the slowness
   of all that mprotect/SEGV processing, the single large mprotect may
   take a while during which all threads are blocked, and it also
   prevents any threads not involved in GC from faulting.  (As you say,
   it grabs the page table lock).

   You can call mprotect() first to protect the GC arena, with threads
   still running.  At this point, you're _not_ using it to collect dirty
   page information.  When mprotect() returns, you synchronise all
   threads to gather local GC roots, and then start collecting dirty
   page info via SEGVs.  If a thread gets a SEGV before the
   synchronisation point, it is blocked until the synchronisation
   point.  In this way, threads not writing to the arena don't get
   stopped for long even if mprotect() itself takes a long time.

2a. Method 2 using mincore().  Now you do do mprotect() at the beginning
    -- remember it is not for collecting dirty page info here, but for
    blocking threads writing to the arena while permitting others to
    continue.

    After synchronisation, call mincore() and then mprotect() to make
    the entire arena writable.  Then restart all blocked threads.  Any
    SEGVs from the start of the first mprotect() to the end of the
    second one block the faulting thread prior to synchronisation; any
    that block are restarted afterwards.

Obviously there are plenty of other ways to arrange this, with multiple
arenas etc.  But I hope you can see that mincore() can be used reliably
without requiring the overhead of individual-page mprotect and SEGVs.

> mprotect() has the advantage of holding page table locks so it can do
> an atomic read-modify-write on the page table entries.  Without that
> locking, you just can't reliably use dirty/accessed information.

mprotect() has the major disadvantage of creating a million tiny vmas
when you are using it to track dirty pages.  And as far as I can see,
mprotect/SEGV gives no advantage over the dirty bit method: in both
cases, you always need synchronisations points between threads to share the
dirty page information.

mprotect has another disadvantage: it holds the page table lock.  Great
for atomic operations; terrible when you do a large mprotect and you
_don't_ want to stop concurrent threads (that are not using the GC
arena) from page faulting their stuff.

Interestingly, neither GC synchronisation method I described depends on
mprotect() being atomic w.r.t. the whole protection change, and method 2
would actually benefit from concurrent page faults being allowed during
the mprotect().

The atomicity you mention is important.  Consider this implementation:

  1. Only private mappings allowed.
  2. A page is considered dirty "since the last mincore call" if the pte
     dirty bit is set, or if a struct page flag PageMincoreDirty is set.

To read this, you must atomically read and clear the pte's dirty bit.
(Not difficult on x86 or any UP system; I'm not sure about other SMP systems).

mincore() calls are assumed to be protected w.r.t. each other.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
