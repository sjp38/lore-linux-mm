Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 623C66B002B
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 19:02:59 -0400 (EDT)
Message-ID: <50395999.1030004@redhat.com>
Date: Sat, 25 Aug 2012 19:02:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] vmscan: sleep only if backingdev is congested
References: <1345619717-5322-1-git-send-email-minchan@kernel.org> <1345619717-5322-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1345619717-5322-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/22/2012 03:15 AM, Minchan Kim wrote:

> +++ b/mm/vmscan.c
> @@ -2705,8 +2705,16 @@ loop_again:
>   		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
>   			if (has_under_min_watermark_zone)
>   				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
> -			else
> -				congestion_wait(BLK_RW_ASYNC, HZ/10);
> +			else {
> +				for (i = 0; i <= end_zone; i++) {
> +					struct zone *zone = pgdat->node_zones
> +								+ i;
> +					if (!populated_zone(zone))
> +						continue;
> +					wait_iff_congested(zone, BLK_RW_ASYNC,
> +								HZ/10);
> +				}
> +			}
>   		}

Do we really want to wait on every zone?

That could increase the sleep time by a factor 3.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
