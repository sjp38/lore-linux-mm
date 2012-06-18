Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id DD9F96B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:30:16 -0400 (EDT)
Date: Mon, 18 Jun 2012 15:30:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: remove -EINTR at rmdir()
Message-ID: <20120618133012.GB2313@tiehlicka.suse.cz>
References: <4FDF17A3.9060202@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FDF17A3.9060202@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 18-06-12 20:57:23, KAMEZAWA Hiroyuki wrote:
> 2 follow-up patches for "memcg: move charges to root cgroup if use_hierarchy=0",
> developped/tested onto memcg-devel tree. Maybe no HUNK with -next and -mm....
> -Kame
> ==
> memcg: remove -EINTR at rmdir()
> 
> By commit "memcg: move charges to root cgroup if use_hierarchy=0",
> no memory reclaiming will occur at removing memory cgroup.

OK, so the there are only 2 reasons why move_parent could fail in this
path. 1) it races with somebody else who is uncharging or moving the
charge and 2) THP split.
1) works for us and 2) doens't seem to be serious enough to expect that
it would stall rmdir on the group for unbound amount of time so the
change is safe (can we make this into the changelog please?).

> So, we don't need to take care of user interrupt by signal. This
> patch removes it.
> (*) If -EINTR is returned here, cgroup will show WARNING.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0623300..cf8a0f6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3890,9 +3890,6 @@ move_account:
>  		ret = -EBUSY;
>  		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
>  			goto out;
> -		ret = -EINTR;
> -		if (signal_pending(current))
> -			goto out;
>  		/* This is for making all *used* pages to be on LRU. */
>  		lru_add_drain_all();
>  		drain_all_stock_sync(memcg);
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
