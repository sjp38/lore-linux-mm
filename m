Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC8296B0269
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:48:02 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id b141-v6so9738718ywh.12
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:48:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 128-v6sor3426219ybv.107.2018.07.31.10.47.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 10:47:56 -0700 (PDT)
Date: Tue, 31 Jul 2018 13:50:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: terminate the reclaim early when direct reclaiming
Message-ID: <20180731175050.GA31657@cmpxchg.org>
References: <1533035368-30911-1-git-send-email-zhaoyang.huang@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533035368-30911-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org

On Tue, Jul 31, 2018 at 07:09:28PM +0800, Zhaoyang Huang wrote:
> This patch try to let the direct reclaim finish earlier than it used
> to be. The problem comes from We observing that the direct reclaim
> took a long time to finish when memcg is enabled. By debugging, we
> find that the reason is the softlimit is too low to meet the loop
> end criteria. So we add two barriers to judge if it has reclaimed
> enough memory as same criteria as it is in shrink_lruvec:
> 1. for each memcg softlimit reclaim.
> 2. before starting the global reclaim in shrink_zone.
> 
> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
> ---
>  include/linux/memcontrol.h |  3 ++-
>  mm/memcontrol.c            |  3 +++
>  mm/vmscan.c                | 38 +++++++++++++++++++++++++++++++++++++-
>  3 files changed, 42 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6c6fb11..a7e82c7 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -325,7 +325,8 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
>  void mem_cgroup_uncharge_list(struct list_head *page_list);
>  
>  void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
> -
> +bool direct_reclaim_reach_watermark(pg_data_t *pgdat, unsigned long nr_reclaimed,
> +			unsigned long nr_scanned, gfp_t gfp_mask, int order);
>  static struct mem_cgroup_per_node *
>  mem_cgroup_nodeinfo(struct mem_cgroup *memcg, int nid)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8c0280b..e4efd46 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2577,6 +2577,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
>  			(next_mz == NULL ||
>  			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
>  			break;
> +		if (direct_reclaim_reach_watermark(pgdat, nr_reclaimed,
> +					*total_scanned, gfp_mask, order))
> +			break;
>  	} while (!nr_reclaimed);
>  	if (next_mz)
>  		css_put(&next_mz->memcg->css);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 03822f8..19503f3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2518,6 +2518,34 @@ static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
>  		(memcg && memcg_congested(pgdat, memcg));
>  }
>  
> +bool direct_reclaim_reach_watermark(pg_data_t *pgdat, unsigned long nr_reclaimed,
> +		unsigned long nr_scanned, gfp_t gfp_mask,
> +		int order)
> +{
> +	struct scan_control sc = {
> +		.gfp_mask = gfp_mask,
> +		.order = order,
> +		.priority = DEF_PRIORITY,
> +		.nr_reclaimed = nr_reclaimed,
> +		.nr_scanned = nr_scanned,
> +	};
> +	if (!current_is_kswapd())
> +		return false;
> +	if (!IS_ENABLED(CONFIG_COMPACTION))
> +		return false;
> +	/*
> +	 * In fact, we add 1 to nr_reclaimed and nr_scanned to let should_continue_reclaim
> +	 * NOT return by finding they are zero, which means compaction_suitable()
> +	 * takes effect here to judge if we have reclaimed enough pages for passing
> +	 * the watermark and no necessary to check other memcg anymore.
> +	 */
> +	if (!should_continue_reclaim(pgdat,
> +				sc.nr_reclaimed + 1, sc.nr_scanned + 1, &sc))
> +		return true;

As per the previous submission, should_continue_reclaim() is really
not an appropriate function to use. It's for the compaction policy.
You might be able to hack around it with faking the reclaim progress,
but this will fail in subtle ways when people change the compaction
policy in that function in the future.

If you use it only for the watermark check, check it explicitly.

Other than that, I agree with Michal that we need much more data on
this; what the configuration is like, what the memory situation is
like when your problem happens, how long the stalls are, and how your
patch helps with overreclaim etc.
