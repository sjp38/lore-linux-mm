Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A94486B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 20:13:45 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j124so117200820ith.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 17:13:45 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id v128si15686794iod.113.2016.07.28.17.13.43
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 17:13:44 -0700 (PDT)
Date: Fri, 29 Jul 2016 10:13:40 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
Message-ID: <20160729001340.GM12670@dastard>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
 <5e6e4f2d-ae94-130e-198d-fa402a9eef50@suse.de>
 <20160728054947.GL12670@dastard>
 <20160728102513.GA2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160728102513.GA2799@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Tony Jones <tonyj@suse.de>, Michal Hocko <mhocko@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Thu, Jul 28, 2016 at 11:25:13AM +0100, Mel Gorman wrote:
> On Thu, Jul 28, 2016 at 03:49:47PM +1000, Dave Chinner wrote:
> > Seems you're all missing the obvious.
> > 
> > Add a tracepoint for a shrinker callback that includes a "name"
> > field, have the shrinker callback fill it out appropriately. e.g
> > in the superblock shrinker:
> > 
> > 	trace_shrinker_callback(shrinker, shrink_control, sb->s_type->name);
> > 
> 
> That misses capturing the latency of the call unless there is a begin/end
> tracepoint.

Sure, but I didn't see that in the email talking about how to add a
name. Even if it is a requirement, it's not necessary as we've
already got shrinker runtime measurements from the
trace_mm_shrink_slab_start and trace_mm_shrink_slab_end trace
points. With the above callback event, shrinker call runtime is
simply the time between the calls to the same shrinker within
mm_shrink_slab start/end trace points.

We don't need tracepoint to measure everything - we just need enough
tracepoints that we can calculate everything we need by post
processing the trace report, and the above gives you shrinker
runtime latency. You need to look at the tracepoints in the wider
context of the code that is running, not just the individual
tracepoint itself.

IOWs, function runtime is obvious from the pattern of related tracepoints
and their timestamps.  Timing information is in the event traces, so
duration between two known tracepoints is a simple calculation.

	[0.0023]	mm_shrink_slab_start:	shrinker 0xblah ....
	[0.0025]	shrinker_callback:	shrinker 0xblah name xfs
	.....		[xfs events ignored]
	[0.0043]	shrinker_callback:	shrinker 0xblah name xfs
	.....		[xfs events ignored]
	[0.0176]	shrinker_callback:	shrinker 0xblah name xfs
	.....		[xfs events ignored]
	[0.0178]	mm_shrink_slab_end:	shrinker 0xblah .....


Now run awk to grab the '/shrinker 0xblah/ { .... } ' - That
information contains everything you need to calculate shrinker
runtime. i.e.  It ran 3 times, taking 1.8ms, 13ms and 0.2ms on each
of the calls.

That's exactly how I work out timings of various operations in XFS.
e.g. how long a specific metadata IO has taken, how long IO
completion has been queued on the endio workqueue before it got
processed, how long a process waited on a buffer lock, etc. Pick
your specific tracepoints from the haystack, post process with
grep/awk/sed/python to find the needle.

If you need more specific information than a tracepoint can give
you, then you can either add more tracepoints or craft a custom
tracer function to drill deeper.  Almost no-one will need anything
more than knowing what shrinker is running, as most shrinkers are
quite simple. Those that are more complex have their own internal
tracepoints that will tell you exactly where and why it is stalling
without the need for custom tracers....

> I was aware of the function graph tracer but I don't know how
> to convince that to give the following information;
>
> 1. The length of time spent in a given function
> 2. The tracepoint information that might explain why the stall occurred
> 
> Take the compaction tracepoint for example
> 
>         trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
>                                 cc->free_pfn, end_pfn, sync);
> 
> 	...
> 
> 	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
>                                 cc->free_pfn, end_pfn, sync, ret);
> 
> The function graph tracer can say that X time is compact_zone() but it
> cannot distinguish between a short time spent in that function because
> compaction_suitable == false or compaction simply finished quickly.

That information (i.e. value of compaction_suitable) should be in
the trace_mm_compaction_end() tracepoint, then. If you need context
information to make sense of the tracepoint then it should be in the
tracepoint.

> My understanding was the point of the tracepoints was to get detailed
> information on points where the kernel is known to stall for long periods
> of time.

First I've heard that's what tracepoints are supposed to be used
for. They are just debugging information points in the code and can
be used for any purpose you need as a developer....

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
