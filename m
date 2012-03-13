Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 49A396B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 02:29:07 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 80D293EE0C3
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:29:05 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6410E45DEA6
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:29:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3786B45DEB2
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:29:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 28C271DB803E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:29:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A7EB01DB8043
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:29:04 +0900 (JST)
Date: Tue, 13 Mar 2012 15:27:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 03/13] memcg: Uncharge all kmem when deleting a
 cgroup.
Message-Id: <20120313152718.a5d2fff3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1331325556-16447-4-git-send-email-ssouhlal@FreeBSD.org>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	<1331325556-16447-4-git-send-email-ssouhlal@FreeBSD.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, glommer@parallels.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On Fri,  9 Mar 2012 12:39:06 -0800
Suleiman Souhlal <ssouhlal@FreeBSD.org> wrote:

> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
> ---
>  mm/memcontrol.c |   31 ++++++++++++++++++++++++++++++-
>  1 files changed, 30 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e6fd558..6fbb438 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -382,6 +382,7 @@ static void mem_cgroup_get(struct mem_cgroup *memcg);
>  static void mem_cgroup_put(struct mem_cgroup *memcg);
>  static void memcg_kmem_init(struct mem_cgroup *memcg,
>      struct mem_cgroup *parent);
> +static void memcg_kmem_move(struct mem_cgroup *memcg);
>  
>  static inline bool
>  mem_cgroup_test_flag(const struct mem_cgroup *memcg, enum memcg_flags flag)
> @@ -3700,6 +3701,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
>  	int ret;
>  	int node, zid, shrink;
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	unsigned long usage;
>  	struct cgroup *cgrp = memcg->css.cgroup;
>  
>  	css_get(&memcg->css);
> @@ -3719,6 +3721,8 @@ move_account:
>  		/* This is for making all *used* pages to be on LRU. */
>  		lru_add_drain_all();
>  		drain_all_stock_sync(memcg);
> +		if (!free_all)
> +			memcg_kmem_move(memcg);
>  		ret = 0;
>  		mem_cgroup_start_move(memcg);
>  		for_each_node_state(node, N_HIGH_MEMORY) {
> @@ -3740,8 +3744,14 @@ move_account:
>  		if (ret == -ENOMEM)
>  			goto try_to_free;
>  		cond_resched();
> +		usage = memcg->res.usage;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +		if (free_all && !mem_cgroup_test_flag(memcg,
> +		    MEMCG_INDEPENDENT_KMEM_LIMIT))
> +			usage -= memcg->kmem.usage;
> +#endif
>  	/* "ret" should also be checked to ensure all lists are empty. */
> -	} while (memcg->res.usage > 0 || ret);
> +	} while (usage > 0 || ret);
>  out:
>  	css_put(&memcg->css);
>  	return ret;
> @@ -5689,9 +5699,28 @@ memcg_kmem_init(struct mem_cgroup *memcg, struct mem_cgroup *parent)
>  		parent_res = &parent->kmem;
>  	res_counter_init(&memcg->kmem, parent_res);
>  }
> +
> +static void
> +memcg_kmem_move(struct mem_cgroup *memcg)

the function name says 'move' but the code seems just do 'forget'
or 'leak'...


> +{
> +	unsigned long flags;
> +	long kmem;
> +
> +	spin_lock_irqsave(&memcg->kmem.lock, flags);
> +	kmem = memcg->kmem.usage;
> +	res_counter_uncharge_locked(&memcg->kmem, kmem);
> +	spin_unlock_irqrestore(&memcg->kmem.lock, flags);
> +	if (!mem_cgroup_test_flag(memcg, MEMCG_INDEPENDENT_KMEM_LIMIT))
> +		res_counter_uncharge(&memcg->res, kmem);
> +}

please update memcg->memsw, too.

Thanks,
-Kame



>  #else /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>  static void
>  memcg_kmem_init(struct mem_cgroup *memcg, struct mem_cgroup *parent)
>  {
>  }
> +
> +static void
> +memcg_kmem_move(struct mem_cgroup *memcg)
> +{
> +}
>  #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> -- 
> 1.7.7.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
