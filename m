Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 038A46B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 01:35:31 -0400 (EDT)
Received: by mail-qa0-f73.google.com with SMTP id p6so46028qad.4
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 22:35:30 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 08/32] list: add a new LRU list type
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
	<1365429659-22108-9-git-send-email-glommer@parallels.com>
Date: Sun, 14 Apr 2013 22:35:29 -0700
Message-ID: <xr93r4ic8ify.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>

On Mon, Apr 08 2013, Glauber Costa wrote:

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
> [ glommer: enum defined constants for lru. Suggested by gthelen ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Optional nit pick below:

Reviewed-by: Greg Thelen <gthelen@google.com>


> ---
>  include/linux/list_lru.h |  44 ++++++++++++++++++
>  lib/Makefile             |   2 +-
>  lib/list_lru.c           | 117 +++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 162 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/list_lru.h
>  create mode 100644 lib/list_lru.c
>
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> new file mode 100644
> index 0000000..394c28c
> --- /dev/null
> +++ b/include/linux/list_lru.h
> @@ -0,0 +1,44 @@
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
> +	LRU_RETRY,		/* item not freeable, lock dropped */
> +};
> +
> +struct list_lru {
> +	spinlock_t		lock;
> +	struct list_head	list;
> +	long			nr_items;
> +};
> +
> +int list_lru_init(struct list_lru *lru);
> +int list_lru_add(struct list_lru *lru, struct list_head *item);
> +int list_lru_del(struct list_lru *lru, struct list_head *item);
> +
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
> +long list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
> +
> +#endif /* _LRU_LIST_H */
> diff --git a/lib/Makefile b/lib/Makefile
> index d7946ff..f14abd9 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -13,7 +13,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
>  	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
>  	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
>  	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
> -	 earlycpio.o
> +	 earlycpio.o list_lru.o
>  
>  lib-$(CONFIG_MMU) += ioremap.o
>  lib-$(CONFIG_SMP) += cpumask.o
> diff --git a/lib/list_lru.c b/lib/list_lru.c
> new file mode 100644
> index 0000000..03bd984
> --- /dev/null
> +++ b/lib/list_lru.c
> @@ -0,0 +1,117 @@
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
> +	struct list_lru *lru,
> +	list_lru_walk_cb isolate,
> +	void		*cb_arg,
> +	long		nr_to_walk)
> +{
> +	struct list_head *item, *n;
> +	long removed = 0;
> +restart:
> +	spin_lock(&lru->lock);
> +	list_for_each_safe(item, n, &lru->list) {
> +		int ret;

enum lru_status ret;

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
> +		default:
> +			BUG();
> +		}
> +	}
> +	spin_unlock(&lru->lock);
> +	return removed;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_walk);

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
