Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 59B106B0038
	for <linux-mm@kvack.org>; Thu,  9 May 2013 09:37:46 -0400 (EDT)
Date: Thu, 9 May 2013 14:37:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 08/31] list: add a new LRU list type
Message-ID: <20130509133742.GW11497@suse.de>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <1368079608-5611-9-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1368079608-5611-9-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Thu, May 09, 2013 at 10:06:25AM +0400, Glauber Costa wrote:
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
> [ glommer: enum defined constants for lru. Suggested by gthelen,
>   don't relock over retry ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Reviewed-by: Greg Thelen <gthelen@google.com>
> >
> > <SNIP>
> >
> +
> +unsigned long
> +list_lru_walk(
> +	struct list_lru *lru,
> +	list_lru_walk_cb isolate,
> +	void		*cb_arg,
> +	long		nr_to_walk)
> +{
> +	struct list_head *item, *n;
> +	unsigned long removed = 0;
> +
> +	spin_lock(&lru->lock);
> +restart:
> +	list_for_each_safe(item, n, &lru->list) {
> +		enum lru_status ret;
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

What happened your suggestion to only retry once for each object to
avoid any possibility of infinite looping or stalling for prolonged
periods of time waiting on XFS to do something?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
