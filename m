Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 17B216B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 05:19:58 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so11727159wib.5
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 02:19:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si18276158wja.154.2015.01.18.02.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 02:19:57 -0800 (PST)
Message-ID: <54BB88CB.7080107@suse.cz>
Date: Sun, 18 Jan 2015 11:19:55 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc: Fix race conditions on getting migratetype
 in buffered_rmqueue
References: <1421572634-3399-1-git-send-email-teawater@gmail.com>
In-Reply-To: <1421572634-3399-1-git-send-email-teawater@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <teawater@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, rientjes@google.com, iamjoonsoo.kim@lge.com, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hui Zhu <zhuhui@xiaomi.com>

On 18.1.2015 10:17, Hui Zhu wrote:
> From: Hui Zhu <zhuhui@xiaomi.com>
>
> To test the patch [1], I use KGTP and a script [2] to show NR_FREE_CMA_PAGES
> and gross of cma_nr_free.  The values are always not same.
> I check the code of pages alloc and free and found that race conditions
> on getting migratetype in buffered_rmqueue.

Can you elaborate? What does this races with, are you dynamically changing
the size of CMA area, or what? The migratetype here is based on which free
list the page was found on. Was it misplaced then? Wasn't Joonsoo's recent
series supposed to eliminate this?

> Then I add move the code of getting migratetype inside the zone->lock
> protection part.

Not just that, you are also reading migratetype from pageblock bitmap
instead of the one embedded in the free page. Which is more expensive
and we already do that more often than we would like to because of CMA.
And it appears to be a wrong fix for a possible misplacement bug. If there's
such misplacement, the wrong stats are not the only problem.

>
> Because this issue will affect system even if the Linux kernel does't
> have [1].  So I post this patch separately.

But we can't test that without [1], right? Maybe the issue is introduced 
by [1]?

>
> This patchset is based on fc7f0dd381720ea5ee5818645f7d0e9dece41cb0.
>
> [1] https://lkml.org/lkml/2015/1/18/28
> [2] https://github.com/teawater/kgtp/blob/dev/add-ons/cma_free.py
>
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> ---
>   mm/page_alloc.c | 11 +++++++----
>   1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7633c50..f3d6922 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1694,11 +1694,12 @@ again:
>   		}
>   		spin_lock_irqsave(&zone->lock, flags);
>   		page = __rmqueue(zone, order, migratetype);
> +		if (page)
> +			migratetype = get_pageblock_migratetype(page);
> +		else
> +			goto failed_unlock;
>   		spin_unlock(&zone->lock);
> -		if (!page)
> -			goto failed;
> -		__mod_zone_freepage_state(zone, -(1 << order),
> -					  get_freepage_migratetype(page));
> +		__mod_zone_freepage_state(zone, -(1 << order), migratetype);
>   	}
>   
>   	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
> @@ -1715,6 +1716,8 @@ again:
>   		goto again;
>   	return page;
>   
> +failed_unlock:
> +	spin_unlock(&zone->lock);
>   failed:
>   	local_irq_restore(flags);
>   	return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
