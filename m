Message-ID: <3D2CD3D3.B43E0E1F@zip.com.au>
Date: Wed, 10 Jul 2002 17:39:47 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take three
References: <20810000.1026311617@baldur.austin.ibm.com> <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com> <20020710173254.GS25360@holomorphy.com> <3D2C9288.51BBE4EB@zip.com.au> <20020710222210.GU25360@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> ..
> Phenomenally harsh.

No offence I hope.  Just venting three year's VM frustration.
 
>...
> On Wed, Jul 10, 2002 at 01:01:12PM -0700, Andrew Morton wrote:
> > Bill, please throw away your list and come up with a new one.
> > Consisting of workloads and tests which we can run to evaluate
> > and optimise page replacement algorithms.
> 
> Your criteria are quantitative. I can't immediately measure all
> of them but can go about collecting missing data immediately and post
> as I go, then. Perhaps I'll even have helpers. =)

A lot of it should be fairly simple.  We have tons of pagecache-intensive
workloads.  But we have gaps when it comes to the VM.  In the area of
page replacement.

Can we fill those gaps with a reasonable amount of effort?

example 1:  "run thirty processes which mmap a common 50000 page file and
touch its pages in a random-but-always-the-same pattern at fifty pages
per second.  Then run (dbench|tiobench|kernel build|slocate|foo).  Then
see how many pages the three processes actually managed to touch."

example 2: "run a process which mallocs 60% of physical memory and
touches it randomly at 1000 pages/sec.  run a second process
which mallocs 60% of physical memory and touches it randomly at
500 pages/sec.   Measure aggregate throughput for both processes".

example 3: "example 2, but do some pagecache stuff as well".

example 4: "run a process which mmaps 60%-worth of memory readonly,
another which mmaps 60%-worth of memory MAP_SHARED.  First process
touches 1000 pages/sec.  Second process modifies 1000 pages/sec.
Optimise for throughput"

Scriptable things.  Things which we can optimise for with a
reasonable expectation that this will improve real workloads.

> On Wed, Jul 10, 2002 at 01:01:12PM -0700, Andrew Morton wrote:
> > Alternatively, please try to enumerate the `operating regions'
> > for the page replacement code.  Then, we can identify measurable
> > tests which exercise them.  Then we can identify combinations of
> > those tests to model a `workload'.    We need to get this ball
> > rolling somehow.
> > btw, I told Rik I'd start on that definition today, but I'm having
> > trouble getting started.  Your insight would be muchly appreciated.
> 
> Excellent. I'll not waste any more time discussing these kinds of
> benefits and focus on the ones considered relevant by maintainers.
> 
> I've already gone about asking for help benchmarking dmc's pte_chain
> space optimization, and I envision the following list of TODO items
> being things you're more interested in:
> 
> (1) measure the effect of rmap on page fault rate
> (1.5) try to figure out how many of mainline's faults came from the
>         virtual scan unmapping things
> (2) measure the effect of rmap on scan rate
> (3) measure the effect of rmap on cpu time consumed by scanning
> (4) measure the effect of per-zone LRU lists on cpu time consumed by
>         scanning
> (5) measure the effect of per-zone LRU list locks on benchmarks
> (6) maybe hack a simulator to compare the hardware referenced bits
>         to the software one computed by rmap and mainline
> (7) re-do(?) swap accuracy measurements in a more meaningful way
> 
> (5) may involve some pain to forward port and (6) is painful too.
> And these involve writing lots of instrumentation code...
> 
> What other missing data are you after and which of these should
> be chucked?

Well there are two phases to this.  One is to run workloads,
and the other is to analyse them.  I think workloads such as my
lame ones above are worth thinking about and setting up first,
don't you?    (And a lot of this will come from me picking your
brains ;).  I can do the coding, although by /bin/sh skills
are woeful.)

After that comes the analysis.  Looks like rmap will be merged in
the next few days for test-and-eval, so we don't need to go through
some great beforehand-justification exercise.  But we do need
a permanent toolkit and we do need a way of optimising the VM.

I would suggest that the toolkit consist of two things:

1: A set of scenarios and associated scripts/tools such as my
   examples above (except more real-worldy) and

2: Permanent in-kernel instrumentation which allows us (and
   remote testers) to understand what is happening in there.

 
> As far as operating regions for page replacement go I see 3 obvious ones:
> (1) lots of writeback with no swap
> (2) churning clean pages with no swap
> (3) swapping
> 
> And each of these with several proportions of memory sharing.
> Sound reasonable?

Sounds ideal.  Care to flesh these out into real use cases?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
