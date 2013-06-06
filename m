Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id DCC7F6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 22:49:28 -0400 (EDT)
Date: Thu, 6 Jun 2013 12:49:09 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 08/35] list: add a new LRU list type
Message-ID: <20130606024909.GP29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-9-git-send-email-glommer@openvz.org>
 <20130605160758.19e854a6995e3c2a1f5260bf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605160758.19e854a6995e3c2a1f5260bf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Wed, Jun 05, 2013 at 04:07:58PM -0700, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:29:37 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Several subsystems use the same construct for LRU lists - a list
> > head, a spin lock and and item count. They also use exactly the same
> > code for adding and removing items from the LRU. Create a generic
> > type for these LRU lists.
> > 
> > This is the beginning of generic, node aware LRUs for shrinkers to
> > work with.
> > 
> > ...
> >
> > --- /dev/null
> > +++ b/include/linux/list_lru.h
> > @@ -0,0 +1,46 @@
> > +/*
> > + * Copyright (c) 2010-2012 Red Hat, Inc. All rights reserved.
> > + * Author: David Chinner
> > + *
> > + * Generic LRU infrastructure
> > + */
> > +#ifndef _LRU_LIST_H
> > +#define _LRU_LIST_H
> > +
> > +#include <linux/list.h>
> > +
> > +enum lru_status {
> > +	LRU_REMOVED,		/* item removed from list */
> > +	LRU_ROTATE,		/* item referenced, give another pass */
> > +	LRU_SKIP,		/* item cannot be locked, skip */
> > +	LRU_RETRY,		/* item not freeable. May drop the lock
> > +				   internally, but has to return locked. */
> > +};
> 
> What's this?
> 
> Seems to be the return code from the undocumented list_lru_walk_cb?
> 
> > +struct list_lru {
> > +	spinlock_t		lock;
> > +	struct list_head	list;
> > +	long			nr_items;
> 
> Should be an unsigned type.
> 
> > +};
> > +
> > +int list_lru_init(struct list_lru *lru);
> > +int list_lru_add(struct list_lru *lru, struct list_head *item);
> > +int list_lru_del(struct list_lru *lru, struct list_head *item);
> > +
> > +static inline unsigned long list_lru_count(struct list_lru *lru)
> > +{
> > +	return lru->nr_items;
> > +}
> 
> It got changed to unsigned here!
> 
> > +typedef enum lru_status
> > +(*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
> > +
> > +typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
> > +
> > +unsigned long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
> > +		   void *cb_arg, unsigned long nr_to_walk);
> > +
> > +unsigned long
> > +list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
> > +
> > +#endif /* _LRU_LIST_H */
> > diff --git a/lib/Makefile b/lib/Makefile
> > index af911db..d610fda 100644
> > --- a/lib/Makefile
> > +++ b/lib/Makefile
> > @@ -13,7 +13,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
> >  	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
> >  	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
> >  	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
> > -	 earlycpio.o percpu-refcount.o
> > +	 earlycpio.o percpu-refcount.o list_lru.o
> >  
> >  obj-$(CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS) += usercopy.o
> >  lib-$(CONFIG_MMU) += ioremap.o
> > diff --git a/lib/list_lru.c b/lib/list_lru.c
> > new file mode 100644
> > index 0000000..3127edd
> > --- /dev/null
> > +++ b/lib/list_lru.c
> > @@ -0,0 +1,122 @@
> > +/*
> > + * Copyright (c) 2010-2012 Red Hat, Inc. All rights reserved.
> > + * Author: David Chinner
> > + *
> > + * Generic LRU infrastructure
> > + */
> > +#include <linux/kernel.h>
> > +#include <linux/module.h>
> > +#include <linux/list_lru.h>
> > +
> > +int
> > +list_lru_add(
> > +	struct list_lru	*lru,
> > +	struct list_head *item)
> 
> This is lib/, not fs/xfs/ ;)
> 
> > +{
> > +	spin_lock(&lru->lock);
> 
> OK, problems.  Long experience has shown us that in-kernel container
> library code like this should not perform its own locking.  Things like:
> 
> - I want to call it from interrupts!
> - I want to use a mutex!
> - I want to use RCU!

Wrap them around the outside of all your LRU operations, then.

> - I already hold a lock and don't need this code to take another one!

The internal lru lock is for simplicity of implementation.

> - I need to sleep in my isolate callback, but the library code is
>   holding a spinlock!

The isolate callback gets passed the spinlock that it is holding
precisely so the callback can drop it and do sleeping operations.

> - I want to test lru.nr_items in a non-racy fashion, but to do that I
>   have to take a lib/-private spinlock!

Nobody should be peeking at the internals of the list structures.
That's just completely broken. Use the APIs that are provided, as
there is no guarantee that the implementation of the lists is going
to remain the same over time. The LRU list locks are an internal
implementation detail, and are only exposed in the places where
callbacks might need to drop them. And even then they are exposed as
just a pointer to the lock to avoid exposing internal details that
nobody has any business fucking with.

The current implementation is designed to be basic and obviously
correct, not some wacky, amazingly optimised code that nobody but
the original author can understand.

> etcetera.  It's just heaps less flexible and useful this way, and
> library code should be flexible and useful.

Quite frankly, the problem with all the existing LRU code is that
everyone rolls their own list and locking scheme. And you know what?
All people do is cookie-cutter copy-n-paste some buggy
implementation from somewhere else.

> If you want to put a spinlocked layer on top of the core code then fine
> - that looks to be simple enough, apart from list_lru_dispose_all().

I'm not interested in modifying the code for some nebulous "what if"
scenario. When someone comes up with an actual need that they can't
scratch by wrapping their needed exclusion around the outside of the
LRU like the dentry and inode caches do, then we can change it to
addresss that need.

> > +		list_add_tail(item, &lru->list);
> > +		lru->nr_items++;
> > +		spin_unlock(&lru->lock);
> > +		return 1;
> > +	}
> > +	spin_unlock(&lru->lock);
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL_GPL(list_lru_add);
> 
> So an undocumented, i-have-to-guess-why feature of list_lru_add() is
> that it will refuse to add an item which appears to be on a list
> already?

Because callers don't know ahead of time if the item is on a list
already. This is the same beheviour that the inode and dentry cache
LRUs have had for years. i.e. it supports lazy LRU addtion and
prevents objects that might be on dispose lists from being readded
to the LRU list and corrupting the lists...

> This is a little bit strange, because one could legitimately do
> 
> 	list_del(item);		/* from my private list */
> 	list_lru_add(lru, item);
> 
> but this interface forced me to do a needless lru_del_init().

How do you know what list the item is on in list_lru_add()? We have
to know to get the accounting right. i.e. if it is already on the
LRU and we remove it and the re-add it, the number of items on the
list doesn't change. but it it's on some private list, then we have
to increment the number of items on the LRU list.

So, if it's already on a list, we cannot determine what the correct
thing to do it, and hence the callers of list_lru_add() must ensure
that the item is not on a private list before trying to add it to
the LRU.

> Maybe this is good, maybe it is bad.  It depends on what the author(s)
> were thinking at the time ;)
> 
> 
> Either way, returning 1 on success and 0 on failure is surprising.  0
> means success, please.  Alternatively I guess one could make it return
> bool and document the dang thing, hence retaining the current 0/1 concept.

Sure, that can be fixed. Documentation is lacking at this point.

> > +restart:
> > +		ret = isolate(item, &lru->lock, cb_arg);
> > +		switch (ret) {
> > +		case LRU_REMOVED:
> > +			lru->nr_items--;
> > +			removed++;
> > +			break;
> > +		case LRU_ROTATE:
> > +			list_move_tail(item, &lru->list);
> > +			break;
> > +		case LRU_SKIP:
> > +			break;
> > +		case LRU_RETRY:
> 
> With no documentation in the code or the changelog, I haven't a clue why
> these four possibilities exist :(

Documentation would explain that:

> Passing the address of the spinlock to the list_lru_walk_cb handler is
> rather gross.
> 
> And afacit it is unresolvably buggy - if the handler dropped that lock,
> list_lru_walk() is now left holding a list_head at *item which could
> have been altered or even freed.
>
> How [patch 09/35]'s inode_lru_isolate() avoids this bug I don't know. 
> Perhaps it doesn't.

The LRU_RETRY cse is supposed to handle this. However, the LRU_RETRY
return code is now buggy and you've caught that. It'll need fixing.
My original code only had inode_lru_isolate() drop the lru lock, and
it would return LRU_RETRY which would restart the scan of the list
from the start, thereby avoiding those problems.

> Addendum: having now read through the evolution of lib/list_lru.c, it's
> pretty apparent that this code is highly specific to the inode and
> dcache shrinkers and is unlikely to see applications elsewhere.  So
> hrm, perhaps we're kinda kidding ourselves by putting it in lib/ at
> all.

In this patch set, it replaces the LRU in the xfs buffer cache, the
LRU in the XFS dquot cache, and I've got patches that use it in the
XFS inode cache as well. And they were all drop-in replacements,
just like for the inode and dentry caches. It's hard to claim that
it's so specific to the inode/dentry caches when there are at least
3 other LRUs that were pretty trivial to convert for use...

The whole point of the patchset is to introduce infrastructure that
is generically useful. Sure, it might start out looking like the
thing that it was derived from, but we've got to start somewhere.
Given that there are 5 different users already, it's obviously
already more than just usable for the inode and dentry caches.

The only reason that there haven't been more subsystems converted is
that we are concentrating on getting what we alreayd have merged
first....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
