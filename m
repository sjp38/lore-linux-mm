Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBD66B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:46:09 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 132so56115988lfz.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:46:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l201si29806731wmd.25.2016.05.30.02.46.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 02:46:07 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: prevent infinite loop in
 buffered_rmqueue()
References: <20160530090154.GM2527@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a4da34ff-cda2-a9a9-d586-277eb6f8797e@suse.cz>
Date: Mon, 30 May 2016 11:46:05 +0200
MIME-Version: 1.0
In-Reply-To: <20160530090154.GM2527@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/30/2016 11:01 AM, Mel Gorman wrote:
> From: Vlastimil Babka <vbabka@suse.cz>
>
> In DEBUG_VM kernel, we can hit infinite loop for order == 0 in
> buffered_rmqueue() when check_new_pcp() returns 1, because the bad page is
> never removed from the pcp list. Fix this by removing the page before retrying.
> Also we don't need to check if page is non-NULL, because we simply grab it from
> the list which was just tested for being non-empty.
>
> Fixes: http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_alloc-defer-debugging-checks-of-freed-pages-until-a-pcp-drain.patch

That was a wrong one, which I corrected later. Also it's no longer 
mmotm. Correction below:

Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages 
allocated from the PCP")

> Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Thanks Mel, I've missed that the patch didn't go in.

> ---
>  mm/page_alloc.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f8f3bfc435ee..bb320cde4d6d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2609,11 +2609,12 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  				page = list_last_entry(list, struct page, lru);
>  			else
>  				page = list_first_entry(list, struct page, lru);
> -		} while (page && check_new_pcp(page));
>
> -		__dec_zone_state(zone, NR_ALLOC_BATCH);
> -		list_del(&page->lru);
> -		pcp->count--;
> +			__dec_zone_state(zone, NR_ALLOC_BATCH);
> +			list_del(&page->lru);
> +			pcp->count--;
> +
> +		} while (check_new_pcp(page));
>  	} else {
>  		/*
>  		 * We most definitely don't want callers attempting to
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
