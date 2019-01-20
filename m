Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A296C8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 13:05:08 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e68so11571750plb.3
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 10:05:08 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l33si10610041pld.142.2019.01.20.10.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 10:05:07 -0800 (PST)
Date: Sun, 20 Jan 2019 19:05:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/5] Memcgroup: Add timer to trigger workqueue
Message-ID: <20190120180505.GH4087@dhcp22.suse.cz>
References: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
 <1547955021-11520-3-git-send-email-duanxiongchun@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547955021-11520-3-git-send-email-duanxiongchun@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiongchun Duan <duanxiongchun@bytedance.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, shy828301@gmail.com, tj@kernel.org, hannes@cmpxchg.org, zhangyongsu@bytedance.com, liuxiaozhou@bytedance.com, zhengfeiran@bytedance.com, wangdongdong.6@bytedance.com

On Sat 19-01-19 22:30:18, Xiongchun Duan wrote:
> Add timer to trigger workqueue which will scan offline memcgroup and call trigger
> memcgroup force_empty worker to force_empty itself.

This requires much more explanation but it looks like a complete hack to
me. Why do we need a timer at all? Why is the hardcoded timeout a
generic enough?

> Signed-off-by: Xiongchun Duan <duanxiongchun@bytedance.com>
> ---
>  include/linux/memcontrol.h |  1 +
>  mm/memcontrol.c            | 23 +++++++++++++++++++++++
>  2 files changed, 24 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d6fbb77..0a29f7f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -313,6 +313,7 @@ struct mem_cgroup {
>  
>  	int max_retry;
>  	int current_retry;
> +	unsigned long timer_jiffies;
>  
>  	struct mem_cgroup_per_node *nodeinfo[0];
>  	/* WARNING: nodeinfo must be the last member here */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2b13c2b..4db08b7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -81,6 +81,8 @@
>  int sysctl_cgroup_default_retry_min;
>  int sysctl_cgroup_default_retry_max = 16;
>  
> +struct timer_list empty_trigger;
> +
>  struct mem_cgroup *root_mem_cgroup __read_mostly;
>  
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
> @@ -2933,6 +2935,11 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
>  	return mem_cgroup_force_empty(memcg) ?: nbytes;
>  }
>  
> +static void add_force_empty_list(struct mem_cgroup *memcg)
> +{
> +
> +}
> +
>  static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
>  				     struct cftype *cft)
>  {
> @@ -4566,11 +4573,26 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	return 0;
>  }
>  
> +void empty_timer_trigger(struct timer_list *t)
> +{
> +
> +}
> +
>  static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup_event *event, *tmp;
>  
> +	if (memcg->max_retry != 0) {
> +		memcg->current_retry = 1;
> +		mem_cgroup_force_empty(memcg);
> +		if (page_counter_read(&memcg->memory) &&
> +				memcg->max_retry != 1) {
> +			memcg->timer_jiffies = jiffies + HZ;
> +			add_force_empty_list(memcg);
> +		}
> +	}
> +
>  	/*
>  	 * Unregister events and notify userspace.
>  	 * Notify userspace about cgroup removing only after rmdir of cgroup
> @@ -6368,6 +6390,7 @@ static int __init mem_cgroup_init(void)
>  	memcg_kmem_cache_wq = alloc_workqueue("memcg_kmem_cache", 0, 1);
>  	BUG_ON(!memcg_kmem_cache_wq);
>  #endif
> +	timer_setup(&empty_trigger, empty_timer_trigger, 0);
>  
>  	cpuhp_setup_state_nocalls(CPUHP_MM_MEMCQ_DEAD, "mm/memctrl:dead", NULL,
>  				  memcg_hotplug_cpu_dead);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
