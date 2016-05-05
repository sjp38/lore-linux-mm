Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C78DB6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 11:11:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so17829820wme.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:11:14 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id e191si7110256lfe.238.2016.05.05.08.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 08:11:13 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id m64so99431901lfd.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:11:13 -0700 (PDT)
Date: Thu, 5 May 2016 18:11:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160505151110.GA13972@node.shutemov.name>
References: <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502152307.GA12310@redhat.com>
 <20160502160042.GC24419@node.shutemov.name>
 <20160502180307.GB12310@redhat.com>
 <20160504191927.095cdd90@t450s.home>
 <20160505143924.GC28755@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160505143924.GC28755@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 05, 2016 at 04:39:24PM +0200, Andrea Arcangeli wrote:
> Hello Alex,
> 
> On Wed, May 04, 2016 at 07:19:27PM -0600, Alex Williamson wrote:
> > On Mon, 2 May 2016 20:03:07 +0200
> > Andrea Arcangeli <aarcange@redhat.com> wrote:
> > 
> > > On Mon, May 02, 2016 at 07:00:42PM +0300, Kirill A. Shutemov wrote:
> > > > Agreed. I just didn't see the two-refcounts solution.  
> > > 
> > > If you didn't do it already or if you're busy with something else,
> > > I can change the patch to the two refcount solution, which should
> > > restore the old semantics without breaking rmap.
> > 
> > I didn't see any follow-up beyond this nor patches on lkml.  Do we have
> > something we feel confident for posting to v4.6 with a stable backport
> > to v4.5?  Thanks,
> 
> I'm currently testing this:
> 
> From c327b17f4de0c968bb3b9035fe36d80b2c28b2f8 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Fri, 29 Apr 2016 01:05:06 +0200
> Subject: [PATCH 1/3] mm: thp: calculate the mapcount correctly for THP pages
>  during WP faults
> 
> This will provide fully accuracy to the mapcount calculation in the
> write protect faults, so page pinning will not get broken by false
> positive copy-on-writes.
> 
> total_mapcount() isn't the right calculation needed in
> reuse_swap_page(), so this introduces a page_trans_huge_mapcount()
> that is effectively the full accurate return value for page_mapcount()
> if dealing with Transparent Hugepages, however we only use the
> page_trans_huge_mapcount() during COW faults where it strictly needed,
> due to its higher runtime cost.
> 
> This also provide at practical zero cost the total_mapcount
> information which is needed to know if we can still relocate the page
> anon_vma to the local vma. If page_trans_huge_mapcount() returns 1 we
> can reuse the page no matter if it's a pte or a pmd_trans_huge
> triggering the fault, but we can only relocate the page anon_vma to
> the local vma->anon_vma if we're sure it's only this "vma" mapping the
> whole THP physical range.
> 
> Kirill A. Shutemov reported the problem with moving the page anon_vma
> to the local vma->anon_vma in a previous version of this patch.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/mm.h   |  6 +++++
>  include/linux/swap.h |  8 ++++---
>  mm/huge_memory.c     | 67 +++++++++++++++++++++++++++++++++++++++++++++-------
>  mm/memory.c          | 21 +++++++++-------
>  mm/swapfile.c        | 13 +++++-----
>  5 files changed, 89 insertions(+), 26 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a55e5be..4b532d8 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -500,11 +500,17 @@ static inline int page_mapcount(struct page *page)
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  int total_mapcount(struct page *page);
> +int page_trans_huge_mapcount(struct page *page, int *total_mapcount);
>  #else
>  static inline int total_mapcount(struct page *page)
>  {
>  	return page_mapcount(page);
>  }
> +static inline int page_trans_huge_mapcount(struct page *page,
> +					   int *total_mapcount)
> +{
> +	return *total_mapcount = page_mapcount(page);
> +}
>  #endif
>  
>  static inline struct page *virt_to_head_page(const void *x)
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 2b83359..acef20d 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -418,7 +418,7 @@ extern sector_t swapdev_block(int, pgoff_t);
>  extern int page_swapcount(struct page *);
>  extern int swp_swapcount(swp_entry_t entry);
>  extern struct swap_info_struct *page_swap_info(struct page *);
> -extern int reuse_swap_page(struct page *);
> +extern bool reuse_swap_page(struct page *, int *);
>  extern int try_to_free_swap(struct page *);
>  struct backing_dev_info;
>  
> @@ -513,8 +513,10 @@ static inline int swp_swapcount(swp_entry_t entry)
>  	return 0;
>  }
>  
> -#define reuse_swap_page(page) \
> -	(!PageTransCompound(page) && page_mapcount(page) == 1)
> +static inline bool reuse_swap_page(struct page *page, int *total_mapcount)
> +{
> +	return page_trans_huge_mapcount(page, total_mapcount) == 1;
> +}
>  
>  static inline int try_to_free_swap(struct page *page)
>  {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 86f9f8b..d368620 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1298,15 +1298,9 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>  	/*
>  	 * We can only reuse the page if nobody else maps the huge page or it's
> -	 * part. We can do it by checking page_mapcount() on each sub-page, but
> -	 * it's expensive.
> -	 * The cheaper way is to check page_count() to be equal 1: every
> -	 * mapcount takes page reference reference, so this way we can
> -	 * guarantee, that the PMD is the only mapping.
> -	 * This can give false negative if somebody pinned the page, but that's
> -	 * fine.
> +	 * part.
>  	 */
> -	if (page_mapcount(page) == 1 && page_count(page) == 1) {
> +	if (page_trans_huge_mapcount(page, NULL) == 1) {

Hm. How total_mapcount equal to NULL wouldn't lead to NULL-pointer
dereference inside page_trans_huge_mapcount()?

>  		pmd_t entry;
>  		entry = pmd_mkyoung(orig_pmd);
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> @@ -2080,7 +2074,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  		if (pte_write(pteval)) {
>  			writable = true;
>  		} else {
> -			if (PageSwapCache(page) && !reuse_swap_page(page)) {
> +			if (PageSwapCache(page) &&
> +			    !reuse_swap_page(page, NULL)) {

Ditto.

>  				unlock_page(page);
>  				result = SCAN_SWAP_CACHE_PAGE;
>  				goto out;
> @@ -3225,6 +3220,60 @@ int total_mapcount(struct page *page)
>  }
>  
>  /*
> + * This calculates accurately how many mappings a transparent hugepage
> + * has (unlike page_mapcount() which isn't fully accurate). This full
> + * accuracy is primarily needed to know if copy-on-write faults can
> + * takeover the page and change the mapping to read-write instead of
> + * copying them. At the same time this returns the total_mapcount too.
> + *
> + * The return value is telling if the page can be reused as it returns
> + * the highest mapcount any one of the subpages has. If the return
> + * value is one, even if different processes are mapping different
> + * subpages of the transparent hugepage, they can all reuse it,
> + * because each process is reusing a different subpage.
> + *
> + * The total_mapcount is instead counting all virtual mappings of the
> + * subpages. If the total_mapcount is equal to "one", it tells the
> + * caller all mappings belong to the same "mm" and in turn the
> + * anon_vma of the transparent hugepage can become the vma->anon_vma
> + * local one as no other process may be mapping any of the subpages.
> + *
> + * It would be more accurate to replace page_mapcount() with
> + * page_trans_huge_mapcount(), however we only use
> + * page_trans_huge_mapcount() in the copy-on-write faults where we
> + * need full accuracy to avoid breaking page pinning, because
> + * page_trans_huge_mapcount is slower than page_mapcount().
> + */
> +int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
> +{
> +	int i, ret, _total_mapcount, mapcount;
> +
> +	/* hugetlbfs shouldn't call it */
> +	VM_BUG_ON_PAGE(PageHuge(page), page);
> +
> +	if (likely(!PageTransCompound(page)))
> +		return atomic_read(&page->_mapcount) + 1;
> +
> +	page = compound_head(page);
> +
> +	_total_mapcount = ret = 0;
> +	for (i = 0; i < HPAGE_PMD_NR; i++) {
> +		mapcount = atomic_read(&page[i]._mapcount) + 1;
> +		ret = max(ret, mapcount);
> +		_total_mapcount += mapcount;
> +	}
> +	if (PageDoubleMap(page)) {
> +		ret -= 1;
> +		_total_mapcount -= HPAGE_PMD_NR;
> +	}
> +	mapcount = compound_mapcount(page);
> +	ret += mapcount;
> +	_total_mapcount += mapcount;
> +	*total_mapcount = _total_mapcount;
> +	return ret;
> +}
> +
> +/*
>   * This function splits huge page into normal pages. @page can point to any
>   * subpage of huge page to split. Split doesn't change the position of @page.
>   *
> diff --git a/mm/memory.c b/mm/memory.c
> index 93897f2..1589aa4 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2340,6 +2340,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * not dirty accountable.
>  	 */
>  	if (PageAnon(old_page) && !PageKsm(old_page)) {
> +		int total_mapcount;
>  		if (!trylock_page(old_page)) {
>  			get_page(old_page);
>  			pte_unmap_unlock(page_table, ptl);
> @@ -2354,13 +2355,17 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			}
>  			put_page(old_page);
>  		}
> -		if (reuse_swap_page(old_page)) {
> -			/*
> -			 * The page is all ours.  Move it to our anon_vma so
> -			 * the rmap code will not search our parent or siblings.
> -			 * Protected against the rmap code by the page lock.
> -			 */
> -			page_move_anon_rmap(old_page, vma, address);
> +		if (reuse_swap_page(old_page, &total_mapcount)) {
> +			if (total_mapcount == 1) {
> +				/*
> +				 * The page is all ours. Move it to
> +				 * our anon_vma so the rmap code will
> +				 * not search our parent or siblings.
> +				 * Protected against the rmap code by
> +				 * the page lock.
> +				 */
> +				page_move_anon_rmap(old_page, vma, address);

compound_head() is missing, I believe.

> +			}
>  			unlock_page(old_page);
>  			return wp_page_reuse(mm, vma, address, page_table, ptl,
>  					     orig_pte, old_page, 0, 0);
> @@ -2584,7 +2589,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	inc_mm_counter_fast(mm, MM_ANONPAGES);
>  	dec_mm_counter_fast(mm, MM_SWAPENTS);
>  	pte = mk_pte(page, vma->vm_page_prot);
> -	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
> +	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
>  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
>  		flags &= ~FAULT_FLAG_WRITE;
>  		ret |= VM_FAULT_WRITE;
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 83874ec..031713ab 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -922,18 +922,19 @@ out:
>   * to it.  And as a side-effect, free up its swap: because the old content
>   * on disk will never be read, and seeking back there to write new content
>   * later would only waste time away from clustering.
> + *
> + * NOTE: total_mapcount should not be relied upon by the caller if
> + * reuse_swap_page() returns false, but it may be always overwritten
> + * (see the other implementation for CONFIG_SWAP=n).
>   */
> -int reuse_swap_page(struct page *page)
> +bool reuse_swap_page(struct page *page, int *total_mapcount)
>  {
>  	int count;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	if (unlikely(PageKsm(page)))
> -		return 0;
> -	/* The page is part of THP and cannot be reused */
> -	if (PageTransCompound(page))
> -		return 0;
> -	count = page_mapcount(page);
> +		return false;
> +	count = page_trans_huge_mapcount(page, total_mapcount);
>  	if (count <= 1 && PageSwapCache(page)) {
>  		count += page_swapcount(page);
>  		if (count == 1 && !PageWriteback(page)) {
> 
> 
> 
> From b3cd271859f4c8243b58b4b55998fcc9ee0a0988 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Sat, 30 Apr 2016 18:35:34 +0200
> Subject: [PATCH 3/4] mm: thp: microoptimize compound_mapcount()
> 
> compound_mapcount() is only called after PageCompound() has already
> been checked by the caller, so there's no point to check it again. Gcc
> may optimize it away too because it's inline but this will remove the
> runtime check for sure and add it'll add an assert instead.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/mm.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4b532d8..119325d 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -471,8 +471,7 @@ static inline atomic_t *compound_mapcount_ptr(struct page *page)
>  
>  static inline int compound_mapcount(struct page *page)
>  {
> -	if (!PageCompound(page))
> -		return 0;
> +	VM_BUG_ON_PAGE(!PageCompound(page), page);
>  	page = compound_head(page);
>  	return atomic_read(compound_mapcount_ptr(page)) + 1;
>  }
> 
> 
> 
> From a2f1172344b87b1b0e18d07014ee5ab2027fac10 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Thu, 5 May 2016 00:59:27 +0200
> Subject: [PATCH 4/4] mm: thp: split_huge_pmd_address() comment improvement
> 
> Comment is partly wrong, this improves it by including the case of
> split_huge_pmd_address() called by try_to_unmap_one if
> TTU_SPLIT_HUGE_PMD is set.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/huge_memory.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f8f07e4..e716726 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3032,8 +3032,10 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
>  		return;
>  
>  	/*
> -	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
> -	 * materialize from under us.
> +	 * Caller holds the mmap_sem write mode or the anon_vma lock,
> +	 * so a huge pmd cannot materialize from under us (khugepaged
> +	 * holds both the mmap_sem write mode and the anon_vma lock
> +	 * write mode).
>  	 */
>  	__split_huge_pmd(vma, pmd, address, freeze);
>  }
> 
> 
> I also noticed we aren't calling page_move_anon_rmap in
> do_huge_pmd_wp_page when page_trans_huge_mapcount returns 1, that's a
> longstanding inefficiency but it's not a bug. We're not locking the
> page down in the THP COW because we don't have to deal with swapcache,
> and in turn we can't overwrite the page->mapping. I think in practice
> it would be safe anyway because it's an atomic write and no matter if
> the rmap_walk reader sees the value before or after the write, it'll
> still be able to find the pmd_trans_huge during the rmap walk. However
> if page->mapping can change under the reader (i.e. rmap_walk) then the
> reader should use READ_ONCE to access page->mapping (or page->mapping
> should become volatile). Otherwise it'd be a bug with the C standard
> where gcc could get confused in theory (in practice it would work fine
> as we're mostly just dereferencing that page->mapping pointer and not
> using it for switch/case or stuff like that where gcc could use an
> hash). Regardless for robustness it'd be better if we take appropriate
> locking and so we should take the page lock by doing a check if the
> page->mapping is already pointing to the local vma->anon_vma first, if
> not then we should take the page lock on the head THP and call
> page_move_anon_rmap. Because this is a longstanding problem I didn't
> address it yet, and it's only a missing optimization but it'd be nice
> to get that covered too (considering we just worsened a bit the
> optimization in presence of a COW after a pmd split and before the
> physical split).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
