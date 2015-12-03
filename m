Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DF86B6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 01:53:37 -0500 (EST)
Received: by wmvv187 with SMTP id v187so12024594wmv.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 22:53:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f64si3048677wmh.43.2015.12.02.22.53.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 22:53:36 -0800 (PST)
Subject: Re: [PATCH v3] mm/compaction: __compact_pgdat() code cleanuup
References: <1449115845-19409-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <565FE6ED.5010505@suse.cz>
Date: Thu, 3 Dec 2015 07:53:33 +0100
MIME-Version: 1.0
In-Reply-To: <1449115845-19409-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 3.12.2015 5:10, Joonsoo Kim wrote:
> This patch uses is_via_compact_memory() to distinguish compaction
> from sysfs or sysctl. And, this patch also reduces indentation
> on compaction_defer_reset() by filtering these cases first
> before checking watermark.
> 
> There is no functional change.
> 
> Acked-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
> +
> +		if (zone_watermark_ok(zone, cc->order,
> +				low_wmark_pages(zone), 0, 0))
> +			compaction_defer_reset(zone, cc->order, false);
>  	}
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
