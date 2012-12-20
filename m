Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 8BA256B0044
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 19:22:35 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id uo1so1563789pbc.31
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 16:22:34 -0800 (PST)
Date: Wed, 19 Dec 2012 16:21:54 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm, ksm: NULL ptr deref in unstable_tree_search_insert
In-Reply-To: <alpine.LNX.2.00.1212190929530.7767@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1212191517150.21603@eggly.anvils>
References: <50D1158F.5070905@oracle.com> <alpine.LNX.2.00.1212181728400.1091@eggly.anvils> <20121219121647.GB4381@thinkpad-work.redhat.com> <alpine.LNX.2.00.1212190929530.7767@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 19 Dec 2012, Hugh Dickins wrote:
> On Wed, 19 Dec 2012, Petr Holasek wrote:
> > > 
> > > For the moment, you're safer not to run KSM: configure it out or don't
> > > set it to run.  Fixes to follow later, I'll try to remember to Cc you.
> 
> Sadly I couldn't send out fixes yesterday, because my testing then
> met another more subtle problem, that I've still not yet resolved.
> 
> > I've also tried fuzzing with trinity inside of kvm guest when tested KSM
> > patch, but applied on top of 3.7-rc8, but didn't trigger that oops. So
> > going to do the same testing on linux-next.
> 
> I haven't tried linux-next myself, it being in a transitional state
> until 3.8-rc1.  I've been testing on Linus's git from last weekend
> (head at a4f1de176614f634c367e5994a7bcc428c940df0 to be precise),
> plus your patch, plus my fixes.
> 
> > 
> > Hugh, does it seem like bug in unstable_tree_search_insert() you mentioned
> > in yesterday email of something else?
> 
> Yes, Sasha's is exactly the one I got earlier: hitting in
> get_mergeable_page() due to bug in unstable_tree_search_insert().
> 
> From your next mail, I see you've started looking into it; so I'd
> better show what I have at the moment, although I do hate posting
> incomplete known-buggy patches: this on top of git + your patch.
> 
> The kernel/sched/fair.c part to go to Mel and 3.8-rc1 when I've a
> moment to separate it out.

I'd better accelerate on that.

> 
> The CONFIG_NUMA section in stable_tree_append() I added late
> last night, but it's not enough to fix the issue I'm still seeing:
> merge_across_nodes 0 and 1 cases are stable, but switching between
> them can bring pages_shared down to 0 but leave something behind
> in the stable_tree.  I suspect it's a wrong-nid issue, but I've
> not yet tracked it down with the BUG_ONs I've been adding (not
> included below).

I half understand this now.  The lifetime of the stable_nodes is
different from that of the rmap_items hanging off them: a stable_node
has to stay around until the PageKsm page pointing to it has been freed;
which is why remove_rmap_item_from_tree() may bring ksm_pages_shared
down to 0, but even so does not call remove_node_from_stable_tree().

That means that merge_across_nodes_store() can find ksm_pages_shared
0 as it wishes, but there still be nodes in the stable_tree(s):
including nodes which are wrongly placed once ksm_merge_across_nodes
switches behaviour - nodes which will end up causing oopses (e.g.
because kpfn belongs to NUMAnode 1 but it's left in tree 0).

I say half understand, because to bring ksm_pages_shared down to 0,
of course I've been setting run to 2 (KSM_RUN_UNMERGE): that has
succeeded, so why has it not freed all the PageKsm pages?  I did
experiment this morning with extra code in merge_across_nodes_store()
to run get_ksm_page() on every stable_node remaining, but that was
not enough to free these nodes.

Ah, perhaps it's due to pages queued up on a pagevec, which need to
be drained: I hadn't thought of that until writing now, I'll try it
out tonight.  Or perhaps we've messed up the ordering versus fork
(I am testing under concurrent load).

Whatever it is, I think the solution to this would best be a separate
patch on top of yours: it is only a problem when changing the sense of
merge_across_nodes after running the other way, which is something few
people will often do, but something which ought not to be prohibited
(it would be lame for people to have to reboot when experimenting with
which way they want to set it), and ought not to cause oopses.

The answer is going to need a separate explanation.  I expect it will
involve a combination of something to improve the freeing rate (draining
pagevecs if that is effective), the loop to free residual stable_nodes,
and an -EBUSY for safety if those measures fail.  I'll experiment over
the coming days, and send in a patch once I'm satisfied.

I'm glad to see that akpm has now dropped your v5 patch from his mm tree;
but if you'd like to send him a v6 merging in my ksm.c mods from below
(ask if you need any explanations), go ahead - I think it's okay in
mmotm/next for a few days without the further fixup, but does need
further fixup before it reaches Linus (for 3.9 I presume).

Hugh

> 
> Removing the KSM_RUN_MERGE test: unimportant, but so far as I could
> see it should be unnecessary, and if it is necessary, then I think
> we would need to check for another state too.
> 
> Hastily back to debugging,
> Hugh
> 
> --- 3.7+git+petr/kernel/sched/fair.c	2012-12-16 16:35:08.724441527 -0800
> +++ linux/kernel/sched/fair.c	2012-12-18 21:37:24.727964195 -0800
> @@ -793,8 +793,11 @@ unsigned int sysctl_numa_balancing_scan_
>  
>  static void task_numa_placement(struct task_struct *p)
>  {
> -	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
> +	int seq;
>  
> +	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
> +		return;
> +	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
>  	if (p->numa_scan_seq == seq)
>  		return;
>  	p->numa_scan_seq = seq;
> --- 3.7+git+petr/mm/ksm.c	2012-12-18 12:15:04.972032321 -0800
> +++ linux/mm/ksm.c	2012-12-19 09:21:12.004004777 -0800
> @@ -1151,7 +1151,6 @@ struct rmap_item *unstable_tree_search_i
>  
>  	nid = get_kpfn_nid(page_to_pfn(page));
>  	root = &root_unstable_tree[nid];
> -
>  	new = &root->rb_node;
>  
>  	while (*new) {
> @@ -1174,22 +1173,16 @@ struct rmap_item *unstable_tree_search_i
>  		}
>  
>  		/*
> -		 * When there isn't same page location, don't do anything.
> -		 * If tree_page was migrated previously, it will be flushed
> -		 * out and put into right unstable tree next time. If the
> -		 * page was migrated in the meantime, it will be ignored
> -		 * this round. When both pages were migrated to the same
> -		 * node, ignore them too.
> +		 * If tree_page has been migrated to another NUMA node, it
> +		 * will be flushed out and put into the right unstable tree
> +		 * next time: only merge with it if merge_across_nodes.
>  		 * Just notice, we don't have similar problem for PageKsm
> -		 * because their migration is disabled now. (62b61f611e) */
> -
> -#ifdef CONFIG_NUMA
> -		if (page_to_nid(page) != page_to_nid(tree_page) ||
> -			tree_rmap_item->nid != page_to_nid(tree_page)) {
> +		 * because their migration is disabled now. (62b61f611e)
> +		 */
> +		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
>  			put_page(tree_page);
>  			return NULL;
>  		}
> -#endif
>  
>  		ret = memcmp_pages(page, tree_page);
>  
> @@ -1209,7 +1202,7 @@ struct rmap_item *unstable_tree_search_i
>  	rmap_item->address |= UNSTABLE_FLAG;
>  	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
>  #ifdef CONFIG_NUMA
> -	rmap_item->nid = page_to_nid(page);
> +	rmap_item->nid = nid;
>  #endif
>  	rb_link_node(&rmap_item->node, parent, new);
>  	rb_insert_color(&rmap_item->node, root);
> @@ -1226,6 +1219,13 @@ struct rmap_item *unstable_tree_search_i
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
> @@ -1852,7 +1852,7 @@ static struct stable_node *ksm_check_sta
>  	struct rb_node *node;
>  	int nid;
>  
> -	for (nid = 0; nid < MAX_NUMNODES; nid++)
> +	for (nid = 0; nid < nr_node_ids; nid++)
>  		for (node = rb_first(&root_stable_tree[nid]); node;
>  				node = rb_next(node)) {
>  			struct stable_node *stable_node;
> @@ -2030,22 +2030,15 @@ static ssize_t merge_across_nodes_store(
>  		return -EINVAL;
>  
>  	mutex_lock(&ksm_thread_mutex);
> -	if (ksm_run & KSM_RUN_MERGE) {
> -		err = -EBUSY;
> -	} else {
> -		if (ksm_merge_across_nodes != knob) {
> -			if (ksm_pages_shared > 0)
> -				err = -EBUSY;
> -			else
> -				ksm_merge_across_nodes = knob;
> -		}
> +	if (ksm_merge_across_nodes != knob) {
> +		if (ksm_pages_shared)
> +			err = -EBUSY;
> +		else
> +			ksm_merge_across_nodes = knob;
>  	}
> -
> -	if (err)
> -		count = err;
>  	mutex_unlock(&ksm_thread_mutex);
>  
> -	return count;
> +	return err ? err : count;
>  }
>  KSM_ATTR(merge_across_nodes);
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
