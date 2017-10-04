Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2396B025F
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:10:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i195so24932554pgd.2
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:10:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u186sor991044pgb.236.2017.10.04.13.10.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 13:10:46 -0700 (PDT)
Date: Wed, 4 Oct 2017 13:10:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v10 2/6] mm: implement mem_cgroup_scan_tasks() for the root
 memory cgroup
In-Reply-To: <20171004154638.710-3-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1710041308510.67374@chino.kir.corp.google.com>
References: <20171004154638.710-1-guro@fb.com> <20171004154638.710-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 4 Oct 2017, Roman Gushchin wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d5f3a62887cf..b4de17a78dc1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -917,7 +917,8 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
>   * value, the function breaks the iteration loop and returns the value.
>   * Otherwise, it will iterate over all tasks and return 0.
>   *
> - * This function must not be called for the root memory cgroup.
> + * If memcg is the root memory cgroup, this function will iterate only
> + * over tasks belonging directly to the root memory cgroup.
>   */
>  int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
>  			  int (*fn)(struct task_struct *, void *), void *arg)
> @@ -925,8 +926,6 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
>  	struct mem_cgroup *iter;
>  	int ret = 0;
>  
> -	BUG_ON(memcg == root_mem_cgroup);
> -
>  	for_each_mem_cgroup_tree(iter, memcg) {
>  		struct css_task_iter it;
>  		struct task_struct *task;
> @@ -935,7 +934,7 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
>  		while (!ret && (task = css_task_iter_next(&it)))
>  			ret = fn(task, arg);
>  		css_task_iter_end(&it);
> -		if (ret) {
> +		if (ret || memcg == root_mem_cgroup) {
>  			mem_cgroup_iter_break(memcg, iter);
>  			break;
>  		}

I think this is fine, but a little strange to start an iteration that 
never loops :)  No objection to the patch but it could also be extracted 
into a new mem_cgroup_scan_tasks() which actually scans the tasks in that 
mem cgroup and then a wrapper that does the iteration that calls into it, 
say, mem_cgroup_scan_tasks_tree().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
