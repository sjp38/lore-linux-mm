Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 0ABE76B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 10:20:46 -0400 (EDT)
Date: Wed, 24 Jul 2013 16:20:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 4/8] memcg: convert to use cgroup_is_descendant()
Message-ID: <20130724142044.GG2540@dhcp22.suse.cz>
References: <51EFA554.6080801@huawei.com>
 <51EFA5F5.3020406@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51EFA5F5.3020406@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed 24-07-13 18:01:25, Li Zefan wrote:
> This is a preparation to kill css_id.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

css_is_ancestor doesn't depend on the depth of the hierarchy while
cgroup_is_descendant does. I do not think this would be an issue though
as __mem_cgroup_same_or_subtree is not called from any hot path.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d12ca6f..626c426 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1434,7 +1434,7 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  		return true;
>  	if (!root_memcg->use_hierarchy || !memcg)
>  		return false;
> -	return css_is_ancestor(&memcg->css, &root_memcg->css);
> +	return cgroup_is_descendant(memcg->css.cgroup, root_memcg->css.cgroup);
>  }
>  
>  static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> -- 
> 1.8.0.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
