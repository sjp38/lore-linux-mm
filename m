Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B35768D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 08:59:12 -0400 (EDT)
Date: Fri, 25 Mar 2011 20:59:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110325125907.GA7997@localhost>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <20110318143001.GA6173@localhost>
 <20110322214314.GC19716@quack.suse.cz>
 <20110323044152.GI15270@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110323044152.GI15270@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

Hi Dave,

On Wed, Mar 23, 2011 at 12:41:52PM +0800, Dave Chinner wrote:
> On Tue, Mar 22, 2011 at 10:43:14PM +0100, Jan Kara wrote:
> >   Hello Fengguang,
> > 
> > On Fri 18-03-11 22:30:01, Wu Fengguang wrote:
> > > On Wed, Mar 09, 2011 at 06:31:10AM +0800, Jan Kara wrote:
> > > > 
> > > >   Hello,
> > > > 
> > > >   I'm posting second version of my IO-less balance_dirty_pages() patches. This
> > > > is alternative approach to Fengguang's patches - much simpler I believe (only
> > > > 300 lines added) - but obviously I does not provide so sophisticated control.
> > > 
> > > Well, it may be too early to claim "simplicity" as an advantage, until
> > > you achieve the following performance/feature comparability (most of
> > > them are not optional ones). AFAICS this work is kind of heavy lifting
> > > that will consume a lot of time and attention. You'd better find some
> > > more fundamental needs before go on the reworking.

To start with, let me explain the below items and you judge whether
they are desirable ones now and future.

> > > (1)  latency

The potential impact a write(2) syscall get blocked for over 200ms
could be

- user perceptible unresponsiveness

- interrupted IO pipeline in such kind of applications

        loop {
                read(buf)
                write(buf)
        }

  In particular the read() IO stream will be interrupted. If it's a
  read stream from another disk, then the disk may go idle for the
  period. If it's a read stream from network, the client side
  uploading files via an ADSL link will find the upload bandwidth
  under-utilized.

> > > (2)  fairness

This is raised by Jan Kara. It should be application dependent.
Some workloads may not care at all.  Some may be more sensitive.

> > > (3)  smoothness

It reflects the variation of a task's throttled dirty bandwidth.
The fluctuation of dirty rate can degrade the possible read-write IO
pipeline in the similar way as (1).

> > > (4)  scalability

Being able to scale well to 1000+ dirtiers, and to large number of
CPUs and disks.

> > > (5)  per-task IO controller
> > > (6)  per-cgroup IO controller (TBD)
> > > (7)  free combinations of per-task/per-cgroup and bandwidth/priority controllers
> > > (8)  think time compensation

The IO controller stuff. It seems there are only disparities on when
and how to provide the features. (5) and priority based IO controller
are the side product of the base bandwidth solution.

> > > (9)  backed by both theory and tests

The prerequisites for quality code.

> > > (10) adapt pause time up on 100+ dirtiers

To reduce CPU overheads, requested by you :)

> > > (11) adapt pause time down on low dirty pages 

This is necessary to avoid < 100% disk utilization on small memory
systems.

> > > (12) adapt to new dirty threshold/goal

This is to support dynamically lowering the number of dirty pages 
in order to avoid excessive page_out() during page reclaim.

> > > (13) safeguard against dirty exceeding

This is a must have to prevent DoS situations. There have to be a hard
dirty limit that force the dirtiers to loop inside balance_dirty_pages().
Because the regular throttling scheme in both Jan and my patches can
at most throttle the dirtier at eg. 200ms per page. This is not enough
to stop the dirty pages from growing high when there are many dirtiers
writing to a slow USB stick.

> > > (14) safeguard against device queue underflow
(in JBOD case, maintain reasonable number of dirty pages in each disk queue)

This is necessary to avoid < 100% disk utilization on small memory
systems. Note that (14) and (11) share the same goal, however need
independent safeguards at two different places.

> >   I think this is a misunderstanding of my goals ;). My main goal is to
> > explore, how far we can get with a relatively simple approach to IO-less
> > balance_dirty_pages(). I guess what I have is better than the current
> > balance_dirty_pages() but it sure does not even try to provide all the
> > features you try to provide.
> 
> This is my major concern - maintainability of the code. It's all
> well and good to evaluate the code based on it's current
> performance, but what about 2 or 3 years down the track when for
> some reason it's not working like it was intended - just like what
> happened with slow degradation in writeback performance between
> ~2.6.15 and ~2.6.30.
>
> Fundamentally, the _only_ thing I want balance_dirty_pages() to do
> is _not issue IO_. Issuing IO in balance_dirty_pages() simply does
> not scale, especially for devices that have no inherent concurrency.
> I don't care if the solution is not perfectly fair or that there is
> some latency jitter between threads, I just want to avoid having the
> IO issue patterns change drastically when the system runs out of
> clean pages.
> 
> IMO, that's all we should be trying to acheive with IO-less write
> throttling right now. Get that algorithm and infrastructure right
> first, then we can work out how to build on that to do more fancy
> stuff.

You already got what you want in the base bandwidth patches v6 :)
It has been tested extensively and is ready for more wide -mm
exercises. Plus more for others that actually care.

As long as the implemented features/performance are

- desirable in long term
- cannot be done in fundamentally more simple/robust way

Then I see no point to drop the ready-to-work solution and take so
much efforts to breed another one, perhaps taking 1-2 more release
cycles only to reach the same level of performance _and_ complexity.

> > I'm thinking about tweaking ratelimiting logic to reduce latencies in some
> > tests, possibly add compensation when we waited for too long in
> > balance_dirty_pages() (e.g. because of bumpy IO completion) but that's
> > about it...
> > 
> > Basically I do this so that we can compare and decide whether what my
> > simple approach offers is OK or whether we want some more complex solution
> > like your patches...
> 
> I agree completely.
> 
> FWIW (and that may not be much), the IO-less write throttling that I
> wrote for Irix back in 2004 was very simple and very effective -
> input and output bandwidth estimation updated once per second, with
> a variable write syscall delay applied on each syscall also
> calculated once per second. The change to the delay was based on the
> difference between input and output rates and the number of write
> syscalls per second.
> 
> I tried all sorts of fancy stuff to improve it, but the corner cases
> in anything fancy led to substantial complexity of algorithms and
> code and workloads that just didn't work well.  In the end, simple
> worked better than fancy and complex and was easier to understand,
> predict and tune....

I may be one of the biggest sufferers of the inherent writeback
complexities, and would be more than pleased to have some simple
scheme that deals with only simple requirements. However.. I feel
obliged to treat smoothness as one requirement when everybody are
complaining writeback responsiveness issues in bugzilla, mailing list
as well as in LSF and kernel summit.

To help debug and evaluate the work, a bunch of test suites are
created and visualized. I can tell from the graphs that the v6 patches
are performing very good in all the test cases. It's achieved by 880
lines of code in page-writeback.c. It's good that Jan's v2 does it
merely in 300 lines of code, however it's still missing the code for
(10)-(14) and the performance gaps are simply too large in many of the
cases. IMHO it would need some non-trivial revisions to become a real
candidate.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
