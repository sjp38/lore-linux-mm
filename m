Message-Id: <200008071740.KAA25895@eng2.sequent.com>
Reply-To: Gerrit.Huizenga@us.ibm.com
From: Gerrit.Huizenga@us.ibm.com
Subject: Re: RFC: design for new VM 
In-reply-to: Your message of Wed, 02 Aug 2000 19:08:52 -0330.
             <8725692F.0079E22B.00@d53mta03h.boulder.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <25891.965670052.1@eng2.sequent.com>
Date: Mon, 07 Aug 2000 10:40:52 PDT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Rik,

I have a few comments on your RFC for VM.  Some are simply
observational, some are based on our experience locally with the
development, deployment and maintenance of a VM subsystem here at IBM
NUMA-Q (formerly Sequent Computer Systems, Inc.).  As you may remember,
our VM subsystem was initially designed in ~1982-1984 to operate on 30
processor SMP machines, and in roughly 1993-1995 it was updated to
support NUMA systems up to 64 processors.  Our machines started with ~1
GB of physical memory, and today support up to 64 GB of physical memory
on a 32-64 processor machine.  These machines run a single operating
system (DYNIX/ptx) which is derived originally from BSD 4.2, although
the VM subsystem has been completely rewritten over the years.

Along the way, we learned many things about memory latency, large
memory support, SMP & NUMA issues, some of which may be useful to
you in your current design effort.

First, and perhaps foremost, I believe your design deals almost
exclusively with page aging & page replacement algorithms, rather
than being a complete VM redesign, although feel free to correct
me if I have misconstrued that.  For instance, I don't believe you
are planning to redo the 3 or 4 tier page table layering as part
of your effort, nor are you changing memory allocation routines in
any kernel-visible way.  I also don't see any modifications to kernel
pools, general memory management of free pages (e.g. AVL trees vs. 
linked lists), any changes to the PAE mechanism currently in use,
no reference to alternate page sizes (e.g. Intel PSE), buffer/page
cache organization, etc.  I also see nothing in the design which
reduces the needs for global TLB flushes across this system, which
is one area where I believe Linux is starting to suffer as CPU counts
increase.  I believe a full VM redesign would tend to address all of
these issues, even if it did so in a completely modular fashion.

I also note that you intend to draw heavily from the FreeBSD
implementation.  Two areas in which to be very careful here have
already been mentioned, but they are worth restating:  FreeBSD
has little to no SMP experience (e.g. kernel big lock) and little
to no large memory experience.  I believe Linux is actually slighly
more advanced in both of these areas, and a good redesign should
preserve and/or improve on those capabilities.

I believe that your current proposed aging mechanism, while perhaps
a positive refinement of what currently exists, still suffers from
a fundamental problem in that you are globally managing page aging.
In both large memory systems and in SMP systems, scaleability is
greatly enhanced if major capabilities like page aging can in some
way be localized.  One mechanism might be to use something like
per-CPU zones from which private pages are typically allocated from
and freed to.  This, in conjunction with good scheduler affinity,
maximizes the benefits of any CPU L1/L2 cache.  Another mechanism,
and the one that we chose in our operating system, was to use a modified
process resident set sizes as the machanism for page management.  The
basic modifications are to make the RSS tuneable system wide as well
as per process.  The RSS size "flexes" based on available memory and
a processes page fault frequency (PFF).  Frequent page faults force the
RSS to increase, infrequent page faults cause a processes resident size
to shrink.  When memory pressure mounts, the running process manages
itself a little more agressively; processes which have "flexed"
their resident set size beyond their system or per process recommended
maxima are among the first to lose pages.  And, when pressure can not
be addressed to RSS management, swapping starts.

Another fundamental flaw I see with both the current page aging mechanism
and the proposed mechanism is that workloads which exhaust memory pay
no penalty at all until memory is full.  Then there is a sharp spike
in the amount of (slow) IO as pages are flushed, processes are swapped,
etc.  There is no apparent smoothing of spikes, such as increasing the
rate of IO as the rate of memory pressure increases.  With the exception
of laptops, most machines can sustain a small amount of background
asynchronous IO without affecting performance (laptops may want IO
batched to maximize battery life).  I would propose that as memory
pressure increases, paging/swapping IO should increase somewhat
proportionally.  This provides some smoothing for the bursty nature of
most single user or small ISP workloads.  I believe databases style
loads on larger machines would also benefit.

Your current design does not address SMP locking at all.  I would
suggest that a single VM lock would provide reasonable scaleability
up to about 16 processors, depending on page size, memory size, processor
speed, and the ratio of processor speed to memory bandwidth.  One
method for stretching that lock is to use zoned, per-processor (or
per-node) data for local page allocations whenever possible.  Then
local allocations can use minimal locking (need only to protect from
memory allocations in interrupt code).  Further, the layout of memory
in a bitmaped, power of 2 sized "buddy system" can speed allocations,
reducing the amount of time during which a critical lock needs to be
held.  AVL trees will perform similarly well, with the exception that
a resource bitmap tends to be easier on TLB entries and processor
cache.  A bitmaped allocator may also be useful in more efficiently
allocating pages of variable sizes on a CPU which supports variable
sized pages in hardware.

Also, I note that your filesys->flush() mechanism utilizes a call
per page.  This is an interesting capability, although I'd question
the processor efficiency of a page granularity here.  On large memory
systems, with large processes starting (e.g. Netscape, StarOffice, or
possible a database client), it seems like a callback to a filesystem
which said something like flush("I must have at least 10 pages from
you", "and I'd really like 100 pages") might be a better way to
use this advisory capability.  You've already pointed out that you
may request that a specific page might be requested but other pages
may be freed; this may be a more explicit way to code the policy
you really want.

It would also be interesting to review the data structure you intend
to use in terms of cache line layout, as well as look at the algorithms
which use those structures with an eye towards minimizing page & cache
hits for both SMP *and* single processor efficiency.

Hope this is of some help,

Gerrit Huizenga
IBM NUMA-Q (nee' Sequent)
Gerrit.Huizenga@us.ibm.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
