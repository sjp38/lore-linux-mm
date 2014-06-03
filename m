Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 50AD46B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 09:22:59 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id q58so6778393wes.39
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 06:22:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wt5si32380843wjb.61.2014.06.03.06.22.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 06:22:58 -0700 (PDT)
Date: Tue, 3 Jun 2014 15:22:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 05/10] mm: memcontrol: catch root bypass in move precharge
Message-ID: <20140603132255.GJ1321@dhcp22.suse.cz>
References: <1401380162-24121-1-git-send-email-hannes@cmpxchg.org>
 <1401380162-24121-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401380162-24121-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 29-05-14 12:15:57, Johannes Weiner wrote:
> When mem_cgroup_try_charge() returns -EINTR, it bypassed the charge to
> the root memcg.  But move precharging does not catch this and treats
> this case as if no charge had happened, thus leaking a charge against
> root.  Because of an old optimization, the root memcg's res_counter is
> not actually charged right now, but it's still an imbalance and
> subsequent patches will charge the root memcg again.
> 
> Catch those bypasses to the root memcg and properly cancel them before
> giving up the move.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8957d6c945b8..184e67cce4e4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6485,8 +6485,15 @@ one_by_one:
>  			cond_resched();
>  		}
>  		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
> +		/*
> +		 * In case of failure, any residual charges against
> +		 * mc.to will be dropped by mem_cgroup_clear_mc()
> +		 * later on.  However, cancel any charges that are
> +		 * bypassed to root right away or they'll be lost.
> +		 */
> +		if (ret == -EINTR)
> +			__mem_cgroup_cancel_charge(root_mem_cgroup, 1);
>  		if (ret)
> -			/* mem_cgroup_clear_mc() will do uncharge later */
>  			return ret;
>  		mc.precharge++;
>  	}
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
