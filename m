Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 146946B0260
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 12:17:47 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id j10so12797810wjb.3
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:17:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si55213933wjk.289.2016.12.14.09.17.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 09:17:45 -0800 (PST)
Subject: Re: [PATCH 2/3] oom, trace: Add oom detection tracepoints
References: <20161214145324.26261-1-mhocko@kernel.org>
 <20161214145324.26261-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dc8350cf-4317-e4f7-7a26-b6a13e48c2eb@suse.cz>
Date: Wed, 14 Dec 2016 18:17:43 +0100
MIME-Version: 1.0
In-Reply-To: <20161214145324.26261-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/14/2016 03:53 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>

I guess the Subject should be more specific to the tracepoint?

> should_reclaim_retry is the central decision point for declaring the
> OOM. It might be really useful to expose data used for this decision
> making when debugging an unexpected oom situations.
>
> Say we have an OOM report:
> [   52.264001] mem_eater invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, order=0, oom_score_adj=0
> [   52.267549] CPU: 3 PID: 3148 Comm: mem_eater Tainted: G        W       4.8.0-oomtrace3-00006-gb21338b386d2 #1024
>
> Now we can check the tracepoint data to see how we have ended up in this
> situation:
>        mem_eater-3148  [003] ....    52.432801: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11134 min_wmark=11084 no_progress_loops=1 wmark_check=1
>        mem_eater-3148  [003] ....    52.433269: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11103 min_wmark=11084 no_progress_loops=1 wmark_check=1
>        mem_eater-3148  [003] ....    52.433712: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11100 min_wmark=11084 no_progress_loops=2 wmark_check=1
>        mem_eater-3148  [003] ....    52.434067: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11097 min_wmark=11084 no_progress_loops=3 wmark_check=1
>        mem_eater-3148  [003] ....    52.434414: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11094 min_wmark=11084 no_progress_loops=4 wmark_check=1
>        mem_eater-3148  [003] ....    52.434761: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11091 min_wmark=11084 no_progress_loops=5 wmark_check=1
>        mem_eater-3148  [003] ....    52.435108: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11087 min_wmark=11084 no_progress_loops=6 wmark_check=1
>        mem_eater-3148  [003] ....    52.435478: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11084 min_wmark=11084 no_progress_loops=7 wmark_check=0
>        mem_eater-3148  [003] ....    52.435478: reclaim_retry_zone: node=0 zone=DMA order=0 reclaimable=0 available=1126 min_wmark=179 no_progress_loops=7 wmark_check=0
>
> From the above we can quickly deduce that the reclaim stopped making
> any progress (see no_progress_loops increased in each round) and while
> there were still some 51 reclaimable pages they couldn't be dropped
> for some reason (vmscan trace points would tell us more about that
> part). available will represent reclaimable + free_pages scaled down per
> no_progress_loops factor. This is essentially an optimistic estimate of
> how much memory we would have when reclaiming everything.  This can be
> compared to min_wmark to get a rought idea but the wmark_check tells the
> result of the watermark check which is more precise (includes lowmem
> reserves, considers the order etc.). As we can see no zone is eligible
> in the end and that is why we have triggered the oom in this situation.
>
> Please note that higher order requests might fail on the wmark_check even
> when there is much more memory available than min_wmark - e.g. when the
> memory is fragmented. A follow up tracepoint will help to debug those
> situations.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
