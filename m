Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 260FB6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:45:20 -0500 (EST)
Received: by pacej9 with SMTP id ej9so54012429pac.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:45:19 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ag6si403668pad.210.2015.11.25.02.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 02:45:19 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so53992151pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:45:19 -0800 (PST)
Date: Wed, 25 Nov 2015 02:45:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/compaction: __compact_pgdat() code cleanuup
In-Reply-To: <1448429172-24961-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1511250242100.32374@chino.kir.corp.google.com>
References: <1448429172-24961-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Yaowei Bai <bywxiaobai@163.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 25 Nov 2015, Joonsoo Kim wrote:

> This patch uses is_via_compact_memory() to distinguish direct compaction.

When I think of "direct compaction", I think of compaction triggered for 
high-order allocations from the page allocator before direct reclaim.  
This is the opposite of being triggered for is_via_compact_memory().

> And it also reduces indentation on compaction_defer_reset
> by filtering failure case. There is no functional change.
> 
> Acked-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/compaction.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index de3e1e7..01b1e5e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1658,14 +1658,15 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>  				!compaction_deferred(zone, cc->order))
>  			compact_zone(zone, cc);
>  
> -		if (cc->order > 0) {
> -			if (zone_watermark_ok(zone, cc->order,
> -						low_wmark_pages(zone), 0, 0))
> -				compaction_defer_reset(zone, cc->order, false);
> -		}
> -
>  		VM_BUG_ON(!list_empty(&cc->freepages));
>  		VM_BUG_ON(!list_empty(&cc->migratepages));
> +
> +		if (is_via_compact_memory(cc->order))
> +			continue;

This will be the third call to is_via_compact_memory() in this function.  
Maybe just do

	const bool sysctl = is_via_compact_memory(cc->order);

early in the function since it won't change during the iteration?  (And 
maybe get rid of that extra newline that already exists at the beginning 
of the iteration?

Otherwise:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
