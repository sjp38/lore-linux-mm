Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC806B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 19:21:42 -0400 (EDT)
Received: by pdrw1 with SMTP id w1so61572266pdr.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 16:21:41 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id oo10si4846468pdb.105.2015.04.01.16.21.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 16:21:41 -0700 (PDT)
Received: by pddn5 with SMTP id n5so69842426pdd.2
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 16:21:41 -0700 (PDT)
Date: Wed, 1 Apr 2015 16:21:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: get page_cache_get_speculative() work on tail
 pages
In-Reply-To: <1427928772-100068-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1504011617300.6431@eggly.anvils>
References: <1427928772-100068-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, 2 Apr 2015, Kirill A. Shutemov wrote:

> Generic RCU fast GUP rely on page_cache_get_speculative() to obtain pin
> on pte-mapped page.  As pointed by Aneesh during review of my compound
> pages refcounting rework, page_cache_get_speculative() would fail on
> pte-mapped tail page, since tail pages always have page->_count == 0.
> 
> That means we would never be able to successfully obtain pin on
> pte-mapped tail page via generic RCU fast GUP.
> 
> But the problem is not exclusive to my patchset. In current kernel some
> drivers (sound, for instance) already map compound pages with PTEs.

Hah, you were sending this as I was replying to the original thread.

Do we care if fast gup fails on some hardware driver's compound pages?
I don't think we do, and it would be better not to complicate the
low-level page_cache_get_speculative for them.

Hugh

> 
> Let's teach page_cache_get_speculative() about tail. We can acquire pin
> by speculatively taking pin on head page and recheck that compound page
> didn't disappear under us. Retry if it did.
> 
> We don't care about THP tail page refcounting -- THP *tail* pages
> shouldn't be found where page_cache_get_speculative() is used --
> pagecache radix tree or page tables.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Steve Capper <steve.capper@linaro.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
>  include/linux/pagemap.h | 31 ++++++++++++++++++++++++++-----
>  1 file changed, 26 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 7c3790764795..573a2510da36 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -142,8 +142,10 @@ void release_pages(struct page **pages, int nr, bool cold);
>   */
>  static inline int page_cache_get_speculative(struct page *page)
>  {
> +	struct page *head_page;
>  	VM_BUG_ON(in_interrupt());
> -
> +retry:
> +	head_page = compound_head_fast(page);
>  #ifdef CONFIG_TINY_RCU
>  # ifdef CONFIG_PREEMPT_COUNT
>  	VM_BUG_ON(!in_atomic());
> @@ -157,11 +159,11 @@ static inline int page_cache_get_speculative(struct page *page)
>  	 * disabling preempt, and hence no need for the "speculative get" that
>  	 * SMP requires.
>  	 */
> -	VM_BUG_ON_PAGE(page_count(page) == 0, page);
> -	atomic_inc(&page->_count);
> +	VM_BUG_ON_PAGE(page_count(head_page) == 0, head_page);
> +	atomic_inc(&head_page->_count);
>  
>  #else
> -	if (unlikely(!get_page_unless_zero(page))) {
> +	if (unlikely(!get_page_unless_zero(head_page))) {
>  		/*
>  		 * Either the page has been freed, or will be freed.
>  		 * In either case, retry here and the caller should
> @@ -170,7 +172,26 @@ static inline int page_cache_get_speculative(struct page *page)
>  		return 0;
>  	}
>  #endif
> -	VM_BUG_ON_PAGE(PageTail(page), page);
> +	/* compound_head_fast() seen PageTail(page) == true */
> +	if (unlikely(head_page != page)) {
> +		/*
> +		 * compound_head_fast() could fetch dangling page->first_page
> +		 * pointer to an old compound page, so recheck that it's still
> +		 * a tail page before returning.
> +		 */
> +		smp_mb__after_atomic();
> +		if (unlikely(!PageTail(page))) {
> +			put_page(head_page);
> +			goto retry;
> +		}
> +		/*
> +		 * Tail page refcounting is only required for THP pages.
> +		 * If page_cache_get_speculative() got called on tail-THP pages
> +		 * something went horribly wrong. We don't have THP in pagecache
> +		 * and we don't map tail-THP to page tables.
> +		 */
> +		VM_BUG_ON_PAGE(compound_tail_refcounted(head_page), head_page);
> +	}
>  
>  	return 1;
>  }
> -- 
> 2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
