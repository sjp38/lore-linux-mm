Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2EEF6B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 21:54:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j79so16655132pfj.9
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:54:49 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id l125si912965pgl.437.2017.07.19.18.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 18:54:48 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id o88so6428777pfk.3
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:54:48 -0700 (PDT)
Date: Wed, 19 Jul 2017 18:54:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
In-Reply-To: <20170710074842.23175-1-mhocko@kernel.org>
Message-ID: <alpine.LSU.2.11.1707191823190.2445@eggly.anvils>
References: <20170710074842.23175-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 10 Jul 2017, Michal Hocko wrote:

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
> ---
> Hi,
> I am resubmitting this patch previously sent here
> http://lkml.kernel.org/r/20170307133057.26182-1-mhocko@kernel.org.
> 
> Johannes and Rik had some concerns that this could lead to premature
> OOM kills. I agree with them that we need a better throttling
> mechanism. Until now we didn't give the issue described above a high
> priority because it usually required a really insane workload to
> trigger. But it seems that the issue can be reproduced also without
> having an insane number of competing threads [3].
> 
> Moreover, the issue also triggers very often while testing heavy memory
> pressure and so prevents further development of hardening of that area
> (http://lkml.kernel.org/r/201707061948.ICJ18763.tVFOQFOHMJFSLO@I-love.SAKURA.ne.jp).
> Tetsuo hasn't seen any negative effect of this patch in his oom stress
> tests so I think we should go with this simple patch for now and think
> about something more robust long term.
> 
> That being said I suggest merging this (after spending the full release
> cycle in linux-next) for the time being until we come up with a more
> clever solution.
> 
>  mm/vmscan.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c15b2e4c47ca..4ae069060ae5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1713,9 +1713,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> +	bool stalled = false;
>  
>  	while (unlikely(too_many_isolated(pgdat, file, sc))) {
> -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		if (stalled)
> +			return 0;
> +
> +		/* wait a bit for the reclaimer. */
> +		schedule_timeout_interruptible(HZ/10);
> +		stalled = true;
>  
>  		/* We are about to die and free our memory. Return now. */
>  		if (fatal_signal_pending(current))
> -- 

You probably won't welcome getting into alternatives at this late stage;
but after hacking around it one way or another because of its pointless
lockups, I lost patience with that too_many_isolated() loop a few months
back (on realizing the enormous number of pages that may be isolated via
migrate_pages(2)), and we've been running nicely since with something like:

	bool got_mutex = false;

	if (unlikely(too_many_isolated(pgdat, file, sc))) {
		if (mutex_lock_killable(&pgdat->too_many_isolated))
			return SWAP_CLUSTER_MAX;
		got_mutex = true;
	}
	...
	if (got_mutex)
		mutex_unlock(&pgdat->too_many_isolated);

Using a mutex to provide the intended throttling, without an infinite
loop or an arbitrary delay; and without having to worry (as we often did)
about whether those numbers in too_many_isolated() are really appropriate.
No premature OOMs complained of yet.

But that was on a different kernel, and there I did have to make sure
that PF_MEMALLOC always prevented us from nesting: I'm not certain of
that in the current kernel (but do remember Johannes changing the memcg
end to make it use PF_MEMALLOC too).  I offer the preview above, to see
if you're interested in that alternative: if you are, then I'll go ahead
and make it into an actual patch against v4.13-rc.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
