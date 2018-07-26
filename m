Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2BE36B0005
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 09:56:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b9-v6so809044edn.18
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 06:56:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18-v6si1280521edf.177.2018.07.26.06.56.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 06:56:47 -0700 (PDT)
Date: Thu, 26 Jul 2018 15:56:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: reduce memcg tree traversals for stats collection
Message-ID: <20180726135645.GL28386@dhcp22.suse.cz>
References: <20180724224635.143944-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724224635.143944-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Bruce Merry <bmerry@ska.ac.za>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Tue 24-07-18 15:46:35, Shakeel Butt wrote:
> Currently cgroup-v1's memcg_stat_show traverses the memcg tree ~17 times
> to collect the stats while cgroup-v2's memory_stat_show traverses the
> memcg tree thrice. On a large machine, a couple thousand memcgs is very
> normal and if the churn is high and memcgs stick around during to
> several reasons, tens of thousands of nodes in memcg tree can exist.
> This patch has refactored and shared the stat collection code between
> cgroup-v1 and cgroup-v2 and has reduced the tree traversal to just one.
> 
> I ran a simple benchmark which reads the root_mem_cgroup's stat file
> 1000 times in the presense of 2500 memcgs on cgroup-v1. The results are:
> 
> Without the patch:
> $ time ./read-root-stat-1000-times
> 
> real    0m1.663s
> user    0m0.000s
> sys     0m1.660s
> 
> With the patch:
> $ time ./read-root-stat-1000-times
> 
> real    0m0.468s
> user    0m0.000s
> sys     0m0.467s

The code is not the nicest one and accumulated_stats could really see
some comment explaining v1 vs. v2 differences but other than that this
makes sense. Especially with many zombies we can have.

> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 150 +++++++++++++++++++++++-------------------------
>  1 file changed, 73 insertions(+), 77 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a5869b9d5194..d90993ef1d7d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3122,29 +3122,34 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
>  	return retval;
>  }
>  
> -static void tree_stat(struct mem_cgroup *memcg, unsigned long *stat)
> -{
> -	struct mem_cgroup *iter;
> -	int i;
> -
> -	memset(stat, 0, sizeof(*stat) * MEMCG_NR_STAT);
> -
> -	for_each_mem_cgroup_tree(iter, memcg) {
> -		for (i = 0; i < MEMCG_NR_STAT; i++)
> -			stat[i] += memcg_page_state(iter, i);
> -	}
> -}
> +struct accumulated_stats {
> +	unsigned long stat[MEMCG_NR_STAT];
> +	unsigned long events[NR_VM_EVENT_ITEMS];
> +	unsigned long lru_pages[NR_LRU_LISTS];
> +	const unsigned int *stats_array;
> +	const unsigned int *events_array;
> +	int stats_size;
> +	int events_size;
> +};
>  
> -static void tree_events(struct mem_cgroup *memcg, unsigned long *events)
> +static void accumulate_memcg_tree(struct mem_cgroup *memcg,
> +				  struct accumulated_stats *acc)
>  {
> -	struct mem_cgroup *iter;
> +	struct mem_cgroup *mi;
>  	int i;
>  
> -	memset(events, 0, sizeof(*events) * NR_VM_EVENT_ITEMS);
> +	for_each_mem_cgroup_tree(mi, memcg) {
> +		for (i = 0; i < acc->stats_size; i++)
> +			acc->stat[i] += memcg_page_state(mi,
> +				acc->stats_array ? acc->stats_array[i] : i);
>  
> -	for_each_mem_cgroup_tree(iter, memcg) {
> -		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
> -			events[i] += memcg_sum_events(iter, i);
> +		for (i = 0; i < acc->events_size; i++)
> +			acc->events[i] += memcg_sum_events(mi,
> +				acc->events_array ? acc->events_array[i] : i);
> +
> +		for (i = 0; i < NR_LRU_LISTS; i++)
> +			acc->lru_pages[i] +=
> +				mem_cgroup_nr_lru_pages(mi, BIT(i));
>  	}
>  }
>  
> @@ -3555,6 +3560,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>  	unsigned long memory, memsw;
>  	struct mem_cgroup *mi;
>  	unsigned int i;
> +	struct accumulated_stats acc;
>  
>  	BUILD_BUG_ON(ARRAY_SIZE(memcg1_stat_names) != ARRAY_SIZE(memcg1_stats));
>  	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
> @@ -3587,32 +3593,27 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>  		seq_printf(m, "hierarchical_memsw_limit %llu\n",
>  			   (u64)memsw * PAGE_SIZE);
>  
> -	for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
> -		unsigned long long val = 0;
> +	memset(&acc, 0, sizeof(acc));
> +	acc.stats_size = ARRAY_SIZE(memcg1_stats);
> +	acc.stats_array = memcg1_stats;
> +	acc.events_size = ARRAY_SIZE(memcg1_events);
> +	acc.events_array = memcg1_events;
> +	accumulate_memcg_tree(memcg, &acc);
>  
> +	for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
>  		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
>  			continue;
> -		for_each_mem_cgroup_tree(mi, memcg)
> -			val += memcg_page_state(mi, memcg1_stats[i]) *
> -			PAGE_SIZE;
> -		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i], val);
> +		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> +			   (u64)acc.stat[i] * PAGE_SIZE);
>  	}
>  
> -	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++) {
> -		unsigned long long val = 0;
> -
> -		for_each_mem_cgroup_tree(mi, memcg)
> -			val += memcg_sum_events(mi, memcg1_events[i]);
> -		seq_printf(m, "total_%s %llu\n", memcg1_event_names[i], val);
> -	}
> -
> -	for (i = 0; i < NR_LRU_LISTS; i++) {
> -		unsigned long long val = 0;
> +	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
> +		seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
> +			   (u64)acc.events[i]);
>  
> -		for_each_mem_cgroup_tree(mi, memcg)
> -			val += mem_cgroup_nr_lru_pages(mi, BIT(i)) * PAGE_SIZE;
> -		seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i], val);
> -	}
> +	for (i = 0; i < NR_LRU_LISTS; i++)
> +		seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
> +			   (u64)acc.lru_pages[i] * PAGE_SIZE);
>  
>  #ifdef CONFIG_DEBUG_VM
>  	{
> @@ -5737,8 +5738,7 @@ static int memory_events_show(struct seq_file *m, void *v)
>  static int memory_stat_show(struct seq_file *m, void *v)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> -	unsigned long stat[MEMCG_NR_STAT];
> -	unsigned long events[NR_VM_EVENT_ITEMS];
> +	struct accumulated_stats acc;
>  	int i;
>  
>  	/*
> @@ -5752,66 +5752,62 @@ static int memory_stat_show(struct seq_file *m, void *v)
>  	 * Current memory state:
>  	 */
>  
> -	tree_stat(memcg, stat);
> -	tree_events(memcg, events);
> +	memset(&acc, 0, sizeof(acc));
> +	acc.stats_size = MEMCG_NR_STAT;
> +	acc.events_size = NR_VM_EVENT_ITEMS;
> +	accumulate_memcg_tree(memcg, &acc);
>  
>  	seq_printf(m, "anon %llu\n",
> -		   (u64)stat[MEMCG_RSS] * PAGE_SIZE);
> +		   (u64)acc.stat[MEMCG_RSS] * PAGE_SIZE);
>  	seq_printf(m, "file %llu\n",
> -		   (u64)stat[MEMCG_CACHE] * PAGE_SIZE);
> +		   (u64)acc.stat[MEMCG_CACHE] * PAGE_SIZE);
>  	seq_printf(m, "kernel_stack %llu\n",
> -		   (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
> +		   (u64)acc.stat[MEMCG_KERNEL_STACK_KB] * 1024);
>  	seq_printf(m, "slab %llu\n",
> -		   (u64)(stat[NR_SLAB_RECLAIMABLE] +
> -			 stat[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
> +		   (u64)(acc.stat[NR_SLAB_RECLAIMABLE] +
> +			 acc.stat[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
>  	seq_printf(m, "sock %llu\n",
> -		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
> +		   (u64)acc.stat[MEMCG_SOCK] * PAGE_SIZE);
>  
>  	seq_printf(m, "shmem %llu\n",
> -		   (u64)stat[NR_SHMEM] * PAGE_SIZE);
> +		   (u64)acc.stat[NR_SHMEM] * PAGE_SIZE);
>  	seq_printf(m, "file_mapped %llu\n",
> -		   (u64)stat[NR_FILE_MAPPED] * PAGE_SIZE);
> +		   (u64)acc.stat[NR_FILE_MAPPED] * PAGE_SIZE);
>  	seq_printf(m, "file_dirty %llu\n",
> -		   (u64)stat[NR_FILE_DIRTY] * PAGE_SIZE);
> +		   (u64)acc.stat[NR_FILE_DIRTY] * PAGE_SIZE);
>  	seq_printf(m, "file_writeback %llu\n",
> -		   (u64)stat[NR_WRITEBACK] * PAGE_SIZE);
> +		   (u64)acc.stat[NR_WRITEBACK] * PAGE_SIZE);
>  
> -	for (i = 0; i < NR_LRU_LISTS; i++) {
> -		struct mem_cgroup *mi;
> -		unsigned long val = 0;
> -
> -		for_each_mem_cgroup_tree(mi, memcg)
> -			val += mem_cgroup_nr_lru_pages(mi, BIT(i));
> -		seq_printf(m, "%s %llu\n",
> -			   mem_cgroup_lru_names[i], (u64)val * PAGE_SIZE);
> -	}
> +	for (i = 0; i < NR_LRU_LISTS; i++)
> +		seq_printf(m, "%s %llu\n", mem_cgroup_lru_names[i],
> +			   (u64)acc.lru_pages[i] * PAGE_SIZE);
>  
>  	seq_printf(m, "slab_reclaimable %llu\n",
> -		   (u64)stat[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
> +		   (u64)acc.stat[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
>  	seq_printf(m, "slab_unreclaimable %llu\n",
> -		   (u64)stat[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
> +		   (u64)acc.stat[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
>  
>  	/* Accumulated memory events */
>  
> -	seq_printf(m, "pgfault %lu\n", events[PGFAULT]);
> -	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
> +	seq_printf(m, "pgfault %lu\n", acc.events[PGFAULT]);
> +	seq_printf(m, "pgmajfault %lu\n", acc.events[PGMAJFAULT]);
>  
> -	seq_printf(m, "pgrefill %lu\n", events[PGREFILL]);
> -	seq_printf(m, "pgscan %lu\n", events[PGSCAN_KSWAPD] +
> -		   events[PGSCAN_DIRECT]);
> -	seq_printf(m, "pgsteal %lu\n", events[PGSTEAL_KSWAPD] +
> -		   events[PGSTEAL_DIRECT]);
> -	seq_printf(m, "pgactivate %lu\n", events[PGACTIVATE]);
> -	seq_printf(m, "pgdeactivate %lu\n", events[PGDEACTIVATE]);
> -	seq_printf(m, "pglazyfree %lu\n", events[PGLAZYFREE]);
> -	seq_printf(m, "pglazyfreed %lu\n", events[PGLAZYFREED]);
> +	seq_printf(m, "pgrefill %lu\n", acc.events[PGREFILL]);
> +	seq_printf(m, "pgscan %lu\n", acc.events[PGSCAN_KSWAPD] +
> +		   acc.events[PGSCAN_DIRECT]);
> +	seq_printf(m, "pgsteal %lu\n", acc.events[PGSTEAL_KSWAPD] +
> +		   acc.events[PGSTEAL_DIRECT]);
> +	seq_printf(m, "pgactivate %lu\n", acc.events[PGACTIVATE]);
> +	seq_printf(m, "pgdeactivate %lu\n", acc.events[PGDEACTIVATE]);
> +	seq_printf(m, "pglazyfree %lu\n", acc.events[PGLAZYFREE]);
> +	seq_printf(m, "pglazyfreed %lu\n", acc.events[PGLAZYFREED]);
>  
>  	seq_printf(m, "workingset_refault %lu\n",
> -		   stat[WORKINGSET_REFAULT]);
> +		   acc.stat[WORKINGSET_REFAULT]);
>  	seq_printf(m, "workingset_activate %lu\n",
> -		   stat[WORKINGSET_ACTIVATE]);
> +		   acc.stat[WORKINGSET_ACTIVATE]);
>  	seq_printf(m, "workingset_nodereclaim %lu\n",
> -		   stat[WORKINGSET_NODERECLAIM]);
> +		   acc.stat[WORKINGSET_NODERECLAIM]);
>  
>  	return 0;
>  }
> -- 
> 2.18.0.233.g985f88cf7e-goog

-- 
Michal Hocko
SUSE Labs
