Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id B322B6B0033
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:06:08 -0400 (EDT)
Date: Wed, 5 Jun 2013 20:05:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 08/35] list: add a new LRU list type
Message-Id: <20130605200554.d4dae16f.akpm@linux-foundation.org>
In-Reply-To: <20130606024909.GP29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-9-git-send-email-glommer@openvz.org>
	<20130605160758.19e854a6995e3c2a1f5260bf@linux-foundation.org>
	<20130606024909.GP29338@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Thu, 6 Jun 2013 12:49:09 +1000 Dave Chinner <david@fromorbit.com> wrote:

> > > +{
> > > +	spin_lock(&lru->lock);
> > 
> > OK, problems.  Long experience has shown us that in-kernel container
> > library code like this should not perform its own locking.  Things like:
> > 
> > - I want to call it from interrupts!
> > - I want to use a mutex!
> > - I want to use RCU!
> 
> Wrap them around the outside of all your LRU operations, then.
> 
> > - I already hold a lock and don't need this code to take another one!
> 
> The internal lru lock is for simplicity of implementation.
> 
> > - I need to sleep in my isolate callback, but the library code is
> >   holding a spinlock!
> 
> The isolate callback gets passed the spinlock that it is holding
> precisely so the callback can drop it and do sleeping operations.

As I said, "Long experience has shown".  These restrictions reduce the
usefulness of this code.

> > - I want to test lru.nr_items in a non-racy fashion, but to do that I
> >   have to take a lib/-private spinlock!
> 
> Nobody should be peeking at the internals of the list structures.
> That's just completely broken. Use the APIs that are provided

Those APIs don't work.  It isn't possible for callers to get an exact
count, unless they provide redundant external locking.  This problem is
a consequence of the decision to perform lib-internal locking.

> The current implementation is designed to be basic and obviously
> correct, not some wacky, amazingly optimised code that nobody but
> the original author can understand.

Implementations which expect caller-provided locking are simpler.

> > This is a little bit strange, because one could legitimately do
> > 
> > 	list_del(item);		/* from my private list */
> > 	list_lru_add(lru, item);
> > 
> > but this interface forced me to do a needless lru_del_init().
> 
> How do you know what list the item is on in list_lru_add()? We have
> to know to get the accounting right. i.e. if it is already on the
> LRU and we remove it and the re-add it, the number of items on the
> list doesn't change. but it it's on some private list, then we have
> to increment the number of items on the LRU list.
> 
> So, if it's already on a list, we cannot determine what the correct
> thing to do it, and hence the callers of list_lru_add() must ensure
> that the item is not on a private list before trying to add it to
> the LRU.

It isn't "already on a list" - the caller just removed it!

It's suboptimal, but I'm not saying this decision was wrong.  However
explanation and documentation is needed to demonstrate that it was
correct.

> > Addendum: having now read through the evolution of lib/list_lru.c, it's
> > pretty apparent that this code is highly specific to the inode and
> > dcache shrinkers and is unlikely to see applications elsewhere.  So
> > hrm, perhaps we're kinda kidding ourselves by putting it in lib/ at
> > all.
> 
> In this patch set, it replaces the LRU in the xfs buffer cache, the
> LRU in the XFS dquot cache, and I've got patches that use it in the
> XFS inode cache as well. And they were all drop-in replacements,
> just like for the inode and dentry caches. It's hard to claim that
> it's so specific to the inode/dentry caches when there are at least
> 3 other LRUs that were pretty trivial to convert for use...
> 
> The whole point of the patchset is to introduce infrastructure that
> is generically useful. Sure, it might start out looking like the
> thing that it was derived from, but we've got to start somewhere.
> Given that there are 5 different users already, it's obviously
> already more than just usable for the inode and dentry caches.
> 
> The only reason that there haven't been more subsystems converted is
> that we are concentrating on getting what we alreayd have merged
> first....

I'm not objecting to the code per-se - I'm sure it's appropriate to the
current callsites.  But these restrictions do reduce its overall
applicability.  And I do agree that it's not worth generalizing it
because of what-if scenarios.

Why was it called "lru", btw?  iirc it's actually a "stack" (or
"queue"?) and any lru functionality is actually implemented externally.
There is no "list_lru_touch()".


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
