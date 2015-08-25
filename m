Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 33D7F6B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 21:48:56 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so60181854pdb.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:48:55 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id aa9si30333867pbd.56.2015.08.24.18.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 18:48:55 -0700 (PDT)
Received: by padfo6 with SMTP id fo6so6738010pad.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:48:55 -0700 (PDT)
Date: Tue, 25 Aug 2015 10:49:34 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv2 2/4] zsmalloc: use page->private instead of
 page->first_page
Message-ID: <20150825014934.GA532@swordfish>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439824145-25397-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439824145-25397-3-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add Minchan to the thread.

	-ss

On (08/17/15 18:09), Kirill A. Shutemov wrote:
> We are going to rework how compound_head() work. It will not use
> page->first_page as we have it now.
> 
> The only other user of page->fisrt_page beyond compound pages is
> zsmalloc.
> 
> Let's use page->private instead of page->first_page here. It occupies
> the same storage space.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/zsmalloc.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 0a7f81aa2249..a85754e69879 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -16,7 +16,7 @@
>   * struct page(s) to form a zspage.
>   *
>   * Usage of struct page fields:
> - *	page->first_page: points to the first component (0-order) page
> + *	page->private: points to the first component (0-order) page
>   *	page->index (union with page->freelist): offset of the first object
>   *		starting in this page. For the first page, this is
>   *		always 0, so we use this field (aka freelist) to point
> @@ -26,8 +26,7 @@
>   *
>   *	For _first_ page only:
>   *
> - *	page->private (union with page->first_page): refers to the
> - *		component page after the first page
> + *	page->private: refers to the component page after the first page
>   *		If the page is first_page for huge object, it stores handle.
>   *		Look at size_class->huge.
>   *	page->freelist: points to the first free object in zspage.
> @@ -770,7 +769,7 @@ static struct page *get_first_page(struct page *page)
>  	if (is_first_page(page))
>  		return page;
>  	else
> -		return page->first_page;
> +		return (struct page *)page_private(page);
>  }
>  
>  static struct page *get_next_page(struct page *page)
> @@ -955,7 +954,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
>  	 * Allocate individual pages and link them together as:
>  	 * 1. first page->private = first sub-page
>  	 * 2. all sub-pages are linked together using page->lru
> -	 * 3. each sub-page is linked to the first page using page->first_page
> +	 * 3. each sub-page is linked to the first page using page->private
>  	 *
>  	 * For each size class, First/Head pages are linked together using
>  	 * page->lru. Also, we set PG_private to identify the first page
> @@ -980,7 +979,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
>  		if (i == 1)
>  			set_page_private(first_page, (unsigned long)page);
>  		if (i >= 1)
> -			page->first_page = first_page;
> +			set_page_private(first_page, (unsigned long)first_page);
>  		if (i >= 2)
>  			list_add(&page->lru, &prev_page->lru);
>  		if (i == class->pages_per_zspage - 1)	/* last page */
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
