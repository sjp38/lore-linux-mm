Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2E316B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 04:19:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k15so15537643wmh.3
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 01:19:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l26si22625601edf.189.2017.06.02.01.18.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 01:18:59 -0700 (PDT)
Date: Fri, 2 Jun 2017 10:18:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] swap: cond_resched in swap_cgroup_prepare()
Message-ID: <20170602081855.GE29840@dhcp22.suse.cz>
References: <20170601195635.20744-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601195635.20744-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 01-06-17 12:56:35, Yu Zhao wrote:
> Saw need_resched() warnings when swapping on large swapfile (TBs)
> because page allocation in swap_cgroup_prepare() took too long.

Hmm, but the page allocator makes sure to cond_resched for sleeping
allocations. I guess what you mean is something different. It is not the
allocation which took too look but there are too many of them and none
of them sleeps because there is enough memory and the allocator doesn't
sleep in that case. Right?

> We already cond_resched when freeing page in swap_cgroup_swapoff().
> Do the same for the page allocation.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>

The patch itself makes sense to me, the changelog could see some
clarification but other than that
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/swap_cgroup.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
> index ac6318a064d3..3405b4ee1757 100644
> --- a/mm/swap_cgroup.c
> +++ b/mm/swap_cgroup.c
> @@ -48,6 +48,9 @@ static int swap_cgroup_prepare(int type)
>  		if (!page)
>  			goto not_enough_page;
>  		ctrl->map[idx] = page;
> +
> +		if (!(idx % SWAP_CLUSTER_MAX))
> +			cond_resched();
>  	}
>  	return 0;
>  not_enough_page:
> -- 
> 2.13.0.219.gdb65acc882-goog

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
