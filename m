Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81BBD6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 05:33:18 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id tb5so43488715lbb.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 02:33:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id je6si23439908wjb.162.2016.04.25.02.33.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 02:33:17 -0700 (PDT)
Subject: Re: [PATCH 01/28] mm, page_alloc: Only check PageCompound for
 high-order pages
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-2-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571DE45B.2050504@suse.cz>
Date: Mon, 25 Apr 2016 11:33:15 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:58 AM, Mel Gorman wrote:
> order-0 pages by definition cannot be compound so avoid the check in the
> fast path for those pages.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Suggestion to improve below:

> ---
>   mm/page_alloc.c | 25 +++++++++++++++++--------
>   1 file changed, 17 insertions(+), 8 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 59de90d5d3a3..5d205bcfe10d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1024,24 +1024,33 @@ void __meminit reserve_bootmem_region(unsigned long start, unsigned long end)
>
>   static bool free_pages_prepare(struct page *page, unsigned int order)
>   {
> -	bool compound = PageCompound(page);
> -	int i, bad = 0;
> +	int bad = 0;
>
>   	VM_BUG_ON_PAGE(PageTail(page), page);
> -	VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
>
>   	trace_mm_page_free(page, order);
>   	kmemcheck_free_shadow(page, order);
>   	kasan_free_pages(page, order);
>
> +	/*
> +	 * Check tail pages before head page information is cleared to
> +	 * avoid checking PageCompound for order-0 pages.
> +	 */
> +	if (order) {

Sticking unlikely() here results in:

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-30 (-30)
function                                     old     new   delta
free_pages_prepare                           771     741     -30

And from brief comparison of disassembly it really seems it's moved the 
compound handling towards the end of the function, which should be nicer 
for the instruction cache, branch prediction etc. And since this series 
is about microoptimization, I think the extra step is worth it.

> +		bool compound = PageCompound(page);
> +		int i;
> +
> +		VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
> +
> +		for (i = 1; i < (1 << order); i++) {
> +			if (compound)
> +				bad += free_tail_pages_check(page, page + i);
> +			bad += free_pages_check(page + i);
> +		}
> +	}
>   	if (PageAnon(page))
>   		page->mapping = NULL;
>   	bad += free_pages_check(page);
> -	for (i = 1; i < (1 << order); i++) {
> -		if (compound)
> -			bad += free_tail_pages_check(page, page + i);
> -		bad += free_pages_check(page + i);
> -	}
>   	if (bad)
>   		return false;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
