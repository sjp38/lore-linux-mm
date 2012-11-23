Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 60FEE6B006C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 03:55:38 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb30so2850101vcb.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 00:55:37 -0800 (PST)
Date: Fri, 23 Nov 2012 09:55:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] cgroup: helper do determine group name
Message-ID: <20121123085532.GC24698@dhcp22.suse.cz>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
 <1353580190-14721-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1353580190-14721-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On Thu 22-11-12 14:29:49, Glauber Costa wrote:
> With more than one user, it is useful to have a helper function in the
> cgroup core to derive a group's name.
> 
> We'll just return a pointer, and it is not expected to get incredibly
> complicated. But it is useful to have it so we can abstract away the
> vfs relation from its users.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Tejun Heo <tj@kernel.org>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>

Looks good to me in general. Minor comments bellow.
Anyway.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> Tejun:
> 
> I know the rcu is no longer necessary. I am using mhocko's tree,
> that doesn't seem to have your last stream of patches yet.

Which patches are we talking about? Are they in a pullable (for -mm)
branch or I have to cherry-pick them?

> If you approve the interface, we'll need a follow up on this to remove
> the rcu dereference of the dentry.
> 
>  include/linux/cgroup.h |  1 +
>  kernel/cgroup.c        |  9 +++++++++
>  mm/memcontrol.c        | 11 ++++-------
>  3 files changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index a178a91..57c4ab1 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -401,6 +401,7 @@ int cgroup_rm_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts);
>  int cgroup_is_removed(const struct cgroup *cgrp);
>  
>  int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
> +extern const char *cgroup_name(const struct cgroup *cgrp);
>  
>  int cgroup_task_count(const struct cgroup *cgrp);
>  
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 3d68aad..d0d291e 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1757,6 +1757,15 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
>  }
>  EXPORT_SYMBOL_GPL(cgroup_path);
>  

This expects css reference at caller, right. Please make it explicit
here in case somebody wants to use this somewhere else.
Besides that rcu_read_{un}lock are not necessary if you keep the
reference, right? The last dput happens only after the last css_put.

> +const char *cgroup_name(const struct cgroup *cgrp)
> +{
> +	struct dentry *dentry;
> +	rcu_read_lock();
> +	dentry = rcu_dereference_check(cgrp->dentry, cgroup_lock_is_held());
> +	rcu_read_unlock();
> +	return dentry->d_name.name;
> +}
> +
>  /*
>   * Control Group taskset
>   */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e3d805f..05b87aa 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3141,16 +3141,13 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>  static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
>  {
>  	char *name;
> -	struct dentry *dentry;
> +	const char *cgname;
>  
> -	rcu_read_lock();
> -	dentry = rcu_dereference(memcg->css.cgroup->dentry);
> -	rcu_read_unlock();
> -
> -	BUG_ON(dentry == NULL);
> +	cgname = cgroup_name(memcg->css.cgroup);
> +	BUG_ON(cgname == NULL);
>  
>  	name = kasprintf(GFP_KERNEL, "%s(%d:%s)", s->name,
> -			 memcg_cache_id(memcg), dentry->d_name.name);
> +			 memcg_cache_id(memcg), cgname);
>  
>  	return name;
>  }
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
