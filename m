Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7536B0261
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:53:05 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 200so3173797pge.12
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:53:05 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 34si2131453plz.343.2017.11.29.16.53.03
        for <linux-mm@kvack.org>;
        Wed, 29 Nov 2017 16:53:04 -0800 (PST)
Date: Thu, 30 Nov 2017 09:53:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
Message-ID: <20171130005301.GA2679@bbox>
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511965054-6328-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Wed, Nov 29, 2017 at 09:17:34AM -0500, Waiman Long wrote:
> The list_lru_del() function removes the given item from the LRU list.
> The operation looks simple, but it involves writing into the cachelines
> of the two neighboring list entries in order to get the deletion done.
> That can take a while if the cachelines aren't there yet, thus
> prolonging the lock hold time.
> 
> To reduce the lock hold time, the cachelines of the two neighboring
> list entries are now prefetched before acquiring the list_lru_node's
> lock.
> 
> Using a multi-threaded test program that created a large number
> of dentries and then killed them, the execution time was reduced
> from 38.5s to 36.6s after applying the patch on a 2-socket 36-core
> 72-thread x86-64 system.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  mm/list_lru.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index f141f0c..65aae44 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -132,8 +132,16 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
>  	struct list_lru_node *nlru = &lru->node[nid];
>  	struct list_lru_one *l;
>  
> +	/*
> +	 * Prefetch the neighboring list entries to reduce lock hold time.
> +	 */
> +	if (unlikely(list_empty(item)))
> +		return false;
> +	prefetchw(item->prev);
> +	prefetchw(item->next);
> +

A question:

A few month ago, I had a chance to measure prefetch effect with my testing
workload. For the clarification, it's not list_lru_del but list traverse
stuff so it might be similar.

With my experiment at that time, it was really hard to find best place to
add prefetchw. Sometimes, it was too eariler or late so the effect was
not good, even worse on some cases.

Also, the performance was different with each machine although my testing
machines was just two. ;-)

So my question is what's a rule of thumb to add prefetch command?
Like your code, putting prefetch right before touching?

I'm really wonder what's the rule to make every arch/machines happy
with prefetch.

>  	spin_lock(&nlru->lock);
> -	if (!list_empty(item)) {
> +	if (likely(!list_empty(item))) {
>  		l = list_lru_from_kmem(nlru, item);
>  		list_del_init(item);
>  		l->nr_items--;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
