Date: Mon, 19 Aug 2002 15:05:22 -0400
Subject: Re: [PATCH] rmap 14
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
In-Reply-To: <Pine.LNX.4.44.0208162247590.874-100000@skynet>
Message-Id: <9C5FA1BA-B3A6-11D6-A545-000393829FA4@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday, August 16, 2002, at 07:02 PM, Mel wrote:

> It will take a *long* time to develop the full test suite to cover,
> faulting, page alloc, slab, vmscan, buffer caches etc..

Agreed.  This is a big project, and I don't expect that the first cut will 
do it all.

>> Or...was this process descheduled, and what you measured is the interval
>> between when this process last ran and when the scheduler put it on the
>> CPU again?
>
> The measure is the time when the script asked the module to read a page.
> [...] I don't call schedule although it is possible I get scheduled.

That's exactly the concern that I had.  Large timing result like that are 
more likely because your code was preempted for something else.  It would 
probably be good to do *something* about these statistical outliers, 
because they can affect averages substantially.  One suggestion is to come 
up with a reasonable upper bound -- something like 5x the normal cost of 
page fault when I/O swapping is required -- and eliminate all timings that 
are larger than the cutoff.  You miss some measurements, but you avoid 
doing weird things to detect cases where the scheduling is interfering 
with your timing.  You just need to be sure that it *is* the scheduling 
that's causing such anomalies, and not something else.

> At the time the test was started, 4 instances of konqueror were starting 
> to
> run and it hogs physical pages quiet a lot so it stands to reason it would
> collide with the test.

I agree that they're likely to compete.  I don't think it's going to be 
easy, though, to reason a-priori about what the result of that competition 
will be; that is, it's not clear to me that it will cause bursts of paging 
activity as opposed to some other kind of paging behavior.

> Lastly, this isn't justification for bad refernce data but even producing
> data with a know pattern is more reproducable than running kernel
> compiles, big dd's, large mmaps etc and timing the results.

A good point:  This is a tool for testing that the desired concepts were 
implemented correctly.  I'll buy that.

> Things have to start with simplified models because they can be easily
> understood at a glance. I think it's a bit unreasonable to expect a full
> featured suites at first release.

I agree.  I was heavy handed, probably unfairly so, but there was a 
purpose to the points I tried to make:  *Since* this is a work in progress,
  I wanted to provide feedback so that it would avoid some known, poor 
directions.  It's good that you know of the limitations of modeling 
reference behavior, but lots of people have fallen into that trap and used 
poor models for evaluative purposes, believing the results to be more 
conclusive and comprehensive than they really were.  I figured that it 
would be better to sound the warning on that problem *before* you got 
deeply into the modeling issues for this project.

Scott

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9YUF08eFdWQtoOmgRAuHAAJ474zwp3PA5UXmZCN5MWgsUzhajeACfepUF
asAVQ/KBoEz9bGFLQ0gpZ4E=
=PVV7
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
