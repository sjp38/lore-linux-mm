Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3630E900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 09:55:52 -0400 (EDT)
Received: by wiga1 with SMTP id a1so15268057wig.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 06:55:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dg10si1361485wjb.152.2015.06.03.06.55.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 06:55:49 -0700 (PDT)
Date: Wed, 3 Jun 2015 15:55:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 2/2] memcg: convert mem_cgroup->under_oom from
 atomic_t to int
Message-ID: <20150603135546.GE16201@dhcp22.suse.cz>
References: <20150603023824.GA7579@mtj.duckdns.org>
 <20150603023859.GB7579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603023859.GB7579@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 03-06-15 11:38:59, Tejun Heo wrote:
> From 5456f353297d6f10b45fd794674b09dd5ab502ca Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj@kernel.org>
> Date: Tue, 2 Jun 2015 09:29:11 -0400
> 
> memcg->under_oom tracks whether the memcg is under OOM conditions and
> is an atomic_t counter managed with mem_cgroup_[un]mark_under_oom().
> While atomic_t appears to be simple synchronization-wise, when used as
> a synchronization construct like here, it's trickier and more
> error-prone due to weak memory ordering rules, especially around
> atomic_read(), and false sense of security.
> 
> For example, both non-trivial read sites of memcg->under_oom are a bit
> problematic although not being actually broken.
> 
> * mem_cgroup_oom_register_event()
> 
>   It isn't explicit what guarantees the memory ordering between event
>   addition and memcg->under_oom check.  This isn't broken only because
>   memcg_oom_lock is used for both event list and memcg->oom_lock.
> 
> * memcg_oom_recover()
> 
>   The lockless test doesn't have any explanation why this would be
>   safe.
> 
> mem_cgroup_[un]mark_under_oom() are very cold paths and there's no
> point in avoiding locking memcg_oom_lock there.  This patch converts
> memcg->under_oom from atomic_t to int, puts their modifications under
> memcg_oom_lock and documents why the lockless test in
> memcg_oom_recover() is safe.
>
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 29 +++++++++++++++++++++--------
>  1 file changed, 21 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9f39647..4de6647 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -285,8 +285,9 @@ struct mem_cgroup {
>  	 */
>  	bool use_hierarchy;
>  
> +	/* protected by memcg_oom_lock */
>  	bool		oom_lock;
> -	atomic_t	under_oom;
> +	int		under_oom;
>  
>  	int	swappiness;
>  	/* OOM-Killer disable */
> @@ -1809,8 +1810,10 @@ static void mem_cgroup_mark_under_oom(struct mem_cgroup *memcg)
>  {
>  	struct mem_cgroup *iter;
>  
> +	spin_lock(&memcg_oom_lock);
>  	for_each_mem_cgroup_tree(iter, memcg)
> -		atomic_inc(&iter->under_oom);
> +		iter->under_oom++;
> +	spin_unlock(&memcg_oom_lock);
>  }
>  
>  static void mem_cgroup_unmark_under_oom(struct mem_cgroup *memcg)
> @@ -1819,11 +1822,13 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *memcg)
>  
>  	/*
>  	 * When a new child is created while the hierarchy is under oom,
> -	 * mem_cgroup_oom_lock() may not be called. We have to use
> -	 * atomic_add_unless() here.
> +	 * mem_cgroup_oom_lock() may not be called. Watch for underflow.
>  	 */
> +	spin_lock(&memcg_oom_lock);
>  	for_each_mem_cgroup_tree(iter, memcg)
> -		atomic_add_unless(&iter->under_oom, -1, 0);
> +		if (iter->under_oom > 0)
> +			iter->under_oom--;
> +	spin_unlock(&memcg_oom_lock);
>  }
>  
>  static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
> @@ -1857,7 +1862,15 @@ static void memcg_wakeup_oom(struct mem_cgroup *memcg)
>  
>  static void memcg_oom_recover(struct mem_cgroup *memcg)
>  {
> -	if (memcg && atomic_read(&memcg->under_oom))
> +	/*
> +	 * For the following lockless ->under_oom test, the only required
> +	 * guarantee is that it must see the state asserted by an OOM when
> +	 * this function is called as a result of userland actions
> +	 * triggered by the notification of the OOM.  This is trivially
> +	 * achieved by invoking mem_cgroup_mark_under_oom() before
> +	 * triggering notification.
> +	 */
> +	if (memcg && memcg->under_oom)
>  		memcg_wakeup_oom(memcg);
>  }
>  
> @@ -3866,7 +3879,7 @@ static int mem_cgroup_oom_register_event(struct mem_cgroup *memcg,
>  	list_add(&event->list, &memcg->oom_notify);
>  
>  	/* already in OOM ? */
> -	if (atomic_read(&memcg->under_oom))
> +	if (memcg->under_oom)
>  		eventfd_signal(eventfd, 1);
>  	spin_unlock(&memcg_oom_lock);
>  
> @@ -3895,7 +3908,7 @@ static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(sf));
>  
>  	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
> -	seq_printf(sf, "under_oom %d\n", (bool)atomic_read(&memcg->under_oom));
> +	seq_printf(sf, "under_oom %d\n", (bool)memcg->under_oom);
>  	return 0;
>  }
>  
> -- 
> 2.4.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
