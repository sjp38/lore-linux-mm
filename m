Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 53C326B006C
	for <linux-mm@kvack.org>; Tue,  1 Jan 2013 03:46:50 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id c14so16088171ieb.0
        for <linux-mm@kvack.org>; Tue, 01 Jan 2013 00:46:49 -0800 (PST)
Message-ID: <1357030004.1379.4.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH v7 1/2] KSM: numa awareness sysfs knob
From: Simon Jeons <simon.jeons@gmail.com>
Date: Tue, 01 Jan 2013 02:46:44 -0600
In-Reply-To: <1356658337-12540-1-git-send-email-pholasek@redhat.com>
References: <20121224050817.GA25749@kroah.com>
	 <1356658337-12540-1-git-send-email-pholasek@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, 2012-12-28 at 02:32 +0100, Petr Holasek wrote:
> Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_across_nodes
> which control merging pages across different numa nodes.
> When it is set to zero only pages from the same node are merged,
> otherwise pages from all nodes can be merged together (default behavior).
> 
> Typical use-case could be a lot of KVM guests on NUMA machine
> and cpus from more distant nodes would have significant increase
> of access latency to the merged ksm page. Sysfs knob was choosen
> for higher variability when some users still prefers higher amount
> of saved physical memory regardless of access latency.
> 
> Every numa node has its own stable & unstable trees because of faster
> searching and inserting. Changing of merge_across_nodes value is possible
> only when there are not any ksm shared pages in system.
> 
> I've tested this patch on numa machines with 2, 4 and 8 nodes and
> measured speed of memory access inside of KVM guests with memory pinned
> to one of nodes with this benchmark:
> 
> http://pholasek.fedorapeople.org/alloc_pg.c
> 
> Population standard deviations of access times in percentage of average
> were following:
> 
> merge_across_nodes=1
> 2 nodes 1.4%
> 4 nodes 1.6%
> 8 nodes	1.7%
> 
> merge_across_nodes=0
> 2 nodes	1%
> 4 nodes	0.32%
> 8 nodes	0.018%
> 
> RFC: https://lkml.org/lkml/2011/11/30/91
> v1: https://lkml.org/lkml/2012/1/23/46
> v2: https://lkml.org/lkml/2012/6/29/105
> v3: https://lkml.org/lkml/2012/9/14/550
> v4: https://lkml.org/lkml/2012/9/23/137
> v5: https://lkml.org/lkml/2012/12/10/540
> v6: https://lkml.org/lkml/2012/12/23/154
> 
> Changelog:
> 
> v2: Andrew's objections were reflected:
> 	- value of merge_nodes can't be changed while there are some ksm
> 	pages in system
> 	- merge_nodes sysfs entry appearance depends on CONFIG_NUMA
> 	- more verbose documentation
> 	- added some performance testing results
> 
> v3:	- more verbose documentation
> 	- fixed race in merge_nodes store function
> 	- introduced share_all debugging knob proposed by Andrew
> 	- minor cleanups
> 
> v4:	- merge_nodes was renamed to merge_across_nodes
> 	- share_all debug knob was dropped
> 	- get_kpfn_nid helper
> 	- fixed page migration behaviour
> 
> v5:	- unstable node's nid presence depends on CONFIG_NUMA
> 	- fixed oops appearing when stable nodes were removed from tree
> 	- roots of stable trees are initialized properly
> 	- fixed unstable page migration issue
> 
> v6:	- fixed oops caused by stable_nodes appended to wrong tree
> 	- KSM_RUN_MERGE test removed
> 
> v7:	- added sysfs ABI documentation for KSM
> 
> Signed-off-by: Petr Holasek <pholasek@redhat.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  Documentation/vm/ksm.txt |   7 +++
>  mm/ksm.c                 | 151 +++++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 139 insertions(+), 19 deletions(-)
> 
> diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
> index b392e49..25cc89b 100644
> --- a/Documentation/vm/ksm.txt
> +++ b/Documentation/vm/ksm.txt
> @@ -58,6 +58,13 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
>                     e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
>                     Default: 20 (chosen for demonstration purposes)
>  
> +merge_across_nodes - specifies if pages from different numa nodes can be merged.
> +                   When set to 0, ksm merges only pages which physically
> +                   reside in the memory area of same NUMA node. It brings
> +                   lower latency to access to shared page. Value can be
> +                   changed only when there is no ksm shared pages in system.
> +                   Default: 1
> +
>  run              - set 0 to stop ksmd from running but keep merged pages,
>                     set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
>                     set 2 to stop ksmd and unmerge all pages currently merged,
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 5157385..d1e1041 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -36,6 +36,7 @@
>  #include <linux/hash.h>
>  #include <linux/freezer.h>
>  #include <linux/oom.h>
> +#include <linux/numa.h>
>  
>  #include <asm/tlbflush.h>
>  #include "internal.h"
> @@ -139,6 +140,9 @@ struct rmap_item {
>  	struct mm_struct *mm;
>  	unsigned long address;		/* + low bits used for flags below */
>  	unsigned int oldchecksum;	/* when unstable */
> +#ifdef CONFIG_NUMA
> +	unsigned int nid;
> +#endif
>  	union {
>  		struct rb_node node;	/* when node of unstable tree */
>  		struct {		/* when listed from stable tree */
> @@ -153,8 +157,8 @@ struct rmap_item {
>  #define STABLE_FLAG	0x200	/* is listed from the stable tree */
>  
>  /* The stable and unstable tree heads */
> -static struct rb_root root_stable_tree = RB_ROOT;
> -static struct rb_root root_unstable_tree = RB_ROOT;
> +static struct rb_root root_unstable_tree[MAX_NUMNODES];
> +static struct rb_root root_stable_tree[MAX_NUMNODES];
>  
>  #define MM_SLOTS_HASH_SHIFT 10
>  #define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
> @@ -189,6 +193,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
>  /* Milliseconds ksmd should sleep between batches */
>  static unsigned int ksm_thread_sleep_millisecs = 20;
>  
> +/* Zeroed when merging across nodes is not allowed */
> +static unsigned int ksm_merge_across_nodes = 1;
> +
>  #define KSM_RUN_STOP	0
>  #define KSM_RUN_MERGE	1
>  #define KSM_RUN_UNMERGE	2
> @@ -447,10 +454,25 @@ out:		page = NULL;
>  	return page;
>  }
>  
> +/*
> + * This helper is used for getting right index into array of tree roots.
> + * When merge_across_nodes knob is set to 1, there are only two rb-trees for
> + * stable and unstable pages from all nodes with roots in index 0. Otherwise,
> + * every node has its own stable and unstable tree.
> + */
> +static inline int get_kpfn_nid(unsigned long kpfn)
> +{
> +	if (ksm_merge_across_nodes)
> +		return 0;
> +	else
> +		return pfn_to_nid(kpfn);
> +}
> +
>  static void remove_node_from_stable_tree(struct stable_node *stable_node)
>  {
>  	struct rmap_item *rmap_item;
>  	struct hlist_node *hlist;
> +	int nid;
>  
>  	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
>  		if (rmap_item->hlist.next)
> @@ -462,7 +484,9 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>  		cond_resched();
>  	}
>  
> -	rb_erase(&stable_node->node, &root_stable_tree);
> +	nid = get_kpfn_nid(stable_node->kpfn);
> +
> +	rb_erase(&stable_node->node, &root_stable_tree[nid]);
>  	free_stable_node(stable_node);
>  }
>  
> @@ -560,7 +584,12 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>  		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
>  		BUG_ON(age > 1);
>  		if (!age)
> -			rb_erase(&rmap_item->node, &root_unstable_tree);
> +#ifdef CONFIG_NUMA
> +			rb_erase(&rmap_item->node,
> +					&root_unstable_tree[rmap_item->nid]);
> +#else
> +			rb_erase(&rmap_item->node, &root_unstable_tree[0]);
> +#endif

Hi Petr and Hugh,

One offline question, thanks for your clarify.

How to understand age = (unsigned char)(ksm_scan.seqnr -
rmap_item->address);? It used for what?

>  
>  		ksm_pages_unshared--;
>  		rmap_item->address &= PAGE_MASK;
> @@ -996,8 +1025,9 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
>   */
>  static struct page *stable_tree_search(struct page *page)
>  {
> -	struct rb_node *node = root_stable_tree.rb_node;
> +	struct rb_node *node;
>  	struct stable_node *stable_node;
> +	int nid;
>  
>  	stable_node = page_stable_node(page);
>  	if (stable_node) {			/* ksm page forked */
> @@ -1005,6 +1035,9 @@ static struct page *stable_tree_search(struct page *page)
>  		return page;
>  	}
>  
> +	nid = get_kpfn_nid(page_to_pfn(page));
> +	node = root_stable_tree[nid].rb_node;
> +
>  	while (node) {
>  		struct page *tree_page;
>  		int ret;
> @@ -1039,10 +1072,16 @@ static struct page *stable_tree_search(struct page *page)
>   */
>  static struct stable_node *stable_tree_insert(struct page *kpage)
>  {
> -	struct rb_node **new = &root_stable_tree.rb_node;
> +	int nid;
> +	unsigned long kpfn;
> +	struct rb_node **new;
>  	struct rb_node *parent = NULL;
>  	struct stable_node *stable_node;
>  
> +	kpfn = page_to_pfn(kpage);
> +	nid = get_kpfn_nid(kpfn);
> +	new = &root_stable_tree[nid].rb_node;
> +
>  	while (*new) {
>  		struct page *tree_page;
>  		int ret;
> @@ -1076,11 +1115,11 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>  		return NULL;
>  
>  	rb_link_node(&stable_node->node, parent, new);
> -	rb_insert_color(&stable_node->node, &root_stable_tree);
> +	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
>  
>  	INIT_HLIST_HEAD(&stable_node->hlist);
>  
> -	stable_node->kpfn = page_to_pfn(kpage);
> +	stable_node->kpfn = kpfn;
>  	set_page_stable_node(kpage, stable_node);
>  
>  	return stable_node;
> @@ -1104,10 +1143,15 @@ static
>  struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>  					      struct page *page,
>  					      struct page **tree_pagep)
> -
>  {
> -	struct rb_node **new = &root_unstable_tree.rb_node;
> +	struct rb_node **new;
> +	struct rb_root *root;
>  	struct rb_node *parent = NULL;
> +	int nid;
> +
> +	nid = get_kpfn_nid(page_to_pfn(page));
> +	root = &root_unstable_tree[nid];
> +	new = &root->rb_node;
>  
>  	while (*new) {
>  		struct rmap_item *tree_rmap_item;
> @@ -1128,6 +1172,18 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>  			return NULL;
>  		}
>  
> +		/*
> +		 * If tree_page has been migrated to another NUMA node, it
> +		 * will be flushed out and put into the right unstable tree
> +		 * next time: only merge with it if merge_across_nodes.
> +		 * Just notice, we don't have similar problem for PageKsm
> +		 * because their migration is disabled now. (62b61f611e)
> +		 */
> +		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
> +			put_page(tree_page);
> +			return NULL;
> +		}
> +
>  		ret = memcmp_pages(page, tree_page);
>  
>  		parent = *new;
> @@ -1145,8 +1201,11 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>  
>  	rmap_item->address |= UNSTABLE_FLAG;
>  	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
> +#ifdef CONFIG_NUMA
> +	rmap_item->nid = nid;
> +#endif
>  	rb_link_node(&rmap_item->node, parent, new);
> -	rb_insert_color(&rmap_item->node, &root_unstable_tree);
> +	rb_insert_color(&rmap_item->node, root);
>  
>  	ksm_pages_unshared++;
>  	return NULL;
> @@ -1160,6 +1219,13 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>  static void stable_tree_append(struct rmap_item *rmap_item,
>  			       struct stable_node *stable_node)
>  {
> +#ifdef CONFIG_NUMA
> +	/*
> +	 * Usually rmap_item->nid is already set correctly,
> +	 * but it may be wrong after switching merge_across_nodes.
> +	 */
> +	rmap_item->nid = get_kpfn_nid(stable_node->kpfn);
> +#endif
>  	rmap_item->head = stable_node;
>  	rmap_item->address |= STABLE_FLAG;
>  	hlist_add_head(&rmap_item->hlist, &stable_node->hlist);
> @@ -1289,6 +1355,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>  	struct mm_slot *slot;
>  	struct vm_area_struct *vma;
>  	struct rmap_item *rmap_item;
> +	int nid;
>  
>  	if (list_empty(&ksm_mm_head.mm_list))
>  		return NULL;
> @@ -1307,7 +1374,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>  		 */
>  		lru_add_drain_all();
>  
> -		root_unstable_tree = RB_ROOT;
> +		for (nid = 0; nid < nr_node_ids; nid++)
> +			root_unstable_tree[nid] = RB_ROOT;
>  
>  		spin_lock(&ksm_mmlist_lock);
>  		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
> @@ -1782,15 +1850,19 @@ static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
>  						 unsigned long end_pfn)
>  {
>  	struct rb_node *node;
> +	int nid;
>  
> -	for (node = rb_first(&root_stable_tree); node; node = rb_next(node)) {
> -		struct stable_node *stable_node;
> +	for (nid = 0; nid < nr_node_ids; nid++)
> +		for (node = rb_first(&root_stable_tree[nid]); node;
> +				node = rb_next(node)) {
> +			struct stable_node *stable_node;
> +
> +			stable_node = rb_entry(node, struct stable_node, node);
> +			if (stable_node->kpfn >= start_pfn &&
> +			    stable_node->kpfn < end_pfn)
> +				return stable_node;
> +		}
>  
> -		stable_node = rb_entry(node, struct stable_node, node);
> -		if (stable_node->kpfn >= start_pfn &&
> -		    stable_node->kpfn < end_pfn)
> -			return stable_node;
> -	}
>  	return NULL;
>  }
>  
> @@ -1937,6 +2009,40 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
>  }
>  KSM_ATTR(run);
>  
> +#ifdef CONFIG_NUMA
> +static ssize_t merge_across_nodes_show(struct kobject *kobj,
> +				struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%u\n", ksm_merge_across_nodes);
> +}
> +
> +static ssize_t merge_across_nodes_store(struct kobject *kobj,
> +				   struct kobj_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long knob;
> +
> +	err = kstrtoul(buf, 10, &knob);
> +	if (err)
> +		return err;
> +	if (knob > 1)
> +		return -EINVAL;
> +
> +	mutex_lock(&ksm_thread_mutex);
> +	if (ksm_merge_across_nodes != knob) {
> +		if (ksm_pages_shared)
> +			err = -EBUSY;
> +		else
> +			ksm_merge_across_nodes = knob;
> +	}
> +	mutex_unlock(&ksm_thread_mutex);
> +
> +	return err ? err : count;
> +}
> +KSM_ATTR(merge_across_nodes);
> +#endif
> +
>  static ssize_t pages_shared_show(struct kobject *kobj,
>  				 struct kobj_attribute *attr, char *buf)
>  {
> @@ -1991,6 +2097,9 @@ static struct attribute *ksm_attrs[] = {
>  	&pages_unshared_attr.attr,
>  	&pages_volatile_attr.attr,
>  	&full_scans_attr.attr,
> +#ifdef CONFIG_NUMA
> +	&merge_across_nodes_attr.attr,
> +#endif
>  	NULL,
>  };
>  
> @@ -2004,11 +2113,15 @@ static int __init ksm_init(void)
>  {
>  	struct task_struct *ksm_thread;
>  	int err;
> +	int nid;
>  
>  	err = ksm_slab_init();
>  	if (err)
>  		goto out;
>  
> +	for (nid = 0; nid < nr_node_ids; nid++)
> +		root_stable_tree[nid] = RB_ROOT;
> +
>  	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
>  	if (IS_ERR(ksm_thread)) {
>  		printk(KERN_ERR "ksm: creating kthread failed\n");


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
