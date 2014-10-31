Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 91A09280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 07:42:54 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id w7so5897742lbi.10
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 04:42:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x8si16208960laj.107.2014.10.31.04.42.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 04:42:52 -0700 (PDT)
Message-ID: <545375B2.6050800@suse.cz>
Date: Fri, 31 Oct 2014 12:42:42 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH for v3.18] mm/compaction: skip the range until proper
 target pageblock is met
References: <1414740235-3975-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414740235-3975-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 10/31/2014 08:23 AM, Joonsoo Kim wrote:
> commit 7d49d8868336 ("mm, compaction: reduce zone checking frequency in
> the migration scanner") makes side-effect that change iteration
> range calculation. Before change, block_end_pfn is calculated using
> start_pfn, but, now, blindly add pageblock_nr_pages to previous value.
>
> This cause the problem that isolation_start_pfn is larger than
> block_end_pfn when we isolation the page with more than pageblock order.
> In this case, isolation would be failed due to invalid range parameter.
>
> To prevent this, this patch implement skipping the range until proper
> target pageblock is met. Without this patch, CMA with more than pageblock
> order always fail, but, with this patch, it will succeed.

Well, that's a shame, a third fix you send for my series... And only the 
first was caught before going mainline. I guess -rcX phase is intended 
for this, but how could we do better to catch this in -next?
Anyway, thanks!

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/compaction.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index ec74cf0..212682a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -472,18 +472,20 @@ isolate_freepages_range(struct compact_control *cc,
>   	pfn = start_pfn;
>   	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>
> -	for (; pfn < end_pfn; pfn += isolated,
> -				block_end_pfn += pageblock_nr_pages) {
> +	for (; pfn < end_pfn; block_end_pfn += pageblock_nr_pages) {
>   		/* Protect pfn from changing by isolate_freepages_block */
>   		unsigned long isolate_start_pfn = pfn;
>
>   		block_end_pfn = min(block_end_pfn, end_pfn);
> +		if (pfn >= block_end_pfn)
> +			continue;

Without any comment, this will surely confuse anyone reading the code.
Also I wonder if just recalculating block_end_pfn wouldn't be cheaper 
cpu-wise (not that it matters much?) and easier to understand than 
conditionals. IIRC backward jumps (i.e. continue) are by default 
predicted as "likely" if there's no history in the branch predictor 
cache, but this rather unlikely?

>   		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
>   			break;
>
>   		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
>   						block_end_pfn, &freelist, true);
> +		pfn += isolated;

Moving the "pfn += isolated" here doesn't change anything, or does it? 
Do you just find it nicer?

>   		/*
>   		 * In strict mode, isolate_freepages_block() returns 0 if
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
