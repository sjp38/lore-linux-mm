Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id BFC476B0008
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 22:44:25 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1037040dak.0
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 19:44:24 -0800 (PST)
Message-ID: <1359344663.6763.32.camel@kernel>
Subject: Re: [PATCH 8/11] ksm: make !merge_across_nodes migration safe
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sun, 27 Jan 2013 21:44:23 -0600
In-Reply-To: <alpine.LNX.2.00.1301251803390.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	 <alpine.LNX.2.00.1301251803390.29196@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2013-01-25 at 18:05 -0800, Hugh Dickins wrote:
> The new KSM NUMA merge_across_nodes knob introduces a problem, when it's
> set to non-default 0: if a KSM page is migrated to a different NUMA node,
> how do we migrate its stable node to the right tree?  And what if that
> collides with an existing stable node?
> 
> ksm_migrate_page() can do no more than it's already doing, updating
> stable_node->kpfn: the stable tree itself cannot be manipulated without
> holding ksm_thread_mutex.  So accept that a stable tree may temporarily
> indicate a page belonging to the wrong NUMA node, leave updating until
> the next pass of ksmd, just be careful not to merge other pages on to a

How you not to merge other pages on to a misplaced page? I don't see it.

> misplaced page.  Note nid of holding tree in stable_node, and recognize
> that it will not always match nid of kpfn.
> 
> A misplaced KSM page is discovered, either when ksm_do_scan() next comes
> around to one of its rmap_items (we now have to go to cmp_and_merge_page
> even on pages in a stable tree), or when stable_tree_search() arrives at
> a matching node for another page, and this node page is found misplaced.
> 
> In each case, move the misplaced stable_node to a list of migrate_nodes
> (and use the address of migrate_nodes as magic by which to identify them):
> we don't need them in a tree.  If stable_tree_search() finds no match for
> a page, but it's currently exiled to this list, then slot its stable_node
> right there into the tree, bringing all of its mappings with it; otherwise
> they get migrated one by one to the original page of the colliding node.
> stable_tree_search() is now modelled more like stable_tree_insert(),
> in order to handle these insertions of migrated nodes.

When node will be removed from migrate_nodes list and insert to stable
tree?

> 
> remove_node_from_stable_tree(), remove_all_stable_nodes() and
> ksm_check_stable_tree() have to handle the migrate_nodes list as well as
> the stable tree itself.  Less obviously, we do need to prune the list of
> stale entries from time to time (scan_get_next_rmap_item() does it once
> each full scan):

>  whereas stale nodes in the stable tree get naturally
> pruned as searches try to brush past them, these migrate_nodes may get
> forgotten and accumulate.

Hard to understand this description. Could you explain it? :)

> Signed-off-by: Hugh Dickins <hughd@google.com>

What will happen if page node of an unstable tree migrate to a new numa
node? Also need to handle colliding? 

> ---
>  mm/ksm.c |  164 +++++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 134 insertions(+), 30 deletions(-)
> 
> --- mmotm.orig/mm/ksm.c	2013-01-25 14:37:03.832206218 -0800
> +++ mmotm/mm/ksm.c	2013-01-25 14:37:06.880206290 -0800
> @@ -122,13 +122,25 @@ struct ksm_scan {
>  /**
>   * struct stable_node - node of the stable rbtree
>   * @node: rb node of this ksm page in the stable tree
> + * @head: (overlaying parent) &migrate_nodes indicates temporarily on that list
> + * @list: linked into migrate_nodes, pending placement in the proper node tree
>   * @hlist: hlist head of rmap_items using this ksm page
> - * @kpfn: page frame number of this ksm page
> + * @kpfn: page frame number of this ksm page (perhaps temporarily on wrong nid)
> + * @nid: NUMA node id of stable tree in which linked (may not match kpfn)
>   */
>  struct stable_node {
> -	struct rb_node node;
> +	union {
> +		struct rb_node node;	/* when node of stable tree */
> +		struct {		/* when listed for migration */
> +			struct list_head *head;
> +			struct list_head list;
> +		};
> +	};
>  	struct hlist_head hlist;
>  	unsigned long kpfn;
> +#ifdef CONFIG_NUMA
> +	int nid;
> +#endif
>  };
>  
>  /**
> @@ -169,6 +181,9 @@ struct rmap_item {
>  static struct rb_root root_unstable_tree[MAX_NUMNODES];
>  static struct rb_root root_stable_tree[MAX_NUMNODES];
>  
> +/* Recently migrated nodes of stable tree, pending proper placement */
> +static LIST_HEAD(migrate_nodes);
> +
>  #define MM_SLOTS_HASH_BITS 10
>  static DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
>  
> @@ -311,11 +326,6 @@ static void insert_to_mm_slots_hash(stru
>  	hash_add(mm_slots_hash, &mm_slot->link, (unsigned long)mm);
>  }
>  
> -static inline int in_stable_tree(struct rmap_item *rmap_item)
> -{
> -	return rmap_item->address & STABLE_FLAG;
> -}
> -
>  /*
>   * ksmd, and unmerge_and_remove_all_rmap_items(), must not touch an mm's
>   * page tables after it has passed through ksm_exit() - which, if necessary,
> @@ -476,7 +486,6 @@ static void remove_node_from_stable_tree
>  {
>  	struct rmap_item *rmap_item;
>  	struct hlist_node *hlist;
> -	int nid;
>  
>  	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
>  		if (rmap_item->hlist.next)
> @@ -488,8 +497,11 @@ static void remove_node_from_stable_tree
>  		cond_resched();
>  	}
>  
> -	nid = get_kpfn_nid(stable_node->kpfn);
> -	rb_erase(&stable_node->node, &root_stable_tree[nid]);
> +	if (stable_node->head == &migrate_nodes)
> +		list_del(&stable_node->list);
> +	else
> +		rb_erase(&stable_node->node,
> +			 &root_stable_tree[NUMA(stable_node->nid)]);
>  	free_stable_node(stable_node);
>  }
>  
> @@ -712,6 +724,7 @@ static int remove_stable_node(struct sta
>  static int remove_all_stable_nodes(void)
>  {
>  	struct stable_node *stable_node;
> +	struct list_head *this, *next;
>  	int nid;
>  	int err = 0;
>  
> @@ -726,6 +739,12 @@ static int remove_all_stable_nodes(void)
>  			cond_resched();
>  		}
>  	}
> +	list_for_each_safe(this, next, &migrate_nodes) {
> +		stable_node = list_entry(this, struct stable_node, list);
> +		if (remove_stable_node(stable_node))
> +			err = -EBUSY;
> +		cond_resched();
> +	}
>  	return err;
>  }
>  
> @@ -1113,25 +1132,30 @@ static struct page *try_to_merge_two_pag
>   */
>  static struct page *stable_tree_search(struct page *page)
>  {
> -	struct rb_node *node;
> -	struct stable_node *stable_node;
>  	int nid;
> +	struct rb_node **new;
> +	struct rb_node *parent;
> +	struct stable_node *stable_node;
> +	struct stable_node *page_node;
>  
> -	stable_node = page_stable_node(page);
> -	if (stable_node) {			/* ksm page forked */
> +	page_node = page_stable_node(page);
> +	if (page_node && page_node->head != &migrate_nodes) {
> +		/* ksm page forked */
>  		get_page(page);
>  		return page;
>  	}
>  
>  	nid = get_kpfn_nid(page_to_pfn(page));
> -	node = root_stable_tree[nid].rb_node;
> +again:
> +	new = &root_stable_tree[nid].rb_node;
> +	parent = NULL;
>  
> -	while (node) {
> +	while (*new) {
>  		struct page *tree_page;
>  		int ret;
>  
>  		cond_resched();
> -		stable_node = rb_entry(node, struct stable_node, node);
> +		stable_node = rb_entry(*new, struct stable_node, node);
>  		tree_page = get_ksm_page(stable_node, false);
>  		if (!tree_page)
>  			return NULL;
> @@ -1139,10 +1163,11 @@ static struct page *stable_tree_search(s
>  		ret = memcmp_pages(page, tree_page);
>  		put_page(tree_page);
>  
> +		parent = *new;
>  		if (ret < 0)
> -			node = node->rb_left;
> +			new = &parent->rb_left;
>  		else if (ret > 0)
> -			node = node->rb_right;
> +			new = &parent->rb_right;
>  		else {
>  			/*
>  			 * Lock and unlock the stable_node's page (which
> @@ -1152,13 +1177,49 @@ static struct page *stable_tree_search(s
>  			 * than kpage, but that involves more changes.
>  			 */
>  			tree_page = get_ksm_page(stable_node, true);
> -			if (tree_page)
> +			if (tree_page) {
>  				unlock_page(tree_page);
> -			return tree_page;
> +				if (get_kpfn_nid(stable_node->kpfn) !=
> +						NUMA(stable_node->nid)) {
> +					put_page(tree_page);
> +					goto replace;
> +				}
> +				return tree_page;
> +			}
> +			/*
> +			 * There is now a place for page_node, but the tree may
> +			 * have been rebalanced, so re-evaluate parent and new.
> +			 */
> +			if (page_node)
> +				goto again;
> +			return NULL;
>  		}
>  	}
>  
> -	return NULL;
> +	if (!page_node)
> +		return NULL;
> +
> +	list_del(&page_node->list);
> +	DO_NUMA(page_node->nid = nid);
> +	rb_link_node(&page_node->node, parent, new);
> +	rb_insert_color(&page_node->node, &root_stable_tree[nid]);
> +	get_page(page);
> +	return page;
> +
> +replace:
> +	if (page_node) {
> +		list_del(&page_node->list);
> +		DO_NUMA(page_node->nid = nid);
> +		rb_replace_node(&stable_node->node,
> +				&page_node->node, &root_stable_tree[nid]);
> +		get_page(page);
> +	} else {
> +		rb_erase(&stable_node->node, &root_stable_tree[nid]);
> +		page = NULL;
> +	}
> +	stable_node->head = &migrate_nodes;

Why still set this magic since node has already insert to the tree? 

> +	list_add(&stable_node->list, stable_node->head);
> +	return page;
>  }
>  
>  /*
> @@ -1215,6 +1276,7 @@ static struct stable_node *stable_tree_i
>  	INIT_HLIST_HEAD(&stable_node->hlist);
>  	stable_node->kpfn = kpfn;
>  	set_page_stable_node(kpage, stable_node);
> +	DO_NUMA(stable_node->nid = nid);
>  	rb_link_node(&stable_node->node, parent, new);
>  	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
>  
> @@ -1311,11 +1373,6 @@ struct rmap_item *unstable_tree_search_i
>  static void stable_tree_append(struct rmap_item *rmap_item,
>  			       struct stable_node *stable_node)
>  {
> -	/*
> -	 * Usually rmap_item->nid is already set correctly,
> -	 * but it may be wrong after switching merge_across_nodes.
> -	 */
> -	DO_NUMA(rmap_item->nid = get_kpfn_nid(stable_node->kpfn));
>  	rmap_item->head = stable_node;
>  	rmap_item->address |= STABLE_FLAG;
>  	hlist_add_head(&rmap_item->hlist, &stable_node->hlist);
> @@ -1344,10 +1401,29 @@ static void cmp_and_merge_page(struct pa
>  	unsigned int checksum;
>  	int err;
>  
> -	remove_rmap_item_from_tree(rmap_item);
> +	stable_node = page_stable_node(page);
> +	if (stable_node) {
> +		if (stable_node->head != &migrate_nodes &&
> +		    get_kpfn_nid(stable_node->kpfn) != NUMA(stable_node->nid)) {
> +			rb_erase(&stable_node->node,
> +				 &root_stable_tree[NUMA(stable_node->nid)]);
> +			stable_node->head = &migrate_nodes;
> +			list_add(&stable_node->list, stable_node->head);
> +		}
> +		if (stable_node->head != &migrate_nodes &&
> +		    rmap_item->head == stable_node)
> +			return;
> +	}
>  
>  	/* We first start with searching the page inside the stable tree */
>  	kpage = stable_tree_search(page);
> +	if (kpage == page && rmap_item->head == stable_node) {
> +		put_page(kpage);
> +		return;
> +	}
> +
> +	remove_rmap_item_from_tree(rmap_item);
> +
>  	if (kpage) {
>  		err = try_to_merge_with_ksm_page(rmap_item, page, kpage);
>  		if (!err) {
> @@ -1464,6 +1540,27 @@ static struct rmap_item *scan_get_next_r
>  		 */
>  		lru_add_drain_all();
>  
> +		/*
> +		 * Whereas stale stable_nodes on the stable_tree itself
> +		 * get pruned in the regular course of stable_tree_search(),
> +		 * those moved out to the migrate_nodes list can accumulate:
> +		 * so prune them once before each full scan.
> +		 */
> +		if (!ksm_merge_across_nodes) {
> +			struct stable_node *stable_node;
> +			struct list_head *this, *next;
> +			struct page *page;
> +
> +			list_for_each_safe(this, next, &migrate_nodes) {
> +				stable_node = list_entry(this,
> +						struct stable_node, list);
> +				page = get_ksm_page(stable_node, false);
> +				if (page)
> +					put_page(page);
> +				cond_resched();
> +			}
> +		}
> +
>  		for (nid = 0; nid < nr_node_ids; nid++)
>  			root_unstable_tree[nid] = RB_ROOT;
>  
> @@ -1586,8 +1683,7 @@ static void ksm_do_scan(unsigned int sca
>  		rmap_item = scan_get_next_rmap_item(&page);
>  		if (!rmap_item)
>  			return;
> -		if (!PageKsm(page) || !in_stable_tree(rmap_item))
> -			cmp_and_merge_page(page, rmap_item);
> +		cmp_and_merge_page(page, rmap_item);
>  		put_page(page);
>  	}
>  }
> @@ -1964,6 +2060,7 @@ static void ksm_check_stable_tree(unsign
>  				  unsigned long end_pfn)
>  {
>  	struct stable_node *stable_node;
> +	struct list_head *this, *next;
>  	struct rb_node *node;
>  	int nid;
>  
> @@ -1984,6 +2081,13 @@ static void ksm_check_stable_tree(unsign
>  			cond_resched();
>  		}
>  	}
> +	list_for_each_safe(this, next, &migrate_nodes) {
> +		stable_node = list_entry(this, struct stable_node, list);
> +		if (stable_node->kpfn >= start_pfn &&
> +		    stable_node->kpfn < end_pfn)
> +			remove_node_from_stable_tree(stable_node);
> +		cond_resched();
> +	}
>  }
>  
>  static int ksm_memory_callback(struct notifier_block *self,
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
