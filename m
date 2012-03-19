Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 723196B0092
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 07:22:38 -0400 (EDT)
Date: Mon, 19 Mar 2012 19:17:30 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] writeback: Avoid iput() from flusher thread
Message-ID: <20120319111730.GA23688@localhost>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
 <1331283748-12959-5-git-send-email-jack@suse.cz>
 <20120319085515.GA25478@infradead.org>
 <20120319104659.GH4359@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120319104659.GH4359@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Mar 19, 2012 at 11:46:59AM +0100, Jan Kara wrote:
> On Mon 19-03-12 04:55:15, Christoph Hellwig wrote:
> > On Fri, Mar 09, 2012 at 10:02:28AM +0100, Jan Kara wrote:
> > > Doing iput() from flusher thread (writeback_sb_inodes()) can create problems
> > > because iput() can do a lot of work - for example truncate the inode if it's
> > > the last iput on unlinked file. Some filesystems (e.g. ubifs) may need to
> > > allocate blocks during truncate (due to their COW nature) and in some cases
> > > they thus need to flush dirty data from truncate to reduce uncertainty in the
> > > amount of free space. This effectively creates a deadlock.
> > > 
> > > We get rid of iput() in flusher thread by using the fact that I_SYNC inode
> > > flag effectively pins the inode in memory. So if we take care to either hold
> > > i_lock or have I_SYNC set, we can get away without taking inode reference
> > > in writeback_sb_inodes().
> > > 
> > > As a side effect, we also fix possible use-after-free in wb_writeback() because
> > > inode_wait_for_writeback() call could try to reacquire i_lock on the inode that
> > > was already free.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > ---
> > >  fs/fs-writeback.c         |   38 ++++++++++++++++++++++++--------------
> > >  fs/inode.c                |   11 ++++++++++-
> > >  include/linux/fs.h        |    7 ++++---
> > >  include/linux/writeback.h |    7 +------
> > >  4 files changed, 39 insertions(+), 24 deletions(-)
> > > 
> > > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > > index 1e8bf44..f9f9b61 100644
> > > --- a/fs/fs-writeback.c
> > > +++ b/fs/fs-writeback.c
> > > @@ -325,19 +325,21 @@ static int write_inode(struct inode *inode, struct writeback_control *wbc)
> > >  }
> > >  
> > >  /*
> > > - * Wait for writeback on an inode to complete.
> > > + * Wait for writeback on an inode to complete. Called with i_lock held.
> > > + * Return 1 if we dropped i_lock and waited, 0 is returned otherwise.
> > >   */
> > > -static void inode_wait_for_writeback(struct inode *inode)
> > > +int __must_check inode_wait_for_writeback(struct inode *inode)
> > >  {
> > >  	DEFINE_WAIT_BIT(wq, &inode->i_state, __I_SYNC);
> > >  	wait_queue_head_t *wqh;
> > >  
> > >  	wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
> > > +	if (inode->i_state & I_SYNC) {
> > >  		spin_unlock(&inode->i_lock);
> > >  		__wait_on_bit(wqh, &wq, inode_wait, TASK_UNINTERRUPTIBLE);
> > > +		return 1;
> > >  	}
> > > +	return 0;
> > 
> > This is a horribly ugl primitive.
> > 
> > I'd rather add a
> > 
> > void inode_wait_for_writeback(struct inode *inode)
> > {
> >  	DEFINE_WAIT_BIT(wq, &inode->i_state, __I_SYNC);
> >  	wait_queue_head_t *wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
> > 
> > 	__wait_on_bit(wqh, &wq, inode_wait, TASK_UNINTERRUPTIBLE);
> > }
> > 
> > and opencode all the locking ad I_SYNC checking logic in the callers.
>   I agree the primitive is ugly. And actually it is buggy the way I wrote
> it. It should have been:
>   __wait_on_bit(wqh, &wq, isync_wait, TASK_UNINTERRUPTIBLE);
> 
> where isync_wait is:
> 
> int isync_wait(void *word)
> {
> 	struct inode *inode = container_of(word, struct inode, i_state);
> 
> 	spin_unlock(&inode->i_lock);
> 	schedule();
> 	return 1;
> }
> 
>   The problem is i_lock pins the inode for us in some cases. So once we
> drop i_lock, inode can go away so we cannot test the bit anymore.

Good point, it may not be valid to test &inode->i_state any more...

Given that __wait_on_bit() is

        do {    
                prepare_to_wait(wq, &q->wait, mode);
                if (test_bit(q->key.bit_nr, q->key.flags))
                        ret = (*action)(q->key.flags);
        } while (test_bit(q->key.bit_nr, q->key.flags) && !ret);

The isync_wait() will do good for the first test_bit, however still
cannot avoid invalid access for the second test_bit.

The fix could be

-        } while (test_bit(q->key.bit_nr, q->key.flags) && !ret);
+        } while (!ret && test_bit(q->key.bit_nr, q->key.flags));

> But there are just two places where we really need this. So maybe I can
> just opencode it there and for others use normal obvious variant.

OK.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
