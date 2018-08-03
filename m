Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1B216B0275
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 16:31:35 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id w7-v6so1522693ljh.15
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 13:31:35 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u127-v6si2755263lja.335.2018.08.03.13.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 13:31:33 -0700 (PDT)
Date: Fri, 3 Aug 2018 13:30:49 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180803203045.GA18725@castle.DHCP.thefacebook.com>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Aug 03, 2018 at 10:57:43AM -0700, Tejun Heo wrote:
> mem_cgroup_print_oom_info() currently prints the same info for cgroup1
> and cgroup2 OOMs.  It doesn't make much sense on cgroup2, which
> doesn't use memsw or separate kmem accounting - the information
> reported is both superflous and insufficient.  This patch updates the
> memcg OOM messages on cgroup2 so that
> 
> * It prints memory and swap usages and limits used on cgroup2.
> 
> * It shows the same information as memory.stat.
> 
> I took out the recursive printing for cgroup2 because the amount of
> output could be a lot and the benefits aren't clear.
> 
> What do you guys think?

It makes total sense for me.
I'd only add an example of output into the commit message,
as well as an explicit statement that output format is changing
for v2 only.

Small nit below.

> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> ---
>  mm/memcontrol.c |  165 ++++++++++++++++++++++++++++++++------------------------
>  1 file changed, 96 insertions(+), 69 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8c0280b3143e..86133e50a0b2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -177,6 +177,7 @@ struct mem_cgroup_event {
>  
>  static void mem_cgroup_threshold(struct mem_cgroup *memcg);
>  static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
> +static void __memory_stat_show(struct seq_file *m, struct mem_cgroup *memcg);
>  
>  /* Stuffs for move charges at task migration. */
>  /*
> @@ -1146,33 +1147,49 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  
>  	rcu_read_unlock();
>  
> -	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
> -		K((u64)page_counter_read(&memcg->memory)),
> -		K((u64)memcg->memory.max), memcg->memory.failcnt);
> -	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
> -		K((u64)page_counter_read(&memcg->memsw)),
> -		K((u64)memcg->memsw.max), memcg->memsw.failcnt);
> -	pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
> -		K((u64)page_counter_read(&memcg->kmem)),
> -		K((u64)memcg->kmem.max), memcg->kmem.failcnt);
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
> +		pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
> +			K((u64)page_counter_read(&memcg->memory)),
> +			K((u64)memcg->memory.max), memcg->memory.failcnt);
> +		pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
> +			K((u64)page_counter_read(&memcg->memsw)),
> +			K((u64)memcg->memsw.max), memcg->memsw.failcnt);
> +		pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
> +			K((u64)page_counter_read(&memcg->kmem)),
> +			K((u64)memcg->kmem.max), memcg->kmem.failcnt);
>  
> -	for_each_mem_cgroup_tree(iter, memcg) {
> -		pr_info("Memory cgroup stats for ");
> -		pr_cont_cgroup_path(iter->css.cgroup);
> -		pr_cont(":");
> +		for_each_mem_cgroup_tree(iter, memcg) {
> +			pr_info("Memory cgroup stats for ");
> +			pr_cont_cgroup_path(iter->css.cgroup);
> +			pr_cont(":");
> +
> +			for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
> +				if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
> +					continue;
> +				pr_cont(" %s:%luKB", memcg1_stat_names[i],
> +					K(memcg_page_state(iter, memcg1_stats[i])));
> +			}
>  
> -		for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
> -			if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
> -				continue;
> -			pr_cont(" %s:%luKB", memcg1_stat_names[i],
> -				K(memcg_page_state(iter, memcg1_stats[i])));
> +			for (i = 0; i < NR_LRU_LISTS; i++)
> +				pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
> +					K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
> +
> +			pr_cont("\n");
>  		}
> +	} else {
> +		pr_info("memory %llu (max %llu)\n",
> +			(u64)page_counter_read(&memcg->memory) * PAGE_SIZE,
> +			(u64)memcg->memory.max * PAGE_SIZE);
>  
> -		for (i = 0; i < NR_LRU_LISTS; i++)
> -			pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
> -				K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
> +		if (memcg->swap.max == PAGE_COUNTER_MAX)
> +			pr_info("swap %llu\n",
> +				(u64)page_counter_read(&memcg->swap) * PAGE_SIZE);
> +		else
> +			pr_info("swap %llu (max %llu)\n",
> +				(u64)page_counter_read(&memcg->swap) * PAGE_SIZE,
> +				(u64)memcg->swap.max * PAGE_SIZE);
>  
> -		pr_cont("\n");
> +		__memory_stat_show(NULL, memcg);
>  	}
>  }
>  
> @@ -5246,9 +5263,15 @@ static int memory_events_show(struct seq_file *m, void *v)
>  	return 0;
>  }
>  
> -static int memory_stat_show(struct seq_file *m, void *v)
> +#define seq_pr_info(m, fmt, ...) do {					\
> +	if ((m))							\
> +		seq_printf(m, fmt, ##__VA_ARGS__);			\
> +	else								\
> +		printk(KERN_INFO fmt, ##__VA_ARGS__);			\
> +} while (0)
> +
> +static void __memory_stat_show(struct seq_file *m, struct mem_cgroup *memcg)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
>  	unsigned long stat[MEMCG_NR_STAT];
>  	unsigned long events[NR_VM_EVENT_ITEMS];
>  	int i;
> @@ -5267,26 +5290,26 @@ static int memory_stat_show(struct seq_file *m, void *v)
>  	tree_stat(memcg, stat);
>  	tree_events(memcg, events);
>  
> -	seq_printf(m, "anon %llu\n",
> -		   (u64)stat[MEMCG_RSS] * PAGE_SIZE);
> -	seq_printf(m, "file %llu\n",
> -		   (u64)stat[MEMCG_CACHE] * PAGE_SIZE);
> -	seq_printf(m, "kernel_stack %llu\n",
> -		   (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
> -	seq_printf(m, "slab %llu\n",
> -		   (u64)(stat[NR_SLAB_RECLAIMABLE] +
> -			 stat[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
> -	seq_printf(m, "sock %llu\n",
> -		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
> -
> -	seq_printf(m, "shmem %llu\n",
> -		   (u64)stat[NR_SHMEM] * PAGE_SIZE);
> -	seq_printf(m, "file_mapped %llu\n",
> -		   (u64)stat[NR_FILE_MAPPED] * PAGE_SIZE);
> -	seq_printf(m, "file_dirty %llu\n",
> -		   (u64)stat[NR_FILE_DIRTY] * PAGE_SIZE);
> -	seq_printf(m, "file_writeback %llu\n",
> -		   (u64)stat[NR_WRITEBACK] * PAGE_SIZE);
> +	seq_pr_info(m, "anon %llu\n",
> +		    (u64)stat[MEMCG_RSS] * PAGE_SIZE);
> +	seq_pr_info(m, "file %llu\n",
> +		    (u64)stat[MEMCG_CACHE] * PAGE_SIZE);
> +	seq_pr_info(m, "kernel_stack %llu\n",
> +		    (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
> +	seq_pr_info(m, "slab %llu\n",
> +		    (u64)(stat[NR_SLAB_RECLAIMABLE] +
> +			  stat[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
> +	seq_pr_info(m, "sock %llu\n",
> +		    (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
> +
> +	seq_pr_info(m, "shmem %llu\n",
> +		    (u64)stat[NR_SHMEM] * PAGE_SIZE);
> +	seq_pr_info(m, "file_mapped %llu\n",
> +		    (u64)stat[NR_FILE_MAPPED] * PAGE_SIZE);
> +	seq_pr_info(m, "file_dirty %llu\n",
> +		    (u64)stat[NR_FILE_DIRTY] * PAGE_SIZE);
> +	seq_pr_info(m, "file_writeback %llu\n",
> +		    (u64)stat[NR_WRITEBACK] * PAGE_SIZE);
>  
>  	for (i = 0; i < NR_LRU_LISTS; i++) {
>  		struct mem_cgroup *mi;
> @@ -5294,37 +5317,41 @@ static int memory_stat_show(struct seq_file *m, void *v)
>  
>  		for_each_mem_cgroup_tree(mi, memcg)
>  			val += mem_cgroup_nr_lru_pages(mi, BIT(i));
> -		seq_printf(m, "%s %llu\n",
> -			   mem_cgroup_lru_names[i], (u64)val * PAGE_SIZE);
> +		seq_pr_info(m, "%s %llu\n",
> +			    mem_cgroup_lru_names[i], (u64)val * PAGE_SIZE);
>  	}
>  
> -	seq_printf(m, "slab_reclaimable %llu\n",
> -		   (u64)stat[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
> -	seq_printf(m, "slab_unreclaimable %llu\n",
> -		   (u64)stat[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
> +	seq_pr_info(m, "slab_reclaimable %llu\n",
> +		    (u64)stat[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
> +	seq_pr_info(m, "slab_unreclaimable %llu\n",
> +		    (u64)stat[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
>  
>  	/* Accumulated memory events */
>  
> -	seq_printf(m, "pgfault %lu\n", events[PGFAULT]);
> -	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
> -
> -	seq_printf(m, "pgrefill %lu\n", events[PGREFILL]);
> -	seq_printf(m, "pgscan %lu\n", events[PGSCAN_KSWAPD] +
> -		   events[PGSCAN_DIRECT]);
> -	seq_printf(m, "pgsteal %lu\n", events[PGSTEAL_KSWAPD] +
> -		   events[PGSTEAL_DIRECT]);
> -	seq_printf(m, "pgactivate %lu\n", events[PGACTIVATE]);
> -	seq_printf(m, "pgdeactivate %lu\n", events[PGDEACTIVATE]);
> -	seq_printf(m, "pglazyfree %lu\n", events[PGLAZYFREE]);
> -	seq_printf(m, "pglazyfreed %lu\n", events[PGLAZYFREED]);
> -
> -	seq_printf(m, "workingset_refault %lu\n",
> -		   stat[WORKINGSET_REFAULT]);
> -	seq_printf(m, "workingset_activate %lu\n",
> -		   stat[WORKINGSET_ACTIVATE]);
> -	seq_printf(m, "workingset_nodereclaim %lu\n",
> -		   stat[WORKINGSET_NODERECLAIM]);
> +	seq_pr_info(m, "pgfault %lu\n", events[PGFAULT]);
> +	seq_pr_info(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
> +
> +	seq_pr_info(m, "pgrefill %lu\n", events[PGREFILL]);
> +	seq_pr_info(m, "pgscan %lu\n", events[PGSCAN_KSWAPD] +
> +		    events[PGSCAN_DIRECT]);
> +	seq_pr_info(m, "pgsteal %lu\n", events[PGSTEAL_KSWAPD] +
> +		    events[PGSTEAL_DIRECT]);
> +	seq_pr_info(m, "pgactivate %lu\n", events[PGACTIVATE]);
> +	seq_pr_info(m, "pgdeactivate %lu\n", events[PGDEACTIVATE]);
> +	seq_pr_info(m, "pglazyfree %lu\n", events[PGLAZYFREE]);
> +	seq_pr_info(m, "pglazyfreed %lu\n", events[PGLAZYFREED]);
>  
> +	seq_pr_info(m, "workingset_refault %lu\n",
> +		    stat[WORKINGSET_REFAULT]);
> +	seq_pr_info(m, "workingset_activate %lu\n",
> +		    stat[WORKINGSET_ACTIVATE]);
> +	seq_pr_info(m, "workingset_nodereclaim %lu\n",
> +		    stat[WORKINGSET_NODERECLAIM]);

I'm not sure we need all theses stats in the oom report.
I'd drop the events part.

Thanks!
