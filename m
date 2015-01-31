Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5C25B6B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 02:39:07 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id s11so23988952qcv.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 23:39:07 -0800 (PST)
Received: from BLU004-OMC2S4.hotmail.com (blu004-omc2s4.hotmail.com. [65.55.111.79])
        by mx.google.com with ESMTPS id b50si17168360qga.56.2015.01.30.23.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 30 Jan 2015 23:39:06 -0800 (PST)
Message-ID: <BLU437-SMTP63C0AFB1A443C6C8688808833E0@phx.gbl>
Date: Sat, 31 Jan 2015 15:38:07 +0800
From: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/4] mm/compaction: fix wrong order check in compact_finished()
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com> <1422621252-29859-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422621252-29859-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

Hello,

At 2015/1/30 20:34, Joonsoo Kim wrote:
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
> compaction success rate.
> 
> Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> 18.47 : 28.94
> 
> Cc: <stable@vger.kernel.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

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
