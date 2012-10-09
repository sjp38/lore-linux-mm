Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 63C8F6B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 05:32:56 -0400 (EDT)
Date: Tue, 9 Oct 2012 10:32:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-ID: <20121009093250.GP29125@suse.de>
References: <1349108796-32161-1-git-send-email-jack@suse.cz>
 <alpine.LSU.2.00.1210082029190.2237@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1210082029190.2237@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org

On Mon, Oct 08, 2012 at 09:24:40PM -0700, Hugh Dickins wrote:
> > <SNIP>
> > CC: Mel Gorman <mgorman@suse.de>
> 
> and I'm grateful to Mel's ack for reawakening me to it...
> 
> > CC: linux-s390@vger.kernel.org
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> but I think it's wrong.
> 

Dang.

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
> 
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
> 

In the case of ramfs, what marks the page clean so it could be discarded? It
does not participate in dirty accounting so it's not going to clear the
dirty flag in clear_page_dirty_for_io(). It doesn't have a writepage
handler that would use an end_io handler to clear the page after "IO"
completes. I am not seeing how a ramfs page can get discarded at the moment.

shm and tmpfs are indeed different and I did not take them into account
(ba dum tisch) when reviewing. For those pages would it be sufficient to
check the following?

PageSwapCache(page) || (page->mapping && !bdi_cap_account_dirty(page->mapping)

The problem the patch dealt with involved buffers associated with the page
and that shouldn't be a problem for tmpfs, right? I recognise that this
might work just because of co-incidence and set off your "Yuck" detector
and you'll prefer the proposed solution below.

> You mention above that even the kernel writing to the page would mark
> the s390 storage key dirty.  I think that means that these shm and
> tmpfs and ramfs pages would all have dirty storage keys just from the
> clear_highpage() used to prepare them originally, and so would have
> been found dirty anyway by the existing code here in page_remove_rmap(),
> even though other architectures would regard them as clean and removable.
> 
> If that's the case, then maybe we'd do better just to mark them dirty
> when faulted in the s390 case.  Then your patch above should (I think)
> be safe.  Though I'd then be VERY tempted to adjust the SwapCache case
> too (I've not thought through exactly what that patch would be, just
> one or two suitably placed SetPageDirtys, I think), and eliminate
> page_test_and_clear_dirty() altogether - no tears shed by any of us!
>  

Do you mean something like this?

diff --git a/mm/memory.c b/mm/memory.c
index 5736170..c66166f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3316,7 +3316,20 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		} else {
 			inc_mm_counter_fast(mm, MM_FILEPAGES);
 			page_add_file_rmap(page);
-			if (flags & FAULT_FLAG_WRITE) {
+
+			/*
+			 * s390 depends on the dirty flag from the storage key
+			 * being propagated when the page is unmapped from the
+			 * page tables. For dirty-accounted mapping, we instead
+			 * depend on the page being marked dirty on writes and
+			 * being write-protected on clear_page_dirty_for_io.
+			 * The same protection does not apply for tmpfs pages
+			 * that do not participate in dirty accounting so mark
+			 * them dirty at fault time to avoid the data being
+			 * lost
+			 */
+			if (flags & FAULT_FLAG_WRITE ||
+			    !bdi_cap_account_dirty(page->mapping)) {
 				dirty_page = page;
 				get_page(dirty_page);
 			}

Could something like this result in more writes to swap? Lets say there
is an unmapped tmpfs file with data on it -- a process maps it, reads the
entire mapping and exits. The page is now dirty and potentially will have
to be rewritten to swap. That seems bad. Did I miss your point?

> A separate worry came to mind as I thought about your patch: where
> in page migration is s390's dirty storage key migrated from old page
> to new?  And if there is a problem there, that too should be fixed
> by what I propose in the previous paragraph.
> 

hmm, very good question. It should have been checked in
migrate_page_copy() where it could be done under the page lock before
the PageDirty check. Martin?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
