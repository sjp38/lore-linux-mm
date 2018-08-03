Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1E66B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 02:15:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y17-v6so1457639eds.22
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 23:15:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x26-v6si2305265edx.261.2018.08.02.23.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 23:15:29 -0700 (PDT)
Date: Fri, 3 Aug 2018 08:15:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm:memcg: skip memcg of current in
 mem_cgroup_soft_limit_reclaim
Message-ID: <20180803061527.GA27245@dhcp22.suse.cz>
References: <1533275285-12387-1-git-send-email-zhaoyang.huang@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533275285-12387-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org

On Fri 03-08-18 13:48:05, Zhaoyang Huang wrote:
> for the soft_limit reclaim has more directivity than global reclaim, we
> have current memcg be skipped to avoid potential page thrashing.

a) this changelog doesn't really explain the problem nor does it explain
   why the proposed solution is reasonable or why it works at all and
b) no, this doesn't really work. You could easily break the current soft
   limit semantic.

I understand that you are not really happy about how the soft limit
works. Me neither but this whole interface is a huge mistake of past and
the general recommendation is to not use it. We simply cannot fix it
because it is unfixable. The semantic is just broken and somebody might
really depend on it.

> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
> ---
>  mm/memcontrol.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8c0280b..9d09e95 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2537,12 +2537,21 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
>  			mz = mem_cgroup_largest_soft_limit_node(mctz);
>  		if (!mz)
>  			break;
> -
> +		/*
> +		 * skip current memcg to avoid page thrashing, for the
> +		 * mem_cgroup_soft_reclaim has more directivity than
> +		 * global reclaim.
> +		 */
> +		if (get_mem_cgroup_from_mm(current->mm) == mz->memcg) {
> +			reclaimed = 0;
> +			goto next;
> +		}
>  		nr_scanned = 0;
>  		reclaimed = mem_cgroup_soft_reclaim(mz->memcg, pgdat,
>  						    gfp_mask, &nr_scanned);
>  		nr_reclaimed += reclaimed;
>  		*total_scanned += nr_scanned;
> +next:
>  		spin_lock_irq(&mctz->lock);
>  		__mem_cgroup_remove_exceeded(mz, mctz);
>  
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs
