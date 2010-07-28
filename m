Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8434B6B02A3
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 00:59:40 -0400 (EDT)
Received: from dastard (unverified [121.44.18.238])
	by mail.internode.on.net (SurgeMail 3.8f2) with ESMTP id 32933026-1927428
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 14:29:36 +0930 (CST)
Date: Wed, 28 Jul 2010 14:59:24 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: VFS scalability git tree
Message-ID: <20100728045924.GF655@dastard>
References: <20100722190100.GA22269@amd>
 <20100723135514.GJ32635@dastard>
 <20100727070538.GA2893@amd>
 <20100727131810.GO7362@dastard>
 <20100727150908.GA3749@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100727150908.GA3749@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 01:09:08AM +1000, Nick Piggin wrote:
> On Tue, Jul 27, 2010 at 11:18:10PM +1000, Dave Chinner wrote:
> > On Tue, Jul 27, 2010 at 05:05:39PM +1000, Nick Piggin wrote:
> > > On Fri, Jul 23, 2010 at 11:55:14PM +1000, Dave Chinner wrote:
> > solve. The difficulty (as always) is in reliably reproducing the bad
> > behaviour.
> 
> Sure, and I didn't see any corruptions, it seems pretty stable and
> scalability is better than other filesystems. I'll see if I can
> give a better recipe to reproduce the 'livelock'ish behaviour.

Well, stable is a good start :)

> > > > 	fs_mark rate (thousands of files/second)
> > > >            2.6.35-rc5   2.6.35-rc5-scale
> > > > threads    xfs   ext4     xfs    ext4
> > > >   1         20    39       20     39
> > > >   2         35    55       35     57
> > > >   4         60    41       57     42
> > > >   8         79     9       75      9
> > > > 
> > > > ext4 is getting IO bound at more than 2 threads, so apart from
> > > > pointing out that XFS is 8-9x faster than ext4 at 8 thread, I'm
> > > > going to ignore ext4 for the purposes of testing scalability here.
> > > > 
> > > > For XFS w/ delayed logging, 2.6.35-rc5 is only getting to about 600%
> > > > CPU and with Nick's patches it's about 650% (10% higher) for
> > > > slightly lower throughput.  So at this class of machine for this
> > > > workload, the changes result in a slight reduction in scalability.
> > > 
> > > I wonder if these results are stable. It's possible that changes in
> > > reclaim behaviour are causing my patches to require more IO for a
> > > given unit of work?
> > 
> > More likely that's the result of using a smaller log size because it
> > will require more frequent metadata pushes to make space for new
> > transactions.
> 
> I was just checking whether your numbers are stable (where you
> saw some slowdown with vfs-scale patches), and what could be the
> cause. I agree that running real disks could make big changes in
> behaviour.

Yeah, the numbers are repeatable within about +/-5%. I generally
don't bother with optimisations that result in gains/losses less
than that because IO benchmarks that reliably repoduce results with
more precise repeatability than that are few and far between.

> > FWIW, I use PCP monitoring graphs to correlate behavioural changes
> > across different subsystems because it is far easier to relate
> > information visually than it is by looking at raw numbers or traces.
> > I think this graph shows the effect of relcaim on performance
> > most clearly:
> > 
> > http://userweb.kernel.org/~dgc/shrinker-2.6.36/fs_mark-2.6.35-rc3-context-only-per-xfs-batch6-16x500-xfs.png
> 
> I haven't actually used that, it looks interesting.

The archiving side of PCP is the most useful, I find. i.e. being able
to record the metrics into a file and  analyse them with pmchart or
other tools after the fact...

> > That is by far the largest improvement I've been able to obtain from
> > modifying the shrinker code, and it is from those sorts of
> > observations that I think that IO being issued from reclaim is
> > currently the most significant performance limiting factor for XFS
> > in this sort of workload....
> 
> How is the xfs inode reclaim tied to linux inode reclaim? Does the
> xfs inode not become reclaimable until some time after the linux inode
> is reclaimed? Or what?

The struct xfs_inode embeds a struct inode like so:

struct xfs_inode {
	.....
	struct inode	i_inode;
}

so they are the same chunk of memory. XFS does not use the VFS inode
hashes for finding inodes - that's what the per-ag radix trees are
used for. The xfs_inode lives longer than the struct inode because
we do non-trivial work after the VFS "reclaims" the struct inode.

For example, when an inode is unlinked
do not truncate or free the inode until after the VFS has finished with
it - the inode remains on the unlinked list (orphaned in ext3 terms)
from the time is is unlinked by the VFS to the time the last VFs
reference goes away. When XFS gets it, XFS then issues the inactive
transaction that takes the inode off the unlinked list and marks it
free in the inode alloc btree. This transaction is asynchronous and
dirties the xfs inode. Finally XFS will mark the inode as
reclaimable via a radix tree tag. The final processing of the inode
is then done via eaither a background relcaim walk from xfssyncd
(every 30s) where it will do non-blocking operations to finalN?ze
reclaim. It may take several passes to actually reclaim the inode.
e.g. one pass to force the log if the inode is pinned, another pass
to flush the inode to disk if it is dirty and not stale, and then
another pass to reclaim the inode once clean. There may be multiple
passes inbetween where the inode is skipped because those operations
have not completed.

And to top it all off, if the inode is looked up again (cache hit)
while in the reclaimable state, it will be removed from the reclaim
state and reused immediately. in this case we don't need to continue
the reclaim processing other things will ensure all the correct
information will go to disk.

> Do all or most of the xfs inodes require IO before being reclaimed
> during this test?

Yes, because all the inode are being dirtied and they are being
reclaimed faster than background flushing expires them.

> I wonder if you could throttle them a bit or sort
> them somehow so that they tend to be cleaned by writeout and reclaim
> just comes after and removes the clean ones, like pagecache reclaim
> is (supposed) to work.?

The whole point of using the radix trees is to get nicely sorted
reclaim IO - inodes are indexed by number, and the radix tree walk
gives us ascending inode number (and hence ascending block number)
reclaim - and the background reclaim allows optimal flushing to
occur by aggregating all the IO into delayed write metadata buffers
so they can be sorted and flushed to the elevator by the xfsbufd in
the most optimal manner possible.

The shrinker does preempt this somewhat, which is why delaying the
XFS shrinker's work appears to improve things alot. If the shrinker
is not running, the the background reclaim does exactly what you are
suggesting.

However, I don't think the increase in iops is caused by the XFS
inode shrinker - I think that it is the VFS cache shrinkers. If you
look at the the graphs in the link above, preformance doesn't
decrease when the XFS inode cache is being shrunk (top chart, yellow
trace) - it drops when the vfs caches are being shrunk (middle
chart). I haven't correlated the behaviour any further than that
because I haven't had time.

FWIW, all this background reclaim, radix tree reclaim tagging and
walking, embedded struct inodes, etc is all relatively new code.
The oldest bit of it was introduced in 2.6.31 (I think) and so a
significant part of what we are exploring here is uncharted
territory. The changes to relcaim, etc are aprtially reponsible for
the scalabilty we are geting from delayed logging, but there is
certainly room for improvement....

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
