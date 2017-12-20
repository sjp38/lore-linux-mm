Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D12D16B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 09:30:59 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id r20so12929297wrg.23
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 06:30:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e67si3077264wmd.231.2017.12.20.06.30.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 06:30:57 -0800 (PST)
Date: Wed, 20 Dec 2017 15:30:55 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 06/10] writeback: introduce
 super_operations->write_metadata
Message-ID: <20171220143055.GA31584@quack2.suse.cz>
References: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
 <1513029335-5112-7-git-send-email-josef@toxicpanda.com>
 <20171211233619.GQ4094@dastard>
 <20171212180534.c5f7luqz5oyfe7c3@destiny>
 <20171212222004.GT4094@dastard>
 <20171219120709.GE2277@quack2.suse.cz>
 <20171219213505.GN5858@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219213505.GN5858@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed 20-12-17 08:35:05, Dave Chinner wrote:
> On Tue, Dec 19, 2017 at 01:07:09PM +0100, Jan Kara wrote:
> > On Wed 13-12-17 09:20:04, Dave Chinner wrote:
> > > On Tue, Dec 12, 2017 at 01:05:35PM -0500, Josef Bacik wrote:
> > > > On Tue, Dec 12, 2017 at 10:36:19AM +1100, Dave Chinner wrote:
> > > > > On Mon, Dec 11, 2017 at 04:55:31PM -0500, Josef Bacik wrote:
> > > > This is just one of those things that's going to be slightly shitty.  It's the
> > > > same for memory reclaim, all of those places use pages so we just take
> > > > METADATA_*_BYTES >> PAGE_SHIFT to get pages and figure it's close enough.
> > > 
> > > Ok, so that isn't exactly easy to deal with, because all our
> > > metadata writeback is based on log sequence number targets (i.e. how
> > > far to push the tail of the log towards the current head). We've
> > > actually got no idea how pages/bytes actually map to a LSN target
> > > because while we might account a full buffer as dirty for memory
> > > reclaim purposes (up to 64k in size), we might have only logged 128
> > > bytes of it.
> > > 
> > > i.e. if we are asked to push 2MB of metadata and we treat that as
> > > 2MB of log space (i.e. push target of tail LSN + 2MB) we could have
> > > logged several tens of megabytes of dirty metadata in that LSN
> > > range and have to flush it all. OTOH, if the buffers are fully
> > > logged, then that same target might only flush 1.5MB of metadata
> > > once all the log overhead is taken into account.
> > > 
> > > So there's a fairly large disconnect between the "flush N bytes of
> > > metadata" API and the "push to a target LSN" that XFS uses for
> > > flushing metadata in aged order. I'm betting that extN and otehr
> > > filesystems might have similar mismatches with their journal
> > > flushing...
> > 
> > Well, for ext4 it isn't as bad since we do full block logging only. So if
> > we are asked to flush N pages, we can easily translate that to number of fs
> > blocks and flush that many from the oldest transaction.
> > 
> > Couldn't XFS just track how much it has cleaned (from reclaim perspective)
> > when pushing items from AIL (which is what I suppose XFS would do in
> > response to metadata writeback request) and just stop pushing when it has
> > cleaned as much as it was asked to?
> 
> If only it were that simple :/
> 
> To start with, flushing the dirty objects (such as inodes) to their
> backing buffers do not mean the the object is clean once the
> writeback completes. XFS has decoupled in-memory objects with
> logical object logging rather than logging physical buffers, and
> so can be modified and dirtied while the inode buffer
> is being written back. Hence if we just count things like "buffer
> size written" it's not actually a correct account of the amount of
> dirty metadata we've cleaned. If we don't get that right, it'll
> result in accounting errors and incorrect behaviour.
> 
> The bigger problem, however, is that we have no channel to return
> flush information from the AIL pushing to whatever caller asked for
> the push. Pushing metadata is completely decoupled from every other
> subsystem. i.e. the caller asked the xfsaild to push to a specific
> LSN (e.g. to free up a certain amount of log space for new
> transactions), and *nothing* has any idea of how much metadata we'll
> need to write to push the tail of the log to that LSN.
> 
> It's also completely asynchronous - there's no mechanism for waiting
> on a push to a specific LSN. Anything that needs a specific amount
> of log space to be available waits in ordered ticket queues on the
> log tail moving forwards. The only interfaces that have access to
> the log tail ticket waiting is the transaction reservation
> subsystem, which cannot be used during metadata writeback because
> that's a guaranteed deadlock vector....
> 
> Saying "just account for bytes written" assumes directly connected,
> synchronous dispatch metadata writeback infrastructure which we
> simply don't have in XFS. "just clean this many bytes" doesn't
> really fit at all because we have no way of referencing that to the
> distance we need to push the tail of the log. An interface that
> tells us "clean this percentage of dirty metadata" is much more
> useful because we can map that easily to a log sequence number
> based push target....

OK, understood.

> > > IOWs, treating metadata like it's one great big data inode doesn't
> > > seem to me to be the right abstraction to use for this - in most
> > > fileystems it's a bunch of objects with a complex dependency tree
> > > and unknown write ordering, not an inode full of data that can be
> > > sequentially written.
> > > 
> > > Maybe we need multiple ops with well defined behaviours. e.g.
> > > ->writeback_metadata() for background writeback, ->sync_metadata() for
> > > sync based operations. That way different filesystems can ignore the
> > > parts they don't need simply by not implementing those operations,
> > > and the writeback code doesn't need to try to cater for all
> > > operations through the one op. The writeback code should be cleaner,
> > > the filesystem code should be cleaner, and we can tailor the work
> > > guidelines for each operation separately so there's less mismatch
> > > between what writeback is asking and how filesystems track dirty
> > > metadata...
> > 
> > I agree that writeback for memory cleaning and writeback for data integrity
> > are two very different things especially for metadata. In fact for data
> > integrity writeback we already have ->sync_fs operation so there the
> > functionality gets duplicated. What we could do is that in
> > writeback_sb_inodes() we'd call ->write_metadata only when
> > work->for_kupdate or work->for_background is set. That way ->write_metadata
> > would be called only for memory cleaning purposes.
> 
> That makes sense, but I still think we need a better indication of
> how much writeback we need to do than just "writeback this chunk of
> pages". That "writeback a chunk" interface is necessary to share
> writeback bandwidth across numerous data inodes so that we don't
> starve any one inode of writeback bandwidth. That's unnecessary for
> metadata writeback on a superblock - we don't need to share that
> bandwidth around hundreds or thousands of inodes. What we actually
> need to know is how much writeback we need to do as a total of all
> the dirty metadata on the superblock.
> 
> Sure, that's not ideal for btrfs and mayext4, but we can write a
> simple generic helper that converts "flush X percent of dirty
> metadata" to a page/byte chunk as the current code does. DOing it
> this way allows filesystems to completely internalise the accounting
> that needs to be done, rather than trying to hack around a
> writeback accounting interface with large impedance mismatches to
> how the filesystem accounts for dirty metadata and/or tracks
> writeback progress.

Let me think loud on how we could tie this into how memory cleaning
writeback currently works - the one with for_background == 1 which is
generally used to get amount of dirty pages in the system under control.
We have a queue of inodes to write, we iterate over this queue and ask each
inode to write some amount (e.g. 64 M - exact amount depends on measured
writeback bandwidth etc.). Some amount from that inode gets written and we
continue with the next inode in the queue (put this one at the end of the
queue if it still has dirty pages). We do this until:

a) the number of dirty pages in the system is below background dirty limit
   and the number dirty pages for this device is below background dirty
   limit for this device.
b) run out of dirty inodes on this device
c) someone queues different type of writeback

And we need to somehow incorporate metadata writeback into this loop. I see
two questions here:

1) When / how often should we ask for metadata writeback?
2) How much to ask to write in one go?

The second question is especially tricky in the presence of completely
async metadata flushing in XFS - we can ask to write say half of dirty
metadata but then we have no idea whether the next observation of dirty
metadata counters is with that part of metadata already under writeback /
cleaned or whether xfsaild didn't even start working and pushing more has
no sense. Partly, this could be dealt with by telling the filesystem
"metadata dirty target" - i.e. "get your dirty metadata counters below X"
- and whether we communicate that in bytes, pages, or a fraction of
current dirty metadata counter value is a detail I don't have a strong
opinion on now. And the fact is the amount written by the filesystem
doesn't have to be very accurate anyway - we basically just want to make
some forward progress with writing metadata, don't want that to take too
long (so that other writeback from the thread isn't stalled), and if
writeback code is unhappy about the state of counters next time it looks,
it will ask the filesystem again...

This gets me directly to another problem with async nature of XFS metadata
writeback. That is that it could get writeback thread into busyloop - we
are supposed to terminate memory cleaning writeback only once dirty
counters are below limit and in case dirty metadata is causing counters to
be over limit, we would just ask in a loop XFS to get metadata below the
target. I suppose XFS could just return "nothing written" from its
->write_metadata operation and in such case we could sleep a bit before
going for another writeback loop (the same thing happens when filesystem
reports all inodes are locked / busy and it cannot writeback anything). But
it's getting a bit ugly and is it really better than somehow waiting inside
XFS for metadata writeback to occur?  Any idea Dave?

Regarding question 1). What Josef does is that once we went through all
queued inodes and wrote some amount from each one, we'd go and ask fs to
write some metadata. And then we'll again go to write inodes that are still
dirty. That is somewhat rough but I guess it is fine for now.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
