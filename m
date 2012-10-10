Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E87FD6B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 04:55:27 -0400 (EDT)
Date: Wed, 10 Oct 2012 10:55:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-ID: <20121010085524.GA32581@quack.suse.cz>
References: <1349108796-32161-1-git-send-email-jack@suse.cz>
 <alpine.LSU.2.00.1210082029190.2237@eggly.anvils>
 <20121009162107.GE15790@quack.suse.cz>
 <alpine.LSU.2.00.1210091824390.30802@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1210091824390.30802@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Tue 09-10-12 19:19:09, Hugh Dickins wrote:
> On Tue, 9 Oct 2012, Jan Kara wrote:
> > On Mon 08-10-12 21:24:40, Hugh Dickins wrote:
> > > On Mon, 1 Oct 2012, Jan Kara wrote:
> > > 
> > > > On s390 any write to a page (even from kernel itself) sets architecture
> > > > specific page dirty bit. Thus when a page is written to via standard write, HW
> > > > dirty bit gets set and when we later map and unmap the page, page_remove_rmap()
> > > > finds the dirty bit and calls set_page_dirty().
> > > > 
> > > > Dirtying of a page which shouldn't be dirty can cause all sorts of problems to
> > > > filesystems. The bug we observed in practice is that buffers from the page get
> > > > freed, so when the page gets later marked as dirty and writeback writes it, XFS
> > > > crashes due to an assertion BUG_ON(!PagePrivate(page)) in page_buffers() called
> > > > from xfs_count_page_state().
...
> > > > Similar problem can also happen when zero_user_segment() call from
> > > > xfs_vm_writepage() (or block_write_full_page() for that matter) set the
> > > > hardware dirty bit during writeback, later buffers get freed, and then page
> > > > unmapped.
> 
> Similar problem, or is that the whole of the problem?  Where else does
> the page get written to, after clearing page dirty?  (It may not be worth
> spending time to answer me, I feel I'm wasting too much time on this.)
  I think the devil is in "after clearing page dirty" -
clear_page_dirty_for_io() has an optimization that it does not bother
transfering pte or storage key dirty bits to page dirty bit when page is
not mapped. On s390 that results in storage key dirty bit set once buffered
write modifies the page.

BTW there's no other place I'm aware of (and I was looking for some time
before I realized that storage key could remain set from buffered write as
described above).
> 
> I keep trying to put my finger on the precise bug.  I said in earlier
> mails to Mel and to Martin that we're mixing a bugfix and an optimization,
> but I cannot quite point to the bug.  Could one say that it's precisely at
> the "page straddles i_size" zero_user_segment(), in XFS or in other FSes?
> that the storage key ought to be re-cleaned after that?
  I think the precise bug is that we can leave dirty bit in storage key set
after writes from kernel while some parts of kernel assume the bit can be
set only via user mapping.

In a perfect world with infinite computation resources, all writes to
pages from kernel could look like:
	.. assume locked page ..
	page_mkclean(page);
	if (page_test_and_clear_dirty(page))
		set_page_dirty(page);
	write to page
	page_test_and_clear_dirty(page);	/* Clean storage key */

This would be bulletproof ... and ridiculously expensive.

> What if one day I happened to copy that code into shmem_writepage()?
> I've no intention to do so!  And it wouldn't cause a BUG.  Ah, and we
> never write shmem to swap while it's still mapped, so it wouldn't even
> have a chance to redirty the page in page_remove_rmap().
> 
> I guess I'm worrying too much; but it's not crystal clear to me why any
> !mapping_cap_account_dirty mapping would necessarily not have the problem.
  They can have a problem - if they cared that page_remove_rmap() can mark
as dirty a page which was never written to via mmap. So far we are lucky
and all !mapping_cap_account_dirty users don't care.

> > > But here's where I think the problem is.  You're assuming that all
> > > filesystems go the same mapping_cap_account_writeback_dirty() (yeah,
> > > there's no such function, just a confusing maze of three) route as XFS.
> > > 
> > > But filesystems like tmpfs and ramfs (perhaps they're the only two
> > > that matter here) don't participate in that, and wait for an mmap'ed
> > > page to be seen modified by the user (usually via pte_dirty, but that's
> > > a no-op on s390) before page is marked dirty; and page reclaim throws
> > > away undirtied pages.
> >   I admit I haven't thought of tmpfs and similar. After some discussion Mel
> > pointed me to the code in mmap which makes a difference. So if I get it
> > right, the difference which causes us problems is that on tmpfs we map the
> > page writeably even during read-only fault. OK, then if I make the above
> > code in page_remove_rmap():
> > 	if ((PageSwapCache(page) ||
> > 	     (!anon && !mapping_cap_account_dirty(page->mapping))) &&
> > 	    page_test_and_clear_dirty(page_to_pfn(page), 1))
> > 		set_page_dirty(page);
> > 
> >   Things should be ok (modulo the ugliness of this condition), right?
> 
> (Setting aside my reservations above...) That's almost exactly right, but
> I think the issue of a racing truncation (which could reset page->mapping
> to NULL at any moment) means we have to be a bit more careful.  Usually
> we guard against that with page lock, but here we can rely on mapcount.
> 
> page_mapping(page), with its built-in PageSwapCache check, actually ends
> up making the condition look less ugly; and so far as I could tell,
> the extra code does get optimized out on x86 (unless CONFIG_DEBUG_VM,
> when we are left with its VM_BUG_ON(PageSlab(page))).
> 
> But please look this over very critically and test (and if you like it,
> please adopt it as your own): I'm not entirely convinced yet myself.
  OK, I'll push the kernel with your updated patch to our build machines
and let it run there for a few days (it took about a day to reproduce the
issue originally). Thanks a lot for helping me with this.

								Honza


>  mm/rmap.c |   20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)
> 
> --- 3.6.0+/mm/rmap.c	2012-10-09 14:01:12.356379322 -0700
> +++ linux/mm/rmap.c	2012-10-09 14:58:48.160445605 -0700
> @@ -56,6 +56,7 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/migrate.h>
>  #include <linux/hugetlb.h>
> +#include <linux/backing-dev.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -926,11 +927,8 @@ int page_mkclean(struct page *page)
>  
>  	if (page_mapped(page)) {
>  		struct address_space *mapping = page_mapping(page);
> -		if (mapping) {
> +		if (mapping)
>  			ret = page_mkclean_file(mapping, page);
> -			if (page_test_and_clear_dirty(page_to_pfn(page), 1))
> -				ret = 1;
> -		}
>  	}
>  
>  	return ret;
> @@ -1116,6 +1114,7 @@ void page_add_file_rmap(struct page *pag
>   */
>  void page_remove_rmap(struct page *page)
>  {
> +	struct address_space *mapping = page_mapping(page);
>  	bool anon = PageAnon(page);
>  	bool locked;
>  	unsigned long flags;
> @@ -1138,8 +1137,19 @@ void page_remove_rmap(struct page *page)
>  	 * this if the page is anon, so about to be freed; but perhaps
>  	 * not if it's in swapcache - there might be another pte slot
>  	 * containing the swap entry, but page not yet written to swap.
> +	 *
> +	 * And we can skip it on file pages, so long as the filesystem
> +	 * participates in dirty tracking; but need to catch shm and tmpfs
> +	 * and ramfs pages which have been modified since creation by read
> +	 * fault.
> +	 *
> +	 * Note that mapping must be decided above, before decrementing
> +	 * mapcount (which luckily provides a barrier): once page is unmapped,
> +	 * it could be truncated and page->mapping reset to NULL at any moment.
> +	 * Note also that we are relying on page_mapping(page) to set mapping
> +	 * to &swapper_space when PageSwapCache(page).
>  	 */
> -	if ((!anon || PageSwapCache(page)) &&
> +	if (mapping && !mapping_cap_account_dirty(mapping) &&
>  	    page_test_and_clear_dirty(page_to_pfn(page), 1))
>  		set_page_dirty(page);
>  	/*
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
