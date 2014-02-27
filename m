Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0866B007B
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 21:50:04 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id w10so1813626pde.10
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 18:50:04 -0800 (PST)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id wm7si2866324pab.115.2014.02.26.18.50.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 18:50:04 -0800 (PST)
Received: by mail-pb0-f50.google.com with SMTP id md12so1884949pbc.9
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 18:50:03 -0800 (PST)
Date: Wed, 26 Feb 2014 18:49:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH -mm] memcg: reparent only LRUs during
 mem_cgroup_css_offline
In-Reply-To: <1392821509-976-1-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.LSU.2.11.1402261755230.975@eggly.anvils>
References: <1392821509-976-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Filipe Brandenburger <filbranden@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 19 Feb 2014, Michal Hocko wrote:

> css_offline callback exported by the cgroup core is not intended to get
> rid of all the charges but rather to get rid of cached charges for the
> soon destruction. For the memory controller we have 2 different types of
> "cached" charges which prevent from the memcg destruction (because they
> pin memcg by css reference). Swapped out pages (when swap accounting is
> enabled) and kmem charges. None of them are dealt with in the current
> code.
> 
> What we do instead is that we are reducing res counter charges (reduced
> by kmem charges) to 0. And this hard down-to-0 requirement has led to
> several issues in the past when the css_offline loops without any way
> out e.g. memcg: reparent charges of children before processing parent.
> 
> The important thing is that we actually do not have to drop all the
> charges. Instead we want to reduce LRU pages (which do not pin memcg) as
> much as possible because they are not reachable by memcg iterators after
> css_offline code returns, thus they are not reclaimable anymore.

That worries me.

> 
> This patch simply extracts LRU reparenting into mem_cgroup_reparent_lrus
> which doesn't care about charges and it is called from css_offline
> callback and the original mem_cgroup_reparent_charges stays in
> css_offline callback. The original workaround for the endless loop is no
> longer necessary because child vs. parent ordering is no longer and
> issue. The only requirement is that the parent has be still online at
> the time of css_offline.

But isn't that precisely what we just found is not guaranteed?
And in fact your patch has the necessary loop up to find the
first ancestor it can successfully css_tryget.  Maybe you meant
to say "still there" rather than "still online".

(Tangential, I don't think you rely on this any more than we do
at present, and I may be wrong to suggest any problem: but I would
feel more comfortable if kernel/cgroup.c's css_free_work_fn() did
parent = css->parent; css->ss->css_free(css); css_put(parent);
instead of putting the parent before freeing the child.)

> mem_cgroup_reparent_charges also doesn't have to exclude kmem charges
> because there shouldn't be any at the css_free stage. Let's add BUG_ON
> to make sure we haven't screwed anything.
> 
> mem_cgroup_reparent_lrus is racy but this is tolerable as the inflight
> pages which will eventually get back to the memcg's LRU shouldn't
> constitute a lot of memory.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
> This is on top of memcg-reparent-charges-of-children-before-processing-parent.patch
> and I am not suggesting to replace it (I think Filipe's patch is more
> appropriate for the stable tree).
> Nevertheless I find this approach slightly better because it makes
> semantical difference between offline and free more obvious and we can
> build on top of it later (when offlining is no longer synchronized by
> cgroup_mutex). But if you think that it is not worth touching this area
> until we find a good way to reparent swapped out and kmem pages then I
> am OK with it and stay with Filipe's patch.

I'm ambivalent about it.  I like it, and I like very much that the loop
waiting for RES_USAGE to go down to 0 is without cgroup_mutex held; but
I dislike that any pages temporarily off LRU at the time of css_offline's
list_empty check, will then go AWOL (unreachable by reclaim), until
css_free later gets around to reparenting them.

It's conceivable that some code could be added to mem_cgroup_page_lruvec()
(near my "Surreptitiously" comment), to reparent when they're put back on
LRU; but more probably not, that's already tricky, and probably bad to
make it any trickier, even if it turned out to be possible.

So I'm inclined to wait until the swap and kmem situation is sorted out
(when the delay between offline and free should become much briefer);
but would be happy if you found a good way to make the missing pages
reclaimable in the meantime.

A couple of un-comments below.

Hugh

> 
>  mm/memcontrol.c | 102 ++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 55 insertions(+), 47 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 45c2a50954ac..9f8e54333b60 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3870,6 +3870,7 @@ out:
>   * @page: the page to move
>   * @pc: page_cgroup of the page
>   * @child: page's cgroup
> + * @parent: parent where to reparent
>   *
>   * move charges to its parent or the root cgroup if the group has no
>   * parent (aka use_hierarchy==0).
> @@ -3888,9 +3889,9 @@ out:
>   */
>  static int mem_cgroup_move_parent(struct page *page,
>  				  struct page_cgroup *pc,
> -				  struct mem_cgroup *child)
> +				  struct mem_cgroup *child,
> +				  struct mem_cgroup *parent)
>  {
> -	struct mem_cgroup *parent;
>  	unsigned int nr_pages;
>  	unsigned long uninitialized_var(flags);
>  	int ret;
> @@ -3905,13 +3906,6 @@ static int mem_cgroup_move_parent(struct page *page,
>  
>  	nr_pages = hpage_nr_pages(page);
>  
> -	parent = parent_mem_cgroup(child);
> -	/*
> -	 * If no parent, move charges to root cgroup.
> -	 */
> -	if (!parent)
> -		parent = root_mem_cgroup;
> -
>  	if (nr_pages > 1) {
>  		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
>  		flags = compound_lock_irqsave(page);
> @@ -4867,6 +4861,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  /**
>   * mem_cgroup_force_empty_list - clears LRU of a group
>   * @memcg: group to clear
> + * @parent: parent group where to reparent
>   * @node: NUMA node
>   * @zid: zone id
>   * @lru: lru to to clear
> @@ -4876,6 +4871,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>   * group.
>   */
>  static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> +				struct mem_cgroup *parent,
>  				int node, int zid, enum lru_list lru)
>  {
>  	struct lruvec *lruvec;
> @@ -4909,7 +4905,7 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>  
>  		pc = lookup_page_cgroup(page);
>  
> -		if (mem_cgroup_move_parent(page, pc, memcg)) {
> +		if (mem_cgroup_move_parent(page, pc, memcg, parent)) {
>  			/* found lock contention or "pc" is obsolete. */
>  			busy = page;
>  			cond_resched();
> @@ -4918,6 +4914,28 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>  	} while (!list_empty(list));
>  }
>  
> +static void mem_cgroup_reparent_lrus(struct mem_cgroup *memcg,
> +		struct mem_cgroup *parent)
> +{
> +	int node, zid;
> +
> +	/* This is for making all *used* pages to be on LRU. */
> +	lru_add_drain_all();
> +	drain_all_stock_sync(memcg);
> +	mem_cgroup_start_move(memcg);
> +	for_each_node_state(node, N_MEMORY) {
> +		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +			enum lru_list lru;
> +			for_each_lru(lru) {
> +				mem_cgroup_force_empty_list(memcg, parent,
> +						node, zid, lru);
> +			}
> +		}
> +	}
> +	mem_cgroup_end_move(memcg);
> +	memcg_oom_recover(memcg);
> +}
> +
>  /*
>   * make mem_cgroup's charge to be 0 if there is no task by moving
>   * all the charges and pages to the parent.
> @@ -4927,42 +4945,25 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>   */
>  static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
>  {
> -	int node, zid;
> -	u64 usage;
> +	struct mem_cgroup *parent;
> +
> +	/*
> +	 * All the kmem charges have to be gone by now or we have
> +	 * a css ref leak from the kmem code.
> +	 */
> +	BUG_ON(res_counter_read_u64(&memcg->kmem, RES_USAGE));
> +
> +	parent = parent_mem_cgroup(memcg);
> +	/*
> +	 * If no parent, move charges to root cgroup.
> +	 */

I have always found that comment a distracting waste of space:
the variables are sensibly named, there is no need for more comment.
Please don't replicate it here and below!

> +	if (!parent)
> +		parent = root_mem_cgroup;
>  
>  	do {
> -		/* This is for making all *used* pages to be on LRU. */
> -		lru_add_drain_all();
> -		drain_all_stock_sync(memcg);
> -		mem_cgroup_start_move(memcg);
> -		for_each_node_state(node, N_MEMORY) {
> -			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> -				enum lru_list lru;
> -				for_each_lru(lru) {
> -					mem_cgroup_force_empty_list(memcg,
> -							node, zid, lru);
> -				}
> -			}
> -		}
> -		mem_cgroup_end_move(memcg);
> -		memcg_oom_recover(memcg);
> +		mem_cgroup_reparent_lrus(memcg, parent);
>  		cond_resched();
> -
> -		/*
> -		 * Kernel memory may not necessarily be trackable to a specific
> -		 * process. So they are not migrated, and therefore we can't
> -		 * expect their value to drop to 0 here.
> -		 * Having res filled up with kmem only is enough.
> -		 *
> -		 * This is a safety check because mem_cgroup_force_empty_list
> -		 * could have raced with mem_cgroup_replace_page_cache callers
> -		 * so the lru seemed empty but the page could have been added
> -		 * right after the check. RES_USAGE should be safe as we always
> -		 * charge before adding to the LRU.
> -		 */
> -		usage = res_counter_read_u64(&memcg->res, RES_USAGE) -
> -			res_counter_read_u64(&memcg->kmem, RES_USAGE);
> -	} while (usage > 0);
> +	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0);
>  }
>  
>  static inline bool memcg_has_children(struct mem_cgroup *memcg)
> @@ -6595,8 +6596,8 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
>  static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	struct mem_cgroup *parent = memcg;
>  	struct mem_cgroup_event *event, *tmp;
> -	struct cgroup_subsys_state *iter;
>  
>  	/*
>  	 * Unregister events and notify userspace.
> @@ -6613,13 +6614,20 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  	kmem_cgroup_css_offline(memcg);
>  
>  	mem_cgroup_invalidate_reclaim_iterators(memcg);
> -
>  	/*
>  	 * This requires that offlining is serialized.  Right now that is
>  	 * guaranteed because css_killed_work_fn() holds the cgroup_mutex.
>  	 */

And that comment belongs to the code you're removing, doesn't it?
So should be removed along with it.

> -	css_for_each_descendant_post(iter, css)
> -		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
> +	do {
> +		parent = parent_mem_cgroup(parent);
> +		/*
> +		 * If no parent, move charges to root cgroup.
> +		 */
> +		if (!parent)
> +			parent = root_mem_cgroup;
> +	} while (!css_tryget(&parent->css));
> +	mem_cgroup_reparent_lrus(memcg, parent);
> +	css_put(&parent->css);
>  
>  	mem_cgroup_destroy_all_caches(memcg);
>  	vmpressure_cleanup(&memcg->vmpressure);
> -- 
> 1.9.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
