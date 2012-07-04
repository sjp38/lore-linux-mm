Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 4B8716B00B0
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 20:47:12 -0400 (EDT)
Date: Wed, 4 Jul 2012 10:47:06 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [MMTests] IO metadata on XFS
Message-ID: <20120704004706.GD19223@dastard>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de>
 <20120701235458.GM19223@dastard>
 <20120702063226.GA32151@infradead.org>
 <20120702143215.GS14154@suse.de>
 <20120702193516.GX14154@suse.de>
 <20120703001928.GV19223@dastard>
 <20120703105951.GB14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120703105951.GB14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, dri-devel@lists.freedesktop.org, Keith Packard <keithp@keithp.com>, Eugeni Dodonov <eugeni.dodonov@intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>

On Tue, Jul 03, 2012 at 11:59:51AM +0100, Mel Gorman wrote:
> On Tue, Jul 03, 2012 at 10:19:28AM +1000, Dave Chinner wrote:
> > On Mon, Jul 02, 2012 at 08:35:16PM +0100, Mel Gorman wrote:
> > > Adding dri-devel and a few others because an i915 patch contributed to
> > > the regression.
> > > 
> > > On Mon, Jul 02, 2012 at 03:32:15PM +0100, Mel Gorman wrote:
> > > > On Mon, Jul 02, 2012 at 02:32:26AM -0400, Christoph Hellwig wrote:
> > > > > > It increases the CPU overhead (dirty_inode can be called up to 4
> > > > > > times per write(2) call, IIRC), so with limited numbers of
> > > > > > threads/limited CPU power it will result in lower performance. Where
> > > > > > you have lots of CPU power, there will be little difference in
> > > > > > performance...
> > > > > 
> > > > > When I checked it it could only be called twice, and we'd already
> > > > > optimize away the second call.  I'd defintively like to track down where
> > > > > the performance changes happend, at least to a major version but even
> > > > > better to a -rc or git commit.
> > > > > 
> > > > 
> > > > By all means feel free to run the test yourself and run the bisection :)
> > > > 
> > > > It's rare but on this occasion the test machine is idle so I started an
> > > > automated git bisection. As you know the milage with an automated bisect
> > > > varies so it may or may not find the right commit. Test machine is sandy so
> > > > http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-xfs/sandy/comparison.html
> > > > is the report of interest. The script is doing a full search between v3.3 and
> > > > v3.4 for a point where average files/sec for fsmark-single drops below 25000.
> > > > I did not limit the search to fs/xfs on the off-chance that it is an
> > > > apparently unrelated patch that caused the problem.
> > > > 
> > > 
> > > It was obvious very quickly that there were two distinct regression so I
> > > ran two bisections. One led to a XFS and the other led to an i915 patch
> > > that enables RC6 to reduce power usage.
> > > 
> > > [aa464191: drm/i915: enable plain RC6 on Sandy Bridge by default]
> > 
> > Doesn't seem to be the major cause of the regression. By itself, it
> > has impact, but the majority comes from the XFS change...
> > 
> 
> The fact it has an impact at all is weird but lets see what the DRI
> folks think about it.
> 
> > > [c999a223: xfs: introduce an allocation workqueue]
> > 
> > Which indicates that there is workqueue scheduling issues, I think.
> > The same amount of work is being done, but half of it is being
> > pushed off into a workqueue to avoid stack overflow issues (*).  I
> > tested the above patch in anger on an 8p machine, similar to the
> > machine you saw no regressions on, but the workload didn't drive it
> > to being completely CPU bound (only about 90%) so the allocation
> > work was probably always scheduled quickly.
> 
> What test were you using?

fsmark, dbench, compilebench, and a few fio workloads. Also,
xfstests times each test and I keep track of overall runtime, and
none of those showed any performance differential, either...

Indeed, running on a current 3.5-rc5 tree, my usual fsmark
benchmarks are running at the same numbers I've been seeing since
about 3.0 - somewhere around 18k files/s for a single thread, and
110-115k files/s for 8 threads.

I just ran your variant, and I'm getting about 20kfile/s for a
single thread, which is about right because you're using smaller
directories than I am (22500 files per dir vs 100k in my tests).

> > How many worker threads have been spawned on these machines
> > that are showing the regression?
> 
> 20 or 21 generally. An example list as spotted by top looks like

Pretty normal.

> > What is the context switch rate on the machines whenteh test is running?
.....
> Vanilla average context switch rate	4278.53
> Revert average context switch rate	1095

That seems about right, too.

> > Can you run latencytop to see
> > if there is excessive starvation/wait times for allocation
> > completion?
> 
> I'm not sure what format you are looking for.

Where the context switches are coming from, and how long they are
abeing stalled for. Just to get the context switch locations, you
can use perf on the sched:sched_switch event, but that doesn't give
you stall times. Local testing tells me that about 40% of the
switches are from xfs_alloc_vextent, 55% are from the work threads,
and the rest are CPU idling events, which is exactly as I'd expect.

> > A pert top profile comparison might be informative,
> > too...
> > 
> 
> I'm not sure if this is what you really wanted. I thought an oprofile or
> perf report would have made more sense but I recorded perf top over time
> anyway and it's at the end of the mail.

perf report and oprofile give you CPU usage across the run, it's not
instantaneous and that's where all the interesting information is.
e.g. a 5% sample in a 20s profile might be 5% per second for 20s, or
it might be 100% for 1s - that's the behaviour run profiles cannot
give you insight into....

As it is, the output you posted is nothing unusual.

> For just these XFS tests I've uploaded a tarball of the logs to
> http://www.csn.ul.ie/~mel/postings/xfsbisect-20120703/xfsbisect-logs.tar.gz

Ok, so the main thing I missed when first looking at this is that
you are concerned about single thread regressions. Well, I can't
reproduce your results here. Single threaded with or without the
workqueue based allocation gives me roughly 20k +/-0.5k files/s one
a single disk, a 12 disk RAID0 array and a RAM disk on a 8p/4GB RAM
machine.  That's the same results I've been seeing since I wrote
this patch almost 12 months ago....

So, given that this is a metadata intensive workload, the only
extent allocation is going to be through inode and directory block
allocation. These paths do not consume a large amount of stack, so
we can tell the allocator not to switch to workqueue stack for these
allocations easily.

The patch below does this. It completely removes all the allocation
based context switches from the no-data fsmark workloads being used
for this testing. It makes no noticable difference to performance
here, so I'm interested if it solves the regression you are seeing
on your machines.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


xfs: don't defer metadata allocation to the workqueue

From: Dave Chinner <dchinner@redhat.com>

Almost all metadata allocations come from shallow stack usage
situations. Avoid the overhead of switching the allocation to a
workqueue as we are not in danger of running out of stack when
making these allocations. Metadata allocations are already marked
through the args that are passed down, so this is trivial to do.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_alloc.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/xfs/xfs_alloc.c b/fs/xfs/xfs_alloc.c
index f654f51..4f33c32 100644
--- a/fs/xfs/xfs_alloc.c
+++ b/fs/xfs/xfs_alloc.c
@@ -2434,13 +2434,22 @@ xfs_alloc_vextent_worker(
 	current_restore_flags_nested(&pflags, PF_FSTRANS);
 }
 
-
-int				/* error */
+/*
+ * Data allocation requests often come in with little stack to work on. Push
+ * them off to a worker thread so there is lots of stack to use. Metadata
+ * requests, OTOH, are generally from low stack usage paths, so avoid the
+ * context switch overhead here.
+ */
+int
 xfs_alloc_vextent(
-	xfs_alloc_arg_t	*args)	/* allocation argument structure */
+	struct xfs_alloc_arg	*args)
 {
 	DECLARE_COMPLETION_ONSTACK(done);
 
+	if (!args->userdata)
+		return __xfs_alloc_vextent(args);
+
+
 	args->done = &done;
 	INIT_WORK_ONSTACK(&args->work, xfs_alloc_vextent_worker);
 	queue_work(xfs_alloc_wq, &args->work);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
