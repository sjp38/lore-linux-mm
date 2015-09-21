Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 50E616B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:19:52 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so119535803wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:19:52 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id gg17si32250266wjc.5.2015.09.21.09.19.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 09:19:51 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so123249902wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:19:50 -0700 (PDT)
Date: Mon, 21 Sep 2015 18:19:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm/compaction: add an is_via_compact_memory helper
 function
Message-ID: <20150921161949.GG19811@dhcp22.suse.cz>
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
 <1442404800-4051-3-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442404800-4051-3-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 16-09-15 20:00:00, Yaowei Bai wrote:
> Introduce is_via_compact_memory helper function indicating compacting
> via /proc/sys/vm/compact_memory to improve readability.
> 
> To catch this situation in __compaction_suitable, use order as parameter
> directly instead of using struct compact_control.
> 
> This patch has no functional changes.

This is a similar case as for the sysrq_oom. I do not like the name that
much though. I am not familiar with the compaction too much to help you
with a better name, unfortunatelly. Maybe is_global_compaction()...

> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
> ---
>  mm/compaction.c | 26 ++++++++++++++------------
>  1 file changed, 14 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index c5c627a..a8e6593 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1197,6 +1197,15 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }
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
>  static int __compact_finished(struct zone *zone, struct compact_control *cc,
>  			    const int migratetype)
>  {
> @@ -1223,11 +1232,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>  		return COMPACT_COMPLETE;
>  	}
>  
> -	/*
> -	 * order == -1 is expected when compacting via
> -	 * /proc/sys/vm/compact_memory
> -	 */
> -	if (cc->order == -1)
> +	if (is_via_compact_memory(cc->order))
>  		return COMPACT_CONTINUE;
>  
>  	/* Compaction run is not finished if the watermark is not met */
> @@ -1290,11 +1295,7 @@ static unsigned long __compaction_suitable(struct zone *zone, int order,
>  	int fragindex;
>  	unsigned long watermark;
>  
> -	/*
> -	 * order == -1 is expected when compacting via
> -	 * /proc/sys/vm/compact_memory
> -	 */
> -	if (order == -1)
> +	if (is_via_compact_memory(order))
>  		return COMPACT_CONTINUE;
>  
>  	watermark = low_wmark_pages(zone);
> @@ -1658,10 +1659,11 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>  		 * this makes sure we compact the whole zone regardless of
>  		 * cached scanner positions.
>  		 */
> -		if (cc->order == -1)
> +		if (is_via_compact_memory(cc->order))
>  			__reset_isolation_suitable(zone);
>  
> -		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
> +		if (is_via_compact_memory(cc->order) ||
> +				!compaction_deferred(zone, cc->order))
>  			compact_zone(zone, cc);
>  
>  		if (cc->order > 0) {
> -- 
> 1.9.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
