In-reply-to: <20080317220431.a8507e29.akpm@linux-foundation.org> (message from
	Andrew Morton on Mon, 17 Mar 2008 22:04:31 -0700)
Subject: Re: [patch 4/8] mm: allow not updating BDI stats in
 end_page_writeback()
References: <20080317191908.123631326@szeredi.hu>
	<20080317191945.122011759@szeredi.hu> <20080317220431.a8507e29.akpm@linux-foundation.org>
Message-Id: <E1JbWvF-0005Hr-Ur@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 18 Mar 2008 09:11:49 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[PeterZ added to CC]

> On Mon, 17 Mar 2008 20:19:12 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > Fuse's writepage will need to clear page writeback separately from
> > updating the per BDI counters.
> > 
> > This patch renames end_page_writeback() to __end_page_writeback() and
> > adds a boolean parameter to indicate if the per BDI stats need to be
> > updated.
> > 
> > Regular callers get an inline end_page_writeback() without the boolean
> > parameter.
> > 
> > ...
> > 
> > Index: linux/include/linux/page-flags.h
> > ===================================================================
> > --- linux.orig/include/linux/page-flags.h	2008-03-17 18:24:13.000000000 +0100
> > +++ linux/include/linux/page-flags.h	2008-03-17 18:25:53.000000000 +0100
> > @@ -300,7 +300,7 @@ struct page;	/* forward declaration */
> >  
> >  extern void cancel_dirty_page(struct page *page, unsigned int account_size);
> >  
> > -int test_clear_page_writeback(struct page *page);
> > +int test_clear_page_writeback(struct page *page, bool bdi_stats);
> >  int test_set_page_writeback(struct page *page);
> >  
> >  static inline void set_page_writeback(struct page *page)
> > Index: linux/include/linux/pagemap.h
> > ===================================================================
> > --- linux.orig/include/linux/pagemap.h	2008-03-17 18:24:13.000000000 +0100
> > +++ linux/include/linux/pagemap.h	2008-03-17 18:25:53.000000000 +0100
> > @@ -223,7 +223,12 @@ static inline void wait_on_page_writebac
> >  		wait_on_page_bit(page, PG_writeback);
> >  }
> >  
> > -extern void end_page_writeback(struct page *page);
> > +extern void __end_page_writeback(struct page *page, bool bdi_stats);
> > +
> > +static inline void end_page_writeback(struct page *page)
> > +{
> > +	__end_page_writeback(page, true);
> > +}
> >  
> >  /*
> >   * Fault a userspace page into pagetables.  Return non-zero on a fault.
> > Index: linux/mm/filemap.c
> > ===================================================================
> > --- linux.orig/mm/filemap.c	2008-03-17 18:25:38.000000000 +0100
> > +++ linux/mm/filemap.c	2008-03-17 18:25:53.000000000 +0100
> > @@ -574,19 +574,20 @@ EXPORT_SYMBOL(unlock_page);
> >  /**
> >   * end_page_writeback - end writeback against a page
> >   * @page: the page
> > + * @bdi_stats: update the per-bdi writeback counter
> >   */
> > -void end_page_writeback(struct page *page)
> > +void __end_page_writeback(struct page *page, bool bdi_stats)
> >  {
> >  	if (TestClearPageReclaim(page))
> >  		rotate_reclaimable_page(page);
> >  
> > -	if (!test_clear_page_writeback(page))
> > +	if (!test_clear_page_writeback(page, bdi_stats))
> >  		BUG();
> >  
> >  	smp_mb__after_clear_bit();
> >  	wake_up_page(page, PG_writeback);
> >  }
> > -EXPORT_SYMBOL(end_page_writeback);
> > +EXPORT_SYMBOL(__end_page_writeback);
> >  
> >  /**
> >   * __lock_page - get a lock on the page, assuming we need to sleep to get it
> > Index: linux/mm/page-writeback.c
> > ===================================================================
> > --- linux.orig/mm/page-writeback.c	2008-03-17 18:25:17.000000000 +0100
> > +++ linux/mm/page-writeback.c	2008-03-17 18:25:53.000000000 +0100
> > @@ -1242,7 +1242,7 @@ int clear_page_dirty_for_io(struct page 
> >  }
> >  EXPORT_SYMBOL(clear_page_dirty_for_io);
> >  
> > -int test_clear_page_writeback(struct page *page)
> > +int test_clear_page_writeback(struct page *page, bool bdi_stats)
> >  {
> >  	struct address_space *mapping = page_mapping(page);
> >  	int ret;
> > @@ -1257,7 +1257,7 @@ int test_clear_page_writeback(struct pag
> >  			radix_tree_tag_clear(&mapping->page_tree,
> >  						page_index(page),
> >  						PAGECACHE_TAG_WRITEBACK);
> > -			if (bdi_cap_writeback_dirty(bdi)) {
> > +			if (bdi_stats && bdi_cap_writeback_dirty(bdi)) {
> >  				__dec_bdi_stat(bdi, BDI_WRITEBACK);
> >  				__bdi_writeout_inc(bdi);
> >  			}
> 
> Adding `mode' flags to a core function is generally considered poor form. 
> And it adds additional overhead and possibly stack utilisation for all
> callers.
> 
> We generally prefer that a new function be created.  After all, that's what
> you've done here, only the code has gone and wedged two different functions
> into one.

Yes, although duplicating such a not entirely trivial function has
it's dangers as well, I think.

> Another approach might be to add a new bdi_cap_foo() flag.  We could then do
> 
> 	if (bdi_cap_writeback_dirty(bdi) && bdi_cap_mumble(bdi)) {
> 
> here.  But even better would be to create a new BDI capability which
> indicates that this address_space doesn't want this treatment in
> test_clear_page_writeback(), then go fix up all the
> !bdi_cap_writeback_dirty() address_spaces to set that flag.
> 
> So then the code becomes
> 
> 	if (!bdi_cap_account_writeback_in_test_clear_page_writeback(bdi)) {
> 
> (good luck thinking up a better name ;))
> 
> Reason: bdi_cap_writeback_dirty() is kinda weirdly intrepreted to mean
> various different things in different places and we really should separate
> its multiple interpretations into separate flags.
> 
> Note that this becomes a standalone VFS cleanup patch, and the fuse code
> can then just use it later on.  

Hmm, I can see two slightly different meanings of bdi_cap_writeback_dirty():

 1) need to call ->writepage (sync_page_range(), ...)
 2) need to update BDI stats  (test_clear_page_writeback(), ...)

If these two were different flags, then fuse could set the
NEED_WRITEPAGE flag, but clear the NEED_UPDATE_BDI_STATS flag, and do
it manually.

Does that sound workable?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
