Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 97F876B005C
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 19:25:39 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 484EB3EE0B5
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:25:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F1C02AEA81
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:25:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 04A04227D24
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:25:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E8F0D1DB803E
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:25:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ACD21DB8037
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:25:37 +0900 (JST)
Date: Wed, 21 Dec 2011 09:24:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: malloc memory for possible node in hotplug
Message-Id: <20111221092426.0c8c1521.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1324375503-31487-1-git-send-email-lliubbo@gmail.com>
References: <1324375503-31487-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, bsingharora@gmail.com

On Tue, 20 Dec 2011 18:05:03 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> Current struct mem_cgroup_per_node and struct mem_cgroup_tree_per_node are
> malloced for all possible node during system boot.
> 
> This may cause some memory waste, better if move it to memory hotplug.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Ying Han and google people tries to remove this rb_tree completely now.
So, could you wait for a while ?

And I'm not sure how benefical this is...
Are we safe at freeing the node at OFFLINE without confirming there are no
reference ?

Thanks,
-Kame

> ---
>  mm/memcontrol.c |   89 +++++++++++++++++++++++++++++++++++++++++-------------
>  1 files changed, 67 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a3d0420..a7a906b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -570,7 +570,7 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
>  	struct mem_cgroup_per_zone *mz;
>  	struct mem_cgroup_tree_per_zone *mctz;
>  
> -	for_each_node(node) {
> +	for_each_node_state(nid, N_NORMAL_MEMORY) {
>  		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>  			mz = mem_cgroup_zoneinfo(memcg, node, zone);
>  			mctz = soft_limit_tree_node_zone(node, zone);
> @@ -4894,18 +4894,9 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>  	struct mem_cgroup_per_node *pn;
>  	struct mem_cgroup_per_zone *mz;
>  	enum lru_list l;
> -	int zone, tmp = node;
> -	/*
> -	 * This routine is called against possible nodes.
> -	 * But it's BUG to call kmalloc() against offline node.
> -	 *
> -	 * TODO: this routine can waste much memory for nodes which will
> -	 *       never be onlined. It's better to use memory hotplug callback
> -	 *       function.
> -	 */
> -	if (!node_state(node, N_NORMAL_MEMORY))
> -		tmp = -1;
> -	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
> +	int zone;
> +
> +	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, node);
>  	if (!pn)
>  		return 1;
>  
> @@ -4972,7 +4963,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  	mem_cgroup_remove_from_trees(memcg);
>  	free_css_id(&mem_cgroup_subsys, &memcg->css);
>  
> -	for_each_node(node)
> +	for_each_node_state(nid, N_NORMAL_MEMORY)
>  		free_mem_cgroup_per_zone_info(memcg, node);
>  
>  	free_percpu(memcg->stat);
> @@ -5025,17 +5016,70 @@ static void __init enable_swap_cgroup(void)
>  }
>  #endif
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +static int __meminit memcg_mem_hotplug_callback(struct notifier_block *self,
> +			       unsigned long action, void *arg)
> +{
> +	struct memory_notify *mn = arg;
> +	struct mem_cgroup *iter;
> +	struct mem_cgroup_tree_per_node *rtpn;
> +	struct mem_cgroup_tree_per_zone *rtpz;
> +	int ret = 0;
> +	int nid = mn->status_change_nid;
> +	int zone;
> +
> +	switch (action) {
> +	case MEM_ONLINE:
> +		if (nid != -1) {
> +			for_each_mem_cgroup(iter){
> +				ret = alloc_mem_cgroup_per_zone_info(iter, nid);
> +				if (ret)
> +					goto free_out;
> +			}
> +
> +			rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, nid);
> +			if (!rtpn)
> +				goto free_out;
> +
> +			soft_limit_tree.rb_tree_per_node[nid] = rtpn;
> +
> +			for (zone = 0; zone < MAX_NR_ZONES; zone++) {
> +				rtpz = &rtpn->rb_tree_per_zone[zone];
> +				rtpz->rb_root = RB_ROOT;
> +				spin_lock_init(&rtpz->lock);
> +			}
> +		}
> +		break;
> +	case MEM_OFFLINE:
> +		if (nid != -1) {
> +			rtpn = soft_limit_tree.rb_tree_per_node[nid];
> +			if (rtpn) {
> +				kfree(rtpn);
> +				soft_limit_tree.rb_tree_per_node[nid] = NULL;
> +			}
> +			goto free_out;
> +		}
> +		break;
> +	}
> +
> +out:
> +	return notifier_from_errno(ret);
> +
> +free_out:
> +	for_each_mem_cgroup(iter)
> +		free_mem_cgroup_per_zone_info(iter, nid);
> +	goto out;
> +}
> +#endif
> +
>  static int mem_cgroup_soft_limit_tree_init(void)
>  {
>  	struct mem_cgroup_tree_per_node *rtpn;
>  	struct mem_cgroup_tree_per_zone *rtpz;
> -	int tmp, node, zone;
> +	int node, zone;
>  
> -	for_each_node(node) {
> -		tmp = node;
> -		if (!node_state(node, N_NORMAL_MEMORY))
> -			tmp = -1;
> -		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
> +	for_each_node_state(nid, N_NORMAL_MEMORY) {
> +		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, node);
>  		if (!rtpn)
>  			goto err_cleanup;
>  
> @@ -5050,7 +5094,7 @@ static int mem_cgroup_soft_limit_tree_init(void)
>  	return 0;
>  
>  err_cleanup:
> -	for_each_node(node) {
> +	for_each_node_state(nid, N_NORMAL_MEMORY) {
>  		if (!soft_limit_tree.rb_tree_per_node[node])
>  			break;
>  		kfree(soft_limit_tree.rb_tree_per_node[node]);
> @@ -5071,7 +5115,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (!memcg)
>  		return ERR_PTR(error);
>  
> -	for_each_node(node)
> +	for_each_node_state(nid, N_NORMAL_MEMORY)
>  		if (alloc_mem_cgroup_per_zone_info(memcg, node))
>  			goto free_out;
>  
> @@ -5119,6 +5163,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	atomic_set(&memcg->refcnt, 1);
>  	memcg->move_charge_at_immigrate = 0;
>  	mutex_init(&memcg->thresholds_lock);
> +	hotplug_memory_notifier(memcg_mem_hotplug_callback, 0);
>  	return &memcg->css;
>  free_out:
>  	__mem_cgroup_free(memcg);
> -- 
> 1.7.0.4
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
