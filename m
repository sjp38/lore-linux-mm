Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 53FEA6B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 20:10:50 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so169457188pdn.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:10:50 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id cb11si19445675pdb.61.2015.03.22.17.10.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 17:10:49 -0700 (PDT)
Received: by pabxg6 with SMTP id xg6so160319478pab.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:10:49 -0700 (PDT)
Date: Sun, 22 Mar 2015 17:10:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 01/16] mm: consolidate all page-flags helpers in
 <linux/page-flags.h>
In-Reply-To: <1426784902-125149-2-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1503221704150.2680@eggly.anvils>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:

> We have page-flags helper function declarations/definitions spread over
> several header files. Let's consolidate them in <linux/page-flags.h>.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Hugh Dickins <hughd@google.com>

I find this one helpful (assuming it builds fine everywhere).  I've
several times recently found myself wanting to use PageAnon tests at a low
level, and been frustrated by its positioning in linux/mm.h (see my 10/24).

> ---
>  include/linux/hugetlb.h    |  7 ----
>  include/linux/ksm.h        | 17 --------
>  include/linux/mm.h         | 81 --------------------------------------
>  include/linux/page-flags.h | 96 ++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 96 insertions(+), 105 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 7b5785032049..1a782733a420 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -41,8 +41,6 @@ extern int hugetlb_max_hstate __read_mostly;
>  struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
>  void hugepage_put_subpool(struct hugepage_subpool *spool);
>  
> -int PageHuge(struct page *page);
> -
>  void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
>  int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
>  int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> @@ -109,11 +107,6 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  
>  #else /* !CONFIG_HUGETLB_PAGE */
>  
> -static inline int PageHuge(struct page *page)
> -{
> -	return 0;
> -}
> -
>  static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
>  {
>  }
> diff --git a/include/linux/ksm.h b/include/linux/ksm.h
> index 3be6bb18562d..7ae216a39c9e 100644
> --- a/include/linux/ksm.h
> +++ b/include/linux/ksm.h
> @@ -35,18 +35,6 @@ static inline void ksm_exit(struct mm_struct *mm)
>  		__ksm_exit(mm);
>  }
>  
> -/*
> - * A KSM page is one of those write-protected "shared pages" or "merged pages"
> - * which KSM maps into multiple mms, wherever identical anonymous page content
> - * is found in VM_MERGEABLE vmas.  It's a PageAnon page, pointing not to any
> - * anon_vma, but to that page's node of the stable tree.
> - */
> -static inline int PageKsm(struct page *page)
> -{
> -	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
> -				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
> -}
> -
>  static inline struct stable_node *page_stable_node(struct page *page)
>  {
>  	return PageKsm(page) ? page_rmapping(page) : NULL;
> @@ -87,11 +75,6 @@ static inline void ksm_exit(struct mm_struct *mm)
>  {
>  }
>  
> -static inline int PageKsm(struct page *page)
> -{
> -	return 0;
> -}
> -
>  #ifdef CONFIG_MMU
>  static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
>  		unsigned long end, int advice, unsigned long *vm_flags)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6571dd78e984..fb1fc38b01ce 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -494,15 +494,6 @@ static inline int page_count(struct page *page)
>  	return atomic_read(&compound_head(page)->_count);
>  }
>  
> -#ifdef CONFIG_HUGETLB_PAGE
> -extern int PageHeadHuge(struct page *page_head);
> -#else /* CONFIG_HUGETLB_PAGE */
> -static inline int PageHeadHuge(struct page *page_head)
> -{
> -	return 0;
> -}
> -#endif /* CONFIG_HUGETLB_PAGE */
> -
>  static inline bool __compound_tail_refcounted(struct page *page)
>  {
>  	return !PageSlab(page) && !PageHeadHuge(page);
> @@ -571,53 +562,6 @@ static inline void init_page_count(struct page *page)
>  	atomic_set(&page->_count, 1);
>  }
>  
> -/*
> - * PageBuddy() indicate that the page is free and in the buddy system
> - * (see mm/page_alloc.c).
> - *
> - * PAGE_BUDDY_MAPCOUNT_VALUE must be <= -2 but better not too close to
> - * -2 so that an underflow of the page_mapcount() won't be mistaken
> - * for a genuine PAGE_BUDDY_MAPCOUNT_VALUE. -128 can be created very
> - * efficiently by most CPU architectures.
> - */
> -#define PAGE_BUDDY_MAPCOUNT_VALUE (-128)
> -
> -static inline int PageBuddy(struct page *page)
> -{
> -	return atomic_read(&page->_mapcount) == PAGE_BUDDY_MAPCOUNT_VALUE;
> -}
> -
> -static inline void __SetPageBuddy(struct page *page)
> -{
> -	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> -	atomic_set(&page->_mapcount, PAGE_BUDDY_MAPCOUNT_VALUE);
> -}
> -
> -static inline void __ClearPageBuddy(struct page *page)
> -{
> -	VM_BUG_ON_PAGE(!PageBuddy(page), page);
> -	atomic_set(&page->_mapcount, -1);
> -}
> -
> -#define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
> -
> -static inline int PageBalloon(struct page *page)
> -{
> -	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
> -}
> -
> -static inline void __SetPageBalloon(struct page *page)
> -{
> -	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> -	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
> -}
> -
> -static inline void __ClearPageBalloon(struct page *page)
> -{
> -	VM_BUG_ON_PAGE(!PageBalloon(page), page);
> -	atomic_set(&page->_mapcount, -1);
> -}
> -
>  void put_page(struct page *page);
>  void put_pages_list(struct list_head *pages);
>  
> @@ -1006,26 +950,6 @@ void page_address_init(void);
>  #define page_address_init()  do { } while(0)
>  #endif
>  
> -/*
> - * On an anonymous page mapped into a user virtual memory area,
> - * page->mapping points to its anon_vma, not to a struct address_space;
> - * with the PAGE_MAPPING_ANON bit set to distinguish it.  See rmap.h.
> - *
> - * On an anonymous page in a VM_MERGEABLE area, if CONFIG_KSM is enabled,
> - * the PAGE_MAPPING_KSM bit may be set along with the PAGE_MAPPING_ANON bit;
> - * and then page->mapping points, not to an anon_vma, but to a private
> - * structure which KSM associates with that merged page.  See ksm.h.
> - *
> - * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is currently never used.
> - *
> - * Please note that, confusingly, "page_mapping" refers to the inode
> - * address_space which maps the page from disk; whereas "page_mapped"
> - * refers to user virtual address space into which the page is mapped.
> - */
> -#define PAGE_MAPPING_ANON	1
> -#define PAGE_MAPPING_KSM	2
> -#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
> -
>  extern struct address_space *page_mapping(struct page *page);
>  
>  /* Neutral page->mapping pointer to address_space or anon_vma or other */
> @@ -1045,11 +969,6 @@ struct address_space *page_file_mapping(struct page *page)
>  	return page->mapping;
>  }
>  
> -static inline int PageAnon(struct page *page)
> -{
> -	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
> -}
> -
>  /*
>   * Return the pagecache index of the passed page.  Regular pagecache pages
>   * use ->index whereas swapcache pages use ->private
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index c851ff92d5b3..84d10b65cec6 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -289,6 +289,47 @@ PAGEFLAG_FALSE(HWPoison)
>  #define __PG_HWPOISON 0
>  #endif
>  
> +/*
> + * On an anonymous page mapped into a user virtual memory area,
> + * page->mapping points to its anon_vma, not to a struct address_space;
> + * with the PAGE_MAPPING_ANON bit set to distinguish it.  See rmap.h.
> + *
> + * On an anonymous page in a VM_MERGEABLE area, if CONFIG_KSM is enabled,
> + * the PAGE_MAPPING_KSM bit may be set along with the PAGE_MAPPING_ANON bit;
> + * and then page->mapping points, not to an anon_vma, but to a private
> + * structure which KSM associates with that merged page.  See ksm.h.
> + *
> + * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is currently never used.
> + *
> + * Please note that, confusingly, "page_mapping" refers to the inode
> + * address_space which maps the page from disk; whereas "page_mapped"
> + * refers to user virtual address space into which the page is mapped.
> + */
> +#define PAGE_MAPPING_ANON	1
> +#define PAGE_MAPPING_KSM	2
> +#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
> +
> +static inline int PageAnon(struct page *page)
> +{
> +	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
> +}
> +
> +#ifdef CONFIG_KSM
> +/*
> + * A KSM page is one of those write-protected "shared pages" or "merged pages"
> + * which KSM maps into multiple mms, wherever identical anonymous page content
> + * is found in VM_MERGEABLE vmas.  It's a PageAnon page, pointing not to any
> + * anon_vma, but to that page's node of the stable tree.
> + */
> +static inline int PageKsm(struct page *page)
> +{
> +	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
> +				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
> +}
> +#else
> +TESTPAGEFLAG_FALSE(Ksm)
> +#endif
> +
>  u64 stable_page_flags(struct page *page);
>  
>  static inline int PageUptodate(struct page *page)
> @@ -426,6 +467,14 @@ static inline void ClearPageCompound(struct page *page)
>  
>  #endif /* !PAGEFLAGS_EXTENDED */
>  
> +#ifdef CONFIG_HUGETLB_PAGE
> +int PageHuge(struct page *page);
> +int PageHeadHuge(struct page *page);
> +#else
> +TESTPAGEFLAG_FALSE(Huge)
> +TESTPAGEFLAG_FALSE(HeadHuge)
> +#endif
> +
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  /*
>   * PageHuge() only returns true for hugetlbfs pages, but not for
> @@ -480,6 +529,53 @@ static inline int PageTransTail(struct page *page)
>  #endif
>  
>  /*
> + * PageBuddy() indicate that the page is free and in the buddy system
> + * (see mm/page_alloc.c).
> + *
> + * PAGE_BUDDY_MAPCOUNT_VALUE must be <= -2 but better not too close to
> + * -2 so that an underflow of the page_mapcount() won't be mistaken
> + * for a genuine PAGE_BUDDY_MAPCOUNT_VALUE. -128 can be created very
> + * efficiently by most CPU architectures.
> + */
> +#define PAGE_BUDDY_MAPCOUNT_VALUE (-128)
> +
> +static inline int PageBuddy(struct page *page)
> +{
> +	return atomic_read(&page->_mapcount) == PAGE_BUDDY_MAPCOUNT_VALUE;
> +}
> +
> +static inline void __SetPageBuddy(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> +	atomic_set(&page->_mapcount, PAGE_BUDDY_MAPCOUNT_VALUE);
> +}
> +
> +static inline void __ClearPageBuddy(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageBuddy(page), page);
> +	atomic_set(&page->_mapcount, -1);
> +}
> +
> +#define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
> +
> +static inline int PageBalloon(struct page *page)
> +{
> +	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
> +}
> +
> +static inline void __SetPageBalloon(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> +	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
> +}
> +
> +static inline void __ClearPageBalloon(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageBalloon(page), page);
> +	atomic_set(&page->_mapcount, -1);
> +}
> +
> +/*
>   * If network-based swap is enabled, sl*b must keep track of whether pages
>   * were allocated from pfmemalloc reserves.
>   */
> -- 
> 2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
