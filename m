Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3D16E6B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:20:04 -0500 (EST)
Received: by iouu10 with SMTP id u10so65890123iou.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:20:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 141si13548605iof.88.2015.12.09.08.20.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 08:20:03 -0800 (PST)
Date: Wed, 9 Dec 2015 17:19:59 +0100
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20151209161959.GC3540@stainedmachine.brq.redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447181081-30056-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

On Tue, 10 Nov 2015, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Without a max deduplication limit for each KSM page, the list of the
> rmap_items associated to each stable_node can grow infinitely
> large.
> 
> During the rmap walk each entry can take up to ~10usec to process
> because of IPIs for the TLB flushing (both for the primary MMU and the
> secondary MMUs with the MMU notifier). With only 16GB of address space
> shared in the same KSM page, that would amount to dozens of seconds of
> kernel runtime.
> 
> A ~256 max deduplication factor will reduce the latencies of the rmap
> walks on KSM pages to order of a few msec. Just doing the
> cond_resched() during the rmap walks is not enough, the list size must
> have a limit too, otherwise the caller could get blocked in (schedule
> friendly) kernel computations for seconds, unexpectedly.
> 
> There's room for optimization to significantly reduce the IPI delivery
> cost during the page_referenced(), but at least for page_migration in
> the KSM case (used by hard NUMA bindings, compaction and NUMA
> balancing) it may be inevitable to send lots of IPIs if each
> rmap_item->mm is active on a different CPU and there are lots of
> CPUs. Even if we ignore the IPI delivery cost, we've still to walk the
> whole KSM rmap list, so we can't allow millions or billions (ulimited)
> number of entries in the KSM stable_node rmap_item lists.
> 
> The limit is enforced efficiently by adding a second dimension to the
> stable rbtree. So there are three types of stable_nodes: the regular
> ones (identical as before, living in the first flat dimension of the
> stable rbtree), the "chains" and the "dups".
> 
> Every "chain" and all "dups" linked into a "chain" enforce the
> invariant that they represent the same write protected memory content,
> even if each "dup" will be pointed by a different KSM page copy of
> that content. This way the stable rbtree lookup computational
> complexity is unaffected if compared to an unlimited
> max_sharing_limit. It is still enforced that there cannot be KSM page
> content duplicates in the stable rbtree itself.
> 
> Adding the second dimension to the stable rbtree only after the
> max_page_sharing limit hits, provides for a zero memory footprint
> increase on 64bit archs. The memory overhead of the per-KSM page
> stable_tree and per virtual mapping rmap_item is unchanged. Only after
> the max_page_sharing limit hits, we need to allocate a stable_tree
> "chain" and rb_replace() the "regular" stable_node with the newly
> allocated stable_node "chain". After that we simply add the "regular"
> stable_node to the chain as a stable_node "dup" by linking hlist_dup
> in the stable_node_chain->hlist. This way the "regular" (flat)
> stable_node is converted to a stable_node "dup" living in the second
> dimension of the stable rbtree.
> 
> During stable rbtree lookups the stable_node "chain" is identified as
> stable_node->rmap_hlist_len == STABLE_NODE_CHAIN (aka
> is_stable_node_chain()).
> 
> When dropping stable_nodes, the stable_node "dup" is identified as
> stable_node->head == STABLE_NODE_DUP_HEAD (aka is_stable_node_dup()).
> 
> The STABLE_NODE_DUP_HEAD must be an unique valid pointer never used
> elsewhere in any stable_node->head/node to avoid a clashes with the
> stable_node->node.rb_parent_color pointer, and different from
> &migrate_nodes. So the second field of &migrate_nodes is picked and
> verified as always safe with a BUILD_BUG_ON in case the list_head
> implementation changes in the future.
> 
> The STABLE_NODE_DUP is picked as a random negative value in
> stable_node->rmap_hlist_len. rmap_hlist_len cannot become negative
> when it's a "regular" stable_node or a stable_node "dup".
> 
> The stable_node_chain->nid is irrelevant. The stable_node_chain->kpfn
> is aliased in a union with a time field used to rate limit the
> stable_node_chain->hlist prunes.
> 
> The garbage collection of the stable_node_chain happens lazily during
> stable rbtree lookups (as for all other kind of stable_nodes), or
> while disabling KSM with "echo 2 >/sys/kernel/mm/ksm/run" while
> collecting the entire stable rbtree.

Hi Andrea,

I've been running stress tests against this patchset for a couple of hours
and everything was ok. However, I've allocated ~1TB of memory and got
following lockup during disabling KSM with 'echo 2 > /sys/kernel/mm/ksm/run':

[13201.060601] INFO: task ksmd:351 blocked for more than 120 seconds.
[13201.066812]       Not tainted 4.4.0-rc4+ #5
[13201.070996] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
this message.
[13201.078830] ksmd            D ffff883f65eb7dc8     0   351      2
0x00000000
[13201.085903]  ffff883f65eb7dc8 ffff887f66e26400 ffff883f65d5e400
ffff883f65eb8000
[13201.093343]  ffffffff81a65144 ffff883f65d5e400 00000000ffffffff
ffffffff81a65148
[13201.100792]  ffff883f65eb7de0 ffffffff816907e5 ffffffff81a65140
ffff883f65eb7df0
[13201.108242] Call Trace:
[13201.110708]  [<ffffffff816907e5>] schedule+0x35/0x80
[13201.115676]  [<ffffffff81690ace>] schedule_preempt_disabled+0xe/0x10
[13201.122044]  [<ffffffff81692524>] __mutex_lock_slowpath+0xb4/0x130
[13201.128237]  [<ffffffff816925bf>] mutex_lock+0x1f/0x2f
[13201.133395]  [<ffffffff811debd2>] ksm_scan_thread+0x62/0x1f0
[13201.139068]  [<ffffffff810c8ac0>] ? wait_woken+0x80/0x80
[13201.144391]  [<ffffffff811deb70>] ? ksm_do_scan+0x1140/0x1140
[13201.150164]  [<ffffffff810a4378>] kthread+0xd8/0xf0
[13201.155056]  [<ffffffff810a42a0>] ? kthread_park+0x60/0x60
[13201.160551]  [<ffffffff8169460f>] ret_from_fork+0x3f/0x70
[13201.165961]  [<ffffffff810a42a0>] ? kthread_park+0x60/0x60

It seems this is not connected with the new code, but it would be nice to
also make unmerge_and_remove_all_rmap_items() more scheduler friendly.

thanks,
Petr

> 
> While the "regular" stable_nodes and the stable_node "dups" must wait
> for their underlying tree_page to be freed before they can be freed
> themselves, the stable_node "chains" can be freed immediately if the
> stable_node->hlist turns empty. This is because the "chains" are never
> pointed by any page->mapping and they're effectively stable rbtree KSM
> self contained metadata.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  Documentation/vm/ksm.txt |  63 ++++
>  mm/ksm.c                 | 731 ++++++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 728 insertions(+), 66 deletions(-)
> 
> diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
> index f34a8ee..a7ef759 100644
> --- a/Documentation/vm/ksm.txt
> +++ b/Documentation/vm/ksm.txt
> @@ -80,6 +80,50 @@ run              - set 0 to stop ksmd from running but keep merged pages,
>                     Default: 0 (must be changed to 1 to activate KSM,
>                                 except if CONFIG_SYSFS is disabled)
>  
> +max_page_sharing - Maximum sharing allowed for each KSM page. This
> +                   enforces a deduplication limit to avoid the virtual
> +                   memory rmap lists to grow too large. The minimum
> +                   value is 2 as a newly created KSM page will have at
> +                   least two sharers. The rmap walk has O(N)
> +                   complexity where N is the number of rmap_items
> +                   (i.e. virtual mappings) that are sharing the page,
> +                   which is in turn capped by max_page_sharing. So
> +                   this effectively spread the the linear O(N)
> +                   computational complexity from rmap walk context
> +                   over different KSM pages. The ksmd walk over the
> +                   stable_node "chains" is also O(N), but N is the
> +                   number of stable_node "dups", not the number of
> +                   rmap_items, so it has not a significant impact on
> +                   ksmd performance. In practice the best stable_node
> +                   "dup" candidate will be kept and found at the head
> +                   of the "dups" list. The higher this value the
> +                   faster KSM will merge the memory (because there
> +                   will be fewer stable_node dups queued into the
> +                   stable_node chain->hlist to check for pruning) and
> +                   the higher the deduplication factor will be, but
> +                   the slowest the worst case rmap walk could be for
> +                   any given KSM page. Slowing down the rmap_walk
> +                   means there will be higher latency for certain
> +                   virtual memory operations happening during
> +                   swapping, compaction, NUMA balancing and page
> +                   migration, in turn decreasing responsiveness for
> +                   the caller of those virtual memory operations. The
> +                   scheduler latency of other tasks not involved with
> +                   the VM operations doing the rmap walk is not
> +                   affected by this parameter as the rmap walks are
> +                   always schedule friendly themselves.
> +
> +stable_node_chains_prune_millisecs - How frequently to walk the whole
> +                   list of stable_node "dups" linked in the
> +                   stable_node "chains" in order to prune stale
> +                   stable_nodes. Smaller milllisecs values will free
> +                   up the KSM metadata with lower latency, but they
> +                   will make ksmd use more CPU during the scan. This
> +                   only applies to the stable_node chains so it's a
> +                   noop if not a single KSM page hit the
> +                   max_page_sharing yet (there would be no stable_node
> +                   chains in such case).
> +
>  The effectiveness of KSM and MADV_MERGEABLE is shown in /sys/kernel/mm/ksm/:
>  
>  pages_shared     - how many shared pages are being used
> @@ -88,10 +132,29 @@ pages_unshared   - how many pages unique but repeatedly checked for merging
>  pages_volatile   - how many pages changing too fast to be placed in a tree
>  full_scans       - how many times all mergeable areas have been scanned
>  
> +stable_node_chains - number of stable node chains allocated, this is
> +		     effectively the number of KSM pages that hit the
> +		     max_page_sharing limit
> +stable_node_dups   - number of stable node dups queued into the
> +		     stable_node chains
> +
>  A high ratio of pages_sharing to pages_shared indicates good sharing, but
>  a high ratio of pages_unshared to pages_sharing indicates wasted effort.
>  pages_volatile embraces several different kinds of activity, but a high
>  proportion there would also indicate poor use of madvise MADV_MERGEABLE.
>  
> +The maximum possible page_sharing/page_shared ratio is limited by the
> +max_page_sharing tunable. To increase the ratio max_page_sharing must
> +be increased accordingly.
> +
> +The stable_node_dups/stable_node_chains ratio is also affected by the
> +max_page_sharing tunable, and an high ratio may indicate fragmentation
> +in the stable_node dups, which could be solved by introducing
> +fragmentation algorithms in ksmd which would refile rmap_items from
> +one stable_node dup to another stable_node dup, in order to freeup
> +stable_node "dups" with few rmap_items in them, but that may increase
> +the ksmd CPU usage and possibly slowdown the readonly computations on
> +the KSM pages of the applications.
> +
>  Izik Eidus,
>  Hugh Dickins, 17 Nov 2009
> diff --git a/mm/ksm.c b/mm/ksm.c
> index b5cd647..fd0bf51 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -126,9 +126,12 @@ struct ksm_scan {
>   * struct stable_node - node of the stable rbtree
>   * @node: rb node of this ksm page in the stable tree
>   * @head: (overlaying parent) &migrate_nodes indicates temporarily on that list
> + * @hlist_dup: linked into the stable_node->hlist with a stable_node chain
>   * @list: linked into migrate_nodes, pending placement in the proper node tree
>   * @hlist: hlist head of rmap_items using this ksm page
>   * @kpfn: page frame number of this ksm page (perhaps temporarily on wrong nid)
> + * @chain_prune_time: time of the last full garbage collection
> + * @rmap_hlist_len: number of rmap_item entries in hlist or STABLE_NODE_CHAIN
>   * @nid: NUMA node id of stable tree in which linked (may not match kpfn)
>   */
>  struct stable_node {
> @@ -136,11 +139,24 @@ struct stable_node {
>  		struct rb_node node;	/* when node of stable tree */
>  		struct {		/* when listed for migration */
>  			struct list_head *head;
> -			struct list_head list;
> +			struct {
> +				struct hlist_node hlist_dup;
> +				struct list_head list;
> +			};
>  		};
>  	};
>  	struct hlist_head hlist;
> -	unsigned long kpfn;
> +	union {
> +		unsigned long kpfn;
> +		unsigned long chain_prune_time;
> +	};
> +	/*
> +	 * STABLE_NODE_CHAIN can be any negative number in
> +	 * rmap_hlist_len negative range, but better not -1 to be able
> +	 * to reliably detect underflows.
> +	 */
> +#define STABLE_NODE_CHAIN -1024
> +	int rmap_hlist_len;
>  #ifdef CONFIG_NUMA
>  	int nid;
>  #endif
> @@ -190,6 +206,7 @@ static struct rb_root *root_unstable_tree = one_unstable_tree;
>  
>  /* Recently migrated nodes of stable tree, pending proper placement */
>  static LIST_HEAD(migrate_nodes);
> +#define STABLE_NODE_DUP_HEAD ((struct list_head *)&migrate_nodes.prev)
>  
>  #define MM_SLOTS_HASH_BITS 10
>  static DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
> @@ -217,6 +234,18 @@ static unsigned long ksm_pages_unshared;
>  /* The number of rmap_items in use: to calculate pages_volatile */
>  static unsigned long ksm_rmap_items;
>  
> +/* The number of stable_node chains */
> +static unsigned long ksm_stable_node_chains;
> +
> +/* The number of stable_node dups linked to the stable_node chains */
> +static unsigned long ksm_stable_node_dups;
> +
> +/* Delay in pruning stale stable_node_dups in the stable_node_chains */
> +static int ksm_stable_node_chains_prune_millisecs = 2000;
> +
> +/* Maximum number of page slots sharing a stable node */
> +static int ksm_max_page_sharing = 256;
> +
>  /* Number of pages ksmd should scan in one batch */
>  static unsigned int ksm_thread_pages_to_scan = 100;
>  
> @@ -279,6 +308,44 @@ static void __init ksm_slab_free(void)
>  	mm_slot_cache = NULL;
>  }
>  
> +static __always_inline bool is_stable_node_chain(struct stable_node *chain)
> +{
> +	return chain->rmap_hlist_len == STABLE_NODE_CHAIN;
> +}
> +
> +static __always_inline bool is_stable_node_dup(struct stable_node *dup)
> +{
> +	return dup->head == STABLE_NODE_DUP_HEAD;
> +}
> +
> +static inline void stable_node_chain_add_dup(struct stable_node *dup,
> +					     struct stable_node *chain)
> +{
> +	VM_BUG_ON(is_stable_node_dup(dup));
> +	dup->head = STABLE_NODE_DUP_HEAD;
> +	VM_BUG_ON(!is_stable_node_chain(chain));
> +	hlist_add_head(&dup->hlist_dup, &chain->hlist);
> +	ksm_stable_node_dups++;
> +}
> +
> +static inline void __stable_node_dup_del(struct stable_node *dup)
> +{
> +	hlist_del(&dup->hlist_dup);
> +	ksm_stable_node_dups--;
> +}
> +
> +static inline void stable_node_dup_del(struct stable_node *dup)
> +{
> +	VM_BUG_ON(is_stable_node_chain(dup));
> +	if (is_stable_node_dup(dup))
> +		__stable_node_dup_del(dup);
> +	else
> +		rb_erase(&dup->node, root_stable_tree + NUMA(dup->nid));
> +#ifdef CONFIG_DEBUG_VM
> +	dup->head = NULL;
> +#endif
> +}
> +
>  static inline struct rmap_item *alloc_rmap_item(void)
>  {
>  	struct rmap_item *rmap_item;
> @@ -303,6 +370,8 @@ static inline struct stable_node *alloc_stable_node(void)
>  
>  static inline void free_stable_node(struct stable_node *stable_node)
>  {
> +	VM_BUG_ON(stable_node->rmap_hlist_len &&
> +		  !is_stable_node_chain(stable_node));
>  	kmem_cache_free(stable_node_cache, stable_node);
>  }
>  
> @@ -493,25 +562,80 @@ static inline int get_kpfn_nid(unsigned long kpfn)
>  	return ksm_merge_across_nodes ? 0 : NUMA(pfn_to_nid(kpfn));
>  }
>  
> +static struct stable_node *alloc_stable_node_chain(struct stable_node *dup,
> +						   struct rb_root *root)
> +{
> +	struct stable_node *chain = alloc_stable_node();
> +	VM_BUG_ON(is_stable_node_chain(dup));
> +	if (likely(chain)) {
> +		INIT_HLIST_HEAD(&chain->hlist);
> +		chain->chain_prune_time = jiffies;
> +		chain->rmap_hlist_len = STABLE_NODE_CHAIN;
> +#ifdef CONFIG_DEBUG_VM
> +		chain->nid = -1; /* debug */
> +#endif
> +		ksm_stable_node_chains++;
> +
> +		/*
> +		 * Put the stable node chain in the first dimension of
> +		 * the stable tree and at the same time remove the old
> +		 * stable node.
> +		 */
> +		rb_replace_node(&dup->node, &chain->node, root);
> +
> +		/*
> +		 * Move the old stable node to the second dimension
> +		 * queued in the hlist_dup. The invariant is that all
> +		 * dup stable_nodes in the chain->hlist point to pages
> +		 * that are wrprotected and have the exact same
> +		 * content.
> +		 */
> +		stable_node_chain_add_dup(dup, chain);
> +	}
> +	return chain;
> +}
> +
> +static inline void free_stable_node_chain(struct stable_node *chain,
> +					  struct rb_root *root)
> +{
> +	rb_erase(&chain->node, root);
> +	free_stable_node(chain);
> +	ksm_stable_node_chains--;
> +}
> +
>  static void remove_node_from_stable_tree(struct stable_node *stable_node)
>  {
>  	struct rmap_item *rmap_item;
>  
> +	/* check it's not STABLE_NODE_CHAIN or negative */
> +	BUG_ON(stable_node->rmap_hlist_len < 0);
> +
>  	hlist_for_each_entry(rmap_item, &stable_node->hlist, hlist) {
>  		if (rmap_item->hlist.next)
>  			ksm_pages_sharing--;
>  		else
>  			ksm_pages_shared--;
> +		VM_BUG_ON(stable_node->rmap_hlist_len <= 0);
> +		stable_node->rmap_hlist_len--;
>  		put_anon_vma(rmap_item->anon_vma);
>  		rmap_item->address &= PAGE_MASK;
>  		cond_resched();
>  	}
>  
> +	/*
> +	 * We need the second aligned pointer of the migrate_nodes
> +	 * list_head to stay clear from the rb_parent_color union
> +	 * (aligned and different than any node) and also different
> +	 * from &migrate_nodes. This will verify that future list.h changes
> +	 * don't break STABLE_NODE_DUP_HEAD.
> +	 */
> +	BUILD_BUG_ON(STABLE_NODE_DUP_HEAD <= &migrate_nodes);
> +	BUILD_BUG_ON(STABLE_NODE_DUP_HEAD >= &migrate_nodes + 1);
> +
>  	if (stable_node->head == &migrate_nodes)
>  		list_del(&stable_node->list);
>  	else
> -		rb_erase(&stable_node->node,
> -			 root_stable_tree + NUMA(stable_node->nid));
> +		stable_node_dup_del(stable_node);
>  	free_stable_node(stable_node);
>  }
>  
> @@ -630,6 +754,8 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>  			ksm_pages_sharing--;
>  		else
>  			ksm_pages_shared--;
> +		VM_BUG_ON(stable_node->rmap_hlist_len <= 0);
> +		stable_node->rmap_hlist_len--;
>  
>  		put_anon_vma(rmap_item->anon_vma);
>  		rmap_item->address &= PAGE_MASK;
> @@ -738,6 +864,31 @@ static int remove_stable_node(struct stable_node *stable_node)
>  	return err;
>  }
>  
> +static int remove_stable_node_chain(struct stable_node *stable_node,
> +				    struct rb_root *root)
> +{
> +	struct stable_node *dup;
> +	struct hlist_node *hlist_safe;
> +
> +	if (!is_stable_node_chain(stable_node)) {
> +		VM_BUG_ON(is_stable_node_dup(stable_node));
> +		if (remove_stable_node(stable_node))
> +			return true;
> +		else
> +			return false;
> +	}
> +
> +	hlist_for_each_entry_safe(dup, hlist_safe,
> +				  &stable_node->hlist, hlist_dup) {
> +		VM_BUG_ON(!is_stable_node_dup(dup));
> +		if (remove_stable_node(dup))
> +			return true;
> +	}
> +	BUG_ON(!hlist_empty(&stable_node->hlist));
> +	free_stable_node_chain(stable_node, root);
> +	return false;
> +}
> +
>  static int remove_all_stable_nodes(void)
>  {
>  	struct stable_node *stable_node;
> @@ -749,7 +900,8 @@ static int remove_all_stable_nodes(void)
>  		while (root_stable_tree[nid].rb_node) {
>  			stable_node = rb_entry(root_stable_tree[nid].rb_node,
>  						struct stable_node, node);
> -			if (remove_stable_node(stable_node)) {
> +			if (remove_stable_node_chain(stable_node,
> +						     root_stable_tree + nid)) {
>  				err = -EBUSY;
>  				break;	/* proceed to next nid */
>  			}
> @@ -1136,6 +1288,163 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
>  	return err ? NULL : page;
>  }
>  
> +static __always_inline
> +bool __is_page_sharing_candidate(struct stable_node *stable_node, int offset)
> +{
> +	VM_BUG_ON(stable_node->rmap_hlist_len < 0);
> +	/*
> +	 * Check that at least one mapping still exists, otherwise
> +	 * there's no much point to merge and share with this
> +	 * stable_node, as the underlying tree_page of the other
> +	 * sharer is going to be freed soon.
> +	 */
> +	return stable_node->rmap_hlist_len &&
> +		stable_node->rmap_hlist_len + offset < ksm_max_page_sharing;
> +}
> +
> +static __always_inline
> +bool is_page_sharing_candidate(struct stable_node *stable_node)
> +{
> +	return __is_page_sharing_candidate(stable_node, 0);
> +}
> +
> +static struct stable_node *stable_node_dup(struct stable_node *stable_node,
> +					   struct page **tree_page,
> +					   struct rb_root *root,
> +					   bool prune_stale_stable_nodes)
> +{
> +	struct stable_node *dup, *found = NULL;
> +	struct hlist_node *hlist_safe;
> +	struct page *_tree_page;
> +	int nr = 0;
> +	int found_rmap_hlist_len;
> +
> +	if (!prune_stale_stable_nodes ||
> +	    time_before(jiffies, stable_node->chain_prune_time +
> +			msecs_to_jiffies(
> +				ksm_stable_node_chains_prune_millisecs)))
> +		prune_stale_stable_nodes = false;
> +	else
> +		stable_node->chain_prune_time = jiffies;
> +
> +	hlist_for_each_entry_safe(dup, hlist_safe,
> +				  &stable_node->hlist, hlist_dup) {
> +		cond_resched();
> +		/*
> +		 * We must walk all stable_node_dup to prune the stale
> +		 * stable nodes during lookup.
> +		 *
> +		 * get_ksm_page can drop the nodes from the
> +		 * stable_node->hlist if they point to freed pages
> +		 * (that's why we do a _safe walk). The "dup"
> +		 * stable_node parameter itself will be freed from
> +		 * under us if it returns NULL.
> +		 */
> +		_tree_page = get_ksm_page(dup, false);
> +		if (!_tree_page)
> +			continue;
> +		nr += 1;
> +		if (is_page_sharing_candidate(dup)) {
> +			if (!found ||
> +			    dup->rmap_hlist_len > found_rmap_hlist_len) {
> +				if (found)
> +					put_page(*tree_page);
> +				found = dup;
> +				found_rmap_hlist_len = found->rmap_hlist_len;
> +				*tree_page = _tree_page;
> +
> +				if (!prune_stale_stable_nodes)
> +					break;
> +				/* skip put_page */
> +				continue;
> +			}
> +		}
> +		put_page(_tree_page);
> +	}
> +
> +	/*
> +	 * nr is relevant only if prune_stale_stable_nodes is true,
> +	 * otherwise we may break the loop at nr == 1 even if there
> +	 * are multiple entries.
> +	 */
> +	if (prune_stale_stable_nodes && found) {
> +		if (nr == 1) {
> +			/*
> +			 * If there's not just one entry it would
> +			 * corrupt memory, better BUG_ON. In KSM
> +			 * context with no lock held it's not even
> +			 * fatal.
> +			 */
> +			BUG_ON(stable_node->hlist.first->next);
> +
> +			/*
> +			 * There's just one entry and it is below the
> +			 * deduplication limit so drop the chain.
> +			 */
> +			rb_replace_node(&stable_node->node, &found->node,
> +					root);
> +			free_stable_node(stable_node);
> +			ksm_stable_node_chains--;
> +			ksm_stable_node_dups--;
> +		} else if (__is_page_sharing_candidate(found, 1)) {
> +			/*
> +			 * Refile our candidate at the head
> +			 * after the prune if our candidate
> +			 * can accept one more future sharing
> +			 * in addition to the one underway.
> +			 */
> +			hlist_del(&found->hlist_dup);
> +			hlist_add_head(&found->hlist_dup,
> +				       &stable_node->hlist);
> +		}
> +	}
> +
> +	return found;
> +}
> +
> +static struct stable_node *stable_node_dup_any(struct stable_node *stable_node,
> +					       struct rb_root *root)
> +{
> +	if (!is_stable_node_chain(stable_node))
> +		return stable_node;
> +	if (hlist_empty(&stable_node->hlist)) {
> +		free_stable_node_chain(stable_node, root);
> +		return NULL;
> +	}
> +	return hlist_entry(stable_node->hlist.first,
> +			   typeof(*stable_node), hlist_dup);
> +}
> +
> +static struct stable_node *__stable_node_chain(struct stable_node *stable_node,
> +					       struct page **tree_page,
> +					       struct rb_root *root,
> +					       bool prune_stale_stable_nodes)
> +{
> +	if (!is_stable_node_chain(stable_node)) {
> +		if (is_page_sharing_candidate(stable_node)) {
> +			*tree_page = get_ksm_page(stable_node, false);
> +			return stable_node;
> +		}
> +		return NULL;
> +	}
> +	return stable_node_dup(stable_node, tree_page, root,
> +			       prune_stale_stable_nodes);
> +}
> +
> +static __always_inline struct stable_node *chain_prune(struct stable_node *s_n,
> +						       struct page **t_p,
> +						       struct rb_root *root)
> +{
> +	return __stable_node_chain(s_n, t_p, root, true);
> +}
> +
> +static __always_inline struct stable_node *chain(struct stable_node *s_n,
> +						 struct page **t_p,
> +						 struct rb_root *root)
> +{
> +	return __stable_node_chain(s_n, t_p, root, false);
> +}
> +
>  /*
>   * stable_tree_search - search for page inside the stable tree
>   *
> @@ -1151,7 +1460,7 @@ static struct page *stable_tree_search(struct page *page)
>  	struct rb_root *root;
>  	struct rb_node **new;
>  	struct rb_node *parent;
> -	struct stable_node *stable_node;
> +	struct stable_node *stable_node, *stable_node_dup, *stable_node_any;
>  	struct stable_node *page_node;
>  
>  	page_node = page_stable_node(page);
> @@ -1173,7 +1482,32 @@ again:
>  
>  		cond_resched();
>  		stable_node = rb_entry(*new, struct stable_node, node);
> -		tree_page = get_ksm_page(stable_node, false);
> +		stable_node_any = NULL;
> +		stable_node_dup = chain_prune(stable_node, &tree_page, root);
> +		if (!stable_node_dup) {
> +			/*
> +			 * Either all stable_node dups were full in
> +			 * this stable_node chain, or this chain was
> +			 * empty and should be rb_erased.
> +			 */
> +			stable_node_any = stable_node_dup_any(stable_node,
> +							      root);
> +			if (!stable_node_any) {
> +				/* rb_erase just run */
> +				goto again;
> +			}
> +			/*
> +			 * Take any of the stable_node dups page of
> +			 * this stable_node chain to let the tree walk
> +			 * continue. All KSM pages belonging to the
> +			 * stable_node dups in a stable_node chain
> +			 * have the same content and they're
> +			 * wrprotected at all times. Any will work
> +			 * fine to continue the walk.
> +			 */
> +			tree_page = get_ksm_page(stable_node_any, false);
> +		}
> +		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
>  		if (!tree_page) {
>  			/*
>  			 * If we walked over a stale stable_node,
> @@ -1196,6 +1530,34 @@ again:
>  		else if (ret > 0)
>  			new = &parent->rb_right;
>  		else {
> +			if (page_node) {
> +				VM_BUG_ON(page_node->head != &migrate_nodes);
> +				/*
> +				 * Test if the migrated page should be merged
> +				 * into a stable node dup. If the mapcount is
> +				 * 1 we can migrate it with another KSM page
> +				 * without adding it to the chain.
> +				 */
> +				if (page_mapcount(page) > 1)
> +					goto chain_append;
> +			}
> +
> +			if (!stable_node_dup) {
> +				/*
> +				 * If the stable_node is a chain and
> +				 * we got a payload match in memcmp
> +				 * but we cannot merge the scanned
> +				 * page in any of the existing
> +				 * stable_node dups because they're
> +				 * all full, we need to wait the
> +				 * scanned page to find itself a match
> +				 * in the unstable tree to create a
> +				 * brand new KSM page to add later to
> +				 * the dups of this stable_node.
> +				 */
> +				return NULL;
> +			}
> +
>  			/*
>  			 * Lock and unlock the stable_node's page (which
>  			 * might already have been migrated) so that page
> @@ -1203,23 +1565,21 @@ again:
>  			 * It would be more elegant to return stable_node
>  			 * than kpage, but that involves more changes.
>  			 */
> -			tree_page = get_ksm_page(stable_node, true);
> -			if (tree_page) {
> -				unlock_page(tree_page);
> -				if (get_kpfn_nid(stable_node->kpfn) !=
> -						NUMA(stable_node->nid)) {
> -					put_page(tree_page);
> -					goto replace;
> -				}
> -				return tree_page;
> -			}
> -			/*
> -			 * There is now a place for page_node, but the tree may
> -			 * have been rebalanced, so re-evaluate parent and new.
> -			 */
> -			if (page_node)
> +			tree_page = get_ksm_page(stable_node_dup, true);
> +			if (unlikely(!tree_page))
> +				/*
> +				 * The tree may have been rebalanced,
> +				 * so re-evaluate parent and new.
> +				 */
>  				goto again;
> -			return NULL;
> +			unlock_page(tree_page);
> +
> +			if (get_kpfn_nid(stable_node_dup->kpfn) !=
> +			    NUMA(stable_node_dup->nid)) {
> +				put_page(tree_page);
> +				goto replace;
> +			}
> +			return tree_page;
>  		}
>  	}
>  
> @@ -1230,22 +1590,72 @@ again:
>  	DO_NUMA(page_node->nid = nid);
>  	rb_link_node(&page_node->node, parent, new);
>  	rb_insert_color(&page_node->node, root);
> -	get_page(page);
> -	return page;
> +out:
> +	if (is_page_sharing_candidate(page_node)) {
> +		get_page(page);
> +		return page;
> +	} else
> +		return NULL;
>  
>  replace:
> -	if (page_node) {
> -		list_del(&page_node->list);
> -		DO_NUMA(page_node->nid = nid);
> -		rb_replace_node(&stable_node->node, &page_node->node, root);
> -		get_page(page);
> +	if (stable_node_dup == stable_node) {
> +		/* there is no chain */
> +		if (page_node) {
> +			VM_BUG_ON(page_node->head != &migrate_nodes);
> +			list_del(&page_node->list);
> +			DO_NUMA(page_node->nid = nid);
> +			rb_replace_node(&stable_node->node, &page_node->node,
> +					root);
> +			if (is_page_sharing_candidate(page_node))
> +				get_page(page);
> +			else
> +				page = NULL;
> +		} else {
> +			rb_erase(&stable_node->node, root);
> +			page = NULL;
> +		}
>  	} else {
> -		rb_erase(&stable_node->node, root);
> -		page = NULL;
> +		VM_BUG_ON(!is_stable_node_chain(stable_node));
> +		__stable_node_dup_del(stable_node_dup);
> +		if (page_node) {
> +			VM_BUG_ON(page_node->head != &migrate_nodes);
> +			list_del(&page_node->list);
> +			DO_NUMA(page_node->nid = nid);
> +			stable_node_chain_add_dup(page_node, stable_node);
> +			if (is_page_sharing_candidate(page_node))
> +				get_page(page);
> +			else
> +				page = NULL;
> +		} else {
> +			page = NULL;
> +		}
>  	}
> -	stable_node->head = &migrate_nodes;
> -	list_add(&stable_node->list, stable_node->head);
> +	stable_node_dup->head = &migrate_nodes;
> +	list_add(&stable_node_dup->list, stable_node_dup->head);
>  	return page;
> +
> +chain_append:
> +	/* stable_node_dup could be null if it reached the limit */
> +	if (!stable_node_dup)
> +		stable_node_dup = stable_node_any;
> +	if (stable_node_dup == stable_node) {
> +		/* chain is missing so create it */
> +		stable_node = alloc_stable_node_chain(stable_node_dup,
> +						      root);
> +		if (!stable_node)
> +			return NULL;
> +	}
> +	/*
> +	 * Add this stable_node dup that was
> +	 * migrated to the stable_node chain
> +	 * of the current nid for this page
> +	 * content.
> +	 */
> +	VM_BUG_ON(page_node->head != &migrate_nodes);
> +	list_del(&page_node->list);
> +	DO_NUMA(page_node->nid = nid);
> +	stable_node_chain_add_dup(page_node, stable_node);
> +	goto out;
>  }
>  
>  /*
> @@ -1262,7 +1672,8 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>  	struct rb_root *root;
>  	struct rb_node **new;
>  	struct rb_node *parent;
> -	struct stable_node *stable_node;
> +	struct stable_node *stable_node, *stable_node_dup, *stable_node_any;
> +	bool need_chain = false;
>  
>  	kpfn = page_to_pfn(kpage);
>  	nid = get_kpfn_nid(kpfn);
> @@ -1277,7 +1688,32 @@ again:
>  
>  		cond_resched();
>  		stable_node = rb_entry(*new, struct stable_node, node);
> -		tree_page = get_ksm_page(stable_node, false);
> +		stable_node_any = NULL;
> +		stable_node_dup = chain(stable_node, &tree_page, root);
> +		if (!stable_node_dup) {
> +			/*
> +			 * Either all stable_node dups were full in
> +			 * this stable_node chain, or this chain was
> +			 * empty and should be rb_erased.
> +			 */
> +			stable_node_any = stable_node_dup_any(stable_node,
> +							      root);
> +			if (!stable_node_any) {
> +				/* rb_erase just run */
> +				goto again;
> +			}
> +			/*
> +			 * Take any of the stable_node dups page of
> +			 * this stable_node chain to let the tree walk
> +			 * continue. All KSM pages belonging to the
> +			 * stable_node dups in a stable_node chain
> +			 * have the same content and they're
> +			 * wrprotected at all times. Any will work
> +			 * fine to continue the walk.
> +			 */
> +			tree_page = get_ksm_page(stable_node_any, false);
> +		}
> +		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
>  		if (!tree_page) {
>  			/*
>  			 * If we walked over a stale stable_node,
> @@ -1300,27 +1736,37 @@ again:
>  		else if (ret > 0)
>  			new = &parent->rb_right;
>  		else {
> -			/*
> -			 * It is not a bug that stable_tree_search() didn't
> -			 * find this node: because at that time our page was
> -			 * not yet write-protected, so may have changed since.
> -			 */
> -			return NULL;
> +			need_chain = true;
> +			break;
>  		}
>  	}
>  
> -	stable_node = alloc_stable_node();
> -	if (!stable_node)
> +	stable_node_dup = alloc_stable_node();
> +	if (!stable_node_dup)
>  		return NULL;
>  
> -	INIT_HLIST_HEAD(&stable_node->hlist);
> -	stable_node->kpfn = kpfn;
> -	set_page_stable_node(kpage, stable_node);
> -	DO_NUMA(stable_node->nid = nid);
> -	rb_link_node(&stable_node->node, parent, new);
> -	rb_insert_color(&stable_node->node, root);
> +	INIT_HLIST_HEAD(&stable_node_dup->hlist);
> +	stable_node_dup->kpfn = kpfn;
> +	set_page_stable_node(kpage, stable_node_dup);
> +	stable_node_dup->rmap_hlist_len = 0;
> +	DO_NUMA(stable_node_dup->nid = nid);
> +	if (!need_chain) {
> +		rb_link_node(&stable_node_dup->node, parent, new);
> +		rb_insert_color(&stable_node_dup->node, root);
> +	} else {
> +		if (!is_stable_node_chain(stable_node)) {
> +			struct stable_node *orig = stable_node;
> +			/* chain is missing so create it */
> +			stable_node = alloc_stable_node_chain(orig, root);
> +			if (!stable_node) {
> +				free_stable_node(stable_node_dup);
> +				return NULL;
> +			}
> +		}
> +		stable_node_chain_add_dup(stable_node_dup, stable_node);
> +	}
>  
> -	return stable_node;
> +	return stable_node_dup;
>  }
>  
>  /*
> @@ -1410,8 +1856,27 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>   * the same ksm page.
>   */
>  static void stable_tree_append(struct rmap_item *rmap_item,
> -			       struct stable_node *stable_node)
> +			       struct stable_node *stable_node,
> +			       bool max_page_sharing_bypass)
>  {
> +	/*
> +	 * rmap won't find this mapping if we don't insert the
> +	 * rmap_item in the right stable_node
> +	 * duplicate. page_migration could break later if rmap breaks,
> +	 * so we can as well crash here. We really need to check for
> +	 * rmap_hlist_len == STABLE_NODE_CHAIN, but we can as well check
> +	 * for other negative values as an undeflow if detected here
> +	 * for the first time (and not when decreasing rmap_hlist_len)
> +	 * would be sign of memory corruption in the stable_node.
> +	 */
> +	BUG_ON(stable_node->rmap_hlist_len < 0);
> +
> +	stable_node->rmap_hlist_len++;
> +	if (!max_page_sharing_bypass)
> +		/* possibly non fatal but unexpected overflow, only warn */
> +		WARN_ON_ONCE(stable_node->rmap_hlist_len >
> +			     ksm_max_page_sharing);
> +
>  	rmap_item->head = stable_node;
>  	rmap_item->address |= STABLE_FLAG;
>  	hlist_add_head(&rmap_item->hlist, &stable_node->hlist);
> @@ -1439,19 +1904,26 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  	struct page *kpage;
>  	unsigned int checksum;
>  	int err;
> +	bool max_page_sharing_bypass = false;
>  
>  	stable_node = page_stable_node(page);
>  	if (stable_node) {
>  		if (stable_node->head != &migrate_nodes &&
> -		    get_kpfn_nid(stable_node->kpfn) != NUMA(stable_node->nid)) {
> -			rb_erase(&stable_node->node,
> -				 root_stable_tree + NUMA(stable_node->nid));
> +		    get_kpfn_nid(READ_ONCE(stable_node->kpfn)) !=
> +		    NUMA(stable_node->nid)) {
> +			stable_node_dup_del(stable_node);
>  			stable_node->head = &migrate_nodes;
>  			list_add(&stable_node->list, stable_node->head);
>  		}
>  		if (stable_node->head != &migrate_nodes &&
>  		    rmap_item->head == stable_node)
>  			return;
> +		/*
> +		 * If it's a KSM fork, allow it to go over the sharing limit
> +		 * without warnings.
> +		 */
> +		if (!is_page_sharing_candidate(stable_node))
> +			max_page_sharing_bypass = true;
>  	}
>  
>  	/* We first start with searching the page inside the stable tree */
> @@ -1471,7 +1943,8 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  			 * add its rmap_item to the stable tree.
>  			 */
>  			lock_page(kpage);
> -			stable_tree_append(rmap_item, page_stable_node(kpage));
> +			stable_tree_append(rmap_item, page_stable_node(kpage),
> +					   max_page_sharing_bypass);
>  			unlock_page(kpage);
>  		}
>  		put_page(kpage);
> @@ -1504,8 +1977,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  			lock_page(kpage);
>  			stable_node = stable_tree_insert(kpage);
>  			if (stable_node) {
> -				stable_tree_append(tree_rmap_item, stable_node);
> -				stable_tree_append(rmap_item, stable_node);
> +				stable_tree_append(tree_rmap_item, stable_node,
> +						   false);
> +				stable_tree_append(rmap_item, stable_node,
> +						   false);
>  			}
>  			unlock_page(kpage);
>  
> @@ -2009,6 +2484,48 @@ static void wait_while_offlining(void)
>  	}
>  }
>  
> +static bool stable_node_dup_remove_range(struct stable_node *stable_node,
> +					 unsigned long start_pfn,
> +					 unsigned long end_pfn)
> +{
> +	if (stable_node->kpfn >= start_pfn &&
> +	    stable_node->kpfn < end_pfn) {
> +		/*
> +		 * Don't get_ksm_page, page has already gone:
> +		 * which is why we keep kpfn instead of page*
> +		 */
> +		remove_node_from_stable_tree(stable_node);
> +		return true;
> +	}
> +	return false;
> +}
> +
> +static bool stable_node_chain_remove_range(struct stable_node *stable_node,
> +					   unsigned long start_pfn,
> +					   unsigned long end_pfn,
> +					   struct rb_root *root)
> +{
> +	struct stable_node *dup;
> +	struct hlist_node *hlist_safe;
> +
> +	if (!is_stable_node_chain(stable_node)) {
> +		VM_BUG_ON(is_stable_node_dup(stable_node));
> +		return stable_node_dup_remove_range(stable_node, start_pfn,
> +						    end_pfn);
> +	}
> +
> +	hlist_for_each_entry_safe(dup, hlist_safe,
> +				  &stable_node->hlist, hlist_dup) {
> +		VM_BUG_ON(!is_stable_node_dup(dup));
> +		stable_node_dup_remove_range(dup, start_pfn, end_pfn);
> +	}
> +	if (hlist_empty(&stable_node->hlist)) {
> +		free_stable_node_chain(stable_node, root);
> +		return true; /* notify caller that tree was rebalanced */
> +	} else
> +		return false;
> +}
> +
>  static void ksm_check_stable_tree(unsigned long start_pfn,
>  				  unsigned long end_pfn)
>  {
> @@ -2021,15 +2538,12 @@ static void ksm_check_stable_tree(unsigned long start_pfn,
>  		node = rb_first(root_stable_tree + nid);
>  		while (node) {
>  			stable_node = rb_entry(node, struct stable_node, node);
> -			if (stable_node->kpfn >= start_pfn &&
> -			    stable_node->kpfn < end_pfn) {
> -				/*
> -				 * Don't get_ksm_page, page has already gone:
> -				 * which is why we keep kpfn instead of page*
> -				 */
> -				remove_node_from_stable_tree(stable_node);
> +			if (stable_node_chain_remove_range(stable_node,
> +							   start_pfn, end_pfn,
> +							   root_stable_tree +
> +							   nid))
>  				node = rb_first(root_stable_tree + nid);
> -			} else
> +			else
>  				node = rb_next(node);
>  			cond_resched();
>  		}
> @@ -2254,6 +2768,47 @@ static ssize_t merge_across_nodes_store(struct kobject *kobj,
>  KSM_ATTR(merge_across_nodes);
>  #endif
>  
> +static ssize_t max_page_sharing_show(struct kobject *kobj,
> +				     struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%u\n", ksm_max_page_sharing);
> +}
> +
> +static ssize_t max_page_sharing_store(struct kobject *kobj,
> +				      struct kobj_attribute *attr,
> +				      const char *buf, size_t count)
> +{
> +	int err;
> +	int knob;
> +
> +	err = kstrtoint(buf, 10, &knob);
> +	if (err)
> +		return err;
> +	/*
> +	 * When a KSM page is created it is shared by 2 mappings. This
> +	 * being a signed comparison, it implicitly verifies it's not
> +	 * negative.
> +	 */
> +	if (knob < 2)
> +		return -EINVAL;
> +
> +	if (READ_ONCE(ksm_max_page_sharing) == knob)
> +		return count;
> +
> +	mutex_lock(&ksm_thread_mutex);
> +	wait_while_offlining();
> +	if (ksm_max_page_sharing != knob) {
> +		if (ksm_pages_shared || remove_all_stable_nodes())
> +			err = -EBUSY;
> +		else
> +			ksm_max_page_sharing = knob;
> +	}
> +	mutex_unlock(&ksm_thread_mutex);
> +
> +	return err ? err : count;
> +}
> +KSM_ATTR(max_page_sharing);
> +
>  static ssize_t pages_shared_show(struct kobject *kobj,
>  				 struct kobj_attribute *attr, char *buf)
>  {
> @@ -2292,6 +2847,46 @@ static ssize_t pages_volatile_show(struct kobject *kobj,
>  }
>  KSM_ATTR_RO(pages_volatile);
>  
> +static ssize_t stable_node_dups_show(struct kobject *kobj,
> +				     struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", ksm_stable_node_dups);
> +}
> +KSM_ATTR_RO(stable_node_dups);
> +
> +static ssize_t stable_node_chains_show(struct kobject *kobj,
> +				       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", ksm_stable_node_chains);
> +}
> +KSM_ATTR_RO(stable_node_chains);
> +
> +static ssize_t
> +stable_node_chains_prune_millisecs_show(struct kobject *kobj,
> +					struct kobj_attribute *attr,
> +					char *buf)
> +{
> +	return sprintf(buf, "%u\n", ksm_stable_node_chains_prune_millisecs);
> +}
> +
> +static ssize_t
> +stable_node_chains_prune_millisecs_store(struct kobject *kobj,
> +					 struct kobj_attribute *attr,
> +					 const char *buf, size_t count)
> +{
> +	unsigned long msecs;
> +	int err;
> +
> +	err = kstrtoul(buf, 10, &msecs);
> +	if (err || msecs > UINT_MAX)
> +		return -EINVAL;
> +
> +	ksm_stable_node_chains_prune_millisecs = msecs;
> +
> +	return count;
> +}
> +KSM_ATTR(stable_node_chains_prune_millisecs);
> +
>  static ssize_t full_scans_show(struct kobject *kobj,
>  			       struct kobj_attribute *attr, char *buf)
>  {
> @@ -2311,6 +2906,10 @@ static struct attribute *ksm_attrs[] = {
>  #ifdef CONFIG_NUMA
>  	&merge_across_nodes_attr.attr,
>  #endif
> +	&max_page_sharing_attr.attr,
> +	&stable_node_chains_attr.attr,
> +	&stable_node_dups_attr.attr,
> +	&stable_node_chains_prune_millisecs_attr.attr,
>  	NULL,
>  };
>  

-- 
Petr Holasek
pholasek@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
