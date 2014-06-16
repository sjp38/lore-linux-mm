Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D0CAC6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:00:01 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so4349324wiv.10
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 09:00:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id la3si19930002wjb.23.2014.06.16.08.59.59
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 09:00:00 -0700 (PDT)
Date: Mon, 16 Jun 2014 11:59:50 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm v2 02/11] madvise: cleanup swapin_walk_pmd_entry()
Message-ID: <20140616155950.GA13264@nhori.bos.redhat.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1402609691-13950-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.LSU.2.11.1406151252400.1241@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1406151252400.1241@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Sun, Jun 15, 2014 at 01:24:30PM -0700, Hugh Dickins wrote:
> On Thu, 12 Jun 2014, Naoya Horiguchi wrote:
> 
> > With the recent update on page table walker, we can use common code for
> > the walking more. Unlike many other users, this swapin_walk expects to
> > handle swap entries. As a result we should be careful about ptl locking.
> > Swapin operation, read_swap_cache_async(), could cause page reclaim, so
> > we can't keep holding ptl throughout this pte loop.
> > In order to properly handle ptl in pte_entry(), this patch adds two new
> > members on struct mm_walk.
> > 
> > This cleanup is necessary to get to the final form of page table walker,
> > where we should do all caller's specific work on leaf entries (IOW, all
> > pmd_entry() should be used for trans_pmd.)
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Hugh Dickins <hughd@google.com>
> 
> Sorry, I believe this (and probably several other of your conversions)
> is badly flawed.
> 
> You have a pattern of doing pte_offset_map_lock() inside the page walker,
> then dropping and regetting map and lock inside your pte handler.
> 
> But on, say, x86_32 with CONFIG_HIGHMEM, CONFIG_SMP and CONFIG_PREEMPT,
> you may be preempted then run on a different cpu while atomic kmap and
> lock are dropped: so that the pte pointer then used on return to
> walk_pte_range() will no longer correspond to the right mapping.

Sorry, I didn't handle it correctly.

> Presumably that can be fixed by keeping the pte pointer in the mm_walk
> structure; but I'm not at all sure that's the right thing to do.

orig_pte should be updated if we call pte_offset_map_lock() or pte_offset_map()
inside the callback. So moving orig_pte into mm_walk is what I think I'll
do in the next post.

> I am not nearly so keen as you to reduce all these to per-pte callouts,
> which seem inefficient to me.

Right, we can't do inlining for callbacks, so calling callbacks more is
slower than open code. To make it better, code generator which creates
open page walk code for each users at build time might be one option.
Standardization done in patchset is the first step for doing it.

>  It can be argued both ways on the less
> important functions (like this madvise one); but I hope you don't try
> to make this kind of conversion to fast paths like those in memory.c.

OK. I never touch fast paths until performance concern is solved.

Thanks,
Naoya Horiguchi

> Hugh
> 
> > ---
> >  include/linux/mm.h |  4 ++++
> >  mm/madvise.c       | 54 +++++++++++++++++++++++-------------------------------
> >  mm/pagewalk.c      | 11 +++++------
> >  3 files changed, 32 insertions(+), 37 deletions(-)
> > 
> > diff --git mmotm-2014-05-21-16-57.orig/include/linux/mm.h mmotm-2014-05-21-16-57/include/linux/mm.h
> > index b4aa6579f2b1..aa832161a1ff 100644
> > --- mmotm-2014-05-21-16-57.orig/include/linux/mm.h
> > +++ mmotm-2014-05-21-16-57/include/linux/mm.h
> > @@ -1108,6 +1108,8 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
> >   * @vma:       vma currently walked
> >   * @skip:      internal control flag which is set when we skip the lower
> >   *             level entries.
> > + * @pmd:       current pmd entry
> > + * @ptl:       page table lock associated with current entry
> >   * @private:   private data for callbacks' use
> >   *
> >   * (see the comment on walk_page_range() for more details)
> > @@ -1126,6 +1128,8 @@ struct mm_walk {
> >  	struct mm_struct *mm;
> >  	struct vm_area_struct *vma;
> >  	int skip;
> > +	pmd_t *pmd;
> > +	spinlock_t *ptl;
> >  	void *private;
> >  };
> >  
> > diff --git mmotm-2014-05-21-16-57.orig/mm/madvise.c mmotm-2014-05-21-16-57/mm/madvise.c
> > index a402f8fdc68e..06b390a6fbbd 100644
> > --- mmotm-2014-05-21-16-57.orig/mm/madvise.c
> > +++ mmotm-2014-05-21-16-57/mm/madvise.c
> > @@ -135,38 +135,31 @@ static long madvise_behavior(struct vm_area_struct *vma,
> >  }
> >  
> >  #ifdef CONFIG_SWAP
> > -static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
> > +/*
> > + * Assuming that page table walker holds page table lock.
> > + */
> > +static int swapin_walk_pte_entry(pte_t *pte, unsigned long start,
> >  	unsigned long end, struct mm_walk *walk)
> >  {
> > -	pte_t *orig_pte;
> > -	struct vm_area_struct *vma = walk->private;
> > -	unsigned long index;
> > -
> > -	if (pmd_none_or_trans_huge_or_clear_bad(pmd))
> > -		return 0;
> > -
> > -	for (index = start; index != end; index += PAGE_SIZE) {
> > -		pte_t pte;
> > -		swp_entry_t entry;
> > -		struct page *page;
> > -		spinlock_t *ptl;
> > -
> > -		orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
> > -		pte = *(orig_pte + ((index - start) / PAGE_SIZE));
> > -		pte_unmap_unlock(orig_pte, ptl);
> > -
> > -		if (pte_present(pte) || pte_none(pte) || pte_file(pte))
> > -			continue;
> > -		entry = pte_to_swp_entry(pte);
> > -		if (unlikely(non_swap_entry(entry)))
> > -			continue;
> > -
> > -		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
> > -								vma, index);
> > -		if (page)
> > -			page_cache_release(page);
> > -	}
> > +	pte_t ptent;
> > +	pte_t *orig_pte = pte - ((start & (PMD_SIZE - 1)) >> PAGE_SHIFT);
> > +	swp_entry_t entry;
> > +	struct page *page;
> >  
> > +	ptent = *pte;
> > +	pte_unmap_unlock(orig_pte, walk->ptl);
> > +	if (pte_present(ptent) || pte_none(ptent) || pte_file(ptent))
> > +		goto lock;
> > +	entry = pte_to_swp_entry(ptent);
> > +	if (unlikely(non_swap_entry(entry)))
> > +		goto lock;
> > +	page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
> > +				     walk->vma, start);
> > +	if (page)
> > +		page_cache_release(page);
> > +lock:
> > +	pte_offset_map(walk->pmd, start & PMD_MASK);
> > +	spin_lock(walk->ptl);
> >  	return 0;
> >  }
> >  
> > @@ -175,8 +168,7 @@ static void force_swapin_readahead(struct vm_area_struct *vma,
> >  {
> >  	struct mm_walk walk = {
> >  		.mm = vma->vm_mm,
> > -		.pmd_entry = swapin_walk_pmd_entry,
> > -		.private = vma,
> > +		.pte_entry = swapin_walk_pte_entry,
> >  	};
> >  
> >  	walk_page_range(start, end, &walk);
> > diff --git mmotm-2014-05-21-16-57.orig/mm/pagewalk.c mmotm-2014-05-21-16-57/mm/pagewalk.c
> > index e734f63276c2..24311d6f5c20 100644
> > --- mmotm-2014-05-21-16-57.orig/mm/pagewalk.c
> > +++ mmotm-2014-05-21-16-57/mm/pagewalk.c
> > @@ -27,10 +27,10 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr,
> >  	struct mm_struct *mm = walk->mm;
> >  	pte_t *pte;
> >  	pte_t *orig_pte;
> > -	spinlock_t *ptl;
> >  	int err = 0;
> >  
> > -	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> > +	walk->pmd = pmd;
> > +	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &walk->ptl);
> >  	do {
> >  		if (pte_none(*pte)) {
> >  			if (walk->pte_hole)
> > @@ -48,7 +48,7 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr,
> >  		if (err)
> >  		       break;
> >  	} while (pte++, addr += PAGE_SIZE, addr < end);
> > -	pte_unmap_unlock(orig_pte, ptl);
> > +	pte_unmap_unlock(orig_pte, walk->ptl);
> >  	cond_resched();
> >  	return addr == end ? 0 : err;
> >  }
> > @@ -172,7 +172,6 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
> >  	unsigned long hmask = huge_page_mask(h);
> >  	pte_t *pte;
> >  	int err = 0;
> > -	spinlock_t *ptl;
> >  
> >  	do {
> >  		next = hugetlb_entry_end(h, addr, end);
> > @@ -186,14 +185,14 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
> >  				break;
> >  			continue;
> >  		}
> > -		ptl = huge_pte_lock(h, mm, pte);
> > +		walk->ptl = huge_pte_lock(h, mm, pte);
> >  		/*
> >  		 * Callers should have their own way to handle swap entries
> >  		 * in walk->hugetlb_entry().
> >  		 */
> >  		if (walk->hugetlb_entry)
> >  			err = walk->hugetlb_entry(pte, addr, next, walk);
> > -		spin_unlock(ptl);
> > +		spin_unlock(walk->ptl);
> >  		if (err)
> >  			break;
> >  	} while (addr = next, addr != end);
> > -- 
> > 1.9.3
> > 
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
