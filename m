Received: from host-54.subnet-241.amherst.edu
 (sfkaplan@host-54.subnet-241.amherst.edu [148.85.241.54])
 by amherst.edu (PMDF V5.2-33 #45524)
 with ESMTP id <01K3BKLR13AMA4P5XO@amherst.edu> for linux-mm@kvack.org; Tue,
 8 May 2001 12:25:38 EDT
Date: Tue, 08 May 2001 08:25:47 -0400 (EDT)
From: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
Subject: Re: on load control / process swapping
In-reply-to: 
        <Pine.LNX.4.21.0105061924160.582-100000@imladris.rielhome.conectiva>
Message-id: <Pine.LNX.4.21.0105081021400.969-100000@localhost.localdomain>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Okay, in responding to this topic, I will issue a warning:  I'm
looking at this from an academic point of view, and probably won't
give as much attention to what is reasonable to engineer as some
people might like.  That said, I think I might have some useful
thoughts...y'all can be the judge of that.

On Mon, 7 May 2001, Rik van Riel wrote:

> In short, the process suspension / wake up code only does
> load control in the sense that system load is reduced, but
> absolutely no effort is made to ensure that individual
> programs can run without thrashing. This, of course, kind of
> defeats the purpose of doing load control in the first place.

First, I agree -- To suspend a process without any calculation that
will indicate that the suspension will reduce the page fault rate is
to operate blindly.  Performing such a calculation, though, requires
some information about the locality characteristics of each process,
based on recent reference behavior.  What would be really nice is some
indication as to how much additional space would reduce paging for
each of the processes that will remain active.  For some, a little
extra space won't help much, and for others, a little extra space is
just what it needs for a significant reduction.  Determining which
processes are which, and just how much "a little extra" needs to be,
seems important in this context.

Second, a nit pick:  We're using the term "thrashing" in so many ways
that it would be nice to standardize on something so that we
understand one another.  As I understand it, the textbook definition
of thrashing is the point at which CPU utilization falls because all
active processes are I/O bound.  That is, thrashing is a system-wide
characteristic, and not applicable to individual processes.  That's
why some people have pointed out that "thrashing" and "heavy paging"
aren't the same thing.  A single process can cause heavy paging while
the CPU is still fully loaded with the work of other processes.  

So, given the paragraph above, are you talking a single process that
may still be paging heavily, in spite of the additional free space
created by process suspension?  (Like I said, it was a nit pick.)  I'm
assuming that's what you mean.

> Any solution will have to address the following points:
> 
> 1) allow the resident processes to stay resident long
>    enough to make progess

Seems reasonable.

> 2) make sure the resident processes aren't thrashing,
>    that is, don't let new processes back in memory if
>    none of the currently resident processes is "ready"
>    to be suspended

What does it mean to be ready to be suspended?  I'm confused by this
one.

> 3) have a mechanism to detect thrashing in a VM
>    subsystem which isn't rate-limited  (hard?)

What's your definition of "thrashing" here?  If it's the system-wide
version, detection of this situation doesn't seem to be too difficult:
When all processes are stalled on page faults, and that situation
obtains over time recently, then the system is thrashing.  Detecting
whether or not a single process is thrashing (paging hopelessly) is a
different matter.  You could deactivate this process (or some other in
the hopes of helping this process), but it could be the case the a
reallocation of space could stop this process from paging so heavily
while not increasing the paging rate of any other process
substantially.

> and, for extra brownie points:
> 4) fairness, small processes can be paged in and out
>    faster, so we can suspend&resume them faster; this
>    has the side effect of leaving the proverbial root
>    shell more usable

I think point should have greater significance.  The very issue at
hand is that fairness and throughput are at odds when there is
contention for memory.  The central question (I think) is, "Given
paging sufficiently detrimental to progress, *how* unfair should the
system be in order to restore progress and increase throughput?"  Note
that if we want increased throughput, we can easily come up with a
scheme that almost completely throws fairness to the wind, and we'll
get great reductions in total paging and incrases in process
throughput.  For a time-sharing system, though, there should probably
a limit to the unfairness.

There has never been a really good solution to this kind of problem,
and there seems to be two important sides to it:

1) Given a level of fairness that you want to maintain, how can you
   keep the paging as low as possible?

2) Given the unfairness you're willing to use, how can you select
   eligible processes intelligently so as to maximize the reduction in
   total paging?

Question 1 is associated, and an important problem, but not part of
the issue here.  Question 2 seems to be the central question, and a
hard one.  I have trouble believing that any solution to Question 2
will make sense if it does not refer directly to the reference
behavior of both the suspended process, and the reference behavior of
the remaining active processes. 

I also have trouble with any solution to Question 2 that doesn't take
into account the cost associated with the deactivation and
reactivation steps.  When a process is reactivated, it's going to
cause substantial paging activity, and so it needs not to be done too
frequently.  If you're going to be unfair, then leave the deactivated
process out for long enough that the cost of paging it back in will be
a small fraction of the total time spent on the
deactivation/reactivation activities.

I hope these are useful thoughts.  Despite all of my complaining here,
I think this problem has been insufficiently addressed for a long
time.  Working Set counted on it, but there was never a study that
showed a good strategy for deacivation/reactivation, in spite of the
fact that different choices could significantly affect the results.
I'd like very much to see a solution to this particular problem.

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE69+Wz8eFdWQtoOmgRAopvAJ0QuVPjUFZU5Pa78JsNUSgndKmGGwCdGJ2/
YKDVahEmCMm7yfoSXnrvfE4=
=Ql2h
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
