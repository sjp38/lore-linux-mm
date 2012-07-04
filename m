Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id D91726B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 05:51:39 -0400 (EDT)
Date: Wed, 4 Jul 2012 10:51:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [MMTests] IO metadata on XFS
Message-ID: <20120704095130.GI14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de>
 <20120701235458.GM19223@dastard>
 <20120702063226.GA32151@infradead.org>
 <20120702143215.GS14154@suse.de>
 <20120702193516.GX14154@suse.de>
 <20120703001928.GV19223@dastard>
 <20120703105951.GB14154@suse.de>
 <20120704004706.GD19223@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120704004706.GD19223@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, dri-devel@lists.freedesktop.org, Keith Packard <keithp@keithp.com>, Eugeni Dodonov <eugeni.dodonov@intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>

On Wed, Jul 04, 2012 at 10:47:06AM +1000, Dave Chinner wrote:
> > > > <SNIP>
> > > > [c999a223: xfs: introduce an allocation workqueue]
> > > 
> > > Which indicates that there is workqueue scheduling issues, I think.
> > > The same amount of work is being done, but half of it is being
> > > pushed off into a workqueue to avoid stack overflow issues (*).  I
> > > tested the above patch in anger on an 8p machine, similar to the
> > > machine you saw no regressions on, but the workload didn't drive it
> > > to being completely CPU bound (only about 90%) so the allocation
> > > work was probably always scheduled quickly.
> > 
> > What test were you using?
> 
> fsmark, dbench, compilebench, and a few fio workloads. Also,
> xfstests times each test and I keep track of overall runtime, and
> none of those showed any performance differential, either...
> 

Sound. I have some coverage on some of the same tests. When I get to
them I'll keep an eye on the 3.4 figures. It might be due to the disk
I'm using. It's a single disk and nothing to write home about in terms of
performance. It's not exactly XFS's usual target audience.

> Indeed, running on a current 3.5-rc5 tree, my usual fsmark
> benchmarks are running at the same numbers I've been seeing since
> about 3.0 - somewhere around 18k files/s for a single thread, and
> 110-115k files/s for 8 threads.
> 
> I just ran your variant, and I'm getting about 20kfile/s for a
> single thread, which is about right because you're using smaller
> directories than I am (22500 files per dir vs 100k in my tests).
> 

I had data for an fsmark-single test running with 30M files and FWIW the
3.4 performance figures were in line with 3.0 and later kernels.

> > > How many worker threads have been spawned on these machines
> > > that are showing the regression?
> > 
> > 20 or 21 generally. An example list as spotted by top looks like
> 
> Pretty normal.
> 
> > > What is the context switch rate on the machines whenteh test is running?
> .....
> > Vanilla average context switch rate	4278.53
> > Revert average context switch rate	1095
> 
> That seems about right, too.
> 
> > > Can you run latencytop to see
> > > if there is excessive starvation/wait times for allocation
> > > completion?
> > 
> > I'm not sure what format you are looking for.
> 
> Where the context switches are coming from, and how long they are
> abeing stalled for.

Noted. Capturing latency_stats over time is enough to do that. It won't
give a per-process breakdown but in the majority of cases that is not a
problem. Extracting the data is a bit annoying but not impossible and
better than parsing latencytop. Ideally, latencytop would be able to log
data in some sensible format. hmmm.

> Just to get the context switch locations, you
> can use perf on the sched:sched_switch event, but that doesn't give
> you stall times.

No, but both can be captured and roughly correlated with each other
given sufficient motivation.

> Local testing tells me that about 40% of the
> switches are from xfs_alloc_vextent, 55% are from the work threads,
> and the rest are CPU idling events, which is exactly as I'd expect.
> 
> > > A pert top profile comparison might be informative,
> > > too...
> > > 
> > 
> > I'm not sure if this is what you really wanted. I thought an oprofile or
> > perf report would have made more sense but I recorded perf top over time
> > anyway and it's at the end of the mail.
> 
> perf report and oprofile give you CPU usage across the run, it's not
> instantaneous and that's where all the interesting information is.
> e.g. a 5% sample in a 20s profile might be 5% per second for 20s, or
> it might be 100% for 1s - that's the behaviour run profiles cannot
> give you insight into....
> 

Fair point. I'll fix up the timestamping and keep the monitor for future
reference.

> As it is, the output you posted is nothing unusual.
> 

Grand. I had taken a look but I saw nothing particularly unusual but I
also was not 100% sure what I should be looking for.,

> > For just these XFS tests I've uploaded a tarball of the logs to
> > http://www.csn.ul.ie/~mel/postings/xfsbisect-20120703/xfsbisect-logs.tar.gz
> 
> Ok, so the main thing I missed when first looking at this is that
> you are concerned about single thread regressions.

In this specific test, yes. In the original data I posted I had threaded
benchmarks but they did not show the regression. This was a rerun with
just the single threaded case. Generally I run both because I see bug
reports involving both types of test.

> Well, I can't
> reproduce your results here. Single threaded with or without the
> workqueue based allocation gives me roughly 20k +/-0.5k files/s one
> a single disk, a 12 disk RAID0 array and a RAM disk on a 8p/4GB RAM
> machine.  That's the same results I've been seeing since I wrote
> this patch almost 12 months ago....
> 
> So, given that this is a metadata intensive workload, the only
> extent allocation is going to be through inode and directory block
> allocation. These paths do not consume a large amount of stack, so
> we can tell the allocator not to switch to workqueue stack for these
> allocations easily.
> 
> The patch below does this. It completely removes all the allocation
> based context switches from the no-data fsmark workloads being used
> for this testing. It makes no noticable difference to performance
> here, so I'm interested if it solves the regression you are seeing
> on your machines.
> 

It does. nodefer-metadata is just your patch applied on top of 3.4 and is
the right-most column. It's within the noise for the reverted patches and
approximately the same performance as 3.3. If you look at the timing
stats at the bottom you'll see that hte patch brings the System time way
down so consider this a

Tested-by: Mel Gorman <mgorman@suse.de>

FS-Mark Single Threaded
                 fsmark-single      single-3.4.0      single-3.4.0      single-3.4.0      single-3.4.0
                 3.4.0-vanilla   revert-aa464191   revert-c999a223       revert-both  nodefer-metadata
Files/s  min       14176.40 ( 0.00%)    17830.60 (25.78%)    24186.70 (70.61%)      25108.00 (77.11%)    25448.40 (79.51%)
Files/s  mean      16783.35 ( 0.00%)    25029.69 (49.13%)    37513.72 (123.52%)     38169.97 (127.43%)   36393.09 (116.84%)
Files/s  stddev     1007.26 ( 0.00%)     2644.87 (162.58%)    5344.99 (430.65%)      5599.65 (455.93%)    5961.48 (491.85%)
Files/s  max       18475.40 ( 0.00%)    27966.10 (51.37%)    45564.60 (146.62%)     47918.10 (159.36%)   47146.20 (155.18%)
Overhead min      593978.00 ( 0.00%)   386173.00 (34.99%)   253812.00 (57.27%)     247396.00 (58.35%)   248906.00 (58.10%)
Overhead mean     637782.80 ( 0.00%)   429229.33 (32.70%)   322868.20 (49.38%)     287141.73 (54.98%)   284274.93 (55.43%)
Overhead stddev    72440.72 ( 0.00%)   100056.96 (-38.12%)  175001.08 (-141.58%)   102018.14 (-40.83%)  114055.47 (-57.45%)
Overhead max      855637.00 ( 0.00%)   753541.00 (11.93%)   880531.00 (-2.91%)     637932.00 (25.44%)   710720.00 (16.94%)

MMTests Statistics: duration
Sys Time Running Test (seconds)              44.06     32.25     24.19     23.99     24.38
User+Sys Time Running Test (seconds)         50.19     36.35     27.24      26.7     27.12
Total Elapsed Time (seconds)                 59.21     44.76     34.95     34.14     36.11

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
