Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 2A6B56B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 20:19:34 -0400 (EDT)
Date: Tue, 3 Jul 2012 10:19:28 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [MMTests] IO metadata on XFS
Message-ID: <20120703001928.GV19223@dastard>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de>
 <20120701235458.GM19223@dastard>
 <20120702063226.GA32151@infradead.org>
 <20120702143215.GS14154@suse.de>
 <20120702193516.GX14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120702193516.GX14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, dri-devel@lists.freedesktop.org, Keith Packard <keithp@keithp.com>, Eugeni Dodonov <eugeni.dodonov@intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>

On Mon, Jul 02, 2012 at 08:35:16PM +0100, Mel Gorman wrote:
> Adding dri-devel and a few others because an i915 patch contributed to
> the regression.
> 
> On Mon, Jul 02, 2012 at 03:32:15PM +0100, Mel Gorman wrote:
> > On Mon, Jul 02, 2012 at 02:32:26AM -0400, Christoph Hellwig wrote:
> > > > It increases the CPU overhead (dirty_inode can be called up to 4
> > > > times per write(2) call, IIRC), so with limited numbers of
> > > > threads/limited CPU power it will result in lower performance. Where
> > > > you have lots of CPU power, there will be little difference in
> > > > performance...
> > > 
> > > When I checked it it could only be called twice, and we'd already
> > > optimize away the second call.  I'd defintively like to track down where
> > > the performance changes happend, at least to a major version but even
> > > better to a -rc or git commit.
> > > 
> > 
> > By all means feel free to run the test yourself and run the bisection :)
> > 
> > It's rare but on this occasion the test machine is idle so I started an
> > automated git bisection. As you know the milage with an automated bisect
> > varies so it may or may not find the right commit. Test machine is sandy so
> > http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-xfs/sandy/comparison.html
> > is the report of interest. The script is doing a full search between v3.3 and
> > v3.4 for a point where average files/sec for fsmark-single drops below 25000.
> > I did not limit the search to fs/xfs on the off-chance that it is an
> > apparently unrelated patch that caused the problem.
> > 
> 
> It was obvious very quickly that there were two distinct regression so I
> ran two bisections. One led to a XFS and the other led to an i915 patch
> that enables RC6 to reduce power usage.
> 
> [aa464191: drm/i915: enable plain RC6 on Sandy Bridge by default]

Doesn't seem to be the major cause of the regression. By itself, it
has impact, but the majority comes from the XFS change...

> [c999a223: xfs: introduce an allocation workqueue]

Which indicates that there is workqueue scheduling issues, I think.
The same amount of work is being done, but half of it is being
pushed off into a workqueue to avoid stack overflow issues (*).  I
tested the above patch in anger on an 8p machine, similar to the
machine you saw no regressions on, but the workload didn't drive it
to being completely CPU bound (only about 90%) so the allocation
work was probably always scheduled quickly.

How many worker threads have been spawned on these machines
that are showing the regression? What is the context switch rate on
the machines whenteh test is running? Can you run latencytop to see
if there is excessive starvation/wait times for allocation
completion? A pert top profile comparison might be informative,
too...

(*) The stack usage below submit_bio() can be more than 5k (DM, MD,
SCSI, driver, memory allocation), so it's really not safe to do
allocation anywhere below about 3k of kernel stack being used. e.g.
on a relatively trivial storage setup without the above commit:

[142296.384921] flush-253:4 used greatest stack depth: 360 bytes left

Fundamentally, 8k stacks on x86-64 are too small for our
increasingly complex storage layers and the 100+ function deep call
chains that occur.

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
