Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 30C2E8D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 13:38:00 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p0JIbvdK011126
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 10:37:57 -0800
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by wpaz17.hot.corp.google.com with ESMTP id p0JIbP6A031234
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 10:37:56 -0800
Received: by pwj6 with SMTP id 6so239253pwj.12
        for <linux-mm@kvack.org>; Wed, 19 Jan 2011 10:37:55 -0800 (PST)
Date: Wed, 19 Jan 2011 10:37:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
 is not allowed
In-Reply-To: <20110119215500.2833.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1101191034060.16126@chino.kir.corp.google.com>
References: <20110118101547.GF27152@csn.ul.ie> <alpine.DEB.2.00.1101181211100.18781@chino.kir.corp.google.com> <20110119215500.2833.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011, KOSAKI Motohiro wrote:

> I'm glad to you are keeping fastpath concern. However you don't need
> nodemask-and in this case. Because zonelist->zref[0] is always in nodemask.
> Please see policy_zonelist(). So, you can just replace nodemask with cpuset_mems_allowed.
> 
> This is not only simple, but also improve a consisteny of mempolicy.
> 

mempolicies have nothing to do with this, they pass their nodemask into 
the page allocator so the preferred_zone is already allowed; setting a 
mempolicy with a nodemask that is disallowed by the cpuset is an invalid 
configuration.

> ---
>  mm/page_alloc.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 07a6544..876de04 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2146,7 +2146,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  
>  	get_mems_allowed();
>  	/* The preferred zone is used for statistics later */
> -	first_zones_zonelist(zonelist, high_zoneidx, nodemask, &preferred_zone);
> +	first_zones_zonelist(zonelist, high_zoneidx,
> +			     &cpuset_current_mems_allowed, &preferred_zone);
>  	if (!preferred_zone) {
>  		put_mems_allowed();
>  		return NULL;

As previously mentioned, I didn't want to affect the current behavior of 
mempolicies when they pass their own nodemask into the page allocator that 
may be a subset of the set of allowed nodes; in that case, the statistics 
are probably actually important and we can defer resetting preferred_zone 
to the slowpath where we know its a __GFP_WAIT allocation instead of the 
first try in the fastpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
