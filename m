Date: Wed, 10 Jul 2002 18:51:02 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Optimize out pte_chain take three
Message-ID: <20020711015102.GV25360@holomorphy.com>
References: <20810000.1026311617@baldur.austin.ibm.com> <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com> <20020710173254.GS25360@holomorphy.com> <3D2C9288.51BBE4EB@zip.com.au> <20020710222210.GU25360@holomorphy.com> <3D2CD3D3.B43E0E1F@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D2CD3D3.B43E0E1F@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Phenomenally harsh.

On Wed, Jul 10, 2002 at 05:39:47PM -0700, Andrew Morton wrote:
> No offence I hope.  Just venting three year's VM frustration.

None taken. I believe it's a strong advisory to change direction,
so I have.


William Lee Irwin III wrote:
>> Your criteria are quantitative. I can't immediately measure all
>> of them but can go about collecting missing data immediately and post
>> as I go, then. Perhaps I'll even have helpers. =)

On Wed, Jul 10, 2002 at 05:39:47PM -0700, Andrew Morton wrote:
> A lot of it should be fairly simple.  We have tons of pagecache-intensive
> workloads.  But we have gaps when it comes to the VM.  In the area of
> page replacement.
> Can we fill those gaps with a reasonable amount of effort?


I'm not entirely sure, but I do have ideas of what I think would
exercise specific (sub)functions of the VM.


On Wed, Jul 10, 2002 at 05:39:47PM -0700, Andrew Morton wrote:
> example 1:  "run thirty processes which mmap a common 50000 page file and
> touch its pages in a random-but-always-the-same pattern at fifty pages
> per second.  Then run (dbench|tiobench|kernel build|slocate|foo).  Then
> see how many pages the three processes actually managed to touch."

Are we looking for "doesn't evict long-lived stuff" or "figures out
when the long-lived stuff finally died?" Maybe both would be good.


On Wed, Jul 10, 2002 at 05:39:47PM -0700, Andrew Morton wrote:
> example 2: "run a process which mallocs 60% of physical memory and
> touches it randomly at 1000 pages/sec.  run a second process
> which mallocs 60% of physical memory and touches it randomly at
> 500 pages/sec.   Measure aggregate throughput for both processes".
> example 3: "example 2, but do some pagecache stuff as well".

I think 2 and 3 should be merged, this should basically see how the
parallel pagecache stuff disturbs the prior results.


On Wed, Jul 10, 2002 at 05:39:47PM -0700, Andrew Morton wrote:
> example 4: "run a process which mmaps 60%-worth of memory readonly,
> another which mmaps 60%-worth of memory MAP_SHARED.  First process
> touches 1000 pages/sec.  Second process modifies 1000 pages/sec.
> Optimise for throughput"
> Scriptable things.  Things which we can optimise for with a
> reasonable expectation that this will improve real workloads.

Sequential/random access is another useful variable here.


William Lee Irwin III wrote:
>> I've already gone about asking for help benchmarking dmc's pte_chain
>> space optimization, and I envision the following list of TODO items
>> being things you're more interested in:
>> What other missing data are you after and which of these should
>> be chucked?

On Wed, Jul 10, 2002 at 05:39:47PM -0700, Andrew Morton wrote:
> Well there are two phases to this.  One is to run workloads,
> and the other is to analyse them.  I think workloads such as my
> lame ones above are worth thinking about and setting up first,
> don't you?    (And a lot of this will come from me picking your
> brains ;).  I can do the coding, although by /bin/sh skills
> are woeful.)
> After that comes the analysis.  Looks like rmap will be merged in
> the next few days for test-and-eval, so we don't need to go through
> some great beforehand-justification exercise.  But we do need
> a permanent toolkit and we do need a way of optimising the VM.

Okay, this is relatively high priority then.


On Wed, Jul 10, 2002 at 05:39:47PM -0700, Andrew Morton wrote:
> I would suggest that the toolkit consist of two things:
> 1: A set of scenarios and associated scripts/tools such as my
>    examples above (except more real-worldy) and
> 2: Permanent in-kernel instrumentation which allows us (and
>    remote testers) to understand what is happening in there.

At long last!


William Lee Irwin III wrote:
>> As far as operating regions for page replacement go I see 3 obvious ones:
>> (1) lots of writeback with no swap
>> (2) churning clean pages with no swap
>> (3) swapping
>> And each of these with several proportions of memory sharing.
>> Sound reasonable?

On Wed, Jul 10, 2002 at 05:39:47PM -0700, Andrew Morton wrote:
> Sounds ideal.  Care to flesh these out into real use cases?

(1) would be a system dedicated to data collection in real-life.
	Lots of writeback without swap is also a common database
	scenario. At any rate, it's intended to measure how effective
	and/or efficient replacement is when writeback is required to
	satisfy allocations.


(2) would be a system dedicated to distributing data in real life.
	This would be a read-only database scenario or (ignoring
	single vs. multiple files) webserving. It's intended to
	measure how effective page replacement is when clean pages
	must be discarded to satisfy allocations.

	These two testcases would be constellations of sibling processes
	mmapping a shared file-backed memory block larger than memory
	(where it departs from database-land) and stomping all over it
	in various patterns. Random, forward sequential, backward
	sequential, mixtures of different patterns across processes,
	mixtures of different patterns over time, varying frequencies
	of access to different regions of the arena and checking to see
	that proportions of memory being reclaimed corresponds to
	frequency of access, and sudden shifts between (1) and (2) would
	all be good things to measure, but the combinatorial explosion
	of options here hurts.

	The measurable criterion is of course throughput shoveling data.
	But there are many useful bits to measure here, e.g. the amount
	of cpu consumed by replacement, how much actually gets scanned
	for that cpu cost, and how right or wrong the guesses were when
	variable frequency access is used.


(3) this is going to be a "slightly overburdened desktop" workload
	here it's difficult to get a notion of how to appropriately
	simulate the workload, but I have a number of things in mind
	as to how to measure some useful things for one known case:

	(A) there are a number (300?) of tasks that start up, fault in
		some crud, and sleep forever -- in fact the majority
		They're just there in the background to chew up some
		space with per-task and per-mm pinned pages.
	(B) there are a number of tasks that are spawned when timer
		goes off, then they stomp on a metric buttload of stuff
		and exit until spawned for the next interval, e.g.
		updatedb, and of course none of the data it uses is
		useful for anything else and is all used just once.
		This can be dcache, buffer cache, pagecache, or anything.
	(C) there are a number of tasks that get prodded and fault on
		minor amounts of stuff and have mostly clean mappings
		but occasionally they'll all sleep for a long time
		(e.g. like end-users sleeping through updatedb runs)
		Basically, get a pool of processes, let them sleep,
		shoot a random process with signals at random times,
		and when shot, a process stomps over some clean data
		with basically random access before going back to
		sleep.

	The goal is to throw (A) out the window, control how much is
	ever taken away from (C) and given to (B), and keep (C), who
	is the real user of the thing, from seeing horribly bad worst
	cases like after updatedb runs at 3AM. Or, perhaps, figuring
	out who the real users are is the whole problem...

	Okay, even though the updatedb stuff can (and must) be solved
	with dcache-specific stuff, the general problem remains as a
	different kind of memory can be allocated in the same way.
	Trying to fool the VM with different kinds of one-shot
	allocations is probably the best variable here; specific timings
	aren't really very interesting.

	The number that comes out of this is of course the peak
	pagefault rate of the tasks in class (C).

The other swapping case is Netscape vs. xmms:
	One huge big fat memory hog is so bloated its working set alone
	drives the machine to swapping. This is poked and prodded at
	repeatedly, at which time it of course faults in a bunch more
	garbage from its inordinately and unreasonably bloated beyond
	belief working set. Now poor little innocent xmms is running
	in what's essentially a fixed amount of memory and cpu but
	can't lose the cpu or the disk for too long or mp3's will skip.

	This test is meant to exercise the VM's control over how much cpu
	and -disk bandwidth- it chews at one time so that well-behaved
	users don't see unreasonable latencies as the VM swamps their
	needed resources.

	I suspect the way to automate it is to generate signals to wake
	the bloated mem hog at random intervals, and that mem hog then
	randomly stomps over a bunch of memory. The innocent victim
	keeps a fixed-size arena where it sequentially slurps in fresh
	files, generates gibberish from their contents into a dedicated
	piece of its fixed-size arena, and then squirts out the data at
	what it wants to be a fixed rate to some character device. So
	the write buffer will always be dirty and the read buffer clean,
	except it doesn't really mmap. Oh, and of course, it takes a
	substantial but not overwhelming amount of cpu (25-40% for
	ancient p200's or something?) to generate the stuff it writes.

	Then the metric used is the variability in the read and write
	rates and %cpu used of the victim.


Uh-oh, this stuff might take a while to write... any userspace helpers
around?


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
