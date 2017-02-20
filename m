Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73F6B6B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 08:01:27 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so10140630wmv.5
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 05:01:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b203si12236063wmf.125.2017.02.20.05.01.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 05:01:26 -0800 (PST)
Date: Mon, 20 Feb 2017 14:01:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/cgroup: avoid panic when init with low memory
Message-ID: <20170220130123.GI2431@dhcp22.suse.cz>
References: <1487154969-6704-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487154969-6704-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 15-02-17 11:36:09, Laurent Dufour wrote:
> The system may panic when initialisation is done when almost all the
> memory is assigned to the huge pages using the kernel command line
> parameter hugepage=xxxx. Panic may occur like this:

I am pretty sure the system might blow up in many other ways when you
misconfigure it and pull basically all the memory out. Anyway...

[...]
 
> This is a chicken and egg issue where the kernel try to get free
> memory when allocating per node data in mem_cgroup_init(), but in that
> path mem_cgroup_soft_limit_reclaim() is called which assumes that
> these data are allocated.
> 
> As mem_cgroup_soft_limit_reclaim() is best effort, it should return
> when these data are not yet allocated.

... this makes some sense. Especially when there is no soft limit
configured. So this is a good step. I would just like to ask you to go
one step further. Can we make the whole soft reclaim thing uninitialized
until the soft limit is actually set? Soft limit is not used in cgroup
v2 at all and I would strongly discourage it in v1 as well. We will save
few bytes as a bonus.
 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1fd6affcdde7..213f96b2f601 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2556,7 +2556,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
>  	 * is empty. Do it lockless to prevent lock bouncing. Races
>  	 * are acceptable as soft limit is best effort anyway.
>  	 */
> -	if (RB_EMPTY_ROOT(&mctz->rb_root))
> +	if (!mctz || RB_EMPTY_ROOT(&mctz->rb_root))
>  		return 0;
>  
>  	/*
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
