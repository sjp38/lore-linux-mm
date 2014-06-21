Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B68286B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 20:39:11 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so3640965pab.36
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:39:11 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id ja1si11745125pbc.254.2014.06.20.17.39.09
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 17:39:10 -0700 (PDT)
Date: Sat, 21 Jun 2014 10:39:06 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/4] cfq: Increase default value of target_latency
Message-ID: <20140621003906.GW9508@dastard>
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
 <1403079807-24690-2-git-send-email-mgorman@suse.de>
 <x49y4wslp6z.fsf@segfault.boston.devel.redhat.com>
 <20140619214214.GM4453@dastard>
 <20140620113025.GG10819@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140620113025.GG10819@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jeff Moyer <jmoyer@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>

On Fri, Jun 20, 2014 at 12:30:25PM +0100, Mel Gorman wrote:
> On Fri, Jun 20, 2014 at 07:42:14AM +1000, Dave Chinner wrote:
> > On Thu, Jun 19, 2014 at 02:38:44PM -0400, Jeff Moyer wrote:
> > > Mel Gorman <mgorman@suse.de> writes:
> > > 
> > > > The existing CFQ default target_latency results in very poor performance
> > > > for larger numbers of threads doing sequential reads.  While this can be
> > > > easily described as a tuning problem for users, it is one that is tricky
> > > > to detect. This patch the default on the assumption that people with access
> > > > to expensive fast storage also know how to tune their IO scheduler.
> > > >
> > > > The following is from tiobench run on a mid-range desktop with a single
> > > > spinning disk.
> > > >
> > > >                                       3.16.0-rc1            3.16.0-rc1                 3.0.0
> > > >                                          vanilla          cfq600                     vanilla
> > > > Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      134.59 ( 10.42%)
> > > > Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      122.59 ( 20.20%)
> > > > Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      114.78 ( 17.82%)
> > > > Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)      100.14 ( 20.09%)
> > > > Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.64 ( 18.50%)
> > > 
> > > Did you test any workloads other than this?  Also, what normal workload
> > > has 8 or more threads doing sequential reads?  (That's an honest
> > > question.)
> > 
> > I'd also suggest that making changes basd on the assumption that
> > people affected by the change know how to tune CFQ is a bad idea.
> > When CFQ misbehaves, most people just switch to deadline or no-op
> > because they don't understand how CFQ works, nor what what all the
> > nobs do or which ones to tweak to solve their problem....
> 
> Ok, that's fair enough. Tuning CFQ is tricky but as it is, the default
> performance is not great in comparison to older kernels and it's something
> that has varied considerably over time. I'm surprised there have not been
> more complaints but maybe I just missed them on the lists.

That's because there are widespread recommendations not to use CFQ
if you have any sort of significant storage or IO workload. We
specifically recommend that you don't use CFQ with XFS
because it does not play nicely with correlated multi-process
IO. This is something that happens a lot, even with single threaded
workloads.

e.g. a single fsync can issue dependent IOs from multiple
process contexts - the syscall process for data IO, the allocation
workqueue kworker for btree blocks, the xfsaild to push metadata to
disk to make space available for the allocation transaction, and
then the journal IO from the xfs log workqueue kworker.

There's 4 IOs, all from different process contexts, all of which
need to be dispatched and completed with the minimum of latency.
With CFQ adding scheduling and idling delays in the middle of this,
it tends to leave disks idle when they really should be doing work.

We also don't recommend using CFQ when you have hardware raid with
caches, because the HW RAID does a much, much better job of
optimising and prioritising IO through it's cache. Idling is
wrong if the cache has hardware readahead, because most subsequent
read IOs will hit the hardware cache. Hence you could be dispatching
other IO instead of idling, yet still get minimal IO latency  across
multiple streams of different read workloads.

Hence people search on CFQ problems, see the "use deadline"
recommendations, change to deadline and see there IO workload going
faster. So they shrug their shoulders, set deadline as the
default, and move on to the next problem...

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
