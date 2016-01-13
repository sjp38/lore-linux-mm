Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 86066828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 11:54:53 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l65so301645128wmf.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:54:53 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id hk5si3261556wjb.22.2016.01.13.08.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 08:54:52 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id l65so37857517wmf.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:54:52 -0800 (PST)
Date: Wed, 13 Jan 2016 17:54:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/7] mm: vmscan: do not scan anon pages if memcg swap
 limit is hit
Message-ID: <20160113165450.GI17512@dhcp22.suse.cz>
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
 <6f6fa6cbfe005917911f89b2b12d5fbfa0b071e4.1450352792.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f6fa6cbfe005917911f89b2b12d5fbfa0b071e4.1450352792.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 17-12-15 15:29:58, Vladimir Davydov wrote:
> We don't scan anonymous memory if we ran out of swap, neither should we
> do it in case memcg swap limit is hit, because swap out is impossible
> anyway.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Changes in v2:
>  - Do not check swap limit on the legacy hierarchy.
> 
>  include/linux/swap.h |  6 ++++++
>  mm/memcontrol.c      | 13 +++++++++++++
>  mm/vmscan.c          |  2 +-
>  3 files changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index f8fb4e06c4bd..c544998dfbe7 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -551,6 +551,7 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
>  extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
>  extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
>  extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
> +extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
>  #else
>  static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  {
> @@ -565,6 +566,11 @@ static inline int mem_cgroup_try_charge_swap(struct page *page,
>  static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
>  {
>  }
> +
> +static inline long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
> +{
> +	return get_nr_swap_pages();
> +}
>  #endif
>  
>  #endif /* __KERNEL__*/
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 567b56da2c23..e0e498f5ca32 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5736,6 +5736,19 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
>  	rcu_read_unlock();
>  }
>  
> +long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
> +{
> +	long nr_swap_pages = get_nr_swap_pages();
> +
> +	if (!do_swap_account || !cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +		return nr_swap_pages;
> +	for (; memcg != root_mem_cgroup; memcg = parent_mem_cgroup(memcg))
> +		nr_swap_pages = min_t(long, nr_swap_pages,
> +				      READ_ONCE(memcg->swap.limit) -
> +				      page_counter_read(&memcg->swap));
> +	return nr_swap_pages;
> +}
> +
>  /* for remember boot option*/
>  #ifdef CONFIG_MEMCG_SWAP_ENABLED
>  static int really_do_swap_account __initdata = 1;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b220e6cda25d..ab52d865d922 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1995,7 +1995,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  		force_scan = true;
>  
>  	/* If we have no swap space, do not bother scanning anon pages. */
> -	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
> +	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
>  		scan_balance = SCAN_FILE;
>  		goto out;
>  	}
> -- 
> 2.1.4
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
