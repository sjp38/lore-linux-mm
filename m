Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54C02828E4
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 03:49:16 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m101so216153864ioi.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 00:49:16 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id g134si9012253wme.1.2016.07.22.00.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 00:49:15 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so4925176wme.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 00:49:15 -0700 (PDT)
Date: Fri, 22 Jul 2016 09:49:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] update sc->nr_reclaimed after each shrink_slab
Message-ID: <20160722074913.GD794@dhcp22.suse.cz>
References: <1469159010-5636-1-git-send-email-zhouchengming1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469159010-5636-1-git-send-email-zhouchengming1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhou Chengming <zhouchengming1@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, riel@redhat.com, guohanjun@huawei.com

On Fri 22-07-16 11:43:30, Zhou Chengming wrote:
> In !global_reclaim(sc) case, we should update sc->nr_reclaimed after each
> shrink_slab in the loop. Because we need the correct sc->nr_reclaimed
> value to see if we can break out.

Does this actually change anything? Maybe I am missing something but
try_to_free_mem_cgroup_pages which is the main entry for the memcg
reclaim doesn't set reclaim_state. I don't remember why... Vladimir?

Have you observed any issues and this patch fixes it or this is just
motivated by the code inspection?

> Signed-off-by: Zhou Chengming <zhouchengming1@huawei.com>
> ---
>  mm/vmscan.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c4a2f45..47133c3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2405,6 +2405,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  					    memcg, sc->nr_scanned - scanned,
>  					    lru_pages);
>  
> +			if (!global_reclaim(sc) && reclaim_state) {
> +				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> +				reclaim_state->reclaimed_slab = 0;
> +			}
> +
>  			/* Record the group's reclaim efficiency */
>  			vmpressure(sc->gfp_mask, memcg, false,
>  				   sc->nr_scanned - scanned,
> -- 
> 1.7.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
