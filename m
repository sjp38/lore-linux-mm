Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 52AB46B035B
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 10:49:37 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d71so1023562qkj.19
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 07:49:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l23sor857816qtj.20.2018.01.03.07.49.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 07:49:35 -0800 (PST)
Date: Wed, 3 Jan 2018 10:49:33 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v3 06/10] writeback: introduce
 super_operations->write_metadata
Message-ID: <20180103154932.yarbs5ondletaoof@destiny>
References: <1513029335-5112-7-git-send-email-josef@toxicpanda.com>
 <20171211233619.GQ4094@dastard>
 <20171212180534.c5f7luqz5oyfe7c3@destiny>
 <20171212222004.GT4094@dastard>
 <20171219120709.GE2277@quack2.suse.cz>
 <20171219213505.GN5858@dastard>
 <20171220143055.GA31584@quack2.suse.cz>
 <20180102161305.6r6qvz5bfixbn3dv@destiny>
 <20180103023219.GC30682@dastard>
 <20180103135921.GF4911@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180103135921.GF4911@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed, Jan 03, 2018 at 02:59:21PM +0100, Jan Kara wrote:
> On Wed 03-01-18 13:32:19, Dave Chinner wrote:
> > On Tue, Jan 02, 2018 at 11:13:06AM -0500, Josef Bacik wrote:
> > > On Wed, Dec 20, 2017 at 03:30:55PM +0100, Jan Kara wrote:
> > > > On Wed 20-12-17 08:35:05, Dave Chinner wrote:
> > > > > On Tue, Dec 19, 2017 at 01:07:09PM +0100, Jan Kara wrote:
> > > > > > On Wed 13-12-17 09:20:04, Dave Chinner wrote:
> > > > > > > IOWs, treating metadata like it's one great big data inode doesn't
> > > > > > > seem to me to be the right abstraction to use for this - in most
> > > > > > > fileystems it's a bunch of objects with a complex dependency tree
> > > > > > > and unknown write ordering, not an inode full of data that can be
> > > > > > > sequentially written.
> > > > > > > 
> > > > > > > Maybe we need multiple ops with well defined behaviours. e.g.
> > > > > > > ->writeback_metadata() for background writeback, ->sync_metadata() for
> > > > > > > sync based operations. That way different filesystems can ignore the
> > > > > > > parts they don't need simply by not implementing those operations,
> > > > > > > and the writeback code doesn't need to try to cater for all
> > > > > > > operations through the one op. The writeback code should be cleaner,
> > > > > > > the filesystem code should be cleaner, and we can tailor the work
> > > > > > > guidelines for each operation separately so there's less mismatch
> > > > > > > between what writeback is asking and how filesystems track dirty
> > > > > > > metadata...
> > > > > > 
> > > > > > I agree that writeback for memory cleaning and writeback for data integrity
> > > > > > are two very different things especially for metadata. In fact for data
> > > > > > integrity writeback we already have ->sync_fs operation so there the
> > > > > > functionality gets duplicated. What we could do is that in
> > > > > > writeback_sb_inodes() we'd call ->write_metadata only when
> > > > > > work->for_kupdate or work->for_background is set. That way ->write_metadata
> > > > > > would be called only for memory cleaning purposes.
> > > > > 
> > > > > That makes sense, but I still think we need a better indication of
> > > > > how much writeback we need to do than just "writeback this chunk of
> > > > > pages". That "writeback a chunk" interface is necessary to share
> > > > > writeback bandwidth across numerous data inodes so that we don't
> > > > > starve any one inode of writeback bandwidth. That's unnecessary for
> > > > > metadata writeback on a superblock - we don't need to share that
> > > > > bandwidth around hundreds or thousands of inodes. What we actually
> > > > > need to know is how much writeback we need to do as a total of all
> > > > > the dirty metadata on the superblock.
> > > > > 
> > > > > Sure, that's not ideal for btrfs and mayext4, but we can write a
> > > > > simple generic helper that converts "flush X percent of dirty
> > > > > metadata" to a page/byte chunk as the current code does. DOing it
> > > > > this way allows filesystems to completely internalise the accounting
> > > > > that needs to be done, rather than trying to hack around a
> > > > > writeback accounting interface with large impedance mismatches to
> > > > > how the filesystem accounts for dirty metadata and/or tracks
> > > > > writeback progress.
> > > > 
> > > > Let me think loud on how we could tie this into how memory cleaning
> > > > writeback currently works - the one with for_background == 1 which is
> > > > generally used to get amount of dirty pages in the system under control.
> > > > We have a queue of inodes to write, we iterate over this queue and ask each
> > > > inode to write some amount (e.g. 64 M - exact amount depends on measured
> > 
> > It's a maximum of 1024 pages per inode.
> 
> That's actually a minimum, not maximum, if I read the code in
> writeback_chunk_size() right.
> 
> > > > writeback bandwidth etc.). Some amount from that inode gets written and we
> > > > continue with the next inode in the queue (put this one at the end of the
> > > > queue if it still has dirty pages). We do this until:
> > > > 
> > > > a) the number of dirty pages in the system is below background dirty limit
> > > >    and the number dirty pages for this device is below background dirty
> > > >    limit for this device.
> > > > b) run out of dirty inodes on this device
> > > > c) someone queues different type of writeback
> > > > 
> > > > And we need to somehow incorporate metadata writeback into this loop. I see
> > > > two questions here:
> > > > 
> > > > 1) When / how often should we ask for metadata writeback?
> > > > 2) How much to ask to write in one go?
> > > > 
> > > > The second question is especially tricky in the presence of completely
> > > > async metadata flushing in XFS - we can ask to write say half of dirty
> > > > metadata but then we have no idea whether the next observation of dirty
> > > > metadata counters is with that part of metadata already under writeback /
> > > > cleaned or whether xfsaild didn't even start working and pushing more has
> > > > no sense.
> > 
> > Well, like with ext4, we've also got to consider that a bunch of the
> > recently dirtied metadata (e.g. from delalloc, EOF updates on IO
> > completion, etc) is still pinned in memory because the
> > journal has not been flushed/checkpointed. Hence we should not be
> > attempting to write back metadata we've dirtied as a result of
> > writing data in the background writeback loop.
> 
> Agreed. Actually for ext4 I would not expose 'pinned' buffers as dirty to
> VM - the journalling layer currently already works that way and it works
> well for us. But that's just a small technical detail and different
> filesystems can decide differently.
> 
> > That greatly simplifies what we need to consider here. That is, we
> > just need to sample the ratio of dirty metadata to clean metadata
> > before we start data writeback, and we calculate the amount of
> > metadata writeback we should trigger from there. We only need to
> > do this *once* per background writeback scan for a superblock
> > as there is no need for sharing bandwidth between lots of data
> > inodes - there's only one metadata inode for ext4/btrfs, and XFS is
> > completely async....
> 
> OK, agreed again.
> 
> > > > Partly, this could be dealt with by telling the filesystem
> > > > "metadata dirty target" - i.e. "get your dirty metadata counters below X"
> > > > - and whether we communicate that in bytes, pages, or a fraction of
> > > > current dirty metadata counter value is a detail I don't have a strong
> > > > opinion on now. And the fact is the amount written by the filesystem
> > > > doesn't have to be very accurate anyway - we basically just want to make
> > > > some forward progress with writing metadata, don't want that to take too
> > > > long (so that other writeback from the thread isn't stalled), and if
> > > > writeback code is unhappy about the state of counters next time it looks,
> > > > it will ask the filesystem again...
> > 
> > Right. The problem is communicating "how much" to the filesystem in
> > a useful manner....
> 
> Yep. I'm fine with communication in the form of 'write X% of your dirty
> metadata'. That should be useful for XFS and as you mentioned in some
> previous email, we can provide a helper function to compute number of pages
> to write (including some reasonable upper limit to bound time spent in one
> ->write_metadata invocation) for ext4 and btrfs.
> 
> > > > This gets me directly to another problem with async nature of XFS metadata
> > > > writeback. That is that it could get writeback thread into busyloop - we
> > > > are supposed to terminate memory cleaning writeback only once dirty
> > > > counters are below limit and in case dirty metadata is causing counters to
> > > > be over limit, we would just ask in a loop XFS to get metadata below the
> > > > target. I suppose XFS could just return "nothing written" from its
> > > > ->write_metadata operation and in such case we could sleep a bit before
> > > > going for another writeback loop (the same thing happens when filesystem
> > > > reports all inodes are locked / busy and it cannot writeback anything). But
> > > > it's getting a bit ugly and is it really better than somehow waiting inside
> > > > XFS for metadata writeback to occur?  Any idea Dave?
> > 
> > I tend to think that the whole point of background writeback is to
> > do it asynchronously and keep the IO pipe full by avoiding blocking
> > on any specific object. i.e. if we can't do writeback from this
> > object, then skip it and do it from the next....
> 
> Agreed.
> 
> > I think we could probably block ->write_metadata if necessary via a
> > completion/wakeup style notification when a specific LSN is reached
> > by the log tail, but realistically if there's any amount of data
> > needing to be written it'll throttle data writes because the IO
> > pipeline is being kept full by background metadata writes....
> 
> So the problem I'm concerned about is a corner case. Consider a situation
> when you have no dirty data, only dirty metadata but enough of them to
> trigger background writeback. How should metadata writeback behave for XFS
> in this case? Who should be responsible that wb_writeback() just does not
> loop invoking ->write_metadata() as fast as CPU allows until xfsaild makes
> enough progress?
> 
> Thinking about this today, I think this looping prevention belongs to
> wb_writeback(). Sadly we don't have much info to decide how long to sleep
> before trying more writeback so we'd have to just sleep for
> <some_magic_amount> if we found no writeback happened in the last writeback
> round before going through the whole writeback loop again. And
> ->write_metadata() for XFS would need to always return 0 (as in "no progress
> made") to make sure this busyloop avoidance logic in wb_writeback()
> triggers. ext4 and btrfs would return number of bytes written from
> ->write_metadata (or just 1 would be enough to indicate some progress in
> metadata writeback was made and busyloop avoidance is not needed).
> 
> So overall I think I have pretty clear idea on how this all should work to
> make ->write_metadata useful for btrfs, XFS, and ext4 and we agree on the
> plan.
> 

I'm glad you do, I'm still confused.  I'm totally fine with sending a % to the
fs to figure out what it wants, what I'm confused about is how to get that % for
xfs?  Since xfs doesn't mark its actual buffers dirty, so wouldn't use
account_metadata_dirtied and it's family, how do we generate this % for xfs?  Or
am I misunderstanding and you do plan to use those helpers?  If you do plan to
use them, then we just need to figure out what we want the ratio to be of, and
then you'll be happy Dave?  I'm not trying to argue with you Dave, we're just in
that "talking past each other" stage of every email conversation we've ever had,
I'm trying to get to the "we both understand what we're both saying and are
happy again" stage.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
