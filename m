Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14C676B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 06:49:46 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j70so433109pgc.5
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 03:49:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v17si5180357pgb.548.2017.10.03.03.49.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 03:49:44 -0700 (PDT)
Date: Tue, 3 Oct 2017 12:49:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v9 2/5] mm: implement mem_cgroup_scan_tasks() for the root
 memory cgroup
Message-ID: <20171003104939.vm7pezgef7bqxe2v@dhcp22.suse.cz>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927130936.8601-3-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 27-09-17 14:09:33, Roman Gushchin wrote:
> Implement mem_cgroup_scan_tasks() functionality for the root
> memory cgroup to use this function for looking for a OOM victim
> task in the root memory cgroup by the cgroup-ware OOM killer.
> 
> The root memory cgroup should be treated as a leaf cgroup,
> so only tasks which are directly belonging to the root cgroup
> should be iterated over.

I would only add that this patch doesn't introduce any functionally
visible change because we never trigger oom killer with the root memcg
as the root of the hierarchy. So this is just a preparatory work for
later changes.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ae37b5624eb2..fa1a5120ce3f 100644
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
> -- 
> 2.13.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
