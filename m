Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 715216B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 06:36:46 -0500 (EST)
Received: by lfdl133 with SMTP id l133so191680039lfd.2
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 03:36:45 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id r193si28508171lfe.1.2015.11.30.03.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 03:36:44 -0800 (PST)
Date: Mon, 30 Nov 2015 14:36:28 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 13/13] mm: memcontrol: hook up vmpressure to socket
 pressure
Message-ID: <20151130113628.GB24704@esperanza>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <20151124215940.GB1373@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151124215940.GB1373@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Nov 24, 2015 at 04:59:40PM -0500, Johannes Weiner wrote:
...
> @@ -2396,6 +2396,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  		memcg = mem_cgroup_iter(root, NULL, &reclaim);
>  		do {
>  			unsigned long lru_pages;
> +			unsigned long reclaimed;
>  			unsigned long scanned;
>  			struct lruvec *lruvec;
>  			int swappiness;
> @@ -2408,6 +2409,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  
>  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  			swappiness = mem_cgroup_swappiness(memcg);
> +			reclaimed = sc->nr_reclaimed;
>  			scanned = sc->nr_scanned;
>  
>  			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
> @@ -2418,6 +2420,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  					    memcg, sc->nr_scanned - scanned,
>  					    lru_pages);
>  
> +			/* Record the group's reclaim efficiency */
> +			vmpressure(sc->gfp_mask, memcg, false,
> +				   sc->nr_scanned - scanned,
> +				   sc->nr_reclaimed - reclaimed);
> +

Suppose we have the following cgroup configuration.

A __ B
  \_ C

A is empty (which is natural for the unified hierarchy AFAIU). B has
some workload running in it, and C generates socket pressure. Due to the
socket pressure coming from C we start reclaim in A, which results in
thrashing of B, but we might not put sockets under pressure in A or C,
because vmpressure does not account pages scanned/reclaimed in B when
generating a vmpressure event for A or C. This might result in
aggressive reclaim and thrashing in B w/o generating a signal for C to
stop growing socket buffers.

Do you think such a situation is possible? If so, would it make sense to
switch to post-order walk in shrink_zone and pass sub-tree
scanned/reclaimed stats to vmpressure for each scanned memcg?

Thanks,
Vladimir

>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
>  			 * cgroups to fulfill the overall scan target for the
> @@ -2449,7 +2456,8 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			reclaim_state->reclaimed_slab = 0;
>  		}
>  
> -		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> +		/* Record the subtree's reclaim efficiency */
> +		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
>  			   sc->nr_scanned - nr_scanned,
>  			   sc->nr_reclaimed - nr_reclaimed);
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
