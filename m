Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id A8AE46B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:27:21 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so2663742wiw.1
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 05:27:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si3089300wjf.128.2015.01.30.05.27.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 05:27:18 -0800 (PST)
Message-ID: <54CB86B3.1060500@suse.cz>
Date: Fri, 30 Jan 2015 14:27:15 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/4] mm/compaction: fix wrong order check in compact_finished()
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com> <1422621252-29859-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422621252-29859-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

On 01/30/2015 01:34 PM, Joonsoo Kim wrote:
> What we want to check here is whether there is highorder freepage
> in buddy list of other migratetype in order to steal it without
> fragmentation. But, current code just checks cc->order which means
> allocation request order. So, this is wrong.

The bug has been introduced by 1fb3f8ca0e92 ("mm: compaction: capture a suitable
high-order page immediately when it is made available") and survived the later
partial revert 8fb74b9fb2b1.

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
> compaction success rate.
> 
> Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> 18.47 : 28.94
> 
> Cc: <stable@vger.kernel.org>

# v3.7+
Fixes: 1fb3f8ca0e9222535a39b884cb67a34628411b9f

> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

> ---
>  mm/compaction.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index b68736c..4954e19 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1173,7 +1173,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
>  			return COMPACT_PARTIAL;
>  
>  		/* Job done if allocation would set block type */
> -		if (cc->order >= pageblock_order && area->nr_free)
> +		if (order >= pageblock_order && area->nr_free)
>  			return COMPACT_PARTIAL;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
