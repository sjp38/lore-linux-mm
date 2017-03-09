Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E44C62808D6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:31:52 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d66so20888656wmi.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:31:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y62si4500014wmb.48.2017.03.09.06.31.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 06:31:51 -0800 (PST)
Date: Thu, 9 Mar 2017 14:31:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170309143148.ewpatb26g6lzsx6a@suse.de>
References: <20170307133057.26182-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170307133057.26182-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 02:30:57PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo Handa has reported [1][2] that direct reclaimers might get stuck
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
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
