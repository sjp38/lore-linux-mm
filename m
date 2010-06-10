Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EB0466B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 04:12:50 -0400 (EDT)
Date: Thu, 10 Jun 2010 10:12:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-ID: <20100610081228.GA10827@quack.suse.cz>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
 <1275677231-15662-3-git-send-email-jack@suse.cz>
 <20100605013802.GG26335@laptop>
 <20100607160903.GE6293@quack.scz.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100607160903.GE6293@quack.scz.novell.com>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 07-06-10 18:09:03, Jan Kara wrote:
> On Sat 05-06-10 11:38:02, Nick Piggin wrote:
> > On Fri, Jun 04, 2010 at 08:47:11PM +0200, Jan Kara wrote:
> > >  	done_index = index;
> > >  	while (!done && (index <= end)) {
> > >  		int i;
> > >  
> > > -		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
> > > -			      PAGECACHE_TAG_DIRTY,
> > > +		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
> > >  			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
> > >  		if (nr_pages == 0)
> > >  			break;
> > 
> > Would it be neat to clear the tag even if we didn't set page to
> > writeback? It should be uncommon case.
>   Yeah, why not.
  Looking at this more, we shouldn't leave any TOWRITE tags dangling in
WB_SYNC_ALL mode - as soon as someone writes the page, he does
set_page_writeback() which clears the tag. Similarly if the page is removed
from the mapping, the tag is cleared. Or am I missing something?

> > > @@ -1319,6 +1356,9 @@ int test_set_page_writeback(struct page *page)
> > >  			radix_tree_tag_clear(&mapping->page_tree,
> > >  						page_index(page),
> > >  						PAGECACHE_TAG_DIRTY);
> > > +		radix_tree_tag_clear(&mapping->page_tree,
> > > +				     page_index(page),
> > > +				     PAGECACHE_TAG_TOWRITE);
> > >  		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> > >  	} else {
> > >  		ret = TestSetPageWriteback(page);
> > 
> > It would be nice to have bitwise tag clearing so we can clear multiple
> > at once. Then
> > 
> > clear_tag = PAGECACHE_TAG_TOWRITE;
> > if (!PageDirty(page))
> >   clear_tag |= PAGECACHE_TAG_DIRTY;
> > 
> > That could reduce overhead a bit more.
>   Good idea. Will do.
  On a second thought, will it bring us enough to justify a new interface
(which will be inconsistent with all the other radix tree interfaces
because they use tag numbers and not bitmaps)? Because looking at the code,
all we could save is the transformation of page index into a radix tree
path.  We would have to do all the other work for each tag separately
anyway and it won't probably have any great cache locality either because
radix trees for different tags are separate.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
