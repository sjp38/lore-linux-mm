Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 29D4C6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 01:24:05 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B074F3EE0AE
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:24:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9802C45DE51
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:24:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 72B2845DE4E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:24:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 644071DB803E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:24:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E1D01DB8040
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:24:03 +0900 (JST)
Date: Wed, 29 Feb 2012 15:22:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/10] memcg: Uncharge all kmem when deleting a cgroup.
Message-Id: <20120229152227.aa416668.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1330383533-20711-3-git-send-email-ssouhlal@FreeBSD.org>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-3-git-send-email-ssouhlal@FreeBSD.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, glommer@parallels.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Mon, 27 Feb 2012 14:58:45 -0800
Suleiman Souhlal <ssouhlal@FreeBSD.org> wrote:

> A later patch will also use this to move the accounting to the root
> cgroup.
> 
> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
> ---
>  mm/memcontrol.c |   30 +++++++++++++++++++++++++++++-
>  1 files changed, 29 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 11e31d6..6f44fcb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -378,6 +378,7 @@ static void mem_cgroup_get(struct mem_cgroup *memcg);
>  static void mem_cgroup_put(struct mem_cgroup *memcg);
>  static void memcg_kmem_init(struct mem_cgroup *memcg,
>      struct mem_cgroup *parent);
> +static void memcg_kmem_move(struct mem_cgroup *memcg);
>  
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> @@ -3674,6 +3675,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
>  	int ret;
>  	int node, zid, shrink;
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	unsigned long usage;
>  	struct cgroup *cgrp = memcg->css.cgroup;
>  
>  	css_get(&memcg->css);
> @@ -3693,6 +3695,8 @@ move_account:
>  		/* This is for making all *used* pages to be on LRU. */
>  		lru_add_drain_all();
>  		drain_all_stock_sync(memcg);
> +		if (!free_all)
> +			memcg_kmem_move(memcg);
>  		ret = 0;
>  		mem_cgroup_start_move(memcg);
>  		for_each_node_state(node, N_HIGH_MEMORY) {
> @@ -3714,8 +3718,13 @@ move_account:
>  		if (ret == -ENOMEM)
>  			goto try_to_free;
>  		cond_resched();
> +		usage = memcg->res.usage;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +		if (free_all && !memcg->independent_kmem_limit)
> +			usage -= memcg->kmem_bytes.usage;
> +#endif

Why we need this even if memcg_kmem_move() does uncharge ?

Thanks,
-Kame

>  	/* "ret" should also be checked to ensure all lists are empty. */
> -	} while (memcg->res.usage > 0 || ret);
> +	} while (usage > 0 || ret);
>  out:
>  	css_put(&memcg->css);
>  	return ret;
> @@ -5632,9 +5641,28 @@ memcg_kmem_init(struct mem_cgroup *memcg, struct mem_cgroup *parent)
>  	res_counter_init(&memcg->kmem_bytes, parent_res);
>  	memcg->independent_kmem_limit = 0;
>  }
> +
> +static void
> +memcg_kmem_move(struct mem_cgroup *memcg)
> +{
> +	unsigned long flags;
> +	long kmem_bytes;
> +
> +	spin_lock_irqsave(&memcg->kmem_bytes.lock, flags);
> +	kmem_bytes = memcg->kmem_bytes.usage;
> +	res_counter_uncharge_locked(&memcg->kmem_bytes, kmem_bytes);
> +	spin_unlock_irqrestore(&memcg->kmem_bytes.lock, flags);
> +	if (!memcg->independent_kmem_limit)
> +		res_counter_uncharge(&memcg->res, kmem_bytes);
> +}
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
