Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id CACB36B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:08:00 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:07:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 08/35] list: add a new LRU list type
Message-Id: <20130605160758.19e854a6995e3c2a1f5260bf@linux-foundation.org>
In-Reply-To: <1370287804-3481-9-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-9-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Mon,  3 Jun 2013 23:29:37 +0400 Glauber Costa <glommer@openvz.org> wrote:

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
> ...
>
> --- /dev/null
> +++ b/include/linux/list_lru.h
> @@ -0,0 +1,46 @@
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

What's this?

Seems to be the return code from the undocumented list_lru_walk_cb?

> +struct list_lru {
> +	spinlock_t		lock;
> +	struct list_head	list;
> +	long			nr_items;

Should be an unsigned type.

> +};
> +
> +int list_lru_init(struct list_lru *lru);
> +int list_lru_add(struct list_lru *lru, struct list_head *item);
> +int list_lru_del(struct list_lru *lru, struct list_head *item);
> +
> +static inline unsigned long list_lru_count(struct list_lru *lru)
> +{
> +	return lru->nr_items;
> +}

It got changed to unsigned here!

> +typedef enum lru_status
> +(*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
> +
> +typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
> +
> +unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
> +		   void *cb_arg, unsigned long nr_to_walk);
> +
> +unsigned long
> +list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
> +
> +#endif /* _LRU_LIST_H */
> diff --git a/lib/Makefile b/lib/Makefile
> index af911db..d610fda 100644
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
> index 0000000..3127edd
> --- /dev/null
> +++ b/lib/list_lru.c
> @@ -0,0 +1,122 @@
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

This is lib/, not fs/xfs/ ;)

> +{
> +	spin_lock(&lru->lock);

OK, problems.  Long experience has shown us that in-kernel container
library code like this should not perform its own locking.  Things like:

- I want to call it from interrupts!

- I want to use a mutex!

- I want to use RCU!

- I already hold a lock and don't need this code to take another one!

- I need to sleep in my isolate callback, but the library code is
  holding a spinlock!

- I want to test lru.nr_items in a non-racy fashion, but to do that I
  have to take a lib/-private spinlock!

etcetera.  It's just heaps less flexible and useful this way, and
library code should be flexible and useful.

If you want to put a spinlocked layer on top of the core code then fine
- that looks to be simple enough, apart from list_lru_dispose_all().

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

So an undocumented, i-have-to-guess-why feature of list_lru_add() is
that it will refuse to add an item which appears to be on a list
already?

This is a little bit strange, because one could legitimately do

	list_del(item);		/* from my private list */
	list_lru_add(lru, item);

but this interface forced me to do a needless lru_del_init().

Maybe this is good, maybe it is bad.  It depends on what the author(s)
were thinking at the time ;)


Either way, returning 1 on success and 0 on failure is surprising.  0
means success, please.  Alternatively I guess one could make it return
bool and document the dang thing, hence retaining the current 0/1 concept.

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
> +unsigned long
> +list_lru_walk(
> +	struct list_lru *lru,
> +	list_lru_walk_cb isolate,
> +	void		*cb_arg,
> +	unsigned long	nr_to_walk)

Interface documentation, please.

> +{
> +	struct list_head *item, *n;
> +	unsigned long removed = 0;
> +
> +	spin_lock(&lru->lock);
> +	list_for_each_safe(item, n, &lru->list) {
> +		enum lru_status ret;
> +		bool first_pass = true;
> +restart:
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

With no documentation in the code or the changelog, I haven't a clue why
these four possibilities exist :(

> +			if (!first_pass)
> +				break;
> +			first_pass = false;
> +			goto restart;
> +		default:
> +			BUG();
> +		}
> +
> +		if (nr_to_walk-- == 0)
> +			break;
> +
> +	}
> +	spin_unlock(&lru->lock);
> +	return removed;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_walk);

Passing the address of the spinlock to the list_lru_walk_cb handler is
rather gross.

And afacit it is unresolvably buggy - if the handler dropped that lock,
list_lru_walk() is now left holding a list_head at *item which could
have been altered or even freed.

How [patch 09/35]'s inode_lru_isolate() avoids this bug I don't know. 
Perhaps it doesn't.


Addendum: having now read through the evolution of lib/list_lru.c, it's
pretty apparent that this code is highly specific to the inode and
dcache shrinkers and is unlikely to see applications elsewhere.  So
hrm, perhaps we're kinda kidding ourselves by putting it in lib/ at
all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
