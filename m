Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id D1CED6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 12:03:27 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so36536006wiw.2
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:03:27 -0800 (PST)
Received: from mail-we0-x22f.google.com (mail-we0-x22f.google.com. [2a00:1450:400c:c03::22f])
        by mx.google.com with ESMTPS id gh9si33092033wib.92.2015.01.15.09.03.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 09:03:26 -0800 (PST)
Received: by mail-we0-f175.google.com with SMTP id k11so15872596wes.6
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:03:26 -0800 (PST)
Date: Thu, 15 Jan 2015 18:03:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] lowmemorykiller: Avoid excessive/redundant calling of LMK
Message-ID: <20150115170324.GD7008@dhcp22.suse.cz>
References: <1421079554-30899-1-git-send-email-cpandya@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421079554-30899-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Weijie Yang <weijie.yang@samsung.com>, David Rientjes <rientjes@google.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon 12-01-15 21:49:14, Chintan Pandya wrote:
> The global shrinker will invoke lowmem_shrink in a loop.
> The loop will be run (total_scan_pages/batch_size) times.
> The default batch_size will be 128 which will make
> shrinker invoking 100s of times. LMK does meaningful
> work only during first 2-3 times and then rest of the
> invocations are just CPU cycle waste. Fix that by returning
> to the shrinker with SHRINK_STOP when LMK doesn't find any
> more work to do. The deciding factor here is, no process
> found in the selected LMK bucket or memory conditions are
> sane.

lowmemory killer is broken by design and this one of the examples which
shows why. It simply doesn't fit into shrinkers concept.

The count_object callback simply lies and tells the core that all
the reclaimable LRU pages are scanable and gives it this as a number
which the core uses for total_scan. scan_objects callback then happily
ignore nr_to_reclaim and does its one time job where it iterates over
_all_ tasks and picks up the victim and returns its rss as a return
value. This is just a subset of LRU pages of course so it continues
looping until total_scan goes down to 0 finally.

If this really has to be a shrinker then, shouldn't it evaluate the OOM
situation in the count callback and return non zero only if OOM and then
the scan callback would kill and return nr_to_reclaim.

Or even better wouldn't it be much better to use vmpressure to wake
up a kernel module which would simply check the situation and kill
something?

Please do not put only cosmetic changes on top of broken concept and try
to think about a proper solution that is what staging is for AFAIU.

The code is in this state for quite some time and I would really hate if
it got merged just because it is in staging for too long and it is used
out there.

> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
> ---
>  drivers/staging/android/lowmemorykiller.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> index b545d3d..5bf483f 100644
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -110,7 +110,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
>  	if (min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
>  		lowmem_print(5, "lowmem_scan %lu, %x, return 0\n",
>  			     sc->nr_to_scan, sc->gfp_mask);
> -		return 0;
> +		return SHRINK_STOP;
>  	}
>  
>  	selected_oom_score_adj = min_score_adj;
> @@ -163,6 +163,9 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
>  		set_tsk_thread_flag(selected, TIF_MEMDIE);
>  		send_sig(SIGKILL, selected, 0);
>  		rem += selected_tasksize;
> +	} else {
> +		rcu_read_unlock();
> +		return SHRINK_STOP;
>  	}
>  
>  	lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
> -- 
> Chintan Pandya
> 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
