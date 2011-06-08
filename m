Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BFCE66B007B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 12:40:23 -0400 (EDT)
Date: Wed, 8 Jun 2011 18:40:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix assertion mapping->nrpages == 0 in
 end_writeback()
Message-ID: <20110608164019.GF5361@quack.suse.cz>
References: <1306748258-4732-1-git-send-email-jack@suse.cz>
 <20110606151614.0037e236.akpm@linux-foundation.org>
 <1307425597.3649.61.camel@tucsk.pomaz.szeredi.hu>
 <24671813-6F79-4746-8BF1-7CC50F4BBBCA@whamcloud.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24671813-6F79-4746-8BF1-7CC50F4BBBCA@whamcloud.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jinshan Xiong <jinshan.xiong@whamcloud.com>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Al Viro <viro@ZenIV.linux.org.uk>, stable@kernel.org, Nick Piggin <npiggin@kernel.dk>

On Tue 07-06-11 11:22:48, Jinshan Xiong wrote:
> 
> On Jun 6, 2011, at 10:46 PM, Miklos Szeredi wrote:
> 
> > On Mon, 2011-06-06 at 15:16 -0700, Andrew Morton wrote:
> >> On Mon, 30 May 2011 11:37:38 +0200
> >> Jan Kara <jack@suse.cz> wrote:
> >> 
> >>> Under heavy memory and filesystem load, users observe the assertion
> >>> mapping->nrpages == 0 in end_writeback() trigger. This can be caused
> >>> by page reclaim reclaiming the last page from a mapping in the following
> >>> race:
> >>> 	CPU0				CPU1
> >>>  ...
> >>>  shrink_page_list()
> >>>    __remove_mapping()
> >>>      __delete_from_page_cache()
> >>>        radix_tree_delete()
> >>> 					evict_inode()
> >>> 					  truncate_inode_pages()
> >>> 					    truncate_inode_pages_range()
> >>> 					      pagevec_lookup() - finds nothing
> >>> 					  end_writeback()
> >>> 					    mapping->nrpages != 0 -> BUG
> >>>        page->mapping = NULL
> >>>        mapping->nrpages--
> >>> 
> >>> Fix the problem by cycling the mapping->tree_lock at the end of
> >>> truncate_inode_pages_range() to synchronize with page reclaim.
> >>> 
> >>> Analyzed by Jay <jinshan.xiong@whamcloud.com>, lost in LKML, and dug
> >>> out by Miklos Szeredi <mszeredi@suse.de>.
> >>> 
> >>> CC: Jay <jinshan.xiong@whamcloud.com>
> >>> CC: stable@kernel.org
> >>> Acked-by: Miklos Szeredi <mszeredi@suse.de>
> >>> Signed-off-by: Jan Kara <jack@suse.cz>
> >>> ---
> >>> mm/truncate.c |    7 +++++++
> >>> 1 files changed, 7 insertions(+), 0 deletions(-)
> >>> 
> >>> Andrew, would you merge this patch please? Thanks.
> >>> 
> >>> diff --git a/mm/truncate.c b/mm/truncate.c
> >>> index a956675..ec3d292 100644
> >>> --- a/mm/truncate.c
> >>> +++ b/mm/truncate.c
> >>> @@ -291,6 +291,13 @@ void truncate_inode_pages_range(struct address_space *mapping,
> >>> 		pagevec_release(&pvec);
> >>> 		mem_cgroup_uncharge_end();
> >>> 	}
> >>> +	/*
> >>> +	 * Cycle the tree_lock to make sure all __delete_from_page_cache()
> >>> +	 * calls run from page reclaim have finished as well (this handles the
> >>> +	 * case when page reclaim took the last page from our range).
> >>> +	 */
> >>> +	spin_lock_irq(&mapping->tree_lock);
> >>> +	spin_unlock_irq(&mapping->tree_lock);
> >>> }
> >>> EXPORT_SYMBOL(truncate_inode_pages_range);
> >> 
> >> That's one ugly patch.
> >> 
> >> 
> >> Perhaps this regression was added by Nick's RCUification of pagecache. 
> >> 
> >> Before that patch, mapping->nrpages and the radix-tree state were
> >> coherent for holders of tree_lock.  So pagevec_lookup() would never
> >> return "no pages" while ->nrpages is non-zero.
> >> 
> >> After that patch, find_get_pages() uses RCU to protect the radix-tree
> >> but I don't think it correctly protects the aggregate (radix-tree +
> >> nrpages).
> > 
> > Yes, that's the case.
> > 
> >> 
> >> 
> >> If it's not that then I see another possibility. 
> >> truncate_inode_pages_range() does
> >> 
> >>        if (mapping->nrpages == 0)
> >>                return;
> >> 
> >> Is there anything to prevent a page getting added to the inode _after_
> >> this test?  i_mutex?  If not, that would trigger the BUG.
> > 
> > That BUG is in the inode eviction phase, so there's nothing that could
> > be adding a page.
> > 
> > And the only thing that could be removing one is page reclaim.
> > 
> >> Either way, I don't think that the uglypatch expresses a full
> >> understanding of te bug ;)
> > 
> > I don't see a better way, how would we make nrpages update atomically
> > wrt the radix-tree while using only RCU?
> > 
> > The question is, does it matter that those two can get temporarily out
> > of sync?
> > 
> > In case of inode eviction it does, not only because of that BUG_ON, but
> > because page reclaim must be somehow synchronised with eviction.
> > Otherwise it may access tree_lock on the mapping of an already freed
> > inode.
> 
> I tend to think your patch is absolutely ok to fix this problem. However, I think it would be better to move:
> 
> spin_lock(&mapping->tree_lock);
> spin_unlock(&mapping->tree_lock);
> 
> into end_writeback(). This is because truncate_inode_pages_range() is a
> generic function and it will be called somewhere else, maybe
> unnecessarily to do this extra thing.
  Possible. I just thought it would be nice from
truncate_inode_pages_range() to return only after we are really sure there
are no outstanding pages in the requested range...

> Actually, I'd like to hold an inode refcount in page stealing process.
> The reason is obvious: it makes no sense to steal pages from a
> to-be-freed inode. However, the problem is the overhead to grab an inode
> is damned heavy.
  No a good idea I think. If you happen to be the last one to drop inode
reference, you have to handle inode deletion and you really want to limit
places from where that can happen because that needs all sorts of
filesystem locks etc.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
