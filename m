Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 793646B0033
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 17:03:15 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 61so5025399plz.1
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 14:03:15 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id p20si4247475pfk.92.2017.12.01.14.03.13
        for <linux-mm@kvack.org>;
        Fri, 01 Dec 2017 14:03:14 -0800 (PST)
Date: Sat, 2 Dec 2017 09:02:46 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-ID: <20171201220246.GV4094@dastard>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
 <20171130004252.GR4094@dastard>
 <209d1aea-2951-9d4f-5638-8bc037a6676c@redhat.com>
 <20171130124736.e60c75d120b74314c049c02b@linux-foundation.org>
 <20171201000919.GA4439@bbox>
 <84b4b0ea-5e54-a0df-4fee-9892da2bf418@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84b4b0ea-5e54-a0df-4fee-9892da2bf418@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 01, 2017 at 09:14:52AM -0500, Waiman Long wrote:
> On 11/30/2017 07:09 PM, Minchan Kim wrote:
> > On Thu, Nov 30, 2017 at 12:47:36PM -0800, Andrew Morton wrote:
> >> On Thu, 30 Nov 2017 08:54:04 -0500 Waiman Long <longman@redhat.com> wrote:
> >>
> >>>> And, from that perspective, the racy shortcut in the proposed patch
> >>>> is wrong, too. Prefetch is fine, but in general shortcutting list
> >>>> empty checks outside the internal lock isn't.
> >>> For the record, I add one more list_empty() check at the beginning of
> >>> list_lru_del() in the patch for 2 purpose:
> >>> 1. it allows the code to bail out early.
> >>> 2. It make sure the cacheline of the list_head entry itself is loaded.
> >>>
> >>> Other than that, I only add a likely() qualifier to the existing
> >>> list_empty() check within the lock critical region.
> >> But it sounds like Dave thinks that unlocked check should be removed?
> >>
> >> How does this adendum look?
> >>
> >> From: Andrew Morton <akpm@linux-foundation.org>
> >> Subject: list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
> >>
> >> include prefetch.h, remove unlocked list_empty() test, per Dave
> >>
> >> Cc: Dave Chinner <david@fromorbit.com>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> >> Cc: Waiman Long <longman@redhat.com>
> >> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >> ---
> >>
> >>  mm/list_lru.c |    5 ++---
> >>  1 file changed, 2 insertions(+), 3 deletions(-)
> >>
> >> diff -puN mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix mm/list_lru.c
> >> --- a/mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
> >> +++ a/mm/list_lru.c
> >> @@ -8,6 +8,7 @@
> >>  #include <linux/module.h>
> >>  #include <linux/mm.h>
> >>  #include <linux/list_lru.h>
> >> +#include <linux/prefetch.h>
> >>  #include <linux/slab.h>
> >>  #include <linux/mutex.h>
> >>  #include <linux/memcontrol.h>
> >> @@ -135,13 +136,11 @@ bool list_lru_del(struct list_lru *lru,
> >>  	/*
> >>  	 * Prefetch the neighboring list entries to reduce lock hold time.
> >>  	 */
> >> -	if (unlikely(list_empty(item)))
> >> -		return false;
> >>  	prefetchw(item->prev);
> >>  	prefetchw(item->next);
> >>  
> >>  	spin_lock(&nlru->lock);
> >> -	if (likely(!list_empty(item))) {
> >> +	if (!list_empty(item)) {
> >>  		l = list_lru_from_kmem(nlru, item);
> >>  		list_del_init(item);
> >>  		l->nr_items--;
> > If we cannot guarantee it's likely !list_empty, prefetch with NULL pointer
> > would be harmful by the lesson we have learned.
> >
> >         https://lwn.net/Articles/444336/
> 
> FYI, when list_empty() is true, it just mean the links are pointing to
> list entry itself. The pointers will never be NULL. So that won't cause
> the NULL prefetch problem mentioned in the article.

Sure, but that misses the larger point of the article in that there
are many unpredictable side effects of adding prefetches, the least
of which is that the result is CPU specific. Some CPUs improve,
others regress, and there's no predicting which side of the ledger
any given CPU falls on.

So from that perspective, we should consider manual prefetching
harmful, similar to the way that likely/unlikely is generally
considered harmful. i.e. it's pretty much impossible for a
programmer to get right in all situations.

> 
> > So, with considering list_lru_del is generic library, it cannot see
> > whether a workload makes heavy lock contentions or not.
> > Maybe, right place for prefetching would be in caller, not in library
> > itself.
> 
> Yes, the prefetch operations will add some overhead to the whole
> deletion operation when the lock isn't contended, but that is usually
> rather small compared with the atomic ops involved in the locking
> operation itself. On the other hand, the performance gain will be
> noticeable when the lock is contended. I will ran some performance
> measurement and report the results later.

Given the extreme fuzziness of the benefit of manual prefetching,
you'll need to:
	a) document the test
	b) run the test on mulitple architectures
	c) run the test on mulitple different CPU models within
	   the x86-64 architecture
	d) show that it works in general for a majority of the
	   platforms and CPUs you benched, and not just for your
	   microbenchmark.

Basically, if there's historic context with people like Ingo saying
"prefetching is toxic" then there's a bloody high bar you need to
get over to add manual prefetching anywhere...

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
