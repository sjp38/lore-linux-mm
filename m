Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 982586B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 12:09:25 -0400 (EDT)
Date: Mon, 7 Jun 2010 18:09:03 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-ID: <20100607160903.GE6293@quack.scz.novell.com>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
 <1275677231-15662-3-git-send-email-jack@suse.cz>
 <20100605013802.GG26335@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100605013802.GG26335@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 05-06-10 11:38:02, Nick Piggin wrote:
> On Fri, Jun 04, 2010 at 08:47:11PM +0200, Jan Kara wrote:
> > We try to avoid livelocks of writeback when some steadily creates
> > dirty pages in a mapping we are writing out. For memory-cleaning
> > writeback, using nr_to_write works reasonably well but we cannot
> > really use it for data integrity writeback. This patch tries to
> > solve the problem.
> > 
> > The idea is simple: Tag all pages that should be written back
> > with a special tag (TOWRITE) in the radix tree. This can be done
> > rather quickly and thus livelocks should not happen in practice.
> > Then we start doing the hard work of locking pages and sending
> > them to disk only for those pages that have TOWRITE tag set.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  include/linux/fs.h         |    1 +
> >  include/linux/radix-tree.h |    2 +-
> >  mm/page-writeback.c        |   44 ++++++++++++++++++++++++++++++++++++++++++--
> >  3 files changed, 44 insertions(+), 3 deletions(-)
...
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index b289310..f590a12 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -807,6 +807,30 @@ void __init page_writeback_init(void)
> >  }
> >  
> >  /**
> > + * tag_pages_for_writeback - tag pages to be written by write_cache_pages
> > + * @mapping: address space structure to write
> > + * @start: starting page index
> > + * @end: ending page index (inclusive)
> > + *
> > + * This function scans the page range from @start to @end and tags all pages
> > + * that have DIRTY tag set with a special TOWRITE tag. The idea is that
> > + * write_cache_pages (or whoever calls this function) will then use TOWRITE tag
> > + * to identify pages eligible for writeback.  This mechanism is used to avoid
> > + * livelocking of writeback by a process steadily creating new dirty pages in
> > + * the file (thus it is important for this function to be damn quick so that it
> > + * can tag pages faster than a dirtying process can create them).
> > + */
> > +void tag_pages_for_writeback(struct address_space *mapping,
> > +			     pgoff_t start, pgoff_t end)
> > +{
> > +	spin_lock_irq(&mapping->tree_lock);
> > +	radix_tree_gang_tag_if_tagged(&mapping->page_tree, start, end,
> > +				PAGECACHE_TAG_DIRTY, PAGECACHE_TAG_TOWRITE);
> > +	spin_unlock_irq(&mapping->tree_lock);
> > +}
> > +EXPORT_SYMBOL(tag_pages_for_writeback);
> > +
> > +/**
> >   * write_cache_pages - walk the list of dirty pages of the given address space and write all of them.
> >   * @mapping: address space structure to write
> >   * @wbc: subtract the number of written pages from *@wbc->nr_to_write
> > @@ -820,6 +844,13 @@ void __init page_writeback_init(void)
> >   * the call was made get new I/O started against them.  If wbc->sync_mode is
> >   * WB_SYNC_ALL then we were called for data integrity and we must wait for
> >   * existing IO to complete.
> > + *
> > + * To avoid livelocks (when other process dirties new pages), we first tag
> > + * pages which should be written back with TOWRITE tag and only then start
> > + * writing them. For data-integrity sync we have to be careful so that we do
> > + * not miss some pages (e.g., because some other process has cleared TOWRITE
> > + * tag we set). The rule we follow is that TOWRITE tag can be cleared only
> > + * by the process clearing the DIRTY tag (and submitting the page for IO).
> >   */
> >  int write_cache_pages(struct address_space *mapping,
> >  		      struct writeback_control *wbc, writepage_t writepage,
> > @@ -836,6 +867,7 @@ int write_cache_pages(struct address_space *mapping,
> >  	int cycled;
> >  	int range_whole = 0;
> >  	long nr_to_write = wbc->nr_to_write;
> > +	int tag;
> >  
> >  	pagevec_init(&pvec, 0);
> >  	if (wbc->range_cyclic) {
> > @@ -853,13 +885,18 @@ int write_cache_pages(struct address_space *mapping,
> >  			range_whole = 1;
> >  		cycled = 1; /* ignore range_cyclic tests */
> >  	}
> > +	if (wbc->sync_mode == WB_SYNC_ALL)
> > +		tag = PAGECACHE_TAG_TOWRITE;
> > +	else
> > +		tag = PAGECACHE_TAG_DIRTY;
> >  retry:
> > +	if (wbc->sync_mode == WB_SYNC_ALL)
> > +		tag_pages_for_writeback(mapping, index, end);
> 
> I wonder if this is too much spinlock latency in a huge dirty file?
> Some kid of batching of the operation perhaps would be good?
  You mean like copy tags for 4096 pages, then cond_resched the spin lock
and continue? That should be doable but it will give tasks that try to
livelock us more time (i.e. if there were 4096 tasks creating dirty pages
than probably they would be able to livelock us, won't they? Maybe we don't
care?).

> >  	done_index = index;
> >  	while (!done && (index <= end)) {
> >  		int i;
> >  
> > -		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
> > -			      PAGECACHE_TAG_DIRTY,
> > +		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
> >  			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
> >  		if (nr_pages == 0)
> >  			break;
> 
> Would it be neat to clear the tag even if we didn't set page to
> writeback? It should be uncommon case.
  Yeah, why not.

> > @@ -1319,6 +1356,9 @@ int test_set_page_writeback(struct page *page)
> >  			radix_tree_tag_clear(&mapping->page_tree,
> >  						page_index(page),
> >  						PAGECACHE_TAG_DIRTY);
> > +		radix_tree_tag_clear(&mapping->page_tree,
> > +				     page_index(page),
> > +				     PAGECACHE_TAG_TOWRITE);
> >  		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> >  	} else {
> >  		ret = TestSetPageWriteback(page);
> 
> It would be nice to have bitwise tag clearing so we can clear multiple
> at once. Then
> 
> clear_tag = PAGECACHE_TAG_TOWRITE;
> if (!PageDirty(page))
>   clear_tag |= PAGECACHE_TAG_DIRTY;
> 
> That could reduce overhead a bit more.
  Good idea. Will do.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
