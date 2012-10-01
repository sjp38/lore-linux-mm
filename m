Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 067F16B0068
	for <linux-mm@kvack.org>; Sun, 30 Sep 2012 21:38:10 -0400 (EDT)
Received: by dadi14 with SMTP id i14so1648580dad.14
        for <linux-mm@kvack.org>; Sun, 30 Sep 2012 18:38:10 -0700 (PDT)
Date: Sun, 30 Sep 2012 18:37:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4] KSM: numa awareness sysfs knob
In-Reply-To: <1348448166-1995-1-git-send-email-pholasek@redhat.com>
Message-ID: <alpine.LSU.2.00.1209301736560.6304@eggly.anvils>
References: <1348448166-1995-1-git-send-email-pholasek@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

Andrea's point about ksm_migrate_page() is an important one, and I've
answered that against his mail, but here's some other easier points.

On Mon, 24 Sep 2012, Petr Holasek wrote:

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
> searching and inserting. Changing of merge_nodes value is possible only

merge_across_nodes

> when there are not any ksm shared pages in system.
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
> merge_nodes=1

merge_across_nodes

> 2 nodes 1.4%
> 4 nodes 1.6%
> 8 nodes	1.7%
> 
> merge_nodes=0

merge_across_nodes

> 2 nodes	1%
> 4 nodes	0.32%
> 8 nodes	0.018%
> 
> RFC: https://lkml.org/lkml/2011/11/30/91
> v1: https://lkml.org/lkml/2012/1/23/46
> v2: https://lkml.org/lkml/2012/6/29/105
> v3: https://lkml.org/lkml/2012/9/14/550
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

Yes, you were right to drop the share_all knob for now.  I do like the
idea, but it was quite inappropriate to mix it in with this NUMAnode
patch.  And although I like the idea, I think it wants a bit more: I
already have a hacky "allksm" boot option patch to mm/mmap.c for my
own testing, which adds VM_MERGEABLE everywhere.  If I gave that up
(I'd like to!) in favour of yours, I think I would still be missing
all the mms that are created before there's a chance to switch the
share_all mode on.  Or maybe I misread your v3.  Anyway, that's a
different topic, happily taken off today's agenda.

> 	- get_kpfn_nid helper
> 	- fixed page migration behaviour
> 
> Signed-off-by: Petr Holasek <pholasek@redhat.com>
> ---
>  Documentation/vm/ksm.txt |   7 +++
>  mm/ksm.c                 | 135 ++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 122 insertions(+), 20 deletions(-)
> 
> diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
> index b392e49..100d58d 100644
> --- a/Documentation/vm/ksm.txt
> +++ b/Documentation/vm/ksm.txt
> @@ -58,6 +58,13 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
>                     e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
>                     Default: 20 (chosen for demonstration purposes)
>  
> +merge_nodes      - specifies if pages from different numa nodes can be merged.

merge_across_nodes

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
> index 47c8853..7c82032 100644
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
> @@ -140,7 +141,10 @@ struct rmap_item {
>  	unsigned long address;		/* + low bits used for flags below */
>  	unsigned int oldchecksum;	/* when unstable */
>  	union {
> -		struct rb_node node;	/* when node of unstable tree */
> +		struct {
> +			struct rb_node node;	/* when node of unstable tree */
> +			struct rb_root *root;
> +		};

This worries me a little, enlarging struct rmap_item: there may
be very many of them in the system, best to minimize their size.

(This struct rb_root *root is used for one thing only, isn't it?  For the
unstable rb_erase() in remove_rmap_item_from_tree().  It annoys me that
we need to record root just for that, but I don't see an alternative.)

The 64-bit case can be easily improved by locating unsigned int nid
after oldchecksum instead.  The 32-bit case (which supports smaller
NODES_SHIFT: 6 was the largest I found) could be "improved" by keeping
nid in the lower bits of address along with (moved) UNSTABLE_FLAG and
STABLE_FLAG and reduced SEQNR_MASK - we really need only 1 bit for that,
but 2 bits would be nice for keeping the BUG_ON(age > 1).

But you may think I'm going too far there, and prefer just to put
#ifdef CONFIG_NUMA around the unsigned int nid, so at least it does
not enlarge the more basic 32-bit configuration.

>  		struct {		/* when listed from stable tree */
>  			struct stable_node *head;
>  			struct hlist_node hlist;
> @@ -153,8 +157,8 @@ struct rmap_item {
>  #define STABLE_FLAG	0x200	/* is listed from the stable tree */
>  
>  /* The stable and unstable tree heads */
> -static struct rb_root root_stable_tree = RB_ROOT;
> -static struct rb_root root_unstable_tree = RB_ROOT;
> +static struct rb_root root_unstable_tree[MAX_NUMNODES] = { RB_ROOT, };
> +static struct rb_root root_stable_tree[MAX_NUMNODES] = { RB_ROOT, };
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
> @@ -462,7 +484,10 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>  		cond_resched();
>  	}
>  
> -	rb_erase(&stable_node->node, &root_stable_tree);
> +	nid = get_kpfn_nid(stable_node->kpfn);
> +
> +	rb_erase(&stable_node->node,
> +			&root_stable_tree[nid]);

Oh, if I ever get my fingers on that, it's going to join the line above :)

>  	free_stable_node(stable_node);
>  }
>  
> @@ -560,7 +585,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>  		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
>  		BUG_ON(age > 1);
>  		if (!age)
> -			rb_erase(&rmap_item->node, &root_unstable_tree);
> +			rb_erase(&rmap_item->node, rmap_item->root);

Right, this is where we have to use rmap_item->root
or &root_unstable_tree[rmap_item->nid].

>  
>  		ksm_pages_unshared--;
>  		rmap_item->address &= PAGE_MASK;
> @@ -989,8 +1014,9 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
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
> @@ -998,6 +1024,9 @@ static struct page *stable_tree_search(struct page *page)
>  		return page;
>  	}
>  
> +	nid = get_kpfn_nid(page_to_pfn(page));
> +	node = root_stable_tree[nid].rb_node;
> +
>  	while (node) {
>  		struct page *tree_page;
>  		int ret;
> @@ -1032,10 +1061,14 @@ static struct page *stable_tree_search(struct page *page)
>   */
>  static struct stable_node *stable_tree_insert(struct page *kpage)
>  {
> -	struct rb_node **new = &root_stable_tree.rb_node;
> +	int nid;
> +	struct rb_node **new = NULL;

No need to initialize new.

>  	struct rb_node *parent = NULL;
>  	struct stable_node *stable_node;
>  
> +	nid = get_kpfn_nid(page_to_nid(kpage));
> +	new = &root_stable_tree[nid].rb_node;
> +
>  	while (*new) {
>  		struct page *tree_page;
>  		int ret;
> @@ -1069,7 +1102,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>  		return NULL;
>  
>  	rb_link_node(&stable_node->node, parent, new);
> -	rb_insert_color(&stable_node->node, &root_stable_tree);
> +	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
>  
>  	INIT_HLIST_HEAD(&stable_node->hlist);
>  
> @@ -1097,10 +1130,16 @@ static
>  struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>  					      struct page *page,
>  					      struct page **tree_pagep)
> -

Thank you!

>  {
> -	struct rb_node **new = &root_unstable_tree.rb_node;
> +	struct rb_node **new = NULL;

No need to initialize new.

> +	struct rb_root *root;
>  	struct rb_node *parent = NULL;
> +	int nid;
> +
> +	nid = get_kpfn_nid(page_to_pfn(page));
> +	root = &root_unstable_tree[nid];
> +
> +	new = &root->rb_node;
>  
>  	while (*new) {
>  		struct rmap_item *tree_rmap_item;
> @@ -1138,8 +1177,9 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>  
>  	rmap_item->address |= UNSTABLE_FLAG;
>  	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
> +	rmap_item->root = root;
>  	rb_link_node(&rmap_item->node, parent, new);
> -	rb_insert_color(&rmap_item->node, &root_unstable_tree);
> +	rb_insert_color(&rmap_item->node, root);
>  
>  	ksm_pages_unshared++;
>  	return NULL;
> @@ -1282,6 +1322,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>  	struct mm_slot *slot;
>  	struct vm_area_struct *vma;
>  	struct rmap_item *rmap_item;
> +	int i;

I'd call it nid myself.

>  
>  	if (list_empty(&ksm_mm_head.mm_list))
>  		return NULL;
> @@ -1300,7 +1341,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>  		 */
>  		lru_add_drain_all();
>  
> -		root_unstable_tree = RB_ROOT;
> +		for (i = 0; i < MAX_NUMNODES; i++)
> +			root_unstable_tree[i] = RB_ROOT;
>  
>  		spin_lock(&ksm_mmlist_lock);
>  		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
> @@ -1758,7 +1800,12 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
>  	stable_node = page_stable_node(newpage);
>  	if (stable_node) {
>  		VM_BUG_ON(stable_node->kpfn != page_to_pfn(oldpage));
> -		stable_node->kpfn = page_to_pfn(newpage);
> +
> +		if (ksm_merge_across_nodes ||
> +				page_to_nid(oldpage) == page_to_nid(newpage))
> +			stable_node->kpfn = page_to_pfn(newpage);
> +		else
> +			remove_node_from_stable_tree(stable_node);

Important point from Andrea discussed elsewhere.

>  	}
>  }
>  #endif /* CONFIG_MIGRATION */
> @@ -1768,15 +1815,19 @@ static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
>  						 unsigned long end_pfn)
>  {
>  	struct rb_node *node;
> +	int i;

I'd call it nid myself.

>  
> -	for (node = rb_first(&root_stable_tree); node; node = rb_next(node)) {
> -		struct stable_node *stable_node;
> +	for (i = 0; i < MAX_NUMNODES; i++)

It's irritating to have to do this outer nid loop, but I think you're
right, that the memory hotremove notification does not quite tell us
which node to look at.  Or can we derive that from start_pfn?  Would
it be safe to assume that end_pfn-1 must be in the same node?

> +		for (node = rb_first(&root_stable_tree[i]); node;
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
> @@ -1926,6 +1977,47 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
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
> +	if (ksm_run & KSM_RUN_MERGE) {
> +		err = -EBUSY;
> +	} else {
> +		if (ksm_merge_across_nodes != knob) {
> +			if (ksm_pages_shared > 0)
> +				err = -EBUSY;
> +			else
> +				ksm_merge_across_nodes = knob;
> +		}
> +	}
> +
> +	if (err)
> +		count = err;
> +	mutex_unlock(&ksm_thread_mutex);
> +
> +	return count;
> +}
> +KSM_ATTR(merge_across_nodes);
> +#endif
> +
>  static ssize_t pages_shared_show(struct kobject *kobj,
>  				 struct kobj_attribute *attr, char *buf)
>  {
> @@ -1980,6 +2072,9 @@ static struct attribute *ksm_attrs[] = {
>  	&pages_unshared_attr.attr,
>  	&pages_volatile_attr.attr,
>  	&full_scans_attr.attr,
> +#ifdef CONFIG_NUMA
> +	&merge_across_nodes_attr.attr,
> +#endif
>  	NULL,
>  };
>  
> -- 
> 1.7.11.4

Looks nice - thank you.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
