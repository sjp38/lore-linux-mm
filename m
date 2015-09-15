Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 15E1F6B0255
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 09:56:26 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so30361123wic.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:56:25 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id lk14si24565957wic.120.2015.09.15.06.56.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 06:56:24 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so30106043wic.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:56:24 -0700 (PDT)
Date: Tue, 15 Sep 2015 15:56:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix order calculation in try_charge()
Message-ID: <20150915135623.GA26649@dhcp22.suse.cz>
References: <1442318757-7141-1-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442318757-7141-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 15-09-15 14:05:57, Jerome Marchand wrote:
> Since commit <6539cc05386> (mm: memcontrol: fold mem_cgroup_do_charge()),
> the order to pass to mem_cgroup_oom() is calculated by passing the number
> of pages to get_order() instead of the expected  size in bytes. AFAICT,
> it only affects the value displayed in the oom warning message.
> This patch fix this.

We haven't noticed that just because the OOM is enabled only for page
faults of order-0 (single page) and get_order work just fine. Thanks for
noticing this. If we ever start triggering OOM on different orders this
would be broken.
 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Btw. a quick git grep shows that at least gart_iommu_init is using
number of pages as well. I haven't checked it does that intentionally,
though.

Thanks!

> ---
>  mm/memcontrol.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1742a2d..91bf094 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2032,7 +2032,8 @@ retry:
>  
>  	mem_cgroup_events(mem_over_limit, MEMCG_OOM, 1);
>  
> -	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(nr_pages));
> +	mem_cgroup_oom(mem_over_limit, gfp_mask,
> +		       get_order(nr_pages * PAGE_SIZE));
>  nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
>  		return -ENOMEM;
> -- 
> 1.9.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
