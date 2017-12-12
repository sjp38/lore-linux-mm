Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC9F6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 17:20:09 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e26so325554pfi.15
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 14:20:09 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id m13si159562pln.97.2017.12.12.14.20.06
        for <linux-mm@kvack.org>;
        Tue, 12 Dec 2017 14:20:07 -0800 (PST)
Date: Wed, 13 Dec 2017 09:20:04 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 06/10] writeback: introduce
 super_operations->write_metadata
Message-ID: <20171212222004.GT4094@dastard>
References: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
 <1513029335-5112-7-git-send-email-josef@toxicpanda.com>
 <20171211233619.GQ4094@dastard>
 <20171212180534.c5f7luqz5oyfe7c3@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171212180534.c5f7luqz5oyfe7c3@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, Dec 12, 2017 at 01:05:35PM -0500, Josef Bacik wrote:
> On Tue, Dec 12, 2017 at 10:36:19AM +1100, Dave Chinner wrote:
> > On Mon, Dec 11, 2017 at 04:55:31PM -0500, Josef Bacik wrote:
> > > From: Josef Bacik <jbacik@fb.com>
> > > 
> > > Now that we have metadata counters in the VM, we need to provide a way to kick
> > > writeback on dirty metadata.  Introduce super_operations->write_metadata.  This
> > > allows file systems to deal with writing back any dirty metadata we need based
> > > on the writeback needs of the system.  Since there is no inode to key off of we
> > > need a list in the bdi for dirty super blocks to be added.  From there we can
> > > find any dirty sb's on the bdi we are currently doing writeback on and call into
> > > their ->write_metadata callback.
> > > 
> > > Signed-off-by: Josef Bacik <jbacik@fb.com>
> > > Reviewed-by: Jan Kara <jack@suse.cz>
> > > Reviewed-by: Tejun Heo <tj@kernel.org>
> > > ---
> > >  fs/fs-writeback.c                | 72 ++++++++++++++++++++++++++++++++++++----
> > >  fs/super.c                       |  6 ++++
> > >  include/linux/backing-dev-defs.h |  2 ++
> > >  include/linux/fs.h               |  4 +++
> > >  mm/backing-dev.c                 |  2 ++
> > >  5 files changed, 80 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > > index 987448ed7698..fba703dff678 100644
> > > --- a/fs/fs-writeback.c
> > > +++ b/fs/fs-writeback.c
> > > @@ -1479,6 +1479,31 @@ static long writeback_chunk_size(struct bdi_writeback *wb,
> > >  	return pages;
> > >  }
> > >  
> > > +static long writeback_sb_metadata(struct super_block *sb,
> > > +				  struct bdi_writeback *wb,
> > > +				  struct wb_writeback_work *work)
> > > +{
> > > +	struct writeback_control wbc = {
> > > +		.sync_mode		= work->sync_mode,
> > > +		.tagged_writepages	= work->tagged_writepages,
> > > +		.for_kupdate		= work->for_kupdate,
> > > +		.for_background		= work->for_background,
> > > +		.for_sync		= work->for_sync,
> > > +		.range_cyclic		= work->range_cyclic,
> > > +		.range_start		= 0,
> > > +		.range_end		= LLONG_MAX,
> > > +	};
> > > +	long write_chunk;
> > > +
> > > +	write_chunk = writeback_chunk_size(wb, work);
> > > +	wbc.nr_to_write = write_chunk;
> > > +	sb->s_op->write_metadata(sb, &wbc);
> > > +	work->nr_pages -= write_chunk - wbc.nr_to_write;
> > > +
> > > +	return write_chunk - wbc.nr_to_write;
> > 
> > Ok, writeback_chunk_size() returns a page count. We've already gone
> > through the "metadata is not page sized" dance on the dirty
> > accounting side, so how are we supposed to use pages to account for
> > metadata writeback?
> > 
> 
> This is just one of those things that's going to be slightly shitty.  It's the
> same for memory reclaim, all of those places use pages so we just take
> METADATA_*_BYTES >> PAGE_SHIFT to get pages and figure it's close enough.

Ok, so that isn't exactly easy to deal with, because all our
metadata writeback is based on log sequence number targets (i.e. how
far to push the tail of the log towards the current head). We've
actually got no idea how pages/bytes actually map to a LSN target
because while we might account a full buffer as dirty for memory
reclaim purposes (up to 64k in size), we might have only logged 128
bytes of it.

i.e. if we are asked to push 2MB of metadata and we treat that as
2MB of log space (i.e. push target of tail LSN + 2MB) we could have
logged several tens of megabytes of dirty metadata in that LSN
range and have to flush it all. OTOH, if the buffers are fully
logged, then that same target might only flush 1.5MB of metadata
once all the log overhead is taken into account.

So there's a fairly large disconnect between the "flush N bytes of
metadata" API and the "push to a target LSN" that XFS uses for
flushing metadata in aged order. I'm betting that extN and otehr
filesystems might have similar mismatches with their journal
flushing...

> > And, from what I can tell, if work->sync_mode = WB_SYNC_ALL or
> > work->tagged_writepages is set, this will basically tell us to flush
> > the entire dirty metadata cache because write_chunk will get set to
> > LONG_MAX.
> > 
> > IOWs, this would appear to me to change sync() behaviour quite
> > dramatically on filesystems where ->write_metadata is implemented.
> > That is, instead of leaving all the metadata dirty in memory and
> > just forcing the journal to stable storage, filesystems will be told
> > to also write back all their dirty metadata before sync() returns,
> > even though it is not necessary to provide correct sync()
> > semantics....
> 
> Well for btrfs that's exactly what we have currently since it's just backed by
> an inode.

Hmmmm. That explains a lot.

Seems to me that btrfs is the odd one out here, so I'm not sure a
mechanism primarily designed for btrfs is going to work
generically....

> Obviously this is different for journaled fs'es, but I assumed that
> in your case you would either not use this part of the infrastructure or simply
> ignore WB_SYNC_ALL and use WB_SYNC_NONE as a way to be nice under memory
> pressure or whatever.

I don't think that designing an interface with the assumption other
filesystems will abuse it until it works for them is a great process
to follow...

> > Mind you, writeback invocation is so convoluted now I could easily
> > be mis-interpretting this code, but it does seem to me like this
> > code is going to have some unintended behaviours....
> > 
> 
> I don't think so, because right now this behavior is exactly what btrfs has
> currently with it's inode setup.  I didn't really think the journaled use case
> out since you guys are already rate limited by the journal.

We are?

XFS is rate limited by metadata writeback, not journal throughput.
Yes, journal space is limited by the metadata writeback rate, but
journalling itself is not the bottleneck.

> If you would want
> to start using this stuff what would you like to see done instead?  Thanks,

If this is all about reacting to memory pressure, then writeback is
not the mechanism that should drive this writeback. Reacting to
memory pressure is what shrinkers are for, and XFS already triggers
metadata writeback on memory pressure. Hence I don't see how this
writeback mechanism would help us if we have to abuse it to infer
"memory pressure occurring"

What I was hoping for was this interface to be a mechanism to drive
periodic background metadata writeback from the VFS so that when we
start to run out of memory the VFS has already started to ramp up
the rate of metadata writeback so we don't have huge amounts of dirty
metadata to write back during superblock shrinker based reclaim.

i.e. it works more like dirty background data writeback, get's the
amount of work to do from the amount of dirty metadata associated
with the bdi and doesn't actually do anything when operations like
sync() are run because there isn't a need to writeback metadata in
those operations.

IOWs, treating metadata like it's one great big data inode doesn't
seem to me to be the right abstraction to use for this - in most
fileystems it's a bunch of objects with a complex dependency tree
and unknown write ordering, not an inode full of data that can be
sequentially written.

Maybe we need multiple ops with well defined behaviours. e.g.
->writeback_metadata() for background writeback, ->sync_metadata() for
sync based operations. That way different filesystems can ignore the
parts they don't need simply by not implementing those operations,
and the writeback code doesn't need to try to cater for all
operations through the one op. The writeback code should be cleaner,
the filesystem code should be cleaner, and we can tailor the work
guidelines for each operation separately so there's less mismatch
between what writeback is asking and how filesystems track dirty
metadata...

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
