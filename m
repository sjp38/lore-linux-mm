Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id DEB606B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 07:10:12 -0400 (EDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 9 Oct 2012 12:10:10 +0100
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q99BA2B518481214
	for <linux-mm@kvack.org>; Tue, 9 Oct 2012 11:10:02 GMT
Received: from d06av06.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q99BA8oN005856
	for <linux-mm@kvack.org>; Tue, 9 Oct 2012 05:10:09 -0600
Date: Tue, 9 Oct 2012 10:18:22 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-ID: <20121009101822.79bdcb65@mschwide>
In-Reply-To: <alpine.LSU.2.00.1210082029190.2237@eggly.anvils>
References: <1349108796-32161-1-git-send-email-jack@suse.cz>
 <alpine.LSU.2.00.1210082029190.2237@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Mon, 8 Oct 2012 21:24:40 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Mon, 1 Oct 2012, Jan Kara wrote:
> 
> > On s390 any write to a page (even from kernel itself) sets architecture
> > specific page dirty bit. Thus when a page is written to via standard write, HW
> > dirty bit gets set and when we later map and unmap the page, page_remove_rmap()
> > finds the dirty bit and calls set_page_dirty().
> > 
> > Dirtying of a page which shouldn't be dirty can cause all sorts of problems to
> > filesystems. The bug we observed in practice is that buffers from the page get
> > freed, so when the page gets later marked as dirty and writeback writes it, XFS
> > crashes due to an assertion BUG_ON(!PagePrivate(page)) in page_buffers() called
> > from xfs_count_page_state().
> 
> What changed recently?  Was XFS hardly used on s390 until now?

One thing that changed is that the zero_user_segment for the remaining bytes between
i_size and the end of the page has been moved to block_write_full_page_endio, see
git commit eebd2aa355692afa. That changed the timing of the race window in regard
to map/unmap of the page by user space. And yes XFS is in use on s390.
 
> > 
> > Similar problem can also happen when zero_user_segment() call from
> > xfs_vm_writepage() (or block_write_full_page() for that matter) set the
> > hardware dirty bit during writeback, later buffers get freed, and then page
> > unmapped.
> > 
> > Fix the issue by ignoring s390 HW dirty bit for page cache pages in
> > page_mkclean() and page_remove_rmap(). This is safe because when a page gets
> > marked as writeable in PTE it is also marked dirty in do_wp_page() or
> > do_page_fault(). When the dirty bit is cleared by clear_page_dirty_for_io(),
> > the page gets writeprotected in page_mkclean(). So pagecache page is writeable
> > if and only if it is dirty.
> 
> Very interesting patch...

Yes, it is an interesting idea. I really like the part that we'll use less storage
key operations, as these are freaking expensive.

> > 
> > CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> which I'd very much like Martin's opinion on...

Until you pointed out the short-comings of the patch I really liked it ..

> > ---
> >  mm/rmap.c |   16 ++++++++++++++--
> >  1 files changed, 14 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 0f3b7cd..6ce8ddb 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -973,7 +973,15 @@ int page_mkclean(struct page *page)
> >  		struct address_space *mapping = page_mapping(page);
> >  		if (mapping) {
> >  			ret = page_mkclean_file(mapping, page);
> > -			if (page_test_and_clear_dirty(page_to_pfn(page), 1))
> > +			/*
> > +			 * We ignore dirty bit for pagecache pages. It is safe
> > +			 * as page is marked dirty iff it is writeable (page is
> > +			 * marked as dirty when it is made writeable and
> > +			 * clear_page_dirty_for_io() writeprotects the page
> > +			 * again).
> > +			 */
> > +			if (PageSwapCache(page) &&
> > +			    page_test_and_clear_dirty(page_to_pfn(page), 1))
> >  				ret = 1;
> 
> This part you could cut out: page_mkclean() is not used on SwapCache pages.
> I believe you are safe to remove the page_test_and_clear_dirty() from here.

Hmm, who guarantees that page_mkclean won't be used for SwapCache in the
future? At least we should add a comment there.

> >  		}
> >  	}
> > @@ -1183,8 +1191,12 @@ void page_remove_rmap(struct page *page)
> >  	 * this if the page is anon, so about to be freed; but perhaps
> >  	 * not if it's in swapcache - there might be another pte slot
> >  	 * containing the swap entry, but page not yet written to swap.
> > +	 * For pagecache pages, we don't care about dirty bit in storage
> > +	 * key because the page is writeable iff it is dirty (page is marked
> > +	 * as dirty when it is made writeable and clear_page_dirty_for_io()
> > +	 * writeprotects the page again).
> >  	 */
> > -	if ((!anon || PageSwapCache(page)) &&
> > +	if (PageSwapCache(page) &&
> >  	    page_test_and_clear_dirty(page_to_pfn(page), 1))
> >  		set_page_dirty(page);
> 
> But here's where I think the problem is.  You're assuming that all
> filesystems go the same mapping_cap_account_writeback_dirty() (yeah,
> there's no such function, just a confusing maze of three) route as XFS.
> 
> But filesystems like tmpfs and ramfs (perhaps they're the only two
> that matter here) don't participate in that, and wait for an mmap'ed
> page to be seen modified by the user (usually via pte_dirty, but that's
> a no-op on s390) before page is marked dirty; and page reclaim throws
> away undirtied pages.
>
> So, if I'm understanding right, with this change s390 would be in danger
> of discarding shm, and mmap'ed tmpfs and ramfs pages - whereas pages
> written with the write system call would already be PageDirty and secure.

The patch relies on the software dirty bit tracking for file backed pages,
if dirty bit tracking is not done for tmpfs and ramfs we are borked.
 
> You mention above that even the kernel writing to the page would mark
> the s390 storage key dirty.  I think that means that these shm and
> tmpfs and ramfs pages would all have dirty storage keys just from the
> clear_highpage() used to prepare them originally, and so would have
> been found dirty anyway by the existing code here in page_remove_rmap(),
> even though other architectures would regard them as clean and removable.

No, the clear_highpage() will set the dirty bit in the storage key but
the SetPageUptodate will clear the complete storage key including the
dirty bit.
 
> If that's the case, then maybe we'd do better just to mark them dirty
> when faulted in the s390 case.  Then your patch above should (I think)
> be safe.  Though I'd then be VERY tempted to adjust the SwapCache case
> too (I've not thought through exactly what that patch would be, just
> one or two suitably placed SetPageDirtys, I think), and eliminate
> page_test_and_clear_dirty() altogether - no tears shed by any of us!

I am seriously tempted to switch to pure software dirty bits by using
page protection for writable but clean pages. The worry is the number of
additional protection faults we would get. But as we do software dirty
bit tracking for the most part anyway this might not be as bad as it
used to be.

> A separate worry came to mind as I thought about your patch: where
> in page migration is s390's dirty storage key migrated from old page
> to new?  And if there is a problem there, that too should be fixed
> by what I propose in the previous paragraph.

That is covered by the SetPageUptodate() in migrate_page_copy().

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
