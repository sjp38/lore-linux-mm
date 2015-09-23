Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 998916B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 12:42:57 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so78118012wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 09:42:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fo8si1878020wib.39.2015.09.23.09.42.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Sep 2015 09:42:56 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm/compaction: add an is_via_compact_memory helper
 function
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
 <1442404800-4051-3-git-send-email-bywxiaobai@163.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5602D68D.7060902@suse.cz>
Date: Wed, 23 Sep 2015 18:42:53 +0200
MIME-Version: 1.0
In-Reply-To: <1442404800-4051-3-git-send-email-bywxiaobai@163.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>, akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/16/2015 02:00 PM, Yaowei Bai wrote:
> Introduce is_via_compact_memory helper function indicating compacting
> via /proc/sys/vm/compact_memory to improve readability.

Note that it can also be through single node, i.e.
/sys/devices/system/node/node0/compact

is_manual_compaction() would perhaps be better name

> To catch this situation in __compaction_suitable, use order as parameter
> directly instead of using struct compact_control.

That can be fixed as well. Remove the test from __compaction_suitable(),
and in compact_zone(), do something like:
   ret = is_manual_compaction() ? COMPACT_CONTINUE : compaction_suitable()

I think it's better since it's more explicit, but I understand others 
might feel differently.

> This patch has no functional changes.
>
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
> ---
>   mm/compaction.c | 26 ++++++++++++++------------
>   1 file changed, 14 insertions(+), 12 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index c5c627a..a8e6593 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1197,6 +1197,15 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>   	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>   }
>
> +/*
> + * order == -1 is expected when compacting via
> + * /proc/sys/vm/compact_memory
> + */
> +static inline bool is_via_compact_memory(int order)
> +{
> +	return order == -1;
> +}
> +
>   static int __compact_finished(struct zone *zone, struct compact_control *cc,
>   			    const int migratetype)
>   {
> @@ -1223,11 +1232,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>   		return COMPACT_COMPLETE;
>   	}
>
> -	/*
> -	 * order == -1 is expected when compacting via
> -	 * /proc/sys/vm/compact_memory
> -	 */
> -	if (cc->order == -1)
> +	if (is_via_compact_memory(cc->order))
>   		return COMPACT_CONTINUE;
>
>   	/* Compaction run is not finished if the watermark is not met */
> @@ -1290,11 +1295,7 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
>   	int fragindex;
>   	unsigned long watermark;
>
> -	/*
> -	 * order == -1 is expected when compacting via
> -	 * /proc/sys/vm/compact_memory
> -	 */
> -	if (order == -1)
> +	if (is_via_compact_memory(order))
>   		return COMPACT_CONTINUE;
>
>   	watermark = low_wmark_pages(zone);
> @@ -1658,10 +1659,11 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>   		 * this makes sure we compact the whole zone regardless of
>   		 * cached scanner positions.
>   		 */
> -		if (cc->order == -1)
> +		if (is_via_compact_memory(cc->order))
>   			__reset_isolation_suitable(zone);
>
> -		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
> +		if (is_via_compact_memory(cc->order) ||
> +				!compaction_deferred(zone, cc->order))
>   			compact_zone(zone, cc);
>
>   		if (cc->order > 0) {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
