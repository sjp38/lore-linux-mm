Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 001746B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 06:54:12 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so23088714wic.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 03:54:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z17si10958879wij.0.2015.09.10.03.54.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 03:54:11 -0700 (PDT)
Subject: Re: [PATCHv5 5/7] mm: make compound_head() robust
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1441283758-92774-6-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F16150.502@suse.cz>
Date: Thu, 10 Sep 2015 12:54:08 +0200
MIME-Version: 1.0
In-Reply-To: <1441283758-92774-6-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 09/03/2015 02:35 PM, Kirill A. Shutemov wrote:
> Hugh has pointed that compound_head() call can be unsafe in some
> context. There's one example:
> 
> 	CPU0					CPU1
> 
> isolate_migratepages_block()
>   page_count()
>     compound_head()
>       !!PageTail() == true
> 					put_page()
> 					  tail->first_page = NULL
>       head = tail->first_page
> 					alloc_pages(__GFP_COMP)
> 					   prep_compound_page()
> 					     tail->first_page = head
> 					     __SetPageTail(p);
>       !!PageTail() == true
>     <head == NULL dereferencing>
> 
> The race is pure theoretical. I don't it's possible to trigger it in
> practice. But who knows.
> 
> We can fix the race by changing how encode PageTail() and compound_head()
> within struct page to be able to update them in one shot.
> 
> The patch introduces page->compound_head into third double word block in
> front of compound_dtor and compound_order. Bit 0 encodes PageTail() and
> the rest bits are pointer to head page if bit zero is set.
> 
> The patch moves page->pmd_huge_pte out of word, just in case if an
> architecture defines pgtable_t into something what can have the bit 0
> set.
> 
> hugetlb_cgroup uses page->lru.next in the second tail page to store
> pointer struct hugetlb_cgroup. The patch switch it to use page->private
> in the second tail page instead. The space is free since ->first_page is
> removed from the union.
> 
> The patch also opens possibility to remove HUGETLB_CGROUP_MIN_ORDER
> limitation, since there's now space in first tail page to store struct
> hugetlb_cgroup pointer. But that's out of scope of the patch.
> 
> That means page->compound_head shares storage space with:
> 
>  - page->lru.next;
>  - page->next;
>  - page->rcu_head.next;
> 
> That's too long list to be absolutely sure, but looks like nobody uses
> bit 0 of the word.

Given the discussion about rcu_head, that should warrant some summary here :)

> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -120,7 +120,13 @@ struct page {
>  		};
>  	};
>  
> -	/* Third double word block */
> +	/*
> +	 * Third double word block
> +	 *
> +	 * WARNING: bit 0 of the first word encode PageTail(). That means
> +	 * the rest users of the storage space MUST NOT use the bit to
> +	 * avoid collision and false-positive PageTail().
> +	 */
>  	union {
>  		struct list_head lru;	/* Pageout list, eg. active_list
>  					 * protected by zone->lru_lock !
> @@ -143,12 +149,19 @@ struct page {
>  						 */
>  		/* First tail page of compound page */

"First tail" doesn't apply for compound_head.

> index 097c7a4bfbd9..330377f83ac7 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1686,8 +1686,7 @@ static void __split_huge_page_refcount(struct page *page,
>  				      (1L << PG_unevictable)));
>  		page_tail->flags |= (1L << PG_dirty);
>  
> -		/* clear PageTail before overwriting first_page */
> -		smp_wmb();
> +		clear_compound_head(page_tail);

I would sleep better if this was done before setting all the page->flags above,
previously, PageTail was cleared by the first operation which is
"page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;"
I do realize that it doesn't use WRITE_ONCE, so it might have been theoretically
broken already, if it does matter.

> diff --git a/mm/internal.h b/mm/internal.h
> index 36b23f1e2ca6..89e21a07080a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -61,9 +61,9 @@ static inline void __get_page_tail_foll(struct page *page,
>  	 * speculative page access (like in
>  	 * page_cache_get_speculative()) on tail pages.
>  	 */
> -	VM_BUG_ON_PAGE(atomic_read(&page->first_page->_count) <= 0, page);
> +	VM_BUG_ON_PAGE(atomic_read(&compound_head(page)->_count) <= 0, page);
>  	if (get_page_head)
> -		atomic_inc(&page->first_page->_count);
> +		atomic_inc(&compound_head(page)->_count);

Doing another compound_head() seems like overkill when this code already assumes
PageTail. All callers do it after if (PageTail()) which means they already did
READ_ONCE(page->compound_head) and here they do another one. Potentially with
different result in bit 0, which would be a subtle bug, that could be
interesting to catch with some VM_BUG_ON. I don't know if a direct plain
page->compound_head access here instead of compound_head() would also result in
a re-read, since the previous access did use READ_ONCE(). Maybe it would be best
to reorganize the code here and in the 3 call sites so that the READ_ONCE() used
to determine PageTail also obtains the compound head pointer.

Some of that is probably made moot by your other series, but better let's think
of this series as standalone first.

>  	get_huge_page_tail(page);
>  }
>  
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 1f4446a90cef..4d1a5de9653d 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -787,8 +787,6 @@ static int me_huge_page(struct page *p, unsigned long pfn)
>  #define lru		(1UL << PG_lru)
>  #define swapbacked	(1UL << PG_swapbacked)
>  #define head		(1UL << PG_head)
> -#define tail		(1UL << PG_tail)
> -#define compound	(1UL << PG_compound)
>  #define slab		(1UL << PG_slab)
>  #define reserved	(1UL << PG_reserved)
>  
> @@ -811,12 +809,7 @@ static struct page_state {
>  	 */
>  	{ slab,		slab,		MF_MSG_SLAB,	me_kernel },
>  
> -#ifdef CONFIG_PAGEFLAGS_EXTENDED
>  	{ head,		head,		MF_MSG_HUGE,		me_huge_page },
> -	{ tail,		tail,		MF_MSG_HUGE,		me_huge_page },
> -#else
> -	{ compound,	compound,	MF_MSG_HUGE,		me_huge_page },
> -#endif
>  
>  	{ sc|dirty,	sc|dirty,	MF_MSG_DIRTY_SWAPCACHE,	me_swapcache_dirty },
>  	{ sc|dirty,	sc,		MF_MSG_CLEAN_SWAPCACHE,	me_swapcache_clean },
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c6733cc3cbce..a56ad53ff553 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -424,15 +424,15 @@ out:
>  /*
>   * Higher-order pages are called "compound pages".  They are structured thusly:
>   *
> - * The first PAGE_SIZE page is called the "head page".
> + * The first PAGE_SIZE page is called the "head page" and have PG_head set.
>   *
> - * The remaining PAGE_SIZE pages are called "tail pages".
> + * The remaining PAGE_SIZE pages are called "tail pages". PageTail() is encoded
> + * in bit 0 of page->compound_head. The rest of bits is pointer to head page.
>   *
> - * All pages have PG_compound set.  All tail pages have their ->first_page
> - * pointing at the head page.
> + * The first tail page's ->compound_dtor holds the offset in array of compound
> + * page destructors. See compound_page_dtors.
>   *
> - * The first tail page's ->lru.next holds the address of the compound page's
> - * put_page() function.  Its ->lru.prev holds the order of allocation.
> + * The first tail page's ->compound_order holds the order of allocation.
>   * This usage means that zero-order pages may not be compound.
>   */
>  
> @@ -452,10 +452,7 @@ void prep_compound_page(struct page *page, unsigned long order)
>  	for (i = 1; i < nr_pages; i++) {
>  		struct page *p = page + i;
>  		set_page_count(p, 0);
> -		p->first_page = page;
> -		/* Make sure p->first_page is always valid for PageTail() */
> -		smp_wmb();
> -		__SetPageTail(p);
> +		set_compound_head(p, page);
>  	}
>  }
>  
> @@ -830,17 +827,30 @@ static void free_one_page(struct zone *zone,
>  
>  static int free_tail_pages_check(struct page *head_page, struct page *page)
>  {
> -	if (!IS_ENABLED(CONFIG_DEBUG_VM))
> -		return 0;
> +	int ret = 1;
> +
> +	/*
> +	 * We rely page->lru.next never has bit 0 set, unless the page
> +	 * is PageTail(). Let's make sure that's true even for poisoned ->lru.
> +	 */
> +	BUILD_BUG_ON((unsigned long)LIST_POISON1 & 1);
> +
> +	if (!IS_ENABLED(CONFIG_DEBUG_VM)) {
> +		ret = 0;
> +		goto out;
> +	}
>  	if (unlikely(!PageTail(page))) {
>  		bad_page(page, "PageTail not set", 0);
> -		return 1;
> +		goto out;
>  	}
> -	if (unlikely(page->first_page != head_page)) {
> -		bad_page(page, "first_page not consistent", 0);
> -		return 1;
> +	if (unlikely(compound_head(page) != head_page)) {
> +		bad_page(page, "compound_head not consistent", 0);
> +		goto out;

Same here, although for a DEBUG_VM config only it's not as important.

>  	}
> -	return 0;
> +	ret = 0;
> +out:
> +	clear_compound_head(page);
> +	return ret;
>  }
>  
>  static void __meminit __init_single_page(struct page *page, unsigned long pfn,
> @@ -888,6 +898,8 @@ static void init_reserved_page(unsigned long pfn)
>  #else
>  static inline void init_reserved_page(unsigned long pfn)
>  {
> +	/* Avoid false-positive PageTail() */
> +	INIT_LIST_HEAD(&pfn_to_page(pfn)->lru);
>  }
>  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>  
> diff --git a/mm/swap.c b/mm/swap.c
> index a3a0a2f1f7c3..faa9e1687dea 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -200,7 +200,7 @@ out_put_single:
>  				__put_single_page(page);
>  			return;
>  		}
> -		VM_BUG_ON_PAGE(page_head != page->first_page, page);
> +		VM_BUG_ON_PAGE(page_head != compound_head(page), page);
>  		/*
>  		 * We can release the refcount taken by
>  		 * get_page_unless_zero() now that
> @@ -261,7 +261,7 @@ static void put_compound_page(struct page *page)
>  	 *  Case 3 is possible, as we may race with
>  	 *  __split_huge_page_refcount tearing down a THP page.
>  	 */
> -	page_head = compound_head_by_tail(page);
> +	page_head = compound_head(page);

This is also in a path after PageTail() is true.

>  	if (!__compound_tail_refcounted(page_head))
>  		put_unrefcounted_compound_page(page_head, page);
>  	else
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
