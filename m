Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 406B16B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:05:39 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id p30so27134574qtg.23
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:05:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q22sor11011399qtg.46.2017.12.12.10.05.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 10:05:38 -0800 (PST)
Date: Tue, 12 Dec 2017 13:05:35 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v3 06/10] writeback: introduce
 super_operations->write_metadata
Message-ID: <20171212180534.c5f7luqz5oyfe7c3@destiny>
References: <1513029335-5112-1-git-send-email-josef@toxicpanda.com>
 <1513029335-5112-7-git-send-email-josef@toxicpanda.com>
 <20171211233619.GQ4094@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171211233619.GQ4094@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, Dec 12, 2017 at 10:36:19AM +1100, Dave Chinner wrote:
> On Mon, Dec 11, 2017 at 04:55:31PM -0500, Josef Bacik wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > Now that we have metadata counters in the VM, we need to provide a way to kick
> > writeback on dirty metadata.  Introduce super_operations->write_metadata.  This
> > allows file systems to deal with writing back any dirty metadata we need based
> > on the writeback needs of the system.  Since there is no inode to key off of we
> > need a list in the bdi for dirty super blocks to be added.  From there we can
> > find any dirty sb's on the bdi we are currently doing writeback on and call into
> > their ->write_metadata callback.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> > Reviewed-by: Jan Kara <jack@suse.cz>
> > Reviewed-by: Tejun Heo <tj@kernel.org>
> > ---
> >  fs/fs-writeback.c                | 72 ++++++++++++++++++++++++++++++++++++----
> >  fs/super.c                       |  6 ++++
> >  include/linux/backing-dev-defs.h |  2 ++
> >  include/linux/fs.h               |  4 +++
> >  mm/backing-dev.c                 |  2 ++
> >  5 files changed, 80 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index 987448ed7698..fba703dff678 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -1479,6 +1479,31 @@ static long writeback_chunk_size(struct bdi_writeback *wb,
> >  	return pages;
> >  }
> >  
> > +static long writeback_sb_metadata(struct super_block *sb,
> > +				  struct bdi_writeback *wb,
> > +				  struct wb_writeback_work *work)
> > +{
> > +	struct writeback_control wbc = {
> > +		.sync_mode		= work->sync_mode,
> > +		.tagged_writepages	= work->tagged_writepages,
> > +		.for_kupdate		= work->for_kupdate,
> > +		.for_background		= work->for_background,
> > +		.for_sync		= work->for_sync,
> > +		.range_cyclic		= work->range_cyclic,
> > +		.range_start		= 0,
> > +		.range_end		= LLONG_MAX,
> > +	};
> > +	long write_chunk;
> > +
> > +	write_chunk = writeback_chunk_size(wb, work);
> > +	wbc.nr_to_write = write_chunk;
> > +	sb->s_op->write_metadata(sb, &wbc);
> > +	work->nr_pages -= write_chunk - wbc.nr_to_write;
> > +
> > +	return write_chunk - wbc.nr_to_write;
> 
> Ok, writeback_chunk_size() returns a page count. We've already gone
> through the "metadata is not page sized" dance on the dirty
> accounting side, so how are we supposed to use pages to account for
> metadata writeback?
> 

This is just one of those things that's going to be slightly shitty.  It's the
same for memory reclaim, all of those places use pages so we just take
METADATA_*_BYTES >> PAGE_SHIFT to get pages and figure it's close enough.

> And, from what I can tell, if work->sync_mode = WB_SYNC_ALL or
> work->tagged_writepages is set, this will basically tell us to flush
> the entire dirty metadata cache because write_chunk will get set to
> LONG_MAX.
> 
> IOWs, this would appear to me to change sync() behaviour quite
> dramatically on filesystems where ->write_metadata is implemented.
> That is, instead of leaving all the metadata dirty in memory and
> just forcing the journal to stable storage, filesystems will be told
> to also write back all their dirty metadata before sync() returns,
> even though it is not necessary to provide correct sync()
> semantics....

Well for btrfs that's exactly what we have currently since it's just backed by
an inode.  Obviously this is different for journaled fs'es, but I assumed that
in your case you would either not use this part of the infrastructure or simply
ignore WB_SYNC_ALL and use WB_SYNC_NONE as a way to be nice under memory
pressure or whatever.

> 
> Mind you, writeback invocation is so convoluted now I could easily
> be mis-interpretting this code, but it does seem to me like this
> code is going to have some unintended behaviours....
> 

I don't think so, because right now this behavior is exactly what btrfs has
currently with it's inode setup.  I didn't really think the journaled use case
out since you guys are already rate limited by the journal.  If you would want
to start using this stuff what would you like to see done instead?  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
