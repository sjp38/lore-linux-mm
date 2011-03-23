Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B99DB8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 00:47:12 -0400 (EDT)
Date: Wed, 23 Mar 2011 15:41:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110323044152.GI15270@dastard>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <20110318143001.GA6173@localhost>
 <20110322214314.GC19716@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322214314.GC19716@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Mar 22, 2011 at 10:43:14PM +0100, Jan Kara wrote:
>   Hello Fengguang,
> 
> On Fri 18-03-11 22:30:01, Wu Fengguang wrote:
> > On Wed, Mar 09, 2011 at 06:31:10AM +0800, Jan Kara wrote:
> > > 
> > >   Hello,
> > > 
> > >   I'm posting second version of my IO-less balance_dirty_pages() patches. This
> > > is alternative approach to Fengguang's patches - much simpler I believe (only
> > > 300 lines added) - but obviously I does not provide so sophisticated control.
> > 
> > Well, it may be too early to claim "simplicity" as an advantage, until
> > you achieve the following performance/feature comparability (most of
> > them are not optional ones). AFAICS this work is kind of heavy lifting
> > that will consume a lot of time and attention. You'd better find some
> > more fundamental needs before go on the reworking.
> > 
> > (1)  latency
> > (2)  fairness
> > (3)  smoothness
> > (4)  scalability
> > (5)  per-task IO controller
> > (6)  per-cgroup IO controller (TBD)
> > (7)  free combinations of per-task/per-cgroup and bandwidth/priority controllers
> > (8)  think time compensation
> > (9)  backed by both theory and tests
> > (10) adapt pause time up on 100+ dirtiers
> > (11) adapt pause time down on low dirty pages 
> > (12) adapt to new dirty threshold/goal
> > (13) safeguard against dirty exceeding
> > (14) safeguard against device queue underflow
>   I think this is a misunderstanding of my goals ;). My main goal is to
> explore, how far we can get with a relatively simple approach to IO-less
> balance_dirty_pages(). I guess what I have is better than the current
> balance_dirty_pages() but it sure does not even try to provide all the
> features you try to provide.

This is my major concern - maintainability of the code. It's all
well and good to evaluate the code based on it's current
performance, but what about 2 or 3 years down the track when for
some reason it's not working like it was intended - just like what
happened with slow degradation in writeback performance between
~2.6.15 and ~2.6.30.

Fundamentally, the _only_ thing I want balance_dirty_pages() to do
is _not issue IO_. Issuing IO in balance_dirty_pages() simply does
not scale, especially for devices that have no inherent concurrency.
I don't care if the solution is not perfectly fair or that there is
some latency jitter between threads, I just want to avoid having the
IO issue patterns change drastically when the system runs out of
clean pages.

IMO, that's all we should be trying to acheive with IO-less write
throttling right now. Get that algorithm and infrastructure right
first, then we can work out how to build on that to do more fancy
stuff.

> I'm thinking about tweaking ratelimiting logic to reduce latencies in some
> tests, possibly add compensation when we waited for too long in
> balance_dirty_pages() (e.g. because of bumpy IO completion) but that's
> about it...
> 
> Basically I do this so that we can compare and decide whether what my
> simple approach offers is OK or whether we want some more complex solution
> like your patches...

I agree completely.

FWIW (and that may not be much), the IO-less write throttling that I
wrote for Irix back in 2004 was very simple and very effective -
input and output bandwidth estimation updated once per second, with
a variable write syscall delay applied on each syscall also
calculated once per second. The change to the delay was based on the
difference between input and output rates and the number of write
syscalls per second.

I tried all sorts of fancy stuff to improve it, but the corner cases
in anything fancy led to substantial complexity of algorithms and
code and workloads that just didn't work well.  In the end, simple
worked better than fancy and complex and was easier to understand,
predict and tune....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
