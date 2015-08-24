Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A6C476B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:04:46 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so75066595wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:04:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sc17si32547163wjb.23.2015.08.24.08.04.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 08:04:45 -0700 (PDT)
Subject: Re: [PATCHv3 2/5] zsmalloc: use page->private instead of
 page->first_page
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-3-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DB328B.2010205@suse.cz>
Date: Mon, 24 Aug 2015 17:04:43 +0200
MIME-Version: 1.0
In-Reply-To: <1439976106-137226-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/19/2015 11:21 AM, Kirill A. Shutemov wrote:
> We are going to rework how compound_head() work. It will not use
> page->first_page as we have it now.
>
> The only other user of page->fisrt_page beyond compound pages is

                                ^ typo

> zsmalloc.
>
> Let's use page->private instead of page->first_page here. It occupies
> the same storage space.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/zsmalloc.c | 11 +++++------
>   1 file changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 0a7f81aa2249..a85754e69879 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -16,7 +16,7 @@
>    * struct page(s) to form a zspage.
>    *
>    * Usage of struct page fields:
> - *	page->first_page: points to the first component (0-order) page
> + *	page->private: points to the first component (0-order) page
>    *	page->index (union with page->freelist): offset of the first object
>    *		starting in this page. For the first page, this is
>    *		always 0, so we use this field (aka freelist) to point
> @@ -26,8 +26,7 @@
>    *
>    *	For _first_ page only:
>    *
> - *	page->private (union with page->first_page): refers to the
> - *		component page after the first page
> + *	page->private: refers to the component page after the first page
>    *		If the page is first_page for huge object, it stores handle.
>    *		Look at size_class->huge.
>    *	page->freelist: points to the first free object in zspage.
> @@ -770,7 +769,7 @@ static struct page *get_first_page(struct page *page)
>   	if (is_first_page(page))
>   		return page;
>   	else
> -		return page->first_page;
> +		return (struct page *)page_private(page);
>   }
>
>   static struct page *get_next_page(struct page *page)
> @@ -955,7 +954,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
>   	 * Allocate individual pages and link them together as:
>   	 * 1. first page->private = first sub-page
>   	 * 2. all sub-pages are linked together using page->lru
> -	 * 3. each sub-page is linked to the first page using page->first_page
> +	 * 3. each sub-page is linked to the first page using page->private
>   	 *
>   	 * For each size class, First/Head pages are linked together using
>   	 * page->lru. Also, we set PG_private to identify the first page
> @@ -980,7 +979,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
>   		if (i == 1)
>   			set_page_private(first_page, (unsigned long)page);
>   		if (i >= 1)
> -			page->first_page = first_page;
> +			set_page_private(first_page, (unsigned long)first_page);
>   		if (i >= 2)
>   			list_add(&page->lru, &prev_page->lru);
>   		if (i == class->pages_per_zspage - 1)	/* last page */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
