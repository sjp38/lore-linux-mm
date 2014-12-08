Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CB32C6B006E
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 04:06:40 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so4115186wiw.4
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 01:06:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si8851107wib.91.2014.12.08.01.06.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 01:06:38 -0800 (PST)
Message-ID: <54856A1D.9060200@suse.cz>
Date: Mon, 08 Dec 2014 10:06:37 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mm/compaction: fix wrong order check in compact_finished()
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com> <1418022980-4584-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1418022980-4584-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 12/08/2014 08:16 AM, Joonsoo Kim wrote:
> What we want to check here is whether there is highorder freepage
> in buddy list of other migratetype in order to steal it without
> fragmentation. But, current code just checks cc->order which means
> allocation request order. So, this is wrong.
>
> Without this fix, non-movable synchronous compaction below pageblock order
> would not stopped until compaction is complete, because migratetype of most
> pageblocks are movable and high order freepage made by compaction is usually
> on movable type buddy list.
>
> There is some report related to this bug. See below link.
>
> http://www.spinics.net/lists/linux-mm/msg81666.html
>
> Although the issued system still has load spike comes from compaction,
> this makes that system completely stable and responsive according to
> his report.
>
> stress-highalloc test in mmtests with non movable order 7 allocation doesn't
> show any notable difference in allocation success rate, but, it shows more
> compaction success rate and reduced elapsed time.
>
> Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> 18.47 : 28.94
>
> Elapsed time (sec)
> 1429 : 1411
>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/compaction.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index c9ee464..1a5f465 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1105,7 +1105,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>   			return COMPACT_PARTIAL;
>
>   		/* Job done if allocation would set block type */
> -		if (cc->order >= pageblock_order && area->nr_free)
> +		if (order >= pageblock_order && area->nr_free)
>   			return COMPACT_PARTIAL;
>   	}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
