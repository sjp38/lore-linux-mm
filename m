Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C24BF6B0388
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 18:52:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 2so43538272pfz.5
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:52:50 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id g27si11587975pgn.377.2017.02.17.15.52.48
        for <linux-mm@kvack.org>;
        Fri, 17 Feb 2017 15:52:49 -0800 (PST)
Date: Sat, 18 Feb 2017 10:52:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Bug 192981] New: page allocation stalls
Message-ID: <20170217235245.GE15349@dastard>
References: <bug-192981-27@https.bugzilla.kernel.org/>
 <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
 <8f450abd-4e05-92d3-2533-72b05fea2012@beget.ru>
 <20170215160538.GA62565@bfoster.bfoster>
 <a055abbf-a471-d111-9491-dc5b00208228@beget.ru>
 <20170215180859.GB62565@bfoster.bfoster>
 <07ee50bc-8220-dda8-07f9-369758603df9@beget.ru>
 <20170216172034.GC11750@bfoster.bfoster>
 <20170216222129.GB15349@dastard>
 <20170217190500.GC20429@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217190500.GC20429@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Alexander Polakov <apolyakov@beget.ru>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Fri, Feb 17, 2017 at 02:05:00PM -0500, Brian Foster wrote:
> On Fri, Feb 17, 2017 at 09:21:29AM +1100, Dave Chinner wrote:
> > On Thu, Feb 16, 2017 at 12:20:34PM -0500, Brian Foster wrote:
> > > A couple things that might
> > > help avoid this situation are more aggressive
> > > /proc/sys/fs/xfs/xfssyncd_centisecs tuning or perhaps considering a
> > > smaller log size would cause more tail pushing pressure on the AIL
> > > instead of pressure originating from memory reclaim. The latter might
> > > not be so convenient if this is an already populated backup server,
> > > though.
> > > 
> > > Beyond that, there's Chris' patch, another patch that Dave proposed[2],
> > > and obviously your hack here to defer inode reclaim entirely to the
> > > workqueue (I've CC'd Dave since it sounds like he might have been
> > > working on this further..).
> > 
> > I was working on a more solid set of changes, but every time I
> > updated the kernel tree I used as my base for development, the
> > baseline kernel reclaim behaviour would change. I'd isolate the
> > behavioural change, upgrade to the kernel that contained the fix,
> > and then trip over some new whacky behaviour that made no sense. I
> > spent more time in this loop than actually trying to fix the XFS
> > problem - chasing a moving target makes finding the root cause of
> > the reclaim stalls just about impossible. 
> > 
> > Brian, I can send you what I have but it's really just a bag of
> > bolts at this point because I was never able to validate that any of
> > the patches made a measurable improvement to reclaim behaviour under
> > any workload I ran.....
> > 
> 
> Sure, I'm curious to see what direction this goes in. I would think
> anything that provides a backoff to other shrinkers would help this
> particular workload where many different filesystems are active. FWIW,
> I'd probably also need more details about what workloads you're testing
> and how you're measuring improvements and whatnot to try and take any of
> that stuff any farther (particularly how you verify the problems with
> dropping blocking behavior entirely), though..

Ok, I'll send you a copy...

> > FWIW, the major problem with removing the blocking in inode reclaim
> > is the ease with which you can then trigger the OOM killer from
> > userspace.  The high level memory reclaim algorithms break down when
> > there are hundreds of direct reclaim processes hammering on reclaim
> > and reclaim stops making progress because it's skipping dirty
> > objects.  Direct reclaim ends up insufficiently throttled, so rather
> > than blocking it winds up reclaim priority and then declares OOM
> > because reclaim runs out of retries before sufficient memory has
> > been freed.
> > 
> 
> I'd need to spend some time in the shrinker code to grok this, but if
> there's such a priority, would switching blocking behavior based on
> priority provide a way to mitigate this problem from within the
> shrinker? For example, provide non-blocking behavior on the lowest
> priority to kick off flushing and allow progress into other shrinkers,
> otherwise we flush and wait if the priority is elevated..?

I tried that - exporting the priority to the shrink_control and so
on. The system either behaved the same (i.e. stalled on reclaim) or
randomly fell into a screaming pile of OOM killer rage-death. There
was no in-between reliable state...

> IOW, it sounds like the problem in this case is that we subject the rest
> of the allocation infrastructure to delays in configurations where we
> are one of N potential shrinkers with reclaimable objects, because we
> have to deal with this situation where our one shrinker actually is the
> main/primary choke point for multiple allocator -> direct reclaimers.

Yup. The mm reclaim design sucks ass because if we use purely
non-blocking reclaim techniques in the shrinkers we have no way of
throttling allocation demand to the rate at which shrinkers can
reclaim objects and we end up with gross cache imbalances under
memory pressure.

> I'm wondering if some kind of severity parameter managed by the shrinker
> infra would help us distinguish between those scenarios (even if it were
> a dumb LOW/HIGH priority param, where LOW allows for one pass through
> all of the shrinkers to kick off I/O and whatnot before any one of them
> should actually block on locks or I/O). Then again, I'm just handwaving
> as I'm only just familiarizing with the context and problem.

Tried that, too. :( Several different ways over the past few years.
Remember that we also have the non-blocking background reclaim
thread - even triggering that immediately on reclaim doesn't
prevent stalls, and my last patchset specifically excluded it
from concurrency control so it always ran immediately on reclaim

Hmmm - I just had a thought.

Perhaps all we need to do is remove direct reclaim from the
shrinker. i.e. make the background reclaimer run on a ticket based
queuing system similar to the log reservations...

For non-blocking reclaim (i.e.  kswapd), we just queue the ticket
and return immediately, saying we've done the scan. 

For blocking reclaim, we take a ticket with the blocking scan count
on it and wait in the wakeup queue.  As background reclaim runs, it
decrements the lead ticket scan count. When it hits zero, wake up
the head of the wait queue. When the background thread has no
pending reclaim tickets or has nothing left to scan/reclaim (i.e.
goes idle), wake everyone....

This means waiting is ordered, it doesn't matter where in the fs we
reclaim from, direct reclaim itself doesn't get stuck waiting for
IO/transactions/log flushing, concurrency is managed by how we
process the ticket queue, and when we have lots of direct reclaim
demand then the background thread just keeps running as optimally as
possible and kswapd is never blocked...

> (I also see no priority in struct shrink_control, so I guess that's an
> internal reclaim thing as it is.)

Yup, I had to promote it all the way through from the struct
scan_control -> priority field.

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
