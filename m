Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B62876B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:43:31 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id u25so34851186qki.3
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:43:31 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v3si1768754qtc.39.2017.02.10.09.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 09:43:31 -0800 (PST)
Date: Fri, 10 Feb 2017 09:43:07 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V2 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170210174307.GC86050@shli-mbp.local>
References: <cover.1486163864.git.shli@fb.com>
 <9426fa2cf9fe320a15bfb20744c451eb6af1710a.1486163864.git.shli@fb.com>
 <20170210065839.GD25078@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170210065839.GD25078@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 10, 2017 at 03:58:39PM +0900, Minchan Kim wrote:
> On Fri, Feb 03, 2017 at 03:33:19PM -0800, Shaohua Li wrote:
> > When memory pressure is high, we free MADV_FREE pages. If the pages are
> > not dirty in pte, the pages could be freed immediately. Otherwise we
> > can't reclaim them. We put the pages back to anonumous LRU list (by
> > setting SwapBacked flag) and the pages will be reclaimed in normal
> > swapout way.
> > 
> > We use normal page reclaim policy. Since MADV_FREE pages are put into
> > inactive file list, such pages and inactive file pages are reclaimed
> > according to their age. This is expected, because we don't want to
> > reclaim too many MADV_FREE pages before used once pages.
> > 
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > ---
> >  mm/rmap.c   |  4 ++++
> >  mm/vmscan.c | 43 +++++++++++++++++++++++++++++++------------
> >  2 files changed, 35 insertions(+), 12 deletions(-)
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index c8d6204..5f05926 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1554,6 +1554,10 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  			dec_mm_counter(mm, MM_ANONPAGES);
> >  			rp->lazyfreed++;
> >  			goto discard;
> > +		} else if (flags & TTU_LZFREE) {
> > +			set_pte_at(mm, address, pte, pteval);
> > +			ret = SWAP_FAIL;
> > +			goto out_unmap;
> 
> trivial:
> 
> How about this?
> 
> if (flags && TTU_LZFREE) {
> 	if (PageDirty(page)) {
> 		set_pte_at(XXX);
> 		ret = SWAP_FAIL;
> 		goto out_unmap;
> 	} else {
> 		dec_mm_counter(mm, MM_ANONPAGES);
> 		rp->lazyfreed++;
> 		goto discard;
> 	}
> }
ok
 
> >  		}
> >  
> >  		if (swap_duplicate(entry) < 0) {
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 947ab6f..b304a84 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -864,7 +864,7 @@ static enum page_references page_check_references(struct page *page,
> >  		return PAGEREF_RECLAIM;
> >  
> >  	if (referenced_ptes) {
> > -		if (PageSwapBacked(page))
> > +		if (PageSwapBacked(page) || PageAnon(page))
> 
> If anyone accesses MADV_FREEed range with load op, not store,
> why shouldn't we discard that pages?

Don't have strong opinion about this, userspace probably shouldn't do this. I'm
ok to delete it if you insist.

> >  			return PAGEREF_ACTIVATE;
> >  		/*
> >  		 * All mapped pages start out with page table
> > @@ -903,7 +903,7 @@ static enum page_references page_check_references(struct page *page,
> >  
> >  /* Check if a page is dirty or under writeback */
> >  static void page_check_dirty_writeback(struct page *page,
> > -				       bool *dirty, bool *writeback)
> > +			bool *dirty, bool *writeback, bool lazyfree)
> >  {
> >  	struct address_space *mapping;
> >  
> > @@ -911,7 +911,7 @@ static void page_check_dirty_writeback(struct page *page,
> >  	 * Anonymous pages are not handled by flushers and must be written
> >  	 * from reclaim context. Do not stall reclaim based on them
> >  	 */
> > -	if (!page_is_file_cache(page)) {
> > +	if (!page_is_file_cache(page) || lazyfree) {
> 
> tivial:
> 
> We can check it with PageLazyFree in here rather than passing lazyfree
> argument. It's consistent like page_is_file_cache in here.

ok 
> >  		*dirty = false;
> >  		*writeback = false;
> >  		return;
> > @@ -971,7 +971,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		int may_enter_fs;
> >  		enum page_references references = PAGEREF_RECLAIM_CLEAN;
> >  		bool dirty, writeback;
> > -		bool lazyfree = false;
> > +		bool lazyfree;
> >  		int ret = SWAP_SUCCESS;
> >  
> >  		cond_resched();
> > @@ -986,6 +986,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  
> >  		sc->nr_scanned++;
> >  
> > +		lazyfree = page_is_lazyfree(page);
> > +
> >  		if (unlikely(!page_evictable(page)))
> >  			goto cull_mlocked;
> >  
> > @@ -993,7 +995,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			goto keep_locked;
> >  
> >  		/* Double the slab pressure for mapped and swapcache pages */
> > -		if (page_mapped(page) || PageSwapCache(page))
> > +		if ((page_mapped(page) || PageSwapCache(page)) && !lazyfree)
> >  			sc->nr_scanned++;
> 
> In this phase, we cannot know whether lazyfree marked page is discarable
> or not. If it is freeable and mapped, this logic makes sense. However,
> if the page is dirty?

I think this doesn't matter. If the page is dirty, it will go to reclaim in
next round and swap out. At that time, we will add nr_scanned there.

> >  
> >  		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> > @@ -1005,7 +1007,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		 * will stall and start writing pages if the tail of the LRU
> >  		 * is all dirty unqueued pages.
> >  		 */
> > -		page_check_dirty_writeback(page, &dirty, &writeback);
> > +		page_check_dirty_writeback(page, &dirty, &writeback, lazyfree);
> >  		if (dirty || writeback)
> >  			nr_dirty++;
> >  
> > @@ -1107,6 +1109,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			; /* try to reclaim the page below */
> >  		}
> >  
> > +		/* lazyfree page could be freed directly */
> > +		if (lazyfree) {
> > +			if (unlikely(PageTransHuge(page)) &&
> > +			    split_huge_page_to_list(page, page_list))
> > +				goto keep_locked;
> > +			goto unmap_page;
> > +		}
> > +
> 
> Maybe, we can remove this hunk. Instead add lazyfree check in here.
> 
> 		if (PageAnon(page) && !PageSwapCache(page) && !lazyfree) {
> 			if (!(sc->gfp_mask & __GFP_IO))
ok

Thanks,
Shaohua 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
