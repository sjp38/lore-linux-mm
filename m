From: Mark_H_Johnson@Raytheon.com
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <OF99EF36E0.B08E89EA-ON862568E9.005C0C02@RSC.RAY.COM>
Date: Wed, 24 May 2000 14:37:44 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: acme@conectiva.com.br, dillon@apollo.backplane.com, linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

I'll try to combine comments on the VM queues & Matt Dillon's material in
one response. I've added some analysis at the end - yes the reference is
OLD, but the math is still valid. The bottom line of my comments - make
sure the goals are right, put some measures into place so we can determine
"success", & build the solution based on sound principles. Also, thanks to
all who are working to make the VM system in Linux better.

Re: Goals
 - Robust design - absolutely essential. VM is one of those key
capabilities that must be done right or not at all.
 - page aging and "buffer for allocations" - not sure if I care which
methods we use as long as they work well. To me, the goal of VM is to have
the "right" pages in memory when the CPU executes an instruction. Page
aging and free lists are two methods, lookahead and clustered reads &
writes are others.
 - treat pages equally - I think I disagree with both you and Matt on this
one. We have different usage patterns for different kinds of data (e.g.
execution of code tends to be localized but not sequential vs. sequential
read of data in a file) & should have a means of distinguishing between
them. This does not mean that one algorithm won't do a good job for both
the VM & buffer cache, just recognize that we should have ways to treat
them differently. See my comments on "stress cases" below for my rationale.
 - simple changes - I agree, get this issue settled & move on.
To these goals I might add
 - predictable performance [essential if I deploy any large (or real time)
system on Linux]
 - no more automatic process kills - give the system [and/or operator] the
ability to recover without terminating jobs
 - make it adjustable by the user or system administrator for different
workloads
 - durable - works well with varied CPU, memory, and disk performance
A related item - measure that the "goals have been met". How do we know
that method A works better than method B without some hooks to measure the
performance?

A final comment on goals - I honestly don't mind systems that swap - IF
they do a better job of running the active jobs as a result. The FUD that
Matt refers to on FreeBSD swapping may actually mean that FreeBSD runs
better than Linux. I can't tell, and it probably varies by application area
anyway.

Re: Design ideas [with ties into Matt's material]
 - not sure what the 3 [4?] queues are doing for us; I can't tie the queue
concept to how we are meeting one of the goals above.
 - allocations / second as a parameter to adjust free pages. Sounds OK, may
want a scalable factor here with min & max limits to free pages. For
example, in a real time system I want no paging - that doesn't mean that I
want no free pages. A burst of activity could occur where I need to do an
allocation & don't want to wait for a disk write before taking action
[though that usually means MY system design is broke...].
 - not sure the distinction between "atomic" and "non atomic" allocations.
Please relate this to meeting the goals above, or add a goal.
 - not clear how the inactive queue scan & page cleaner methods meet the
goals either.
 - [Matt] real statistics - I think is a part of the data needed to
determine if A is better than B.
 - [Matt] several places talks about LRU or not strict LRU - LRU is a good
algorithm but has overhead involved. You may find that a simple FIFO or
clock algorithm gets >90% of the benefit of LRU without the overhead [can
be a net gain, something to consider].
 - [Matt] relate scan rate to perceived memory load. Looks OK if the
overhead makes it worth the investment.
 - [Matt] moving balance points & changing algorithms [swap, not page].
Ditto.
 - [Matt] adjustments to initial weight. Ditto - relates directly to the
"right page" goal.
See the analysis below to get an idea of what I mean by "overhead is worth
the investment". It looks like we can spend a lot of CPU cycles to save one
disk read or write and still run the system efficiently.

The remainder of Matt's message was somewhat harder to read - some mixture
of stress cases & methods used to implement VM. I've reorganized what he
said to characterize this somewhat more clearly [at least in my mind]...

  Stress cases [characterized as sequential/not, read only or read/write,
shared or not, locked or not] I tried to note the application for each case
as well as the general technique that could be applied to memory
management.
  - sequential read only access [file I/O or mmap'd file, use once &
discard]
  - sequential read/write access [file updates or mmap'd file, use once &
push to file on disk]
  - non-sequential read or execute access, not shared [typical executable,
locality of reference; when memory is tight, can discard & refresh from
disk]
  - non-sequential read/write access, not shared [stack or heap; locality
of reference, must push to file or swap when memory is tight]
  - read only shared access [typical shared library, higher "apparent cost"
if not in memory, can discard & refresh from disk]
  - read/write shared access [typical memory mapped file or shared memory
region, higher apparent cost if not in memory, has cache impact on multi
processors, must push to file or swap when memory is tight]
  - locked pages for I/O or real time applications [fixed in memory due to
system constraints, VM system must (?) leave alone, cannot (?) move in
memory, not "likely" needed on disk (?)]. I had a crazy idea as I was
writing this one - application is to capture a stream of data from the
network onto disk. The user mmap's a file & locks into memory to ensure
bandwidth can be met, fills region with data from network, unlocks & sync's
the file when transfer is done. How would FreeBSD/Linux handle that case?

I expect there are other combinations possible - I just tried to
characterize the kind of memory usage patterns that are typical. It may
also be good to look at some real application areas - interactive X
applications, application compile/link, database updates, web server, real
time, streaming data, and so on; measure how they stress the system & build
the VM system to handle the varied loads - automatically if you can but
with help from the user/system administrator if you need it.

  Methods [recap of Matt's list]
  - write clustering - a good technique used on many systems
  - read clustering - ditto, especially note about priority reduction on
pages already read
  - sequential access detection - ditto
  - sequential write detection - ditto, would be especially helpful with
some of our shared memory test programs that currently stress Linux to
process kills; think of sequential access to memory mapped files in the
same way as sequential file I/O. They should have similar performance
characteristics if we do this right [relatively small resident set sizes,
high throughput].

Some analysis of the situation

I took a few minutes to go through some of my old reference books. Here are
some concepts that might help from "Operating System Principles" by Per
Brinch Hansen (1973), pp 182-191.

Your disk can supply at most one page every T seconds, memory access every
t seconds, and your program demands at a rate of p(s) - s relates to the
percent of resident to total size of the process. The processor tends to
demands one page every t/p(s) memory accesses. There are three situations:
 - disk is idle, p(s) < t/T. Generally OK, desired if you need to keep
latency down.
 - CPU is idle, p(s) > t/T. Generally bad, leads to thrashing. May indicate
you need more memory or faster disks for your application.
 - balanced system, p(s) = t/T. Full utilization, may lead to latency
increases.
Let's feed some current performance numbers & see where it leads.

A disk access (T) is still a few milliseconds and a memory access (t) is
well under a microsecond (lets use T=5E-3 and t=5E-8 to keep the math
simple). The ratio of t/T is thus 1/100000 - that means one disk page
access per 100000 memory accesses. Check the math, on 20mhz memory
accesses, your balanced demand is 200 disk pages per second (perhaps
high?). Note that many of our stress tests have much higher ratios than
this. I suggest a few real measurements to get ratios for real systems
rather than my made up answers.

Even if I'm off by 10x or 100x, this kind of ratio means that many of the
methods Matt describes makes sense. It helps justify why spending time to
do read/write clusters pays off - it gets you more work done for the cost
of each disk access (T). It helps justify why detecting sequential access &
limiting resident set sizes in those cases is OK [discard pages that will
never be used again]. It shows how some of the measures Matt has described
(e.g., page weights & perceived memory load) help determine how we should
proceed.

The book goes on to talk about replacement algorithms. FIFO or
approximations to LRU can cause up to 2-3x more pages to be transferred
than the "ideal algorithm" (one that knows in advance the best choice).
This results in a 12-24 % reduction of working set size but improves
utilization only a few percent. There is also a discussion of transfer
algorithms, basically a combination of elevator and/or clustering to reduce
latency & related overhead. I think Matt has covered better techniques than
was in this old book. I did have to chuckle with the biggest gain -  fix
the application to improve locality - a problem then & still one today.
Small tools work better than big ones. Perhaps a reason to combat code
bloat in the tools we use.

Closing
First, let's make sure we agree what we really need from the VM system
(goals).
Second, define a few measurements in place so we can determine we've
succeeded.
Third, implement solutions that will get us there.

Don't forget to give thanks for all the hard work that has gone into what
we have today & will have tomorrow.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
