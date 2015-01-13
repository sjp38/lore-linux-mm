Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2689D6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 10:01:37 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id l4so2981710lbv.12
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 07:01:36 -0800 (PST)
Received: from mail-we0-x233.google.com (mail-we0-x233.google.com. [2a00:1450:400c:c03::233])
        by mx.google.com with ESMTPS id ym7si42269786wjc.83.2015.01.13.07.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 07:01:35 -0800 (PST)
Received: by mail-we0-f179.google.com with SMTP id q59so3378006wes.10
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 07:01:35 -0800 (PST)
Date: Tue, 13 Jan 2015 16:01:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/3] mm: memcontrol: consolidate swap controller code
Message-ID: <20150113150133.GI25318@dhcp22.suse.cz>
References: <1420856041-27647-1-git-send-email-hannes@cmpxchg.org>
 <1420856041-27647-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420856041-27647-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 09-01-15 21:14:01, Johannes Weiner wrote:
> The swap controller code is scattered all over the file.  Gather all
> the code that isn't directly needed by the memory controller at the
> end of the file in its own CONFIG_MEMCG_SWAP section.

Well, the idea was to stick with corresponding infrastructure I guess.
memsw_cgroup_files where together with mem_cgroup_files, swap accounting
with the charge routines. Putting everything together is certainly
an option as well. I do not feel strongly about either way. I tend
to dislike code churn but if it makes further changes easier then
definitely no objections from me.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 264 +++++++++++++++++++++++++++-----------------------------
>  1 file changed, 125 insertions(+), 139 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f66bb8f83ac9..5a5769e8b12c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -72,22 +72,13 @@ EXPORT_SYMBOL(memory_cgrp_subsys);
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  static struct mem_cgroup *root_mem_cgroup __read_mostly;
>  
> +/* Whether the swap controller is active */
>  #ifdef CONFIG_MEMCG_SWAP
> -/* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
>  int do_swap_account __read_mostly;
> -
> -/* for remember boot option*/
> -#ifdef CONFIG_MEMCG_SWAP_ENABLED
> -static int really_do_swap_account __initdata = 1;
> -#else
> -static int really_do_swap_account __initdata;
> -#endif
> -
>  #else
>  #define do_swap_account		0
>  #endif
>  
> -
>  static const char * const mem_cgroup_stat_names[] = {
>  	"cache",
>  	"rss",
> @@ -4382,34 +4373,6 @@ static struct cftype mem_cgroup_legacy_files[] = {
>  	{ },	/* terminate */
>  };
>  
> -#ifdef CONFIG_MEMCG_SWAP
> -static struct cftype memsw_cgroup_files[] = {
> -	{
> -		.name = "memsw.usage_in_bytes",
> -		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
> -		.read_u64 = mem_cgroup_read_u64,
> -	},
> -	{
> -		.name = "memsw.max_usage_in_bytes",
> -		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_MAX_USAGE),
> -		.write = mem_cgroup_reset,
> -		.read_u64 = mem_cgroup_read_u64,
> -	},
> -	{
> -		.name = "memsw.limit_in_bytes",
> -		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_LIMIT),
> -		.write = mem_cgroup_write,
> -		.read_u64 = mem_cgroup_read_u64,
> -	},
> -	{
> -		.name = "memsw.failcnt",
> -		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_FAILCNT),
> -		.write = mem_cgroup_reset,
> -		.read_u64 = mem_cgroup_read_u64,
> -	},
> -	{ },	/* terminate */
> -};
> -#endif
>  static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  {
>  	struct mem_cgroup_per_node *pn;
> @@ -5415,37 +5378,6 @@ struct cgroup_subsys memory_cgrp_subsys = {
>  	.early_init = 0,
>  };
>  
> -#ifdef CONFIG_MEMCG_SWAP
> -static int __init enable_swap_account(char *s)
> -{
> -	if (!strcmp(s, "1"))
> -		really_do_swap_account = 1;
> -	else if (!strcmp(s, "0"))
> -		really_do_swap_account = 0;
> -	return 1;
> -}
> -__setup("swapaccount=", enable_swap_account);
> -
> -static void __init memsw_file_init(void)
> -{
> -	WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys,
> -					  memsw_cgroup_files));
> -}
> -
> -static void __init enable_swap_cgroup(void)
> -{
> -	if (!mem_cgroup_disabled() && really_do_swap_account) {
> -		do_swap_account = 1;
> -		memsw_file_init();
> -	}
> -}
> -
> -#else
> -static void __init enable_swap_cgroup(void)
> -{
> -}
> -#endif
> -
>  /**
>   * mem_cgroup_events - count memory events against a cgroup
>   * @memcg: the memory cgroup
> @@ -5496,74 +5428,6 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
>  	return true;
>  }
>  
> -#ifdef CONFIG_MEMCG_SWAP
> -/**
> - * mem_cgroup_swapout - transfer a memsw charge to swap
> - * @page: page whose memsw charge to transfer
> - * @entry: swap entry to move the charge to
> - *
> - * Transfer the memsw charge of @page to @entry.
> - */
> -void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> -{
> -	struct mem_cgroup *memcg;
> -	unsigned short oldid;
> -
> -	VM_BUG_ON_PAGE(PageLRU(page), page);
> -	VM_BUG_ON_PAGE(page_count(page), page);
> -
> -	if (!do_swap_account)
> -		return;
> -
> -	memcg = page->mem_cgroup;
> -
> -	/* Readahead page, never charged */
> -	if (!memcg)
> -		return;
> -
> -	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> -	VM_BUG_ON_PAGE(oldid, page);
> -	mem_cgroup_swap_statistics(memcg, true);
> -
> -	page->mem_cgroup = NULL;
> -
> -	if (!mem_cgroup_is_root(memcg))
> -		page_counter_uncharge(&memcg->memory, 1);
> -
> -	/* XXX: caller holds IRQ-safe mapping->tree_lock */
> -	VM_BUG_ON(!irqs_disabled());
> -
> -	mem_cgroup_charge_statistics(memcg, page, -1);
> -	memcg_check_events(memcg, page);
> -}
> -
> -/**
> - * mem_cgroup_uncharge_swap - uncharge a swap entry
> - * @entry: swap entry to uncharge
> - *
> - * Drop the memsw charge associated with @entry.
> - */
> -void mem_cgroup_uncharge_swap(swp_entry_t entry)
> -{
> -	struct mem_cgroup *memcg;
> -	unsigned short id;
> -
> -	if (!do_swap_account)
> -		return;
> -
> -	id = swap_cgroup_record(entry, 0);
> -	rcu_read_lock();
> -	memcg = mem_cgroup_lookup(id);
> -	if (memcg) {
> -		if (!mem_cgroup_is_root(memcg))
> -			page_counter_uncharge(&memcg->memsw, 1);
> -		mem_cgroup_swap_statistics(memcg, false);
> -		css_put(&memcg->css);
> -	}
> -	rcu_read_unlock();
> -}
> -#endif
> -
>  /**
>   * mem_cgroup_try_charge - try charging a page
>   * @page: page to charge
> @@ -5920,8 +5784,130 @@ static int __init mem_cgroup_init(void)
>  		soft_limit_tree.rb_tree_per_node[nid] = rtpn;
>  	}
>  
> -	enable_swap_cgroup();
> -
>  	return 0;
>  }
>  subsys_initcall(mem_cgroup_init);
> +
> +#ifdef CONFIG_MEMCG_SWAP
> +/**
> + * mem_cgroup_swapout - transfer a memsw charge to swap
> + * @page: page whose memsw charge to transfer
> + * @entry: swap entry to move the charge to
> + *
> + * Transfer the memsw charge of @page to @entry.
> + */
> +void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> +{
> +	struct mem_cgroup *memcg;
> +	unsigned short oldid;
> +
> +	VM_BUG_ON_PAGE(PageLRU(page), page);
> +	VM_BUG_ON_PAGE(page_count(page), page);
> +
> +	if (!do_swap_account)
> +		return;
> +
> +	memcg = page->mem_cgroup;
> +
> +	/* Readahead page, never charged */
> +	if (!memcg)
> +		return;
> +
> +	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> +	VM_BUG_ON_PAGE(oldid, page);
> +	mem_cgroup_swap_statistics(memcg, true);
> +
> +	page->mem_cgroup = NULL;
> +
> +	if (!mem_cgroup_is_root(memcg))
> +		page_counter_uncharge(&memcg->memory, 1);
> +
> +	/* XXX: caller holds IRQ-safe mapping->tree_lock */
> +	VM_BUG_ON(!irqs_disabled());
> +
> +	mem_cgroup_charge_statistics(memcg, page, -1);
> +	memcg_check_events(memcg, page);
> +}
> +
> +/**
> + * mem_cgroup_uncharge_swap - uncharge a swap entry
> + * @entry: swap entry to uncharge
> + *
> + * Drop the memsw charge associated with @entry.
> + */
> +void mem_cgroup_uncharge_swap(swp_entry_t entry)
> +{
> +	struct mem_cgroup *memcg;
> +	unsigned short id;
> +
> +	if (!do_swap_account)
> +		return;
> +
> +	id = swap_cgroup_record(entry, 0);
> +	rcu_read_lock();
> +	memcg = mem_cgroup_lookup(id);
> +	if (memcg) {
> +		if (!mem_cgroup_is_root(memcg))
> +			page_counter_uncharge(&memcg->memsw, 1);
> +		mem_cgroup_swap_statistics(memcg, false);
> +		css_put(&memcg->css);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +/* for remember boot option*/
> +#ifdef CONFIG_MEMCG_SWAP_ENABLED
> +static int really_do_swap_account __initdata = 1;
> +#else
> +static int really_do_swap_account __initdata;
> +#endif
> +
> +static int __init enable_swap_account(char *s)
> +{
> +	if (!strcmp(s, "1"))
> +		really_do_swap_account = 1;
> +	else if (!strcmp(s, "0"))
> +		really_do_swap_account = 0;
> +	return 1;
> +}
> +__setup("swapaccount=", enable_swap_account);
> +
> +static struct cftype memsw_cgroup_files[] = {
> +	{
> +		.name = "memsw.usage_in_bytes",
> +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
> +		.read_u64 = mem_cgroup_read_u64,
> +	},
> +	{
> +		.name = "memsw.max_usage_in_bytes",
> +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_MAX_USAGE),
> +		.write = mem_cgroup_reset,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},
> +	{
> +		.name = "memsw.limit_in_bytes",
> +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_LIMIT),
> +		.write = mem_cgroup_write,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},
> +	{
> +		.name = "memsw.failcnt",
> +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_FAILCNT),
> +		.write = mem_cgroup_reset,
> +		.read_u64 = mem_cgroup_read_u64,
> +	},
> +	{ },	/* terminate */
> +};
> +
> +static int __init mem_cgroup_swap_init(void)
> +{
> +	if (!mem_cgroup_disabled() && really_do_swap_account) {
> +		do_swap_account = 1;
> +		WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys,
> +						  memsw_cgroup_files));
> +	}
> +	return 0;
> +}
> +subsys_initcall(mem_cgroup_swap_init);
> +
> +#endif /* CONFIG_MEMCG_SWAP */
> -- 
> 2.2.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
