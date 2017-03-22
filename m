Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2086B0343
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:54:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b140so11760376wme.3
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 07:54:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n124si25091436wmd.81.2017.03.22.07.54.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Mar 2017 07:54:22 -0700 (PDT)
Date: Wed, 22 Mar 2017 10:54:15 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
Message-ID: <20170322145413.GA10290@dhcp22.suse.cz>
References: <1490191893-5923-1-git-send-email-ysxie@foxmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1490191893-5923-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <ysxie@foxmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, qiuxishi@huawei.com

On Wed 22-03-17 22:11:33, Yisheng Xie wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
> 
> By reviewing code, I find that when enter do_try_to_free_pages, the
> may_thrash is always clear, and it will retry shrink zones to tap
> cgroup's reserves memory by setting may_thrash when the former
> shrink_zones reclaim nothing.
> 
> However, when memcg is disabled or on legacy hierarchy, or there do not
> have any memcg protected by low limit, it should not do this useless
> retry at all, for we do not have any cgroup's reserves memory to tap,
> and we have already done hard work but made no progress, which as Michal
> pointed out in former version, we are trying hard to control the retry
> logical of page alloctor, and the current additional round of reclaim is
> just lame.
> 
> Therefore, to avoid this unneeded retrying and make code more readable,
> we remove the may_thrash field in scan_control, instead, introduce
> memcg_low_reclaim and memcg_low_skipped, and only retry when
> memcg_low_skipped, by setting memcg_low_reclaim.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

Yes, the naming is much better now. Btw. Acked-by tags should be usually
dropped after the patch is reworked. But I am OK with keeping it in this
particular case.

Thanks!

> ---
> v5:
>  - remove may_thrash field in scan_control, and introduce mem_cgroup_reclaim
>    and memcg_low_skipped to make code more readable. - Johannes
> 
> v4:
>  - add a new field in scan_control named memcg_low_protection to check whether
>    there have any memcg protected by low limit. - Michal
> 
> v3:
>  - rename function may_thrash() to mem_cgroup_thrashed() to avoid confusing.
> 
> v2:
>  - more restrictive condition for retry of shrink_zones (restricting
>    cgroup_disabled=memory boot option and cgroup legacy hierarchy) - Shakeel
> 
>  - add a stub function may_thrash() to avoid compile error or warning.
> 
>  - rename subject from "donot retry shrink zones when memcg is disable"
>    to "more restrictive condition for retry in do_try_to_free_pages"
> 
> Any comment is more than welcome!
> 
> Hi, Andrew,
> Could you please help to drop the v4, thank you so much.
> 
> Thanks
> Yisheng Xie
> 
>  mm/vmscan.c | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bc8031e..d214212 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -97,8 +97,13 @@ struct scan_control {
>  	/* Can pages be swapped as part of reclaim? */
>  	unsigned int may_swap:1;
>  
> -	/* Can cgroups be reclaimed below their normal consumption range? */
> -	unsigned int may_thrash:1;
> +	/*
> +	 * Cgroups are not reclaimed below their configured memory.low,
> +	 * unless we threaten to OOM. If any cgroups are skipped due to
> +	 * memory.low and nothing was reclaimed, go back for memory.low.
> +	 */
> +	unsigned int memcg_low_reclaim:1;
> +	unsigned int memcg_low_skipped:1;
>  
>  	unsigned int hibernation_mode:1;
>  
> @@ -2557,8 +2562,10 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  			unsigned long scanned;
>  
>  			if (mem_cgroup_low(root, memcg)) {
> -				if (!sc->may_thrash)
> +				if (!sc->memcg_low_reclaim) {
> +					sc->memcg_low_skipped = 1;
>  					continue;
> +				}
>  				mem_cgroup_events(memcg, MEMCG_LOW, 1);
>  			}
>  
> @@ -2808,9 +2815,10 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		return 1;
>  
>  	/* Untapped cgroup reserves?  Don't OOM, retry. */
> -	if (!sc->may_thrash) {
> +	if (sc->memcg_low_skipped) {
>  		sc->priority = initial_priority;
> -		sc->may_thrash = 1;
> +		sc->memcg_low_reclaim = 1;
> +		sc->memcg_low_skipped = 0;
>  		goto retry;
>  	}
>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
