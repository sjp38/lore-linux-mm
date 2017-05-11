Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3956B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 05:51:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d127so5129693wmf.15
        for <linux-mm@kvack.org>; Thu, 11 May 2017 02:51:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 42si1571670wrm.49.2017.05.11.02.51.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 May 2017 02:51:40 -0700 (PDT)
Subject: Re: [patch] mm, thp: copying user pages must schedule on collapse
References: <alpine.DEB.2.10.1705101426380.109808@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b139f4cc-50b5-dc5d-76c5-1dffe658cd16@suse.cz>
Date: Thu, 11 May 2017 11:51:37 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1705101426380.109808@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/10/2017 11:27 PM, David Rientjes wrote:
> We have encountered need_resched warnings in __collapse_huge_page_copy()
> while doing {clear,copy}_user_highpage() over HPAGE_PMD_NR source pages.
> 
> mm->mmap_sem is held for write, but the iteration is well bounded.
> 
> Reschedule as needed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/khugepaged.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -612,7 +612,8 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
>  				      spinlock_t *ptl)
>  {
>  	pte_t *_pte;
> -	for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
> +	for (_pte = pte; _pte < pte + HPAGE_PMD_NR;
> +				_pte++, page++, address += PAGE_SIZE) {
>  		pte_t pteval = *_pte;
>  		struct page *src_page;
>  
> @@ -651,9 +652,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
>  			spin_unlock(ptl);
>  			free_page_and_swap_cache(src_page);
>  		}
> -
> -		address += PAGE_SIZE;
> -		page++;
> +		cond_resched();
>  	}
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
