Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4A46B025E
	for <linux-mm@kvack.org>; Wed, 25 May 2016 11:51:25 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n2so30789639wma.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:51:25 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id g69si12736496wme.83.2016.05.25.08.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 08:51:24 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q62so16841361wmg.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:51:24 -0700 (PDT)
Date: Wed, 25 May 2016 17:51:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH][V2] mm: memcontrol: fix the margin computation in
 mem_cgroup_margin
Message-ID: <20160525155122.GK20132@dhcp22.suse.cz>
References: <1464068266-27736-1-git-send-email-roy.qing.li@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464068266-27736-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: roy.qing.li@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com

On Tue 24-05-16 13:37:46, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The margin may be set to the difference value between memory limit and
> memory count firstly. which maybe returned wrongly if memsw.count excess
> memsw.limit, because try_charge forces charging __GFP_NOFAIL allocations,
> which may result in memsw.limit excess. If we are below memory.limit
> and there's nothing to reclaim to reduce memsw.usage, might end up
> looping in try_charge forever.

This is quite hard for me to grasp. What would you say about the
following:
"
mem_cgroup_margin might return memory.limit - memory_count when
the memsw.limit is in excess. This
doesn't happen usually because we do not allow excess on hard limits and
memory.limit <= memsw.limit but __GFP_NOFAIL charges can force the charge
and cause the excess when no memory is really swapable (swap is full or
no anonymous memory is left).
"

> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Michal Hocko <mhocko@suse.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 00981d2..12aaadd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1090,6 +1090,8 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
>  		limit = READ_ONCE(memcg->memsw.limit);
>  		if (count <= limit)
>  			margin = min(margin, limit - count);
> +		else
> +			margin = 0;
>  	}
>  
>  	return margin;
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
