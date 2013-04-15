Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id BBD226B0006
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 01:37:53 -0400 (EDT)
Received: by mail-ve0-f202.google.com with SMTP id 14so1422vea.1
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 22:37:52 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 11/32] list_lru: per-node list infrastructure
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
	<1365429659-22108-12-git-send-email-glommer@parallels.com>
Date: Sun, 14 Apr 2013 22:37:51 -0700
Message-ID: <xr93k3o48ic0.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>

On Mon, Apr 08 2013, Glauber Costa wrote:

> From: Dave Chinner <dchinner@redhat.com>
>
> Now that we have an LRU list API, we can start to enhance the
> implementation.  This splits the single LRU list into per-node lists
> and locks to enhance scalability. Items are placed on lists
> according to the node the memory belongs to. To make scanning the
> lists efficient, also track whether the per-node lists have entries
> in them in a active nodemask.
>
> [ glommer: fixed warnings ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Reviewed-by: Greg Thelen <gthelen@google.com>

(one comment below regarding a potentially unnecessary spinlock)

> ---
>  include/linux/list_lru.h |  14 ++--
>  lib/list_lru.c           | 162 +++++++++++++++++++++++++++++++++++------------
>  2 files changed, 130 insertions(+), 46 deletions(-)
>
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index 394c28c..9073f97 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -8,6 +8,7 @@
>  #define _LRU_LIST_H
>  
>  #include <linux/list.h>
> +#include <linux/nodemask.h>
>  
>  enum lru_status {
>  	LRU_REMOVED,		/* item removed from list */
> @@ -16,20 +17,21 @@ enum lru_status {
>  	LRU_RETRY,		/* item not freeable, lock dropped */
>  };
>  
> -struct list_lru {
> +struct list_lru_node {
>  	spinlock_t		lock;
>  	struct list_head	list;
>  	long			nr_items;
> +} ____cacheline_aligned_in_smp;
> +
> +struct list_lru {
> +	struct list_lru_node	node[MAX_NUMNODES];
> +	nodemask_t		active_nodes;
>  };
>  
>  int list_lru_init(struct list_lru *lru);
>  int list_lru_add(struct list_lru *lru, struct list_head *item);
>  int list_lru_del(struct list_lru *lru, struct list_head *item);
> -
> -static inline long list_lru_count(struct list_lru *lru)
> -{
> -	return lru->nr_items;
> -}
> +long list_lru_count(struct list_lru *lru);
>  
>  typedef enum lru_status
>  (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
> diff --git a/lib/list_lru.c b/lib/list_lru.c
> index 03bd984..0119af8 100644
> --- a/lib/list_lru.c
> +++ b/lib/list_lru.c
> @@ -6,6 +6,7 @@
>   */
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> +#include <linux/mm.h>
>  #include <linux/list_lru.h>
>  
>  int
> @@ -13,14 +14,19 @@ list_lru_add(
>  	struct list_lru	*lru,
>  	struct list_head *item)
>  {
> -	spin_lock(&lru->lock);
> +	int nid = page_to_nid(virt_to_page(item));
> +	struct list_lru_node *nlru = &lru->node[nid];
> +
> +	spin_lock(&nlru->lock);
> +	BUG_ON(nlru->nr_items < 0);
>  	if (list_empty(item)) {
> -		list_add_tail(item, &lru->list);
> -		lru->nr_items++;
> -		spin_unlock(&lru->lock);
> +		list_add_tail(item, &nlru->list);
> +		if (nlru->nr_items++ == 0)
> +			node_set(nid, lru->active_nodes);
> +		spin_unlock(&nlru->lock);
>  		return 1;
>  	}
> -	spin_unlock(&lru->lock);
> +	spin_unlock(&nlru->lock);
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(list_lru_add);
> @@ -30,43 +36,72 @@ list_lru_del(
>  	struct list_lru	*lru,
>  	struct list_head *item)
>  {
> -	spin_lock(&lru->lock);
> +	int nid = page_to_nid(virt_to_page(item));
> +	struct list_lru_node *nlru = &lru->node[nid];
> +
> +	spin_lock(&nlru->lock);
>  	if (!list_empty(item)) {
>  		list_del_init(item);
> -		lru->nr_items--;
> -		spin_unlock(&lru->lock);
> +		if (--nlru->nr_items == 0)
> +			node_clear(nid, lru->active_nodes);
> +		BUG_ON(nlru->nr_items < 0);
> +		spin_unlock(&nlru->lock);
>  		return 1;
>  	}
> -	spin_unlock(&lru->lock);
> +	spin_unlock(&nlru->lock);
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(list_lru_del);
>  
>  long
> -list_lru_walk(
> -	struct list_lru *lru,
> -	list_lru_walk_cb isolate,
> -	void		*cb_arg,
> -	long		nr_to_walk)
> +list_lru_count(
> +	struct list_lru *lru)
>  {
> +	long count = 0;
> +	int nid;
> +
> +	for_each_node_mask(nid, lru->active_nodes) {
> +		struct list_lru_node *nlru = &lru->node[nid];
> +
> +		spin_lock(&nlru->lock);

I'm not sure if the spin_lock() is really needed here.  It wasn't
grabbed before this patch.

> +		BUG_ON(nlru->nr_items < 0);
> +		count += nlru->nr_items;
> +		spin_unlock(&nlru->lock);
> +	}
> +
> +	return count;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_count);
> +
> +static long
> +list_lru_walk_node(
> +	struct list_lru		*lru,
> +	int			nid,
> +	list_lru_walk_cb	isolate,
> +	void			*cb_arg,
> +	long			*nr_to_walk)
> +{
> +	struct list_lru_node	*nlru = &lru->node[nid];
>  	struct list_head *item, *n;
> -	long removed = 0;
> +	long isolated = 0;
>  restart:
> -	spin_lock(&lru->lock);
> -	list_for_each_safe(item, n, &lru->list) {
> +	spin_lock(&nlru->lock);
> +	list_for_each_safe(item, n, &nlru->list) {
>  		int ret;
>  
> -		if (nr_to_walk-- < 0)
> +		if ((*nr_to_walk)-- < 0)
>  			break;
>  
> -		ret = isolate(item, &lru->lock, cb_arg);
> +		ret = isolate(item, &nlru->lock, cb_arg);
>  		switch (ret) {
>  		case LRU_REMOVED:
> -			lru->nr_items--;
> -			removed++;
> +			if (--nlru->nr_items == 0)
> +				node_clear(nid, lru->active_nodes);
> +			BUG_ON(nlru->nr_items < 0);
> +			isolated++;
>  			break;
>  		case LRU_ROTATE:
> -			list_move_tail(item, &lru->list);
> +			list_move_tail(item, &nlru->list);
>  			break;
>  		case LRU_SKIP:
>  			break;
> @@ -76,42 +111,89 @@ restart:
>  			BUG();
>  		}
>  	}
> -	spin_unlock(&lru->lock);
> -	return removed;
> +	spin_unlock(&nlru->lock);
> +	return isolated;
>  }
> -EXPORT_SYMBOL_GPL(list_lru_walk);
>  
>  long
> -list_lru_dispose_all(
> -	struct list_lru *lru,
> -	list_lru_dispose_cb dispose)
> +list_lru_walk(
> +	struct list_lru	*lru,
> +	list_lru_walk_cb isolate,
> +	void		*cb_arg,
> +	long		nr_to_walk)
>  {
> -	long disposed = 0;
> +	long isolated = 0;
> +	int nid;
> +
> +	for_each_node_mask(nid, lru->active_nodes) {
> +		isolated += list_lru_walk_node(lru, nid, isolate,
> +					       cb_arg, &nr_to_walk);
> +		if (nr_to_walk <= 0)
> +			break;
> +	}
> +	return isolated;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_walk);
> +
> +static long
> +list_lru_dispose_all_node(
> +	struct list_lru		*lru,
> +	int			nid,
> +	list_lru_dispose_cb	dispose)
> +{
> +	struct list_lru_node	*nlru = &lru->node[nid];
>  	LIST_HEAD(dispose_list);
> +	long disposed = 0;
>  
> -	spin_lock(&lru->lock);
> -	while (!list_empty(&lru->list)) {
> -		list_splice_init(&lru->list, &dispose_list);
> -		disposed += lru->nr_items;
> -		lru->nr_items = 0;
> -		spin_unlock(&lru->lock);
> +	spin_lock(&nlru->lock);
> +	while (!list_empty(&nlru->list)) {
> +		list_splice_init(&nlru->list, &dispose_list);
> +		disposed += nlru->nr_items;
> +		nlru->nr_items = 0;
> +		node_clear(nid, lru->active_nodes);
> +		spin_unlock(&nlru->lock);
>  
>  		dispose(&dispose_list);
>  
> -		spin_lock(&lru->lock);
> +		spin_lock(&nlru->lock);
>  	}
> -	spin_unlock(&lru->lock);
> +	spin_unlock(&nlru->lock);
>  	return disposed;
>  }
>  
> +long
> +list_lru_dispose_all(
> +	struct list_lru		*lru,
> +	list_lru_dispose_cb	dispose)
> +{
> +	long disposed;
> +	long total = 0;
> +	int nid;
> +
> +	do {
> +		disposed = 0;
> +		for_each_node_mask(nid, lru->active_nodes) {
> +			disposed += list_lru_dispose_all_node(lru, nid,
> +							      dispose);
> +		}
> +		total += disposed;
> +	} while (disposed != 0);
> +
> +	return total;
> +}
> +
>  int
>  list_lru_init(
>  	struct list_lru	*lru)
>  {
> -	spin_lock_init(&lru->lock);
> -	INIT_LIST_HEAD(&lru->list);
> -	lru->nr_items = 0;
> +	int i;
>  
> +	nodes_clear(lru->active_nodes);
> +	for (i = 0; i < MAX_NUMNODES; i++) {
> +		spin_lock_init(&lru->node[i].lock);
> +		INIT_LIST_HEAD(&lru->node[i].list);
> +		lru->node[i].nr_items = 0;
> +	}
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(list_lru_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
