Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 287116B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:42:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p17so3582820pfh.18
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:42:57 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id d63si2235369pfb.16.2017.11.29.16.42.54
        for <linux-mm@kvack.org>;
        Wed, 29 Nov 2017 16:42:55 -0800 (PST)
Date: Thu, 30 Nov 2017 11:42:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-ID: <20171130004252.GR4094@dastard>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 29, 2017 at 01:53:19PM -0800, Andrew Morton wrote:
> On Wed, 29 Nov 2017 09:17:34 -0500 Waiman Long <longman@redhat.com> wrote:
> 
> > The list_lru_del() function removes the given item from the LRU list.
> > The operation looks simple, but it involves writing into the cachelines
> > of the two neighboring list entries in order to get the deletion done.
> > That can take a while if the cachelines aren't there yet, thus
> > prolonging the lock hold time.
> > 
> > To reduce the lock hold time, the cachelines of the two neighboring
> > list entries are now prefetched before acquiring the list_lru_node's
> > lock.
> > 
> > Using a multi-threaded test program that created a large number
> > of dentries and then killed them, the execution time was reduced
> > from 38.5s to 36.6s after applying the patch on a 2-socket 36-core
> > 72-thread x86-64 system.
> 
> Patch looks good.
> 
> Can someone (Dave?) please explain why list_lru_del() supports deletion
> of an already list_empty(item)?
> This seems a rather dangerous thing to
> encourage.  Use cases I can think of are:
> 
> a) item is already reliably deleted, so why the heck was the caller
>    calling list_lru_del() and 

Higher level operations can race. e.g. caller looks up an object,
finds it on the LRU, takes a reference. Then calls list_lru_del()
to remove it from the LRU. It blocks 'cause it can't get the list
lock as....

... Meanwhile, the list shrinker is running, sees the object on the
LRU list, sees it has a valid reference count, does lazy LRU cleanup
by runnning list_lru_isolate() on the object which removes it from
the LRU list. Eventually it drops the list lock, and ....

... the original thread gets the lock in list_lru_del() and sees the
object has already been removed from the LRU....

IOWs, this sort of boilerplate code is potentially dangerous if
list_lru_del() can't handle items that have already been removed
from the list:

	if (!list_empty(&obj->lru))
		list_lru_del(&obj->lru);

Because this:

	if (!list_empty(&obj->lru))
		<preempt>
		<shrinker removes obj from LRU>
		list_lru_del(&obj->lru);
			<SPLAT>

Would result in bad things happening....

And, from that perspective, the racy shortcut in the proposed patch
is wrong, too. Prefetch is fine, but in general shortcutting list
empty checks outside the internal lock isn't.

> b) item might be concurrently deleted by another thread, in which case
>    the race loser is likely to hit a use-after-free.

Nope. the list_lru infrastructure is just for tracking how the
object is aging. It is not designed to control object lifecycle
behaviour - it's not a kref. It's just an ordered list with a
shrinker callback to allow subsystems to react to memory pressure.

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
