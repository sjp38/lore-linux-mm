Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6644D6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 12:27:51 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so7209467wib.3
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:27:50 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id ck20si24953124wjb.112.2014.06.17.09.27.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 09:27:50 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so6153406wib.15
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:27:49 -0700 (PDT)
Date: Tue, 17 Jun 2014 18:27:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/12] mm: huge_memory: use GFP_TRANSHUGE when charging
 huge pages
Message-ID: <20140617162747.GB9572@dhcp22.suse.cz>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <1402948472-8175-4-git-send-email-hannes@cmpxchg.org>
 <20140617142317.GD19886@dhcp22.suse.cz>
 <20140617153814.GB7331@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140617153814.GB7331@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 17-06-14 11:38:14, Johannes Weiner wrote:
> On Tue, Jun 17, 2014 at 04:23:17PM +0200, Michal Hocko wrote:
[...]
> > @@ -2647,7 +2645,7 @@ retry:
> >  	if (fatal_signal_pending(current))
> >  		goto bypass;
> >  
> > -	if (!oom)
> > +	if (!oom_gfp_allowed(gfp_mask))
> >  		goto nomem;
> 
> We don't actually need that check: if __GFP_NORETRY is set, we goto
> nomem directly after reclaim fails and don't even reach here.

I meant it for further robustness. If we ever change oom_gfp_allowed in
future and have new and unexpected users then we should back off.  Or
maybe WARN_ON(!oom_gfp_allowed(gfp_mask)) would be more appropriate to
catch those and fix the charging code or the charger?

> So here is the patch I have now - can I get your sign-off on this?

Sure. Thanks!

> ---
> From eda800d2aa2376d347d6d4f7660e3450bd4c5dbb Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Tue, 17 Jun 2014 11:10:59 -0400
> Subject: [patch] mm: memcontrol: remove explicit OOM parameter in charge path
> 
> For the page allocator, __GFP_NORETRY implies that no OOM should be
> triggered, whereas memcg has an explicit parameter to disable OOM.
> 
> The only callsites that want OOM disabled are THP charges and charge
> moving.  THP already uses __GFP_NORETRY and charge moving can use it
> as well - one full reclaim cycle should be plenty.  Switch it over,
> then remove the OOM parameter.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Signed-off-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 32 ++++++++++----------------------
>  1 file changed, 10 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9c646b9b56f4..c765125694e2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2555,15 +2555,13 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>   * mem_cgroup_try_charge - try charging a memcg
>   * @memcg: memcg to charge
>   * @nr_pages: number of pages to charge
> - * @oom: trigger OOM if reclaim fails
>   *
>   * Returns 0 if @memcg was charged successfully, -EINTR if the charge
>   * was bypassed to root_mem_cgroup, and -ENOMEM if the charge failed.
>   */
>  static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
>  				 gfp_t gfp_mask,
> -				 unsigned int nr_pages,
> -				 bool oom)
> +				 unsigned int nr_pages)
>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> @@ -2647,9 +2645,6 @@ retry:
>  	if (fatal_signal_pending(current))
>  		goto bypass;
>  
> -	if (!oom)
> -		goto nomem;
> -
>  	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
>  nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
> @@ -2675,15 +2670,14 @@ done:
>   */
>  static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
>  				 gfp_t gfp_mask,
> -				 unsigned int nr_pages,
> -				 bool oom)
> +				 unsigned int nr_pages)
>  
>  {
>  	struct mem_cgroup *memcg;
>  	int ret;
>  
>  	memcg = get_mem_cgroup_from_mm(mm);
> -	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages, oom);
> +	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages);
>  	css_put(&memcg->css);
>  	if (ret == -EINTR)
>  		memcg = root_mem_cgroup;
> @@ -2900,8 +2894,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>  	if (ret)
>  		return ret;
>  
> -	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT,
> -				    oom_gfp_allowed(gfp));
> +	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT);
>  	if (ret == -EINTR)  {
>  		/*
>  		 * mem_cgroup_try_charge() chosed to bypass to root due to
> @@ -3650,7 +3643,6 @@ int mem_cgroup_charge_anon(struct page *page,
>  {
>  	unsigned int nr_pages = 1;
>  	struct mem_cgroup *memcg;
> -	bool oom = true;
>  
>  	if (mem_cgroup_disabled())
>  		return 0;
> @@ -3662,14 +3654,9 @@ int mem_cgroup_charge_anon(struct page *page,
>  	if (PageTransHuge(page)) {
>  		nr_pages <<= compound_order(page);
>  		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> -		/*
> -		 * Never OOM-kill a process for a huge page.  The
> -		 * fault handler will fall back to regular pages.
> -		 */
> -		oom = false;
>  	}
>  
> -	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages, oom);
> +	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages);
>  	if (!memcg)
>  		return -ENOMEM;
>  	__mem_cgroup_commit_charge(memcg, page, nr_pages,
> @@ -3706,7 +3693,7 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  		memcg = try_get_mem_cgroup_from_page(page);
>  	if (!memcg)
>  		memcg = get_mem_cgroup_from_mm(mm);
> -	ret = mem_cgroup_try_charge(memcg, mask, 1, true);
> +	ret = mem_cgroup_try_charge(memcg, mask, 1);
>  	css_put(&memcg->css);
>  	if (ret == -EINTR)
>  		memcg = root_mem_cgroup;
> @@ -3733,7 +3720,7 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
>  	if (!PageSwapCache(page)) {
>  		struct mem_cgroup *memcg;
>  
> -		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
> +		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1);
>  		if (!memcg)
>  			return -ENOMEM;
>  		*memcgp = memcg;
> @@ -3802,7 +3789,7 @@ int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
>  		return 0;
>  	}
>  
> -	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
> +	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1);
>  	if (!memcg)
>  		return -ENOMEM;
>  	__mem_cgroup_commit_charge(memcg, page, 1, type, false);
> @@ -6414,7 +6401,8 @@ one_by_one:
>  			batch_count = PRECHARGE_COUNT_AT_ONCE;
>  			cond_resched();
>  		}
> -		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
> +		ret = mem_cgroup_try_charge(memcg,
> +					    GFP_KERNEL & ~__GFP_NORETRY, 1);
>  		if (ret)
>  			/* mem_cgroup_clear_mc() will do uncharge later */
>  			return ret;
> -- 
> 2.0.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
