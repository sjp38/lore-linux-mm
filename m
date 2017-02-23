Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB1506B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 03:59:15 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id t8so19893393vke.3
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 00:59:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b1si4145370iog.75.2017.02.23.00.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 00:59:15 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1N8rUR2023630
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 03:59:14 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28sau4bt66-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 03:59:14 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 23 Feb 2017 08:59:12 -0000
Subject: Re: [PATCH 2/2] mm/cgroup: delay soft limit data allocation
References: <1487779091-31381-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1487779091-31381-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170222171132.GB26472@dhcp22.suse.cz>
 <3b8d0a31-d869-4564-0e03-ac621af43ce7@linux.vnet.ibm.com>
 <20170222182414.4r3ytqi3ajtceumo@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2017 09:59:09 +0100
MIME-Version: 1.0
In-Reply-To: <20170222182414.4r3ytqi3ajtceumo@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <f9520440-eefc-3511-4cad-825a5e58d788@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 22/02/2017 19:24, Michal Hocko wrote:
> On Wed 22-02-17 18:50:19, Laurent Dufour wrote:
>> On 22/02/2017 18:11, Michal Hocko wrote:
>>> On Wed 22-02-17 16:58:11, Laurent Dufour wrote:
>>> [...]
>>>>  static struct mem_cgroup_tree_per_node *
>>>>  soft_limit_tree_node(int nid)
>>>>  {
>>>> @@ -465,6 +497,8 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
>>>>  	struct mem_cgroup_tree_per_node *mctz;
>>>>  
>>>>  	mctz = soft_limit_tree_from_page(page);
>>>> +	if (!mctz)
>>>> +		return;
>>>>  	/*
>>>>  	 * Necessary to update all ancestors when hierarchy is used.
>>>>  	 * because their event counter is not touched.
>>>> @@ -502,7 +536,8 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
>>>>  	for_each_node(nid) {
>>>>  		mz = mem_cgroup_nodeinfo(memcg, nid);
>>>>  		mctz = soft_limit_tree_node(nid);
>>>> -		mem_cgroup_remove_exceeded(mz, mctz);
>>>> +		if (mctz)
>>>> +			mem_cgroup_remove_exceeded(mz, mctz);
>>>>  	}
>>>>  }
>>>>  
>>>
>>> this belongs to the previous patch, right?
>>
>> It may. I made the first patch fixing the panic I saw but if you prefer
>> this to be part of the first one, fair enough.
> 
> Without these you would just blow up later AFAICS so the fix is not
> complete. Also this patch is not complete because the initialization
> code should clean up if the allocation fails half way. I have tried to
> do that and it blows the code size a bit. I am not convinced this is
> worth the savings after all...

I do agree, we will have more code than the data we don't want to allocate.

Bur your proposal sounds to be the cleanest way to handle that, despite
the larger size of the code.
I'll send a new series in that way.

> 
> Here is what I ended up:
> --- 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 44fb1e80701a..54d73c20124e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -141,7 +141,7 @@ struct mem_cgroup_tree {
>  	struct mem_cgroup_tree_per_node *rb_tree_per_node[MAX_NUMNODES];
>  };
> 
> -static struct mem_cgroup_tree soft_limit_tree __read_mostly;
> +static struct mem_cgroup_tree *soft_limit_tree __read_mostly;
> 
>  /* for OOM */
>  struct mem_cgroup_eventfd_list {
> @@ -381,7 +381,9 @@ mem_cgroup_page_nodeinfo(struct mem_cgroup *memcg, struct page *page)
>  static struct mem_cgroup_tree_per_node *
>  soft_limit_tree_node(int nid)
>  {
> -	return soft_limit_tree.rb_tree_per_node[nid];
> +	if (!soft_limit_tree_node)
> +		return NULL;
> +	return soft_limit_tree->rb_tree_per_node[nid];
>  }
> 
>  static struct mem_cgroup_tree_per_node *
> @@ -389,7 +391,9 @@ soft_limit_tree_from_page(struct page *page)
>  {
>  	int nid = page_to_nid(page);
> 
> -	return soft_limit_tree.rb_tree_per_node[nid];
> +	if (!soft_limit_tree_node)
> +		return NULL;
> +	return soft_limit_tree->rb_tree_per_node[nid];
>  }
> 
>  static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_node *mz,
> @@ -2969,6 +2973,46 @@ static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
>  	return ret;
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
> +		goto out_unlock;
> +
> +	tree = kmalloc(sizeof(*soft_limit_tree), GFP_KERNEL);
> +	if (!tree) {
> +		ret = false;
> +		goto out;
> +	}
> +	for_each_node(node) {
> +		struct mem_cgroup_tree_per_node *rtpn;
> +
> +		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
> +				    node_online(node) ? node : NUMA_NO_NODE);
> +		if (!rtpn)
> +			goto out_free;
> +
> +		rtpn->rb_root = RB_ROOT;
> +		spin_lock_init(&rtpn->lock);
> +		tree->rb_tree_per_node[node] = rtpn;
> +	}
> +	WRITE_ONCE(soft_limit_tree, tree);
> +out_unlock:
> +	mutex_unlock(&soft_limit_tree);
> +	return ret;
> +out_free:
> +	for_each_node(node)
> +		kfree(tree->rb_tree_per_node[node]);
> +	kfree(tree);
> +	ret = false;
> +	goto out_unlock;
> +}
> +
>  /*
>   * The user of this function is...
>   * RES_LIMIT.
> @@ -3007,6 +3051,11 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
>  		}
>  		break;
>  	case RES_SOFT_LIMIT:
> +		if (!soft_limit_initialize()) {
> +			ret = -ENOMEM;
> +			break;
> +		}
> +
>  		memcg->soft_limit = nr_pages;
>  		ret = 0;
>  		break;
> @@ -5800,17 +5849,6 @@ static int __init mem_cgroup_init(void)
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
