Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C75D86B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:49:53 -0500 (EST)
Received: by wmuu63 with SMTP id u63so86286146wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 00:49:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f18si25191589wmi.76.2015.11.24.00.49.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 00:49:52 -0800 (PST)
Subject: Re: [PATCH] mm/compaction: __compact_pgdat() code cleanuup
References: <1448346282-5435-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <565424AD.7030808@suse.cz>
Date: Tue, 24 Nov 2015 09:49:49 +0100
MIME-Version: 1.0
In-Reply-To: <1448346282-5435-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Yaowei Bai <bywxiaobai@163.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/24/2015 07:24 AM, Joonsoo Kim wrote:
> This patch uses is_via_compact_memory() to distinguish direct compaction.
> And it also reduces indentation on compaction_defer_reset
> by filtering failure case. There is no functional change.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/compaction.c | 15 +++++++++------
>   1 file changed, 9 insertions(+), 6 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index de3e1e7..2b1a15e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1658,14 +1658,17 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>   				!compaction_deferred(zone, cc->order))
>   			compact_zone(zone, cc);
>
> -		if (cc->order > 0) {
> -			if (zone_watermark_ok(zone, cc->order,
> -						low_wmark_pages(zone), 0, 0))
> -				compaction_defer_reset(zone, cc->order, false);
> -		}
> -
>   		VM_BUG_ON(!list_empty(&cc->freepages));
>   		VM_BUG_ON(!list_empty(&cc->migratepages));
> +
> +		if (is_via_compact_memory(cc->order))
> +			continue;

That's fine.

> +		if (!zone_watermark_ok(zone, cc->order,
> +				low_wmark_pages(zone), 0, 0))
> +			continue;
> +
> +		compaction_defer_reset(zone, cc->order, false);

Here I'd personally find the way of "if(watermark_ok) defer_reset()" 
logic easier to follow.

>   	}
>   }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
