Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id D8E7B6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 09:29:33 -0500 (EST)
Date: Tue, 20 Dec 2011 15:29:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/3] memcg: cleanup for_each_node_state()
Message-ID: <20111220142930.GK10565@tiehlicka.suse.cz>
References: <1324375312-31252-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1324375312-31252-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Tue 20-12-11 18:01:52, Bob Liu wrote:
> We already have for_each_node(node) define in nodemask.h, better to use it.

Yes seems to be the last user of the for_each_node_state(N_POSSIBLE) in
the tree.

> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  mm/memcontrol.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6a417fe..a3d0420 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -570,7 +570,7 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
>  	struct mem_cgroup_per_zone *mz;
>  	struct mem_cgroup_tree_per_zone *mctz;
>  
> -	for_each_node_state(node, N_POSSIBLE) {
> +	for_each_node(node) {
>  		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>  			mz = mem_cgroup_zoneinfo(memcg, node, zone);
>  			mctz = soft_limit_tree_node_zone(node, zone);
> @@ -4972,7 +4972,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  	mem_cgroup_remove_from_trees(memcg);
>  	free_css_id(&mem_cgroup_subsys, &memcg->css);
>  
> -	for_each_node_state(node, N_POSSIBLE)
> +	for_each_node(node)
>  		free_mem_cgroup_per_zone_info(memcg, node);
>  
>  	free_percpu(memcg->stat);
> @@ -5031,7 +5031,7 @@ static int mem_cgroup_soft_limit_tree_init(void)
>  	struct mem_cgroup_tree_per_zone *rtpz;
>  	int tmp, node, zone;
>  
> -	for_each_node_state(node, N_POSSIBLE) {
> +	for_each_node(node) {
>  		tmp = node;
>  		if (!node_state(node, N_NORMAL_MEMORY))
>  			tmp = -1;
> @@ -5050,7 +5050,7 @@ static int mem_cgroup_soft_limit_tree_init(void)
>  	return 0;
>  
>  err_cleanup:
> -	for_each_node_state(node, N_POSSIBLE) {
> +	for_each_node(node) {
>  		if (!soft_limit_tree.rb_tree_per_node[node])
>  			break;
>  		kfree(soft_limit_tree.rb_tree_per_node[node]);
> @@ -5071,7 +5071,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (!memcg)
>  		return ERR_PTR(error);
>  
> -	for_each_node_state(node, N_POSSIBLE)
> +	for_each_node(node)
>  		if (alloc_mem_cgroup_per_zone_info(memcg, node))
>  			goto free_out;
>  
> -- 
> 1.7.0.4
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
