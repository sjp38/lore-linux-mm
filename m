Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEC4B44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:17:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r103so24233744wrb.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 06:17:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v67si6486109wma.175.2017.07.10.06.17.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 06:17:32 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
References: <20170710074842.23175-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <841988a5-d3a8-3e1c-5b41-cb07df8dae96@suse.cz>
Date: Mon, 10 Jul 2017 15:16:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170710074842.23175-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 07/10/2017 09:48 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo Handa has reported [1][2][3]that direct reclaimers might get stuck
> in too_many_isolated loop basically for ever because the last few pages
> on the LRU lists are isolated by the kswapd which is stuck on fs locks
> when doing the pageout or slab reclaim. This in turn means that there is
> nobody to actually trigger the oom killer and the system is basically
> unusable.
> 
> too_many_isolated has been introduced by 35cd78156c49 ("vmscan: throttle
> direct reclaim when too many pages are isolated already") to prevent
> from pre-mature oom killer invocations because back then no reclaim
> progress could indeed trigger the OOM killer too early. But since the
> oom detection rework 0a0337e0d1d1 ("mm, oom: rework oom detection")
> the allocation/reclaim retry loop considers all the reclaimable pages
> and throttles the allocation at that layer so we can loosen the direct
> reclaim throttling.
> 
> Make shrink_inactive_list loop over too_many_isolated bounded and returns
> immediately when the situation hasn't resolved after the first sleep.
> Replace congestion_wait by a simple schedule_timeout_interruptible because
> we are not really waiting on the IO congestion in this path.
> 
> Please note that this patch can theoretically cause the OOM killer to
> trigger earlier while there are many pages isolated for the reclaim
> which makes progress only very slowly. This would be obvious from the oom
> report as the number of isolated pages are printed there. If we ever hit
> this should_reclaim_retry should consider those numbers in the evaluation
> in one way or another.
> 
> [1] http://lkml.kernel.org/r/201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp
> [2] http://lkml.kernel.org/r/201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp
> [3] http://lkml.kernel.org/r/201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Let's hope there won't be premature OOM's then.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
