Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 81C816B0088
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 10:11:53 -0500 (EST)
Date: Tue, 29 Jan 2013 16:11:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 6/6] memcg: init/free swap cgroup strucutres upon
 create/free child memcg
Message-ID: <20130129151150.GH29574@dhcp22.suse.cz>
References: <510658E3.1020306@oracle.com>
 <510658FC.50009@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510658FC.50009@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org

On Mon 28-01-13 18:54:52, Jeff Liu wrote:
> Initialize swap_cgroup strucutres when creating a non-root memcg,
> swap_cgroup_init() will be called for multiple times but only does
> buffer allocation per the first non-root memcg.
> 
> Free swap_cgroup structures correspondingly on the last non-root memcg
> removal.
> 
> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
> CC: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Sha Zhengju <handai.szj@taobao.com>

OK, looks good to me. Except for the outdated tree you are based on.
You should hook into mem_cgroup_css_online for the creation path.

Please fold this into the previous patch. It won't make it harder to
review and we will have all users of init/free in one patch.

Acked-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index afe5e86..031d242 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5998,6 +5998,7 @@ static void free_work(struct work_struct *work)
>  
>  	memcg = container_of(work, struct mem_cgroup, work_freeing);
>  	__mem_cgroup_free(memcg);
> +	swap_cgroup_free();
>  }
>  
>  static void free_rcu(struct rcu_head *rcu_head)
> @@ -6116,6 +6117,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  			INIT_WORK(&stock->work, drain_local_stock);
>  		}
>  	} else {
> +		if (swap_cgroup_init())
> +			goto free_out;
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		memcg->use_hierarchy = parent->use_hierarchy;
>  		memcg->oom_kill_disable = parent->oom_kill_disable;
> -- 
> 1.7.9.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
