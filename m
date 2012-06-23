Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 847496B02AD
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 05:40:16 -0400 (EDT)
Date: Sat, 23 Jun 2012 11:39:34 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] memcg: optimize memcg_get_hierarchical_limit
Message-ID: <20120623093934.GN27816@cmpxchg.org>
References: <1340432297-5362-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340432297-5362-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On Sat, Jun 23, 2012 at 02:18:17PM +0800, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Optimize memcg_get_hierarchical_limit to save cpu cycle.
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

I really would have thought the compiler would detect it, but this
patch actually does switch around move and jump.

But this is miniscule and anything but a fastpath...

> ---
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c821e36..1ca79e2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3917,9 +3917,9 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
>  
>  	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
>  	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -	cgroup = memcg->css.cgroup;
>  	if (!memcg->use_hierarchy)
>  		goto out;
> +	cgroup = memcg->css.cgroup;
>  
>  	while (cgroup->parent) {
>  		cgroup = cgroup->parent;
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
