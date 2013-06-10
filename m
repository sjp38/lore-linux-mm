Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 19E046B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 11:13:01 -0400 (EDT)
Date: Mon, 10 Jun 2013 17:12:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: event control at vmpressure.
Message-ID: <20130610151258.GA14295@dhcp22.suse.cz>
References: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, Anton Vorontsov <anton.vorontsov@linaro.org>

[Let's CC Anton]

On Mon 10-06-13 20:14:13, Hyunhee Kim wrote:
> In vmpressure, events are sent to the user space continuously
> until the memory state changes. This becomes overheads for user space module
> and also consumes power consumption. So, with this patch, vmpressure
> remembers
> the current level and only sends the event only when new memory state is
> different from the current level.
> 
> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  include/linux/vmpressure.h |    2 ++
>  mm/vmpressure.c            |    4 +++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
> index 76be077..fa0c0d2 100644
> --- a/include/linux/vmpressure.h
> +++ b/include/linux/vmpressure.h
> @@ -20,6 +20,8 @@ struct vmpressure {
>  	struct mutex events_lock;
>  
>  	struct work_struct work;
> +
> +	int current_level;
>  };
>  
>  struct mem_cgroup;
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 736a601..5f6609c 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -152,9 +152,10 @@ static bool vmpressure_event(struct vmpressure *vmpr,
>  	mutex_lock(&vmpr->events_lock);
>  
>  	list_for_each_entry(ev, &vmpr->events, node) {
> -		if (level >= ev->level) {
> +		if (level >= ev->level && level != vmpr->current_level) {
>  			eventfd_signal(ev->efd, 1);
>  			signalled = true;
> +			vmpr->current_level = level;

This would mean that you send a signal for, say, VMPRESSURE_LOW, then
the reclaim finishes and two days later when you hit the reclaim again
you would simply miss the event, right?

So, unless I am missing something, then this is plain wrong. If you are
worried about too many events then a time based throttling should be
implemented.

>  		}
>  	}
>  
> @@ -371,4 +372,5 @@ void vmpressure_init(struct vmpressure *vmpr)
>  	mutex_init(&vmpr->events_lock);
>  	INIT_LIST_HEAD(&vmpr->events);
>  	INIT_WORK(&vmpr->work, vmpressure_work_fn);
> +	vmpr->current_level = -1;
>  }
> -- 
> 1.7.9.5
> 
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
