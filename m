Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 324526B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:17:25 -0400 (EDT)
Date: Mon, 19 Mar 2012 17:16:56 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/4] writeback: Refactor writeback_single_inode()
Message-ID: <20120319161656.GA10561@quack.suse.cz>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
 <1331283748-12959-4-git-send-email-jack@suse.cz>
 <20120319071358.GC11113@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120319071358.GC11113@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon 19-03-12 03:13:58, Christoph Hellwig wrote:
> On Fri, Mar 09, 2012 at 10:02:27AM +0100, Jan Kara wrote:
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/fs-writeback.c                |  264 +++++++++++++++++++++-----------------
> >  include/trace/events/writeback.h |   36 ++++-
> >  2 files changed, 174 insertions(+), 126 deletions(-)
> 
> Can you split this into a more gradual patch series?  This a a huge
> change of lots of little bits in a very sensitive area.
  OK, I'll try.

> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index be84e28..1e8bf44 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -231,11 +231,7 @@ static void requeue_io(struct inode *inode, struct bdi_writeback *wb)
> >  
> >  static void inode_sync_complete(struct inode *inode)
> >  {
> > -	/*
> > -	 * Prevent speculative execution through
> > -	 * spin_unlock(&wb->list_lock);
> > -	 */
> > -
> > +	inode->i_state &= ~I_SYNC;
> >  	smp_mb();
> >  	wake_up_bit(&inode->i_state, __I_SYNC);
> 
> E.g. Moving the I_SYNC clearing later should be a small patch of it's
> own with a changelog describing why it is safe.
  OK.

> > -static void inode_wait_for_writeback(struct inode *inode,
> > -				     struct bdi_writeback *wb)
> > +static void inode_wait_for_writeback(struct inode *inode)
> >  {
> >  	DEFINE_WAIT_BIT(wq, &inode->i_state, __I_SYNC);
> >  	wait_queue_head_t *wqh;
> > @@ -340,70 +335,34 @@ static void inode_wait_for_writeback(struct inode *inode,
> >  	wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
> >  	while (inode->i_state & I_SYNC) {
> >  		spin_unlock(&inode->i_lock);
> > -		spin_unlock(&wb->list_lock);
> >  		__wait_on_bit(wqh, &wq, inode_wait, TASK_UNINTERRUPTIBLE);
> > -		spin_lock(&wb->list_lock);
> >  		spin_lock(&inode->i_lock);
> >  	}
> >  }
> 
> Ditto for why calling inode_wait_for_writeback without the list_lock
> is fine now.
  OK.

> >  
> >  /*
> > + * Do real work connected with writing out inode and its dirty pages.
> 
>     * Write out an inode and its dirty pages, but do not update the
>       writeback list linkage, which is left to the caller.
> 
> > + * The function must be called with i_lock held and drops it.
> 
> Can we avoid these assymetric calling conventions if possible?  If not
> pleae add least add the sparse locking context annotations.
  Returning from __writeback_single_inode() with i_lock would be
impractical because callers need to take wb->list_lock which ranks above
it. Entering __writeback_single_inode() without i_lock might be possible
(see comment below) but I'm not sure it's worth it.

> > + * I_SYNC flag of the inode must be clear on entry and the function returns
> > + * with I_SYNC set. Caller must call inode_sync_complete() when it is done
> > + * with postprocessing of the inode.
> 
> Ewww..
  Yeah, it is awkward. Sadly I don't have much better solution. Flusher thread
cannot really afford normal waiting for I_SYNC because it doesn't hold
inode reference and thus inode can go away once we drop i_lock. Because of
that we have to enter without I_SYNC set. We could possibly set I_SYNC
already in the caller. That would at least make the function less
asymmetric. Also that would solve the problem with inode pinning so we could
make the function completely symmetric (entering without i_lock). But still
both callers would do unnecessary unlock of i_lock just for
__writeback_single_inode() to take it again (to clear I_DIRTY_PAGES).

  And we cannot clear I_SYNC before we have moved the inode to proper
writeback list which is done in the caller.

> >  	ret = do_writepages(mapping, wbc);
> >  
> > @@ -424,6 +383,9 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
> >  	 * write_inode()
> >  	 */
> >  	spin_lock(&inode->i_lock);
> > +	/* Didn't write out all pages or some became dirty? */
> > +	if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY))
> > +		inode->i_state |= I_DIRTY_PAGES;
> 
> Where did this hunk come from?
  writeback_single_inode() had:
		if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
			/*
			 * We didn't write back all the pages.  nfs_writepages()
			 * sometimes bales out without doing anything.
			 */
			inode->i_state |= I_DIRTY_PAGES;
			...

> > +	if (inode->i_state & I_FREEING)
> > +		goto out_unlock;
> 
> > +	if (inode->i_state & I_DIRTY)
> > +		redirty_tail(inode, wb);
> > +	else
> > +		list_del_init(&inode->i_wb_list);
> 
> These lines should be factored into a small helper shared with the
> writeback thread code, which would also avoid the out_unlock goto.
  Yup. Will do.

> > @@ -580,24 +587,51 @@ static long writeback_sb_inodes(struct super_block *sb,
> >  			redirty_tail(inode, wb);
> >  			continue;
> >  		}
> > +		if (inode->i_state & I_SYNC && work->sync_mode != WB_SYNC_ALL) {
> 
> Please add braces around the inode->i_state & I_SYNC.
  OK.

> > +		if (inode->i_state & I_FREEING)
> > +			goto continue_unlock;
> > +		/*
> > +		 * Sync livelock prevention. Each inode is tagged and synced in
> > +		 * one shot. If still dirty, it will be redirty_tail()'ed in
> > +		 * inode_wb_requeue(). We update the dirty time to prevent
> > +		 * queueing and syncing it again.
> > +		 */
> > +		if ((inode->i_state & I_DIRTY) &&
> > +		    (wbc.sync_mode == WB_SYNC_ALL || wbc.tagged_writepages))
> > +			inode->dirtied_when = jiffies;
> > +		inode_wb_requeue(inode, wb, &wbc);
> > +continue_unlock:
> 
> I'd rather have the non-freeing code indentented one more level than the
> goto magic here.  What's the problem with moving the dirtied_when update
> into inode_wb_requeue, which would make the whole thing a lot more
> readable?
  Not sure why I put it here. Will move it inside inode_wb_requeue().

> (Also factoring out inode_wb_requeue would be another good split patch)
> 
> > +		inode_sync_complete(inode);
> >  		spin_unlock(&inode->i_lock);
> >  		spin_unlock(&wb->list_lock);
> >  		iput(inode);
> > @@ -796,8 +830,10 @@ static long wb_writeback(struct bdi_writeback *wb,
> >  			trace_writeback_wait(wb->bdi, work);
> >  			inode = wb_inode(wb->b_more_io.prev);
> >  			spin_lock(&inode->i_lock);
> > +			spin_unlock(&wb->list_lock);
> > +			inode_wait_for_writeback(inode);
> >  			spin_unlock(&inode->i_lock);
> > +			spin_lock(&wb->list_lock);
> >  		}

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
