Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D66DC6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:58:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x43so28127303wrb.9
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 04:58:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p193si7331791wmg.212.2017.07.25.04.58.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 04:58:11 -0700 (PDT)
Date: Tue, 25 Jul 2017 13:58:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memcg: reset low limit during memcg offlining
Message-ID: <20170725115808.GE26723@dhcp22.suse.cz>
References: <20170725114047.4073-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725114047.4073-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 25-07-17 12:40:47, Roman Gushchin wrote:
> A removed memory cgroup with a defined low limit and some belonging
> pagecache has very low chances to be freed.
> 
> If a cgroup has been removed, there is likely no memory pressure inside
> the cgroup, and the pagecache is protected from the external pressure
> by the defined low limit. The cgroup will be freed only after
> the reclaim of all belonging pages. And it will not happen until
> there are any reclaimable memory in the system. That means,
> there is a good chance, that a cold pagecache will reside
> in the memory for an undefined amount of time, wasting
> system resources.
> 
> Fix this issue by zeroing memcg->low during memcg offlining.

Very well spotted! This goes all the way down to low limit inclusion
AFAICS. I would be even tempted to mark it for stable because hiding
some memory from reclaim basically indefinitely is not good. We might
have been just lucky nobody has noticed that yet.

Fixes: 241994ed8649 ("mm: memcontrol: default hierarchy interface for memory")

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index aed11b2d0251..2aa204b8f9fd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4300,6 +4300,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  	}
>  	spin_unlock(&memcg->event_list_lock);
>  
> +	memcg->low = 0;
> +
>  	memcg_offline_kmem(memcg);
>  	wb_memcg_offline(memcg);
>  
> -- 
> 2.13.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
