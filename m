Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFD356B02E5
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 21:32:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q186so146493pga.23
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 18:32:24 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id u5si26029pgp.237.2018.01.02.18.32.21
        for <linux-mm@kvack.org>;
        Tue, 02 Jan 2018 18:32:23 -0800 (PST)
Date: Wed, 3 Jan 2018 13:32:19 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 06/10] writeback: introduce
 super_operations->write_metadata
Message-ID: <20180103023219.GC30682@dastard>
References: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
 <1513029335-5112-7-git-send-email-josef@toxicpanda.com>
 <20171211233619.GQ4094@dastard>
 <20171212180534.c5f7luqz5oyfe7c3@destiny>
 <20171212222004.GT4094@dastard>
 <20171219120709.GE2277@quack2.suse.cz>
 <20171219213505.GN5858@dastard>
 <20171220143055.GA31584@quack2.suse.cz>
 <20180102161305.6r6qvz5bfixbn3dv@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180102161305.6r6qvz5bfixbn3dv@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Jan Kara <jack@suse.cz>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, Jan 02, 2018 at 11:13:06AM -0500, Josef Bacik wrote:
> On Wed, Dec 20, 2017 at 03:30:55PM +0100, Jan Kara wrote:
> > On Wed 20-12-17 08:35:05, Dave Chinner wrote:
> > > On Tue, Dec 19, 2017 at 01:07:09PM +0100, Jan Kara wrote:
> > > > On Wed 13-12-17 09:20:04, Dave Chinner wrote:
> > > > > IOWs, treating metadata like it's one great big data inode doesn't
> > > > > seem to me to be the right abstraction to use for this - in most
> > > > > fileystems it's a bunch of objects with a complex dependency tree
> > > > > and unknown write ordering, not an inode full of data that can be
> > > > > sequentially written.
> > > > > 
> > > > > Maybe we need multiple ops with well defined behaviours. e.g.
> > > > > ->writeback_metadata() for background writeback, ->sync_metadata() for
> > > > > sync based operations. That way different filesystems can ignore the
> > > > > parts they don't need simply by not implementing those operations,
> > > > > and the writeback code doesn't need to try to cater for all
> > > > > operations through the one op. The writeback code should be cleaner,
> > > > > the filesystem code should be cleaner, and we can tailor the work
> > > > > guidelines for each operation separately so there's less mismatch
> > > > > between what writeback is asking and how filesystems track dirty
> > > > > metadata...
> > > > 
> > > > I agree that writeback for memory cleaning and writeback for data integrity
> > > > are two very different things especially for metadata. In fact for data
> > > > integrity writeback we already have ->sync_fs operation so there the
> > > > functionality gets duplicated. What we could do is that in
> > > > writeback_sb_inodes() we'd call ->write_metadata only when
> > > > work->for_kupdate or work->for_background is set. That way ->write_metadata
> > > > would be called only for memory cleaning purposes.
> > > 
> > > That makes sense, but I still think we need a better indication of
> > > how much writeback we need to do than just "writeback this chunk of
> > > pages". That "writeback a chunk" interface is necessary to share
> > > writeback bandwidth across numerous data inodes so that we don't
> > > starve any one inode of writeback bandwidth. That's unnecessary for
> > > metadata writeback on a superblock - we don't need to share that
> > > bandwidth around hundreds or thousands of inodes. What we actually
> > > need to know is how much writeback we need to do as a total of all
> > > the dirty metadata on the superblock.
> > > 
> > > Sure, that's not ideal for btrfs and mayext4, but we can write a
> > > simple generic helper that converts "flush X percent of dirty
> > > metadata" to a page/byte chunk as the current code does. DOing it
> > > this way allows filesystems to completely internalise the accounting
> > > that needs to be done, rather than trying to hack around a
> > > writeback accounting interface with large impedance mismatches to
> > > how the filesystem accounts for dirty metadata and/or tracks
> > > writeback progress.
> > 
> > Let me think loud on how we could tie this into how memory cleaning
> > writeback currently works - the one with for_background == 1 which is
> > generally used to get amount of dirty pages in the system under control.
> > We have a queue of inodes to write, we iterate over this queue and ask each
> > inode to write some amount (e.g. 64 M - exact amount depends on measured

It's a maximum of 1024 pages per inode.

> > writeback bandwidth etc.). Some amount from that inode gets written and we
> > continue with the next inode in the queue (put this one at the end of the
> > queue if it still has dirty pages). We do this until:
> > 
> > a) the number of dirty pages in the system is below background dirty limit
> >    and the number dirty pages for this device is below background dirty
> >    limit for this device.
> > b) run out of dirty inodes on this device
> > c) someone queues different type of writeback
> > 
> > And we need to somehow incorporate metadata writeback into this loop. I see
> > two questions here:
> > 
> > 1) When / how often should we ask for metadata writeback?
> > 2) How much to ask to write in one go?
> > 
> > The second question is especially tricky in the presence of completely
> > async metadata flushing in XFS - we can ask to write say half of dirty
> > metadata but then we have no idea whether the next observation of dirty
> > metadata counters is with that part of metadata already under writeback /
> > cleaned or whether xfsaild didn't even start working and pushing more has
> > no sense.

Well, like with ext4, we've also got to consider that a bunch of the
recently dirtied metadata (e.g. from delalloc, EOF updates on IO
completion, etc) is still pinned in memory because the
journal has not been flushed/checkpointed. Hence we should not be
attempting to write back metadata we've dirtied as a result of
writing data in the background writeback loop.

That greatly simplifies what we need to consider here. That is, we
just need to sample the ratio of dirty metadata to clean metadata
before we start data writeback, and we calculate the amount of
metadata writeback we should trigger from there. We only need to
do this *once* per background writeback scan for a superblock
as there is no need for sharing bandwidth between lots of data
inodes - there's only one metadata inode for ext4/btrfs, and XFS is
completely async....

> > Partly, this could be dealt with by telling the filesystem
> > "metadata dirty target" - i.e. "get your dirty metadata counters below X"
> > - and whether we communicate that in bytes, pages, or a fraction of
> > current dirty metadata counter value is a detail I don't have a strong
> > opinion on now. And the fact is the amount written by the filesystem
> > doesn't have to be very accurate anyway - we basically just want to make
> > some forward progress with writing metadata, don't want that to take too
> > long (so that other writeback from the thread isn't stalled), and if
> > writeback code is unhappy about the state of counters next time it looks,
> > it will ask the filesystem again...

Right. The problem is communicating "how much" to the filesystem in
a useful manner....

> > This gets me directly to another problem with async nature of XFS metadata
> > writeback. That is that it could get writeback thread into busyloop - we
> > are supposed to terminate memory cleaning writeback only once dirty
> > counters are below limit and in case dirty metadata is causing counters to
> > be over limit, we would just ask in a loop XFS to get metadata below the
> > target. I suppose XFS could just return "nothing written" from its
> > ->write_metadata operation and in such case we could sleep a bit before
> > going for another writeback loop (the same thing happens when filesystem
> > reports all inodes are locked / busy and it cannot writeback anything). But
> > it's getting a bit ugly and is it really better than somehow waiting inside
> > XFS for metadata writeback to occur?  Any idea Dave?

I tend to think that the whole point of background writeback is to
do it asynchronously and keep the IO pipe full by avoiding blocking
on any specific object. i.e. if we can't do writeback from this
object, then skip it and do it from the next....

I think we could probably block ->write_metadata if necessary via a
completion/wakeup style notification when a specific LSN is reached
by the log tail, but realistically if there's any amount of data
needing to be written it'll throttle data writes because the IO
pipeline is being kept full by background metadata writes....

> > Regarding question 1). What Josef does is that once we went through all
> > queued inodes and wrote some amount from each one, we'd go and ask fs to
> > write some metadata. And then we'll again go to write inodes that are still
> > dirty. That is somewhat rough but I guess it is fine for now.
> > 
> 
> Alright I'm back from vacation so am sufficiently hungover to try and figure
> this out.  Btrfs and ext4 account their dirty metadata directly and reclaim it
> like inodes, xfs doesn't.

Terminology: "reclaim" is not what we do when accounting for
writeback IO completion.

And we've already been through the accounting side of things - we
can add that to XFS once it's converted to byte-based accounting.

> Btrfs does do something similar to what xfs does with
> delayed updates, but we just use the enospc logic to trigger when to update the
> metadata blocks, and then those just get written out via the dirty balancing
> stuff.  Since xfs doesn't have a direct way to tie that together, you'd rather
> we'd have some sort of ratio so you know you need to flush dirty inodes, correct
> Dave?

Again, terminology: We don't "need to flush dirty inodes" in XFS,
we need to flush /metadata objects/.

> I don't think this is solvable for xfs.  The whole vm is around pages/bytes.
> The only place we have this ratio thing is in slab reclaim, and we only have to
> worry about actual memory pressure there because we have a nice external
> trigger, we're out of pages.

WE don't need all of the complexity of slab reclaim, though. That's
a complete red herring.

All that is needed is for the writeback API to tell us "flush X% of
your dirty metadata".  We will have cached data and metadata in
bytes and dirty cached data and metadata in bytes at the generic
writeback level - it's not at all difficult to turn that into a
flush ratio. e.g. take the amount we are over the dirty metadata
background threshold, request writeback for that amount of metadata
as a percentage of the overall dirty metadata.

> For dirty throttling we have to know how much we're pushing and how much we need
> to push, and that _requires_ bytes/pages.

Dirty throttling does not need to know how much work you've asked
the filesystem to do. It does it's own accounting of bytes/pages
being cleaned based on the accounting updates from the filesystem
metadata object IO completion routines. That is what needs to be in
bytes/pages for dirty throttling to work.

> And not like "we can only send you
> bytes/pages to reclaim" but like the throttling stuff has all of it's accounting
> in bytes/pages, so putting in arbitrary object counts into this logic is not
> going to be straightforward.  The system administrator sets their dirty limits
> to absolute numbers or % of total memory.  If xfs can't account for its metadata
> this way then I don't think it can use any sort of infrastructure we provide in
> the current framework.

XFS will account for clean/dirty metadata in bytes, just like btrfs
and ext4 will do. We've already been over this and *solved that
problem*.

But really, though, I'm fed up with having to fight time and time
again over simple changes to core infrastructure that make it
generic rather than specifically tailored to the filesystem that
wants it first.  Merge whatever crap you need for btrfs and I'll
make it work for XFS later and leave what gets fed to btrfs
completely unchanged.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
