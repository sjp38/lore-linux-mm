Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1EF6B0037
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 20:26:40 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so4420684yho.24
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 17:26:40 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t39si14172613yhp.100.2013.12.16.17.26.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 17:26:39 -0800 (PST)
Message-ID: <52AFA845.3060109@oracle.com>
Date: Tue, 17 Dec 2013 09:26:29 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: munlock: fix a bug where THP tail page is encountered
References: <52AE07B4.4020203@oracle.com> <1387188856-21027-1-git-send-email-vbabka@suse.cz> <1387188856-21027-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1387188856-21027-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, joern@logfs.org, Michel Lespinasse <walken@google.com>, stable@kernel.org

On 12/16/2013 06:14 PM, Vlastimil Babka wrote:
> Since commit ff6a6da60 ("mm: accelerate munlock() treatment of THP pages")
> munlock skips tail pages of a munlocked THP page. However, when the head page
> already has PageMlocked unset, it will not skip the tail pages.
> 
> Commit 7225522bb ("mm: munlock: batch non-THP page isolation and
> munlock+putback using pagevec") has added a PageTransHuge() check which
> contains VM_BUG_ON(PageTail(page)). Sasha Levin found this triggered using
> trinity, on the first tail page of a THP page without PageMlocked flag.
> 
> This patch fixes the issue by skipping tail pages also in the case when
> PageMlocked flag is unset. There is still a possibility of race with THP page
> split between clearing PageMlocked and determining how many pages to skip.
> The race might result in former tail pages not being skipped, which is however
> no longer a bug, as during the skip the PageTail flags are cleared.
> 
> However this race also affects correctness of NR_MLOCK accounting, which is to
> be fixed in a separate patch.
> 
> Cc: stable@kernel.org
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/mlock.c | 24 ++++++++++++++++++------
>  1 file changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index d480cd6..3847b13 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -148,21 +148,30 @@ static void __munlock_isolation_failed(struct page *page)
>   */
>  unsigned int munlock_vma_page(struct page *page)
>  {
> -	unsigned int page_mask = 0;
> +	unsigned int nr_pages;
>  
>  	BUG_ON(!PageLocked(page));
>  
>  	if (TestClearPageMlocked(page)) {
> -		unsigned int nr_pages = hpage_nr_pages(page);
> +		nr_pages = hpage_nr_pages(page);

This line can be put before the if.

>  		mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
> -		page_mask = nr_pages - 1;
>  		if (!isolate_lru_page(page))
>  			__munlock_isolated_page(page);
>  		else
>  			__munlock_isolation_failed(page);
> +	} else {
> +		nr_pages = hpage_nr_pages(page);
>  	}
>  
> -	return page_mask;
> +	/*
> +	 * Regardless of the original PageMlocked flag, we determine nr_pages
> +	 * after touching the flag. This leaves a possible race with a THP page
> +	 * split, such that a whole THP page was munlocked, but nr_pages == 1.
> +	 * Returning a smaller mask due to that is OK, the worst that can
> +	 * happen is subsequent useless scanning of the former tail pages.
> +	 * The NR_MLOCK accounting can however become broken.
> +	 */
> +	return nr_pages - 1;
>  }

Personally, I'd prefer to make munlock_vma_page() return void.
If not please add some comment about the return value in this function's
description also.

>  
>  /**
> @@ -440,7 +449,8 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>  
>  	while (start < end) {
>  		struct page *page = NULL;
> -		unsigned int page_mask, page_increm;
> +		unsigned int page_mask;
> +		unsigned long page_increm;
>  		struct pagevec pvec;
>  		struct zone *zone;
>  		int zoneid;
> @@ -490,7 +500,9 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>  				goto next;
>  			}
>  		}
> -		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
> +		/* It's a bug to munlock in the middle of a THP page */
> +		VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
> +		page_increm = 1 + page_mask;
>  		start += page_increm * PAGE_SIZE;
>  next:
>  		cond_resched();
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
