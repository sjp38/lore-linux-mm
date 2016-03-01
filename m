Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DF6396B0256
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 11:04:08 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id yy13so114184762pab.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 08:04:08 -0800 (PST)
Received: from mail-pa0-f66.google.com (mail-pa0-f66.google.com. [209.85.220.66])
        by mx.google.com with ESMTPS id v88si51281242pfi.243.2016.03.01.08.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 08:04:08 -0800 (PST)
Received: by mail-pa0-f66.google.com with SMTP id a7so9291915pax.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 08:04:07 -0800 (PST)
Date: Tue, 1 Mar 2016 17:04:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: cleanup css_reset callback
Message-ID: <20160301160403.GL9461@dhcp22.suse.cz>
References: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 01-03-16 14:13:12, Vladimir Davydov wrote:
>  - Do not take memcg_limit_mutex for resetting limits - the cgroup
>    cannot be altered from userspace anymore, so no need to protect them.
> 
>  - Use plain page_counter_limit() for resetting ->memory and ->memsw
>    limits instead of mem_cgrouop_resize_* helpers - we enlarge the
>    limits, so no need in special handling.
> 
>  - Reset ->swap and ->tcpmem limits as well.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ae8b81c55685..8615b066b642 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4257,9 +4257,11 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
> -	mem_cgroup_resize_limit(memcg, PAGE_COUNTER_MAX);
> -	mem_cgroup_resize_memsw_limit(memcg, PAGE_COUNTER_MAX);
> -	memcg_update_kmem_limit(memcg, PAGE_COUNTER_MAX);
> +	page_counter_limit(&memcg->memory, PAGE_COUNTER_MAX);
> +	page_counter_limit(&memcg->swap, PAGE_COUNTER_MAX);
> +	page_counter_limit(&memcg->memsw, PAGE_COUNTER_MAX);
> +	page_counter_limit(&memcg->kmem, PAGE_COUNTER_MAX);
> +	page_counter_limit(&memcg->tcpmem, PAGE_COUNTER_MAX);
>  	memcg->low = 0;
>  	memcg->high = PAGE_COUNTER_MAX;
>  	memcg->soft_limit = PAGE_COUNTER_MAX;
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
