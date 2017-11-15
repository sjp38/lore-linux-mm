Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7ED66B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 04:02:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q84so10995090pfl.12
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 01:02:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o11si17664812pgs.552.2017.11.15.01.02.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 01:02:58 -0800 (PST)
Date: Wed, 15 Nov 2017 10:02:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171115090251.umpd53zpvp42xkvi@dhcp22.suse.cz>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 14-11-17 06:37:42, Tetsuo Handa wrote:
> When shrinker_rwsem was introduced, it was assumed that
> register_shrinker()/unregister_shrinker() are really unlikely paths
> which are called during initialization and tear down. But nowadays,
> register_shrinker()/unregister_shrinker() might be called regularly.

Please provide some examples. I know your other patch mentions the
usecase but I guess the two patches should be just squashed together.

> This patch prepares for allowing parallel registration/unregistration
> of shrinkers.
> 
> Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> using one RCU section. But using atomic_inc()/atomic_dec() for each
> do_shrink_slab() call will not impact so much.
> 
> This patch uses polling loop with short sleep for unregister_shrinker()
> rather than wait_on_atomic_t(), for we can save reader's cost (plain
> atomic_dec() compared to atomic_dec_and_test()), we can expect that
> do_shrink_slab() of unregistering shrinker likely returns shortly, and
> we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
> shrinker unexpectedly took so long.

I would use wait_event_interruptible in the remove path rather than the
short sleep loop which is just too ugly. The shrinker walk would then
just wake_up the sleeper when the ref. count drops to 0. Two
synchronize_rcu is quite ugly as well, but I was not able to simplify
them. I will keep thinking. It just sucks how we cannot follow the
standard rcu list with dynamically allocated structure pattern here.
 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/shrinker.h |  3 ++-
>  mm/vmscan.c              | 41 +++++++++++++++++++----------------------
>  2 files changed, 21 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 388ff29..333a1d0 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -62,9 +62,10 @@ struct shrinker {
>  
>  	int seeks;	/* seeks to recreate an obj */
>  	long batch;	/* reclaim batch size, 0 = default */
> -	unsigned long flags;
> +	unsigned int flags;

Why?

>  
>  	/* These are for internal use */
> +	atomic_t nr_active;
>  	struct list_head list;
>  	/* objs pending delete, per node */
>  	atomic_long_t *nr_deferred;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1c1bc95..c8996e8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -157,7 +157,7 @@ struct scan_control {
>  unsigned long vm_total_pages;
>  
>  static LIST_HEAD(shrinker_list);
> -static DECLARE_RWSEM(shrinker_rwsem);
> +static DEFINE_MUTEX(shrinker_lock);
>  
>  #ifdef CONFIG_MEMCG
>  static bool global_reclaim(struct scan_control *sc)
> @@ -285,9 +285,10 @@ int register_shrinker(struct shrinker *shrinker)
>  	if (!shrinker->nr_deferred)
>  		return -ENOMEM;
>  
> -	down_write(&shrinker_rwsem);
> -	list_add_tail(&shrinker->list, &shrinker_list);
> -	up_write(&shrinker_rwsem);
> +	atomic_set(&shrinker->nr_active, 0);

I would expect ref counter to be 1 and either remove path dec it down to
0 or the racing walker would. In any case that is when
unregister_shrinker can continue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
