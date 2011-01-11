Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3056B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 15:41:57 -0500 (EST)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p0BKfskn018511
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 12:41:54 -0800
Received: from yxm8 (yxm8.prod.google.com [10.190.4.8])
	by hpaq7.eem.corp.google.com with ESMTP id p0BKfqsf015769
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 12:41:52 -0800
Received: by yxm8 with SMTP id 8so8712403yxm.21
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 12:41:52 -0800 (PST)
Date: Tue, 11 Jan 2011 12:41:41 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mmotm hangs on compaction lock_page
In-Reply-To: <20110111114521.GD11932@csn.ul.ie>
Message-ID: <alpine.LSU.2.00.1101111217410.26276@sister.anvils>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils> <20110107145259.GK29257@csn.ul.ie> <20110107175705.GL29257@csn.ul.ie> <20110110172609.GA11932@csn.ul.ie> <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com>
 <20110111114521.GD11932@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011, Mel Gorman wrote:
> On Mon, Jan 10, 2011 at 03:56:37PM -0800, Hugh Dickins wrote:
> > On Mon, 10 Jan 2011, Mel Gorman wrote:
> > > the other patch I posted was garbage.
> > 
> > I did give it a run, additionally setting PF_MEMALLOC before the call
> > to __alloc_pages_direct_compact and clearing after, you appeared to
> > be relying on that.  It didn't help, but now, only now, do I see there
> > are two calls to __alloc_pages_direct_compact and I missed the second
> > one - perhaps that's why it didn't help.
> 
> That is the most likely explanation.

Perhaps.  But FWIW let me add that before I realized I'd missed the second
location, I set a run going with my anon_vma hang patch added in - it's had
plenty of testing in the last week or two, but I'd taken it out because it
seemed to make hitting this other bug harder.  Indeed: the test was still
running happily this morning, as if the one bugfix somehow makes the other
bug much harder to hit (despite the one being entirely about anon pages
and the other entirely about file pages).  Odd odd odd.

> How about this then? Andrew, if accepted, this should replace the patch
> mm-vmscan-reclaim-order-0-and-use-compaction-instead-of-lumpy-reclaim-avoid-potential-deadlock-for-readahead-pages-and-direct-compaction.patch
> in -mm.
> 
> ==== CUT HERE ====
> mm: compaction: Avoid a potential deadlock due to lock_page() during direct compaction
> 
> Hugh Dickins reported that two instances of cp were locking up when
> running on ppc64 in a memory constrained environment. It also affects
> x86-64 but was harder to reproduce. The deadlock was related to readahead
> pages. When reading ahead, the pages are added locked to the LRU and queued
> for IO. The process is also inserting pages into the page cache and so is
> calling radix_preload and entering the page allocator. When SLUB is used,
> this can result in direct compaction finding the page that was just added
> to the LRU but still locked by the current process leading to deadlock.
> 
> This patch avoids locking pages in the direct compaction patch because
> we cannot be certain the current process is not holding the lock. To do
> this, PF_MEMALLOC is set for compaction. Compaction should not be
> re-entering the page allocator and so will not breach watermarks through
> the use of ALLOC_NO_WATERMARKS.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Yes, I like this one (and the PF_MEMALLOCs are better here than at the
outer level where I missed the one earlier).  I do wonder if you'll later
discover some reason why you were right to hesitate from doing this before,
but to me it looks like the right answer.  I've not yet tested precisely
this patch (and the issue is sufficiently elusive that successful tests
don't give much guarantee anyway - though I may find your tuning tips
help a lot there), but

Acked-by: Hugh Dickins <hughd@google.com>


> ---
>  mm/migrate.c    |   17 +++++++++++++++++
>  mm/page_alloc.c |    3 +++
>  2 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index b8a32da..7c3e307 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -644,6 +644,23 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	if (!trylock_page(page)) {
>  		if (!force)
>  			goto move_newpage;
> +
> +		/*
> +		 * It's not safe for direct compaction to call lock_page.
> +		 * For example, during page readahead pages are added locked
> +		 * to the LRU. Later, when the IO completes the pages are
> +		 * marked uptodate and unlocked. However, the queueing
> +		 * could be merging multiple pages for one bio (e.g.
> +		 * mpage_readpages). If an allocation happens for the
> +		 * second or third page, the process can end up locking
> +		 * the same page twice and deadlocking. Rather than
> +		 * trying to be clever about what pages can be locked,
> +		 * avoid the use of lock_page for direct compaction
> +		 * altogether.
> +		 */
> +		if (current->flags & PF_MEMALLOC)
> +			goto move_newpage;
> +
>  		lock_page(page);
>  	}
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index aede3a4..a5313f1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1809,12 +1809,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	bool sync_migration)
>  {
>  	struct page *page;
> +	struct task_struct *p = current;
>  
>  	if (!order || compaction_deferred(preferred_zone))
>  		return NULL;
>  
> +	p->flags |= PF_MEMALLOC;
>  	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
>  						nodemask, sync_migration);
> +	p->flags &= ~PF_MEMALLOC;
>  	if (*did_some_progress != COMPACT_SKIPPED) {
>  
>  		/* Page migration frees to the PCP lists but we want merging */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
