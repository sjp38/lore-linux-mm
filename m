Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 3DDD76B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 12:12:58 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so9443132pab.36
        for <linux-mm@kvack.org>; Wed, 11 Sep 2013 09:12:57 -0700 (PDT)
Date: Wed, 11 Sep 2013 09:12:54 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
Message-ID: <20130911161254.GA17081@teo>
References: <alpine.LNX.2.00.1309062254470.11420@eggly.anvils>
 <20130909110847.GB18056@dhcp22.suse.cz>
 <20130911154057.GA16765@teo>
 <20130911160357.GA32273@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130911160357.GA32273@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 11, 2013 at 06:03:57PM +0200, Michal Hocko wrote:
> The patch below. I find it little bit nicer than Hugh's original one
> because having the two checks sounds more confusing.
> What do you think Hugh, Anton?

Acked-by: Anton Vorontsov <anton@enomsg.org>

Thanks!

> ---
> From 888745909da34f8aee8a208a82d467236b828d0d Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 11 Sep 2013 17:48:10 +0200
> Subject: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
> 
> Hugh Dickins has reported a division by 0 when a vmpressure event is
> processed. The reason for the exception is that a single vmpressure
> work item (which is per memcg) might be processed by multiple CPUs
> because it is enqueued on system_wq which is !WQ_NON_REENTRANT.
> This means that the out of lock vmpr->scanned check in
> vmpressure_work_fn is inherently racy and the racing workers will see
> already zeroed scanned value after they manage to take the spin lock.
> 
> The patch simply moves the vmp->scanned check inside the sr_lock to fix
> the race.
> 
> The issue was there since the very beginning but "vmpressure: change
> vmpressure::sr_lock to spinlock" might have made it more visible as the
> racing workers would sleep on the mutex and give it more time to see
> updated value. The issue was still there, though.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: stable@vger.kernel.org
> ---
>  mm/vmpressure.c |   17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index e0f6283..ad679a0 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -164,18 +164,19 @@ static void vmpressure_work_fn(struct work_struct *work)
>  	unsigned long scanned;
>  	unsigned long reclaimed;
>  
> +	spin_lock(&vmpr->sr_lock);
> +
>  	/*
> -	 * Several contexts might be calling vmpressure(), so it is
> -	 * possible that the work was rescheduled again before the old
> -	 * work context cleared the counters. In that case we will run
> -	 * just after the old work returns, but then scanned might be zero
> -	 * here. No need for any locks here since we don't care if
> -	 * vmpr->reclaimed is in sync.
> +	 * Several contexts might be calling vmpressure() and the work
> +	 * item is sitting on !WQ_NON_REENTRANT workqueue so different
> +	 * CPUs might execute it concurrently. Bail out if the scanned
> +	 * counter is already 0 because all the work has been done already.
>  	 */
> -	if (!vmpr->scanned)
> +	if (!vmpr->scanned) {
> +		spin_unlock(&vmpr->sr_lock);
>  		return;
> +	}
>  
> -	spin_lock(&vmpr->sr_lock);
>  	scanned = vmpr->scanned;
>  	reclaimed = vmpr->reclaimed;
>  	vmpr->scanned = 0;
> -- 
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
