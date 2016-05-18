Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4EC6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:55:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a17so9021480wme.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:55:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n184si9353576wmn.115.2016.05.18.00.55.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 00:55:13 -0700 (PDT)
Subject: Re: [PATCH 28/28] mm, page_alloc: Defer debugging checks of pages
 allocated from the PCP
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
 <20160517064153.GA23930@hori1.linux.bs1.fc.nec.co.jp>
 <573C1F1E.4040201@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573C1FE0.3010500@suse.cz>
Date: Wed, 18 May 2016 09:55:12 +0200
MIME-Version: 1.0
In-Reply-To: <573C1F1E.4040201@suse.cz>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/18/2016 09:51 AM, Vlastimil Babka wrote:
> ----8<----
>  From f52f5e2a7dd65f2814183d8fd254ace43120b828 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Wed, 18 May 2016 09:41:01 +0200
> Subject: [PATCH] mm, page_alloc: prevent infinite loop in buffered_rmqueue()
> 
> In DEBUG_VM kernel, we can hit infinite loop for order == 0 in
> buffered_rmqueue() when check_new_pcp() returns 1, because the bad page is
> never removed from the pcp list. Fix this by removing the page before retrying.
> Also we don't need to check if page is non-NULL, because we simply grab it from
> the list which was just tested for being non-empty.
> 
> Fixes: http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_alloc-defer-debugging-checks-of-freed-pages-until-a-pcp-drain.patch

Wrong.
Fixes: http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_alloc-defer-debugging-checks-of-pages-allocated-from-the-pcp.patch

> Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>   mm/page_alloc.c | 9 +++++----
>   1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8c81e2e7b172..d5b93e5dd697 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2641,11 +2641,12 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>   				page = list_last_entry(list, struct page, lru);
>   			else
>   				page = list_first_entry(list, struct page, lru);
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
>   	} else {
>   		/*
>   		 * We most definitely don't want callers attempting to
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
