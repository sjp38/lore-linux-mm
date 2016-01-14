Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 400F5828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 09:38:54 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id u188so350355097wmu.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 06:38:54 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id u3si10006332wju.201.2016.01.14.06.38.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 06:38:52 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id f206so434516221wmf.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 06:38:51 -0800 (PST)
Date: Thu, 14 Jan 2016 15:38:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: Only free spare array when readers are done
Message-ID: <20160114143847.GD5046@dhcp22.suse.cz>
References: <001a113abaa499606605294b5b17@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a113abaa499606605294b5b17@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martijn Coenen <maco@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 14-01-16 14:33:52, Martijn Coenen wrote:
> A spare array holding mem cgroup threshold events is kept around
> to make sure we can always safely deregister an event and have an
> array to store the new set of events in.
> 
> In the scenario where we're going from 1 to 0 registered events, the
> pointer to the primary array containing 1 event is copied to the spare
> slot, and then the spare slot is freed because no events are left.
> However, it is freed before calling synchronize_rcu(), which means
> readers may still be accessing threshold->primary after it is freed.

Have you seen this triggering in the real life?

> 
> Fixed by only freeing after synchronize_rcu().
> 

Fixes: 8c7577637ca3 ("memcg: free spare array to avoid memory leak")
> Signed-off-by: Martijn Coenen <maco@google.com>
Cc: stable

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 14cb1db..73228b6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3522,16 +3522,17 @@ static void
> __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
>  swap_buffers:
>  	/* Swap primary and spare array */
>  	thresholds->spare = thresholds->primary;
> -	/* If all events are unregistered, free the spare array */
> -	if (!new) {
> -		kfree(thresholds->spare);
> -		thresholds->spare = NULL;
> -	}
> 
>  	rcu_assign_pointer(thresholds->primary, new);
> 
>  	/* To be sure that nobody uses thresholds */
>  	synchronize_rcu();
> +
> +	/* If all events are unregistered, free the spare array */
> +	if (!new) {
> +		kfree(thresholds->spare);
> +		thresholds->spare = NULL;
> +	}
>  unlock:
>  	mutex_unlock(&memcg->thresholds_lock);
>  }
> -- 
> 2.6.0.rc2.230.g3dd15c0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
