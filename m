Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8B56B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 05:56:22 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so12606046lfc.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 02:56:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tf3si23503838wjc.168.2016.04.25.02.56.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 02:56:20 -0700 (PDT)
Subject: Re: [PATCH 02/28] mm, page_alloc: Use new PageAnonHead helper in the
 free page fast path
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-3-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571DE9C3.8090103@suse.cz>
Date: Mon, 25 Apr 2016 11:56:19 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-3-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 04/15/2016 10:58 AM, Mel Gorman wrote:
> The PageAnon check always checks for compound_head but this is a relatively
> expensive check if the caller already knows the page is a head page. This
> patch creates a helper and uses it in the page free path which only operates
> on head pages.
>
> With this patch and "Only check PageCompound for high-order pages", the
> performance difference on a page allocator microbenchmark is;
>
[...]
>
> There is a sizable boost to the free allocator performance. While there
> is an apparent boost on the allocation side, it's likely a co-incidence
> or due to the patches slightly reducing cache footprint.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

This again highlights the cost of thp rework due to those 
compound_head() calls, and a more general solution would benefit other 
places, but this can always be converted later if such solution happens.

> ---
>   include/linux/page-flags.h | 7 ++++++-
>   mm/page_alloc.c            | 2 +-
>   2 files changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index f4ed4f1b0c77..ccd04ee1ba2d 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -371,10 +371,15 @@ PAGEFLAG(Idle, idle, PF_ANY)
>   #define PAGE_MAPPING_KSM	2
>   #define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
>
> +static __always_inline int PageAnonHead(struct page *page)
> +{
> +	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
> +}
> +
>   static __always_inline int PageAnon(struct page *page)
>   {
>   	page = compound_head(page);
> -	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
> +	return PageAnonHead(page);
>   }
>
>   #ifdef CONFIG_KSM
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5d205bcfe10d..6812de41f698 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1048,7 +1048,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>   			bad += free_pages_check(page + i);
>   		}
>   	}
> -	if (PageAnon(page))
> +	if (PageAnonHead(page))
>   		page->mapping = NULL;
>   	bad += free_pages_check(page);
>   	if (bad)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
