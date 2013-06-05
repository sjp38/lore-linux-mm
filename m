Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 0DFAF6B003C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:08:06 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:08:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 11/35] list_lru: per-node list infrastructure
Message-Id: <20130605160804.be25fb655f075efe70ec57c0@linux-foundation.org>
In-Reply-To: <1370287804-3481-12-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-12-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Mon,  3 Jun 2013 23:29:40 +0400 Glauber Costa <glommer@openvz.org> wrote:

> From: Dave Chinner <dchinner@redhat.com>
> 
> Now that we have an LRU list API, we can start to enhance the
> implementation.  This splits the single LRU list into per-node lists
> and locks to enhance scalability.

Do we have any runtime measurements?  They're pretty important for
justifying inclusion of the code.

Measurememnts for non-NUMA and uniprocessor kernels would be useful in
making that decision as well.

In fact a lot of the patchset is likely to be injurious to small
machines.  We should quantify this and then persade ourselves that the
large-machine gains are worth the small-machine losses.

> Items are placed on lists
> according to the node the memory belongs to. To make scanning the
> lists efficient, also track whether the per-node lists have entries
> in them in a active nodemask.
> 
> Note:
> We use a fixed-size array for the node LRU, this struct can be very big
> if MAX_NUMNODES is big. If this becomes a problem this is fixable by
> turning this into a pointer and dynamically allocating this to
> nr_node_ids. This quantity is firwmare-provided, and still would provide
> room for all nodes at the cost of a pointer lookup and an extra
> allocation. Because that allocation will most likely come from a
> different slab cache than the main structure holding this structure, we
> may very well fail.

Surprised.  How big is MAX_NUMNODES likely to get?

lib/flex_array.c might be of use here.

>
> ...
>
> -struct list_lru {
> +struct list_lru_node {
>  	spinlock_t		lock;
>  	struct list_head	list;
>  	long			nr_items;
> +} ____cacheline_aligned_in_smp;
> +
> +struct list_lru {
> +	/*
> +	 * Because we use a fixed-size array, this struct can be very big if
> +	 * MAX_NUMNODES is big. If this becomes a problem this is fixable by
> +	 * turning this into a pointer and dynamically allocating this to
> +	 * nr_node_ids. This quantity is firwmare-provided, and still would
> +	 * provide room for all nodes at the cost of a pointer lookup and an
> +	 * extra allocation. Because that allocation will most likely come from
> +	 * a different slab cache than the main structure holding this
> +	 * structure, we may very well fail.
> +	 */
> +	struct list_lru_node	node[MAX_NUMNODES];
> +	nodemask_t		active_nodes;

Some documentation of the data structure would be helpful.  It appears
that active_nodes tracks (ie: duplicates) node[x].nr_items!=0.

It's unclear that active_nodes is really needed - we could just iterate
across all items in list_lru.node[].  Are we sure that the correct
tradeoff decision was made here?

What's the story on NUMA node hotplug, btw?

>  };
>  
>
> ...
>
>  unsigned long
> -list_lru_walk(
> -	struct list_lru *lru,
> -	list_lru_walk_cb isolate,
> -	void		*cb_arg,
> -	unsigned long	nr_to_walk)
> +list_lru_count(struct list_lru *lru)
>  {
> +	long count = 0;
> +	int nid;
> +
> +	for_each_node_mask(nid, lru->active_nodes) {
> +		struct list_lru_node *nlru = &lru->node[nid];
> +
> +		spin_lock(&nlru->lock);
> +		BUG_ON(nlru->nr_items < 0);

This is buggy.

The bit in lru->active_nodes could be cleared by now.  We can only make
this assertion if we recheck lru->active_nodes[nid] inside the
spinlocked region.

> +		count += nlru->nr_items;
> +		spin_unlock(&nlru->lock);
> +	}
> +
> +	return count;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_count);

list_lru_count()'s return value is of course approximate.  If callers
require that the returned value be exact, they will need to provide
their own locking on top of list_lru's internal locking (which would
then become redundant).

This is the sort of thing which should be discussed in the interface
documentation.

list_lru_count() can be very expensive.

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
