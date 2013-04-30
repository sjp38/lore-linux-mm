Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1BEC16B00F5
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:00:57 -0400 (EDT)
Message-ID: <517FEAE5.2010809@parallels.com>
Date: Tue, 30 Apr 2013 20:01:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 08/31] list: add a new LRU list type
References: <1367018367-11278-1-git-send-email-glommer@openvz.org> <1367018367-11278-9-git-send-email-glommer@openvz.org> <20130430151854.GH6415@suse.de>
In-Reply-To: <20130430151854.GH6415@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

>> +
>> +struct list_lru {
>> +	spinlock_t		lock;
>> +	struct list_head	list;
>> +	long			nr_items;
>> +};
> 
> Is there ever a circumstance where nr_items is negative? If so, what
> does that mean?
> 

No, but we would like to be able to detect it and BUG (which we actually do)


> 
>> +int list_lru_add(struct list_lru *lru, struct list_head *item);
>> +int list_lru_del(struct list_lru *lru, struct list_head *item);
>> +
> 
> However, these are bool and the return value determines if the item was
> really added to the list or not. It fails if the item is already part of
> a list and it would be very nice to have a comment explaining why it's
> not a bug if this happens because it feels like it would be a lookup and
> insertion race. Maybe it's clear later in the series why this is ok but
> it's not very obvious at this point.
> 

I actually don't know.
I would appreciate Dave's comments on this one. Dave?

>> +static inline long list_lru_count(struct list_lru *lru)
>> +{
>> +	return lru->nr_items;
>> +}
>> +
>> +typedef enum lru_status
>> +(*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
>> +
>> +typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
>> +
>> +long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
>> +		   void *cb_arg, long nr_to_walk);
>> +
> 
> Is nr_to_walk ever negative?
> 

Shouldn't be, and this one, we don't BUG.

>> +long list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
>> +
>> +#endif /* _LRU_LIST_H */
>> diff --git a/lib/Makefile b/lib/Makefile
>> index af79e8c..40a6d4a 100644
>> --- a/lib/Makefile
>> +++ b/lib/Makefile
>> @@ -13,7 +13,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
>>  	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
>>  	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
>>  	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
>> -	 earlycpio.o percpu-refcount.o
>> +	 earlycpio.o percpu-refcount.o list_lru.o
>>  
>>  obj-$(CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS) += usercopy.o
>>  lib-$(CONFIG_MMU) += ioremap.o
>> diff --git a/lib/list_lru.c b/lib/list_lru.c
>> new file mode 100644
>> index 0000000..937ee87
>> --- /dev/null
>> +++ b/lib/list_lru.c
>> @@ -0,0 +1,118 @@
>> +/*
>> + * Copyright (c) 2010-2012 Red Hat, Inc. All rights reserved.
>> + * Author: David Chinner
>> + *
>> + * Generic LRU infrastructure
>> + */
>> +#include <linux/kernel.h>
>> +#include <linux/module.h>
>> +#include <linux/list_lru.h>
>> +
>> +int
>> +list_lru_add(
>> +	struct list_lru	*lru,
>> +	struct list_head *item)
>> +{
>> +	spin_lock(&lru->lock);
>> +	if (list_empty(item)) {
>> +		list_add_tail(item, &lru->list);
>> +		lru->nr_items++;
>> +		spin_unlock(&lru->lock);
>> +		return 1;
>> +	}
>> +	spin_unlock(&lru->lock);
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(list_lru_add);
>> +
>> +int
>> +list_lru_del(
>> +	struct list_lru	*lru,
>> +	struct list_head *item)
>> +{
>> +	spin_lock(&lru->lock);
>> +	if (!list_empty(item)) {
>> +		list_del_init(item);
>> +		lru->nr_items--;
>> +		spin_unlock(&lru->lock);
>> +		return 1;
>> +	}
>> +	spin_unlock(&lru->lock);
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(list_lru_del);
>> +
>> +long
>> +list_lru_walk(
> 
> It returns long but never actually returns a negative number.
> 
>> +	struct list_lru *lru,
>> +	list_lru_walk_cb isolate,
>> +	void		*cb_arg,
>> +	long		nr_to_walk)
>> +{
>> +	struct list_head *item, *n;
>> +	long removed = 0;
>> +
>> +	spin_lock(&lru->lock);
>> +restart:
>> +	list_for_each_safe(item, n, &lru->list) {
>> +		enum lru_status ret;
>> +
>> +		if (nr_to_walk-- < 0)
>> +			break;
>> +
>> +		ret = isolate(item, &lru->lock, cb_arg);
>> +		switch (ret) {
>> +		case LRU_REMOVED:
>> +			lru->nr_items--;
>> +			removed++;
>> +			break;
>> +		case LRU_ROTATE:
>> +			list_move_tail(item, &lru->list);
>> +			break;
>> +		case LRU_SKIP:
>> +			break;
>> +		case LRU_RETRY:
>> +			goto restart;
> 
> Are the two users of LRU_RETRY guaranteed to eventually make progress
> or can this infinite loop? It feels like the behaviour of LRU_RETRY is
> not very desirable. Once an object that returns LRU_RETRY is isolated on
> the list then it looks like XFS can stall for 100 ticks (bit arbitrary)
> each time it tries and maybe do this forever.
> 
> The inode.c user looks like it could race where some other process is
> reallocating the buffers between each time this isolate callback tries to
> isolate it. Granted, it may accidentally break out because the spinlock
> is contended and it returns LRU_SKIP so maybe no one will hit the problem
> but if it's ok with LRU_SKIP then maybe a LRU_RETRY_ONCE would also be
> suitable and use that in fs/inode.c?
> 
> Either hypothetical situation would require that the list you are trying
> to walk is very small but maybe memcg will hit that problem. If there is
> a guarantee of forward progress then a comment would be nice.
> 

I have to look into this issue further, which I plan to do soon, but
can't today. Meanwhile, This is really a lot more under Dave's umbrella,
so Dave, if you would give us the honor =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
