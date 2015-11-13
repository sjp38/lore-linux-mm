Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6B18E6B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 05:37:52 -0500 (EST)
Received: by wmec201 with SMTP id c201so74678374wme.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:37:52 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id pd8si24924520wjb.183.2015.11.13.02.37.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 02:37:51 -0800 (PST)
Received: by wmec201 with SMTP id c201so74677691wme.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:37:51 -0800 (PST)
Date: Fri, 13 Nov 2015 11:37:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 11/14] mm: memcontrol: do not account memory+swap on
 unified hierarchy
Message-ID: <20151113103749.GC2632@dhcp22.suse.cz>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-12-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447371693-25143-12-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 12-11-15 18:41:30, Johannes Weiner wrote:
> The unified hierarchy memory controller doesn't expose the memory+swap
> counter to userspace, but its accounting is hardcoded in all charge
> paths right now, including the per-cpu charge cache ("the stock").
> 
> To avoid adding yet more pointless memory+swap accounting with the
> socket memory support in unified hierarchy, disable the counter
> altogether when in unified hierarchy mode.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 44 +++++++++++++++++++++++++-------------------
>  1 file changed, 25 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 658bef2..e7f1a79 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -87,6 +87,12 @@ int do_swap_account __read_mostly;
>  #define do_swap_account		0
>  #endif
>  
> +/* Whether legacy memory+swap accounting is active */
> +static bool do_memsw_account(void)
> +{
> +	return !cgroup_subsys_on_dfl(memory_cgrp_subsys) && do_swap_account;
> +}
> +
>  static const char * const mem_cgroup_stat_names[] = {
>  	"cache",
>  	"rss",
> @@ -1177,7 +1183,7 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
>  	if (count < limit)
>  		margin = limit - count;
>  
> -	if (do_swap_account) {
> +	if (do_memsw_account()) {
>  		count = page_counter_read(&memcg->memsw);
>  		limit = READ_ONCE(memcg->memsw.limit);
>  		if (count <= limit)
> @@ -1280,7 +1286,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  		pr_cont(":");
>  
>  		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> -			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> +			if (i == MEM_CGROUP_STAT_SWAP && !do_memsw_account())
>  				continue;
>  			pr_cont(" %s:%luKB", mem_cgroup_stat_names[i],
>  				K(mem_cgroup_read_stat(iter, i)));
> @@ -1903,7 +1909,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
>  
>  	if (stock->nr_pages) {
>  		page_counter_uncharge(&old->memory, stock->nr_pages);
> -		if (do_swap_account)
> +		if (do_memsw_account())
>  			page_counter_uncharge(&old->memsw, stock->nr_pages);
>  		css_put_many(&old->css, stock->nr_pages);
>  		stock->nr_pages = 0;
> @@ -2033,11 +2039,11 @@ retry:
>  	if (consume_stock(memcg, nr_pages))
>  		return 0;
>  
> -	if (!do_swap_account ||
> +	if (!do_memsw_account() ||
>  	    page_counter_try_charge(&memcg->memsw, batch, &counter)) {
>  		if (page_counter_try_charge(&memcg->memory, batch, &counter))
>  			goto done_restock;
> -		if (do_swap_account)
> +		if (do_memsw_account())
>  			page_counter_uncharge(&memcg->memsw, batch);
>  		mem_over_limit = mem_cgroup_from_counter(counter, memory);
>  	} else {
> @@ -2124,7 +2130,7 @@ force:
>  	 * temporarily by force charging it.
>  	 */
>  	page_counter_charge(&memcg->memory, nr_pages);
> -	if (do_swap_account)
> +	if (do_memsw_account())
>  		page_counter_charge(&memcg->memsw, nr_pages);
>  	css_get_many(&memcg->css, nr_pages);
>  
> @@ -2161,7 +2167,7 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
>  		return;
>  
>  	page_counter_uncharge(&memcg->memory, nr_pages);
> -	if (do_swap_account)
> +	if (do_memsw_account())
>  		page_counter_uncharge(&memcg->memsw, nr_pages);
>  
>  	css_put_many(&memcg->css, nr_pages);
> @@ -2441,7 +2447,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
>  
>  	page_counter_uncharge(&memcg->kmem, nr_pages);
>  	page_counter_uncharge(&memcg->memory, nr_pages);
> -	if (do_swap_account)
> +	if (do_memsw_account())
>  		page_counter_uncharge(&memcg->memsw, nr_pages);
>  
>  	page->mem_cgroup = NULL;
> @@ -3154,7 +3160,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>  	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
>  
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> -		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> +		if (i == MEM_CGROUP_STAT_SWAP && !do_memsw_account())
>  			continue;
>  		seq_printf(m, "%s %lu\n", mem_cgroup_stat_names[i],
>  			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
> @@ -3176,14 +3182,14 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>  	}
>  	seq_printf(m, "hierarchical_memory_limit %llu\n",
>  		   (u64)memory * PAGE_SIZE);
> -	if (do_swap_account)
> +	if (do_memsw_account())
>  		seq_printf(m, "hierarchical_memsw_limit %llu\n",
>  			   (u64)memsw * PAGE_SIZE);
>  
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>  		unsigned long long val = 0;
>  
> -		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
> +		if (i == MEM_CGROUP_STAT_SWAP && !do_memsw_account())
>  			continue;
>  		for_each_mem_cgroup_tree(mi, memcg)
>  			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
> @@ -3314,7 +3320,7 @@ static void mem_cgroup_threshold(struct mem_cgroup *memcg)
>  {
>  	while (memcg) {
>  		__mem_cgroup_threshold(memcg, false);
> -		if (do_swap_account)
> +		if (do_memsw_account())
>  			__mem_cgroup_threshold(memcg, true);
>  
>  		memcg = parent_mem_cgroup(memcg);
> @@ -4460,7 +4466,7 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
>  	 * we call find_get_page() with swapper_space directly.
>  	 */
>  	page = find_get_page(swap_address_space(ent), ent.val);
> -	if (do_swap_account)
> +	if (do_memsw_account())
>  		entry->val = ent.val;
>  
>  	return page;
> @@ -4495,7 +4501,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
>  		page = find_get_entry(mapping, pgoff);
>  		if (radix_tree_exceptional_entry(page)) {
>  			swp_entry_t swp = radix_to_swp_entry(page);
> -			if (do_swap_account)
> +			if (do_memsw_account())
>  				*entry = swp;
>  			page = find_get_page(swap_address_space(swp), swp.val);
>  		}
> @@ -5270,7 +5276,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  		if (page->mem_cgroup)
>  			goto out;
>  
> -		if (do_swap_account) {
> +		if (do_memsw_account()) {
>  			swp_entry_t ent = { .val = page_private(page), };
>  			unsigned short id = lookup_swap_cgroup_id(ent);
>  
> @@ -5334,7 +5340,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  	memcg_check_events(memcg, page);
>  	local_irq_enable();
>  
> -	if (do_swap_account && PageSwapCache(page)) {
> +	if (do_memsw_account() && PageSwapCache(page)) {
>  		swp_entry_t entry = { .val = page_private(page) };
>  		/*
>  		 * The swap entry might not get freed for a long time,
> @@ -5379,7 +5385,7 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
>  
>  	if (!mem_cgroup_is_root(memcg)) {
>  		page_counter_uncharge(&memcg->memory, nr_pages);
> -		if (do_swap_account)
> +		if (do_memsw_account())
>  			page_counter_uncharge(&memcg->memsw, nr_pages);
>  		memcg_oom_recover(memcg);
>  	}
> @@ -5587,7 +5593,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
>  	VM_BUG_ON_PAGE(page_count(page), page);
>  
> -	if (!do_swap_account)
> +	if (!do_memsw_account())
>  		return;
>  
>  	memcg = page->mem_cgroup;
> @@ -5627,7 +5633,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
>  	struct mem_cgroup *memcg;
>  	unsigned short id;
>  
> -	if (!do_swap_account)
> +	if (!do_memsw_account())
>  		return;
>  
>  	id = swap_cgroup_record(entry, 0);
> -- 
> 2.6.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
