Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id CF4726B0037
	for <linux-mm@kvack.org>; Tue, 13 May 2014 09:36:28 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so438256eek.13
        for <linux-mm@kvack.org>; Tue, 13 May 2014 06:36:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i49si13178631eem.162.2014.05.13.06.36.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 06:36:27 -0700 (PDT)
Message-ID: <53721FD9.6000106@suse.cz>
Date: Tue, 13 May 2014 15:36:25 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 11/19] mm: page_alloc: Lookup pageblock migratetype with
 IRQs enabled during free
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1399974350-11089-12-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On 05/13/2014 11:45 AM, Mel Gorman wrote:
> get_pageblock_migratetype() is called during free with IRQs disabled. This
> is unnecessary and disables IRQs for longer than necessary.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>

With a comment below,

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/page_alloc.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3948f0a..fcbf637 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -773,9 +773,9 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>   	if (!free_pages_prepare(page, order))
>   		return;
>
> +	migratetype = get_pfnblock_migratetype(page, pfn);
>   	local_irq_save(flags);
>   	__count_vm_events(PGFREE, 1 << order);
> -	migratetype = get_pfnblock_migratetype(page, pfn);
>   	set_freepage_migratetype(page, migratetype);

The line above could be also outside disabled IRQ, no?

>   	free_one_page(page_zone(page), page, pfn, order, migratetype);
>   	local_irq_restore(flags);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
