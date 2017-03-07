Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74D786B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 05:17:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c143so115826wmd.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 02:17:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b141si18206595wma.133.2017.03.07.02.17.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 02:17:04 -0800 (PST)
Date: Tue, 7 Mar 2017 11:17:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable
 nodes
Message-ID: <20170307101702.GD28642@dhcp22.suse.cz>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-2-hannes@cmpxchg.org>
 <20170303012609.GA3394@bbox>
 <20170303075954.GA31499@dhcp22.suse.cz>
 <20170306013740.GA8779@bbox>
 <20170306162410.GB2090@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306162410.GB2090@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 06-03-17 11:24:10, Johannes Weiner wrote:
[...]
> >From e126db716926ff353b35f3a6205bd5853e01877b Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 6 Mar 2017 10:53:59 -0500
> Subject: [PATCH] mm: fix 100% CPU kswapd busyloop on unreclaimable nodes fix
> 
> Check kswapd failure against the cumulative nr_reclaimed count, not
> against the count from the lowest priority iteration.
> 
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ddcff8a11c1e..b834b2dd4e19 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3179,9 +3179,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  	count_vm_event(PAGEOUTRUN);
>  
>  	do {
> +		unsigned long nr_reclaimed = sc.nr_reclaimed;
>  		bool raise_priority = true;
>  
> -		sc.nr_reclaimed = 0;
>  		sc.reclaim_idx = classzone_idx;
>  
>  		/*
> @@ -3271,7 +3271,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  		 * Raise priority if scanning rate is too low or there was no
>  		 * progress in reclaiming pages
>  		 */
> -		if (raise_priority || !sc.nr_reclaimed)
> +		nr_reclaimed = sc.nr_reclaimed - nr_reclaimed;
> +		if (raise_priority || !nr_reclaimed)
>  			sc.priority--;
>  	} while (sc.priority >= 1);
>  

I would rather not play with the sc state here. From a quick look at
least 
	/*
	 * Fragmentation may mean that the system cannot be rebalanced for
	 * high-order allocations. If twice the allocation size has been
	 * reclaimed then recheck watermarks only at order-0 to prevent
	 * excessive reclaim. Assume that a process requested a high-order
	 * can direct reclaim/compact.
	 */
	if (sc->order && sc->nr_reclaimed >= compact_gap(sc->order))
		sc->order = 0;

does rely on the value. Wouldn't something like the following be safer?
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c15b2e4c47ca..b731f24fed12 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3183,6 +3183,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		.may_unmap = 1,
 		.may_swap = 1,
 	};
+	bool reclaimable = false;
 	count_vm_event(PAGEOUTRUN);
 
 	do {
@@ -3274,6 +3275,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		if (try_to_freeze() || kthread_should_stop())
 			break;
 
+		if (sc.nr_reclaimed)
+			reclaimable = true;
+
 		/*
 		 * Raise priority if scanning rate is too low or there was no
 		 * progress in reclaiming pages
@@ -3282,7 +3286,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			sc.priority--;
 	} while (sc.priority >= 1);
 
-	if (!sc.nr_reclaimed)
+	if (!reclaimable)
 		pgdat->kswapd_failures++;
 
 out:
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
