Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65E1E6B025E
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 16:46:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m30so2019631pgn.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 13:46:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i9sor494302pgp.382.2017.09.13.13.46.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 13:46:53 -0700 (PDT)
Date: Wed, 13 Sep 2017 13:46:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 2/4] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20170911131742.16482-3-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1709131346200.146292@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <20170911131742.16482-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 11 Sep 2017, Roman Gushchin wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 15af3da5af02..da2b12ea4667 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2661,6 +2661,231 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  	return ret;
>  }
>  
> +static long memcg_oom_badness(struct mem_cgroup *memcg,
> +			      const nodemask_t *nodemask,
> +			      unsigned long totalpages)
> +{
> +	long points = 0;
> +	int nid;
> +	pg_data_t *pgdat;
> +
> +	/*
> +	 * We don't have necessary stats for the root memcg,
> +	 * so we define it's oom_score as the maximum oom_score
> +	 * of the belonging tasks.
> +	 */
> +	if (memcg == root_mem_cgroup) {
> +		struct css_task_iter it;
> +		struct task_struct *task;
> +		long score, max_score = 0;
> +
> +		css_task_iter_start(&memcg->css, 0, &it);
> +		while ((task = css_task_iter_next(&it))) {
> +			score = oom_badness(task, memcg, nodemask,
> +					    totalpages);
> +			if (max_score > score)

score > max_score

> +				max_score = score;
> +		}
> +		css_task_iter_end(&it);
> +
> +		return max_score;
> +	}
> +
> +	for_each_node_state(nid, N_MEMORY) {
> +		if (nodemask && !node_isset(nid, *nodemask))
> +			continue;
> +
> +		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> +				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> +
> +		pgdat = NODE_DATA(nid);
> +		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> +					    NR_SLAB_UNRECLAIMABLE);
> +	}
> +
> +	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> +		(PAGE_SIZE / 1024);
> +	points += memcg_page_state(memcg, MEMCG_SOCK);
> +	points += memcg_page_state(memcg, MEMCG_SWAP);
> +
> +	return points;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
