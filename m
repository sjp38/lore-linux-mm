Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA316B0255
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 11:00:39 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id v187so40184296wmv.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:00:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fk13si19713938wjc.15.2015.12.10.08.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 08:00:38 -0800 (PST)
Date: Thu, 10 Dec 2015 11:00:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151210160027.GA3308@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 02:39:14PM +0300, Vladimir Davydov wrote:
> In the legacy hierarchy we charge memsw, which is dubious, because:
> 
>  - memsw.limit must be >= memory.limit, so it is impossible to limit
>    swap usage less than memory usage. Taking into account the fact that
>    the primary limiting mechanism in the unified hierarchy is
>    memory.high while memory.limit is either left unset or set to a very
>    large value, moving memsw.limit knob to the unified hierarchy would
>    effectively make it impossible to limit swap usage according to the
>    user preference.
> 
>  - memsw.usage != memory.usage + swap.usage, because a page occupying
>    both swap entry and a swap cache page is charged only once to memsw
>    counter. As a result, it is possible to effectively eat up to
>    memory.limit of memory pages *and* memsw.limit of swap entries, which
>    looks unexpected.
> 
> That said, we should provide a different swap limiting mechanism for
> cgroup2.
> 
> This patch adds mem_cgroup->swap counter, which charges the actual
> number of swap entries used by a cgroup. It is only charged in the
> unified hierarchy, while the legacy hierarchy memsw logic is left
> intact.
> 
> The swap usage can be monitored using new memory.swap.current file and
> limited using memory.swap.max.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

This looks great!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

I have a few questions, but none of them show-stoppers:

> ---
>  include/linux/memcontrol.h |   1 +
>  include/linux/swap.h       |   5 ++
>  mm/memcontrol.c            | 123 +++++++++++++++++++++++++++++++++++++++++----
>  mm/shmem.c                 |   4 ++
>  mm/swap_state.c            |   5 ++
>  5 files changed, 129 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index c6a5ed2f2744..993c9a26b637 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -169,6 +169,7 @@ struct mem_cgroup {
>  
>  	/* Accounted resources */
>  	struct page_counter memory;
> +	struct page_counter swap;
>  	struct page_counter memsw;
>  	struct page_counter kmem;

We should probably separate this to differentiate the new counters
from the old ones. Only memory and swap are actual resources, the
memsw and kmem counters are counting consumer-oriented.

> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 457181844b6e..f4b3ccdcba91 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -368,11 +368,16 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
>  #endif
>  #ifdef CONFIG_MEMCG_SWAP
>  extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
> +extern int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry);

Should this be mem_cgroup_try_swap() to keep in line with the page
counter terminology? So it's clear this is not forcing a charge.

> @@ -1248,12 +1248,15 @@ static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
>  {
>  	unsigned long limit;
>  
> -	limit = memcg->memory.limit;
> +	limit = READ_ONCE(memcg->memory.limit);
>  	if (mem_cgroup_swappiness(memcg)) {
>  		unsigned long memsw_limit;
> +		unsigned long swap_limit;
>  
> -		memsw_limit = memcg->memsw.limit;
> -		limit = min(limit + total_swap_pages, memsw_limit);
> +		memsw_limit = READ_ONCE(memcg->memsw.limit);
> +		swap_limit = min(READ_ONCE(memcg->swap.limit),
> +				 (unsigned long)total_swap_pages);
> +		limit = min(limit + swap_limit, memsw_limit);
>  	}
>  	return limit;

This is taking a racy snapshot, so we don't rely on 100% accuracy. Can
we do without the READ_ONCE()?

> @@ -5754,26 +5760,66 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	memcg_check_events(memcg, page);
>  }
>  
> +/*
> + * mem_cgroup_charge_swap - charge a swap entry
> + * @page: page being added to swap
> + * @entry: swap entry to charge
> + *
> + * Try to charge @entry to the memcg that @page belongs to.
> + *
> + * Returns 0 on success, -ENOMEM on failure.
> + */
> +int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry)
> +{
> +	struct mem_cgroup *memcg;
> +	struct page_counter *counter;
> +	unsigned short oldid;
> +
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) || !do_swap_account)
> +		return 0;
> +
> +	memcg = page->mem_cgroup;
> +
> +	/* Readahead page, never charged */
> +	if (!memcg)
> +		return 0;
> +
> +	if (!mem_cgroup_is_root(memcg) &&
> +	    !page_counter_try_charge(&memcg->swap, 1, &counter))
> +		return -ENOMEM;
> +
> +	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> +	VM_BUG_ON_PAGE(oldid, page);
> +	mem_cgroup_swap_statistics(memcg, true);
> +
> +	css_get(&memcg->css);

I think we don't have to duplicate the swap record code. Both cgroup1
and cgroup2 could run this function to handle the swapout record and
statistics, and then mem_cgroup_swapout() would simply uncharge memsw.

> @@ -5828,6 +5931,8 @@ static int __init mem_cgroup_swap_init(void)
>  {
>  	if (!mem_cgroup_disabled() && really_do_swap_account) {
>  		do_swap_account = 1;
> +		WARN_ON(cgroup_add_dfl_cftypes(&memory_cgrp_subsys,
> +					       swap_files));
>  		WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys,
>  						  memsw_cgroup_files));

I guess we could also support cgroup.memory=noswap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
