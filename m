Date: Wed, 19 Mar 2008 11:51:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] radix-tree page cgroup
Message-Id: <20080319115103.c361969d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080319020536.GE24473@balbir.in.ibm.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
	<20080319020536.GE24473@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008 07:35:36 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > +#include <linux/mm.h>
> > +#include <linux/slab.h>
> > +#include <linux/radix-tree.h>
> > +#include <linux/memcontrol.h>
> > +#include <linux/page_cgroup.h>
> > +#include <linux/err.h>
> > +
> > +
> > +
> 
> Too many extra lines
> 
fixed.

> > +#define PCGRP_SHIFT	(CONFIG_CGROUP_PAGE_CGROUP_ORDER)
> > +#define PCGRP_SIZE	(1 << PCGRP_SHIFT)
> > +
> > +struct page_cgroup_head {
> > +	struct page_cgroup pc[PCGRP_SIZE];
> 
> Are we over optimizing here?
> 
what is over optimizing ? PCGRP_SIZE is too large ?

> > +};
> > +
> > +struct page_cgroup_root {
> > +	spinlock_t	       tree_lock;
> > +	struct radix_tree_root root_node;
> > +};
> > +
> 
> Comments describing induvidual members of the structures would be nice
> 
will add.

> > +static struct page_cgroup_root *root_dir[MAX_NUMNODES];
> > +
> 
> 
> The root_dir is per node, should we call it node_root_dir?
> 
ok.

>
> > +	root = root_dir[nid];
> > +	/* Before Init ? */
> > +	if (unlikely(!root))
> > +		return NULL;
> > +
> 
> Shouldn't this be a BUG_ON? We don't expect any user space pages to be
> allocated prior to init.
No. this routine uses kmalloc(). To use it, I uses late_initcall().
Before late_initcall(), pages will be used.

> 
> > +	base_pfn = idx << PCGRP_SHIFT;
> > +retry:
> > +	error = 0;
> > +	rcu_read_lock();
> > +	head = radix_tree_lookup(&root->root_node, idx);
> > +	rcu_read_unlock();
> > +
> > +	if (likely(head))
> > +		return &head->pc[pfn - base_pfn];
> > +	if (allocate == false)
> > +		return NULL;
> > +
> > +	/* Very Slow Path. On demand allocation. */
> > +	gfpmask = gfpmask & ~(__GFP_HIGHMEM | __GFP_MOVABLE);
> > +
> > +	head = alloc_init_page_cgroup(base_pfn, nid, gfpmask);
> 
> This name is a bit confusing, it sounds like the page_cgroup is
> allocated from initialzation context, but I think it stands for
> allocate and initialize right?
> 
Ah, yes. I'll rename this.


> > +	if (!head)
> > +		return ERR_PTR(-ENOMEM);
> > +	pc = NULL;
> > +	error = radix_tree_preload(gfpmask);
> > +	if (error)
> > +		goto out;
> > +	spin_lock_irqsave(&root->tree_lock, flags);
> > +	error = radix_tree_insert(&root->root_node, idx, head);
> > +
> > +	if (!error)
> > +		pc = &head->pc[pfn - base_pfn];
> > +	spin_unlock_irqrestore(&root->tree_lock, flags);
> > +	radix_tree_preload_end();
> > +out:
> > +	if (!pc) {
> > +		free_page_cgroup(head);
> 
> We free the entire page_cgroup_head?
> 
yes. We alloc a head and free a head.


> > +		if (error == -EEXIST)
> > +			goto retry;
> > +	}
> > +	if (error)
> > +		pc = ERR_PTR(error);
> > +	return pc;
> > +}
> > +
> > +__init int page_cgroup_init(void)
> > +{
> > +	int nid;
> > +	struct page_cgroup_root *root;
> > +
> > +	page_cgroup_cachep = kmem_cache_create("page_cgroup",
> > +				sizeof(struct page_cgroup_head), 0,
> > +				SLAB_PANIC | SLAB_DESTROY_BY_RCU, NULL);
> > +	if (!page_cgroup_cachep) {
> > +		printk(KERN_ERR "page accouning setup failure\n");
> > +		printk(KERN_ERR "can't initialize slab memory\n");
> > +		/* FIX ME: should return some error code ? */
> > +		return 0;
> > +	}
> > +	for_each_online_node(nid) {
> > +		if (node_state(nid, N_NORMAL_MEMORY)
> > +			root = kmalloc_node(sizeof(struct page_cgroup_root),
> > +					GFP_KERNEL, nid);
> > +		else
> > +			root = kmalloc(sizeof(struct page_cgroup_root),
> > +					GFP_KERNEL);
> > +		INIT_RADIX_TREE(&root->root_node, GFP_ATOMIC);
> > +		spin_lock_init(&root->tree_lock);
> > +		smp_wmb();
> 
> Could you please explain why we need a barrier here and comment it as
> well.
ok. will add.

Before root_dir[nid] != NULL is visible to other cpus, all initizlization to
root should be finished.
> > +		root_dir[nid] = root;

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
