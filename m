Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3E06B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 09:20:49 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id cc10so6526568wib.4
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 06:20:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr5si32317572wjc.118.2014.06.03.06.20.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 06:20:43 -0700 (PDT)
Date: Tue, 3 Jun 2014 15:20:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/10] mm: memcontrol: retry reclaim for oom-disabled and
 __GFP_NOFAIL charges
Message-ID: <20140603132029.GI1321@dhcp22.suse.cz>
References: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
 <1401380162-24121-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401380162-24121-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 29-05-14 12:15:55, Johannes Weiner wrote:
> There is no reason why oom-disabled and __GFP_NOFAIL charges should
> try to reclaim only once when every other charge tries several times
> before giving up.  Make them all retry the same number of times.

I have mentioned that already with the last iteration of the patch.
This can make THP charges stall unnecessarily when the allocation could
fall back to single page charges.
MEM_CGROUP_RECLAIM_RETRIES * SWAP_CLUSTER_MAX + CHARGE_BATCH * CPUS
reclaimed pages will not help for huge pages so multiple reclaims is
just pointless waisting of time.

I think you should just move the next patch in the series up and simply make
the thp charge __GFP_NORETRY:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b3a6deed66d5..ba822c27a55b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3703,10 +3703,13 @@ int mem_cgroup_charge_anon(struct page *page,
 		nr_pages <<= compound_order(page);
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/*
-		 * Never OOM-kill a process for a huge page.  The
-		 * fault handler will fall back to regular pages.
+		 * Never OOM-kill a process for a huge page. Also do not
+		 * reclaim memcg too much because it wouldn't help the
+		 * huge page charge anyway.
+		 * The fault handler will fall back to regular pages.
 		 */
 		oom = false;
+		gfp_mask |= __GFP_NORETRY;
 	}
 
 	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages, oom);


> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 46b3e37542ad..e8d5075c081f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2567,7 +2567,7 @@ static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
>  				 bool oom)
>  {
>  	unsigned int batch = max(CHARGE_BATCH, nr_pages);
> -	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  	struct mem_cgroup *mem_over_limit;
>  	struct res_counter *fail_res;
>  	unsigned long nr_reclaimed;
> @@ -2639,6 +2639,9 @@ retry:
>  	if (mem_cgroup_wait_acct_move(mem_over_limit))
>  		goto retry;
>  
> +	if (nr_retries--)
> +		goto retry;
> +
>  	if (gfp_mask & __GFP_NOFAIL)
>  		goto bypass;
>  
> @@ -2648,9 +2651,6 @@ retry:
>  	if (!oom)
>  		goto nomem;
>  
> -	if (nr_oom_retries--)
> -		goto retry;
> -
>  	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
>  nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
> -- 
> 1.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
