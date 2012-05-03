Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id EC49C6B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:14:21 -0400 (EDT)
Date: Thu, 3 May 2012 15:14:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/11] mm: Add support for a filesystem to activate swap
 files and use direct_IO for writing swap pages
Message-ID: <20120503141415.GG11435@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
 <1334578675-23445-5-git-send-email-mgorman@suse.de>
 <20120501155308.5679a09b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120501155308.5679a09b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Tue, May 01, 2012 at 03:53:08PM -0700, Andrew Morton wrote:
> > It is perfectly possible that direct_IO be used to read the swap
> > pages but it is an unnecessary complication. Similarly, it is possible
> > that ->writepage be used instead of direct_io to write the pages but
> > filesystem developers have stated that calling writepage from the VM
> > is undesirable for a variety of reasons and using direct_IO opens up
> > the possibility of writing back batches of swap pages in the future.
> 
> This all seems a bit odd.  And abusive.
> 
> Yes, it would be more pleasing if direct-io was used for reading as
> well.  How much more complication would it add?
> 

Quite a bit.

Superficially it's easy because swap_readpage() just sets up a kiocb,
fills in the necessary details and call ->direct_IO. The complexity is
around page locking and writing back pending writes in NFS.

read_swap_cache_async() calls swap_readpage with the page locked and
is expected to return with the page unlocked on successful completion of
the IO.

For swap-over-nfs, the readpage handler behaves exactly as
read_swap_cache_async() expects. For everything else, submit_bio() is used
with end_swap_bio_read() unlocking the page. Both of these handlers behave
the same with respect to locking. The direct_IO handler does not expect the
page to be locked and does not unlock it itself. Even if it works for NFS,
there might be other complications in the future around page locking in
direct_IO handlers.

The second complexity may be specific to NFS. The NFS readpage handler
flushes any pending writes with nfs_wb_page() before doing the read which it
can do because it holds the page lock. It was completely unclear how the same
could be achieved from swap_readpage() in a filesystem-independent manner.

As ->readpage() already knew how to do the right thing in all cases, I
used it.

> If I understand correctly, on the read path we're taking a fresh page
> which is destined for swapcache and then pretending that it is a
> pagecache page for the purpose of the I/O? 
>
> If there already existed a
> pagecache page for that file offset then we let it just sit there and
> bypass it?
> 

On the read path read_swap_cache_async() checks if a page is already in
swapcache and if not not, allocates a new page, adds it to the swapcache
and calls swap_readpage. Hence I do not think we are tripping the
problem you are thinking of.

> I'm surprised that this works at all - I guess nothing under
> ->readpage() goes poking around in the address_space.  For NFS, at
> least!
> 
> >
> > ...
> >
> > @@ -93,11 +94,38 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
> >  {
> >  	struct bio *bio;
> >  	int ret = 0, rw = WRITE;
> > +	struct swap_info_struct *sis = page_swap_info(page);
> >  
> >  	if (try_to_free_swap(page)) {
> >  		unlock_page(page);
> >  		goto out;
> >  	}
> > +
> > +	if (sis->flags & SWP_FILE) {
> > +		struct kiocb kiocb;
> > +		struct file *swap_file = sis->swap_file;
> > +		struct address_space *mapping = swap_file->f_mapping;
> > +		struct iovec iov = {
> > +			.iov_base = page_address(page),
> 
> Didn't we need to kmap the page?
> 

.... Yep, that would be important all right. I'll look at this closely
and do a round of testing on x86-32.

> > +			.iov_len  = PAGE_SIZE,
> > +		};
> > +
> > +		init_sync_kiocb(&kiocb, swap_file);
> > +		kiocb.ki_pos = page_file_offset(page);
> > +		kiocb.ki_left = PAGE_SIZE;
> > +		kiocb.ki_nbytes = PAGE_SIZE;
> > +
> > +		unlock_page(page);
> > +		ret = mapping->a_ops->direct_IO(KERNEL_WRITE,
> > +						&kiocb, &iov,
> > +						kiocb.ki_pos, 1);
> 
> I wonder if there's any point in setting PG_writeback around the IO.  I
> can't think of a reason.
> 

One does not spring to mind.

> > +		if (ret == PAGE_SIZE) {
> > +			count_vm_event(PSWPOUT);
> > +			ret = 0;
> > +		}
> > +		return ret;
> > +	}
> > +
> >  	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
> >  	if (bio == NULL) {
> >  		set_page_dirty(page);
> > @@ -119,9 +147,21 @@ int swap_readpage(struct page *page)
> >  {
> >  	struct bio *bio;
> >  	int ret = 0;
> > +	struct swap_info_struct *sis = page_swap_info(page);
> >  
> >  	VM_BUG_ON(!PageLocked(page));
> >  	VM_BUG_ON(PageUptodate(page));
> > +
> > +	if (sis->flags & SWP_FILE) {
> > +		struct file *swap_file = sis->swap_file;
> > +		struct address_space *mapping = swap_file->f_mapping;
> > +
> > +		ret = mapping->a_ops->readpage(swap_file, page);
> > +		if (!ret)
> > +			count_vm_event(PSWPIN);
> > +		return ret;
> > +	}
> 
> Confused.  Where did we set up page->index with the file offset?
> 

We don't use page->index in this case.

__add_to_swap_cache() records the swap entry in page->private.
nfs_readpage() looks up the page index with page_index() which for
SwapCache pages calls __page_file_index(). It in turn gets the swap
entry and looks up the index with swp_offset().

> >  	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
> >  	if (bio == NULL) {
> >  		unlock_page(page);
> > @@ -133,3 +173,15 @@ int swap_readpage(struct page *page)
> >  out:
> >  	return ret;
> >  }
> > +
> > +int swap_set_page_dirty(struct page *page)
> > +{
> > +	struct swap_info_struct *sis = page_swap_info(page);
> > +
> > +	if (sis->flags & SWP_FILE) {
> > +		struct address_space *mapping = sis->swap_file->f_mapping;
> > +		return mapping->a_ops->set_page_dirty(page);
> > +	} else {
> > +		return __set_page_dirty_nobuffers(page);
> > +	}
> > +}
> 
> More confused.  This is a swapcache page, not a pagecache page?  Why
> are we running set_page_dirty() against it?
> 

I don't really get the question. swap-over-NFS is not doing anything
different here than what we do today. PageSwapCache pages still have to
be marked dirty so they get written to disk before being discarded.

> And what are we doing on the !SWP_FILE path? 

Maintaining existing behaviour. This is what the swap ops looks like
without the patchset

static const struct address_space_operations swap_aops = {
        .writepage      = swap_writepage,
        .set_page_dirty = __set_page_dirty_nobuffers,
        .migratepage    = migrate_page,
};

> Newly setting PG_dirty
> against block-device-backed swapcache pages?  Why?  Where does it get
> cleared again?
> 

clear_page_dirty_for_io() in vmscan.c#pageout() ? I might be missing
something in your question again :(

> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index 9d3dd37..c25b9cf 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -26,7 +26,7 @@
> >   */
> >  static const struct address_space_operations swap_aops = {
> >  	.writepage	= swap_writepage,
> > -	.set_page_dirty	= __set_page_dirty_nobuffers,
> > +	.set_page_dirty	= swap_set_page_dirty,
> >  	.migratepage	= migrate_page,
> >  };
> >
> > ...
> >

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
