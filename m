Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id EDC0F6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:06:08 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so14421738pac.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 00:06:08 -0800 (PST)
Received: from m12-11.163.com (m12-11.163.com. [220.181.12.11])
        by mx.google.com with ESMTP id ol7si977243pbb.105.2015.11.23.23.37.05
        for <linux-mm@kvack.org>;
        Mon, 23 Nov 2015 23:37:06 -0800 (PST)
Date: Tue, 24 Nov 2015 15:36:50 +0800
From: Yaowei Bai <bywxiaobai@163.com>
Subject: Re: [PATCH] mm/compaction: __compact_pgdat() code cleanuup
Message-ID: <20151124073650.GA3184@yaowei-K42JY>
References: <1448346282-5435-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448346282-5435-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, Nov 24, 2015 at 03:24:42PM +0900, Joonsoo Kim wrote:
> This patch uses is_via_compact_memory() to distinguish direct compaction.
> And it also reduces indentation on compaction_defer_reset
> by filtering failure case. There is no functional change.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/compaction.c | 15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index de3e1e7..2b1a15e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1658,14 +1658,17 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
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
> +		if (!zone_watermark_ok(zone, cc->order,
> +				low_wmark_pages(zone), 0, 0))
> +			continue;
> +
> +		compaction_defer_reset(zone, cc->order, false);
>  	}
>  }

This makes more sense,

Acked-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>

>  
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
