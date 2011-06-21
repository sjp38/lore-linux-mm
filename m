Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC6286B0129
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 02:47:11 -0400 (EDT)
Subject: Re: [PATCH v2] mm: Fix assertion mapping->nrpages == 0 in
 end_writeback()
From: Miklos Szeredi <mszeredi@suse.cz>
In-Reply-To: <20110620171833.411c96e0.akpm@linux-foundation.org>
References: <1308152233-16919-1-git-send-email-jack@suse.cz>
	 <20110620171833.411c96e0.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jun 2011 08:47:49 +0200
Message-ID: <1308638869.2695.59.camel@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Jay <jinshan.xiong@whamcloud.com>, Miklos Szeredi <mszeredi@suse.de>

On Mon, 2011-06-20 at 17:18 -0700, Andrew Morton wrote:
> On Wed, 15 Jun 2011 17:37:13 +0200
> Jan Kara <jack@suse.cz> wrote:
> 
> > Under heavy memory and filesystem load, users observe the assertion
> > mapping->nrpages == 0 in end_writeback() trigger. This can be caused
> > by page reclaim reclaiming the last page from a mapping in the following
> > race:
> > 	CPU0				CPU1
> >   ...
> >   shrink_page_list()
> >     __remove_mapping()
> >       __delete_from_page_cache()
> >         radix_tree_delete()
> > 					evict_inode()
> > 					  truncate_inode_pages()
> > 					    truncate_inode_pages_range()
> > 					      pagevec_lookup() - finds nothing
> > 					  end_writeback()
> > 					    mapping->nrpages != 0 -> BUG
> >         page->mapping = NULL
> >         mapping->nrpages--
> > 
> > Fix the problem by doing a reliable check of mapping->nrpages under
> > mapping->tree_lock in end_writeback().
> > 
> > Analyzed by Jay <jinshan.xiong@whamcloud.com>, lost in LKML, and dug
> > out by Miklos Szeredi <mszeredi@suse.de>.
> > 
> > CC: Jay <jinshan.xiong@whamcloud.com>
> > CC: Miklos Szeredi <mszeredi@suse.de>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/inode.c         |    7 +++++++
> >  include/linux/fs.h |    1 +
> >  mm/truncate.c      |    5 +++++
> >  3 files changed, 13 insertions(+), 0 deletions(-)
> > 
> >   Andrew, does this look better?
> 
> spose so.
> 
> > diff --git a/fs/inode.c b/fs/inode.c
> > index 33c963d..1133cb0 100644
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -467,7 +467,14 @@ EXPORT_SYMBOL(remove_inode_hash);
> >  void end_writeback(struct inode *inode)
> >  {
> >  	might_sleep();
> > +	/*
> > +	 * We have to cycle tree_lock here because reclaim can be still in the
> > +	 * process of removing the last page (in __delete_from_page_cache())
> > +	 * and we must not free mapping under it.
> > +	 */
> > +	spin_lock(&inode->i_data.tree_lock);
> >  	BUG_ON(inode->i_data.nrpages);
> > +	spin_unlock(&inode->i_data.tree_lock);
> 
> That's an expensive assertion.  We might want to wrap all this in
> CONFIG_DEBUG_VM.
> 
> Or we could do
> 
> 	if (unlikely(inode->i_data.nrpages)) {
> 		/* comment goes here */
> 		spin_lock(&inode->i_data.tree_lock);
> 		BUG_ON(inode->i_data.nrpages);
> 		spin_unlock(&inode->i_data.tree_lock);
> 	}
> 

It's not *just* the assertion that needs locking.   Suppose that we are
in __remove_mapping() just before the 
spin_unlock_irq(&mapping->tree_lock) and the inode is freed along with
the mapping at that point in evict().  In that case the spin_unlock
would be touching freed memory.

truncate_inode_pages() used to synchronize page reclaim with inode
eviction, but now that synchronization is gone.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
