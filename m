Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D31A6B0388
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 10:31:10 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so1070274wmv.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 07:31:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si7352303wmu.159.2017.02.23.07.31.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 07:31:08 -0800 (PST)
Date: Thu, 23 Feb 2017 16:31:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] mm/cgroup: delay soft limit data allocation
Message-ID: <20170223153107.GD29056@dhcp22.suse.cz>
References: <1487856999-16581-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1487856999-16581-3-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487856999-16581-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 23-02-17 14:36:39, Laurent Dufour wrote:
> Until a soft limit is set to a cgroup, the soft limit data are useless
> so delay this allocation when a limit is set.

Hmm, I am still undecided whether this is actually worth it. On one hand
distribution kernels tend to have quite large NUMA_SHIFT (e.g. SLES has
NUMA_SHIFT=10 and then we will save 8kB+12kB which is not hell of a lot
but always good if we can save that, especially for a rarely used
feature. The code grown on the other hand (it was in __init section
previously) which is a minus, on the other hand.

What do you think Johannes?

This would be a useful info in the changelog, btw.

> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

The patch looks good to me so feel free to add
Reviewed-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 67 ++++++++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 52 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a9f10fde44a6..c639c898809d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -142,7 +142,7 @@ struct mem_cgroup_tree {
>  	struct mem_cgroup_tree_per_node *rb_tree_per_node[MAX_NUMNODES];
>  };
>  
> -static struct mem_cgroup_tree soft_limit_tree __read_mostly;
> +static struct mem_cgroup_tree *soft_limit_tree __read_mostly;
>  
>  /* for OOM */
>  struct mem_cgroup_eventfd_list {
> @@ -381,10 +381,52 @@ mem_cgroup_page_nodeinfo(struct mem_cgroup *memcg, struct page *page)
>  	return memcg->nodeinfo[nid];
>  }
>  
> +static bool soft_limit_initialize(void)
> +{
> +	static DEFINE_MUTEX(soft_limit_mutex);
> +	struct mem_cgroup_tree *tree;
> +	bool ret = true;
> +	int node;
> +
> +	mutex_lock(&soft_limit_mutex);
> +	if (soft_limit_tree)
> +		goto bail;
> +
> +	tree = kmalloc(sizeof(*soft_limit_tree), GFP_KERNEL);
> +	if (!tree) {
> +		ret = false;
> +		goto bail;
> +	}
> +	for_each_node(node) {
> +		struct mem_cgroup_tree_per_node *rtpn;
> +
> +		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
> +				    node_online(node) ? node : NUMA_NO_NODE);
> +		if (!rtpn)
> +			goto cleanup;
> +
> +		rtpn->rb_root = RB_ROOT;
> +		spin_lock_init(&rtpn->lock);
> +		tree->rb_tree_per_node[node] = rtpn;
> +	}
> +	WRITE_ONCE(soft_limit_tree, tree);
> +bail:
> +	mutex_unlock(&soft_limit_mutex);
> +	return ret;
> +cleanup:
> +	for_each_node(node)
> +		kfree(tree->rb_tree_per_node[node]);
> +	kfree(tree);
> +	ret = false;
> +	goto bail;
> +}
> +
>  static struct mem_cgroup_tree_per_node *
>  soft_limit_tree_node(int nid)
>  {
> -	return soft_limit_tree.rb_tree_per_node[nid];
> +	if (!soft_limit_tree)
> +		return NULL;
> +	return soft_limit_tree->rb_tree_per_node[nid];
>  }
>  
>  static struct mem_cgroup_tree_per_node *
> @@ -392,7 +434,9 @@ soft_limit_tree_from_page(struct page *page)
>  {
>  	int nid = page_to_nid(page);
>  
> -	return soft_limit_tree.rb_tree_per_node[nid];
> +	if (!soft_limit_tree)
> +		return NULL;
> +	return soft_limit_tree->rb_tree_per_node[nid];
>  }
>  
>  static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_node *mz,
> @@ -3003,6 +3047,10 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
>  		}
>  		break;
>  	case RES_SOFT_LIMIT:
> +		if (!soft_limit_initialize()) {
> +			ret = -ENOMEM;
> +			break;
> +		}
>  		memcg->soft_limit = nr_pages;
>  		ret = 0;
>  		break;
> @@ -5777,7 +5825,7 @@ __setup("cgroup.memory=", cgroup_memory);
>   */
>  static int __init mem_cgroup_init(void)
>  {
> -	int cpu, node;
> +	int cpu;
>  
>  #ifndef CONFIG_SLOB
>  	/*
> @@ -5797,17 +5845,6 @@ static int __init mem_cgroup_init(void)
>  		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,
>  			  drain_local_stock);
>  
> -	for_each_node(node) {
> -		struct mem_cgroup_tree_per_node *rtpn;
> -
> -		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
> -				    node_online(node) ? node : NUMA_NO_NODE);
> -
> -		rtpn->rb_root = RB_ROOT;
> -		spin_lock_init(&rtpn->lock);
> -		soft_limit_tree.rb_tree_per_node[node] = rtpn;
> -	}
> -
>  	return 0;
>  }
>  subsys_initcall(mem_cgroup_init);
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
