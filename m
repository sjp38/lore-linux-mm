Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8196B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 04:05:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v11so9081946wri.13
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 01:05:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b55si1604940wrb.523.2018.04.03.01.05.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 01:05:05 -0700 (PDT)
Date: Tue, 3 Apr 2018 10:05:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: avoid the unnecessary waiting when force empty a
 cgroup
Message-ID: <20180403080503.GE5501@dhcp22.suse.cz>
References: <1522739529-5602-1-git-send-email-lirongqing@baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522739529-5602-1-git-send-email-lirongqing@baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <lirongqing@baidu.com>
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 03-04-18 15:12:09, Li RongQing wrote:
> The number of writeback and dirty page can be read out from memcg,
> the unnecessary waiting can be avoided by these counts

This changelog doesn't explain the problem and how the patch fixes it.
Why do wee another throttling when we do already throttle in the reclaim
path?

> Signed-off-by: Li RongQing <lirongqing@baidu.com>
> ---
>  mm/memcontrol.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9ec024b862ac..5258651bd4ec 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2613,9 +2613,13 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>  		progress = try_to_free_mem_cgroup_pages(memcg, 1,
>  							GFP_KERNEL, true);
>  		if (!progress) {
> +			unsigned long num;
> +
> +			num = memcg_page_state(memcg, NR_WRITEBACK) +
> +					memcg_page_state(memcg, NR_FILE_DIRTY);
>  			nr_retries--;
> -			/* maybe some writeback is necessary */
> -			congestion_wait(BLK_RW_ASYNC, HZ/10);
> +			if (num)
> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
>  		}
>  
>  	}
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs
