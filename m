Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 2A0796B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 05:08:53 -0400 (EDT)
Date: Thu, 21 Mar 2013 10:08:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130321090849.GF6094@dhcp22.suse.cz>
References: <514A60CD.60208@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514A60CD.60208@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>

On Thu 21-03-13 09:22:21, Li Zefan wrote:
> As cgroup supports rename, it's unsafe to dereference dentry->d_name
> without proper vfs locks. Fix this by using cgroup_name().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
> 
> This patch depends on "cgroup: fix cgroup_path() vs rename() race",
> which has been queued for 3.10.
> 
> ---
>  mm/memcontrol.c | 15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 53b8201..72be5c9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3217,17 +3217,16 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>  static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
>  {
>  	char *name;
> -	struct dentry *dentry;
> +
> +	name = (char *)__get_free_page(GFP_TEMPORARY);

Ouch. Can we use a static temporary buffer instead? This is called from
workqueue context so we do not have to be afraid of the deep call chain.
It is also not a hot path AFAICS.

Even GFP_ATOMIC for kasprintf would be an improvement IMO.

> +	if (!name)
> +		return NULL;
>  
>  	rcu_read_lock();
> -	dentry = rcu_dereference(memcg->css.cgroup->dentry);
> +	snprintf(name, PAGE_SIZE, "%s(%d:%s)", s->name, memcg_cache_id(memcg),
> +		 cgroup_name(memcg->css.cgroup));
>  	rcu_read_unlock();
>  
> -	BUG_ON(dentry == NULL);
> -
> -	name = kasprintf(GFP_KERNEL, "%s(%d:%s)", s->name,
> -			 memcg_cache_id(memcg), dentry->d_name.name);
> -
>  	return name;
>  }
>  
> @@ -3247,7 +3246,7 @@ static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
>  	if (new)
>  		new->allocflags |= __GFP_KMEMCG;
>  
> -	kfree(name);
> +	free_page((unsigned long)name);
>  	return new;
>  }
>  
> -- 
> 1.8.0.2
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
