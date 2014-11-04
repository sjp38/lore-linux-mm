Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF5F6B00E0
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 03:46:14 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id hs14so461487lab.5
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 00:46:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id db1si23871123lad.79.2014.11.04.00.46.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 00:46:12 -0800 (PST)
Message-ID: <54589251.2020105@suse.cz>
Date: Tue, 04 Nov 2014 09:46:09 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 for v3.18] mm/compaction: skip the range until proper
 target pageblock is met
References: <1415068649-18040-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1415068649-18040-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 11/04/2014 03:37 AM, Joonsoo Kim wrote:
> commit 7d49d8868336 ("mm, compaction: reduce zone checking frequency in
> the migration scanner") makes side-effect that change iteration
> range calculation. Before change, block_end_pfn is calculated using
> start_pfn, but, now, blindly add pageblock_nr_pages to previous value.
>
> This cause the problem that isolation_start_pfn is larger than
> block_end_pfn when we isolate the page with more than pageblock order.
> In this case, isolation would be failed due to invalid range parameter.
>
> To prevent this, this patch recalculate the range to find valid target
> pageblock. Without this patch, CMA with more than pageblock order always
> fail, but, with this patch, it will succeed.
>
> Changes from v1:
> recalculate the range rather than just skipping to find valid one.
> add code comment.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

(nitpick below)

> ---
>   mm/compaction.c |   10 ++++++++++
>   1 file changed, 10 insertions(+)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index ec74cf0..4f0151c 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -479,6 +479,16 @@ isolate_freepages_range(struct compact_control *cc,
>
>   		block_end_pfn = min(block_end_pfn, end_pfn);
>
> +		/*
> +		 * pfn could pass the block_end_pfn if isolated freepage
> +		 * is more than pageblock order. In this case, we adjust
> +		 * scanning range to right one.
> +		 */
> +		if (pfn >= block_end_pfn) {
> +			block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> +			block_end_pfn = min(block_end_pfn, end_pfn);
> +		}

If you moved this up, there could be just one min(block_end_pfn, 
end_pfn) instance in the code. If the first min() makes block_end_pfn == 
end_pfn and pfn >= block_end_pfn, then pfn >= end_pfn and the loop would 
be terminated already (assuming this was why you left the first min() 
before the new check). But I don't mind if you leave it like this.

> +
>   		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
>   			break;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
