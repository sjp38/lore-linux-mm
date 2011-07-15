Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7D6C06B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 23:12:16 -0400 (EDT)
Date: Fri, 15 Jul 2011 13:12:10 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/5] mm: vmscan: Do not writeback filesystem pages in
 kswapd except in high priority
Message-ID: <20110715031210.GD21663@dastard>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-3-git-send-email-mgorman@suse.de>
 <20110713233743.GV23038@dastard>
 <20110714062947.GO7529@suse.de>
 <20110714115220.GB21663@dastard>
 <20110714131745.GU7529@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714131745.GU7529@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 14, 2011 at 02:17:45PM +0100, Mel Gorman wrote:
> On Thu, Jul 14, 2011 at 09:52:21PM +1000, Dave Chinner wrote:
> > On Thu, Jul 14, 2011 at 07:29:47AM +0100, Mel Gorman wrote:
> > > On Thu, Jul 14, 2011 at 09:37:43AM +1000, Dave Chinner wrote:
> > > > On Wed, Jul 13, 2011 at 03:31:24PM +0100, Mel Gorman wrote:
> > > > > It is preferable that no dirty pages are dispatched for cleaning from
> > > > > the page reclaim path. At normal priorities, this patch prevents kswapd
> > > > > writing pages.
> > > > > 
> > > > > However, page reclaim does have a requirement that pages be freed
> > > > > in a particular zone. If it is failing to make sufficient progress
> > > > > (reclaiming < SWAP_CLUSTER_MAX at any priority priority), the priority
> > > > > is raised to scan more pages. A priority of DEF_PRIORITY - 3 is
> > > > > considered to tbe the point where kswapd is getting into trouble
> > > > > reclaiming pages. If this priority is reached, kswapd will dispatch
> > > > > pages for writing.
> > > > > 
> > > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > > 
> > > > Seems reasonable, but btrfs still will ignore this writeback from
> > > > kswapd, and it doesn't fall over.
> > > 
> > > At least there are no reports of it falling over :)
> > 
> > However you want to spin it.
> 
> I regret that it is coming across as spin.

Shit, sorry, I didn't mean it that way. I forgot to add the smiley
at the end of that comment. It was meant in jest and not to be
derogatory - I do understand your concerns.

> > > > Given that data point, I'd like to
> > > > see the results when you stop kswapd from doing writeback altogether
> > > > as well.
> > > > 
> > > 
> > > The results for this test will be identical because the ftrace results
> > > show that kswapd is already writing 0 filesystem pages.
> > 
> > You mean these numbers:
> > 
> > Kswapd reclaim write file async I/O           4483       4286 0          1          0          0
> > 
> > Which shows that kswapd, under this workload has been improved to
> > the point that it doesn't need to do IO. Yes, you've addressed the
> > one problematic workload, but the numbers do not provide the answers
> > to the fundamental question that have been raised during
> > discussions. i.e. do we even need IO at all from reclaim?
> 
> I don't know and at best will only be able to test with a single
> disk which is why I wanted to separate this series from a complete
> preventing of kswapd writing pages. I may be able to get access to
> a machine with more disks but it'll take time.

That, to me, seems like a major problem, and explains why swapping
was affecting your results - you've got your test filesystem and
your swap partition on the same spindle. In the server admin world,
that's the first thing anyone concerned with performance avoids and
as such I tend to avoid doing that, too.

The lack of spindles/bandwidth used in testing the mm code is also
potentially another reason why XFS tends to show up mm problems.
That is, most testing and production use of XFS occurs on disk
subsystems much more bandwidth than a single spindle, and hence the
effects of bad IO show up much more obviously than for a single
spindle.

> > > Where it makes a difference is when the system is under enough
> > > pressure that it is failing to reclaim any memory and is in danger
> > > of prematurely triggering the OOM killer. Andrea outlined some of
> > > the concerns before at http://lkml.org/lkml/2010/6/15/246
> > 
> > So put the system under more pressure such that with this patch
> > series memory reclaim still writes from kswapd. Can you even get it
> > to that stage, and if you can, does the system OOM more or less if
> > you don't do file IO from reclaim?
> 
> I can setup such a tests, it'll be at least next week before I
> configure such a test and get it queued. It'll probably take a few
> days to run then because more iterations will be required to pinpoint
> where the OOM threshold is.  I know from the past that pushing a
> system near OOM causes a non-deterministic number of triggers that
> depend heavily on what was killed so the only real choice is to start
> light and increase the load until boom which is time consuming.
> 
> Even then, the test will be inconclusive because it'll be just one
> or two machines that I'll have to test on.

Which is why I have a bunch of test VMs with different
CPU/RAM/platform configs.  I regularly use 1p/1GB x86-64, 1p/2GB
i686 (to stress highmem), 2p/2GB, 8p/4GB and 8p/16GB x86-64 VMs. I
have a bunch of different disk images for the VMs to work off,
located on storage from shared single SATA spindles to a 16TB volume
to a short-stroked, 1GB/s, 5kiops, 12 disk dm RAID-0 setup.

I mix and match the VMs with the disk images all the time - this is
one of the benefits of using a virtualised test environment. One
slightly beefy piece of hardware that costs $10k can be used to test
many, many different configurations. That's why I complain about
corner cases all the time ;)

> There will be important
> corner cases that I won't be able to test for.  For example;
> 
>   o small lowest zone that is critical for operation of some reason and
>     the pages must be cleaned from there even though there is a large
>     amount of memory overall

That's the i686 highmem case, using a large amount of memory (e.g.
4GB or more) to make sure that the highmem zone is much larger than
the lowmem zone. inode caching uses low memory, so directory
intensive operations on large sets of files (e.g. 10 million)
tend to stress low memory availability.

>   o small highest zone causing high kswapd usage as it fails to balance
>     continually due to pages being dirtied constantly and the window
>     between when flushers clean the page and kswapd reclaim the page
>     being too big. I might be able to simulate this one but bugs of
>     this nature tend to be workload specific and affect some machines
>     worse than others

And that is also testable with i686 highmem, but simply use smaller
amounts of ram (say 1.5GB). Use page cache pressure to fill and
dirty highmem, and inode cache pressure to fill lowmem.

Guess what one of my ad hoc tests for XFS shrinker balancing is.  :)

>   o Machines with many nodes and dirty pages spread semi-randomly
>     on all nodes. If the flusher thread is not cleaning pages from
>     a particular node that is under memory pressure due to affinity,
>     processes will stall for long periods of time until the relevant
>     inodes expire and gets cleaned. This will be particularly
>     problematic if zone_reclaim is enabled

And you can create large node-count virtual machines via the kvm
-numa option. I haven't been doing this as yet because getting stuff
working well on single node SMP needs to be done first.

So, like you, I really only have one or two tests machine available
locally, but I've been creative in working around that
limitation.... :/

> > It's that next step that I'm asking you to test now. What form
> > potential changes take or when they are released is irrelevant to me
> > at this point, because we still haven't determined if the
> > fundamental concept is completely sound or not. If the concept is
> > sound I'm quite happy to wait until the implementation is fully
> > baked before it gets rolled out....
> 
> I'll setup a suitable test next week then.

Sounds great. Thanks Mel.

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
