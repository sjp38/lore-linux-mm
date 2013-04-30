Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id F29106B00EB
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 11:18:58 -0400 (EDT)
Date: Tue, 30 Apr 2013 16:18:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 08/31] list: add a new LRU list type
Message-ID: <20130430151854.GH6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-9-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-9-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Sat, Apr 27, 2013 at 03:19:04AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Several subsystems use the same construct for LRU lists - a list
> head, a spin lock and and item count. They also use exactly the same
> code for adding and removing items from the LRU. Create a generic
> type for these LRU lists.
> 
> This is the beginning of generic, node aware LRUs for shrinkers to
> work with.
> 
> [ glommer: enum defined constants for lru. Suggested by gthelen,
>   don't relock over retry ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Reviewed-by: Greg Thelen <gthelen@google.com>
> ---
>  include/linux/list_lru.h |  45 ++++++++++++++++++
>  lib/Makefile             |   2 +-
>  lib/list_lru.c           | 118 +++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 164 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/list_lru.h
>  create mode 100644 lib/list_lru.c
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> new file mode 100644
> index 0000000..c0b796d
> --- /dev/null
> +++ b/include/linux/list_lru.h
> @@ -0,0 +1,45 @@
> +/*
> + * Copyright (c) 2010-2012 Red Hat, Inc. All rights reserved.
> + * Author: David Chinner
> + *
> + * Generic LRU infrastructure
> + */
> +#ifndef _LRU_LIST_H
> +#define _LRU_LIST_H
> +
> +#include <linux/list.h>
> +
> +enum lru_status {
> +	LRU_REMOVED,		/* item removed from list */
> +	LRU_ROTATE,		/* item referenced, give another pass */
> +	LRU_SKIP,		/* item cannot be locked, skip */
> +	LRU_RETRY,		/* item not freeable. May drop the lock
> +				   internally, but has to return locked. */
> +};
> +
> +struct list_lru {
> +	spinlock_t		lock;
> +	struct list_head	list;
> +	long			nr_items;
> +};

Is there ever a circumstance where nr_items is negative? If so, what
does that mean?

> +
> +int list_lru_init(struct list_lru *lru);

I was going to complain that this always returns 0 and should be void
but that changes later.

> +int list_lru_add(struct list_lru *lru, struct list_head *item);
> +int list_lru_del(struct list_lru *lru, struct list_head *item);
> +

However, these are bool and the return value determines if the item was
really added to the list or not. It fails if the item is already part of
a list and it would be very nice to have a comment explaining why it's
not a bug if this happens because it feels like it would be a lookup and
insertion race. Maybe it's clear later in the series why this is ok but
it's not very obvious at this point.

> +static inline long list_lru_count(struct list_lru *lru)
> +{
> +	return lru->nr_items;
> +}
> +
> +typedef enum lru_status
> +(*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
> +
> +typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
> +
> +long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
> +		   void *cb_arg, long nr_to_walk);
> +

Is nr_to_walk ever negative?

> +long list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
> +
> +#endif /* _LRU_LIST_H */
> diff --git a/lib/Makefile b/lib/Makefile
> index af79e8c..40a6d4a 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -13,7 +13,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
>  	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
>  	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
>  	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
> -	 earlycpio.o percpu-refcount.o
> +	 earlycpio.o percpu-refcount.o list_lru.o
>  
>  obj-$(CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS) += usercopy.o
>  lib-$(CONFIG_MMU) += ioremap.o
> diff --git a/lib/list_lru.c b/lib/list_lru.c
> new file mode 100644
> index 0000000..937ee87
> --- /dev/null
> +++ b/lib/list_lru.c
> @@ -0,0 +1,118 @@
> +/*
> + * Copyright (c) 2010-2012 Red Hat, Inc. All rights reserved.
> + * Author: David Chinner
> + *
> + * Generic LRU infrastructure
> + */
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/list_lru.h>
> +
> +int
> +list_lru_add(
> +	struct list_lru	*lru,
> +	struct list_head *item)
> +{
> +	spin_lock(&lru->lock);
> +	if (list_empty(item)) {
> +		list_add_tail(item, &lru->list);
> +		lru->nr_items++;
> +		spin_unlock(&lru->lock);
> +		return 1;
> +	}
> +	spin_unlock(&lru->lock);
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_add);
> +
> +int
> +list_lru_del(
> +	struct list_lru	*lru,
> +	struct list_head *item)
> +{
> +	spin_lock(&lru->lock);
> +	if (!list_empty(item)) {
> +		list_del_init(item);
> +		lru->nr_items--;
> +		spin_unlock(&lru->lock);
> +		return 1;
> +	}
> +	spin_unlock(&lru->lock);
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_del);
> +
> +long
> +list_lru_walk(

It returns long but never actually returns a negative number.

> +	struct list_lru *lru,
> +	list_lru_walk_cb isolate,
> +	void		*cb_arg,
> +	long		nr_to_walk)
> +{
> +	struct list_head *item, *n;
> +	long removed = 0;
> +
> +	spin_lock(&lru->lock);
> +restart:
> +	list_for_each_safe(item, n, &lru->list) {
> +		enum lru_status ret;
> +
> +		if (nr_to_walk-- < 0)
> +			break;
> +
> +		ret = isolate(item, &lru->lock, cb_arg);
> +		switch (ret) {
> +		case LRU_REMOVED:
> +			lru->nr_items--;
> +			removed++;
> +			break;
> +		case LRU_ROTATE:
> +			list_move_tail(item, &lru->list);
> +			break;
> +		case LRU_SKIP:
> +			break;
> +		case LRU_RETRY:
> +			goto restart;

Are the two users of LRU_RETRY guaranteed to eventually make progress
or can this infinite loop? It feels like the behaviour of LRU_RETRY is
not very desirable. Once an object that returns LRU_RETRY is isolated on
the list then it looks like XFS can stall for 100 ticks (bit arbitrary)
each time it tries and maybe do this forever.

The inode.c user looks like it could race where some other process is
reallocating the buffers between each time this isolate callback tries to
isolate it. Granted, it may accidentally break out because the spinlock
is contended and it returns LRU_SKIP so maybe no one will hit the problem
but if it's ok with LRU_SKIP then maybe a LRU_RETRY_ONCE would also be
suitable and use that in fs/inode.c?

Either hypothetical situation would require that the list you are trying
to walk is very small but maybe memcg will hit that problem. If there is
a guarantee of forward progress then a comment would be nice.

> +		default:
> +			BUG();
> +		}
> +	}
> +	spin_unlock(&lru->lock);
> +	return removed;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_walk);
> +
> +long
> +list_lru_dispose_all(
> +	struct list_lru *lru,
> +	list_lru_dispose_cb dispose)
> +{
> +	long disposed = 0;
> +	LIST_HEAD(dispose_list);
> +
> +	spin_lock(&lru->lock);
> +	while (!list_empty(&lru->list)) {
> +		list_splice_init(&lru->list, &dispose_list);
> +		disposed += lru->nr_items;
> +		lru->nr_items = 0;
> +		spin_unlock(&lru->lock);
> +
> +		dispose(&dispose_list);
> +
> +		spin_lock(&lru->lock);
> +	}
> +	spin_unlock(&lru->lock);
> +	return disposed;
> +}
> +
> +int
> +list_lru_init(
> +	struct list_lru	*lru)
> +{
> +	spin_lock_init(&lru->lock);
> +	INIT_LIST_HEAD(&lru->list);
> +	lru->nr_items = 0;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_init);

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
