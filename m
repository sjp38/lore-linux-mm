Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2J27CSX020573
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 13:07:12 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2J2BGAV203880
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 13:11:16 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2J27V2Y008699
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 13:07:31 +1100
Date: Wed, 19 Mar 2008 07:35:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/7] radix-tree page cgroup
Message-ID: <20080319020536.GE24473@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:17:33]:

> A lookup routine for page_cgroup struct.
> 
> Now, page_cgroup is pointed by struct page's page_cgroup entry
> 
> struct page {
> 	...
> 	struct page_cgroup *page_cgroup;
> 	..
> }
> 
> But some people dislike this because this increases sizeof(struct page).
> 
> For avoiding that, we'll have to add a lookup routine for
> 	pfn <-> page_cgroup.
> by radix-tree.
> 
> New function is
> 
> struct page *get_page_cgroup(struct page *page, gfp_mask mask, bool allocate);
> 
> if (allocate == true), look up and allocate new one if necessary.
> if (allocate == false), just do look up and return NULL if not exist.
> 
> Changes:
>   - add the 3rd argument 'allocate'
>   - making page_cgroup chunk size to be configurable (for test.)
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  init/Kconfig     |   14 ++++
>  mm/Makefile      |    2 
>  mm/page_cgroup.c |  169 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 184 insertions(+), 1 deletion(-)
> 
> Index: mm-2.6.25-rc5-mm1/mm/page_cgroup.c
> ===================================================================
> --- /dev/null
> +++ mm-2.6.25-rc5-mm1/mm/page_cgroup.c
> @@ -0,0 +1,173 @@
> +/*
> + * page_cgroup mamagement codes.
> + * page_cgroup is yet another mem_map when cgroup's memory resoruce controller
> + * is activated. It containes information which cannot be stored in usual
> + * mem_map. (it's too big.)
> + * This allows us to keep 'struct page' small when a user doesn't activate
> + * memory resource controller.
> + *
> + * Note: all things are allocated on demand.
> + *
> + * We can translate : struct page <-> pfn -> page_cgroup -> struct page.
> + */
> +
> +#include <linux/mm.h>
> +#include <linux/slab.h>
> +#include <linux/radix-tree.h>
> +#include <linux/memcontrol.h>
> +#include <linux/page_cgroup.h>
> +#include <linux/err.h>
> +
> +
> +

Too many extra lines

> +#define PCGRP_SHIFT	(CONFIG_CGROUP_PAGE_CGROUP_ORDER)
> +#define PCGRP_SIZE	(1 << PCGRP_SHIFT)
> +
> +struct page_cgroup_head {
> +	struct page_cgroup pc[PCGRP_SIZE];

Are we over optimizing here?

> +};
> +
> +struct page_cgroup_root {
> +	spinlock_t	       tree_lock;
> +	struct radix_tree_root root_node;
> +};
> +

Comments describing induvidual members of the structures would be nice

> +static struct page_cgroup_root *root_dir[MAX_NUMNODES];
> +


The root_dir is per node, should we call it node_root_dir?

> +static void init_page_cgroup(struct page_cgroup_head *head, unsigned long pfn)
> +{
> +	int i;
> +	struct page_cgroup *pc;
> +
> +	memset(head, 0, sizeof(*head));
> +	for (i = 0; i < PCGRP_SIZE; ++i) {
> +		pc = &head->pc[i];
> +		pc->page = pfn_to_page(pfn + i);
> +		spin_lock_init(&pc->lock);
> +		INIT_LIST_HEAD(&pc->lru);
> +	}
> +}
> +
> +
> +struct kmem_cache *page_cgroup_cachep;
> +
> +static struct page_cgroup_head *
> +alloc_init_page_cgroup(unsigned long pfn, int nid, gfp_t mask)
> +{
> +	struct page_cgroup_head *head;
> +
> +	head = kmem_cache_alloc_node(page_cgroup_cachep, mask, nid);
> +	if (!head)
> +		return NULL;
> +
> +	init_page_cgroup(head, pfn);
> +
> +	return head;
> +}
> +
> +void free_page_cgroup(struct page_cgroup_head *head)
> +{
> +	kmem_cache_free(page_cgroup_cachep, head);
> +}
> +
> +
> +/*
> + * Look up page_cgroup struct for struct page (page's pfn)
> + * if (allocate == true), look up and allocate new one if necessary.
> + * if (allocate == false), look up and return NULL if it cannot be found.
> + */
> +
> +struct page_cgroup *
> +get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
> +{
> +	struct page_cgroup_root *root;
> +	struct page_cgroup_head *head;
> +	struct page_cgroup *pc;
> +	unsigned long pfn, idx;
> +	int nid;
> +	unsigned long base_pfn, flags;
> +	int error;
> +
> +	if (!page)
> +		return NULL;
> +
> +	pfn = page_to_pfn(page);
> +	idx = pfn >> PCGRP_SHIFT;
> +	nid = page_to_nid(page);
> +
> +	root = root_dir[nid];
> +	/* Before Init ? */
> +	if (unlikely(!root))
> +		return NULL;
> +

Shouldn't this be a BUG_ON? We don't expect any user space pages to be
allocated prior to init.

> +	base_pfn = idx << PCGRP_SHIFT;
> +retry:
> +	error = 0;
> +	rcu_read_lock();
> +	head = radix_tree_lookup(&root->root_node, idx);
> +	rcu_read_unlock();
> +
> +	if (likely(head))
> +		return &head->pc[pfn - base_pfn];
> +	if (allocate == false)
> +		return NULL;
> +
> +	/* Very Slow Path. On demand allocation. */
> +	gfpmask = gfpmask & ~(__GFP_HIGHMEM | __GFP_MOVABLE);
> +
> +	head = alloc_init_page_cgroup(base_pfn, nid, gfpmask);

This name is a bit confusing, it sounds like the page_cgroup is
allocated from initialzation context, but I think it stands for
allocate and initialize right?

> +	if (!head)
> +		return ERR_PTR(-ENOMEM);
> +	pc = NULL;
> +	error = radix_tree_preload(gfpmask);
> +	if (error)
> +		goto out;
> +	spin_lock_irqsave(&root->tree_lock, flags);
> +	error = radix_tree_insert(&root->root_node, idx, head);
> +
> +	if (!error)
> +		pc = &head->pc[pfn - base_pfn];
> +	spin_unlock_irqrestore(&root->tree_lock, flags);
> +	radix_tree_preload_end();
> +out:
> +	if (!pc) {
> +		free_page_cgroup(head);

We free the entire page_cgroup_head?

> +		if (error == -EEXIST)
> +			goto retry;
> +	}
> +	if (error)
> +		pc = ERR_PTR(error);
> +	return pc;
> +}
> +
> +__init int page_cgroup_init(void)
> +{
> +	int nid;
> +	struct page_cgroup_root *root;
> +
> +	page_cgroup_cachep = kmem_cache_create("page_cgroup",
> +				sizeof(struct page_cgroup_head), 0,
> +				SLAB_PANIC | SLAB_DESTROY_BY_RCU, NULL);
> +	if (!page_cgroup_cachep) {
> +		printk(KERN_ERR "page accouning setup failure\n");
> +		printk(KERN_ERR "can't initialize slab memory\n");
> +		/* FIX ME: should return some error code ? */
> +		return 0;
> +	}
> +	for_each_online_node(nid) {
> +		if (node_state(nid, N_NORMAL_MEMORY)
> +			root = kmalloc_node(sizeof(struct page_cgroup_root),
> +					GFP_KERNEL, nid);
> +		else
> +			root = kmalloc(sizeof(struct page_cgroup_root),
> +					GFP_KERNEL);
> +		INIT_RADIX_TREE(&root->root_node, GFP_ATOMIC);
> +		spin_lock_init(&root->tree_lock);
> +		smp_wmb();

Could you please explain why we need a barrier here and comment it as
well.

> +		root_dir[nid] = root;
> +	}
> +
> +	printk(KERN_INFO "Page Accouintg is activated\n");
> +	return 0;
> +}
> +late_initcall(page_cgroup_init);
> Index: mm-2.6.25-rc5-mm1/mm/Makefile
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/mm/Makefile
> +++ mm-2.6.25-rc5-mm1/mm/Makefile
> @@ -32,5 +32,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
>  obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_SMP) += allocpercpu.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
> -obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
> +obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
> 
> Index: mm-2.6.25-rc5-mm1/init/Kconfig
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/init/Kconfig
> +++ mm-2.6.25-rc5-mm1/init/Kconfig
> @@ -405,6 +405,20 @@ config SYSFS_DEPRECATED_V2
>  	  If you are using a distro with the most recent userspace
>  	  packages, it should be safe to say N here.
> 
> +config CGROUP_PAGE_CGROUP_ORDER
> +	int "Order of page accounting subsystem"
> +	range 0 10
> +	default 3 if HIGHMEM64G
> +	default 10 if 64BIT
> +	default 7

What are these defaults based on?

> +	depends on CGROUP_MEM_RES_CTLR
> +	help
> +	  By making this value to be small, wastes in memory usage of page
> +	  accounting can be small. But big number is good for perfomance.
> +	  Especially, HIGHMEM64G users should keep this to be small because
> +	  you tend to have small kernel memory.
> +	  If unsure, use default.
> +
>  config PROC_PID_CPUSET
>  	bool "Include legacy /proc/<pid>/cpuset file"
>  	depends on CPUSETS
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
