Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CF6E6900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 06:20:57 -0400 (EDT)
Date: Thu, 14 Apr 2011 12:20:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/4] writeback: avoid duplicate
 balance_dirty_pages_ratelimited() calls
Message-ID: <20110414102047.GG5054@quack.suse.cz>
References: <20110413085937.981293444@intel.com>
 <20110413090415.511675208@intel.com>
 <20110413215307.GD4648@quack.suse.cz>
 <20110414003045.GB6097@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110414003045.GB6097@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Thu 14-04-11 08:30:45, Wu Fengguang wrote:
> On Thu, Apr 14, 2011 at 05:53:07AM +0800, Jan Kara wrote:
> > On Wed 13-04-11 16:59:39, Wu Fengguang wrote:
> > > When dd in 512bytes, balance_dirty_pages_ratelimited() could be called 8
> > > times for the same page, but obviously the page is only dirtied once.
> > > 
> > > Fix it with a (slightly racy) PageDirty() test.
> > > 
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > >  mm/filemap.c |    5 ++++-
> > >  1 file changed, 4 insertions(+), 1 deletion(-)
> > > 
> > > --- linux-next.orig/mm/filemap.c	2011-04-13 16:46:01.000000000 +0800
> > > +++ linux-next/mm/filemap.c	2011-04-13 16:47:26.000000000 +0800
> > > @@ -2313,6 +2313,7 @@ static ssize_t generic_perform_write(str
> > >  	long status = 0;
> > >  	ssize_t written = 0;
> > >  	unsigned int flags = 0;
> > > +	unsigned int dirty;
> > >  
> > >  	/*
> > >  	 * Copies from kernel address space cannot fail (NFSD is a big user).
> > > @@ -2361,6 +2362,7 @@ again:
> > >  		pagefault_enable();
> > >  		flush_dcache_page(page);
> > >  
> > > +		dirty = PageDirty(page);
> >   This isn't completely right as we sometimes dirty the page in
> > ->write_begin() (see e.g. block_write_begin() when we allocate blocks under
> > an already uptodate page) and in such cases we would not call
> > balance_dirty_pages(). So I'm not sure we can really do this
> > optimization (although it's sad)...
> 
> Good catch, thanks! I evaluated three possible options, the last one
> looks most promising (however is a radical change).
> 
> - do radix_tree_tag_get() before calling ->write_begin()
>   simple but heavy weight
  Yes, moreover you cannot really do the check until you have the page
locked for write because otherwise someone could come and write the page
before ->write_begin starts working with it.

> - add balance_dirty_pages_ratelimited() in __block_write_begin()
>   seems not easy, too
  Yes, you would call balance_dirty_pages_ratelimited() with page lock held
which is not a good thing to do.

> - accurately account the dirtied pages in account_page_dirtied() rather than
>   in balance_dirty_pages_ratelimited_nr(). This diff on top of my patchset
>   illustrates the idea, but will need to sort out cases like direct IO ...
> 
> --- linux-next.orig/mm/page-writeback.c	2011-04-14 07:50:09.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2011-04-14 07:52:35.000000000 +0800
> @@ -1295,8 +1295,6 @@ void balance_dirty_pages_ratelimited_nr(
>  	if (!bdi_cap_account_dirty(bdi))
>  		return;
>  
> -	current->nr_dirtied += nr_pages_dirtied;
> -
>  	if (dirty_exceeded_recently(bdi, MAX_PAUSE)) {
>  		unsigned long max = current->nr_dirtied +
>  						(128 >> (PAGE_SHIFT - 10));
> @@ -1752,6 +1750,7 @@ void account_page_dirtied(struct page *p
>  		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
>  		task_dirty_inc(current);
>  		task_io_account_write(PAGE_CACHE_SIZE);
> +		current->nr_dirtied++;
>  	}
>  }
  I see. We could do ratelimit accounting in account_page_dirtied() and
only check limits in balance_dirty_pages(). The only downside of this I can
see is that we would do one-by-one increment instead of a simple addition
when several pages are dirtied (ocfs2, btrfs, and splice interface take
advantage of this). But that should not be a huge issue and it's probably
worth the better ratelimit accounting.

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
