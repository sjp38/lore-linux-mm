Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 878366B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 11:39:01 -0500 (EST)
Received: by wmec201 with SMTP id c201so34800661wme.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:39:01 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id pm2si20433189wjb.168.2015.11.24.08.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 08:39:00 -0800 (PST)
Received: by wmvv187 with SMTP id v187so218412095wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:39:00 -0800 (PST)
Date: Tue, 24 Nov 2015 17:38:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: fix memory.high target
Message-ID: <20151124163857.GL29472@dhcp22.suse.cz>
References: <1448281351-15103-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448281351-15103-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 23-11-15 15:22:31, Vladimir Davydov wrote:
> When the memory.high threshold is exceeded, try_charge() schedules a
> task_work to reclaim the excess. The reclaim target is set to the number
> of pages requested by try_charge(). This is wrong, because try_charge()
> usually charges more pages than requested (batch > nr_pages) in order to
> refill per cpu stocks. As a result, a process in a cgroup can easily
> exceed memory.high significantly when doing a lot of charges w/o
> returning to userspace (e.g. reading a file in big chunks).
> 
> Fix this issue by assuring that when exceeding memory.high a process
> reclaims as many pages as were actually charged (i.e. batch).

Good point. This will not affect the single page load because the
reclaim is done in SWAP_CLUSTER_MAX chunks anyway.

> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 648cc9f02437..06c476ab0f2c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2133,7 +2133,7 @@ done_restock:
>  	 */
>  	do {
>  		if (page_counter_read(&memcg->memory) > memcg->high) {
> -			current->memcg_nr_pages_over_high += nr_pages;
> +			current->memcg_nr_pages_over_high += batch;
>  			set_notify_resume(current);
>  			break;
>  		}
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
