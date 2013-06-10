Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 362C56B0032
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 10:09:42 -0400 (EDT)
Date: Mon, 10 Jun 2013 10:09:39 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] memcg: event control at vmpressure.
Message-ID: <20130610100939.3cb7f89b@redhat.com>
In-Reply-To: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
References: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Mon, 10 Jun 2013 20:14:13 +0900
Hyunhee Kim <hyunhee.kim@samsung.com> wrote:

> In vmpressure, events are sent to the user space continuously
> until the memory state changes. This becomes overheads for user space module
> and also consumes power consumption.

If the kernel is still under memory pressure, I think we do want to keep
sending the event to user-space. At least as a default behavior.

I think it would be fine to implement this change as an additional parameter
when registering for the event, but I also wonder if this shouldn't be
solved by the user-space app itself (eg. rate-limiting the event reception).

> So, with this patch, vmpressure
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
>  		}
>  	}
>  
> @@ -371,4 +372,5 @@ void vmpressure_init(struct vmpressure *vmpr)
>  	mutex_init(&vmpr->events_lock);
>  	INIT_LIST_HEAD(&vmpr->events);
>  	INIT_WORK(&vmpr->work, vmpressure_work_fn);
> +	vmpr->current_level = -1;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
