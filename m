Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A073C8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:59:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 39so1747653edq.13
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 06:59:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18-v6si26821ejp.285.2019.01.08.06.59.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 06:59:44 -0800 (PST)
Date: Tue, 8 Jan 2019 15:59:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: schedule high reclaim for remote memcgs on
 high_work
Message-ID: <20190108145942.GZ31793@dhcp22.suse.cz>
References: <20190103015638.205424-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103015638.205424-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 02-01-19 17:56:38, Shakeel Butt wrote:
> If a memcg is over high limit, memory reclaim is scheduled to run on
> return-to-userland. However it is assumed that the memcg is the current
> process's memcg. With remote memcg charging for kmem or swapping in a
> page charged to remote memcg, current process can trigger reclaim on
> remote memcg. So, schduling reclaim on return-to-userland for remote
> memcgs will ignore the high reclaim altogether. So, punt the high
> reclaim of remote memcgs to high_work.

Have you seen this happening in real life workloads? And is this
offloading what we really want to do? I mean it is clearly the current
task that has triggered the remote charge so why should we offload that
work to a system? Is there any reason we cannot reclaim on the remote
memcg from the return-to-userland path?

> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  mm/memcontrol.c | 20 ++++++++++++--------
>  1 file changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e9db1160ccbc..47439c84667a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2302,19 +2302,23 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * reclaim on returning to userland.  We can perform reclaim here
>  	 * if __GFP_RECLAIM but let's always punt for simplicity and so that
>  	 * GFP_KERNEL can consistently be used during reclaim.  @memcg is
> -	 * not recorded as it most likely matches current's and won't
> -	 * change in the meantime.  As high limit is checked again before
> -	 * reclaim, the cost of mismatch is negligible.
> +	 * not recorded as the return-to-userland high reclaim will only reclaim
> +	 * from current's memcg (or its ancestor). For other memcgs we punt them
> +	 * to work queue.
>  	 */
>  	do {
>  		if (page_counter_read(&memcg->memory) > memcg->high) {
> -			/* Don't bother a random interrupted task */
> -			if (in_interrupt()) {
> +			/*
> +			 * Don't bother a random interrupted task or if the
> +			 * memcg is not current's memcg's ancestor.
> +			 */
> +			if (in_interrupt() ||
> +			    !mm_match_cgroup(current->mm, memcg)) {
>  				schedule_work(&memcg->high_work);
> -				break;
> +			} else {
> +				current->memcg_nr_pages_over_high += batch;
> +				set_notify_resume(current);
>  			}
> -			current->memcg_nr_pages_over_high += batch;
> -			set_notify_resume(current);
>  			break;
>  		}
>  	} while ((memcg = parent_mem_cgroup(memcg)));
> -- 
> 2.20.1.415.g653613c723-goog
> 

-- 
Michal Hocko
SUSE Labs
