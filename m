Date: Tue, 18 Mar 2008 10:23:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] radix-tree page cgroup
Message-Id: <20080318102355.c619cd02.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47DDDDC6.2080808@cn.fujitsu.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
	<47DDDDC6.2080808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Mar 2008 11:56:06 +0900
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:

> > +static void init_page_cgroup(struct page_cgroup_head *head, unsigned long pfn)
> > +{
> > +	int i;
> > +	struct page_cgroup *pc;
> > +
> > +	memset(head, 0, sizeof(*head));
> > +	for (i = 0; i < PCGRP_SIZE; ++i) {
> 
> Usually we use 'i++' in this case, gcc will take care of it.
> 
Hmm, ok.

> > +		pc = &head->pc[i];
> > +		pc->page = pfn_to_page(pfn + i);
> > +		spin_lock_init(&pc->lock);
> > +		INIT_LIST_HEAD(&pc->lru);
> > +	}
> > +}
> > +
> > +
> > +struct kmem_cache *page_cgroup_cachep;
> > +
> > +static struct page_cgroup_head *
> > +alloc_init_page_cgroup(unsigned long pfn, int nid, gfp_t mask)
> > +{
> > +	struct page_cgroup_head *head;
> > +
> > +	head = kmem_cache_alloc_node(page_cgroup_cachep, mask, nid);
> > +	if (!head)
> > +		return NULL;
> > +
> > +	init_page_cgroup(head, pfn);
> > +
> > +	return head;
> > +}
> > +
> > +void free_page_cgroup(struct page_cgroup_head *head)
> > +{
> > +	kmem_cache_free(page_cgroup_cachep, head);
> > +}
> > +
> > +
> > +/*
> > + * Look up page_cgroup struct for struct page (page's pfn)
> > + * if (allocate == true), look up and allocate new one if necessary.
> > + * if (allocate == false), look up and return NULL if it cannot be found.
> > + */
> > +
> 
> It's confusing when NULL will be returned and when -EFXXX...
> 
> if (allocate == true) -EFXXX may still be returned ?
> 
> > +struct page_cgroup *
> > +get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
> > +{
> > +	struct page_cgroup_root *root;
> > +	struct page_cgroup_head *head;
> > +	struct page_cgroup *pc;
> > +	unsigned long pfn, idx;
> > +	int nid;
> > +	unsigned long base_pfn, flags;
> > +	int error;
> > +
> > +	if (!page)
> > +		return NULL;
> > +
> > +	pfn = page_to_pfn(page);
> > +	idx = pfn >> PCGRP_SHIFT;
> > +	nid = page_to_nid(page);
> > +
> > +	root = root_dir[nid];
> > +	/* Before Init ? */
> > +	if (unlikely(!root))
> > +		return NULL;
> > +
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
> 
> why can't return -ENOMEM ?
> 
It seems I misunderstand initcalls. Sorry.


> > +	}
> > +	for_each_online_node(nid) {
> > +		if (node_state(nid, N_NORMAL_MEMORY)
> > +			root = kmalloc_node(sizeof(struct page_cgroup_root),
> > +					GFP_KERNEL, nid);
> 
> if (root == NULL)
> 
> > +		else
> > +			root = kmalloc(sizeof(struct page_cgroup_root),
> > +					GFP_KERNEL);
> 
> ditto
> 

ok.


> > +		INIT_RADIX_TREE(&root->root_node, GFP_ATOMIC);
> > +		spin_lock_init(&root->tree_lock);
> > +		smp_wmb();
> > +		root_dir[nid] = root;
> > +	}
> > +
> > +	printk(KERN_INFO "Page Accouintg is activated\n");
> > +	return 0;
> > +}
> > +late_initcall(page_cgroup_init);
> > Index: mm-2.6.25-rc5-mm1/mm/Makefile
> > ===================================================================
> > --- mm-2.6.25-rc5-mm1.orig/mm/Makefile
> > +++ mm-2.6.25-rc5-mm1/mm/Makefile
> > @@ -32,5 +32,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
> >  obj-$(CONFIG_MIGRATION) += migrate.o
> >  obj-$(CONFIG_SMP) += allocpercpu.o
> >  obj-$(CONFIG_QUICKLIST) += quicklist.o
> > -obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
> > +obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
> >  
> > Index: mm-2.6.25-rc5-mm1/init/Kconfig
> > ===================================================================
> > --- mm-2.6.25-rc5-mm1.orig/init/Kconfig
> > +++ mm-2.6.25-rc5-mm1/init/Kconfig
> > @@ -405,6 +405,20 @@ config SYSFS_DEPRECATED_V2
> >  	  If you are using a distro with the most recent userspace
> >  	  packages, it should be safe to say N here.
> >  
> > +config CGROUP_PAGE_CGROUP_ORDER
> > +	int "Order of page accounting subsystem"
> > +	range 0 10
> > +	default 3 if HIGHMEM64G
> > +	default 10 if 64BIT
> > +	default 7
> > +	depends on CGROUP_MEM_RES_CTLR
> > +	help
> > +	  By making this value to be small, wastes in memory usage of page
> > +	  accounting can be small. But big number is good for perfomance.
> 
> s/perfomance/performance
> 
ok

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
