Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2906B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 19:09:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w22so5236067pge.10
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 16:09:22 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b5si3853870pgr.120.2017.11.30.16.09.20
        for <linux-mm@kvack.org>;
        Thu, 30 Nov 2017 16:09:21 -0800 (PST)
Date: Fri, 1 Dec 2017 09:09:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-ID: <20171201000919.GA4439@bbox>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171129135319.ab078fbed566be8fc90c92ec@linux-foundation.org>
 <20171130004252.GR4094@dastard>
 <209d1aea-2951-9d4f-5638-8bc037a6676c@redhat.com>
 <20171130124736.e60c75d120b74314c049c02b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130124736.e60c75d120b74314c049c02b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, Dave Chinner <david@fromorbit.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 30, 2017 at 12:47:36PM -0800, Andrew Morton wrote:
> On Thu, 30 Nov 2017 08:54:04 -0500 Waiman Long <longman@redhat.com> wrote:
> 
> > > And, from that perspective, the racy shortcut in the proposed patch
> > > is wrong, too. Prefetch is fine, but in general shortcutting list
> > > empty checks outside the internal lock isn't.
> > 
> > For the record, I add one more list_empty() check at the beginning of
> > list_lru_del() in the patch for 2 purpose:
> > 1. it allows the code to bail out early.
> > 2. It make sure the cacheline of the list_head entry itself is loaded.
> > 
> > Other than that, I only add a likely() qualifier to the existing
> > list_empty() check within the lock critical region.
> 
> But it sounds like Dave thinks that unlocked check should be removed?
> 
> How does this adendum look?
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
> 
> include prefetch.h, remove unlocked list_empty() test, per Dave
> 
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Waiman Long <longman@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/list_lru.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff -puN mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix mm/list_lru.c
> --- a/mm/list_lru.c~list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix
> +++ a/mm/list_lru.c
> @@ -8,6 +8,7 @@
>  #include <linux/module.h>
>  #include <linux/mm.h>
>  #include <linux/list_lru.h>
> +#include <linux/prefetch.h>
>  #include <linux/slab.h>
>  #include <linux/mutex.h>
>  #include <linux/memcontrol.h>
> @@ -135,13 +136,11 @@ bool list_lru_del(struct list_lru *lru,
>  	/*
>  	 * Prefetch the neighboring list entries to reduce lock hold time.
>  	 */
> -	if (unlikely(list_empty(item)))
> -		return false;
>  	prefetchw(item->prev);
>  	prefetchw(item->next);
>  
>  	spin_lock(&nlru->lock);
> -	if (likely(!list_empty(item))) {
> +	if (!list_empty(item)) {
>  		l = list_lru_from_kmem(nlru, item);
>  		list_del_init(item);
>  		l->nr_items--;

If we cannot guarantee it's likely !list_empty, prefetch with NULL pointer
would be harmful by the lesson we have learned.

        https://lwn.net/Articles/444336/

So, with considering list_lru_del is generic library, it cannot see
whether a workload makes heavy lock contentions or not.
Maybe, right place for prefetching would be in caller, not in library
itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
