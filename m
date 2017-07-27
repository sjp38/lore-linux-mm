Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17AB86B0497
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:47:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x43so35630548wrb.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:47:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z37si20547057wrb.382.2017.07.27.07.47.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 07:47:58 -0700 (PDT)
Date: Thu, 27 Jul 2017 16:47:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, memcg: reset memory.low during memcg offlining
Message-ID: <20170727144755.GD31031@dhcp22.suse.cz>
References: <20170726083017.3yzeucmi7lcj46qd@esperanza>
 <20170727130428.28856-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727130428.28856-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 27-07-17 14:04:27, Roman Gushchin wrote:
> A removed memory cgroup with a defined memory.low and some belonging
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
> This problem was fixed earlier by commit fa06235b8eb0
> ("cgroup: reset css on destruction"), but it's not a best way
> to do it, as we can't really reset all limits/counters during
> cgroup offlining.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

my ack for this patch still holds.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d61133e6af99..7b24210596ea 100644
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
