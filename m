Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 677916B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 11:06:13 -0500 (EST)
Date: Fri, 18 Jan 2013 17:06:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 4/7] memcg: fast hierarchy-aware child test.
Message-ID: <20130118160610.GI10701@dhcp22.suse.cz>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
 <1357897527-15479-5-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357897527-15479-5-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Fri 11-01-13 13:45:24, Glauber Costa wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2ac2808..aa4e258 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4723,6 +4723,30 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
>  }
>  
>  /*
> + * must be called with memcg_mutex held, unless the cgroup is guaranteed to be

This one doesn't exist yet.

> + * already dead (like in mem_cgroup_force_empty, for instance).  This is
> + * different than mem_cgroup_count_children, in the sense that we don't really
> + * care how many children we have, we only need to know if we have any. It is
> + * also count any memcg without hierarchy as infertile for that matter.
> + */
> +static inline bool memcg_has_children(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *iter;
> +
> +	if (!memcg->use_hierarchy)
> +		return false;
> +
> +	/* bounce at first found */
> +	for_each_mem_cgroup_tree(iter, memcg) {

This will not work. Consider you will see a !online memcg. What happens?
mem_cgroup_iter will css_get group that it returns and css_put it when
it visits another one or finishes the loop. So your poor iter will be
released before it gets born. Not good.

> +		if ((iter == memcg) || !mem_cgroup_online(iter))
> +			continue;
> +		return true;

mem_cgroup_iter_break here if you _really_ insist on
for_each_mem_cgroup_tree.

I still think that the hammer is too big for what we need here.

> +	}
> +
> +	return false;
> +}
> +
> +/*
>   * Reclaims as many pages from the given memcg as possible and moves
>   * the rest to the parent.
>   *
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
