Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id A34F16B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 19:21:27 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so1478684iak.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 16:21:27 -0700 (PDT)
Date: Tue, 9 Oct 2012 16:21:24 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
In-Reply-To: <20121009101822.79bdcb65@mschwide>
Message-ID: <alpine.LSU.2.00.1210091600450.30446@eggly.anvils>
References: <1349108796-32161-1-git-send-email-jack@suse.cz> <alpine.LSU.2.00.1210082029190.2237@eggly.anvils> <20121009101822.79bdcb65@mschwide>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Tue, 9 Oct 2012, Martin Schwidefsky wrote:
> On Mon, 8 Oct 2012 21:24:40 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> > On Mon, 1 Oct 2012, Jan Kara wrote:
> > 
> > > On s390 any write to a page (even from kernel itself) sets architecture
> > > specific page dirty bit. Thus when a page is written to via standard write, HW
> > > dirty bit gets set and when we later map and unmap the page, page_remove_rmap()
> > > finds the dirty bit and calls set_page_dirty().
> > > 
> > > Dirtying of a page which shouldn't be dirty can cause all sorts of problems to
> > > filesystems. The bug we observed in practice is that buffers from the page get
> > > freed, so when the page gets later marked as dirty and writeback writes it, XFS
> > > crashes due to an assertion BUG_ON(!PagePrivate(page)) in page_buffers() called
> > > from xfs_count_page_state().
> > 
> > What changed recently?  Was XFS hardly used on s390 until now?
> 
> One thing that changed is that the zero_user_segment for the remaining bytes between
> i_size and the end of the page has been moved to block_write_full_page_endio, see
> git commit eebd2aa355692afa. That changed the timing of the race window in regard
> to map/unmap of the page by user space. And yes XFS is in use on s390.

February 2008: I think we have different ideas of "recently" ;)

>  
> > > 
> > > Similar problem can also happen when zero_user_segment() call from
> > > xfs_vm_writepage() (or block_write_full_page() for that matter) set the
> > > hardware dirty bit during writeback, later buffers get freed, and then page
> > > unmapped.
> > > 
> > > Fix the issue by ignoring s390 HW dirty bit for page cache pages in
> > > page_mkclean() and page_remove_rmap(). This is safe because when a page gets
> > > marked as writeable in PTE it is also marked dirty in do_wp_page() or
> > > do_page_fault(). When the dirty bit is cleared by clear_page_dirty_for_io(),
> > > the page gets writeprotected in page_mkclean(). So pagecache page is writeable
> > > if and only if it is dirty.
> > 
> > Very interesting patch...
> 
> Yes, it is an interesting idea. I really like the part that we'll use less storage
> key operations, as these are freaking expensive.

As I said to Mel and will repeat to Jan, though an optimization would
be nice, I don't think we should necessarily mix it with the bugfix.

> 
> > > 
> > > CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > 
> > which I'd very much like Martin's opinion on...
> 
> Until you pointed out the short-comings of the patch I really liked it ..
> 
> > > ---
> > >  mm/rmap.c |   16 ++++++++++++++--
> > >  1 files changed, 14 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/mm/rmap.c b/mm/rmap.c
> > > index 0f3b7cd..6ce8ddb 100644
> > > --- a/mm/rmap.c
> > > +++ b/mm/rmap.c
> > > @@ -973,7 +973,15 @@ int page_mkclean(struct page *page)
> > >  		struct address_space *mapping = page_mapping(page);
> > >  		if (mapping) {
> > >  			ret = page_mkclean_file(mapping, page);
> > > -			if (page_test_and_clear_dirty(page_to_pfn(page), 1))
> > > +			/*
> > > +			 * We ignore dirty bit for pagecache pages. It is safe
> > > +			 * as page is marked dirty iff it is writeable (page is
> > > +			 * marked as dirty when it is made writeable and
> > > +			 * clear_page_dirty_for_io() writeprotects the page
> > > +			 * again).
> > > +			 */
> > > +			if (PageSwapCache(page) &&
> > > +			    page_test_and_clear_dirty(page_to_pfn(page), 1))
> > >  				ret = 1;
> > 
> > This part you could cut out: page_mkclean() is not used on SwapCache pages.
> > I believe you are safe to remove the page_test_and_clear_dirty() from here.
> 
> Hmm, who guarantees that page_mkclean won't be used for SwapCache in the
> future? At least we should add a comment there.

I set out to do so, to add a comment there; but honestly, it's a strange
place for such a comment when there's no longer even the code to comment
upon.  And page_mkclean_file(), called in the line above, already says
BUG_ON(PageAnon(page)), so it would soon fire if we ever make a change
that sends PageSwapCache pages this way.  It is possible that one day we
shall want to send tmpfs and swapcache down this route, I'm not ruling
that out; but then we shall have to extend page_mkclean(), yes.

> 
> The patch relies on the software dirty bit tracking for file backed pages,
> if dirty bit tracking is not done for tmpfs and ramfs we are borked.
>  
> > You mention above that even the kernel writing to the page would mark
> > the s390 storage key dirty.  I think that means that these shm and
> > tmpfs and ramfs pages would all have dirty storage keys just from the
> > clear_highpage() used to prepare them originally, and so would have
> > been found dirty anyway by the existing code here in page_remove_rmap(),
> > even though other architectures would regard them as clean and removable.
> 
> No, the clear_highpage() will set the dirty bit in the storage key but
> the SetPageUptodate will clear the complete storage key including the
> dirty bit.

Ah, thank you Martin, that clears that up...

>  
> > If that's the case, then maybe we'd do better just to mark them dirty
> > when faulted in the s390 case.  Then your patch above should (I think)
> > be safe.  Though I'd then be VERY tempted to adjust the SwapCache case
> > too (I've not thought through exactly what that patch would be, just
> > one or two suitably placed SetPageDirtys, I think), and eliminate
> > page_test_and_clear_dirty() altogether - no tears shed by any of us!

... so I should not hurt your performance with a change of that kind.

> 
> I am seriously tempted to switch to pure software dirty bits by using
> page protection for writable but clean pages. The worry is the number of
> additional protection faults we would get. But as we do software dirty
> bit tracking for the most part anyway this might not be as bad as it
> used to be.

That's exactly the same reason why tmpfs opts out of dirty tracking, fear
of unnecessary extra faults.  Anomalous as s390 is here, tmpfs is being
anomalous too, and I'd be a hypocrite to push for you to make that change.

> 
> > A separate worry came to mind as I thought about your patch: where
> > in page migration is s390's dirty storage key migrated from old page
> > to new?  And if there is a problem there, that too should be fixed
> > by what I propose in the previous paragraph.
> 
> That is covered by the SetPageUptodate() in migrate_page_copy().,> 

I don't think so: that makes sure that the newpage is not marked
dirty in storage key just because of the copy_highpage to it; but
I see nothing to mark the newpage dirty in storage key when the
old page was dirty there.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
