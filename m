Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8E96D6B0082
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 07:52:26 -0400 (EDT)
Date: Thu, 14 Jul 2011 21:52:21 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/5] mm: vmscan: Do not writeback filesystem pages in
 kswapd except in high priority
Message-ID: <20110714115220.GB21663@dastard>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-3-git-send-email-mgorman@suse.de>
 <20110713233743.GV23038@dastard>
 <20110714062947.GO7529@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714062947.GO7529@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 14, 2011 at 07:29:47AM +0100, Mel Gorman wrote:
> On Thu, Jul 14, 2011 at 09:37:43AM +1000, Dave Chinner wrote:
> > On Wed, Jul 13, 2011 at 03:31:24PM +0100, Mel Gorman wrote:
> > > It is preferable that no dirty pages are dispatched for cleaning from
> > > the page reclaim path. At normal priorities, this patch prevents kswapd
> > > writing pages.
> > > 
> > > However, page reclaim does have a requirement that pages be freed
> > > in a particular zone. If it is failing to make sufficient progress
> > > (reclaiming < SWAP_CLUSTER_MAX at any priority priority), the priority
> > > is raised to scan more pages. A priority of DEF_PRIORITY - 3 is
> > > considered to tbe the point where kswapd is getting into trouble
> > > reclaiming pages. If this priority is reached, kswapd will dispatch
> > > pages for writing.
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > 
> > Seems reasonable, but btrfs still will ignore this writeback from
> > kswapd, and it doesn't fall over.
> 
> At least there are no reports of it falling over :)

However you want to spin it.

> > Given that data point, I'd like to
> > see the results when you stop kswapd from doing writeback altogether
> > as well.
> > 
> 
> The results for this test will be identical because the ftrace results
> show that kswapd is already writing 0 filesystem pages.

You mean these numbers:

Kswapd reclaim write file async I/O           4483       4286 0          1          0          0

Which shows that kswapd, under this workload has been improved to
the point that it doesn't need to do IO. Yes, you've addressed the
one problematic workload, but the numbers do not provide the answers
to the fundamental question that have been raised during
discussions. i.e. do we even need IO at all from reclaim?

> Where it makes a difference is when the system is under enough
> pressure that it is failing to reclaim any memory and is in danger
> of prematurely triggering the OOM killer. Andrea outlined some of
> the concerns before at http://lkml.org/lkml/2010/6/15/246

So put the system under more pressure such that with this patch
series memory reclaim still writes from kswapd. Can you even get it
to that stage, and if you can, does the system OOM more or less if
you don't do file IO from reclaim?

> > Can you try removing it altogether and seeing what that does to your
> > test results? i.e
> > 
> > 			if (page_is_file_cache(page)) {
> > 				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
> > 				goto keep_locked;
> > 			}
> 
> It won't do anything, it'll still be writing 0 filesystem-backed pages.
> 
> Because of the possibility for the OOM killer triggering prematurely due
> to the inability of kswapd to write pages, I'd prefer to separate such a
> change by at least one release so that if there is an increase in OOM
> reports, it'll be obvious what was the culprit.

I'm not asking for release quality patches or even when such fixes
would roll out.

What you've shown here is that memory reclaim can be more efficient
without issuing IO itself under medium memory pressure. Now the
question is whether it can do so under heavy, sustained, near OOM
memory pressure?

IOWs, what I want to see is whether the fundamental principle of
IO-less reclaim can be validated as workable or struck down.  This
patchset demonstrates that IO-less reclaim is superior for a
workload that produces medium levels of sustained IO-based memory
pressure, which leads to the conclusion that the approach has merit
and needs further investigation.

It's that next step that I'm asking you to test now. What form
potential changes take or when they are released is irrelevant to me
at this point, because we still haven't determined if the
fundamental concept is completely sound or not. If the concept is
sound I'm quite happy to wait until the implementation is fully
baked before it gets rolled out....

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
