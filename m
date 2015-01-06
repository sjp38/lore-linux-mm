Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 990BF6B00DE
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 12:43:52 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so5850115wiw.9
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 09:43:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si25832302wix.30.2015.01.06.09.43.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 09:43:51 -0800 (PST)
Message-ID: <54AC1ED5.2050101@suse.cz>
Date: Tue, 06 Jan 2015 18:43:49 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc.c: drop dead destroy_compound_page()
References: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org
Cc: aarcange@redhat.com, linux-mm@kvack.org

On 01/05/2015 12:46 PM, Kirill A. Shutemov wrote:
> The only caller is __free_one_page(). By the time we should have
> page->flags to be cleared already:
> 
>  - for 0-order pages though PCP list:

Can there even be a 0-order compound page? I guess not, so this is just confusing?

Otherwise it seems like you are right and it's a dead code to be removed. I
tried to check history to see when it was actually needed, but seems it predates
git.

Acked-by: Vlastimil Babka <vbabka@suse.cz>


> 	free_hot_cold_page()
> 		free_pages_prepare()
> 			free_pages_check()
> 				page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> 		<put the page to PCP list>
> 
> 	free_pcppages_bulk()
> 		page = <withdraw pages from PCP list>
> 		__free_one_page(page)
> 
>  - for non-0-order pages:
> 	__free_pages_ok()
> 		free_pages_prepare()
> 			free_pages_check()
> 				page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> 		free_one_page()
> 			__free_one_page()
> 
> So there's no way PageCompound() will return true in __free_one_page().
> Let's remove dead destroy_compound_page() and put assert for page->flags
> there instead.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/page_alloc.c | 35 +----------------------------------
>  1 file changed, 1 insertion(+), 34 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1bb65e6f48dd..5e75380dacab 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -381,36 +381,6 @@ void prep_compound_page(struct page *page, unsigned long order)
>  	}
>  }
>  
> -/* update __split_huge_page_refcount if you change this function */
> -static int destroy_compound_page(struct page *page, unsigned long order)
> -{
> -	int i;
> -	int nr_pages = 1 << order;
> -	int bad = 0;
> -
> -	if (unlikely(compound_order(page) != order)) {
> -		bad_page(page, "wrong compound order", 0);
> -		bad++;
> -	}
> -
> -	__ClearPageHead(page);
> -
> -	for (i = 1; i < nr_pages; i++) {
> -		struct page *p = page + i;
> -
> -		if (unlikely(!PageTail(p))) {
> -			bad_page(page, "PageTail not set", 0);
> -			bad++;
> -		} else if (unlikely(p->first_page != page)) {
> -			bad_page(page, "first_page not consistent", 0);
> -			bad++;
> -		}
> -		__ClearPageTail(p);
> -	}
> -
> -	return bad;
> -}
> -
>  static inline void prep_zero_page(struct page *page, unsigned int order,
>  							gfp_t gfp_flags)
>  {
> @@ -613,10 +583,7 @@ static inline void __free_one_page(struct page *page,
>  	int max_order = MAX_ORDER;
>  
>  	VM_BUG_ON(!zone_is_initialized(zone));
> -
> -	if (unlikely(PageCompound(page)))
> -		if (unlikely(destroy_compound_page(page, order)))
> -			return;
> +	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
>  
>  	VM_BUG_ON(migratetype == -1);
>  	if (is_migrate_isolate(migratetype)) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
