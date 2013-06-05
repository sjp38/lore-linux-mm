Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 31B006B0073
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:08:39 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:08:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 28/35] list_lru: per-memcg walks
Message-Id: <20130605160837.0d0a35fbd4b32d7ad02f7136@linux-foundation.org>
In-Reply-To: <1370287804-3481-29-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-29-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon,  3 Jun 2013 23:29:57 +0400 Glauber Costa <glommer@openvz.org> wrote:

> This patch extend the list_lru interfaces to allow for a memcg

"extends"

> parameter. Because most of its users won't need it, instead of
> modifying the function signatures we create a new set of _memcg()
> functions and write the old API ontop of that.

"on top"

> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> c: Hugh Dickins <hughd@google.com>

I'd rate him a d, personally.

> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ...
>
> --- a/lib/list_lru.c
> +++ b/lib/list_lru.c
> @@ -50,13 +50,16 @@ lru_node_of_index(struct list_lru *lru, int index, int nid)
>  	rcu_read_lock();
>  	rmb();
>  	/*
> -	 * The array exist, but the particular memcg does not. That is an
> -	 * impossible situation: it would mean we are trying to add to a list
> -	 * belonging to a memcg that does not exist. Either wasn't created or
> -	 * has been already freed. In both cases it should no longer have
> -	 * objects. BUG_ON to avoid a NULL dereference.
> +	 * The array exist, but the particular memcg does not. This cannot
> +	 * happen when we are called from memcg_kmem_lru_of_page with a
> +	 * definite memcg, but it can happen when we are iterating over all
> +	 * memcgs (for instance, when disposing all lists.
>  	 */
> -	BUG_ON(!lru->memcg_lrus[index]);
> +	if (!lru->memcg_lrus[index]) {
> +		rcu_read_unlock();
> +		return NULL;
> +	}

It took 28 patches, but my head is now spinning and my vision is fading
in and out.

>  	nlru = &lru->memcg_lrus[index]->node[nid];
>  	rcu_read_unlock();
>  	return nlru;
> @@ -80,6 +83,23 @@ memcg_kmem_lru_of_page(struct list_lru *lru, struct page *page)
>  	return lru_node_of_index(lru, memcg_id, nid);
>  }
>  
> +/*
> + * This helper will loop through all node-data in the LRU, either global or
> + * per-memcg.  If memcg is either not present or not used,
> + * memcg_limited_groups_array_size will be 0. _idx starts at -1, and it will
> + * still be allowed to execute once.
> + *
> + * We convention that for _idx = -1, the global node info should be used.

I don't think that "convention" is a verb, but I rather like the way
it is used here.

> + * After that, we will go through each of the memcgs, starting at 0.
> + *
> + * We don't need any kind of locking for the loop because
> + * memcg_limited_groups_array_size can only grow, gaining new fields at the
> + * end. The old ones are just copied, and any interesting manipulation happen
> + * in the node list itself, and we already lock the list.

Might be worth mentioning what type _idx should have.  Although I suspect
the code will work OK if _idx has unsigned type.

> + */
> +#define for_each_memcg_lru_index(_idx)	\
> +	for ((_idx) = -1; ((_idx) < memcg_limited_groups_array_size); (_idx)++)
> +
>  int
>  list_lru_add(
>  	struct list_lru	*lru,
> @@ -139,10 +159,19 @@ list_lru_del(
>  EXPORT_SYMBOL_GPL(list_lru_del);
>  
>  unsigned long
> -list_lru_count_node(struct list_lru *lru, int nid)
> +list_lru_count_node_memcg(struct list_lru *lru, int nid,
> +			  struct mem_cgroup *memcg)
>  {
>  	long count = 0;

But this function returns unsigned long.

> -	struct list_lru_node *nlru = &lru->node[nid];
> +	int memcg_id = -1;
> +	struct list_lru_node *nlru;
> +
> +	if (memcg && memcg_kmem_is_active(memcg))
> +		memcg_id = memcg_cache_id(memcg);
> +
> +	nlru = lru_node_of_index(lru, memcg_id, nid);
> +	if (!nlru)
> +		return 0;
>  
>  	spin_lock(&nlru->lock);
>  	BUG_ON(nlru->nr_items < 0);
> @@ -151,19 +180,28 @@ list_lru_count_node(struct list_lru *lru, int nid)
>  
>  	return count;
>  }
> -EXPORT_SYMBOL_GPL(list_lru_count_node);
> +EXPORT_SYMBOL_GPL(list_lru_count_node_memcg);
>  
>  unsigned long
> -list_lru_walk_node(
> +list_lru_walk_node_memcg(
>  	struct list_lru		*lru,
>  	int			nid,
>  	list_lru_walk_cb	isolate,
>  	void			*cb_arg,
> -	unsigned long		*nr_to_walk)
> +	unsigned long		*nr_to_walk,
> +	struct mem_cgroup	*memcg)
>  {
> -	struct list_lru_node	*nlru = &lru->node[nid];
>  	struct list_head *item, *n;
>  	unsigned long isolated = 0;
> +	struct list_lru_node *nlru;
> +	int memcg_id = -1;
> +
> +	if (memcg && memcg_kmem_is_active(memcg))
> +		memcg_id = memcg_cache_id(memcg);

Could use a helper function for this I guess.  The nice thing about
this is that it gives one a logical place at which to describe what's
going on.

> +	nlru = lru_node_of_index(lru, memcg_id, nid);
> +	if (!nlru)
> +		return 0;
>  
>  	spin_lock(&nlru->lock);
>  	list_for_each_safe(item, n, &nlru->list) {
> @@ -200,7 +238,7 @@ restart:
>  	spin_unlock(&nlru->lock);
>  	return isolated;
>  }
> -EXPORT_SYMBOL_GPL(list_lru_walk_node);
> +EXPORT_SYMBOL_GPL(list_lru_walk_node_memcg);
>  
>  static unsigned long
>  list_lru_dispose_all_node(
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
