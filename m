Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 88E246B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 03:23:09 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so76616216wic.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 00:23:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b1si21290839wiy.63.2015.10.13.00.23.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Oct 2015 00:23:08 -0700 (PDT)
Subject: Re: [PATCH V2] mm, page_alloc: reserve pageblocks for high-order
 atomic allocations on demand -fix
References: <1444700544-22666-1-git-send-email-yalin.wang2010@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561CB159.8060409@suse.cz>
Date: Tue, 13 Oct 2015 09:23:05 +0200
MIME-Version: 1.0
In-Reply-To: <1444700544-22666-1-git-send-email-yalin.wang2010@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, rientjes@google.com, js1304@gmail.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/13/2015 03:42 AM, yalin wang wrote:
> There is a redundant check and a memory leak introduced by a patch in
> mmotm. This patch removes an unlikely(order) check as we are sure order
> is not zero at the time. It also checks if a page is already allocated
> to avoid a memory leak.
>
> This is a fix to the mmotm patch
> mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch
>
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/page_alloc.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0d6f540..043b691 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2241,13 +2241,13 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>   		spin_lock_irqsave(&zone->lock, flags);
>
>   		page = NULL;
> -		if (unlikely(order) && (alloc_flags & ALLOC_HARDER)) {
> +		if (alloc_flags & ALLOC_HARDER) {
>   			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
>   			if (page)
>   				trace_mm_page_alloc_zone_locked(page, order, migratetype);
>   		}
> -
> -		page = __rmqueue(zone, order, migratetype, gfp_flags);
> +		if (!page)
> +			page = __rmqueue(zone, order, migratetype, gfp_flags);
>   		spin_unlock(&zone->lock);
>   		if (!page)
>   			goto failed;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
