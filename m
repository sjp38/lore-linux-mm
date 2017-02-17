Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 727F6681021
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 00:41:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so51857073pfb.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 21:41:12 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r59si9210494plb.97.2017.02.16.21.41.10
        for <linux-mm@kvack.org>;
        Thu, 16 Feb 2017 21:41:11 -0800 (PST)
Date: Fri, 17 Feb 2017 14:41:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170217054108.GA3653@bbox>
References: <cover.1487100204.git.shli@fb.com>
 <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
 <20170216184018.GC20791@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170216184018.GC20791@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi Johannes,

On Thu, Feb 16, 2017 at 01:40:18PM -0500, Johannes Weiner wrote:
> On Tue, Feb 14, 2017 at 11:36:09AM -0800, Shaohua Li wrote:
> > @@ -1419,11 +1419,18 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
> >  				page);
> >  
> > -			if (!PageDirty(page) && (flags & TTU_LZFREE)) {
> > -				/* It's a freeable page by MADV_FREE */
> > -				dec_mm_counter(mm, MM_ANONPAGES);
> > -				rp->lazyfreed++;
> > -				goto discard;
> > +			if (flags & TTU_LZFREE) {
> > +				if (!PageDirty(page)) {
> > +					/* It's a freeable page by MADV_FREE */
> > +					dec_mm_counter(mm, MM_ANONPAGES);
> > +					rp->lazyfreed++;
> > +					goto discard;
> > +				} else {
> > +					set_pte_at(mm, address, pvmw.pte, pteval);
> > +					ret = SWAP_FAIL;
> > +					page_vma_mapped_walk_done(&pvmw);
> > +					break;
> > +				}
> 
> I don't understand why we need the TTU_LZFREE bit in general. More on
> that below at the callsite.

The reason I introduced it was ttu is used for migration/THP split path
as well as reclaim. It's clear to discard them in reclaim path because
it means surely memory pressure now but not sure with other path.

If you guys think it's always win to discard them in try_to_unmap
unconditionally, I think it would be better to be separate patch.

> 
> > @@ -911,7 +911,7 @@ static void page_check_dirty_writeback(struct page *page,
> >  	 * Anonymous pages are not handled by flushers and must be written
> >  	 * from reclaim context. Do not stall reclaim based on them
> >  	 */
> > -	if (!page_is_file_cache(page)) {
> > +	if (!page_is_file_cache(page) || page_is_lazyfree(page)) {
> 
> Do we need this? MADV_FREE clears the dirty bit off the page; we could
> just let them go through with the function without any special-casing.

I thought some driver potentially can do GUP with FOLL_TOUCH so that the
lazyfree page can have PG_dirty with !PG_swapbacked. In this case,
throttling logic of shrink_page_list can be confused?

> 
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
> >  
> >  		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> > @@ -1119,13 +1121,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		/*
> >  		 * Anonymous process memory has backing store?
> >  		 * Try to allocate it some swap space here.
> > +		 * Lazyfree page could be freed directly
> >  		 */
> > -		if (PageAnon(page) && !PageSwapCache(page)) {
> > +		if (PageAnon(page) && !PageSwapCache(page) && !lazyfree) {
> 
> lazyfree duplicates the anon check. As per the previous email, IMO it
> would be much preferable to get rid of that "lazyfree" obscuring here.
> 
> This would simply be:
> 
> 		if (PageAnon(page) && PageSwapBacked && !PageSwapCache)

Agree.

> 
> > @@ -1142,7 +1144,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		 * The page is mapped into the page tables of one or more
> >  		 * processes. Try to unmap it here.
> >  		 */
> > -		if (page_mapped(page) && mapping) {
> > +		if (page_mapped(page) && (mapping || lazyfree)) {
> 
> Do we actually need to filter for mapping || lazyfree? If we fail to
> allocate swap, we don't reach here. If the page is a truncated file
> page, ttu returns pretty much instantly with SWAP_AGAIN. We should be
> able to just check for page_mapped() alone, no?

try_to_unmap_one assumes every anonymous pages reached will have swp_entry
so it should be changed to check PageSwapCache if we go to the way.

> 
> >  			switch (ret = try_to_unmap(page, lazyfree ?
> >  				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
> >  				(ttu_flags | TTU_BATCH_FLUSH))) {
> 
> That bit I don't understand. Why do we need to pass TTU_LZFREE? What
> information does that carry that cannot be gathered from inside ttu?
> 
> I.e. when ttu runs into PageAnon, can it simply check !PageSwapBacked?
> And if it's still clean, it can lazyfreed++; goto discard.
> 
> Am I overlooking something?

As I said above, TTU_LZFREE signals when we should discard the page and
in my implementation, I thought it was only shrink_page_list which is
event for memory pressure.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
