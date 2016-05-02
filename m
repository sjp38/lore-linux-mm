Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 540716B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 06:41:24 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so137589416lfq.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 03:41:24 -0700 (PDT)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id w128si16775831lfa.100.2016.05.02.03.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 03:41:22 -0700 (PDT)
Received: by mail-lf0-x22c.google.com with SMTP id j8so50934175lfd.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 03:41:22 -0700 (PDT)
Date: Mon, 2 May 2016 13:41:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160502104119.GA23305@node.shutemov.name>
References: <20160428102051.17d1c728@t450s.home>
 <20160428181726.GA2847@node.shutemov.name>
 <20160428125808.29ad59e5@t450s.home>
 <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429163444.GM11700@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Apr 29, 2016 at 06:34:44PM +0200, Andrea Arcangeli wrote:
> On Fri, Apr 29, 2016 at 10:06:11AM +0300, Kirill A. Shutemov wrote:
> > Hm. I just woke up and haven't got any coffee yet, but I don't why my
> > approach would be worse for performance. Both have the same algorithmic
> > complexity.
> 
> Even before looking at the overall performance, I'm not sure your
> patch is really fixing it all: you didn't touch reuse_swap_page which
> is used by do_wp_page to know if it can call do_wp_page_reuse. Your
> patch would still trigger a COW instead of calling do_wp_page_reuse,
> but it would only happen if the page was pinned after the pmd split,
> which is probably not what the testcase is triggering. My patch
> instead fixed that too.
> 
> total_mapcount returns the wrong value for reuse_swap_page, which is
> probably why you didn't try to use it there.
> 
> The main issue of my patch is that it has a performance downside that
> is page_mapcount becomes expensive for all other usages, which is
> better than breaking vfio but I couldn't use total_mapcount again
> because it counts things wrong in reuse_swap_page.
> 
> Like I said there's room for optimizations so today I tried to
> optimize more stuff...
> 
> From 74f1fd7fab71a2cce0d1796fb38241acde2c1224 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Fri, 29 Apr 2016 01:05:06 +0200
> Subject: [PATCH 1/1] mm: thp: calculate the mapcount correctly for THP pages
>  during WP faults
> 
> This will provide fully accuracy to the mapcount calculation in the
> write protect faults, so page pinning will not get broken by false
> positive copy-on-writes.
> 
> total_mapcount() isn't the right calculation needed in
> reuse_swap_page, so this introduces a page_trans_huge_mapcount() that
> is effectively the full accurate return value for page_mapcount() if
> dealing with Transparent Hugepages, however we only use the
> page_trans_huge_mapcount() during COW faults where it strictly needed,
> due to its higher runtime cost.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/mm.h   |  5 +++++
>  include/linux/swap.h |  3 +--
>  mm/huge_memory.c     | 44 ++++++++++++++++++++++++++++++++++++--------
>  mm/swapfile.c        |  5 +----
>  4 files changed, 43 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8fb3604..c2026a1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -501,11 +501,16 @@ static inline int page_mapcount(struct page *page)
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  int total_mapcount(struct page *page);
> +int page_trans_huge_mapcount(struct page *page);
>  #else
>  static inline int total_mapcount(struct page *page)
>  {
>  	return page_mapcount(page);
>  }
> +static inline int page_trans_huge_mapcount(struct page *page)
> +{
> +	return page_mapcount(page);
> +}
>  #endif
>  
>  static inline struct page *virt_to_head_page(const void *x)
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 2f6478f..905bf8e 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -517,8 +517,7 @@ static inline int swp_swapcount(swp_entry_t entry)
>  	return 0;
>  }
>  
> -#define reuse_swap_page(page) \
> -	(!PageTransCompound(page) && page_mapcount(page) == 1)
> +#define reuse_swap_page(page) (page_trans_huge_mapcount(page) == 1)
>  
>  static inline int try_to_free_swap(struct page *page)
>  {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 06bce0f..6a6d9c0 100644
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
> +	if (page_trans_huge_mapcount(page) == 1) {
>  		pmd_t entry;
>  		entry = pmd_mkyoung(orig_pmd);
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> @@ -3226,6 +3220,40 @@ int total_mapcount(struct page *page)
>  }
>  
>  /*
> + * This calculates accurately how many mappings a transparent hugepage
> + * has (unlike page_mapcount() which isn't fully accurate). This full
> + * accuracy is primarily needed to know if copy-on-write faults can
> + * takeover the page and change the mapping to read-write instead of
> + * copying them. This is different from total_mapcount() too: we must
> + * not count all mappings on the subpages individually, but instead we
> + * must check the highest mapcount any one of the subpages has.
> + *
> + * It would be entirely safe and even more correct to replace
> + * page_mapcount() with page_trans_huge_mapcount(), however we only
> + * use page_trans_huge_mapcount() in the copy-on-write faults where we
> + * need full accuracy to avoid breaking page pinning.
> + */
> +int page_trans_huge_mapcount(struct page *page)
> +{
> +	int i, ret;
> +
> +	VM_BUG_ON_PAGE(PageTail(page), page);
> +
> +	if (likely(!PageCompound(page)))
> +		return atomic_read(&page->_mapcount) + 1;
> +
> +	ret = 0;
> +	if (likely(!PageHuge(page))) {
> +		for (i = 0; i < HPAGE_PMD_NR; i++)
> +			ret = max(ret, atomic_read(&page[i]._mapcount) + 1);
> +		if (PageDoubleMap(page))
> +			ret -= 1;
> +	}
> +	ret += compound_mapcount(page);
> +	return ret;
> +}
> +
> +/*
>   * This function splits huge page into normal pages. @page can point to any
>   * subpage of huge page to split. Split doesn't change the position of @page.
>   *
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 83874ec..984470a 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -930,10 +930,7 @@ int reuse_swap_page(struct page *page)
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	if (unlikely(PageKsm(page)))
>  		return 0;
> -	/* The page is part of THP and cannot be reused */
> -	if (PageTransCompound(page))
> -		return 0;
> -	count = page_mapcount(page);
> +	count = page_trans_huge_mapcount(page);
>  	if (count <= 1 && PageSwapCache(page)) {
>  		count += page_swapcount(page);
>  		if (count == 1 && !PageWriteback(page)) {

I don't think this would work correctly. Let's check one of callers:

static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
		unsigned long address, pte_t *page_table, pmd_t *pmd,
		spinlock_t *ptl, pte_t orig_pte)
	__releases(ptl)
{
...
		if (reuse_swap_page(old_page)) {
			/*
			 * The page is all ours.  Move it to our anon_vma so
			 * the rmap code will not search our parent or siblings.
			 * Protected against the rmap code by the page lock.
			 */
			page_move_anon_rmap(old_page, vma, address);
			unlock_page(old_page);
			return wp_page_reuse(mm, vma, address, page_table, ptl,
					     orig_pte, old_page, 0, 0);
		}

The first thing to notice is that old_page can be a tail page here
therefore page_move_anon_rmap() should be able to handle this after you
patch, which it doesn't.

But I think there's a bigger problem.

Consider the following situation: after split_huge_pmd() we have
pte-mapped THP, fork() comes and now the pages is shared between two
processes. Child process munmap()s one half of the THP page, parent
munmap()s the other half.

IIUC, afther that page_trans_huge_mapcount() would give us 1 as all 4k
subpages have mapcount exactly one. Fault in the child would trigger
do_wp_page() and reuse_swap_page() returns true, which would lead to
page_move_anon_rmap() tranferring the whole compound page to child's
anon_vma. That's not correct.

We should at least avoid page_move_anon_rmap() for compound pages there.


Other thing I would like to discuss is if there's a problem on vfio side.
To me it looks like vfio expects guarantee from get_user_pages() which it
doesn't provide: obtaining pin on the page doesn't guarantee that the page
is going to remain mapped into userspace until the pin is gone.

Even with THP COW regressing fixed, vfio would stay fragile: any
MADV_DONTNEED/fork()/mremap()/whatever what would make vfio expectation
broken.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
