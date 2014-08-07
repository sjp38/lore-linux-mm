Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6397A6B0037
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 09:36:17 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so5023779wib.16
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 06:36:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gc1si8460615wib.24.2014.08.07.06.36.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 06:36:15 -0700 (PDT)
Date: Thu, 7 Aug 2014 15:36:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/4] mm: memcontrol: add memory.current and memory.high
 to default hierarchy
Message-ID: <20140807133614.GC12730@dhcp22.suse.cz>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <1407186897-21048-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407186897-21048-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 04-08-14 17:14:55, Johannes Weiner wrote:
[...]
> @@ -132,6 +137,19 @@ u64 res_counter_uncharge(struct res_counter *counter, unsigned long val);
>  u64 res_counter_uncharge_until(struct res_counter *counter,
>  			       struct res_counter *top,
>  			       unsigned long val);
> +
> +static inline unsigned long long res_counter_high(struct res_counter *cnt)

soft limit used res_counter_soft_limit_excess which has quite a long
name but at least those two should be consistent.
I will post two helper patches which I have used to make this and other
operations on res counter easier as a reply to this.

> +{
> +	unsigned long long high = 0;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	if (cnt->usage > cnt->high)
> +		high = cnt->usage - cnt->high;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return high;
> +}
> +
>  /**
>   * res_counter_margin - calculate chargeable space of a counter
>   * @cnt: the counter
> @@ -193,6 +211,17 @@ static inline void res_counter_reset_failcnt(struct res_counter *cnt)
>  	spin_unlock_irqrestore(&cnt->lock, flags);
>  }
>  
> +static inline int res_counter_set_high(struct res_counter *cnt,
> +				       unsigned long long high)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	cnt->high = high;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return 0;
> +}
> +
[...]
> @@ -2541,16 +2541,16 @@ retry:
>  		goto done;
>  
>  	size = batch * PAGE_SIZE;
> -	if (!res_counter_charge(&memcg->res, size, &fail_res)) {
> +	if (!res_counter_charge(&memcg->res, size, &res)) {
>  		if (!do_swap_account)
>  			goto done_restock;
> -		if (!res_counter_charge(&memcg->memsw, size, &fail_res))
> +		if (!res_counter_charge(&memcg->memsw, size, &res))
>  			goto done_restock;
>  		res_counter_uncharge(&memcg->res, size);
> -		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
> +		mem_over_limit = mem_cgroup_from_res_counter(res, memsw);
>  		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
>  	} else
> -		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> +		mem_over_limit = mem_cgroup_from_res_counter(res, res);
>  
>  	if (batch > nr_pages) {
>  		batch = nr_pages;
> @@ -2621,6 +2621,20 @@ bypass:
>  done_restock:
>  	if (batch > nr_pages)
>  		refill_stock(memcg, batch - nr_pages);
> +
> +	res = &memcg->res;
> +	while (res) {
> +		unsigned long long high = res_counter_high(res);
> +
> +		if (high) {
> +			unsigned long high_pages = high >> PAGE_SHIFT;
> +			struct mem_cgroup *memcg;
> +
> +			memcg = mem_cgroup_from_res_counter(res, res);
> +			mem_cgroup_reclaim(memcg, high_pages, gfp_mask, 0);
> +		}
> +		res = res->parent;
> +	}
>  done:
>  	return ret;
>  }

Why haven't you followed what we do for hard limit here? In my
implementation I have the following:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a37465fcd8ae..6a797c740ea5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2529,6 +2529,21 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	return NOTIFY_OK;
 }
 
+static bool high_limit_excess(struct mem_cgroup *memcg,
+		struct mem_cgroup **memcg_over_limit)
+{
+	struct mem_cgroup *parent = memcg;
+
+	do {
+		if (res_counter_limit_excess(&parent->res, RES_HIGH_LIMIT)) {
+			*memcg_over_limit = parent;
+			return true;
+		}
+	} while ((parent = parent_mem_cgroup(parent)));
+
+	return false;
+}
+
 static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		      unsigned int nr_pages)
 {
@@ -2623,6 +2638,10 @@ bypass:
 	goto retry;
 
 done_restock:
+	/* Throttle charger a bit if it is above high limit. */
+	if (high_limit_excess(memcg, &mem_over_limit))
+		mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
+
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
 done:

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
