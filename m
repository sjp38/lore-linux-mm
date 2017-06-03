Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A81E6B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 10:58:31 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o139so21068501lfe.15
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 07:58:30 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id h138si15343084lfg.422.2017.06.03.07.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 07:58:29 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id v20so3684967lfa.2
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 07:58:29 -0700 (PDT)
Date: Sat, 3 Jun 2017 17:58:26 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] swap: cond_resched in swap_cgroup_prepare()
Message-ID: <20170603145826.GA15130@esperanza>
References: <20170601195635.20744-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601195635.20744-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 01, 2017 at 12:56:35PM -0700, Yu Zhao wrote:
> Saw need_resched() warnings when swapping on large swapfile (TBs)
> because page allocation in swap_cgroup_prepare() took too long.
> 
> We already cond_resched when freeing page in swap_cgroup_swapoff().
> Do the same for the page allocation.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

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

We should probably do the same on the error path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
