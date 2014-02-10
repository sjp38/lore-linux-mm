Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9E30A6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:41:52 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id q59so4212656wes.23
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:41:51 -0800 (PST)
Received: from mail-we0-x22b.google.com (mail-we0-x22b.google.com [2a00:1450:400c:c03::22b])
        by mx.google.com with ESMTPS id fc7si7721208wjc.108.2014.02.10.06.41.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 06:41:50 -0800 (PST)
Received: by mail-we0-f171.google.com with SMTP id u56so4349412wes.30
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:41:50 -0800 (PST)
Date: Mon, 10 Feb 2014 15:41:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 6/8] memcg: get_mem_cgroup_from_mm()
Message-ID: <20140210144148.GK7117@dhcp22.suse.cz>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
 <1391792665-21678-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391792665-21678-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 07-02-14 12:04:23, Johannes Weiner wrote:
> Instead of returning NULL from try_get_mem_cgroup_from_mm() when the
> mm owner is exiting, just return root_mem_cgroup.  This makes sense
> for all callsites and gets rid of some of them having to fallback
> manually.

It makes sense now that css reference counting is basically for free
so we do not have to prevent reference counting on the root.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c | 18 ++++--------------
>  1 file changed, 4 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 689fffdee471..37946635655c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1071,7 +1071,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>  	return mem_cgroup_from_css(task_css(p, mem_cgroup_subsys_id));
>  }
>  
> -struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> +struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
>  {
>  	struct mem_cgroup *memcg = NULL;
>  
> @@ -1079,7 +1079,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>  	do {
>  		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
>  		if (unlikely(!memcg))
> -			break;
> +			memcg = root_mem_cgroup;
>  	} while (!css_tryget(&memcg->css));
>  	rcu_read_unlock();
>  	return memcg;
> @@ -1475,7 +1475,7 @@ bool task_in_mem_cgroup(struct task_struct *task,
>  
>  	p = find_lock_task_mm(task);
>  	if (p) {
> -		curr = try_get_mem_cgroup_from_mm(p->mm);
> +		curr = get_mem_cgroup_from_mm(p->mm);
>  		task_unlock(p);
>  	} else {
>  		/*
> @@ -1489,8 +1489,6 @@ bool task_in_mem_cgroup(struct task_struct *task,
>  			css_get(&curr->css);
>  		rcu_read_unlock();
>  	}
> -	if (!curr)
> -		return false;
>  	/*
>  	 * We should check use_hierarchy of "memcg" not "curr". Because checking
>  	 * use_hierarchy of "curr" here make this function true if hierarchy is
> @@ -3649,15 +3647,7 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
>  	if (!current->mm || current->memcg_kmem_skip_account)
>  		return true;
>  
> -	memcg = try_get_mem_cgroup_from_mm(current->mm);
> -
> -	/*
> -	 * very rare case described in mem_cgroup_from_task. Unfortunately there
> -	 * isn't much we can do without complicating this too much, and it would
> -	 * be gfp-dependent anyway. Just let it go
> -	 */
> -	if (unlikely(!memcg))
> -		return true;
> +	memcg = get_mem_cgroup_from_mm(current->mm);
>  
>  	if (!memcg_can_account_kmem(memcg)) {
>  		css_put(&memcg->css);
> -- 
> 1.8.5.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
