Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 930E76B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:30:32 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id j94so25550897uad.0
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:30:32 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h23si711455vkc.174.2017.02.10.09.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 09:30:31 -0800 (PST)
Date: Fri, 10 Feb 2017 09:30:09 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V2 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170210173008.GA86050@shli-mbp.local>
References: <cover.1486163864.git.shli@fb.com>
 <3914c9f53c343357c39cb891210da31aa30ad3a9.1486163864.git.shli@fb.com>
 <20170210065022.GC25078@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170210065022.GC25078@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 10, 2017 at 03:50:22PM +0900, Minchan Kim wrote:
> Hi Shaohua,

Thanks for your time!
 
> On Fri, Feb 03, 2017 at 03:33:18PM -0800, Shaohua Li wrote:
> > Userspace indicates MADV_FREE pages could be freed without pageout, so
> > it pretty much likes used once file pages. For such pages, we'd like to
> > reclaim them once there is memory pressure. Also it might be unfair
> > reclaiming MADV_FREE pages always before used once file pages and we
> > definitively want to reclaim the pages before other anonymous and file
> > pages.
> > 
> > To speed up MADV_FREE pages reclaim, we put the pages into
> > LRU_INACTIVE_FILE list. The rationale is LRU_INACTIVE_FILE list is tiny
> > nowadays and should be full of used once file pages. Reclaiming
> > MADV_FREE pages will not have much interfere of anonymous and active
> > file pages. And the inactive file pages and MADV_FREE pages will be
> > reclaimed according to their age, so we don't reclaim too many MADV_FREE
> > pages too. Putting the MADV_FREE pages into LRU_INACTIVE_FILE_LIST also
> > means we can reclaim the pages without swap support. This idea is
> > suggested by Johannes.
> > 
> > We also clear the pages SwapBacked flag to indicate they are MADV_FREE
> > pages.
> 
> I think this patch should be merged with 3/7. Otherwise, MADV_FREE will
> be broken during the bisect.

Maybe I should move the patch 3 ahead, then we won't break bisect and still
make the patches clear.

> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > ---
> >  include/linux/mm_inline.h     |  5 +++++
> >  include/linux/swap.h          |  2 +-
> >  include/linux/vm_event_item.h |  2 +-
> >  mm/huge_memory.c              |  5 ++---
> >  mm/madvise.c                  |  3 +--
> >  mm/swap.c                     | 50 ++++++++++++++++++++++++-------------------
> >  mm/vmstat.c                   |  1 +
> >  7 files changed, 39 insertions(+), 29 deletions(-)
> > 
> > diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> > index e030a68..fdded06 100644
> > --- a/include/linux/mm_inline.h
> > +++ b/include/linux/mm_inline.h
> > @@ -22,6 +22,11 @@ static inline int page_is_file_cache(struct page *page)
> >  	return !PageSwapBacked(page);
> >  }
> >  
> > +static inline bool page_is_lazyfree(struct page *page)
> > +{
> > +	return PageAnon(page) && !PageSwapBacked(page);
> > +}
> > +
> 
> trivial:
> 
> How about using PageLazyFree for consistency with other PageXXX?
> As well, use SetPageLazyFree/ClearPageLazyFree rather than using
> raw {Set,Clear}PageSwapBacked.

So SetPageLazyFree == ClearPageSwapBacked, that would be weird. I personally
prefer directly using {Set, Clear}PageSwapBacked, because reader can
immediately know what's happening. If using the PageLazyFree, people always
need to refer the code and check the relationship between PageLazyFree and
PageSwapBacked.
 
> >  static __always_inline void __update_lru_size(struct lruvec *lruvec,
> >  				enum lru_list lru, enum zone_type zid,
> >  				int nr_pages)
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 45e91dd..486494e 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -279,7 +279,7 @@ extern void lru_add_drain_cpu(int cpu);
> >  extern void lru_add_drain_all(void);
> >  extern void rotate_reclaimable_page(struct page *page);
> >  extern void deactivate_file_page(struct page *page);
> > -extern void deactivate_page(struct page *page);
> > +extern void mark_page_lazyfree(struct page *page);
> 
> trivial:
> 
> How about "deactivate_lazyfree_page"? IMO, it would show intention
> clear that move the lazy free page to inactive list.
> 
> It's just matter of preference so I'm not strong against.

Yes, I thought about the name a little bit. Don't think we should use
deactivate, because it sounds that only works for active page, while the
function works for both active/inactive pages. I'm open to any suggestions.

> >  extern void swap_setup(void);
> >  
> >  extern void add_page_to_unevictable_list(struct page *page);
> > diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> > index 6aa1b6c..94e58da 100644
> > --- a/include/linux/vm_event_item.h
> > +++ b/include/linux/vm_event_item.h
> > @@ -25,7 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >  		FOR_ALL_ZONES(PGALLOC),
> >  		FOR_ALL_ZONES(ALLOCSTALL),
> >  		FOR_ALL_ZONES(PGSCAN_SKIP),
> > -		PGFREE, PGACTIVATE, PGDEACTIVATE,
> > +		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
> >  		PGFAULT, PGMAJFAULT,
> >  		PGLAZYFREED,
> >  		PGREFILL,
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index ecf569d..ddb9a94 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1391,9 +1391,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  		ClearPageDirty(page);
> >  	unlock_page(page);
> >  
> > -	if (PageActive(page))
> > -		deactivate_page(page);
> > -
> >  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> >  		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> >  			tlb->fullmm);
> > @@ -1404,6 +1401,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  		set_pmd_at(mm, addr, pmd, orig_pmd);
> >  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> >  	}
> > +
> > +	mark_page_lazyfree(page);
> >  	ret = true;
> >  out:
> >  	spin_unlock(ptl);
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index c867d88..c24549e 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -378,10 +378,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> >  			ptent = pte_mkclean(ptent);
> >  			ptent = pte_wrprotect(ptent);
> >  			set_pte_at(mm, addr, pte, ptent);
> > -			if (PageActive(page))
> > -				deactivate_page(page);
> >  			tlb_remove_tlb_entry(tlb, pte, addr);
> >  		}
> > +		mark_page_lazyfree(page);
> >  	}
> >  out:
> >  	if (nr_swap) {
> > diff --git a/mm/swap.c b/mm/swap.c
> > index c4910f1..69a7e9d 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -46,7 +46,7 @@ int page_cluster;
> >  static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
> >  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> >  static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
> > -static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
> > +static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
> >  #ifdef CONFIG_SMP
> >  static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
> >  #endif
> > @@ -268,6 +268,11 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
> >  		int lru = page_lru_base_type(page);
> >  
> >  		del_page_from_lru_list(page, lruvec, lru);
> > +		if (page_is_lazyfree(page)) {
> > +			SetPageSwapBacked(page);
> > +			file = 0;
> 
> I don't see why you set file with 0. Could you explain the rationale?

We are moving the page back to active anonymous list, so I'd like to charge the
recent_scanned and recent_rotated to anonymous.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
