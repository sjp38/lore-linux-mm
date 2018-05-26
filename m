Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5521F6B0003
	for <linux-mm@kvack.org>; Sat, 26 May 2018 14:51:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q3-v6so6767056wrm.8
        for <linux-mm@kvack.org>; Sat, 26 May 2018 11:51:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s74-v6sor4374450lfg.109.2018.05.26.11.51.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 11:51:48 -0700 (PDT)
Date: Sat, 26 May 2018 21:51:44 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] memcg: force charge kmem counter too
Message-ID: <20180526185144.xvh7ejlyelzvqwdb@esperanza>
References: <20180525185501.82098-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525185501.82098-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, May 25, 2018 at 11:55:01AM -0700, Shakeel Butt wrote:
> Based on several conditions the kernel can decide to force charge an
> allocation for a memcg i.e. overcharge memcg->memory and memcg->memsw
> counters. Do the same for memcg->kmem counter too. In cgroup-v1, this
> bug can cause a __GFP_NOFAIL kmem allocation fail if an explicit limit
> on kmem counter is set and reached.

memory.kmem.limit is broken and unlikely to ever be fixed as this knob
was deprecated in cgroup-v2. The fact that hitting the limit doesn't
trigger reclaim can result in unexpected behavior from user's pov, like
getting ENOMEM while listing a directory. Bypassing the limit for NOFAIL
allocations isn't going to fix those problem. So I'd suggest to avoid
setting memory.kmem.limit instead of trying to fix it or, even better,
switch to cgroup-v2.

> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  mm/memcontrol.c | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ab5673dbfc4e..0a88f824c550 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1893,6 +1893,18 @@ void mem_cgroup_handle_over_high(void)
>  	current->memcg_nr_pages_over_high = 0;
>  }
>  
> +/*
> + * Based on try_charge() force charge conditions.
> + */
> +static inline bool should_force_charge(gfp_t gfp_mask)
> +{
> +	return (unlikely(tsk_is_oom_victim(current) ||
> +			 fatal_signal_pending(current) ||
> +			 current->flags & PF_EXITING ||
> +			 current->flags & PF_MEMALLOC ||
> +			 gfp_mask & __GFP_NOFAIL));
> +}
> +
>  static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  		      unsigned int nr_pages)
>  {
> @@ -2008,6 +2020,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * The allocation either can't fail or will lead to more memory
>  	 * being freed very soon.  Allow memory usage go over the limit
>  	 * temporarily by force charging it.
> +	 *
> +	 * NOTE: Please keep the should_force_charge() conditions in sync.
>  	 */
>  	page_counter_charge(&memcg->memory, nr_pages);
>  	if (do_memsw_account())
> @@ -2331,8 +2345,11 @@ int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
>  
>  	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
>  	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
> -		cancel_charge(memcg, nr_pages);
> -		return -ENOMEM;
> +		if (!should_force_charge(gfp)) {
> +			cancel_charge(memcg, nr_pages);
> +			return -ENOMEM;
> +		}
> +		page_counter_charge(&memcg->kmem, nr_pages);
>  	}
>  
>  	page->mem_cgroup = memcg;
