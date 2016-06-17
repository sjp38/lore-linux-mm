Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 229716B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:36:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k184so41160561wme.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:36:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x137si23021069wme.107.2016.06.17.04.36.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 04:36:52 -0700 (PDT)
Subject: Re: [PATCH 26/27] mm: vmstat: Replace __count_zone_vm_events with a
 zone id equivalent
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-27-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d5894d08-a25f-ca01-fb2d-9668dcb0f02e@suse.cz>
Date: Fri, 17 Jun 2016 13:36:51 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-27-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> This is partially a preparation patch for more vmstat work but it also
> has the slight advantage that __count_zid_vm_events is cheaper to
> calculate than __count_zone_vm_events().
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/vmstat.h | 5 ++---
>  mm/page_alloc.c        | 2 +-
>  2 files changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 533948c93550..2feab717704d 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -107,9 +107,8 @@ static inline void vm_events_fold_cpu(int cpu)
>  #define count_vm_vmacache_event(x) do {} while (0)
>  #endif
>
> -#define __count_zone_vm_events(item, zone, delta) \
> -		__count_vm_events(item##_NORMAL - ZONE_NORMAL + \
> -		zone_idx(zone), delta)
> +#define __count_zid_vm_events(item, zid, delta) \
> +	__count_vm_events(item##_NORMAL - ZONE_NORMAL + zid, delta)
>
>  /*
>   * Zone and node-based page accounting with per cpu differentials.
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7c6c18a314a1..028d088633c4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2621,7 +2621,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  					  get_pcppage_migratetype(page));
>  	}
>
> -	__count_zone_vm_events(PGALLOC, zone, 1 << order);
> +	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
>  	zone_statistics(preferred_zone, zone, gfp_flags);
>  	local_irq_restore(flags);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
