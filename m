Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id ACC7B6B02F4
	for <linux-mm@kvack.org>; Tue, 30 May 2017 08:24:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b84so19415715wmh.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 05:24:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w21si11626314eda.13.2017.05.30.05.24.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 05:24:39 -0700 (PDT)
Date: Tue, 30 May 2017 14:24:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: bump PGSTEAL*/PGSCAN*/ALLOCSTALL counters in memcg
 reclaim
Message-ID: <20170530122436.GE7969@dhcp22.suse.cz>
References: <1496062901-21456-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496062901-21456-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-05-17 14:01:41, Roman Gushchin wrote:
> Historically, PGSTEAL*/PGSCAN*/ALLOCSTALL counters were used to
> account only for global reclaim events, memory cgroup targeted reclaim
> was ignored.
> 
> It doesn't make sense anymore, because the whole reclaim path
> is designed around cgroups. Also, per-cgroup counters can exceed the
> corresponding global counters, what can be confusing.

The whole reclaim is designed around cgroups but the source of the
memory pressure is different. I agree that checking global_reclaim()
for PGSTEAL_KSWAPD doesn't make much sense because we are _always_ in
the global reclaim context but counting ALLOCSTALL even for targetted
memcg reclaim is more confusing than helpful. We usually consider this
counter to see whether the kswapd catches up with the memory demand
and the global direct reclaim is indicator it doesn't. The similar
applies to other counters as well.

So I do not think this is correct. What is the problem you are trying to
solve here anyway.

> So, make PGSTEAL*/PGSCAN*/ALLOCSTALL counters reflect sum of any
> reclaim activity in the system.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/vmscan.c | 15 +++++----------
>  1 file changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7c2a36b..77253b1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1765,13 +1765,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	if (current_is_kswapd()) {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
> +		__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
>  		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
>  				   nr_scanned);
>  	} else {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
> +		__count_vm_events(PGSCAN_DIRECT, nr_scanned);
>  		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
>  				   nr_scanned);
>  	}
> @@ -1786,13 +1784,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	spin_lock_irq(&pgdat->lru_lock);
>  
>  	if (current_is_kswapd()) {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
> +		__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
>  		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
>  				   nr_reclaimed);
>  	} else {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
> +		__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
>  		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
>  				   nr_reclaimed);
>  	}
> @@ -2828,8 +2824,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  retry:
>  	delayacct_freepages_start();
>  
> -	if (global_reclaim(sc))
> -		__count_zid_vm_events(ALLOCSTALL, sc->reclaim_idx, 1);
> +	__count_zid_vm_events(ALLOCSTALL, sc->reclaim_idx, 1);
>  
>  	do {
>  		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
