Date: Thu, 20 Mar 2008 13:45:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] radix-tree page cgroup
Message-Id: <20080320134513.3e4d45f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1205961066.6437.10.camel@lappy>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
	<1205961066.6437.10.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

thank you for review.

On Wed, 19 Mar 2008 22:11:06 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > New function is
> > 
> > struct page *get_page_cgroup(struct page *page, gfp_mask mask, bool allocate);
> > 
> > if (allocate == true), look up and allocate new one if necessary.
> > if (allocate == false), just do look up and return NULL if not exist.
> 
> I think others said as well, but we generally just write
> 
>  if (allocate)
> 
>  if (!allocate)
> 
ok. I'm now separating this function to 2 functions.
just look-up/ look-up and allocate.


> > +	struct page_cgroup_head *head;
> > +
> > +	head = kmem_cache_alloc_node(page_cgroup_cachep, mask, nid);
> > +	if (!head)
> > +		return NULL;
> > +
> > +	init_page_cgroup(head, pfn);
> 
> Just because I'm lazy, I'll suggest the shorter:
> 
> if (head)
>    init_page_cgroup(head, pfn)
I'll fix.


> > +	struct page_cgroup_root *root;
> > +	struct page_cgroup_head *head;
> > +	struct page_cgroup *pc;
> > +	unsigned long pfn, idx;
> > +	int nid;
> > +	unsigned long base_pfn, flags;
> > +	int error;
> 
> Would a this make sense? :
> 
>   might_sleep_if(allocate && (gfp_mask & __GFP_WAIT));
> 
seems good. I'll add it.


> > +	base_pfn = idx << PCGRP_SHIFT;
> > +retry:
> > +	error = 0;
> > +	rcu_read_lock();
> > +	head = radix_tree_lookup(&root->root_node, idx);
> > +	rcu_read_unlock();
> 
> This looks iffy, who protects head here?
> 

In this patch, a routine for freeing "head" is not included.
Then....Hmm.....rcu_read_xxx is not required...I'll remove it.
I'll check the whole logic around here again.

> > +	for_each_online_node(nid) {
> > +		if (node_state(nid, N_NORMAL_MEMORY)
> > +			root = kmalloc_node(sizeof(struct page_cgroup_root),
> > +					GFP_KERNEL, nid);
> > +		else
> > +			root = kmalloc(sizeof(struct page_cgroup_root),
> > +					GFP_KERNEL);
> 
> if (!node_state(nid, N_NORMAL_MEMORY))
>   nid = -1;
> 
> allows us to use a single kmalloc_node() statement.
> 
Oh, ok. it seems good.

> > +		INIT_RADIX_TREE(&root->root_node, GFP_ATOMIC);
> > +		spin_lock_init(&root->tree_lock);
> > +		smp_wmb();
> 
> unadorned barrier; we usually require a comment outlining the race, and
> a reference to the matching barrier.
> 
I'll add comments.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
