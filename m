Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B154A6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 19:00:55 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so60489198pdb.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 16:00:55 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id l3si5041675pdf.11.2015.08.17.16.00.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 16:00:54 -0700 (PDT)
Received: by paccq16 with SMTP id cq16so74075630pac.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 16:00:54 -0700 (PDT)
Date: Mon, 17 Aug 2015 15:59:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv2 3/4] mm: pack compound_dtor and compound_order into
 one word in struct page
In-Reply-To: <1439824145-25397-4-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1508171555560.2513@eggly.anvils>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com> <1439824145-25397-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 17 Aug 2015, Kirill A. Shutemov wrote:

> The patch halves space occupied by compound_dtor and compound_order in
> struct page.
> 
> For compound_order, it's trivial long -> int/short conversion.
> 
> For get_compound_page_dtor(), we now use hardcoded table for destructor
> lookup and store its index in the struct page instead of direct pointer
> to destructor. It shouldn't be a big trouble to maintain the table: we
> have only two destructor and NULL currently.
> 
> This patch free up one word in tail pages for reuse. This is preparation
> for the next patch.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Well, yes, that is one way of doing it.  But I'd have thought the time
for complicating it, instead of simplifying it with direct calls,
would be when someone adds another destructor.  Up to Andrew.

> ---
>  include/linux/mm.h       | 22 +++++++++++++++++-----
>  include/linux/mm_types.h | 11 +++++++----
>  mm/hugetlb.c             |  8 ++++----
>  mm/page_alloc.c          |  9 ++++++++-
>  4 files changed, 36 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 2e872f92dbac..9c21bbb8875a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -575,18 +575,30 @@ int split_free_page(struct page *page);
>  /*
>   * Compound pages have a destructor function.  Provide a
>   * prototype for that function and accessor functions.
> - * These are _only_ valid on the head of a PG_compound page.
> + * These are _only_ valid on the head of a compound page.
>   */
> +typedef void compound_page_dtor(struct page *);
> +
> +/* Keep the enum in sync with compound_page_dtors array in mm/page_alloc.c */
> +enum {
> +	NULL_COMPOUND_DTOR,
> +	COMPOUND_PAGE_DTOR,
> +	HUGETLB_PAGE_DTOR,
> +	NR_COMPOUND_DTORS,
> +};
> +extern compound_page_dtor * const compound_page_dtors[];
>  
>  static inline void set_compound_page_dtor(struct page *page,
> -						compound_page_dtor *dtor)
> +		unsigned int compound_dtor)
>  {
> -	page[1].compound_dtor = dtor;
> +	VM_BUG_ON_PAGE(compound_dtor >= NR_COMPOUND_DTORS, page);
> +	page[1].compound_dtor = compound_dtor;
>  }
>  
>  static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
>  {
> -	return page[1].compound_dtor;
> +	VM_BUG_ON_PAGE(page[1].compound_dtor >= NR_COMPOUND_DTORS, page);
> +	return compound_page_dtors[page[1].compound_dtor];
>  }
>  
>  static inline int compound_order(struct page *page)
> @@ -596,7 +608,7 @@ static inline int compound_order(struct page *page)
>  	return page[1].compound_order;
>  }
>  
> -static inline void set_compound_order(struct page *page, unsigned long order)
> +static inline void set_compound_order(struct page *page, unsigned int order)
>  {
>  	page[1].compound_order = order;
>  }
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 58620ac7f15c..63cdfe7ec336 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -28,8 +28,6 @@ struct mem_cgroup;
>  		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
>  #define ALLOC_SPLIT_PTLOCKS	(SPINLOCK_SIZE > BITS_PER_LONG/8)
>  
> -typedef void compound_page_dtor(struct page *);
> -
>  /*
>   * Each physical page in the system has a struct page associated with
>   * it to keep track of whatever it is we are using the page for at the
> @@ -145,8 +143,13 @@ struct page {
>  						 */
>  		/* First tail page of compound page */
>  		struct {
> -			compound_page_dtor *compound_dtor;
> -			unsigned long compound_order;
> +#ifdef CONFIG_64BIT
> +			unsigned int compound_dtor;
> +			unsigned int compound_order;
> +#else
> +			unsigned short int compound_dtor;
> +			unsigned short int compound_order;
> +#endif
>  		};
>  
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a8c3087089d8..8ea74caa1fa8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -969,7 +969,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
>  				1 << PG_writeback);
>  	}
>  	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
> -	set_compound_page_dtor(page, NULL);
> +	set_compound_page_dtor(page, NULL_COMPOUND_DTOR);
>  	set_page_refcounted(page);
>  	if (hstate_is_gigantic(h)) {
>  		destroy_compound_gigantic_page(page, huge_page_order(h));
> @@ -1065,7 +1065,7 @@ void free_huge_page(struct page *page)
>  static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
>  {
>  	INIT_LIST_HEAD(&page->lru);
> -	set_compound_page_dtor(page, free_huge_page);
> +	set_compound_page_dtor(page, HUGETLB_PAGE_DTOR);
>  	spin_lock(&hugetlb_lock);
>  	set_hugetlb_cgroup(page, NULL);
>  	h->nr_huge_pages++;
> @@ -1117,7 +1117,7 @@ int PageHuge(struct page *page)
>  		return 0;
>  
>  	page = compound_head(page);
> -	return get_compound_page_dtor(page) == free_huge_page;
> +	return page[1].compound_dtor == HUGETLB_PAGE_DTOR;
>  }
>  EXPORT_SYMBOL_GPL(PageHuge);
>  
> @@ -1314,7 +1314,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>  	if (page) {
>  		INIT_LIST_HEAD(&page->lru);
>  		r_nid = page_to_nid(page);
> -		set_compound_page_dtor(page, free_huge_page);
> +		set_compound_page_dtor(page, HUGETLB_PAGE_DTOR);
>  		set_hugetlb_cgroup(page, NULL);
>  		/*
>  		 * We incremented the global counters already
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index df959b7d6085..beab86e694b2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -208,6 +208,13 @@ static char * const zone_names[MAX_NR_ZONES] = {
>  	 "Movable",
>  };
>  
> +static void free_compound_page(struct page *page);
> +compound_page_dtor * const compound_page_dtors[] = {
> +	NULL,
> +	free_compound_page,
> +	free_huge_page,
> +};
> +
>  int min_free_kbytes = 1024;
>  int user_min_free_kbytes = -1;
>  
> @@ -437,7 +444,7 @@ void prep_compound_page(struct page *page, unsigned long order)
>  	int i;
>  	int nr_pages = 1 << order;
>  
> -	set_compound_page_dtor(page, free_compound_page);
> +	set_compound_page_dtor(page, COMPOUND_PAGE_DTOR);
>  	set_compound_order(page, order);
>  	__SetPageHead(page);
>  	for (i = 1; i < nr_pages; i++) {
> -- 
> 2.5.0
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
