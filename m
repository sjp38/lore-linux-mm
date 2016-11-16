Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 412EA6B0038
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 04:01:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so19229206wmd.6
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 01:01:44 -0800 (PST)
Received: from smtp4.mail.ru (smtp4.mail.ru. [94.100.179.57])
        by mx.google.com with ESMTPS id u82si16641490lfg.289.2016.11.16.01.01.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Nov 2016 01:01:42 -0800 (PST)
Date: Wed, 16 Nov 2016 12:01:29 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [RESEND] [PATCH v1 1/3] Add basic infrastructure for memcg
 hotplug support
Message-ID: <20161116090129.GA18225@esperanza>
References: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
 <1479253501-26261-2-git-send-email-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479253501-26261-2-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: mpe@ellerman.id.au, hannes@cmpxchg.org, mhocko@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Wed, Nov 16, 2016 at 10:44:59AM +1100, Balbir Singh wrote:
> The lack of hotplug support makes us allocate all memory
> upfront for per node data structures. With large number
> of cgroups this can be an overhead. PPC64 actually limits
> n_possible nodes to n_online to avoid some of this overhead.
> 
> This patch adds the basic notifiers to listen to hotplug
> events and does the allocation and free of those structures
> per cgroup. We walk every cgroup per event, its a trade-off
> of allocating upfront vs allocating on demand and freeing
> on offline.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org> 
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> 
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>
> ---
>  mm/memcontrol.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 60 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 91dfc7c..5585fce 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -63,6 +63,7 @@
>  #include <linux/lockdep.h>
>  #include <linux/file.h>
>  #include <linux/tracehook.h>
> +#include <linux/memory.h>
>  #include "internal.h"
>  #include <net/sock.h>
>  #include <net/ip.h>
> @@ -1342,6 +1343,10 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
>  {
>  	return 0;
>  }
> +
> +static void mem_cgroup_may_update_nodemask(struct mem_cgroup *memcg)
> +{
> +}
>  #endif
>  
>  static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
> @@ -4115,14 +4120,7 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
>  {
>  	struct mem_cgroup_per_node *pn;
>  	int tmp = node;
> -	/*
> -	 * This routine is called against possible nodes.
> -	 * But it's BUG to call kmalloc() against offline node.
> -	 *
> -	 * TODO: this routine can waste much memory for nodes which will
> -	 *       never be onlined. It's better to use memory hotplug callback
> -	 *       function.
> -	 */
> +
>  	if (!node_state(node, N_NORMAL_MEMORY))
>  		tmp = -1;
>  	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
> @@ -5773,6 +5771,59 @@ static int __init cgroup_memory(char *s)
>  }
>  __setup("cgroup.memory=", cgroup_memory);
>  
> +static void memcg_node_offline(int node)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	if (node < 0)
> +		return;

Is this possible?

> +
> +	for_each_mem_cgroup(memcg) {
> +		free_mem_cgroup_per_node_info(memcg, node);
> +		mem_cgroup_may_update_nodemask(memcg);

If memcg->numainfo_events is 0, mem_cgroup_may_update_nodemask() won't
update memcg->scan_nodes. Is it OK?

> +	}

What if a memory cgroup is created or destroyed while you're walking the
tree? Should we probably use get_online_mems() in mem_cgroup_alloc() to
avoid that?

> +}
> +
> +static void memcg_node_online(int node)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	if (node < 0)
> +		return;
> +
> +	for_each_mem_cgroup(memcg) {
> +		alloc_mem_cgroup_per_node_info(memcg, node);
> +		mem_cgroup_may_update_nodemask(memcg);
> +	}
> +}
> +
> +static int memcg_memory_hotplug_callback(struct notifier_block *self,
> +					unsigned long action, void *arg)
> +{
> +	struct memory_notify *marg = arg;
> +	int node = marg->status_change_nid;
> +
> +	switch (action) {
> +	case MEM_GOING_OFFLINE:
> +	case MEM_CANCEL_ONLINE:
> +		memcg_node_offline(node);

Judging by __offline_pages(), the MEM_GOING_OFFLINE event is emitted
before migrating pages off the node. So, I guess freeing per-node info
here isn't quite correct, as pages still need it to be moved from the
node's LRU lists. Better move it to MEM_OFFLINE?

> +		break;
> +	case MEM_GOING_ONLINE:
> +	case MEM_CANCEL_OFFLINE:
> +		memcg_node_online(node);
> +		break;
> +	case MEM_ONLINE:
> +	case MEM_OFFLINE:
> +		break;
> +	}
> +	return NOTIFY_OK;
> +}
> +
> +static struct notifier_block memcg_memory_hotplug_nb __meminitdata = {
> +	.notifier_call = memcg_memory_hotplug_callback,
> +	.priority = IPC_CALLBACK_PRI,

I wonder why you chose this priority?

> +};
> +
>  /*
>   * subsys_initcall() for memory controller.
>   *
> @@ -5797,6 +5848,7 @@ static int __init mem_cgroup_init(void)
>  #endif
>  
>  	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
> +	register_hotmemory_notifier(&memcg_memory_hotplug_nb);
>  
>  	for_each_possible_cpu(cpu)
>  		INIT_WORK(&per_cpu_ptr(&memcg_stock, cpu)->work,

I guess, we should modify mem_cgroup_alloc/free() in the scope of this
patch, otherwise it doesn't make much sense IMHO. May be, it's even
worth merging patches 1 and 2 altogether.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
