Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 8729A6B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 09:12:56 -0400 (EDT)
Date: Thu, 23 May 2013 14:12:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: vmscan: Take page buffers dirty and locked state
 into account
Message-ID: <20130523131248.GW11497@suse.de>
References: <1369301187-24934-1-git-send-email-mgorman@suse.de>
 <1369301187-24934-3-git-send-email-mgorman@suse.de>
 <20130523095315.GC22466@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130523095315.GC22466@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, May 23, 2013 at 11:53:15AM +0200, Jan Kara wrote:
> On Thu 23-05-13 10:26:27, Mel Gorman wrote:
> > Page reclaim keeps track of dirty and under writeback pages and uses it to
> > determine if wait_iff_congested() should stall or if kswapd should begin
> > writing back pages. This fails to account for buffer pages that can be
> > under writeback but not PageWriteback which is the case for filesystems
> > like ext3. Furthermore, PageDirty buffer pages can have all the buffers
> > clean and writepage does no IO so it should not be accounted as congested.
> > 
> > This patch adds an address_space operation that filesystems may
> > optionally use to check if a page is really dirty or really under
> > writeback. An implementation is provided for filesystems that use
> > buffer_heads. By default, the page flags are obeyed.
> > 
> > Credit goes to Jan Kara for identifying that the page flags alone are
> > not sufficient for ext3 and sanity checking a number of ideas on how
> > the problem could be addressed.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  fs/buffer.c                 | 34 ++++++++++++++++++++++++++++++++++
> >  fs/ext2/inode.c             |  1 +
> >  fs/ext3/inode.c             |  3 +++
> >  fs/ext4/inode.c             |  2 ++
> >  fs/gfs2/aops.c              |  2 ++
> >  fs/ntfs/aops.c              |  1 +
> >  fs/ocfs2/aops.c             |  1 +
> >  fs/xfs/xfs_aops.c           |  1 +
> >  include/linux/buffer_head.h |  3 +++
> >  include/linux/fs.h          |  1 +
> >  mm/vmscan.c                 | 33 +++++++++++++++++++++++++++++++--
> >  11 files changed, 80 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/buffer.c b/fs/buffer.c
> > index 1aa0836..4247aa9 100644
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -91,6 +91,40 @@ void unlock_buffer(struct buffer_head *bh)
> >  EXPORT_SYMBOL(unlock_buffer);
> >  
> >  /*
> > + * Returns if the page has dirty or writeback buffers. If all the buffers
> > + * are unlocked and clean then the PageDirty information is stale. If
> > + * any of the pages are locked, it is assumed they are locked for IO.
> > + */
> > +void buffer_check_dirty_writeback(struct page *page,
> > +				     bool *dirty, bool *writeback)
> > +{
> > +	struct buffer_head *head, *bh;
> > +	*dirty = false;
> > +	*writeback = false;
> > +
> > +	BUG_ON(!PageLocked(page));
> > +
> > +	if (!page_has_buffers(page))
> > +		return;
> > +
> > +	if (PageWriteback(page))
> > +		*writeback = true;
> > +
> > +	head = page_buffers(page);
> > +	bh = head;
> > +	do {
> > +		if (buffer_locked(bh))
> > +			*writeback = true;
> > +
> > +		if (buffer_dirty(bh))
> > +			*dirty = true;
> > +
> > +		bh = bh->b_this_page;
> > +	} while (bh != head);
> > +}
> > +EXPORT_SYMBOL(buffer_check_dirty_writeback);
> > +
> > +/*
> >   * Block until a buffer comes unlocked.  This doesn't stop it
> >   * from becoming locked again - you have to lock it yourself
> >   * if you want to preserve its state.
> > diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> > index 0a87bb1..2fc3593 100644
> > --- a/fs/ext2/inode.c
> > +++ b/fs/ext2/inode.c
> > @@ -880,6 +880,7 @@ const struct address_space_operations ext2_aops = {
> >  	.writepages		= ext2_writepages,
> >  	.migratepage		= buffer_migrate_page,
> >  	.is_partially_uptodate	= block_is_partially_uptodate,
> > +	.is_dirty_writeback	= buffer_check_dirty_writeback,
> >  	.error_remove_page	= generic_error_remove_page,
> >  };
>
>   Hum, actually from what I know, it should be enough to set
> .is_dirty_writeback to buffer_check_dirty_writeback() only for
> ext3_ordered_aops and maybe def_blk_aops (fs/block_dev.c).

Hmm, ok. I had thought that even where the generic write pages were used
that set PageWriteback that it should still benefit from checking if the
buffers were clean. I'll back it out.

I'll add it to def_blk_aops, thanks for pointing that out.

> I also realized
> that data=journal mode of ext3 & ext4 also needs a special treatment but
> there we have to have a special function (likely provided by jbd/jbd2). But
> this mode isn't used very much so it's not pressing to fix that.
> 

And thanks for catching that

> Also I was thinking about how does this work NFS? It's page state logic is
> more complex with page going from PageDirty -> PageWriteback -> Unstable ->
> Clean. Unstable is a state where the page appears as clean to MM but it
> still cannot be reclaimed (we are waiting for the server to write the
> page). You need an inode wide commit operation to transform pages from
> Unstable to Clean state.
>   

I expect they'll be skipped and not accounted for because try_to_release_page
will fail. The pages will move to the active list and do another cycle
through the LRU. If there a lot of these pages then kswapd usage may get
high as it'll not stall. It'll need additional help.

That said, I also notice now that the PageWriteback check in the wrong
place. Pages have their dirty flag cleared under the lock before queueing
for IO until they are either redirtied or under writeback but the accounting
is within a PageDirty check. That needs fixing.

> I guess it would be worth testing this - something like your largedd test
> but over NFS.
> 

I will add it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
