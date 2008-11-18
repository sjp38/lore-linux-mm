Date: Tue, 18 Nov 2008 15:28:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector (v4)
Message-Id: <20081118152833.98125cdd.akpm@linux-foundation.org>
In-Reply-To: <20081116081105.25166.54820.sendpatchset@balbir-laptop>
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
	<20081116081105.25166.54820.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, rientjes@google.com, xemul@openvz.org, dhaval@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sun, 16 Nov 2008 13:41:05 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> Don't enable multiple hierarchy support by default. This patch introduces
> a features element that can be set to enable the nested depth hierarchy
> feature. This feature can only be enabled when the cgroup for which the
> feature this is enabled, has no children.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  mm/memcontrol.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 57 insertions(+), 4 deletions(-)
> 
> diff -puN mm/memcontrol.c~memcg-add-hierarchy-selector mm/memcontrol.c
> --- linux-2.6.28-rc4/mm/memcontrol.c~memcg-add-hierarchy-selector	2008-11-16 13:19:33.000000000 +0530
> +++ linux-2.6.28-rc4-balbir/mm/memcontrol.c	2008-11-16 13:19:33.000000000 +0530
> @@ -148,6 +148,10 @@ struct mem_cgroup {
>  	 * reclaimed from. Protected by cgroup_lock()
>  	 */
>  	struct mem_cgroup *last_scanned_child;
> +	/*
> +	 * Should the accounting and control be hierarchical, per subtree?
> +	 */
> +	unsigned long use_hierarchy;

This field is a boolean, but it is declared as an unsigned long and is
accessed from userspace via an API which returns a u64.  This all seems
ripe for a cleanup..

>  	int		obsolete;
>  	atomic_t	refcnt;
> @@ -1527,6 +1531,44 @@ int mem_cgroup_force_empty_write(struct 
>  }
>  
>  
> +static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
> +{
> +	return mem_cgroup_from_cont(cont)->use_hierarchy;
> +}
> +
> +static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
> +					u64 val)
> +{
> +	int retval = 0;
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +	struct cgroup *parent = cont->parent;
> +	struct mem_cgroup *parent_mem = NULL;
> +
> +	if (parent)
> +		parent_mem = mem_cgroup_from_cont(parent);
> +
> +	cgroup_lock();
> +	/*
> +	 * If parent's use_hiearchy is set, we can't make any modifications
> +	 * in the child subtrees. If it is unset, then the change can
> +	 * occur, provided the current cgroup has no children.
> +	 *
> +	 * For the root cgroup, parent_mem is NULL, we allow value to be
> +	 * set if there are no children.
> +	 */
> +	if (!parent_mem || (!parent_mem->use_hierarchy &&
> +				(val == 1 || val == 0))) {

One part of this test permits any value, but the other part restricts
values to 0 or 1.

> +		if (list_empty(&cont->children))
> +			mem->use_hierarchy = val;
> +		else
> +			retval = -EBUSY;
> +	} else
> +		retval = -EINVAL;
> +	cgroup_unlock();
> +
> +	return retval;
> +}
> +
>  static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  {
>  	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> @@ -1690,6 +1732,11 @@ static struct cftype mem_cgroup_files[] 
>  		.name = "force_empty",
>  		.trigger = mem_cgroup_force_empty_write,
>  	},
> +	{
> +		.name = "use_hierarchy",
> +		.write_u64 = mem_cgroup_hierarchy_write,
> +		.read_u64 = mem_cgroup_hierarchy_read,
> +	},
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -1865,12 +1912,18 @@ mem_cgroup_create(struct cgroup_subsys *
>  	if (cont->parent == NULL) {
>  		enable_swap_cgroup();
>  		parent = NULL;
> -	} else
> +	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);
> +		mem->use_hierarchy = parent->use_hierarchy;
> +	}
>  
> - 	res_counter_init(&mem->res, parent ? &parent->res : NULL);
> -	res_counter_init(&mem->memsw, parent ? &parent->memsw : NULL);
> -
> +	if (parent && parent->use_hierarchy) {
> +		res_counter_init(&mem->res, &parent->res);
> +		res_counter_init(&mem->memsw, &parent->memsw);
> +	} else {
> +		res_counter_init(&mem->res, NULL);
> +		res_counter_init(&mem->memsw, NULL);
> +	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
