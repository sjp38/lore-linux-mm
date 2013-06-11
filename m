Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 707576B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 08:59:15 -0400 (EDT)
Date: Tue, 11 Jun 2013 14:59:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: event control at vmpressure.
Message-ID: <20130611125906.GB31277@dhcp22.suse.cz>
References: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
 <20130610151258.GA14295@dhcp22.suse.cz>
 <20130611001747.GA16971@teo>
 <20130611062124.GA24031@dhcp22.suse.cz>
 <002401ce6680$96dee480$c49cad80$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002401ce6680$96dee480$c49cad80$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Tue 11-06-13 17:49:31, Hyunhee Kim wrote:
> In the original vmpressure, event is sent to the user space continuously
> until the memory state changes.

This is not correct AFAIU. Events are sent when the vm_pressure event is
triggered - aka when there is a reclaim activity.

> This becomes overheads to user space module
> and also consumes power consumption.

As Anton already pointed out. If there is nobody to listen then there
are no events triggered in fact so no power consumption should be
increased. If you are under reclaim activity then your system is hardly
idle anyway.

> So, with this patch, vmpressure remembers the current level and only

I guess you meant "remembers the last level"

> sends the event only new memory state is different with the current
> level. This can be set when registering each event by writing a
> trigger option (0 or 1) next to the level.

What does 0 and what does 1 mean? I know I can go and check the code but
the changelog should better tell me without that.

> Change-Id: Ie075b7c510a9cea8c4a092ac4fa4680248139371

Please do not add references to an internal tracking system.

> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> Reviewed-on: http://165.213.202.130:8080/55935
> Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> Tested-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  Documentation/cgroups/memory.txt |   10 ++++++++--
>  include/linux/vmpressure.h       |    2 ++
>  mm/vmpressure.c                  |   35 ++++++++++++++++++++++++++++++-----
>  3 files changed, 40 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt
> b/Documentation/cgroups/memory.txt
> index ddf4f93..cc12aaa 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -791,6 +791,11 @@ way to trigger. Applications should do whatever they
> can to help the
>  system. It might be too late to consult with vmstat or any other
>  statistics, so it's advisable to take an immediate action.
>  
> +Events can be triggered continuously or only when the level changes.
> Trigger
> +option is decided by writing it next to level. If "0", events are sent
> +every time the reclaiming occurs. If "1", events are sent only when the
> level
> +is changed.
> +

The lines seems to be wrapped (maybe your email client does that).

Also what happens when somebody uses an existing application and `0' is
not added? The interface _has_ to be backward compatible. And is the
numberic interface appropriate at all?

>  The events are propagated upward until the event is handled, i.e. the
>  events are not pass-through. Here is what this means: for example you have
>  three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
> @@ -807,7 +812,8 @@ register a notification, an application must:
>  
>  - create an eventfd using eventfd(2);
>  - open memory.pressure_level;
> -- write string like "<event_fd> <fd of memory.pressure_level> <level>"
> +- write string like
> +	"<event_fd> <fd of memory.pressure_level> <level> <trigger_option>"
>    to cgroup.event_control.
>  
>  Application will be notified through eventfd when memory pressure is at
> @@ -823,7 +829,7 @@ Test:
>     # cd /sys/fs/cgroup/memory/
>     # mkdir foo
>     # cd foo
> -   # cgroup_event_listener memory.pressure_level low &
> +   # cgroup_event_listener memory.pressure_level low 0 &
>     # echo 8000000 > memory.limit_in_bytes
>     # echo 8000000 > memory.memsw.limit_in_bytes
>     # echo $$ > tasks
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

The name seems to be really inappropriate. This is the last_level in
fact, isn't it?

>  };
>  
>  struct mem_cgroup;
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 736a601..0ffed76 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -137,6 +137,7 @@ static enum vmpressure_levels
> vmpressure_calc_level(unsigned long scanned,
>  struct vmpressure_event {
>  	struct eventfd_ctx *efd;
>  	enum vmpressure_levels level;
> +	unsigned long edge_trigger;

Unsigned long? Why? level is an int so there is a nice 4B hole between
level and edge_trigger. I would also suggest using something like bool.
Do we have more modes that could be used?

>  	struct list_head node;
>  };
>  
> @@ -153,8 +154,11 @@ static bool vmpressure_event(struct vmpressure *vmpr,
>  
>  	list_for_each_entry(ev, &vmpr->events, node) {
>  		if (level >= ev->level) {
> +			if (ev->edge_trigger && level ==
> vmpr->current_level)

Email client again.
But what confuses me is that the current_level is shared for all events
for the pressure group. Is this correct?

> +				continue;
>  			eventfd_signal(ev->efd, 1);
>  			signalled = true;
> +			vmpr->current_level = level;
>  		}
>  	}
>  
> @@ -290,9 +294,11 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup
> *memcg, int prio)
>   *
>   * This function associates eventfd context with the vmpressure
>   * infrastructure, so that the notifications will be delivered to the
> - * @eventfd. The @args parameter is a string that denotes pressure level
> + * @eventfd. The @args parameters are a string that denotes pressure level
>   * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
> - * "critical").
> + * "critical") and a trigger option that decides whether events are
> triggered
> + * continuously or only on edge (0 or 1 if 1, events are triggered only
> when
> + * the level changes.
>   *
>   * This function should not be used directly, just pass it to (struct
>   * cftype).register_event, and then cgroup core will handle everything by
> @@ -303,14 +309,31 @@ int vmpressure_register_event(struct cgroup *cg,
> struct cftype *cft,
>  {
>  	struct vmpressure *vmpr = cg_to_vmpressure(cg);
>  	struct vmpressure_event *ev;
> -	int level;
> +	unsigned long trigger = 0;
> +	int level, i = 0;
> +	char *s[2], *p;
> +
> +	while ((p = strsep((char **)&args, " ")) != NULL) {
> +		if (!*p)
> +			continue;
> +		s[i++] = p;
> +
> +		/* Prevent from inputing more than 2 args */
> +		if (i == 2)
> +			break;
> +	}
> +
> +	if (i != 2)
> +		return -EINVAL;

Ouch, this is just ugly.

> +
> +	trigger = simple_strtoul(s[1], NULL, sizeof(s[1]));
>  
>  	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
> -		if (!strcmp(vmpressure_str_levels[level], args))
> +		if (!strcmp(vmpressure_str_levels[level], s[0]))
>  			break;
>  	}
>  
> -	if (level >= VMPRESSURE_NUM_LEVELS)
> +	if (trigger > 1 || level >= VMPRESSURE_NUM_LEVELS)
>  		return -EINVAL;
>  
>  	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
> @@ -319,6 +342,7 @@ int vmpressure_register_event(struct cgroup *cg, struct
> cftype *cft,
>  
>  	ev->efd = eventfd;
>  	ev->level = level;
> +	ev->edge_trigger = trigger;
>  
>  	mutex_lock(&vmpr->events_lock);
>  	list_add(&ev->node, &vmpr->events);
> @@ -371,4 +395,5 @@ void vmpressure_init(struct vmpressure *vmpr)
>  	mutex_init(&vmpr->events_lock);
>  	INIT_LIST_HEAD(&vmpr->events);
>  	INIT_WORK(&vmpr->work, vmpressure_work_fn);
> +	vmpr->current_level = -1;
>  }
> -- 
> 1.7.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
