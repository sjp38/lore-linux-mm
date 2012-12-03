Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 15A5A6B0070
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 12:15:36 -0500 (EST)
Date: Mon, 3 Dec 2012 18:15:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: replace cgroup_lock with memcg specific
 memcg_lock
Message-ID: <20121203171532.GG17093@dhcp22.suse.cz>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-5-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354282286-32278-5-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On Fri 30-11-12 17:31:26, Glauber Costa wrote:
[...]
> +/*
> + * must be called with memcg_lock held, unless the cgroup is guaranteed to be
> + * already dead (like in mem_cgroup_force_empty, for instance).
> + */
> +static inline bool memcg_has_children(struct mem_cgroup *memcg)
> +{
> +	return mem_cgroup_count_children(memcg) != 1;
> +}

Why not just keep list_empty(&cgrp->children) which is much simpler much
more effective and correct here as well because cgroup cannot vanish
while we are at the call because all callers come from cgroup fs?

[...]
> @@ -3900,7 +3911,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  	if (parent)
>  		parent_memcg = mem_cgroup_from_cont(parent);
>  
> -	cgroup_lock();
> +	mutex_lock(&memcg_lock);
>  
>  	if (memcg->use_hierarchy == val)
>  		goto out;
> @@ -3915,7 +3926,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  	 */
>  	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
>  				(val == 1 || val == 0)) {
> -		if (list_empty(&cont->children))
> +		if (!memcg_has_children(memcg))
>  			memcg->use_hierarchy = val;
>  		else
>  			retval = -EBUSY;

Nothing prevents from a race when a task is on the way to be attached to
the group. This means that we might miss some charges up the way to the
parent.

mem_cgroup_hierarchy_write
  					cgroup_attach_task
					  ss->can_attach() = mem_cgroup_can_attach
					    mutex_lock(&memcg_lock)
					    memcg->attach_in_progress++
					    mutex_unlock(&memcg_lock)
					    __mem_cgroup_can_attach
					      mem_cgroup_precharge_mc (*)
  mutex_lock(memcg_lock)
  memcg_has_children(memcg)==false
					  cgroup_task_migrate
  memcg->use_hierarchy = val;
					  ss->attach()

(*) All the charches here are not propagated upwards.

Fixable simply by testing attach_in_progress as well. The same applies
to all other cases so it would be much better to prepare a common helper
which does the whole magic.

[...]

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
