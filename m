Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 97DE1900015
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 09:47:11 -0400 (EDT)
Received: by wigg3 with SMTP id g3so49142127wig.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 06:47:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si18174082wjr.23.2015.06.10.06.47.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 06:47:09 -0700 (PDT)
Message-ID: <55783FDA.3080700@suse.cz>
Date: Wed, 10 Jun 2015 15:47:06 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 26/36] mm: rework mapcount accounting to enable 4k mapping
 of THPs
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-27-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
> We're going to allow mapping of individual 4k pages of THP compound.
> It means we need to track mapcount on per small page basis.
>
> Straight-forward approach is to use ->_mapcount in all subpages to track
> how many time this subpage is mapped with PMDs or PTEs combined. But
> this is rather expensive: mapping or unmapping of a THP page with PMD
> would require HPAGE_PMD_NR atomic operations instead of single we have
> now.
>
> The idea is to store separately how many times the page was mapped as
> whole -- compound_mapcount. This frees up ->_mapcount in subpages to
> track PTE mapcount.
>
> We use the same approach as with compound page destructor and compound
> order to store compound_mapcount: use space in first tail page,
> ->mapping this time.
>
> Any time we map/unmap whole compound page (THP or hugetlb) -- we
> increment/decrement compound_mapcount. When we map part of compound page
> with PTE we operate on ->_mapcount of the subpage.
>
> page_mapcount() counts both: PTE and PMD mappings of the page.
>
> Basically, we have mapcount for a subpage spread over two counters.
> It makes tricky to detect when last mapcount for a page goes away.
>
> We introduced PageDoubleMap() for this. When we split THP PMD for the
> first time and there's other PMD mapping left we offset up ->_mapcount
> in all subpages by one and set PG_double_map on the compound page.
> These additional references go away with last compound_mapcount.
>
> This approach provides a way to detect when last mapcount goes away on
> per small page basis without introducing new overhead for most common
> cases.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   include/linux/mm.h         | 26 +++++++++++-
>   include/linux/mm_types.h   |  1 +
>   include/linux/page-flags.h | 37 +++++++++++++++++
>   include/linux/rmap.h       |  4 +-
>   mm/debug.c                 |  5 ++-
>   mm/huge_memory.c           |  2 +-
>   mm/hugetlb.c               |  4 +-
>   mm/memory.c                |  2 +-
>   mm/migrate.c               |  2 +-
>   mm/page_alloc.c            | 14 +++++--
>   mm/rmap.c                  | 98 +++++++++++++++++++++++++++++++++++-----------
>   11 files changed, 160 insertions(+), 35 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 31cd5be081cf..22cd540104ec 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -403,6 +403,19 @@ static inline int is_vmalloc_or_module_addr(const void *x)
>
>   extern void kvfree(const void *addr);
>
> +static inline atomic_t *compound_mapcount_ptr(struct page *page)
> +{
> +	return &page[1].compound_mapcount;
> +}
> +
> +static inline int compound_mapcount(struct page *page)
> +{
> +	if (!PageCompound(page))
> +		return 0;
> +	page = compound_head(page);
> +	return atomic_read(compound_mapcount_ptr(page)) + 1;
> +}
> +
>   /*
>    * The atomic page->_mapcount, starts from -1: so that transitions
>    * both from it and to it can be tracked, using atomic_inc_and_test
> @@ -415,8 +428,17 @@ static inline void page_mapcount_reset(struct page *page)
>
>   static inline int page_mapcount(struct page *page)
>   {
> +	int ret;
>   	VM_BUG_ON_PAGE(PageSlab(page), page);
> -	return atomic_read(&page->_mapcount) + 1;
> +
> +	ret = atomic_read(&page->_mapcount) + 1;
> +	if (PageCompound(page)) {
> +		page = compound_head(page);
> +		ret += compound_mapcount(page);

compound_mapcount() means another PageCompound() and compound_head(), 
which you just did. I've tried this to see the effect on a function that 
"calls" (inlines) page_mapcount() once:

-               ret += compound_mapcount(page);
+               ret += atomic_read(compound_mapcount_ptr(page)) + 1;

bloat-o-meter on compaction.o:
add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-59 (-59)
function                                     old     new   delta
isolate_migratepages_block                  1769    1710     -59

> +		if (PageDoubleMap(page))
> +			ret--;
> +	}
> +	return ret;
>   }
>
>   static inline int page_count(struct page *page)
> @@ -898,7 +920,7 @@ static inline pgoff_t page_file_index(struct page *page)
>    */
>   static inline int page_mapped(struct page *page)
>   {
> -	return atomic_read(&(page)->_mapcount) >= 0;
> +	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
>   }
>
>   /*
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 4b51a59160ab..4d182cd14c1f 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -56,6 +56,7 @@ struct page {
>   						 * see PAGE_MAPPING_ANON below.
>   						 */
>   		void *s_mem;			/* slab first object */
> +		atomic_t compound_mapcount;	/* first tail page */
>   	};
>
>   	/* Second double word */
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 74b7cece1dfa..a8d47c1edf6a 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -127,6 +127,9 @@ enum pageflags {
>
>   	/* SLOB */
>   	PG_slob_free = PG_private,
> +
> +	/* THP. Stored in first tail page's flags */
> +	PG_double_map = PG_private_2,

Well, not just THP. Any user of compound pages must make sure not to use 
PG_private_2 on the first tail page. At least where the page is going to 
be user-mapped. And same thing about fields that are in union with 
compound_mapcount. Should that be documented more prominently somewhere? 
I guess there's no such user so far, right?

>   };
>
>   #ifndef __GENERATING_BOUNDS_H

[...]

> @@ -1167,6 +1194,41 @@ out:
>   	mem_cgroup_end_page_stat(memcg);
>   }
>
> +static void page_remove_anon_compound_rmap(struct page *page)
> +{
> +	int i, nr;
> +
> +	if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
> +		return;
> +
> +	/* Hugepages are not counted in NR_ANON_PAGES for now. */
> +	if (unlikely(PageHuge(page)))
> +		return;
> +
> +	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
> +		return;
> +
> +	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> +
> +	if (PageDoubleMap(page)) {
> +		nr = 0;
> +		ClearPageDoubleMap(page);
> +		/*
> +		 * Subpages can be mapped with PTEs too. Check how many of
> +		 * themi are still mapped.
> +		 */
> +		for (i = 0; i < HPAGE_PMD_NR; i++) {
> +			if (atomic_add_negative(-1, &page[i]._mapcount))
> +				nr++;
> +		}
> +	} else {
> +		nr = HPAGE_PMD_NR;
> +	}
> +
> +	if (nr)
> +		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);

-nr as we discussed on IRC.

> +}
> +
>   /**
>    * page_remove_rmap - take down pte mapping from a page
>    * @page:	page to remove mapping from
> @@ -1176,33 +1238,25 @@ out:
>    */
>   void page_remove_rmap(struct page *page, bool compound)
>   {
> -	int nr = compound ? hpage_nr_pages(page) : 1;
> -
>   	if (!PageAnon(page)) {
>   		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
>   		page_remove_file_rmap(page);
>   		return;
>   	}
>
> +	if (compound)
> +		return page_remove_anon_compound_rmap(page);
> +
>   	/* page still mapped by someone else? */
>   	if (!atomic_add_negative(-1, &page->_mapcount))
>   		return;
>
> -	/* Hugepages are not counted in NR_ANON_PAGES for now. */
> -	if (unlikely(PageHuge(page)))
> -		return;
> -
>   	/*
>   	 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
>   	 * these counters are not modified in interrupt context, and
>   	 * pte lock(a spinlock) is held, which implies preemption disabled.
>   	 */
> -	if (compound) {
> -		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> -		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> -	}
> -
> -	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
> +	__dec_zone_page_state(page, NR_ANON_PAGES);
>
>   	if (unlikely(PageMlocked(page)))
>   		clear_page_mlock(page);
> @@ -1643,7 +1697,7 @@ void hugepage_add_anon_rmap(struct page *page,
>   	BUG_ON(!PageLocked(page));
>   	BUG_ON(!anon_vma);
>   	/* address might be in next vma when migration races vma_adjust */
> -	first = atomic_inc_and_test(&page->_mapcount);
> +	first = atomic_inc_and_test(compound_mapcount_ptr(page));
>   	if (first)
>   		__hugepage_set_anon_rmap(page, vma, address, 0);
>   }
> @@ -1652,7 +1706,7 @@ void hugepage_add_new_anon_rmap(struct page *page,
>   			struct vm_area_struct *vma, unsigned long address)
>   {
>   	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> -	atomic_set(&page->_mapcount, 0);
> +	atomic_set(compound_mapcount_ptr(page), 0);
>   	__hugepage_set_anon_rmap(page, vma, address, 1);
>   }
>   #endif /* CONFIG_HUGETLB_PAGE */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
