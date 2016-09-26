Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88C3E280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:29:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y6so104792781lff.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:29:16 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id m127si9239375lfd.164.2016.09.26.13.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 13:29:14 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id s64so10812000lfs.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:29:14 -0700 (PDT)
Date: Mon, 26 Sep 2016 22:29:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, compaction: restrict fragindex to costly orders
Message-ID: <20160926202912.GC23827@dhcp22.suse.cz>
References: <20160926162025.21555-1-vbabka@suse.cz>
 <20160926162025.21555-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160926162025.21555-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Mon 26-09-16 18:20:25, Vlastimil Babka wrote:
> Fragmentation index and the vm.extfrag_threshold sysctl is meant as a heuristic
> to prevent excessive compaction for costly orders (i.e. THP). It's unlikely to
> make any difference for non-costly orders, especially with the default
> threshold. But we cannot afford any uncertainty for the non-costly orders where
> the only alternative to successful reclaim/compaction is OOM. After the recent
> patches we are guaranteed maximum effort without heuristics from compaction
> before deciding OOM, and fragindex is the last remaining heuristic. Therefore
> skip fragindex altogether for non-costly orders.

It would be nicer to reduce this just to the highest compaction priority
but as your previous attempt shows this adds a lot of code churn.
Not skipping the compaction for these !costly orders might lead to a
higher latency for the allocation due to pointless zone scanning but
considering that an alternative would be the order-0 reclaim which
doesn't guarantee any larger blocks then doing a more targeted approach
sounds quite reasonable to me.

This patch is not really needed to prevent pre-mature OOMs because
compaction_zonelist_suitable doesn't rely on the fragmentation index
after the previous patch but it makes sense to me regardless. The
fagindex was quite an obscure measure and having !costly order easier to
understand is valuable imho.

> Suggested-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/compaction.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 5ff7f801c345..badb92bf14b4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1435,9 +1435,14 @@ enum compact_result compaction_suitable(struct zone *zone, int order,
>  	 * index towards 0 implies failure is due to lack of memory
>  	 * index towards 1000 implies failure is due to fragmentation
>  	 *
> -	 * Only compact if a failure would be due to fragmentation.
> +	 * Only compact if a failure would be due to fragmentation. Also
> +	 * ignore fragindex for non-costly orders where the alternative to
> +	 * a successful reclaim/compaction is OOM. Fragindex and the
> +	 * vm.extfrag_threshold sysctl is meant as a heuristic to prevent
> +	 * excessive compaction for costly orders, but it should not be at the
> +	 * expense of system stability.
>  	 */
> -	if (ret == COMPACT_CONTINUE) {
> +	if (ret == COMPACT_CONTINUE && (order > PAGE_ALLOC_COSTLY_ORDER)) {
>  		fragindex = fragmentation_index(zone, order);
>  		if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
>  			return COMPACT_NOT_SUITABLE_ZONE;
> -- 
> 2.10.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
