Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 617F76B0072
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:08:35 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:08:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 27/35] lru: add an element to a memcg list
Message-Id: <20130605160832.93f3f62e42321d920b2adb31@linux-foundation.org>
In-Reply-To: <1370287804-3481-28-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-28-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon,  3 Jun 2013 23:29:56 +0400 Glauber Costa <glommer@openvz.org> wrote:

> With the infrastructure we now have, we can add an element to a memcg
> LRU list instead of the global list. The memcg lists are still
> per-node.
> 
> Technically, we will never trigger per-node shrinking in the memcg is

"if the memcg".

> short of memory.

hm, why?  If the memcg is short on memory, we *want* to trigger pernode
shrinking?  Is this sentence describing a design feature or is it
describing a shortcoming which is about to be overcome?

> Therefore an alternative to this would be to add the
> element to *both* a single-node memcg array and a per-node global array.

The latter, I think.

> There are two main reasons for this design choice:
> 
> 1) adding an extra list_head to each of the objects would waste 16-bytes
> per object, always remembering that we are talking about 1 dentry + 1
> inode in the common case. This means a close to 10 % increase in the
> dentry size, and a lower yet significant increase in the inode size. In
> terms of total memory, this design pays 32-byte per-superblock-per-node
> (size of struct list_lru_node), which means that in any scenario where
> we have more than 10 dentries + inodes, we would already be paying more
> memory in the two-list-heads approach than we will here with 1 node x 10
> superblocks. The turning point of course depends on the workload, but I
> hope the figures above would convince you that the memory footprint is
> in my side in any workload that matters.

yup.  Assume the number of dentries and inodes is huge.

> 2) The main drawback of this, namely, that we loose global LRU order, is

"lose"

> not really seen by me as a disadvantage: if we are using memcg to
> isolate the workloads, global pressure should try to balance the amount
> reclaimed from all memcgs the same way the shrinkers will already
> naturally balance the amount reclaimed from each superblock. (This
> patchset needs some love in this regard, btw).
> 
> To help us easily tracking down which nodes have and which nodes doesn't

"track"

"don't"

> have elements in the list, we will count on an auxiliary node bitmap in

"use an auxiliary node bitmap at"

> the global level.
> 
> ...
>
> @@ -53,12 +53,23 @@ struct list_lru {
>  	 * structure, we may very well fail.
>  	 */
>  	struct list_lru_node	node[MAX_NUMNODES];
> +	atomic_long_t		node_totals[MAX_NUMNODES];
>  	nodemask_t		active_nodes;
>  #ifdef CONFIG_MEMCG_KMEM
>  	/* All memcg-aware LRUs will be chained in the lrus list */
>  	struct list_head	lrus;
>  	/* M x N matrix as described above */
>  	struct list_lru_array	**memcg_lrus;
> +	/*
> +	 * The memcg_lrus is RCU protected

It is?  I don't recall seeing that in the earlier patches.  Is some
description missing?

>	  , so we need to keep the previous
> +	 * array around when we update it. But we can only do that after
> +	 * synchronize_rcu(). A typical system has many LRUs, which means
> +	 * that if we call synchronize_rcu after each LRU update, this
> +	 * will become very expensive. We add this pointer here, and then
> +	 * after all LRUs are update, we call synchronize_rcu() once, and

"updated"

> +	 * free all the old_arrays.
> +	 */
> +	void *old_array;
>  #endif
>  };
>  
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 3442eb9..50f199f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -24,6 +24,7 @@
>  #include <linux/hardirq.h>
>  #include <linux/jump_label.h>
>  #include <linux/list_lru.h>
> +#include <linux/mm.h>

erk.  There's a good chance that mm.h already includes memcontrol.h, or
vice versa, by some circuitous path.  Expect problems from this.

afaict the include is only needed for struct page?  If so, simply
adding a forward declaration for that would be prudent.

>  struct mem_cgroup;
>  struct page_cgroup;
> 
> ...
>
> +static struct list_lru_node *
> +lru_node_of_index(struct list_lru *lru, int index, int nid)
> +{
> +#ifdef CONFIG_MEMCG_KMEM
> +	struct list_lru_node *nlru;
> +
> +	if (index < 0)
> +		return &lru->node[nid];
> +
> +	/*
> +	 * If we reach here with index >= 0, it means the page where the object
> +	 * comes from is associated with a memcg. Because memcg_lrus is
> +	 * populated before the caches, we can be sure that this request is
> +	 * truly for a LRU list that does not have memcg caches.

"an LRU" :)

> +	 */
> +	if (!lru->memcg_lrus)
> +		return &lru->node[nid];
> +
> +	/*
> +	 * Because we will only ever free the memcg_lrus after synchronize_rcu,
> +	 * we are safe with the rcu lock here: even if we are operating in the
> +	 * stale version of the array, the data is still valid and we are not
> +	 * risking anything.
> +	 *
> +	 * The read barrier is needed to make sure that we see the pointer
> +	 * assigment for the specific memcg
> +	 */
> +	rcu_read_lock();
> +	rmb();
> +	/*
> +	 * The array exist, but the particular memcg does not. That is an

"exists"

> +	 * impossible situation: it would mean we are trying to add to a list
> +	 * belonging to a memcg that does not exist. Either wasn't created or

"it wasn't created or it"

> +	 * has been already freed. In both cases it should no longer have
> +	 * objects. BUG_ON to avoid a NULL dereference.

Well.  We could jsut permit the NULL reference - that provides the same
info.  But an explicit BUG_ON does show that it has been thought through!

> +	 */
> +	BUG_ON(!lru->memcg_lrus[index]);
> +	nlru = &lru->memcg_lrus[index]->node[nid];
> +	rcu_read_unlock();
> +	return nlru;
> +#else
> +	BUG_ON(index >= 0); /* nobody should be passing index < 0 with !KMEM */
> +	return &lru->node[nid];
> +#endif
> +}
> +
> 
> ...
>
>  int
>  list_lru_add(
>  	struct list_lru	*lru,
>  	struct list_head *item)
>  {
> -	int nid = page_to_nid(virt_to_page(item));
> -	struct list_lru_node *nlru = &lru->node[nid];
> +	struct page *page = virt_to_page(item);
> +	struct list_lru_node *nlru;
> +	int nid = page_to_nid(page);
> +
> +	nlru = memcg_kmem_lru_of_page(lru, page);
>  
>  	spin_lock(&nlru->lock);
>  	BUG_ON(nlru->nr_items < 0);
>  	if (list_empty(item)) {
>  		list_add_tail(item, &nlru->list);
> -		if (nlru->nr_items++ == 0)
> +		nlru->nr_items++;
> +		/*
> +		 * We only consider a node active or inactive based on the
> +		 * total figure for all involved children.

Is "children" an appropriate term in this context?  Where would one go
to understand the overall object hierarchy here?

> +		 */
> +		if (atomic_long_add_return(1, &lru->node_totals[nid]) == 1)
>  			node_set(nid, lru->active_nodes);
>  		spin_unlock(&nlru->lock);
>  		return 1;
> 
> ...
>
> +	/*
> +	 * Even if we were to use call_rcu, we still have to keep the old array
> +	 * pointer somewhere. It is easier for us to just synchronize rcu here
> +	 * since we are in a fine context. Now we guarantee that there are no
> +	 * more users of old_array, and proceed freeing it for all LRUs

"a fine context" is a fine term, but it's unclear what is meant by it ;)

> +	 */
> +	synchronize_rcu();
> +	list_for_each_entry(lru, &all_memcg_lrus, lrus) {
> +		kfree(lru->old_array);
> +		lru->old_array = NULL;
> +	}
>  	mutex_unlock(&all_memcg_lrus_mutex);
>  	return ret;
>  }
> 
> ...
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3162,19 +3162,22 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>  	 */
>  	memcg_kmem_set_activated(memcg);
>  
> -	ret = memcg_update_all_caches(num+1);
> -	if (ret)
> -		goto out;
> -
>  	/*
> -	 * We should make sure that the array size is not updated until we are
> -	 * done; otherwise we have no easy way to know whether or not we should
> -	 * grow the array.
> +	 * We have to make absolutely sure that we update the LRUs before we
> +	 * update the caches. Once the caches are updated, they will be able to
> +	 * start hosting objects. If a cache is created very quickly, and and

s/and/an/

> +	 * element is used and disposed to the LRU quickly as well, we may end
> +	 * up with a NULL pointer in list_lru_add because the lists are not yet
> +	 * ready.
>  	 */
>  	ret = memcg_update_all_lrus(num + 1);
>  	if (ret)
>  		goto out;
>  
> +	ret = memcg_update_all_caches(num+1);
> +	if (ret)
> +		goto out;
> +
>  	memcg->kmemcg_id = num;
>  
>  	memcg_update_array_size(num + 1);
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
