Date: Fri, 24 Mar 2000 01:21:49 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000324012149.C20140@pcep-jamie.cern.ch>
References: <20000322233147.A31795@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003231332080.20600-100000@funky.monkey.org>; from Chuck Lever on Thu, Mar 23, 2000 at 01:53:22PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On the dirty bit
................

And then Chuck moved onto a different topic, mincore...
> can this be any worse than mprotect?

Do you really imagine an application having to handle 1000 SEGV signals,
and call mprotect() for one page per SEGV, and the kernel locking the mm
thereby causing soft fault contention for other threads, is fast? :-)

<ahem>, but enough sensationalism from me.  I went and looked at some
papers -- and found a rather annoying problem with mprotect, for general
purpose GCs[1]:

	"The resulting write faults were caught as UNIX signals and
	recorded.  Various Portable Common Runtime interfaces to SunOS
	system calls were modified so as to preclude unrecoverable
	faults in system calls."

Ouch!  You can't use the mprotect() method with read().  mincore would
be just fine.  So you can't make a conservative collector that works
with a third-party library unless you're willing to write wrappers for
all the system calls that touch user memory.  ioctl() for a hairy
example.

On the matter of timing, when that paper was written (1991), continued
from above:

	"The primary cost of this is that the first time a page in the
	heap is written after a garbage collection, a signal must be
	caught and a system call must be executed to unprotect the
	page.  The cost of this is variable, but in our environment
	appears to be somewhat less then half a millisecond per page
	written."

As a counterpoint, Boehm has this to say on the subject of getting dirty
bits from the OS[2].  See 3:

	"We keep track of modified pages using one of three distinct
	mechanisms:

	1. Through explicit mutator cooperation. Currently this requires the
	   use of GC_malloc_stubborn. 
	2. By write-protecting physical pages and catching write faults. This
           is implemented for many Unix-like systems and for win32. It is not
           possible in a few environments. 
	3. By retrieving dirty bit information from /proc. (Currently only
           Sun's Solaris supports this. Though this is considerably cleaner,
           performance may actually be better with mprotect and signals.) 

Well, I guess we will never know until it has been tried, but it looks
like it should be experimented with by someone writing a garbage
collector before it becomes a standard kernel feature.  I really don't
like the way mprotect breaks syscalls though, even if it performs well.


On the accessed bit
...................

In [3], Boehm says:

	"Paging locality 

	A common concern about garbage collection, or any form of
	dynamic memory allocation, is its interaction with a virtual
	memory system.  Accesses to virtual memory should be such that
	the traffic between disk and memory is small, i.e. most access
	should be to pages that were already recently accessed.  On
	modern computers, where disks are so much slower than CPUs, many
	programs page very little, and most of their heaps reside in the
	working set. But even for those programs in which significant
	parts of the heap do not reside in the working set, there are a
	number of techniques which dramatically increase the locality of
	reference of a mark-and-sweep collector.  The fundamental
	problem is that all memory that may possibly contain pointers
	has to be examined during every full collection."

Boehm then goes on to summarise methods used to avoid this problem.  In
particular, generational collection.

This is something that mincore could perhaps help with.  Pages that
haven't been accessed since certain GC checkpoints can gather in a set
of pages that don't need to be scanned, or at least not scanned
particularly often.

Again, somebody working on a real GC implementation would be the right
person to experiment with extensions to mincore.

My summary from this is: no point adding mincore extensions until we
know what would be useful.  But do reserve the space in those bits 1-7.

enjoy,
-- Jamie

[1] http://reality.sgi.com/boehm/papers/pldi91.ps.Z
[2] http://reality.sgi.com/boehm/gcdescr.html
[3] http://reality.sgi.com/boehm/issues.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
